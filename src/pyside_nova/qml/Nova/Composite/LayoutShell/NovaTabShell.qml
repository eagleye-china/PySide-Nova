// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaTabShell.qml
// NovaTabShell 标签页工作台壳：下划线激活指示条 + 标签栏 + 内容容器 + 状态栏（对标 Quasar QTabs）
// NovaTabShell —— 多文档并行工作台组合根容器；以"下划线指示条"为身份语言
// 用法：向 tabBarSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；Tab 状态由宿主受控，Shell 只 emit 意图
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root
    // 鲁棒性 / i18n：声明式容器随 RTL 镜像；逻辑侧槽位语义恒定（宪法第 7 章第 3 条）
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias tabBarSlot: _tabBar.data
    property alias contentSlot: _body.content
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property bool showTabBar: true
    property bool showFooter: true
    property int tabBarHeight: 44
    property int footerHeight: 48

    signal tabActivated(int index)
    signal tabCloseRequested(int index)
    signal tabAddRequested()

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _tabBarH: Math.max(24, Math.min(root.tabBarHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))

    implicitWidth: 1024
    implicitHeight: 720

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 身份元素：材质化标签栏（浅色底 + 三态段落 + 下划线激活指示）──
    // a11y: decorative
    Rectangle {
        id: _tabBarWrap
        visible: root.showTabBar
        height: root._tabBarH
        anchors { top: parent.top; left: parent.left; right: parent.right }
        color: NovaTheme.surfaceAlt
        z: NovaTheme.zMarginals

        // 顶部段落标记（左中右三段，纯装饰）
        // a11y: decorative
        Row {
            z: NovaTheme.zMarginals
            anchors { left: parent.left; leftMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            spacing: 4
            Rectangle { width: 16; height: 3; radius: 1.5; color: NovaTheme.primary; opacity: 0.9 }
            Rectangle { width: 8; height: 3; radius: 1.5; color: NovaTheme.secondary; opacity: 0.9 }
            Rectangle { width: 8; height: 3; radius: 1.5; color: NovaTheme.accent; opacity: 0.9 }
        }

        // 激活指示条：贴标签栏底边居中的品牌下划线（纯装饰身份元素，不绑定业务状态）
        // a11y: decorative
        Rectangle {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: 56
            height: 3
            radius: 1.5
            color: NovaTheme.primary
            z: NovaTheme.zMarginals
        }

        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
        Item {
            id: _tabBar
            anchors {
                fill: parent
                leftMargin: NovaTheme.spacingL * 2
                rightMargin: NovaTheme.spacingM
            }
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
            top: root.showTabBar ? _tabBarWrap.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left
            right: parent.right
        }
        padding: NovaTheme.spacingM
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
