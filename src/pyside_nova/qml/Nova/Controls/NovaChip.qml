// src/pyside_nova/qml/Nova/Controls/NovaChip.qml
// NovaChip 标签：filled/outlined/tinted、可选中、可移除、dense（对标 QChip）
// NovaChip —— 标签/片（对标 QChip）
// tint 为基调色（对应 QChip 的 color 属性；QML 中 color 与基类属性冲突故命名 tint）
// filled / outlined / tinted 三形态，支持图标、可选中、可移除
import QtQuick
import Nova.Services

Rectangle {
    id: root

    // ── 槽机制（对标 QChip 默认槽）────────────────────────────
    // 默认子项挂载到标签覆盖层，可在标签之上叠加自定义内容
    default property alias content: extraHost.data

    // ── 内容 ──
    property string text: ""
    property string icon: ""

    // ── 外观 ──
    property bool filled: false
    property bool outlined: false
    property bool dense: false
    property bool selected: false
    property color tint: NovaTheme.primary

    // ── 状态 ──
    property bool clickable: false
    property bool removable: false
    property bool disable: false

    // ── 事件 ──
    signal clicked()
    signal removed()

    readonly property real _h: dense ? 26 : 34
    readonly property color _fg: filled ? "#FFFFFF" : tint

    implicitHeight: _h
    implicitWidth: content.implicitWidth + (dense ? 16 : 22)
    radius: _h / 2
    color: {
        if (outlined)
            return "transparent"
        if (filled)
            return selected ? Qt.darker(tint, 1.10) : tint
        return Qt.rgba(tint.r, tint.g, tint.b, selected ? 0.22 : 0.12)
    }
    border.width: outlined ? 1.2 : 0
    border.color: tint

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            text: root.icon
            color: root._fg
            font.pixelSize: root.dense ? 13 : 15
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            text: root.text
            color: root._fg
            font.family: NovaTheme.fontFamily
            font.pixelSize: root.dense ? 12 : 13
            font.weight: Font.Medium
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.removable
            text: "✕"
            color: root._fg
            font.pixelSize: 11
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                enabled: !root.disable
                cursorShape: Qt.PointingHandCursor
                onClicked: root.removed()
            }
        }
    }

    // 默认槽宿主：覆盖层，几何与标签一致
    Item { id: extraHost; anchors.fill: parent }

    MouseArea {
        anchors.fill: parent
        enabled: root.clickable && !root.disable
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
