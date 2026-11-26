> **NovaIncubator · 诺瓦应用孵化器 ／ Application Incubation Workbench**
> **pyside-nova 第 20 个组合根容器 · 企业级旗舰版封版法源**
>
> | 元项 | 值 |
> |---|---|
> | **版本** | `Enterprise Flagship v1.0-FINAL` |
> | **封版日期** | `2026-11-26` |
> | **封版状态** | `FINAL` |
> | **术语对仗** | NovaIncubator · 诺瓦应用孵化器 ／ Application Incubation Workbench |
> | **组件序号** | 第 **20** 个组合根容器（`Nova.Composite.LayoutShell`）· **本库最后一个组合组件** |
> | **并入批次** | 1.2.0（未发布批次）· 整批**单次重签**：143→144 类型 ／ 19→20 组合根 ／ a11y `decorative` 83→84 · 指纹 **`68b34a408489b6a8`**（由 `gen_api_freeze.py` 签署；旧 143 类型成员 0 漂移，仅新增 `NovaIncubator`） |
> | **五层定位** | 孵化层（方法论）＋ 组件层第 20 组合根（工作台壳） |
> | **一句话定位** | 诺瓦应用孵化器的工作台壳 · 孵化流水线的呈现载体 · 本库最后一个组合组件（第 20 个组合根容器） |
>
> **法源链（逐级援引，不得越级）**：
> `docs/CONSTITUTION.md`（母法，含第 13 章 API 冻结门禁）
> → `docs/COMPOSITION_CONSTITUTION.md`（组合组件宪法 1.0.0）
> → 第 9 章 CC-1~CC-8 组合态一致性契约
> → 《Prescient Layout Shell 封版规范 v2.1.0》
> → `docs/prescript/ARCHIVE_NovaIncubator_Naming.md`（命名定稿史料）
> → **本方案（NovaIncubator 正式封版法源）**
>
> **封版资格声明**：法定封版资格**只由母法第 13 章 API 冻结门禁授予**
> （整批单次重签后由生成器签署件确认）；本文档的 `FINAL` 指本方案作为设计法源定稿，
> **不自行宣称组件封版资格、不自行宣称已发布**，发布边界归 CSA。
>
> **史料沿革**：`NovaIncubator_name.md`（命名定稿 v1.0）与本文下方 World-Class Edition 初稿
> 全文保留为史料；`2026-11-26` 完成法源完现、整合双稿并并入 1.2.0 未发布批次，
> **全文元信息以本块为准**。

---

## 零、三要素与无业务语义骨架

> 依《组合组件宪法 1.0.0》第 1 章，NovaIncubator 的 QML 实现（`Nova.Composite.LayoutShell.NovaIncubator`）
> 是**组合性 + 槽位化 + 无业务语义**的纯布局骨架；本方案的配方体系、四阶段流水线、
> 三重校验、封版证书等治理与业务语义，全部是**业务槽位将要注入的语义**，不是壳自身持有的能力。

### 0.1 三要素（宪法第 1 章冻结条款）

| 要素 | NovaIncubator 落地 |
|---|---|
| **组合性** | 由 ≥2 个已导出公共类型组合（`NovaTheme` / `NovaHeader` / `NovaFooter` / `NovaPage` / `NovaSeparator` / `NovaMotion`），不是单控件皮肤化包装；7 槽骨架共由这 6 类公共类型托举 |
| **槽位化** | 7 个语义化槽位一律 `property alias`：`globalSlot` / `recipeSlot` / `stageSlot` / `pipelineSlot` / `validateSlot` / `certificateSlot` / `overlaySlot`；槽位是纯布局托管点，Shell 只决定位置 / 尺寸 / 显隐 / 断点，不读写注入内容状态 |
| **无业务语义** | 7 槽不含配方注册表 / R1~R5 配方数据 / 七区契约 / 校验规则 / 证书签发 / 业务文案 / 项目专属图标；脱离业务工程在 Gallery 可独立预览、调参、测试 |

**单向数据流**：属性向下传配置、信号向上报事件；`recipeToggled` / `validateToggled` / `freezeRequested`
**只 emit、不自写宿主状态**（受控契约，宪法第 3 章第 4 条 / 母法第 9·12·13 章）；
`freezeRequested()` 只表达「请求封版」，是否签发证书由宿主确认（人工闸门不可绕过）。

### 0.2 壳内可验收项 vs 业务注入项

**治理与业务语义一律由业务槽位注入，Shell 不内置、不持有状态**——
配方注册表 / 配方解释器 / 组件装配器 / 治理注入器 / 三重校验器 / 封版证书签发器 / CLI 孵化内核 / 审计流，
均不进入壳的公共 API 与私有实现。

| 壳内可验收项（无业务语义 · 可机检） | 业务注入项（治理与业务语义 · Shell 不持有） |
|---|---|
| 全局栏 / 左栏配方库 / 中栏孵化舞台 / 底部 CARF 四阶段条 / 右栏三重校验 / 右栏下封版证书预览 / 浮层的 7 槽 `property alias` 骨架 | **配方注册表与 R1~R5**：五套首发配方的代号、必选件、治理清单、封版门禁 |
| `recipeSize` / `validateSize` / `globalHeight` / `pipelineHeight` / `certificateHeight` / `show*` / `*Collapsed` / `breakpoint` / `bordered` 等公开配置与 `belowBreakpoint`(ro) 只读派生 | **七区配方契约**：`incubator.recipe.yaml` 七区（shell / components / intelligence / governance / acceptance / delivery / observability）全填校验 |
| 纯几何身份元素（四级递进楔形条 / 五列配方栅 + 列尾七刻点 / 七区分格环 + 中心孵化点 / 四节点收敛链 / 三道递减校验刻线 + 收敛角 / 方章折角 + 封蜡点 / 顶层 2px 递进发丝线），`primary` 单色系 · 实心度 ≥0.85 · 零字体依赖 | **配方解释器**：解析七区、生成孵化计划（DAG）、缺区拦截 |
| `LayoutMirroring.enabled: NovaTheme.isRtl` / `// a11y: decorative` / Esc 对 recipe · validate 两条可折叠栏分别 emit 收起意图 | **组件装配器**：按配方拉取七件组件、双向核对槽位契约与组件配置 |
| `NovaMotion.duration(NovaMotion.transitionDuration)` + `NovaMotion.easingStandard` 共用的 `_dur` / `_ease`（`reducedMotion` 归零） | **治理注入器**：身份 / 审计 / 脱敏 / 成本归因，治理先于业务注入 |
| 几何入参 `_` 私有 `readonly` 钳制；槽位宿主 `anchors.fill: parent`；业务注入顶层显式 `anchors.fill: parent`；极端非法入参稳态几何非负 | **三重校验器**：配方合规 / 契约合规 / 门禁合规 |
| `recipeToggled` / `validateToggled` / `freezeRequested` 信号与 `toggleRecipe()` / `toggleValidate()` / `requestFreeze()` 函数（只 emit，不自写宿主状态） | **封版证书签发器 / CLI 孵化内核 / 审计流**：`incubator freeze` 调用 `carf freeze`、证书五件套、离线核验、审计贯通 |

> 一句话：**壳回答「四阶段与七槽怎么摆、折叠怎么动、装饰长什么样」；业务回答「配方是什么、七区怎么填、三重校验过不过、证书何时签发」。**
> 二者以槽位为唯一边界，任一越界（壳内出现配方状态、业务要求改壳骨架）即判封版失格。

---

## 零之一、法源沿革与张力消解

> 本章如实记录本次封版必须消解的法源张力与 CSA 裁定；**史料不删、定义不改、不圆场**，
> 全部张力原样入法源，以「层级裁定」而非「改写历史」的方式消解。

### （一）张力登记（原始表述逐条如实列出）

| # | 史料来源 | 原始表述（不改写） | 指向 |
|---|---|---|---|
| T1 | `NovaIncubator_name.md` §1 | 「NovaIncubator 是范式之上的孵化层，不替代 NovaOrbit」；§5「不替代 Prescript，不替代 CARF」 | 孵化层 ≠ 范式 / 流水线 / 呈现组件 |
| T2 | `NovaIncubator_name.md` §2 | 「孵化层……**不是运行时组件**」；组件层为「被孵化器编排进应用的运行时与智能组件」 | 孵化层 ≠ 运行时组件 |
| T3 | 本文史料正文 §2（World-Class Edition 初稿） | 五层概念体系：孵化层定位「**应用孵化系统**」，组件层七件组合组件定位「**孵化原料**」 | 孵化层是系统 / 方法论层，七件是原料 |
| T4 | 2026-11-26 CSA 新指令 | 「企业级优化完善，落地为本库企业级旗舰版封版，使其实至名归，完现应用孵化器功能，按 CARF 打造**本库最后一个组合组件**」 | 落地为**运行时 QML 组合根** |

