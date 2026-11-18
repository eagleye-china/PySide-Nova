pragma Singleton
import QtQuick

QtObject {
    // 🌟 修正为 Quasar 标准色板
    property color primary: "#1976D2"    // 标准蓝 (原 #2196F3 太亮)
    property color secondary: "#26A69A"  // 蓝绿 (Quasar 的 Primary 替代)
    property color positive: "#21BA45"
    property color negative: "#C10015"
    property color warning: "#F2C037"
    property color info: "#31CCEC"
    property color dark: "#1D1D1D"
    property color white: "#FFFFFF"
    property color teal: "#26A69A"       // 🌟 新增 teal
    property color grey9: "#424242"      // 🌟 新增 grey-9
    property color background: "#121212"
    property color surface: "#1E1E1E"
    property color text_primary: "#E0E0E0"
    property color text_secondary: "#757575"
    property color border: "#333333"
    property color disabled: "#BDBDBD"

    property int radiusSm: 4
    property int radiusMd: 8
    property int radiusLg: 12
    property int radiusPill: 100
    property int radiusNone: 0
    property int durationFast: 150

    function colorOf(name) {
        if (name === "primary") return primary;
        if (name === "secondary") return secondary;
        if (name === "positive") return positive;
        if (name === "negative") return negative;
        if (name === "warning") return warning;
        if (name === "info") return info;
        if (name === "dark") return dark;
        if (name === "white") return white;
        return primary;
    }
}
