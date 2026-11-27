# 项目交接快照 — Session Handoff

> 用途：本文件是项目状态的**唯一事实源**；`scripts/gen_prompt.py` 会把它全文内联进
> `PROMPT.md`，新会话粘贴 PROMPT.md 即可 100% 恢复上下文。
> **每次交付随宪法迭代记录表同步更新本文件。**（**更新于 2026-11-28 07:16 · nova-forge 0.6.0 已由 CSA 发布校准**：新增「0.6.0 已发布校准」段覆盖下方 04:50 发布态校准段及全部史料；**nova-forge 0.6.0 已由 CSA 发布**（tag `v0.6.0` → `aaba3764d` = HEAD = `origin/main`，PyPI LATEST RELEASE 上架 whl + sdist）· **pyside-nova 1.11.0 已由 CSA 发布**（tag `v1.11.0` → `596f304`；HEAD / `origin/main` 为发布后 docs-only 校准提交 `2f0c9a3`）；下方 04:50 / T3 / T29 / T29-A 段及更早全部快照按「史料不圆场」逐字保留为史料）

## 🆕 0.6.0 已发布校准（2026-11-28 07:16 · git push + PyPI 双成功 · 覆盖下方 04:50 发布态校准段及全部史料；下方全部保留为史料）

- **CSA 确认**：「v0.6.0 / git、pypi成功」+ PyPI 页面截图（`nova-forge 0.6.0` · `pip install nova-forge==0.6.0` · **LATEST RELEASE** · Released: half a minute ago）。
- **nova-forge 发布事实（磁盘 + PyPI API 为准）**：tag `v0.6.0` → `aaba3764d chore(release): v0.6.0` = HEAD = `origin/main`，工作树干净；`pyproject.toml` / `CHANGELOG.md [0.6.0]` / `PRESCRIPT_GALLERY.md` 均随发布提交冻结。PyPI JSON 实测 `name=nova-forge version=0.6.0`、上传 `2026-11-27T23:15Z`（≈ 北京时间 11-28 07:15）、产物 `nova_forge-0.6.0-py3-none-any.whl` + `nova_forge-0.6.0.tar.gz`。此前「升版待 CSA 发布 / 尚无新 tag」口径过期。
- **pyside-nova 账实校准**：**1.11.0 已由 CSA 发布**（tag `v1.11.0` → `596f304`）；但 `origin/main` / HEAD 现为 `2f0c9a3 chore(release): v1.11.0` —— 发布后追加的 **docs-only 校准提交**（仅 `PROMPT.md` 16 行 + `SESSION_HANDOFF.md` 10 行，tag 未移动），`596f304` 仍是其祖先、工作树干净。此前「HEAD `596f304` = tag `v1.11.0` = `origin/main`」三等式过期，如实校准为「tag `596f304` / HEAD·`origin/main` `2f0c9a3`」。
- **已发布物零回改**：`nova-forge/CHANGELOG.md [0.6.0]` 段标题「⭐ 当前版本（待 CSA 发布）」与如实登记末行「等待 CSA 发版」属**发布时点史料**、已随 tag `v0.6.0` 冻结，按「史料不圆场」（延续 `[0.5.0]` 段同款先例）**不回改**；现行状态一律以本段 + 六处账本校准为准。
- **边界与状态**：本轮仅做发布态账实校准（只读核实 + 账本追加），**未执行任何新的** `commit / push / tag / PyPI / 站点上线`。现行冻结面 **API 1.11.0 / 147 类型 / 指纹 `9966483dda5a53c4` 零改动**、不升版、不重签；ruff 15 条存量挂账按 CSA 拍板保持不修。**待办池 0 项（无活跃主线）· 下一个 T30**。

## 🆕 发布态校准（2026-11-28 04:50 · 只读扫描 ruff 挂账 + 升版 0.6.0 待 CSA 发布 · 史料段，已由上方 07:16 校准覆盖；下方全部保留为史料）

- **CSA 指令与拍板**：「先扫一下 ruff 那 15 条挂账，再发布」→ ① ruff 15 条**保持存量直接发**（不修，仅如实登记）；② **CSA 自行发版**，小诺只交付发布就绪清单；③ nova-forge 新版本 **0.6.0 minor**。
- **发布事实（磁盘为准 · 账实不符已校准）**：`pyside-nova` HEAD `596f304 chore(release): v1.11.0` = tag `v1.11.0` = `origin/main`，工作树干净 → **1.11.0 已由 CSA 发布**（此前「本地完成待 CSA 发布」口径过期）；`nova-forge` tag `v0.5.0` → `db76dd5e1`（**0.5.0 已发布**），HEAD `eb0bfef9d chore(release): v0.5.0` = `origin/main` 比 tag 多 1 个提交，正是 T3 全套（`migrate/` 9 文件 / `cmd_migrate.py` / `app-aireport.svg` / README·CHANGELOG），**已 commit + push、尚无新 tag**。两仓库工作树均 0 改动。
- **发布前置阻塞（本轮解除）**：`pyproject.toml` 原 `0.5.0`、CHANGELOG 顶部原 `[Unreleased]`；`.github/workflows/publish.yml` 门禁 1 强制 **tag 版本 == pyproject 版本**、门禁 2 **PyPI 查重**，且 `v0.5.0` tag 已占用 → 直接发必被拒。本轮升 `0.6.0`、归档 `[0.6.0]`、`docs/PRESCRIPT_GALLERY.md` 版本同步；测试夹具中的 `"0.5.0"` 是入参常量、非版本声明，按最小改动不回改。
- **ruff 15 条挂账（只读扫描 · 保持不修）**：`UP012` 7 / `F401` 3 / `N802` 2 / `RUF005` 1 / `SIM105` 1 / `RUF015` 1，落 `tests/test_comment.py`、`cmd_saver.py`、`cmd_publish.py`、`core/comment_logic.py`、`resources/resources_rc.py`；9 条 `--fix` 可修、6 条需手工或豁免。全部为 `v0.5.0` 及更早存量，T3 新增文件 ruff 全净 → **不阻塞发布**。`N802` 是 `pyside6-rcc` 生成物固有、`cmd_saver.py` 的 `import resources_rc` 是「导入即注册 qrc」误报倾向，故不一把 `--fix --unsafe-fixes` 梭哈。上一轮「均在 T23 未改动文件」口径不准确，此处如实校准。
- **本轮边界**：只做升版 / 归档 / 六处账本校准 / 发布就绪清单；**不执行 commit / tag / push / PyPI / 站点上线**。`pyside-nova 1.11.0` 冻结面（147 类型 / 指纹 `9966483dda5a53c4`）零改动、不升版、不重签。待办池 0 项、下一个 T30。

## 🆕 T3 现行校准（2026-11-28 · migrate2nova 完现销号「100% 迁移」+ 第 11 枚应用图标 / 专属暗色主题 · 覆盖下方 1.11.0 / T29-A 及更早快照；下方全部保留为史料）

- **CSA 指令**：「1. 为 NovaAIReport 设计应用图标并放在 resources/icons/，为其设计专属暗色主题（同其他的 10 个组合组件），并在应用暗色主题时标题栏为暗色；3. 完现 T3，建议更名为 migrate2nova（方便输入子命令），目标 100% 实现迁移」。
- **T3 更名**：主命令 **`nova-forge migrate2nova`**，原名 `migrate_to_nova` 保留为**隐藏 alias**（根 `PROMPT.md §9` 方案骨架史料逐字保留，`nova-api-1.0.0.json` 史料行不回改）。
- **100% 口径定死**：试验田 `nova-forge/src/nova_forge/ui/saver_window.py` **1** 个 `.py` / **22 个唯一 Qt 名** 全部进入 `AUTO 11 / MANUAL 2 / NATIVE 5 / RUNTIME 4` 四类处置（**100% = 22/22**），MANUAL 明确为 `QSplitter` / `QSystemTrayIcon`；`UNKNOWN_RULE` 兜底 MANUAL，零静默遗漏。
- **法源链零悬空**：`FreezeIndex` 自动探测 `api/nova-api-1.11.0.json`（API `1.11.0` / **147 类型** / 指纹 `9966483dda5a53c4`），`--list-mapping` 实测 **72 条规则 / AUTO 目标悬空 0 个**；不手写 Nova 类型清单。
- **五道契约门**（§9.4）：`static-tier` / `coverage` / `qmllint` / `modelValue` / `slot-constitution`；dry-run 2 PASS + 3 SKIP，`--scaffold` 时实跑全绿方落盘；FAIL 抛 `ContractBlockedError`，一个字节不写。默认 dry-run · 原 `.py` 零改动 · QML 加载失败动态降级回原窗口 · §9.3 `%TEMP%/nova-scratch/` 备份自建自删 / `--restore` 回滚。
- **坑位 83**：全量 pytest 暴露「导入 PySide6 会把 `qmllint.exe` 注入 PATH」+「Windows `qmllint.exe` 不支持 stdin `-`（返 -1）」致 qmllint 门误判 FAIL（专向 26 passed / 全量 4 failed）；改落临时文件实跑 + 自动 `-I` 指向 pyside-nova QML 根 + 以 `Error:` 行零容忍判定，warning / rc 如实登记不掩盖，新增专项回归固化。
- **第 11 枚图标 / 第 11 套主题**：`app-aireport.svg`（258° 仪表钢蓝）两工程 qrc 双别名 + `resources_rc.py` 重编；`NovaAIReport._signatureOn / _themeHue(+0.0694) / _accent / _ink / _inkSoft / _glow` + `NovaIcon` 徽记与其余 10 壳同构；`ai_report/run.py` 自包含 DWM helper（`darkChromeChanged(bool)` → 属性 20/19）同步 Windows 原生暗色标题栏。`GUIDE_COMPONENT_THEMES.md` / `NovaAIReport.md` §6 登记。
- **验收**：nova-forge 全量 **206 passed + 32 subtests**（T3 专项 **26 passed** · `test_titlebar_and_hatch.py` 18 passed）· pyside-nova 图标/主题专项 **26 passed** · ruff 新增修改文件全净 · qmllint 0 error · `check_api_freeze.py` **147 类型零漂移** · 三 `--check` · 生成器幂等 · 骨架 `Main.qml` 离屏 `ROOTS 1 / TOTAL_MSGS 0 / BAD_MSGS 0` · 降级 `FALLBACK_RC 0` · `ai_report` demo `TOTAL_MSGS 0`。
- **状态**：**T3 完现销号（真实交付）** · **待办池 0 项**（无活跃主线）· **下一个 T30**（T3 为历史编号，不占用新号）· `commit / push / tag / PyPI / 站点上线` 全归 CSA；本轮改动全部留本地工作树。**pyside-nova 1.11.0 冻结面零改动、不升版、不重签**。

---

## 🆕 1.11.0 现行校准（2026-11-28 03:33 · T29 完现「先 A 后 B」· 物理重构重签 · 覆盖下方 T29-A / 02:51 及更早快照；下方全部保留为史料）

- **CSA 拍板（03:20）**：B 版本起点 = **1.11.0 minor（仅重签指纹）**、**不落 `@nova-compat-view` 兼容视图**、不升 2.0.0 major。
- **T29-A**：文档层二维台账 `GUIDE_LAYOUTSHELL_TAXONOMY.md` + 法源页 `SPEC_T29_LAYOUTSHELL_SPLIT.md` + `mkdocs.yml` nav 2 条；判别锚 `NovaTheme.primary.hsvHue` 命中 11 / 未命中 10 **零例外**，九类仅 `Page/` 被劈开；零产品代码 / 零 URI / 零重签。
- **T29-B**：10 个通用布局原语 QML 上移 `Composite/`；`LayoutShell/qmldir` 10 条 `../` 转发、11 条原位；模块 URI 恒 `Nova.Composite.LayoutShell`，21 类型名 / `import` / **147 类型公共面逐字不变**。
- **逐成员零漂移证明**：唯一变化 = 10 个 `types[].file` 溯源字段；归一化反推**精确还原旧指纹** `5328cd0e3c71e7ac` → 新指纹 **`9966483dda5a53c4`**（`api/nova-api-1.11.0.json` · 147 类型不变）；`tests/test_t29_migration.py` **9 项机检固化**。
- **实测排险**：`spike_v2_compat.py` 7/7 + B 精确形态 A/B 对照探针 PASS → R2 降级为真机回归项；真实产品树 foundations **15/15 · 130 类型实例化零缺陷**、a11y **147/147**、qmllint **0 error / 571 warning 未增**。**`check_a11y.py` / `audit_v2_compat.py` C1 均无需改动**（`../` 拼接被 `Path.exists()` 天然解析；C1 与生成器 `file` 同源）。
- **文档层**：CHANGELOG `[1.11.0]` 段 · `NovaTable.current.md` §0 1.11.0 段 · 两份 prescript 现行校准段 · `SPEC_V2_COMPAT.md` 版本锚点校准段；**1.10.0 及更早史料段逐字保留**。
- **验收**：静态 3/3 · 专项 **131 passed** · v2 compat C1~C5 PASS · 天花板 21/21 · foundations 15/15 · 域分类 PASS · `mkdocs --strict` EXIT=0 · 三 `--check` 全绿 · 生成器幂等。
- **状态**：**T29 完现销号** · **1.11.0 本地完成待 CSA 发布**；待办池仍 1 项 = **T3**；**下一个 T30**；`commit / push / tag / PyPI / 站点上线` 全归 CSA。

---

## 🆕 T29-A 现行校准（史料段，上方 1.11.0 优先 · 2026-11-28 03:17 ·「先 A 后 B」· 文档层二维分层台账 · 零重签 · 覆盖下方 02:51 交付段及更早快照；下方全部保留为史料）

- **CSA 指令**：「小诺，T29，先 A 后 B」。按序执行：A 文档层（本阶段完现）/ B 受控物理迁移（待拍板）。
- **判别锚（可机检、零例外）**：`NovaTheme.primary.hsvHue` 命中 **11** 个 = CSA 保留清单逐字一致；未命中 **10** 个 = 移出清单逐字一致。九类里仅 `Page/` 被劈开（`NovaSetupWizard` 留 / `NovaBlankPage` 移）→ 分界实为「**通用布局原语 vs 产品级组合根**」，不是九类；保留集 = 十色相工作台（10）+ 第 21 组合根 `NovaAIReport`（1）。
- **A 交付**：`docs/prescript/GUIDE_LAYOUTSHELL_TAXONOMY.md`（二维台账 / 判别锚 / 21→11+10 集合核算 / B 影响面预登记）+ `docs/prescript/SPEC_T29_LAYOUTSHELL_SPLIT.md`（法源页 / 三档路径 / 拍板项 / B 九项切换清单 / 冲突登记）+ `mkdocs.yml` nav 2 条。
- **A 纪律**：零产品 QML 改动 / 零 `qmldir` 改动 / 零 URI 变化 / 零重签 / 零版本变动；仍 **1.10.0 · 147 类型 · 指纹 `5328cd0e3c71e7ac`**。
- **A 验收**：静态 3/3 · 专项 **122 passed** · 天花板 **21/21**（619 条链接 0 断链）· foundations **15/15** · 域分类 / v2 compat PASS · `mkdocs --strict` **EXIT=0** · 三 `--check` 全绿 · 生成器幂等 210 文件哈希一致。
- **B 技术前提实测（只读临时 import path、不动产品目录）**：`spike_v2_compat.py` **7/7 PASS**（形态 C `../` 跨目录转发 / H `../../` 到新顶层目录均拿同一物理实现）+ **B 精确形态 A/B 对照探针 PASS**（既有 URI `Nova.Composite.LayoutShell` 不变、QML 在父目录 `Composite/`、`qmldir` 写 `../NovaSidebar.qml`，与平铺基线两组 tag 同为 `REAL`、非包装）→ **`../` 转发可行，R2 从「未验证假设」降级为「真机回归项」**，B 阶段仍须对真实 21 组件做离屏真机回归。
- **B 待 CSA 拍板**：② 版本起点（**1.11.0 minor** 仅重签指纹 / **2.0.0 major** 按 `SPEC_V2_COMPAT.md` §5 M2）③ 是否同批落首个 `@nova-compat-view` 兼容视图（建议不落）。① 打破 12:05 平铺约定已由「后 B」隐含授权。
- **账实脱节登记**：`SPEC_V2_COMPAT.md` 版本锚点仍写 `1.2.0 / 144 类型 / 4f882374ad52262b / 2.0.0`，与现行 **1.10.0 / 147 / `5328cd0e3c71e7ac`** 不符，B 实施前追加现行校准段（史料行不回改）。
- **状态**：**T29 立项占用（A 完成 / B 待拍板）**；待办池仍 1 项 = **T3**；**下一个 T30**；`commit / push / tag / PyPI / 站点上线` 全归 CSA。

---

## 🆕 1.10.0 发布态校准（2026-11-28 02:51 · 史料段，上方 T29-A 优先 · 已由 CSA 发布 · 覆盖下方 02:30 交付段及更早快照；下方全部保留为史料）

> **本节优先于下方全部历史正文**。CSA「1.10.0 已发布」→ 只读核实 + 账实对齐，零产品代码改动。

