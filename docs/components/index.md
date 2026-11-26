# 组合根容器（20 项）

> **Nova.Composite.LayoutShell** · pyside-nova **1.2.0** · **144 个导出类型** · API 冻结指纹 `4f882374ad52262b` · **20/20 六维天花板全部销号**（CARF-R）
> 本页由 `scripts/gen_apidocs.py` 自动生成，**禁止手工编辑**。

20 个组合根容器按语义分为 9 类；每个容器都由 ≥2 个已导出公共类型组合、一律 `property alias` 槽位、只 emit 不自写宿主状态。

## 主导航（4）

| 组件 | 说明 | Props | Slots | Signals | 文档 |
|---|---|---|---|---|---|
| [NovaDualSide](NovaDualSide.md) | 双侧边工作台 | 7 | 5 | 2 | [API 页](NovaDualSide.md) |
| [NovaSidebar](NovaSidebar.md) | 侧边导航工作台 | 9 | 5 | 1 | [API 页](NovaSidebar.md) |
| [NovaTabShell](NovaTabShell.md) | 标签页工作台 | 4 | 4 | 3 | [API 页](NovaTabShell.md) |
| [NovaTopNavigation](NovaTopNavigation.md) | 顶部导航工作台 | 6 | 5 | 1 | [API 页](NovaTopNavigation.md) |

## 多栏工作台（3）

| 组件 | 说明 | Props | Slots | Signals | 文档 |
|---|---|---|---|---|---|
| [NovaCardGrid](NovaCardGrid.md) | 卡片网格壳 | 5 | 4 | 0 | [API 页](NovaCardGrid.md) |
| [NovaCompare](NovaCompare.md) | 双栏对比壳 | 6 | 5 | 1 | [API 页](NovaCompare.md) |
| [NovaThreeColumn](NovaThreeColumn.md) | 三栏工作台 | 7 | 6 | 1 | [API 页](NovaThreeColumn.md) |

## 浮层容器（2）

| 组件 | 说明 | Props | Slots | Signals | 文档 |
|---|---|---|---|---|---|
| [NovaDrawerPanel](NovaDrawerPanel.md) | 侧边滑出面板壳 | 9 | 3 | 1 | [API 页](NovaDrawerPanel.md) |
| [NovaModal](NovaModal.md) | 模态弹窗壳 | 8 | 3 | 1 | [API 页](NovaModal.md) |

## 独立页壳（2）

| 组件 | 说明 | Props | Slots | Signals | 文档 |
|---|---|---|---|---|---|
| [NovaBlankPage](NovaBlankPage.md) | 纯净单页壳 | 5 | 4 | 0 | [API 页](NovaBlankPage.md) |
| [NovaSetupWizard](NovaSetupWizard.md) | 安装配置向导壳 | 9 | 5 | 3 | [API 页](NovaSetupWizard.md) |

## 多端根壳（3）

| 组件 | 说明 | Props | Slots | Signals | 文档 |
|---|---|---|---|---|---|
| [NovaDesktop](NovaDesktop.md) | 桌面应用根壳 | 6 | 5 | 1 | [API 页](NovaDesktop.md) |
| [NovaFlexLayout](NovaFlexLayout.md) | 企业大屏弹性布局壳 | 7 | 4 | 1 | [API 页](NovaFlexLayout.md) |
| [NovaMobile](NovaMobile.md) | 移动应用根壳 | 7 | 4 | 1 | [API 页](NovaMobile.md) |

## AI 对话主窗口（1）

| 组件 | 说明 | Props | Slots | Signals | 文档 |
|---|---|---|---|---|---|
| [NovaChat](NovaChat.md) | 六轨按轨分治主窗口 | 16 | 7 | 3 | [API 页](NovaChat.md) |

## AI 智能组合根（3）

| 组件 | 说明 | Props | Slots | Signals | 文档 |
|---|---|---|---|---|---|
| [NovaAgent](NovaAgent.md) | 智能体任务执行工作台 | 13 | 6 | 3 | [API 页](NovaAgent.md) |
| [NovaCopilot](NovaCopilot.md) | 增强型协作面板 | 11 | 5 | 3 | [API 页](NovaCopilot.md) |
| [NovaDE](NovaDE.md) | 数字员工岗位工作台 | 13 | 6 | 3 | [API 页](NovaDE.md) |

## 意图轨道呈现层（1）

| 组件 | 说明 | Props | Slots | Signals | 文档 |
|---|---|---|---|---|---|
| [NovaOrbit](NovaOrbit.md) | 意图轨道工作台 | 15 | 7 | 3 | [API 页](NovaOrbit.md) |

## 应用孵化器工作台（1）

| 组件 | 说明 | Props | Slots | Signals | 文档 |
|---|---|---|---|---|---|
| [NovaIncubator](NovaIncubator.md) | 应用孵化器工作台 | 15 | 7 | 3 | [API 页](NovaIncubator.md) |

## 契约基线

- **CC-1~CC-8** 组合态一致性契约（组合宪法 1.0.0 第 9 章）
- **NovaTheme** 唯一令牌源 · **NovaMotion** 唯一动效门面（CC-3）
- `property alias` 槽位 + 注入顶层 `anchors.fill: parent`（CC-6）
- `_` 私有成员不进冻结面；公共 API 逐字不变（144 类型）

## 相关

- [60 张三态装配图索引](showcase.md)
- [CARF-R 20/20 销号台账](../prescript/AUDIT_CEILING.md)
- [组件清单（144 项）](../COMPONENT_LIST.md)
- [API 冻结清单](../API_FREEZE.md)
