# 上游跟进节奏（D3 · 2026-11-28 09:37 已核定）

<!-- cadence-signature: 705d09e50e671df98a0bbdd95360d39515fefbb0ab51599e72186311cb6bb1d9 -->

> **生成物 · 禁手改**：由 `scripts/gen_parity_cadence.py` 从唯一法源 `upstream/cadence.json` 渲染；`check_parity_ops.py` 用此签名做双向核对。
> **版本事实源**：`upstream/quasar-pin.json`（本页刻意不复制 pinned / observed 版本号，避免口径散落）。**关系口径**：Inspired by Quasar (MIT) · 只用公开 API 元数据与发布说明。
> **性质**：本页是**节奏口径**（方向与标准级），不是自动化实现。本轮未创建任何定时自动化任务；周期自动化属 P3，须 CSA 单独授权。

## 1. 核定结论

**三档节奏：**T1 交付前离线硬门（必跑、阻断）+ T2 每周一次在线周巡（制度化、双源交叉、只登记）+ T3 阻断类事件即时响应（不等周巡）**。准实时自动化不做，保留为 P3 独立议题。**

核定依据：CSA 2026-11-28 09:37 授权「D3 跟进节奏你先定」；小诺依磁盘实证核定并落为唯一法源。本文件只定节奏口径，不创建任何定时自动化任务。。承接提案 §7-D3 的建议（交付前离线门 + 每周在线周巡），并按磁盘实证把「每周」细化为三档触发与分级 SLA。

## 2. 实证依据（为什么不做准实时）

| 版本 | 日期 | 实际变更 |
|---|---|---|
| 2.35.3 | 2026-11-09 | 安全硬化（C5） |
| 2.35.4 | 2026-11-12 | 安全硬化（C5） |
| 2.35.5 | 2026-11-17 | 建库对账基线 |
| 2.35.6 | 2026-11-21 | 3 条 humanStorageSize 修复（全部 C1） |
| 2.36.0 | 2026-11-28 | Tajik 语言包（C3）+ 两指令 TS 类型（C4） |

> 逐条实证：
> - 11-09 ~ 11-28 共 5 版，间隔 3~7 天；**组件 API 面变化为 0**
> - 真实影响仅 1 个 L5 工具函数（C1×3）+ lang / TS 类型（C3 / C4）
> - T30 已证：不做分类分级，每次上游 patch 都会误导成「全库 147 类型重跑」
> - 第三方 EOL 站点滞后（仍报 2.35.6 为最新）→ 监测必须 GitHub Releases + npm registry 双源交叉

> **推论**：上游发版频度高但 API 面变更稀疏。准实时（每次 Release 全量对账）会把 C3/C4/C6 噪音放大为重跑，直接违反提案 §6「误报率 = 0」；交付前离线硬门已能兜住全部阻断类。因此节奏的价值在「不漏登记 + 分级响应」，而非「触发得更快」。

## 3. 三档触发

| 档 | 节奏 | 模式 | 硬门 | SLA | 责任 | 状态 |
|---|---|---|---|---|---|---|
| **T1 交付前离线硬门** | 每次立项验收 / 封版 / 发布前，无条件必跑 | offline | **是（rc 1 阻断）** | 交付动作前同步完成，无时延 | 小诺（执行 / 自检）→ CSA（验收） | `implemented` |
| **T2 每周在线周巡** | 每周一次（建议周一）；上游 Release 后 ≤1 个工作日内补跑一次 | online | 否 | 上游 Release → upstream/reports/<from>-<to>.md 落盘 ≤1 工作日 | CSA 触发（或 P3 授权后自动化）→ 小诺执行 / 登记 / 账本 | `institutionalized` |
| **T3 阻断类事件即时响应** | 事件驱动：命中 C0 / C1 / C5，或上游 major 版本 / 新品类 | event | 否 | 发现 → 变更登记 ≤1 工作日；修复排在下一个交付窗口前 | CSA（立项 / 拍板）→ 小诺（实现 / 自检 / 文档 / 账本） | `ratified` |

### 3.1 各档明细

**T1 · 交付前离线硬门**

