# Prescript 企业级旗舰版封版方案（FINAL）

## 1. 封版结论

**Prescript 定为唯一正式术语**，作为面向 **Prescient Layout Shell（预判式布局壳）** 的编程范式名称，进入白皮书、CLI、注释规范、工程规范与 CARF 体系。

封版范围冻结四项：

1. **术语冻结**：Prescript 为正式范式名，不再使用 Preshell / Prescribe / Prescode 作为主术语。  
2. **定义冻结**：采用下方标准定义文案。  
3. **CLI 命名空间冻结**：`pyside-nova prescript <verb>`。  
4. **口号冻结**：`Prescript on Prescient Shell, validated by CARF.`

> 封版状态：**FINAL / Enterprise Flagship Edition**  
> 术语版本：**Prescript Terminology Freeze v1.0**

---

## 2. 三层概念体系定稿

| 层级 | 正式术语 | 中文名 | 定位 | 不得混淆 |
|---|---|---|---|---|
| 组件载体 | **Prescient Layout Shell** | 预判式布局壳 | 预置业务槽位与布局骨架的壳载体 | 不是编程范式本身 |
| 开发范式 | **Prescript** | 预制壳编程范式 | 面向 Prescient Layout Shell 的开发方式 | 不是 Shell 组件名 |
| 品质流水线 | **CARF** | 品质封版流水线 | Conceive-Achieve-Refine-Freeze | 不是开发范式 |

一句话关系：

> **以 Prescript 编写 Prescient Layout Shell，经 CARF 验收封版。**

---

## 3. 白皮书标准定义文案（可直接复制）

### 3.1 一句定义

> **Prescript 是 PySide-Nova 独创的编程范式，专门面向 Prescient Layout Shell（预判式布局壳），通过预置槽位、预设契约和业务注入完成全端 GUI 编排。**

### 3.2 段落定义

> **Prescript**  
> Prescript 是 PySide-Nova 独创的编程范式，专门面向 Prescient Layout Shell（预判式布局壳）。开发者不再从零堆砌基础控件，而是遵循壳的契约与槽位规范，向预制布局壳注入业务内容，快速搭建符合四性标准的全端 GUI。Prescript 对标 Quasar 的模板式开发思想，但进一步强调“预判槽位 + 契约注入 + CARF 封版”的工程闭环，并依托 Qt/QML 实现桌面、移动、工业大屏的统一编排。

### 3.3 术语卡定义

> **Prescript**：面向 Prescient Layout Shell 的预制壳编程范式。  
> **核心动作**：遵循契约，向槽位注入业务。  
> **核心价值**：不从零堆控件，按预判骨架快速编排。  
> **配套体系**：Prescient Layout Shell 为载体，CARF 为品质流水线。

---

## 4. 词形、大小写与禁用规范

| 场景 | 规范写法 | 说明 |
|---|---|---|
| 正式术语/标题 | **Prescript** | 首字母大写，作为范式专名 |
| CLI 子命令 | `prescript` | 全小写，作为命令命名空间 |
| 代码标识符/配置键 | `prescript` | 全小写 |
| 环境变量前缀 | `PRESCRIPT_*` | 全大写 |
| 注释标签 | `@prescript` | 固定标签 |
| 形容词场景 | `Prescript-native` | 表示“Prescript 原生”，不随意造动词变形 |

**禁用为主术语**：Preshell、Prescribe、Prescode。  
可作为历史讨论别名，但不得进入白皮书、CLI、规范文档正文。

**大小写铁律**：  
- 写“Prescript 编程范式”，不写“prescript 编程范式”。  
- 写 `pyside-nova prescript dev`，不写 `pyside-nova Prescript dev`。

---

## 5. Prescript 编程范式四条原则

1. **壳先于页**：先选 Prescient Layout Shell，再注入业务，不从零堆控件。  
2. **槽位即边界**：业务只进入声明槽位，不穿透壳骨架。  
3. **契约即接口**：槽位、数据、事件、样式均以契约为准。  
4. **封版即交付**：Prescript 产物必须经 CARF 流水线验收后封版。

