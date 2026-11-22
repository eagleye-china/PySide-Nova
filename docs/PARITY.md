# 对标审计 — pyside-nova Quasar Parity Audit

> 宪法第 3 章的落地执行表：**逐组件、逐属性、逐事件、逐槽、逐 model 对照 Quasar**
> （对标基线 **2.35.5**，0.4.2 纠正），一步一个脚印，不急功近利。
> 每次交付随宪法迭代记录表同步更新；新组件交付时必须新增对应审计节。

**图例**：✅ 已对标 · 🚧 已排期 · ⛔ QML 语境不适用 · ❌ 待排期

## v-model / modelValue 映射约定

Quasar 的 `v-model` 在 QML 中统一映射为**可写属性 + 配对信号**：
`v-model="x"` → `property X x` + `signal xChanged()`（QML 属性变更通知天然等价）。
数据类组件（M1 NovaInput/NovaSelect/NovaTable）按此约定实现双向绑定。

## NovaBtn ← QBtn（审计 0.3.0）

| Quasar API | 类型 | 状态 | 说明 |
|---|---|---|---|
| `label` / `icon` / `icon-right` | prop | ✅ | 映射为 `text` / `icon` / `iconRight` |
| `color` | prop | ✅ | 映射为 `tint`（命名红线） |
| `size` | prop | ✅ | sm/md/lg（Quasar 还接受 CSS 尺寸串 → 🚧 M1 扩展） |
| `flat` / `outline` / `unelevated` / `push` / `glossy` | prop | ✅/🚧 | 统一为 `variant` 枚举；push/glossy 🚧 M2 |
| `round` / `round-outline` / `dense` / `disable` | prop | ✅ | round-outline 并入 variant+round 组合 🚧 |
| `loading` / `loading-label` / `loading-icon` | prop | 🚧 | loading ✅；label/icon 定制 M1 |
| `no-caps` / `no-wrap` / `align` / `padding` / `stack` / `stretch` | prop | ❌ | M1 排期（QML 默认行为不同，需逐项论证） |
| `type` / `to` / `href` / `tabindex` / `form` | prop | ⛔/🚧 | QML 无 DOM 语义；tabindex M2 无障碍批次 |
| `ripple` | prop | ✅ | 内置波纹（ unconstitutional 免检） |
| `click` / `pressed` 等事件 | event | ✅ | `clicked()` / `pressed()` / `released()` |
| 默认槽 / `loading` 命名槽 | slot | ✅/🚧 | 默认槽 ✅（覆盖层）；loading 槽 M1 |

## NovaChip ← QChip（审计 0.3.0）

| Quasar API | 类型 | 状态 | 说明 |
|---|---|---|---|
| `label` → `text`、`icon`、`color` → `tint`、`dense`、`disable` | prop | ✅ | |
| `removable` + `remove` 事件 | prop/event | ✅ | `removed()` |
| `selected` / `clickable` / `click` 事件 | prop/event | ✅ | |
| `outline` / `dark`（外观） | prop | ✅/🚧 | dark 外观令牌版 M1 |
| `size`（CSS 串） | prop | ❌ | M1 |
| `icon-right` / `dir` | prop | ❌ | M2 |
| 默认槽 | slot | ✅ | 覆盖层宿主 |
| v-model:selected | model | ✅ | `selected` 可写属性 |

## NovaAvatar ← QAvatar（审计 0.3.0）

`text`（slot 等价）、`icon` 🚧、`source` ✅、`size` ✅、`square` ✅、`color`→`tint` ✅、
`text-color` ✅、默认槽 ✅。`icon` 属性 M1 补齐。

## NovaIcon ← QIcon（审计 0.3.0）

`icon="set:name"` API ✅（Quasar 的 webfont 模型换为 SVG 双通道，属架构决策 ADR-6）、
`size` ✅、`color` ✅、默认槽 ✅、`tag`/语义化 DOM ⛔。`role`/`aria` M2 无障碍批次。

## NovaBadge ← QBadge（审计 0.3.0）

`value` → `text` ✅、`color`→`tint` ✅、`text-color` ✅、`floating` ✅、`transparent` 🚧、
`multi-line` / `max`（99+ 截断）❌ M1、`label` 命名槽 / `align` 作用域控制 ❌ M2、默认槽 ✅、
`align`（五方位吸附）🚧 M1。

