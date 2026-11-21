# 组件 API 参考 — pyside-nova Components

> 0.2.1 已交付 12 个组件。API 与 Quasar 1:1 对齐（对标基线 **2.26.0**），例外均有注明。
> 每个组件在 `examples/gallery/` 中均有实机展示页面。槽机制详见《架构宪法》第 4 章
> （[CONSTITUTION.md](CONSTITUTION.md)）。

## 槽机制总览（Quasar 槽 → QML 映射）

| 组件 | 默认槽 | 命名槽 | 作用域槽 |
|---|---|---|---|
| `NovaBtn` | ✅ `default property alias`（覆盖层宿主） | loading 规划于 M1 | — |
| `NovaChip` | ✅ | — | — |
| `NovaAvatar` | ✅ | — | — |
| `NovaIcon` | ✅ | — | — |
| `NovaBadge` | ✅ | — | — |
| `NovaCard` | ✅ | Section / Actions 组合子组件 | — |
| `NovaCardSection` / `NovaCardActions` | ✅ | — | — |
| `NovaTable` / `NovaList`（M1） | — | — | ✅ `property Component delegate` |

```qml
// 默认槽示例：子项直接写入即进入组件覆盖层
NovaBtn {
    text: "发布"
    Rectangle { width: 4; height: 4; color: NovaTheme.negative }   // 状态点叠加
}
```

## Nova.Services（单例服务）

### NovaTheme

设计令牌单例。完整令牌表见 [DESIGN_TOKENS.md](DESIGN_TOKENS.md)。

| 成员 | 类型 | 说明 |
|---|---|---|
| `isDark` | bool | 明暗状态（对标 `$q.dark.isActive`） |
| `toggleDark()` | fn | 一键切换主题（对标 `$q.dark.toggle()`） |
| `setDark(v)` | fn | 直接设定明暗（对标 `$q.dark.set()`） |
| `primary / secondary / accent / dark / positive / negative / info / warning` | color | Quasar 8 大品牌变量 1:1，可写（换肤） |
| `setBrand(color)` | fn | 运行时换肤 |
| `page / surface / surfaceAlt / outline / textColor / textMuted` | color | 表面色，只读，随 isDark 切换 |
| `textOnPrimary` | color | 主色之上的文字（命名规避 `on*` 保留字） |
| `spacingS/M/L`、`radiusS/M/L`、`fontXS…XL`、`fontFamily` | — | 几何/字体令牌 |
| `shadowColor(level)` | fn | 0~5 级高程阴影色 |
| `iconLocalRoot` | url | 本地图标包根目录 |

### NovaScreen

屏幕断点单例（Quasar Screen 插件 1:1）。阈值 `{xs:600, sm:1024, md:1440, lg:1920}`。

| 成员 | 说明 |
|---|---|
| `source` | 绑定的 Item（通常是窗口） |
| `width / height` | 源尺寸 |
| `name` | `"xs" | "sm" | "md" | "lg" | "xl"` |
| `isXs / isSm / isMd / isLg / isXl` | 等值判定 |
| `ltSm / ltMd / ltLg` | 小于判定（lt = less than） |
| `gtXs / gtSm / gtMd / gtLg` | 大于等于判定 |
| `isMobile` | `ltSm` 别名 |
| `setThresholds(obj)` | 自定义阈值 |

```qml
ApplicationWindow {
    Component.onCompleted: NovaScreen.source = window  // ⚠ 不能对象体内声明式绑定
}
```

## Nova.Controls（组件）

### NovaBtn（对标 QBtn）

按钮：三种形态 × 三种尺寸，内置水波纹 / hover / loading / 键盘触发。

| 属性 | 默认 | 说明 |
|---|---|---|
| `text` / `icon` / `iconRight` | `""` | 内容；`icon` 智能识别 `mdi:home` 式引用或字形/emoji |
| `variant` | `"filled"` | `filled` \| `outlined` \| `flat` |
| `size` | `"md"` | `sm` \| `md` \| `lg` |
| `round` / `dense` | false | 圆形 / 紧凑 |
| `tint` | `NovaTheme.primary` | 基调色（API 约定：等同 QBtn `color`） |
| `disable` / `loading` | false | 状态 |
| 信号 | — | `clicked()` / `pressed()` / `released()` |

