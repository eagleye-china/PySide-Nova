# 架构宪法 — pyside-nova Architecture Constitution

> 本宪法是 pyside-nova 的最高工程准则。**每次产品交付都必须随版本迭代更新本文件**
> （见文末迭代记录表），条款变更须在 CHANGELOG 同步说明。与任何其他文档冲突时，以本宪法为准。

---

## 卷首 · CARF 宣言（Manifesto · 最高方法论 · 1.0.1 入宪）

> **CARF — Conceive, Achieve, Refine, Freeze — Culminate to the peak.**
> **构想 · 实现 · 打磨 · 封版，终抵巅峰（天花板）。**
>
> 本宣言位列第 0 章之前，是 pyside-nova 的**最高方法论与最终目的**；其后一切条款、门禁、
> 验收与发布纪律，均为四阶段之一的具体化。条款解释发生歧义时，以「终抵巅峰」为准绳。

| 阶段 | 英文 | 本项目落地 | 责任 |
| :--- | :--- | :--- | :--- |
| **C** | **Conceive 构想** | 立方向、定标准、**法源先行**（母法 → 组合宪法 → CC 契约 → 封版规范）；奇思妙想与验收拍板 | CSA（伙伴） |
| **A** | **Achieve 实现** | 把设想落成可交付、可验证的工程现实：组合三要素 / 槽位 alias / 唯一令牌源 / 冻结面登记 / 自检 | 完现者（小诺） |
| **R** | **Refine 打磨** | **六维天花板**（功能 · 质量 · 观感 · 友好度 · 四性）逐项评估；CC-1~CC-8 装配态验收；**「现有再优、稳步推进、逐个打磨」**，一次一项（或同族一组），逐项验收、逐项销号 | 完现者（小诺） |
| **F** | **Freeze 封版** | API 冻结指纹零漂移、生成物保护、宪法 / CHANGELOG / 权威清单 / 账本 / AI 离线副本闭环；**commit / push / tag / PyPI 一律归 CSA** | CSA（伙伴） |

1. **终抵峰值（天花板铁律）**：每一个组件、每一个 15 项组合根容器，都必须是各自领域内的
   「组件的天花板」——**功能 / 质量 / 观感 / 友好度 / 四性**（Robustness 鲁棒性 ·
   Solidity 坚实性 · Aesthetics 艺术性 · Prescience 预判性）**六维缺一不可**。
2. **CARF 是循环，不是一次性流程**：F 之后以复评回到 C，但**禁止推倒重来**；每一轮 R
   在既有基座上再优化，不批量扫荡。第 9 章 CC-7 已确立「单组件 PASS 不等于装配 PASS」，
   装配态出图审计是 R 阶段的强制动作。
3. **执行版**：组合组件领域的 CARF 执行细则见
   `docs/COMPOSITION_CONSTITUTION.md` 卷首与 `docs/layout_shell/CEILING_AUDIT.md`（逐项销号台账）。
   CSA = Chief Solution Architect；完现者 = 拥有世界超脑、把设想落成现实的交付方。

---

## 第 0 章 宗旨

以 **Quasar Framework 最新稳定版**为对标本源，为 PySide6 / Qt Quick 构建
**企业级旗舰版**组件库，最终达成 `1.0.0-flagship` 封版（API 冻结 + LTS 24 个月）。

**对标基线：Quasar `2.35.5`**（2026-11-22 经官方 GitHub releases 复核；0.4.1 及之前的 2.26.0 基线为过期核实，已纠正）。**每期开工第一天必须先复核官方最新 release，发现基线漂移立即修正后再动工。**

## 第 1 章 工程结构（冻结条款）

1. 项目根目录名为 `pyside-nova`（建项目/仓库时使用）
2. **src 布局**：Python 包固定 `src/pyside_nova`，QML 模块固定 `src/pyside_nova/qml/Nova/{Services,Controls,Behaviors,Design,Composite/LayoutShell}`
3. QML 模块 URI 固定：`Nova.Services` / `Nova.Controls` / `Nova.Behaviors` / `Nova.Design` / `Nova.Composite.LayoutShell`（末者为组合组件专属模块，见组合宪法）；`qmldir` 导出清单即公共 API 面
4. Python 接入层唯一入口：`from pyside_nova import init_nova`；版本唯一来源 `src/pyside_nova/__about__.py`
5. wheel 必须完整携带 QML 资源（qmldir + .qml），pip 安装即用

