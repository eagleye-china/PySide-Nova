// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaDrawerPanelShell.qml
// NovaDrawerPanelShell 侧边滑出面板壳：从左/右滑出的非模态临时面板，不阻塞主界面（区别于常驻 Sidebar）
// NovaDrawerPanelShell —— 属性面板 / 详情面板 / 临时表单组合根容器
// 用法：向 titleSlot/contentSlot/actionsSlot 注入业务内容；open/side 受控，Shell 只 emit 关闭与侧别意图
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
    property string side: "right"          // left | right（逻辑侧；RTL 下 bySide 自动镜像）
    readonly property string bySide: NovaTheme.isRtl ? (root.side === "left" ? "right" : "left") : root.side
    property real size: 360
    property int titleHeight: 52
    property bool showTitle: true
    property bool showActions: false
    property int actionsHeight: 56
    property bool scrim: false

    signal closeRequested()

    function requestClose() { root.closeRequested() }

    visible: root.open
    anchors.fill: parent

    Rectangle {
        id: _scrim
        visible: root.scrim
        anchors.fill: parent
        color: NovaTheme.shadowColor(2)
        opacity: 0.32
        MouseArea { anchors.fill: parent; onClicked: root.requestClose() }
    }

    Rectangle {
        id: _panel
        width: Math.max(200, Math.min(root.size, parent.width * 0.8 || root.size))
        anchors {
            top: parent.top; bottom: parent.bottom
            left: root.bySide === "left" ? parent.left : undefined
            right: root.bySide === "right" ? parent.right : undefined
        }
        color: NovaTheme.surface
        z: NovaTheme.zFixedDrawer
        NovaSeparator {
            anchors {
                top: parent.top; bottom: parent.bottom
                left: root.bySide === "right" ? parent.left : undefined
                right: root.bySide === "left" ? parent.right : undefined
            }
            vertical: true
        }

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

        Keys.onEscapePressed: root.requestClose()
        focus: true
    }

    Component.onCompleted: if (root.open) _panel.forceActiveFocus()
}
