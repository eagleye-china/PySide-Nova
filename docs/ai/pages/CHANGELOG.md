# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] - 2026-11-25 — GA 正式版（PyPI 发布）

### Changed（旗舰封版规约落地 · 组合宪法 0.8.0 · 伙伴："汲取营养融入 README / 优化完善两篇白皮书为企业级旗舰封版 / 为咱们所用再次打磨重构 15 项" · patch 实现变更指纹不变）

**文档（企业级旗舰封版）**
- `docs/white_paper/` 三篇全部升级 **v2.0.0**：
  - 《Prescient Layout Shell 封版规范》——补「法源与封版资格」声明（FROZEN 为记录性，
    资格由 API 冻结门禁授予）；适用范围 11 → **15 项**、第五模块 URI 与五模块物理映射；
    **第 4 章槽位契约重写**（作废「固定五槽 / `contentSlot` 必需」错误口径，给出 15 项真实
    槽位权威表 + 浮层槽透明契约 + 宿主隔离）；第 5 章目录结构重写为单一模块平铺；
    第 6 章补 `NovaMotion` 动效令牌与 `outlineStrong` / `textOnPrimary` 真实令牌；
    第 7 章明确身份元素不违反 D-013 的合规边界；第 8/9 章对齐真实门禁与交付物；
    第 12 章 Root Shell / AI 主窗口改为已 GA 封版；成熟度表全部改为 ✅ 1.0.0 GA。
  - 《旗舰组件库白皮书》——保留品牌宣言 / 痛点 / Slogan / 对比表 / 文案库营养，
    「11 + 3 规划中」全部校准为六类 15 项 ✅ 1.0.0 GA；新增 §4.4 封版成果与
    §8「基线 + 实测」双列工程规范；演进路线拆为「已达成 / 后续工程项」并加不夸成熟度声明。
  - `pyside-nova-README.md` —— 校准为对外营销版素材 v2.0.0（真名 / 真状态 / 可执行示例），
    消除旧 `Nova*Shell` 命名、`title` 伪属性与草案痕迹。
- `README.md` / `README_zh.md` 汲取营销稿营养重写：品牌宣言、架构分层图、旗舰四性、
  全端覆盖、跨端对比、适用场景、Slogan 与文案库；状态由 0.3.0 / 12 组件 / M1–M3 规划中
  校准为 **1.0.0 GA / 139 类型 / 五模块 / 15 组合根容器 / Quasar 2.35.5 / 478 项 pytest**。
  事实核实纠正：Quasar 基线 2.26.0 → **2.35.5**；`NovaField/Form/Select/Date/Table/Layout`
  等原标 🚧 M1 实为**已注册实现**；`NovaSidebar` **无 `title` 属性**（营销稿伪属性已删）。
  **README 快速上手示例经真实 QML 引擎实例化验证可执行**。
- 新增 `src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md` —— 补齐白皮书第 9 章 /
  宪法第 8 章要求的交付物：15 项完整属性 / 信号 / 函数 / 槽位契约、**依赖组件清单与
  15 项依赖矩阵**（D-013 前置门禁产物）、最小示例、验收状态与维护纪律。
- `docs/COMPOSITION_CONSTITUTION.md` 升 **0.8.0**：第 4 章槽位口径校准、第 6 章令牌白名单
  补全 + 动效令牌强制落地、第 7 章键盘可达清单、第 8 章模块级 README 交付物、
  坑位表补 16（散落动画参数）/ 17（援引早期草案口径）、迭代记录登记。
- `docs/layout_shell/PrescientLayoutShell.md` 权威清单：删旧对话残留与规划态「落地顺序建议」，
  改为 15/15 封版状态表 + 0.8.0 规约落地记录；`qmldir` 头注释补封版声明。

**代码（15 项组合根容器再次打磨，全为 PATCH 内部实现变更）**
- **动效全库令牌化**：`NovaSidebar` / `NovaTopNavigation` / `NovaDualSide` /
  `NovaSetupWizard` / `NovaChat` 共 **8 处** `duration: 200/220/240; Easing.OutCubic`
  硬编码全部改为 `NovaMotion.duration(NovaMotion.transitionDuration)` +
  `NovaMotion.easingStandard`（新增 `import Nova.Design`）。由此全库节奏统一、
  `NovaMotion.reducedMotion` 无障碍短路与 `speedFactor` 全库调速自动生效
  （落实宪法第 6 章第 3 条与白皮书「动画全库统一」）。
- **键盘可达补齐**：`NovaSidebar` / `NovaDualSide` / `NovaTopNavigation` / `NovaChat`
  新增 `focus: true` + `Keys.onEscapePressed`，**只 emit 已有信号**（收起 / 关闭意图），
  不新增公共 API、不自写宿主状态；与既有 Modal / Drawer / Desktop / Mobile 的 Esc / Back 一致。
- **槽位宿主隔离**：`NovaDesktop.toolbarSlot` 由 `_toolbar.data` 改指独立 `_toolbarHost`，
  装饰 Row 提级 `NovaTheme.zMarginals`，避免业务注入遮挡身份元素。
- **清理**：`NovaFlexLayout` 删未使用的 `_bandColor`；`NovaTabShell` 校准虚构
  `activeIndex` 注释为「纯装饰身份元素，不绑定业务状态」。

**验收（发布边界归伙伴）**
- **公共 API 签名逐字不变、冻结指纹 `bfd3d938a2fab7be` 不变**（139 类型零漂移，
  PATCH 无需重签，恰证 Solidity 与 Aesthetics 可兼得）。
- 静态门禁 `check_all.py --tier static` **3/3 PASS**（a11y 139/139 · API 冻结 · qmllint 0 error）、
  专项 `test_api_freeze.py` + `test_layout_shells.py` **48/48**、
  **31/31 无头实例化**（15 组件 + Gallery + 15 演示）、README 示例实例化 OK、
  qmllint 零新增告警。

