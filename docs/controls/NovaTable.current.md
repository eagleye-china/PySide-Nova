# NovaTable 使用文档（1.9.0 现行）

> **模块** `Nova.Controls` · **a11y** `interactive`（`Accessible.Table`）· **pyside-nova 1.9.0** ·
> **API 冻结指纹** `b15a4be38c000c59` · **零第三方依赖**（全库唯一依赖仍是 `PySide6>=6.8`）·
> 公共签名以 `api/nova-api-1.9.0.json` 冻结面为准 · **77 props / 14 signals / 21 methods**。
>
> **史料（不回改）**：同目录 `docs/controls/NovaTable.md` 是 1.5.0 之前的
> 「NovaTable 企业级旗舰封版 · 完整可运行方案」构想稿（1654 行，含独立 `nova/` Python 包
> 与 `TableView + reuseItems` 路线），**不是本组件文档**，一直由 `mkdocs.yml` 的
> `exclude_docs: controls/NovaTable.md` 排除、不在文档站发布。本页按「史料不圆场」
> **另立现行文档**，不改写、不删除构想稿；该构想稿的 B 路径实际落地为另立的
> `NovaDataGrid` 类型，见 `docs/controls/NovaDataGrid.md` §0。
>
> 本页是**手写使用文档**（`docs/controls/` 不属生成物目录）。组件源码：
> `src/pyside_nova/qml/Nova/Controls/NovaTable.qml`。

---

## 🆕 §0 · 1.10.0 现行校准（2026-11-28 · 完全对标 Quasar QTable）

> **本段是唯一现行口径**，覆盖下方 §1~§13 的 1.9.0 快照；下方全部正文（含标题中的
> 「1.9.0」、`77 props / 14 signals / 21 methods`、指纹 `b15a4be38c000c59`）按
> 「史料不圆场」**逐字保留、不回改**。

| 项 | 1.9.0（已发布史料） | **1.10.0（现行）** |
|---|---|---|
| 包 / API 版本 | 1.9.0 | **1.10.0** |
| 冻结指纹 | `b15a4be38c000c59` | **`5328cd0e3c71e7ac`** |
| 冻结清单 | `api/nova-api-1.9.0.json` | `api/nova-api-1.10.0.json` |
| `NovaTable` 公共面 | 77 / 14 / 21 | **110 / 18 / 26** |
| `NovaTr` | 2 props / 2 signals | 3 props / 3 signals（`rowColor` / `rowContextMenu`） |
| 类型总数 | 147 | **147（不变）** |
| 发布态 | **已由 CSA 发布**（HEAD `f209387` · tag `v1.9.0` · 工作树干净） | **本地完成，待 CSA 发布** |

1.10.0 **新增 33 props / 4 signals / 5 methods，旧 77/14/21 逐成员零丢失**；
完整签名见 `api/nova-api-1.10.0.json` 的 `types["Nova.Controls.NovaTable"]`，
`tests/test_nova_table.py` 机检固化。**完整度量化与逐项映射见 §14，框架边界逐项登记见 §15。**

### §0.1 补齐 8 个插槽 → QTable 21 slots 全覆盖

| 新增 | 对标 | 注入包 |
|---|---|---|
| `bodyCellDelegate` | `body-cell` | `cellData`（全局 fallback，低于 `cellDelegates[列名]`） |
| `headerCellDelegate` | `header-cell` | `cellData`（全局 fallback） |
| `bodySelectionDelegate` | `body-selection` | `slotData`（`rowSelected` / `rowData` …） |
| `headerSelectionDelegate` | `header-selection` | `slotData`（`allSelected` / `someSelected` …） |
| `paginationDelegate` | `pagination` | `slotData`（`pagination` / `firstRowIndex` / `lastRowIndex` …） |
| `topLeftDelegate` / `topRightDelegate` | `top-left` / `top-right` | `slotData`（表格级状态） |
| `topSelectionDelegate` | `top-selection` | `slotData`（`selected` / `keys` / `selectedCount`） |

> **委托声明契约不变**（下方 §5）：宿主委托必须显式声明 `property var slotData: ({})`
> 或 `property var cellData: ({})`，否则 Qt 6 会报 `Binding: Property ... does not exist`。

