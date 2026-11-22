// src/pyside_nova/qml/Nova/Controls/NovaToolbarTitle.qml
// NovaToolbarTitle 工具栏标题（对标 QToolbarTitle）：默认占满剩余宽度（shrink 反转收缩为内容宽）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 默认槽：标题内容（未放置内容时使用便捷 text） ─────────
    default property alias content: body.data

    // shrink：反转"撑满剩余空间"的默认行为，收缩为内容宽（对标 shrink）
    property bool shrink: false

    property string text: ""          // 便捷文案（未用默认槽时渲染）

    implicitWidth: shrink ? body.implicitWidth + 2 : 200
    implicitHeight: Math.max(24, body.implicitHeight)

    Row {
        id: body
        anchors.verticalCenter: parent.verticalCenter
        spacing: NovaTheme.spacingS

        Text {
            visible: root.text !== "" && body.children.length === 1
            text: root.text
            color: NovaTheme.textColor
            font.pixelSize: NovaTheme.fontL
            font.weight: Font.Medium
            elide: Text.ElideRight
            width: root.shrink ? implicitWidth : parent.width
            maximumLineCount: 1
        }
    }
}
