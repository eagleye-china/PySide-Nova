# NovaIncubator 企业级旗舰版封版方案（FINAL）

## 0. 命名定稿

在 `NonaWizard` 与 `NovaIncubator` 之间，**选定 NovaIncubator**，理由如下（一并封版）：

| 候选 | 判定 | 依据 |
|---|---|---|
| NonaWizard | **否** | "Nona" 首字母脱离 Nova 体系，破坏 NovaChat / NovaAgent / NovaDE / NovaCopilot / NovaOrbit 的命名同源；"Wizard" 语义偏轻量向导，承载不了企业级旗舰版封版；且"Wizard"易与交互组件混淆 |
| **NovaIncubator** | **定** | "Nova" 与全体系同源；"Incubator" 精确对应"应用孵化器"定位，语义即能力；对外可缩写为 **NI**，对内 CLI 命名空间为 `incubator`，与 `prescript`、`carf` 构成三命名空间对仗 |

**中文正式名：诺瓦应用孵化器**
**英文正式名：NovaIncubator**
**一句话关系（封版口径）**：

> **以预构范式（Prescript）编写预判布局壳（Prescient Layout Shell），由诺瓦应用孵化器（NovaIncubator）按组件组合孵化，经 CARF 验收封版。**

---

## 1. 封版结论

本方案将 PRESCRIPT1.md 的**术语层封版**推进到**应用孵化层封版**，冻结五项：

1. **名称冻结**：中文 **诺瓦应用孵化器**，英文 **NovaIncubator**，不得混用"NonaWizard"作为正式名。
2. **组件冻结**：孵化器可孵化的组件集合为七件，全部纳入封版：
   `NovaDesk · NovaMobile · NovaFlexLayout · NovaAgent · NovaDE · NovaCopilot · NovaOrbit`
3. **配方冻结**：组件组合以**配方（Recipe）** 表达，首发冻结五套标准配方（见第 5 节）。
4. **CLI 命名空间冻结**：`pyside-nova incubator <verb>`，与 `prescript`、`carf` 三空间并列不吞并。
5. **上位关系冻结**：NovaIncubator 是**范式之上的孵化层**，不是新范式，不替代 Prescript，不替代 CARF，不替代 NovaOrbit。

> 封版状态：**FINAL / Enterprise Flagship Edition**
> 术语版本：**NovaIncubator Terminology Freeze v1.0**
> 上位依据：**Prescript Terminology Freeze v1.0（中英对仗封版）**

---

## 2. 五层概念体系定稿（中英对仗版）

PRESCRIPT1.md 冻的是三层，NovaIncubator 封版在其上增加两层，形成**五层不混淆体系**：

| 层级 | 中文正式名 | 英文正式名 | 定位 | 不得混淆 |
|---|---|---|---|---|
| 载体层 | **预判布局壳** | **Prescient Layout Shell** | 预置业务槽位与布局骨架的壳载体 | 不是范式，不是孵化器 |
| 范式层 | **预构范式** | **Prescript** | 面向预判布局壳的编程方法论 | 不是组件名，不是孵化器 |
| **孵化层** | **诺瓦应用孵化器** | **NovaIncubator** | 把范式、组件、配方组织为可交付应用的孵化系统 | **不是新范式，不是运行时组件** |
| **组件层** | （七件组合组件） | **NovaDesk / NovaMobile / NovaFlexLayout / NovaAgent / NovaDE / NovaCopilot / NovaOrbit** | 被孵化器编排进应用的运行时与智能组件 | 不是壳，不是范式 |
| 品质层 | **CARF 品质流水线** | **CARF** | 构想·实现·打磨·封版 | 不是孵化器，不是范式 |

**层级铁律**：

- **Prescript** 管"怎么编写"；
- **NovaIncubator** 管"把什么组合、孵成什么应用"；
- **CARF** 管"什么时候算封版交付"；
- **NovaOrbit** 管"应用呈现给用户时，工作台长什么样"；
- 五层各司其职，任一越界即判封版失格。

---

## 3. 命名理据（白皮书收录版）