## 第 2 章 头注释（冻结条款）

每个 `.py` / `.qml` 文件以两行注释开头：

```
// src/pyside_nova/qml/Nova/Controls/NovaIcon.qml
// NovaIcon 图标组件：icon="mdi:home" 式 API，本地图标包优先、云端 CDN 自动回落，MultiEffect 单色化着色（对标 QIcon）
```

- 第 1 行：**从 `src/` 开始的完整文件子路径**（qmldir 用 `#` 前缀，shebang 文件路径注释位于第 2 行）
- 第 2 行：**组件/文件说明**——直接沉淀为 API 文档（docs）素材，一句话讲清定位与对标关系，禁止日期流水
- `qmldir` 注释只能用 `#`（Qt 硬限制：`//` 会破坏模块解析）

## 第 3 章 Quasar 化（核心条款）

1. **对标基线锁定 Quasar 2.26.x**：组件属性名 1:1 对齐（如 `flat`/`dense`/`disable`），差异须在组件注释与 docs 中注明理由
2. 组件类名一律 `Nova` 前缀：`QBtn → NovaBtn`
3. **命名红线**：
   - 基调色属性统一命名 `tint`（QML 中 `color` 与 Rectangle 基类冲突）
   - 禁用 `on*` 前缀属性名（QML 信号处理器保留字；语义文本色为 `textOnPrimary`/`textColor`/`textMuted`）
   - 禁止组件内声明 `property color color`
4. **全量对标审计（3.5 条）**：每组件逐属性/事件/槽/model 对照 Quasar 建立审计表
   （[PARITY.md](PARITY.md)）；新组件交付必须新增审计节；❌ 项须标里程碑、⛔ 项须写 QML 语境理由；
   封版前 ✅ 占比门禁 P0 ≥90%、全库 ≥85%
5. **槽机制（宪法第 4 章）与断点体系（第 6 章）为 Quasar 化的强制性组成**

## 第 4 章 槽机制（0.2.1 新颁）

Quasar 组件的 Vue 槽必须映射为 QML 等价机制；**凡 Quasar 组件有槽，对应 Nova 组件必须实现**：

| Vue/Quasar 槽 | QML 映射 | 实现方式 |
|---|---|---|
| 默认槽（default） | `default property alias content: <host>.data` | 子项挂载到覆盖层宿主 Item |
| 命名槽（named，如 QBtn loading） | 具名 alias / 专属子组件区域 | `property alias` 或组合子组件（如 NovaCard 的 CardSection/CardActions） |
| 作用域槽（scoped） | `property Component xxxDelegate` + required 属性回传数据 | M1 数据类组件（NovaTable/NovaList）强制使用 delegate 模式 |

已实现默认槽的组件：`NovaBtn` / `NovaChip` / `NovaAvatar` / `NovaIcon` / `NovaBadge` /
`NovaCard` / `NovaCardSection` / `NovaCardActions`。
`NovaSeparator` / `NovaSpace` / `NovaRipple`（行为类）在 Quasar 中无内容槽，豁免。

## 第 5 章 设计令牌

1. `NovaTheme` 是令牌唯一来源；组件**禁止魔法数值色**，颜色/间距/字号一律取令牌
2. 三级令牌：基础（品牌/语义/几何/字阶/阴影）→ 表面（随 dark 切换）→ 组件内部派生
3. **品牌色 1:1 对标 Quasar 8 大变量**：`primary` / `secondary` / `accent` / `dark` /
   `positive` / `negative` / `info` / `warning`；运行时 `setBrand()` 换肤
4. 明暗双主题为每个组件的强制属性；`toggleDark()` 一键切换零警告；
   主题模式 API 对标 Dark 插件：`isDark`（= $q.dark.isActive）/ `setDark(v)`（= $q.dark.set()）/ `toggleDark()`（= $q.dark.toggle()）
5. WCAG 2.1 AA 对比度门禁自 M2 起纳入 CI
6. **层叠令牌（0.6.0 新颁）**：`zFab/zSide/zMarginals/zFixedDrawer/zFullscreen/zMenu/zTop/zTooltip/zNotify/zMax`
   对标 Quasar `$z-*` 数值 1:1；一切弹层（Notify/Dialog/Loading/Tooltip…）z 值禁止魔法数值，一律取令牌

## 第 6 章 断点体系