**张力如实陈述**：T1 / T2 / T3 明确把 NovaIncubator 定义为 Prescript 之上、CARF 之下的
「孵化层 / 应用孵化系统 / 方法论层」，且白纸黑字「**不是运行时组件**」；而 T4 指令要求把它
「落地」为「本库最后一个组合组件」——即组件层的一个 QML 组合根容器。二者在字面上直接相抵，
不作和稀泥式圆场，以 CSA 裁定的层级切分处理。

### （二）CSA 裁定（层级切分，史料全留）

1. **方法论层定义原样保留**：`NovaIncubator` 作为「孵化系统 / 方法论层」（Prescript 之上、CARF 之下）
   **仍不是普通运行时组件**；该定义（含 T2「不是运行时组件」）作为史料**完整保留、逐字不改**，
   与史料正文 §0~§17 一并存档。
2. **组件层新增的是「工作台壳」而非「孵化内核」**：本库交付的是它在**组件层**的
   「应用孵化器工作台壳」（QML 组合根 `Nova.Composite.LayoutShell.NovaIncubator`），
   即**孵化流水线的呈现载体**，不是孵化内核本身。方法论层的「孵化系统」与组件层的「工作台壳」
   是两个层级、两个对象，不构成定义冲突。
3. **与 NovaOrbit 处理完全同构**：`NovaOrbit`（呈现层 → 第 19 组合根 QML）同样只提供槽位，
   轨道引擎 / 信号感知 / 意图路由 / 审计流等业务语义全部由 Demo 业务槽位注入
   （组合宪法「无业务语义骨架」）；NovaIncubator 照此办理——壳只提供 7 槽，
   **配方解释器 / 组件装配器 / 治理注入器 / 三重校验器 / 封版证书签发器**等一切业务语义
   全部由 Demo 业务槽位注入，壳不内置、不持有状态。
4. **七件组合组件史料不冲突**：原「七件组合组件」为**孵化原料**的史料表述逐字保留、不改写其
   历史定义；第 20 组合根属**组件层新增工作台壳**，与七件孵化原料**不冲突、不改写、不替代**，
   也不把工作台壳回写进「七件」清单。
5. **序号与批次裁定**：「本库最后一个组合组件」序号为 **20**；`NovaOrbit` 为 **19**。
   1.1.0 为未发布批次；本轮四增量 + 第 20 组合根整批抬升 **1.2.0 单次重签**：
   143→144 类型 ／ 19→20 组合根 ／ a11y `decorative` 83→84；
   **指纹 `68b34a408489b6a8`**（由 `gen_api_freeze.py` 签署件确认，非编造）；发布边界归 CSA，法源不自行宣称已发布。

### （三）「完现应用孵化器功能」的落点

> 「完现应用孵化器功能」的落点＝**成品级 Demo 真实业务注入**，而非把 CLI 孵化内核塞进 QML 组合根：
> 五套配方 R1~R5（`recipeSlot`）／ 七区配方契约（`recipeSlot` · `stageSlot`）／
> 三重校验状态（`validateSlot`）／ 封版证书预览（`certificateSlot`）／
> CARF 四阶段流水线（`pipelineSlot`）／ 全局栏（`globalSlot`）／ 确认浮层（`overlaySlot`），
> 由业务向 7 槽注入，构成可独立预览、调参、出图审计的成品级工作台（CC-8 参考实现纪律）。
> **CLI 孵化内核属工具链层，不在组合根交付范围**：史料正文 §6 三大引擎、§7 `pyside-nova incubator`
> 全命令面、§4 孵化内核 L1~L6 均为方法论 / 工具链层规范，不是第 20 组合根 QML 的内建能力。

### （四）「完现应用孵化器功能」落地清单（成品级 Demo 逐项对照）

> 用户指令「完现应用孵化器功能」的兑现口径：**功能语义由成品级 Demo 真实注入并可视**，
> 而非下沉为组件公共 API。壳保持零业务语义，符合宪法「无业务语义骨架」封版要求。

| 功能 | 史料依据 | 组件层落点 | 成品级 Demo `examples/layout_shell/incubator/` |
|---|---|---|---|
| 五套首发配方 R1~R5 | §5.2 | `recipeSlot` | `recipes` 五套可选中 / 切换，配方代号联动全局栏 |
| 七区配方契约 | §5.1 / §8 | `recipeSlot` + `stageSlot` | `zones` 七区导航 + 七区契约表 |
| 七件组件编排 | §1 / §2 | `stageSlot` | 组件编排清单逐件列出 |
| 治理清单四类 | §10.1 | `stageSlot` | 治理清单实表 |
| CARF 四阶段流水线 | §9 | `pipelineSlot` | `stages` 四阶段 + 阶段推进 + 「请求封版」 |
| 三重校验 | §6.2 | `validateSlot` | `checks` 三项逐条呈现 |
| 封版证书五件套 | §6.3 | `certificateSlot` | `bundle` 五件套（含升级路径）完整可见 |
| 人工确认闸门 | §7.2 / §12 | `overlaySlot` | `seal()` 只上报 `freezeRequested()` 并打开闸门；`confirm()` 才签发证书 |
| 受控信号 | 宪法第 3 章 | 3 信号 + 3 函数 | `recipeToggled` / `validateToggled` / `freezeRequested` 全走宿主回写 |

> **闸门铁律**：`seal()` 不等于封版。Shell 的 `requestFreeze()` 只 emit 意图，业务侧必须先打开
> 人工确认闸门、由人 `confirm()` 后才置 `frozen = true` 并签发证书——**壳绝不自动封版、绝不自动执行**。


---

# NovaIncubator 企业级旗舰版封版方案（FINAL · World-Class Edition）
> 史料正文（World-Class Edition 初稿）· 逐字保留；元信息以本文件顶部封版块为准。

> 本文承接 **PRESCRIPT1.md（Prescript Terminology Freeze v1.0）** 与 **NovaIncubator Terminology Freeze v1.0**，将 NovaIncubator 从"命名与配方封版"推进到**"世界应用孵化器天花板"的完整实现封版**。本次封版冻结六项：名称、定义、架构、配方体系、门禁标准、天花板判据。

> **封版状态：FINAL / Enterprise Flagship Edition / World-Class Ceiling v1.0**
> **中文正式名：诺瓦应用孵化器** ｜ **英文正式名：NovaIncubator** ｜ **CLI 命名空间：`pyside-nova incubator`**

---

## 0. 天花板定位：一句封版结论

> **NovaIncubator 是世界上第一个把"壳 + 范式 + 组件 + 治理 + 封版"五要素一次性封装为可交付应用的应用孵化器。它不是模板脚手架，不是低代码平台，不是 IDE，不是部署平台；它是 Prescript 范式与 CARF 品质之间的"应用诞生层"，把从封版范式到企业级可交付应用的最后一步，压缩为"选配方 → 注入业务 → 三重校验 → 一次封版"。**

这句话是 NovaIncubator 的**天花板判据**，也是与全球同类工具划界的硬标尺。任何"应用孵化器"若不能一次交付以下五件事，即不被视为天花板：

1. **一次交付壳契约**（Prescient Layout Shell 的槽位与骨架）
2. **一次交付范式合规**（Prescript 四原则通过）
3. **一次交付组件编排**（七件组合组件按配方协同）
4. **一次交付治理**（身份、审计、租户、门禁、可观测）
5. **一次交付封版**（CARF Freeze 通过，产物可发布）

---

## 1. 与全球同类工具划界的六条硬标准

**天花板不是形容词，是可核验的六条标准。** 以下六条同时满足，才配称"世界应用孵化器天花板"：

| # | 硬标准 | 全球同类典型短板 | NovaIncubator 的封版答案 |
|---|---|---|---|
| **C1** | **一次输入五要素**：壳 + 范式 + 组件 + 治理 + 验收 | Quasar CLI 仅壳+模板；create-react-app 仅 UI；Nx 仅 monorepo；Retool/Appsmith 仅低代码 UI | `incubator init` 一次接收 `incubator.recipe.yaml`（含壳、组件、治理、门禁） |
| **C2** | **一次输出可交付应用**：运行、治理、审计、封版包 | Vercel/Netlify 只部署不治理；OutSystems 锁平台 | `incubator freeze` 输出"运行包 + 治理清单 + 审计接入 + CARF 封版证书"四件套 |
| **C3** | **智能实体为一等公民**：Agent/DE/Copilot/Orbit 由配方原生编排 | 多数平台把 AI 作为"插件"或"对话框" | 七件组件中四件为智能组件，配方层原生调度 |
| **C4** | **一壳全端**：桌面 + 移动 + 工业大屏，一套 Prescient Layout Shell | 多数工具按端分栈（桌面一套、移动一套） | NovaFlexLayout 在 Prescript 层保证跨端一致性，配方层一次声明三端 |
| **C5** | **治理随配方同行**：治理不事后补，配方即治理清单 | 多数工具治理需另配（IAM、审计、脱敏平台） | 治理清单写进 `incubator.recipe.yaml`，`incubator validate` 与 `freeze` 双重核查 |
| **C6** | **封版可核验、可回滚、可升级**：一次封版即企业级交付 | 多数工具"生成"即结束，无封版、无回滚、无升级路径 | `incubator freeze` 产出封版证书；配方版本化，升级走 `incubator upgrade` 不影响业务层 |

