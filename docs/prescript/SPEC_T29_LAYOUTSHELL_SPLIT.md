# T29 · LayoutShell 21 组合根分层迁移法源页

> **文档性质**：本库**现行**法源页（非史料、非方案稿）· T29「`Composite/LayoutShell/` 分层迁移」的唯一裁决与拍板登记入口
> **适用版本**：**1.11.0（本地完成，待 CSA 发布）** · `api/nova-api-1.11.0.json` · **147 类型 / 21 组合根** · 内容指纹 **`9966483dda5a53c4`**
> **立项**：**T29 · 2026-11-28 03:07 · CSA 指令「小诺，T29，先 A 后 B」**
> **配套台账**：[`GUIDE_LAYOUTSHELL_TAXONOMY.md`](GUIDE_LAYOUTSHELL_TAXONOMY.md)（二维分层 / 判别锚 / 集合核算）
> **法源链**：母法 [`CONSTITUTION.md`](../CONSTITUTION.md)（卷首 CARF / 第 8 章版本纪律 / 第 13 章冻结面）→ 组合宪法 [`COMPOSITION_CONSTITUTION.md`](../COMPOSITION_CONSTITUTION.md) 1.0.0（CC-1 唯一组合上下文 / CC-8 参考实现）→ [封版规范 v2.1.0](SPEC_FREEZE.md) → [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md)（§0 三条前提校正 / §1.1 拍平史料 / §6 三层铁律）→ [`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md)（M1 就绪态 / §4 C1~C5 / §5 M2 路线图 / §9 拍板项 / §6 R2）→ [`GUIDE_LAYOUTSHELL_TAXONOMY.md`](GUIDE_LAYOUTSHELL_TAXONOMY.md) → **本页**
> **状态**：**现行 · 2026-11-28 03:2x · T29 完现（A + B）· B 按 1.11.0 minor 落地、待 CSA 发布**

---

## 0. CSA 指令与一句话结论

### 0.1 指令原文（史料不改写）

上一轮评估请求（2026-11-28 03:0x）：

> 「小诺，我想 `LayoutShell/` 下的（为了省事我就不带 `Nova` 前缀了）除 `Agent, AIReport, Chat, Copilot, DE, Desktop, FlexLayout, Incubator, Mobile, Orbit, SetupWizard` 11 个组件之外的其他组件移入 `Composite/` 下，请评估🤝」

本轮立项指令（2026-11-28 03:07）：

> 「**小诺，T29，先 A 后 B**」

### 0.2 一句话结论

> **划分成立、法源有轨道、技术可行，但这是 v2.0 M2 的破坏性物理迁移批次，不是 additive 打磨。按「先 A 后 B」：A 阶段只在文档层建二维台账 + 本页法源（零产品代码、零重签、零版本变动）；B 阶段受控物理迁移须先由 CSA 对版本起点拍板，再按 §4 切换条件逐项落地。**

A 阶段交付物已随本页与 [`GUIDE_LAYOUTSHELL_TAXONOMY.md`](GUIDE_LAYOUTSHELL_TAXONOMY.md) 落地；B 阶段产品代码、`qmldir`、URI、冻结面在本页登记时**全部零改动**。

### 0.3 三条不可越的底线（依「不将就」信条）

1. **不破坏已发布兼容**：`Nova.Composite.LayoutShell` 单一模块 URI、**21 个类型名**、全库 **180 个 URI 引用文件**、`examples/` 里各 3~5 处 demo 引用**逐字保留**；B 阶段任何批次都 additive、可逆。
2. **宪法铁律不擅自豁免**：工作区长期笔记（`.workbuddy/memory/MEMORY.md`）口径「禁止子目录升格独立 `qmldir` 模块」不因本批次松动；B **不建第 6 个 `qmldir`**、不改 URI，故不触发宪法第 13 章「移模块」豁免。
3. **稳步推进、逐批销号**（CARF / 天花板铁律）：21 个组合根只迁 10 个，不批量扫荡；A / B 分阶段验收，禁止跨阶段夹带；已发布物（1.10.0 冻结面、1.9.0 及更早史料）零回改。

> **发布权边界**：`commit / push / tag / PyPI / 站点上线` 一律归 CSA；小诺只做实现 / 自检 / 验收 / 文档 / 账本，不代发布、不代定 major 版本号。

---

## 1. 三档路径与选定结果

上一轮评估给出三档，本轮 CSA 以「先 A 后 B」选定：

| 档 | 内容 | 破坏性 | 本轮状态 |
|---|---|---|---|
| **A** | 文档层建「通用原语 / 产品级根」二维台账 + 法源页；mkdocs nav 登记；账本记立项 | **零**（不动产品代码 / URI / 冻结面 / 版本） | ✅ **已落地**（本页 + [`GUIDE_LAYOUTSHELL_TAXONOMY.md`](GUIDE_LAYOUTSHELL_TAXONOMY.md)） |
| **B** | 受控物理迁移：10 个 QML 移入 `Composite/`，`LayoutShell/qmldir` 以 `../` 转发，URI 与 `import` 全不变；必重签、切契约、修 a11y 硬编码、真机验 `../` | **中**（`types[].file` 变化 → 重签；切 C1~C5；打破 12:05 平铺约定） | ⏳ **待 CSA 对版本起点拍板后执行** |
| **C** | 升格独立模块（如 `Nova.Composite`）→ 真正 breaking | **高**（major 2.0.0 + 兼容视图 + 全库回扫 + RFC） | ❌ **不采纳**（用户明确「移入 `Composite/`」是物理目录，`B` 定义即 URI 不变） |

> **C 为何排除**：[`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) §9 拍板项 2「是否全量废除 `Composite` / 改模块 URI」须 CSA **单独一句话**拍板，且明确「**未拍板前 M2 只在既有 URI 下做物理迁移**」。本轮指令未提改 URI，故 B 严格落在「既有 URI 下物理迁移」，不触碰 §9 第 2 项。

