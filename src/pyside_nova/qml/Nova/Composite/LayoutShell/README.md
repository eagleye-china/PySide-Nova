# Nova.Composite.LayoutShell · 模块交付文档

> **第五 QML 模块｜21 项组合根容器（Prescient Layout Shell）｜15 项 1.0.0 GA 封版 + 5 项 1.2.0 增量（NovaAgent / NovaDE / NovaCopilot / NovaOrbit / NovaIncubator）+ 1 项 1.5.0 增量（NovaAIReport 智能报表工作台）**
>
> 模块 URI：`Nova.Composite.LayoutShell` · 注册文件：`qmldir` · 21 项全部为冻结公共类型
> API 冻结指纹：`4f882374ad52262b`（144 类型；1.2.0 整批单次重签，新增第 20 组合根 NovaIncubator；物理拍平后重签，公共成员零漂移。反向归一化 `file` 可精确还原旧值 `68b34a408489b6a8`）
>
> **物理平铺（1.2.0 · 12:05 拍平后）**：20 个 QML 全部平铺于本目录、`qmldir` 逐项以 `名字.qml` 导出，**模块 URI 与 `import` 用法不变**，物理路径回到 1.0.x 已发布形态。九类语义（Navigation / Workbench / Overlay / Page / Carrier / Chat / Intelligence / Orbit / Incubator）保留为**文档层分类台账**，不再落物理子目录——遵循「概念域 ≠ 物理目录 ≠ 模块 URI」铁律。详见 `docs/prescript/GUIDE_CLASSIFICATION.md §1.1 / §4`。

| 项目 | 内容 |
|---|---|
| **法源** | `docs/CONSTITUTION.md`（母法）· `docs/COMPOSITION_CONSTITUTION.md`（组合组件宪法 0.9.1）· `docs/prescript/SPEC_FREEZE.md`（技术红线 v2.1.0） |
| **权威事实源** | `docs/COMPONENT_LIST.md` + `api/nova-api-1.2.0.json`（均为生成器产物，禁止手改） |
| **性质** | 无业务语义的复合根容器骨架；填业务即交付 |
| **状态** | ✅ 21/21 已登记（15 GA 封版 + 5 增量 + 1 智能报表）· Gallery 21 页独立预览 · 静态门禁 3/3 |

---

## 一、模块契约（三要素 + 四性）

| 要素 | 落地 |
|---|---|
| **组合性** | 每项由 ≥2 个已导出公共类型组合（`NovaHeader` / `NovaPage` / `NovaFooter` / `NovaSeparator` …），不是单控件皮肤 |
| **槽位化** | 一律 `property alias`；槽位是纯布局托管点，Shell 不读写注入内容状态 |
| **无业务语义** | 不含菜单 / 路由 / 数据模型 / 文案 / 项目专属图标；Gallery 可独立预览、调参、测试 |

**旗舰四性**：

- **Robustness**：`readonly property` 显式钳制非法尺寸（如 `_lw` / `_tw` / `_cols` / `_navW`）、
  动态内容走 `Repeater`、明暗主题实时切换、`reducedMotion` 动效短路；
- **Solidity**：`_` 私有成员不进冻结面、只 emit 不自写宿主状态（受控契约）、依赖严格向下；
- **Aesthetics**：唯一令牌源 `NovaTheme`、动效唯一门面 `NovaMotion`、**每项独有纯几何身份元素**
  （零业务语义、零字体依赖、装饰实心度 ≥0.85）、多轨组件按轨分治；
- **Prescience**：内置安全边距 / 断点 / 主题绑定 / **Esc · Back 键盘可达** / 分层可定制。

**统一机制**：`import Nova.Composite.LayoutShell` → 向槽位注入业务内容 → 监听 signal 自行决定是否
修改 `collapsed` / `open` 等配置。**Shell 只 emit 意图，不替宿主改状态。**

---

## 二、依赖组件清单（D-013 前置门禁产物）

> 组合宪法第 5 章 / 封版规范第 7 章要求：每个 Shell 开发前读取 `COMPONENT_LIST.md`，
> 在此列出「依赖组件清单」。以下**全部为库内已导出公共类型**，无私有原子、无复制样式、无业务依赖。

### 2.1 基础依赖（实际在 Shell 内组合使用）

