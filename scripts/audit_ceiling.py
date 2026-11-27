# scripts/audit_ceiling.py
# 组合根容器天花板机检（CARF-R / CC-7）：20 项静态契约扫描 + 字面量实例化 + 极端非法入参稳态几何
"""20/20 天花板逐项销号的机检入口。

法源：母法卷首 CARF 宣言 · 组合宪法 1.0.0 第 9 章 CC-1~CC-8
      · docs/prescript/AUDIT_CEILING.md（逐项销号台账）

覆盖：
  1. 静态机检表：组合上下文 / 单一分隔源 / 主色系 / 动效令牌 / RTL / 恒定锚链 / 槽位宿主
  2. 无头实例化：20 组合组件字面量 + 20 独立 showcase + Gallery = 41/41
  3. 极端非法入参：每项注入全部数值属性的 -999 / 999999 / undefined 三组，
     等待 Behavior 收敛后遍历对象树，确认稳态几何非负且有限
  4. RTL 20/20 实例化（NovaI18n.setLocale("ar")）
  5. reducedMotion：NovaMotion.duration(300) 300 → 0
  6. 文档相对链接断链扫描

用法：python scripts/audit_ceiling.py
"""
from __future__ import annotations

import json
import math
import os
import re
import sys
import time
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

from PySide6.QtCore import QUrl  # noqa: E402
from PySide6.QtGui import QGuiApplication  # noqa: E402
from PySide6.QtQml import QQmlComponent, QQmlEngine  # noqa: E402
from PySide6.QtQuick import QQuickItem, QQuickWindow  # noqa: E402

from pyside_nova import init_nova  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
QMLDIR = ROOT / "src" / "pyside_nova" / "qml" / "Nova" / "Composite" / "LayoutShell"
EXAMPLES = ROOT / "examples" / "layout_shell"


def _qml_files() -> dict:
    """从 qmldir 解析 {类型名: 真实路径}；1.2.0 起组合根按九类物理子目录归档。"""
    out = {}
    for ln in (QMLDIR / "qmldir").read_text(encoding="utf-8").splitlines():
        parts = ln.strip().split()
        if len(parts) >= 3 and parts[1].startswith("1."):
            out[parts[0]] = QMLDIR / parts[2]
    return out


QML_FILES = _qml_files()
API = ROOT / "api" / "nova-api-1.5.0.json"

NAMES = [
    "NovaChat", "NovaDesktop", "NovaMobile", "NovaFlexLayout",
    "NovaSidebar", "NovaTopNavigation", "NovaDualSide",
    "NovaTabShell", "NovaThreeColumn", "NovaCompare", "NovaCardGrid",
    "NovaModal", "NovaDrawerPanel", "NovaSetupWizard", "NovaBlankPage",
    "NovaAgent", "NovaDE", "NovaCopilot", "NovaOrbit", "NovaIncubator",
]
EXAMPLE_DIRS = [
    "chat", "desktop", "mobile", "flex_layout", "sidebar", "top_navigation",
    "dual_side", "tab_shell", "three_column", "compare", "card_grid",
    "modal", "drawer_panel", "setup_wizard", "blank_page",
    "agent", "de", "copilot", "orbit", "incubator",
]

_PROBE = b"""
import QtQuick
import Nova.Services
import Nova.Design
QtObject {
    function dur() { return NovaMotion.duration(NovaMotion.transitionDuration) }
    function setReduced(v) { NovaMotion.reducedMotion = v }
    function setRtl(v) { NovaI18n.setLocale(v ? "ar" : "en-US") }
}
"""

_ALIVE: list = []


def pump(seconds: float = 0.35) -> None:
    end = time.perf_counter() + seconds
    while time.perf_counter() < end:
        QGuiApplication.processEvents()
        time.sleep(0.01)


def _strip_comments(src: str) -> str:
    """机检语义：反模式扫描只针对用户可见内容；// 行注释与 /* */ 块注释是工程史料，不参与。

    注释里「替换原伪按钮」描述的是**已修复的历史**，不是可见占位文案；剥离注释后仍
    全量扫描真实 QML 文本，检测强度不降低（真实占位文案依旧会被判 FAIL）。
    """
    src = re.sub(r"/\*.*?\*/", "", src, flags=re.S)
    return re.sub(r"(?m)^[ \t]*//.*$", "", src)


