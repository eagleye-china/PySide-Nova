> **NovaOrbit · 意图轨道工作台 ／ Intent Orbit Workspace**
> **pyside-nova 第 19 个组合根容器 · 企业级旗舰版封版法源**
>
> | 元项 | 值 |
> |---|---|
> | **版本** | `Enterprise Flagship v1.0-FINAL` |
> | **封版日期** | `2026-11-26` |
> | **封版状态** | `FINAL` |
> | **术语对仗** | NovaOrbit · 意图轨道工作台 ／ Intent Orbit Workspace |
> | **组件序号** | 第 **19** 个组合根容器（`Nova.Composite.LayoutShell`） |
> | **并入批次** | 1.1.0（未发布批次）· 整批**单次重签**冻结面：142→143 类型 ／ 18→19 组合根 ／ a11y `decorative` 82→83 |
> | **七件组件定位** | 呈现层 · NovaIncubator 七件组件收官件（「奇思妙想中的最后一个组合组件」） |
> | **一句话定位** | NovaChat 的天花板形态 · 七件组件的呈现层 · 本库第 19 个组合根容器 |
>
> **法源链（逐级援引，不得越级）**：
> `docs/CONSTITUTION.md`（母法，含第 13 章 API 冻结门禁）
> → `docs/COMPOSITION_CONSTITUTION.md`（组合组件宪法 1.0.0）
> → 第 9 章 CC-1~CC-8 组合态一致性契约
> → 《Prescient Layout Shell 封版规范 v2.1.0》
> → **本方案（NovaOrbit 正式封版法源）**
>
> **封版资格声明**：法定封版资格**只由母法第 13 章 API 冻结门禁授予**
> （整批单次重签后由生成器签署件确认）；本文档的 `FINAL` 指本方案作为设计法源定稿，
> **不自行宣称组件封版资格、不自行宣称已发布**，发布边界归 CSA。
>
> **史料沿革**：下方原方案抬头保留初稿封版日期 `2026-11-25` 作为史料；
> `2026-11-26` 完成法源完现并并入 1.1.0 未发布批次，**全文元信息以本块为准**。

---

以下方案将 NovaOrbit 定位为 **NovaChat 的天花板形态**：它不再是一个“更好的对话窗口”，而是 NovaChat 从**会话基座**跃迁为**意图轨道操作系统**的最终形态。WorkBuddy 的主窗口证明了三栏工作台的有效性，但它止步于“任务的工作台”；NovaOrbit 要在同一空间布局上，完成从 **“任务工作台”到“意图轨道”** 的范式升级。


# NovaOrbit：NovaChat + Orbit 标准（企业级旗舰版封版方案）

**版本**：Enterprise Flagship v1.0-FINAL
**封版日期**：2026-11-25
**定位**：NovaChat 的能力天花板；Agent / DE / Copilot 的统一编排面与最终呈现层


## 零、三要素与无业务语义骨架

> 依《组合组件宪法 1.0.0》第 1 章，NovaOrbit 的 QML 实现（`Nova.Composite.LayoutShell.NovaOrbit`）
> 是**组合性 + 槽位化 + 无业务语义**的纯布局骨架；本方案的 Orbit Engine、L1~L5 架构、
> 三栏业务定义，全部是**业务槽位将要注入的语义**，不是壳自身持有的能力。

### 0.1 三要素（宪法第 1 章冻结条款）

| 要素 | NovaOrbit 落地 |
|---|---|
| **组合性** | 由 ≥2 个已导出公共类型组合（`NovaTheme` / `NovaHeader` / `NovaFooter` / `NovaPage` / `NovaSeparator` / `NovaMotion`），不是单控件皮肤化包装 |
| **槽位化** | 7 个语义化槽位一律 `property alias`；槽位是纯布局托管点，Shell 只决定位置 / 尺寸 / 显隐 / 断点，不读写注入内容状态 |
| **无业务语义** | 不含轨道菜单 / 路由表 / 意图数据模型 / 业务文案 / 项目专属图标；脱离业务工程在 Gallery 可独立预览、调参、测试 |

**单向数据流**：属性向下传配置、信号向上报事件；`railToggled` / `canvasToggled` / `orbitRequested`
**只 emit、不自写宿主状态**（受控契约，宪法第 3 章第 4 条 / 母法第 9·12·13 章）。

### 0.2 壳内可验收项 vs 业务注入项

**治理与业务语义一律由业务槽位注入，Shell 不内置、不持有状态**——
Orbit Engine 轨道注册表 / 信号感知器 / Entity Router / 孵化轨道 / 活产物对象 / 意图路由 / 审计流，
均不进入壳的公共 API 与私有实现。