### §0.2 补齐 5 个方法与 4 个事件 → QTable 15 methods / 9 events 全覆盖

- 方法：`lastPage()` · `clearSelection()` · `setExpanded(keys)` · `sort(name)` ·
  `getCellValue(col, row)`（后者的存在同时让 `filterRowsMethod` 的 `getCellValue` 参数可用）。
- 事件：`rowContextMenu(row, index)` · `selectionChanged(info)`（含
  `rows / keys / added / removed`）· `paginationChanged(pagination)` ·
  `virtualScrollInfo(info)`（含 `firstRowIndex / lastRowIndex / contentY / contentHeight`）。
- 只读聚合量 `paginationState` / `selectionInfo` 对标 `pagination` 对象与 `@selection` 载荷。

### §0.3 官方语义校准（另立成员，不劫持已发布语义）

Quasar 官方 `QTable.json` 定义：`sort-method` = `(rows, sortBy, descending) => Array`
（**整体排序**）、`filter-method` = `(rows, terms, cols, getCellValue) => Array`
（**整体过滤**）。1.9.0 的 `filterMethod(row, filter) -> bool` 是早期**单行谓词**，
已发布、原样保留。1.10.0 **另立** `sortMethod` / `filterRowsMethod` 承载官方语义 ——
与 `grid`（描边）/ `viewMode`（卡片）同一纪律。

其余：官方 `row-key: Function` → `rowKeyFn`；`selection` 三态 → `selectionMode`；
`columns[].field / style / classes` 升为可接 `Function`。

### §0.4 样式语义令牌（CSS 专属项的等价承接）

官方 12 个 `table-*-style/class` / `card-*` / `*-fn` 是 CSS 字符串 / Vue class 对象；
QML 无 CSS 解析。本版以 `tableStyleToken` / `tableHeaderStyleToken` / `rowStyleFn` /
`cardContainerStyleToken` / `cardStyleToken` / `cardStyleFn` 映射 `NovaTheme` 语义令牌
（`primary` / `positive` / `negative` / `warning` / `muted` / `surface` / `surfaceAlt` /
`outline`），**不接受任意 CSS**。逐项边界见 §15。

---

## 1. 定位与选型

`NovaTable` 是 **1.0.0 GA 起就在冻结面里的纯 QML 数据表格**：数据由宿主以
`rows: var` / `columns: var` 直接喂入，不接 Python 模型，不引入任何第三方依赖。
1.9.0 按 Quasar `QTable` 的能力面补齐插槽、列定义元字段、列显隐、卡片视图、
全屏 / 导出 / 触底意图、响应式与密度，**全部为 additive**，

> 旧 **45 props / 7 signals / 13 methods 逐字不变**（`tests/test_nova_table.py` 机检固化）。

| | `NovaTable`（本页） | `NovaDataGrid`（1.5.0 起） |
|---|---|---|
| 数据输入 | 纯 QML `rows` / `columns` | Python `pyside_nova.datagrid` 模型 + 代理链 |
| 渲染 | `Repeater` + `ListView` 虚拟滚动 | `TableView` + `HorizontalHeaderView` 真虚拟化 |
| 依赖 | 纯 QML、零 Python | 仍仅 `PySide6>=6.8`，但需 Python 侧装配 |
| 选中 / 展开 | **受控**（只 emit 意图，宿主写回） | 组件内 `ItemSelectionModel` 就地选中 |
| 插槽 | 1.9.0 完整插槽体系 | 1.8.0 完整插槽体系 + 分组树 / 编辑器 |
| 适用 | 数据已在 QML 侧、零 Python 接入、轻量表格 | 数据来自 Python / 数据库、行量大、需内联编辑 |

**两者并存**，互不替换。选型分界一句话：要「零 Python 接线」用 `NovaTable`；
要「大模型 / 编辑 / 分组树 / 冻结列」用 `NovaDataGrid`。

---

## 2. 快速开始

