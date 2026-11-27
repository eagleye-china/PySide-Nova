# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [1.10.0] - 2026-11-28 — NovaTable 完全对标 Quasar QTable（additive minor · 本地完成，待 CSA 发布）⭐ 当前状态

> **版本说明**：**1.9.0 已由 CSA 发布**（HEAD `f209387 chore(release): v1.9.0` · tag `v1.9.0` · 工作树干净），
> 属史料事实，正文不回改；下方 1.9.0 段标题的「本地完成，待 CSA 发布 ⭐ 当前状态」为撰写时口径，
> 其发布态与现行状态均由本段接替校准。
> 本段以 Quasar 官方 `ui/src/components/table/QTable.json` 全表为口径做「完全对标」收口，
> **不新增 QML 导出类型**（仍 **147 类型 / Controls 93 / LayoutShell 21**），
> 冻结指纹 `b15a4be38c000c59` → `5328cd0e3c71e7ac`（公共面入面后重签，旧指纹为已发布史料）。
> `api/nova-api-1.10.0.json` / `api/component-domains-1.10.0.json` / `docs/API_FREEZE.md` 为生成物禁手改。

### 完整度评估（Quasar QTable 官方 API 全表 = 123 项）

| 口径 | 1.9.0（已发布） | 1.10.0（本版） |
|---|---|---|
| 分母 | 63 props + 21 slots + 9 events + 15 methods + 15 列元字段 = **123** | 同左 |
| 完全对齐 | **65 项 · 52.8%** | **114 项 · 92.7%** |
| 部分对齐 | 9 项 | 0 项 |
| 未覆盖 | 48 项 | 8 项（全部为框架边界 / 库组件承接，逐项登记） |
| 框架不适用 | 1 项（`dark`，走全局 `NovaTheme`） | 1 项 |
| **能力面可解释覆盖** | 65 + 9 + 48 中已承接者 | **123 / 123 · 100%** |

### 新增（Added）

- **公共面 77/14/21 → 110/18/26**：新增 **33 props / 4 signals / 5 methods**，
  旧 77/14/21 逐成员零丢失（`tests/test_nova_table.py` 机检固化）；`NovaTr` additive
  +1 prop（`rowColor`）+1 signal（`rowContextMenu`），147 类型不变。
- **插槽 13 → 21，QTable 21 slots 全覆盖**：新增 `bodyCellDelegate` / `headerCellDelegate` /
  `bodySelectionDelegate` / `headerSelectionDelegate` / `paginationDelegate` /
  `topLeftDelegate` / `topRightDelegate` / `topSelectionDelegate`。
- **方法 21 → 26，QTable 15 methods 全覆盖**：新增 `lastPage()` / `clearSelection()` /
  `setExpanded(keys)` / `sort(name)` / `getCellValue(col, row)`。
- **事件补齐**：`rowContextMenu` / `selectionChanged` / `paginationChanged` /
  `virtualScrollInfo`，与 QTable 9 events 一一对齐；`pagination` / `selectionInfo` 只读聚合量。
- **官方语义校准（不劫持已发布语义）**：官方 `sort-method` 是
  `(rows, sortBy, descending) => Array` 整体排序、`filter-method` 是
  `(rows, terms, cols, getCellValue) => Array` 整体过滤；1.9.0 的 `filterMethod` 是早期
  单行谓词（已发布，原样保留），本版**另立** `sortMethod` / `filterRowsMethod` 等价成员 ——
  与 `grid`（描边）/ `viewMode`（卡片）同一纪律。
- **列元字段 15/15**：`field` / `style` / `classes` 升为可接 `Function`（`rowKeyFn` 补
  `row-key: Function`）；`selectionMode` 补 `none` / `single` / `multiple`。
- **行为开关与文案**：`square` / `wrapCells` / `hideSelectedBanner` / `hideNoData` /
  `hidePagination` / `selectedRowsLabel` / `rowsPerPageLabel` / `paginationLabel` /
  `colorToken` / `titleClass`。
- **虚拟滚动细项**：`virtualScrollSliceSize`（驱动 `ListView.cacheBuffer`）、
  `virtualScrollStickySizeStart` / `End`（驱动视口几何）、`virtualScrollInfo` 事件。
- **样式语义令牌**（对标 12 个 CSS 专属 `table-*-style/class` / `card-*` / `*-fn`）：
  `tableStyleToken` / `tableHeaderStyleToken` / `rowStyleFn` / `cardContainerStyleToken` /
  `cardStyleToken` / `cardStyleFn`。**只映射 `NovaTheme` 令牌，不解析 CSS、不引入第三方依赖。**
- **现行文档**：`docs/controls/NovaTable.current.md` 头部追加 1.10.0 现行校准段 +
  §14 完整度评估 / §15 框架边界登记；下方 1.9.0 正文按「史料不圆场」逐字保留。

### 框架边界（如实登记，不伪造实现）

| Quasar 项 | 处置 |
|---|---|
| `virtual-scroll-target` / `table-colspan` | DOM / `table-layout:fixed` 专属，QML 无对应语义 |
| `virtual-scroll-slice-ratio-before` / `after` | Qt `ListView.cacheBuffer` 前后对称，无独立比例；由 `virtualScrollSliceSize` 统一驱动 |
| `icon-first-page` / `icon-prev-page` / `icon-next-page` / `icon-last-page` | 由库组件 `NovaPagination` 的字形体系承接，不引入 Quasar 图标字体名（库组件优先零手搓） |
| `dark` | 走全局 `NovaTheme` 主题，不由表格单独翻转 |
| QTable 的 `aria-sort` / 原生 `<table>` 语义 | Qt 走 `Accessible.Table` + 键盘路径，见现行文档 §10 |

- **不做**：不接 Python 模型、不写磁盘、不发网络请求、不自动改窗口状态、
  不引入 QtWebEngine 或任何第三方依赖、不改写 `docs/controls/NovaTable.md` 史料、
  不回改 1.9.0 冻结面与已发布文档稿。
- **发布**：1.10.0 本地完成，`commit / push / tag / PyPI / 站点上线` 一律归 CSA。

## [1.9.0] - 2026-11-27 — NovaTable 对标 Quasar QTable 打磨（additive minor · 已由 CSA 发布）

> **版本说明**：1.8.0 之上的 **additive minor**；1.8.0 已由 CSA `git tag v1.8.0` / `git push origin v1.8.0` / PyPI 上架发布（HEAD `6c80d42 chore(release): v1.8.0`），属史料事实，正文不回改；上方 1.8.0 段标题的「待 CSA 发布 ⭐ 当前状态」为撰写时口径，其发布态与现行状态均由本段接替校准。
> 本段只做 `NovaTable` 公共面增量，**不新增 QML 导出类型**（仍 **147 类型 / Controls 93 / LayoutShell 21**），
> 冻结指纹 `89d5d3cdd7f94cf0` → `b15a4be38c000c59`（公共面入面后重签，旧指纹为已发布史料）。
> `api/nova-api-1.9.0.json` / `api/component-domains-1.9.0.json` / `docs/API_FREEZE.md` 为生成物禁手改。

### 新增（Added）

- **公共面 45/7/13 → 77/14/21**（旧面逐成员零丢失，`test_nova_table.py` 机检固化）：新增 32 props /
  7 signals / 8 methods，全部为 additive，不改任何既有签名、默认值与视觉语义。
- **Quasar QTable 插槽体系**：`topDelegate` / `bottomDelegate` / `topRowDelegate` / `bottomRowDelegate` /
  `footerDelegate` / `bodyDelegate` / `noDataDelegate` / `loadingDelegate` 八个外围与空态插槽；
  `headerDelegate` / `headerCellDelegates` / `cellDelegates` / `gridDelegate` 表头与单元格级注册表；
  旧 `expandSlot` 逐字保留。委托上下文 `rowData` / `rowKey` / `rowIdx` / `rowSelected` / `rowExpanded` /
  `slotData` 由组件注入，宿主零 Python 接入。
- **列定义元字段与列选择器**：`columns` 支持 `sort` / `rawSort` / `format` / `align` / `classes` / `style` /
  `headerStyle` / `autoWidth`；`columnSortOrder` 多列排序优先级、`showColumnSelector` +
  `visibleColumns` / `setVisibleColumns(keys)` / `toggleColumnVisibility(name)` /
  `columnVisibilityChanged(keys)` 列显隐受控。
- **真 Grid / 全屏 / 导出 / 触底**：`viewMode`（`table` / `grid`，`gridHeader` 卡片头）与
  `gridCellWidth` / `gridCellHeight` / `setViewMode(mode)`；**旧 `grid` 属性保留「单元格描边」原语义不被劫持**；
  `fullScreen` / `showFullScreenButton` / `toggleFullScreen()` / `fullScreenToggled(active)` 只发意图；
  `exportCsv(delimiter)` / `exportDelimiter` / `showExportButton` / `exportRequested(csvText)` 纯 QML CSV 拼装、
  不写磁盘；`loadMoreEnabled` / `loadMoreThreshold` / `loadMoreRequested(lastRow)` 触底加载。
- **筛选 / 分页 / 虚拟滚动外围**：`clearFilterText` / `clearFilter()` / `clearFilterRequested()`；
  `rowsPerPageOptions` / `requestRowsPerPage(size)` / `rowsPerPageRequested(size)` 页大小 UI 与意图；
  `resetVirtualScroll()` / `virtualScrollReset()` 虚拟滚动复位；
  `noResultsLabel` 区分 no-data 与 no-results，`noDataLabel` / `loadingLabel` 文案可配。
- **密度与响应式**：`dense` / `separator` / `bordered` / `flat` 视觉密度、`responsive` / `gridBreakpoint`
  窄屏自动切 Grid；`viewMode` 与旧 `grid` 双轨并存，老用法零迁移成本。

### 改进（Changed）

- **纯 QML 受控模式不变**：`selected` / `expanded` / `sortBy` / `descending` / `page` / `rowsPerPage`
  组件内不自写，只发 `updateSelected` / `updateExpanded` / `sortChanged` / `pageRequested` /
  `rowsPerPageRequested` 由宿主写回；服务端模式下 `request(params)` 语义逐字保留。
- **文档与验收**：新建现行文档 `docs/controls/NovaTable.current.md` 并加入 mkdocs nav；
  `docs/controls/NovaTable.md` 为 1.5.0 前「企业级旗舰封版方案」构想稿史料，按「史料不圆场」原样保留、
  仍由 `exclude_docs` 排除、不在文档站发布；新增 `tests/test_nova_table.py` 固化公共面、零漂移、
  插槽与意图信号、文档事实；离屏真机全插槽激活 `TOTAL_MSGS=0`。
- **品牌资产**：`sync_brand_version.py` 将封版徽标刻字 `v1.8.0` → `v1.9.0`。

## [1.8.0] - 2026-11-27 — NovaDataGrid P1/P2 打磨（additive minor · 已由 CSA 发布）

> **版本说明**：1.7.0 之上的 **additive minor**；1.7.0 已由 CSA `git tag v1.7.0` / `git push origin v1.7.0` 发布，属史料事实，正文不回改。
> 本段只做 `NovaDataGrid` 公共面增量，不新增 QML 导出类型（仍 **147 类型 / Controls 93 / LayoutShell 21**）；
> 冻结指纹 `157ab2b1d77ea9f9` → `89d5d3cdd7f94cf0`（P1/P2 契约入面后重签，旧指纹为已发布史料）。
> `api/nova-api-1.8.0.json` / `api/component-domains-1.8.0.json` / `docs/API_FREEZE.md` 为生成物禁手改。

### 新增（Added）
- **P1 体验与扩展**：`resizableColumns` / `columnWidths` / `columnWidthResized` / `resetColumnWidths()` 的列宽拖拽与持久化；
  `stickyColumns` 首/末列与 `footerData` 合计行；`bodyDelegate` / `bodyCellDelegate` / `headerDelegate` /
  `headerCellDelegate` 完整插槽；`loadMoreEnabled` / `loadMoreThreshold` / `loadMoreRequested(lastRow)`；
  `pageSizeOptions` / `paginationDelegate` 可替换分页条。
- **P2 形态与外围**：`viewMode` 的 table / grid / masonry 三态 + `gridDelegate` / `gridCellWidth` / `gridCellHeight`；
  `fullScreen` 意图与 `fullScreenToggled`；`exportCsv(delimiter)` / `exportRequested` 纯标准库 CSV；
  `NovaDataGridGroupProxy` 分组 / 树虚拟行 + `groupToggled`；列级 `style/classes/headerStyle/autoWidth`；
  `responsive` / `gridBreakpoint` / `dense` 响应式密度。
- **Python 数据层**：`NovaDataGridColumn` 增 4 个列级元字段；`NovaDataGridModel` 增三个 CSV Slot；
  `NovaDataGridGroupProxy` 导出，零第三方依赖不变。

### 改进（Changed）
- **文档与验收**：`docs/controls/NovaDataGrid.md` 增补 §4.6 / §4.7；专项测试 97 → **99 passed**；
  qmllint 单文件 0 error / 0 warning（本文件显式关闭 unqualified 类别，全库预算只降不升）。

## [1.7.0] - 2026-11-27 — NovaDataGrid P0 打磨（additive minor · 已由 CSA 发布）

> **版本说明**：1.6.0 之上的 **additive minor**；1.6.0 已由 CSA `git tag v1.6.0` / `git push origin v1.6.0` 发布至 PyPI LATEST，属史料事实，正文不回改。
> 本段只做 `NovaDataGrid` 公共面增量，不新增 QML 导出类型（仍 **147 类型 / Controls 93 / LayoutShell 21**）；
> 冻结指纹 `7c542c416709cd96` → `157ab2b1d77ea9f9`（P0 契约入面后重签，旧指纹为已发布史料）。
> `api/nova-api-1.7.0.json` / `api/component-domains-1.7.0.json` / `docs/API_FREEZE.md` 为生成物禁手改。

### 新增（Added）
- **展开行**：`NovaDataGridExpandProxy` 在管道末端按 `rowKey` 插入虚拟展开行，不改写业务数据；QML 新增
  `expandProxy` / `expandedRows` / `expansionDelegate` / `expansionHeight`，`toggleExpansion(row)` /
  `isExpanded(row)` 与 `rowExpansionToggled(rowKey, expanded)`；首列箭头或展开行自身均可折叠。
- **选择体系**：`selectedRows` 只读派生、`selectionDelegate` 自定义首列选择单元格；多选模式支持
  `Ctrl+单击` 切行、`Shift+单击` 范围选择；`selectionChanged(rows)` /
  `requestSelectionAction(action)` / `selectionActionRequested(rows, action)` 供宿主挂自定义动作。
- **编辑器 `select`**：`NovaDataGridColumn(editor="select", options=[...])` 走库组件 `NovaSelect`
  （选项按坑位 70 在 QML 内重建为 JS 数组），提交仍发 `cellEdited`，ESC 取消与失败红框一致。
- **空态区分**：`noResultsText` / `clearFilterText` / `emptyDelegate`，`filterProxy.filterActive` 驱动
  no-data / no-results 分流；`clearFilters()` 与 `clearFilterRequested()` 同时覆盖本地与服务端模式。

### 改进（Changed）
- **a11y 深化**：表头 `Accessible.ColumnHeader` + 可聚焦 Enter/Space 排序，`Accessible.description`
  暴露「可排序 / 升序 / 降序」等价 `aria-sort`；单元格 `Accessible.Cell` + 名称/选中态；
  行游标新增 PageUp/PageDown 十行跳转。
- **文档与验收**：`docs/controls/NovaDataGrid.md` 增补 P0 契约；专项测试 95 → **97 passed**；
  qmllint 仍 0 error / 594 warning 预算内。

## [1.6.0] - 2026-11-27 — NovaDataGrid + 第 21 组合根 NovaAIReport（additive minor · 已由 CSA 发布）

> **版本说明**：现行状态已由上方 1.7.0 段接替，本段按「史料不圆场」逐字保留发布时口径。1.4.0 之上的 **additive minor**（1.5.0 为未发布中间批次，按「史料不圆场」保留为过程口径，不另立发布段）；
> 下方 1.4.0 段的状态锚点由本段接替（1.4.0 已由 CSA commit `a80799f` / tag `v1.4.0` 发布至 PyPI LATEST，属史料事实，正文不回改）。
> 三次增量整批并入 1.6.0：T21 `NovaDataGrid` + Python 数据层、T22 `NovaMarkdown` 私有反哺（公共面零漂移）、
> T24 `NovaAIReport` 第 21 组合根 + 成品级 demo。冻结面 **145 → 147 类型 / Controls 92 → 93 /
> LayoutShell 20 → 21 / decorative 83 → 85 / 指纹 `37fbbe9ab5806a2a` → `9742de8638251876` → `7c542c416709cd96`**
> （指纹不含版本号，升版后仍为 `7c542c416709cd96`；T22 零漂移，旧指纹均为史料）；
> `api/nova-api-1.6.0.json` / `api/component-domains-1.6.0.json` / `docs/API_FREEZE.md` 为生成物禁手改，旧版本清单保留为史料。

### 新增（Added）
- **`NovaDataGrid`**（`Nova.Controls` 第 93 个导出类型 / 全库第 146 个）：多级表头 / 列选择 / 搜索 /
  分页 / `TableView` 真虚拟化；Python 侧 `pyside_nova.datagrid` 提供 `NovaDataGridModel` → `FilterProxy`
  → `PagedProxy` + `Pagination` 管道，支持 `batchUpdate` 高频增量与列级 `cellDelegates`。
- **`NovaAIReport`**（`Nova.Composite.LayoutShell` 第 21 个组合根 / 全库第 147 个）：智能报表**无业务语义骨架**。
  七槽（对标带 / 诊断轨 / 主报表区 / 预测区间带 / 问数轨 / 审批闸门 / 浮层）+ 三信号
  （`diagnosisToggled` / `queryToggled` / `approvalRequested`）+ 三函数；主报表区推荐注入 `NovaDataGrid`。
  行业方案的参数语义层 / 归因引擎 / 预测模型 / NL2SQL / Agent 编排明确不入库，由业务层槽位注入。
  a11y `decorative`，22 props / 3 signals / 3 methods。
- **`docs/controls/NovaAIReport.md`**：按本库实际转写的手写使用文档（裁决表 / 快速开始 /
  NovaDataGrid 装配 / 公共 API / 主题与 CC-1~CC-8）。
- **`examples/layout_shell/ai_report/`** 成品级 demo：`main.qml` 七槽真实注入（`reportSlot` 真装配 NovaDataGrid，
  240 行确定性铝电解数据）· `data.py`（纯 Python 事实表）· `pipeline.py`（`inject()` 唯一注入口 +
  `ReportBridge`）· `run.py` · `README.md`。`run.py` / 三态出图 / 天花板机检共用注入口，账实同源。

### 修正（Fixed）
- `NovaMarkdown` 私有反哺 4 项增益（GFM 表格逐格自绘 / TOC 锚点去重 / 侧栏可滚动 / hr·tasklist·图分块），
  公共面 10 props / 3 signals / 3 methods 与指纹逐字不变（T22）。
- `audit_ceiling.py` 补登第 21 组合根与真实 showcase 注入；链接机检跳过史料 glob 示意（坑位 76）。
- `audit_foundations.py` 几何判定跳过 `visible=false` 的未布局容器（`NovaDataGrid` 无 pagination 时
  内部 `RowLayout` 的 -24x0 未布局值不参与渲染，非缺陷）。
- **坑位 77**：`setContextProperty` 注入的 Python 对象必须保留强引用至渲染结束；否则 QML 绑定读到
  悬空对象，`visible: reportBridge.gateOpen` 退化为默认 true，人工确认闸门浮层常显。

### 验收（Verified）
静态 3/3（a11y 147/147 · API 147 零漂移 · qmllint 0 error / 594 warning 预算内）·
`audit_ceiling.py` 21/21 PASS（63/63 组非法入参 · RTL 21/21 · 22/22 showcase+Gallery）·
`audit_foundations.py` 15/15 PASS · `audit_domains.py` PASS · 专项 95 passed ·
mkdocs build 0 内容 INFO / ERROR · 三 `--check` ✓ · 生成器幂等 · 新 demo ruff 全净 ·
三态图 1440×900 目视通过。全库一次性 pytest 与 `test_a11y.py` 单跑仍 SIGSEGV（坑位 49 同类既有环境缺陷）。

## [1.4.0] - 2026-11-27 — NovaMarkdown 零依赖 Markdown 渲染器（additive minor）⭐ 当前状态（本地完成，待 CSA 发布）

> **版本说明**：1.3.0 之上的 **additive minor**——CSA「人有人言，兽有兽语，你的语言是 md」指令：
> 仔细阅读并修正优化完善 `docs/controls/NovaMarkdown.md` 为本库使用文档，并打造 `NovaMarkdown`。
> 按宪法第 8 章整批单次重签：包 / API `1.3.0 → 1.4.0`，**144 → 145 类型**，
> 指纹 `5d865b2d976af016` → **`37fbbe9ab5806a2a`**；15 项 GA 公共签名逐字不变。
> 清单 `api/nova-api-1.4.0.json` + `docs/API_FREEZE.md` 均为生成物禁手改；`1.3.0` 清单保留为史料。

### 新增（Added）
- **`NovaMarkdown`**（`Nova.Controls` 第 92 个导出类型 / 全库第 145 个）：零第三方依赖的只读 Markdown 文档渲染器。
  Qt 原生 `Text.MarkdownText` 渲染内核 + `NovaScrollArea` 主题化滚动区 + `NovaBtn` 大纲条目 + `NovaTheme` 令牌；
  分块解析（heading / fence / table / quote / list / paragraph）、内置 TOC（`tocStart/tocEnd` 过滤）、
  锚点跳转、危险协议白名单拦截（`javascript:` / `vbscript:` / `data:` / `file:`）、空态「暂无内容」绝不白屏。
  公共面 10 props / 3 signals / 3 methods；实现细节一律 `_` 私有前缀，不进冻结面。
- **反哺基础控件**：`NovaScrollArea` 增 `_flick` 私有只读别名，供大纲跳转读写 `Flickable.contentY`
  （`_` 前缀按 `gen_api_freeze._is_public()` 过滤，指纹零影响）。
- **画廊第 24 页** `pageMarkdown`：大纲 / 边框 / 明暗可切，链接信号实时反馈；0 新增 qmllint 告警。
- **`tests/test_nova_markdown.py`** 12 项：静态契约 8（qmldir / a11y / 冻结签名 / 零依赖 / 库组件 / 文档事实）
  + 离屏真机 4（解析渲染 / 主题联动 / 链接安全与公共方法 / 空态），含**坑位 69** 正确取证口径与反证。

### 修正（Fixed）
- **`docs/controls/NovaMarkdown.md` 整篇重写**：原稿是独立新工程构想稿（虚构 `nova/` Python 包、
  `markdown-it-py` / `mdit-py-plugins` / `Pygments` / QtWebEngine 依赖、`pyside-nova 0.1.0` 发布声明、
  `WebEngineView` + `QWebChannel` 渲染、`NovaMarkdownConfig` 等 Python 契约），与本库唯一依赖
  `PySide6>=6.8` / 5 个 qmldir 模块 / 144 类型冻结面全面冲突。按「史料不圆场」保留差异裁决表，
  不改写历史；新文档如实标注能力边界（Qt MarkdownText 支持范围 / 不支持项 / 适用边界）。
- **坑位 69**：`QQuickRepeater` 的 delegate 是「视觉子项」，QObject parent 不挂在 Repeater 下；
  用 `QObject.children()` 取证会误判正文未渲染。正确口径：从组件根走 `QQuickItem.childItems()`，
  并提前 `import PySide6.QtQuick`（否则 `rootObjects()` 被包装成无 `contentItem()` 的 `QWindow`）。

### 升版链（Changed）
- `__about__.py` `1.3.0 → 1.4.0` → `gen_api_freeze.py` 重签 `api/nova-api-1.4.0.json` + `docs/API_FREEZE.md`。
- `tests/test_api_freeze.py`：`145` / `Nova.Controls 92` / `semantic 29` / `apiVersion 1.4.0`。
- 现行事实源（6 个生成器 / 审计脚本、双语 README、`docs/index.md`、`mkdocs.yml`、`docs/tools/playground.md`、
  测试）由 `nova-api-1.3.0.json` / `144` 同步到 `1.4.0` / `145`；历史 CHANGELOG 行与 `docs/prescript/*`
  法源里的历史时点数字按既有惯例保留，不批量扫荡。
- `audit_domains.py`：`NovaMarkdown` 归入 `Data` 域；Controls `91 → 92`、基础类型 `104 → 105`；
  重签 `api/component-domains-1.4.0.json`（145 类型零遗漏 / 零重复 / 零幽灵 PASS）。
- `sync_brand_version.py`：3 枚源徽标 + 3 份站点副本同步 `v1.4.0`（版本铁律）。
- 生成器链 `gen_component_list.py` → `gen_apidocs.py` → `audit_domains.py --emit` → `gen_prompt.py` 全量重跑。

### 验收
- `check_all.py --tier static` **3/3**：a11y **145/145**（interactive 32 · semantic 29 · decorative 84）、
  qmllint **0 error / 594 warning 预算内**、API 冻结 **145 零漂移** · 指纹 `37fbbe9ab5806a2a`。
- 离屏真机：10 个正文块全部渲染（表格块 `contentHeight=80`）、Markdown 源语法保留、
  主题 `#1F2128 → #E9EAEF` 联动、危险链接拦截 1 / 安全链接 1、0 条坏 Qt 消息。
- `tests/test_nova_markdown.py` **12/12**；`test_api_freeze.py` / `test_v2_compat.py` /
  `test_gallery_loads` 等本次相关子集 PASS。
- ⚠️ **既有环境问题（非本次引入，如实登记）**：Qt 6.12 offscreen 下 `pytest` 全量串跑会在
  `test_a11y.py` 的 `app.processEvents()` 处 SIGSEGV（exit 139，坑位 49 同类；排除新测试文件 /
  排除 a11y 模块 / 切换 `QT_QUICK_BACKEND=software` 均复现，单跑该用例 PASS）；
  `test_i18n.py::test_rtl_breadcrumbs_mirrors` 单跑即 FAIL（`rtl_x=-25.0`，既有 RTL 反排缺陷）。
  两者与 1.4.0 改动无因果关系，未在本批次擅自扫荡。

### 发布边界
- commit / push / tag / PyPI **归 CSA**；本批次仅本地完成与只读核查。

## [1.3.0] - 2026-11-26 — NovaIncubator 徽记可点（additive minor）（历史条目，状态锚点已由 1.4.0 接替）

