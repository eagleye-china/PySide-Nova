# Nova 1.0 API 冻结清单（RC1 签署件）

> **冻结日期**：2026-11-26　**包版本**：`1.2.2`　
> **API 版本**：`1.2.0`　**对标基线**：Quasar 2.35.5
> **内容指纹**：`4f882374ad52262b`　**签署人**：小伙（产品/验收）· 小诺（架构/实现）

## 1. 冻结口径

**公共 API 面 = 五个 `qmldir` 的导出行**。这是本库对外的唯一契约来源：QML 侧
`import Nova.Controls 1.0` / `import Nova.Composite.LayoutShell 1.0` 能拿到的每个类型名，
就是 1.0 承诺稳定的全部内容。

| 进冻结面 | 不进冻结面 |
|---|---|
| 类型名 / 模块归属 / 单例性 | QML 内部 `id`、子项结构、锚点与布局细节 |
| 公共 `property`（含 `readonly`）的名字、类型、只读性 | `_` 开头的私有属性与方法（实现自由） |
| 公共 `signal` 的名字与参数签名 | 默认值与绑定表达式（视觉令牌可调） |
| 公共 `function` 的名字与参数签名 | 文件内部拆分、委托组件命名 |
| a11y 分类（interactive / semantic / decorative） | 内部性能优化与重绘策略 |

机器可校验副本：`api/nova-api-1.2.0.json`（schema `nova-api-freeze/1`）。
其 `types` 里每个公共成员都是 `名字:类型` / `名字(参数)` 的签名串，任何增删改都会让
`scripts/check_api_freeze.py` 变红。

## 2. 冻结统计（144 类型）

| 模块 | 组件 | 单例 | 合计 |
|---|---|---|---|
| Nova.Controls | 91 | 0 | 91 |
| Nova.Behaviors | 12 | 1 | 13 |
| Nova.Services | 4 | 12 | 16 |
| Nova.Design | 0 | 4 | 4 |
| Nova.Composite.LayoutShell | 20 | 0 | 20 |
| **合计** | **127** | **17** | **144** |

a11y 分类：interactive **32** / semantic **28** /
decorative **84**（与 `scripts/check_a11y.py` 同一契约表，双通道一致才放行）。

## 3. 冻结后的变更政策（语义化版本）

| 变更类型 | 例子 | 允许的版本动作 | 门禁行为 |
|---|---|---|---|
| **破坏性** | 删类型 / 改成员类型 / 改信号参数 / 移模块 / 单例↔组件 | 仅 **major**（2.0） | `check_api_freeze.py` 红，须重签清单 |
| **增量** | 新增类型 / 新增公共属性或方法（不改既有签名） | **minor**（1.x） | 红，须升 minor + 重签 |
| **实现** | 私有成员、默认值、内部结构、视觉令牌取值 | **patch**（1.0.x） | 绿，无需重签 |
| **废弃** | `@deprecated` 注释 + 运行时警告，两版本周期后移除 | minor 标注 → major 移除 | 门禁提示，不阻断 |

**废弃 API 的落地方式（QML 无 `@deprecated` 运行时）**：`// DEPRECATED 1.x: 用 xxx 取代，2.0 移除`
写在属性声明上一行，`_warnOnce` 在 `Component.onCompleted` 里经 `NovaUtils.logOnce()` 打一次
console.warn（不污染绑定、不刷屏）。1.0 封版时清单内**无废弃项**。

## 4. 签署

- [x] 导出清单清点完毕（144 类型，五模块）
- [x] 每类型文件存在、文件名与类型名一致、qmldir 版本 `1.0`
- [x] a11y 分类 100% 登记（三分类制，见 `docs/A11Y.md`）
- [x] 无跨模块重名（同名类型必须全库唯一，否则 QML 侧歧义）
- [x] 公共成员签名机器快照入库（本文件同目录 JSON）
- [x] 命名红线扫描通过（无 `on*` 前缀属性 / 无 `color` 撞名 / 无 `palette`·`show`·`hide`）
- [ ] RC2：24 条验收清单（`docs/ECOSYSTEM_PARITY.md` §6）全勾后随 1.0.0 正式生效

**签署结论**：自 2026-11-26 起，上表 144 个类型的公共面视为
**冻结**；后续任何公共面变化都必须走第 3 节流程并重签本文件（指纹 `4f882374ad52262b` → 新指纹）。

