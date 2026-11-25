// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaCompare.qml
// NovaCompare 双栏对比壳：中缝分隔 + 等宽双面板 + 控制栏 + 状态栏（对标代码 / 配置 diff 工具）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）；
//   A/B 贯穿色条与伪调节柄箭头改为主色系角标 + 抽象短条（CC-2/CC-3）；槽位宿主独立铺满（CC-6）。
// 用法：向 controlSlot/leftSlot/rightSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias controlSlot: _controlHost.data
    property alias leftSlot: _left.content
    property alias rightSlot: _right.content
    property alias footerSlot: _footerHost.data
    property alias overlaySlot: _overlay.data

    property bool showControl: true
    property bool showFooter: true
    property bool syncScroll: false
    property int controlHeight: 48
    property int footerHeight: 48
    property bool divider: true

    signal syncScrollToggled(bool enabled)
    function toggleSyncScroll() { root.syncScrollToggled(!root.syncScroll) }

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）
    readonly property int _controlH: Math.max(24, Math.min(root.controlHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))

    // ── 组合上下文 CC-1 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _panel: NovaTheme.surface
    readonly property color _ink: NovaTheme.primary
    readonly property color _inkSoft: Qt.lighter(NovaTheme.primary, 1.35)

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 控制栏（高度归零 + 恒定锚链 CC-5）──
    Rectangle {
        id: _controlWrap
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showControl ? root._controlH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
        Item {
            id: _controlHost
            anchors { fill: parent; leftMargin: root._gap; rightMargin: root._gap }
        }
    }

    // ── 左面板（A）：锚链恒指控制栏底边与中缝左缘（CC-5）──
    NovaPage {
        id: _left
        anchors {
            top: _controlWrap.bottom
            bottom: _footerBar.top
            left: parent.left
            right: _sep.left
        }
        padding: 0
    }
    // 身份 A：主色系角标（抽象几何，替换左 primary 贯穿色条，避免与中缝叠线 CC-2/CC-3）
    // a11y: decorative
    Row {
        anchors { top: _controlWrap.bottom; left: parent.left; topMargin: root._gap; leftMargin: root._gap }
        spacing: root._unit
        z: NovaTheme.zMarginals
        Rectangle { width: 22; height: 3; radius: 1.5; color: root._ink; opacity: 0.9 }
        Rectangle { width: 10; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
    }

    // ── 中缝：唯一分隔源 + 抽象短条（替换「圆形调节柄 + 双箭头」伪控件，CC-3）──
    NovaSeparator {
        id: _sep
        anchors {
            top: _controlWrap.bottom
            bottom: _footerBar.top
            horizontalCenter: parent.horizontalCenter
        }
        vertical: true
        visible: root.divider
        z: NovaTheme.zMarginals
        Rectangle {
            anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            width: 4; height: 28; radius: 2
            color: root._ink
            opacity: 0.9
        }
    }

    // ── 右面板（B）──
    NovaPage {
        id: _right
        anchors {
            top: _controlWrap.bottom
            bottom: _footerBar.top
            left: _sep.right
            right: parent.right
        }
        padding: 0
    }
    // 身份 B：主色系浅档角标（替换右 secondary 贯穿色条）
    // a11y: decorative
    Row {
        anchors { top: _controlWrap.bottom; right: parent.right; topMargin: root._gap; rightMargin: root._gap }
        spacing: root._unit
        z: NovaTheme.zMarginals
        Rectangle { width: 10; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
        Rectangle { width: 22; height: 3; radius: 1.5; color: root._ink; opacity: 0.9 }
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

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
