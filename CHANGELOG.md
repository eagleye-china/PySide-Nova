# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [0.13.0] - 2026-11-23

### Added（四期 Sprint A · **导航体系 14 类型一次收口**：L2 43% → 54%，Controls 59 → 73）

- **NovaTabs / NovaTab**（对标 QTabs/QTab）：受控 modelValue（Tab 点击只 emit，宿主写回——
  坑位 22 契约）；横向溢出滚动 + 溢出箭头（outside-arrows 占位 / mobile-arrows 强制）、
  align（left/center/right/justify）、breakpoint 自动 justify（默认 600）、垂直模式、
  指示条（narrow-indicator 内容宽 / switch-indicator 换侧）、dense、active-color→activeTint /
  active-bg-color / indicator-color、left/right-icon；NovaTab：name/label/icon/alert
  （true→红点 | 字符串→徽标）/alert-icon/no-caps（font.capitalization 实现）+ default 槽
- **NovaTabPanels / NovaTabPanel**（对标 QTabPanels/QTabPanel）：受控 modelValue、
  animated/infinite/swipeable（DragHandler 被动抓取）/vertical/transitionDuration；
  next/previous/goTo（name 或 index，禁用面板自动跳过）；beforeTransition/transition 事件；
  与 NovaTabs 共享宿主变量即可联动（受控契约）
- **NovaBreadcrumbs / NovaBreadcrumbsEl**（对标 QBreadcrumbs/QBreadcrumbsEl）：
  条目间自动插分隔符（separator 文本 / separatorDelegate 自定义模板）、separator-color、
  gutter 五档（none/xs/sm/md/lg/xl→0/4/8/16/24/48）、align 三档；**activeColor 语义
  1:1 对标 2.35.6 源码（QBreadcrumbs.js）**——作用于「中间的、未禁用」条目，
  最后一个（当前页）不着色；El：label/icon/disable/click + default 槽
- **NovaStepper / NovaStep / NovaStepperNavigation**（对标 QStepper/QStep/QStepperNavigation）：
  受控 modelValue、头部导航（总开关 headerNav × 逐步骤 headerNav × disable）、
  **状态图标解析 1:1 对标 2.35.6 StepHeader.js**——active > error > done 优先级、
  step 级 icon/color 覆盖 stepper 级、'none' 退让 prefix→icon/inactiveIcon、
  命名色映射（primary/secondary/…→NovaTheme 令牌）；垂直模式（contracted 只画圆点）、
  flat/bordered、alternative-labels、infinite、next/previous/goTo（禁用步骤跳过）；
  navigation 命名槽（NovaStepperNavigation 容器）+ message 槽（Component 模板）
- **NovaExpansionItem**（对标 QExpansionItem）：header（icon/label/caption 或 header 命名槽）+
  高度动画展开内容；**group 手风琴**（ExpansionGroups.js 注册表互斥收起——被收起方
  走自身 updateModelValue(false) 受控上报）；show/beforeShow/shown/beforeHide/hidden/
  afterShow/afterHide 全事件（show/hide 与 QML 内建语义撞名规避，坑位 25 口径）、
  show()/hide()/toggle() 方法；switch-toggle-side / expand-icon-toggle / dense-toggle /
  hide-expand-icon / expand-separator / popup / label·caption-lines / inset-level 系
- **NovaToolbar / NovaToolbarTitle**（对标 QToolbar/QToolbarTitle）：inset 缩进、
  min-height 50（$toolbar-min-height 1:1）；Title 默认撑满、shrink 收缩为内容宽
- **NovaFab / NovaFabAction**（对标 QFab/QFabAction）：direction 四向展开、
  **stagger 级联动画**（逐动作 Timer delay=idx×stagger，坑位 19 显式 start）、
  **hover 打开契约**（hoverDelay 进入延迟 / hoverHideDelay 离场宽限，命中区覆盖动作外溢范围）、
  external-label / label-position / vertical-actions-align / square、icon↔active-icon 旋转切换；
  受控 modelValue(bool) + updateModelValue + beforeShow/shown/beforeHide/hidden + show/hide/toggle；
  NovaFabAction：icon/label/tint/textColor/square/anchor/disable + clicked 信号 + click() 方法
- 画廊新增第 20 页「导航体系」（20 页）：Tabs+Panels 受控联动（禁用页跳过/alert 徽标）/
  Breadcrumbs 双形态 / Stepper 水平（navigation 槽上下步按钮）+垂直 contracted /
  ExpansionItem 手风琴 / Toolbar / Fab 向上级联
- 测试 250 → **271**：14 类型实例化冒烟 + 行为用例 7 个
  （Tabs 受控与禁用页 / Panels 联动+名称寻址+禁用跳过+过渡事件 / Stepper 序号寻址+
  禁用跳过+事件 / ExpansionItem 同组互斥异组不扰 / Fab 级联延迟与 Timer 显式启动 /
  Breadcrumbs 分隔符计数+点击+激活色语义 / 环境复检）

### Changed

