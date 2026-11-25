// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaDesktop.qml
// NovaDesktop 桌面应用根壳：菜单栏 + 工具栏 + 多页面管理 + 状态栏，PC 桌面应用顶层根容器（对标 QMainWindow）
// NovaDesktop —— 多端根壳之桌面端（无 Shell 后缀，按组合宪法 0.2.0 同样受约束）
// 用法：向 menuSlot/toolbarSlot/pageSlot/statusSlot/overlaySlot 注入业务内容；根节点为应用窗口内容根，不含 ApplicationWindow
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    property alias menuSlot: _menu.data
    property alias toolbarSlot: _toolbar.data
    property alias pageSlot: _page.content
    property alias statusSlot: _status.data
    property alias overlaySlot: _overlay.data

    property bool showMenu: true
    property bool showToolbar: true
    property bool showStatus: true
    property int menuHeight: 32
    property int toolbarHeight: 48
    property int statusHeight: 28

    signal windowCloseRequested()

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    Rectangle {
        id: _menu
        visible: root.showMenu
        height: root.menuHeight
        anchors { top: parent.top; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        z: NovaTheme.zMarginals
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

    Rectangle {
        id: _toolbar
        visible: root.showToolbar
        height: root.toolbarHeight
        anchors {
            top: root.showMenu ? _menu.bottom : parent.top
            left: parent.left; right: parent.right
        }
        color: NovaTheme.surfaceAlt
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

    NovaPage {
        id: _page
        anchors {
            top: root.showToolbar ? _toolbar.bottom : (root.showMenu ? _menu.bottom : parent.top)
            bottom: root.showStatus ? _status.top : parent.bottom
            left: parent.left; right: parent.right
        }
        padding: 0
    }

    NovaFooter {
        id: _status
        visible: root.showStatus
        height: root.statusHeight
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zMax }

    Keys.onEscapePressed: root.windowCloseRequested()
    focus: true
}
