# NovaSidebar · 侧边导航工作台

> **模块** `Nova.Composite.LayoutShell` · **分类** 主导航 · **pyside-nova 1.2.4** · API 冻结指纹 `4f882374ad52262b` · **20/20 天花板销号** · a11y `decorative`
> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；重跑生成器即可同步。

## 概览

NovaSidebar 侧边导航工作台壳：单色系品牌渐变轨 + 浮起侧栏卡 + 五槽骨架（对标 Quasar QLayout + QDrawer） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5，消除 visible 三元跳变）； 每边界唯一分隔源；primary→secondary 撞色渐变收敛为主色系、装饰改抽象几何（CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 headerSlot/sidebarSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent

- **身份**：品牌渐变轨（4px 恒驻左缘）+ 浮起侧栏卡（圆角 / 阴影 / 内边距）
- **依赖组件**：`NovaTheme`、`NovaHeader`、`NovaFooter`、`NovaPage`、`NovaMotion`（全部为库内已导出公共类型）
- **天花板销号**：✅ 已销号 · 批次 3 · 三态「浅 / 深 / 侧栏折叠」
- **台账备注**：产品控制台；宿主 margins 稳态钳制
- **源码**：`Nova/Composite/LayoutShell/NovaSidebar.qml`

## Props

| 属性 | 类型 | 默认值 |
|---|---|---|
| `bordered` | `bool` | `true` |
| `breakpoint` | `int` | `1024` |
| `footerHeight` | `int` | `48` |
| `headerHeight` | `int` | `56` |
| `belowBreakpoint` *(只读)* | `bool` | `width > 0 && width < root._bp` |
| `showFooter` | `bool` | `true` |
| `showHeader` | `bool` | `true` |
| `sidebarCollapsed` | `bool` | `false` |
| `sidebarSize` | `real` | `260` |

## Slots

| 槽位 | 类型 | 说明 |
|---|---|---|
| `contentSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `footerSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `headerSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `overlaySlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `sidebarSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |

## Events / Signals

| 信号 | 参数 | 语义 |
|---|---|---|
| `sidebarToggled` | `bool collapsed` | 组件只 emit，不自写宿主状态 |

## Methods

| 方法 | 参数 | 语义 |
|---|---|---|
| `toggleSidebar` | — | 命令式调用 |

## 最小示例

```qml
import QtQuick
import Nova.Composite.LayoutShell

NovaSidebar {
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
| ![浅色](../screenshots/sidebar_showcase_light.png) | ![深色](../screenshots/sidebar_showcase_dark.png) | ![变体](../screenshots/sidebar_showcase_variant.png) |

## 相关

- [20 项组合根容器总览](index.md)
- [60 张三态装配图索引](showcase.md)
- [CARF-R 20/20 销号台账](../prescript/AUDIT_CEILING.md)
- [组件清单（144 项）](../COMPONENT_LIST.md)
- [API 冻结清单](../API_FREEZE.md)
