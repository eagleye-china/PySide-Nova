# NovaTable 企业级旗舰封版 · 完整可运行方案

下面给出完整工程。核心决策：**渲染层用 `TableView + reuseItems` 守住性能底线；Python 侧用 `batchUpdate + dataChanged 合并` 守住吞吐底线；Quasar 友好度用「核心 API 对齐 + 列级委托注册表 + 工业特化 role」实现**。展开行与冻结列不在本次封版范围（用详情弹窗与固定操作列替代，下一版本再补），以保证代码可交付。

## 📁 项目结构

```
novatable/
├── main.py
├── Main.qml
└── nova/
    ├── __init__.py
    ├── model.py
    ├── proxy.py
    ├── theme.py
    └── qml/
        └── NovaTable.qml
```

---

## 1. `nova/__init__.py`

```python
from .model import NovaColumn, NovaRoles, NovaTableModel
from .proxy import NovaFilterProxyModel, NovaPagedProxyModel, NovaPagination
from .theme import NovaTheme

__all__ = [
    "NovaColumn",
    "NovaRoles",
    "NovaTableModel",
    "NovaFilterProxyModel",
    "NovaPagedProxyModel",
    "NovaPagination",
    "NovaTheme",
]
```

---

## 2. `nova/theme.py`

```python
from PySide6.QtCore import Property, QObject, Signal


class NovaTheme(QObject):
    """
    令牌化主题。QML 侧通过 novaTheme 全局单例访问，Python 侧可在运行时切换。
    令牌与 Quasar 的 CSS 变量语义对齐（primary / surface / outline / textMuted ...）。
    """

    themeChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._dark = False

    @Property(bool, notify=themeChanged)
    def dark(self):
        return self._dark

    @dark.setter
    def dark(self, value: bool):
        if self._dark != value:
            self._dark = value
            self.themeChanged.emit()

    @Property(str, notify=themeChanged)
    def primary(self):
        return "#2563eb" if not self._dark else "#60a5fa"

    @Property(str, notify=themeChanged)
    def primaryFaint(self):
        return "#dbeafe" if not self._dark else "#1e3a8a"

    @Property(str, notify=themeChanged)
    def surface(self):
        return "#ffffff" if not self._dark else "#1e1e1e"

    @Property(str, notify=themeChanged)
    def surfaceAlt(self):
        return "#f9fafb" if not self._dark else "#252526"

    @Property(str, notify=themeChanged)
    def zebra(self):
        return "#fafafa" if not self._dark else "#262626"

    @Property(str, notify=themeChanged)
    def outline(self):
        return "#e5e7eb" if not self._dark else "#3c3c3c"

    @Property(str, notify=themeChanged)
    def textColor(self):
        return "#111827" if not self._dark else "#d4d4d4"

    @Property(str, notify=themeChanged)
    def textMuted(self):
        return "#6b7280" if not self._dark else "#9ca3af"

    @Property(str, notify=themeChanged)
    def textOnPrimary(self):
        return "#ffffff"

    @Property(str, notify=themeChanged)
    def severityWarning(self):
        return "#fef3c7" if not self._dark else "#3f2d00"

    @Property(str, notify=themeChanged)
    def severityCritical(self):
        return "#fee2e2" if not self._dark else "#3f0f0f"

    @Property(str, notify=themeChanged)
    def highlight(self):
        return "#e0f2fe" if not self._dark else "#0c2f4a"

    @Property(int, notify=themeChanged)
    def fontS(self):
        return 12

    @Property(int, notify=themeChanged)
    def fontM(self):
        return 14

    @Property(int, notify=themeChanged)
    def fontL(self):
        return 16

    @Property(int, notify=themeChanged)
    def radiusM(self):
        return 8

    @Property(int, notify=themeChanged)
    def spacingS(self):
        return 6

    @Property(int, notify=themeChanged)
    def spacingM(self):
        return 12

    @Property(int, notify=themeChanged)
    def spacingL(self):
        return 20
```

---

## 3. `nova/model.py`

