# NovaTable 企业级旗舰封版

下面是完整可运行代码，融合了前面方案的全部核心能力：**Model-View-Delegate 三层分离 + 增量更新 + 双层代理（筛选/分页）+ 虚拟滚动 + 内联编辑 + 粘性表头 + 全屏 + Loading/NoData 状态**。

## 一、项目结构

```
novatable/
├── main.py
├── Main.qml
└── nova/
    ├── __init__.py
    ├── model.py
    ├── proxy.py
    └── qml/
        └── NovaTable.qml
```

---

## 二、`nova/__init__.py`

```python
from .model import NovaColumn, NovaTableModel
from .proxy import NovaFilterProxyModel, NovaPagination, NovaPagedProxyModel

__all__ = [
    "NovaColumn",
    "NovaTableModel",
    "NovaFilterProxyModel",
    "NovaPagination",
    "NovaPagedProxyModel",
]
```

---

## 三、`nova/model.py`

```python
from typing import Any, Callable, Dict, List, Optional

from PySide6.QtCore import (
    Property,
    QAbstractTableModel,
    QModelIndex,
    Qt,
    Signal,
    Slot,
)


class NovaColumn:
    """列定义：一次声明，全链路复用。"""

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
        # formatter 是 Python callable，不能暴露到 QML
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


class NovaTableModel(QAbstractTableModel):
    """NovaTable 数据模型：全量数据 + 增量更新协议。"""

    rowsChanged = Signal()

    def __init__(
        self,
        columns: List[NovaColumn],
        rows: Optional[List[Dict[str, Any]]] = None,
        parent=None,
    ):
        super().__init__(parent)
        self._columns = columns
        self._rows = rows or []
        self._key_to_col = {c.key: i for i, c in enumerate(columns)}

    # ---------------- QAbstractTableModel 核心 ----------------
    def rowCount(self, parent=QModelIndex()) -> int:
        return 0 if parent.isValid() else len(self._rows)

    def columnCount(self, parent=QModelIndex()) -> int:
        return 0 if parent.isValid() else len(self._columns)

    def roleNames(self):
        # 只暴露 display / edit 两个 role，足够通用
        return {Qt.DisplayRole: b"display", Qt.EditRole: b"edit"}

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if not index.isValid():
            return None
        row = self._rows[index.row()]
        col = self._columns[index.column()]
        if role in (Qt.DisplayRole, Qt.EditRole):
            value = row.get(col.key, "")
            if role == Qt.DisplayRole and col.formatter is not None:
                try:
                    return col.formatter(value, row)
                except Exception:
                    return str(value)
            return value
        return None

    def headerData(self, section: int, orientation, role=Qt.DisplayRole):
        if orientation == Qt.Horizontal and role == Qt.DisplayRole:
            if 0 <= section < len(self._columns):
                return self._columns[section].label
        return None

    def flags(self, index: QModelIndex):
        f = Qt.ItemIsEnabled | Qt.ItemIsSelectable
        if index.isValid() and self._columns[index.column()].editable:
            f |= Qt.ItemIsEditable
        return f

    def setData(self, index: QModelIndex, value, role=Qt.EditRole) -> bool:
        if not index.isValid() or role != Qt.EditRole:
            return False
        return self._coerce_and_set(index.row(), self._columns[index.column()], value)

    # ---------------- QML 便捷访问 ----------------
    @Slot(int, int, result="QVariant")
    def getRawValue(self, row: int, column: int):
        if not (0 <= row < len(self._rows)) or not (0 <= column < len(self._columns)):
            return None
        return self._rows[row].get(self._columns[column].key, "")

    @Slot(int, int, "QVariant", result=bool)
    def setRawValue(self, row: int, column: int, value) -> bool:
        if not (0 <= row < len(self._rows)) or not (0 <= column < len(self._columns)):
            return False
        return self._coerce_and_set(row, self._columns[column], value)

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
        idx = self.index(row, self._key_to_col[col.key])
        self.dataChanged.emit(idx, idx, [Qt.DisplayRole, Qt.EditRole])
        return True

    # ---------------- 行级增删改 ----------------
    @Slot(int, "QVariantMap")
    def insertRowAt(self, position: int, data: dict):
        if position < 0 or position > len(self._rows):
            position = len(self._rows)
        self.beginInsertRows(QModelIndex(), position, position)
        self._rows.insert(position, dict(data))
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
            self.endRemoveRows()
            self.rowsChanged.emit()

    @Slot(int, int)
    def removeRowsInRange(self, first: int, last: int):
        first = max(0, first)
        last = min(len(self._rows) - 1, last)
        if first <= last:
            self.beginRemoveRows(QModelIndex(), first, last)
            del self._rows[first : last + 1]
            self.endRemoveRows()
            self.rowsChanged.emit()

    @Slot(int, "QVariantMap")
    def updateRow(self, position: int, data: dict):
        if not (0 <= position < len(self._rows)):
            return
        self._rows[position].update(data)
        self.dataChanged.emit(
            self.index(position, 0),
            self.index(position, self.columnCount() - 1),
            [Qt.DisplayRole, Qt.EditRole],
        )

    @Slot()
    def clearRows(self):
        if not self._rows:
            return
        self.beginResetModel()
        self._rows.clear()
        self.endResetModel()
        self.rowsChanged.emit()

    @Slot(result="QVariantList")
    def allRows(self):
        return self._rows

    # ---------------- 属性 ----------------
    @Property("QVariantList", constant=True)
    def columns(self):
        return [c.to_dict() for c in self._columns]

    @Property(int, notify=rowsChanged)
    def totalCount(self):
        return len(self._rows)
```

