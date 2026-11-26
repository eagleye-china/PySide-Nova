# pyside-nova 组件分类与架构分层实用指南

> **文档性质**：本库**现行**实用文档（非史料、非方案稿）· 组件与文档分类的唯一查阅入口
> **适用版本**：**1.2.0** · `api/nova-api-1.2.0.json` · **144 导出类型** · **20 组合根容器** · 冻结指纹 **`4f882374ad52262b`** · **20/20 天花板销号** · **60 张三态装配图**
> **前身**：`PRESCRIPT_CLASSIFY.md`（外部建议稿，2026-11-26 更名重写；其目录重构建议前提经核不成立，核心内容存档于附录 A）
> **法源链**：母法 [`CONSTITUTION.md`](../CONSTITUTION.md)（卷首 CARF）→ 组合宪法 [`COMPOSITION_CONSTITUTION.md`](../COMPOSITION_CONSTITUTION.md) 1.0.0（第 9 章 CC-1~CC-8）→ [封版规范 v2.1.0](SPEC_FREEZE.md) → [`ARCHIVE_NovaIncubator_Naming.md`](ARCHIVE_NovaIncubator_Naming.md)（五层概念体系 / 七件组件 / R1~R5）→ 本指南
> **状态**：**现行 · 2026-11-26 · 待 CSA 随 1.2.0 发布**

---

## 0. 先读这一节：原稿三条前提校正

前身 `PRESCRIPT_CLASSIFY.md` 从一张目录截图出发，判定「20 个组合根平铺在 `Composite/LayoutShell/` 违背五层概念体系」，建议按业务域**物理重构 QML 目录**。经磁盘事实（`qmldir` / 冻结清单 / QML 字面量）与 1.2.0 封版法源逐条核对，**该判定不成立**；若照搬会直接摧毁 1.2.0 冻结面。

| # | 原稿主张 | 磁盘 / 法源事实 | 裁定 |
|---|---|---|---|
| 1 | 「五层概念体系」要求 QML 目录按 载体 / 范式 / 孵化 / 组件 / 品质 分层 | 五层是**概念分工**（`NovaIncubator_name.md` §2 定稿），不是 QML 模块物理层；本库物理层是 **5 个 `qmldir` 模块**（见 §1） | 概念分层与物理分层**不一一对应**；分类保留在文档层台账（§4），物理层已拍平为根目录，子目录不升格为模块 |
| 2 | `NovaAgent` / `NovaDE` / `NovaCopilot` 是智能实体运行时，`NovaOrbit` 是呈现层，`NovaIncubator` 是非运行时的孵化系统 | 1.2.0 封版法源：**20 个组合根一律是「无业务语义骨架」**（纯布局壳），业务语义全由 `property alias` 槽位注入；[`LAW_NovaIncubator.md`](LAW_NovaIncubator.md) 零之一已裁定「方法论层孵化系统史料 + 组件层应用孵化器工作台壳」**双层并存** | 按 CC-1「唯一组合上下文」刻意同处 `Nova.Composite.LayoutShell` **单一模块**——这是架构决策，不是疏忽 |
| 3 | 应拆 `Prescient/` `Base/` `Entities/` `Orbit/` `Incubator/` 并各配 `qmldir` | **仅改模块 URI** 才会改变 144 类型归属并破坏已发布 `import` 兼容；仅移动文件 + `qmldir` 路径导出则 URI 与公共面全不变（Qt 实测通过） | **物理层已拍平为根目录**（九类降为文档层台账，§1.1 / §4），模块 URI 恒为单一 `Nova.Composite.LayoutShell`；独立 `qmldir` 模块属另一议题，本次不做 |

**另有三次事实误差，一并校正**：

