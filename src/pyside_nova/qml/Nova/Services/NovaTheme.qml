// src/pyside_nova/qml/Nova/Services/NovaTheme.qml
// NovaTheme 设计令牌单例：三级令牌体系、明暗双主题一键切换、运行时品牌换肤、0~5 级阴影（对标 Quasar brand + Dark 插件）
// NovaTheme —— 全局设计令牌单例（对标 Quasar brand 变量 + Dark 插件）
// 三级令牌体系的第一层：品牌色 / 语义色 / 表面色 / 几何 / 字阶 / 阴影
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma Singleton
import QtQuick
import Nova.Design
import Nova.Services

QtObject {
    id: theme

    // ── 主题模式（对标 Quasar Dark 插件） ────────────────────────
    // isDark 对标 $q.dark.isActive；dark 品牌色 1:1 对标 Quasar $dark（0.3.0 起修复命名冲突）
    property bool isDark: false
    function toggleDark() { theme.isDark = !theme.isDark }
    function setDark(value) { theme.isDark = value }   // 对标 $q.dark.set()

    // ── 品牌色（可运行时定制，用于企业换肤） ─────────────────────
    // 1:1 对标 Quasar 8 大品牌变量：primary / secondary / accent / dark / positive / negative / info / warning
    property color primary: "#5B6EF5"
    property color secondary: "#26A69A"
    property color accent: "#FF7043"
    property color dark: "#1D1D1D"   // Quasar $dark 品牌色 1:1

    function setBrand(primaryColor) {
        if (primaryColor !== undefined)
            theme.primary = primaryColor
    }

    // ── 语义色 ────────────────────────────────────────────────
    readonly property color textOnPrimary: "#FFFFFF"
    readonly property color positive: "#22C55E"
    readonly property color negative: "#EF4444"
    readonly property color warning: "#F59E0B"
    readonly property color info: "#38BDF8"

    // ── 表面色（随 dark 自动切换） ──────────────────────────────
    readonly property color page: isDark ? "#121216" : "#F2F4F7"
    readonly property color surface: isDark ? "#1C1C21" : "#FFFFFF"
    readonly property color surfaceAlt: isDark ? "#25252C" : "#F7F8FA"
    readonly property color outline: isDark ? "#38383F" : "#E3E5EB"
    readonly property color textColor: isDark ? "#E9EAEF" : "#1F2128"
    // 次要文本：AA 兜底派生（0.16.0）——原 #6E7380 在 page 上仅 4.31:1，压到 4.50 后肉眼无差
    readonly property color textMuted: NovaA11y.aaText(isDark ? "#9DA0AB" : "#6E7380", a11yBase)

    // ══════════════════════════════════════════════════════════
    // 可访问性令牌（WCAG 2.1 AA · 0.16.0 新颁）
    // ══════════════════════════════════════════════════════════
    // a11yBase：三种表面中「对比度最不利」的一块，所有 AA 派生都以它为基准，
    // 保证同一前景色在 page/surface/surfaceAlt 上都过 4.5:1（明暗各取最严者）
    readonly property color a11yBase: {
        var cands = [page, surface, surfaceAlt]
        var worst = page, low = Number.MAX_VALUE
        for (var i = 0; i < cands.length; ++i) {
            var r = NovaA11y.contrast(textColor, cands[i])
            if (r < low) { low = r; worst = cands[i] }
        }
        return worst
    }
    // 焦点环（1.4.11 非文本对比 ≥3:1）：外扩 2px 绘制，间隙露出表面色，填充态按钮上也可见
    readonly property color focusRing: isDark ? Qt.lighter(primary, 1.25) : primary
    readonly property int focusRingWidth: 2
    readonly property int focusRingOffset: 2
    // 控件边界（1.4.11）：输入框/可交互容器轮廓，AA 兜底到 3:1；装饰性分隔线仍用 outline
    readonly property color outlineStrong: NovaA11y.aaText(outline, a11yBase, NovaA11y.uiComponentRatio)

    // 语义色作为「文字/图标」时的 AA 兜底版（品牌本色仍用于填充面与大色块）
    readonly property color primaryText: NovaA11y.aaText(primary, a11yBase)
    readonly property color secondaryText: NovaA11y.aaText(secondary, a11yBase)
    readonly property color accentText: NovaA11y.aaText(accent, a11yBase)
    readonly property color positiveText: NovaA11y.aaText(positive, a11yBase)
    readonly property color negativeText: NovaA11y.aaText(negative, a11yBase)
    readonly property color warningText: NovaA11y.aaText(warning, a11yBase)
    readonly property color infoText: NovaA11y.aaText(info, a11yBase)
    // 填充面兜底：底色上压 textOnPrimary 时把底色压到 4.5:1（保品牌色相，不翻黑字）
    function fillTint(color) {
        return NovaA11y.aaFill(color, textOnPrimary)
    }

    // 水波纹默认色（明暗自适应）
    readonly property color ripple: isDark ? Qt.rgba(1, 1, 1, 0.22)
                                         : Qt.rgba(0, 0, 0, 0.14)

    // ── 图标资源 ──────────────────────────────────────────────
    // 本地图标包根目录（file:///…/icons），由 scripts/fetch_icons.py 产出；
    // 为空则 NovaIcon 走云端 CDN，本地缺失仍会自动回落云端
    property url iconLocalRoot: ""

    // ── 层叠令牌（0.6.0 起入册，对标 Quasar $z-* 变量，数值 1:1） ──
    // 组件禁止魔法 z 值：弹层/抽屉/悬浮等一律取本组令牌（NovaOverlayHost.attach 默认层为 zNotify）
    readonly property int zFab: 990
    readonly property int zSide: 1000
    readonly property int zMarginals: 2000
    readonly property int zFixedDrawer: 3000
    readonly property int zFullscreen: 6000
    readonly property int zMenu: 6000
    readonly property int zTop: 7000
    readonly property int zTooltip: 9000
    readonly property int zNotify: 9500
    readonly property int zMax: 9998

    // ── 几何令牌 ──────────────────────────────────────────────
    readonly property int spacingS: 6
    readonly property int spacingM: 12
    readonly property int spacingL: 24
    readonly property int radiusS: 6
    readonly property int radiusM: 10
    readonly property int radiusL: 14

    // ── 方向令牌（0.16.1 新颁 · RTL 镜像） ──────────────────────
    // 事实源在 NovaI18n（isRtl/direction）；主题层派生只读别名，供组件统一取用。
    // 方向性组件一律 LayoutMirroring.enabled: NovaTheme.isRtl，禁止手写翻转分支。
    readonly property bool isRtl: NovaI18n.isRtl
    readonly property string direction: NovaI18n.direction

    // ── 字体令牌 ──────────────────────────────────────────────
    property string fontFamily: "Segoe UI"
    readonly property int fontXS: 11
    readonly property int fontS: 13
    readonly property int fontM: 15
    readonly property int fontL: 18
    readonly property int fontXL: 24

    // ── 排版令牌（12 级，1:1 对标 $headings map；rem×16 换算 px）──
    // size / lineHeight 单位 px；letterSpacing 单位 px（= em 值 × size）；weight 为 Font 枚举
    // 基线：h1 6rem/6rem/-.01562em/300 … caption .75rem/1.25rem/.03333em/400
    readonly property var typeScale: ({
        "h1":        { size: 96, lineHeight: 96, letterSpacing: -1.5,  weight: Font.Light },
        "h2":        { size: 60, lineHeight: 60, letterSpacing: -0.5,  weight: Font.Light },
        "h3":        { size: 48, lineHeight: 50, letterSpacing: 0,     weight: Font.Normal },
        "h4":        { size: 34, lineHeight: 40, letterSpacing: 0.25,  weight: Font.Normal },
        "h5":        { size: 24, lineHeight: 32, letterSpacing: 0,     weight: Font.Normal },
        "h6":        { size: 20, lineHeight: 32, letterSpacing: 0.25,  weight: Font.Medium },
        "subtitle1": { size: 16, lineHeight: 28, letterSpacing: 0.15,  weight: Font.Normal },
        "subtitle2": { size: 14, lineHeight: 22, letterSpacing: 0.1,   weight: Font.Medium },
        "body1":     { size: 16, lineHeight: 24, letterSpacing: 0.5,   weight: Font.Normal },
        "body2":     { size: 14, lineHeight: 20, letterSpacing: 0.25,  weight: Font.Normal },
        "overline":  { size: 12, lineHeight: 32, letterSpacing: 2,     weight: Font.Medium },
        "caption":   { size: 12, lineHeight: 20, letterSpacing: 0.4,   weight: Font.Normal }
    })

    // 基线 body：font-size 14px / line-height 1.5
    readonly property int bodyFontSize: 14
    readonly property real bodyLineHeight: 1.5

    readonly property var typeNames: ["h1", "h2", "h3", "h4", "h5", "h6",
                                      "subtitle1", "subtitle2", "body1", "body2",
                                      "overline", "caption"]

    // 取排版样式，未知名回落 body2（不抛错，避免绑定中断）
    function textStyle(name) {
        var s = theme.typeScale[name]
        return s !== undefined ? s : theme.typeScale["body2"]
    }

    // 字重令牌（1:1 对标 $text-weights：thin100/light300/regular400/medium500/bold700/bolder900）
    readonly property int weightThin: Font.Thin
    readonly property int weightLight: Font.Light
    readonly property int weightRegular: Font.Normal
    readonly property int weightMedium: Font.Medium
    readonly property int weightBold: Font.Bold
    readonly property int weightBolder: Font.Black

    // ── 阴影令牌：0~5 级高程 → 阴影色 ───────────────────────────
    function shadowColor(level) {
        var l = Math.min(Math.max(Math.floor(level), 0), 5)
        var light = [0, 0.06, 0.10, 0.14, 0.18, 0.22]
        var darkA = [0, 0.18, 0.26, 0.34, 0.42, 0.50]
        var a = theme.isDark ? darkA[l] : light[l]
        return Qt.rgba(0, 0, 0, a)
    }

    // ── 高程令牌（0~24，1:1 对标 $shadow-* 三层 umbra/penumbra/ambient）──
    // QML 无多层 box-shadow：数值保留供 MultiEffect 组合（blur/offset/alpha 三档）
    readonly property var elevation: ({
        0:  [],
        1:  [[0, 1, 3], [0, 1, 1], [0, 2, 1]],
        2:  [[0, 1, 5], [0, 2, 2], [0, 3, 1]],
        3:  [[0, 1, 8], [0, 3, 4], [0, 3, 3]],
        4:  [[0, 2, 4], [0, 4, 5], [0, 1, 10]],
        5:  [[0, 3, 5], [0, 5, 8], [0, 1, 14]],
        6:  [[0, 3, 5], [0, 6, 10], [0, 1, 18]],
        8:  [[0, 5, 5], [0, 8, 10], [0, 3, 14]],
        10: [[0, 6, 6], [0, 10, 14], [0, 4, 18]],
        12: [[0, 7, 8], [0, 12, 17], [0, 5, 22]],
        16: [[0, 8, 10], [0, 16, 24], [0, 6, 30]],
        24: [[0, 11, 15], [0, 24, 38], [0, 9, 46]]
    })

    // 取最近可用的高程层（如 7 → 6，9 → 8）
    function elevationLayers(level) {
        var lv = Math.min(Math.max(Math.floor(level), 0), 24)
        while (lv > 0 && theme.elevation[lv] === undefined)
            --lv
        return theme.elevation[lv]
    }
}
