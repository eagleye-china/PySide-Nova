# pyside-nova Quasar 工程化理念对齐与架构演进实用指南

> **文档性质**：本库**现行**实用文档（非史料、非方案稿）· Quasar 四大工程化理念对齐 + 命令式服务 / 设计令牌 / 槽位范式**正确用法** + 架构演进边界的唯一查阅入口
> **适用版本**：**1.2.0** · `api/nova-api-1.2.0.json` · **144 导出类型** · 冻结指纹 **`4f882374ad52262b`**
> **前身**：《pyside-nova 企业级旗舰版 QML 架构封版方案（FINAL）》（CSA 2026-11-26 贴入的对话式**外部建议稿**，自称 `v2.0+` / FINAL；其「九大顶层目录 / 每子目录独立 `qmldir` / `view` 字符串」等物理重构主张经核**未采纳**，原文逐字存档于附录 A）
> **法源链**：母法 [`CONSTITUTION.md`](../CONSTITUTION.md)（卷首 CARF + 不将就）→ 组合宪法 [`COMPOSITION_CONSTITUTION.md`](../COMPOSITION_CONSTITUTION.md) 1.0.0（CC-1~CC-8）→ [封版规范 v2.1.0](SPEC_FREEZE.md) → [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md)（五模块 / 20 组合根九类）→ [`GUIDE_COMPONENT_DOMAINS.md`](GUIDE_COMPONENT_DOMAINS.md)（104 基础类型十域）→ **本指南（架构层 / 工程化层对齐）**
> **与既有对账文档的分工**：[`PARITY.md`](../PARITY.md) 是**逐组件逐属性**对账（Quasar 2.35.5 基线）；[`ECOSYSTEM_PARITY.md`](../ECOSYSTEM_PARITY.md) 是 **0.4.0~0.7.0 历史演进档案**（已明确标注不代表当前状态）；本指南是**架构层 / 工程化理念层**的集中对齐与用法速查，三者不重复。
> **状态**：**现行 · 2026-11-26 · 待 CSA 随 1.2.0 发布**

---

## 0. 先读这一节：原稿评估结论

### 0.1 一句话

原稿把 Quasar 四大工程化理念写成 **v2.0 的待实现目标**，但经磁盘事实核对，其中**三项在 1.2.0 早已落地**（命令式服务 / 设计令牌 / 模块化按需），第四项（预判布局）亦以另一形态落地。它真正有价值的是「**集中对齐的视角**」与「服务 / 令牌 / 槽位的用法线索」，本指南把这些落为**正确用法速查**；而「废除 `Composite` + 九大顶层目录 + 每子目录独立 `qmldir` + `view` 字符串」的物理重构与冻结面、已发布兼容冲突，**未采纳**，存档为 v2.0 独立议题。

> **不圆场**：前身是外部建议稿，不是本库法源；本指南不叫「封版方案」，也不把未采纳主张写成已落地。

### 0.2 四大理念对齐总表

| # | 原稿主张（Quasar → QML） | 本库 1.2.0 事实 | 裁定 |
|---|---|---|---|
| 1 | **QLayout 预判布局** → `Prescient` 模块 + `view: "hHh LpR fFf"` 字符串 + 具名插槽 | 无 `Prescient` 模块、无 `view` 属性；**20 个组合根用 `property alias xxxSlot` 槽位**（全库 **100 处** alias）实现预判布局，模块 URI 恒为 `Nova.Composite.LayoutShell` | 理念**已落地**、形态不同；`view` 字符串属新增公共 API，**未采纳**（§2.2 / §4.3） |
| 2 | **模块化 Tree-shaking** → 每子目录独立 `qmldir` + `import Nova.Controls.Action` | **5 个 `qmldir` 模块**（`Nova.Controls` 91 · `Nova.Behaviors` 13 · `Nova.Services` 16 · `Nova.Design` 4 · `Nova.Composite.LayoutShell` 20）；全库 **0 处相对导入**，一律绝对模块 `import Nova.XXX`；QML 引擎本就按 `import` 按需解析，无 JS 打包 tree-shaking 概念 | 理念**已落地**（模块级按需）；「每子目录独立 qmldir」会摧毁冻结面，**未采纳**（§2.1 / §0.3） |
| 3 | **插件 / 命令式服务** → `$q.dialog()` → `Nova.Services` 全局单例 | **早已落地**：`Nova.Services` **16 个导出类型 / 12 个 `singleton`**，含 `NovaDialog` · `NovaNotify` · `NovaLoading` · `NovaApp` · `NovaTheme` 等；源码注释直写「对标 `$q.dialog(opts)` → 链式句柄」「对标 Notify.create」 | 原稿把它当待实现目标、且 API 名写错（`create()` 实为 `show()`）、用了 QML 不存在的箭头函数 → **校正为真实用法速查**（§3） |
| 4 | **CSS 变量 / 品牌色** → `Nova.Design.NovaTheme` + Token 驱动绑定 | `NovaTheme` 在 **`Nova.Services`**（不是 `Nova.Design`），已有 `primary` / `secondary` / `accent` / `dark`（注释「Quasar `$dark` 品牌色 1:1」）+ 全套语义色 + a11y 派生；`Nova.Design` 是 4 个 singleton（`NovaIconSet` / `NovaMotion` / `NovaUtils` / `NovaA11y`） | 理念**已落地**、路径写错 → **校正引用**（§2.4 / §4.1） |

