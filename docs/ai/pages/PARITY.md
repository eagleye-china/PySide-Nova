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

## L0 设计语言总审计（0.8.0，npm quasar@2.35.5 icon-set/*.js + src/css/core/*.sass 逐项核实）

### NovaIconSet ← $q.iconSet + IconSet 插件（审计 0.8.0 · 100 语义键 × 14 套）
- 语义键：mdi-v7 为基准 19 组 100 叶子键 1:1（type/arrow/chevron/colorPicker/pullToRefresh/carousel/
  chip/datetime/editor(42)/expansionItem/fab/field/pagination/rating/stepper/tabs/table/tree/uploader）；
  material 系缺 editor.heading1~6/size1~7 共 13 键——与基线一致（IconSet.json 标注"可省略，回落 heading/size"）
- `set(obj)` 顶层浅合并（整组替换）1:1；`use(name)` 对标 install(iconSet)；`register()` 以 mdi-v7 全键
  补底为 Nova 增强；任务描述中的 nav.*/header.*/notify.* 等键在 2.35.5 中不存在，未收录
- 归一化解析 1:1 对标 QIcon.parseIcon：img: / svguse: / ion-*（平台前缀）/ sym_[ors]_ / libMap 九前缀 /
  FA 旧式类名 / SVG path（&&、|viewBox、@@）/ o_r_s_ 连字变体；`svguse:` 与 `i-`(UnoCSS) 显式
  unsupported 留痕（QML 无对应能力）
- provider CDN 模板 2026-11-22 实测 200：mdi@7.4.47、material-design-icons、material-symbols(svg-400)、
  ionicons@7、eva-icons@1.1.3(outline/svg/，文件名带 -outline 后缀)、fontawesome-free@6.7.2（FA5→FA6
  改名内置 44 条别名表）、bootstrap-icons@1.11.3、line-awesome@1（<name>-solid.svg）
- ⛔ themify：仅 woff 字体分发，无逐图标 SVG（实测 404）→ 图标集数据保留，资源通道需自备本地图标包

### NovaMotion ← transitions.sass + animations.sass（审计 0.8.0）
- 时长/缓动：--q-transition-duration .3s、--animate-duration .3s、q-animate--scale .15s、
  q-animate--fade .2s；cubic-bezier(0.215,0.61,0.355,1)=Easing.OutCubic 1:1
- 预设过渡 15 种 1:1（q-transition--fade/scale/rotate/slide-right·left·up·down/jump-right·left·up·down/
  flip-right·left·up·down）；enter-from 与 leave-to 非对称语义保留（两组独立动画）
- Nova 增强：speedFactor 调速、reducedMotion 全链短路（基线 prefers-reduced-motion 只覆盖 .animated）

### NovaTheme 排版/高程 ← typography.sass + elevation.sass（审计 0.8.0）
- typeScale 12 级 1:1（$headings map，rem×16→px、letterSpacing=em×size）：h1 96/96/-1.5/300、
  h2 60/60/-0.5/300、h3 48/50/0/400、h4 34/40/0.25/400、h5 24/32/0/400、h6 20/32/0.25/500、
  subtitle1 16/28/0.15/400、subtitle2 14/22/0.1/500、body1 16/24/0.5/400、body2 14/20/0.25/400、
  overline 12/32/2/500、caption 12/20/0.4/400；body 14px/1.5
- 字重六档（$text-weights：100/300/400/500/700/900）；基线无响应式字阶缩放（grep 全包无 @media），
  Nova 同样固定
- elevation 三层几何 0~24（umbra/penumbra/ambient）入册；QML 无多层 box-shadow，数值供 MultiEffect
  组合，属"部分映射"

### NovaText ← text-* 工具类（审计 0.8.0）
- typography 12 级 / muted / strike / italic / upper（text-uppercase→font.capitalization 原生映射）；
  text-justify 在 QML 无通用对齐（Qt 6.6+ AlignJustify 场景有限），未硬编码，留痕

## L5 工具层总审计（0.8.0，npm quasar@2.35.5 src/utils/* 逐函数核实）

### NovaUtils.colors ← src/utils/colors/colors.js（12 具名导出）
- 12 函数全移植：rgbToHex/rgbToText/hexToRgb/hsvToRgb/rgbToHsv/textToRgb/lighten/luminosity/brightness/
  blend/changeAlpha；a 全链 0..100 百分制；changeAlpha 无 alpha 基准 0、offset 限 -1..1 1:1；
  lighten 负数即 darken 1:1；blend source-over 合成、入参 string 返回 hex 1:1
- ⛔ getPaletteColor（document+getComputedStyle）不适用；Nova 增强：contrastRatio/contrastColor（WCAG）

### NovaUtils.date ← src/utils/date/date.js（23 具名导出）
- formatDate 44 token 全覆盖（6 序数 + aa 点分 + Z/ZZ/X/x），literal [...] 原样输出（基线语义）；
  mask===undefined 走 defaultMask（YYYY-MM-DDTHH:mm:ss.SSSZ）；**有意偏差**：mask===null 基线抛错、
  Nova 回落 defaultMask（QML 绑定空值友好，见 CHANGELOG）
- addToDate/subtractFromDate 单位 14 别名 1:1（year(s)/month(s)/day(s)/date/hour(s)/minute(s)/
  second(s)/millisecond(s)；week/quarter 不支持同基线）；月末日夹取（先 setDate(1)）1:1
- getWeekOfYear 纯 ISO 8601（无 firstDayOfWeek/firstWeekMinDays 参数，2.x 已收敛）1:1；
  isBetweenDates opts={inclusiveFrom,inclusiveTo,onlyDate} 默认两端开区间 1:1，
  **Nova 增强**：'[]' '[)' '(]' '()' 字符串写法；isSameDate 未知 unit 抛错 1:1
- adjustDate/buildDate/startOfDate/endOfDate/getDateDiff/getDayOfYear/getISOWeekYear/getDayOfWeek/
  daysInMonth/getMaxDate/getMinDate/getDateBetween/inferDateFormat/isValid/clone 全部移植
- extractDate 覆盖常用 token 子集解析（YYYY/YY/M*、D*、H*/h*/m*/s*/S*、A*/a*/aa、Z/ZZ、X/x），
  其余 token 宽松吞掉——格式化侧 44 全覆盖、解析侧子集，如实留痕
- ⛔ __splitDate/persian 历法不移植（内部函数 + QDate 侧原生承担）

### NovaUtils 其余 ← format/is/extend/debounce/throttle/frame-debounce/uid
- format 6 函数 1:1（humanStorageSize parseInt>=1024 边界、getDecimalsCount 指数处理、pad null 透传）
- is 5 函数 1:1（isObject 排除数组、deepEqual 过滤 undefined 键、NaN 同判定）
- extend：deep 标志、__proto__ 跳过、undefined 不覆盖 1:1；单参调用基线会崩（this===undefined），
  Nova 显式重置 target={}，为有意偏差
- debounce(fn, wait=250, options)：leading/trailing/maxWait/isPending/cancel/flush 1:1；
  throttle：尾跑补齐重开窗口、返回上次结果、cancel/flush 1:1
- **Nova 增强/降级留痕**：frameDebounce 无 rAF → 16ms Timer 等价；uid 无 crypto.randomUUID →
  时间戳+计数+随机 v4 形态（碰撞抗性弱于基线）；无 setTimeout → Timer Component 内联创建
- ⛔ dom 9 项 / event 14 项 / scroll 12 项不适用（QML Item 几何、MouseArea accepted、Flickable contentY
  原生承担）

## 审计纪律（宪法第 3.5 条）

