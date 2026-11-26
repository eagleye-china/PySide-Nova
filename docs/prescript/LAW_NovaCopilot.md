本方案由 `LAW_NovaAgent.md` / `LAW_NovaDE.md` / `LAW_NovaCopilot.md`（原联合总纲已拆分归档） 联合封版方案拆分而来，总纲见该文件。

# NovaCopilot 企业级旗舰版封版方案

> **NovaCopilot · 增强型协作面板 / Augmented Collaboration Panel**
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

**NovaCopilot 是嵌入用户现有工作流、以“建议—确认—执行”为交互契约、始终将最终决策权保留给人类的增强型协作智能层。**

> 上句为原文封版口径逐字保留；标准聚焦于**嵌入性与可控性**，而非自主性。

三维判据定位（取联合方案总表 NovaCopilot 列，逐字）：

| 维度 | NovaCopilot |
|---|---|
| **自主程度** | 低—中（建议 + 受限执行） |
| **责任归属** | 交互中的操作者 |
| **交付契约** | 建议 + 可撤销动作 |
| **NovaChat 角色** | 内嵌于工作流的交互面板 |

**可机检判据转写**（把定义落成验收动作，见第七、八章）：
- 「输出是建议与待确认动作」→ 由业务向 `suggestSlot` 注入建议、`gateSlot` 注入待确认动作，`actionProposed()` 只上报提案意图，不执行变更。
- 「最终决策权保留给人类」→ `gateSlot` 承载 Draft / Confirm / Read-Only 三模契约，闸门不可绕过的判定由业务注入，壳只托管闸门轨布局。
- 「嵌入现有工作流」→ 由业务向 `inlineSlot` 注入内联建议条、`contentSlot` 注入当前工作对象，会话绑定的 grounding 权限继承属业务注入。

---

## 二、标准定义（原文完整章节，史料逐字保留）

### 2.1 封版口径

**NovaCopilot 是嵌入用户现有工作流、以“建议—确认—执行”为交互契约、始终将最终决策权保留给人类的增强型协作智能层。** 其标准聚焦于**嵌入性与可控性**，而非自主性。

参考 Microsoft Copilot Studio 的三框架划分，NovaCopilot 的封版定位落在 **“标准线束 + Copilot 聊天线束”的合取**上：

- **标准线束**：基于规则、可预测的对话，遵循预定义主题与规则，提供一致性回答；
- **Copilot 聊天线束**：扩展至用户日常工作界面，接入企业知识，但不替代用户做出不可逆决策。

**核心判据**：NovaCopilot 的输出是**建议**（suggestion）与**待确认动作**（proposed action），而非直接生效的变更。任何写入、发送、审批类操作在执行前必须经过显式的人类确认——在 Draft 模式下保存为草稿，在 Auto 模式下也保留可撤销窗口与审计记录。

> **治理归属声明**：上述标准线束、聊天线束、人工确认闸门、Draft / Confirm / Read-Only 三模、grounding 权限继承、规则引擎优先、动作可撤销可回溯等均是**业务治理语义**，由业务槽位注入（见第六章）；NovaCopilot 作为无业务语义骨架不实现、不判定、不代持其中任何一项。

---

## 三、实现方案（原文分层架构 + 全部关键实现约束，逐字保留）

NovaCopilot 的架构以 **“嵌入层薄、治理层厚”** 为原则，避免 Copilot 变成另一个需要独立运维的孤岛系统。

```
┌──────────────────────────────────────────────────────────────┐
│ 嵌入面（NovaChat 渲染于工作流内）                            │
│  · 侧边栏 / 内联建议 / 命令面板                              │
│  · 会话绑定当前工作对象（文档/工单/记录）作为 grounding     │
├──────────────────────────────────────────────────────────────┤
│ Copilot 运行时                                                 │
│  · 意图路由：规则命中 → 标准线束；开放推理 → 推理线束       │
│  · 上下文构造：企业知识 grounding（仅注入用户有权访问的内容）│
│  · 动作提案器：生成 proposed action，不直接执行              │
├──────────────────────────────────────────────────────────────┤
│ 执行闸门（Human-in-the-loop Gate）                            │
│  · Draft 模式：动作保存为草稿，人工发送/提交                 │
│  · Confirm 模式：显式确认后执行，附撤销窗口                  │
│  · Read-Only 模式：仅分析报告，零外部写入                    │
├──────────────────────────────────────────────────────────────┤
│ 共享治理层（与 Agent/DE 共用）                               │
│  · Entra ID / 企业 IdP 认证 · 租户级策略 · OTel 可观测      │
└──────────────────────────────────────────────────────────────┘
```

