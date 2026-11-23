# 生态对标白皮书 — Quasar Ecosystem Parity

> 对标基线 **Quasar 2.35.5**（2026-11-22 复核，原 2.26.0 已过期纠正）· 编制 2026-11-21 · 增量审计 2026-11-22 · 适用版本 0.7.0
> 结论先行：**组件层已走通，生态层才刚起步**。封版前必须补的不是"更多组件"，而是
> **服务层（插件）、指令层（行为）、工具类层（布局语法）**这三块——它们才是 Quasar 开发者的"肌肉记忆"。

---

## 0. 结论摘要（七层成熟度评分）

| 层 | 内容 | Quasar 提供 | Nova 现状 | 成熟度 | 封版门槛 |
|---|---|---|---|---|---|
| **L0 设计语言** | 令牌/主题/图标集/动效/排版 | 8 品牌色 + Dark + 14 套图标 + q-transition--* | **已交付（0.8.0）**：14 套图标集 + provider 注册表 + 八通道解析 + NovaMotion 15 预设 + 12 级字阶 + 高程 0~24 | **100%** | ≥95% |
| **L1 布局系统** | QLayout/QHeader/QFooter/QDrawer/QPage + 栅格 | 完整 + 断点行为 + mini 抽屉 | **已交付（0.5.0）** | **100%** | 100% |
| **L2 组件** | 120+ 组件 | 全 | **91 个控件 + 32 个非控件类型**（0.16.0 可访问性攻坚未加控件；0.15.0 长尾：Editor/SlideItem/Morph） | **70%** | P0 100% / 全库 ≥90% |
| **L3 指令** | 9 个（ripple/close-popup/intersection/touch 系列/scroll/morph/mutation） | 全 | **10 个**（Ripple + 0.7.0 九件收口 + **0.15.0 NovaMorph 形变**；Mutation/DropZone 由 QML 原生信号承担，PARITY 留痕） | **100%** | 100% |
| **L4 插件（服务）** | 16 个（Notify/Dialog/Loading/BottomSheet/Storage/App/Meta…） | 全 | **7 个**（OverlayHost 基建 + Notify + Dialog + Loading + Storage + App + Platform，0.6.2 一次收口四件） | **44%** | 100%（QML 适用项） |
| **L5 工具层** | CSS 工具类 + composables + utils | 数百个 class + 25 composable | **已交付（0.8.0）**：NovaUtils（colors 12 + date 21 + format 6 + is 5 + debounce/throttle/frameDebounce/uid/extend/clone）；CSS 工具类由 QML 组件承担留痕 | **95%** | ≥90% |
| **L6 工程化** | CLI/打包/文档站/测试/发布 | 全 | **80%**（0.16.0 补 a11y 双门禁 + 契约矩阵；缺文档站、视觉回归、打包器） | **80%** | ≥95% |

> **一句话诊断**：L1/L3/L0 满格、L5 95%；L2 70%（五期 A 长尾收官）；L4 44%；L6 **80%**（AI-ready + MCP + a11y 双门禁）；**非功能轴上的可访问性从 0% → 95%**（0.16.0），这是 Quasar 也没做出的统一层。
> 补组件只是"长得像"，补齐这几层才叫"用起来像"。

---


## 0.5 基线漂移审计（2.26.0 → 2.35.5，2026-11-22）

Quasar 无新增组件（组件对账 76 项不变），但生态层有 6 类增量，已并入 MASTER_PLAN：

