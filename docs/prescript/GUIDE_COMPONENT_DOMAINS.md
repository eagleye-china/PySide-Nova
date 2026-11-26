# pyside-nova 基础组件域分类与依赖纪律实用指南

> **文档性质**：本库**现行**实用文档（非史料、非方案稿）· 基础组件域分类 + 依赖纪律的唯一查阅入口
> **适用版本**：**1.2.0** · `api/nova-api-1.2.0.json` · **144 导出类型** · 冻结指纹 **`4f882374ad52262b`**
> **前身**：`NOVA_CLASSIFY.md`（外部建议稿，2026-11-26 更名重写；其「终极物理重构」建议经核**五重冲突、未采纳**，核心内容存档于附录 A）
> **法源链**：母法 [`CONSTITUTION.md`](../CONSTITUTION.md)（卷首 CARF）→ 组合宪法 [`COMPOSITION_CONSTITUTION.md`](../COMPOSITION_CONSTITUTION.md) 1.0.0（第 9 章 CC-1~CC-8）→ [封版规范 v2.1.0](SPEC_FREEZE.md) → [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md)（五模块 / 五层 / 20 组合根九类）→ **本指南（§3 的下钻互补）**
> **机器事实源**：`api/component-domains-1.2.0.json`（**生成物，禁手改**）· 唯一生成器与机检尺 `scripts/audit_domains.py`
> **状态**：**现行 · 2026-11-26 · 待 CSA 随 1.2.0 发布**

---

## 0. 先读这一节：原稿评估结论

前身 `NOVA_CLASSIFY.md` 提出「废弃 `Composite/LayoutShell/`、按五层体系重构**整个** `qml/Nova/`、每个子目录独立 `qmldir`、批量改 `import`」的终极重构方案。经磁盘事实（`qmldir` / 冻结清单 / QML 字面量）与 1.2.0 封版法源逐条核对，结论如下。

### 0.1 终极物理重构**不可落地**：五重冲突

