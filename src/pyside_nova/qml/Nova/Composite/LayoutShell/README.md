# Nova.Composite.LayoutShell · 模块交付文档

> **第五 QML 模块｜15 项组合根容器（Prescient Layout Shell）｜1.0.0 GA 已封版**
>
> 模块 URI：`Nova.Composite.LayoutShell` · 注册文件：`qmldir` · 15 项全部为冻结公共类型
> API 冻结指纹：`bfd3d938a2fab7be`（139 类型零漂移）

| 项目 | 内容 |
|---|---|
| **法源** | `docs/CONSTITUTION.md`（母法）· `docs/COMPOSITION_CONSTITUTION.md`（组合组件宪法 0.8.0）· `docs/white_paper/Prescient-LayoutShell-封版规范.md`（技术红线 v2.0.0） |
| **权威事实源** | `docs/COMPONENT_LIST.md` + `api/nova-api-1.0.0.json`（均为生成器产物，禁止手改） |
| **性质** | 无业务语义的复合根容器骨架；填业务即交付 |
| **状态** | ✅ 15/15 已封版 · Gallery 15 页独立预览 · 15 个独立演示 · 静态门禁 3/3 |

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

### 2.2 15 项依赖矩阵

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

### 2.3 推荐业务注入类型（非 Shell 内实例化）

| 类型 | 模块 | 建议用途 |
|---|---|---|
| `NovaCard` | `Nova.Controls` | 由业务注入 `NovaCardGrid.gridSlot` 的卡片 |
| `NovaChatMessage` | `Nova.Controls` | 由业务注入 `NovaChat.contentSlot` 的对话气泡 |
| `NovaBtn` / `NovaText` / `NovaMenu` 等 | `Nova.Controls` | 由业务注入任意槽位的交互与展示内容 |

> **D-013 合规边界**：15 项的独有身份元素是 `_` 私有**纯几何装饰**（`Rectangle` / `Gradient` /
> `Row` / `Repeater`），不构成可交互控件、不复制原子样式、不绕过令牌、不含字体依赖——
> **不违反**"禁止私造原子"基线。

---

## 三、15 项完整契约

> 下表属性均为**公开配置 / 只读派生属性**；`_` 前缀私有成员不进冻结面，不在此列。
> 机器可读完整签名见 `api/nova-api-1.0.0.json` 与 `docs/COMPONENT_LIST.md`。

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
- **身份**：工具条胶囊占位（筛选 / 视图切换）+ Flow 网格骨架
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
> 更多骨架见 `examples/layout_shell/<snake_case>/main.qml`（15 个独立演示），
> 逐项调参见 `examples/gallery/layout_shells.qml`（Gallery 15 页）。

---

## 五、验收状态（1.0.0 GA）

| 门禁 | 结果 |
|---|---|
| 静态门禁 `check_all.py --tier static` | **3/3 PASS**（a11y → API 冻结 → qmllint） |
| API 冻结 | **139 类型零漂移** · `bfd3d938a2fab7be` |
| a11y 契约 | **139/139**（interactive 32 · semantic 28 · decorative 79） |
| qmllint | **0 error**，warning 在 `tests/lint-baseline.json` 预算内 |
| 专项测试 `test_api_freeze.py` + `test_layout_shells.py` | **48/48** |
| 无头实例化 | **31/31**（15 组件 + Gallery + 15 演示） |
| 槽位挂载 | 7/7（`NovaChat` 六槽 + 浮层） |

**封版资格由 API 冻结门禁授予**，本文档为交付物记录，不自行宣称封版。
视觉与工程打磨（身份差异化 / 多轨分治 / 动效令牌化 / 键盘可达 / 宿主隔离）全属 `_` 私有
PATCH 实现变更，**公共 API 签名逐字不变、指纹不变**。

---

## 六、维护纪律

1. **生成物禁止手改**：`api/nova-api-1.0.0.json` / `docs/COMPONENT_LIST.md` / `A11Y_MATRIX.md` /
   `docs/ai/api/*.json` 只改生成器或重跑生成器；
2. **批量单次重签**：新增 / 改名 Shell 须整批登记、单次重签，禁止产生中间指纹；
3. **PATCH 自由、MAJOR 谨慎**：`_` 私有实现可自由重构；公共签名变更须走主版本并附迁移说明；
4. **两行头注释**：第 1 行 `src/` 起完整子路径，第 2 行定位说明，禁止日期流水；
5. **a11y**：容器根标 `// a11y: decorative`，不挂 `Accessible.*`；纯几何装饰逐块标注；
6. **动效**：一律 `NovaMotion.duration(NovaMotion.transitionDuration)` +
   `NovaMotion.easingStandard`，禁止散落 `duration: 240`；
7. **槽位宿主隔离**：装饰层与业务注入层分离，装饰用 `NovaTheme.z*` 提级。

> 本模块 README 是《Prescient Layout Shell 封版规范 v2.0.0》第 9 章「入库交付物清单」的
> 集中承载形式（单一模块平铺，不按组件拆子目录——宪法 0.3.0）。技术红线以封版规范与
> 组合组件宪法为准；成熟度以 `docs/COMPONENT_LIST.md` 为准。