| 类型 | 模块 | 用途 |
|---|---|---|
| `NovaTheme` | `Nova.Services` | 唯一视觉令牌门面：表面色 / 品牌色 / 间距 / 圆角 / 层叠 / 阴影 / `isDark` / `isRtl` |
| `NovaHeader` | `Nova.Controls` | 顶部区域骨架 |
| `NovaFooter` | `Nova.Controls` | 底部状态栏 / 输入区 / 控制区骨架 |
| `NovaPage` | `Nova.Controls` | 主内容区骨架（`content` 承载注入内容） |
| `NovaSeparator` | `Nova.Controls` | 区域分隔（水平 / 垂直） |
| `NovaMotion` | `Nova.Design` | 动效令牌：`duration()` / `easingStandard` / `reducedMotion` / `speedFactor` |
| `NovaPlatform` | `Nova.Services` | `isMobile` 触控平台判定（仅 `NovaMobile`） |
| `NovaScreen` | `Nova.Services` | `gtLg` 断点判定（仅 `NovaFlexLayout`） |

### 2.2 21 项依赖矩阵

| 组件 | Theme | Header | Footer | Page | Separator | Motion | Platform | Screen |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `NovaSidebar` | ✓ | ✓ | ✓ | ✓ | | ✓ | | |
| `NovaTopNavigation` | ✓ | ✓ | ✓ | ✓ | | ✓ | | |
| `NovaDualSide` | ✓ | | ✓ | ✓ | | ✓ | | |
| `NovaTabShell` | ✓ | | ✓ | ✓ | ✓ | | | |
| `NovaThreeColumn` | ✓ | ✓ | ✓ | ✓ | ✓ | | | |
| `NovaCompare` | ✓ | | ✓ | ✓ | ✓ | | | |
| `NovaCardGrid` | ✓ | | ✓ | | ✓ | | | |
| `NovaModal` | ✓ | ✓ | | ✓ | ✓ | | | |
| `NovaDrawerPanel` | ✓ | ✓ | | ✓ | ✓ | | | |
| `NovaSetupWizard` | ✓ | | ✓ | ✓ | ✓ | ✓ | | |
| `NovaBlankPage` | ✓ | ✓ | ✓ | ✓ | | | | |
| `NovaDesktop` | ✓ | | ✓ | ✓ | ✓ | | | |
| `NovaMobile` | ✓ | ✓ | | ✓ | ✓ | | ✓ | |
| `NovaFlexLayout` | ✓ | ✓ | ✓ | ✓ | | | | ✓ |
| `NovaChat` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | |
| `NovaAgent` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | |
| `NovaDE` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | |
| `NovaCopilot` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | |
| `NovaOrbit` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | |
| `NovaIncubator` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | |
| `NovaAIReport` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | |

### 2.3 推荐业务注入类型（非 Shell 内实例化）

| 类型 | 模块 | 建议用途 |
|---|---|---|
| `NovaCard` | `Nova.Controls` | 由业务注入 `NovaCardGrid.gridSlot` 的卡片 |
| `NovaChatMessage` | `Nova.Controls` | 由业务注入 `NovaChat.contentSlot` 的对话气泡 |
| `NovaBtn` / `NovaText` / `NovaMenu` 等 | `Nova.Controls` | 由业务注入任意槽位的交互与展示内容 |

> **D-013 合规边界**：21 项的独有身份元素是 `_` 私有**纯几何装饰**（`Rectangle` / `Gradient` /
> `Row` / `Repeater`），不构成可交互控件、不复制原子样式、不绕过令牌、不含字体依赖——
> **不违反**"禁止私造原子"基线。

---

## 三、21 项完整契约

> 下表属性均为**公开配置 / 只读派生属性**；`_` 前缀私有成员不进冻结面，不在此列。
> 机器可读完整签名见 `api/nova-api-1.2.0.json` 与 `docs/COMPONENT_LIST.md`。

### 主导航（4）

#### `NovaSidebar` — 侧边导航工作台
- **身份**：品牌渐变轨（4px 恒驻左缘）+ 浮起侧栏卡（圆角 / 阴影 / 内边距）
- **配置**：`sidebarSize` · `sidebarCollapsed` · `showHeader` · `showFooter` · `headerHeight` · `footerHeight` · `breakpoint` · `bordered` · `belowBreakpoint`(ro)
- **信号**：`sidebarToggled(bool collapsed)` ｜ **函数**：`toggleSidebar()`
- **槽位**：`headerSlot` · `sidebarSlot` · `contentSlot` · `footerSlot` · `overlaySlot`
- **键盘**：`Esc` 展开态时 emit `sidebarToggled(true)`
- **依赖**：Theme · Header · Footer · Page · Motion

#### `NovaTopNavigation` — 顶部导航工作台
- **身份**：胶囊导航台（浮起圆角 header）+ 悬浮下拉卡（阴影 + 边框）
- **配置**：`showHeader` · `showFooter` · `menuOpen` · `headerHeight` · `footerHeight` · `menuHeight`
- **信号**：`menuToggled(bool open)` ｜ **函数**：`toggleMenu()`
- **槽位**：`headerSlot` · `menuSlot` · `contentSlot` · `footerSlot` · `overlaySlot`
- **键盘**：`Esc` 下拉打开时 emit `menuToggled(false)`
- **依赖**：Theme · Header · Footer · Page · Motion

