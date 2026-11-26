# 10 项 AI / 根壳组合根 · 专属主题设计指南

> **文档性质**：本库**现行**实用文档（设计层）· 10 个组合根专属主题的唯一查阅入口 · 色值 / 派生机制 / 架构铁律
> **适用版本**：**1.2.0** · `api/nova-api-1.2.0.json` · **144 导出类型** · 冻结指纹 **`4f882374ad52262b`**
> **法源链**：母法 [`CONSTITUTION.md`](../CONSTITUTION.md)（卷首 CARF + 不将就 第 4 条）→ 组合宪法 [`COMPOSITION_CONSTITUTION.md`](../COMPOSITION_CONSTITUTION.md) 1.0.0（CC-1~CC-8）→ [封版规范 v2.1.0](SPEC_FREEZE.md) → [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md)（20 组合根九类）→ **本指南（专属主题设计层）**
> **状态**：**现行 · 2026-11-26 · CSA 构想「为 10 个组件设计专属、专业、艺术级主题，每次显示只用组件的专属主题」**

---

## 0. 一句话结论

10 个 AI / 根壳组合根**各有专属主题色**，同一色温家族、色相有序分布（168° 湖绿 → 283° 紫晶）；主题色是组件**内部私有 `_` 令牌**，从 `NovaTheme.primary` 的色相派生并独立定制饱和度 / 明度系数。**公共 API / 冻结面 / 模块 URI / qmldir 零改动**，同一时刻只显示一个组件时天然不撞色。

> **CSA 的「3 个主题」问句 → 13:39 二态方案拍板**：伙伴先问「这样这 10 个组件就用 3 个主题了吧？」——当时澄清本库**没有**全局「3 套主题」开关，现行是 `NovaTheme.isDark` 明暗双模式 + 每个组合根各自的**专属身份色**（明暗 × 专属色的二维体系，非 3 个离散主题）。13:34 伙伴构想「默认专属，在亮/暗/专属间切换」，13:38 自行收敛为「**专属跟暗色差不多，只在专属和亮色间切换，默认专属**」，13:39 拍板**方案 A**。现行落地（见 §1.6）：
>
> | 态 | 明度 | 色相 | 落地层级 |
> |---|---|---|---|
> | **专属**（默认） | 深底（`NovaTheme.isDark=true`） | 组件专属色相（`_signatureOn=true` + 固定偏移） | demo 私有开关 + 组件私有令牌 |
> | **亮色** | 浅底（`isDark=false`） | 全局品牌蓝 `#5B6EF5`（`_signatureOn=false`，偏移归零） | 同上 |
>
> **不动 `NovaTheme` 公共 API、不重签冻结面**——`_signatureOn` 是 `_` 私有令牌，生成器明确过滤。若未来要升为**全局公共三态切换器**，仍属 additive 公共 API，须 CSA 另行拍板 + minor 重签。

---

## 1. 设计原则（艺术级四要件）

| 要件 | 落地 |
|---|---|
| **专属身份色** | 每组件一个中文主题名 + 目标色相 + 独立 sat/val 系数；10 色相覆盖冷色区间且互不重复 |
| **同一色温家族** | 全部由 `NovaTheme.primary.hsvHue` 加固定偏移派生，色相有序、饱和/明度受控，不做红/黄/绿撞色 |
| **换肤联动** | `NovaTheme.setBrand(newColor)` 改变主色相时，10 套专属主题**同步平移**，永远保持家族感；饱和/明度系数独立，不被换肤覆盖 |
| **明暗自适应** | 暗色模式 val 系数 ×1.25 提亮（上限 1.0），保证深底上的装饰几何清晰可辨 |


---

## 1.5 Aurora Core · 极光核辉光（2026-11-26 CSA 四问授权落地）

> **缘起**：伙伴给一张「深蓝底 + 青蓝星芒 + 发光核心 + 轨道环」的灵感图，问「这个颜色叫什么 / 能否作第 9 色 / 能否用于 10 主题」。取色结论：主色 `#22A6EF` hue 201° = **Azure / Cerulean 蔚蓝**（中文「天青」），正是「青出于蓝」的青。
> **CSA 决策**：**Q2 撤销——不加第 9 公共色**（避免 additive minor 重签）；**Q3 授权完现——目标「世界级、惊艳」，实现由小诺定**。本轮落地 Aurora Core 辉光层。

### 设计：同色相亮核 + 中性白芯