1. `NovaScreen` 1:1 对标 Quasar Screen 插件：阈值 xs<600 / sm<1024 / md<1440 / lg<1920 / xl≥1920，可 `setThresholds()` 定制
2. 语义 `isXs…isXl` / `ltSm…ltLg` / `gtXs…gtLg` / `isMobile` 与 Quasar 完全一致
3. 接入方式唯一：`Component.onCompleted: NovaScreen.source = window`
   （单例属性禁止对象体内声明式绑定——会被解析为 attached property）

## 第 7 章 图标系统

1. `NovaIcon` 的 `icon` 属性采用 `"mdi:home"` 式 API（`<集>:<名>`，无前缀默认 material）
2. 双通道：本地图标包（`NovaTheme.iconLocalRoot`，`scripts/fetch_icons.py` 产出）优先，缺失自动回落 jsDelivr CDN
3. 封装 QML `Image` + `MultiEffect` 着色；`monochrome: false` 保留原 SVG 彩色
4. 组件的 `icon` 属性统一自动识别图标引用（如 `NovaBtn.icon: "mdi:magnify"`）

## 第 8 章 质量门禁（CI 强制）

1. 冒烟测试全绿；**新组件必须新增**：解析+实例化用例、槽用例（若有槽）、明暗主题用例
2. 新组件必须在 `examples/gallery/` 新增页面且画廊完整加载
3. `pyside6-qmllint` 0 error；wheel 完整性（QML+qmldir 齐全）随 `local_deploy.py` 验证
4. 一键交付命令：`python scripts/local_deploy.py --zip`（构建→安装→测试→发布 ZIP）

## 第 9 章 版本与交付纪律

1. SemVer：破坏性 API 变更必须升 major 并在 CHANGELOG 标注 ⚠ Breaking
2. 每次交付：`__about__.py` 升版 → CHANGELOG 更新 → **本宪法迭代记录表新增一行** → 重新生成发布 ZIP
3. 封版（M3）后：公共 API 冻结，仅允许 bug 修复 / 72h 安全热修 / 性能优化；废弃 API 走两版本周期
4. **跨会话接续**：`docs/SESSION_HANDOFF.md` 为项目状态唯一事实源；`scripts/gen_prompt.py`
   将其**全文内联**生成自包含 `PROMPT.md`（新会话只需粘贴该单文件）。
   快照任何改动后必须重跑生成器，`gen_prompt.py --check` 以内容指纹判定过期（可入 CI）

## 第 10 章 生态完整性（七层模型）

"Quasar 生态化"不等于"组件数量对齐"，而是七层同时到位。任何交付物必须归属其中一层：

| 层 | 范围 | 封版门槛 |
|---|---|---|
| L0 设计语言 | 令牌、主题、图标集、动效、排版、阴影 | ≥95% |
| L1 布局系统 | Layout/Header/Footer/Drawer/Page + 栅格 + 可见性 | 100% |
| L2 组件 | 可视化控件 | P0 100% / 全库 ≥90% |
| L3 指令（行为） | ripple/close-popup/intersection/touch 系列/scroll/morph | 100%（不适用项须注明理由） |
| L4 插件（服务） | Notify/Dialog/Loading/Storage/App/Platform 等命令式 API | 100%（QML 适用项） |
| L5 工具层 | 栅格语法、可见性、文本、工具函数 | ≥90% |
| L6 工程化 | 构建、打包、文档站、测试、发布、治理 | ≥95% |

1. **补组件的判定标准**：只补"Quasar 有、QML 没有"的；QML 原生已有的以**皮肤化包装**（Nova 前缀 + 令牌 + 断点）实现，不重复造轮子
2. **优先级纪律**：骨架（L1）> 服务（L4）> 行为（L3）> 组件（L2）> 长尾（P2）
3. **审计义务**：每层差距维护于 `docs/ECOSYSTEM_PARITY.md`，每次交付复核一次
4. **禁止"生态空心"**：组件堆满而 L1/L3/L4/L5 为 0 时，不得宣称"生态化完成"

## 第 11 章 可访问性（0.16.0 新颁，封版门禁条款）

1. **三分类契约制**：每个 qmldir 导出类型必须在 `scripts/check_a11y.py` 的契约表登记为
   `interactive` / `semantic` / `decorative`；未登记即门禁失败（新增类型不补分类不得交付）
2. **interactive 五件套**：`Accessible.role` + `Accessible.name`（或 `a11yLabel` 覆盖）+
   `activeFocusOnTab`（或继承自 Nova 组件）+ 至少一条 `Keys.on*` 路径 + `NovaFocusRing`
