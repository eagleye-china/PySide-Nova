# 全生态开发总规划 — Master Plan

> 目标：**使用 PySide6 QML 完现 Quasar 框架全生态 + 全部组件**，对标基线 Quasar `2.35.5`（2026-11-22 官方 releases 复核），
> 终点 `1.0.0-flagship` 封版（API 冻结 + LTS 24 个月）。
> 编制 2026-11-21 · 适用版本 0.4.1 · 总周期估算 **约 28 周（单人节奏，含缓冲）**
> 与 `ECOSYSTEM_PARITY.md`（差距审计）、`PARITY.md`（逐组件对标）互为姊妹篇：
> 白皮书回答"缺什么"，本规划回答"按什么顺序、每一期交什么、怎么验收"。

---

## 0. 六期战略总览

| 期 | 主题 | 版本阶梯 | 周期 | 新增组件/服务/指令 | 累计覆盖 |
|---|---|---|---|---|---|
| **一期** | 生态骨架（L1 布局 + L4 服务 + L3 行为 + L0/L5 基础） | 0.5.0 → 0.8.0 | 8 周 | 8 组件 + 8 服务 + 9 指令 | 生态 60% |
| **二期** | 表单与选择体系 | 0.9.0 → 0.10.0 | 4 周 | 18 组件 | 组件 ~40% |
| **三期** | 数据展示与媒体体系 | 0.11.0 → 0.12.0 | 5 周 | 16 组件 | 组件 ~62% |
| **四期** | 导航、弹层与反馈体系 | 0.13.0 → 0.14.0 | 5 周 | 25 组件 | 组件 ~95% |
| **五期** | 长尾组件 + 非功能攻坚 | 0.15.0 → 0.16.0 | 4 周 | 4 组件 + a11y/i18n/性能/文档站/打包器 | 全生态 |
| **六期** | 封版 | **1.0.0-flagship** | 2 周 | RC1/RC2 + API 冻结 | 100% |

> **排期总原则（宪法第 10 章）**：先骨架、再服务、后组件；组件按"体系"成批交付
> （表单一批、数据一批、导航一批），不做零敲碎打——成批交付才能保证体系内
> API 风格一致（如全部表单组件统一 `label/hint/error/readonly/disable` 语义）。
>
> **交付节奏条款（0.6.2 增补，回应用户对"每期一个组件"的纠偏）**：
> 1. **Sprint 是最小交付单元**——一个 Sprint 内的所有组件/服务**一次收口、一个版本号、
>    一套交付物**（ALL-IN-ONE / release zip / sha256 / PROMPT / MASTER_PLAN / 总索引 共六份）；
>    Sprint 中间件只做 git 提交与画廊预览，**不单独打全包发版**。
> 2. 版本号跟随 Sprint：0.5.0=Sprint 1；0.6.x=Sprint 2（0.6.0/0.6.1 为拆件期的历史小版本，
>    自 0.6.2 起恢复"一 Sprint 一版本"）；**0.7.0=Sprint 3 ✅**；0.8.0=Sprint 4。
> 3. 唯一例外：涉及契约裁定（如 0.5.1）可单独发版，但同样只出六份交付物。

---

## 1. 一期：生态骨架（v0.5.0 ~ v0.8.0，4 Sprint）

### Sprint 1 · L1 布局系统（v0.5.0）

| 交付物 | 对标 | 关键能力 |
|---|---|---|
| `NovaLayout` | QLayout | 四象限骨架容器（header/footer/drawer/page） |
| `NovaHeader` / `NovaFooter` | QHeader / QFooter | 固定头尾、reveal 滚动隐藏、自动避让抽屉 |
| `NovaDrawer` | QDrawer | left/right、mini、behavior(desktop/mobile)、breakpoint、overlay、bordered |
| `NovaPage` | QPageContainer + QPage | 页面容器、padding、页面切换 |
| `NovaPageSticky` / `NovaPageScroller` | 同名 | 页内吸附、滚动回顶 |
| `NovaRow` / `NovaCol` | Flex 栅格 | 12 栅格 × 5 断点（xs~xl）、gutter、offset、align、wrap |
| `NovaScreen` 增强 | Screen 2.35 | 补 `orientation`（portrait/landscape + primary/secondary）|
| `NovaVisible` | gt-md / lt-sm | above/below/only 断点显隐 |

