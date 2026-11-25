# 组合组件宪法 — pyside-nova Layout Shell Constitution

> 版本：0.8.0（2026-11-25，旗舰封版规约落地：动效全库令牌化 + 键盘可达 + 令牌白名单补全 + 槽位口径校准 + 模块级交付物）
>
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
3. **适用范围（0.4.0 修订）**：组合组件由**模块归属 + 三要素**界定，**不再以 `Shell` 后缀为唯一标识**。
   凡由 ≥2 个已导出公共类型组合而成、提供固定槽位、无业务语义的根容器，均受本宪法约束——
   包括已去后缀的 `Nova*` 根容器与无后缀的 `NovaDesktop` / `NovaMobile` / `NovaFlexLayout` /
   `NovaChat`。命名以 `docs/layout_shell/PrescientLayoutShell.md` 权威清单为准。
   单纯的基础控件（L2）、行为（L3）、服务（L4）不受本宪法约束。
4. **法源声明**：自本宪法颁布之日起，`docs/layout_shell/` 下历史文档中的
   "v1.0.0 FROZEN / 已封版"表述、日期流水头注释（母法第 2 章禁止）、
   以及 `Theme.*` / `NovaButton` / `NovaLabel` / `NovaAnimation` 等**不存在的 API 名**
   一律作废，不得作为开发或验收依据。其设计纪律（三层边界、槽位语义、组合优于继承、
   D-013）已被本宪法吸收并校正。

## 第 1 章 定义与分类（冻结条款）

1. **组合组件三要素**，缺一不称组合根容器：
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
   | AI 对话主窗口（1） | 导航轨 + 会话列 + 对话区 + 输入区 + 详情栏 | `NovaHeader` / `NovaPage` / `NovaFooter` / `NovaSeparator` / `NovaChatMessage`（气泡由槽位注入） |

   六类合计 15 项（0.6.0：能去则去 + `NovaTabShell` 保留 + `NovaTopNavigation` 全称 + `NovaSetupWizard` 正名 + `NovaChat`），名称与落地顺序以
   `docs/layout_shell/PrescientLayoutShell.md` 为权威清单；
   分类仅为语义标签，**不是目录结构**。

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
5. **命名纪律（0.6.0 修订）**：公共类型名遵循**"能去则去、必要则留；缩写一律全称自解释"**——
   模块 URI `Nova.Composite.LayoutShell` 已表达"组合壳"身份，故**优先不带 `Shell` 后缀**；
   但遇到以下任一情形应调整（0.4.0"一律去后缀"与 0.5.0"缩写可维持"均已被本版取代，坑位 11）：
   - 去后缀会与 Controls 已有类型同名或造成语义混淆——`NovaTabShell` 去后缀与
     Controls 的 `NovaTab` 同名，跨模块重名门禁会拦截，故**保留 `NovaTabShell`**；
   - 缩写一律**全称自解释**（0.6.0 伙伴拍板）：`NovaTopNav` 扩写为
     `NovaTopNavigation`，不保留 `Nav` 缩写；旗舰公共 API 以自解释优先于字数精简；
   - 用途收窄的类型以**语义前缀正名**：`NovaWizard` 实为安装 / 新建工程 / 初始化配置
     专用，0.5.0 正名为 `NovaSetupWizard`。

   任何改名须先过冻结门禁的跨模块重名检查，属破坏性 API 变更，须在 GA 前完成并**整批单次重签**冻结面。

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

