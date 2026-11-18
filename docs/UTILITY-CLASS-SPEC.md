# Nova QML 工具类（Utility Class）实施规范 —— 企业旗舰版 · 封版基线 v1.0

> 文档定位：`pyside-nova` 原子化外观工具类的**唯一真源规范**，对标 Quasar 的 `class="bg-primary text-white"`。
> 配套规范：[`SLOT-SPEC.md`](SLOT-SPEC.md)（QML 插槽实施规范）、[`ARCHITECTURE.md`](ARCHITECTURE.md)（架构基线）。
> 对标文档：<https://quasar.dev/style/color-palette>、<https://quasar.dev/style/shadow>。
> 入库路径：`pyside-nova/docs/UTILITY-CLASS-SPEC.md`。
> 状态：**封版（Final）**，仅做向后兼容的增补；破坏性变更需走 ARCHITECTURE.md 变更评审。

---

## 0. 背景与前提

### 0.1 截图里那行是什么

```vue
class="bg-primary text-white"
```

- `bg-primary`：背景色 = `Theme.primary`
- `text-white`：文字色 = `#FFFFFF`
- 本质：Quasar 内置**原子工具类（Utility Class）**，是预定义的语义化样式简写，可叠加、可动态绑定、全局统一，不是组件 Prop，也不是 CSS 文件里手写的样式。

### 0.2 技术前提（强制）

- 渲染底座：Qt Quick Scene Graph，纯 QML，**不引入任何 CSS 引擎、不做字符串 eval**。
- 主题：颜色全部取自 `Theme.*`；明暗主题自动切换，禁止硬编码色值。
- 单位：所有间距/圆角/线宽/图标尺寸必须经 `Units.px()`，禁止裸写像素魔法数字（遵循 `Units.qml` 规则）。
- Qt：PySide6 ≥ 6.5 LTS（主测 6.8），Python ≥ 3.10；组件前缀 `Nova*`，模块 `import Nova 1.0`。

### 0.3 一句话定义

> QML 没有 `class` 属性。Nova 用**组件内置 `utilityClasses` 字符串属性 + 独立 `NovaUtility` 包裹组件**模拟 Quasar 工具类体系：空格分词、白名单校验、Token 驱动、静态可检查，只做外观附加，不碰布局与交互。

### 0.4 术语对齐表

| Quasar (Vue) | Nova (QML) 实现 | 说明 |
| --- | --- | --- |
| `class="bg-primary"` | `utilityClasses: "bg-primary"` | 组件内置属性（模式 A） |
| 给任意元素加 class | `NovaUtility { utilityClasses: "..." }` | 独立包裹组件（模式 B） |
| `bg-*` 色板类 | `bg-*` 工具类 | 映射 `Theme.*` |
| `text-*` 文字类 | `text-*` 工具类 | 映射 `Theme.*` |
| `shadow-*` 阴影类 | `elevation-1` ~ `elevation-5` | 走阴影参数 |
| `rounded-*` 圆角类 | `rounded-sm/md/lg/pill` | 映射 `Theme.radius*` |
| `md:bg-primary` 响应式 | ❌ 首期不支持 | 断点系统单独立项 |
| class 优先级 | 组件原生 Prop > 工具类 | 见第 4 节 |

---

## 1. 设计原则（强制）

1. **命名对齐**：工具类名称与 Quasar 保持一致（`bg-primary`、`text-white`、`elevation-2`、`rounded-md`），降低两库迁移成本；新增工具类必须评审并登记白名单，禁止自创缩写。
2. **可叠加**：多个工具类用**空格**分隔；同类后者覆盖前者（右覆盖左）。
3. **Token 驱动**：只映射 `Theme` 已有 token，不允许在工具类里出现色值字面量；主题切换自动跟随。
4. **静态可检查**：允许简单三元绑定，禁止动态字符串拼接与 eval；`qmllint` + 契约测试必须能校验白名单。
5. **不侵入插槽**：工具类只作用于组件本体容器，**不修改插槽内部内容样式**（与 Quasar 行为一致，插槽样式自包含）。
6. **向后兼容**：`utilityClasses` 默认 `""`，不传不改变任何既有渲染；老代码零改动。
7. **优先级固定**：组件原生 Prop（`color` / `variant`）> 工具类；文档必须公示。
8. **只做外观**：仅背景色、文字色、阴影、圆角；**不处理间距、尺寸、布局、交互、动画**。

---

## 2. 合法工具类清单（首期封版白名单）

### 2.1 背景色 `bg-*`