- **冒烟验收**：6 种经典布局示例可跑（后台/看板/表单/详情/登录/空态）；
  抽屉断点切换不闪烁；mini 展开/收起动画正常；全量 pytest 绿 + ZIP
- **测试基线**：32 → 45 项

### Sprint 2 · L4 服务层（v0.6.0）

| 交付物 | 对标插件 | 关键能力 |
|---|---|---|
| `NovaNotify` —— **✅ v0.6.0 交付** | Notify | 队列、去重、超时、动作按钮、9 位定位、同屏 ≤5 条（maxVisible）；**29 项配置逐项对账**（npm 2.35.5 源码核实）；`html` 不移植改 `contentDelegate`；`dismissed(reason)` 6 值（含 overflow）为 **Nova 增强**（PARITY 标增强）；**NovaOverlayHost 已抽件**（overlay 宿主 + 层叠令牌 + 位置栈 9 位插入，Dialog/Loading 直接复用） |
| `NovaDialog` | Dialog | 命令式 `ask()/confirm()`、ESC/遮罩策略、可嵌套、返回结果 |
| `NovaLoading` —— **✅ v0.6.2 交付** | Loading | 11 项对账（npm 2.35.5 核实）；引用计数并发不互踩（句柄释放一份，归零收口）；delay 防闪烁；局部 target/全屏双路；timeout 卡死兜底；ring/dots/pulse 三 spinner |
| `NovaStorage` —— **✅ v0.6.2 交付** | LocalStorage/SessionStorage | Python ini 后端（不依赖 organizationName）；全 API 面 + Web 别名；命名空间隔离；JSON 损坏安全降级 |
| `NovaApp` —— **✅ v0.6.2 交付** | AppFullscreen/AppVisibility/Meta | request/exit/toggle 1:1；setVisibility 统一入口（fullscreen/maximized/minimized/windowed）；setTitle 映射 document.title |
| `NovaPlatform` —— **✅ v0.6.2 交付** | Platform | isWindows/isMac/isLinux/isAndroid/isIOS/isWasm/isMobile/isDesktop；hasTouch 走 QInputDevice 枚举；osVersion/cpuArch 增强 |

- **冒烟验收（✅ 0.6.2 达成）**：画廊可交互触发 Notify/Dialog/Loading；并发 Loading 引用计数正确
  （测试实证：同组 ×2 → 释放一份仍显示，归零收口）；Storage 全新 QSettings 实例读回同 ini 实证落盘；
  测试 46 → 63 → 71 → **91 项**（Sprint 2 累计 +45）

### Sprint 3 · L3 行为层（v0.7.0）

| 交付物 | 对标指令 | 关键能力 |
|---|---|---|
| `NovaClosePopup` —— **✅ v0.7.0 交付** | v-close-popup | depth 语义 1:1（<0 全关/0 禁用/N 层）；clicked 信号自动桥接 + Enter 键；NovaOverlayHost 弹层栈承载"层"（NovaDialog 已接入） |
| `NovaIntersection` —— **✅ v0.7.0 交付** | v-intersection | entry 七字段 1:1；threshold/rootMargin/once+rearm/stop；**NovaIntersectionPool 共享观察池**（对标 2.30 架构）；祖先 clip 链计入可见区域 |
| `NovaTouchPan` / `NovaTouchSwipe` / `NovaTouchHold` / `NovaTouchRepeat` —— **✅ v0.7.0 交付** | v-touch 系列 | details 全字段 1:1（offset/delta/isFirst/isFinal）；arg 三段阈值拆独立属性（默认值同基线）；共享 NovaTouchCore 内核（触摸/鼠标来源判定统一） |
| `NovaScrollObserver` / `NovaScrollFire` —— **✅ v0.7.0 交付** | v-scroll / v-scroll-fire | 滚动位置/方向/边界回调；首入视口触发一次 + rearm 再武装；与 Intersection 同池同驱动 |

> 注：Morph/Mutation/Resize/DropZone 不做指令化移植（QML 属性信号/DropArea 天然承担，PARITY 留痕）。