1. 端载体实际名为 **`NovaDesktop`**（`qmldir` 与冻结清单），原稿写 `NovaDesk`（命名稿历史别名，未进入组件库）；
2. **`NovaSetupWizard` 是 15 项 GA 组合根之一**（安装配置向导壳），不属孵化层，也不与 `NovaIncubator` 同族；
3. **七标签 `@incubator` / `@components` 是孵化工程生成的应用代码规范**（见 `NovaIncubator_name.md` §8），不是组件库 QML 源码的标签；组件库源码使用 `// a11y: decorative` 等 a11y 标记。

> **本指南的落点（CSA 2026-11-26 12:05 拍板「九类子目录拍平」后更新）**：分类落到**三层** —— 分类台账（§4）、文档站导航（§5）、概念映射（§2）；物理层回归根目录平铺。**20 个 QML 平铺于 `Composite/LayoutShell/`，`qmldir` 逐项平铺导出；模块 URI、20 个类型名、144 个公共成员签名全部不变**，公共面零漂移。九类物理子目录是 1.2.0 曾落地的历史形态（CSA 06:55 授权），12:05 撤回为文档层分类，理由见 §1.1。

---

## 1. 唯一物理事实源：5 个 `qmldir` 模块

> 事实源：`src/pyside_nova/qml/Nova/**/qmldir` + [`API_FREEZE.md`](../API_FREEZE.md) / [`COMPONENT_LIST.md`](../COMPONENT_LIST.md)（均为生成器产物，禁手改）。

| 模块 URI | 目录 | 类型数 | 职责 | 冻结性质 |
|---|---|---:|---|---|
| `Nova.Controls` | `Controls/` | **91** | 基础控件（Btn / Field / Table / Header / Footer / Separator …） | 1.0.0 GA 冻结 |
| `Nova.Behaviors` | `Behaviors/` | **13** | 行为扩展 | GA 冻结 |
| `Nova.Services` | `Services/` | **16** | 服务与门面（`NovaTheme` / `NovaMotion` / `NovaI18n` / Bridge …） | GA 冻结 |
| `Nova.Design` | `Design/` | **4** | 设计令牌与主题 | GA 冻结 |
| `Nova.Composite.LayoutShell` | `Composite/LayoutShell/` | **20** | 组合根容器（无业务语义骨架） | 15 GA + 5 增量，1.2.0 整批单次重签 |
| **合计** | — | **144** | — | `4f882374ad52262b` |

**铁律**：`qmldir` 是**唯一**模块导出清单，也是 `gen_api_freeze.py` 生成冻结面的输入。**物理目录形态（平铺或子目录）+ `qmldir` 路径导出 ≠ 模块 URI 变更**（Qt 实测 `Foo 1.0 Sub/Foo.qml` 可正确解析并实例化）；现行物理层为平铺，与 1.0.x 已发布形态一致。只有把子目录升格为独立 `module Nova.X` 才会改变类型归属，须按母法第 8 章走 **major 重签 + RFC**。

### 1.1 物理平铺 + 九类文档层台账（1.2.0 · 12:05 拍平后）

> 事实源：`src/pyside_nova/qml/Nova/Composite/LayoutShell/qmldir` 的导出行；**单一 `module Nova.Composite.LayoutShell`，20 项逐项平铺导出**。九类分类语义保留在 §4 台账与文档站导航，不再落物理子目录。

> **历史登记（史料不圆场）**：1.2.0 曾于 CSA 06:55 授权把 20 个 QML 按九类移入物理子目录、`qmldir` 以相对子路径导出（指纹 `68b34a408489b6a8`）。CSA 2026-11-26 **12:05 指令「拍平」**，物理层回归根目录平铺，指纹重签为 `4f882374ad52262b`。验证：把新清单 20 个 `file` 反向归一化回旧子目录路径，指纹**精确还原 `68b34a408489b6a8`** → 公共成员逐字零漂移，唯一变化是 `file` 溯源元数据。拍平同时让物理路径回到 1.0.x 已发布形态，老用户按路径引用零漂移。

