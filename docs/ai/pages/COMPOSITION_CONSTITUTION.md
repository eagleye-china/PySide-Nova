# 组合组件宪法 — pyside-nova Layout Shell Constitution

> 本宪法是《架构宪法》（[CONSTITUTION.md](CONSTITUTION.md)，下称**母法**）的**子法**，
> 专属约束"组合组件（Layout Shell）"这一类公共类型。母法第 10 章 L1 布局系统、第 4 章槽机制、
> 第 11 章 a11y、第 12 章国际化与非功能、第 13 章 API 冻结是本宪法的最高法源；
> 本宪法只定义**组合组件特有的纪律**，令牌 / 目录 / 命名 / a11y / 冻结一律援引母法，
> 不另立标准、不新增术语门面。
>
> **母法权威版本声明（0.2.0 补）**：本宪法所在 `docs/` 目录下的
> [CONSTITUTION.md](CONSTITUTION.md) 是母法**唯一权威版**（含第 0~13 章）；
> 仓库根目录的 `CONSTITUTION.md` 是 0~10 章的历史副本（迭代记录止于 0.11.0），
> **不得作为法源援引**。凡本宪法提及"母法第 N 章"，一律指 `docs/CONSTITUTION.md` 的章节。
>
> 条款变更须在 CHANGELOG 同步，并在文末迭代记录表登记；与母法冲突时以母法为准。

## 第 0 章 宗旨与适用范围

1. **定位**：组合组件是立于母法 L1 基础布局（`NovaLayout` 四象限 + `NovaRow`/`NovaCol`/`NovaVisible`）
   之上的**无业务语义骨架**，把企业级桌面应用的布局范式、槽位契约、主题联动、边界容错
   预先沉淀为可复用公共类型，使使用者"填业务即交付"，同时保留全量定制能力。
2. **四性目标**：Solidity（契约稳定）、Robustness（边界不崩）、Aesthetics（令牌驱动的美学基线）、
   Prescience（预判高频痛点并内置默认方案）。四性是**设计目标**，不是"封版"标签——
   封版资格只由母法第 13 章的 API 冻结门禁授予（见第 8 章）。
3. **适用范围**：凡以 `Shell` 命名后缀、或由 ≥2 个已导出公共类型组合而成、提供固定槽位、
   无业务语义的根容器，均受本宪法约束。**多端根壳**（`NovaDesktop` / `NovaMobile` /
   `NovaFlexLayout`）虽无 `Shell` 后缀，但作为顶层场景化组合根容器，同样受本宪法全部条款约束，
   命名以 `docs/layout_shell/PrescientLayoutShell.md` 权威清单为准（0.2.0 明确）。
   单纯的基础控件（L2）、行为（L3）、服务（L4）不受本宪法约束。
4. **法源声明**：自本宪法颁布之日起，`docs/layout_shell/` 下历史文档中的
   "v1.0.0 FROZEN / 已封版"表述、日期流水头注释（母法第 2 章禁止）、
   以及 `Theme.*` / `NovaButton` / `NovaLabel` / `NovaAnimation` 等**不存在的 API 名**
   一律作废，不得作为开发或验收依据。其设计纪律（三层边界、槽位语义、组合优于继承、
   D-013）已被本宪法吸收并校正。

## 第 1 章 定义与分类（冻结条款）

1. **组合组件三要素**，缺一不称 Shell：
   - **组合性**：根容器由**两个及以上已导出公共类型**组合而成（如 `NovaLayout` + `NovaHeader`
     + `NovaDrawer` + `NovaPage`），不是单一控件的皮肤化包装。
   - **槽位化**：提供固定、语义化、单向数据流的内容注入点（第 4 章）；Shell 只托管布局位置，
     不持有业务状态。
   - **无业务语义**：不含业务菜单、路由表、数据模型、业务文案、项目专属图标；脱离任何业务工程
     在 Gallery 中可独立预览、独立调参、独立测试。
