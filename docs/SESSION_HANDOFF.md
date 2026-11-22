# 项目交接快照 — Session Handoff

> 用途：本文件是项目状态的**唯一事实源**；`scripts/gen_prompt.py` 会把它全文内联进
> `PROMPT.md`，新会话粘贴 PROMPT.md 即可 100% 恢复上下文。
> **每次交付随宪法迭代记录表同步更新本文件。**（更新于 0.14.0 · 2026-11-23）

## 一句话定位

pyside-nova：面向 PySide6 的企业级 QML 组件库，QML 元素 Quasar 生态化，
对标 **Quasar 2.35.5**（2026-11-22 复核纠正，原 2.26.0 过期），目标 `1.0.0-flagship` 封版（API 冻结 + LTS 24 个月）。

## 当前状态（0.14.0 · **四期 Sprint B 收口：弹层与反馈**）

- **公共 QML 类型 117 个已交付**（qmldir 导出口径）：Controls **89**（0.14.0 新增
  NovaMenu/NovaDialogShell/NovaPopupProxy/NovaTooltip/NovaBottomSheet/NovaSpinner×8 变体/
  NovaSkeleton/NovaInnerLoading/NovaAjaxBar/NovaBanner/NovaBar/NovaNoSsr/NovaPullToRefresh/
  NovaResizeObserver）
  + Services 单例 11（Screen/Theme/OverlayHost/Notify/Dialog/Loading/**LoadingBar**/Storage/App/Platform/IntersectionPool）
  + Design 单例 3（NovaIconSet/NovaMotion/NovaUtils）+ 句柄与动作 4
  + Behaviors 9（Ripple/Intersection/ScrollObserver/ScrollFire/ClosePopup/TouchPan/Swipe/Hold/Repeat，
  另有 internal NovaTouchCore 内核）
- **测试 308 项全绿**（271 + 0.14.0 新增 38：29 类型实例化冒烟 + 行为用例 9：菜单 auto-close
  与弹层栈逐层 ESC、对话框关闭原因上报/persistent 锁闭+shake、BottomSheet 动作回报、
  AjaxBar 多进程计数、PTR trigger 受控复位、ResizeObserver 上报、BtnGroup 样式下发、
  LoadingBar 服务降级 no-op）
- **Sprint 进度**：Sprint 1 ✅(0.5.0) → Sprint 2 ✅(0.6.0~0.6.2) → Sprint 3 ✅(0.7.0) → Sprint 4 ✅(0.8.0)
  → 二期 Sprint A ✅(0.9.0 表单核心七件) → 二期 Sprint B ✅(0.10.0 输入进阶八件)
  → **三期 Sprint A ✅(0.11.0 数据体系九件)** → **三期 Sprint B ✅(0.12.0 媒体体系十类型 + Table 增强)**
  → **四期 Sprint A ✅(0.13.0 导航体系 14 类型)** → **四期 Sprint B ✅(0.14.0 弹层与反馈)**
  → 五期 Sprint A（v0.15.0 长尾组件）待开工
- **七层成熟度**：L0 100% / L1 100% / L3 100% / L4 44% / L5 95% / **L2 68%（四期 B 0.14.0）** / L6 70%（五期）
- **表单统一契约**：`label/hint/error/readonly/disable/clearable/rules` 贯穿表单族（对标 use-field +
  use-validate 36 props 逐项对账）；**受控模式**：组件只 emit 不自写（Quasar v-model 语义 1:1，
  防绑定环），宿主绑定 + 信号写回——数据体系全族沿用（selected/expanded/sortBy/page 均受控）
- **数据体系契约**：选中/勾选一律**按键值比较**（rowKey 或 JSON 全等，坑位 27）；
  树派生索引**显式失效**（onNodesChanged/on_LazyStoreChanged → _refreshDerived + _rev，坑位 28）