```text
Composite/LayoutShell/
├── qmldir                 # 单一模块 URI，20 项逐项平铺导出
├── README.md              # 20 项完整契约 + 九类分类
├── NovaSidebar.qml        # 主导航（4）之一 · 九类语义分类见 §4
├── ...                    # 共 20 个 .qml 平铺（无物理子目录）
└── NovaIncubator.qml      # 第 20 个 · 本库最后一个组合组件
```

QML 源码无任何相对导入（全库扫描 0 命中），一律 `import Nova.Controls / Services / Design`，故物理移动不影响解析；20 个文件头注释路径已同步更新。hatch wheel 以 `packages = ["src/pyside_nova"]` 递归打包，平铺 QML 随包发布。

---

## 2. 逻辑五层概念体系 ↔ 五模块映射

五层出自 `NovaIncubator_name.md` §2（中英对仗封版），是**概念分工**；五模块是**编译单元**。二者允许一对多 / 多对一，**不得用目录树强制映射概念层**。

| 概念层 | 中文 / 英文 | 管什么 | 物理落点 | 运行时组件？ |
|---|---|---|---|---|
| 载体层 | 预判布局壳 / Prescient Layout Shell | 预置槽位与布局骨架 | `Nova.Composite.LayoutShell` **20 项** | 是（骨架） |
| 范式层 | 预构范式 / Prescript | 怎么编写壳 | 规范文档（`SPEC_PRESCRIPT.md` / `SPEC_PRESCRIPT_ZH.md`） | 否（方法论） |
| 孵化层 | 诺瓦应用孵化器 / NovaIncubator | 把什么组合、孵成什么应用 | 方法论层 = 史料；组件层 = [`NovaIncubator.qml`](LAW_NovaIncubator.md)（第 20 组合根） | 组件层是骨架 |
| 组件层 | 七件组件 | 被编排进应用的原料 | **全部在 `Nova.Composite.LayoutShell`**：`NovaDesktop` / `NovaMobile` / `NovaFlexLayout` / `NovaAgent` / `NovaDE` / `NovaCopilot` / `NovaOrbit` | 是（骨架） |
| 品质层 | CARF | 什么时候算封版 | [`AUDIT_CEILING.md`](AUDIT_CEILING.md) + `scripts/audit_*.py` | 否（流水线） |

> **映射铁律**：一个概念层可跨多个模块，一个模块可承载多个概念层。组合根同处单一模块，恰恰保证了 CC-1「唯一组合上下文」与 CC-8「参考实现纪律」——所有壳共享同一套 `NovaTheme` / `NovaMotion` 门面、同一套槽位 alias 约定、同一份冻结面。

---

## 3. 全库 144 类型分类总表（按架构域）

| 架构域 | 类型数 | 所属模块 | 代表类型 | 查找入口 |
|---|---:|---|---|---|
| 基础控件 | 91 | `Nova.Controls` | `NovaBtn` / `NovaField` / `NovaTable` / `NovaHeader` / `NovaFooter` / `NovaSeparator` | [`COMPONENT_LIST.md`](../COMPONENT_LIST.md) |
| 行为扩展 | 13 | `Nova.Behaviors` | 动效 / 交互行为 | 同上 |
| 服务与门面 | 16 | `Nova.Services` | `NovaTheme` / `NovaMotion` / `NovaI18n` | 同上 |
| 设计令牌 | 4 | `Nova.Design` | 颜色 / 间距 / 字阶 | [`DESIGN_TOKENS.md`](../DESIGN_TOKENS.md) |
| **组合根骨架** | **20** | `Nova.Composite.LayoutShell` | 见 §4 | **本指南 §4** / [`components/index.md`](../components/index.md) |

