# pyside-nova 与 Quasar 的关系 · 致谢与定位文案

> **文档性质**：现行对外文案的**唯一事实源**（品牌层，非法源、非史料、非对账）· 供 README / 站点 / 演示 / 投稿统一引用
> **适用版本**：**1.2.0** · 冻结指纹 **`4f882374ad52262b`** · 文案口径与 API 冻结面无关，改文案不触发重签
> **口径**：**Inspired by Quasar** —— 受启发、借鉴理念，**不是** Quasar 的 Python 衍生版、移植版或 fork
> **法源链**：本文件只管「怎么说」；「怎么对齐」见 [`PARITY.md`](../../PARITY.md)（逐组件逐属性对账）与 [`GUIDE_QUASAR_ALIGNMENT.md`](../../prescript/GUIDE_QUASAR_ALIGNMENT.md)（工程化理念对齐）；「历史演进」见 [`ECOSYSTEM_PARITY.md`](../../ECOSYSTEM_PARITY.md)（历史档案，不代表当前）
> **品牌立意**：**「青，取之于蓝，而青于蓝」**（《荀子·劝学》）—— 受蓝（Quasar）启发，在 PySide 生态里生成更青的 Nova；典故是 Inspired by 的中文母题表达，详见 §3
> **状态**：**现行 · 2026-11-26 · 待 CSA 随 1.2.0 发布**

---

## 0. 一句话结论

**pyside-nova is inspired by Quasar — not derived from it.**

Quasar 是 Vue 生态的组件框架；pyside-nova 是 **PySide6 / Qt Quick 生态**的独立组件库。二者共享的是**组件化理念与工程化手感**（令牌体系、断点、槽位、命令式服务、预判布局壳），**不共享代码、不共享仓库、不共享维护者、不构成 fork 关系**。

> 准确用词是 **Inspired by / 受启发**；`Derived from` / `移植` / `fork` / `surpasses its origin` 一律不用——前者说清来源与边界，后者会让人误以为是 Quasar 的 Python 衍生版。

---

## 1. 首屏文案（推荐版 · 准确、正式、不过度声称）

伙伴 2026-11-26 凝练，小诺校订。用于 README 首屏与官网首屏。

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
