# Parity 机读矩阵 · 现行覆盖率与逐项欠账清单

<!-- parity-signature: 35548a2652c9dd6371eb42fa041fe0759027fd62190e76c1762f24b64308c128 -->

> **生成物 · 禁手改**：由 `scripts/gen_parity_matrix.py` 写出；`check_parity.py` 用此签名做矩阵 / 视图 / 冻结面三方一致校验。
> **上游事实源**：npm `quasar@2.35.5` `dist/api/*.json`（`upstream/manifest-2.35.5.json`）；**Nova 事实源**：`nova-api-1.11.0.json`（147 类型）。
> **关系口径**：Inspired by Quasar (MIT) · 只用公开 API 元数据 · 不复制源码、不构成 fork / port。
> **口径纪律**：`docs/PARITY.md` 是历史审计史料（不删、不回改）；本页是**现行机读视图**，与 `ECOSYSTEM_PARITY.md` 的历史评分无继承关系。

## 1. 全量面总览（脚本计数，非估算）

| 指标 | 值 |
|---|---|
| 上游条目 | **156**（component 123 / directive 13 / plugin 20） |
| 与冻结面自动同名映射 | **103** |
| 逐项展开成员项 | **1932** |
| 未逐项展开（无 Nova 对应类型，组件级带里程碑） | **400** |
| 零悬空率 | **100.00%**（悬空 0） |
| 适用项（扣除 N/A / 元数据） | **1715** |

### 1.1 三层口径覆盖率（口径见 `parity/scope.json::coverage_definitions`）

| 档 | 定义 | 全量面 | P0 集 |
|---|---|---|---|
| 字面 literal | ALIGNED / 适用项 | **2.62%** | **8.04%** |
| 可解释 explainable | (ALIGNED+MAPPED+N/A) / 全量项（GAP 不计入） | **55.38%** | **56.44%** |
| 机检固化 test_frozen | 带真实 PASS `test_id` 的 ALIGNED / 适用项（独立计） | **2.62%** | **8.04%** |

> **验收红线（2026-11-28 12:35 CSA 采纳 A 类）**：三层必须并列呈现，禁止只报可解释率；**GAP = 保守下界**（语义等价但未登记映射的项暂落 GAP），提升只能靠**补登记 + 补机检**，不许改判五态放宽口径；**机检固化独立计**，MAPPED / N/A 无对应机检用例不计入。详见 `proposals/SPEC_COMPONENT_PARITY_MEASURES.md` §2 / §3。

> **不圆场**：GAP 不算「可解释」。P1 是诊断期，覆盖率是**真实诊断输出**，不是凑数指标；把阈值提到 100% 属 P2/P3 封版门禁（届时 GAP 清零才达标）。

### 1.2 逐项五态分布

| 状态 | 数量 | 含义 |
|---|---|---|
| `ALIGNED` | 45 | 有机检固化（`test_id` 真实存在） |
| `MAPPED` | 808 | 语义承接（同名或改名），可解释但未固化 |
| `N/A` | 217 | 带理由码的合法不适用 |
| `GAP` | 862 | 真实缺口，带优先级 + 里程碑 |
| `ENHANCEMENT` | 0 | Nova 增强（登记不混入 ALIGNED） |

## 2. P0 组件集全表审计（12 个旗舰配对 · CSA 09:13 授权依磁盘事实核定）

P0 集口径见 `parity/scope.json::p0_pairs`（**CSA 2026-11-28 09:13 授权「按磁盘事实定」、小诺逐条核验 12/12 后固化；标准级口径已确认**）。逐项 613 项 · 适用 560 项 · **真实 GAP 267 项**。

