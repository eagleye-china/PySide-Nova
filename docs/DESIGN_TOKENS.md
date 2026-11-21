# 设计令牌 — pyside-nova Design Tokens

> `NovaTheme` 是三级令牌体系的全局单例（`pragma Singleton`），对标 Quasar 的
> brand 变量 + Dark 插件。所有组件只消费令牌，禁止魔法数值色。

## 令牌分层

```
基础令牌（Brand / Raw）      → 品牌色、语义色、几何常量、字阶、阴影
        ↓ 语义化
表面令牌（Surface，随 dark 自动切换） → page / surface / surfaceAlt / outline / textColor / textMuted
        ↓ 组件化
组件令牌（M1 规划）          → 每组件内部派生（如 NovaBtn._fg/_bg）
```

## 主题模式

```qml
NovaTheme.dark            // bool，当前明暗状态
NovaTheme.toggleDark()    // 一键切换，全部表面令牌自动重算
```

## 品牌色（可运行时换肤）

1:1 对标 Quasar 8 大品牌变量（`dark` 品牌色 1:1 同名；明暗模式为 `isDark`，对标 `$q.dark.isActive`）：

| 令牌 | 默认值 | 对标 Quasar |
|---|---|---|
| `primary` | `#5B6EF5` | `$primary` |
| `secondary` | `#26A69A` | `$secondary` |
| `accent` | `#FF7043` | `$accent` |
| `dark` | `#1D1D1D` | `$dark` |
| `positive` | `#22C55E` | `$positive` |
| `negative` | `#EF4444` | `$negative` |
| `info` | `#38BDF8` | `$info` |
| `warning` | `#F59E0B` | `$warning` |

```qml
// 运行时企业换肤
Component.onCompleted: NovaTheme.setBrand("#C62828")
```

## 语义色

| 令牌 | 值 | 用途 |
|---|---|---|
| `positive` | `#22C55E` | 成功/上升 |
| `negative` | `#EF4444` | 失败/危险 |
| `warning` | `#F59E0B` | 警告 |
| `info` | `#38BDF8` | 信息 |
| `textOnPrimary` | `#FFFFFF` | 主色之上的文字（命名规避 `on*` 保留字） |

## 表面色（随 dark 自动切换）

| 令牌 | Light | Dark |
|---|---|---|
| `page` | `#F2F4F7` | `#121216` |
| `surface` | `#FFFFFF` | `#1C1C21` |
| `surfaceAlt` | `#F7F8FA` | `#25252C` |
| `outline` | `#E3E5EB` | `#38383F` |
| `textColor` | `#1F2128` | `#E9EAEF` |
| `textMuted` | `#6E7380` | `#9DA0AB` |
| `ripple` | 黑 14% | 白 22% |

## 几何令牌

| 令牌 | 值 |
|---|---|
| `spacingS / M / L` | 6 / 12 / 24 |
| `radiusS / M / L` | 6 / 10 / 14 |

## 字体令牌

| 令牌 | 值 |
|---|---|
| `fontFamily` | `"Segoe UI"`（Windows 11 基线，跨平台应用可覆盖） |
| `fontXS / S / M / L / XL` | 11 / 13 / 15 / 18 / 24 |

## 阴影令牌

```qml
NovaTheme.shadowColor(level)   // 0~5 级高程 → 阴影色（明暗自适应）
```

| 级别 | Light alpha | Dark alpha |
|---|---|---|
| 0 | 0 | 0 |
| 1 | 0.06 | 0.18 |
| 2 | 0.10 | 0.26 |
| 3 | 0.14 | 0.34 |
| 4 | 0.18 | 0.42 |
| 5 | 0.22 | 0.50 |

## 图标资源令牌

| 令牌 | 说明 |
|---|---|
| `iconLocalRoot` | 本地图标包根目录（`file:///…/icons`，`scripts/fetch_icons.py` 产出）。空则 NovaIcon 走云端 CDN |

## 命名红线（评审强制）

1. 禁止 `on*` 前缀属性名（QML 信号处理器保留字）
2. 禁止组件内声明 `property color color`（基类冲突）→ 统一 `tint`
3. 表面/文本类令牌禁止硬编码在组件内，必须经 `NovaTheme`
