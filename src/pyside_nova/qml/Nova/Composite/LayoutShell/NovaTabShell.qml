// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaTabShell.qml
// NovaTabShell 标签页工作台壳：下划线激活指示条 + 标签栏 + 内容容器 + 状态栏（对标 Quasar QTabs）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）；
//   三色段落收敛主色系递减条、删底边重复分隔线（CC-2/CC-3）；槽位宿主独立铺满（CC-6）。
// 用法：向 tabBarSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias tabBarSlot: _tabBarHost.data
    property alias contentSlot: _body.content
    property alias footerSlot: _footerHost.data
    property alias overlaySlot: _overlay.data

    property bool showTabBar: true
    property bool showFooter: true
    property int tabBarHeight: 44
    property int footerHeight: 48

    signal tabActivated(int index)
    signal tabCloseRequested(int index)
    signal tabAddRequested()

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）
    readonly property int _tabBarH: Math.max(24, Math.min(root.tabBarHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))

    // ── 组合上下文 CC-1 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
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

    // ── 标签栏（高度归零 + 恒定锚链 CC-5；clip 保证收起动画全程可见）──
    Rectangle {
        id: _tabBarWrap
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showTabBar ? root._tabBarH : 0
        clip: true
        color: root._rail
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }

        // 身份 A（次签名）：主色系三档递减条（抽象几何，替换原 primary/secondary/accent 三色撞色）
        // a11y: decorative
        Row {
            anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
            spacing: root._unit
            z: NovaTheme.zMarginals
            Rectangle { width: 16; height: 3; radius: 1.5; color: root._ink; opacity: 0.9 }
            Rectangle { width: 8; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
            Rectangle { width: 8; height: 3; radius: 1.5; color: root._inkPale; opacity: 0.9 }
        }

        // 身份 B（主签名）：居中品牌下划线（该边界唯一视觉标记，不再叠加 NovaSeparator，CC-2）
        // a11y: decorative
        Rectangle {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            width: 56
            height: 3
            radius: 1.5
            color: root._ink
            opacity: 0.9
            z: NovaTheme.zMarginals
        }

        Item {
            id: _tabBarHost
            anchors { fill: parent; leftMargin: root._gap * 5; rightMargin: root._gap }
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

    NovaPage {
        id: _body
        anchors {
            top: _tabBarWrap.bottom
            bottom: _footerBar.top
            left: parent.left
            right: parent.right
        }
        padding: 0
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