**天花板铁律**：六条中任一未满足，不作为天花板；六条全过，**才允许**在对外文件使用"世界应用孵化器天花板"表述。

---

## 2. 五层概念体系（承接上版，冻结不变）

| 层级 | 中文 | 英文 | 定位 |
|---|---|---|---|
| 载体层 | 预判布局壳 | Prescient Layout Shell | 骨架载体 |
| 范式层 | 预构范式 | Prescript | 开发方法论 |
| **孵化层** | **诺瓦应用孵化器** | **NovaIncubator** | 应用孵化系统 |
| 组件层 | 七件组合组件 | NovaDesk / NovaMobile / NovaFlexLayout / NovaAgent / NovaDE / NovaCopilot / NovaOrbit | 孵化原料 |
| 品质层 | CARF 品质流水线 | CARF | 封版验收 |

> **关系不变式**：**以预构范式编写预判布局壳，由诺瓦应用孵化器按配方孵化七件组件，经 CARF 验收封版。** 五层不混淆，任一越界即封版失格。

---

## 3. 标准定义文案（天花板版，可直接对外）

### 3.1 一句定义（对外发布会口径）

> **诺瓦应用孵化器（NovaIncubator）是世界上第一个"五要素一次交付"的应用孵化系统：以预构范式（Prescript）为开发方式、以预判布局壳（Prescient Layout Shell）为骨架载体，从七件组合组件中按配方选型、按治理清单注入、按 CARF 门禁封版，一次输出可运行、可治理、可审计、可封版、可升级的企业级应用。**

### 3.2 段落定义（白皮书收录）

> **诺瓦应用孵化器（NovaIncubator）**
> 诺瓦应用孵化器是 PySide-Nova 企业级旗舰版的应用孵化系统，代表全球应用孵化器天花板的实现形态。它以**配方（Recipe）** 为选型单位、以**五要素一次交付**为封版判据、以**三重校验**为门禁基线、以**CARF 封版证书**为交付凭证，把 Prescript 范式、Prescient Layout Shell 载体、七件组合组件、企业级治理与 CARF 品质流水线一次性打包进"选配方 → 注入业务 → 三重校验 → 一次封版"的闭环。NovaIncubator 对标 Quasar CLI 的模板思想、Vercel 的部署思想、Backstage 的门户思想，但**同时超越三者的单点强项**：它把"模板 + 部署 + 门户"统一为"孵化"，把"一次生成"升级为"一次封版"，把"开发工具"升格为"应用诞生系统"。

### 3.3 术语卡定义

> **诺瓦应用孵化器（NovaIncubator）**：Prescript 之上、CARF 之下、七组件之内的应用孵化系统。
> **核心动作**：选配方 → 注业务 → 三重校验 → 一次封版。
> **核心价值**：五要素一次交付；不从零拼装、不各自治理、不分散封版。
> **天花板判据**：C1–C6 六条硬标准同时满足。
> **命名对仗**：Prescient Layout Shell ｜ Prescript ｜ **NovaIncubator**。

---

## 4. 五层架构：从"脚手架"升级为"孵化内核"

```
┌────────────────────────────────────────────────────────────────────────┐
│ L6  交付层：CARF 封版证书 · 运行包 · 治理清单 · 审计接入 · 升级路径  │
├────────────────────────────────────────────────────────────────────────┤
│ L5  孵化器内核（NovaIncubator Core）                                   │
│  · 配方注册表 · 配方解释器 · 组件装配器 · 治理注入器                  │
│  · 三重校验器（配方合规 / 契约合规 / 门禁合规）                        │
│  · 封版证书签发器 · 升级/回滚引擎 · 配方版本管理器                     │
├────────────────────────────────────────────────────────────────────────┤
│ L4  组件编排层（七件组合组件）                                         │
│  · 端载体：NovaDesk · NovaMobile · NovaFlexLayout                     │
│  · 智能实体：NovaAgent · NovaDE · NovaCopilot                          │
│  · 呈现层：NovaOrbit                                                   │
├────────────────────────────────────────────────────────────────────────┤
│ L3  Prescript 范式层：壳契约 · 槽位注入 · 四原则约束                  │
├────────────────────────────────────────────────────────────────────────┤
│ L2  Prescient Layout Shell 载体层：跨端骨架 · 槽位契约                │
├────────────────────────────────────────────────────────────────────────┤
│ L1  CARF 品质层：构想 · 实现 · 打磨 · 封版                             │
└────────────────────────────────────────────────────────────────────────┘
```

**架构铁律**：

- **孵化内核不重造范式、不重造流水线**：L3/L1 分别由 Prescript 与 CARF 承担，NovaIncubator 通过 `prescript validate` 与 `carf freeze` **调用**而非重写；
- **组件装配器不穿壳骨架**：L4 组件配置必须服从 L2 槽位契约，越界即被 `incubator validate` 拦截；
- **交付层是封版的终点**：L6 五件套（证书、运行包、治理清单、审计接入、升级路径）缺一不可，缺项即封版失格。

---

## 5. 配方体系：从"模板"到"契约化组合"

### 5.1 配方结构（`incubator.recipe.yaml` 冻结格式）

配方不是 JSON 模板，是**契约化组合清单**。每个配方包含**七区**，每区为必填项：

```yaml
# incubator.recipe.yaml
recipe:
  code: R1                                  # 配方代号（R1–R5 首发冻结）
  name: Orbit 旗舰工作台
  version: 1.0.0                            # 配方版本，独立于孵化器版本
  maturity: FINAL                           # DRAFT / BETA / FINAL
  ceiling_grade: true                       # 是否达天花板级（C1–C6 全过）

shell:                                       # 区1：载体契约
  prescient_shell: PrescientLayoutShell.v2
  flex_targets: [desk, mobile, large_screen] # 三端一致声明
  slot_contract: prescript.contract.yaml

components:                                  # 区2：七件组件选型
  required: [NovaDesk, NovaFlexLayout, NovaOrbit, NovaCopilot]
  optional: [NovaAgent, NovaDE]
  versions:
    NovaOrbit: ">=1.0.0 <2.0.0"
    NovaCopilot: ">=1.0.0"

intelligence:                                # 区3：智能实体编排
  routing_policy: "orbit_entity_router"     # 按 NovaOrbit 轨道规则切换 Agent/DE/Copilot
  hitl_gates:                                # 人工闸门（Copilot 三模强制）
    - component: NovaCopilot
      mode: Draft
    - component: NovaAgent
      high_risk_action: approve

governance:                                  # 区4：治理清单（配方即治理）
  identity: SSO + tenant_isolation
  audit: otel_unified_stream + orbit_event_id
  data_boundary: per_tenant + per_role
  cost_attribution: per_orbit_per_entity

acceptance:                                  # 区5：门禁清单
  prescript_validate: required
  carf_gate: freeze-gate
  component_gates:
    NovaOrbit: [O1, O2, O3, O4, O5, O6, O7, O8]
    NovaCopilot: [human_gate_non_bypassable, grounding_no_escalation]
    NovaAgent: [admission_01_to_08]
    NovaDE: [four_elements, shadow_48h]

delivery:                                    # 区6：交付物清单
  runtime_bundle: true
  governance_manifest: true
  audit_connector: true
  carf_certificate: true
  upgrade_path: semver

observability:                               # 区7：可观测清单
  otel: true
  cost_dashboard: per_tenant_per_recipe
  sla_target: "p99 < 200ms, availability 99.95%"
```

**配方铁律**：

- 七区全填才可 `incubator validate`；
- 配方版本独立于孵化器版本，允许"孵化器升级、配方不动"与"配方升级、孵化器兼容"两条路径；
- 首发五套配方 R1–R5 全部通过 C1–C6 六条硬标准核验，均标记 `ceiling_grade: true`。

### 5.2 首发五套配方（承接上版冻结，深化要点）

| 配方 | 形态 | 天花板级关键点 |
|---|---|---|
| **R1 · Orbit 旗舰工作台** | 意图轨道工作台 | NovaOrbit O1–O8 全过；Copilot 三模不可绕过；Entity Router 支持轨内实体切换 |
| **R2 · 数字员工队伍** | 部门级数字员工流水线 | NovaDE 四要件齐备 + 队伍级治理先于规模；影子模式 ≥48h；技能层共享 |
| **R3 · 智能任务台** | 任务型自主执行工作台 | NovaAgent 八项准入全过；外部验证器独立；沙箱凭证任务级签发 |
| **R4 · 全端协同应用** | 桌面 + 移动 + 大屏一体 | 一壳三端一致；NovaFlexLayout 跨端一致性验收；同一 `prescript.contract.yaml` 覆盖三端 |
| **R5 · 极简 Copilot 应用** | 单职能嵌入式协作 | Copilot Draft/Confirm/Read-Only 三模落地；grounding 不提升权限；最小治理集 |

### 5.3 配方扩展机制（对标 Quasar CLI 的"模板可扩展"）

