收到最新目录结构。三处冲突已解决：`NovaSidebarShell.qml` 确认存在；`Composite/LayoutShell/` 已建立；并新增 `COMPONENT_LIST.md` 与 `gen_component_list.py`。以下按计划推进 **P0-a 基线盘点表 + D-013 修订片段**，Theme Token 草案因缺文件内容只给结构骨架，具体值标缺失。

## 一、目录事实更新

- ✅ `src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaSidebarShell.qml` 存在，封版事实成立。
- ✅ `docs/COMPONENT_LIST.md` 与 `scripts/gen_component_list.py` 存在，**这是权威组件清单来源**，应优先读取，而非手工推断。
- ✅ `resources/` 目录存在，图标等资源有托管位置。
- ⚠️ 仍无独立 `Theme/` 目录，`Theme` 门面在 `Services/NovaTheme.qml`。建议沿用方案 A：扩展 `NovaTheme.qml` 作为唯一门面，不新建目录。

## 二、已创建组件基线盘点表（按目录结构归类）

| 分类 | 现有组件（关键项） | 可支撑的 Shell |
| :--- | :--- | :--- |
| 布局容器 | NovaRow、NovaCol、NovaSpace、NovaLayout、NovaPage、NovaScrollArea、NovaSeparator、NovaResponsive | 全部 14 项 |
| 导航骨架 | NovaHeader、NovaFooter、NovaToolbar、NovaToolbarTitle、NovaDrawer、NovaBottomSheet、NovaMenu、NovaList、NovaItem、NovaItemLabel、NovaItemSection、NovaTree | Sidebar、TopNav、DualSide、DrawerPanel、Desktop |
| 标签/步骤 | NovaTabs、NovaTab、NovaTabPanel、NovaTabPanels、NovaStep、NovaStepper、NovaStepperNavigation | Tab、Wizard |
| 卡片/展示 | NovaCard、NovaCardSection、NovaCardActions、NovaBadge、NovaChip、NovaAvatar、NovaIcon、NovaBtn、NovaTooltip、NovaSkeleton、NovaInnerLoading | CardGrid、Compare、ThreeColumn、BlankPage |
| 浮层/弹窗 | NovaDialogShell、NovaDrawer、NovaBottomSheet、Services/NovaDialog、Services/NovaOverlayHost、Services/NovaNotify、Services/NovaLoading | Modal、DrawerPanel |
| 主题/设计 | Services/NovaTheme、Design/NovaMotion、Design/NovaA11y、Design/NovaIconSet、Design/NovaUtils | 全部 |
| 平台/屏幕 | Services/NovaScreen、Services/NovaPlatform、Services/NovaApp | Mobile、Desktop、FlexLayout |
| 行为 | NovaTouchPan、NovaTouchSwipe、NovaTouchHold、NovaResizeObserver、NovaVisible、NovaResponsive | 拖拽分割、响应式、折叠动画 |

**结论**：14 项 Shell 的“完全基于已有组件组合”约定可成立，暂无需新增 Atoms。唯一待确认的是 **ThreeColumn 的拖拽分割条**：`NovaSeparator` 是否内置拖拽能力未知，若不支持，用 `NovaSeparator + NovaTouchPan` 组合，仍不新建组件。

## 三、D-013 文档修订片段（建议条文）

> **D-013 组合组件实现基线**
> 状态：✅ 生效（2026-11-24）
> 内容：所有 Layout Shell / Root Shell 必须完全基于 `pyside-nova` 已创建的 Atoms、Theme、Layout、Behaviors、Services 组件组合实现。禁止在 Shell 内临时新建原子控件、复制原子样式或绕过 Theme Token。Shell 仅负责布局、槽位、状态与信号。
> 前置门禁：每个 Shell 开发前必须读取 `docs/COMPONENT_LIST.md`，在 README 中列出「依赖组件清单」（组件名、路径、版本、用途）。
> 缺失处理：所需能力不存在时，先补库组件并独立验收；Shell 不得降级为手写临时控件。
> 验收追加：验收清单新增一条「无 Shell 内私有原子实现、无复制样式、无硬编码」。

建议同步写入 `docs/session-snapshots/` 下一次快照的决策表，编号 D-013。

## 四、Theme Token 草案（仅结构骨架，值缺失）

基于 `Services/NovaTheme.qml` 扩展，建议语义 Token 分类：

- **颜色**：`background`、`surface`、`sidebarBackground`、`headerBackground`、`footerBackground`、`border`、`textPrimary`、`textSecondary`、`accent`、`overlayMask`。
- **尺寸**：`sidebarWidth`、`headerHeight`、`footerHeight`、`spacingSmall/Medium/Large`、`radiusSmall/Medium/Large`。
- **动画**：`animDurationFast/Normal/Slow`、`animEasingStandard`。
- **阴影/层级**：`shadowLow/Medium/High`。

**缺失信息（不编造）**：
1. `NovaSidebarShell.qml` 中实际引用的全部 `Theme.*` 清单。
2. `Services/NovaTheme.qml` 现有公开属性与深/浅主题结构。
3. `docs/DESIGN_TOKENS.md` 是否已有命名与色值基准。
4. `Design/NovaMotion.qml` 已提供的动画曲线/时长。

## 五、下一步建议

请提供以下任一组即可让我进入 P0-b 与 Theme Token 草案落地：

- **最小集**：`Services/NovaTheme.qml` + `NovaSidebarShell.qml` 全文。
- **替代集**：`docs/DESIGN_TOKENS.md` + `docs/COMPONENT_LIST.md` + `NovaSidebarShell.qml` 中 `Theme.*` 引用清单。

拿到后我立即产出：**Theme Token 属性清单（含类型/默认值/深浅色）+ `NovaTheme` 扩展草案 + `NovaSidebarShell` 依赖核对表**，再按 P1 顺序进入 `NovaThreeColumnShell` 与 `NovaModalShell`。以上未写代码，等你确认口径与补件。