| 壳内可验收项（无业务语义 · 可机检） | 业务注入项（治理与业务语义 · Shell 不持有） |
|---|---|
| 左—中—右三栏骨架 + 全局栏 / 输入栏 / 轨道地图 / 浮层的 7 槽 `property alias` | **L4 Orbit Engine**：轨道注册表、轨道状态机、轨道依赖图 |
| `railSize` / `canvasSize` / `*Height` / `*Collapsed` / `breakpoint` / `bordered` 等公开配置与 `belowBreakpoint`(ro) 只读派生 | **信号感知器**：跨会话、跨时间的弱信号检测与孵化轨道提案 |
| 纯几何身份元素（三段轨道发丝线 / 递减轨道链 + 弧点 / 并行分叉角标 + 取景框 / 双向箭头环 + 拓扑点阵），主色系 · 实心度 ≥0.85 · 零字体依赖 | **L3 Entity Router**：按意图与风险等级路由 Agent / DE / Copilot、执行中切换实体 |
| `LayoutMirroring.enabled: NovaTheme.isRtl` / `// a11y: decorative` / Esc 收起两条折叠轨 | **孵化轨道 / 活产物对象**：低置信度轨道卡、产物可再入轨、拖拽绑定 |
| `NovaMotion.duration(NovaMotion.transitionDuration)` + `easingStandard` 共用的 `_dur` / `_ease` | **意图路由**：轨道路由语义、`@轨道` 指令、确认 / 忽略 / 灵敏度决策 |
| 几何入参 `_` 私有 `readonly` 钳制；槽位宿主 `anchors.fill: parent`；极端非法入参稳态几何非负 | **审计流 / 会话标识 / 租户上下文**：轨道 ID 与实体事件 ID 双向追溯 |
| `railToggled` / `canvasToggled` / `orbitRequested` 信号与 `toggleRail()` / `toggleCanvas()` / `requestOrbit()` 函数（只 emit） | **轨道事件与变更投影**：步骤干预、分叉 / 汇合、产物变更反查 |

> 一句话：**壳回答「三栏与七槽怎么摆、折叠怎么动、装饰长什么样」；业务回答「轨道是什么、意图怎么走、谁来执行、审计怎么记」。**
> 二者以槽位为唯一边界，任一越界（壳内出现轨道状态、业务要求改壳骨架）即判封版失格。

---

## 一、NovaOrbit 的标准定义：模仿什么，超越什么

### 1.1 WorkBuddy 主窗口的可迁移内核

WorkBuddy 的主窗口之所以有效，不在于“三栏”这个形式，而在于三栏分别承担了三种不可互相替代的认知负荷：

| 区域 | WorkBuddy 的职责 | 本质 |
|---|---|---|
| **左侧** | 能力管理：新建任务、助理、项目、专家·技能·连接器、定时任务、资料库 | **能力的库存视图** |
| **中间** | 任务对话：下发意图、补充上下文、观察执行、追问推进 | **意图到执行的转化通道** |
| **右侧** | 结果面板：产物、工作空间文件、变更、浏览器、终端，以标签页并存 | **工作的物理痕迹** |

三栏的设计哲学值得继承：左侧回答“我能调用什么”，中间回答“我正在让它做什么”，右侧回答“它已经留下了什么”。此外，WorkBuddy 的底层不是主从 Agent 调度，而是 **“路由 + Skill 市场”** ——Skill 以声明式 description 告知路由层自己能处理什么意图，能力扩展不修改核心代码。这一架构选择让 NovaOrbit 的“超越”有了可对标的工程基线。

### 1.2 NovaOrbit 的封版定义

**NovaOrbit 是一个以“意图轨道”为核心对象的 AI 工作宇宙：用户的每一个意图不被降格为一条消息，而被升格为一条可观测、可干预、可并行的轨道；Agent / DE / Copilot 不是被“选择”的工具，而是被轨道引擎按意图路由调度的执行实体。**

WorkBuddy 的三栏是 **“任务的工作台”** ；NovaOrbit 的三栏是 **“轨道的控制台”** 。区别在于：

- WorkBuddy 的中心是**当前任务**，NovaOrbit 的中心是**用户当前的意图集合**——可能是一件事，可能是五件事并行推进，也可能是一个尚未成形、正在被 Orbit 主动感知的弱信号；
- WorkBuddy 的右侧是**产物查看器**，NovaOrbit 的右侧是**活产物（Live Artifact）** ——产物本身可继续接收指令、可被重新编排、可作为下一条轨道的输入；
- WorkBuddy 的左侧是**功能入口的集合**，NovaOrbit 的左侧是**轨道与能力的融合视图**：能力因轨道而被召回，而非用户先打开能力再发起任务。

**一句话封版口径**：WorkBuddy 让 AI 进入工作台；NovaOrbit 让工作台本身成为可被意图驱动的轨道系统。


## 二、主窗口设计：三栏布局的“同构异质”超越

NovaOrbit 沿用 WorkBuddy 的 **左—中—右三栏骨架**，因为这一骨架在信息架构上已被验证为 AI 工作台的最优解之一。但每一栏的内部逻辑发生质变：**从“功能/任务/产物”升级为“轨道/意图/活产物”** 。

```
┌─────────────────────────────────────────────────────────────────────────┐
│  NovaChat 全局栏（身份 · 租户 · 全局搜索 · 通知）                       │
├──────────────┬──────────────────────────────────┬───────────────────────┤
│              │                                  │                       │
│  左栏        │          中栏                    │       右栏            │
│  Orbit Rail  │      Intent Field                │   Live Canvas         │
│              │                                  │                       │
│  轨道 +      │  意图场：当前活跃意图的          │  活产物画布：          │
│  能力融合    │  多轨道并行视图                  │  产物即对象           │
│  视图        │                                  │                       │
│              │  ┌────────────────────────────┐  │  ┌─────────────────┐  │
│  · 活跃轨道  │  │ 轨道 A：进行中             │  │  │ 产物卡片        │  │
│  · 暂停轨道  │  │ ├ 步骤 1 ✓                 │  │  │ （可拖拽入轨道）│  │
│  · 感知信号  │  │ ├ 步骤 2 ⟳                 │  │  └─────────────────┘  │
│  · 能力召回  │  │ └ 步骤 3 ○ 待确认          │  │                       │
│              │  ├────────────────────────────┤  │  · 文档 · 表格        │
│  · Agent     │  │ 轨道 B：已暂停（等待输入） │  │  · 网页 · 看板        │
│  · DE        │  ├────────────────────────────┤  │  · 终端 · 变更        │
│  · Copilot   │  │ 轨道 C：感知中（弱信号）   │  │                       │
│              │  └────────────────────────────┘  │  · 任意产物可         │
│              │                                  │    “继续这条轨道”     │
│              │  ── 统一意图输入栏 ──           │                       │
│              │  @轨道  /技能  +上下文           │  ── 全局轨道地图 ──   │
└──────────────┴──────────────────────────────────┴───────────────────────┘
```