## NovaCard / Section / Actions ← QCard 系列（审计 0.3.0）

QCard：默认槽 ✅、`flat` ✅、`bordered` ✅、`dark` 外观 🚧 M1、`square` 🚧、
`tag`/语义 DOM ⛔、`section` 命名区域 ✅（以 Section/Actions 组合子组件实现，宪法命名槽映射）。
QCardSection：`horizontal` / `avatar` 命名槽 ❌ M1。
QCardActions：`vertical` / `align` ✅ / ❌ M1。
QCardSection `prepend`/`append` 槽 ❌ M1。

## NovaSpace / NovaSeparator ← QSpace / QSeparator（审计 0.3.0）

NovaSpace ✅（无 API 面，等价）。NovaSeparator：`vertical` ✅、`dark` 🚧、
`inset` / `spaced` / `thick` / `size` / `color` ❌ M1、默认槽/前后槽 ❌ M1、`oriented` 作用域 ⛔。

## NovaRipple ← v-ripple 指令（审计 0.3.0）

`color` / `center` / 挂载即用 ✅ / 🚧（`center` M1）。触发灵敏度（early-ripple 取消策略，
Quasar 2.26 改进）🚧 M1 对齐。

## NovaTheme ← brand 变量 + Dark 插件（审计 0.3.0）

| Quasar API | 状态 | 说明 |
|---|---|---|
| `$primary/secondary/accent/dark/positive/negative/info/warning` | ✅ | 8 色品牌变量 1:1（0.3.0 起 `dark` 直接同名） |
| `$q.dark.isActive` | ✅ | `isDark` |
| `$q.dark.set()` / `toggle()` | ✅ | `setDark(v)` / `toggleDark()` |
| `$q.dark.setAll()` / `auto`（跟随系统） | ❌ | M1 排期（QGuiApplication palette 联动） |
| `setBrand()` 换肤 | ✅ | 主色级；完整 brand 批量 API M1 |

## NovaScreen ← Screen 插件（审计 0.3.0）

`width/height/name/isXs…isXl/lt*/gt*/isMobile/setThresholds` ✅ 全量。
`sizes` 响应式 CSS 类、`bodyClasses`（DOM 概念）⛔。滚动/键盘可见性插件（Quasar 其他插件）按
M1/M2 排期在 ROADMAP 跟踪。


## NovaLayout / NovaHeader / NovaFooter / NovaPage ← QLayout 系列（审计 0.5.0）

| Quasar API | 类型 | 状态 | 说明 |
|---|---|---|---|
| QLayout 四象限（header/footer/drawer/page） | 结构 | ✅ | 子项**按类型自动归位**（instanceof 扫描），对标 QLayout 的组件探测机制 |
| `view="hHh lpr fFf"` 视图矩阵 | prop | 🚧 | v0.5 固定"顶/底通栏 + 抽屉夹中"形态；自定义矩阵 M2 |
| QHeader/QFooter `reveal` 滚动隐藏 | prop | ❌ | 需滚动容器联动，M2 与 QScrollArea/NovaScrollArea 一并交付 |
| QHeader `elevated` / `bordered` | prop | 🚧 | bordered ✅（tint 之上）；elevated 阴影 M2 |
| QDrawer `side` / `width` / `mini` / `mini-width` | prop | ✅ | 映射 side / size / mini / miniWidth |
| QDrawer `overlay` / `behavior`（desktop/mobile） | prop | ✅ | overlay ✅；behavior 由 breakpoint 自动判定（宽→push，窄→overlay） |
| QDrawer `breakpoint` / `bordered` / `elevated` | prop | ✅/🚧 | breakpoint/bordered ✅；elevated 阴影仅 overlay 模式 ✅ |
| QDrawer `open`（v-model） | prop | ✅ | `open` + `opened()`/`closed()` 信号 |
| QPageContainer/QPage `padding` / `style` | prop | ✅/🚧 | padding ✅；style 类名语义 ⛔（QML 无 CSS） |
| QPageSticky / QPageScroller | 组件 | ❌ | 🚧 M1 Sprint 1 收尾或 M2 |

