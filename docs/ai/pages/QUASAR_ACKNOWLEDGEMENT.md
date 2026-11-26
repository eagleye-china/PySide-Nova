# pyside-nova 与 Quasar 的关系 · 致谢与定位文案

> **文档性质**：现行对外文案的**唯一事实源**（品牌层，非法源、非史料、非对账）· 供 README / 站点 / 演示 / 投稿统一引用
> **适用版本**：**1.2.0** · 冻结指纹 **`4f882374ad52262b`** · 文案口径与 API 冻结面无关，改文案不触发重签
> **口径（关系声明层）**：**Inspired by Quasar** —— 受启发、借鉴理念，**不是** Quasar 的 Python 衍生版、移植版或 fork
> **口径（品牌 tagline 层）**：**2026-11-26 16:37 CSA 新拍板「换回霸气比喻 + 把 QML 加上」，现行首屏见 §8**；§1 推荐版为 12:30 历史口径，按史料不圆场逐字保留。
> **法源链**：本文件只管「怎么说」；「怎么对齐」见 [`PARITY.md`](../../PARITY.md)（逐组件逐属性对账）与 [`GUIDE_QUASAR_ALIGNMENT.md`](../../prescript/GUIDE_QUASAR_ALIGNMENT.md)（工程化理念对齐）；「历史演进」见 [`ECOSYSTEM_PARITY.md`](../../ECOSYSTEM_PARITY.md)（历史档案，不代表当前）
> **品牌立意**：**「青，取之于蓝，而青于蓝」**（《荀子·劝学》）—— 受蓝（Quasar）启发，在 PySide 生态里生成更青的 Nova；典故是 Inspired by 的中文母题表达，详见 §3
> **状态**：**现行 · 2026-11-26 · 随 1.2.4 发布（CSA 17:17 拍板升版）**

---

## 0. 一句话结论

**pyside-nova is inspired by Quasar — not derived from it.**

Quasar 是 Vue 生态的组件框架；pyside-nova 是 **PySide6 / Qt Quick 生态**的独立组件库。二者共享的是**组件化理念与工程化手感**（令牌体系、断点、槽位、命令式服务、预判布局壳），**不共享代码、不共享仓库、不共享维护者、不构成 fork 关系**。

> 准确用词是 **Inspired by / 受启发**；`Derived from` / `移植` / `fork` / `surpasses its origin` 一律不用——前者说清来源与边界，后者会让人误以为是 Quasar 的 Python 衍生版。

---

## 1. 首屏文案（历史推荐版 · 准确、正式、不过度声称）

伙伴 2026-11-26 凝练，小诺校订。用于 README 首屏与官网首屏。

> ⚠️ **效力已被 §8 覆盖（2026-11-26 16:37 CSA 新拍板）**：本节为 12:30 口径的历史留痕，
> **不再作为现行首屏文案**；现行首屏一律按 **§8.3 定稿**。按「史料不圆场」铁律，原文逐字保留。

**English**

```markdown
# PySide-Nova

> Inspired by Quasar, PySide-Nova takes its component philosophy further in the PySide ecosystem.
> 受 Quasar 启发，PySide-Nova 在 PySide 生态中将其组件理念推进一步。

PySide-Nova is a component library for PySide, inspired by the Vue Quasar framework.
It borrows Quasar's component-driven ideas while adapting them to Python desktop
development — with a cleaner API, better ergonomics, and a maintainable foundation.

Inspired by Quasar, built for PySide.
```

**中文对照（用于 README_zh 首屏）**

```markdown
# pyside-nova

> 受 Quasar 启发，PySide-Nova 在 PySide 生态中将其组件理念推进一步。
> Inspired by Quasar, PySide-Nova takes its component philosophy further in the PySide ecosystem.

pyside-nova 是面向 PySide 的组件库，灵感来自 Vue 生态的 Quasar。它借鉴 Quasar 的组件驱动
理念，并针对 Python 桌面开发重新适配——更干净的 API、更顺手的开发体验、可长期维护的底座。

受 Quasar 启发，为 PySide 而生。
```

---

## 2. 短 banner（徽章 / 页脚 / 演示封面）

```markdown
> Inspired by Quasar, built for PySide.
> 受 Quasar 启发，为 PySide 而生。
```

---

## 3. 品牌立意母题：青出于蓝而胜于蓝（CSA 2026-11-26 澄清）

