// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaTopNavShell.qml
// NovaTopNavShell 顶部导航工作台壳：一级导航 + 下拉区 + 主内容 + 状态栏，无常驻侧栏（对标 Quasar QLayout header 导航）
// NovaTopNavShell —— 轻量化主导航组合根容器
// 用法：向 headerSlot/menuSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；Shell 只托管布局与下拉显隐
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    property alias headerSlot: _header.data
    property alias menuSlot: _menu.data
    property alias contentSlot: _body.content
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property bool showHeader: true
    property bool showFooter: true
    property bool menuOpen: false
    property int headerHeight: 56
    property int footerHeight: 48
    property int menuHeight: 160

    signal menuToggled(bool open)
    function toggleMenu() { root.menuToggled(!root.menuOpen) }

    implicitWidth: 1024
    implicitHeight: 720

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    NovaHeader {
        id: _header
        visible: root.showHeader
        height: root.headerHeight
        anchors { top: parent.top; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
        z: NovaTheme.zMarginals
    }

    // 下拉菜单区：受控显隐，靠信号上报，不写宿主状态
    Rectangle {
        id: _menuWrap
        anchors { top: _header.bottom; left: parent.left; right: parent.right }
        height: root.menuOpen ? root.menuHeight : 0
        color: NovaTheme.surface
        clip: true
        visible: root.showHeader
        z: NovaTheme.zMenu
        Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
        Item { id: _menu; anchors.fill: parent }
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root.footerHeight
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    NovaPage {
        id: _body
        anchors {
            top: root.menuOpen ? _menuWrap.bottom : (root.showHeader ? _header.bottom : parent.top)
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left
            right: parent.right
        }
        padding: NovaTheme.spacingM
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