## NovaRow / NovaCol / NovaVisible ← Flex 栅格 + 可见性工具类（审计 0.5.0）

| Quasar API | 类型 | 状态 | 说明 |
|---|---|---|---|
| `row` / `col-xs/sm/md/lg/xl-N` | class | ✅ | NovaRow + NovaCol.cols（12 栅格 × 5 断点中先支持固定 cols，断点响应式 cols 🚧 M2） |
| `offset-*-N` | class | ✅ | NovaCol.offset（推挤后续列，语义与 CSS margin 一致） |
| `q-gutter-*` | class | ✅/🚧 | NovaCol.gutter（列内边距）+ NovaRow.spacing（列间距）；q-col-gutter 变体 🚧 |
| `justify-*` / `items-*` | class | ✅ | justify: start/center/end/between；align: top/center/bottom（around/stretch 🚧 M2） |
| `wrap` / 自动换行 | class | ✅ | NovaRow.wrap |
| `gt-md` / `lt-sm` / `xs-only` 等可见性 | class | ✅ | NovaVisible.above / below / only（语义重命名：gt→above、lt→below、only 保留） |
| `desktop-only` / `mobile-only` | class | 🚧 | 可由 above/below 组合表达；专用糖属性 M2 |


## NovaNotify ← Notify 插件（审计 0.6.0）

对标基线 `quasar@2.35.5`（npm 包源码 `ui/src/plugins/notify/Notify.js` + `dist/api/Notify.json`
逐项核对；文档页漏记 `ignoreDefaults`，一律以包内源码为准，不按文档页凭记忆写）。

| Quasar API | 类型 | 状态 | 说明 |
|---|---|---|---|
| `Notify.create(config)` / `$q.notify()` | method | ✅ | 映射 `NovaNotify.show(config)`；返回句柄由裸函数升级为 `NovaNotifyHandle`（QObject，可绑定/可观测） |
| `Notify.setDefaults(opts)` | method | ✅ | 生效顺序照抄基线：内置类型预设 → defaults → 本次 config |
| `Notify.registerType(name, opts)` | method | ✅ | 自定义类型注册表 |
| `type`（内置 5 值 + 自定义） | prop | ✅ | positive/negative/warning/info/ongoing 预设 1:1（warning `textColor: dark`；ongoing group:false/timeout:0/spinner；基线 grey-8 → NovaTheme.dark 令牌映射） |
| `color` / `textColor` / `iconColor` / `spinnerColor` / `badgeColor` / `badgeTextColor` | prop | ✅ | 命名红线：统一 `tint` / `textTint` / `iconTint` / `spinnerTint` / `badgeTint` / `badgeTextTint` |
| `message` / `caption` | prop | ✅ | 空白判定对齐基线 `hasContent` |
| `html` | prop | ⛔ | QML 无 DOM 且基线该选项自带 XSS 面（0.5.1 D2 裁定）；替代 `contentDelegate: Component`（作用域槽，宪法第 4 章） |
| `icon` / `iconSize` / `avatar` | prop | ✅ | icon 走 NovaIcon 双通道；`none` 占位不渲染语义保留；iconSize 基线 CSS 串 → real px（改型） |
| `spinner`（Boolean\|Component）/ `spinnerSize` | prop | ✅ | `true` → 内置最小转圈（0.5.1 D4 裁定，Sprint 4 后可换 NovaSpinner）；组件形态 → `spinnerDelegate` 作用域槽 |
| `position`（9 值） | prop | ✅ | 插入规则照抄：top 系头插 / bottom 系尾插 / left·right·center 中线插入；拼错基线静默回落 bottom，Nova 拒绝返回 null（改型） |
| `group`（Boolean\|String\|Number） | prop | ✅ | 分组键逐条复刻：`message\|caption\|multiLine\|label*icon…` 再拼 `\|position`；同按钮文案不同 → 不同组；数字键归一字符串 |
| `badgePosition`（4 值） | prop | ✅ | 默认：position 含 left → top-right，否则 top-left（基线一致） |
| `badgeStyle` / `badgeClass` / `progressClass` / `classes` | prop | ⛔ | QML 无 CSS class/style 体系；`badgeDelegate` 规划 M2 |
| `attrs` | prop | ⛔ | QML 无 HTML 属性；无障碍改 `Accessible.*`（M2 批次） |
| `timeout`（默认 5000；0 = 常驻） | prop | ✅ | 无效值（undefined/null/true/false/''/负数）回落 5000；`timeout: 0` → progress 强制 false |
| `progress` | prop | ✅ | 进度条动画时长 = timeout+1000，与消失时刻对齐（1000 = 入场动效，基线 transition 1s） |
| `actions[]` | prop | ✅ | `NovaNotifyAction`：label/icon/tint/textTint/noDismiss/handler + `triggered()` 信号；handler→信号/回调双通道；点击顺序契约：triggered 先行、dismissed 后至；按钮内图标渲染 🚧 Sprint 4 图标 provider |
| `closeBtn`（Boolean\|String） | prop | ✅ | true → "关闭"文案（Nova 暂无 lang 插件，🚧 M2 接 NovaLang）；关闭原因 user |
| `multiLine`（未指定 = actions>1） | prop | ✅ | 必须在 actions 定稿后计算（分组键依赖） |
| `onDismiss` | event | ✅/🔁 | on\* 红线 → 信号 `dismissed(reason)`；⚠ 基线 `onDismiss()` **无参数**（2.35.5 源码核实，"关闭原因上报"属 Dialog/BottomSheet），reason 为 Nova 增强 |
| 默认槽 / 作用域槽 | slot | ✅ | `contentDelegate` / `spinnerDelegate`（宪法第 4 章槽机制） |
| 句柄 dismiss() / update(props) | api | ✅ | 分组通知只能 dismiss（update 拒绝返回 false）；update 合并 config+props、group 强制 false、position 不变、重置计时器与进度条 |
| `ignoreDefaults` | prop | ⛔ | 0.5.1 D5 裁定不暴露（Nova 无 quasar.config 注入场景） |