- **新增配方**：只需在 `recipes/` 目录新增一份 `incubator.recipe.yaml`，七区全填即被 `incubator init` 自动发现；
- **不需要改孵化器核心代码**（继承 WorkBuddy/Quasar 的"声明式路由"思想）；
- **配方发布走 RFC**：任何新增或修改配方必须走 RFC 流程，禁止静默迭代。

---

## 6. 孵化器内核：三大引擎 + 三重校验 + 一证签发

### 6.1 三大引擎

| 引擎 | 职责 | 关键设计 |
|---|---|---|
| **配方解释器（Recipe Interpreter）** | 解析 `incubator.recipe.yaml`，生成孵化计划（DAG） | 七区语义化；缺区即拦截；配方版本与孵化器版本解耦 |
| **组件装配器（Component Assembler）** | 按配方拉取七件组件、装配到 Prescient Layout Shell 槽位 | 组件版本范围校验；槽位契约与组件配置双向核对；越界即拒绝装配 |
| **治理注入器（Governance Injector）** | 按配方 `governance` 区注入身份、审计、脱敏、成本归因 | 治理**先于**业务注入（治理先于规模原则）；注入即验证 |

### 6.2 三重校验

`incubator validate` 执行三层校验，缺一层不通过：

1. **配方合规校验**：`incubator.recipe.yaml` 七区完整性 + 配方版本可用性 + `ceiling_grade` 声明可核；
2. **契约合规校验**：**调用**（非重写）`pyside-nova prescript validate`，校验壳契约、槽位边界、注释七标签；
3. **门禁合规校验**：按配方 `acceptance` 区核查组件门禁（Orbit O1–O8、Copilot 人工闸门、Agent 八项准入、DE 四要件、影子模式时长）。

### 6.3 一证签发

`incubator freeze` **调用** `pyside-nova carf freeze` 并产出**封版证书（Incubation Certificate）** ，证书内容冻结：

```yaml
# incubation.certificate.yaml（封版证书冻结字段）
certificate:
  issuer: NovaIncubator
  version: 1.0-FINAL
  recipe:
    code: R1
    version: 1.0.0
    ceiling_grade_verified: true
  components:
    frozen: [NovaDesk, NovaFlexLayout, NovaOrbit, NovaCopilot]
    versions: { NovaOrbit: "1.0.0", NovaCopilot: "1.0.0", ... }
  validation:
    recipe: pass
    prescript: pass
    gates: pass
  carf:
    freeze_id: CARF-2026-11-25-00001
    gate: freeze-gate
  governance_manifest: attached
  audit_connector: attached
  upgrade_path: semver
  signature: (企业签名)
```

**封版证书五件套**（交付层 L6）**缺一即封版失格**：

1. 封版证书（`incubation.certificate.yaml`）
2. 运行包（桌面/移动/大屏构建产物）
3. 治理清单（`governance.manifest.yaml`）
4. 审计接入（OTel 接入配置 + 轨道事件 ID 映射）
5. 升级路径（`upgrade.path.yaml`：配方版本 + 组件版本 + 兼容矩阵）

---

## 7. CLI 冻结规范（完整命令面）

```bash
# 命名空间（三空间并列，互不吞并）
pyside-nova prescript <verb>     # 开发范式
pyside-nova carf      <verb>     # 品质流水线
pyside-nova incubator <verb>     # 应用孵化器
```

### 7.1 incubator 全命令冻结

```bash
pyside-nova incubator init          # 选配方初始化孵化工程（R1–R5 或自定义配方）
pyside-nova incubator scaffold      # 按配方生成壳契约 + 组件骨架 + 七标签注释
pyside-nova incubator dev           # 孵化态运行（调用 prescript dev）
pyside-nova incubator build         # 构建组件产物（含 NovaDesk / NovaMobile / 大屏三端）
pyside-nova incubator validate      # 三重校验（配方 + 契约 + 门禁）
pyside-nova incubator freeze        # 调用 carf freeze，签发封版证书
pyside-nova incubator release       # 发布封版产物（企业级渠道）
pyside-nova incubator upgrade       # 配方版本升级（不穿透业务层）
pyside-nova incubator rollback      # 回滚到指定封版快照
pyside-nova incubator verify        # 校验封版证书有效性（离线可核）
pyside-nova incubator diff          # 比对两次封版差异（配方/组件/治理）
pyside-nova incubator audit         # 输出审计接入配置（OTel）
```

### 7.2 边界铁律

- `incubator validate` 内部**调用** `prescript validate`，不重写其校验逻辑；
- `incubator freeze` 内部**调用** `carf freeze`，以 CARF 封版为前置，不得绕过；
- `incubator upgrade` 只升级配方与组件版本，**不穿透业务层代码**（业务层改动走业务方代码仓）；
- `incubator rollback` 保证回滚后**封版证书仍可核验**（证书带快照锚点）；
- 三命名空间**不得互相吞并命令语义**，任一越界即违反封版规范。

---

## 8. 注释与孵化标签规范（七标签冻结）

```python
# @prescript
# @shell: PrescientLayoutShell
# @slot: main.content
# @contract: prescript.contract.yaml
# @incubator: R1-orbit-flagship          # 孵化配方
# @components: NovaDesk, NovaFlexLayout, NovaOrbit, NovaCopilot
# @carf: freeze-gate
```

**标签规则**：

- `@incubator`：声明所属配方（R1–R5 或自定义），缺省即视为配方未定，`incubator validate` 直接拦截；
- `@components`：仅允许七件组件名（NovaDesk / NovaMobile / NovaFlexLayout / NovaAgent / NovaDE / NovaCopilot / NovaOrbit），清单外名称即拦截；
- 其余五标签沿用 Prescript 封版规范，语义不变；
- 标签仅作可追溯标记，**不承载业务逻辑**。

---

## 9. 与 Prescript / CARF 的配套映射（闭环）

| 孵化器阶段 | Prescript 阶段 | CARF 阶段 | 封版含义 |
|---|---|---|---|
| `incubator init`（选配方） | 壳选择与槽位规划 | Conceive（构想） | 配方选定 + 预判骨架意图 |
| `incubator scaffold`（生成骨架） | 契约编写准备 | Conceive → Achieve | 壳契约 + 组件骨架 + 七标签落地 |
| `incubator dev`（注入业务） | 契约编写与业务注入 | Achieve（实现） | 按配方完成预构编排 |
| `incubator validate`（三重校验） | 槽位校验与样式收敛 | Refine（打磨） | 配方 + 契约 + 门禁三重核 |
| `incubator freeze`（封版） | validate 通过并冻结 | Freeze（封版） | 调用 CARF Freeze，签发封版证书 |
| `incubator release`（发布） | — | Freeze 之后 | 企业级渠道发布 |

**标准闭环（封版）**：

> **选配方 → Prescript 编排 → 三重校验 → CARF Freeze → 签发封版证书 → release。**

**中英对齐**：

> **Recipe → Prescript → Triple-Validate → CARF Freeze → Certificate → Release.**

---

## 10. 治理与安全：把"治理随配方同行"落到工程

### 10.1 治理四类（配方必填）

| 治理类 | 必填项 | 校验时机 |
|---|---|---|
| **身份治理** | SSO 接入 + 租户隔离 + 角色 RBAC | `incubator validate` 门禁 |
| **审计治理** | OTel 统一流 + 轨道事件 ID + 会话标识贯通 | `incubator validate` 门禁 |
| **数据治理** | 数据出境范围 + 保留期限 + 脱敏规则 | `incubator validate` 门禁 |
| **成本治理** | 按租户/配方/轨道/实体的用量归因 | `incubator freeze` 证书附加字段 |

### 10.2 安全三条铁律

1. **治理先于规模**：治理清单在 `incubator init` 阶段即写入配方，事后补治理 = 违反孵化四原则；
2. **人工闸门不可绕过**：Copilot Draft/Confirm 模式、Agent 高风险审批、DE 岗位升级路径，三条闸门在配方中硬约束，运行时由门禁器强制；
3. **封版证书可离线核验**：证书携带签名与快照锚点，脱离平台也可核验真伪与内容。

---

## 11. 成熟度模型：从"用配方"到"造壳"

NovaIncubator 的"天花板"不是一次性达成的静态高度，而是**五级成长模型**给出的可演进路径：

| 级别 | 名称 | 能力 | 判定 |
|---|---|---|---|
| **L1** | 用配方 | 使用 R1–R5 首发配方孵应用 | 能成功 `init → freeze` |
| **L2** | 组合配方 | 用七件组件组合新配方（不改组件） | 新增 `incubator.recipe.yaml` 即通过 validate |
| **L3** | 造配方 | 在七件组件基础上创建 R6+ 配方（含自定义治理清单） | 配方通过 C1–C6 六条硬标准核验 |
| **L4** | 造组件 | 在 Prescript 规范下新增八件、九件组件 | 新组件通过组件准入 + 可被配方引用 |
| **L5** | 造壳 | 在 Prescient Layout Shell 规范下新增自定义壳 | 新壳通过壳契约校验 + 可孵三端 |