#### `NovaDualSide` — 双侧边工作台
- **身份**：中央画布点阵网格 + 左右浮起栏（primary / secondary 顶部标识）
- **配置**：`leftSize` · `rightSize` · `leftCollapsed` · `rightCollapsed` · `showFooter` · `footerHeight` · `bordered`
- **信号**：`leftToggled(bool collapsed)` · `rightToggled(bool collapsed)` ｜ **函数**：`toggleLeft()` · `toggleRight()`
- **槽位**：`leftSlot` · `contentSlot` · `rightSlot` · `footerSlot` · `overlaySlot`
- **键盘**：`Esc` 对展开侧分别 emit 收起意图
- **依赖**：Theme · Footer · Page · Motion

#### `NovaTabShell` — 标签页工作台
- **身份**：材质化标签栏（三态段落）+ 底部品牌下划线指示
- **配置**：`showTabBar` · `showFooter` · `tabBarHeight` · `footerHeight`
- **信号**：`tabActivated(int index)` · `tabCloseRequested(int index)` · `tabAddRequested()`
- **槽位**：`tabBarSlot` · `contentSlot` · `footerSlot` · `overlaySlot`
- **依赖**：Theme · Footer · Page · Separator

### 多栏工作台（3）

#### `NovaThreeColumn` — 三栏工作台
- **身份**：三级深度色阶（目录 / 列表 / 详情）+ 分隔中部拖拽 grip
- **配置**：`treeSize` · `detailSize` · `showHeader` · `showFooter` · `headerHeight` · `footerHeight` · `bordered`
- **信号**：`columnResized(string column, real size)`
- **槽位**：`treeSlot` · `listSlot` · `detailSlot` · `headerSlot` · `footerSlot` · `overlaySlot`
- **依赖**：Theme · Header · Footer · Page · Separator

#### `NovaCompare` — 双栏对比壳
- **身份**：A/B 面板标识发丝 + 中缝圆形调节柄（纯几何双向箭头）
- **配置**：`showControl` · `showFooter` · `syncScroll` · `controlHeight` · `footerHeight` · `divider`
- **信号**：`syncScrollToggled(bool enabled)` ｜ **函数**：`toggleSyncScroll()`
- **槽位**：`controlSlot` · `leftSlot` · `rightSlot` · `footerSlot` · `overlaySlot`
- **依赖**：Theme · Footer · Page · Separator

#### `NovaCardGrid` — 卡片网格壳
- **身份**：工具条抽象几何标识（筛选 / 视图切换）+ Flow 网格骨架
- **配置**：`showFilter` · `showFooter` · `filterHeight` · `footerHeight` · `padding`
- **槽位**：`filterSlot` · `gridSlot` · `footerSlot` · `overlaySlot`
- **依赖**：Theme · Footer · Separator ｜ **推荐注入**：`NovaCard`

### 浮层容器（2）

#### `NovaModal` — 模态弹窗壳
- **身份**：顶部三色渐变条 + 拖拽 catcher + 浮起阴影层
- **配置**：`open` · `dismissOnMask` · `showTitle` · `showActions` · `maxWidth` · `maxHeight` · `titleHeight` · `actionsHeight`
- **信号**：`closeRequested(string reason)`（`"escape"` / `"mask"` / `"button"`）｜ **函数**：`requestClose(reason)`
- **槽位**：`titleSlot` · `contentSlot` · `actionsSlot`
- **键盘**：`Esc` → `requestClose("escape")`；点遮罩 → `"mask"`；初始焦点自动落于卡片
- **层叠**：`NovaTheme.zFullscreen`
- **依赖**：Theme · Header · Page · Separator

#### `NovaDrawerPanel` — 侧边滑出面板壳
- **身份**：侧缘渐变轨 + 顶部 grabber 把手
- **配置**：`open` · `side`（`left`/`right`，逻辑侧）· `bySide`(ro, RTL 自动镜像) · `size` · `titleHeight` · `showTitle` · `showActions` · `actionsHeight` · `scrim`
- **信号**：`closeRequested()` ｜ **函数**：`requestClose()`
- **槽位**：`titleSlot` · `contentSlot` · `actionsSlot`
- **键盘**：`Esc` → `requestClose()`；初始焦点自动落于面板
- **层叠**：`NovaTheme.zFixedDrawer`
- **依赖**：Theme · Header · Page · Separator

### 独立页壳（2）