---

## 四、`nova/proxy.py`

```python
from PySide6.QtCore import (
    Property,
    QModelIndex,
    QSortFilterProxyModel,
    Qt,
    QObject,
    Signal,
    Slot,
)


class NovaFilterProxyModel(QSortFilterProxyModel):
    """筛选代理：全局关键词 + 列级筛选。"""

    countChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setDynamicSortFilter(True)
        self._quick_filter = ""
        self._column_filters = {}
        self._key_to_col = {}

        # 所有行数变化路径都同步 countChanged
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

    # ---------------- 过滤 API ----------------
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

    @Slot(int)
    def sortByColumn(self, column: int, ascending: bool = True):
        self.sort(column, Qt.AscendingOrder if ascending else Qt.DescendingOrder)

    def filterAcceptsRow(self, source_row, source_parent: QModelIndex) -> bool:
        model = self.sourceModel()
        if model is None:
            return True

        # 全局关键词：命中任意列的 display 值即可
        if self._quick_filter:
            for c in range(model.columnCount()):
                idx = model.index(source_row, c, source_parent)
                val = model.data(idx, Qt.DisplayRole)
                if val is not None and self._quick_filter in str(val).lower():
                    break
            else:
                return False

        # 列级筛选
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
    """分页控制器：与数据模型解耦，只持分页状态。"""

    pageChanged = Signal()
    pageSizeChanged = Signal()
    totalChanged = Signal()

    def __init__(self, page_size: int = 20, parent=None):
        super().__init__(parent)
        self._page = 1
        self._page_size = max(1, page_size)
        self._total = 0

    @Property(int, notify=pageChanged)
    def currentPage(self):
        return self._page

    @Property(int, notify=pageSizeChanged)
    def pageSize(self):
        return self._page_size

    @Property(int, notify=totalChanged)
    def total(self):
        return self._total

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
    """
    分页代理：包裹在 NovaFilterProxyModel 外层，
    只放行当前页的行范围，因此不存在“先过滤再分页”的行号错位问题。
    """

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

## 五、`nova/qml/NovaTable.qml`

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

Item {
    id: root

    // =================== 输入 API ===================
    property var tableModel: null         // NovaTableModel
    property var filterProxy: null        // NovaFilterProxyModel
    property var pagedProxy: null         // NovaPagedProxyModel（可选）
    property var pagination: null         // NovaPagination（可选）

    property var columnDefs: tableModel && tableModel.columns ? tableModel.columns : []

    property string title: ""
    property bool showToolbar: true
    property bool showFilter: true
    property bool showPagination: true
    property bool zebraStripes: true
    property bool loading: false
    property string loadingText: "加载中..."
    property string noDataText: "暂无数据"
    property string searchPlaceholder: "搜索..."

    property bool fullscreen: false
    property string selectionMode: "single"    // single / multiple / none
    property int rowHeight: 40
    property int headerHeight: 40
    property int defaultColumnWidth: 120

    // =================== 输出信号 ===================
    signal cellClicked(int row, int column)
    signal rowClicked(int row)
    signal rowDoubleClicked(int row)
    signal cellEdited(int row, int column, var value)
    signal refreshRequested()

    // =================== 内部状态 ===================
    readonly property var _model: root.pagedProxy ? root.pagedProxy : root.filterProxy
    property int _editingRow: -1
    property int _editingColumn: -1

    implicitWidth: 800
    implicitHeight: 520

    // ---------------- 全屏 ----------------
    states: State {
        name: "fullscreen"; when: root.fullscreen
        ParentChange {
            target: root; parent: Overlay.overlay
            x: 0; y: 0
            width: Overlay.overlay.width
            height: Overlay.overlay.height
        }
    }

    // ---------------- 分页联动 ----------------
    Connections {
        target: root.filterProxy
        function onCountChanged() {
            if (root.pagination && root.filterProxy) {
                root.pagination.setTotal(root.filterProxy.count)
            }
        }
    }
    Component.onCompleted: {
        if (root.pagination && root.filterProxy)
            root.pagination.setTotal(root.filterProxy.count)
    }

    // =================== 主布局 ===================
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ---------- Toolbar ----------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.showToolbar ? 56 : 0
            color: "#ffffff"
            visible: height > 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                Text {
                    text: root.title
                    font.pixelSize: 16
                    font.bold: true
                    color: "#111827"
                    visible: text.length > 0
                }

                Item { Layout.fillWidth: true }

                TextField {
                    id: searchField
                    visible: root.showFilter
                    Layout.preferredWidth: 260
                    Layout.preferredHeight: 34
                    placeholderText: root.searchPlaceholder
                    selectByMouse: true
                    leftPadding: 30

                    background: Rectangle {
                        radius: 6
                        color: "#f9fafb"
                        border.color: searchField.activeFocus ? "#3b82f6" : "#e5e7eb"
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
                    onTextChanged: if (root.filterProxy) root.filterProxy.setQuickFilter(text)
                }

                Button {
                    text: "刷新"
                    Layout.preferredHeight: 34
                    onClicked: root.refreshRequested()
                }
            }

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#e5e7eb" }
        }

        // ---------- Table ----------
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.fill: parent
                visible: root._model && root._model.rowCount() > 0
                spacing: 0

                // 粘性表头
                HorizontalHeaderView {
                    id: header
                    width: parent.width
                    height: root.headerHeight
                    syncView: table
                    clip: true

                    delegate: Rectangle {
                        required property int index
                        required property string display
                        color: "#f9fafb"

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            text: display
                            font.pixelSize: 13
                            font.bold: true
                            color: "#374151"
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 1
                            color: "#e5e7eb"
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#e5e7eb" }

                // 表格本体（TableView 默认已启用虚拟滚动）
                TableView {
                    id: table
                    width: parent.width
                    height: parent.height - root.headerHeight - 1
                    clip: true
                    model: root._model

                    rowHeightProvider: function(row) { return root.rowHeight }
                    columnWidthProvider: function(column) { return root.columnWidthFor(column) }

                    selectionBehavior: TableView.SelectionBehavior.Items
                    selectionMode: root.selectionMode === "multiple"
                                 ? TableView.SelectionMode.ExtendedSelection
                                 : root.selectionMode === "none"
                                 ? TableView.SelectionMode.NoSelection
                                 : TableView.SelectionMode.SingleSelection

                    selectionModel: ItemSelectionModel {
                        id: selModel
                        model: table.model
                    }

                    delegate: Rectangle {
                        id: cellRect
                        required property int row
                        required property int column
                        required property var display

                        implicitWidth: root.columnWidthFor(column)
                        implicitHeight: root.rowHeight

                        readonly property var colDef:
                            column < root.columnDefs.length ? root.columnDefs[column] : ({})
                        readonly property bool isSelected:
                            table.selectionModel && table.selectionModel.isRowSelected
                            ? table.selectionModel.isRowSelected(row) : false
                        readonly property bool editing:
                            root._editingRow === row && root._editingColumn === column

                        color: isSelected
                             ? "#dbeafe"
                             : (root.zebraStripes && row % 2 === 1 ? "#fafafa" : "#ffffff")

                        // 显示文本
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            text: display !== undefined && display !== null ? display : ""
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: colDef.align === "center" ? Text.AlignHCenter
                                              : colDef.align === "right"  ? Text.AlignRight
                                              : Text.AlignLeft
                            elide: Text.ElideRight
                            font.pixelSize: 13
                            color: "#111827"
                            visible: !editing
                        }

                        // 内联编辑器
                        Loader {
                            anchors.fill: parent
                            anchors.margins: 2
                            active: editing && colDef.editable === true
                            sourceComponent: {
                                if (!colDef.editor) return textEditor
                                if (colDef.editor === "number" || colDef.editor === "int") return numberEditor
                                if (colDef.editor === "select") return selectEditor
                                return textEditor
                            }
                        }

                        // 网格线
                        Rectangle { anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 1; color: "#f0f0f0" }
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#f0f0f0" }

                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            onTapped: {
                                root.rowClicked(row)
                                root.cellClicked(row, column)
                                if (colDef.editable) {
                                    root._editingRow = row
                                    root._editingColumn = column
                                }
                            }
                            onDoubleTapped: root.rowDoubleClicked(row)
                        }
                    }
                }
            }

            // 空数据
            Text {
                anchors.centerIn: parent
                visible: !root.loading && (!root._model || root._model.rowCount() === 0)
                text: root.noDataText
                color: "#9ca3af"
                font.pixelSize: 14
            }

            // Loading 遮罩
            Rectangle {
                anchors.fill: parent
                visible: root.loading
                color: "#80ffffff"

                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    BusyIndicator { running: root.loading; anchors.horizontalCenter: parent.horizontalCenter }
                    Text {
                        text: root.loadingText
                        color: "#6b7280"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // ---------- Pagination ----------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: (root.showPagination && root.pagination) ? 48 : 0
            color: "#ffffff"
            visible: height > 0

            Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: "#e5e7eb" }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: root.pagination
                        ? ("第 " + (root.pagination.total === 0 ? 0 : root.pagination.startIndex + 1)
                           + " - " + root.pagination.endIndex
                           + " 条 / 共 " + root.pagination.total + " 条")
                        : ""
                    color: "#6b7280"
                    font.pixelSize: 12
                }

                Item { Layout.fillWidth: true }

                ComboBox {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 30
                    model: [10, 20, 50, 100]
                    currentIndex: root.pagination
                        ? Math.max(0, model.indexOf(root.pagination.pageSize)) : 1
                    onActivated: if (root.pagination) root.pagination.setPageSize(model[currentIndex])
                }

                Button { text: "«"; Layout.preferredWidth: 32; Layout.preferredHeight: 30
                    enabled: root.pagination && root.pagination.currentPage > 1
                    onClicked: root.pagination.firstPage() }
                Button { text: "‹"; Layout.preferredWidth: 32; Layout.preferredHeight: 30
                    enabled: root.pagination && root.pagination.currentPage > 1
                    onClicked: root.pagination.prevPage() }
                Text {
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignHCenter
                    text: root.pagination
                        ? (root.pagination.currentPage + " / " + root.pagination.pageCount) : ""
                    color: "#374151"
                    font.pixelSize: 13
                }
                Button { text: "›"; Layout.preferredWidth: 32; Layout.preferredHeight: 30
                    enabled: root.pagination && root.pagination.currentPage < root.pagination.pageCount
                    onClicked: root.pagination.nextPage() }
                Button { text: "»"; Layout.preferredWidth: 32; Layout.preferredHeight: 30
                    enabled: root.pagination && root.pagination.currentPage < root.pagination.pageCount
                    onClicked: root.pagination.lastPage() }
            }
        }
    }

    // =================== 编辑器组件 ===================
    Component {
        id: textEditor
        TextField {
            id: tf
            text: root._editingRow >= 0 && root.tableModel
                ? String(root.tableModel.getRawValue(root._editingRow, root._editingColumn) ?? "")
                : ""
            selectByMouse: true
            onAccepted: commit()
            onEditingFinished: commit()
            Component.onCompleted: { forceActiveFocus(); selectAll(); }

            function commit() {
                if (root._editingRow < 0) return
                const r = root._editingRow
                const c = root._editingColumn
                const v = tf.text
                const ok = root.tableModel.setRawValue(r, c, v)
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
                ? String(root.tableModel.getRawValue(root._editingRow, root._editingColumn) ?? "")
                : ""
            selectByMouse: true
            validator: DoubleValidator { }
            onAccepted: commit()
            onEditingFinished: commit()
            Component.onCompleted: { forceActiveFocus(); selectAll(); }

            function commit() {
                if (root._editingRow < 0) return
                const r = root._editingRow
                const c = root._editingColumn
                const v = nf.text
                const ok = root.tableModel.setRawValue(r, c, v)
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
            model: (root._editingColumn >= 0 && root._editingColumn < root.columnDefs.length)
                ? (root.columnDefs[root._editingColumn].options || [])
                : []
            textRole: "label"
            valueRole: "value"

            Component.onCompleted: {
                if (root._editingRow < 0 || !root.tableModel) return
                const cur = root.tableModel.getRawValue(root._editingRow, root._editingColumn)
                currentIndex = indexOfValue(cur)
                forceActiveFocus()
                popup.open()
            }

            onActivated: {
                if (root._editingRow < 0 || !root.tableModel) return
                const r = root._editingRow
                const c = root._editingColumn
                const v = currentValue
                const ok = root.tableModel.setRawValue(r, c, v)
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

    // =================== 对外方法 ===================
    function columnWidthFor(column) {
        if (column >= 0 && column < root.columnDefs.length) {
            const c = root.columnDefs[column]
            if (c && c.width) return c.width
        }
        return root.defaultColumnWidth
    }

    property alias currentRow: table.currentRow
    property alias currentColumn: table.currentColumn

    function clearSelection() {
        if (table.selectionModel) table.selectionModel.clear()
    }
}
```