> **另有一条原稿正确**：验收清单第 6 项「CI 测试绿灯 `scripts/check_all.py` 全量 + `docs/ai/api/` 重新生成」与现行门禁一致（比上一份外部稿引用已归档坑位 49 的 `test_smoke.py` 有进步），**如实采纳**，本轮自检即按此执行（§6）。

### 0.3 物理重构不可落地：与冻结面的五重冲突（与 [`GUIDE_COMPONENT_DOMAINS.md`](GUIDE_COMPONENT_DOMAINS.md) §0.1 同源）

| # | 主张 | 本库事实 | 裁定 |
|---|---|---|---|
| 1 | 「废除 `Composite` 历史包袱」，新建 `Base/` `Entities/` `Orbit/` `Incubator/` `Prescient/` 等 9 大顶层目录 | 顶层实为 **5 个目录**；改模块 URI 会改变 144 类型归属，摧毁冻结面 `68b34a408489b6a8`，并破坏已发布 1.0.0 / 1.0.1 的 `import Nova.Composite.LayoutShell 1.0` 兼容 | 属 **additive major + RFC + 全库回扫 + 新法源 + 兼容层**独立议题，**待 CSA 单独拍板** |
| 2 | 每个业务子目录「**必须**」存在独立 `qmldir`（如 `module Nova.Controls.Form`） | **Qt 实测**：`qmldir` 支持 `Foo 1.0 Sub/Foo.qml` 相对子路径导出（`Status.Ready`）；`test_layout_shells.py` **20/20** 真实实例化证实；1.2.0 已按九类物理子目录归档且公共面零漂移 | 工程前提**已被证伪**；物理分类 ≠ 模块拆分 |
| 3 | 「批量把 `import "../` 相对路径替换为 `import Nova.XXX`」 | 全库 **0 处相对导入**（`import Nova.Services` 122 / `Nova.Design` 57 / `Nova.Controls` 38 / `Nova.Behaviors` 32 / `Nova.Runtime` 4） | 本库天然满足，**无需动作** |
| 4 | 「`Behaviors` 目录禁止任何视觉渲染组件（纯逻辑挂载）」 | **14/14** 个 `Behaviors/*.qml` 均以 `Item` / `Rectangle` 为根对象 —— QML 行为组件必须挂载视觉树，运行时正常写法 | 照搬会**误杀全部行为组件**；与 [`GUIDE_COMPONENT_DOMAINS.md`](GUIDE_COMPONENT_DOMAINS.md) §3 同一裁定，**未采纳** |
| 5 | 20 组合根按业务语义重分「智能实体 / 呈现层 / 孵化层 / 基座层」 | 1.2.0 封版法源：20 组合根**一律无业务语义骨架**，按 CC-1「唯一组合上下文」刻意同处单一模块共享门面与槽位约定 | 与组合宪法冲突；概念分层 ≠ 模块物理层 |

> **一句话**：原稿把「概念理念」误当成「模块 URI」，把「目录分类」误当成「模块拆分」。本库解法是**物理子目录分类 + 单一模块 URI 不变 + 文档层理念对齐**，三者并存。
>
> **立项更新（2026-11-26 10:09）**：CSA 已拍板 v2.0 物理重构立项（见 §5.1）。上表 #1 的「待 CSA 单独拍板」已兑现；Qt 七形态实测另证明「旧 URI 保留薄转发 `qmldir` + 物理目录重构」可兼容（`SPEC_V2_COMPAT.md §1`）。本表作为**立项前评估史料**保留，不回改。

### 0.4 八处事实误差（已在本指南校正）

| # | 原稿 | 磁盘事实 |
|---|---|---|
| 1 | `Nova.Design.NovaTheme` | `NovaTheme` 属 **`Nova.Services`**；`Nova.Design` 4 个是 `NovaIconSet` / `NovaMotion` / `NovaUtils` / `NovaA11y` |
| 2 | `NovaDialog.create({ title, message, onConfirm: () => {} })` | 真实入口 **`NovaDialog.show(opts)`**，回调键 `onOk` / `onCancel` / `onDismiss`（函数值）；QML **无箭头函数** `() => {}`；`show()` 返回 `NovaDialogHandle`（`accepted` / `rejected` / `dismissed` 信号） |
| 3 | `import Nova.Controls.Action 1.0` / `import Nova.Prescient.Carriers 1.0` | 本库无子模块 URI；真实为 `import Nova.Controls 1.0` / `import Nova.Composite.LayoutShell 1.0` |
| 4 | `NovaDesktop { view: "..."; header: ...; drawer: ...; page: ... }` | 真实公开面是 **5 个 `property alias`**（`menuSlot` / `toolbarSlot` / `pageSlot` / `statusSlot` / `overlaySlot`）+ `showMenu` / `showToolbar` / `showStatus` + 3 个高度 + `windowCloseRequested()`；**无 `view` / `header` / `drawer` / `page` 属性** |
| 5 | 顶层「9 大目录」，`Services/` 仅列 4 个文件 | 顶层 **5 个**；`Services` 实为 **16 导出**（12 `singleton` + 4 handle）+ 3 个 `internal` helper；`NovaApp` / `NovaDialog` / `NovaNotify` / `NovaLoading` 均已存在 |
| 6 | `NovaSetupWizard` → `Incubator/`；`NovaChat` → `Base/`；三 AI → `Entities/` | `NovaSetupWizard` 是 **15 项 GA 组合根**、归九类 `Page/`；`NovaChat` 归 `Chat/`；三 AI 归 `Intelligence/`；`NovaOrbit` 归 `Orbit/` |
| 7 | 「Behaviors 不得含 `Item` 视觉体」 | 14/14 含视觉根对象；另有 `NovaTouchCore.qml` 是 `internal` helper、未导出、不计入 144 |
| 8 | 「适用版本 `v2.0+`」 | 本库当前 **1.2.0**（待 CSA 发布）；`v2.0` 是假设的未来版本，物理重构属 additive major，本轮**不启动** |

