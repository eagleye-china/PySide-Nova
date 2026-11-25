// examples/layout_shell/card_grid/main.qml
// NovaCardGrid 独立演示 · 成品级 Showcase：模板市场真实业务注入 / 调参面板默认收起
// 运行：python examples/layout_shell/card_grid/run.py
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1200
    height: 780
    minimumWidth: 760
    minimumHeight: 520
    visible: true
    title: "NovaCardGrid · 模板市场（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // 变体态 = 工具条收起 + 大留白 + 4 张卡片
    property bool paramsOpen: false
    property string lastSignal: "—"
    property int signalCount: 0
    function logSignal(msg) {
        win.signalCount = win.signalCount + 1
        win.lastSignal = "#" + win.signalCount + "  " + msg
    }
    readonly property real _gap: NovaTheme.spacingM
    readonly property real _unit: NovaTheme.spacingS
    property var cardModel: [
        { n: "IDE 工作台", c: "桌面端", t: "NovaDesktop" },
        { n: "AI 对话主窗口", c: "AI 客户端", t: "NovaChat" },
        { n: "实时运行看板", c: "工业大屏", t: "NovaFlexLayout" },
        { n: "移动会话页", c: "移动端", t: "NovaMobile" },
        { n: "配置对比", c: "开发工具", t: "NovaCompare" },
        { n: "设计器工作台", c: "创作工具", t: "NovaDualSide" }
    ]

    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 48
        color: NovaTheme.surface
        z: NovaTheme.zFixedDrawer + 1
        Text {
            id: titleText
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "NovaCardGrid  ·  模板市场"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text { anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter } text: "筛选工具条 / 自适应卡片网格 / 分页"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
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

        NovaCardGrid {
            id: shell
            anchors.fill: parent
            showFilter: !win.variantMode
            padding: win.variantMode ? 24 : 12

            // ① 工具条：真实搜索 + 分类标签
            filterSlot: Item {
                anchors.fill: parent
                Rectangle {
                    id: gridSearch
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    width: 260; height: 30; radius: 15
                    color: NovaTheme.surfaceAlt
                    border { width: 1; color: gridSearchArea.containsMouse ? NovaTheme.primary : NovaTheme.outline }
                    Text { anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter } text: "搜索模板 / 组件…"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    MouseArea { id: gridSearchArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("search()") }
                }
                Row {
                    anchors { left: gridSearch.right; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Repeater {
                        model: ["全部", "桌面端", "移动端", "工业大屏"]
                        Rectangle {
                            required property string modelData
                            required property int index
                            width: 76; height: 26; radius: 13
                            color: index === 0 ? NovaTheme.primary : (catArea.containsMouse ? NovaTheme.surfaceAlt : "transparent")
                            border { width: index === 0 ? 0 : 1; color: NovaTheme.outline }
                            Text { anchors.centerIn: parent; text: modelData; color: index === 0 ? NovaTheme.textOnPrimary : NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                            MouseArea { id: catArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("category(" + modelData + ")") }
                        }
                    }
                }
                Text { anchors { right: parent.right; verticalCenter: parent.verticalCenter } text: "共 6 个模板"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            }

            // ② 网格：6 张真实模板卡（变体态 4 张），Flow 自适应
            gridSlot: Item {
                anchors.fill: parent
                Flow {
                    id: gridFlow
                    anchors.fill: parent
                    spacing: win._gap
                    Repeater {
                        model: win.variantMode ? 4 : 6
                        Rectangle {
                            required property int index
                            property var d: win.cardModel[index]
                            width: (gridFlow.width - win._gap * 2) / 3
                            height: 176
                            radius: NovaTheme.radiusM
                            color: NovaTheme.surface
                            border { width: 1; color: cardArea.containsMouse ? NovaTheme.primary : NovaTheme.outline }
                            Rectangle {
                                anchors { left: parent.left; right: parent.right; top: parent.top; margins: win._gap }
                                height: 76
                                radius: NovaTheme.radiusS
                                color: NovaTheme.surfaceAlt
                                Rectangle { anchors { left: parent.left; leftMargin: 12; top: parent.top; topMargin: 14 } width: 46; height: 8; radius: 4; color: NovaTheme.primary; opacity: 0.9 }
                                Rectangle { anchors { left: parent.left; leftMargin: 12; top: parent.top; topMargin: 30 } width: 88; height: 6; radius: 3; color: Qt.lighter(NovaTheme.primary, 1.35); opacity: 0.9 }
                                Rectangle { anchors { left: parent.left; leftMargin: 12; top: parent.top; topMargin: 44 } width: 62; height: 6; radius: 3; color: Qt.lighter(NovaTheme.primary, 1.7); opacity: 0.9 }
                                Rectangle { anchors { right: parent.right; rightMargin: 12; bottom: parent.bottom; bottomMargin: 12 } width: 44; height: 20; radius: 4; color: NovaTheme.primary; opacity: 0.9 }
                            }
                            Text { anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 100 } text: d.n; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                            Text { anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 124 } text: d.c + " · " + d.t; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                            Rectangle {
                                anchors { right: parent.right; rightMargin: win._gap; bottom: parent.bottom; bottomMargin: 12 }
                                width: 58; height: 22; radius: 11
                                color: NovaTheme.surfaceAlt
                                border { width: 1; color: NovaTheme.outline }
                                Text { anchors.centerIn: parent; text: "使用"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                            }
                            MouseArea {
                                id: cardArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.logSignal("use(" + d.n + ")")
                            }
                        }
                    }
                }
            }

            // ③ 状态栏：真实分页
            footerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.positive }
                    Text { text: "模板库已加载 · 6 个模板"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                }
                Row {
                    anchors { right: parent.right; rightMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Text { text: "第 1 / 1 页"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Rectangle {
                        width: 60; height: 24; radius: 12
                        color: pageArea.containsMouse ? NovaTheme.surfaceAlt : "transparent"
                        border { width: 1; color: NovaTheme.outline }
                        Text { anchors.centerIn: parent; text: "下一页"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                        MouseArea { id: pageArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("nextPage()") }
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
        Text { anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL } text: "装配态  ·  工具条栏高归零恒定锚链 / 网格宿主铺满  ·  浅/深双主题  ·  工具条收起变体"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
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
                Text { text: "收起工具条"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