| 增量 | 版本 | Nova 对应动作 |
|---|---|---|
| QMenu/QBtnDropdown/QFab/QSelect 统一 hover 契约（hover/hover-delay/hover-hide-delay） | 2.26~2.28 | 二期 NovaSelect、四期 NovaFab 验收补 hover 契约 |
| Dialog/BottomSheet 插件关闭原因上报（cancel/backdrop/escape/programmatic） | 2.28 | NovaDialog / NovaBottomSheet DoD 增加关闭原因回调 |
| ⚠ 归属澄清（0.5.1）：**Notify 无关闭原因**（npm 2.35.5 源码核实，`onDismiss()` 不接收参数）；NovaNotify 的 `dismissed(reason)` 属 **Nova 增强**，PARITY 标"增强"栏，不入已对齐 |
| QFab stagger 级联动画；QPullToRefresh side 四边拉动；QTooltip cursor-position | 2.27/2.30 | 四期对应组件关键能力补充 |
| useIntersection() composable + **共享 observer 池**（指令/组件/composable 三合一复用） | 2.30 | 一期 Sprint 3 NovaIntersection 实现要点：单例 observer 池 |
| **AI-ready 文档 + @quasar/mcp server**（全新生态品类） | 2.33 | ✅ **0.15.0 交付**：docs/ai/ 版本化 API 包（gen_apidocs.py）+ Nova MCP server 六工具（nova_mcp.py，search_docs/list_pages/get_page/list_api/get_api/check_updates 1:1 口径，离线零依赖） |
| useElementSize()、colors.rgbToText()、format.getDecimalsCount()、Screen.orientation | 2.34/2.35 | NovaScreen 补 orientation；Nova.utils 对账更新 |
| 安全硬化：SSR 品牌色注入 / Lang isoName 注入 / DOM clobbering | 2.32~2.35 | 五期供应链门禁补"外部输入消毒" |

## 1. 七层生态模型（交付范围的统一定义）

```
L0 设计语言   ← 令牌、主题、图标集、动效、排版、阴影
L1 布局系统   ← 骨架：Layout/Header/Footer/Drawer/Page + 栅格 + 容器
L2 组件       ← 可视化控件（Btn/Card/Table/Select…）
L3 指令       ← 无渲染行为（ripple/intersection/touch/scroll…）
L4 插件       ← 全局服务（Notify/Dialog/Loading/Storage…）
L5 工具层     ← 工具类布局语法 + 组合式 API + 工具函数
L6 工程化     ← 构建、打包、文档、测试、发布、治理
```

**宪法第 10 章据此定义**：任何新增交付物必须标注所属层；封版验收按层计分，不允许"组件堆满、生态空心"。

---

## 2. 逐层差距明细

### L0 设计语言（60%）

| Quasar 能力 | Nova 现状 | 缺口 | 优先级 |
|---|---|---|---|
| 8 大品牌色 + `setBrand` | ✅ 已 1:1 | — | — |
| Dark 插件（isActive/set/toggle/auto） | ✅ 手动 + ❌ auto（跟随系统） | `auto` 跟随系统、定时切换 | P1 |
| 图标集 + provider 注册表（14 套内置 + 运行时注册） | ✅ 0.8.0 全交付（CDN 模板实测、themify 留痕） | — | — |
| 图标命名八通道写法（`mdi-home`/`mdi:home`/`fas fa-home`/`o_home`/`sym_r_home`/`ion-*`/`img:`/SVG path） | ✅ 0.8.0 resolve() 归一化解析器 1:1 | — | — |
| 颜色工具（lighten/darken/changeAlpha/luminosity/blend… 12 函数） | ✅ 0.8.0 NovaUtils.colors 1:1 + WCAG 对比度选字色（增强） | — | — |
| q-transition--* 15 种 + 动效令牌 + reduced-motion | ✅ 0.8.0 NovaMotion + NovaTransition（reducedMotion 为 Nova 增强） | — | — |
| 排版 12 级（text-h1…caption + text-weight-*） | ✅ 0.8.0 NovaTheme.typeScale + NovaText（rem×16→px 1:1） | — | — |
| 阴影 0~24 级三层几何 | ✅ 0.8.0 elevation 0~24 入册（MultiEffect 组合待 L2 落地） | — | — |

### L1 布局系统（0%）—— **最紧急**

| Quasar | 语义 | Nova 缺什么 |
|---|---|---|
| `QLayout` | 页面骨架容器（view/drawer/header/footer 四象限） | 全部 |
| `QHeader / QFooter` | 固定头尾，自动避让抽屉 | 全部 |
| `QDrawer` | 侧边抽屉：left/right、mini、width、behavior(desktop/mobile)、breakpoint、overlay、bordered | 全部 |
| `QPageContainer / QPage` | 页面切换容器 + 页面内边距/样式 | 全部 |
| `QPageSticky / QPageScroller` | 页内吸附元素、滚动回顶 | 全部 |
| Flex 栅格 `row / col-*-n` | 12 栅格 + 5 断点 + offset/order/self-align | 全部 |
| `q-gutter-*` | 行列间距 | 全部 |
| 断点可见性 `gt-md / lt-sm` | 按断点显隐 | 全部（`NovaVisible`） |

