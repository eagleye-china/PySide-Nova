# Parity 全生态广度台账（P2 · 先列出，未完现）

<!-- breadth-signature: 943ef27d61f6919e8def1f02a13b5cf921084c169f9f17cc5b9782b732ee8384 -->

> **生成物 · 禁手改**：由 `scripts/gen_parity_breadth.py` 写出；`check_parity_ops.py` 用此签名做机读台账 / 视图 / 矩阵三方一致校验。
> **上游事实源**：npm `quasar@2.35.5` `dist/api/*.json`（`upstream/manifest-2.35.5.json`，156 条脚本计数）；**Nova 事实源**：`nova-api-1.11.0.json`（147 类型）。
> **关系口径**：Inspired by Quasar (MIT) · 只用公开 API 元数据 · 不复制源码、不构成 fork / port。
> **诚实边界**：`dist/api/*.json` 只覆盖 **L1~L4** 的 API 面。**L0 设计语言 / L5 工具层 / L6 工程化**是面外未纳入层（见 §5），绝不把 156 条当作「全生态」——T30 的 L5 漏复核正是这一边界的可复现证据。

## 1. 广度总览（脚本计数，非估算）

| 指标 | 值 |
|---|---|
| 上游条目（dist/api 面内） | **156** |
| 逐项展开成员项 | **1932** |
| 未逐项展开（组件级缺口） | **400** |
| 逐项五态 | `ALIGNED` 45 · `GAP` 862 · `MAPPED` 808 · `N/A` 217 |
| 成员级 GAP | **862** |
| 组件级缺口条目（NO_NOVA_COUNTERPART） | **53** |
| 层级归属零悬空率 | **100.00%** |
| 兜底规则命中（如实登记，不算精确分类） | **0** |

### 1.1 七层覆盖现状（L0~L6）

| 层 | 名称 | dist/api 面内 | 条目 | 逐项 | GAP | 组件级缺口 | 口径 |
|---|---|---|---|---|---|---|---|
| **L0** | 设计语言 | **否（面外）** | 0 | 0 | 0 | 0 | 面外 · dist/api 不含此层，见 out_of_scope_facets（不虚高） |
| **L1** | 布局系统 | 是 | 13 | 66 | 42 | 4 | 面内 · 由 dist/api 条目逐条归属 |
| **L2** | 组件 | 是 | 110 | 1799 | 796 | 33 | 面内 · 由 dist/api 条目逐条归属 |
| **L3** | 指令 | 是 | 13 | 9 | 0 | 4 | 面内 · 由 dist/api 条目逐条归属 |
| **L4** | 插件（服务） | 是 | 20 | 58 | 24 | 12 | 面内 · 由 dist/api 条目逐条归属 |
| **L5** | 工具层 | **否（面外）** | 0 | 0 | 0 | 0 | 面外 · dist/api 不含此层，见 out_of_scope_facets（不虚高） |
| **L6** | 工程化 | **否（面外）** | 0 | 0 | 0 | 0 | 面外 · dist/api 不含此层，见 out_of_scope_facets（不虚高） |

> 面内层条目合计 = 156（与 manifest 一致）；面外层的 `0` 表示「dist/api 不含此层」，**不是「已覆盖」也不是「零缺口」**。

### 1.2 三层口径（与 `docs/PARITY_MATRIX.md` 同源；面外不算分子）

| 档 | 全量面 | 定义 |
|---|---|---|
| 字面 literal | **2.62%** | ALIGNED / 适用项 |
| 可解释 explainable | **55.38%** | (ALIGNED+MAPPED+N/A) / 全量项，GAP 不计入 |
| 机检固化 test_frozen | **2.62%** | 带真实 PASS `test_id` 的 ALIGNED / 适用项，**独立计** |

> **验收红线（2026-11-28 12:35 CSA 采纳 A 类）**：三层并列呈现，禁止只报可解释率；**GAP = 保守下界**，提升只能靠**补登记 + 补机检**，不许改判五态放宽口径；机检固化独立计，MAPPED / N/A 无用例不计入；L0/L5/L6 面外层**不算覆盖率分子**。详见 `proposals/SPEC_COMPONENT_PARITY_MEASURES.md` §2 / §3。

