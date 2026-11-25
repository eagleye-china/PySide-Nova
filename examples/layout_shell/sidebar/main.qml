// examples/layout_shell/sidebar/main.qml
// NovaSidebar 独立演示 · 成品级 Showcase：五槽真实业务注入 / 调参面板默认收起 / 真实交互位 / 明暗双主题
// 运行：python examples/layout_shell/sidebar/run.py
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
    title: "NovaSidebar · 产品控制台（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // CC-7 三态出图：变体态 = 侧栏折叠
    property bool paramsOpen: false         // CC-8：调参面板与展示区分离，默认收起
    property bool showBars: true
    property int panelSize: 260
    property string lastSignal: "—"
    property int signalCount: 0
    function logSignal(msg) {
        win.signalCount = win.signalCount + 1
        win.lastSignal = "#" + win.signalCount + "  " + msg
    }

    readonly property real _gap: NovaTheme.spacingM
    readonly property real _unit: NovaTheme.spacingS

    // ── 顶部应用条 ──
    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 48
        color: NovaTheme.surface
        z: NovaTheme.zFixedDrawer + 1
        Text {
            id: titleText
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "NovaSidebar  ·  产品控制台"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "导航轨 / 工作区 / 概览 / 状态栏"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        // 主题切换（纯几何日月，零字体依赖）
        Rectangle {
            anchors { right: parent.right; rightMargin: 56; verticalCenter: parent.verticalCenter }
            width: 30; height: 30; radius: 15
            color: NovaTheme.surfaceAlt
            border { width: 1; color: NovaTheme.outline }
            Rectangle {
                anchors.centerIn: parent
                width: 14; height: 14; radius: 7
                color: NovaTheme.isDark ? NovaTheme.warning : NovaTheme.primary
                Rectangle {
                    anchors { right: parent.right; top: parent.top }
                    width: 11; height: 11; radius: 5.5
                    color: NovaTheme.surfaceAlt
                    visible: !NovaTheme.isDark
                }
            }
            MouseArea { anchors.fill: parent; onClicked: NovaTheme.toggleDark() }
        }
        // 调参开关（纯几何三横线）
        Rectangle {
            anchors { right: parent.right; rightMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            width: 30; height: 30; radius: 8
            color: win.paramsOpen ? NovaTheme.primary : NovaTheme.surfaceAlt
            border { width: 1; color: win.paramsOpen ? NovaTheme.primary : NovaTheme.outline }
            Column {
                anchors.centerIn: parent
                spacing: 3
                Repeater {
                    model: 3
                    Rectangle { width: 14; height: 2; radius: 1; color: win.paramsOpen ? NovaTheme.textOnPrimary : NovaTheme.textMuted }
                }
            }
            MouseArea { anchors.fill: parent; onClicked: win.paramsOpen = !win.paramsOpen }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

    // ── 主舞台：五槽真实业务注入 ──
    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaSidebar {
            id: shell
            anchors.fill: parent
            sidebarSize: win.panelSize
            sidebarCollapsed: win.variantMode
            showHeader: win.showBars
            showFooter: win.showBars
            onSidebarToggled: function(c) { win.logSignal("sidebarToggled(" + c + ")"); win.variantMode = c }

            // ① 顶栏：品牌 + 全局搜索（真实交互）+ 账户胶囊
            headerSlot: Item {
                anchors.fill: parent
                Rectangle {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    width: 22; height: 22; radius: 6
                    color: NovaTheme.primary
                    Rectangle { anchors.centerIn: parent; width: 8; height: 8; radius: 2; color: NovaTheme.textOnPrimary }
                }
                Text {
                    anchors { left: parent.left; leftMargin: 32; verticalCenter: parent.verticalCenter }
                    text: "Nova Console"
                    color: NovaTheme.textColor
                    font { pixelSize: NovaTheme.fontM; bold: true }
                }
                Rectangle {
                    id: searchBox
                    anchors { right: accountChip.left; rightMargin: win._gap; verticalCenter: parent.verticalCenter }
                    width: 200; height: 28; radius: 14
                    color: NovaTheme.surfaceAlt
                    border { width: 1; color: searchArea.containsMouse ? NovaTheme.primary : NovaTheme.outline }
                    Rectangle {
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                        width: 8; height: 8; radius: 4
                        color: "transparent"
                        border { width: 1.5; color: NovaTheme.textMuted }
                    }
                    Text {
                        anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
                        text: "搜索工作区 / 项目…"
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                    }
                    MouseArea { id: searchArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("search()") }
                }
                Rectangle {
                    id: accountChip
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    width: 84; height: 28; radius: 14
                    color: NovaTheme.surfaceAlt
                    border { width: 1; color: NovaTheme.outline }
                    Text { anchors.centerIn: parent; text: "CSA · 管理员"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                    MouseArea { anchors.fill: parent; onClicked: win.logSignal("account()") }
                }
            }

            // ② 侧栏：工作区导航树（真实可点击）
            sidebarSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { fill: parent; topMargin: win._unit }
                    spacing: win._unit
                    Text { text: "工作区"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Repeater {
                        model: [
                            { label: "总览", badge: "" },
                            { label: "项目看板", badge: "12" },
                            { label: "数据管道", badge: "3" },
                            { label: "发布记录", badge: "" },
                            { label: "团队成员", badge: "8" }
                        ]
                        Rectangle {
                            required property var modelData
                            required property int index
                            width: parent.width
                            height: 34
                            radius: NovaTheme.radiusS
                            color: navArea.containsMouse ? NovaTheme.surface : "transparent"
                            Rectangle {
                                anchors { left: parent.left; leftMargin: win._unit; verticalCenter: parent.verticalCenter }
                                width: 6; height: 6; radius: 3
                                color: NovaTheme.primary
                            }
                            Text {
                                anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                                text: modelData.label
                                color: NovaTheme.textColor
                                font.pixelSize: NovaTheme.fontS
                            }
                            Text {
                                anchors { right: parent.right; rightMargin: win._unit; verticalCenter: parent.verticalCenter }
                                text: modelData.badge
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                                visible: modelData.badge !== ""
                            }
                            MouseArea {
                                id: navArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.logSignal("navigate(" + modelData.label + ")")
                            }
                        }
                    }
                    Item { width: 1; height: win._unit }
                    Rectangle {
                        width: parent.width
                        height: 56
                        radius: NovaTheme.radiusS
                        color: NovaTheme.surface
                        border { width: 1; color: NovaTheme.outline }
                        Text {
                            anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 9 }
                            text: "当前工作区"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                        }
                        Text {
                            anchors { left: parent.left; leftMargin: win._gap; bottom: parent.bottom; bottomMargin: 9 }
                            text: "nova-flagship / main"
                            color: NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontS
                        }
                    }
                }
            }

            // ③ 主内容：项目概览（KPI 3 张 + 最近活动），限宽居中
            contentSlot: Item {
                anchors.fill: parent
                Item {
                    anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    width: Math.min(parent.width - win._gap * 2, 860)
                    Column {
                        anchors { fill: parent; margins: win._gap }
                        spacing: win._gap
                        Text {
                            text: "总览"
                            color: NovaTheme.textColor
                            font { pixelSize: NovaTheme.fontXL; bold: true }
                        }
                        Text {
                            text: "今天是 2026-11-25，最近一次装配态验收已通过。"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontS
                        }
                        Row {
                            width: parent.width
                            spacing: win._gap
                            Repeater {
                                model: [
                                    { label: "活跃项目", value: "12", delta: "+2" },
                                    { label: "本周交付", value: "38", delta: "+6" },
                                    { label: "门禁通过率", value: "100%", delta: "稳定" }
                                ]
                                Rectangle {
                                    required property var modelData
                                    width: (parent.width - win._gap * 2) / 3
                                    height: 104
                                    radius: NovaTheme.radiusM
                                    color: NovaTheme.surface
                                    border { width: 1; color: NovaTheme.outline }
                                    Text {
                                        anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 12 }
                                        text: modelData.label
                                        color: NovaTheme.textMuted
                                        font.pixelSize: NovaTheme.fontXS
                                    }
                                    Text {
                                        anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 36 }
                                        text: modelData.value
                                        color: NovaTheme.textColor
                                        font { pixelSize: NovaTheme.fontXL; bold: true }
                                    }
                                    Text {
                                        anchors { right: parent.right; rightMargin: win._gap; bottom: parent.bottom; bottomMargin: 12 }
                                        text: modelData.delta
                                        color: NovaTheme.primary
                                        font.pixelSize: NovaTheme.fontXS
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: parent.width
                            height: 220
                            radius: NovaTheme.radiusM
                            color: NovaTheme.surface
                            border { width: 1; color: NovaTheme.outline }
                            Text {
                                anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 12 }
                                text: "最近活动"
                                color: NovaTheme.textColor
                                font { pixelSize: NovaTheme.fontM; bold: true }
                            }
                            Column {
                                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 44; margins: win._gap }
                                spacing: 10
                                Repeater {
                                    model: [
                                        { t: "15:24", s: "CSA 确立「优先组合组件」打磨节奏" },
                                        { t: "15:04", s: "NovaChat 六轨装配态复盘完成" },
                                        { t: "14:52", s: "1.0.0 GA 上架 PyPI" },
                                        { t: "11:30", s: "组合宪法 0.8.1 四性全库回扫通过" }
                                    ]
                                    Row {
                                        required property var modelData
                                        width: parent.width
                                        spacing: win._gap
                                        Rectangle { width: 6; height: 6; radius: 3; color: NovaTheme.primary; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: modelData.t; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: 46 }
                                        Text { text: modelData.s; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ④ 状态栏：真实连接态
            footerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.positive }
                    Text { text: "已连接 · 本地工作区"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "|"; color: NovaTheme.outline; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "UTF-8 · LF · 分支 main"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
                Text {
                    anchors { right: parent.right; rightMargin: win._gap; verticalCenter: parent.verticalCenter }
                    text: "pyside-nova 1.0.0"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                }
            }
        }
    }

    // ── 状态栏（真实状态，非调试字样）──
    Rectangle {
        id: statusBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: NovaTheme.surfaceAlt
        Text {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "装配态  ·  浅/深双主题  ·  侧栏折叠变体  ·  六维天花板验收"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "CARF-R  ·  CC-1~CC-8"
            color: NovaTheme.primary
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }

    // ── 调参浮层（默认收起，与展示区分离 CC-8）──
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
                Text { text: "侧栏折叠"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Row {
                spacing: win._unit
                Text { text: "显示顶/底栏"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
            }
            Column {
                spacing: 4
                Text { text: "侧栏宽度 " + win.panelSize; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                Slider { width: 210; from: 160; to: 380; stepSize: 20; value: win.panelSize; onValueChanged: win.panelSize = value }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