### 2.1 左栏：Orbit Rail——轨道与能力的融合视图

**模仿 WorkBuddy 之处**：左侧承担“我能调用什么”的库存功能，WorkBuddy 将新建任务、助理、项目、技能、连接器、资料库集中在一列。NovaOrbit 保留“能力库存”作为左栏的底层语义。

**超越之处**：WorkBuddy 的左栏是**静态的能力菜单**——用户先打开“技能市场”或“专家中心”，再发起任务。NovaOrbit 的左栏是**动态的轨道视图**，能力不是被用户“浏览”的，而是被轨道“召回”的：

| 左栏区块 | 内容 | 与 WorkBuddy 的差异 |
|---|---|---|
| **活跃轨道列表** | 当前所有未关闭的意图轨道，按状态（执行中 / 待确认 / 暂停 / 感知中）分组 | WorkBuddy 左侧是历史任务列表；NovaOrbit 左侧是**活跃意图的态势** |
| **感知信号区** | Orbit 主动检测到的弱信号（如“截止日期临近”“某依赖已变更”“同类任务重复出现”），以**非侵入卡片**呈现，可一键“拉起为轨道” | WorkBuddy 有“意图预判”但停留在当前对话的下一步建议；NovaOrbit 将预判扩展到**跨会话、跨时间的信号层** |
| **能力召回抽屉** | 不在左栏常驻展示全部 Skill/专家；当用户在中栏输入意图时，左栏**动态高亮**本次轨道可能需要的技能与连接器，可拖入中栏作为轨道参数 | WorkBuddy 的能力需要用户主动进入市场寻找；NovaOrbit 的能力**因意图而浮现** |
| **执行实体切换** | Agent / DE / Copilot 不是三个独立入口，而是轨道的**执行模式选项**：同一条轨道可以在三种实体间切换（如从 Copilot 建议升级为 Agent 自动执行） | 这是 NovaOrbit 对前序三组件方案的关键整合：三组件不再分治，而是在轨道层统一调度 |

**设计判据**：如果左栏需要用户**先浏览再决策**，它就仍然是 WorkBuddy 式的库存；NovaOrbit 的左栏要求用户**先表达意图（或先看到信号），能力与轨道自动就位**。

### 2.2 中栏：Intent Field——意图场，而非对话流

**模仿 WorkBuddy 之处**：中间是意图下发与执行观察的主战场。WorkBuddy 的中栏以对话为容器，支持补充要求、追加消息队列、查看执行步骤，并在长对话中提供提问刻度导航。NovaOrbit 保留“中栏作为意图转化通道”这一定位。

**超越之处**：WorkBuddy 的中栏本质是**一条对话流**——即使有队列和追问，所有内容仍然线性堆叠在同一个对话中。NovaOrbit 的中栏是**多轨道的并行意图场**：

- **轨道卡（Orbit Card）取代消息气泡**：每一条活跃意图以独立的轨道卡呈现，卡片内包含步骤时间线、当前执行实体、待确认动作、关联产物。多条轨道可以在中栏**并排或堆叠**，用户在不同轨道间切换而不丢失上下文。
- **统一意图输入栏是“轨道调度器”** ：输入栏不再是“向当前对话发消息”，而是向**指定轨道或全局**发出调度指令。`@轨道A 把第三步改用报告格式` 是修改一条轨道；直接输入一个新目标则**创建一条新轨道**。WorkBuddy 的输入栏可以选模型、技能、连接器、附件；NovaOrbit 的输入栏额外承载**轨道路由语义**。
- **弱信号轨道的“孵化态”** ：Orbit 感知到的信号可以以低置信度轨道卡出现在中栏顶部（如“检测到：您本周有 3 份相似周报需要汇总”），用户可以**确认拉起**、**静默忽略**或**调整感知灵敏度**。这超越了 WorkBuddy 仅基于当前对话的提示词推荐。
- **执行过程的“可干预粒度”** ：WorkBuddy 允许在执行中追加消息并排队；NovaOrbit 允许对轨道内**任意未完成步骤**直接干预——跳过、替换执行实体、插入审批点、分叉为子轨道。干预本身被记录为轨道事件，而非混入对话历史。

**中栏的封版判据**：用户在中栏首先看到的是**意图的态势**，而不是**消息的堆积**。如果关闭所有轨道卡后中栏只剩下聊天气泡，说明设计退化回了 WorkBuddy。

### 2.3 右栏：Live Canvas——活产物画布，而非结果面板

**模仿 WorkBuddy 之处**：右侧是核心工作面板，以标签页承载产物、文件、变更、浏览器、终端，可同时打开、随时切换。WorkBuddy 还区分“聊天回复”与“产物”——PPT 的执行过程在中栏，生成的文件出现在右侧“产物”区。NovaOrbit 完全继承“右侧是工作的物理痕迹”这一原则，并保留标签页并存能力。