- **冒烟验收（✅ 0.7.0 达成）**：画廊第 13 页演示全部行为（懒加载进入视口才触发、
  拖动/划动/长按/连发可交互、ClosePopup 真实关闭对话框）；测试 91 → **114 项**

### Sprint 4 · L0/L5 基础层（v0.8.0）

| 交付物 | 对标 | 关键能力 |
|---|---|---|
| 图标 provider 注册表 + 6 套图标集 | 8 套图标 | `mdi:home` / `mdi-home` / `fas fa-home` 三写法归一解析；缺图标降级占位 |
| `Nova.utils` | date/color/formatter | 日期、颜色（lighten/darken/对比度选字色）、格式化、防抖节流 |
| 动效令牌 | animate.css | durationS/M/L、easingStandard、reduced-motion 开关 |
| 排版 9 级 | text-h1…overline | NovaText（variant/ellipsis/lines） |

- **冒烟验收**：三写法图标全部正确渲染；`Nova.utils` 单元测试全绿；
  画廊全部页面换用排版令牌后视觉无回归；测试 66 → 75 项
- **一期里程碑验收**：七层成熟度 L1 0%→100%、L3 11%→100%、L4 0%→100%、L5 0%→≥90%

---

## 2. 二期：表单与选择体系（v0.9.0 ~ v0.10.0）

> 体系内统一契约：`label / hint / error / errorMessage / readonly / disable /
> clearable / rules 校验`，一套契约贯穿 18 个组件，这就是 Quasar 的"表单手感"。

### Sprint A · 表单核心（v0.9.0）

| 交付物 | 对标 | 关键能力 |
|---|---|---|
| `NovaField` | QField | 统一字段包装器（标签/提示/错误态/前后置图标/计数器） |
| `NovaInput` | QInput | 校验、clearable、多行、密码、字符计数 |
| `NovaForm` | QForm | 规则化校验容器、提交聚合校验、resetValidation |
| `NovaSelect` | QSelect | 多选 chip、搜索过滤、选项分组、useInput 式自由输入；hover 契约（hover/hover-delay/hover-hide-delay）、no-option-label、dialog 关闭按钮 |
| `NovaToggle` / `NovaCheckbox` / `NovaRadio` / `NovaOptionGroup` | 同名 | keep-color、dark 支持、indeterminate |
| `NovaBtnToggle` | QBtnToggle | 分段选择按钮组（spread/clear/outline） |
| `NovaPopupEdit` | QPopupEdit | 点击编辑单元格/文本（配合三期表格） |

### Sprint B · 输入进阶（v0.10.0）

| 交付物 | 对标 | 关键能力 |
|---|---|---|
| `NovaSlider` / `NovaRange` / `NovaKnob` | 同名 | 双值范围、step/markers/labelAlways、拖动 label |
| `NovaDate` | QDate | **自研日历**（Qt 6 无内置）：年月切换、多选/区间、locale、最小最大值 |
| `NovaTime` | QTime | 时/分/秒选择、24h 制、with-seconds |
| `NovaColorPicker` | QColor | 调色板 + 无默认值的格式化输出 |
| `NovaFile` / `NovaUploader` | QFile/QUploader | 多文件、大小限制、拒绝回调、进度模拟 |

- **冒烟验收**：18 组件全部进画廊"表单"页；rules 校验（必填/长度/正则/自定义函数）
  错误态与 a11y 提示齐全；表单提交聚合校验演示可用；测试 75 → 100 项

---

## 3. 三期：数据展示与媒体体系（v0.11.0 ~ v0.12.0）

### Sprint A · 数据体系（v0.11.0）