> **落地定义**：M1 第一战不是"再做一个组件"，而是 `NovaLayout` 五件套 + `NovaRow/NovaCol` 栅格 + `NovaVisible`。
> 没有骨架，后面所有页面示例都是"散件"。

### L2 组件（10%）

已交付 12 个，路线图 P0 剩余 22 项、P1 26 项、P2 10 项（见 ROADMAP）。
**新增判断标准**：只补"Quasar 有、QML 没有"的；QML 原生已有的（Button/Menu/Slider…）以**皮肤化包装**（Nova 前缀 + 令牌 + 断点）而非重写。

### L3 指令（11%）—— **Quasar 的隐形资产**

| Quasar 指令 | 用途 | Nova 对应 | 优先级 |
|---|---|---|---|
| `v-ripple` | 水波纹 | ✅ NovaRipple | 已完成 |
| `v-close-popup` | 点击关闭弹层（菜单/对话框/抽屉） | ❌ `NovaClosePopup`（含 escape/backdrop 策略） | **P0** |
| `v-intersection` | 元素进入/离开视口 | ❌ `NovaIntersection`（懒加载、曝光埋点） | **P0** |
| `v-touch-pan` | 拖拽平移（手势） | ❌ `NovaTouchPan`（带方向/阈值/惯性） | P1 |
| `v-touch-swipe` | 快速滑动（左右滑删除） | ❌ `NovaTouchSwipe` | P1 |
| `v-touch-hold` | 长按 | ❌ `NovaTouchHold` | P1 |
| `v-touch-repeat` | 按住连发（数字步进） | ❌ `NovaTouchRepeat` | P2 |
| `v-scroll` / `v-scroll-fire` | 滚动监听 / 滚动触发一次 | ❌ `NovaScrollObserver` / `NovaScrollFire` | P1 |
| `v-morph` | 元素形变过渡（卡片展开为详情） | ❌ `NovaMorph` | P2 |
| `v-mutation` | DOM 变更监听 | ⛔ 不适用（QML 无 DOM；等价能力由属性信号提供） | — |

### L4 插件 / 服务（0%）—— **"命令式 API"是生态灵魂**

| Quasar 插件 | 能力 | Nova 规划 | 优先级 |
|---|---|---|---|
| `Notify` | 全局消息队列：位置/超时/动作按钮/分组/进度 | `NovaNotify`（单例 + 队列 + 9 位定位）—— **✅ 0.6.0 交付** | **P0** |
| `Dialog` | 命令式弹窗，返回 Promise | `NovaDialog`（回调式 `ask()` / `confirm()`） | **P0** |
| `Loading` | 全屏/局部遮罩 + 文案 + 超时 | `NovaLoading`（show/hide + 引用计数） | **P0** |
| `BottomSheet` | 底部动作面板（网格/列表） | `NovaBottomSheet` | P1 |
| `LocalStorage/SessionStorage` | 键值持久化 | `NovaStorage`（QSettings 后端 + 命名空间） | **P0** |
| `AppFullscreen` | 全屏切换 | `NovaApp.fullscreen` | P1 |
| `AppVisibility` | 前后台可见性 | `NovaApp.visible`（窗口 active 状态） | P1 |
| `Meta` | 标题/图标/描述 | `NovaApp.title/icon` | P1 |
| `Platform` | 平台判定（desktop/touch/os） | `NovaPlatform`（含 `isWindows/isMac/isLinux/touch`） | **P0** |
| `Screen` | 断点 | ✅ NovaScreen | 已完成 |
| `Dark` | 明暗 | ✅ NovaTheme | 已完成 |
| `LoadingBar` | 顶部进度条 | `NovaLoadingBar` | P2 |
| `Cookies` / `AddressbarColor` | 浏览器专有 | ⛔ 不适用（桌面端无对应语义） | — |