- **发布态核实**：HEAD `1fb87d9 chore(release): v1.10.0` · tag `v1.10.0` → `1fb87d9d2c827d1c87096c536c7e393800a98dac` = HEAD · **工作树干净（0 改动）**；`__about__` = `1.10.0`；`api/nova-api-1.10.0.json` / `api/component-domains-1.10.0.json` 均在发布提交内 → **1.10.0 确已由 CSA 发布**。
- **状态校准**：现行口径由「1.10.0 本地完成待 CSA 发布」改为「**1.10.0 已由 CSA 发布**」；`CHANGELOG.md [1.10.0]` 标题 / 版本说明 / 发布行、`docs/controls/NovaTable.current.md` §0 发布态行 / 发布行、本文件头部与本节、根 `PROMPT.md`（头部 / §A.2 指针 / §A.3 播报 / §A.4 归档表）、`NOVA_WORKSPACE.md`（§0 / §6）、`MEMORY.md`（§2 / §4）、当日日志同步。
- **史料不圆场**：**1.9.0 及更早冻结面 / 文档正文 / 快照段逐字保留，零回改**；下方 02:30「1.10.0 现行校准」段保留为交付史料，仅标注「史料段、上方 02:51 优先」。
- **边界**：本轮不新增任务编号、不改组件、不重签、不执行发布动作；`commit / push / tag / PyPI / 站点上线` 全归 CSA。待办池仍 **1 项 = T3**；**T28 已销号，下一个 T29**。
- **复核**：三 `--check`（`gen_api_freeze` / `gen_prompt` / `sync_brand_version`）、静态 3/3、专项测试全集、生成器幂等复验通过；`gen_prompt.py` 已重投影 `pyside-nova/PROMPT.md`。


## 🆕 1.10.0 现行校准（2026-11-28 02:30 · 史料段，上方 02:51 优先 · NovaTable 完全对标 Quasar QTable · 覆盖下方 1.9.0 / 1.8.0 及更早快照；下方全部保留为史料）

> **本节优先于下方全部历史正文**。CSA「打磨 NovaTable 组件，完全对标 https://quasar.dev/vue-components/table，评估完整度」
> +「1.9.0 已发布」→ 立 **T28** 当轮完现；已发布版本不回改，按 additive minor 升 **1.10.0** 重签。

- **发布态核实**：HEAD `f209387 chore(release): v1.9.0` · tag `v1.9.0` · **工作树干净** → 1.9.0 确已由 CSA 发布；
  `api/nova-api-1.9.0.json`（指纹 `b15a4be38c000c59`）为已发布史料，不回改。
- **冻结面**：**pyside-nova 1.10.0 · API 1.10.0 · 指纹 `5328cd0e3c71e7ac`**；
  **147 类型 / Controls 93 / LayoutShell 21 不变**；`NovaTable` **77/14/21 → 110/18/26**
  （+33 props / +4 signals / +5 methods，旧面逐成员零丢失），`NovaTr` +1 prop `rowColor` +1 signal `rowContextMenu`。
- **完整度评估**（数据源 = Quasar 官方 `ui/src/components/table/QTable.json` 全表：
  63 props / 21 slots / 9 events / 15 methods / 15 列元字段 = **123 项**）：
  1.9.0 字面完全对齐 **65/123 = 52.8%** → 1.10.0 **114/123 = 92.7%**，
  **能力面可解释覆盖 123/123 = 100%**（剩余 8 项框架边界 / 库组件承接 + 1 项全局主题，
  逐项登记于 `docs/controls/NovaTable.current.md` §15）。
- **补齐**：8 个插槽（21/21）· 5 个方法（15/15）· 4 个事件（9/9）· 列元字段 15/15；
  另立 `sortMethod` / `filterRowsMethod` / `rowKeyFn` 承载官方整体函数语义（**不劫持**已发布
  `filterMethod` 单行谓词）；`selectionMode` / `square` / `wrapCells` / `hide-*` / 三个 label /
  `virtualScrollSliceSize` + sticky sizes / 6 个样式语义令牌（只映射 `NovaTheme`，不解析 CSS）。
- **现行文档**：`docs/controls/NovaTable.current.md` 头部插入 §0 现行校准 + §14 完整度评估 +
  §15 框架边界 + §16 验收；**1.9.0 正文逐字保留**。构想稿 `NovaTable.md`（1654 行）仍 exclude、不上站。
- **坑位 82**：QML `signal paginationChanged(var p)` 与 `readonly property var pagination`
  自动生成的属性变更信号**重名** → 加载期 `Duplicate signal name: invalid override of property
  change signal`（foundations / 天花板实例化 FAIL）。将属性改名 `paginationState` 规避，信号名保留。
- **验收**：静态 **3/3** · 专项 **122 passed** · 天花板 **21/21** · foundations **15/15** ·
  域分类 / v2 compat PASS · `mkdocs --strict` EXIT=0 · qmllint **0 error / 571 warning** ·
  生成器幂等 · ruff `All checks passed` · 三 `--check` 全绿 ·
  离屏真机全 21 插槽 + 5 新方法 + 4 新信号 **ROOTS 1 / TOTAL_MSGS 0 / BAD_MSGS 0**。
- **状态**：**pyside-nova 1.10.0 本地完成，待 CSA 发布**；
  `commit / push / tag / PyPI / 站点上线` 全归 CSA。待办池仍 **1 项 = T3**；
  **T28 完现销号，下一个 T29**。

## 🆕 1.9.0 现行校准（2026-11-27 23:30 · NovaTable 对标 Quasar QTable 打磨 · 覆盖下方 1.8.0 / 1.7.0 / 21:30 / 21:20 及更早历史快照；下方全部保留为史料）

> **本节优先于下方全部历史正文**。CSA「继续打磨 NovaTable，对标 https://quasar.dev/vue-components/table」→ 立 **T27**，按 additive minor 1.9.0 收口；1.8.0 已由 CSA 发布（HEAD `6c80d42 chore(release): v1.8.0` / tag `v1.8.0`），属史料事实，正文不回改。发布边界仍归 CSA。

| 项 | 1.9.0 现行事实 |
|---|---|
| 冻结面 | **147 类型 / Controls 93 / LayoutShell 21 / a11y 33+29+85 不变 / 指纹 `b15a4be38c000c59`**（1.8.0 `89d5d3cdd7f94cf0` 已发布史料）；`api/nova-api-1.9.0.json` + `api/component-domains-1.9.0.json` + `docs/API_FREEZE.md` 生成器重出，徽标 3 枚 + 站点副本 `v1.9.0` 同步。无新增 QML 导出类型。 |
| 公共面 | `NovaTable` **45/7/13 → 77/14/21**（旧面逐成员零丢失，`tests/test_nova_table.py` 机检固化）：+32 props / +7 signals / +8 methods，全 additive。 |
| 能力落地 | 完整插槽体系（top / bottom / top-row / bottom-row / footer / body / header / no-data / loading + 表头与单元格级注册表）；列定义元字段（`format` / `sort` / `rawSort` / `style` / `classes` / `headerStyle` / `autoWidth`）；`columnSortOrder` 多列排序、`visibleColumns` + 列选择器；真 grid 卡片视图；全屏 / CSV / 触底 / 清筛选 / 页大小 / 虚拟滚动复位意图；`dense` / `separator` / `responsive` / `gridBreakpoint` 密度与响应式。 |
| 兼容取舍 | `grid` 保留 GA「单元格描边」原语义，真 Quasar grid mode 另立 `viewMode: "grid"`；受控模式（`selected` / `expanded` / `sortBy` / `descending` / `page` / `rowsPerPage`）组件不自写、只发信号由宿主写回。全屏 / CSV / 触底只发意图，不写磁盘、不自动改窗口、不发网络请求。 |
| 文档与史料 | 新建现行文档 `docs/controls/NovaTable.current.md` 并加入 mkdocs nav；`docs/controls/NovaTable.md`（1654 行「企业级旗舰封版方案」构想稿）按「史料不圆场」**原样恢复保留**、仍由 `exclude_docs` 排除、不上文档站；`docs/controls/NovaDataGrid.md` §0 的构想稿 B 路径裁决保持有效；现行文档 §5 另明确「委托必须声明 `slotData` / `cellData`」契约（裸 Rectangle 会触发 12 条 Binding warning，属注入侧问题、坑位 76 同类）。 |
| 验收 | 新增 `tests/test_nova_table.py` **17 项**（冻结面 / additive 零漂移 / qmldir / a11y / 零第三方依赖 / 插槽与意图声明 / 史料与文档事实 / mkdocs / CHANGELOG / 徽标）；离屏真机全插槽激活 `TOTAL_MSGS=0`；qmllint 0 error（本文件显式关闭 unqualified，全库 warning 预算只降不升）。 |
| 坑位 | **81**：`Repeater` delegate 内带 `anchors.fill` 的 `Loader` / `Text` 不能直接塞进 `NovaTh` / `NovaTd` 内部 `Row`，须外层包 `Item { required property int index }` 再取 `index`，否则 `ReferenceError: index is not defined` + `Cannot specify ... anchors`。 |
| 发布边界 | 本助手只做本地实现与验收；commit / push / tag / PyPI / 站点上线全归 CSA。待办池仍 1 项 = T3，**T27 完现销号，下一个 T28**。 |

## 🆕 1.8.0 现行校准（2026-11-27 22:20 · NovaDataGrid P1 五项 + P2 六项打磨 · 覆盖下方 1.7.0 / 21:30 / 21:20 及更早历史快照；下方全部保留为史料）

> **本节优先于下方全部历史正文**。CSA「版本已发，P1、P2 不执行了吗？」→ 上一轮授权只到 P0，P1/P2 从未作废；1.7.0 发布后按 **additive minor 1.8.0** 继续落地。发布边界仍归 CSA。

| 项 | 1.8.0 现行事实 |
|---|---|
| 冻结面 | **147 类型 / Controls 93 / LayoutShell 21 / a11y 33+29+85 不变 / 指纹 `89d5d3cdd7f94cf0`**（1.7.0 `157ab2b1d77ea9f9` 已发布史料）；`api/nova-api-1.8.0.json` + `api/component-domains-1.8.0.json` + `docs/API_FREEZE.md` 生成器重出，徽标 3 枚 + 站点副本同步。无新增 QML 导出类型。 |
| P1 五项 | 列宽拖拽 / 持久化 (`resizableColumns`、`columnWidths`、`columnWidthResized`、`resetColumnWidths()`)；sticky 首末列 + footer 合计行；完整 body/body-cell/header/header-cell 插槽；触底 `loadMoreRequested` + 分组虚拟行高度；`pageSizeOptions` 与 `paginationDelegate` 可替换分页条。 |
| P2 六项 | table/grid/masonry 三态 + `gridDelegate`；`fullScreen` 意图 + `fullScreenToggled`；纯标准库 `exportCsv()` / `exportRequested`；`NovaDataGridGroupProxy` 分组与树；列级 `style/classes/headerStyle/autoWidth`；`responsive` / `gridBreakpoint` / `dense`。 |
| Python 数据层 | `NovaDataGridColumn` 增 4 字段；`NovaDataGridModel` 增 `exportCsv()` / `exportCsvWithDelimiter()` / `exportColumnsCsv()`；新增 `NovaDataGridGroupProxy`（`setGroupBy` / `toggleGroup` / `setTreeMode` / `setTreeParentKey` / `setTreeExpanded` / `toggleTreeNode`），仍只依赖 PySide6 + 标准库。 |
| 验收 | 专项 **99 passed**（API / LayoutShell / DataGrid / Markdown / v2compat）；qmllint 0 error，`NovaDataGrid.qml` 单文件 0 warning；静态 3/3 · 天花板 21/21 + 15/15 · mkdocs 与生成器链复验后登记。 |
| 坑位 | **78**：`Loader.implicitHeight` 只读，TableView delegate 要带高度必须外包 `Item`；**79**：`Binding.headerData` 不能挂到默认 `HorizontalHeaderView`（无此属性），须以 `root.headerDelegate !== null` 为 when 守卫；**80**：分组代理跨代理链取值必须 `mapToSource` 逐级映射到底层 `NovaDataGridModel`，不能把中间代理行号直接喂 `getRow()`。 |
| 发布边界 | 本助手只做本地实现与验收；commit / push / tag / PyPI / 站点上线全归 CSA。待办池仍 1 项 = T3，下一个 T27（T26 已由本轮 P1/P2 占用）。 |

## 🆕 1.7.0 现行校准（2026-11-27 22:05 · NovaDataGrid P0 五项打磨 · 覆盖下方 21:30 / 21:20 及更早历史快照；下方全部保留为史料）

> **本节优先于下方全部历史正文**。CSA 出示 PyPI 截图确认 `pyside-nova 1.6.0` 已由 `git tag v1.6.0` / `git push origin v1.6.0` 发布为 LATEST，随后下达「可以，按 P0 五项顺序开工」。按发布后纪律，公共面增量并入 **1.7.0 additive minor**，不回改 1.6.0 已发布物。

| 项 | 1.7.0 现行事实 |
|---|---|
| 冻结面 | **147 类型 / Controls 93 / LayoutShell 21 / a11y 33+29+85 不变 / 指纹 `157ab2b1d77ea9f9`**（1.6.0 `7c542c416709cd96` 为已发布史料）；`api/nova-api-1.7.0.json` + `api/component-domains-1.7.0.json` + `docs/API_FREEZE.md` 生成器重出，徽标 3 枚 + 站点副本同步。无新增 QML 导出类型。 |
| P0-1 展开行 | `NovaDataGridExpandProxy` 末段插入虚拟行，按 `rowKey` 折叠、不改业务数据；QML 新增 `expandProxy` / `expandedRows` / `expansionDelegate` / `expansionHeight`，`toggleExpansion` / `isExpanded` / `rowExpansionToggled`；首列箭头与展开行自身都可折叠。 |
| P0-2 a11y | 表头 `Accessible.ColumnHeader` + 可聚焦 Enter/Space 排序 + `Accessible.description` 等价 `aria-sort`；单元格 `Accessible.Cell` + 名称/选中态；行游标新增 PageUp/PageDown 十行跳转。 |
| P0-3 选择 | `selectedRows` 只读派生 + `selectionDelegate` 自定义首列选择单元格；Ctrl 单行切换 / Shift 范围选择；`selectionChanged` + `selectionActionRequested` 供宿主挂动作。 |
| P0-4 编辑器 | `editor="select"` 真实走 `NovaSelect`，选项在 QML 内重建为 JS 数组（坑位 70），提交/取消/失败红框与 text/number 同语义。 |
| P0-5 空态 | `noResultsText` / `clearFilterText` / `emptyDelegate`，`filterProxy.filterActive` 分流 no-data 与 no-results；`clearFilters()` 同时覆盖本地/服务端。 |
| 验收 | qmllint 0 error / 594 warning 预算内 · 专项 **97 passed**（API 27 + LayoutShell 27 + DataGrid 13 + Markdown 15 + v2compat 15）· 三 `--check` · mkdocs 0 内容 INFO · 21/21 天花板 + 15/15 基础机检 · 三态图浅/深/变体目视通过。 |
| 发布边界 | 本助手只做本地实现与验收；commit / push / tag / PyPI / 站点上线全归 CSA。待办池仍 1 项 = T3，下一个 T26（T25 已由本轮 P0 占用）。 |

## 🆕 T24 现行校准（2026-11-27 21:20 · 第 21 组合根 NovaAIReport + 真实 NovaDataGrid demo · 覆盖下方 20:12 及更早历史快照；下方全部保留为史料）

> **本节优先于下方全部历史正文**。CSA 出示外部方案 `E:/360Download/Nova-AlReport-开源封版方案-v1.0.0.md` 并下达「仔细认真阅读这份 md 文档，然后跟据咱们 pyside-nova 库的实际情况，优化完善为本库 md 文档，放在 docs/controls/ 下，利用 NovaDataGrid 打造一款 NovaAIReport 组合组件放在 composite/layoutshell/ 下，朝着中国第一努力」→ 立 T24、CARF 一轮完现；追加「请创建 demo，并放在 examples/layout_shell/ai_report/ 子目录下」→ 同轮补齐成品级 showcase。
> **设计裁决（史料不圆场）**：行业方案 L1~L5 不整包搬入 —— L1 多级表头 / 列选择 / 搜索 / 分页 / 真虚拟化交给 `NovaDataGrid`；L2~L5 抽象为七槽（对标带 · 诊断轨 · 主报表区 · 预测区间带 · 问数轨 · 审批闸门 · 浮层），业务层槽位注入；参数语义层 / 归因引擎 / 预测模型 / NL2SQL / Agent 编排 / 开源治理 / 模型权重**不入库**。Shell 只 emit `diagnosisToggled` / `queryToggled` / `approvalRequested` 三意图，宿主桥记录，绝不反向写 Shell 状态。