## 5. 已知偏差与例外（冻结保留，2.0 再谈）

冻结不等于完美。RC1 逐文件 + qmllint 体检后，以下四项**明确保留**并登记原因——
写下来是为了让后来者知道「这是裁定的结果，不是漏掉的债」：

| 项 | 现状 | 为什么不在此刻动 |
|---|---|---|
| `[unqualified]` 552 条 | 嵌套组件引用外层 `id`（qmllint 建议 `pragma ComponentBehavior: Bound`） | 该 pragma 会收紧委托的上下文捕获语义，124 文件全库改造在封版窗口内风险 > 收益；已入预算（`tests/lint-baseline.json`），只降不升 |
| `a11yLabel` 在 NovaInput / NovaToggle 重复声明 | 基类（NovaField / NovaCheckbox）已有同名同型属性 | 重复声明让「本类型的 a11y 面」在文件内自证，冻结清单不依赖继承推导；语义零差异，保留 |
| `[import]` 单例告警 1 条 | qmllint 对 `NovaMotion` 报「未在 qmldir 声明 singleton」 | 误判：`Nova/Design/qmldir` 第 5 行即 `singleton NovaMotion 1.0`；qmllint 单文件扫描缺模块上下文 |
| 应用包 185.7MB（目标 ≤60MB） | Qt 运行时物理下限 | 与 API 面无关，属打包工程；方向已记录（upx / QML 预编译 / 插件裁剪），RC2 再评估 |

RC2 仍欠的四项（与 API 面解耦，不阻断冻结）：24h 内存长跑、NVDA 真机回归、
安装器与代码签名（需平台证书）、迁移指南 + LTS 承诺书。

## 6. 全类型清单（冻结面明细）