| # | 原稿主张 | 本库事实 | 裁定 |
|---|---|---|---|
| 1 | 拆 `Base/` `Entities/` `Orbit/` `Incubator/` `Prescient/`，各配独立 `qmldir`（如 `module Nova.Controls.Form`） | **仅改模块 URI** 才会改变 144 类型归属，摧毁冻结面 `68b34a408489b6a8`，并破坏已发布 1.0.0 / 1.0.1 的 `import Nova.Composite.LayoutShell 1.0` 兼容 | 属 **additive major + RFC + 全库回扫 + 新法源 + 兼容层** 独立议题，**待 CSA 单独拍板**；本次不做 |
| 2 | 20 个组合根按业务语义分层（智能实体 / 呈现层 / 孵化层 / 基座层） | 1.2.0 封版法源：**20 个组合根一律「无业务语义骨架」**，业务语义全由 `property alias` 槽位注入；按 CC-1「唯一组合上下文」刻意同处**单一模块**以共享 `NovaTheme` / `NovaMotion` 门面与槽位约定 | 与组合宪法冲突；概念分层 ≠ 模块物理层 |
| 3 | 废弃既有 `Composite/LayoutShell/` 目录树重来 | 上一轮已按**既有九类**落地物理子目录分类（[`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §1.1），`qmldir` 以相对子路径导出、公共面零漂移 | 推倒重来违反 CARF「**不推倒重来、不批量扫荡**」 |
| 4 | Step 2「QML 不会自动递归查找子目录，**每个子目录必须有自己的 `qmldir`**」；Step 3「`import "../Controls"` 等相对路径会全部失效」 | **Qt 实测**：`qmldir` 支持 `Foo 1.0 Sub/Foo.qml` 相对子路径导出（`Status.Ready` + 实例化成功）；本库 `test_layout_shells.py` **20/20** 真实实例化通过；全库 **0 处相对导入**（一律 `import Nova.Controls / Services / Design`） | 两条工程前提在本库**已被证伪**；把物理分类错误等同于模块拆分 |
| 5 | 第四部分「CI 冒烟 `pytest tests/test_smoke.py` 100% 绿灯」 | `test_smoke.py -k` 子集触发坑位 49（Qt 6.12 + shiboken 生命周期 SIGSEGV，已依 CSA 指令结案归档）；现行门禁是 `check_all.py --tier static` 3/3 + 专项 53/53 + `audit_ceiling.py` 20/20 | 引用**过时且有坑**的门禁，不可作为封版标准 |

> **一句话**：原稿把「概念域」误当成「模块 URI」，把「目录分类」误当成「模块拆分」。本库 1.2.0 的正确解法是**物理子目录分类 + 单一模块 URI 不变 + 文档层概念域台账**，三者并存。

### 0.2 六处事实误差（已在本指南校正）

| # | 原稿 | 磁盘事实 |
|---|---|---|
| 1 | 「剥离 `Composite/LayoutShell/`（原 **21** 个文件）」 | `qmldir` 实际导出 **20** 项组合根 |
| 2 | `NovaSetupWizard` → `Incubator/` | `NovaSetupWizard` 是 **15 项 GA 组合根**（安装配置向导壳），已归九类 `Page/`；不属孵化层（[`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §0 已校正，原稿重复该误差） |
| 3 | `Hold` / `Pan` / `Avatar` / `Btn` … 简写名 | 冻结清单一律带 `Nova` 前缀：`NovaTouchHold` / `NovaTouchPan` / `NovaAvatar` / `NovaBtn` |
| 4 | 手势域列 `NovaTouchCore` / `Hold` / `Pan` / `Repeat` / `Swipe` 共 5 项 | `NovaTouchCore.qml` **存在但未在 `Behaviors/qmldir` 导出**，是内部 helper、不计入 144；导出的手势类型只有 **4** 个 |
| 5 | Controls 七大域共列 86 个 | 实际 **91**，遗漏 `NovaBar` / `NovaTransition`（基础展示）、`NovaNoSsr` / `NovaResizeObserver` / `NovaResponsive`（响应式辅助）**5 个** |
| 6 | 「`Behaviors` 下不允许存在含 `Rectangle` / `Item` 的渲染体，应被剔除」 | 实测 **13/13 全部含** —— QML 行为组件必须挂载视觉树，这是运行时正常写法；照搬会**误杀全部行为组件** |

> **另校正一处本库既有笔误**：[`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §1 标题与 §0 写「**6** 个 `qmldir` 模块」，冻结清单 `counts.modules` 与 `find` 实为 **5** 个（`Controls` / `Behaviors` / `Services` / `Design` / `Composite/LayoutShell`）；本轮同步修正为 5。

### 0.3 可落地的部分（本指南的落点）

原稿最有价值的是**「Controls 按七大域 + Behaviors 按三大域」的分类视角**与**「单向依赖 / 零重叠」纪律**。本指南把它们落为**文档层增量**：

1. **104 个基础类型（91 + 13）零遗漏归入十域**（§2 / §3），补齐原稿遗漏 5 项，作为 [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §3「5 个架构域汇总」的**下钻**；
2. **机器可校验台账** `api/component-domains-1.2.0.json` + 机检尺 `scripts/audit_domains.py`（144 零遗漏 / 零重复 / 零幽灵 / 模块归属一致 / 单向依赖 0 破口）；
3. **依赖纪律**落为**守护规则**而非改造项（§5）——本库已天然成立，机检只负责不让它退化；
4. **原稿终极重构建议存档附录 A**，标注「未采纳 / 待 CSA 拍板」，不圆场成已落地。

> **零改动承诺**：本指南与台账**不改任何 QML 物理文件、不改 `qmldir`、不改模块 URI、不改冻结面指纹**。分类只存在于文档 / 台账层。

---

## 1. 铁律：概念域 ≠ 物理层 ≠ 模块 URI

| 层 | 本库的唯一事实 | 谁能改 |
|---|---|---|
| **模块 URI**（编译单元） | 5 个 `qmldir` 模块：`Nova.Controls` 91 · `Nova.Behaviors` 13 · `Nova.Services` 16 · `Nova.Design` 4 · `Nova.Composite.LayoutShell` 20 | 仅 additive major + RFC，须 CSA 拍板 |
| **物理子目录**（文件归档） | 20 个组合根按九类归入 `Navigation/` … `Incubator/`；`qmldir` 相对子路径导出 | 1.2.0 已封版 |
| **概念域**（本指南） | Controls 七域 / Behaviors 三域 / 组合根九类 / 服务与门面 / 设计令牌 | 随分类口径演进，走文档 + 生成器 |

**三者允许一对多 / 多对一，不得用目录树强制映射概念域。** 概念域的价值是「查得快、讲得清、守得住」，不是重新编译。

---

## 2. Controls 91 · 七大控件域台账

> 事实源：`api/component-domains-1.2.0.json` 的 `controlDomains`（由 `scripts/audit_domains.py` 生成并机检）。
> 权威成员签名见 [`COMPONENT_LIST.md`](../COMPONENT_LIST.md) 与 [`API_FREEZE.md`](../API_FREEZE.md)（生成器产物，禁手改）。

| 域（中文） | 域（英文） | 数量 | 管什么 | 代表类型 |
|---|---|---:|---|---|
| 基础展示 | `Foundation` | **12** | 无交互的原子展示件 | `NovaText` · `NovaIcon` · `NovaAvatar` · `NovaBadge` · `NovaSeparator` · `NovaSkeleton` · `NovaBar` · `NovaTransition` |
| 表单输入 | `Form` | **15** | 取值与编辑 | `NovaField` · `NovaInput` · `NovaSelect` · `NovaCheckbox` · `NovaDate` · `NovaColorPicker` · `NovaEditor` |
| 操作交互 | `Action` | **7** | 触发动作 | `NovaBtn` · `NovaBtnGroup` · `NovaFab` · `NovaPullToRefresh` · `NovaPopupEdit` |
| 导航路由 | `Navigation` | **15** | 视图切换与层级 | `NovaTabs` · `NovaMenu` · `NovaToolbar` · `NovaBreadcrumbs` · `NovaStepper` · `NovaHeader` · `NovaFooter` |
| 布局容器 | `Layout` | **14** | 排布与滚动 | `NovaLayout` · `NovaRow` · `NovaCol` · `NovaCard` · `NovaDrawer` · `NovaScrollArea` · `NovaVirtualScroll` |
| 数据展示 | `Data` | **18** | 集合与记录 | `NovaTable` · `NovaList` · `NovaTree` · `NovaTimeline` · `NovaCarousel` · `NovaVideo` · `NovaParallax` |
| 智能交互 / 响应式辅助 | `Intelligent` | **10** | 上下文感知与辅助 | `NovaChatMessage` · `NovaTooltip` · `NovaBanner` · `NovaAjaxBar` · `NovaPopupProxy` · `NovaNoSsr` · `NovaResizeObserver` · `NovaResponsive` |

### 2.1 七域全量清单（逐项可查）

| 域 | 类型（全量） |
|---|---|
| `Foundation` (12) | `NovaAvatar` · `NovaBadge` · `NovaChip` · `NovaIcon` · `NovaImg` · `NovaSeparator` · `NovaSkeleton` · `NovaSpace` · `NovaSpinner` · `NovaText` · `NovaBar` · `NovaTransition` |
| `Form` (15) | `NovaForm` · `NovaField` · `NovaInput` · `NovaSelect` · `NovaOptionGroup` · `NovaCheckbox` · `NovaRadio` · `NovaToggle` · `NovaBtnToggle` · `NovaSlider` · `NovaRange` · `NovaDate` · `NovaTime` · `NovaColorPicker` · `NovaEditor` |
| `Action` (7) | `NovaBtn` · `NovaBtnGroup` · `NovaBtnDropdown` · `NovaFab` · `NovaFabAction` · `NovaPullToRefresh` · `NovaPopupEdit` |
| `Navigation` (15) | `NovaTabs` · `NovaTab` · `NovaTabPanel` · `NovaTabPanels` · `NovaBreadcrumbs` · `NovaBreadcrumbsEl` · `NovaPagination` · `NovaStepper` · `NovaStep` · `NovaStepperNavigation` · `NovaMenu` · `NovaToolbar` · `NovaToolbarTitle` · `NovaHeader` · `NovaFooter` |
| `Layout` (14) | `NovaLayout` · `NovaPage` · `NovaRow` · `NovaCol` · `NovaCard` · `NovaCardActions` · `NovaCardSection` · `NovaExpansionItem` · `NovaDrawer` · `NovaBottomSheet` · `NovaDialogShell` · `NovaScrollArea` · `NovaVirtualScroll` · `NovaInfiniteScroll` |
| `Data` (18) | `NovaTable` · `NovaMarkupTable` · `NovaTr` · `NovaTd` · `NovaTh` · `NovaList` · `NovaItem` · `NovaItemLabel` · `NovaItemSection` · `NovaTree` · `NovaTimeline` · `NovaTimelineEntry` · `NovaCarousel` · `NovaCarouselControl` · `NovaCarouselSlide` · `NovaSlideItem` · `NovaVideo` · `NovaParallax` |
| `Intelligent` (10) | `NovaChatMessage` · `NovaTooltip` · `NovaInnerLoading` · `NovaBanner` · `NovaAjaxBar` · `NovaPopupProxy` · `NovaVisible` · `NovaNoSsr` · `NovaResizeObserver` · `NovaResponsive` |

> **补齐说明**：原稿遗漏的 5 项已归位 —— `NovaBar` / `NovaTransition` → `Foundation`；`NovaNoSsr` / `NovaResizeObserver` / `NovaResponsive` → `Intelligent`（Quasar 系响应式辅助件，非视觉控件、非行为扩展，故不归 `Behaviors`）。

---

## 3. Behaviors 13 · 三大行为域台账

> **重要**：13/13 个行为组件都以 `Item` / `Rectangle` 为 QML 根对象 —— **这是 QML 行为组件挂载视觉树的正常写法**。原稿「零重叠原则要求剔除渲染体」在本库不成立，本指南不采纳该条，仅保留其「分类清晰」意图。

| 域（中文） | 域（英文） | 数量 | 管什么 | 类型（全量） |
|---|---|---:|---|---|
| 手势 | `Gestures` | **4** | 触摸与指针手势 | `NovaTouchHold` · `NovaTouchPan` · `NovaTouchRepeat` · `NovaTouchSwipe` |
| 监听观察 | `Observers` | **3** | 可见性 / 滚动事件 | `NovaIntersection` · `NovaScrollFire` · `NovaScrollObserver` |
| 特效与 a11y 行为 | `Effects` | **6** | 动效、焦点、播报 | `NovaClosePopup` · `NovaFocusRing` · `NovaLiveRegion` · `NovaMorph` · `NovaMorphPool` · `NovaRipple` |

**内部 helper（不计入 144）**：`Behaviors/NovaTouchCore.qml` 存在但未在 `Behaviors/qmldir` 导出，是手势域的共享实现，不出现在冻结清单与域台账的类型表中；台账以 `internalHelpers` 单独登记，避免被误判为「遗漏类型」。

---

## 4. 其余 40 类型的归属

| 架构域 | 数量 | 归域口径 | 查阅入口 |
|---|---:|---|---|
| `Nova.Services` 服务与门面 | **16** | **不归十域**（服务层，`NovaTheme` / `NovaMotion` / `NovaI18n` / Bridge 等） | [`COMPONENT_LIST.md`](../COMPONENT_LIST.md) |
| `Nova.Design` 设计令牌 | **4** | **不归十域**（`NovaA11y` / `NovaIconSet` / `NovaMotion` / `NovaUtils`） | 同上 |
| `Nova.Composite.LayoutShell` 组合根 | **20** | 归**九类**（物理子目录 + 槽位契约），不归十域 | [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §4 · [`components/index.md`](../components/index.md) |

> 组合根是唯一「由 ≥2 个已导出公共类型组合而成」的架构域，套 **CC-1~CC-8**；基础控件 / 行为 / 服务 / 令牌**不套 CC 契约**（组合宪法第 0 章第 3/4 条），其 15/15 Robustness 台账见 [`CEILING_AUDIT_FOUNDATIONS.md`](../CEILING_AUDIT_FOUNDATIONS.md)。

---

## 5. 依赖纪律（可机检的三条守护）

原稿「单向依赖 / 零重叠 / 基座统御」三条中，只有**单向依赖**在本库成立且可守护；其余两条与运行时机制或 CC-1 冲突，不落为规则。

| # | 守护规则 | 本库实测 | 机检实现 |
|---|---|---|---|
| 1 | **基础层不依赖上层**：`Controls/` `Behaviors/` 不得 `import Nova.Composite.*` / `Nova.Entities` / `Nova.Orbit` / `Nova.Incubator` / `Nova.Base` / `Nova.Prescient` | **0 处**（天然成立） | `audit_domains.py` 正则扫描，命中即 FAIL |
| 2 | **绝对模块导入**：QML 不得出现 `import ".."` / `import "."` 相对导入 | **0 处**（全库扫描） | 同上；保证物理子目录分类与后续移动安全 |
| 3 | **域分类不漂移**：台账 144 类型零遗漏 / 零重复 / 零幽灵，且每个类型的 `module` 与冻结清单逐项一致 | 机检 PASS | 以 `api/nova-api-1.2.0.json` 为唯一比对源 |

**运行方式**（只读校验，不改任何文件）：

```bash
python scripts/audit_domains.py            # 机检，输出 PASS / FAIL
python scripts/audit_domains.py --emit     # 机检通过后重新生成台账 JSON
```

> 该机检是 [`AUDIT_CEILING.md`](AUDIT_CEILING.md) 天花板销号体系外的**文档层守护**，不改动 20/20 组合根与 15/15 基础组件的任何验收口径；它只保证「分类账实相符」。

---

## 6. 怎样查 / 怎样维护（实用）

**按意图找组件**：先判「是不是组合根」→ 是则去 [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §4 九类速查；否则按 §2 七域 / §3 三域定位，再进 [`COMPONENT_LIST.md`](../COMPONENT_LIST.md) 查完整签名。三态装配图索引见 [`components/showcase.md`](../components/showcase.md)。

**维护纪律**：

1. `api/component-domains-1.2.0.json` 是**生成物，禁手改**；域映射只改 `scripts/audit_domains.py` 的 `CONTROL_DOMAINS` / `BEHAVIOR_DOMAINS` / `COMPOSITE_GROUPS`，然后 `--emit` 重生成。
2. 新增公共导出类型（additive minor）时，须**同步**在生成器登记域归属，否则机检「零遗漏」立刻 FAIL —— 这是分类不腐化的硬闸门。
3. 冻结面升级（`nova-api-1.2.0.json` → 后续版本）时，同步更新生成器的 `API` 路径与台账 `apiVersion`；本指南头部口径一并校准。
4. 概念域**永不**触发 `qmldir` 改写；若未来真要拆独立模块 URI，须走 additive major + RFC + 全库回扫 + 新法源 + 兼容层，由 CSA 单独拍板。

---

## 7. 封版声明

本指南按 **CARF — Conceive, Achieve, Refine, Freeze — Culminate to the peak** 落地：

- **C 构想**：CSA 交办「精读 `NOVA_CLASSIFY.md`、认真评估、针对本库实际、若可落地则更名优化并落地分类」；
- **A 实现**：更名 `NOVA_CLASSIFY.md` → `COMPONENT_DOMAINS.md`，重写为现行实用文档；新增机器台账 + 机检尺；104 基础类型零遗漏归十域；
- **R 打磨**：六处事实误差逐条校正（含本库既有「6 → 5 模块」笔误）、原稿五重冲突逐条给证、Behaviors 渲染体误杀风险显式排除；
- **F 封版**：**零 QML 物理改动 · 零 `qmldir` 改动 · 零模块 URI 改动 · 冻结指纹 `68b34a408489b6a8` 不变**；文档站 nav / CHANGELOG / 台账 / 日志闭环，发布边界归 CSA。

> **发布边界**：本轮全部改动留工作树未提交，`commit / push / tag / PyPI / 站点上线` **全归 CSA**。

---

## 附录 A · 原稿终极重构建议存档（**未采纳**）

> 前身 `NOVA_CLASSIFY.md`（141 行，2026-11-26 到达）核心主张存档于此，**标注未采纳、不圆场成已落地**；完整原文见当日工作区日志与 git 历史。评估结论见 §0.1 / §0.2。

**A.1 目标目录树（未采纳）**：废弃 `Composite/LayoutShell/`，改 `Base/`（仅 `NovaChat`）、`Entities/`（三 AI 组合根）、`Orbit/`、`Incubator/`、`Prescient/{Carriers,Navigation,Structures}/`；`Behaviors/` 拆 `Effects/Gestures/Observers/`；`Controls/` 拆 `Action/Data/Form/Foundation/Intelligent/Layout/Navigation/`；`Design/`、`Services/` 不变。

**A.2 四步走（未采纳）**：① `git mv` 批量搬迁；② **每个子目录新建独立 `qmldir`**（`module Nova.Controls.Form` 等）并改 `import` 为 `import Nova.Controls.Form 1.0`；③ 批量修正相对导入；④ 适配 `gen_component_list.py` / `check_qmllint.py` / `runtime.py` / `gen_apidocs.py`，废弃旧 JSON 命名。

**A.3 封版标准（部分未采纳）**：① 零重叠（不允许 `Composite` 文件夹、**不允许 Behaviors 含渲染体**）→ 与 CC-1 / QML 运行时冲突，未采纳；② 单向依赖（底层不依赖上层）→ **采纳为机检守护**（§5 规则 1）；③ 基座统御（`NovaChat` 可被上层引用）→ 与「组合根之间无相互 import」的磁盘事实不符，未采纳；④ `pytest tests/test_smoke.py` 冒烟 → 坑位 49 已归档、门禁口径过时，未采纳。

**A.4 唯一仍开放议题**：把子目录**升格为独立 `qmldir` 模块**会改变 144 类型模块归属，属 additive major + RFC + 全库回扫 + 新法源 + 兼容层，**待 CSA 单独拍板**；与 [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §6 的裁定一致，两处不重复立项。
