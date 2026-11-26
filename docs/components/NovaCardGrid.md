# NovaCardGrid · 卡片网格壳

> **模块** `Nova.Composite.LayoutShell` · **分类** 多栏工作台 · **pyside-nova 1.2.1** · API 冻结指纹 `4f882374ad52262b` · **20/20 天花板销号** · a11y `decorative`
> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；重跑生成器即可同步。

## 概览

NovaCardGrid 卡片网格壳：筛选工具条 + 网格骨架 + 分页状态栏（对标组件画廊 / 模板市场） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 伪筛选胶囊 / 伪视图切换钮改为主色系抽象几何（CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 filterSlot/gridSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent

- **身份**：工具条抽象几何标识（筛选 / 视图切换）+ Flow 网格骨架
- **依赖组件**：`NovaTheme`、`NovaFooter`、`NovaSeparator`（全部为库内已导出公共类型）
- **天花板销号**：✅ 已销号 · 批次 4 · 三态「浅 / 深 / 列数变化」
- **台账备注**：模板市场
- **源码**：`Nova/Composite/LayoutShell/NovaCardGrid.qml`

## Props

| 属性 | 类型 | 默认值 |
|---|---|---|
| `filterHeight` | `int` | `52` |
| `footerHeight` | `int` | `48` |
| `padding` | `int` | `12` |
| `showFilter` | `bool` | `true` |
| `showFooter` | `bool` | `true` |

## Slots

| 槽位 | 类型 | 说明 |
|---|---|---|
| `filterSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `footerSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `gridSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `overlaySlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |

## Events / Signals

（该组件不 emit 信号）

## Methods

（该组件无公开方法）

## 最小示例

```qml
import QtQuick
import Nova.Composite.LayoutShell

NovaCardGrid {
    anchors.fill: parent

    filterSlot: Item {
        anchors.fill: parent
        // 业务内容：注入顶层须铺满（CC-6）
    }
}
```

## 三态装配图

> 真实 Qt Quick 引擎渲染；60 张全量索引见 [装配图索引](showcase.md)

| 浅色 | 深色 | 变体 |
|---|---|---|
| ![浅色](../screenshots/card_grid_showcase_light.png) | ![深色](../screenshots/card_grid_showcase_dark.png) | ![变体](../screenshots/card_grid_showcase_variant.png) |

## 相关

- [20 项组合根容器总览](index.md)
- [60 张三态装配图索引](showcase.md)
- [CARF-R 20/20 销号台账](../prescript/AUDIT_CEILING.md)
- [组件清单（144 项）](../COMPONENT_LIST.md)
- [API 冻结清单](../API_FREEZE.md)