| 类型 | 模块 | 形态 | a11y | props | signals | methods |
|---|---|---|---|---|---|---|
| `NovaClosePopup` | Nova.Behaviors | 组件 | decorative | 7 | 1 | 2 |
| `NovaFocusRing` | Nova.Behaviors | 组件 | decorative | 6 | 0 | 0 |
| `NovaIntersection` | Nova.Behaviors | 组件 | decorative | 11 | 3 | 5 |
| `NovaLiveRegion` | Nova.Behaviors | 组件 | decorative | 2 | 0 | 2 |
| `NovaMorph` | Nova.Behaviors | 组件 | decorative | 7 | 2 | 2 |
| `NovaMorphPool` | Nova.Behaviors | 单例 | decorative | 0 | 0 | 4 |
| `NovaRipple` | Nova.Behaviors | 组件 | decorative | 2 | 0 | 3 |
| `NovaScrollFire` | Nova.Behaviors | 组件 | decorative | 5 | 1 | 1 |
| `NovaScrollObserver` | Nova.Behaviors | 组件 | decorative | 6 | 1 | 2 |
| `NovaTouchHold` | Nova.Behaviors | 组件 | decorative | 8 | 2 | 0 |
| `NovaTouchPan` | Nova.Behaviors | 组件 | decorative | 10 | 1 | 0 |
| `NovaTouchRepeat` | Nova.Behaviors | 组件 | decorative | 7 | 1 | 0 |
| `NovaTouchSwipe` | Nova.Behaviors | 组件 | decorative | 7 | 1 | 0 |
| `NovaAgent` | Nova.Composite.LayoutShell | 组件 | decorative | 19 | 3 | 3 |
| `NovaBlankPage` | Nova.Composite.LayoutShell | 组件 | decorative | 9 | 0 | 0 |
| `NovaCardGrid` | Nova.Composite.LayoutShell | 组件 | decorative | 9 | 0 | 0 |
| `NovaChat` | Nova.Composite.LayoutShell | 组件 | decorative | 23 | 3 | 3 |
| `NovaCompare` | Nova.Composite.LayoutShell | 组件 | decorative | 11 | 1 | 1 |
| `NovaCopilot` | Nova.Composite.LayoutShell | 组件 | decorative | 16 | 3 | 3 |
| `NovaDE` | Nova.Composite.LayoutShell | 组件 | decorative | 19 | 3 | 3 |
| `NovaDesktop` | Nova.Composite.LayoutShell | 组件 | decorative | 11 | 1 | 0 |
| `NovaDrawerPanel` | Nova.Composite.LayoutShell | 组件 | decorative | 12 | 1 | 1 |
| `NovaDualSide` | Nova.Composite.LayoutShell | 组件 | decorative | 12 | 2 | 2 |
| `NovaFlexLayout` | Nova.Composite.LayoutShell | 组件 | decorative | 11 | 1 | 0 |
| `NovaIncubator` | Nova.Composite.LayoutShell | 组件 | decorative | 22 | 3 | 3 |
| `NovaMobile` | Nova.Composite.LayoutShell | 组件 | decorative | 11 | 1 | 0 |
| `NovaModal` | Nova.Composite.LayoutShell | 组件 | decorative | 11 | 1 | 1 |
| `NovaOrbit` | Nova.Composite.LayoutShell | 组件 | decorative | 22 | 3 | 3 |
| `NovaSetupWizard` | Nova.Composite.LayoutShell | 组件 | decorative | 14 | 3 | 0 |
| `NovaSidebar` | Nova.Composite.LayoutShell | 组件 | decorative | 14 | 1 | 1 |
| `NovaTabShell` | Nova.Composite.LayoutShell | 组件 | decorative | 8 | 3 | 0 |
| `NovaThreeColumn` | Nova.Composite.LayoutShell | 组件 | decorative | 13 | 1 | 0 |
| `NovaTopNavigation` | Nova.Composite.LayoutShell | 组件 | decorative | 11 | 1 | 1 |
| `NovaAjaxBar` | Nova.Controls | 组件 | semantic | 8 | 2 | 3 |
| `NovaAvatar` | Nova.Controls | 组件 | semantic | 8 | 0 | 0 |
| `NovaBadge` | Nova.Controls | 组件 | semantic | 8 | 0 | 0 |
| `NovaBanner` | Nova.Controls | 组件 | semantic | 7 | 0 | 0 |
| `NovaBar` | Nova.Controls | 组件 | decorative | 3 | 0 | 0 |
| `NovaBottomSheet` | Nova.Controls | 组件 | interactive | 7 | 8 | 4 |
| `NovaBreadcrumbs` | Nova.Controls | 组件 | semantic | 8 | 0 | 2 |
| `NovaBreadcrumbsEl` | Nova.Controls | 组件 | interactive | 6 | 1 | 1 |
| `NovaBtn` | Nova.Controls | 组件 | interactive | 13 | 3 | 2 |
| `NovaBtnDropdown` | Nova.Controls | 组件 | interactive | 18 | 6 | 5 |
| `NovaBtnGroup` | Nova.Controls | 组件 | semantic | 6 | 0 | 0 |
| `NovaBtnToggle` | Nova.Controls | 组件 | interactive | 28 | 1 | 2 |
| `NovaCard` | Nova.Controls | 组件 | decorative | 4 | 0 | 0 |
| `NovaCardActions` | Nova.Controls | 组件 | decorative | 1 | 0 | 0 |
| `NovaCardSection` | Nova.Controls | 组件 | decorative | 1 | 0 | 0 |
| `NovaCarousel` | Nova.Controls | 组件 | interactive | 27 | 3 | 3 |
| `NovaCarouselControl` | Nova.Controls | 组件 | semantic | 3 | 0 | 0 |
| `NovaCarouselSlide` | Nova.Controls | 组件 | decorative | 3 | 0 | 0 |
| `NovaChatMessage` | Nova.Controls | 组件 | semantic | 15 | 0 | 0 |
| `NovaCheckbox` | Nova.Controls | 组件 | interactive | 29 | 2 | 2 |
| `NovaChip` | Nova.Controls | 组件 | interactive | 11 | 2 | 0 |
| `NovaCol` | Nova.Controls | 组件 | decorative | 3 | 0 | 0 |
| `NovaColorPicker` | Nova.Controls | 组件 | interactive | 15 | 1 | 7 |
| `NovaDate` | Nova.Controls | 组件 | interactive | 33 | 2 | 9 |
| `NovaDialogShell` | Nova.Controls | 组件 | interactive | 17 | 10 | 9 |
| `NovaDrawer` | Nova.Controls | 组件 | decorative | 16 | 0 | 0 |
| `NovaEditor` | Nova.Controls | 组件 | interactive | 10 | 3 | 6 |
| `NovaExpansionItem` | Nova.Controls | 组件 | interactive | 26 | 7 | 4 |
| `NovaFab` | Nova.Controls | 组件 | interactive | 22 | 5 | 4 |
| `NovaFabAction` | Nova.Controls | 组件 | interactive | 11 | 1 | 1 |
| `NovaField` | Nova.Controls | 组件 | semantic | 41 | 2 | 4 |
| `NovaFooter` | Nova.Controls | 组件 | decorative | 2 | 0 | 0 |
| `NovaForm` | Nova.Controls | 组件 | semantic | 5 | 3 | 3 |
| `NovaHeader` | Nova.Controls | 组件 | decorative | 2 | 0 | 0 |
| `NovaIcon` | Nova.Controls | 组件 | semantic | 12 | 0 | 0 |
| `NovaImg` | Nova.Controls | 组件 | semantic | 18 | 2 | 1 |
| `NovaInfiniteScroll` | Nova.Controls | 组件 | decorative | 2 | 1 | 1 |
| `NovaInnerLoading` | Nova.Controls | 组件 | semantic | 7 | 0 | 0 |
| `NovaInput` | Nova.Controls | 组件 | interactive | 10 | 2 | 1 |
| `NovaItem` | Nova.Controls | 组件 | interactive | 14 | 2 | 2 |
| `NovaItemLabel` | Nova.Controls | 组件 | decorative | 4 | 0 | 0 |
| `NovaItemSection` | Nova.Controls | 组件 | decorative | 4 | 0 | 0 |
| `NovaLayout` | Nova.Controls | 组件 | decorative | 8 | 0 | 3 |
| `NovaList` | Nova.Controls | 组件 | semantic | 5 | 0 | 2 |
| `NovaMarkupTable` | Nova.Controls | 组件 | semantic | 6 | 0 | 0 |
| `NovaMenu` | Nova.Controls | 组件 | interactive | 22 | 6 | 7 |
| `NovaNoSsr` | Nova.Controls | 组件 | decorative | 4 | 0 | 0 |
| `NovaOptionGroup` | Nova.Controls | 组件 | semantic | 21 | 1 | 2 |
| `NovaPage` | Nova.Controls | 组件 | decorative | 1 | 0 | 0 |
| `NovaPagination` | Nova.Controls | 组件 | interactive | 13 | 1 | 5 |
| `NovaParallax` | Nova.Controls | 组件 | decorative | 6 | 1 | 1 |
| `NovaPopupEdit` | Nova.Controls | 组件 | interactive | 12 | 6 | 4 |
| `NovaPopupProxy` | Nova.Controls | 组件 | decorative | 17 | 6 | 7 |
| `NovaPullToRefresh` | Nova.Controls | 组件 | semantic | 10 | 1 | 1 |
| `NovaRadio` | Nova.Controls | 组件 | interactive | 18 | 2 | 1 |
| `NovaRange` | Nova.Controls | 组件 | interactive | 42 | 2 | 4 |
| `NovaResizeObserver` | Nova.Controls | 组件 | decorative | 2 | 1 | 3 |
| `NovaResponsive` | Nova.Controls | 组件 | decorative | 1 | 0 | 0 |
| `NovaRow` | Nova.Controls | 组件 | decorative | 4 | 0 | 1 |
| `NovaScrollArea` | Nova.Controls | 组件 | decorative | 0 | 0 | 0 |
| `NovaSelect` | Nova.Controls | 组件 | interactive | 18 | 3 | 3 |
| `NovaSeparator` | Nova.Controls | 组件 | semantic | 5 | 0 | 0 |
| `NovaSkeleton` | Nova.Controls | 组件 | decorative | 4 | 0 | 0 |
| `NovaSlideItem` | Nova.Controls | 组件 | interactive | 8 | 4 | 3 |
| `NovaSlider` | Nova.Controls | 组件 | interactive | 35 | 2 | 3 |
| `NovaSpace` | Nova.Controls | 组件 | decorative | 0 | 0 | 0 |
| `NovaSpinner` | Nova.Controls | 组件 | semantic | 6 | 0 | 0 |
| `NovaStep` | Nova.Controls | 组件 | semantic | 18 | 0 | 0 |
| `NovaStepper` | Nova.Controls | 组件 | semantic | 30 | 3 | 5 |
| `NovaStepperNavigation` | Nova.Controls | 组件 | semantic | 1 | 0 | 0 |
| `NovaTab` | Nova.Controls | 组件 | interactive | 11 | 1 | 2 |
| `NovaTabPanel` | Nova.Controls | 组件 | decorative | 3 | 0 | 0 |
| `NovaTabPanels` | Nova.Controls | 组件 | decorative | 8 | 3 | 3 |
| `NovaTable` | Nova.Controls | 组件 | interactive | 45 | 7 | 13 |
| `NovaTabs` | Nova.Controls | 组件 | interactive | 24 | 1 | 3 |
| `NovaTd` | Nova.Controls | 组件 | decorative | 3 | 0 | 0 |
| `NovaText` | Nova.Controls | 组件 | semantic | 6 | 0 | 0 |
| `NovaTh` | Nova.Controls | 组件 | interactive | 6 | 1 | 0 |
| `NovaTime` | Nova.Controls | 组件 | interactive | 18 | 1 | 11 |
| `NovaTimeline` | Nova.Controls | 组件 | decorative | 3 | 0 | 0 |
| `NovaTimelineEntry` | Nova.Controls | 组件 | semantic | 11 | 0 | 0 |
| `NovaToggle` | Nova.Controls | 组件 | interactive | 3 | 0 | 0 |
| `NovaToolbar` | Nova.Controls | 组件 | semantic | 2 | 0 | 0 |
| `NovaToolbarTitle` | Nova.Controls | 组件 | semantic | 3 | 0 | 0 |
| `NovaTooltip` | Nova.Controls | 组件 | semantic | 13 | 5 | 5 |
| `NovaTr` | Nova.Controls | 组件 | decorative | 2 | 2 | 0 |
| `NovaTransition` | Nova.Controls | 组件 | decorative | 7 | 2 | 0 |
| `NovaTree` | Nova.Controls | 组件 | interactive | 29 | 5 | 11 |
| `NovaVideo` | Nova.Controls | 组件 | semantic | 3 | 0 | 0 |
| `NovaVirtualScroll` | Nova.Controls | 组件 | decorative | 3 | 0 | 1 |
| `NovaVisible` | Nova.Controls | 组件 | decorative | 3 | 0 | 2 |
| `NovaA11y` | Nova.Design | 单例 | decorative | 10 | 0 | 14 |
| `NovaIconSet` | Nova.Design | 单例 | decorative | 23 | 0 | 11 |
| `NovaMotion` | Nova.Design | 单例 | decorative | 20 | 0 | 3 |
| `NovaUtils` | Nova.Design | 单例 | decorative | 6 | 0 | 14 |
| `NovaApp` | Nova.Services | 单例 | decorative | 9 | 0 | 8 |
| `NovaDialog` | Nova.Services | 单例 | decorative | 5 | 0 | 6 |
| `NovaDialogHandle` | Nova.Services | 组件 | decorative | 2 | 3 | 4 |
| `NovaI18n` | Nova.Services | 单例 | decorative | 7 | 0 | 10 |
| `NovaIntersectionPool` | Nova.Services | 单例 | decorative | 3 | 0 | 10 |
| `NovaLoading` | Nova.Services | 单例 | decorative | 10 | 0 | 10 |
| `NovaLoadingBar` | Nova.Services | 单例 | decorative | 0 | 0 | 3 |
| `NovaLoadingHandle` | Nova.Services | 组件 | decorative | 5 | 0 | 2 |
| `NovaNotify` | Nova.Services | 单例 | decorative | 9 | 0 | 12 |
| `NovaNotifyAction` | Nova.Services | 组件 | decorative | 7 | 1 | 0 |
| `NovaNotifyHandle` | Nova.Services | 组件 | decorative | 2 | 0 | 2 |
| `NovaOverlayHost` | Nova.Services | 单例 | decorative | 2 | 0 | 7 |
| `NovaPlatform` | Nova.Services | 单例 | decorative | 14 | 0 | 2 |
| `NovaScreen` | Nova.Services | 单例 | decorative | 18 | 0 | 1 |
| `NovaStorage` | Nova.Services | 单例 | decorative | 4 | 0 | 16 |
| `NovaTheme` | Nova.Services | 单例 | decorative | 65 | 0 | 7 |

---

> 本文件由 `scripts/gen_api_freeze.py` 生成，**勿手改**；签署行随生成时间与指纹自动更新。
> 校验：`python scripts/check_api_freeze.py`（CI 与交付前必跑，红则阻断）。
