# NovaDataGrid · 铝电解工作站大数据量演示

> `pyside-nova 1.10.0` · 第 146 公共类型 `Nova.Controls.NovaDataGrid` 的独立演示工程。
> 与 [`markdown_demo`](../markdown_demo/README.md) 同级，按控件类别归档在 `examples/controls/`。
> **不动库本体、不重签冻结面、不新增公共类型**——只消费已发布/已重签的公共 API。

## 1. 它演示什么

一个电解系列下辖若干车间/工区，每台槽持续上报工艺量。真实工作站动辄数千台槽、秒级采集，
把整表塞进 JS 数组或每帧 `model = newRows` 都会掉帧。本 demo 用 `NovaDataGrid` 的标准管道处理：

```
data.generate_rows(4000)          ← 确定性数据源（seed 固定，可复现）
        │
        ▼
NovaDataGridModel       (tableModel)   QAbstractTableModel，50 ms 合并 dataChanged
        │                              + 1.5 s 变动行高亮 + batchUpdate 增量合并
        ▼
NovaDataGridFilterProxy (filterProxy)  全字段 / 列级过滤
        │
        ├── NovaDataGridPagination (pagination)  页码 / 每页槽数 / 总数
        ▼
NovaDataGridPagedProxy  (pagedProxy)   按 startIndex/endIndex 切片
        │
        ▼
NovaDataGrid.qml                      TableView 真虚拟化，只创建可视区 delegate
```

**大数据量的三条硬约束**（都在本 demo 里真跑，不是纸面说明）：

| 约束 | 做法 |
| --- | --- |
| 不全量渲染 | `TableView` 按可视区创建 delegate；`reuseItems: false`（坑位 32），虚拟化不依赖复用 |
| 不全量回写 | 采集批次走 `batchUpdate()` 按 `slot`（rowKey）合并，不重置整表 |
| QML 不遍历全表 | 统计卡片在 Python 侧聚合，QML 只读 `plantStats.*` 属性 |

`verify_offscreen.py` 用视觉树文本数作为**真虚拟化的硬证据**：4000 行 × 11 列若全量渲染会有数万个
`QQuickText`，实测只有几百个。

## 2. 运行

```bash
# 从 pyside-nova 仓库根运行（需要 PySide6>=6.8，且 pyside-nova 已 editable 安装）
python examples/controls/datagrid_demo/main.py                 # 4000 槽 + 实时采集
python examples/controls/datagrid_demo/main.py --rows 10000   # 万行档，验证虚拟化不随行数劣化
python examples/controls/datagrid_demo/main.py --no-stream    # 静态快照（截图/验收）
python examples/controls/datagrid_demo/main.py --list         # 只打印数据集摘要，不启窗
```

| 参数 | 默认 | 说明 |
| --- | --- | --- |
| `--rows` | `4000` | 槽位行数，建议试 `1000` / `4000` / `10000` 三档 |
| `--seed` | `20261127` | 数据随机种子，固定即可复现截图与统计 |
| `--interval` | `400` | 采集批次间隔（ms） |
| `--batch` | `24` | 每批刷新的槽位数 |
| `--page-size` | `50` | 分页大小（表格底部 `NovaPagination` 可改 10/20/50/100） |
| `--no-stream` | 关 | 关闭实时采集，用于静态截图 |
| `--list` | 关 | 打印行数/列数/统计/阈值，不启动 QML 窗口 |

## 3. 界面

- **顶栏**：数据集规模、分页规格、采集状态、明暗切换。
- **统计卡片 ×6**：在册槽数 / 正常率 / 预警槽 / 严重槽 / 平均槽电压 / 平均电解温度。
- **控制条**：暂停或继续采集、仅看预警/严重、清除过滤、手动刷新一批、精简列/恢复全部列。
- **主表格**：11 列工艺参数；点表头排序、点「槽电压」单元格内联编辑（`editor="number"`）、
  右键行、翻页、列显隐；状态列与槽电压列走 `cellDelegates` 自定义委托（徽标 + 趋势条）。
- **底栏**：最近事件、页码/总槽数、采集节奏。

