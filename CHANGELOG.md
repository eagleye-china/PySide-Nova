# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [0.7.0] - 2026-11-22

### Added（一期 Sprint 3 · **L3 行为层九件一次收口**：L3 11% → 100%）

- **NovaIntersectionPool 共享观察池**（L3 基础设施，对标 2.30 共享 IntersectionObserver 池架构）：
  - 一个 Timer（pollInterval 34ms ≈ 30fps）驱动全部订阅者批量求值，N 个行为共享唯一驱动源；
    无订阅时零开销；`add/remove/clear/kick/tick` + `viewport()/nearestScrollable()/scrollPosition()/intersect()`
    公共几何工具
  - 实现路径差异（如实记录）：基线走浏览器原生 IntersectionObserver（异步、阈值边界通知），
    Nova 走"帧轮询 + 自算矩形交集（含祖先 clip 链）"——比例是精确值
- **NovaIntersection**（对标 v-intersection，Intersection.json 核实）：handler → `onIntersect/entered/exited`
  三信号；threshold 数字/数组；rootMargin 四向 real；once + `rearm()`（对标 setOnce 再武装）；
  `stop()`（对标 handler 返回 false）；entry 七字段 1:1（target/isIntersecting/intersectionRatio/
  boundingClientRect/intersectionRect/rootBounds/time）；祖先 clip 链计入可见区域
- **NovaScrollObserver**（对标 v-scroll）：`onScroll(details)` 给出 vertical/horizontal/deltaX/Y/
  direction/atTop/atBottom/atLeft/atRight；root 自动解析最近可滚动祖先（Flickable/ListView/GridView）
- **NovaScrollFire**（对标 v-scroll-fire）：进入视口触发一次（复用 NovaIntersection，同池同算法）；
  threshold 0~1（arg 语义）；触发后自动解除武装，`rearm()` 可再触发
- **NovaClosePopup**（对标 v-close-popup，ClosePopup.json 核实）：depth 语义 1:1（<0 全关 / 0 禁用 /
  N 关顶 N 层）；触发源自动桥接宿主 clicked 信号（向上找带 clicked 的祖先，NovaBtn 子项转交
  contentHost 也能命中）；`usePointer` 兜底指针通道；Enter 键触发（对标 keyup 13）
- **NovaOverlayHost 弹层栈**（Nova 增强，对标 portal 链 + closePortals）：
  `registerPopup/unregisterPopup/popupCount/popups/closePopups(depth, reason)/topPopup`；
  **NovaDialog 已接入**（show 进栈、_forget 出栈），ClosePopup 的"层"因此有真实语义
- **NovaTouchPan**（对标 v-touch-pan，TouchPan.json 核实）：details 十一字段 1:1（evt/touch/mouse/
  position/direction/isFirst/isFinal/duration/distance/offset/delta）；修饰 horizontal/vertical/
  up/right/down/left → `horizontal/vertical/directions`；mouseAllDir → `allDirections`；
  preserveCursor → `preserveCursor`；stop/prevent → `stopPropagation/preventStealing`
- **NovaTouchSwipe**（对标 v-touch-swipe）：arg "6e-2:6:50" → `minVelocity/touchMinDistance/
  mouseMinDistance` 三属性；移动中即触发 + 松手兜底；direction/duration/distance/velocity
- **NovaTouchHold**（对标 v-touch-hold）：arg "600:5:7" → `duration/touchSensitivity/
  mouseSensitivity`；位移超灵敏度取消 + `onCancel` 通知（增强）；`progress` 进度源 `holding`
- **NovaTouchRepeat**（对标 v-touch-repeat）：delays 序列 "0:600:300"（末值复用、0 延迟防自旋）；
  details 九字段含 keyboard/keyCode/repeatCount/startTime；`keys` 数组接键盘（默认 Space/Enter）
- 内核 **NovaTouchCore**（internal）：四个 touch 行为共享同一套指针生命周期/坐标/时间/阈值/
  触摸来源判定（MultiPointTouchArea 探测真实触摸 + MouseArea 合成事件），避免四份实现各自漂移
- 画廊第 13 页"L3 行为指令"：懒加载（ScrollFire 触发变色 + Intersection 比例实时显示）、
  滚动位置/方向/到底、拖动方块（松手回弹）、四向划动、长按 600ms、按住连发、
  弹层栈按层关闭 + 对话框内容内真实 ClosePopup 关闭按钮
