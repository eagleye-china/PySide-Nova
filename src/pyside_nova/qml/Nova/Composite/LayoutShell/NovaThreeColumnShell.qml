// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaThreeColumnShell.qml
// NovaThreeColumnShell 三栏工作台壳：左目录树 / 中列表 / 右详情，栏宽受控、内置分割条与重排信号（对标资源管理器布局）
// NovaThreeColumnShell —— 文档阅读器 / 图标画廊 / API 工作台组合根容器
// 用法：向 treeSlot/listSlot/detailSlot 注入业务内容；宽度变化时 emit columnResized，分割条拖拽由宿主决策
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    property alias treeSlot: _tree.data
    property alias listSlot: _list.content
    property alias detailSlot: _detail.data
    property alias headerSlot: _header.data
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property real treeSize: 220
    property real detailSize: 320
    property bool showHeader: true
    property bool showFooter: false
    property int headerHeight: 56
    property int footerHeight: 48
    property bool bordered: true

    signal columnResized(string column, real size)

    readonly property real _tw: Math.max(120, Math.min(root.treeSize, width / 4 || root.treeSize))
    readonly property real _dw: Math.max(160, Math.min(root.detailSize, width / 3 || root.detailSize))

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    NovaHeader {
        id: _header
        visible: root.showHeader
        height: root.headerHeight
        anchors { top: parent.top; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    Rectangle {
        id: _treeWrap
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left
        }
        width: root._tw
        color: NovaTheme.surfaceAlt
        Item { id: _tree; anchors.fill: parent }
    }

    NovaSeparator {
        id: _s1
        anchors {
            top: _treeWrap.top; bottom: _treeWrap.bottom; left: _treeWrap.right
        }
        vertical: true
        visible: root.bordered
        z: NovaTheme.zMarginals
        enabled: true
        HoverHandler { cursorShape: Qt.SplitHCursor }
    }

    NovaPage {
        id: _list
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: _s1.right
            right: _s2.left
        }
        padding: NovaTheme.spacingM
    }

    NovaSeparator {
        id: _s2
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            right: _detailWrap.left
        }
        vertical: true
        visible: root.bordered
        z: NovaTheme.zMarginals
        HoverHandler { cursorShape: Qt.SplitHCursor }
    }

    Rectangle {
        id: _detailWrap
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            right: parent.right
        }
        width: root._dw
        color: NovaTheme.surface
        Item { id: _detail; anchors.fill: parent }
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
