// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaCompareShell.qml
// NovaCompareShell 双栏对比壳：等宽双面板 + 顶部控制栏 + 底部状态栏，可选同步滚动（对标代码 / 配置 diff 工具）
// NovaCompareShell —— 等宽对比工作台组合根容器
// 用法：向 controlSlot/leftSlot/rightSlot/footerSlot/overlaySlot 注入业务内容；同步滚动为受控开关，Shell 只 emit 偏好
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    property alias controlSlot: _control.data
    property alias leftSlot: _left.data
    property alias rightSlot: _right.data
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property bool showControl: true
    property bool showFooter: true
    property bool syncScroll: false
    property int controlHeight: 48
    property int footerHeight: 48
    property bool divider: true

    signal syncScrollToggled(bool enabled)

    function toggleSyncScroll() { root.syncScrollToggled(!root.syncScroll) }

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    Rectangle {
        id: _controlWrap
        visible: root.showControl
        height: root.controlHeight
        anchors { top: parent.top; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        z: NovaTheme.zMarginals
        Item { id: _control; anchors.fill: parent }
    }

    NovaPage {
        id: _left
        anchors {
            top: root.showControl ? _controlWrap.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left
            right: _sep.left
        }
        padding: NovaTheme.spacingS
    }

    NovaSeparator {
        id: _sep
        anchors {
            top: root.showControl ? _controlWrap.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        vertical: true
        visible: root.divider
        z: NovaTheme.zMarginals
    }

    NovaPage {
        id: _right
        anchors {
            top: root.showControl ? _controlWrap.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: _sep.right
            right: parent.right
        }
        padding: NovaTheme.spacingS
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