- 冒烟测试 91 → **114 项全绿**（新增 23：九件实例化 10 + Intersection 4 + Scroll 2 +
  Touch 4 + ClosePopup/弹层栈 3）

### Fixed（Qt 6.12 / PySide6 实战坑位沉淀）

- **Item 的 FINAL 属性不可覆盖**：QML 派生 Item 里声明 `property real x/y`、`property bool active`
  报 "Cannot override FINAL property"（x/y/active 是 Qt 6.12 的 FINAL 成员）——
  行为层改用 posX/posY/gesturing；`enabled` 同理不重声明，直接用 Item.enabled（继承语义天然正确）
- **visible:false 的 Item 不参与事件分发**：行为根节点若设 visible:false，内部 MouseArea 彻底失灵——
  纯逻辑行为可关，带指针通道的行为绝不能关（Item 无 visual 本就不渲染，无需隐藏）
- **组件默认属性转交内部容器**：NovaBtn 把子项塞进 contentHost，子项的 `parent` 不是按钮本体，
  `target: parent` 拿不到 clicked 信号 → ClosePopup 向上遍历找第一个带 clicked 的祖先
- **QML Window 的 Python wrapper 调不到 QML 函数**：PySide 把 QQuickWindow 包装成 QWindow
  （metaobject 里没有 QML 定义的方法）——测试用 QML 侧 QtObject 代理（call0/1/2 + val）统一调用，
  代理同时强引用窗口防 JS GC 回收
- **观察器重订阅必须重交付**：IntersectionObserver 只报"变化"，重新 observe 才会补一帧
  当前状态——`_start()` 时重置上次判定，否则 rearm 后永远等不到回调（基线 reobserve 同款注释）
- **QML 函数无可选参数**：Qt 6 的 QML 函数按固定形参暴露给 PySide（缺参即 TypeError）——
  代理拆成 call0/call1/call2 按实参个数分派

## [0.6.2] - 2026-11-22

### Added（一期 Sprint 2 收口 · **一次交付四件**：NovaLoading / NovaStorage / NovaApp / NovaPlatform —— L4 12% → 44%）

- **NovaRuntime Python 后端**（独立模块 `Nova.Runtime`，C++ 侧注册）：
  - ini 存储后端：QSettings 文件级落盘（`AppDataLocation/nova-storage.ini`），
    **不依赖 organizationName**（纯 QML 的 Settings 类型在无 org 标识时直接失效，故下沉 Python）
  - 平台探测：os / osVersion（prettyProductName）/ cpuArch / kernelType / isMobile /
    hasTouchscreen（QInputDevice 枚举 TouchScreen，Qt 6 无 QML 级 API）
- **NovaLoading**（对标 Loading 插件，npm 2.35.5 `dist/api/Loading.json` 逐项核实 **11 项**）：
  - 配置：delay / message / group / spinnerSize / spinnerColor→spinnerTint / messageColor→messageTint /
    backgroundColor→backgroundTint / spinner→spinnerModel（ring/dots/pulse）✅；html / boxClass / customClass ⛔（留痕，boxed 布尔映射）
  - **引用计数（Nova 增强）**：同组并发 show 不互踩，句柄 `hide()` 只释放自己那一份，归零才收口；
    `hide(group)` 对标基线语义 = 无视计数整组强杀
  - delay 防闪烁（默认 500，对标基线）；delay 窗口内 hide 从未显示即销毁
  - `target` 局部加载（挂任意 Item 内铺满）/ `timeout` 卡死兜底（默认关）/
    `increment / decrement / count / activeGroups / activeCount / isActive / hideAll / setDefaults` 内省面
  - 视觉层 `NovaLoadingOverlay`（internal）：Canvas 圆环（底环 16% + 270° 弧）、三点缩放、呼吸圆；
    明暗双主题遮罩自适应；句柄 `NovaLoadingHandle`（hide/update/valid/count/item）
- **NovaStorage**（对标 LocalStorage 插件）：
  - 全 API 面：`set/get/has/remove/clear/getAll/getAllKeys/getLength/isEmpty/setAll`
    + Web Storage 别名 `setItem/getItem/removeItem`
  - **命名空间隔离（Nova 增强）**：`useNamespace(name)` 切换即落盘旧空间、加载新空间
  - 真持久化：写入后由全新 QSettings 实例读回验证（测试 `test_storage_persistence_to_disk`）
  - JSON 损坏安全降级（按空空间载入不崩）；getAll 深拷贝防外部改库