```qml
import QtQuick
import Nova.Controls

NovaTable {
    width: 720; height: 420
    a11yLabel: "订单列表"

    columns: [
        { name: "id",    label: "单号", field: "id",    sortable: true, width: 110 },
        { name: "owner", label: "负责人", field: "owner", sortable: true },
        { name: "amount",label: "金额", field: "amount", align: "right",
          format: function (v) { return "¥" + Number(v).toFixed(2) } }
    ]
    rows: [
        { id: "A-01", owner: "张三", amount: 1280 },
        { id: "A-02", owner: "李四", amount: 960  }
    ]

    rowKey: "id"
    rowsPerPage: 10

    // 受控模式：组件只发意图，宿主写回
    onUpdateSelected: function (rows) { selected = rows }
    onUpdateExpanded: function (keys) { expanded = keys }
    onSortChanged: function (field, desc) { sortBy = field; descending = desc }
    onPageRequested: function (p) { page = p }
}
```

> **坑位 22 / 受控模式**：`selected` / `expanded` / `sortBy` / `descending` /
> `page` / `rowsPerPage` **组件内不自写**。组件只 emit
> `updateSelected` / `updateExpanded` / `sortChanged` / `pageRequested` /
> `rowsPerPageRequested`，由宿主写回才会变化。服务端模式下这些意图同时汇入
> `request(var params)`，宿主据 `params.pagination` 与 `params.filter` 取数后回写 `rows`。

---

## 3. 数据管道与派生链

```
rows ──▶ filteredRows ──▶ sortedRows ──▶ visibleRows ──▶ 表体 / 卡片
        (filter /        (sortBy /       (page /
         filterMethod)    descending)     rowsPerPage)
```

- **客户端模式**（默认）：`filter` 全字段包含匹配，`filterMethod(row, filter)` 可完全接管；
  排序三态（无序→升→降→无序）或 `binaryStateSort` 两态，`columnSortOrder` 控制
  首次点击优先升（`ad`）还是优先降（`da`）。
- **服务端模式**（`serverSide: true`）：`filteredRows` / `sortedRows` 直通 `rows`，
  `rows` 即宿主返回的**当前页切片**；`rowCount` 取 `rowsNumber`（`-1` 回落 `rows.length`），
  `pageCount` 据此计算。
- **虚拟滚动**（`virtualScroll: true`）：表体走 `ListView` 真虚拟化，
  `virtualScrollItemSize` 为行高估高，建议 `rowsPerPage: 0`；
  `resetVirtualScroll()` 复位并 emit `virtualScrollReset()`。

只读派生量：`filteredRows` / `sortedRows` / `visibleRows` / `rowCount` / `pageCount` /
`normColumns` / `allVisibleSelected` / `someSelected` / `virtualContentY` /
`virtualContentHeight` / `virtualRowCount`。

---

## 4. 对标 Quasar QTable 能力映射（1.9.0）

| Quasar QTable | NovaTable 落点 | 状态 |
|---|---|---|
| `rows` / `columns` | `rows` / `columns` | GA 起 |
| `filter` / `filter-method` | `filter` / `filterMethod` | GA 起 |
| `sort-by` / `descending` / `binary-state-sort` | `sortBy` / `descending` / `binaryStateSort` | GA 起 |
| `column-sort-order` | `columnSortOrder`（`ad` / `da`） | **1.9.0** |
| `columns[].sort` / `rawSort` / `format` | 列定义 `sort` / `rawSort` / `format(val, row)` | **1.9.0** |
| `pagination` / `rows-per-page-options` | `page` / `rowsPerPage` / `rowsPerPageOptions` + 页大小 UI | **1.9.0** |
| `selection` / `selected` | 受控 `selected` + `updateSelected` | GA 起 |
| `expanded` / `body-expand` slot | 受控 `expanded` + `expandSlot` | GA 起 |
| `visible-columns` / `QTableColumns` | `visibleColumns` / `showColumnSelector` / `setVisibleColumns()` | **1.9.0** |
| `grid` mode / `grid-header` | `viewMode: "grid"` / `gridHeader` / `gridDelegate` | **1.9.0** |
| `fullscreen` | `fullScreen` / `toggleFullScreen()` / `fullScreenToggled()` | **1.9.0** |
| `dense` / `separator` / `flat` / `bordered` | 同名属性 | **1.9.0** |
| `top` / `bottom` / `top-row` / `bottom-row` / `footer` slots | 同名 5 个 `Component` 插槽 | **1.9.0** |
| `body` / `body-cell-[name]` slots | `bodyDelegate` / `cellDelegates` | **1.9.0** |
| `header` / `header-cell-[name]` slots | `headerDelegate` / `headerCellDelegates` | **1.9.0** |
| `no-data` / `loading` slots + `no-results-label` | 同名 2 个 `Component` + `noResultsLabel` | **1.9.0** |
| `loading` / `loading-label` / `no-data-label` | 同名属性 | GA 起 |
| `virtual-scroll` | `virtualScroll` / `virtualScrollItemSize` / `resetVirtualScroll()` | GA 起（1.9.0 补复位信号） |
| `request` / server-side | `serverSide` / `rowsNumber` / `request(var params)` | GA 起 |
| `@request` 触底加载 | `loadMoreEnabled` / `loadMoreThreshold` / `loadMoreRequested(lastRow)` | **1.9.0** |
| 导出（示例级） | `exportCsv(delimiter)` / `exportRequested(csvText)` | **1.9.0** |

