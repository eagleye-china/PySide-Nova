// src/pyside_nova/qml/Nova/Controls/NovaDataGrid.qml
// NovaDataGrid 企业级数据网格（1.5.0 additive · 第 146 公共类型）
//
// 定位：与已发布的 `NovaTable` 并存，不替换、不改动其冻结签名。
//   - 渲染层：TableView + HorizontalHeaderView + ItemSelectionModel 真虚拟化；
//   - 数据层：Python 侧 QAbstractTableModel 管道（tableModel → filterProxy →
//     pagedProxy + pagination），见 `pyside_nova.datagrid`；
//   - 外观：全部取 Nova.Services.NovaTheme 令牌，不新增主题令牌；
//   - 控件：全部取 Nova.Controls 库组件，零手搓裸控件；
//   - 坑位 32：Qt 6.12 下 reuseItems 与自定义 delegate 组合会触发进程退出段错误，
//     故默认关闭；TableView 仍按可视区创建 delegate（虚拟化不依赖 reuseItems）。
//   - 坑位 70：注入 Python list 在 QML 侧 Array.isArray() 为 false，故所有
//     options 一律用 JS 数组字面量在 QML 内构造。
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import Nova.Controls
import Nova.Behaviors
import Nova.Services

Rectangle {
    id: root

    // ── 可访问性（WCAG 2.1 AA）──────────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.Table
    Accessible.name: a11yLabel
    Accessible.focusable: true
    Accessible.focused: activeFocus
    activeFocusOnTab: true

    // =================== 输入 API ===================
    property var tableModel: null
    property var filterProxy: null
    property var pagedProxy: null
    property var pagination: null
    property bool serverSide: false
    property bool reuseItems: false

    // 列级自定义委托：{ "<colKey>": Component }
    // 委托根对象声明 `property var cellData`，表格自动绑定
    // { value, severity, rowIndex, colKey }；完整行可调用 root.getRowData(rowIndex)。
    property var cellDelegates: ({})

    // =================== 外观 ===================
    property string title: ""
    property bool showToolbar: true
    property bool showFilter: true
    property bool showColumnSelector: true
    property bool showPagination: true
    property bool zebraStripes: true
    property bool bordered: true
    property int rowHeight: 42
    property int headerHeight: 44
    property string searchPlaceholder: qsTr("搜索任意字段...")
    property string selectionMode: "single"    // single / multiple / none

    // =================== 状态 ===================
    property bool loading: false
    property string loadingText: qsTr("加载中...")
    property string noDataText: qsTr("暂无数据")

    // =================== 输出信号 ===================
    signal rowClicked(int row)
    signal rowDoubleClicked(int row)
    signal cellClicked(int row, int column)
    signal cellEdited(int row, int column, var value)
    signal sortRequested(int column, bool ascending)
    signal refreshRequested()
    signal request(var params)
    signal rowContextMenuRequested(int row, real x, real y)

    // =================== 公共只读派生 ===================
    readonly property var columnDefs:
        root.tableModel && root.tableModel.columns ? root.tableModel.columns : []
    readonly property var allColumnDefs:
        root.tableModel && root.tableModel.allColumns ? root.tableModel.allColumns : root.columnDefs

    // =================== 内部状态（`_` 前缀不进冻结面）===================
    readonly property var _model:
        root.pagedProxy ? root.pagedProxy
            : (root.filterProxy ? root.filterProxy : root.tableModel)
    property int _editingRow: -1
    property int _editingColumn: -1
    property var _visibleColumnKeys: []      // 空 = 全部可见
    property string _sortKey: ""
    property bool _sortAsc: true
    property int _selRev: 0
    property int _a11yRow: -1
    property bool _columnMenuOpen: false
    property bool _editError: false
    readonly property var _columnOptions: {
        var out = []
        var defs = root.allColumnDefs
        for (var i = 0; i < defs.length; i++)
            out.push({ label: defs[i].label, value: defs[i].key })
        return out
    }
    readonly property var _pageSizeOptions: [
        { label: "10", value: 10 },
        { label: "20", value: 20 },
        { label: "50", value: 50 },
        { label: "100", value: 100 }
    ]

    radius: NovaTheme.radiusM
    color: NovaTheme.surface
    border.width: root.bordered ? 1 : 0
    border.color: NovaTheme.outline
    implicitWidth: 900
    implicitHeight: 560
    clip: true

    Component.onCompleted: root._syncPaginationTotal()

    // 坑位 72：Qt 6.12 起 Connections 的隐式 `onFoo: …` 语法已 deprecated
    //（运行时会刷 4 条 Qt 消息），必须用标准 `function onFoo() { … }`。
    // 这些 handler 按库内既有惯例（如 NovaClosePopup.onClicked()）进入冻结面。
    Connections {
        target: root.filterProxy
        function onCountChanged() { root._syncPaginationTotal() }
    }
    Connections {
        target: root.tableModel
        function onRowsChanged() { root._syncPaginationTotal() }
    }
    Connections {
        target: tableView.selectionModel
        function onSelectionChanged() { root._selRev++ }
    }
    Connections {
        target: root.pagination
        function onPageSizeChanged() {
            if (!root.pagination)
                return
            if (root.serverSide)
                root._emitServerRequest(root._sortKey, !root._sortAsc, 1)
        }
    }

    // =================== 函数 ===================
    function _syncPaginationTotal() {
        if (root.serverSide)
            return
        if (root.pagination && root.filterProxy)
            root.pagination.setTotal(root.filterProxy.count)
    }

    function sortByKey(colKey, ascending) {
        if (!colKey)
            return
        var visibleIdx = -1
        for (var i = 0; i < root.columnDefs.length; i++) {
            if (root.columnDefs[i].key === colKey) {
                visibleIdx = i
                break
            }
        }
        if (visibleIdx < 0)
            return
        root._sortKey = colKey
        root._sortAsc = ascending
        if (root.serverSide) {
            root._emitServerRequest(colKey, !ascending, 1)
            root.sortRequested(visibleIdx, ascending)
            return
        }
        if (root.filterProxy)
            root.filterProxy.sort(visibleIdx,
                ascending ? Qt.AscendingOrder : Qt.DescendingOrder)
        root.sortRequested(visibleIdx, ascending)
    }

    function _emitServerRequest(sortKey, descending, page) {
        if (!root.serverSide)
            return
        root.request({
            pagination: {
                sortBy: sortKey,
                descending: descending,
                page: page,
                rowsPerPage: root.pagination ? root.pagination.pageSize : 20,
                rowsNumber: root.pagination ? root.pagination.total : 0
            },
            filter: searchInput ? String(searchInput.modelValue) : ""
        })
    }

    function clearSelection() {
        if (tableView.selectionModel)
            tableView.selectionModel.clear()
    }

    function getRowData(rowIndex) {
        return root.tableModel ? root.tableModel.getRow(rowIndex) : ({})
    }

    function _commitEdit(row, column, value) {
        if (!root.tableModel)
            return false
        var ok = root.tableModel.setRawValue(row, column, value)
        if (ok)
            root.cellEdited(row, column, value)
        return ok
    }

    function _submitEdit(value) {
        if (root._editingRow < 0)
            return
        var r = root._editingRow
        var c = root._editingColumn
        if (root._commitEdit(r, c, value)) {
            root._closeEdit()
        } else {
            root._editError = true
            flashTimer.restart()
        }
    }

    function _cancelEdit() {
        root._closeEdit()
    }

    function _closeEdit() {
        root._editingRow = -1
        root._editingColumn = -1
        root._editError = false
    }

    function _applyVisibleColumns(keys) {
        if (!Array.isArray(keys) || keys.length === 0)
            return
        root._visibleColumnKeys = keys
        if (root.tableModel)
            root.tableModel.setVisibleColumns(keys)
    }

    function _allColumnKeys() {
        var out = []
        var defs = root.allColumnDefs
        for (var i = 0; i < defs.length; i++)
            out.push(defs[i].key)
        return out
    }

    // ── 键盘导航 ──────────────────────────────────────────────
    function _a11ySet(i) {
        var n = root._model ? root._model.rowCount() : 0
        if (n === 0)
            return
        root._a11yRow = Math.max(0, Math.min(n - 1, i))
        root.scrollToRow(root._a11yRow)
    }

    function _a11yMove(dir) {
        var n = root._model ? root._model.rowCount() : 0
        if (n === 0)
            return
        if (root._a11yRow < 0) {
            root._a11ySet(dir > 0 ? 0 : n - 1)
            return
        }
        root._a11ySet(root._a11yRow + dir)
    }

    function _a11yActivate() {
        if (root._a11yRow >= 0)
            root.rowClicked(root._a11yRow)
    }

    function _a11yToggle() {
        if (root._a11yRow < 0 || root.selectionMode === "none")
            return
        var sm = tableView.selectionModel
        if (!sm || !tableView.model)
            return
        var idx = tableView.model.index(root._a11yRow, 0)
        if (sm.isSelected(idx))
            sm.select(idx, ItemSelectionModel.Deselect | ItemSelectionModel.Rows)
        else
            sm.select(idx, ItemSelectionModel.Select | ItemSelectionModel.Rows)
    }

    function scrollToRow(row) {
        if (tableView && tableView.visible) {
            var n = root._model ? root._model.rowCount() : 1
            tableView.positionViewAtRow(
                Math.max(0, Math.min(row, n - 1)), TableView.Contain)
        }
    }

    Keys.onPressed: function (ev) {
        if (root._editingRow >= 0)
            return
        var n = root._model ? root._model.rowCount() : 0
        if (n === 0)
            return
        if (ev.key === Qt.Key_Down) root._a11yMove(1)
        else if (ev.key === Qt.Key_Up) root._a11yMove(-1)
        else if (ev.key === Qt.Key_Home) root._a11ySet(0)
        else if (ev.key === Qt.Key_End) root._a11ySet(n - 1)
        else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) root._a11yActivate()
        else if (ev.key === Qt.Key_Space) root._a11yToggle()
        else return
        ev.accepted = true
    }

    // =================== 布局 ===================
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── 工具栏 ────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.showToolbar ? 56 : 0
            color: "transparent"
            // 坑位 71：visible 不可绑定自身 height（初始 0 → 不可见 → Layout 跳过
            // → 永不分配高度的自举死锁），必须绑定到决定高度的上游属性。
            visible: root.showToolbar

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: NovaTheme.spacingM
                anchors.rightMargin: NovaTheme.spacingM
                spacing: NovaTheme.spacingM

                Text {
                    text: root.title
                    visible: text.length > 0
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontL
                    font.bold: true
                    color: NovaTheme.textColor
                }

                Item { Layout.fillWidth: true }

                NovaField {
                    id: searchField
                    visible: root.showFilter
                    Layout.preferredWidth: 220
                    Layout.preferredHeight: 36
                    outlined: true

                    NovaInput {
                        id: searchInput
                        placeholder: root.searchPlaceholder
                        onModelValueChanged: filterDebounce.restart()
                    }
                }

                NovaBtn {
                    id: columnBtn
                    text: qsTr("列")
                    visible: root.showColumnSelector
                    variant: "flat"
                    size: "sm"
                    onClicked: {
                        if (root._visibleColumnKeys.length === 0)
                            root._visibleColumnKeys = root._allColumnKeys()
                        columnMenu.show()
                    }
                }

                NovaBtn {
                    text: qsTr("刷新")
                    variant: "flat"
                    size: "sm"
                    onClicked: root.refreshRequested()
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: NovaTheme.outline
            }
        }

        // ── 表头（排序按 column key，避免列显隐后索引错位）──────
        HorizontalHeaderView {
            id: headerView
            Layout.fillWidth: true
            Layout.preferredHeight: root.headerHeight
            syncView: tableView
            clip: true
            resizableColumns: false

            delegate: Rectangle {
                id: headerCell
                required property int index
                required property string display

                readonly property var hColDef:
                    index < root.columnDefs.length ? root.columnDefs[index] : ({})
                readonly property string colKey:
                    hColDef && hColDef.key ? hColDef.key : ""
                readonly property bool sortable:
                    !!colKey && hColDef.sortable !== false
                readonly property bool sorted:
                    colKey !== "" && colKey === root._sortKey

                implicitHeight: root.headerHeight
                color: headerMa.containsMouse && sortable
                    ? NovaTheme.surfaceAlt : NovaTheme.surface

                MouseArea {
                    id: headerMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: headerCell.sortable
                        ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: headerCell.sortable
                    onClicked: {
                        var asc = headerCell.sorted ? !root._sortAsc : true
                        root.sortByKey(headerCell.colKey, asc)
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 22
                    text: headerCell.display
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontS
                    font.bold: true
                    color: headerCell.sorted ? NovaTheme.primary : NovaTheme.textColor
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: headerCell.sorted ? (root._sortAsc ? "▲" : "▼") : ""
                    font.pixelSize: NovaTheme.fontXS
                    color: NovaTheme.primary
                }

                Rectangle {
                    anchors.right: parent.right
                    width: 1
                    height: parent.height
                    color: NovaTheme.outline
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: NovaTheme.outline
        }

        // ── 表体 ──────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TableView {
                id: tableView
                anchors.fill: parent
                clip: true
                model: root._model
                reuseItems: root.reuseItems

                rowHeightProvider: function (row) { return root.rowHeight }
                columnWidthProvider: function (column) {
                    var cols = root.columnDefs
                    if (column < 0 || column >= cols.length)
                        return 120
                    var w = cols[column].width || 120
                    // 末列吃掉剩余宽度，避免宽视口右侧留大片空白；
                    // 视口不足时回落自身列宽（天然横向滚动）。
                    if (column === cols.length - 1) {
                        var used = 0
                        for (var i = 0; i < cols.length - 1; i++)
                            used += cols[i].width || 120
                        w = Math.max(w, tableView.width - used)
                    }
                    return w
                }

                // Qt 6.12 的 SelectionMode 无 NoSelection 枚举值；
                // "none" 由下方 MouseArea / 键盘路径短路（不写 selectionModel），
                // 语义一致且避免类型系统空转。
                selectionMode: root.selectionMode === "multiple"
                    ? TableView.SelectionMode.ExtendedSelection
                    : TableView.SelectionMode.SingleSelection

                selectionModel: ItemSelectionModel {
                    model: tableView.model
                }

                delegate: Rectangle {
                    id: cell
                    required property int row
                    required property int column
                    required property var display
                    required property int severity
                    required property bool highlighted

                    readonly property var colDef:
                        column < root.columnDefs.length ? root.columnDefs[column] : ({})
                    readonly property bool selected: {
                        root._selRev
                        var sm = tableView.selectionModel
                        if (!sm || !tableView.model)
                            return false
                        return sm.isSelected(tableView.model.index(row, 0))
                    }
                    readonly property bool editing:
                        root._editingRow === row && root._editingColumn === column
                    readonly property bool a11yFocused:
                        root._a11yRow === row && root.activeFocus

                    implicitWidth: colDef.width || 120
                    implicitHeight: root.rowHeight

                    color: a11yFocused
                        ? Qt.rgba(NovaTheme.primary.r, NovaTheme.primary.g,
                                  NovaTheme.primary.b, 0.20)
                        : selected
                            ? Qt.rgba(NovaTheme.primary.r, NovaTheme.primary.g,
                                      NovaTheme.primary.b, 0.12)
                            : highlighted
                                ? Qt.rgba(NovaTheme.primary.r, NovaTheme.primary.g,
                                          NovaTheme.primary.b, 0.10)
                                : severity === 2
                                    ? Qt.rgba(NovaTheme.negative.r, NovaTheme.negative.g,
                                              NovaTheme.negative.b, 0.16)
                                    : severity === 1
                                        ? Qt.rgba(NovaTheme.warning.r, NovaTheme.warning.g,
                                                  NovaTheme.warning.b, 0.16)
                                        : (root.zebraStripes && row % 2 === 1
                                            ? NovaTheme.surfaceAlt : NovaTheme.surface)

                    Behavior on color { ColorAnimation { duration: 180 } }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        text: cell.display !== undefined && cell.display !== null
                            ? String(cell.display) : ""
                        visible: !cellLoader.active && !cell.editing
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontS
                        color: NovaTheme.textColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: cell.colDef.align === "center"
                            ? Text.AlignHCenter
                            : cell.colDef.align === "right"
                                ? Text.AlignRight : Text.AlignLeft
                        elide: Text.ElideRight
                    }

                    // 列级自定义委托（cellData 懒加载，不含完整行）
                    // 用 Binding 元素而非 item.cellData 直接赋值：Loader.item 静态类型是
                    // QObject，qmllint 无法证明自定义属性存在；Binding 走属性名字符串，
                    // 既零告警又保持响应式（value 绑定随 display / severity 自动刷新）。
                    Loader {
                        id: cellLoader
                        anchors.fill: parent
                        active: !!cell.colDef.key
                            && root.cellDelegates[cell.colDef.key] !== undefined
                            && !cell.editing
                        sourceComponent: !!cell.colDef.key
                            ? root.cellDelegates[cell.colDef.key] : undefined
                    }
                    Binding {
                        target: cellLoader.item
                        property: "cellData"
                        when: cellLoader.active && cellLoader.item !== null
                        value: ({
                            value: cell.display,
                            severity: cell.severity,
                            rowIndex: cell.row,
                            colKey: cell.colDef.key
                        })
                    }

                    // 内联编辑器（NovaField + NovaInput，ESC 取消 / 失败红框）
                    Loader {
                        id: editorLoader
                        anchors.fill: parent
                        anchors.margins: 2
                        active: cell.editing && cell.colDef.editable === true
                        sourceComponent: cellEditor
                    }

                    Rectangle {
                        anchors.right: parent.right
                        width: 1
                        height: parent.height
                        color: NovaTheme.outline
                        opacity: 0.4
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: NovaTheme.outline
                        opacity: 0.4
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: function (mouse) {
                            if (mouse.button === Qt.RightButton) {
                                var pt = mapToItem(null, mouse.x, mouse.y)
                                root.rowContextMenuRequested(cell.row, pt.x, pt.y)
                                return
                            }
                            if (root.selectionMode !== "none") {
                                var flags = root.selectionMode === "multiple"
                                    ? (ItemSelectionModel.Select | ItemSelectionModel.Rows)
                                    : (ItemSelectionModel.ClearAndSelect
                                        | ItemSelectionModel.Rows)
                                tableView.selectionModel.select(
                                    tableView.model.index(cell.row, cell.column), flags)
                            }
                            root.cellClicked(cell.row, cell.column)
                            root.rowClicked(cell.row)
                            if (cell.colDef.editable) {
                                root._editingRow = cell.row
                                root._editingColumn = cell.column
                            }
                        }
                        onDoubleClicked: root.rowDoubleClicked(cell.row)
                    }
                }

                ScrollBar.vertical: ScrollBar {}
                ScrollBar.horizontal: ScrollBar {}
            }

            // 空态
            Text {
                anchors.centerIn: parent
                visible: !root.loading
                    && (!root._model || root._model.rowCount() === 0)
                text: root.noDataText
                font.family: NovaTheme.fontFamily
                font.pixelSize: NovaTheme.fontM
                color: NovaTheme.textMuted
            }

            // Loading 覆盖层
            Rectangle {
                anchors.fill: parent
                visible: root.loading
                color: NovaTheme.surface
                opacity: 0.82

                Column {
                    anchors.centerIn: parent
                    spacing: NovaTheme.spacingS

                    NovaSpinner {
                        size: 36
                        tint: NovaTheme.primary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: root.loadingText
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontS
                        color: NovaTheme.textMuted
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // ── 分页 ──────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight:
                (root.showPagination && root.pagination) ? 48 : 0
            color: NovaTheme.surfaceAlt
            // 同坑位 71：按上游属性判定可见性。
            visible: root.showPagination && root.pagination !== null

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: NovaTheme.outline
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: NovaTheme.spacingM
                anchors.rightMargin: NovaTheme.spacingM
                spacing: NovaTheme.spacingM

                Text {
                    text: root.pagination
                        ? (qsTr("第 %1 - %2 条 / 共 %3 条").arg(
                                root.pagination.total === 0
                                    ? 0 : root.pagination.startIndex + 1)
                            .arg(root.pagination.endIndex)
                            .arg(root.pagination.total))
                        : ""
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontXS
                    color: NovaTheme.textMuted
                }

                Item { Layout.fillWidth: true }

                NovaBtnToggle {
                    options: root._pageSizeOptions
                    modelValue: root.pagination ? root.pagination.pageSize : 20
                    outline: true
                    onValueChanged: function (v) {
                        if (root.pagination)
                            root.pagination.setPageSize(v)
                    }
                }

                NovaPagination {
                    page: root.pagination ? root.pagination.currentPage : 1
                    pages: root.pagination ? root.pagination.pageCount : 1
                    maxPages: 5
                    arrows: true
                    boundaryLinks: true
                    onPageRequested: function (p) {
                        if (root.pagination)
                            root.pagination.setCurrentPage(p)
                        if (root.serverSide)
                            root._emitServerRequest(root._sortKey, !root._sortAsc, p)
                    }
                }
            }
        }
    }

    // 搜索防抖
    Timer {
        id: filterDebounce
        interval: 150
        onTriggered: {
            var text = searchInput ? String(searchInput.modelValue) : ""
            if (root.filterProxy && !root.serverSide)
                root.filterProxy.setQuickFilter(text)
            else if (root.serverSide)
                root._emitServerRequest(root._sortKey, !root._sortAsc, 1)
        }
    }

    // 编辑失败红框复位
    Timer {
        id: flashTimer
        interval: 600
        onTriggered: root._editError = false
    }

    // 列选择器（库弹层 + 库多选组）
    NovaMenu {
        id: columnMenu
        width: 230
        target: columnBtn
        autoClose: true
        modelValue: root._columnMenuOpen
        onUpdateModelValue: function (v) { root._columnMenuOpen = v }

        NovaOptionGroup {
            // 固定宽度：绑定 columnMenu.width 会因弹层按内容测宽形成绑定环
            width: 206
            type: "checkbox"
            dense: true
            options: root._columnOptions
            modelValue: root._visibleColumnKeys.length === 0
                ? root._allColumnKeys() : root._visibleColumnKeys
            onValueChanged: function (v) { root._applyVisibleColumns(v) }
        }
    }

    // 内联编辑器组件（text / number / int / select 统一走 NovaInput 的类型）
    Component {
        id: cellEditor
        NovaField {
            id: edField
            width: parent ? parent.width : 120
            height: parent ? parent.height : root.rowHeight
            error: root._editError
            errorMessage: root._editError ? qsTr("提交失败") : ""
            outlined: true

            NovaInput {
                id: edInput
                type: edField._editorType()
                modelValue: root.tableModel
                    ? String(root.tableModel.getRawValue(
                        root._editingRow, root._editingColumn) ?? "")
                    : ""
                onEditingFinished: root._submitEdit(edInput.modelValue)
                onKeyPressed: function (ev) {
                    if (ev.key === Qt.Key_Escape) {
                        root._cancelEdit()
                        ev.accepted = true
                    }
                }
            }

            function _editorType() {
                var c = root._editingColumn
                if (c < 0 || c >= root.columnDefs.length)
                    return "text"
                var ed = root.columnDefs[c].editor
                return (ed === "number" || ed === "int") ? "number" : "text"
            }
        }
    }

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }
}