> **诺瓦应用孵化器（NovaIncubator）**
> - **"诺瓦"**：承自 Nova 体系（NovaChat / NovaAgent / NovaDE / NovaCopilot / NovaOrbit），保持品牌同源；同时含"新星"意蕴，指向从壳到应用的诞生。
> - **"应用孵化器"**：明示这不是 IDE、不是低代码平台、不是组件库，而是**把 Prescript 产物 + 七件组件组合成企业级应用**的孵化系统；孵化 = 选种（壳与组件）+ 培育（Prescript 编排）+ 验收（CARF 封版）+ 交付（应用产物）。
> - **英文 NovaIncubator**：`Nova（新星）+ Incubator（孵化器）`，与中文一一对仗。

**对仗铁律**：

> **预判布局壳** 讲**骨架载体**；**预构范式** 讲**开发方式**；**诺瓦应用孵化器** 讲**应用诞生方式**。
> "判"、"构"、"孵"三字对仗：一判骨架，一构范式，一孵应用。

---

## 4. 标准定义文案（可直接复制）

### 4.1 一句定义

> **诺瓦应用孵化器（NovaIncubator）是 PySide-Nova 企业级旗舰版的应用孵化系统，以预构范式（Prescript）为开发方式、以预判布局壳（Prescient Layout Shell）为骨架载体，从七件组合组件（NovaDesk / NovaMobile / NovaFlexLayout / NovaAgent / NovaDE / NovaCopilot / NovaOrbit）中按配方选型，快速孵出符合四性标准、经 CARF 封版的企业级应用。**

### 4.2 段落定义

> **诺瓦应用孵化器（NovaIncubator）**
> 诺瓦应用孵化器（NovaIncubator）是 PySide-Nova 企业级旗舰版的应用孵化系统，承接预构范式（Prescript）与预判布局壳（Prescient Layout Shell）的封版成果，向上组织七件组合组件、向下对接 CARF 品质流水线。孵化器以**配方（Recipe）** 为选型单位，把端载体（NovaDesk / NovaMobile / NovaFlexLayout）、智能实体（NovaAgent / NovaDE / NovaCopilot）、意图轨道呈现面（NovaOrbit）组合为可交付应用；开发过程严格遵循 Prescript 的壳先于页、槽位即边界、契约即接口三原则，交付过程严格经 CARF 四阶段验收。孵化器不替代范式，不替代流水线，只解决"从封版范式到可交付应用"的最后一公里。

### 4.3 术语卡定义

> **诺瓦应用孵化器（NovaIncubator）**：Prescript 之上、CARF 之下的应用孵化系统。
> **核心动作**：选壳、选配方、孵应用、经 CARF 封版。
> **核心价值**：不从零拼装、不重复治理、不各自封版，按配方一次孵出企业级应用。
> **配套体系**：Prescript 为开发方式，Prescient Layout Shell 为载体，CARF 为品质流水线，七件组合组件为孵化原料。
> **命名对仗**：Prescient Layout Shell · 预判布局壳 ｜ Prescript · 预构范式 ｜ NovaIncubator · 诺瓦应用孵化器。

---

## 5. 组件分层与首发配方（Recipe）冻结

### 5.1 七件组件分层定位（封版口径）

| 层 | 组件 | 封版定位 | 一句话职责 |
|---|---|---|---|
| **端载体层** | **NovaDesk** | 桌面端运行时与工作台载体 | 承载桌面级企业应用的标准外观与交互 |
| **端载体层** | **NovaMobile** | 移动端运行时与触屏载体 | 承载移动/平板级企业应用的标准外观与交互 |
| **端载体层** | **NovaFlexLayout** | 跨端自适应布局引擎 | 为 Prescient Layout Shell 提供全端骨架实现，桌面/移动/工业大屏一套壳 |
| **智能实体层** | **NovaAgent** | 任务内自主执行单元 | 八项准入控制通过后方可接入生产 |
| **智能实体层** | **NovaDE** | 数字员工（岗位形态） | 持队列、跨系统、受队伍级治理 |
| **智能实体层** | **NovaCopilot** | 嵌入工作流的协作智能层 | 建议 + 待确认动作，人工闸门不可绕过 |
| **呈现层** | **NovaOrbit** | NovaChat 的天花板形态 | 以意图轨道组织 NovaChat、三栏同构异质 |

