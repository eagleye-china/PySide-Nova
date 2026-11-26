本方案由 `LAW_NovaAgent.md` / `LAW_NovaDE.md` / `LAW_NovaCopilot.md`（原联合总纲已拆分归档） 联合封版方案拆分而来，总纲见该文件。

# NovaDE 企业级旗舰版封版方案

> **NovaDE · 数字员工岗位工作台 / Digital Employee Post Workspace**
> AI 智能组合根（3）之一 · 模块 `Nova.Composite.LayoutShell` · 冻结公共类型

| 元信息 | 值 |
|---|---|
| **版本** | Enterprise Flagship v1.0-FINAL |
| **封版日期** | 2026-11-26 |
| **封版状态** | FINAL |
| **法源** | 母法 `docs/CONSTITUTION.md` → 组合组件宪法 1.0.0（`docs/COMPOSITION_CONSTITUTION.md`）→ 第 9 章 CC-1~CC-8 → 《Prescient Layout Shell · 封版规范 v2.1.0》 |
| **权威事实源** | `src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md`「AI 智能组合根（3）」段 · `docs/COMPONENT_LIST.md`（生成器产物，禁止手改） |
| **封版资格声明** | **封版资格只由母法第 13 章 API 冻结门禁授予，本文档不自行宣称**；本文的 `FINAL` 是方案定稿状态，非冻结门禁结论。 |

> **封版原则（承自总纲）**：定义即接口，接口即治理边界；组件间能力不越界，治理不重复，交付物可验收。

---

## 一、一句话标准定义与三维判据定位

**NovaDE 不是“能力更强的 Agent”，而是一个被赋予组织岗位、持有任务队列、在统一治理下跨系统完成工作的数字化工作实体。**

> 上句为原文封版口径逐字保留；数字员工与 Agent 的分界不在于技术复杂度，而在于**是否具备岗位形态**——四要件缺一不可。

三维判据定位（取联合方案总表 NovaDE 列，逐字）：

| 维度 | NovaDE |
|---|---|
| **自主程度** | 高（岗位内自主） |
| **责任归属** | 岗位持有者（组织角色） |
| **交付契约** | 队列工作量 + 验收记录 |
| **NovaChat 角色** | 工单/队列接入与状态回传 |

**可机检判据转写**（把定义落成验收动作，见第七、八章）：
- 「持有任务队列」→ 由业务向 `queueSlot` 注入队列视图，`showQueue` / `queueCollapsed` 只管布局与折叠意图。
- 「在统一治理下跨系统完成工作」→ 由业务向 `roleSlot` 注入岗位定义、`slaSlot` 注入 SLA 监控，队伍级 SSO/RBAC/审计全部属业务注入。
- 「跨任务持久身份」→ 壳不持有会话与身份数据，身份由 NovaChat 基座经业务槽位透传。

---

## 二、标准定义（原文完整章节，史料逐字保留）

### 2.1 封版口径

**NovaDE 不是“能力更强的 Agent”，而是一个被赋予组织岗位、持有任务队列、在统一治理下跨系统完成工作的数字化工作实体。** 数字员工与 Agent 的分界不在于技术复杂度，而在于**是否具备岗位形态**：

> Agent 是能力本身；数字员工是把 Agent 装进岗位外壳之后的产物。Agent 交出结果，数字员工对一条队列负责。

**NovaDE 的四要件（缺一不可）** ：

| 要件 | 标准要求 | 封版判据 |
|---|---|---|
| **岗位形态** | 持有某一职能（如“应付单据处理”“一线客服分流”），来什么处理什么，而非等待单一触发器 | 仍是“一个触发、一条固定路径”则不是数字员工 |
| **任务队列** | 拥有独立队列，工作可能跨小时/跨系统，周期可长 | 无队列则无法度量工作量与 SLA |
| **能力调用而非内嵌** | 业务能力从共享技能层调用，岗位不各自重造能力 | 每个新岗位需重造一遍能力则不合格 |
| **治理面向队伍** | 身份、权限、脱敏、审计在队伍层统一配置，不按实例逐配 | 规模上量后再补治理 = 一次迁移项目 |

参考 AI Worker Standard 1.0 的正式定义：数字员工是 “an AI work entity with an identity that persists across tasks, defined responsibilities, an authorization boundary, and deliverables that can be checked” —— 核心在于**跨任务持久的身份、可核验的交付物、以及明确的授权边界**，而非法律人格或永久进程。