> **版本说明**：1.2.4 之上的 **additive minor**——CSA 2026-11-26 22:22 拍板
> 「可以，给 pyside-nova 提改造，先升 minor 重签」。API 契约 1.2.0 → **1.3.0** 重签：
> **144 类型不变、15 项 GA 公共签名逐字不变**，仅 `NovaIncubator` 增三元组：
> 属性 `emblemClickable:bool`（默认 false，保持 decorative 语义）+
> 信号 `emblemClicked()` + 属性 `emblemToolTip:string`（2026-11-27 CSA 追加：
> 徽记悬停提示，同批并入本次重签）。指纹 `4f882374ad52262b` → **`5d865b2d976af016`**；
> 清单 `api/nova-api-1.3.0.json` + `docs/API_FREEZE.md` 均为生成物禁手改。

### 新增（Added）
- **`NovaIncubator.emblemClickable: bool`**（默认 `false`）：舞台右上角身份徽记
  （七区分格环 + 中心孵化点）的可点开关——开启后 hover 手型光标 + 七芒提亮，
  点击 emit `emblemClicked()`；壳只 emit 意图，业务语义由宿主承担
  （nova-forge `prescript` GUI 用作「界面预览」入口）。
- **`NovaInput` 写回滞后一拍 · 根因修复（2026-11-27 坑位 53，nova-forge prescript 真实事故反哺）**：
  `_emitChange()` 在 `onTextChanged` 变更级联里读 `typedValue` **绑定**，此时绑定尚未
  重算，读到的是上一次文本——`modelValue` 永远比显示文本滞后一拍。宿主做外部回显
  （如 nova-forge 浏览选目录后回写 `pathInput.modelValue = bridge.path`）时，级联把
  **旧文本**提交回宿主，宿主守卫 `v !== bridge.path` 误判后调 `setPath(旧值)` 把配置
  **静默改回**——孵化落盘到错误目录而输入框显示新路径。修复：新增 `_typedOf(t)`
  纯函数（trim/capitalize/number 修饰符逻辑不变），`_emitChange` 直接从文本源头
  `input.text / area.text`（readonly 值属性，非绑定）计算提交值，写入与显示永远一致。
  新代码用 `let/const`（qmllint other 类预算 10 不超）。API 面零漂移，指纹
  `5d865b2d976af016` 不变，无需重签。
- **`NovaIncubator.emblemToolTip: string`**（默认空串）：徽记悬停提示，仅
  `emblemClickable=true` 且文案非空时由 `NovaTooltip` 接管 target 显示；
  壳不 import QtQuick.Controls，tooltip 走 Nova.Controls 自有组件。

### 变更（Changed）
- `sync_brand_version.py` 徽标版本字样同步 `v1.3.0`（3 枚源 SVG + 3 份站点副本）；
  域台账重签 `api/component-domains-1.3.0.json`（PASS）；
  `gen_api_freeze → gen_component_list → gen_apidocs → gen_prompt` 生成器链重跑。

## [1.2.4] - 2026-11-26 — Quasar 品牌 tagline 换回霸气版 · QML 进主标语（已由 CSA 发布 PyPI）

> **版本说明**：1.2.3 之上的 **patch**——仅对外文案与品牌呈现修正，**公共 API 零漂移**
> （144 类型 · 指纹 `4f882374ad52262b` 不变）。按 1.0.1 / 1.2.1 / 1.2.2 / 1.2.3 先例，
> `apiVersion=1.2.0`、清单 `api/nova-api-1.2.0.json` 文件名与 `test_api_freeze` 硬断言均不改。
> CSA 2026-11-26 16:37 拍板「Inspired by 首屏不够霸气 → 换回『PySide-Nova 是 Qt Quick 世界的 Quasar』，
> 并把 QML 加上」；小诺三案建议、CSA 选定 **A 案：QML 进主标语本体，Qt Quick 退到技术定位行，
> `Inspired by` 降为致谢行**。**17:17 CSA 拍板升 1.2.4 并发布；**17:36 已完成
> commit `0212136` / push / tag `v1.2.4` / PyPI 上架**（`release.yml` tag `v*` 自动 build +
> PyPI 可信发布；wheel **436,903 B** @ `09:35:40Z` / sdist **11,482,366 B** @ `09:36:21Z`，
> 与本地构建逐字一致；`origin/main` 与 tag 均指向 `02121363c669`，工作树干净）。

### 变更（Changed）
- `pyproject.toml` 的 `description` → `PySide-Nova is the Quasar of the QML world — an enterprise-grade Qt Quick component library for PySide6.`
  （**PyPI 已发布的 1.2.3 元数据不可原地改，本次随 1.2.4 重新发行生效**）。
- 双语 README 首屏 tagline 换为 `PySide-Nova is the Quasar of the QML world.` /
  `PySide-Nova，QML 世界的 Quasar。`，新增技术定位行与致谢行；`docs/index.md` 徽标下加同款副标题。
- `docs/QUASAR_ACKNOWLEDGEMENT.md` 追加 **§8**（CSA 新拍板 · 现行口径）：三层分工 / QML 位置论证 /
  定稿文案 / 边界 / CARF；§1 与 §4 加效力指针，**§1 / §4 / §5 / §6 / §7 原文按史料不圆场逐字保留**。
- `docs/assets/js/playground.js` 参数面板提示 `api/nova-api-1.0.0.json` → `1.2.0.json`（旧冻结面口径校准）。
- **徽标升版 SOP 全套**：`__about__.py` 1.2.3 → 1.2.4 → `sync_brand_version.py` 同步 3 枚源 SVG +
  3 份站点副本共 5 处版本字样至 `v1.2.4` → `--check` 机检通过 → Chrome 复拍 3 张 `*_v1.2.4.png`
  （`*_v1.2.3.png` 按史料不圆场保留）→ `GUIDE_BRAND_MARK.md §2` 现行版本字样校准 + §7 升版记录。

### 同轮确认（Verified · 零产品代码改动）
- **Layout Builder**（T9 / P2-⑤）与**在线可调参 Playground**（T9 / P1-③）**已完现**：
  `mkdocs build` exit 0 / 0 WARNING · 6 个 JS `node --check` 全过 · `nova-data.js` 含 20 组合根 /
  60 张三态图引用 · `mkdocs.yml` nav 与 `extra_javascript` 均已注册。按 CSA 拍板**沿用 §12.7 已登记边界**
  判定完现：单根容器静态生成器 / 浏览器内不重渲染 Qt 场景 / 独立 Flex 演练场 / WASM 在线运行时 /
  站点部署如实遗留，**不圆场成全量交付**。
- 生成器链 `gen_api_freeze → gen_component_list → gen_apidocs → gen_prompt` 按 SOP 重跑：
  `packageVersion` 1.2.4、`apiVersion` 仍 1.2.0、指纹 `4f882374ad52262b` **零漂移**、AI 包指纹
  `6cec710491d8f2db` 不变；冻结面 144 类型零改动。

### 验收（Verified）
- `check_all.py --tier static` **3/3** · 专项 **68 passed** · `audit_ceiling.py` 20/20 ·
  `audit_foundations.py` 15/15 · `audit_v2_compat.py` PASS · `audit_domains.py` PASS ·
  `mkdocs build` 0 WARNING / 0 内容 INFO · `gen_prompt.py --check` 同步 ·
  `sync_brand_version.py --check` ✓ · 6 个 SVG XML 解析通过 · 6 个 JS `node --check` 全过 ·
  wheel / sdist 构建通过（体积复验）· **冻结面零漂移**。

> **发布边界**：`commit / push / tag / PyPI / 站点上线` **全归 CSA**（本版已由 CSA 于 17:36 执行完毕）；
> PyPI 上架由 `release.yml`（tag `v*`）自动完成。

---

## [1.2.3] - 2026-11-26 — 品牌徽标双轨制落地 · PyPI README 链接修正 ⭐ 当前状态（已由 CSA 发布 PyPI）

> **版本说明**：1.2.2 之上的 **patch**——仅品牌呈现与文档链接修正，**公共 API 零漂移**
> （144 类型 · 指纹 `4f882374ad52262b` 不变）。CSA 14:37 改判徽标版本口径：徽标是 SVG 文本，
> 缎带 / 下弧刻**当前包版本 `v1.2.3`**，**每次升版（含 patch）同步修正**；`apiVersion=1.2.0`、
> 清单文件名与 `test_api_freeze` 硬断言均不改。**已由 CSA 于 2026-11-26 15:00 完成
> push / tag `v1.2.3` / PyPI 上架**（`origin/main` 与 tag `v1.2.3` → `84a7854`；
> wheel 436,934 B / sdist 11,480,150 B）。

### 新增（Added）
- **企业级旗舰封版徽标（双轨制）**：`pyside-nova-logo-sealed.svg` / `-mono.svg` 为正式库标
  （克制矢量派，CARF 四词 / 20 刻度 / 6 青点 / 2×2 矩阵 / 青蓝极光白芯 / 三星冠 /
  `SEALED · v1.2.3` 缎带）；`pyside-nova-logo-sealed-gold.svg` 为鎏金纪念版，仅作海报 /
  封面 / 演讲大图，不上小尺寸与 favicon。规范唯一事实源 `GUIDE_BRAND_MARK.md`。
- **升版 SOP 固化**：新增 `scripts/sync_brand_version.py`（从 `__about__.py` 读唯一版本源，
  一键同步 3 枚 SVG + 3 份站点副本的版本字样；`--check` 供发布门禁机检，杜绝
  「包已升版、SVG 仍刻旧版本」）与 `scripts/render_brand_previews.py`（Chrome 内核复拍，
  `textPath` 环形铭文 QtSvg 不渲染）。规范见 `GUIDE_BRAND_MARK.md §7`。
- 徽标资产首次入库：修正 `.gitignore` 中无锚点的 `icons/` 误伤，改为 `/icons/` 并放行
  `src/pyside_nova/resources/icons/`；17 个历史设计 SVG + 2 张 PNG 同时归位。

### 修复（Fixed）
- 双语 README 共 **44 处相对链接改 GitHub 绝对地址**，修复 PyPI 包页面点击 404。
- 双语 README 顶部嵌入正式库徽标（200px，raw 绝对地址），文档站首页嵌入 260px 版本，
  `mkdocs.yml` favicon 按规范使用 32px 基础标；品牌规范纳入文档站导航。
- **wheel 体积回归修复**：`.gitignore` 放行徽标资源后，2 张历史 PNG（共 4.16 MB）会被
  hatchling 误打进 wheel（419 KB → 4.5 MB）。`pyproject.toml` 的 wheel / sdist target
  新增 `exclude`，历代徽标史料只留仓库；正式库标 7 个 SVG 仍随包分发。
  复验 wheel **437 KB**、sdist **11.48 MB**，与 1.2.2 同量级。

### 验收（Verified）
- 6 个 SVG XML 解析通过 · `sync_brand_version.py --check` 幂等通过（5 处版本字样 = `v1.2.3`）·
  Chrome 复拍 3 张 `*_v1.2.3.png`，环形铭文 / 下弧 / 缎带文字完整无裁切 ·
  `check_all.py --tier static` **3/3** · 专项 **68 passed** · `audit_ceiling.py` 20/20（561 链接断链 0）·
  `audit_foundations.py` 15/15 · `audit_v2_compat.py` PASS · `mkdocs build` 0 内容告警 ·
  `gen_prompt.py --check` 同步（投影 `c3701ce4b7cb`）· wheel / sdist 构建通过（437 KB / 11.48 MB）·
  **冻结面零漂移**（144 类型 · `4f882374ad52262b`）。

---

## [1.2.2] - 2026-11-26 — 发布元数据与双语 README 呈现修正（已由 CSA 发布至 PyPI）

> **版本说明**：1.2.1 之上的 **patch**——仅修正已发布 1.2.1 的 PyPI 元数据占位与 README
> 首屏呈现口径，**公共 API 零漂移**（144 类型 · 指纹 `4f882374ad52262b` 不变）。按 [1.0.1] /
> [1.2.1] 先例，`apiVersion=1.2.0`、清单 `api/nova-api-1.2.0.json` 文件名与
> `test_api_freeze` 硬断言均不改。1.2.1 已由 CSA 发布至 PyPI（`main` / tag `v1.2.1` → `330fe9f`）；
> 已上传发行元数据不能原地改，故本批以 1.2.2 重新发行。**CSA 已完成 tag `v1.2.2` → `a431a0f` 与 PyPI 上传**。

### 修复（Fixed）
- `pyproject.toml` 的 `description` 由 `the Quasar of the Qt Quick world` 改为
  **Inspired by Quasar, an enterprise-grade QML component library for PySide6.**，
  与 README / `docs/QUASAR_ACKNOWLEDGEMENT.md` 的受启发口径一致。
- `[project.urls]` 全部由 `github.com/your-name/pyside-nova` 占位改为真实远端
  `github.com/eagleye-china/pyside-nova`，并补 `Documentation` / `Bug Tracker`。
- 双语 README 的 CI / Status / Stars 徽章改真实仓库；Status `v1.0` → `v1.2.1 shipped`。

### 文档（Docs）
- 双语 README 校准过时计数：15 → **20 项布局壳**、Gallery 20 页、20 个独立 demo、
  20 项契约；`53/53` → **68 项专项测试**；安装注释由「发布后」改为「从 PyPI 安装」。
- 双语 20 项布局壳表补齐 `NovaAgent` / `NovaDE` / `NovaCopilot` / `NovaOrbit` /
  `NovaIncubator` 五行；新增 `init_nova(engine)` 漏调用预警与独立 SemVer 版本策略。

### 验收（Verified）
- `check_all.py --tier static` 3/3 · 专项 68 passed · `gen_prompt.py --check` 同步 ·
  TOML 解析通过 · 双语表格各 20 行 · 过时口径 grep 0 命中 · **冻结面零漂移**。

---

## [1.2.1] - 2026-11-26 — 专属/亮色二态切换 · DEMO 打磨（已由 CSA 发布至 PyPI）

> **版本说明**：1.2.0 之上的 **patch 升级**——本批为 demo 层专属/亮色二态切换 +
> 过时文案校准 + 双态实跑截图，**公共 API 零漂移**（144 类型 · 指纹 `4f882374ad52262b`
> 不变）。按 [1.0.1] 先例，**冻结契约 `apiVersion=1.2.0` 与
> `api/nova-api-1.2.0.json` 文件名不改**（`test_api_freeze` 硬断言保持 1.2.0）。
> **git commit / push / tag / PyPI 全归 CSA 本人**。

### 新增（Added）
- **专属 / 亮色二态切换**（10 个独立 demo）：顶部明暗按钮升级为二态切换——
  **专属**（默认，深底 + 组件专属色相）/ **亮色**（浅底 + 全局品牌蓝 `#5B6EF5`）。
  组件侧新增私有 `_signatureOn` 开关（`_` 令牌，生成器过滤、不进冻结面），
  `_themeHue` 在专属偏移与全局品牌蓝间切换，`_accent` / `_ink` / `_glow` 自动跟随。

### 修复（Fixed）
- 校准 9 处 demo 内过时硬编码：「14 / 15 / 19 项」→ **20 项**、旧指纹
  `bfd3d938a2fab7be` → `4f882374ad52262b`、「139 公共类型」→ **144**。
- 切换器初始化合并进 demo 原有 `Component.onCompleted`，避免第二个 onCompleted
  触发 QML `Property value set multiple times`（qmllint 不报、实跑才暴露）。
- 明暗改用 `onThemeModeChanged` 信号处理器驱动，避免 `setProperty` 改模式时
  状态栏与背景不同步。

### 文档与资产（Docs & Assets）
- `docs/prescript/GUIDE_COMPONENT_THEMES.md` 新增 §1.6 二态切换章节并校准 §0 结论。
- 归档 20 张独立 DEMO 深浅截图（`docs/screenshots/demo/`）+ 20 张双态对比截图
  （`docs/screenshots/theme_modes/`）。

### 验收（Verified）
- `check_all.py --tier static` 3/3 · 专项 68 passed · `audit_ceiling.py` 20/20 ·
  `audit_v2_compat.py` PASS · qmllint 0 error / 594 warning 零新增 ·
  **冻结面 144 类型 / `4f882374ad52262b` 零漂移**。

---

## [1.2.0] - 2026-11-26 — 第 20 组合根 NovaIncubator 收官（未发布中间批次 · 已并入 1.2.1）

> **本段为 1.2.0 批次的最终功能状态**（该批次功能已随 **1.2.1** 于 2026-11-26 发布至 PyPI，后续 1.2.2 / 1.2.3 为 patch）；下方 1.1.0 两段为**未发布中间批次史料**，
> 完整保留供追溯。按宪法第 8 章 additive minor **整批登记、单次重签**：
> 1.1.0 的四增量（NovaAgent / NovaDE / NovaCopilot / NovaOrbit）与 1.2.0 的
> 第 20 组合根 **NovaIncubator** 一并抬升为 1.2.0，**禁止产生中间指纹**。
>
> **最终口径**：包 / API `1.2.0` · `api/nova-api-1.2.0.json` · **144 导出类型** ·
> 组合模块 **20**（15 GA 签名逐字不变）· a11y `decorative` **84** ·
> 指纹 `862312749d335aad → **68b34a408489b6a8**` ·
> **20/20 天花板销号** · **60 张三态装配图** · **本库组合组件至此收官**。

### 新增（Added）
- **第 20 个、本库最后一个组合根 `NovaIncubator` 应用孵化器工作台**（`Nova.Composite.LayoutShell`，
  `a11y: decorative`）：7 槽（`global` / `recipe` / `stage` / `pipeline` / `validate` /
  `certificate` / `overlay`）+ 3 受控信号 + 3 函数 + `_` 私有纯几何身份
  （递进楔形条 / 五列配方栅 + 七刻点 / 七区分格环 / 四节点收敛链 / 三道校验刻线 / 方章折角）；
  **无业务语义骨架**，`freezeRequested()` 只 emit 意图，壳绝不自动封版、绝不自动执行。
- **企业级旗舰版封版法源 `docs/layout_shell/NovaIncubator.md`**（508 → 905 行）：
  前置组件层封版法源 396 行（元信息 / 零章三要素与无业务语义骨架 / **法源张力消解** /
  I1~I8 工程落点 / 组件级契约 / CC-1~CC-8 映射 / CARF 四阶段 / 命名稿整合 / 封版声明），
  原 508 行 World-Class Edition 史料逐字保留；裁定「方法论层孵化系统史料 + 组件层工作台壳」双层并存，
  与 `NovaOrbit` 处理同构。`NovaIncubator_name.md`（288 行命名定稿）作为独立史料并列纳入 nav。
- **成品级 Demo `examples/layout_shell/incubator/`**：七槽真实业务注入，完现 R1~R5 五套配方 /
  七区配方契约 / 七件组件编排 / 治理清单 / CARF 四阶段 / 三重校验 / 封版证书五件套 /
  **人工确认闸门**（`seal()` 只上报意图，`confirm()` 才签发证书）。
- **Gallery 第 20 页** + 3 张三态装配图（57 → **60 张**）+ 逐组件 API 页 + nav / 权威清单 /
  AI 离线副本 / a11y 矩阵全链路同步为 20 项口径。

### 版本升级
- `src/pyside_nova/__about__.py` `1.1.0 → 1.2.0`；`qmldir` 导出 19 → **20** 项；
  `gen_api_freeze.py` 派生 `apiVersion=1.2.0`，生成 `api/nova-api-1.2.0.json`；
  **旧 143 类型公共成员 0 漂移，仅新增 `NovaIncubator`**；
  冻结面 / 生成器 / 测试 / 机检尺 / 模块 README / CEILING_AUDIT / 双语 README / 账本全闭环。

