// src/pyside_nova/qml/Nova/Controls/NovaSeparator.qml
// NovaSeparator 分隔线：vertical 属性切换方向，颜色取 outline 令牌（对标 QSeparator）
// NovaSeparator —— 分隔线（对标 QSeparator）
// horizontal（默认）或 vertical；spaced 在两端留出呼吸空隙
import QtQuick
import Nova.Services

Item {
    id: root

    property bool vertical: false
    property bool spaced: false
    property real size: 1
    property color color: NovaTheme.outline

    implicitWidth: vertical ? root.size : 8
    implicitHeight: vertical ? 8 : root.size

    Rectangle {
        anchors.centerIn: parent
        width: root.vertical ? root.size
                             : Math.max(0, root.width - (root.spaced ? NovaTheme.spacingL : 0))
        height: root.vertical ? Math.max(0, root.height - (root.spaced ? NovaTheme.spacingL : 0))
                              : root.size
        color: root.color
    }
}
