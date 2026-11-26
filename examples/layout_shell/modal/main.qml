// examples/layout_shell/modal/main.qml
// NovaModal 独立演示 · 成品级 Showcase：发布确认对话框真实业务注入 / 调参面板默认收起
// 运行：python examples/layout_shell/modal/run.py
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1200
    height: 760
    minimumWidth: 760
    minimumHeight: 500
    visible: true
    title: "NovaModal · 发布确认（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // 变体态 = 标题栏与操作栏收起，内容铺满
    property bool paramsOpen: false
    property bool dialogOpen: true
    property string lastSignal: "—"
    property int signalCount: 0
    function logSignal(msg) {
        win.signalCount = win.signalCount + 1
        win.lastSignal = "#" + win.signalCount + "  " + msg
    }
    readonly property real _gap: NovaTheme.spacingM
    readonly property real _unit: NovaTheme.spacingS

    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 48
        color: NovaTheme.surface
        z: NovaTheme.zFixedDrawer + 1
        Text {
            id: titleText
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "NovaModal  ·  发布确认"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text { anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter } text: "遮罩 / 浮起卡片 / 受控关闭"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
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

        // 背景业务页：项目列表（浮层关闭后可见，验证遮罩透出）
        Rectangle {
            anchors.fill: parent
            color: NovaTheme.page
            Column {
                anchors { fill: parent; margins: win._gap * 2 }
                spacing: win._gap
                Text { text: "发布管理"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontXL; bold: true } }
                Text { text: "当前工作区：nova-flagship / main"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                Repeater {
                    model: [
                        { n: "pyside-nova 1.0.0", s: "已发布 · PyPI" },
                        { n: "组合宪法 1.0.0", s: "待发布 · CARF 立宪" },
                        { n: "天花板档案 15/15", s: "待发布 · 装配态验收" }
                    ]
                    Rectangle {
                        required property var modelData
                        width: Math.min(parent.width, 720)
                        height: 62
                        radius: NovaTheme.radiusM
                        color: NovaTheme.surface
                        border { width: 1; color: NovaTheme.outline }
                        Text { anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 12 } text: modelData.n; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                        Text { anchors { left: parent.left; leftMargin: win._gap; bottom: parent.bottom; bottomMargin: 12 } text: modelData.s; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    }
                }
                Rectangle {
                    width: 168; height: 34; radius: 17
                    color: NovaTheme.primary
                    Text { anchors.centerIn: parent; text: "打开发布确认"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS }
                    MouseArea { anchors.fill: parent; onClicked: win.dialogOpen = true }
                }
            }
        }

        NovaModal {
            id: shell
            anchors.fill: parent
            open: win.dialogOpen
            showTitle: !win.variantMode
            showActions: !win.variantMode
            dismissOnMask: true
            onCloseRequested: function(reason) { win.logSignal("closeRequested(" + reason + ")"); win.dialogOpen = false }

            // ① 标题栏：发布确认
            titleSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    spacing: win._gap
                    Rectangle { width: 10; height: 10; radius: 5; color: NovaTheme.primary; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "确认发布到 PyPI"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                }
                Text { anchors { right: parent.right; verticalCenter: parent.verticalCenter } text: "1.0.0 GA"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            }

            // ② 内容：版本信息 + 变更清单
            contentSlot: Item {
                anchors.fill: parent
                Item {
                    anchors { fill: parent; margins: win._gap }
                    Column {
                        anchors.fill: parent
                        spacing: win._gap
                        Text { text: "即将发布 pyside-nova 1.0.0（GA）"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                        Rectangle {
                            width: parent.width
                            height: 108
                            radius: NovaTheme.radiusS
                            color: NovaTheme.surfaceAlt
                            border { width: 1; color: NovaTheme.outline }
                            Column {
                                anchors { fill: parent; margins: win._gap }
                                spacing: 8
                                Repeater {
                                    model: ["144 公共类型 · 零漂移", "指纹 4f882374ad52262b", "20 项组合根容器 · 天花板 20/20"]
                                    Row {
                                        required property string modelData
                                        spacing: win._gap
                                        Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.positive; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: modelData; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                                    }
                                }
                            }
                        }
                        Text { text: "发布后不可撤销，请确认变更清单已完成复核。"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    }
                }
            }

            // ③ 操作栏：真实按钮（取消 / 确认发布）
            actionsSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle {
                        width: 84; height: 32; radius: NovaTheme.radiusS
                        color: cancelArea.containsMouse ? NovaTheme.surface : "transparent"
                        border { width: 1; color: NovaTheme.outline }
                        Text { anchors.centerIn: parent; text: "取消"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                        MouseArea { id: cancelArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.dialogOpen = false }
                    }
                    Rectangle {
                        width: 112; height: 32; radius: NovaTheme.radiusS
                        color: NovaTheme.primary
                        Text { anchors.centerIn: parent; text: "确认发布"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS }
                        MouseArea { anchors.fill: parent; onClicked: { win.logSignal("publish()"); win.dialogOpen = false } }
                    }
                }
            }
        }
    }

    Rectangle {
        id: statusBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: NovaTheme.surfaceAlt
        Text { anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL } text: "装配态  ·  遮罩功能性半透明 / 栏高归零恒定锚链  ·  浅/深双主题  ·  标题操作栏收起变体"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
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
                Text { text: "收起标题/操作栏"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Row {
                spacing: win._unit
                Text { text: "显示弹窗"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.dialogOpen; onCheckedChanged: win.dialogOpen = checked }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