关键实现约束：

- **Grounding 权限继承**：Copilot 检索企业知识时，以当前用户的身份与权限执行，不获得超出用户可见范围的任何内容。“以用户身份运行”是 Copilot 安全模型的第一原则，而非事后过滤。
- **规则引擎优先于模型**：在可预测的、结构化的交互场景中，标准线束的规则引擎先行；仅在规则未覆盖的开放问题上才升级至推理线束。这保证了高频场景的确定性与可计费性。
- **动作永不“静默执行”**：即使处于 Auto 模式，Copilot 发起的每一个外部动作都生成独立的可审计事件，并与 NovaChat 会话 ID 绑定，支持按用户、按动作类型、按时间段的全量回溯。
- **扩展通过声明式接入**：第三方能力以 REST API 描述或 MCP 服务器形式注册，运行时由 Copilot 根据用户意图路由，不在嵌入面中硬编码连接逻辑。

> 上图与四条约束是**业务实现范式**史料，逐字保留；它们描述「业务侧怎么建协作智能层」，不是 Shell 的槽位契约。Shell 只提供承载这些注入内容的布局骨架（第四章）。

### 3.1 异常与降级边界（新增）

| 场景 | 安全出口（业务注入责任） | 壳侧保证（可验收） |
|---|---|---|
| 缺数据 / grounding 无内容 | 停止生成建议，不即兴猜测 | `suggestSlot` 空注入下不溢出、稳态几何非负 |
| 规则未命中 | 降级至“无法处理”，而非猜测（对齐 A5） | `inlineSlot` 空态由业务注入，壳不塞占位 |
| 待确认动作被阻塞 | 保存为草稿，保留可撤销窗口，不静默执行 | `actionProposed()` 只 emit 意图，不自写宿主状态 |
| 越界（写入 / 发送 / 审批） | 转 Confirm / Read-Only，权限不提升，零外部写入 | `gateSlot` 收起不产生布局跳变，闸门装饰仍可见 |
| 运行时 / Orbit Engine 不可用 | 退化为 NovaChat 会话基座：仅保留会话与身份，不产出 proposed action | 壳本身即会话骨架，天然可退化，无单点故障 |

---

## 四、组件级契约（新增 · 与真实 QML 完全一致）

> 本节逐项对齐 `Nova.Composite.LayoutShell` 模块 README「AI 智能组合根（3）」的 `NovaCopilot` 条目，为**冻结公共 API 面**的文档化复述；`_` 前缀私有成员不进冻结面。注：本组件为 **5 槽**，`overlaySlot` 保留但非必需。

### 4.1 槽位（5，均为 `property alias` 纯布局托管点）

| 槽位 | 承载位置 | 典型业务注入（治理语义由业务负责） |
|---|---|---|
| `suggestSlot` | 左建议列 | 建议（suggestion）列表 / 三段确认级条视图 |
| `inlineSlot` | 内联建议条 | 短条侧锚的内联建议 |
| `contentSlot` | 中央工作画布 | 当前工作对象 / 主工作区（对角取景框装饰之下） |
| `gateSlot` | 动作闸门轨 | Draft / Confirm / Read-Only 三模与待确认动作卡片 |
| `overlaySlot` | 浮层区 | 撤销窗口 / 提示（透明空 `Item`，取 `NovaTheme.zFixedDrawer` 等 z 层叠令牌；非必需但保留） |

### 4.2 配置 / 信号 / 函数 / 身份 / 依赖