2. **语义分类**（分类是语义标签，**不是目录结构**，不得据此新建宪法外目录）：

   | 类别 | 骨架职责 | 可复用的真实公共类型 |
   |---|---|---|
   | 主导航壳（4） | 主导航 + 内容承载 | `NovaLayout` / `NovaHeader` / `NovaFooter` / `NovaDrawer` / `NovaTabs` |
   | 多栏工作台壳（3） | 多栏 / 对比 / 卡片网格 | `NovaRow` / `NovaCol` / `NovaSeparator` / `NovaTabPanels` / `NovaCard` |
   | 浮层容器壳（2） | 模态 / 临时面板 | `NovaDialogShell` / `NovaDrawer` / `NovaOverlayHost`（z 令牌，Services 单例） |
   | 极简独立页壳（2） | 向导 / 纯净单页 | `NovaRow` / `NovaCol` / `NovaStepper` / `NovaPage` / `NovaHeader` |
   | 多端根壳（3） | 桌面 / 移动 / 大屏顶层 | `NovaLayout` / `NovaRow` / `NovaCol` / `NovaScreen`（Services 单例）/ `NovaPlatform`（Services 单例） |

   五类合计 14 项，名称与落地顺序以 `docs/layout_shell/PrescientLayoutShell.md` 为权威清单；
   分类仅为语义标签，**不是目录结构**（0.2.0 与 14 项清单对齐）。

3. **与 L1 的关系**：`NovaLayout`（四象限自动归位 + push/overlay 双模 + 断点自动收起）是母法 L1
   的既定骨架；组合组件**站在 L1 之上做场景化组合**，禁止重写四象限排布逻辑、
   禁止复制 `NovaDrawer` 的断点收起实现（母法第 10 章第 1 条"不重复造轮子"）。

## 第 2 章 法源优先、目录与身份（冻结条款）

1. **目录纪律（0.3.0 修订）**：组合组件 `.qml` **必须**落在组合组件专属合法模块
   `Nova/Composite/LayoutShell/`（URI `Nova.Composite.LayoutShell`）——该目录是母法第 1 章
   0.3.0 补入的第五 QML 模块，不是宪法外目录。基础组件仍按归属入位四模块
   （`Nova/Services` / `Nova/Controls` / `Nova/Behaviors` / `Nova/Design`）。
   **禁止**新建 `Atoms/` / `Theme/` / `Layout/` 等其余宪法外目录。
   令牌门面唯一是 `NovaTheme`（`Services/NovaTheme.qml`），不新建 `Theme/` 目录。
   > 变更史：0.1.0~0.2.0 曾禁止一切 `Composite/` 目录并将其中未导出 QML 定性为黑户；
   > 0.3.0 经伙伴拍板将 `Composite/LayoutShell/` 升格为**合法专属模块**（有独立 qmldir、
   > 进冻结面），既满足物理目录诉求又不破坏封版纪律。其余 `Composite/` 子目录仍属禁止。
2. **合法身份（黑户禁令）**：组合组件必须在所属模块 `qmldir` 中导出，从而进入母法第 13 章的
   **API 冻结面**与 `docs/COMPONENT_LIST.md` 清单。位于 `src/` 却不进任何 `qmldir` 的
   `.qml` 是"黑户"：既不受冻结门禁保护，又会污染 `qmllint` 分类预算（见第 9 章坑位 7），
   **不得交付、不得自称已封版**。
3. **头注释**：严格遵从母法第 2 章——第 1 行是从 `src/` 起的完整子路径，第 2 行是组件定位说明，
   **禁止日期流水**（"星期一 2026-11-23" 式注释是从异项目混入的违规约定，见第 9 章坑位 1）。
   `qmldir` 注释只能用 `#`。
4. **导出文件名 = 类型名**，版本恒为 `1.0`（母法第 13 章第 5 条）。

## 第 3 章 三层边界与单向数据流（核心条款）

