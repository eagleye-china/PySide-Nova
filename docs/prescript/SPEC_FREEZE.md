---

# Prescient Layout Shell · 封版规范

> **PySide6-Nova 1.0.0 GA 旗舰版技术执行红线**

| 项目 | 内容 |
| :--- | :--- |
| **文档版本** | **v2.1.0**（Flagship GA · 组合态一致性契约 CC） |
| **文档状态** | 🟢 封版（FROZEN，**记录性**）—— 见下方「法源与封版资格」声明 |
| **发布日期** | 2026-11-25 |
| **归属** | PySide6-Nova 旗舰版组件库 **1.0.0 GA** |
| **适用范围** | 第五 QML 模块 `Nova.Composite.LayoutShell` 下 **15 项**组合根容器（含 3 项 App Root Shell 与 1 项 AI 对话主窗口） |
| **配套文档** | 《PySide6-Nova 旗舰组件库白皮书》、《docs/COMPOSITION_CONSTITUTION.md》组合组件宪法、`docs/COMPONENT_LIST.md` 组件索引、模块级 `README.md` |
| **文档性质** | 技术执行红线 · 封版门禁 · 验收依据 |
| **变更策略** | PATCH 修文字 / MINOR 增可选要求 / MAJOR 改封版口径或四性标准；破坏性变更须走版本评审 |
| **事实源优先级** | 组件成熟度与 API 以 `docs/COMPONENT_LIST.md` + `api/nova-api-1.0.0.json` 为准；本规范与白皮书冲突时以本规范技术红线为准；二者与宪法冲突时**一律以宪法为准** |

> **法源与封版资格声明（v2.0.0 首要校准）**
> 1. 本规范是 **子法级执行文档**，服从 `docs/CONSTITUTION.md`（架构宪法，母法，0~13 章）与
>    `docs/COMPOSITION_CONSTITUTION.md`（组合组件宪法）。**本规范不新立法、不新增术语门面、
>    不另立令牌 / 目录 / 命名标准**，一律援引宪法条款。
> 2. **封版资格只由母法第 13 章的 API 冻结门禁授予**（`scripts/check_all.py` 聚合），不是由文档
>    自称 "FROZEN" 获得。本规范的 FROZEN 标记是**对已通过门禁这一事实的记录**：
>    139 个公共类型零漂移，指纹 `bfd3d938a2fab7be`。
> 3. v1.0.0 草案中的 `Nova*Shell` 旧命名、`Theme.*` / `NovaLabel` / `NovaAnimation` 等虚构 API、
>    "11 个布局壳 / 仅 1 个平铺文件 / 12 项规划中"、"每组件独立子目录 + 独立 qmldir"、
>    "Root Shell 不得对外宣称已封版" 等口径，**均已作废**，不得作为开发或验收依据。
>    本版按 1.0.0 GA 仓库实际交付逐项校正。

---

## 目录