> 组合根是唯一「由 ≥2 个已导出公共类型组合而成」的架构域；基础控件 / 行为 / 服务 / 令牌不套 CC 契约（组合宪法第 0 章第 3/4 条），其 15/15 健壮性台账见 [`CEILING_AUDIT_FOUNDATIONS.md`](../CEILING_AUDIT_FOUNDATIONS.md)。
> **下钻（1.2.0 新增）**：91 个 `Nova.Controls` + 13 个 `Nova.Behaviors` 的**十域细分**（Controls 七域 / Behaviors 三域）、144 类型零遗漏机检台账与依赖纪律，见现行实用文档 [`GUIDE_COMPONENT_DOMAINS.md`](GUIDE_COMPONENT_DOMAINS.md)（《基础组件域分类与依赖纪律实用指南》）；机检尺 `scripts/audit_domains.py` 守护分类不腐化。

---

## 4. 20 组合根 · 九类分类台账（核心 · 可查）

**分类口径沿用模块 README「三、20 项完整契约」既有九类**，不另造体系。槽位 / 信号 / 函数均取自 QML 字面量实测（`property alias` / `signal` / `function`），**20 项全部具备浅 / 深 / 变体三态装配图（共 60 张）**，索引见 [`components/showcase.md`](../components/showcase.md)。

| 架构域（九类） | 组件 | 槽位 | 信号 / 函数 | 定位 | 批次 | 法源 |
|---|---|---:|---|---|---|---|
| **主导航（4）** | `NovaSidebar` | 5 | 1 / 1 | 侧边导航工作台 | GA | 模块 README 契约 |
| | `NovaTopNavigation` | 5 | 1 / 1 | 顶部导航工作台 | GA | 同上 |
| | `NovaDualSide` | 5 | 2 / 2 | 双侧边工作台 | GA | 同上 |
| | `NovaTabShell` | 4 | 3 / 0 | 标签页工作台 | GA | 同上 |
| **多栏工作台（3）** | `NovaThreeColumn` | 6 | 1 / 0 | 三栏工作台 | GA | 同上 |
| | `NovaCompare` | 5 | 1 / 1 | 双栏对比壳 | GA | 同上 |
| | `NovaCardGrid` | 4 | 0 / 0 | 卡片网格壳 | GA | 同上 |
| **浮层容器（2）** | `NovaModal` | 3 | 1 / 1 | 模态弹窗壳 | GA | 同上 |
| | `NovaDrawerPanel` | 3 | 1 / 1 | 侧边滑出面板壳 | GA | 同上 |
| **独立页壳（2）** | `NovaSetupWizard` | 5 | 3 / 0 | 安装配置向导壳 | GA | 同上 |
| | `NovaBlankPage` | 4 | 0 / 0 | 纯净单页壳 | GA | 同上 |
| **多端根壳（3）** | `NovaDesktop` | 5 | 1 / 0 | 桌面应用根壳 | GA | 同上 |
| | `NovaMobile` | 4 | 1 / 0 | 移动应用根壳 | GA | 同上 |
| | `NovaFlexLayout` | 4 | 1 / 0 | 企业大屏弹性布局壳 | GA | 同上 |
| **AI 对话主窗口（1）** | `NovaChat` | 7 | 3 / 3 | 六轨按轨分治主窗口 | GA | 同上 |
| **AI 智能组合根（3）** | `NovaAgent` | 6 | 3 / 3 | 智能体任务执行工作台 | 1.2.0 增量 | [`LAW_NovaAgent.md`](LAW_NovaAgent.md) |
| | `NovaDE` | 6 | 3 / 3 | 数字员工岗位工作台 | 1.2.0 增量 | [`LAW_NovaDE.md`](LAW_NovaDE.md) |
| | `NovaCopilot` | 5 | 3 / 3 | 增强型协作面板 | 1.2.0 增量 | [`LAW_NovaCopilot.md`](LAW_NovaCopilot.md) |
| **意图轨道呈现层（1）** | `NovaOrbit` | 7 | 3 / 3 | 意图轨道工作台（第 19 组合根） | 1.2.0 增量 | [`LAW_NovaOrbit.md`](LAW_NovaOrbit.md) |
| **应用孵化器工作台（1）** | `NovaIncubator` | 7 | 3 / 3 | 应用孵化器工作台（**第 20 个、本库最后一个组合组件**） | 1.2.0 增量 | [`LAW_NovaIncubator.md`](LAW_NovaIncubator.md) |

