// src/pyside_nova/qml/Nova/Controls/NovaInnerLoading.qml
// NovaInnerLoading 局部加载遮罩：半透明蒙层 + Spinner（或 default 槽替换）+ label（对标 QInnerLoading）
// 用法：anchors.fill: parent 覆盖宿主区域；default 槽非空时替换 Spinner（如自定义动画）
import QtQuick
import Nova.Controls
import Nova.Services

Rectangle {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.ProgressBar
    Accessible.name: a11yLabel !== "" ? a11yLabel : label

    // ── 内容 ──────────────────────────────────────────────────
    default property alias content: slotBox.data
    property string label: ""                    // default 槽非空时被覆盖（对标 label prop）

    // ── 状态与形态 ────────────────────────────────────────────
    property bool showing: false                 // loading 态
    property real size: 42                       // spinner 直径
    property color tint: NovaTheme.primary
    property string spinnerVariant: "ring"
    property bool dark: false                    // 深底蒙层口径（宿主自选）

    color: dark ? Qt.rgba(0, 0, 0, 0.55) : Qt.rgba(1, 1, 1, 0.7)

    opacity: showing ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    readonly property bool _hasSlot: slotBox.children.length > 0

    Column {
        anchors.centerIn: parent
        spacing: NovaTheme.spacingM

        // default 槽（非空时替换 Spinner）
        Item {
            id: slotBox
            visible: root._hasSlot
            width: childrenRect.width
            height: childrenRect.height
            anchors.horizontalCenter: parent.horizontalCenter
        }

        NovaSpinner {
            visible: !root._hasSlot
            anchors.horizontalCenter: parent.horizontalCenter
            variant: root.spinnerVariant
            size: root.size
            tint: root.tint
        }

        Text {
            visible: root.label !== "" && !root._hasSlot
            text: root.label
            color: root.dark ? "#FFFFFF" : NovaTheme.textColor
            font.pixelSize: NovaTheme.fontS
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
