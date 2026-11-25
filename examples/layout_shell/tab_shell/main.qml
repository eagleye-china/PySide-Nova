// examples/layout_shell/tab_shell/main.qml
// NovaTabShell 独立演示 - 组合宪法 0.2.0 - 全槽位 / 实时调参 / signal 回显 / 明暗切换
// 运行：python examples/layout_shell/tab_shell/run.py
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1080
    height: 720
    minimumWidth: 680
    minimumHeight: 480
    visible: true
    title: "NovaTabShell - 独立演示"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool collapsed: false
    property bool showBars: true
    property int panelSize: 260


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
            text: "NovaTabShell  -  主导航 / 标签页容器"
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

        NovaTabShell {
            id: shell
            anchors.fill: parent
            showTabBar: win.showBars
            showFooter: win.showBars
            onTabActivated: function(i) { win.logSignal("tabActivated(" + i + ")") }
            onTabCloseRequested: function(i) { win.logSignal("tabCloseRequested(" + i + ")") }
            onTabAddRequested: win.logSignal("tabAddRequested()")
            tabBarSlot: Rectangle {
                color: NovaTheme.surface
                Row {
                    anchors.centerIn: parent; spacing: NovaTheme.spacingM
                    NovaBtn { text: "Tab 1"; variant: "flat"; onClicked: shell.tabActivated(0) }
                    NovaBtn { text: "Tab 2"; variant: "flat"; onClicked: shell.tabActivated(1) }
                    NovaBtn { text: "Tab 3"; variant: "flat"; onClicked: shell.tabActivated(2) }
                    NovaBtn { text: "+"; variant: "flat"; onClicked: shell.tabAddRequested() }
                }
            }
            contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaTabShell / contentSlot"; color: NovaTheme.textColor } }
            footerSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "footerSlot"; color: NovaTheme.textMuted } }
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
                Text { text: "NovaTabShell"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示 TabBar"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示 Footer"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Text {
                    text: "槽位已注入可视化占位；交互触发 signal 见底部状态栏。令牌驱动，无业务语义。"
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