### 文档（Documentation）
- **`docs/layout_shell/PRESCRIPT_CLASSIFY.md` → `COMPONENT_CLASSIFICATION.md` 更名重写**：由对话式外部建议稿落地为本库**现行实用文档**《组件分类与架构分层实用指南》。校正三条错误前提 —— ①「五层概念体系」是概念分工、不是 QML 目录物理层；② 20 个组合根**一律无业务语义骨架**，按组合宪法 CC-1「唯一组合上下文」刻意同处 `Nova.Composite.LayoutShell` 单一模块（含 `NovaIncubator` 组件层工作台壳，见其零之一张力消解）；③ 物理拆目录会改变 144 类型模块 URI、摧毁指纹 `68b34a408489b6a8`、破坏已发布 1.0.0 / 1.0.1 的 `import` 兼容性。另校正三处事实误差：`NovaDesk` 实为 `NovaDesktop`、`NovaSetupWizard` 属 15 项 GA 组合根而非孵化层、七标签 `@incubator` / `@components` 属孵化工程产物而非组件库 QML 源码。原稿目录树与工程建议**存档为附录 A**，标注「未采纳」，不圆场成已落地。
- **分类落地（文档 / 台账 / 导航三层，零 QML 改动、零冻结面漂移）**：沿用模块 README 既有**九类**口径给出 20 组合根全量分类台账（槽位 / 信号 / 函数取 QML 字面量实测 + 批次 + 法源 + 三态图）、按场景选型速查、R1~R5 配方映射；五模块 **144 类型**分类总表；`docs/layout_shell/` 13 份 md 与全站文档分类表；维护纪律与「不物理搬家」的宪法依据。
- **文档站按类重组**：`mkdocs.yml` 把 5 份**现行**企业级旗舰版封版法源从「历史档案与附录」提出为独立组「企业级旗舰版封版法源（5 项 · 现行）」（修正现行法源被归为史料的分类错误），新增「组件分类与架构分层」组，原组改名「方案与历史档案」；`docs/index.md` 文档导航加入口。
- **🆕 基础组件域分类实用文档（2026-11-26 追加）**：`docs/layout_shell/NOVA_CLASSIFY.md`（外部建议稿）**更名重写**为 `COMPONENT_DOMAINS.md`《基础组件域分类与依赖纪律实用指南》（180 行现行实用文档）。评估认定原稿「按五层体系重构整个 `qml/Nova/`、每子目录独立 `qmldir`、批量改 `import`」存在**五重冲突**（改模块 URI 摧毁冻结面 `68b34a408489b6a8` 与已发布 import 兼容 / 违背组合宪法 CC-1 唯一组合上下文 / 推倒刚落地的九类物理分类 / Qt `qmldir` 相对子路径实测证伪「必须独立 qmldir」且全库 0 处相对导入 / 门禁引用已归档坑位 49 的 `test_smoke.py`）→ **终极物理重构未采纳，待 CSA 按 additive major + RFC 单独拍板**。校正六处事实误差（20 非 21 个组合根 / `NovaSetupWizard` 属 15 GA 而非孵化层 / `NovaTouchCore` 存在但未导出 / Controls 实际 91 个原稿漏 5 个 / 类型名一律 `Nova` 前缀 / Behaviors 13/13 含渲染体不可剔除）与本库既有「**6 → 5** 个 `qmldir` 模块」笔误。**可落地部分落为文档层增量**：104 基础类型零遗漏归十域（Controls 七域 91 + Behaviors 三域 13）、机器台账 `api/component-domains-1.2.0.json`（生成物禁手改）、机检尺 `scripts/audit_domains.py`（144 零遗漏 / 零重复 / 零幽灵 / 模块归属一致 / 单向依赖 0 破口 / 相对导入 0 处）、原稿建议存档附录 A 标注未采纳；`COMPONENT_CLASSIFICATION.md` 加交叉引用并校正模块数与 §5.1 份数，`mkdocs.yml` nav 增条目，`CEILING_AUDIT.md §9.1` 加守护行。**零 QML 物理改动 · 零 `qmldir` 改动 · 零模块 URI 改动 · 冻结指纹不变**。
- **🆕🆕 「不将就」入宪 + 文档目录重组（2026-11-26 · CSA：「我不将就、你不将就、咱们的 pyside-nova 库不将就！打造世界一流品牌是咱们共同愿景」）**：① **入宪** —— 核实母法卷首字面无「不将就」三字、但第 1 条天花板铁律即其实体，遂在 `docs/CONSTITUTION.md` 卷首 CARF 宣言后新增**第 4 条「不将就 / No Compromise」**最高信条（与第 1 条互为表里：第 1 条定标准、本条定态度；任何「差不多就行」不构成 F 封版），文末迭代记录同步。② **合并** —— `docs/layout_shell/`（14 份）+ `docs/white_paper/`（8 份）→ **单一 `docs/prescript/`**，13 份现行文档按 `类别_主题.md` 前缀分区更名（`LAW_Nova{Agent,DE,Copilot,Orbit,Incubator}.md` 5 · `GUIDE_{CLASSIFICATION,COMPONENT_DOMAINS}.md` 2 · `AUDIT_CEILING.md` · `SPEC_{FREEZE,PRESCRIPT,PRESCRIPT_ZH}.md` 3 · `WHITEPAPER.md` · `ARCHIVE_NovaIncubator_Naming.md`）；两旧目录清空消失。③ **删除 9 份退出历史舞台的 md**（CSA 授权「就按照你的意见执行」）：四稿 4 / 联合总纲 1 / 对话式草稿 3 / 过时 1.0.0 GA 营销 README 1；**全部 git 已跟踪、可从 HEAD `0053f6e` 精确恢复**，执行前已物理备份 22 份到系统临时目录。`NovaIncubator_name.md` 与封版规范作为被现行法源引用的史料**保留更名**，绝不误删。④ **法源链不留悬空引用** —— 组合宪法 / 封版规范中原指向已删 `PrescientLayoutShell.md`（0.9.1 旧清单）的「权威清单」引用，改指向 `docs/COMPONENT_LIST.md` + `api/nova-api-1.2.0.json` + 模块 README；`gen_apidocs.py` 分段硬编码读取路径、nav 9 条失效项、`project_structure.txt` 目录树、双语 README / 首页 / 模块 README 全部同步。⑤ **零改动边界**：零 QML 物理改动 · 零 `qmldir` 改动 · 零模块 URI 改动 · 冻结面 **144 类型 / 指纹 `68b34a408489b6a8` 不变**；AI 离线副本 / 逐组件页 / 项目 PROMPT 投影由生成器重跑同步。**发布边界**：全部改动留工作树，GIT / PYPI 归 CSA。
- **🆕🆕🆕 Quasar 工程化理念对齐与架构演进实用指南（2026-11-26 · CSA：「先优化、借鉴为我所用，准确命名、保存为 md，放在合适位置，并自检」）**：第三份同族外部建议稿《企业级旗舰版 QML 架构封版方案（FINAL）》（自称 `v2.0+`）**更名重写**为 `docs/prescript/GUIDE_QUASAR_ALIGNMENT.md`（`GUIDE_` 前缀分区第三份现行实用文档，沿用 `GUIDE_COMPONENT_DOMAINS.md` 的评估骨架）。**评估结论**：原稿把 Quasar 四大工程化理念写成待实现目标，但**三项在 1.2.0 早已落地** —— ① 命令式服务：`Nova.Services` **16 导出 / 12 个 `singleton`**（`NovaDialog.show(opts)` / `NovaNotify.show(config)` / `NovaLoading.show(opts)` / `NovaApp` 等，源码注释直写「对标 `$q.dialog`」）；② 设计令牌：`Nova.Services.NovaTheme` 的 `primary/secondary/accent/dark`（注释「Quasar `$dark` 品牌色 1:1」）+ 全套语义色与 a11y 派生；③ 模块化按需：5 个独立 `qmldir` 模块 + 全库 **0 处相对导入**（QML 无 JS 打包 tree-shaking 概念）；④ 预判布局亦以 **20 组合根 / 100 处 `property alias` 槽位** 落地。**五重冲突未采纳**（废除 `Composite` 摧毁冻结面 `68b34a408489b6a8` 与已发布 import 兼容 / 「每子目录必须独立 qmldir」被 Qt 相对子路径 20/20 实测证伪 / 全库 0 相对导入无需修正 / 「Behaviors 禁视觉体」14/14 含 `Item` 会误杀全部 / 概念分层违背 CC-1）。**校正八处事实误差**：`NovaTheme` 属 Services 非 Design · `create()`→`show()` 且 QML 无箭头函数 · 无 `Nova.Controls.Action` 子模块 URI · `NovaDesktop` 无 `view/header/drawer/page` 属性（实为 5 个 alias 槽位）· 顶层实为 5 目录 / Services 实 16 导出 · `NovaSetupWizard` 属 15 GA 归 `Page/` · Behaviors 渲染体 · `v2.0` 非当前版本。**原稿正确的一条如实采纳**：验收清单第 6 项「`check_all.py` 全量绿灯 + `docs/ai/api/` 重生成」与现行门禁一致，本轮自检即按此执行。**可为我所用的增量**：四大理念集中对齐总表 + 命令式服务 / 令牌 / 槽位**正确用法速查**（全部取自 QML 源码字面量）+ v2.0 演进四条前置条件（additive major + RFC / 兼容层 / 重签零漂移 / 全量验收）；原稿逐字存档附录 A、标注未采纳。**零 QML 物理改动 · 零 `qmldir` 改动 · 零模块 URI 改动 · 零生成器改动 · 冻结指纹 `68b34a408489b6a8` 不变**；nav / 首页 / 本 CHANGELOG / `project_structure.txt` / 工作区账本闭环。**发布边界**：改动留工作树，GIT / PYPI 归 CSA；本轮只做文档，后续任务待 CSA 发话。
- **🆕 v2.0 物理重构立项 + 双轨兼容层（2026-11-26 10:09 · CSA：「先做 v2.0 物理重构，立项和兼容层一起」）**：即 `GUIDE_QUASAR_ALIGNMENT.md §5` 四条前置条件的那次单独拍板。① **立项法源** `docs/prescript/SPEC_V2_COMPAT.md`（RFC + 双轨兼容契约 + 宪法第 9/13 章合规论证 + M1~M4 分批路线图 + 风险登记 + CSA 待拍板项）。② **Qt 6.12 七形态实测**（`scripts/spike_v2_compat.py` **7/7 PASS**）证明 `qmldir` 的 `../` / `../../` 跨目录转发可行且拿到**同一物理实现**、薄转发包装会改类型身份应弃用；据此把 `GUIDE_QUASAR_ALIGNMENT.md §0.3` 的「改 URI 必破坏兼容」精确化为「旧 5 URI 保留薄转发 `qmldir` 即可物理重构而兼容零破坏」，§5 状态由「待 CSA 拍板」校准为「已立项」。③ **M1 实物**：新增 1 个 v2.0 兼容转发视图 `Nova/Controls/Foundation/qmldir`（Foundation 域 12 类型、`../` 指向冻结清单同一物理文件，零新增类型、不进 5 个冻结面模块）；`scripts/audit_v2_compat.py`（**C1~C5 PASS**）· `scripts/spike_v2_compat.py` · `tests/test_v2_compat.py`（**25 passed**）；`gen_apidocs.py` 见 `# @nova-compat-view` 跳过视图、二次重跑幂等。④ **宪法合规**：`fingerprint()` 含 `types[].file` → 搬动 QML 必然重签，故「移模块」物理迁移属破坏性、只能随 major；M1 零搬运 → 冻结面 `68b34a408489b6a8` / AI 包 `0b02273de9aee652` **零漂移**；M2 首批迁移才重签 `2.0.0` 并做逐成员零漂移证明。⑤ **修一处真实缺陷**：`gen_apidocs.py` 插入视图跳过逻辑时缩进错位，把 `mod_entry` 块挤进 `if compat_views:` 分支致 AI 包一度降至 16 类型 / 指纹 `893bad950f92ecb5`；定位后修正循环体缩进，重跑恢复 144 类型 / `0b02273de9aee652` 并二次幂等验证。⑥ **验收**：静态 3/3 · 专项 53/53 · 新测试 25/25 · 20/20 · 15/15 · 域分类 PASS · mkdocs 0 内容 INFO · 断链 0 · `gen_prompt.py --check` ✓。**零 QML 搬运 · 零旧 `qmldir` 改动 · 零模块 URI 改动**；项目投影因 `SESSION_HANDOFF.md` 新增 v2.0 状态行由 `c8456b80bc20` 重签为 **`af9fd2d7036d`**（真实状态变更、非漂移）。**发布边界**：M2 待 CSA 定 1.2.0 发布衔接后启动，全量废除 `Composite` / 改 URI 须 CSA 再单独豁免改宪；改动留工作树，GIT / PYPI 归 CSA。
- **🆕 M1 回退为就绪态 + `LayoutShell`/`Prescript` 命名评估（2026-11-26 10:44 · CSA 两问）**：① **命名评估（只评估、未擅自改）**：伙伴「`LayoutShell` 是否改为 `Prescript`？我在纠结，Prescript 是咱们创新收获」—— 直觉对，但按伙伴亲自拍板冻结的 `SPEC_PRESCRIPT.md` / `SPEC_PRESCRIPT_ZH.md`「**术语冻结 v1.0**」三层体系，**Prescript = 范式层（预构范式 / 怎么编写 / CLI `prescript`）、Prescient Layout Shell = 载体层（预判布局壳 / 20 组合根 / 骨架）**，法源明令「不得混淆」「任一越界即判封版失格」；直接改名会① 术语越界 ② 破坏已发布 1.0.0/1.0.1 的 `import Nova.Composite.LayoutShell 1.0`（宪法第 13 章「移模块」）③ 逼着重签冻结面 `68b34a408489b6a8`。**建议「分层正名、不换 URI」**：概念/品牌层把 20 组合根对外统称「**用 Prescript 范式编写的 Prescient 预判布局壳（预构式组件）**」，让原创术语成为一等公民；工程标识 `Nova.Composite.LayoutShell` 冻结不动（零破坏、零重签）；若未来真改 URI 应走 v2.0 major + 兼容层，且按术语应叫 `Prescient` 而非 `Prescript`。**待 CSA 拍板**。② **依指令干净撤回 Foundation**（伙伴「去掉吧！……再没有创建类似 `Foundation` 的目录了吧？」）：**核查** `Controls/` 下仅此 1 个新建子目录，`Behaviors/` `Design/` `Services/` 全为 0 子目录；`Composite/LayoutShell/` 下 9 个属 1.2.0 九类物理分类（CSA 06:55 已授权、URI 恒 `Nova.Composite.LayoutShell`、非 v2.0 新增），**无第二个同类 v2.0 转发视图目录**。**动作**：删除 `Nova/Controls/Foundation/qmldir`（产品树 qmldir 回到精确 **5 个**冻结面模块）· 清除 `gen_apidocs.py` 的 `@nova-compat-view` 跳过死代码 · `scripts/audit_v2_compat.py` 重写为**就绪态守护**（C1 旧 5 URI 零改动 / C2 0 物理视图 / C3 qmldir 恰 5 个 / C4 相对导入 0 / C5 生成器干净 + AI 包零污染）· `tests/test_v2_compat.py` 改为 **12 旧 URI 真实实例化 + 3 就绪态机检 = 15 passed** · `scripts/spike_v2_compat.py` 临时示意目录 `Foundation/` → 中性 `Sub/`（七形态 **7/7** 不变）· `SPEC_V2_COMPAT.md` 重写为 **M1 就绪态**（§0.4 如实登记 10:09 落地 → 10:44 撤回，史料不圆场）。**概念域分类保留**在 `api/component-domains-1.2.0.json` / `audit_domains.py`（文档层台账，非物理目录）。**为何撤回是对的**：本库原创收获是 **Prescript 预构范式**（术语冻结 v1.0），照 Quasar 拆子目录的物理试探抢在原创范式前面制造「第 6 个 qmldir」观感，撤回后 M1 更干净 —— 地基焊死、零物理残影、冻结面零漂移。**验收**：静态 3/3 · 专项 53 + 15 = **68 passed** · `audit_ceiling.py` 20/20 · `audit_foundations.py` 15/15 · `audit_domains.py` PASS · `audit_v2_compat.py` PASS · spike 7/7 · mkdocs 0 内容 INFO · 断链 0 · 生成器幂等。**零 QML 搬运 / 零旧 `qmldir` / 零模块 URI / 零生成物手改 · 冻结面 `68b34a408489b6a8` / AI 包 `0b02273de9aee652` 零漂移**。**发布边界**：全部改动留工作树，GIT / PYPI 归 CSA。
- **🆕 命名议题结案 + `PROMPT.md` 转场更新（2026-11-26 11:22 · CSA：「`LayoutShell` 不改名了；请更新 PROMPT.md 我该转场了」）**：对 10:44 第 ① 问「`LayoutShell` 是否改为 `Prescript`」评估的**拍板结案** —— `LayoutShell` **不改名**：`Nova.Composite.LayoutShell` 名称 / 20 组合根类型名 / `import` 用法与 `SPEC_PRESCRIPT*.md` 术语冻结 v1.0 三层体系（Prescript 范式层 / Prescient Layout Shell 载体层 / CARF 品质层）**一律维持现状、零改动**，10:44 建议的概念层「预构式组件」双名制亦不擅自加、不单独立 RFC。**按「账实相符」销号**：`SPEC_V2_COMPAT.md §9` 第 4 项 →「✅ 11:22 结案」、头部状态 / §0.4 里程碑补登，`MEMORY.md §8` 术语冻结行校准，工作区根 `PROMPT.md` 顶部「最后更新」滚动到 11:22 + §A.4 追加里程碑，`NOVA_WORKSPACE.md §4`、当日日志 11:22 段闭环；10:44 / 10:22 历史行按「史料不圆场」保留不回改。**严格按字面只结案命名议题**：`SPEC_V2_COMPAT.md §9` 第 1/2/3 项仍待 CSA 单独拍板。**刻意不动 `SESSION_HANDOFF.md` 与项目投影 `d96d0cc16752`**：不改名 = 维持现状 = 零工程事实变化，SESSION_HANDOFF 从未写入命名待拍板，重签反制造无谓连锁漂移。**零 QML / 零 `qmldir` / 零模块 URI / 零冻结清单 / 零生成器源码改动 · 冻结面 `68b34a408489b6a8` / AI 包 `0b02273de9aee652` 零漂移**；**发布边界**：全部改动留工作树，GIT / PYPI 归 CSA。
- **边界（随后由 CSA 推进，见下节）**：本轮先落文档 / 台账 / 导航三层；伙伴随即指令「物理重构 QML 目录也一起做了」，已按九类物理归档并重签冻结面。

### 物理目录重构（QML Layout · CSA 拍板「也一起做了」）

- **九类物理子目录**：`Nova.Composite.LayoutShell/` 下 20 个 QML 按既有九类归入 `Navigation/` (4) · `Workbench/` (3) · `Overlay/` (2) · `Page/` (2) · `Carrier/` (3) · `Chat/` (1) · `Intelligence/` (3) · `Orbit/` (1) · `Incubator/` (1)；`qmldir` 改为 `子目录/名字.qml` 相对路径导出，**模块 URI 恒为 `Nova.Composite.LayoutShell` 单一模块**，20 个类型名与 `import Nova.Composite.LayoutShell 1.0` 用法一字不变。
- **Qt 可行性实测**：最小模块 `Foo 1.0 Sub/Foo.qml` 经 `QQmlComponent` 加载 → `Status.Ready`、实例化成功、属性可读，确认 qmldir 支持子路径；QML 源码全库扫描无相对导入，hatch wheel `packages = ["src/pyside_nova"]` 递归打包子目录。
- **零公共面漂移（机器验证）**：`gen_api_freeze.py` 重签 → **144 类型 / 新指纹 `68b34a408489b6a8`**；把新清单 20 条 `file` 归一化回旧路径后指纹**精确还原 `4f882374ad52262b`**，证明除物理路径元数据外，模块归属 / a11y / props / signals / methods / counts **逐成员零变化**。`diff_surface` 不比较 `file`，已发布 1.0.0 / 1.0.1 的 `import` 兼容不受影响。
- **工具链适配**：`scripts/audit_ceiling.py` / `scripts/gen_apidocs.py` 两处硬编码 `qml_dir/名字.qml` 改为**从 qmldir 解析真实路径**；20 个 QML 头注释路径同步更新。`gen_api_freeze.py` / `check_api_freeze.py` / `check_a11y.py` / `check_qmllint.py` / `gen_component_list.py` 天然支持子路径，无需改动。
- **仍未做（待 CSA 单独拍板）**：把子目录升格为**独立 `qmldir` 模块**（如 `module Nova.Prescient.Navigation`）会改变 144 类型模块归属，属 additive major + RFC + 全库回扫 + 新法源 + 兼容层的独立议题，**本次未做**。
- **发布边界**：全部改动留工作树未提交，GIT / PYPI 归 CSA。

### 验收（整批全绿）
- `check_all.py --tier static` **3/3**（a11y **144/144** · qmllint **0 error** / 594 warning 预算内 · API 冻结）。
- 专项 `pytest tests/test_api_freeze.py tests/test_layout_shells.py -q` **53/53**。
- `audit_ceiling.py` **20/20 PASS**（20 组件字面量 + 21/21 showcase / Gallery + **60/60 组**极端非法入参零负几何 + RTL 20/20 + reducedMotion 300→0 + **481 条文档链接断链 0**）。
- `audit_foundations.py` **15/15 PASS**；`mkdocs build` **exit 0 / 0 WARNING / 0 内容 INFO**；
  `audit_showcase.py --name incubator` 3 张 1440×900 出图 PASS；生成器重跑幂等。
- **R 打磨（实测驱动、按需打磨）**：首轮三态图视觉复核暴露 2 处业务注入侧争位
  （配方库 / 校验栏标题与身份装饰重叠、证书栏五件套裁切），仅在 Demo 侧
  `topMargin: 40` / `certificateHeight: 190` 避让修复，**零公共 API 改动、零指纹漂移**。
- **发布边界**：全部改动留工作树未提交，`commit / push / tag / PyPI / 站点上线` 全归 CSA。

---

## [1.1.0] - 2026-11-26 — 四增量整批单次重签（未发布中间批次史料 · 已并入 1.2.0）

> **本段为 1.1.0 未发布中间批次的史料**（该批次从未发布，四增量已并入 1.2.0 整批单次重签）；下方同版本「三个 AI 智能组合根完现」段落为
> 批次一史料，完整保留供追溯。1.1.0 共 **4 项增量组合根**（`NovaAgent` / `NovaDE` /
> `NovaCopilot` / `NovaOrbit`），按宪法第 8 章 additive minor **整批登记、单次重签**，
> 禁止产生中间指纹。
>
> **最终口径**：包 / API `1.1.0` · `api/nova-api-1.1.0.json` · **143 导出类型** ·
> 组合模块 **19**（15 GA 签名逐字不变）· a11y `decorative` **83** ·
> 指纹 `bfd3d938a2fab7be → cc32b5852ed04995 → **862312749d335aad**` ·
> **19/19 天花板销号** · **57 张三态装配图**。

### 本轮增量（第 19 组合根 NovaOrbit + 四份企业级旗舰版封版法源）
- `docs/layout_shell/NovaAgent-NovaDE-NovaCopilot.md` **优化完善并拆分为三份独立封版法源**：
  `NovaAgent.md` / `NovaDE.md` / `NovaCopilot.md`（原文联合总纲保留为史料）。
- `docs/layout_shell/NovaOrbit.md` **原地企业级优化完善**（元信息 / 零章无业务语义骨架 /
  O1~O8 工程落点列 / 组件级契约 / CC-1~CC-8 映射 / CARF 四阶段 / 封版声明），
  原文 ASCII 图与表格、O1~O8 编号逐字保留。
- **创建第 19 个组合根 `NovaOrbit` 意图轨道工作台**（七槽无业务语义骨架 +
  受控信号 + `_` 私有纯几何身份），落地为库内企业级旗舰版封版法源；
  七槽真实业务注入成品级 Demo `examples/layout_shell/orbit/` + Gallery 第 19 页 +
  3 张三态装配图（54 → **57 张**）。
- **三个既有 AI 组合组件按 CSA 拍板「实测驱动、按需打磨」**：19/19 机检（静态 CC 契约 /
  字面量实例化 / 57/57 组极端非法入参 / RTL / reducedMotion）+ 三态装配图视觉复核
  **零缺陷暴露 → 零 PATCH、无需打磨**，如实登记，不硬造修改。
- 冻结面 / 生成器 / 测试 / 机检尺 / 模块 README / CEILING_AUDIT / nav / 双语 README /
  docs / AI 离线副本 / 账本全链路同步为 19 项口径。

### 验收（整批全绿）
- `check_all.py --tier static` **3/3**（a11y **143/143** · API 冻结 · qmllint **0 error** / 594 warning 预算内）。
- 专项 `pytest tests/test_api_freeze.py tests/test_layout_shells.py -q` **52/52**。
- `audit_ceiling.py` **19/19 PASS**（19 组件字面量 + 20 showcase / Gallery + **57/57 组**极端非法入参零负几何 + RTL 19/19 + reducedMotion 300→0 + **465 条文档链接断链 0**）。
- `audit_foundations.py` **15/15 PASS**；`mkdocs build` **exit 0 / 0 WARNING / 0 内容 INFO**；
  `gen_apidocs.py` 重跑幂等、19 页逐组件文档 / 57 张三态图索引齐全。
- **发布边界**：全部改动留工作树未提交，`commit / push / tag / PyPI / 站点上线` 全归 CSA。

---

## [1.1.0] - 2026-11-26 — 三个 AI 智能组合根完现（CARF 全循环 · additive minor · 待 CSA 发布）

> **版本说明**：1.0.1 之上的 **additive minor** 升级——新增 3 个组合根容器公共类型
> `NovaAgent` / `NovaDE` / `NovaCopilot`（设计定义见
> `docs/layout_shell/NovaAgent-NovaDE-NovaCopilot.md`，Enterprise Flagship v1.0-FINAL）。
> 按宪法第 8 章与 `gen_api_freeze.py` 第 3 节变更政策：新增公共类型属增量，须**升 minor + 重签冻结面**：
> 包版本 `1.0.1 → 1.1.0`、`apiVersion` 派生为 `1.1.0`、清单 `api/nova-api-1.1.0.json` 重签、
> 指纹 `bfd3d938a2fab7be → cc32b5852ed04995`、导出类型 **139 → 142**、组合模块 **15 → 18**。
> **15 项 GA 公共签名逐字不变**；发布边界（commit / push / tag / PyPI / 站点上线）仍**全归 CSA 本人**。

### 新增（Added）
- **三个组合根容器 QML**（`Nova.Composite.LayoutShell`，全部 `a11y: decorative`）：
  - `NovaAgent` 智能体任务执行工作台：6 槽（task / plan / content / verify / approval / overlay）+ 3 信号 + 3 函数；身份 = DAG 节点链 + 风险分级色阶 + 审批闸门色带 + 验证轨递减条。
  - `NovaDE` 数字员工岗位工作台：6 槽（role / queue / content / sla / handoff / overlay）+ 3 信号 + 3 函数；身份 = 岗位菱形徽记 + 队列堆叠卡沿 + SLA 递减条 + 交接双向箭头。
  - `NovaCopilot` 增强型协作面板：5 槽（suggest / inline / content / gate / overlay）+ 3 信号 + 3 函数；身份 = 内联胶囊条 + 三段确认级条 + 闸门分隔点 + 撤销弧环。
  - 三者均遵循宪法三要素（≥2 已导出类型组合 / `property alias` 固定槽位 / **无业务语义骨架**）与 CC-1~CC-8（唯一密度源、单一分隔源、抽象几何身份、恒定锚链、槽位宿主铺满、动效令牌、RTL、`Esc` 键盘可达、极端入参几何钳制）。
  - **治理语义边界**：八项准入控制 / 四要件 / 建议—确认—执行闸门等均为业务层职责，全由槽位注入；Shell 只托管布局与 emit 意图。
- **三个成品级 Demo**：`examples/layout_shell/{agent,de,copilot}/main.qml` + `run.py`（六槽真实业务注入 / 调参浮层默认收起 / `variantMode` 三态开关 / 明暗双主题 / 令牌驱动自绘按钮）。
- **9 张三态装配图**：`docs/screenshots/{agent,de,copilot}_showcase_{light,dark,variant}.png`（45 → 54 张）。
- **Gallery 调参页**、逐组件 API 页、模块 README 契约、CEILING_AUDIT §8 销号表、mkdocs nav、`nova-data.js` 站点数据同步为 18 项。

### 变更（Changed）
- 版本号 `1.0.1 → 1.1.0`；冻结清单、API_FREEZE、COMPONENT_LIST、A11Y_MATRIX、AI 离线副本、项目 PROMPT 投影全部按生成物纪律重跑。
- 各机检尺口径 15 → 18（`audit_ceiling.py` / `audit_showcase.py` / `test_layout_shells.py` / `test_api_freeze.py` 的 139→142、15→18、decorative 79→82）。
- `gen_apidocs.py`：补 `NovaDE → de` 展示目录别名表；逐组件页 / 总览 / 装配图索引 / 站点产品化层的 15/45/139 硬编码改为动态计算。

### 验收（本轮全绿）
- `check_all.py --tier static` **3/3**（a11y **142/142** · API 冻结 **142 类型零漂移** · qmllint **0 error** / 593 warning 预算内）。
- 专项 `pytest test_api_freeze.py test_layout_shells.py -q` **51/51**。
- `audit_ceiling.py` **18/18 PASS**：18 组件字面量实例化 + 19 showcase + **54/54 组**极端非法入参零负几何 + RTL 18/18 + reducedMotion 300→0 + **443 条文档链接断链 0**。
- `audit_showcase.py` 三个新组件三态出图全 PASS；`mkdocs build` exit 0 / 0 WARNING / 0 内容 INFO（输出系统临时目录，未触碰 `site/`）。
- 三组件 showcase 均无头加载 ROOTS 1 / 零警告；浅 / 深 / 变体三态真实引擎渲染复核通过。

---

## [1.0.1] - 2026-11-25 — 基础组件天花板打磨（CARF-R 续篇 · patch · 待 CSA 发布）

> **版本说明**：1.0.0 GA 之上的 patch 升级——本批为 Robustness 修复 + 文档站打磨，
> **公共 API 零漂移**（139 类型 · 指纹 `bfd3d938a2fab7be` 不变）；冻结契约 `apiVersion=1.0.0`
> 与 `api/nova-api-1.0.0.json` 文件名不改（`test_api_freeze` 硬断言保持 1.0.0）。
> 21:54 伙伴指令「T5 销号后升级版本号，我 pypi、git」→ **git commit / push / tag / PyPI 全归 CSA 本人**。

> 伙伴："按 CARF 宣言与 CEILING_AUDIT.md 方式，认真打磨除 15 项组合组件之外的其他全部组件。"
> 组合组件 15/15 已封版；本轮是其适配版续篇，遵循组合宪法第 0 章第 3/4 条——**基础控件不套 CC 契约、
> 四性逐项判定、仅实测暴露缺陷才打磨**，不为凑流程硬造修改。
> 第二批指令："49 个 SIGSEGV 先不管，继续打磨剩下的项"——对剩余项补测非数值入参 / 深主题 /
> RTL-ar / reducedMotion 三维度，坚持数据驱动、不硬造修改。

### Fixed（第一批 14 项真实 Robustness 缺陷 · `_` 私有 PATCH · 公共 API 零漂移）

- 逐属性极端非法入参（`-999` / `999999`）+ 0.45s 充分收敛体检 128 项基础组件，锁定 **14 项稳态几何负宽高**
  （初筛 19 组含收敛不足假阳性，精确复测后 14 项为真实缺陷；合法 API 语义如 `NovaStepper._qcolor()`
  命名色映射、margin 条件值、占位属性**不改**）。
- 修复清单：`NovaPage` / `NovaCardSection`（padding）、`NovaCol`（gutter）、`NovaSeparator` / `NovaInnerLoading`
  / `NovaAjaxBar`（size）、`NovaCheckbox`（visualWidth）、`NovaDialogShell`（maxWidth）、`NovaEditor`（minHeight，
  含 Qt ScrollView 内部装饰负几何）、`NovaExpansionItem`（层级缩进）、`NovaImg`（spinnerSize）、
  `NovaSlideItem`（revealWidth + 除零保护）、`NovaRange` / `NovaSlider`（thumbSize / trackSize）。
  全部以 `readonly property _xxx` 钳制属性 + 几何出口改用钳制值实现，公共签名逐字不变。

### Fixed（第二批 1 项 · 剩余项多维体检 · 内部几何守护）

- 对剩余可实例化基础组件（89 项：77 Controls + 12 Behaviors，剔除 15 组合壳 / 14 已销号 / 4 数据句柄）
  补测三维度：**非数值边界入参**（string 超长 2000 字 / 特殊字符 / 空串、color `transparent`、bool、`null`）、
  **深主题 `NovaTheme.setDark(true)`**、**RTL-ar `NovaI18n.setLocale("ar")`**、**reducedMotion**。
- 锁定 **1 项真实 Robustness 缺陷**：`NovaField` 的 `label` / `prefix` / `suffix` 超长时，
  Row 内 Text 隐式宽度（≈27228px）反噬 `controlHost.width = parent.width - x - suffixText.width...`
  → `QQuickItem -27228x40`；以内部几何出口 `Math.max(0, ...)` 守护修复，超长 / 短 / 空三组复验负几何 **0**，公共 API 不变。
