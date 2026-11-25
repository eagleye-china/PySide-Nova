# pyside-nova 旗舰组合根容器｜权威清单（整合完整版）
> 封版规范：组合宪法 **0.9.1** · 包版本 **1.0.0 GA** · **15 项全部已封版**（API 冻结指纹 `bfd3d938a2fab7be`）
> 技术红线：`docs/white_paper/Prescient-LayoutShell-封版规范.md` v2.1.0 ·
> 契约交付物：`src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md`（15 项属性/信号/槽位 + 依赖组件清单）
> 定位：主打工业桌面工具、HMI、IDE类、配置管理、AI助手、文档工作台；精而不繁、正交无冗余，一个业务场景优先匹配一个根容器，不重复造同结构骨架
> 命名纪律（0.6.0）：能去则去、必要则留；缩写一律全称——优先不带 `Shell`；撞 Controls 同名时保留（`NovaTabShell`）；用途收窄者语义正名（`NovaSetupWizard`）；`NovaTopNavigation`（原 `NovaTopNav`）
> **身份差异化（0.7.0 强制）**：每项有独有结构性身份元素（纯装饰 / `_` 私有 / 零业务语义），严禁 15 项共用同一模板仅换槽位名：
> Sidebar 品牌渐变轨+浮起侧栏卡 · TopNavigation 胶囊导航台+悬浮下拉 · DualSide 中央画布点阵+双侧浮起栏 ·
> TabShell 材质标签栏+下划线指示 · ThreeColumn 三级深度色阶+拖拽 grip · Compare 中缝圆形调节柄+A/B 色条 ·
> CardGrid 工具条胶囊+Flow 网格 · Modal 顶部三色条+catcher+浮起阴影 · DrawerPanel 侧缘渐变轨+grabber ·
> SetupWizard 三态步骤时间轴 · BlankPage 居中阅读栏 · Desktop 窗口控制点+分层栏 · Mobile 灵动岛+home indicator ·
> FlexLayout 三色面板网格 · **Chat 品牌化多轨工作台（0.7.1 按轨分治）**
> **多轨按轨分治（0.7.1 强制）**：`NovaChat` 6 轨各有独占前景签名，绝非"轨数多即差异化"——
> 顶层三段品牌发丝线 / 导航轨（渐变徽记 + 三级激活图标位 + 账户锚 + 缘轨）/ 会话栈（搜索胶囊 + 激活竖条 + 新建圆钮）/
> 对话区（在线状态点 + 三点位 + 四角取景框）/ 输入区（浮起胶囊 + 附加十字 + 纯几何发送箭头）/ 详情栏（分段 tab + 缘轨）。
> 签名只占边缘/角标，中央内容区全留给业务注入；浅色 + 深色主题实心注入下均清晰（装饰实心度 ≥0.85、零字体依赖）。
> 新增：**NovaChat** AI 对话主窗口（对标 WorkBuddy 桌面端主窗口），与 **NovaDesktop / NovaMobile / NovaFlexLayout** 三端根壳共同覆盖 15 项场景
> **0.8.0 旗舰封版规约落地**：动效全库令牌化（`NovaMotion`）/ 键盘 Esc · Back 可达 /
> 槽位口径校准（统一机制与语义、场景化命名，`overlaySlot` 非必需）/ 模块级 README 交付物 /
> `toolbarSlot` 宿主隔离；全为 `_` 私有 PATCH，公共 API 与指纹零漂移

## 总览分类（6 类 15 项）
主导航布局壳（业务工作台主力，引流核心）
内容排版/多栏工作台壳（文档、预览、对比、配置）
弹窗 & 浮层容器壳（模态、非模态、提示面板）
极简独立页壳（小工具、单页卡片、向导页）
多端专属根壳（桌面、移动端、企业大屏）
AI 对话主窗口（导航轨 + 会话列 + 对话区 + 输入区 + 详情栏）