| 交付物 | 对标 | 关键能力 |
|---|---|---|
| `NovaTable`（含 QTh/QTd/QTr） | QTable | 列定义/排序/过滤/分页/多选/展开行/粘性表头/grid 模式/虚拟滚动/服务端模式 |
| `NovaTree` | QTree | 节点勾选/展开/懒加载/过滤、default-expand-all |
| `NovaPagination` | QPagination | 页码器（max-pages/ellipses/boundary-links） |
| `NovaList` / `NovaItem` | QList/QItem/QItemSection/QItemLabel | 列表与条目、手风琴、双行/三行布局 |
| `NovaMarkupTable` | QMarkupTable | 表格皮肤化包装 |
| `NovaInfiniteScroll` | QInfiniteScroll | 触底加载、停止条件 |
| `NovaVirtualScroll` | QVirtualScroll | 大列表虚拟化 |
| `NovaScrollArea` | QScrollArea | 统一滚动条样式 |

### Sprint B · 媒体体系（v0.12.0）

| 交付物 | 对标 | 关键能力 |
|---|---|---|
| `NovaImg` | QImg | 加载占位/错误占位/宽高比 |
| `NovaResponsive` | QResponsive | 16:9 等比例容器 |
| `NovaVideo` | QVideo | 视频嵌入包装 |
| `NovaParallax` | QParallax | 视差滚动 |
| `NovaCarousel` | QCarousel | 轮播（arrows/dots/autoplay/infinite/swipe） |
| `NovaTimeline`（含 Entry） | QTimeline | 时间轴（颜色/图标/反向） |
| `NovaChatMessage` | QChatMessage | 聊天气泡 |

- **冒烟验收**：NovaTable 1000 行虚拟滚动 ≥55fps；Tree 懒加载不过渡闪烁；
  Carousel 触摸/滚轮双输入可用；测试 100 → 135 项

---

## 4. 四期：导航、弹层与反馈体系（v0.13.0 ~ v0.14.0）

### Sprint A · 导航体系（v0.13.0）