### Changed（NovaChat 多轨按轨分治 · 宪法 0.7.1 · 伙伴点名纠正 · patch 实现变更指纹不变）
- **`NovaChat` 6 轨重构**：伙伴点名"NovaChat 那套多轨结构也按这个思路重构一下"——
  0.7.0 把 `NovaChat` 当"多轨标杆"漏改，实则 6 轨各自仍是同一
  "`surfaceAlt` 平铺方块 + `NovaSeparator` + 220ms 宽度动画"模板，只是轨数多、无身份。
  本次给每条轨注入**独占且互不重复**的前景签名：顶层三段品牌发丝线 /
  导航轨（圆形渐变徽记 + 三级激活图标位 + 账户锚 + 缘轨）/
  会话栈（圆角搜索胶囊 + 左缘激活竖条 + 十字新建圆钮）/
  对话区（在线状态点 + 三点位 + 四角取景框）/ 输入区（浮起胶囊 + 附加十字 + 纯几何发送箭头）/
  详情栏（分段 tab + 缘轨）。签名只占边缘/角标，中央内容区完全留给业务注入。
- 全为 `_` 私有纯几何装饰、零业务语义、**零字体依赖**（发送箭头由 Rectangle + rotation 组合，
  规避 offscreen 字体符号豆腐块）；装饰实心度 ≥0.85，浅色 + 深色主题实心业务注入下均清晰对比。
- **公共 API 签名逐字不变、指纹 `bfd3d938a2fab7be` 不变**（patch 实现变更，无需重签）；
  宪法第 6 章新增第 6 条（多轨按轨分治）/ 第 7 条（浮层槽透明契约）、坑位表补 14/15。
- 验证：浅色 + 深色主题真实注入渲染验收（6 轨全展开、身份可辨）、15 格对比拼图与
  `docs/screenshots/chat_identity_audit*.png` 同步更新、静态门禁 3/3、专项 48/48、
  Gallery+15 演示 16/16 无头加载、15 项 qmllint 0 告警、chat 演示 qmllint 0 告警。

### Changed（身份差异化重构 · 宪法 0.7.0 · 伙伴点名纠正 · patch 实现变更指纹不变）
- **15 项组合根容器逐项重塑独有结构性身份元素**：伙伴点名"除 NovaChat 外基本都一个面孔"——
  0.4.0~0.6.0 的 14 项共用同一"平铺背景 + Header/Page/Footer + 220ms 宽度动画"模板仅换槽位名。
  本次逐项给出身份语言：Sidebar 品牌渐变轨+浮起侧栏卡、TopNavigation 胶囊导航台+悬浮下拉、
  DualSide 中央画布点阵+双侧浮起栏、TabShell 材质标签栏+下划线指示、ThreeColumn 三级深度色阶+
  拖拽 grip、Compare 中缝圆形调节柄+A/B 色条、CardGrid 工具条胶囊+Flow 网格、Modal 顶部三色条+
  catcher+浮起阴影、DrawerPanel 侧缘渐变轨+grabber、SetupWizard 三态步骤时间轴、BlankPage 居中
  阅读栏、Desktop 窗口控制点+分层栏、Mobile 灵动岛+home indicator、FlexLayout 三色面板网格、
  Chat 多轨标杆。
- 身份元素全为 `_` 私有纯装饰、零业务语义、**公共 API 签名逐字不变、指纹 `bfd3d938a2fab7be` 不变**
  （patch 实现变更，无需重签——恰证 Solidity 契约稳定与 Aesthetics 美学可兼得）；
  宪法第 6 章第 5 条立强制条款、坑位表补 13 防回退。
- 验证：渲染审计 15/15 出图（身份可辨）、静态门禁 3/3、专项 48/48、Gallery+演示 16/16 无头加载、
  qmllint 零新增告警。

### Changed（缩写全称化 · 宪法 0.6.0 · 伙伴拍板 · 单次重签）
- **`NovaTopNav` → `NovaTopNavigation`**：0.5.0 的"缩写可维持"结论被伙伴拍板推翻——
  旗舰公共 API 以自解释优先于字数精简；演示目录 `top_nav/`→`top_navigation/`，
  Gallery / a11y / 测试 / 权威清单 / PARITY / 宪法全量同步。
- 15 项总数不变，冻结面单次重签（宪法第 8 章批量纪律）。

### Changed（语义正名 · 宪法 0.5.0 · 伙伴拍板 · 同批重签）
- `NovaTabWorkspace` **改回 `NovaTabShell`**：撞 Controls 已有 `NovaTab` 时保留 `Shell`
  后缀，而非生造别名（0.4.0 的"一律去后缀"过严）；演示目录 `tab_workspace/`→`tab_shell/`。
- `NovaTopNav` 评估后**维持不扩写**（`Nav` 为 UI 领域通用缩写，与 `NovaSidebar` /
  `NovaDualSide` 粒度一致，不改为 `NovaTopNavigation`）。
- `NovaWizard` **正名为 `NovaSetupWizard`**（明确安装 / 新建工程 / 初始化配置用途）；
  演示目录 `wizard/`→`setup_wizard/`，Gallery / 契约表 / 权威清单 / 宪法 / PARITY 全量同步。
- 15 项总数不变，冻结面整批单次重签（宪法第 8 章批量纪律）。

### Changed（破坏性 · 1.0 GA 命名定稿 · 宪法 0.4.0 · 伙伴拍板）
- **版本号 1.0.0rc1 → 1.0.0 正式版**（发 PyPI stable）；`src/pyside_nova/__about__.py`
  唯一版本源更新，冻结清单 `packageVersion` 与 AI 索引版本随生成器同步。
- **14 项组合根容器去 `Shell` 后缀**（模块 URI 已表达组合身份，类型名冗余）：
  `NovaSidebarShell`→`NovaSidebar`、`NovaTopNavShell`→`NovaTopNav`、
  `NovaDualSideShell`→`NovaDualSide`、`NovaThreeColumnShell`→`NovaThreeColumn`、
  `NovaCompareShell`→`NovaCompare`、`NovaCardGridShell`→`NovaCardGrid`、
  `NovaModalShell`→`NovaModal`、`NovaDrawerPanelShell`→`NovaDrawerPanel`、
  `NovaWizardShell`→`NovaWizard`、`NovaBlankPageShell`→`NovaBlankPage`。
  **`NovaTabShell`→`NovaTabWorkspace`**：机械去后缀会撞 Controls 已有 `NovaTab`，
  触发冻结门禁跨模块重名红线；`NovaDesktop`/`NovaMobile`/`NovaFlexLayout` 本就无后缀，不变。
  这是破坏性 API 变更，故在 GA 前一次性完成，不升 2.0。
