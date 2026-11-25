// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaSidebar.qml
// NovaSidebar 侧边导航工作台壳：品牌渐变轨 + 浮起侧栏卡 + 五槽骨架（对标 Quasar QLayout + QDrawer）
// NovaSidebar —— 主推引流款组合根容器；以"品牌轨"为身份语言，区别于其余工作台壳
// 用法：向 headerSlot/sidebarSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；Shell 只托管布局与折叠状态，不含业务菜单
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    // 鲁棒性 / i18n：声明式容器随 RTL 镜像；逻辑侧槽位语义恒定（宪法第 7 章第 3 条）
    LayoutMirroring.enabled: NovaTheme.isRtl

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

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))

    implicitWidth: 1024
    implicitHeight: 720

    // 非法入参兜底：尺寸钳制到安全范围
    readonly property real _size: Math.max(120, Math.min(root.sidebarSize, width / 2 || root.sidebarSize))

    // ── 身份元素 ①：品牌渐变轨（4px，恒驻左缘，折叠时仍保留为视觉锚）──
    // a11y: decorative
    Rectangle {
        id: _brandRail
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: 4
        z: NovaTheme.zMarginals
        gradient: Gradient {
            GradientStop { position: 0.0; color: NovaTheme.primary }
            GradientStop { position: 1.0; color: NovaTheme.secondary }
        }
    }

    // 底：内容表面
    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; left: _brandRail.right; right: parent.right }
        color: NovaTheme.page
    }

    NovaHeader {
        id: _header
        visible: root.showHeader
        height: root._headerH
        anchors {
            top: parent.top
            left: _brandRail.right
            right: parent.right
        }
        tint: NovaTheme.surface
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root._footerH
        anchors {
            bottom: parent.bottom
            left: _brandRail.right
            right: parent.right
        }
        tint: NovaTheme.surface
    }

    // ── 身份元素 ②：浮起侧栏卡（圆角 + 阴影影层 + 内边距）──
    // 阴影影层：低透明度、右下偏移，模拟 elevation（QML 无 box-shadow）
    // a11y: decorative
    Rectangle {
        id: _sidebarShadow
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: _brandRail.right
            leftMargin: NovaTheme.spacingS + 3
            topMargin: NovaTheme.spacingS + 3
            bottomMargin: NovaTheme.spacingS - 3
        }
        width: _sidebarCard.width
        radius: NovaTheme.radiusM
        color: NovaTheme.shadowColor(2)
        visible: _sidebarCard.visible
    }

    Rectangle {
        id: _sidebarCard
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: _brandRail.right
            leftMargin: NovaTheme.spacingS
            topMargin: NovaTheme.spacingS
            bottomMargin: NovaTheme.spacingS
        }
        width: (root.sidebarCollapsed || root.belowBreakpoint) ? 0 : root._size
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border { width: root.bordered ? 1 : 0; color: NovaTheme.outline }
        clip: true
        visible: width > 0
        Behavior on width {
            NumberAnimation { duration: NovaMotion.duration(NovaMotion.transitionDuration); easing.type: NovaMotion.easingStandard }
        }
        Item {
            id: _sidebar
            anchors {
                fill: parent
                margins: NovaTheme.spacingS
            }
        }
    }

    NovaPage {
        id: _body
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: _sidebarCard.visible ? _sidebarCard.right : _brandRail.right
            right: parent.right
        }
        padding: NovaTheme.spacingM
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }

    // 前置预判性：Esc 收起侧栏（只 emit 收起意图，宿主受控改 sidebarCollapsed）
    focus: true
    Keys.onEscapePressed: if (!root.sidebarCollapsed) root.sidebarToggled(true)
}
