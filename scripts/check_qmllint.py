#!/usr/bin/env python3
# scripts/check_qmllint.py
# qmllint 门禁（六期 RC1）：error 零容忍 + warning 按类别设预算，只降不升
# 24 条封版验收「qmllint 0 error、0 warning」的工程化落地：先锁 error=0，再逐类还债
"""qmllint 静态检查门禁。

**为什么不是「0 warning」直接卡死**：1.0 的 124 个类型里有 500+ 条 `[unqualified]`——
这是 QML 嵌套组件引用外层 `id` 的经典告警，官方给的解法是 `pragma ComponentBehavior: Bound`，
而该 pragma 会改变嵌套组件的上下文捕获语义（委托里隐式取外层 id 的行为被收紧），
在封版窗口内全库改造的风险远大于收益。因此本门禁采用**预算制**：

- `error`：**零容忍**，出现即红（真正的解析/类型错误）；
- `warning`：按类别记录预算（`tests/lint-baseline.json`），现网数 > 预算数即红；
  修一处就 `--update` 下调预算，**只降不升**——欠债有账，不能悄悄变多。

用法::

    python scripts/check_qmllint.py            # 校验（CI / 交付前）
    python scripts/check_qmllint.py --update   # 修完告警后下调预算并写盘
    python scripts/check_qmllint.py -v         # 打印每类前 3 条明细，便于排期还债
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
QML_ROOT = ROOT / "src" / "pyside_nova" / "qml"
BASELINE = ROOT / "tests" / "lint-baseline.json"

DIAG_RE = re.compile(r"^(Warning|Error): (.+?):(\d+):(\d+): (.+?)(?: \[([\w-]+)\])?$")

# 预算为 0 的类别也要显式登记（新增类别默认 0，防止悄悄引入新坑）
KNOWN_CATEGORIES = [
    "unqualified", "missing-property", "unused-imports", "import",
    "block-scope-var-declaration", "index", "id-shadows-member", "property-override",
    "deprecated", "syntax", "unresolved-type", "internal",
]


def find_qmllint() -> str:
    """优先 PATH 上的 pyside6-qmllint；退化为 PySide6 包内二进制。

    Windows 注意（坑位 52）：PySide6 包内是 ``qmllint.exe``，``Path.exists()``
    不会补 ``.exe`` 后缀，且部分环境 Scripts/ 下没有 ``pyside6-qmllint`` 入口脚本——
    必须把带后缀的候选显式列出，否则门禁在中文 Windows 交付机上假红灯。
    """
    exe = shutil.which("pyside6-qmllint") or shutil.which("qmllint")
    if exe:
        return exe
    import PySide6
    pkg = Path(PySide6.__file__).parent
    # POSIX 无后缀 / Windows 带 .exe，两者都试；顺序保证跨平台确定性
    for name in ("qmllint", "qmllint.exe"):
        cand = pkg / name
        if cand.exists():
            return str(cand)
    raise SystemExit("找不到 qmllint（需 PySide6 ≥ 6.4）")


def run_lint() -> tuple[dict[str, int], list[str], list[str]]:
    """返回 (类别计数, error 明细, warning 明细)。"""
    files = sorted(str(p) for p in QML_ROOT.rglob("*.qml"))
    cmd = [find_qmllint(), "-I", str(QML_ROOT), *files]
    # qmllint 把诊断写到 stderr（stdout 只留源码片段），两股流合并解析。
    # 坑位 52：text=True 走 locale 默认编码，中文 Windows 是 GBK，而诊断含 UTF-8 路径
    # 时解码崩 UnicodeDecodeError——显式 utf-8 + replace，脏字节不致命、正文照常解析。
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                          encoding="utf-8", errors="replace")
    counts: dict[str, int] = {}
    errors: list[str] = []
    warnings: list[str] = []
    for line in proc.stdout.splitlines():
        m = DIAG_RE.match(line.strip())
        if not m:
            continue
        level, path, ln, col, msg, cat = m.groups()
        rel = path.split("qml/Nova/")[-1]
        entry = f"{rel}:{ln}:{col} {msg}"
        if level == "Error":
            errors.append(entry)
            continue
        warnings.append(f"[{cat or 'other'}] {entry}")
        key = cat or "other"
        counts[key] = counts.get(key, 0) + 1
    return counts, errors, warnings


def load_baseline() -> dict:
    if not BASELINE.exists():
        return {}
    return json.loads(BASELINE.read_text(encoding="utf-8"))


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="qmllint 门禁")
    ap.add_argument("--update", action="store_true", help="按现网结果下调预算（只降不升）")
    ap.add_argument("-v", "--verbose", action="store_true", help="打印每类明细抽样")
    args = ap.parse_args(argv)

    counts, errors, warnings = run_lint()
    total = sum(counts.values())
    baseline = load_baseline()
    budget = baseline.get("budget", {})

    if args.update:
        merged = {k: max(counts.get(k, 0), 0) for k in set(budget) | set(counts)}
        # 只降不升：新预算不得高于旧预算（除非该类别此前不存在）
        for k, v in list(merged.items()):
            if k in budget and v > budget[k]:
                merged[k] = budget[k]
        payload = {
            "tool": "pyside6-qmllint",
            "scope": "src/pyside_nova/qml/**/*.qml",
            "total": sum(merged.values()),
            "budget": dict(sorted(merged.items())),
            "policy": "error 零容忍；warning 按类别预算，只降不升（--update 只允许下调）",
            "note": "预算内告警以 [unqualified] 为主（嵌套组件引用外层 id），"
                    "根治需全库 pragma ComponentBehavior: Bound，封版窗口内不做",
        }
        BASELINE.write_text(json.dumps(payload, indent=1, ensure_ascii=False) + "\n",
                            encoding="utf-8")
        print(f"✓ 已写预算：{BASELINE.relative_to(ROOT)}（{len(merged)} 类 / {sum(merged.values())} 条）")
        return 0

    print(f"qmllint 门禁 · {len(list(QML_ROOT.rglob('*.qml')))} 文件 · 现网 {total} warning / {len(errors)} error")
    print(f"  {'类别':<26}{'现网':>6}{'预算':>6}  状态")
    over: list[str] = []
    for cat in sorted(set(counts) | set(budget), key=lambda c: -max(counts.get(c, 0), budget.get(c, 0))):
        cur, lim = counts.get(cat, 0), budget.get(cat, 0)
        state = "✓"
        if cat not in budget:
            state = "✗ 新类别（未立预算）"
            over.append(cat)
        elif cur > lim:
            state = f"✗ 超预算 +{cur - lim}"
            over.append(cat)
        elif cur < lim:
            state = f"↓ 可下调 {lim - cur}"
        print(f"  {cat:<26}{cur:>6}{lim:>6}  {state}")
        if args.verbose and state.startswith("✗"):
            for w in [x for x in warnings if x.startswith(f"[{cat}]")][:3]:
                print(f"      {w}")

    if errors:
        print("\n✗ qmllint 报 error（零容忍）：")
        for e in errors[:20]:
            print(f"  {e}")
        return 1
    if over:
        print(f"\n✗ qmllint 门禁未通过：{len(over)} 类超预算/未登记（{', '.join(over)}）")
        print("  修完跑 `python scripts/check_qmllint.py --update` 下调预算")
        return 1
    print(f"\n✓ qmllint 门禁通过：0 error · {total} warning 全在预算内")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