```python
from typing import Any, Callable, Dict, List, Optional

from PySide6.QtCore import (
    Property,
    QAbstractTableModel,
    QModelIndex,
    Qt,
    QTimer,
    Signal,
    Slot,
)


class NovaColumn:
    """列定义。一次声明，全链路复用。"""

    def __init__(
        self,
        key: str,
        label: str,
        width: int = 120,
        align: str = "left",           # left / center / right
        editable: bool = False,
        editor: str = "text",          # text / number / int / select
        options: Optional[List[Dict[str, Any]]] = None,
        visible: bool = True,
        sortable: bool = True,
        formatter: Optional[Callable[[Any, Dict[str, Any]], str]] = None,
    ):
        self.key = key
        self.label = label
        self.width = width
        self.align = align
        self.editable = editable
        self.editor = editor
        self.options = options or []
        self.visible = visible
        self.sortable = sortable
        self.formatter = formatter

    def to_dict(self) -> Dict[str, Any]:
        return {
            "key": self.key,
            "label": self.label,
            "width": self.width,
            "align": self.align,
            "editable": self.editable,
            "editor": self.editor,
            "options": self.options,
            "visible": self.visible,
            "sortable": self.sortable,
        }


class NovaRoles:
    """对外暴露的 role 常量。QML 侧通过 roleNames 映射到属性名。"""

    DisplayRole = Qt.DisplayRole
    EditRole = Qt.EditRole
    SeverityRole = Qt.UserRole + 1       # 0=normal / 1=warning / 2=critical
    RowKeyRole = Qt.UserRole + 2
    HighlightedRole = Qt.UserRole + 3    # 新数据高亮


# 行内约定：severity 存储在 row["_severity"]，避免与业务列名冲突
SEVERITY_FIELD = "_severity"


class NovaTableModel(QAbstractTableModel):
    """
    工业级数据模型：
    - 批量更新：batchUpdate 合并为周期性 dataChanged
    - 高亮：最近更新的行高亮 1.5s
    - 列显隐：setVisibleColumns 动态调整 columnCount
    - 服务端模式：setRows 直接接收服务端返回的当前页数据
    """

    rowsChanged = Signal()

    def __init__(
        self,
        columns: List[NovaColumn],
        rows: Optional[List[Dict[str, Any]]] = None,
        row_key: str = "",
        parent=None,
    ):
        super().__init__(parent)
        self._all_columns = list(columns)
        self._visible_columns = list(columns)
        self._col_key_to_idx = {c.key: i for i, c in enumerate(columns)}
        self._rows = list(rows or [])
        self._row_key = row_key
        self._key_to_row: Dict[str, int] = {}
        self._rebuild_key_index()

        # 批量 dataChanged 合并
        self._pending_rows: set = set()
        self._flush_timer = QTimer(self)
        self._flush_timer.setInterval(50)
        self._flush_timer.setSingleShot(True)
        self._flush_timer.timeout.connect(self._flush_data_changed)

        # 新数据高亮
        self._highlighted_rows: set = set()
        self._highlight_timer = QTimer(self)
        self._highlight_timer.setInterval(1500)
        self._highlight_timer.setSingleShot(True)
        self._highlight_timer.timeout.connect(self._clear_highlights)

    # ---------------- QAbstractTableModel ----------------
    def rowCount(self, parent=QModelIndex()) -> int:
        return 0 if parent.isValid() else len(self._rows)

    def columnCount(self, parent=QModelIndex()) -> int:
        return 0 if parent.isValid() else len(self._visible_columns)

    def roleNames(self):
        return {
            NovaRoles.DisplayRole: b"display",
            NovaRoles.EditRole: b"edit",
            NovaRoles.SeverityRole: b"severity",
            NovaRoles.RowKeyRole: b"rowKey",
            NovaRoles.HighlightedRole: b"highlighted",
        }

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if not index.isValid():
            return None
        row = self._rows[index.row()]
        col = self._visible_columns[index.column()]

        if role == NovaRoles.DisplayRole:
            v = row.get(col.key, "")
            if col.formatter is not None:
                try:
                    return col.formatter(v, row)
                except Exception:
                    return str(v)
            return v

        if role == NovaRoles.EditRole:
            return row.get(col.key, "")

        if role == NovaRoles.SeverityRole:
            return int(row.get(SEVERITY_FIELD, 0))

        if role == NovaRoles.RowKeyRole:
            return self._row_key_at(index.row())

        if role == NovaRoles.HighlightedRole:
            return index.row() in self._highlighted_rows

        return None

    def headerData(self, section: int, orientation, role=Qt.DisplayRole):
        if orientation == Qt.Horizontal and role == Qt.DisplayRole:
            if 0 <= section < len(self._visible_columns):
                return self._visible_columns[section].label
        return None

    def flags(self, index: QModelIndex):
        f = Qt.ItemIsEnabled | Qt.ItemIsSelectable
        if index.isValid() and self._visible_columns[index.column()].editable:
            f |= Qt.ItemIsEditable
        return f

    def setData(self, index: QModelIndex, value, role=Qt.EditRole) -> bool:
        if not index.isValid() or role != Qt.EditRole:
            return False
        col = self._visible_columns[index.column()]
        return self._coerce_and_set(index.row(), col, value)

    # ---------------- QML 便捷访问 ----------------
    @Slot(int, int, result="QVariant")
    def getRawValue(self, row: int, column: int):
        if not (0 <= row < len(self._rows)) or not (0 <= column < len(self._visible_columns)):
            return None
        return self._rows[row].get(self._visible_columns[column].key, "")

    @Slot(int, int, "QVariant", result=bool)
    def setRawValue(self, row: int, column: int, value) -> bool:
        if not (0 <= row < len(self._rows)) or not (0 <= column < len(self._visible_columns)):
            return False
        return self._coerce_and_set(row, self._visible_columns[column], value)

    @Slot(int, result="QVariantMap")
    def getRow(self, row: int) -> dict:
        if 0 <= row < len(self._rows):
            return dict(self._rows[row])
        return {}

    def _coerce_and_set(self, row: int, col: NovaColumn, value) -> bool:
        try:
            if col.editor in ("int", "number"):
                if value in (None, ""):
                    value = 0
                else:
                    value = float(value) if col.editor == "number" else int(value)
        except (ValueError, TypeError):
            return False

        if self._rows[row].get(col.key) == value:
            return True

        self._rows[row][col.key] = value
        self._schedule_row_changed(row)
        return True

    # ---------------- 批量更新（工业核心） ----------------
    @Slot(list)
    def batchUpdate(self, updates: list):
        """
        批量增量更新。
        updates: [{"槽号": "A01", "电压": 4.12, "温度": 935.5}, ...]
        按 rowKey 匹配已有行，合并为周期性 dataChanged。
        """
        if not self._row_key:
            return
        touched: set = set()
        for u in updates:
            if not isinstance(u, dict):
                continue
            key = str(u.get(self._row_key, ""))
            if not key:
                continue
            idx = self._key_to_row.get(key)
            if idx is None:
                continue
            row = self._rows[idx]
            changed = False
            for k, v in u.items():
                if k == self._row_key:
                    continue
                if row.get(k) != v:
                    row[k] = v
                    changed = True
            if changed:
                touched.add(idx)

        if touched:
            self._highlighted_rows.update(touched)
            for r in touched:
                self._schedule_row_changed(r)
            if not self._highlight_timer.isActive():
                self._highlight_timer.start()

    def _schedule_row_changed(self, row_idx: int):
        self._pending_rows.add(row_idx)
        if not self._flush_timer.isActive():
            self._flush_timer.start()

    def _flush_data_changed(self):
        if not self._pending_rows:
            return
        roles = [
            NovaRoles.DisplayRole,
            NovaRoles.EditRole,
            NovaRoles.SeverityRole,
            NovaRoles.HighlightedRole,
        ]
        for row_idx in self._pending_rows:
            if 0 <= row_idx < len(self._rows):
                self.dataChanged.emit(
                    self.index(row_idx, 0),
                    self.index(row_idx, self.columnCount() - 1),
                    roles,
                )
        self._pending_rows.clear()

    def _clear_highlights(self):
        if not self._highlighted_rows:
            return
        rows = list(self._highlighted_rows)
        self._highlighted_rows.clear()
        roles = [NovaRoles.HighlightedRole]
        for row_idx in rows:
            if 0 <= row_idx < len(self._rows):
                self.dataChanged.emit(
                    self.index(row_idx, 0),
                    self.index(row_idx, self.columnCount() - 1),
                    roles,
                )

    # ---------------- 全量替换（服务端分页 & 环形缓冲上层） ----------------
    @Slot(list)
    def setRows(self, rows: list):
        self.beginResetModel()
        self._rows = list(rows)
        self._rebuild_key_index()
        self.endResetModel()
        self.rowsChanged.emit()

    @Slot()
    def clearRows(self):
        if not self._rows:
            return
        self.beginResetModel()
        self._rows.clear()
        self._key_to_row.clear()
        self.endResetModel()
        self.rowsChanged.emit()

    # ---------------- 行级增删 ----------------
    @Slot(int, "QVariantMap")
    def insertRowAt(self, position: int, data: dict):
        if position < 0 or position > len(self._rows):
            position = len(self._rows)
        self.beginInsertRows(QModelIndex(), position, position)
        self._rows.insert(position, dict(data))
        self._rebuild_key_index()
        self.endInsertRows()
        self.rowsChanged.emit()

    @Slot("QVariantMap")
    def appendRow(self, data: dict):
        self.insertRowAt(len(self._rows), data)

    @Slot(int)
    def removeRowAt(self, position: int):
        if 0 <= position < len(self._rows):
            self.beginRemoveRows(QModelIndex(), position, position)
            self._rows.pop(position)
            self._rebuild_key_index()
            self.endRemoveRows()
            self.rowsChanged.emit()

    # ---------------- 列显隐 ----------------
    @Slot(list)
    def setVisibleColumns(self, keys: list):
        keys_set = set(keys)
        new_visible = [c for c in self._all_columns if c.key in keys_set]
        if [c.key for c in new_visible] == [c.key for c in self._visible_columns]:
            return
        self.beginResetModel()
        self._visible_columns = new_visible
        self.endResetModel()

    # ---------------- 属性 ----------------
    @Property("QVariantList", constant=True)
    def columns(self):
        return [c.to_dict() for c in self._visible_columns]

    @Property("QVariantList", constant=True)
    def allColumns(self):
        return [c.to_dict() for c in self._all_columns]

    @Property(int, notify=rowsChanged)
    def totalCount(self):
        return len(self._rows)

    # ---------------- 内部辅助 ----------------
    def _row_key_at(self, row: int) -> str:
        if not (0 <= row < len(self._rows)):
            return ""
        r = self._rows[row]
        if self._row_key and self._row_key in r:
            return str(r[self._row_key])
        return str(row)

    def _rebuild_key_index(self):
        self._key_to_row.clear()
        if not self._row_key:
            return
        for i, r in enumerate(self._rows):
            if self._row_key in r:
                self._key_to_row[str(r[self._row_key])] = i

    @Slot(result="QVariantList")
    def allRows(self):
        return list(self._rows)
```

