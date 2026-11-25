// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaMobile.qml
// NovaMobile 移动应用根壳：系统安全区 + 顶栏 + 内容 + 底部导航，适配安卓触摸与 PySide6 移动打包（对标 Quasar QLayout mobile）
// NovaMobile —— 多端根壳之移动端（无 Shell 后缀，按组合宪法 0.2.0 同样受约束）
// 用法：向 headerSlot/contentSlot/bottomNavSlot/overlaySlot 注入业务内容；安全区由 safeTop/safeBottom 属性注入
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    property alias headerSlot: _header.data
    property alias contentSlot: _body.content
    property alias bottomNavSlot: _bottomNav.data
    property alias overlaySlot: _overlay.data

    property bool showHeader: true
    property bool showBottomNav: true
    property int safeTop: 0
    property int safeBottom: 0
    property int headerHeight: 56
    property int bottomNavHeight: 60
    property bool isTouch: NovaPlatform.isMobile

    signal backRequested()

    implicitWidth: 390
    implicitHeight: 844

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // 顶部安全区（刘海 / 状态栏）
    Item {
        id: _safeTop
        height: root.safeTop
        anchors { top: parent.top; left: parent.left; right: parent.right }
    }

    NovaHeader {
        id: _header
        visible: root.showHeader
        height: root.headerHeight
        anchors { top: _safeTop.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    NovaPage {
        id: _body
        anchors {
            top: root.showHeader ? _header.bottom : _safeTop.bottom
            bottom: root.showBottomNav ? _bottomNavWrap.top : _safeBottom.top
            left: parent.left; right: parent.right
        }
        padding: NovaTheme.spacingM
    }

    Rectangle {
        id: _bottomNavWrap
        visible: root.showBottomNav
        height: root.bottomNavHeight + root.safeBottom
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
        Item {
            id: _bottomNav
            anchors {
                top: parent.top; left: parent.left; right: parent.right
                bottom: parent.bottom; bottomMargin: root.safeBottom
            }
        }
    }

    Item {
        id: _safeBottom
        height: root.safeBottom
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        visible: !root.showBottomNav
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFullscreen }

    Keys.onBackPressed: root.backRequested()
}
