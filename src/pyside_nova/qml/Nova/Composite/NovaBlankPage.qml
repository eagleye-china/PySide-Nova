// src/pyside_nova/qml/Nova/Composite/NovaBlankPage.qml
// NovaBlankPage 纯净单页壳：居中阅读栏 + Header + Content + Footer，最克制的可定制基底（无侧栏 / 无标签导航）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）；
//   阅读栏 padding 与 NovaPage padding 合并为单一边距（CC-1）；槽位宿主独立铺满（CC-6）。
// 用法：向 headerSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent
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
    property alias contentSlot: _body.content
    property alias footerSlot: _footerHost.data
    property alias overlaySlot: _overlay.data

    property bool showHeader: true
    property bool showFooter: true
    property int headerHeight: 56
    property int footerHeight: 48
    property int padding: 24

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _pad: Math.max(0, Math.min(root.padding, 96))

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

    implicitWidth: 800
    implicitHeight: 600

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 顶栏（高度归零 + 恒定锚链 CC-5；该边界唯一分隔源）──
    Rectangle {
        id: _headerBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showHeader ? root._headerH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        NovaHeader {
            id: _header
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root._headerH
            tint: root._panel
        }
        // 身份 A：极细居中主色发丝（克制到极致，仅一点品牌暗示）
        // a11y: decorative
        Rectangle {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            width: 32; height: 2; radius: 1
            color: root._ink
            opacity: 0.9
            z: NovaTheme.zMarginals
        }
        Item {
            id: _headerHost
            anchors { fill: _header; leftMargin: root._gap; rightMargin: root._gap }
        }
    }

    // ── 身份 B：居中阅读栏（最大宽度约束，左右优雅留白；单一表面色阶）──
    Rectangle {
        id: _readingColumn
        anchors {
            top: _headerBar.bottom
            bottom: _footerBar.top
            horizontalCenter: parent.horizontalCenter
            margins: root._gap
        }
        width: Math.max(0, Math.min(parent.width - root._gap * 2, 880))
        color: root._panel
        radius: root._radius
        border { width: 1; color: root._divider }

        NovaPage {
            id: _body
            anchors { fill: parent; margins: root._pad }
            padding: 0
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
        // a11y: decorative —— 主色系浅档发丝（替换 outlineStrong 中性描边）
        Rectangle {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            width: 32; height: 2; radius: 1
            color: root._inkSoft
            opacity: 0.9
            z: NovaTheme.zMarginals
        }
        Item {
            id: _footerHost
            anchors { fill: _footer; leftMargin: root._gap; rightMargin: root._gap }
        }
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
