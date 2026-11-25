// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaTopNavigation.qml
// NovaTopNavigation 顶部导航工作台壳：胶囊导航条 + 悬浮下拉 + 主内容 + 状态栏（对标 Quasar QLayout header 导航）
// NovaTopNavigation —— 轻量化主导航组合根容器；以"胶囊 + 悬浮卡"为身份语言
// 用法：向 headerSlot/menuSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；Shell 只托管布局与下拉显隐
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

    property alias headerSlot: _header.data
    property alias menuSlot: _menu.data
    property alias contentSlot: _body.content
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property bool showHeader: true
    property bool showFooter: true
    property bool menuOpen: false
    property int headerHeight: 56
    property int footerHeight: 48
    property int menuHeight: 160

    signal menuToggled(bool open)
    function toggleMenu() { root.menuToggled(!root.menuOpen) }

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _menuH: Math.max(24, Math.min(root.menuHeight, 480))

    implicitWidth: 1024
    implicitHeight: 720

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 身份元素 ①：胶囊导航台（浮起的圆角 header，居中约束宽度）──
    // a11y: decorative
    Rectangle {
        id: _headerWrap
        visible: root.showHeader
        height: root._headerH
        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: NovaTheme.spacingS }
        color: NovaTheme.surface
        radius: NovaTheme.radiusL
        border { width: 1; color: NovaTheme.outline }
        z: NovaTheme.zMarginals

        // 胶囊底部居中 accent 发丝线（身份点缀）
        // a11y: decorative
        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 2
            }
            width: Math.max(24, parent.width * 0.12)
            height: 2
            radius: 1
            color: NovaTheme.primary
            opacity: 0.9
        }

        NovaHeader {
            id: _header
            anchors {
                fill: parent
                leftMargin: NovaTheme.spacingM
                rightMargin: NovaTheme.spacingM
            }
            tint: NovaTheme.surface
        }
    }

    // ── 身份元素 ②：悬浮下拉卡（圆角 + 阴影 + 边框，不再是通栏方块）──
    // a11y: decorative
    Rectangle {
        id: _menuShadow
        anchors {
            top: _menuCard.top
            left: _menuCard.left
            right: _menuCard.right
            bottom: _menuCard.bottom
        }
        x: _menuCard.x + 2
        y: _menuCard.y + 3
        radius: NovaTheme.radiusM
        color: NovaTheme.shadowColor(2)
        visible: _menuCard.visible
    }

    Rectangle {
        id: _menuCard
        anchors {
            top: _headerWrap.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: NovaTheme.spacingS
        }
        width: Math.max(0, Math.min(parent.width - NovaTheme.spacingL * 2, 640))
        height: root.menuOpen ? root._menuH : 0
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border { width: 1; color: NovaTheme.outline }
        clip: true
        visible: root.showHeader && root.menuOpen
        z: NovaTheme.zMenu
        Behavior on height {
            NumberAnimation { duration: NovaMotion.duration(NovaMotion.transitionDuration); easing.type: NovaMotion.easingStandard }
        }
        Item {
            id: _menu
            anchors { fill: parent; margins: NovaTheme.spacingS }
        }
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root._footerH
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    NovaPage {
        id: _body
        anchors {
            top: root.showHeader ? _headerWrap.bottom : parent.top
            topMargin: root.showHeader ? NovaTheme.spacingS : 0
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left
            right: parent.right
        }
        padding: NovaTheme.spacingM
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }

    // 前置预判性：Esc 收起悬浮下拉（只 emit 关闭意图，宿主受控改 menuOpen）
    focus: true
    Keys.onEscapePressed: if (root.menuOpen) root.menuToggled(false)
}