#### `NovaSetupWizard` — 安装配置向导壳
- **身份**：三态步骤时间轴（连接线 + 已完成进度线 + 圆点）+ 控制区按钮位
- **配置**：`currentStep` · `stepCount` · `showSteps` · `showFooter` · `stepsHeight` · `controlsHeight` · `footerHeight` · `canGoPrevious`(ro) · `canGoNext`(ro)
- **信号**：`previousRequested()` · `nextRequested()` · `stepSelected(int index)`
- **槽位**：`stepsSlot` · `contentSlot` · `controlsSlot` · `footerSlot` · `overlaySlot`
- **依赖**：Theme · Footer · Page · Separator · Motion

#### `NovaBlankPage` — 纯净单页壳
- **身份**：居中阅读栏（最大宽度约束）+ 极细居中发丝
- **配置**：`showHeader` · `showFooter` · `headerHeight` · `footerHeight` · `padding`
- **槽位**：`headerSlot` · `contentSlot` · `footerSlot` · `overlaySlot`
- **依赖**：Theme · Header · Footer · Page

### 多端根壳（3）

#### `NovaDesktop` — 桌面应用根壳
- **身份**：三色窗口控制点 + 分层菜单栏 / 工具栏 + 状态指示点
- **配置**：`showMenu` · `showToolbar` · `showStatus` · `menuHeight` · `toolbarHeight` · `statusHeight`
- **信号**：`windowCloseRequested()`
- **槽位**：`menuSlot` · `toolbarSlot` · `pageSlot` · `statusSlot` · `overlaySlot`
- **键盘**：`Esc` → `windowCloseRequested()`
- **层叠**：`overlaySlot` 取 `NovaTheme.zMax`；装饰层 `zMarginals` 提级，`toolbarSlot` 指向独立
  `_toolbarHost`，业务注入不与装饰层争位
- **依赖**：Theme · Footer · Page · Separator

#### `NovaMobile` — 移动应用根壳
- **身份**：灵动岛（居中胶囊 + 摄像头点）+ home indicator
- **配置**：`showHeader` · `showBottomNav` · `safeTop` · `safeBottom` · `headerHeight` · `bottomNavHeight` · `isTouch`(ro, `NovaPlatform.isMobile`)
- **信号**：`backRequested()`
- **槽位**：`headerSlot` · `contentSlot` · `bottomNavSlot` · `overlaySlot`
- **键盘**：`Back` → `backRequested()`
- **依赖**：Theme · Header · Page · Separator · Platform

#### `NovaFlexLayout` — 企业大屏弹性布局壳
- **身份**：`columns` 驱动的浮起面板网格 + 三色面板顶条（提级至 `zMarginals`）
- **配置**：`showHeader` · `showFooter` · `columns`（钳制 1~4）· `headerHeight` · `footerHeight` · `gap` · `scalable` · `_cols`(ro) · `_largeScreen`(ro)
- **信号**：`layoutChanged(int columns)`
- **槽位**：`headerSlot` · `contentSlot` · `footerSlot` · `overlaySlot`
- **依赖**：Theme · Header · Footer · Page · Screen

### AI 对话主窗口（1）

#### `NovaChat` — 六轨按轨分治主窗口
- **身份**：顶层三段品牌发丝线；**每条轨道各有独占且互不重复的前景签名**——
  导航轨（渐变徽记 / 三级激活图标位 / 账户锚 / 缘轨）、会话列（搜索胶囊 / 激活竖条 / 新建圆钮）、
  对话区（在线点 / 三点位 / 四角取景框）、输入区（浮起胶囊 / 附加十字 / 纯几何发送箭头）、
  详情栏（分段 tab / 缘轨）。签名只占边缘 / 角标，中央完全留给业务注入
- **配置**：`navSize` · `conversationSize` · `detailSize` · `headerHeight` · `composerHeight` ·
  `showNav` · `showConversation` · `showDetail` · `showHeader` · `showComposer` ·
  `navCollapsed` · `conversationCollapsed` · `detailCollapsed` · `breakpoint` · `bordered` · `belowBreakpoint`(ro)
- **信号**：`navToggled(bool collapsed)` · `conversationToggled(bool collapsed)` · `detailToggled(bool collapsed)`
  ｜ **函数**：`toggleNav()` · `toggleConversation()` · `toggleDetail()`
- **槽位**：`navSlot` · `conversationSlot` · `headerSlot` · `contentSlot` · `composerSlot` · `detailSlot` · `overlaySlot`
- **键盘**：`Esc` 对三条可折叠轨分别 emit 收起意图
- **RTL**：根节点 `LayoutMirroring.enabled: NovaTheme.isRtl`
- **气泡**：由业务向 `contentSlot` 注入 `NovaChatMessage`，Shell 不持有会话数据与提示词
- **浮层槽透明契约**：`overlaySlot` 位于 `zFixedDrawer` 顶层，业务注入须为透明 / 空 `Item`，
  注入铺满的不透明块会盖住整个组件（验收口径，非组件缺陷）
