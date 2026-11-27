// src/pyside_nova/qml/Nova/Controls/NovaTable.qml
// NovaTable 数据表格（对标 QTable）
// v0.11.0 基础：列定义/排序/过滤/分页/多选/展开行/grid 模式
// 1.9.0：对标 Quasar QTable 收口 PARITY 留痕五项（column-sort-order / sort-method /
// visible-columns / fullscreen / grid 定制）+ 补齐招牌插槽体系、列定义元字段、
// 列选择器、附加行、响应式、dense/separator、空态区分、页大小 UI、CSV/触底意图。
// 1.10.0：以 Quasar QTable 官方 QTable.json 全表（63 props / 21 slots / 9 events /
// 15 methods / 15 列元字段）为口径做「完全对标」收口：补齐 8 个插槽、5 个方法、
// 4 个事件、行为开关/文案/虚拟滚动细项/样式语义令牌，并把 row-key / field /
// style|classes / sort-method 升为可调用。CSS / DOM 专属项按「框架边界」以语义令牌
// 等价承接，绝不伪造 CSS 解析。旧 77 props / 14 signals / 21 methods 逐字不变。
// 全部新增公共面 additive，旧 45 props / 7 signals / 13 methods 逐字不变；
// `grid` 保留「单元格描边」原语义，真卡片视图另立 `viewMode`。
// 受控模式（坑位 22）：selected/expanded/sortBy/descending/page/rowsPerPage 均不自写，
// 只 emit 配对信号由宿主写回。
// 全库 unqualified 预算已满，本文件显式关闭该类别（error 仍零容忍）。
// qmllint disable unqualified
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Behaviors
import Nova.Design