| 工具类 | 含义 | 映射 |
| --- | --- | --- |
| `bg-primary` | 主色底 | `Theme.primary` |
| `bg-secondary` | 次要色底 | `Theme.secondary` |
| `bg-positive` | 成功色底 | `Theme.positive` |
| `bg-negative` | 错误/危险色底 | `Theme.negative` |
| `bg-warning` | 警告色底 | `Theme.warning` |
| `bg-info` | 信息色底 | `Theme.info` |
| `bg-dark` | 深色底 | `Theme.dark` |
| `bg-white` | 白色底 | `Theme.white` |
| `bg-background` | 页面底色 | `Theme.background` |
| `bg-surface` | 表面/卡片底 | `Theme.surface` |

### 2.2 文字色 `text-*`

| 工具类 | 含义 | 映射 |
| --- | --- | --- |
| `text-white` | 白色文字 | `Theme.white` |
| `text-primary` | 主色文字 | `Theme.primary` |
| `text-secondary` | 次要色文字 | `Theme.secondary` |
| `text-positive` | 成功色文字 | `Theme.positive` |
| `text-negative` | 错误色文字 | `Theme.negative` |
| `text-warning` | 警告色文字 | `Theme.warning` |
| `text-dark` | 正文主色文字 | `Theme.text_primary` |
| `text-muted` | 弱化次要文字 | `Theme.text_secondary` |
| `text-disabled` | 禁用态文字 | `Theme.disabled` |

> 约定：`text-dark` 在 Nova 中语义为「正文主色文字」（暗色主题下自动变浅），不是固定黑色；对外文档写明。

### 2.3 阴影 `elevation-*`

| 工具类 | 含义 | 实现 |
| --- | --- | --- |
| `elevation-1` | 最低阴影 | 1 级模糊/偏移 |
| `elevation-2` | 卡片默认 | 2 级 |
| `elevation-3` | 浮起面板 | 3 级 |
| `elevation-4` | 弹层/抽屉 | 4 级 |
| `elevation-5` | 最高（对话框） | 5 级 |

> 与 Quasar `shadow-1..24` 的差异：Nova 只开放 5 级语义档位，走 token 而非硬编码百分比；如后续需要更多档位，只在此表扩展，不改实现。

### 2.4 圆角 `rounded-*`

| 工具类 | 含义 | 映射 |
| --- | --- | --- |
| `rounded-none` | 直角 | `Theme.radiusNone` |
| `rounded-sm` | 小圆角 | `Theme.radiusSm` |
| `rounded-md` | 中圆角（默认） | `Theme.radiusMd` |
| `rounded-lg` | 大圆角 | `Theme.radiusLg` |
| `rounded-pill` | 胶囊 | `Theme.radiusPill` |

### 2.5 白名单之外的 class

一律**无效并告警**：契约校验不通过、运行时保持默认外观（不崩、不静默吞掉）。禁止"猜测性兼容"未登记名称。

---

## 3. API 定义规范

### 3.1 统一属性

| 项 | 定义 |
| --- | --- |
| 属性名 | `utilityClasses` |
| 类型 | `string` |
| 默认值 | `""` |
| 分隔符 | 空格（与 Quasar 完全一致） |
| 示例 | `utilityClasses: "bg-primary text-white elevation-2 rounded-md"` |
| 非法值 | 未在白名单内 → 忽略 + `console.warn("[Nova] unknown utility class: xxx")` |

### 3.2 两种使用模式

**模式 A：组件内置属性（推荐，观感最贴近 Quasar）**

容器类组件（`NovaDrawer` / `NovaCard` / `NovaDialog` / `NovaPanel`）内置 `utilityClasses`。

```qml
// 对标截图 Quasar 写法
NovaDrawer {
    id: drawerLeft
    opened: false
    drawerWidth: 200
    breakpoint: 700
    elevated: true
    utilityClasses: "bg-primary text-white"
}
```

> 快捷别名：`elevated: true` 等价于附加 `elevation-2`。两者二选一即可，同时存在时以 `elevation-*` 显式档位为准。

**模式 B：独立包裹组件 `NovaUtility`（任意 Item 可用）**

给普通 `Item`、自定义内容、未内置该属性的组件附加样式。

```qml
NovaUtility {
    utilityClasses: "bg-primary text-white elevation-3 rounded-md"
    width: Units.px(240)
    height: Units.px(120)

    NovaButton {
        anchors.centerIn: parent
        label: "测试按钮"
        variant: "text"
    }
}
```

### 3.3 对外只读输出（供组件内部消费）