---

## 六、`main.py`

```python
import os
import random
import sys

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from nova import (
    NovaColumn,
    NovaFilterProxyModel,
    NovaPagedProxyModel,
    NovaPagination,
    NovaTableModel,
)


def build_demo():
    columns = [
        NovaColumn("id", "ID", width=70, align="center"),
        NovaColumn("name", "姓名", width=180, editable=True),
        NovaColumn("dept", "部门", width=140, editable=True, editor="select", options=[
            {"label": "研发部", "value": "研发部"},
            {"label": "市场部", "value": "市场部"},
            {"label": "销售部", "value": "销售部"},
            {"label": "人事部", "value": "人事部"},
        ]),
        NovaColumn("role", "职位", width=140, editable=True),
        NovaColumn("salary", "薪资", width=120, align="right", editable=True, editor="number",
                   formatter=lambda v, row: f"¥ {float(v):,.2f}" if v not in (None, "") else ""),
        NovaColumn("status", "状态", width=100, align="center",
                   formatter=lambda v, row: {"active": "在职", "leave": "离职", "probation": "试用"}.get(v, v)),
        NovaColumn("joined", "入职日期", width=130, align="center"),
    ]

    depts = ["研发部", "市场部", "销售部", "人事部"]
    roles = ["工程师", "经理", "总监", "专员", "助理"]
    statuses = ["active", "leave", "probation"]

    rows = []
    for i in range(237):
        rows.append({
            "id": i + 1,
            "name": f"员工 {i + 1:03d}",
            "dept": depts[i % len(depts)],
            "role": roles[i % len(roles)],
            "salary": round(random.uniform(8000, 35000), 2),
            "status": statuses[i % len(statuses)],
            "joined": f"202{random.randint(0, 4)}-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}",
        })

    model = NovaTableModel(columns, rows)
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

    ctx = engine.rootContext()
    ctx.setContextProperty("tableModel", model)
    ctx.setContextProperty("filterProxy", filter_proxy)
    ctx.setContextProperty("pagedProxy", paged_proxy)
    ctx.setContextProperty("pagination", pagination)

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

## 七、`Main.qml`

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Window

Window {
    width: 1280
    height: 760
    visible: true
    title: "NovaTable 企业级旗舰演示"
    color: "#f3f4f6"

    NovaTable {
        anchors.fill: parent
        anchors.margins: 16

        tableModel: tableModel
        filterProxy: filterProxy
        pagedProxy: pagedProxy
        pagination: pagination

        title: "员工列表"
        searchPlaceholder: "搜索任意字段..."

        onCellEdited: function (row, column, value) {
            console.log("[cellEdited]", row, column, value)
        }
        onRowDoubleClicked: function (row) {
            console.log("[rowDoubleClicked]", row)
        }
        onRefreshRequested: {
            console.log("[refresh] 触发刷新")
        }
    }
}
```