**分层铁律**：孵化器不得把智能实体层组件作为"必选项"塞进最小配方，也不得把呈现层组件当作普通界面控件复用。**组合有边界，配方有形态。**

### 5.2 首发五套标准配方（冻结）

> 配方 = 可孵化应用的组件组合模板。每套配方附**必选件**、**可选件**、**封版门禁**。

| 配方代号 | 应用形态 | 必选组件 | 可选组件 | 封版门禁 |
|---|---|---|---|---|
| **R1 · Orbit 旗舰工作台** | 意图轨道工作台 | NovaDesk + NovaFlexLayout + NovaOrbit + NovaCopilot | NovaAgent / NovaDE | NovaOrbit 封版清单 O1–O8 全过；Copilot 人工闸门不可绕过 |
| **R2 · 数字员工队伍** | 部门级数字员工流水线 | NovaDesk + NovaFlexLayout + NovaDE + NovaCopilot | NovaAgent（任务级自主补位） / NovaOrbit（监控视图） | NovaDE 四要件齐备、队伍级治理先于规模；影子模式 ≥ 48h |
| **R3 · 智能任务台** | 任务型自主执行工作台 | NovaDesk + NovaFlexLayout + NovaAgent + NovaCopilot | NovaOrbit（多任务并行） / NovaDE（队列承接） | NovaAgent 八项准入控制全过；外部验证器独立运行 |
| **R4 · 全端协同应用** | 桌面 + 移动 + 大屏一体 | NovaDesk + NovaMobile + NovaFlexLayout + NovaCopilot | NovaOrbit / NovaAgent / NovaDE | NovaFlexLayout 跨端一致性全过；同一 Prescient Layout Shell 骨架下三端验收通过 |
| **R5 · 极简 Copilot 应用** | 单职能嵌入式协作应用 | NovaDesk（或 NovaMobile）+ NovaFlexLayout + NovaCopilot | — | Copilot 三模（Draft / Confirm / Read-Only）落地；grounding 权限不提升 |

**配方选择判据**：先看应用是否**有工作台形态**（→是否选 NovaOrbit），再看是否**有岗位/队列形态**（→NovaDE），再看是否**有任务型自主**（→NovaAgent）；三者皆非，仅需协作增强，则落 R5 极简配方。

---

## 6. 孵化器四条原则

与 Prescript 四条原则并列为**孵化层四原则**：

1. **配方先于拼装**：先选配方，再个性化；不在孵化器内临时拼装无归属的组件组合。
2. **壳契约定于组件**：组件配置必须服从 Prescient Layout Shell 的槽位契约，不得因组件需求反向穿透壳骨架。
3. **治理随配方同行**：每套配方携其治理清单（身份、审计、人工闸门、封版门禁）一并孵化，事后补治理视为失格。
4. **封版即发布**：孵化产物必须经 CARF Freeze 与配方对应门禁，方可标记企业级旗舰版交付。

---

## 7. CLI 冻结规范

三命名空间并列，**互不吞并**：

```bash
pyside-nova prescript <verb>   # 开发范式（已有）
pyside-nova carf      <verb>   # 品质流水线（已有）
pyside-nova incubator <verb>   # 应用孵化器（本次冻结）
```

### 7.1 incubator 旗舰版冻结命令

```bash
pyside-nova incubator init          # 初始化孵化工程，选择配方（R1–R5）
pyside-nova incubator scaffold      # 按配方生成壳契约 + 组件骨架 + 注释标签
pyside-nova incubator dev           # 孵化态运行（调用 prescript dev）
pyside-nova incubator build         # 构建组件产物（含多端 NovaDesk/NovaMobile）
pyside-nova incubator validate      # 配方合规 + prescript validate + 配方门禁三重校验
pyside-nova incubator freeze        # 调用 carf freeze，输出封版交付包
pyside-nova incubator release       # 发布封版产物（企业级渠道）
```

