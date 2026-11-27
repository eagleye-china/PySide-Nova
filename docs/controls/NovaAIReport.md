# NovaAIReport · 智能报表工作台壳

> **模块** `Nova.Composite.LayoutShell` · **a11y** `decorative`（布局容器，语义由注入内容承担）· **pyside-nova 1.7.0**
> **API 冻结指纹** `7c542c416709cd96` · **第 21 个组合根** · 公共面 **22 props / 3 signals / 3 methods**
> 公共签名以 `api/nova-api-1.7.0.json` 冻结面为准；组件源码 `Nova/Composite/LayoutShell/NovaAIReport.qml`
>
> 本页是**手写使用文档**（`docs/controls/` 不属生成物目录），把外部行业方案转译为
> 本库可交付事实。组件自动生成页见 `docs/components/NovaAIReport.md`（禁止手改）。

## 0. 定位与裁决（为什么和方案原文不同）

输入方案 `Nova-AlReport 铝电解行业 AI 报表 · 开源封版方案 v1.0.0` 是一份**产品级方案**：
它定义 L1~L5 能力分层、参数语义层 YAML、归因/预测框架、NL2SQL、Agent 编排、信任爬坡、
开源治理与社区规则。其中**绝大部分是 Python 智能层与业务层职责**，不属于 QML 组件库。

本库唯一依赖是 `PySide6>=6.8`，组合组件按宪法第 1 章必须是**无业务语义骨架**。因此做如下裁决：

| 方案原文诉求 | 本库落地裁决 | 归属 |
| :--- | :--- | :--- |
| L1 多级表头 / 冻结列 / 规模自适应 | 交给 `NovaDataGrid`（真虚拟化 + 列选择器 + 列级委托） | 库内已有公共类型 |
| L2 归因七元组 / L3 预测区间 / L4 问数早报 / L5 Agent 审批 | 抽象为四条**槽位** + 一条审批闸门槽，Shell 只托管布局 | 本组件（NovaAIReport） |
| 对标基线 `benchmark_tier` / 本厂 vs 先进差距 | 抽象为顶部**对标带槽位**，数值口径由业务注入 | 本组件（槽位） |
| `parameter-semantics.yaml` 唯一事实源 | **不入库**：语义层是业务资产，Shell 不硬编码第二份参数口径 | 业务层 |
| 归因引擎 / 预测模型 / NL2SQL / Agent 编排 / 信任爬坡 | **不入库**：Python 智能层，需 GPU/数据/模型权重 | 业务层（另仓/另项目） |
| 开源治理 / 社区规则 / RFC / 收益账本 | **不入库**：项目治理文档，非运行时组件 | 社区层 |

**一句话**：NovaAIReport 是方案的**界面骨架载体**——把"对标→诊断→预测→问数→审批"的决策闭环
做成可复用的七槽工作台，业务把参数语义、归因结论、预测区间、问数结果与审批动作注入槽位即可。
它不是、也不宣称是完整的 AI 报表系统。

> 史料不圆场：方案原文中的先进工厂量化指标（魏桥/云铝/遵义/包头/信发）是其对标参照，
> 属业务层填充内容，**本组件不内置、不承诺任何精度数值**。

## 1. 快速开始

### 1.1 QML 侧（七个槽位全部由业务注入）

```qml
import QtQuick
import QtQuick.Controls
import Nova.Controls
import Nova.Services
import Nova.Composite.LayoutShell

ApplicationWindow {
    width: 1440; height: 900; visible: true
    color: NovaTheme.page

    NovaAIReport {
        anchors.fill: parent
        anchors.margins: 16
        diagnosisSize: 300
        querySize: 340

        // 主报表区：注入 NovaDataGrid（数据管道见 §2）
        reportSlot: NovaDataGrid {
            anchors.fill: parent
            title: "电解槽实时报表"
            tableModel: gridTableModel
            filterProxy: gridFilterProxy
            pagedProxy: gridPagedProxy
            pagination: gridPagination
        }

        // 对标带：本厂值 / 行业基线 / 先进基线 / 差距（业务填充）
        benchmarkSlot: Rectangle {
            anchors.fill: parent; color: "transparent"
            Text { anchors.centerIn: parent; text: "电流效率 94.1% · 先进基线 ≥94.6% · 差距 −0.5pt"
                   color: NovaTheme.textColor }
        }
        diagnosisSlot: Rectangle { anchors.fill: parent; color: NovaTheme.surfaceAlt }
        forecastSlot:  Rectangle { anchors.fill: parent; color: NovaTheme.surface }
        querySlot:     Rectangle { anchors.fill: parent; color: NovaTheme.surfaceAlt }
        approvalSlot:  Rectangle { anchors.fill: parent; color: NovaTheme.surface }
        overlaySlot:   Item {}
    }
}
```

