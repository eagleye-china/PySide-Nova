# src/pyside_nova/datagrid/proxy.py
# NovaDataGrid 配套数据层：全局/列级过滤代理、分页状态控制器、分页切片代理。
"""NovaDataGrid 的代理层：过滤、分页状态与页切片。"""
from __future__ import annotations

from PySide6.QtCore import (
    Property,
    QModelIndex,
    QObject,
    QSortFilterProxyModel,
    Qt,
    Signal,
    Slot,
)


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

    @Slot(str)
    def setQuickFilter(self, text: str) -> None:
        self._quick_filter = (text or "").strip().lower()
        _invalidate_rows(self)

    @Slot(str, str)
    def setColumnFilter(self, key: str, text: str) -> None:
        if text:
            self._column_filters[key] = text.strip().lower()
        else:
            self._column_filters.pop(key, None)
        _invalidate_rows(self)

    @Slot()
    def clearFilters(self) -> None:
        self._quick_filter = ""
        self._column_filters.clear()
        _invalidate_rows(self)

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