---

## 6. CLI 冻结规范

统一命名空间：

```bash
pyside-nova prescript <verb>
```

旗舰版冻结命令：

```bash
pyside-nova prescript init       # 初始化 Prescript 工程/壳契约
pyside-nova prescript dev        # Prescript 开发态运行
pyside-nova prescript compile    # Prescript 产物编译
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

## 7. 注释与契约标签规范

推荐最小注释标签集：

```python
# @prescript
# @shell: PrescientLayoutShell
# @slot: main.content
# @contract: prescript.contract.yaml
# @carf: freeze-gate
```

规范要求：

- `@prescript`：标识该文件/模块遵循 Prescript 范式。  
- `@shell`：声明所依托的 Prescient Layout Shell。  
- `@slot`：声明业务注入槽位。  
- `@contract`：声明契约文件。  
- `@carf`：声明对应 CARF 门禁或封版阶段。  

注释只做可追溯标记，不承载业务逻辑。

工程落地建议：契约文件统一为 `prescript.contract.yaml`，壳清单建议为 `prescient.shell.yaml`。此两项为工程建议，术语冻结核心仍是 Prescript。

---

## 8. 规范文档目录定稿

```text
00-terminology.md        # Prescript 术语与封版声明
01-principles.md         # 四条编程原则
02-shell-slot-contract.md# Prescient Layout Shell 槽位与契约规范
03-cli-spec.md           # pyside-nova prescript CLI 规范
04-annotation-spec.md    # @prescript 注释标签规范
05-carf-gate.md          # Prescript 与 CARF 门禁映射
06-migration-guide.md    # 旧写法迁移到 Prescript
07-reference.md          # 示例、反例、验收清单
```

---

## 9. 与 CARF 的配套映射

| Prescript 阶段 | CARF 对应 | 封版含义 |
|---|---|---|
| 壳选择与槽位规划 | Conceive | 预判骨架与业务槽位构思 |
| 契约编写与业务注入 | Achieve | 按契约完成 Prescript 编排 |
| 槽位校验与样式收敛 | Refine | 修正越界、契约偏差与全端一致性 |
| validate 通过并冻结 | Freeze | Prescript 产物封版交付 |

标准闭环：

> **Prescript 编写 → validate 校验 → CARF Freeze 封版。**

---

## 10. 对标 Quasar 的正式表述

> Prescript 借鉴 Quasar 的模板式开发思想，但并非模板复制。Prescript 以 Prescient Layout Shell 为预判载体，以槽位和契约为注入边界，并以 CARF 形成品质封版闭环，面向 Qt/QML 的桌面、移动、工业大屏统一编排。

---

## 11. 口号定稿

英文：

> **Prescript on Prescient Shell, validated by CARF.**

中文：

> **以 Prescript 编写 Prescient Layout Shell，经 CARF 验收封版。**

---

## 12. 封版验收清单

- [ ] 白皮书仅使用 **Prescript** 作为范式主术语。  
- [ ] CLI 仅使用 `pyside-nova prescript <verb>` 命名空间。  
- [ ] 注释统一使用 `@prescript` 标签。  
- [ ] 文档明确三层关系：Shell 载体 / Prescript 范式 / CARF 流水线。  
- [ ] 禁用 Preshell、Prescribe、Prescode 作为主术语。  
- [ ] 标准定义、口号、CLI 示例已进入规范文档。  
- [ ] 后续术语变更必须走 RFC，不得静默改写。

---

## 封版声明

**Prescript 企业级旗舰版术语与范式方案至此封版。**  
正式定义：**Prescript 是面向 Prescient Layout Shell 的预制壳编程范式。**  
正式口号：**Prescript on Prescient Shell, validated by CARF.**  
封版状态：**FINAL / Enterprise Flagship Edition**。