1. 新组件交付 = 宪法迭代 + **本文件新增审计节**（属性/事件/槽/model 逐项列明）
2. ❌ 项必须标注目标里程碑；⛔ 项必须写明 QML 语境理由
3. 封版（1.0.0-flagship）前，✅ 占比门禁：P0 组件 ≥90%，全库 ≥85%

---

## §0.9 二期 Sprint A · 表单核心七件（0.9.0，对标 Quasar 2.35.5 npm 原包逐项核对）

### NovaField ↔ QField（use-field 29 + use-validate 7 props）

| 基线 props | Nova | 备注 |
|---|---|---|
| label / stack-label / hint / hide-hint / prefix / suffix | ✅ 1:1 | 浮动 label 语义（stackLabel/聚焦/有值浮起） |
| label-color / color / bg-color / dark | ✅（color→tint） | dark 随 NovaTheme.isDark 全局承担 |
| loading / clearable / clear-icon | ✅ 1:1 | clearIcon 留 props（视觉用内置十字绘制，无网络依赖） |
| filled / outlined / borderless / standout | ✅ 1:1 | 互斥优先级 outlined > standout > filled > borderless |
| rounded / square / dense / hide-bottom-space | ✅ 1:1 | |
| counter | ✅ | 基线 bool 由子类算长；Nova 另增 counterText 自定义 |
| label-slot / bottom-slots | ⭕ 部分 | labelSlot 语义保留；bottom 插槽底行内置三位（hint/error/counter） |
| item-aligned / for / tag | ❌ 留痕 | item-aligned 表格场景四期；for 为 QML 保留字 → `name`；tag 不适用 |
| error / error-message / no-error-icon / rules / reactive-rules / lazy-rules | ✅ 1:1 | 校验引擎：函数规则 + 内置字符串 required/minlen(n)/maxlen(n)/len(n)/email；错误图标不适用（底行红字承担） |
| model-value（use-validate） | ✅ | 走 value 属性接线，子类注入 |

### NovaInput ↔ QInput（8 props）

| 基线 props | Nova | 备注 |
|---|---|---|
| model-value / model-modifiers / type / debounce / autogrow / shadow-text | ✅ 1:1 | type 含 textarea（TextArea 自增高）；modifiers number/trim/capitalize |
| input-class / input-style | ❌ 留痕 | CSS 通道不适用 QML；由 NovaText/typeScale 承担 |
| maxlength（HTML） | ✅ Nova 增强 | 基线由属性透传 DOM；Nova 显式 prop |

### NovaSelect ↔ QSelect（47 props，收口 24）

| 基线核心 | Nova | 备注 |
|---|---|---|
| options / option-value / option-label / option-disable | ✅ 1:1 | 标量/对象数组归一化 |
| model-value / multiple / emit-value / max-values | ✅ 1:1 | 多选上限拒收返回 false |
| display-value / dropdown-icon / hide-dropdown-icon / no-option-label | ✅ 1:1 | |
| use-input（过滤） / options-dense / options-cover | ✅ | cover 简化为向上弹 |
| use-chips / new-value-mode / map-options / menu-* 五 props / virtual-scroll-* / behavior / transition-* / popup-* / options-html / options-dark / options-selected-class / fill-input / autocomplete / tabindex / display-value-html / hide-dialog-close / popup-no-route-dismiss / disable-tab-selection / no-chip-remove / no-option-prefetch / on-filter / on-new-value | ⭕/❌ 二期 B 起 | chips 与 onFilter/onNewValue 入 v0.10.0；menu 定制/虚拟滚动随 OverlayHost 演进；inputClass/inputStyle 不适用；@new-value 以 signal newValue 落位 |

### NovaCheckbox / NovaRadio / NovaToggle ↔ use-checkbox(18) / QRadio(12) / QToggle(+2)

| 基线 props | Nova | 备注 |
|---|---|---|
| model-value / val / true-value / false-value / indeterminate-value / toggle-order / toggle-indeterminate | ✅ 1:1 | 半选循环 order0 t→f→i→t / order1 f→t→i→f；toggle()/select() 只发信号不自写（受控模式，坑位 22） |
| label / left-label / keep-color / dense / disable / dark / tabindex | ✅（tabindex→activeTab） | dark 随主题 |
| checked-icon / unchecked-icon / indeterminate-icon | ✅ | 默认内置绘制勾/横线（零网络依赖），显式指定走 NovaIcon |
| QToggle icon / icon-color | ✅ 1:1 | 滑块内置图标 |
| error / hint（契约统一） | ✅ Nova 增强 | 基线经 QForm 校验态注入；Nova 直挂组件 |
| clearable / rules | ❌ 留痕 | 契约对 checkbox 族不适用（与基线一致） |

### NovaSlider ↔ QSlider（use-slider 33 + label-value/model-value）

| 基线 props | Nova | 备注 |
|---|---|---|
| min / max / inner-min / inner-max / step / snap / reverse / vertical | ✅ 1:1 | step 恒量化 + 夹取；posToValue/setValue 公开 |
| color→tint / track-color / selection-color / thumb-color / track-size / thumb-size / dark / dense / disable / readonly / tabindex | ✅ | |
| label / label-always / label-value / label-color / label-text-color / switch-label-side | ✅ 核心 | 气泡配色随 tint；switch-label-side 四期 |
| markers / marker-labels | ✅ | true=数值 / 数组=自定义 / 数字=间隔；上限 200 刻点 |
| track-img / inner-track-img / selection-img / thumb-path / marker-labels-class / switch-marker-labels-side | ❌ 留痕 | 图片贴图与样式类不适用 QML |
| events：update:model-value / change | ✅ | valueChanged 信号 + changed()（释放/键盘提交）；键盘 ←→↑↓/Home/End |

> 测试口径：13 条实例化冒烟 + 12 个行为用例（FORM_ENV_QML 驱动代理），合计 0.9.0 新增 25 项。

---

## §0.10 二期 Sprint B · 输入进阶八件（0.10.0，对标 Quasar 2.35.5 npm 原包逐项核对）

### NovaRange ↔ QRange（20 props）

| 基线 props | Nova | 备注 |
|---|---|---|
| model-value / min / max / step / snap / reverse / vertical | ✅ 1:1 | 双值 {min,max} 归一（逆序交换） |
| left-thumb-color / right-thumb-color / left-label-value / right-label-value / left(right)-label-color·text-color | ✅ 核心 | 气泡配色随 tint；label-color 双端独立留四期 |
| min-range / max-range | ✅ 1:1 | setRange 内强制约束（minRange 拉右滑块 / maxRange 压右滑块） |
| drag-range / drag-only-range | ⭕ 部分 | dragRange=整段随右滑块平移；drag-only-range 延后 |
| left(right)-thumb-aria-label / aria | ❌ 留痕 | QML 无 aria 通道 |
| events：update:model-value / change | ✅ | valueChanged + changed()（释放/键盘提交） |

### NovaDate ↔ QDate（23 props；Qt 6 无内置日历——全自研）

| 基线核心 | Nova | 备注 |
|---|---|---|
| model-value / mask / multiple / range | ✅ 1:1 | mask→正则解析 + NovaUtils.date.formatDate 输出（44 token 全量复用）；range pending 两击闭合、逆序交换 |
| first-day-of-week / title / subtitle / minimal | ✅ 1:1 | title/subtitle 空串自动派生 |
| navigation-min(year-month) / navigation-max | ✅ 1:1 | 翻月双向夹取返回 false |
| today-btn / no-unset / required / events / event-color / options | ✅ 1:1 | events 数组或函数；options fn(date)->bool |
| default-view / years-in-month-view / event-from / emit-immediately / validator / default-year-month | ⭕/❌ 留痕 | 年月视图选择器随 OverlayHost 演进；emit-immediately 三期；validator 五期表单深度集成 |
| type: date→datetime | ⭕ | datetime 由 NovaDate+NovaTime 组合承担（四期页面级） |

