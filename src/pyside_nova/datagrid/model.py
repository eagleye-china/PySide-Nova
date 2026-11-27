# src/pyside_nova/datagrid/model.py
# NovaDataGrid 配套 Python 数据层：列定义 / role 常量 / QAbstractTableModel 实现。
#
# 设计约束（与 pyside-nova 一致）：
#   * 零第三方依赖，只用 PySide6 + 标准库（唯一依赖 PySide6>=6.8）；
#   * 主题令牌不放 Python 侧 —— QML 统一走 Nova.Services.NovaTheme 单例；
#   * 命名统一 `NovaDataGrid*` 前缀，避免与已发布的 QML 类型 `NovaTable` 混淆。
"""NovaDataGrid 的数据模型：列定义、role 常量与工业级表格模型。"""
from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass, field
from typing import Any

from PySide6.QtCore import (
    Property,
    QAbstractTableModel,
    QModelIndex,
    Qt,
    QTimer,
    Signal,
    Slot,
)

# severity 存于行内保留字段，避免与业务列名冲突（0 正常 / 1 警告 / 2 严重）。
SEVERITY_FIELD = "_severity"


class NovaDataGridRoles:
    """对外 role 常量；QML 侧经 roleNames() 映射为同名属性。"""

    DisplayRole = Qt.ItemDataRole.DisplayRole
    EditRole = Qt.ItemDataRole.EditRole
    SeverityRole = Qt.ItemDataRole.UserRole + 1
    RowKeyRole = Qt.ItemDataRole.UserRole + 2
    HighlightedRole = Qt.ItemDataRole.UserRole + 3
    # 1.7.0 additive：展开行 role。基础模型恒返回默认值，真实行由
    # NovaDataGridExpandProxy 在管道末端注入。
    ExpansionRowRole = Qt.ItemDataRole.UserRole + 4
    IsExpansionRole = Qt.ItemDataRole.UserRole + 5
    ExpandedRole = Qt.ItemDataRole.UserRole + 6
    ExpansionDataRole = Qt.ItemDataRole.UserRole + 7


@dataclass
class NovaDataGridColumn:
    """列定义：一次声明，模型 / 表头 / 编辑器 / 列选择器全链路复用。"""

    key: str
    label: str
    width: int = 120
    align: str = "left"
    editable: bool = False
    editor: str = "text"  # text / number / int / select
    options: list[dict[str, Any]] = field(default_factory=list)
    visible: bool = True
    sortable: bool = True
    formatter: Callable[[Any, dict[str, Any]], str] | None = None

    def to_dict(self) -> dict[str, Any]:
        """QML 侧看到的列定义（不含 formatter —— 函数不跨 QML 边界）。"""
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