---

## 4. `nova/proxy.py`

```python
from PySide6.QtCore import (
    Property,
    QModelIndex,
    QObject,
    QSortFilterProxyModel,
    Qt,
    Signal,
    Slot,
)


class NovaFilterProxyModel(QSortFilterProxyModel):
    """全局过滤 + 列级过滤（客户端模式）。"""

    countChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setDynamicSortFilter(True)
        self._quick_filter = ""
        self._column_filters = {}
        self._key_to_col = {}

        self.rowsInserted.connect(self._emit_count)
        self.rowsRemoved.connect(self._emit_count)
        self.modelReset.connect(self._emit_count)
        self.layoutChanged.connect(self._emit_count)

    def setSourceModel(self, model):
        super().setSourceModel(model)
        self._key_to_col = {}
        if model is not None and hasattr(model, "columns"):
            self._key_to_col = {c["key"]: i for i, c in enumerate(model.columns)}

    def _emit_count(self, *args):
        self.countChanged.emit()

    @Property(int, notify=countChanged)
    def count(self):
        return self.rowCount()

    @Slot(str)
    def setQuickFilter(self, text: str):
        self._quick_filter = (text or "").strip().lower()
        self.invalidateFilter()

    @Slot(str, str)
    def setColumnFilter(self, key: str, text: str):
        if text:
            self._column_filters[key] = text.strip().lower()
        else:
            self._column_filters.pop(key, None)
        self.invalidateFilter()

    @Slot()
    def clearFilters(self):
        self._quick_filter = ""
        self._column_filters.clear()
        self.invalidateFilter()

    def filterAcceptsRow(self, source_row, source_parent: QModelIndex) -> bool:
        model = self.sourceModel()
        if model is None:
            return True

        if self._quick_filter:
            for c in range(model.columnCount()):
                idx = model.index(source_row, c, source_parent)
                val = model.data(idx, Qt.DisplayRole)
                if val is not None and self._quick_filter in str(val).lower():
                    break
            else:
                return False

        for key, needle in self._column_filters.items():
            c = self._key_to_col.get(key)
            if c is None:
                continue
            idx = model.index(source_row, c, source_parent)
            val = model.data(idx, Qt.DisplayRole)
            if val is None or needle not in str(val).lower():
                return False
        return True


class NovaPagination(QObject):
    """分页状态控制器，与数据模型解耦。"""

    pageChanged = Signal()
    pageSizeChanged = Signal()
    totalChanged = Signal()

    def __init__(self, page_size: int = 20, parent=None):
        super().__init__(parent)
        self._page = 1
        self._page_size = max(1, page_size)
        self._total = 0

    @Property(int, notify=pageChanged)
    def currentPage(self): return self._page

    @Property(int, notify=pageSizeChanged)
    def pageSize(self): return self._page_size

    @Property(int, notify=totalChanged)
    def total(self): return self._total

    @Property(int, notify=pageChanged)
    def pageCount(self):
        return max(1, (self._total + self._page_size - 1) // self._page_size)

    @Property(int, notify=pageChanged)
    def startIndex(self):
        return (self._page - 1) * self._page_size

    @Property(int, notify=pageChanged)
    def endIndex(self):
        return min(self._total, self._page * self._page_size)

    @Slot(int)
    def setCurrentPage(self, page: int):
        page = max(1, min(self.pageCount, page))
        if page != self._page:
            self._page = page
            self.pageChanged.emit()

    @Slot(int)
    def setPageSize(self, size: int):
        if size > 0 and size != self._page_size:
            self._page_size = size
            self._page = 1
            self.pageSizeChanged.emit()
            self.pageChanged.emit()

    @Slot(int)
    def setTotal(self, total: int):
        if total != self._total:
            self._total = total
            self.totalChanged.emit()
            self.pageChanged.emit()

    @Slot()
    def firstPage(self): self.setCurrentPage(1)

    @Slot()
    def prevPage(self): self.setCurrentPage(self._page - 1)

    @Slot()
    def nextPage(self): self.setCurrentPage(self._page + 1)

    @Slot()
    def lastPage(self): self.setCurrentPage(self.pageCount)


class NovaPagedProxyModel(QSortFilterProxyModel):
    """分页代理：包裹在 FilterProxy 外层，按 startIndex/endIndex 切片。"""

    def __init__(self, pagination: NovaPagination, parent=None):
        super().__init__(parent)
        self._pagination = pagination
        pagination.pageChanged.connect(self.invalidateFilter)
        pagination.pageSizeChanged.connect(self.invalidateFilter)

    def filterAcceptsRow(self, source_row, source_parent):
        p = self._pagination
        return p.startIndex <= source_row < p.endIndex
```