---

## 八、运行

```bash
pip install PySide6>=6.6
python main.py
```

---

## 九、封版设计要点

| Quasar QTable 能力 | NovaTable 对标方案 |
|---|---|
| Props 69 项 | 通过 `NovaTable.qml` 属性 + `NovaColumn` 字段收敛，暴露"足够用"的 20 项以内 |
| `virtual-scroll` / `virtual-scroll-target` | TableView 默认虚拟化 + delegate 复用，无需手动开关 |
| `columns` 定义 | Python `NovaColumn` 声明，`@Property("QVariantList", constant=True)` 一次性下发 |
| `pagination` | `NovaPagination` (QObject) + `NovaPagedProxyModel`（独立层，与筛选解耦） |
| `filter` | `NovaFilterProxyModel` 提供 `setQuickFilter` / `setColumnFilter` 双入口 |
| `rows-per-page-options` | 分页栏 ComboBox，可选 [10/20/50/100] |
| `sticky-header` | `HorizontalHeaderView` + `syncView` |
| `fullscreen` / `no-route-fullscreen-exit` | `State` + `ParentChange` 提升到 `Overlay.overlay` |
| `loading` / `no-data` | 遮罩层 + 空态文案 |
| `selection: single/multiple/none` | `TableView.selectionMode` 直接映射 |
| 增删改 | `@Slot insertRowAt / removeRowAt / removeRowsInRange / updateRow` 全部走增量协议 |
| 单元格编辑 | 委托内 `Loader` + 三种编辑器（text / number / select），`setRawValue` 校验后落库 |
| 国际化（C++/Python 侧 `tr()`） | `formatter` 在 Python 端翻译输出，`display` role 直接下发已翻译文本，避免二次翻译 |

**三个刻意保留的"不封"设计：**

1. **不把 formatter 暴露到 QML**——保证格式化规则唯一在 Python，避免前后端双份维护。
2. **分页与筛选分两层代理**——避免"先过滤后分页"的行号错位，是企业级最稳的组合。
3. **`display`/`edit` 双 role**——视图读 `display`，编辑器读 `edit`（这里走 `getRawValue`），彻底隔离"显示格式"与"存储格式"。