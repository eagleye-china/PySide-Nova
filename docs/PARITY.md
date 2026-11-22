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

## 审计纪律（宪法第 3.5 条）

1. 新组件交付 = 宪法迭代 + **本文件新增审计节**（属性/事件/槽/model 逐项列明）
2. ❌ 项必须标注目标里程碑；⛔ 项必须写明 QML 语境理由
3. 封版（1.0.0-flagship）前，✅ 占比门禁：P0 组件 ≥90%，全库 ≥85%
