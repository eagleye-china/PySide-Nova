// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaCardGridShell.qml
// NovaCardGridShell 卡片网格壳：顶部筛选栏 + 自适应卡片网格 + 底部分页状态栏（对标组件画廊 / 模板市场）
// NovaCardGridShell —— 画廊首页 / 素材库组合根容器
// 用法：向 filterSlot/gridSlot/footerSlot/overlaySlot 注入业务内容；Shell 只托管布局，卡片由业务用 NovaCard 注入
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    property alias filterSlot: _filter.data
    property alias gridSlot: _grid.data
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property bool showFilter: true
    property bool showFooter: true
    property int filterHeight: 52
    property int footerHeight: 48
    property int padding: 12

    implicitWidth: 1024
    implicitHeight: 720

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    Rectangle {
        id: _filterWrap
        visible: root.showFilter
        height: root.filterHeight
        anchors { top: parent.top; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        z: NovaTheme.zMarginals
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
        Item { id: _filter; anchors.fill: parent }
    }

    Item {
        id: _grid
        anchors {
            top: root.showFilter ? _filterWrap.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left; right: parent.right
            margins: root.padding
        }
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