| 交付物 | 对标 | 关键能力 |
|---|---|---|
| `NovaTabs` / `NovaTab` / `NovaTabPanels` | QTabs/QTab/QTabPanels | 标签页与面板、inline/active-class/切换动画 |
| `NovaBreadcrumbs` | QBreadcrumbs(+El) | 面包屑（图标/分隔符/收缩） |
| `NovaStepper`（含 QStep） | QStepper | 步骤条（可编辑/错误态/垂直/备用标签） |
| `NovaExpansionItem` | QExpansionItem | 展开项（手风琴/分组） |
| `NovaToolbar` | QToolbar(+Title) | 工具栏 |
| `NovaFab` / `NovaFabAction` | QFab/QFabAction | 悬浮按钮组（展开方向/持久展开/**stagger 级联动画**、hover 打开契约） |

### Sprint B · 弹层与反馈（v0.14.0）

| 交付物 | 对标 | 关键能力 |
|---|---|---|
| `NovaMenu` | QMenu | 菜单（auto-close/context-menu/触摸） |
| `NovaDialog`（组件壳） | QDialog | 声明式对话框（服务式 API 于 Sprint 2 交付）；**关闭原因上报**（cancel/backdrop/escape/programmatic，对标 2.28） |
| `NovaPopupProxy` | QPopupProxy | 弹层路由（Menu/Dialog 自适应） |
| `NovaTooltip` | QTooltip | 工具提示（延迟/锚点/偏移） |
| `NovaBtnDropdown` / `NovaBtnGroup` | 同名 | 下拉按钮 / 按钮组 |
| `NovaBanner` / `NovaBar` | QBanner/QBar | 横幅 / 顶栏 |
| `NovaAjaxBar` | QAjaxBar | 顶部进度条 |
| `NovaLoadingBar`（服务） | LoadingBar 插件 | 命令式顶部进度 |
| `NovaBottomSheet` | BottomSheet 插件 | 底部动作面板（网格/列表）；关闭原因上报（对标 2.28） |
| `NovaInnerLoading` | QInnerLoading | 局部加载遮罩 |
| `NovaSpinner`（8 变体） | QSpinner 系列 | 球/环/齿轮/沙漏等 8 种 |
| `NovaSkeleton` | QSkeleton | 骨架屏（类型/动画/波纹） |
| `NovaNoSsr` | QNoSsr | 延迟渲染 |
| `NovaPullToRefresh` | QPullToRefresh | 下拉刷新（**side 四边拉动**：top/bottom/left/right，对标 2.30） |
| `NovaScrollObserver` / `NovaResizeObserver` | 同名组件 | 滚动/尺寸观察（若 S3 未覆盖则此期补齐） |

- **冒烟验收**：菜单/对话框/抽屉/弹层互相嵌套不串焦点；ESC 逐层关闭；
  明暗主题下弹层阴影/遮罩一致；测试 135 → 175 项

---

## 5. 五期：长尾组件 + 非功能攻坚（v0.15.0 ~ v0.16.0）

### Sprint A · 长尾组件（v0.15.0）

| 交付物 | 对标 | 说明 |
|---|---|---|
| `NovaEditor` | QEditor | 轻量富文本（工具栏配置/格式化命令） |
| `NovaMorph` | v-morph | 元素形变过渡（卡片展开为详情） |
| `NovaSlideItem` | QSlideItem | 滑动操作项（左滑删除/右滑收藏） |
| `NovaIconGenie` | Icon Genie | 单图生成全套应用图标（favicon/启动图/多分辨率） |
| **Nova MCP server + AI-ready 文档** | @quasar/mcp（2.33 新品类） | 离线文档包 + MCP server（search/list/get 三工具，AI agent 精确查询 Nova 版本化 API，杜绝幻觉） |

### Sprint B · 非功能攻坚（v0.16.0）

| 维度 | 门禁目标 | 关键动作 |
|---|---|---|
| 可访问性 | WCAG 2.1 AA 全过 | Accessible.name/role 100%、键盘全路径、焦点环、对比度 ≥4.5:1 |
| 国际化 | 中/英 + RTL 可演示 | NovaI18n：locale 切换、复数、日期数字格式、RTL 镜像 |
| 性能 | 冷启动 ≤800ms；1000 行表格 ≥55fps；单组件实例化 ≤5ms | 基线测量 + 压测脚本 + 24h 内存 |
| HiDPI | 100%~200% 无模糊 | fontScale 跟随系统 |
| 文档站 | 可搜索 + 在线示例 + API 自动生成 | MkDocs/Sphinx + 示例沙箱 |
| 视觉回归 | 明/暗 × 5 断点全画廊基线 | 截图 diff 纳入 CI |
| 应用打包 | 一键 exe | `python scripts/build_app.py`（PyInstaller）+ 安装器 |
| 供应链 | SBOM + 许可证审计 + CVE 周巡 | 脚本化；**外部输入消毒**（对标 2.32~2.35 SSR 注入/DOM clobbering 硬化，Nova 语境：Storage/Notify 等服务的字符串内容消毒） |

- **测试基线**：175 → 220 项 + 视觉回归基线集

---

## 6. 六期：封版 `1.0.0-flagship`（约 2 周）

1. **RC1**（0.16.x 后）：API 冻结审查——qmldir 导出清单 = 冻结公共 API 面，签署冻结清单
2. **RC2**：24 条封版验收清单全勾（ECOSYSTEM_PARITY 第 6 节）；迁移指南 + 废弃策略 + LTS 承诺书
3. **1.0.0-flagship 正式封版**：
   - 封版后仅 bug 修复 / 72h 安全热修 / 性能优化；新特性进 minor、破坏性进 major
   - 废弃 API：`@deprecated` 标注 + 运行时警告，两版本周期后移除
   - LTS 24 个月承诺
4. **庆祝与沉淀**：宪法终版、技术复盘、PyPI 正式版发布

---

## 7. 冒烟测试纪律（每期每 Sprint 统一执行）

**"所有步骤都冒烟测试"落实为制度化模板，每个 Sprint 交付时逐条执行：**

1. **组件解析冒烟**：QML 引擎加载全部 qmldir + 每个新组件实例化成功（防 on*/命名坑位复发）
2. **槽机制冒烟**：默认槽 / 命名槽 / 作用域槽各至少 1 项断言
3. **明暗双主题冒烟**：toggleDark() 后新组件无绑定错误、无控制台警告
4. **断点冒烟**：涉及布局的新组件在 5 断点下显隐/尺寸正确
5. **画廊门禁**：新组件必须进画廊对应体系页，gallery 整体加载测试通过
6. **全量回归**：pytest 全绿（不通过不交付）→ `local_deploy.py --zip` → SHA256 校验
7. **宪法六步**：升版 → CHANGELOG → 宪法记录表 → SESSION_HANDOFF → gen_prompt → ZIP