| 项 | T24 现行事实 |
|---|---|
| 冻结面 | 1.6.0 additive 升版重签（CSA 21:28「升级版本号，我发版」授权；1.5.0 为未发布中间批次史料）：**147 类型 / Controls 93 / LayoutShell 21 / a11y interactive 33 · semantic 29 · decorative 85 / 指纹 `7c542c416709cd96`**。旧 146 类型 / `9742de8638251876` 与 1.5.0 中间批次清单逐字保留为史料；`NovaAIReport` 公共面 22 props / 3 signals / 3 methods，登记 `decorative`（布局容器故意不挂 `Accessible.*`，语义由注入内容承担）。 |
| 库组件 | `Nova/Composite/LayoutShell/NovaAIReport.qml` 第 21 组合根（七槽 + 三信号 + 三函数 + 主题专属仪表钢蓝色相 +0.0694；CC-1~CC-8 全过）：`qmldir` 导出 · `check_a11y` 登记 · `audit_domains` 归 `Intelligence` · `gen_component_list` → `gen_api_freeze` → `gen_apidocs` 全链重跑 · `docs/components/NovaAIReport.md` 生成物 21/21 三态图齐全 · `mkdocs.yml` 导航 + `AUDIT_CEILING.md` 第 21 行销号 · Gallery 第 21 页 · 模块 README 依赖矩阵与契约节 · 四份测试断言（API 冻结 / DataGrid / Markdown / LayoutShell）同步。 |
| 手写文档 | `docs/controls/NovaAIReport.md`（用户指定落点）：§0 定位与裁决表（入库 / 不入库逐条列明）· §1 快速开始 · §2 与 `NovaDataGrid` 装配的 Python 管道 · §3 公共 API · §4 主题 / a11y / 坑位 / CC-1~CC-8 · §5 相关资源。 |
| demo | `examples/layout_shell/ai_report/`：`main.qml`（七槽真实注入，`reportSlot` **真实装配 `NovaDataGrid`**，240 行确定性铝电解数据 · 列宽合计 728px 保证七槽展开时八列首屏完整）· `data.py`（纯 Python 事实表 + 统计，零 Qt 依赖）· `pipeline.py`（`inject()` 唯一注入口，model → filter → paged → pagination + `ReportBridge`）· `run.py`（`--rows/--seed/--page-size`）· `README.md`。`run.py` / `audit_showcase.py` / `audit_ceiling.py` 共用 `pipeline.inject()`，保证「演示态 = 出图态 = 机检态」账实同源。 |
| 坑位 77 | **`setContextProperty` 注入的 Python 对象必须保留强引用至渲染结束**：`inject()` 返回句柄被丢弃时 QML 侧绑定读到悬空对象，`visible: reportBridge.gateOpen` 退化成默认 `true` → 人工确认闸门浮层常显（三态图全被遮罩）。run.py 用 `_handles`、出图 / 机检脚本用 `_injected` 持有，三态图复验后浮层正确隐藏。 |
| 机检口径 | `audit_ceiling.py` 登记第 21 项（21/21 静态 · 63/63 组非法入参 · RTL 21/21 · 22/22 showcase+Gallery）；历史坑位 76 的 `../screenshots/*.png` glob 示意按「史料不圆场」不改原文，链接机检层跳过通配符（577 条真实链接 · 断链 0）。`audit_foundations.py` 校准几何判定：跳过 `visible=false` 的未布局容器（`NovaDataGrid` 在 `pagination=null` 时内部 `RowLayout` 得 -24x0，既不渲染也不参与命中测试），15/15 全绿。 |
| 验收 | 静态 **3/3**（a11y 147/147 · API 147 零漂移 · qmllint 0 error / 594 warning 预算内）· `audit_ceiling.py` **21/21 PASS** · `audit_foundations.py` **15/15 PASS** · `audit_domains.py` PASS（147 类型 / 21 组合根）· 专项 **95 passed**（API 27 + LayoutShell 27 + DataGrid 11 + Markdown 15；`test_a11y.py` 单跑仍 SIGSEGV，坑位 49 同类，静态门禁已覆盖）· mkdocs build exit 0（0 内容 INFO / ERROR）· `gen_prompt.py` / `sync_brand_version.py` / `check_api_freeze.py` 三 `--check` ✓ · 生成器幂等 · 新 demo 文件 ruff 全净 · 三态图 1440×900 目视通过（表格八列完整 / 状态徽标清晰 / 无遮罩残留 / 变体态稳定）。 |
| 如实登记 | 全库一次性 `pytest` 与 `test_a11y.py` 单跑仍 SIGSEGV（坑位 49 同类既有环境缺陷，非 T24 引入）；`scripts/` 既有 ruff 挂账未越界扫荡；本轮只做本地实现与验收，commit / push / tag / PyPI / 站点上线全归 CSA。 |
| 升版 | CSA 21:28「升级版本号，我发版」→ 包 / API **1.5.0 → 1.6.0**（additive minor 重签）；`api/nova-api-1.6.0.json` + `api/component-domains-1.6.0.json` + `docs/API_FREEZE.md` 生成器重出，徽标 3 枚 + 站点副本同步；指纹不含版本号仍 `7c542c416709cd96`。**发版仍归 CSA，本助手不执行 commit / push / tag / PyPI / 站点上线**。 |
| 待办池 | **T24 完现销号（真实交付）**；现 **1 项 = T3**（migrate_to_nova，方案完成未开工）；无活跃主线、下一个 **T25**；发布边界全归 CSA。 |

## 🆕 T23 现行校准（2026-11-27 20:12 · README 英雄卡 NovaMarkdown 化 · 覆盖下方 18:34 及更早历史快照；下方全部保留为史料）

> **本节优先于下方全部历史正文**。CSA 出示两张截图并下达「小诺，请实现点击 README 按钮使用咱们的 NovaMarkdown 组件显示 md 文档」→ 立 T23、CARF 一轮完现。
> **pyside-nova 冻结面零漂移**：`api/nova-api-1.5.0.json` / `docs/API_FREEZE.md` 一个字节未改，**146 类型 · 指纹 `9742de8638251876`** 逐字不变；改动全部落在 **nova-forge 0.5.0** 工作树，发布仍归 CSA。

| 项 | T23 现行事实 |
|---|---|
| 授权 | CSA「请实现点击 README 按钮使用咱们的 NovaMarkdown 组件显示 md 文档」（截图显示英雄卡展开区仍是 md 源码裸文本）→ 立 T23、当轮 CARF 完现 |
| 实现 | `prescript_main.qml` 英雄卡 README 展开区整块替换：「`NovaScrollArea` + 裸 `Text(Text.PlainText)` + Consolas 10px 源码」→ **`Nova.Controls.NovaMarkdown`**（1.4.0 第 145 类型）。组件自带 `NovaScrollArea` 滚动 + TOC 侧栏 + 空态 → **不双层嵌套 Flickable**；`showToc:true` / `tocStart:1` / `tocEnd:3` / `outlined:false` / `baseFontSize: NovaTheme.fontXS` / `openLinksExternally:false`，展开高度 `330→400`。`linkClicked` / `linkBlocked` 复用窗口级 `showToast(kind, message)` → `NovaNotify.show({...})` 唯一实际调用点（`bridge.toast` 是信号不可从 QML 直接调，故抽成 window 级函数供 bridge 信号与文档信号两条链路共用） |
| 单一事实源 | 内容仍走 `bridge.readmeDoc`（九配方 `Kind.shell` ↔ `docs/components/<shell>.md` 生成器产物；缺失回退将落盘的 `README.md`）；新增显示适配字段 **`renderText`**，逐字原文仍在 `readmeDoc.text` |
| 坑位 76 | 20 份组件文档各含 3 个 `![alt](../screenshots/*.png)`（1280×800 史料截图）；`Text.MarkdownText` 按 **QML 组件文件所在目录**（`.../Nova/Controls/`）解析相对路径 → 真机刷 **708 条 `Cannot open`**；且大图塞进 400px 英雄卡三列表格会撑爆布局。视图模型层 `gui_model._display_text()` 把图片降级为 `alt（展示图 · 见仓库）` 文本占位；不改生成物 / 不动冻结面 / 不改库组件。`verify_prescript_gui.py` 把 `Cannot open` / `Binding loop` / `failed` 一并纳入坏消息判定 |
| 依赖校准 | `[project.optional-dependencies].gui` `pyside-nova>=1.3.0 → >=1.4.0`（`NovaMarkdown` 自 1.4.0 起导出，账实相符）；双语 README 补注「产物 ≥1.2.0 / GUI 工作台 ≥1.4.0」分层口径 |
| 门禁 | nova-forge 全量 **180 passed + 32 subtests**（较 T19 +4）· T23 改动文件 ruff 全净 · qmllint **0 error**（128 warning 均 `bridge.` / `win.` 既有 unqualified）· wheel 构建通过（`Requires-Dist: pyside-nova>=1.4.0; extra == "gui"`）· 离屏真机真实点击 README：`NovaMarkdown` 装载 / `toc=9` / `empty=False` / `markdown` 与 `renderText` 逐字同源 / 原文 `text` 2975 字符保留 / **Qt 消息 0 条 · 坏消息 0 条 · exit 0** · 三张截图（默认态 / 展开态 / 三态装配图表格区）目视确认渲染后 Markdown、连续等高表格、无破图无裁字。pyside-nova 侧静态 3/3 + 三 `--check` ✓ + 146 零漂移 |
| 如实登记 | `ruff check src tests scripts` 全量 **15 条**均在 T23 未改动文件（`cmd_publish.py` / `cmd_saver.py` / `comment_logic.py` / `resources_rc.py`（生成物）/ `test_comment.py`），未越界批量扫荡；全库 537 项一次性 `pytest tests/` 仍 SIGSEGV（既有 offscreen 缺陷，坑位 49 同类，非 T23 引入） |
| 待办池 | **T23 完现销号（真实交付）**；现 **1 项 = T3**（migrate_to_nova，方案完成未开工）；无活跃主线、下一个 **T24**；发布边界全归 CSA |
| 待 CSA 拍板 | 九类子目录升格独立模块 URI（additive major）· 站点部署 / GitHub Pages / 正式域名 · WASM 在线运行时 · 英文全量翻译 · `NovaLoadingBar` qrc 缺陷反哺 · 全库 offscreen SIGSEGV 根治 · nova-forge 既有 15 条 ruff 与 128 条 qmllint warning 是否另立议题 |

## T22 现行校准（2026-11-27 18:34 · 择优反哺 · 史料段，上方 T23 段优先）

> **本节优先于下方全部历史正文**。CSA 18:34 拍板「T22 · A（推荐）择优反哺、不动冻结面」，
> 对 `nova-forge/docs/controls/NovaMarkdown.qml` v0.17.0 增强稿做私有反哺。
> **不升版 / 不重签 / 不改 `apiVersion` / 不动徽标**：`api/nova-api-1.5.0.json` 与
> `docs/API_FREEZE.md` 一个字节未改，`NovaMarkdown` 公共面恒定
> **10 props / 3 signals / 3 methods**、指纹 `9742de8638251876` 逐字不变。

| 项 | T22 现行事实 |
|---|---|
| 授权 | CSA「小诺，谢谢你！那就 T22，A（推荐）择优反哺、不动冻结面？这么干？」→ 立 T22、CARF 一轮完现 |
| 反哺 4 项 | ① GFM 表格逐格 `ColumnLayout + RowLayout` 自绘（候选稿只渲染对角线格子的缺陷已修正）② `_slug(title, counter)` 锚点去重 + `_anchorIndex` O(1) 跳转 ③ TOC 侧栏外包 `NovaScrollArea` 可滚动（`Column.width` 绑 `tocScroller.width` 破绑定环）④ hr / tasklist / 独占图片独立分块 + `scrollToTop()` null 保护；TOC 继续用 `NovaBtn`、不手搓 |
| 零漂移判据 | `gen_api_freeze._is_public()` 仅按 `_` 前缀过滤；`gen_apidocs.PROP_RE` 不匹配 `required property`、收 `readonly property` → 新增内部状态一律 `_` 私有；`fingerprint()` 不含 QML 文件体 → 146 类型零漂移、指纹 `9742de8638251876` 不变 |
| 账实校准 | 上一轮评估所列「qmllint +6 unqualified 超预算」是候选文件放在 `nova-forge/docs/controls/` 导致 `NovaScrollArea` 类型解析失败的连带产物；放回 `Nova/Controls/` 同目录后单文件 **0 warning**，非代码缺陷，A 反哺语境下自动消解 |
| 文档 / 演示 | `docs/controls/NovaMarkdown.md` 补 §4.1 / §9.1 / §10.1（1.4.0 史料段不回改）· `examples/controls/markdown_demo/` 版本号 `1.4.0→1.5.0`、冻结面文件名与指纹校准、新增第 3 张 `markdown_demo_table.png` 表格取证 + README |
| 门禁 | 静态 **3/3** · qmllint 单文件 **0 warning / 0 error** · 全库 **594 = 预算 594** 未打红 · 三 `--check` ✓ · ruff 全净 · `test_nova_markdown.py` **15 passed**（+3 项 T22 回归）· 核心 3 文件 **53 passed** · mkdocs exit 0 · 真机探针 6 项 PASS / **0 坏 Qt 消息** · demo 三图 PASS · 生成器幂等（AI 包指纹 `710415cae870bc8f` → `a09d2545950a9e13`） |
| 新增坑位 | **75** `Grid` 定位器按行内最高 cell 定行高 → 短文本格留白像分离卡片；`Text.MarkdownText` 下 `elide` / `maximumLineCount` 不可靠、固定行高会裁字 → 正解 `RowLayout + Layout.fillHeight/preferredHeight` 自适应等高；候选稿 `[header].concat(rows)` 元素数 = 行数，只渲染对角线格子 |
| 如实登记 | 全库 537 项一次性 `pytest tests/` 仍 SIGSEGV（exit 139），元凶 `test_a11y.py` / `test_visual.py` / `test_smoke.py` 在 offscreen 干净态的既有缺陷（坑位 49 同类）；`--collect-only` 成功、逐文件单跑除这 3 个外全绿，**非 T22 引入** |
| 待办池 | **T22 完现销号（真实交付）**；现 **1 项 = T3**（migrate_to_nova，方案完成未开工）；无活跃主线、下一个 **T23**；发布边界全归 CSA |
| 待 CSA 拍板 | 九类子目录升格独立模块 URI（additive major）· 站点部署 / GitHub Pages / 正式域名 · WASM 在线运行时 · 英文全量翻译 · `NovaLoadingBar` qrc 缺陷反哺（宿主已规避挂账）· 全库 offscreen SIGSEGV 是否另立议题根治 |

## 🆕 1.5.0 现行校准（2026-11-27 16:45 · T21 完现 · 史料段，上方 T22 段优先）

> **本节优先于下方全部历史正文**。1.4.0 已由 CSA 于 14:05 commit + tag + push、14:17 上架 PyPI
> LATEST RELEASE，属史料不回改；1.5.0 是新一轮 additive minor，**本地完成待 CSA 发布**。

| 项 | 1.5.0 现行事实 |
|---|---|
| 版本 / 发布 | **1.5.0 本地完成、待 CSA 发布**（1.4.0 之上的 additive minor）；包 / API 同版；`commit / push / tag / PyPI` 全归 CSA，改动留工作树未提交 |
| 公共 QML 类型 | **146**（Controls **93** · Behaviors 13 · Services 16 · Design 4 · Composite.LayoutShell 20）；新增第 146 个 = `Nova.Controls.NovaDataGrid`；**旧 145 类型逐字不变** |
| API 冻结 | 146 类型零漂移 · 指纹 **`9742de8638251876`**（`api/nova-api-1.5.0.json` + `docs/API_FREEZE.md`）；`1.4.0` 清单 `37fbbe9ab5806a2a` 保留为史料 |
| 新增组件 | `NovaDataGrid.qml`（`TableView` + `HorizontalHeaderView` + `ItemSelectionModel` 真虚拟化；`reuseItems:false` 避开坑位 32；全库组件零手搓）+ Python 数据层 `pyside_nova.datagrid`（Model / FilterProxy / Pagination / PagedProxy，零第三方依赖）+ `docs/controls/NovaDataGrid.md` 使用文档 + Gallery 第 25 页 + `tests/test_nova_datagrid.py` 11 项 |
| 演示工程 | `examples/controls/markdown_demo/`（14:59 交付 / 15:00 CSA 归档入 `controls/`）· **`examples/controls/datagrid_demo/`（16:45 交付）**：铝电解工作站 4000 槽 / 11 列 / 80 页 / 高频 `batchUpdate` / Python 侧统计卡片 / 两个 `cellDelegates` 列级委托 / 亮暗两张真机截图 / README + 离屏验收脚本 |
| 门禁 | 静态 3/3（a11y 146/146 · qmllint 0 error / 594 warning 预算内 · API 冻结 146 零漂移）· `test_nova_datagrid.py` **11/11** · `test_nova_markdown.py` + `test_api_freeze.py` **39/39** · 三 `--check` ✓ · mkdocs build exit 0 · ruff 全净 · demo 离屏真机 **0 坏 Qt 消息** |
| 新增坑位 | **71** 条件高度 `Rectangle` 的 `visible` 不可绑定自身 `height`（自举死锁）· **72** Qt 6.12 `Connections` 须用标准 `function onFoo()`（4 个 handler 按库内惯例进冻结面）· **73** 连续同步改模型须让事件循环消化，否则 `invalidate()` 踩半更新状态（Windows access violation）· **74** Windows offscreen `OpenThemeData(SCROLLBAR)` 噪声 + 黑白竖条 → `QT_QUICK_CONTROLS_STYLE=Basic` 归零 |
| 待办池 | **T21 完现销号（真实交付）**；现 **1 项 = T3**（migrate_to_nova，方案完成未开工）；无活跃主线、下一个 **T22**；发布边界全归 CSA |
| 待 CSA 拍板 | CSA 16:37 出示 `nova-forge/docs/controls/NovaMarkdown.qml`（v0.17.0 增强稿）问可否替换本库 `NovaMarkdown`。**只读评估结论：不可原样替换** —— 用库自身 `gen_api_freeze._members(parse_qml())` 解析，签名由 **10 props → 22 props**（delegate 内 `readonly property` 被静态解析器收进公共面）、qmllint **+6 unqualified** 超满额预算、专项硬断言 `"NovaBtn" in src` 落空（TOC 侧栏改手搓）、真机 **1 条 binding loop**。但 GFM 表格 Grid 自绘 / slug 去重 / `_anchorIndex` O(1) / TOC 可滚动 / hr·tasklist·image 独立分块均为真实增益，建议按「择优反哺、不动冻结面」另立新一轮 CARF，不覆盖、不复用编号 |