## 2. 逐层逐条台账（156 条，脚本计数）

| 上游 | 类型 | 功能族 | Nova 对应 | 状态 | 逐项 | GAP | 优先级 | 批次 |
|---|---|---|---|---|---|---|---|---|

### 2.1 L1 · 布局系统（13 条）

| 上游 | 类型 | 功能族 | Nova 对应 | 状态 | 逐项 | GAP | 优先级 | 批次 |
|---|---|---|---|---|---|---|---|---|
| `QBar.json` | component | 布局容器 | `Nova.Controls.NovaBar` | `MAPPED` | 3 | 0 | — | **B0** |
| `QDrawer.json` | component | 布局骨架 | `Nova.Controls.NovaDrawer` | `MAPPED` | 35 | 25 | P2 | **B2** |
| `QFooter.json` | component | 布局骨架 | `Nova.Controls.NovaFooter` | `MAPPED` | 7 | 5 | P2 | **B2** |
| `QHeader.json` | component | 布局骨架 | `Nova.Controls.NovaHeader` | `MAPPED` | 8 | 6 | P2 | **B2** |
| `QLayout.json` | component | 布局骨架 | `Nova.Controls.NovaLayout` | `GAP` | 6 | 5 | P2 | **B2** |
| `QPage.json` | component | 布局骨架 | `Nova.Controls.NovaPage` | `MAPPED` | 3 | 1 | P2 | **B2** |
| `QPageContainer.json` | component | 布局骨架 | **无对应类型** | `GAP` | 未展开 1 | 0 | P2 | **B3** |
| `QPageScroller.json` | component | 布局骨架 | **无对应类型** | `GAP` | 未展开 7 | 0 | P2 | **B3** |
| `QPageSticky.json` | component | 布局骨架 | **无对应类型** | `GAP` | 未展开 4 | 0 | P2 | **B3** |
| `QSpace.json` | component | 布局骨架 | `Nova.Controls.NovaSpace` | `GAP` | 未展开 0 | 0 | — | **B0** |
| `QSplitter.json` | component | 布局骨架 | **无对应类型** | `GAP` | 未展开 18 | 0 | P2 | **B3** |
| `QToolbar.json` | component | 布局容器 | `Nova.Controls.NovaToolbar` | `MAPPED` | 2 | 0 | — | **B0** |
| `QToolbarTitle.json` | component | 布局容器 | `Nova.Controls.NovaToolbarTitle` | `MAPPED` | 2 | 0 | — | **B0** |

### 2.2 L2 · 组件（110 条）