**测试数量轨迹**：32 → 45 → 58 → 66 → 75 → 100 → 135 → 175 → 220 → 封版 ≥240，
封版时全库覆盖率 ≥85%、P0 组件 ≥90%。

---

## 8. 全量对账表（Quasar 生态 → Nova → 归属期）

### 组件（76 项：已完成 12 + 规划 64）

| 已完成（12） | | | | | |
|---|---|---|---|---|---|
| NovaBtn | NovaCard 三件套 | NovaChip | NovaAvatar | NovaBadge | NovaSeparator |
| NovaSpace | NovaIcon | NovaTheme(Dark) | NovaScreen(Screen) | NovaRipple | — |

| 一期（8） | NovaLayout / NovaHeader / NovaFooter / NovaDrawer / NovaPage / NovaPageSticky / NovaPageScroller / NovaVisible |
|---|---|

| 二期（18） | NovaField / NovaInput / NovaForm / NovaSelect / NovaToggle / NovaCheckbox / NovaRadio / NovaOptionGroup / NovaBtnToggle / NovaPopupEdit / NovaSlider / NovaRange / NovaKnob / NovaDate / NovaTime / NovaColorPicker / NovaFile / NovaUploader |
|---|---|

| 三期（16） | NovaTable(+Th/Td/Tr) / NovaTree / NovaPagination / NovaList / NovaItem / NovaMarkupTable / NovaInfiniteScroll / NovaVirtualScroll / NovaScrollArea / NovaImg / NovaResponsive / NovaVideo / NovaParallax / NovaCarousel / NovaTimeline / NovaChatMessage |
|---|---|

| 四期（25） | NovaTabs / NovaTab / NovaTabPanels / NovaBreadcrumbs / NovaStepper / NovaExpansionItem / NovaToolbar / NovaFab / NovaFabAction / NovaMenu / NovaDialog 壳 / NovaPopupProxy / NovaTooltip / NovaBtnDropdown / NovaBtnGroup / NovaBanner / NovaBar / NovaAjaxBar / NovaInnerLoading / NovaSpinner×8 / NovaSkeleton / NovaNoSsr / NovaPullToRefresh / NovaScrollObserver / NovaResizeObserver |
|---|---|

| 五期（4） | NovaEditor / NovaMorph / NovaSlideItem / NovaIconGenie |
|---|---|

> ⛔ 不适用记录（对标审计留痕，非遗漏）：AddressbarColor / Cookies（浏览器专有）、
> v-mutation 指令（QML 无 DOM）。合计覆盖率：组件 76/76、指令 11/11（10 交付 + 1 不适用）、
> 插件 15/15（13 交付 + 2 不适用）。

### 服务（13 项）、指令（10 项）、基础（3 项）

- 服务：NovaNotify / NovaDialog / NovaLoading / NovaStorage / NovaApp / NovaPlatform（一期）+
  NovaBottomSheet / NovaLoadingBar（四期）
- 指令：NovaClosePopup / NovaIntersection / NovaTouchPan·Swipe·Hold·Repeat / NovaScrollObserver / NovaScrollFire（一期）+
  NovaMorph（五期）
- 基础：图标 8 套 + provider 注册表、Nova.utils、动效令牌 + 排版 9 级（一期 Sprint 4）

---

## 9. 风险与对策

| 风险 | 对策 |
|---|---|
| NovaDate 日历自研工作量大（Qt 无内置） | 提前到二期收尾攻坚，允许顺延一周，不压缩测试 |
| NovaTable 全能力复杂度高 | 拆两次交付：v0.11 基础（排序/过滤/分页），v0.12 增强虚拟滚动/服务端模式 |
| 单人开发节奏波动 | 每期只锁范围不锁死日期；连续两周未达标即触发宪法复盘条款 |
| PySide6 升版破坏 | 测试护栏（220+ 项）+ CI 多版本矩阵即为回归网 |
| 会话中断 | SESSION_HANDOFF + PROMPT 单文件闭环，任何新会话 100% 恢复 |