- **NovaApp**（对标 AppFullscreen + AppVisibility + Meta）：
  - `request/exit/toggle/isFullscreen/isCapable`（全屏三件套 1:1）；
    `setVisibility` 统一入口：fullscreen/maximized/minimized/windowed；
    退出全屏自动回落进入前状态；`setTitle`（document.title → 窗口 title）；`show/hide/isVisible/isActive`
- **NovaPlatform**（对标 Platform 插件）：
  - `isWindows/isMac/isLinux/isAndroid/isIOS/isWasm/isMobile/isDesktop`；
    `hasTouch` 走后端输入设备枚举（桌面触摸本真实可得）；浏览器专属项
    （webAuthn/within.iframe/pwa/electron/内核判定）⛔ 不适用留痕
  - Nova 增强：`osVersion / cpuArch / describe() / snapshot()`
- 画廊第 12 页 "**Loading / Storage**"：全屏加载自动收口、引用计数 ±1 演示、局部加载、
  三种 spinner、Storage 读写/清空快照、窗口控制、平台信息（全程真实组件可交互）
- 冒烟测试 71 → **91 项全绿**（新增 20 项：Loading 10 + Storage 7 + Platform 1 + App 2）

### Fixed（Qt 6.12 / PySide6 实战坑位沉淀）

- **qmlRegisterSingletonInstance 所有权坑**：QML 树按 JS 所有权管理实例，组件销毁即 delete
  Python 侧对象，二次访问报 "Internal C++ object already deleted"；且全局单实例无法被多个
  QQmlEngine 安全共享 → 改用**工厂式 `qmlRegisterSingletonType`**（每引擎惰性创建，PySide 不留悬空引用）
- **单例引用裸 JS 对象无属性通知**：Loading 的活动组条目最初用裸 JS 对象，句柄 valid/count 绑定
  不随状态刷新 → 升级为 QML QtObject 条目（property Component 内联，Qt 6.12 坑位惯例）
- **overlay 可见性与宿主冲突**：NovaOverlayHost.attach 强制 visible=true，与 Loading 的
  delay 门控打架 → 可见性改由内部 `_started` 门控（delay 期间子项不渲染、遮罩不拦点击）

## [0.6.1] - 2026-11-22

### Added（一期 Sprint 2 · L4 服务层第二件：NovaDialog）

- **NovaDialog 命令式对话框**（对标 Dialog 插件，npm 2.35.5 `dist/api/Dialog.json` 逐项核实 **27 项**）：
  - `show(opts)` → 链式句柄 `NovaDialogHandle`：`hide()` / `update()` / `ok()` / `cancel()` / `valid`
  - 三个信号：`accepted` / `rejected` / `dismissed(reason)`（reason 五值 ok/cancel/backdrop/escape/api）
  - 五向定位 standard/top/right/bottom/left；非法值直接拒绝
  - 关闭策略三档：`persistent` / `noEscDismiss` / `noBackdropDismiss`
  - 形态：`seamless` / `maximized` / `fullWidth` / `fullHeight` / 进度态
  - 按钮三态归一（true/false/string/对象）+ `stackButtons`
  - `contentDelegate` 替代基线 `html`；`setDefaults()` 深合并；`count()`/`hideAll()` 内省
- 画廊新增"NovaDialog 对话框"页：基础/危险/仅确定、persistent/seamless/全宽/最大化、
  五向定位、进度态 + 句柄 update 收尾、自定义内容（TextField）
- 冒烟测试 63 → **71 项全绿**（新增 8 项：ok/cancel 原因、persistent 双锁、noBackdrop/noEsc 分离、
  setDefaults+update、五向定位、seamless/progress/dark、链式回调、hideAll）

### Notes

- **归属纪律再确认**：`dismissed(reason)` 在 Dialog/BottomSheet 是基线 2.28 真 parity；
  在 Notify 是 Nova 增强——两处已分栏标注，防止再混
- 基线 DOM 专属项（class/style/html/noRouteDismiss）⛔ 留痕不移植；prompt/options/component 标 🚧 待二期

## [0.6.0] - 2026-11-22