- 数据源：本地 quasar-pin.json + upstream/changes/*.json + upstream/cache/
- 命令：`python scripts/check_upstream_drift.py --offline` / `python scripts/check_parity.py`
- 产出：控制台结论（PASS / FAIL） · 可选 --report 结构化 JSON
- 说明：离线零联网、零第三方依赖；rc 1 = 存在未销号 C0/C1/C5、分类漂移或 6 处 baseline 口径漂移 → 阻断交付。不挂进 check_all.py --tier static（静态恒 3/3），按项目惯例交付前单独跑。

**T2 · 每周在线周巡**

- 数据源：GitHub Releases（changelog）+ npm registry（dist/api 实体）双源交叉，不依赖单一聚合站
- 命令：`python scripts/check_upstream_drift.py --online  # P3 实现，当前 rc 2（前置缺失，非产品红）`
- 产出：upstream/changes/<from>-<to>.json（逐条变更 + C0~C6 分类 + test_ids 绑定） · upstream/reports/<from>-<to>.md（实证报告 + 欠账清单） · quasar-pin.json::observed_version 更新（pinned 不动，D4）
- 说明：只登记、不改代码 / 不升 pin / 不重签 / 不发布。C2 命中进 P2 广度台账；C3/C4/C6 仅登记，严禁触发全库重跑（误报率 0 红线）。

**T3 · 阻断类事件即时响应**

- 数据源：周巡登记结果 / 安全通告 / CSA 直报
- 命令：`独立议题立项（T 编号）→ CSA 拍板 → 小诺实现 + 机检固化 + 销号`
- 产出：`独立议题` · `机检用例` · 销号后的 changes 条目（status=resolved + test_ids）
- 说明：不等周巡。阻断类未销号时 T1 离线门自动 rc 1，形成闭环：事件发现 → 登记 → 立项 → 修复 → 机检 → 销号 → 门放行。

## 4. C0~C6 分级响应 SLA

| 类 | 阻断 | 响应时限 | 动作 | 闸门 |
|---|---|---|---|---|
| **C0** | **是** | ≤1 工作日登记 | 命中组件 PARITY 重跑；additive 公共类型评估 minor 重签 | T1 |
| **C1** | **是** | ≤1 工作日登记 | 按 T30 范式修函数体 + 补边界机检用例，公共签名零变化 | T1 |
| **C2** | 否 | 当周周巡内 | 登记 GAP + 里程碑，纳入 P2 广度台账 | T2 |
| **C3** | 否 | 当周周巡内 | 仅登记（i18n 可选增益），不触发重跑 | T2 |
| **C4** | 否 | 当周周巡内 | 仅登记（QML 无 TS 类型层），不触发重跑 | T2 |
| **C5** | **是** | ≤1 工作日登记 | check_cve.py + NovaUtils.sanitize 复核 | T1 |
| **C6** | 否 | 当周周巡内 | 仅登记（文档 / 构建 / CI / 内部重构），不触发重跑 | T2 |

## 5. 闸门契约与红线

| 项 | 口径 |
|---|---|
| `hard_gate` | T1 是唯一硬门；rc 1 阻断交付 |
| `resolution_requirement` | C0/C1/C5 变更必须 status=resolved 且带真实 test_ids，否则离线门按 resolved-but-no-test_id 阻断 |
| `no_rerun_redline` | C3 / C4 / C6 不得触发全库 147 类型重跑（提案 §6 误报率 = 0） |
| `pin_independence` | 周巡只更新 observed_version；pinned_version 升版走独立议题（D4） |

## 6. 明确不做（non-goals）

- 准实时自动化：每次 Release 自动触发全库对账 —— 否。理由：5 版实证 API 面变化为 0，C3/C4/C6 占多数，自动化只会放大噪音并可能违反 D4 造成「基线跳了、实现没跟」。
- 自动升 pin / 自动改 QML / 自动重签 / 自动发布 —— 否。发布归 CSA，冻结面铁律不变。
- 挂进 check_all.py --tier static —— 否。静态门禁恒 3/3，交付前单独跑两道门。
- 本轮创建定时自动化任务 —— 否。D3 只核定节奏口径；周期自动化属 P3，须 CSA 单独授权后建。

## 7. 留给 P3 的待办（本轮不实现）

- check_upstream_drift.py --online 双源拉取实现（当前 rc 2 明确为前置缺失）
- nova_mcp.py::check_updates 升级为报 drift 分类 + 欠账清单 + 报告路径
- 每周定时自动化任务（须 CSA 单独授权）
- LTS 承诺 + 迁移指南模板

## 8. 边界与交还控制权

**零 QML 改动 · 零冻结面改动（147 类型 / `9966483dda5a53c4` 不变）· 零史料回改 · 零发布动作 · 零自动化任务**。交付前离线门（`check_upstream_drift.py --offline`）与 `check_parity.py` 仍按项目惯例单独跑，不挂 `check_all.py --tier static`（静态恒 3/3）。
> 节奏已核定，但**周巡的在线实现与定时自动化均需 CSA 另行立项/授权**；未发话前不自行开工、不建 automation、不升 pin。

---

*签名 `705d09e50e671df98a0bbdd95360d39515fefbb0ab51599e72186311cb6bb1d9` · 由 `gen_parity_cadence.py` 生成，`check_parity_ops.py` 校验。*