> **治理归属声明**：上表四要件、岗位注册表、队伍级 SSO/RBAC、Shadow Mode、技能层共享、SLA 监控与人工介入边界均是**业务治理语义**，由业务槽位注入（见第六章）；NovaDE 作为无业务语义骨架不实现、不判定、不代持其中任何一项。

---

## 三、实现方案（原文分层架构 + 全部关键实现约束，逐字保留）

NovaDE 采用 **控制层 / 执行层 / 技能层** 三层分离架构，NovaChat 作为队列接入与人工交接的交互面：

```
┌──────────────────────────────────────────────────────────────┐
│ NovaChat 交互面：队列视图 · 交接通知 · 人工补录 · 验收确认  │
├──────────────────────────────────────────────────────────────┤
│ 控制层（DE Control Plane）                                   │
│  · 岗位注册表（岗位定义 · 责任边界 · 验收合约）              │
│  · 队伍级治理：SSO · 角色 RBAC · 租户隔离 · 审计            │
│  · 队列调度与 SLA 监控 · 用量与成本归因                      │
├──────────────────────────────────────────────────────────────┤
│ 执行层（DE Worker）                                           │
│  · 岗位实例：从队列领取任务，自主规划步骤                   │
│  · 跨系统操作：ERP / CRM / HRIS / 文档系统                  │
│  · 人工介入边界执行：自动 / 生成待审 / 转人工，边界写死     │
├──────────────────────────────────────────────────────────────┤
│ 技能层（共享能力池，版本化管理）                             │
│  · 系统操作技能（APA）· 文档理解技能（ADP）· 知识技能（ACX）│
│  · 第三方 MCP 技能接入                                       │
└──────────────────────────────────────────────────────────────┘
```

关键实现约束：

- **岗位定义先于技术配置**：部署 NovaDE 的第一步是书面回答四问——这个岗位拥有哪一项单一职能（尽量窄）、需要哪些数据与工具、何时必须升级给人、用哪两个核心指标度量成功。岗位定义作为注册表中的不可变合约版本化存储。
- **影子模式强制**：新 DE 上线前必须在 Shadow Mode 中运行至少 48 小时，生成应答与动作草案但不执行，经人工审核通过率达标后方可切换至 Draft / Auto。
- **人工介入边界固化为策略**：每一步的执行模式（Auto / Draft / Handoff）在岗位合约中声明，不在运行时由模型“判断要不要找人”。边界文档是治理部署与事故之间的唯一分界。
- **技能层共享**：流程变更在技能层修改一次，所有调用该技能的岗位同步继承，杜绝“每岗一版流程”的版本分裂。

> 上图与四条约束是**业务实现范式**史料，逐字保留；它们描述「业务侧怎么建数字员工队伍」，不是 Shell 的槽位契约。Shell 只提供承载这些注入内容的布局骨架（第四章）。

### 3.1 异常与降级边界（新增）

| 场景 | 安全出口（业务注入责任） | 壳侧保证（可验收） |
|---|---|---|
| 缺数据 / 队列为空 | 按岗位合约升级路径挂起，不即兴造任务 | `queueSlot` 空注入下不溢出、稳态几何非负 |
| 阻塞 / SLA 临期 | 触发 Handoff 转人工，交接事件独立入审计流 | `handoffRequested()` 只 emit 意图，不自写宿主状态 |
| 越界（授权 / 脱敏 / 跨系统） | 边界写死：自动 / 生成待审 / 转人工，不由模型判断 | `roleSlot` / `handoffSlot` 收起不产生布局跳变 |
| 控制层 / 技能层不可用 | 退化为 NovaChat 会话基座：保留队列视图、交接通知、人工补录、验收确认，不自动领取任务 | 壳本身即会话骨架，天然可退化，无单点故障 |
| Shadow Mode 未达标 | 不切换至 Draft / Auto，只产出草案 | 草案态由业务槽位注入，壳不塞占位 |

---

## 四、组件级契约（新增 · 与真实 QML 完全一致）

> 本节逐项对齐 `Nova.Composite.LayoutShell` 模块 README「AI 智能组合根（3）」的 `NovaDE` 条目，为**冻结公共 API 面**的文档化复述；`_` 前缀私有成员不进冻结面。

### 4.1 槽位（6，均为 `property alias` 纯布局托管点）