**超越之处**：WorkBuddy 的右侧是**被动的结果容器**——产物被生成后放进去，用户去查看。NovaOrbit 的右侧是**主动的对象画布**——产物本身是**一等交互实体**：

| 能力 | WorkBuddy 右栏 | NovaOrbit Live Canvas |
|---|---|---|
| **产物的身份** | 文件，属于当前任务 | **对象（Object）** ，拥有独立生命周期，可属于多条轨道 |
| **产物与轨道的连接** | 产物在右侧，轨道在中栏，查看需切换视线 | 任意产物可**拖拽回中栏**，作为新轨道的输入或某条轨道的替换输出；“继续这条轨道”动作内嵌于产物卡片 |
| **变更的理解** | 查看文件修改记录 | 变更被呈现为**轨道事件的投影**：哪条轨道的哪一步导致了这次变更，可反向追溯 |
| **终端的地位** | 一个标签页，独立工具 | 终端是**轨道的可编程延伸**：轨道中的某一步可“打开为终端会话”，人工接管后轨道暂停，终端关闭后轨道可继续 |
| **全局轨道地图** | 无对应物 | 右栏底部常驻**迷你轨道地图**：以拓扑视图展示所有活跃轨道之间的依赖与分叉关系，点击跳转中栏对应轨道卡 |

**右栏的封版判据**：如果用户只能在右侧“看”产物，它仍然是 WorkBuddy 面板；NovaOrbit 要求用户能**从产物发起动作、将产物重新投入轨道、或让产物成为另一条轨道的起点**。


## 三、Orbit 引擎：三栏背后的意图轨道架构

三栏是 NovaOrbit 的**可见层**。支撑其超越 WorkBuddy 的，是 WorkBuddy “路由 + Skill 市场”之上再叠加的一层**轨道引擎**。

### 3.1 五层架构

```
┌──────────────────────────────────────────────────────────────────┐
│ L5  呈现层：NovaChat 三栏（Orbit Rail / Intent Field / Live Canvas）│
├──────────────────────────────────────────────────────────────────┤
│ L4  轨道引擎（Orbit Engine）                                      │
│  · 轨道注册表：意图 → 轨道状态机（孵化 / 执行 / 暂停 / 待确认 / 关闭）│
│  · 轨道依赖图：轨道间的输入输出关系，支持分叉与汇合               │
│  · 信号感知器：跨会话、跨时间的弱信号检测，产出“孵化轨道”提案     │
│  · 干预路由器：将用户对任意步骤的干预映射为轨道事件               │
├──────────────────────────────────────────────────────────────────┤
│ L3  执行实体路由层（Entity Router）                               │
│  · 按轨道意图与风险等级，路由至 Agent / DE / Copilot              │
│  · 同一条轨道可在执行过程中切换实体（Copilot 建议 → Agent 执行）  │
├──────────────────────────────────────────────────────────────────┤
│ L2  能力层（Skill / Connector / Expert 市场，继承 WorkBuddy 范式）│
│  · 声明式注册：description 驱动路由，扩展不改核心代码             │
├──────────────────────────────────────────────────────────────────┤
│ L1  NovaChat 基座：会话 · 身份 · 审计 · 租户隔离                  │
└──────────────────────────────────────────────────────────────────┘
```

### 3.2 与 WorkBuddy 架构的关键差异

WorkBuddy 的核心创新是**路由层 + Skill 市场**：路由层判断意图，从 Skill 市场中调度自包含的 mini-Agent 执行，Skill 通过 description 声明能力边界。NovaOrbit 不抛弃这一层，但在它之上增加了**轨道引擎**，解决 WorkBuddy 架构中两个尚未被充分处理的问题：

1. **并行意图的状态管理**：WorkBuddy 的路由是“一次一个意图 → 一个 Skill → 返回结果”。当用户同时推进五件事、每件事需要不同实体在不同时间点介入时，路由层缺乏一个**跨意图的状态容器**。Orbit Engine 的轨道注册表正是这个容器。
2. **执行实体的可切换性**：WorkBuddy 的 Skill 是自包含的执行单元，但用户无法在同一条工作流中途从“Copilot 建议”切换到“Agent 自动执行”。NovaOrbit 将 Agent / DE / Copilot 从“并列的产品入口”降格为**轨道上的执行模式**，由 Entity Router 按需切换。

### 3.3 主动性的封版边界

WorkBuddy 的“意图预判”停留在当前对话的下一步提示层面。NovaOrbit 将主动性扩展到信号感知，但必须遵守一条**硬边界**：

> **信号可以发起“孵化轨道”，但孵化轨道不得在没有用户一次显式确认的情况下转化为执行轨道。**

这是 NovaOrbit 与“过度主动的 Ambient Agent”之间的分界线：信号驱动的价值在于**降低意图表达的成本**，而非绕过意图本身。孵化轨道在中栏以低置信度卡片出现，用户确认后才进入 Entity Router 的执行路径。


## 四、封版验收清单（NovaOrbit Sign-off Checklist）