> **边界如实登记**：`grid` 属性在 1.0.0 时已表示「单元格描边」，属已发布语义，
> 1.9.0 **不劫持**它；真卡片视图另立 `viewMode: "grid"`，老用法零迁移成本。
> CSV 与全屏、触底、清筛选、页大小变更**只发意图 / 只拼字符串**，组件**不写磁盘、
> 不自动改窗口状态、不自动发网络请求**，宿主自行决定落点。

---

## 5. 完整插槽体系

| 插槽 | 类型 | 对标 | 上下文 |
|---|---|---|---|
| `topDelegate` | `Component` | `top` | 表格顶部工具区 |
| `bottomDelegate` | `Component` | `bottom` | 表格底部工具区 |
| `topRowDelegate` | `Component` | `top-row` | 表体上方的附加行 |
| `bottomRowDelegate` | `Component` | `bottom-row` | 表体下方的附加行 |
| `footerDelegate` | `Component` | `footer` | 页脚合计行 |
| `bodyDelegate` | `Component` | `body` | 整行替换 |
| `headerDelegate` | `Component` | `header` | 整表头替换 |
| `noDataDelegate` | `Component` | `no-data` | 空态（含 no-results 分流） |
| `loadingDelegate` | `Component` | `loading` | 加载覆盖层 |
| `gridDelegate` | `Component` | grid 卡片 | `slotData` |
| `expandSlot` | `Component` | `body-expand` | 展开行（GA 起保留） |
| `cellDelegates` | `var`（`{列名: Component}`） | `body-cell-[name]` | 单元格上下文 |
| `headerCellDelegates` | `var`（`{列名: Component}`） | `header-cell-[name]` | 表头单元格上下文 |

> **⚠️ 委托声明契约（必读）**：组件通过 `Binding { property: "slotData" ... }` 向
> 行级 / 外围 / grid 卡片委托注入**一个** `slotData` 属性，通过
> `Binding { property: "cellData" ... }` 向单元格委托注入**一个** `cellData` 属性；
> 二者值都是 JS 对象（数据包）。**宿主委托必须显式声明同名属性**，否则 QML 会报
> `QML Binding: Property 'slotData' does not exist on Rectangle` —— 这是 Qt 6 静态属性
> 绑定的要求，与 `TableView` delegate 的 `required property` 同理。`expandSlot` 例外：
> 走 `onLoaded` 带 `!== undefined` 守卫逐项赋值，可选声明 `rowData` / `rowIndex`。
>
> ```qml
> Component {
>     id: rowSlot
>     Rectangle {
>         property var slotData: ({})     // 行级 / 外围 / grid 插槽必声明
>         property var cellData: ({})     // 单元格级委托必声明
>         // 取值：slotData.rowData / slotData.rowKey / cellData.value ...
>     }
> }
> NovaTable {
>     bodyDelegate: rowSlot
>     cellDelegates: ({ "id": rowSlot })
>     expandSlot: rowSlot
> }
> ```
>
> 离屏真机按此契约全插槽激活实测 **0 坏 Qt 消息**；若用裸 `Rectangle` 不声明属性，
> 会产生 12 条 `Binding` warning（宿主注入侧问题，非组件缺陷，坑位 76 同类）。

