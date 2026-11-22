// src/pyside_nova/qml/Nova/Controls/NovaTable.qml
// NovaTable 数据表格（对标 QTable）
// v0.11.0 基础：列定义/排序/过滤/分页/多选/展开行/grid 模式
// （虚拟滚动与服务端模式 → v0.12.0）
// 受控模式（坑位 22）：selected/expanded/sortBy/descending/page 均不自写，
// 只 emit updateSelected/updateExpanded/sortChanged/pageRequested 由宿主写回
import QtQuick
import Nova.Controls
import Nova.Services

Rectangle {
    id: root

    // ── 数据 ────────────────────────────────────────────────
    property var columns: []               // [{name,label,field,align,sortable,cellStyle}] 或字符串
    property var rows: []
    property string rowKey: ""             // 行键字段名；空则用原始行序号
    property string filter: ""             // 客户端过滤（全字段包含匹配）
    property var filterMethod: null        // 自定义过滤 function(row, filter) -> bool

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

    // ── 派生数据（管道：过滤 → 排序 → 分页） ────────────────
    readonly property var filteredRows: _filterRows()
    readonly property var sortedRows: _sortRows(filteredRows)
    readonly property int rowCount: sortedRows.length
    readonly property int pageCount: rowsPerPage > 0 ? Math.max(1, Math.ceil(rowCount / rowsPerPage)) : 1
    readonly property var visibleRows: rowsPerPage > 0
        ? sortedRows.slice((page - 1) * rowsPerPage, page * rowsPerPage)
        : sortedRows
    readonly property bool allVisibleSelected: visibleRows.length > 0 && _allSelected()
    readonly property bool someSelected: selected.length > 0 && !allVisibleSelected

    signal rowClicked(var row, int index)
    signal rowDoubleClicked(var row)
    signal updateSelected(var rows)
    signal updateExpanded(var keys)
    signal sortChanged(string field, bool desc)
    signal pageRequested(int page)

    radius: NovaTheme.radiusL
    color: NovaTheme.surface
    border.width: bordered ? 1 : 0
    border.color: NovaTheme.outline
    implicitWidth: 640
    implicitHeight: titleArea.height + headerRow.height + bodyCol.height
                    + (hideBottom ? 0 : bottomBar.height) + 2

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
    function requestSort(name) {
        if (sortBy !== name) {
            sortChanged(name, false)
            return { sortBy: name, descending: false }
        }
        if (!descending) {
            sortChanged(name, true)
            return { sortBy: name, descending: true }
        }
        if (binaryStateSort) {
            sortChanged(name, false)
            return { sortBy: name, descending: false }
        }
        sortChanged("", false)
        return { sortBy: "", descending: false }
    }

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
        if (next !== page)
            pageRequested(next)
        return next
    }
    function nextPage() { return requestPage(page + 1) }
    function prevPage() { return requestPage(page - 1) }

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

        // 表体
        Column {
            id: bodyCol
            width: parent.width

            Repeater {
                model: root.visibleRows

                Column {
                    id: rowWrap
                    required property var modelData
                    required property int index
                    width: parent.width

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
            }

            // 空态
            Rectangle {
                width: parent.width
                height: root.visibleRows.length === 0 ? 64 : 0
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    visible: root.visibleRows.length === 0
                    text: "暂无数据"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontM
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
}
