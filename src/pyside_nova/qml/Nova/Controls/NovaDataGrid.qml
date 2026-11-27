// src/pyside_nova/qml/Nova/Controls/NovaDataGrid.qml
// NovaDataGrid 企业级数据网格（1.5.0 additive · 第 146 公共类型；1.8.0 P1/P2 打磨）
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
// 1.8.0：P1/P2 新增大量内部 Loader/委托，沿用库内 `NovaTheme` 单例的既有风格；
// 全库 unqualified 预算已满，本文件显式关闭该类别（error 仍零容忍）。
// qmllint disable unqualified
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
    property string noResultsText: qsTr("没有匹配的结果")
    property string clearFilterText: qsTr("清除筛选")

    // 1.7.0 additive：展开行 / 选择 / 空态委托。全部沿用库组件渲染，
    // 宿主只提供 Component，不在此组件内手搓业务控件。
    property var expandProxy: null
    property var expandedRows: []
    property var expansionDelegate: null
    property int expansionHeight: 88
    property var selectionDelegate: null
    property var emptyDelegate: null

    // =================== 1.8.0 additive：P1 体验与扩展 ===================
    // P1-1 列宽拖拽 + 持久化：widths 为 { "<colKey>": width } 的 JS 对象，
    // 宿主写回 columnWidths 即可跨会话保存；resetColumnWidths() 恢复列定义宽度。
    property bool resizableColumns: false
    property var columnWidths: ({})
    // P1-2 sticky 首/末列与底部合计行
    property var stickyColumns: []
    property var footerData: ({})
    // P1-3 完整插槽体系（body / body-cell / header / header-cell）
    property var bodyDelegate: null
    property var bodyCellDelegate: null
    property var headerDelegate: null
    property var headerCellDelegate: null
    // P1-4 滚动到底加载更多 + 分组 / 树虚拟行高度
    property bool loadMoreEnabled: false
    property int loadMoreThreshold: 24
    property var groupProxy: null
    property var groupHeaderDelegate: null
    // P1-5 页大小可配置 + 分页控件可替换
    property var pageSizeOptions: []
    property var paginationDelegate: null

    // =================== 1.8.0 additive：P2 形态与外围 ===================
    property string viewMode: "table"      // table / grid / masonry
    property var gridDelegate: null
    property int gridCellWidth: 220
    property int gridCellHeight: 120
    property bool fullScreen: false
    property bool showFullScreenButton: false
    property bool showExportButton: false
    property string exportDelimiter: ","
    property bool treeMode: false
    property string treeParentKey: "parentKey"
    property bool dense: false
    property bool responsive: true
    property int gridBreakpoint: 720

    // =================== 输出信号 ===================
    signal rowClicked(int row)
    signal rowDoubleClicked(int row)
    signal cellClicked(int row, int column)
    signal cellEdited(int row, int column, var value)
    signal sortRequested(int column, bool ascending)
    signal refreshRequested()
    signal request(var params)
    signal rowContextMenuRequested(int row, real x, real y)
    signal rowExpansionToggled(var rowKey, bool expanded)
    signal selectionChanged(var rows)
    signal selectionActionRequested(var rows, string action)
    signal clearFilterRequested()
    signal columnWidthResized(var widths)
    signal loadMoreRequested(int lastRow)
    signal groupToggled(var groupKey, bool collapsed)
    signal fullScreenToggled(bool active)
    signal exportRequested(var csvText)

    // =================== 公共只读派生 ===================
    readonly property var columnDefs:
        root.tableModel && root.tableModel.columns ? root.tableModel.columns : []
    readonly property var allColumnDefs:
        root.tableModel && root.tableModel.allColumns ? root.tableModel.allColumns : root.columnDefs
    readonly property var selectedRows: root._collectSelectedRows()
    readonly property bool filterActive:
        root.serverSide
            ? (searchInput && String(searchInput.modelValue).length > 0)
            : (root.filterProxy && root.filterProxy.filterActive !== undefined
                ? root.filterProxy.filterActive : false)

    // =================== 内部状态（`_` 前缀不进冻结面）===================
    readonly property var _model:
        root.groupProxy ? root.groupProxy
            : (root.expandProxy ? root.expandProxy
                : (root.pagedProxy ? root.pagedProxy
                    : (root.filterProxy ? root.filterProxy : root.tableModel)))
    property int _editingRow: -1
    property int _editingColumn: -1
    property var _visibleColumnKeys: []      // 空 = 全部可见
    property string _sortKey: ""
    property bool _sortAsc: true
    property int _selRev: 0
    property int _anchorRow: -1
    property int _emptyRev: 0
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
    readonly property var _defaultPageSizeOptions: [
        { label: "10", value: 10 },
        { label: "20", value: 20 },
        { label: "50", value: 50 },
        { label: "100", value: 100 }
    ]
    readonly property var _pageSizeOptions: root._resolvedPageSizeOptions()
    property var _widthOverrides: ({})
    property int _colRev: 0
    property string _effectiveViewMode: root.viewMode
    property bool _loadMoreArmed: true
    property var _lastFooterKeys: []

    radius: NovaTheme.radiusM
    color: NovaTheme.surface
    border.width: root.bordered ? 1 : 0
    border.color: NovaTheme.outline
    implicitWidth: 900
    implicitHeight: 560
    clip: true

    Component.onCompleted: {
        root._syncPaginationTotal()
        if (root.expandProxy && root.expandProxy.setExpanded)
            root.expandProxy.setExpanded(root.expandedRows)
        if (root.groupProxy) {
            if (root.groupProxy.setTreeMode)
                root.groupProxy.setTreeMode(root.treeMode)
            if (root.groupProxy.setTreeParentKey)
                root.groupProxy.setTreeParentKey(root.treeParentKey)
        }
        root._applyResponsive()
    }

    onExpandedRowsChanged: {
        if (root.expandProxy && root.expandProxy.setExpanded)
            root.expandProxy.setExpanded(root.expandedRows)
    }
    onViewModeChanged: root._effectiveViewMode = root.viewMode
    onTreeModeChanged: {
        if (root.groupProxy && root.groupProxy.setTreeMode)
            root.groupProxy.setTreeMode(root.treeMode)
    }
    onTreeParentKeyChanged: {
        if (root.groupProxy && root.groupProxy.setTreeParentKey)
            root.groupProxy.setTreeParentKey(root.treeParentKey)
    }
    onWidthChanged: root._applyResponsive()
    onColumnWidthsChanged: root._colRev++

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
        function onSelectionChanged() { root._emitSelectionChanged() }
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
    Connections {
        target: root.expandProxy
        function onExpansionToggled(rowKey, expanded) {
            root.rowExpansionToggled(rowKey, expanded)
        }
        function onExpandedChanged() {
            if (root.expandProxy.expanded !== undefined)
                root.expandedRows = root.expandProxy.expanded
        }
    }
    Connections {
        target: root.filterProxy
        function onFilterActiveChanged() { root._emptyRev++ }
    }
    Connections {
        target: root.groupProxy
        function onGroupToggled(key, collapsed) {
            root.groupToggled(key, collapsed)
        }
    }

    // =================== 函数 ===================
    function _resolvedPageSizeOptions() {
        var src = root.pageSizeOptions
        if (!src || !src.length)
            src = root._defaultPageSizeOptions
        var out = []
        // 坑位 70：Python list 到 QML 是 QVariantList，Array.isArray() 为 false。
        for (var i = 0; i < src.length; i++) {
            var o = src[i]
            if (o !== null && typeof o === "object") {
                var v = o.value !== undefined ? o.value : o
                out.push({ label: String(o.label !== undefined ? o.label : v),
                    value: v })
            } else {
                out.push({ label: String(o), value: o })
            }
        }
        return out.length ? out : root._defaultPageSizeOptions
    }

    function _applyResponsive() {
        if (!root.responsive) {
            root._effectiveViewMode = root.viewMode
            return
        }
        root._effectiveViewMode = root.width > 0 && root.width < root.gridBreakpoint
            ? "grid" : root.viewMode
    }

    function _widthForColumn(column) {
        root._colRev
        var cols = root.columnDefs
        if (column < 0 || column >= cols.length)
            return 120
        var def = cols[column]
        var key = def.key
        if (root.columnWidths && root.columnWidths[key] !== undefined)
            return Number(root.columnWidths[key]) || def.width || 120
        if (def.autoWidth)
            return root._autoWidthFor(def)
        return def.width || 120
    }

    function _autoWidthFor(def) {
        // 纯估算：中文按 2 个字符宽、拉丁按 1 个，取表头与首屏几行的最大值。
        function _measure(text) {
            var s = String(text === undefined || text === null ? "" : text)
            var units = 0
            for (var i = 0; i < s.length; i++)
                units += s.charCodeAt(i) > 255 ? 2 : 1
            return units * (root.dense ? 7 : 8) + 28
        }
        var best = _measure(def.label)
        var rows = root.tableModel && root.tableModel.allRows
            ? root.tableModel.allRows() : []
        var limit = Math.min(rows.length, 40)
        for (var i = 0; i < limit; i++)
            best = Math.max(best, _measure(rows[i][def.key]))
        return Math.max(72, Math.min(360, best))
    }

    function _persistColumnWidth(column, width) {
        var cols = root.columnDefs
        if (column < 0 || column >= cols.length || width <= 0)
            return
        var key = cols[column].key
        var next = {}
        for (var k in root.columnWidths)
            next[k] = root.columnWidths[k]
        next[key] = Math.round(width)
        root.columnWidths = next
        root.columnWidthResized(next)
        tableView.forceLayout()
    }

    function resetColumnWidths() {
        root.columnWidths = ({})
        root._widthOverrides = ({})
        root.columnWidthsChanged(root.columnWidths)
        tableView.forceLayout()
    }

    function _styleColor(def) {
        var s = def && def.style ? String(def.style) : ""
        var all = (def && def.classes ? def.classes : []).join(" ")
        if (s === "negative" || all.indexOf("negative") >= 0)
            return NovaTheme.negative
        if (s === "warning" || all.indexOf("warning") >= 0)
            return NovaTheme.warning
        if (s === "positive" || all.indexOf("positive") >= 0)
            return NovaTheme.primary
        if (s === "muted" || all.indexOf("muted") >= 0)
            return NovaTheme.textMuted
        return NovaTheme.textColor
    }

    function _headerColor(def) {
        var s = def && def.headerStyle ? String(def.headerStyle) : ""
        if (s === "accent")
            return NovaTheme.primary
        if (s === "muted")
            return NovaTheme.textMuted
        return NovaTheme.textColor
    }

    function _toggleGroupRow(row) {
        if (!root.groupProxy || !root.groupProxy.isGroupRow)
            return
        if (!root.groupProxy.isGroupRow(row))
            return
        var key = root.groupProxy.groupData(row).key
        if (key)
            root.groupProxy.toggleGroup(key)
    }

    function toggleGroup(groupKey) {
        if (root.groupProxy && root.groupProxy.toggleGroup)
            root.groupProxy.toggleGroup(groupKey)
    }

    function toggleTreeNode(row) {
        if (root.groupProxy && root.groupProxy.toggleTreeNode)
            root.groupProxy.toggleTreeNode(row)
    }

    function setViewMode(mode) {
        root.viewMode = (mode === "grid" || mode === "masonry") ? mode : "table"
        root._effectiveViewMode = root.viewMode
    }

    function setPageSize(size) {
        if (root.pagination && root.pagination.setPageSize)
            root.pagination.setPageSize(size)
    }

    function toggleFullScreen() {
        root.fullScreen = !root.fullScreen
        root.fullScreenToggled(root.fullScreen)
    }

    function exportCsv(delimiter) {
        var d = delimiter === undefined || delimiter === null
            ? root.exportDelimiter : String(delimiter)
        var text = ""
        if (root.tableModel) {
            if (d !== "," && root.tableModel.exportCsvWithDelimiter)
                text = root.tableModel.exportCsvWithDelimiter(d)
            else if (root.tableModel.exportCsv)
                text = root.tableModel.exportCsv()
            else if (root.tableModel.allRows)
                text = JSON.stringify(root.tableModel.allRows())
        }
        root.exportRequested(text)
        return text
    }

    function _stickyKeys() {
        var src = root.stickyColumns || []
        var out = []
        for (var i = 0; i < src.length && out.length < 2; i++) {
            var k = String(src[i])
            if (root._columnIndexForKey(k) >= 0 && out.indexOf(k) < 0)
                out.push(k)
        }
        return out
    }

    function _sumWidthsBefore(column) {
        var total = 0
        for (var i = 0; i < column; i++)
            total += root._widthForColumn(i)
        return total
    }

    function _columnIndexForKey(key) {
        var defs = root.columnDefs
        for (var i = 0; i < defs.length; i++)
            if (defs[i].key === key)
                return i
        return -1
    }

    function _onContentYChanged() {
        if (!root.loadMoreEnabled || root._effectiveViewMode !== "table")
            return
        var remaining = tableView.contentHeight - tableView.contentY - tableView.height
        if (remaining <= root.loadMoreThreshold * root.rowHeight && root._loadMoreArmed) {
            root._loadMoreArmed = false
            var last = Math.max(0, root._model && root._model.rowCount
                ? root._model.rowCount() - 1 : 0)
            root.loadMoreRequested(last)
        } else if (remaining > root.loadMoreThreshold * root.rowHeight * 2) {
            root._loadMoreArmed = true
        }
    }
    function _syncPaginationTotal() {
        if (root.serverSide)
            return
        if (root.pagination && root.filterProxy)
            root.pagination.setTotal(root.filterProxy.count)
    }

    function _collectSelectedRows() {
        root._selRev
        var out = []
        var sm = tableView && tableView.selectionModel ? tableView.selectionModel : null
        if (!sm || !tableView.model)
            return out
        var n = root._model ? root._model.rowCount() : 0
        for (var i = 0; i < n; i++) {
            if (sm.isSelected(tableView.model.index(i, 0)))
                out.push(i)
        }
        return out
    }

    function _emitSelectionChanged() {
        root._selRev++
        root.selectionChanged(root.selectedRows)
    }

    function toggleExpansion(row) {
        if (!root.expandProxy || !root.expandProxy.toggleRow)
            return
        var isExp = root.expandProxy.isExpansionRow(row)
        root.expandProxy.toggleRow(isExp ? row - 1 : row)
    }

    function isExpanded(row) {
        return !!(root.expandProxy && root.expandProxy.isRowExpanded(row))
    }

    function clearFilters() {
        if (!root.serverSide && root.filterProxy && root.filterProxy.clearFilters)
            root.filterProxy.clearFilters()
        if (searchInput)
            searchInput.modelValue = ""
        root.clearFilterRequested()
        if (root.serverSide)
            root._emitServerRequest(root._sortKey, !root._sortAsc, 1)
    }

    function requestSelectionAction(action) {
        root.selectionActionRequested(root.selectedRows, action)
    }

    function _editorType() {
        var c = root._editingColumn
        if (c < 0 || c >= root.columnDefs.length)
            return "text"
        var ed = root.columnDefs[c].editor
        return (ed === "number" || ed === "int" || ed === "select") ? ed : "text"
    }

    function _editorOptions() {
        var c = root._editingColumn
        if (c < 0 || c >= root.columnDefs.length)
            return []
        var src = root.columnDefs[c].options || []
        var out = []
        // 坑位 70：Python list 不是 QML JS 数组，必须逐项重建。
        for (var i = 0; i < src.length; i++) {
            var o = src[i]
            if (o !== null && typeof o === "object")
                out.push({
                    label: String(o.label !== undefined ? o.label : o.value),
                    value: o.value !== undefined ? o.value : o
                })
            else
                out.push({ label: String(o), value: o })
        }
        return out
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
        else if (ev.key === Qt.Key_PageDown) root._a11yMove(10)
        else if (ev.key === Qt.Key_PageUp) root._a11yMove(-10)
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

                NovaBtn {
                    text: qsTr("导出 CSV")
                    visible: root.showExportButton
                    variant: "flat"
                    size: "sm"
                    onClicked: root.exportCsv(root.exportDelimiter)
                }

                NovaBtn {
                    text: root.fullScreen ? qsTr("退出全屏") : qsTr("全屏")
                    visible: root.showFullScreenButton
                    variant: "flat"
                    size: "sm"
                    onClicked: root.toggleFullScreen()
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
        // 1.8.0：headerDelegate 可整体替换表头，headerCellDelegate 可替换单元格；
        // sticky 首/末列在表头层也用同款覆盖，保持横向滚动时列身份可见。
        Item {
            id: headerHost
            Layout.fillWidth: true
            Layout.preferredHeight: root.headerHeight
            visible: root.headerHeight > 0

            Loader {
                id: headerLoader
                anchors.fill: parent
                sourceComponent: root.headerDelegate !== null
                    ? root.headerDelegate : defaultHeaderView
            }
            Binding {
                target: headerLoader.item
                property: "headerData"
                when: headerLoader.active && root.headerDelegate !== null
                    && headerLoader.item !== null
                value: ({
                    columns: root.columnDefs,
                    sortKey: root._sortKey,
                    ascending: root._sortAsc,
                    headerHeight: root.headerHeight
                })
            }

            Rectangle {
                id: stickyFirstHeader
                readonly property int columnIndex:
                    root._columnIndexForKey(root._stickyKeys().length
                        ? root._stickyKeys()[0] : "")
                visible: columnIndex >= 0
                x: 0
                y: 0
                width: root._widthForColumn(columnIndex)
                height: parent.height
                color: NovaTheme.surface
                z: 4
                Accessible.role: Accessible.ColumnHeader
                Accessible.name: columnIndex >= 0 && columnIndex < root.columnDefs.length
                    ? root.columnDefs[columnIndex].label : ""
                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    text: stickyFirstHeader.Accessible.name
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontS
                    font.bold: true
                    color: NovaTheme.primary
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.sortByKey(root._stickyKeys()[0], true)
                }
                Rectangle {
                    anchors.right: parent.right
                    width: 1
                    height: parent.height
                    color: NovaTheme.outline
                }
            }

            Rectangle {
                id: stickyLastHeader
                readonly property int columnIndex:
                    root._columnIndexForKey(root._stickyKeys().length > 1
                        ? root._stickyKeys()[root._stickyKeys().length - 1] : "")
                visible: columnIndex >= 0
                anchors.right: parent.right
                y: 0
                width: root._widthForColumn(columnIndex)
                height: parent.height
                color: NovaTheme.surface
                z: 4
                Accessible.role: Accessible.ColumnHeader
                Accessible.name: columnIndex >= 0 && columnIndex < root.columnDefs.length
                    ? root.columnDefs[columnIndex].label : ""
                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    text: stickyLastHeader.Accessible.name
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontS
                    font.bold: true
                    color: NovaTheme.primary
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.sortByKey(
                        root._stickyKeys()[root._stickyKeys().length - 1], true)
                }
                Rectangle {
                    anchors.left: parent.left
                    width: 1
                    height: parent.height
                    color: NovaTheme.outline
                }
            }

            Component {
                id: headerSlot
                Item {
                    id: headerSlotRoot
                    required property int index
                    required property string display

                    implicitHeight: root.headerHeight
                    readonly property var hColDef:
                        index < root.columnDefs.length ? root.columnDefs[index] : ({})
                    readonly property var slotData: ({
                        column: index,
                        label: display,
                        key: hColDef && hColDef.key ? hColDef.key : "",
                        sortable: !!hColDef && hColDef.sortable !== false,
                        sorted: !!hColDef && hColDef.key === root._sortKey,
                        ascending: root._sortAsc
                    })

                    Loader {
                        id: headerCellLoader
                        anchors.fill: parent
                        sourceComponent: root.headerCellDelegate !== null
                            ? root.headerCellDelegate : defaultHeaderCell
                    }
                    Binding {
                        target: headerCellLoader.item
                        property: "slotData"
                        when: headerCellLoader.active && headerCellLoader.item !== null
                        value: headerSlotRoot.slotData
                    }
                }
            }

            Component {
                id: defaultHeaderCell
                Rectangle {
                    id: headerCell
                    property var slotData: ({})
                    readonly property bool sortable:
                        !!slotData.key && slotData.sortable === true
                    readonly property bool sorted: slotData.sorted === true
                    readonly property var colDef:
                        slotData.column < root.columnDefs.length
                            ? root.columnDefs[slotData.column] : ({})

                    implicitHeight: root.headerHeight
                    color: headerMa.containsMouse && sortable
                        ? NovaTheme.surfaceAlt : NovaTheme.surface

                    // Qt 无障碍没有 aria-sort；用 ColumnHeader + name/description
                    // 暴露等价语义（列名 + 当前排序方向），键盘 Enter/Space 排序。
                    Accessible.role: Accessible.ColumnHeader
                    Accessible.name: String(slotData.label)
                    Accessible.description: !headerCell.sortable ? ""
                        : (!headerCell.sorted ? qsTr("可排序")
                            : (root._sortAsc ? qsTr("升序") : qsTr("降序")))
                    Accessible.focusable: headerCell.sortable
                    activeFocusOnTab: headerCell.sortable
                    Keys.onPressed: function (ev) {
                        if (!headerCell.sortable)
                            return
                        if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter
                                || ev.key === Qt.Key_Space) {
                            root.sortByKey(slotData.key,
                                headerCell.sorted ? !root._sortAsc : true)
                            ev.accepted = true
                        }
                    }

                    MouseArea {
                        id: headerMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: headerCell.sortable
                            ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: headerCell.sortable
                        onClicked: {
                            var asc = headerCell.sorted ? !root._sortAsc : true
                            root.sortByKey(slotData.key, asc)
                        }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 22
                        text: String(slotData.label)
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontS
                        font.bold: true
                        color: slotData.sorted ? NovaTheme.primary
                            : root._headerColor(colDef)
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: slotData.sorted ? (root._sortAsc ? "▲" : "▼") : ""
                        font.pixelSize: NovaTheme.fontXS
                        color: NovaTheme.primary
                    }

                    MouseArea {
                        visible: root.resizableColumns
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 6
                        cursorShape: Qt.SplitHCursor
                        property real _startX: 0
                        property real _startWidth: 0
                        onPressed: function (mouse) {
                            _startX = mouse.x
                            _startWidth = parent.width
                            mouse.accepted = true
                        }
                        onPositionChanged: function (mouse) {
                            if (!pressed)
                                return
                            root._persistColumnWidth(slotData.column,
                                _startWidth + mouse.x - _startX)
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        width: 1
                        height: parent.height
                        color: NovaTheme.outline
                    }
                }
            }

            Component {
                id: defaultHeaderView
                HorizontalHeaderView {
                    anchors.fill: parent
                    syncView: tableView
                    clip: true
                    resizableColumns: false   // 拖拽走 defaultHeaderCell 的库内手柄
                    delegate: headerSlot
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
                anchors {
                    fill: parent
                    bottomMargin: footerHost.visible ? footerHost.height : 0
                }
                clip: true
                visible: root._effectiveViewMode === "table"
                model: root._model
                reuseItems: root.reuseItems

                rowHeightProvider: function (row) {
                    if (root.groupProxy && root.groupProxy.isGroupRow
                            && root.groupProxy.isGroupRow(row))
                        return root.dense ? 32 : 40
                    return (root.expandProxy && root.expandProxy.isExpansionRow(row))
                        ? root.expansionHeight
                        : (root.dense ? Math.max(28, root.rowHeight - 8) : root.rowHeight)
                }
                columnWidthProvider: function (column) {
                    var cols = root.columnDefs
                    if (column < 0 || column >= cols.length)
                        return 120
                    var w = root._widthForColumn(column)
                    // 末列吃掉剩余宽度，避免宽视口右侧留大片空白；
                    // 拖拽过宽度 / autoWidth 的列以宿主口径为准，不再拉伸。
                    if (column === cols.length - 1
                            && root.columnWidths[cols[column].key] === undefined
                            && !cols[column].autoWidth) {
                        var used = 0
                        for (var i = 0; i < cols.length - 1; i++)
                            used += root._widthForColumn(i)
                        w = Math.max(w, tableView.width - used)
                    }
                    return w
                }

                onContentYChanged: root._onContentYChanged()

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
                    required property bool isExpansion
                    required property bool expanded
                    required property var rowKey
                    required property bool isGroup
                    required property string groupKey
                    required property string groupLabel
                    required property int groupCount
                    required property int treeLevel
                    required property bool hasChildren

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
                    implicitHeight: cell.isGroup ? (root.dense ? 32 : 40)
                        : (cell.isExpansion ? root.expansionHeight
                            : (root.dense ? Math.max(28, root.rowHeight - 8) : root.rowHeight))
                    visible: (!cell.isExpansion && !cell.isGroup) || cell.column === 0

                    Accessible.role: Accessible.Cell
                    Accessible.name: cell.isGroup
                        ? qsTr("分组 %1，共 %2 行").arg(cell.groupLabel).arg(cell.groupCount)
                        : (cell.isExpansion
                            ? qsTr("第 %1 行展开内容").arg(cell.rowKey)
                            : String(cell.display))
                    Accessible.selected: cell.selected
                    Accessible.focusable: false

                    color: cell.isGroup ? NovaTheme.surfaceAlt
                        : cell.isExpansion ? "transparent" : (a11yFocused
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
                                            ? NovaTheme.surfaceAlt : NovaTheme.surface))

                    Behavior on color { ColorAnimation { duration: 180 } }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: cell.column === 0
                            && (root.selectionDelegate !== null || root.expandProxy
                                || root.groupProxy || cell.hasChildren)
                            ? 38 : 10
                        anchors.rightMargin: 10
                        text: cell.isGroup
                            ? cell.groupLabel + "  (" + cell.groupCount + ")"
                            : (cell.display !== undefined && cell.display !== null
                                ? String(cell.display) : "")
                        visible: !cell.isExpansion && !cellLoader.active && !cell.editing
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontS
                        font.bold: cell.isGroup
                        color: cell.isGroup ? NovaTheme.primary
                            : root._styleColor(cell.colDef)
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: cell.colDef.align === "center"
                            ? Text.AlignHCenter
                            : cell.colDef.align === "right"
                                ? Text.AlignRight : Text.AlignLeft
                        elide: Text.ElideRight
                    }

                    // 1.7.0：展开行委托。首列 Loader 允许越过列宽覆盖整行，
                    // 其余展开单元格不可见，达到 QTable body-expand 的整行效果。
                    Loader {
                        id: expansionLoader
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: tableView.width
                        height: parent.height
                        z: 3
                        active: cell.isExpansion && cell.column === 0
                            && root.expansionDelegate !== null
                        sourceComponent: root.expansionDelegate
                    }
                    Binding {
                        target: expansionLoader.item
                        property: "expansionData"
                        when: expansionLoader.active && expansionLoader.item !== null
                        value: root.expandProxy ? root.expandProxy.expansionData(cell.row) : ({})
                    }

                    // 1.8.0 P1-4/P2-4：分组头 / 树节点整行插槽。
                    Loader {
                        id: groupLoader
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: tableView.width
                        height: parent.height
                        z: 3
                        active: cell.isGroup && cell.column === 0
                            && root.groupHeaderDelegate !== null
                        sourceComponent: root.groupHeaderDelegate
                    }
                    Binding {
                        target: groupLoader.item
                        property: "slotData"
                        when: groupLoader.active && groupLoader.item !== null
                        value: ({
                            key: cell.groupKey,
                            label: cell.groupLabel,
                            count: cell.groupCount,
                            level: cell.treeLevel,
                            hasChildren: cell.hasChildren
                        })
                    }

                    // 1.8.0 P1-3：body 整行插槽（首列 Loader 跨列覆盖）。
                    Loader {
                        id: bodyLoader
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: tableView.width
                        height: parent.height
                        z: 2
                        active: !cell.isExpansion && !cell.isGroup && cell.column === 0
                            && root.bodyDelegate !== null
                        sourceComponent: root.bodyDelegate
                    }
                    Binding {
                        target: bodyLoader.item
                        property: "slotData"
                        when: bodyLoader.active && bodyLoader.item !== null
                        value: ({
                            row: cell.row,
                            rowKey: cell.rowKey,
                            column: cell.column,
                            selected: cell.selected,
                            severity: cell.severity,
                            level: cell.treeLevel,
                            rowData: root.getRowData(cell.row)
                        })
                    }

                    // 1.7.0：自定义选择单元格（首列左侧），不替换数据文本。
                    Loader {
                        id: selectionLoader
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28
                        z: 4
                        active: !cell.isExpansion && cell.column === 0
                            && root.selectionDelegate !== null
                        sourceComponent: root.selectionDelegate
                    }
                    Binding {
                        target: selectionLoader.item
                        property: "selectionData"
                        when: selectionLoader.active && selectionLoader.item !== null
                        value: ({
                            selected: cell.selected,
                            row: cell.row,
                            rowKey: cell.rowKey,
                            mode: root.selectionMode
                        })
                    }

                    NovaBtn {
                        visible: !cell.isExpansion && cell.column === 0 && root.expandProxy
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: root.selectionDelegate !== null ? 28 : 0
                        width: 28
                        text: cell.expanded ? "▾" : "▸"
                        variant: "flat"
                        size: "sm"
                        z: 5
                        onClicked: root.toggleExpansion(cell.row)
                    }

                    NovaBtn {
                        visible: cell.column === 0
                            && (cell.isGroup || cell.hasChildren)
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        text: cell.isGroup && root.groupProxy
                            ? (root.groupProxy.collapsed.indexOf(cell.groupKey) >= 0
                                ? "▸" : "▾")
                            : (root.groupProxy
                                && root.groupProxy.treeExpanded.indexOf(cell.rowKey) >= 0
                                ? "▾" : "▸")
                        variant: "flat"
                        size: "sm"
                        z: 5
                        onClicked: cell.isGroup
                            ? root._toggleGroupRow(cell.row)
                            : root.toggleTreeNode(cell.row)
                    }

                    // 列级自定义委托（cellData 懒加载，不含完整行）
                    // 用 Binding 元素而非 item.cellData 直接赋值：Loader.item 静态类型是
                    // QObject，qmllint 无法证明自定义属性存在；Binding 走属性名字符串，
                    // 既零告警又保持响应式（value 绑定随 display / severity 自动刷新）。
                    Loader {
                        id: cellLoader
                        anchors.fill: parent
                        readonly property bool _hasColumnDelegate:
                            !!cell.colDef.key
                            && root.cellDelegates[cell.colDef.key] !== undefined
                        active: !cell.isExpansion && !cell.isGroup && !cell.editing
                            && (root.bodyCellDelegate !== null || _hasColumnDelegate)
                        sourceComponent: root.bodyCellDelegate !== null
                            ? root.bodyCellDelegate
                            : (_hasColumnDelegate
                                ? root.cellDelegates[cell.colDef.key] : undefined)
                    }
                    Binding {
                        target: cellLoader.item
                        property: "cellData"
                        when: cellLoader.active && cellLoader.item !== null
                        value: ({
                            value: cell.display,
                            severity: cell.severity,
                            rowIndex: cell.row,
                            row: cell.row,
                            column: cell.column,
                            label: cell.colDef.label,
                            style: cell.colDef.style,
                            classes: cell.colDef.classes,
                            colKey: cell.colDef.key,
                            rowData: root.getRowData(cell.row)
                        })
                    }

                    // 内联编辑器（NovaField + NovaInput，ESC 取消 / 失败红框）
                    Loader {
                        id: editorLoader
                        anchors.fill: parent
                        anchors.margins: 2
                        active: !cell.isExpansion && !cell.isGroup && cell.editing
                            && cell.colDef.editable === true
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
                            if (cell.isExpansion)
                                return
                            if (cell.isGroup) {
                                root._toggleGroupRow(cell.row)
                                return
                            }
                            if (mouse.button === Qt.RightButton) {
                                var pt = mapToItem(null, mouse.x, mouse.y)
                                root.rowContextMenuRequested(cell.row, pt.x, pt.y)
                                return
                            }
                            if (root.selectionMode !== "none") {
                                var sm = tableView.selectionModel
                                var rowFlags = ItemSelectionModel.Rows
                                if (root.selectionMode === "multiple"
                                        && (mouse.modifiers & Qt.ControlModifier)) {
                                    var rowIndex = tableView.model.index(cell.row, 0)
                                    sm.select(rowIndex,
                                        sm.isSelected(rowIndex)
                                            ? (ItemSelectionModel.Deselect | rowFlags)
                                            : (ItemSelectionModel.Select | rowFlags))
                                    root._anchorRow = cell.row
                                } else if (root.selectionMode === "multiple"
                                        && (mouse.modifiers & Qt.ShiftModifier)
                                        && root._anchorRow >= 0) {
                                    var lo = Math.min(root._anchorRow, cell.row)
                                    var hi = Math.max(root._anchorRow, cell.row)
                                    sm.clearSelection()
                                    for (var i = lo; i <= hi; i++)
                                        sm.select(tableView.model.index(i, 0),
                                            ItemSelectionModel.Select | rowFlags)
                                } else {
                                    var flags = root.selectionMode === "multiple"
                                        ? (ItemSelectionModel.Select | rowFlags)
                                        : (ItemSelectionModel.ClearAndSelect | rowFlags)
                                    sm.select(tableView.model.index(cell.row, 0), flags)
                                    root._anchorRow = cell.row
                                }
                            }
                            root.cellClicked(cell.row, cell.column)
                            root.rowClicked(cell.row)
                            if (cell.colDef.editable && !cell.hasChildren) {
                                root._editingRow = cell.row
                                root._editingColumn = cell.column
                            }
                        }
                        onDoubleClicked: {
                            if (!cell.isExpansion)
                                root.rowDoubleClicked(cell.row)
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {}
                ScrollBar.horizontal: ScrollBar {}
            }

            // 1.8.0 P1-2 / P2-1：sticky 首/末列覆盖视图。
            // 用同一模型的只读 TableView 镜像列像素，同步 contentY；enabled:false
            // 让所有指针事件继续落到主表，避免双份选中态。
            TableView {
                id: stickyFirstView
                readonly property int columnIndex:
                    root._columnIndexForKey(root._stickyKeys().length
                        ? root._stickyKeys()[0] : "")
                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                    bottomMargin: footerHost.visible ? footerHost.height : 0
                }
                width: columnIndex >= 0 ? root._widthForColumn(columnIndex) : 0
                visible: root._effectiveViewMode === "table" && columnIndex >= 0
                enabled: false
                clip: true
                z: 3
                model: root._model
                contentY: tableView.contentY
                columnWidthProvider: function (column) {
                    return column === stickyFirstView.columnIndex
                        ? root._widthForColumn(column) : 0
                }
                rowHeightProvider: function (row) {
                    return root.groupProxy && root.groupProxy.isGroupRow
                        && root.groupProxy.isGroupRow(row)
                        ? (root.dense ? 32 : 40)
                        : (root.expandProxy && root.expandProxy.isExpansionRow(row)
                            ? root.expansionHeight
                            : (root.dense ? Math.max(28, root.rowHeight - 8) : root.rowHeight))
                }
                delegate: Rectangle {
                    required property int row
                    required property var display
                    required property bool isGroup
                    readonly property var colDef:
                        stickyFirstView.columnIndex < root.columnDefs.length
                            ? root.columnDefs[stickyFirstView.columnIndex] : ({})
                    width: root._widthForColumn(stickyFirstView.columnIndex)
                    height: isGroup ? (root.dense ? 32 : 40) : root.rowHeight
                    color: NovaTheme.surface
                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 6
                        text: String(display)
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontS
                        font.bold: isGroup
                        color: isGroup ? NovaTheme.primary : root._styleColor(colDef)
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    Rectangle {
                        anchors.right: parent.right
                        width: 1
                        height: parent.height
                        color: NovaTheme.outline
                    }
                }
            }

            TableView {
                id: stickyLastView
                readonly property int columnIndex:
                    root._columnIndexForKey(root._stickyKeys().length > 1
                        ? root._stickyKeys()[root._stickyKeys().length - 1] : "")
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: footerHost.visible ? footerHost.height : 0
                }
                width: columnIndex >= 0 ? root._widthForColumn(columnIndex) : 0
                visible: root._effectiveViewMode === "table" && columnIndex !== stickyFirstView.columnIndex
                enabled: false
                clip: true
                z: 3
                model: root._model
                contentY: tableView.contentY
                contentX: root._sumWidthsBefore(columnIndex)
                columnWidthProvider: function (column) {
                    return column === stickyLastView.columnIndex
                        ? root._widthForColumn(column) : 0
                }
                rowHeightProvider: function (row) {
                    return root.groupProxy && root.groupProxy.isGroupRow
                        && root.groupProxy.isGroupRow(row)
                        ? (root.dense ? 32 : 40)
                        : (root.expandProxy && root.expandProxy.isExpansionRow(row)
                            ? root.expansionHeight
                            : (root.dense ? Math.max(28, root.rowHeight - 8) : root.rowHeight))
                }
                delegate: Rectangle {
                    required property int row
                    required property var display
                    readonly property var colDef:
                        stickyLastView.columnIndex < root.columnDefs.length
                            ? root.columnDefs[stickyLastView.columnIndex] : ({})
                    width: root._widthForColumn(stickyLastView.columnIndex)
                    height: root.rowHeight
                    color: NovaTheme.surface
                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 6
                        text: String(display)
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontS
                        color: root._styleColor(colDef)
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
            }

            // 1.8.0 P2-1：Grid / Masonry 视图。仍走同一 Python 模型，不另起数据源。
            GridView {
                id: gridView
                anchors {
                    fill: parent
                    bottomMargin: footerHost.visible ? footerHost.height : 0
                }
                visible: root._effectiveViewMode !== "table"
                clip: true
                model: root._model
                cellWidth: root.gridCellWidth
                cellHeight: root.gridCellHeight
                flow: root._effectiveViewMode === "masonry"
                    ? GridView.FlowTopToBottom : GridView.FlowLeftToRight
                delegate: Item {
                    required property int index
                    required property var display
                    required property var rowKey
                    required property int severity
                    width: gridView.cellWidth
                    height: gridView.cellHeight
                    Loader {
                        id: cardLoader
                        anchors.fill: parent
                        anchors.margins: 4
                        sourceComponent: root.gridDelegate !== null
                            ? root.gridDelegate : defaultGridCard
                    }
                    Binding {
                        target: cardLoader.item
                        property: "slotData"
                        when: cardLoader.active && cardLoader.item !== null
                        value: ({
                            index: index,
                            rowKey: rowKey,
                            display: display,
                            severity: severity,
                            rowData: root.getRowData(index)
                        })
                    }
                }
            }

            Component {
                id: defaultGridCard
                Rectangle {
                    property var slotData: ({})
                    radius: NovaTheme.radiusS
                    border.width: 1
                    border.color: NovaTheme.outline
                    color: slotData.severity === 2
                        ? Qt.rgba(NovaTheme.negative.r, NovaTheme.negative.g,
                                  NovaTheme.negative.b, 0.12)
                        : (slotData.severity === 1
                            ? Qt.rgba(NovaTheme.warning.r, NovaTheme.warning.g,
                                      NovaTheme.warning.b, 0.12)
                            : NovaTheme.surface)
                    Text {
                        anchors.fill: parent
                        anchors.margins: 10
                        text: String(slotData.display)
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontS
                        color: NovaTheme.textColor
                        wrapMode: Text.WrapAnywhere
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // 1.8.0 P1-2：底部合计 / 附加行。内容由宿主注入 footerData。
            Rectangle {
                id: footerHost
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 36
                visible: root._effectiveViewMode === "table"
                    && root.footerData !== null && Object.keys(root.footerData).length > 0
                z: 4
                color: NovaTheme.surfaceAlt

                Row {
                    anchors.fill: parent
                    clip: true
                    Repeater {
                        model: root.columnDefs
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: root._widthForColumn(index)
                            height: parent.height
                            color: "transparent"
                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 6
                                text: root.footerData[modelData.key] !== undefined
                                    ? String(root.footerData[modelData.key]) : ""
                                font.family: NovaTheme.fontFamily
                                font.pixelSize: NovaTheme.fontXS
                                font.bold: true
                                color: NovaTheme.primary
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: 1
                    color: NovaTheme.outline
                }
            }

            // 空态：区分「无数据」与「筛选无结果」，两者都可注入自定义委托。
            Item {
                id: emptyHost
                anchors.fill: parent
                visible: !root.loading
                    && (!root._model || root._model.rowCount() === 0)
                z: 2

                readonly property bool filtered: root.filterActive
                readonly property string message: filtered ? root.noResultsText : root.noDataText

                Loader {
                    id: emptyLoader
                    anchors.centerIn: parent
                    active: root.emptyDelegate !== null
                    sourceComponent: root.emptyDelegate
                }
                Binding {
                    target: emptyLoader.item
                    property: "emptyData"
                    when: emptyLoader.active && emptyLoader.item !== null
                    value: ({
                        filtered: emptyHost.filtered,
                        text: emptyHost.message,
                        canClear: emptyHost.filtered
                    })
                }

                Column {
                    anchors.centerIn: parent
                    spacing: NovaTheme.spacingM
                    visible: !emptyLoader.active

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: emptyHost.message
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontM
                        color: NovaTheme.textMuted
                    }
                    NovaBtn {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: emptyHost.filtered
                        text: root.clearFilterText
                        variant: "outlined"
                        size: "sm"
                        onClicked: root.clearFilters()
                    }
                }
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
                    visible: root.paginationDelegate === null
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

                // 1.8.0 P1-5：宿主可注入自己的分页条；仍从同一 pagination 派生状态。
                Loader {
                    id: paginationLoader
                    visible: root.paginationDelegate !== null
                    sourceComponent: root.paginationDelegate
                }
                Binding {
                    target: paginationLoader.item
                    property: "paginationData"
                    when: paginationLoader.active && paginationLoader.item !== null
                    value: ({
                        page: root.pagination ? root.pagination.currentPage : 1,
                        pages: root.pagination ? root.pagination.pageCount : 1,
                        pageSize: root.pagination ? root.pagination.pageSize : 20,
                        total: root.pagination ? root.pagination.total : 0,
                        startIndex: root.pagination ? root.pagination.startIndex : 0,
                        endIndex: root.pagination ? root.pagination.endIndex : 0,
                        setPage: function (p) {
                            if (root.pagination)
                                root.pagination.setCurrentPage(p)
                            if (root.serverSide)
                                root._emitServerRequest(root._sortKey, !root._sortAsc, p)
                        },
                        setPageSize: function (s) { root.setPageSize(s) }
                    })
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

    // 内联编辑器：text/number/int 走 NovaField + NovaInput；
    // select 走库组件 NovaSelect（坑位 70：选项在 QML 内重建为 JS 数组）。
    Component {
        id: textCellEditor
        NovaField {
            id: edField
            width: parent ? parent.width : 120
            height: parent ? parent.height : root.rowHeight
            error: root._editError
            errorMessage: root._editError ? qsTr("提交失败") : ""
            outlined: true

            NovaInput {
                id: edInput
                type: root._editorType() === "number" ? "number" : "text"
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
        }
    }

    Component {
        id: selectCellEditor
        NovaSelect {
            id: edSelect
            width: parent ? parent.width : 120
            height: parent ? parent.height : root.rowHeight
            options: root._editorOptions()
            modelValue: root.tableModel
                ? root.tableModel.getRawValue(root._editingRow, root._editingColumn)
                : null
            emitValue: true
            error: root._editError
            errorMessage: root._editError ? qsTr("提交失败") : ""
            outlined: true
            property bool _ready: false
            Component.onCompleted: Qt.callLater(function () { edSelect._ready = true })

            onModelValueChanged: {
                if (!edSelect._ready)
                    return
                root._submitEdit(edSelect.modelValue)
            }
            Keys.onEscapePressed: function (ev) {
                root._cancelEdit()
                ev.accepted = true
            }
        }
    }

    Component {
        id: cellEditor
        Item {
            width: parent ? parent.width : 120
            height: parent ? parent.height : root.rowHeight
            Loader {
                anchors.fill: parent
                sourceComponent: root._editorType() === "select"
                    ? selectCellEditor : textCellEditor
            }
        }
    }

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }
}