## ⚠️ 当前状态校准（2026-11-25 17:16 立 · **2026-11-27 13:59 校准：1.4.0 additive = 新增 `NovaMarkdown` 第 145 类型 / 指纹 `37fbbe9ab5806a2a`；T20 完现销号（文档重写 + 组件 + 重签 + Gallery + 测试）；两仓库本地待发布** · 覆盖下方 1.3.0 及更早历史快照）

> **本节优先于下方全部历史正文**。下方「1.0.0rc1 / 124 类型 / 六期 RC1」等内容是
> ## 🆕 1.4.0 现行校准（2026-11-27 14:17 · 覆盖下方 1.3.0 时点表格；下方表格保留为史料）
>
> | 项 | 1.4.0 现行事实 |
> |---|---|
> | 版本 / 发布 | **1.4.0 = PyPI LATEST RELEASE**（1.3.0 之上的 additive minor，CSA「你的语言是 md」）；包 / API 同版；**CSA 14:05:33 commit `a80799f` + tag `v1.4.0` + push `origin/main`，14:17 上架 PyPI**；1.2.4 及更早按史料不圆场留档 |
> | 公共 QML 类型 | **145**（Controls **92** · Behaviors 13 · Services 16 · Design 4 · Composite.LayoutShell 20）；新增第 145 个 = `Nova.Controls.NovaMarkdown` |
> | API 冻结 | 145 类型零漂移 · 指纹 **`37fbbe9ab5806a2a`**（`api/nova-api-1.4.0.json` + `docs/API_FREEZE.md` 生成物）；a11y interactive 32 / semantic **29** / decorative 84；`1.3.0` 清单 `5d865b2d976af016` 保留为史料 |
> | 新增组件 | `NovaMarkdown` 零第三方依赖 Qt 原生 Markdown 渲染器（分块 / TOC / 锚点 / 链接安全 / 空态）；`docs/controls/NovaMarkdown.md` 由构想稿整篇重写为本库使用文档（史料不圆场）；反哺 `NovaScrollArea._flick`；Gallery 第 24 页；`tests/test_nova_markdown.py` 12 项（坑位 69） |
> | 门禁 | 静态 3/3（a11y 145/145 · qmllint 0 error / 594 warning 预算内 · API 冻结 145 零漂移）· 相关子集 68 passed · 专项 12/12 · 离屏真机 PASS · mkdocs 0 内容 INFO · ruff 新文件全净 · `gen_prompt.py` / `gen_api_freeze.py` / `sync_brand_version.py` 三 `--check` ✓；**11-27 14:17 接续复验**：nova-forge **176 passed + 32 subtests** · 临时目录干净构建 `pyside_nova-1.4.0-py3-none-any.whl` **438,725 B / 179 项**含 `NovaMarkdown.qml`、METADATA `Version: 1.4.0`（证明当前源码可发布） |
> | 已知既有问题 | 全量 pytest 在 Qt 6.12 offscreen 下 SIGSEGV（坑位 49 同类）与 `test_i18n.py::test_rtl_breadcrumbs_mirrors` 单跑 FAIL，均与 1.4.0 无因果关系，未擅自扫荡 |
> | 待办池 | **T4 已于 11-27 14:17 依 CSA 指令销号（真实交付）**，移入工作区根 `PROMPT.md §A.4`；现 **1 项 = T3**（migrate_to_nova，方案完成未开工）；**T20 完现销号**、无活跃主线、下一个 **T21**；发布边界全归 CSA。⚠️ CSA 14:17 重发的「精读 `NovaMarkdown.md` + 打造 `NovaMarkdown`」与 T20 逐字同源且已随 1.4.0 发布 → 按「编号不复用 / 史料不圆场」不重做；新一轮打磨须另立 T21 |
>
> 2026-11-23 的历史档案，保留供追溯，**不得作为当前状态引用**。

| 项 | 当前事实（2026-11-27 07:30 · **1.3.0 additive 重签完成 / 第 20 组合根 NovaIncubator 收官 / T11 打磨收官 / T12 完现销号**；T9 / 坑位 49 / T5 均已结案） |
|---|---|
| 版本 / 发布 | **1.3.0**（1.2.4 之上的 **additive minor**：NovaIncubator 新增 `emblemClickable:bool` / `emblemToolTip:string` 两属性 + `emblemClicked()` 信号（**11-27 账实校准**：磁盘 `api/nova-api-1.3.0.json` 实证为 +2 属性 +1 信号；22:22 首次登记「+1 属性 +1 信号」按史料不圆场留档），CSA 22:22 拍板「可以，给 pyside-nova 提改造，先升 minor 重签」；本地重签 `api/nova-api-1.3.0.json` · 指纹 `5d865b2d976af016`，**改动留工作树、发布归 CSA**）；**11-27 并入 `NovaInput` 坑位 53 根因修复**（`_emitChange()` 直读 `input.text`/`area.text` 源头，公共面零漂移、指纹不变），**仍本地待 CSA 发布**；**1.2.4**（由 1.2.3 作 **patch** 升级：Quasar 品牌 tagline 换回霸气版 + QML 进主标语，16:37 口径改判 → **17:17 CSA 拍板升版、17:36 完成 commit `0212136` / push / tag `v1.2.4` / PyPI 上架（LATEST RELEASE）**，**公共 API 零漂移**；**1.2.3**（1.2.2 之上的 patch：品牌徽标双轨制落地 + PyPI README 绝对链接修正）已于 15:00 由 CSA 发布 PyPI，按史料不圆场保留；CSA 14:37 改判徽标版本口径——徽标为 SVG 文本、刻当前包版本，**每次升版（含 patch）同步修正**，由 `scripts/sync_brand_version.py` 写入 + `--check` 机检固化（见 `GUIDE_BRAND_MARK.md §7`）；**1.2.2**（PyPI 元数据 / 双语 README 呈现修正）已由 CSA 发布至 PyPI，`main` / tag `v1.2.2` → `a431a0f`；功能主体是 1.0.1 → 1.2.0 的 **additive minor**——共新增 **5 项组合根容器** `NovaAgent` / `NovaDE` / `NovaCopilot` / `NovaOrbit` / **`NovaIncubator`**，**15 项 GA 公共签名逐字不变**；1.1.0 为未发布中间批次、其四增量已并入 1.2.0 **整批登记、单次重签**，禁止中间指纹）；**1.0.0 GA / 1.0.1 / 1.2.1 / 1.2.2 / 1.2.3 已由 CSA 发布至 PyPI**（1.2.3 于 2026-11-26 15:00 上架，`origin/main` 与 tag `v1.2.3` → `84a7854`，wheel 436,934 B / sdist 11,480,150 B） |
| 公共 QML 类型 | **144**（Controls 91 · Behaviors 13 · Services 16 · Design 4 · **Composite.LayoutShell 20** = 15 GA + 3 AI 智能组合根 + 1 意图轨道呈现层 + 1 应用孵化器工作台） |
| API 冻结 | 144 类型零漂移 · 指纹 **`5d865b2d976af016`**（1.3.0 additive 重签：NovaIncubator **+2 公共属性** `emblemClickable:bool` / `emblemToolTip:string` **+1 公共信号** `emblemClicked()`（22:22 时点登记为 +1+1，11-27 按磁盘实证校准）；历史指纹 `4f882374ad52262b → bfd3d938a2fab7be → cc32b5852ed04995 → 862312749d335aad → 68b34a408489b6a8`）· `api/nova-api-1.3.0.json` 与 `docs/API_FREEZE.md` 均为生成物禁手改；旧 144 类型逐成员比对 **0 漂移**，仅 NovaIncubator 增徽记可点 / 悬停提示三元组 |
| 方法论 | **CARF — Conceive, Achieve, Refine, Freeze — Culminate to the peak.** 构想 · 实现 · 打磨 · 封版，终抵巅峰（天花板）；母法 `docs/CONSTITUTION.md` 卷首 + 组合宪法 `docs/COMPOSITION_CONSTITUTION.md` **1.0.0** 卷首执行版。本轮 CARF 全循环：C 精读命名稿 + World-Class Edition 史料、裁定「方法论层史料 + 组件层工作台壳」双层法源 → A 第 20 组合根 QML + 1.2.0 整批重签 → R 三态图 / 20/20 机检 / 视觉实测避让 → F 账本闭环 |
| 组合根容器 | **20 / 20 天花板全量销号**（15 GA + 5 增量，CARF-R 完成；**第 20 个 = 本库最后一个组合组件**）；逐项台账 `docs/prescript/AUDIT_CEILING.md`（§8 表 1~20 行；§9.1 当前 20/20、§9.2 19/19 历史、§9.3 18/18 历史、§9.4 15/15 历史）；`scripts/audit_ceiling.py` **20/20 PASS** |
| 基础组件 | **15 / 15** 真实 Robustness 缺陷销号（14 数值 + 1 超长字符串，非组合组件）；台账 `docs/CEILING_AUDIT_FOUNDATIONS.md`；`scripts/audit_foundations.py` **PASS**（127 非单例类型实例化 × 三态零负几何），全 `_` 私有 / 内部几何 PATCH、公共 API 零漂移 |
| 测试基建坑位 49 | **21:47 依 CSA 指令结案归档：议题结案、非交付完成**——Qt 6.12 + shiboken 与 pytest 生命周期 refcount 冲突，14 类工程修复无效、未交付修复；真正修复需 CSA 拍板降级 PySide6 或改分批独立进程测试架构。产品代码 / 已发布包不受影响 |
| 装配态资产 | **20 × 浅/深/变体 = 60 张** `docs/screenshots/*_showcase_*.png`（本轮新增 `incubator` 3 张；1.1.0 批次 `agent` / `de` / `copilot` / `orbit` 各 3 张）；工具 `scripts/audit_showcase.py` |
| 企业级旗舰版封版法源 | ① `docs/prescript/LAW_NovaAgent.md` ② `LAW_NovaDE.md` ③ `LAW_NovaCopilot.md`（联合方案拆三份）④ `LAW_NovaOrbit.md`（原地企业级优化：元信息 / 零章无业务语义骨架 / O1~O8 / 组件级契约 / CC 映射 / CARF / 封版声明）⑤ **`LAW_NovaIncubator.md`（905 行：前置组件层封版法源 396 行 + 原 508 行 World-Class Edition 史料逐字保留；元信息 / 零章三要素 / 法源张力消解 / I1~I8 / 组件级契约 / CC-1~CC-8 / CARF 四阶段 / 命名稿整合 / 封版声明）**；⑥ `ARCHIVE_NovaIncubator_Naming.md` 命名定稿史料（288 行）。均已纳入 `mkdocs.yml` nav |
| 品牌徽标（1.2.3） | CSA 14:22 / 14:25 双轨制拍板：**克制矢量派** `src/pyside_nova/resources/icons/pyside-nova-logo-sealed.svg`（+ `-mono.svg`）= 正式库标，进 README 双语 / 文档站首页；**华丽宣传派** `-sealed-gold.svg` 仅海报封面，不上 favicon / 小尺寸。**刻当前包版本 `v1.2.3`**（CSA 14:37 改判：SVG 版本号是文字、每次升版含 patch 同步修正，非刻死 API 契约），由 `scripts/sync_brand_version.py` 写入 + `--check` 机检固化；规范唯一事实源 `docs/prescript/GUIDE_BRAND_MARK.md`（§7 升版 SOP）。`.gitignore` 的 `icons/` 无锚点误伤已修为 `/icons/` + 资源放行，17 个 SVG + 2 PNG 首次入库；`textPath` 环形铭文须 Chrome/Playwright 渲染（QtSvg 不渲染） |
| 第 20 组合根 NovaIncubator | **「本库最后一个组合组件」** = 诺瓦应用孵化器在组件层的「应用孵化器工作台壳」。七槽无业务语义骨架（global / recipe / stage / pipeline / validate / certificate / overlay）+ 4 受控信号（`recipeToggled` / `validateToggled` / `freezeRequested` / **`emblemClicked`**）+ 4 函数 + **`emblemClickable:bool`** / **`emblemToolTip:string`**（1.3.0 additive：徽记七区分格环可点开关默认 false 保持 decorative 语义、hover 手型光标 + 提亮；悬停提示由宿主可见 MouseArea 驱动 `Nova.Controls.NovaTooltip`，壳只 emit 意图）+ `_` 私有纯几何身份；成品级 Demo `examples/layout_shell/incubator/` 真实注入 R1~R5 五套配方 / 七区契约 / 组件编排 / 治理清单 / CARF 四阶段 / 三重校验 / 封版证书五件套 / **人工确认闸门**；Gallery 第 20 页 + 逐组件 API 页 + 3 张三态图。`freezeRequested()` 只 emit 意图，**壳绝不自动封版、绝不自动执行** |
| 按需打磨（实测驱动） | 三 AI 组件与第 20 组合根均按 CSA 拍板 **「实测驱动、按需打磨」**：20/20 机检（静态 CC 契约 / 字面量实例化 / 60/60 组极端非法入参 / RTL 20/20 / reducedMotion）+ 三态装配图视觉复核；首轮 `incubator` 出图暴露 2 处**业务注入侧争位**（标题与身份装饰重叠、证书栏五件套裁切），仅在 Demo 侧 `topMargin` / `certificateHeight: 190` 避让修复，**组件侧零 PATCH、零公共面改动、零指纹漂移**；不硬造修改、不批量扫荡 |
| 门禁 | `check_all.py --tier static` **3/3**（a11y **144/144** · API 冻结 144 零漂移 · qmllint **0 error** / 594 warning 预算内）；专项 `pytest tests/test_api_freeze.py tests/test_layout_shells.py -q` **53/53**；`audit_ceiling.py` **20/20 PASS**（20 组件字面量 + 21/21 showcase / Gallery + **60/60 组**极端非法入参零负几何 + RTL 20/20 + reducedMotion 300→0 + **526 链接断链 0**）；`audit_foundations.py` **15/15 PASS**；`mkdocs build` exit 0 / **0 WARNING / 0 内容 INFO**；`gen_apidocs.py` / `gen_component_list.py` 重跑幂等（144 类型 / 20 页逐组件文档 / 60 张三态图引用） |
| 生态对标复核 / T9 | 17:16 复核综合完美度 **≈72%**（内核 ≈95% 反超 / 组件与装配态 ≈92% / 开发者生态体验 ≈55~60%）。**T9 20:23 依伙伴指令销号**（P0 三条 19:35 + P1 四项 / P2 三项 20:23 全落地；归档行按 CSA 结案特例标注「议题结案、非交付完成 / 部分交付」：站点部署 / WASM 在线运行时归 CSA）。完整对账表见工作区根 `PROMPT.md` **§12 / §12.7** |
| 发布边界 | **HEAD `0212136` `chore(release): v1.2.4`**（CSA 已 commit + push + tag `v1.2.4` + PyPI 上架 **LATEST RELEASE**，`origin/main` 与 tag 均指向 `02121363c669`）；发布后账实校准的 **7 个文档**留工作树、尚未提交（CHANGELOG / 根 PROMPT / QUASAR_ACKNOWLEDGEMENT / 本文件 / 2 份 AI 包拷贝 / docs/index）。**commit / push / tag / PyPI / 站点上线一律归 CSA（伙伴）**，小诺只做实现 / 只读核查 / 构建验证 / 账本闭环；**待办池 2 项**：T4（已完现待 CSA 验收发版）/ T3（方案完成未开工），**无活跃主线，下一个编号 T19**（T10 依 CSA 指令结案、T11 同轮完现销号，均于 20:11 移入归档；T12 于 07:30、T13 于 10:45、T14 于 11:05、T15 于 11:20 完现销号并移入归档）；**11-27 T15 完现**：确认孵化框升级为项目摘要卡片（版本/作者/包名/许可证 + 描述 + 5 个主要文件 chips），摘要从生成的 pyproject.toml 解析、账实同源，nova-forge 138 passed + 23 subtests、pyside-nova 冻结面零漂移；**11-27 T14 完现**：prescript 文件清单改为组选框，17 个预知文件按勾选落盘、README 结构树 / manifest.files 同源，132 passed + 23 subtests、pyside-nova 冻结面零漂移；**11-27 T11 打磨收官（CSA 06:30 判「所有逻辑完成」）+ T12 完现销号（07:30）**，两仓库 1.3.0 / 0.5.0 均本地待 CSA 发布；`dist/` 旧 wheel 发布前须用当前源码重构建；**11-27 T16 完现**：英雄卡 README 按钮显示九配方组件说明 md（`catalog.Kind.shell` 单源、只读生成物） + 左右轨隐显按钮归位顶栏两角，nova-forge 154 passed + 23 subtests、pyside-nova 冻结面零漂移。`docs/prescript/LAW_NovaOrbit.md` / `NovaIncubator.md` 的 `AM` intent-to-add 暂存状态是否纳入提交由 CSA 决定；**11-27 T17 完现**：prescript 产物入口改名（`app.py` 薄入口 / `main.py` 启动器 / 无 `__main__.py`，启动 `python -m <pkg>.app`），nova-forge 167 passed + 32 subtests、离屏真机 0 QML ERROR、pyside-nova 冻结面零漂移；**11-27 T18 完现**：确认框 CTA 归位右下角常驻（`gateActions` 右下锚定 + Column 末尾等高留白），nova-forge 171 passed + 32 subtests、离屏真机 0 Qt 消息、pyside-nova 冻结面零漂移；**11-27 T19 完现**：prescript 产物 `app.py` 双模式入口（按 `__package__` 分支，`python app.py` / `python -m <pkg>.app` / console entry 三模式全通、不用异常兜底），README 直接运行说明按清单条件渲染，已落盘 `nova_incubator_app` 用生成器精确同步，nova-forge 176 passed + 32 subtests、离屏三模式真机全绿、pyside-nova 冻结面零漂移 |