> **批次口径**：15 项 GA 于 1.0.0 封版；5 项增量为 additive minor。**1.1.0 是未发布中间批次**（四增量），已与第 20 组合根一并抬升 **1.2.0 整批单次重签、禁止中间指纹**；详见仓库根 `CHANGELOG.md` `[1.2.0]` 段。
> **法源口径**：15 项 GA 的权威契约在 `src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md`「三、20 项完整契约」；5 项增量另有企业级旗舰版封版法源（上表最后一列）。

### 4.1 按场景选型速查（实用）

| 你要做的界面 | 优先看哪一类 | 推荐组合根 | 说明 |
|---|---|---|---|
| 后台管理 / 带侧栏的应用框架 | 主导航 | `NovaSidebar` · `NovaTopNavigation` · `NovaTabShell` | 需要双侧边用 `NovaDualSide` |
| 三栏 / 对比 / 卡片陈列 | 多栏工作台 | `NovaThreeColumn` · `NovaCompare` · `NovaCardGrid` | 纯布局，业务由槽位注入 |
| 弹窗 / 抽屉 / 向导 | 浮层容器 + 独立页壳 | `NovaModal` · `NovaDrawerPanel` · `NovaSetupWizard` | 向导壳有 3 信号、无函数 |
| 桌面 / 移动 / 大屏一套壳 | 多端根壳 | `NovaDesktop` · `NovaMobile` · `NovaFlexLayout` | 跨端一致性由 `NovaFlexLayout` 承载 |
| 会话式主窗口 | AI 对话主窗口 | `NovaChat` | 七槽六轨，治理语义全由业务注入 |
| 智能体 / 数字员工 / 协作增强工作台 | AI 智能组合根 | `NovaAgent` · `NovaDE` · `NovaCopilot` | 八项准入控制 / 四要件 / 确认闸门**全部业务注入** |
| 意图轨道级旗舰工作台 | 呈现层 | `NovaOrbit` | 七槽三栏同构异质 |
| 配方选型 / 校验 / 封版证书工作台 | 应用孵化器工作台 | `NovaIncubator` | `requestFreeze()` 只 emit，人工确认闸门不可绕过 |

### 4.2 九类与五套首发配方的对应（R1~R5）

`NovaIncubator_name.md` §5 冻结的 R1~R5 是**方法论层配方**，其「必选组件」在本库一律对应**组合根骨架**（而非独立业务实体）：

| 配方 | 应用形态 | 对应本库组合根（骨架层） |
|---|---|---|
| R1 · Orbit 旗舰工作台 | 意图轨道工作台 | `NovaDesktop` + `NovaFlexLayout` + `NovaOrbit` + `NovaCopilot` |
| R2 · 数字员工队伍 | 部门级流水线 | `NovaDesktop` + `NovaFlexLayout` + `NovaDE` + `NovaCopilot` |
| R3 · 智能任务台 | 任务型自主执行 | `NovaDesktop` + `NovaFlexLayout` + `NovaAgent` + `NovaCopilot` |
| R4 · 全端协同应用 | 桌面 + 移动 + 大屏 | `NovaDesktop` + `NovaMobile` + `NovaFlexLayout` + `NovaCopilot` |
| R5 · 极简 Copilot 应用 | 单职能嵌入式协作 | `NovaDesktop`（或 `NovaMobile`）+ `NovaFlexLayout` + `NovaCopilot` |

> 配方是**选型模板**，不是运行时依赖；组件库本身不实现配方解释器、装配器、校验器与证书签发器——这些由成品级 Demo `examples/layout_shell/incubator/main.qml` 作为业务注入示范，或由后续 CLI 工具链承载。