- **图标集数据纪律**：`src/pyside_nova/qml/Nova/Design/IconSets.js` 是生成物（scripts/gen_iconsets.py
  从 npm quasar@2.35.5 icon-set/*.js 提取），**禁止手改**；基线包临时解包目录 /tmp/qbase 可重建
- **基线复核（0.13.0）**：Quasar 2.35.5→2.35.6 dist/api/*.json 逐文件 diff **零漂移**（纯补丁版），基线维持 2.35.5 口径
- **交付节奏条款（0.6.2 新颁，0.7.0 首次完整执行）**：Sprint 是最小交付单元——一次收口、
  一个版本号、一套六份交付物；中间件只 git 提交不单独打全包
- **弹层纪律（0.14.0）**：可关闭弹层挂 NovaOverlayHost.registerPopup + **Component.onDestruction
  注销**（泄漏会级联污染后续测试）；关闭原因上报口径 ok/cancel/backdrop/escape/api；auto-close 类
  语义动态挂接子项 clicked（坑位 35）；受控契约沿用（Menu/DialogShell/BottomSheet/PTR 均 emit-only）
- **规划核对纪律（0.14.0）**：NovaScrollObserver 已于 Behaviors 0.7.0 交付——本期发现 Controls
  新建同名类型造成跨模块歧义，已删除并关闭规划条目；同名交付前先 grep 全部 qmldir
- **导航体系契约（0.13.0）**：受控契约全族沿用（Tabs/Panels/Stepper 的 modelValue 与
  Fab 的 open 均只 emit 不自写）；ExpansionItem group 手风琴经 ExpansionGroups.js 注册表
  互斥——被收起方走自身 updateModelValue(false) 受控上报；Breadcrumbs 激活色 1:1
  对标 2.35.6 QBreadcrumbs.js（中间未禁用条目着色，当前页不着色）；Stepper 状态图标
  解析 1:1 对标 StepHeader.js（active>error>done、step 级优先、'none' 退让 prefix）
- **环境约定**：用户 Dell Win11 · PySide6 6.12.0 · 单人开发 · PyPI + GitHub
- **接续方式**：粘贴 `PROMPT.md`（自包含，快照已内联）；快照改动后须重跑 `gen_prompt.py`

## 必读文件（按需深读，非预读）

0. `docs/MASTER_PLAN.md` —— **全生态六期总规划**（排期与验收以它为准）

1. `docs/CONSTITUTION.md` —— 架构宪法（十章程则 + 迭代记录表）
0.5. `docs/ECOSYSTEM_PARITY.md` §0.5 —— 2.26→2.35 基线漂移审计（增量对照表）
2. `docs/PARITY.md` —— 全量对标审计（逐属性/事件/槽/model）
3. `CHANGELOG.md` —— 版本史（含 Qt 6.12 坑位沉淀）
4. `CONTRIBUTING.md` —— 宪法落地细则

## 不可违反的约定（速查）

- 头注释：第 1 行 `src/` 起始子路径，第 2 行文档素材说明；qmldir 只用 `#`
- 命名红线：基调色 `tint`；禁 `on*` 属性；主题模式 `isDark` / `setDark()` / `toggleDark()`；品牌色 `dark`（$dark 1:1）
- 槽机制：默认槽 `default property alias`、命名槽组合子组件、作用域槽 `Component delegate`
- 断点接入唯一方式：`Component.onCompleted: NovaScreen.source = window`
- 交付纪律：升版 → CHANGELOG → 宪法记录表 → 本文件 → `gen_prompt.py` 刷新 PROMPT → `local_deploy.py --zip`

## 已知坑位（Qt 6.12 实战沉淀）

1. `on*` 前缀属性名导致整个模块加载失败
6. 断点判断勿在组件自身 Component.onCompleted 做——创建期 parent 宽度是瞬态值（0），策略应由宿主（如 NovaLayout）持有
2. `property color color` 与 Rectangle 基类冲突 → 用 `tint`
3. 纯 QML 不支持自定义 attached property（`attach` 语法 M1 经 PySide6 `QML_ATTACHED`）
4. qmldir 不支持 `//` 注释
5. 单例属性不可对象体内声明式绑定（会解析成 attached）
7. QtObject（含单例）体内不可直接声明 `Component { }` 子项——报 "Cannot assign to non-existent
   default property"；必须走 `property Component xxx: Component { … }` 内联（0.6.0 实战沉淀）
8. `qmlRegisterSingletonInstance`（PySide6）把实例交给 QML 树管理：组件销毁即 delete Python 对象，
   二次访问报 "Internal C++ object already deleted"，且全局单实例无法多引擎共享 →
   一律用**工厂式 `qmlRegisterSingletonType`**（0.6.2 沉淀）
9. 服务单例引用裸 JS 对象当状态条目：属性变化无通知，句柄绑定不刷新 → 条目必须是 QML 对象
   （property Component 内联 QtObject）（0.6.2 沉淀）
10. 动态 overlay 的可见性与宿主 attach（强制 visible=true）冲突：可见性门控放内部 `_started`，
    根节点常驻、子项受控（0.6.2 沉淀）
11. QML 测试里 Python 引用保不住 QML 顶层 Window（JS GC 不认 Python 引用）→ 行为断言一律走
    QML 侧函数，不摸 Python 侧窗口 wrapper（0.6.2 沉淀）
12. QML 派生 Item 里重声明 `x/y/active` 报 "Cannot override FINAL property"（Qt 6.12 FINAL 成员）；
    `enabled` 不重声明直接用 Item.enabled（继承语义天然正确）（0.7.0 沉淀）
13. 行为根节点设 visible:false 会阻断内部 MouseArea 收事件（不可见 Item 不参与事件分发）——
    纯逻辑行为可以关，带指针通道的绝不能关（0.7.0 沉淀）
14. 组件默认属性把子项转交内部容器（如 NovaBtn 的 contentHost）时，子项的 parent 不是宿主本体，
    `target: parent` 拿不到宿主信号 → 向上遍历找第一个带目标信号的祖先（0.7.0 沉淀）
15. PySide 把 QML Window 包装成 QWindow，metaobject 里没有 QML 定义的方法，函数调不到 →
    测试用 QML 侧 QtObject 代理（call0/1/2 按实参个数分派——QML 函数无可选参数）+ 强引用窗口（0.7.0 沉淀）
16. 观察器只报"变化"：重新订阅必须重置上次判定并补一帧当前状态，否则状态未变就永远等不到回调
    （基线 reobserve 同款语义）（0.7.0 沉淀）
17. V4 引擎下 `1<<24` 参与 `|` 位运算拼 hex 会静默串色（#5B6EF5→#769397）→ 十六进制一律逐字节
    toString(16) 补零；formatDate 的 literal `[...]` 语义是"原样输出"不是"解析后插值"（0.8.0 沉淀）
18. QML Animation/NumberAnimation **没有 `enabled` 属性**：不参与的维度用 from==to 兜底（0.8.0 沉淀）
19. `Component.createObject` 创建的 Timer **不会自动启动**：必须显式 start()/restart()
    ——throttle 尾跑曾因此静默失效（0.8.0 沉淀）
20. QML 无 requestAnimationFrame / crypto.randomUUID：frameDebounce 用 16ms 单发 Timer 等价 rAF；
    uid 用时间戳+计数+随机 v4 形态降级留痕；debounce/throttle 的 Timer 用 `property Component`
    内联创建（0.8.0 沉淀）
21. 子类再声明 `signal valueChanged(var)` 与基类属性的自动通知信号撞名 → "Duplicate signal name:
    invalid override"（NovaField.value 的 valueChanged 即自动信号）；值通知一律走属性变更信号，
    自定义信号换名（0.9.0 沉淀）
22. 受控组件写自身 modelValue（self-assign）会断宿主绑定并触发绑定环告警；对标 Quasar v-model：
    组件只 emit 不自写，toggle()/select() 返回下一值由宿主写回（0.9.0 沉淀）
23. `readonly color x: …` 漏 property 关键字报 "Expected token `:`"——readonly 必须配 property
    连用（0.9.0 沉淀）
24. 缓存型 `readonly property var _norm: _normalize(mv)` 在信号处理器内引用时可能拿到重评期
    undefined——处理器内改直接函数调用，不走缓存绑定（0.10.0 沉淀）
25. `palette`/`show`/`hide` 与 Qt 内建 Item 成员撞名 → 覆盖告警或 Duplicate method：改
    paletteColors/shown/hidden（0.10.0 沉淀）
26. local_deploy 装出 site-packages 真实拷贝后，pytest 的 `import pyside_nova` 会命中旧 QML
    （组件 is not a type 随机爆）——交付后必须 `pip install -e . --no-deps` 复位（0.10.0 沉淀）
27. **Qt6 信号参数会把 JS 对象/数组深拷贝**——updateSelected(rows) 这类带对象数组参数的信号
    送达宿主时引用一致性已丢失；选择/勾选语义一律按键值（rowKey 或 JSON 全等）比较，
    勿用 `===`/`indexOf` 引用比较（0.11.0 沉淀）
28. 绑定内经函数间接读取的依赖跟踪不可靠 + 递归索引漏层——NovaTree `_index` 只递归 `children`
    静态层，懒加载回填层（`_lazyStore`）永不入索引，且函数内读 `_lazyStore` 的重赋不触发重评；
    改显式失效：onNodesChanged/on_LazyStoreChanged/onFilterChanged → _refreshDerived() + _rev
    版本号供渲染绑定引用（0.11.0 沉淀）
29. inline component 裸名赋给 `delegate:`（`delegate: TableRow`）在 Qt 6.12 下**恒 count 0**
    且零报错——必须带花括号实例化 `delegate: TableRow { }`（0.12.0 沉淀）
30. 创建期可见性求值时序会让 Column 定位器错过自动布局（委托 implicitHeight 恒 0，翻可见性
    才补）——显式绑定 `height: childrenRect.height` 兜底（子项高度不依赖父高，无环）（0.12.0 沉淀）
31. QtMultimedia `Video` 元素创建即初始化 FFmpeg 音频上下文，无音频服务环境（CI/沙箱）**进程
    挂死**——播放器必须按 src 惰性创建（0.12.0 沉淀）
32. `ListView` reuseItems 与含自定义子组件的 delegate 组合在 Qt 6.12 触发**进程退出段错误**
    （包装 Component 亦不能规避）——NovaTable 虚拟滚动暂缓 reuseItems，cacheBuffer 兜底；
    布尔型 exit code 必须以 subprocess/直接退出码核验，管道 `| tail` 会吞 pytest 退出码
    （0.12.0 沉淀）
32. 占位/错误图若走"source 随 status 切换"成 source↔status 绑定环——分层叠加（主图常驻 +
    占位/错误图层按态覆盖）；坑位 28 再验证：columns.map()/宿主探测等函数调用绑定依赖不可靠，
    派生数据变更点一律显式失效（0.12.0 沉淀）
33. QML `Item` 无 `Component.onDestroyed`——析构钩子是 **`Component.onDestruction`**，
    写错整文件加载失败（0.13.0 沉淀）
35. TapHandler 与子项 MouseArea 同区域时被独占饿死——auto-close 类语义须**动态挂接子项
    clicked 信号**（connect + 登记防重复）；弹层组件销毁必须 unregisterPopup（0.14.0 沉淀）
34. Text/Item 级基元元素**没有 `background` 属性**（Control 系 API）——徽标底色须手写
    包裹 Rectangle；布尔型 JS `join(',')` 产出小写 `true/false`，测试断言小写口径
    （0.13.0 沉淀）
- ~~Sprint 2 L4 服务~~ ✅ 0.6.0~0.6.2（Notify 29 项/Dialog 27 项/Loading 11 项对账 + Storage/App/Platform；L4 44%）
- ~~Sprint 3 L3 行为~~ ✅ 0.7.0（九件一次收口；L3 100%）
- ~~Sprint 4 L0/L5 基础层~~ ✅ **0.8.0 收口（Nova.Design 三单例 + NovaText/NovaTransition；
  14 套图标集 + provider 注册表 + 八通道解析；colors 12 + date 21（44 token）+ format 6 + is 5 +
  debounce/throttle/uid；动效 15 预设；排版 12 级；画廊 15 页；149 项测试；L0 100%/L5 95%）**
- ~~二期 Sprint A 表单核心~~ ✅ 0.9.0；~~二期 Sprint B 输入进阶~~ ✅ **0.10.0（NovaRange/NovaDate
  自研日历/NovaTime 时钟面盘/NovaColorPicker 色域盘/NovaOptionGroup/NovaForm/NovaBtnToggle/
  NovaPopupEdit 八件；L2 16%→24%；画廊 17 页；199 项测试）**
- ~~二期 Sprint A 表单核心~~ ✅ 0.9.0；~~二期 Sprint B 输入进阶~~ ✅ 0.10.0（八件；L2 16%→24%）
- ~~三期 Sprint A 数据体系~~ ✅ **0.11.0（NovaTable+Th/Td/Tr / NovaTree / NovaPagination /
  NovaList·NovaItem(+Section/Label) / NovaMarkupTable / NovaInfiniteScroll / NovaVirtualScroll /
  NovaScrollArea 九件 14 类型；L2 24%→34%；画廊 18 页；225 项测试）**
- ~~三期 Sprint B 媒体体系~~ ✅ **0.12.0（NovaImg/NovaResponsive/NovaVideo/NovaParallax/
  NovaCarousel+Slide+Control/NovaTimeline+Entry/NovaChatMessage 十类型 + NovaTable 增强
  虚拟滚动/服务端模式/loading；L2 34%→43%；画廊 19 页；250 项测试）**
- ~~四期 A 导航体系~~ ✅ **0.13.0（NovaTabs/Tab/TabPanel/TabPanels + NovaBreadcrumbs/El +
  NovaStepper/Step/StepperNavigation + NovaExpansionItem + NovaToolbar/Title +
  NovaFab/FabAction 14 类型；L2 43%→54%；画廊 20 页；271 项测试；基线复核 2.35.6 零漂移）**
- ~~四期 B 弹层与反馈~~ ✅ **0.14.0（NovaMenu/DialogShell/PopupProxy/Tooltip/BottomSheet +
  Spinner×8/Skeleton/InnerLoading/AjaxBar+LoadingBar 服务/Banner/Bar/NoSsr/PullToRefresh/
  ResizeObserver；L2 54%→68%；画廊 21 页；308 项测试；ScrollObserver 规划核对不重复）**
- **五期 A（下一步）长尾组件（v0.15.0）**：NovaEditor（轻量富文本）/ NovaMorph（元素形变）/
  NovaSlideItem（滑动操作项）/ NovaIconGenie（图标生成）/ **Nova MCP server + AI-ready 文档**
  （对标 @quasar/mcp 2.33 新品类），以 MASTER_PLAN §5 为准（开工首日复核 Quasar 最新 release）
- 详细差距与 DoD：`docs/ECOSYSTEM_PARITY.md`

## 最近一次交付

- **0.14.0：四期 Sprint B 收口 · 弹层与反馈一次交付**
  （NovaMenu + NovaDialogShell 关闭原因上报 + NovaPopupProxy 断点路由 + NovaTooltip +
  NovaBottomSheet + NovaSpinner 八变体 + NovaSkeleton/NovaInnerLoading/NovaAjaxBar/
  NovaLoadingBar 服务/NovaBanner/NovaBar/NovaNoSsr/NovaPullToRefresh 四边拉动/
  NovaResizeObserver；画廊第 21 页；测试 308 项；L2 54%→68%；类型 100→117）
- **0.13.0：四期 Sprint A 收口 · 导航体系 14 类型一次交付**
  （NovaTabs/Tab/TabPanel/TabPanels 受控标签页族 + NovaBreadcrumbs/El + NovaStepper/Step/
  StepperNavigation 状态图标 1:1 解析 + NovaExpansionItem group 手风琴 + NovaToolbar/Title +
  NovaFab/FabAction stagger 级联 + hover 契约；画廊第 20 页；测试 271 项；L2 43%→54%）
- **0.12.0：三期 Sprint B 收口 · 媒体体系十类型 + Table 增强一次交付**
  （NovaImg 三态占位/ratio + NovaResponsive 等比 + NovaVideo 惰性播放器 + NovaParallax 视差 +
  NovaCarousel 受控全家桶（arrows/navigation/autoplay/infinite/swipeable/覆盖控件）+
  NovaTimeline 三布局 + NovaChatMessage 收发气泡 + NovaTable 虚拟滚动/服务端模式/loading；
  画廊第 19 页；测试 250 项；L2 34%→43%）
- **0.11.0：三期 Sprint A 收口 · 数据体系九件 14 类型一次交付**
  （NovaTable 排序/过滤/分页/多选/展开行 + NovaTree strict 级联/懒加载/过滤 +
  NovaPagination + NovaList 手风琴四件 + NovaMarkupTable + NovaInfiniteScroll +
  NovaVirtualScroll 5000 行虚拟化 + NovaScrollArea；画廊第 18 页；测试 225 项；L2 24%→34%）
- 0.10.0：二期 Sprint B 收口 · 输入进阶八件一次交付（自研日历/时钟面盘/取色器落地）
  （NovaRange 双值约束 + NovaDate 三模式 mask 日历 + NovaTime 三面时钟 + NovaColorPicker
  SV 色域盘 + NovaOptionGroup 三型 + NovaForm 聚合校验 + NovaBtnToggle + NovaPopupEdit
  + 画廊第 17 页 + 测试 199 项；L2 16%→24%）
- 0.9.0：二期 Sprint A · 表单核心七件（统一契约 + 校验引擎；画廊 16 页；174 项测试）
- 0.8.0：Sprint 4 收口 · L0 设计语言 + L5 工具层一次交付（一期生态骨架完工）**
  （NovaIconSet 14 套图标集/100 语义键/provider 注册表/八通道解析 + NovaMotion 动效令牌 15 预设
  + NovaUtils colors 12·date 21·format 6·is 5·debounce/throttle/uid/extend + NovaText 排版 12 级
  + NovaTransition 过渡组件 + NovaTheme 排版/高程令牌 + NovaIcon 升级三通道 + 画廊 14/15 页
  + 测试 149 项；L0 60%→100%、L5 0%→95%；新增 Nova.Design 模块）
- 0.7.0：Sprint 3 收口 · L3 行为层九件一次交付（Intersection/ScrollObserver/ScrollFire/
  ClosePopup/TouchPan·Swipe·Hold·Repeat + NovaIntersectionPool 共享观察池 + NovaOverlayHost
  弹层栈 + 画廊第 13 页 + 114 项测试；L3 11% → 100%）
- 0.6.2：Sprint 2 收口 · 一次交付四件（NovaLoading 11 项对账 + 引用计数 / NovaStorage 真落盘 /
  NovaApp / NovaPlatform + NovaRuntime Python 后端 + 画廊第 12 页 + 91 项测试 + 交付节奏条款）
- 0.6.1：Sprint 2 第二件 NovaDialog（27 项对账 + 句柄三信号 + 画廊对话框页 + 71 项测试）
- 0.6.0：Sprint 2 首件 NovaNotify + NovaOverlayHost（29 项对账 + 63 项测试）
- **0.5.0：一期 Sprint 1 · L1 布局系统**（布局五件套 + 栅格三件套 + 画廊布局页 + 46 项测试）
- 0.4.2：**基线纠正 2.26.0 → 2.35.5** + 增量审计（AI-ready/MCP 入 L6、关闭原因上报/hover 契约/stagger/side 入 DoD）
- 0.4.1：**全生态开发总规划**（六期战略 + 全量对账表 + 冒烟测试七条纪律）
- 0.4.0：生态对标白皮书（七层模型 + 12 项 P0 空白 + 24 条封版验收）+ 宪法第 10 章 + M1 范围重排
- 0.3.4：PROMPT 单文件自包含（快照全文内联 + 内容指纹校验），告别"翻 4 个文件"
- 0.3.3：交付包完整性加固（ZIP 含 PROMPT + .git 历史 + BUILD_INFO + SHA256）
- 0.3.2：快照/提示词双模板 + gen_prompt.py 生成器

## 交付物通道

- 本地：`python scripts/local_deploy.py --zip --allinone` → release.zip + ALL-IN-ONE.zip
  （--allinone 必须在最终 git 提交之后运行，保证包内历史与 HEAD 一致——0.8.0 教训）
- PyPI：打 `v*` 标签 → GitHub Actions Trusted Publishing 自动发布
