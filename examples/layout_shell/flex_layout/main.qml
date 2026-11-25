// examples/layout_shell/flex_layout/main.qml
// NovaFlexLayout 独立演示 · 成品级 Showcase：大屏面板网格真实业务注入 / 调参面板默认收起 / 分栏变体 / 明暗双主题
// 运行：python examples/layout_shell/flex_layout/run.py
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
    title: "NovaFlexLayout · 实时运行看板（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool showBars: true
    property bool variantMode: false      // CARF 复评：三态出图统一变体开关
    property int columnCount: 3
    property bool paramsOpen: false
    property string lastSignal: "（等待交互）"
    property int signalCount: 0
    function logSignal(msg) {
        win.signalCount = win.signalCount + 1
        win.lastSignal = "#" + win.signalCount + "  " + msg
    }

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
            text: "NovaFlexLayout  ·  实时运行看板"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "header / 面板网格 / content / footer"
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

    // ── 主舞台：四槽全部注入真实业务内容 ──
    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaFlexLayout {
            id: shell
            anchors.fill: parent
            columns: win.variantMode ? 2 : win.columnCount
            showHeader: win.showBars && !win.variantMode
            showFooter: win.showBars && !win.variantMode
            onLayoutChanged: function(c) { win.logSignal("layoutChanged(" + c + ")") }

            // ① Header：看板标题 + 实时状态
            headerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
                    spacing: 12
                    Rectangle { width: 10; height: 10; radius: 5; color: NovaTheme.primary; opacity: 0.9; anchors.verticalCenter: parent.verticalCenter }
                    Column {
                        spacing: 3
                        Text { text: "智造中枢 · 实时运行看板"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                        Text { text: "3 条产线 · 127 台设备 · 数据每秒刷新"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    }
                }
                Row {
                    anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                    spacing: 10
                    Rectangle { width: 6; height: 6; radius: 3; color: NovaTheme.positive; opacity: 0.9; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "全部在线"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "15:24:08"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
            }

            // ② Content：三张面板内容（与底层面板网格逐列对齐；业务只注入内容，不另铺不透明底板）
            contentSlot: Item {
                anchors.fill: parent
                Row {
                    anchors.fill: parent
                    spacing: 8
                    Repeater {
                        model: [
                            { title: "产线 A · 综合效率", value: "98.6%", trend: "较昨日 +2.4%", bars: [0.42, 0.58, 0.51, 0.72, 0.66, 0.83, 0.78, 0.94], rows: ["节拍 42.1s", "良率 99.2%", "停机 0 次"] },
                            { title: "设备健康", value: "127 台", trend: "在线 124 · 检修 3", bars: [0.88, 0.91, 0.86, 0.93, 0.90, 0.95, 0.92, 0.97], rows: ["平均负载 61%", "告警 2 条", "上次巡检 09:30"] },
                            { title: "能耗监测", value: "1.24 MWh", trend: "较昨日 −3.1%", bars: [0.72, 0.68, 0.75, 0.61, 0.58, 0.64, 0.55, 0.49], rows: ["峰值 1.82 MW", "谷值 0.71 MW", "碳排 0.42 t"] }
                        ]
                        Item {
                            required property int index
                            required property var modelData
                            // 与底层面板网格逐列对齐；分栏变体时多余卡片隐藏
                            visible: index < win.columnCount
                            width: (parent.width - (win.columnCount - 1) * 8) / win.columnCount
                            height: parent.height
                            Column {
                                anchors { left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16; top: parent.top; topMargin: 18 }
                                spacing: 10
                                Text { text: modelData.title; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                Text { text: modelData.value; color: NovaTheme.textColor; font { pixelSize: 28; bold: true } }
                                Text { text: modelData.trend; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
                                // 迷你柱状图（纯几何，零字体依赖）
                                Row {
                                    width: parent.width
                                    height: 54
                                    spacing: 4
                                    Repeater {
                                        model: modelData.bars
                                        Rectangle {
                                            required property int index
                                            required property real modelData
                                            width: (parent.width - 7 * 4) / 8
                                            height: Math.max(4, parent.height * modelData)
                                            anchors.bottom: parent.bottom
                                            radius: 2
                                            color: index >= 6 ? NovaTheme.primary : Qt.lighter(NovaTheme.primary, 1.5)
                                            opacity: 0.9
                                        }
                                    }
                                }
                                NovaSeparator { width: parent.width }
                                Repeater {
                                    model: modelData.rows
                                    Row {
                                        required property string modelData
                                        width: parent.width
                                        spacing: 8
                                        Rectangle { width: 4; height: 4; radius: 2; color: NovaTheme.primary; opacity: 0.9; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: modelData; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    }
                                }
                                Item { width: 1; height: 12 }
                                Text { text: "时段明细"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                Repeater {
                                    model: ["08:00 — 10:00", "10:00 — 12:00", "12:00 — 14:00", "14:00 — 16:00"]
                                    Row {
                                        required property int index
                                        required property string modelData
                                        width: parent.width
                                        height: 28
                                        spacing: 8
                                        Text { text: modelData; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS; width: 110; anchors.verticalCenter: parent.verticalCenter }
                                        Rectangle {
                                            width: parent.width - 186; height: 6; radius: 3
                                            color: NovaTheme.surfaceAlt
                                            anchors.verticalCenter: parent.verticalCenter
                                            Rectangle {
                                                width: parent.width * (0.55 + index * 0.12)
                                                height: 6; radius: 3
                                                color: NovaTheme.primary
                                                opacity: 0.9
                                            }
                                        }
                                        Text {
                                            text: ["92.1%", "95.4%", "97.8%", "98.6%"][index]
                                            color: NovaTheme.textMuted
                                            font.pixelSize: NovaTheme.fontXS
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ③ Footer：数据源与自适应状态
            footerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
                    spacing: 16
                    Text { text: "数据刷新于 15:24:08"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "3 个数据源"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "延迟 24 ms"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
                Text {
                    anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                    text: "NovaScreen 自适应 · columns = " + win.columnCount
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                }
            }

            overlaySlot: Item {}
        }
    }

    // ── 调参面板：默认收起的浮层，与展示区彻底分离（CC-8）──
    Rectangle {
        id: params
        anchors { top: topBar.bottom; bottom: statusBar.top; right: parent.right }
        width: 232
        visible: win.paramsOpen
        z: NovaTheme.zFixedDrawer
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
                Text { text: "NovaFlexLayout · 收起/展开不影响展示"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示 Header / Footer"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Column {
                    spacing: 4
                    Text { text: "分栏数 " + win.columnCount; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 200; from: 1; to: 4; stepSize: 1; value: win.columnCount; onValueChanged: win.columnCount = value }
                }
                Text {
                    text: "面板网格为底层骨架，业务只注入内容；分栏变化触发 layoutChanged。"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                    wrapMode: Text.Wrap
                }
                Text {
                    text: "signal · " + win.lastSignal
                    color: NovaTheme.primary
                    font.pixelSize: NovaTheme.fontXS
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    // ── 底部状态条 ──
    Rectangle {
        id: statusBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: NovaTheme.surfaceAlt
        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            spacing: 8
            Rectangle { width: 6; height: 6; radius: 3; color: NovaTheme.positive; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: "Showcase  ·  大屏装配态验收  ·  分栏 / 双主题 / 变体态"
                color: NovaTheme.textMuted
                font.pixelSize: NovaTheme.fontXS
            }
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "NovaFlexLayout · 1.0.0 GA · " + (NovaTheme.isDark ? "深色" : "浅色")
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }
}