### NovaTime ↔ QTime（14 props）

| 基线核心 | Nova | 备注 |
|---|---|---|
| model-value / format24h / with-seconds | ✅ 1:1 | 内部恒 24h 制存储；12h 显示 AM/PM 切换偏移 |
| hour-options / minute-options / second-options | ✅ 1:1 | set 拒绝返回 false |
| now-btn / mask / required / validator / default-date | ✅核心/⭕ | mask 输出固定 HH:mm(:ss)（自定义 mask 五期）；default-date 留痕 |
| 时钟面盘实现 | ✅ Nova 增强 | Canvas 三面（时数字环/分秒 60 刻点），选拔自动进分面（基线手感） |

### NovaColorPicker ↔ QColor（16 props）

| 基线核心 | Nova | 备注 |
|---|---|---|
| model-value / default-value / format-model(hex·rgb) / palette | ✅ 1:1 | 无默认值不产出（null）；rgb 输出 "rgb(r,g,b)" |
| no-footer / no-header / flat / bordered / disable / readonly | ✅ 1:1 | |
| default-view / no-header-tabs / square | ⭕ 部分 | 默认 spectrum 单视图；square 视觉留四期 |
| rgb/hsl 编辑器、alpha 通道（hexb/rgba/hsla） | ❌ 留痕 | 五期色域深化 |
| palette 属性名 | ⚠️ 改名 paletteColors | Item.palette 内建撞名（坑位 25） |

### NovaOptionGroup / NovaForm / NovaBtnToggle / NovaPopupEdit

| 基线 props | Nova | 备注 |
|---|---|---|
| QOptionGroup 24 | ✅ 收口 21 | type checkbox/radio/toggle Loader 换装；size/validator/name 留痕（name 为 QML 保留字 → 契约 `name` 不适用） |
| QForm 5（autofocus/greedy/no-error-focus/no-reset-focus/onSubmit） | ✅ 1:1 | 递归发现 validate() 子件；validationSuccess/Failed 信号 |
| QBtnToggle 31 | ✅ 收口 22 | glossy/stack/stretch/key/validator 留痕；multiple 多值 Nova 增强（基线无 multiple——实际基线 QBtnToggle 单值，Nova 补齐多选） |
| QPopupEdit 13 | ✅ 收口 11 | cover 覆盖定位/validate 函数留四期；shown/hidden 信号（show/hide 撞内建改名） |
| show/hide 信号名 | ⚠️ 改名 shown/hidden | 坑位 25 留痕 |

> 测试口径：14 条实例化冒烟 + 11 个行为用例（FORM2_ENV_QML 驱动代理），合计 0.10.0 新增 25 项。
> NovaSlider（0.9.0 提前交付）/NovaKnob/NovaFile/NovaUploader——Knob 随滑杆族四期，File/Uploader 五期文件体系。

---

## §0.11 三期 Sprint A · 数据体系九件（0.11.0，对标 Quasar 2.35.5 npm 原包逐项核对）

| Quasar 组件 | Nova 收口 | 关键差异留痕 |
|---|---|---|
| QTable 79 props | ✅ 收口 26（基础面） | columns/rows/filter/filter-method/sortBy/descending/binary-state-sort/selection(single)/selected/rows-per-page/pagination(page)/expanded/expand-slot/grid/flat/bordered/title/hide-header/hide-bottom/dense 留痕；**虚拟滚动/服务端模式/粘性表头/行插槽定制 → v0.12.0**；loading/no-data/sort-method/binary-state-sort 已落 binaryStateSort |
| QTh 5 / QTd 7 / QTr 5 | ✅ 收口 3+2+2 | auto-width 语义由列宽均分承担；props/route/typing 不适用 QML |
| QTree 33 | ✅ 收口 20 | nodes/node-key/expanded/ticked/selected（单键）/tick-strategy(strict·lazy·none)/default-expand-all/filter/filter-method/dense/icon/caption/disabled/lazy；accordion/separator 语义由 NovaList 承担留痕；no-nodes-label/slot 定制 → 四期 |
| QPagination 18 | ✅ 收口 12 | max-pages/ellipses/boundary-links/arrows/boundary-numbers(=boundaryLinks)/color/dark/disable/min-max 钳制；input 型页跳 → 五期 |
| QList 6 | ✅ 收口 5 | separator/dense/padding/accordion；**listRef 注入制**（子 NovaItem 经 listRef 消费 separator/dense） |
| QItem 17 | ✅ 收口 12 | label/caption/icon/clickable/active/disable/manual；expandable+expanded 手风琴语义（Quasar 由 QExpansionItem 承担，Nova 提前入 Item）；slot 命名 left→leading、side→trailing（FINAL 属性红线） |
| QItemSection 5 / QItemLabel 5 | ✅ 1:1 | avatar/thumbnail/side→trailing/top→topAligned；overline/caption/header/lines |
| QMarkupTable 9 | ✅ 收口 7 | title/columns/rows/dense/flat/bordered；slot 定制留五期 |
| QInfiniteScroll 8 | ✅ 收口 6 | offset/load(index, done)/disable/resume；scroll-target 指定容器 → 四期 |
| QVirtualScroll 20 | ✅ 收口 6 | items/delegate/itemsSize/uniform 行高假设（等高行）；slice-size/横向虚拟化/类型分隔 → v0.12.0 留痕 |
| QScrollArea 12 | ✅ 收口 5 | 内容超界滚动 + 主题滚动条；延迟渲染/滚动锁 → 留痕 |

> 测试口径：14 类型实例化冒烟 18 条 + 行为用例 8 个（DATA_ENV_QML 驱动代理），合计 0.11.0 新增 26 项（199 → 225）。
> 坑位沉淀：27 信号参数深拷贝→键值比较；28 函数间接读绑定不可靠→显式失效 + _rev。

---

## §0.12 三期 Sprint B · 媒体体系十类型 + Table 增强（0.12.0，对标 Quasar 2.35.5 npm 原包 dist/api/*.json 逐项核对）

### NovaImg ↔ QImg（29 props）

| 类别 | 收口 | 留痕 |
|---|---|---|
| props | ✅ 12：src / placeholder-src / error-src / ratio / initial-ratio / fit / position / spinner-color→spinnerTint / spinner-size / no-spinner / no-transition / loading-show-delay / alt（→Accessible.name） | width/height ⛔（QML Item.width/height 即尺寸语义）；srcset/sizes ⛔（QML Image 无 srcset，原生按 DPR 取图）；loading/crossorigin/decoding/referrerpolicy/fetchpriority/draggable/img-class/img-style/no-native-menu ⛔（浏览器加载与 class 语境） |
| events | ✅ load→loaded / error→errored | — |
| slots | ✅ default（覆盖层）/ loading / error | loading 与 error 态互斥渲染 |

### NovaResponsive ↔ QResponsive（1 prop）

- ✅ ratio（Number>0 强制 height = width/ratio，useRatio 语义 1:1：非法值视为无比例，高度交宿主）；slot：default 铺满容器。Quasar 无 ratio 时依赖 CSS aspect-ratio 缺省 —— Nova 取"高度交宿主/内容自定"同语义。

### NovaVideo ↔ QVideo（6 props）