## 一、主导航布局壳（4个，最核心）
1. **NovaSidebar**（✅ 已封版，首个主推引流款）
    > 结构：侧边栏 + Header + Content + Footer + Overlay
    > 适用：绝大多数工具、管理后台、dev_toolbox_pro、NovaChat、图标画廊、剪贴板保存工具
    > 特点：侧边可折叠，自带导航骨架，是用户上手第一个Shell
2. **NovaTopNavigation**（顶部一级导航，全称自解释）
    > 结构：顶部一级导航栏 + 子菜单下拉区 + 主内容区 + 底部状态栏
    > 适用：软件配置工具、简单企业后台、面向新手的轻量化工具、不想占左侧空间的场景
    > 差异：无常驻侧边栏，适合窗口宽度不大、功能模块不多的应用
3. **NovaDualSide**（双侧边）
    > 结构：左侧导航目录 + 右侧属性面板 + 中间主内容 + Header + Footer
    > 适用：编辑器、配置器、节点工具、QML预览工作台、资源管理器（类似Qt Designer、VSCode基础布局）
    > 特点：左右侧栏均可独立折叠，三栏骨架，工业配置软件高频
4. **NovaTabShell**（标签页工作台壳，保留 `Shell` 以避开 Controls.NovaTab 重名）
    > 结构：顶部Tab标签栏 + 标签内容容器 + 底部状态栏 + 全局浮层
    > 适用：多文档打开、多任务并行工具（同时打开多个qml、多个配置文件）
    > 特点：内置Tab激活、关闭、新增信号；每个Tab内部可嵌入任意Shell/页面

## 二、多栏内容工作台壳（3个，专业向，吸引进阶开发者）
5. **NovaThreeColumn**（三栏固定工作台）
    > 结构：左目录树｜中列表｜右详情预览
    > 适用：文档阅读器、资源库、图标库画廊、日志查看器、API文档工作台
    > 特点：三栏宽度均可拖拽分割，内置分割条，适配Material Symbols图标画廊场景
6. **NovaCompare**（双栏对比壳）
    > 结构：左右对等双内容面板 + 顶部统一控制栏 + 底部状态栏
    > 适用：代码对比、SVG图标对比、配置对比、新旧版本diff查看器
    > 特点：等宽布局，同步滚动可选属性，专门面向开发工具场景
7. **NovaCardGrid**（卡片工作台壳）
    > 结构：顶部筛选/搜索栏 + 自适应卡片网格容器 + 底部分页状态栏
    > 适用：组件画廊总览、模板市场、素材库、模板选择器
    > 特点：自适应行列，适合展示大量预览卡片，Gallery首页非常合适

## 三、弹窗 & 浮层容器壳（2个，基础配套，所有Shell共用）
8. **NovaModal**（模态弹窗壳）
    > 结构：遮罩层 + 弹窗容器（标题栏 + 内容槽 + 按钮栏）
    > 适用：配置弹窗、确认框、表单弹窗、导出弹窗
    > 特点：自带键盘ESC关闭、点击遮罩关闭、圆角阴影，主题Token驱动
9. **NovaDrawerPanel**（侧边滑出面板壳）
    > 结构：从右侧/左侧滑出的面板容器
    > 适用：属性面板、详情面板、临时表单，非模态，不阻塞主界面
    > 区别于主Sidebar：它是临时唤起面板，不是常驻导航

## 四、极简独立页壳（2个，轻量化小工具）
10. **NovaSetupWizard**（安装 / 初始化配置向导壳）
    > 结构：顶部步骤指示器 + 当前步骤内容槽 + 底部上一步/下一步按钮区
    > 适用：安装流程、新建工程向导、打包向导、初始化配置向导（WSL安卓打包向导、项目初始化）
    > 特点：内置步骤状态管理、进度展示，只做向导骨架，业务表单放contentSlot
