# NovaTabShell · 标签页工作台

> **模块** `Nova.Composite.LayoutShell` · **分类** 主导航 · **pyside-nova 1.9.0** · API 冻结指纹 `b15a4be38c000c59` · **21/21 天花板销号** · a11y `decorative`
> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；重跑生成器即可同步。

## 概览

NovaTabShell 标签页工作台壳：下划线激活指示条 + 标签栏 + 内容容器 + 状态栏（对标 Quasar QTabs） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 三色段落收敛主色系递减条、删底边重复分隔线（CC-2/CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 tabBarSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent

- **身份**：材质化标签栏（三态段落）+ 底部品牌下划线指示
- **依赖组件**：`NovaTheme`、`NovaFooter`、`NovaPage`、`NovaSeparator`（全部为库内已导出公共类型）
- **天花板销号**：✅ 已销号 · 批次 4 · 三态「浅 / 深 / 标签栏收起」
- **台账备注**：多文档编辑器
- **源码**：`Nova/Composite/LayoutShell/NovaTabShell.qml`

## Props

| 属性 | 类型 | 默认值 |
|---|---|---|
| `footerHeight` | `int` | `48` |
| `showFooter` | `bool` | `true` |
| `showTabBar` | `bool` | `true` |
| `tabBarHeight` | `int` | `44` |

## Slots

| 槽位 | 类型 | 说明 |
|---|---|---|
| `contentSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `footerSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `overlaySlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `tabBarSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |

## Events / Signals

| 信号 | 参数 | 语义 |
|---|---|---|
| `tabActivated` | `int index` | 组件只 emit，不自写宿主状态 |
| `tabAddRequested` | — | 组件只 emit，不自写宿主状态 |
| `tabCloseRequested` | `int index` | 组件只 emit，不自写宿主状态 |

## Methods

（该组件无公开方法）

## 最小示例

```qml
import QtQuick
import Nova.Composite.LayoutShell

NovaTabShell {
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
| ![浅色](../screenshots/tab_shell_showcase_light.png) | ![深色](../screenshots/tab_shell_showcase_dark.png) | ![变体](../screenshots/tab_shell_showcase_variant.png) |

## 相关

- [21 项组合根容器总览](index.md)
- [63 张三态装配图索引](showcase.md)
- [CARF-R 21/21 销号台账](../prescript/AUDIT_CEILING.md)
- [组件清单（147 项）](../COMPONENT_LIST.md)
- [API 冻结清单](../API_FREEZE.md)