| 上游 | 类型 | 功能族 | Nova 对应 | 状态 | 逐项 | GAP | 优先级 | 批次 |
|---|---|---|---|---|---|---|---|---|
| `QAjaxBar.json` | component | 反馈进度 | `Nova.Controls.NovaAjaxBar` | `MAPPED` | 11 | 4 | P2 | **B2** |
| `QAvatar.json` | component | 反馈进度 | `Nova.Controls.NovaAvatar` | `MAPPED` | 8 | 2 | P2 | **B2** |
| `QBadge.json` | component | 反馈进度 | `Nova.Controls.NovaBadge` | `MAPPED` | 10 | 6 | P2 | **B2** |
| `QBanner.json` | component | 反馈进度 | `Nova.Controls.NovaBanner` | `MAPPED` | 7 | 0 | — | **B0** |
| `QBreadcrumbs.json` | component | 导航 | `Nova.Controls.NovaBreadcrumbs` | `MAPPED` | 7 | 1 | P2 | **B2** |
| `QBreadcrumbsEl.json` | component | 导航 | `Nova.Controls.NovaBreadcrumbsEl` | `MAPPED` | 13 | 3 | P2 | **B2** |
| `QBtn.json` | component | 按钮操作 | `Nova.Controls.NovaBtn` | `MAPPED` | 38 | 23 | P1 | **B1** |
| `QBtnDropdown.json` | component | 按钮操作 | `Nova.Controls.NovaBtnDropdown` | `MAPPED` | 70 | 38 | P2 | **B2** |
| `QBtnGroup.json` | component | 按钮操作 | `Nova.Controls.NovaBtnGroup` | `MAPPED` | 11 | 5 | P2 | **B2** |
| `QBtnToggle.json` | component | 按钮操作 | `Nova.Controls.NovaBtnToggle` | `MAPPED` | 31 | 11 | P2 | **B2** |
| `QCard.json` | component | 容器列表 | `Nova.Controls.NovaCard` | `MAPPED` | 6 | 2 | P2 | **B2** |
| `QCardActions.json` | component | 容器列表 | `Nova.Controls.NovaCardActions` | `MAPPED` | 3 | 1 | P2 | **B2** |
| `QCardSection.json` | component | 容器列表 | `Nova.Controls.NovaCardSection` | `GAP` | 3 | 2 | P2 | **B2** |
| `QCarousel.json` | component | 媒体轮播 | `Nova.Controls.NovaCarousel` | `MAPPED` | 43 | 17 | P1 | **B1** |
| `QCarouselControl.json` | component | 媒体轮播 | `Nova.Controls.NovaCarouselControl` | `MAPPED` | 3 | 0 | — | **B0** |
| `QCarouselSlide.json` | component | 媒体轮播 | `Nova.Controls.NovaCarouselSlide` | `MAPPED` | 4 | 0 | — | **B0** |
| `QChatMessage.json` | component | 容器列表 | `Nova.Controls.NovaChatMessage` | `MAPPED` | 18 | 0 | — | **B0** |
| `QCheckbox.json` | component | 表单输入 | `Nova.Controls.NovaCheckbox` | `MAPPED` | 23 | 3 | P2 | **B2** |
| `QChip.json` | component | 表单输入 | `Nova.Controls.NovaChip` | `MAPPED` | 25 | 14 | P2 | **B2** |
| `QCircularProgress.json` | component | 反馈进度 | **无对应类型** | `GAP` | 未展开 17 | 0 | P2 | **B3** |
| `QColor.json` | component | 表单输入 | **无对应类型** | `GAP` | 未展开 18 | 0 | P2 | **B3** |
| `QDate.json` | component | 表单输入 | `Nova.Controls.NovaDate` | `MAPPED` | 41 | 22 | P2 | **B2** |
| `QDialog.json` | component | 弹层浮层 | `Nova.Controls.NovaDialogShell` | `MAPPED` | 33 | 12 | P2 | **B2** |
| `QEditor.json` | component | 表单输入 | `Nova.Controls.NovaEditor` | `MAPPED` | 46 | 34 | P2 | **B2** |
| `QExpansionItem.json` | component | 容器列表 | `Nova.Controls.NovaExpansionItem` | `MAPPED` | 45 | 4 | P2 | **B2** |
| `QFab.json` | component | 按钮操作 | `Nova.Controls.NovaFab` | `MAPPED` | 42 | 11 | P2 | **B2** |
| `QFabAction.json` | component | 按钮操作 | `Nova.Controls.NovaFabAction` | `MAPPED` | 27 | 10 | P2 | **B2** |
| `QField.json` | component | 表单输入 | `Nova.Controls.NovaField` | `MAPPED` | 57 | 14 | P1 | **B1** |
| `QFile.json` | component | 表单输入 | **无对应类型** | `GAP` | 未展开 77 | 0 | P2 | **B3** |
| `QForm.json` | component | 表单输入 | `Nova.Controls.NovaForm` | `MAPPED` | 15 | 6 | P2 | **B2** |
| `QFormChildMixin.json` | component | 表单输入 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QIcon.json` | component | 容器列表 | `Nova.Controls.NovaIcon` | `MAPPED` | 7 | 4 | P2 | **B2** |
| `QImg.json` | component | 媒体轮播 | `Nova.Controls.NovaImg` | `MAPPED` | 32 | 17 | P2 | **B2** |
| `QInfiniteScroll.json` | component | 数据展示 | `Nova.Controls.NovaInfiniteScroll` | `MAPPED` | 17 | 12 | P2 | **B2** |
| `QInnerLoading.json` | component | 反馈进度 | `Nova.Controls.NovaInnerLoading` | `MAPPED` | 11 | 3 | P2 | **B2** |
| `QInput.json` | component | 表单输入 | `Nova.Controls.NovaInput` | `MAPPED` | 69 | 55 | P1 | **B1** |
| `QIntersection.json` | component | 容器列表 | `Nova.Behaviors.NovaIntersection` | `MAPPED` | 12 | 8 | P2 | **B2** |
| `QItem.json` | component | 容器列表 | `Nova.Controls.NovaItem` | `MAPPED` | 20 | 8 | P2 | **B2** |
| `QItemLabel.json` | component | 容器列表 | `Nova.Controls.NovaItemLabel` | `MAPPED` | 5 | 0 | — | **B0** |
| `QItemSection.json` | component | 容器列表 | `Nova.Controls.NovaItemSection` | `MAPPED` | 6 | 3 | P2 | **B2** |
| `QKnob.json` | component | 表单输入 | **无对应类型** | `GAP` | 未展开 25 | 0 | P2 | **B3** |
| `QLinearProgress.json` | component | 反馈进度 | **无对应类型** | `GAP` | 未展开 14 | 0 | P2 | **B3** |
| `QList.json` | component | 容器列表 | `Nova.Controls.NovaList` | `MAPPED` | 8 | 3 | P2 | **B2** |
| `QMarkupTable.json` | component | 数据展示 | `Nova.Controls.NovaMarkupTable` | `MAPPED` | 8 | 4 | P2 | **B2** |
| `QMenu.json` | component | 弹层浮层 | `Nova.Controls.NovaMenu` | `MAPPED` | 39 | 11 | P1 | **B1** |
| `QNoSsr.json` | component | 容器列表 | `Nova.Controls.NovaNoSsr` | `MAPPED` | 4 | 1 | P2 | **B2** |
| `QOptionGroup.json` | component | 表单输入 | `Nova.Controls.NovaOptionGroup` | `MAPPED` | 18 | 5 | P2 | **B2** |
| `QPagination.json` | component | 数据展示 | `Nova.Controls.NovaPagination` | `MAPPED` | 38 | 28 | P2 | **B2** |
| `QParallax.json` | component | 媒体轮播 | `Nova.Controls.NovaParallax` | `MAPPED` | 9 | 4 | P2 | **B2** |
| `QPopupEdit.json` | component | 弹层浮层 | `Nova.Controls.NovaPopupEdit` | `MAPPED` | 49 | 30 | P2 | **B2** |
| `QPopupProxy.json` | component | 弹层浮层 | `Nova.Controls.NovaPopupProxy` | `MAPPED` | 47 | 23 | P2 | **B2** |
| `QPullToRefresh.json` | component | 容器列表 | `Nova.Controls.NovaPullToRefresh` | `MAPPED` | 11 | 3 | P2 | **B2** |
| `QRadio.json` | component | 表单输入 | `Nova.Controls.NovaRadio` | `MAPPED` | 17 | 4 | P2 | **B2** |
| `QRange.json` | component | 表单输入 | `Nova.Controls.NovaRange` | `MAPPED` | 54 | 24 | P2 | **B2** |
| `QRating.json` | component | 表单输入 | **无对应类型** | `GAP` | 未展开 17 | 0 | P2 | **B3** |
| `QResizeObserver.json` | component | 容器列表 | `Nova.Controls.NovaResizeObserver` | `MAPPED` | 3 | 0 | — | **B0** |
| `QResponsive.json` | component | 容器列表 | `Nova.Controls.NovaResponsive` | `MAPPED` | 2 | 0 | — | **B0** |
| `QRouteTab.json` | component | 导航 | **无对应类型** | `GAP` | 未展开 19 | 0 | P2 | **B3** |
| `QScrollArea.json` | component | 容器列表 | `Nova.Controls.NovaScrollArea` | `MAPPED` | 22 | 11 | P2 | **B2** |
| `QScrollObserver.json` | component | 容器列表 | `Nova.Behaviors.NovaScrollObserver` | `MAPPED` | 6 | 5 | P2 | **B2** |
| `QSelect.json` | component | 表单输入 | `Nova.Controls.NovaSelect` | `MAPPED` | 144 | 110 | P1 | **B1** |
| `QSeparator.json` | component | 容器列表 | `Nova.Controls.NovaSeparator` | `MAPPED` | 6 | 1 | P2 | **B2** |
| `QSkeleton.json` | component | 反馈进度 | `Nova.Controls.NovaSkeleton` | `MAPPED` | 11 | 5 | P2 | **B2** |
| `QSlideItem.json` | component | 容器列表 | `Nova.Controls.NovaSlideItem` | `MAPPED` | 17 | 14 | P2 | **B2** |
| `QSlider.json` | component | 表单输入 | `Nova.Controls.NovaSlider` | `MAPPED` | 41 | 14 | P1 | **B1** |
| `QSlideTransition.json` | component | 容器列表 | **无对应类型** | `GAP` | 未展开 5 | 0 | P2 | **B3** |
| `QSpinner.json` | component | 加载指示器族 | `Nova.Controls.NovaSpinner` | `MAPPED` | 3 | 0 | — | **B0** |
| `QSpinnerAudio.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerBall.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerBars.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerBox.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerClock.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerComment.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerCube.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerDots.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerFacebook.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerGears.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerGrid.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerHearts.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerHourglass.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerInfinity.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerIos.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerOrbit.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerOval.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerPie.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerPuff.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerRadio.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerRings.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QSpinnerTail.json` | component | 加载指示器族 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `QStep.json` | component | 导航 | `Nova.Controls.NovaStep` | `MAPPED` | 17 | 0 | — | **B0** |
| `QStepper.json` | component | 导航 | `Nova.Controls.NovaStepper` | `MAPPED` | 36 | 7 | P1 | **B1** |
| `QStepperNavigation.json` | component | 导航 | `Nova.Controls.NovaStepperNavigation` | `GAP` | 1 | 0 | — | **B0** |
| `QTab.json` | component | 导航 | `Nova.Controls.NovaTab` | `MAPPED` | 11 | 1 | P2 | **B2** |
| `QTable.json` | component | 数据展示 | `Nova.Controls.NovaTable` | `MAPPED` | 114 | 14 | P1 | **B1** |
| `QTabPanel.json` | component | 导航 | `Nova.Controls.NovaTabPanel` | `MAPPED` | 3 | 0 | — | **B0** |
| `QTabPanels.json` | component | 导航 | `Nova.Controls.NovaTabPanels` | `MAPPED` | 20 | 6 | P2 | **B2** |
| `QTabs.json` | component | 导航 | `Nova.Controls.NovaTabs` | `MAPPED` | 22 | 0 | — | **B1** |
| `QTd.json` | component | 数据展示 | `Nova.Controls.NovaTd` | `MAPPED` | 5 | 3 | P2 | **B2** |
| `QTh.json` | component | 数据展示 | `Nova.Controls.NovaTh` | `GAP` | 4 | 3 | P2 | **B2** |
| `QTime.json` | component | 表单输入 | `Nova.Controls.NovaTime` | `MAPPED` | 25 | 12 | P2 | **B2** |
| `QTimeline.json` | component | 导航 | `Nova.Controls.NovaTimeline` | `MAPPED` | 5 | 0 | — | **B0** |
| `QTimelineEntry.json` | component | 导航 | `Nova.Controls.NovaTimelineEntry` | `MAPPED` | 12 | 1 | P2 | **B2** |
| `QToggle.json` | component | 表单输入 | `Nova.Controls.NovaToggle` | `MAPPED` | 25 | 18 | P2 | **B2** |
| `QTooltip.json` | component | 弹层浮层 | `Nova.Controls.NovaTooltip` | `MAPPED` | 25 | 9 | P2 | **B2** |
| `QTr.json` | component | 数据展示 | `Nova.Controls.NovaTr` | `GAP` | 4 | 3 | P2 | **B2** |
| `QTree.json` | component | 数据展示 | `Nova.Controls.NovaTree` | `MAPPED` | 58 | 34 | P2 | **B2** |
| `QUploader.json` | component | 表单输入 | **无对应类型** | `GAP` | 未展开 50 | 0 | P2 | **B3** |
| `QUploaderAddTrigger.json` | component | 表单输入 | **无对应类型** | `GAP` | 未展开 0 | 0 | P2 | **B3** |
| `QVideo.json` | component | 媒体轮播 | `Nova.Controls.NovaVideo` | `MAPPED` | 6 | 3 | P2 | **B2** |
| `QVirtualScroll.json` | component | 数据展示 | `Nova.Controls.NovaVirtualScroll` | `MAPPED` | 30 | 27 | P2 | **B2** |

### 2.3 L3 · 指令（13 条）

| 上游 | 类型 | 功能族 | Nova 对应 | 状态 | 逐项 | GAP | 优先级 | 批次 |
|---|---|---|---|---|---|---|---|---|
| `ClosePopup.json` | directive | 行为指令 | `Nova.Behaviors.NovaClosePopup` | `GAP` | 1 | 0 | — | **B0** |
| `DropZone.json` | directive | 行为指令 | **无对应类型** | `GAP` | 未展开 1 | 0 | P2 | **B3** |
| `Intersection.json` | directive | 行为指令 | `Nova.Behaviors.NovaIntersection` | `GAP` | 1 | 0 | — | **B0** |
| `Morph.json` | directive | 行为指令 | `Nova.Behaviors.NovaMorph` | `GAP` | 1 | 0 | — | **B0** |
| `Mutation.json` | directive | 行为指令 | **无对应类型** | `GAP` | 未展开 1 | 0 | P2 | **B3** |
| `Resize.json` | directive | 行为指令 | **无对应类型** | `GAP` | 未展开 1 | 0 | P2 | **B3** |
| `Ripple.json` | directive | 行为指令 | `Nova.Behaviors.NovaRipple` | `GAP` | 1 | 0 | — | **B0** |
| `Scroll.json` | directive | 行为指令 | **无对应类型** | `GAP` | 未展开 1 | 0 | P2 | **B3** |
| `ScrollFire.json` | directive | 行为指令 | `Nova.Behaviors.NovaScrollFire` | `GAP` | 1 | 0 | — | **B0** |
| `TouchHold.json` | directive | 行为指令 | `Nova.Behaviors.NovaTouchHold` | `GAP` | 1 | 0 | — | **B0** |
| `TouchPan.json` | directive | 行为指令 | `Nova.Behaviors.NovaTouchPan` | `GAP` | 1 | 0 | — | **B0** |
| `TouchRepeat.json` | directive | 行为指令 | `Nova.Behaviors.NovaTouchRepeat` | `GAP` | 1 | 0 | — | **B0** |
| `TouchSwipe.json` | directive | 行为指令 | `Nova.Behaviors.NovaTouchSwipe` | `GAP` | 1 | 0 | — | **B0** |

### 2.4 L4 · 插件（服务）（20 条）

| 上游 | 类型 | 功能族 | Nova 对应 | 状态 | 逐项 | GAP | 优先级 | 批次 |
|---|---|---|---|---|---|---|---|---|
| `AddressbarColor.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `AppFullscreen.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 7 | 0 | P2 | **B3** |
| `AppNetwork.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 7 | 0 | P2 | **B3** |
| `AppVisibility.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 2 | 0 | P2 | **B3** |
| `AppWakeLock.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 6 | 0 | P2 | **B3** |
| `BottomSheet.json` | plugin | 平台插件 | `Nova.Controls.NovaBottomSheet` | `GAP` | 2 | 1 | P2 | **B2** |
| `Brand.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 3 | 0 | P2 | **B3** |
| `Cookies.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 8 | 0 | P2 | **B3** |
| `Dark.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 9 | 0 | P2 | **B3** |
| `Dialog.json` | plugin | 平台插件 | `Nova.Services.NovaDialog` | `GAP` | 2 | 1 | P1 | **B1** |
| `IconSet.json` | plugin | 平台插件 | `Nova.Design.NovaIconSet` | `MAPPED` | 4 | 2 | P2 | **B2** |
| `Lang.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 8 | 0 | P2 | **B3** |
| `Loading.json` | plugin | 平台插件 | `Nova.Services.NovaLoading` | `MAPPED` | 8 | 1 | P1 | **B1** |
| `LoadingBar.json` | plugin | 平台插件 | `Nova.Services.NovaLoadingBar` | `MAPPED` | 11 | 2 | P2 | **B2** |
| `LocalStorage.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 13 | 0 | P2 | **B3** |
| `Meta.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 0 | 0 | P2 | **B3** |
| `Notify.json` | plugin | 平台插件 | `Nova.Services.NovaNotify` | `MAPPED` | 7 | 1 | P2 | **B2** |
| `Platform.json` | plugin | 平台插件 | `Nova.Services.NovaPlatform` | `GAP` | 6 | 5 | P2 | **B2** |
| `Screen.json` | plugin | 平台插件 | `Nova.Services.NovaScreen` | `MAPPED` | 18 | 11 | P2 | **B2** |
| `SessionStorage.json` | plugin | 平台插件 | **无对应类型** | `GAP` | 未展开 13 | 0 | P2 | **B3** |