### 0.5 可为我所用的部分（本指南的落点）

1. **集中对齐视角**（§2）：本库此前 Quasar 对齐信息散在 [`PARITY.md`](../PARITY.md) / [`ECOSYSTEM_PARITY.md`](../ECOSYSTEM_PARITY.md) / [`DESIGN_TOKENS.md`](../DESIGN_TOKENS.md) / 逐组件页，缺一份**架构层 / 工程化理念层**的对照总表 → 本指南补齐。
2. **命令式服务正确用法速查**（§3）：把原稿错误的 `create()` / 箭头函数 / `onConfirm` 校正为本库真实可运行的 `show()` 调用与配置键，这是本轮最实用的增量。
3. **设计令牌与槽位范式的正确引用**（§4）：校正 `NovaTheme` 归属，给出 20 组合根 `property alias` 槽位范式的真实形态与理由。
4. **v2.0 演进议题存档**（§5）：九大顶层目录 / 独立 `qmldir` / `view` 字符串逐项裁定，标注「未采纳 / additive major + RFC / 待 CSA 单独拍板」，不圆场成已落地。

> **零改动承诺**：本指南**不改任何 QML 物理文件、不改 `qmldir`、不改模块 URI、不改冻结面指纹、不改任何生成器**。对齐只存在于文档层。

---

## 1. 三层基线：工程理念 ≠ 物理目录 ≠ 模块 URI

| 层 | 本库的唯一事实 | 谁能改 |
|---|---|---|
| **模块 URI**（编译单元） | 5 个 `qmldir` 模块：Controls 91 · Behaviors 13 · Services 16 · Design 4 · Composite.LayoutShell 20 | 仅 additive major + RFC，须 CSA 拍板 |
| **物理子目录**（文件归档） | 20 个组合根按九类归入 `Navigation/` … `Incubator/`；`qmldir` 相对子路径导出 | 1.2.0 已封版 |
| **工程理念**（本指南） | Quasar 四大理念 ↔ 本库实现映射；概念域十类；服务 / 令牌 / 槽位用法 | 随对齐口径演进，走文档 + 机检 |

**三者允许一对多 / 多对一，不得用目录树强制映射理念。** 另有 `import Nova.Runtime`（4 处）由 `src/pyside_nova/runtime.py` 运行时注册，不是 `qmldir` 静态模块，不计入 5 模块与 144 类型。

---

## 2. Quasar 四大理念 × 本库实现逐项对齐

### 2.1 模块化按需加载 —— 已落地（模块级）

Quasar 的 `import { QBtn } from 'quasar'` 依赖 JS 打包器 tree-shaking；**QML 没有打包器**，`QQmlEngine` 本就按 `import` 语句按需解析类型，不存在「全量加载」问题。本库的对应物是 **5 个独立 `qmldir` 模块 + 绝对模块导入**：

```qml
import Nova.Controls 1.0
import Nova.Behaviors 1.0
import Nova.Services 1.0
import Nova.Design 1.0
import Nova.Composite.LayoutShell 1.0
```