数据包字段（对**插槽委托**而言从 `slotData` / `cellData` 包内取值；`rowData` 等同时作为
`rowWrap` 内部属性存在于冻结面 props 中，是组件实现细节，不要当作委托顶层属性直接引用）：

| 字段 | 所属包 | 含义 |
|---|---|---|
| `rowData` | `slotData` / `cellData` | 当前行对象 |
| `rowIndex` | `slotData` / `cellData` | 当前行序号 |
| `rowKey` | `slotData` | 行键（`rowKey` 字段或原始序号） |
| `rowSelected` / `rowExpanded` | `slotData` | 选中 / 展开态 |
| `columns` | `slotData` / `cellData` | 当前可见列定义 |
| `value` / `text` | `cellData` | 原始值 / 格式化文本 |
| `colName` / `colLabel` / `color` | `cellData` | 列名 / 表头文案 / 列级语义色 |
| `selected` / `rowCount` / `page` / `pageCount` | 外围插槽 `slotData` | 表格级状态 |

> 1.9.0 修复过一次真机缺陷：表头 / 表体 `Repeater` 的 delegate 外层统一包
> `Item { required property int index }`，避免把带 `anchors.fill` 的 `Loader` 直接塞进
> `NovaTh` / `NovaTd` 内部 `Row` 而触发 `Cannot specify ... anchors`；离屏真机全插槽
> 激活实测 `TOTAL_MSGS = 0`。

---

## 6. 列定义元字段（`columns[]`）

`columns` 既接受字符串（退化为 `name = label = field`），也接受对象：

| 字段 | 类型 | 含义 |
|---|---|---|
| `name` / `label` / `field` | `string` | 列标识 / 表头文案 / 取值字段 |
| `align` | `string` | `left` / `center` / `right` |
| `sortable` / `required` | `bool` | 可排序 / 列选择器中恒可见且不可隐藏 |
| `width` / `autoWidth` | `int` / `bool` | 固定列宽 / 按内容自适应 |
| `format` | `function(val, row)` | 显示格式化（如金额加 `¥`） |
| `sort` / `rawSort` | `function(a, b, rowA, rowB)` | 自定义比较器（`rawSort` 优先） |
| `sortOrder` | `string` | 单列排序优先方向 |
| `style` / `headerStyle` | `string` | 语义样式名（**只映射 `NovaTheme` 令牌，不接受任意 CSS**） |
| `classes` / `headerClasses` | `var` | 语义样式类数组，同上 |
| `cellStyle` | `var` | GA 起既有单元格样式入口 |

---

## 7. 列显隐与列选择器

- `visibleColumns: []` 表示全部可见；非空时按 `name` 过滤，`required: true` 的列恒可见。
- `showColumnSelector: true` 打开内置列选择器（走库组件，不手搓）。
- `setVisibleColumns(keys)` 批量设置、`toggleColumnVisibility(name)` 单列切换，
  二者均 emit `columnVisibilityChanged(var keys)` 由宿主同步外部状态。

---

## 8. 视图形态与响应式

| 属性 | 取值 / 默认 | 说明 |
|---|---|---|
| `viewMode` | `"table"` / `"grid"` | 表格 / 卡片视图；`setViewMode(mode)` 切换 |
| `gridHeader` | `false` | grid 视图下是否保留表头 |
| `gridCellWidth` / `gridCellHeight` | `220` / `128` | 卡片尺寸 |
| `grid` | `false` | **GA 语义：单元格描边开关**，与 `viewMode` 解耦 |
| `responsive` | `false` | 开启后按 `gridBreakpoint`（默认 `640`）窄屏自动切 grid |
| `dense` | `false` | 行高 `44 → 32` |
| `separator` | `"horizontal"` | `horizontal` / `vertical` / `cell` / `none` |
| `flat` / `bordered` | `false` / `!flat` | 外框与扁平化 |
| `hideHeader` / `hideBottom` | `false` | 隐藏表头 / 分页条 |

---

## 9. 意图信号（组件不越权）