class NovaDataGridModel(QAbstractTableModel):
    """工业级数据模型。

    - ``batchUpdate`` 把高频增量更新合并为周期性 ``dataChanged``（吞吐底线）；
    - 最近更新的行短时高亮（1.5 s）；
    - ``setVisibleColumns`` 动态调整 columnCount（列显隐不改数据）；
    - ``setRows`` 全量替换（服务端分页返回当前页切片时直接灌入）。
    """

    rowsChanged = Signal()
    columnsChanged = Signal()

    def __init__(
        self,
        columns: list[NovaDataGridColumn],
        rows: list[dict[str, Any]] | None = None,
        row_key: str = "",
        parent=None,
    ) -> None:
        super().__init__(parent)
        self._all_columns = list(columns)
        self._visible_columns = [c for c in columns if c.visible]
        self._rows: list[dict[str, Any]] = [dict(r) for r in (rows or [])]
        self._row_key = row_key
        self._key_to_row: dict[str, int] = {}
        self._rebuild_key_index()

        # 批量 dataChanged 合并（50 ms 窗口）
        self._pending_rows: set[int] = set()
        self._flush_timer = QTimer(self)
        self._flush_timer.setInterval(50)
        self._flush_timer.setSingleShot(True)
        self._flush_timer.timeout.connect(self._flush_data_changed)

        # 新数据高亮
        self._highlighted_rows: set[int] = set()
        self._highlight_timer = QTimer(self)
        self._highlight_timer.setInterval(1500)
        self._highlight_timer.setSingleShot(True)
        self._highlight_timer.timeout.connect(self._clear_highlights)

    # ── QAbstractTableModel ───────────────────────────────────────
    def rowCount(self, parent=None) -> int:
        if parent is None:
            parent = QModelIndex()
        return 0 if parent.isValid() else len(self._rows)

    def columnCount(self, parent=None) -> int:
        if parent is None:
            parent = QModelIndex()
        return 0 if parent.isValid() else len(self._visible_columns)

    def roleNames(self) -> dict[int, bytes]:
        return {
            NovaDataGridRoles.DisplayRole: b"display",
            NovaDataGridRoles.EditRole: b"edit",
            NovaDataGridRoles.SeverityRole: b"severity",
            NovaDataGridRoles.RowKeyRole: b"rowKey",
            NovaDataGridRoles.HighlightedRole: b"highlighted",
            NovaDataGridRoles.ExpansionRowRole: b"expansionRow",
            NovaDataGridRoles.IsExpansionRole: b"isExpansion",
            NovaDataGridRoles.ExpandedRole: b"expanded",
            NovaDataGridRoles.ExpansionDataRole: b"expansionData",
        }

    def data(self, index: QModelIndex, role: int = Qt.ItemDataRole.DisplayRole):
        if not index.isValid() or not (0 <= index.row() < len(self._rows)):
            return None
        row = self._rows[index.row()]
        if not (0 <= index.column() < len(self._visible_columns)):
            return None
        col = self._visible_columns[index.column()]

        if role == NovaDataGridRoles.DisplayRole:
            value = row.get(col.key, "")
            if col.formatter is not None:
                try:
                    return col.formatter(value, row)
                except Exception:  # noqa: BLE001 - 格式化器由宿主提供，异常不得打断渲染
                    return str(value)
            return value
        if role == NovaDataGridRoles.EditRole:
            return row.get(col.key, "")
        if role == NovaDataGridRoles.SeverityRole:
            return int(row.get(SEVERITY_FIELD, 0))
        if role == NovaDataGridRoles.RowKeyRole:
            return self._row_key_at(index.row())
        if role == NovaDataGridRoles.HighlightedRole:
            return index.row() in self._highlighted_rows
        if role == NovaDataGridRoles.ExpansionRowRole:
            return -1
        if role == NovaDataGridRoles.IsExpansionRole:
            return False
        if role == NovaDataGridRoles.ExpandedRole:
            return False
        if role == NovaDataGridRoles.ExpansionDataRole:
            return {}
        return None

    def headerData(self, section: int, orientation, role=Qt.ItemDataRole.DisplayRole):
        horizontal = orientation == Qt.Orientation.Horizontal
        display = role == Qt.ItemDataRole.DisplayRole
        if horizontal and display and 0 <= section < len(self._visible_columns):
            return self._visible_columns[section].label
        return None

    def flags(self, index: QModelIndex):
        base = Qt.ItemFlag.ItemIsEnabled | Qt.ItemFlag.ItemIsSelectable
        editable = (
            index.isValid()
            and 0 <= index.column() < len(self._visible_columns)
            and self._visible_columns[index.column()].editable
        )
        if editable:
            base |= Qt.ItemFlag.ItemIsEditable
        return base

    def setData(self, index: QModelIndex, value, role=Qt.ItemDataRole.EditRole) -> bool:
        if not index.isValid() or role != Qt.ItemDataRole.EditRole:
            return False
        if not (0 <= index.column() < len(self._visible_columns)):
            return False
        return self._coerce_and_set(index.row(), self._visible_columns[index.column()], value)

    # ── QML 便捷访问 ─────────────────────────────────────────────
    @Slot(int, int, result="QVariant")
    def getRawValue(self, row: int, column: int):
        if not (0 <= row < len(self._rows)):
            return None
        if not (0 <= column < len(self._visible_columns)):
            return None
        return self._rows[row].get(self._visible_columns[column].key, "")

    @Slot(int, int, "QVariant", result=bool)
    def setRawValue(self, row: int, column: int, value) -> bool:
        if not (0 <= row < len(self._rows)):
            return False
        if not (0 <= column < len(self._visible_columns)):
            return False
        return self._coerce_and_set(row, self._visible_columns[column], value)

    @Slot(int, result="QVariantMap")
    def getRow(self, row: int) -> dict:
        if 0 <= row < len(self._rows):
            return dict(self._rows[row])
        return {}

    @Slot(result="QVariantList")
    def allRows(self) -> list[dict]:
        return [dict(r) for r in self._rows]

    # ── 写入与批量更新 ───────────────────────────────────────────
    def _coerce_and_set(self, row: int, col: NovaDataGridColumn, value) -> bool:
        if col.editor in ("int", "number"):
            try:
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

    @Slot("QVariantList")
    def batchUpdate(self, updates: list) -> None:
        """按 rowKey 合并增量更新，合并为周期性 dataChanged + 短时高亮。"""
        if not self._row_key:
            return
        touched: set[int] = set()
        for update in updates:
            if not isinstance(update, dict):
                continue
            key = str(update.get(self._row_key, ""))
            idx = self._key_to_row.get(key)
            if not key or idx is None:
                continue
            row = self._rows[idx]
            changed = False
            for field_name, value in update.items():
                if field_name == self._row_key:
                    continue
                if row.get(field_name) != value:
                    row[field_name] = value
                    changed = True
            if changed:
                touched.add(idx)
        if touched:
            self._highlighted_rows.update(touched)
            for row_idx in touched:
                self._schedule_row_changed(row_idx)
            if not self._highlight_timer.isActive():
                self._highlight_timer.start()

    def _schedule_row_changed(self, row_idx: int) -> None:
        self._pending_rows.add(row_idx)
        if not self._flush_timer.isActive():
            self._flush_timer.start()

    def _flush_data_changed(self) -> None:
        if not self._pending_rows or self.columnCount() == 0:
            self._pending_rows.clear()
            return
        roles = [
            NovaDataGridRoles.DisplayRole,
            NovaDataGridRoles.EditRole,
            NovaDataGridRoles.SeverityRole,
            NovaDataGridRoles.HighlightedRole,
        ]
        last_col = self.columnCount() - 1
        for row_idx in self._pending_rows:
            if 0 <= row_idx < len(self._rows):
                self.dataChanged.emit(
                    self.index(row_idx, 0), self.index(row_idx, last_col), roles
                )
        self._pending_rows.clear()

    def _clear_highlights(self) -> None:
        if not self._highlighted_rows or self.columnCount() == 0:
            self._highlighted_rows.clear()
            return
        rows = list(self._highlighted_rows)
        self._highlighted_rows.clear()
        last_col = self.columnCount() - 1
        for row_idx in rows:
            if 0 <= row_idx < len(self._rows):
                self.dataChanged.emit(
                    self.index(row_idx, 0),
                    self.index(row_idx, last_col),
                    [NovaDataGridRoles.HighlightedRole],
                )

    # ── 全量替换 / 行级增删 ──────────────────────────────────────
    @Slot("QVariantList")
    def setRows(self, rows: list) -> None:
        self.beginResetModel()
        self._rows = [dict(r) for r in rows]
        self._rebuild_key_index()
        self.endResetModel()
        self.rowsChanged.emit()

    @Slot()
    def clearRows(self) -> None:
        if not self._rows:
            return
        self.beginResetModel()
        self._rows.clear()
        self._key_to_row.clear()
        self.endResetModel()
        self.rowsChanged.emit()

    @Slot(int, "QVariantMap")
    def insertRowAt(self, position: int, data: dict) -> None:
        if position < 0 or position > len(self._rows):
            position = len(self._rows)
        self.beginInsertRows(QModelIndex(), position, position)
        self._rows.insert(position, dict(data))
        self._rebuild_key_index()
        self.endInsertRows()
        self.rowsChanged.emit()

    @Slot("QVariantMap")
    def appendRow(self, data: dict) -> None:
        self.insertRowAt(len(self._rows), data)

    @Slot(int)
    def removeRowAt(self, position: int) -> None:
        if 0 <= position < len(self._rows):
            self.beginRemoveRows(QModelIndex(), position, position)
            self._rows.pop(position)
            self._rebuild_key_index()
            self.endRemoveRows()
            self.rowsChanged.emit()

    # ── 列显隐 ──────────────────────────────────────────────────
    @Slot("QVariantList")
    def setVisibleColumns(self, keys: list) -> None:
        wanted = set(keys)
        new_visible = [c for c in self._all_columns if c.key in wanted]
        if [c.key for c in new_visible] == [c.key for c in self._visible_columns]:
            return
        self.beginResetModel()
        self._visible_columns = new_visible
        self.endResetModel()
        self.columnsChanged.emit()

    # ── 属性 ────────────────────────────────────────────────────
    @Property("QVariantList", notify=columnsChanged)
    def columns(self) -> list[dict]:
        return [c.to_dict() for c in self._visible_columns]

    @Property("QVariantList", constant=True)
    def allColumns(self) -> list[dict]:
        return [c.to_dict() for c in self._all_columns]

    @Property(int, notify=rowsChanged)
    def totalCount(self) -> int:
        return len(self._rows)

    # ── 内部辅助 ────────────────────────────────────────────────
    def _row_key_at(self, row: int) -> str:
        if not (0 <= row < len(self._rows)):
            return ""
        record = self._rows[row]
        if self._row_key and self._row_key in record:
            return str(record[self._row_key])
        return str(row)

    def _rebuild_key_index(self) -> None:
        self._key_to_row.clear()
        if not self._row_key:
            return
        for i, record in enumerate(self._rows):
            if self._row_key in record:
                self._key_to_row[str(record[self._row_key])] = i