全部控件取自 `Nova.Controls`（`NovaDataGrid` / `NovaBtn` / `NovaChip`），颜色全部取
`NovaTheme` 令牌，零手搓裸控件、零新增主题令牌。

## 4. 铝电解工艺口径

阈值是 `data.py` 与界面说明的**唯一事实源**（`severity` 与「状态」列由同一份行数据推导，账实同源）：

| 指标 | 预警线 | 严重线 |
| --- | --- | --- |
| 电解温度 | ≥ 958 °C | ≥ 968 °C |
| 槽电压 | ≥ 4.30 V | ≥ 4.45 V |
| 炉底压降 | ≥ 395 mV | — |
| 阳极效应次数 | ≥ 2 次 | ≥ 4 次 |

`severity` 0/1/2 → 正常/预警/严重，同时驱动 `NovaDataGrid` 的 severity 染色、状态徽标配色与统计卡片。

## 5. 文件清单

| 文件 | 作用 |
| --- | --- |
| `data.py` | 确定性数据源、阈值、列定义、批量增量、统计聚合（纯 Python，零 Qt 依赖） |
| `main.py` | 启动器：装配四段管道、`WorkstationStats` / `CollectionStream`、注入 context、CLI |
| `main.qml` | 主界面：顶栏 / 统计卡片 / 控制条 / `NovaDataGrid` / 底栏 + 两个列级委托 |
| `verify_offscreen.py` | 离屏真机验收：视觉树取证、交互事件链、两张截图、0 坏 Qt 消息 |
| `datagrid_demo.png` | 默认态截图（亮色 / 全量） |
| `datagrid_demo_dark.png` | 交互态截图（暗色 / 严重槽过滤） |

## 6. 验收

```bash
QT_QPA_PLATFORM=offscreen python examples/controls/datagrid_demo/verify_offscreen.py
```

覆盖：4000 行源模型 / 50 行分页切片 / 11 列 / 虚拟化取证 / 统计断言 / 排序·过滤·批量刷新·
采集开关·列显隐·翻页·键盘·信号事件链 / 明暗切换 / 两张 `grabWindow()` 截图 / 0 条坏 Qt 消息。

## 7. 坑位备忘

- **坑位 69**：`TableView`/`Repeater` 的 delegate 是视觉子项，取证走 `QQuickItem.childItems()`，
  并提前 `import PySide6.QtQuick`，否则 `rootObjects()` 会被包装成无 `contentItem()` 的 `QWindow`。
- **坑位 70**：Python `list[dict]` 注入到 QML 是 `QVariantList`，`Array.isArray()` 为 false；
  所有 `options` / `setVisibleColumns()` 的数组一律在 QML 内用 JS 数组字面量构造。
- **坑位 71**：条件高度的 `Rectangle` 不要用 `visible: height > 0` 自举（初始高 0 → 永不分配高度）。
- **坑位 72**：Qt 6.12 起 `Connections` 的隐式 `onFoo:` 已 deprecated，用标准 `function onFoo() { … }`。
- **坑位 73**：QML 绑定/delegate 更新排队到事件循环；若把一连串改模型的操作挤在同一条表达式求值链
  同步跑完，下一次 `QSortFilterProxyModel.invalidate()` 会踩到半更新状态（offscreen 下 access
  violation）。验收脚本每个表达式后都推进事件循环，与真实 app 节奏一致。
- **路径**：`find_repo_root()` 向上探测标志目录，不写死 `parents[n]`（markdown_demo 曾因目录归档
  整理静默丢掉 dogfooding 文档）。
- **坑位 74（Windows offscreen 滚动条）**：`QT_QPA_PLATFORM=offscreen` 下 `QWindowsTheme` 会尝试打开
  原生 `SCROLLBAR` 主题并失败，连刷 52 条 `OpenThemeData() failed for theme 8 (SCROLLBAR)`，
  同时把 `TableView` 的 `ScrollBar` indicator 画成黑/白竖条。设
  `QT_QUICK_CONTROLS_STYLE=Basic` 强制 Qt Quick Controls 走 Basic 自绘样式，消息归零、竖条消失。
  `verify_offscreen.py` 已在导入 Qt 前 `setdefault` 该变量；手工复跑无需额外设置。
