// examples/controls/datagrid_demo/main.qml
// 铝电解工作站 · NovaDataGrid 大数据量演示主界面。
//
// 全库组件零手搓：NovaBtn / NovaChip / NovaDataGrid + NovaTheme 令牌；
// 颜色一律取 NovaTheme，不新增主题令牌；不使用裸 Button / TextField / Popup。
// plant* 由 main.py 经 setContextProperty 运行时注入，qmllint 静态不可见，
// 故对本文件关闭 unqualified 类别（examples 本不进门禁扫描，仍按「不将就」做到 0 warning）。
// qmllint disable unqualified
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nova.Services
import Nova.Controls

ApplicationWindow {
    id: win
    width: 1440
    height: 900
    minimumWidth: 1100
    minimumHeight: 700
    visible: true
    title: "NovaDataGrid · 铝电解工作站实时监控"
    color: NovaTheme.page

    property string status: "就绪 · 点击表头排序 / 点击槽电压单元格内联编辑 / 试试控制条"

    Component.onCompleted: {
        NovaScreen.source = win
        if (typeof novaIconLocalRoot !== "undefined" && novaIconLocalRoot !== "")
            NovaTheme.iconLocalRoot = novaIconLocalRoot
    }

    // ── 列级自定义委托（cellDelegates 契约：根对象声明 property var cellData）──
    // 状态徽标：severity 决定配色，数值来自 cellData.value。
    Component {
        id: stateBadge
        Item {
            property var cellData: ({ value: "", severity: 0 })
            readonly property color tint:
                cellData.severity === 2 ? NovaTheme.negative
                    : cellData.severity === 1 ? NovaTheme.warning
                    : NovaTheme.positive

            // 外层 Item 由 Loader 撑满单元格；内层留出 7px 做成圆角小徽标，
            // 避免整格铺色（anchors.margins 写在根对象上不生效）。
            Rectangle {
                anchors.fill: parent
                anchors.margins: 7
                radius: NovaTheme.radiusS
                color: Qt.rgba(tint.r, tint.g, tint.b, 0.14)
                border.width: 1
                border.color: Qt.rgba(tint.r, tint.g, tint.b, 0.45)

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

    // 槽电压迷你趋势条：把 3.90~4.60 V 归一化为进度，直观看出偏压槽。
    Component {
        id: voltageBar
        Rectangle {
            property var cellData: ({ value: 0, severity: 0 })
            readonly property real ratio: {
                var v = Number(cellData.value)
                return Math.max(0, Math.min(1, (v - 3.90) / 0.70))
            }
            readonly property color tint:
                cellData.severity === 2 ? NovaTheme.negative
                    : cellData.severity === 1 ? NovaTheme.warning
                    : NovaTheme.primary
            color: "transparent"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                height: 5
                radius: 2
                color: NovaTheme.outline
            }
            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                width: Math.max(2, (parent.width - 20) * parent.ratio)
                height: 5
                radius: 2
                color: parent.tint
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: Number(cellData.value).toFixed(2)
                font.family: NovaTheme.fontFamily
                font.pixelSize: NovaTheme.fontS
                color: NovaTheme.textColor
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: NovaTheme.spacingL
        spacing: NovaTheme.spacingM

        // ── 顶栏 ──────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            radius: NovaTheme.radiusM
            color: NovaTheme.surface
            border.width: 1
            border.color: NovaTheme.outline

            RowLayout {
                anchors.fill: parent
                anchors.margins: NovaTheme.spacingM
                spacing: NovaTheme.spacingM

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        text: "NovaDataGrid · 铝电解工作站实时监控"
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontL
                        font.bold: true
                        color: NovaTheme.textColor
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "TableView 真虚拟化 · Python QAbstractTableModel 管道 · 高频 batchUpdate · pyside-nova 1.6.0"
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontXS
                        color: NovaTheme.textMuted
                    }
                }
                NovaChip {
                    text: plantMeta.rows + " 台槽 · " + plantMeta.columns + " 列"
                    outlined: true
                    dense: true
                }
                NovaChip {
                    text: "每页 " + plantMeta.pageSize + " 槽"
                    outlined: true
                    dense: true
                }
                NovaChip {
                    text: plantStream.running ? "● 采集中" : "○ 已暂停"
                    outlined: true
                    dense: true
                    tint: plantStream.running ? NovaTheme.positive : NovaTheme.textMuted
                }
                NovaBtn {
                    text: NovaTheme.isDark ? "切到亮色" : "切到暗色"
                    variant: "outlined"
                    size: "sm"
                    onClicked: NovaTheme.toggleDark()
                }
            }
        }

        // ── 统计卡片（Python 侧聚合，QML 只读属性，不遍历全表）──
        RowLayout {
            Layout.fillWidth: true
            spacing: NovaTheme.spacingM

            Repeater {
                model: 6
                Rectangle {
                    id: card
                    required property int index
                    Layout.fillWidth: true
                    Layout.preferredHeight: 78
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.width: 1
                    border.color: NovaTheme.outline

                    // 数组字面量是绑定表达式：plantStats.* 变化会重算整个数组，
                    // 进而刷新卡片文字（坑位 70：只在 QML 内构造，不注入 Python list）。
                    readonly property var defs: [
                        { label: "在册槽数", value: plantStats.total + " 台", tint: NovaTheme.primary, hint: "全系列在册" },
                        { label: "槽况正常率", value: plantStats.healthyRate + " %", tint: NovaTheme.positive, hint: "达标槽占比" },
                        { label: "预警槽", value: plantStats.warning + " 台", tint: NovaTheme.warning, hint: "需安排巡检" },
                        { label: "严重槽", value: plantStats.critical + " 台", tint: NovaTheme.negative, hint: "需立即处置" },
                        { label: "平均槽电压", value: plantStats.avgVoltage + " V", tint: NovaTheme.info, hint: "目标 4.16 V" },
                        { label: "平均电解温度", value: plantStats.avgTemp + " °C", tint: NovaTheme.primary, hint: "预警 " + plantMeta.tempWarn + " °C" }
                    ]

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 1
                        width: 4
                        color: card.defs[card.index].tint
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: NovaTheme.spacingL
                        anchors.rightMargin: NovaTheme.spacingM
                        anchors.topMargin: NovaTheme.spacingS
                        anchors.bottomMargin: NovaTheme.spacingS
                        spacing: 1
                        Text {
                            text: card.defs[card.index].label
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontXS
                            color: NovaTheme.textMuted
                        }
                        Text {
                            text: card.defs[card.index].value
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontXL
                            font.bold: true
                            color: NovaTheme.textColor
                        }
                        Text {
                            text: card.defs[card.index].hint
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontXS
                            color: NovaTheme.textMuted
                        }
                    }
                }
            }
        }

        // ── 控制条 ────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            radius: NovaTheme.radiusM
            color: NovaTheme.surface
            border.width: 1
            border.color: NovaTheme.outline

            RowLayout {
                anchors.fill: parent
                anchors.margins: NovaTheme.spacingS
                spacing: NovaTheme.spacingS

                NovaBtn {
                    text: plantStream.running ? "暂停采集" : "继续采集"
                    variant: "outlined"
                    size: "sm"
                    onClicked: plantStream.toggle()
                }
                NovaBtn {
                    text: "仅看预警"
                    variant: "outlined"
                    size: "sm"
                    onClicked: {
                        plantFilter.setQuickFilter("预警")
                        win.status = "全字段过滤：预警"
                    }
                }
                NovaBtn {
                    text: "仅看严重"
                    variant: "outlined"
                    size: "sm"
                    onClicked: {
                        plantFilter.setQuickFilter("严重")
                        win.status = "全字段过滤：严重"
                    }
                }
                NovaBtn {
                    text: "清除过滤"
                    variant: "outlined"
                    size: "sm"
                    onClicked: {
                        plantFilter.clearFilters()
                        win.status = "过滤已清除，回到全量行"
                    }
                }
                NovaBtn {
                    text: "手动刷新一批"
                    variant: "outlined"
                    size: "sm"
                    onClicked: {
                        plantStream.tick()
                        win.status = "手动推送一批增量，batchUpdate 合并 dataChanged"
                    }
                }
                NovaBtn {
                    text: "精简列"
                    variant: "outlined"
                    size: "sm"
                    onClicked: {
                        // 坑位 70：JS 数组字面量在 QML 内构造，不注入 Python list
                        plantTable.setVisibleColumns(["slot", "workshop", "voltage", "temp", "state"])
                        win.status = "列显隐不改数据，排序仍按 column key"
                    }
                }
                NovaBtn {
                    text: "恢复全部列"
                    variant: "outlined"
                    size: "sm"
                    onClicked: {
                        plantTable.setVisibleColumns(["slot", "workshop", "voltage", "current",
                            "temp", "alumina", "ratio", "drop", "effect", "age", "state"])
                        win.status = "已恢复 11 列工艺参数"
                    }
                }
                Item { Layout.fillWidth: true }
                NovaChip {
                    text: "批次 " + plantStream.batchNo
                    outlined: true
                    dense: true
                }
                NovaChip {
                    text: "最近 " + (plantStream.lastSlot === "" ? "—" : plantStream.lastSlot)
                    outlined: true
                    dense: true
                }
            }
        }

        // ── 主表格 ────────────────────────────────────────────
        NovaDataGrid {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "铝电解槽实时工艺参数 · " + plantMeta.rows + " 台"
            searchPlaceholder: "搜索槽号 / 工区 / 状态…"
            tableModel: plantTable
            filterProxy: plantFilter
            pagedProxy: plantPaged
            pagination: plantPages
            rowHeight: 38
            // 列级委托：状态徽标 + 槽电压趋势条
            cellDelegates: ({ "state": stateBadge, "voltage": voltageBar })
            onRowClicked: function (r) {
                win.status = "rowClicked 行 " + r + " · " + JSON.stringify(grid.getRowData(r)).slice(0, 90)
            }
            onRowDoubleClicked: function (r) { win.status = "rowDoubleClicked 行 " + r }
            onCellClicked: function (r, c) { win.status = "cellClicked " + r + "/" + c }
            onCellEdited: function (r, c, v) {
                win.status = "cellEdited " + r + "/" + c + " = " + v + "（已回写模型）"
            }
            onSortRequested: function (c, a) {
                win.status = "sortRequested 列 " + c + " 升序=" + a
            }
            onRowContextMenuRequested: function (r, x, y) {
                win.status = "rowContextMenuRequested 行 " + r + " @ " + Math.round(x) + "," + Math.round(y)
            }
            onRefreshRequested: win.status = "refreshRequested"
        }

        // ── 底栏 ──────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            radius: NovaTheme.radiusS
            color: NovaTheme.surfaceAlt

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: NovaTheme.spacingM
                anchors.rightMargin: NovaTheme.spacingM
                spacing: NovaTheme.spacingM
                Text {
                    Layout.fillWidth: true
                    text: win.status
                    elide: Text.ElideRight
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontXS
                    color: NovaTheme.textMuted
                }
                Text {
                    text: "第 " + plantPages.currentPage + " / " + plantPages.pageCount
                        + " 页 · 共 " + plantPages.total + " 槽"
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontXS
                    color: NovaTheme.textColor
                }
                Text {
                    text: "每 " + plantMeta.interval + " ms / " + plantMeta.batch + " 槽"
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontXS
                    color: NovaTheme.textMuted
                }
            }
        }
    }
}