**天花板判据的展开**：任何自称"应用孵化器天花板"的产品，必须至少达到 **L3（造配方）** 并公开配方扩展机制；未达 L3 者，最多是"高级脚手架"。

---

## 12. 反模式清单（封版：明确不做的事）

**NovaIncubator 明确不做以下事，以确保定位不被稀释**：

| 反模式 | 为什么不 | 替代方案 |
|---|---|---|
| 不做拖拽式低代码编辑器 | 与 Prescript 契约注入冲突 | 走 `prescript` 契约编程 + `incubator` 配方组合 |
| 不做 IDE | 与 VSCode/JetBrains 生态冲突 | 以 CLI + 契约文件 + LSP 插件嵌入现有 IDE |
| 不做部署平台 | 与 Vercel/K8s 生态冲突 | 仅输出运行包，部署由企业既有平台承接 |
| 不做组件市场 | 与开源生态边界模糊 | 七件组件为旗舰版封版组件，扩展走 RFC |
| 不替代 Prescript | Prescript 是范式，Incubator 是孵化层 | 调用 `prescript validate`，不重写 |
| 不替代 CARF | CARF 是品质流水线 | 调用 `carf freeze`，不绕过 |
| 不静默迭代 | 封版意义在于可核验 | 配方与术语变更走 RFC |
| 不承诺"一次到位" | 企业级应用是持续演进 | 以配方版本 + 升级路径承诺持续可升级 |

---

## 13. SLA 与性能封版目标

| 指标 | 封版目标 | 度量口径 |
|---|---|---|
| `incubator init → freeze` 全链路 | **≤ 4 小时**（R1–R5 标准配方，业务注入 ≤ 2000 行） | 从 `init` 到 `freeze` 的墙钟时间 |
| `incubator validate` 单次 | **≤ 60 秒**（中等规模配方） | 单机、标准配置 |
| `incubator build` 三端构建 | **≤ 15 分钟**（含桌面 + 移动 + 大屏） | 标准 CI 配置 |
| 孵化器自身可用性 | **99.95%**（SaaS 形态）；100%（CLI 离线可用） | 月度滚动 |
| 封版证书核验 | **≤ 2 秒/次**（离线） | 单机 |
| `incubator upgrade` 回滚 | **≤ 5 分钟**到指定封版快照 | 单次升级回滚 |

**SLA 铁律**：任何一次孵化若超出上述 SLA 两倍，视为配方或孵化器自身缺陷，进入 RFC 议题。

---

## 14. 规范文档目录定稿（最终版）

```text
00-terminology.md            # 预构范式与诺瓦应用孵化器术语封版声明
01-principles.md             # Prescript 四原则 + Incubator 四原则 + 天花板判据
02-shell-slot-contract.md    # 预判布局壳槽位与契约规范
03-cli-spec.md               # prescript / incubator / carf 三命名空间全命令面
04-annotation-spec.md        # 七标签规范（含 @incubator / @components）
05-carf-gate.md              # Prescript / Incubator / CARF 门禁映射
06-migration-guide.md        # 旧写法迁移到预构范式与孵化器配方
07-reference.md              # 示例、反例、验收清单
08-incubator-recipes.md      # 五套首发配方 R1–R5 与配方扩展机制
09-incubator-components.md   # 七件组合组件封版定位与边界
10-incubator-core.md         # 孵化器内核三大引擎与三重校验
11-incubator-certificate.md  # 封版证书五件套与离线核验规范
12-incubator-maturity.md     # L1–L5 成熟度模型
13-incubator-antipatterns.md # 反模式清单与边界铁律
14-incubator-sla.md          # SLA 与性能封版目标
15-incubator-ceiling.md      # 天花板判据 C1–C6 与对外表述规范
```

---

## 15. 中英双标语定稿

**正式对仗标语（白皮书 / 规范文档 / PPT 首页）**：

> **NovaIncubator · 诺瓦应用孵化器**
> **Prescript · 预构范式 ｜ Prescient Shell · 预判布局壳**

**完整交付标语（正式对外版本）**：

> **Incubated by NovaIncubator, written in Prescript, frozen by CARF.**
> **以诺瓦应用孵化器孵应用，以预构范式写壳，经 CARF 验收封版。**

**天花板宣言（对外发布会专用）**：

> **World's first five-in-one application incubator: Shell · Paradigm · Components · Governance · Certificate.**
> **世界首个"五要素一次交付"的应用孵化器：壳 · 范式 · 组件 · 治理 · 封版证书。**

**短 Slogan（宣讲 / 幻灯片 / 页脚）**：

> **选配方，孵应用；一壳七组件，五要素一次封版。**

**使用规则（承接 PRESCRIPT1.md 三层标语规则）**：白皮书正文用完整交付标语；PPT 首页用对仗标语；宣讲页脚用短 Slogan；对外发布会专页用天花板宣言。四层标语不得混用场景。

---

## 16. 封版验收清单（Sign-off Checklist）

### 16.1 名称与定义

- [ ] 中文正式名统一为 **诺瓦应用孵化器**，英文 **NovaIncubator**，CLI `pyside-nova incubator`。
- [ ] NonaWizard 不进入白皮书、CLI、规范文档正文（仅历史别名记录）。
- [ ] 一句定义、段落定义、术语卡定义按第 3 节冻结文案收录。
- [ ] "世界应用孵化器天花板"表述仅在 C1–C6 全过场景使用。

### 16.2 架构与配方

- [ ] 五层架构（L1–L6）与三大引擎 + 三重校验 + 一证签发冻结落地。
- [ ] 首发五套配方 R1–R5 全部通过 C1–C6 核验并标记 `ceiling_grade: true`。
- [ ] 配方七区格式（`incubator.recipe.yaml`）冻结，缺区即拦截。
- [ ] 配方扩展机制（新增 `recipes/` 文件即生效）通过验证。
- [ ] 七件组合组件版本范围校验机制生效。

### 16.3 门禁与封版

- [ ] `incubator validate` 三重校验落地，且**调用**而非重写 `prescript validate`。
- [ ] `incubator freeze` 以 `carf freeze` 为前置，**不绕过**。
- [ ] 封版证书五件套（证书 / 运行包 / 治理清单 / 审计接入 / 升级路径）缺一即失格。
- [ ] 封版证书支持离线核验（签名 + 快照锚点）。

### 16.4 治理与安全

- [ ] 治理四类（身份/审计/数据/成本）为配方必填，`init` 阶段写入。
- [ ] 三条人工闸门（Copilot 三模、Agent 高风险审批、DE 升级路径）硬约束生效。
- [ ] 审计贯通：NovaChat 会话 ID + NovaOrbit 轨道事件 ID + 组件事件 ID 双向可追溯。

### 16.5 成熟度与生态

- [ ] L1–L5 成熟度模型对外公布，明确 L3 为"天花板"最低门槛。
- [ ] 反模式清单（第 12 节）列入白皮书，明确不做的事。
- [ ] SLA 六项指标（第 13 节）公示并纳入监控。

### 16.6 术语与流程

- [ ] 七标签注释规范（含 `@incubator` / `@components`）落地并校验生效。
- [ ] 配方与术语变更走 RFC，禁止静默改写。
- [ ] 四层标语（对仗 / 完整交付 / 天花板宣言 / 短 Slogan）各归其位，不混用场景。

---

## 17. 封版声明

**NovaIncubator 企业级旗舰版封版方案（World-Class Ceiling Edition）至此封版。**

- 中文正式名：**诺瓦应用孵化器**
- 英文正式名：**NovaIncubator**
- 中文正式定义：**诺瓦应用孵化器是 Prescript 之上、CARF 之下、七件组件之内的应用孵化系统。**
- 英文正式定义：**NovaIncubator is the application incubation system above Prescript, below CARF, and across the seven flagship components.**
- 天花板判据：**C1–C6 六条硬标准同时满足**；最低成熟度 **L3（造配方）** 。
- 核心交付：**五要素一次交付**（壳 + 范式 + 组件 + 治理 + 封版证书）。
- 封版证书：**Incubation Certificate**（五件套缺一即失格，可离线核验）。
- 中英对仗标语：**NovaIncubator · 诺瓦应用孵化器 ｜ Prescript · 预构范式 ｜ Prescient Shell · 预判布局壳**
- 完整交付标语：**Incubated by NovaIncubator, written in Prescript, frozen by CARF.**
- 天花板宣言：**World's first five-in-one application incubator: Shell · Paradigm · Components · Governance · Certificate.**
- 短 Slogan：**选配方，孵应用；一壳七组件，五要素一次封版。**
- 配方冻结：**R1 Orbit 旗舰工作台 · R2 数字员工队伍 · R3 智能任务台 · R4 全端协同应用 · R5 极简 Copilot 应用**
- 组件冻结：**NovaDesk · NovaMobile · NovaFlexLayout · NovaAgent · NovaDE · NovaCopilot · NovaOrbit**
- 封版状态：**FINAL / Enterprise Flagship Edition / World-Class Ceiling v1.0**

