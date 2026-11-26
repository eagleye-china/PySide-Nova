# scripts/audit_v2_compat.py
# v2.0 双轨兼容契约守护（法源 docs/prescript/SPEC_V2_COMPAT.md §4）
"""只读机检：M1 就绪态守护 —— 零物理兼容视图 + 冻结公共面零漂移。

CSA 2026-11-26 10:44 指令「Controls 下新建的 Foundation 去掉」后，M1 由
「落地 1 个 pilot 兼容转发视图」回退为「**就绪态**」：地基焊死、零物理试探。
本脚本把该判断固化为机检，防止任何批次在冻结面之外偷建独立 qmldir / 子模块。

守护五条契约（全部可机检）：
  C1 旧 5 个冻结面 URI 的 qmldir 导出集合与 api/nova-api-1.2.0.json 逐项一致
  C2 产品树 @nova-compat-view 物理视图数 == 0（M1 就绪态硬约束）
  C3 全库 qmldir 恰 5 个冻结面模块，不得出现第 6 个模块
  C4 全库 QML 相对导入 0 处
  C5 生成器干净：gen_apidocs.py 无 @nova-compat-view 跳过死代码；
     docs/ai/index.json 5 模块 / 144 类型 / 无视图产物

> 面向 M2 的条件契约：若未来经 CSA 拍板 + additive major 重签后显式落地兼容
> 视图，本脚本 C2/C3 由「0 视图」切换为「视图导出 ⊆ 冻结面 + 单一事实源
> （../ 指向同一物理文件）」，规则见 SPEC_V2_COMPAT.md §4。**当前 0 视图即 PASS**。

不写任何文件；失败以非零码退出，可入 CI。
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
QML = ROOT / "src" / "pyside_nova" / "qml" / "Nova"
LEDGER = ROOT / "api" / "nova-api-1.2.0.json"
AI_INDEX = ROOT / "docs" / "ai" / "index.json"
AI_API = ROOT / "docs" / "ai" / "api"
GEN = ROOT / "scripts" / "gen_apidocs.py"
LAYERS = ["Controls", "Behaviors", "Services", "Design", "Composite/LayoutShell"]
MARK = "@nova-compat-view"
RELATIVE_IMPORT = re.compile(r'^\s*import\s+["\'][.~]')


def parse_qmldir(path: Path) -> tuple[str, list[tuple[str, str, str]]]:
    """→ (module, [(name, file, kind)])；跳过 # 注释 / internal / pragma / depends。"""
    module = ""
    out: list[tuple[str, str, str]] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        ln = raw.strip()
        if ln.startswith("module "):
            module = ln.split(None, 1)[1]
        elif ln.startswith("singleton "):
            p = ln.split()
            if len(p) >= 4:
                out.append((p[1], p[3], "singleton"))
        elif ln and not ln.startswith("#") and not ln.startswith(("internal ", "pragma ", "depends")):
            p = ln.split()
            if len(p) >= 3 and p[1].startswith("1."):
                out.append((p[0], p[2], "component"))
    return module, out


