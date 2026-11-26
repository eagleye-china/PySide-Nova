// examples/layout_shell/copilot/main.qml
// NovaCopilot 独立演示 · 成品级 Showcase：五槽真实业务注入 / 调参面板默认收起 / 真实交互位 / 明暗双主题
// 运行：python examples/layout_shell/copilot/run.py
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
    title: "NovaCopilot · 协作建议与动作闸门（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool collapsed: false
    property bool showBars: true
    property bool variantMode: false
    property int panelSize: 280
    property string lastSignal: "（等待交互）"
    property int signalCount: 0
    property bool paramsOpen: false
    property string currentMode: "Confirm"
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
            text: "NovaCopilot  ·  协作建议与动作闸门"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "建议列 / 内联建议 / 工作画布 / 动作闸门轨"
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

        NovaCopilot {
            id: shell
            anchors.fill: parent
            suggestSize: win.panelSize
            gateSize: win.panelSize
            suggestCollapsed: win.collapsed || win.variantMode
            gateCollapsed: win.collapsed || win.variantMode
            showSuggest: win.showBars && !win.variantMode
            showInline: win.showBars && !win.variantMode
            showGate: win.showBars && !win.variantMode
            onSuggestToggled: function(c) { win.logSignal("suggestToggled(" + c + ")"); win.collapsed = c }
            onGateToggled: function(c) { win.logSignal("gateToggled(" + c + ")"); win.collapsed = c }
            onActionProposed: win.logSignal("actionProposed()")

            // ① 建议列：4 条真实建议（按 grounding 生成，可选中采纳）
            suggestSlot: Item {
                anchors.fill: parent
                Column {
                    id: suggestList
                    anchors { top: parent.top; topMargin: 44; left: parent.left; right: parent.right }
                    Repeater {
                        model: [
                            { t: "补全第三季度数据", d: "按现有口径填充 7–9 月" },
                            { t: "润色摘要段落", d: "压缩背景、突出结论" },
                            { t: "生成对比图表", d: "同比 / 环比双视图" },
                            { t: "检查引用来源", d: "回溯 6 处数据出处" }
                        ]
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: suggestList.width
                            height: 62
                            color: index === 0 ? Qt.lighter(NovaTheme.surfaceAlt, 1.08) : "transparent"
                            Rectangle {
                                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                width: 2
                                color: index === 0 ? NovaTheme.primary : NovaTheme.outline
                                visible: index <= 1
                            }
                            Column {
                                anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                spacing: 4
                                Text {
                                    text: modelData.t
                                    color: NovaTheme.textColor
                                    font { pixelSize: NovaTheme.fontS; bold: true }
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                                Text {
                                    text: modelData.d
                                    color: NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontXS
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: win.logSignal("suggest(" + index + ")") }
                        }
                    }
                }
            }

            // ② 内联建议条：当前工作对象 + grounding 状态 + 模式标签
            inlineSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 40; verticalCenter: parent.verticalCenter }
                    spacing: 12
                    Rectangle { width: 8; height: 8; radius: 4; color: NovaTheme.primary; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: "Q4 市场分析.docx"
                        color: NovaTheme.textColor
                        font { pixelSize: NovaTheme.fontS; bold: true }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "已按你的权限检索企业知识"
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 78; height: 22; radius: 11
                        color: NovaTheme.primary
                        Text {
                            anchors.centerIn: parent
                            text: win.currentMode + " 模式"
                            color: NovaTheme.textOnPrimary
                            font.pixelSize: NovaTheme.fontXS
                        }
                    }
                }
            }

            // ③ 工作画布：正在编辑的文档内容（真实段落 + 高亮建议片段）
            contentSlot: Item {
                anchors.fill: parent
                Flickable {
                    anchors.fill: parent
                    contentHeight: docCol.implicitHeight + 32
                    Column {
                        id: docCol
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                        width: Math.min(parent.width - 24, 720)
                        spacing: 12
                        Text {
                            text: "Q4 市场分析（草稿）"
                            color: NovaTheme.textColor
                            font { pixelSize: NovaTheme.fontM; bold: true }
                            wrapMode: Text.Wrap
                            width: parent.width
                        }
                        Text {
                            text: "本季度营收同比增长 18.6%，主要受企业服务线拉动。华东与华南区域贡献了超过六成的增量，客户续约率保持在较高水平。"
                            color: NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontS
                            wrapMode: Text.Wrap
                            lineHeight: 1.5
                            width: parent.width
                        }
                        Text {
                            text: "从成本侧看，交付人效环比提升 9.2%，但差旅与外包支出仍高于预算。建议在下一季度收紧非必要开支，并优先保障核心项目的交付节奏。"
                            color: NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontS
                            wrapMode: Text.Wrap
                            lineHeight: 1.5
                            width: parent.width
                        }
                        Item {
                            width: parent.width
                            height: hiText.height + 12
                            Rectangle {
                                anchors.fill: parent
                                color: NovaTheme.primary
                                radius: 4
                                opacity: 0.18
                            }
                            Text {
                                id: hiText
                                anchors { left: parent.left; leftMargin: 8; right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "【建议补全】第三季度数据待填充：7 月 3,240 万 / 8 月 3,610 万 / 9 月 3,980 万（来源：企业知识库·经营月报）。"
                                color: NovaTheme.textColor
                                font.pixelSize: NovaTheme.fontS
                                wrapMode: Text.Wrap
                            }
                        }
                        Text {
                            text: "综合判断，全年目标达成概率较高，但需关注四季度需求回落风险与关键人才的保留。"
                            color: NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontS
                            wrapMode: Text.Wrap
                            lineHeight: 1.5
                            width: parent.width
                        }
                    }
                }
            }

            // ④ 动作闸门轨：待确认提案 + 撤销窗口 + 三模状态 + 受控按钮
            gateSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { top: parent.top; topMargin: 44; left: parent.left; right: parent.right; margins: 20 }
                    spacing: 14
                    Text {
                        text: "待确认动作提案"
                        color: NovaTheme.textMuted
                        font { pixelSize: NovaTheme.fontXS; bold: true }
                    }
                    Text {
                        text: "将替换 3 处表述"
                        color: NovaTheme.textColor
                        font { pixelSize: NovaTheme.fontM; bold: true }
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                    Row {
                        spacing: 8
                        Rectangle { width: 8; height: 8; radius: 4; color: NovaTheme.warning; anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            text: "10 分钟内可撤销"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Text {
                        text: "当前模式"
                        color: NovaTheme.textMuted
                        font { pixelSize: NovaTheme.fontXS; bold: true }
                        topPadding: 6
                    }
                    Row {
                        spacing: 6
                        Repeater {
                            model: ["Draft", "Confirm", "Read-Only"]
                            Rectangle {
                                required property int index
                                required property string modelData
                                width: 78; height: 26; radius: 13
                                color: win.currentMode === modelData ? NovaTheme.primary : NovaTheme.surfaceAlt
                                border { width: 1; color: win.currentMode === modelData ? NovaTheme.primary : NovaTheme.outline }
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: win.currentMode === modelData ? NovaTheme.textOnPrimary : NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontXS
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: { win.currentMode = modelData; win.logSignal("mode(" + modelData + ")") }
                                }
                            }
                        }
                    }
                    Row {
                        spacing: 10
                        topPadding: 6
                        // 令牌驱动自绘按钮：不依赖 QtQuick.Controls 样式（offscreen 下默认按钮会渲染成黑块）
                        Rectangle {
                            width: undoLabel.implicitWidth + 24; height: 32; radius: 6
                            color: NovaTheme.surfaceAlt
                            border { width: 1; color: NovaTheme.outline }
                            Text { id: undoLabel; anchors.centerIn: parent; text: "撤销"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.logSignal("action(undo)") }
                        }
                        Rectangle {
                            width: confirmLabel.implicitWidth + 24; height: 32; radius: 6
                            color: NovaTheme.primary
                            Text { id: confirmLabel; anchors.centerIn: parent; text: "确认执行"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: shell.proposeAction() }
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
                Text { text: "NovaCopilot · 收起/展开不影响展示"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "建议/闸门轨折叠"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.collapsed; onCheckedChanged: win.collapsed = checked }
                }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示建议/内联/闸门"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Column {
                    spacing: 4
                    Text { text: "栏宽 " + win.panelSize; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 240; from: 180; to: 420; stepSize: 20; value: win.panelSize; onValueChanged: win.panelSize = value }
                }
                Text {
                    text: "建议—确认—执行契约 / Draft·Confirm·Read-Only 三模由业务槽位注入；Shell 只托管五槽布局。"
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
            Text { text: "协作引擎在线  ·  建议按用户权限 grounding  ·  动作闸门待人确认  ·  10 分钟内可撤销"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "NovaCopilot · 1.2.0 · " + (NovaTheme.isDark ? "深色" : "浅色")
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }
}