- 演示目录同步去 `_shell` 后缀（`examples/layout_shell/sidebar/` 等 11 个），
  Gallery、测试、生成器契约表、权威清单、宪法与 PARITY 审计全量同步。

### Added（第 15 项组合组件 · NovaChat · 对标 WorkBuddy 桌面端主窗口）
- **新增 `NovaChat`**：AI 对话主窗口根容器，六槽（导航轨/会话列/对话区/输入区/详情栏/浮层），
  `NovaHeader`+`NovaPage`+`NovaFooter`+`NovaSeparator` 真实公共类型组合；
  对话气泡由业务向 `contentSlot` 注入 Controls 已有的 `NovaChatMessage`（主窗口+气泡各司其职）；
  零业务会话数据、零写死文案、折叠只 emit、令牌驱动、`// a11y: decorative`。
- 新增 `examples/layout_shell/chat/` 独立演示（真实气泡渲染 + 六槽注入 + 调参 + signal 回显），
  Gallery 增第 15 页；15 演示 + Gallery 无头加载 16/16 通过，NovaChat 演示 qmllint 零告警。
- 冻结面一次重签（宪法第 8 章批量纪律）：138→139 类型，指纹
  `a8859ec8fc5720bf`→`2d7f173b8f13b123`；decorative 78→79；静态三门禁 3/3 PASS，
  API 冻结+布局专项 48/48 PASS。

## [Unreleased] - 2026-11-25

### Changed（治理 · 组合组件专属模块升格 · 宪法 0.3.0 · 伙伴拍板）
- 应伙伴要求，14 项组合组件从 `Nova.Controls` 物理迁至新模块
  `src/pyside_nova/qml/Nova/Composite/LayoutShell/`（URI `Nova.Composite.LayoutShell`），
  独立 `qmldir` 导出 14 项——**合法模块、非黑户**，冻结面与门禁纪律不变。
- 组合宪法升 **0.3.0**：第 2 章目录纪律将该目录升格为合法专属模块、坑位 7 与准入清单同步；
  母法 `docs/CONSTITUTION.md` 第 1 章补第五模块 URI。14 项类型名不变，整批单次重签冻结面。
- `examples/layout_shell/` 14 个子目录演示 + Gallery 的 import 同步改为新 URI；
  生成器（冻结/清单/AI 文档）、门禁、测试模块注册全量同步。

### Added（14 项 Prescient Layout Shell · 一次交付 · 组合宪法 0.2.0 合规重签）
- **14 个组合根容器 QML 一次落地**，全部进 `Nova.Controls` qmldir（合法导出、非黑户）：
  - 主导航 4：`NovaSidebarShell` / `NovaTopNavShell` / `NovaDualSideShell` / `NovaTabShell`
  - 多栏工作台 3：`NovaThreeColumnShell` / `NovaCompareShell` / `NovaCardGridShell`
  - 弹窗浮层 2：`NovaModalShell` / `NovaDrawerPanelShell`
  - 极简独立页 2：`NovaWizardShell` / `NovaBlankPageShell`
  - 多端根壳 3：`NovaDesktop` / `NovaMobile` / `NovaFlexLayout`（保留权威清单原名）
- 全部遵循组合宪法：≥2 个已导出公共类型组合、标准槽 alias、单向数据流（只 emit）、
  `NovaTheme` 令牌驱动、`// a11y: decorative` 标记、非法入参钳制、`pragma ComponentBehavior: Bound`
  零新增 warning、两行头注释无日期流水。
- **整批单次重签 API 冻结**：124→138 类型（Controls 91→105），指纹
  `f2fd1b0eacf665f2`→`3bc0fb035fa927ab`；同步 `API_FREEZE.md` / COMPONENT_LIST /
  A11Y_MATRIX（decorative 64→78）/ AI 文档；`test_api_freeze` 常量同步。
- 独立 Gallery `examples/gallery/layout_shells.qml` + `layout_shells.py`：14 页逐项真实预览、
  调参面板（折叠/显示栏/尺寸）、明暗切换，零运行时警告；不侵入主画廊。
- 新增 `tests/test_layout_shells.py` 20 项（14 实例化 / 槽位 / 主题 / 边界 / 列数钳制）。
- 静态三门禁 3/3 PASS；qmllint `import` 预算校准（RC1 漏记 `Nova.Runtime` 一条，1→2，非新增欠债）。

### Changed（治理 · 组合组件宪法 0.2.0 · 14 项一次交付适配）
- `docs/COMPOSITION_CONSTITUTION.md` 升 0.2.0：抬头新增**母法权威版本声明**（唯一法源 =
  `docs/CONSTITUTION.md` 0~13 章；根目录 0~10 章副本不得援引），法源补第 11/12 章；
  第 0 章明确 `NovaDesktop`/`NovaMobile`/`NovaFlexLayout` 三个无 `Shell` 后缀的多端根壳同样受约束；
  第 1 章语义分类由 3 类扩为**与 14 项权威清单对齐的 5 类**（逐类型核实为真实导出，无虚构 API）；
  第 8 章新颁**批量交付纪律**（整批登记 → 单次重签 → 整批验收，禁止逐个重签产生中间指纹）
  与生成物保护条款；坑位表补第 9/10 条。

## [Unreleased] - 2026-11-24

### Added（治理 · 组合组件宪法首颁）
- **新增 `docs/COMPOSITION_CONSTITUTION.md`**：《组合组件宪法 — pyside-nova Layout Shell
  Constitution》，母法《架构宪法》的子法，第 0~9 章——三要素定义 / 四模块目录与黑户禁令 /
  三层边界与单向数据流 / 五标准槽位 alias 契约 / D-013 组合完整性 / 真实令牌白名单 /
  鲁棒性与 a11y / 准入门禁清单 / 8 条反模式坑位。只定义在母法 L1 之上的组合纪律，
  令牌·目录·命名·冻结一律援引母法，不另立门面。
- 明确 `docs/layout_shell/` 历史四稿中的 "v1.0.0 FROZEN / 已封版" 表述与
  `Theme.*` / `NovaButton` / `NovaLabel` / `NovaAnimation` 等虚构 API **一律作废**；
  吸收其三层边界·槽位语义·组合优于继承·D-013 精华并校正为真实 API 面。
