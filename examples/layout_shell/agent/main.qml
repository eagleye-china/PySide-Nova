// examples/layout_shell/agent/main.qml
// NovaAgent 独立演示 · 成品级 Showcase：六槽真实业务注入 / 调参面板默认收起 / 真实交互位 / 明暗双主题
// 运行：python examples/layout_shell/agent/run.py
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1280
    height: 800
    minimumWidth: 760
    minimumHeight: 520
    visible: true
    title: "NovaAgent · 智能体任务执行工作台（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool collapsed: false
    property bool showBars: true
    property bool variantMode: false
    property int panelSize: 280
    property string lastSignal: "（等待交互）"
    property int signalCount: 0
    property bool paramsOpen: false
    property int runStep: 2
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
            text: "NovaAgent  ·  智能体任务执行工作台"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "任务列 / 编排画布 / 验证轨 / 审批闸门"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        Rectangle {
            id: themeBtn
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

    // ── 主舞台：六槽全部注入真实业务内容 ──
    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaAgent {
            id: shell
            anchors.fill: parent
            taskSize: win.panelSize
            verifySize: win.panelSize
            taskCollapsed: win.collapsed || win.variantMode
            verifyCollapsed: win.collapsed || win.variantMode
            showTask: win.showBars && !win.variantMode
            showPlan: win.showBars && !win.variantMode
            showApproval: win.showBars && !win.variantMode
            onTaskToggled: function(c) { win.logSignal("taskToggled(" + c + ")"); win.collapsed = c }
            onVerifyToggled: function(c) { win.logSignal("verifyToggled(" + c + ")"); win.collapsed = c }
            onApprovalRequested: win.logSignal("approvalRequested()")

            // ① 任务列：真实任务队列（4 条，含状态与风险级别）
            taskSlot: Item {
                anchors.fill: parent
                Column {
                    id: taskList
                    anchors { top: parent.top; topMargin: 44; left: parent.left; right: parent.right }
                    Repeater {
                        model: [
                            { name: "季度报表归集", risk: "LOW", state: "执行中" },
                            { name: "客户邮件分流", risk: "MED", state: "待审批" },
                            { name: "合同字段抽取", risk: "LOW", state: "已完成" },
                            { name: "生产库写回", risk: "HIGH", state: "闸门" }
                        ]
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: taskList.width
                            height: 62
                            color: index === 0 ? Qt.lighter(NovaTheme.surfaceAlt, 1.08) : "transparent"
                            Rectangle {
                                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                width: 2
                                color: modelData.risk === "HIGH" ? NovaTheme.warning
                                     : (modelData.risk === "MED" ? NovaTheme.info : NovaTheme.primary)
                                visible: index <= 1
                            }
                            Column {
                                anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                spacing: 4
                                Text {
                                    text: modelData.name
                                    color: NovaTheme.textColor
                                    font { pixelSize: NovaTheme.fontS; bold: true }
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                                Row {
                                    spacing: 8
                                    Text { text: modelData.risk; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: "·"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: modelData.state; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: win.logSignal("task(" + index + ")") }
                        }
                    }
                }
            }

            // ② 规划头：任务名 + 步骤计数 + 风险标记
            planSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 40; verticalCenter: parent.verticalCenter }
                    spacing: 12
                    Rectangle { width: 8; height: 8; radius: 4; color: NovaTheme.primary; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "季度报表归集"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "显式 DAG · 步骤 " + win.runStep + "/4"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; anchors.verticalCenter: parent.verticalCenter }
                }
            }

            // ③ 执行画布：DAG 节点流（真实业务呈现，四节点 + 连线）
            contentSlot: Item {
                anchors.fill: parent
                Flickable {
                    anchors.fill: parent
                    contentHeight: dagCol.implicitHeight + 32
                    Column {
                        id: dagCol
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                        width: Math.min(parent.width - 24, 680)
                        spacing: 10
                        Repeater {
                            model: [
                                { n: "01", t: "解析报表模板", s: "已完成", ok: true },
                                { n: "02", t: "归集 12 个数据源", s: "执行中", ok: true },
                                { n: "03", t: "外部信号校验", s: "待验证", ok: false },
                                { n: "04", t: "生成交付记录", s: "待执行", ok: false }
                            ]
                            Rectangle {
                                required property int index
                                required property var modelData
                                width: dagCol.width
                                height: 72
                                radius: 8
                                color: NovaTheme.surface
                                border { width: 1; color: NovaTheme.outline }
                                Rectangle {
                                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                    width: 3
                                    color: modelData.ok ? NovaTheme.primary : NovaTheme.outline
                                }
                                Row {
                                    anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                    spacing: 14
                                    Rectangle {
                                        width: 30; height: 30; radius: 15
                                        color: modelData.ok ? NovaTheme.primary : NovaTheme.surfaceAlt
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.n
                                            color: modelData.ok ? NovaTheme.textOnPrimary : NovaTheme.textMuted
                                            font { pixelSize: NovaTheme.fontXS; bold: true }
                                        }
                                    }
                                    Column {
                                        spacing: 4
                                        Text { text: modelData.t; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                                        Text { text: modelData.s; color: modelData.ok ? NovaTheme.primary : NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    }
                                }
                                MouseArea { anchors.fill: parent; onClicked: { win.runStep = index + 1; win.logSignal("step(" + (index + 1) + ")") } }
                            }
                        }
                    }
                }
            }

            // ④ 审批闸门：HIGH 风险人工复核点（真实提案 + 受控按钮）
            approvalSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 40; verticalCenter: parent.verticalCenter }
                    spacing: 12
                    Rectangle { width: 8; height: 8; radius: 4; color: NovaTheme.warning; anchors.verticalCenter: parent.verticalCenter }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        Text { text: "审批闸门 · 生产库写回"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                        Text { text: "HIGH 风险工具须人工复核 · 审批记录独立写入审计流"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    }
                }
                Row {
                    anchors { right: parent.right; rightMargin: 24; verticalCenter: parent.verticalCenter }
                    spacing: 10
                    // 令牌驱动自绘按钮：不依赖 QtQuick.Controls 样式（offscreen 下默认按钮会渲染成黑块）
                    Rectangle {
                        width: rejectLabel.implicitWidth + 24; height: 32; radius: 6
                        color: NovaTheme.surfaceAlt
                        border { width: 1; color: NovaTheme.outline }
                        Text { id: rejectLabel; anchors.centerIn: parent; text: "拒绝"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.logSignal("approval(reject)") }
                    }
                    Rectangle {
                        width: approveLabel.implicitWidth + 24; height: 32; radius: 6
                        color: NovaTheme.primary
                        Text { id: approveLabel; anchors.centerIn: parent; text: "批准执行"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.logSignal("approval(approve)") }
                    }
                }
            }

            // ⑤ 验证轨：外部信号检查器（独立于 Agent，真实核验项）
            verifySlot: Item {
                anchors.fill: parent
                Column {
                    id: verifyList
                    anchors { top: parent.top; topMargin: 44; left: parent.left; right: parent.right }
                    Repeater {
                        model: [
                            { k: "文件存在且可打开", ok: true },
                            { k: "测试全部通过", ok: true },
                            { k: "记录状态已变更", ok: false },
                            { k: "来源可回溯", ok: true }
                        ]
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: verifyList.width
                            height: 52
                            color: "transparent"
                            Row {
                                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                                spacing: 10
                                Rectangle {
                                    width: 12; height: 12; radius: 6
                                    color: modelData.ok ? NovaTheme.positive : NovaTheme.outline
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.ok ? "✓" : "·"
                                        color: NovaTheme.textOnPrimary
                                        font.pixelSize: 10
                                    }
                                }
                                Text {
                                    text: modelData.k
                                    color: NovaTheme.textColor
                                    font.pixelSize: NovaTheme.fontS
                                    width: verifyList.width - 50
                                    elide: Text.ElideRight
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: win.logSignal("signal(" + index + ")") }
                        }
                    }
                }
            }

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
                Text { text: "NovaAgent · 收起/展开不影响展示"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "任务列/验证轨折叠"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.collapsed; onCheckedChanged: win.collapsed = checked }
                }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示任务/规划/审批"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Column {
                    spacing: 4
                    Text { text: "栏宽 " + win.panelSize; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 240; from: 180; to: 420; stepSize: 20; value: win.panelSize; onValueChanged: win.panelSize = value }
                }
                Text {
                    text: "八项准入控制 / 外部信号验证器由业务槽位注入；Shell 只托管六槽布局。"
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
            Text { text: "编排引擎在线  ·  外部信号校验器独立运行  ·  高风险工具闸门待复核"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "NovaAgent · 1.2.0 · " + (NovaTheme.isDark ? "深色" : "浅色")
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }
}