- **甄别不改**：约 40 处 `CREATE_FAIL` 是探针给 Delegate 内部属性（`opt`/`tag`/`rowData`/`key` 等）赋值被 QML 拒绝的假阳性；
  37 处硬编码颜色为色板数据 / 头像随机色 / 品牌底白字 / 自带 `isDark` 双分支 / 半透明遮罩等合法语义；
  深主题 / RTL / reducedMotion 三态全类型实例化 **0 负几何**。坑位 49 SIGSEGV 属测试基建问题，本轮搁置。

### Added（工具与台账）

- `scripts/audit_foundations.py`：基础组件 Robustness 机检尺（15 项逐属性稳态几何守护 +
  122 非单例类型实例化冒烟 + 超长字符串守护 + 三态零负几何守护），为组合尺 `audit_ceiling.py` 的**适配版**（不套 CC 契约）。
- `docs/CEILING_AUDIT_FOUNDATIONS.md`：CARF-R 基础组件逐项销号活台账（**15/15** 销号）。

### 验收（CARF-F）

- `audit_foundations.py` **PASS**（15/15 · 122 类型实例化零缺陷 · 三态零负几何）；
  第一批 14 项负几何 **19 组 → 0**，第二批 NovaField 超长文本负几何 **→ 0**；
- 静态门禁 **3/3 PASS**（a11y 139/139 · API 冻结 · qmllint 0 error / 594 warning 分类预算内）；专项 **48/48**；
- **139 类型零漂移 · 指纹 `bfd3d938a2fab7be` 不变**（全 `_` 私有 / 内部几何 PATCH）；**21:25 经 CSA 授权已 commit + push**（`5c94186`，195 文件）；tag / PyPI 仍归 CSA、未执行。

### 归档（测试基建 · 坑位 49 · 议题结案、非交付完成）

> 伙伴 21:47 指令：「按这个状态结案归档」。按 **CSA 结案特例**归档——**议题结案、非交付完成**，不圆场成已修复。

- **精确诊断**：崩溃在 pytest `_pytest/runner.py:150 item.funcargs = None` 之后，用例 funcargs 引用清空 → shiboken 立即析构 QML 对象 → 同进程引擎残留对象 refcount 冲突 → `0xc0000374` 堆损坏 / access violation。最小复现：`-k "test_demo_loads or test_gallery_loads"` 3/3 崩；form_env 13 用例 3/3 崩；全量 `test_smoke` 崩在第 7 用例 `test_gallery_loads`。
- **排除项**：产品 QML 代码（体检脚本 122 类型 × 三态零崩）、测试逻辑错误、Python 版本（3.12.7 / 3.14.7 均崩）、pytest 插件（`no:cacheprovider` 仍崩）、断言重写（`--assert=plain` 仍崩）、单用例（独立进程 8/8 稳定）、纯脚本模拟 funcargs 清空（30 轮不崩 → 确证 pytest 生命周期交互特有）。
- **14 类工程修复尝试全部无效**：强引用 `_ALIVE`、component 保活、删 `_smoke_teardown` 收尾 pump、unconfigure / sessionfinish 硬退出（崩在报告前，来不及）、`PYTHONMALLOC=malloc`、funcargs teardown hook、受控 pump 排空删除队列、deleteLater / close 混用、原始 1.0.0 worktree 对照等；与 `SESSION_HANDOFF.md` 坑位 49 原始结论一致（deleteLater / close / gc.collect 均无效）。
- **定性与后续（需 CSA 拍板）**：Qt 6.12 + shiboken 6.12 与 pytest 9.2 生命周期交互的深层 refcount 缺陷。真正修复需**环境 / 架构变更**：隔离验证 PySide6 降级（6.11.3 / 6.10.3；项目声明 `PySide6>=6.8`、当前锁 6.12.0），或改测试架构为分批独立进程。**本归档不代表已修复、不代表已交付代码变更**。
- **影响边界**：产品代码 / 已发布 1.0.0 包 / 已推送提交 `5c94186` 均不受影响；所有试验改动已 `git checkout HEAD --` 回退，工作树干净；功能契约由 48 专项 + 静态 3/3 + 300+ 冒烟覆盖。

### 治理（T5 销号 · CSA 结案特例）

- 21:54 伙伴指令「T5 销号」→ **议题结案、非交付完成**：5 项中 4 项已闭环（① 项目级 PROMPT 重生成 / ③ 宪法单一源收敛 / ⑤ 门面文档刷新 / ④ DoD 计数裁定 24→21），**仅剩 ② static 门禁接 CI 客观未完成**，不圆场成已交付、编号不复用。待办池 3 → 2 项（T3 / T4）。

## [1.0.0] - 2026-11-25 — GA 正式版（PyPI 发布）

### Added（CARF 宣言入宪 · 15 项组合根容器全量天花板封版 · 伙伴："15 项组合组件全部打磨一遍，你自己定节奏"）

**宣言与落点（小诺定）**
- **CARF — Conceive, Achieve, Refine, Freeze — Culminate to the peak. 构想 · 实现 · 打磨 · 封版，终抵巅峰（天花板）。**
  列为 pyside-nova **最高方法论与最终目的**：母法 `docs/CONSTITUTION.md` **卷首**（第 0 章之前）、
  组合宪法 `docs/COMPOSITION_CONSTITUTION.md` **卷首执行版**（版本升 **1.0.0**、第 0 章新颁第 5 条 CARF 循环与销号纪律）、
  `docs/layout_shell/CEILING_AUDIT.md` 作为 **CARF-R 活台账**。C 由 CSA 立标准与法源、A 由完现者落成工程现实、
  R 按六维天花板逐项销号、F 封版零漂移且发布边界归 CSA；CARF 是循环，不推倒重来。
- 不升包版本号：本轮全部为 1.0.0 GA 基座上的 `_` 私有 PATCH / 文档 / 生成器 / 工具改动，公共 API 签名逐字不变。

**全量打磨（15/15 · 按语义分类自定节奏 · 一次一项或同族一组 · 逐项验收销号）**
- 批次 3 主导航壳：`NovaSidebar` → `NovaTopNavigation` → `NovaDualSide`；批次 4 多栏工作台壳：
  `NovaTabShell` → `NovaThreeColumn` → `NovaCompare` → `NovaCardGrid`；批次 5 浮层容器壳：
  `NovaModal` → `NovaDrawerPanel`；批次 6 极简独立页壳：`NovaSetupWizard` → `NovaBlankPage`。
- 十一项源码整文件按 **CC-1~CC-8** 重写（组合上下文唯一密度源 / 单一分隔源 / 主色系抽象几何、
  禁止仿交互控件 / 层级色阶 / 栏高归零 + 恒定锚链 + 共用 `_dur`·`_ease` / 槽位宿主铺满 / 装配态验收 / showcase 纪律）；
  十一项 showcase 重做为成品级真实业务场景（调参面板默认收起、纯几何图标、统一 `variantMode`）。
- **CARF 复评**：批次 1~2 四项统一补 `variantMode` 恢复三态差异；`NovaChat` 残留三元锚链改栏高归零、
  `NovaMobile` 新增 `_chromeCap` chrome 高度预算。
- 新建 `scripts/audit_showcase.py`（CC-7 三态出图）与 `scripts/audit_ceiling.py`（CARF-R 销号机检）；
  **15 项 × 浅 / 深 / 变体 = 45 张装配态图**全部出图 PASS。

**机检 FAIL 33 项 → 0（不降标准、只修真实缺陷）**
- **5 处真实稳态几何缺陷**：`NovaMobile` 安全区 / Header / 底导航叠加超窗高（`NovaPage -80`）；
  `NovaSidebar` / `NovaTopNavigation` / `NovaDrawerPanel` 槽位宿主固定 `margins` 在父轨归零时算出 `-24` / `-12`
  → chrome 高度预算 + `margins` 随父轨尺寸钳制，最终 **45/45 组极端非法入参非负几何**。
- `NovaDrawerPanel` 装配态对侧变体拉伸占满整宽（`left/right: undefined` 三元锚链）→ 恒定 `x/y` + `Behavior on x`；
  另修 `id-shadows-member` 真实红灯（重命名 `_panelCard`），**未调 qmllint 预算掩盖**。
- 静态 3 项是注释史料被误判为占位文案 → 机检新增 `_strip_comments()` 只扫非注释文本（真实占位仍判 FAIL），
  并规范化三份注释措辞做双保险；功能性遮罩 `_mask` / `_scrim` 按 CC-3 例外识别。
- 21 条断链全部来自 `docs/ai/pages/**` 生成物副本（`shutil.copyfile` 原样拷贝致链接基准失效）
  → **修 `scripts/gen_apidocs.py`**：新增 `rewrite_links()` 按源文档目录解析、按目标目录重表达，
  重跑后断链 **21 → 0**；生成物一律由生成器产出，未手工编辑。

**验收（CARF-F）**
- `scripts/audit_ceiling.py` **PASS**（静态 15/15 全 ✓ · 45/45 组极端入参 · RTL 15/15 · reducedMotion `300→0` · 断链 0）；
- 静态门禁 **3/3 PASS**（a11y 139/139 · API 冻结 · qmllint **0 error / 593 warning** 预算内）、专项 **48/48**、
  无头实例化 **31/31**、45 张三态图抽查视觉无退化；
- **139 类型零漂移 · 指纹 `bfd3d938a2fab7be` 不变**（全 `_` 私有 PATCH，无需重签）；
- `gen_apidocs.py` 重跑：**139 类型 API + 13 页文档**，AI 离线副本自洽。
- 发布边界归伙伴（CSA）；本轮未执行 commit / push / tag / PyPI。

### Added（CC 迁移批次 2 · 组合宪法 0.9.1 · 伙伴："优先组合组件…NovaChat → NovaDesktop → NovaMobile → NovaFlexLayout" · patch 实现变更指纹不变）

**复盘与节奏**
- 伙伴问「你总结了吗？问题出在何处」→ 复盘已固化：**缺 L1 组合上下文层**（机制）、
  `alias` 到 `.data` 的槽位注入顶层 **0×0**（架构）、只有单组件验收没有装配态验收（规范）。
- 伙伴立节奏：**优先组合组件 → 组合打磨中若暴露单个组件问题 → 反向打磨该单个组件**；
  按「稳步推进、逐个打磨」串行处理 4 项，不批量扫荡其余 11 项。
- 新建 `docs/layout_shell/CEILING_AUDIT.md` 天花板档案（评估标尺 / 复盘 / 批次记录 /
  反向打磨记录 / 15 项销号进度表 / 验收总表）。

**NovaChat 复评（0.9.0 首例）**
- 销号 7 处 showcase 层残余：状态栏调试字样 → 真实连接态、消息流「不足一屏贴底 /
  超出一屏顶对齐且可滚动」、三点伪菜单 → 真实「成员 3」胶囊、3 个伪工具方块 → 真实
  可交互工具位、导航位 hover 反馈、signal 回显移入调参浮层。

**NovaDesktop / NovaMobile / NovaFlexLayout（三大多端根壳，全 `_` 私有 PATCH）**
- **CC-1**：各建 10~13 个 `_` 私有组合上下文常量，消除散用 `NovaTheme.spacing*`。
- **CC-5**：三元锚链全面改为「**栏高归零 + 恒定锚链 + `Behavior on height` 共用
  `_dur`/`_ease`**」，隐藏栏平滑收起、页面自动铺满，消除布局跳变；FlexLayout 面板加
  `Behavior on width`，分栏变化平滑过渡。
- **CC-3**：Desktop 红黄绿三色控制点 / 26×26 伪按钮方块、FlexLayout 三色渐变底线与
  面板顶条，一律收敛主色系抽象几何；Mobile 灵动岛深色改提亮表面色 + 描边。
- **CC-2 / CC-6**：每边界唯一分隔源；槽位宿主独立铺满、注入顶层 `anchors.fill: parent`、
  内容限宽；`NovaPage padding` 与网格 margins 同值，消除三层 padding 叠加。
- **CC-8**：三个独立演示重写为成品级 showcase（真实 IDE / 移动会话页 / 实时运行看板），
  调参面板默认收起浮层、emoji 图标改纯几何日月、组件状态栏与窗口状态条文案去重。

**反向打磨（条件触发，仅 1 次）**
- 装配态深色出图审计暴露 `NovaMobile` 灵动岛与背景糊成一片 → 直接修该组合组件；
  **未触发任何 Controls 基础组件反向修改**，不为凑流程硬造。

**验收**
- 4 个 showcase × 浅 / 深 / 变体 = **12 张图**全部出图，QML 零错误；
- 静态门禁 **3/3**、专项 **48/48**、**31/31** 无头实例化；
- 4 组件极端非法入参 **0 错误 / 0 负几何**、RTL **4/4**、reducedMotion `300→0ms`；
- qmllint **0 error / 593 warning**（新增 2 处 unqualified 已用 `parent._tone` 限定修复）；
- **139 类型零漂移 · 冻结指纹 `bfd3d938a2fab7be` 不变**（PATCH 无需重签）。
- 其余 11 项按节奏逐项推进；发布边界归伙伴。

### Added（组合态一致性契约 CC · 组合宪法 0.9.0 · 封版规范 v2.1.0 · 伙伴："单个组件组合到一起就掉链子" · patch 实现变更指纹不变）

**诊断（机制 / 架构 / 规范三层）**
- 15 项单组件四性回扫全 PASS，但 `NovaChat` 六轨装配后仍「中央空板 / 同边界 3~4 层线 /
  青橙撞色装饰 / 伪按钮冒充交互控件 / 调参台混入展示区」——根因是 **`NovaTheme`（L0 令牌）
  与业务注入（L2）之间缺 L1 装配层**。Quasar 靠 CSS 变量 + `QItem/QList/QCard` 组合惯例
  隐式提供，QML 必须显式建模。
- **最硬实测**：`property alias xxxSlot: _host.data` 注入的顶层 `Item` 默认 **0×0**，内部
  anchors 算出 `-24` / `-48` 负宽高被裁 → 「中央永远空板」；`NovaPage` padding + Shell
  padding + 装饰 margins 形成三层间距叠加。

**规范**
- 宪法新增**第 9 章 组合态一致性契约 CC-1~CC-8**（组合上下文唯一密度源 / 单一分隔源 /
  装饰预算与禁止仿交互控件 / 层级色阶 / 动效同步与恒定锚链 / 槽位内容基线 / 装配态验收 /
  参考实现纪律）；原第 9 章坑位表顺延第 10 章，新坑位 20/21；第 8 章准入清单补装配态验收。
- 封版规范升 **v2.1.0**（§2.3 组合态 8 条红线 / §8.3 装配实测 / §12 AI 主窗口 CC 附加 /
  §13 层级与变更记录）；白皮书 v2.1.0、营销 README、权威清单、模块 README 同步。

**代码（NovaChat 首例，全 `_` 私有 PATCH）**
- 13 个 `_` 私有 `readonly` 组合上下文常量（`_unit` / `_gap` / `_radius` / `_divider` /
  `_rail` / `_panel` / `_ink` / `_inkSoft` / `_dur` / `_ease` 等）供六轨共享，消除散用 spacing；
- 边界由「3 separator + 3 渐变缘轨 + header 渐变线 + 顶层三段撞色带」收敛为**每边界唯一
  分隔源 + 2px 主色系顶层线**；删除 3 条 `secondary`/`accent` 撞色缘轨；
- 20+ 仿交互控件装饰（圆钮 / 搜索胶囊 / 图标方块 / 三点菜单 / 分段 tab / 完整输入轮廓）
  改为抽象几何（渐变轨 / 色带 / 角标 / 圆点 / 递减条），消除「看着能点却不能点」；
- 三段折叠 `Behavior` 共用 `_dur` / `_ease`，锚定链恒定指向轨 wrap，不再用
  `sep.visible ? sep.right : wrap.right` 三元切换（折叠瞬间布局跳变的真因）；
- `examples/layout_shell/chat/main.qml` 重做为**成品级 showcase**：六槽注入真实业务
  （导航位 / 搜索框 + 4 条会话 / 头像标题栏 / 6 条 `NovaChatMessage` / 可发送输入框 /
  详情信息卡），调参面板改默认收起浮层，消息流与输入区限宽居中，标题与副标题分离。

**验收**
- 浅色 / 深色 / 折叠三态真实引擎渲染审计（`docs/screenshots/chat_showcase_*.png`）
  全部通过，QML **零错误**，对象树无 0×0 / 负宽高；
- 静态门禁 3/3、专项 48/48、31/31 无头实例化、qmllint 0 error；
- **公共 API 签名逐字不变、139 类型零漂移、指纹 `bfd3d938a2fab7be` 不变**（PATCH 无需重签）。
- 其余 14 项按「现有再优、稳步推进、逐个打磨」分阶段迁移，本版不批量改动。

### Changed（四性标准全库回扫 · 组合宪法 0.8.1 · 封版规范 v2.0.1 · 伙伴："其余 6 个组件也按四性标准过一遍" · patch 实现变更指纹不变）

**边界厘定**
- 伙伴口径"其余 6 个"经 `git diff` + 文件时间戳 + 全量机检锁定为：0.7.1 / 0.8.0 立规后只修
  单点，15 项从未按新四性规则整体回扫——故按**全库 15 项四性回扫**处理（宪法坑位 18：
  新条款入宪即全库回扫，无"其余免检"）。

**代码（四类合规债全清，全为 PATCH `_` 私有实现变更）**
- **艺术性 · 装饰实心度**：20 余处身份装饰 `opacity: 0.18~0.7` 全库统一提到 **≥0.85**；
  仅保留功能性遮罩（`NovaModal` `_mask` 0.55 / `NovaDrawerPanel` `_scrim` 0.32）与交互禁用态
  等三类显式注释例外；
- **鲁棒性 · RTL**：14 项根 Item 补 `LayoutMirroring.enabled: NovaTheme.isRtl`（全库 15/15，
  `NovaChat` 0.7.1 已有）；逻辑侧 `bySide` 等 API 语义恒定；
- **鲁棒性 · 几何入参钳制**：15 项新增 **39 个** `_` 私有 `readonly property` 钳制属性
  （`_headerH` / `_footerH` / `_pad` / `_gap` / `_nSteps` / `_chromeH` 等），**54 处**几何
  引用改走钳制值；栏高钳制下界统一 **24**（下界 0 会被 `NovaHeader` / `NovaPage` 内部固定
  padding 反噬出负几何）；`NovaModal` 补 `_maxW` / `_maxH` / `_chromeH` 并修卡片高度下界
  （`maxHeight` 小于标题栏 + 操作栏时内容区塌陷为负）；同时净化 33 行
  `root.* || <默认值>` 弱类型兜底（合法 `0` 不得被抬升为默认值）；
- **艺术性 · 身份装饰层叠**：17 处与槽位注入层同父的身份装饰补 `z: NovaTheme.zMarginals`；
  撤销 1 处误提级的 `NovaDualSide` 中央画布网格底纹（中央内容区完全留给业务注入）。

**验收**
- **15/15 极端非法入参稳态几何非负**（每项注入 34 组负尺寸 / 超大尺寸 / 非法枚举，等待
  Behavior 动画收敛后测稳态；过渡中间态负 margin 不判缺陷）；
- 31/31 无头实例化（15 组件 + Gallery + 15 演示）；明暗令牌实时切换 PASS；
  `reducedMotion` 300→0ms PASS；
- 浅色 + 深色双主题、实心业务注入身份审计图 15/15 重渲染
  （`docs/screenshots/composition_identity_audit*.png`）；
- 静态门禁 `check_all.py --tier static` **3/3 PASS**；专项 48/48；qmllint 0 error 且
  warning 与基线一致（593）；**公共 API 签名逐字不变、139 类型零漂移、指纹
  `bfd3d938a2fab7be` 不变**（PATCH 无需重签）。

**文档**
- 组合宪法升 **0.8.1**（第 6 章第 5 条 / 第 7 章第 1、3 条强化；坑位表补 18「新条款入宪即
  全库回扫」/ 19「栏高下界与 maxHeight 矛盾」；迭代记录登记）；
- 封版规范升 **v2.0.1**（§2.1 钳制细则、§2.3 实心度例外与中央底纹不提级、§2.4 RTL 15/15、
  §8.3 回扫实测基线、§13 层级表与变更记录）；
- 白皮书升 v2.0.1（§4.4 补四性回扫成果、§8 工程基线补实测、§12 文档治理同步）；
  营销版 README 素材补四性回扫实测行；
- 权威清单 `docs/layout_shell/PrescientLayoutShell.md` 头部与末尾补 0.8.1 回扫记录；
  模块级 `Composite/LayoutShell/README.md` 法源版本同步；
- AI 离线副本重跑 `gen_apidocs.py` 同步（宪法 / CHANGELOG 副本不再停留在 0.8.0）。

### Changed（旗舰封版规约落地 · 组合宪法 0.8.0 · 伙伴："汲取营养融入 README / 优化完善两篇白皮书为企业级旗舰封版 / 为咱们所用再次打磨重构 15 项" · patch 实现变更指纹不变）

**文档（企业级旗舰封版）**
- `docs/white_paper/` 三篇全部升级 **v2.0.0**：
  - 《Prescient Layout Shell 封版规范》——补「法源与封版资格」声明（FROZEN 为记录性，
    资格由 API 冻结门禁授予）；适用范围 11 → **15 项**、第五模块 URI 与五模块物理映射；
    **第 4 章槽位契约重写**（作废「固定五槽 / `contentSlot` 必需」错误口径，给出 15 项真实
    槽位权威表 + 浮层槽透明契约 + 宿主隔离）；第 5 章目录结构重写为单一模块平铺；
    第 6 章补 `NovaMotion` 动效令牌与 `outlineStrong` / `textOnPrimary` 真实令牌；
    第 7 章明确身份元素不违反 D-013 的合规边界；第 8/9 章对齐真实门禁与交付物；
    第 12 章 Root Shell / AI 主窗口改为已 GA 封版；成熟度表全部改为 ✅ 1.0.0 GA。
  - 《旗舰组件库白皮书》——保留品牌宣言 / 痛点 / Slogan / 对比表 / 文案库营养，
    「11 + 3 规划中」全部校准为六类 15 项 ✅ 1.0.0 GA；新增 §4.4 封版成果与
    §8「基线 + 实测」双列工程规范；演进路线拆为「已达成 / 后续工程项」并加不夸成熟度声明。
  - `pyside-nova-README.md` —— 校准为对外营销版素材 v2.0.0（真名 / 真状态 / 可执行示例），
    消除旧 `Nova*Shell` 命名、`title` 伪属性与草案痕迹。
- `README.md` / `README_zh.md` 汲取营销稿营养重写：品牌宣言、架构分层图、旗舰四性、
  全端覆盖、跨端对比、适用场景、Slogan 与文案库；状态由 0.3.0 / 12 组件 / M1–M3 规划中
  校准为 **1.0.0 GA / 139 类型 / 五模块 / 15 组合根容器 / Quasar 2.35.5 / 478 项 pytest**。
  事实核实纠正：Quasar 基线 2.26.0 → **2.35.5**；`NovaField/Form/Select/Date/Table/Layout`
  等原标 🚧 M1 实为**已注册实现**；`NovaSidebar` **无 `title` 属性**（营销稿伪属性已删）。
  **README 快速上手示例经真实 QML 引擎实例化验证可执行**。
- 新增 `src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md` —— 补齐白皮书第 9 章 /
  宪法第 8 章要求的交付物：15 项完整属性 / 信号 / 函数 / 槽位契约、**依赖组件清单与
  15 项依赖矩阵**（D-013 前置门禁产物）、最小示例、验收状态与维护纪律。
- `docs/COMPOSITION_CONSTITUTION.md` 升 **0.8.0**：第 4 章槽位口径校准、第 6 章令牌白名单
  补全 + 动效令牌强制落地、第 7 章键盘可达清单、第 8 章模块级 README 交付物、
  坑位表补 16（散落动画参数）/ 17（援引早期草案口径）、迭代记录登记。
- `docs/layout_shell/PrescientLayoutShell.md` 权威清单：删旧对话残留与规划态「落地顺序建议」，
  改为 15/15 封版状态表 + 0.8.0 规约落地记录；`qmldir` 头注释补封版声明。

**代码（15 项组合根容器再次打磨，全为 PATCH 内部实现变更）**
- **动效全库令牌化**：`NovaSidebar` / `NovaTopNavigation` / `NovaDualSide` /
  `NovaSetupWizard` / `NovaChat` 共 **8 处** `duration: 200/220/240; Easing.OutCubic`
  硬编码全部改为 `NovaMotion.duration(NovaMotion.transitionDuration)` +
  `NovaMotion.easingStandard`（新增 `import Nova.Design`）。由此全库节奏统一、
  `NovaMotion.reducedMotion` 无障碍短路与 `speedFactor` 全库调速自动生效
  （落实宪法第 6 章第 3 条与白皮书「动画全库统一」）。
- **键盘可达补齐**：`NovaSidebar` / `NovaDualSide` / `NovaTopNavigation` / `NovaChat`
  新增 `focus: true` + `Keys.onEscapePressed`，**只 emit 已有信号**（收起 / 关闭意图），
  不新增公共 API、不自写宿主状态；与既有 Modal / Drawer / Desktop / Mobile 的 Esc / Back 一致。
- **槽位宿主隔离**：`NovaDesktop.toolbarSlot` 由 `_toolbar.data` 改指独立 `_toolbarHost`，
  装饰 Row 提级 `NovaTheme.zMarginals`，避免业务注入遮挡身份元素。
- **清理**：`NovaFlexLayout` 删未使用的 `_bandColor`；`NovaTabShell` 校准虚构
  `activeIndex` 注释为「纯装饰身份元素，不绑定业务状态」。

**验收（发布边界归伙伴）**
- **公共 API 签名逐字不变、冻结指纹 `bfd3d938a2fab7be` 不变**（139 类型零漂移，
  PATCH 无需重签，恰证 Solidity 与 Aesthetics 可兼得）。
- 静态门禁 `check_all.py --tier static` **3/3 PASS**（a11y 139/139 · API 冻结 · qmllint 0 error）、
  专项 `test_api_freeze.py` + `test_layout_shells.py` **48/48**、
  **31/31 无头实例化**（15 组件 + Gallery + 15 演示）、README 示例实例化 OK、
  qmllint 零新增告警。