## 3. 组件级缺口专表（53 条 NO_NOVA_COUNTERPART）

> 这些上游条目在冻结面 147 类型中无对应类型。逐项成员未展开（合计 400 项），需先逐条判定「新增组件 / N/A 理由码」，再决定是否立项——**不直接等于要做 53 个组件**。

| 功能族 | 条数 | 代表条目 |
|---|---|---|
| 加载指示器族 | **22** | `QSpinnerAudio`, `QSpinnerBall`, `QSpinnerBars`, `QSpinnerBox`, `QSpinnerClock` |
| 平台插件 | **12** | `AddressbarColor`, `AppFullscreen`, `AppNetwork`, `AppVisibility`, `AppWakeLock` |
| 表单输入 | **7** | `QColor`, `QFile`, `QFormChildMixin`, `QKnob`, `QRating` |
| 布局骨架 | **4** | `QPageContainer`, `QPageScroller`, `QPageSticky`, `QSplitter` |
| 行为指令 | **4** | `DropZone`, `Mutation`, `Resize`, `Scroll` |
| 反馈进度 | **2** | `QCircularProgress`, `QLinearProgress` |
| 容器列表 | **1** | `QSlideTransition` |
| 导航 | **1** | `QRouteTab` |

## 4. 批次聚合与建议（批次是建议，不是立项）