1. **核心槽位语义**（按需提供、不冗余；语义统一以便跨 Shell 迁移业务页面）：

   | 槽位 | 语义 |
   |---|---|
   | `headerSlot` | 顶部区域：标题、全局操作、主题切换 |
   | `sidebarSlot` | 侧边导航：菜单、目录（业务菜单由应用层注入，Shell 不内置） |
   | `contentSlot` | **主内容区**：业务页面注入位置，最常见的核心槽位 |
   | `footerSlot` | 底部区域：状态栏、版本信息 |
   | `overlaySlot` | 浮层区域：弹窗、提示、加载遮罩（z 值取 `NovaTheme.z*` 令牌） |

   > **0.8.0 口径校准**：统一的是**槽位机制（`property alias`）、单向数据流与纯布局托管语义**，
   > **不是固定五个槽位名**。中心内容槽随骨架范式**场景化命名**（`gridSlot` / `pageSlot` /
   > `leftSlot`+`rightSlot` / `treeSlot`+`listSlot`+`detailSlot` / `navSlot`+`conversationSlot`+
   > `composerSlot`+`detailSlot`），`overlaySlot` 亦非必需（`NovaModal` / `NovaDrawerPanel` 自身即浮层）。
   > 故早期草案"固定五槽、`contentSlot` 必需"的口径**作废**；15 项真实槽位权威表见
   > `src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md` 与《封版规范 v2.0.0》§4.2。

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
   | 表面色（随 `isDark` 切换） | `page` / `surface` / `surfaceAlt` / `outline` / **`outlineStrong`** / `textColor` / `textMuted` / **`textOnPrimary`**（0.8.0 补全：`outlineStrong` 由 `NovaA11y.aaText()` 派生，`textOnPrimary` 为品牌色上的反色文本，二者均为 `NovaTheme.qml` 真实导出属性） |
   | 品牌与语义色 | `primary` / `secondary` / `accent` / `dark` / `positive` / `negative` / `info` / `warning` |
   | 间距 / 圆角 | `spacingS` / `spacingM` / `spacingL`；`radiusS` / `radiusM` / `radiusL` |
   | 层叠 z | `zSide` / `zMarginals` / `zFixedDrawer` / `zFullscreen` / `zMenu` / `zTop` / `zTooltip` / `zNotify` / `zMax` |
   | 阴影 / 字阶 | `shadowColor(level)` / `elevationLayers(level)`；`fontXS`…`fontXL` / `textStyle(name)` |
   | 模式 / 方向 | `isDark` / `setDark(v)` / `toggleDark()`；`isRtl` / `direction` |

   注：明暗状态是 `isDark`；`dark` 是 Quasar `$dark` 品牌色，二者不可混用。
3. **动效统一**：动画曲线与时长取 `NovaMotion`（`Design/NovaMotion.qml`），
   禁止在 Shell 内散落自定义 `Animation` 参数；不存在 `NovaAnimation` 类型。
   **0.8.0 强制落地写法**：`import Nova.Design` 后一律
   `duration: NovaMotion.duration(NovaMotion.transitionDuration)` 与
   `easing.type: NovaMotion.easingStandard`（库内 `NovaTransition.qml` 既定惯例）。
   15 项中原有 8 处 `duration: 200/220/240; Easing.OutCubic` 硬编码已全部令牌化——
   由此全库节奏统一、`reducedMotion` 无障碍短路与 `speedFactor` 全库调速自动生效。
   **禁止**回退为字面时长（坑位 16）。
4. **美学基线**：默认配置即具备安全边距、层级区分与精致观感；高级用户可通过公开属性 / 槽覆盖。
5. **身份差异化（0.7.0 强制条款）**：每个组合根容器**必须有独有结构性身份元素**，
   严禁 15 项共用同一"平铺背景 + Header/Page/Footer + 宽度动画"模板仅换槽位名（0.4.0~0.6.0
   的历史病灶）。身份元素须是**纯装饰结构**（色带 / 渐变轨 / 胶囊 / 网格底纹 / 圆点时间轴 /
   窗口控制点 / 灵动岛 / home indicator / 面板色条 / 中缝 grip 等），**不含业务语义与文案**，
   且必须是 `_` 私有的内部实现（不进冻结面——公共 API 签名保持不变，指纹不变）。
   身份元素若被业务槽位注入的内容遮挡，须用层叠令牌提级（如时间轴 `z: 2`、面板色条
   `z: NovaTheme.zMarginals`），确保 Gallery 默认视图即可辨识。差异化身份一览见
   `docs/layout_shell/PrescientLayoutShell.md` 的"身份元素"列。
6. **多轨组件按轨分治（0.7.1 深化）**：含 ≥2 条并排轨道的组件（如 `NovaChat` 的
   导航轨 / 会话列 / 对话区 / 输入区 / 详情栏 / 浮层），**"轨多"不等于"有身份"**——
   每条轨道须有**各自独占且互不重复**的前景结构签名，禁止各轨共用同一
   "`surfaceAlt` 平铺方块 + `NovaSeparator` + 220ms 宽度动画"模板（坑位 14）。
   轨道签名只占边缘 / 角标 / 列首列尾，**中央内容区完全留给业务注入**；
   并须在**浅色与深色主题、实心业务注入**下都保持清晰对比（坑位 15）。
