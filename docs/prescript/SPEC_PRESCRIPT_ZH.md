# 预构范式（Prescript）企业级旗舰版封版方案（FINAL）

## 1. 封版结论

**中文定名：预构范式**  
**英文定名：Prescript**  
**关系：中英对仗，一体封版，作为面向 Prescient Layout Shell（预判布局壳）的编程范式正式术语，进入白皮书、CLI、注释规范、工程规范与 CARF 体系。**

封版冻结五项：

1. **中英术语冻结**：中文名 **预构范式**，英文名 **Prescript**，二者一一对仗，不再使用"预制壳编程范式"作为正式中文名。
2. **定义冻结**：采用下方标准定义文案。
3. **CLI 命名空间冻结**：`pyside-nova prescript <verb>`。
4. **口号冻结**：中英双标语见第 11 节。
5. **禁用别名冻结**：预叙范式、预契范式、预述范式、Preshell、Prescribe、Prescode 均不作正式主术语。

> 封版状态：**FINAL / Enterprise Flagship Edition**  
> 术语版本：**Prescript Terminology Freeze v1.0（中英对仗封版）**

---

## 2. 三层概念体系定稿（中英对仗版）

| 层级 | 中文正式名 | 英文正式名 | 定位 | 不得混淆 |
|---|---|---|---|---|
| 组件载体 | **预判布局壳** | **Prescient Layout Shell** | 预置业务槽位与布局骨架的壳载体 | 不是编程范式本身 |
| 开发范式 | **预构范式** | **Prescript** | 面向预判布局壳的编程方法论 | 不是 Shell 组件名 |
| 品质流水线 | **CARF 品质流水线** | **CARF** | 构想·实现·打磨·封版 | 不是开发范式 |

一句话关系：

> **以预构范式（Prescript）编写预判布局壳（Prescient Layout Shell），经 CARF 验收封版。**

---

## 3. 术语命名理据（白皮书收录版）

> **预构范式（Prescript）**  
> - **"预"**：承自 Prescient，指预判、预置、预先构筑，与"预判布局壳"同源。  
> - **"构"**：指构筑、架构、布局搭建，直指 Layout Shell 的骨架本质，工业/企业语境力度足。  
> - **"范式"**：明示这是编程层面的方法论，不是语法糖，不是模板文件，是一套开发思想。  
> - **英文 Prescript**：词根 `Prescient（预判预置）+ Script（规约、描述、编码）`，与中文"预构"一一对仗。

**对仗关系铁律**：

> **预判布局壳** 讲**骨架载体**；**预构范式** 讲**开发方式**。  
> 一个"判"，一个"构"，动词对仗工整，中英同源同构，构成完整术语对。

---

## 4. 白皮书标准定义文案（可直接复制）

### 4.1 一句定义

> **预构范式（Prescript）是 PySide-Nova 独创的 GUI 开发范式，以预判布局壳为核心载体，遵循统一槽位契约，开发者仅注入业务内容，复用预先构筑好的跨端自适应骨架，快速产出符合四性标准的企业级界面。**

### 4.2 段落定义

> **预构范式（Prescript）**  
> 预构范式（Prescript）是 PySide-Nova 独创的 GUI 开发范式，专门面向预判布局壳（Prescient Layout Shell）。开发者不再从零堆砌基础控件，而是遵循壳的契约与槽位规范，向预判布局壳注入业务内容，复用预先构筑好的跨端自适应骨架，快速搭建符合四性标准的企业级界面。预构范式对标 Quasar 的模板式开发思想，但进一步强调"预判槽位 + 契约注入 + CARF 封版"的工程闭环，并依托 Qt/QML 实现桌面、移动、工业大屏的统一编排。

### 4.3 术语卡定义

> **预构范式（Prescript）**：面向预判布局壳的编程范式。  
> **核心动作**：遵循契约，向槽位注入业务。  
> **核心价值**：不从零堆控件，按预判骨架快速编排。  
> **配套体系**：预判布局壳为载体，CARF 为品质流水线。  
> **命名对仗**：Prescient Layout Shell · 预判布局壳 ｜ Prescript · 预构范式。

---

## 5. 词形、大小写与用法规范

| 场景 | 规范写法 | 说明 |
|---|---|---|
| 正式术语/标题（中文） | **预构范式** | 四字专名，不加引号，不拆分 |
| 正式术语/标题（中英并写） | **预构范式（Prescript）** | 首次出现用此格式 |
| 正式术语/标题（英文） | **Prescript** | 首字母大写，作为范式专名 |
| CLI 子命令 | `prescript` | 全小写，作为命令命名空间 |
| 代码标识符/配置键 | `prescript` | 全小写 |
| 环境变量前缀 | `PRESCRIPT_*` | 全大写 |
| 注释标签 | `@prescript` | 固定标签 |
| 形容词场景 | `Prescript-native` / `预构原生` | 表示"预构范式原生"，不随意造动词变形 |

**用法铁律**：

- 写"**预构范式**"，不写"预构"单用作为范式名；"预构"作为动词仅在解释性文字中使用。
- 写"**Prescript 编程范式**"，不写"prescript 编程范式"。
- 写 `pyside-nova prescript dev`，不写 `pyside-nova Prescript dev`。
- 中英并写时用全角括号：**预构范式（Prescript）**。

**禁用为主术语**：预叙范式、预契范式、预述范式、Preshell、Prescribe、Prescode。  
可作为历史讨论别名，但不得进入白皮书、CLI、规范文档正文。

---

## 6. 预构范式四条原则

