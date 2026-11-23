// src/pyside_nova/qml/Nova/Controls/NovaTable.qml
// NovaTable 数据表格（对标 QTable）
// v0.11.0 基础：列定义/排序/过滤/分页/多选/展开行/grid 模式
// v0.12.0 增强：虚拟滚动（virtualScroll + ListView 真虚拟化）/ 服务端模式
// （serverSide + rowsNumber + request 信号 + requestServerInteraction/setPagination/firstPage）
// / loading 状态层 / noDataLabel / loadingLabel；表头独立于表体滚动区，天然粘性
// 受控模式（坑位 22）：selected/expanded/sortBy/descending/page 均不自写，
// 只 emit updateSelected/updateExpanded/sortChanged/pageRequested/request 由宿主写回
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
    property var columns: []               // [{name,label,field,align,sortable,cellStyle}] 或字符串
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

    // ── 排序（受控） ────────────────────────────────────────
    property string sortBy: ""
    property bool descending: false
    property bool binaryStateSort: false   // true=升↔降两态；false=三态（无序→升→降→无序）

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
    property bool grid: false              // 网格模式（单元格描边）
    property bool flat: false
    property bool bordered: !flat

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

    signal rowClicked(var row, int index)
    signal rowDoubleClicked(var row)
    signal updateSelected(var rows)
    signal updateExpanded(var keys)
    signal sortChanged(string field, bool desc)
    signal pageRequested(int page)
    signal request(var params)   // 服务端模式：{ pagination: {sortBy,descending,page,rowsPerPage,rowsNumber}, filter }

    radius: NovaTheme.radiusL
    color: NovaTheme.surface
    border.width: bordered ? 1 : 0
    border.color: NovaTheme.outline
    implicitWidth: 640
    implicitHeight: titleArea.height + headerRow.height + bodyHost.height
                    + (hideBottom ? 0 : bottomBar.height) + 2

    // 虚拟滚动模式：宿主应给定 height；未给定时回落 320 视口
    readonly property real _bodyViewport: Math.max(virtualScrollItemSize,
        ((height > 0 ? height : 320) - titleArea.height - headerRow.height
         - (hideBottom ? 0 : bottomBar.height) - 2))

    function scrollTo(i) {
        // 虚拟滚动模式跳转到指定行（对标 scrollTo()）
        if (!virtualScroll || virtualBody.count === 0) return
        virtualBody.positionViewAtIndex(
            Math.min(Math.max(0, Math.floor(i)), virtualBody.count - 1),
            ListView.Beginning)
    }

    // 虚拟滚动内部状态（诊断/测试用）
    readonly property int virtualRowCount: virtualBody.count
    readonly property real virtualContentY: virtualBody.contentY
    readonly property real virtualContentHeight: virtualBody.contentHeight

    // ── 工具函数 ────────────────────────────────────────────
    function _normCol(c) {
        if (typeof c === "string")
            return { name: c, label: c, field: c, align: "left", sortable: true }
        return {
            name: c.name, label: c.label !== undefined ? c.label : c.name,
            field: c.field !== undefined ? c.field : c.name,
            align: c.align || "left",
            sortable: c.sortable !== false,
            cellStyle: c.cellStyle || null
        }
    }
    readonly property var normColumns: columns.map(_normCol)

    function _keyOf(row, i) {
        return rowKey && row[rowKey] !== undefined ? String(row[rowKey]) : String(i)
    }

    function _cellText(row, col) {
        var v = row[col.field]
        return v === undefined || v === null ? "" : String(v)
    }

    function _filterRows() {
        var src = rows
        if (!filter || filter === "")
            return src
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

    function _cmp(a, b, field) {
        var va = a[field], vb = b[field]
        if (typeof va === "number" && typeof vb === "number")
            return va - vb
        return String(va === undefined ? "" : va)
            .localeCompare(String(vb === undefined ? "" : vb))
    }

    function _sortRows(src) {
        if (!sortBy)
            return src
        var col = null
        for (var i = 0; i < normColumns.length; i++)
            if (normColumns[i].name === sortBy) col = normColumns[i]
        var field = col ? col.field : sortBy
        var out = src.slice()
        out.sort(function (a, b) {
            var r = _cmp(a, b, field)
            return descending ? -r : r
        })
        return out
    }

    // ── 选择（受控：返回下一状态供宿主写回） ────────────────
    // 坑位 27：Qt6 信号参数会把 JS 对象深拷贝，选中态一律按键值比较（rowKey 或 JSON 全等）
    function _keyVal(row) {
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
    function requestSort(name) {
        if (sortBy !== name) {
            sortChanged(name, false)
            _emitServerRequest(name, false, 1)
            return { sortBy: name, descending: false }
        }
        if (!descending) {
            sortChanged(name, true)
            _emitServerRequest(name, true, 1)
            return { sortBy: name, descending: true }
        }
        if (binaryStateSort) {
            sortChanged(name, false)
            _emitServerRequest(name, false, 1)
            return { sortBy: name, descending: false }
        }
        sortChanged("", false)
        _emitServerRequest("", false, 1)
        return { sortBy: "", descending: false }
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

        NovaTr {
            id: tr
            width: parent.width
            selected: rowWrap.rowSelected
            Row {
                // 单选/多选列
                Item {
                    width: root.singleSelection ? 0 : 44
                    height: parent.height
                    visible: !root.singleSelection
                    Rectangle {
                        width: 16; height: 16; radius: 3
                        anchors.centerIn: parent
                        color: rowWrap.rowSelected ? NovaTheme.primary : "transparent"
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
                        onClicked: root.toggleRowSelection(rowWrap.rowData)
                    }
                }
                Repeater {
                    model: root.normColumns
                    NovaTd {
                        required property var modelData
                        text: root._cellText(rowWrap.rowData, modelData)
                        align: modelData.align
                        width: Math.max(80, (tr.width - (root.singleSelection ? 0 : 44)) / root.normColumns.length)
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: root.grid ? 1 : 0
                            border.color: NovaTheme.outline
                        }
                    }
                }
            }
            onRowClicked: root.rowClicked(rowWrap.rowData, rowWrap.rowIdx)
            onRowDoubleClicked: root.rowDoubleClicked(rowWrap.rowData, rowWrap.rowIdx)
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
        Rectangle { width: parent.width; height: 1; color: NovaTheme.outline; opacity: 0.5 }
    }

    // ══════════════════════════════════════════════════════════
    Column {
        id: shell
        anchors.fill: parent

        // 标题
        Rectangle {
            id: titleArea
            width: parent.width
            height: root.title !== "" ? 44 : 0
            color: "transparent"
            Text {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingM }
                text: root.title
                color: NovaTheme.textColor
                font.pixelSize: NovaTheme.fontL
                font.weight: Font.Medium
            }
        }

        // 表头（粘性语义：分页模式行数有限，表头常驻）
        Rectangle {
            id: headerRow
            width: parent.width
            height: root.hideHeader ? 0 : 44
            color: NovaTheme.surfaceAlt
            visible: !root.hideHeader

            Row {
                anchors.fill: parent

                // 多选列表头
                Item {
                    width: root.singleSelection ? 0 : 44
                    height: parent.height
                    visible: !root.singleSelection
                    Rectangle {
                        id: headCheck
                        width: 16; height: 16; radius: 3
                        anchors.centerIn: parent
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
                        onClicked: root.toggleAllSelection()
                    }
                }

                Repeater {
                    model: root.normColumns
                    NovaTh {
                        required property var modelData
                        text: modelData.label
                        align: modelData.align
                        sortable: modelData.sortable
                        sorted: root.sortBy === modelData.name
                        descending: root.descending
                        width: Math.max(80, (headerRow.width - (root.singleSelection ? 0 : 44)) / root.normColumns.length)
                        onSortRequest: root.requestSort(modelData.name)
                    }
                }
            }
        }

        // 表体（v0.12.0 双形态：普通流式 / 虚拟滚动；表头独立常驻=天然粘性）
        Item {
            id: bodyHost
            width: parent.width
            height: root.virtualScroll ? root._bodyViewport : bodyCol.height
            clip: true

            // 形态一：普通流式（Repeater 直渲）
            Column {
                id: bodyCol
                visible: !root.virtualScroll
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
                visible: root.virtualScroll
                anchors.fill: parent
                model: root.virtualScroll ? root.sortedRows : null
                // 坑位 32：reuseItems 与本 delegate 组合在 Qt 6.12 触发进程退出段错误
                // （单测定位 media_table_virtual；包装 Component 亦不能规避）——
                // 暂缓 reuseItems，cacheBuffer 承担预取；滚动性能仍为可视区+缓冲带量级
                delegate: TableRow { }
                cacheBuffer: 240
                boundsBehavior: Flickable.StopAtBounds
            }

            // 空态（两种形态共用；noDataLabel 优先）
            Rectangle {
                width: parent.width
                height: root.visibleRows.length === 0 && !root.loading ? 64 : 0
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    visible: root.visibleRows.length === 0 && !root.loading
                    text: root.noDataLabel !== "" ? root.noDataLabel : "暂无数据"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontM
                }
            }

            // loading 覆盖层（令牌取色；loadingLabel 优先）
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(NovaTheme.surface.r, NovaTheme.surface.g,
                               NovaTheme.surface.b, 0.72)
                visible: root.loading

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

        // 底部分页
        Rectangle {
            id: bottomBar
            width: parent.width
            height: root.hideBottom ? 0 : 44
            color: NovaTheme.surfaceAlt
            visible: !root.hideBottom

            Row {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingM }
                spacing: NovaTheme.spacingM

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "共 " + root.rowCount + " 条 · 已选 " + root.selected.length
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontS
                }
            }

            Row {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingM }
                spacing: NovaTheme.spacingM

                NovaPagination {
                    anchors.verticalCenter: parent.verticalCenter
                    page: root.page
                    pages: root.pageCount
                    maxPages: 5
                    arrows: true
                    onPageRequested: (p) => root.pageRequested(p)
                }
            }
        }
    }

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