| 类别 | 冻结契约 |
|---|---|
| **配置** | `suggestSize` · `gateSize` · `inlineHeight` · `showSuggest` · `showInline` · `showGate` · `suggestCollapsed` · `gateCollapsed` · `breakpoint` · `bordered` · `belowBreakpoint(ro)` |
| **信号** | `suggestToggled(bool collapsed)` · `gateToggled(bool collapsed)` · `actionProposed()` |
| **函数** | `toggleSuggest()` · `toggleGate()` · `proposeAction()` |
| **身份元素** | 内联胶囊条 + 三段确认级条 + 闸门渐变点 + 撤销弧环（与 NovaAgent / NovaDE 身份互不重复） |
| **依赖** | Theme · Header · Page · Separator · Motion（即 `NovaTheme` / `NovaHeader` / `NovaPage` / `NovaSeparator` / `NovaMotion`，全部为库内已导出公共类型；本组件不含 Footer） |

### 4.3 统一工程约束（三组件一致，逐项可机检）

| 约束 | 落点写法 | 机检项 |
|---|---|---|
| RTL | 根节点 `LayoutMirroring.enabled: NovaTheme.isRtl` | 声明式镜像扫描 |
| a11y | 根 Item 标 `// a11y: decorative`，不挂 `Accessible.*` | `check_a11y.py` decorative 登记 |
| 键盘可达 | `Esc` 对建议列 / 闸门轨两条可折叠轨分别 emit 收起意图（只 emit，不自写宿主状态、不新增公共 API） | `focus: true` + `Keys.onEscapePressed` 扫描 |
| 动效 | 一律 `NovaMotion.duration(NovaMotion.transitionDuration)` + `NovaMotion.easingStandard` | 无字面时长扫描 |
| 几何鲁棒 | 全部几何入参经 `_` 私有 `readonly property` 钳制后方可参与计算 | 极端非法入参稳态几何非负 |
| 槽位基线（CC-6） | 槽位宿主 `anchors.fill: parent` 并提供可协商 `implicit*` | 对象树几何打印，无 0×0 / 负宽高 |
| 注入基线 | 业务注入顶层须显式 `anchors.fill: parent` | 最小示例示范并实测可实例化 |

---

## 五、治理边界 · 无业务语义骨架（新增）

按组合组件宪法第 1 章三要素，NovaCopilot 是**立于母法 L1 之上的无业务语义骨架**：由 ≥2 个已导出公共类型组合而成（组合性）、以固定语义化 `property alias` 提供单向注入点（槽位化）、不含业务菜单/路由/数据模型/文案/专属图标（无业务语义），可在 Gallery 独立预览、独立调参、独立测试。

**Shell 只托管布局与折叠意图**：标准线束、聊天线束、人工确认闸门、风险分级、外部信号验证器、Shadow Mode、grounding 权限继承、规则引擎优先、动作可撤销可回溯、声明式接入等治理语义**全部由业务槽位注入**，Shell 只 emit 意图、不判定、不代持、不写宿主状态（受控契约，宪法第 3 章第 4 条）。

| 壳内可验收项（Shell 负责） | 业务注入项（槽位负责，治理语义） |
|---|---|
| 5 槽的位置 / 尺寸 / 显隐 / 断点行为 | 建议—确认—执行契约、「输出是建议与待确认动作」的判定 |
| 两条折叠轨的展开/收起意图（emit-only） | 人工确认闸门不可绕过、Draft / Confirm / Read-Only 三模 |
| `belowBreakpoint(ro)` 自适应与 RTL 镜像 | 以用户身份 grounding、权限不提升、企业知识注入范围 |
| 身份装饰纯几何、实心度 ≥0.85、零业务语义 | 规则引擎优先于模型、动作提案器、撤销窗口与审计事件 |
| 明暗双主题 / `NovaMotion` 动效 / 几何钳制 / a11y | 第三方 REST API / MCP 声明式注册与意图路由 |
| 槽位宿主铺满、`overlaySlot` 透明契约 | 建议列表、内联条、待确认动作卡片、工作对象等全部内容 |

---

## 六、CC-1~CC-8 合规映射（新增）