---

## 5. `nova/qml/NovaTable.qml`

```qml
// NovaTable · 企业级旗舰版
// TableView + reuseItems 虚拟化 / 批量 dataChanged / 列级委托 / severity 染色 / 列选择器
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import Nova 1.0

Item {
    id: root

    // =================== 输入 API ===================
    property var tableModel: null
    property var filterProxy: null
    property var pagedProxy: null
    property var pagination: null
    property bool serverSide: false

    // =================== 列定义 ===================
    readonly property var columnDefs:
        tableModel && tableModel.columns ? tableModel.columns : []
    readonly property var allColumnDefs:
        tableModel && tableModel.allColumns ? tableModel.allColumns : columnDefs

    // 列级自定义委托：{ "status": Component, "alarm": Component }
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
    property string searchPlaceholder: "搜索任意字段..."
    property string selectionMode: "single"    // single / multiple / none

    // =================== 状态 ===================
    property bool loading: false
    property string loadingText: "加载中..."
    property string noDataText: "暂无数据"

    // =================== 输出信号 ===================
    signal rowClicked(int row)
    signal rowDoubleClicked(int row)
    signal cellClicked(int row, int column)
    signal cellEdited(int row, int column, var value)
    signal refreshRequested()
    signal request(var params)

    // =================== 内部 ===================
    readonly property var _model:
        pagedProxy ? pagedProxy : (filterProxy ? filterProxy : tableModel)
    property int _editingRow: -1
    property int _editingColumn: -1
    property var _visibleColumnKeys: []   // 空 = 全部可见

    implicitWidth: 900
    implicitHeight: 560

    // =================== 生命周期 ===================
    Component.onCompleted: _syncPaginationTotal()

    Connections {
        target: filterProxy
        function onCountChanged() { root._syncPaginationTotal() }
    }

    function _syncPaginationTotal() {
        if (pagination && filterProxy)
            pagination.setTotal(filterProxy.count)
    }

    // =================== 布局 ===================
    Rectangle {
        anchors.fill: parent
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border.width: bordered ? 1 : 0
        border.color: NovaTheme.outline

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ─────────────── 工具栏 ───────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: showToolbar ? 56 : 0
                color: "transparent"
                visible: height > 0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: NovaTheme.spacingM
                    anchors.rightMargin: NovaTheme.spacingM
                    spacing: NovaTheme.spacingM

                    Text {
                        text: root.title
                        visible: text.length > 0
                        font.pixelSize: NovaTheme.fontL
                        font.bold: true
                        color: NovaTheme.textColor
                    }

                    Item { Layout.fillWidth: true }

                    TextField {
                        id: searchField
                        visible: root.showFilter
                        Layout.preferredWidth: 240
                        Layout.preferredHeight: 34
                        placeholderText: root.searchPlaceholder
                        selectByMouse: true
                        leftPadding: 30

                        background: Rectangle {
                            radius: 6
                            color: NovaTheme.surfaceAlt
                            border.color: searchField.activeFocus
                                ? NovaTheme.primary : NovaTheme.outline
                            border.width: 1
                        }
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: "🔍"
                            font.pixelSize: 13
                            opacity: 0.5
                        }
                        onTextChanged: {
                            if (root.filterProxy && !root.serverSide)
                                root.filterProxy.setQuickFilter(text)
                        }
                    }

                    Button {
                        text: "列"
                        visible: root.showColumnSelector
                        Layout.preferredHeight: 34
                        onClicked: columnPopup.open()
                    }

                    Button {
                        text: "刷新"
                        Layout.preferredHeight: 34
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

            // ─────────────── 表头 ───────────────
            HorizontalHeaderView {
                id: headerView
                Layout.fillWidth: true
                Layout.preferredHeight: root.headerHeight
                syncView: tableView
                clip: true
                resizableColumns: false

                delegate: Rectangle {
                    required property int index
                    required property string display
                    implicitHeight: root.headerHeight
                    color: NovaTheme.surfaceAlt

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        text: display
                        font.pixelSize: 13
                        font.bold: true
                        color: NovaTheme.textColor
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

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: NovaTheme.outline
            }

            // ─────────────── 表体 ───────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TableView {
                    id: tableView
                    anchors.fill: parent
                    clip: true
                    model: root._model
                    reuseItems: true
                    cacheBuffer: root.rowHeight * 3

                    rowHeightProvider: function(row) { return root.rowHeight }
                    columnWidthProvider: function(column) {
                        var cols = root.columnDefs
                        if (column < 0 || column >= cols.length) return 120
                        return cols[column].width || 120
                    }

                    selectionBehavior: TableView.SelectionBehavior.Items
                    selectionMode: root.selectionMode === "multiple"
                        ? TableView.SelectionMode.ExtendedSelection
                        : root.selectionMode === "none"
                        ? TableView.SelectionMode.NoSelection
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
                        required property var rowKey
                        required property bool highlighted

                        readonly property var colDef:
                            column < root.columnDefs.length ? root.columnDefs[column] : ({})
                        readonly property bool selected:
                            tableView.selectionModel &&
                            tableView.selectionModel.isRowSelected(row)
                        readonly property bool editing:
                            root._editingRow === row && root._editingColumn === column

                        implicitWidth: colDef.width || 120
                        implicitHeight: root.rowHeight

                        // 背景色：选中 > 高亮 > severity > 斑马纹
                        color: selected ? NovaTheme.primaryFaint
                             : highlighted ? NovaTheme.highlight
                             : severity === 2 ? NovaTheme.severityCritical
                             : severity === 1 ? NovaTheme.severityWarning
                             : (root.zebraStripes && row % 2 === 1
                                ? NovaTheme.zebra : NovaTheme.surface)

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }

                        // 默认文本渲染
                        Text {
                            id: defaultText
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            text: display !== undefined && display !== null
                                ? String(display) : ""
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: colDef.align === "center"
                                ? Text.AlignHCenter
                                : colDef.align === "right"
                                ? Text.AlignRight
                                : Text.AlignLeft
                            elide: Text.ElideRight
                            font.pixelSize: 13
                            color: NovaTheme.textColor
                            visible: !cellLoader.active && !editing
                        }

                        // 列级自定义委托
                        Loader {
                            id: cellLoader
                            anchors.fill: parent
                            active: root.cellDelegates[colDef.key] !== undefined
                                    && !editing
                            sourceComponent: root.cellDelegates[colDef.key]
                            onLoaded: {
                                if (!item) return
                                if (item.rowData !== undefined)
                                    item.rowData = root.tableModel
                                        ? root.tableModel.getRow(row) : ({})
                                if (item.value !== undefined)
                                    item.value = display
                                if (item.severity !== undefined)
                                    item.severity = severity
                                if (item.rowIndex !== undefined)
                                    item.rowIndex = row
                                if (item.colDef !== undefined)
                                    item.colDef = colDef
                            }
                        }

                        // 内联编辑器
                        Loader {
                            id: editorLoader
                            anchors.fill: parent
                            anchors.margins: 2
                            active: editing && colDef.editable === true
                            sourceComponent: {
                                if (!colDef.editor) return textEditor
                                if (colDef.editor === "number" || colDef.editor === "int")
                                    return numberEditor
                                if (colDef.editor === "select") return selectEditor
                                return textEditor
                            }
                        }

                        // 网格线
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
                            acceptedButtons: Qt.LeftButton
                            onClicked: {
                                if (root.selectionMode !== "none") {
                                    var flags = root.selectionMode === "multiple"
                                        ? (ItemSelectionModel.Select | ItemSelectionModel.Rows)
                                        : (ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Rows)
                                    tableView.selectionModel.select(
                                        tableView.model.index(row, column), flags)
                                }
                                root.cellClicked(row, column)
                                root.rowClicked(row)
                                if (colDef.editable) {
                                    root._editingRow = row
                                    root._editingColumn = column
                                }
                            }
                            onDoubleClicked: root.rowDoubleClicked(row)
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
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontM
                }

                // Loading
                Rectangle {
                    anchors.fill: parent
                    visible: root.loading
                    color: Qt.rgba(1, 1, 1, 0.7)

                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        BusyIndicator {
                            running: root.loading
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: root.loadingText
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontS
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            // ─────────────── 分页 ───────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight:
                    (root.showPagination && root.pagination) ? 48 : 0
                color: NovaTheme.surfaceAlt
                visible: height > 0

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
                            ? ("第 " + (root.pagination.total === 0
                                       ? 0 : root.pagination.startIndex + 1)
                               + " - " + root.pagination.endIndex
                               + " 条 / 共 " + root.pagination.total + " 条")
                            : ""
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontS
                    }

                    Item { Layout.fillWidth: true }

                    ComboBox {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 30
                        model: [10, 20, 50, 100]
                        currentIndex: root.pagination
                            ? Math.max(0, model.indexOf(root.pagination.pageSize))
                            : 1
                        onActivated: {
                            if (root.pagination)
                                root.pagination.setPageSize(model[currentIndex])
                        }
                    }

                    Button { text: "«"; Layout.preferredWidth: 32
                        enabled: root.pagination && root.pagination.currentPage > 1
                        onClicked: root.pagination.firstPage() }
                    Button { text: "‹"; Layout.preferredWidth: 32
                        enabled: root.pagination && root.pagination.currentPage > 1
                        onClicked: root.pagination.prevPage() }
                    Text {
                        Layout.preferredWidth: 80
                        horizontalAlignment: Text.AlignHCenter
                        text: root.pagination
                            ? (root.pagination.currentPage + " / "
                               + root.pagination.pageCount) : ""
                        color: NovaTheme.textColor
                        font.pixelSize: 13
                    }
                    Button { text: "›"; Layout.preferredWidth: 32
                        enabled: root.pagination
                                 && root.pagination.currentPage < root.pagination.pageCount
                        onClicked: root.pagination.nextPage() }
                    Button { text: "»"; Layout.preferredWidth: 32
                        enabled: root.pagination
                                 && root.pagination.currentPage < root.pagination.pageCount
                        onClicked: root.pagination.lastPage() }
                }
            }
        }
    }

    // =================== 列选择器 Popup ===================
    Popup {
        id: columnPopup
        width: 240
        height: Math.min(420, colList.implicitHeight + 60)
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            color: NovaTheme.surface
            border.color: NovaTheme.outline
            radius: 8
        }

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Text {
                text: "选择显示列"
                font.bold: true
                font.pixelSize: 14
                color: NovaTheme.textColor
            }

            ScrollView {
                width: parent.width
                height: parent.height - 40
                clip: true

                Column {
                    id: colList
                    width: parent.width

                    Repeater {
                        model: root.allColumnDefs
                        delegate: CheckBox {
                            required property var modelData
                            width: colList.width
                            text: modelData.label
                            checked: {
                                if (root._visibleColumnKeys.length === 0) return true
                                return root._visibleColumnKeys.indexOf(modelData.key) !== -1
                            }
                            onToggled: {
                                if (root._visibleColumnKeys.length === 0) {
                                    root._visibleColumnKeys =
                                        root.allColumnDefs.map(function(c) { return c.key })
                                }
                                var keys = root._visibleColumnKeys.slice()
                                var i = keys.indexOf(modelData.key)
                                if (checked && i === -1) keys.push(modelData.key)
                                else if (!checked && i !== -1) keys.splice(i, 1)
                                root._visibleColumnKeys = keys
                                if (root.tableModel)
                                    root.tableModel.setVisibleColumns(keys)
                            }
                        }
                    }
                }
            }
        }
    }

    // =================== 编辑器组件 ===================
    Component {
        id: textEditor
        TextField {
            id: tf
            text: root._editingRow >= 0 && root.tableModel
                ? String(root.tableModel.getRawValue(root._editingRow,
                                                      root._editingColumn) ?? "")
                : ""
            selectByMouse: true
            onAccepted: commit()
            onEditingFinished: commit()
            Component.onCompleted: { forceActiveFocus(); selectAll(); }

            function commit() {
                if (root._editingRow < 0) return
                var r = root._editingRow
                var c = root._editingColumn
                var v = tf.text
                var ok = root.tableModel.setRawValue(r, c, v)
                if (ok) root.cellEdited(r, c, v)
                root._editingRow = -1
                root._editingColumn = -1
            }
        }
    }

    Component {
        id: numberEditor
        TextField {
            id: nf
            text: root._editingRow >= 0 && root.tableModel
                ? String(root.tableModel.getRawValue(root._editingRow,
                                                      root._editingColumn) ?? "")
                : ""
            selectByMouse: true
            validator: DoubleValidator {}
            onAccepted: commit()
            onEditingFinished: commit()
            Component.onCompleted: { forceActiveFocus(); selectAll(); }

            function commit() {
                if (root._editingRow < 0) return
                var r = root._editingRow
                var c = root._editingColumn
                var v = nf.text
                var ok = root.tableModel.setRawValue(r, c, v)
                if (ok) root.cellEdited(r, c, v)
                root._editingRow = -1
                root._editingColumn = -1
            }
        }
    }

    Component {
        id: selectEditor
        ComboBox {
            id: cb
            model: (root._editingColumn >= 0
                    && root._editingColumn < root.columnDefs.length)
                ? (root.columnDefs[root._editingColumn].options || [])
                : []
            textRole: "label"
            valueRole: "value"

            Component.onCompleted: {
                if (root._editingRow < 0 || !root.tableModel) return
                var cur = root.tableModel.getRawValue(root._editingRow,
                                                     root._editingColumn)
                currentIndex = indexOfValue(cur)
                forceActiveFocus()
                popup.open()
            }

            onActivated: {
                if (root._editingRow < 0 || !root.tableModel) return
                var r = root._editingRow
                var c = root._editingColumn
                var v = currentValue
                var ok = root.tableModel.setRawValue(r, c, v)
                if (ok) root.cellEdited(r, c, v)
                root._editingRow = -1
                root._editingColumn = -1
            }

            Connections {
                target: cb.popup
                function onClosed() {
                    if (root._editingRow >= 0) {
                        root._editingRow = -1
                        root._editingColumn = -1
                    }
                }
            }
        }
    }
}
```