- **依赖**：Theme · Header · Footer · Page · Separator · Motion

### AI 智能组合根（3）

> 1.1.0 新增：以 NovaChat 为统一交互基座，三组件在「自主程度 × 责任归属 × 交付契约」三维分叉。
> 设计定义与 A1~A8 封版验收清单见联合方案 `docs/prescript/LAW_NovaAgent.md`
> 与三份独立企业级旗舰版封版法源 `docs/prescript/LAW_NovaAgent.md` / `NovaDE.md` / `NovaCopilot.md`。
> **治理语义（八项准入控制 / 四要件 / 确认闸门）全由业务槽位注入，Shell 只托管布局与折叠意图**。

#### `NovaAgent` — 智能体任务执行工作台
- **身份**：左任务列 DAG 三节点递减链 + 右缘主色渐变轨；执行画布对角取景框；审批闸门色带；验证轨三段递减级条——与 NovaDE / NovaCopilot 身份互不重复
- **配置**：`taskSize` · `verifySize` · `headerHeight` · `approvalHeight` · `showTask` · `showPlan` · `showVerify` · `showApproval` · `taskCollapsed` · `verifyCollapsed` · `breakpoint` · `bordered` · `belowBreakpoint`(ro)
- **信号**：`taskToggled(bool collapsed)` · `verifyToggled(bool collapsed)` · `approvalRequested()`
  ｜ **函数**：`toggleTask()` · `toggleVerify()` · `requestApproval()`
- **槽位**：`taskSlot` · `planSlot` · `contentSlot` · `verifySlot` · `approvalSlot` · `overlaySlot`
- **键盘**：`Esc` 对两条可折叠轨分别 emit 收起意图
- **RTL**：根节点 `LayoutMirroring.enabled: NovaTheme.isRtl`
- **治理边界**：八项准入控制（目的/数据/权限/审批/可观测/验证/异常/运营）与风险分级路由器由业务注入；审批闸门槽预留 HIGH 风险人工复核点；外部信号验证器独立于 Agent
- **依赖**：Theme · Header · Footer · Page · Separator · Motion

#### `NovaDE` — 数字员工岗位工作台
- **身份**：顶部岗位菱形徽记（旋转方形）；左队列分层堆叠卡沿 + 渐变缘轨；工作画布顶部双短条；SLA 轨递减条 + 状态点；交接条双向箭头——与 NovaAgent / NovaCopilot 身份互不重复
- **配置**：`queueSize` · `slaSize` · `roleHeight` · `handoffHeight` · `showQueue` · `showSla` · `showRole` · `showHandoff` · `queueCollapsed` · `slaCollapsed` · `breakpoint` · `bordered` · `belowBreakpoint`(ro)
- **信号**：`queueToggled(bool collapsed)` · `slaToggled(bool collapsed)` · `handoffRequested()`
  ｜ **函数**：`toggleQueue()` · `toggleSla()` · `requestHandoff()`
- **槽位**：`roleSlot` · `queueSlot` · `contentSlot` · `slaSlot` · `handoffSlot` · `overlaySlot`
- **键盘**：`Esc` 对两条可折叠轨分别 emit 收起意图
- **RTL**：根节点 `LayoutMirroring.enabled: NovaTheme.isRtl`
- **治理边界**：四要件（岗位形态 / 任务队列 / 能力调用 / 队伍级治理）由业务注入；岗位条与交接条预留 Auto/Draft/Handoff 边界；Shadow Mode / SSO+RBAC / 技能层共享为业务层职责
- **依赖**：Theme · Header · Footer · Page · Separator · Motion

#### `NovaCopilot` — 增强型协作面板
- **身份**：左建议列内联胶囊条 + 三段确认级条；内联建议条短条侧锚；工作画布对角取景框；动作闸门轨分隔渐变点 + 撤销弧环——与 NovaAgent / NovaDE 身份互不重复
- **配置**：`suggestSize` · `gateSize` · `inlineHeight` · `showSuggest` · `showInline` · `showGate` · `suggestCollapsed` · `gateCollapsed` · `breakpoint` · `bordered` · `belowBreakpoint`(ro)
- **信号**：`suggestToggled(bool collapsed)` · `gateToggled(bool collapsed)` · `actionProposed()`
  ｜ **函数**：`toggleSuggest()` · `toggleGate()` · `proposeAction()`
- **槽位**：`suggestSlot` · `inlineSlot` · `contentSlot` · `gateSlot` · `overlaySlot`（5 槽，`overlaySlot` 非必需但保留）
- **键盘**：`Esc` 对两条可折叠轨分别 emit 收起意图
- **RTL**：根节点 `LayoutMirroring.enabled: NovaTheme.isRtl`
- **治理边界**：建议—确认—执行契约由业务注入；闸门轨预留 Draft / Confirm / Read-Only 三模与撤销窗口；以用户身份 grounding / 规则引擎优先 / 动作可撤销可回溯为业务层职责
- **依赖**：Theme · Header · Page · Separator · Motion