### NovaCard / NovaCardSection / NovaCardActions（对标 QCard 系列）

| 属性（NovaCard） | 默认 | 说明 |
|---|---|---|
| `flat` / `elevated` | false / `!flat` | 平面 / 阴影模式 |
| `bordered` | false | 描边 |
| `elevation` | 2 | 高程 0~5，映射 `NovaTheme.shadowColor` |
| `content`（default） | — | 卡片内容（即 CardSection 子项） |

- `NovaCardSection`：内容区，`padding` 默认 `spacingL`
- `NovaCardActions`：操作区，`align: "right" | "left" | "center"`

### NovaChip（对标 QChip）

| 属性 | 默认 | 说明 |
|---|---|---|
| `text` / `icon` | `""` | 内容 |
| `filled` / `outlined` | false | 外观（默认 tinted） |
| `dense` | false | 紧凑（26px） |
| `selected` | false | 选中态 |
| `tint` | primary | 基调色 |
| `clickable` / `removable` / `disable` | false | 交互 |
| 信号 | — | `clicked()` / `removed()` |

### NovaAvatar（对标 QAvatar）

| 属性 | 默认 | 说明 |
|---|---|---|
| `text` | `""` | 文字/emoji |
| `source` | `""` | 图片地址（url） |
| `size` | 44 | 直径 |
| `square` | false | 方形 |
| `tint` / `textColor` | 自动 / 白 | 无图片时按 text 哈希自动配色 |

### NovaIcon（对标 QIcon）

| 属性 | 默认 | 说明 |
|---|---|---|
| `icon` | `""` | `"mdi:home"` / `"material:favorite"` / `"material-outlined:settings"` |
| `source` | `""` | 直接指定图片地址（优先级最高） |
| `size` | 24 | 边长 |
| `color` | `NovaTheme.textColor` | 着色 |
| `monochrome` | true | 单色化；false 保留原 SVG 彩色 |
| `cloudFallback` | true | 本地缺失时回落 jsDelivr CDN |

加载链：`source` > 本地包（`NovaTheme.iconLocalRoot`）> 云端 CDN（自动回落）。

### NovaBadge（对标 QBadge，子项挂载）

| 属性 | 默认 | 说明 |
|---|---|---|
| `text` | `""` | 数值/文本；**空字符串 = 红点模式** |
| `tint` / `textColor` | negative / 白 | 颜色 |
| `offsetX / offsetY` | 0 | 位移微调 |
| `floating` | false | 浮出（部分溢出容器边缘） |

```qml
NovaBtn { icon: "🔔"; round: true; NovaBadge { text: "99+" } }
```

### NovaSpace / NovaSeparator（对标 QSpace / QSeparator）

- `NovaSpace`：占位空白
- `NovaSeparator`：分隔线，`vertical` 属性切换方向，颜色取 `outline` 令牌

## Nova.Behaviors（行为）

### NovaRipple（对标 v-ripple，子项挂载）

| 属性 | 默认 | 说明 |
|---|---|---|
| `color` | `NovaTheme.ripple` | 波纹色 |
| `duration` | 550 | 时长 ms |

```qml
Rectangle { NovaRipple { } }   // 挂载到任意 Item；NovaBtn 内置按压波纹
```

## API 约定汇总

| 约定 | 原因 |
|---|---|
| 基调色属性命名 `tint` | `color` 与 Rectangle 基类冲突 |
| 挂载式组件以子项形式使用 | Qt 6.12 纯 QML 不支持自定义 attached property（M1 经 `QML_ATTACHED` 补齐） |
| 语义文本色 `textOnPrimary / textColor / textMuted` | 禁用 `on*` 前缀属性名 |