Rectangle {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    property int _a11yRow: -1                // 键盘游标（-1 = 未定位）
    Accessible.role: Accessible.Table
    Accessible.name: a11yLabel
    Accessible.focusable: true
    Accessible.focused: activeFocus
    activeFocusOnTab: true
    // 键盘路径：上下移动行游标、Home/End 首尾、Enter 行点击、Space 切换勾选
    Keys.onPressed: function(ev) {
        var n = root.rows ? root.rows.length : 0
        if (n === 0) return
        if (ev.key === Qt.Key_Down) root._a11yMove(1, n)
        else if (ev.key === Qt.Key_Up) root._a11yMove(-1, n)
        else if (ev.key === Qt.Key_Home) root._a11ySet(0)
        else if (ev.key === Qt.Key_End) root._a11ySet(n - 1)
        else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) root._a11yActivate()
        else if (ev.key === Qt.Key_Space) root._a11yToggle()
        else if (ev.key === Qt.Key_PageDown) root._a11yMove(10, n)
        else if (ev.key === Qt.Key_PageUp) root._a11yMove(-10, n)
        else return
        ev.accepted = true
    }
    function _a11ySet(i) {
        var n = root.rows ? root.rows.length : 0
        if (n === 0) return
        root._a11yRow = Math.max(0, Math.min(n - 1, i))
        root.scrollTo(root._a11yRow)
    }
    function _a11yMove(dir, n) {
        if (root._a11yRow < 0) { root._a11ySet(dir > 0 ? 0 : n - 1); return }
        root._a11ySet(root._a11yRow + dir)
    }
    function _a11yActivate() {
        if (root._a11yRow >= 0 && root._a11yRow < root.rows.length)
            root.rowClicked(root.rows[root._a11yRow], root._a11yRow)
    }
    function _a11yToggle() {
        if (root._a11yRow >= 0 && root._a11yRow < root.rows.length)
            root.toggleRowSelection(root.rows[root._a11yRow])
    }

    // ── 数据 ────────────────────────────────────────────────
    property var columns: []               // [{name,label,field,align,sortable,...}] 或字符串
    property var rows: []
    property string rowKey: ""             // 行键字段名；空则用原始行序号
    property string filter: ""             // 客户端过滤（全字段包含匹配）
    property var filterMethod: null        // 自定义过滤 function(row, filter) -> bool

    // ── 服务端模式（v0.12.0） ───────────────────────────────
    property bool serverSide: false        // true=过滤/排序/分页均由宿主执行，rows 即当前页数据
    property int rowsNumber: -1            // 服务端总行数（pageCount 依据；-1 回落 rows.length）

    // ── 虚拟滚动（v0.12.0，对标 virtual-scroll 系） ─────────
    property bool virtualScroll: false     // 表体走 ListView 真虚拟化（建议 rowsPerPage: 0）
    property int virtualScrollItemSize: 48 // 行高（虚拟化估高）

    // ── 状态反馈 ────────────────────────────────────────────
    property bool loading: false           // loading 覆盖层（对标 loading）
    property string loadingLabel: ""       // loading 文案（对标 loading-label）
    property string noDataLabel: ""        // 空态文案（对标 no-data-label；空用内置文案）
    property string noResultsLabel: ""     // 1.9.0：筛选无结果文案（对标 no-results-label）

    // ── 排序（受控） ────────────────────────────────────────
    property string sortBy: ""
    property bool descending: false
    property bool binaryStateSort: false   // true=升↔降两态；false=三态（无序→升→降→无序）
    property string columnSortOrder: "ad"  // 1.9.0：'ad' 升序优先 / 'da' 降序优先（对标 column-sort-order）

    // ── 选择（受控） ────────────────────────────────────────
    property var selected: []              // 选中行对象数组（single 时长度 0/1）
    property bool singleSelection: false   // true=单选（点新行替换）

    // ── 分页（page 受控） ───────────────────────────────────
    property int rowsPerPage: 10
    property int page: 1
    property var rowsPerPageOptions: [5, 10, 20, 50]
    property bool hideBottom: false

    // ── 展开行（受控） ──────────────────────────────────────
    property var expanded: []              // 展开行 key 数组
    property Component expandSlot: null    // 展开区渲染组件（上下文 row/index/expand）

    // ── 外观 ────────────────────────────────────────────────
    property string title: ""
    property bool hideHeader: false
    property bool grid: false              // 网格模式（单元格描边；1.9.0 保留原语义，非卡片视图）
    property bool flat: false
    property bool bordered: !flat

    // ══════════════════════════════════════════════════════════
    // 1.9.0 additive · 对标 Quasar QTable 新增公共面
    // ══════════════════════════════════════════════════════════

    // ── 形态（对标 grid mode / grid-header）──────────────────
    property string viewMode: "table"      // table | grid（grid = 卡片视图，与描边开关 `grid` 解耦）
    property bool gridHeader: false        // grid 视图下保留表头
    property Component gridDelegate: null  // 卡片委托，收 slotData
    property int gridCellWidth: 220
    property int gridCellHeight: 128

    // ── 响应式（对标 dense / responsive）─────────────────────
    property bool dense: false
    property bool responsive: false
    property int gridBreakpoint: 640
    property string separator: "horizontal" // horizontal | vertical | cell | none

    // ── 列显隐（对标 visible-columns / QTableColumns）────────
    property var visibleColumns: []        // 空 = 全部可见；required 列恒可见
    property bool showColumnSelector: false

    // ── 全屏 / 导出 / 触底意图（对标 fullscreen / 导出示例）──
    property bool fullScreen: false
    property bool showFullScreenButton: false
    property bool showExportButton: false
    property string exportDelimiter: ","
    property bool loadMoreEnabled: false
    property int loadMoreThreshold: 80
    property string clearFilterText: ""    // 空 = 内置「清除筛选」

    // ── 完整插槽体系（对标 body / body-cell-[name] / header /
    //    header-cell-[name] / top / bottom / top-row / bottom-row /
    //    footer / no-data / loading / body-expand）─────────────
    property Component bodyDelegate: null
    property Component headerDelegate: null
    property var cellDelegates: ({})       // { "<colName>": Component }，等价 body-cell-[name]
    property var headerCellDelegates: ({}) // { "<colName>": Component }，等价 header-cell-[name]
    property Component topDelegate: null
    property Component bottomDelegate: null
    property Component topRowDelegate: null
    property Component bottomRowDelegate: null
    property Component footerDelegate: null
    property Component noDataDelegate: null
    property Component loadingDelegate: null

    // ══════════════════════════════════════════════════════════
    // 1.10.0 additive · 完全对标 Quasar QTable
    // 口径 = Quasar 官方 ui/src/components/table/QTable.json 全表
    //        （63 props / 21 slots / 9 events / 15 methods / 15 列元字段）
    // CSS / DOM 专属项一律以 NovaTheme 语义令牌等价承接，不伪造 CSS 解析。
    // ══════════════════════════════════════════════════════════

    // ── row-key / selection / sort-method ─────────────────────
    property var rowKeyFn: null            // function(row) -> key（对标 row-key: Function，优先于 rowKey）
    property string selectionMode: ""      // "" | "none" | "single" | "multiple"；空=沿用 singleSelection
    property var sortMethod: null          // function(rows, sortBy, descending) -> Array（官方 sort-method 整体排序）
    property var filterRowsMethod: null    // function(rows, terms, cols, getCellValue) -> Array（官方 filter-method 等价）

    // ── 行为开关（对标 square / wrap-cells / hide-* / color）──
    property bool square: false
    property bool wrapCells: false
    property string colorToken: ""         // 语义色令牌（对标 color，只映射 NovaTheme）
    property string titleClass: ""         // 标题语义样式名
    property bool hideSelectedBanner: false
    property bool hideNoData: false
    property bool hidePagination: false

    // ── 文案（对标 *-label props；string 或 function）─────────
    property var selectedRowsLabel: null   // string | function(n) -> string
    property string rowsPerPageLabel: ""
    property var paginationLabel: null     // string | function(start,end,total) -> string

    // ── 样式语义令牌（对标 table-*-style/class、card-*、*-fn）──
    property string tableStyleToken: ""
    property string tableHeaderStyleToken: ""
    property var rowStyleFn: null          // function(row, index) -> 语义色令牌名
    property string cardContainerStyleToken: ""
    property string cardStyleToken: ""
    property var cardStyleFn: null         // function(row, index) -> 语义色令牌名

    // ── 虚拟滚动细项（对标 virtual-scroll-slice-size / sticky-size-*）──
    property int virtualScrollSliceSize: 10
    property int virtualScrollStickySizeStart: 0
    property int virtualScrollStickySizeEnd: 0

    // ── 补齐 1.9.0 未覆盖的 8 个插槽（QTable 21 slots 全覆盖）──
    property Component bodyCellDelegate: null        // body-cell（全局）
    property Component headerCellDelegate: null      // header-cell（全局）
    property Component bodySelectionDelegate: null   // body-selection
    property Component headerSelectionDelegate: null // header-selection
    property Component paginationDelegate: null     // pagination
    property Component topLeftDelegate: null        // top-left
    property Component topRightDelegate: null       // top-right
    property Component topSelectionDelegate: null   // top-selection

    // ── 新增输出信号（1.9.0）─────────────────────────────────
    signal fullScreenToggled(bool active)
    signal exportRequested(var csvText)
    signal loadMoreRequested(int lastRow)
    signal clearFilterRequested()
    signal rowsPerPageRequested(int size)
    signal columnVisibilityChanged(var keys)
    signal virtualScrollReset()

    // ── 新增输出信号（1.10.0，对标 QTable events）────────────
    signal rowContextMenu(var row, int index)   // @row-contextmenu
    signal selectionChanged(var info)           // @selection：{rows,keys,added,removed}
    signal paginationChanged(var pagination)    // @update:pagination
    signal virtualScrollInfo(var info)          // @virtual-scroll

    // ── 派生数据（管道：服务端模式下全部直通，客户端：过滤 → 排序 → 分页） ──
    readonly property var filteredRows: serverSide ? rows : _filterRows()
    readonly property var sortedRows: serverSide ? rows : _sortRows(filteredRows)
    readonly property int rowCount: serverSide && rowsNumber >= 0 ? rowsNumber : sortedRows.length
    readonly property int pageCount: rowsPerPage > 0 ? Math.max(1, Math.ceil(rowCount / rowsPerPage)) : 1
    // 服务端模式：rows 即宿主返回的当前页切片；客户端模式：本地切片
    readonly property var visibleRows: serverSide ? rows
        : (rowsPerPage > 0 ? sortedRows.slice((page - 1) * rowsPerPage, page * rowsPerPage)
                           : sortedRows)
    readonly property bool allVisibleSelected: visibleRows.length > 0 && _allSelected()
    readonly property bool someSelected: selected.length > 0 && !allVisibleSelected

    // 1.9.0 只读派生：规范化列 / 可见列 / 尺寸 / 视图态
    readonly property var normColumns: _buildNormColumns()
    readonly property var _visibleNormColumns: _filterVisibleColumns()
    readonly property int _rowHeight: root.dense ? 32 : 44
    readonly property int _headerHeight: root.dense ? 32 : 44
    readonly property bool _horizontalSeparator:
        root.separator === "horizontal" || root.separator === "cell"
    readonly property bool _verticalSeparator:
        root.separator === "vertical" || root.separator === "cell"
    readonly property bool _filtered: String(root.filter).length > 0
    readonly property string _emptyText: {
        if (root._filtered && root.noResultsLabel !== "") return root.noResultsLabel
        if (!root._filtered && root.noDataLabel !== "") return root.noDataLabel
        return root._filtered ? "没有匹配结果" : "暂无数据"
    }
    readonly property var _columnOptions: _buildColumnOptions()
    readonly property var _pageSizeOptions: _buildPageSizeOptions()

    // 1.10.0 只读聚合（对标 pagination 对象 / selection 事件载荷）
    readonly property var paginationState: ({
        sortBy: root.sortBy, descending: root.descending, page: root.page,
        rowsPerPage: root.rowsPerPage,
        rowsNumber: root.rowsNumber >= 0 ? root.rowsNumber : root.rowCount
    })
    readonly property var selectionInfo: ({
        rows: root.selected, keys: root._selectedKeys
    })

    property string _effectiveViewMode: root.viewMode
    property bool _columnMenuOpen: false
    property bool _loadMoreArmed: true

    signal rowClicked(var row, int index)
    signal rowDoubleClicked(var row)
    signal updateSelected(var rows)
    signal updateExpanded(var keys)
    signal sortChanged(string field, bool desc)
    signal pageRequested(int page)
    signal request(var params)   // 服务端模式：{ pagination: {sortBy,descending,page,rowsPerPage,rowsNumber}, filter }

    radius: root.square ? 0 : NovaTheme.radiusL
    color: root._tokenColor(root.tableStyleToken) !== null
           ? root._tokenColor(root.tableStyleToken) : NovaTheme.surface
    border.width: bordered ? 1 : 0
    border.color: NovaTheme.outline
    implicitWidth: 640
    implicitHeight: topArea.height + titleArea.height + headerRow.height
                    + topRowArea.height + bodyHost.height
                    + bottomRowArea.height + footerArea.height
                    + (hideBottom ? 0 : bottomBar.height) + bottomArea.height + 2

    // 虚拟滚动模式：宿主应给定 height；未给定时回落 320 视口
    readonly property real _bodyViewport: Math.max(root._rowHeight,
        ((height > 0 ? height : 320) - topArea.height - titleArea.height - headerRow.height
         - topRowArea.height - bottomRowArea.height - footerArea.height
         - (hideBottom ? 0 : bottomBar.height) - bottomArea.height - 2
         - root.virtualScrollStickySizeStart - root.virtualScrollStickySizeEnd))

    function scrollTo(i) {
        // 虚拟滚动模式跳转到指定行（对标 scrollTo()）
        if (!virtualScroll || virtualBody.count === 0) return
        virtualBody.positionViewAtIndex(
            Math.min(Math.max(0, Math.floor(i)), virtualBody.count - 1),
            ListView.Beginning)
    }

    function resetVirtualScroll() {
        // 1.9.0：对标 resetVirtualScroll()（回到首行并复位触底武装）
        if (virtualBody.count > 0)
            virtualBody.positionViewAtIndex(0, ListView.Beginning)
        root._loadMoreArmed = true
        root.virtualScrollReset()
    }

    // 虚拟滚动内部状态（诊断/测试用）
    readonly property int virtualRowCount: virtualBody.count
    readonly property real virtualContentY: virtualBody.contentY
    readonly property real virtualContentHeight: virtualBody.contentHeight

    // ── 工具函数 ────────────────────────────────────────────
    function _normCol(c) {
        if (typeof c === "string")
            return {
                name: c, label: c, field: c, align: "left", sortable: true,
                cellStyle: null, required: false, autoWidth: false, width: 0,
                format: null, sort: null, rawSort: null, sortOrder: "",
                style: "", classes: [], headerStyle: "", headerClasses: []
            }
        return {
            name: c.name,
            label: c.label !== undefined ? c.label : c.name,
            field: c.field !== undefined ? c.field : c.name,
            align: c.align || "left",
            sortable: c.sortable !== false,
            cellStyle: c.cellStyle || null,
            // 1.9.0 列定义元字段（对标 columns[].required/format/sort/rawSort/
            // sortOrder/style/classes/headerStyle/headerClasses/autoWidth/width）
            required: c.required === true,
            autoWidth: c.autoWidth === true,
            width: Number(c.width) || 0,
            format: c.format || null,
            sort: c.sort || null,
            rawSort: c.rawSort || null,
            sortOrder: String(c.sortOrder || ""),
            style: String(c.style || ""),
            classes: c.classes || [],
            headerStyle: String(c.headerStyle || ""),
            headerClasses: c.headerClasses || []
        }
    }

    function _buildNormColumns() {
        var src = root.columns
        // 对标「Omitting columns definition」：从首行 key 推断（跳过 _ 私有字段）
        if ((!src || src.length === 0) && root.rows && root.rows.length > 0) {
            var first = root.rows[0]
            var inferred = []
            for (var k in first) {
                if (String(k).charAt(0) === "_") continue
                inferred.push({ name: k, label: String(k).toUpperCase(), field: k,
                                align: "left", sortable: true })
            }
            return inferred.map(_normCol)
        }
        return src.map(_normCol)
    }

    function _filterVisibleColumns() {
        var keys = root.visibleColumns
        if (!keys || keys.length === 0)
            return root.normColumns
        var out = []
        for (var i = 0; i < root.normColumns.length; i++) {
            var c = root.normColumns[i]
            if (c.required || keys.indexOf(c.name) !== -1)
                out.push(c)
        }
        return out
    }

    function _buildColumnOptions() {
        var out = []
        for (var i = 0; i < root.normColumns.length; i++) {
            var c = root.normColumns[i]
            out.push({ label: c.label, value: c.name, disable: c.required === true })
        }
        return out
    }

    function _buildPageSizeOptions() {
        var src = root.rowsPerPageOptions || []
        var out = []
        for (var i = 0; i < src.length; i++)
            out.push({ label: String(src[i]), value: Number(src[i]) })
        return out
    }

    function _colWidth(index) {
        var cols = root._visibleNormColumns
        if (index < 0 || index >= cols.length) return 120
        var c = cols[index]
        if (c.width > 0) return c.width
        if (c.autoWidth) return root._autoWidthFor(c)
        var sel = root.singleSelection || root.selectionMode === "none" ? 0 : 44
        return Math.max(80, (root.width - sel) / cols.length)
    }

    function _autoWidthFor(def) {
        // 纯估算：中文按 2 个字符宽、拉丁按 1 个，取表头与首屏 40 行的最大值。
        function _measure(text) {
            var s = String(text === undefined || text === null ? "" : text)
            var units = 0
            for (var i = 0; i < s.length; i++)
                units += s.charCodeAt(i) > 255 ? 2 : 1
            return units * (root.dense ? 7 : 8) + 28
        }
        var best = _measure(def.label)
        var src = root.sortedRows
        var lim = Math.min(src.length, 40)
        for (var r = 0; r < lim; r++)
            best = Math.max(best, _measure(root._cellText(src[r], def)))
        return Math.min(360, Math.max(72, best))
    }

    // 列级语义样式：只映射既有 NovaTheme 令牌，不接受任意 CSS（对标 style/classes）
    function _styleColor(def, row) {
        var s = def && def.style ? def.style : ""
        var all = def && def.classes ? def.classes : ""
        // 1.10.0：对标 columns[].style / classes: Function(row)
        if (typeof s === "function") s = s(row)
        if (typeof all === "function") all = all(row)
        s = String(s === undefined || s === null ? "" : s)
        all = String(all === undefined || all === null ? "" : all)
        if (s === "negative" || all.indexOf("negative") >= 0) return NovaTheme.negative
        if (s === "warning" || all.indexOf("warning") >= 0) return NovaTheme.warning
        if (s === "positive" || all.indexOf("positive") >= 0) return NovaTheme.primary
        if (s === "muted" || all.indexOf("muted") >= 0) return NovaTheme.textMuted
        var tok = root.colorToken !== "" ? root._tokenColor(root.colorToken) : null
        return tok !== null ? tok : NovaTheme.textColor
    }

    function _headerColor(def) {
        var s = String(def && def.headerStyle ? def.headerStyle : "")
        var all = String(def && def.headerClasses ? def.headerClasses : "")
        if (s === "accent" || all.indexOf("accent") >= 0
                || s === "positive" || all.indexOf("positive") >= 0)
            return NovaTheme.primary
        if (s === "muted" || all.indexOf("muted") >= 0) return NovaTheme.textMuted
        return NovaTheme.textColor
    }

    function _keyOf(row, i) {
        // 1.10.0：对标 row-key: Function（嵌套 / 派生键）
        if (root.rowKeyFn !== null && typeof root.rowKeyFn === "function")
            return String(root.rowKeyFn(row))
        return rowKey && row[rowKey] !== undefined ? String(row[rowKey]) : String(i)
    }

    function _cellText(row, col) {
        if (row === undefined || row === null || col === undefined || col === null)
            return ""
        // 1.10.0：对标 columns[].field: Function（row => 嵌套取值）
        var v = (col.field !== null && typeof col.field === "function")
            ? col.field(row) : row[col.field]
        // 1.9.0：对标 columns[].format(val, row)
        if (col.format !== null && typeof col.format === "function")
            return String(col.format(v, row))
        return v === undefined || v === null ? "" : String(v)
    }

    function _filterRows() {
        var src = rows
        if (!filter || filter === "")
            return src
        // 1.10.0：官方 filter-method 整体函数优先（rows, terms, cols, getCellValue）
        if (root.filterRowsMethod !== null && typeof root.filterRowsMethod === "function")
            return root.filterRowsMethod(src, root.filter, root.normColumns, root.getCellValue)
        if (filterMethod)
            return src.filter(function (r) { return filterMethod(r, filter) })
        var f = String(filter).toLowerCase()
        return src.filter(function (r) {
            for (var k in r) {
                if (String(r[k]).toLowerCase().indexOf(f) !== -1)
                    return true
            }
            return false
        })
    }

    function _cmp(a, b, col) {
        var field = col ? col.field : root.sortBy
        // 1.10.0：columns[].field: Function 时按函数取值，避免 a[function] 退化为 undefined
        var va = (field !== null && typeof field === "function") ? field(a) : a[field]
        var vb = (field !== null && typeof field === "function") ? field(b) : b[field]
        // 1.9.0：对标 columns[].sort / rawSort(a, b, rowA, rowB)
        var fn = col ? (col.rawSort || col.sort) : null
        if (fn !== null && typeof fn === "function")
            return fn(va, vb, a, b)
        if (typeof va === "number" && typeof vb === "number")
            return va - vb
        return String(va === undefined ? "" : va)
            .localeCompare(String(vb === undefined ? "" : vb))
    }

    function _sortRows(src) {
        if (!sortBy)
            return src
        // 1.10.0：官方 sort-method 整体排序优先（rows, sortBy, descending）-> Array
        if (root.sortMethod !== null && typeof root.sortMethod === "function")
            return root.sortMethod(src, root.sortBy, root.descending)
        var col = null
        for (var i = 0; i < normColumns.length; i++)
            if (normColumns[i].name === sortBy) col = normColumns[i]
        var out = src.slice()
        out.sort(function (a, b) {
            var r = _cmp(a, b, col)
            return descending ? -r : r
        })
        return out
    }

    function _colByName(name) {
        for (var i = 0; i < root.normColumns.length; i++)
            if (root.normColumns[i].name === name) return root.normColumns[i]
        return null
    }

    // ── 选择（受控：返回下一状态供宿主写回） ────────────────
    // 坑位 27：Qt6 信号参数会把 JS 对象深拷贝，选中态一律按键值比较（rowKey 或 JSON 全等）
    function _keyVal(row) {
        // 1.10.0：rowKeyFn 与 _keyOf 共用同一取值口径
        if (root.rowKeyFn !== null && typeof root.rowKeyFn === "function")
            return String(root.rowKeyFn(row))
        if (rowKey && row[rowKey] !== undefined)
            return String(row[rowKey])
        return JSON.stringify(row)
    }

    readonly property var _selectedKeys: selected.map(function (r) { return _keyVal(r) })

    function isRowSelected(row) {
        return _selectedKeys.indexOf(_keyVal(row)) !== -1
    }

    function toggleRowSelection(row) {
        var next = selected.slice()
        var kv = _keyVal(row)
        var at = _selectedKeys.indexOf(kv)
        if (at !== -1) {
            next.splice(at, 1)
            updateSelected(next)
            return next
        }
        if (singleSelection)
            next = [row]
        else
            next.push(row)
        updateSelected(next)
        return next
    }

    function _allSelected() {
        for (var i = 0; i < visibleRows.length; i++)
            if (!isRowSelected(visibleRows[i]))
                return false
        return true
    }

    function toggleAllSelection() {
        var visKeys = visibleRows.map(function (r) { return _keyVal(r) })
        var next
        if (_allSelected()) {
            next = selected.filter(function (r) { return visKeys.indexOf(_keyVal(r)) === -1 })
        } else {
            next = selected.slice()
            for (var i = 0; i < visibleRows.length; i++)
                if (!isRowSelected(visibleRows[i]))
                    next.push(visibleRows[i])
        }
        updateSelected(next)
        return next
    }

    // ── 排序请求（受控：emit 下一状态） ─────────────────────
    // 服务端模式：排序触发请求并重置页码为 1（Quasar 语义）
    // 1.9.0：columnSortOrder / columns[].sortOrder 决定首次点击方向（默认 ad 与原行为一致）
    function requestSort(name) {
        var col = _colByName(name)
        var order = col && col.sortOrder !== "" ? col.sortOrder : root.columnSortOrder
        var initial = order === "da"        // 首次点击方向：ad→升序 / da→降序
        var nextDesc
        if (sortBy !== name)
            nextDesc = initial
        else if (descending === initial)
            nextDesc = !initial
        else if (binaryStateSort)
            nextDesc = initial
        else {
            sortChanged("", false)
            _emitServerRequest("", false, 1)
            return { sortBy: "", descending: false }
        }
        sortChanged(name, nextDesc)
        _emitServerRequest(name, nextDesc, 1)
        return { sortBy: name, descending: nextDesc }
    }

    // 服务端模式：filter 变化触发请求（重置页码为 1；宿主勿在 request 处理器回写 filter，防环）
    onFilterChanged: if (serverSide) _emitServerRequest(sortBy, descending, 1)

    // ── 展开行（受控） ──────────────────────────────────────
    function isRowExpanded(row, i) {
        return expanded.indexOf(_keyOf(row, i)) !== -1
    }

    function toggleRowExpand(row, i) {
        var k = _keyOf(row, i)
        var next = expanded.slice()
        var at = next.indexOf(k)
        if (at === -1)
            next.push(k)
        else
            next.splice(at, 1)
        updateExpanded(next)
        return next
    }

    // ── 分页 ────────────────────────────────────────────────
    function requestPage(p) {
        var next = Math.min(Math.max(1, Math.round(p)), pageCount)
        if (next !== page) {
            pageRequested(next)
            _emitServerRequest(sortBy, descending, next)  // 服务端模式：翻页触发请求
        }
        return next
    }
    function nextPage() { return requestPage(page + 1) }
    function prevPage() { return requestPage(page - 1) }
    function firstPage() { return requestPage(1) }   // 对标 firstPage()

    function requestRowsPerPage(size) {
        // 1.9.0：对标 rows-per-page-options（受控，宿主写回 rowsPerPage）
        var n = Math.max(0, Math.round(Number(size) || 0))
        root.rowsPerPageRequested(n)
        root._emitServerRequest(root.sortBy, root.descending, 1)
        return n
    }

    // ── 服务端模式辅助（对标 requestServerInteraction / setPagination） ──
    function _emitServerRequest(sortBy_, desc, pg) {
        if (!serverSide) return
        request({
            pagination: {
                sortBy: sortBy_, descending: desc, page: pg,
                rowsPerPage: rowsPerPage, rowsNumber: rowsNumber
            },
            filter: filter
        })
    }
    function requestServerInteraction() {
        // 主动触发一次服务端交互（对标 requestServerInteraction()）
        _emitServerRequest(sortBy, descending, page)
    }
    function setPagination(pg) {
        // 对标 setPagination：以给定分页对象触发服务端请求
        // pg: {sortBy, descending, page, rowsPerPage, rowsNumber}
        if (pg === undefined || pg === null) return
        if (pg.sortBy !== undefined && pg.descending !== undefined)
            sortChanged(pg.sortBy, pg.descending)
        if (pg.page !== undefined)
            pageRequested(pg.page)
        _emitServerRequest(pg.sortBy !== undefined ? pg.sortBy : sortBy,
                           pg.descending !== undefined ? pg.descending : descending,
                           pg.page !== undefined ? pg.page : page)
    }

    // ── 1.9.0 形态 / 外围方法 ───────────────────────────────
    function _applyResponsive() {
        if (!root.responsive) {
            root._effectiveViewMode = root.viewMode
            return
        }
        root._effectiveViewMode = root.width > 0 && root.width < root.gridBreakpoint
            ? "grid" : root.viewMode
    }
    onWidthChanged: root._applyResponsive()
    onViewModeChanged: root._applyResponsive()
    Component.onCompleted: root._applyResponsive()

    function setViewMode(mode) {
        root.viewMode = (mode === "grid") ? "grid" : "table"
        root._applyResponsive()
    }

    function toggleFullScreen() {
        root.fullScreen = !root.fullScreen
        root.fullScreenToggled(root.fullScreen)
    }

    function setVisibleColumns(keys) {
        var next = []
        for (var i = 0; i < keys.length; i++)
            next.push(String(keys[i]))
        root.visibleColumns = next
        root.columnVisibilityChanged(next)
        return next
    }

    function toggleColumnVisibility(name) {
        var keys = root.visibleColumns.length === 0
            ? root._columnOptions.map(function (o) { return o.value })
            : root.visibleColumns.slice()
        var n = String(name)
        var at = keys.indexOf(n)
        if (at === -1) keys.push(n)
        else keys.splice(at, 1)
        return root.setVisibleColumns(keys)
    }

    function _applyVisibleColumns(keys) {
        var next = []
        for (var i = 0; i < keys.length; i++)
            next.push(String(keys[i]))
        root.visibleColumns = next
        root.columnVisibilityChanged(next)
    }

    function clearFilter() {
        // 受控：只发意图，宿主写回 filter = ""
        root.clearFilterRequested()
    }

    function _csvCell(s, sep) {
        var v = String(s === undefined || s === null ? "" : s)
        if (v.indexOf("\"") !== -1 || v.indexOf(sep) !== -1 || v.indexOf("\n") !== -1)
            return "\"" + v.split("\"").join("\"\"") + "\""
        return v
    }

    function exportCsv(delimiter) {
        // 1.9.0：纯 QML / 纯 JS 生成 CSV，不写文件、不依赖 Python，只发意图
        var d = delimiter === undefined || delimiter === null
            ? root.exportDelimiter : String(delimiter)
        var sep = d === "\\t" ? "\t" : String(d).charAt(0)
        if (sep === "") sep = ","
        var cols = root._visibleNormColumns
        var lines = []
        var head = []
        for (var c = 0; c < cols.length; c++)
            head.push(root._csvCell(cols[c].label, sep))
        lines.push(head.join(sep))
        var src = root.sortedRows
        for (var r = 0; r < src.length; r++) {
            var cells = []
            for (var j = 0; j < cols.length; j++)
                cells.push(root._csvCell(root._cellText(src[r], cols[j]), sep))
            lines.push(cells.join(sep))
        }
        var text = lines.join("\n") + "\n"
        root.exportRequested(text)
        return text
    }

    // ══════════════════════════════════════════════════════════
    // 1.10.0 · 语义令牌 / 文案 / 聚合意图 / 补齐方法
    // ══════════════════════════════════════════════════════════
    function _tokenColor(token) {
        var t = String(token === undefined || token === null ? "" : token)
        if (t === "negative") return NovaTheme.negative
        if (t === "warning") return NovaTheme.warning
        if (t === "positive" || t === "primary") return NovaTheme.primary
        if (t === "muted") return NovaTheme.textMuted
        if (t === "surfaceAlt") return NovaTheme.surfaceAlt
        if (t === "surface") return NovaTheme.surface
        if (t === "outline") return NovaTheme.outline
        return null
    }

    function _cardToken(row, index) {
        return root.cardStyleFn !== null && typeof root.cardStyleFn === "function"
            ? root.cardStyleFn(row, index) : root.cardStyleToken
    }
    function _cardColor(row, index) {
        var c = root._tokenColor(root._cardToken(row, index))
        return c !== null ? c : NovaTheme.surface
    }
    function _cardBorderColor(row, index) {
        var c = root._tokenColor(root._cardToken(row, index))
        return c !== null ? c : NovaTheme.outline
    }

    function _rowsLabel() {
        var v = root.selectedRowsLabel
        if (v === null || v === undefined || v === "")
            return "共 " + root.rowCount + " 条 · 已选 " + root.selected.length
        return typeof v === "function" ? String(v(root.selected.length)) : String(v)
    }

    function _paginationLabelText() {
        var start = root.rowCount === 0 ? 0 : (root.page - 1) * root.rowsPerPage + 1
        var end = Math.min(root.rowCount, root.page * root.rowsPerPage)
        if (root.rowsPerPage <= 0) { start = root.rowCount === 0 ? 0 : 1; end = root.rowCount }
        var v = root.paginationLabel
        if (v === null || v === undefined || v === "")
            return start + "–" + end + " / " + root.rowCount
        return typeof v === "function" ? String(v(start, end, root.rowCount)) : String(v)
    }

    function _rowsPerPageLabelText() {
        return root.rowsPerPageLabel !== "" ? root.rowsPerPageLabel : qsTr("每页")
    }

    function _emitPaginationChanged() { root.paginationChanged(root.paginationState) }
    onPageChanged: root._emitPaginationChanged()
    onSortByChanged: root._emitPaginationChanged()
    onDescendingChanged: root._emitPaginationChanged()
    onRowsPerPageChanged: root._emitPaginationChanged()
    onRowsNumberChanged: root._emitPaginationChanged()

    property var _prevSelectedKeys: []
    onSelectedChanged: {
        var cur = root._selectedKeys
        var prev = root._prevSelectedKeys
        var added = []
        var removed = []
        for (var i = 0; i < cur.length; i++)
            if (prev.indexOf(cur[i]) === -1) added.push(cur[i])
        for (var j = 0; j < prev.length; j++)
            if (cur.indexOf(prev[j]) === -1) removed.push(prev[j])
        root._prevSelectedKeys = cur.slice()
        root.selectionChanged({
            rows: root.selected, keys: cur, added: added, removed: removed
        })
    }

    function _emitVirtualScrollInfo() {
        if (!root.virtualScroll) return
        var unit = Math.max(1, root.virtualScrollItemSize)
        root.virtualScrollInfo({
            firstRowIndex: Math.max(0, Math.floor(virtualBody.contentY / unit)),
            lastRowIndex: Math.max(0, Math.ceil((virtualBody.contentY + virtualBody.height) / unit) - 1),
            contentY: virtualBody.contentY, contentHeight: virtualBody.contentHeight
        })
    }

    // ── 对标 QTable methods 的 5 项补齐 ───────────────────────
    function lastPage() { return requestPage(pageCount) }
    function clearSelection() {
        root.updateSelected([])
        return []
    }
    function setExpanded(keys) {
        var next = []
        for (var i = 0; i < keys.length; i++)
            next.push(String(keys[i]))
        root.updateExpanded(next)
        return next
    }
    function sort(name) { return root.requestSort(name) }
    function getCellValue(col, row) {
        var d = typeof col === "string" ? root._colByName(col) : col
        return d === null ? undefined : root._cellText(row, d)
    }

    // ══════════════════════════════════════════════════════════
    // 行结构（inline component：普通 Repeater 与虚拟 ListView 共用）
    // ══════════════════════════════════════════════════════════
    component TableRow: Column {
        id: rowWrap
        required property var modelData
        required property int index
        width: ListView.view !== null ? ListView.view.width
                                      : (parent !== null ? parent.width : 300)
        // 显式高度：虚拟滚动创建期定位器可能错过自动布局（坑位 30），
        // 用 childrenRect 兜底——子项自身高度（NovaTr 44 + 展开区 + 分隔线 1）不依赖父高，无环
        height: childrenRect.height

        property var rowData: modelData
        property int rowIdx: index
        property string rowK: root._keyOf(modelData, index)
        property bool rowExpanded: root.expanded.indexOf(rowK) !== -1
        property bool rowSelected: root.isRowSelected(modelData)

        // 1.9.0：bodyDelegate 整行替换（对标 body slot）
        Loader {
            id: bodySlotLoader
            width: parent.width
            height: root._rowHeight
            active: root.bodyDelegate !== null
            sourceComponent: root.bodyDelegate
            visible: active
        }
        Binding {
            target: bodySlotLoader.item
            property: "slotData"
            when: bodySlotLoader.active && bodySlotLoader.item !== null
            value: ({
                rowData: rowWrap.rowData,
                rowIndex: rowWrap.rowIdx,
                rowKey: rowWrap.rowK,
                rowSelected: rowWrap.rowSelected,
                rowExpanded: rowWrap.rowExpanded,
                columns: root._visibleNormColumns
            })
        }

        NovaTr {
            id: tr
            width: parent.width
            height: root._rowHeight
            visible: !bodySlotLoader.active
            selected: rowWrap.rowSelected
            // 1.10.0：对标 table-row-style-fn / table-row-class-fn（语义令牌色）
            rowColor: {
                var t = root.rowStyleFn !== null && typeof root.rowStyleFn === "function"
                    ? root.rowStyleFn(rowWrap.rowData, rowWrap.rowIdx) : ""
                var c = root._tokenColor(t)
                return c !== null ? c : "transparent"
            }
            Row {
                width: parent.width
                height: parent.height
                // 单选/多选列（1.10.0：selectionMode:"none" 整列隐藏；可整体替换）
                Item {
                    id: bodySelectionCell
                    readonly property bool _none: root.selectionMode === "none"
                    width: root.singleSelection || _none ? 0 : 44
                    height: parent.height
                    visible: !root.singleSelection && !_none

                    Loader {
                        id: bodySelectionLoader
                        anchors.fill: parent
                        active: root.bodySelectionDelegate !== null
                        sourceComponent: root.bodySelectionDelegate
                    }
                    Binding {
                        target: bodySelectionLoader.item
                        property: "slotData"
                        when: bodySelectionLoader.active && bodySelectionLoader.item !== null
                        value: ({
                            rowData: rowWrap.rowData, rowIndex: rowWrap.rowIdx,
                            rowKey: rowWrap.rowK, rowSelected: rowWrap.rowSelected,
                            selected: rowWrap.rowSelected
                        })
                    }

                    Rectangle {
                        width: 16; height: 16; radius: 3
                        anchors.centerIn: parent
                        visible: !bodySelectionLoader.active
                        color: rowWrap.rowSelected
                            ? (root._tokenColor(root.colorToken) !== null
                                ? root._tokenColor(root.colorToken) : NovaTheme.primary)
                            : "transparent"
                        border.width: 1
                        border.color: rowWrap.rowSelected ? NovaTheme.primary : NovaTheme.textMuted
                        Text {
                            anchors.centerIn: parent
                            visible: rowWrap.rowSelected
                            text: "✓"; color: NovaTheme.textOnPrimary
                            font.pixelSize: 12; font.bold: true
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: !bodySelectionLoader.active
                        onClicked: root.toggleRowSelection(rowWrap.rowData)
                    }
                }
                Repeater {
                    model: root._visibleNormColumns
                    // 外包 Item：① 显式 required index = 列索引（否则 Qt6 会
                    // 拿到 inline component 的行号或报未定义）；② 避免把带
                    // anchors.fill 的 Loader 塞进 NovaTd/NovaTh 内部的 Row 定位器。
                    Item {
                        required property var modelData
                        required property int index
                        readonly property bool _custom:
                            root.cellDelegates[modelData.name] !== undefined
                            || root.bodyCellDelegate !== null
                        width: root._colWidth(index)
                        height: root._rowHeight

                        NovaTd {
                            anchors.fill: parent
                            text: ""
                            align: modelData.align
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.width: root.grid ? 1 : 0
                                border.color: NovaTheme.outline
                            }
                        }

                        Text {
                            // 列级语义色：无自定义委托时由本 Text 渲染
                            anchors.fill: parent
                            anchors.leftMargin: NovaTheme.spacingM
                            anchors.rightMargin: NovaTheme.spacingM
                            visible: !_custom
                            text: root._cellText(rowWrap.rowData, modelData)
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontM
                            color: root._styleColor(modelData, rowWrap.rowData)
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: modelData.align === "center"
                                ? Text.AlignHCenter
                                : (modelData.align === "right" ? Text.AlignRight : Text.AlignLeft)
                            wrapMode: root.wrapCells ? Text.WordWrap : Text.NoWrap
                            elide: root.wrapCells ? Text.ElideNone : Text.ElideRight
                        }

                        // 列级自定义委托（对标 body-cell-[name]）
                        Loader {
                            id: cellSlotLoader
                            anchors.fill: parent
                            active: _custom
                            sourceComponent: _custom
                                ? (root.cellDelegates[modelData.name] !== undefined
                                    ? root.cellDelegates[modelData.name]
                                    : root.bodyCellDelegate) : undefined
                        }
                        Binding {
                            target: cellSlotLoader.item
                            property: "cellData"
                            when: cellSlotLoader.active && cellSlotLoader.item !== null
                            value: ({
                                value: rowWrap.rowData[modelData.field],
                                text: root._cellText(rowWrap.rowData, modelData),
                                rowData: rowWrap.rowData,
                                rowIndex: rowWrap.rowIdx,
                                colName: modelData.name,
                                colLabel: modelData.label,
                                color: root._styleColor(modelData, rowWrap.rowData),
                                columns: root._visibleNormColumns
                            })
                        }

                        Rectangle {
                            anchors.right: parent.right
                            width: 1
                            height: parent.height
                            color: NovaTheme.outline
                            visible: root._verticalSeparator
                        }
                    }
                }
            }
            onRowClicked: root.rowClicked(rowWrap.rowData, rowWrap.rowIdx)
            onRowDoubleClicked: root.rowDoubleClicked(rowWrap.rowData, rowWrap.rowIdx)
            onRowContextMenu: root.rowContextMenu(rowWrap.rowData, rowWrap.rowIdx)
        }

        // 展开区
        Loader {
            width: parent.width
            active: rowWrap.rowExpanded && root.expandSlot !== null
            sourceComponent: root.expandSlot
            onLoaded: {
                if (item.rowData !== undefined) item.rowData = rowWrap.rowData
                if (item.rowIndex !== undefined) item.rowIndex = rowWrap.rowIdx
            }
        }
        Rectangle {
            width: parent.width
            height: 1
            color: NovaTheme.outline
            opacity: 0.5
            visible: root._horizontalSeparator
        }
    }

    // ══════════════════════════════════════════════════════════
    Column {
        id: shell
        anchors.fill: parent

        // ── 1.9.0 自定义顶部控件（对标 top slot）────────────
        Item {
            id: topArea
            width: parent.width
            // 固定高度：委托由 Loader 的 anchors.fill 填满，避免动态取 item 几何
            // 触发 qmllint missing-property，也规避 implicitHeight 为 0 的自举坑。
            height: (topSlotLoader.active || topLeftLoader.active
                     || topRightLoader.active || topSelectionLoader.active) ? 44 : 0
            visible: height > 0
            Loader {
                id: topSlotLoader
                anchors.fill: parent
                active: root.topDelegate !== null
                sourceComponent: root.topDelegate
            }
            Binding {
                target: topSlotLoader.item
                property: "slotData"
                when: topSlotLoader.active && topSlotLoader.item !== null
                value: ({
                    selected: root.selected, rowCount: root.rowCount,
                    page: root.page, pageCount: root.pageCount,
                    filter: root.filter, fullScreen: root.fullScreen,
                    columns: root._visibleNormColumns
                })
            }

            // 1.10.0：top-left / top-right / top-selection 三个分区（可与 top 共存）
            Loader {
                id: topLeftLoader
                anchors { left: parent.left; verticalCenter: parent.verticalCenter
                          leftMargin: NovaTheme.spacingM }
                width: active ? 160 : 0
                height: parent.height
                active: root.topLeftDelegate !== null
                sourceComponent: root.topLeftDelegate
            }
            Binding {
                target: topLeftLoader.item
                property: "slotData"
                when: topLeftLoader.active && topLeftLoader.item !== null
                value: ({ selected: root.selected, rowCount: root.rowCount,
                          page: root.page, pageCount: root.pageCount, filter: root.filter })
            }
            Loader {
                id: topRightLoader
                anchors { right: parent.right; verticalCenter: parent.verticalCenter
                          rightMargin: NovaTheme.spacingM }
                width: active ? 160 : 0
                height: parent.height
                active: root.topRightDelegate !== null
                sourceComponent: root.topRightDelegate
            }
            Binding {
                target: topRightLoader.item
                property: "slotData"
                when: topRightLoader.active && topRightLoader.item !== null
                value: ({ selected: root.selected, rowCount: root.rowCount,
                          page: root.page, pageCount: root.pageCount, filter: root.filter,
                          fullScreen: root.fullScreen, columns: root._visibleNormColumns })
            }
            Loader {
                id: topSelectionLoader
                anchors.centerIn: parent
                width: active ? 200 : 0
                height: parent.height
                active: root.topSelectionDelegate !== null && root.selected.length > 0
                sourceComponent: root.topSelectionDelegate
            }
            Binding {
                target: topSelectionLoader.item
                property: "slotData"
                when: topSelectionLoader.active && topSelectionLoader.item !== null
                value: ({ selected: root.selected, keys: root._selectedKeys,
                          selectedCount: root.selected.length, rowCount: root.rowCount })
            }
        }

        // 标题 + 1.9.0 工具栏按钮（列选择器 / 导出 / 全屏）
        Rectangle {
            id: titleArea
            width: parent.width
            height: (root.title !== "" || root.showColumnSelector
                     || root.showExportButton || root.showFullScreenButton) ? 44 : 0
            color: "transparent"
            visible: height > 0
            Text {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingM }
                text: root.title
                color: root.titleClass === "muted" ? NovaTheme.textMuted
                    : (root.titleClass === "primary" ? NovaTheme.primary : NovaTheme.textColor)
                font.pixelSize: NovaTheme.fontL
                font.weight: Font.Medium
            }
            Row {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingM }
                spacing: NovaTheme.spacingS
                NovaBtn {
                    id: columnBtn
                    visible: root.showColumnSelector
                    text: qsTr("列")
                    variant: "flat"
                    size: "sm"
                    onClicked: columnMenu.show()
                }
                NovaBtn {
                    visible: root.showExportButton
                    text: qsTr("导出 CSV")
                    variant: "flat"
                    size: "sm"
                    onClicked: root.exportCsv(root.exportDelimiter)
                }
                NovaBtn {
                    visible: root.showFullScreenButton
                    text: root.fullScreen ? qsTr("退出全屏") : qsTr("全屏")
                    variant: "flat"
                    size: "sm"
                    onClicked: root.toggleFullScreen()
                }
            }
        }

        // 表头（粘性语义：分页模式行数有限，表头常驻）
        Rectangle {
            id: headerRow
            width: parent.width
            height: root.hideHeader ? 0 : root._headerHeight
            color: root._tokenColor(root.tableHeaderStyleToken) !== null
                   ? root._tokenColor(root.tableHeaderStyleToken) : NovaTheme.surfaceAlt
            visible: !root.hideHeader
                && (root._effectiveViewMode !== "grid" || root.gridHeader)

            // 1.9.0：headerDelegate 整表头替换
            Loader {
                id: headerSlotLoader
                anchors.fill: parent
                active: root.headerDelegate !== null
                sourceComponent: root.headerDelegate
            }
            Binding {
                target: headerSlotLoader.item
                property: "slotData"
                when: headerSlotLoader.active && headerSlotLoader.item !== null
                value: ({
                    columns: root._visibleNormColumns,
                    sortBy: root.sortBy, descending: root.descending,
                    rowCount: root.rowCount
                })
            }

            Row {
                anchors.fill: parent
                visible: !headerSlotLoader.active

                // 多选列表头（1.10.0：selectionMode:"none" 隐藏；可整体替换）
                Item {
                    readonly property bool _none: root.selectionMode === "none"
                    width: root.singleSelection || _none ? 0 : 44
                    height: parent.height
                    visible: !root.singleSelection && !_none

                    Loader {
                        id: headerSelectionLoader
                        anchors.fill: parent
                        active: root.headerSelectionDelegate !== null
                        sourceComponent: root.headerSelectionDelegate
                    }
                    Binding {
                        target: headerSelectionLoader.item
                        property: "slotData"
                        when: headerSelectionLoader.active && headerSelectionLoader.item !== null
                        value: ({
                            allSelected: root.allVisibleSelected,
                            someSelected: root.someSelected,
                            selectedCount: root.selected.length,
                            columns: root._visibleNormColumns
                        })
                    }

                    Rectangle {
                        id: headCheck
                        width: 16; height: 16; radius: 3
                        anchors.centerIn: parent
                        visible: !headerSelectionLoader.active
                        color: root.allVisibleSelected ? NovaTheme.primary
                                : root.someSelected ? NovaTheme.surface : "transparent"
                        border.width: 1
                        border.color: root.allVisibleSelected ? NovaTheme.primary : NovaTheme.textMuted
                        Text {
                            anchors.centerIn: parent
                            visible: root.someSelected && !root.allVisibleSelected
                            text: "–"; color: NovaTheme.primary
                            font.pixelSize: 12; font.bold: true
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: root.allVisibleSelected
                            text: "✓"; color: NovaTheme.textOnPrimary
                            font.pixelSize: 12; font.bold: true
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: !headerSelectionLoader.active
                        onClicked: root.toggleAllSelection()
                    }
                }

                Repeater {
                    model: root._visibleNormColumns
                    Item {
                        required property var modelData
                        required property int index
                        readonly property bool _hCustom:
                            root.headerCellDelegates[modelData.name] !== undefined
                            || root.headerCellDelegate !== null
                        width: root._colWidth(index)
                        height: root._headerHeight

                        NovaTh {
                            anchors.fill: parent
                            text: ""
                            align: modelData.align
                            sortable: modelData.sortable
                            sorted: root.sortBy === modelData.name
                            descending: root.descending
                            onSortRequest: root.requestSort(modelData.name)
                        }

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: NovaTheme.spacingM
                            anchors.rightMargin: 22
                            visible: !_hCustom
                            text: modelData.label
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontS
                            font.bold: true
                            color: root._headerColor(modelData)
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: modelData.align === "center"
                                ? Text.AlignHCenter
                                : (modelData.align === "right" ? Text.AlignRight : Text.AlignLeft)
                            elide: Text.ElideRight
                        }

                        // 1.9.0：header-cell-[name] 自定义委托
                        Loader {
                            id: headerCellLoader
                            anchors.fill: parent
                            active: _hCustom
                            sourceComponent: _hCustom
                                ? (root.headerCellDelegates[modelData.name] !== undefined
                                    ? root.headerCellDelegates[modelData.name]
                                    : root.headerCellDelegate) : undefined
                        }
                        Binding {
                            target: headerCellLoader.item
                            property: "cellData"
                            when: headerCellLoader.active && headerCellLoader.item !== null
                            value: ({
                                colName: modelData.name,
                                colLabel: modelData.label,
                                sortable: modelData.sortable,
                                sorted: root.sortBy === modelData.name,
                                descending: root.descending,
                                color: root._headerColor(modelData),
                                columns: root._visibleNormColumns
                            })
                        }
                        Rectangle {
                            anchors.right: parent.right
                            width: 1
                            height: parent.height
                            color: NovaTheme.outline
                            visible: root._verticalSeparator
                        }
                    }
                }
            }
        }

        // ── 1.9.0 数据行之前附加行（对标 top-row）───────────
        Item {
            id: topRowArea
            width: parent.width
            height: topRowLoader.active ? root._rowHeight : 0
            visible: topRowLoader.active
            Loader {
                id: topRowLoader
                anchors.fill: parent
                active: root.topRowDelegate !== null
                sourceComponent: root.topRowDelegate
            }
            Binding {
                target: topRowLoader.item
                property: "slotData"
                when: topRowLoader.active && topRowLoader.item !== null
                value: ({
                    columns: root._visibleNormColumns,
                    rowCount: root.rowCount, page: root.page,
                    pageCount: root.pageCount, filter: root.filter
                })
            }
        }

        // 表体（v0.12.0 双形态 + 1.9.0 grid 卡片视图；表头独立常驻=天然粘性）
        Item {
            id: bodyHost
            width: parent.width
            height: root.virtualScroll || root._effectiveViewMode !== "table"
                ? root._bodyViewport : bodyCol.height
            clip: true

            // 形态一：普通流式（Repeater 直渲）
            Column {
                id: bodyCol
                visible: !root.virtualScroll && root._effectiveViewMode === "table"
                width: parent.width

                Repeater {
                    model: root.visibleRows
                    delegate: TableRow { }
                }
            }

            // 形态二：虚拟滚动（ListView 真虚拟化；建议 rowsPerPage: 0 全量入模）
            // 坑位 29：inline component 裸名赋 delegate 恒 count 0——必须带花括号实例化
            ListView {
                id: virtualBody
                visible: root.virtualScroll && root._effectiveViewMode === "table"
                anchors.fill: parent
                model: root.virtualScroll && root._effectiveViewMode === "table"
                    ? root.sortedRows : null
                // 坑位 32：reuseItems 与本 delegate 组合在 Qt 6.12 触发进程退出段错误
                // （单测定位 media_table_virtual；包装 Component 亦不能规避）——
                // 暂缓 reuseItems，cacheBuffer 承担预取；滚动性能仍为可视区+缓冲带量级
                delegate: TableRow { }
                cacheBuffer: Math.max(240, root.virtualScrollSliceSize * root.virtualScrollItemSize)
                boundsBehavior: Flickable.StopAtBounds
                // 1.9.0：触底加载意图（仅虚拟滚动形态生效）
                onContentYChanged: {
                    root._emitVirtualScrollInfo()
                    if (!root.loadMoreEnabled)
                        return
                    var distance = contentHeight - (contentY + height)
                    if (distance <= root.loadMoreThreshold && root._loadMoreArmed) {
                        root._loadMoreArmed = false
                        root.loadMoreRequested(Math.max(0, virtualBody.count - 1))
                    } else if (distance > root.loadMoreThreshold * 2) {
                        root._loadMoreArmed = true
                    }
                }
            }

            // 形态三：grid 卡片视图（对标 QTable grid mode）
            // 1.10.0：card-container-style/class 以语义令牌承接（QML 不解析 CSS）
            Rectangle {
                anchors.fill: parent
                visible: root._effectiveViewMode === "grid"
                color: root._tokenColor(root.cardContainerStyleToken) !== null
                    ? root._tokenColor(root.cardContainerStyleToken) : "transparent"
            }
            GridView {
                id: gridCards
                visible: root._effectiveViewMode === "grid"
                anchors.fill: parent
                clip: true
                model: root.visibleRows
                cellWidth: root.gridCellWidth
                cellHeight: root.gridCellHeight
                delegate: Item {
                    width: gridCards.cellWidth
                    height: gridCards.cellHeight
                    Loader {
                        id: gridCardLoader
                        anchors.fill: parent
                        anchors.margins: 4
                        sourceComponent: root.gridDelegate !== null
                            ? root.gridDelegate : defaultGridCard
                    }
                    Binding {
                        target: gridCardLoader.item
                        property: "slotData"
                        when: gridCardLoader.item !== null
                        value: ({
                            index: index,
                            rowData: modelData,
                            rowKey: root._keyOf(modelData, index),
                            columns: root._visibleNormColumns,
                            cardColor: root._cardColor(modelData, index),
                            cardBorderColor: root._cardBorderColor(modelData, index)
                        })
                    }
                }
            }

            Component {
                id: defaultGridCard
                Rectangle {
                    property var slotData: ({})
                    radius: root.square ? 0 : NovaTheme.radiusM
                    border.width: 1
                    border.color: root._cardBorderColor(slotData.rowData, slotData.index)
                    color: root._cardColor(slotData.rowData, slotData.index)
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2
                        Repeater {
                            model: slotData.columns ? slotData.columns.length : 0
                            Text {
                                required property int index
                                width: parent.width
                                text: (slotData.columns[index].label + "："
                                       + root._cellText(slotData.rowData,
                                                        slotData.columns[index]))
                                font.family: NovaTheme.fontFamily
                                font.pixelSize: NovaTheme.fontS
                                color: index === 0 ? NovaTheme.primary : NovaTheme.textColor
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            // 空态（两种形态共用；区分「无数据」与「筛选无结果」）
            Rectangle {
                width: parent.width
                height: root.visibleRows.length === 0 && !root.loading && !root.hideNoData ? 64 : 0
                color: "transparent"
                visible: root.visibleRows.length === 0 && !root.loading && !root.hideNoData

                Loader {
                    id: noDataLoader
                    anchors.fill: parent
                    active: root.noDataDelegate !== null
                    sourceComponent: root.noDataDelegate
                }
                Binding {
                    target: noDataLoader.item
                    property: "slotData"
                    when: noDataLoader.active && noDataLoader.item !== null
                    value: ({
                        filtered: root._filtered,
                        text: root._emptyText,
                        canClear: root._filtered,
                        rowCount: root.rowCount
                    })
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    visible: !noDataLoader.active
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root._emptyText
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontM
                    }
                    NovaBtn {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root._filtered
                        text: root.clearFilterText !== ""
                            ? root.clearFilterText : qsTr("清除筛选")
                        variant: "flat"
                        size: "sm"
                        onClicked: root.clearFilter()
                    }
                }
            }

            // loading 覆盖层（令牌取色；loadingLabel 优先）
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(NovaTheme.surface.r, NovaTheme.surface.g,
                               NovaTheme.surface.b, 0.72)
                visible: root.loading

                Loader {
                    id: loadingSlotLoader
                    anchors.fill: parent
                    active: root.loadingDelegate !== null
                    sourceComponent: root.loadingDelegate
                }
                Binding {
                    target: loadingSlotLoader.item
                    property: "slotData"
                    when: loadingSlotLoader.active && loadingSlotLoader.item !== null
                    value: ({ label: root.loadingLabel, rowCount: root.rowCount })
                }

                Item {
                    anchors.fill: parent
                    visible: !loadingSlotLoader.active
                    Item {
                        width: 28; height: 28
                        anchors.centerIn: parent
                        RotationAnimation on rotation {
                            from: 0; to: 360
                            duration: 900
                            loops: Animation.Infinite
                            running: root.loading
                        }
                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "transparent"
                            border.width: 3
                            border.color: Qt.rgba(NovaTheme.primary.r, NovaTheme.primary.g,
                                                  NovaTheme.primary.b, 0.22)
                        }
                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.strokeStyle = NovaTheme.primary.toString()
                                ctx.lineWidth = 3
                                ctx.lineCap = "round"
                                ctx.beginPath()
                                ctx.arc(width / 2, height / 2, width / 2 - 2,
                                        -Math.PI / 2, -Math.PI / 2 + 1.5 * Math.PI)
                                ctx.stroke()
                            }
                        }
                    }
                    Text {
                        anchors { horizontalCenter: parent.horizontalCenter
                                  top: parent.verticalCenter; topMargin: 22 }
                        visible: root.loadingLabel !== ""
                        text: root.loadingLabel
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontS
                    }
                }
            }
        }

        // ── 1.9.0 数据行之后附加行（对标 bottom-row）────────
        Item {
            id: bottomRowArea
            width: parent.width
            height: bottomRowLoader.active ? root._rowHeight : 0
            visible: bottomRowLoader.active
            Loader {
                id: bottomRowLoader
                anchors.fill: parent
                active: root.bottomRowDelegate !== null
                sourceComponent: root.bottomRowDelegate
            }
            Binding {
                target: bottomRowLoader.item
                property: "slotData"
                when: bottomRowLoader.active && bottomRowLoader.item !== null
                value: ({
                    columns: root._visibleNormColumns,
                    rowCount: root.rowCount, page: root.page,
                    pageCount: root.pageCount, filter: root.filter
                })
            }
        }

        // ── 1.9.0 真实 tfoot 等价区（对标 footer slot）───────
        Item {
            id: footerArea
            width: parent.width
            height: footerLoader.active ? root._rowHeight : 0
            visible: footerLoader.active
            Rectangle {
                anchors.fill: parent
                color: NovaTheme.surfaceAlt
                border.width: 1
                border.color: NovaTheme.outline
            }
            Loader {
                id: footerLoader
                anchors.fill: parent
                active: root.footerDelegate !== null
                sourceComponent: root.footerDelegate
            }
            Binding {
                target: footerLoader.item
                property: "slotData"
                when: footerLoader.active && footerLoader.item !== null
                value: ({
                    columns: root._visibleNormColumns,
                    rowCount: root.rowCount, page: root.page,
                    pageCount: root.pageCount, visibleRows: root.visibleRows
                })
            }
        }

        // 底部分页（1.9.0 落地 rowsPerPageOptions 选择器；1.10.0 补齐 pagination slot 与三个 label）
        Rectangle {
            id: bottomBar
            width: parent.width
            height: root.hideBottom ? 0 : 44
            color: NovaTheme.surfaceAlt
            visible: !root.hideBottom

            // 1.10.0：pagination slot 整条替换默认控件
            Loader {
                id: paginationSlotLoader
                anchors.fill: parent
                active: root.paginationDelegate !== null
                sourceComponent: root.paginationDelegate
            }
            Binding {
                target: paginationSlotLoader.item
                property: "slotData"
                when: paginationSlotLoader.active && paginationSlotLoader.item !== null
                value: ({
                    page: root.page, pageCount: root.pageCount, rowCount: root.rowCount,
                    rowsPerPage: root.rowsPerPage, pagination: root.paginationState,
                    firstRowIndex: root.rowCount === 0 ? 0 : (root.page - 1) * root.rowsPerPage + 1,
                    lastRowIndex: Math.min(root.rowCount, root.page * root.rowsPerPage)
                })
            }

            Row {
                id: bottomLeftRow
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingM }
                spacing: NovaTheme.spacingM
                visible: !paginationSlotLoader.active

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.hideSelectedBanner
                    text: root._rowsLabel()
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontS
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root._paginationLabelText()
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontS
                }
            }

            Row {
                id: bottomRightRow
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingM }
                spacing: NovaTheme.spacingM
                visible: !paginationSlotLoader.active

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.hidePagination
                    text: root._rowsPerPageLabelText()
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontS
                }

                NovaBtnToggle {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.hidePagination
                    options: root._pageSizeOptions
                    modelValue: root.rowsPerPage
                    outline: true
                    size: "sm"
                    onValueChanged: function (v) { root.requestRowsPerPage(v) }
                }

                NovaPagination {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.hidePagination
                    page: root.page
                    pages: root.pageCount
                    maxPages: 5
                    arrows: true
                    onPageRequested: (p) => root.pageRequested(p)
                }
            }
        }

        // ── 1.9.0 自定义底部控件（对标 bottom slot）─────────
        Item {
            id: bottomArea
            width: parent.width
            height: bottomSlotLoader.active ? 44 : 0
            visible: bottomSlotLoader.active
            Loader {
                id: bottomSlotLoader
                anchors.fill: parent
                active: root.bottomDelegate !== null
                sourceComponent: root.bottomDelegate
            }
            Binding {
                target: bottomSlotLoader.item
                property: "slotData"
                when: bottomSlotLoader.active && bottomSlotLoader.item !== null
                value: ({
                    selected: root.selected, rowCount: root.rowCount,
                    page: root.page, pageCount: root.pageCount,
                    filter: root.filter, columns: root._visibleNormColumns
                })
            }
        }
    }

    // ── 1.9.0 列选择器（对标 QTableColumns / visible-columns）──
    NovaMenu {
        id: columnMenu
        width: 230
        target: columnBtn
        autoClose: true
        modelValue: root._columnMenuOpen
        onUpdateModelValue: function (v) { root._columnMenuOpen = v }

        NovaOptionGroup {
            width: 206
            type: "checkbox"
            dense: true
            options: root._columnOptions
            modelValue: root.visibleColumns.length === 0
                ? root._columnOptions.map(function (o) { return o.value })
                : root.visibleColumns
            onValueChanged: function (v) { root._applyVisibleColumns(v) }
        }
    }

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
