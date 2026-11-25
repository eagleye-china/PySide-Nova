# scripts/check_a11y.py
# 可访问性门禁：逐类型核对 Accessible 契约（角色/名称/焦点/键盘/焦点环），生成 docs/A11Y_MATRIX.md（0.16.0 新颁）
# pyside-nova a11y 门禁（WCAG 2.1 AA · 五期 Sprint B）
"""可访问性静态门禁：把「每个导出类型该有什么 a11y 契约」写成可执行的表。

三类契约（分类是审计结论，不是实现细节）：

- ``interactive``：可操作控件。必须有 ``Accessible.role`` + ``Accessible.name`` +
  键盘入口（``activeFocusOnTab`` 或继承自 NovaField）+ ``NovaFocusRing``，且至少一条 ``Keys.on*``。
- ``semantic``：只读语义元素（图表/进度/状态/链接文本）。必须有 role + name（name 可为空则需
  在备注里写明「由 i18n 提供」或「装饰性图标可空」）。
- ``decorative``：布局容器与装饰。**禁止**挂 Accessible.*（避免屏读器噪声），源码须带
  ``a11y: decorative`` 标记，便于审阅者一眼看出「不是漏了，是故意的」。

用法::

    python scripts/check_a11y.py                  # 只校验，缺项退出码 1
    python scripts/check_a11y.py --matrix docs/A11Y_MATRIX.md   # 同时生成矩阵文档

门禁接入：CI 与 local_deploy 交付前均调用；缺项即阻断交付（宪法第 8 章）。
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
QML_ROOT = ROOT / "src" / "pyside_nova" / "qml" / "Nova"

# ── 契约表（唯一事实源）──────────────────────────────────────────────
# 字段：layer -> {类型名: (分类, 期望角色, 名称来源说明)}
#   分类：interactive / semantic / decorative
#   角色：Accessible.<Role> 中的 Role 名；分类为 decorative 时写 "-"
INTERACTIVE, SEMANTIC, DECORATIVE = "interactive", "semantic", "decorative"

CONTROLS: dict[str, tuple[str, str, str]] = {
    # ── 动作类 ────────────────────────────────────────────────────
    "NovaBtn":            (INTERACTIVE, "Button", "a11yLabel → text"),
    "NovaBtnToggle":      (INTERACTIVE, "RadioButton", "a11yLabel → text"),
    "NovaBtnDropdown":    (INTERACTIVE, "ButtonDropDown", "a11yLabel → label"),
    "NovaBtnGroup":       (SEMANTIC, "Grouping", "a11yLabel（可选）"),
    "NovaFab":            (INTERACTIVE, "Button", "a11yLabel → icon 语义键"),
    "NovaFabAction":      (INTERACTIVE, "Button", "a11yLabel → label"),
    "NovaChip":           (INTERACTIVE, "Button/StaticText", "a11yLabel → label（可点/可删时 Button）"),
    "NovaItem":           (INTERACTIVE, "Button/ListItem", "a11yLabel → label"),
    "NovaSlideItem":      (INTERACTIVE, "Grouping", "a11yLabel（可选）"),
    "NovaBreadcrumbsEl":  (INTERACTIVE, "Link", "a11yLabel → label"),
    "NovaStepperNavigation": (SEMANTIC, "Grouping", "a11yLabel（可选）"),
    "NovaCarouselControl": (SEMANTIC, "Grouping", "a11yLabel（定位容器，语义由内部控件承担）"),
    # ── 表单类 ────────────────────────────────────────────────────
    "NovaField":          (SEMANTIC, "Grouping", "label"),
    "NovaInput":          (INTERACTIVE, "EditableText", "label / placeholder / a11yLabel"),
    "NovaEditor":         (INTERACTIVE, "EditableText", "label / a11yLabel"),
    "NovaSelect":         (INTERACTIVE, "ComboBox", "label"),
    "NovaCheckbox":       (INTERACTIVE, "CheckBox", "a11yLabel → label"),
    "NovaToggle":         (INTERACTIVE, "Switch", "a11yLabel → label"),
    "NovaRadio":          (INTERACTIVE, "RadioButton", "a11yLabel → label"),
    "NovaOptionGroup":    (SEMANTIC, "Grouping", "label"),
    "NovaForm":           (SEMANTIC, "Form", "a11yLabel（可选）"),
    "NovaSlider":         (INTERACTIVE, "Slider", "a11yLabel → label"),
    "NovaRange":          (INTERACTIVE, "Slider", "a11yLabel → label"),
    "NovaDate":           (INTERACTIVE, "EditableText", "a11yLabel → title"),
    "NovaTime":           (INTERACTIVE, "EditableText", "a11yLabel → hint"),
    "NovaColorPicker":    (INTERACTIVE, "ColorChooser", "a11yLabel → hint"),
    "NovaPopupEdit":      (INTERACTIVE, "Button", "a11yLabel → label"),
    # ── 数据类 ────────────────────────────────────────────────────
    "NovaTable":          (INTERACTIVE, "Table", "a11yLabel（可选）"),
    "NovaTh":             (INTERACTIVE, "ColumnHeader", "text"),
    "NovaTd":             (DECORATIVE, "-", "单元格内容由所在行的可读名承载"),
    "NovaTr":             (DECORATIVE, "-", "行容器，语义由 NovaTable 承担"),
    "NovaTree":           (INTERACTIVE, "Tree", "a11yLabel（可选）"),
    "NovaList":           (SEMANTIC, "List", "a11yLabel（可选）"),
    "NovaItemLabel":      (DECORATIVE, "-", "文本节点，由父项可读名承载"),
    "NovaItemSection":    (DECORATIVE, "-", "分组容器"),
    "NovaMarkupTable":    (SEMANTIC, "Table", "a11yLabel（可选）"),
    "NovaPagination":     (INTERACTIVE, "Grouping", "a11yLabel"),
    "NovaInfiniteScroll": (DECORATIVE, "-", "滚动容器"),
    "NovaVirtualScroll":  (DECORATIVE, "-", "滚动容器"),
    "NovaScrollArea":     (DECORATIVE, "-", "滚动容器"),
    # ── 导航类 ────────────────────────────────────────────────────
    "NovaTabs":           (INTERACTIVE, "PageTabList", "a11yLabel（可选）"),
    "NovaTab":            (INTERACTIVE, "PageTab", "label"),
    "NovaTabPanel":       (DECORATIVE, "-", "面板容器"),
    "NovaTabPanels":      (DECORATIVE, "-", "面板容器"),
    "NovaBreadcrumbs":    (SEMANTIC, "Grouping", "a11yLabel（可选）"),
    "NovaStepper":        (SEMANTIC, "Grouping", "a11yLabel（可选）"),
    "NovaStep":           (SEMANTIC, "ListItem", "title"),
    "NovaExpansionItem":  (INTERACTIVE, "Button", "label"),
    "NovaToolbar":        (SEMANTIC, "ToolBar", "a11yLabel（可选）"),
    "NovaToolbarTitle":   (SEMANTIC, "Heading", "text"),
    "NovaMenu":           (INTERACTIVE, "PopupMenu", "a11yLabel（可选）"),
    # ── 弹层与反馈 ────────────────────────────────────────────────
    "NovaDialogShell":    (INTERACTIVE, "Dialog", "title"),
    "NovaBottomSheet":    (INTERACTIVE, "Dialog", "title"),
    "NovaTooltip":        (SEMANTIC, "ToolTip", "text"),
    "NovaPopupProxy":     (DECORATIVE, "-", "路由容器，语义由目标弹层承担"),
    "NovaSpinner":        (SEMANTIC, "ProgressBar", "a11yLabel（i18n 后默认「加载中」）"),
    "NovaSkeleton":       (DECORATIVE, "-", "占位骨架，对屏读器无信息量"),
    "NovaInnerLoading":   (SEMANTIC, "ProgressBar", "a11yLabel（i18n 后默认「加载中」）"),
    "NovaAjaxBar":        (SEMANTIC, "ProgressBar", "a11yLabel（i18n 后默认「加载中」）"),
    "NovaBanner":         (SEMANTIC, "Grouping", "a11yLabel（可选）"),
    "NovaBar":            (DECORATIVE, "-", "通用条容器"),
    "NovaNoSsr":          (DECORATIVE, "-", "延迟渲染代理"),
    "NovaPullToRefresh":  (SEMANTIC, "Grouping", "a11yLabel（触摸手势容器：键盘等价路径由内容区刷新按钮承担）"),
    # ── 媒体与基础 ────────────────────────────────────────────────
    "NovaImg":            (SEMANTIC, "Graphic", "alt"),
    "NovaVideo":          (SEMANTIC, "Animation", "title"),
    "NovaCarousel":       (INTERACTIVE, "Grouping", "a11yLabel（可选）"),
    "NovaCarouselSlide":  (DECORATIVE, "-", "轮播页容器"),
    "NovaParallax":       (DECORATIVE, "-", "视差容器"),
    "NovaTimeline":       (DECORATIVE, "-", "时间线容器"),
    "NovaTimelineEntry":  (SEMANTIC, "ListItem", "title"),
    "NovaChatMessage":    (SEMANTIC, "StaticText", "text"),
    "NovaText":           (SEMANTIC, "StaticText", "text"),
    "NovaIcon":           (SEMANTIC, "Graphic", "a11yLabel（装饰图标可空）"),
    "NovaAvatar":         (SEMANTIC, "Graphic", "a11yLabel → text"),
    "NovaBadge":          (SEMANTIC, "StaticText", "a11yLabel → label"),
    "NovaSeparator":      (SEMANTIC, "Separator", "a11yLabel（可选）"),
    "NovaTransition":     (DECORATIVE, "-", "过渡容器"),
    "NovaVisible":        (DECORATIVE, "-", "断点显示代理"),
    "NovaResponsive":     (DECORATIVE, "-", "等比容器"),
    "NovaSpace":          (DECORATIVE, "-", "间距占位"),
    "NovaRow":            (DECORATIVE, "-", "栅格容器"),
    "NovaCol":            (DECORATIVE, "-", "栅格容器"),
    "NovaLayout":         (DECORATIVE, "-", "布局骨架"),
    "NovaHeader":         (DECORATIVE, "-", "布局骨架"),
    "NovaFooter":         (DECORATIVE, "-", "布局骨架"),
    "NovaDrawer":         (DECORATIVE, "-", "布局骨架"),
    "NovaPage":           (DECORATIVE, "-", "布局骨架"),
    "NovaCard":           (DECORATIVE, "-", "卡片容器"),
    "NovaCardSection":    (DECORATIVE, "-", "卡片分区"),
    "NovaCardActions":    (DECORATIVE, "-", "卡片动作区"),
    "NovaResizeObserver": (DECORATIVE, "-", "尺寸观察行为"),
}

# 组合组件专属模块（宪法 0.3.0，从 Controls 迁出）：14 项 Prescient Layout Shell
LAYOUTSHELL: dict[str, tuple[str, str, str]] = {
    "NovaSidebarShell":     (DECORATIVE, "-", "侧边导航工作台骨架，语义由注入槽位承担"),
    "NovaTopNavShell":      (DECORATIVE, "-", "顶部导航工作台骨架"),
    "NovaDualSideShell":    (DECORATIVE, "-", "双侧边三栏工作台骨架"),
    "NovaTabShell":         (DECORATIVE, "-", "标签页工作台骨架"),
    "NovaThreeColumnShell": (DECORATIVE, "-", "三栏工作台骨架"),
    "NovaCompareShell":     (DECORATIVE, "-", "双栏对比骨架"),
    "NovaCardGridShell":    (DECORATIVE, "-", "卡片网格骨架"),
    "NovaModalShell":       (DECORATIVE, "-", "模态弹窗容器骨架，焦点由内部交互件承担"),
    "NovaDrawerPanelShell": (DECORATIVE, "-", "侧滑面板容器骨架"),
    "NovaWizardShell":      (DECORATIVE, "-", "分步向导骨架"),
    "NovaBlankPageShell":   (DECORATIVE, "-", "纯净单页骨架"),
    "NovaDesktop":          (DECORATIVE, "-", "桌面应用顶层根壳"),
    "NovaMobile":           (DECORATIVE, "-", "移动应用顶层根壳"),
    "NovaFlexLayout":       (DECORATIVE, "-", "企业大屏弹性布局根壳"),
}

BEHAVIORS: dict[str, tuple[str, str, str]] = {
    "NovaRipple":         (DECORATIVE, "-", "纯视觉反馈，无信息量"),
    "NovaIntersection":   (DECORATIVE, "-", "观察器行为"),
    "NovaScrollObserver": (DECORATIVE, "-", "观察器行为"),
    "NovaScrollFire":     (DECORATIVE, "-", "滚动触发行为"),
    "NovaClosePopup":     (DECORATIVE, "-", "点击外部关闭行为"),
    "NovaTouchPan":       (DECORATIVE, "-", "指针手势行为"),
    "NovaTouchSwipe":     (DECORATIVE, "-", "指针手势行为"),
    "NovaTouchHold":      (DECORATIVE, "-", "指针手势行为"),
    "NovaTouchRepeat":    (DECORATIVE, "-", "指针手势行为"),
    "NovaMorph":          (DECORATIVE, "-", "形变过渡，宿主语义不变"),
    "NovaMorphPool":      (DECORATIVE, "-", "形变注册表"),
    "NovaFocusRing":      (DECORATIVE, "-", "焦点指示绘制件（自身不承载语义）"),
    "NovaLiveRegion":     (DECORATIVE, "-", "播报通道，语义来自 NovaA11y.notice 文本"),
}

SERVICES: dict[str, tuple[str, str, str]] = {
    # 服务单例是 QtObject（非 Item），挂不了 Accessible.*：命令式 API 的语义由
    # NovaA11y.notice + NovaLiveRegion 在宿主侧播报承担（见 docs/A11Y.md §状态播报）
    name: (DECORATIVE, "-", "QtObject 单例：语义经 NovaA11y.notice 播报")
    for name in ("NovaNotify", "NovaDialog", "NovaLoading", "NovaLoadingBar")
} | {
    name: (DECORATIVE, "-", "无视觉节点（状态/平台/注册表）")
    for name in ("NovaScreen", "NovaTheme", "NovaOverlayHost", "NovaStorage",
                 "NovaApp", "NovaPlatform", "NovaIntersectionPool",
                 "NovaI18n",
                 "NovaNotifyAction", "NovaNotifyHandle", "NovaDialogHandle",
                 "NovaLoadingHandle")
}

DESIGN: dict[str, tuple[str, str, str]] = {
    "NovaIconSet": (DECORATIVE, "-", "图标数据表"),
    "NovaMotion":  (DECORATIVE, "-", "动效令牌"),
    "NovaUtils":   (DECORATIVE, "-", "工具函数"),
    "NovaA11y":    (DECORATIVE, "-", "a11y 基座单例（本身即门禁设施）"),
}

TABLE = {"Controls": CONTROLS, "Behaviors": BEHAVIORS,
         "Services": SERVICES, "Design": DESIGN,
         "Composite/LayoutShell": LAYOUTSHELL}

MARKER = "a11y: decorative"


def parse_qmldir(path: Path) -> list[tuple[str, str, bool]]:
    """返回 [(类型名, 文件名, 是否 singleton)]；跳过 internal 与注释。"""
    out = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("module"):
            continue
        parts = line.split()
        if parts[0] == "internal":
            continue
        singleton = parts[0] == "singleton"
        if singleton:
            parts = parts[1:]
        if len(parts) < 3:
            continue
        out.append((parts[0], parts[2], singleton))
    return out


ROOT_TYPE_RE = re.compile(r"^([A-Z][A-Za-z0-9_.]*)\s*\{", re.MULTILINE)


def root_type(text: str) -> str:
    """首个顶层类型声明（跳过 import / 注释）；用于识别「继承自 Nova 组件」的键盘契约。"""
    for m in ROOT_TYPE_RE.finditer(text):
        name = m.group(1)
        if name not in ("Component",):
            return name
    return ""


def scan() -> tuple[list[dict], list[str]]:
    """静态扫描：返回 (行数据, 违规列表)。"""
    rows: list[dict] = []
    errors: list[str] = []
    seen: set[str] = set()

    for layer, table in TABLE.items():
        qmldir = QML_ROOT / layer / "qmldir"
        if not qmldir.exists():
            errors.append(f"缺少 qmldir：{qmldir}")
            continue
        for type_name, file_name, _singleton in parse_qmldir(qmldir):
            seen.add(type_name)
            expect = table.get(type_name)
            if expect is None:
                errors.append(f"[{layer}] {type_name} 未在契约表登记（新增类型必须补分类）")
                continue
            kind, role, name_src = expect
            qml_path = QML_ROOT / layer / file_name
            text = qml_path.read_text(encoding="utf-8") if qml_path.exists() else ""
            has_role = "Accessible.role" in text
            has_name = "Accessible.name" in text
            has_tab = "activeFocusOnTab" in text
            has_keys = "Keys.on" in text
            # 继承式契约：根类型是 Nova 组件（如 NovaToggle → NovaCheckbox），键盘路径由基类提供
            base = root_type(text)
            inherits_nova = base.startswith("Nova") and base != type_name
            has_ring = "NovaFocusRing" in text
            marked = MARKER in text

            ok = True
            if kind == INTERACTIVE:
                if not has_role:
                    errors.append(f"[{layer}] {type_name}（interactive）缺 Accessible.role")
                    ok = False
                if not has_name:
                    errors.append(f"[{layer}] {type_name}（interactive）缺 Accessible.name")
                    ok = False
                if not (has_tab or inherits_nova):
                    errors.append(f"[{layer}] {type_name}（interactive）缺键盘入口 activeFocusOnTab")
                    ok = False
                if not (has_keys or inherits_nova):
                    errors.append(f"[{layer}] {type_name}（interactive）缺按键路径 Keys.on*")
                    ok = False
                if not has_ring:
                    errors.append(f"[{layer}] {type_name}（interactive）缺 NovaFocusRing")
                    ok = False
            elif kind == SEMANTIC:
                if not has_role:
                    errors.append(f"[{layer}] {type_name}（semantic）缺 Accessible.role")
                    ok = False
                if not has_name:
                    errors.append(f"[{layer}] {type_name}（semantic）缺 Accessible.name")
                    ok = False
            else:  # decorative
                if has_role or has_name:
                    errors.append(f"[{layer}] {type_name}（decorative）不应挂 Accessible.*，请改分类或删除")
                    ok = False
                if not marked:
                    errors.append(f"[{layer}] {type_name}（decorative）缺 `{MARKER}` 标记注释")
                    ok = False

            rows.append({
                "layer": layer, "type": type_name, "file": file_name, "kind": kind,
                "role": role, "name": name_src, "ok": ok,
                "tab": has_tab or inherits_nova, "keys": has_keys or inherits_nova,
                "ring": has_ring, "inherit": inherits_nova,
            })

    for layer, table in TABLE.items():
        for type_name in table:
            if type_name not in seen:
                errors.append(f"[{layer}] 契约表登记了不存在的类型：{type_name}")
    return rows, errors


def render_matrix(rows: list[dict]) -> str:
    icons = {True: "✅", False: "❌"}
    out = [
        "# 可访问性矩阵 — A11Y_MATRIX",
        "",
        "> 本文件由 `python scripts/check_a11y.py --matrix docs/A11Y_MATRIX.md` 生成，**勿手改**。",
        "> 契约分类与门禁规则见 [A11Y.md](A11Y.md)；分类是审计结论：interactive=可操作控件，",
        "> semantic=只读语义元素，decorative=布局/装饰（**故意不挂** Accessible，避免屏读器噪声）。",
        "",
        f"总计 {len(rows)} 个导出类型："
        f"interactive {sum(1 for r in rows if r['kind'] == INTERACTIVE)} · "
        f"semantic {sum(1 for r in rows if r['kind'] == SEMANTIC)} · "
        f"decorative {sum(1 for r in rows if r['kind'] == DECORATIVE)}",
        "",
        "| 层 | 类型 | 分类 | Accessible.role | 可读名来源 | 键盘入口 | 按键路径 | 焦点环 | 门禁 |",
        "|---|---|---|---|---|---|---|---|---|",
    ]
    for r in rows:
        out.append(
            f"| {r['layer']} | `{r['type']}` | {r['kind']} | {r['role']} | {r['name']} | "
            f"{icons[r['tab']]} | {icons[r['keys']]} | {icons[r['ring']]} | {icons[r['ok']]} |"
        )
    out.append("")
    return "\n".join(out)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="pyside-nova 可访问性门禁")
    ap.add_argument("--matrix", metavar="PATH", help="生成矩阵文档到指定路径")
    ap.add_argument("--quiet", action="store_true", help="只输出结论")
    args = ap.parse_args(argv)

    rows, errors = scan()

    if args.matrix:
        target = Path(args.matrix)
        if not target.is_absolute():
            target = ROOT / target
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(render_matrix(rows), encoding="utf-8")
        if not args.quiet:
            print(f"矩阵已写入 {target}")

    total = len(rows)
    ok_count = sum(1 for r in rows if r["ok"])
    if errors:
        print(f"\n可访问性门禁未通过：{len(errors)} 项缺口（{ok_count}/{total} 类型合规）")
        for e in errors:
            print("  ✗ " + e)
        return 1
    print(f"可访问性门禁通过：{total}/{total} 类型合规"
          f"（interactive {sum(1 for r in rows if r['kind'] == INTERACTIVE)} · "
          f"semantic {sum(1 for r in rows if r['kind'] == SEMANTIC)} · "
          f"decorative {sum(1 for r in rows if r['kind'] == DECORATIVE)}）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