---

## 2. A 阶段验收口径（零重签）

| 项 | 期望 | 本轮实测 |
|---|---|---|
| 产品代码 QML | 21 个文件零改动 | ✅ 零改动 |
| `qmldir` | 21 条导出行零改动 | ✅ 零改动 |
| 模块 URI / 类型名 / 公共面 | 全部不变 | ✅ 不变 |
| `api/nova-api-1.10.0.json` / `api/component-domains-1.10.0.json` | 零回改 | ✅ 零回改 |
| `src/pyside_nova/__about__.py` / 徽标 / CHANGELOG 版本行 | 零变动（仍 **1.10.0**） | ✅ 零变动 |
| 新增手写文件 | 2 份 prescript md + `mkdocs.yml` nav 2 条 | ✅ |
| 内容指纹 | 仍 `5328cd0e3c71e7ac` | ✅ |
| 门禁 | 静态 3/3 · 专项 · 天花板 21/21 · foundations 15/15 · `mkdocs --strict` EXIT=0 · 三 `--check` · 生成器幂等 | 见 §7 复核 |

> A 阶段**不升版本、不重签**：新增的是文档层法源与台账，不进 `fingerprint()` 的 surface（该函数对含 `types[].file` 的冻结面做 canonical JSON 哈希），故公共面零漂移。

---

## 3. B 阶段前置：CSA 拍板项登记（小诺不代为决定）

上一轮评估列出三项，本轮「先 A 后 B」已隐含回答第 ① 项；**② ③ 仍待拍板**，逐项如实登记：

