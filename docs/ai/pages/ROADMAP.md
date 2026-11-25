# 路线图 — pyside-nova Roadmap

> **进度排期以 [MASTER_PLAN.md](../../MASTER_PLAN.md) 全生态六期总规划为准**；本文件保留 P0/P1/P2 分级视角。

> 对标 Quasar v2 官方组件目录（70+ 组件）与 Qt Quick Controls（Qt 6.8/6.12）官方类型清单
> 逐项比对后的差距清单。QML 已有 40+ 基础控件（Button/CheckBox/ComboBox/Slider/Menu/
> Drawer/SplitView/TableView 等）直接复用，**Quasar 有而 QML 缺失共 68 项**，分 P0/P1/P2。

## 生态层交付顺序（0.4.0 修订，详见 ECOSYSTEM_PARITY.md）

原路线图按"组件清单"排期，现按**生态七层**重排优先级：

1. **L1 布局骨架（M1 Sprint 1）**：NovaLayout / NovaHeader / NovaFooter / NovaDrawer / NovaPage
   + NovaRow / NovaCol / NovaVisible —— 所有页面示例的前提
2. **L4 服务层（M1 Sprint 2）**：NovaNotify / NovaDialog / NovaLoading / NovaStorage / NovaApp / NovaPlatform
3. **L3 行为层（M1 Sprint 3）**：NovaClosePopup / NovaIntersection / NovaTouchPan·Swipe·Hold / NovaScrollObserver
4. **L0/L5 基础层（M1 Sprint 4）**：图标 provider 注册表 + 6 套图标集 + Nova.utils + 动效令牌 + 9 级排版
5. **L2 组件纵深（M2）**：表单体系 → 数据体系 → 反馈体系
6. **L6 非功能与封版（M3）**：a11y / i18n+RTL / 性能基线 / 文档站 / 应用打包器

> 原则：**先骨架、再服务、后组件**。骨架决定示例形态，后改成本极高。

## 里程碑

| 里程碑 | 周期 | 范围 |
|---|---|---|
| M0 基建 ✅ | 3 周 | 工程骨架、令牌引擎、首批 12 组件、画廊、文档集 |
| M1 P0 攻坚 | 8 周 | P0 旗舰组件 22 项 |
| M2 P1 补全 | 5 周 | P1 企业增强 26 项 + 文档站 |
| M3 RC 封版 | 4 周 | `1.0.0-flagship`：API 冻结、WCAG AA 门禁、LTS 24 个月 |

## P0 旗舰必备（22 项，M1）

| 组件 | 对标 | 说明 |
|---|---|---|
| `NovaLayout` | QLayout | header/footer/drawer/page 集成布局（QML 完全没有） |
| `NovaTable` | QTable | TableView 增强：排序/过滤/分页/多选/grid 模式 |
| `NovaField` | QField | 统一字段包装器（标签/提示/错误态/前后置图标） |
| `NovaInput` | QInput | 文本输入（校验、clearable、多行） |
| `NovaForm` | QForm | 规则化校验容器 |
| `NovaSelect` | QSelect | 多选 chip + 搜索过滤 |
| `NovaDate` | QDate | 日历选择器（**Qt 6 无内置日历**，自研） |
| `NovaUploader` | QUploader | 文件上传 |
| `NovaCarousel` | QCarousel | 轮播 |
| `NovaTree` | QTree | 树控件 |
| `NovaStepper` | QStepper | 步骤条 |
| `NovaExpansionItem` | QExpansionItem | 展开项 |
| `NovaBtnDropdown` | QBtnDropdown | 下拉按钮 |
| `NovaNotify` | Notify 插件 | Toast 队列命令式服务 |
| `NovaDialog` | Dialog 插件 | 命令式对话框服务 |
| `NovaBadge.attach` | QBadge | M1 经 PySide6 `QML_ATTACHED` 补齐 attached 语法 |
| `NovaRipple.attach` | v-ripple | 同上 |
| `NovaIntersection` | QIntersection | 可视区观察指令 |
| `NovaSkeleton` | QSkeleton | 骨架屏 |
| `NovaPagination` | QPagination | 分页器 |
| `NovaRating` | QRating | 评分 |
| `NovaKnob` | QKnob | 旋钮 |

> 注：原 P0 清单中的 NovaBadge/NovaRipple/NovaIcon/NovaScreen/NovaCard/NovaChip/NovaAvatar
> 已在 M0 提前交付（0.1.0/0.2.0），上表为剩余项。

## P1 企业增强（26 项，M2）

`NovaFab`、`NovaFabActions`、`NovaColorPicker`、`NovaPullToRefresh`、`NovaBottomSheet`、
`NovaLoading`、`NovaSpinner`、`NovaLinearProgress`、`NovaCircularProgress`、
`NovaToggle`、`NovaRange`、`NovaSlider增强`、`NovaBanner`、`NovaBar`、`NovaBreadcrumbs`、
`NovaTabs`、`NovaTimeline`、`NovaChatMessage`、`NovaEditorToolbar`、`NovaFile`、
`NovaList/QItem 系列`、`NovaMarkupTable`、`NovaNoSsr`、`NovaAjaxBar`、`NovaScrollObserver`、
`NovaWindowResizeObserver`。

## P2 长尾（10 项，M2 后）

`NovaEditor`（WYSIWYG）、`NovaMorph`（形变动画）、`NovaParallax`、`NovaVideo`、
`NovaAudio`、`NovaViewer`（PDF/图片查看）、`NovaSparkline`、`NovaGantt`、
`NovaWaterfall`、`NovaChart` 轻量图表。

## 旗舰版封版门禁（M3）

1. **API 冻结**：qmldir 导出清单 = 冻结公共 API 面；新增走 minor、移除走 major
2. **质量门禁**：qmllint 0 error；P0 覆盖率 ≥90%、全库 ≥85%；明暗双主题视觉回归；
   首帧 ≤800ms；缺文档即构建失败
3. **无障碍**：WCAG 2.1 AA（对比度 ≥4.5:1、焦点遍历、键盘可达）
4. **LTS**：封版后 24 个月；仅 bug 修复 / 72h 安全热修 / 性能优化
5. **废弃流程**：`@deprecated` 标注 + 运行时警告，两版本周期后移除