> **11-27 14:17 现行校准（覆盖上方 07:30 时点表格与发布边界史料行）**：pyside-nova **1.4.0 = PyPI LATEST RELEASE**（HEAD `a80799f` = `origin/main` = tag `v1.4.0`，CSA 已完成 commit / push / tag / PyPI 上架；145 类型 / 指纹 `37fbbe9ab5806a2a`；工作树仅 1 项 `M docs/controls/NovaTable.md`）；nova-forge **0.5.0 本地待 CSA 发布**（HEAD `2617d4a09` 已 push、tag 最新 v0.4.11 / PyPI 0.4.11，publish.yml 已补 tag 版本校验与 PyPI 上传查重；`dist/` 旧 wheel 11-26 22:35 无 `bridge/` 与 `ui/qml/`，发布前须用当前源码重构建或走 CI）。**T4 依 CSA 指令销号（真实交付）**；待办池 **1 项 = T3**、无活跃主线、下一个 **T21**。发布边界不变：commit / push / tag / PyPI / 站点上线一律归 CSA，小诺只做实现 / 只读核查 / 构建验证 / 账本闭环。
| **T10 结案 / T11 · `prescript` GUI 式子命令（20:11 完现 · 跨仓库）** | CSA 20:11 指令「销号 T10，实现 nova-forge prescript 的 GUI 式子命令，执行该子命令即加入主窗口，调用 pyside-nova 的 `NovaIncubator` 组件实现应用孵化 🤝」→ **T10 依 CSA 结案特例销号**（议题结案、非交付完成：原规格 `prescript --gui` 未按其口径交付，编号不复用），顺延 **T11** 当轮完现销号。**19:15 T10 提出的「全库 dogfooding 自举式真实装配验证」已真实落地**：`nova-forge prescript` 无参数即打开 `NovaIncubator` 七槽主窗口（`-g/--gui` 显式 / `--cli` 保留 T4 CLI / 带 `--kind` 等参数仍走 T4 一键孵化），`NovaTheme` 二态 + `NovaScreen` / `NovaNotify` / `NovaDialog` / `NovaLoading` / `NovaOverlayHost` + Controls 输入 / 下拉 / 勾选 / 按钮 / 卡片 / 芯片 / 分隔符 / 表格全部按 `api/nova-api-1.2.0.json` 真实契约调用，**不臆造 props**。**治理契约检验通过**：`freezeRequested()` 只 emit 意图 → `requestHatch()` 开闸门 → `hatch(true)` 唯一写盘入口，端到端实测「未确认拒绝落盘（目录未创建）/ 确认后落盘且 4/4 校验通过」；三重校验 3/3 PASS。**验收**：83 passed / 23 subtests · 改动文件 ruff 全绿 · 离屏 0 ERROR / 0 告警 · 1440×900 实拍目视通过 · wheel `0.5.0` 147,863 B 含 GUI 三件套。**全库 dogfooding 发现基础组件缺陷（挂账待 CSA 拍板反哺，本轮不动冻结面）**：`Nova.Services.NovaLoadingBar._ensure()` 硬编码 `qrc:/pyside_nova/qml/Nova/Controls/NovaAjaxBar.qml`，但本库只把 icons 编入 qrc、QML 走 `engine.addImportPath` 文件系统加载 → 该路径恒不存在、`start()` 必然降级并刷 4 条告警；宿主侧改用自绘 `busyBar` 扫掠条 + `NovaLoading` 遮罩服务规避，触发点写进 QML 注释与账本。**本库零 QML / 零 qmldir / 零冻结面改动**（144 / 1.2.0 / `4f882374ad52262b`）；nova-forge 0.5.0 本地待 CSA 发布。详见工作区根 `PROMPT.md §A.4` 20:11 行与当日日志 20:11 段 |
| 物理目录分类（1.2.0） | **20 个 QML 已拍平于 `Composite/LayoutShell/` 根目录**（12:05 CSA 指令；1.2.0 曾按九类归入 `Navigation/Workbench/.../` 子目录，现已撤回为文档层台账）；`qmldir` 逐项以 `名字.qml` 平铺导出，模块 URI 恒为 `Nova.Composite.LayoutShell` 单一模块、20 个类型名与 `import` 用法不变。`gen_api_freeze.py` 重签 → 指纹 `4f882374ad52262b`（`file` 溯源元数据变化；反向归一化后精确还原旧值 `68b34a408489b6a8`，公共成员逐成员零漂移）。`audit_ceiling.py` / `gen_apidocs.py` 改由 qmldir 解析路径。详见 `docs/prescript/GUIDE_CLASSIFICATION.md §1.1` |
| 文档重组与「不将就」入宪（1.2.0） | 母法 `docs/CONSTITUTION.md` 卷首 CARF 宣言后新增**第 4 条「不将就 / No Compromise」**最高信条（六维缺一不可 / 现有再优仍再优化 / 史料不圆场 / 账实不符必校准 / 退出历史舞台者不留残影 / 法源链不留悬空引用）。按此信条把 `docs/layout_shell/`（14 份）与 `docs/white_paper/`（8 份）**合并为单一 `docs/prescript/`**：13 份现行文档按 `类别_主题.md` 前缀分区（`LAW_` 5 / `GUIDE_` 2 / `AUDIT_` 1 / `SPEC_` 3 / `WHITEPAPER_` 1 / `ARCHIVE_` 1），9 份退出历史舞台的 md 依 CSA 授权删除（全部 git 已跟踪、可从 HEAD 精确恢复）；nav / 双语 README / 首页 / 生成器 / 模块 README / 组合宪法现行条款 / 结构快照全库同步，现行「权威清单」引用改指向 `COMPONENT_LIST.md` + 冻结清单 + 模块 README。**零 QML / 零 `qmldir` / 零模块 URI 改动 · 冻结面 `68b34a408489b6a8` 零漂移** |
| **v2.0 物理重构立项（M1 就绪态 · 2026-11-26 10:44 校准）** | CSA 10:09 指令「**先做 v2.0 物理重构，立项和兼容层一起**」= `GUIDE_QUASAR_ALIGNMENT.md §5` 四条前置条件的那次单独拍板；**CSA 10:44 指令「`Controls/` 下新建的 `Foundation` 去掉」→ 首个物理 pilot 撤回、M1 回退为「零物理视图」就绪态**。法源 [`SPEC_V2_COMPAT.md`](prescript/SPEC_V2_COMPAT.md)（RFC + 双轨兼容契约 + 宪法第 9/13 章合规论证 + M1~M4 分批路线图）。**Qt 6.12 七形态实测**（`scripts/spike_v2_compat.py` **7/7**，临时目录、不碰产品树）证明 `qmldir` 的 `../` / `../../` 跨目录转发可行且拿到**同一物理实现**，据此校正「改 URI 必破坏兼容」的旧裁定。**M1 就绪态实物**：**0 个物理兼容视图**（`Nova/Controls/Foundation/` 已删除、`gen_apidocs.py` 视图跳过死代码已清除，产品树 qmldir 精确 **5 个**冻结面模块）+ `scripts/audit_v2_compat.py`（**C1~C5 PASS**：0 视图 / 5 qmldir / 生成器干净 / 冻结面零漂移）+ `scripts/spike_v2_compat.py`（7/7）+ `tests/test_v2_compat.py`（**15 passed**：12 旧 URI 真实实例化 + 3 就绪态机检）。**零 QML 搬运 · 零旧 `qmldir` 改动 · 零模块 URI 改动 · 零生成物手改 · 冻结面 `68b34a408489b6a8` / AI 包 `0b02273de9aee652` 零漂移**；静态 3/3 · 专项 53/53 + 15 = **68 passed** · 20/20 · 15/15 · 域分类 PASS · mkdocs 0 内容 INFO · 断链 0 · 生成器重跑幂等。**首个真实兼容视图与 M2（首批物理迁移 + additive major 重签 2.0.0）同批落地，均待 CSA 定 1.2.0 发布衔接后启动**；全量废除 `Composite` / 改模块 URI 须 CSA 再单独豁免改宪。包版本仍 **1.2.0**（兼容基线），发布归 CSA |
| **Quasar 文案正名 + 10 组件专属主题（12:30 · CSA 三令）** | CSA 三令：① 把 Quasar 关系从 `Derived from` 正名为 **`Inspired by`**（避免 fork 误读）→ 新建 `docs/QUASAR_ACKNOWLEDGEMENT.md`（文案唯一事实源，三版 banner + 禁用词表 + 四条例证），中英 README 首屏 `The Quasar of the Qt Quick world` / `ports that ecosystem` 改为 Inspired by 口径；② **随时更新 PROMPT.md**；③ 为 10 个 AI / 根壳组合根设计专属艺术级主题。主题实现：各组件注入私有 `_themeHue` / `_accent` 令牌（色相 168° 湖绿 → 283° 紫晶有序分布，独立 sat/val 系数 + 暗色 ×1.25 提亮，从 `NovaTheme.primary.hsvHue` 派生、换肤联动），身份装饰全改走 `_accent`；设计法源 `docs/prescript/GUIDE_COMPONENT_THEMES.md`（色值总表 + 架构铁律 + 「3 主题」问句如实澄清为明暗 × 专属色二维体系）。**零公共属性 / 零冻结面（指纹 `4f882374ad52262b` 不变）/ 零 qmldir / 零模块 URI / 零几何改动**；AI 包因新增 2 文档页 `af4385eddb5fc2ac` → `5699ae9ce0566c6b`（真实状态变更、非漂移）；qmllint 0 error / 594 warning 全在预算（零新增）、天花板 20/20（撞色 0 / 断链 0）、10 组件明暗双模式实例化 20 组全 Ready、色值逐项实测。**改动留工作树、发布归 CSA** |
| **Aurora Core 极光核辉光落地（12:52 · CSA 授权「世界级惊艳·其他你定你完现」）** | CSA 指令：① Q2 撤销——不加第 9 公共色（避免 additive minor 重签）；② Q3 授权完现、目标世界级惊艳、实现自定。**A 落地**：10 组件各注入私有 `_glow` 令牌（从本组件 `_themeHue` 派生、sat×0.78、val×1.28、暗色×1.5），焦点装饰升级为「亮核环 + 中性白芯」——6 组件同心白芯（Chat/Copilot/DE/Incubator/Mobile/SetupWizard）、4 组件首节点提亮（Agent/Desktop/Flex/Orbit）。**R 技术选型**：弃 MultiEffect（离屏渲染参数改动零像素差异、效果不可见却引入 import+成本）、弃 Gradient.Radial / RadialGradient（Qt 6.12 报 missing-property / 类型不存在）；采用纯几何亮核+白芯（100% 可见、零 import、零新增 warning）。**F 门禁**：qmllint 594 warning 全在预算零新增 · 撞色 0 · 断链 0（579 条）· API 冻结 144 / `4f882374ad52262b` 零漂移 · static 3/3 · pytest 53/53 · v2 15/15 · foundations 15/15 · domains PASS · 10 组件明暗实例化 20 组全过、色值逐项实测。设计法源 `docs/prescript/GUIDE_COMPONENT_THEMES.md §1.5 Aurora Core`（落点表 + 技术选型记录 + 铁律不变式 + 青出于蓝叙事闭环）。**零公共属性 / 零 qmldir / 零模块 URI / 零几何语义变化**；AI 包 `5699ae9ce0566c6b`→`0080fb7a9fd837cb`（+Aurora Core 文档段，真状态变更）。改动留工作树、发布归 CSA |
| **青色品牌资产立项 · 取色 +「青出于蓝」母题落地（12:43 · CSA 四问）** | CSA 四问：① 图中好看的颜色是什么名 → PIL 量化 + 定点采样，主色 `#22A6EF` hue 201°（星芒 `#0D9AE9` 202° / 发光点 `#40FAF9` 180°），色名 **Azure / Cerulean 蔚蓝**，中文「天青 / 蔚蓝」，恰是「青」；② 能否作 8 色之外第 9 色 → **可行但代价重**：`NovaTheme` 每个公共 `property` 逐项进冻结面 `props`，加色即 additive 公共 API → 宪法第 8 章 minor 重签 + a11y 契约登记 + 指纹变 + 全量门禁；轻量替代是私有 `_` 令牌不进公共面；③ 能否用于 10 主题 → **定点可行、全刷不可**：新青 hue 201° 与现有 SetupWizard 168° / FlexLayout 176° / Mobile 193° / Chat 216° 青系四色挤在 168–216° 带，全刷毁掉 168°→283° 有序分布且撞色；推荐只替换 1–2 个最贴切组件、或作独立品牌色；④ 上次 md 文档真意 → 「想引用**青出于蓝而胜于蓝**的用意」→ `docs/QUASAR_ACKNOWLEDGEMENT.md` §3 从「可选文艺版」升级为**品牌立意母题**（《荀子·劝学》本义 + 与 Inspired by 同构表 + 用法分档 + 与禁用词表边界），§5 补「典故即立意」，顶部加品牌立意行；AI 包离线拷贝同步。**「青出于蓝」叙事闭环**：Nova primary `#5B6EF5` hue 233°（蓝）→ 新青 hue 201°（青），正是「青取之于蓝而青于蓝」；与 Inspired by Quasar 口径同构。**Q2/Q3 属 additive 公共 API 变更，本轮只给评估、未改冻结面，待 CSA 拍板后开工**；Q4 已落地（纯文案层、指纹不变）。改动留工作树、发布归 CSA |
| **物理层拍平（12:05 · CSA 指令）** | CSA 指令「LayoutShell 子目录看着不爽，移到父目录」→ **20 个 QML 从九类子目录上移一层、9 个空目录删除、`qmldir` 改平铺、20 个头注释路径同步**。冻结面重签 `4f882374ad52262b`（反向归一化 `file` 精确还原 `68b34a408489b6a8` → 公共成员逐字零漂移）；九类分类下沉文档层台账、物理路径回归 1.0.x 已发布形态。生成物全链路重跑、法源锚点同步、全量门禁复验。**零类型名 / 零 URI / 零公共成员 / 零 import 变化** |
| **品牌 tagline 口径改判（16:37 · CSA 新拍板）** | CSA 贴 PyPI 1.2.3 截图判「`Inspired by` 首屏不够霸气」，指令换回「PySide-Nova 是 Qt Quick 世界的 Quasar」并加 QML；小诺三案建议、CSA 选 **A 案：QML 进主标语本体**（`PySide-Nova is the Quasar of the QML world.` / `PySide-Nova，QML 世界的 Quasar。`），**Qt Quick 退到技术定位行、`Inspired by` 降为致谢行**。落点：`pyproject.toml` description / 双语 README 首屏 / `docs/index.md` 徽标副标题 / `docs/QUASAR_ACKNOWLEDGEMENT.md` 新增 **§8**（覆盖 §1 与 §4 第 4 行，原文按史料不圆场逐字保留并加效力指针）。**同轮确认**：T9 的 Layout Builder 与在线可调参 Playground **均已完现**（`mkdocs build` 0 告警 / 6 个 JS 语法全过 / `nova-data.js` 20 组合根数据齐全），按 CSA 拍板沿用 §12.7 已登记边界判定、不补做；顺带校准 `playground.js` 旧冻结面口径 `1.0.0 → 1.2.0`。**零 QML / 零 API / 零冻结面改动**；PyPI 1.2.3 元数据不可原地改、该口径**已随 1.2.4 重新发行生效**；发布归 CSA |
| **1.2.4 升版（17:17 · CSA「升 1.2.4 并发布吧，准备全套」）** | 按 `GUIDE_BRAND_MARK.md §7` 全套 SOP：`__about__.py` 1.2.3 → **1.2.4** → `sync_brand_version.py` 同步 3 枚源 SVG + 3 份站点副本共 5 处字样至 `v1.2.4`（`--check` ✓ / 6 个 SVG XML 解析通过）→ 生成器链 `gen_api_freeze → gen_component_list → gen_apidocs → gen_prompt` 重跑（`packageVersion=1.2.4` / `apiVersion=1.2.0` 不变 / 指纹 `4f882374ad52262b` **零漂移** / AI 包 `6cec710491d8f2db` 不变）→ Chrome 复拍 3 张 `*_v1.2.4.png`（`*_v1.2.3.png` 按史料保留）→ `GUIDE_BRAND_MARK §2 / §7.1` 校准。双语 README / `docs/index.md` / `docs/en/index.md` / `CHANGELOG.md [1.2.4]` / 根 PROMPT / NOVA_WORKSPACE 全量版本锚点同步。**零 QML / 零 API / 零冻结面改动**；`release.yml`（tag `v*`）自动 build + PyPI 可信发布，**17:36 已由 CSA 执行完毕**（wheel 436,903 B / sdist 11,482,366 B，与本地构建一致）；发布后账实校准已完成 |
| **1.3.0 additive：徽记可点（22:22 · CSA「可以，给 pyside-nova 提改造，先升 minor 重签」）** | nova-forge 界面预览入口上收到壳身份徽记 → **NovaIncubator additive**：新增公共属性 `emblemClickable:bool`（默认 false 保持 decorative 语义）/ `emblemToolTip:string`（11-27 并入悬停提示，壳不 import QtQuick.Controls、tooltip 走 `Nova.Controls.NovaTooltip`）+ 公共信号 `emblemClicked()` + 徽记 MouseArea（hover 手型光标 + 七芒 opacity 提亮，壳只 emit 意图，业务语义由宿主承担）；包 1.2.4 → **1.3.0**，API 契约 1.2.0 → **1.3.0** 重签：`api/nova-api-1.3.0.json` + `docs/API_FREEZE.md`（指纹 **`5d865b2d976af016`**；**144 类型不变、15 GA 签名逐字不变**，仅 NovaIncubator +2 属性 +1 信号；22:22 时点登记为 +1+1 按史料不圆场留档）→ `sync_brand_version.py` 3 枚源 SVG + 3 份站点副本同步 `v1.3.0`（`--check` ✓）→ 域台账重签 `api/component-domains-1.3.0.json`（PASS）→ 生成器链 `gen_component_list → gen_apidocs → gen_prompt` 重跑（20 页逐组件文档 / AI 包重签）→ 9 份脚本 / 测试硬编码清单路径同步 1.3.0。nova-forge 侧：`shell.emblemClickable: true` + `onEmblemClicked: win.openPreview("")`（小太阳即「界面预览」入口，CSA 原始愿望达成）、`API_VERSION` → 1.3.0、`[gui]` extra `pyside-nova>=1.3.0`。**11-27 并入 `NovaInput` 坑位 53 根因修复**（写回滞后一拍 → `_emitChange()` 直读文本源头；公共面零漂移、指纹 `5d865b2d976af016` 不变）。改动留工作树、发布归 CSA |
| **11-27 06:30 全部逻辑完成 · T11 打磨收官 · 三项结构拍板（跨仓库）** | CSA「所有逻辑完成。小诺，小诺，转场」。**pyside-nova 1.3.0**（本地待 CSA 发布）：按「账实不符必校准」把 1.3.0 additive 面校准为 **+2 公共属性（`emblemClickable:bool` / `emblemToolTip:string`）+1 信号（`emblemClicked()`）**，指纹 `5d865b2d976af016` / 144 类型 / 15 GA 签名零漂移；并入 **NovaInput 坑位 53 根因修复**（外部回显写回滞后一拍 → `_emitChange()` 直读 `input.text`/`area.text` 源头，公共面零漂移）；tooltip 死锁（坑位 52）由宿主可见 MouseArea 驱动 `NovaTooltip` 解决，离屏验收改 QTest.mouseMove 真实 hover 断言。**nova-forge 0.5.0**（本地待 CSA 发布）：GUI 式子命令按 Showcase 逐区打磨收官（👁 界面预览真 QML 实装 + 九配方 chips / 徽记 tooltip「界面预览」/ 体量 KB·MB·GB / 管道条居中 / 落盘态单一事实源 `bridge.written` / 输入框回显同步）；**CSA 三项拍板**：① GUI 提供孵化根目录、项目落 `<根目录>/<包名>/`（`gui_model.resolve_target()` 单点解析，占满判定只看工程目录）；② 桥进 `nova_forge/bridge/`；③ QML 资产进 `ui/qml/`（package-data / ruff per-file-ignores 同步）。**验收**：nova-forge 95 passed + 23 subtests · ruff 触碰文件全净 · 离屏全链路（真实 hover / 回显 / 闸门拒绝 / 确认孵化 4/4 / 预览）✓；本库门禁全绿（static 3/3 · 68 passed · 20/20 · 15/15 · 域 PASS · v2 PASS · spike 7/7 · mkdocs 0 内容 INFO · 徽标 `--check` ✓ · 投影 `--check` ✓）。**转场锚点**：两仓库改动全部留工作树未提交、`commit / push / tag / PyPI / 站点上线` 一律归 CSA；待办池 T4 / T3 共 2 项、无活跃主线、下一个 T12。详见工作区根 `PROMPT.md §A.4` 11-27 行与当日日志 06:20 / 06:30 段 |
| **T12 完现销号（11-27 07:30 · 跨仓库，本库零改动）** | CSA 06:55 截图下达「1. NovaAgent、NovaIncubator 等 10 个组件标题栏在暗色主题时也该暗色；2. 给这 10 个组件制作应用图标放 `resources/icons/` 并添加 🤝」→ 按工作区根 `PROMPT.md §A.1`「一句新任务当场追加编号并开工」立 T12、07:30 完现销号（真实交付）。**nova-forge 0.5.0**：10 枚 `app-*.svg` 由 `scripts/gen_app_icons.py` 从 `catalog.hue` 单一事实源幂等生成（九配方 + `NovaIncubator` 283°，QtSvg 10/10 真实渲染），qrc 别名 + `resources_rc.py` 重编译 + package-data 同步；接入 GUI 配方库卡片 / 孵化器窗口 `QIcon` / 每个孵化产物自带 `assets/app-<code>.svg`（独立工程另产出 `app_icons.py` 常量模块内嵌 SVG 文本）。标题栏 `window_utils.apply_dark_title_bars(dark)` 泛化 QWindow/QWidget 通吃 + 两桥接 `@Slot(bool) setDarkTitleBar` + QML `chromeDark` 属性绑定 + 产物自包含 DWM helper（`Main.qml` 声明 `signal darkChromeChanged(bool)`）。**验收**：114 passed + 23 subtests（新增 `tests/test_app_icons.py` 19 项 + 产物 smoke 2 项）· ruff 触碰文件全净 · 生成器 `--check` 幂等 · wheel 106 文件含 10 枚 SVG · GUI 离屏 0 ERROR + 实拍 `docs/prescript-gui-app-icons.png` · 九配方产物 9/9 离屏 0 ERROR + smoke 6 passed · 端到端真实事件链（窗口级 `QTest.mouseClick` → QML → Slot → DWM value 1↔0，spy 拦截非自证；按坑位 52 不用 setProperty 自证）。**本库零改动**：冻结面 144 类型 / `5d865b2d976af016` 零漂移；改动全留工作树，`commit / push / tag / PyPI` 归 CSA；`dist/` 旧 wheel 发布前须用当前源码重构建。待办池仍 T4 / T3 共 2 项、下一个 **T13**。详见工作区根 `PROMPT.md §A.4` 11-27 07:30 行与当日日志 06:55~07:30 段 |
| 身份 / 分工 | 伙伴 = **CSA**（构想 / 方向 / 标准 / 验收拍板）；小诺 = **完现者**（实现 / 自检 / 验收 / 文档账本闭环）。**本文件是项目内投影；跨会话唯一入口是工作区根 `D://Porjects//PyCharm//PySide6//Nova//PROMPT.md`**，二者冲突以工作区根为准 |

