// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaDesktop.qml
// NovaDesktop 桌面应用根壳：窗口控制点 + 菜单栏 + 工具栏 + 多页面 + 状态栏（对标 QMainWindow）
// NovaDesktop —— 多端根壳之桌面端；以"窗口控制点 + 分层栏"为身份语言，区别于移动与大屏根壳
// 用法：向 menuSlot/toolbarSlot/pageSlot/statusSlot/overlaySlot 注入业务内容；根节点为应用窗口内容根，不含 ApplicationWindow
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root
    // 鲁棒性 / i18n：声明式容器随 RTL 镜像；逻辑侧槽位语义恒定（宪法第 7 章第 3 条）
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias menuSlot: _menu.data
    property alias toolbarSlot: _toolbarHost.data
    property alias pageSlot: _page.content
    property alias statusSlot: _status.data
    property alias overlaySlot: _overlay.data

    property bool showMenu: true
    property bool showToolbar: true
    property bool showStatus: true
    property int menuHeight: 32
    property int toolbarHeight: 48
    property int statusHeight: 28

    signal windowCloseRequested()

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _menuH: Math.max(24, Math.min(root.menuHeight, 120))
    readonly property int _toolbarH: Math.max(24, Math.min(root.toolbarHeight, 240))
    readonly property int _statusH: Math.max(24, Math.min(root.statusHeight, 120))

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 身份元素 ①：菜单栏 + 三色窗口控制点（左端红黄绿，纯装饰）──
    Rectangle {
        id: _menuBar
        visible: root.showMenu
        height: root._menuH
        anchors { top: parent.top; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        z: NovaTheme.zMarginals
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        // a11y: decorative
        Row {
            z: NovaTheme.zMarginals
            anchors { left: parent.left; leftMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            spacing: 8
            Rectangle { width: 10; height: 10; radius: 5; color: NovaTheme.negative; opacity: 0.85 }
            Rectangle { width: 10; height: 10; radius: 5; color: NovaTheme.warning; opacity: 0.85 }
            Rectangle { width: 10; height: 10; radius: 5; color: NovaTheme.positive; opacity: 0.85 }
        }

        // 业务菜单注入区（避开左端控制点）
        Item {
            id: _menu
            anchors {
                top: parent.top; bottom: parent.bottom
                left: parent.left; leftMargin: NovaTheme.spacingL * 2
                right: parent.right
            }
        }
    }

    // ── 身份元素 ②：工具栏（section 分隔 + 提亮底面）──
    Rectangle {
        id: _toolbar
        visible: root.showToolbar
        height: root._toolbarH
        anchors {
            top: root.showMenu ? _menuBar.bottom : parent.top
            left: parent.left; right: parent.right
        }
        color: NovaTheme.surfaceAlt
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        // 工具段分隔点（纯装饰；z 提级确保业务注入铺满时身份仍可见）
        // a11y: decorative
        Row {
            z: NovaTheme.zMarginals
            anchors { left: parent.left; leftMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            spacing: NovaTheme.spacingS
            Rectangle { width: 26; height: 26; radius: NovaTheme.radiusS; color: NovaTheme.primary; opacity: 0.9 }
            Rectangle { width: 26; height: 26; radius: NovaTheme.radiusS; color: NovaTheme.surface; border { width: 1; color: NovaTheme.outline } }
            Rectangle { width: 26; height: 26; radius: NovaTheme.radiusS; color: NovaTheme.surface; border { width: 1; color: NovaTheme.outline } }
            Rectangle { width: 1; height: 20; color: NovaTheme.outline; anchors { verticalCenter: parent.verticalCenter } }
            Rectangle { width: 26; height: 26; radius: NovaTheme.radiusS; color: NovaTheme.surface; border { width: 1; color: NovaTheme.outline } }
        }

        // 业务工具条注入宿主：独立于装饰层，避开左端段位标识
        Item {
            id: _toolbarHost
            anchors {
                fill: parent
                leftMargin: NovaTheme.spacingL * 3
            }
        }
    }

    NovaPage {
        id: _page
        anchors {
            top: root.showToolbar ? _toolbar.bottom : (root.showMenu ? _menuBar.bottom : parent.top)
            bottom: root.showStatus ? _status.top : parent.bottom
            left: parent.left; right: parent.right
        }
        padding: 0
    }

    NovaFooter {
        id: _status
        visible: root.showStatus
        height: root._statusH
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface

        // 状态指示点（左端，纯装饰）
        // a11y: decorative
        Rectangle {
            anchors { left: parent.left; leftMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            width: 6; height: 6; radius: 3
            color: NovaTheme.positive
            z: NovaTheme.zMarginals
        }
    }

    Item {
        id: _overlay
        anchors.fill: parent
        z: NovaTheme.zMax
    }

    Keys.onEscapePressed: root.windowCloseRequested()
    focus: true
}
