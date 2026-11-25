// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaBlankPageShell.qml
// NovaBlankPageShell 纯净单页壳：Header + Content + Footer，无任何侧栏/标签导航，最小可定制骨架
// NovaBlankPageShell —— 独立小工具 / 子页面 / 高级用户自定义布局基底
// 用法：向 headerSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；Shell 仅提供三区布局与令牌底色
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    property alias headerSlot: _header.data
    property alias contentSlot: _body.content
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property bool showHeader: true
    property bool showFooter: true
    property int headerHeight: 56
    property int footerHeight: 48
    property int padding: 24

    implicitWidth: 800
    implicitHeight: 600

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    NovaHeader {
        id: _header
        visible: root.showHeader
        height: root.headerHeight
        anchors { top: parent.top; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    NovaPage {
        id: _body
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left; right: parent.right
        }
        padding: root.padding
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root.footerHeight
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
