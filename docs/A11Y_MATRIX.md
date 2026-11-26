# 可访问性矩阵 — A11Y_MATRIX

> 本文件由 `python scripts/check_a11y.py --matrix docs/A11Y_MATRIX.md` 生成，**勿手改**。
> 契约分类与门禁规则见 [A11Y.md](A11Y.md)；分类是审计结论：interactive=可操作控件，
> semantic=只读语义元素，decorative=布局/装饰（**故意不挂** Accessible，避免屏读器噪声）。

总计 144 个导出类型：interactive 32 · semantic 28 · decorative 84

| 层 | 类型 | 分类 | Accessible.role | 可读名来源 | 键盘入口 | 按键路径 | 焦点环 | 门禁 |
|---|---|---|---|---|---|---|---|---|
| Controls | `NovaAvatar` | semantic | Graphic | a11yLabel → text | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaBadge` | semantic | StaticText | a11yLabel → label | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaBtn` | interactive | Button | a11yLabel → text | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaBtnToggle` | interactive | RadioButton | a11yLabel → text | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaCard` | decorative | - | 卡片容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaCardActions` | decorative | - | 卡片动作区 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaCardSection` | decorative | - | 卡片分区 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaCarousel` | interactive | Grouping | a11yLabel（可选） | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaCarouselControl` | semantic | Grouping | a11yLabel（定位容器，语义由内部控件承担） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaCarouselSlide` | decorative | - | 轮播页容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaChatMessage` | semantic | StaticText | text | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaCheckbox` | interactive | CheckBox | a11yLabel → label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaChip` | interactive | Button/StaticText | a11yLabel → label（可点/可删时 Button） | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaCol` | decorative | - | 栅格容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaColorPicker` | interactive | ColorChooser | a11yLabel → hint | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaDate` | interactive | EditableText | a11yLabel → title | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaDrawer` | decorative | - | 布局骨架 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaField` | semantic | Grouping | label | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaFooter` | decorative | - | 布局骨架 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaForm` | semantic | Form | a11yLabel（可选） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaHeader` | decorative | - | 布局骨架 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaIcon` | semantic | Graphic | a11yLabel（装饰图标可空） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaImg` | semantic | Graphic | alt | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaInput` | interactive | EditableText | label / placeholder / a11yLabel | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaLayout` | decorative | - | 布局骨架 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaOptionGroup` | semantic | Grouping | label | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaInfiniteScroll` | decorative | - | 滚动容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaItem` | interactive | Button/ListItem | a11yLabel → label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaItemLabel` | decorative | - | 文本节点，由父项可读名承载 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaItemSection` | decorative | - | 分组容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaList` | semantic | List | a11yLabel（可选） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaMarkupTable` | semantic | Table | a11yLabel（可选） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaPage` | decorative | - | 布局骨架 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaPagination` | interactive | Grouping | a11yLabel | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaParallax` | decorative | - | 视差容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaPopupEdit` | interactive | Button | a11yLabel → label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaRadio` | interactive | RadioButton | a11yLabel → label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaRange` | interactive | Slider | a11yLabel → label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaResponsive` | decorative | - | 等比容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaRow` | decorative | - | 栅格容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaScrollArea` | decorative | - | 滚动容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaSelect` | interactive | ComboBox | label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaSeparator` | semantic | Separator | a11yLabel（可选） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaSlideItem` | interactive | Grouping | a11yLabel（可选） | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaSlider` | interactive | Slider | a11yLabel → label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaSpace` | decorative | - | 间距占位 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaTable` | interactive | Table | a11yLabel（可选） | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaTd` | decorative | - | 单元格内容由所在行的可读名承载 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaText` | semantic | StaticText | text | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaTh` | interactive | ColumnHeader | text | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaTimeline` | decorative | - | 时间线容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaTimelineEntry` | semantic | ListItem | title | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaTime` | interactive | EditableText | a11yLabel → hint | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaToggle` | interactive | Switch | a11yLabel → label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaTransition` | decorative | - | 过渡容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaTree` | interactive | Tree | a11yLabel（可选） | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaTr` | decorative | - | 行容器，语义由 NovaTable 承担 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaVirtualScroll` | decorative | - | 滚动容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaVideo` | semantic | Animation | title | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaVisible` | decorative | - | 断点显示代理 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaTabs` | interactive | PageTabList | a11yLabel（可选） | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaTab` | interactive | PageTab | label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaTabPanel` | decorative | - | 面板容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaTabPanels` | decorative | - | 面板容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaBreadcrumbs` | semantic | Grouping | a11yLabel（可选） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaBreadcrumbsEl` | interactive | Link | a11yLabel → label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaStepper` | semantic | Grouping | a11yLabel（可选） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaStep` | semantic | ListItem | title | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaStepperNavigation` | semantic | Grouping | a11yLabel（可选） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaEditor` | interactive | EditableText | label / a11yLabel | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaExpansionItem` | interactive | Button | label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaToolbar` | semantic | ToolBar | a11yLabel（可选） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaToolbarTitle` | semantic | Heading | text | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaFab` | interactive | Button | a11yLabel → icon 语义键 | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaFabAction` | interactive | Button | a11yLabel → label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaMenu` | interactive | PopupMenu | a11yLabel（可选） | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaDialogShell` | interactive | Dialog | title | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaPopupProxy` | decorative | - | 路由容器，语义由目标弹层承担 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaTooltip` | semantic | ToolTip | text | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaBottomSheet` | interactive | Dialog | title | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaSpinner` | semantic | ProgressBar | a11yLabel（i18n 后默认「加载中」） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaSkeleton` | decorative | - | 占位骨架，对屏读器无信息量 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaInnerLoading` | semantic | ProgressBar | a11yLabel（i18n 后默认「加载中」） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaAjaxBar` | semantic | ProgressBar | a11yLabel（i18n 后默认「加载中」） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaBanner` | semantic | Grouping | a11yLabel（可选） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaBar` | decorative | - | 通用条容器 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaNoSsr` | decorative | - | 延迟渲染代理 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaPullToRefresh` | semantic | Grouping | a11yLabel（触摸手势容器：键盘等价路径由内容区刷新按钮承担） | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaResizeObserver` | decorative | - | 尺寸观察行为 | ❌ | ❌ | ❌ | ✅ |
| Controls | `NovaBtnDropdown` | interactive | ButtonDropDown | a11yLabel → label | ✅ | ✅ | ✅ | ✅ |
| Controls | `NovaBtnGroup` | semantic | Grouping | a11yLabel（可选） | ❌ | ❌ | ❌ | ✅ |
| Behaviors | `NovaMorphPool` | decorative | - | 形变注册表 | ❌ | ❌ | ❌ | ✅ |
| Behaviors | `NovaRipple` | decorative | - | 纯视觉反馈，无信息量 | ❌ | ❌ | ❌ | ✅ |
| Behaviors | `NovaIntersection` | decorative | - | 观察器行为 | ❌ | ❌ | ❌ | ✅ |
| Behaviors | `NovaScrollObserver` | decorative | - | 观察器行为 | ❌ | ❌ | ❌ | ✅ |
| Behaviors | `NovaScrollFire` | decorative | - | 滚动触发行为 | ❌ | ❌ | ❌ | ✅ |
| Behaviors | `NovaClosePopup` | decorative | - | 点击外部关闭行为 | ❌ | ✅ | ❌ | ✅ |
| Behaviors | `NovaTouchPan` | decorative | - | 指针手势行为 | ❌ | ❌ | ❌ | ✅ |
| Behaviors | `NovaTouchSwipe` | decorative | - | 指针手势行为 | ❌ | ❌ | ❌ | ✅ |
| Behaviors | `NovaTouchHold` | decorative | - | 指针手势行为 | ❌ | ❌ | ❌ | ✅ |
| Behaviors | `NovaTouchRepeat` | decorative | - | 指针手势行为 | ❌ | ✅ | ❌ | ✅ |
| Behaviors | `NovaMorph` | decorative | - | 形变过渡，宿主语义不变 | ❌ | ❌ | ❌ | ✅ |
| Behaviors | `NovaFocusRing` | decorative | - | 焦点指示绘制件（自身不承载语义） | ❌ | ❌ | ✅ | ✅ |
| Behaviors | `NovaLiveRegion` | decorative | - | 播报通道，语义来自 NovaA11y.notice 文本 | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaScreen` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaTheme` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaOverlayHost` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaNotify` | decorative | - | QtObject 单例：语义经 NovaA11y.notice 播报 | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaDialog` | decorative | - | QtObject 单例：语义经 NovaA11y.notice 播报 | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaIntersectionPool` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaLoading` | decorative | - | QtObject 单例：语义经 NovaA11y.notice 播报 | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaStorage` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaApp` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaPlatform` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaI18n` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaNotifyAction` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaNotifyHandle` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaDialogHandle` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaLoadingHandle` | decorative | - | 无视觉节点（状态/平台/注册表） | ❌ | ❌ | ❌ | ✅ |
| Services | `NovaLoadingBar` | decorative | - | QtObject 单例：语义经 NovaA11y.notice 播报 | ❌ | ❌ | ❌ | ✅ |
| Design | `NovaIconSet` | decorative | - | 图标数据表 | ❌ | ❌ | ❌ | ✅ |
| Design | `NovaMotion` | decorative | - | 动效令牌 | ❌ | ❌ | ❌ | ✅ |
| Design | `NovaUtils` | decorative | - | 工具函数 | ❌ | ❌ | ❌ | ✅ |
| Design | `NovaA11y` | decorative | - | a11y 基座单例（本身即门禁设施） | ❌ | ❌ | ❌ | ✅ |
| Composite/LayoutShell | `NovaSidebar` | decorative | - | 侧边导航工作台骨架，语义由注入槽位承担 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaTopNavigation` | decorative | - | 顶部导航工作台骨架 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaDualSide` | decorative | - | 双侧边三栏工作台骨架 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaTabShell` | decorative | - | 标签页工作台骨架（保留 Shell 后缀，避开 Controls.NovaTab 语义混淆） | ❌ | ❌ | ❌ | ✅ |
| Composite/LayoutShell | `NovaThreeColumn` | decorative | - | 三栏工作台骨架 | ❌ | ❌ | ❌ | ✅ |
| Composite/LayoutShell | `NovaCompare` | decorative | - | 双栏对比骨架 | ❌ | ❌ | ❌ | ✅ |
| Composite/LayoutShell | `NovaCardGrid` | decorative | - | 卡片网格骨架 | ❌ | ❌ | ❌ | ✅ |
| Composite/LayoutShell | `NovaModal` | decorative | - | 模态弹窗容器骨架，焦点由内部交互件承担 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaDrawerPanel` | decorative | - | 侧滑面板容器骨架 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaSetupWizard` | decorative | - | 安装 / 新建工程 / 初始化配置向导骨架 | ❌ | ❌ | ❌ | ✅ |
| Composite/LayoutShell | `NovaBlankPage` | decorative | - | 纯净单页骨架 | ❌ | ❌ | ❌ | ✅ |
| Composite/LayoutShell | `NovaDesktop` | decorative | - | 桌面应用顶层根壳 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaMobile` | decorative | - | 移动应用顶层根壳 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaFlexLayout` | decorative | - | 企业大屏弹性布局根壳 | ❌ | ❌ | ❌ | ✅ |
| Composite/LayoutShell | `NovaChat` | decorative | - | AI 对话主窗口骨架，气泡语义由注入的 NovaChatMessage 承担 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaAgent` | decorative | - | 智能体任务执行工作台骨架，任务/审批/验证语义由注入槽位承担 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaDE` | decorative | - | 数字员工岗位工作台骨架，岗位/队列/SLA 语义由注入槽位承担 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaCopilot` | decorative | - | 增强型协作面板骨架，建议/闸门/撤销语义由注入槽位承担 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaOrbit` | decorative | - | 意图轨道工作台骨架，轨道态势/活产物/孵化确认语义由注入槽位承担 | ❌ | ✅ | ❌ | ✅ |
| Composite/LayoutShell | `NovaIncubator` | decorative | - | 应用孵化器工作台骨架，配方/七区契约/三重校验/封版证书语义由注入槽位承担 | ❌ | ✅ | ❌ | ✅ |