- 接入 mkdocs「工程纪律」导航、首页文档导航；`scripts/gen_apidocs.py` 的 PAGES 清单加入新页，
  重跑 AI 索引（13 页，指纹 0ffe8bd37c9827dd）。

### Added（库管员 + 成品验收员工具 · 一键总验收入口）
- **新增 `scripts/check_all.py`**：分层串跑全部门禁的统一入口。四层——`static`（默认，
  a11y/api/qmllint 三道秒级门禁，与 local_deploy 交付链一致）/ `dynamic`（perf + visual
  smoke + soak 冒烟 + hidpi）/ `supply`（cve）/ `all`（8 道全覆盖；封版加 `--soak-24
  --visual-full --cve-online` 为完全体）。`--brief` 摘要模式、`--report PATH` 落验收 JSON、
  `--list` 列举门禁。
- **统一退出码语义**：0=全绿（含 WARN 有条件通过）/ 1=至少一道产品红或工具 ERROR /
  2=未执行门禁（参数错误或环境缺失）。红灯先定性：cve 缺 SBOM/缓存(码2)判 WARN 前置缺失，
  不计产品红；环境预检发现无 PySide6 的解释器直接判 ERROR(码2)终止，杜绝假绿灯/假红灯混淆；
  子门禁统一用 `sys.executable` 启动保证解释器一致性。

### Added（RC2 封版验收 · 24h 内存长跑压测门禁）
- **24h 压测工具链**：`scripts/check_soak.py`（CLI 门禁，`--hours/--interval/--report`，退出码入 CI）
  + `tests/test_soak.py`（pytest 承载，复用单引擎/单斜杠/硬退出纪律）
  + `tests/soak_mem.py`（零第三方依赖 RSS 采样：Windows psapi / Linux statm + 三段稳健趋势判定）。
  冒烟 72s / 8896 轮 / 25 样本，RSS 84.6→84.9MB 全程平坦、斜率 -2.78MB/h，门禁通过。
- `tests/conftest.py` 新增 `--soak-hours/--soak-interval/--soak-report` 与 soak 硬退出标志
  （坑位 49），`.gitignore` 忽略 `reports/`。
- `docs/ECOSYSTEM_PARITY.md` §6「24h 压测」勾选（工具就绪 + 冒烟通过；真实 24h 全量长跑留 CI）。

### Fixed（验收工具链 · 中文 Windows 兼容性）
- `scripts/check_qmllint.py` 两处 Windows 假红灯修复（坑位 52）：① `find_qmllint()` 包内
  只找无后缀 `qmllint`，而 Windows 实际是 `qmllint.exe` 且 Scripts/ 无入口脚本 → 显式列
  两种后缀候选；② `subprocess.run(text=True)` 走 locale 默认编码（中文 Windows=GBK），
  诊断含 UTF-8 路径时 `UnicodeDecodeError` 崩溃 → 改 `encoding="utf-8", errors="replace"`。
  修复前门禁在交付机假红灯，修复后真实退出码 0（0 error / 593 warning 全在预算内）。

### 设计决策（踩坑沉淀，勿回退为「反复建销组件」负载）
- 负载采用**稳态对象池**：一次创建弹层/表格长期持有，只做 register/unregister、派生属性读取、
  主题/i18n 切换。采样前驱动 JS（`engine.collectGarbage()`）+ Python 双 GC，读 GC 后驻留 RSS。
- **不测「反复创建/销毁复杂 QML 组件」**：实测 Qt 6.12+PySide6 每建销一个复杂组件有
  0.3-0.5MB 不可回收固有开销——纯 Qt Quick 组件（无 Nova 代码）同样复现，属引擎层行为，
  纳入会让门禁永远红灯、掩盖产品真泄漏。

## [1.0.0rc1] - 2026-11-23

### Added（六期 RC1 收口 · **API 冻结审查**：测试 427 → 454、类型 124 不变）

- **冻结清单双件制**：`api/nova-api-1.0.0.json`（schema `nova-api-freeze/1`，124 类型逐成员
  签名——`props`/`signals`/`methods` 以 `名字:类型` / `名字(参数)` 串快照，`_` 前缀私有成员
  **不进面**；内容指纹 `f2fd1b0eacf665f2`）+ `docs/API_FREEZE.md`（口径表 / 统计 / 语义化
  变更政策 / 签署六勾 / 例外登记 / 124 行全量明细）。两者均由 `scripts/gen_api_freeze.py`
  生成，**禁止手改**
- **API 冻结门禁** `scripts/check_api_freeze.py`：现网面 vs 清单**逐成员**比对，结果分三桶
  ——破坏性（删类型 / 改签名 / 移模块 / 改 a11y）/ 增量（新类型 / 新公共成员）/ 纪律
  （`on*` 前缀、基类成员撞名、qmldir `//`、版本非 1.0、文件名不符、缺 `pragma Singleton`、
  `Component.onDestroyed`）；另校验**清单指纹自洽**（手改清单绕过门禁也会红）
- **qmllint 门禁** `scripts/check_qmllint.py`：error **零容忍** + warning **分类预算制**
  （`tests/lint-baseline.json`：unqualified 552 / missing-property 24 / 其他 10 /
  id-shadows-member 4 / property-override 2 / import 1，共 593），`--update` 只允许下调
- **交付前串跑三道门禁**：`local_deploy.py` 新增第 0 步——`check_a11y` → `check_api_freeze`
  → `check_qmllint`，任一红即拒绝出包（`--no-gates` 仅限应急）
- **废弃机制落地**（第 13 章政策 4 的运行时载体）：`NovaUtils.logOnce(key, msg)` +
  `NovaUtils.deprecate(type, api, replacement, removedIn)`——同一 key 只播一次，不刷屏、
  不污染绑定

### Fixed（冻结审查抓出的真实缺陷，静态门禁与逐文件审阅交叉命中）

- **NovaColorPicker**：HEX 输入框底色写 `NovaTheme.background`——该令牌**不存在**（主题令牌
  为 `page`/`surface`/`surfaceAlt`），赋值 undefined 导致输入框底色丢失 → 改 `NovaTheme.surface`；
  焦点边框写 `root.tint`——该组件无 `tint` 属性（非 NovaField 派生）→ 改
  `hasError ? negative : primary`（并保留未聚焦时的 `outline`）