1. [定位与定义](#一定位与定义)
2. [旗舰四性验收标准](#二旗舰四性验收标准)
3. [分层边界（封版红线）](#三分层边界封版红线)
4. [槽位契约](#四槽位契约)
5. [目录结构与仓库现状映射](#五目录结构与仓库现状映射)
6. [QML 编码强制规范](#六qml-编码强制规范)
7. [组合完整性（D-013 入宪口径）](#七组合完整性d-013-入宪口径)
8. [封版准入验收清单](#八封版准入验收清单)
9. [入库交付物清单](#九入库交付物清单)
10. [版本迭代与变更流程](#十版本迭代与变更流程)
11. [最小使用示例](#十一最小使用示例)
12. [App Root Shell 与 AI 主窗口附加要求](#十二app-root-shell-与-ai-主窗口附加要求)
13. [文档治理与变更记录](#十三文档治理与变更记录)
14. [附录：术语表](#附录术语表)

---

## 一、定位与定义

**Layout Shell（组合根容器 / 布局壳）** 是无业务语义的复合根容器：由**两个及以上已导出公共类型**
按固定美学与工程约束组合而成，内置语义化槽位、默认布局比例、安全边距、`NovaTheme` 令牌联动、
`NovaMotion` 动效参数与边界兜底。

使用者无需从零搭建页面结构，仅向预留槽位注入业务页面与自定义控件，即可生成符合企业级审美、
多场景兼容的完整应用界面。

### 1.1 三要素（缺一不称组合根容器）

| 要素 | 判据 |
|---|---|
| **组合性** | 由 ≥2 个已导出公共类型组合（如 `NovaHeader` + `NovaPage` + `NovaFooter` + `NovaSeparator`），不是单一控件皮肤化包装 |
| **槽位化** | 提供固定、语义化、单向数据流的内容注入点；Shell 只托管布局位置，不持有业务状态 |
| **无业务语义** | 不含业务菜单 / 路由 / 数据模型 / 文案 / 项目专属图标；脱离任何业务工程，在 Gallery 可独立预览、独立调参、独立测试 |

### 1.2 核心边界

- Shell 本身是**标准 Nova 公共类型**：须在 `qmldir` 导出、进 API 冻结面、进 `COMPONENT_LIST.md`、
  可在 Gallery 预览、可独立调参、可单元测试、可版本管控；
- Shell 不绑定任何业务逻辑，只提供稳定、好看、鲁棒的应用骨架；
- Shell **不是业务框架**：不得内置路由、菜单数据、业务单例或业务页面；
- 封版后破坏性 API 变更须走主版本升级；小版本仅修缺陷、新增可选属性。

### 1.3 15 项权威清单（六类）

| 类别 | 组件 | 身份语言 |
|---|---|---|
| 主导航（4） | `NovaSidebar` / `NovaTopNavigation` / `NovaDualSide` / `NovaTabShell` | 品牌渐变轨 / 胶囊导航台 / 中央点阵画布 / 材质标签栏 |
| 多栏工作台（3） | `NovaThreeColumn` / `NovaCompare` / `NovaCardGrid` | 三级深度色阶 / 中缝调节柄 / Flow 网格 |
| 浮层容器（2） | `NovaModal` / `NovaDrawerPanel` | 顶部三色条 + catcher / 侧缘渐变轨 + grabber |
| 独立页壳（2） | `NovaSetupWizard` / `NovaBlankPage` | 三态步骤时间轴 / 居中阅读栏 |
| 多端根壳（3） | `NovaDesktop` / `NovaMobile` / `NovaFlexLayout` | 窗口控制点 / 灵动岛 / 浮起面板网格 |
| AI 对话主窗口（1） | `NovaChat` | 六轨按轨分治、每轨独占签名 |

> 命名以 `docs/COMPONENT_LIST.md` 权威清单与 `qmldir` 为准。
> 分类是**语义标签，不是目录结构**，不得据此新建宪法外目录。

---

## 二、旗舰四性验收标准

一个组件归类为 Prescient Layout Shell，必须**全部满足**以下四性。验收时逐项勾选，
任一项不通过即不得封版。四性是设计目标与品牌承诺；封版资格另由第 8 章门禁授予。

### 2.1 鲁棒性 Robustness

- [ ] 窗口缩至极小、最大化、全屏时布局不溢出、不崩溃、元素不丢失；
- [ ] Windows 100% / 125% / 150% / 200% 缩放下渲染正常，文字图标不模糊、不错位；
- [ ] `undefined` / 空值 / 非法尺寸 / 非法枚举入参自动回退安全默认值，不抛 QML 运行异常。
      **落地方式**：以 `_` 私有 `readonly property` 显式钳制（如 `Math.max(120, Math.min(size, width / 2 || size))`、
      `Math.max(1, Math.min(4, columns))`），禁止把未校验的外部值直接用于几何计算；
      **v2.0.1 全库强制**：15 项所有 `*Height` / `*Size` / `padding` / `gap` / `safe*` / `columns` /
      `stepCount` / `currentStep` 均须钳制后再用（共 39 个 `_` 私有只读属性）。栏高下界取 **24**
      （下界 0 会让 `NovaHeader` / `NovaPage` 的固定 padding 反噬出负几何）；`maxHeight` 不得小于
      「标题栏 + 操作栏 + 最小内容区」之和。验收须注入极端非法入参组合，**等待 Behavior 动画收敛后**
      测稳态几何非负、有限；过渡中间态的负 margin 不判缺陷；
- [ ] 规避同一属性多处重复赋值（`Property value set multiple times`）；
- [ ] 槽位内容动态增删时自动重排、无残留渲染、无内存泄漏；动态对象优先 `Loader` / `Repeater`，
      委托带 `required property int index`；
- [ ] 明暗主题实时切换，样式平滑更新，无卡死、无样式残留；
- [ ] `NovaMotion.reducedMotion` 为真时全部动效时长归零，不产生跳帧或残留动画。

### 2.2 健壮性 Solidity

- [ ] 对外属性、信号、槽位命名遵循 Nova 统一规范，与 Quasar 对标契约语义一致；
- [ ] **API 最小化**：只暴露必要配置项；内部控件 id 与辅助 property 一律 `_` 前缀，
      **私有成员不进冻结面**（母法第 13 章），可自由重构而不触发重签；
- [ ] **依赖定向**：仅依赖 `Nova.Controls` / `Nova.Behaviors` / `Nova.Services` / `Nova.Design`
      四个基础模块，以及本模块内已导出类型；**不依赖业务模块、不反向依赖上层**；
- [ ] **单向数据流 / 受控契约**：属性向下传配置，信号向上报意图；Shell **只 emit，不自写宿主状态**
      （键盘 Esc、点击遮罩等一律 emit 已有 signal，由宿主决定是否改 `collapsed` / `open`）；
- [ ] 封版后属性、信号移除或破坏性变更必须走主版本升级；PATCH / MINOR 保持 API 兼容。

### 2.3 艺术性 Aesthetics

- [ ] **唯一令牌源 `NovaTheme`**：颜色 / 间距 / 圆角 / 阴影 / 层叠一律取令牌，禁止字面色值与
      `Theme.*` 等虚构门面。真实令牌白名单见 §6.3；
- [ ] **动效全库统一**：动画时长取 `NovaMotion.duration(NovaMotion.transitionDuration)`、
      缓动取 `NovaMotion.easingStandard`；**禁止**在 Shell 内散落 `duration: 200/220/240` 等
      自定义参数（v2.0.0 已将 15 项中 8 处硬编码全部令牌化）；
- [ ] 不做任何自定义配置时，默认渲染即具备企业级精致观感；内置安全边距，内容不贴边；
- [ ] 导航、头部、侧边栏、内容区、底部层级区分清晰，阴影与边框组合使用；
- [ ] **身份差异化（强制）**：每项必须有**独有结构性身份元素**，严禁 15 项共用
      "平铺背景 + Header/Page/Footer + 宽度动画"模板仅换槽位名。身份元素须是 `_` 私有的
      **纯几何装饰**（色带 / 渐变轨 / 胶囊 / 网格底纹 / 时间轴 / 控制点 / 灵动岛 / 取景框等），
      零业务语义、**零字体依赖**（图标一律 Rectangle + rotation 组合），装饰实心度 ≥ 0.85，
      品牌色与中性底错开，浅色与深色主题、实心业务注入下均清晰可辨。
      **v2.0.1 全库强制**：实心度 ≥0.85 对 15 项一律生效（v2.0.0 只修 `NovaChat` 单点属漏改，
      宪法坑位 18），全库 20 余处低 opacity 身份装饰已统一提到 ≥0.85；三类例外须在源码
      显式注释：① 功能性遮罩 `_mask` / `_scrim`（刻意半透明透出下层，允许 0.32~0.55）；
      ② 交互禁用态（用颜色令牌区分，不用低 opacity 发虚）；③ 阴影层（`shadowColor(level)`
      自带 alpha）；
- [ ] **多轨按轨分治**：含 ≥2 条并排轨道的组件（典型 `NovaChat` 六轨），每条轨道须有
      **各自独占且互不重复**的前景签名，只占边缘 / 角标 / 列首列尾，中央内容区完全留给业务注入；
- [ ] 身份元素若会被业务槽位注入内容遮挡，须用层叠令牌提级（`NovaTheme.zMarginals` 等），
      确保 Gallery 默认视图即可辨识。**v2.0.1 全库回扫**：17 处与槽位注入层同父的身份装饰
      已补 `z: NovaTheme.zMarginals`；反之，**中央内容区底纹不得提级**（如 `NovaDualSide`
      中央网格点阵须留在业务注入之下——中央内容区完全留给业务注入）。
- [ ] **组合态一致性（v2.1.0 新颁 · 宪法第 9 章 CC-1~CC-8）**：① 组合上下文以 `_` 私有
      `readonly` 常量统一密度 / 层级 / 动效，六轨共享，禁止各轨散用 spacing 造成 padding 叠加；
      ② 相邻边界**唯一分隔源**，禁止 separator + 渐变缘轨 + 发丝线叠加；③ 装饰预算分主次、
      同屏收敛主色系，**禁止仿交互控件**（圆钮 / 搜索胶囊 / 图标方块 / 三点菜单 / 分段 tab）；
      ④ 折叠轨共用 `_dur`/`_ease`、锚链恒定不依赖 `visible` 三元；⑤ **槽位注入顶层必须
      `anchors.fill: parent`**（顶层默认 0×0，内部 anchors 会算负宽高被裁）；⑥ 内容限宽居中；
      ⑦ 装配后须出图审计，单组件 PASS 不等于装配 PASS；⑧ 独立演示为成品场景，调参面板默认收起。

### 2.4 前置预判性 Prescience

- [ ] 预判高频痛点并内置默认方案：不会设计边距 → 内置安全边距；调不好抽屉动画 → 内置
      `NovaMotion` 成熟参数；遗漏高 DPI → 内置缩放适配；主题联动漏写 → 自动绑定 `NovaTheme`；
- [ ] **键盘可达即鼠标可达**：有可收起面板 / 浮层的 Shell 内置 Esc 收起 / 关闭意图
      （`NovaSidebar` / `NovaDualSide` / `NovaTopNavigation` / `NovaChat` / `NovaModal` /
      `NovaDrawerPanel` / `NovaDesktop`），移动端根壳内置 Back；Shell 不吞键、不阻断 Tab 焦点链，
      交互子件沿用各自 interactive 契约与 `NovaFocusRing`；
- [ ] 分层可定制：新手直接用默认值，高级用户可覆盖公开属性与全部槽位；
- [ ] 属性命名语义直白、配套注释，降低理解成本；
- [ ] **RTL 声明式镜像（v2.0.1 全库强制）**：15 项组合根容器一律在根 Item 声明
      `LayoutMirroring.enabled: NovaTheme.isRtl`（v2.0.0 只覆盖部分组件，本轮补齐 14 项，
      15/15）；逻辑侧 `bySide` 等 API 语义恒定，不与声明式镜像冲突。验收须覆盖 `isRtl`
      与明暗主题联动切换、实心业务注入下的渲染。

---

## 三、分层边界（封版红线）

### 3.1 五模块物理映射（v2.0.0 校准）

| 层 | 物理目录 | 类型数 | 约束 |
|---|---|---:|---|
| 业务应用层 | 使用方工程 | — | 消费 Shell、向槽位注入内容；不修改 Shell 私有实现 |
| **组合组件层** | `Nova/Composite/LayoutShell/`（URI `Nova.Composite.LayoutShell`） | 15 | 只做结构、槽位、状态编排、信号转发、纯装饰身份；组合而非继承 |
| 基础组件层 | `Nova/Controls/` + `Nova/Behaviors/` | 91 + 13 | 单一职责控件与附加行为，不感知 Shell 布局 |
| 服务 / 设计层 | `Nova/Services/` + `Nova/Design/` | 16 + 4 | `NovaTheme` / `NovaScreen` / `NovaPlatform` / `NovaI18n` / `NovaMotion` |
| 主题基座 | `Nova/Services/NovaTheme.qml` | — | **唯一视觉变量来源** |

> **重要**：草案中的 `Atoms/`、`Widgets/`、`Theme/`、`Layout/` 是**逻辑分组名称，不是仓库物理目录**。
> 仓库只有上表五个 QML 模块。新增代码不得据此新建目录；不得新建 `Theme/` 门面或
> `Composite/` 下的其它子目录（宪法 0.3.0：`Composite/LayoutShell/` 是唯一合法组合目录）。

### 3.2 允许实现

固定布局结构与安全边距；展开 / 收起动画与过渡；`NovaTheme` 表面令牌与 `isDark` 绑定；
`NovaScreen` 断点自适应与 `LayoutMirroring.enabled: NovaTheme.isRtl`；入参合法性校验与兜底渲染；
信号转发；`_` 私有纯几何身份装饰。

### 3.3 严格禁止

- 硬编码业务菜单、业务路由表、业务页面、业务文案、业务图标、项目专属颜色；
- 引入业务单例、业务数据模型、业务专属配置，反向依赖上层业务工程代码；
- 在 Shell 内临时新建**可交互原子控件**、复制基础组件绘制样式、绕过 `NovaTheme` 令牌（第 7 章）；
- 未进 `qmldir` 的黑户 `.qml`（既不进冻结面，又污染 qmllint 分类预算）；
- 魔法 z 值（`z: 999`）、散落 `Animation` 参数、`Theme.*` 虚构 API、日期流水头注释。

---

## 四、槽位契约

### 4.1 统一的是机制与语义，不是固定槽位名（v2.0.0 重点校准）

草案规定"所有 Shell 采用 `headerSlot` / `sidebarSlot` / `contentSlot` / `footerSlot` / `overlaySlot`
五槽，且 `contentSlot` 为必需槽"——**该口径与 1.0.0 GA 实际交付不符，已作废**。

真实契约是：

- **统一机制**：一律 `property alias <slot>: <host>.data` 或 `<host>.content`（母法第 4 章 QML
  等价机制），禁止自造"槽对象"；
- **统一语义**：槽位是纯布局托管点，Shell 只决定位置 / 尺寸 / 显隐 / 断点行为，
  **不得**读写注入内容内部状态、不得把业务状态存在槽位宿主里；
- **场景化命名**：中心内容槽名随骨架范式而变（`contentSlot` / `gridSlot` / `pageSlot` /
  `leftSlot` + `rightSlot` / `treeSlot` + `listSlot` + `detailSlot` / `navSlot` + `conversationSlot` +
  `composerSlot` + `detailSlot`），**按需提供、不冗余**；
- **`overlaySlot` 按需**：13 项提供，`NovaModal` / `NovaDrawerPanel` 两个浮层容器自身即浮层，
  不重复提供；
- **浮层槽透明契约**：`overlaySlot` 位于 `NovaTheme.zFixedDrawer` / `zMax` 顶层，业务注入必须是
  透明 / 空 `Item`；注入铺满的不透明块会盖住整个组件（验收口径，非组件缺陷）。

### 4.2 15 项真实槽位一览（权威）

| 组件 | 槽位 |
|---|---|
| `NovaSidebar` | `headerSlot` · `sidebarSlot` · `contentSlot` · `footerSlot` · `overlaySlot` |
| `NovaTopNavigation` | `headerSlot` · `menuSlot` · `contentSlot` · `footerSlot` · `overlaySlot` |
| `NovaDualSide` | `leftSlot` · `contentSlot` · `rightSlot` · `footerSlot` · `overlaySlot` |
| `NovaTabShell` | `tabBarSlot` · `contentSlot` · `footerSlot` · `overlaySlot` |
| `NovaThreeColumn` | `treeSlot` · `listSlot` · `detailSlot` · `headerSlot` · `footerSlot` · `overlaySlot` |
| `NovaCompare` | `controlSlot` · `leftSlot` · `rightSlot` · `footerSlot` · `overlaySlot` |
| `NovaCardGrid` | `filterSlot` · `gridSlot` · `footerSlot` · `overlaySlot` |
| `NovaModal` | `titleSlot` · `contentSlot` · `actionsSlot` |
| `NovaDrawerPanel` | `titleSlot` · `contentSlot` · `actionsSlot` |
| `NovaSetupWizard` | `stepsSlot` · `contentSlot` · `controlsSlot` · `footerSlot` · `overlaySlot` |
| `NovaBlankPage` | `headerSlot` · `contentSlot` · `footerSlot` · `overlaySlot` |
| `NovaDesktop` | `menuSlot` · `toolbarSlot` · `pageSlot` · `statusSlot` · `overlaySlot` |
| `NovaMobile` | `headerSlot` · `contentSlot` · `bottomNavSlot` · `overlaySlot` |
| `NovaFlexLayout` | `headerSlot` · `contentSlot` · `footerSlot` · `overlaySlot` |
| `NovaChat` | `navSlot` · `conversationSlot` · `headerSlot` · `contentSlot` · `composerSlot` · `detailSlot` · `overlaySlot` |

### 4.3 层叠与宿主隔离

- `overlaySlot` 及任何弹层的 `z` 一律取 `NovaTheme.zSide` / `zMarginals` / `zFixedDrawer` /
  `zFullscreen` / `zMenu` / `zTop` / `zMax` 等令牌，禁止魔法数值；
- **槽位宿主必须是独立 `Item`**：装饰层与业务注入层分离，装饰用层叠令牌提级，
  避免业务注入内容遮挡身份元素（如 `NovaDesktop.toolbarSlot` 指向内层 `_toolbarHost`，
  而非直接指向带装饰的 `_toolbar.data`）。

---

## 五、目录结构与仓库现状映射

### 5.1 封版交付标准（1.0.0 GA 实际结构）

```text
src/pyside_nova/qml/Nova/Composite/LayoutShell/
├── qmldir                       # 单一模块注册 15 项（module Nova.Composite.LayoutShell）
├── README.md                    # 模块级交付物：15 项契约 + 依赖组件清单 + 最小示例
├── NovaSidebar.qml
├── NovaTopNavigation.qml
├── NovaDualSide.qml
├── NovaTabShell.qml
├── NovaThreeColumn.qml
├── NovaCompare.qml
├── NovaCardGrid.qml
├── NovaModal.qml
├── NovaDrawerPanel.qml
├── NovaSetupWizard.qml
├── NovaBlankPage.qml
├── NovaDesktop.qml
├── NovaMobile.qml
├── NovaFlexLayout.qml
└── NovaChat.qml

examples/layout_shell/<snake_case>/   # 15 个独立演示目录（main.qml + run.py）
examples/gallery/layout_shells.qml    # Gallery 独立分组：15 页逐项预览 + 调参面板
docs/COMPONENT_LIST.md   # 权威清单（命名 / 分类 / 身份元素）
```

### 5.2 与草案的差异（必须知晓）

| 草案 v1.0.0 口径 | 1.0.0 GA 实际 | 依据 |
|---|---|---|
| 每个 Shell 一个独立子目录，内含独立 `qmldir` | **单一模块平铺** 15 个 `.qml` + 单个 `qmldir` | 组合宪法 0.3.0：单一合法专属模块，独立 qmldir、整体进冻结面 |
| 仅 `NovaSidebarShell.qml` 一个平铺文件，其余规划中 | **15 项全部交付并冻结** | `COMPONENT_LIST.md` / API 指纹 `bfd3d938a2fab7be` |
| 组件名一律带 `Shell` 后缀 | **能去则去、必要则留**：`NovaTabShell` 因跨模块重名保留；`NovaTopNavigation` 全称化；`NovaSetupWizard` 正名 | 组合宪法 0.4.0~0.6.0 |
| Root Shell 不在本规范内、不得宣称已封版 | 3 根壳 + `NovaChat` **同模块、已 GA 封版**，另加第 12 章附加要求 | 组合宪法第 1 章六类 15 项 |

> 每个 Shell 的 `qmldir` 独立注册会与上层模块 URI 冲突并产生 N 个中间冻结指纹，
> 属宪法坑位 7 / 10 明令禁止的做法。**不得回退。**

---

## 六、QML 编码强制规范

1. **两行头注释**（母法第 2 章）：第 1 行为从 `src/` 起的完整子路径，第 2 行为组件定位说明；
   允许追加用法 / 身份 / a11y 说明行。**禁止日期流水**（"星期一 2026-11-23" 式）、
   **禁止 `/** ... v1.0.0 FROZEN ... */` 模板**（草案模板作废，封版由门禁而非注释声明）。
   `qmldir` 注释只能用 `#`。
2. **私有前缀**：内部控件 id、辅助 property 一律 `_`（`_drawer` / `_bandColor` / `_done`）；
   `_` 前缀成员不进冻结面。
3. **唯一令牌源**：默认值优先读 `NovaTheme`，禁止字面色值与 `Theme.*`。
   *边界说明*：纯几何身份装饰的 1~4px 发丝 / 圆点尺寸属于**几何常量**（非布局尺寸），
   允许字面量；布局尺寸、间距、圆角、颜色、层叠一律取令牌。
4. **真实令牌白名单**（以 `NovaTheme.` 为前缀，取值见 `docs/DESIGN_TOKENS.md`）：
   - 表面色：`page` / `surface` / `surfaceAlt` / `outline` / **`outlineStrong`** / `textColor` /
     `textMuted` / **`textOnPrimary`**；
   - 品牌与语义色：`primary` / `secondary` / `accent` / `dark` / `positive` / `negative` /
     `info` / `warning`；
   - 间距 / 圆角：`spacingS` / `spacingM` / `spacingL`；`radiusS` / `radiusM` / `radiusL`；
   - 层叠：`zSide` / `zMarginals` / `zFixedDrawer` / `zFullscreen` / `zMenu` / `zTop` /
     `zTooltip` / `zNotify` / `zMax`；
   - 阴影 / 字阶：`shadowColor(level)` / `elevationLayers(level)`；`fontXS`…`fontXL` / `textStyle(name)`；
   - 模式 / 方向：`isDark` / `setDark(v)` / `toggleDark()`；`isRtl` / `direction`。
   > `isDark` 是明暗状态，`dark` 是 Quasar `$dark` 品牌色，二者不可混用；
   > 不存在 `Theme` 单例、`NovaLabel` / `NovaButton` / `NovaAnimation` 类型。
5. **动效令牌**：`NovaMotion.duration(base)` + `NovaMotion.easingStandard`；
   `import Nova.Design`；禁止散落 `NumberAnimation { duration: 240; easing.type: Easing.OutCubic }`。
6. **信号与状态**：信号命名动宾结构（`sidebarToggled()` / `closeRequested()`）；**只 emit 不自写宿主状态**；
   防重入用显式状态位，禁止拿几何量当布尔（`sidebarCollapsed !== _drawer.width` 是历史缺陷）。
7. **组合优于继承**：优先组合既有类型，规避 QML 单继承属性冲突与 `Item` FINAL 属性覆盖陷阱。
8. **alias 暴露槽位**：内部容器不对外泄露；槽位宿主独立 `Item`；装饰层与注入层分离（§4.3）。
9. **生命周期**：声明式容器无动态对象时**无需** `Component.onDestruction`（不得为凑条款写空实现）；
   `Component.onCompleted` 仅用于初始状态校准与焦点获取（如 Modal / Drawer 的 `forceActiveFocus()`）。
10. **a11y 标记**：组合容器根 `Item` 属 decorative，源码带 `// a11y: decorative`，
    **禁止挂 `Accessible.*`**；纯几何装饰同样逐块标注。
11. **Repeater 委托**：`required property int index`，内层引用用委托 id 限定；
    辅助 property 必须 `_` 前缀，否则会进冻结面造成指纹漂移。

---

## 七、组合完整性（D-013 入宪口径）

> 决策编号 **D-013**｜状态：✅ 生效｜对应组合宪法第 5 章

所有 Layout Shell 必须**完全基于** `pyside-nova` 库内已导出的 Controls / Behaviors / Services /
Design 组件组合实现。

- **禁止**在 Shell 内临时新建**可交互原子控件**、复制基础组件绘制样式、绕过 `NovaTheme` 令牌；
- **身份元素的合规边界（v2.0.0 明确）**：§2.3 要求的独有身份元素是 `_` 私有的**纯几何装饰**
  （`Rectangle` / `Gradient` / `Row` / `Repeater` 组合），不构成可交互控件、不复制原子样式、
  不含业务语义、不引入字体依赖，且全部取 `NovaTheme` 令牌与 `NovaMotion` 参数——
  **因此不违反 D-013**。反之，若身份元素演变为可点击按钮、复制 `NovaBtn` 样式或硬编码色值，
  即属违规。
- **前置门禁**：每个 Shell 开发前必须读取 `docs/COMPONENT_LIST.md`（生成器唯一权威来源），
  在模块级 `README.md` 中列出「依赖组件清单」（组件名 / 模块路径 / 用途）；
- **缺失处理**：所需能力库内不存在时，**先补库组件并独立验收**，再在 Shell 中组合使用；
  Shell 不得降级为手写临时控件；
- **可机检纪律**：新增 Shell 后 qmllint error 零容忍、warning 分类数不超过
  `tests/lint-baseline.json` 预算；靠"加未登记文件"抬高告警数视为门禁破坏。

---

## 八、封版准入验收清单

一个 Layout Shell 封版前必须**全部满足**以下条目。

### 8.1 契约与边界

- [ ] 符合第 1 章三要素；进 `Composite/LayoutShell` 单一 `qmldir`、入 `COMPONENT_LIST.md`、无黑户文件；
- [ ] 头注释两行合规、无日期流水；导出文件名 = 类型名、版本恒为 `1.0`；
- [ ] 仅依赖 four 基础模块与 Theme 令牌，无业务依赖；无私有可交互原子、无复制样式、无硬编码令牌；
- [ ] 单向数据流 / 受控契约成立；内部控件与辅助 property `_` 前缀；
- [ ] 槽位只用 §4.2 alias 机制；overlay 层叠取 `NovaTheme.z*`，无魔法 z。

### 8.2 四性

- [ ] 第二章 2.1 鲁棒性全部勾选；
- [ ] 第二章 2.2 健壮性全部勾选；
- [ ] 第二章 2.3 艺术性全部勾选（含**身份差异化**与**多轨按轨分治**）；
- [ ] 第二章 2.4 前置预判性全部勾选（含 **Esc / Back 键盘可达**）。

### 8.3 工程交付（1.0.0 GA 实测基线）

- [ ] `python scripts/check_all.py --tier static` **3/3 PASS**：
      a11y 契约 139/139、API 冻结 139 类型零漂移（指纹 `bfd3d938a2fab7be`）、
      qmllint 0 error 且 warning 在预算内；
- [ ] 专项测试 `test_api_freeze.py` + `test_layout_shells.py` **48/48**；
- [ ] Gallery 15 页 + `examples/layout_shell/` 15 个独立演示**无头实例化 31/31**（15 组件 + Gallery + 15 演示）；
- [ ] 模块级 `README.md` 含 15 项属性 / 信号 / 槽位表、依赖组件清单与最小示例；
- [ ] 明暗切换 + RTL + 断点自适应 + 窗口极值 + 非法入参兜底实测通过；
- [ ] 容器根标 `// a11y: decorative`；交互子件沿用 interactive 契约与焦点环；
- [ ] 版本号、变更记录、封版标记写入 `CHANGELOG.md` 与宪法迭代记录表。

> **v2.0.1 / 宪法 0.8.1 四性全库回扫补充实测**：15/15 每项注入 34 组极端非法入参
> （负尺寸 / 超大尺寸 / 非法枚举同时注入），**等待 Behavior 动画收敛后**测稳态几何
> 非负、有限；15/15 根 Item 声明 `LayoutMirroring.enabled: NovaTheme.isRtl`；明暗令牌
> 实时切换 PASS；`reducedMotion` 下动画时长 300→0ms PASS；浅色 + 深色双主题、实心
> 业务注入下 15/15 身份装饰审计图重渲染（`docs/screenshots/composition_identity_audit*.png`）。
> 机检表（装饰实心度 / RTL / 钳制 / 字面色值 / 动效硬编码 / 键盘 / a11y 标记）全库无一
> 漏项：39 个 `_` 私有 `readonly` 钳制属性、54 处几何引用改走钳制值、17 处 `zMarginals`
> 提级、20 余处实心度提至 ≥0.85。**公共 API 签名逐字不变、139 类型零漂移、指纹
> `bfd3d938a2fab7be` 不变**（PATCH 无需重签）。

> **v2.1.0 / 宪法 0.9.0 组合态装配实测（NovaChat 首例）**：13 个 `_` 私有组合上下文常量
> 供六轨共享；边界由「3 separator + 3 渐变缘轨 + header 渐变线 + 顶层三段撞色带」收敛为**每边界
> 唯一分隔源 + 主色系 2px 顶层线**；20+ 仿控件装饰收敛为抽象几何；三段折叠 Behavior 共用
> `NovaMotion.duration()` 且锚链恒定；showcase 六槽注入真实业务内容（会话列表 / 气泡 / 详情 /
> 输入区），调参面板改默认收起浮层；消息流与输入框限宽居中。**浅色 / 深色 / 折叠三态渲染审计
> 全部通过、QML 零错误、对象树无 0×0 / 负宽高**；公共 API 逐字不变、139 类型零漂移、
> 指纹 `bfd3d938a2fab7be` 不变（PATCH 无需重签）。

> **0.9.1 / 宪法 0.9.1 组合态装配实测（批次 2 · 三大多端根壳）**：`NovaDesktop` /
> `NovaMobile` / `NovaFlexLayout` 逐项完成 CC-1~CC-8 迁移；三元锚链一律改为「栏高归零 +
> 恒定锚链 + `Behavior on height` 共用 `_dur`/`_ease`」；三色撞色与伪按钮收敛主色系抽象
> 几何；槽位宿主独立铺满、注入顶层 `anchors.fill: parent`；三个演示重做成品级 showcase
> 且调参面板默认收起。**验收**：4 个 showcase × 浅 / 深 / 变体共 12 张渲染审计图、QML
> 零错误、静态 3/3、专项 48/48、31/31 实例化、4 组件极端非法入参 0 负几何、RTL 4/4、
> reducedMotion 300→0ms、qmllint 0 error / 593 warning、139 类型零漂移、
> 指纹 `bfd3d938a2fab7be` 不变。逐项销号台账见 `docs/prescript/AUDIT_CEILING.md`，
> **4/15 已销号**，其余 11 项按「稳步推进、逐个打磨」推进。

> **批量交付纪律**：一次交付 N 个 Shell 时，先整批完成登记（统一进 `qmldir` → 整批登记 a11y
> `decorative` → 整批补 `PARITY.md` 审计节 → **单次重签** API 冻结 → 单次重生成
> `COMPONENT_LIST.md`），再整批跑门禁。**禁止逐个重签**（产生 N 个中间指纹）。
> 纯 `_` 私有实现变更（如身份重构、动效令牌化）不触动公共签名，属 PATCH，无需重签。

---

## 九、入库交付物清单

每个封版 Shell 必须齐备（**模块级集中承载**，不按草案拆子目录）：

- [ ] 组件源码：15 个 `.qml` + 单一 `qmldir`（`module Nova.Composite.LayoutShell`）
- [ ] **模块级 `README.md`**：15 项组件说明、属性表、信号表、槽位表、依赖组件清单、最小示例
- [ ] Gallery Demo：15 页独立预览页与调参面板
- [ ] `examples/layout_shell/` 15 个独立演示目录（`main.qml` + `run.py`）
- [ ] 单元测试：覆盖核心信号、状态切换、边界参数、槽位挂载
- [ ] 验收清单：对照第二章与第八章逐项勾选通过
- [ ] 变更记录：版本号、封版日期、已知限制（`CHANGELOG.md`）
- [ ] 生成物同步：`COMPONENT_LIST.md` / `API_FREEZE.md` / `A11Y_MATRIX.md` / `docs/ai/api/*.json`
      **只重跑生成器，禁止手改**

---

## 十、版本迭代与变更流程

1. 本规范本身为 Frozen 基准；修改封版规则须走版本评审并升级规范版本号；
2. 已封版 Shell：
   - **PATCH**：仅修缺陷、优化兜底逻辑、`_` 私有实现重构（含身份 / 动效 / 键盘打磨），
     不新增公共属性、不改默认美学、**不重签**；
   - **MINOR**：新增可选属性、新增槽位，原有 API 完全兼容，需重签冻结面；
   - **MAJOR**：破坏性 API 变更、跨模块改名、结构重设计，须明确告知迁移方案并整批单次重签；
3. 新增 Shell：先写 Demo、在 Gallery 验证，对照第八章逐项勾选，全部通过后合并入库；
4. 交付物结构迁移（如平铺改子目录）属宪法禁止项，不得执行（§5.2）。

---

## 十一、最小使用示例

```qml
// main.qml —— 1.0.0 GA 真实命名 / 真实 import / 真实属性（可执行）
import QtQuick
import QtQuick.Controls.Basic
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    visible: true
    width: 1080; height: 720
    color: NovaTheme.page

    NovaSidebar {
        anchors.fill: parent
        sidebarSize: 260
        onSidebarToggled: function(collapsed) { /* 宿主受控改 sidebarCollapsed */ }

        sidebarSlot: NovaText { text: "导航由业务注入" }
        contentSlot: Rectangle { color: NovaTheme.page }
        footerSlot: NovaText { text: "Powered by pyside-nova" }
    }
}
```

> 说明：槽位名以 §4.2 权威表为准；`NovaSidebar` **没有** `title` 属性（草案示例的 `title:` /
> `NovaLabel` 均已作废）。业务页面 `MyBusinessPage` 由使用方提供，Shell 不内置任何业务内容。

---

## 十二、App Root Shell 与 AI 主窗口附加要求

`NovaDesktop`、`NovaMobile`、`NovaFlexLayout` 与 `NovaChat` **同属第五模块、同为 1.0.0 GA 已封版
公共类型**（草案"不得对外宣称已封版"口径作废）。在满足第二至七章之外，另须满足：

- 提供页面 / 内容宿主能力（如 `pageSlot` / `contentSlot` / `composerSlot`），
  **禁止内置业务路由表与业务菜单数据**；
- 移动端根壳须处理系统安全区，数值来自 `safeTop` / `safeBottom` 属性与 `NovaPlatform.isMobile`，
  不得硬编码机型参数；
- 大屏根壳须提供 `columns` 分栏策略与 `NovaScreen` 缩放依据，禁止内置具体业务大屏模板；
- AI 对话主窗口六槽全由业务注入，气泡复用 `NovaChatMessage`，Shell 不持有会话数据或提示词；
  每条轨道须有独占前景签名（§2.3 多轨按轨分治）；
- 交付物中须包含目标平台适配说明与验证记录。
- AI 对话主窗口另须满足第 9 章 CC：六轨共享组合上下文、单一分隔源、抽象几何装饰、
  槽位注入顶层 `anchors.fill: parent`、内容限宽居中；独立演示须为成品 showcase，调参面板分离。

---

## 十三、文档治理与变更记录

### 13.1 文档层级

| 文档 | 性质 | 版本 | 状态 |
|---|---|---|---|
| `docs/CONSTITUTION.md` | 架构宪法（母法） | 现行 | 最高法源 |
| `docs/COMPOSITION_CONSTITUTION.md` | 组合组件宪法（子法） | 0.9.0 | 现行 |
| 《Prescient Layout Shell · 封版规范》 | 技术执行红线 | **v2.1.0** | FROZEN（本文档，记录性） |
| 《PySide6-Nova 旗舰组件库白皮书》 | 品牌与架构总纲 | v2.1.0 | FROZEN |
| `docs/COMPONENT_LIST.md` | 组件成熟度唯一事实源 | 随仓库 | 动态（生成器产物） |

> 四者关系：**宪法立法 → 白皮书定调 → 本规范定红线 → COMPONENT_LIST 定事实**。
> 对外宣传与工程执行均以事实源为准，白皮书与本规范不得夸大成熟度。

### 13.2 适用组件成熟度（全部 ✅ 已封版 1.0.0 GA）

| 类别 | 组件 | 成熟度 |
|---|---|---|
| 主导航 | `NovaSidebar` / `NovaTopNavigation` / `NovaDualSide` / `NovaTabShell` | ✅ 1.0.0 GA |
| 多栏工作台 | `NovaThreeColumn` / `NovaCompare` / `NovaCardGrid` | ✅ 1.0.0 GA |
| 浮层容器 | `NovaModal` / `NovaDrawerPanel` | ✅ 1.0.0 GA |
| 独立页壳 | `NovaSetupWizard` / `NovaBlankPage` | ✅ 1.0.0 GA |
| 多端根壳 | `NovaDesktop` / `NovaMobile` / `NovaFlexLayout` | ✅ 1.0.0 GA |
| AI 对话主窗口 | `NovaChat` | ✅ 1.0.0 GA |

### 13.3 封版变更记录

| 版本 | 日期 | 变更 |
|---|---|---|
| v1.0.0 | 2026-11-25 | 首版草案：确立四性标准、分层红线、槽位规范、D-013 组合基线、目录映射、Root Shell 附加要求、文档治理机制（含大量与仓库不符的规划态口径） |
| **v2.0.0** | **2026-11-25** | **企业级旗舰封版校准**：① 抬头补「法源与封版资格」声明，明确 FROZEN 为记录性、资格由 API 冻结门禁授予；② 适用范围 11 → **15 项**、第五模块 URI、五模块物理映射，作废 `Atoms/Theme/Layout` 虚构目录；③ 组件名全部校准为 GA 真名，作废 `Nova*Shell` 旧名与 `Theme.*` / `NovaLabel` / `NovaAnimation` 虚构 API；④ **第 4 章槽位契约重写**：作废"固定五槽 / contentSlot 必需"错误口径，给出 15 项真实槽位权威表 + 浮层槽透明契约 + 宿主隔离要求；⑤ 第 5 章目录结构重写为单一模块平铺 + 模块级 README，明确禁止拆子目录 / 独立 qmldir；⑥ 第 6 章编码规范补 `NovaMotion` 动效令牌、`outlineStrong` / `textOnPrimary` 真实令牌、Repeater 委托纪律、两行头注释与生命周期校准；⑦ 第 7 章明确身份元素不违反 D-013 的合规边界；⑧ 第 8/9 章验收口径对齐真实门禁（静态 3/3、专项 48/48、31/31 无头加载、指纹零漂移）；⑨ 第 12 章 Root Shell / AI 主窗口改为已 GA 封版；⑩ 成熟度表全部由"规划中"改为 ✅ 1.0.0 GA；⑪ 最小示例改为可执行的真实命名版本 |

| **v2.0.1** | **2026-11-25** | **四性全库回扫验收细则补强（MINOR，不改封版口径）**：§2.1 非法入参条款落地为 `_` 私有 `readonly` 钳制（15 项共 39 个属性 / 54 处引用、栏高下界 24、`maxHeight` ≥ chrome 之和、等待 Behavior 动画收敛后测稳态几何）；§2.3 装饰实心度 ≥0.85 升为**全库强制** + 三类显式注释例外（功能性遮罩 / 交互禁用态 / 阴影层）+ 中央内容区底纹不得提级；§2.4 新增 RTL 声明式镜像 15/15 全库强制；§8.3 补四性回扫实测基线（15/15 极端非法入参稳态几何非负、双主题实心注入渲染、`reducedMotion` 300→0ms）；§13.1 层级表同步组合宪法 0.8.1。全部为验收细则增补，四性标准与封版口径不变 |

| **v2.1.0** | **2026-11-25** | **组合态一致性契约 CC 升版（MINOR，不改四性与封版口径）**：§2.3 新增组合态 8 条红线（组合上下文 / 唯一分隔源 / 装饰预算与禁止仿交互控件 / 动效同步 / 槽位 `anchors.fill` / 内容限宽 / 装配态验收 / showcase 纪律）；§8.3 补 `NovaChat` 三态渲染实测基线；§12 补 AI 主窗口 CC 附加要求；§13.1 层级表同步宪法 0.9.0 与白皮书 v2.1.0。本版为新增验收项，原四性标准与 15 项清单不变 |

### 13.4 后续变更策略

- **PATCH**：错别字、措辞微调、目录映射事实更新，不改结构；
- **MINOR**：新增可选验收项、补充场景，不改变封版口径；
- **MAJOR**：调整四性标准、分层红线、槽位语义、组件清单数量，须走版本评审并同步宪法。

---

## 附录：术语表

| 术语 | 英文 | 释义 |
|---|---|---|
| 组合根容器 / 布局壳 | Layout Shell | 无业务语义的复合根容器，由 ≥2 个已导出公共类型组合而成 |
| 预判式布局壳 | Prescient Layout Shell | 内置痛点预判方案与默认美学基线的壳组件体系 |
| 根壳 | App Root Shell | 面向桌面 / 移动 / 大屏的顶层应用容器 |
| 主题令牌 | Theme Token | 颜色、间距、圆角、阴影、层叠等可复用设计变量，唯一门面 `NovaTheme` |
| 动效令牌 | Motion Token | 时长、缓动、预设过渡与 `reducedMotion` 短路，唯一门面 `NovaMotion` |
| 槽位 | Slot | 预留内容注入点位，`property alias` 实现，遵循单向数据流 |
| 身份元素 | Identity Element | `_` 私有纯几何装饰，赋予每个 Shell 独有可辨识结构，零业务语义 / 零字体依赖 |
| 多轨按轨分治 | Per-track Identity | 多轨组件每条轨道各有独占前景签名，中央留给业务注入 |
| 受控契约 | Controlled Contract | Shell 只 emit 意图、不自写宿主状态，由宿主决定是否改配置 |
| API 冻结 | API Freeze | 公共 `property` / `signal` / `function` / `alias` 签名快照，`_` 私有成员不进冻结面 |
| 指纹 | Freeze Fingerprint | 冻结快照哈希；当前 `bfd3d938a2fab7be`，139 类型零漂移 |
| 封版 | Frozen | 对外契约冻结、门禁验收通过、纳入正式版本的状态（由门禁授予） |
| 黑户 | Unregistered QML | 位于 `src/` 却不进任何 `qmldir` 的 `.qml`，不得交付 |
| 组合基线 | D-013 | Shell 必须基于库内已导出组件组合，禁止私造可交互原子 / 复制样式 |
| 鲁棒性 / 健壮性 / 艺术性 / 前置预判性 | Robustness / Solidity / Aesthetics / Prescience | 旗舰四性验收标准 |
| a11y decorative | — | 装饰容器不挂 `Accessible.*`，避免屏读器噪声 |
| HMI | Human-Machine Interface | 人机交互界面，工业领域常用 |

---

*本规范随白皮书与宪法同步维护；组件实现以仓库代码为准，规范变更须记录版本号与迁移说明。*