def main() -> int:
    errs: list[str] = []
    ledger = json.loads(LEDGER.read_text(encoding="utf-8"))
    frozen = ledger["types"]                       # key: "Nova.Controls.NovaAvatar"
    print(f"冻结面基线：{ledger['fingerprint']} · {len(frozen)} 类型 · "
          f"{len(ledger['counts']['modules'])} 个冻结面模块")

    # ── C1 旧 5 URI 零改动 ──────────────────────────────────────────
    seen: set[str] = set()
    for layer in LAYERS:
        qd = QML / layer / "qmldir"
        if not qd.exists():
            errs.append(f"C1 缺少冻结面 qmldir：{qd}")
            continue
        module, entries = parse_qmldir(qd)
        for name, file, _kind in entries:
            key = f"{module}.{name}"
            seen.add(key)
            if key not in frozen:
                errs.append(f"C1 冻结面出现新导出类型（被改）：{key}")
                continue
            expect = f"Nova/{layer}/{file}"
            if expect != frozen[key]["file"]:
                errs.append(f"C1 {key} 物理路径与冻结清单不符：{expect} ≠ {frozen[key]['file']}")
            if not (qd.parent / file).exists():
                errs.append(f"C1 {key} 源文件不存在：{file}")
    if len(seen) != len(frozen):
        errs.append(f"C1 冻结面导出数不符：qmldir {len(seen)} ≠ 清单 {len(frozen)}")
    print(f"[C1] 旧 5 URI 导出 {len(seen)} 类型 / 期望 {len(frozen)} · "
          f"{'PASS' if not any(e.startswith('C1') for e in errs) else 'FAIL'}")

    # ── C2 零物理兼容视图（M1 就绪态硬约束） ────────────────────────
    all_qmldirs = sorted(QML.glob("**/qmldir"))
    views = [p for p in all_qmldirs if MARK in p.read_text(encoding="utf-8")]
    if views:
        errs.append(f"C2 M1 就绪态要求 0 个物理兼容视图，实得 {len(views)} 个："
                    + ", ".join(p.relative_to(QML).as_posix() for p in views))
    print(f"[C2] 产品树 @nova-compat-view 物理视图 {len(views)} 个（期望 0）· "
          f"{'PASS' if not views else 'FAIL'}")

    # ── C3 qmldir 恰 5 个冻结面模块 ────────────────────────────────
    if len(all_qmldirs) != len(LAYERS):
        errs.append(f"C3 qmldir 数不符：{len(all_qmldirs)} ≠ {len(LAYERS)}（冻结面 5 模块）· "
                    + ", ".join(p.relative_to(QML).as_posix() for p in all_qmldirs))
    mods = {parse_qmldir(p)[0] for p in all_qmldirs}
    expect_mods = set(ledger["counts"]["modules"])
    if mods != expect_mods:
        errs.append(f"C3 模块 URI 集合不符：{sorted(mods)} ≠ {sorted(expect_mods)}")
    print(f"[C3] qmldir {len(all_qmldirs)} 个 / 冻结面模块 {len(mods)} 个 · "
          f"{'PASS' if not any(e.startswith('C3') for e in errs) else 'FAIL'}")

    # ── C4 相对导入 0 处 ────────────────────────────────────────────
    rel_hits: list[str] = []
    for f in sorted(QML.rglob("*.qml")):
        for i, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
            if RELATIVE_IMPORT.match(line):
                rel_hits.append(f"{f.relative_to(QML).as_posix()}:{i}")
    if rel_hits:
        errs.append(f"C4 相对导入破口：{rel_hits}")
    print(f"[C4] 全库 QML 相对导入 {len(rel_hits)} 处 · "
          f"{'PASS' if not rel_hits else 'FAIL'}")

    # ── C5 生成器干净 + AI 包零污染 ─────────────────────────────────
    gen_text = GEN.read_text(encoding="utf-8")
    if MARK in gen_text:
        errs.append(f"C5 gen_apidocs.py 残留 {MARK} 跳过死代码（视图已撤，应清除）")
    ai = json.loads(AI_INDEX.read_text(encoding="utf-8")) if AI_INDEX.exists() else {}
    ai_mods = ai.get("modules", {})
    ai_total = ai.get("types_total", -1)
    if len(ai_mods) != len(LAYERS):
        errs.append(f"C5 AI 包模块数 {len(ai_mods)} ≠ {len(LAYERS)}")
    if ai_total != len(frozen):
        errs.append(f"C5 AI 包 types_total {ai_total} ≠ {len(frozen)}")
    # 精确泄漏检查：AI 包 api 文件名集合必须 == 冻结清单 144 类型的 {key}.json
    expect_names = {f"{k}.json" for k in frozen}
    got_names = {p.name for p in AI_API.glob("*.json")} if AI_API.exists() else set()
    leaked = sorted(got_names - expect_names)
    if leaked:
        errs.append(f"C5 AI 包混入冻结面之外的产物（疑似视图泄漏）：{leaked}")
    print(f"[C5] 生成器跳过死代码 {'残留' if MARK in gen_text else '0 处'} · "
          f"AI 包 {len(ai_mods)} 模块 / {ai_total} 类型 / 视图产物 {len(leaked)} 个 · "
          f"{'PASS' if not any(e.startswith('C5') for e in errs) else 'FAIL'}")

    print()
    if errs:
        for e in errs:
            print(f"  ✗ {e}")
        print(f"\n结论：FAIL · {len(errs)} 项破口")
        return 1
    print(f"结论：PASS · M1 就绪态（0 物理视图）· 冻结面 {ledger['fingerprint']} 零漂移 · "
          f"5 个冻结面模块 · 相对导入 0 处 · 生成器干净 · AI 包 {ai.get('fingerprint', 'n/a')} 零污染")
    return 0


if __name__ == "__main__":
    sys.exit(main())