- **NovaText**：`readonly property var style` **覆盖了 `Text.style` 枚举**（基类成员撞名，
  outline/stroke 渲染语义被吃掉）→ 更名私有 `_style`，`Text.style` 原生语义归还
- **examples/gallery**：同款幽灵令牌 `NovaTheme.background` 2 处 → `surface`

### 变更政策（1.0 起生效，宪法第 13 章）

| 变更 | 版本动作 | 门禁 |
|---|---|---|
| 删类型 / 改签名 / 移模块 / 改 a11y 分类 | 仅 major | 红，须重签清单 |
| 新增类型 / 新增公共成员 | minor + 重签 | 红，重签后绿 |
| 私有成员 / 默认值 / 内部结构 | patch | 绿，不重签 |

### 坑位沉淀（50~51）

- **50**：`qmllint` 的诊断**全部写到 stderr**（stdout 只有源码片段），用 `capture_output`
  只读 stdout 会得到「0 warning」的假绿灯——预算门禁必须合并两股流（`stderr=STDOUT`）
- **51**：解析模块限定类型名（`Nova.Behaviors.NovaMorph`）用 `split(".", 1)` 会切出
  `Behaviors.NovaMorph`——模块名自身带点，**必须 `rsplit(".", 1)`**；同批：qmldir
  `singleton <名> <版本> <文件>` 的版本位比普通行右移一格，正则要按 `singleton` 前缀偏移

### 诚实边界（RC2 待办，与 API 面解耦）

24h 内存长跑 / NVDA 真机回归 / 安装器与代码签名（需平台证书）/ 迁移指南 + LTS 承诺书；
`[unqualified]` 552 条按预算挂账（根治需全库 `pragma ComponentBehavior: Bound`）；
应用包 185.7MB 未达 ≤60MB（Qt 运行时物理下限）。

## [0.16.2] - 2026-11-23

### Added（五期 Sprint B3 收口 · **工程化外环**：测试 394 → 427、类型 124 不变）

- **视觉回归门禁**（`tests/test_visual.py` + `scripts/check_visual.py`）：**明/暗 × 5 断点
  （xs=480/sm=800/md=1200/lg=1600/xl=1920）× 全画廊 24 页 = 240 张基线**（256 色量化 PNG，
  12MB）；diff 口径单通道差 >12 / 占比 >1%（容忍反走样 + 量化噪声）；默认全量只跑 smoke
  抽检（秒级），全矩阵由 CLI `--visual-full` 承载（~150s）
- **画廊在线预览页**（docs/GALLERY.md + 24 张真实离屏渲染截图）：QML 无法浏览器运行的
  "在线示例"等价呈现（视觉回归基线集抽帧）
- **外部输入消毒**（供应链门禁，对标 Quasar 2.32~2.35 安全硬化）：
  - `NovaUtils.sanitize` 组（escapeHtml / stripControlChars / sanitizeUrl / clampLength /
    safeText 组合拳）——注入面裁定：Text 默认 AutoText 会把含 HTML 字符串按富文本解析
    （RichText 走 QTextDocument 可外联资源）
  - `NovaRuntime.sanitizeText/escapeHtml/stripControlChars/sanitizeUrl` Python 侧 Slot
    （语义 1:1，供 MCP/CLI/存储回读路径）
  - **组件加固 9 处**：NovaNotificationItem ×4 / NovaDialogCard ×3 / NovaLoadingOverlay /
    NovaTooltip 文案 Text 显式 `textFormat: Text.PlainText`
  - `tests/test_sanitize.py` 32 项（XSS 样本 / ANSI 转义 / 零宽字符 / scheme 白名单
    javascript:data:vbscript: / 长度钳制 / Python 镜像 / 组件静态门禁）
- **CycloneDX SBOM + CVE 周巡**：`scripts/gen_sbom.py`（零第三方依赖离线生成，许可证逐包
  读取）+ `scripts/check_cve.py`（OSV.dev querybatch 联网查询 / --offline 缓存 /
  --fail-on 阈值入 CI / `.cve-ignore` 忽略清单带理由）；首轮巡检 3 组件 0 未忽略漏洞
  （pytest 2 项 dev-only 漏洞经评估登记不随运行时分发）
- **一键应用打包**：`scripts/build_app.py`（PyInstaller onefile，gallery_launch.py 入口）+
  `examples/gallery_launch.py`（打包后从 sys._MEIPASS 解析 QML 资源）；Linux 产物
  `dist/nova-gallery`（185.7MB，PySide6 全运行时物理下限）**启动自检通过**；
  uv venv（shared python）构建路径与 Windows exe / 代码签名边界已记录
- **MkDocs 文档站**（可搜索 + 在线示例，material 主题明暗切换）：15 页 / 搜索索引 /
  全画廊预览页；`mkdocs.yml` + `docs/index.md` 首页；构建 1.3s / 产物 4.9MB

### 坑位沉淀（49）

- **49**：全矩阵视觉长跑（240 截图 × 150s）后解释器收尾期 GC 触发 shiboken refcount 崩溃
  （`none_dealloc`，deleteLater / 显式 close / gc.collect 均无效）→
  `pytest_unconfigure` 中硬退出（报告已输出完成，保 CI 退出码语义）

## [0.16.1] - 2026-11-23

### Added（五期 Sprint B 第二交付单元 · **i18n + RTL + 性能 + HiDPI 非功能攻坚**：类型 123 → 124、测试 343 → 394）

- **NovaI18n 服务单例**（Nova.Services，第 124 个公共类型；对标 Quasar Lang 插件 `$q.lang` +
  vue-i18n 语义）：`locale/setLocale()` 全局切换、`t()` 词典翻译（`{name}` 插值；三级回落链
  locale 精确 → 主语言码前缀 → en-US → key 本身）、`tp()` CLDR 复数（JS 精简实现七语系：
  zh/ja/ko/th/vi 恒 other、en/de one-other、ru one-few-many、ar 六类别、cs/sk、pl）、
  `addBundle()/addPluralBundle()` 运行时热注入（幂等覆盖）、`formatNumber/formatCurrency`
  （分隔符/货币符号表随 locale）、`formatDate`（命名样式 + 自定义 pattern，
  `Qt.locale(name).toString` 渲染）、`formatRelative`（复数联动）