| 批次 | 名称 | 优先级 | 条目 | 成员级 GAP | 组件级缺口 | 说明 |
|---|---|---|---|---|---|---|
| **B1** | 封版前置 · P0 集欠账清零 | P1 | 12 | 267 | 0 | D1 目标函数指向：适用域内 P0 100% 机检固化，是封版门禁前置。 |
| **B3** | 组件级归属判定 | P2 | 53 | 0 | 53 | 53 条上游条目在冻结面 147 类型中无对应类型；先逐条判定「新增组件 / N/A 理由码」，再决定是否立项。 |
| **B2** | 语义补登记与成员级欠账 | P2 | 66 | 595 | 0 | 含语义等价但未登记映射的项（variant 承接 square/rounded、主题令牌承接 *-color 等）。P2 只补登记、不放宽口径；GAP 是保守下界。 |
| **B0** | 已解释 · 维持 | — | 25 | 0 | 0 | 无 GAP 的条目，维持现有归属判定即可。 |

> **口径守恒**：四个批次的成员级 GAP 求和 = 862（与矩阵一致）；组件级缺口条目求和 = 53。B1 是 D1 目标函数（适用域内 P0 100% 机检固化）的封版前置，B2 只补登记不放宽口径，B3 先做归属判定。**全部须 CSA 拍板后才立项**。