每个组件在令牌块注入一个 `_glow`（`readonly` 私有），**从本组件 `_themeHue` 派生**——不是固定青蓝：

```qml
readonly property color _glow: Qt.hsva(root._themeHue,
    Math.min(1, NovaTheme.primary.hsvSaturation * 0.78),
    Math.min(1, NovaTheme.primary.hsvValue * (NovaTheme.isDark ? 1.5 : 1.28)), 1)
```

- **为什么不用固定 201° 青**：固定青会在每个组件内引入第二色相，违反 **CC-3 组件内单色相**；且 `setBrand()` 换肤时亮核不跟随、家族感断裂。改为「各组件自身色相的提亮版」后，单色相 ✓ 换肤联动 ✓ 撞色 0 ✓。
- **中性白芯**：焦点最内层用 `NovaTheme.surface`（中性色，非色相），形成「亮核环 + 白芯」同心层次——对应灵感图「白中心 + 发光环」的结构，观感是「每轨身份焦点会呼吸」。

### 10 组件的落点（均在天然身份焦点，几何外层一字未动）

| 组件 | 焦点位置 | Aurora Core 处理 |
|---|---|---|
| NovaChat | 列首品牌徽记 | 内环 → `_glow` 亮核环 + 白芯 |
| NovaCopilot | 撤销弧环最内点 | 同心方块最内层 → 亮核 + 白芯 |
| NovaDE | 岗位菱形徽记中心 | 镂空 4×4 → 亮核 + 白芯 |
| NovaIncubator | 七区环中心孵化点 | 中心点 → 亮核 + 白芯 |
| NovaMobile | 灵动岛摄像头点 | 6px 点 → 亮核 + 白芯 |
| NovaSetupWizard | 步骤时间轴当前步内芯 | `_active` 内芯 → 亮核 + 白芯（语义与视觉契合，最出彩） |
| NovaAgent | DAG 首节点 | 首节点 → `_glow` 提亮 |
| NovaDesktop | 窗口控制首点 | 首点 → `_glow` 提亮 |
| NovaFlexLayout | 面板首档顶条 | 首档 tone → `_glow` |
| NovaOrbit | 感知信号首点 | 首点 → `_glow` 提亮 |

### 技术验证记录（为何弃用 MultiEffect / Gradient.Radial）

| 方案 | 结论 |
|---|---|
| `MultiEffect` blur 辉光 | 实测离屏渲染下**参数改动零像素差异**、效果几乎不可见，却引入 import + 离屏成本 → **弃用** |
| `Gradient.Radial` / `RadialGradient` | Qt 6.12 报 `missing-property` / 类型不存在 → **弃用** |
| **纯几何亮核 + 白芯**（本方案） | 100% 可见、零 import、零新增 warning、明暗可控 → **采用** |

### 铁律不变式

- **`_glow` 是私有 `_` 令牌**：不进冻结面，144 类型 / 指纹 `4f882374ad52262b` 零漂移；公共 property / signal / alias / function 逐字未变。
- **CC-3 单色相**：glow 派生自本组件色相，非 `NovaTheme.secondary|accent`，撞色计数 0。
- **decorative 不挂 Accessible**：辉光是抽象几何，屏读器零噪声。
- **几何语义零改**：只替换焦点「颜色」与同心内环尺寸，anchors / 外层几何 / opacity / 槽位 / 动效一字未动。
- **不改 qmldir / 模块 URI / import**：无新依赖。

> **「青出于蓝」叙事闭环**：Quasar / Nova primary 是「蓝」（hue 233°），灵感图主色是「青」（hue 201°）——「青，取之于蓝，而青于蓝」。本轮不靠固定青色污染组件，而让每个专属色相自己「提亮出核」，正是同一哲理的工程表达，与 `QUASAR_ACKNOWLEDGEMENT.md §3` 品牌立意母题呼应。

---

## 2. 十套主题总表

