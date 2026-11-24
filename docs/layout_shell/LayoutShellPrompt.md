# 项目会话交接快照 (Enterprise Edition)

> **生成时间**：2026-11-23
> **版本**：v1.4 (QML 组件库启动版)
> **使用说明**：新会话首条消息直接粘贴此文档。AI 读取后必须根据「启动指令」进行状态对齐校验。

---

## 〇、 硬约束（不可绕过）

在你（AI）完成下面「四步初始化协议」并得到我明确"确认"之前：

1. **先复述，再动手**：不得开始任何具体的编码、改写、检索等实质工作。
2. **不编造**：信息不足处必须写"缺失信息"，禁止臆测或虚构项目状态。
3. **不跳步**：四步必须逐条完整输出，缺任一步视为未完成对齐。
4. **守决策**：凡被标注"已废弃"的方案，禁止重新提出。

---

## 一、 项目背景 (Project Context)

本项目旨在构建一套 **AI 会话上下文管理与接续工具链**（`Nova-Forge`），并同步开发企业级桌面 GUI 组件库（`pyside-nova`）。
1. **Nova-Forge CLI**：已实现本地快照/接续指令的无缝生成。
2. **pyside-nova**：正在开发基于 QML 的旗舰版组件库，已确立 Layout Shell 体系规范，并完成了首个核心骨架组件的封版。

---

## 二、 当前进度 (Current Status)

### ✅ 已完成 (Completed)
- **Nova-Forge 核心**：`archive`、`resume`、`saver` 子命令开发完毕。
  - `archive/resume`：极简交互，生成 `ready_prompt.md`。
  - `saver`：已按洋葱架构拆分为 `ui/`、`core/`、`command/` 三层；注册了 `Ctrl+Alt+S` 全局热键唤出。
- **QML 旗舰规范**：完成《Prescient Layout Shell v1.0.0 (FROZEN) 规范》编写。
- **首个 Shell 封版**：`NovaSidebarShell.qml` v1.0.0 代码完成（严格遵守 D-008，含完整槽位与响应式信号）。

### 🟡 进行中 (In Progress)
- (暂无，等待下一步指令)

### ⬜ 未开始 (Not Started)
- **Theme Token 体系落地**：补齐 `NovaSidebarShell` 依赖的所有颜色、尺寸、动画 Token。
- **第二个 Layout Shell 开发**：如 `NovaTopNavShell` 或 `NovaThreeColumnShell`。
- 自动化剪贴板深度解析。

---

## 三、 关键决策 (Key Decisions)

| 编号 | 决策内容 | 状态 |
| :--- | :--- | :--- |
| D-001 | **快照策略**：每完成一段就存，严禁拖延至上下文濒临断连。 | ✅ 生效 |
| D-002 | **技术路线**：纯本地脚本 + 手动复制粘贴，不假设有外部 API。 | ✅ 生效 |
| D-003 | ~~脚本内调本地 Agent HTTP 生成快照~~ | ❌ **已废弃**。被 D-007 取代。 |
| D-004 | **决策记录规则**：废弃方案不删除，仅标注"已废弃+原因+被替代方案"。 | ✅ 生效 |
| D-005 | **粒度控制**：`TODO.md` 中一条任务必须能在一次会话内独立完成。 | ✅ 生效 |
| D-006 | **对齐校验**：新会话接入后，AI 必须先复述状态再开始执行新任务。 | ✅ 生效 |
| D-007 | **脚本形态**：零外部 API 依赖，仅执行"读快照→拼模板→写文件"。 | ✅ 生效 |
| D-008 | **代码提交规范**：每次提交必须为完整代码；文件第一行为项目子目录路径注释，第二行为星期日期时间。 | ✅ 生效 |
| D-009 | **极简交互**：`archive` 终端手动粘贴+`EOF`结束；`resume` 自动读最新快照并拼装 `ready_prompt.md` 直接写剪贴板。 | ✅ 生效 |
| D-010 | **Nova-Forge 路由**：采用原生 `argparse` + `lambda` 极简分发模式。 | ✅ 生效 |
| D-011 | **架构分层规范**：代码必须分离 UI 层（`ui/`）、核心逻辑层（`core/`）、控制入口层（`command/`）。 | ✅ 生效 |
| D-012 | **QML 组件开发规范**：必须遵循《Prescient Layout Shell》规范，禁止硬编码色值尺寸，槽位命名统一，内部控件加 `_` 前缀。 | ✅ 生效 |

---

## 四、 待办事项 (Action Items)

按优先级排序：

1. **QML Theme Token 编写**
   - 补齐 `NovaSidebarShell` 中调用的 `Theme.sidebarWidth`、`Theme.spacingSmall`、`Theme.animDurationNormal` 等属性。
   - 定义深色/浅色主题的色值（`Theme.background`、`Theme.sidebarBackground` 等）。
2. **开发第二个 Layout Shell**
   - 基于已有的骨架体系，编写 `NovaTopNavShell.qml` 及其 Gallery Demo。
3. **Nova-Forge 全局打包测试**

---

## 五、 已知问题与风险 (Known Issues)

| 风险点 | 影响 | 缓解策略 |
| :--- | :--- | :--- |
| **Theme Token 缺失** | QML 组件预览时会报 undefined 错误。 | 列为待办第 1 条，立即补齐核心 Token。 |
| **QML 属性赋值重入** | 外部绑定与内部信号可能造成循环。 | 组件内 `onXxxChanged` 逻辑中加入了状态判断（如 `if (sidebarCollapsed !== _drawer.width)`）。 |
| **无头环境剪贴板** | Linux 无 GUI 环境下 `tkinter` 报错。 | 降级打印到终端。 |

---

## 六、 约束条件 (Constraints)

- **环境要求**：Python 3.9+，PySide6，纯标准库零第三方依赖（除 PySide6 外）。
- **语言规范**：文档与注释必须为中文。
- **代码交付规范**：强制 D-008（首行路径，次行时间）。

---

## 七、 重要引用 (References)

| 资产路径 / 名称 | 类型 | 说明 |
| :--- | :--- | :--- |
| `docs/session-snapshots/` | 目录 | 快照与 `ready_prompt.md` 归档位置。 |
| `src/nova_forge/core/templates/tmpl_resume.py` | 文件 | 封版接续指令模板。 |
| `src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md` | 文件 | 《预判式布局壳封版规范 v1.0.0》 |
| `src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaSidebarShell.qml` | 文件 | 首个封版的侧边导航布局壳。 |

---

### 🚀 新会话启动指令

**（在新会话中，将上方内容及以下指令发送给 AI）**

> 请阅读上方《会话交接快照》，并严格按以下步骤初始化你的状态：
> 
> 1. **状态复述**：用 200 字以内总结当前项目状态与核心目标。
> 2. **决策自查**：列出你接下来行动中必须遵守的核心决策（尤其是 D-011, D-012）。
> 3. **行动建议**：基于待办事项第 1 条，给出编写 QML Theme Token 的具体实现方案。
> 4. **缺失信息确认**：列出完成当前任务还需要我提供哪些信息。
> 
> 在我确认你的理解无误后，我们正式开工。