## 5. 面外未纳入层（dist/api 之外，如实列出）

> 这是「全面对标」不能只看 156 条的关键。以下生态面不在 npm `dist/api/*.json` 内，本轮只登记现状与 P2 应做动作，**不计入任何覆盖率分子**。

| 层 | 面 | Nova 现状 | 为何面外 | P2 应做 |
|---|---|---|---|---|
| **L0** | 设计令牌 / 十色相主题 / 图标集 / NovaMotion 动效 / 字阶 / 高程 | NovaTheme（Services）/ Design 4 类型 / 11 套主题 / 14 套图标 | npm dist/api/*.json 只发布组件 / 插件 / 指令的 API 元数据，不含设计语言层；不能把 156 条当作全生态。 | 建 L0 现行基线（令牌清单 + 主题数 + 图标集清单），与上游 ui/src/css/core/*、ui/icon-set/* 逐项对账。 |
| **L5** | NovaUtils（colors / date / format / is / debounce…）+ composables + CSS 工具类 | NovaUtils.qml（L5 工具层） | T30 已实证：0.13.0 判「2.35.6 零漂移」只比对 dist/api/*.json，漏掉 L5 工具层，导致 humanStorageSize 三条边界欠账。这正是「全生态 ≠ 156 条」的可复现证据。 | 建 L5 基线：把 ui/src/utils/* 与 ui/src/composables/* 纳入周巡 scope（cadence.json::T2 双源交叉覆盖），逐函数登记机检绑定。 |
| **L6** | CLI / 打包 / 文档站 / 测试 / 发布 / 治理 / SBOM·CVE 周巡 | nova-forge CLI / mkdocs / 静态 3/3 / gen_* 生成器链 / check_cve.py | 工程化层不是上游 dist/api 条目，按层单列才符合宪法第 10 章「组件堆满、生态空心」的反向纪律。 | 建 L6 基线，登记工具链与门禁现状；不把工程能力混入组件覆盖率分子。 |
| **L0** | ui/lang/* 语言包（2.36.0 新增 Tajik tg）· ui/icon-set/* | I18N.md / 图标注册表 | 2.36.0 的 C3 变更正落在此面，不在 156 条内；若不单列，周巡会误判「本版零影响却无处登记」。 | 纳入 cadence.json::T2 周巡登记范围，C3 只登记不阻断。 |

## 6. 未竟事项（列出 ≠ 完现 P2）

- **本轮只做**：逐条台账 + 批次建议 + 面外清单 + 机检固化；`docs/PARITY_BREADTH.md` 已挂 nav。
- **未做（须 CSA 立项）**：`parity/baseline.json` 棘轮基线（覆盖率只升不降）、站点 parity dashboard、门禁阈值提升、53 条逐条归属判定、面外层基线（L0/L5/L6）、862 项 GAP 逐项收敛。
- **未做（已核定的 D3 节奏，见 `docs/PARITY_CADENCE.md`）**：`--online` 双源实现、`nova_mcp.py::check_updates` 升级、每周定时自动化（须 CSA 单独授权）。
- **升 pin 独立议题**：D4 下 `pinned` 保持 2.35.5；`gen_upstream_baseline.py --apply` 仍 rc 2。
- **零改动边界**：零 QML / 零冻结面改动（147 类型 / `9966483dda5a53c4` 不变）· 不升版 · 不重签 · 零史料回改 · 零发布动作 · 零自动化任务。

---

*签名 `943ef27d61f6919e8def1f02a13b5cf921084c169f9f17cc5b9782b732ee8384` · 由 `gen_parity_breadth.py` 生成，`check_parity_ops.py` 校验。*