| 槽位 | 承载位置 | 典型业务注入（治理语义由业务负责） |
|---|---|---|
| `roleSlot` | 顶部岗位条 | 岗位定义 / 菱形徽记视图 / 责任边界 |
| `queueSlot` | 左队列列 | 独立任务队列视图（按岗位持有） |
| `contentSlot` | 中央工作画布 | 岗位实例的执行主工作区 |
| `slaSlot` | SLA 轨 | SLA 监控 / 交付物验收记录 |
| `handoffSlot` | 交接条 | 人工补录 / 转人工 / 验收确认卡片 |
| `overlaySlot` | 浮层区 | 交接弹层 / 提示（透明空 `Item`，取 `NovaTheme.zFixedDrawer` 等 z 层叠令牌） |

### 4.2 配置 / 信号 / 函数 / 身份 / 依赖

| 类别 | 冻结契约 |
|---|---|
| **配置** | `queueSize` · `slaSize` · `roleHeight` · `handoffHeight` · `showQueue` · `showSla` · `showRole` · `showHandoff` · `queueCollapsed` · `slaCollapsed` · `breakpoint` · `bordered` · `belowBreakpoint(ro)` |
| **信号** | `queueToggled(bool collapsed)` · `slaToggled(bool collapsed)` · `handoffRequested()` |
| **函数** | `toggleQueue()` · `toggleSla()` · `requestHandoff()` |
| **身份元素** | 岗位菱形徽记 + 队列堆叠卡沿 + SLA 递减条 + 交接双向箭头（与 NovaAgent / NovaCopilot 身份互不重复） |
| **依赖** | Theme · Header · Footer · Page · Separator · Motion（即 `NovaTheme` / `NovaHeader` / `NovaFooter` / `NovaPage` / `NovaSeparator` / `NovaMotion`，全部为库内已导出公共类型） |

### 4.3 统一工程约束（三组件一致，逐项可机检）

| 约束 | 落点写法 | 机检项 |
|---|---|---|
| RTL | 根节点 `LayoutMirroring.enabled: NovaTheme.isRtl` | 声明式镜像扫描 |
| a11y | 根 Item 标 `// a11y: decorative`，不挂 `Accessible.*` | `check_a11y.py` decorative 登记 |
| 键盘可达 | `Esc` 对队列列 / SLA 轨两条可折叠轨分别 emit 收起意图（只 emit，不自写宿主状态、不新增公共 API） | `focus: true` + `Keys.onEscapePressed` 扫描 |
| 动效 | 一律 `NovaMotion.duration(NovaMotion.transitionDuration)` + `NovaMotion.easingStandard` | 无字面时长扫描 |
| 几何鲁棒 | 全部几何入参经 `_` 私有 `readonly property` 钳制后方可参与计算 | 极端非法入参稳态几何非负 |
| 槽位基线（CC-6） | 槽位宿主 `anchors.fill: parent` 并提供可协商 `implicit*` | 对象树几何打印，无 0×0 / 负宽高 |
| 注入基线 | 业务注入顶层须显式 `anchors.fill: parent` | 最小示例示范并实测可实例化 |

---

## 五、治理边界 · 无业务语义骨架（新增）

按组合组件宪法第 1 章三要素，NovaDE 是**立于母法 L1 之上的无业务语义骨架**：由 ≥2 个已导出公共类型组合而成（组合性）、以固定语义化 `property alias` 提供单向注入点（槽位化）、不含业务菜单/路由/数据模型/文案/专属图标（无业务语义），可在 Gallery 独立预览、独立调参、独立测试。

**Shell 只托管布局与折叠意图**：四要件、岗位注册表、队伍级 SSO/RBAC/租户隔离、Auto/Draft/Handoff 人工介入边界、Shadow Mode、技能层共享、SLA 监控、用量与成本归因等治理语义**全部由业务槽位注入**，Shell 只 emit 意图、不判定、不代持、不写宿主状态（受控契约，宪法第 3 章第 4 条）。

| 壳内可验收项（Shell 负责） | 业务注入项（槽位负责，治理语义） |
|---|---|
| 6 槽的位置 / 尺寸 / 显隐 / 断点行为 | 岗位形态 · 任务队列 · 能力调用 · 队伍级治理 四要件的判定 |
| 两条折叠轨的展开/收起意图（emit-only） | 岗位注册表（不可变合约）、责任边界、验收合约 |
| `belowBreakpoint(ro)` 自适应与 RTL 镜像 | 队伍级 SSO / 角色 RBAC / 租户隔离 / 脱敏 / 审计 |
| 身份装饰纯几何、实心度 ≥0.85、零业务语义 | Auto / Draft / Handoff 边界策略、Shadow Mode ≥ 48h |
| 明暗双主题 / `NovaMotion` 动效 / 几何钳制 / a11y | 共享技能池（APA / ADP / ACX）、第三方 MCP 技能 |
| 槽位宿主铺满、`overlaySlot` 透明契约 | 队列视图、SLA 看板、交接卡片、验收确认等全部内容 |