**Nova 增强（增强栏，不入已对齐栏）**：

| 增强 | 说明 |
|---|---|
| `dismissed(reason)` 6 值枚举 | timeout / user / action / api / replaced / overflow（replaced 静默换装无动效，对齐基线；overflow 由同屏上限产生） |
| `maxVisible`（默认 5） | 同屏上限，MASTER_PLAN Sprint 2 验收项"同屏 ≤5 条"；超限淘汰最旧一条 |
| `NovaNotifyHandle.valid` | 基线 dismiss 后句柄变静默空函数；QML 语境提供显式失效态 |
| `countAt(pos)` / `dismissAll(pos)` / `maxVisible` | 队列内省与批量管理（测试/自动化/调试面） |
| `NovaNotificationItem.triggerAction(i)` | 程序化触发动作，等同点击（自动化复用） |
| `NovaOverlayHost` 单例 + `NovaTheme` z 令牌族 | 全局弹层宿主 + `$z-*` 1:1 层叠令牌（zNotify=9500），Dialog/Loading 复用 |

冒烟测试覆盖：解析/实例化 + 分组徽标、组键含 actions、group:false、自定义组替换、更新语义、
动作点击顺序、closeBtn user、overflow、timeout 到期、非法输入、Dark 实例化（宪法第 5 章强制用例）。


## NovaDialog ← Dialog 插件（审计 0.6.1，npm 2.35.5 dist/api/Dialog.json 逐项核实 · 27 项）