11. **NovaBlankPage**（纯净单页壳）
    > 结构：Header + Content + Footer，无任何侧边/标签导航
    > 适用：独立小工具、简单单页页面、嵌入到其他Shell内部的子页面
    > 特点：最小化骨架，给需要完全自定义布局的高级用户

## 五、多端专属根壳（3个，补齐桌面/移动/大屏）
12. **NovaDesktop**｜桌面应用容器组件
    > 桌面端根壳，内置菜单栏、状态栏、多页面管理，作为PC桌面应用顶层根容器
13. **NovaMobile**｜移动应用容器组件
    > 适配安卓触摸交互、系统安全区、移动端导航，专门用于PySide6移动端打包顶层壳
14. **NovaFlexLayout**｜企业大屏弹性布局组件
    > 自适应大屏、分栏、网格、动态缩放，面向HMI、工控超大分辨率大屏场景
15. **NovaChat**｜AI 对话主窗口组件（对标 WorkBuddy 桌面端主窗口）
    > 结构：导航轨 + 会话列 + 对话区（Header/Content/Composer）+ 详情栏 + 浮层，共六槽
    > 适用：AI 助手、IDE 对话页、企业级 Copilot 工作台
    > 特点：气泡由业务向 `contentSlot` 注入 `NovaChatMessage`；Shell 零会话数据与业务文案，折叠只 emit

---
## ✅ 清单汇总（精简索引版，直接放进LayoutShell总README）
1. NovaSidebar        侧边导航工作台（主推、已封版）
2. NovaTopNavigation  顶部导航轻量化工作台
3. NovaDualSide       左右双侧边三栏工作台
4. NovaTabShell           多标签页工作台（保留 Shell）
5. NovaThreeColumn    目录-列表-详情三栏工作台
6. NovaCompare        双栏对比工作台
7. NovaCardGrid       卡片网格素材画廊
8. NovaModal          模态弹窗壳
9. NovaDrawerPanel    侧边临时滑出面板
10. NovaSetupWizard   安装 / 初始化配置向导壳
11. NovaBlankPage     纯净无导航单页壳
12. NovaDesktop            桌面端顶层应用根壳
13. NovaMobile             移动端顶层应用根壳
14. NovaFlexLayout         企业大屏弹性布局壳
15. NovaChat               AI 对话主窗口（WorkBuddy 桌面端对标）

## 📄 仓库简介（README 可用）
pyside-nova 组合根容器体系是一套对标 Quasar 2.35.5、面向 PySide6 QML 的旗舰布局壳体系，包含 15 个正交无冗余的组合根容器，全部落在第五 QML 模块 `Nova.Composite.LayoutShell` 并于 1.0.0 GA 封版。覆盖工作台导航、多栏预览对比、弹窗浮层、向导、独立单页，同时配套 **NovaDesktop 桌面根壳、NovaMobile 移动端根壳、NovaFlexLayout 企业大屏布局** 与 **NovaChat AI 对话主窗口**，一套布局体系同时适配 PC 桌面软件、安卓移动端、工业 HMI 大屏与 AI 工作台场景。所有组件遵循组合宪法（0.9.0）、**统一槽位机制与语义（槽位名按骨架场景化）**、唯一 `NovaTheme` 视觉令牌门面与 `NovaMotion` 动效令牌门面、独立 Gallery Demo 与独立演示，适合企业级工具、IDE、配置平台、AI 工作台快速落地。

## ✅ 封版状态（1.0.0 GA · 15/15 全部已交付）

| 类别 | 组件 | 状态 |
|---|---|---|
| 主导航（4） | `NovaSidebar` · `NovaTopNavigation` · `NovaDualSide` · `NovaTabShell` | ✅ 1.0.0 GA |
| 多栏工作台（3） | `NovaThreeColumn` · `NovaCompare` · `NovaCardGrid` | ✅ 1.0.0 GA |
| 浮层容器（2） | `NovaModal` · `NovaDrawerPanel` | ✅ 1.0.0 GA |
| 独立页壳（2） | `NovaSetupWizard` · `NovaBlankPage` | ✅ 1.0.0 GA |
| 多端根壳（3） | `NovaDesktop` · `NovaMobile` · `NovaFlexLayout` | ✅ 1.0.0 GA |
| AI 对话主窗口（1） | `NovaChat` | ✅ 1.0.0 GA |

