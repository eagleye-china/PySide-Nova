# Nova QML 插槽（Slot）实施规范 —— 企业旗舰版 · 封版基线 v1.0

> 文档定位：`pyside-nova` 组件库插槽能力的**唯一真源规范**，新增/迭代组件必须遵循。
> 对标体系：Quasar QDrawer / QBtn 的 Slots API（<https://quasar.dev/layout/drawer#qdrawer-api>）。
> 姊妹库：`pyside-quasar`（PySide6 Widgets）；本规范只约束 QML 侧。
> 入库路径：`pyside-nova/docs/SLOT-SPEC.md`。
> 状态：**封版（Final）**，仅做向后兼容的增补；破坏性变更需走 ARCHITECTURE.md 变更评审。

---

## 0. 适用范围与前提

### 0.1 技术前提
- 渲染底座：Qt Quick Scene Graph，纯 QML，无 `QtQuick.Controls` 业务依赖。
- 主题/单位：颜色取 `Theme.*`，所有间距/圆角/尺寸经 `Units.px()`，禁止裸写像素魔法数字（遵循 Units.qml 规则）。
- 组件前缀 `Nova*`，QML 模块 `import Nova 1.0`。

### 0.2 一句话定义
> QML 没有 Vue 的 `slot` 关键字。Nova 用 **`default property alias`（默认槽）+ 命名别名容器（命名槽）** 模拟 Quasar 插槽体系；QML 原生无作用域槽，通过**只读 `scope` 属性 + 信号**显式模拟，并在文档中标注限制。

### 0.3 术语对齐表

| Quasar (Vue) | Nova (QML) 实现 | 说明 |
| --- | --- | --- |
| `<template #default>` | `defaultSlotContent` | 主体内容槽，组件标签内直接书写的子项 |
| `<template #prepend>` | `prependSlotContent` | 前置（左侧）槽 |
| `<template #append>` | `appendSlotContent` | 后置（右侧）槽 |
| `<template #mini>` | `miniSlotContent` | 迷你态替换槽 |
| `#item="scope"` 作用域槽 | 只读 `scope` 属性 + 信号 | 模拟，非原生双向绑定 |
| 插槽优先级 | 一致：**Slot > Prop > 内置默认占位** | 见第 5 节 |

---

## 1. 设计原则（强制）

1. **简单内容走 Prop，复杂自定义内容走 Slot**：纯文本/颜色/布尔/数字用属性；图标组合、嵌套组件、自由布局开放槽。
2. **插槽全部可选**：不传槽时组件渲染内置默认内容；传了就覆盖对应默认渲染。
3. **插槽优先级高于对应 Prop**：同一位置同时提供槽与 Prop，槽内容生效，Prop 在该位置被忽略（文档必须写明覆盖关系）。
4. **槽容器只做承载，不做样式**：槽容器 `Item` 不自带背景、边框、内边距、固定宽高；位置与布局约束由组件负责，视觉样式交给调用方。
5. **槽隔离**：一个槽的子项不影响其他槽的布局；槽内子项只能引用组件对外暴露的 `scope`，禁止触碰组件私有 `id`。
6. **向后兼容**：新增槽一律为可选；老代码不传该槽不得报错、不得改变既有渲染。
7. **三模一致**：槽内自定义内容同样受 hover / pressed / disabled / loading 状态约束，组件需把状态透传到槽容器（见 6.3）。

---

## 2. 插槽分类

### 2.1 默认槽 `default`
最常用，容器类组件（Drawer / Card / Dialog / Page）主体内容。
- 组件内：`default property alias defaultSlotContent: defaultSlot.children`
- 调用方：直接写在组件标签内，无需声明槽名。

### 2.2 命名槽 `prepend / append / header / footer / mini / loading`
同一组件预留多个位置，各用独立别名容器承载。命名取值见第 3 节命名表。