1. **三层职责**：

   | 层 | 成员 | 约束 |
   |---|---|---|
   | 基础组件层 | 现有 124 类型中的 Controls / Behaviors / Services / Design | 单一职责，不感知 Shell 布局、路由、业务 |
   | 组合组件层（本宪法） | 符合第 1 章三要素的 Shell 公共类型 | 只做布局、槽位、状态编排、信号转发；组合而非继承 |
   | 业务应用层 | 业务页面 / 逻辑 / 数据模型 | 消费 Shell、向槽位注入内容；只读公开 API，不碰私有实现 |

2. **允许实现**：固定布局结构与安全边距；展开/收起动画与过渡；自动绑定 `NovaTheme` 表面令牌与
   `isDark`；断点自适应（`NovaScreen`）与 RTL（`LayoutMirroring.enabled: NovaTheme.isRtl`）；
   入参合法性校验与兜底渲染；信号转发。
3. **严格禁止**：硬编码业务菜单 / 路由 / 页面；引入业务单例或数据模型；反向依赖业务工程代码；
   写死业务文案或项目专属图标；在 Shell 内新建私有原子控件或复制基础组件的样式（第 5 章）。
4. **单向数据流**：属性向下传配置，信号向上报事件；Shell **只 emit 不自写宿主状态**
   （受控契约，母法第 9/12/13 章一贯纪律）。跨层级不得直接修改内部控件状态。
5. **私有化**：内部控件 id 一律 `_` 前缀（如 `_drawer`）；API 最小化，不对外暴露内部控件 id。
   私有成员用 `_` 前缀后**不进冻结面**（母法第 13 章第 1 条），可自由重构。

## 第 4 章 槽位契约（强制条款）

1. **五个标准槽位**（按需提供、不冗余；语义统一以便跨 Shell 迁移业务页面）：

   | 槽位 | 语义 |
   |---|---|
   | `headerSlot` | 顶部区域：标题、全局操作、主题切换 |
   | `sidebarSlot` | 侧边导航：菜单、目录（业务菜单由应用层注入，Shell 不内置） |
   | `contentSlot` | **主内容区**：业务页面注入位置，核心槽位 |
   | `footerSlot` | 底部区域：状态栏、版本信息 |
   | `overlaySlot` | 浮层区域：弹窗、提示、加载遮罩（z 值取 `NovaTheme.z*` 令牌） |

2. **实现方式必须映射母法第 4 章的 QML 等价机制**，禁止自造"槽对象"：
   - 默认槽（default）：`default property alias content: <host>.data`
   - 命名槽：`property alias <slot>: <host>.<target>`（如 `headerSlot` 指向头部 Item 的 `data`）
   - 作用域槽：需要数据回传时用 `property Component xxxDelegate` + required 属性（数据类场景）
3. **槽位是纯布局托管点**：Shell 只决定槽位的位置、尺寸、显隐与断点行为，
   **不得**读写注入内容内部的状态、不得把业务状态存在槽位宿主里。
4. **层叠令牌**：`overlaySlot` 及任何弹层的 `z` 一律取 `NovaTheme.zSide` / `zFixedDrawer` /
   `zFullscreen` / `zTop` / `zMax` 等令牌，**禁止魔法数值**（母法第 5 章第 6 条）。

## 第 5 章 组合完整性（D-013 入宪，核心条款）

1. **完全基于已导出组件**：所有 Shell 必须由库内**已导出公共类型**组合实现；
   **禁止**在 Shell 内临时新建原子控件、复制基础组件的绘制样式、绕过 `NovaTheme` 令牌。
2. **前置门禁**：每个 Shell 开发前必须读取 `docs/COMPONENT_LIST.md`（生成器唯一权威来源），
   在其 README 中列出"依赖组件清单"（组件名 / 模块路径 / 用途）。
3. **缺失处理**：所需能力库内不存在时，**先补库组件并独立验收**（走母法第 8/13 章），
   Shell **不得**降级为手写临时控件——这是"黑户原子"和样式分叉的主要来源。
4. **可机检纪律**：新增 Shell 后 `qmllint` 必须 error 零容忍、warning 分类数不超过
   `tests/lint-baseline.json` 预算（母法第 13 章第 6 条）；靠"加一个未登记文件"抬高告警数
   视为门禁破坏，不得通过调整预算掩盖。