| 条款 | NovaCopilot 具体落点 | 机检 / 验收动作 |
|---|---|---|
| **CC-1 唯一密度源** | 根 Item 以 `_` 私有 `readonly` 声明唯一组合上下文 `_unit/_gap/_dur/_ease`（及 `_radius/_divider/_rail/_panel/_ink`），5 槽共享，不各轨散用间距令牌 | 组合上下文常量扫描 + padding 叠加检查 |
| **CC-2 单一分隔源** | 建议列 / 内联条 / 画布 / 闸门轨相邻边界只保留 1 个 `NovaSeparator` 或 1 级表面色阶，闸门渐变点不落在边界线上 | 同边界多重线扫描 |
| **CC-3 抽象几何装饰** | 内联胶囊 / 三段确认级条 / 闸门渐变点 / 撤销弧环一律抽象几何，不仿圆钮、搜索胶囊、图标方块等交互控件 | 伪控件扫描 + 装饰实心度 ≥0.85 |
| **CC-4 层级顺序** | `page` < `surfaceAlt`（建议/闸门轨）< `surface`（内联条/嵌入面板）< 浮起层，靠色阶 + 1px 分隔表达，不靠多重描边 | 表面色阶出图审计 |
| **CC-5 动效同步** | 建议列 / 闸门轨两折叠轨共用 `_dur/_ease`，锚定链**恒定指向轨 wrap** + `Behavior`，不用 `visible` 三元切换 | 折叠动画稳态 + `reducedMotion` 短路 |
| **CC-6 槽位铺满** | 5 槽宿主 `anchors.fill: parent` + `implicit*`，业务注入顶层显式 `anchors.fill: parent`，中央内容区不塞空态占位 | 对象树几何打印，无 0×0 / 负宽高 |
| **CC-7 装配态出图** | 浅色 / 深色 / 折叠**三态**装配图审计：5 轨同屏密度 / 对齐 / 层级 / 装饰预算 / 伪控件 / 空态 / 实心业务注入 | 三态出图 + `audit_ceiling.py` 机检 |
| **CC-8 成品级 showcase** | Gallery 独立演示注入真实建议卡 / 工作对象 / 三模闸门 / 撤销窗口，无「XX（注入业务）」占位文案，调参面板默认收起且与展示区分离 | `audit_showcase.py` 占位文案扫描 |

---

## 七、封版验收清单 A1~A8（原联合清单 NovaCopilot 列 + 新增「工程落点」）

| # | 验收域 | NovaCopilot（原文逐字） | 工程落点（槽位 / 装饰 / 机检项 / 业务注入责任） |
|---|---|---|---|
| A1 | 身份与租户隔离 | 以用户身份 grounding，权限不提升 | `contentSlot` 注入工作对象；RTL + a11y 机检；权限继承由业务注入 |
| A2 | 审计完整性 | 每个 proposed action 独立审计事件 | `gateSlot` 注入动作流；`actionProposed()` emit-only 机检；审计写入由业务注入 |
| A3 | 人工介入点 | Draft / Confirm / Read-Only 三模 | `gateSlot` + 闸门渐变点 / 撤销弧环装饰 + 折叠机检；三模由业务注入 |
| A4 | 外部可验证信号 | 动作结果可撤销、可回溯 | `gateSlot` + 撤销弧环装饰 + `overlaySlot`；撤销窗口由业务注入 |
| A5 | 异常安全出口 | 规则未命中时降级至“无法处理”而非猜测 | 见 §3.1 异常与降级边界；几何钳制机检；降级策略由业务注入 |
| A6 | 能力复用机制 | 扩展以声明式注册，不硬编码 | `suggestSlot` 注入扩展视图；依赖清单机检（无私有原子）；注册表由业务注入 |
| A7 | 影子/灰度能力 | Draft 模式作为默认上线模式 | `showGate` / `gateCollapsed` 折叠意图 + 恒定锚链机检；默认三模由业务注入 |
| A8 | 成本可观测 | 按用户/动作类型的计费与限额 | `inlineSlot` / `overlaySlot` 注入看板；`belowBreakpoint(ro)` 机检；计费由业务注入 |

> 任一 A 项未通过，该组件不得进入生产封版。工程落点列只标定**壳侧可机检位置**，判据本身的达标责任在业务注入侧。

---

