以下为可直接纳入白皮书、封版规范与 CLI 帮助的企业级旗舰版封版优化文本。建议版本标识：**V1.0-FREEZE（企业级旗舰版封版）**。

---

# PySide‑Nova 术语与范式封版规范

**文档状态：** 企业级旗舰版封版（Freeze）  
**适用范围：** 白皮书、封版规范、CLI 帮助、API 文档、README、发布说明、官网/宣传材料、培训材料  
**封版原则：** 术语唯一、写法固定、定义单源、禁用别名、变更受控

## 一、封版术语与固定对应关系

| 中文固定名 | 英文固定写法 | 类型 | 封版定义/用法 | 受控说明 |
|---|---|---|---|---|
| 预构范式 | **Prescript** | 范式名 | PySide‑Nova 项目专属 GUI 开发范式，面向 Prescient Layout Shell，遵循壳契约与槽位规范，向预制骨架注入业务内容，经 CARF 品质流水线构建符合四性标准的全端 GUI。 | 首字母大写；禁止写成 prescript、PreScript、预构模式、预构建范式。 |
| 预判布局壳 | **Prescient Layout Shell** | 架构组件 | Prescript 所面向的预判布局壳/预制骨架，承载壳契约与槽位规范。 | 正文首次必须写全称；禁止写成 PrescientLayoutShell（自然语言中）、预知布局壳、预判布局外壳。 |
| 品质流水线 | **CARF** | 流程名 | 由 Conceive、Achieve、Refine、Freeze 四阶段组成的品质流水线。 | 全大写；展开顺序不可变；禁止 Carf、carf、C.A.R.F.；阶段中文固定为：构思、达成、精炼、冻结。 |
| 预判布局壳（受控简称） | **Prescient Shell** | 标语/空间受限简称 | 仅用于固定标语及空间受限场景。 | 正文首次仍须使用全称 Prescient Layout Shell；不得作为 API、类名或定义主名。 |

**固定体系关系：**

- **Prescript（预构范式）**：开发范式与方法体系。
- **Prescient Layout Shell（预判布局壳）**：承载 Prescript 的预制布局壳与骨架。
- **CARF（Conceive, Achieve, Refine, Freeze）**：保障交付品质的品质流水线。
- 标准链路：**Prescript 范式 → Prescient Layout Shell 壳契约/槽位 → 业务内容注入 → CARF 品质流水线 → 符合四性标准的全端 GUI。**

## 二、标准正式定义（封版文本）

> **Prescript（预构范式）：** PySide‑Nova 项目专属的 GUI 开发范式，面向 Prescient Layout Shell（预判布局壳）。开发者遵循壳契约与槽位规范，向预制骨架注入业务内容，并通过 CARF（Conceive, Achieve, Refine, Freeze）品质流水线，快速构建符合四性标准的全端 GUI。

说明：**四性标准**不在本规范中另行定义，统一引用《PySide‑Nova 四性标准封版规范》，避免多源定义。

## 三、词根与语义边界（封版说明）

**Prescript** 为 PySide‑Nova 项目专属造词，由 **Prescient**（预判、预置）与 **script**（描述、编码规约）组合而成，指面向 Prescient Layout Shell 的描述性、规约化预构开发范式。  
该词不是通用编程术语，不按 Python `script` 解释，不拆分为 `Pre-script` 翻译，不创建同义别名。

## 四、固定配套标语（封版）

> **Prescript · 预构范式**  
> **Prescient Shell · 预判布局壳**

书写要求：英文行在前、中文行在后；不增删词；中点统一使用「·」；不写成「Prescript-预构范式」等变体。

## 五、书写与使用规范

1. **首次出现：** 定义场景统一写「Prescript（预构范式）」「Prescient Layout Shell（预判布局壳）」「CARF（Conceive, Achieve, Refine, Freeze）」。
2. **大小写固定：** `Prescript` 首字母大写；`Prescient Layout Shell` 实词首字母大写；`CARF` 全大写。
3. **阶段名固定：** Conceive=构思，Achieve=达成，Refine=精炼，Freeze=冻结；封版语境可称「封版冻结」，但阶段名固定为「冻结」。
4. **禁用别名：** 不得使用「预构模式」「预构建范式」「预判壳」「预知布局壳」「Carf」等非封版写法。
5. **代码标识符：** 按项目命名规范使用 `Prescript`、`PrescientLayoutShell`、`CARF`；自然语言文档中仍使用封版写法。

## 六、CLI 帮助文案（可直接使用）

**短帮助：**

> Prescript — 预构范式；面向 Prescient Layout Shell，经 CARF 品质流水线构建全端 GUI。

**长帮助：**

> Prescript（预构范式）：面向 Prescient Layout Shell（预判布局壳）的 PySide‑Nova 项目专属 GUI 开发范式。遵循壳契约与槽位规范，向预制骨架注入业务内容，经 CARF（Conceive, Achieve, Refine, Freeze）品质流水线，构建符合四性标准的全端 GUI。

## 七、白皮书/封版规范段落（可直接使用）

> PySide‑Nova 以 **Prescript（预构范式）** 统一 GUI 开发方法：开发者面向 **Prescient Layout Shell（预判布局壳）**，遵循壳契约与槽位规范，向预制骨架注入业务内容，并通过 **CARF（Conceive, Achieve, Refine, Freeze）** 品质流水线完成从构思、达成、精炼到冻结的交付，快速构建符合四性标准的全端 GUI。

## 八、封版控制与验收清单

**变更控制：** 本组术语为冻结术语；任何改名、缩写、翻译、大小写或标语变更，须走术语变更评审，不得在文档中私设别名。  
**同步清单：** 白皮书、封版规范、CLI 帮助、README、API 文档、发布说明、官网/宣传材料、培训材料。  
**验收项：**

- [ ] 中英文对应关系与封版表一致  
- [ ] Prescript、Prescient Layout Shell、CARF 大小写正确  
- [ ] CARF 四阶段展开及顺序正确  
- [ ] 固定标语逐字一致  
- [ ] 首次出现使用双语全称  
- [ ] 无禁用别名与非受控简称  
- [ ] 四性标准仅引用单源规范  
- [ ] 所有材料已同步至 V1.0-FREEZE

以上文本可直接替换白皮书、封版规范与 CLI 帮助中的对应段落。