| Nova 类型 | 上游 | 逐项 | ALIGNED | MAPPED | N/A | GAP | 可解释 | 机检固化 |
|---|---|---|---|---|---|---|---|---|
| `Nova.Services.NovaDialog` | `Dialog.json` | 2 | 0 | 0 | 1 | 1 | 50.0% | 0.0% |
| `Nova.Services.NovaLoading` | `Loading.json` | 8 | 0 | 3 | 4 | 1 | 87.5% | 0.0% |
| `Nova.Controls.NovaBtn` | `QBtn.json` | 38 | 0 | 9 | 6 | 23 | 39.5% | 0.0% |
| `Nova.Controls.NovaCarousel` | `QCarousel.json` | 43 | 0 | 24 | 2 | 17 | 60.5% | 0.0% |
| `Nova.Controls.NovaField` | `QField.json` | 57 | 0 | 41 | 2 | 14 | 75.4% | 0.0% |
| `Nova.Controls.NovaInput` | `QInput.json` | 69 | 0 | 10 | 4 | 55 | 20.3% | 0.0% |
| `Nova.Controls.NovaMenu` | `QMenu.json` | 39 | 0 | 25 | 3 | 11 | 71.8% | 0.0% |
| `Nova.Controls.NovaSelect` | `QSelect.json` | 144 | 0 | 24 | 10 | 110 | 23.6% | 0.0% |
| `Nova.Controls.NovaSlider` | `QSlider.json` | 41 | 0 | 25 | 2 | 14 | 65.9% | 0.0% |
| `Nova.Controls.NovaStepper` | `QStepper.json` | 36 | 0 | 27 | 2 | 7 | 80.6% | 0.0% |
| `Nova.Controls.NovaTable` | `QTable.json` | 114 | 45 | 41 | 14 | 14 | 87.7% | 45.0% |
| `Nova.Controls.NovaTabs` | `QTabs.json` | 22 | 0 | 19 | 3 | 0 | 100.0% | 0.0% |

### 2.1 P0 集逐条磁盘证据（CSA 09:13 授权核定 · 脚本计数，非估算）

> 各条 `disk_evidence` 与 `upstream/manifest-2.35.5.json` / `parity/matrix.json` / 冻结面同源，由 `tests/test_parity_matrix.py` 反查现盘复验；`selection_basis` 里的数字是 `docs/PARITY.md` 历史审计节口径，与 pinned npm `dist/api` 发布面**并列保留、不圆场**（见 §3）。

| Nova 类型 | 上游 | 类型 | pinned 面 props/slots/events/methods | 逐项 / 五态 | 冻结面 props/signals/methods | 审计法源 | 机检绑定 |
|---|---|---|---|---|---|---|---|
| `Nova.Controls.NovaBtn` | `QBtn.json` | component | 34/2/1/1 | 38 · GAP 23 · MAPPED 9 · N/A 6 | 13/3/2 | NovaBtn ← QBtn（审计 0.3.0） | tests/test_smoke.py 冒烟（无成员级全表机检） |
| `Nova.Controls.NovaField` | `QField.json` | component | 38/11/4/4 | 57 · GAP 14 · MAPPED 41 · N/A 2 | 41/2/4 | NovaField ↔ QField（use-field 29 + use-validate 7 props） | tests/test_smoke.py 冒烟（无成员级全表机检） |
| `Nova.Controls.NovaInput` | `QInput.json` | component | 49/10/4/6 | 69 · GAP 55 · MAPPED 10 · N/A 4 | 10/2/1 | NovaInput ↔ QInput（8 props） | tests/test_smoke.py 冒烟（无成员级全表机检） |
| `Nova.Controls.NovaSelect` | `QSelect.json` | component | 92/16/13/23 | 144 · GAP 110 · MAPPED 24 · N/A 10 | 18/3/3 | NovaSelect ↔ QSelect（47 props，收口 24） | tests/test_smoke.py 冒烟（无成员级全表机检） |
| `Nova.Controls.NovaSlider` | `QSlider.json` | component | 36/2/3/0 | 41 · GAP 14 · MAPPED 25 · N/A 2 | 35/2/3 | NovaSlider ↔ QSlider（use-slider 33 + label-value/model-value） | tests/test_smoke.py 冒烟（无成员级全表机检） |
| `Nova.Controls.NovaTable` | `QTable.json` | component | 65/21/11/17 | 114 · ALIGNED 45 · GAP 14 · MAPPED 41 · N/A 14 | 110/18/26 | §14 T28 全映射表（21 slots / 15 methods / 9 events） | tests/test_nova_table.py 23 项（21 slots / 15 methods / 9 events 专项） |
| `Nova.Controls.NovaMenu` | `QMenu.json` | component | 27/1/6/5 | 39 · GAP 11 · MAPPED 25 · N/A 3 | 22/6/7 | NovaMenu ↔ QMenu（34 props + 6 events + 5 methods + 1 slot） | tests/test_smoke.py 冒烟（无成员级全表机检） |
| `Nova.Services.NovaDialog` | `Dialog.json` | plugin | 0/0/0/1 | 2 · GAP 1 · N/A 1 | 5/0/6 | NovaDialog ← Dialog 插件（审计 0.6.1，npm 2.35.5 dist/api/Dialog.json 逐项核实 · 27 项） | tests/test_smoke.py 冒烟（无成员级全表机检） |
| `Nova.Services.NovaLoading` | `Loading.json` | plugin | 1/0/0/3 | 8 · GAP 1 · MAPPED 3 · N/A 4 | 10/0/10 | NovaLoading ← Loading 插件（审计 0.6.2，npm 2.35.5 dist/api/Loading.json 逐项核实 · 11 项） | tests/test_smoke.py 冒烟（无成员级全表机检） |
| `Nova.Controls.NovaTabs` | `QTabs.json` | component | 20/1/1/0 | 22 · MAPPED 19 · N/A 3 | 24/1/3 | NovaTabs ↔ QTabs（15 props + 1 event + 1 slot） | tests/test_smoke.py 冒烟（无成员级全表机检） |
| `Nova.Controls.NovaStepper` | `QStepper.json` | component | 27/3/3/3 | 36 · GAP 7 · MAPPED 27 · N/A 2 | 30/3/5 | NovaStepper ↔ QStepper（26 props + 2 events + 3 methods + 3 slots） | tests/test_smoke.py 冒烟（无成员级全表机检） |
| `Nova.Controls.NovaCarousel` | `QCarousel.json` | component | 29/3/5/6 | 43 · GAP 17 · MAPPED 24 · N/A 2 | 27/3/3 | NovaCarousel ↔ QCarousel（31 props + 5 events + 7 methods + 3 slots） | tests/test_smoke.py 冒烟（无成员级全表机检） |