def static_audit() -> list[dict]:
    rows = []
    anchor_ternary = re.compile(r"anchors\s*\{[^}]*\?[^}]*:[^}]*\}", re.S)
    for name in NAMES:
        src = QML_FILES[name].read_text(encoding="utf-8")
        code = _strip_comments(src)
        low_opacity = re.findall(r"opacity:\s*(0\.\d+)", code)
        weak = [float(x) for x in low_opacity if float(x) < 0.85]
        # CC-3 功能性遮罩例外：id 为 _mask / _scrim 的半透明层刻意透出下层，
        # 不属于「低实心」反模式；仅从展示值中剔除，不改变任何 PASS/FAIL 判定。
        for mid in ("_mask", "_scrim"):
            m = re.search(r"id:\s*" + mid + r"\b[\s\S]{0,300}?opacity:\s*(0\.\d+)", code)
            if m and float(m.group(1)) in weak:
                weak.remove(float(m.group(1)))
        rows.append({
            "name": name,
            "context": "readonly property real _unit" in code,
            "motion": "NovaMotion.duration(" in code,
            "rtl": "LayoutMirroring.enabled" in code,
            "anchor_ternary": len(anchor_ternary.findall(code)),
            "clash_colors": len(re.findall(r"NovaTheme\.(secondary|accent)", code)),
            "hardcoded_duration": len(re.findall(r"duration:\s*2\d\d\b", code)),
            "weak_opacity": weak,
            "behavior": len(re.findall(r"Behavior on (?:height|width|x)\b", code)),
            "aliases": len(re.findall(r"property alias \w+", code)),
            "placeholder_words": len(re.findall(r"占位|按钮位标识|伪按钮|（注入业务）", code)),
        })
    return rows


def _create(engine, qml: str):
    comp = QQmlComponent(engine)
    comp.setData(qml.encode("utf-8"), QUrl("qrc:/ceiling-audit.qml"))
    obj = comp.create()
    if obj is None:
        raise RuntimeError(" | ".join(e.toString() for e in comp.errors()))
    _ALIVE.append(comp)
    _ALIVE.append(obj)
    return obj


def _load(engine, path: Path):
    comp = QQmlComponent(engine, QUrl.fromLocalFile(str(path)))
    obj = comp.create()
    if obj is None:
        raise RuntimeError(f"{path.name}: " + " | ".join(e.toString() for e in comp.errors()))
    _ALIVE.append(comp)
    _ALIVE.append(obj)
    return obj


def _geometry_ok(obj) -> tuple[bool, str]:
    import math as _m
    items = [obj] + list(obj.findChildren(QQuickItem))
    for it in items:
        try:
            w, h = it.width(), it.height()
        except RuntimeError:
            continue
        if not (_m.isfinite(w) and _m.isfinite(h)) or w < 0 or h < 0:
            return False, f"{it.metaObject().className()} {w}x{h}"
    return True, ""


def numeric_props() -> dict[str, list[str]]:
    data = json.loads(API.read_text(encoding="utf-8"))
    out = {}
    for name in NAMES:
        key = f"Nova.Composite.LayoutShell.{name}"
        props = data["types"][key]["props"]
        nums = []
        for p in props:
            if p.startswith("ro "):
                continue
            pname, _, ptype = p.partition(":")
            if ptype in ("int", "real"):
                nums.append(pname)
        out[name] = nums
    return out


def dynamic_audit(engine) -> dict:
    result = {"instantiated": 0, "showcases": 0, "illegal": {}, "rtl": 0, "reduced": ""}
    failures = []

    # ① 20 组件字面量实例化
    for name in NAMES:
        try:
            _create(engine, f"import QtQuick\nimport Nova.Composite.LayoutShell 1.0\n{name} {{ width: 1024; height: 720 }}")
            result["instantiated"] += 1
        except Exception as exc:  # noqa: BLE001
            failures.append(f"instantiate {name}: {exc}")

    # ② 20 独立 showcase + Gallery
    for d in EXAMPLE_DIRS:
        try:
            _load(engine, EXAMPLES / d / "main.qml")
            result["showcases"] += 1
        except Exception as exc:  # noqa: BLE001
            failures.append(f"showcase {d}: {exc}")
    try:
        _load(engine, ROOT / "examples" / "gallery" / "main.qml")
        result["showcases"] += 1
    except Exception as exc:  # noqa: BLE001
        failures.append(f"gallery: {exc}")

    # ③ 极端非法入参：三组（-999 / 999999 / undefined），等待 Behavior 收敛后测稳态几何
    props = numeric_props()
    for name in NAMES:
        cases = 0
        for bad in ("-999", "999999", "undefined"):
            assigns = "\n    ".join(f"{p}: {bad}" for p in props[name])
            qml = f"import QtQuick\nimport Nova.Composite.LayoutShell 1.0\n{name} {{\n    width: 1024; height: 720\n    {assigns}\n}}"
            try:
                obj = _create(engine, qml)
                pump(0.45)
                ok, detail = _geometry_ok(obj)
                if not ok:
                    failures.append(f"illegal {name} {bad}: 负/非有限几何 {detail}")
                else:
                    cases += 1
            except Exception as exc:  # noqa: BLE001
                failures.append(f"illegal {name} {bad}: {exc}")
        result["illegal"][name] = cases

    # ④ RTL 20/20
    probe_comp = QQmlComponent(engine)
    probe_comp.setData(_PROBE, QUrl("qrc:/ceiling-probe.qml"))
    probe = probe_comp.create()
    if probe is None:
        failures.append("probe: " + " | ".join(e.toString() for e in probe_comp.errors()))
    else:
        _ALIVE.extend([probe_comp, probe])
        probe.setRtl(True)
        pump(0.15)
        for name in NAMES:
            try:
                _create(engine, f"import QtQuick\nimport Nova.Composite.LayoutShell 1.0\n{name} {{ width: 900; height: 640 }}")
                result["rtl"] += 1
            except Exception as exc:  # noqa: BLE001
                failures.append(f"rtl {name}: {exc}")
        probe.setRtl(False)
        # ⑤ reducedMotion 300 → 0
        before = probe.dur()
        probe.setReduced(True)
        after = probe.dur()
        probe.setReduced(False)
        result["reduced"] = f"{before} → {after}"
        if int(before) <= 0 or int(after) != 0:
            failures.append(f"reducedMotion 异常：{before} → {after}")

    result["failures"] = failures
    return result