> **一"判"定骨架，一"构"定范式，一"孵"定应用；五要素一次交付，一证封版，全球同类，此为天花板。**

---

## 附录一、封版验收清单（I1~I8）

| # | 验收域 | 封版判据 | 工程落点 | 归属 |
|---|---|---|---|---|
| I1 | **四阶段流水线同构异质** | C 构想 / A 实现 / R 打磨 / F 封版四阶段在同一骨架上逐阶段异质承载：`recipeSlot` 选配方 → `stageSlot` 编排 → `validateSlot` 校验 → `certificateSlot` 预览，四阶段共享壳、不共享业务状态 | `globalSlot` / `recipeSlot` / `stageSlot` / `pipelineSlot` / `validateSlot` / `certificateSlot` / `overlaySlot` 七槽宿主 `anchors.fill: parent` 铺满；`pipelineSlot` 四节点收敛链 + `stageSlot` 七区分格环身份装饰；机检：七槽注入顶层默认非空、`anchors.fill` 断言全过 | 壳内可验收 |
| I2 | **配方为一等公民** | R1~R5 五套配方以一等对象注入 `recipeSlot`，配方选择、成熟度、门禁可追溯；壳不内建任何配方数据 | 配方注册表与 R1~R5 由业务注入 `recipeSlot`；机检：壳内零内建配方状态属性、`_` 私有成员不进冻结面、无配方文案 | 业务注入 |
| I3 | **七区契约完整** | `incubator.recipe.yaml` 七区（shell / components / intelligence / governance / acceptance / delivery / observability）全填方可进入校验，缺区即拦截 | 七区契约导航由业务注入 `recipeSlot` / `stageSlot`；左栏「五列配方栅 + 列尾七刻点」几何可辨；机检：壳内零七区数据、零 `incubator.recipe.yaml` 解析逻辑 | 业务注入 |
| I4 | **三重校验** | 配方合规 / 契约合规 / 门禁合规三层校验状态可呈现于 `validateSlot`，缺一层不通过；校验结论不改写壳骨架 | 三重校验器与状态由业务注入 `validateSlot`；右栏「三道递减校验刻线 + 收敛角」身份装饰；机检：壳内只 emit `validateToggled`、不自写宿主状态 | 业务注入 |
| I5 | **封版闸门不可绕过** | `freezeRequested()` 只表达「请求封版」，是否签发证书由宿主显式确认（人工闸门）；壳不自动签发、不自动封版 | `overlaySlot` 仅提供浮层槽位（`NovaTheme.zFixedDrawer`）；机检：壳内零自动封版 / 零定时器 / 零证书签发逻辑、无孵化态业务状态 | 壳内可验收 |
| I6 | **治理随配方同行** | 身份 / 审计 / 脱敏 / 成本归因治理清单随配方一并注入、治理先于业务；事后补治理视为失格 | 治理清单与注入器由业务注入 `stageSlot`；机检：壳内零治理状态、依赖仅 6 个已导出公共类型、无私有原子 | 业务注入 |
| I7 | **与 CARF 治理连续** | 四阶段事件、配方选择、校验结果、封版请求全部携带会话标识与租户上下文；审计流中配方 ID 与组件事件 ID 双向可追溯；与 CARF 四阶段一一映射 | 会话标识 / 租户上下文 / 审计流由业务注入 `globalSlot` / `pipelineSlot`；机检：壳内 `// a11y: decorative`、零业务文案、四阶段条稳态几何非负 | 业务注入 |
| I8 | **降级安全** | 孵化内核 / 配方注册表 / 三重校验器任一不可用时退化为可用工作台骨架，不存在「内核故障即全系统不可用」单点 | 引擎不可用时 `stageSlot` / `recipeSlot` 仍可渲染；机检：极端非法入参稳态几何非负、布局不塌、`_` 私有 `readonly` 钳制生效、窗口极小 / 最大化 / 全屏不溢出 | 壳内可验收 |

**判据可机检化**：上表「工程落点」列把 I1~I8 的设计判据逐行锚定到具体槽位、纯几何装饰与
机检断言——`anchors.fill` 铺满 / 零内建配方状态 / 零自动封版 · 零定时器 / 依赖白名单 /
稳态几何非负，分别对应 `qmllint`、`scripts/audit_ceiling.py`（20/20）与装配态三态出图审计，
判据不再停留于主观描述；「归属」列区分**壳内可验收**（布局 / 装饰 / 契约 / 边界）与
**业务注入**（配方 / 契约 / 校验 / 治理 / 证书），与第零章两栏表一一对应，
并入 `scripts/audit_ceiling.py` **20/20 机检销号**。

**封版闸门 I5 的壳内体现**：`freezeRequested()` 只发出「请求封版」意图，
`certificateSlot` 只提供证书预览槽位、`overlaySlot` 只提供 `NovaTheme.zFixedDrawer` 浮层槽位
承载「宿主确认」的业务注入界面，**不内置证书签发器、不自动封版、不自动执行、不持有孵化态业务状态**；
人工闸门不可绕过——这条硬边界在壳内表现为「零自动逻辑」，在业务注入层表现为宿主一次显式确认；
壳只 emit、不代宿主决策。

---

## 附录二、组件级契约（NovaIncubator Component Contract）

> 与落地的 `Nova.Composite.LayoutShell.NovaIncubator.qml` 逐项一致；格式对齐
> `src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md` 的组件级契约写法。
> 全部依赖为**库内已导出公共类型**，无虚构组件名、无私有原子、无复制样式。

#### `NovaIncubator` — 应用孵化器工作台壳 ／ Application Incubation Workbench

- **类型**：`Nova.Composite.LayoutShell.NovaIncubator`；**定位**：应用孵化器工作台壳 ／ Application Incubation Workbench
- **7 槽 `property alias`**：`globalSlot`（全局栏）· `recipeSlot`（左栏配方库 R1~R5 + 七区契约导航）· `stageSlot`（中栏孵化舞台 · 四阶段流水线主内容）· `pipelineSlot`（底部 CARF 四阶段条）· `validateSlot`（右栏三重校验）· `certificateSlot`（右栏下封版证书预览）· `overlaySlot`（浮层，`NovaTheme.zFixedDrawer`）
- **配置**：`recipeSize`(260) · `validateSize`(340) · `globalHeight`(52) · `pipelineHeight`(64) · `certificateHeight`(160) · `showGlobal` / `showRecipe` / `showValidate` / `showPipeline` / `showCertificate`(true) · `recipeCollapsed` / `validateCollapsed`(false) · `breakpoint`(1100) · `bordered`(true) · `belowBreakpoint`(ro)
- **信号（3）**：`recipeToggled(bool collapsed)` · `validateToggled(bool collapsed)` · `freezeRequested()`
- **函数（3）**：`toggleRecipe()` · `toggleValidate()` · `requestFreeze()`
- **受控契约**：信号与函数只 emit 意图、不自写宿主状态；`freezeRequested()` 只表达「请求封版」，是否签发证书由宿主确认（人工闸门不可绕过）。
- **身份元素**（纯几何 · 抽象 · `primary` 单色系 · 实心度 ≥0.85 · 零字体依赖 · 与既有 19 个组合根互不重复）：全局栏「四级递进楔形条」（CARF 四阶段收敛）；左栏「五列配方栅 + 列尾七刻点」（R1~R5 / 七区）；中栏「七区分格环 + 中心孵化点」；阶段条「四节点收敛链」；右栏「三道递减校验刻线 + 收敛角」；证书栏「方章折角 + 封蜡点」；顶层 2px 递进发丝线。签名只占边缘 / 角标 / 列首列尾，中央完全留给业务注入。
- **键盘**：`Esc` 对 recipe / validate 两条可折叠栏分别 emit 收起意图（只 emit 已有信号，不新增公共 API）
- **RTL**：根节点 `LayoutMirroring.enabled: NovaTheme.isRtl`
- **a11y**：容器根标 `// a11y: decorative`，不挂 `Accessible.*`
- **动效**：`NovaMotion.duration(NovaMotion.transitionDuration)` + `NovaMotion.easingStandard`，两条折叠栏共用 `_dur` / `_ease`，`reducedMotion` 归零
- **边界**：全部几何入参经 `_` 私有 `readonly property` 钳制；槽位宿主 `anchors.fill: parent`（CC-6），业务注入顶层须显式 `anchors.fill: parent`
- **依赖（6 个已导出公共类型）**：`NovaTheme`(Nova.Services) · `NovaHeader` / `NovaFooter` / `NovaPage` / `NovaSeparator`(Nova.Controls) · `NovaMotion`(Nova.Design)