- 基线复核：Quasar 2.35.5 → **2.35.6**（dist/api/*.json 逐文件 diff 零漂移，纯补丁版；
  基线维持 2.35.5 口径，审计仍逐项标注）
- 版本贴/概览页同步 0.13.0（Gallery 0.13.0；概览口径改"100 个公共类型"）
- 坑位 24/28 再验证：NovaStepper 状态色/图标经函数计算——绑定侧直读依赖
  （st.* + currentIndex）强制重评后调函数；派生步骤集合 _steps 平铺属性 + _rev 显式失效

### 固定（坑位沉淀）

- **33**：QML `Item` 无 `Component.onDestroyed`——析构钩子是 **`Component.onDestruction`**
  （NovaExpansionItem 组注销曾因此整文件加载失败）
- **34**：Text/Item 级基元元素**没有 `background` 属性**（那是 Control 系 API）——
  徽标底色须手写包裹 Rectangle
- 布尔型 JS `join(',')` 产出小写 `true/false`——测试断言须小写口径

## [0.12.0] - 2026-11-23

### Added（三期 Sprint B · **媒体体系十类型 + Table 增强一次收口**：L2 34% → 43%，Controls 49 → 59）

- **NovaImg**（对标 QImg）：占位图/错误图/延时转圈三态（loadingShowDelay 防缓存闪 spinner）、
  ratio/initial-ratio 宽高比派生、fit 五模式 + position 方位、alt→Accessible.name、
  slots：default 覆盖内容 / loadingSlot / errorSlot；**占位与错误图分层叠加**，
  规避 source↔status 互相依赖的绑定环
- **NovaResponsive**（对标 QResponsive）：ratio 等比容器（useRatio 语义 1:1，非法值视为无比例）
- **NovaVideo**（对标 QVideo）：QtMultimedia Video 皮肤化包装，ratio 默认 16/9，
  title→无障碍语义；**播放器惰性创建**——src 为空不实例化（坑位 31：
  无音频服务环境 FFmpeg 音频初始化挂死，空源本就只显示提示）
- **NovaParallax**（对标 QParallax）：媒体层随宿主滚动按 speed 因子慢速位移（progress 0→1），
  scroll-target 缺省向上遍历找最近 Flickable（坑位 14 语义）、refresh() 重测、
  scrolled({progress, contentY}) 事件、mediaSlot 作用域槽
- **NovaCarousel**（对标 QCarousel，受控 modelValue）：arrows / navigation（四向停靠）/
  navigation-icon / thumbnails 缩略图 / autoplay（数字 ms、true→5000、负数反向、到末页停）/
  infinite 回绕 / swipeable（**DragHandler 被动抓取**，不吞子内容点击）/ vertical / padding /
  transitionDuration；next/previous/goTo（name 或 index，禁用页自动跳过）；
  **NovaCarouselSlide**（name/disable/img-src 快速图片页）+ **NovaCarouselControl**
  （position/offset 覆盖控件，声明于轮播内部自动挂载覆盖层——坑位 14 向上遍历）
- **NovaTimeline / NovaTimelineEntry**（对标 QTimeline 族）：tint 轴色 / side 左右停靠 /
  dense·comfortable·loose 三布局；条目 heading 标题态 / icon·avatar 轴点 / title·subtitle·body
  + titleSlot/subtitleSlot 命名槽；轴连线条目自绘（延伸进 spacing 覆盖间隙，loose 左右交替成立）
- **NovaChatMessage**（对标 QChatMessage）：sent 收发镜像 / label 分组标签 / tint 气泡色 /
  name / avatar / text（字符串或数组→多条气泡）/ stamp（仅尾条）/ size 1~12 栅格宽；
  slots：default 正文 / avatarSlot / nameSlot / stampSlot / labelSlot
- **NovaTable 增强**（v0.12.0 承诺项）：**虚拟滚动**（virtualScroll + virtualScrollItemSize，
  表体切 ListView 真虚拟化、行结构 inline component 复用、表头独立常驻=天然粘性、scrollTo）；
  **服务端模式**（serverSide + rowsNumber + request 信号 {pagination, filter} +
  requestServerInteraction()/setPagination()/firstPage()，排序/过滤触发请求页码重置为 1）；
  **loading 覆盖层 + loadingLabel + noDataLabel**
- 画廊新增第 19 页「媒体体系」（19 页）：Img 三态 / Responsive / Video / Parallax 视差实机 /
  Carousel 全家桶实机（自动轮播+覆盖控件计数）/ Timeline / ChatMessage 收发对话 /
  虚拟表 1000 行 / 服务端表 137 条模拟取数（内联 SVG data URL 作离线图源）

### Changed

- 版本贴/概览页同步 0.12.0（Gallery 0.12.0；概览口径改"86 个公共类型"）
- NovaCarousel/NovaTable 暴露诊断只读位（controlLayerItem / autoRunning /
  virtualRowCount / virtualContentY / virtualContentHeight）

### 固定（坑位沉淀）

- **29**：inline component 裸名赋给 `delegate:`（如 `delegate: TableRow`）在 Qt 6.12 下
  **恒 count 0** 且零报错——必须带花括号实例化 `delegate: TableRow { }`
- **30**：创建期可见性求值时序会让 Column 定位器错过自动布局（委托 implicitHeight 恒 0），
  显式绑定 `height: childrenRect.height` 兜底（子项高度不依赖父高，无环）
- **31**：QtMultimedia `Video` 元素创建即初始化 FFmpeg 音频上下文，无音频服务环境（CI/沙箱）
  **进程挂死**——播放器必须按 src 惰性创建
- NovaImg 占位/错误图若走"source 随 status 切换"会成 source↔status 绑定环——改分层叠加
  （主图常驻 + 占位/错误图层按态覆盖）
- **32**：`ListView` 的 `reuseItems: true` 与含 NovaTr 的自定义 delegate 组合，在 Qt 6.12
  触发**进程退出段错误**（tests media_table_virtual 定位；包装 Component 亦不能规避）——
  NovaTable 虚拟滚动暂缓 reuseItems，cacheBuffer 预取兜底；0.11 的 NovaVirtualScroll
  （普通 Rectangle delegate）不受影响
- 坑位 28 再验证：函数调用绑定依赖不可靠在 `columns.map()`/`_flick` 探测场景重现——
  派生数据变更点一律走显式信号/句柄（onChildrenChanged/onScrollTargetChanged/onFilterChanged）

## [0.11.0] - 2026-11-23

### Added（三期 Sprint A · **数据体系九件 14 类型一次收口**：L2 24% → 34%，Controls 35 → 49）

- **NovaTable + NovaTh/NovaTd/NovaTr**（对标 QTable 基础面）：列定义（对象/字符串归一化）、
  三态排序（无序→升→降→无序，binaryStateSort 两态）、全字段过滤 + filterMethod 自定义、
  客户端分页（rowsPerPage/page/越界钳制）、多选/单选（表头半选态、全选/反选）、
  展开行（rowKey 键控 + expandSlot 上下文 rowData/rowIndex）、grid/flat 模式、
  底部计数与 NovaPagination 集成；**选中一律按键值比较**（坑位 27：Qt6 信号参数深拷贝）
- **NovaTree**（对标 QTree）：递归渲染、nodeKey/路径键双键制、strict 勾选级联
  （子全勾→父自动勾、反勾父→子全清、半选态）/lazy（仅向下联动）/none 三策略、
  懒加载（lazyLoad(node, done) → _resolveLazy 回填重建索引）、过滤保祖先链、
  defaultExpandAll、expandAll/collapseAll、dense
- **NovaPagination**（对标 QPagination）：maxPages 滑窗、ellipses 省略号、
  boundaryLinks 首末快捷（«»）、arrows 前后翻页、requestPage 越界钳制、
  受控 page（pageRequested 上报宿主写回）
- **NovaList / NovaItem / NovaItemSection / NovaItemLabel**（对标 QList/QItem 族）：
  separator 分隔线（NovaList 注入 listRef，最后一条不画）、dense、padding、
  **accordion 手风琴**（展开自动收起兄弟，expandRequested(false) 受控上报）、
  NovaItem 四槽（default/leading/trailing/expandContent——left/top 撞 Item FINAL
  属性改名，坑位 25 同款）、双行/三行布局、NovaItemSection avatar/thumbnail/trailing/topAligned、
  NovaItemLabel overline/caption/header/lines
- **NovaMarkupTable**（对标 QMarkupTable）：columns/rows 数组直渲 + title + dense/flat
- **NovaInfiniteScroll**（对标 QInfiniteScroll）：触底 offset 提前量、load(index, done)
  受控批次、done(true) 停止 / resume() 重新武装、内容不足视口自动补载
- **NovaVirtualScroll**（对标 QVirtualScroll）：items + delegate 组件、内部 ListView
  真虚拟化（reuseItems + cacheBuffer）、scrollToIndex 跳转、统一行高 itemSize
- **NovaScrollArea**（对标 QScrollArea）：内容超界双向滚动 + NovaTheme 明暗跟随滚动条

### Changed

- 画廊新增第 18 页「数据体系」（18 页）；BUILD_INFO/版本贴同步 0.11.0

### 固定（坑位沉淀）

- 27：**Qt6 信号参数会把 JS 对象/数组深拷贝**——组件与宿主之间传递选中行等对象数组时
  引用一致性丢失；选择语义一律按键值（rowKey 或 JSON 全等）比较，勿用 `===`/`indexOf` 引用比较
- 28：**绑定内经函数间接读取的依赖跟踪不可靠 + 递归索引漏层**——NovaTree 的
  `_index` 由 `_buildIndexInto` 生成时只递归 `children` 静态层，懒加载回填层（`_lazyStore`）
  永不入索引；且函数内读 `_lazyStore` 的重赋不触发重评。改为显式失效模式：
  `onNodesChanged/on_LazyStoreChanged/onFilterChanged → _refreshDerived()` + `_rev` 版本号
  供节点渲染绑定引用保刷新

## [0.10.0] - 2026-11-22

### Added（二期 Sprint B · **输入进阶八件一次收口**：L2 16% → 24%，Controls 27 → 35）

- **NovaRange**（对标 QRange 20 props 收口 17）：双值 {min,max}、左右滑块独立步进、
  step 双端量化、minRange/maxRange 间距约束、左/右气泡（left/rightLabelValue）、
  markers/markerLabels、vertical+reverse、点轨道跳最近滑块、changed() 提交信号
- **NovaDate 自研日历**（对标 QDate 23 props 收口 19）：Qt 6 无内置日历——全自研；
  单选/多选(multiple)/区间(range 三态点击 pending→闭合、逆序自动交换)、
  mask 任意格式（mask→正则解析 + formatDate 输出）、firstDayOfWeek、minimal 最小可选、
  options 函数过滤、navigationMin/MaxYearMonth 导航夹取、events 事件点（数组或函数）、
  todayBtn、noUnset、required
- **NovaTime 时钟面盘**（对标 QTime 14 props 收口 12）：Canvas 时/分/秒三面自动递进、
  24h/12h（AM/PM 切换偏移 +12h）、hourOptions/minuteOptions/secondOptions 过滤、
  nowBtn、内部恒 24h 制存储（对标基线）
- **NovaColorPicker**（对标 QColor 16 props 收口 13）：Canvas SV 色域盘（hue 底色 + 双向
  渐变）+ 色相条 + 调色板（palette 18 色）+ HEX 编辑框 + footer 值显示；formatModel hex/rgb；
  无默认值不产出（modelValue null 对标基线语义）；palette 属性因 Item 内建撞名改名 paletteColors
- **NovaOptionGroup**（对标 QOptionGroup 24 props 收口 21）：checkbox/radio/toggle 三型
  Loader 换装（复用七件值语义）、options 归一化（标量/对象 + optionValue/Label/Disable）、
  inline 横排、leftLabel、keepColor、disabled 选项拒选
- **NovaForm**（对标 QForm 5 props 1:1）：递归发现 validate() 能力子件、greedy 全量校验
  （默认短路）、noErrorFocus/noResetFocus、submit()/validate()/resetValidation()、
  validationSuccess/validationFailed 信号
- **NovaBtnToggle**（对标 QBtnToggle 31 props 收口 22）：options 单/多值、clearable 再点
  清空、选中 toggleColor 着色、未选中 outline/flat/push 变体、spread 均分、vertical、
  dense/rounded/size
- **NovaPopupEdit**（对标 QPopupEdit 13 props 收口 11）：点击目标就地弹层、editorData
  编辑槽、autoSave（无按钮，编辑即值）、buttons + labelSet/labelCancel、title、validate；
  set() 写值并关闭、cancel() 发 canceled；shown/hidden 信号（show/hide 因内建撞名改名）
- **画廊第 17 页**：输入进阶页（Range 约束演示/日历+时钟/取色器/选项组+按钮组/
  Form 聚合校验提交/PopupEdit 就地编辑），共 17 页
- **测试 174 → 199 项全绿**（14 条实例化冒烟 + 11 个行为用例：Range 量化约束/日期
  单选·区间·多选·导航夹取·minimal/时钟管道·AM/PM·options/取色 hex·rgb/选项组三型/
  Form 聚合·greedy/按钮组 clearable·多选/PopupEdit 值管道）

### 留痕（PARITY 同步）

- QDate validator/yearsInMonthView/QTime validator+defaultDate/QRange dragOnlyRange 与
  aria 类/QColor rgb·hsl 编辑器与 alpha 通道/QBtnToggle glossy·stack·stretch/QPopupEdit
  cover 覆盖定位、QSlider 家族 NovaKnob/NovaFile/NovaUploader——延后五期或留痕，逐项见
  docs/PARITY.md §Sprint B
- 坑位沉淀 24~26：`_norm` 缓存绑定在信号处理器重评期可返回 undefined（改直接函数调用）；
  `palette`/`show`/`hide` 与 Item 内建成员撞名（改 paletteColors/shown/hidden）；
  site-packages 残留 wheel 旧拷贝会让 pytest 走旧 QML（交付后须 `pip install -e .` 复位）

## [0.9.0] - 2026-11-22

### Added（二期 Sprint A · **表单核心七件一次收口**：L2 10% → 16%，统一契约落地）

- **统一表单契约**：`label / hint / error / readonly / disable / clearable / rules` 贯穿七件，
  对标 Quasar "表单手感"（QField use-field 29 props + use-validate 7 props 逐项对账）
- **NovaField 容器壳**（对标 QField）：浮动 label / 前后缀 / 样式四型（filled/outlined/standout/borderless）
  / dense+rounded+square / counter / loading / clearable / 底行 hint·error·counter 三位；
  **校验引擎**（对标 use-validate）：rules 数组（函数 + 内置字符串规则 required/minlen/maxlen/len/email）、
  lazyRules 失焦激活、reactiveRules、validate()/resetValidation()/validated()
- **NovaInput**（对标 QInput 8 props）：type text/password/number/int/textarea/email/tel/url/search、
  modelModifiers（number/trim/capitalize）、debounce 防抖提交、autogrow 多行自增高、shadowText、
  clearable、maxLength（Nova 增强）、autofocus；值通知走 modelValue 变更信号（对标 update:model-value）
- **NovaSelect**（对标 QSelect 核心子集 24/47）：options 归一化（标量/对象/optionValue·Label·Disable）、
  single/multiple + maxValues 上限、emitValue、displayValue、useInput 键入过滤、noOptionLabel、
  optionsDense/optionsCover、dropdownIcon；disabled 选项拒选；Popup 弹层（Controls）
- **NovaCheckbox**（对标 use-checkbox 18 props）：trueValue/falseValue/indeterminateValue 三态、
  toggleIndeterminate 半选入链（order 0: t→f→i→t / order 1: f→t→i→f）、val 模式、leftLabel、keepColor、
  **visual 插槽**（property Component，NovaToggle 换装复用同一套值语义）
- **NovaRadio**（对标 QRadio 12 props）：val 匹配、组联动受控模式
- **NovaToggle**（对标 QToggle）：轨道+滑块换装、icon/iconColor、复用 checkbox 全部值语义
- **NovaSlider**（对标 use-slider 33 props 收口 26 项）：min/max/step 量化、innerMin/innerMax、
  snap+markers+markerLabels、label 气泡（labelAlways/labelValue）、reverse/vertical、trackSize/thumbSize、
  键盘方向键/Home/End、changed() 提交信号
- **画廊第 16 页**：表单核心页（校验实时报错/样式四型/选择三态/受控模式组联动/滑杆刻度），共 16 页
- **测试 149 → 174 项全绿**（13 条实例化冒烟 + 12 个行为用例：契约校验/清空/防抖/lazyRules/
  选项归一化/多选上限/半选循环/val 模式/radio 组/开关/滑杆量化夹取/垂直步进）
- **local_deploy.py 新增 `--allinone`**：全量交付包一键生成（修复 0.8.0 包内 git 历史滞后 2 提交的
  交付缺陷；--allinone 须在最终提交后运行）

### Changed（语义对齐说明）

- **受控模式（Quasar 1:1）**：NovaCheckbox.toggle()/NovaRadio.select() 只发信号**不写自身 modelValue**，
  写回由宿主完成（对标 v-model 语义，规避 QML 绑定自环）；toggle()/select() 返回下一值便于宿主写回
- NovaSlider 按快照指令从二期 B（v0.10.0）提前至 Sprint A 交付；NovaForm/NovaBtnToggle/NovaPopupEdit/
  NovaOptionGroup 留待 v0.10.0（快照「下一步」清单为准）

### 留痕（PARITY 同步）

- QField standout 颜色参数/labelSlot/bottom-slots 插槽、QInput inputClass/inputStyle、QSelect 23 项
  （chips/虚拟滚动/menu 定制五 props/behavior 等）、QSlider img 类四 props 与 markerLabels-class——
  QML 不适用或二期后续补齐，逐项见 docs/PARITY.md §Sprint A
- 坑位沉淀 21~22：属性通知信号撞名（有 value 属性再声明 signal valueChanged 即报 Duplicate signal
  ——改走属性变更信号）；受控组件禁写自身 modelValue（绑定环）

## [0.8.0] - 2026-11-22

### Added（一期 Sprint 4 · **L0 设计语言 + L5 工具层一次收口**：L0 60% → 100%、L5 0% → 95%）

- **新增 `Nova.Design` 模块**（L0/L5 落位）：`NovaIconSet` / `NovaMotion` / `NovaUtils` 三个单例
- **NovaIconSet 图标集单例**（对标 `$q.iconSet` + IconSet 插件，npm 2.35.5 icon-set/*.js 逐键提取）：
  - **14 套内置图标集全键 1:1**（material-icons/-outlined/-round/-sharp、material-symbols ×3、
    mdi-v7、ionicons-v4、eva-icons、fontawesome-v6、themify、bootstrap-icons、line-awesome；
    mdi-v7 为基准 19 组 100 个语义键；material 系缺 editor.heading1~6/size1~7 共 13 键与基线一致，
    官方标注"可省略，回落 heading/size"）
  - 19 组语义属性直读（type/arrow/chevron/colorPicker/pullToRefresh/carousel/chip/datetime/editor/
    expansionItem/fab/field/pagination/rating/stepper/tabs/table/tree/uploader）+ `get(path, fallback)`
  - `set(obj)` 顶层浅合并 1:1（整组替换语义，与基线 Object.assign 一致）；`use(name)` 切换；
    `register(name, def)` 自定义集以 mdi-v7 全键补底；`available` / `keyPaths` 自检面
  - **provider 注册表**：`registerProvider/unregisterProvider/provider/providerUrl`，svg / ligature
    双通道；内置 15 个 provider 的 CDN 模板全部实测（2026-11-22，HTTP 200）；ionicons v4 类名 →
    v7 SVG 名称映射（md-X→X、ios-X→X-outline）；Eva 补 `-outline` 后缀；Line Awesome 实际分发
    `<name>-solid.svg`；FA6 改名内置 44 条别名表（home→house 等）；**themify 无逐图标 SVG 分发
    （实测 404），留痕需自备本地图标包**
  - **八通道归一化解析器 `resolve()`**（对标 QIcon.parseIcon 全语义）：`img:` / `svguse:`（unsupported
    留痕）/ `ion-*` 平台前缀 / `sym_[ors]_` / libMap 九前缀（mdi-/icon-/fa-/bt-/eva-/iconfont /ti-/bi-/i-）
    / FA 旧式类名（fas fa-home / las la-check）/ SVG path 直出（`&&` 多路径 + `|viewBox` + `@@style@@transform`）
    / `o_ r_ s_` 连字变体 / `set:name` 显式写法 / 非 ASCII 文本走文本通道（emoji 不再撞 CDN 404）
- **NovaIcon 升级**：改走 NovaIconSet.resolve + provider 注册表；渲染三通道 Image(SVG) / Text(连字
  与 emoji) / Shape+PathSvg（path 直出，viewBox 缩放）；本地图标包（NovaTheme.iconLocalRoot）优先
  → provider CDN 回落链路保留
- **NovaMotion 动效令牌单例**（对标 --q-transition-duration/.3s + transitions.sass + animations.sass）：
  时长七令牌（300/150/200/400…）、缓动八令牌（easingStandard=OutCubic 对标
  cubic-bezier(0.215,0.61,0.355,1)）、**15 种预设过渡表**（fade/scale/rotate/slide×4/jump×4/flip×4，
  enter-from 与 leave-to 非对称 1:1）、`speedFactor` 全局调速、`reducedMotion` 无障碍短路（Nova 增强，
  基线只覆盖 .animated）
- **NovaTransition 过渡组件**（Controls）：声明式包住任意内容，show 切换按预设播进场/离场动画；
  entered()/exited() 信号；flip 用 Rotation 轴旋转近似 perspective；reducedMotion 时长归零
- **NovaTheme 排版/高程令牌**：`typeScale` 12 级 1:1（rem×16→px、em 字距→px、Font 枚举字重；
  h1 96/96/-1.5/300 … caption 12/20/0.4/400）、`typeNames`/`textStyle()`、六档字重令牌（$text-weights）；
  `elevation` 0~24 级三层 umbra/penumbra/ambient 几何（QML 无多层 box-shadow，供 MultiEffect 组合）
- **NovaText 排版组件**（对标 text-h1…caption + text-weight-* + text-italic/strike 等）：typography
  12 级、muted/strike/italic/upper；大写小写走 QML 原生 font.capitalization（1:1 text-uppercase/lowercase/capitalize）
- **NovaUtils 工具层单例**（对标 `import { colors, date, format, is, extend, debounce, throttle } from 'quasar'`）：
  - **colors 12 函数 1:1**（rgbToHex/rgbToText/hexToRgb/hsvToRgb/rgbToHsv/textToRgb/lighten/luminosity/
    brightness/blend/changeAlpha + getPaletteColor 因 DOM 不适用留痕）；alpha 一律 0..100 百分制契约；
    changeAlpha 无 alpha 基准 0 等边界 1:1；Nova 增强 `contrastRatio`/`contrastColor`（WCAG 自动选字色）
  - **date 21 函数**：formatDate **44 token 全覆盖**（YYYY…x，序数/ISO 周/时区符号约定 1:1）；
    en-US/zh-CN 语言包内置；addToDate/subtractFromDate（月末日夹取，1/31+1月→2/28）、adjustDate/
    buildDate/startOfDate/endOfDate/getDateDiff/getDayOfYear/getWeekOfYear（纯 ISO）/getISOWeekYear/
    getDayOfWeek/isBetweenDates（opts 对象 1:1 + `'[]' '[)' '(]' '()'` 字符串写法为 Nova 增强）/
    isSameDate/daysInMonth/getMaxDate/getMinDate/getDateBetween/inferDateFormat/isValid/clone/extractDate
  - **format 6 函数**（humanStorageSize/capitalize/between/normalizeToInterval/pad/getDecimalsCount）
  - **is 5 函数**（isObject/isDate/isRegexp/isNumber/deepEqual）+ `extend`（deep 标志 1:1）+ `clone`
  - **debounce**（leading/trailing/maxWait/isPending/cancel/flush 1:1）、**throttle**（尾跑补齐、返回
    上次结果 1:1）、**frameDebounce**（16ms Timer 等价 rAF）、**uid**（v4 形态；QML 无 crypto.randomUUID，
    碰撞抗性弱于基线，PARITY 留痕）
  - **不适用留痕**：dom 9 项、event 14 项、scroll 12 项（QML Item 几何/MouseArea 信号/Flickable 原生）
- **画廊第 14/15 页**（L0 图标/排版/动效 + L5 utils）：图标集 14 套一键切换、语义键实时预览、
  八种写法对照、12 级字阶、动效预设演示、亮度梯度、对比度选字色、实时日期格式化、防抖节流真实交互
- **测试 114 → 149 项全绿**（新增 35 项：图标集 8 / 归一化 2 / provider 2 / 动效 4 / 过渡 1 /
  排版 2 / 高程 1 / colors 5 / format 1 / date 8 / is-extend 1 / debounce-throttle-frame-uid 3）

### Fixed
- NovaIcon 对 emoji/符号输入不再请求 CDN（404 噪音），改文本通道渲染
- gen_prompt.py 基线常量 2.26.0 → 2.35.5（与 0.4.2 纠正同步）

### 沉淀坑位（17~20，详见 CONSTITUTION/SESSION_HANDOFF）
17. V4 引擎下 `1<<24` 参与 `|` 位运算拼 hex 会串色 → 逐字节 toHex2
18. Animation 无 `enabled` 属性（NumberAnimation 用 from==to 兜底不参与）
19. `Component.createObject` 创建的 Timer 不自动启动，必须显式 start/restart
20. QML 无 requestAnimationFrame/crypto.randomUUID → frameDebounce 用 16ms Timer、uid 降级实现留痕

## [0.7.0] - 2026-11-22

### Added（一期 Sprint 3 · **L3 行为层九件一次收口**：L3 11% → 100%）

- **NovaIntersectionPool 共享观察池**（L3 基础设施，对标 2.30 共享 IntersectionObserver 池架构）：
  - 一个 Timer（pollInterval 34ms ≈ 30fps）驱动全部订阅者批量求值，N 个行为共享唯一驱动源；
    无订阅时零开销；`add/remove/clear/kick/tick` + `viewport()/nearestScrollable()/scrollPosition()/intersect()`
    公共几何工具
  - 实现路径差异（如实记录）：基线走浏览器原生 IntersectionObserver（异步、阈值边界通知），
    Nova 走"帧轮询 + 自算矩形交集（含祖先 clip 链）"——比例是精确值
- **NovaIntersection**（对标 v-intersection，Intersection.json 核实）：handler → `onIntersect/entered/exited`
  三信号；threshold 数字/数组；rootMargin 四向 real；once + `rearm()`（对标 setOnce 再武装）；
  `stop()`（对标 handler 返回 false）；entry 七字段 1:1（target/isIntersecting/intersectionRatio/
  boundingClientRect/intersectionRect/rootBounds/time）；祖先 clip 链计入可见区域
- **NovaScrollObserver**（对标 v-scroll）：`onScroll(details)` 给出 vertical/horizontal/deltaX/Y/
  direction/atTop/atBottom/atLeft/atRight；root 自动解析最近可滚动祖先（Flickable/ListView/GridView）
- **NovaScrollFire**（对标 v-scroll-fire）：进入视口触发一次（复用 NovaIntersection，同池同算法）；
  threshold 0~1（arg 语义）；触发后自动解除武装，`rearm()` 可再触发
- **NovaClosePopup**（对标 v-close-popup，ClosePopup.json 核实）：depth 语义 1:1（<0 全关 / 0 禁用 /
  N 关顶 N 层）；触发源自动桥接宿主 clicked 信号（向上找带 clicked 的祖先，NovaBtn 子项转交
  contentHost 也能命中）；`usePointer` 兜底指针通道；Enter 键触发（对标 keyup 13）
- **NovaOverlayHost 弹层栈**（Nova 增强，对标 portal 链 + closePortals）：
  `registerPopup/unregisterPopup/popupCount/popups/closePopups(depth, reason)/topPopup`；
  **NovaDialog 已接入**（show 进栈、_forget 出栈），ClosePopup 的"层"因此有真实语义
- **NovaTouchPan**（对标 v-touch-pan，TouchPan.json 核实）：details 十一字段 1:1（evt/touch/mouse/
  position/direction/isFirst/isFinal/duration/distance/offset/delta）；修饰 horizontal/vertical/
  up/right/down/left → `horizontal/vertical/directions`；mouseAllDir → `allDirections`；
  preserveCursor → `preserveCursor`；stop/prevent → `stopPropagation/preventStealing`
- **NovaTouchSwipe**（对标 v-touch-swipe）：arg "6e-2:6:50" → `minVelocity/touchMinDistance/
  mouseMinDistance` 三属性；移动中即触发 + 松手兜底；direction/duration/distance/velocity
- **NovaTouchHold**（对标 v-touch-hold）：arg "600:5:7" → `duration/touchSensitivity/
  mouseSensitivity`；位移超灵敏度取消 + `onCancel` 通知（增强）；`progress` 进度源 `holding`
- **NovaTouchRepeat**（对标 v-touch-repeat）：delays 序列 "0:600:300"（末值复用、0 延迟防自旋）；
  details 九字段含 keyboard/keyCode/repeatCount/startTime；`keys` 数组接键盘（默认 Space/Enter）
- 内核 **NovaTouchCore**（internal）：四个 touch 行为共享同一套指针生命周期/坐标/时间/阈值/
  触摸来源判定（MultiPointTouchArea 探测真实触摸 + MouseArea 合成事件），避免四份实现各自漂移
- 画廊第 13 页"L3 行为指令"：懒加载（ScrollFire 触发变色 + Intersection 比例实时显示）、
  滚动位置/方向/到底、拖动方块（松手回弹）、四向划动、长按 600ms、按住连发、
  弹层栈按层关闭 + 对话框内容内真实 ClosePopup 关闭按钮
- 冒烟测试 91 → **114 项全绿**（新增 23：九件实例化 10 + Intersection 4 + Scroll 2 +
  Touch 4 + ClosePopup/弹层栈 3）

### Fixed（Qt 6.12 / PySide6 实战坑位沉淀）

- **Item 的 FINAL 属性不可覆盖**：QML 派生 Item 里声明 `property real x/y`、`property bool active`
  报 "Cannot override FINAL property"（x/y/active 是 Qt 6.12 的 FINAL 成员）——
  行为层改用 posX/posY/gesturing；`enabled` 同理不重声明，直接用 Item.enabled（继承语义天然正确）
- **visible:false 的 Item 不参与事件分发**：行为根节点若设 visible:false，内部 MouseArea 彻底失灵——
  纯逻辑行为可关，带指针通道的行为绝不能关（Item 无 visual 本就不渲染，无需隐藏）
- **组件默认属性转交内部容器**：NovaBtn 把子项塞进 contentHost，子项的 `parent` 不是按钮本体，
  `target: parent` 拿不到 clicked 信号 → ClosePopup 向上遍历找第一个带 clicked 的祖先
- **QML Window 的 Python wrapper 调不到 QML 函数**：PySide 把 QQuickWindow 包装成 QWindow
  （metaobject 里没有 QML 定义的方法）——测试用 QML 侧 QtObject 代理（call0/1/2 + val）统一调用，
  代理同时强引用窗口防 JS GC 回收
- **观察器重订阅必须重交付**：IntersectionObserver 只报"变化"，重新 observe 才会补一帧
  当前状态——`_start()` 时重置上次判定，否则 rearm 后永远等不到回调（基线 reobserve 同款注释）
- **QML 函数无可选参数**：Qt 6 的 QML 函数按固定形参暴露给 PySide（缺参即 TypeError）——
  代理拆成 call0/call1/call2 按实参个数分派

## [0.6.2] - 2026-11-22

### Added（一期 Sprint 2 收口 · **一次交付四件**：NovaLoading / NovaStorage / NovaApp / NovaPlatform —— L4 12% → 44%）

- **NovaRuntime Python 后端**（独立模块 `Nova.Runtime`，C++ 侧注册）：
  - ini 存储后端：QSettings 文件级落盘（`AppDataLocation/nova-storage.ini`），
    **不依赖 organizationName**（纯 QML 的 Settings 类型在无 org 标识时直接失效，故下沉 Python）
  - 平台探测：os / osVersion（prettyProductName）/ cpuArch / kernelType / isMobile /
    hasTouchscreen（QInputDevice 枚举 TouchScreen，Qt 6 无 QML 级 API）
- **NovaLoading**（对标 Loading 插件，npm 2.35.5 `dist/api/Loading.json` 逐项核实 **11 项**）：
  - 配置：delay / message / group / spinnerSize / spinnerColor→spinnerTint / messageColor→messageTint /
    backgroundColor→backgroundTint / spinner→spinnerModel（ring/dots/pulse）✅；html / boxClass / customClass ⛔（留痕，boxed 布尔映射）
  - **引用计数（Nova 增强）**：同组并发 show 不互踩，句柄 `hide()` 只释放自己那一份，归零才收口；
    `hide(group)` 对标基线语义 = 无视计数整组强杀
  - delay 防闪烁（默认 500，对标基线）；delay 窗口内 hide 从未显示即销毁
  - `target` 局部加载（挂任意 Item 内铺满）/ `timeout` 卡死兜底（默认关）/
    `increment / decrement / count / activeGroups / activeCount / isActive / hideAll / setDefaults` 内省面
  - 视觉层 `NovaLoadingOverlay`（internal）：Canvas 圆环（底环 16% + 270° 弧）、三点缩放、呼吸圆；
    明暗双主题遮罩自适应；句柄 `NovaLoadingHandle`（hide/update/valid/count/item）
- **NovaStorage**（对标 LocalStorage 插件）：
  - 全 API 面：`set/get/has/remove/clear/getAll/getAllKeys/getLength/isEmpty/setAll`
    + Web Storage 别名 `setItem/getItem/removeItem`
  - **命名空间隔离（Nova 增强）**：`useNamespace(name)` 切换即落盘旧空间、加载新空间
  - 真持久化：写入后由全新 QSettings 实例读回验证（测试 `test_storage_persistence_to_disk`）
  - JSON 损坏安全降级（按空空间载入不崩）；getAll 深拷贝防外部改库
- **NovaApp**（对标 AppFullscreen + AppVisibility + Meta）：
  - `request/exit/toggle/isFullscreen/isCapable`（全屏三件套 1:1）；
    `setVisibility` 统一入口：fullscreen/maximized/minimized/windowed；
    退出全屏自动回落进入前状态；`setTitle`（document.title → 窗口 title）；`show/hide/isVisible/isActive`
- **NovaPlatform**（对标 Platform 插件）：
  - `isWindows/isMac/isLinux/isAndroid/isIOS/isWasm/isMobile/isDesktop`；
    `hasTouch` 走后端输入设备枚举（桌面触摸本真实可得）；浏览器专属项
    （webAuthn/within.iframe/pwa/electron/内核判定）⛔ 不适用留痕
  - Nova 增强：`osVersion / cpuArch / describe() / snapshot()`
- 画廊第 12 页 "**Loading / Storage**"：全屏加载自动收口、引用计数 ±1 演示、局部加载、
  三种 spinner、Storage 读写/清空快照、窗口控制、平台信息（全程真实组件可交互）
- 冒烟测试 71 → **91 项全绿**（新增 20 项：Loading 10 + Storage 7 + Platform 1 + App 2）

### Fixed（Qt 6.12 / PySide6 实战坑位沉淀）

- **qmlRegisterSingletonInstance 所有权坑**：QML 树按 JS 所有权管理实例，组件销毁即 delete
  Python 侧对象，二次访问报 "Internal C++ object already deleted"；且全局单实例无法被多个
  QQmlEngine 安全共享 → 改用**工厂式 `qmlRegisterSingletonType`**（每引擎惰性创建，PySide 不留悬空引用）
- **单例引用裸 JS 对象无属性通知**：Loading 的活动组条目最初用裸 JS 对象，句柄 valid/count 绑定
  不随状态刷新 → 升级为 QML QtObject 条目（property Component 内联，Qt 6.12 坑位惯例）
- **overlay 可见性与宿主冲突**：NovaOverlayHost.attach 强制 visible=true，与 Loading 的
  delay 门控打架 → 可见性改由内部 `_started` 门控（delay 期间子项不渲染、遮罩不拦点击）

## [0.6.1] - 2026-11-22

### Added（一期 Sprint 2 · L4 服务层第二件：NovaDialog）

- **NovaDialog 命令式对话框**（对标 Dialog 插件，npm 2.35.5 `dist/api/Dialog.json` 逐项核实 **27 项**）：
  - `show(opts)` → 链式句柄 `NovaDialogHandle`：`hide()` / `update()` / `ok()` / `cancel()` / `valid`
  - 三个信号：`accepted` / `rejected` / `dismissed(reason)`（reason 五值 ok/cancel/backdrop/escape/api）
  - 五向定位 standard/top/right/bottom/left；非法值直接拒绝
  - 关闭策略三档：`persistent` / `noEscDismiss` / `noBackdropDismiss`
  - 形态：`seamless` / `maximized` / `fullWidth` / `fullHeight` / 进度态
  - 按钮三态归一（true/false/string/对象）+ `stackButtons`
  - `contentDelegate` 替代基线 `html`；`setDefaults()` 深合并；`count()`/`hideAll()` 内省
- 画廊新增"NovaDialog 对话框"页：基础/危险/仅确定、persistent/seamless/全宽/最大化、
  五向定位、进度态 + 句柄 update 收尾、自定义内容（TextField）
- 冒烟测试 63 → **71 项全绿**（新增 8 项：ok/cancel 原因、persistent 双锁、noBackdrop/noEsc 分离、
  setDefaults+update、五向定位、seamless/progress/dark、链式回调、hideAll）

### Notes

- **归属纪律再确认**：`dismissed(reason)` 在 Dialog/BottomSheet 是基线 2.28 真 parity；
  在 Notify 是 Nova 增强——两处已分栏标注，防止再混
- 基线 DOM 专属项（class/style/html/noRouteDismiss）⛔ 留痕不移植；prompt/options/component 标 🚧 待二期

## [0.6.0] - 2026-11-22

### Added（一期 Sprint 2 · L4 服务层第一件：NovaNotify + NovaOverlayHost —— 七层 L4 从 0% 到 6%）

- **NovaOverlayHost**（全局弹层宿主单例）：动态 Item 挂载窗口顶层 + 层叠分配；
  自动跟随 `NovaScreen.source` 定位窗口（Window.contentItem / Item.window 双路解析），
  Dialog/Loading 直接复用，不再各自造宿主
- **NovaTheme 层叠令牌族入册**：`zFab 990 / zSide 1000 / zMarginals 2000 / zFixedDrawer 3000 /
  zFullscreen 6000 / zMenu 6000 / zTop 7000 / zTooltip 9000 / zNotify 9500 / zMax 9998`
  （对标 Quasar `$z-*` 数值 1:1，宪法第 5 章补充条款：弹层 z 值禁止魔法数值）
- **NovaNotify**（L4，对标 Notify 插件）：29 项配置逐项对账（npm quasar@2.35.5 包内源码 +
  dist/api/Notify.json 核实）；9 位定位（top 系头插 / bottom 系尾插 / 侧向中线插入）；
  分组徽标（组键 message|caption|multiLine|label*icon…|position 逐条复刻）；动作按钮
  （NovaNotifyAction：triggered 信号 + handler 回调双通道）；超时进度条（时长 = timeout+1000
  与消失时刻对齐）；句柄 `NovaNotifyHandle`（dismiss / update / valid）
- **Nova 增强（PARITY 增强栏）**：`dismissed(reason)` 6 值 timeout/user/action/api/replaced/overflow；
  `maxVisible`（默认 5，同屏上限）；`countAt()/dismissAll()` 队列内省；`triggerAction(i)` 程序化触发
- **NovaNotifyAction / NovaNotifyHandle** 公开导出；`NovaNotificationItem` 内部导出（internal）
- 画廊新增"**NovaNotify 通知**"页（类型预设 / 9 位定位 / 动作与关闭原因 / 分组徽标 / 句柄
  ongoing 进度更新，全程真实组件可交互）；Demo 页新增通知卡片区
- 冒烟测试 46 → **63 项**（解析用例 + 行为级断言：分组徽标/组键含 actions/自定义组替换/
  更新语义拒绝与放行/动作点击顺序/closeBtn user/overflow 淘汰/timeout 到期/非法输入回落/Dark 实例化）

### Changed

- **方法论入册执行首例**：API 对账以 npm 包源码与 dist API JSON 为准（0.5.1 新颁纪律）——
  本轮实机核对发现 npm 当日最新 2.35.6 的 Notify 与 2.35.5 逐字节相同，基线无需返工
- 库存契约文档（资料库）同步落定：D1/D2/D6 采纳、D3 红线确认、D4 内置最小转圈、D5 不暴露 ignoreDefaults

### Fixed

- 0.4.2 审计归属二次澄清落地：PARITY 增补 NovaNotify 审计节，"关闭原因上报"在 Notify 上
  明确标为 Nova 增强（基线 `onDismiss()` 无参数），杜绝后续误打勾

## [0.5.1] - 2026-11-22

### Changed（NovaNotify 契约裁定落盘 —— 新会话 npm 源码级核对成果固化）

- **D1 采纳**：NovaNotify 做 Nova 增强 `dismissed(reason)`（5 值
  timeout/user/action/api/replaced），PARITY 标"增强"栏，**不入已对齐栏**
- **D2 采纳**：`html` 不移植（QML 无 DOM 且基线该选项自带 XSS 面），改 `contentDelegate`
- **D3 确认**：基线 `onDismiss` 撞 on\* 红线，改为信号 `dismissed`，无商量余地
- **D6 采纳**：`NovaOverlayHost` 宿主抽件**提前至 Sprint 2**（overlay 层叠令牌 + 位置栈
  9 位插入先跑通，避免 Sprint 3 Dialog 位置栈返工）
- 归属修正：`关闭原因上报` 仅属 Dialog/BottomSheet（2.28）；**Notify 无关闭原因**
  （npm 2.35.5 源码核实 `onDismiss()` 无参数），0.4.2 审计表补澄清注
- 基线快照：npm 当日最新 2.35.6，其 Notify 与 2.35.5 逐字节相同，无需返工
- 修正 MASTER_PLAN 笔误："NovaDialog 服务式 v0.6.0 已交付" → "服务式 API 于 Sprint 2 交付"
- 方法论入册：**API 对账以 npm 包源码/dist API JSON 为准，不按文档页凭记忆写**
  （文档页漏 `ignoreDefaults` 即为例证）

## [0.5.0] - 2026-11-22

### Added（一期 Sprint 1 · L1 布局系统 —— 生态七层 L1 从 0% 到 100%）

- **布局五件套**（L1，对标 QLayout 系列）：
  `NovaLayout`（四象限骨架，子项按类型自动归位，push/overlay 双模式 + 断点自动收起）、
  `NovaHeader`（顶栏，tint + 默认槽）、`NovaFooter`（底栏）、
  `NovaDrawer`（left/right、mini 悬停展开、overlay、breakpoint、bordered、宽度动画）、
  `NovaPage`（页面容器 + padding）
- **栅格三件套**（L5/L1，对标 Quasar Flex 栅格）：
  `NovaRow`（12 栅格水平排布、wrap 换行、justify/align 对齐）、
  `NovaCol`（cols 1~12、offset 推挤、gutter）、
  `NovaVisible`（above/below/only 断点显隐，对标 gt-*/lt-*/*-only 工具类）
- 画廊新增"**NovaLayout 布局**"页：6 种经典布局迷你示例（后台/看板/表单/详情/登录/空态），全部真实组件可交互
- 冒烟测试 32 → **46 项**（新增四象限归位/push 让位/断点自动收起/栅格数学/NovaVisible 语义等行为级断言）

### Changed

- `NovaLayout.pageArea` 只读暴露页面区引用；`drawerOpen` / `openDrawer()` / `closeDrawer()` / `toggleDrawer()` 抽屉控制 API
- PARITY 新增布局五件套 + 栅格三件套审计节（基线 2.35.5）；reveal/elevated/断点响应式 cols 等 🚧 项如实标注 M2

### Notes

- 断点收起策略由宿主 NovaLayout 执行（NovaDrawer 创建期 parent 宽度是瞬态值，不可自判）——已沉淀为坑位经验
- 距宪法 24 条封版验收：L1 布局层达成 100%，L5 可见性/栅格从 0% 起步覆盖

## [0.4.2] - 2026-11-22

### Fixed（基线漂移纠正 —— 用户截屏立功）

- **对标基线 2.26.0 → 2.35.5**：经官方 GitHub releases 复核（v2.35.5 发布于 2026-11-17），
  原 0.4.0"核实"的 2.26.0 为过期结果；宪法第 0 章新增**基线复核条款**：
  每期开工第一天必须先核对官方最新 release
- `ECOSYSTEM_PARITY.md` 新增 §0.5 基线漂移审计（2.26→2.35 增量对照表）：
  Quasar 无新增组件（对账 76 项不变），生态层 6 类增量全部落入 MASTER_PLAN

### Changed（增量审计落入各期 DoD）

- 一期 Sprint 1：NovaScreen 补 `orientation`（对标 2.35 Screen API）
- 一期 Sprint 3：NovaIntersection 采用**单例 observer 池**（对标 2.30 useIntersection 复用架构）
- 二期：NovaSelect 补 hover 契约 / no-option-label / dialog 关闭按钮（对标 2.26~2.28）
- 四期：NovaFab 补 stagger 级联 + hover 打开；NovaPullToRefresh 补 side 四边拉动；
  NovaDialog/NovaBottomSheet 补**关闭原因上报**（cancel/backdrop/escape/programmatic，对标 2.28）
- 五期：**新增 L6 项"Nova MCP server + AI-ready 离线文档"**（对标 2.33 @quasar/mcp 全新品类，
  AI agent 精确查询版本化 API，杜绝幻觉）；供应链门禁补外部输入消毒（对标 2.32~2.35 安全硬化）

## [0.4.1] - 2026-11-21

### Added（全生态开发总规划 —— 六期战略图）

- **`docs/MASTER_PLAN.md`**：全生态开发总规划，覆盖 Quasar 2.26.0 全生态（组件 76 项 /
  指令 11 项 / 插件 15 项 / 图标 8 套 / 工具 / 工程化），分 **六期** 稳步推进：
  一期生态骨架（0.5.0~0.8.0）→ 二期表单与选择（0.9.0~0.10.0）→ 三期数据与媒体
  （0.11.0~0.12.0）→ 四期导航弹层反馈（0.13.0~0.14.0）→ 五期长尾+非功能（0.15.0~0.16.0）
  → 六期封版 `1.0.0-flagship`；总周期约 28 周（单人节奏含缓冲）
- 每期含：生态层归属、逐组件关键能力表、**冒烟测试验收标准**、测试数量轨迹
  （32 → 240+，封版覆盖率 ≥85%）
- **冒烟测试纪律制度化**（规划第 7 节）：七条统一模板，每个 Sprint 交付时逐条执行
- **全量对账表**（规划第 8 节）：Quasar 全生态 → Nova 命名 → 归属期，覆盖率对账
  组件 76/76、指令 11/11、插件 15/15（含 ⛔ 不适用留痕：AddressbarColor/Cookies/v-mutation）
- 风险对策表：NovaDate 自研日历、NovaTable 复杂度拆两次交付、单人节奏波动等

### Changed

- ROADMAP 增加指向 MASTER_PLAN 的入口说明（总规划为准，路线图保留 P0/P1/P2 分级视角）

## [0.4.0] - 2026-11-21

### Added（生态完整性 —— 封版前最后一块拼图）

- **`docs/ECOSYSTEM_PARITY.md` 生态对标白皮书**：以七层模型（L0 设计语言 / L1 布局 /
  L2 组件 / L3 指令 / L4 插件·服务 / L5 工具层 / L6 工程化）审计 Quasar 2.26.0 全生态，
  给出各层成熟度评分（当前 60%/0%/10%/11%/0%/0%/70%）、逐层差距表、
  **12 项 P0 空白清单**（含验收标准）、非功能门禁、重排后的里程碑、**24 条封版验收清单**
- 宪法新颁**第 10 章 生态完整性（七层模型）**：交付物必须标注所属层；
  优先级纪律"骨架 > 服务 > 行为 > 组件"；禁止"组件堆满、生态空心"
- ROADMAP 按生态层重排交付顺序（L1 → L4 → L3 → L0/L5 → L2 → L6）

### Changed

- M1 范围重定义：从"组件攻坚"改为"生态骨架"四个 Sprint
  （布局五件套 → 服务六件套 → 行为四件套 → 图标/工具/动效）

### Notes

- 核心判断：Quasar 的"生态味"主要来自 **L1 布局、L3 指令、L4 插件、L5 工具类**（当前合计 0%），
  而非组件数量；补齐这四层才叫"用起来像 Quasar"，否则只是"长得像"

## [0.3.4] - 2026-11-21

### Changed（接续方式精简为单文件）

- `PROMPT.md` 改为**自包含**：交接快照全文内联，新会话只需粘贴这一个文件，
  不再要求预先翻 `SESSION_HANDOFF / CONSTITUTION / PARITY / CHANGELOG`
- 宪法/PARITY/CHANGELOG/ROADMAP 改为"**按需深读**"表格（涉及对应主题时再打开）
- `gen_prompt.py` 升级：快照正文自动内联（H2→H3 嵌套、剥离引用块），
  输出**内容指纹**（SHA256 前 12 位）；`--check` 由"版本号比对"升级为"指纹比对"
- 宪法第 9 章新增第 4 条：SESSION_HANDOFF 为唯一事实源，PROMPT.md 为其单文件投影
- SESSION_HANDOFF 陈旧状态修正（0.3.1 → 0.3.4）并清理重复条目

## [0.3.3] - 2026-11-21

### Fixed（交付包完整性加固）

- 发布 ZIP 补齐 `PROMPT.md`（此前漏打，接续提示词不在包内）
- 发布 ZIP 默认纳入完整 `.git` 历史（此前遗漏，异地灾备承诺未兑现）
- 新增 `BUILD_INFO.txt` 构建清单（版本/构建时间/git HEAD/文件总数/校验方式）
- 新增旁路 `*.sha256` 校验文件：下载后可核对指纹，杜绝传输截断导致的“包变小”误判
- 新增 `--bundle`：ZIP 内附加 `icons/` 离线图标全量包（约 30MB，完全离线部署）
- 新增 `--no-git`：按需剔除 git 历史以减小体积

## [0.3.2] - 2026-11-21

### Added（跨会话永续开发闭环）

- `docs/templates/SESSION_HANDOFF_TEMPLATE.md`：交接快照通用模板（{{占位符}} + 使用说明）
- `docs/templates/PROMPT_TEMPLATE.md`：会话接续提示词模板（上下文恢复 → 汇报 → 硬约束）
- `scripts/gen_prompt.py`：**根据交接快照实时更新提示词** —— 提取快照版本/日期/git HEAD，
  从模板生成项目根目录 `PROMPT.md`；`--check` 模式校验同步性（可入 CI 门禁）
- 宪法第 9 章交付纪律升级：每次交付 = 升版 → CHANGELOG → 宪法记录 → SESSION_HANDOFF →
  **gen_prompt 刷新 PROMPT** → 一键 ZIP

## [0.3.1] - 2026-11-21

### Added（基础夯实轮 —— 磨刀不误砍柴工）

- 测试护栏补齐：Dark 插件 API 测试（`isDark` / `setDark` / `toggleDark` 翻转 / `dark` 品牌色令牌）、
  demo 完整加载测试（此前仅画廊有护栏）；合计 32 项，全绿
- GitHub 基建：Issue 模板（Bug/Feat，要求附 Quasar 对标 API 与明暗主题复现说明）、
  PR 模板（宪法第 8/9 章交付检查清单）、dependabot 依赖巡检（actions + pip 周检）
- 文档测试计数全量同步（25 → 32）
- **防失忆保险**：`docs/SESSION_HANDOFF.md` 项目交接快照（新会话 1 分钟恢复全部上下文）；
  git 仓库初始化 + 全量首提交（工程记忆落盘，不依赖任何会话）

## [0.3.0] - 2026-11-21

### Changed ⚠ Breaking（0.x 期重构，趁早降本）

- **命名冲突重构**（宪法迭代 0.3.0）：明暗模式 `NovaTheme.dark` → **`NovaTheme.isDark`**
  （1:1 对标 `$q.dark.isActive`），品牌色 **`darkColor` → `dark`**（1:1 对标 Quasar `$dark`），
  并新增 `setDark(value)`（对标 `$q.dark.set()`）；`toggleDark()` 不变（对标 `$q.dark.toggle()`）
- 迁移：`NovaTheme.dark = true` → `NovaTheme.setDark(true)`；读取用 `NovaTheme.isDark`

### Added

- **全量对标审计机制（宪法 3.5 条）**：`docs/PARITY.md` —— 已交付组件逐属性/事件/槽/model
  对照 Quasar 2.26.0 列明 ✅/🚧/⛔/❌ 状态与目标里程碑；v-model → QML 可写属性+变更信号映射约定；
  封版前 ✅ 占比门禁（P0 ≥90%、全库 ≥85%）
- 新增测试：`isDark` / `setDark` / `dark` 品牌色（合计 30 项，全绿）

## [0.2.1] - 2026-11-21

### Added

- **《架构宪法》`docs/CONSTITUTION.md`**：九章最高工程准则（工程结构 / 头注释 / Quasar 化 /
  槽机制 / 设计令牌 / 断点 / 图标 / 质量门禁 / 版本纪律）+ 迭代记录表，每次交付随版本更新
- **槽机制入宪（宪法第 4 章）**：Quasar 默认槽 → QML `default property alias`、
  命名槽 → 具名 alias / 组合子组件、作用域槽 → `property Component delegate`
- `NovaTheme.darkColor`（`#1D1D1D`）：补齐 Quasar 8 大品牌变量最后一项（本库 `dark` 已被明暗模式布尔占用，故映射命名 `darkColor`）

### Changed

- ⚠ 对标基线核实并锁定 **Quasar 2.26.0**（此前记录的 2.2x 版本号已过时，随宪法迭代复核）
- **5 个组件重构补齐默认槽**（Quasar 对应组件均有默认槽）：`NovaBtn` / `NovaChip` /
  `NovaAvatar` / `NovaIcon` / `NovaBadge` 新增 `default property alias`，
  默认子项挂载到覆盖层宿主，NovaBadge 角标吸附行为不受影响
- 新增 5 项槽机制冒烟测试（合计 30 项，全绿）

## [0.2.0] - 2026-11-21

### Changed ⚠ Breaking

- **包结构规范化（src 布局终版）**：Python 包 `nova` → `pyside_nova`，
  QML 模块 URI `nova.services/controls/behaviors` → `Nova.Services/Controls/Behaviors`
  - `from nova import init_nova` → `from pyside_nova import init_nova`
  - `import nova.controls` → `import Nova.Controls`
- 工程约定落盘：所有 `.py` / `.qml` 文件以两行头注释开头——
  第 1 行从 `src/` 开始的完整文件子路径（`src/pyside_nova/…`），第 2 行组件/文件说明（直接沉淀为 API 文档素材）
- ⚠ 已知坑（沉淀为规范）：`qmldir` 文件仅支持 `#` 注释，`//` 会破坏模块解析

### Added

- **一键打包部署升级**：`scripts/local_deploy.py --zip` 生成发布 ZIP 包
  （`dist/pyside-nova-<版本>-release.zip`：完整源码树 + 构建 wheel，zip 内根目录 `pyside-nova/`）

- **组件画廊（Gallery）**：`examples/gallery/` —— 侧边导航 + 8 个页面，
  全部 12 个组件实机展示（按钮形态/尺寸/状态、卡片三件套、标签、头像、徽标波纹、
  图标双通道、主题令牌色板、断点实时监控），顶部一键明暗切换
- **完整旗舰版文档集**：README.md（英文）/ README_zh.md（中文）/
  CHANGELOG / CONTRIBUTING / SECURITY / CODE_OF_CONDUCT /
  docs/ARCHITECTURE.md / docs/DESIGN_TOKENS.md / docs/COMPONENTS.md / docs/ROADMAP.md
- 新增测试：组件画廊完整加载测试（合计 25 项，全绿）

## [0.1.0] - 2026-11-21

### Added — M0 基建 · 第一批组件（12 个）

- `NovaTheme`：设计令牌单例（品牌色/语义色/表面色/几何/字阶/阴影），明暗双主题，运行时品牌换肤
- `NovaBtn`：按钮（filled/outlined/flat、水波纹、loading、disable、键盘触发）
- `NovaCard` / `NovaCardSection` / `NovaCardActions`：卡片系列（MultiEffect 阴影）
- `NovaChip`：标签（filled/outlined/tinted、可选中、可移除）
- `NovaAvatar`：头像（自动配色/emoji/图片）
- `NovaBadge`：徽标（子项挂载，红点/数值/浮动）
- `NovaSpace` / `NovaSeparator`：布局原语
- `NovaIcon`：图标组件（对标 QIcon）——`icon="mdi:home"` 式 API，云端 CDN + 本地图标包双通道自动回落，封装 QML Image + MultiEffect 单色化着色；`NovaBtn.icon` 自动识别图标引用
- `NovaScreen`：屏幕断点单例（对标 Quasar Screen 插件）——xs/sm/md/lg/xl（600/1024/1440/1920），is/lt/gt 语义 1:1 对标，阈值可定制
- `NovaRipple`：水波纹行为（子项挂载）
- Python 接入层 `init_nova(engine)`；wheel 内完整打包 QML 模块
- 设计约定：组件基调色属性命名 `tint`（QML 中 `color` 与基类属性冲突）；`NovaBadge.attach`/`NovaRipple.attach` 语法规划于 M1 通过 PySide6 `QML_ATTACHED` 实现
- 可运行演示 `examples/demo`；QML 冒烟测试；CI（Windows+Linux 矩阵）与 PyPI 可信发布流水线
- 一键本地部署：`scripts/fetch_icons.py`（下载 MDI/Material 图标包离线可用）+ `scripts/local_deploy.py`（build→install→test）

### Verified（Qt 6.12.0 关键坑位沉淀）

1. `on*` 前缀属性命名与 QML 信号处理器命名规则冲突（如 `onPrimary`），会令整个模块加载失败
   → 主题文本属性命名 `textOnPrimary` / `textColor` / `textMuted`
2. 组件声明 `property color color` 与 Rectangle 基类 `color` 冲突导致重复赋值
   → 基调色统一命名 `tint`
3. 纯 QML（6.12）不支持自定义 attached property（`Xxx.attach` 语法）
   → M1 经 PySide6 `QML_ATTACHED` 注册 Python 类型补齐，当前以子项挂载保持属性名一致
4. 单例属性不能在对象体内声明式绑定（会被解析为 attached property）
   → `NovaScreen.source = window` 须在 `Component.onCompleted` 中赋值