### 意图轨道呈现层（1）

> 1.1.0 收官件（第 19 个组合根）：`NovaOrbit` 是 NovaChat 天花板形态、Agent / DE / Copilot 的
> 统一编排面与最终呈现层，也是 NovaIncubator 七件组件的呈现层收官件。
> 企业级旗舰版封版法源见 `docs/prescript/LAW_NovaOrbit.md`（零章无业务语义骨架 / O1~O8 /
> CC-1~CC-8 映射 / CARF 四阶段 / 封版声明）。
> **Orbit Engine / Entity Router / 孵化确认闸门 / 审计流全由业务槽位注入，Shell 只托管七槽布局与折叠意图**。

#### `NovaOrbit` — 意图轨道工作台
- **身份**：全局栏三段轨道发丝线；左栏递减轨道链 + 感知信号弧点；中栏并行分叉角标 + 对角取景框；右栏双向箭头环 + 拓扑点阵——与 NovaChat 六轨签名及三个 AI 组件身份互不重复
- **配置**：`railSize` · `canvasSize` · `globalHeight` · `composerHeight` · `mapHeight` · `showGlobal` · `showRail` · `showCanvas` · `showComposer` · `showMap` · `railCollapsed` · `canvasCollapsed` · `breakpoint` · `bordered` · `belowBreakpoint`(ro)
- **信号**：`railToggled(bool collapsed)` · `canvasToggled(bool collapsed)` · `orbitRequested()`
  ｜ **函数**：`toggleRail()` · `toggleCanvas()` · `requestOrbit()`
- **槽位**：`globalSlot` · `railSlot` · `intentSlot` · `composerSlot` · `canvasSlot` · `mapSlot` · `overlaySlot`（7 槽，`overlaySlot` 取 `NovaTheme.zFixedDrawer` 且业务注入须为透明顶层）
- **键盘**：`Esc` 对 rail / canvas 两条可折叠轨分别 emit 收起意图
- **RTL**：根节点 `LayoutMirroring.enabled: NovaTheme.isRtl`
- **治理边界**：孵化轨道须经用户一次显式确认方可转执行轨道（O5 硬边界）；壳零定时器、零自动拉起逻辑；引擎不可用时退化为可用会话基座（O8）
- **依赖**：Theme · Header · Footer · Page · Separator · Motion

### 应用孵化器工作台（1）

> 1.2.0 收官件（第 **20** 个组合根 / 本库最后一个组合组件）：`NovaIncubator` 是
> 诺瓦应用孵化器的**工作台壳**，把「选配方 → 注入业务 → 三重校验 → 一次封版」四阶段
> 孵化流水线呈现为无业务语义骨架。孵化系统本身仍居**方法论层**（Prescript 之上、CARF 之下，
> 不是普通运行时组件）；本组件是其在**组件层**的呈现载体，与 `NovaOrbit` 的处理同构。
> 企业级旗舰版封版法源见 `docs/prescript/LAW_NovaIncubator.md`（零章无业务语义骨架 /
> 法源张力消解 / I1~I8 / CC-1~CC-8 映射 / CARF 四阶段 / 封版声明）。
> **配方解释器 / 组件装配器 / 治理注入器 / 三重校验器 / 证书签发器 / CLI 孵化内核
> 全由业务槽位注入，Shell 只托管七槽布局与折叠意图，绝不自动封版、绝不自动执行**。

#### `NovaIncubator` — 应用孵化器工作台
- **身份**：全局栏四级递进楔形条；左栏五列配方栅 + 列尾七刻点；中栏七区分格环 + 中心孵化点；阶段条四节点收敛链；右栏三道递减校验刻线 + 收敛角；证书栏方章折角 + 封蜡点——与既有 19 项身份互不重复
- **配置**：`recipeSize` · `validateSize` · `globalHeight` · `pipelineHeight` · `certificateHeight` · `showGlobal` · `showRecipe` · `showValidate` · `showPipeline` · `showCertificate` · `recipeCollapsed` · `validateCollapsed` · `breakpoint` · `bordered` · `belowBreakpoint`(ro)
- **信号**：`recipeToggled(bool collapsed)` · `validateToggled(bool collapsed)` · `freezeRequested()`
  ｜ **函数**：`toggleRecipe()` · `toggleValidate()` · `requestFreeze()`