> 15 项全部落在第五 QML 模块 `Nova.Composite.LayoutShell`（单一 `qmldir` 平铺导出），
> 全部进 API 冻结面（139 类型零漂移 / `bfd3d938a2fab7be`）、全部有 Gallery 独立预览页与
> `examples/layout_shell/` 独立演示、全部通过 `check_all.py --tier static` 3/3 门禁。
>
> 统一的是**槽位机制（`property alias`）、单向数据流与纯布局托管语义**，槽位名按骨架范式
> **场景化命名**（完整 15 项真实槽位表见模块 README 与《封版规范 v2.1.0》§4.2）；
> 视觉取 `NovaTheme`、动效取 `NovaMotion`（0.8.0 全量令牌化）、装饰容器标 `// a11y: decorative`。
> 交付物以**模块级 `README.md` 集中承载**，不按组件拆独立子目录（宪法 0.3.0）。

## 🛠️ 0.8.0 旗舰封版规约落地（本次打磨）

- **动效全库统一**：15 项中 8 处 `duration: 200/220/240` 硬编码动画全部改为
  `NovaMotion.duration(NovaMotion.transitionDuration)` + `NovaMotion.easingStandard`；
  `reducedMotion` 无障碍短路与 `speedFactor` 全库调速生效。
- **键盘可达补齐**：`NovaSidebar` / `NovaDualSide` / `NovaTopNavigation` / `NovaChat` 新增 Esc
  收起意图（`focus: true` + `Keys.onEscapePressed`，只 emit 已有信号、不新增 API、
  不自写宿主状态），与既有 Modal / Drawer / Desktop / Mobile 的 Esc / Back 一致。
- **槽位口径校准**：作废草案「固定五槽 / `contentSlot` 必需」，改为统一机制与语义、
  场景化命名、`overlaySlot` 非必需。
- **工程细节**：`NovaDesktop.toolbarSlot` 改独立 `_toolbarHost` 宿主隔离 + 装饰
  `zMarginals` 提级；`NovaFlexLayout` 删未用 `_bandColor`；`NovaTabShell` 校准虚构
  `activeIndex` 注释。
- **交付物补齐**：新增模块级 `README.md`（15 项完整契约 + 依赖组件清单 + 最小示例，
  示例已实测可实例化）；三篇 `docs/white_paper/` 升级 v2.0.0 企业级旗舰封版；
  `README.md` / `README_zh.md` 汲取营销稿营养并校准 1.0.0 GA 真实现状。
- **契约零漂移**：以上全为 `_` 私有 / 注释 / 内部实现变更，公共 API 签名逐字不变、
  指纹 `bfd3d938a2fab7be` 不变（PATCH，无需重签）。

## 🛡️ 0.8.1 四性标准全库回扫（封版规范 v2.0.1）

伙伴点名"其余 6 个组件也按四性标准过一遍"——经全量机检厘定为**全库 15 项回扫**
（0.7.1 / 0.8.0 立规后只修单点，其余组件从未按新规复核；宪法坑位 18：新条款入宪即
全库回扫，无"其余免检"）。四类合规债全清，全为 `_` 私有 PATCH、指纹零漂移：

- **装饰实心度**：20 余处 `opacity: 0.18~0.7` 身份装饰统一 ≥ **0.85**（三类显式注释例外：
  功能性遮罩 `_mask` / `_scrim`、交互禁用态、阴影层）；