7. **浮层槽透明契约（0.7.1）**：`overlaySlot` 为 `zFixedDrawer` 顶层，业务注入必须是
   透明 / 空 `Item`；验证脚本若向其注入铺满的不透明块会盖住整个组件（验收口径，非组件缺陷）。

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
   **0.8.0 键盘可达清单**：含可收起面板 / 浮层的 Shell 必须内置 Esc 收起 / 关闭意图——
   `NovaSidebar` / `NovaDualSide` / `NovaTopNavigation` / `NovaChat`（多轨）/ `NovaModal` /
   `NovaDrawerPanel` / `NovaDesktop`，移动根壳 `NovaMobile` 内置 Back。
   一律 `focus: true` + `Keys.onEscapePressed` **只 emit 已有信号**（如 `sidebarToggled(true)`），
   **不自写宿主状态、不新增公共 API**（受控契约，第 3 章第 4 条）；Shell 不吞键、不阻断 Tab 焦点链。
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
   - [ ] 模块级 `Composite/LayoutShell/README.md` 含 15 项属性 / 信号 / 槽位表 + 依赖组件清单
         （组件名/路径/用途，全部为已导出公共类型）+ 最小示例（0.8.0 交付物落地）
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
| 11 | 类型名机械去 `Shell` 撞 Controls 已有类型（如 `NovaTabShell`→`NovaTab`），或为去后缀而造出生硬别名（`NovaTabWorkspace`）| 第 2 章第 5 条（0.5.0）：能去则去、必要则留——撞名时**保留 `NovaTabShell`** 而非生造别名；任何改名先过跨模块重名检查 |
| 12 | 把 AI 对话主窗口当成业务页面写死会话列表 / 提示词（黑户业务语义） | 第 1 章第 1 条：六槽全由业务注入，Shell 只托管布局；气泡复用 `NovaChatMessage` |
| 13 | 15 项组合组件共用同一"平铺背景 + Header/Page/Footer + 宽度动画"模板，仅换槽位名——打开像同一张脸（0.4.0~0.6.0 历史病灶，伙伴 0.7.0 点名纠正） | 第 6 章第 5 条（0.7.0）：每项须有 `_` 私有结构性身份元素（纯装饰、零业务语义），层叠提级确保 Gallery 可见；公共 API 不变、指纹不变 |
| 14 | 多轨组件误把"轨数多"当差异化——`NovaChat` 6 轨其实各轨仍是同一 `surfaceAlt` 方块 + `NovaSeparator` + 220ms 宽度动画，0.7.0 时被当作"标杆"漏改（伙伴 0.7.1 点名） | 第 6 章第 6 条（0.7.1）：每条轨须有独占前景签名（边缘 / 角标 / 列首列尾），中央全部留给业务注入；逐轨重渲染验收 |
| 15 | 品牌装饰用低 opacity 半透明 + 品牌色与业务注入色接近时，在实心浓色注入下对比度骤降、装饰"发虚"消失；或用 `Text` 字体符号做图标，offscreen / 缺字体环境渲染成豆腐块 | 第 6 章第 6 条：装饰实心度 ≥0.85、品牌色与中性底错开；图标一律纯几何（Rectangle / rotation 组合），零字体依赖；验收须覆盖浅色 + 深色主题 |
| 16 | 在 Shell 内散落 `duration: 200/220/240; easing.type: Easing.OutCubic` 硬编码动画，全库节奏割裂、`reducedMotion` 与 `speedFactor` 形同虚设（0.8.0 体检发现 8 处） | 第 6 章第 3 条：`import Nova.Design` + `NovaMotion.duration(NovaMotion.transitionDuration)` / `NovaMotion.easingStandard`；全库单一节奏源 |
| 17 | 把 `docs/white_paper/` 早期草案（旧 `Nova*Shell` 名、`Theme.*` / `NovaLabel` 虚构 API、"固定五槽 / contentSlot 必需"、"11 项规划中"、"每组件独立子目录 + 独立 qmldir"、Root Shell "不得宣称已封版"）当现行规范援引 | 第 0 章第 4 条 / 第 2 章 / 第 4 章：唯一法源是本宪法 + 母法，成熟度以 `COMPONENT_LIST.md` 为准；白皮书与封版规范 v2.0.0 已按 1.0.0 GA 校准，草案口径一律作废 |

## 迭代记录表（条款变更必须登记）