---

## 六、CC-1~CC-8 合规映射（新增）

| 条款 | NovaDE 具体落点 | 机检 / 验收动作 |
|---|---|---|
| **CC-1 唯一密度源** | 根 Item 以 `_` 私有 `readonly` 声明唯一组合上下文 `_unit/_gap/_dur/_ease`（及 `_radius/_divider/_rail/_panel/_ink`），6 槽共享，不各轨散用间距令牌 | 组合上下文常量扫描 + padding 叠加检查 |
| **CC-2 单一分隔源** | 岗位条 / 队列列 / 画布 / SLA 轨 / 交接条相邻边界只保留 1 个 `NovaSeparator` 或 1 级表面色阶，渐变缘轨不落在边界线上 | 同边界多重线扫描 |
| **CC-3 抽象几何装饰** | 菱形徽记 / 堆叠卡沿 / SLA 递减条 / 双向箭头一律抽象几何，不仿圆钮、搜索胶囊、图标方块等交互控件 | 伪控件扫描 + 装饰实心度 ≥0.85 |
| **CC-4 层级顺序** | `page` < `surfaceAlt`（队列/SLA 轨）< `surface`（岗位条/交接条）< 浮起层，靠色阶 + 1px 分隔表达，不靠多重描边 | 表面色阶出图审计 |
| **CC-5 动效同步** | 队列列 / SLA 轨两折叠轨共用 `_dur/_ease`，锚定链**恒定指向轨 wrap** + `Behavior`，不用 `visible` 三元切换 | 折叠动画稳态 + `reducedMotion` 短路 |
| **CC-6 槽位铺满** | 6 槽宿主 `anchors.fill: parent` + `implicit*`，业务注入顶层显式 `anchors.fill: parent`，中央内容区不塞空态占位 | 对象树几何打印，无 0×0 / 负宽高 |
| **CC-7 装配态出图** | 浅色 / 深色 / 折叠**三态**装配图审计：6 轨同屏密度 / 对齐 / 层级 / 装饰预算 / 伪控件 / 空态 / 实心业务注入 | 三态出图 + `audit_ceiling.py` 机检 |
| **CC-8 成品级 showcase** | Gallery 独立演示注入真实队列工单 / 岗位卡 / SLA 看板 / 交接记录，无「XX（注入业务）」占位文案，调参面板默认收起且与展示区分离 | `audit_showcase.py` 占位文案扫描 |

---

## 七、封版验收清单 A1~A8（原联合清单 NovaDE 列 + 新增「工程落点」）

| # | 验收域 | NovaDE（原文逐字） | 工程落点（槽位 / 装饰 / 机检项 / 业务注入责任） |
|---|---|---|---|
| A1 | 身份与租户隔离 | 队伍级 SSO + 岗位 RBAC + 租户隔离 | `roleSlot` 注入岗位身份视图；RTL + a11y 机检；SSO/RBAC 由业务注入 |
| A2 | 审计完整性 | 队列动作 + 人工交接 + 验收确认全链路 | `queueSlot` / `handoffSlot` 注入事件流；emit-only 机检；审计写入由业务注入 |
| A3 | 人工介入点 | 岗位合约声明 Auto/Draft/Handoff 边界 | `handoffSlot` + 交接双向箭头装饰 + `handoffRequested()` 机检；边界合约由业务注入 |
| A4 | 外部可验证信号 | 交付物可核验（文件/状态/记录） | `slaSlot` + SLA 递减条装饰 + `contentSlot`；验收记录由业务注入 |
| A5 | 异常安全出口 | 岗位合约定义升级路径与兜底规则 | 见 §3.1 异常与降级边界；几何钳制机检；升级路径由业务注入 |
| A6 | 能力复用机制 | 技能层共享，改一处全岗位继承 | `contentSlot` 注入技能视图；依赖清单机检（无私有原子）；技能池由业务注入 |
| A7 | 影子/灰度能力 | 强制 Shadow Mode ≥ 48h | `showSla` / `slaCollapsed` 折叠意图 + 恒定锚链机检；草案态由业务注入 |
| A8 | 成本可观测 | 队伍级用量与 SLA 看板 | `slaSlot` / `overlaySlot` 注入看板；`belowBreakpoint(ro)` 机检；归因由业务注入 |

