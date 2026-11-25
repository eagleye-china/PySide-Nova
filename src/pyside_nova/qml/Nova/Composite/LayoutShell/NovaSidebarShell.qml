// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaSidebarShell.qml
// NovaSidebarShell 侧边导航工作台壳：侧栏 + Header + Content + Footer + Overlay 五槽骨架，侧栏可折叠、断点自动收起（对标 Quasar QLayout + QDrawer）
// NovaSidebarShell —— 主推引流款组合根容器（对标 QLayout 侧栏布局）
// 用法：向 headerSlot/sidebarSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；Shell 只托管布局与折叠状态，不含业务菜单
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    // ── 五个标准槽位（第 4 章 alias 机制）──
    property alias headerSlot: _header.data
    property alias sidebarSlot: _sidebar.data
    property alias contentSlot: _body.content
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    // ── 配置属性（默认值来自令牌，不进冻结面）──
    property real sidebarSize: 260
    property bool sidebarCollapsed: false
    property bool showHeader: true
    property bool showFooter: true
    property int headerHeight: 56
    property int footerHeight: 48
    property int breakpoint: 1024
    property bool bordered: true

    // ── 受控契约：只 emit，不自写宿主状态 ──
    signal sidebarToggled(bool collapsed)
    function toggleSidebar() { root.sidebarToggled(!root.sidebarCollapsed) }

    readonly property bool belowBreakpoint: width > 0 && width < root.breakpoint

    implicitWidth: 1024
    implicitHeight: 720

    // 非法入参兜底：尺寸钳制到安全范围
    readonly property real _size: Math.max(120, Math.min(root.sidebarSize, width / 2 || root.sidebarSize))

    Rectangle {
        id: _bg
        anchors.fill: parent
        color: NovaTheme.page
    }

    NovaHeader {
        id: _header
        visible: root.showHeader
        height: root.headerHeight
        anchors { top: parent.top; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root.footerHeight
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    // 侧栏宿主：折叠/断点时宽度归零，内容由业务注入
    Rectangle {
        id: _sidebarWrap
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left
        }
        width: (root.sidebarCollapsed || root.belowBreakpoint) ? 0 : root._size
        color: NovaTheme.surfaceAlt
        clip: true
        Behavior on width {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
        Item {
            id: _sidebar
            anchors.fill: parent
        }
    }

    NovaSeparator {
        id: _sep
        anchors {
            top: _sidebarWrap.top
            bottom: _sidebarWrap.bottom
            left: _sidebarWrap.right
        }
        vertical: true
        visible: root.bordered && _sidebarWrap.width > 0
        z: NovaTheme.zMarginals
    }

    NovaPage {
        id: _body
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: _sep.visible ? _sep.right : _sidebarWrap.right
            right: parent.right
        }
        padding: NovaTheme.spacingM
    }

    Item {
        id: _overlay
        anchors.fill: parent
        z: NovaTheme.zFixedDrawer
    }
}
