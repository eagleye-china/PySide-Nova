# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

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