### 2.3 模拟作用域槽 `scoped`
QML 原生不支持把内部状态回传给插槽模板。统一方案：
1. 组件暴露只读 `property var scope: ({ ... })`，封装需要外抛的状态；
2. 配套信号在状态变化时通知外部（如 `onItemClicked(scope)`）；
3. 文档明确标注「模拟作用域槽」，并写明：QML 为静态绑定，不具备 Vue 作用域槽的动态响应式体验。

---

## 3. 命名规范（强制）

### 3.1 槽名（对外语义名，全小写、短横线分隔）

| 槽名 | 用途 | 典型组件 |
| --- | --- | --- |
| `default` | 主体主内容 | NovaDrawer / NovaCard / NovaDialog / NovaButton |
| `prepend` | 前置（左）内容，图标/自定义元件 | NovaButton / NovaInput |
| `append` | 后置（右）内容 | NovaButton / NovaInput |
| `header` | 头部区域 | NovaCard / NovaDialog |
| `footer` | 底部区域 | NovaCard / NovaDialog |
| `mini` | 迷你态替换内容 | NovaDrawer |
| `loading` | 加载态替换内容 | NovaButton / NovaInput |

### 3.2 别名属性名（组件内对外暴露）

> 强制后缀 `SlotContent`，与普通属性一眼区分。

| 对外别名 | 绑定容器 |
| --- | --- |
| `defaultSlotContent` | `defaultSlot.children` |
| `prependSlotContent` | `prependSlot.children` |
| `appendSlotContent` | `appendSlot.children` |
| `headerSlotContent` | `headerSlot.children` |
| `footerSlotContent` | `footerSlot.children` |
| `miniSlotContent` | `miniSlot.children` |
| `loadingSlotContent` | `loadingSlot.children` |

### 3.3 禁止项
- ❌ 驼峰 / 大驼峰 / 中文槽名；❌ 无意义短名（`slot1`、`left`）。
- ❌ 别名不带 `SlotContent` 后缀；❌ 一个槽同时挂多个 `alias`。

---

## 4. 标准实现范式（可直接复制）

### 4.1 默认槽（容器类组件标配）

```qml
Item {
    id: root

    // 默认槽：固定写法
    default property alias defaultSlotContent: defaultSlot.children

    Item {
        id: defaultSlot
        anchors.fill: parent
        // 不在槽容器上写 margin / color；内边距由组件布局层负责
    }
}
```

调用方：

```qml
NovaDrawer {
    // 直接书写 → 进入 default 槽
    ColumnLayout {
        spacing: Units.px(8)
        NovaButton { label: "首页" }
    }
}
```

### 4.2 命名槽（prepend / append / mini）

```qml
Item {
    id: root

    // 默认槽
    default property alias defaultSlotContent: defaultSlot.children
    // 命名槽
    property alias prependSlotContent: prependSlot.children
    property alias appendSlotContent: appendSlot.children
    property alias miniSlotContent: miniSlot.children

    Item { id: defaultSlot }
    Item { id: prependSlot }
    Item { id: appendSlot }
    Item { id: miniSlot }
}
```

调用方（对象列表赋值）：

```qml
NovaButton {
    label: "提交"
    prependSlotContent: [
        Image { source: "icons/check.svg"; fillMode: Image.PreserveAspectFit }
    ]
    appendSlotContent: [
        NovaBadge { label: "Hot" }
    ]
}
```

### 4.3 模拟作用域槽

```qml
Item {
    id: root

    // 只读作用域：对外暴露行数据与序号
    readonly property var scope: ({ row: currentRow, index: currentIndex })
    property alias itemSlotContent: itemSlot.children

    signal itemClicked(var scope)

    Item { id: itemSlot }
}
```

调用方：

```qml
NovaList {
    itemSlotContent: [
        Text { text: root.scope.row.title }
    ]
}
```

> 限制：`scope` 字段只读，外部不得回写；行数据刷新时由组件更新 `scope` 并触发信号。

---

## 5. 优先级与渲染仲裁

### 5.1 仲裁顺序（高 → 低）