`NovaUtility` 计算后对外暴露只读结果，组件/调用方可以读，但**禁止回写**：

| 只读属性 | 类型 | 说明 |
| --- | --- | --- |
| `textColor` | `color` | 解析后的文字色；无匹配为 `"transparent"`（表示"不改"） |
| `backgroundColor` | `color` | 解析后的背景色；无匹配为 `"transparent"` |
| `elevationLevel` | `int` | 0~5 |
| `radiusToken` | `string` | `"" / none / sm / md / lg / pill` |
| `classList` | `var` | 分词后的字符串数组（调试用） |

> 语义约定：`transparent` 一律表示「该维度不施加样式」，由组件回退到自身 Prop/Theme 默认值。**禁止把 `transparent` 当作"清空背景"的语义使用**。

---

## 4. 优先级与仲裁规则（封版固定）

### 4.1 总顺序

```
组件原生 Prop（color / variant）  >  utilityClasses 工具类  >  组件内置 Theme 默认值
```

### 4.2 同类工具类

书写靠后的覆盖靠前：

```qml
utilityClasses: "bg-surface bg-primary"   // 最终 bg-primary
```

### 4.3 冲突示例表（NovaDrawer）

| 场景 | 最终背景 | 说明 |
| --- | --- | --- |
| 仅 `color: "primary"` | `Theme.primary` | 原生 Prop 生效 |
| 仅 `utilityClasses: "bg-secondary"` | `Theme.secondary` | 工具类生效 |
| `color: "primary"` + `"bg-secondary"` | `Theme.primary` | **原生 Prop 优先** |
| `utilityClasses: "bg-surface bg-primary"` | `Theme.primary` | 右覆盖左 |
| 都不传 | `Theme.surface` | Theme 默认值 |

### 4.4 与插槽的边界

- 工具类**不修改插槽内容**：`defaultSlotContent` 里的 `Text` 颜色不由外层 `text-white` 决定，需在插槽内自行绑定或使用 `NovaUtility`。
- 组件可把解析结果通过只读别名开放给内部默认渲染层，但**不得强制注入插槽子树**。

---

## 5. 实现范式（可直接复制）

### 5.1 `NovaUtility.qml` 定稿源码

```qml
/**
 * NovaUtility v1.0 Final
 * 原子工具类包裹组件，对标 Quasar utility class
 * 规范归属：docs/UTILITY-CLASS-SPEC.md
 */
import QtQuick

Item {
    id: root

    // 对标 Quasar class="..."，空格分隔
    property string utilityClasses: ""
    default property alias content: targetItem.children

    implicitWidth: targetItem.childrenRect.width
    implicitHeight: targetItem.childrenRect.height

    Item {
        id: targetItem
        anchors.fill: parent
    }

    // ── 分词（空串安全）
    readonly property var classList: utilityClasses.split(/\s+/).filter(function (c) { return c !== "" })

    function has(name) {
        return classList.indexOf(name) !== -1
    }

    // ── 白名单告警（不崩、不静默）
    readonly property var _known: [
        "bg-primary", "bg-secondary", "bg-positive", "bg-negative", "bg-warning",
        "bg-info", "bg-dark", "bg-white", "bg-background", "bg-surface",
        "text-white", "text-primary", "text-secondary", "text-positive",
        "text-negative", "text-warning", "text-dark", "text-muted", "text-disabled",
        "elevation-1", "elevation-2", "elevation-3", "elevation-4", "elevation-5",
        "rounded-none", "rounded-sm", "rounded-md", "rounded-lg", "rounded-pill"
    ]

    Component.onCompleted: {
        for (var i = 0; i < classList.length; i++) {
            if (_known.indexOf(classList[i]) === -1)
                console.warn("[Nova] unknown utility class: " + classList[i])
        }
    }

    // ── 背景色（右覆盖左：自后向前取）
    readonly property color backgroundColor: {
        for (var i = classList.length - 1; i >= 0; i--) {
            var c = classList[i]
            if (c === "bg-primary") return Theme.primary
            if (c === "bg-secondary") return Theme.secondary
            if (c === "bg-positive") return Theme.positive
            if (c === "bg-negative") return Theme.negative
            if (c === "bg-warning") return Theme.warning
            if (c === "bg-info") return Theme.info
            if (c === "bg-dark") return Theme.dark
            if (c === "bg-white") return Theme.white
            if (c === "bg-background") return Theme.background
            if (c === "bg-surface") return Theme.surface
        }
        return "transparent"
    }

    // ── 文字色
    readonly property color textColor: {
        for (var i = classList.length - 1; i >= 0; i--) {
            var c = classList[i]
            if (c === "text-white") return Theme.white
            if (c === "text-primary") return Theme.primary
            if (c === "text-secondary") return Theme.secondary
            if (c === "text-positive") return Theme.positive
            if (c === "text-negative") return Theme.negative
            if (c === "text-warning") return Theme.warning
            if (c === "text-dark") return Theme.text_primary
            if (c === "text-muted") return Theme.text_secondary
            if (c === "text-disabled") return Theme.disabled
        }
        return "transparent"
    }

    // ── 阴影档位
    readonly property int elevationLevel: {
        for (var lv = 5; lv >= 1; lv--) {
            if (has("elevation-" + lv)) return lv
        }
        return 0
    }

    // ── 圆角
    readonly property string radiusToken: {
        for (var i = classList.length - 1; i >= 0; i--) {
            var c = classList[i]
            if (c === "rounded-pill") return "pill"
            if (c === "rounded-lg") return "lg"
            if (c === "rounded-md") return "md"
            if (c === "rounded-sm") return "sm"
            if (c === "rounded-none") return "none"
        }
        return ""
    }

    readonly property int radiusPx: {
        if (radiusToken === "pill") return Units.px(Theme.radiusPill)
        if (radiusToken === "lg") return Units.px(Theme.radiusLg)
        if (radiusToken === "md") return Units.px(Theme.radiusMd)
        if (radiusToken === "sm") return Units.px(Theme.radiusSm)
        if (radiusToken === "none") return Units.px(Theme.radiusNone)
        return 0
    }

    // ── 背景层（z:-1，不遮挡子内容）
    Rectangle {
        anchors.fill: targetItem
        z: -1
        visible: root.backgroundColor !== "transparent"
        color: root.backgroundColor
        radius: root.radiusPx
    }

    // ── 阴影层（纯 QML 模拟 elevation，不引入 Effects 依赖）
    Rectangle {
        anchors.fill: targetItem
        z: -2
        visible: root.elevationLevel > 0
        color: "#000000"
        opacity: 0.04 * root.elevationLevel
        radius: root.radiusPx
        anchors.margins: -Units.px(root.elevationLevel)
        anchors.bottomMargin: -Units.px(root.elevationLevel * 2)
    }
}
```