> 任一 A 项未通过，该组件不得进入生产封版。工程落点列只标定**壳侧可机检位置**，判据本身的达标责任在业务注入侧。

---

## 八、CARF 四阶段封版记录（新增）

| 阶段 | 落地内容 | 门禁 / 产物 |
|---|---|---|
| **C 构想** | 本方案（一句话定义 + 四要件 + AI Worker Standard 1.0 + 三维判据）与组合组件宪法 1.0.0 立方向、立标准、立验收；法源先行 | 法源链：母法 → 组合宪法 → CC-1~CC-8 → 封版规范 v2.1.0 |
| **A 实现** | QML 组合根落地 + `qmldir` 导出 + a11y `decorative` 登记 + 1.1.0 冻结面整批单次重签（新增公共类型走母法第 13 章完整流程） | 6 槽 / 配置 / 信号 / 函数冻结签名；`PARITY.md` 审计节、生成物重跑 |
| **R 打磨** | 六维天花板逐项评估 + 浅/深/折叠三态装配图 + `scripts/audit_ceiling.py` 机检（静态 CC 契约 + 实例化 + 极端非法入参稳态几何 + RTL + reducedMotion + 断链扫描） | 三态出图审计 PASS；`CEILING_AUDIT.md` 逐项销号 |
| **F 封版** | 公共 API 签名逐字不变、冻结面零漂移、宪法 / CHANGELOG / 权威清单 / 账本闭环；**发布边界归 CSA** | `check_all.py --tier static` 全绿；封版资格由母法第 13 章门禁授予 |

---

## 九、封版声明（新增）

**正式定义（中）**：NovaDE 是 pyside-nova 企业级旗舰版中、以 NovaChat 为统一交互基座、以四要件齐备为岗位形态、在队伍级治理下对一条任务队列负责的数字员工岗位工作台组合根容器，其壳仅托管布局与折叠意图。
**Formal Definition (EN)**: NovaDE is the Digital Employee Post Workspace composition root in pyside-nova Enterprise Flagship, grounded on the NovaChat interaction base, qualified by four essential requirements as an organizational post, and accountable for a task queue under fleet-level governance, whose shell hosts layout and collapse intent only.

**封版底线**：NovaDE 的封版底线是**四要件齐备且控制层先于规模到位**（原文封版结论逐字保留）。

**组件关系与不越界**（另两件见 [`LAW_NovaAgent.md`](LAW_NovaAgent.md) 与 [`LAW_NovaCopilot.md`](LAW_NovaCopilot.md)，原联合总纲已拆分归档为 `LAW_NovaAgent.md` / `LAW_NovaDE.md` / `LAW_NovaCopilot.md` 三份独立法源）：

| 维度 | NovaAgent | NovaDE（本文） | NovaCopilot |
|---|---|---|---|
| 自主程度 | 中—高（任务内自主） | 高（岗位内自主） | 低—中（建议 + 受限执行） |
| 责任归属 | 任务发起人 | 岗位持有者（组织角色） | 交互中的操作者 |
| 交付契约 | 任务结果 + 推理链 | 队列工作量 + 验收记录 | 建议 + 可撤销动作 |
| 身份元素 | DAG 链 / 渐变轨 / 取景框 / 审批色带 / 递减条 | 菱形徽记 / 堆叠卡沿 / SLA 递减条 / 双向箭头 | 内联胶囊 / 确认级条 / 闸门渐变点 / 撤销弧环 |
| 不越界约定 | 不持任务队列、不承载岗位形态、不内建人工确认闸门语义 | 不做单次任务自主规划、不抢占执行画布 | 不做任务自主执行、不提升 grounding 权限 |

> 三者共享 NovaChat 基座与统一治理层，在自主性光谱上形成从「建议」到「岗位执行」再到「任务自主」的清晰梯度，互不替代，也互不留下治理真空（原文封版结论逐字保留）。
>
> **收束句：治理语义由业务注入，壳不越界。** 四要件、岗位注册表、队伍级治理、Shadow Mode、人工介入边界、技能层共享、SLA 归因等一切治理判据，均由业务向 6 个槽位注入；NovaDE 只提供可组合、可折叠、可机检的无业务语义骨架，封版资格由母法第 13 章 API 冻结门禁授予，发布边界归 CSA。