```
槽内容（Slot）  >  对应 Prop 文本/资源  >  组件内置默认占位
```

### 5.2 仲裁规则（以 NovaButton 为例）

| 位置 | 优先 | 其次 | 兜底 |
| --- | --- | --- | --- |
| 前置 | `prependSlotContent` 非空 | `icon` | 空白 |
| 主体 | `defaultSlotContent` 非空 | `label` | 空白 |
| 后置 | `appendSlotContent` 非空 | `iconRight` | 空白 |

### 5.3 实现要求
- 组件内用 `Loader` / 条件可见做仲裁，**不可槽与 Prop 同时叠绘**。
- 每个槽在文档 Slots 表中必须写明「覆盖哪个 Prop」。
- 槽列表非空判定：`xxxSlotContent.length > 0`。

参考仲裁骨架：

```qml
Row {
    Loader {
        active: prependSlotContent.length > 0
        sourceComponent: prependSlot
    }
    Loader {
        active: defaultSlotContent.length > 0
        sourceComponent: defaultSlot
    }
    Loader {
        active: appendSlotContent.length > 0
        sourceComponent: appendSlot
    }
}
```

---

## 6. 布局与状态约束

### 6.1 布局
1. 槽容器 `Item` 不设固定宽高，优先 `anchors` 或 `Layout` 自适应。
2. 组件负责槽的位置排布（prepend 在左、append 在右、mini 仅迷你态显示）。
3. 槽容器 `clip: false`，允许角标/气泡等溢出元素；需要裁剪时由调用方在自身子项上开启。
4. 高 DPI：槽内尺寸由调用方处理；组件不强行覆盖槽内字体、像素。

### 6.2 间距与内边距
- 组件层统一用 `Units.px(Theme.spaceMd)` 等 token 控制槽与边框、槽与槽之间的间距。
- 禁止在槽容器上硬编码 `anchors.margins: 16` 这类魔法值。

### 6.3 状态透传
组件需把 `disabled / loading / hovered / down` 等只读状态开放给槽内子项绑定；槽内自定义元件应跟随组件整体置灰/禁用：

```qml
readonly property bool disabled: false
// 槽容器随组件禁用态降级
Item {
    id: prependSlot
    opacity: root.disabled ? 0.5 : 1.0
}
```

### 6.4 隔离红线
- 槽内子项**禁止引用**组件私有 `id`（如 `bg`、`contentRow`）。
- 只能使用对外暴露的属性、`scope`、信号。
- 禁止在槽容器内写业务状态、动画、定时器；容器只承载。

---

## 7. API 文档模板（每个组件必附 Slots 表）

```markdown
## Slots

| Slot | 别名属性 | 说明 | 作用域 | 覆盖 Prop |
| --- | --- | --- | --- | --- |
| default | `defaultSlotContent` | 主体内容区域 | 否 | `label` |
| prepend | `prependSlotContent` | 前置图标/自定义元件 | 否 | `icon` |
| append | `appendSlotContent` | 后置内容 | 否 | `iconRight` |
| mini | `miniSlotContent` | 迷你态替换内容 | 否 | `default` 槽 |

> 插槽可选；不传则渲染内置默认内容。插槽优先级高于对应 Prop。
```

作用域槽额外标注：

```markdown
> `item` 为模拟作用域槽。`scope` 字段只读：`{ row, index }`；
> 行点击通过 `itemClicked(scope)` 信号回传。QML 为静态绑定，不支持 Vue 式动态作用域响应。
```

---

## 8. 工程与自动化规范

### 8.1 仓库结构
- 组件源码：`src/pyside_nova/qml/Nova/Nova<Name>.qml`，单组件单文件。
- `qmldir` 只注册组件，不注册槽；槽是组件内部能力。
- 组件 API 元数据：`theme/` 或 `meta/` 下导出 JSON，包含 props / slots / signals / methods，供 MCP 代理读取（避免 AI 只生成 Prop、漏掉槽）。

### 8.2 元数据字段约定（slots 段）