| # | 验收域 | 封版判据 | 工程落点 | 归属 |
|---|---|---|---|---|
| O1 | **三栏同构异质** | 左栏不是静态能力菜单，中栏不是单一线程对话，右栏不是被动产物列表；三栏的默认状态分别呈现**轨道态势 / 意图场 / 活对象** | `railSlot` / `intentSlot` / `canvasSlot` 三槽默认态 + 三段发丝线 / 递减轨道链 / 双向箭头环身份装饰；机检：三槽宿主 `anchors.fill: parent`、注入顶层默认非空 | 壳内可验收 |
| O2 | **轨道引擎为核心** | 所有用户意图以轨道对象存在；关闭所有轨道后，系统不遗留“游离于轨道之外的对话上下文” | 轨道对象与状态机由业务注入 `intentSlot`；机检：壳内零内建轨道状态属性、`_` 私有成员不进冻结面 | 业务注入 |
| O3 | **实体可切换** | 同一条轨道可在 Agent / DE / Copilot 之间切换执行模式，切换事件写入轨道审计，不丢失已完成的步骤状态 | 执行模式切换与审计由业务注入 `railSlot`；机检：壳内只 emit `orbitRequested()`、不自写宿主状态 | 业务注入 |
| O4 | **产物的双向性** | Live Canvas 中的任意产物可被拖入中栏作为新轨道输入，或反向绑定回产生它的轨道；产物不是轨道生命周期的终点 | `canvasSlot` / `mapSlot` 拖拽与绑定由业务注入；机检：画布宿主铺满、`overlaySlot` 取 `NovaTheme.zFixedDrawer` 且透明 | 业务注入 |
| O5 | **主动性的硬边界** | 孵化轨道必须经用户显式确认方可执行；忽略信号不产生任何隐性执行；感知灵敏度可由用户/管理员调节 | `overlaySlot` 仅提供浮层槽位；机检：壳内无自动拉起 / 自动执行 / 定时器、无孵化态业务状态 | 壳内可验收 |
| O6 | **能力声明的可扩展性** | 新增 Skill / Connector 通过声明式注册接入，不修改 Orbit Engine 或三栏渲染层代码（继承并验证 WorkBuddy 的路由可扩展原则） | 声明式注册由业务层承担；机检：壳内依赖仅 6 个已导出公共类型、无私有原子、无虚构组件名 | 业务注入 |
| O7 | **与 NovaChat 基座的治理连续** | 轨道事件、实体切换、信号触发全部携带 NovaChat 会话标识与租户上下文；审计流中轨道 ID 与 Agent/DE/Copilot 事件 ID 可双向追溯 | 会话标识 / 租户上下文 / 审计流由业务注入；机检：壳内 `// a11y: decorative`、零业务文案 | 业务注入 |
| O8 | **降级安全** | Orbit Engine 不可用时，NovaChat 退化为可用的会话基座；Live Canvas 不可用时，产物仍可通过标准文件路径访问；不存在“轨道故障即全系统不可用”的单点 | 引擎不可用时 `intentSlot` 仍可渲染会话基座；机检：极端非法入参稳态几何非负、布局不塌、`_` 私有 `readonly` 钳制生效 | 壳内可验收 |

**判据可机检化**：上表「工程落点」列把 O1~O8 的设计判据逐行锚定到具体槽位、纯几何装饰与
机检断言——`anchors.fill` 铺满 / 零内建业务状态 / `zFixedDrawer` 透明浮层 / 依赖白名单 /
稳态几何非负，分别对应 `qmllint`、`scripts/audit_ceiling.py`（19/19）与装配态三态出图审计，
判据不再停留于主观描述；「归属」列区分**壳内可验收**（布局 / 装饰 / 契约 / 边界）与
**业务注入**（轨道引擎 / 意图路由 / 治理审计），与第零章两栏表一一对应。

**主动性硬边界 O5 的壳内体现**：孵化轨道必须经用户**一次显式确认**方可转为执行轨道；
壳侧只提供 `overlaySlot` 浮层槽位（取 `NovaTheme.zFixedDrawer`）承载「确认 / 静默忽略 /
调节灵敏度」的业务注入界面，**不内置信号感知器、不自动拉起孵化轨道、不自动执行、
不持有孵化态业务状态**。忽略信号不产生任何隐性执行——这条硬边界在壳内表现为
「零自动逻辑」，在业务注入层表现为人工闸门不可绕过；壳只 emit、不代宿主决策。

**封版结论**：NovaAgent / NovaDE / NovaCopilot 回答的是“AI 能做什么、以什么责任形态做”；**NovaOrbit 回答的是“这一切在工作台上如何被组织、被感知、被干预”** 。WorkBuddy 证明了 AI 工作台的三栏骨架和声明式能力路由是正确方向；NovaOrbit 在这一方向上完成两件事：**把“任务”升格为“轨道”，把“产物”升格为“可再入轨的对象”** 。当三栏的默认视图分别呈现轨道的态势、意图的并行、产物的活性时，NovaChat 才真正到达它的天花板形态。

---

## 五、组件级契约（NovaOrbit Component Contract）

> 与即将落地的 `Nova.Composite.LayoutShell.NovaOrbit.qml` 逐项一致；格式对齐
> `src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md` 的组件级契约写法。
> 全部依赖为**库内已导出公共类型**，无虚构组件名、无私有原子、无复制样式。

#### `NovaOrbit` — 意图轨道工作台 ／ Intent Orbit Workspace

- **槽位（7）**：`globalSlot`（NovaChat 全局栏）· `railSlot`（左栏 Orbit Rail）·
  `intentSlot`（中栏 Intent Field）· `composerSlot`（统一意图输入栏 · 轨道调度器）·
  `canvasSlot`（右栏 Live Canvas 活产物画布）· `mapSlot`（全局轨道地图）·
  `overlaySlot`（浮层，`NovaTheme.zFixedDrawer`）