| 版本 | 日期 | 条款变更 |
|---|---|---|
| 0.1.0 | 2026-11-24 | 首颁：以母法为法源确立 9 章组合组件纪律——三要素定义 / 四模块目录与黑户禁令 / 三层边界与单向数据流 / 五标准槽位 alias 契约 / D-013 组合完整性 / 真实令牌白名单 / 鲁棒性与 a11y / 准入门禁清单 / 8 条反模式坑位；明确 `docs/layout_shell/` 历史文档虚构 API 与"FROZEN"表述作废，吸收其三层边界·槽位语义·组合优于继承精华并校正 |
| 0.2.0 | 2026-11-25 | **14 项一次交付适配修订**：① 抬头新增母法权威版本声明（`docs/CONSTITUTION.md` 0~13 章为唯一法源，根副本 0~10 章不得援引）+ 法源补第 11/12 章；② 第 0 章第 3 条明确 3 个多端根壳（`NovaDesktop`/`NovaMobile`/`NovaFlexLayout`）无 Shell 后缀同样受约束；③ 第 1 章语义分类由 3 类扩为 5 类对齐 14 项权威清单（逐类型已核实为真实导出，无虚构 API）；④ 第 8 章新颁批量交付纪律（整批登记、单次重签、整批验收）与生成物保护条款；⑤ 坑位表补 9/10 条；同步 CHANGELOG。为 14 项一次封版提供无歧义的上位规则。 |
| 0.3.0 | 2026-11-25 | **组合组件专属模块升格（伙伴拍板）**：应伙伴要求将 14 项从 `Nova/Controls/` 物理迁至 `Nova/Composite/LayoutShell/`。第 2 章第 1 条由"禁止一切 Composite/"改为"该目录为合法专属模块（URI `Nova.Composite.LayoutShell`），其余 Composite 子目录仍禁止"；坑位 7 同步改写；第 8 章准入清单改指新 qmldir；母法第 1 章补第五模块 URI。14 项类型名不变、只改模块归属，整批单次重签冻结面，保持封版纪律不破。 |
| 0.4.0 | 2026-11-25 | **1.0 GA 命名定稿 + NovaChat 入宪（伙伴拍板）**：① 去 `Shell` 后缀（11 项改 10 项，`NovaTabShell` 因跨模块重名改 `NovaTabWorkspace`），第 0 章适用范围改以模块+三要素界定、第 2 章新颁命名纪律、坑位表补 11/12；② 新增 `NovaChat` AI 对话主窗口（第 6 类，六槽对标 WorkBuddy 桌面端主窗口，气泡复用 `NovaChatMessage`）；③ 六类合计 15 项，一次重签冻结面（138→139 类型，指纹 `2d7f173b8f13b123`），包版本 1.0.0rc1→1.0.0 正式发 PyPI。 |
| 0.5.0 | 2026-11-25 | **语义正名定稿（伙伴拍板）**：① 0.4.0 的"一律去后缀"过严——`NovaTabWorkspace` 改回 `NovaTabShell`（跨模块重名时保留 `Shell` 而非生造别名）；② `NovaTopNav` 评估后维持不扩写为 `NovaTopNavigation`（`Nav` 为 UI 领域通用缩写，与 `NovaSidebar` / `NovaDualSide` 粒度一致）；③ `NovaWizard` 正名为 `NovaSetupWizard`（明确安装 / 新建工程 / 初始化配置用途）。第 2 章第 5 条改为"能去则去、必要则留"三情形、坑位 11 同步；15 项总数不变，整批单次重签冻结面。 |
| 0.6.0 | 2026-11-25 | **缩写全称化（伙伴拍板）**：`NovaTopNav` → **`NovaTopNavigation`**，0.5.0 的"缩写可维持"结论被推翻——旗舰公共 API 以自解释优先于字数精简。第 2 章第 5 条命名纪律改写、演示目录 `top_nav/`→`top_navigation/`、Gallery / a11y / 测试 / 权威清单 / PARITY 同步；15 项总数不变，整批单次重签冻结面。 |
| 0.7.1 | 2026-11-25 | **NovaChat 多轨按轨分治（伙伴点名："NovaChat 那套多轨结构也按这个思路重构一下"）**：0.7.0 把 `NovaChat` 当作"多轨标杆"漏改，实则 6 轨各自仍是同一 `surfaceAlt` 方块 + `NovaSeparator` + 220ms 宽度动画。本次给每条轨注入独占前景签名——顶层三段品牌发丝线 / 导航轨（渐变徽记 + 三级激活图标位 + 账户锚 + 缘轨）/ 会话栈（搜索胶囊 + 激活竖条 + 新建圆钮）/ AI 画布（四角取景框）/ 输入区（浮起胶囊 + 附加点 + 纯几何发送箭头）/ 详情栏（分段 tab + 缘轨），全为 `_` 私有纯几何装饰、零业务语义、零字体依赖；公共 API 逐字不变、指纹 `bfd3d938a2fab7be` 不变（patch）。第 6 章新增第 6 条（多轨按轨分治）、第 7 条（浮层槽透明契约），坑位表补 14/15（轨多≠有身份 / 半透明装饰对比度与字体符号豆腐块）。浅色 + 深色主题真实注入渲染验收、15 格对比拼图与 `docs/screenshots/chat_identity_audit*.png` 同步更新；静态门禁 3/3、专项 48/48、16/16 无头加载、15 项 qmllint 0 告警。 |
| 0.7.0 | 2026-11-25 | **身份差异化强制条款（伙伴点名纠正："除 NovaChat 外基本都一个面孔"）**：15 项组合根容器逐项重塑独有结构性身份元素——Sidebar 品牌渐变轨 + 浮起侧栏卡 / TopNavigation 胶囊导航台 + 悬浮下拉卡 / DualSide 中央画布点阵 + 双侧浮起栏 / TabShell 材质标签栏 + 下划线指示 / ThreeColumn 三级深度色阶 + 拖拽 grip / Compare 中缝圆形调节柄 + A/B 色条 / CardGrid 工具条胶囊 + Flow 网格 / Modal 顶部三色条 + catcher + 浮起阴影 / DrawerPanel 侧缘渐变轨 + grabber / SetupWizard 三态步骤时间轴 / BlankPage 居中阅读栏 / Desktop 窗口控制点 + 分层栏 / Mobile 灵动岛 + home indicator / FlexLayout 三色面板网格 / Chat 多轨标杆。第 6 章第 5 条立强制条款、坑位表补 13：**身份元素全为 `_` 私有纯装饰、零业务语义、公共 API 签名逐字不变、指纹 `bfd3d938a2fab7be` 不变**（属 patch 实现变更，无需重签，恰证 Solidity 契约稳定与 Aesthetics 可兼得）。渲染审计 15/15 出图、静态门禁 3/3、专项 48/48、Gallery+演示 16/16 无头加载。 |
| 0.8.0 | 2026-11-25 | **旗舰封版规约落地（伙伴："认真读 white_paper 三篇，汲取营养融入 README；优化完善另外两篇为企业级旗舰封版，为咱们所用，再次打磨重构 15 项"）**：① 第 4 章第 1 条槽位口径校准——统一的是机制与语义而非固定五槽，中心内容槽按骨架场景化命名、`overlaySlot` 非必需，草案"contentSlot 必需"作废；② 第 6 章第 2 条令牌白名单补 `outlineStrong` / `textOnPrimary` 真实导出属性；③ 第 6 章第 3 条动效令牌强制落地——15 项中 8 处 `duration: 200/220/240` 硬编码全部改为 `NovaMotion.duration()` + `easingStandard`（`import Nova.Design`），全库节奏统一 + `reducedMotion` 无障碍短路 + `speedFactor` 调速生效；④ 第 7 章第 4 条补键盘可达清单——Sidebar / DualSide / TopNavigation / Chat 新增 `focus: true` + `Keys.onEscapePressed`（只 emit 已有信号、不新增 API、不自写宿主状态），与既有 Modal / Drawer / Desktop / Mobile 一致；⑤ 第 8 章准入清单补模块级 `Composite/LayoutShell/README.md` 交付物（15 项契约 + 依赖组件清单 + 最小示例），并实测 README 快速上手示例可实例化；⑥ 坑位表补 16（散落动画参数）/ 17（援引早期草案口径）；⑦ 工程细节打磨：`NovaDesktop.toolbarSlot` 改为独立 `_toolbarHost` 宿主隔离 + 装饰 `zMarginals` 提级、`NovaFlexLayout` 删未用 `_bandColor`、`NovaTabShell` 校准虚构 `activeIndex` 注释。**全部为 `_` 私有 / 注释 / 内部实现变更，公共 API 签名逐字不变、指纹 `bfd3d938a2fab7be` 不变**（patch 无需重签）。同步：三篇 `docs/white_paper/` 升级 v2.0.0 企业级旗舰封版（消除旧命名 / 虚构 API / 规划中口径、补法源与封版资格声明、15 项真实槽位权威表）、README 双版汲取营销稿营养并校准 1.0.0 GA 真实现状、CHANGELOG / 权威清单 / 账本同步。验收：静态 3/3、专项 48/48、31/31 无头实例化、qmllint 0 error。发布边界归伙伴。 |