1. **壳先于页**：先选预判布局壳，再注入业务，不从零堆控件。  
2. **槽位即边界**：业务只进入声明槽位，不穿透壳骨架。  
3. **契约即接口**：槽位、数据、事件、样式均以契约为准。  
4. **封版即交付**：预构范式产物必须经 CARF 流水线验收后封版。

---

## 7. CLI 冻结规范

统一命名空间：

```bash
pyside-nova prescript <verb>
```

旗舰版冻结命令：

```bash
pyside-nova prescript init       # 初始化预构工程/壳契约
pyside-nova prescript dev        # 预构范式开发态运行
pyside-nova prescript compile    # 预构范式产物编译
pyside-nova prescript validate   # 契约、槽位、注释与 CARF 门禁校验
```

CARF 配套命令保持独立命名空间：

```bash
pyside-nova carf conceive
pyside-nova carf achieve
pyside-nova carf refine
pyside-nova carf freeze
```

**边界铁律**：`prescript` 管开发范式，`carf` 管品质封版；不得互相吞并命令语义。

---

## 8. 注释与契约标签规范

推荐最小注释标签集：

```python
# @prescript
# @shell: PrescientLayoutShell
# @slot: main.content
# @contract: prescript.contract.yaml
# @carf: freeze-gate
```

规范要求：

- `@prescript`：标识该文件/模块遵循预构范式。  
- `@shell`：声明所依托的预判布局壳。  
- `@slot`：声明业务注入槽位。  
- `@contract`：声明契约文件。  
- `@carf`：声明对应 CARF 门禁或封版阶段。  

注释只做可追溯标记，不承载业务逻辑。

工程落地建议：契约文件统一为 `prescript.contract.yaml`，壳清单建议为 `prescient.shell.yaml`。此两项为工程建议，术语冻结核心仍是预构范式（Prescript）。

---

## 9. 规范文档目录定稿

```text
00-terminology.md        # 预构范式术语与中英对仗封版声明
01-principles.md         # 预构范式四条原则
02-shell-slot-contract.md# 预判布局壳槽位与契约规范
03-cli-spec.md           # pyside-nova prescript CLI 规范
04-annotation-spec.md    # @prescript 注释标签规范
05-carf-gate.md          # 预构范式与 CARF 门禁映射
06-migration-guide.md    # 旧写法迁移到预构范式
07-reference.md          # 示例、反例、验收清单
```

---

## 10. 与 CARF 的配套映射

| 预构范式阶段 | CARF 对应 | 封版含义 |
|---|---|---|
| 壳选择与槽位规划 | Conceive（构想） | 预判骨架与业务槽位构思 |
| 契约编写与业务注入 | Achieve（实现） | 按契约完成预构编排 |
| 槽位校验与样式收敛 | Refine（打磨） | 修正越界、契约偏差与全端一致性 |
| validate 通过并冻结 | Freeze（封版） | 预构范式产物封版交付 |

标准闭环：

> **预构范式编写 → validate 校验 → CARF Freeze 封版。**

中英对齐：

> **Prescript 编排 → validate → CARF Freeze。**

---

## 11. 中英双标语定稿

**正式对仗标语（白皮书 / 规范文档 / PPT 首页）**：

> **Prescript · 预构范式**  
> **Prescient Shell · 预判布局壳**

**完整交付标语（正式对外版本）**：

> **Prescript on Prescient Shell, validated by CARF.**  
> **以预构范式编写预判布局壳，经 CARF 验收封版。**

**短 Slogan（宣讲 / 幻灯片 / 页脚）**：

> **预构范式，壳上编排；CARF 筑基，全端共生。**

> 使用规则：白皮书正文用完整交付标语；PPT 首页用对仗标语；宣讲页脚用短 Slogan。三层标语不得混用场景。

---

## 12. 对标 Quasar 的正式表述

> 预构范式（Prescript）借鉴 Quasar 的模板式开发思想，但并非模板复制。预构范式以预判布局壳为预判载体，以槽位和契约为注入边界，并以 CARF 形成品质封版闭环，面向 Qt/QML 的桌面、移动、工业大屏统一编排。

---

## 13. 封版验收清单

- [ ] 白皮书中文正式名统一为 **预构范式**，英文正式名统一为 **Prescript**。  
- [ ] 中英首次出现采用 **预构范式（Prescript）** 格式。  
- [ ] CLI 仅使用 `pyside-nova prescript <verb>` 命名空间。  
- [ ] 注释统一使用 `@prescript` 标签。  
- [ ] 文档明确三层关系：预判布局壳 / 预构范式 / CARF 流水线。  
- [ ] 中英对仗标语、完整交付标语、短 Slogan 各归其位。  
- [ ] 禁用预叙范式、预契范式、预述范式、Preshell、Prescribe、Prescode 作为主术语。  
- [ ] 命名理据（"预"承 Prescient，"构"指构筑骨架）已收录白皮书。  
- [ ] 标准定义、口号、CLI 示例已进入规范文档。  
- [ ] 后续术语变更必须走 RFC，不得静默改写。

---

## 14. 封版声明

**预构范式（Prescript）企业级旗舰版术语与范式方案至此封版。**  

- 中文正式定义：**预构范式是面向预判布局壳的编程范式。**  
- 英文正式定义：**Prescript is the programming paradigm for Prescient Layout Shell.**  
- 中英对仗标语：**Prescript · 预构范式 ｜ Prescient Shell · 预判布局壳**  
- 完整交付标语：**Prescript on Prescient Shell, validated by CARF.**  
- 短 Slogan：**预构范式，壳上编排；CARF 筑基，全端共生。**  
- 封版状态：**FINAL / Enterprise Flagship Edition**。

> **一"判"定骨架，一"构"定范式；中英对仗，一体封版。**