// examples/layout_shell/drawer_panel/main.qml
// NovaDrawerPanel 独立演示 · 成品级 Showcase：属性编辑抽屉真实业务注入 / 调参面板默认收起
// 运行：python examples/layout_shell/drawer_panel/run.py
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
    title: "NovaDrawerPanel · 属性编辑（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // 变体态 = 抽屉切换到左侧 + 开启遮罩
    property bool paramsOpen: false
    property bool drawerOpen: true
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
            text: "NovaDrawerPanel  ·  属性编辑"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text { anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter } text: "侧缘轨 / 非模态临时面板 / 受控关闭"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
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

        // 背景业务页：项目详情
        Rectangle {
            anchors.fill: parent
            color: NovaTheme.page
            Column {
                anchors { fill: parent; margins: win._gap * 2 }
                spacing: win._gap
                Text { text: "项目详情"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontXL; bold: true } }
                Text { text: "nova-flagship · 组合根容器工作台"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                Rectangle {
                    width: Math.min(parent.width, 680)
                    height: 220
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border { width: 1; color: NovaTheme.outline }
                    Column {
                        anchors { fill: parent; margins: win._gap }
                        spacing: 10
                        Repeater {
                            model: ["模块：Nova.Composite.LayoutShell", "类型：20 项组合根容器", "指纹：4f882374ad52262b", "状态：天花板 20/20 已销号"]
                            Text { required property string modelData; text: modelData; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                        }
                    }
                }
                Rectangle {
                    width: 148; height: 34; radius: 17
                    color: NovaTheme.primary
                    Text { anchors.centerIn: parent; text: "打开属性面板"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS }
                    MouseArea { anchors.fill: parent; onClicked: win.drawerOpen = true }
                }
            }
        }

        NovaDrawerPanel {
            id: shell
            anchors.fill: parent
            open: win.drawerOpen
            side: win.variantMode ? "left" : "right"
            scrim: win.variantMode
            showActions: true
            onCloseRequested: { win.logSignal("closeRequested()"); win.drawerOpen = false }

            // ① 标题栏：属性编辑
            titleSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    spacing: win._gap
                    Rectangle { width: 9; height: 9; radius: 4.5; color: NovaTheme.primary; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "卡片属性"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                }
                Text { anchors { right: parent.right; verticalCenter: parent.verticalCenter } text: "未保存"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            }

            // ② 内容：真实表单字段
            contentSlot: Item {
                anchors.fill: parent
                Item {
                    anchors { fill: parent; margins: win._gap }
                    Column {
                        anchors.fill: parent
                        spacing: win._gap
                        Repeater {
                            model: [
                                { l: "标题", v: "NovaChat 装配态" },
                                { l: "宽度", v: "520 px" },
                                { l: "高度", v: "420 px" },
                                { l: "圆角", v: "10 px" },
                                { l: "填充", v: "NovaTheme.surface" }
                            ]
                            Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 56
                                radius: NovaTheme.radiusS
                                color: NovaTheme.surfaceAlt
                                border { width: 1; color: NovaTheme.outline }
                                Text { anchors { left: parent.left; leftMargin: 10; top: parent.top; topMargin: 7 } text: modelData.l; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                Text { anchors { left: parent.left; leftMargin: 10; bottom: parent.bottom; bottomMargin: 7 } text: modelData.v; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                            }
                        }
                        Text { text: "不透明度  100%"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                        Slider { width: parent.width; from: 0; to: 100; value: 100 }
                    }
                }
            }

            // ③ 操作栏：真实按钮
            actionsSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle {
                        width: 76; height: 30; radius: NovaTheme.radiusS
                        color: "transparent"
                        border { width: 1; color: NovaTheme.outline }
                        Text { anchors.centerIn: parent; text: "取消"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                        MouseArea { anchors.fill: parent; onClicked: win.drawerOpen = false }
                    }
                    Rectangle {
                        width: 76; height: 30; radius: NovaTheme.radiusS
                        color: NovaTheme.primary
                        Text { anchors.centerIn: parent; text: "保存"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS }
                        MouseArea { anchors.fill: parent; onClicked: { win.logSignal("save()"); win.drawerOpen = false } }
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
        Text { anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL } text: "装配态  ·  侧缘轨单色系 / 栏高归零恒定锚链  ·  浅/深双主题  ·  对侧滑出变体"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
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
                Text { text: "切到左侧 + 遮罩"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Row {
                spacing: win._unit
                Text { text: "显示抽屉"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.drawerOpen; onCheckedChanged: win.drawerOpen = checked }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