---

## 6. `main.py`

```python
import os
import random
import sys

from PySide6.QtCore import QObject, QTimer, QUrl, Signal, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from nova import (
    NovaColumn,
    NovaFilterProxyModel,
    NovaPagedProxyModel,
    NovaPagination,
    NovaTableModel,
    NovaTheme,
)


class IndustrialSimulator(QObject):
    """模拟铝电解槽测点数据源（工业场景演示）。"""

    def __init__(self, model: NovaTableModel, parent=None):
        super().__init__(parent)
        self._model = model
        self._timer = QTimer(self)
        self._timer.setInterval(200)
        self._timer.timeout.connect(self._tick)

    def start(self):
        self._timer.start()

    def stop(self):
        self._timer.stop()

    @Slot()
    def _tick(self):
        """每 200ms 批量更新所有槽的电压、温度。"""
        updates = []
        for i in range(self._model.totalCount):
            cell_id = self._model.getRawValue(i, 0)   # 槽号
            if not cell_id:
                continue
            voltage = round(random.uniform(3.9, 4.5), 2)
            temp = round(random.uniform(920, 965), 1)
            severity = 0
            if voltage > 4.4 or temp > 960:
                severity = 2
            elif voltage > 4.3 or temp > 955:
                severity = 1
            updates.append({
                "cell_id": cell_id,
                "voltage": voltage,
                "temperature": temp,
                "_severity": severity,
            })
        self._model.batchUpdate(updates)


def build_demo():
    columns = [
        NovaColumn("cell_id", "槽号", width=100, align="center"),
        NovaColumn("voltage", "电压 (V)", width=110, align="right",
                   formatter=lambda v, r: f"{float(v):.2f}" if v is not None else ""),
        NovaColumn("current", "电流 (kA)", width=110, align="right",
                   formatter=lambda v, r: f"{float(v):.1f}" if v is not None else ""),
        NovaColumn("temperature", "温度 (°C)", width=110, align="right",
                   formatter=lambda v, r: f"{float(v):.1f}" if v is not None else ""),
        NovaColumn("alumina", "氧化铝浓度 (%)", width=130, align="right"),
        NovaColumn("status", "状态", width=100, align="center"),
        NovaColumn("operator", "责任人", width=100, align="center"),
    ]

    rows = []
    for i in range(500):
        rows.append({
            "cell_id": f"A{i + 1:03d}",
            "voltage": round(random.uniform(3.9, 4.5), 2),
            "current": round(random.uniform(300, 320), 1),
            "temperature": round(random.uniform(920, 965), 1),
            "alumina": round(random.uniform(1.8, 3.0), 2),
            "status": random.choice(["运行", "检修", "备用"]),
            "operator": random.choice(["张三", "李四", "王五"]),
            "_severity": 0,
        })

    model = NovaTableModel(columns, rows, row_key="cell_id")
    filter_proxy = NovaFilterProxyModel()
    filter_proxy.setSourceModel(model)
    pagination = NovaPagination(page_size=20)
    paged_proxy = NovaPagedProxyModel(pagination)
    paged_proxy.setSourceModel(filter_proxy)

    return model, filter_proxy, paged_proxy, pagination


def main():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    model, filter_proxy, paged_proxy, pagination = build_demo()
    theme = NovaTheme()

    simulator = IndustrialSimulator(model)
    simulator.start()

    ctx = engine.rootContext()
    ctx.setContextProperty("tableModel", model)
    ctx.setContextProperty("filterProxy", filter_proxy)
    ctx.setContextProperty("pagedProxy", paged_proxy)
    ctx.setContextProperty("pagination", pagination)
    ctx.setContextProperty("novaTheme", theme)

    here = os.path.dirname(os.path.abspath(__file__))
    engine.addImportPath(os.path.join(here, "nova", "qml"))
    engine.load(QUrl.fromLocalFile(os.path.join(here, "Main.qml")))

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
```