- **RTL 镜像双轨适配**：`NovaTheme.isRtl/direction` 方向令牌（随 NovaI18n 联动）；
  `NovaPagination`（LayoutMirroring + 箭头字符取反）、`NovaDrawer`/`NovaLayout`
  （`effectiveSide` 逻辑侧换边）、`NovaSlideItem`（loader 镜像 + Left/Right 物理键互换）、
  `NovaBreadcrumbs`（反排重布局）、`NovaStepperNavigation`（LayoutMirroring）；
  **逻辑侧 API 语义恒定**——RTL 只换物理方向，不换语义
- **性能门禁三指标**（`tests/test_perf.py` 3 项 + `scripts/check_perf.py` CLI 包装）：
  冷启动 ≤800ms、全导出类型实例化 ≤5ms/个（预热后两遍测量 + KNOWN_HEAVY 白名单）、
  1000 行 NovaTable 挂载 ≤1700ms
- **HiDPI 门禁**（`tests/test_hidpi.py` 4 项）：QT_SCALE_FACTOR 1.0/1.5/2.0 矩阵下
  devicePixelRatio 联动、逻辑几何恒定；Nova.Runtime 上报 `devicePixelRatio/scaleFactor`
- **a11y 补差**（M2 清单）：`NovaTree` 方向键游标（roving cursor：Up/Down 移动、
  Right 展开 / Left 收起、收起态跳父、环绕式移动；RTL 时 Left/Right 语义互换）；
  `NovaDialogShell` WAI-ARIA 焦点陷阱（打开记录来源焦点并聚焦首项、Tab/Shift+Tab 循环困于
  陷阱内、关闭还焦来源；runtime 应用级事件过滤器承载 Tab 拦截——QML Keys 层收不到 Tab）
- **画廊第 24 页「国际化 i18n」**：locale 切换按钮组、t/tp/复数类别实时联动、
  数字/货币/日期/相对时间格式化、RTL 镜像演示（含 de/ja/ru/ar 四语热注入词典示范）
- **`docs/I18N.md`** 国际化指南（API 一览/词典回落链/复数规则表/RTL 双轨/坑位 43）

### Fixed

- `qrc://` 双斜杠 URL 经 shiboken 解析为带 authority 的路径，`QQmlComponent.setData` 间歇性
  SIGSEGV——**全局替换为 `qrc:/` 单斜杠**（独立脚本/pytest 交错崩溃的总根因，坑位 48 前因）

### 坑位沉淀（43~48，详见 docs/SESSION_HANDOFF.md）

- **43**：Qt 6.12 `Qt.formatDate` 三参重载不存在（pattern 被丢弃）→ `Qt.locale(name).toString(date, pattern)`
- **44**：QQmlExpression + creationContext 对非 Item 对象间歇 SIGSEGV → QML 内定义 helper + Python 直调
- **45**：Tab 在 QQuickItem::keyPressEvent C++ 默认实现被消费不冒泡（Keys.BeforeItem 也拦不到）
  → 应用级事件过滤器；PySide slot 的 QObject 参数 wrapper 是临时的（须强引用）；
  `Item.window` 普通属性 JS 层 undefined → attached `Item.Window.window`
- **46**：QML 函数从 wrapper 调用返回未求值 MetaFunction → 改 `readonly property int` 承载
- **47**：性能测量须两遍法（首建含 QML 编译冷缓存）；NovaDate/NovaEditor 首建 11~15ms 属固有成本
- **48**：干净引擎早期 setData 组件 SIGSEGV（实为坑位 qrc:// 双斜杠）→ 全局 `qrc:/` 单斜杠 + 探针纪律

## [0.16.0] - 2026-11-23

### Added（五期 Sprint B 第一交付单元 · **可访问性攻坚 WCAG 2.1 AA**：类型 120 → 123、测试 322 → 343）

- **NovaA11y 单例**（Nova.Design，第 123 个公共类型）：WCAG 2.1 对比度数学（相对亮度/对比度/
  大小文本判定/AA·AAA·UI 三档门禁）、**AA 兜底派生**（`aaText` 双向取最小位移、`aaFill` 单向压暗
  保品牌色相，二分 22 次收敛）、focus-visible 裁决 `ringVisible()`、状态播报状态机
  `notice()/announcementCount`、语义词汇表。Quasar 2.35.5 无对应模块——Nova 差异化能力
- **NovaFocusRing 行为**（Nova.Behaviors）：键盘模态下为宿主画焦点环（外扩 offset、间隙露表面色、
  填充态按钮上不撞色）；只画不拦事，无指针通道
- **NovaLiveRegion**（Nova.Behaviors）：`NovaA11y.notice()` 的真正播报出口
  （WCAG 4.1.3 Status Messages），宿主根节点放一个即可
- **Nova.Runtime 输入模态**：应用级事件过滤器（`install_input_modality_filter`，随 `init_nova` 幂等安装）
  维护 `keyboardMode`，KeyPress→true / 鼠标·触摸·滚轮→false；QML 侧经 `NovaA11y.keyboardMode` 读取
- **NovaTheme a11y 令牌**：`a11yBase`（最不利表面，派生基准）、`focusRing` + `focusRingWidth/Offset`、
  `outlineStrong`（1.4.11 控件边界 3:1）、`primaryText…infoText` 七个文字安全版、`fillTint()`、
  `textMuted` AA 化
- **123 个导出类型 100% 登记 a11y 契约**：interactive **32**（role + 可读名 + 键盘入口 + 按键路径 +
  焦点环全齐）/ semantic **28** / decorative **63**（故意不挂 Accessible + `// a11y: decorative` 标记）；
  32 个 interactive 全量补齐键盘路径（Enter/Space 激活、方向键组内导航与值步进、Home/End、
  PageUp/Down 月步进、Esc 关闭归位、Delete 移除）；统一新增 `a11yLabel` 可读名覆盖属性
- **`scripts/check_a11y.py`** 静态门禁：解析四个 qmldir × 契约表，逐类型核对 role/name/键盘/焦点环/
  装饰标记，未登记类型直接报错；`--matrix` 生成 `docs/A11Y_MATRIX.md`；退出码可直接入 CI