### 5.2 组件集成范式（以 NovaDrawer 为例）

组件根增加 `utilityClasses`，解析交给共用内核，**不改动既有 Prop 渲染路径**：

```qml
Item {
    id: root

    // 对外
    property string utilityClasses: ""

    // 内部：统一走 NovaUtilityCore，禁止每个组件各写一套分词
    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)

    // 原生 Prop 优先：颜色显式设置时不采用工具类
    color: explicitColor !== "" ? Theme.colorOf(explicitColor) : _utilBg
}
```

### 5.3 推荐实现结构（消除重复解析）

```
Nova/
├── NovaUtilityCore.qml     # Singleton：分词 + 白名单 + 解析，唯一实现
├── NovaUtility.qml         # 包裹组件：消费 NovaUtilityCore
└── NovaDrawer.qml          # 内置 utilityClasses：消费 NovaUtilityCore
```

---

## 6. 工程质量与验收规范

### 6.1 静态检查（CI 必过）

- `qmllint` 纳入 CI，校验：未定义属性、重复赋值、别名绑定。
- 自定义 `tools/check_utility_classes.py`（pytest 内跑）：
  1. 扫描全部组件 QML，提取 `utilityClasses` 字符串常量；
  2. 逐个 token 比对第 2 节白名单；
  3. 出现白名单外 token → 红灯。

### 6.2 QML 单元测试用例（必须覆盖）

| # | 用例 | 期望 |
| --- | --- | --- |
| 1 | `utilityClasses: ""` | 全部为 `transparent` / `0` / `""`，无附加层可见 |
| 2 | 单类 `bg-primary` | 背景 = `Theme.primary` |
| 3 | 叠加 `bg-primary text-white elevation-2 rounded-md` | 四项同时生效，互不干扰 |
| 4 | 同类型覆盖 `bg-surface bg-primary` | 背景 = `Theme.primary` |
| 5 | 与原生 `color` 共存 | 原生 `color` 胜出 |
| 6 | 插槽内容 | 插槽内 `Text` 颜色不受外层 `text-white` 影响 |
| 7 | 非法 class `bg-foo` | 不崩溃、保持默认、`console.warn` 一次 |
| 8 | 明暗主题切换 | 工具类颜色随 `Theme.mode` 自动变化 |

### 6.3 MCP 元数据规范