### 7.2 边界铁律

- `prescript` 管**怎么编写**；`carf` 管**品质怎么封**；`incubator` 管**配方怎么组、应用怎么孵**。
- `incubator` 不得重写 `prescript` 的契约校验；`incubator validate` 内部**调用**而非**重写** `prescript validate`。
- `incubator freeze` 不得绕过 `carf freeze`；孵化器的封版动作必须以 CARF 封版为前置。

---

## 8. 注释与孵化标签规范

在 Prescript 最小注释标签集之上，增补**孵化标签**，五标签变为**七标签**：

```python
# @prescript
# @shell: PrescientLayoutShell
# @slot: main.content
# @contract: prescript.contract.yaml
# @incubator: R1-orbit-flagship          # 孵化配方
# @components: NovaDesk, NovaFlexLayout, NovaOrbit, NovaCopilot
# @carf: freeze-gate
```

标签规则：

- `@incubator`：声明所属配方（R1–R5），缺省即视为配方未定，`incubator validate` 直接拦截；
- `@components`：声明本文件/模块涉及的组合组件，必须为七件组件中的成员，不得出现清单外组件名；
- 其余五标签沿用 Prescript 封版规范，语义不变。

**工程落地建议**：孵化工程根目录统一放置 `incubator.recipe.yaml`，声明配方代号、组件清单、CARF 门禁阶段；术语冻结核心是 **NovaIncubator**，配方与文件名为工程建议。

---

## 9. 与 PRESCRIPT1.md / CARF 的配套映射

| 孵化器阶段 | Prescript 阶段 | CARF 阶段 | 封版含义 |
|---|---|---|---|
| `incubator init`（选配方） | 壳选择与槽位规划 | Conceive（构想） | 配方选定 + 预判骨架意图 |
| `incubator scaffold`（生成骨架） | 契约编写准备 | Conceive → Achieve | 壳契约 + 组件骨架 + 注释标签落地 |
| `incubator dev`（注入业务） | 契约编写与业务注入 | Achieve（实现） | 按配方完成预构编排 |
| `incubator validate`（三重校验） | 槽位校验与样式收敛 | Refine（打磨） | 配方合规 + 契约校验 + 门禁核查 |
| `incubator freeze`（封版） | validate 通过并冻结 | Freeze（封版） | 调用 CARF Freeze，输出交付包 |
| `incubator release`（发布） | — | Freeze 之后 | 企业级渠道发布 |

标准闭环（封版）：

> **选配方 → Prescript 编排 → validate 三重校验 → CARF Freeze → incubator release。**

中英对齐：

> **Recipe → Prescript → validate → CARF Freeze → Release。**

---

## 10. 中英双标语定稿

**正式对仗标语（白皮书 / 规范文档 / PPT 首页）**：

> **NovaIncubator · 诺瓦应用孵化器**
> **Prescript · 预构范式 ｜ Prescient Shell · 预判布局壳**

**完整交付标语（正式对外版本）**：

> **Incubated by NovaIncubator, written in Prescript, frozen by CARF.**
> **以诺瓦应用孵化器孵应用，以预构范式写壳，经 CARF 验收封版。**

**短 Slogan（宣讲 / 幻灯片 / 页脚）**：

> **选配方，孵应用；一壳七组件，全端共生。**

**使用规则（承接 PRESCRIPT1.md 三层标语规则）**：白皮书正文用完整交付标语；PPT 首页用对仗标语；宣讲页脚用短 Slogan。三层标语不得混用场景。

---

## 11. 对标表述（正式收录）