### Changed（NovaChat 多轨按轨分治 · 宪法 0.7.1 · 伙伴点名纠正 · patch 实现变更指纹不变）
- **`NovaChat` 6 轨重构**：伙伴点名"NovaChat 那套多轨结构也按这个思路重构一下"——
  0.7.0 把 `NovaChat` 当"多轨标杆"漏改，实则 6 轨各自仍是同一
  "`surfaceAlt` 平铺方块 + `NovaSeparator` + 220ms 宽度动画"模板，只是轨数多、无身份。
  本次给每条轨注入**独占且互不重复**的前景签名：顶层三段品牌发丝线 /
  导航轨（圆形渐变徽记 + 三级激活图标位 + 账户锚 + 缘轨）/
  会话栈（圆角搜索胶囊 + 左缘激活竖条 + 十字新建圆钮）/
  对话区（在线状态点 + 三点位 + 四角取景框）/ 输入区（浮起胶囊 + 附加十字 + 纯几何发送箭头）/
  详情栏（分段 tab + 缘轨）。签名只占边缘/角标，中央内容区完全留给业务注入。
- 全为 `_` 私有纯几何装饰、零业务语义、**零字体依赖**（发送箭头由 Rectangle + rotation 组合，
  规避 offscreen 字体符号豆腐块）；装饰实心度 ≥0.85，浅色 + 深色主题实心业务注入下均清晰对比。
- **公共 API 签名逐字不变、指纹 `bfd3d938a2fab7be` 不变**（patch 实现变更，无需重签）；
  宪法第 6 章新增第 6 条（多轨按轨分治）/ 第 7 条（浮层槽透明契约）、坑位表补 14/15。
- 验证：浅色 + 深色主题真实注入渲染验收（6 轨全展开、身份可辨）、15 格对比拼图与
  `docs/screenshots/chat_identity_audit*.png` 同步更新、静态门禁 3/3、专项 48/48、
  Gallery+15 演示 16/16 无头加载、15 项 qmllint 0 告警、chat 演示 qmllint 0 告警。

### Changed（身份差异化重构 · 宪法 0.7.0 · 伙伴点名纠正 · patch 实现变更指纹不变）
- **15 项组合根容器逐项重塑独有结构性身份元素**：伙伴点名"除 NovaChat 外基本都一个面孔"——
  0.4.0~0.6.0 的 14 项共用同一"平铺背景 + Header/Page/Footer + 220ms 宽度动画"模板仅换槽位名。
  本次逐项给出身份语言：Sidebar 品牌渐变轨+浮起侧栏卡、TopNavigation 胶囊导航台+悬浮下拉、
  DualSide 中央画布点阵+双侧浮起栏、TabShell 材质标签栏+下划线指示、ThreeColumn 三级深度色阶+
  拖拽 grip、Compare 中缝圆形调节柄+A/B 色条、CardGrid 工具条胶囊+Flow 网格、Modal 顶部三色条+
  catcher+浮起阴影、DrawerPanel 侧缘渐变轨+grabber、SetupWizard 三态步骤时间轴、BlankPage 居中
  阅读栏、Desktop 窗口控制点+分层栏、Mobile 灵动岛+home indicator、FlexLayout 三色面板网格、
  Chat 多轨标杆。
- 身份元素全为 `_` 私有纯装饰、零业务语义、**公共 API 签名逐字不变、指纹 `bfd3d938a2fab7be` 不变**
  （patch 实现变更，无需重签——恰证 Solidity 契约稳定与 Aesthetics 美学可兼得）；
  宪法第 6 章第 5 条立强制条款、坑位表补 13 防回退。
- 验证：渲染审计 15/15 出图（身份可辨）、静态门禁 3/3、专项 48/48、Gallery+演示 16/16 无头加载、
  qmllint 零新增告警。

### Changed（缩写全称化 · 宪法 0.6.0 · 伙伴拍板 · 单次重签）
- **`NovaTopNav` → `NovaTopNavigation`**：0.5.0 的"缩写可维持"结论被伙伴拍板推翻——
  旗舰公共 API 以自解释优先于字数精简；演示目录 `top_nav/`→`top_navigation/`，
  Gallery / a11y / 测试 / 权威清单 / PARITY / 宪法全量同步。
- 15 项总数不变，冻结面单次重签（宪法第 8 章批量纪律）。

### Changed（语义正名 · 宪法 0.5.0 · 伙伴拍板 · 同批重签）
- `NovaTabWorkspace` **改回 `NovaTabShell`**：撞 Controls 已有 `NovaTab` 时保留 `Shell`
  后缀，而非生造别名（0.4.0 的"一律去后缀"过严）；演示目录 `tab_workspace/`→`tab_shell/`。
- `NovaTopNav` 评估后**维持不扩写**（`Nav` 为 UI 领域通用缩写，与 `NovaSidebar` /
  `NovaDualSide` 粒度一致，不改为 `NovaTopNavigation`）。
- `NovaWizard` **正名为 `NovaSetupWizard`**（明确安装 / 新建工程 / 初始化配置用途）；
  演示目录 `wizard/`→`setup_wizard/`，Gallery / 契约表 / 权威清单 / 宪法 / PARITY 全量同步。
- 15 项总数不变，冻结面整批单次重签（宪法第 8 章批量纪律）。

### Changed（破坏性 · 1.0 GA 命名定稿 · 宪法 0.4.0 · 伙伴拍板）
- **版本号 1.0.0rc1 → 1.0.0 正式版**（发 PyPI stable）；`src/pyside_nova/__about__.py`
  唯一版本源更新，冻结清单 `packageVersion` 与 AI 索引版本随生成器同步。
- **14 项组合根容器去 `Shell` 后缀**（模块 URI 已表达组合身份，类型名冗余）：
  `NovaSidebarShell`→`NovaSidebar`、`NovaTopNavShell`→`NovaTopNav`、
  `NovaDualSideShell`→`NovaDualSide`、`NovaThreeColumnShell`→`NovaThreeColumn`、
  `NovaCompareShell`→`NovaCompare`、`NovaCardGridShell`→`NovaCardGrid`、
  `NovaModalShell`→`NovaModal`、`NovaDrawerPanelShell`→`NovaDrawerPanel`、
  `NovaWizardShell`→`NovaWizard`、`NovaBlankPageShell`→`NovaBlankPage`。
  **`NovaTabShell`→`NovaTabWorkspace`**：机械去后缀会撞 Controls 已有 `NovaTab`，
  触发冻结门禁跨模块重名红线；`NovaDesktop`/`NovaMobile`/`NovaFlexLayout` 本就无后缀，不变。
  这是破坏性 API 变更，故在 GA 前一次性完成，不升 2.0。
- 演示目录同步去 `_shell` 后缀（`examples/layout_shell/sidebar/` 等 11 个），
  Gallery、测试、生成器契约表、权威清单、宪法与 PARITY 审计全量同步。

### Added（第 15 项组合组件 · NovaChat · 对标 WorkBuddy 桌面端主窗口）
- **新增 `NovaChat`**：AI 对话主窗口根容器，六槽（导航轨/会话列/对话区/输入区/详情栏/浮层），
  `NovaHeader`+`NovaPage`+`NovaFooter`+`NovaSeparator` 真实公共类型组合；
  对话气泡由业务向 `contentSlot` 注入 Controls 已有的 `NovaChatMessage`（主窗口+气泡各司其职）；
  零业务会话数据、零写死文案、折叠只 emit、令牌驱动、`// a11y: decorative`。
- 新增 `examples/layout_shell/chat/` 独立演示（真实气泡渲染 + 六槽注入 + 调参 + signal 回显），
  Gallery 增第 15 页；15 演示 + Gallery 无头加载 16/16 通过，NovaChat 演示 qmllint 零告警。
- 冻结面一次重签（宪法第 8 章批量纪律）：138→139 类型，指纹
  `a8859ec8fc5720bf`→`2d7f173b8f13b123`；decorative 78→79；静态三门禁 3/3 PASS，
  API 冻结+布局专项 48/48 PASS。

## [Unreleased] - 2026-11-25

### Changed（治理 · 组合组件专属模块升格 · 宪法 0.3.0 · 伙伴拍板）
- 应伙伴要求，14 项组合组件从 `Nova.Controls` 物理迁至新模块
  `src/pyside_nova/qml/Nova/Composite/LayoutShell/`（URI `Nova.Composite.LayoutShell`），
  独立 `qmldir` 导出 14 项——**合法模块、非黑户**，冻结面与门禁纪律不变。
- 组合宪法升 **0.3.0**：第 2 章目录纪律将该目录升格为合法专属模块、坑位 7 与准入清单同步；
  母法 `docs/CONSTITUTION.md` 第 1 章补第五模块 URI。14 项类型名不变，整批单次重签冻结面。
- `examples/layout_shell/` 14 个子目录演示 + Gallery 的 import 同步改为新 URI；
  生成器（冻结/清单/AI 文档）、门禁、测试模块注册全量同步。

### Added（14 项 Prescient Layout Shell · 一次交付 · 组合宪法 0.2.0 合规重签）
- **14 个组合根容器 QML 一次落地**，全部进 `Nova.Controls` qmldir（合法导出、非黑户）：
  - 主导航 4：`NovaSidebarShell` / `NovaTopNavShell` / `NovaDualSideShell` / `NovaTabShell`
  - 多栏工作台 3：`NovaThreeColumnShell` / `NovaCompareShell` / `NovaCardGridShell`
  - 弹窗浮层 2：`NovaModalShell` / `NovaDrawerPanelShell`
  - 极简独立页 2：`NovaWizardShell` / `NovaBlankPageShell`
  - 多端根壳 3：`NovaDesktop` / `NovaMobile` / `NovaFlexLayout`（保留权威清单原名）
- 全部遵循组合宪法：≥2 个已导出公共类型组合、标准槽 alias、单向数据流（只 emit）、
  `NovaTheme` 令牌驱动、`// a11y: decorative` 标记、非法入参钳制、`pragma ComponentBehavior: Bound`
  零新增 warning、两行头注释无日期流水。
- **整批单次重签 API 冻结**：124→138 类型（Controls 91→105），指纹
  `f2fd1b0eacf665f2`→`3bc0fb035fa927ab`；同步 `API_FREEZE.md` / COMPONENT_LIST /
  A11Y_MATRIX（decorative 64→78）/ AI 文档；`test_api_freeze` 常量同步。
- 独立 Gallery `examples/gallery/layout_shells.qml` + `layout_shells.py`：14 页逐项真实预览、
  调参面板（折叠/显示栏/尺寸）、明暗切换，零运行时警告；不侵入主画廊。
- 新增 `tests/test_layout_shells.py` 20 项（14 实例化 / 槽位 / 主题 / 边界 / 列数钳制）。
- 静态三门禁 3/3 PASS；qmllint `import` 预算校准（RC1 漏记 `Nova.Runtime` 一条，1→2，非新增欠债）。

### Changed（治理 · 组合组件宪法 0.2.0 · 14 项一次交付适配）
- `docs/COMPOSITION_CONSTITUTION.md` 升 0.2.0：抬头新增**母法权威版本声明**（唯一法源 =
  `docs/CONSTITUTION.md` 0~13 章；根目录 0~10 章副本不得援引），法源补第 11/12 章；
  第 0 章明确 `NovaDesktop`/`NovaMobile`/`NovaFlexLayout` 三个无 `Shell` 后缀的多端根壳同样受约束；
  第 1 章语义分类由 3 类扩为**与 14 项权威清单对齐的 5 类**（逐类型核实为真实导出，无虚构 API）；
  第 8 章新颁**批量交付纪律**（整批登记 → 单次重签 → 整批验收，禁止逐个重签产生中间指纹）
  与生成物保护条款；坑位表补第 9/10 条。

## [Unreleased] - 2026-11-24

### Added（治理 · 组合组件宪法首颁）
- **新增 `docs/COMPOSITION_CONSTITUTION.md`**：《组合组件宪法 — pyside-nova Layout Shell
  Constitution》，母法《架构宪法》的子法，第 0~9 章——三要素定义 / 四模块目录与黑户禁令 /
  三层边界与单向数据流 / 五标准槽位 alias 契约 / D-013 组合完整性 / 真实令牌白名单 /
  鲁棒性与 a11y / 准入门禁清单 / 8 条反模式坑位。只定义在母法 L1 之上的组合纪律，
  令牌·目录·命名·冻结一律援引母法，不另立门面。
- 明确 `docs/layout_shell/` 历史四稿中的 "v1.0.0 FROZEN / 已封版" 表述与
  `Theme.*` / `NovaButton` / `NovaLabel` / `NovaAnimation` 等虚构 API **一律作废**；
  吸收其三层边界·槽位语义·组合优于继承·D-013 精华并校正为真实 API 面。
- 接入 mkdocs「工程纪律」导航、首页文档导航；`scripts/gen_apidocs.py` 的 PAGES 清单加入新页，
  重跑 AI 索引（13 页，指纹 0ffe8bd37c9827dd）。

### Added（库管员 + 成品验收员工具 · 一键总验收入口）
- **新增 `scripts/check_all.py`**：分层串跑全部门禁的统一入口。四层——`static`（默认，
  a11y/api/qmllint 三道秒级门禁，与 local_deploy 交付链一致）/ `dynamic`（perf + visual
  smoke + soak 冒烟 + hidpi）/ `supply`（cve）/ `all`（8 道全覆盖；封版加 `--soak-24
  --visual-full --cve-online` 为完全体）。`--brief` 摘要模式、`--report PATH` 落验收 JSON、
  `--list` 列举门禁。
- **统一退出码语义**：0=全绿（含 WARN 有条件通过）/ 1=至少一道产品红或工具 ERROR /
  2=未执行门禁（参数错误或环境缺失）。红灯先定性：cve 缺 SBOM/缓存(码2)判 WARN 前置缺失，
  不计产品红；环境预检发现无 PySide6 的解释器直接判 ERROR(码2)终止，杜绝假绿灯/假红灯混淆；
  子门禁统一用 `sys.executable` 启动保证解释器一致性。

### Added（RC2 封版验收 · 24h 内存长跑压测门禁）
- **24h 压测工具链**：`scripts/check_soak.py`（CLI 门禁，`--hours/--interval/--report`，退出码入 CI）
  + `tests/test_soak.py`（pytest 承载，复用单引擎/单斜杠/硬退出纪律）
  + `tests/soak_mem.py`（零第三方依赖 RSS 采样：Windows psapi / Linux statm + 三段稳健趋势判定）。
  冒烟 72s / 8896 轮 / 25 样本，RSS 84.6→84.9MB 全程平坦、斜率 -2.78MB/h，门禁通过。
- `tests/conftest.py` 新增 `--soak-hours/--soak-interval/--soak-report` 与 soak 硬退出标志
  （坑位 49），`.gitignore` 忽略 `reports/`。
- `docs/ECOSYSTEM_PARITY.md` §6「24h 压测」勾选（工具就绪 + 冒烟通过；真实 24h 全量长跑留 CI）。

### Fixed（验收工具链 · 中文 Windows 兼容性）
- `scripts/check_qmllint.py` 两处 Windows 假红灯修复（坑位 52）：① `find_qmllint()` 包内
  只找无后缀 `qmllint`，而 Windows 实际是 `qmllint.exe` 且 Scripts/ 无入口脚本 → 显式列
  两种后缀候选；② `subprocess.run(text=True)` 走 locale 默认编码（中文 Windows=GBK），
  诊断含 UTF-8 路径时 `UnicodeDecodeError` 崩溃 → 改 `encoding="utf-8", errors="replace"`。
  修复前门禁在交付机假红灯，修复后真实退出码 0（0 error / 593 warning 全在预算内）。

### 设计决策（踩坑沉淀，勿回退为「反复建销组件」负载）
- 负载采用**稳态对象池**：一次创建弹层/表格长期持有，只做 register/unregister、派生属性读取、
  主题/i18n 切换。采样前驱动 JS（`engine.collectGarbage()`）+ Python 双 GC，读 GC 后驻留 RSS。
- **不测「反复创建/销毁复杂 QML 组件」**：实测 Qt 6.12+PySide6 每建销一个复杂组件有
  0.3-0.5MB 不可回收固有开销——纯 Qt Quick 组件（无 Nova 代码）同样复现，属引擎层行为，
  纳入会让门禁永远红灯、掩盖产品真泄漏。

## [1.0.0rc1] - 2026-11-23

### Added（六期 RC1 收口 · **API 冻结审查**：测试 427 → 454、类型 124 不变）

- **冻结清单双件制**：`api/nova-api-1.0.0.json`（schema `nova-api-freeze/1`，124 类型逐成员
  签名——`props`/`signals`/`methods` 以 `名字:类型` / `名字(参数)` 串快照，`_` 前缀私有成员
  **不进面**；内容指纹 `f2fd1b0eacf665f2`）+ `docs/API_FREEZE.md`（口径表 / 统计 / 语义化
  变更政策 / 签署六勾 / 例外登记 / 124 行全量明细）。两者均由 `scripts/gen_api_freeze.py`
  生成，**禁止手改**
- **API 冻结门禁** `scripts/check_api_freeze.py`：现网面 vs 清单**逐成员**比对，结果分三桶
  ——破坏性（删类型 / 改签名 / 移模块 / 改 a11y）/ 增量（新类型 / 新公共成员）/ 纪律
  （`on*` 前缀、基类成员撞名、qmldir `//`、版本非 1.0、文件名不符、缺 `pragma Singleton`、
  `Component.onDestroyed`）；另校验**清单指纹自洽**（手改清单绕过门禁也会红）
- **qmllint 门禁** `scripts/check_qmllint.py`：error **零容忍** + warning **分类预算制**
  （`tests/lint-baseline.json`：unqualified 552 / missing-property 24 / 其他 10 /
  id-shadows-member 4 / property-override 2 / import 1，共 593），`--update` 只允许下调
- **交付前串跑三道门禁**：`local_deploy.py` 新增第 0 步——`check_a11y` → `check_api_freeze`
  → `check_qmllint`，任一红即拒绝出包（`--no-gates` 仅限应急）
- **废弃机制落地**（第 13 章政策 4 的运行时载体）：`NovaUtils.logOnce(key, msg)` +
  `NovaUtils.deprecate(type, api, replacement, removedIn)`——同一 key 只播一次，不刷屏、
  不污染绑定

### Fixed（冻结审查抓出的真实缺陷，静态门禁与逐文件审阅交叉命中）

- **NovaColorPicker**：HEX 输入框底色写 `NovaTheme.background`——该令牌**不存在**（主题令牌
  为 `page`/`surface`/`surfaceAlt`），赋值 undefined 导致输入框底色丢失 → 改 `NovaTheme.surface`；
  焦点边框写 `root.tint`——该组件无 `tint` 属性（非 NovaField 派生）→ 改
  `hasError ? negative : primary`（并保留未聚焦时的 `outline`）
- **NovaText**：`readonly property var style` **覆盖了 `Text.style` 枚举**（基类成员撞名，
  outline/stroke 渲染语义被吃掉）→ 更名私有 `_style`，`Text.style` 原生语义归还
- **examples/gallery**：同款幽灵令牌 `NovaTheme.background` 2 处 → `surface`

### 变更政策（1.0 起生效，宪法第 13 章）

| 变更 | 版本动作 | 门禁 |
|---|---|---|
| 删类型 / 改签名 / 移模块 / 改 a11y 分类 | 仅 major | 红，须重签清单 |
| 新增类型 / 新增公共成员 | minor + 重签 | 红，重签后绿 |
| 私有成员 / 默认值 / 内部结构 | patch | 绿，不重签 |

### 坑位沉淀（50~51）

- **50**：`qmllint` 的诊断**全部写到 stderr**（stdout 只有源码片段），用 `capture_output`
  只读 stdout 会得到「0 warning」的假绿灯——预算门禁必须合并两股流（`stderr=STDOUT`）
- **51**：解析模块限定类型名（`Nova.Behaviors.NovaMorph`）用 `split(".", 1)` 会切出
  `Behaviors.NovaMorph`——模块名自身带点，**必须 `rsplit(".", 1)`**；同批：qmldir
  `singleton <名> <版本> <文件>` 的版本位比普通行右移一格，正则要按 `singleton` 前缀偏移

### 诚实边界（RC2 待办，与 API 面解耦）

24h 内存长跑 / NVDA 真机回归 / 安装器与代码签名（需平台证书）/ 迁移指南 + LTS 承诺书；
`[unqualified]` 552 条按预算挂账（根治需全库 `pragma ComponentBehavior: Bound`）；
应用包 185.7MB 未达 ≤60MB（Qt 运行时物理下限）。

## [0.16.2] - 2026-11-23

### Added（五期 Sprint B3 收口 · **工程化外环**：测试 394 → 427、类型 124 不变）

- **视觉回归门禁**（`tests/test_visual.py` + `scripts/check_visual.py`）：**明/暗 × 5 断点
  （xs=480/sm=800/md=1200/lg=1600/xl=1920）× 全画廊 24 页 = 240 张基线**（256 色量化 PNG，
  12MB）；diff 口径单通道差 >12 / 占比 >1%（容忍反走样 + 量化噪声）；默认全量只跑 smoke
  抽检（秒级），全矩阵由 CLI `--visual-full` 承载（~150s）
- **画廊在线预览页**（docs/GALLERY.md + 24 张真实离屏渲染截图）：QML 无法浏览器运行的
  "在线示例"等价呈现（视觉回归基线集抽帧）
- **外部输入消毒**（供应链门禁，对标 Quasar 2.32~2.35 安全硬化）：
  - `NovaUtils.sanitize` 组（escapeHtml / stripControlChars / sanitizeUrl / clampLength /
    safeText 组合拳）——注入面裁定：Text 默认 AutoText 会把含 HTML 字符串按富文本解析
    （RichText 走 QTextDocument 可外联资源）
  - `NovaRuntime.sanitizeText/escapeHtml/stripControlChars/sanitizeUrl` Python 侧 Slot
    （语义 1:1，供 MCP/CLI/存储回读路径）
  - **组件加固 9 处**：NovaNotificationItem ×4 / NovaDialogCard ×3 / NovaLoadingOverlay /
    NovaTooltip 文案 Text 显式 `textFormat: Text.PlainText`
  - `tests/test_sanitize.py` 32 项（XSS 样本 / ANSI 转义 / 零宽字符 / scheme 白名单
    javascript:data:vbscript: / 长度钳制 / Python 镜像 / 组件静态门禁）
- **CycloneDX SBOM + CVE 周巡**：`scripts/gen_sbom.py`（零第三方依赖离线生成，许可证逐包
  读取）+ `scripts/check_cve.py`（OSV.dev querybatch 联网查询 / --offline 缓存 /
  --fail-on 阈值入 CI / `.cve-ignore` 忽略清单带理由）；首轮巡检 3 组件 0 未忽略漏洞
  （pytest 2 项 dev-only 漏洞经评估登记不随运行时分发）
- **一键应用打包**：`scripts/build_app.py`（PyInstaller onefile，gallery_launch.py 入口）+
  `examples/gallery_launch.py`（打包后从 sys._MEIPASS 解析 QML 资源）；Linux 产物
  `dist/nova-gallery`（185.7MB，PySide6 全运行时物理下限）**启动自检通过**；
  uv venv（shared python）构建路径与 Windows exe / 代码签名边界已记录
- **MkDocs 文档站**（可搜索 + 在线示例，material 主题明暗切换）：15 页 / 搜索索引 /
  全画廊预览页；`mkdocs.yml` + `docs/index.md` 首页；构建 1.3s / 产物 4.9MB

### 坑位沉淀（49）

- **49**：全矩阵视觉长跑（240 截图 × 150s）后解释器收尾期 GC 触发 shiboken refcount 崩溃
  （`none_dealloc`，deleteLater / 显式 close / gc.collect 均无效）→
  `pytest_unconfigure` 中硬退出（报告已输出完成，保 CI 退出码语义）

## [0.16.1] - 2026-11-23

### Added（五期 Sprint B 第二交付单元 · **i18n + RTL + 性能 + HiDPI 非功能攻坚**：类型 123 → 124、测试 343 → 394）

- **NovaI18n 服务单例**（Nova.Services，第 124 个公共类型；对标 Quasar Lang 插件 `$q.lang` +
  vue-i18n 语义）：`locale/setLocale()` 全局切换、`t()` 词典翻译（`{name}` 插值；三级回落链
  locale 精确 → 主语言码前缀 → en-US → key 本身）、`tp()` CLDR 复数（JS 精简实现七语系：
  zh/ja/ko/th/vi 恒 other、en/de one-other、ru one-few-many、ar 六类别、cs/sk、pl）、
  `addBundle()/addPluralBundle()` 运行时热注入（幂等覆盖）、`formatNumber/formatCurrency`
  （分隔符/货币符号表随 locale）、`formatDate`（命名样式 + 自定义 pattern，
  `Qt.locale(name).toString` 渲染）、`formatRelative`（复数联动）
- **RTL 镜像双轨适配**：`NovaTheme.isRtl/direction` 方向令牌（随 NovaI18n 联动）；
  `NovaPagination`（LayoutMirroring + 箭头字符取反）、`NovaDrawer`/`NovaLayout`
  （`effectiveSide` 逻辑侧换边）、`NovaSlideItem`（loader 镜像 + Left/Right 物理键互换）、
  `NovaBreadcrumbs`（反排重布局）、`NovaStepperNavigation`（LayoutMirroring）；
  **逻辑侧 API 语义恒定**——RTL 只换物理方向，不换语义
- **性能门禁三指标**（`tests/test_perf.py` 3 项 + `scripts/check_perf.py` CLI 包装）：
  冷启动 ≤800ms、全导出类型实例化 ≤5ms/个（预热后两遍测量 + KNOWN_HEAVY 白名单）、
  1000 行 NovaTable 挂载 ≤1700ms
- **HiDPI 门禁**（`tests/test_hidpi.py` 4 项）：QT_SCALE_FACTOR 1.0/1.5/2.0 矩阵下
  devicePixelRatio 联动、逻辑几何恒定；Nova.Runtime 上报 `devicePixelRatio/scaleFactor`
- **a11y 补差**（M2 清单）：`NovaTree` 方向键游标（roving cursor：Up/Down 移动、
  Right 展开 / Left 收起、收起态跳父、环绕式移动；RTL 时 Left/Right 语义互换）；
  `NovaDialogShell` WAI-ARIA 焦点陷阱（打开记录来源焦点并聚焦首项、Tab/Shift+Tab 循环困于
  陷阱内、关闭还焦来源；runtime 应用级事件过滤器承载 Tab 拦截——QML Keys 层收不到 Tab）
- **画廊第 24 页「国际化 i18n」**：locale 切换按钮组、t/tp/复数类别实时联动、
  数字/货币/日期/相对时间格式化、RTL 镜像演示（含 de/ja/ru/ar 四语热注入词典示范）
- **`docs/I18N.md`** 国际化指南（API 一览/词典回落链/复数规则表/RTL 双轨/坑位 43）

### Fixed