> **伙伴原意**：这份文案的真正用意，是引用《荀子·劝学》「青，取之于蓝，而青于蓝」的典故——
> **靛青从蓝草中提取，颜色却比蓝草更深**；引申为「受前人启发，在后来的生态里更进一步」。
> 不是把那句话当 slogan 贴上去，而是把它作为整份文案的**精神内核**。

### 3.1 典故与 Inspired by 的同构关系

| 典故层 | 文案层 | 事实层 |
|---|---|---|
| 蓝草（源） | Quasar · Inspired by | Vue 生态组件框架，MIT，本库理念来源 |
| 青（承） | PySide-Nova · takes its component philosophy further | PySide6 / Qt Quick 独立组件库，借鉴理念而重新适配 |
| 青于蓝（进） | cleaner API · better ergonomics · maintainable foundation | 令牌体系 / 预判布局壳 / 冻结门禁 / 60 张三态图 |

一句话：**「青出于蓝」= Inspired by 的中文母题，「胜于蓝」= takes its component philosophy further 的典故说法**。同义同源，不是两套口径。

### 3.2 用法分档（与 §4 禁用词表的边界）

| 场景 | 用法 |
|---|---|
| README / API / 技术文档首屏 | **§1 推荐版**（Inspired by … takes its component philosophy further）——准确、正式、克制 |
| 发布会 / 海报 / 社交封面 / 演讲 | **§3.3 典故版**（青出于蓝而胜于蓝）——品牌传播，允许文艺表达 |
| 对账表 / 法源 / a11y / 冻结面文档 | §1 推荐版；典故与「Nova 青」构想只作品牌叙事，不写进契约文本 |

> **与禁用词表不冲突**：§4 禁用 `surpasses its origin` / `超越原版`，因为它们处在「derived from（衍生）」框架里，会强化 fork 误读且做首屏价值判断；
> 「青出于蓝而胜于蓝」处在中国文化「传承中精进」的框架里，落点是「在新生态做得更适合」，不是「贬低源头」。**典故保留，衍生框架不用**。

### 3.3 典故版文案（品牌传播专用）

```markdown
> Drawing from Quasar, PySide-Nova is bluer than the indigo.
> 受 Quasar 启发，PySide-Nova 青出于蓝而胜于蓝。
```

> ⚠️ 边界：典故版仅用于明确的品牌传播场合；README 首屏与所有技术文档一律 §1 推荐版。

---

## 4. 措辞纪律（评审强制）

> ⚠️ **效力变更（2026-11-26 16:37）**：下表第 4 行 `The Quasar of Qt Quick`（首屏 tagline）
> 自 **§8** 起**仅在「品牌 tagline 层」解禁**——比喻句可用，关系声明层仍须 `Inspired by`；
> 其余 4 条仍是现行禁用表述。表格原文按「史料不圆场」保留，不回改。

| 禁用表述 | 为什么禁用 | 改为 |
|---|---|---|
| `Derived from Quasar` / `源自 Quasar` | 暗示派生 / 血缘关系 | `Inspired by Quasar` / `受 Quasar 启发` |
| `Quasar fork` / `Python port of Quasar` | 暗示同源仓库或移植版 | `a PySide component library inspired by Quasar` |
| `surpasses its origin` / `超越原版` | 首屏做价值判断，且强化"衍生"框架 | `takes its component philosophy further` / `将其组件理念推进一步` |
| `The Quasar of Qt Quick`（首屏 tagline） | 等同式比喻，易读成"Qt Quick 版的 Quasar" | §1 推荐版 banner |
| `ports that ecosystem`（叙事段落） | "搬运生态" 暗示整套移植 | `borrows ... ideas while adapting them to Python desktop development` |

**保留但精确限定的表述**：

- `Quasar-style API` / `QBtn → NovaBtn`：说的是**属性命名对齐**、降低学习成本，是事实，保留；但不能写成"1:1 移植 Quasar 代码"。
- `NovaScreen 1:1 对标 Quasar Screen 插件`：说的是**断点数值与 API 语义**对标（xs/sm/md/lg/xl = 600/1024/1440/1920），保留 "对标 / aligned with" 措辞，不用 "port / 移植"。
- `Quasar 2.35.5 对标基线`：见 README 现状速览表，是**对账基线**不是版本血缘，保留。

---

## 5. 为什么这样定（不将就 · 准确优先）