### 最小使用示例

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

    NovaIncubator {
        anchors.fill: parent
        recipeSize: 260
        validateSize: 340

        // 受控契约：宿主收到意图后自行决定是否修改配置
        onRecipeToggled: function(collapsed) { recipeCollapsed = collapsed }
        onValidateToggled: function(collapsed) { validateCollapsed = collapsed }
        // Shell 只 emit「请求封版」；是否签发证书由宿主确认（人工闸门不可绕过）
        onFreezeRequested: function() { }

        // 7 槽注入顶层一律显式 anchors.fill: parent（CC-6，否则 0×0 被裁）
        globalSlot:      Item { anchors.fill: parent }
        recipeSlot:      Item { anchors.fill: parent }
        stageSlot:       Item { anchors.fill: parent }
        pipelineSlot:    Item { anchors.fill: parent }
        validateSlot:    Item { anchors.fill: parent }
        certificateSlot: Item { anchors.fill: parent }
        overlaySlot:     Item { anchors.fill: parent }  // 透明顶层，取 zFixedDrawer
    }
}
```

> 真实可执行骨架：全部令牌取 `NovaTheme` 唯一门面、动效取 `NovaMotion`，
> 无虚构组件名、无伪造令牌门面、无 `title` 属性。配方解释器 / 组件装配器 / 治理注入器 /
> 三重校验器 / 封版证书签发器 / CLI 孵化内核 / 审计流均由业务向 7 槽注入，壳不内置、不持有状态。

### 冻结面登记

`api/nova-api-1.2.0.json` 中 `Nova.Composite.LayoutShell.NovaIncubator` 登记为
**22 个公共 props**（含 7 个 alias 槽位 + `belowBreakpoint` 只读派生）、**3 个 signals**、
**3 个 methods**，a11y 分类 `decorative`。与旧 `api/nova-api-1.1.0.json` 的 143 类型逐成员比对：
**旧面 0 漂移，仅新增本类型**。


---

## 附录三、CC-1~CC-8 合规映射

> 依《组合组件宪法 1.0.0》第 9 章，NovaIncubator 作为第 20 个组合根容器逐条落地组合态一致性契约。

| 条款 | 契约要求 | NovaIncubator 具体落点 |
|---|---|---|
| **CC-1** 唯一组合上下文 | 根 Item 以 `_` 私有 `readonly` 声明组合上下文，所有栏共享，禁止各栏散用 `NovaTheme.spacing*` 叠加 | 根 Item 声明 `_unit` / `_gap` / `_radius` / `_dur` / `_ease` / `_divider` / `_railBg` / `_panel` / `_ink` / `_inkSoft` 一组 `_` 私有 `readonly` 常量，7 槽（含 global / pipeline / certificate / overlay）共享同一密度栅格与分隔预算；`NovaPage` padding 与壳 padding 同值，消除三层偏移 |
| **CC-2** 单一分隔源 | 相邻栏边界只允许 1 个 `NovaSeparator` 或 1 级表面色阶；身份装饰不得落在边界线上 | 左 / 中、中 / 右、舞台 / 阶段条、校验 / 证书相邻边界各仅 1 个 `NovaSeparator`（或 1 级 `surfaceAlt`→`surface` 色阶）；四级递进楔形条 / 五列配方栅 / 七刻点 / 分格环 / 收敛链 / 校验刻线 / 方章折角 / 2px 发丝线均退到栏首列尾或角标，不叠在边界线 |
| **CC-3** 装饰预算与主次 | 主签名 1 处 + 每栏次签名 ≤1，收敛主色系，装饰实心度 ≥0.85，**抽象几何不仿交互控件** | 主签名＝全局栏四级递进楔形条；左 / 中 / 阶段条 / 右 / 证书各 ≤1 处次签名（五列配方栅 + 七刻点 / 七区分格环 + 孵化点 / 四节点收敛链 / 三道递减校验刻线 + 收敛角 / 方章折角 + 封蜡点）；全部取 `primary` 单色系派生、纯几何、零字体依赖、实心度 ≥0.85，与既有 19 个组合根互不重复，无圆钮 / 搜索胶囊 / 伪 tab |
| **CC-4** 层级顺序 | `page` < `surfaceAlt`（栏）< `surface`（头 / 证书面板）< 浮起层；靠表面色阶 + 1px 分隔表达 | `page` 作底 → `surfaceAlt` 铺 `recipeSlot` / `stageSlot` / `validateSlot` 栏 → `surface` 抬 `globalSlot` / `pipelineSlot` / `certificateSlot` 面板 → `shadowColor(level)` 浮起 `overlaySlot`；层级不靠多重描边 |
| **CC-5** 动效同步 | 折叠栏共用 `_dur` / `_ease`；锚定链**恒定指向栏 wrap**，禁用 `visible` 三元切换 | `recipe` / `validate` 两条折叠栏共用 `NovaMotion.duration(NovaMotion.transitionDuration)` + `NovaMotion.easingStandard`，栏宽归零 + `Behavior on width` 共用 `_dur` / `_ease`，锚链恒指栏 wrap、无 `sep.visible ? … : …`，`reducedMotion` 归零 |
| **CC-6** 槽位内容基线 | 槽位宿主 `anchors.fill` 铺满；**业务注入顶层显式 `anchors.fill: parent`**；内容限宽；中央不塞空态占位 | 7 槽宿主 `anchors.fill: parent` 铺满并提供可协商 `implicit*`；最小示例 7 槽注入顶层逐槽示范 `anchors.fill: parent`；`stageSlot` 孵化主内容限宽居中；中央空态由业务注入承担，壳不放占位 |
| **CC-7** 装配态验收 | 装配后出图审计；单组件 PASS ≠ 装配 PASS | 7 槽同屏密度 / 对齐 / 层级 / 装饰预算 / 伪控件扫描 / 空态 / 折叠动画稳态 / 浅深双主题实心业务注入，**浅 · 深 · 变体三态出图**（57 → 60 张），并入 `scripts/audit_ceiling.py` 20/20 机检销号 |
| **CC-8** 参考实现纪律 | 成品级 showcase 真实业务注入、无占位文案；调参面板与展示区分离 | 独立演示为成品级「应用孵化器工作台」showcase（7 槽真实业务内容注入：R1~R5 / 七区契约 / 三重校验状态 / 封版证书预览，无占位文字），Gallery 调参面板默认收起、不与展示区同级 |

---

> **R 打磨实录（1.2.0 · 实测驱动、按需打磨 · 零公共面改动）**：首轮三态出图视觉复核暴露 2 处
> **业务注入侧争位**——① 配方库 / 三重校验标题与壳身份装饰轻微重叠；② 证书栏默认
> `certificateHeight: 160` 裁切了五件套第 5 件「升级路径」。按 CC-6 / CC-8 判定为注入内容避让问题，
> **不改组件公共面、不动冻结指纹**，仅在 `examples/layout_shell/incubator/main.qml` 做
> `topMargin: 40` / `topMargin: 36` / `certificateHeight: 190` 三处避让后重出图 PASS。
> 组件侧零 `_` 私有 PATCH、零新增公共属性、零指纹漂移——如实登记，不硬造修改。

## 附录四、异常与降级边界

> 呼应 I8 降级安全判据：孵化内核不可用时退化为可用工作台骨架，壳只保证**布局不塌**。

| 异常 | 业务层降级（业务注入负责） | 壳内保证（可机检） |
|---|---|---|
| **孵化内核不可用 / CLI 工具链离线** | 退化为可用的静态工作台，配方与阶段态以只读清单承载 | 四阶段七槽骨架与 7 槽宿主稳态几何非负、不溢出，`stageSlot` 仍可渲染；壳内无内核依赖 |
| **配方注册表为空** | `recipeSlot` 呈现「未选配方」业务空态，不自动填充占位配方 | `recipeSlot` 折叠 / 隐藏后左—中锚链恒定、无布局跳变（CC-5）；壳内零内建配方状态 |
| **三重校验器异常** | `validateSlot` 呈现校验不可用态，封版闸门保持关闭，不自动放行 | 壳内零定时器、零自动封版逻辑（I5 硬边界） |
| **极端非法入参**（负尺寸 / 超大尺寸 / 非法枚举同时注入） | — | `_` 私有 `readonly` 钳制后稳态几何非负、有限、无残留；`undefined` / 空值回退安全默认值 |
| **窗口极小 / 最大化 / 全屏** | — | `breakpoint` / `belowBreakpoint`(ro) 驱动自适应，布局不丢元素、不溢出（宪法第 7 章） |

**边界底线**：不存在「内核故障即全系统不可用」的单点。壳不承载孵化内核、不持有配方 / 校验 /
证书状态，故内核降级时壳**只保证布局不塌**，四阶段可用性与证书签发由业务注入层按上表兜底。

---

## 附录五、CARF 四阶段封版记录

> 依《组合组件宪法 1.0.0》卷首 CARF 宣言（组合组件执行版）与母法卷首，逐阶段登记落地。

| 阶段 | NovaIncubator 落地 | 法条锚点 |
|---|---|---|
| **C 构想** | 本方案（法源链 · 零章三要素 · 零之一张力消解 · 四阶段流水线同构异质 · 封版闸门不可绕过 · I1~I8）+ 组合宪法 1.0.0 + 第 9 章 CC-1~CC-8 + 封版规范 v2.1.0 法源先行 | 第 0 章 / 第 9 章 |
| **A 实现** | `NovaIncubator.qml` + 7 槽 `property alias` + `qmldir` 导出 + a11y `decorative` 登记 + **1.2.0 整批单次重签冻结面**（四增量 + 第 20 组合根：143→144 类型 ／ 19→20 组合根 ／ `decorative` 83→84；指纹 `68b34a408489b6a8`） | 第 1/2/4/5/8 章 · 母法第 13 章 |
| **R 打磨** | 六维天花板逐项评估 + 浅 / 深 / 变体**三态装配图**出图审计（57 → 60 张）+ `scripts/audit_ceiling.py` **20/20** 机检销号（静态 CC 契约 / 实例化 / 极端非法入参稳态几何 / RTL / reducedMotion / 断链扫描） | 第 9 章 CC-7 · `CEILING_AUDIT.md` |
| **F 封版** | 公共 API 签名逐字不变、整批单次重签后零漂移 + `CHANGELOG` / 权威清单 / `PARITY` / 账本 / AI 离线副本闭环；**指纹 `68b34a408489b6a8`**；**发布边界归 CSA** | 第 8 章第 6 条 · 母法第 13 章 |

**执行铁律**：整批登记、单次重签、整批验收，**禁止逐个重签产生中间指纹**；
1.1.0 为未发布批次，本轮四增量 + 第 20 组合根整批抬升 1.2.0 单次重签；
封版资格由母法第 13 章 API 冻结门禁授予，本记录为交付物登记，不自行宣称已发布；指纹 `68b34a408489b6a8` 由生成器签署件确认。

**1.2.0 整批全量门禁（全绿）**：

```text
check_all.py --tier static              3/3 PASS（a11y 144/144 · API 冻结 144 零漂移 · qmllint 0 error / 594 warning 预算内）
pytest test_api_freeze.py test_layout_shells.py -q            53 passed
audit_ceiling.py                       20/20 PASS（20 字面量实例化 · 21/21 showcase+Gallery ·
                                      60/60 组极端非法入参零负几何 · RTL 20/20 · reducedMotion 300.0→0 · 481 链接断链 0）
