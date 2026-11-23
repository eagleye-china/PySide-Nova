// src/pyside_nova/qml/Nova/Controls/NovaBadge.qml
// NovaBadge 徽标：红点（text 留空）/数值/浮动三种模式，作为子项挂载到任意 Item（对标 QBadge）
// NovaBadge —— 徽标（对标 QBadge）
// 用法：作为子项放在任意 Item 内，自动吸附到父级右上角；text 为空 = 红点模式
//     NovaAvatar {
//         text: "M"
//         NovaBadge { text: "3" }
//     }
// 说明：纯 QML 不支持自定义 attached property（需 C++/Python 注册），
// attach 语法规划在 M1 通过 PySide6 QML_ATTACHED 补齐，保持同名属性 API。
import QtQuick
import Nova.Services

Rectangle {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.StaticText
    Accessible.name: a11yLabel !== "" ? a11yLabel : text

    // ── 槽机制（对标 QBadge 默认槽）───────────────────────────
    default property alias content: extraHost.data

    property string text: ""
    property color tint: NovaTheme.negative
    property color textColor: "#FFFFFF"
    property real offsetX: 0
    property real offsetY: 0
    property bool floating: false

    readonly property bool dot: text === ""

    width: dot ? 10 : Math.max(label.width + 12, 22)
    height: dot ? 10 : 22
    radius: height / 2
    color: tint
    border.width: floating ? 2 : 0
    border.color: NovaTheme.surface
    z: 2

    anchors.right: parent ? parent.right : undefined
    anchors.top: parent ? parent.top : undefined
    anchors.rightMargin: -width / 2 + offsetX
    anchors.topMargin: -height / 2 + offsetY

    Text {
        id: label
        anchors.centerIn: parent
        visible: !root.dot
        text: root.text
        color: root.textColor
        font.family: NovaTheme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    // 默认槽宿主：徽标内容覆盖层
    Item { id: extraHost; anchors.fill: parent }
}