---

## 5. 文档分类表（"分类"在文档层的落实）

### 5.1 `docs/prescript/` 13 份 md 归类

| 类别 | 文件 | 性质 | 维护方式 |
|---|---|---|---|
| **现行 · 分类实用文档** | `COMPONENT_CLASSIFICATION.md`（本文件） | 现行唯一分类入口 | 随分类口径变更更新 |
| **现行 · 域分类实用文档** | `COMPONENT_DOMAINS.md` | 基础组件十域 / 依赖纪律（本指南 §3 下钻） | 由 `scripts/audit_domains.py` 机检守护 |
| **现行 · 企业级旗舰版封版法源（5）** | `NovaAgent.md` · `NovaDE.md` · `NovaCopilot.md` · `NovaOrbit.md` · `NovaIncubator.md` | **现行法源**（不是历史档案） | 封版后只读，变更走 RFC |
| **现行 · 天花板台账（1）** | `CEILING_AUDIT.md` | CARF-R 20/20 销号台账 | 每轮验收追加，历史快照下沉 |
| **史料 · 四稿（4）** | `LayoutShell.md` · `LayoutShellPlan.md` · `LayoutShellPrompt.md` · `PrescientLayoutShell.md` | 早期设计史料 | 只归档、不改 |
| **史料 · 联合总纲（1）** | `LAW_NovaAgent.md` / `LAW_NovaDE.md` / `LAW_NovaCopilot.md`（原联合总纲已拆分归档） | 拆分前的联合方案 | 只归档、不改 |
| **史料 · 命名定稿（1）** | `NovaIncubator_name.md` | 五层体系 / 七件组件 / R1~R5 / 七标签 | 只归档、不改 |

> **本次修正**：文档站导航原先把 5 份**现行封版法源**归入「历史档案与附录」，属分类错误；现独立为「企业级旗舰版封版法源（5 项）」组，史料留在「方案与历史档案」组，本指南独立成组。

### 5.2 全站文档分类

| 类别 | 代表文件 | 是否生成物 |
|---|---|---|
| 法源 / 宪法 | [`CONSTITUTION.md`](../CONSTITUTION.md) · [`COMPOSITION_CONSTITUTION.md`](../COMPOSITION_CONSTITUTION.md) · 5 份封版法源 | 手写 |
| 规范 / 白皮书 | `docs/prescript/` 下 PRESCRIPT 系列、封版规范 v2.1.0、旗舰组件库白皮书 | 手写 |
| 台账 / 对账 | [`AUDIT_CEILING.md`](AUDIT_CEILING.md) · [`../CEILING_AUDIT_FOUNDATIONS.md`](../CEILING_AUDIT_FOUNDATIONS.md) · [`../PARITY.md`](../PARITY.md) · [`../ECOSYSTEM_PARITY.md`](../ECOSYSTEM_PARITY.md) | 手写 |
| 权威清单 / 冻结面 | [`../COMPONENT_LIST.md`](../COMPONENT_LIST.md) · [`../API_FREEZE.md`](../API_FREEZE.md) · [`../A11Y_MATRIX.md`](../A11Y_MATRIX.md) | **生成物，禁手改** |
| 逐组件 API 页 / 三态图索引 | `../components/` 下 20 页 + `index.md` + `showcase.md` | **生成物，禁手改** |
| 站点产品化层 | `../tools/` · `../en/` · `../community/` · `../assets/js/nova-data.js` | 生成物 + 手写 JS/CSS |
| 史料 / 历史档案 | 四稿 · 联合总纲 · 命名稿 · `../COMPONENTS.md`（历史稿） | 只归档 |
| 活状态 / 交接 | [`../index.md`](../index.md) · [`../SESSION_HANDOFF.md`](../SESSION_HANDOFF.md) · 仓库根 `CHANGELOG.md` · 双语 README | 手写，随批次更新 |