| # | 拍板项 | 状态 | 说明 |
|---|---|---|---|
| ① | 是否打破 12:05「九类子目录拍平 / 物理层回归平铺」约定 | ✅ **已由「后 B」隐含授权** | B 把 10 个文件移入 `Composite/`（上一级）会重新引入物理分层；但不建第 6 个 `qmldir`、不改 URI，故不违反「物理目录 ≠ 模块 URI」铁律本身，仅与平铺美术约定冲突。冲突登记见 §5。 |
| ② | **版本起点**：只重签指纹走 **1.11.0 minor**，还是按 [`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) §5 走 **2.0.0 major** | ⏳ **待 CSA 一句话拍板** | **本页最关键分叉**，法源冲突见 §3.1。定档前不擅自升版本、不擅自搬 QML、不擅自建视图（§0.3 底线 3 / 发布权）。 |
| ③ | 是否同批落首个 `@nova-compat-view` 兼容视图 | ⏳ **待 CSA 一句话拍板 · 建议「不落」** | B 定义是 URI 与 `import` 全不变，**不需要**视图来保兼容；落了反而触发 C2/C3 从「0 视图」切到「视图态」，扩大破坏面。[`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) §9 第 3 项亦注明「当前影响面 = 0」。 |

### 3.1 版本起点的法源冲突（必须 CSA 裁定）

| 依据 | 主张 |
|---|---|
| [`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) §5 路线图 / §113 第 9.1 条 | M2 = **additive major 重签 `2.0.0`**；「M2 迁移才升 2.0.0 重签」 |
| 同页 §9 拍板项 1 | 「1.2.0 是否单独发布 / 2.0.0 是否直接接续」——**已过时**：1.2.0 早已发布，版本链已推进到 **1.10.0 已发布** |
| 同页 §4 C1 / §116 | 「搬动任何 QML 都会改变指纹」，但「归一化 `file` 后指纹反推还原」可证明**逐成员零漂移** |
| 本轮 B 的实际破坏程度 | URI 不变 · `import` 不变 · **147 类型公共面零变化** · 仅 10 个 `types[].file` 溯源字段受控变化 → 比 §5 描述的 M2（含首个兼容视图 + URI 重构）**轻得多** |
| 宪法第 8 章 / 工作区冻结纪律 | 「additive 公共类型升 minor 重签；patch 只改包版本」；纯物理重构不新增公共成员、不改 URI，按字面既非 additive minor 也非 breaking |

**结论**：存在「按法源字面走 **2.0.0 major**」与「按实际破坏程度走 **1.11.0 minor**（仅重签指纹）」两条合法路径，且二者对 CHANGELOG / 徽标 / 冻结清单命名 / 六处账本 / 兼容视图契约的影响完全不同。此属**发布版本号决定权**，归 CSA；小诺不代为选择，待拍板后按选定档一次性执行，避免返工。

> **账实不符必校准**：无论选哪档，[`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) 第 5 行版本锚点（`1.2.0` / 144 类型 / `4f882374ad52262b`）与 §9 拍板项 1 都须在校准段对齐到现行 **1.10.0 / 147 类型 / `5328cd0e3c71e7ac`**；历史行按「史料不圆场」逐字保留、只追加现行校准段。

---

## 4. B 阶段切换条件与机检契约变更清单（登记，未执行）

> 以下为拍板后的**执行清单**，全部以「URI 与 `import` 全不变、旧公共面逐成员零漂移」为硬约束。规则在此登记，当前不启用。