5. **组合优于继承**：优先组合既有类型，规避 QML 单继承的属性冲突与 FINAL 属性覆盖陷阱
   （母法第 3/5/12 章坑位纪律，如 `Item` FINAL 属性不可覆盖）。

## 第 6 章 令牌与视觉（强制条款）

1. **唯一令牌源**：`NovaTheme` 是唯一门面（母法第 5 章）；颜色 / 间距 / 圆角 / 字号 / 阴影 / 层叠
   一律取令牌，**禁止字面色值与像素硬编码**。**不存在 `Theme` 单例**，`Theme.*` 全部非法。
2. **本宪法可直接引用的真实令牌**（以 `NovaTheme.` 为前缀，取值见 [DESIGN_TOKENS.md](DESIGN_TOKENS.md)）：

   | 类别 | 真实令牌 |
   |---|---|
   | 表面色（随 `isDark` 切换） | `page` / `surface` / `surfaceAlt` / `outline` / `textColor` / `textMuted` |
   | 品牌与语义色 | `primary` / `secondary` / `accent` / `dark` / `positive` / `negative` / `info` / `warning` |
   | 间距 / 圆角 | `spacingS` / `spacingM` / `spacingL`；`radiusS` / `radiusM` / `radiusL` |
   | 层叠 z | `zSide` / `zMarginals` / `zFixedDrawer` / `zFullscreen` / `zMenu` / `zTop` / `zTooltip` / `zNotify` / `zMax` |
   | 阴影 / 字阶 | `shadowColor(level)` / `elevationLayers(level)`；`fontXS`…`fontXL` / `textStyle(name)` |
   | 模式 / 方向 | `isDark` / `setDark(v)` / `toggleDark()`；`isRtl` / `direction` |

   注：明暗状态是 `isDark`；`dark` 是 Quasar `$dark` 品牌色，二者不可混用。
3. **动效统一**：动画曲线与时长取 `NovaMotion`（`Design/NovaMotion.qml`），
   禁止在 Shell 内散落自定义 `Animation` 参数；不存在 `NovaAnimation` 类型。
4. **美学基线**：默认配置即具备安全边距、层级区分与精致观感；高级用户可通过公开属性 / 槽覆盖。

## 第 7 章 鲁棒性与非功能（门禁条款）

1. **边界容错**：窗口极小 / 最大化 / 全屏下布局不溢出、不丢元素；`undefined` / 空值 / 非法枚举 /
   非法尺寸入参自动回退安全默认值；禁止对同一属性多处重复赋值（Property value set multiple times）。
2. **动态内容**：槽内容动态增删须自动重排、无残留渲染、无泄漏；动态对象优先用 `Loader` / `Repeater`
   管理，并在 `Component.onDestruction` 释放定时器与动态对象（母法第 10 章 Sprint 坑位纪律）。
3. **明暗与 RTL**：主题切换样式平滑无残留；声明式容器用
   `LayoutMirroring.enabled: NovaTheme.isRtl`，逻辑侧 API 语义恒定（母法第 12 章第 4 条）。
4. **a11y**：组合容器根 Item 属 decorative——**禁止挂 `Accessible.*`**（屏读器噪声），
   源码带 `// a11y: decorative` 标记；内部交互子件（如 `NovaBtn`）沿用其自身 interactive 契约与
   `NovaFocusRing`，Shell 不得绕过（母法第 11 章第 2/3 条）。键盘可达即鼠标可达（Tab 流转、Esc 收起）。
5. **i18n**：用户可见字符串经 `NovaI18n.t()`，禁止硬编码于 Shell（母法第 12 章第 1 条）。
6. **性能与崩溃红线**：实例化 / 挂载 / HiDPI 矩阵遵从母法第 12 章第 5/6/7 条门禁；
   任何 SIGSEGV / exit 139 视为阻断级缺陷，禁止用重试 / 跳过掩盖。

## 第 8 章 交付与验收门禁（门禁条款）

