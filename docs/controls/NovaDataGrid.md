# NovaDataGrid 使用文档

> **1.5.0 additive · 第 146 个公共类型** · `Nova.Controls.NovaDataGrid`
> 冻结指纹 `9742de8638251876` · 146 类型 / Controls 93 / a11y `interactive`
> 公共面：**32 props · 8 signals · 8 methods**（其中 4 个为 Connections 标准 handler，
> 与库内 `NovaClosePopup.onClicked()` 惯例一致；逐成员见 `api/nova-api-1.5.0.json`）

## 0. 定位与裁决

`NovaDataGrid` 是**另立的新类型**，不是 `NovaTable` 的替换版。

| | `NovaTable`（1.0.0 GA 起） | `NovaDataGrid`（1.5.0） |
|---|---|---|
| 数据输入 | 纯 QML：`rows: var` / `columns: var` | Python 管道：`tableModel` / `filterProxy` / `pagedProxy` / `pagination` |
| 渲染 | `Repeater` + `ListView` 虚拟滚动 | `TableView` + `HorizontalHeaderView` 真虚拟化 |
| 依赖 | 纯 QML、零 Python 模型 | 配套 `pyside_nova.datagrid`（仍只依赖 `PySide6>=6.8`） |
| 选中 | 受控（emit `updateSelected` 由宿主写回） | `ItemSelectionModel` 就地选中 |
| 编辑 | 无 | 内联编辑 + ESC 取消 + 失败红框 |
| 列显隐 / 列级委托 | 无 | 有（`NovaMenu` + `cellDelegates`） |
| 服务端模式 | 受控 `request` | `request` + 表头排序 + 页大小变更补发 |
| 展开行 / 冻结列 | `expandSlot` / `expanded` | 不在本次范围（构想稿自述） |

**选型建议**：数据已在 QML 侧、要零 Python 接入、需要展开行 → 用 `NovaTable`；
数据来自 Python / 数据库、行量大、需要列级委托与内联编辑 → 用 `NovaDataGrid`。
两者**并存**，旧 145 类型逐字不变（1.5.0 重签已机检确认）。

> 该文件曾以「企业级旗舰封版方案」构想稿形式存在于 `docs/controls/NovaTable.md`
> 与 `nova-forge/docs/controls/NovaTable.qml`。本实现按其 B 路径落地：
> **新增类型 + Python 数据层入库 + 令牌统一到 `NovaTheme` + 裸控件换成库组件**，
> 不替换、不改动已发布组件。史料不圆场，构想稿保留但不在文档站发布。

## 1. 快速开始

### 1.1 Python 侧：装配数据管道

```python
from pyside_nova.datagrid import (
    NovaDataGridColumn, NovaDataGridModel,
    NovaDataGridFilterProxy, NovaDataGridPagedProxy, NovaDataGridPagination,
    SEVERITY_FIELD,
)

columns = [
    NovaDataGridColumn("slot", "槽号", width=120),
    NovaDataGridColumn("voltage", "电压(V)", width=120,
                       editable=True, editor="number"),
    NovaDataGridColumn("temp", "温度(°C)", width=130, align="right"),
    NovaDataGridColumn("state", "状态", width=110),
]
rows = [
    {"slot": "A01", "voltage": 4.12, "temp": 935.5, "state": "正常", SEVERITY_FIELD: 0},
    {"slot": "B02", "voltage": 3.98, "temp": 941.2, "state": "预警", SEVERITY_FIELD: 1},
    {"slot": "C03", "voltage": 3.71, "temp": 988.9, "state": "严重", SEVERITY_FIELD: 2},
]

table_model = NovaDataGridModel(columns, rows, row_key="slot")
pagination = NovaDataGridPagination(page_size=20)
filter_proxy = NovaDataGridFilterProxy()
filter_proxy.setSourceModel(table_model)
paged_proxy = NovaDataGridPagedProxy(pagination)
paged_proxy.setSourceModel(filter_proxy)
pagination.setTotal(len(rows))          # 客户端模式：由组件自动同步亦可
```

### 1.2 注入 QML

```python
from PySide6.QtQml import QQmlApplicationEngine
from pyside_nova import init_nova

engine = QQmlApplicationEngine()
init_nova(engine)
ctx = engine.rootContext()
ctx.setContextProperty("gridTableModel", table_model)
ctx.setContextProperty("gridFilterProxy", filter_proxy)
ctx.setContextProperty("gridPagedProxy", paged_proxy)
ctx.setContextProperty("gridPagination", pagination)
engine.load("main.qml")
```