### Added（一期 Sprint 2 · L4 服务层第一件：NovaNotify + NovaOverlayHost —— 七层 L4 从 0% 到 6%）

- **NovaOverlayHost**（全局弹层宿主单例）：动态 Item 挂载窗口顶层 + 层叠分配；
  自动跟随 `NovaScreen.source` 定位窗口（Window.contentItem / Item.window 双路解析），
  Dialog/Loading 直接复用，不再各自造宿主
- **NovaTheme 层叠令牌族入册**：`zFab 990 / zSide 1000 / zMarginals 2000 / zFixedDrawer 3000 /
  zFullscreen 6000 / zMenu 6000 / zTop 7000 / zTooltip 9000 / zNotify 9500 / zMax 9998`
  （对标 Quasar `$z-*` 数值 1:1，宪法第 5 章补充条款：弹层 z 值禁止魔法数值）
- **NovaNotify**（L4，对标 Notify 插件）：29 项配置逐项对账（npm quasar@2.35.5 包内源码 +
  dist/api/Notify.json 核实）；9 位定位（top 系头插 / bottom 系尾插 / 侧向中线插入）；
  分组徽标（组键 message|caption|multiLine|label*icon…|position 逐条复刻）；动作按钮
  （NovaNotifyAction：triggered 信号 + handler 回调双通道）；超时进度条（时长 = timeout+1000
  与消失时刻对齐）；句柄 `NovaNotifyHandle`（dismiss / update / valid）
- **Nova 增强（PARITY 增强栏）**：`dismissed(reason)` 6 值 timeout/user/action/api/replaced/overflow；
  `maxVisible`（默认 5，同屏上限）；`countAt()/dismissAll()` 队列内省；`triggerAction(i)` 程序化触发
- **NovaNotifyAction / NovaNotifyHandle** 公开导出；`NovaNotificationItem` 内部导出（internal）
- 画廊新增"**NovaNotify 通知**"页（类型预设 / 9 位定位 / 动作与关闭原因 / 分组徽标 / 句柄
  ongoing 进度更新，全程真实组件可交互）；Demo 页新增通知卡片区
- 冒烟测试 46 → **63 项**（解析用例 + 行为级断言：分组徽标/组键含 actions/自定义组替换/
  更新语义拒绝与放行/动作点击顺序/closeBtn user/overflow 淘汰/timeout 到期/非法输入回落/Dark 实例化）

### Changed

- **方法论入册执行首例**：API 对账以 npm 包源码与 dist API JSON 为准（0.5.1 新颁纪律）——
  本轮实机核对发现 npm 当日最新 2.35.6 的 Notify 与 2.35.5 逐字节相同，基线无需返工
- 库存契约文档（资料库）同步落定：D1/D2/D6 采纳、D3 红线确认、D4 内置最小转圈、D5 不暴露 ignoreDefaults

### Fixed

- 0.4.2 审计归属二次澄清落地：PARITY 增补 NovaNotify 审计节，"关闭原因上报"在 Notify 上
  明确标为 Nova 增强（基线 `onDismiss()` 无参数），杜绝后续误打勾

## [0.5.1] - 2026-11-22

### Changed（NovaNotify 契约裁定落盘 —— 新会话 npm 源码级核对成果固化）

- **D1 采纳**：NovaNotify 做 Nova 增强 `dismissed(reason)`（5 值
  timeout/user/action/api/replaced），PARITY 标"增强"栏，**不入已对齐栏**
- **D2 采纳**：`html` 不移植（QML 无 DOM 且基线该选项自带 XSS 面），改 `contentDelegate`
- **D3 确认**：基线 `onDismiss` 撞 on\* 红线，改为信号 `dismissed`，无商量余地
- **D6 采纳**：`NovaOverlayHost` 宿主抽件**提前至 Sprint 2**（overlay 层叠令牌 + 位置栈
  9 位插入先跑通，避免 Sprint 3 Dialog 位置栈返工）
- 归属修正：`关闭原因上报` 仅属 Dialog/BottomSheet（2.28）；**Notify 无关闭原因**
  （npm 2.35.5 源码核实 `onDismiss()` 无参数），0.4.2 审计表补澄清注