| Quasar 配置项 | 类型 | 状态 | 说明 |
|---|---|---|---|
| `title` / `message` | prop | ✅ | 标题 + 正文；均支持句柄 update |
| `ok` / `cancel` | prop | ✅ | 三态 true/false/string + 对象（label/tint/variant/flat）；默认双按钮 flat |
| `focus` | prop | ✅ | ok / cancel / none |
| `stackButtons` | prop | ✅ | 单列堆叠（默认双列右对齐） |
| `position` | prop | ✅ | standard/top/right/bottom/left；非法值直接拒绝（不静默回落） |
| `persistent` / `noEscDismiss` / `noBackdropDismiss` | prop | ✅ | 三档关闭策略，互不串味；程序化 api 仍可关 |
| `seamless` / `maximized` / `fullWidth` / `fullHeight` | prop | ✅ | 形态四开关 |
| `transitionShow` / `transitionHide` | prop | ✅ | scale / fade / none（映射内置过渡子集） |
| `color` | prop | ✅ | 映射 `tint`（命名红线：基调色叫 tint） |
| `dark` | prop | 🚧 | 当前跟随 NovaTheme 全局明暗（宪法第 5 章路径）；单框局部覆盖 M2 |
| `progress` | prop | ✅/🚧 | bool + `{message}` ✅；自定义 spinner 组件 🚧 M2 |
| `html` | prop | ⛔→增强 | 不移植（QML 无 DOM + XSS 面），改 `contentDelegate`（Nova 增强） |
| `class` / `style` | prop | ⛔ | QML 无 CSS 类/行内样式；由 `tint`/radius 令牌替代 |
| `noRouteDismiss` | prop | ⛔ | QML 无路由概念（不适用） |
| `prompt` | prop | 🚧 | 依赖 NovaInput，二期表单批交付后补 |
| `options` | prop | 🚧 | 依赖 NovaRadio/NovaCheckbox，二期补 |
| `component` / `componentProps` | prop | 🚧 | 当前用 `contentDelegate` 覆盖正文；整卡组件替换 M2 |
| 句柄：`hide()` / `update()` / `onOk` / `onCancel` / `onDismiss` | API | ✅ | hide/update ✅；回调改名承载为 `accepted`/`rejected`/`dismissed(reason)` 三信号（on\* 撞 QML 红线） |
| `dismissed(reason)` 五值 | 事件 | ✅ | ok/cancel/backdrop/escape/api —— **基线 2.28 真 parity**（与 Notify 不同，勿混） |
| `ok()` / `cancel()` | API | ✅增强 | Nova 增强：程序化触发按钮，自动化测试友好 |
| `count()` / `activeDialogs()` / `hideAll()` | API | ✅增强 | Nova 增强：内省与批量关闭 |

## NovaLoading ← Loading 插件（审计 0.6.2，npm 2.35.5 dist/api/Loading.json 逐项核实 · 11 项）

| 基线配置 | Nova | 判定 |
|---|---|---|
| delay | delay（默认 500 同基线） | ✅ |
| message | message | ✅ |
| group | group（默认 `__default_quasar_group__` 1:1） | ✅ |
| spinnerSize | spinnerSize | ✅ |
| spinnerColor | spinnerTint（命名规范 tint） | ✅ 改名 |
| messageColor | messageTint | ✅ 改名 |
| backgroundColor | backgroundTint | ✅ 改名 |
| spinner（QSpinner 组件） | spinnerModel: ring/dots/pulse | 🚧 四期 NovaSpinner 就绪后开放组件注入 |
| html | —（XSS 面 + QML 无 DOM） | ⛔ 留痕 |
| boxClass / customClass | boxed（布尔卡片化） | ⛔→映射（无 CSS 类体系） |

- `hide(group)` 对标基线 = 按组立即关闭；**句柄 hide() 是 Nova 增强的引用计数语义**
  （同组多次 show 各持一份引用，归零才收口）——两者刻意区分，防混用
- Nova 增强：`target`（局部加载）/ `timeout`（卡死兜底）/ `increment / decrement / count /
  activeGroups / activeCount / isActive / hideAll / setDefaults` / 句柄 `valid/count/item`

## NovaStorage ← LocalStorage 插件（审计 0.6.2）

- API 面 1:1：`set/get/has/remove/clear/getAll/getAllKeys/getLength/isEmpty/setAll`
  + Web Storage 别名 `setItem/getItem/removeItem` ✅
- 后端裁定：Quasar 走浏览器 localStorage；Nova 走 Python `Nova.Runtime` 的 QSettings ini
  （AppDataLocation/nova-storage.ini）——纯 QML 的 Settings 类型在应用未设 organizationName 时
  直接失效（0.6.2 实测），不可作为企业级默认
- Nova 增强：`useNamespace()` 命名空间隔离（基线无此概念）；`reload()/flush()` 显式同步；
  JSON 损坏安全降级；getAll 深拷贝
- SessionStorage 语义：由 `clear()` + 不持久模式承载（QML 无 per-tab 存储），记录不移植