> ⚠️ **坑位 70**：`setContextProperty` 注入的 Python `list[dict]` 在 QML 侧
> `Array.isArray()` 返回 **false**。组件内所有 options 一律用 JS 数组字面量构造；
> 宿主若自行传 `options`，也请在 QML 里重建数组，不要直接喂 Python 列表。

### 1.3 QML 侧

```qml
import QtQuick
import QtQuick.Controls
import Nova.Controls
import Nova.Services

ApplicationWindow {
    width: 1000; height: 640; visible: true
    NovaDataGrid {
        anchors.fill: parent
        anchors.margins: 16
        title: "工业槽位监控"
        tableModel: gridTableModel
        filterProxy: gridFilterProxy
        pagedProxy: gridPagedProxy
        pagination: gridPagination
        onCellEdited: function (row, column, value) {
            console.log("编辑", row, column, value)
        }
    }
}
```

## 2. 公共 API

### 2.1 输入属性

| 属性 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `a11yLabel` | `string` | `""` | 可读名覆盖（`Accessible.Table`） |
| `tableModel` | `var` | `null` | `NovaDataGridModel`（`QAbstractTableModel`） |
| `filterProxy` | `var` | `null` | `NovaDataGridFilterProxy` |
| `pagedProxy` | `var` | `null` | `NovaDataGridPagedProxy` |
| `pagination` | `var` | `null` | `NovaDataGridPagination` |
| `serverSide` | `bool` | `false` | 过滤/排序/分页交宿主，`rows` 即当前页切片 |
| `reuseItems` | `bool` | `false` | 见 §6 坑位 32 |
| `cellDelegates` | `var` | `({})` | `{ "<colKey>": Component }`，见 §4 |
| `title` / `showToolbar` / `showFilter` / `showColumnSelector` / `showPagination` | `string` / `bool` | `""` / `true` | 工具栏与分页条开关 |
| `zebraStripes` / `bordered` | `bool` | `true` | 斑马纹 / 边框 |
| `rowHeight` / `headerHeight` | `int` | `42` / `44` | 行高 / 表头高 |
| `searchPlaceholder` | `string` | `搜索任意字段...` | 搜索框占位 |
| `selectionMode` | `string` | `"single"` | `single` / `multiple` / `none` |
| `loading` / `loadingText` / `noDataText` | `bool` / `string` | `false` / … | 加载态与空态 |

### 2.2 公共只读派生

| 属性 | 说明 |
|---|---|
| `columnDefs` | 当前可见列定义（`tableModel.columns`） |
| `allColumnDefs` | 全部列定义（含隐藏列，用于列选择器） |

### 2.3 信号

| 信号 | 触发 |
|---|---|
| `rowClicked(int row)` / `rowDoubleClicked(int row)` | 行单击 / 双击 |
| `cellClicked(int row, int column)` | 单元格单击 |
| `cellEdited(int row, int column, var value)` | 内联编辑提交成功 |
| `sortRequested(int column, bool ascending)` | 表头排序（客户端与服务端统一） |
| `refreshRequested()` | 工具栏「刷新」 |
| `request(var params)` | 服务端模式请求，见 §5 |
| `rowContextMenuRequested(int row, real x, real y)` | 右键菜单入口（场景坐标） |

### 2.4 方法

| 方法 | 说明 |
|---|---|
| `sortByKey(colKey, ascending)` | 按**列 key** 排序（列显隐后索引不漂移） |
| `scrollToRow(row)` | 滚动到指定行 |
| `clearSelection()` | 清空 `ItemSelectionModel` |
| `getRowData(rowIndex)` | 取完整行字典（供列级委托按需调用） |

## 3. 数据层 `pyside_nova.datagrid`

| 类 | 基类 | 职责 |
|---|---|---|
| `NovaDataGridColumn` | dataclass | 列定义：`key / label / width / align / editable / editor / options / visible / sortable / formatter` |
| `NovaDataGridRoles` | 常量 | `display / edit / severity / rowKey / highlighted` 五种 role |
| `NovaDataGridModel` | `QAbstractTableModel` | 数据源；`batchUpdate` 合并 `dataChanged`、行高亮 1.5 s、`setVisibleColumns`、行级增删 |
| `NovaDataGridFilterProxy` | `QSortFilterProxyModel` | 全字段快速过滤 + 列级过滤；转发源模型 roleNames |
| `NovaDataGridPagination` | `QObject` | 分页状态：`currentPage / pageSize / total / pageCount / startIndex / endIndex` + 翻页 Slot |
| `NovaDataGridPagedProxy` | `QSortFilterProxyModel` | 按 `startIndex/endIndex` 切片；转发 roleNames |

