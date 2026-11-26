# NovaMobile · 移动应用根壳

> **模块** `Nova.Composite.LayoutShell` · **分类** 多端根壳 · **pyside-nova 1.2.1** · API 冻结指纹 `4f882374ad52262b` · **20/20 天花板销号** · a11y `decorative`
> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；重跑生成器即可同步。

## 概览

NovaMobile 移动应用根壳：安全区 + 灵动岛 + 内容 + 底部导航 + home indicator（对标 Quasar QLayout mobile），组合态一致性契约（CC）落地 组合态（宪法 0.9.0）：_ 私有组合上下文统一安全区/头/底栏密度与动效；栏高归零 + 恒定锚链（CC-5）； 每边界唯一分隔源；灵动岛与 home indicator 收敛主色系抽象几何（CC-3）；槽位宿主铺满（CC-6）。 用法：向 headerSlot/contentSlot/bottomNavSlot/overlaySlot 注入业务内容；安全区由 safeTop/safeBottom 属性注入

- **身份**：灵动岛（居中胶囊 + 摄像头点）+ home indicator
- **依赖组件**：`NovaTheme`、`NovaHeader`、`NovaPage`、`NovaSeparator`、`NovaPlatform`（全部为库内已导出公共类型）
- **天花板销号**：✅ 已销号 · 批次 2（0.9.1） · 三态「浅 / 深 / 大安全区」
- **台账备注**：灵动岛深色反向修复 + CARF 复评 chrome 高度预算
- **源码**：`Nova/Composite/LayoutShell/NovaMobile.qml`

## Props

| 属性 | 类型 | 默认值 |
|---|---|---|
| `bottomNavHeight` | `int` | `60` |
| `headerHeight` | `int` | `56` |
| `isTouch` | `bool` | `NovaPlatform.isMobile` |
| `safeBottom` | `int` | `0` |
| `safeTop` | `int` | `0` |
| `showBottomNav` | `bool` | `true` |
| `showHeader` | `bool` | `true` |

## Slots

| 槽位 | 类型 | 说明 |
|---|---|---|
| `bottomNavSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `contentSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `headerSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `overlaySlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |

## Events / Signals

| 信号 | 参数 | 语义 |
|---|---|---|
| `backRequested` | — | 组件只 emit，不自写宿主状态 |

## Methods

（该组件无公开方法）

## 最小示例

```qml
import QtQuick
import Nova.Composite.LayoutShell

NovaMobile {
    anchors.fill: parent

    bottomNavSlot: Item {
        anchors.fill: parent
        // 业务内容：注入顶层须铺满（CC-6）
    }
}
```

## 三态装配图

> 真实 Qt Quick 引擎渲染；60 张全量索引见 [装配图索引](showcase.md)

| 浅色 | 深色 | 变体 |
|---|---|---|
| ![浅色](../screenshots/mobile_showcase_light.png) | ![深色](../screenshots/mobile_showcase_dark.png) | ![变体](../screenshots/mobile_showcase_variant.png) |

## 相关

- [20 项组合根容器总览](index.md)
- [60 张三态装配图索引](showcase.md)
- [CARF-R 20/20 销号台账](../prescript/AUDIT_CEILING.md)
- [组件清单（144 项）](../COMPONENT_LIST.md)
- [API 冻结清单](../API_FREEZE.md)
