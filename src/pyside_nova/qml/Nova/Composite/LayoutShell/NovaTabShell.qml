// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaTabShell.qml
// NovaTabShell 标签页工作台壳：顶部 Tab 栏 + 内容容器 + 状态栏 + 全局浮层，内置激活/关闭/新增信号（对标 Quasar QTabs）
// NovaTabShell —— 多文档并行工作台组合根容器
// 用法：向 tabBarSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；Tab 状态由宿主受控，Shell 只 emit 意图
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    property alias tabBarSlot: _tabBar.data
    property alias contentSlot: _body.content
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property bool showTabBar: true
    property bool showFooter: true
    property int tabBarHeight: 44
    property int footerHeight: 48

    signal tabActivated(int index)
    signal tabCloseRequested(int index)
    signal tabAddRequested()

    implicitWidth: 1024
    implicitHeight: 720

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    Rectangle {
        id: _tabBarWrap
        visible: root.showTabBar
        height: root.tabBarHeight
        anchors { top: parent.top; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
        Item { id: _tabBar; anchors.fill: parent }
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
            top: root.showTabBar ? _tabBarWrap.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left
            right: parent.right
        }
        padding: NovaTheme.spacingM
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
