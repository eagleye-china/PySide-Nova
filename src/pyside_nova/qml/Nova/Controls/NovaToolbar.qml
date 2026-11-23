// src/pyside_nova/qml/Nova/Controls/NovaToolbar.qml
// NovaToolbar 工具栏（对标 QToolbar）：水平排布行、min-height 50、inset 内容缩进；
// 默认槽为工具栏内容（常配 NovaToolbarTitle / NovaBtn / NovaChip）
import QtQuick
import Nova.Services

Rectangle {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.ToolBar
    Accessible.name: a11yLabel

    // ── 默认槽：工具栏内容 ──────────────────────────────────
    default property alias content: row.data

    // inset：内容缩进（对标 inset，适用于叠放的第二层工具栏）
    property bool inset: false

    color: NovaTheme.surface
    implicitWidth: 400
    implicitHeight: 50   // Quasar $toolbar-min-height 1:1

    Row {
        id: row
        x: (root.inset ? 58 : NovaTheme.spacingM)
        y: (root.height - height) / 2
        width: parent.width - x - NovaTheme.spacingM
        spacing: NovaTheme.spacingM
    }
}
