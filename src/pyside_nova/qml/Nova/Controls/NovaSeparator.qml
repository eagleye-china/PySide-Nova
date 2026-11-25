// src/pyside_nova/qml/Nova/Controls/NovaSeparator.qml
// NovaSeparator 分隔线：vertical 属性切换方向，颜色取 outline 令牌（对标 QSeparator）
// NovaSeparator —— 分隔线（对标 QSeparator）
// horizontal（默认）或 vertical；spaced 在两端留出呼吸空隙
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.Separator
    Accessible.name: a11yLabel

    property bool vertical: false
    property bool spaced: false
    property real size: 1
    property color color: NovaTheme.outline

    // CARF 基础组件 Robustness：size 非法入参钳制，分隔线厚度恒非负。
    readonly property real _size: Math.max(0, root.size)

    implicitWidth: vertical ? root._size : 8
    implicitHeight: vertical ? 8 : root._size

    Rectangle {
        anchors.centerIn: parent
        width: root.vertical ? root._size
                             : Math.max(0, root.width - (root.spaced ? NovaTheme.spacingL : 0))
        height: root.vertical ? Math.max(0, root.height - (root.spaced ? NovaTheme.spacingL : 0))
                              : root._size
        color: root.color
    }
}