- **配置**：`railSize` · `canvasSize` · `globalHeight` · `composerHeight` · `mapHeight` ·
  `showGlobal` · `showRail` · `showCanvas` · `showComposer` · `showMap` ·
  `railCollapsed` · `canvasCollapsed` · `breakpoint` · `bordered` · `belowBreakpoint`(ro)
- **信号**：`railToggled(bool collapsed)` · `canvasToggled(bool collapsed)` · `orbitRequested()`
- **函数**：`toggleRail()` · `toggleCanvas()` · `requestOrbit()`
- **受控契约**：信号与函数**只 emit 意图，不自写宿主 `railCollapsed` / `canvasCollapsed` 等状态**；
  宿主收到意图后自行决定是否修改配置（宪法第 3 章第 4 条）
- **身份元素**（纯几何 · 抽象 · 主色系 `primary` 单色系 · 实心度 ≥0.85 · 零字体依赖）：
  全局栏「三段轨道发丝线」；左栏「递减轨道链 + 感知信号弧点」；
  中栏「并行分叉角标 + 对角取景框」；右栏「双向箭头环 + 拓扑点阵地图」——
  与 `NovaChat` 六轨签名、`NovaAgent` / `NovaDE` / `NovaCopilot` 三 AI 组件身份**互不重复**，
  签名只占边缘 / 角标 / 列首列尾，中央完全留给业务注入
- **键盘**：`Esc` 对 `rail` / `canvas` 两条可折叠轨分别 emit 收起意图（只 emit 已有信号，不新增公共 API）
- **RTL**：根节点 `LayoutMirroring.enabled: NovaTheme.isRtl`
- **a11y**：容器根标 `// a11y: decorative`，不挂 `Accessible.*`；纯几何装饰逐块标注
- **动效**：`NovaMotion.duration(NovaMotion.transitionDuration)` + `NovaMotion.easingStandard`，
  两条折叠轨共用 `_dur` / `_ease`，`reducedMotion` 归零照旧
- **边界**：全部几何入参经 `_` 私有 `readonly property` 钳制后用于几何计算；
  槽位宿主 `anchors.fill: parent`（CC-6），**业务注入顶层须显式 `anchors.fill: parent`**
- **浮层**：`overlaySlot` 取 `NovaTheme.zFixedDrawer`，业务注入须为透明 / 空 `Item`
- **依赖**（6 个已导出公共类型）：`NovaTheme`（`Nova.Services`）·
  `NovaHeader` / `NovaFooter` / `NovaPage` / `NovaSeparator`（`Nova.Controls`）·
  `NovaMotion`（`Nova.Design`）

### 5.1 最小使用示例

```qml
import QtQuick
import QtQuick.Controls.Basic
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    visible: true
    width: 1440; height: 900
    color: NovaTheme.page

    NovaOrbit {
        anchors.fill: parent
        railSize: 260
        canvasSize: 360

        // 受控契约：宿主收到意图后自行决定是否修改配置
        onRailToggled: function(collapsed) { railCollapsed = collapsed }
        onCanvasToggled: function(collapsed) { canvasCollapsed = collapsed }
        // Shell 只 emit，是否新建轨道由业务侧决定
        onOrbitRequested: function() { }

        // 7 槽注入顶层一律显式 anchors.fill: parent（CC-6，否则 0×0 被裁）
        globalSlot:   Item { anchors.fill: parent }
        railSlot:     Item { anchors.fill: parent }
        intentSlot:   Item { anchors.fill: parent }
        composerSlot: Item { anchors.fill: parent }
        canvasSlot:   Item { anchors.fill: parent }
        mapSlot:      Item { anchors.fill: parent }
        overlaySlot:  Item { anchors.fill: parent }  // 透明顶层，取 zFixedDrawer
    }
}
```

> 真实可执行骨架：全部令牌取 `NovaTheme` 唯一门面、动效取 `NovaMotion`，
> 无虚构组件名、无伪造令牌门面、无 `title` 属性。轨道引擎 / 信号感知 / 意图路由 / 审计流
> 均由业务向 7 槽注入，壳不内置、不持有状态。

---

## 六、CC-1~CC-8 合规映射

> 依《组合组件宪法 1.0.0》第 9 章，NovaOrbit 作为第 19 个组合根容器逐条落地组合态一致性契约。