> **为什么这是 P0**：Quasar 应用里 `Notify.create()`、`Dialog.create()`、`$q.loading.show()` 的出现频率
> 高于任何单个组件。没有命令式服务层，组件库只是"零件箱"，不是"生态"。

### L5 工具层（0%）

| 类别 | Quasar | Nova 规划 | 优先级 |
|---|---|---|---|
| 布局工具类 | `row/column/flex-center/justify-*/items-*` | `NovaRow` / `NovaCol`（属性化：`justify/align/wrap`） | **P0** |
| 间距工具 | `q-pa-md/q-mt-lg/q-gutter-md` | `NovaSpacer` 扩展 + 间距令牌（`spacingS/M/L`） | P1 |
| 可见性工具 | `gt-md / lt-sm / desktop-only` | `NovaVisible`（`above/below/only`） | **P0** |
| 文本工具 | `text-h6/text-caption/ellipsis` | `NovaText`（`variant/ellipsis/lines`） | P1 |
| 组合式 | `useDialogPluginComponent` 等 25 个 | QML 语境多由 signals/属性天然承担 | 逐项评估 |
| 工具函数 | Date/Color/Formatter/Scrolling | `Nova.utils`（JS 单例：格式化/日期/颜色/防抖节流） | **P0** |

### L6 工程化（70%）

| 能力 | 现状 | 缺口 | 优先级 |
|---|---|---|---|
| 构建/打包 wheel | ✅ hatchling | — | — |
| 一键本地部署 | ✅ `local_deploy.py --zip` | — | — |
| CI 矩阵 | ✅ Win+Linux | 补 macOS、PySide6 多版本 | P1 |
| 测试 | ✅ 32 项冒烟 | **QML TestCase 单测、视觉回归（截图 diff）、API 快照、a11y 扫描** | **P0** |
| 文档站 | 🚧 Markdown | **可搜索文档站 + 在线示例 + API 自动生成** | **P0** |
| 应用打包 | ❌ | **PyInstaller/Nuitka 一键 exe + 安装器 + 图标生成（对标 Icon Genie）** | **P0** |
| 版本治理 | ✅ 宪法 + CHANGELOG | 迁移指南模板、废弃告警机制 | P1 |
| 供应链 | 🚧 dependabot | SBOM、许可证审计、CVE 巡查 | P1 |

---

## 3. 封版前必须补齐的 12 项空白（P0 清单）

| # | 交付物 | 层 | 验收标准（DoD） |
|---|---|---|---|
| 1 | **NovaLayout 五件套** | L1 | header/footer/drawer/page 组合可用；drawer 支持 mini/behavior/breakpoint；断点切换不闪烁 |
| 2 | **NovaRow / NovaCol / NovaVisible** | L5/L1 | 12 栅格 × 5 断点；gutter；`above/below` 显隐；示例页覆盖 6 种经典布局 |
| 3 | **NovaNotify** ✅（0.6.0） | L4 | 队列/去重/超时/动作按钮/9 位定位；同屏 ≤5 条（maxVisible）；Demo 可交互；29 项对账见 PARITY 审计节 |
| 4 | **NovaDialog** ✅（0.6.1） | L4 | 命令式 show + 链式句柄；27 项对账；五向定位；persistent/seamless/进度态；dismissed 五值 |
| 5 | **NovaLoading** | L4 | 引用计数（并发不互相踩）；局部/全屏；超时保护 |
| 6 | **NovaStorage + NovaApp + NovaPlatform** | L4 | 命名空间键值持久化；全屏/标题/可见性；平台判定 |
| 7 | **NovaClosePopup / NovaIntersection** | L3 | 点击外部/ESC 关闭；进入视口触发一次+持续两种模式 |
| 8 | **图标 provider 注册表 + 6 套图标集** | L0 | `icon="mdi:home"`/`mdi-home`/`fas fa-home` 三写法归一；离线包按需下载；缺图标降级占位 |
| 9 | **Nova.utils + 动效令牌** | L5/L0 | 日期/颜色/格式化/防抖；`durationS/M/L`、`easingStandard`；reduced-motion 开关 |
| 10 | **NovaForm 体系（Form/Field/Input/Select/Toggle/OptionGroup）+ rules 校验** | L2 | 规则数组（必填/长度/正则/自定义函数）；错误态与 a11y 提示；提交聚合校验 |
| 11 | **NovaTable 完整能力** | L2 | 列定义/排序/过滤/分页/多选/展开行/粘性表头/virtual scroll/服务端模式 ✅（0.12.0：虚拟滚动 + 服务端模式 + loading 收口） |
| 12 | **工程化三件套：文档站 + 视觉回归 + 应用打包** | L6 | 文档站可搜索；截图 diff 纳入 CI；`python scripts/build_app.py` 产出 exe |