1. **新增组合组件 = 新增公共类型**，必须走母法第 13 章完整变更流程：
   进 `qmldir` → a11y 契约登记 → `PARITY.md` 新增审计节 → 重签 API 冻结快照
   （`gen_api_freeze.py` 生成物，禁止手改）→ 重生成 `COMPONENT_LIST.md`（`gen_component_list.py`）。
2. **Gallery 门禁**：每个 Shell 必须在 `examples/gallery/` 有独立预览页与调参面板，
   可独立加载（母法第 8 章第 2 条）——这是"无业务语义"的可执行判据。
3. **测试门禁**：解析 + 实例化用例、槽用例、明暗主题用例、边界参数用例、
   Gallery 加载用例（母法第 8 章第 1 条）。
4. **交付前机检**：`python scripts/check_all.py --tier static` 必须全绿（三道静态门禁聚合入口）；
   涉及新 Shell 的交付追加 `--tier dynamic`（perf / visual smoke / soak smoke / hidpi）。
   任一红灯先按"工具/环境 vs 产品"定性，不得据假红灯判缺陷、不得据假绿灯放行。
5. **批量交付纪律（0.2.0 新颁）**：一次交付 N 个 Shell 时，先整批完成第 8 章第 1 条的全部
   登记动作（统一进 `qmldir` → 整批登记 a11y `decorative` → 整批补 `PARITY.md` 审计节 →
   单次重签 API 冻结 → 单次重生成 `COMPONENT_LIST.md`），再整批跑第 4 条门禁；
   **禁止逐个重签**（会产生 N 个中间指纹、污染签署件历史）。整批仍须逐项满足第 8 章第 5 条清单，
   任一项不合格则整批不合规。
6. **生成物保护**：`API_FREEZE.md` / `api/nova-api-*.json` / `A11Y_MATRIX.md` /
   `COMPONENT_LIST.md` / `docs/ai/api/*.json` 均为生成器产物，**只改生成器或重跑生成器，
   禁止手改**（母法第 13 章第 2 条）；本宪法自身条款变更才算文档改动，须同步 CHANGELOG
   与本文件迭代记录表。

7. **准入验收清单**（逐项满足方可标"合规"；"封版"资格另由母法第 13 章冻结门禁授予）：

   - [ ] 符合第 1 章三要素；进 `Composite/LayoutShell` qmldir、入 `COMPONENT_LIST.md`、无黑户文件
   - [ ] 头注释两行合规、无日期流水；导出文件名 = 类型名、版本 1.0
   - [ ] README 含依赖组件清单（组件名/路径/用途），全部为已导出公共类型
   - [ ] 槽位只用第 4 章 alias 机制；overlay 层叠取 `NovaTheme.z*`，无魔法 z
   - [ ] 无 Shell 内私有原子实现、无复制样式、无硬编码令牌；无 `Theme.*` 等虚构 API
   - [ ] 单向数据流 / 受控契约（只 emit 不自写宿主状态）；内部控件 `_` 前缀
   - [ ] 明暗切换 + RTL + 断点自适应 + 窗口极值 + 非法入参兜底实测通过
   - [ ] 容器根标 `// a11y: decorative`；交互子件沿用 interactive 契约与焦点环
   - [ ] Gallery 独立预览页 + 调参面板；解析/实例化/槽/主题/边界测试全绿
   - [ ] `check_all.py --tier static` 全绿；qmllint error 0、warning 未超预算

## 第 9 章 反模式坑位表（血泪条款，勿回退）