- ✅ src / ratio（默认 16/9）/ title（→Accessible.name）；⛔ fetchpriority/referrerpolicy/loading（浏览器 iframe 语境）。
- **播放器惰性创建**：src 为空不实例化 QtMultimedia Video（坑位 31：无音频服务环境 FFmpeg 初始化挂死；且空源仅显示提示）。

### NovaParallax ↔ QParallax（4 props + 1 event + 1 method + 3 slots）

- ✅ src / speed（0~1 钳制，官方默认 1）/ scroll-target（仅接受 Item 引用；缺省向上遍历找最近 Flickable，坑位 14 语义）；scroll-target 的 CSS 选择器形态 ⛔（无 DOM 查询）；height ⛔（Item.height 即容器高）。
- ✅ scroll → scrolled({ progress, contentY })（Quasar 载荷为滚动位置对象，Nova 收敛为穿越进度 0→1 + contentY）；✅ refresh()；slots：default（前景）/ media（mediaSlot）；content 槽与 default 合并（QML 覆盖层语义等价）。
- 实现口径：媒体层高 = 容器高 + speed×高 余量，随 progress 反向位移，全程覆盖容器。

### NovaCarousel ↔ QCarousel（31 props + 5 events + 7 methods + 3 slots）

| 类别 | 收口 | 留痕 |
|---|---|---|
| props | ✅ 15：model-value（受控，页 name/序号寻址）/ animated / infinite / swipeable / vertical / transition-duration / padding / autoplay（数字 ms、true→5000、负数反向）/ arrows / prev-icon / next-icon / navigation / navigation-position / navigation-icon / thumbnails / control-color→controlTint / control-text-color | height ⛔（Item.height）；dark ⛔（NovaTheme 自动）；keep-alive 系 ⛔（Vue 组件缓存）；fullscreen/no-route-fullscreen-exit ⛔（窗口全屏与路由退出留待四期弹层体系）；transition-prev/next ⛔（统一单一滑动过渡）；control-type ⛔（控件形态固定） |
| events | ✅ update:model-value→updateModelValue / before-transition→beforeTransition / transition→transition（过渡完成后上报） | fullscreen / update:fullscreen 随 fullscreen ⛔ |
| methods | ✅ next / previous / goTo（name 或 index；禁用页自动跳过） | toggleFullscreen/setFullscreen/exitFullscreen 随 fullscreen ⛔ |
| slots | ✅ default（页集合，子项即页）+ NovaCarouselControl（position/offset 覆盖控件，自动挂载覆盖层） | navigation-icon 槽 → navigation-icon 属性替代 |

- NovaCarouselSlide ↔ QCarouselSlide：✅ name / disable / img-src（快速图片页）+ default 槽。
- 手势：DragHandler 被动抓取（不吞子内容点击），快速甩动（速度>0.5px/ms）或拖过 1/4 尺寸翻页。
- infinite 回绕（首尾跳变）瞬移不带动画留痕：避免长距离扫过中间页。

### NovaTimeline / NovaTimelineEntry ↔ QTimeline（4 props）/ QTimelineEntry（9 props + 3 slots）

- ✅ QTimeline：color→tint / side（left/right）/ layout（dense/comfortable/loose）；dark ⛔（主题自动）。
- ✅ QTimelineEntry：heading / side（loose 布局生效）/ icon / avatar / color→tint / title / subtitle / body + default 槽（正文）+ title/subtitle 命名槽；tag ⛔（HTML 元素语义）。
- 轴连线由条目自绘（延伸进 spacing 覆盖间隙；loose 左右交替成立）。

### NovaChatMessage ↔ QChatMessage（14 props + 5 slots）

- ✅ sent（镜像）/ label / bg-color→tint / text-color→textColor / name / avatar / text（字符串或数组→多条气泡）/ stamp（仅尾条）/ size（1~12 栅格宽语义）。
- ✅ slots：default（正文）/ avatar / name / stamp / label。
- ⛔ label-html/name-html/text-html/stamp-html：QML 不解析 HTML，富文本走 default 槽。

### NovaTable 增强（v0.12.0 承诺项收口）

- ✅ **虚拟滚动**：virtual-scroll→virtualScroll / virtual-scroll-item-size→virtualScrollItemSize（表体切 ListView 真虚拟化，reuseItems+cacheBuffer；表头独立常驻=天然粘性）；scrollTo() / resetVirtualScroll 语义由 scrollTo 承担；virtual-scroll-slice-size ⛔（reuseItems+cacheBuffer 等价）。
- ✅ **服务端模式**：@request→request 信号（{ pagination:{sortBy,descending,page,rowsPerPage,rowsNumber}, filter }）/ rowsNumber / serverSide（Nova 增强显式开关，Quasar 以 request 绑定推断）/ requestServerInteraction() / setPagination() / firstPage()；排序/过滤触发请求时页码重置为 1（Quasar 语义）；filter 变化自动触发请求（宿主勿在 request 处理器回写 filter，防环）。
- ✅ loading / loading-label→loadingLabel / no-data-label→noDataLabel（loading 覆盖层 + 空态文案）。
- binary-state-sort 已于 0.11.0 落 binaryStateSort；column-sort-order/sort-method/visible-columns/fullscreen/grid 定制 → 留痕。

> 测试口径：十类型实例化冒烟 13 条 + 行为用例 12 个（MEDIA_ENV_QML 驱动代理），合计 0.12.0 新增 25 项（225 → 250）。
> 坑位沉淀：29 inline component 裸名赋 delegate 恒 count 0（须带花括号实例化）；30 创建期定位器错过自动布局（显式 childrenRect 高度兜底）；31 QtMultimedia Video 惰性创建（无音频服务环境初始化挂死）；32 reuseItems × 自定义 delegate 退出段错误（暂缓 reuseItems）；NovaImg 占位/错误图分层叠加规避 source↔status 绑定环。

## §0.13 四期 Sprint A · 导航体系 14 类型（0.13.0，对标 Quasar 2.35.5 npm 原包 dist/api/*.json 逐项核对；基线漂移复核 2.35.6 零 API 变化）

### NovaTabs ↔ QTabs（15 props + 1 event + 1 slot）

| 类别 | 收口 | 留痕 |
|---|---|---|
| props | ✅ 13：model-value（受控，Tab name/序号寻址）/ vertical / outside-arrows / mobile-arrows / align（left/center/right/justify）/ breakpoint（默认 600，低于自动 justify）/ active-color→activeTint（命名红线）/ active-bg-color / indicator-color / left-icon / right-icon / switch-indicator / narrow-indicator / inline-label（横向即同行，恒等口径）/ no-caps（font.capitalization 实现）/ dense | stretch/shrink：flexbox 语境收敛为纵向拉伸/容器收缩为内容宽（implicit 尺寸派生）；dark ⛔（NovaTheme 自动） |
| events | ✅ update:model-value→updateModelValue（Tab 只 emit，宿主写回——坑位 22 契约） | — |
| slots | ✅ default（NovaTab 集合） | active-class/content-class ⛔（HTML class 选择器语义，样式直连属性下发） |

- 指示条：横向底部下划线（switch→上沿）/ 纵向左侧竖条（switch→右侧），几何随激活 Tab 动画跟随；溢出时 Flickable 滚动 + flat 圆钮箭头（outside-arrows 占位两侧）。

### NovaTab ↔ QTab（9 props + 1 slot）

- ✅ name（空则宿主序号寻址）/ label / icon / alert（Boolean→红点、String→徽标）/ alert-icon / no-caps / disable + default 槽（覆盖 label/icon）。
- ⛔ ripple（Nova 内置波纹口径）、tabindex（无障碍批次）、content-class（class 语义）。
- 宿主识别 `isNovaTab` 标记 + tabsRef 注入（激活态/点击上报统一走宿主 `_goToTab`）。