---

## 4. 世界级"非功能"门禁（真正的分水岭）

企业级旗舰不是"功能多"，而是**这些指标可量化**：

| 维度 | 门禁 | 现状 |
|---|---|---|
| **可访问性** | WCAG 2.1 AA；全组件键盘可达（Tab/Enter/Esc/方向键）；`Accessible.name/role` 覆盖 100%；焦点环可见；对比度 ≥4.5:1 | **95%（0.16.1）**：124 类型契约 100%（32 interactive 全键盘路径 + 焦点环）、AA 派生令牌、静态+运行时双门禁、24 项测试；0.16.1 补齐 Tree 方向键游标、Dialog 焦点陷阱；余 5% = 组件内部组合色逐件采样（B3）、屏读器手工回归（NVDA，B3） |
| **国际化** | `NovaI18n`：locale 切换、复数、日期/数字格式、**RTL 镜像** | **90%（0.16.1）**：NovaI18n 单例（对标 $q.lang：t() 三级回落 / tp() CLDR 七语系复数 / 数字货币日期相对时间格式化 / addBundle 热注入）、RTL 双轨镜像 6 组件、41 项测试；余 10% = 更多语言词典包 + 术语表管理 |
| **性能** | 冷启动首帧 ≤800ms；1000 行表格滚动 ≥55fps；单组件实例化 ≤5ms；内存无泄漏（24h 压测） | **门禁化（0.16.1）**：test_perf.py 三指标全绿——冷启动 ≤800ms ✅ / 实例化 ≤5ms ✅（两遍测量 + KNOWN_HEAVY）/ 1000 行挂载 ≤1700ms ✅（55fps 预算大幅富余）；24h 内存长跑待 B3 |
| **HiDPI/缩放** | 100%~200% 无模糊；字体缩放跟随系统；`NovaTheme.fontScale` | **门禁化（0.16.1）**：QT_SCALE_FACTOR 1.0/1.5/2.0 矩阵（dpr 联动 + 逻辑几何恒定）；Qt 6 高分屏默认策略下无自研 fontScale 必要；真机多屏抽查待 B3 |
| **主题** | 明暗 + 跟随系统 + 品牌换肤 + 对比度自动校验 | 60% |
| **打包** | PyInstaller 单文件 ≤60MB；安装器；代码签名；离线图标内置 | 0% |
| **安全** | 图标 SVG 消毒；无默认联网；依赖 SBOM；CVE 周巡 | 30% |
| **治理** | API 冻结清单；废弃两版本周期；迁移指南 | 60% |

---

## 5. 修订后的里程碑（M1 范围重定义）

原 M1 只列了组件，现按生态层重排：

```
M1（8 周）生态骨架
├─ Sprint 1（2 周）L1 布局：NovaLayout 五件套 + NovaRow/Col/Visible + 画廊"布局"页
├─ Sprint 2（2 周）L4 服务：Notify / Dialog / Loading / Storage / App / Platform
├─ Sprint 3（2 周）L3 行为：ClosePopup / Intersection / Touch 系列
└─ Sprint 4（2 周）L0/L5：图标 provider + 6 套图标 + Nova.utils + 动效令牌 + 排版 9 级

M2（6 周）组件纵深
├─ 表单体系（Form/Field/Input/Select/Toggle/OptionGroup + rules）
├─ 数据体系（Table 全能力 / Tree / Pagination / VirtualScroll）
└─ 反馈体系（Skeleton / InnerLoading / Spinner / Progress / Tooltip / Menu）

M3（4 周）非功能与封版
├─ a11y 全量整改 + i18n/RTL + 性能基线 + HiDPI
├─ 文档站 + 视觉回归 + 应用打包器
└─ RC1/RC2 + API 冻结 + 1.0.0-flagship
```