| # | 反模式（历史真实缺陷） | 正确做法（本宪法条款） |
|---|---|---|
| 1 | QML 头注释第 2 行写"星期一 2026-11-23"日期流水（异项目 D-008 约定混入） | 第 2 章第 3 条：两行注释，第 2 行写定位说明，**禁止日期流水**（母法第 2 章） |
| 2 | 引用 `Theme.background` / `sidebarBackground` / `spacingSmall` 等虚构令牌 | 第 6 章：唯一门面 `NovaTheme`，真实令牌白名单；不存在 `Theme` 单例 |
| 3 | 引用 `NovaButton` / `NovaLabel` / `NovaAnimation` 等不存在的类型 | 第 6 章：真名 `NovaBtn` / `NovaText` / `NovaMotion`；以 `COMPONENT_LIST.md` 为准 |
| 4 | 给 `NovaRow` / `NovaDrawer` 写 `color` / `border` / `border.bottom`（Item 级基元无此属性） | 第 3 章第 1 条：只用公共类型已声明的属性；基类冲突用 `tint`（母法第 3 章） |
| 5 | `sidebarCollapsed !== _drawer.width`——bool 与 real 比较，防抖恒真/恒假 | 第 3 章第 2/4 条：状态比较类型一致；受控契约用显式状态位，不拿几何量当布尔 |
| 6 | `z: 999` 硬编码层级 | 第 4 章第 4 条 / 第 6 章：取 `NovaTheme.z*` 令牌（母法第 5 章第 6 条） |
| 7 | 组合组件放任意目录却不进 qmldir（黑户），污染 qmllint 预算却不进冻结面；或在 `Composite/` 下**另建**非 `LayoutShell` 子目录 | 第 2 章第 1/2 条（0.3.0）：唯一合法组合目录是 `Composite/LayoutShell/` 且必须有独立 qmldir；其余 `Composite/` 子目录禁止、黑户不得交付 |
| 8 | rc1 阶段自称 "v1.0.0 FROZEN / 已封版"，绕过冻结门禁 | 第 0 章第 2 条 / 第 8 章第 1 条：封版资格只由母法第 13 章门禁授予 |
| 9 | 把根目录 0~10 章旧副本当母法，误判"第 13 章 API 冻结不存在" | 宪法抬头权威版本声明 / 第 8 章第 6 条：唯一权威母法是 `docs/CONSTITUTION.md`（0~13 章） |
| 10 | 一次交付 N 个 Shell 时逐个重签冻结清单，产生 N 个中间指纹污染签署件 | 第 8 章第 5 条：整批登记、单次重签、整批验收 |

## 迭代记录表（条款变更必须登记）

| 版本 | 日期 | 条款变更 |
|---|---|---|
| 0.1.0 | 2026-11-24 | 首颁：以母法为法源确立 9 章组合组件纪律——三要素定义 / 四模块目录与黑户禁令 / 三层边界与单向数据流 / 五标准槽位 alias 契约 / D-013 组合完整性 / 真实令牌白名单 / 鲁棒性与 a11y / 准入门禁清单 / 8 条反模式坑位；明确 `docs/layout_shell/` 历史文档虚构 API 与"FROZEN"表述作废，吸收其三层边界·槽位语义·组合优于继承精华并校正 |
| 0.2.0 | 2026-11-25 | **14 项一次交付适配修订**：① 抬头新增母法权威版本声明（`docs/CONSTITUTION.md` 0~13 章为唯一法源，根副本 0~10 章不得援引）+ 法源补第 11/12 章；② 第 0 章第 3 条明确 3 个多端根壳（`NovaDesktop`/`NovaMobile`/`NovaFlexLayout`）无 Shell 后缀同样受约束；③ 第 1 章语义分类由 3 类扩为 5 类对齐 14 项权威清单（逐类型已核实为真实导出，无虚构 API）；④ 第 8 章新颁批量交付纪律（整批登记、单次重签、整批验收）与生成物保护条款；⑤ 坑位表补 9/10 条；同步 CHANGELOG。为 14 项一次封版提供无歧义的上位规则。 |
| 0.3.0 | 2026-11-25 | **组合组件专属模块升格（伙伴拍板）**：应伙伴要求将 14 项从 `Nova/Controls/` 物理迁至 `Nova/Composite/LayoutShell/`。第 2 章第 1 条由"禁止一切 Composite/"改为"该目录为合法专属模块（URI `Nova.Composite.LayoutShell`），其余 Composite 子目录仍禁止"；坑位 7 同步改写；第 8 章准入清单改指新 qmldir；母法第 1 章补第五模块 URI。14 项类型名不变、只改模块归属，整批单次重签冻结面，保持封版纪律不破。 |