| # | 动作 | 法源 / 事实依据 | 风险 |
|---|---|---|---|
| B1 | 10 个 QML 从 `Composite/LayoutShell/` 移入 `Composite/`（上一级） | 10 个 QML 正文相对路径 `import` **0 处**、被 11 个保留组件引用 **0 处** → 内部零耦合 | 低 |
| B2 | `LayoutShell/qmldir` 对应 10 条改为 `../NovaXxx.qml` 转发；**不建第 6 个 `qmldir`** | [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §1 铁律「物理目录形态 + `qmldir` 路径导出 ≠ 模块 URI 变更」 | **R2 已排险（T29-A 实测）**：产品树 `../` 零先例，但 `spike_v2_compat.py` 形态 C/H 与 B 精确形态 A/B 对照探针均 PASS（同一 URI / 同一物理实现 / 非包装）；B 阶段仍需对**真实 21 组件**做离屏真机回归 |
| B3 | `check_a11y.py` TABLE 键 `Composite/LayoutShell` 路径映射校准 | 现按层扫 `QML_ROOT / layer / file_name`；`../` 拼接可解析但须实测 a11y **147/147** 不漏登记 | 中 |
| B4 | `audit_v2_compat.py` C1 `expect = f"Nova/{layer}/{file}"` 改为 `normpath` 归一化后比对 | [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §1.1 与 [`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) §116「归一化 `file` 后指纹反推还原」——**法源已给现成解法** | 中 |
| B5 | 按 [`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) §4「M2 切换条件」把 C1~C5 从就绪态切到迁移态 | 就绪态 C1 硬约束「`file` 物理路径零变化」与物理迁移**天然互斥** | 中（须同步 `test_v2_compat.py` 断言） |
| B6 | 校准 `SPEC_V2_COMPAT.md` 版本锚点与 §9 拍板项 1 | §3.1 账实脱节 | 低 |
| B7 | `gen_api_freeze.py` 重签（版本号按 §3 拍板档）、CHANGELOG / 徽标 / 六处账本 / 生成器链 / 三态图引用同步 | `fingerprint()` 含 `types[].file`，搬 QML **必重签** | 低（生成器链成熟） |
| B8 | **逐成员零漂移证明**：旧 147 类型 `props/signals/methods` 逐项零丢失，唯一变化为 10 个 `file` 溯源字段；归一化后指纹反推还原 | 宪法第 13 章 / [`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) §116 | 必须项 |
| B9 | 六维验收 + 离屏真机全 URI 实例化回归 + 已发布 `import` 回归 | §7 / 天花板铁律 | 必须项 |

> **禁止事项**：不得为「让 C1 通过」而复制 / 包装 QML（[`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) §4 spike D 已证包装会改身份）；不得新建任何带 `.qml` 的视图目录；不得更改 21 个类型名与 `import` 用法。

---

## 5. 冲突登记（史料不圆场）

| # | 冲突对象 | 现行文字 / 事实 | 本页处置 |
|---|---|---|---|
| 1 | 12:05 平铺约定 | `qmldir` 头注释：「**不再落物理子目录**……物理层回归平铺、老用户路径零漂移」；[`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §0 落点段 | B 重新引入物理分层，**与美术约定冲突**；已由「后 B」授权，如实登记、不圆场成「从未冲突」 |
| 2 | 1.2.0 九类物理子目录史料 | 06:55 授权按九类移入子目录（指纹 `68b34a408489b6a8`）、12:05 拍平重签（`4f882374ad52262b`） | 逐字保留于原历史行；本批次是**第三种物理形态**（部分上移一级），不回填、不改史料 |
| 3 | `SPEC_V2_COMPAT.md` 版本锚点 | 仍写 `1.2.0 / 144 类型 / 4f882374ad52262b / 2.0.0` | §3.1 已列为 B6 校准项；A 阶段**不改**（零重签纪律），B 阶段追加现行校准段 |
| 4 | 1.10.0 已发布冻结面 | `api/nova-api-1.10.0.json` / `component-domains-1.10.0.json` / 徽标 / CHANGELOG 均在发布提交 `1fb87d9` 内 | **零回改**；B 重签产出新版本清单，不覆盖已发布物 |
| 5 | 任务编号 | T28 已销号、下一编号 T29 | T29 本轮立项占用；A 完成 / B 待拍板；销号后下一个 **T30** |

---

## 6. CARF 映射

| 维度 | 本页落点 |
|---|---|
| **构想** | T29 二维分层判别锚（`hsvHue`）、A/B/C 三档路径裁定 |
| **实现** | A 阶段两份 prescript md + nav 登记（零产品代码）；B 阶段按 §4 九项清单执行 |
| **打磨** | §3 拍板项如实登记、§4 契约变更逐项法源化、§5 冲突不圆场 |
| **封版** | §2 A 阶段零重签验收 + §7 复核；B 阶段完成后另立现行校准段 |
| 四性 | **Robustness** 判别锚零例外可机检 · **Solidity** 三层铁律不冲突 · **Aesthetics** 十色相身份色守恒 · **Prescience** M2 切换条件与归一化反推法预先登记 |

---

## 7. A 阶段复核与交付

A 阶段在 1.10.0 已发布基线上叠加，复核项：静态 3/3 · 专项测试全集 122 passed · 天花板 21/21（619 条链接 0 断链）· foundations 15/15 · 域分类 / v2 compat M1 就绪态 PASS · `mkdocs --strict` EXIT=0 · 三 `--check` 全绿 · 生成器幂等 210 文件哈希一致（排除含分钟级时间戳的 `pyside-nova/PROMPT.md`）。

**B 技术前提实测（T29-A 附带，只读临时 import path、不动产品目录）**：`spike_v2_compat.py` **7/7 PASS**（形态 C `../` 跨目录转发 / H `../../` 到新顶层目录均拿同一物理实现）；另以 **B 精确形态 A/B 对照探针**验证「既有 URI `Nova.Composite.LayoutShell` 不变 + QML 在父目录 `Composite/` + `qmldir` 写 `../NovaSidebar.qml`」与平铺基线两组均 `Ready` · tag 同为 `REAL` · 非包装。据此 **R2 从「未验证假设」降级为「真机回归项」**，B 阶段仍须对真实 21 组件做离屏真机回归。

**交付口径**：**T29-A 完现 · 零产品代码改动 / 零 URI 变化 / 零重签 / 零版本变动**；T29-B 待 CSA 对 §3 ②（版本起点）与 ③（兼容视图）一句话拍板后按 §4 执行；发布动作全归 CSA。

---

## 8. 封版声明

**本页为 T29「LayoutShell 21 组合根分层迁移」的现行法源：划分成立、判别锚可机检、A 阶段零重签落地、B 阶段破坏性迁移待 CSA 拍板。九类管语义、二维管分层、物理层待授权、URI 恒单一、已发布物零回改。**

> **身份色定归属，文档层先落地；版本归 CSA，迁移逐批销号。**

## 9. 🆕 T29-B 落地结果（2026-11-28 · 现行，覆盖上方 §3 拍板项的「待拍板」表述）

> 上方 §3 的「② ③ 待 CSA 拍板」是 **A 阶段时点事实**，按「史料不圆场」逐字保留；本段是现行口径。

| 拍板项 | CSA 裁定（03:20） |
|---|---|
| ② 版本起点 | **1.11.0 minor（仅重签指纹）**，`api/nova-api-1.11.0.json`；不升 2.0.0 major |
| ③ 兼容视图 | **不落**，C2/C3 保持 0 视图就绪态 |
| ① 平铺约定 | 由「后 B」隐含授权，已按 §5 冲突登记如实处理 |

- **§4 九项清单执行结果**：B1/B2 已落地；**B3（a11y 路径）无需改动**（`../` 拼接被 `Path.exists()` 天然解析，实测 147/147）；
  **B4（C1 归一化）无需改动**（C1 的 `expect = Nova/{layer}/{file}` 与生成器 `file = Nova/{layer}/{t['file']}` 同源，
  新清单下天然 PASS，实测 C1~C5 全绿）；B5 保持 M1 就绪态（因不落视图，C2/C3 无需切换）；
  B6 已在本页与 `SPEC_V2_COMPAT.md` 追加现行校准段；B7 已重签；B8/B9 已完成。
- **零漂移证明**：`tests/test_t29_migration.py::test_normalized_reverse_restores_old_fingerprint`
  把 10 个 `file` 改回旧值后指纹精确还原 `5328cd0e3c71e7ac`；新指纹 `9966483dda5a53c4`。
- **真机**：`spike_v2_compat.py` 7/7 + B 精确形态探针 PASS；`audit_foundations.py` 15/15 · 130 类型实例化零缺陷。
- **状态**：**T29 完现销号 · 1.11.0 本地完成待 CSA 发布**；下一个 **T30**，待办池仍 1 项 = **T3**。

---