audit_foundations.py                   15/15 PASS（127 非单例类型实例化零缺陷 · 三态零负几何）
mkdocs build                           exit 0 / 0 WARNING / 0 内容 INFO
audit_showcase.py --name incubator     3 张 1440×900 出图 PASS（浅 / 深 / 变体）
gen_apidocs.py / gen_component_list.py 144 类型 API · 20 页逐组件文档 · 60 张三态图引用 · 生成器幂等
```


---

## 附录六、命名定稿与理据（承接 `NovaIncubator_name.md`）

> **史料，原文见 `NovaIncubator_name.md`，逐字保留。** 以下命名决策表、命名理据、七件组件分层定位表、
> 孵化四原则、对标表述均为命名定稿稿原文，定义不改写、不回写第 20 组合根。

### 6.1 命名决策表（原文）

在 `NonaWizard` 与 `NovaIncubator` 之间，**选定 NovaIncubator**，理由如下（一并封版）：

| 候选 | 判定 | 依据 |
|---|---|---|
| NonaWizard | **否** | "Nona" 首字母脱离 Nova 体系，破坏 NovaChat / NovaAgent / NovaDE / NovaCopilot / NovaOrbit 的命名同源；"Wizard" 语义偏轻量向导，承载不了企业级旗舰版封版；且"Wizard"易与交互组件混淆 |
| **NovaIncubator** | **定** | "Nova" 与全体系同源；"Incubator" 精确对应"应用孵化器"定位，语义即能力；对外可缩写为 **NI**，对内 CLI 命名空间为 `incubator`，与 `prescript`、`carf` 构成三命名空间对仗 |

**中文正式名：诺瓦应用孵化器**
**英文正式名：NovaIncubator**
**一句话关系（封版口径）**：

> **以预构范式（Prescript）编写预判布局壳（Prescient Layout Shell），由诺瓦应用孵化器（NovaIncubator）按组件组合孵化，经 CARF 验收封版。**

### 6.2 命名理据（原文，白皮书收录版）

> **诺瓦应用孵化器（NovaIncubator）**
> - **"诺瓦"**：承自 Nova 体系（NovaChat / NovaAgent / NovaDE / NovaCopilot / NovaOrbit），保持品牌同源；同时含"新星"意蕴，指向从壳到应用的诞生。
> - **"应用孵化器"**：明示这不是 IDE、不是低代码平台、不是组件库，而是**把 Prescript 产物 + 七件组件组合成企业级应用**的孵化系统；孵化 = 选种（壳与组件）+ 培育（Prescript 编排）+ 验收（CARF 封版）+ 交付（应用产物）。
> - **英文 NovaIncubator**：`Nova（新星）+ Incubator（孵化器）`，与中文一一对仗。

**对仗铁律**：

> **预判布局壳** 讲**骨架载体**；**预构范式** 讲**开发方式**；**诺瓦应用孵化器** 讲**应用诞生方式**。
> "判"、"构"、"孵"三字对仗：一判骨架，一构范式，一孵应用。

### 6.3 七件组件分层定位表（原文，封版口径）

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

### 6.4 孵化四原则（原文）

与 Prescript 四条原则并列为**孵化层四原则**：

1. **配方先于拼装**：先选配方，再个性化；不在孵化器内临时拼装无归属的组件组合。
2. **壳契约定于组件**：组件配置必须服从 Prescient Layout Shell 的槽位契约，不得因组件需求反向穿透壳骨架。
3. **治理随配方同行**：每套配方携其治理清单（身份、审计、人工闸门、封版门禁）一并孵化，事后补治理视为失格。
4. **封版即发布**：孵化产物必须经 CARF Freeze 与配方对应门禁，方可标记企业级旗舰版交付。

### 6.5 对标表述（原文，正式收录）

> 诺瓦应用孵化器（NovaIncubator）借鉴 Quasar CLI 的模板式脚手架思想，但并非脚手架复制。NovaIncubator 以**配方**为选型单位，向上组织 NovaDesk / NovaMobile / NovaFlexLayout / NovaAgent / NovaDE / NovaCopilot / NovaOrbit 七件组合组件，向下对接 Prescript 开发范式与 CARF 品质流水线，形成"范式 → 孵化 → 封版"的企业级闭环。对标 Quasar CLI 的脚手架层，NovaIncubator 多出**组件配方**与**治理随行**两层内涵；对标低代码平台，NovaIncubator 不追求拖拽式所见即所得，而坚持 Prescript 的契约注入与 CARF 的封版验收。

---

## 附录七、封版声明（1.2.0 收官版）

> **NovaIncubator · 诺瓦应用孵化器 ／ Application Incubation Workbench**

- **中文正式定义**：NovaIncubator（诺瓦应用孵化器）是本库第 20 个组合根容器、诺瓦应用孵化器的工作台壳与孵化流水线的呈现载体，以 CARF 四阶段流水线 + 7 槽无业务语义骨架承载配方库 / 孵化舞台 / 四阶段条 / 三重校验 / 封版证书预览，治理与业务语义全由业务槽位注入，经 CARF 四阶段与 I1~I8 验收封版；发布边界归 CSA。
- **英文正式定义**：NovaIncubator (Application Incubation Workbench) is the 20th composite root container — the workbench shell and presentation carrier of the Nova Application Incubator — hosting the recipe library, incubation stage, four-stage pipeline, triple validation and freeze-certificate preview on a CARF-four-stage, seven-slot business-semantics-free skeleton, with all governance and business semantics injected through business slots, frozen under CARF and the I1–I8 sign-off checklist; release authority rests with CSA.
- **术语对仗**：NovaIncubator · 诺瓦应用孵化器 ｜ Application Incubation Workbench
- **封版状态**：`FINAL` ／ `Enterprise Flagship v1.0-FINAL`（设计法源层）
- **封版底线**：孵化系统 / 方法论层「不是运行时组件」的历史定义逐字保留；本组件只交付组件层工作台壳，不内建孵化内核、不自动签发证书；`freezeRequested()` 只 emit 请求，人工闸门不可绕过；七件组合组件「孵化原料」史料不改写。
- **法源与资格**：母法 `docs/CONSTITUTION.md` → 组合宪法 1.0.0 → 第 9 章 CC-1~CC-8 → 封版规范 v2.1.0 → 本方案；法定封版资格只由母法第 13 章 API 冻结门禁整批单次重签授予（1.2.0：143→144 类型 ／ 19→20 组合根 ／ `decorative` 83→84，指纹 `68b34a408489b6a8`），**本文档不自行宣称组件封版资格、不自行宣称已发布；指纹 `68b34a408489b6a8` 以生成器签署件为准，发布边界归 CSA**。

> **收束句**：一「判」定骨架，一「构」定范式，一「孵」定应用；第 20 个组合根容器收官、
> 七件组件 + 一工作台壳至此齐备——孵化层之法与组件层之壳分层并存、同证封版，
> 诺瓦应用孵化器自此实至名归，本库组合根容器序列终抵天花板。