> 诺瓦应用孵化器（NovaIncubator）借鉴 Quasar CLI 的模板式脚手架思想，但并非脚手架复制。NovaIncubator 以**配方**为选型单位，向上组织 NovaDesk / NovaMobile / NovaFlexLayout / NovaAgent / NovaDE / NovaCopilot / NovaOrbit 七件组合组件，向下对接 Prescript 开发范式与 CARF 品质流水线，形成"范式 → 孵化 → 封版"的企业级闭环。对标 Quasar CLI 的脚手架层，NovaIncubator 多出**组件配方**与**治理随行**两层内涵；对标低代码平台，NovaIncubator 不追求拖拽式所见即所得，而坚持 Prescript 的契约注入与 CARF 的封版验收。

---

## 12. 封版验收清单

- [ ] 白皮书中文正式名统一为 **诺瓦应用孵化器**，英文正式名统一为 **NovaIncubator**。
- [ ] 中英首次出现采用 **诺瓦应用孵化器（NovaIncubator）** 格式。
- [ ] NonaWizard 不进入白皮书、CLI、规范文档正文，仅作为历史别名记录。
- [ ] CLI 仅使用 `pyside-nova incubator <verb>` 命名空间，与 `prescript`、`carf` 三空间并列不吞并。
- [ ] 七件组合组件定名冻结：NovaDesk / NovaMobile / NovaFlexLayout / NovaAgent / NovaDE / NovaCopilot / NovaOrbit。
- [ ] 首发配方 R1–R5 冻结，每套配方必选/可选件与门禁明确。
- [ ] 注释规范在 Prescript 五标签之上增补 `@incubator`、`@components`，形成七标签体系。
- [ ] 五层概念体系（壳 / 范式 / 孵化器 / 组件 / CARF）文档明确不混淆。
- [ ] 孵化四原则与 Prescript 四原则并列收录。
- [ ] 与 Prescript / CARF 的配套映射表进入规范文档。
- [ ] 中英对仗标语、完整交付标语、短 Slogan 各归其位。
- [ ] 与 Quasar CLI 的对标表述正式收录。
- [ ] 后续术语与配方变更必须走 RFC，不得静默改写。

---

## 13. 规范文档目录定稿（承接 PRESCRIPT1.md 07 之后扩展）

```text
00-terminology.md        # 预构范式与诺瓦应用孵化器术语封版声明
01-principles.md         # Prescript 四原则 + Incubator 四原则
02-shell-slot-contract.md# 预判布局壳槽位与契约规范
03-cli-spec.md           # prescript / incubator / carf 三命名空间
04-annotation-spec.md    # 七标签规范（含 @incubator / @components）
05-carf-gate.md          # Prescript / Incubator / CARF 门禁映射
06-migration-guide.md    # 旧写法迁移到预构范式与孵化器配方
07-reference.md          # 示例、反例、验收清单
08-incubator-recipes.md  # 五套首发配方（R1–R5）与选型判据
09-incubator-components.md# 七件组合组件封版定位与边界
```

---

## 14. 封版声明

**诺瓦应用孵化器（NovaIncubator）企业级旗舰版封版方案至此封版。**

- 中文正式定义：**诺瓦应用孵化器是 Prescript 之上、CARF 之下的应用孵化系统。**
- 英文正式定义：**NovaIncubator is the application incubation system above Prescript and below CARF.**
- 中文正式名：**诺瓦应用孵化器**
- 英文正式名：**NovaIncubator**
- 中英对仗标语：**NovaIncubator · 诺瓦应用孵化器 ｜ Prescript · 预构范式 ｜ Prescient Shell · 预判布局壳**
- 完整交付标语：**Incubated by NovaIncubator, written in Prescript, frozen by CARF.**
- 短 Slogan：**选配方，孵应用；一壳七组件，全端共生。**
- 配方冻结：**R1 Orbit 旗舰工作台 · R2 数字员工队伍 · R3 智能任务台 · R4 全端协同应用 · R5 极简 Copilot 应用**
- 组件冻结：**NovaDesk · NovaMobile · NovaFlexLayout · NovaAgent · NovaDE · NovaCopilot · NovaOrbit**
- 封版状态：**FINAL / Enterprise Flagship Edition**

> **一"判"定骨架，一"构"定范式，一"孵"定应用；七件组件、五套配方、三线封版，一体交付。**