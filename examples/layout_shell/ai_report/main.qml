// examples/layout_shell/ai_report/main.qml
// NovaAIReport 成品级 Showcase · 七槽真实业务注入
//   主报表区真实装配 NovaDataGrid（Python QAbstractTableModel 管道 + 真虚拟化）；
//   对标 / 归因 / 预测 / 问数 / 审批语义全部在宿主侧注入，Shell 不持有业务状态。
// 运行：python examples/layout_shell/ai_report/run.py
// report* 由 run.py / pipeline.inject() 经 setContextProperty 注入，qmllint 静态不可见。
// qmllint disable unqualified
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1440
    height: 900
    minimumWidth: 960
    minimumHeight: 600
    visible: true
    title: "NovaAIReport · 铝电解智能报表（NovaDataGrid 真装配 Showcase）"
    color: NovaTheme.page

    property string themeMode: "signature"
    onThemeModeChanged: NovaTheme.setDark(win.themeMode === "signature")
    function toggleTheme() { win.themeMode = (win.themeMode === "signature") ? "light" : "signature" }

    property bool variantMode: false      // CC-8 变体态：收起两轨 + 隐藏分区带
    property bool collapsed: false
    property bool showBars: true
    property real railSize: 300
    property bool paramsOpen: false       // 调参面板默认收起（CC-8）
    property string status: "点表头排序 / 单元格编辑 / 搜索过滤 / 申请审批"

    onVariantModeChanged: {
        win.collapsed = win.variantMode
        win.showBars = !win.variantMode
        win.railSize = win.variantMode ? 180 : 300
    }

    Component.onCompleted: {
        NovaScreen.source = win
        if (typeof novaIconLocalRoot !== "undefined" && novaIconLocalRoot !== "")
            NovaTheme.iconLocalRoot = novaIconLocalRoot
        NovaTheme.setDark(win.themeMode === "signature")
    }

    // ── 状态徽标委托：severity 决定配色（库组件零手搓业务色）──
    Component {
        id: stateBadge
        Item {
            property var cellData: ({ value: "", severity: 0 })
            readonly property color tint:
                cellData.severity === 2 ? NovaTheme.negative
                    : cellData.severity === 1 ? NovaTheme.warning
                    : NovaTheme.positive
            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                radius: NovaTheme.radiusS
                color: Qt.rgba(tint.r, tint.g, tint.b, 0.14)
                border { width: 1; color: Qt.rgba(tint.r, tint.g, tint.b, 0.45) }
                Text {
                    anchors.centerIn: parent
                    text: cellData.value
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontS
                    font.bold: true
                    color: tint
                }
            }
        }
    }

    NovaAIReport {
        id: shell
        anchors.fill: parent
        anchors.margins: 16
        diagnosisSize: win.railSize
        querySize: win.railSize
        diagnosisCollapsed: win.collapsed
        queryCollapsed: win.collapsed
        showBenchmark: win.showBars
        showDiagnosis: win.showBars
        showForecast: win.showBars
        showQuery: win.showBars
        showApproval: win.showBars

        // Shell 只 emit 意图；宿主桥记录，绝不反向写 Shell 状态
        onDiagnosisToggled: function (c) {
            win.collapsed = c
            reportBridge.noteSignal("diagnosisToggled(" + c + ")")
        }
        onQueryToggled: function (c) {
            win.collapsed = c
            reportBridge.noteSignal("queryToggled(" + c + ")")
        }
        onApprovalRequested: function () { reportBridge.requestApproval() }

        // ── 1. 对标带：本厂 / 行业基线 / 先进基线 / 差距 ──
        benchmarkSlot: RowLayout {
            anchors.fill: parent
            anchors.leftMargin: NovaTheme.spacingL
            anchors.rightMargin: NovaTheme.spacingL
            spacing: NovaTheme.spacingM
            Text {
                text: "铝电解智能报表 · 全厂对标"
                color: NovaTheme.textColor
                font.pixelSize: NovaTheme.fontL
                font.bold: true
            }
            NovaChip { text: "本厂 " + reportBridge.avgCE.toFixed(2) + "%"; outlined: true; dense: true; tint: NovaTheme.primary }
            NovaChip { text: "行业基线 93.6%"; outlined: true; dense: true }
            NovaChip {
                text: "先进 94.6% · 差距 " + reportBridge.advancedGap.toFixed(2) + "pt"
                outlined: true; dense: true; tint: NovaTheme.warning
            }
            Item { Layout.fillWidth: true }
            NovaChip { text: reportBridge.total + " 台槽 · " + reportMeta.pageSize + " 行/页"; outlined: true; dense: true }
        }

        // ── 2. 诊断轨：归因七元组（业务注入）──
        diagnosisSlot: ColumnLayout {
            anchors.fill: parent
            spacing: NovaTheme.spacingS
            Text {
                text: "归因诊断 · 偏离槽位"
                color: NovaTheme.textColor
                font.pixelSize: NovaTheme.fontM
                font.bold: true
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 96
                color: NovaTheme.surface
                radius: NovaTheme.radiusM
                border { width: 1; color: NovaTheme.warning }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: NovaTheme.spacingM
                    spacing: 4
                    RowLayout {
                        NovaChip { text: "预警"; dense: true; tint: NovaTheme.warning }
                        Text { text: "极距偏低 → 槽电压分解异常"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    }
                    Text { text: "置信度 0.87 · 模型 v2.3 · 新鲜度 2h"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 96
                color: NovaTheme.surface
                radius: NovaTheme.radiusM
                border { width: 1; color: NovaTheme.negative }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: NovaTheme.spacingM
                    spacing: 4
                    RowLayout {
                        NovaChip { text: "严重"; dense: true; tint: NovaTheme.negative }
                        Text { text: "热平衡累积越界 → 冷槽趋势"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    }
                    Text { text: "严重 " + reportBridge.critical + " 台 · 预警 " + reportBridge.warning + " 台"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
            }
            Item { Layout.fillHeight: true }
            Text {
                text: "机理先验：热平衡 / 电压分解 / 物料平衡（业务注入）"
                color: NovaTheme.textMuted
                font.pixelSize: NovaTheme.fontXS
                wrapMode: Text.Wrap
            }
        }

        // ── 3. 主报表区：真实 NovaDataGrid ──
        reportSlot: Rectangle {
            anchors.fill: parent
            color: NovaTheme.page
            ColumnLayout {
                anchors.fill: parent
                spacing: NovaTheme.spacingS

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    Text {
                        text: "槽位实时报表 · " + reportBridge.total + " 行"
                        color: NovaTheme.textColor
                        font.pixelSize: NovaTheme.fontM
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    NovaBtn {
                        text: "申请审批"
                        variant: "filled"
                        size: "sm"
                        onClicked: shell.requestApproval()
                    }
                }

                NovaDataGrid {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: "电流效率 / 直流电耗 / 效应 · TableView 真虚拟化"
                    searchPlaceholder: "搜索槽号 / 状态…"
                    tableModel: reportTable
                    filterProxy: reportFilter
                    pagedProxy: reportPaged
                    pagination: reportPages
                    rowHeight: 36
                    cellDelegates: ({ "state": stateBadge })
                    onRowClicked: function (r) {
                        win.status = "rowClicked " + r + " · " + JSON.stringify(grid.getRowData(r)).slice(0, 96)
                    }
                    onCellClicked: function (r, c) { win.status = "cellClicked " + r + "/" + c }
                    onCellEdited: function (r, c, v) { win.status = "cellEdited " + r + "/" + c + " = " + v + "（已回写模型）" }
                    onSortRequested: function (c, a) { win.status = "sortRequested 列 " + c + " 升序=" + a }
                    onRefreshRequested: win.status = "refreshRequested"
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    spacing: NovaTheme.spacingM
                    Text {
                        Layout.fillWidth: true
                        text: win.status
                        elide: Text.ElideRight
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                    }
                    Text {
                        text: "第 " + reportPages.currentPage + " / " + reportPages.pageCount + " 页"
                        color: NovaTheme.textColor
                        font.pixelSize: NovaTheme.fontXS
                    }
                }
            }
        }

        // ── 4. 预测区间带 ──
        forecastSlot: RowLayout {
            anchors.fill: parent
            anchors.leftMargin: NovaTheme.spacingL
            anchors.rightMargin: NovaTheme.spacingL
            spacing: NovaTheme.spacingM
            Text { text: "预测 2–8h"; color: NovaTheme.primary; font.bold: true; font.pixelSize: NovaTheme.fontS }
            NovaChip { text: "电流效率 " + (reportBridge.avgCE - 0.6).toFixed(1) + "–" + (reportBridge.avgCE + 0.4).toFixed(1) + "%"; outlined: true; dense: true }
            NovaChip { text: "平均电耗 " + reportBridge.avgDC.toFixed(0) + " kWh/t"; outlined: true; dense: true }
            NovaChip { text: "正常率 " + reportBridge.healthyRate.toFixed(1) + "%"; outlined: true; dense: true; tint: NovaTheme.positive }
            Item { Layout.fillWidth: true }
            Text { text: "模型 v2.3 · 新鲜度 2h"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        }

        // ── 5. 问数轨 ──
        querySlot: ColumnLayout {
            anchors.fill: parent
            spacing: NovaTheme.spacingS
            Text { text: "问数 / 每日早报"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontM; font.bold: true }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: NovaTheme.radiusM
                color: NovaTheme.surface
                border { width: 1; color: NovaTheme.outline }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: NovaTheme.spacingM
                    spacing: 6
                    Text { text: "06:30 早报（规则模板）"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontS; font.bold: true }
                    Text {
                        text: "① 严重 " + reportBridge.critical + " 台，建议立即处置；② 预警 " + reportBridge.warning + " 台，安排巡检；③ 全厂平均电流效率 " + reportBridge.avgCE.toFixed(2) + "%，差距 " + reportBridge.gapCE.toFixed(2) + "pt。"
                        color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; Layout.fillWidth: true
                    }
                    Text { text: "查询逻辑可展开 · 只读账号"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
            }
            NovaBtn {
                text: "问数：为何预警？"
                variant: "flat"
                size: "sm"
                onClicked: reportBridge.noteSignal("query: why-warning")
            }
            NovaBtn {
                text: "仅看严重（过滤管道）"
                variant: "flat"
                size: "sm"
                onClicked: {
                    reportFilter.setQuickFilter("严重")
                    reportBridge.noteSignal("filter: 严重")
                }
            }
            NovaBtn {
                text: "清除过滤"
                variant: "flat"
                size: "sm"
                onClicked: {
                    reportFilter.clearFilters()
                    reportBridge.noteSignal("filter: cleared")
                }
            }
            Item { Layout.fillHeight: true }
        }

        // ── 6. 审批闸门 ──
        approvalSlot: ColumnLayout {
            anchors.fill: parent
            spacing: NovaTheme.spacingS
            Text { text: "审批闸门 · 建议 → 确认 → 回写"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontM; font.bold: true }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 108
                radius: NovaTheme.radiusM
                color: NovaTheme.surface
                border { width: 1; color: NovaTheme.outline }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: NovaTheme.spacingM
                    spacing: 4
                    Text { text: "氟化铝添加建议 +0.8 kg（置信度 0.86）"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS; wrapMode: Text.Wrap }
                    Text { text: "依据：物料平衡 + 历史相似案例 78%"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    RowLayout {
                        NovaBtn { text: "采纳"; variant: "filled"; size: "sm"; onClicked: reportBridge.approve(true) }
                        NovaBtn { text: "驳回"; variant: "flat"; size: "sm"; onClicked: reportBridge.approve(false) }
                    }
                }
            }
            Text { text: reportBridge.approvalLabel; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
            Text { text: "默认人工确认；自动执行属业务层可选扩展"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
        }

        // ── 7. 浮层：人工确认闸门（宿主状态，仅呈现）──
        overlaySlot: Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.32)
            visible: reportBridge.gateOpen
            z: NovaTheme.zFixedDrawer
            Rectangle {
                anchors.centerIn: parent
                width: Math.min(420, parent.width - 48)
                height: 190
                radius: NovaTheme.radiusL
                color: NovaTheme.surface
                border { width: 1; color: NovaTheme.outline }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: NovaTheme.spacingL
                    spacing: NovaTheme.spacingS
                    Text { text: "人工确认闸门"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontL; font.bold: true }
                    Text {
                        text: "建议：对 " + reportBridge.critical + " 台严重槽安排处置并回写工艺参数。Shell 不自动执行。"
                        color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS; wrapMode: Text.Wrap; Layout.fillWidth: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        NovaBtn { text: "取消"; variant: "flat"; size: "sm"; onClicked: reportBridge.closeGate() }
                        NovaBtn {
                            text: "确认并回写"
                            variant: "filled"
                            size: "sm"
                            onClicked: { reportBridge.approve(true); reportBridge.closeGate() }
                        }
                    }
                }
            }
        }
    }

    // ── 调参面板（默认收起，CC-8）──
    NovaBtn {
        anchors { top: parent.top; right: parent.right; topMargin: 8; rightMargin: 8 }
        text: win.paramsOpen ? "收起调参" : "调参"
        variant: "flat"
        size: "sm"
        onClicked: win.paramsOpen = !win.paramsOpen
        z: NovaTheme.zTop
    }
    Rectangle {
        anchors { top: parent.top; right: parent.right; topMargin: 46; rightMargin: 8 }
        width: 250; height: 210; radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border { width: 1; color: NovaTheme.outline }
        visible: win.paramsOpen
        z: NovaTheme.zTop
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: NovaTheme.spacingM
            spacing: NovaTheme.spacingS
            Text { text: "调参 · NovaAIReport"; color: NovaTheme.textColor; font.bold: true; font.pixelSize: NovaTheme.fontS }
            RowLayout {
                Text { text: "折叠双轨"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                Item { Layout.fillWidth: true }
                NovaToggle { modelValue: win.collapsed; onValueChanged: function (v) { win.collapsed = v } }
            }
            RowLayout {
                Text { text: "显示分区"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                Item { Layout.fillWidth: true }
                NovaToggle { modelValue: win.showBars; onValueChanged: function (v) { win.showBars = v } }
            }
            RowLayout {
                Text { text: "变体态"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                Item { Layout.fillWidth: true }
                NovaToggle { modelValue: win.variantMode; onValueChanged: function (v) { win.variantMode = v } }
            }
            RowLayout {
                Text { text: "亮/暗主题"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                Item { Layout.fillWidth: true }
                NovaToggle { modelValue: win.themeMode === "signature"; onValueChanged: function () { win.toggleTheme() } }
            }
            Text {
                text: reportBridge.lastSignal + " · 信号 " + reportBridge.signalCount
                color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS
            }
        }
    }
}
