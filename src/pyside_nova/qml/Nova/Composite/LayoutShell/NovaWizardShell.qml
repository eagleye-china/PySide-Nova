// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaWizardShell.qml
// NovaWizardShell 分步向导壳：步骤指示器 + 当前步内容 + 上一步/下一步控制区，内置步骤状态骨架（对标 Quasar QStepper）
// NovaWizardShell —— 新建工程 / 打包 / 初始化配置向导组合根容器
// 用法：向 stepsSlot/contentSlot/controlsSlot/footerSlot 注入业务内容；currentStep 受控，Shell 只 emit 导航意图
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

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

    implicitWidth: 900
    implicitHeight: 640

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    Rectangle {
        id: _stepsWrap
        visible: root.showSteps
        height: root.stepsHeight
        anchors { top: parent.top; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
        Item { id: _steps; anchors.fill: parent }
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
        height: root.controlsHeight
        anchors { bottom: root.showFooter ? _footer.top : parent.bottom; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
        Item { id: _controls; anchors.fill: parent }
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root.footerHeight
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