| 条款 | 契约要求 | NovaOrbit 具体落点 |
|---|---|---|
| **CC-1** 唯一组合上下文 | 根 Item 以 `_` 私有 `readonly` 声明组合上下文，所有轨道共享，禁止各轨散用 `NovaTheme.spacing*` 叠加 | 根 Item 声明 `_unit` / `_gap` / `_radius` / `_divider` / `_ink` / `_dur` / `_ease` 一组 `_` 私有 `readonly` 常量，7 槽（含 global / composer / map / overlay）共享同一密度栅格与分隔预算；`NovaPage` padding 与壳 padding 同值，消除三层偏移 |
| **CC-2** 单一分隔源 | 相邻轨边界只允许 1 个 `NovaSeparator` 或 1 级表面色阶；身份装饰不得落在边界线上 | 左 / 中、中 / 右相邻边界各仅 1 个 `NovaSeparator`（或 1 级 `surfaceAlt`→`surface` 色阶）；三段发丝线 / 递减轨道链 / 弧点 / 双向箭头环均退到栏首列尾或角标，不叠在边界线 |
| **CC-3** 装饰预算与主次 | 主签名 1 处 + 每轨次签名 ≤1，收敛主色系，装饰实心度 ≥0.85，**抽象几何不仿交互控件** | 主签名＝全局栏三段轨道发丝线；左 / 中 / 右各 ≤1 处次签名（递减轨道链 + 弧点 / 并行分叉角标 + 取景框 / 双向箭头环 + 拓扑点阵）；全部取 `primary` 单色系派生、`Rectangle` 旋转 / 点阵纯几何、零字体依赖、实心度 ≥0.85，无圆钮 / 搜索胶囊 / 伪 tab |
| **CC-4** 层级顺序 | `page` < `surfaceAlt`（轨）< `surface`（头 / 输入面板）< 浮起层；靠表面色阶 + 1px 分隔表达 | `page` 作底 → `surfaceAlt` 铺 `railSlot` / `intentSlot` 轨 → `surface` 抬 `globalSlot` / `composerSlot` 面板 → `shadowColor(level)` 浮起 `overlaySlot`；层级不靠多重描边 |
| **CC-5** 动效同步 | 折叠轨共用 `_dur` / `_ease`；锚定链**恒定指向轨 wrap**，禁用 `visible` 三元切换 | `rail` / `canvas` 两条折叠轨共用 `NovaMotion.duration(NovaMotion.transitionDuration)` + `NovaMotion.easingStandard`，栏高归零 + `Behavior on width` 共用 `_dur` / `_ease`，锚链恒指轨 wrap、无 `sep.visible ? … : …`，`reducedMotion` 归零 |
| **CC-6** 槽位内容基线 | 槽位宿主 `anchors.fill` 铺满；**业务注入顶层显式 `anchors.fill: parent`**；内容限宽；中央不塞空态占位 | 7 槽宿主 `anchors.fill: parent` 铺满并提供可协商 `implicit*`；最小示例 7 槽注入顶层逐槽示范 `anchors.fill: parent`；`intentSlot` 意图流限宽居中；中央空态由业务注入承担，壳不放占位 |
| **CC-7** 装配态验收 | 装配后出图审计；单组件 PASS ≠ 装配 PASS | 7 槽同屏密度 / 对齐 / 层级 / 装饰预算 / 伪控件扫描 / 空态 / 折叠动画稳态 / 浅深双主题实心业务注入，**浅 · 深 · 折叠三态出图**，并入 `scripts/audit_ceiling.py` 19/19 机检销号 |
| **CC-8** 参考实现纪律 | 成品级 showcase 真实业务注入、无占位文案；调参面板与展示区分离 | 独立演示为成品级「意图轨道工作台」showcase（7 槽真实业务内容注入，无占位文字），Gallery 调参面板默认收起、不与展示区同级 |

---

## 七、上位关系与七件组件

> 与 `docs/prescript/LAW_NovaIncubator.md` 第 2 节五层概念体系、第 5 节七件组件分层与 R1 配方对齐。
> NovaOrbit 是「奇思妙想中的最后一个组合组件」——七件组件收官的**呈现层**。

### 7.1 五层概念体系对齐

| 层级 | 中文 / 英文 | NovaOrbit 的位置 | 不得混淆 |
|---|---|---|---|
| 载体层 | 预判布局壳 ／ Prescient Layout Shell | 提供 7 槽无业务语义骨架（本组件即此类公共类型） | 不是范式、不是孵化器 |
| 范式层 | 预构范式 ／ Prescript | 壳先于页、槽位即边界、契约即接口 | 不定义轨道业务语义 |
| 孵化层 | 诺瓦应用孵化器 ／ NovaIncubator | 以配方选型，把 NovaOrbit 编入 R1 | 不是运行时组件 |
| 组件层 | 七件组合组件 | **呈现层**：NovaOrbit（第 19 个组合根容器） | 不是端载体、不是智能实体 |
| 品质层 | CARF 品质流水线 ／ CARF | 以 O1~O8 + CC-1~CC-8 逐项销号、封版 | 不是孵化器、不是范式 |

> **五层别称对照**（与上位文档互换）：**壳体层**＝载体层（预判布局壳 ／ Prescient Layout Shell）·
> **Prescript**（预构范式）· **Incubator**（诺瓦应用孵化器）· **组件层**（七件组合组件）·
> **CARF**（品质流水线）。NovaOrbit 恒居**组件层之呈现层**，不越任一上位层。

**层级铁律**：Prescript 管「怎么编写」、NovaIncubator 管「把什么组合、孵成什么应用」、
CARF 管「什么时候算封版交付」、**NovaOrbit 管「应用呈现给用户时，工作台长什么样」**；
五层各司其职，任一越界即判封版失格。

### 7.2 R1 配方与编排面定位

- **R1 · Orbit 旗舰工作台**（NovaIncubator 5.2 首发配方）必选件：
  `NovaDesk + NovaFlexLayout + NovaOrbit + NovaCopilot`（`NovaAgent` / `NovaDE` 可选）；
  配方门禁＝**NovaOrbit 封版清单 O1–O8 全过 + Copilot 人工闸门不可绕过**。
  NovaOrbit 是 R1 的**必选件**，不是可选装饰。
- **编排面 vs 执行实体**：与 `NovaAgent` / `NovaDE` / `NovaCopilot` 不是并列产品入口——
  三组件是轨道上被 Entity Router 调度的**执行实体**，NovaOrbit 是它们的**统一编排面与最终呈现层**；
  呼应原文 2.1「三组件不再分治，而是在轨道层统一调度」与 3.2「降格为轨道上的执行模式」。