### NovaTabPanels ↔ QTabPanels（12 props + 2 events + 3 methods + 1 slot）

| 类别 | 收口 | 留痕 |
|---|---|---|
| props | ✅ 6：model-value（受控）/ animated / infinite / swipeable（DragHandler 被动抓取，Carousel 口径）/ vertical / transition-duration | keep-alive 系 ⛔（Vue 组件缓存语义，面板常驻条带）；transition-prev/next ⛔（统一单一滑动过渡）；dark ⛔ |
| events | ✅ update:model-value→updateModelValue（外部改 model 不触发）/ before-transition→beforeTransition（{newIndex,oldIndex,direction}）/ transition→transition（过渡完成后上报） | — |
| methods | ✅ next / previous / goTo（name 或 index；禁用面板自动跳过；infinite 回绕瞬移不带动画） | — |
| slots | ✅ default（NovaTabPanel 集合，子项即面板） | — |

### NovaTabPanel ↔ QTabPanel（2 props + 1 slot）

- ✅ name（任意类型寻址）/ disable（禁用遮罩）+ default 槽；几何由宿主统一管理（Slide 口径）。

### NovaBreadcrumbs ↔ QBreadcrumbs（4 props + 2 slots）

- ✅ separator（默认 '/'）/ separator-color / active-color→activeTint（命名红线）/ gutter（none/xs/sm/md/lg/xl→0/4/8/16/24/48）/ align（left/center/right）。
- ✅ **activeColor 语义 1:1 对标 2.35.6 QBreadcrumbs.js 源码**：作用于「中间的、未禁用」条目；最后一个（当前页）不着色。
- ✅ separator 槽 → `separatorDelegate`（Component 模板，作用域槽口径）；default 槽 → 宿主持有 + 手动线性布局（坑位 24/28：显式 x/y，不走定位器）。

### NovaBreadcrumbsEl ↔ QBreadcrumbsEl（11 props + 1 event + 1 slot）

- ✅ label / icon / disable / click→clicked + default 槽（覆盖 label/icon）；宿主注入 crumbsRef（激活色判定 `isActiveColor`）。
- ⛔ to/href/exact/replace/active-class/exact-active-active-class/target（无路由体系，点击统一信号由宿主处理）；tag ⛔（HTML 元素语义）。

### NovaStepper ↔ QStepper（26 props + 2 events + 3 methods + 3 slots）

| 类别 | 收口 | 留痕 |
|---|---|---|
| props | ✅ 14：model-value（受控）/ vertical / header-nav（总开关）/ animated / infinite / flat / bordered / alternative-labels / contracted（头部只画圆点）/ inactive-icon / inactive-color / done-color / active-color / error-color / done-icon / active-icon / error-icon / transition-duration | keep-alive 系 ⛔；swipeable（步骤条语境留痕）；dark ⛔；transition-prev/next ⛔ |
| events | ✅ update:model-value→updateModelValue / before-transition→beforeTransition / transition→transition | — |
| methods | ✅ next / previous / goTo（禁用步骤跳过） | — |
| slots | ✅ default（NovaStep 集合）/ navigation（NovaStepperNavigation 容器挂底部）/ message（Component 模板，Loader 渲染） | header-class ⛔（class 语义） |

- **状态图标解析 1:1 对标 2.35.6 StepHeader.js**：active > error > done 优先级；step 级 icon/color 覆盖 stepper 级；`'none'` 退让 prefix → step.icon/inactiveIcon；颜色解析含命名色映射（primary/secondary/accent/negative/positive/warning/info/dark → NovaTheme 令牌）。
- 连接线：前段/后段按相邻步骤 done 态着色（对标 q-stepper__line 语义）；垂直模式竖向连接线。
- 坑位 24/28 口径落地：状态色/图标绑定侧**直读依赖**（st.* + currentIndex）强制重评，再经 `_dotColor/_stateIcon` 计算；派生步骤集合 `_steps` 平铺属性 + `_rev` 显式失效。

### NovaStep ↔ QStep（15 props + 1 slot）

- ✅ name / title / caption / icon / prefix / done / error / disable / header-nav（逐步骤）+ default 槽（步骤内容）。
- ✅ 状态覆盖：done-icon/done-color/active-icon/active-color/error-icon/error-color（'none' 退让口径同上）；color（Quasar 命名色字符串口径，Item 基类无冲突）。

### NovaStepperNavigation ↔ QStepperNavigation

- ✅ default 槽容器（Row 间距 spacingM；由宿主 navigation 命名槽挂载渲染）。

### NovaExpansionItem ↔ QExpansionItem（34 props + 7 events + 3 methods + 2 slots）

| 类别 | 收口 | 留痕 |
|---|---|---|
| props | ✅ 16：label / caption / label-lines / caption-lines / icon / expand-icon / expanded-icon / hide-expand-icon / expand-icon-toggle / switch-toggle-side / dense-toggle / dense / duration / header-inset-level / content-inset-level / expand-separator / group（手风琴互斥）/ popup / disable / color→tint（命名红线） | expanded 受控 + defaultOpened 初值（宿主绑定后以宿主为准——坑位 22 不自写） |
| events | ✅ update:model-value→updateModelValue / before-show→beforeShow / show→shown / before-hide→beforeHide / hide→hidden / after-show→afterShow / after-hide→afterHide | show/hide 与 QML 内建语义撞名规避（坑位 25 口径） |
| methods | ✅ show / hide / toggle（只 emit 不自写；手风琴互斥经 ExpansionGroups.js 注册表通知组内其他条目各自受控上报） | — |
| slots | ✅ default（展开内容）/ header（自定义头部） | to/href 系 ⛔（无路由）；dark ⛔；header-style/header-class/expand-icon-class ⛔（style/class 语义） |

### NovaToolbar ↔ QToolbar（1 prop + 1 slot）

- ✅ inset + default 槽；min-height 50（$toolbar-min-height 1:1）。dark ⛔。

### NovaToolbarTitle ↔ QToolbarTitle（1 prop + 1 slot）

- ✅ shrink（反转撑满语义）+ default 槽；便捷 text 属性（未用槽时渲染，elide 单行）。

### NovaFab ↔ QFab（26 props + 5 events + 3 methods + 5 slots）

| 类别 | 收口 | 留痕 |
|---|---|---|
| props | ✅ 15：model-value（bool 受控）/ icon / active-icon（open 态切换 + 45° 旋转）/ hide-icon / label / external-label / label-position（left/right/top/bottom）/ hide-label / direction（right/left/up/down）/ vertical-actions-align / stagger（级联节拍 ms）/ hover（悬停展开契约）/ hover-delay / hover-hide-delay（离场宽限）/ square / disable / color→tint（命名红线）/ text-color | type/outline/push/unelevated/glossy/padding ⛔（HTML 按钮形态，Nova 圆钮形态固定）；persistent ⛔（路由导航语境 N/A）；dark ⛔ |
| events | ✅ update:model-value→updateModelValue / before-show→beforeShow / show→shown / before-hide→beforeHide / hide→hidden（坑位 25 撞名口径同上） | — |
| methods | ✅ show / hide / toggle（只 emit 不自写；级联由 open 变化统一驱动） | — |
| slots | ✅ default（NovaFabAction 集合）/ label（便捷 label 属性 + externalLabel 外置渲染）/ icon·active-icon（便捷属性替代）/ tooltip → 四期弹层体系交付后接入 | — |

