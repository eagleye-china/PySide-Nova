// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaModalShell.qml
// NovaModalShell 模态弹窗壳：遮罩 + 标题栏 + 内容槽 + 按钮栏，ESC 与点遮罩关闭、圆角阴影（对标 Quasar QDialog）
// NovaModalShell —— 全库通用模态弹窗组合根容器
// 用法：向 titleSlot/contentSlot/actionsSlot 注入业务内容；open/dismiss 受控，Shell 只 emit 关闭意图
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    property alias titleSlot: _title.data
    property alias contentSlot: _body.content
    property alias actionsSlot: _actions.data

    property bool open: false
    property bool dismissOnMask: true
    property bool showTitle: true
    property bool showActions: true
    property real maxWidth: 520
    property real maxHeight: 620
    property int titleHeight: 52
    property int actionsHeight: 56

    signal closeRequested(string reason)   // "escape" | "mask" | "button"

    function requestClose(reason) { root.closeRequested(reason) }

    visible: root.open
    anchors.fill: parent
    z: NovaTheme.zFullscreen

    Rectangle {
        id: _mask
        anchors.fill: parent
        color: NovaTheme.shadowColor(2)
        opacity: 0.55
        MouseArea {
            anchors.fill: parent
            enabled: root.dismissOnMask
            onClicked: root.requestClose("mask")
        }
    }

    Rectangle {
        id: _card
        width: Math.max(280, Math.min(root.maxWidth, parent.width - NovaTheme.spacingL * 2))
        height: Math.min(root.maxHeight,
                         (root.showTitle ? root.titleHeight : 0)
                         + _body.implicitHeight + NovaTheme.spacingL * 2
                         + (root.showActions ? root.actionsHeight : 0))
        anchors.centerIn: parent
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border { width: 1; color: NovaTheme.outline }

        NovaHeader {
            id: _titleWrap
            visible: root.showTitle
            height: root.titleHeight
            anchors { top: parent.top; left: parent.left; right: parent.right }
            tint: NovaTheme.surface
            NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
            Item { id: _title; anchors.fill: parent }
        }

        NovaPage {
            id: _body
            anchors {
                top: root.showTitle ? _titleWrap.bottom : parent.top
                bottom: root.showActions ? _actionsWrap.top : parent.bottom
                left: parent.left; right: parent.right
            }
            padding: NovaTheme.spacingM
        }

        Rectangle {
            id: _actionsWrap
            visible: root.showActions
            height: root.actionsHeight
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            color: NovaTheme.surface
            NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
            Item { id: _actions; anchors.fill: parent }
        }

        Keys.onEscapePressed: root.requestClose("escape")
        focus: true
    }

    Component.onCompleted: if (root.open) _card.forceActiveFocus()
}