**批量更新**（工业高频写入）：

```python
table_model.batchUpdate([
    {"slot": "B02", "voltage": 4.01},
    {"slot": "C03", "voltage": 3.75, "_severity": 2},
])
```

同一刷新窗口（50 ms）内的多次写入合并成一次 `dataChanged`，并把被改行短时高亮；
不支持无 `row_key` 的批量更新（无法按 key 匹配行）。

**severity 染色**：行内保留字段 `_severity`（`SEVERITY_FIELD`）：
`0` 正常 / `1` 警告（取 `NovaTheme.warning` 低透明度）/ `2` 严重（`NovaTheme.negative`）。
组件**不新增任何主题令牌**，全部由既有 `NovaTheme` 令牌派生。

## 4. 列级自定义委托

```qml
NovaDataGrid {
    cellDelegates: ({
        "state": statusBadge
    })
    // ...
}
Component {
    id: statusBadge
    Item {
        property var cellData          // 由组件用 Binding 元素自动绑定
        NovaChip {
            anchors.centerIn: parent
            text: String(cellData.value)
            tint: cellData.severity === 2 ? NovaTheme.negative
                : cellData.severity === 1 ? NovaTheme.warning : NovaTheme.primary
            outlined: true
            dense: true
        }
    }
}
```

`cellData = { value, severity, rowIndex, colKey }`，**懒加载**（不含完整行）。
需要完整行时调 `root.getRowData(cellData.rowIndex)`。
实现用 `Binding` 元素按属性名注入，因此委托根无需继承特定基类。

## 5. 服务端模式

设 `serverSide: true`，组件不再本地过滤/排序/切片，只发 `request`：

```js
{
  pagination: {
    sortBy: "voltage", descending: false, page: 1,
    rowsPerPage: 20, rowsNumber: 0
  },
  filter: "B02"
}
```

触发时机：表头排序、搜索防抖（150 ms）、翻页、页大小变更（自动回到第 1 页）、
`pagination.pageSizeChanged`。宿主收到后把当前页数据写回 `tableModel.setRows(...)`
并 `pagination.setTotal(服务端总数)`。`total` 在服务端模式下由宿主管理，组件不覆盖。

## 6. 主题、a11y 与坑位

- **主题**：全部取 `Nova.Services.NovaTheme` 令牌；`severity` / 选中 / 键盘焦点
  用 `Qt.rgba(令牌.r/g/b, α)` 派生，**不新增公共令牌**（旧 145 类型逐字不变）。
- **a11y**：`Accessible.Table` + `a11yLabel`；`↑/↓/Home/End` 移动行游标、
  `Enter` 触发 `rowClicked`、`Space` 切换选中；编辑态短路键盘导航，避免与编辑器冲突。
- **坑位 32（Qt 6.12）**：`reuseItems` 与自定义 delegate 组合会触发进程退出段错误，
  故默认 `false`。`TableView` 仍按可视区创建 delegate，虚拟化不依赖 `reuseItems`；
  宿主若要在其他 Qt 版本开启，需自行实跑验证。
- **坑位 70**：见 §1.2，Python 列表不是 QML 的 JS 数组。
- **坑位 71**：条件高度的 `Rectangle` 的 `visible` **不可绑定自身 `height`**
  （初始 0 → 不可见 → `ColumnLayout` 跳过 → 永不分配高度的自举死锁）；
  必须绑定决定高度的上游属性。
- **坑位 72**：Qt 6.12 起 `Connections` 的隐式 `onFoo: …` 语法已废弃（运行时刷
  Qt 消息），必须用标准 `function onFoo() { … }`；这些 handler 按库内既有惯例进入冻结面。
- **库组件优先**：搜索框 `NovaField + NovaInput`、按钮 `NovaBtn`、列选择器
  `NovaMenu + NovaOptionGroup`、页大小 `NovaBtnToggle`、分页 `NovaPagination`、
  加载态 `NovaSpinner` —— 零裸控件手搓。

## 7. 相关资源

- Gallery 第 25 页：`examples/gallery/main.qml`（`pageDataGrid`）
- 冻结清单：`api/nova-api-1.5.0.json` / 签署件 `docs/API_FREEZE.md`
- 组件自动生成文档：`docs/components/NovaDataGrid.md`（生成器产物）
- 独立演示：`examples/controls/markdown_demo/` 展示的是 `NovaMarkdown`；
  `NovaDataGrid` 的可运行装配见 Gallery 与 `tests/test_nova_datagrid.py`
