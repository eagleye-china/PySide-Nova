# pyside-nova v2.0 物理重构立项书 · 双轨兼容规范

> **文档性质**：本库**现行**法源级立项书 / 架构规范（RFC + 兼容层契约 + 分批迁移路线图），非史料、非外部建议稿
> **状态**：**已立项 · M1 就绪态 · 2026-11-26**（CSA 10:09 拍板立项；10:44 指令撤回首个物理 pilot，M1 回退为「零物理视图」就绪态；**11:22 CSA 拍板「`LayoutShell` 不改名」→ §9 第 4 项命名议题结案，URI 与术语三层维持现状**；12:05 CSA 拍板九类子目录拍平、物理层回归平铺、冻结面重签）· 后续批次待 CSA 定发布衔接后逐批推进
> **版本锚点**：当前包 `__about__.py` = **`1.2.0`**（兼容基线，待 CSA 发布）· 冻结清单 `api/nova-api-1.2.0.json` · **144 类型 / 5 冻结面模块** · 指纹 **`4f882374ad52262b`**（12:05 物理拍平重签）· 目标版本 **2.0.0（additive major，M2 重签）**
> **法源链**：母法 [`CONSTITUTION.md`](../CONSTITUTION.md)（卷首 CARF + 不将就 · 第 9 章版本与交付纪律 · 第 13 章 API 冻结与废弃政策）→ 组合宪法 [`COMPOSITION_CONSTITUTION.md`](../COMPOSITION_CONSTITUTION.md)（CC-1~CC-8）→ [封版规范 v2.1.0](SPEC_FREEZE.md) → [`GUIDE_QUASAR_ALIGNMENT.md`](GUIDE_QUASAR_ALIGNMENT.md) §5（四条前置条件）· [`GUIDE_COMPONENT_DOMAINS.md`](GUIDE_COMPONENT_DOMAINS.md) §0.1/§6.4 · [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §6（三处同源、不重复立项）→ **本立项书**
> **前身裁定**：外部建议稿《企业级旗舰版 QML 架构封版方案（FINAL）》的「废除 `Composite` / 9 大顶层目录 / 每子目录独立 `qmldir` / `view` 字符串」原判「未采纳、待 CSA 单独拍板」，原文逐字存档于 `GUIDE_QUASAR_ALIGNMENT.md` 附录 A。**CSA 已于 2026-11-26 10:09 明确拍板「先做 v2.0 物理重构，立项和兼容层一起」**，本立项书即该拍板的法源落地。
> **发布边界**：全部改动留工作树未提交，`commit / push / tag / PyPI / 站点上线` **全归 CSA**。

---

## 0. 立项依据与一句话结论

### 0.1 CSA 指令（2026-11-26 10:09 / 10:44）

> 10:09 「先做 v2.0 物理重构，立项和兼容层一起」
> 10:44 「在 `Controls/` 就新建了个 `Foundation`？去掉吧！……再没有创建类似 `Foundation` 的目录了吧？」

对照 `GUIDE_QUASAR_ALIGNMENT.md §5` 与两份同源指南列出的**四条前置条件**：

| # | 前置条件 | 本立项书对应 |
|---|---|---|
| 1 | additive major + RFC + 新法源 + 全库回扫 | **本立项书 = RFC + 新法源**（§2~§5）；全库回扫结果见 §6 风险登记；重签在 M2 |
| 2 | **兼容层**：保留旧 `import Nova.Composite.LayoutShell 1.0` 等别名 / 转发模块，保证已发布 1.0.0 / 1.0.1 / 1.2.0 用户不破 | **§2 双轨兼容架构 + §4 五条可机检契约 + §1 Qt 七形态实测证据**；M1 为**就绪态、零物理视图**（§0.4 / §2.2） |
| 3 | 冻结面重签 + 零漂移证明，禁止中间态指纹 | **M1 零重签（论证见 §3）**；M2 迁移批次才重签 2.0.0 并逐成员比对 |
| 4 | 全量验收：静态 3/3 · 专项 · 20/20 · 15/15 · 域分类 · mkdocs · 断链 · 生成器幂等 | **§7 M1 验收标准**，全绿方销号 |

### 0.2 一句话结论

> **v2.0 = 物理目录重构 + 双轨兼容**。兼容层的技术形态由 Qt 实测焊死（§1）：「**零新增类型的转发视图**」用 `../` 指向冻结清单里的同一物理文件、导出集合 ⊆ 既有 144 类型，因不改变宪法第 13 章定义的冻结公共面，**M1 不触发重签、零漂移**；真正的「移模块」物理迁移属破坏性、只能随 major 重签，列入 **M2**，逐批销号、不批量扫荡。**M1 当前为就绪态**：契约、实测、守护、测试、生成器全部就位，但依 CSA 10:44 指令**不落地任何物理转发视图**——首个视图与 M2 物理迁移同批落地。

### 0.3 三条不可越的底线（依「不将就」信条）

1. **不破坏已发布兼容**：`1.0.0 / 1.0.1` 已在 PyPI；5 个 `Nova.*` 模块 URI、144 类型名、全部 `import` 用法**逐字保留**，任何批次都 additive、可逆。
2. **宪法铁律不擅自豁免**：`MEMORY.md §6` 明令「禁止子目录升格独立 `qmldir` 模块」；本立项书的兼容视图**不是冻结面模块**（§2.2），不改动 144 类型归属；若 CSA 要全量改 URI / 废除 `Composite`，属宪法第 13 章「移模块」+ CC-1 豁免，须 CSA 再单独一句话拍板（§9）。
3. **稳步推进、不推倒重来、不批量扫荡**（CARF / 天花板铁律）：144 类型全量物理迁移拆成 M2~M3 分批，每批单独验收销号。

### 0.4 M1 就绪态回退记录（2026-11-26 10:44 · CSA 指令 · 史料不圆场）

**事实链如实登记，不圆场、不抹除**：

| 时点 | 动作 | 状态 |
|---|---|---|
| 10:09 | CSA 拍板「立项和兼容层一起」；小诺落地 `SPEC_V2_COMPAT.md` + `Nova/Controls/Foundation/qmldir`（12 类型 `../` 转发 pilot）+ `audit_v2_compat.py` / `spike_v2_compat.py` / `test_v2_compat.py` + `gen_apidocs.py` 跳过标记 | M1 曾「已落地 1 个 pilot」 |
| 10:44 | CSA 指令「`Controls/` 下新建的 `Foundation` 去掉」+ 关切「是否还创建类似目录」 | 明确撤回首个物理 pilot |
| 10:44 后 | **删除** `Nova/Controls/Foundation/`（产品树 qmldir 回到精确 **5 个**）；**清除** `gen_apidocs.py` 的 `@nova-compat-view` 跳过死代码；**重写** `audit_v2_compat.py` / `test_v2_compat.py` 为「就绪态守护」；spike 内临时示意目录 `Foundation/` → 中性 `Sub/` | **M1 就绪态 · 0 物理视图** |
| 11:22 | CSA 拍板「**`LayoutShell` 不改名了**」，指令更新 `PROMPT.md` 转场 | **§9 第 4 项命名议题结案**：`Nova.Composite.LayoutShell` 名称 / URI / 术语三层维持现状、零改动；§9 第 1~3 项待拍板不变 |
| 12:05 | CSA 拍板「`LayoutShell` 九类子目录拍平到父目录」→ **物理层回归平铺**：20 个 QML 上移一层、9 空目录删除、`qmldir` 改逐项平铺，九类分类下沉文档层台账；冻结面重签 `4f882374ad52262b`（旧 `68b34a408489b6a8`，反向归一化 `file` 精确还原 → 公共成员逐字零漂移）；物理路径回到 1.0.x 已发布形态。**V2 兼容契约不变**：仍为 M1 就绪态、0 物理视图、5 qmldir、旧 5 URI 零改动（本次改的是 `Composite/LayoutShell` 内部物理路径，URI / 导出类型名 / `import` 全不变） |

**CSA 关切的核查结论（磁盘实测）**：`Controls/` 下**仅此 1 个**新建子目录；`Behaviors/` `Design/` `Services/` 全为 **0 子目录**；`Composite/LayoutShell/` 下 9 个子目录是 **1.2.0 九类物理分类**（CSA 06:55 已授权、URI 恒 `Nova.Composite.LayoutShell`、非 v2.0 新增、非兼容视图），性质不同。**没有任何第二个类似 `Foundation` 的 v2.0 转发视图目录**。**12:05 补充**：CSA 指令把 `Composite/LayoutShell/` 下这 9 个九类物理子目录拍平（20 QML 上移一层），九类分类现为文档层台账、不再落物理目录——性质仍与 v2.0 兼容视图无关，M1 就绪态（0 视图 / 5 qmldir）不变。

> **为什么撤回是对的（不将就）**：本库原创收获是 **Prescript 预构范式**（`SPEC_PRESCRIPT*.md` 术语冻结 v1.0）；而 `Controls/Foundation/` 是照 Quasar「按域拆子目录 / `import Nova.Controls.Form`」思路落的物理试探，抢在原创范式前面制造了一个「第 6 个 `qmldir`」的观感，与 `GUIDE_COMPONENT_DOMAINS.md §1`「概念域 ≠ 物理层 ≠ 模块 URI」铁律别扭。撤回后 M1 更干净：**地基焊死、零物理残影、冻结面零漂移**。概念域分类**保留**在 `audit_domains.py` / `api/component-domains-1.2.0.json`（文档层台账，非物理目录），不受影响。

---

## 1. 技术可行性实测（Qt 6.12.0 · 可复现）

**不把立项建立在未验证的假设上**。`scripts/spike_v2_compat.py` 用 `QQmlComponent` 在**临时 import path** 造最小模块做 spike（临时目录内示意名为 `Sub/`，**不触碰仓库任何产品目录**），环境 `QT_QPA_PLATFORM=offscreen` + 单 `QGuiApplication`（规避坑位 49）。可随时重跑。

| 形态 | 构造 | 实测结果 | 裁定 |
|---|---|---|---|
| A | 旧 URI 平铺导出 `NovaInput 1.0 NovaInput.qml` | `Ready` · tag=`REAL` | 基线成立 |
| B | 同一 URI 相对子路径 `Sub/NovaText.qml` | `Ready` · tag=`SUB` | 1.2.0 已验证范式，成立 |
| C | **新 URI** `module Nova.Controls.Form` + `NovaInput 1.0 ../NovaInput.qml` | `Ready` · tag=`REAL` | **跨目录转发可行，拿到的是同一物理实现** |
| D | 新 URI 目录内放薄转发包装 QML（`Base.NovaInput { }`） | `Ready` · tag=`WRAPPER` | **类型身份被改 → 弃用**（兼容层不得用包装） |
| E | 双 URI 共存（旧 + 新同时 `import`、实例化） | `Ready` | 双轨可并存 |
| F | **物理重构**：文件搬进 `Form/`，旧 URI 用 `Form/NovaInput.qml` 反指，新 URI 平铺导出 | 双 `Ready` · 均 `REAL` | **物理重构 + 双轨兼容 + 单一事实源**成立 |
| H | 旧 URI `qmldir` 用 `../../Prescient/Carriers/NovaDesktop.qml` 转发到**新顶层目录** | `Ready` · tag=`REAL-DESKTOP` | **「9 大顶层目录重构 + 旧 URI 零破坏」技术可行** |

且 F/H 中 QML 文件内部 `import Nova.Services 1.0` 仍正常解析 —— 本库**全库 0 处相对导入**，物理搬家不影响内部依赖。

> **对旧裁定的校准（账实相符，非圆场）**：`GUIDE_QUASAR_ALIGNMENT.md §0.3` 冲突 #1 原写「改模块 URI 会摧毁冻结面、破坏已发布兼容」。spike H 证明更精确的事实是：**只要旧 5 个 URI 保留为薄转发 `qmldir`，物理目录可以彻底重构而兼容零破坏**。原裁定的「未采纳」结论在**当时无兼容层实测**的前提下成立；本立项书在 CSA 拍板 + 实测证据齐备后把它升级为「**已立项、M1 就绪态**」，历史评估表保留不回改。

---

## 2. 三层架构：冻结面 / 兼容层 / 物理层

| 层 | 唯一事实 | 谁能改 |
|---|---|---|
| **冻结面**（公共 API 契约） | 宪法第 13.1 条：**5 个 `LAYERS` 的 `qmldir` 导出行** = 144 类型 / 指纹 `68b34a408489b6a8`；双件制 `api/nova-api-1.2.0.json` + `docs/API_FREEZE.md`（`gen_api_freeze.py` 生成物，禁手改） | 「移模块 / 改签名 / 改分类」= 破坏性，**只能随 major 重签**（宪法第 9.1 / 13.3）；机判 `check_api_freeze.py` |
| **兼容层**（v2.0 契约） | **M1 就绪态：0 个物理视图**。契约 / 实测 / 守护 / 测试全部就位；未来视图须带 `# @nova-compat-view` 标记、`../` 指向冻结面同一物理文件、导出集合 ⊆ 144 类型 | additive、不进 `LAYERS`、不进冻结面；`audit_v2_compat.py` 守护；与 **M2 物理迁移同批**落地，不在 M1 抢跑 |
| **物理层**（文件归档） | M1：既有 QML **零搬运**（仍在 `Controls/*.qml` 等原位）、**零新增子目录**；M2+：按域 / 九大顶层目录分批迁入 | 每批单独重签 + 验收 + 销号（§5） |

### 2.1 关键区分（避免账实不符）

- **冻结面模块恒 5 个**：`Nova.Controls` 91 · `Nova.Behaviors` 13 · `Nova.Services` 16 · `Nova.Design` 4 · `Nova.Composite.LayoutShell` 20。M1 撤回 pilot 后，产品树 `qmldir` **精确 5 个**，由 `audit_v2_compat.py C3` 机检钉死。
- **兼容转发视图**（M1 = **0 个**）不是第 6 个冻结面模块：它不新增任何类型、不改变任何类型归属，只是给既有类型多一个访问路径。全库账本统一表述为「**5 个冻结面模块 + N 个 v2.0 兼容转发视图（当前 N=0）**」，`audit_domains.py` 的「5 模块」守护读的是冻结清单 `module` 字段，不受影响。
- **概念域 ≠ 物理层 ≠ 模块 URI**（`GUIDE_COMPONENT_DOMAINS.md` §1 铁律）继续有效。Foundation / Form / Action 等**只是文档层概念域标签**，不落物理子目录、不改 URI —— 这正是 10:44 撤回的依据。

### 2.2 M1 就绪态：零物理视图

M1 交付的是**可立即启用兼容层的完整地基**，而非任何半落地的物理试探：

| 资产 | 作用 | 是否落地物理视图 |
|---|---|---|
| `SPEC_V2_COMPAT.md`（本立项书） | RFC + 宪法合规论证 + 契约 + 路线图 | 否 |
| `scripts/spike_v2_compat.py` | Qt 七形态实测证据（7/7 PASS，临时目录，不碰产品树） | 否 |
| `scripts/audit_v2_compat.py` | C1~C5 就绪态守护（0 视图 / 5 qmldir / 生成器干净 / 冻结面零漂移） | 否 |
| `tests/test_v2_compat.py` | 旧 URI 真实实例化回归 + 0 视图机检（15 passed，conftest 单引擎规避坑位 49） | 否 |
| `gen_apidocs.py` | 回到 1.2.0 干净生成器（无 `@nova-compat-view` 死代码）；AI 包 `0b02273de9aee652` 幂等 | 否 |

> 首个真实转发视图在 **M2 与物理迁移同批**落地，届时 `audit_v2_compat.py` 的 C2/C3 由「0 视图硬约束」切换为「视图导出 ⊆ 冻结面 + 单一事实源」条件契约（§4），逐项机检后才销号。**M1 不抢跑、不留残影**。

---

## 3. 宪法合规论证：为什么 M1 不触发重签

| 条款 | 原文要点 | M1 的符合性 |
|---|---|---|
| 第 13.1 条 | 冻结面 = **5 个 `qmldir` 的导出行**；`_` 私有成员 / 默认值 / 内部结构不进面 | 就绪态**零视图、零新增导出类型** → 冻结公共面零变化 |
| 第 13.2 条 | 双件制清单 + 签署件**均为生成物、禁止手改** | `api/nova-api-1.2.0.json` **原样不动**；本立项书不改任何生成物 |
| 第 13.3 条 | 破坏性（删类型 / 改签名 / **移模块** / 改分类）只能随 major；增量（新类型 / 新公共成员）随 minor 且必须重签；**任何漂移都变红，不允许「先在文档里记一笔」绕过** | 就绪态**零新增公共成员**、**M1 不搬文件** → 两者均不触发 |
| 第 9.1 条 | 破坏性 API 变更必须升 major + CHANGELOG ⚠ Breaking | M1 无破坏性变更 → 包版本保持 `1.2.0`；**M2 迁移才升 `2.0.0` 重签** |
| 第 9.2 条 | 每次交付：升版 → CHANGELOG → 宪法迭代记录 → 重生成 ZIP | M1 是**立项 + 地基**，非版本交付；宪法迭代记录随 M2 正式升版补录 |

**硬约束（`gen_api_freeze.py:128`）**：`fingerprint()` 对含 `types[].file` 的 surface 做 canonical JSON 哈希 → **搬动任何 QML 都会改变指纹**，且 `check_api_freeze.py:133` 会校验 `file` 路径存在。因此「物理搬运 + 1.2.0 基线零漂移」在 M1 不可兼得，二者只能取其一：

- **M1（本轮）**：不搬文件、不建视图 → 基线 `68b34a408489b6a8` 冻结不动、账实相符；
- **M2**：搬文件 → 必须按第 13.3 条**重签 `api/nova-api-2.0.0.json`** 并做逐成员零漂移证明（沿用 1.2.0 物理分类时的「归一化 `file` 后指纹反推还原」方法），禁止中间态指纹。

> 这正是 §0.3 底线 3「不推倒重来」的法源依据：**先立地基、后逐批迁移**，而不是一次性把 144 类型全搬完再补文档。

---

## 4. 双轨兼容契约（五条，全部可机检）

M1 就绪态口径（由 `scripts/audit_v2_compat.py` 守护，失败即非零退出、可入 CI）：

| # | 契约 | 就绪态期望 | 守护 |
|---|---|---|---|
| C1 | **旧 5 URI 零改动**：`Nova.Controls` / `Behaviors` / `Services` / `Design` / `Composite.LayoutShell` 的 `qmldir` 导出集合与 `api/nova-api-1.2.0.json` 逐项一致，144 类型名、`file` 物理路径、`import` 用法零变化 | 144/144 PASS | `audit_v2_compat.py`；`check_api_freeze.py` 3/3 |
| C2 | **零物理兼容视图**：产品树 `@nova-compat-view` 视图数 == **0**（防止半吊子物理试探复现） | 0 个 | `audit_v2_compat.py` + `test_v2_compat.py` |
| C3 | **qmldir 恰 5 个**：全库 `qmldir` 精确 5 个冻结面模块，不得出现第 6 个独立子模块 | 5 / 5 | `audit_v2_compat.py` + `test_v2_compat.py` |
| C4 | **相对导入 0 处**：全库 QML 一律绝对模块 `import Nova.XXX` | 0 处 | `audit_domains.py` + `audit_v2_compat.py` |
| C5 | **生成器干净 + AI 包零污染**：`gen_apidocs.py` 无 `@nova-compat-view` 跳过死代码；`docs/ai/index.json` 5 模块 / 144 类型 / 指纹 `0b02273de9aee652` / 无视图产物 | 全 PASS | 重跑生成器 + 指纹比对 + `audit_v2_compat.py` |

> **M2 切换条件**：经 CSA 拍板 + additive major 重签后显式落地视图时，C2/C3 由「0 视图」切换为「视图导出集合 ⊆ 冻结面 144 短名（禁止新类型）+ `../` 目标解析后 == 冻结清单 `types[].file` 同一物理文件（禁止复制/包装 QML，spike D 已证包装会改身份）+ 视图目录内无 `.qml`」，并恢复生成器跳过标记。规则在此登记，**当前不启用**。

另由 `tests/test_v2_compat.py` 用 `conftest.qml_engine` **会话级单引擎**真实实例化 12 个旧 URI 类型（C1 兼容基线回归），规避坑位 49。

---

## 5. 分批迁移路线图（逐批销号，不批量扫荡）

| 批次 | 范围 | 动作 | 销号门槛 |
|---|---|---|---|
| **M1（本轮 · 就绪态）** | 立项 + 兼容层地基（**零物理视图**） | 新法源 `SPEC_V2_COMPAT.md` · spike 实测 · `audit_v2_compat.py` / `test_v2_compat.py` 就绪态守护 · 生成器干净 · 全库账本 | §7 全绿、冻结面与 AI 包零漂移 |
| **M2（待 CSA 定发布衔接）** | **首个兼容视图 + 首批物理迁移 + additive major 重签 2.0.0** | 按 spike F/H 把首批 QML 搬入 v2.0 目标目录；旧 URI `qmldir` 改相对路径转发；首个 `@nova-compat-view` 视图同批落地；`gen_api_freeze.py` 重签 `2.0.0`；`__about__.py` / CHANGELOG / 宪法迭代记录 / 项目投影同步 | 逐成员零漂移证明 + 全量门禁 + 已发布 `import` 回归 |
| **M3** | 余域逐批：Controls 其余 6 域（79 类型）· Behaviors 3 域（13）· 组合根九类（20）· Prescient / Entities / Orbit / Incubator 顶层（若 CSA 豁免 CC-1 批准） | 每批单独重签 / 单独验收 / 单独销号 | 每批全绿，禁止跨批夹带 |
| **M4** | 示例 / 文档 / 生成器 / 三态图 / 站点 / 发布 | 全库回扫 + 发布清单 | CSA 验收拍板 |

> **M2 的前置**：CSA 需明确「1.2.0 是否单独发布」与「2.0.0 是否直接接续」（§9）。在此之前小诺不擅自升版本、不擅自搬 QML、不擅自建视图 —— 这是发布权与 §0.3 底线，不是工程判断。

---

## 6. 风险登记

| # | 风险 | 处置 |
|---|---|---|
| R1 | wheel 未包含 M2 新增 `qmldir` | `pyproject.toml [tool.hatch.build.targets.wheel] packages = ["src/pyside_nova"]` 递归包含；M2 发布前**实际 build + 解压核对** |
| R2 | `qmllint -I qml_root` 对 `../` 转发的模块上下文解析 | 兼容视图目录内**无 .qml 文件**，`check_qmllint.py` 扫 `*.qml` 不受影响；M2 迁移后重验 |
| R3 | 兼容视图被第三方工具误当第 6 个冻结面模块 | `# @nova-compat-view` 显式标记 + `audit_v2_compat.py` C3 守护 + 全库账本统一「5 冻结面 + N 视图（当前 N=0）」表述 |
| R4 | Qt 6.12 + shiboken 生命周期 SIGSEGV（坑位 49） | 复用 `conftest.qml_engine` 单引擎 + `_HELD` 强引用 + `close_alive()`；spike 用单 `QGuiApplication` offscreen |
| R5 | 1.2.0 尚未发布，v2.0 直接跳版会让 1.2.0 成为内部基线 | §9 交 CSA 拍板；M1 明确「1.2.0 为兼容基线冻结不动」 |
| R6 | 全量废除 `Composite` / 改模块 URI 需豁免 CC-1 + 宪法第 13 章 | §9 交 CSA 单独一句话拍板；技术可行性已由 spike H 证明，但**不擅自执行** |
| R7 | 半吊子物理试探抢跑、制造「第 6 个 qmldir」观感 | **已由 CSA 10:44 撤回 + `audit_v2_compat.py C2/C3` 机检钉死**（§0.4）；M2 前任何视图都是 FAIL |

---

## 7. M1 验收标准（全绿方销号）

| 项 | 期望 |
|---|---|
| 静态门禁 `check_all.py --tier static` | **3/3**（a11y · API 冻结 · qmllint 0 error） |
| 专项 | **53 passed** + `test_v2_compat.py` **15 passed**（12 旧 URI 实例化 + 3 就绪态机检）= **68 passed** |
| `audit_ceiling.py` | **20/20** · 链接断链 0 |
| `audit_foundations.py` | **15/15** |
| `audit_domains.py` | **PASS** · 144 类型 / 5 冻结面模块 |
| `audit_v2_compat.py`（新） | **PASS** · C1~C5 · **0 物理视图 / 5 qmldir / 生成器干净** |
| `spike_v2_compat.py`（新） | **7/7** 形态全 PASS（临时目录，不碰产品树） |
| `mkdocs build` | exit 0 / 0 内容 INFO / 0 "not in nav" |
| `gen_apidocs.py` 幂等 | AI 包 **144 类型 / 13 页 / `0b02273de9aee652`** 不变（生成器回到 1.2.0 干净态） |
| `gen_prompt.py --check` | 项目投影同步 ✓（因 `SESSION_HANDOFF.md` 校准 M1 就绪态状态行**重签**，属真实状态变更、非漂移） |
| **零漂移** | 冻结面 **`68b34a408489b6a8`** 不变 · 零 QML 搬运 · 零旧 `qmldir` 改动 · 零模块 URI 改动 · 零生成物手改 · **零物理兼容视图** |

---

## 8. CARF 映射

- **C 构想**：CSA「先做 v2.0 物理重构，立项和兼容层一起」+ §5 四条前置条件；方向 = 双轨兼容、底线 = 不破坏已发布兼容 / 不擅自改宪 / 不批量扫荡。
- **A 实现**：本立项书 + Qt 七形态实测 + C1~C5 就绪态守护 + 真实实例化测试 + 全库账本；**依 CSA 10:44 指令，零物理试点、零死代码、零残影**。
- **R 打磨**：Qt 实测把「物理重构是否必然破坏兼容」从推测变为**证据**；宪法第 9/13 章逐条论证 M1 零重签；10:44 撤回把「照 Quasar 拆子目录」的物理试探从库里清出去，让 **Prescript 原创范式**回到第一位；账实不符处（旧裁定 / 链接计数 / 工作树分类 / M1 状态）逐项登记。
- **F 封版**：M1 独立复跑全量门禁、零漂移、生成器幂等、断链 0；改动全部留工作树未提交，**发布归 CSA**。

---

## 9. CSA 待拍板项（小诺不代为决定）

1. **1.2.0 发布衔接**：1.2.0 仍按原清单单独发布、随后 2.0.0 接续？还是放弃单发 1.2.0、直接以 2.0.0 对外？——决定 M2 何时启动与版本号起点。
2. **是否全量废除 `Composite` / 改模块 URI**（照 FINAL 稿 9 大顶层目录）：spike H 已证技术可行，但属宪法第 13 章「移模块」+ CC-1「唯一组合上下文」豁免，需 CSA **单独一句话**拍板；未拍板前 M2 只在既有 URI 下做物理迁移。
3. **兼容视图 URI 命名**：M1 就绪态不含任何视图；M2 落地首个视图时采用点分子模块还是 `NovaV2.*` 前缀，M2 前一句话即可切换（当前影响面 = 0）。
4. **✅ 术语 / 命名议题（`LayoutShell` 与 `Prescript`）· 2026-11-26 11:22 CSA 拍板结案「不改名」**：工程标识 `Nova.Composite.LayoutShell`、20 组合根类型名、`import` 用法与 `SPEC_PRESCRIPT*.md`「术语冻结 v1.0」三层体系（Prescript 范式层 / Prescient Layout Shell 载体层 / CARF 品质层）**一律维持现状、零改动**；小诺 10:44 建议的「概念层升格双名制」亦不擅自执行，**不单独立 RFC、不并入任何物理重构批次**。10:44 评估（术语越界 / 破坏已发布 `import` / 逼着重签冻结面）作为结案依据保留于史料；**未改动任何 QML / `qmldir` / URI / 冻结面**（`68b34a408489b6a8` 零漂移）。

> **切换口令**：若 CSA 要的是「本轮直接全量搬迁 + 升 2.0.0 重签」，一句话即切到 M2 全量模式；本立项书的 §2~§4 契约仍适用，只是把 M2 提前。

---

## 附录 A · 实测可复现

- `scripts/spike_v2_compat.py` —— Qt 6.12 `QQmlComponent` 七形态实测（A/B/C/D/E/F/H，含 F1/F2），输出 7/7 PASS 表；用 `python scripts/spike_v2_compat.py` 重跑。临时目录内示意名为 `Sub/`，**不触碰仓库产品目录**。
- `scripts/audit_v2_compat.py` —— C1~C5 就绪态静态守护（0 视图 / 5 qmldir / 生成器干净 / 冻结面零漂移）。
- `tests/test_v2_compat.py` —— 12 旧 URI 真实实例化回归 + 3 就绪态机检（15 passed）。
- 原始 spike 结论见 §1；本库当前所有时点值（`68b34a408489b6a8` / `0b02273de9aee652` / 项目投影指纹）按「史料不圆场」保留在各自历史行，不回改。
