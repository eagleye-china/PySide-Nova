// examples/layout_shell/top_navigation/main.qml
// NovaTopNavigation 独立演示 · 成品级 Showcase：胶囊台 / 悬浮下拉 / 指标看板真实业务注入 · 调参默认收起
// 运行：python examples/layout_shell/top_navigation/run.py
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
    title: "NovaTopNavigation · 数据分析门户（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // 变体态 = 悬浮下拉展开
    property bool paramsOpen: false
    property bool showBars: true
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
            text: "NovaTopNavigation  ·  数据分析门户"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "胶囊导航台 / 悬浮下拉 / 指标看板"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
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

    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaTopNavigation {
            id: shell
            anchors.fill: parent
            showHeader: win.showBars
            showFooter: win.showBars
            menuOpen: win.variantMode
            onMenuToggled: function(o) { win.logSignal("menuToggled(" + o + ")"); win.variantMode = o }

            // ① 胶囊台：品牌 + 四个真实导航位 + 新建报表
            headerSlot: Item {
                anchors.fill: parent
                Rectangle {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    width: 22; height: 22; radius: 11
                    color: NovaTheme.primary
                    Rectangle { anchors.centerIn: parent; width: 8; height: 8; radius: 2; color: NovaTheme.textOnPrimary }
                }
                Text {
                    anchors { left: parent.left; leftMargin: 32; verticalCenter: parent.verticalCenter }
                    text: "Nova Analytics"
                    color: NovaTheme.textColor
                    font { pixelSize: NovaTheme.fontM; bold: true }
                }
                Row {
                    anchors { left: parent.left; leftMargin: 190; verticalCenter: parent.verticalCenter }
                    spacing: 4
                    Repeater {
                        model: ["概览", "报表", "数据源", "自动化"]
                        Rectangle {
                            required property string modelData
                            required property int index
                            width: 84; height: 30; radius: NovaTheme.radiusS
                            color: navArea.containsMouse ? NovaTheme.surfaceAlt : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: index === 0 ? NovaTheme.primary : NovaTheme.textColor
                                font { pixelSize: NovaTheme.fontS; bold: index === 0 }
                            }
                            MouseArea {
                                id: navArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    win.logSignal("navigate(" + modelData + ")")
                                    if (index === 1) win.variantMode = !win.variantMode
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    width: 92; height: 28; radius: 14
                    color: NovaTheme.primary
                    Text { anchors.centerIn: parent; text: "新建报表"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontXS }
                    MouseArea { anchors.fill: parent; onClicked: win.logSignal("createReport()") }
                }
            }

            // ② 悬浮下拉：快捷入口 6 宫格（真实可点击）
            menuSlot: Item {
                anchors.fill: parent
                Text {
                    anchors { left: parent.left; top: parent.top }
                    text: "快捷入口"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                }
                Grid {
                    anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 22 }
                    columns: 3
                    spacing: win._unit
                    Repeater {
                        model: ["销售漏斗", "留存分析", "渠道归因", "实时大屏", "导出中心", "告警规则"]
                        Rectangle {
                            required property string modelData
                            width: (parent.width - win._unit * 2) / 3
                            height: 42
                            radius: NovaTheme.radiusS
                            color: shortArea.containsMouse ? NovaTheme.surfaceAlt : NovaTheme.page
                            border { width: 1; color: NovaTheme.outline }
                            Rectangle {
                                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                width: 14; height: 14; radius: 4
                                color: NovaTheme.primary
                                opacity: 0.9
                            }
                            Text {
                                anchors { left: parent.left; leftMargin: 32; verticalCenter: parent.verticalCenter }
                                text: modelData
                                color: NovaTheme.textColor
                                font.pixelSize: NovaTheme.fontXS
                            }
                            MouseArea {
                                id: shortArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.logSignal("shortcut(" + modelData + ")")
                            }
                        }
                    }
                }
            }

            // ③ 主内容：指标卡 + 柱状趋势 + 数据源列表，限宽居中
            contentSlot: Item {
                anchors.fill: parent
                Item {
                    anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    width: Math.min(parent.width - win._gap * 2, 900)
                    Column {
                        anchors { fill: parent; topMargin: win._gap; leftMargin: win._gap; rightMargin: win._gap }
                        spacing: win._gap
                        Text {
                            text: "业务概览"
                            color: NovaTheme.textColor
                            font { pixelSize: NovaTheme.fontXL; bold: true }
                        }
                        Row {
                            width: parent.width
                            spacing: win._gap
                            Repeater {
                                model: [
                                    { label: "今日活跃", value: "24,861", delta: "+8.2%" },
                                    { label: "转化率", value: "6.48%", delta: "+0.7pt" },
                                    { label: "平均响应", value: "128ms", delta: "-12ms" }
                                ]
                                Rectangle {
                                    required property var modelData
                                    width: (parent.width - win._gap * 2) / 3
                                    height: 88
                                    radius: NovaTheme.radiusM
                                    color: NovaTheme.surface
                                    border { width: 1; color: NovaTheme.outline }
                                    Text {
                                        anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 10 }
                                        text: modelData.label
                                        color: NovaTheme.textMuted
                                        font.pixelSize: NovaTheme.fontXS
                                    }
                                    Text {
                                        anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 32 }
                                        text: modelData.value
                                        color: NovaTheme.textColor
                                        font { pixelSize: NovaTheme.fontL; bold: true }
                                    }
                                    Text {
                                        anchors { right: parent.right; rightMargin: win._gap; bottom: parent.bottom; bottomMargin: 10 }
                                        text: modelData.delta
                                        color: NovaTheme.primary
                                        font.pixelSize: NovaTheme.fontXS
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: parent.width
                            height: 210
                            radius: NovaTheme.radiusM
                            color: NovaTheme.surface
                            border { width: 1; color: NovaTheme.outline }
                            Text {
                                anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 12 }
                                text: "近 12 小时趋势"
                                color: NovaTheme.textColor
                                font { pixelSize: NovaTheme.fontM; bold: true }
                            }
                            Row {
                                anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: win._gap }
                                height: 130
                                spacing: 8
                                Repeater {
                                    model: [42, 55, 48, 70, 62, 84, 76, 92, 68, 88, 96, 80]
                                    Rectangle {
                                        required property int modelData
                                        required property int index
                                        width: (parent.width - 8 * 11) / 12
                                        height: parent.height * modelData / 100
                                        y: parent.height - height
                                        radius: 3
                                        color: index === 10 ? NovaTheme.primary : Qt.lighter(NovaTheme.primary, 1.35)
                                        opacity: 0.9
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: parent.width
                            height: 132
                            radius: NovaTheme.radiusM
                            color: NovaTheme.surface
                            border { width: 1; color: NovaTheme.outline }
                            Text {
                                anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 12 }
                                text: "数据源"
                                color: NovaTheme.textColor
                                font { pixelSize: NovaTheme.fontM; bold: true }
                            }
                            Column {
                                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 42; margins: win._gap }
                                spacing: 8
                                Repeater {
                                    model: [
                                        { n: "prod-events", s: "已连接 · 12.4k / min" },
                                        { n: "warehouse-daily", s: "已连接 · 每日 02:00 同步" },
                                        { n: "crm-snapshot", s: "已连接 · 5 分钟前" }
                                    ]
                                    Row {
                                        required property var modelData
                                        width: parent.width
                                        spacing: win._gap
                                        Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.positive; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: modelData.n; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS; width: 160 }
                                        Text { text: modelData.s; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ④ 状态栏：真实同步态
            footerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.positive }
                    Text { text: "3 个数据源已连接"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "|"; color: NovaTheme.outline; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "最近同步 5 分钟前"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
                Text {
                    anchors { right: parent.right; rightMargin: win._gap; verticalCenter: parent.verticalCenter }
                    text: "时区 UTC+8"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
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
            text: "装配态  ·  胶囊台 / 下拉卡恒定锚链  ·  浅/深双主题  ·  下拉展开变体"
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
                Text { text: "展开下拉"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Row {
                spacing: win._unit
                Text { text: "显示顶/底栏"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
