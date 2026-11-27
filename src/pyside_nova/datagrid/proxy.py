# src/pyside_nova/datagrid/proxy.py
# NovaDataGrid 配套数据层：全局/列级过滤代理、分页状态控制器、分页切片代理。
"""NovaDataGrid 的代理层：过滤、分页状态与页切片。"""
from __future__ import annotations

from PySide6.QtCore import (
    Property,
    QAbstractProxyModel,
    QModelIndex,
    QObject,
    QSortFilterProxyModel,
    Qt,
    Signal,
    Slot,
)

from .model import NovaDataGridRoles


def _invalidate_rows(proxy: QSortFilterProxyModel) -> None:
    """使代理重新求值过滤/排序。

    Qt 6.12 把 ``invalidateFilter()`` 与 ``invalidateRowsFilter()`` **都**标记了
    deprecated（后者是 6.10 新增的短命替代）。实测 ``invalidate()`` 在 6.8~6.12
    全程可用且无警告，故统一走它；语义是重算整个代理，对分页切片场景无害。
    """
    proxy.invalidate()


class NovaDataGridFilterProxy(QSortFilterProxyModel):
    """全局快速过滤 + 列级过滤（客户端模式）。"""

    countChanged = Signal()
    filterActiveChanged = Signal()

    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self.setDynamicSortFilter(True)
        self._quick_filter = ""
        self._column_filters: dict[str, str] = {}
        self._key_to_col: dict[str, int] = {}
        self.rowsInserted.connect(self._emit_count)
        self.rowsRemoved.connect(self._emit_count)
        self.modelReset.connect(self._emit_count)
        self.layoutChanged.connect(self._emit_count)

    def setSourceModel(self, model) -> None:
        super().setSourceModel(model)
        if model is not None and hasattr(model, "columnsChanged"):
            model.columnsChanged.connect(self._rebuild_keys)
        self._rebuild_keys()

    def roleNames(self) -> dict[int, bytes]:
        """转发源模型自定义 role，否则 TableView delegate 的 required role 会失效。"""
        source = self.sourceModel()
        return source.roleNames() if source is not None else super().roleNames()

    def _rebuild_keys(self) -> None:
        model = self.sourceModel()
        self._key_to_col = {}
        if model is not None and hasattr(model, "columns"):
            self._key_to_col = {
                str(c["key"]): i for i, c in enumerate(model.columns) if "key" in c
            }

    def _emit_count(self, *args) -> None:
        self.countChanged.emit()

    @Property(int, notify=countChanged)
    def count(self) -> int:
        return self.rowCount()

    @Property(bool, notify=filterActiveChanged)
    def filterActive(self) -> bool:
        return bool(self._quick_filter) or any(self._column_filters.values())

    @Slot(str)
    def setQuickFilter(self, text: str) -> None:
        was_active = self.filterActive
        self._quick_filter = (text or "").strip().lower()
        _invalidate_rows(self)
        if was_active != self.filterActive:
            self.filterActiveChanged.emit()

    @Slot(str, str)
    def setColumnFilter(self, key: str, text: str) -> None:
        was_active = self.filterActive
        if text:
            self._column_filters[key] = text.strip().lower()
        else:
            self._column_filters.pop(key, None)
        _invalidate_rows(self)
        if was_active != self.filterActive:
            self.filterActiveChanged.emit()

    @Slot()
    def clearFilters(self) -> None:
        was_active = self.filterActive
        self._quick_filter = ""
        self._column_filters.clear()
        _invalidate_rows(self)
        if was_active != self.filterActive:
            self.filterActiveChanged.emit()

    def filterAcceptsRow(self, source_row: int, source_parent: QModelIndex) -> bool:
        model = self.sourceModel()
        if model is None:
            return True

        if self._quick_filter:
            hit = False
            for column in range(model.columnCount()):
                idx = model.index(source_row, column, source_parent)
                value = model.data(idx, Qt.ItemDataRole.DisplayRole)
                if value is not None and self._quick_filter in str(value).lower():
                    hit = True
                    break
            if not hit:
                return False

        for key, needle in self._column_filters.items():
            column = self._key_to_col.get(key)
            if column is None:
                continue
            idx = model.index(source_row, column, source_parent)
            value = model.data(idx, Qt.ItemDataRole.DisplayRole)
            if value is None or needle not in str(value).lower():
                return False
        return True