- `qrc://` 双斜杠 URL 经 shiboken 解析为带 authority 的路径，`QQmlComponent.setData` 间歇性
  SIGSEGV——**全局替换为 `qrc:/` 单斜杠**（独立脚本/pytest 交错崩溃的总根因，坑位 48 前因）

### 坑位沉淀（43~48，详见 docs/SESSION_HANDOFF.md）

- **43**：Qt 6.12 `Qt.formatDate` 三参重载不存在（pattern 被丢弃）→ `Qt.locale(name).toString(date, pattern)`
- **44**：QQmlExpression + creationContext 对非 Item 对象间歇 SIGSEGV → QML 内定义 helper + Python 直调
- **45**：Tab 在 QQuickItem::keyPressEvent C++ 默认实现被消费不冒泡（Keys.BeforeItem 也拦不到）
  → 应用级事件过滤器；PySide slot 的 QObject 参数 wrapper 是临时的（须强引用）；
  `Item.window` 普通属性 JS 层 undefined → attached `Item.Window.window`
- **46**：QML 函数从 wrapper 调用返回未求值 MetaFunction → 改 `readonly property int` 承载
- **47**：性能测量须两遍法（首建含 QML 编译冷缓存）；NovaDate/NovaEditor 首建 11~15ms 属固有成本
- **48**：干净引擎早期 setData 组件 SIGSEGV（实为坑位 qrc:// 双斜杠）→ 全局 `qrc:/` 单斜杠 + 探针纪律

## [0.16.0] - 2026-11-23

### Added（五期 Sprint B 第一交付单元 · **可访问性攻坚 WCAG 2.1 AA**：类型 120 → 123、测试 322 → 343）

- **NovaA11y 单例**（Nova.Design，第 123 个公共类型）：WCAG 2.1 对比度数学（相对亮度/对比度/
  大小文本判定/AA·AAA·UI 三档门禁）、**AA 兜底派生**（`aaText` 双向取最小位移、`aaFill` 单向压暗
  保品牌色相，二分 22 次收敛）、focus-visible 裁决 `ringVisible()`、状态播报状态机
  `notice()/announcementCount`、语义词汇表。Quasar 2.35.5 无对应模块——Nova 差异化能力
- **NovaFocusRing 行为**（Nova.Behaviors）：键盘模态下为宿主画焦点环（外扩 offset、间隙露表面色、
  填充态按钮上不撞色）；只画不拦事，无指针通道
- **NovaLiveRegion**（Nova.Behaviors）：`NovaA11y.notice()` 的真正播报出口
  （WCAG 4.1.3 Status Messages），宿主根节点放一个即可
- **Nova.Runtime 输入模态**：应用级事件过滤器（`install_input_modality_filter`，随 `init_nova` 幂等安装）
  维护 `keyboardMode`，KeyPress→true / 鼠标·触摸·滚轮→false；QML 侧经 `NovaA11y.keyboardMode` 读取
- **NovaTheme a11y 令牌**：`a11yBase`（最不利表面，派生基准）、`focusRing` + `focusRingWidth/Offset`、
  `outlineStrong`（1.4.11 控件边界 3:1）、`primaryText…infoText` 七个文字安全版、`fillTint()`、
  `textMuted` AA 化
- **123 个导出类型 100% 登记 a11y 契约**：interactive **32**（role + 可读名 + 键盘入口 + 按键路径 +
  焦点环全齐）/ semantic **28** / decorative **63**（故意不挂 Accessible + `// a11y: decorative` 标记）；
  32 个 interactive 全量补齐键盘路径（Enter/Space 激活、方向键组内导航与值步进、Home/End、
  PageUp/Down 月步进、Esc 关闭归位、Delete 移除）；统一新增 `a11yLabel` 可读名覆盖属性
- **`scripts/check_a11y.py`** 静态门禁：解析四个 qmldir × 契约表，逐类型核对 role/name/键盘/焦点环/
  装饰标记，未登记类型直接报错；`--matrix` 生成 `docs/A11Y_MATRIX.md`；退出码可直接入 CI
- **`tests/test_a11y.py` 21 项**：WCAG 数学（黑白 21:1/对称/亮度边界）、AA 派生最小性与色相保持、
  9 文本令牌 × 3 表面 × 明暗双主题全过 4.5:1、边界与焦点环 3:1、QAccessible 运行时角色矩阵
  （19 类型 role/name/disabled 逐项）、键盘激活/切换/翻页/行游标/标签切换/时间步进、焦点环
  键盘可见·指针隐藏、播报计数、静态门禁自检、画廊 a11y 页实例化无运行时错误
- **画廊第 23 页「无障碍 a11y」**：AA 派生色板（本色 vs AA 版实时对比度）、焦点环 Tab 走查、
  键盘全路径演示、播报演示、契约矩阵与门禁命令

### Changed

- `NovaTheme.textMuted` 改为 AA 兜底派生：浅色在 page 上由 **4.31 → 4.50**（`#6E7380 → #6B707C`，
  肉眼无差；暗色不变）
- 填充态按钮底色经 `fillTint()` 压到白字 **4.50:1**（`#5B6EF5 → #576AEB`，色相不变）
- 新增 `outlineStrong` 作为**可交互控件**边界（3:1）；`outline` 保留给装饰性分隔线（1.4.11 只约束
  控件边界，不是所有线条）
- `NovaChip/NovaItem/NovaTab/NovaFabAction/NovaBtnDropdown` 等按 `!disable` 映射 `enabled`，
  使 Qt 无障碍接口能上报 disabled 状态（视觉不变）

### Fixed

- `NovaUtils.colors.luminosity/brightness` 传 QML `color` 值（r/g/b 为 0~1 浮点）时被按 0~255 处理，
  对比度恒为 **1.0**——新增 `_channels255` 归一化（字符串路径不变）；a11y 派生必须能直接吃 color 值
- `Accessible.announce()` 在单例/`Connections` 作用域调用报 *"must be attached to an object deriving
  from Item or Action"* → 播报下沉到 `NovaLiveRegion.speak()`

### Refactor（测试基建）

- 新增 `tests/conftest.py`：**全测试进程共用「一个 QGuiApplication + 一个 QQmlEngine」**，
  模块收尾只关闭窗口不析构引擎；`test_smoke` / `test_a11y` 的 `qml_engine` / `engine` 夹具改为复用。
  原因见坑位 42——多引擎「一个销毁、另一个继续建组件」在 Qt 6.12 下会间歇 SIGSEGV
  （343 项实测 20~60% 概率崩在 `component.create()`，与用例内容无关）；单引擎后连跑 10 次全绿

### Pitfalls（坑位 38~42）

38. `Accessible` 是附加属性，只能在 Item 作用域内调用——单例（QtObject）与 `Connections` 里都不行
39. `Accessible` **没有** `disabled`/`defaultAction`/`ignoresAutomaticName`；禁用态唯一有效途径是
    `Item.enabled: false`（实测 `QAccessible` 接口随之 `state().disabled = true`）
40. `Keys.onEndPressed` 不存在（Qt 6.12）——`End` 走 `Keys.onPressed` + `ev.key === Qt.Key_End`
41. `QTest` 键位测试必须同时强引用 `QQmlComponent`：组件 GC 后其创建出的 Window 立即析构
    （*Internal C++ object already deleted*）
42. **多个 `QQmlEngine` 各自析构会在 Qt 6.12 引发间歇 SIGSEGV**：A 引擎销毁后 B 引擎再
    `component.create()` 有 20~60% 概率崩（与用例内容无关，纯引擎数量相关）→ QML 测试全进程
    共用单引擎（`tests/conftest.py`），模块收尾只 close 窗口、不删引擎；另：Window 活到解释器
    退出而 `QGuiApplication` 已析构是第二类退出期崩溃，靠 session 收尾统一释放规避

## [0.15.0] - 2026-11-23

### Added（五期 Sprint A · **长尾组件一次收口**：Controls 89 → 91、Behaviors 10 → 11 + 新 singleton）

- **NovaEditor**（对标 QEditor）：toolbar 分组配置（数组的数组，组间 separator）、execCmd 命令族
  （bold/italic/underline/strike 行内包裹、h1~h6/quote/code/ul/ol 行前缀、link、removeFormat、
  undo/redo）、modelValue 受控 + updateModelValue 上报（NovaInput 同款 guard 防回环）、
  selectRange/caretPosition 辅助、toHtml() HTML 导出（结构前缀在原始行上判断切片、内容单独转义）、
  placeholder/flat/minHeight/readonly/disable、buttonCount 派生。
  **实现口径留痕**：QEditor 基于 DOM contenteditable，QML TextEdit 无富文本选区格式化 API——
  Nova 以「轻量标记编辑器 + HTML 导出」实现同语义（toolbar 配置/execCmd/modelValue 契约 1:1）
- **NovaSlideItem**（对标 QSlideItem）：正面 default 槽左右拖拽跟手（死区防抖 + clamp）、
  leftSlot/rightSlot Component 动作面板（QSlideItem 的 left/right 撞 Item FINAL 成员改名，
  坑位 12）、释放越 openThreshold 吸附（Behavior OutCubic）、slideLeft/slideRight/reset 命令式
  API、slideOpened(side)/slideClosed/leftAction/rightAction 事件、dense/revealWidth/duration
- **NovaMorph**（对标 v-morph 指令 · Behaviors 族）：group 组内元素形变切换——morph() 时旧活动
  元素退出、ghost 影子从旧几何动画至新几何（跨父级 mapFromItem 映射）、新元素延至动画完成显示；
  morphStarted/morphFinished 信号、isActive() 命令式判定、duration=0 快路径。
  **NovaMorphPool 单例注册表**：group → 当前活动目标 Item；曾用 .pragma library JS 共享注册表
  实测呈现 per-importing-file 实例化（同组两实例互相看不见对方注册）→ 改 QML singleton
  （Services 模块同款惯例）保证引擎级唯一（0.15.0 新沉淀）
- **NovaIconGenie**（对标 @quasar/icongenie，`scripts/gen_icons.py`）：单图生成全套应用图标——
  favicon ×4 + apple-touch ×6 + android ×7 + iOS AppIcon 全档 + 可选 splash ×6（37 产物），
  --background/--padding/--splash、居中缩放合成、icongenie-report.json 产物清单（源图指纹）
- **AI-ready 文档包**（对标 Quasar 2.33 "AI-ready out of the box"，`scripts/gen_apidocs.py`）：
  扫描 qmldir + QML 源生成 `docs/ai/api/*.json`（每公共类型 props/signals/methods/描述 + 行内注释）
  + `docs/ai/pages/`（10 页核心文档离线拷贝）+ `docs/ai/index.json`（版本 + 基线 + 模块计数 +
  内容指纹）——AI agent 从此查询 Nova **版本化 API** 而非依赖训练记忆
- **Nova MCP server**（对标 @quasar/mcp v1.0.0，`scripts/nova_mcp.py`）：stdio JSON-RPC 2.0
  （MCP 换行分隔传输），六工具口径 1:1——search_docs / list_pages / get_page（宽松按节截取）/
  list_api / get_api（带前缀自动宽松匹配）/ check_updates（离线版本+指纹报告）；仅标准库、
  零网络零依赖；"built for small context windows" 口径——search 返回命中摘要、get_page 支持单节
- 画廊第 22 页"长尾组件"（Editor 实时 HTML 导出 / SlideItem 左右滑动 / Morph 卡片⇄详情形变 /
  IconGenie 与 MCP CLI 演示）

### Fixed

- NovaEditor toHtml 结构前缀判断误用转义后文本（"> " 已变 "&gt; " 永不命中）→ 原始行上判结构、
  内容单独转义（切片错位同源修复）

### Changed

- 类型总面：**120 个公共类型**（Controls 91 + Services 15 + Design 3 + Behaviors 11）
- 测试 308 → **322 项全绿**（7 冒烟 + 7 行为：Editor 命令链与 HTML 导出/工具栏按钮计数、
  SlideItem 开合事件链与跟手位移、Morph 零时长切换与 ghost 动画路径、IconGenie CLI 产物尺寸
  与 splash 拒绝守卫、MCP server 六工具 subprocess 全链路）

## [0.14.0] - 2026-11-23

### Added（四期 Sprint B · **弹层与反馈一次收口**：L2 54% → 68%，Controls 73 → 89、Services 10 → 11）

- **NovaMenu**（对标 QMenu）：target 触发（左键/右键 contextMenu）、auto-close（动态挂接子项 clicked）、
  persistent 锁 ESC+外部点击、fit/cover、anchor/self/offset 定位（clamp 宿主范围）、hover 契约、
  show/hide/toggle/updatePosition/focus、进 NovaOverlayHost 弹层栈（ESC 逐层关闭口径）
- **NovaDialogShell**（对标 QDialog 组件壳；Services 单例同名 → Nova 命名红线改名留痕）：声明式遮罩+卡片、
  persistent/no-esc-dismiss/no-backdrop-dismiss、seamless/maximized/fullWidth/fullHeight、五向 position、
  **关闭原因上报 dismissed(reason)**（ok/cancel/backdrop/escape/api，基线 2.28 真 parity）、
  persistent 拒关 shake 动效（shake 事件）
- **NovaPopupProxy**（对标 QPopupProxy）：断点路由（窗口宽/高较小者 < breakpoint → Dialog 形态，否则 Menu 形态）、
  内容槽共享（reparent 迁移/归还）
- **NovaTooltip**（对标 QTooltip）：悬停 target + delay/hideDelay、anchor/self/offset（默认 [14,14]）、
  text 便捷属性或 default 槽、就地渲染 z 提升
- **NovaBottomSheet**（对标 BottomSheet 插件组件壳）：actions 数组（列表/grid 网格）+ default 槽、
  遮罩/ESC 关闭、actionPicked + **dismissed(reason) 关闭原因上报**
- **NovaSpinner**（对标 QSpinner 系列）：variant 八变体 ring/ball/dots/hourglass/gears/grid/radio/comment，
  Canvas 统一相位驱动（坑位 28 显式失效口径）
- **NovaSkeleton**（对标 QSkeleton）：type（rect/text/circle/square/badge/tag）× animation（wave/bounce/fade/none）
  × animationSpeed、size/width/height/square/bordered
- **NovaInnerLoading**（对标 QInnerLoading）：showing、半透明蒙层 + Spinner、default 槽替换、label
- **NovaAjaxBar**（对标 QAjaxBar）：start/increment/stop + **多进程计数**（N start 需 N stop）、
  渐进模拟（越接近 progressCap 越慢）、stop 冲刺收尾、四向 position/reverse、started/stopped 事件
- **NovaLoadingBar 服务单例**（对标 LoadingBar 插件）：命令式 start/increment/stop，懒创建 AjaxBar 挂
  NovaOverlayHost（zTop 层），无窗口降级 no-op
- **NovaBanner / NovaBar**（对标 QBanner/QBar）：三槽横幅（avatar/content/action、inline-actions/dense/rounded）、
  顶栏（dense、primary 底色文字反转）
- **NovaNoSsr**（对标 QNoSsr）：placeholder 文案/槽 → delay（默认下一帧）后切换内容
- **NovaPullToRefresh**（对标 QPullToRefresh · side 四边对标 2.30）：top/bottom/left/right 四向拉动、
  threshold 阈值、refresh 事件、refreshing 受控、trigger() 方法
- **NovaResizeObserver**（对标 QResizeObserver）：target（默认声明父项）尺寸变化 debounce → resize(w,h)
  （NovaScrollObserver 已于 Behaviors 0.7.0 交付——本轮发现规划核对口径：不重复交付）
- 画廊第 21 页"弹层与反馈"（全类型实机演示 + 关闭原因实时展示）

### Fixed

- NovaMenu auto-close 初版 TapHandler 被子项 MouseArea 独占饿死 → 动态挂接子项 clicked 信号（坑位 35）

### Changed

- 类型总面：**117 个公共类型**（Controls 89 + Services 单例 11 + Design 3 + Behaviors 10 + 句柄动作 4）
- 测试 271 → **308 项全绿**（29 冒烟 + 9 行为：菜单 auto-close/弹层栈逐层 ESC/关闭原因上报/persistent
  shake/BottomSheet 动作回报/AjaxBar 多进程计数/PTR trigger 复位/观察器/BtnGroup 样式下发/服务降级 no-op）

## [0.13.0] - 2026-11-23

### Added（四期 Sprint A · **导航体系 14 类型一次收口**：L2 43% → 54%，Controls 59 → 73）

- **NovaTabs / NovaTab**（对标 QTabs/QTab）：受控 modelValue（Tab 点击只 emit，宿主写回——
  坑位 22 契约）；横向溢出滚动 + 溢出箭头（outside-arrows 占位 / mobile-arrows 强制）、
  align（left/center/right/justify）、breakpoint 自动 justify（默认 600）、垂直模式、
  指示条（narrow-indicator 内容宽 / switch-indicator 换侧）、dense、active-color→activeTint /
  active-bg-color / indicator-color、left/right-icon；NovaTab：name/label/icon/alert
  （true→红点 | 字符串→徽标）/alert-icon/no-caps（font.capitalization 实现）+ default 槽
- **NovaTabPanels / NovaTabPanel**（对标 QTabPanels/QTabPanel）：受控 modelValue、
  animated/infinite/swipeable（DragHandler 被动抓取）/vertical/transitionDuration；
  next/previous/goTo（name 或 index，禁用面板自动跳过）；beforeTransition/transition 事件；
  与 NovaTabs 共享宿主变量即可联动（受控契约）
- **NovaBreadcrumbs / NovaBreadcrumbsEl**（对标 QBreadcrumbs/QBreadcrumbsEl）：
  条目间自动插分隔符（separator 文本 / separatorDelegate 自定义模板）、separator-color、
  gutter 五档（none/xs/sm/md/lg/xl→0/4/8/16/24/48）、align 三档；**activeColor 语义
  1:1 对标 2.35.6 源码（QBreadcrumbs.js）**——作用于「中间的、未禁用」条目，
  最后一个（当前页）不着色；El：label/icon/disable/click + default 槽
- **NovaStepper / NovaStep / NovaStepperNavigation**（对标 QStepper/QStep/QStepperNavigation）：
  受控 modelValue、头部导航（总开关 headerNav × 逐步骤 headerNav × disable）、
  **状态图标解析 1:1 对标 2.35.6 StepHeader.js**——active > error > done 优先级、
  step 级 icon/color 覆盖 stepper 级、'none' 退让 prefix→icon/inactiveIcon、
  命名色映射（primary/secondary/…→NovaTheme 令牌）；垂直模式（contracted 只画圆点）、
  flat/bordered、alternative-labels、infinite、next/previous/goTo（禁用步骤跳过）；
  navigation 命名槽（NovaStepperNavigation 容器）+ message 槽（Component 模板）
- **NovaExpansionItem**（对标 QExpansionItem）：header（icon/label/caption 或 header 命名槽）+
  高度动画展开内容；**group 手风琴**（ExpansionGroups.js 注册表互斥收起——被收起方
  走自身 updateModelValue(false) 受控上报）；show/beforeShow/shown/beforeHide/hidden/
  afterShow/afterHide 全事件（show/hide 与 QML 内建语义撞名规避，坑位 25 口径）、
  show()/hide()/toggle() 方法；switch-toggle-side / expand-icon-toggle / dense-toggle /
  hide-expand-icon / expand-separator / popup / label·caption-lines / inset-level 系
- **NovaToolbar / NovaToolbarTitle**（对标 QToolbar/QToolbarTitle）：inset 缩进、
  min-height 50（$toolbar-min-height 1:1）；Title 默认撑满、shrink 收缩为内容宽
- **NovaFab / NovaFabAction**（对标 QFab/QFabAction）：direction 四向展开、
  **stagger 级联动画**（逐动作 Timer delay=idx×stagger，坑位 19 显式 start）、
  **hover 打开契约**（hoverDelay 进入延迟 / hoverHideDelay 离场宽限，命中区覆盖动作外溢范围）、
  external-label / label-position / vertical-actions-align / square、icon↔active-icon 旋转切换；
  受控 modelValue(bool) + updateModelValue + beforeShow/shown/beforeHide/hidden + show/hide/toggle；
  NovaFabAction：icon/label/tint/textColor/square/anchor/disable + clicked 信号 + click() 方法
- 画廊新增第 20 页「导航体系」（20 页）：Tabs+Panels 受控联动（禁用页跳过/alert 徽标）/
  Breadcrumbs 双形态 / Stepper 水平（navigation 槽上下步按钮）+垂直 contracted /
  ExpansionItem 手风琴 / Toolbar / Fab 向上级联
- 测试 250 → **271**：14 类型实例化冒烟 + 行为用例 7 个
  （Tabs 受控与禁用页 / Panels 联动+名称寻址+禁用跳过+过渡事件 / Stepper 序号寻址+
  禁用跳过+事件 / ExpansionItem 同组互斥异组不扰 / Fab 级联延迟与 Timer 显式启动 /
  Breadcrumbs 分隔符计数+点击+激活色语义 / 环境复检）

### Changed