- **`tests/test_a11y.py` 21 项**：WCAG 数学（黑白 21:1/对称/亮度边界）、AA 派生最小性与色相保持、
  9 文本令牌 × 3 表面 × 明暗双主题全过 4.5:1、边界与焦点环 3:1、QAccessible 运行时角色矩阵
  （19 类型 role/name/disabled 逐项）、键盘激活/切换/翻页/行游标/标签切换/时间步进、焦点环
  键盘可见·指针隐藏、播报计数、静态门禁自检、画廊 a11y 页实例化无运行时错误
- **画廊第 23 页「无障碍 a11y」**：AA 派生色板（本色 vs AA 版实时对比度）、焦点环 Tab 走查、
  键盘全路径演示、播报演示、契约矩阵与门禁命令

### Changed

- `NovaTheme.textMuted` 改为 AA 兜底派生：浅色在 page 上由 **4.31 → 4.50**（`#6E7380 → #6B707C`，
  肉眼无差；暗色不变）
- 填充态按钮底色经 `fillTint()` 压到白字 **4.50:1**（`#5B6EF5 → #576AEB`，色相不变）
- 新增 `outlineStrong` 作为**可交互控件**边界（3:1）；`outline` 保留给装饰性分隔线（1.4.11 只约束
  控件边界，不是所有线条）
- `NovaChip/NovaItem/NovaTab/NovaFabAction/NovaBtnDropdown` 等按 `!disable` 映射 `enabled`，
  使 Qt 无障碍接口能上报 disabled 状态（视觉不变）

### Fixed

- `NovaUtils.colors.luminosity/brightness` 传 QML `color` 值（r/g/b 为 0~1 浮点）时被按 0~255 处理，
  对比度恒为 **1.0**——新增 `_channels255` 归一化（字符串路径不变）；a11y 派生必须能直接吃 color 值
- `Accessible.announce()` 在单例/`Connections` 作用域调用报 *"must be attached to an object deriving
  from Item or Action"* → 播报下沉到 `NovaLiveRegion.speak()`

### Refactor（测试基建）

- 新增 `tests/conftest.py`：**全测试进程共用「一个 QGuiApplication + 一个 QQmlEngine」**，
  模块收尾只关闭窗口不析构引擎；`test_smoke` / `test_a11y` 的 `qml_engine` / `engine` 夹具改为复用。
  原因见坑位 42——多引擎「一个销毁、另一个继续建组件」在 Qt 6.12 下会间歇 SIGSEGV
  （343 项实测 20~60% 概率崩在 `component.create()`，与用例内容无关）；单引擎后连跑 10 次全绿

### Pitfalls（坑位 38~42）

38. `Accessible` 是附加属性，只能在 Item 作用域内调用——单例（QtObject）与 `Connections` 里都不行
39. `Accessible` **没有** `disabled`/`defaultAction`/`ignoresAutomaticName`；禁用态唯一有效途径是
    `Item.enabled: false`（实测 `QAccessible` 接口随之 `state().disabled = true`）
40. `Keys.onEndPressed` 不存在（Qt 6.12）——`End` 走 `Keys.onPressed` + `ev.key === Qt.Key_End`
41. `QTest` 键位测试必须同时强引用 `QQmlComponent`：组件 GC 后其创建出的 Window 立即析构
    （*Internal C++ object already deleted*）
42. **多个 `QQmlEngine` 各自析构会在 Qt 6.12 引发间歇 SIGSEGV**：A 引擎销毁后 B 引擎再
    `component.create()` 有 20~60% 概率崩（与用例内容无关，纯引擎数量相关）→ QML 测试全进程
    共用单引擎（`tests/conftest.py`），模块收尾只 close 窗口、不删引擎；另：Window 活到解释器
    退出而 `QGuiApplication` 已析构是第二类退出期崩溃，靠 session 收尾统一释放规避

## [0.15.0] - 2026-11-23

### Added（五期 Sprint A · **长尾组件一次收口**：Controls 89 → 91、Behaviors 10 → 11 + 新 singleton）

- **NovaEditor**（对标 QEditor）：toolbar 分组配置（数组的数组，组间 separator）、execCmd 命令族
  （bold/italic/underline/strike 行内包裹、h1~h6/quote/code/ul/ol 行前缀、link、removeFormat、
  undo/redo）、modelValue 受控 + updateModelValue 上报（NovaInput 同款 guard 防回环）、
  selectRange/caretPosition 辅助、toHtml() HTML 导出（结构前缀在原始行上判断切片、内容单独转义）、
  placeholder/flat/minHeight/readonly/disable、buttonCount 派生。
  **实现口径留痕**：QEditor 基于 DOM contenteditable，QML TextEdit 无富文本选区格式化 API——
  Nova 以「轻量标记编辑器 + HTML 导出」实现同语义（toolbar 配置/execCmd/modelValue 契约 1:1）
- **NovaSlideItem**（对标 QSlideItem）：正面 default 槽左右拖拽跟手（死区防抖 + clamp）、
  leftSlot/rightSlot Component 动作面板（QSlideItem 的 left/right 撞 Item FINAL 成员改名，
  坑位 12）、释放越 openThreshold 吸附（Behavior OutCubic）、slideLeft/slideRight/reset 命令式
  API、slideOpened(side)/slideClosed/leftAction/rightAction 事件、dense/revealWidth/duration
- **NovaMorph**（对标 v-morph 指令 · Behaviors 族）：group 组内元素形变切换——morph() 时旧活动
  元素退出、ghost 影子从旧几何动画至新几何（跨父级 mapFromItem 映射）、新元素延至动画完成显示；
  morphStarted/morphFinished 信号、isActive() 命令式判定、duration=0 快路径。
  **NovaMorphPool 单例注册表**：group → 当前活动目标 Item；曾用 .pragma library JS 共享注册表
  实测呈现 per-importing-file 实例化（同组两实例互相看不见对方注册）→ 改 QML singleton
  （Services 模块同款惯例）保证引擎级唯一（0.15.0 新沉淀）
- **NovaIconGenie**（对标 @quasar/icongenie，`scripts/gen_icons.py`）：单图生成全套应用图标——
  favicon ×4 + apple-touch ×6 + android ×7 + iOS AppIcon 全档 + 可选 splash ×6（37 产物），
  --background/--padding/--splash、居中缩放合成、icongenie-report.json 产物清单（源图指纹）