- **stagger 级联**：逐动作 Timer（delay = idx×stagger）置 revealed（坑位 19 显式 start）；收起全量即隐。
- **hover 契约**（对标 2.35 use-hover）：进入 hoverDelay 展开、离场 hoverHideDelay 宽限收起；命中区 = 主钮 + 动作外溢范围的并集（`hoverArea` 统一更新）。

### NovaFabAction ↔ QFabAction（21 props + 1 event + 1 slot + 1 method）

- ✅ icon / label（外置标签渲染于按钮旁）/ hide-label / color→tint / text-color / square / disable / anchor（沿用宿主方向口径）+ default 槽（覆盖 icon）+ click 信号 + `click()` 方法。
- ⛔ to/replace（无路由）；type/outline/push/unelevated/glossy/padding ⛔（同 Fab）；tabindex ⛔。
- revealed/delay 由宿主 NovaFab 级联下发（组件只做渐显/缩放响应）。

> 测试口径：14 类型实例化冒烟 + 行为用例 7 个（NAV_ENV_QML 驱动代理），合计 0.13.0 新增 21 项（250 → 271）。
> 坑位沉淀：33 QML Item 析构钩子是 `Component.onDestruction`（无 onDestroyed）；34 Text/Item 基元无 `background` 属性（Control 系 API），徽标底色手写包裹 Rectangle；布尔 `join` 产出小写 `true/false`（断言口径）。

## §0.14 四期 Sprint B · 弹层与反馈 17 件（0.14.0，对标 Quasar 2.35.5 npm 原包 dist/api/*.json 逐项核对；基线 2.35.6 零漂移沿用）

### NovaMenu ↔ QMenu（34 props + 6 events + 5 methods + 1 slot）

| 类别 | 收口 | 留痕 |
|---|---|---|
| props | ✅ 15：target（缺省父项，绑定直读不写回）/ context-menu→contextMenu / auto-close→autoClose / persistent / no-esc-dismiss→noEscDismiss / hover 系（hover/hoverDelay/hoverHideDelay）/ fit / cover / anchor / self / offset / square / max-height→maxHeight / max-width→maxWidth | model-value 受控（坑位 22 只 emit）；transition-show/hide/duration ⛔（统一 fade 口径内建）；dark ⛔（NovaTheme 自动）；no-parent-event/touch-position ⛔（DOM 语义）；no-route-dismiss ⛔（无路由）；separate-close-popup ⛔（v-close-popup 指令语境）；no-refocus/no-focus ⛔（无障碍批次） |
| events | ✅ 6：update:model-value→updateModelValue / before-show→beforeShow / show→shown / before-hide→beforeHide / hide→hidden / escape-key→escapeKey | — |
| methods | ✅ 5：show / hide / toggle / updatePosition / focus | — |
| slots | ✅ default（菜单项，NovaItem 口径） | — |

- **portal 语义降级**：就地渲染 + z 提升（Nova 建议声明在页面根层）；外部点击捕获层覆盖宿主范围，
  宿主交互控件事件不劫持（Nova 口径）。
- **auto-close**：动态挂接子项 clicked（坑位 35：TapHandler 被子项 MouseArea 独占饿死）。
- 进 NovaOverlayHost 弹层栈（registerPopup）→ closePopups(depth) 逐层 ESC 关闭口径成立。

### NovaDialogShell ↔ QDialog（组件壳；17 props + 7 events + 5 methods + 1 slot）

- ✅ model-value 受控 / persistent / no-esc-dismiss / no-backdrop-dismiss / seamless / maximized /
  full-width / full-height / position（五向）/ square / transition（内建 scale+fade）
- ✅ **关闭原因上报 dismissed(reason)**：ok / cancel / backdrop / escape / api（programmatic=api 别名，
  基线 2.28 真 parity）；persistent 拒关 → shake 事件 + 动效（对标 QDialog shake）
- ⛔ backdrop-filter（CSS 特性）、allow-focus-outside/no-refocus/no-focus ⛔（无障碍批次）
- **命名红线**：Services 已有 NovaDialog 命令式单例，跨模块 import 歧义 → 组件壳名 NovaDialogShell。

### NovaPopupProxy ↔ QPopupProxy（8 props + 5 methods）

- ✅ breakpoint（窗口宽/高较小者判定，默认 450）→ Dialog 全屏形态 / Menu 定位形态二选一；
  内容槽共享（reparent 迁移到当前形态容器，关闭归还）；target/contextMenu/persistent/cover/fit/position 转发。
- ✅ 事件转发：updateModelValue/beforeShow/shown/beforeHide/hidden/escapeKey。

### NovaTooltip ↔ QTooltip（13 props + 5 events + 4 methods + 1 slot）

- ✅ target（缺省父项）/ delay / hide-delay / anchor（默认 bottom middle）/ self（默认 top middle）/
  offset（默认 [14,14]）/ max-width / text（Nova 增强便捷属性）+ default 槽；updatePosition。
- ⛔ transition-show/hide（统一 fade）；cursor-position ⛔（DOM 指针语义）；persistent ⛔（路由语境）。
- 就地渲染口径（同 Menu，PARITY 降级留痕）。

### NovaBottomSheet ↔ BottomSheet 插件（组件壳）

- ✅ actions 数组（{label, icon, disable}）列表/grid 网格双布局 + default 槽；遮罩 + ESC 关闭；
  actionPicked(index) 信号；**dismissed(reason) 关闭原因上报**（backdrop/escape/api/ok——对标 2.28 语义）；
  modelValue 受控；show/hide/toggle。
- 插件的 options.grid/cardStyle ⛔（CSS 语义）；QML 口径 actions 对象留 disable 通道。

### NovaSpinner ↔ QSpinner 系列（17 组件 → 单类型 8 变体）

- ✅ variant：ring（默认 mat）/ ball / dots / hourglass / gears / grid / radio / comment；
  size / tint（color 命名红线）/ thickness（ring/radio 口径）。
- Canvas 统一相位驱动（Timer → phase → requestPaint，坑位 28 显式失效口径）；
  单类型收敛理由：QSpinner 17 个组件同 API（size/color/thickness），仅形状差异。

### NovaSkeleton ↔ QSkeleton（11 props + 1 slot）

- ✅ type（rect/text/circle/square/badge/tag）/ animation（wave 渐变横扫/bounce 脉冲/fade 呼吸/none）/
  animation-speed / size / width→customWidth / height→customHeight / square（type 口径）/
  bordered | dark ⛔、tag ⛔（HTML 元素）；default 槽 ⛔（内容语义=占位）。

### NovaInnerLoading ↔ QInnerLoading（7 props + 1 slot）

- ✅ showing / size / color→tint（命名红线）/ label + default 槽替换 Spinner；spinners（spinnerVariant
  Nova 增强）；半透明蒙层（dark 增强开关）。

### NovaAjaxBar ↔ QAjaxBar（6 props + 2 events + 3 methods）

- ✅ position（top/bottom/left/right）/ size / color→tint / reverse / start / increment / stop /
  start→started / stop→stopped。
- **多进程计数**：N 次 start 需 N 次 stop（对标 hijack 语义）；渐进模拟：间隔 200→800ms 随进度拉长、
  步长收窄，progressCap 90，stop 冲刺收尾。skip-hijack/hijack-filter ⛔（Ajax 拦截语境 N/A）。

### NovaLoadingBar 服务 ↔ LoadingBar 插件

- ✅ start(opts)/increment/stop 命令式；懒创建 NovaAjaxBar 挂 NovaOverlayHost（zTop 层）；
  无窗口（NovaScreen.source 未设）降级 no-op 不炸。