全库 import 分布（`audit_domains.py` 守护）：`Nova.Services` 122 · `Nova.Design` 57 · `Nova.Controls` 38 · `Nova.Behaviors` 32 · `Nova.Runtime` 4；**相对导入 0 处**。1.2.0 的九类物理子目录分类用 `子目录/名字.qml` 相对路径导出，模块 URI 与 20 个类型名零变化（[`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §1.1）。

> **原稿收益判词校准**：「避免全量加载、极大提升桌面端冷启动」在 QML 语境是**伪命题**；真正的收益是**命名空间清晰 + 按需 import 可静态机检**，本库已具备。

### 2.2 槽位预判布局 —— 已落地（声明式 alias，非字符串 DSL）

Quasar `QLayout` 用 `view: "hHh LpR fFf"` 字符串描述 Header/Left/Right/Footer 结构。本库 20 个组合根采用 **`property alias xxxSlot: <宿主>.data`** 的声明式槽位（全库 **100 处**），业务侧注入组件而非字符串：

```qml
import Nova.Composite.LayoutShell 1.0

NovaDesktop {
    menuSlot: NovaSidebar { /* 业务注入 */ }
    toolbarSlot: NovaToolbar { /* 业务注入 */ }
    pageSlot: NovaTabShell { /* 业务主体 */ }
    statusSlot: NovaText { text: "ready" }
    showStatus: true
}
```

**为什么不采用 `view` 字符串**：① 需新增字符串解析器 + 每个组合根新增公共属性，属 additive 变更、改冻结面；② QML 无 DOM，字符串 DSL 只是把 `anchors` / `Layout` 决策推迟到运行时，反而增加几何不确定性与非法入参面（与 20/20 天花板「非法入参稳态几何」验收冲突）；③ 现有槽位范式已由 `test_layout_shells.py` 20/20 实例化与 60/60 组非法入参守护证实。详见 [`SPEC_FREEZE.md`](SPEC_FREEZE.md) 与 [`AUDIT_CEILING.md`](AUDIT_CEILING.md) §9.1。

### 2.3 命令式服务 —— 已落地（12 个 singleton）

`Nova.Services` 的 `qmldir` 以 `singleton <Name> 1.0 <Name>.qml` 导出 12 个全局单例，业务侧**无需在 UI 树中声明组件**即可调用，与 `$q.dialog()` / `$q.notify()` 一一对应。真实用法见 §3。

| Quasar | 本库 | 入口 |
|---|---|---|
| `$q.dialog(opts)` | `NovaDialog` | `show(opts)` → `NovaDialogHandle` |
| `$q.notify(config)` | `NovaNotify` | `show(config)` → `NovaNotifyHandle` |
| `$q.loading.show/hide` | `NovaLoading` | `show(opts)` / `hide(group)` / `hideAll()` |
| `$q.localStorage` | `NovaStorage` | singleton |
| `$q.platform` / `$q.screen` | `NovaPlatform` / `NovaScreen` | singleton |
| `$q.i18n` / `$q.app` | `NovaI18n` / `NovaApp` | singleton |
| 主题 / 全局上下文 | `NovaTheme` / `NovaOverlayHost` / `NovaIntersectionPool` / `NovaLoadingBar` | singleton |

### 2.4 设计令牌 —— 已落地（`Nova.Services.NovaTheme`）

`NovaTheme` 是 **`Nova.Services`** 下的 singleton，`primary` / `secondary` / `accent` / `dark` 四品牌色（源码注释「Quasar `$dark` 品牌色 1:1」）+ `page` / `surface` / `surfaceAlt` / `outline` / `textColor` / `textMuted` 语义色 + `positive` / `negative` / `warning` / `info` 状态色，并由 `NovaA11y.aaText()` 派生 `primaryText` / `focusRing` 等对比度合规色；`isDark` 一键换肤。`Nova.Design` 的 4 个 singleton 负责图标集 / 动效令牌 / 工具 / a11y 基座。完整令牌表见 [`DESIGN_TOKENS.md`](../DESIGN_TOKENS.md)。

---

## 3. 命令式服务正确用法速查（本轮核心增量）

> **全部取自 QML 源码字面量**，可直接运行；原稿的 `create()` / `onConfirm` / `() => {}` 均不适用。

### 3.1 `NovaDialog.show(opts)` → `NovaDialogHandle`

```qml
import Nova.Services 1.0
import Nova.Controls 1.0

NovaBtn {
    text: "删除记录"
    onClicked: {
        NovaDialog.show({
            title: "警告",
            message: "确认删除该记录？此操作不可撤销。",
            ok: { label: "删除", tint: NovaTheme.negative },
            cancel: "取消",
            onOk: function() { Api.deleteRecord() },
            onCancel: function() { /* 用户取消 */ }
        })
    }
}
```

| 配置键 | 说明 |
|---|---|
| `title` / `message` / `contentDelegate` | 标题 / 正文 / 自定义内容组件 |
| `ok` / `cancel` | `false`（隐藏）/ `true`（默认）/ 字符串（标签）/ 对象 `{ label, tint, variant, flat, visible }` 四态 |
| `onOk` / `onCancel` / `onDismiss` | **函数值**（QML 用 `function() {}`），非箭头函数 |
| `position` | `standard` / `top` / `right` / `bottom` / `left` |
| `persistent` / `noEscDismiss` / `noBackdropDismiss` / `seamless` / `maximized` / `fullWidth` / `fullHeight` | 行为开关 |
| `progress` / `progressMessage` / `transitionShow` / `transitionHide` / `focus` / `stackButtons` / `tint` | 进阶配置 |

`setDefaults(opts)` 设全局默认 · `count()` / `activeDialogs()` / `hideAll(reason)` 内省与批量关闭 · 返回句柄带 `accepted()` / `rejected()` / `dismissed(string reason)` 信号，支持多层堆叠与 `NovaClosePopup` 按层关闭。

### 3.2 `NovaNotify.show(config)` → `NovaNotifyHandle`

```qml
NovaNotify.show({
    type: "negative",
    message: "保存失败",
    caption: "请检查网络连接后重试",
    position: "top",
    timeout: 3000,
    actions: [ { label: "重试", handler: function() { Api.retry() } } ]
})
```

内置类型预设 `positive` / `negative` / `warning` / `info` / `ongoing`（自动带 `tint` / `icon`）；`registerType(name, opts)` 可注册业务类型。`dismiss(item, reason, animate)` / `update(item, props)` / `dismissAll(position)` / `totalCount()` / `relayoutAll()` 为管理与内省面。

### 3.3 `NovaLoading.show(opts)`

```qml
var h = NovaLoading.show({ message: "正在加载…", group: "fetch" })
// … 业务结束 …
NovaLoading.hide("fetch")     // 或 h 句柄释放 / NovaLoading.hideAll()
```

同 `group` 并发自动计数复用同一视觉层；另有 `increment` / `decrement` / `isActive` / `activeGroups` / `activeCount`。

---

## 4. 设计令牌与预判布局的正确引用

### 4.1 令牌引用

```qml
import Nova.Services 1.0
import Nova.Design 1.0

NovaBtn { tint: NovaTheme.primary; text: "提交" }   // Nova.Services.NovaTheme
NovaIcon { name: "mdi:check"; color: NovaTheme.positive }
// NovaMotion / NovaA11y / NovaIconSet / NovaUtils 属 Nova.Design
```

> **红线**：`NovaTheme` **不在** `Nova.Design`。原稿映射表把两者写反，照抄会产生 `import` 正确但类型解析失败的运行时错误。

### 4.2 20 组合根槽位范式

20 个组合根合计 **100 处 `property alias` 槽位**（如 `NovaDesktop` 5 槽、`NovaIncubator` 7 槽），全部遵循「**无业务语义骨架**」：壳只提供槽位、几何钳制、动效、RTL、Esc、a11y decorative 与受控信号，业务语义由注入侧承担（CC-1~CC-8）。逐组件槽位清单见 [`components/index.md`](../components/index.md) 与 [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §4。

---

## 5. v2.0 演进：已立项（CSA 2026-11-26 10:09 拍板）· 见 SPEC_V2_COMPAT.md

原稿「封版验收清单」6 项逐项裁定如下：

| 原稿验收项 | 本库 1.2.0 事实 | 裁定 |
|---|---|---|
| 物理清理：`Composite` 已彻底删除，QML 归入 9 大顶层目录 | 未删。20 组合根在 `Composite/LayoutShell/` 九类子目录，冻结面 `68b34a408489b6a8` | **未采纳**（摧毁冻结面 + 破坏已发布兼容） |
| 模块化验证：所有子目录含完整 `qmldir` 且无报错 | 5 个 `qmldir` 模块；20 组合根用相对子路径导出，`test_layout_shells.py` **20/20** 真实实例化 | **已以另一形态达成**；「每子目录独立 qmldir」被 Qt 实测证伪 |
| QML Import 修正：`import "../` → `import Nova.XXX` | 全库 **0 处**相对导入（`audit_domains.py` 守护） | **本库天然满足**，无需动作 |
| Quasar 对齐：`NovaDesktop` 支持 `view` 参数、`Services` 命令式单例 | 命令式单例 **12 个早已落地**；`view` 字符串未实现 | **部分达成**；`view` 属新增公共 API，未采纳（§2.2） |
| 行为解耦：`Behaviors` 无视觉渲染组件 | **14/14** 含 `Item` / `Rectangle` 视觉根对象（QML 挂载视觉树的正常写法） | **未采纳**（会误杀全部行为组件） |
| CI 测试绿灯 `check_all.py` 全量 + `docs/ai/api/` 重生成 | 现行门禁 `check_all.py --tier static` 3/3 + 专项 53/53 + 天花板 20/20 + 基础 15/15 + 域分类 PASS；`docs/ai/api/` 由 `gen_apidocs.py` 生成 | **已采纳**（本轮自检即按此执行） |

**若 CSA 未来决定推进 v2.0 物理重构**，前置条件（与 [`GUIDE_COMPONENT_DOMAINS.md`](GUIDE_COMPONENT_DOMAINS.md) §6.4、[`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §6 一致，两处不重复立项）：

1. **additive major + RFC**：新法源、全库回扫、20 组合根与 104 基础类型的模块归属重登记；
2. **兼容层**：保留旧 `import Nova.Composite.LayoutShell 1.0` 的别名 / 转发模块，保证已发布 1.0.0 / 1.0.1 / 1.2.0 用户不破；
3. **冻结面重签 + 零漂移证明**：`gen_api_freeze.py` 重签后须逐成员比对，禁止中间态指纹；
4. **全量验收**：静态 3/3 · 专项 · 20/20 · 15/15 · 域分类 · mkdocs · 断链 · 生成器幂等。

### 5.1 立项更新（2026-11-26 10:09 · CSA 拍板）

CSA 指令「**先做 v2.0 物理重构，立项和兼容层一起**」即本节四条前置条件的那次单独拍板。据此：

- **新法源**：[`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md)《v2.0 物理重构立项书 · 双轨兼容规范》已落盘（RFC + 兼容层契约 + M1~M4 分批路线图 + 宪法第 9/13 章合规论证）。
- **Qt 实测校准旧裁定**：`scripts/spike_v2_compat.py` 七形态实测证明 `qmldir` 的 `../` / `../../` 跨目录转发可行、拿到**同一物理实现**；因此 §0.3 冲突 #1「改 URI 必破坏已发布兼容」应精确化为「**只要旧 5 个 URI 保留为薄转发 `qmldir`，物理目录可彻底重构而兼容零破坏**」。原裁定在「当时无兼容层实测」的前提下成立，历史评估表**保留不回改**（史料不圆场）。
- **M1 就绪态（10:44 校准 · 零物理视图）**：CSA 10:44 指令撤回 10:22 落地的 `Nova/Controls/Foundation/qmldir` pilot —— 它是照 Quasar「按域拆子目录」思路的物理试探，与本库 `GUIDE_COMPONENT_DOMAINS.md §1`「概念域 ≠ 物理层 ≠ 模块 URI」铁律及 **Prescript 原创范式**别扭。当前产品树 qmldir 精确 **5 个**、**0 个物理兼容视图**；`scripts/audit_v2_compat.py`（**C1~C5 PASS**）· `scripts/spike_v2_compat.py`（**7/7**，临时目录）· `tests/test_v2_compat.py`（**15 passed**）· `gen_apidocs.py` 回到 1.2.0 干净生成器。**冻结面 `68b34a408489b6a8`、AI 包 `0b02273de9aee652` 全不变**；项目投影因 `SESSION_HANDOFF.md` 校准 v2.0 状态行重签（真实状态变更、非漂移，见当日日志 10:44 段）。详见 `SPEC_V2_COMPAT.md §0.4 / §2.2`。
- **原稿主张仍未采纳**：九大顶层目录 / 每子目录独立 `qmldir` / `view` 字符串 / 废除 `Composite` 等，须按 §5 前置条件与 `SPEC_V2_COMPAT.md §9` 由 CSA 再单独拍板（涉及宪法第 13 章「移模块」+ CC-1 豁免），**不在 M1 范围内**。
- **不批量扫荡**：144 类型全量物理迁移按 `SPEC_V2_COMPAT.md §5` 的 M2~M3 逐批重签 / 验收 / 销号。

> 本指南 §0.1 / §0.3 / §0.4 的「未采纳 / 待 CSA 单独拍板」是**立项前评估史料**；现状以本节与 `SPEC_V2_COMPAT.md` 为准。

---

## 6. 怎样查 / 怎样维护（实用）

**按意图查**：想找「某个 Quasar 组件对应什么」→ [`PARITY.md`](../PARITY.md)（逐组件对账）；想找「工程化理念怎么在本库落地」→ 本指南 §2 / §3；想找「组件属于哪一类」→ [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md)（组合根九类）/ [`GUIDE_COMPONENT_DOMAINS.md`](GUIDE_COMPONENT_DOMAINS.md)（基础类型十域）；想查完整签名 → [`COMPONENT_LIST.md`](../COMPONENT_LIST.md) 与 [`API_FREEZE.md`](../API_FREEZE.md)（生成物，禁手改）。

**维护纪律**：

1. 本指南所有 API 名 / 属性 / 路径**以 QML 源码字面量与 `api/nova-api-1.2.0.json` 为准**；新增服务或令牌时同步 §2.3 / §2.4 / §3，不得凭 Quasar 文档想当然。
2. 概念理念**永不**触发 `qmldir` 改写；若真要拆独立模块 URI，走 §5 四条前置条件，由 CSA 单独拍板。
3. 冻结面升级（`nova-api-1.2.0.json` → 后续版本）时同步本指南头部口径与 §0.2 数量。
4. [`ECOSYSTEM_PARITY.md`](../ECOSYSTEM_PARITY.md) 的七层成熟度评分是 **0.7.0 历史快照**（如 L4 插件 44%），**不得**作为当前状态引用；当前服务层为 16 导出 / 12 singleton。

---

## 7. 封版声明（CARF）

- **C 构想**：CSA 交办「先优化、借鉴为我所用，准确命名、保存为 md，放在合适位置，并自检」；本轮边界明确为**文档落地**，后续任务另议。
- **A 实现**：更名重写为 `docs/prescript/GUIDE_QUASAR_ALIGNMENT.md`（`GUIDE_` 前缀分区第三份现行指南）；四大理念集中对齐 + 命令式服务 / 令牌 / 槽位正确用法速查 + v2.0 议题存档；原文逐字存档附录 A。
- **R 打磨**：八处事实误差逐条校正、五重冲突逐条给证、原稿正确的一条第 6 项如实采纳、QML tree-shaking 伪命题与 `view` 字符串取舍显式论证。
- **F 封版**：**零 QML 物理改动 · 零 `qmldir` 改动 · 零模块 URI 改动 · 零生成器改动 · 冻结指纹 `68b34a408489b6a8` 不变**；nav / 首页 / CHANGELOG / 结构快照 / 账本闭环，自检见 §0.2 末与当日日志。

> **发布边界**：本轮全部改动留工作树未提交，`commit / push / tag / PyPI / 站点上线` **全归 CSA**。

---

## 附录 A · 原《企业级旗舰版 QML 架构封版方案（FINAL）》逐字存档（**未采纳**）

> 以下为 CSA 2026-11-26 贴入的对话式外部建议稿**原文逐字存档**（含其表格、目录树、代码示例与验收清单），**标注未采纳、不圆场成已落地**。原文中的 `create()` / `onConfirm: () => {}` / `Nova.Design.NovaTheme` / `view` 字符串 / 九大顶层目录等均为原稿笔误或未采纳主张，评估见 §0.2~§0.4，**不得作为本库用法引用**。原稿自称 `v2.0+` / FINAL，本库当前版本为 1.2.0。

````markdown
这份架构方案已经具备了"世界级前端框架"的骨架。现在，我们将基于 Vue Quasar 的核心成功要素（**模块化按需加载、槽位预判布局、命令式服务、严格的设计令牌**），结合 `pyside-nova` 的 **Prescript 范式**与 **Nova 智能生态**，正式输出这份《**pyside-nova 企业级旗舰版 QML 架构封版方案（FINAL）**》。

此方案将作为工程重构、代码审查、以及 `NovaIncubator` 孵化器的最高物理架构准绳。

---

# pyside-nova 企业级旗舰版 QML 架构封版方案（FINAL）

**封版状态**：FINAL / Enterprise Flagship Ceiling v1.0
**核心思想**：**"QML 界的 Quasar"**。以 Quasar 的工程化体验为底座，向上构建 Prescript 预构范式与 AI 智能实体生态。
**适用版本**：`pyside-nova v2.0+`

---

## 一、 核心对齐：Quasar 理念的 QML 级复现

我们将 Quasar 的四大核心优势，逐一映射到 PySide-Nova 的架构中：

| Quasar 核心理念 | Vue/JS 实现方式 | PySide-Nova (QML) 实现方式 | 架构收益 |
| :--- | :--- | :--- | :--- |
| **1. QLayout (预判布局)** | `<q-layout view="hHh LpR fFf">` + `<slot>` | `Prescient` 模块 + `Prescript` 范式约束 | 脱离从零写 `Row/Column` 的泥沼，一套骨架自适应多端。 |
| **2. 模块化 (Tree-shaking)** | `import { QBtn } from 'quasar'` | 独立 `qmldir` 与按需 `import Nova.Controls.Action` | 避免全量加载，极大提升桌面端冷启动速度。 |
| **3. 插件/服务模式** | `$q.dialog()`, `$q.notify()` | `Nova.Services` 全局单例调用，无需在 UI 树中声明组件 | 简化全局弹窗/提示的代码逻辑，解耦 UI 树。 |
| **4. CSS 变量 (品牌色)** | `$primary`, `$dark` | `Nova.Design.NovaTheme` 与 Token 驱动的 QML 属性绑定 | 极速换肤，保证企业级 UI 的 100% 一致性。 |

---

## 二、 物理目录架构终极定稿（The Ultimate Tree）

废除 `Composite` 历史包袱，强制实行**"层级隔离 + 业务分域"**。任何新建 QML 文件必须且只能存在于以下 9 大顶层目录之一。

```text
src/pyside_nova/qml/Nova/
│
├── Base/                  # [交互基座] (NovaChat 及其基础总线)
│
├── Behaviors/             # [行为注入] 不可见逻辑，对标 Quasar Touch/Morph 插件
│   ├── Effects/           # (Ripple, Morph, FocusRing, LiveRegion)
│   ├── Gestures/          # (TouchHold, TouchPan, TouchSwipe, TouchRepeat)
│   └── Observers/         # (Intersection, ScrollFire, ResizeObserver)
│
├── Controls/              # [原子控件] 可见的 UI 元素，对标 Quasar Components
│   ├── Action/            # 操作 (NovaBtn, NovaFab, NovaPullToRefresh)
│   ├── Data/              # 数据 (NovaTable, NovaList, NovaTree, NovaTimeline)
│   ├── Form/              # 表单 (NovaInput, NovaSelect, NovaForm, NovaField)
│   ├── Foundation/        # 基础 (NovaIcon, NovaText, NovaImg, NovaAvatar)
│   ├── Intelligent/       # 智能专属 (NovaChatMessage, NovaTooltip, NovaBanner)
│   ├── Layout/            # 容器 (NovaCard, NovaRow, NovaCol, NovaScrollArea)
│   └── Navigation/        # 导航 (NovaTabs, NovaBreadcrumbs, NovaPagination)
│
├── Design/                # [设计系统] (NovaTheme, NovaA11y, NovaIconSet)
│
├── Entities/              # [智能实体] (NovaAgent, NovaDE, NovaCopilot)
│
├── Orbit/                 # [呈现天花板] (NovaOrbit 轨道系统)
│
├── Incubator/             # [孵化层] (NovaIncubator, NovaSetupWizard)
│
├── Prescient/             # [预判布局壳] 对标 Quasar Layout，纯粹骨架
│   ├── Carriers/          # (NovaDesktop, NovaMobile, NovaFlexLayout)
│   ├── Navigation/        # (NovaSidebar, NovaTopNavigation, NovaTabShell)
│   └── Structures/        # (NovaThreeColumn, NovaDualSide, NovaModal)
│
└── Services/              # [命令式服务] 对标 Quasar Plugins
    ├── NovaApp.qml        # 全局上下文
    ├── NovaDialog.qml     # 命令式弹窗 (替代直接使用 NovaModal)
    ├── NovaNotify.qml     # 命令式通知
    └── NovaLoading.qml    # 全局加载遮罩
```

---

## 三、 核心模块封版规范（Iron Rules）

### 1. `Prescient` 层：预判槽位的铁律
**借鉴 Quasar `QLayout` 的 `view` 属性与具名插槽机制。**

`NovaDesktop` 作为预判布局壳，其内部严禁写死业务 UI，必须通过 `Prescript` 范式暴露槽位：
```qml
// 业务层调用示例：遵循 Prescript 范式
import Nova.Prescient.Carriers 1.0
import Nova.Prescient.Navigation 1.0

NovaDesktop {
    view: "hHh Lpr fFf" // 像 Quasar 一样，用字符串定义自适应结构 (Header, Left, Right, Footer)

    header: NovaTopNavigation { /* 业务注入 */ }
    drawer: NovaSidebar { /* 业务注入 */ }
    page: NovaPage { /* 业务主体内容注入，通常是一个 Router 或 Tab 壳 */ }
}
```

### 2. `Controls` 层：七域划分与 `qmldir` 强制绑定
**借鉴 Quasar 按需引入。**

严禁大平铺！每个业务子目录（如 `Controls/Form`）下**必须**存在一个 `qmldir` 文件。QML 引擎通过 `qmldir` 进行快速解析，业务层通过 `import Nova.Controls.Form 1.0` 按需引入。
```text
# src/pyside_nova/qml/Nova/Controls/Form/qmldir 示例
module Nova.Controls.Form
NovaForm 1.0 NovaForm.qml
NovaInput 1.0 NovaInput.qml
NovaSelect 1.0 NovaSelect.qml
```

### 3. `Services` 层：命令式调用的实现
**借鉴 Quasar 的 Plugin 机制。**

企业级应用中，业务逻辑往往需要随时唤起弹窗，而不是在复杂的 QML 树中硬编码 `Modal`。
```qml
import Nova.Services 1.0

Button {
    text: "删除"
    onClicked: {
        // 直接通过全局单例调用 Dialog，而不是实例化一个 NovaDialogShell 组件
        NovaDialog.create({
            title: "警告",
            message: "确认删除该记录？",
            onConfirm: () => { Api.delete() }
        })
    }
}
```

### 4. `Behaviors` 层：可见与不可见的绝对边界
**严格区分行为与控件。**

- **可见的滚动**（带滚动条、可视区域）属于 `Controls/Layout/NovaScrollArea`。
- **不可见的监听**（页面划到底部触发的逻辑）属于 `Behaviors/Observers/NovaScrollObserver`。
禁止在 `Behaviors` 目录中出现任何继承自 `Item` 且有视觉表现的代码。

---

## 四、 完美融合：Quasar 体验 + Prescript 范式 + Nova 智能

按照此架构落地后，`pyside-nova` 将呈现出无与伦比的开发体验：

1. **传统业务开发（类 Quasar 体验）**：使用 `Prescient` 搭建骨架，注入 `Controls` 控件，调用 `Services` 弹窗。
2. **预构范式开发（Prescript 规范）**：所有业务代码强制附带七标签注释，声明壳契约与所属组件。
3. **AI 智能开发（Agent/Orbit）**：
   - 将原本单点的交互（如一个查询按钮），升级为具备意图理解的 `NovaAgent` 实体，放置在 `NovaChat` 基座中。
   - 通过 `NovaOrbit` 轨道系统，将三栏布局（Sidebar + Chat + Canvas）完美整合为"意图操作台"。
   - 最终通过 `NovaIncubator` 封版交付。

---

## 五、 封版验收清单（Sign-off）

- [ ] **物理清理**：`Composite` 目录已被彻底删除，所有 QML 文件归入 9 大顶层目录。
- [ ] **模块化验证**：所有子目录（如 Controls 的七个域）都包含完整的 `qmldir`，且无报错。
- [ ] **QML Import 修正**：全局搜索 `import "../` 相对路径引用已全部替换为 `import Nova.XXX` 的模块化引用。
- [ ] **Quasar 对齐**：`NovaDesktop` 支持类似 `QLayout` 的 `view` 参数，`Services` 支持命令式单例调用。
- [ ] **行为解耦**：`Behaviors` 目录下无任何视觉渲染组件（纯逻辑挂载）。
- [ ] **CI 测试绿灯**：`scripts/check_all.py` 全量运行通过，`docs/ai/api/` 重新生成完毕。

> **一"判"定骨架，一"构"定范式，一"孵"定应用。**
> **以 Quasar 体验为基，以 Prescript 范式为纲，铸就 QML 界的旗舰天花板！**
````
