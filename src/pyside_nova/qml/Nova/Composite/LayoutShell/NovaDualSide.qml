// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaDualSide.qml
// NovaDualSide 双侧边工作台壳：左导航 + 中央画布 + 右属性，两侧独立折叠（对标 Qt Designer / VSCode 三栏布局）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；两侧宽度归零 + 恒定锚链（CC-5）；
//   primary/secondary 撞色标识收敛主色系角标（CC-3）；每边界唯一分隔源；槽位宿主独立铺满（CC-6）。
// 用法：向 leftSlot/contentSlot/rightSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias leftSlot: _leftHost.data
    property alias contentSlot: _body.content
    property alias rightSlot: _rightHost.data
    property alias footerSlot: _footerHost.data
    property alias overlaySlot: _overlay.data

    property real leftSize: 240
    property real rightSize: 280
    property bool leftCollapsed: false
    property bool rightCollapsed: false
    property bool showFooter: true
    property int footerHeight: 48
    property bool bordered: true

    signal leftToggled(bool collapsed)
    signal rightToggled(bool collapsed)
    function toggleLeft() { root.leftToggled(!root.leftCollapsed) }
    function toggleRight() { root.rightToggled(!root.rightCollapsed) }

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）
    readonly property real _lw: Math.max(80, Math.min(root.leftSize, width / 3 || root.leftSize))
    readonly property real _rw: Math.max(80, Math.min(root.rightSize, width / 3 || root.rightSize))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))

    // ── 组合上下文 CC-1 ──
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

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 身份 A（主签名）：左侧单色系渐变轨，折叠时仍保留视觉锚 ──
    // a11y: decorative
    Rectangle {
        id: _leftRail
        anchors { top: parent.top; bottom: _footerBar.top; left: parent.left }
        width: 3
        z: NovaTheme.zMarginals
        gradient: Gradient {
            GradientStop { position: 0.0; color: root._ink }
            GradientStop { position: 1.0; color: root._inkSoft }
        }
        opacity: 0.9
    }

    // ── 左栏（宽度归零 + 恒定锚链 + 共用动效；clip 保证折叠动画全程可见）──
    Rectangle {
        id: _leftCard
        anchors {
            top: parent.top; topMargin: root._gap
            bottom: _footerBar.top; bottomMargin: root._gap
            left: _leftRail.right; leftMargin: root._gap
        }
        width: root.leftCollapsed ? 0 : root._lw
        radius: root._radius
        color: root._rail
        border { width: root.bordered && _leftCard.width > 0 ? 1 : 0; color: root._divider }
        clip: true
        Behavior on width {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        // a11y: decorative —— 右上角主色系角标（抽象几何，非整条色带，避免边界叠线 CC-2）
        Row {
            anchors { top: parent.top; right: parent.right; topMargin: root._unit; rightMargin: root._gap }
            spacing: root._unit
            z: NovaTheme.zMarginals
            Rectangle { width: 16; height: 3; radius: 1.5; color: root._ink; opacity: 0.9 }
            Rectangle { width: 8; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
        }
        Item {
            id: _leftHost
            anchors { fill: parent; margins: root._gap }
        }
    }

    // ── 身份 B：中央画布（圆角表面 + 网格点阵底纹；底纹留在业务注入之下，不提级）──
    Rectangle {
        id: _canvas
        anchors {
            top: parent.top; topMargin: root._gap
            bottom: _footerBar.top; bottomMargin: root._gap
            left: _leftCard.right
            right: _rightCard.left
            leftMargin: root._gap
            rightMargin: root._gap
        }
        radius: root._radius
        color: root._panel
        border { width: 1; color: root._divider }

        // a11y: decorative
        Grid {
            anchors.centerIn: parent
            rows: 8; columns: 12
            rowSpacing: 28; columnSpacing: 28
            Repeater {
                model: 96
                Rectangle {
                    width: 2; height: 2; radius: 1
                    color: root._divider
                    opacity: 0.9
                }
            }
        }

        NovaPage {
            id: _body
            anchors.fill: parent
            padding: 0
        }
    }

    // ── 右栏（宽度归零 + 恒定锚链；角标用主色系浅档，消除 secondary 撞色 CC-3）──
    Rectangle {
        id: _rightCard
        anchors {
            top: parent.top; topMargin: root._gap
            bottom: _footerBar.top; bottomMargin: root._gap
            right: parent.right; rightMargin: root._gap
        }
        width: root.rightCollapsed ? 0 : root._rw
        radius: root._radius
        color: root._rail
        border { width: root.bordered && _rightCard.width > 0 ? 1 : 0; color: root._divider }
        clip: true
        Behavior on width {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        // a11y: decorative
        Row {
            anchors { top: parent.top; left: parent.left; topMargin: root._unit; leftMargin: root._gap }
            spacing: root._unit
            z: NovaTheme.zMarginals
            Rectangle { width: 8; height: 3; radius: 1.5; color: root._inkPale; opacity: 0.9 }
            Rectangle { width: 16; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
        }
        Item {
            id: _rightHost
            anchors { fill: parent; margins: root._gap }
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

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }

    // 前置预判性：Esc 收起双侧栏（只 emit 收起意图，宿主受控改 left/rightCollapsed）
    focus: true
    Keys.onEscapePressed: {
        if (!root.leftCollapsed) root.leftToggled(true)
        if (!root.rightCollapsed) root.rightToggled(true)
    }
}