---

## 6. 分类的工程边界：物理层平铺，模块 URI 不拆

| 约束 | 出处 | 单一模块如何满足 |
|---|---|---|
| **CC-1 唯一组合上下文** | 组合宪法 1.0.0 §9 | 20 项共享同一 `NovaTheme` / `NovaMotion` 门面与槽位 alias 约定；拆模块会分裂组合上下文 |
| **无业务语义骨架** | 5 份封版法源零章 | `NovaAgent` / `NovaDE` / `NovaCopilot` / `NovaOrbit` / `NovaIncubator` 与基础壳同类：只托管布局，业务全由槽位注入；不存在「智能实体 ↔ 基础壳」的物理隔离需求 |
| **API 冻结零漂移** | 母法第 8 章 | 物理拍平不改 URI，144 类型签名逐成员零漂移（反推验证：归一化 `file` 路径后指纹精确还原旧值 `68b34a408489b6a8`）；现行指纹 `4f882374ad52262b` 仅因 `file` 溯源元数据变化，已发布 `import` 不受影响 |
| **依赖方向** | 组合宪法「依赖严格向下」 | 单一模块内由 `import Nova.Controls` / `Nova.Services` / `Nova.Design` 保证：**组合根只向下依赖基础模块，绝不反向**；原稿担心的「循环依赖」由 import 图约束，而非目录树 |
| **七标签适用边界** | `NovaIncubator_name.md` §8 | `@incubator` / `@components` 用于**孵化工程产出的应用代码**；组件库 QML 源码不使用，避免把配方语义污染进冻结公共面 |
| **天花板铁律** | 母法卷首 CARF | 「现有再优、稳步推进、逐个打磨」；物理层回归平铺、九类分类下沉文档台账，**不新建业务域体系、不改模块 URI、不动冻结公共面**，属受控实现级变更 |

> **仍未做的那一半**：把九类升格为**独立 `qmldir` 模块**（如 `module Nova.Prescient.Navigation`）会改变 144 类型的模块归属，属 **additive major 重签 + 全库回扫 + 新 RFC + 新法源 + 已发布兼容层** 的独立议题，**本次未做、待 CSA 单独拍板**。物理层已拍平、九类留在文档层台账，模块 URI 保持单一。

---

## 7. 维护纪律（新增 / 变更如何归类）

1. **新增组合根**：归入九类之一（§4），同步 ① 模块 README「三、完整契约」新增 `####` 契约段（生成器解析源）→ ② 本指南 §4 台账 → ③ QML **平铺放入 `Composite/LayoutShell/`** 并在 `qmldir` 以 `名字.qml` 导出 → ④ a11y 契约表 → ⑤ `gen_api_freeze.py` 重签（additive minor / major 按宪法第 8 章）→ ⑥ nav / 三态图 / 天花板台账 / 生成物重跑。
2. **分类口径变更**（增删类、调整归属）：必须走 **RFC**，并在本指南 §0 追加裁定记录；不得静默改写。
3. **事实源优先级**：`qmldir` > `api/nova-api-1.2.0.json` > QML 字面量 > 模块 README 契约 > 本指南台账 > 生成物。**生成物一律禁手改**（`docs/components/` / `docs/ai/` / `nova-data.js` / `COMPONENT_LIST.md` / `API_FREEZE.md` / `A11Y_MATRIX.md`）。
4. **史料只移不删**：四稿 / 联合总纲 / 命名稿保持原样；原稿建议见附录 A，标注「部分采纳 / 独立模块建议未采纳」，不圆场成全量落地。
5. **版本号与指纹**：本指南不持有版本锚点；一切以 `src/pyside_nova/__about__.py` + 冻结清单为准，避免多头事实源。

---

## 8. 封版声明