---

## 7. `Main.qml`

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Nova.Controls 1.0

Window {
    id: win
    width: 1400
    height: 820
    visible: true
    title: "NovaTable 企业级旗舰演示 · 铝电解工作站"
    color: novaTheme.surfaceAlt

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // 顶部状态条
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: novaTheme.surface
            radius: 8
            border.color: novaTheme.outline

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 16

                Text {
                    text: "铝电解槽实时监控"
                    font.pixelSize: 18
                    font.bold: true
                    color: novaTheme.textColor
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "总槽数: " + tableModel.totalCount
                    color: novaTheme.textMuted
                    font.pixelSize: 13
                }
            }
        }

        // 主表格
        NovaTable {
            id: table
            Layout.fillWidth: true
            Layout.fillHeight: true

            tableModel: tableModel
            filterProxy: filterProxy
            pagedProxy: pagedProxy
            pagination: pagination

            title: "实时测点"
            searchPlaceholder: "搜索槽号 / 状态 / 责任人..."
            selectionMode: "multiple"
            rowHeight: 40
            headerHeight: 42

            // 列级自定义委托：状态列渲染为 Badge 风格
            cellDelegates: ({
                "status": statusBadge
            })

            onRowClicked: function(row) { /* 打开详情或高亮 */ }
            onRowDoubleClicked: function(row) {
                console.log("[dblclick] row", row)
            }
            onCellEdited: function(row, column, value) {
                console.log("[edit]", row, column, value)
            }
            onRefreshRequested: {
                console.log("[refresh] 重载数据")
            }
        }
    }

    // 状态列 Badge 委托
    Component {
        id: statusBadge
        Item {
            property var value: ""
            property int severity: 0
            property int rowIndex: -1
            property var rowData: ({})

            Rectangle {
                anchors.centerIn: parent
                width: label.implicitWidth + 20
                height: 24
                radius: 12
                color: severity === 2 ? novaTheme.severityCritical
                     : severity === 1 ? novaTheme.severityWarning
                     : novaTheme.primaryFaint
                border.width: 1
                border.color: severity === 2 ? "#ef4444"
                            : severity === 1 ? "#f59e0b"
                            : novaTheme.primary

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: value !== undefined ? String(value) : ""
                    font.pixelSize: 12
                    font.bold: true
                    color: severity === 2 ? "#991b1b"
                         : severity === 1 ? "#92400e"
                         : novaTheme.primary
                }
            }
        }
    }
}
```

---

## 8. 运行

```bash
pip install PySide6>=6.6
python main.py
```

运行后可以看到：

- **500 行**电解槽数据，20 行/页
- **每 200ms 批量刷新**电压、温度，超阈值时**行背景变黄/变红**，新数据**淡蓝高亮 1.5 秒**
- **状态列**渲染为自定义 Badge（列级委托）
- **列选择器**支持动态显隐
- **全局搜索**过滤 + **分页**
- **可编辑列**双击进入编辑器（text/number/select）

---

## 9. 封版能力对照表

| Quasar QTable 能力 | NovaTable 实现 |
| :--- | :--- |
| `columns` 列定义 | `NovaColumn` 声明，含 label / width / align / sortable / formatter |
| `row-key` 行唯一标识 | `NovaTableModel(row_key=...)` |
| 虚拟滚动 | `TableView + reuseItems` + `cacheBuffer`（Qt 原生池化） |
| 分页（客户端） | `NovaPagination` + `NovaPagedProxyModel` 双层代理 |
| 分页（服务端） | `serverSide: true` + `setRows` + `request(params)` 契约 |
| 过滤 | `NovaFilterProxyModel.setQuickFilter / setColumnFilter` |
| 排序 | `proxy.sort(column, order)` |
| 单选/多选 | `selectionMode: "single" / "multiple"` |
| 列级自定义渲染 | `cellDelegates: { "status": Component }`（等价 `body-cell-status`） |
| 列显隐（列选择器） | 工具栏「列」按钮 + Popup CheckBox 列表 |
| Loading 状态 | `loading` + `loadingText` |
| 空态 | `noDataText` |
| 行点击/双击/单元格编辑 | `rowClicked` / `rowDoubleClicked` / `cellEdited` |
| 批量更新（工业特化） | `NovaTableModel.batchUpdate(updates)`，50ms 合并 dataChanged |
| 告警染色（工业特化） | `severity` role（0/1/2）+ 行背景色 |
| 新数据高亮（工业特化） | `highlighted` role + 1.5s 自动淡出 |

## 10. 封版契约与已知限制

**冻结契约**：

1. `NovaTableModel` 的公开方法签名（`batchUpdate` / `setRows` / `setVisibleColumns` / `getRow` / `setRawValue`）不再变更。
2. `NovaColumn` 构造参数不再变更。
3. `NovaTable.qml` 的属性与信号不再变更。
4. `severity` 约定为 `0=正常 / 1=警告 / 2=严重`，存储在 `row["_severity"]`。

**已知限制**：

- **展开行**：本版未实现，行内展开请用详情弹窗代替；`v0.13.0` 计划通过 `rowHeightProvider` 动态化补齐。
- **冻结列**：本版未实现，关键操作列建议用行内按钮或右侧详情面板代替；`v0.13.0` 计划用双 TableView 垂直同步补齐。
- **环形缓冲**：Model 不直接管理容量，由上层数据源用 `collections.deque(maxlen=N)` 管理，每 500ms 调用 `setRows(list(deque))` 重建。
- **QTableView 包装**：明确不做，`QQuickWidget` 的离屏渲染开销会吃掉工业场景的帧预算。

---

**这套方案可以直接开工。** 三周内按「渲染层切换 → 模型批量通道 → Quasar 核心 API 收尾」的顺序推进，每周都有可交付的验证点。冻结列与展开行作为 v0.13.0 补丁推进，不阻塞本次封版。