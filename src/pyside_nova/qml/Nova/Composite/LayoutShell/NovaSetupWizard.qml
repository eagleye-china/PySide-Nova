// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaSetupWizard.qml
// NovaSetupWizard 安装配置向导壳：三态步骤时间轴 + 当前步内容 + 上一步/下一步控制区（对标 Quasar QStepper）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）；
//   两个仿交互控件改抽象几何（CC-3）；业务步骤指示器提级到装饰之上（友好度）；槽位宿主独立铺满（CC-6）。
// 用法：向 stepsSlot/contentSlot/controlsSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias stepsSlot: _steps.data
    property alias contentSlot: _body.content
    property alias controlsSlot: _controls.data
    property alias footerSlot: _footerHost.data
    property alias overlaySlot: _overlay.data

    property int currentStep: 0
    property int stepCount: 3
    property bool showSteps: true
    property bool showFooter: false
    property int stepsHeight: 64
    property int controlsHeight: 56
    property int footerHeight: 48

    signal previousRequested()
    signal nextRequested()
    signal stepSelected(int index)

    readonly property bool canGoPrevious: root.currentStep > 0
    readonly property bool canGoNext: root.currentStep < root.stepCount - 1

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）
    readonly property int _stepsH: Math.max(24, Math.min(root.stepsHeight, 240))
    readonly property int _controlsH: Math.max(24, Math.min(root.controlsHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _nSteps: Math.max(1, Math.min(root.stepCount, 12))
    readonly property int _curStep: Math.max(0, Math.min(root.currentStep, root._nSteps - 1))

    // ── 组合上下文 CC-1 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _panel: NovaTheme.surface
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _ink: NovaTheme.primary
    readonly property color _inkSoft: Qt.lighter(NovaTheme.primary, 1.35)
    readonly property color _inkPale: Qt.lighter(NovaTheme.primary, 1.7)

    implicitWidth: 900
    implicitHeight: 640

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 步骤栏（高度归零 + 恒定锚链 CC-5；该边界唯一分隔源）──
    Rectangle {
        id: _stepsWrap
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showSteps ? root._stepsH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        // 身份（主签名）：三态步骤时间轴 —— 连接线 + 进度线 + 圆点（纯装饰，零业务语义）
        // a11y: decorative
        Rectangle {
            z: 2
            anchors {
                left: parent.left; leftMargin: root._gap * 2
                right: parent.right; rightMargin: root._gap * 2
                verticalCenter: parent.verticalCenter
            }
            height: 2
            color: root._divider
        }
        // a11y: decorative
        Rectangle {
            z: 2
            anchors { left: parent.left; leftMargin: root._gap * 2; verticalCenter: parent.verticalCenter }
            width: root._nSteps > 1
                   ? (parent.width - root._gap * 4) * (root._curStep / Math.max(1, root._nSteps - 1))
                   : 0
            height: 2
            color: root._ink
            Behavior on width {
                NumberAnimation { duration: root._dur; easing.type: root._ease }
            }
        }
        // a11y: decorative
        Row {
            z: 2
            anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            spacing: Math.max(24, (_stepsWrap.width - root._gap * 6) / root._nSteps)
            Repeater {
                model: root._nSteps
                Rectangle {
                    id: _dot
                    required property int index
                    property bool _done: _dot.index < root._curStep
                    property bool _active: _dot.index === root._curStep
                    width: 18; height: 18; radius: 9
                    color: _dot._done ? root._ink : (_dot._active ? root._panel : root._rail)
                    border {
                        width: _dot._done || _dot._active ? 2 : 1
                        color: _dot._done || _dot._active ? root._ink : root._divider
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        width: 6; height: 6; radius: 3
                        color: _dot._active ? root._ink : NovaTheme.textOnPrimary
                        visible: _dot._done || _dot._active
                    }
                }
            }
        }
        // 业务步骤指示器注入层：提级到装饰时间轴之上，真实可交互（CC-3 友好度）
        Item {
            id: _steps
            anchors.fill: parent
            z: 3
        }
    }

    NovaPage {
        id: _body
        anchors {
            top: _stepsWrap.bottom
            bottom: _controlsWrap.top
            left: parent.left
            right: parent.right
        }
        padding: 0
    }

    // ── 控制栏（恒定高度；两侧抽象几何，替换原「上一步/下一步」仿交互控件）──
    Rectangle {
        id: _controlsWrap
        height: root._controlsH
        anchors { bottom: _footerBar.top; left: parent.left; right: parent.right }
        color: root._rail
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }

        // a11y: decorative —— 左侧三档递减条
        Row {
            anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
            spacing: root._unit
            z: NovaTheme.zMarginals
            Rectangle { width: 22; height: 3; radius: 1.5; color: root._ink; opacity: 0.9 }
            Rectangle { width: 12; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
            Rectangle { width: 6; height: 3; radius: 1.5; color: root._inkPale; opacity: 0.9 }
        }
        // a11y: decorative —— 右侧单色渐变短线
        Rectangle {
            anchors { right: parent.right; rightMargin: root._gap; verticalCenter: parent.verticalCenter }
            width: 28; height: 3; radius: 1.5
            color: root._inkSoft
            opacity: 0.9
            z: NovaTheme.zMarginals
        }
        Item {
            id: _controls
            anchors { fill: parent; leftMargin: root._gap * 8; rightMargin: root._gap * 8 }
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
}