## 八、CARF 四阶段封版记录（新增）

| 阶段 | 落地内容 | 门禁 / 产物 |
|---|---|---|
| **C 构想** | 本方案（一句话定义 + 标准线束/聊天线束 + 核心判据 + 三维判据）与组合组件宪法 1.0.0 立方向、立标准、立验收；法源先行 | 法源链：母法 → 组合宪法 → CC-1~CC-8 → 封版规范 v2.1.0 |
| **A 实现** | QML 组合根落地 + `qmldir` 导出 + a11y `decorative` 登记 + 1.1.0 冻结面整批单次重签（新增公共类型走母法第 13 章完整流程） | 5 槽 / 配置 / 信号 / 函数冻结签名；`PARITY.md` 审计节、生成物重跑 |
| **R 打磨** | 六维天花板逐项评估 + 浅/深/折叠三态装配图 + `scripts/audit_ceiling.py` 机检（静态 CC 契约 + 实例化 + 极端非法入参稳态几何 + RTL + reducedMotion + 断链扫描） | 三态出图审计 PASS；`CEILING_AUDIT.md` 逐项销号 |
| **F 封版** | 公共 API 签名逐字不变、冻结面零漂移、宪法 / CHANGELOG / 权威清单 / 账本闭环；**发布边界归 CSA** | `check_all.py --tier static` 全绿；封版资格由母法第 13 章门禁授予 |

---

## 九、封版声明（新增）

**正式定义（中）**：NovaCopilot 是 pyside-nova 企业级旗舰版中、以 NovaChat 为统一交互基座、以“建议—确认—执行”为交互契约、始终将最终决策权保留给人类的增强型协作面板组合根容器，其壳仅托管布局与折叠意图。
**Formal Definition (EN)**: NovaCopilot is the Augmented Collaboration Panel composition root in pyside-nova Enterprise Flagship, grounded on the NovaChat interaction base, contracted as suggest–confirm–execute, and always reserving the final decision to the human, whose shell hosts layout and collapse intent only.

**封版底线**：NovaCopilot 的封版底线是**人工确认闸门不可绕过、grounding 权限不提升**（原文封版结论逐字保留）。

**组件关系与不越界**（另两件见 [`LAW_NovaAgent.md`](LAW_NovaAgent.md) 与 [`LAW_NovaDE.md`](LAW_NovaDE.md)，原联合总纲已拆分归档为 `LAW_NovaAgent.md` / `LAW_NovaDE.md` / `LAW_NovaCopilot.md` 三份独立法源）：

| 维度 | NovaAgent | NovaDE | NovaCopilot（本文） |
|---|---|---|---|
| 自主程度 | 中—高（任务内自主） | 高（岗位内自主） | 低—中（建议 + 受限执行） |
| 责任归属 | 任务发起人 | 岗位持有者（组织角色） | 交互中的操作者 |
| 交付契约 | 任务结果 + 推理链 | 队列工作量 + 验收记录 | 建议 + 可撤销动作 |
| 身份元素 | DAG 链 / 渐变轨 / 取景框 / 审批色带 / 递减条 | 菱形徽记 / 堆叠卡沿 / SLA 递减条 / 双向箭头 | 内联胶囊 / 确认级条 / 闸门渐变点 / 撤销弧环 |
| 不越界约定 | 不持任务队列、不承载岗位形态、不内建人工确认闸门语义 | 不做单次任务自主规划、不抢占执行画布 | 不做任务自主执行、不提升 grounding 权限 |

> 三者共享 NovaChat 基座与统一治理层，在自主性光谱上形成从「建议」到「岗位执行」再到「任务自主」的清晰梯度，互不替代，也互不留下治理真空（原文封版结论逐字保留）。
>
> **收束句：治理语义由业务注入，壳不越界。** 建议—确认—执行契约、人工确认闸门、grounding 权限继承、规则引擎优先、动作可撤销可回溯、声明式接入等一切治理判据，均由业务向 5 个槽位注入；NovaCopilot 只提供可组合、可折叠、可机检的无业务语义骨架，封版资格由母法第 13 章 API 冻结门禁授予，发布边界归 CSA。