| 触发 | 信号 | 宿主职责 |
|---|---|---|
| 全屏按钮 | `fullScreenToggled(bool active)` | 自行改窗口 / 布局 |
| 导出按钮 / `exportCsv(delimiter)` | `exportRequested(var csvText)` | 自行决定写文件 / 下载 |
| 触底 | `loadMoreRequested(int lastRow)` | 自行追加下一页数据 |
| 清筛选 | `clearFilterRequested()` | 写回 `filter = ""` |
| 页大小变更 | `rowsPerPageRequested(int size)` | 写回 `rowsPerPage` |
| 列显隐 | `columnVisibilityChanged(var keys)` | 同步外部状态 |
| 虚拟滚动复位 | `virtualScrollReset()` | 需要时重置宿主侧游标 |

`exportCsv(delimiter)` 在 QML 内按 `normColumns` 拼装 CSV 文本，
`exportDelimiter` 为默认分隔符；`_csvCell()` 处理引号与转义。
**不引入 `csv` 模块、不写磁盘、不弹保存框**。

---

## 10. 无障碍与键盘

`Accessible.role = Accessible.Table`、`Accessible.name = a11yLabel`、
`activeFocusOnTab: true`。键盘路径：
`↑/↓` 移动行游标、`Home/End` 首尾、`PageUp/PageDown` 十行跳转、
`Enter` 触发 `rowClicked`、`Space` 切换勾选；游标移动自动 `scrollTo()`。

---

## 11. 公共面（1.9.0 冻结）

- **45 个 GA 属性**逐字保留（含 `columns` / `rows` / `filter` /
  `virtualScroll` / `grid` / `expandSlot` / `selected` / `expanded` …）。
- **新增 32 props**：`viewMode` `gridHeader` `gridDelegate` `gridCellWidth`
  `gridCellHeight` `dense` `responsive` `gridBreakpoint` `separator`
  `visibleColumns` `showColumnSelector` `fullScreen` `showFullScreenButton`
  `showExportButton` `exportDelimiter` `loadMoreEnabled` `loadMoreThreshold`
  `clearFilterText` `noResultsLabel` `bodyDelegate` `headerDelegate`
  `cellDelegates` `headerCellDelegates` `topDelegate` `bottomDelegate`
  `topRowDelegate` `bottomRowDelegate` `footerDelegate` `noDataDelegate`
  `loadingDelegate` `columnSortOrder` `slotData`。
- **新增 7 signals**：`fullScreenToggled` `exportRequested` `loadMoreRequested`
  `clearFilterRequested` `rowsPerPageRequested` `columnVisibilityChanged`
  `virtualScrollReset`。
- **新增 8 methods**：`setViewMode` `toggleFullScreen` `setVisibleColumns`
  `toggleColumnVisibility` `clearFilter` `exportCsv` `requestRowsPerPage`
  `resetVirtualScroll`。

完整逐成员签名见 `api/nova-api-1.9.0.json` 的
`types["Nova.Controls.NovaTable"]`，`scripts/check_api_freeze.py` 机检零漂移。

---

## 12. 验收与边界

- **冻结**：`147 类型 / Controls 93 / LayoutShell 21` 不变，指纹
  `89d5d3cdd7f94cf0` → `b15a4be38c000c59`（additive minor 重签）。
- **机检**：`tests/test_nova_table.py` 固化 77/14/21 公共面、旧 45/7/13 零漂移、
  qmldir 导出、a11y 登记、零第三方依赖、插槽与意图声明、文档事实、
  mkdocs nav / exclude、CHANGELOG 与徽标版本。
- **真机**：离屏 `QQmlApplicationEngine` 全插槽激活，
  `TOTAL_MSGS = 0`；`fullScreenToggled` / `exportRequested` /
  `columnVisibilityChanged` / `rowsPerPageRequested` / `clearFilterRequested` 实证生效。
- **qmllint**：`0 error`；本文件显式关闭 `unqualified` 类别，全库 warning 预算只降不升。
- **不做**：不接 Python 模型、不写磁盘、不发网络请求、不自动改窗口状态、
  不引入 QtWebEngine 或任何第三方依赖、不改写 `docs/controls/NovaTable.md` 史料。