3. **decorative 禁令**：布局/装饰容器**禁止**挂 `Accessible.*`（屏读器噪声），源码须带
   `// a11y: decorative` 标记；这是审计结论，不是遗漏
4. **对比度门禁**：文本 ≥4.5:1、控件边界与焦点指示 ≥3:1（WCAG 1.4.3 / 1.4.11）；
   品牌色不改，需要承载文字/边界时用 `NovaA11y` 派生（`*Text` / `fillTint` / `outlineStrong`）
5. **焦点可见性**：键盘模态才画焦点环（focus-visible 语义）；任何新增可聚焦控件不得自绘另一套
6. **键盘等价**：鼠标可达即键盘可达；键盘路径必须走与鼠标相同的 emit 出口，
   **不得**绕过受控契约（组件只 emit 不自写宿主状态）
7. **状态播报**：命令式服务的状态消息经 `NovaA11y.notice()`，由 `NovaLiveRegion` 播报（WCAG 4.1.3）
8. **交付验证**：`python scripts/check_a11y.py --matrix docs/A11Y_MATRIX.md` + `pytest tests/test_a11y.py`
   必须全绿；矩阵文件为生成物，禁止手改

## 第 12 章 国际化与非功能性（0.16.1 新颁，封版门禁条款）

1. **i18n 契约**：用户可见字符串必须经 `NovaI18n.t()`（复数 `tp()`）取词，禁止硬编码于组件；
   词典包内置 en-US/zh-CN，其余语言经 `addBundle()` 热注入（幂等、可增量）
2. **缺译回落显式化**：查找链 locale 精确 → 主语言码前缀 → en-US → key 本身；
   兜底返回 key 而非空串/英文硬译，缺译必须在运行界面可见
3. **复数零依赖**：CLDR 卡片规则走 JS 精简实现（七语系），不引 ICU/后端
4. **RTL 双轨纪律**：声明式容器优先 `LayoutMirroring.enabled: NovaTheme.isRtl`；
   手工布局组件必须提供 `effectiveSide` 或布局期反排，逻辑侧 API 语义恒定（RTL 只换物理方向）
5. **性能门禁**（`pytest tests/test_perf.py`，CLI 包装 `scripts/check_perf.py`）：
   冷启动 ≤800ms、组件实例化 ≤5ms/个（预热后两遍测量，KNOWN_HEAVY 白名单显式登记）、
   1000 行表格挂载 ≤1700ms；任一超预算不得交付
6. **HiDPI 契约**：全部几何走逻辑像素（devicePixelRatio 由 Qt 合成），Nova.Runtime 上报
   `devicePixelRatio/scaleFactor`；scale factor 1.0~2.0 矩阵下逻辑几何必须恒定
7. **崩溃红线**：测试进程任何 SIGSEGV/exit 139 视为阻断级缺陷，先定位根因
   （沉淀进 SESSION_HANDOFF 坑位表）再交付，禁止用"重试/跳过"掩盖

## 第 13 章 API 冻结与废弃政策（1.0.0-rc1 新颁，封版门禁条款）

1. **冻结面定义**：公共 API 面 = 四个 `qmldir` 的导出行。类型名 / 模块归属 / 单例性 /
   公共 `property`（名字·类型·只读性）/ 公共 `signal` 与 `function` 签名 / a11y 分类
   进冻结面；`_` 前缀成员、默认值、内部结构、视觉令牌取值**不进**（可自由重构）
2. **双件制**：机器清单 `api/nova-api-<apiVersion>.json`（逐成员签名 + 内容指纹）与
   人读签署件 `docs/API_FREEZE.md`（口径 + 统计 + 政策 + 例外 + 全量明细）必须同源同指纹；
   **两者均为 `scripts/gen_api_freeze.py` 生成物，禁止手改**
3. **变更分级**：破坏性（删类型/改签名/移模块/改分类）只能随 major；增量（新类型/新公共成员）
   随 minor 且必须重签；实现级改动随 patch 不重签。判定由 `scripts/check_api_freeze.py` 机判，
   任何漂移都变红——不允许"先在文档里记一笔"绕过
4. **废弃机制**：属性上一行写 `// DEPRECATED 1.x: 用 xxx 取代，2.0 移除`，并在创建时经
   `NovaUtils.deprecate(type, api, replacement, removedIn)` 播报一次（同一 key 不重复刷屏）；
   废弃项保留**两个版本周期**后于 major 移除。1.0 封版时清单内无废弃项
