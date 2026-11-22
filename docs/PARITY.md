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

## 审计纪律（宪法第 3.5 条）

1. 新组件交付 = 宪法迭代 + **本文件新增审计节**（属性/事件/槽/model 逐项列明）
2. ❌ 项必须标注目标里程碑；⛔ 项必须写明 QML 语境理由
3. 封版（1.0.0-flagship）前，✅ 占比门禁：P0 组件 ≥90%，全库 ≥85%