- **发布**：1.9.0 本地完成，`commit / push / tag / PyPI / 站点上线` 一律归 CSA。

---

## 13. 史料指针

| 对象 | 处置 |
|---|---|
| `docs/controls/NovaTable.md`（1654 行构想稿） | 原样保留，`exclude_docs` 排除，不上文档站 |
| `api/nova-api-1.8.0.json`（指纹 `89d5d3cdd7f94cf0`） | 已发布史料，不回改 |
| `docs/controls/NovaDataGrid.md` §0 | 构想稿 B 路径落地为 `NovaDataGrid` 的裁决记录 |
| 本页 | 1.9.0 现行使用文档，nav 条目「NovaTable 使用文档（1.9.0 现行）」 |

---

## 14. Quasar QTable 完整度评估（1.10.0）

> **数据源**：Quasar Framework 官方仓库 `ui/src/components/table/QTable.json`
> （`dev` 分支，2026-11-28 取）+ 官方页 `https://quasar.dev/vue-components/table`。
> **分母**：63 props + 21 slots + 9 events + 15 methods + 15 列定义元字段 = **123 项**。
> **口径**：`完全对齐` = 同名/等价成员且语义一致；`部分` = 有成员但语义或取值受限；
> `未覆盖` = 无对应成员；`框架不适用` = QML 无该 DOM/CSS 语义。

### 14.1 量化结论

| | 完全对齐 | 部分 | 未覆盖 | 框架不适用 | 字面完整度 | 能力面可解释覆盖 |
|---|---|---|---|---|---|---|
| **1.9.0（已发布）** | 65 | 9 | 48 | 1 | **65/123 = 52.8%** | 65 + 9 + 已承接者 ≈ 56.5% |
| **1.10.0（现行）** | **114** | **0** | **8** | 1 | **114/123 = 92.7%** | **123/123 = 100%** |

剩余 8 项全部是**框架边界或库内分工**，逐项登记于 §15，无功能性缺口。

### 14.2 分类逐项统计

| 类别 | 分母 | 1.9.0 完全对齐 | 1.10.0 完全对齐 | 增量来源 |
|---|---|---|---|---|
| props | 63 | 25 | **54** | 29 项（行为开关 / 文案 / 样式令牌 / 虚拟滚动细项 / 官方语义成员） |
| slots | 21 | 13 | **21** | 8 个新 `Component` 插槽 |
| events | 9 | 5 | **9** | 4 个新信号 |
| methods | 15 | 10 | **15** | 5 个新方法 |
| 列定义元字段 | 15 | 12 | **15** | `field` / `style` / `classes` 升为可接 `Function` |
| **合计** | **123** | **65** | **114** | **+49** |

### 14.3 QTable 21 slots → NovaTable 1.10.0 全映射

| Quasar slot | NovaTable | Quasar slot | NovaTable |
|---|---|---|---|
| `loading` | `loadingDelegate` | `item`（grid 卡片） | `gridDelegate` |
| `body` | `bodyDelegate` | `body-cell` | **`bodyCellDelegate`** |
| `body-cell-[name]` | `cellDelegates[列名]` | `header` | `headerDelegate` |
| `header-cell` | **`headerCellDelegate`** | `header-cell-[name]` | `headerCellDelegates[列名]` |
| `body-selection` | **`bodySelectionDelegate`** | `body-expand` | `expandSlot` |
| `header-selection` | **`headerSelectionDelegate`** | `top-row` | `topRowDelegate` |
| `bottom-row` | `bottomRowDelegate` | `footer` | `footerDelegate` |
| `top` | `topDelegate` | `bottom` | `bottomDelegate` |
| `pagination` | **`paginationDelegate`** | `top-left` | **`topLeftDelegate`** |
| `top-right` | **`topRightDelegate`** | `top-selection` | **`topSelectionDelegate`** |
| `no-data` | `noDataDelegate` | | |

### 14.4 QTable 15 methods → NovaTable 1.10.0 全映射