5. **命名红线随冻结加固**：新类型不得使用 `on*` 前缀属性（坑位 1）、不得与基类内建成员撞名
   （坑位 2/25）、导出文件名必须与类型名一致、qmldir 只认 `#` 注释且导出版本恒为 `1.0`
6. **静态检查预算制**：`qmllint` 的 **error 零容忍**；warning 按类别记录预算
   （`tests/lint-baseline.json`），现网数只允许 ≤ 预算，修正后必须 `--update` 下调预算——
   欠债有账，不允许变多
7. **交付验证三连**（`scripts/local_deploy.py` 已内置，任一红即拒绝出包）：
   `python scripts/check_a11y.py` → `python scripts/check_api_freeze.py` → `python scripts/check_qmllint.py`

## 迭代记录表（每次交付必须更新）

| 版本 | 日期 | 条款变更 |
|---|---|---|
| **1.0.0 · 卷首 CARF** | 2026-11-25 | **CARF 宣言入宪**（伙伴：「加入咱们的宪法？还是哪儿？你定合适的地方，15 项组合组件全部打磨一遍，你自己定节奏」）：卷首立 **Conceive / Achieve / Refine / Freeze — Culminate to the peak（构想 · 实现 · 打磨 · 封版，终抵巅峰）** 为**最高方法论与最终目的**，位列第 0 章之前；C 构想由 CSA 立方向 / 标准 / 法源，A 实现由完现者落成可交付、可验证的工程现实，R 打磨按**六维天花板**（功能 / 质量 / 观感 / 友好度 / 四性）逐项销号，F 封版 API 冻结零漂移且发布边界归 CSA；CARF 是循环、不推倒重来、不批量扫荡。援引组合宪法 **1.0.0** 卷首执行版 + 第 0 章第 5 条销号纪律，`docs/layout_shell/CEILING_AUDIT.md` 为 CARF-R 活台账。**15 项组合根容器全量打磨销号 15/15**：按语义分类批次 3~6 完成十一项 CC-1~CC-8 迁移与成品级 showcase，批次 1~2 四项 CARF 复评；新建 `scripts/audit_showcase.py`（15×3=**45 张**三态装配图）与 `scripts/audit_ceiling.py`（静态契约 + 31/31 实例化 + **45/45 组**极端非法入参稳态几何 + RTL 15/15 + reducedMotion + 断链扫描）机检 **PASS**；修复 5 处真实稳态几何缺陷、`NovaChat` 残留三元锚链、`NovaDrawerPanel` 装配态对侧拉伸与 `id-shadows-member` 红灯；`gen_apidocs.py` 离线副本改链接重写，断链 **21→0**。全程 `_` 私有 PATCH：**139 类型零漂移 · 冻结指纹 `bfd3d938a2fab7be` 不变**；静态门禁 3/3、专项 48/48、qmllint 0 error / 593 warning。发布边界归 CSA。 |
| 1.0.0rc1 | 2026-11-23 | 六期 RC1 收口：**API 冻结审查**（新颁第 13 章七条）；124 类型逐成员签名快照入库（api/nova-api-1.0.0.json，指纹 f2fd1b0eacf665f2）+ 签署件 docs/API_FREEZE.md（口径/统计/变更分级/例外登记/全量明细）；新增门禁 check_api_freeze.py（破坏性·增量·纪律三分桶 + 清单指纹自洽）与 check_qmllint.py（error 零容忍 + warning 分类预算 594 条）；local_deploy 交付前串跑三道门禁；**冻结审查修掉 3 处真实缺陷**：NovaColorPicker 幽灵令牌 NovaTheme.background→surface、root.tint 不存在→primary/hasError、NovaText.style 覆盖 Text.style 枚举→私有 _style；落地废弃机制 NovaUtils.logOnce/deprecate；测试 427→454；坑位 50~51 |
| 0.16.2 | 2026-11-23 | 五期 Sprint B3 收口：**工程化外环**（L6 80%→90%）；视觉回归门禁（明暗 × 5 断点 × 全画廊 240 基线 + check_visual.py 像素 diff）；外部输入消毒（NovaUtils.sanitize 五函数 + runtime 四 Slot + 组件 textFormat 加固 9 处 + 32 项测试，对标 2.32~2.35 安全硬化）；CycloneDX SBOM（gen_sbom.py 零依赖离线）+ OSV CVE 周巡（check_cve.py，.cve-ignore 带理由）；一键打包 build_app.py（PyInstaller onefile 185.7MB 启动自检过，≤60MB 目标诚实边界）；MkDocs 文档站（material 可搜索 15 页 + 画廊预览 24 图）；测试 394→427；坑位沉淀 49（视觉长跑后收尾期 GC 崩溃→pytest_unconfigure 硬退出） |
| 0.16.1 | 2026-11-23 | 五期 Sprint B2 收口：**i18n + RTL + 性能 + HiDPI 非功能攻坚**（新颁第 12 章）；新增 NovaI18n 服务单例（对标 Quasar Lang：locale 切换 / t() 插值与三级回落 / tp() CLDR 七语系复数 / 数字货币日期相对时间格式化 / addBundle 热注入）；RTL 双轨镜像（Pagination/Drawer/Layout/SlideItem/Breadcrumbs/StepperNavigation，逻辑侧语义恒定）；性能门禁三指标（冷启动 ≤800ms / 组件 ≤5ms / 1000 行表格 ≤1700ms）+ HiDPI 矩阵 1.0~2.0；补 a11y 差距：NovaTree 方向键游标（roving cursor，RTL 键互换）、NovaDialogShell 焦点陷阱（Tab 循环 + Esc 还焦，runtime 应用级过滤器）；新增 I18N.md + 画廊第 24 页 i18n；类型 123→124，测试 343→394；坑位沉淀 43~48（Qt.formatDate 三参不存在 / QQmlExpression 非 Item SIGSEGV / Tab 不冒泡→应用级过滤器 / Item.window undefined→attached / qrc:// 双斜杠 shiboken 段错误总根因→全局 qrc:/ / setData 探针纪律） |
| 0.16.0 | 2026-11-23 | 五期 Sprint B 第一交付单元：**可访问性攻坚**（新颁第 11 章 a11y 八条门禁）；新增 NovaA11y 单例 / NovaFocusRing / NovaLiveRegion / Nova.Runtime 输入模态（focus-visible）；NovaTheme 增 a11yBase·focusRing·outlineStrong·七个 *Text 派生·fillTint，textMuted AA 化；123 导出类型 100% 登记契约（32 interactive / 28 semantic / 63 decorative），32 个交互件补齐全键盘路径与焦点环；新增静态门禁 check_a11y.py + A11Y.md/A11Y_MATRIX.md + 测试 21 项；类型 120→123，测试 322→343；坑位沉淀 38~42（Accessible 作用域 / 无 disabled 属性 / 无 Keys.onEndPressed / QTest 需强引用组件 / 多引擎析构间歇崩溃→测试单引擎） |
| 0.15.0 | 2026-11-23 | 五期 Sprint A 收口：长尾组件一次交付（Editor 轻量富文本——DOM contenteditable 无 QML 等价物以标记编辑+HTML 导出实现同语义、SlideItem 左右滑动面板、Morph group 形变、IconGenie 图标全套 CLI、AI-ready 文档包 + Nova MCP server 六工具对标 @quasar/mcp 2.33 新品类），类型 117→120，测试 308→322；坑位沉淀 36（pragma library JS 注册表 per-importing-file 实例化→QML singleton）；基线开工复核：@quasar/mcp v1.x Active、quasar 2.33.0 AI-ready 口径核实 |
| 0.14.0 | 2026-11-23 | 四期 Sprint B 收口：弹层与反馈一次交付（Menu、DialogShell 关闭原因上报、PopupProxy 断点路由、Tooltip、BottomSheet、Spinner×8、Skeleton、InnerLoading、AjaxBar+LoadingBar 服务、Banner/Bar、NoSsr、PullToRefresh 四边、ResizeObserver），L2 54%→68%，类型 100→117；规划核对：ScrollObserver 已于 Behaviors 0.7.0 交付不重复；坑位沉淀 35（TapHandler 被子项 MouseArea 饿死→动态挂接 clicked）；弹层栈析构注销纪律（onDestruction）；受控契约沿用（Menu/DialogShell/BottomSheet/PTR 均 emit-only） |
| 0.13.0 | 2026-11-23 | 四期 Sprint A 收口：导航体系 14 类型一次交付（Tabs/Tab/TabPanel/TabPanels、Breadcrumbs/El、Stepper/Step/StepperNavigation、ExpansionItem、Toolbar/Title、Fab/FabAction），L2 43%→54%；基线复核 2.35.6（API 零漂移）；坑位沉淀 33~34（析构钩子 onDestruction / 基元无 background）；坑位 24/28 再验证（NovaStepper 状态绑定直读依赖 + _rev 显式失效）；受控契约沿用（Tabs/Panels/Stepper/Fab 均 emit-only） |
| 0.12.0 | 2026-11-23 | 三期 Sprint B 收口：媒体体系十类型 + NovaTable 增强（虚拟滚动/服务端模式/loading 三态）一次交付，L2 34%→43%；坑位沉淀 29~31（inline component 裸名 delegate 恒 count 0 / 创建期定位器错过布局需 childrenRect 兜底 / QtMultimedia Video 必须按 src 惰性创建）；坑位 28 再验证（函数调用绑定依赖不可靠，派生数据一律显式失效）；受控契约沿用（Carousel modelValue / Table page·sortBy 均 emit-only） |
| 0.11.0 | 2026-11-23 | 数据体系契约入宪：选择/勾选**按键值比较**（坑位 27：Qt6 信号参数深拷贝）、树派生索引**显式失效**（坑位 28：_refreshDerived + _rev）；NovaItem 槽位命名 left/top → leading/trailing、top → topAligned（FINAL 属性红线）；分页器受控 page 契约 |
| 0.1.0 | 2026-11-21 | 宪法雏形：工程结构、头注释雏形、命名红线、令牌、断点、图标、质量门禁 |
| 0.2.0 | 2026-11-21 | 第 1/2 章冻结：src 布局终版（pyside_nova/qml/Nova）、头注释双行规范、qmldir `#` 注释条款、gallery 门禁 |
| 0.2.1 | 2026-11-21 | 新颁第 4 章槽机制（默认/命名/作用域槽映射，5 组件重构补默认槽）；第 3 章对标基线锁定 Quasar 2.26.0；第 5 章补齐品牌色 `darkColor` |
| 0.3.0 | 2026-11-21 | ⚠ 命名重构：主题模式 `dark` → `isDark`，品牌色 `darkColor` → `dark`（1:1 对标 $dark，趁 0.x 期修复），新增 `setDark()`；新颁 3.5 条全量对标审计（PARITY.md，逐属性/事件/槽/model 对照） |
| 0.3.1 | 2026-11-21 | 基础夯实轮：测试护栏补齐（Dark API + demo 加载，合计 32 项）、GitHub Issue/PR 模板入宪第 8 章交付清单、dependabot 巡检、SESSION_HANDOFF.md 交接快照 + git 全量首提交 |
| 0.3.2 | 2026-11-21 | 跨会话永续闭环：交接快照模板 + 提示词模板 + gen_prompt.py 实时生成器（--check 同步校验），第 9 章交付纪律升级为六步 |
| 0.3.3 | 2026-11-21 | 交付包完整性加固：ZIP 补 PROMPT.md + 完整 .git 历史 + BUILD_INFO 清单 + SHA256 校验文件；新增 --bundle 离线图标全量包 |
| 0.3.4 | 2026-11-21 | 接续方式精简为**单文件**：PROMPT.md 内联快照全文 + 内容指纹校验，取消“预读 4 文件”要求（改为按需深读），第 9 章新增第 4 条跨会话接续条款 |
| 0.4.0 | 2026-11-21 | 新颁第 10 章 **生态完整性（七层模型）**：L0 设计语言/L1 布局/L2 组件/L3 指令/L4 插件/L5 工具/L6 工程化；发布 `docs/ECOSYSTEM_PARITY.md` 生态对标白皮书（成熟度评分 + 12 项 P0 空白 + 24 条封版验收） |
| 0.4.1 | 2026-11-21 | 发布 `docs/MASTER_PLAN.md` **全生态开发总规划**：六期战略（生态骨架→表单→数据媒体→导航弹层→长尾+非功能→封版 1.0.0-flagship），组件 76 项/指令 11 项/插件 15 项全量对账到期；冒烟测试七条纪律制度化 |
| 0.4.2 | 2026-11-22 | ⚠ 基线漂移纠正：对标基线 2.26.0 → **2.35.5**（官方 releases 复核）；新颁基线复核条款（每期开工先核对最新 release）；2.26→2.35 增量审计入册：新增 L6 "AI-ready 文档 + Nova MCP server"，Dialog/BottomSheet 关闭原因上报、Select hover 契约、Fab stagger、PullToRefresh side、Screen orientation 等写入对应期 DoD，安全硬化入五期门禁 |
| 0.5.0 | 2026-11-22 | 一期 Sprint 1 落地：L1 布局系统交付（NovaLayout 五件套 + NovaRow/Col/Visible），七层 L1 0%→100%；画廊布局页 6 种经典布局；测试 32→46；沉淀坑位"瞬态 parent 宽度不可自判断点" |
| 0.5.1 | 2026-11-22 | NovaNotify 契约裁定（D1 增强 dismissed(reason) 标增强栏 / D2 不移植 html 改 contentDelegate / D3 onDismiss→dismissed 信号 / D6 NovaOverlayHost 提前 Sprint 2）；归属修正：Notify 无关闭原因（npm 2.35.5 源码核实）；新颁纪律：API 对账以 npm 包源码与 dist API JSON 为准，不按文档页凭记忆写 |
| 0.6.0 | 2026-11-22 | 一期 Sprint 2 首件落地：L4 通知服务 NovaNotify + NovaOverlayHost 交付（L4 0%→6%）；第 5 章新颁第 6 条层叠令牌（$z-* 1:1，禁止弹层魔法 z 值）；坑位沉淀第 7 条（QtObject 单例体内禁声明 Component 子项）；0.4.2"关闭原因上报"归属二次澄清入 PARITY 审计节 |
| 0.6.1 | 2026-11-22 | Sprint 2 第二件 NovaDialog 交付（27 项对账 / 句柄五方法 / dismissed 五值）；L4 6%→12%；测试 63→71；确认"同名字段在 Notify 是增强、在 Dialog 是 parity"的分栏纪律 |
| 0.6.2 | 2026-11-22 | Sprint 2 收口：一次交付 NovaLoading/Storage/App/Platform（L4 12%→44%）；新增 Nova.Runtime Python 后端；新颁"Sprint 最小交付单元"节奏条款；坑位沉淀：qmlRegisterSingletonInstance 所有权 / 裸 JS 条目无属性通知 / overlay visible 与宿主冲突 |
| 0.7.0 | 2026-11-22 | Sprint 3 收口：L3 行为层九件一次交付（Ripple 之外八件新 + 共享观察池 NovaIntersectionPool + 宿主弹层栈），L3 11%→100%；坑位沉淀：Item FINAL 属性不可覆盖 / visible:false 阻断事件分发 / 默认属性转交内部容器使 parent 失真 / QWindow wrapper 调不到 QML 函数 / 观察器重订阅须重交付 / QML 函数无可选参数 |
| 0.8.0 | 2026-11-22 | Sprint 4 收口（一期生态骨架完工）：新增 **Nova.Design 模块**（NovaIconSet/NovaMotion/NovaUtils）+ NovaText/NovaTransition，L0 60%→100%、L5 0%→95%；14 套图标集全键 1:1（图标集数据表经 scripts/gen_iconsets.py 从基线包提取，禁止手改）；坑位沉淀 17~20：V4 引擎位运算拼 hex 串色 / Animation 无 enabled / createObject 的 Timer 不自启 / QML 无 rAF 与 crypto.randomUUID |
| 0.9.0 | 2026-11-22 | 二期 Sprint A 收口：表单核心七件（NovaField/NovaInput/NovaSelect/NovaCheckbox/NovaRadio/NovaToggle/NovaSlider）一次交付，统一契约 label/hint/error/readonly/disable/clearable/rules + 校验引擎（内置字符串规则/函数规则/lazyRules）；受控模式（组件只发信号不自写 modelValue，对标 v-model）；画廊第 16 页；测试 149→174；local_deploy 新增 --allinone；坑位沉淀 21~23：属性通知信号撞名 / 受控组件禁写自身 modelValue（绑定环） / readonly 漏 property 关键字 |
| 0.10.0 | 2026-11-22 | 二期 Sprint B 收口：输入进阶八件（NovaRange/NovaDate 自研日历/NovaTime 时钟面盘/NovaColorPicker/NovaOptionGroup/NovaForm/NovaBtnToggle/NovaPopupEdit）一次交付；画廊第 17 页；测试 174→199；坑位沉淀 24~26：缓存绑定重评期 undefined / palette·show·hide 内建撞名 / site-packages 残留 wheel 让 pytest 走旧 QML（交付后 pip install -e . 复位） |