1. **法律与品牌边界**：Quasar 是 MIT 许可的独立项目；pyside-nova 同样 MIT，但**没有代码复用、没有上游仓库关系**。`Derived from` 在开源语境会被读成 derivative work，属于不实陈述。
2. **准确第一**：伙伴原话——"真实情况是受 Quasar 启发，不是代码层面的 derived from"，首屏"准确、正式、不过度声称超越"。
3. **借鉴而非模仿**：`takes its component philosophy further` 的宾语是 **philosophy（理念）**，落在"自己做、做得更适合 PySide"；`surpasses its origin` 的宾语是 **origin（源头）**，落在"比较与超越"，既不准确也无必要。
4. **典故即立意**：「青出于蓝而胜于蓝」出自《荀子·劝学》，本义是靛青取自蓝草而色更深，比喻受启发者在新的生态里更进一步——与本库 `takes its component philosophy further` 完全同构。把它确立为品牌母题（§3），既满足 CSA 引用典故的用意，又不与 §1 的克制首屏或 §4 的禁用词冲突。
5. **不圆场**：本轮之前 README 首屏用的是更强的 `The Quasar of the Qt Quick world` / `ports that ecosystem`。按史料不圆场铁律，这里**不回改历史文档中的旧表述**，只在现行首屏与本文档统一为 Inspired by 口径；旧表述若在史料中出现，保留原样。

---

## 6. 应用记录（本轮落地）

| 位置 | 改动 |
|---|---|
| `README.md` 首屏 | tagline `The Quasar of the Qt Quick world` → §1 推荐版 banner；`ports that ecosystem` → `borrows ... adapting them to Python desktop development` |
| `README_zh.md` 首屏 | `Qt Quick 世界的 Quasar` → §1 中文推荐版 banner；`把这套生态搬到` → `借鉴理念并重新适配` |
| 本文件 | 新建，作为文案唯一事实源 |
| `mkdocs.yml` | nav「对账」分组新增本文件条目 |
| `scripts/gen_apidocs.py` | `PAGES` 清单新增本文件，随 AI 包离线拷贝 |

> 生成物纪律：本文件是**手写文案事实源**；`docs/ai/pages/` 下的同名拷贝是 `gen_apidocs.py` 生成物，禁止手改，只重跑生成器。

---

## 7. 封版声明（CARF）

- **C 构想**：CSA 指出"真实情况是受启发，不是 derived from"，要求把 `Derived from → Inspired by`、`surpasses its origin → takes its component philosophy further`，凝练三版文案并整理为 md、放合适位置、为我所用。
- **A 实现**：`docs/QUASAR_ACKNOWLEDGEMENT.md` 落盘（文案唯一事实源）；README 中英首屏按推荐版对齐；nav / AI 包拷贝清单登记。
- **R 打磨**：三版文案分级（首屏 / banner / 文艺），禁用词表 5 条 + 保留但限定 3 条，四条例证支撑口径。
- **F 封版**：**零 QML 改动 · 零 API 改动 · 零冻结面改动 · 零模块 URI 改动**；文案口径与代码事实分离，不夸大成熟度、不暗示 fork。

> **发布边界**：本轮全部改动留工作树未提交，`commit / push / tag / PyPI / 站点上线` **全归 CSA**。

---

## 8. 品牌 tagline 口径改判（CSA 2026-11-26 16:37 拍板 · **现行**）

> **触发**：CSA 贴 PyPI 1.2.3 页面截图，指出首屏 `Inspired by Quasar, PySide-Nova takes its component philosophy further…`
> **「不够霸气」**，指令「**还换回 PySide-Nova 是 Qt Quick 世界的 Quasar，但需要把 QML 加上，
> 因为大家可能对 QML 更熟悉**」，并问「加在哪儿合适？」。
> **小诺建议 / CSA 拍板**：三案取 **A 案 —— QML 进主标语本体，Qt Quick 退到紧随其后的技术定位行，
> `Inspired by` 降为致谢行**。
> **效力**：本节**覆盖** §1 推荐版与 §4 禁用表第 4 行「`The Quasar of Qt Quick` 禁作首屏 tagline」；
> §1 / §4 / §5 / §6 / §7 原文按「史料不圆场」逐字保留，仅在此登记效力变更，法源链不留悬空引用。

### 8.1 三层分工（既要霸气、又要准确）

