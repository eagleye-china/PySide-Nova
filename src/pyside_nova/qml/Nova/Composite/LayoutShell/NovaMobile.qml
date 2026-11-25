// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaMobile.qml
// NovaMobile 移动应用根壳：安全区 + 灵动岛状态栏 + 内容 + 底部导航 + home indicator（对标 Quasar QLayout mobile）
// NovaMobile —— 多端根壳之移动端；以"灵动岛 + home indicator"为身份语言，适配安卓触摸与 PySide6 移动打包
// 用法：向 headerSlot/contentSlot/bottomNavSlot/overlaySlot 注入业务内容；安全区由 safeTop/safeBottom 属性注入
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root
    // 鲁棒性 / i18n：声明式容器随 RTL 镜像；逻辑侧槽位语义恒定（宪法第 7 章第 3 条）
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias headerSlot: _header.data
    property alias contentSlot: _body.content
    property alias bottomNavSlot: _bottomNav.data
    property alias overlaySlot: _overlay.data

    property bool showHeader: true
    property bool showBottomNav: true
    property int safeTop: 0
    property int safeBottom: 0
    property int headerHeight: 56
    property int bottomNavHeight: 60
    property bool isTouch: NovaPlatform.isMobile

    signal backRequested()

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _safeT: Math.max(0, Math.min(root.safeTop, 160))
    readonly property int _safeB: Math.max(0, Math.min(root.safeBottom, 160))
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _navH: Math.max(24, Math.min(root.bottomNavHeight, 240))

    implicitWidth: 390
    implicitHeight: 844

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // 顶部安全区（刘海 / 状态栏）
    Item {
        id: _safeTop
        height: root._safeT
        anchors { top: parent.top; left: parent.left; right: parent.right }

        // ── 身份元素 ①：灵动岛（居中胶囊，纯装饰）──
        // a11y: decorative
        Rectangle {
            z: NovaTheme.zMarginals
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 4 }
            width: 96; height: 20; radius: 10
            color: NovaTheme.dark
            opacity: 0.85
            // 灵动岛内摄像头点
            Rectangle {
                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                width: 6; height: 6; radius: 3
                color: NovaTheme.primary
                opacity: 0.9
            }
        }
    }

    NovaHeader {
        id: _header
        visible: root.showHeader
        height: root._headerH
        anchors { top: _safeTop.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    NovaPage {
        id: _body
        anchors {
            top: root.showHeader ? _header.bottom : _safeTop.bottom
            bottom: root.showBottomNav ? _bottomNavWrap.top : _safeBottom.top
            left: parent.left; right: parent.right
        }
        padding: NovaTheme.spacingM
    }

    // ── 身份元素 ②：底部导航栏 + home indicator ──
    Rectangle {
        id: _bottomNavWrap
        visible: root.showBottomNav
        height: root._navH + root._safeB
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }

        // home indicator（底部居中横条）
        // a11y: decorative
        Rectangle {
            z: NovaTheme.zMarginals
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: Math.max(4, root._safeB / 2)
            }
            width: 108; height: 4; radius: 2
            color: NovaTheme.outlineStrong
            opacity: 0.9
        }

        Item {
            id: _bottomNav
            anchors {
                top: parent.top; left: parent.left; right: parent.right
                bottom: parent.bottom
                bottomMargin: Math.max(root._safeB, 16)
            }
        }
    }

    Item {
        id: _safeBottom
        height: root._safeB
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        visible: !root.showBottomNav
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFullscreen }

    Keys.onBackPressed: root.backRequested()
}