- **AI-ready 文档包**（对标 Quasar 2.33 "AI-ready out of the box"，`scripts/gen_apidocs.py`）：
  扫描 qmldir + QML 源生成 `docs/ai/api/*.json`（每公共类型 props/signals/methods/描述 + 行内注释）
  + `docs/ai/pages/`（10 页核心文档离线拷贝）+ `docs/ai/index.json`（版本 + 基线 + 模块计数 +
  内容指纹）——AI agent 从此查询 Nova **版本化 API** 而非依赖训练记忆
- **Nova MCP server**（对标 @quasar/mcp v1.0.0，`scripts/nova_mcp.py`）：stdio JSON-RPC 2.0
  （MCP 换行分隔传输），六工具口径 1:1——search_docs / list_pages / get_page（宽松按节截取）/
  list_api / get_api（带前缀自动宽松匹配）/ check_updates（离线版本+指纹报告）；仅标准库、
  零网络零依赖；"built for small context windows" 口径——search 返回命中摘要、get_page 支持单节
- 画廊第 22 页"长尾组件"（Editor 实时 HTML 导出 / SlideItem 左右滑动 / Morph 卡片⇄详情形变 /
  IconGenie 与 MCP CLI 演示）

### Fixed

- NovaEditor toHtml 结构前缀判断误用转义后文本（"> " 已变 "&gt; " 永不命中）→ 原始行上判结构、
  内容单独转义（切片错位同源修复）

### Changed

- 类型总面：**120 个公共类型**（Controls 91 + Services 15 + Design 3 + Behaviors 11）
- 测试 308 → **322 项全绿**（7 冒烟 + 7 行为：Editor 命令链与 HTML 导出/工具栏按钮计数、
  SlideItem 开合事件链与跟手位移、Morph 零时长切换与 ghost 动画路径、IconGenie CLI 产物尺寸
  与 splash 拒绝守卫、MCP server 六工具 subprocess 全链路）

## [0.14.0] - 2026-11-23

### Added（四期 Sprint B · **弹层与反馈一次收口**：L2 54% → 68%，Controls 73 → 89、Services 10 → 11）

- **NovaMenu**（对标 QMenu）：target 触发（左键/右键 contextMenu）、auto-close（动态挂接子项 clicked）、
  persistent 锁 ESC+外部点击、fit/cover、anchor/self/offset 定位（clamp 宿主范围）、hover 契约、
  show/hide/toggle/updatePosition/focus、进 NovaOverlayHost 弹层栈（ESC 逐层关闭口径）
- **NovaDialogShell**（对标 QDialog 组件壳；Services 单例同名 → Nova 命名红线改名留痕）：声明式遮罩+卡片、
  persistent/no-esc-dismiss/no-backdrop-dismiss、seamless/maximized/fullWidth/fullHeight、五向 position、
  **关闭原因上报 dismissed(reason)**（ok/cancel/backdrop/escape/api，基线 2.28 真 parity）、
  persistent 拒关 shake 动效（shake 事件）
- **NovaPopupProxy**（对标 QPopupProxy）：断点路由（窗口宽/高较小者 < breakpoint → Dialog 形态，否则 Menu 形态）、
  内容槽共享（reparent 迁移/归还）
- **NovaTooltip**（对标 QTooltip）：悬停 target + delay/hideDelay、anchor/self/offset（默认 [14,14]）、
  text 便捷属性或 default 槽、就地渲染 z 提升
- **NovaBottomSheet**（对标 BottomSheet 插件组件壳）：actions 数组（列表/grid 网格）+ default 槽、
  遮罩/ESC 关闭、actionPicked + **dismissed(reason) 关闭原因上报**
- **NovaSpinner**（对标 QSpinner 系列）：variant 八变体 ring/ball/dots/hourglass/gears/grid/radio/comment，
  Canvas 统一相位驱动（坑位 28 显式失效口径）
- **NovaSkeleton**（对标 QSkeleton）：type（rect/text/circle/square/badge/tag）× animation（wave/bounce/fade/none）
  × animationSpeed、size/width/height/square/bordered
- **NovaInnerLoading**（对标 QInnerLoading）：showing、半透明蒙层 + Spinner、default 槽替换、label
- **NovaAjaxBar**（对标 QAjaxBar）：start/increment/stop + **多进程计数**（N start 需 N stop）、
  渐进模拟（越接近 progressCap 越慢）、stop 冲刺收尾、四向 position/reverse、started/stopped 事件
- **NovaLoadingBar 服务单例**（对标 LoadingBar 插件）：命令式 start/increment/stop，懒创建 AjaxBar 挂
  NovaOverlayHost（zTop 层），无窗口降级 no-op
- **NovaBanner / NovaBar**（对标 QBanner/QBar）：三槽横幅（avatar/content/action、inline-actions/dense/rounded）、
  顶栏（dense、primary 底色文字反转）
- **NovaNoSsr**（对标 QNoSsr）：placeholder 文案/槽 → delay（默认下一帧）后切换内容
- **NovaPullToRefresh**（对标 QPullToRefresh · side 四边对标 2.30）：top/bottom/left/right 四向拉动、
  threshold 阈值、refresh 事件、refreshing 受控、trigger() 方法
- **NovaResizeObserver**（对标 QResizeObserver）：target（默认声明父项）尺寸变化 debounce → resize(w,h)
  （NovaScrollObserver 已于 Behaviors 0.7.0 交付——本轮发现规划核对口径：不重复交付）
- 画廊第 21 页"弹层与反馈"（全类型实机演示 + 关闭原因实时展示）

### Fixed

- NovaMenu auto-close 初版 TapHandler 被子项 MouseArea 独占饿死 → 动态挂接子项 clicked 信号（坑位 35）

### Changed

- 类型总面：**117 个公共类型**（Controls 89 + Services 单例 11 + Design 3 + Behaviors 10 + 句柄动作 4）
- 测试 271 → **308 项全绿**（29 冒烟 + 9 行为：菜单 auto-close/弹层栈逐层 ESC/关闭原因上报/persistent
  shake/BottomSheet 动作回报/AjaxBar 多进程计数/PTR trigger 复位/观察器/BtnGroup 样式下发/服务降级 no-op）

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