class NovaDataGridPagination(QObject):
    """分页状态控制器，与数据模型解耦（QML 侧可直接绑定）。"""

    pageChanged = Signal()
    pageSizeChanged = Signal()
    totalChanged = Signal()

    def __init__(self, page_size: int = 20, parent=None) -> None:
        super().__init__(parent)
        self._page = 1
        self._page_size = max(1, int(page_size))
        self._total = 0

    @Property(int, notify=pageChanged)
    def currentPage(self) -> int:
        return self._page

    @Property(int, notify=pageSizeChanged)
    def pageSize(self) -> int:
        return self._page_size

    @Property(int, notify=totalChanged)
    def total(self) -> int:
        return self._total

    @Property(int, notify=pageChanged)
    def pageCount(self) -> int:
        return max(1, (self._total + self._page_size - 1) // self._page_size)

    @Property(int, notify=pageChanged)
    def startIndex(self) -> int:
        return (self._page - 1) * self._page_size

    @Property(int, notify=pageChanged)
    def endIndex(self) -> int:
        return min(self._total, self._page * self._page_size)

    @Slot(int)
    def setCurrentPage(self, page: int) -> None:
        clamped = max(1, min(self.pageCount, int(page)))
        if clamped != self._page:
            self._page = clamped
            self.pageChanged.emit()

    @Slot(int)
    def setPageSize(self, size: int) -> None:
        size = int(size)
        if size > 0 and size != self._page_size:
            self._page_size = size
            self._page = 1
            self.pageSizeChanged.emit()
            self.pageChanged.emit()

    @Slot(int)
    def setTotal(self, total: int) -> None:
        total = max(0, int(total))
        if total != self._total:
            self._total = total
            self.totalChanged.emit()
            self.pageChanged.emit()

    @Slot()
    def firstPage(self) -> None:
        self.setCurrentPage(1)

    @Slot()
    def prevPage(self) -> None:
        self.setCurrentPage(self._page - 1)

    @Slot()
    def nextPage(self) -> None:
        self.setCurrentPage(self._page + 1)

    @Slot()
    def lastPage(self) -> None:
        self.setCurrentPage(self.pageCount)


class NovaDataGridPagedProxy(QSortFilterProxyModel):
    """分页代理：包在过滤代理外层，按 pagination 的 startIndex/endIndex 切片。"""

    def __init__(self, pagination: NovaDataGridPagination, parent=None) -> None:
        super().__init__(parent)
        self._pagination = pagination
        pagination.pageChanged.connect(lambda *a: _invalidate_rows(self))
        pagination.pageSizeChanged.connect(lambda *a: _invalidate_rows(self))
        pagination.totalChanged.connect(lambda *a: _invalidate_rows(self))

    def roleNames(self) -> dict[int, bytes]:
        """转发源模型自定义 role（分页代理位于管道末端）。"""
        source = self.sourceModel()
        return source.roleNames() if source is not None else super().roleNames()

    def filterAcceptsRow(self, source_row: int, source_parent: QModelIndex) -> bool:
        p = self._pagination
        return p.startIndex <= source_row < p.endIndex


class NovaDataGridExpandProxy(QAbstractProxyModel):
    """展开行代理：在分页代理末端为每个展开的数据行插入一条虚拟行。

    设计约束：

    * 不改写业务数据，展开态只存 rowKey 集合；
    * 展开行只提供 ``expansionRow / isExpansion / expanded / expansionData``
      四个附加 role，其余 role 透传宿主行；
    * 行映射每次按源模型顺序重建，过滤/排序/分页后的索引不会漂移；
    * 无 rowKey 的行退化为源行序号字符串，但跨过滤后语义不稳定，文档要求
      使用展开行时必须给 ``NovaDataGridModel`` 传 ``row_key``。
    """

    expandedChanged = Signal()
    expansionToggled = Signal(str, bool)

    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self._expanded: set[str] = set()
        self._connections: list[tuple] = []

    # ── 源模型绑定 ─────────────────────────────────────────────────
    def setSourceModel(self, model) -> None:
        for signal, slot in self._connections:
            try:
                signal.disconnect(slot)
            except (RuntimeError, TypeError):
                pass
        self._connections.clear()
        super().setSourceModel(model)
        if model is None:
            return
        pairs = (
            (model.modelReset, self._on_source_reset),
            (model.rowsInserted, self._on_source_reset),
            (model.rowsRemoved, self._on_source_reset),
            (model.layoutChanged, self._on_source_reset),
            (model.columnsChanged, self._on_source_reset)
            if hasattr(model, "columnsChanged") else None,
        )
        for pair in pairs:
            if pair is None:
                continue
            pair[0].connect(pair[1])
            self._connections.append(pair)

    def _on_source_reset(self, *args) -> None:
        self.beginResetModel()
        self.endResetModel()

    # ── 行计划 ─────────────────────────────────────────────────────
    def _source_key(self, source_row: int) -> str:
        model = self.sourceModel()
        if model is None:
            return ""
        key = model.data(model.index(source_row, 0), NovaDataGridRoles.RowKeyRole)
        return str(key) if key not in (None, "") else str(source_row)

    def _row_plan(self) -> list[tuple[int, str]]:
        """返回 ``(源行号, 展开 key)``；展开 key 为空表示普通数据行。"""
        model = self.sourceModel()
        if model is None:
            return []
        plan: list[tuple[int, str]] = []
        for row in range(model.rowCount()):
            plan.append((row, ""))
            key = self._source_key(row)
            if key in self._expanded:
                plan.append((row, key))
        return plan

    def _proxy_row_for_key(self, key: str) -> int:
        for proxy_row, (_src_row, exp_key) in enumerate(self._row_plan()):
            if exp_key == key:
                return proxy_row
        return -1

    def _proxy_row_for_source_row(self, source_row: int) -> int:
        proxy_row = 0
        for src_row, _exp_key in self._row_plan():
            if src_row == source_row:
                return proxy_row
            proxy_row += 1
        return -1

    def _source_row_for_proxy_row(self, proxy_row: int) -> int | None:
        plan = self._row_plan()
        if 0 <= proxy_row < len(plan):
            return plan[proxy_row][0]
        return None

    # ── QAbstractProxyModel 必需实现 ──────────────────────────────
    def rowCount(self, parent=QModelIndex()) -> int:
        return 0 if parent.isValid() else len(self._row_plan())

    def columnCount(self, parent=QModelIndex()) -> int:
        model = self.sourceModel()
        return 0 if model is None or parent.isValid() else model.columnCount()

    def index(self, row: int, column: int, parent=QModelIndex()) -> QModelIndex:
        if parent.isValid() or row < 0 or column < 0:
            return QModelIndex()
        if row >= self.rowCount() or column >= self.columnCount():
            return QModelIndex()
        return self.createIndex(row, column, row)

    def parent(self, child=QModelIndex()) -> QModelIndex:
        return QModelIndex()

    def mapToSource(self, proxy_index: QModelIndex) -> QModelIndex:
        model = self.sourceModel()
        if model is None or not proxy_index.isValid():
            return QModelIndex()
        source_row = self._source_row_for_proxy_row(proxy_index.row())
        if source_row is None:
            return QModelIndex()
        return model.index(source_row, proxy_index.column())

    def mapFromSource(self, source_index: QModelIndex) -> QModelIndex:
        if not source_index.isValid():
            return QModelIndex()
        proxy_row = self._proxy_row_for_source_row(source_index.row())
        if proxy_row < 0:
            return QModelIndex()
        return self.index(proxy_row, source_index.column())

    def roleNames(self) -> dict[int, bytes]:
        names = dict(super().roleNames())
        source = self.sourceModel()
        if source is not None:
            names.update(source.roleNames())
        names.update({
            NovaDataGridRoles.ExpansionRowRole: b"expansionRow",
            NovaDataGridRoles.IsExpansionRole: b"isExpansion",
            NovaDataGridRoles.ExpandedRole: b"expanded",
            NovaDataGridRoles.ExpansionDataRole: b"expansionData",
        })
        return names

    def data(self, index: QModelIndex, role=Qt.ItemDataRole.DisplayRole):
        model = self.sourceModel()
        if model is None or not index.isValid():
            return None
        plan = self._row_plan()
        if index.row() >= len(plan):
            return None
        source_row, exp_key = plan[index.row()]

        if exp_key:
            if role == NovaDataGridRoles.IsExpansionRole:
                return True
            if role == NovaDataGridRoles.ExpansionRowRole:
                return source_row
            if role == NovaDataGridRoles.ExpandedRole:
                return True
            if role == NovaDataGridRoles.RowKeyRole:
                return exp_key
            if role == NovaDataGridRoles.ExpansionDataRole:
                getter = getattr(model, "getRow", None)
                return getter(source_row) if callable(getter) else {}
            if role in (NovaDataGridRoles.DisplayRole, NovaDataGridRoles.EditRole):
                return ""
            if role == NovaDataGridRoles.SeverityRole:
                return 0
            if role == NovaDataGridRoles.HighlightedRole:
                return False
            return None

        source_index = model.index(source_row, index.column())
        if role == NovaDataGridRoles.IsExpansionRole:
            return False
        if role == NovaDataGridRoles.ExpansionRowRole:
            return -1
        if role == NovaDataGridRoles.ExpandedRole:
            return self._source_key(source_row) in self._expanded
        if role == NovaDataGridRoles.ExpansionDataRole:
            return {}
        return model.data(source_index, role)

    def setData(self, index: QModelIndex, value, role=Qt.ItemDataRole.EditRole) -> bool:
        if not index.isValid() or self._row_plan()[index.row()][1]:
            return False
        return self.sourceModel().setData(self.mapToSource(index), value, role)

    def flags(self, index: QModelIndex):
        if not index.isValid():
            return Qt.ItemFlag.NoItemFlags
        if self._row_plan()[index.row()][1]:
            return Qt.ItemFlag.ItemIsEnabled
        return self.sourceModel().flags(self.mapToSource(index))

    def headerData(self, section, orientation, role=Qt.ItemDataRole.DisplayRole):
        model = self.sourceModel()
        return model.headerData(section, orientation, role) if model is not None else None

    # ── 展开态公共 API ─────────────────────────────────────────────
    @Property("QVariantList", notify=expandedChanged)
    def expanded(self) -> list[str]:
        return [key for _row, key in self._row_plan() if key]

    @Slot("QVariantList")
    def setExpanded(self, keys) -> None:
        wanted = {str(k) for k in (keys or [])}
        if wanted == self._expanded:
            return
        self.beginResetModel()
        self._expanded = wanted
        self.endResetModel()
        self.expandedChanged.emit()

    @Slot(int, result=bool)
    def isExpansionRow(self, proxy_row: int) -> bool:
        plan = self._row_plan()
        return 0 <= proxy_row < len(plan) and bool(plan[proxy_row][1])

    @Slot(int, result=bool)
    def isRowExpanded(self, proxy_row: int) -> bool:
        plan = self._row_plan()
        if not (0 <= proxy_row < len(plan)):
            return False
        return self._source_key(plan[proxy_row][0]) in self._expanded

    @Slot(int)
    def toggleRow(self, proxy_row: int) -> None:
        plan = self._row_plan()
        if not (0 <= proxy_row < len(plan)):
            return
        source_row, exp_key = plan[proxy_row]
        if exp_key:
            self.setExpanded([k for k in self.expanded if k != exp_key])
            self.expansionToggled.emit(exp_key, False)
            return
        key = self._source_key(source_row)
        if key in self._expanded:
            self.setExpanded([k for k in self.expanded if k != key])
            self.expansionToggled.emit(key, False)
            return
        insert_at = self._proxy_row_for_source_row(source_row) + 1
        self.beginInsertRows(QModelIndex(), insert_at, insert_at)
        self._expanded.add(key)
        self.endInsertRows()
        self.expandedChanged.emit()
        self.expansionToggled.emit(key, True)

    @Slot(int, result="QVariantMap")
    def expansionData(self, proxy_row: int) -> dict:
        plan = self._row_plan()
        if not (0 <= proxy_row < len(plan)):
            return {}
        source_row, exp_key = plan[proxy_row]
        model = self.sourceModel()
        getter = getattr(model, "getRow", None)
        row_data = getter(source_row) if callable(getter) else {}
        return {
            "rowKey": exp_key or self._source_key(source_row),
            "sourceRow": source_row,
            "rowData": row_data,
            "expansionRow": source_row if exp_key else -1,
        }