def link_audit() -> tuple[int, list[str]]:
    broken = []
    checked = 0
    for md in (ROOT / "docs").rglob("*.md"):
        text = md.read_text(encoding="utf-8", errors="replace")
        for target in re.findall(r"\]\(([^)]+)\)", text):
            if target.startswith(("http://", "https://", "#", "mailto:")):
                continue
            rel = target.split("#")[0].split("?")[0]
            if not rel:
                continue
            checked += 1
            p = (md.parent / rel).resolve()
            if not p.exists():
                broken.append(f"{md.relative_to(ROOT)} -> {rel}")
    return checked, broken


def main() -> int:
    app = QGuiApplication.instance() or QGuiApplication([])
    engine = QQmlEngine()
    init_nova(engine)

    print("=" * 78)
    print("pyside-nova · 20/20 天花板机检（CARF-R / CC-7）")
    print("=" * 78)

    rows = static_audit()
    print("\n[1] 静态机检表（20 项 CC 契约信号）")
    print(f"{'组件':<20}{'CC-1':<6}{'动效':<6}{'RTL':<5}{'锚链三元':<9}{'撞色':<6}{'硬编码':<7}{'低实心':<8}{'Behavior':<10}{'槽位':<5}")
    static_fail = []
    for r in rows:
        print(f"{r['name']:<20}{'✓' if r['context'] else '✗':<6}{'✓' if r['motion'] else '✗':<6}"
              f"{'✓' if r['rtl'] else '✗':<5}{r['anchor_ternary']:<9}{r['clash_colors']:<6}"
              f"{r['hardcoded_duration']:<7}{len(r['weak_opacity']):<8}{r['behavior']:<10}{r['aliases']:<5}")
        if not (r["context"] and r["motion"] and r["rtl"]):
            static_fail.append(f"{r['name']} 缺组合上下文/动效/RTL")
        if r["anchor_ternary"] or r["clash_colors"] or r["hardcoded_duration"] or r["placeholder_words"]:
            static_fail.append(f"{r['name']} 残留反模式（三元 {r['anchor_ternary']} / 撞色 {r['clash_colors']} / 硬编码 {r['hardcoded_duration']} / 占位 {r['placeholder_words']}）")

    print("\n[2] 动态验收")
    dyn = dynamic_audit(engine)
    print(f"  组件字面量实例化      {dyn['instantiated']}/{len(NAMES)}")
    print(f"  showcase + Gallery    {dyn['showcases']}/{len(EXAMPLE_DIRS) + 1}")
    illegal_pass = sum(1 for v in dyn["illegal"].values() if v == 3)
    print(f"  极端非法入参稳态几何  {illegal_pass}/{len(NAMES)}（每项 3 组；共 {sum(dyn['illegal'].values())}/{len(NAMES) * 3} 组）")
    print(f"  RTL 镜像实例化        {dyn['rtl']}/{len(NAMES)}")
    print(f"  reducedMotion         {dyn['reduced']}")
    if dyn["failures"]:
        for f in dyn["failures"][:20]:
            print("  ✗ " + f)

    checked, broken = link_audit()
    print(f"\n[3] 文档相对链接        {checked} 条检查 · 断链 {len(broken)}")
    for b in broken[:10]:
        print("  ✗ " + b)

    failures = static_fail + dyn["failures"] + broken
    print("\n" + "=" * 78)
    if failures:
        print(f"结论：FAIL · {len(failures)} 项待销号")
        return 1
    print("结论：PASS · 20/20 六维天花板机检全绿（CARF-R 销号条件达成）")
    return 0


if __name__ == "__main__":
    code = main()
    sys.stdout.flush()
    sys.stderr.flush()
    os._exit(code)