- 基线复核：Quasar 2.35.5 → **2.35.6**（dist/api/*.json 逐文件 diff 零漂移，纯补丁版；
  基线维持 2.35.5 口径，审计仍逐项标注）
- 版本贴/概览页同步 0.13.0（Gallery 0.13.0；概览口径改"100 个公共类型"）
- 坑位 24/28 再验证：NovaStepper 状态色/图标经函数计算——绑定侧直读依赖
  （st.* + currentIndex）强制重评后调函数；派生步骤集合 _steps 平铺属性 + _rev 显式失效

### 固定（坑位沉淀）

- **33**：QML `Item` 无 `Component.onDestroyed`——析构钩子是 **`Component.onDestruction`**
  （NovaExpansionItem 组注销曾因此整文件加载失败）
- **34**：Text/Item 级基元元素**没有 `background` 属性**（那是 Control 系 API）——
  徽标底色须手写包裹 Rectangle
- 布尔型 JS `join(',')` 产出小写 `true/false`——测试断言须小写口径

## [0.12.0] - 2026-11-23

### Added（三期 Sprint B · **媒体体系十类型 + Table 增强一次收口**：L2 34% → 43%，Controls 49 → 59）

- **NovaImg**（对标 QImg）：占位图/错误图/延时转圈三态（loadingShowDelay 防缓存闪 spinner）、
  ratio/initial-ratio 宽高比派生、fit 五模式 + position 方位、alt→Accessible.name、
  slots：default 覆盖内容 / loadingSlot / errorSlot；**占位与错误图分层叠加**，
  规避 source↔status 互相依赖的绑定环
- **NovaResponsive**（对标 QResponsive）：ratio 等比容器（useRatio 语义 1:1，非法值视为无比例）
- **NovaVideo**（对标 QVideo）：QtMultimedia Video 皮肤化包装，ratio 默认 16/9，
  title→无障碍语义；**播放器惰性创建**——src 为空不实例化（坑位 31：
  无音频服务环境 FFmpeg 音频初始化挂死，空源本就只显示提示）
- **NovaParallax**（对标 QParallax）：媒体层随宿主滚动按 speed 因子慢速位移（progress 0→1），
  scroll-target 缺省向上遍历找最近 Flickable（坑位 14 语义）、refresh() 重测、
  scrolled({progress, contentY}) 事件、mediaSlot 作用域槽
- **NovaCarousel**（对标 QCarousel，受控 modelValue）：arrows / navigation（四向停靠）/
  navigation-icon / thumbnails 缩略图 / autoplay（数字 ms、true→5000、负数反向、到末页停）/
  infinite 回绕 / swipeable（**DragHandler 被动抓取**，不吞子内容点击）/ vertical / padding /
  transitionDuration；next/previous/goTo（name 或 index，禁用页自动跳过）；
  **NovaCarouselSlide**（name/disable/img-src 快速图片页）+ **NovaCarouselControl**
  （position/offset 覆盖控件，声明于轮播内部自动挂载覆盖层——坑位 14 向上遍历）
- **NovaTimeline / NovaTimelineEntry**（对标 QTimeline 族）：tint 轴色 / side 左右停靠 /
  dense·comfortable·loose 三布局；条目 heading 标题态 / icon·avatar 轴点 / title·subtitle·body
  + titleSlot/subtitleSlot 命名槽；轴连线条目自绘（延伸进 spacing 覆盖间隙，loose 左右交替成立）
- **NovaChatMessage**（对标 QChatMessage）：sent 收发镜像 / label 分组标签 / tint 气泡色 /
  name / avatar / text（字符串或数组→多条气泡）/ stamp（仅尾条）/ size 1~12 栅格宽；
  slots：default 正文 / avatarSlot / nameSlot / stampSlot / labelSlot
- **NovaTable 增强**（v0.12.0 承诺项）：**虚拟滚动**（virtualScroll + virtualScrollItemSize，
  表体切 ListView 真虚拟化、行结构 inline component 复用、表头独立常驻=天然粘性、scrollTo）；
  **服务端模式**（serverSide + rowsNumber + request 信号 {pagination, filter} +
  requestServerInteraction()/setPagination()/firstPage()，排序/过滤触发请求页码重置为 1）；
  **loading 覆盖层 + loadingLabel + noDataLabel**
- 画廊新增第 19 页「媒体体系」（19 页）：Img 三态 / Responsive / Video / Parallax 视差实机 /
  Carousel 全家桶实机（自动轮播+覆盖控件计数）/ Timeline / ChatMessage 收发对话 /
  虚拟表 1000 行 / 服务端表 137 条模拟取数（内联 SVG data URL 作离线图源）

### Changed

- 版本贴/概览页同步 0.12.0（Gallery 0.12.0；概览口径改"86 个公共类型"）
- NovaCarousel/NovaTable 暴露诊断只读位（controlLayerItem / autoRunning /
  virtualRowCount / virtualContentY / virtualContentHeight）

### 固定（坑位沉淀）

- **29**：inline component 裸名赋给 `delegate:`（如 `delegate: TableRow`）在 Qt 6.12 下
  **恒 count 0** 且零报错——必须带花括号实例化 `delegate: TableRow { }`
- **30**：创建期可见性求值时序会让 Column 定位器错过自动布局（委托 implicitHeight 恒 0），
  显式绑定 `height: childrenRect.height` 兜底（子项高度不依赖父高，无环）
- **31**：QtMultimedia `Video` 元素创建即初始化 FFmpeg 音频上下文，无音频服务环境（CI/沙箱）
  **进程挂死**——播放器必须按 src 惰性创建
- NovaImg 占位/错误图若走"source 随 status 切换"会成 source↔status 绑定环——改分层叠加
  （主图常驻 + 占位/错误图层按态覆盖）
- **32**：`ListView` 的 `reuseItems: true` 与含 NovaTr 的自定义 delegate 组合，在 Qt 6.12
  触发**进程退出段错误**（tests media_table_virtual 定位；包装 Component 亦不能规避）——
  NovaTable 虚拟滚动暂缓 reuseItems，cacheBuffer 预取兜底；0.11 的 NovaVirtualScroll
  （普通 Rectangle delegate）不受影响
- 坑位 28 再验证：函数调用绑定依赖不可靠在 `columns.map()`/`_flick` 探测场景重现——
  派生数据变更点一律走显式信号/句柄（onChildrenChanged/onScrollTargetChanged/onFilterChanged）

## [0.11.0] - 2026-11-23

### Added（三期 Sprint A · **数据体系九件 14 类型一次收口**：L2 24% → 34%，Controls 35 → 49）

- **NovaTable + NovaTh/NovaTd/NovaTr**（对标 QTable 基础面）：列定义（对象/字符串归一化）、
  三态排序（无序→升→降→无序，binaryStateSort 两态）、全字段过滤 + filterMethod 自定义、
  客户端分页（rowsPerPage/page/越界钳制）、多选/单选（表头半选态、全选/反选）、
  展开行（rowKey 键控 + expandSlot 上下文 rowData/rowIndex）、grid/flat 模式、
  底部计数与 NovaPagination 集成；**选中一律按键值比较**（坑位 27：Qt6 信号参数深拷贝）
- **NovaTree**（对标 QTree）：递归渲染、nodeKey/路径键双键制、strict 勾选级联
  （子全勾→父自动勾、反勾父→子全清、半选态）/lazy（仅向下联动）/none 三策略、
  懒加载（lazyLoad(node, done) → _resolveLazy 回填重建索引）、过滤保祖先链、
  defaultExpandAll、expandAll/collapseAll、dense
- **NovaPagination**（对标 QPagination）：maxPages 滑窗、ellipses 省略号、
  boundaryLinks 首末快捷（«»）、arrows 前后翻页、requestPage 越界钳制、
  受控 page（pageRequested 上报宿主写回）
- **NovaList / NovaItem / NovaItemSection / NovaItemLabel**（对标 QList/QItem 族）：
  separator 分隔线（NovaList 注入 listRef，最后一条不画）、dense、padding、
  **accordion 手风琴**（展开自动收起兄弟，expandRequested(false) 受控上报）、
  NovaItem 四槽（default/leading/trailing/expandContent——left/top 撞 Item FINAL
  属性改名，坑位 25 同款）、双行/三行布局、NovaItemSection avatar/thumbnail/trailing/topAligned、
  NovaItemLabel overline/caption/header/lines
- **NovaMarkupTable**（对标 QMarkupTable）：columns/rows 数组直渲 + title + dense/flat
- **NovaInfiniteScroll**（对标 QInfiniteScroll）：触底 offset 提前量、load(index, done)
  受控批次、done(true) 停止 / resume() 重新武装、内容不足视口自动补载
- **NovaVirtualScroll**（对标 QVirtualScroll）：items + delegate 组件、内部 ListView
  真虚拟化（reuseItems + cacheBuffer）、scrollToIndex 跳转、统一行高 itemSize
- **NovaScrollArea**（对标 QScrollArea）：内容超界双向滚动 + NovaTheme 明暗跟随滚动条

### Changed

- 画廊新增第 18 页「数据体系」（18 页）；BUILD_INFO/版本贴同步 0.11.0

### 固定（坑位沉淀）

- 27：**Qt6 信号参数会把 JS 对象/数组深拷贝**——组件与宿主之间传递选中行等对象数组时
  引用一致性丢失；选择语义一律按键值（rowKey 或 JSON 全等）比较，勿用 `===`/`indexOf` 引用比较
- 28：**绑定内经函数间接读取的依赖跟踪不可靠 + 递归索引漏层**——NovaTree 的
  `_index` 由 `_buildIndexInto` 生成时只递归 `children` 静态层，懒加载回填层（`_lazyStore`）
  永不入索引；且函数内读 `_lazyStore` 的重赋不触发重评。改为显式失效模式：
  `onNodesChanged/on_LazyStoreChanged/onFilterChanged → _refreshDerived()` + `_rev` 版本号
  供节点渲染绑定引用保刷新

## [0.10.0] - 2026-11-22

### Added（二期 Sprint B · **输入进阶八件一次收口**：L2 16% → 24%，Controls 27 → 35）

- **NovaRange**（对标 QRange 20 props 收口 17）：双值 {min,max}、左右滑块独立步进、
  step 双端量化、minRange/maxRange 间距约束、左/右气泡（left/rightLabelValue）、
  markers/markerLabels、vertical+reverse、点轨道跳最近滑块、changed() 提交信号
- **NovaDate 自研日历**（对标 QDate 23 props 收口 19）：Qt 6 无内置日历——全自研；
  单选/多选(multiple)/区间(range 三态点击 pending→闭合、逆序自动交换)、
  mask 任意格式（mask→正则解析 + formatDate 输出）、firstDayOfWeek、minimal 最小可选、
  options 函数过滤、navigationMin/MaxYearMonth 导航夹取、events 事件点（数组或函数）、
  todayBtn、noUnset、required
- **NovaTime 时钟面盘**（对标 QTime 14 props 收口 12）：Canvas 时/分/秒三面自动递进、
  24h/12h（AM/PM 切换偏移 +12h）、hourOptions/minuteOptions/secondOptions 过滤、
  nowBtn、内部恒 24h 制存储（对标基线）
- **NovaColorPicker**（对标 QColor 16 props 收口 13）：Canvas SV 色域盘（hue 底色 + 双向
  渐变）+ 色相条 + 调色板（palette 18 色）+ HEX 编辑框 + footer 值显示；formatModel hex/rgb；
  无默认值不产出（modelValue null 对标基线语义）；palette 属性因 Item 内建撞名改名 paletteColors
- **NovaOptionGroup**（对标 QOptionGroup 24 props 收口 21）：checkbox/radio/toggle 三型
  Loader 换装（复用七件值语义）、options 归一化（标量/对象 + optionValue/Label/Disable）、
  inline 横排、leftLabel、keepColor、disabled 选项拒选
- **NovaForm**（对标 QForm 5 props 1:1）：递归发现 validate() 能力子件、greedy 全量校验
  （默认短路）、noErrorFocus/noResetFocus、submit()/validate()/resetValidation()、
  validationSuccess/validationFailed 信号
- **NovaBtnToggle**（对标 QBtnToggle 31 props 收口 22）：options 单/多值、clearable 再点
  清空、选中 toggleColor 着色、未选中 outline/flat/push 变体、spread 均分、vertical、
  dense/rounded/size
- **NovaPopupEdit**（对标 QPopupEdit 13 props 收口 11）：点击目标就地弹层、editorData
  编辑槽、autoSave（无按钮，编辑即值）、buttons + labelSet/labelCancel、title、validate；
  set() 写值并关闭、cancel() 发 canceled；shown/hidden 信号（show/hide 因内建撞名改名）
- **画廊第 17 页**：输入进阶页（Range 约束演示/日历+时钟/取色器/选项组+按钮组/
  Form 聚合校验提交/PopupEdit 就地编辑），共 17 页
- **测试 174 → 199 项全绿**（14 条实例化冒烟 + 11 个行为用例：Range 量化约束/日期
  单选·区间·多选·导航夹取·minimal/时钟管道·AM/PM·options/取色 hex·rgb/选项组三型/
  Form 聚合·greedy/按钮组 clearable·多选/PopupEdit 值管道）

### 留痕（PARITY 同步）

- QDate validator/yearsInMonthView/QTime validator+defaultDate/QRange dragOnlyRange 与
  aria 类/QColor rgb·hsl 编辑器与 alpha 通道/QBtnToggle glossy·stack·stretch/QPopupEdit
  cover 覆盖定位、QSlider 家族 NovaKnob/NovaFile/NovaUploader——延后五期或留痕，逐项见
  docs/PARITY.md §Sprint B
- 坑位沉淀 24~26：`_norm` 缓存绑定在信号处理器重评期可返回 undefined（改直接函数调用）；
  `palette`/`show`/`hide` 与 Item 内建成员撞名（改 paletteColors/shown/hidden）；
  site-packages 残留 wheel 旧拷贝会让 pytest 走旧 QML（交付后须 `pip install -e .` 复位）

## [0.9.0] - 2026-11-22

### Added（二期 Sprint A · **表单核心七件一次收口**：L2 10% → 16%，统一契约落地）

- **统一表单契约**：`label / hint / error / readonly / disable / clearable / rules` 贯穿七件，
  对标 Quasar "表单手感"（QField use-field 29 props + use-validate 7 props 逐项对账）
- **NovaField 容器壳**（对标 QField）：浮动 label / 前后缀 / 样式四型（filled/outlined/standout/borderless）
  / dense+rounded+square / counter / loading / clearable / 底行 hint·error·counter 三位；
  **校验引擎**（对标 use-validate）：rules 数组（函数 + 内置字符串规则 required/minlen/maxlen/len/email）、
  lazyRules 失焦激活、reactiveRules、validate()/resetValidation()/validated()
- **NovaInput**（对标 QInput 8 props）：type text/password/number/int/textarea/email/tel/url/search、
  modelModifiers（number/trim/capitalize）、debounce 防抖提交、autogrow 多行自增高、shadowText、
  clearable、maxLength（Nova 增强）、autofocus；值通知走 modelValue 变更信号（对标 update:model-value）
- **NovaSelect**（对标 QSelect 核心子集 24/47）：options 归一化（标量/对象/optionValue·Label·Disable）、
  single/multiple + maxValues 上限、emitValue、displayValue、useInput 键入过滤、noOptionLabel、
  optionsDense/optionsCover、dropdownIcon；disabled 选项拒选；Popup 弹层（Controls）
- **NovaCheckbox**（对标 use-checkbox 18 props）：trueValue/falseValue/indeterminateValue 三态、
  toggleIndeterminate 半选入链（order 0: t→f→i→t / order 1: f→t→i→f）、val 模式、leftLabel、keepColor、
  **visual 插槽**（property Component，NovaToggle 换装复用同一套值语义）
- **NovaRadio**（对标 QRadio 12 props）：val 匹配、组联动受控模式
- **NovaToggle**（对标 QToggle）：轨道+滑块换装、icon/iconColor、复用 checkbox 全部值语义
- **NovaSlider**（对标 use-slider 33 props 收口 26 项）：min/max/step 量化、innerMin/innerMax、
  snap+markers+markerLabels、label 气泡（labelAlways/labelValue）、reverse/vertical、trackSize/thumbSize、
  键盘方向键/Home/End、changed() 提交信号
- **画廊第 16 页**：表单核心页（校验实时报错/样式四型/选择三态/受控模式组联动/滑杆刻度），共 16 页
- **测试 149 → 174 项全绿**（13 条实例化冒烟 + 12 个行为用例：契约校验/清空/防抖/lazyRules/
  选项归一化/多选上限/半选循环/val 模式/radio 组/开关/滑杆量化夹取/垂直步进）
- **local_deploy.py 新增 `--allinone`**：全量交付包一键生成（修复 0.8.0 包内 git 历史滞后 2 提交的
  交付缺陷；--allinone 须在最终提交后运行）

### Changed（语义对齐说明）

- **受控模式（Quasar 1:1）**：NovaCheckbox.toggle()/NovaRadio.select() 只发信号**不写自身 modelValue**，
  写回由宿主完成（对标 v-model 语义，规避 QML 绑定自环）；toggle()/select() 返回下一值便于宿主写回
- NovaSlider 按快照指令从二期 B（v0.10.0）提前至 Sprint A 交付；NovaForm/NovaBtnToggle/NovaPopupEdit/
  NovaOptionGroup 留待 v0.10.0（快照「下一步」清单为准）

### 留痕（PARITY 同步）

- QField standout 颜色参数/labelSlot/bottom-slots 插槽、QInput inputClass/inputStyle、QSelect 23 项
  （chips/虚拟滚动/menu 定制五 props/behavior 等）、QSlider img 类四 props 与 markerLabels-class——
  QML 不适用或二期后续补齐，逐项见 docs/PARITY.md §Sprint A
- 坑位沉淀 21~22：属性通知信号撞名（有 value 属性再声明 signal valueChanged 即报 Duplicate signal
  ——改走属性变更信号）；受控组件禁写自身 modelValue（绑定环）

## [0.8.0] - 2026-11-22

### Added（一期 Sprint 4 · **L0 设计语言 + L5 工具层一次收口**：L0 60% → 100%、L5 0% → 95%）

- **新增 `Nova.Design` 模块**（L0/L5 落位）：`NovaIconSet` / `NovaMotion` / `NovaUtils` 三个单例
- **NovaIconSet 图标集单例**（对标 `$q.iconSet` + IconSet 插件，npm 2.35.5 icon-set/*.js 逐键提取）：
  - **14 套内置图标集全键 1:1**（material-icons/-outlined/-round/-sharp、material-symbols ×3、
    mdi-v7、ionicons-v4、eva-icons、fontawesome-v6、themify、bootstrap-icons、line-awesome；
    mdi-v7 为基准 19 组 100 个语义键；material 系缺 editor.heading1~6/size1~7 共 13 键与基线一致，
    官方标注"可省略，回落 heading/size"）
  - 19 组语义属性直读（type/arrow/chevron/colorPicker/pullToRefresh/carousel/chip/datetime/editor/
    expansionItem/fab/field/pagination/rating/stepper/tabs/table/tree/uploader）+ `get(path, fallback)`
  - `set(obj)` 顶层浅合并 1:1（整组替换语义，与基线 Object.assign 一致）；`use(name)` 切换；
    `register(name, def)` 自定义集以 mdi-v7 全键补底；`available` / `keyPaths` 自检面
  - **provider 注册表**：`registerProvider/unregisterProvider/provider/providerUrl`，svg / ligature
    双通道；内置 15 个 provider 的 CDN 模板全部实测（2026-11-22，HTTP 200）；ionicons v4 类名 →
    v7 SVG 名称映射（md-X→X、ios-X→X-outline）；Eva 补 `-outline` 后缀；Line Awesome 实际分发
    `<name>-solid.svg`；FA6 改名内置 44 条别名表（home→house 等）；**themify 无逐图标 SVG 分发
    （实测 404），留痕需自备本地图标包**
  - **八通道归一化解析器 `resolve()`**（对标 QIcon.parseIcon 全语义）：`img:` / `svguse:`（unsupported
    留痕）/ `ion-*` 平台前缀 / `sym_[ors]_` / libMap 九前缀（mdi-/icon-/fa-/bt-/eva-/iconfont /ti-/bi-/i-）
    / FA 旧式类名（fas fa-home / las la-check）/ SVG path 直出（`&&` 多路径 + `|viewBox` + `@@style@@transform`）
    / `o_ r_ s_` 连字变体 / `set:name` 显式写法 / 非 ASCII 文本走文本通道（emoji 不再撞 CDN 404）
- **NovaIcon 升级**：改走 NovaIconSet.resolve + provider 注册表；渲染三通道 Image(SVG) / Text(连字
  与 emoji) / Shape+PathSvg（path 直出，viewBox 缩放）；本地图标包（NovaTheme.iconLocalRoot）优先
  → provider CDN 回落链路保留
- **NovaMotion 动效令牌单例**（对标 --q-transition-duration/.3s + transitions.sass + animations.sass）：
  时长七令牌（300/150/200/400…）、缓动八令牌（easingStandard=OutCubic 对标
  cubic-bezier(0.215,0.61,0.355,1)）、**15 种预设过渡表**（fade/scale/rotate/slide×4/jump×4/flip×4，
  enter-from 与 leave-to 非对称 1:1）、`speedFactor` 全局调速、`reducedMotion` 无障碍短路（Nova 增强，
  基线只覆盖 .animated）
- **NovaTransition 过渡组件**（Controls）：声明式包住任意内容，show 切换按预设播进场/离场动画；
  entered()/exited() 信号；flip 用 Rotation 轴旋转近似 perspective；reducedMotion 时长归零
- **NovaTheme 排版/高程令牌**：`typeScale` 12 级 1:1（rem×16→px、em 字距→px、Font 枚举字重；
  h1 96/96/-1.5/300 … caption 12/20/0.4/400）、`typeNames`/`textStyle()`、六档字重令牌（$text-weights）；
  `elevation` 0~24 级三层 umbra/penumbra/ambient 几何（QML 无多层 box-shadow，供 MultiEffect 组合）
- **NovaText 排版组件**（对标 text-h1…caption + text-weight-* + text-italic/strike 等）：typography
  12 级、muted/strike/italic/upper；大写小写走 QML 原生 font.capitalization（1:1 text-uppercase/lowercase/capitalize）
- **NovaUtils 工具层单例**（对标 `import { colors, date, format, is, extend, debounce, throttle } from 'quasar'`）：
  - **colors 12 函数 1:1**（rgbToHex/rgbToText/hexToRgb/hsvToRgb/rgbToHsv/textToRgb/lighten/luminosity/
    brightness/blend/changeAlpha + getPaletteColor 因 DOM 不适用留痕）；alpha 一律 0..100 百分制契约；
    changeAlpha 无 alpha 基准 0 等边界 1:1；Nova 增强 `contrastRatio`/`contrastColor`（WCAG 自动选字色）
  - **date 21 函数**：formatDate **44 token 全覆盖**（YYYY…x，序数/ISO 周/时区符号约定 1:1）；
    en-US/zh-CN 语言包内置；addToDate/subtractFromDate（月末日夹取，1/31+1月→2/28）、adjustDate/
    buildDate/startOfDate/endOfDate/getDateDiff/getDayOfYear/getWeekOfYear（纯 ISO）/getISOWeekYear/
    getDayOfWeek/isBetweenDates（opts 对象 1:1 + `'[]' '[)' '(]' '()'` 字符串写法为 Nova 增强）/
    isSameDate/daysInMonth/getMaxDate/getMinDate/getDateBetween/inferDateFormat/isValid/clone/extractDate
  - **format 6 函数**（humanStorageSize/capitalize/between/normalizeToInterval/pad/getDecimalsCount）
  - **is 5 函数**（isObject/isDate/isRegexp/isNumber/deepEqual）+ `extend`（deep 标志 1:1）+ `clone`
  - **debounce**（leading/trailing/maxWait/isPending/cancel/flush 1:1）、**throttle**（尾跑补齐、返回
    上次结果 1:1）、**frameDebounce**（16ms Timer 等价 rAF）、**uid**（v4 形态；QML 无 crypto.randomUUID，
    碰撞抗性弱于基线，PARITY 留痕）
  - **不适用留痕**：dom 9 项、event 14 项、scroll 12 项（QML Item 几何/MouseArea 信号/Flickable 原生）
- **画廊第 14/15 页**（L0 图标/排版/动效 + L5 utils）：图标集 14 套一键切换、语义键实时预览、
  八种写法对照、12 级字阶、动效预设演示、亮度梯度、对比度选字色、实时日期格式化、防抖节流真实交互
- **测试 114 → 149 项全绿**（新增 35 项：图标集 8 / 归一化 2 / provider 2 / 动效 4 / 过渡 1 /
  排版 2 / 高程 1 / colors 5 / format 1 / date 8 / is-extend 1 / debounce-throttle-frame-uid 3）

### Fixed
- NovaIcon 对 emoji/符号输入不再请求 CDN（404 噪音），改文本通道渲染
- gen_prompt.py 基线常量 2.26.0 → 2.35.5（与 0.4.2 纠正同步）

### 沉淀坑位（17~20，详见 CONSTITUTION/SESSION_HANDOFF）
17. V4 引擎下 `1<<24` 参与 `|` 位运算拼 hex 会串色 → 逐字节 toHex2
18. Animation 无 `enabled` 属性（NumberAnimation 用 from==to 兜底不参与）
19. `Component.createObject` 创建的 Timer 不自动启动，必须显式 start/restart
20. QML 无 requestAnimationFrame/crypto.randomUUID → frameDebounce 用 16ms Timer、uid 降级实现留痕

## [0.7.0] - 2026-11-22

### Added（一期 Sprint 3 · **L3 行为层九件一次收口**：L3 11% → 100%）

- **NovaIntersectionPool 共享观察池**（L3 基础设施，对标 2.30 共享 IntersectionObserver 池架构）：
  - 一个 Timer（pollInterval 34ms ≈ 30fps）驱动全部订阅者批量求值，N 个行为共享唯一驱动源；
    无订阅时零开销；`add/remove/clear/kick/tick` + `viewport()/nearestScrollable()/scrollPosition()/intersect()`
    公共几何工具
  - 实现路径差异（如实记录）：基线走浏览器原生 IntersectionObserver（异步、阈值边界通知），
    Nova 走"帧轮询 + 自算矩形交集（含祖先 clip 链）"——比例是精确值
- **NovaIntersection**（对标 v-intersection，Intersection.json 核实）：handler → `onIntersect/entered/exited`
  三信号；threshold 数字/数组；rootMargin 四向 real；once + `rearm()`（对标 setOnce 再武装）；
  `stop()`（对标 handler 返回 false）；entry 七字段 1:1（target/isIntersecting/intersectionRatio/
  boundingClientRect/intersectionRect/rootBounds/time）；祖先 clip 链计入可见区域
- **NovaScrollObserver**（对标 v-scroll）：`onScroll(details)` 给出 vertical/horizontal/deltaX/Y/
  direction/atTop/atBottom/atLeft/atRight；root 自动解析最近可滚动祖先（Flickable/ListView/GridView）
- **NovaScrollFire**（对标 v-scroll-fire）：进入视口触发一次（复用 NovaIntersection，同池同算法）；
  threshold 0~1（arg 语义）；触发后自动解除武装，`rearm()` 可再触发
- **NovaClosePopup**（对标 v-close-popup，ClosePopup.json 核实）：depth 语义 1:1（<0 全关 / 0 禁用 /
  N 关顶 N 层）；触发源自动桥接宿主 clicked 信号（向上找带 clicked 的祖先，NovaBtn 子项转交
  contentHost 也能命中）；`usePointer` 兜底指针通道；Enter 键触发（对标 keyup 13）
- **NovaOverlayHost 弹层栈**（Nova 增强，对标 portal 链 + closePortals）：
  `registerPopup/unregisterPopup/popupCount/popups/closePopups(depth, reason)/topPopup`；
  **NovaDialog 已接入**（show 进栈、_forget 出栈），ClosePopup 的"层"因此有真实语义
- **NovaTouchPan**（对标 v-touch-pan，TouchPan.json 核实）：details 十一字段 1:1（evt/touch/mouse/
  position/direction/isFirst/isFinal/duration/distance/offset/delta）；修饰 horizontal/vertical/
  up/right/down/left → `horizontal/vertical/directions`；mouseAllDir → `allDirections`；
  preserveCursor → `preserveCursor`；stop/prevent → `stopPropagation/preventStealing`
- **NovaTouchSwipe**（对标 v-touch-swipe）：arg "6e-2:6:50" → `minVelocity/touchMinDistance/
  mouseMinDistance` 三属性；移动中即触发 + 松手兜底；direction/duration/distance/velocity
- **NovaTouchHold**（对标 v-touch-hold）：arg "600:5:7" → `duration/touchSensitivity/
  mouseSensitivity`；位移超灵敏度取消 + `onCancel` 通知（增强）；`progress` 进度源 `holding`
- **NovaTouchRepeat**（对标 v-touch-repeat）：delays 序列 "0:600:300"（末值复用、0 延迟防自旋）；
  details 九字段含 keyboard/keyCode/repeatCount/startTime；`keys` 数组接键盘（默认 Space/Enter）
- 内核 **NovaTouchCore**（internal）：四个 touch 行为共享同一套指针生命周期/坐标/时间/阈值/
  触摸来源判定（MultiPointTouchArea 探测真实触摸 + MouseArea 合成事件），避免四份实现各自漂移
- 画廊第 13 页"L3 行为指令"：懒加载（ScrollFire 触发变色 + Intersection 比例实时显示）、
  滚动位置/方向/到底、拖动方块（松手回弹）、四向划动、长按 600ms、按住连发、
  弹层栈按层关闭 + 对话框内容内真实 ClosePopup 关闭按钮
- 冒烟测试 91 → **114 项全绿**（新增 23：九件实例化 10 + Intersection 4 + Scroll 2 +
  Touch 4 + ClosePopup/弹层栈 3）

### Fixed（Qt 6.12 / PySide6 实战坑位沉淀）

- **Item 的 FINAL 属性不可覆盖**：QML 派生 Item 里声明 `property real x/y`、`property bool active`
  报 "Cannot override FINAL property"（x/y/active 是 Qt 6.12 的 FINAL 成员）——
  行为层改用 posX/posY/gesturing；`enabled` 同理不重声明，直接用 Item.enabled（继承语义天然正确）
- **visible:false 的 Item 不参与事件分发**：行为根节点若设 visible:false，内部 MouseArea 彻底失灵——
  纯逻辑行为可关，带指针通道的行为绝不能关（Item 无 visual 本就不渲染，无需隐藏）
- **组件默认属性转交内部容器**：NovaBtn 把子项塞进 contentHost，子项的 `parent` 不是按钮本体，
  `target: parent` 拿不到 clicked 信号 → ClosePopup 向上遍历找第一个带 clicked 的祖先
- **QML Window 的 Python wrapper 调不到 QML 函数**：PySide 把 QQuickWindow 包装成 QWindow
  （metaobject 里没有 QML 定义的方法）——测试用 QML 侧 QtObject 代理（call0/1/2 + val）统一调用，
  代理同时强引用窗口防 JS GC 回收
- **观察器重订阅必须重交付**：IntersectionObserver 只报"变化"，重新 observe 才会补一帧
  当前状态——`_start()` 时重置上次判定，否则 rearm 后永远等不到回调（基线 reobserve 同款注释）
- **QML 函数无可选参数**：Qt 6 的 QML 函数按固定形参暴露给 PySide（缺参即 TypeError）——
  代理拆成 call0/call1/call2 按实参个数分派

## [0.6.2] - 2026-11-22

### Added（一期 Sprint 2 收口 · **一次交付四件**：NovaLoading / NovaStorage / NovaApp / NovaPlatform —— L4 12% → 44%）

- **NovaRuntime Python 后端**（独立模块 `Nova.Runtime`，C++ 侧注册）：
  - ini 存储后端：QSettings 文件级落盘（`AppDataLocation/nova-storage.ini`），
    **不依赖 organizationName**（纯 QML 的 Settings 类型在无 org 标识时直接失效，故下沉 Python）
  - 平台探测：os / osVersion（prettyProductName）/ cpuArch / kernelType / isMobile /
    hasTouchscreen（QInputDevice 枚举 TouchScreen，Qt 6 无 QML 级 API）
- **NovaLoading**（对标 Loading 插件，npm 2.35.5 `dist/api/Loading.json` 逐项核实 **11 项**）：
  - 配置：delay / message / group / spinnerSize / spinnerColor→spinnerTint / messageColor→messageTint /
    backgroundColor→backgroundTint / spinner→spinnerModel（ring/dots/pulse）✅；html / boxClass / customClass ⛔（留痕，boxed 布尔映射）
  - **引用计数（Nova 增强）**：同组并发 show 不互踩，句柄 `hide()` 只释放自己那一份，归零才收口；
    `hide(group)` 对标基线语义 = 无视计数整组强杀
  - delay 防闪烁（默认 500，对标基线）；delay 窗口内 hide 从未显示即销毁
  - `target` 局部加载（挂任意 Item 内铺满）/ `timeout` 卡死兜底（默认关）/
    `increment / decrement / count / activeGroups / activeCount / isActive / hideAll / setDefaults` 内省面
  - 视觉层 `NovaLoadingOverlay`（internal）：Canvas 圆环（底环 16% + 270° 弧）、三点缩放、呼吸圆；
    明暗双主题遮罩自适应；句柄 `NovaLoadingHandle`（hide/update/valid/count/item）
- **NovaStorage**（对标 LocalStorage 插件）：
  - 全 API 面：`set/get/has/remove/clear/getAll/getAllKeys/getLength/isEmpty/setAll`
    + Web Storage 别名 `setItem/getItem/removeItem`
  - **命名空间隔离（Nova 增强）**：`useNamespace(name)` 切换即落盘旧空间、加载新空间
  - 真持久化：写入后由全新 QSettings 实例读回验证（测试 `test_storage_persistence_to_disk`）
  - JSON 损坏安全降级（按空空间载入不崩）；getAll 深拷贝防外部改库
- **NovaApp**（对标 AppFullscreen + AppVisibility + Meta）：
  - `request/exit/toggle/isFullscreen/isCapable`（全屏三件套 1:1）；
    `setVisibility` 统一入口：fullscreen/maximized/minimized/windowed；
    退出全屏自动回落进入前状态；`setTitle`（document.title → 窗口 title）；`show/hide/isVisible/isActive`
- **NovaPlatform**（对标 Platform 插件）：
  - `isWindows/isMac/isLinux/isAndroid/isIOS/isWasm/isMobile/isDesktop`；
    `hasTouch` 走后端输入设备枚举（桌面触摸本真实可得）；浏览器专属项
    （webAuthn/within.iframe/pwa/electron/内核判定）⛔ 不适用留痕
  - Nova 增强：`osVersion / cpuArch / describe() / snapshot()`
- 画廊第 12 页 "**Loading / Storage**"：全屏加载自动收口、引用计数 ±1 演示、局部加载、
  三种 spinner、Storage 读写/清空快照、窗口控制、平台信息（全程真实组件可交互）
- 冒烟测试 71 → **91 项全绿**（新增 20 项：Loading 10 + Storage 7 + Platform 1 + App 2）

### Fixed（Qt 6.12 / PySide6 实战坑位沉淀）

- **qmlRegisterSingletonInstance 所有权坑**：QML 树按 JS 所有权管理实例，组件销毁即 delete
  Python 侧对象，二次访问报 "Internal C++ object already deleted"；且全局单实例无法被多个
  QQmlEngine 安全共享 → 改用**工厂式 `qmlRegisterSingletonType`**（每引擎惰性创建，PySide 不留悬空引用）
- **单例引用裸 JS 对象无属性通知**：Loading 的活动组条目最初用裸 JS 对象，句柄 valid/count 绑定
  不随状态刷新 → 升级为 QML QtObject 条目（property Component 内联，Qt 6.12 坑位惯例）
- **overlay 可见性与宿主冲突**：NovaOverlayHost.attach 强制 visible=true，与 Loading 的
  delay 门控打架 → 可见性改由内部 `_started` 门控（delay 期间子项不渲染、遮罩不拦点击）

## [0.6.1] - 2026-11-22

### Added（一期 Sprint 2 · L4 服务层第二件：NovaDialog）

- **NovaDialog 命令式对话框**（对标 Dialog 插件，npm 2.35.5 `dist/api/Dialog.json` 逐项核实 **27 项**）：
  - `show(opts)` → 链式句柄 `NovaDialogHandle`：`hide()` / `update()` / `ok()` / `cancel()` / `valid`
  - 三个信号：`accepted` / `rejected` / `dismissed(reason)`（reason 五值 ok/cancel/backdrop/escape/api）
  - 五向定位 standard/top/right/bottom/left；非法值直接拒绝
  - 关闭策略三档：`persistent` / `noEscDismiss` / `noBackdropDismiss`
  - 形态：`seamless` / `maximized` / `fullWidth` / `fullHeight` / 进度态
  - 按钮三态归一（true/false/string/对象）+ `stackButtons`
  - `contentDelegate` 替代基线 `html`；`setDefaults()` 深合并；`count()`/`hideAll()` 内省
- 画廊新增"NovaDialog 对话框"页：基础/危险/仅确定、persistent/seamless/全宽/最大化、
  五向定位、进度态 + 句柄 update 收尾、自定义内容（TextField）
- 冒烟测试 63 → **71 项全绿**（新增 8 项：ok/cancel 原因、persistent 双锁、noBackdrop/noEsc 分离、
  setDefaults+update、五向定位、seamless/progress/dark、链式回调、hideAll）

### Notes

- **归属纪律再确认**：`dismissed(reason)` 在 Dialog/BottomSheet 是基线 2.28 真 parity；
  在 Notify 是 Nova 增强——两处已分栏标注，防止再混
- 基线 DOM 专属项（class/style/html/noRouteDismiss）⛔ 留痕不移植；prompt/options/component 标 🚧 待二期

## [0.6.0] - 2026-11-22

### Added（一期 Sprint 2 · L4 服务层第一件：NovaNotify + NovaOverlayHost —— 七层 L4 从 0% 到 6%）

- **NovaOverlayHost**（全局弹层宿主单例）：动态 Item 挂载窗口顶层 + 层叠分配；
  自动跟随 `NovaScreen.source` 定位窗口（Window.contentItem / Item.window 双路解析），
  Dialog/Loading 直接复用，不再各自造宿主
- **NovaTheme 层叠令牌族入册**：`zFab 990 / zSide 1000 / zMarginals 2000 / zFixedDrawer 3000 /
  zFullscreen 6000 / zMenu 6000 / zTop 7000 / zTooltip 9000 / zNotify 9500 / zMax 9998`
  （对标 Quasar `$z-*` 数值 1:1，宪法第 5 章补充条款：弹层 z 值禁止魔法数值）
- **NovaNotify**（L4，对标 Notify 插件）：29 项配置逐项对账（npm quasar@2.35.5 包内源码 +
  dist/api/Notify.json 核实）；9 位定位（top 系头插 / bottom 系尾插 / 侧向中线插入）；
  分组徽标（组键 message|caption|multiLine|label*icon…|position 逐条复刻）；动作按钮
  （NovaNotifyAction：triggered 信号 + handler 回调双通道）；超时进度条（时长 = timeout+1000
  与消失时刻对齐）；句柄 `NovaNotifyHandle`（dismiss / update / valid）
- **Nova 增强（PARITY 增强栏）**：`dismissed(reason)` 6 值 timeout/user/action/api/replaced/overflow；
  `maxVisible`（默认 5，同屏上限）；`countAt()/dismissAll()` 队列内省；`triggerAction(i)` 程序化触发
- **NovaNotifyAction / NovaNotifyHandle** 公开导出；`NovaNotificationItem` 内部导出（internal）
- 画廊新增"**NovaNotify 通知**"页（类型预设 / 9 位定位 / 动作与关闭原因 / 分组徽标 / 句柄
  ongoing 进度更新，全程真实组件可交互）；Demo 页新增通知卡片区
- 冒烟测试 46 → **63 项**（解析用例 + 行为级断言：分组徽标/组键含 actions/自定义组替换/
  更新语义拒绝与放行/动作点击顺序/closeBtn user/overflow 淘汰/timeout 到期/非法输入回落/Dark 实例化）

### Changed

- **方法论入册执行首例**：API 对账以 npm 包源码与 dist API JSON 为准（0.5.1 新颁纪律）——
  本轮实机核对发现 npm 当日最新 2.35.6 的 Notify 与 2.35.5 逐字节相同，基线无需返工
- 库存契约文档（资料库）同步落定：D1/D2/D6 采纳、D3 红线确认、D4 内置最小转圈、D5 不暴露 ignoreDefaults

### Fixed

- 0.4.2 审计归属二次澄清落地：PARITY 增补 NovaNotify 审计节，"关闭原因上报"在 Notify 上
  明确标为 Nova 增强（基线 `onDismiss()` 无参数），杜绝后续误打勾

## [0.5.1] - 2026-11-22

### Changed（NovaNotify 契约裁定落盘 —— 新会话 npm 源码级核对成果固化）

- **D1 采纳**：NovaNotify 做 Nova 增强 `dismissed(reason)`（5 值
  timeout/user/action/api/replaced），PARITY 标"增强"栏，**不入已对齐栏**
- **D2 采纳**：`html` 不移植（QML 无 DOM 且基线该选项自带 XSS 面），改 `contentDelegate`
- **D3 确认**：基线 `onDismiss` 撞 on\* 红线，改为信号 `dismissed`，无商量余地
- **D6 采纳**：`NovaOverlayHost` 宿主抽件**提前至 Sprint 2**（overlay 层叠令牌 + 位置栈
  9 位插入先跑通，避免 Sprint 3 Dialog 位置栈返工）
- 归属修正：`关闭原因上报` 仅属 Dialog/BottomSheet（2.28）；**Notify 无关闭原因**
  （npm 2.35.5 源码核实 `onDismiss()` 无参数），0.4.2 审计表补澄清注
- 基线快照：npm 当日最新 2.35.6，其 Notify 与 2.35.5 逐字节相同，无需返工
- 修正 MASTER_PLAN 笔误："NovaDialog 服务式 v0.6.0 已交付" → "服务式 API 于 Sprint 2 交付"
- 方法论入册：**API 对账以 npm 包源码/dist API JSON 为准，不按文档页凭记忆写**
  （文档页漏 `ignoreDefaults` 即为例证）

## [0.5.0] - 2026-11-22

### Added（一期 Sprint 1 · L1 布局系统 —— 生态七层 L1 从 0% 到 100%）

- **布局五件套**（L1，对标 QLayout 系列）：
  `NovaLayout`（四象限骨架，子项按类型自动归位，push/overlay 双模式 + 断点自动收起）、
  `NovaHeader`（顶栏，tint + 默认槽）、`NovaFooter`（底栏）、
  `NovaDrawer`（left/right、mini 悬停展开、overlay、breakpoint、bordered、宽度动画）、
  `NovaPage`（页面容器 + padding）
- **栅格三件套**（L5/L1，对标 Quasar Flex 栅格）：
  `NovaRow`（12 栅格水平排布、wrap 换行、justify/align 对齐）、
  `NovaCol`（cols 1~12、offset 推挤、gutter）、
  `NovaVisible`（above/below/only 断点显隐，对标 gt-*/lt-*/*-only 工具类）
- 画廊新增"**NovaLayout 布局**"页：6 种经典布局迷你示例（后台/看板/表单/详情/登录/空态），全部真实组件可交互
- 冒烟测试 32 → **46 项**（新增四象限归位/push 让位/断点自动收起/栅格数学/NovaVisible 语义等行为级断言）

### Changed

- `NovaLayout.pageArea` 只读暴露页面区引用；`drawerOpen` / `openDrawer()` / `closeDrawer()` / `toggleDrawer()` 抽屉控制 API
- PARITY 新增布局五件套 + 栅格三件套审计节（基线 2.35.5）；reveal/elevated/断点响应式 cols 等 🚧 项如实标注 M2

### Notes

- 断点收起策略由宿主 NovaLayout 执行（NovaDrawer 创建期 parent 宽度是瞬态值，不可自判）——已沉淀为坑位经验
- 距宪法 24 条封版验收：L1 布局层达成 100%，L5 可见性/栅格从 0% 起步覆盖

## [0.4.2] - 2026-11-22

### Fixed（基线漂移纠正 —— 用户截屏立功）

- **对标基线 2.26.0 → 2.35.5**：经官方 GitHub releases 复核（v2.35.5 发布于 2026-11-17），
  原 0.4.0"核实"的 2.26.0 为过期结果；宪法第 0 章新增**基线复核条款**：
  每期开工第一天必须先核对官方最新 release
- `ECOSYSTEM_PARITY.md` 新增 §0.5 基线漂移审计（2.26→2.35 增量对照表）：
  Quasar 无新增组件（对账 76 项不变），生态层 6 类增量全部落入 MASTER_PLAN

### Changed（增量审计落入各期 DoD）

- 一期 Sprint 1：NovaScreen 补 `orientation`（对标 2.35 Screen API）
- 一期 Sprint 3：NovaIntersection 采用**单例 observer 池**（对标 2.30 useIntersection 复用架构）
- 二期：NovaSelect 补 hover 契约 / no-option-label / dialog 关闭按钮（对标 2.26~2.28）
- 四期：NovaFab 补 stagger 级联 + hover 打开；NovaPullToRefresh 补 side 四边拉动；
  NovaDialog/NovaBottomSheet 补**关闭原因上报**（cancel/backdrop/escape/programmatic，对标 2.28）
- 五期：**新增 L6 项"Nova MCP server + AI-ready 离线文档"**（对标 2.33 @quasar/mcp 全新品类，
  AI agent 精确查询版本化 API，杜绝幻觉）；供应链门禁补外部输入消毒（对标 2.32~2.35 安全硬化）

## [0.4.1] - 2026-11-21

### Added（全生态开发总规划 —— 六期战略图）

- **`docs/MASTER_PLAN.md`**：全生态开发总规划，覆盖 Quasar 2.26.0 全生态（组件 76 项 /
  指令 11 项 / 插件 15 项 / 图标 8 套 / 工具 / 工程化），分 **六期** 稳步推进：
  一期生态骨架（0.5.0~0.8.0）→ 二期表单与选择（0.9.0~0.10.0）→ 三期数据与媒体
  （0.11.0~0.12.0）→ 四期导航弹层反馈（0.13.0~0.14.0）→ 五期长尾+非功能（0.15.0~0.16.0）
  → 六期封版 `1.0.0-flagship`；总周期约 28 周（单人节奏含缓冲）
- 每期含：生态层归属、逐组件关键能力表、**冒烟测试验收标准**、测试数量轨迹
  （32 → 240+，封版覆盖率 ≥85%）
- **冒烟测试纪律制度化**（规划第 7 节）：七条统一模板，每个 Sprint 交付时逐条执行
- **全量对账表**（规划第 8 节）：Quasar 全生态 → Nova 命名 → 归属期，覆盖率对账
  组件 76/76、指令 11/11、插件 15/15（含 ⛔ 不适用留痕：AddressbarColor/Cookies/v-mutation）
- 风险对策表：NovaDate 自研日历、NovaTable 复杂度拆两次交付、单人节奏波动等

### Changed

- ROADMAP 增加指向 MASTER_PLAN 的入口说明（总规划为准，路线图保留 P0/P1/P2 分级视角）

## [0.4.0] - 2026-11-21

### Added（生态完整性 —— 封版前最后一块拼图）

- **`docs/ECOSYSTEM_PARITY.md` 生态对标白皮书**：以七层模型（L0 设计语言 / L1 布局 /
  L2 组件 / L3 指令 / L4 插件·服务 / L5 工具层 / L6 工程化）审计 Quasar 2.26.0 全生态，
  给出各层成熟度评分（当前 60%/0%/10%/11%/0%/0%/70%）、逐层差距表、
  **12 项 P0 空白清单**（含验收标准）、非功能门禁、重排后的里程碑、**24 条封版验收清单**
- 宪法新颁**第 10 章 生态完整性（七层模型）**：交付物必须标注所属层；
  优先级纪律"骨架 > 服务 > 行为 > 组件"；禁止"组件堆满、生态空心"
- ROADMAP 按生态层重排交付顺序（L1 → L4 → L3 → L0/L5 → L2 → L6）

### Changed

- M1 范围重定义：从"组件攻坚"改为"生态骨架"四个 Sprint
  （布局五件套 → 服务六件套 → 行为四件套 → 图标/工具/动效）

### Notes

- 核心判断：Quasar 的"生态味"主要来自 **L1 布局、L3 指令、L4 插件、L5 工具类**（当前合计 0%），
  而非组件数量；补齐这四层才叫"用起来像 Quasar"，否则只是"长得像"

## [0.3.4] - 2026-11-21

### Changed（接续方式精简为单文件）

- `PROMPT.md` 改为**自包含**：交接快照全文内联，新会话只需粘贴这一个文件，
  不再要求预先翻 `SESSION_HANDOFF / CONSTITUTION / PARITY / CHANGELOG`
- 宪法/PARITY/CHANGELOG/ROADMAP 改为"**按需深读**"表格（涉及对应主题时再打开）
- `gen_prompt.py` 升级：快照正文自动内联（H2→H3 嵌套、剥离引用块），
  输出**内容指纹**（SHA256 前 12 位）；`--check` 由"版本号比对"升级为"指纹比对"
- 宪法第 9 章新增第 4 条：SESSION_HANDOFF 为唯一事实源，PROMPT.md 为其单文件投影
- SESSION_HANDOFF 陈旧状态修正（0.3.1 → 0.3.4）并清理重复条目

## [0.3.3] - 2026-11-21

### Fixed（交付包完整性加固）

- 发布 ZIP 补齐 `PROMPT.md`（此前漏打，接续提示词不在包内）
- 发布 ZIP 默认纳入完整 `.git` 历史（此前遗漏，异地灾备承诺未兑现）
- 新增 `BUILD_INFO.txt` 构建清单（版本/构建时间/git HEAD/文件总数/校验方式）
- 新增旁路 `*.sha256` 校验文件：下载后可核对指纹，杜绝传输截断导致的“包变小”误判
- 新增 `--bundle`：ZIP 内附加 `icons/` 离线图标全量包（约 30MB，完全离线部署）
- 新增 `--no-git`：按需剔除 git 历史以减小体积

## [0.3.2] - 2026-11-21

### Added（跨会话永续开发闭环）

- `docs/templates/SESSION_HANDOFF_TEMPLATE.md`：交接快照通用模板（{{占位符}} + 使用说明）
- `docs/templates/PROMPT_TEMPLATE.md`：会话接续提示词模板（上下文恢复 → 汇报 → 硬约束）
- `scripts/gen_prompt.py`：**根据交接快照实时更新提示词** —— 提取快照版本/日期/git HEAD，
  从模板生成项目根目录 `PROMPT.md`；`--check` 模式校验同步性（可入 CI 门禁）
- 宪法第 9 章交付纪律升级：每次交付 = 升版 → CHANGELOG → 宪法记录 → SESSION_HANDOFF →
  **gen_prompt 刷新 PROMPT** → 一键 ZIP

## [0.3.1] - 2026-11-21

### Added（基础夯实轮 —— 磨刀不误砍柴工）

- 测试护栏补齐：Dark 插件 API 测试（`isDark` / `setDark` / `toggleDark` 翻转 / `dark` 品牌色令牌）、
  demo 完整加载测试（此前仅画廊有护栏）；合计 32 项，全绿
- GitHub 基建：Issue 模板（Bug/Feat，要求附 Quasar 对标 API 与明暗主题复现说明）、
  PR 模板（宪法第 8/9 章交付检查清单）、dependabot 依赖巡检（actions + pip 周检）
- 文档测试计数全量同步（25 → 32）
- **防失忆保险**：`docs/SESSION_HANDOFF.md` 项目交接快照（新会话 1 分钟恢复全部上下文）；
  git 仓库初始化 + 全量首提交（工程记忆落盘，不依赖任何会话）

## [0.3.0] - 2026-11-21

### Changed ⚠ Breaking（0.x 期重构，趁早降本）

- **命名冲突重构**（宪法迭代 0.3.0）：明暗模式 `NovaTheme.dark` → **`NovaTheme.isDark`**
  （1:1 对标 `$q.dark.isActive`），品牌色 **`darkColor` → `dark`**（1:1 对标 Quasar `$dark`），
  并新增 `setDark(value)`（对标 `$q.dark.set()`）；`toggleDark()` 不变（对标 `$q.dark.toggle()`）
- 迁移：`NovaTheme.dark = true` → `NovaTheme.setDark(true)`；读取用 `NovaTheme.isDark`

### Added

- **全量对标审计机制（宪法 3.5 条）**：`docs/PARITY.md` —— 已交付组件逐属性/事件/槽/model
  对照 Quasar 2.26.0 列明 ✅/🚧/⛔/❌ 状态与目标里程碑；v-model → QML 可写属性+变更信号映射约定；
  封版前 ✅ 占比门禁（P0 ≥90%、全库 ≥85%）
- 新增测试：`isDark` / `setDark` / `dark` 品牌色（合计 30 项，全绿）

## [0.2.1] - 2026-11-21

### Added

- **《架构宪法》`docs/CONSTITUTION.md`**：九章最高工程准则（工程结构 / 头注释 / Quasar 化 /
  槽机制 / 设计令牌 / 断点 / 图标 / 质量门禁 / 版本纪律）+ 迭代记录表，每次交付随版本更新
- **槽机制入宪（宪法第 4 章）**：Quasar 默认槽 → QML `default property alias`、
  命名槽 → 具名 alias / 组合子组件、作用域槽 → `property Component delegate`
- `NovaTheme.darkColor`（`#1D1D1D`）：补齐 Quasar 8 大品牌变量最后一项（本库 `dark` 已被明暗模式布尔占用，故映射命名 `darkColor`）

### Changed

- ⚠ 对标基线核实并锁定 **Quasar 2.26.0**（此前记录的 2.2x 版本号已过时，随宪法迭代复核）
- **5 个组件重构补齐默认槽**（Quasar 对应组件均有默认槽）：`NovaBtn` / `NovaChip` /
  `NovaAvatar` / `NovaIcon` / `NovaBadge` 新增 `default property alias`，
  默认子项挂载到覆盖层宿主，NovaBadge 角标吸附行为不受影响
- 新增 5 项槽机制冒烟测试（合计 30 项，全绿）

## [0.2.0] - 2026-11-21

### Changed ⚠ Breaking

- **包结构规范化（src 布局终版）**：Python 包 `nova` → `pyside_nova`，
  QML 模块 URI `nova.services/controls/behaviors` → `Nova.Services/Controls/Behaviors`
  - `from nova import init_nova` → `from pyside_nova import init_nova`
  - `import nova.controls` → `import Nova.Controls`
- 工程约定落盘：所有 `.py` / `.qml` 文件以两行头注释开头——
  第 1 行从 `src/` 开始的完整文件子路径（`src/pyside_nova/…`），第 2 行组件/文件说明（直接沉淀为 API 文档素材）
- ⚠ 已知坑（沉淀为规范）：`qmldir` 文件仅支持 `#` 注释，`//` 会破坏模块解析

### Added

- **一键打包部署升级**：`scripts/local_deploy.py --zip` 生成发布 ZIP 包
  （`dist/pyside-nova-<版本>-release.zip`：完整源码树 + 构建 wheel，zip 内根目录 `pyside-nova/`）

- **组件画廊（Gallery）**：`examples/gallery/` —— 侧边导航 + 8 个页面，
  全部 12 个组件实机展示（按钮形态/尺寸/状态、卡片三件套、标签、头像、徽标波纹、
  图标双通道、主题令牌色板、断点实时监控），顶部一键明暗切换
- **完整旗舰版文档集**：README.md（英文）/ README_zh.md（中文）/
  CHANGELOG / CONTRIBUTING / SECURITY / CODE_OF_CONDUCT /
  docs/ARCHITECTURE.md / docs/DESIGN_TOKENS.md / docs/COMPONENTS.md / docs/ROADMAP.md
- 新增测试：组件画廊完整加载测试（合计 25 项，全绿）

## [0.1.0] - 2026-11-21

### Added — M0 基建 · 第一批组件（12 个）

- `NovaTheme`：设计令牌单例（品牌色/语义色/表面色/几何/字阶/阴影），明暗双主题，运行时品牌换肤
- `NovaBtn`：按钮（filled/outlined/flat、水波纹、loading、disable、键盘触发）
- `NovaCard` / `NovaCardSection` / `NovaCardActions`：卡片系列（MultiEffect 阴影）
- `NovaChip`：标签（filled/outlined/tinted、可选中、可移除）
- `NovaAvatar`：头像（自动配色/emoji/图片）
- `NovaBadge`：徽标（子项挂载，红点/数值/浮动）
- `NovaSpace` / `NovaSeparator`：布局原语
- `NovaIcon`：图标组件（对标 QIcon）——`icon="mdi:home"` 式 API，云端 CDN + 本地图标包双通道自动回落，封装 QML Image + MultiEffect 单色化着色；`NovaBtn.icon` 自动识别图标引用
- `NovaScreen`：屏幕断点单例（对标 Quasar Screen 插件）——xs/sm/md/lg/xl（600/1024/1440/1920），is/lt/gt 语义 1:1 对标，阈值可定制
- `NovaRipple`：水波纹行为（子项挂载）
- Python 接入层 `init_nova(engine)`；wheel 内完整打包 QML 模块
- 设计约定：组件基调色属性命名 `tint`（QML 中 `color` 与基类属性冲突）；`NovaBadge.attach`/`NovaRipple.attach` 语法规划于 M1 通过 PySide6 `QML_ATTACHED` 实现
- 可运行演示 `examples/demo`；QML 冒烟测试；CI（Windows+Linux 矩阵）与 PyPI 可信发布流水线
- 一键本地部署：`scripts/fetch_icons.py`（下载 MDI/Material 图标包离线可用）+ `scripts/local_deploy.py`（build→install→test）

### Verified（Qt 6.12.0 关键坑位沉淀）

1. `on*` 前缀属性命名与 QML 信号处理器命名规则冲突（如 `onPrimary`），会令整个模块加载失败
   → 主题文本属性命名 `textOnPrimary` / `textColor` / `textMuted`
2. 组件声明 `property color color` 与 Rectangle 基类 `color` 冲突导致重复赋值
   → 基调色统一命名 `tint`
3. 纯 QML（6.12）不支持自定义 attached property（`Xxx.attach` 语法）
   → M1 经 PySide6 `QML_ATTACHED` 注册 Python 类型补齐，当前以子项挂载保持属性名一致
4. 单例属性不能在对象体内声明式绑定（会被解析为 attached property）
   → `NovaScreen.source = window` 须在 `Component.onCompleted` 中赋值
