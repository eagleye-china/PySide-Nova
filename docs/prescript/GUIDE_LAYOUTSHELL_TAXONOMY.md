# pyside-nova 组合根二维分层台账（通用布局原语 / 产品级组合根）

> **文档性质**：本库**现行**实用文档（非史料、非方案稿）· `Nova.Composite.LayoutShell` 21 个组合根的**二维分层唯一查阅入口**
> **适用版本**：**1.11.0（本地完成，待 CSA 发布）** · `api/nova-api-1.11.0.json` · **147 导出类型** · **21 组合根** · 内容指纹 **`9966483dda5a53c4`**
> **立项**：**T29 · 2026-11-28 · CSA「先 A 后 B」**；本页为 **A 阶段**交付物（文档层台账），B 阶段物理迁移见 [`SPEC_T29_LAYOUTSHELL_SPLIT.md`](SPEC_T29_LAYOUTSHELL_SPLIT.md)
> **法源链**：母法 [`CONSTITUTION.md`](../CONSTITUTION.md)（卷首 CARF / 第 8 章版本 / 第 13 章冻结面）→ 组合宪法 [`COMPOSITION_CONSTITUTION.md`](../COMPOSITION_CONSTITUTION.md) 1.0.0（CC-1 唯一组合上下文 / CC-8）→ [封版规范 v2.1.0](SPEC_FREEZE.md) → [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md)（九类台账 / §1.1 拍平史料 / §6 铁律）→ [`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md)（M1 就绪态 / §4 C1~C5 / §5 M2 / §9 拍板项）→ 本台账
> **状态**：**现行 · 2026-11-28 03:2x · T29 完现（A 文档层 + B 物理迁移）· URI 与 147 公共面零漂移 · 1.11.0 待 CSA 发布**

---

## 🆕 1.11.0 现行校准（T29-B · 物理迁移已落地）

> 本段覆盖下方 §0~§7 的 A 阶段快照；下方「A 阶段零重签 / 仍 1.10.0」等表述是**当时事实**，按「史料不圆场」逐字保留。

- **CSA 拍板**：版本起点 **1.11.0 minor（仅重签指纹）**、**不落兼容视图**、**不升 2.0.0 major**。
- **B 已落地**：10 个通用布局原语 QML 上移 `Composite/`，`LayoutShell/qmldir` 10 条 `../` 转发；
  11 个产品级组合根原位不动；URI 恒 `Nova.Composite.LayoutShell`、21 类型名与 `import` 全不变。
- **零漂移**：147 类型公共面逐成员零变化，唯一变化是 10 个 `types[].file`；
  归一化反推**精确还原旧指纹** `5328cd0e3c71e7ac` → 新指纹 **`9966483dda5a53c4`**。
- **机检**：`tests/test_t29_migration.py` 9 passed；静态 3/3 · a11y 147/147 · foundations 15/15（130 类型实例化零缺陷）·
  v2 compat C1~C5 PASS · qmllint 0 error · `mkdocs --strict` EXIT=0。
- **判别锚不变**：`hsvHue` 命中 11（保留）/ 未命中 10（移出）零例外，迁移后复验仍成立。

---

## 0. 一句话结论与可机检判别锚

CSA 于 T29 提出：把 `Composite/LayoutShell/` 下 **除 `Agent`/`AIReport`/`Chat`/`Copilot`/`DE`/`Desktop`/`FlexLayout`/`Incubator`/`Mobile`/`Orbit`/`SetupWizard` 这 11 个之外**的其他组件移入 `Composite/`。磁盘实测 21 个组合根，移出集恰为 10 个、保留集恰为 11 个，**划分成立且零例外**。

**它不是按九类分**（[`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §4 的九类里 `Page/` 被劈成两半：`NovaSetupWizard` 保留、`NovaBlankPage` 移出）。真正的分界是：

> **产品级组合根（11，保留在 `LayoutShell/`）↔ 通用布局原语（10，拟移入 `Composite/`）**

而这个二维分界在本库有一个**已存在、可机检、零例外的判别锚**：

> **`NovaTheme.primary.hsvHue`（主题色唯一公共派生源 / 身份色）是否在该 QML 中被用作专属色相派生。**
> 命中 = 有专属身份色的**产品级组合根**；未命中 = 无身份色的**通用布局原语**。
> 该锚是工作区长期笔记（`.workbuddy/memory/MEMORY.md`）§2 冻结铁律「`NovaTheme.primary.hsvHue` 是主题色唯一公共派生源，禁 `secondary|accent` 作身份色」的直接推论，不是新造体系。

```bash
# 可复现机检（在 pyside-nova/ 根执行；21 个 QML 二分，零例外）
grep -l  "hsvHue" src/pyside_nova/qml/Nova/Composite/LayoutShell/*.qml   # → 11 个 = 保留集
grep -L  "hsvHue" src/pyside_nova/qml/Nova/Composite/LayoutShell/*.qml   # → 10 个 = 移出集
```

> **实测结果（2026-11-28）**：`hsvHue` 命中 11 个 = `NovaAgent, NovaAIReport, NovaChat, NovaCopilot, NovaDE, NovaDesktop, NovaFlexLayout, NovaIncubator, NovaMobile, NovaOrbit, NovaSetupWizard`，与 CSA 保留清单**逐字一致**；未命中 10 个 = `NovaBlankPage, NovaCardGrid, NovaCompare, NovaDrawerPanel, NovaDualSide, NovaModal, NovaSidebar, NovaTabShell, NovaThreeColumn, NovaTopNavigation`，与移出清单**逐字一致**。

---

## 1. 集合核算（21 → 11 + 10）

> 事实源：`src/pyside_nova/qml/Nova/Composite/LayoutShell/qmldir` 导出行 + `api/nova-api-1.10.0.json` 的 `types[].file` + QML 字面量。九类归属沿用 `qmldir` 注释与 [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §4 台账，不另造体系。

### 1.1 保留集 · 产品级组合根（11）· 全部命中 `hsvHue`

按 QML 内色相偏移值升序（偏移相对 `NovaTheme.primary.hsvHue`，近似色相以 233° 基准换算；`≈` 为四舍五入值，权威值是 QML 字面量）：

| # | 组件 | 九类归属（文档层） | 批次 | QML 色相偏移 | 近似色相 | 身份 |
|---:|---|---|---|---:|---:|---|
| 1 | `NovaSetupWizard` | `Page/` 独立页壳 | 1.0.0 GA | `-0.1790` | 169° | 十色相首 · 安装配置向导壳 |
| 2 | `NovaFlexLayout` | `Carrier/` 多端根壳 | 1.0.0 GA | `-0.1560` | 177° | 企业大屏弹性布局壳 |
| 3 | `NovaMobile` | `Carrier/` 多端根壳 | 1.0.0 GA | `-0.1110` | 193° | 移动应用根壳 |
| 4 | `NovaDE` | `Intelligence/` AI 智能 | 1.2.0 增量 | `-0.0760` | 206° | 旗舰法源 [`LAW_NovaDE.md`](LAW_NovaDE.md) |
| 5 | `NovaChat` | `Chat/` AI 对话主窗口 | 1.0.0 GA | `-0.0460` | 216° | 七槽六轨主窗口 |
| 6 | `NovaDesktop` | `Carrier/` 多端根壳 | 1.0.0 GA | `-0.0260` | 224° | 桌面应用根壳 |
| 7 | `NovaAgent` | `Intelligence/` AI 智能 | 1.2.0 增量 | `0.0000` | 233° | 旗舰法源 [`LAW_NovaAgent.md`](LAW_NovaAgent.md) · **primary 基准** |
| 8 | `NovaOrbit` | `Orbit/` 意图轨道 | 1.2.0 增量 | `+0.0290` | 243° | 旗舰法源 [`LAW_NovaOrbit.md`](LAW_NovaOrbit.md) |
| 9 | `NovaAIReport` | `Intelligence/` 智能报表 | **1.5.0 additive · 第 21 组合根** | `+0.0694` | 258° | 仪表钢蓝 · 七槽无业务语义壳 |
| 10 | `NovaCopilot` | `Intelligence/` AI 智能 | 1.2.0 增量 | `+0.0940` | 267° | 旗舰法源 [`LAW_NovaCopilot.md`](LAW_NovaCopilot.md) |
| 11 | `NovaIncubator` | `Incubator/` 孵化器 | 1.2.0 增量 | `+0.1390` | 283° | 旗舰法源 [`LAW_NovaIncubator.md`](LAW_NovaIncubator.md) · 十色相末 |

> **十色相工作台**：上表除 `NovaAIReport` 外的 10 个正好对应工作区长期笔记 §5 记录的十色相（SetupWizard 168 / Flex 176 / Mobile 193 / DE 205 / Chat 216 / Desktop 223 / Agent 233 / Orbit 243 / Copilot 266 / Incubator 283°）；`NovaAIReport` 是 1.5.0 新增第 21 组合根，沿用同一 `hsvHue` 派生纪律、偏移 `+0.0694`。**保留集 = 十色相工作台（10）+ 第 21 组合根（1）= 11。**
> 所有偏移均写作 `(NovaTheme.primary.hsvHue + offset + 1) % 1`，私有令牌不进冻结面；`setBrand()` 换肤时同步平移，饱和 / 明度系数各自独立定制（CC-3 组件内单色相）。

### 1.2 移出集 · 通用布局原语（10）· 全部未命中 `hsvHue`

槽位 / 信号 / 函数三列取自 [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §4 台账（QML 字面量实测）：

| # | 组件 | 九类归属（文档层） | 槽位 | 信号 / 函数 | 定位 |
|---:|---|---|---:|---|---|
| 1 | `NovaSidebar` | `Navigation/` 主导航 | 5 | 1 / 1 | 侧边导航工作台 |
| 2 | `NovaTopNavigation` | `Navigation/` 主导航 | 5 | 1 / 1 | 顶部导航工作台 |
| 3 | `NovaDualSide` | `Navigation/` 主导航 | 5 | 2 / 2 | 双侧边工作台 |
| 4 | `NovaTabShell` | `Navigation/` 主导航 | 4 | 3 / 0 | 标签页工作台 |
| 5 | `NovaThreeColumn` | `Workbench/` 多栏工作台 | 6 | 1 / 0 | 三栏工作台 |
| 6 | `NovaCompare` | `Workbench/` 多栏工作台 | 5 | 1 / 1 | 双栏对比壳 |
| 7 | `NovaCardGrid` | `Workbench/` 多栏工作台 | 4 | 0 / 0 | 卡片网格壳 |
| 8 | `NovaModal` | `Overlay/` 浮层容器 | 3 | 1 / 1 | 模态弹窗壳 |
| 9 | `NovaDrawerPanel` | `Overlay/` 浮层容器 | 3 | 1 / 1 | 侧边滑出面板壳 |
| 10 | `NovaBlankPage` | `Page/` 独立页壳 | 4 | 0 / 0 | 纯净单页壳 |

> **九类分布**：`Navigation/` 4 全移出 · `Workbench/` 3 全移出 · `Overlay/` 2 全移出 · `Page/` **2 选 1 移出**（`NovaBlankPage` 移、`NovaSetupWizard` 留）· `Carrier/` 3 全保留 · `Chat/` `Intelligence/` `Orbit/` `Incubator/` 全保留。**唯一被劈开的九类是 `Page/`** —— 这正是「分界不是九类」的磁盘证据。

### 1.3 为什么 `Page/` 会被劈开

`NovaSetupWizard` 虽与 `NovaBlankPage` 同属 `Page/`，但它是**安装配置向导壳**，有专属色相（169°，十色相首）、3 个信号、独立的产品叙事；`NovaBlankPage` 是**纯净单页壳**（0 信号 / 0 函数），无任何身份标识，是最纯粹的布局原语。二者按「有无专属 `hsvHue` 身份色 / 产品叙事」分列两侧，符合二维分界；按九类则无法解释。

---

## 2. 判别锚的机检口径

| 项 | 口径 |
|---|---|
| 判别式 | `'hsvHue' in <QML 正文>` → 产品级组合根；否则 → 通用布局原语 |
| 事实源 | `src/pyside_nova/qml/Nova/Composite/LayoutShell/*.qml`（21 个） |
| 期望 | 命中 **11** / 未命中 **10**，与 §1.1 / §1.2 两表逐字一致 |
| 复现 | `grep -l` / `grep -L`，或等价 Python `Path.glob('*.qml')` 遍历 |
| 约束 | 判别锚是**现象归纳**而非新契约：不得为迁就分类给移出组件补 `hsvHue`，也不得据此改动任何 QML / `qmldir` / 冻结面 |

> **A 阶段纪律**：本台账是**只读查询表**。它只描述现状、不改现状；移出动作属 B 阶段，须另按 [`SPEC_T29_LAYOUTSHELL_SPLIT.md`](SPEC_T29_LAYOUTSHELL_SPLIT.md) 的拍板项执行。

---

## 3. 与既有三层铁律的关系（不冲突）

`GUIDE_CLASSIFICATION.md` §0 / §6 与 `qmldir` 头注释共同确立的铁律是：

> **概念域 ≠ 物理目录 ≠ 模块 URI**；概念分层入文档台账，物理层归平铺，模块 URI 恒为单一 `Nova.Composite.LayoutShell`。

本二维分层**完全落在「概念域 / 文档台账」这一层**：

| 层 | 本台账是否触碰 | 说明 |
|---|---|---|
| 概念域（九类 / 二维分层） | **是（文档层）** | 新增一维「通用原语 ↔ 产品级根」，与九类并存，不改九类台账 |
| 物理目录 | 否（A 阶段） | 21 个 QML 仍平铺于 `Composite/LayoutShell/`，零搬动 |
| 模块 URI | 否 | `Nova.Composite.LayoutShell` 单一模块、21 个类型名、`import` 用法全部不变 |

因此 A 阶段**不违反**三层铁律，也不触发 `fingerprint()` 重签（`fingerprint()` 含 `types[].file`，但本阶段不动 `file`）。

---

## 4. 与 v2.0 M1 / M2 的关系（如实登记，不圆场）

[`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) 已立项「v2.0 = 物理目录重构 + 双轨兼容」，**M1 现为就绪态**（0 兼容视图 / 5 `qmldir` / C1~C5 守护全绿）。本 T29 的 B 阶段正好落在该立项书的 **M2 首批物理迁移**上，但两者有三处口径需要如实对齐：

| # | `SPEC_V2_COMPAT.md` 现行文字 | 磁盘 / 账本事实 | 处置 |
|---|---|---|---|
| 1 | 版本锚点（第 5 行）：`__about__.py = 1.2.0` · `api/nova-api-1.2.0.json` · **144 类型** · 指纹 `4f882374ad52262b` · 目标 **2.0.0** | 现行 **1.10.0 已发布** · `api/nova-api-1.10.0.json` · **147 类型** · 指纹 `5328cd0e3c71e7ac` | **账实不符必校准**：B 阶段实施前须把该法源页版本锚点校准到现行，历史行按「史料不圆场」保留不回改 |
| 2 | §9 拍板项 1「1.2.0 是否单独发布 / 2.0.0 是否直接接续」 | 1.2.0 早已发布且版本链已推进到 1.10.0 | 该拍板项已随历史演进失效，B 阶段须改问「**版本起点 = 1.11.0 minor 还是 2.0.0 major**」 |
| 3 | §4 C1「144 类型名、`file` 物理路径、`import` 用法零变化」· §5 M2「additive major 重签 2.0.0」 | B 路线是 **URI 与 `import` 全不变**、只搬 10 个文件 | 必须按 §4「M2 切换条件」与 §116「归一化 `file` 后指纹反推还原」把 C1~C5 从就绪态切到迁移态；[`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §1.1 已实测该归一化可精确还原旧指纹 |

**另一处冲突（12:05 平铺约定）**：CSA 2026-11-26 12:05 拍板「九类子目录拍平」，`qmldir` 头注释写「**不再落物理子目录**，物理层回归平铺、老用户路径零漂移」。B 把 10 个文件移入 `Composite/`（上一级）会**重新引入物理分层**，与该美术约定冲突；但它**不建第 6 个 `qmldir`、不改 URI**，故不违反「物理目录 ≠ 模块 URI」铁律本身。冲突与授权状态逐项登记于 [`SPEC_T29_LAYOUTSHELL_SPLIT.md`](SPEC_T29_LAYOUTSHELL_SPLIT.md) §5，**不圆场、不静默**。

---

## 5. B 阶段影响面预登记（A 阶段只读，不执行）

> 以下为 B 阶段实施前的**事实核查结果**，仅登记、不动作。数据取自 2026-11-28 磁盘实测。

| 面 | 实测 | 结论 |
|---|---|---|
| 全库 `Nova.Composite.LayoutShell` URI 引用 | **180 个文件** | B 保持 URI 不变 → 这些引用**零改动** |
| 10 组件在 `examples/` 引用 | 各 **3~5 个文件** | 按 URI 引用，同样零改动 |
| 10 组件 QML 正文相对路径 `import` | **0 处** | 一律绝对模块 `import Nova.Controls / Services / Design`，移动不影响解析 |
| 10 组件被 11 个保留组件引用 | **0 处** | 内部零耦合，可整批迁出 |
| `fingerprint()` 含 `types[].file` | 是 | **搬 QML 必重签**（唯一变化是 10 个 `file` 溯源字段，公共面逐成员零漂移） |
| `Composite/` 下 `qmldir` | **无**（直接子项仅 `LayoutShell/`） | 只能由 `LayoutShell/qmldir` 写 `../NovaXxx.qml` 转发 |
| 全库 `qmldir` 的 `../` 转发先例 | 产品树 **0 处** | 法源 R2 标注须真机复验（[`SPEC_V2_COMPAT.md`](SPEC_V2_COMPAT.md) §6）；**T29-A 已实测排险**：`spike_v2_compat.py` 形态 C（`../` 跨目录转发）/ H（`../../` 到新顶层目录）**7/7 PASS**，另以 B 精确形态 A/B 对照探针（既有 URI 不变、QML 在父目录）验证两组均 `Ready` · tag 同为 `REAL` · 非包装 → **`../` 转发可行、URI 与类型身份不变**，R2 降级为「真机回归项」而非「未验证假设」 |
| `check_a11y.py` TABLE 键 | `Composite/LayoutShell`（硬编码，按层扫） | 10 个搬出后须校准路径映射，否则 a11y 147/147 门禁漏登记 |
| `audit_v2_compat.py` C1 | `expect = f"Nova/{layer}/{file}"` 逐字比对 | `../` 写入 `file` 后须按 §1.1 归一化法改为 `normpath` 比对 |

---

## 6. 维护纪律

1. **新增组合根**：先按 §0 判别锚判定归属（有专属 `hsvHue` → 产品级 / 无 → 通用原语），再回写 [`GUIDE_CLASSIFICATION.md`](GUIDE_CLASSIFICATION.md) §4 九类台账与 `qmldir` 导出行；两表并存、互不替代。
2. **分类口径变更**：必须走 RFC 并在本页 §0 追加裁定记录，不得静默改写；本页不持有版本锚点，一切以 `src/pyside_nova/__about__.py` + 冻结清单为准，避免多头事实源。
3. **生成物禁手改**：`docs/components/` · `docs/ai/` · `nova-data.js` · `COMPONENT_LIST.md` · `API_FREEZE.md` · `A11Y_MATRIX.md` · `api/*.json` 一律由生成器产出，本台账不触碰。
4. **史料不圆场**：1.2.0 九类物理子目录（06:55 授权）/ 12:05 拍平重签 / 1.10.0 已发布冻结面，均按各自历史行保留，不因本台账回填或改写。
5. **A 阶段零重签**：本页与 [`SPEC_T29_LAYOUTSHELL_SPLIT.md`](SPEC_T29_LAYOUTSHELL_SPLIT.md) 均为文档层交付，产品代码 / `qmldir` / URI / 冻结面 / 版本号 / 徽标全部不动。

---

## 7. 封版声明（T29-A）

**本台账为 pyside-nova 1.10.0（已发布）组合根二维分层的现行查询入口：11 个产品级组合根 + 10 个通用布局原语，判别锚 `NovaTheme.primary.hsvHue` 零例外可机检。A 阶段只在文档层落地，物理目录、模块 URI、147 类型公共面、内容指纹 `5328cd0e3c71e7ac` 全部零漂移。**

- 概念分层：**九类（既有）+ 二维分层（本页新增）** 并存于文档台账
- 物理层：**21 个 QML 仍平铺于 `Composite/LayoutShell/`**，单一模块 URI 不变
- 冻结面：**147 类型 · 指纹 `5328cd0e3c71e7ac` · 零重签**
- 发布边界：`commit / push / tag / PyPI / 站点上线` **一律归 CSA**

> **身份色定归属，物理层待拍板；九类管语义，二维管分层，URI 恒单一。**
