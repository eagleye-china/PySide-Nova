// src/pyside_nova/qml/Nova/Services/NovaTheme.qml
// NovaTheme 设计令牌单例：三级令牌体系、明暗双主题一键切换、运行时品牌换肤、0~5 级阴影（对标 Quasar brand + Dark 插件）
// NovaTheme —— 全局设计令牌单例（对标 Quasar brand 变量 + Dark 插件）
// 三级令牌体系的第一层：品牌色 / 语义色 / 表面色 / 几何 / 字阶 / 阴影
pragma Singleton
import QtQuick

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
    readonly property color textMuted: isDark ? "#9DA0AB" : "#6E7380"

    // 水波纹默认色（明暗自适应）
    readonly property color ripple: isDark ? Qt.rgba(1, 1, 1, 0.22)
                                         : Qt.rgba(0, 0, 0, 0.14)

    // ── 图标资源 ──────────────────────────────────────────────
    // 本地图标包根目录（file:///…/icons），由 scripts/fetch_icons.py 产出；
    // 为空则 NovaIcon 走云端 CDN，本地缺失仍会自动回落云端
    property url iconLocalRoot: ""

    // ── 几何令牌 ──────────────────────────────────────────────
    readonly property int spacingS: 6
    readonly property int spacingM: 12
    readonly property int spacingL: 24
    readonly property int radiusS: 6
    readonly property int radiusM: 10
    readonly property int radiusL: 14

    // ── 字体令牌 ──────────────────────────────────────────────
    property string fontFamily: "Segoe UI"
    readonly property int fontXS: 11
    readonly property int fontS: 13
    readonly property int fontM: 15
    readonly property int fontL: 18
    readonly property int fontXL: 24

    // ── 阴影令牌：0~5 级高程 → 阴影色 ───────────────────────────
    function shadowColor(level) {
        var l = Math.min(Math.max(Math.floor(level), 0), 5)
        var light = [0, 0.06, 0.10, 0.14, 0.18, 0.22]
        var darkA = [0, 0.18, 0.26, 0.34, 0.42, 0.50]
        var a = theme.isDark ? darkA[l] : light[l]
        return Qt.rgba(0, 0, 0, a)
    }
}