### 2.2 P0 集逐项欠账清单（真实 GAP，按上游条目聚合）

| 上游 | Nova | facet | 成员 | 优先级 | 里程碑 |
|---|---|---|---|---|---|
| `Dialog.json` | `Nova.Services.NovaDialog` | methods | `create` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `Loading.json` | `Nova.Services.NovaLoading` | props | `isActive` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `type` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `label` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `outline` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `flat` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `unelevated` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `rounded` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `push` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `square` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `glossy` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `fab` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `fab-mini` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `padding` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `text-color` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `no-caps` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `no-wrap` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `ripple` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `align` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `stack` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `stretch` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `percentage` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | props | `dark-percentage` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | events | `click` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QBtn.json` | `Nova.Controls.NovaBtn` | methods | `click` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `fullscreen` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `keep-alive` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `keep-alive-include` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `keep-alive-exclude` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `keep-alive-max` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `transition-prev` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `transition-next` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `height` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `control-color` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `control-type` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | props | `navigation-active-icon` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | slots | `control` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | events | `fullscreen` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | events | `update:fullscreen` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | methods | `toggleFullscreen` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | methods | `setFullscreen` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QCarousel.json` | `Nova.Controls.NovaCarousel` | methods | `exitFullscreen` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | props | `item-aligned` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | props | `maxlength` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | props | `tag` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | slots | `prepend` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | slots | `append` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | slots | `before` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | slots | `after` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | slots | `control` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | events | `update:model-value` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | events | `focus` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | events | `blur` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | events | `clear` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | methods | `focus` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QField.json` | `Nova.Controls.NovaField` | methods | `blur` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `name` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `mask` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `fill-mask` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `reverse-fill-mask` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `unmasked-value` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `mask-tokens` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `error` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `error-message` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `no-error-icon` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `rules` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `reactive-rules` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `lazy-rules` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `label` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `stack-label` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `hint` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `hide-hint` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `prefix` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `suffix` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `loading` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `clearable` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `clear-icon` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `filled` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `outlined` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| `QInput.json` | `Nova.Controls.NovaInput` | props | `borderless` | P1 | P2 · P0 集欠账清零（封版门禁前置） |
| … | | | 其余 187 项见 `parity/matrix.json::p0_gaps` | | |

## 3. 法源口径差异登记（不圆场、并列保留）

| 项 | T28 / `PARITY.md` 史料 | 本页（pinned npm `dist/api` 2.35.5） |
|---|---|---|
| QTable props | 63 | **65** |
| QTable slots | 21 | **21**（一致） |
| QTable events | 9 | **11**（多 `fullscreen` / `update:fullscreen`） |
| QTable methods | 15 | **17**（多 `setFullscreen` / `exitFullscreen`） |
| QTable 分母 | 63+21+9+15+15 列元字段 = **123** | 65+21+11+17 = **114**（`computedProps` 3 单列） |
| QSelect props | 47（`PARITY.md §0.9` 收口 24） | **92**（聚合 mixin 后的完整发布面） |

> **两个法源，不是谁错了**：`PARITY.md` 各 Sprint 与 T28 用的是 GitHub `dev` 分支 `ui/src/components/*/*.json`（**组件自身定义**）；本页用 npm `dist/api/*.json`（**聚合 use-field / use-form / use-virtual-scroll 等 mixin 后的完整发布面**）。QSelect 47 → 92 的落差正说明历史审计面对的是更小的面，因此本页的 GAP 多为真实缺口，而非误判。按史料不圆场：T28 的 123/123 结论与 `PARITY.md` 各节计数逐字保留、不回改，本页另给 pinned 发布面的真实数字。`scope.json::test_bindings` 只绑定 T28 真实断言过的 21 slots / 15 methods / 9 events，多出的 4 项**不虚绑**。

## 4. 门禁口径

| 类别 | 项 |
|---|---|
| 阻断 | zero_orphan_rate == 100%（含 GAP 带 priority + milestone） |
| 阻断 | matrix.json 签名 / docs/PARITY_MATRIX.md 签名 / 冻结面三方一致 |
| 阻断 | 所有 test_id 真实存在于 tests/*.py（法源链不留悬空） |
| 阻断 | 每条 ALIGNED 必须带至少一个 test_id |
| 阻断 | P0 集条数 = scope.json::p0_pair_count，且每条配对须通过磁盘事实核验（上游 dist/api JSON / 冻结面全限定类型 / 逐项审计法源，见各条 disk_evidence） |
| 阻断 | 上游缓存 156 文件 sha256 与 manifest 一致 |
| 仅报告（不阻断） | 三档覆盖率 |
| 仅报告（不阻断） | P0 集可解释率 |
| 仅报告（不阻断） | 机检固化率 |
| 仅报告（不阻断） | 逐项 GAP 欠账清单 |

> P1 是诊断期：目标是把「完整度不够」变成可机读的真实数字与逐项欠账清单，而不是把 GAP 算成可解释来凑 100%。把覆盖率阈值提到 100% 属 P2/P3 封版门禁，届时 GAP 清零才达标。
> 下一步：P2 引入 parity/baseline.json 棘轮基线（覆盖率只升不降）；P3 把 test_frozen_coverage 阈值提到封版目标。

## 5. 未竟事项（如实登记）

- **P2**（09:37 已「先列出」）：全生态 L0~L6 广度台账见 `docs/PARITY_BREADTH.md`（156 条逐条归属 + 批次建议 + 面外层清单）；**完现待办**：逐条归属判定 / `parity/baseline.json` 棘轮基线 / 站点 dashboard / 门禁阈值提升，须 CSA 立项。
- **P3 / D3**：跟进节奏已于 09:37 核定（三档：T1 交付前离线硬门 + T2 每周在线周巡 + T3 阻断类事件即时响应），见 `docs/PARITY_CADENCE.md` + `upstream/cadence.json`；`--online` 双源实现、`nova_mcp.py::check_updates` 升级与周期自动化仍属 P3 待立项，**准实时自动化不做**。
- **升 pin 独立议题**：`gen_upstream_baseline.py --apply` 源码级投影 + minor 重签；CSA D4 下 `pinned` 保持 2.35.5。
- **机检固化率偏低是真实欠账**：库内仅 `NovaTable` 有成员级全表机检（`test_nova_table.py` 23 项），其余 P0 组件主要靠 `test_smoke.py` 冒烟；这一数字正是本议题「完整度不够」的量化答案，不以调整口径掩盖。
- **GAP 是保守下界，不等于功能缺口数**：当前矩阵只机读化「同名 / `scope.json` 已登记别名 / 明确 N/A 理由码」三类判定。`variant` 承接 `square` / `rounded` / `flat`、主题令牌承接 `*-color` 等**语义等价但尚未登记映射**的项暂落 GAP。P2 逐层人工审计收敛后，可解释率只会因补登记而上升，不会靠放宽口径上升。

---

*签名 `35548a2652c9dd6371eb42fa041fe0759027fd62190e76c1762f24b64308c128` · 由 `gen_parity_matrix.py` 生成，`check_parity.py` 校验。*
