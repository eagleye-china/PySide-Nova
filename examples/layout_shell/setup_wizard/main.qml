// examples/layout_shell/setup_wizard/main.qml
// NovaSetupWizard 独立演示 · 成品级 Showcase：新建工程向导真实业务注入 / 调参面板默认收起
// 运行：python examples/layout_shell/setup_wizard/run.py
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1100
    height: 740
    minimumWidth: 720
    minimumHeight: 500
    visible: true
    title: "NovaSetupWizard · 新建工程（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // 变体态 = 跳到第 3 步 + 显示底栏
    property bool paramsOpen: false
    property int step: 0
    property string lastSignal: "—"
    property int signalCount: 0
    function logSignal(msg) {
        win.signalCount = win.signalCount + 1
        win.lastSignal = "#" + win.signalCount + "  " + msg
    }
    readonly property real _gap: NovaTheme.spacingM
    readonly property real _unit: NovaTheme.spacingS
    readonly property int curStep: win.variantMode ? 2 : win.step

    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 48
        color: NovaTheme.surface
        z: NovaTheme.zFixedDrawer + 1
        Text {
            id: titleText
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "NovaSetupWizard  ·  新建工程"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text { anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter } text: "步骤时间轴 / 表单 / 导航控制"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        Rectangle {
            anchors { right: parent.right; rightMargin: 56; verticalCenter: parent.verticalCenter }
            width: 30; height: 30; radius: 15
            color: NovaTheme.surfaceAlt
            border { width: 1; color: NovaTheme.outline }
            Rectangle {
                anchors.centerIn: parent
                width: 14; height: 14; radius: 7
                color: NovaTheme.isDark ? NovaTheme.warning : NovaTheme.primary
                Rectangle { anchors { right: parent.right; top: parent.top } width: 11; height: 11; radius: 5.5; color: NovaTheme.surfaceAlt; visible: !NovaTheme.isDark }
            }
            MouseArea { anchors.fill: parent; onClicked: NovaTheme.toggleDark() }
        }
        Rectangle {
            anchors { right: parent.right; rightMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            width: 30; height: 30; radius: 8
            color: win.paramsOpen ? NovaTheme.primary : NovaTheme.surfaceAlt
            border { width: 1; color: win.paramsOpen ? NovaTheme.primary : NovaTheme.outline }
            Column {
                anchors.centerIn: parent
                spacing: 3
                Repeater { model: 3; Rectangle { width: 14; height: 2; radius: 1; color: win.paramsOpen ? NovaTheme.textOnPrimary : NovaTheme.textMuted } }
            }
            MouseArea { anchors.fill: parent; onClicked: win.paramsOpen = !win.paramsOpen }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaSetupWizard {
            id: shell
            anchors.fill: parent
            currentStep: win.curStep
            stepCount: 3
            showFooter: win.variantMode
            onPreviousRequested: { win.logSignal("previousRequested()"); if (win.step > 0) win.step = win.step - 1 }
            onNextRequested: { win.logSignal("nextRequested()"); if (win.step < 2) win.step = win.step + 1 }
            onStepSelected: function(i) { win.logSignal("stepSelected(" + i + ")"); win.step = i }

            // ① 步骤指示器：真实可点击标签（提级在装饰时间轴之上，不遮挡圆点）
            stepsSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 5 }
                    spacing: win._gap * 4
                    Repeater {
                        model: ["选择模板", "配置模块", "确认创建"]
                        Rectangle {
                            required property string modelData
                            required property int index
                            width: 96; height: 20
                            color: "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: win.curStep === index ? NovaTheme.primary : NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                            }
                            MouseArea { anchors.fill: parent; onClicked: win.step = index }
                        }
                    }
                }
            }

            // ② 内容：当前步真实表单
            contentSlot: Item {
                anchors.fill: parent
                Item {
                    anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    width: Math.min(parent.width - win._gap * 2, 640)
                    Column {
                        anchors { fill: parent; margins: win._gap }
                        spacing: win._gap
                        Text {
                            text: win.curStep === 0 ? "第 1 步 · 选择模板" : (win.curStep === 1 ? "第 2 步 · 配置模块" : "第 3 步 · 确认创建")
                            color: NovaTheme.textColor
                            font { pixelSize: NovaTheme.fontXL; bold: true }
                        }
                        Text {
                            text: win.curStep === 0 ? "为工程选择一套组合根容器作为起点。" : (win.curStep === 1 ? "勾选需要随工程生成的 QML 模块。" : "复核配置后即可创建工程。")
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontS
                        }
                        Repeater {
                            model: win.curStep === 0
                                ? [{ n: "IDE 工作台", d: "NovaDesktop · 五槽桌面根壳" }, { n: "AI 对话主窗口", d: "NovaChat · 六槽多轨" }, { n: "运行看板", d: "NovaFlexLayout · 分栏网格" }]
                                : (win.curStep === 1
                                    ? [{ n: "Nova.Controls", d: "基础控件 91 项" }, { n: "Nova.Services", d: "令牌与服务 16 项" }, { n: "Composite.LayoutShell", d: "组合根容器 15 项" }]
                                    : [{ n: "工程名称", d: "nova-flagship" }, { n: "目标路径", d: "D:/Projects/nova-flagship" }, { n: "包版本", d: "1.0.0 GA" }])
                            Rectangle {
                                required property var modelData
                                required property int index
                                width: parent.width
                                height: 64
                                radius: NovaTheme.radiusM
                                color: selArea.containsMouse ? NovaTheme.surfaceAlt : NovaTheme.surface
                                border { width: 1; color: index === 0 ? NovaTheme.primary : NovaTheme.outline }
                                Rectangle { anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter } width: 10; height: 10; radius: 5; color: index === 0 ? NovaTheme.primary : NovaTheme.outline }
                                Text { anchors { left: parent.left; leftMargin: 36; top: parent.top; topMargin: 12 } text: modelData.n; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                                Text { anchors { left: parent.left; leftMargin: 36; bottom: parent.bottom; bottomMargin: 12 } text: modelData.d; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                MouseArea { id: selArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("select(" + modelData.n + ")") }
                            }
                        }
                    }
                }
            }

            // ③ 控制区：真实上一步 / 下一步
            controlsSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle {
                        width: 92; height: 32; radius: NovaTheme.radiusS
                        color: "transparent"
                        border { width: 1; color: NovaTheme.outline }
                        Text { anchors.centerIn: parent; text: "上一步"; color: win.curStep > 0 ? NovaTheme.textColor : NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                        MouseArea { anchors.fill: parent; onClicked: { if (win.step > 0) win.step = win.step - 1 } }
                    }
                }
                Row {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle {
                        width: 92; height: 32; radius: NovaTheme.radiusS
                        color: NovaTheme.primary
                        Text { anchors.centerIn: parent; text: win.curStep === 2 ? "创建工程" : "下一步"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS }
                        MouseArea { anchors.fill: parent; onClicked: { if (win.step < 2) win.step = win.step + 1; else win.logSignal("create()") } }
                    }
                }
            }

            // ④ 底栏：真实进度态
            footerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.positive }
                    Text { text: "步骤 " + (win.curStep + 1) + " / 3 · 配置有效"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                }
                Text { anchors { right: parent.right; rightMargin: win._gap; verticalCenter: parent.verticalCenter } text: "预计耗时 < 1 分钟"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            }
        }
    }

    Rectangle {
        id: statusBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: NovaTheme.surfaceAlt
        Text { anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL } text: "装配态  ·  步骤栏栏高归零恒定锚链 / 伪按钮改抽象几何  ·  浅/深双主题  ·  步骤跳转变体"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        Text { anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL } text: "CARF-R  ·  CC-1~CC-8"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }

    Rectangle {
        id: params
        anchors { top: topBar.bottom; bottom: statusBar.top; right: parent.right }
        width: 248
        color: NovaTheme.surface
        border { width: 1; color: NovaTheme.outline }
        visible: win.paramsOpen
        z: NovaTheme.zMenu
        Column {
            anchors { fill: parent; margins: win._gap }
            spacing: win._gap
            Text { text: "调参面板"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
            Row {
                spacing: win._unit
                Text { text: "跳到第 3 步"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
