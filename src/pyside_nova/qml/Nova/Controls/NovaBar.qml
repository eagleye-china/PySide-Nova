// src/pyside_nova/qml/Nova/Controls/NovaBar.qml
// NovaBar 顶栏：default 槽、dense、tint 默认主色（对标 QBar —— 默认背景 $primary、文字反转）
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Rectangle {
    id: root

    default property alias content: bodySlot.data

    // ── 形态 ──────────────────────────────────────────────────
    property bool dense: false
    property color tint: NovaTheme.primary

    color: tint
    implicitWidth: 400
    final property real _baseH: dense ? 24 : 32
    width: implicitWidth
    height: Math.max(_baseH, bodyRow.implicitHeight + 8)

    // 文字自动反转：primary 系底色上用 textOnPrimary
    readonly property color fg: tint === NovaTheme.primary ? NovaTheme.textOnPrimary : NovaTheme.textColor

    Row {
        id: bodyRow
        x: NovaTheme.spacingM
        y: (root.height - height) / 2
        width: Math.max(0, root.width - 2 * NovaTheme.spacingM)
        spacing: NovaTheme.spacingM

        Item {
            id: bodySlot
            width: childrenRect.width
            height: childrenRect.height
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
