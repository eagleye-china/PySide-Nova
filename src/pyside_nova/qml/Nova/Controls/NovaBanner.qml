// src/pyside_nova/qml/Nova/Controls/NovaBanner.qml
// NovaBanner 横幅：default/avatar/action 三槽、inline-actions 同行、dense、rounded（对标 QBanner）
import QtQuick
import Nova.Controls
import Nova.Services

Rectangle {
    id: root

    default property alias content: bodySlot.data
    property alias avatar: avatarSlot.data
    property alias action: actionSlot.data

    // ── 形态 ──────────────────────────────────────────────────
    property bool inlineActions: false           // 动作与内容同行
    property bool dense: false
    property bool rounded: false
    property color tint: NovaTheme.surfaceAlt

    radius: rounded ? NovaTheme.radiusS : 0
    implicitWidth: 400
    final property real _baseH: dense ? 40 : 64
    width: implicitWidth
    height: Math.max(_baseH, row.implicitHeight + (dense ? 8 : 16))

    Row {
        id: row
        x: NovaTheme.spacingL
        y: (root.height - height) / 2
        width: Math.max(0, root.width - 2 * NovaTheme.spacingL)
        spacing: NovaTheme.spacingM

        Item {
            id: avatarSlot
            width: childrenRect.width
            height: childrenRect.height
            anchors.verticalCenter: parent.verticalCenter
            visible: children.length > 0
        }

        Column {
            id: bodySlot
            width: inlineActions ? (parent.width - avatarSlot.width - actionSlot.width - 2 * NovaTheme.spacingM)
                                 : (parent.width - avatarSlot.width - NovaTheme.spacingM)
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter
            height: childrenRect.height
        }

        Row {
            id: actionSlot
            visible: children.length > 0
            spacing: NovaTheme.spacingS
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
