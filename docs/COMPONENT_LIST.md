# pyside-nova 组件清单

> 版本 **1.6.0** · 基线 **Quasar 2.35.5** · API 指纹 `7c542c416709cd96` · 共 **147** 个公共 QML 类型
>
> 数据源：`api/nova-api-1.6.0.json`（权威）+ `docs/ai/api/*.json`（描述）。本文件由 `scripts/gen_component_list.py` 生成，请勿手工编辑。
>
> 分类口径：Nova.Controls 93 / Nova.Behaviors 13 / Nova.Services 16 / Nova.Design 4 / Nova.Composite.LayoutShell 21；每个类型在 `examples/gallery/` 中有实机展示页面。

## 目录

- 一、Controls · 控件（93 项）
- 二、Behaviors · 行为（13 项）
- 三、Services · 服务单例（16 项）
- 四、Design · 设计层（4 项）
- 五、Composite/LayoutShell · 组合组件（15 项根容器）（21 项）

---

## 一、Controls · 控件（93 项）

| 序号 | 组件 | 说明 | 对标 Quasar | a11y | 属性/信号/方法 | QML 文件 |
|---:|---|---|---|---|---:|---|
| 1 | **NovaAjaxBar** | 顶部进度条：start/increment/stop 命令式 API + 渐进模拟（越接近完成越慢，对标 QAjaxBar） 四向 position（top/bottom/left/right）+ reverse；进… | QAjaxBar | semantic（语义） | 8/2/3 | `Nova/Controls/NovaAjaxBar.qml` |
| 2 | **NovaAvatar** | 头像：文字哈希自动配色 / 图片 / square / size 可调 | QAvatar | semantic（语义） | 8/0/0 | `Nova/Controls/NovaAvatar.qml` |
| 3 | **NovaBadge** | 徽标：红点（text 留空）/数值/浮动三种模式，作为子项挂载到任意 Item | QBadge | semantic（语义） | 8/0/0 | `Nova/Controls/NovaBadge.qml` |
| 4 | **NovaBanner** | 横幅：default/avatar/action 三槽、inline-actions 同行、dense、rounded | QBanner | semantic（语义） | 7/0/0 | `Nova/Controls/NovaBanner.qml` |
| 5 | **NovaBar** | 顶栏：default 槽、dense、tint 默认主色 | QBar —— 默认背景 $primary、文字反转 | decorative（装饰） | 3/0/0 | `Nova/Controls/NovaBar.qml` |
| 6 | **NovaBottomSheet** | 底部动作面板：actions 数组（列表/网格）+ default 槽、遮罩、ESC/背景点击关闭、 关闭原因上报（backdrop/escape/api，对标 BottomSheet 插件 · 基线 2.28 语义… | BottomSheet 插件 | interactive（交互） | 7/8/4 | `Nova/Controls/NovaBottomSheet.qml` |
| 7 | **NovaBreadcrumbs** | 面包屑容器：在条目之间自动插分隔符 | QBreadcrumbs | semantic（语义） | 8/0/2 | `Nova/Controls/NovaBreadcrumbs.qml` |
| 8 | **NovaBreadcrumbsEl** | 面包屑条目：label/icon/disable + default 槽 | QBreadcrumbsEl | interactive（交互） | 6/1/1 | `Nova/Controls/NovaBreadcrumbsEl.qml` |
| 9 | **NovaBtn** | 按钮：filled/outlined/flat × sm/md/lg，内置按压水波纹、hover、loading、disable、键盘触发 | QBtn | interactive（交互） | 13/3/2 | `Nova/Controls/NovaBtn.qml` |
| 10 | **NovaBtnDropdown** | 下拉按钮：NovaBtn 主钮 + 内嵌 NovaMenu、split 分体、cover/persistent/auto-close 受控契约：modelValue（菜单开合，坑位 22） | QBtnDropdown | interactive（交互） | 18/6/5 | `Nova/Controls/NovaBtnDropdown.qml` |
| 11 | **NovaBtnGroup** | 按钮组样式壳：spread/vertical、outline/flat/push 形态统一下发 子项为 NovaBtn；组内间距归零（并接）；vertical 切换时槽内容 reparent 到对应布局容器 | QBtnGroup | semantic（语义） | 6/0/0 | `Nova/Controls/NovaBtnGroup.qml` |
| 12 | **NovaBtnToggle** | 按钮组切换：options 单/多值、clearable、active 着色、spread/vertical 对标 Quasar QBtnToggle（31 props；Nova 收口核心 22 项，glossy/s… | Quasar QBtnToggle | interactive（交互） | 28/1/2 | `Nova/Controls/NovaBtnToggle.qml` |
| 13 | **NovaCard** | 卡片容器：flat/elevated/bordered、elevation 0~5 级 MultiEffect 真实阴影 | QCard | decorative（装饰） | 4/0/0 | `Nova/Controls/NovaCard.qml` |
| 14 | **NovaCardActions** | 卡片操作区：align 左/中/右对齐 | QCardActions | decorative（装饰） | 1/0/0 | `Nova/Controls/NovaCardActions.qml` |
| 15 | **NovaCardSection** | 卡片内容区：默认内容槽，padding 取 NovaTheme.spacingL | QCardSection | decorative（装饰） | 1/0/0 | `Nova/Controls/NovaCardSection.qml` |
| 16 | **NovaCarousel** | 轮播：受控 modelValue / arrows / navigation / thumbnails / autoplay / infinite / swipeable(DragHandler 被动抓取不吞子内容点… | QCarousel | interactive（交互） | 27/3/3 | `Nova/Controls/NovaCarousel.qml` |
| 17 | **NovaCarouselControl** | 轮播覆盖控件：声明于 NovaCarousel 内部， 完成后自动挂载到轮播覆盖层并按 position/offset 锚定；default 槽为控件内容 | QCarouselControl | semantic（语义） | 3/0/0 | `Nova/Controls/NovaCarouselControl.qml` |
| 18 | **NovaCarouselSlide** | 轮播页：name 寻址 / disable / img-src 快速图片页， default 槽为页内容；几何（位置/尺寸/显隐）由宿主 NovaCarousel 统一管理 | QCarouselSlide | decorative（装饰） | 3/0/0 | `Nova/Controls/NovaCarouselSlide.qml` |
| 19 | **NovaChatMessage** | 聊天气泡：sent 收发镜像 / name·avatar·text[]·stamp / label 分组标签 + size 栅格宽（1~12）；slots：default 正文 / avatarSlot / name… | QChatMessage | semantic（语义） | 15/0/0 | `Nova/Controls/NovaChatMessage.qml` |
| 20 | **NovaCheckbox** | 复选：true/false/indeterminate 三态、toggleOrder、val 模式、leftLabel、键盘切换 对标 Quasar QCheckbox（use-checkbox 18 props）；… | Quasar QCheckbox | interactive（交互） | 29/2/2 | `Nova/Controls/NovaCheckbox.qml` |
| 21 | **NovaChip** | 标签：filled/outlined/tinted、可选中、可移除、dense | QChip | interactive（交互） | 11/2/0 | `Nova/Controls/NovaChip.qml` |
| 22 | **NovaCol** | 栅格列：cols 1~12 占 12 栅格、offset 偏移、gutter 内边距，父级 NovaRow 自动排布 | Quasar col-*-n | decorative（装饰） | 3/0/0 | `Nova/Controls/NovaCol.qml` |
| 23 | **NovaColorPicker** | 取色器：SV 色域盘 + 色相条 + 调色板(palette) + HEX 编辑 + footer 值显示 对标 Quasar QColor（16 props；Nova 收口核心 13 项，rgb/hsl 编辑器与 … | Quasar QColor | interactive（交互） | 15/1/7 | `Nova/Controls/NovaColorPicker.qml` |
| 24 | **NovaDataGrid** | 企业级数据网格（1.5.0 additive · 第 146 公共类型） 定位：与已发布的 `NovaTable` 并存，不替换、不改动其冻结签名 | Nova 增强 / 无对应 | interactive（交互） | 32/8/8 | `Nova/Controls/NovaDataGrid.qml` |
| 25 | **NovaDate** | 自研日历：单选/多选(multiple)/区间(range)、mask 格式化、最小值约束、 事件点(events)、todayBtn、导航范围限定（Qt 6 无内置日历——对标 Quasar QDate 全自研路径… | Quasar QDate | interactive（交互） | 33/2/9 | `Nova/Controls/NovaDate.qml` |
| 26 | **NovaDialogShell** | 声明式对话框壳：遮罩 + 卡片 + default 槽，persistent/no-esc/no-backdrop、 五向定位、shake 吸引注意、**关闭原因上报**（ok/cancel/backdrop/esc… | QDialog | interactive（交互） | 17/10/9 | `Nova/Controls/NovaDialogShell.qml` |
| 27 | **NovaDrawer** | 侧边抽屉：left/right、mini 悬停展开、push/overlay 双模式、breakpoint 自动收起、宽度动画 | QDrawer | decorative（装饰） | 16/0/0 | `Nova/Controls/NovaDrawer.qml` |
| 28 | **NovaEditor** | 轻量富文本编辑器 工具栏配置 toolbar（数组的数组，分组渲染）+ execCmd() 格式化命令 + modelValue 受控 ── | QEditor · 基线 2.35.5 语义 | interactive（交互） | 10/3/6 | `Nova/Controls/NovaEditor.qml` |
| 29 | **NovaExpansionItem** | 展开项：header（icon/label/caption 或 header 命名槽）+ 动画展开内容；group 手风琴（ExpansionGroups.js 注册表互斥收起） | QExpansionItem | interactive（交互） | 26/7/4 | `Nova/Controls/NovaExpansionItem.qml` |
| 30 | **NovaFab** | 悬浮按钮组：主圆钮 + NovaFabAction 子项；direction 展开方向 / stagger 级联动画（逐个 delay=idx×stagger 显现）/ hover 打开契约（hoverDelay 进… | QFab | interactive（交互） | 22/5/4 | `Nova/Controls/NovaFab.qml` |
| 31 | **NovaFabAction** | 悬浮按钮动作：圆钮 + 外置 label；revealed/_delay 由宿主 NovaFab 级联下发（stagger 节拍），本组件只做渐显/缩放响应 | QFabAction | interactive（交互） | 11/1/1 | `Nova/Controls/NovaFabAction.qml` |
| 32 | **NovaField** | 表单容器壳：浮动 label + hint/error/counter 底行 + 样式四型 + 校验引擎 对标 Quasar QField（use-field 29 props + use-validate 7 pr… | Quasar QField | semantic（语义） | 41/2/4 | `Nova/Controls/NovaField.qml` |
| 33 | **NovaFooter** | 底部应用栏：NovaLayout 四象限之底栏，tint 基调色 + 默认槽，高度隐式 48 | QFooter | decorative（装饰） | 2/0/0 | `Nova/Controls/NovaFooter.qml` |
| 34 | **NovaForm** | 表单容器：聚合子组件校验（递归发现 validate() 能力）、greedy 全量校验、 提交聚合、错误焦点 | Quasar QForm 5 props 1:1 | semantic（语义） | 5/3/3 | `Nova/Controls/NovaForm.qml` |
| 35 | **NovaHeader** | 顶部应用栏：NovaLayout 四象限之顶栏，tint 基调色 + 默认槽，高度隐式 56 | QHeader | decorative（装饰） | 2/0/0 | `Nova/Controls/NovaHeader.qml` |
| 36 | **NovaIcon** | —— 图标：八通道归一化解析 + provider 注册表 + 本地图标包优先/CDN 回落 + MultiEffect 单色化 支持写法（NovaIconSet.resolve 归一化）： home / o_hom… | QIcon | semantic（语义） | 12/0/0 | `Nova/Controls/NovaIcon.qml` |
| 37 | **NovaImg** | 图片组件：占位/错误图 + 加载转圈（延时防闪）+ ratio 宽高比 + fit/position， slots：default 覆盖内容 / loadingSlot / errorSlot | QImg | semantic（语义） | 18/2/1 | `Nova/Controls/NovaImg.qml` |
| 38 | **NovaInfiniteScroll** | 无限滚动 滚动近底 emit load(index, done)：宿主追加内容后 done(false) 继续；done(true) 停止 | QInfiniteScroll | decorative（装饰） | 2/1/1 | `Nova/Controls/NovaInfiniteScroll.qml` |
| 39 | **NovaInnerLoading** | 局部加载遮罩：半透明蒙层 + Spinner（或 default 槽替换）+ label | QInnerLoading | semantic（语义） | 7/0/0 | `Nova/Controls/NovaInnerLoading.qml` |
| 40 | **NovaInput** | 文本输入：单行/密码/多行/数字、modelModifiers、debounce、autogrow、clearable 对标 Quasar QInput（input 8 props + use-field + use… | Quasar QInput | interactive（交互） | 10/2/1 | `Nova/Controls/NovaInput.qml` |
| 41 | **NovaItem** | 列表条目 槽：default（主内容）/ leading（左头像图标区，对标 QItemSection left）/ trailing（右侧区）/ expandContent（展开内容区，仅 expanded 时显示… | QItem | interactive（交互） | 14/2/2 | `Nova/Controls/NovaItem.qml` |
| 42 | **NovaItemLabel** | 条目标签：overline/caption/header/lines | QItemLabel | decorative（装饰） | 4/0/0 | `Nova/Controls/NovaItemLabel.qml` |
| 43 | **NovaItemSection** | 条目分区：avatar/thumbnail/trailing/topAligned | QItemSection | decorative（装饰） | 4/0/0 | `Nova/Controls/NovaItemSection.qml` |
| 44 | **NovaLayout** | 布局骨架：四象限容器（header/footer/drawer/page），按子项类型自动归位 + push/overlay 双模式 + 断点自动收起 | QLayout | decorative（装饰） | 8/0/3 | `Nova/Controls/NovaLayout.qml` |
| 45 | **NovaList** | 列表容器：separator/dense/padding、accordion 手风琴协调 | QList | semantic（语义） | 5/0/2 | `Nova/Controls/NovaList.qml` |
| 46 | **NovaMarkdown** | Markdown 文档渲染器：Qt 原生 Text.MarkdownText + NovaTheme 令牌 + 分块大纲 | Quasar QMarkdown | semantic（语义） | 10/3/3 | `Nova/Controls/NovaMarkdown.qml` |
| 47 | **NovaMarkupTable** | 标记表格：columns/rows 数组直渲 + 标题 | QMarkupTable | semantic（语义） | 6/0/0 | `Nova/Controls/NovaMarkupTable.qml` |
| 48 | **NovaMenu** | 声明式菜单：target 触发（父项/右键/hover | QMenu | interactive（交互） | 22/6/7 | `Nova/Controls/NovaMenu.qml` |
| 49 | **NovaNoSsr** | 延迟渲染壳：placeholder 文案/槽先显示，内容在 delay（默认下一帧）后切换 Nova 口径：QML 无 SSR 环境，语义落位为"客户端就绪延迟渲染"（骨架占位→内容），PARITY §0.14 留痕 | QNoSsr | decorative（装饰） | 4/0/0 | `Nova/Controls/NovaNoSsr.qml` |
| 50 | **NovaOptionGroup** | 选项组：checkbox/radio/toggle 三型统一、options 归一化、inline/纵向布局 对标 Quasar QOptionGroup（24 props 含继承 use-checkbox 18；N… | Quasar QOptionGroup | semantic（语义） | 21/1/2 | `Nova/Controls/NovaOptionGroup.qml` |
| 51 | **NovaPage** | 页面容器：NovaLayout 之页面象限内容包装，统一 padding，类型扫描后自动铺满页面区 | QPage | decorative（装饰） | 1/0/0 | `Nova/Controls/NovaPage.qml` |
| 52 | **NovaPagination** | 页码器 受控模式（坑位 22）：不自写 page —— pageRequested(next) 上报，宿主写回 | QPagination | interactive（交互） | 13/1/5 | `Nova/Controls/NovaPagination.qml` |
| 53 | **NovaParallax** | 视差滚动容器：媒体层随宿主滚动慢速位移（speed 因子）， scroll-target 缺省向上遍历找最近 Flickable（坑位 14：默认属性转交内部容器 parent 失真） | QParallax | decorative（装饰） | 6/1/1 | `Nova/Controls/NovaParallax.qml` |
| 54 | **NovaPopupEdit** | 就地编辑弹层：点击目标弹编辑器、autoSave、设置/取消按钮、校验 对标 Quasar QPopupEdit（13 props；Nova 收口核心 11 项，cover 覆盖定位留痕见 PARITY） | Quasar QPopupEdit | interactive（交互） | 12/6/4 | `Nova/Controls/NovaPopupEdit.qml` |
| 55 | **NovaPopupProxy** | 弹层路由：窗口宽/高较小者 < breakpoint → Dialog 形态（全屏卡片），否则 Menu 形态 内容槽共享：default 槽内容按当前形态 reparent 到对应形态容器；关闭后归还 受控契约：m… | QPopupProxy | decorative（装饰） | 17/6/7 | `Nova/Controls/NovaPopupProxy.qml` |
| 56 | **NovaPullToRefresh** | 下拉刷新：side 四边拉动（top/bottom/left/right，对标 2.30）、refresh 事件、trigger() 方法 拉动数学：从 side 边缘向内容方向拖拽 dist；pullProgres… | 事件驱动语义 | semantic（语义） | 10/1/1 | `Nova/Controls/NovaPullToRefresh.qml` |
| 57 | **NovaRadio** | 单选：val 匹配 modelValue、leftLabel、keepColor、键盘选择 对标 Quasar QRadio（12 props） | Quasar QRadio | interactive（交互） | 18/2/1 | `Nova/Controls/NovaRadio.qml` |
| 58 | **NovaRange** | 双值范围滑杆：左右滑块、step 量化、min/maxRange 约束、markers、气泡 对标 Quasar QRange（20 props；Nova 收口核心 17 项，aria/img 类留痕见 PARITY） | Quasar QRange | interactive（交互） | 42/2/4 | `Nova/Controls/NovaRange.qml` |
| 59 | **NovaResizeObserver** | 尺寸观察：target（默认声明父项）尺寸变化 → debounce → resize(w,h) | QResizeObserver | decorative（装饰） | 2/1/3 | `Nova/Controls/NovaResizeObserver.qml` |
| 60 | **NovaResponsive** | 等比例容器：ratio > 0 时强制 height = width / ratio， 内容铺满容器（use-ratio 组合函数 1:1；ratio 缺省时高度交给宿主/内容自定） | QResponsive | decorative（装饰） | 1/0/0 | `Nova/Controls/NovaResponsive.qml` |
| 61 | **NovaRow** | 栅格行：12 栅格水平排布 + wrap 换行 + justify/align 对齐，与 NovaCol 配合使用 | Quasar Flex row | decorative（装饰） | 4/0/1 | `Nova/Controls/NovaRow.qml` |
| 62 | **NovaScrollArea** | 滚动区域：内容超界出主题化滚动条 | QScrollArea | decorative（装饰） | 0/0/0 | `Nova/Controls/NovaScrollArea.qml` |
| 63 | **NovaSelect** | 下拉选择：options 归一化 / single+multiple / emitValue / useInput 过滤 / 下拉弹层 对标 Quasar QSelect（47 props；Nova 收口核心 24 … | Quasar QSelect | interactive（交互） | 18/3/3 | `Nova/Controls/NovaSelect.qml` |
| 64 | **NovaSeparator** | 分隔线：vertical 属性切换方向，颜色取 outline 令牌 | QSeparator | semantic（语义） | 5/0/0 | `Nova/Controls/NovaSeparator.qml` |
| 65 | **NovaSkeleton** | 骨架屏：type（rect/text/circle/square/badge/tag）× animation（wave/bounce/fade/none，对标 QSkeleton） wave = 渐变横扫；bounc… | QSkeleton | decorative（装饰） | 4/0/0 | `Nova/Controls/NovaSkeleton.qml` |
| 66 | **NovaSlideItem** | 滑动操作项： 正面内容（default 槽）左右滑动露出动作面板（leftSlot/rightSlot Component 槽（QSlideItem 的 left/right 撞 Item FINAL 成员改名，坑位… | QSlideItem · 基线 2.35.5 语义 | interactive（交互） | 8/4/3 | `Nova/Controls/NovaSlideItem.qml` |
| 67 | **NovaSlider** | 滑杆：拖拽/键盘取值、step 量化、snap 刻点、markers、label 气泡、垂直模式 对标 Quasar QSlider（use-slider 33 props；Nova 收口 26 项，img 类留痕见… | Quasar QSlider | interactive（交互） | 35/2/3 | `Nova/Controls/NovaSlider.qml` |
| 68 | **NovaSpace** | 占位空白 | QSpace | decorative（装饰） | 0/0/0 | `Nova/Controls/NovaSpace.qml` |
| 69 | **NovaSpinner** | 加载指示器：variant 八变体（ring/ball/dots/hourglass/gears/grid/radio/comment，对标 QSpinner 系列） Canvas 逐帧绘制口径：统一 Timer 驱… | QSpinner | semantic（语义） | 6/0/0 | `Nova/Controls/NovaSpinner.qml` |
| 70 | **NovaStep** | 步骤面板：name/title/caption/icon/prefix/done/error/disable + 状态图标覆盖（done/active/error 的 icon+color，'none' 退让 pre… | QStep | semantic（语义） | 18/0/0 | `Nova/Controls/NovaStep.qml` |
| 71 | **NovaStepper** | 步骤条：受控 modelValue / 头部导航（headerNav 逐项开关）/ 状态图标解析 1:1 对标 2.35.6 StepHeader.js（active > error > done；step 级优先 | QStepper | semantic（语义） | 30/3/5 | `Nova/Controls/NovaStepper.qml` |
| 72 | **NovaStepperNavigation** | 步骤导航槽容器：default 槽放 上一步/下一步等按钮；由宿主 NovaStepper 的 navigation 命名槽挂载渲染 | QStepperNavigation | semantic（语义） | 1/0/0 | `Nova/Controls/NovaStepperNavigation.qml` |
| 73 | **NovaTab** | 标签页单项：name/label/icon/alert + default 槽自定义内容 | QTab | interactive（交互） | 11/1/2 | `Nova/Controls/NovaTab.qml` |
| 74 | **NovaTabPanel** | 标签页面板：name 寻址 / disable | QTabPanel | decorative（装饰） | 3/0/0 | `Nova/Controls/NovaTabPanel.qml` |
| 75 | **NovaTabPanels** | 面板容器：受控 modelValue / animated / infinite / swipeable（DragHandler 被动抓取）/ vertical / transitionDuration | QTabPanels | decorative（装饰） | 8/3/3 | `Nova/Controls/NovaTabPanels.qml` |
| 76 | **NovaTable** | 数据表格 v0.11.0 基础：列定义/排序/过滤/分页/多选/展开行/grid 模式 v0.12.0 增强：虚拟滚动（virtualScroll + ListView 真虚拟化）/ 服务端模式 （serverSid… | QTable | interactive（交互） | 45/7/13 | `Nova/Controls/NovaTable.qml` |
| 77 | **NovaTabs** | 标签页容器：受控 modelValue、横向滚动 + 溢出箭头 （outside-arrows/mobile-arrows）、align（left/center/right/justify）、breakpoint 自… | QTabs | interactive（交互） | 24/1/3 | `Nova/Controls/NovaTabs.qml` |
| 78 | **NovaTd** | 单元格：文本/对齐/自定义内容 | QTd | decorative（装饰） | 3/0/0 | `Nova/Controls/NovaTd.qml` |
| 79 | **NovaText** | 排版组件 | Quasar text-h1…caption + text-weight-* + text-muted/italic/strike/no-wrap 工具类 | semantic（语义） | 6/0/0 | `Nova/Controls/NovaText.qml` |
| 80 | **NovaTh** | 表头单元格：文本/对齐/排序指示（受控模式：sortRequest 只上报） | QTh | interactive（交互） | 6/1/0 | `Nova/Controls/NovaTh.qml` |
| 81 | **NovaTime** | 时钟面盘：时/分/秒三面切换、24h/12h(AM/PM)、options 过滤、nowBtn 对标 Quasar QTime（14 props；Nova 收口核心 12 项，validator/defaultDat… | Quasar QTime | interactive（交互） | 18/1/11 | `Nova/Controls/NovaTime.qml` |
| 82 | **NovaTimeline** | 时间轴：tint 轴色 / side 左右停靠 / dense·comfortable·loose 三布局；default 槽为 NovaTimelineEntry 序列，条目经 _timelineRef 反向取宿主… | QTimeline | decorative（装饰） | 3/0/0 | `Nova/Controls/NovaTimeline.qml` |
| 83 | **NovaTimelineEntry** | 时间轴条目：heading 标题态 / icon·avatar 轴点 / title·subtitle·body 三段内容 + titleSlot/subtitleSlot 命名槽；布局参数取自宿主 NovaTime… | QTimelineEntry | semantic（语义） | 11/0/0 | `Nova/Controls/NovaTimelineEntry.qml` |
| 84 | **NovaToggle** | 开关：轨道+滑块换装 NovaCheckbox（复用三态/toggleOrder/val 全部值语义） 对标 Quasar QToggle（use-checkbox 18 + icon/iconColor） | Quasar QToggle | interactive（交互） | 3/0/0 | `Nova/Controls/NovaToggle.qml` |
| 85 | **NovaToolbar** | 工具栏：水平排布行、min-height 50、inset 内容缩进 | QToolbar | semantic（语义） | 2/0/0 | `Nova/Controls/NovaToolbar.qml` |
| 86 | **NovaToolbarTitle** | 工具栏标题：默认占满剩余宽度（shrink 反转收缩为内容宽） | QToolbarTitle | semantic（语义） | 3/0/0 | `Nova/Controls/NovaToolbarTitle.qml` |
| 87 | **NovaTooltip** | 工具提示：target 悬停（delay/hideDelay）、anchor/self/offset 定位、text 便捷或 default 槽 就地渲染口径：z 提升于声明处（PARITY §0.14 留痕：非 p… | QTooltip | semantic（语义） | 13/5/5 | `Nova/Controls/NovaTooltip.qml` |
| 88 | **NovaTr** | 表格行：选中高亮/点击上报（受控：selection 由宿主写回） | QTr | decorative（装饰） | 2/2/0 | `Nova/Controls/NovaTr.qml` |
| 89 | **NovaTransition** | 过渡包装组件 | Quasar q-transition--fade/scale/rotate/slide-*/jump-*/flip-* 共 16 种 | decorative（装饰） | 7/2/0 | `Nova/Controls/NovaTransition.qml` |
| 90 | **NovaTree** | 树控件 受控模式（坑位 22）：expanded/ticked/selected 均不自写，只 emit 由宿主写回 勾选策略：none（仅自身）/ strict（上下级联动+半选）/ lazy（仅向下联动已加载层）… | QTree | interactive（交互） | 29/5/11 | `Nova/Controls/NovaTree.qml` |
| 91 | **NovaVideo** | 视频嵌入包装：QtMultimedia Video 的皮肤化容器， ratio 默认 16/9 等比缩放，controls 常驻（QML Video 自带回放控件） | QVideo | semantic（语义） | 3/0/0 | `Nova/Controls/NovaVideo.qml` |
| 92 | **NovaVirtualScroll** | 虚拟滚动容器 items 数组 + delegate 组件 → 内部 ListView 真虚拟化（仅渲染可视窗口 + reuseItems） | QVirtualScroll | decorative（装饰） | 3/0/1 | `Nova/Controls/NovaVirtualScroll.qml` |
| 93 | **NovaVisible** | 断点显隐：above/below/only 三种语义按 NovaScreen 断点控制 visible | Quasar gt-*/lt-* 可见性工具类 | decorative（装饰） | 3/0/2 | `Nova/Controls/NovaVisible.qml` |

## 二、Behaviors · 行为（13 项）

| 序号 | 组件 | 说明 | 对标 Quasar | a11y | 属性/信号/方法 | QML 文件 |
|---:|---|---|---|---|---:|---|
| 94 | **NovaClosePopup** | 关闭弹层行为：点击宿主即关闭当前弹层栈的 N 层 | Quasar v-close-popup | decorative（装饰） | 7/1/2 | `Nova/Behaviors/NovaClosePopup.qml` |
| 95 | **NovaFocusRing** | 焦点环行为：键盘模态下为可聚焦控件绘制焦点环（WCAG 2.4.7 焦点可见 / 1.4.11 非文本对比）——Quasar 无对应，Nova 增强 | Nova 增强 / 无对应 | decorative（装饰） | 6/0/0 | `Nova/Behaviors/NovaFocusRing.qml` |
| 96 | **NovaIntersection** | 视口观察行为：进入/离开视口回调、阈值、once、rootMargin、once 再武装 | Quasar v-intersection | decorative（装饰） | 11/3/5 | `Nova/Behaviors/NovaIntersection.qml` |
| 97 | **NovaLiveRegion** | 状态播报区：把 NovaA11y.notice() 的状态消息真正说给屏读器（WCAG 4.1.3 Status Messages）——Quasar 无对应，Nova 增强 | Nova 增强 / 无对应 | decorative（装饰） | 2/0/2 | `Nova/Behaviors/NovaLiveRegion.qml` |
| 98 | **NovaMorph** | 元素形变行为： 同 group 的元素间形变过渡——morph() 时旧活动元素退出、ghost 影子从旧几何 形变至新元素几何、新元素显示（卡片展开为详情） | Quasar v-morph 指令 · 基线 2.35.5 语义 | decorative（装饰） | 7/2/2 | `Nova/Behaviors/NovaMorph.qml` |
| 99 | **NovaMorphPool** | 形变分组注册表（单例）：group -> 当前活动目标 Item NovaMorph 依赖它协调同名 group 的元素切换（旧隐/新显 + 几何形变） ── | Nova 增强 / 无对应 | decorative（装饰） | 0/0/4 | `Nova/Behaviors/NovaMorphPool.qml` |
| 100 | **NovaRipple** | 水波纹行为：作为子项挂载到任意 Item，color/duration 可定制 | Quasar v-ripple 指令 | decorative（装饰） | 2/0/3 | `Nova/Behaviors/NovaRipple.qml` |
| 101 | **NovaScrollFire** | 首次进入视口触发一次的行为：阈值可调、可再武装 | Quasar v-scroll-fire | decorative（装饰） | 5/1/1 | `Nova/Behaviors/NovaScrollFire.qml` |
| 102 | **NovaScrollObserver** | 滚动位置观察行为：滚动回调、方向、边界 | Quasar v-scroll | decorative（装饰） | 6/1/2 | `Nova/Behaviors/NovaScrollObserver.qml` |
| 103 | **NovaTouchHold** | 长按行为：按住时长阈值、触摸/鼠标各自灵敏度、位移即取消 | Quasar v-touch-hold | decorative（装饰） | 8/2/0 | `Nova/Behaviors/NovaTouchHold.qml` |
| 104 | **NovaTouchPan** | 拖动手势行为：方向/轴向过滤、首末标记、位移与增量、抓手光标 | Quasar v-touch-pan | decorative（装饰） | 10/1/0 | `Nova/Behaviors/NovaTouchPan.qml` |
| 105 | **NovaTouchRepeat** | 按住连发行为：按序列延迟重复触发、可接键盘按键 | Quasar v-touch-repeat | decorative（装饰） | 7/1/0 | `Nova/Behaviors/NovaTouchRepeat.qml` |
| 106 | **NovaTouchSwipe** | 快速滑动行为：速度阈值、触摸/鼠标各自最小距离、方向过滤 | Quasar v-touch-swipe | decorative（装饰） | 7/1/0 | `Nova/Behaviors/NovaTouchSwipe.qml` |

## 三、Services · 服务单例（16 项）

| 序号 | 组件 | 说明 | 对标 Quasar | a11y | 属性/信号/方法 | QML 文件 |
|---:|---|---|---|---|---:|---|
| 107 | **NovaApp** | 窗口服务单例：全屏/最大化/最小化、窗口标题、可见与激活状态 | AppFullscreen + AppVisibility + Meta | decorative（装饰） | 9/0/8 | `Nova/Services/NovaApp.qml` |
| 108 | **NovaDialog** | 全局对话框服务单例：27 项配置对账、五向定位、双按钮契约、关闭原因上报、句柄更新 | Dialog 插件 | decorative（装饰） | 5/0/6 | `Nova/Services/NovaDialog.qml` |
| 109 | **NovaDialogHandle** | 对话框句柄：show() 返回值，hide()/update()/ok()/cancel()/valid + 三信号 | createDialog 的链式句柄 | decorative（装饰） | 2/3/4 | `Nova/Services/NovaDialogHandle.qml` |
| 110 | **NovaI18n** | 国际化服务单例 基线事实（npm quasar@2.35.5 Lang 源码核实）： $q.lang.isoName / $q.lang.rtl / $q.lang.set(locale) / $q.lang.pro… | Quasar Lang 插件 $q.lang + vue-i18n 语义 | decorative（装饰） | 7/0/10 | `Nova/Services/NovaI18n.qml` |
| 111 | **NovaIntersectionPool** | 视口观察池单例：一个定时器驱动全部订阅者批量求值 | Quasar 2.30 共享 IntersectionObserver 池 | decorative（装饰） | 3/0/10 | `Nova/Services/NovaIntersectionPool.qml` |
| 112 | **NovaLoading** | 全局加载服务单例：引用计数并发、delay 防闪烁、局部/全屏、超时保护、三种 spinner | Loading 插件 | decorative（装饰） | 10/0/10 | `Nova/Services/NovaLoading.qml` |
| 113 | **NovaLoadingBar** | 命令式顶部进度服务单例：start/increment/stop 懒创建内部 NovaAjaxBar 挂 NovaOverlayHost（zTop 层）；无窗口时降级 no-op | LoadingBar 插件 | decorative（装饰） | 0/0/3 | `Nova/Services/NovaLoadingBar.qml` |
| 114 | **NovaLoadingHandle** | 加载句柄：show() 返回值，hide()/update() + valid/count（引用计数语义，Nova 增强） | Nova 增强 / 无对应 | decorative（装饰） | 5/0/2 | `Nova/Services/NovaLoadingHandle.qml` |
| 115 | **NovaNotify** | 全局通知服务单例：29 项配置对账、9 位位置栈、分组徽标、句柄更新、关闭原因上报 | Notify 插件 | decorative（装饰） | 9/0/12 | `Nova/Services/NovaNotify.qml` |
| 116 | **NovaNotifyAction** | 通知动作项：label/icon/tint/noDismiss + triggered() 信号或 handler 回调 | Notify actions 数组项 | decorative（装饰） | 7/1/0 | `Nova/Services/NovaNotifyAction.qml` |
| 117 | **NovaNotifyHandle** | 通知句柄：show() 返回值，dismiss()/update(props)/valid 三面 | Notify.create 返回的句柄函数 | decorative（装饰） | 2/0/2 | `Nova/Services/NovaNotifyHandle.qml` |
| 118 | **NovaOverlayHost** | 全局弹层宿主单例：把动态 Item 挂到窗口顶层 overlay 并按层叠令牌分配 z | Quasar createGlobalNode | decorative（装饰） | 2/0/7 | `Nova/Services/NovaOverlayHost.qml` |
| 119 | **NovaPlatform** | 平台信息服务单例：操作系统判定、触摸能力、移动/桌面/WebAssembly 分流 | Platform 插件 | decorative（装饰） | 14/0/2 | `Nova/Services/NovaPlatform.qml` |
| 120 | **NovaScreen** | 屏幕断点单例：xs/sm/md/lg/xl（600/1024/1440/1920），is/lt/gt 语义 1:1 对标 Quasar Screen 插件 | Quasar Screen 插件 | decorative（装饰） | 18/0/1 | `Nova/Services/NovaScreen.qml` |
| 121 | **NovaStorage** | 持久化服务单例：命名空间隔离、JSON 值序列化、Web Storage 别名、落盘到 ini | LocalStorage / SessionStorage | decorative（装饰） | 4/0/16 | `Nova/Services/NovaStorage.qml` |
| 122 | **NovaTheme** | 设计令牌单例：三级令牌体系、明暗双主题一键切换、运行时品牌换肤、0~5 级阴影 | Quasar brand + Dark 插件 | decorative（装饰） | 65/0/7 | `Nova/Services/NovaTheme.qml` |

## 四、Design · 设计层（4 项）

| 序号 | 组件 | 说明 | 对标 Quasar | a11y | 属性/信号/方法 | QML 文件 |
|---:|---|---|---|---|---:|---|
| 123 | **NovaA11y** | 可访问性单例：WCAG 2.1 AA 对比度数学、AA 兜底派生令牌、键盘焦点可见性语义、状态播报与语义词汇表 | Quasar 无——Nova 增强 | decorative（装饰） | 10/0/14 | `Nova/Design/NovaA11y.qml` |
| 124 | **NovaIconSet** | 图标集单例：14 套内置图标集全键 1:1、provider 注册表、图标名归一化解析器 | Quasar $q.iconSet + IconSet 插件 | decorative（装饰） | 23/0/11 | `Nova/Design/NovaIconSet.qml` |
| 125 | **NovaMotion** | 动效令牌单例 | Quasar --q-transition-duration/.3s + q-transition--* 12 种过渡 + q-animate--* 2 种动画 | decorative（装饰） | 20/0/3 | `Nova/Design/NovaMotion.qml` |
| 126 | **NovaUtils** | 工具层单例：colors 12 / date 21（formatDate 44 token）/ format 6 / is 5 / debounce / throttle / frameDebounce / uid … | Quasar utils | decorative（装饰） | 6/0/14 | `Nova/Design/NovaUtils.qml` |

## 五、Composite/LayoutShell · 组合组件（15 项根容器）（21 项）

| 序号 | 组件 | 说明 | 对标 Quasar | a11y | 属性/信号/方法 | QML 文件 |
|---:|---|---|---|---|---:|---|
| 127 | **NovaAIReport** | 智能报表工作台壳：对标带 + 诊断轨 + 主报表区 + 预测区间带 + 问数轨 + 审批闸门 + 浮层 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全槽共享 | 游标尺 / 因果鱼骨 / 行列刻度尺 / 置信区间带 / 问数双点 / 闸门横闩 / 单色系发丝 | decorative（装饰） | 22/3/3 | `Nova/Composite/LayoutShell/NovaAIReport.qml` |
| 128 | **NovaAgent** | 智能体任务执行工作台壳：任务列 + 编排画布 + 验证轨 + 审批闸 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全轨共享 | NovaAgent 八项准入控制 | decorative（装饰） | 19/3/3 | `Nova/Composite/LayoutShell/NovaAgent.qml` |
| 129 | **NovaBlankPage** | 纯净单页壳：居中阅读栏 + Header + Content + Footer，最克制的可定制基底（无侧栏 / 无标签导航） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零… | Nova 增强 / 无对应 | decorative（装饰） | 9/0/0 | `Nova/Composite/LayoutShell/NovaBlankPage.qml` |
| 130 | **NovaCardGrid** | 卡片网格壳：筛选工具条 + 网格骨架 + 分页状态栏 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5） | 组件画廊 / 模板市场 | decorative（装饰） | 9/0/0 | `Nova/Composite/LayoutShell/NovaCardGrid.qml` |
| 131 | **NovaChat** | AI 对话主窗口壳：六槽多轨工作台，组合态一致性契约（CC）落地标杆 组合态（宪法 0.9.0）：根内以 _ 私有 readonly 声明唯一组合上下文（密度/层级/动效/品牌色），六轨共享 | WorkBuddy 桌面端主窗口 | decorative（装饰） | 23/3/3 | `Nova/Composite/LayoutShell/NovaChat.qml` |
| 132 | **NovaCompare** | 双栏对比壳：中缝分隔 + 等宽双面板 + 控制栏 + 状态栏 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5） | 代码 / 配置 diff 工具 | decorative（装饰） | 11/1/1 | `Nova/Composite/LayoutShell/NovaCompare.qml` |
| 133 | **NovaCopilot** | 增强型协作面板壳：建议列 + 工作画布 + 动作闸门轨  组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全轨共享 | NovaCopilot 建议—确认—执行契约与 Draft/Confirm/Read-Only 三模 | decorative（装饰） | 16/3/3 | `Nova/Composite/LayoutShell/NovaCopilot.qml` |
| 134 | **NovaDE** | 数字员工岗位工作台壳：岗位条 + 任务队列 + 工作画布 + SLA 轨 + 人工交接条  组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全部轨共享 | NovaDE 四要件：岗位形态 / 任务队列 / 能力调用 / 队伍级治理 | decorative（装饰） | 19/3/3 | `Nova/Composite/LayoutShell/NovaDE.qml` |
| 135 | **NovaDesktop** | 桌面应用根壳：窗口控制点 + 菜单栏 + 工具栏 + 页面 + 状态栏，组合态一致性契约（CC）落地 组合态（宪法 0.9.0）：_ 私有组合上下文统一三栏密度/层级/动效；栏高归零 + 恒定锚链（CC-5，消除 v… | QMainWindow | decorative（装饰） | 11/1/0 | `Nova/Composite/LayoutShell/NovaDesktop.qml` |
| 136 | **NovaDrawerPanel** | 侧边滑出面板壳：单色系侧缘轨 + 抽象短条 + 非模态临时面板（区别于常驻 Sidebar） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5） | Nova 增强 / 无对应 | decorative（装饰） | 12/1/1 | `Nova/Composite/LayoutShell/NovaDrawerPanel.qml` |
| 137 | **NovaDualSide** | 双侧边工作台壳：左导航 + 中央画布 + 右属性，两侧独立折叠 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；两侧宽度归零 + 恒定锚链（CC-5） | Qt Designer / VSCode 三栏布局 | decorative（装饰） | 12/2/2 | `Nova/Composite/LayoutShell/NovaDualSide.qml` |
| 138 | **NovaFlexLayout** | 企业大屏弹性布局壳：columns 驱动的浮起面板网格 + 自适应分栏（HMI / 工控大屏），组合态一致性契约（CC）落地 组合态（宪法 0.9.0）：_ 私有组合上下文统一网格密度/层级/动效；header/fo… | Nova 增强 / 无对应 | decorative（装饰） | 11/1/0 | `Nova/Composite/LayoutShell/NovaFlexLayout.qml` |
| 139 | **NovaIncubator** | 应用孵化器工作台壳：全局栏 + 配方库 + 孵化舞台 + CARF 四阶段条 + 三重校验 + 封版证书 + 浮层 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，… | Nova 增强 / 无对应 | decorative（装饰） | 24/4/3 | `Nova/Composite/LayoutShell/NovaIncubator.qml` |
| 140 | **NovaMobile** | 移动应用根壳：安全区 + 灵动岛 + 内容 + 底部导航 + home indicator，组合态一致性契约（CC）落地 组合态（宪法 0.9.0）：_ 私有组合上下文统一安全区/头/底栏密度与动效；栏高归零 + 恒… | Quasar QLayout mobile | decorative（装饰） | 11/1/0 | `Nova/Composite/LayoutShell/NovaMobile.qml` |
| 141 | **NovaModal** | 模态弹窗壳：单色系顶条 + 抽象短条 + 浮起卡片 + 遮罩，ESC / 点遮罩关闭 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5） | Quasar QDialog | decorative（装饰） | 11/1/1 | `Nova/Composite/LayoutShell/NovaModal.qml` |
| 142 | **NovaOrbit** | 意图轨道工作台壳：全局栏 + 轨道态势栏 + 意图场 + 活产物画布（NovaChat 天花板形态） 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全轨共享 | Nova 增强 / 无对应 | decorative（装饰） | 22/3/3 | `Nova/Composite/LayoutShell/NovaOrbit.qml` |
| 143 | **NovaSetupWizard** | 安装配置向导壳：三态步骤时间轴 + 当前步内容 + 上一步/下一步控制区 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5） | Quasar QStepper | decorative（装饰） | 14/3/0 | `Nova/Composite/LayoutShell/NovaSetupWizard.qml` |
| 144 | **NovaSidebar** | 侧边导航工作台壳：单色系品牌渐变轨 + 浮起侧栏卡 + 五槽骨架 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5，消除 visible 三元跳变） | Quasar QLayout + QDrawer | decorative（装饰） | 14/1/1 | `Nova/Composite/LayoutShell/NovaSidebar.qml` |
| 145 | **NovaTabShell** | 标签页工作台壳：下划线激活指示条 + 标签栏 + 内容容器 + 状态栏 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5） | Quasar QTabs | decorative（装饰） | 8/3/0 | `Nova/Composite/LayoutShell/NovaTabShell.qml` |
| 146 | **NovaThreeColumn** | 三栏工作台壳：目录树 / 中列表 / 详情，三级深度色阶 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5） | 资源管理器布局 | decorative（装饰） | 13/1/0 | `Nova/Composite/LayoutShell/NovaThreeColumn.qml` |
| 147 | **NovaTopNavigation** | 顶部导航工作台壳：胶囊导航台 + 悬浮下拉 + 主内容 + 状态栏 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5） | Quasar QLayout header 导航 | decorative（装饰） | 11/1/1 | `Nova/Composite/LayoutShell/NovaTopNavigation.qml` |

---

## 统计

| 模块 | 数量 | 占比 |
|---|---:|---:|
| Controls · 控件 | 93 | 63.3% |
| Behaviors · 行为 | 13 | 8.8% |
| Services · 服务单例 | 16 | 10.9% |
| Design · 设计层 | 4 | 2.7% |
| Composite/LayoutShell · 组合组件（15 项根容器） | 21 | 14.3% |
| **合计** | **147** | **100%** |

a11y 契约分布：decorative 85 / interactive 33 / semantic 29。完整契约见 [A11Y_MATRIX.md](A11Y_MATRIX.md)（`scripts/check_a11y.py` 生成）。