> **CC-6 槽位基线**：注入的顶层 `Item` 默认 0×0，**必须显式 `anchors.fill: parent`**；
> 否则内部 anchors 算出负宽高被裁（表现为"中央空板"）。`overlaySlot` 取
> `NovaTheme.zFixedDrawer` 顶层，业务注入须为透明 / 空 `Item`，铺满不透明块会盖住整个组件。

### 1.2 受控契约（Shell 只 emit 意图，不自写宿主状态）

```qml
NovaAIReport {
    id: report
    onDiagnosisToggled: function (collapsed) { report.diagnosisCollapsed = collapsed }
    onQueryToggled:      function (collapsed) { report.queryCollapsed = collapsed }
    onApprovalRequested: function () { /* 宿主弹出人工确认闸门，走业务审批流程 */ }
}
```

按 `Esc` 时，Shell 对未收起的 diagnosis / query 两条轨分别 emit `*_Toggled(true)`；
是否真的收起由宿主写回 `*Collapsed`。这与 `NovaSidebar` / `NovaChat` 的受控契约一致。

## 2. 主报表区：与 NovaDataGrid 装配

`reportSlot` 不绑定具体表格类型，推荐注入库内的 `NovaDataGrid`（第 146 类型，1.5.0 additive）。
数据管道装配沿用其标准五件套（`pyside_nova.datagrid`）：

```python
from pyside_nova.datagrid import (
    NovaDataGridColumn, NovaDataGridModel,
    NovaDataGridFilterProxy, NovaDataGridPagedProxy, NovaDataGridPagination,
    SEVERITY_FIELD,
)
from pyside_nova import init_nova
from PySide6.QtQml import QQmlApplicationEngine

columns = [
    NovaDataGridColumn("slot", "槽号", width=100),
    NovaDataGridColumn("ce", "电流效率(%)", width=120, align="right"),
    NovaDataGridColumn("energy", "直流电耗(kWh/t)", width=150, align="right"),
    NovaDataGridColumn("severity", "状态", width=100),
]
rows = [
    {"slot": "A01", "ce": 94.3, "energy": 12510, "state": "正常", SEVERITY_FIELD: 0},
    {"slot": "B02", "ce": 93.1, "energy": 12980, "state": "预警", SEVERITY_FIELD: 1},
]
model = NovaDataGridModel(columns, rows, row_key="slot")
pagination = NovaDataGridPagination(page_size=20)
filter_proxy = NovaDataGridFilterProxy(); filter_proxy.setSourceModel(model)
paged_proxy = NovaDataGridPagedProxy(pagination); paged_proxy.setSourceModel(filter_proxy)
pagination.setTotal(len(rows))

engine = QQmlApplicationEngine()
init_nova(engine)
ctx = engine.rootContext()
ctx.setContextProperty("gridTableModel", model)
ctx.setContextProperty("gridFilterProxy", filter_proxy)
ctx.setContextProperty("gridPagedProxy", paged_proxy)
ctx.setContextProperty("gridPagination", pagination)
engine.load("main.qml")
```

- **severity 染色**：`_severity` 字段 `0` 正常 / `1` 警告 / `2` 严重，颜色取 `NovaTheme.warning/negative` 派生，
  由 NovaDataGrid 承担，本壳不重复实现。
- **规模自适应**（方案 L1）：NovaDataGrid 自带列选择器与真虚拟化；">500 槽切换异常聚合视图"属业务选择，
  由宿主切换注入的数据视图，壳不内置阈值。
- 详见 `docs/controls/NovaDataGrid.md`。

## 3. 公共 API

### 3.1 槽位（alias）

| 槽位 | 语义 | 方案映射 |
| :--- | :--- | :--- |
| `benchmarkSlot` | 对标带：本厂值 / 行业基线 / 先进基线 / 差距 | §2 先进对标基线 |
| `diagnosisSlot` | 诊断轨：归因七元组、根因排序、建议动作 | L2 异常检测 + 自动归因 |
| `reportSlot` | 主报表区：推荐注入 `NovaDataGrid` | L1 多级表头 / 冻结列 / 规模自适应 |
| `forecastSlot` | 预测区间带：2–8h 区间 + 模型新鲜度 | L3 预测性 KPI |
| `querySlot` | 问数轨：NL2SQL 结果 / 每日工艺早报 | L4 自然语言问数 + 早报 |
| `approvalSlot` | 审批闸门：建议 → 人工确认 → 回写 | L5 Agent 建议 + 人工确认 |
| `overlaySlot` | 浮层：确认弹窗 / 加载遮罩（须透明 Item） | — |