- **槽位**：`globalSlot` · `recipeSlot` · `stageSlot` · `pipelineSlot` · `validateSlot` · `certificateSlot` · `overlaySlot`（7 槽，`overlaySlot` 取 `NovaTheme.zFixedDrawer` 且业务注入须为透明顶层）
- **键盘**：`Esc` 对 recipe / validate 两条可折叠栏分别 emit 收起意图
- **RTL**：根节点 `LayoutMirroring.enabled: NovaTheme.isRtl`
- **治理边界**：封版须经宿主一次显式确认（I5 闸门不可绕过）；壳零定时器、零自动封版逻辑；孵化内核不可用时退化为可用工作台骨架（I8）
- **依赖**：Theme · Header · Footer · Page · Separator · Motion

### 智能报表工作台（1）

> 1.5.0 收官件（第 **21** 个组合根）：`NovaAIReport` 是铝电解 AI 报表的**工作台壳**，
> 把行业方案「对标 → 诊断 → 预测 → 问数 → 审批」的报表决策闭环呈现为无业务语义骨架。
> 行业方案原文（L1~L5 能力分层 / 语义层 / 归因 / 预测 / NL2SQL / Agent 编排 / 信任爬坡）
> 是 Python 智能层与业务层职责，按「无业务语义」铁律**不进 Shell**；本组件是其在组件层的
> 呈现载体，与 `NovaOrbit` / `NovaIncubator` 处理同构。完整转译与使用见
> `docs/controls/NovaAIReport.md`。**参数语义层 / 归因引擎 / 预测模型 / 问数映射 / Agent 编排
> 全由业务槽位注入，Shell 只托管七槽布局与折叠意图，绝不自动执行、绝不硬编码第二份参数口径**。

#### `NovaAIReport` — 智能报表工作台
- **身份**：对标带四级基准游标尺（主轴 + 三档刻 + 偏差游标）；左栏因果鱼骨（竖干 + 三对斜枝）；中栏行列刻度尺（横纵轴 + 行列刻点）；预测带置信区间带（主轴 + 上下界 + 中心点）；右栏问数双点（双实心方点 + 连接线）；审批栏闸门横闩（双立柱 + 横闩 + 缺口）；顶层单色系递进发丝——与既有 20 项身份互不重复
- **配置**：`diagnosisSize` · `querySize` · `benchmarkHeight` · `forecastHeight` · `approvalHeight` · `showBenchmark` · `showDiagnosis` · `showForecast` · `showQuery` · `showApproval` · `diagnosisCollapsed` · `queryCollapsed` · `breakpoint` · `bordered` · `belowBreakpoint`(ro)
- **信号**：`diagnosisToggled(bool collapsed)` · `queryToggled(bool collapsed)` · `approvalRequested()`
  ｜ **函数**：`toggleDiagnosis()` · `toggleQuery()` · `requestApproval()`
- **槽位**：`benchmarkSlot` · `diagnosisSlot` · `reportSlot` · `forecastSlot` · `querySlot` · `approvalSlot` · `overlaySlot`（7 槽，`overlaySlot` 取 `NovaTheme.zFixedDrawer` 且业务注入须为透明顶层；`reportSlot` 推荐注入 `NovaDataGrid`）
- **键盘**：`Esc` 对 diagnosis / query 两条可折叠轨分别 emit 收起意图
- **RTL**：根节点 `LayoutMirroring.enabled: NovaTheme.isRtl`
- **治理边界**：审批闸门是业务层的「建议→人工确认→回写」呈现位；壳零定时器、零自动执行逻辑；默认人工确认，自动执行（L5-C）属业务层在审计合规下的可选扩展
- **依赖**：Theme · Header · Footer · Page · Separator · Motion（推荐注入 `NovaDataGrid` 承载主报表区）

---

## 四、最小使用示例

```qml
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
        // 受控契约：宿主收到意图后自行决定是否修改 sidebarCollapsed
        onSidebarToggled: function(collapsed) { sidebarCollapsed = collapsed }

        sidebarSlot: NovaText { text: "导航由业务注入" }
        contentSlot: Rectangle { color: NovaTheme.page }
        footerSlot: NovaText { text: "Powered by pyside-nova" }
    }
}
```

> 真实可执行示例（无 `title` 属性、无 `NovaLabel`、无 `Theme.*`）。
> 更多骨架见 `examples/layout_shell/<snake_case>/main.qml`（21 个独立演示），
> 逐项调参见 `examples/gallery/layout_shells.qml`（Gallery 21 页）。

---

## 五、验收状态（1.2.0）