| Quasar method | NovaTable | Quasar method | NovaTable |
|---|---|---|---|
| `requestServerInteraction` | 同名 | `setPagination` | 同名 |
| `firstPage` | 同名 | `prevPage` | 同名 |
| `nextPage` | 同名 | `lastPage` | **同名（新增）** |
| `isRowSelected` | 同名 | `clearSelection` | **同名（新增）** |
| `isRowExpanded` | 同名 | `setExpanded` | **同名（新增）** |
| `sort` | **同名（新增）** | `toggleFullscreen` | `toggleFullScreen` |
| `resetVirtualScroll` | 同名 | `scrollTo` | 同名 |
| `getCellValue` | **同名（新增）** | | |

### 14.5 QTable 9 events → NovaTable 1.10.0 全映射

| Quasar event | NovaTable | Quasar event | NovaTable |
|---|---|---|---|
| `row-click` | `rowClicked` | `row-dblclick` | `rowDoubleClicked` |
| `row-contextmenu` | **`rowContextMenu`** | `request` | `request` |
| `selection` | **`selectionChanged`** | `update:pagination` | **`paginationChanged`** |
| `update:selected` | `updateSelected` | `update:expanded` | `updateExpanded` |
| `virtual-scroll` | **`virtualScrollInfo`** | | |

### 14.6 勘误登记

下方 §13 史料表格中「`api/nova-api-1.9.0.json`（指纹 `89d5d3cdd7f94cf0`）」为
1.9.0 撰写时的笔误：`89d5d3cdd7f94cf0` 实为 **1.8.0** 指纹，1.9.0 指纹应为
**`b15a4be38c000c59`**。按「史料不圆场」下方正文逐字保留，此处校准，不再回改。

---

## 15. 框架边界登记（1.10.0）

| Quasar 项 | 数量 | 处置 |
|---|---|---|
| `virtual-scroll-target` | 1 | DOM 滚动容器专属；QML `ListView` 自身即滚动容器 |
| `table-colspan` | 1 | `table-layout: fixed` / 原生 `<table>` 专属；QML 列宽由 `_colWidth()` 计算 |
| `virtual-scroll-slice-ratio-before` / `after` | 2 | Qt `ListView.cacheBuffer` 前后对称，无独立比例；由 `virtualScrollSliceSize` 统一驱动 |
| `icon-first-page` / `icon-prev-page` / `icon-next-page` / `icon-last-page` | 4 | 由库组件 `NovaPagination` 的字形与 `BoundaryLinks` 体系承接；不引入 Quasar 图标字体名（库组件优先零手搓） |
| `dark` | 1 | 走全局 `NovaTheme` 主题，不由表格单独翻转 |
| `aria-sort` / 原生 `<table>` 语义 | — | Qt 走 `Accessible.Table` + `Accessible.name` + 键盘路径（§10），无 HTML ARIA 属性 |

> **sticky 首/末列**：Quasar 依赖 CSS `position: sticky` 与横向滚动；`NovaTable` 为纯
> 流式布局（列宽均分、无横向滚动），故不伪造。库内 **1.8.0 的 `NovaDataGrid` 已实现
> 真实 sticky 首末列**，按选型分界由它承接（见 §1）。

---

## 16. 1.10.0 验收与边界

- **冻结**：147 类型 / Controls 93 / LayoutShell 21 不变，指纹
  `b15a4be38c000c59` → `5328cd0e3c71e7ac`（additive minor 重签）；
  `api/nova-api-1.9.0.json` 为已发布史料，不回改。
- **机检**：`tests/test_nova_table.py` 固化 110/18/26 公共面、旧 77/14/21 逐成员零漂移、
  QTable 21 slots / 15 methods / 9 events 全映射、qmldir 导出、a11y 登记、
  零第三方依赖、史料稿逐字保留、CHANGELOG 与徽标版本。
- **真机**：离屏 `QQmlApplicationEngine` 全插槽激活，要求 `TOTAL_MSGS = 0`。
- **qmllint**：`0 error`；全库 warning 预算只降不升。
- **不做**：不接 Python 模型、不写磁盘、不发网络请求、不自动改窗口状态、
  不引入 QtWebEngine 或任何第三方依赖、不解析 CSS、不改写史料稿。
- **发布**：1.10.0 本地完成，`commit / push / tag / PyPI / 站点上线` 一律归 CSA。