## NovaApp ← AppFullscreen + AppVisibility + Meta（审计 0.6.2）

| 基线 | Nova | 判定 |
|---|---|---|
| $q.fullscreen.request/exit/toggle/isActive | request/exit/toggle/isFullscreen | ✅ |
| $q.fullscreen.isCapable | isCapable（窗口存在即可） | ✅ |
| $q.appVisible | isVisible / isActive（窗口级近似） | ✅ 映射 |
| $q.meta.set({ title }) | setTitle / title（document.title → 窗口 title） | ✅ 映射 |
| page URL / meta 标签 | — | ⛔ 不适用（无浏览器文档模型） |
- Nova 增强：`setVisibility` 统一入口（fullscreen/maximized/minimized/windowed）、
  退出全屏自动回落进入前状态、`show/hide/snapshot()`

## NovaPlatform ← Platform 插件（审计 0.6.2）

| 基线 | Nova | 判定 |
|---|---|---|
| is.windows/mac/linux/ios/android | isWindows/isMac/isLinux/isIOS/isAndroid | ✅ |
| is.desktop / is.mobile | isDesktop / isMobile | ✅ |
| has.touch | hasTouch（后端 QInputDevice 枚举 TouchScreen；无后端回落"移动系统即有触摸"） | ✅ 换实现路径 |
| is.chrome/firefox/safari 等内核判定 | — | ⛔ 不适用 |
| has.webAuthn / within.iframe / within.webView / is.pwa / is.electron | — | ⛔ 不适用（浏览器/Electron 专属） |
- Nova 增强：`osVersion / cpuArch / describe() / snapshot() / reducedMotion`（五期 a11y 接管真实系统值）

## L3 行为层总审计（0.7.0，npm quasar@2.35.5 src/directives/*/*.json 逐项核实）

### NovaIntersection ← v-intersection（审计 0.7.0）

| 基线 | Nova | 判定 |
|---|---|---|
| value: Function(handler) | `onIntersect(entry)` 信号（每次跨阈值/翻转） | ✅ 映射 |
| value: {handler, cfg{root, rootMargin, threshold}} | `root` + `rootMarginTop/Right/Bottom/Left` + `threshold`（数字/数组） | ✅ 映射（rootMargin 字符串拆四向 real，更 QML） |
| value: false / null / undefined（禁用） | `enabled: false`（重开即重新武装） | ✅ |
| modifiers.once | `once: true` + `rearm()`（对标 setOnce） | ✅ |
| handler 返回 false（停止） | `stop()` | ✅ 映射 |
| entry 七字段 | target/isIntersecting/intersectionRatio/boundingClientRect/intersectionRect/rootBounds/time 1:1 | ✅ |
| 浏览器原生 IntersectionObserver | NovaIntersectionPool 帧轮询 + 自算矩形交集（含祖先 clip 链） | 🔄 实现路径（比例是精确值；pollInterval 可调） |
| 2.30 共享 observer 池 | NovaIntersectionPool 单例：N 订阅者共用一个 Timer 驱动源 | ✅ 架构复刻 |

- Nova 增强：`entered/exited` 状态信号、`kick()` 立即求值、`observing/intersectionRatio` 只读状态

### NovaScrollObserver ← v-scroll（审计 0.7.0）

- 基线 `Function(vertical, horizontal)` → `onScroll(details)`；details 另含 deltaY/deltaX/
  direction/atTop/atBottom/atLeft/atRight（Nova 增强）✅
- root 解析：显式 root → 最近可滚动祖先（Flickable/ListView/GridView）→ 窗口视口（基线固定窗口，Nova 更通用）✅
- 与 Intersection/ScrollFire 共用 NovaIntersectionPool 驱动源（对标 2.30 共享架构）✅

### NovaScrollFire ← v-scroll-fire（审计 0.7.0）

- `Function(el)` 触发一次 → `onFire(item)`；arg 0~1（v2.30）→ `threshold` 属性 ✅
- 禁用期重新赋值可再武装 → 触发后 `armed=false`，`rearm()` / enabled 开关再武装 ✅
- v2.30 起与 v-intersection 共享 observer → Nova 直接复用 NovaIntersection（同池同算法）✅

### NovaClosePopup ← v-close-popup（审计 0.7.0）

