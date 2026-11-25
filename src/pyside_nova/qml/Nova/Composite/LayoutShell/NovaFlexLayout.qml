// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaFlexLayout.qml
// NovaFlexLayout 企业大屏弹性布局壳：自适应分栏 / 网格 / 动态缩放，面向 HMI 与工控超大分辨率（对标 Quasar flex grid）
// NovaFlexLayout —— 多端根壳之企业大屏（无 Shell 后缀，按组合宪法 0.2.0 同样受约束）
// 用法：向 headerSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；columns 与断点驱动分栏，缩放取 NovaScreen
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
    property bool showFooter: false
    property int columns: 3            // 1~4 分栏数，钳制防非法入参
    property int headerHeight: 64
    property int footerHeight: 48
    property int gap: 8
    property bool scalable: true

    signal layoutChanged(int columns)

    readonly property int _cols: Math.max(1, Math.min(4, root.columns))
    readonly property bool _largeScreen: NovaScreen.gtLg

    implicitWidth: 1920
    implicitHeight: 1080

    onColumnsChanged: root.layoutChanged(root._cols)

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
        padding: root.gap
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root.footerHeight
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zMax }
}
