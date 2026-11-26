// examples/layout_shell/de/main.qml
// NovaDE 独立演示 · 成品级 Showcase：五槽真实业务注入 / 调参面板默认收起 / 真实交互位 / 明暗双主题
// 运行：python examples/layout_shell/de/run.py
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
    title: "NovaDE · 数字员工岗位工作台（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool collapsed: false
    property bool showBars: true
    property bool variantMode: false
    property int panelSize: 280
    property string lastSignal: "（等待交互）"
    property int signalCount: 0
    property bool paramsOpen: false
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
            text: "NovaDE  ·  数字员工岗位工作台"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "岗位条 / 任务队列 / 工作画布 / SLA 轨 / 人工交接"
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

    // ── 主舞台：五槽全部注入真实业务内容 ──
    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaDE {
            id: shell
            anchors.fill: parent
            queueSize: win.panelSize
            slaSize: win.panelSize
            queueCollapsed: win.collapsed || win.variantMode
            slaCollapsed: win.collapsed || win.variantMode
            showQueue: win.showBars && !win.variantMode
            showSla: win.showBars && !win.variantMode
            showRole: win.showBars && !win.variantMode
            showHandoff: win.showBars && !win.variantMode
            onQueueToggled: function(c) { win.logSignal("queueToggled(" + c + ")"); win.collapsed = c }
            onSlaToggled: function(c) { win.logSignal("slaToggled(" + c + ")"); win.collapsed = c }
            onHandoffRequested: win.logSignal("handoffRequested()  ·  人工接管已登记")

            // ① 岗位条：岗位身份 + 岗位 ID + RBAC 角色 + 队伍归属
            roleSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 40; verticalCenter: parent.verticalCenter }
                    spacing: 14
                    Rectangle { width: 8; height: 8; radius: 4; color: NovaTheme.primary; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "应付单据处理"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "岗位 ID  DE-AP-014"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "RBAC 应付会计"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "财务共享中心 · 应付组"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; anchors.verticalCenter: parent.verticalCenter }
                }
            }

            // ② 任务队列：4 条单据（编号 / 金额 / 状态）
            queueSlot: Item {
                anchors.fill: parent
                Column {
                    id: queueList
                    anchors { top: parent.top; topMargin: 44; left: parent.left; right: parent.right }
                    Repeater {
                        model: [
                            { no: "INV-20831", amount: "¥12,400", state: "待处理" },
                            { no: "INV-20832", amount: "¥8,650", state: "匹配中" },
                            { no: "INV-20833", amount: "¥62,000", state: "待复核" },
                            { no: "INV-20834", amount: "¥3,200", state: "已完成" }
                        ]
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: queueList.width
                            height: 62
                            color: index === 0 ? Qt.lighter(NovaTheme.surfaceAlt, 1.08) : "transparent"
                            Rectangle {
                                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                width: 2
                                color: modelData.state === "待复核" ? NovaTheme.warning
                                     : (modelData.state === "匹配中" ? NovaTheme.info : NovaTheme.primary)
                                visible: index <= 2
                            }
                            Column {
                                anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                spacing: 4
                                Text {
                                    text: modelData.no
                                    color: NovaTheme.textColor
                                    font { pixelSize: NovaTheme.fontS; bold: true }
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                                Row {
                                    spacing: 8
                                    Text { text: modelData.amount; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: "·"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: modelData.state; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: win.logSignal("queue(" + index + ")") }
                        }
                    }
                }
            }

            // ③ 工作画布：当前单据处理详情（表格式字段，限宽居中）
            contentSlot: Item {
                anchors.fill: parent
                Flickable {
                    anchors.fill: parent
                    contentHeight: detailCol.implicitHeight + 32
                    Column {
                        id: detailCol
                        anchors { top: parent.top; topMargin: 16; horizontalCenter: parent.horizontalCenter }
                        width: Math.min(parent.width - 24, 720)
                        spacing: 10
                        Repeater {
                            model: [
                                { k: "供应商", v: "华东精密制造有限公司" },
                                { k: "单据金额", v: "¥12,400.00" },
                                { k: "纳税人识别号", v: "91310115MA1K3X8R2Q" },
                                { k: "三单匹配状态", v: "金额一致 · 待验收" }
                            ]
                            Rectangle {
                                required property int index
                                required property var modelData
                                width: detailCol.width
                                height: 64
                                radius: 8
                                color: NovaTheme.surface
                                border { width: 1; color: NovaTheme.outline }
                                Rectangle {
                                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                    width: 3
                                    color: index === 3 ? NovaTheme.positive : NovaTheme.primary
                                }
                                Text {
                                    anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                    text: modelData.k
                                    color: NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontS
                                }
                                Text {
                                    anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                    text: modelData.v
                                    color: NovaTheme.textColor
                                    font { pixelSize: NovaTheme.fontS; bold: true }
                                }
                                MouseArea { anchors.fill: parent; onClicked: win.logSignal("field(" + index + ")") }
                            }
                        }
                    }
                }
            }

            // ④ SLA 轨：4 个治理指标（含纯几何状态点）
            slaSlot: Item {
                anchors.fill: parent
                Column {
                    id: slaList
                    anchors { top: parent.top; topMargin: 44; left: parent.left; right: parent.right }
                    Repeater {
                        model: [
                            { k: "处理时效", v: "92%", ok: true },
                            { k: "准确率", v: "98.6%", ok: true },
                            { k: "队列积压", v: "7", ok: false },
                            { k: "本日完成", v: "43", ok: true }
                        ]
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: slaList.width
                            height: 52
                            color: "transparent"
                            Row {
                                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                                spacing: 10
                                Rectangle {
                                    width: 12; height: 12; radius: 6
                                    color: modelData.ok ? NovaTheme.positive : NovaTheme.warning
                                    Rectangle { anchors.centerIn: parent; width: 4; height: 4; radius: 2; color: NovaTheme.surface }
                                }
                                Column {
                                    spacing: 2
                                    Text { text: modelData.k; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: modelData.v; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: win.logSignal("sla(" + index + ")") }
                        }
                    }
                }
            }

            // ⑤ 人工交接条：边界策略 + 真实受控按钮
            handoffSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 40; verticalCenter: parent.verticalCenter }
                    spacing: 12
                    Rectangle { width: 8; height: 8; radius: 2; color: NovaTheme.warning; rotation: 45; anchors.verticalCenter: parent.verticalCenter }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        Text { text: "边界策略：金额 > ¥50,000 转人工"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                        Text { text: "超限单据自动挂起 · 人工复核后写入审计流"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    }
                }
                Row {
                    anchors { right: parent.right; rightMargin: 24; verticalCenter: parent.verticalCenter }
                    spacing: 10
                    // 令牌驱动自绘按钮：不依赖 QtQuick.Controls 样式（offscreen 下默认按钮会渲染成黑块）
                    Rectangle {
                        width: handoffLabel.implicitWidth + 24; height: 32; radius: 6
                        color: NovaTheme.surfaceAlt
                        border { width: 1; color: NovaTheme.outline }
                        Text { id: handoffLabel; anchors.centerIn: parent; text: "申请交接"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: shell.requestHandoff() }
                    }
                    Rectangle {
                        width: acceptLabel.implicitWidth + 24; height: 32; radius: 6
                        color: NovaTheme.primary
                        Text { id: acceptLabel; anchors.centerIn: parent; text: "确认验收"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.logSignal("handoff(accept)") }
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
                Text { text: "NovaDE · 收起/展开不影响展示"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "队列/SLA 轨折叠"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.collapsed; onCheckedChanged: win.collapsed = checked }
                }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示岗位/队列/SLA/交接"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Column {
                    spacing: 4
                    Text { text: "轨宽 " + win.panelSize; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 240; from: 180; to: 420; stepSize: 20; value: win.panelSize; onValueChanged: win.panelSize = value }
                }
                Text {
                    text: "岗位注册表 / RBAC / SLA 指标由业务槽位注入；Shell 只托管五槽布局与折叠状态。"
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
            Text { text: "数字员工引擎在线  ·  应付单据队列同步中  ·  超限单据待人工接管"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "NovaDE · 1.2.0 · " + (NovaTheme.isDark ? "深色" : "浅色")
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }
}