### 3.2 配置属性

| 属性 | 类型 | 默认 | 说明 |
| :--- | :--- | :--- | :--- |
| `diagnosisSize` | `real` | `300` | 左诊断轨宽（内部钳制 ≥180、≤width/3） |
| `querySize` | `real` | `340` | 右问数轨宽（内部钳制 ≥220、≤width/3） |
| `benchmarkHeight` | `int` | `64` | 顶部对标带高（钳制 24~240） |
| `forecastHeight` | `int` | `96` | 预测区间带高（钳制 24~360） |
| `approvalHeight` | `int` | `180` | 审批闸门区高（钳制 24~480） |
| `showBenchmark` / `showDiagnosis` / `showForecast` / `showQuery` / `showApproval` | `bool` | `true` | 各区显隐；隐藏走栏高归零 + Behavior 动画 |
| `diagnosisCollapsed` / `queryCollapsed` | `bool` | `false` | 可折叠轨状态（受控，由宿主写回） |
| `breakpoint` | `int` | `1180` | 断点：低于此宽自动收起两轨 |
| `bordered` | `bool` | `true` | 轨间分隔线显隐 |
| `belowBreakpoint` | `bool`(ro) | — | 当前是否低于断点 |

### 3.3 信号与方法

| 成员 | 签名 | 触发 |
| :--- | :--- | :--- |
| signal | `diagnosisToggled(bool collapsed)` | 诊断轨折叠意图（`Esc` / `toggleDiagnosis()`） |
| signal | `queryToggled(bool collapsed)` | 问数轨折叠意图（`Esc` / `toggleQuery()`） |
| signal | `approvalRequested()` | 审批闸门请求（宿主接业务审批流程） |
| method | `toggleDiagnosis()` | emit 诊断轨反向折叠意图 |
| method | `toggleQuery()` | emit 问数轨反向折叠意图 |
| method | `requestApproval()` | emit `approvalRequested()` |

## 4. 主题、a11y 与坑位

- **主题**：唯一令牌源 `NovaTheme`；专属身份色 `_ink` 由 `NovaTheme.primary.hsvHue + 0.0694`
  派生（仪表钢蓝，仍属 primary 同色系，CC-3 组件内单色相），暗色态提亮；
  辉光 `_glow` 同色相提亮仅用于身份焦点小面积点缀；`setBrand` 换肤同步平移。**不新增公共令牌**。
- **a11y**：容器根为 decorative，故意不挂 `Accessible.*`（避免屏读器噪声），语义由注入内容承担；
  `Esc` 只 emit 已有信号、不自写宿主状态；注入的交互子件沿用其自身 interactive 契约与焦点环。
- **RTL**：根节点 `LayoutMirroring.enabled: NovaTheme.isRtl`，逻辑侧 API 语义恒定。
- **动效**：折叠动画统一取 `NovaMotion.duration(NovaMotion.transitionDuration)` +
  `NovaMotion.easingStandard`（CC-5，`reducedMotion` 自动短路）。
- **CC-1~CC-8**：组合上下文 `_unit/_gap/_dur/_ease/_divider` 全槽共享；相邻边界单条
  `NovaSeparator`；身份装饰全为 `_` 私有抽象几何、实心度 ≥0.85、`z: NovaTheme.zMarginals` 提级；
  锚链恒定指向轨 wrap，不依赖 `visible` 三元切换。
- **坑位 71**：轨道 `visible` 绑定上游配置（`showXxx && !collapsed && !belowBreakpoint`），
  不绑自身 `height`，避免"初始 0 → 不可见 → 永不分配高度"自举死锁。
- **坑位 72**：Qt 6.12 下 `Connections` 须用标准 `function onFoo()` 语法（本组件无 Connections）。
- **库组件优先**：Header / Footer / Page / Separator 全取库组件，身份装饰为 `_` 私有纯几何，零手搓交互控件。

## 5. 相关资源

- 组合组件宪法：`docs/COMPOSITION_CONSTITUTION.md`（第 1 章三要素 / 第 9 章 CC-1~CC-8）
- 模块交付文档：`src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md`（21 项契约 + 依赖矩阵）
- 主报表区：`docs/controls/NovaDataGrid.md` · 数据层 `pyside_nova.datagrid`
- Gallery 第 21 页：`examples/gallery/layout_shells.qml`（`pgAIReport`，可独立加载、调参、明暗切换）
- 冻结清单：`api/nova-api-1.7.0.json` / 签署件 `docs/API_FREEZE.md`
- 组件自动生成文档：`docs/components/NovaAIReport.md`（生成器产物）