| 组件 | 主题名 | 目标色相 | 偏移 | sat 系数 | val 系数 | Light `_ink` | Dark `_ink` | 身份语义 |
|---|---|---:|---:|---:|---:|---|---|---|
| `NovaAgent` | 深空靛蓝 | 233° | +0.0000 | ×1.00 | ×1.00 | `#5b6ef5` | `#5f72ff` | 智能体编排 · 本库基准主色，冷静理性 |
| `NovaChat` | 蔚蓝 | 216° | −0.0460 | ×1.18 | ×1.00 | `#3f88f5` | `#428dff` | AI 对话 · 清澈沟通，六轨分治 |
| `NovaCopilot` | 鸢尾紫 | 266° | +0.0940 | ×1.00 | ×1.00 | `#9f5bf5` | `#a55fff` | 增强协作 · 紫色代表增强与共创 |
| `NovaDE` | 钢蓝 | 205° | −0.0760 | ×0.95 | ×0.82 | `#5196c9` | `#65bcfb` | 数字员工 · 钢蓝理性、岗位秩序 |
| `NovaDesktop` | 石板蓝 | 223° | −0.0260 | ×0.66 | ×0.66 | `#5f71a2` | `#768eca` | 桌面根壳 · 沉稳系统基底 |
| `NovaFlexLayout` | 碧青 | 176° | −0.1560 | ×1.00 | ×0.64 | `#3a9d97` | `#49c4bd` | 大屏 HMI · 碧青冷静、工业数据 |
| `NovaIncubator` | 紫晶 | 283° | +0.1390 | ×1.00 | ×1.00 | `#c85bf5` | `#d15fff` | 应用孵化 · 紫晶孕育、CARF 收敛 |
| `NovaMobile` | 天青 | 193° | −0.1110 | ×1.00 | ×0.95 | `#56cae9` | `#5fddff` | 移动根壳 · 天青轻盈 |
| `NovaOrbit` | 靛青 | 243° | +0.0290 | ×0.94 | ×0.98 | `#6962f0` | `#7068ff` | 意图轨道 · 靛青深邃、感知 |
| `NovaSetupWizard` | 湖绿 | 168° | −0.1790 | ×1.00 | ×0.76 | `#45baa3` | `#56e9cc` | 初始化向导 · 湖绿代表启程与通过 |

> 表中色值为 **QML 引擎实测**（`QQmlComponent` 实例化读 `_ink` 属性），非纸面推算。基准 `NovaTheme.primary = #5B6EF5`（hue 0.6461 / sat 0.6286 / val 0.9608）。

---

## 3. 实现形态（每个组件的私有令牌块）

10 个组件在 CC-1「唯一组合上下文」块中各注入一段**私有**主题令牌（以 `NovaFlexLayout` 碧青为例）：

```qml
// ── 专属主题 · 碧青（色相 176°，偏移 -0.1560）──
// 大屏 HMI · 碧青冷静、工业数据；色相随 setBrand 漂移，饱和/明度系数独立定制（CC-3：组件内仍单色相）
readonly property real _themeHue: (NovaTheme.primary.hsvHue + (-0.1560) + 1) % 1
readonly property color _accent: Qt.hsva(root._themeHue,
    Math.min(1, NovaTheme.primary.hsvSaturation * 1.00),
    Math.min(1, NovaTheme.primary.hsvValue * 0.64 * (NovaTheme.isDark ? 1.25 : 1)), 1)
readonly property color _ink: root._accent
readonly property color _inkSoft: Qt.lighter(root._accent, 1.35)
readonly property color _inkPale: Qt.lighter(root._accent, 1.7)   // 仅三档组件有
```

随后该组件所有身份装饰（`_ink` / `_inkSoft` / `_inkPale` 的消费点）自动呈现专属色——**几何、anchors、opacity、槽位、动效一个字节未动**。

---

## 4. 架构铁律（为何零漂移）

1. **私有 `_` 令牌不进冻结面**：`gen_api_freeze.py::_is_public()` 显式排除 `_` 前缀；10 个组件的 property / signal / alias / function **逐字未变**，144 类型 / 指纹 `4f882374ad52262b` 零漂移。
2. **不用 `NovaTheme.secondary|accent`**：`audit_ceiling.py` 把它判为撞色反模式（CC-3）。专属色一律 `NovaTheme.primary.hsvHue` 派生 + 独立系数，**撞色计数 0**。
3. **不写回全局单例**：`NovaTheme` 是 `pragma Singleton`，在组件内赋值 `NovaTheme.primary = ...` 会污染全库。本设计只读 `hsvHue/hsvSaturation/hsvValue`，**零写回**。
4. **语义色不随主题偏移**：`NovaTheme.positive / negative / warning / info`（在线状态点、SLA 等）保持原义，`primaryText` 等 AA 派生色仍由 NovaTheme 统一计算。
5. **decorative 不挂 Accessible**：10 组件维持 `a11y: decorative`，主题色只作用于抽象几何，屏读器零噪声。
6. **每次显示只用专属主题**：同屏只实例化一个组合根时，只有它的专属色出现（组件内单色相）；跨壳同屏展示属 Gallery 对照场景，各壳身份色不同但均在冷色家族，不构成撞色。