```json
{
  "component": "NovaButton",
  "slots": [
    {
      "name": "default",
      "alias": "defaultSlotContent",
      "scoped": false,
      "overrides": ["label"],
      "description": "主体自定义内容"
    },
    {
      "name": "prepend",
      "alias": "prependSlotContent",
      "scoped": false,
      "overrides": ["icon"],
      "description": "前置元件"
    }
  ]
}
```

### 8.3 静态校验
- `qmllint` 纳入 CI，校验槽别名绑定、未定义属性、重复赋值。
- 契约测试（pytest）：扫描组件 QML，校验每个 `*SlotContent` 别名都有对应 `Item` 容器；槽名落在第 3.1 节白名单内。

### 8.4 单元测试用例（QML Test / pytest 冒烟）
1. 不传任何槽 → 渲染内置默认占位。
2. 传入 default 槽 → 主体被替换。
3. 传入命名槽 → 指定位置替换，其余位置保持默认。
4. 槽与 Prop 同时存在 → 槽优先，Prop 被忽略。
5. 作用域槽 → `scope` 字段只读，信号回传正确。
6. 组件 `disabled / loading` → 槽内子项跟随降级。

---

## 9. 反面示例（禁止写法）

❌ 别名命名不合规：

```qml
property alias miniSlot: mini.children   // 缺 SlotContent 后缀
```

❌ 槽容器自带业务样式：

```qml
Item {
    id: prependSlot
    color: "#ccc"          // 禁止：样式应交调用方
    anchors.margins: 16    // 禁止：魔法值
}
```

❌ 槽与 Prop 叠绘、不做仲裁：

```qml
Text { text: root.icon }
Item { id: prependSlot }   // 两者同时渲染，未互斥
```

❌ 槽内耦合私有 id：

```qml
prependSlotContent: [
    Text { text: internalData.title }   // 禁止引用私有 id/私有数据
]
```

❌ 对原生作用域槽做黑魔法 hack：禁止用 `Qt.binding` 手写不可控的回写链路。

---

## 10. 现有组件槽位迁移清单（基线对齐）

> 现状：`NovaButton` 仅 Prop（`label / icon / iconRight`），尚未开放槽。下表为封版后迭代目标，新增槽均为向后兼容增补。

| 组件 | 规划槽 | 覆盖 Prop | 优先级 |
| --- | --- | --- | --- |
| NovaButton | `default` / `prepend` / `append` | `label` / `icon` / `iconRight` | P1 |
| NovaDrawer | `default` / `mini` | —（主体） | P1 |
| NovaCard | `default` / `header` / `footer` | — | P2 |
| NovaDialog | `default` / `header` / `footer` | — | P2 |
| NovaList | `item`（作用域） | — | P2 |

### 10.1 NovaButton 槽位落地骨架（迭代参考）

```qml
Item {
    id: root

    property string label: ""
    property url icon: ""
    property url iconRight: ""

    // 槽定义（遵循 3.2 命名）
    default property alias defaultSlotContent: defaultSlot.children
    property alias prependSlotContent: prependSlot.children
    property alias appendSlotContent: appendSlot.children

    Item { id: defaultSlot }
    Item { id: prependSlot }
    Item { id: appendSlot }

    Row {
        id: contentRow
        Loader { sourceComponent: prependSlotContent.length > 0 ? prependSlot : null }
        Loader { sourceComponent: defaultSlotContent.length > 0 ? defaultSlot : null }
        Loader { sourceComponent: appendSlotContent.length > 0 ? appendSlot : null }
    }
}
```

> 落地时保留既有 Prop 渲染作为兜底：槽为空时回退到 `icon / label / iconRight`，保证老代码零改动。

---

## 11. 变更记录

| 版本 | 日期 | 内容 |
| --- | --- | --- |
| v1.0 | 2026-11-17 | 封版基线：三类槽、命名规范、仲裁规则、布局约束、文档模板、元数据与测试清单、迁移清单 |

> （注：部分内容由豆包 AI 生成）