- **RTL**：14 项根 Item 补 `LayoutMirroring.enabled: NovaTheme.isRtl`（**15/15**）；
- **几何入参钳制**：新增 **39 个** `_` 私有 `readonly` 钳制属性、**54 处**几何引用改走
  钳制值；栏高下界 **24**；`NovaModal` 补 `_maxW` / `_maxH` / `_chromeH` 修内容区负高；
- **身份装饰层叠**：17 处补 `z: zMarginals` 提级；**中央底纹不得提级**（DualSide 网格
  点阵留在业务注入之下）。

> 实测基线：**15/15 极端非法入参稳态几何非负**（每项 34 组，等 Behavior 动画收敛后测）、
> 31/31 无头实例化、明暗令牌实时切换 PASS、`reducedMotion` 300→0ms PASS、双主题实心
> 注入审计图 15/15 重渲染（`docs/screenshots/composition_identity_audit*.png`）、
> 静态门禁 3/3、专项 48/48、qmllint 0 error（593 warning 与基线一致）。
## 0.9.0 组合态一致性契约（2026-11-25 · NovaChat 首例）

伙伴点名「单个旗舰封版组件组合到一起就掉链子、没有 Quasar 丝滑」→ 诊断结论：
**`NovaTheme`（L0 令牌）与业务注入（L2）之间缺 L1 装配层**。宪法新增第 9 章 CC-1~CC-8
（组合上下文唯一密度源 / 唯一分隔源 / 装饰预算与禁止仿交互控件 / 层级色阶 / 动效同步与
恒定锚链 / 槽位内容基线 / 装配态验收 / 参考实现纪律），封版规范升 v2.1.0。

**最硬的一条实测发现**：`property alias xxxSlot: _host.data` 只保证「放得进」，
注入的顶层 `Item` 默认 **0×0**，内部 anchors 算出负宽高被裁——这正是「中央永远空板」
的真因。故槽位注入顶层一律 `anchors.fill: parent`，内容限宽居中。

`NovaChat` 首例落地（全 `_` 私有 PATCH、公共 API 逐字不变、指纹 `bfd3d938a2fab7be` 不变）：
13 个组合上下文常量六轨共享、边界收敛为唯一分隔源 + 主色系顶层线、20+ 仿控件装饰
改为抽象几何、三段折叠共用 `_dur`/`_ease`、showcase 六槽真实业务注入 + 调参面板默认收起。
验收：浅色 / 深色 / 折叠三态渲染审计（`docs/screenshots/chat_showcase_*.png`）、
QML 零错误、对象树无 0×0 / 负宽高。其余 14 项按「稳步推进、逐个打磨」分阶段迁移。

## 0.9.1 CC 迁移批次 2（2026-11-25 · 三大多端根壳销号）

伙伴立节奏「**优先组合组件 → 组合打磨中若暴露单个组件问题再反向打磨**」，点名
`NovaChat` 评估 → `NovaDesktop` → `NovaMobile` → `NovaFlexLayout`。逐项完成 CC-1~CC-8
迁移：三元锚链改「栏高归零 + 恒定锚链 + 同步 `Behavior`」；三色撞色 / 伪按钮收敛主色系
抽象几何；槽位宿主铺满 + 注入顶层 `anchors.fill: parent`；三个演示重做成品级 showcase
（调参面板默认收起）。**反向打磨仅 1 次**：深色出图审计暴露 `NovaMobile` 灵动岛融合，
直接修该组合组件，未改 Controls 基础组件。

验收：4 × 浅 / 深 / 变体共 12 张三态渲染图、QML 零错误、静态 3/3、专项 48/48、
31/31 实例化、4 组件极端非法入参 0 负几何、RTL 4/4、reducedMotion 300→0ms、
qmllint 0 error / 593 warning、**139 类型零漂移 · 指纹 `bfd3d938a2fab7be` 不变**。
逐项销号台账见 `CEILING_AUDIT.md`（**4/15 已销号**），其余 11 项按节奏推进。