---

## 5. 维护纪律

1. 调整某组件主题：只改该组件私有令牌块的 `offset / sat系数 / val系数`，**不动几何与其它组件**。
2. 新增组合根的主题：按 §1 四要件选色相与系数，在 §2 总表登记，跑 §6 门禁。
3. 主题色**不进 `NovaTheme` 公共令牌表**（避免冻结面与 91 基础控件污染）；只在组合根内部派生。
4. 禁止把主题做成公共 `style` / `variant` / `theme` 属性——那属 additive 公共 API，须 CSA 拍板 + minor 重签（见 §0「3 主题」说明）。

---

## 1.6 专属 / 亮色二态切换（13:39 方案 A · demo 层）

10 个独立 demo（`examples/layout_shell/<name>/main.qml`）顶部的圆形明暗按钮升级为**二态切换**：

| 元素 | 专属态（默认） | 亮色态 |
|---|---|---|
| `themeMode` | `"signature"` | `"light"` |
| 组件私有开关 | `_signatureOn: true` → `_themeHue = (primary.hsvHue + 偏移 + 1) % 1` | `_signatureOn: false` → `_themeHue = primary.hsvHue`（偏移归零） |
| 明度 | `NovaTheme.setDark(true)` 深底 + Aurora 亮核 | `NovaTheme.setDark(false)` 浅底 |
| 视觉 | 各组件专属身份色（靛蓝 / 紫晶 / 钢蓝 …） | 全库统一品牌蓝 `#5B6EF5` |

实现要点：
- 组件令牌块新增 `property bool _signatureOn: true`（私有、非 `readonly`，不进冻结面）；`_themeHue` 用三元表达式在「专属偏移」与「全局品牌蓝」间切换，`_accent` / `_ink` / `_glow` 自动跟随。
- demo 根 `ApplicationWindow` 新增 `themeMode` 属性 + `onThemeModeChanged` 信号处理器（明暗跟随属性变化，**不新增第二个 `Component.onCompleted`**——原已有 `NovaScreen.source = win`，重复赋值会触发 QML `Property value set multiple times` 实跑失败，`check_all.py --tier static` 的 qmllint 不报此类错）。
- 组件实例 `id: shell` 绑定 `_signatureOn: win.themeMode === "signature"`；切换按钮与状态栏文字同步标示当前态。
- 20 张双态实跑截图归档 `docs/screenshots/theme_modes/<组件>_signature.png` / `_light.png`。

**边界**：仅 demo 层二态切换，非全局公共 API；`NovaTheme` 公共属性零变化，冻结面 144 类型 / 指纹 `4f882374ad52262b` 零漂移。

---

## 6. 验证记录（2026-11-26 · 全绿）

| 门禁 | 结果 |
|---|---|
| 10 组件明暗双模式实例化 | 20 组全 `Status.Ready`，`_ink` 色值逐项实测（§2 表） |
| `check_qmllint.py` | 0 error · 594 warning 全在预算内（**零新增告警**） |
| `audit_ceiling.py` | PASS · 20/20 六维全绿（撞色 0 / 断链 0 / 非法入参 60/60 / RTL 20/20） |
| `gen_api_freeze.py --check` | 144 类型零漂移 · 指纹 `4f882374ad52262b` 不变 |
| `test_layout_shells.py` | 20/20 解析实例化 PASS |

---

## 7. 封版声明（CARF）

- **C 构想**：CSA「开动超脑为 10 组件设计专属、专业、艺术级主题，必须惊艳；每次显示只用组件的专属主题」。
- **A 实现**：10 组件各注入私有主题令牌块（色相偏移 + 独立 sat/val 系数 + 暗色提亮），身份装饰全改走 `_accent`；本文档沉淀色值总表与架构铁律。
- **R 打磨**：从「统一 sat/val 荧光色」升级为「独立 sat/val 沉稳色」（钢蓝 / 石板蓝 / 碧青 / 湖绿艺术级配色），明暗双模式分别实测；「3 主题」问句如实澄清为明暗 × 专属色二维体系。
- **F 封版**：**零公共属性 / 零冻结面 / 零 qmldir / 零模块 URI / 零几何改动**，指纹 `4f882374ad52262b` 不变。

> **发布边界**：本轮全部改动留工作树未提交，`commit / push / tag / PyPI / 站点上线` **全归 CSA**。