| 门禁 | 结果 |
|---|---|
| 静态门禁 `check_all.py --tier static` | **3/3 PASS**（a11y → API 冻结 → qmllint） |
| API 冻结 | **144 类型零漂移** · `68b34a408489b6a8`（1.2.0 整批单次重签，15 项 GA 签名逐字不变 + 5 项新增） |
| a11y 契约 | **144/144**（interactive 32 · semantic 28 · decorative 84） |
| qmllint | **0 error**，warning 在 `tests/lint-baseline.json` 预算内 |
| 专项测试 `test_api_freeze.py` + `test_layout_shells.py` | **53/53** |
| 无头实例化 | **41/41**（20 组件 + Gallery + 20 演示，待机检复验） |
| 槽位挂载 | 6/6（`NovaChat` 六槽 + 浮层）+ 三 AI 组件 6+6+5 槽 + `NovaOrbit` 7 槽 + `NovaIncubator` 7 槽 |

**封版资格由 API 冻结门禁授予**，本文档为交付物记录，不自行宣称封版。
视觉与工程打磨（身份差异化 / 多轨分治 / 动效令牌化 / 键盘可达 / 宿主隔离）全属 `_` 私有
PATCH 实现变更，**公共 API 签名逐字不变、指纹不变**。

---

## 六、维护纪律

1. **生成物禁止手改**：`api/nova-api-1.2.0.json` / `docs/COMPONENT_LIST.md` / `A11Y_MATRIX.md` /
   `docs/ai/api/*.json` 只改生成器或重跑生成器；
2. **批量单次重签**：新增 / 改名 Shell 须整批登记、单次重签，禁止产生中间指纹；
3. **PATCH 自由、MAJOR 谨慎**：`_` 私有实现可自由重构；公共签名变更须走主版本并附迁移说明；
4. **两行头注释**：第 1 行 `src/` 起完整子路径，第 2 行定位说明，禁止日期流水；
5. **a11y**：容器根标 `// a11y: decorative`，不挂 `Accessible.*`；纯几何装饰逐块标注；
6. **动效**：一律 `NovaMotion.duration(NovaMotion.transitionDuration)` +
   `NovaMotion.easingStandard`，禁止散落 `duration: 240`；
7. **槽位宿主隔离**：装饰层与业务注入层分离，装饰用 `NovaTheme.z*` 提级；
8. **槽位内容基线（宪法 0.9.0 CC-6）**：`xxxSlot` 注入的顶层 `Item` 默认 0×0，
   **必须显式 `anchors.fill: parent`**，否则内部 anchors 算出负宽高被裁（中央空板）；
   消息流 / 输入区等长内容须限宽居中，避免宽屏被拉成超长条。

> 本模块 README 是《Prescient Layout Shell 封版规范 v2.1.0》第 9 章「入库交付物清单」的
> 集中承载形式（单一模块平铺，不按组件拆子目录——宪法 0.3.0）。技术红线以封版规范与
> 组合组件宪法为准；成熟度以 `docs/COMPONENT_LIST.md` 为准。
>
> **0.8.1 四性全库回扫已过**：装饰实心度 ≥0.85（15/15）、声明式 RTL（15/15）、几何入参
> `_` 私有钳制（39 属性 / 54 引用）、身份装饰 `zMarginals` 提级（17 处）；15/15 极端
> 非法入参稳态几何非负、双主题实心注入渲染 PASS、`reducedMotion` 短路 PASS。全为
> `_` 私有 PATCH，公共 API 与指纹零漂移。

> **0.9.0 组合态一致性契约已落地（NovaChat 首例）**：第 9 章 CC-1~CC-8 定义 L1 装配层；
> 本模块 `NovaChat.qml` 已用 13 个 `_` 私有组合上下文常量统一六轨密度 / 层级 / 动效，
> 边界收敛为唯一分隔源、装饰改抽象几何、折叠锚链恒定；独立演示改为成品 showcase
> （六槽真实业务注入、调参面板默认收起、消息与输入限宽居中）。浅色 / 深色 / 折叠
> 三态渲染审计通过、QML 零错误、公共 API 与指纹 `bfd3d938a2fab7be` 零漂移。

> **0.9.1 CC 迁移批次 2 已落地（3 项销号）**：`NovaDesktop` / `NovaMobile` /
> `NovaFlexLayout` 逐项完成 CC-1~CC-8——三元锚链改「栏高归零 + 恒定锚链 + 同步动效」、
> 三色撞色与伪控件收敛主色系抽象几何、槽位宿主独立铺满（注入顶层一律
> `anchors.fill: parent`）、独立演示改成品级 showcase 且调参面板默认收起。
> 深色装配态审计反向修复 `NovaMobile` 灵动岛可见性。12 张三态渲染审计图全通过、
> 静态 3/3、专项 48/48、31/31 实例化、极端非法入参 0 负几何、RTL 4/4、
> 指纹 `bfd3d938a2fab7be` 不变。逐项台账见 `docs/prescript/AUDIT_CEILING.md`（**4/15**）。