### NovaBanner ↔ QBanner（4 props + 3 slots）

- ✅ inline-actions / dense / rounded + default/avatar/action 三槽。

### NovaBar ↔ QBar（2 props + 1 slot）

- ✅ dense + default 槽；tint 默认 primary、文字 textOnPrimary 反转（对标 $primary 背景）。

### NovaNoSsr ↔ QNoSsr（2 props + 2 slots）

- ✅ placeholder 文案 / placeholder 槽 + default 槽；语义落位"客户端就绪延迟渲染"（delay，默认下一帧）。
- tag ⛔（HTML 元素）。

### NovaPullToRefresh ↔ QPullToRefresh（7 props + 1 event + 2 methods + 1 slot）

- ✅ **side 四边拉动（top/bottom/left/right，对标 2.30）** / icon / disable / color→tint（命名红线）/
  bg-color→bgColor / threshold（拉动阈值）；refresh 事件；trigger() 方法；refreshing 受控（宿主置 false
  复位——事件驱动语义的受控映射）。
- scroll-target ⛔（就地渲染口径无外部滚动目标）；no-mouse ⛔（QML 统一指针语义）；边缘起点判定简化为
  整面生效（无 DOM touchstart 坐标，PARITY 留痕）。

### NovaResizeObserver ↔ QResizeObserver（2 props + 1 event + 1 method）

- ✅ debounce（默认 100）/ target（缺省声明父项）/ resize(w,h) / trigger()；绑定首帧只记录基线不触发。
- **规划核对**：NovaScrollObserver 已于 Behaviors 0.7.0 交付（L3 行为层）——本期不重复交付，
  规划"若 S3 未覆盖则此期补齐"口径关闭。

> 测试口径：29 类型实例化冒烟 + 行为用例 9 个（POPUP_ENV_QML 驱动代理），合计 0.14.0 新增 38 项（271 → 308）。
> 坑位沉淀：35 TapHandler 被子项 MouseArea 独占饿死——auto-close 类语义须动态挂接子项 clicked 信号；
> 弹层组件必须 Component.onDestruction 注销弹层栈（跨测试泄漏级联）；QtObject 无默认属性不能挂
> Timer/Connections（观察器根改 Item）；var 数组 in-place push 不写回（concat 口径三度复验）。


---

## 0.15.0 审计 —— 五期 Sprint A · 长尾组件（Controls 89→91、Behaviors 10→11 + singleton）

### NovaEditor ↔ QEditor（4 props + 5 events + 15 methods + 2 slots）

- ✅ toolbar 分组配置（数组的数组、组间 separator，对标 QEditor toolbar 定义格式）/ modelValue
  受控 + updateModelValue（update:model-value 口径，NovaInput 同款 guard 防回环）/ placeholder /
  flat / readonly / disable / min-height→minHeight（Nova 增强）；@save→saved（execCmd("save") 触发）、
  key-press→keyPressed；**execCmd 命令族 1:1 命令名**：bold/italic/underline/strike（行内包裹）、
  h1~h6/quote/code/ul/ol（行前缀逐行）、link、remove-format、undo/redo（TextEdit 原生栈）、save；
  selectRange/caretPosition（对标 caret）；toHtml()（对标 getHTML：结构前缀原始行判断、内容单独
  转义、h1~h6/blockquote/li/pre/p + 行内标记 + HTML 实体转义）；buttonCount 派生。
- ⛔ **实现口径留痕**：QEditor 基于 DOM contenteditable + document.execCommand，QML TextEdit 无
  富文本选区格式化 API——Nova 以「轻量标记编辑器 + HTML 导出」实现同语义（工具栏配置/命令名/
  受控契约 1:1，标记语法非 HTML-in-place，PARITY 记录为语义对齐而非字节级对齐）。
- ⚠️ execCmd 内 command-view/restore-default ⛔（无 DOM 命令栈）；字体/颜色命令 ⛔（QML 无选区格式化）。

### NovaSlideItem ↔ QSlideItem（6 props + 4 events + 3 methods + 3 slots）

- ✅ left/right 动作面板 → **leftSlot/rightSlot**（QSlideItem 的 left/right 撞 Item FINAL 成员
  [坑位 12] 改名留痕，Component 槽语义一致）/ dense→revealWidth 紧凑侧板；slideLeft/slideRight/
  reset 命令式 API（对标 ref 方法族）；拖拽跟手（死区防抖 + clamp 侧板宽度）+ 释放越
  openThreshold 吸附（Behavior OutCubic）；slideOpened(side)/slideClosed/leftAction/rightAction
  事件（QSlideItem 回调型槽语义的事件化映射）。
- ⛔ use-plain-anchor ⛔（QML 无 DOM 锚定语义）；开合为内部动画状态（QSlideItem 无 v-model，
  指令型组件契约一致）。

### NovaMorph ↔ v-morph 指令（Behaviors 族，1 directive value + group 修饰符）

- ✅ group 组内元素形变切换：morph() 触发——旧活动元素退出、**ghost 影子从旧几何动画至新几何**
  （跨父级 mapFromItem 映射）、新元素延至动画完成显示；duration/tint/radius 配置；
  morphStarted/morphFinished 事件；isActive() 命令式判定（坑位 24/28：不做函数调用派生绑定）；
  duration=0 快路径直切。
- ✅ **NovaMorphPool singleton 注册表**（group → 当前活动 Item）：register/setCurrent/unregister/
  current——首成员登记（组空时）、morph 强制切换、析构注销。
- ⛔ v-morph 修饰符只接首个匹配元素等 DOM 细节 ⛔；可见性接管为命令式切换（宿主勿绑定
  target.visible，组件头注释声明契约）。
- **坑位沉淀 36**：.pragma library JS 注册表实测 per-importing-file 实例化（同组两实例互盲）→
  改 QML singleton；**坑位沉淀 37**：Component.onCompleted 逆序执行——组内默认活动元素通常是
  声明序最后的成员，语义已入测试。

### NovaIconGenie ↔ @quasar/icongenie（CLI，scripts/gen_icons.py）

- ✅ 单图生成全套：favicon ×4 + apple-touch ×6 + android ×7 + iOS AppIcon 全档（20~1024 pt/scale
  全清单）+ 可选 splash ×6（**37 产物**，icongenie-report.json 清单含源图指纹）；--background /
  --padding / --splash；居中缩放合成、背景色/透明模式；splash 必须不透明背景（拒绝守卫）。
- ⛔ 桌面平台专属产物（electron/macos/win 图标 ICO/ICNS）⛔ 本期不含（打包器 v0.16.0 补）；
  产物清单为 icongenie 默认模式主档位子集（全档位口径在报告 JSON 可扩展）。

### AI-ready 文档包 + Nova MCP server ↔ @quasar/mcp v1.0.0（Quasar 2.33 新品类，scripts/gen_apidocs.py + nova_mcp.py）

