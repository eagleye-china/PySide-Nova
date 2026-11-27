# scripts/audit_domains.py
# pyside-nova 1.5.0 · 基础组件域分类机检与台账生成器
"""COMPONENT_DOMAINS.md 的可验证底座（文档层概念域，非物理层）。

事实源：api/nova-api-1.5.0.json（冻结清单）+ src/.../Nova/**/qmldir（模块归属）
本脚本是 api/component-domains-1.5.0.json 的**唯一生成器**；该 JSON 为生成物，禁手改。

铁律：域分类只落在文档 / 台账层，**不改变 qmldir 模块 URI、不改冻结面指纹、
不移动任何 QML 物理文件**。原稿 NOVA_CLASSIFY.md 主张的「每子目录独立 qmldir +
批量改 import」经本库实测证伪（qmldir 支持相对子路径导出、全库 0 处相对导入），
且属 additive major + RFC 议题，未采纳。
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
API = ROOT / "api" / "nova-api-1.5.0.json"
EMIT = ROOT / "api" / "component-domains-1.5.0.json"
QML = ROOT / "src" / "pyside_nova" / "qml" / "Nova"

# ── Controls 93 → 七大控件域 ────────────────────────────────────────────────
# 对齐原稿「Controls 按 7 大域」建议，并补齐其遗漏的 5 个真实导出类型：
#   NovaBar / NovaTransition（基础展示）· NovaNoSsr / NovaResizeObserver /
#   NovaResponsive（响应式辅助 → 智能交互）
CONTROL_DOMAINS: dict[str, list[str]] = {
    "Foundation": [
        "NovaAvatar", "NovaBadge", "NovaChip", "NovaIcon", "NovaImg",
        "NovaSeparator", "NovaSkeleton", "NovaSpace", "NovaSpinner", "NovaText",
        "NovaBar", "NovaTransition",
    ],
    "Form": [
        "NovaForm", "NovaField", "NovaInput", "NovaSelect", "NovaOptionGroup",
        "NovaCheckbox", "NovaRadio", "NovaToggle", "NovaBtnToggle", "NovaSlider",
        "NovaRange", "NovaDate", "NovaTime", "NovaColorPicker", "NovaEditor",
    ],
    "Action": [
        "NovaBtn", "NovaBtnGroup", "NovaBtnDropdown", "NovaFab", "NovaFabAction",
        "NovaPullToRefresh", "NovaPopupEdit",
    ],
    "Navigation": [
        "NovaTabs", "NovaTab", "NovaTabPanel", "NovaTabPanels", "NovaBreadcrumbs",
        "NovaBreadcrumbsEl", "NovaPagination", "NovaStepper", "NovaStep",
        "NovaStepperNavigation", "NovaMenu", "NovaToolbar", "NovaToolbarTitle",
        "NovaHeader", "NovaFooter",
    ],
    "Layout": [
        "NovaLayout", "NovaPage", "NovaRow", "NovaCol", "NovaCard", "NovaCardActions",
        "NovaCardSection", "NovaExpansionItem", "NovaDrawer", "NovaBottomSheet",
        "NovaDialogShell", "NovaScrollArea", "NovaVirtualScroll", "NovaInfiniteScroll",
    ],
    "Data": [
        "NovaTable", "NovaMarkupTable", "NovaTr", "NovaTd", "NovaTh", "NovaList",
        "NovaItem", "NovaItemLabel", "NovaItemSection", "NovaTree", "NovaTimeline",
        "NovaTimelineEntry", "NovaCarousel", "NovaCarouselControl",
        "NovaCarouselSlide", "NovaSlideItem", "NovaVideo", "NovaParallax",
        "NovaMarkdown", "NovaDataGrid",
    ],
    "Intelligent": [
        "NovaChatMessage", "NovaTooltip", "NovaInnerLoading", "NovaBanner",
        "NovaAjaxBar", "NovaPopupProxy", "NovaVisible", "NovaNoSsr",
        "NovaResizeObserver", "NovaResponsive",
    ],
}

# ── Behaviors 13 → 三大行为域 ───────────────────────────────────────────────
# NovaTouchCore.qml 是目录内**存在但未导出**的内部 helper，不纳入 146 类型。
BEHAVIOR_DOMAINS: dict[str, list[str]] = {
    "Gestures": ["NovaTouchHold", "NovaTouchPan", "NovaTouchRepeat", "NovaTouchSwipe"],
    "Observers": ["NovaIntersection", "NovaScrollFire", "NovaScrollObserver"],
    "Effects": [
        "NovaClosePopup", "NovaFocusRing", "NovaLiveRegion", "NovaMorph",
        "NovaMorphPool", "NovaRipple",
    ],
}

# ── 20 组合根 → 九类（沿用 COMPONENT_CLASSIFICATION.md §4 / 模块 README） ──
COMPOSITE_GROUPS: dict[str, list[str]] = {
    "Navigation": ["NovaSidebar", "NovaTopNavigation", "NovaDualSide", "NovaTabShell"],
    "Workbench": ["NovaThreeColumn", "NovaCompare", "NovaCardGrid"],
    "Overlay": ["NovaModal", "NovaDrawerPanel"],
    "Page": ["NovaSetupWizard", "NovaBlankPage"],
    "Carrier": ["NovaDesktop", "NovaMobile", "NovaFlexLayout"],
    "Chat": ["NovaChat"],
    "Intelligence": ["NovaAgent", "NovaDE", "NovaCopilot"],
    "Orbit": ["NovaOrbit"],
    "Incubator": ["NovaIncubator"],
}

INTERNAL_HELPERS = [
    {
        "name": "NovaTouchCore",
        "file": "Behaviors/NovaTouchCore.qml",
        "reason": "手势域内部实现 helper，未在 Behaviors/qmldir 导出，不计入 146 类型",
    },
]

UPWARD = re.compile(r"import\s+Nova\.(Composite|Entities|Orbit|Incubator|Base|Prescient)")
RELATIVE_IMPORT = re.compile(r'import\s+"[.~]')


def _flatten(groups: dict[str, list[str]]) -> dict[str, str]:
    out: dict[str, str] = {}
    for domain, names in groups.items():
        for n in names:
            if n in out:
                raise ValueError(f"域分类重复：{n} 同时属于 {out[n]} 与 {domain}")
            out[n] = domain
    return out


def build() -> tuple[dict, list[str]]:
    """返回 (台账, 错误列表)。两段式：先全量校验，再由调用方决定是否写盘。"""
    errs: list[str] = []
    api = json.loads(API.read_text(encoding="utf-8"))
    types: dict[str, dict] = api["types"]
    by_short: dict[str, dict] = {k.split(".")[-1]: v for k, v in types.items()}

    ctrl = _flatten(CONTROL_DOMAINS)
    beh = _flatten(BEHAVIOR_DOMAINS)
    comp = _flatten(COMPOSITE_GROUPS)
    mapped = {**ctrl, **beh, **comp}

    # [1] 域计数
    if len(ctrl) != 93:
        errs.append(f"Controls 域分类应为 93，实得 {len(ctrl)}")
    if len(beh) != 13:
        errs.append(f"Behaviors 域分类应为 13，实得 {len(beh)}")
    if len(comp) != 20:
        errs.append(f"组合根九类应为 20，实得 {len(comp)}")

    # [2] 零遗漏 / 零幽灵 / 模块归属一致
    for short, info in by_short.items():
        mod = info["module"]
        if mod in ("Nova.Controls", "Nova.Behaviors", "Nova.Composite.LayoutShell"):
            if short not in mapped:
                errs.append(f"[{mod}] {short} 未归入任何域")
            else:
                expect = {
                    "Nova.Controls": "controls",
                    "Nova.Behaviors": "behaviors",
                    "Nova.Composite.LayoutShell": "composite",
                }[mod]
                actual = "controls" if short in ctrl else "behaviors" if short in beh else "composite"
                if expect != actual:
                    errs.append(f"{short} 域归属与冻结清单模块不符：{mod} vs {actual}")
    for short in mapped:
        if short not in by_short:
            errs.append(f"域分类存在冻结清单之外的幽灵类型：{short}")

    # [3] 冻结面 146 / 5 模块守护
    if len(types) != 146:
        errs.append(f"冻结清单应为 146 类型，实得 {len(types)}")
    mods = sorted({v["module"] for v in types.values()})
    if len(mods) != 5:
        errs.append(f"qmldir 模块应为 5 个，实得 {len(mods)}：{mods}")

    # [4] 单向依赖 / 相对导入守护（只读 QML 源码，不改任何文件）
    upward_hits: list[str] = []
    rel_hits: list[str] = []
    for sub in ("Controls", "Behaviors"):
        for f in (QML / sub).glob("*.qml"):
            text = f.read_text(encoding="utf-8")
            if UPWARD.search(text):
                upward_hits.append(str(f.relative_to(QML)))
            if RELATIVE_IMPORT.search(text):
                rel_hits.append(str(f.relative_to(QML)))
    if upward_hits:
        errs.append(f"单向依赖破口（基础层 import 上层模块）：{upward_hits}")
    if rel_hits:
        errs.append(f"出现相对导入（与绝对模块导入纪律冲突）：{rel_hits}")

    # [5] 台账组装
    entries: dict[str, dict] = {}
    for fqn, info in types.items():
        short = fqn.split(".")[-1]
        mod = info["module"]
        if short in ctrl:
            arch, domain, group = "controls", ctrl[short], "—"
        elif short in beh:
            arch, domain, group = "behaviors", beh[short], "—"
        elif short in comp:
            arch, domain, group = "composite", "—", comp[short]
        elif mod == "Nova.Services":
            arch, domain, group = "services", "—", "—"
        else:
            arch, domain, group = "design", "—", "—"
        entries[fqn] = {"module": mod, "archDomain": arch, "domain": domain, "group": group}

    ledger = {
        "schema": "nova-component-domains/1",
        "package": "pyside-nova",
        "apiVersion": api["apiVersion"],
        "fingerprint": api["fingerprint"],
        "source": "api/nova-api-1.5.0.json",
        "generator": "scripts/audit_domains.py",
        "note": "概念域分类（文档层），不改变 qmldir 模块 URI / 冻结面 / QML 物理目录",
        "counts": {
            "total": len(types),
            "controls": len(ctrl),
            "behaviors": len(beh),
            "services": sum(1 for v in types.values() if v["module"] == "Nova.Services"),
            "design": sum(1 for v in types.values() if v["module"] == "Nova.Design"),
            "composite": len(comp),
            "controlDomains": len(CONTROL_DOMAINS),
            "behaviorDomains": len(BEHAVIOR_DOMAINS),
            "compositeGroups": len(COMPOSITE_GROUPS),
            "modules": len(mods),
        },
        "controlDomains": CONTROL_DOMAINS,
        "behaviorDomains": BEHAVIOR_DOMAINS,
        "compositeGroups": COMPOSITE_GROUPS,
        "internalHelpers": INTERNAL_HELPERS,
        "guard": {
            "upwardImports": len(upward_hits),
            "relativeImports": len(rel_hits),
        },
        "types": entries,
    }
    return ledger, errs


def main() -> int:
    ap = argparse.ArgumentParser(description="基础组件域分类机检 / 台账生成")
    ap.add_argument("--emit", action="store_true", help="生成 api/component-domains-1.5.0.json（生成物禁手改）")
    args = ap.parse_args()

    try:
        ledger, errs = build()
    except (ValueError, KeyError, OSError) as e:
        print(f"结论：FAIL · 构建台账异常：{e}")
        return 1

    c = ledger["counts"]
    print("=" * 78)
    print("pyside-nova 1.5.0 · 基础组件域分类机检（文档层概念域）")
    print("=" * 78)
    print(f"[1] 冻结面            {c['total']} 类型 / {c['modules']} 个 qmldir 模块 · 指纹 {ledger['fingerprint']}")
    print(f"[2] Controls           {c['controls']} → {c['controlDomains']} 域")
    print(f"[3] Behaviors          {c['behaviors']} → {c['behaviorDomains']} 域")
    print(f"[4] 组合根             {c['composite']} → {c['compositeGroups']} 类")
    print(f"[5] 服务 / 设计        {c['services']} / {c['design']}（不归域，按架构域标注）")
    print(f"[6] 零遗漏 / 零重复 / 零幽灵   {'PASS' if not errs else 'FAIL'}")
    print(f"[7] 单向依赖守护       上层 import {ledger['guard']['upwardImports']} 处 · 相对导入 {ledger['guard']['relativeImports']} 处")
    print(f"[8] 内部 helper        {', '.join(h['name'] for h in INTERNAL_HELPERS)}（未导出，不计入 146）")

    if errs:
        print("-" * 78)
        for e in errs:
            print(f"  ✗ {e}")
        print("结论：FAIL · 域分类台账不自洽，未写盘")
        return 1

    if args.emit:
        EMIT.write_text(json.dumps(ledger, ensure_ascii=False, indent=1, sort_keys=True) + "\n",
                        encoding="utf-8")
        print(f"[emit] 已生成 {EMIT.relative_to(ROOT)}（生成物，禁手改）")

    print("=" * 78)
    print(f"结论：PASS · 146 类型零遗漏 · 105 基础类型全归域 · 单向依赖 0 破口 · 零物理改动")
    return 0


if __name__ == "__main__":
    sys.exit(main())
