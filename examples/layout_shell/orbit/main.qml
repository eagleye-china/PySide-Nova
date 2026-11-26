// examples/layout_shell/orbit/main.qml
// NovaOrbit 独立演示 · 成品级 Showcase：七槽真实业务注入 / 调参面板默认收起 / 真实交互位 / 明暗双主题
// 运行：python examples/layout_shell/orbit/run.py
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    // 主题模式：signature=专属（深底+组件专属色相，默认） / light=亮色（浅底+全局品牌蓝）
    property string themeMode: "signature"
    onThemeModeChanged: NovaTheme.setDark(win.themeMode === "signature")
    function toggleTheme() {
        win.themeMode = (win.themeMode === "signature") ? "light" : "signature"
    }
    width: 1440
    height: 900
    minimumWidth: 960
    minimumHeight: 600
    visible: true
    title: "NovaOrbit · 意图轨道工作台（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: { NovaScreen.source = win; NovaTheme.setDark(win.themeMode === "signature") }

    property bool collapsed: false
    property bool showBars: true
    property bool variantMode: false
    property real railSize: 260
    property real canvasSize: 360
    property string lastSignal: "（等待交互）"
    property int signalCount: 0
    property bool paramsOpen: false
    property int activeOrbit: 0
    property string entity: "NovaAgent"
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
            text: "NovaOrbit  ·  意图轨道工作台"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "轨道态势 / 意图场 / 活产物画布 / 统一编排面"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        Rectangle {
            id: themeBtn
            anchors { right: parent.right; rightMargin: 56; verticalCenter: parent.verticalCenter }
            width: 30; height: 30; radius: 15
            color: NovaTheme.surfaceAlt
            border { width: 1; color: NovaTheme.outline }
            // 主题模式：专属（深底+专属色） / 亮色（浅底+品牌蓝）——点击切换
            Rectangle {
                anchors.centerIn: parent
                width: 14; height: 14; radius: 7
                color: win.themeMode === "signature" ? Qt.lighter(NovaTheme.primary, 1.25) : "transparent"
                border { width: 1; color: win.themeMode === "signature" ? Qt.lighter(NovaTheme.primary, 1.25) : NovaTheme.primary }
                Rectangle {
                    anchors.centerIn: parent
                    width: 6; height: 6; radius: 3
                    color: win.themeMode === "signature" ? NovaTheme.surfaceAlt : NovaTheme.primary
                }
            }
            MouseArea { anchors.fill: parent; onClicked: win.toggleTheme() }
        }
        Rectangle {
            id: paramsBtn
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

    // ── 主舞台：七槽全部注入真实业务内容 ──
    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaOrbit {
            id: shell
            _signatureOn: win.themeMode === "signature"
            anchors.fill: parent
            railSize: win.railSize
            canvasSize: win.canvasSize
            railCollapsed: win.collapsed
            canvasCollapsed: win.collapsed
            showGlobal: win.showBars && !win.variantMode
            showRail: win.showBars && !win.variantMode
            showCanvas: win.showBars && !win.variantMode
            showComposer: win.showBars && !win.variantMode
            showMap: win.showBars && !win.variantMode
            onRailToggled: function(c) { win.logSignal("railToggled(" + c + ")"); win.collapsed = c }
            onCanvasToggled: function(c) { win.logSignal("canvasToggled(" + c + ")"); win.collapsed = c }
            onOrbitRequested: win.logSignal("orbitRequested() · 新建轨道意图已上报")

            // ① 全局栏：NovaChat 基座呈现位（身份 · 租户 · 全局搜索 · 通知）
            globalSlot: Item {
                anchors.fill: parent
                Rectangle {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    width: 10; height: 10; radius: 5
                    color: NovaTheme.primary
                }
                Text {
                    anchors { left: parent.left; leftMargin: 38; verticalCenter: parent.verticalCenter }
                    text: "NovaChat  ·  星海科技 / 企业租户"
                    color: NovaTheme.textColor
                    font { pixelSize: NovaTheme.fontS; bold: true }
                }
                Row {
                    anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 12
                    Rectangle {
                        width: 176; height: 26; radius: 6
                        color: NovaTheme.surfaceAlt
                        border { width: 1; color: NovaTheme.outline }
                        Text {
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            text: "搜索意图 / 轨道 / 产物…"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                        }
                    }
                    Rectangle { width: 8; height: 8; radius: 4; color: NovaTheme.warning; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "3 条待确认"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; anchors.verticalCenter: parent.verticalCenter }
                }
            }

            // ② 左栏 Orbit Rail：活跃轨道 + 感知信号 + 执行实体切换 + 能力召回
            railSlot: Item {
                anchors.fill: parent
                Column {
                    id: railCol
                    anchors { top: parent.top; topMargin: 40; left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16 }
                    spacing: 8
                    Text { text: "活跃轨道 · 4"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Repeater {
                        model: [
                            { name: "季度经营分析", state: "执行中", entity: "NovaAgent", hi: true },
                            { name: "客户合同归档", state: "待确认", entity: "NovaCopilot", hi: false },
                            { name: "供应链周报汇总", state: "已暂停", entity: "NovaDE", hi: false },
                            { name: "弱信号 · 同类周报", state: "感知中", entity: "Orbit", hi: false }
                        ]
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: railCol.width
                            height: 56
                            radius: 6
                            color: modelData.hi ? Qt.lighter(NovaTheme.surfaceAlt, 1.08) : "transparent"
                            Rectangle {
                                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                width: 3
                                color: modelData.hi ? NovaTheme.primary : NovaTheme.outline
                            }
                            Column {
                                anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                spacing: 4
                                Text {
                                    text: modelData.name
                                    color: NovaTheme.textColor
                                    font { pixelSize: NovaTheme.fontS; bold: modelData.hi }
                                    width: parent.width
                                    elide: Text.ElideRight
                                }
                                Row {
                                    spacing: 8
                                    Text { text: modelData.state; color: modelData.hi ? NovaTheme.primary : NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: "·"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: modelData.entity; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: { win.activeOrbit = index; win.logSignal("orbit(" + index + ") · " + modelData.name) } }
                        }
                    }
                    Rectangle { width: railCol.width; height: 1; color: NovaTheme.outline }
                    Text { text: "执行实体 · Entity Router"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Row {
                        spacing: 6
                        Repeater {
                            model: ["NovaAgent", "NovaDE", "NovaCopilot"]
                            Rectangle {
                                required property var modelData
                                width: chipLabel.implicitWidth + 16; height: 24; radius: 6
                                color: win.entity === modelData ? NovaTheme.primary : NovaTheme.surfaceAlt
                                border { width: 1; color: win.entity === modelData ? NovaTheme.primary : NovaTheme.outline }
                                Text {
                                    id: chipLabel
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: win.entity === modelData ? NovaTheme.textOnPrimary : NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontXS
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { win.entity = modelData; win.logSignal("entity(" + modelData + ")") } }
                            }
                        }
                    }
                    Rectangle { width: railCol.width; height: 1; color: NovaTheme.outline }
                    Text { text: "能力召回 · 因意图浮现"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Row {
                        spacing: 6
                        Repeater {
                            model: ["报表解析", "数据源", "审计流"]
                            Rectangle {
                                required property var modelData
                                width: capLabel.implicitWidth + 16; height: 22; radius: 5
                                color: "transparent"
                                border { width: 1; color: NovaTheme.outline }
                                Text { id: capLabel; anchors.centerIn: parent; text: modelData; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.logSignal("recall(" + modelData + ")") }
                            }
                        }
                    }
                }
            }

            // ③ 中栏 Intent Field：多轨道并行意图场（轨道卡取代消息气泡）
            intentSlot: Item {
                anchors.fill: parent
                Flickable {
                    anchors.fill: parent
                    contentHeight: orbitCol.implicitHeight + 24
                    Column {
                        id: orbitCol
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 8 }
                        width: Math.min(parent.width - 16, 720)
                        spacing: 12
                        Repeater {
                            model: [
                                { no: "轨道 A", t: "季度经营分析", s: "执行中", steps: ["解析模板 ✓", "归集 12 源 ⟳", "外部校验 ○", "交付记录 ○"], hi: true },
                                { no: "轨道 B", t: "客户合同归档", s: "待确认", steps: ["字段抽取 ✓", "风险复核 ⟳", "人工闸门 ○"], hi: false },
                                { no: "轨道 C", t: "供应链周报汇总", s: "感知中 · 低置信度", steps: ["弱信号检测 ✓", "孵化提案 ○"], hi: false }
                            ]
                            Rectangle {
                                required property int index
                                required property var modelData
                                width: orbitCol.width
                                height: 116
                                radius: 8
                                color: NovaTheme.surface
                                border { width: 1; color: modelData.hi ? NovaTheme.primary : NovaTheme.outline }
                                Rectangle {
                                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                    width: 3
                                    color: modelData.hi ? NovaTheme.primary : NovaTheme.outline
                                }
                                Column {
                                    anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 12; top: parent.top; topMargin: 10 }
                                    spacing: 8
                                    Row {
                                        spacing: 10
                                        Text { text: modelData.no; color: NovaTheme.primary; font { pixelSize: NovaTheme.fontXS; bold: true } }
                                        Text { text: modelData.t; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                                        Text { text: "· " + modelData.s; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    }
                                    Flow {
                                        width: parent.width
                                        spacing: 8
                                        Repeater {
                                            model: modelData.steps
                                            Rectangle {
                                                required property var modelData
                                                width: stepLabel.implicitWidth + 14; height: 22; radius: 5
                                                color: NovaTheme.surfaceAlt
                                                Text { id: stepLabel; anchors.centerIn: parent; text: modelData; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                                            }
                                        }
                                    }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { win.activeOrbit = index; win.logSignal("orbitCard(" + index + ")") } }
                            }
                        }
                    }
                }
            }

            // ④ 统一意图输入栏：轨道调度器（@轨道 / 技能 / 上下文 + 新建轨道）
            composerSlot: Item {
                id: composerHost
                anchors.fill: parent
                Row {
                    id: composerRow
                    anchors { left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                    spacing: 10
                    Rectangle {
                        width: 72; height: 28; radius: 6
                        color: NovaTheme.surfaceAlt
                        border { width: 1; color: NovaTheme.outline }
                        Text { anchors.centerIn: parent; text: "@轨道 A"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
                    }
                    Rectangle {
                        width: Math.max(160, composerHost.width - 340); height: 28; radius: 6
                        color: NovaTheme.surfaceAlt
                        border { width: 1; color: NovaTheme.outline }
                        Text {
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            text: "把第三步改用报告格式  /  新建意图即创建新轨道…"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                        }
                    }
                    Rectangle {
                        width: newOrbitLabel.implicitWidth + 24; height: 30; radius: 6
                        color: NovaTheme.primary
                        Text { id: newOrbitLabel; anchors.centerIn: parent; text: "新建轨道"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: shell.requestOrbit() }
                    }
                }
            }

            // ⑤ 右栏 Live Canvas：活产物画布（产物即对象，可再入轨）
            canvasSlot: Item {
                anchors.fill: parent
                Column {
                    id: canvasCol
                    anchors { top: parent.top; topMargin: 36; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    spacing: 8
                    Text { text: "活产物 · 可继续这条轨道"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Repeater {
                        model: [
                            { k: "经营分析.pptx", t: "演示文稿", from: "轨道 A" },
                            { k: "数据源清单.xlsx", t: "表格", from: "轨道 A" },
                            { k: "合同风险看板", t: "看板", from: "轨道 B" },
                            { k: "校验会话 #128", t: "终端", from: "轨道 A" }
                        ]
                        Rectangle {
                            required property var modelData
                            width: canvasCol.width
                            height: 58
                            radius: 6
                            color: NovaTheme.surface
                            border { width: 1; color: NovaTheme.outline }
                            Column {
                                anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                spacing: 4
                                Text { text: modelData.k; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } width: parent.width; elide: Text.ElideRight }
                                Row {
                                    spacing: 8
                                    Text { text: modelData.t; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: "· 来自 " + modelData.from; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: "↺ 继续这条轨道"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
                                }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.logSignal("artifact(" + modelData.k + ") · 再入轨") }
                        }
                    }
                }
            }

            // ⑥ 全局轨道地图：拓扑视图（依赖 / 分叉 / 汇合）
            mapSlot: Item {
                anchors.fill: parent
                Text {
                    anchors { left: parent.left; leftMargin: 16; top: parent.top; topMargin: 8 }
                    text: "全局轨道地图 · 3 活跃 / 1 分叉 / 1 汇合"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                }
                Item {
                    anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 32; bottom: parent.bottom; bottomMargin: 8 }
                    Repeater {
                        model: [
                            { x: 24, y: 20, r: 7, c: 2 },
                            { x: 96, y: 20, r: 6, c: 2 },
                            { x: 168, y: 20, r: 5, c: 1 },
                            { x: 96, y: 54, r: 5, c: 1 },
                            { x: 168, y: 54, r: 4, c: 0 }
                        ]
                        Rectangle {
                            required property var modelData
                            x: modelData.x; y: modelData.y
                            width: modelData.r * 2; height: modelData.r * 2; radius: modelData.r
                            color: modelData.c === 2 ? NovaTheme.primary : (modelData.c === 1 ? Qt.lighter(NovaTheme.primary, 1.35) : NovaTheme.outline)
                            border { width: 1; color: NovaTheme.outline }
                        }
                    }
                    Repeater {
                        model: [
                            { x: 38, y: 25, w: 58 },
                            { x: 110, y: 25, w: 58 },
                            { x: 103, y: 27, w: 2 },
                            { x: 110, y: 60, w: 56 }
                        ]
                        Rectangle {
                            required property var modelData
                            x: modelData.x; y: modelData.y
                            width: modelData.w; height: 1
                            color: NovaTheme.outline
                        }
                    }
                }
            }

            // ⑦ 浮层：孵化轨道确认卡由业务注入，壳不自动拉起（O5 硬边界）
            overlaySlot: Item {}
        }

        // ── 调参浮层（默认收起，与展示区隔离）──
        Rectangle {
            id: params
            visible: win.paramsOpen
            anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
            width: 288
            z: NovaTheme.zFixedDrawer
            color: NovaTheme.surface
            border { width: 1; color: NovaTheme.outline }
            Column {
                anchors { fill: parent; margins: NovaTheme.spacingM }
                spacing: NovaTheme.spacingM
                Text { text: "调参面板"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                Text { text: "NovaOrbit · 收起/展开不影响展示"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "折叠左右两栏"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.collapsed; onCheckedChanged: win.collapsed = checked }
                }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示全部栏位"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Column {
                    spacing: 4
                    Text { text: "左栏宽 " + Math.round(win.railSize); color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 240; from: 180; to: 420; stepSize: 20; value: win.railSize; onValueChanged: win.railSize = value }
                }
                Column {
                    spacing: 4
                    Text { text: "右栏宽 " + Math.round(win.canvasSize); color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 240; from: 200; to: 460; stepSize: 20; value: win.canvasSize; onValueChanged: win.canvasSize = value }
                }
                Text {
                    text: "Orbit Engine / Entity Router / 孵化确认闸门由业务槽位注入；Shell 只托管七槽布局。"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                    wrapMode: Text.Wrap
                }
                Text { text: "signal · " + win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
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
            Text { text: "Orbit Engine 在线  ·  Entity Router 就绪  ·  孵化轨道须显式确认方可执行"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "NovaOrbit · 1.2.0 · " + (win.themeMode === "signature" ? "专属" : "亮色")
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }
}
