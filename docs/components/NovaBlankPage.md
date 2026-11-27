# NovaBlankPage · 纯净单页壳

> **模块** `Nova.Composite.LayoutShell` · **分类** 独立页壳 · **pyside-nova 1.10.0** · API 冻结指纹 `5328cd0e3c71e7ac` · **21/21 天花板销号** · a11y `decorative`
> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；重跑生成器即可同步。

## 概览

NovaBlankPage 纯净单页壳：居中阅读栏 + Header + Content + Footer，最克制的可定制基底（无侧栏 / 无标签导航） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 阅读栏 padding 与 NovaPage padding 合并为单一边距（CC-1）；槽位宿主独立铺满（CC-6）。 用法：向 headerSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent

- **身份**：居中阅读栏（最大宽度约束）+ 极细居中发丝
- **依赖组件**：`NovaTheme`、`NovaHeader`、`NovaFooter`、`NovaPage`（全部为库内已导出公共类型）
- **天花板销号**：✅ 已销号 · 批次 6 · 三态「浅 / 深 / 阅读栏宽度」
- **台账备注**：CARF 宣言文档阅读页
- **源码**：`Nova/Composite/LayoutShell/NovaBlankPage.qml`

## Props

| 属性 | 类型 | 默认值 |
|---|---|---|
| `footerHeight` | `int` | `48` |
| `headerHeight` | `int` | `56` |
| `padding` | `int` | `24` |
| `showFooter` | `bool` | `true` |
| `showHeader` | `bool` | `true` |

## Slots

| 槽位 | 类型 | 说明 |
|---|---|---|
| `contentSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `footerSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `headerSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `overlaySlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |

## Events / Signals

（该组件不 emit 信号）

## Methods

（该组件无公开方法）

## 最小示例

```qml
import QtQuick
import Nova.Composite.LayoutShell

NovaBlankPage {
    anchors.fill: parent

    contentSlot: Item {
        anchors.fill: parent
        // 业务内容：注入顶层须铺满（CC-6）
    }
}
```

## 三态装配图

> 真实 Qt Quick 引擎渲染；60 张全量索引见 [装配图索引](showcase.md)

| 浅色 | 深色 | 变体 |
|---|---|---|
| ![浅色](../screenshots/blank_page_showcase_light.png) | ![深色](../screenshots/blank_page_showcase_dark.png) | ![变体](../screenshots/blank_page_showcase_variant.png) |

## 相关

- [21 项组合根容器总览](index.md)
- [63 张三态装配图索引](showcase.md)
- [CARF-R 21/21 销号台账](../prescript/AUDIT_CEILING.md)
- [组件清单（147 项）](../COMPONENT_LIST.md)
- [API 冻结清单](../API_FREEZE.md)
