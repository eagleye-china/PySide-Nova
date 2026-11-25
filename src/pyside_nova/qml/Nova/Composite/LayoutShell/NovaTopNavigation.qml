// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaTopNavigation.qml
// NovaTopNavigation 顶部导航工作台壳：胶囊导航台 + 悬浮下拉 + 主内容 + 状态栏（对标 Quasar QLayout header 导航）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）；
//   单一分隔源、装饰收敛主色系抽象几何（CC-3）；槽位宿主独立铺满（CC-6）。
// 用法：向 headerSlot/menuSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias headerSlot: _headerHost.data
    property alias menuSlot: _menuHost.data
    property alias contentSlot: _body.content
    property alias footerSlot: _footerHost.data
    property alias overlaySlot: _overlay.data

    property bool showHeader: true
    property bool showFooter: true
    property bool menuOpen: false
    property int headerHeight: 56
    property int footerHeight: 48
    property int menuHeight: 160

    signal menuToggled(bool open)
    function toggleMenu() { root.menuToggled(!root.menuOpen) }

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _menuH: Math.max(24, Math.min(root.menuHeight, 480))

    // ── 组合上下文 CC-1 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property real _radius: NovaTheme.radiusM
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _panel: NovaTheme.surface
    readonly property color _ink: NovaTheme.primary
    readonly property color _inkSoft: Qt.lighter(NovaTheme.primary, 1.35)

    implicitWidth: 1024
    implicitHeight: 720

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 身份 A（主签名）：胶囊导航台（浮起圆角 header；高度归零 + 恒定锚链 CC-5）──
    Rectangle {
        id: _headerWrap
        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: root._unit }
        height: root.showHeader ? root._headerH : 0
        clip: true
        color: root._panel
        radius: NovaTheme.radiusL
        border { width: 1; color: root._divider }
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }

        NovaHeader {
            id: _header
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root._headerH          // 固定高度，规避 0 高内部 padding 反噬（坑位 19）
            tint: root._panel
        }

        // 身份 B（次签名）：底部居中主色系发丝线（抽象几何，非交互控件 CC-3）
        // a11y: decorative
        Rectangle {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 2 }
            width: Math.max(24, parent.width * 0.12)
            height: 2
            radius: 1
            color: root._ink
            opacity: 0.9
            z: NovaTheme.zMarginals
        }

        Item {
            id: _headerHost
            anchors { fill: _header; leftMargin: root._gap; rightMargin: root._gap }
        }
    }

    // ── 悬浮下拉卡（结构层；阴影为功能性遮罩例外，随卡片高度同步显隐）──
    Rectangle {
        id: _menuShadow
        anchors { top: _menuCard.top; horizontalCenter: parent.horizontalCenter; topMargin: 3 }
        width: _menuCard.width + 6
        height: _menuCard.height
        radius: root._radius
        color: NovaTheme.shadowColor(2)
        visible: _menuCard.height > 0
    }

    Rectangle {
        id: _menuCard
        anchors { top: _headerWrap.bottom; horizontalCenter: parent.horizontalCenter; topMargin: root._gap }
        width: Math.max(0, Math.min(parent.width - root._gap * 2, 640))
        height: root.menuOpen ? root._menuH : 0
        radius: root._radius
        color: root._panel
        border { width: 1; color: root._divider }
        clip: true
        visible: root.menuOpen
        z: NovaTheme.zMenu
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        // CC-6 + 鲁棒性（坑位 20）：下拉卡收起（高度 0）时 margins 自动归零，避免负高。
        Item {
            id: _menuHost
            anchors {
                fill: parent
                margins: Math.max(0, Math.min(root._gap, Math.min(parent.width, parent.height) / 2))
            }
        }
    }

    // ── 底栏（高度归零 + 恒定锚链；该边界唯一分隔源）──
    Rectangle {
        id: _footerBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
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

    // 主内容区：锚链恒指胶囊台底边与底栏顶边；padding 归零（CC-1）
    NovaPage {
        id: _body
        anchors {
            top: _headerWrap.bottom
            topMargin: root._gap
            bottom: _footerBar.top
            left: parent.left
            right: parent.right
        }
        padding: 0
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }

    // 前置预判性：Esc 收起悬浮下拉（只 emit 关闭意图，宿主受控改 menuOpen）
    focus: true
    Keys.onEscapePressed: if (root.menuOpen) root.menuToggled(false)
}