| 层 | 作用 | 现行文案 | 约束 |
|---|---|---|---|
| **品牌 tagline 层** | 第一眼的气势与品类认知 | `PySide-Nova is the Quasar of the QML world.` / `PySide-Nova，QML 世界的 Quasar。` | 等比**比喻句**，允许；`QML` 为主词（大众最熟、最好搜） |
| **技术定位层** | 说清底层框架与宿主 | `An enterprise-grade, cross-platform Qt Quick component library for PySide6.` | `Qt Quick` 在此保留，不丢技术底座；不塞进主句以免括注削弱气势 |
| **关系声明层** | 说清与 Quasar 的真实关系 | `Inspired by Quasar · Built on Qt Quick for PySide6.` / `受 Quasar 启发 · 基于 Qt Quick，为 PySide6 而生。` | **仍守 §0 口径**：`Derived from` / `fork` / `port` / `源自` 一律禁用；致谢不删 |

> 三层互不污染：**品牌层用比喻，关系层不松口**。§0「pyside-nova is inspired by Quasar — not derived from it」
> 仍是全部技术文档 / 对账表 / 法源正文的事实陈述，tagline 不得被引用为关系证据。

### 8.2 QML 加在哪儿（CSA 问句的答案）

**加在主标语本体**：用 `QML world` 取代旧句的 `Qt Quick world`，`Qt Quick` 移到下一行技术定位语。三条理由：

1. **认知优先**：目标读者对 `QML` 的熟悉度远高于 `Qt Quick`；主标语第一眼出现 QML 才真正解决「大家可能对 QML 更熟悉」的顾虑——放副行等于没加。
2. **气势不打折**：`the Quasar of the QML world` 是干净的等比比喻；若写 `QML & Qt Quick world` 或 `QML (Qt Quick) world`，主句被并列/括注拖长，霸气被稀释（B / C 案落选原因）。
3. **一词不丢 + 合规不破**：Qt Quick 仍在首屏技术定位行，Inspired by 仍在致谢行与 §0 关系声明；改的是**措辞层**，不是**事实层**。

### 8.3 现行定稿文案

**English（`README.md` 首屏 / 官网首屏）**

````markdown
> **PySide-Nova is the Quasar of the QML world.**
> **PySide-Nova，QML 世界的 Quasar。**

**An enterprise-grade, cross-platform Qt Quick component library for PySide6.**
*Inspired by Quasar · Built on Qt Quick for PySide6.*
````

**中文（`README_zh.md` 首屏）**

````markdown
> **PySide-Nova，QML 世界的 Quasar。**
> **PySide-Nova is the Quasar of the QML world.**

**面向 PySide6 的企业级全端 Qt Quick 组件库。**
*受 Quasar 启发 · 基于 Qt Quick，为 PySide6 而生。*
````

**PyPI `description`（`pyproject.toml`）**

````text
PySide-Nova is the Quasar of the QML world — an enterprise-grade Qt Quick component library for PySide6.
````

**站点首页（`docs/index.md`）**：徽标下方副标题 `PySide-Nova，QML 世界的 Quasar。` /
`受 Quasar 启发 · 基于 Qt Quick，为 PySide6 而生`。

### 8.4 边界与发布

- **零 QML / 零 API / 零冻结面改动**：本轮纯文案层，144 类型 · 指纹 `4f882374ad52262b` 不变，不触发重签。
- **PyPI 已发布的 1.2.3 元数据不可原地改**：`description` 变更**随 1.2.4 重新发行**才会在 PyPI 页面生效
  （CSA 2026-11-26 17:17 拍板升版）；`commit / tag / push / PyPI / 站点上线` 全归 CSA。
- **§3 典故版仍有效**：「青出于蓝而胜于蓝」品牌母题与本节霸气 tagline 不冲突——前者用于发布会 / 海报 / 演讲，后者用于首屏。
- **§4 其余 4 条禁用表述继续生效**；`The Quasar of Qt Quick` 一条仅在品牌 tagline 层解禁，
  技术文档 / 对账表 / 法源正文**不得**用等同式比喻陈述事实关系。

### 8.5 CARF

- **C 构想**：CSA 定方向——「不够霸气，换回，QML 加上」，授权小诺定位置。
- **A 实现**：三案评估 → A 案落地；双语 README / PyPI `description` / 站点首页 / 本文件四处同步，
  AI 包离线拷贝随 `gen_apidocs.py` 重跑同步（生成物禁手改）。
- **R 打磨**：法源以**追加覆盖章节**处理而非回改史料；§1 / §4 加效力指针，§5 / §6 / §7 原文保留；
  顺带校准 `playground.js` 面板提示的旧冻结面口径 `1.0.0 → 1.2.0`（账实不符必校准）。
- **F 封版**：文案与代码事实分离，冻结面零漂移；**随 1.2.4 发布，发布归 CSA**。
