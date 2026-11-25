// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaSidebar.qml
// NovaSidebar 侧边导航工作台壳：单色系品牌渐变轨 + 浮起侧栏卡 + 五槽骨架（对标 Quasar QLayout + QDrawer）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5，消除 visible 三元跳变）；
//   每边界唯一分隔源；primary→secondary 撞色渐变收敛为主色系、装饰改抽象几何（CC-3）；槽位宿主独立铺满（CC-6）。
// 用法：向 headerSlot/sidebarSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent
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

    // ── 五个标准槽位（第 4 章 alias 机制；宿主一律独立铺满，CC-6）──
    property alias headerSlot: _headerHost.data
    property alias sidebarSlot: _sidebarHost.data
    property alias contentSlot: _body.content
    property alias footerSlot: _footerHost.data
    property alias overlaySlot: _overlay.data

    // ── 配置属性（默认值来自令牌，公共签名逐字不变）──
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

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _bp: Math.max(320, Math.min(root.breakpoint, 4096))
    readonly property real _size: Math.max(120, Math.min(root.sidebarSize, width / 2 || root.sidebarSize))
    readonly property bool belowBreakpoint: width > 0 && width < root._bp

    // ── 组合上下文 CC-1（宪法第 9 章）：唯一密度 / 层级 / 动效 / 品牌色基准 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property real _radius: NovaTheme.radiusM
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    readonly property color _ink: NovaTheme.primary
    readonly property color _inkSoft: Qt.lighter(NovaTheme.primary, 1.35)
    readonly property color _inkPale: Qt.lighter(NovaTheme.primary, 1.7)

    implicitWidth: 1024
    implicitHeight: 720

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 身份 A（主签名）：单色系品牌渐变竖轨，恒驻左缘，折叠时仍保留视觉锚 ──
    // a11y: decorative
    Rectangle {
        id: _brandRail
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: 4
        z: NovaTheme.zMarginals
        gradient: Gradient {
            GradientStop { position: 0.0; color: root._ink }
            GradientStop { position: 1.0; color: root._inkSoft }
        }
        opacity: 0.9
    }

    // ── 顶栏（高度归零 + 恒定锚链 CC-5；clip 保证收起动画全程可见）──
    Rectangle {
        id: _headerBar
        anchors { top: parent.top; left: _brandRail.right; right: parent.right }
        height: root.showHeader ? root._headerH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        // 该边界唯一分隔源（CC-2）：不再叠加缘轨 / 发丝线 / 顶层色带
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        NovaHeader {
            id: _header
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root._headerH          // 固定高度，避免 0 高时内部 padding 反噬负几何（坑位 19）
            tint: root._panel
        }

        // 身份 B（次签名）：主色系三档深浅圆点，抽象几何、不仿按钮（CC-3）
        // a11y: decorative
        Row {
            anchors { left: parent.left; leftMargin: root._gap; verticalCenter: _header.verticalCenter }
            spacing: root._unit
            z: NovaTheme.zMarginals
            Rectangle { width: 8; height: 8; radius: 4; color: root._ink; opacity: 0.9 }
            Rectangle { width: 8; height: 8; radius: 4; color: root._inkSoft; opacity: 0.9 }
            Rectangle { width: 8; height: 8; radius: 4; color: root._inkPale; opacity: 0.9 }
        }

        Item {
            id: _headerHost
            anchors { fill: _header; leftMargin: root._gap * 5; rightMargin: root._gap }
        }
    }

    // ── 底栏（锚链恒指自身，栏高归零驱动）──
    Rectangle {
        id: _footerBar
        anchors { bottom: parent.bottom; left: _brandRail.right; right: parent.right }
        height: root.showFooter ? root._footerH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }

        NovaFooter {
            id: _footer
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: root._footerH
            tint: root._panel
        }
        Item {
            id: _footerHost
            anchors { fill: _footer; leftMargin: root._gap; rightMargin: root._gap }
        }
    }

    // ── 身份 C：浮起侧栏卡（表面色阶 + 圆角 + 顶部段位条；宽度归零 + 恒定锚链）──
    Rectangle {
        id: _sidebarCard
        anchors {
            top: _headerBar.bottom
            bottom: _footerBar.top
            left: _brandRail.right
            leftMargin: root._gap
            topMargin: root._gap
            bottomMargin: root._gap
        }
        width: (root.sidebarCollapsed || root.belowBreakpoint) ? 0 : root._size
        radius: root._radius
        color: root._rail
        border { width: root.bordered ? 1 : 0; color: root._divider }
        clip: true
        Behavior on width {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        // a11y: decorative —— 段位递减条（抽象几何，非交互控件）
        Row {
            anchors { top: parent.top; left: parent.left; topMargin: root._unit; leftMargin: root._gap }
            spacing: root._unit
            z: NovaTheme.zMarginals
            Rectangle { width: 28; height: 3; radius: 1.5; color: root._ink; opacity: 0.9 }
            Rectangle { width: 16; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
            Rectangle { width: 8; height: 3; radius: 1.5; color: root._inkPale; opacity: 0.9 }
        }
        // CC-6 + 鲁棒性（坑位 20）：宿主铺满侧栏卡；margins 随父轨可用尺寸钳制，
        // 折叠 / 极端入参下父宽或父高为 0 时不产生负宽高。
        Item {
            id: _sidebarHost
            anchors {
                fill: parent
                margins: Math.max(0, Math.min(root._gap, Math.min(parent.width, parent.height) / 2))
                topMargin: Math.max(0, Math.min(root._gap * 2, parent.height / 2))
            }
        }
    }

    // 主内容区：锚链恒指侧栏卡右缘（宽度归零时恰为品牌轨右缘，无跳变）；padding 归零消除三层叠加（CC-1）
    NovaPage {
        id: _body
        anchors {
            top: _headerBar.bottom
            bottom: _footerBar.top
            left: _sidebarCard.right
            right: parent.right
        }
        padding: 0
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }

    // 前置预判性：Esc 收起侧栏（只 emit 收起意图，宿主受控改 sidebarCollapsed）
    focus: true
    Keys.onEscapePressed: if (!root.sidebarCollapsed) root.sidebarToggled(true)
}