| 基线 | Nova | 判定 |
|---|---|---|
| value 0 / 'false'（禁用） | `depth: 0` | ✅ |
| value < 0（关整链） | `depth: -1` → `closePopups(-1)` | ✅ |
| value 1 / 'true' / undefined（关父层） | `depth: 1`（默认） | ✅ |
| value > 1（关 N 层） | `depth: N` | ✅ |
| click + keyup(Enter 13) | clicked 信号桥接 + Keys（Key_Return/Key_Enter） | ✅ |
| setTimeout(0) 延迟关（让 @click 先跑） | QML 信号处理器天然同步完成，无需延迟 | ✅ 等价 |
| portal 链（getPortalProxy/closePortals） | NovaOverlayHost 弹层栈（registerPopup/closePopups） | 🔄 实现路径（NovaDialog 已接入） |
- Nova 增强：`closed(count)` 信号（实际关闭层数）、`trigger()` 程序化触发、`usePointer` 指针兜底、`reason` 可指定关闭原因

### NovaTouchPan ← v-touch-pan（审计 0.7.0）

- details 十一字段 1:1：evt(null)/touch/mouse/position{top,left}/direction/isFirst/isFinal/
  duration/distance{x,y}/offset{x,y}(带符号)/delta{x,y} ✅
- 修饰映射：stop→stopPropagation、prevent→preventStealing、mouseAllDir→allDirections、
  preserveCursor→preserveCursor、horizontal/vertical→同名、up/right/down/left→directions 数组 ✅
- 差异：基线鼠标无独立起判阈值，Nova 统一 `threshold: 8px`（增强，可调）；evt 传 null（QML 无 DOM 事件对象）⛔
- Nova 增强：`panning` 只读状态、`threshold` 可调

### NovaTouchSwipe ← v-touch-swipe（审计 0.7.0）

- arg "6e-2:6:50"（minVelocity:touchMinDistance:mouseMinDistance）→ 三个独立属性，默认值同基线 ✅
- details：direction/duration/distance{x,y} 1:1；另给 `velocity`（Nova 增强）✅
- 语义同基线：移动中判定即触发（不等松手），Nova 附加松手兜底一次；方向/轴向过滤同基线 ✅

### NovaTouchHold ← v-touch-hold（审计 0.7.0）

- arg "600:5:7"（duration:touchSensitivity:mouseSensitivity）→ 三个属性，默认值同基线 ✅
- details：touch/mouse/position/duration 1:1 ✅
- Nova 增强：`onCancel`（位移超限/提前松手显式通知）、`holding` 进度源、`held` 状态

### NovaTouchRepeat ← v-touch-repeat（审计 0.7.0）

- arg "0:600:300"（首帧/第二次/之后）→ `delays` 属性（字符串同格式，末值复用、防 0 延迟自旋）✅
- details 九字段 1:1：touch/mouse/keyboard/position(仅指针)/keyCode(仅键盘)/duration/repeatCount/startTime ✅
- 键盘修饰（esc/tab/enter/space/up/left/right/down/delete/[键码]）→ `keys` 数组（Qt.Key 值）+ `keyRepeat` 开关 ✅ 映射

### L3 不适用项留痕（⛔）

- **v-morph**：依赖 DOM 元素变形过渡（morph transitions between DOM elements）；QML 无 DOM，
  等价能力由 Loader + Behavior/Transition 天然承担，不做指令化移植
- **v-mutation**：监听 DOM MutationObserver；QML 属性变化本身就是信号（property 变更通知），
  能力天然存在，无需指令
- **v-resize**：监听元素尺寸变化；QML `onWidthChanged/onHeightChanged` 原生信号，同上
- **v-drop-zone**：HTML5 拖放（dataTransfer）；QML 有 DropArea + urls 通道，五期文件交互时再评估

## 审计纪律（宪法第 3.5 条）

1. 新组件交付 = 宪法迭代 + **本文件新增审计节**（属性/事件/槽/model 逐项列明）
2. ❌ 项必须标注目标里程碑；⛔ 项必须写明 QML 语境理由
3. 封版（1.0.0-flagship）前，✅ 占比门禁：P0 组件 ≥90%，全库 ≥85%
