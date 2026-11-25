// examples/layout_shell/chat/main.qml
// NovaChat 独立演示 - 组合宪法 0.4.0 - 全槽位 / 实时调参 / signal 回显 / 明暗切换
// 运行：python examples/layout_shell/chat/run.py
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1280
    height: 800
    minimumWidth: 720
    minimumHeight: 520
    visible: true
    title: "NovaChat - 独立演示（WorkBuddy 桌面端主窗口）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool collapsed: false
    property bool showBars: true
    property int panelSize: 300
    property string lastSignal: "（等待交互）"
    property int signalCount: 0
    function logSignal(msg) {
        win.signalCount = win.signalCount + 1
        win.lastSignal = "#" + win.signalCount + "  " + msg
    }

    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 48
        color: NovaTheme.surface
        Text {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "NovaChat  -  AI 对话主窗口 / 导航轨 + 会话列 + 对话区 + 输入区 + 详情栏"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        NovaBtn {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            icon: NovaTheme.isDark ? "☀" : "🌙"
            variant: "flat"
            onClicked: NovaTheme.toggleDark()
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: params.left }
        Rectangle { anchors.fill: parent; color: NovaTheme.page }

        NovaChat {
            id: shell
            anchors.fill: parent
            navSize: 56
            conversationSize: win.panelSize
            detailSize: win.panelSize
            conversationCollapsed: win.collapsed
            detailCollapsed: win.collapsed
            showNav: win.showBars
            showHeader: win.showBars
            showComposer: win.showBars
            onNavToggled: function(c) { win.logSignal("navToggled(" + c + ")") }
            onConversationToggled: function(c) { win.logSignal("conversationToggled(" + c + ")"); win.collapsed = c }
            onDetailToggled: function(c) { win.logSignal("detailToggled(" + c + ")"); win.collapsed = c }
            navSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "▤"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontL } }
            conversationSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "会话列表（注入业务）"; color: NovaTheme.textMuted } }
            headerSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "当前会话标题"; color: NovaTheme.textColor } }
            contentSlot: Rectangle {
                color: NovaTheme.page
                Column {
                    anchors.centerIn: parent; spacing: NovaTheme.spacingM
                    NovaChatMessage { width: 420; sent: false; name: "Nova"; text: ["你好，我是 Nova。", "这是一个对话主窗口骨架演示。"]; stamp: "10:00" }
                    NovaChatMessage { width: 420; sent: true; text: "收到，槽位由业务注入。"; stamp: "10:01" }
                }
            }
            composerSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "输入框 / 发送按钮 / 工具栏（注入业务）"; color: NovaTheme.textMuted } }
            detailSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "详情 / 上下文 / 引用面板"; color: NovaTheme.textMuted } }
            overlaySlot: Item {}
        }
    }

    Rectangle {
        id: params
        anchors { top: topBar.bottom; bottom: statusBar.top; right: parent.right }
        width: 232
        color: NovaTheme.surface
        NovaSeparator { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } }
        Flickable {
            anchors.fill: parent
            anchors.margins: NovaTheme.spacingM
            contentHeight: paramCol.implicitHeight + NovaTheme.spacingM
            clip: true
            Column {
                id: paramCol
                anchors { top: parent.top; left: parent.left; right: parent.right }
                spacing: NovaTheme.spacingM
                Text { text: "调参面板"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                Text { text: "NovaChat"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "会话列/详情折叠"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.collapsed; onCheckedChanged: win.collapsed = checked }
                }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示导航/Header/输入区"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Column {
                    spacing: 4
                    Text { text: "栏宽 " + win.panelSize; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 200; from: 120; to: 420; stepSize: 20; value: win.panelSize; onValueChanged: win.panelSize = value }
                }
                Text {
                    text: "对话气泡由 NovaChatMessage 真实渲染；主窗口只托管六槽布局。signal 见底部状态栏。"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    Rectangle {
        id: statusBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: NovaTheme.surfaceAlt
        Text {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "signal - " + win.lastSignal
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }
}