---

## 6. 封版验收清单（Definition of Done，24 条）

**生态完整**
- [ ] L1 布局五件套 100% 可用，含 mini/breakpoint 抽屉
- [ ] L3 指令 9 项（除不适用项）全部交付且可组合
- [ ] L4 插件 9 项（QML 适用项）全部交付，命令式 API 稳定
- [ ] L5 栅格/可见性/文本/工具函数全覆盖
- [ ] 图标 8 套 + 三种命名写法归一
**质量**
- [ ] P0 组件测试覆盖率 ≥90%，全库 ≥85%
- [ ] 视觉回归基线覆盖全部画廊页面（明/暗 × 5 断点）
- [ ] qmllint 0 error、0 warning
- [ ] 24h 压测无内存增长
**体验**
- [ ] WCAG 2.1 AA 全通过（含键盘全路径）
- [ ] i18n 中/英 + RTL 阿拉伯语演示可用
- [ ] 冷启动 ≤800ms、1000 行表格 ≥55fps
- [ ] 明暗切换零闪烁、零警告
**交付**
- [ ] wheel + sdist + 一键 exe + 安装器
- [ ] 文档站上线（搜索 + 在线示例 + API 自动生成）
- [ ] 迁移指南 + 废弃策略 + LTS 承诺书
- [ ] SBOM + 许可证清单 + 安全策略
**治理**
- [ ] 宪法迭代记录完整（每次交付一行）
- [ ] PARITY 审计 ✅ 占比 ≥90%（P0）/ ≥85%（全库）
- [ ] CHANGELOG 全量可追溯
- [ ] API 冻结清单签署

---

## 7. 明天开工：Sprint 1 前三天（可直接照做）

| 天 | 任务 | 产出 |
|---|---|---|
| D1 | `NovaLayout` 骨架：四象限 + `NovaPage` | 一个能跑的空壳布局（header/footer/drawer/page） |
| D2 | `NovaDrawer` 行为：width/mini/behavior/breakpoint/overlay | 断点自动收起 + mini 展开动画 |
| D3 | `NovaRow/NovaCol/NovaVisible` + 画廊"布局"页 | 6 种经典布局示例（后台/看板/表单/详情/登录/空态） |

> 建议顺序不变：**先骨架、再服务、后组件**。骨架决定后面所有示例的形态，改一次成本极高。

---

## 附：Quasar 生态完整清单（对标用）

- **组件**：120+（见 [COMPONENTS.md](COMPONENTS.md) 的 P0/P1/P2 分组）
- **指令**：Close Popup、Intersection、Mutation、Morph、Ripple、Scroll、Scroll Fire、Touch Hold、Touch Pan、Touch Repeat、Touch Swipe
- **插件**：AddressbarColor、AppFullscreen、AppVisibility、BottomSheet、Cookies、Dark、Dialog、Loading、LoadingBar、LocalStorage、Meta、Notify、Platform、Screen、SessionStorage
- **组合式**：useQuasar、useDialogPluginComponent、useFormChild、useMeta、useDropZone、useElementSize、useIntersection、useScroll、useIdle、useKeyboardShortcut、useWebSocket 等 25 个
- **工具**：Date、Color、DOM、Morph、Formatter、Scrolling、Type checking、Event bus、Other
- **CSS**：Flex Grid、Spacing、Typography、Visibility（断点/平台/方向/打印）、Shadows、Positioning、Borders、Size
- **图标集**：Material Icons、Material Symbols、MDI、Font Awesome、Ionicons、Eva Icons、Themify、Bootstrap Icons、Line Awesome、SVG
- **语言包**：40+ 语种；**Icon Genie**：单图生成全套应用图标