- **不与端载体层越界**：`NovaDesk` / `NovaMobile` / `NovaFlexLayout` 属端载体层，
  负责承载桌面 / 移动 / 大屏的标准外观与全端骨架；NovaOrbit 只负责呈现层三栏编排，
  不重写四象限排布、不复制断点收起实现（宪法第 1 章第 3 条 / 母法第 10 章）。

---

## 八、异常与降级边界

> 呼应 O8 降级安全判据：轨道引擎不可用时退化为可用会话基座，壳只保证**布局不塌**。

| 异常 | 业务层降级（业务注入负责） | 壳内保证（可机检） |
|---|---|---|
| **Orbit Engine 不可用 / 轨道注册表为空** | 退化为可用的 NovaChat 会话基座，意图以普通会话消息承载 | 三栏骨架与 7 槽宿主稳态几何非负、不溢出，`intentSlot` 仍可渲染；壳内无引擎依赖 |
| **Live Canvas 不可用** | 产物仍可通过标准文件路径访问 | `canvasSlot` 折叠 / 隐藏后中—右锚链恒定、无布局跳变（CC-5） |
| **信号感知器 / 孵化轨道异常** | 停止孵化提案，不自动转执行；人工闸门保持 | 壳内零定时器、零自动拉起逻辑（O5 硬边界） |
| **极端非法入参**（负尺寸 / 超大尺寸 / 非法枚举同时注入） | — | `_` 私有 `readonly` 钳制后稳态几何非负、有限、无残留；`undefined` / 空值回退安全默认值 |
| **窗口极小 / 最大化 / 全屏** | — | `breakpoint` / `belowBreakpoint`(ro) 驱动自适应，布局不丢元素、不溢出（宪法第 7 章） |

**边界底线**：不存在「轨道故障即全系统不可用」的单点。壳不承载轨道引擎、不持有孵化态状态，
故引擎降级时壳**只保证布局不塌**，会话可用性与产物可达性由业务注入层按上表兜底。

---

## 九、CARF 四阶段封版记录

> 依《组合组件宪法 1.0.0》卷首 CARF 宣言（组合组件执行版）与母法卷首，逐阶段登记落地。

| 阶段 | NovaOrbit 落地 | 法条锚点 |
|---|---|---|
| **C 构想** | 本方案（WorkBuddy 三栏对标 · 三栏同构异质 · 五层架构 L1~L5 · 主动性硬边界 · O1~O8）+ 组合宪法 1.0.0 + 第 9 章 CC-1~CC-8 + 封版规范 v2.1.0 法源先行 | 第 0 章 / 第 9 章 |
| **A 实现** | `NovaOrbit.qml` + 7 槽 `property alias` + `qmldir` 导出 + a11y `decorative` 登记 + **1.1.0 整批单次重签冻结面**（142→143 类型 ／ 18→19 组合根 ／ `decorative` 82→83） | 第 1/2/4/5/8 章 · 母法第 13 章 |
| **R 打磨** | 六维天花板逐项评估 + 浅 / 深 / 折叠**三态装配图**出图审计 + `scripts/audit_ceiling.py` **19/19** 机检销号（静态 CC 契约 / 实例化 / 极端非法入参稳态几何 / RTL / reducedMotion / 断链扫描） | 第 9 章 CC-7 · `CEILING_AUDIT.md` |
| **F 封版** | 公共 API 签名逐字不变、整批单次重签后零漂移 + `CHANGELOG` / 权威清单 / `PARITY` / 账本 / AI 离线副本闭环；**发布边界归 CSA** | 第 8 章第 6 条 · 母法第 13 章 |

**执行铁律**：整批登记、单次重签、整批验收，禁止逐个重签产生中间指纹；
封版资格由母法第 13 章 API 冻结门禁授予，本记录为交付物登记，不自行宣称已发布。

---

## 十、封版声明

> **NovaOrbit · 意图轨道工作台 ／ Intent Orbit Workspace**

- **中文正式定义**：NovaOrbit（意图轨道工作台）是本库第 19 个组合根容器、NovaChat 的天花板形态与 NovaIncubator 七件组件的呈现层，以左—中—右三栏同构异质骨架承载意图轨道的编排面，治理与业务语义全由 7 个业务槽位注入，经 CARF 四阶段与 O1~O8 验收封版。
- **英文正式定义**：NovaOrbit (Intent Orbit Workspace) is the 19th composite root container — the ceiling form of NovaChat and the presentation layer of the seven NovaIncubator components — hosting the orchestration surface of intent orbits on a three-column isomorphic-heterogeneous skeleton, with all governance and business semantics injected through seven slots, frozen under CARF and the O1–O8 sign-off checklist.
- **术语对仗**：NovaOrbit · 意图轨道工作台 ｜ Intent Orbit Workspace
- **封版状态**：`FINAL` ／ `Enterprise Flagship v1.0-FINAL`（设计法源层）
- **封版底线**：三栏默认视图分别呈现**轨道态势 / 意图并行 / 产物活性**；孵化轨道不得未经确认转为执行轨道。
- **法源与资格**：母法 `docs/CONSTITUTION.md` → 组合宪法 1.0.0 → 第 9 章 CC-1~CC-8 → 封版规范 v2.1.0 → 本方案；法定封版资格只由母法第 13 章 API 冻结门禁整批单次重签授予，**本文档不自行宣称组件封版资格、不自行宣称已发布，发布边界归 CSA**。

> **收束句**：一「轨」统三栏，一「槽」分壳业；七件组件至此收官、第 19 个组合根归位，
> 呈现层封版——NovaChat 自此从会话基座跃迁为意图轨道操作系统，抵达天花板形态。
