// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaSetupWizard.qml
// NovaSetupWizard 安装配置向导壳：三态步骤时间轴 + 当前步内容 + 上一步/下一步控制区（对标 Quasar QStepper）
// NovaSetupWizard —— 新建工程 / 打包 / 初始化配置向导组合根容器；以"步骤时间轴"为身份语言
// 用法：向 stepsSlot/contentSlot/controlsSlot/footerSlot 注入业务内容；currentStep 受控，Shell 只 emit 导航意图
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

    property alias stepsSlot: _steps.data
    property alias contentSlot: _body.content
    property alias controlsSlot: _controls.data
    property alias footerSlot: _footer.data
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

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _stepsH: Math.max(24, Math.min(root.stepsHeight, 240))
    readonly property int _controlsH: Math.max(24, Math.min(root.controlsHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _nSteps: Math.max(1, Math.min(root.stepCount, 12))
    readonly property int _curStep: Math.max(0, Math.min(root.currentStep, root._nSteps - 1))

    implicitWidth: 900
    implicitHeight: 640

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 身份元素：三态步骤时间轴（连接线 + 圆点：已完成 / 当前 / 待办）──
    // a11y: decorative
    Rectangle {
        id: _stepsWrap
        visible: root.showSteps
        height: root._stepsH
        anchors { top: parent.top; left: parent.left; right: parent.right }
        color: NovaTheme.surface

        // 连接线（贯穿圆点）
        // a11y: decorative
        Rectangle {
            z: 2
            anchors {
                left: parent.left; leftMargin: NovaTheme.spacingL * 2
                right: parent.right; rightMargin: NovaTheme.spacingL * 2
                verticalCenter: parent.verticalCenter
            }
            height: 2
            color: NovaTheme.outline
        }
        // 已完成进度线
        // a11y: decorative
        Rectangle {
            z: 2
            anchors {
                left: parent.left; leftMargin: NovaTheme.spacingL * 2
                verticalCenter: parent.verticalCenter
            }
            width: root._nSteps > 1
                   ? (parent.width - NovaTheme.spacingL * 4) * (root._curStep / Math.max(1, root._nSteps - 1))
                   : 0
            height: 2
            color: NovaTheme.primary
            Behavior on width { NumberAnimation { duration: NovaMotion.duration(NovaMotion.transitionDuration); easing.type: NovaMotion.easingStandard } }
        }

        // 步骤圆点（三态由 currentStep 驱动）
        Row {
            z: 2
            anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            spacing: Math.max(24, (_stepsWrap.width - NovaTheme.spacingL * 6) / root._nSteps)
            Repeater {
                model: root._nSteps
                Rectangle {
                    id: _dot
                    required property int index
                    property bool _done: _dot.index < root._curStep
                    property bool _active: _dot.index === root._curStep
                    width: 18; height: 18; radius: 9
                    color: _dot._done ? NovaTheme.primary
                          : (_dot._active ? NovaTheme.surface : NovaTheme.surfaceAlt)
                    border {
                        width: _dot._done || _dot._active ? 2 : 1
                        color: _dot._done || _dot._active ? NovaTheme.primary : NovaTheme.outline
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        width: 6; height: 6; radius: 3
                        color: _dot._active ? NovaTheme.primary : NovaTheme.textOnPrimary
                        visible: _dot._done || _dot._active
                    }
                }
            }
        }

        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
        // 业务步骤指示器注入层（覆盖在装饰时间轴之上）
        Item { id: _steps; anchors.fill: parent; z: 1 }
    }

    NovaPage {
        id: _body
        anchors {
            top: root.showSteps ? _stepsWrap.bottom : parent.top
            bottom: root.showFooter ? _footer.top : _controlsWrap.top
            left: parent.left; right: parent.right
        }
        padding: NovaTheme.spacingM
    }

    Rectangle {
        id: _controlsWrap
        height: root._controlsH
        anchors { bottom: root.showFooter ? _footer.top : parent.bottom; left: parent.left; right: parent.right }
        color: NovaTheme.surfaceAlt
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }

        // 上一步 / 下一步 按钮位标识（左右两侧，纯装饰）
        // a11y: decorative
        Rectangle {
            anchors { left: parent.left; leftMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            width: 64; height: 28; radius: NovaTheme.radiusS
            color: root.canGoPrevious ? NovaTheme.surface : NovaTheme.surfaceAlt
            border { width: 1; color: root.canGoPrevious ? NovaTheme.outlineStrong : NovaTheme.outline }
            opacity: root.canGoPrevious ? 1 : 0.85
        }
        // a11y: decorative
        Rectangle {
            anchors { right: parent.right; rightMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            width: 64; height: 28; radius: NovaTheme.radiusS
            color: root.canGoNext ? NovaTheme.primary : NovaTheme.surfaceAlt
            opacity: root.canGoNext ? 0.9 : 0.85
        }

        Item { id: _controls; anchors { fill: parent; leftMargin: 96; rightMargin: 96 } }
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root._footerH
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