组件元数据 JSON 必须导出 `utilityClasses` 白名单，供 AI 代理消费，避免编造不存在的 class：

```json
{
  "component": "NovaDrawer",
  "props": [
    {
      "name": "utilityClasses",
      "type": "string",
      "default": "",
      "delimiter": "space",
      "priority": "component-native-props-win",
      "validValues": [
        "bg-primary", "bg-secondary", "bg-positive", "bg-negative", "bg-warning",
        "bg-info", "bg-dark", "bg-white", "bg-background", "bg-surface",
        "text-white", "text-primary", "text-secondary", "text-positive",
        "text-negative", "text-warning", "text-dark", "text-muted", "text-disabled",
        "elevation-1", "elevation-2", "elevation-3", "elevation-4", "elevation-5",
        "rounded-none", "rounded-sm", "rounded-md", "rounded-lg", "rounded-pill"
      ],
      "description": "原子工具类，空格分隔，对标 Quasar class"
    }
  ]
}
```

### 6.4 文档模板（每个组件 API 文档统一加入）

| 属性 | 类型 | 默认 | 说明 |
| --- | --- | --- | --- |
| `utilityClasses` | `string` | `""` | 原子工具类，空格分隔，对标 Quasar `class`；支持 `bg-*` / `text-*` / `elevation-*` / `rounded-*`；组件原生 `color`、`variant` 优先级高于工具类；不修改插槽内部样式 |

---

## 7. 禁止行为清单（红线）

1. ❌ 在工具类里实现 CSS 选择器、伪类、动画、过渡。
2. ❌ 工具类修改布局：`width` / `height` / `anchors` / `margin` / `Layout.*`。
3. ❌ 工具类修改交互：`enabled` / `focus` / `visible` / 事件。
4. ❌ 动态拼接字符串：`utilityClasses: "bg-" + colorVar`（允许简单三元：`cond ? "bg-primary" : "bg-surface"`）。
5. ❌ 直接硬编码色值（`#2196F3`）：一律走 `Theme` token 或工具类。
6. ❌ 插槽内依赖外层 `textColor` 做文字色（插槽样式自包含）。
7. ❌ 新增工具类不入白名单、不更新 MCP 元数据、不写测试。
8. ❌ 把 `transparent` 当"清空背景"语义使用。
9. ❌ 每个组件各写一套分词/解析逻辑（必须共用 `NovaUtilityCore`）。

---

## 8. 落地路线（与现有组件迭代对齐）

| 步骤 | 内容 | 产出 |
| --- | --- | --- |
| 1 | 新增 `NovaUtilityCore.qml` 单例（分词 + 白名单 + 解析） | 唯一解析实现 |
| 2 | 新增 `NovaUtility.qml` 包裹组件，注册 `qmldir` | 模式 B 可用 |
| 3 | `NovaDrawer` / `NovaCard` / `NovaDialog` / `NovaButton` 增加 `utilityClasses` | 模式 A 可用 |
| 4 | `examples/` 增加与 Quasar 截图一对一的对照示例 | 迁移样板 |
| 5 | 导出 MCP 元数据含 `validValues` | AI 可识别 |
| 6 | 文档归档本文件，README 挂索引 | 封版入库 |

---

## 9. Quasar ↔ Nova 一对一对照（截图复刻）

Quasar：

```vue
<q-drawer
  v-model="drawerLeft"
  :width="200"
  breakpoint="700"
  elevated
  class="bg-primary text-white"
/>
```

pyside-nova：

```qml
NovaDrawer {
    id: drawerLeft
    opened: false
    drawerWidth: 200
    breakpoint: 700
    elevated: true
    utilityClasses: "bg-primary text-white"
}
```

差异说明（文档必须公示）：

| 项 | Quasar | Nova |
| --- | --- | --- |
| 双向绑定 | `v-model` | `opened` + `opened()/closed()` 信号 |
| 宽度 | `width` | `drawerWidth`（规避 QML 原生 `width` 冲突） |
| 工具类载体 | `class` | `utilityClasses` |
| 阴影快捷 | `elevated` | `elevated` / `elevation-*` 二选一 |
| 响应式前缀 | `md:` 支持 | ❌ 首期不支持（单独立项） |

---

## 10. 变更记录

| 版本 | 日期 | 内容 |
| --- | --- | --- |
| v1.0 | 2026-11-17 | 封版基线：白名单（4 类 30 项）、两种使用模式、优先级仲裁、`NovaUtility` 定稿源码、测试与元数据规范、落地路线 |

> （注：部分内容由豆包 AI 生成）