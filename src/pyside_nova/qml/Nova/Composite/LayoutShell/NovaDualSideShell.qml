// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaDualSideShell.qml
// NovaDualSideShell 双侧边工作台壳：左导航 + 中内容 + 右属性，两侧独立折叠（对标 Qt Designer / VSCode 三栏布局）
// NovaDualSideShell —— 工业配置软件高频三栏组合根容器
// 用法：向 leftSlot/contentSlot/rightSlot/footerSlot/overlaySlot 注入业务内容；两侧宽度受控、只 emit 折叠事件
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    property alias leftSlot: _left.data
    property alias contentSlot: _body.content
    property alias rightSlot: _right.data
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property real leftSize: 240
    property real rightSize: 280
    property bool leftCollapsed: false
    property bool rightCollapsed: false
    property bool showFooter: true
    property int footerHeight: 48
    property bool bordered: true

    signal leftToggled(bool collapsed)
    signal rightToggled(bool collapsed)
    function toggleLeft() { root.leftToggled(!root.leftCollapsed) }
    function toggleRight() { root.rightToggled(!root.rightCollapsed) }

    readonly property real _lw: Math.max(80, Math.min(root.leftSize, width / 3 || root.leftSize))
    readonly property real _rw: Math.max(80, Math.min(root.rightSize, width / 3 || root.rightSize))

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    Rectangle {
        id: _leftWrap
        anchors { top: parent.top; bottom: root.showFooter ? _footer.top : parent.bottom; left: parent.left }
        width: root.leftCollapsed ? 0 : root._lw
        color: NovaTheme.surfaceAlt
        clip: true
        Behavior on width {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
        Item { id: _left; anchors.fill: parent }
    }

    NovaSeparator {
        id: _ls
        anchors { top: parent.top; bottom: root.showFooter ? _footer.top : parent.bottom; left: _leftWrap.right }
        vertical: true
        visible: root.bordered && !root.leftCollapsed
        z: NovaTheme.zMarginals
    }

    NovaPage {
        id: _body
        anchors {
            top: parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: _ls.visible ? _ls.right : _leftWrap.right
            right: _rs.visible ? _rs.left : _rightWrap.left
        }
        padding: NovaTheme.spacingM
    }

    NovaSeparator {
        id: _rs
        anchors { top: parent.top; bottom: root.showFooter ? _footer.top : parent.bottom; right: _rightWrap.left }
        vertical: true
        visible: root.bordered && !root.rightCollapsed
        z: NovaTheme.zMarginals
    }

    Rectangle {
        id: _rightWrap
        anchors { top: parent.top; bottom: root.showFooter ? _footer.top : parent.bottom; right: parent.right }
        width: root.rightCollapsed ? 0 : root._rw
        color: NovaTheme.surfaceAlt
        clip: true
        Behavior on width {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
        Item { id: _right; anchors.fill: parent }
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