**本指南为 pyside-nova 1.2.0 组件与文档分类的现行实用入口，分类落地于台账 / 导航 / 概念映射三层，物理层拍平为根目录，模块 URI 与冻结公共面保持不变。**

- 现行分类：**九类 20 组合根** · **五模块 144 类型** · **五层概念体系 ↔ 五模块映射**
- 冻结面：**144 类型 · 指纹 `4f882374ad52262b` · 公共成员零漂移**（20 项 QML 物理拍平；`file` 溯源元数据变化导致指纹重签，反向归一化可精确还原 `68b34a408489b6a8`，模块归属与 144 个签名逐成员一致）
- 前身 `PRESCRIPT_CLASSIFY.md`：**更名重写、前提校正、目录分类诉求已采纳（按本库九类）、独立 `qmldir` 模块建议未采纳**（附录 A 存档）
- 发布边界：`commit / push / tag / PyPI / 站点上线` **一律归 CSA**

> **一「模」定编译，分类入文档；概念分层入文档，物理层归平铺，冻结面零漂移。**

---

## 附录 A · 原稿建议存档（未采纳 · 史料）

> 前身 `PRESCRIPT_CLASSIFY.md`（105 行）为对话式外部建议稿，核心主张是「按业务域物理重构 QML 目录」。经 §0 三条前提校正，原稿的**业务域目录树**与**独立 `qmldir` 模块**建议未采纳；九类物理子目录曾于 1.2.0 落地、12:05 又拍平为根目录（见 §1.1），分类诉求现以**文档层台账**承载。其原文存档如下供追溯，不代表本库现行结构。

**A.1 原稿拟议目录树（未采纳 · 现行结构见 §1.1，物理层平铺）**

```text
src/pyside_nova/qml/Nova/
├── Controls/  Design/  Services/                 # 现有三层
├── Prescient/                                   # 拟拆：预判布局壳层
│   ├── Navigation/   # NovaSidebar / NovaTopNavigation / NovaTabShell / NovaDrawerPanel
│   ├── Structures/   # NovaThreeColumn / NovaDualSide / NovaCardGrid / NovaModal / NovaBlankPage
│   └── Carriers/     # NovaDesktop / NovaMobile / NovaFlexLayout
├── Base/        # NovaChat（交互基座）
├── Entities/    # NovaCopilot / NovaAgent / NovaDE（智能实体）
├── Orbit/       # NovaOrbit（呈现层）
└── Incubator/   # NovaIncubator / NovaSetupWizard（孵化层）
```

**A.2 原稿三条工程建议与裁定**

| 原稿建议 | 裁定 | 依据 |
|---|---|---|
| 每个子目录配独立 `qmldir`（如 `module Nova.Prescient.Navigation`） | **未采纳** | 改 URI = 公共 API 变更，须 major 重签 RFC；分类现由文档层台账承载、物理层平铺，见 §1.1、§6 |
| 在 QML 文件头落实 `@incubator` 七标签 | **未采纳（适用边界错位）** | 七标签属孵化工程产物，组件库源码不套用；见 §0 误差 3、§6 |
| 「只允许高层级目录 import 低层级，禁止反向」 | **诉求已采纳，实现路径不同** | 本库由单一模块内的 `import Nova.Controls / Services / Design` 向下依赖保证，不依赖目录树；见 §6 |

**A.3 原稿一句话总结（存档）**

> 「用目录物理结构去强制映射逻辑架构分层，让任何一个新入职的工程师，只要看一眼 `qml/Nova/` 的文件夹结构，就能瞬间理解 Prescript 范式与 NovaIncubator 五层体系的宏伟设计。」

**本库答复（1.2.0 · 12:05 更新）**：该诉求现由 **§1 五模块表 + §2 五层映射表 + §4 九类台账 + 文档站按类导航**共同满足，物理层拍平为根目录；**分类已落在文档层，但不让目录树定义模块 URI**——编译分层属于模块层，概念分层属于文档层，二者不强行一一对应。
