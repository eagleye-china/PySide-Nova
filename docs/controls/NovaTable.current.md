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