- ✅ **AI-ready 文档包**：docs/ai/api/*.json（120 公共类型 props/signals/methods/描述 + 行内注释 +
  行号）/ docs/ai/pages/（10 页核心文档离线拷贝）/ docs/ai/index.json（版本 + 基线 Quasar 2.35.5 +
  模块计数 + 16 位内容指纹）——"docs that match your project"（版本化 API，杜绝幻觉 props）口径 1:1。
- ✅ **MCP server 六工具 1:1**：search_docs（关键词 → API 条目 + 页面行级命中摘要，"built for small
  context windows" 口径——返回摘要非全文）/ list_pages / get_page（宽松按节截取，如 "第 1 章"）/
  list_api（模块过滤）/ get_api（全量 API JSON，无前缀自动宽松匹配）/ check_updates（离线版本 +
  基线 + 指纹报告，"works offline, nothing to install" 口径——仅标准库零网络零依赖）。
- ✅ stdio JSON-RPC 2.0（MCP 换行分隔传输）：initialize（protocolVersion/serverInfo）/ tools/list /
  tools/call（content/isError 规范）/ notification 不回包；unknown tool → isError。
- ⛔ @quasar/mcp 的 quasar/@quasar/app-vite 版本探测 ⛔（Nova 单包无多包构成，check_updates 报
  单版本 + 基线）；`--project` 参数已对齐。

> 测试口径：7 冒烟 + 7 行为（LT_EDITOR/LT_SLIDE/LT_MORPH 环境驱动代理 + IconGenie/MCP
> subprocess 直退码核验），合计 0.15.0 新增 14 项（308 → 322）。

---

## 0.16.0 审计 —— 五期 Sprint B1 · 可访问性（**Quasar 无对应层，Nova 增强**）

基线事实：npm `quasar@2.35.5` **没有 a11y 模块**——`Accessible` 语义靠模板里散写 `aria-*`，
无统一令牌、无键盘路径约束、无对比度门禁。故本节全部为 ✅ Nova 增强（⛔ 无基线可 1:1），
按"契约可验证"口径登记，避免把"没有对标"误读成"没有做"。

| 交付物 | 对标情况 | 契约口径 |
|---|---|---|
| `NovaA11y`（Nova.Design 单例） | ⛔ Quasar 无（Vue 侧无公共 a11y API） | WCAG 2.1 数学（相对亮度/对比度/大文本判定/AA·AAA·UI 三档）+ AA 派生（`aaText` 双向最小位移、`aaFill` 单向压暗保色相）+ `ringVisible()` + `notice()` + 语义词汇表 |
| `NovaFocusRing`（Behaviors） | ⛔ Quasar 无（Quasar 焦点态靠 CSS `:focus` 常显） | focus-visible 语义：仅键盘模态绘制；`target/tint/ringWidth/offset/cornerRadius` 五参数；只画不拦事 |
| `NovaLiveRegion`（Behaviors） | ⛔ Quasar 无（Vue 侧靠第三方 aria-live） | 消费 `NovaA11y.notice()` → `Accessible.announce()`；WCAG 4.1.3 |
| `Nova.Runtime.keyboardMode` | ⛔ 无（浏览器原生 `:focus-visible`） | 应用级事件过滤器维护输入模态；KeyPress→true / 指针→false；QML 经 `NovaA11y.keyboardMode` 读取 |
| 组件 `a11yLabel` 属性（32 个 interactive 类型） | ⚠ Quasar 对应 `aria-label` 属性（Vue 模板字符串） | QML 化为一等属性：空则自动回落 `text`/`label`/`title`/`hint`，非空优先 |
| `Accessible.*` 覆盖 | ⚠ Quasar 声明 WAI-ARIA 全覆盖 | **123 类型 100% 登记**：interactive 32（role+name+键盘入口+按键路径+焦点环）、semantic 28（role+name）、decorative 63（禁止挂载 + 标记留痕） |
| 对比度令牌 | ⛔ Quasar 无派生（`text-primary` 在浅色面 4.21:1，不合 AA） | `a11yBase` / `*Text` ×7 / `fillTint()` / `outlineStrong` / `focusRing`，全部由 `NovaA11y` 运行时派生，`setBrand()` 换肤后仍合规 |
| 门禁 | ⛔ Quasar 无 | `scripts/check_a11y.py`（静态，exit 1 阻断）+ `tests/test_a11y.py` 21 项（运行时 QAccessible 矩阵） |

**已知差距（0.16.1 已补 Tree 游标 / Dialog 焦点陷阱；余项滚动）**：表格逐单元格语义、
**组件内部组合色逐件像素采样**（tinted Chip 等，令牌门禁只管令牌组合）、
真机屏读器（NVDA/VoiceOver）手工回归（B3）。详见 [A11Y.md](A11Y.md) §7。

> 测试口径：0.16.0 新增 21 项（322 → 343）——数学 2 / 令牌 4（明暗 × 文本·非文本）/
> 运行时矩阵 2（19 类型 role·name·disabled·focusable）/ 键盘 8 / 焦点环 1 / 播报 1 /
> 画廊页实例化 1 / 静态门禁自检 1，另有 1 项测试内参数化展开。


---

## 0.16.1 审计 —— 五期 Sprint B2 · 国际化 + RTL + 性能 + HiDPI

基线事实：npm `quasar@2.35.5` Lang 插件——`$q.lang.isoName/rtl/set(props)` + `lang:locale-change`
事件；RTL 语言集合 ar/he/fa/ur/ps/sd/ug/yi/ckb（源码核实）。复数无对应（Vue 生态靠 vue-i18n
`$tc` / Intl.PluralRules），格式化无对应（浏览器 Intl）——QML 语境裁定：全局词典包 + t()/tp()
命令式查询 + JS 精简 CLDR + Qt.locale().toString。

| 交付物 | 对标情况 | 契约口径 |
|---|---|---|
| `NovaI18n`（Nova.Services 单例，第 124 类型） | ✅ `$q.lang`（isoName/rtl/set）+ ⚠ vue-i18n（t/tp 语义，QML 无组件作用域词典改全局包） | locale 切换（属性信号即 `lang:locale-change`）、`t()` 插值三级回落（精确 → 主语言前缀 → en-US → key）、`tp()` CLDR 七语系（zh/ja/en/ru/ar/cs/pl）、`addBundle/addPluralBundle` 热注入（对标 props 合并）、formatNumber/Currency/Date/Relative、isRtl/direction |
| RTL 双轨镜像 | ⚠ Quasar RTL Build 模式（编译期 `$q.lang.rtl` 注入 CSS） | QML 语境 = 运行期双轨：声明式 `LayoutMirroring.enabled: NovaTheme.isRtl`（首选）+ 手工布局组件 effectiveSide 反排（Drawer/Layout/SlideItem/Breadcrumbs/Pagination/StepperNavigation）；逻辑侧 API 语义恒定 |
| 性能门禁 | ⛔ Quasar 无（Vue SFC 构建期收益不可比） | 冷启动 ≤800ms / 全类型实例化 ≤5ms（两遍测量 + KNOWN_HEAVY 白名单）/ 1000 行表格挂载 ≤1700ms；`scripts/check_perf.py` CLI 入口 |
| HiDPI | ⛔ 无对标（浏览器 DPR 原生） | QT_SCALE_FACTOR 1.0/1.5/2.0 矩阵：dpr 联动 + 逻辑几何恒定；Nova.Runtime 上报 devicePixelRatio/scaleFactor |
| a11y M2 补差 | ⚠ WAI-ARIA treeview/dialog 模式 | NovaTree roving cursor（Up/Down 移动、Right 展开/Left 收起、跳父、环绕；RTL 键互换）；NovaDialogShell 焦点陷阱（Tab 循环 + 还焦；应用级事件过滤器承载） |

**已知差距（滚动）**：更多语言词典包（de/ja/ru/ar 由应用侧 addBundle 注入示范）、术语表管理、
24h 内存长跑、真机多屏 HiDPI 抽查、NVDA 真机回归（均 B3）。详见 [I18N.md](I18N.md)。

> 测试口径：0.16.1 新增 51 项（343 → 394）——i18n 41（含 RTL 几何断言）/ a11y 补差 3 /
> perf 3 / hidpi 4。类型 123 → 124（NovaI18n decorative 单例）。