## 一句话定位

pyside-nova：面向 PySide6 的企业级 QML 组件库，QML 元素 Quasar 生态化，
对标 **Quasar 2.35.5**（2026-11-22 复核纠正，原 2.26.0 过期），目标 `1.0.0-flagship` 封版（API 冻结 + LTS 24 个月）。

## 当前状态（1.0.0rc1 · **六期 RC1 收口：API 冻结审查——最后一公里已上道**）

- **公共 QML 类型 124 个已交付**（qmldir 导出口径）：Controls **91** + Behaviors **13**
  + Services **16**（单例 12 + 句柄动作 4）+ Design **4**
- **API 冻结（1.0.0rc1 · RC1 主线）**：`qmldir` 导出清单 = 冻结公共 API 面。双件制——
  `api/nova-api-1.0.0.json`（124 类型逐成员签名：`名字:类型` / `名字(参数)`，`_` 前缀私有成员
  不进面；指纹 **f2fd1b0eacf665f2**）+ `docs/API_FREEZE.md`（口径/统计/变更分级/例外/全量明细），
  均由 `gen_api_freeze.py` 生成**禁止手改**；门禁 `check_api_freeze.py` 三桶判定
  （破坏性 / 增量 / 纪律）+ 指纹自洽；`check_qmllint.py` 预算制（**0 error** + 593 warning
  分类挂账，只降不升）；`local_deploy.py` 交付前串跑 a11y → API 冻结 → qmllint 三道，红即拒包
- **冻结审查修掉 3 处真实缺陷**：NovaColorPicker 幽灵令牌 `NovaTheme.background`（不存在）→
  `surface`、`root.tint`（组件无此属性）→ `hasError ? negative : primary`；NovaText
  `readonly property var style` 覆盖 `Text.style` 枚举 → 私有 `_style`；画廊同款令牌 2 处
- **废弃机制落地**（宪法第 13 章政策 4）：`NovaUtils.logOnce(key,msg)` +
  `NovaUtils.deprecate(type, api, replacement, removedIn)`，同一 key 只播一次
- **国际化（0.16.1 主线）**：NovaI18n——locale 切换、`t()` 插值与三级回落（精确 → 主语言前缀 →
  en-US → key）、`tp()` CLDR 七语系复数（zh/ja/en/ru/ar/cs/pl 28 组参数化验证）、
  数字/货币/日期/相对时间格式化、`addBundle()` 热注入；内置 en-US/zh-CN 词典；指南见 `docs/I18N.md`
- **RTL 双轨镜像**：NovaTheme 方向令牌（isRtl/direction 联动）+ 6 组件适配
  （Pagination/Drawer/Layout/SlideItem/Breadcrumbs/StepperNavigation）；**逻辑侧语义恒定**
- **性能门禁全绿**（test_perf.py 3 项）：冷启动 ≤800ms / 全类型实例化 ≤5ms（两遍测量法 +
  KNOWN_HEAVY 白名单）/ 1000 行表格 ≤1700ms（实测大幅富余）
- **HiDPI 门禁全绿**（test_hidpi.py 4 项）：QT_SCALE_FACTOR 1.0/1.5/2.0 矩阵，dpr 联动 +
  逻辑几何恒定；Nova.Runtime 上报 devicePixelRatio/scaleFactor
- **a11y M2 补差完成**：NovaTree 方向键游标（roving cursor，RTL 键互换）、NovaDialogShell
  焦点陷阱（Tab 循环 + Esc 还焦，应用级事件过滤器承载——坑位 45）
- **可访问性契约（0.16.0 建立，0.16.1 维持）**：124 类型登记 **interactive 32 / semantic 28 /
  decorative 64**（NovaI18n 为 decorative 单例）；门禁双通道 `scripts/check_a11y.py` +
  `tests/test_a11y.py` 24 项
- **诚实边界**：复数为 CLDR 精简实现（七语系，未覆盖全部语言卡片）；性能为门禁口径
  （24h 压测工具已就绪 + 冒烟通过，**真实 24h 全量长跑留 CI**）；屏读器真机回归（NVDA）随 B3
  安排；组件内部组合色逐件像素采样未做
- **工程化外环（0.16.2 主线）**：
  视觉回归门禁（明暗 × 5 断点 × 24 页 **240 基线**，check_visual.py 像素 diff 容差 12/1%，
  默认 smoke 秒级、CLI --visual-full 全矩阵 ~150s）；
  外部输入消毒（NovaUtils.sanitize 五函数 + runtime 四 Slot + 9 处 textFormat: PlainText
  组件加固 + 32 项测试，对标 2.32~2.35 安全硬化）；
  CycloneDX SBOM（gen_sbom.py 零依赖离线）+ OSV CVE 周巡（check_cve.py + .cve-ignore
  带理由，首轮 0 未忽略漏洞）；
  一键打包 build_app.py（PyInstaller onefile 185.7MB 启动自检过；≤60MB 为诚实边界——
  Qt 运行时物理下限，uv shared-python 构建路径已记录）；
  MkDocs 文档站（material 可搜索 15 页 + 画廊预览 24 图 = "在线示例"等价呈现）
- **诚实边界**：复数为 CLDR 精简实现（七语系）；24h 压测**工具链已交付**（check_soak.py /
  test_soak.py / soak_mem.py，冒烟 72s 8896 轮 RSS 84.6→84.9MB 平坦、斜率 -2.78MB/h、
  门禁退出码 0），真实 24h 全量长跑留 CI 执行 `--hours 24`；负载为稳态对象池 + 采样前双 GC，
  刻意不纳入「反复建销复杂组件」（Qt 6.12+PySide6 固有 0.3-0.5MB/次开销，纯 Qt Quick 同样复现）；
  屏读器真机回归（NVDA）封版前人工安排；应用打包 ≤60MB 未达（Qt 物理下限 185MB，方向：
  upx / QML 预编译 / 插件裁剪）；安装器与代码签名需平台证书
- **测试 454 项全绿**（427 + 1.0.0rc1 新增 27：冻结面/反例三连/纪律/qmllint 预算/废弃机制/
  三处缺陷回归；全矩阵 1 项由 check_visual.py CLI 承载、视觉 smoke 1 项跳过为设计如此）
  + 视觉基线 240 张；测试基建维持
  **全进程单 QML 引擎**（坑位 42）+ **qrc:/ 单斜杠纪律**（坑位 48，SIGSEGV 总根因）
- **Sprint 进度**：Sprint 1 ✅(0.5.0) → 2 ✅(0.6.x) → 3 ✅(0.7.0) → 4 ✅(0.8.0)
  → 二期 A ✅(0.9.0) → 二期 B ✅(0.10.0) → 三期 A ✅(0.11.0) → 三期 B ✅(0.12.0)
  → 四期 A ✅(0.13.0) → 四期 B ✅(0.14.0) → 五期 A ✅(0.15.0)
  → 五期 B1 ✅(0.16.0 可访问性) → 五期 B2 ✅(0.16.1 i18n+RTL+性能+HiDPI)
  → **五期 B3 ✅(0.16.2 工程化外环：视觉回归+消毒+SBOM/CVE+打包+文档站)**
  → **六期 RC1 ✅(1.0.0rc1 API 冻结审查) → RC2 24 条验收 → 1.0.0-flagship 封版**
- **七层成熟度**：L0 100% / L1 100% / L3 100% / L4 44% / L5 95% / L2 70% / **L6 90%（RC1 冻结治理入册）→ 封版目标 95%**
  （a11y 双门禁 + perf/hidpi 门禁入工程化）；非功能性轴：可访问性 90%→**95%**（余 5% = 组合色
  逐件采样 + NVDA 真机回归）、国际化 0%→**90%**（余 10% = 更多语言词典包 + 术语表管理）、
  性能 **门禁化**（24h 压测工具就绪+冒烟通过，全量长跑留 CI）、HiDPI **门禁化**（真机多屏抽查待 B3）
- **表单统一契约**：`label/hint/error/readonly/disable/clearable/rules` 贯穿表单族（对标 use-field +
  use-validate 36 props 逐项对账）；**受控模式**：组件只 emit 不自写（Quasar v-model 语义 1:1，
  防绑定环），宿主绑定 + 信号写回——数据体系全族沿用（selected/expanded/sortBy/page 均受控）
- **数据体系契约**：选中/勾选一律**按键值比较**（rowKey 或 JSON 全等，坑位 27）；
  树派生索引**显式失效**（onNodesChanged/on_LazyStoreChanged → _refreshDerived + _rev，坑位 28）