- 基线快照：npm 当日最新 2.35.6，其 Notify 与 2.35.5 逐字节相同，无需返工
- 修正 MASTER_PLAN 笔误："NovaDialog 服务式 v0.6.0 已交付" → "服务式 API 于 Sprint 2 交付"
- 方法论入册：**API 对账以 npm 包源码/dist API JSON 为准，不按文档页凭记忆写**
  （文档页漏 `ignoreDefaults` 即为例证）

## [0.5.0] - 2026-11-22

### Added（一期 Sprint 1 · L1 布局系统 —— 生态七层 L1 从 0% 到 100%）

- **布局五件套**（L1，对标 QLayout 系列）：
  `NovaLayout`（四象限骨架，子项按类型自动归位，push/overlay 双模式 + 断点自动收起）、
  `NovaHeader`（顶栏，tint + 默认槽）、`NovaFooter`（底栏）、
  `NovaDrawer`（left/right、mini 悬停展开、overlay、breakpoint、bordered、宽度动画）、
  `NovaPage`（页面容器 + padding）
- **栅格三件套**（L5/L1，对标 Quasar Flex 栅格）：
  `NovaRow`（12 栅格水平排布、wrap 换行、justify/align 对齐）、
  `NovaCol`（cols 1~12、offset 推挤、gutter）、
  `NovaVisible`（above/below/only 断点显隐，对标 gt-*/lt-*/*-only 工具类）
- 画廊新增"**NovaLayout 布局**"页：6 种经典布局迷你示例（后台/看板/表单/详情/登录/空态），全部真实组件可交互
- 冒烟测试 32 → **46 项**（新增四象限归位/push 让位/断点自动收起/栅格数学/NovaVisible 语义等行为级断言）

### Changed

- `NovaLayout.pageArea` 只读暴露页面区引用；`drawerOpen` / `openDrawer()` / `closeDrawer()` / `toggleDrawer()` 抽屉控制 API
- PARITY 新增布局五件套 + 栅格三件套审计节（基线 2.35.5）；reveal/elevated/断点响应式 cols 等 🚧 项如实标注 M2

### Notes

- 断点收起策略由宿主 NovaLayout 执行（NovaDrawer 创建期 parent 宽度是瞬态值，不可自判）——已沉淀为坑位经验
- 距宪法 24 条封版验收：L1 布局层达成 100%，L5 可见性/栅格从 0% 起步覆盖

## [0.4.2] - 2026-11-22

### Fixed（基线漂移纠正 —— 用户截屏立功）

- **对标基线 2.26.0 → 2.35.5**：经官方 GitHub releases 复核（v2.35.5 发布于 2026-11-17），
  原 0.4.0"核实"的 2.26.0 为过期结果；宪法第 0 章新增**基线复核条款**：
  每期开工第一天必须先核对官方最新 release
- `ECOSYSTEM_PARITY.md` 新增 §0.5 基线漂移审计（2.26→2.35 增量对照表）：
  Quasar 无新增组件（对账 76 项不变），生态层 6 类增量全部落入 MASTER_PLAN

### Changed（增量审计落入各期 DoD）

- 一期 Sprint 1：NovaScreen 补 `orientation`（对标 2.35 Screen API）
- 一期 Sprint 3：NovaIntersection 采用**单例 observer 池**（对标 2.30 useIntersection 复用架构）
- 二期：NovaSelect 补 hover 契约 / no-option-label / dialog 关闭按钮（对标 2.26~2.28）
- 四期：NovaFab 补 stagger 级联 + hover 打开；NovaPullToRefresh 补 side 四边拉动；
  NovaDialog/NovaBottomSheet 补**关闭原因上报**（cancel/backdrop/escape/programmatic，对标 2.28）
- 五期：**新增 L6 项"Nova MCP server + AI-ready 离线文档"**（对标 2.33 @quasar/mcp 全新品类，
  AI agent 精确查询版本化 API，杜绝幻觉）；供应链门禁补外部输入消毒（对标 2.32~2.35 安全硬化）

## [0.4.1] - 2026-11-21

### Added（全生态开发总规划 —— 六期战略图）

- **`docs/MASTER_PLAN.md`**：全生态开发总规划，覆盖 Quasar 2.26.0 全生态（组件 76 项 /
  指令 11 项 / 插件 15 项 / 图标 8 套 / 工具 / 工程化），分 **六期** 稳步推进：
  一期生态骨架（0.5.0~0.8.0）→ 二期表单与选择（0.9.0~0.10.0）→ 三期数据与媒体
  （0.11.0~0.12.0）→ 四期导航弹层反馈（0.13.0~0.14.0）→ 五期长尾+非功能（0.15.0~0.16.0）
  → 六期封版 `1.0.0-flagship`；总周期约 28 周（单人节奏含缓冲）
- 每期含：生态层归属、逐组件关键能力表、**冒烟测试验收标准**、测试数量轨迹
  （32 → 240+，封版覆盖率 ≥85%）
- **冒烟测试纪律制度化**（规划第 7 节）：七条统一模板，每个 Sprint 交付时逐条执行
- **全量对账表**（规划第 8 节）：Quasar 全生态 → Nova 命名 → 归属期，覆盖率对账
  组件 76/76、指令 11/11、插件 15/15（含 ⛔ 不适用留痕：AddressbarColor/Cookies/v-mutation）
- 风险对策表：NovaDate 自研日历、NovaTable 复杂度拆两次交付、单人节奏波动等

### Changed

- ROADMAP 增加指向 MASTER_PLAN 的入口说明（总规划为准，路线图保留 P0/P1/P2 分级视角）

## [0.4.0] - 2026-11-21

### Added（生态完整性 —— 封版前最后一块拼图）

- **`docs/ECOSYSTEM_PARITY.md` 生态对标白皮书**：以七层模型（L0 设计语言 / L1 布局 /
  L2 组件 / L3 指令 / L4 插件·服务 / L5 工具层 / L6 工程化）审计 Quasar 2.26.0 全生态，
  给出各层成熟度评分（当前 60%/0%/10%/11%/0%/0%/70%）、逐层差距表、
  **12 项 P0 空白清单**（含验收标准）、非功能门禁、重排后的里程碑、**24 条封版验收清单**
- 宪法新颁**第 10 章 生态完整性（七层模型）**：交付物必须标注所属层；
  优先级纪律"骨架 > 服务 > 行为 > 组件"；禁止"组件堆满、生态空心"
- ROADMAP 按生态层重排交付顺序（L1 → L4 → L3 → L0/L5 → L2 → L6）

### Changed

- M1 范围重定义：从"组件攻坚"改为"生态骨架"四个 Sprint
  （布局五件套 → 服务六件套 → 行为四件套 → 图标/工具/动效）

### Notes

- 核心判断：Quasar 的"生态味"主要来自 **L1 布局、L3 指令、L4 插件、L5 工具类**（当前合计 0%），
  而非组件数量；补齐这四层才叫"用起来像 Quasar"，否则只是"长得像"

## [0.3.4] - 2026-11-21

### Changed（接续方式精简为单文件）

- `PROMPT.md` 改为**自包含**：交接快照全文内联，新会话只需粘贴这一个文件，
  不再要求预先翻 `SESSION_HANDOFF / CONSTITUTION / PARITY / CHANGELOG`
- 宪法/PARITY/CHANGELOG/ROADMAP 改为"**按需深读**"表格（涉及对应主题时再打开）
- `gen_prompt.py` 升级：快照正文自动内联（H2→H3 嵌套、剥离引用块），
  输出**内容指纹**（SHA256 前 12 位）；`--check` 由"版本号比对"升级为"指纹比对"
- 宪法第 9 章新增第 4 条：SESSION_HANDOFF 为唯一事实源，PROMPT.md 为其单文件投影
- SESSION_HANDOFF 陈旧状态修正（0.3.1 → 0.3.4）并清理重复条目

## [0.3.3] - 2026-11-21

### Fixed（交付包完整性加固）

- 发布 ZIP 补齐 `PROMPT.md`（此前漏打，接续提示词不在包内）
- 发布 ZIP 默认纳入完整 `.git` 历史（此前遗漏，异地灾备承诺未兑现）
- 新增 `BUILD_INFO.txt` 构建清单（版本/构建时间/git HEAD/文件总数/校验方式）
- 新增旁路 `*.sha256` 校验文件：下载后可核对指纹，杜绝传输截断导致的“包变小”误判
- 新增 `--bundle`：ZIP 内附加 `icons/` 离线图标全量包（约 30MB，完全离线部署）
- 新增 `--no-git`：按需剔除 git 历史以减小体积

## [0.3.2] - 2026-11-21

### Added（跨会话永续开发闭环）

- `docs/templates/SESSION_HANDOFF_TEMPLATE.md`：交接快照通用模板（{{占位符}} + 使用说明）
- `docs/templates/PROMPT_TEMPLATE.md`：会话接续提示词模板（上下文恢复 → 汇报 → 硬约束）
- `scripts/gen_prompt.py`：**根据交接快照实时更新提示词** —— 提取快照版本/日期/git HEAD，
  从模板生成项目根目录 `PROMPT.md`；`--check` 模式校验同步性（可入 CI 门禁）
- 宪法第 9 章交付纪律升级：每次交付 = 升版 → CHANGELOG → 宪法记录 → SESSION_HANDOFF →
  **gen_prompt 刷新 PROMPT** → 一键 ZIP

## [0.3.1] - 2026-11-21

### Added（基础夯实轮 —— 磨刀不误砍柴工）

- 测试护栏补齐：Dark 插件 API 测试（`isDark` / `setDark` / `toggleDark` 翻转 / `dark` 品牌色令牌）、
  demo 完整加载测试（此前仅画廊有护栏）；合计 32 项，全绿
- GitHub 基建：Issue 模板（Bug/Feat，要求附 Quasar 对标 API 与明暗主题复现说明）、
  PR 模板（宪法第 8/9 章交付检查清单）、dependabot 依赖巡检（actions + pip 周检）
- 文档测试计数全量同步（25 → 32）
- **防失忆保险**：`docs/SESSION_HANDOFF.md` 项目交接快照（新会话 1 分钟恢复全部上下文）；
  git 仓库初始化 + 全量首提交（工程记忆落盘，不依赖任何会话）

## [0.3.0] - 2026-11-21

### Changed ⚠ Breaking（0.x 期重构，趁早降本）

- **命名冲突重构**（宪法迭代 0.3.0）：明暗模式 `NovaTheme.dark` → **`NovaTheme.isDark`**
  （1:1 对标 `$q.dark.isActive`），品牌色 **`darkColor` → `dark`**（1:1 对标 Quasar `$dark`），
  并新增 `setDark(value)`（对标 `$q.dark.set()`）；`toggleDark()` 不变（对标 `$q.dark.toggle()`）
- 迁移：`NovaTheme.dark = true` → `NovaTheme.setDark(true)`；读取用 `NovaTheme.isDark`

### Added

- **全量对标审计机制（宪法 3.5 条）**：`docs/PARITY.md` —— 已交付组件逐属性/事件/槽/model
  对照 Quasar 2.26.0 列明 ✅/🚧/⛔/❌ 状态与目标里程碑；v-model → QML 可写属性+变更信号映射约定；
  封版前 ✅ 占比门禁（P0 ≥90%、全库 ≥85%）
- 新增测试：`isDark` / `setDark` / `dark` 品牌色（合计 30 项，全绿）

## [0.2.1] - 2026-11-21

### Added

- **《架构宪法》`docs/CONSTITUTION.md`**：九章最高工程准则（工程结构 / 头注释 / Quasar 化 /
  槽机制 / 设计令牌 / 断点 / 图标 / 质量门禁 / 版本纪律）+ 迭代记录表，每次交付随版本更新
- **槽机制入宪（宪法第 4 章）**：Quasar 默认槽 → QML `default property alias`、
  命名槽 → 具名 alias / 组合子组件、作用域槽 → `property Component delegate`
- `NovaTheme.darkColor`（`#1D1D1D`）：补齐 Quasar 8 大品牌变量最后一项（本库 `dark` 已被明暗模式布尔占用，故映射命名 `darkColor`）

### Changed

- ⚠ 对标基线核实并锁定 **Quasar 2.26.0**（此前记录的 2.2x 版本号已过时，随宪法迭代复核）
- **5 个组件重构补齐默认槽**（Quasar 对应组件均有默认槽）：`NovaBtn` / `NovaChip` /
  `NovaAvatar` / `NovaIcon` / `NovaBadge` 新增 `default property alias`，
  默认子项挂载到覆盖层宿主，NovaBadge 角标吸附行为不受影响
- 新增 5 项槽机制冒烟测试（合计 30 项，全绿）

## [0.2.0] - 2026-11-21

### Changed ⚠ Breaking

- **包结构规范化（src 布局终版）**：Python 包 `nova` → `pyside_nova`，
  QML 模块 URI `nova.services/controls/behaviors` → `Nova.Services/Controls/Behaviors`
  - `from nova import init_nova` → `from pyside_nova import init_nova`
  - `import nova.controls` → `import Nova.Controls`
- 工程约定落盘：所有 `.py` / `.qml` 文件以两行头注释开头——
  第 1 行从 `src/` 开始的完整文件子路径（`src/pyside_nova/…`），第 2 行组件/文件说明（直接沉淀为 API 文档素材）
- ⚠ 已知坑（沉淀为规范）：`qmldir` 文件仅支持 `#` 注释，`//` 会破坏模块解析

### Added

- **一键打包部署升级**：`scripts/local_deploy.py --zip` 生成发布 ZIP 包
  （`dist/pyside-nova-<版本>-release.zip`：完整源码树 + 构建 wheel，zip 内根目录 `pyside-nova/`）

- **组件画廊（Gallery）**：`examples/gallery/` —— 侧边导航 + 8 个页面，
  全部 12 个组件实机展示（按钮形态/尺寸/状态、卡片三件套、标签、头像、徽标波纹、
  图标双通道、主题令牌色板、断点实时监控），顶部一键明暗切换
- **完整旗舰版文档集**：README.md（英文）/ README_zh.md（中文）/
  CHANGELOG / CONTRIBUTING / SECURITY / CODE_OF_CONDUCT /
  docs/ARCHITECTURE.md / docs/DESIGN_TOKENS.md / docs/COMPONENTS.md / docs/ROADMAP.md
- 新增测试：组件画廊完整加载测试（合计 25 项，全绿）

## [0.1.0] - 2026-11-21

### Added — M0 基建 · 第一批组件（12 个）

- `NovaTheme`：设计令牌单例（品牌色/语义色/表面色/几何/字阶/阴影），明暗双主题，运行时品牌换肤
- `NovaBtn`：按钮（filled/outlined/flat、水波纹、loading、disable、键盘触发）
- `NovaCard` / `NovaCardSection` / `NovaCardActions`：卡片系列（MultiEffect 阴影）
- `NovaChip`：标签（filled/outlined/tinted、可选中、可移除）
- `NovaAvatar`：头像（自动配色/emoji/图片）
- `NovaBadge`：徽标（子项挂载，红点/数值/浮动）
- `NovaSpace` / `NovaSeparator`：布局原语
- `NovaIcon`：图标组件（对标 QIcon）——`icon="mdi:home"` 式 API，云端 CDN + 本地图标包双通道自动回落，封装 QML Image + MultiEffect 单色化着色；`NovaBtn.icon` 自动识别图标引用
- `NovaScreen`：屏幕断点单例（对标 Quasar Screen 插件）——xs/sm/md/lg/xl（600/1024/1440/1920），is/lt/gt 语义 1:1 对标，阈值可定制
- `NovaRipple`：水波纹行为（子项挂载）
- Python 接入层 `init_nova(engine)`；wheel 内完整打包 QML 模块
- 设计约定：组件基调色属性命名 `tint`（QML 中 `color` 与基类属性冲突）；`NovaBadge.attach`/`NovaRipple.attach` 语法规划于 M1 通过 PySide6 `QML_ATTACHED` 实现
- 可运行演示 `examples/demo`；QML 冒烟测试；CI（Windows+Linux 矩阵）与 PyPI 可信发布流水线
- 一键本地部署：`scripts/fetch_icons.py`（下载 MDI/Material 图标包离线可用）+ `scripts/local_deploy.py`（build→install→test）

### Verified（Qt 6.12.0 关键坑位沉淀）

1. `on*` 前缀属性命名与 QML 信号处理器命名规则冲突（如 `onPrimary`），会令整个模块加载失败
   → 主题文本属性命名 `textOnPrimary` / `textColor` / `textMuted`
2. 组件声明 `property color color` 与 Rectangle 基类 `color` 冲突导致重复赋值
   → 基调色统一命名 `tint`
3. 纯 QML（6.12）不支持自定义 attached property（`Xxx.attach` 语法）
   → M1 经 PySide6 `QML_ATTACHED` 注册 Python 类型补齐，当前以子项挂载保持属性名一致
4. 单例属性不能在对象体内声明式绑定（会被解析为 attached property）
   → `NovaScreen.source = window` 须在 `Component.onCompleted` 中赋值
