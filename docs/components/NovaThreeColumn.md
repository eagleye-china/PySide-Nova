# NovaThreeColumn · 三栏工作台

> **模块** `Nova.Composite.LayoutShell` · **分类** 多栏工作台 · **pyside-nova 1.2.1** · API 冻结指纹 `4f882374ad52262b` · **20/20 天花板销号** · a11y `decorative`
> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；重跑生成器即可同步。

## 概览

NovaThreeColumn 三栏工作台壳：目录树 / 中列表 / 详情，三级深度色阶（对标资源管理器布局） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 深色顶条与 primary→secondary 渐变收敛主色系、伪 grip 改抽象短条（CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 treeSlot/listSlot/detailSlot/headerSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent

- **身份**：三级深度色阶（目录 / 列表 / 详情）+ 分隔中部拖拽 grip
- **依赖组件**：`NovaTheme`、`NovaHeader`、`NovaFooter`、`NovaPage`、`NovaSeparator`（全部为库内已导出公共类型）
- **天花板销号**：✅ 已销号 · 批次 4 · 三态「浅 / 深 / 三栏折叠」
- **台账备注**：Nova API Explorer
- **源码**：`Nova/Composite/LayoutShell/NovaThreeColumn.qml`

## Props

| 属性 | 类型 | 默认值 |
|---|---|---|
| `bordered` | `bool` | `true` |
| `detailSize` | `real` | `320` |
| `footerHeight` | `int` | `48` |
| `headerHeight` | `int` | `56` |
| `showFooter` | `bool` | `false` |
| `showHeader` | `bool` | `true` |
| `treeSize` | `real` | `220` |

## Slots

| 槽位 | 类型 | 说明 |
|---|---|---|
| `detailSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `footerSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `headerSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `listSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `overlaySlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |
| `treeSlot` | `alias` | 业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6） |

## Events / Signals

| 信号 | 参数 | 语义 |
|---|---|---|
| `columnResized` | `string column, real size` | 组件只 emit，不自写宿主状态 |

## Methods

（该组件无公开方法）

## 最小示例

```qml
import QtQuick
import Nova.Composite.LayoutShell

NovaThreeColumn {
    anchors.fill: parent

    detailSlot: Item {
        anchors.fill: parent
        // 业务内容：注入顶层须铺满（CC-6）
    }
}
```

## 三态装配图

> 真实 Qt Quick 引擎渲染；60 张全量索引见 [装配图索引](showcase.md)

| 浅色 | 深色 | 变体 |
|---|---|---|
| ![浅色](../screenshots/three_column_showcase_light.png) | ![深色](../screenshots/three_column_showcase_dark.png) | ![变体](../screenshots/three_column_showcase_variant.png) |

## 相关

- [20 项组合根容器总览](index.md)
- [60 张三态装配图索引](showcase.md)
- [CARF-R 20/20 销号台账](../prescript/AUDIT_CEILING.md)
- [组件清单（144 项）](../COMPONENT_LIST.md)
- [API 冻结清单](../API_FREEZE.md)