- **图标集数据纪律**：`src/pyside_nova/qml/Nova/Design/IconSets.js` 是生成物（scripts/gen_iconsets.py
  从 npm quasar@2.35.5 icon-set/*.js 提取），**禁止手改**；基线包临时解包目录 /tmp/qbase 可重建
- **基线复核（0.13.0）**：Quasar 2.35.5→2.35.6 dist/api/*.json 逐文件 diff **零漂移**（纯补丁版），基线维持 2.35.5 口径
- **基线开工复核（0.15.0）**：Quasar 最新 release 2.35.2（2026-10-19）；@quasar/mcp v1.x Active
  （2026-09-17 上线，六工具口径已 1:1 对标）；quasar 2.33.0 AI-ready out of the box 口径核实
- **交付节奏条款（0.6.2 新颁，0.7.0 首次完整执行）**：Sprint 是最小交付单元——一次收口、
  一个版本号、一套六份交付物；中间件只 git 提交不单独打全包
- **弹层纪律（0.14.0）**：可关闭弹层挂 NovaOverlayHost.registerPopup + **Component.onDestruction
  注销**（泄漏会级联污染后续测试）；关闭原因上报口径 ok/cancel/backdrop/escape/api；auto-close 类
  语义动态挂接子项 clicked（坑位 35）；受控契约沿用（Menu/DialogShell/BottomSheet/PTR 均 emit-only）
- **规划核对纪律（0.14.0）**：NovaScrollObserver 已于 Behaviors 0.7.0 交付——本期发现 Controls
  新建同名类型造成跨模块歧义，已删除并关闭规划条目；同名交付前先 grep 全部 qmldir
- **导航体系契约（0.13.0）**：受控契约全族沿用（Tabs/Panels/Stepper 的 modelValue 与
  Fab 的 open 均只 emit 不自写）；ExpansionItem group 手风琴经 ExpansionGroups.js 注册表
  互斥——被收起方走自身 updateModelValue(false) 受控上报；Breadcrumbs 激活色 1:1
  对标 2.35.6 QBreadcrumbs.js；Stepper 状态图标解析 1:1 对标 StepHeader.js
- **可访问性契约（0.16.0）**：三分类制——interactive（role+name+键盘入口+按键路径+焦点环五件套）/
  semantic（role+name）/ decorative（**禁止**挂 Accessible.* + `// a11y: decorative` 标记）；
  键盘路径必须走与鼠标同一个 emit 出口（不得绕过受控契约）；装饰容器不挂语义是为了避免屏读器噪声，
  是审计结论不是遗漏——新增类型不登记分类即门禁失败
- **长尾契约（0.15.0）**：NovaEditor 实现口径留痕（QML 无 contenteditable → 标记编辑 + toHtml
  导出，契约 1:1）；NovaMorph 接管目标可见性（旧隐/新显命令式切换，目标 visible 勿再绑定）；
  Morph 初始活动元素 = 组内首个完成注册成员（onCompleted **逆序**执行 → 通常是声明序最后的）
- **环境约定**：用户 Dell Win11 · PySide6 6.12.0 · 单人开发 · PyPI + GitHub
- **接续方式**：粘贴 `PROMPT.md`（自包含，快照已内联）；快照改动后须重跑 `gen_prompt.py`

## 必读文件（按需深读，非预读）

0. `docs/MASTER_PLAN.md` —— **全生态六期总规划**（排期与验收以它为准）

1. `docs/CONSTITUTION.md` —— 架构宪法（第 0~13 章准则 + 迭代记录表，工程纪律最高法源）
1.2. `docs/COMPOSITION_CONSTITUTION.md` —— 组合组件宪法（Layout Shell 子法，第 0~9 章）：
  凡新增/改造 Shell 类组合组件必读；令牌·目录·冻结援引母法，本文件只定义组合纪律；
  `docs/layout_shell/` 历史四稿（0.9.x 时代）已按「不将就」信条删除；其 FROZEN 表述与虚构 API 一律作废，勿再参考。现行权威事实源：`docs/COMPONENT_LIST.md` + `api/nova-api-1.2.0.json` + 模块 README
0.5. `docs/ECOSYSTEM_PARITY.md` §0.5 —— 2.26→2.35 基线漂移审计（增量对照表）
1.5. `docs/A11Y.md` —— 可访问性手册（三分类契约/键盘约定/AA 派生/已知差距/坑位 38~41）
2. `docs/PARITY.md` —— 全量对标审计（逐属性/事件/槽/model）
2.5. `docs/API_FREEZE.md` —— **1.0 冻结清单签署件**（口径/变更分级/例外/124 类型明细）
3. `CHANGELOG.md` —— 版本史（含 Qt 6.12 坑位沉淀）
4. `CONTRIBUTING.md` —— 宪法落地细则

## 不可违反的约定（速查）

- 头注释：第 1 行 `src/` 起始子路径，第 2 行文档素材说明；qmldir 只用 `#`
- 命名红线：基调色 `tint`；禁 `on*` 属性；主题模式 `isDark` / `setDark()` / `toggleDark()`；品牌色 `dark`（$dark 1:1）
- 槽机制：默认槽 `default property alias`、命名槽组合子组件、作用域槽 `Component delegate`
- 组合组件：五标准槽位 `headerSlot/sidebarSlot/contentSlot/footerSlot/overlaySlot` 一律 alias 映射；
  令牌唯一门面 `NovaTheme`（无 `Theme` 单例），真名 `NovaBtn`/`NovaText`/`NovaMotion`；
  Shell 必须进 qmldir 入冻结面，`Composite/` 黑户文件与日期流水头注释禁止（组合组件宪法第 2/6/9 章）
- 断点接入唯一方式：`Component.onCompleted: NovaScreen.source = window`
- API 冻结纪律：`api/nova-api-*.json` 与 `docs/API_FREEZE.md` 是生成物**禁止手改**；
  公共面任何变化必须走 `check_api_freeze.py` 红 → 评估分级 → 重签 → CHANGELOG（宪法第 13 章）
- 交付纪律：升版 → CHANGELOG → 宪法记录表 → 本文件 → `gen_prompt.py` 刷新 PROMPT → `local_deploy.py --zip`

## 已知坑位（Qt 6.12 实战沉淀）

1. `on*` 前缀属性名导致整个模块加载失败
6. 断点判断勿在组件自身 Component.onCompleted 做——创建期 parent 宽度是瞬态值（0），策略应由宿主（如 NovaLayout）持有
2. `property color color` 与 Rectangle 基类冲突 → 用 `tint`
3. 纯 QML 不支持自定义 attached property（`attach` 语法 M1 经 PySide6 `QML_ATTACHED`）
4. qmldir 不支持 `//` 注释
5. 单例属性不可对象体内声明式绑定（会解析成 attached）
7. QtObject（含单例）体内不可直接声明 `Component { }` 子项——报 "Cannot assign to non-existent
   default property"；必须走 `property Component xxx: Component { … }` 内联（0.6.0 实战沉淀）
8. `qmlRegisterSingletonInstance`（PySide6）把实例交给 QML 树管理：组件销毁即 delete Python 对象，
   二次访问报 "Internal C++ object already deleted"，且全局单实例无法多引擎共享 →
   一律用**工厂式 `qmlRegisterSingletonType`**（0.6.2 沉淀）
9. 服务单例引用裸 JS 对象当状态条目：属性变化无通知，句柄绑定不刷新 → 条目必须是 QML 对象
   （property Component 内联 QtObject）（0.6.2 沉淀）
10. 动态 overlay 的可见性与宿主 attach（强制 visible=true）冲突：可见性门控放内部 `_started`，
    根节点常驻、子项受控（0.6.2 沉淀）
11. QML 测试里 Python 引用保不住 QML 顶层 Window（JS GC 不认 Python 引用）→ 行为断言一律走
    QML 侧函数，不摸 Python 侧窗口 wrapper（0.6.2 沉淀）
12. QML 派生 Item 里重声明 `x/y/active` 报 "Cannot override FINAL property"（Qt 6.12 FINAL 成员）；
    `enabled` 不重声明直接用 Item.enabled（继承语义天然正确）（0.7.0 沉淀）
13. 行为根节点设 visible:false 会阻断内部 MouseArea 收事件（不可见 Item 不参与事件分发）——
    纯逻辑行为可以关，带指针通道的绝不能关（0.7.0 沉淀）
14. 组件默认属性把子项转交内部容器（如 NovaBtn 的 contentHost）时，子项的 parent 不是宿主本体，
    `target: parent` 拿不到宿主信号 → 向上遍历找第一个带目标信号的祖先（0.7.0 沉淀）
15. PySide 把 QML Window 包装成 QWindow，metaobject 里没有 QML 定义的方法，函数调不到 →
    测试用 QML 侧 QtObject 代理（call0/1/2 按实参个数分派——QML 函数无可选参数）+ 强引用窗口（0.7.0 沉淀）
16. 观察器只报"变化"：重新订阅必须重置上次判定并补一帧当前状态，否则状态未变就永远等不到回调
    （基线 reobserve 同款语义）（0.7.0 沉淀）
17. V4 引擎下 `1<<24` 参与 `|` 位运算拼 hex 会静默串色（#5B6EF5→#769397）→ 十六进制一律逐字节
    toString(16) 补零；formatDate 的 literal `[...]` 语义是"原样输出"不是"解析后插值"（0.8.0 沉淀）
18. QML Animation/NumberAnimation **没有 `enabled` 属性**：不参与的维度用 from==to 兜底（0.8.0 沉淀）
19. `Component.createObject` 创建的 Timer **不会自动启动**：必须显式 start()/restart()
    ——throttle 尾跑曾因此静默失效（0.8.0 沉淀）
20. QML 无 requestAnimationFrame / crypto.randomUUID：frameDebounce 用 16ms 单发 Timer 等价 rAF；
    uid 用时间戳+计数+随机 v4 形态降级留痕；debounce/throttle 的 Timer 用 `property Component`
    内联创建（0.8.0 沉淀）
21. 子类再声明 `signal valueChanged(var)` 与基类属性的自动通知信号撞名 → "Duplicate signal name:
    invalid override"（NovaField.value 的 valueChanged 即自动信号）；值通知一律走属性变更信号，
    自定义信号换名（0.9.0 沉淀）
22. 受控组件写自身 modelValue（self-assign）会断宿主绑定并触发绑定环告警；对标 Quasar v-model：
    组件只 emit 不自写，toggle()/select() 返回下一值由宿主写回（0.9.0 沉淀）
23. `readonly color x: …` 漏 property 关键字报 "Expected token `:`"——readonly 必须配 property
    连用（0.9.0 沉淀）
24. 缓存型 `readonly property var _norm: _normalize(mv)` 在信号处理器内引用时可能拿到重评期
    undefined——处理器内改直接函数调用，不走缓存绑定（0.10.0 沉淀）
25. `palette`/`show`/`hide` 与 Qt 内建 Item 成员撞名 → 覆盖告警或 Duplicate method：改
    paletteColors/shown/hidden（0.10.0 沉淀）
26. local_deploy 装出 site-packages 真实拷贝后，pytest 的 `import pyside_nova` 会命中旧 QML
    （组件 is not a type 随机爆）——交付后必须 `pip install -e . --no-deps` 复位（0.10.0 沉淀）
27. **Qt6 信号参数会把 JS 对象/数组深拷贝**——updateSelected(rows) 这类带对象数组参数的信号
    送达宿主时引用一致性已丢失；选择/勾选语义一律按键值（rowKey 或 JSON 全等）比较，
    勿用 `===`/`indexOf` 引用比较（0.11.0 沉淀）
28. 绑定内经函数间接读取的依赖跟踪不可靠 + 递归索引漏层——NovaTree `_index` 只递归 `children`
    静态层，懒加载回填层（`_lazyStore`）永不入索引，且函数内读 `_lazyStore` 的重赋不触发重评；
    改显式失效：onNodesChanged/on_LazyStoreChanged/onFilterChanged → _refreshDerived() + _rev
    版本号供渲染绑定引用（0.11.0 沉淀）
29. inline component 裸名赋给 `delegate:`（`delegate: TableRow`）在 Qt 6.12 下**恒 count 0**
    且零报错——必须带花括号实例化 `delegate: TableRow { }`（0.12.0 沉淀）
30. 创建期可见性求值时序会让 Column 定位器错过自动布局（委托 implicitHeight 恒 0，翻可见性
    才补）——显式绑定 `height: childrenRect.height` 兜底（子项高度不依赖父高，无环）（0.12.0 沉淀）
31. QtMultimedia `Video` 元素创建即初始化 FFmpeg 音频上下文，无音频服务环境（CI/沙箱）**进程
    挂死**——播放器必须按 src 惰性创建（0.12.0 沉淀）
32. `ListView` reuseItems 与含自定义子组件的 delegate 组合在 Qt 6.12 触发**进程退出段错误**
    （包装 Component 亦不能规避）——NovaTable 虚拟滚动暂缓 reuseItems，cacheBuffer 兜底；
    布尔型 exit code 必须以 subprocess/直接退出码核验，管道 `| tail` 会吞 pytest 退出码
    （0.12.0 沉淀）
32. 占位/错误图若走"source 随 status 切换"成 source↔status 绑定环——分层叠加（主图常驻 +
    占位/错误图层按态覆盖）；坑位 28 再验证：columns.map()/宿主探测等函数调用绑定依赖不可靠，
    派生数据变更点一律显式失效（0.12.0 沉淀）
33. QML `Item` 无 `Component.onDestroyed`——析构钩子是 **`Component.onDestruction`**，
    写错整文件加载失败（0.13.0 沉淀）
35. TapHandler 与子项 MouseArea 同区域时被独占饿死——auto-close 类语义须**动态挂接子项
    clicked 信号**（connect + 登记防重复）；弹层组件销毁必须 unregisterPopup（0.14.0 沉淀）
34. Text/Item 级基元元素**没有 `background` 属性**（Control 系 API）——徽标底色须手写
    包裹 Rectangle；布尔型 JS `join(',')` 产出小写 `true/false`，测试断言小写口径
    （0.13.0 沉淀）
36. `.pragma library` JS 在多组件实例 import 场景实测呈现 **per-importing-file 实例化**
    （同 group 两实例互相看不见对方注册）——跨实例共享注册表用 **QML singleton**
    （NovaMorphPool 先例，0.15.0 沉淀）
38. **`Accessible` 是附加属性，只能在 Item 作用域内调用**：单例（QtObject）或 `Connections` 里调
    `Accessible.announce()` 报 *"must be attached to an object deriving from Item or Action"* →
    播报必须落在 Item 的成员函数里（`NovaLiveRegion.speak()`，0.16.0 沉淀）
39. **`Accessible` 没有 `disabled` / `defaultAction` / `ignoresAutomaticName`**：禁用态唯一有效途径是
    `Item.enabled: false`（实测 `QAccessible` 接口随之 `state().disabled = true`）；另：
    `Keys.onEndPressed` 在 Qt 6.12 **不存在**，End 走 `Keys.onPressed` + `Qt.Key_End`（0.16.0 沉淀）
40. **QML `color` 的 r/g/b 是 0~1 浮点**：把 color 值当 0~255 处理会让对比度恒等于 1.0
    （`NovaUtils.colors.luminosity` 旧实现即踩此坑，0.16.0 已修 + `_channels255` 归一化）
41. **`QTest` 键位测试必须同时强引用 `QQmlComponent`**：`component.create()` 出的 Window 所有权属于
    组件，组件被 GC 后窗口立即析构（*Internal C++ object already deleted*）（0.16.0 沉淀）
42. **多个 `QQmlEngine` 各自析构在 Qt 6.12 会间歇 SIGSEGV**（A 销毁后 B 再建组件 20~60% 概率崩，
    与用例无关）→ QML 测试全进程共用单引擎（`tests/conftest.py`），模块收尾只 close 窗口不删引擎；
    Window 活到解释器退出而 app 已析构是第二类退出期崩溃，靠 session 收尾规避（0.16.0 沉淀）
43. **Qt 6.12 的 `Qt.formatDate` 三参重载实际不存在**：`Qt.formatDate(date, localeName, pattern)`
    被解析为 `(date, locale)` 两参版、pattern 静默丢弃 → 自定义 pattern + 自定义 locale 必须走
    **`Qt.locale(name).toString(date, pattern)`**（本地化字段齐全，NovaI18n.formatDate 即此实现，
    0.16.1 沉淀）
44. **`QQmlExpression` + `creationContext` 对非 Item 对象间歇 SIGSEGV**：用组件的 creationContext
    求值含单例名的表达式，对象非 Item 时崩溃概率高 → 统一「**QML 内定义 helper 函数/只读属性 +
    Python 直调/直读**」模式，Python 侧不构造表达式（0.16.1 沉淀）
45. **Tab 键在 QML Keys 层拦不到**：Tab 在 `QQuickItem::keyPressEvent` 的 C++ 默认实现中被消费，
    不冒泡（`Keys.BeforeItem` 也拦不到）→ **应用级事件过滤器**（`QGuiApplication.installEventFilter`
    拦 KeyPress+Tab/Backtab，DialogShell 焦点陷阱方案）。
    同批沉淀：PySide slot 的 QObject 参数 wrapper 是**临时的**（weakref 立即失效，注册表须强引用）；
    wrapper 静态类型 QObject（QQuickItem 方法不可见，判定逻辑移 QML 内）；
    `win.property("activeFocusItem")` 的 QQuickItem* 无 converter；
    **`Item.window` 普通属性在 JS 层返回 undefined** → 必须用 attached **`Item.Window.window`**
    （0.16.1 沉淀）
50. **`qmllint` 诊断全部走 stderr**（stdout 只剩源码片段）：`capture_output=True` 只读 stdout
    会得到「0 warning」的假绿灯——预算门禁必须 `stderr=subprocess.STDOUT` 合并两股流
    （1.0.0rc1 沉淀；同批：该版本对 block-scope var 告警**不带 `[category]` 尾缀**，按消息归类）
51. **模块限定类型名不能 `split(".", 1)`**：`Nova.Behaviors.NovaMorph` 会切成
    `Behaviors.NovaMorph`（模块名自身带点）→ 一律 `rsplit(".", 1)`；qmldir 的
    `singleton <名> <版本> <文件>` 版本位比普通行右移一格，解析要按 `singleton` 前缀偏移
    （1.0.0rc1 沉淀；两处都曾让冻结清单/文档表格悄悄写错名字）
52. **`check_qmllint.py` 在中文 Windows 交付机假红灯**：① PySide6 包内是 `qmllint.exe`，
    `Path.exists()` 不补后缀且 Scripts/ 无 `pyside6-qmllint` 入口 → 显式列 `qmllint`/`qmllint.exe`
    两种候选；② `subprocess.run(text=True)` 走 locale 默认编码（中文 Windows=GBK），诊断含
    UTF-8 路径时解码崩 → 显式 `encoding="utf-8", errors="replace"`。两者都让门禁"环境问题"
    与"产品问题"混淆——**门禁红灯先分清是工具/环境还是产品，勿据假红灯判产品缺陷**
    （1.0.0rc1 交付后验收实战沉淀；修复后真实退出码 0）
49. **全矩阵视觉长跑后解释器收尾期 GC 崩溃**：240 截图 × 150s 跑完 pytest 报告后，
    finalizing GC 触发 `none_dealloc: refcount error in a C extension`
    （deleteLater / 显式 close / gc.collect 均无效）→ conftest `pytest_unconfigure`
    硬退出（`os._exit(0)`，报告输出已完成，保 CI 退出码语义）（0.16.2 沉淀）
    **【2026-11-25 21:47 CSA 指令结案归档：议题结案、非交付完成】**：`-k` 子集在 `form_env._pump()`
    亦复现；诊断定位 `runner.py:150 item.funcargs = None` 后 shiboken refcount / 堆损坏
    （`0xc0000374` / access violation）；14 类工程修复全部无效，独立进程 8/8 稳定。
    **未交付代码修复**；真正修复需 CSA 拍板隔离验证 PySide6 降级（6.11.3 / 6.10.3）
    或改测试架构为分批独立进程。产品 QML / 已推送 `5c94186` / 已发布 1.0.0 包不受影响，
    试验改动已全部回退、工作树干净。详见 `CHANGELOG.md` [Unreleased] 与工作区日志 21:45 / 21:47 段。
46. **QML 函数从 Python wrapper 调用返回未求值 MetaFunction**：`host.someFunc()` 拿到的是
    MetaFunction 对象而非结果 → 承载结果的用 `readonly property int xxx`，Python
    `setProperty`/直读属性（0.16.1 沉淀）
47. **性能测量须两遍法**：首建含 QML 编译冷缓存（同一进程内同类型第二次才是纯实例化成本）；
    NovaDate/NovaEditor 首建 11~15ms 属日历/文档网格固有成本，白名单显式登记（KNOWN_HEAVY），
    不静默放行（0.16.1 沉淀）
48. **`qrc://` 双斜杠 URL 是间歇 SIGSEGV 总根因**：shiboken 把 `qrc://xxx.qml` 解析为带 authority
    的路径，`QQmlComponent.setData(data, QUrl("qrc://…"))` 在干净引擎早期确定性段错误
    （exit 139，独立脚本与 pytest 交错复现，历劫多引擎/import 顺序/NovaTheme 热身等假设全部排除后定位）
    → **全部测试代码统一 `qrc:/` 单斜杠**；纪律：test_smoke 首两个 case 先建 NovaTheme 探针
    （0.16.1 沉淀）
49. **全矩阵视觉长跑后解释器收尾期 GC 崩溃**：240 截图 × 150s 跑完 pytest 报告后，
    finalizing GC 触发 `none_dealloc: refcount error in a C extension`
    （deleteLater / 显式 close / gc.collect 均无效）→ conftest `pytest_unconfigure`
    硬退出（`os._exit(0)`，报告输出已完成，保 CI 退出码语义）（0.16.2 沉淀）
    **【2026-11-25 21:47 CSA 指令结案归档：议题结案、非交付完成】**：`-k` 子集在 `form_env._pump()`
    亦复现；诊断定位 `runner.py:150 item.funcargs = None` 后 shiboken refcount / 堆损坏
    （`0xc0000374` / access violation）；14 类工程修复全部无效，独立进程 8/8 稳定。
    **未交付代码修复**；真正修复需 CSA 拍板隔离验证 PySide6 降级（6.11.3 / 6.10.3）
    或改测试架构为分批独立进程。产品 QML / 已推送 `5c94186` / 已发布 1.0.0 包不受影响，
    试验改动已全部回退、工作树干净。详见 `CHANGELOG.md` [Unreleased] 与工作区日志 21:45 / 21:47 段。
37. QML `Component.onCompleted` 按**创建完成逆序**执行（声明序最后的先 complete）——
    组内"首个完成注册者成为默认活动元素"通常是声明序最后的成员；依赖顺序的注册表
    语义须按此口径设计并写进测试（0.15.0 沉淀）
- ~~Sprint 2 L4 服务~~ ✅ 0.6.0~0.6.2（Notify 29 项/Dialog 27 项/Loading 11 项对账 + Storage/App/Platform；L4 44%）
- ~~Sprint 3 L3 行为~~ ✅ 0.7.0（九件一次收口；L3 100%）
- ~~Sprint 4 L0/L5 基础层~~ ✅ **0.8.0 收口（Nova.Design 三单例 + NovaText/NovaTransition；
  14 套图标集 + provider 注册表 + 八通道解析；colors 12 + date 21（44 token）+ format 6 + is 5 +
  debounce/throttle/uid；动效 15 预设；排版 12 级；画廊 15 页；149 项测试；L0 100%/L5 95%）**
- ~~二期 Sprint A 表单核心~~ ✅ 0.9.0；~~二期 Sprint B 输入进阶~~ ✅ **0.10.0（NovaRange/NovaDate
  自研日历/NovaTime 时钟面盘/NovaColorPicker 色域盘/NovaOptionGroup/NovaForm/NovaBtnToggle/
  NovaPopupEdit 八件；L2 16%→24%；画廊 17 页；199 项测试）**
- ~~二期 Sprint A 表单核心~~ ✅ 0.9.0；~~二期 Sprint B 输入进阶~~ ✅ 0.10.0（八件；L2 16%→24%）
- ~~三期 Sprint A 数据体系~~ ✅ **0.11.0（NovaTable+Th/Td/Tr / NovaTree / NovaPagination /
  NovaList·NovaItem(+Section/Label) / NovaMarkupTable / NovaInfiniteScroll / NovaVirtualScroll /
  NovaScrollArea 九件 14 类型；L2 24%→34%；画廊 18 页；225 项测试）**
- ~~三期 Sprint B 媒体体系~~ ✅ **0.12.0（NovaImg/NovaResponsive/NovaVideo/NovaParallax/
  NovaCarousel+Slide+Control/NovaTimeline+Entry/NovaChatMessage 十类型 + NovaTable 增强
  虚拟滚动/服务端模式/loading；L2 34%→43%；画廊 19 页；250 项测试）**
- ~~四期 A 导航体系~~ ✅ **0.13.0（NovaTabs/Tab/TabPanel/TabPanels + NovaBreadcrumbs/El +
  NovaStepper/Step/StepperNavigation + NovaExpansionItem + NovaToolbar/Title +
  NovaFab/FabAction 14 类型；L2 43%→54%；画廊 20 页；271 项测试；基线复核 2.35.6 零漂移）**
- ~~四期 B 弹层与反馈~~ ✅ **0.14.0（NovaMenu/DialogShell/PopupProxy/Tooltip/BottomSheet +
  Spinner×8/Skeleton/InnerLoading/AjaxBar+LoadingBar 服务/Banner/Bar/NoSsr/PullToRefresh/
  ResizeObserver；L2 54%→68%；画廊 21 页；308 项测试；ScrollObserver 规划核对不重复）**
- ~~五期 A 长尾组件~~ ✅ **0.15.0（NovaEditor 轻量富文本（标记编辑+HTML 导出同语义留痕）/
  NovaSlideItem 左右滑动面板/NovaMorph group 形变 + NovaMorphPool 单例/NovaIconGenie CLI
  37 产物/AI-ready 文档包 + Nova MCP server 六工具；L2 68%→70%、L3 Morph 补齐、L6 70%→75%；
  画廊 22 页；322 项测试；坑位 36~37 沉淀）**
- **五期 B2（下一步）国际化 + 性能（v0.16.1）** ✅ **0.16.1 收口（NovaI18n 单例 + RTL 双轨镜像
  6 组件 + 性能门禁三指标（冷启动 ≤800ms / 组件 ≤5ms / 1000 行表格 ≤1700ms）+ HiDPI 1.0~2.0 矩阵；
  a11y M2 补差：Tree 方向键游标、Dialog 焦点陷阱（NVDA 真机回归移 B3）；画廊 23 页；394 项测试；
  坑位 43~48 沉淀，其中 48（qrc:// 双斜杠段错误）为间歇崩溃总根因）**
- ~~五期 B3 工程化外环（v0.16.2）~~ ✅ **0.16.2 收口（视觉回归 240 基线 + 外部输入消毒 32 项
  + SBOM/CVE 周巡 + PyInstaller 打包自检 + MkDocs 文档站可搜索；画廊预览页 = 在线示例等价；
  L6 80%→90%；427 项测试；坑位 49 沉淀）**——**五期全部完成**
- **六期（下一步）封版 1.0.0-flagship**：~~RC1 API 冻结审查~~ ✅ 1.0.0rc1 →
  **RC2 24 条封版验收清单全勾**（ECOSYSTEM_PARITY 第 6 节；24h 压测工具就绪+冒烟通过（全量长跑留 CI），
  余项 3 条：NVDA 真机 / 安装器签名 / 迁移指南 + LTS）→ 1.0.0 正式封版
- 详细差距与 DoD：`docs/ECOSYSTEM_PARITY.md`

## 最近一次交付

- **1.0.0rc1：六期 RC1 收口 · API 冻结审查**
  （124 类型逐成员签名快照 `api/nova-api-1.0.0.json` + 签署件 `docs/API_FREEZE.md`；
  新增门禁 `check_api_freeze.py`（三桶 + 指纹自洽）与 `check_qmllint.py`（0 error + 593
  warning 分类预算）；local_deploy 交付前三门禁串跑；冻结审查修掉 3 处真实缺陷
  （ColorPicker 幽灵令牌/无主 tint、NovaText.style 覆盖 Text.style）；
  废弃机制 NovaUtils.logOnce·deprecate；测试 427→454；坑位 50~51）

- **0.16.2：五期 Sprint B3 收口 · 工程化外环一次交付**
  （视觉回归门禁 240 基线明暗 × 5 断点 + 外部输入消毒 NovaUtils.sanitize/runtime Slot/
  textFormat 加固 9 处 + CycloneDX SBOM + OSV CVE 周巡 + build_app.py 打包自检 +
  MkDocs 可搜索文档站 + 画廊在线预览页；测试 394→427；坑位 49 沉淀）

- **0.16.1：五期 Sprint B2 收口 · i18n + RTL + 性能 + HiDPI 一次交付**
  （NovaI18n 服务单例（locale 切换/t() 三级回落/tp() CLDR 七语系复数/formatNumber·Currency·
  Date·Relative/addBundle 热注入）+ RTL 双轨镜像（Pagination/Drawer/Layout/SlideItem/
  Breadcrumbs/StepperNavigation，逻辑侧语义恒定）+ 性能门禁 test_perf.py 三指标 + HiDPI 门禁
  test_hidpi.py 矩阵 + a11y 补差（Tree roving cursor / DialogShell 焦点陷阱）+ docs/I18N.md +
  画廊第 24 页；测试 343→394；类型 123→124）
- **0.15.0：五期 Sprint A 收口 · 长尾组件一次交付**
  （NovaEditor 轻量富文本（toolbar 分组/execCmd 命令族/toHtml 导出/受控 guard）+
  NovaSlideItem 左右滑动动作面板 + NovaMorph 元素形变（ghost 几何过渡）+ NovaMorphPool
  singleton 注册表 + NovaIconGenie 图标全套 CLI + AI-ready 版本化 API 文档包 +
  Nova MCP server 六工具；画廊第 22 页；测试 322 项；类型 117→120）
- **0.14.0：四期 Sprint B 收口 · 弹层与反馈一次交付**
  （NovaMenu + NovaDialogShell 关闭原因上报 + NovaPopupProxy 断点路由 + NovaTooltip +
  NovaBottomSheet + NovaSpinner 八变体 + NovaSkeleton/NovaInnerLoading/NovaAjaxBar/
  NovaLoadingBar 服务/NovaBanner/NovaBar/NovaNoSsr/NovaPullToRefresh 四边拉动/
  NovaResizeObserver；画廊第 21 页；测试 308 项；L2 54%→68%；类型 100→117）
- **0.13.0：四期 Sprint A 收口 · 导航体系 14 类型一次交付**
  （NovaTabs/Tab/TabPanel/TabPanels 受控标签页族 + NovaBreadcrumbs/El + NovaStepper/Step/
  StepperNavigation 状态图标 1:1 解析 + NovaExpansionItem group 手风琴 + NovaToolbar/Title +
  NovaFab/FabAction stagger 级联 + hover 契约；画廊第 20 页；测试 271 项；L2 43%→54%）
- **0.12.0：三期 Sprint B 收口 · 媒体体系十类型 + Table 增强一次交付**
  （NovaImg 三态占位/ratio + NovaResponsive 等比 + NovaVideo 惰性播放器 + NovaParallax 视差 +
  NovaCarousel 受控全家桶（arrows/navigation/autoplay/infinite/swipeable/覆盖控件）+
  NovaTimeline 三布局 + NovaChatMessage 收发气泡 + NovaTable 虚拟滚动/服务端模式/loading；
  画廊第 19 页；测试 250 项；L2 34%→43%）
- **0.11.0：三期 Sprint A 收口 · 数据体系九件 14 类型一次交付**
  （NovaTable 排序/过滤/分页/多选/展开行 + NovaTree strict 级联/懒加载/过滤 +
  NovaPagination + NovaList 手风琴四件 + NovaMarkupTable + NovaInfiniteScroll +
  NovaVirtualScroll 5000 行虚拟化 + NovaScrollArea；画廊第 18 页；测试 225 项；L2 24%→34%）
- 0.10.0：二期 Sprint B 收口 · 输入进阶八件一次交付（自研日历/时钟面盘/取色器落地）
  （NovaRange 双值约束 + NovaDate 三模式 mask 日历 + NovaTime 三面时钟 + NovaColorPicker
  SV 色域盘 + NovaOptionGroup 三型 + NovaForm 聚合校验 + NovaBtnToggle + NovaPopupEdit
  + 画廊第 17 页 + 测试 199 项；L2 16%→24%）
- 0.9.0：二期 Sprint A · 表单核心七件（统一契约 + 校验引擎；画廊 16 页；174 项测试）
- 0.8.0：Sprint 4 收口 · L0 设计语言 + L5 工具层一次交付（一期生态骨架完工）**
  （NovaIconSet 14 套图标集/100 语义键/provider 注册表/八通道解析 + NovaMotion 动效令牌 15 预设
  + NovaUtils colors 12·date 21·format 6·is 5·debounce/throttle/uid/extend + NovaText 排版 12 级
  + NovaTransition 过渡组件 + NovaTheme 排版/高程令牌 + NovaIcon 升级三通道 + 画廊 14/15 页
  + 测试 149 项；L0 60%→100%、L5 0%→95%；新增 Nova.Design 模块）
- 0.7.0：Sprint 3 收口 · L3 行为层九件一次交付（Intersection/ScrollObserver/ScrollFire/
  ClosePopup/TouchPan·Swipe·Hold·Repeat + NovaIntersectionPool 共享观察池 + NovaOverlayHost
  弹层栈 + 画廊第 13 页 + 114 项测试；L3 11% → 100%）
- 0.6.2：Sprint 2 收口 · 一次交付四件（NovaLoading 11 项对账 + 引用计数 / NovaStorage 真落盘 /
  NovaApp / NovaPlatform + NovaRuntime Python 后端 + 画廊第 12 页 + 91 项测试 + 交付节奏条款）
- 0.6.1：Sprint 2 第二件 NovaDialog（27 项对账 + 句柄三信号 + 画廊对话框页 + 71 项测试）
- 0.6.0：Sprint 2 首件 NovaNotify + NovaOverlayHost（29 项对账 + 63 项测试）
- **0.5.0：一期 Sprint 1 · L1 布局系统**（布局五件套 + 栅格三件套 + 画廊布局页 + 46 项测试）
- 0.4.2：**基线纠正 2.26.0 → 2.35.5** + 增量审计（AI-ready/MCP 入 L6、关闭原因上报/hover 契约/stagger/side 入 DoD）
- 0.4.1：**全生态开发总规划**（六期战略 + 全量对账表 + 冒烟测试七条纪律）
- 0.4.0：生态对标白皮书（七层模型 + 12 项 P0 空白 + 24 条封版验收）+ 宪法第 10 章 + M1 范围重排
- 0.3.4：PROMPT 单文件自包含（快照全文内联 + 内容指纹校验），告别"翻 4 个文件"
- 0.3.3：交付包完整性加固（ZIP 含 PROMPT + .git 历史 + BUILD_INFO + SHA256）
- 0.3.2：快照/提示词双模板 + gen_prompt.py 生成器

## 交付物通道

- 门禁：`check_a11y.py` → `check_api_freeze.py` → `check_qmllint.py`（local_deploy 第 0 步，红即拒包）
- **一键总验收 `scripts/check_all.py`**（库管员+验收员入口，分层，统一退出码 0 全绿/1 产品红或工具 ERROR/2 未执行门禁）：
  `--tier static`（默认，秒级三静态门禁）· `--tier dynamic`（perf/visual smoke/soak 冒烟/hidpi）·
  `--tier supply`（cve）· `--tier all`（全部 8 道；封版加 `--soak-24 --visual-full --cve-online`）；
  `--brief` 摘要、`--report PATH` 落 JSON。内置环境预检：无 PySide6 的解释器直接判 ERROR(码2)，
  不把"环境问题"误报成产品红。子门禁与总入口共用 `sys.executable`，必须用
  `miniconda3/envs/pyside6_nova/python.exe` 运行。
- 本地：`python scripts/local_deploy.py --zip --allinone` → release.zip + ALL-IN-ONE.zip
  （--allinone 必须在最终 git 提交之后运行，保证包内历史与 HEAD 一致——0.8.0 教训）
- PyPI：打 `v*` 标签 → GitHub Actions Trusted Publishing 自动发布
