# PySide6-Nova

> 一套基于 Qt 原生渲染引擎的企业级跨端 GUI 组件库 · 覆盖桌面、移动端与工业大屏
>
> **1.0.0 GA 旗舰版 · 对外营销版 README 素材**（与仓库根 `README.md` / `README_zh.md` 同源）

![Status](https://img.shields.io/badge/status-flagship%20v1.0-blue)
![Qt](https://img.shields.io/badge/Qt-Qt%20Quick%206.8+-41cd52)
![Python](https://img.shields.io/badge/Python-3.10+-3776ab)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ 简介

**PySide6-Nova** 是面向企业级工具、IDE 工作台、AI 客户端、HMI 与工业大屏的标准化 UI 组件体系。
依托 Qt 原生高性能渲染引擎，在同一套组件与规范下覆盖桌面客户端、移动根壳形态、工业超大屏与
嵌入式终端，具备**轻量、高性能、高稳定、全适配、易扩展**五大特质。

> 不用精通 UI 设计，也能写出专业、精致、工业级的界面；布局、导航、主题联动、自适应、动效节奏、
> 键盘可达与边界容错，已由 Nova 提前封装到位。

**1.0.0 GA 事实**：139 个公共 QML 类型 · 五个 QML 模块 · 15 项组合根容器 ·
API 冻结指纹 `bfd3d938a2fab7be`（零漂移）。

---

## 🚀 核心特性

- **一套组件，全端交付**：桌面 / 移动 / 大屏 / 嵌入式，统一设计契约与 `NovaTheme` 主题 Token
- **原生渲染，稳定轻量**：无浏览器内核包袱，启动快、内存友好，适合 7×24 常驻
- **Prescient Layout Shell 布局壳体系**：15 项预判式骨架组件，开箱即用，支持全量自定义，
  **每项有独有结构性身份元素**
- **旗舰四性标准**：鲁棒性 Robustness · 健壮性 Solidity · 艺术性 Aesthetics · 前置预判性 Prescience
- **双令牌驱动**：视觉取 `NovaTheme`、动效取 `NovaMotion`（`reducedMotion` 无障碍短路、
  `speedFactor` 全库调速），明暗主题自动联动
- **a11y 契约化**：139/139 类型登记 interactive / semantic / decorative，装饰容器不制造屏读器噪声
- **工程规范完备**：Ruff 校验、Gallery 预览、API 冻结门禁、qmllint 预算、单元测试与封版验收清单

---

## 🧱 架构总览

```
┌──────────────────────────────────────────────────────────┐
│  业务应用层  Business Applications                        │  业务页面 · 工具 · 数据逻辑
├──────────────────────────────────────────────────────────┤
│  组合根容器层  Prescient Layout Shell（15 项）             │  骨架 · 槽位 · 约束 · 身份
├──────────────────────────────────────────────────────────┤
│  基础组件层  Controls（91）+ Behaviors（13）               │  按钮 · 列表 · 弹窗 · 表单
├──────────────────────────────────────────────────────────┤
│  服务与设计层  Services（16）+ Design（4）                 │  NovaTheme · NovaMotion · NovaScreen
└──────────────────────────────────────────────────────────┘
```

### 三端根壳 + AI 主窗口

| 组件 | 职责 |
|---|---|
| **NovaDesktop** | 桌面端根壳：菜单栏、工具栏、页面宿主、状态栏 |
| **NovaMobile** | 移动端根壳：安全区、触控交互、底部导航与返回意图 |
| **NovaFlexLayout** | 大屏弹性布局：columns 驱动自适应分栏、网格与动态缩放 |
| **NovaChat** | AI 对话主窗口：导航轨 / 会话列 / 对话区 / 输入区 / 详情栏 / 浮层六轨 |

### 布局壳家族（11 项）

| 分类 | 组件 | 典型场景 | 身份语言 |
|---|---|---|---|
| 主导航 | `NovaSidebar` | 工具、后台、AI 工作台（主推款） | 品牌渐变轨 + 浮起侧栏卡 |
| 主导航 | `NovaTopNavigation` | 轻量化配置工具 | 胶囊导航台 + 悬浮下拉 |
| 主导航 | `NovaDualSide` | 编辑器、配置器、节点工具 | 中央点阵画布 + 双栏浮起 |
| 主导航 | `NovaTabShell` | 多文档、多任务并行 | 材质标签栏 + 下划线 |
| 多栏工作台 | `NovaThreeColumn` | 目录-列表-详情，资源库与画廊 | 三级深度色阶 + 拖拽 grip |
| 多栏工作台 | `NovaCompare` | 双栏对比、diff 查看 | 中缝调节柄 + A/B 色条 |
| 多栏工作台 | `NovaCardGrid` | 卡片网格、素材与模板市场 | 工具条胶囊 + Flow 网格 |
| 浮层容器 | `NovaModal` | 模态配置与表单弹窗 | 顶部三色条 + catcher |
| 浮层容器 | `NovaDrawerPanel` | 非模态临时侧滑面板 | 侧缘渐变轨 + grabber |
| 独立页壳 | `NovaSetupWizard` | 安装 / 新建工程 / 初始化配置 | 三态步骤时间轴 |
| 独立页壳 | `NovaBlankPage` | 纯净单页与嵌入式子页面 | 居中阅读栏 |

> 六类合计 **15 项**，全部落在第五 QML 模块 `Nova.Composite.LayoutShell`，
> 全部为 1.0.0 GA 已封版公共类型。命名以 `docs/layout_shell/PrescientLayoutShell.md` 权威清单为准。

---

## 🛠️ 技术栈

- **运行框架**：PySide6 ≥ 6.8（6.12.0 实测）· Qt Quick / QML
- **语言**：Python 3.10+ + QML
- **对标基线**：Quasar 2.35.5
- **代码规范**：Ruff + 两行头注释（禁止日期流水）
- **图标体系**：Material Symbols / MDI（本地包 + CDN 双通道）
- **目标平台**：Windows · Linux · macOS · Android · 嵌入式 Linux · 工业大屏

---

## ⚡ 快速上手

### 环境要求

- Python 3.10+
- PySide6 6.8+

### 安装依赖

```bash
pip install PySide6
pip install pyside-nova      # PyPI 上架后（发布由维护者执行）
```

### 最小示例（1.0.0 GA 真实命名，可执行）

```qml
import QtQuick
import QtQuick.Controls.Basic
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    visible: true
    width: 1080; height: 720
    color: NovaTheme.page

    NovaSidebar {
        anchors.fill: parent
        sidebarSize: 260

        sidebarSlot: NovaText { text: "导航由业务注入" }
        contentSlot: Rectangle { color: NovaTheme.page }
        footerSlot: NovaText { text: "Powered by PySide6-Nova" }
    }
}
```

> 槽位名按骨架范式场景化命名（完整 15 项权威表见《封版规范》§4.2）；
> `NovaSidebar` **没有** `title` 属性，也不存在 `NovaLabel` / `Theme.*` 等 API。
> 完整属性 / 信号 / 槽位表与「依赖组件清单」见
> `src/pyside_nova/qml/Nova/Composite/LayoutShell/README.md`。

---

## 📂 目录结构

```
pyside-nova/
├── src/pyside_nova/qml/Nova/
│   ├── Controls/               # 91 控件与布局原语
│   ├── Behaviors/              # 13 附加行为
│   ├── Services/               # 16 服务单例（NovaTheme / NovaScreen / …）
│   ├── Design/                 # 4 设计语言类型（NovaMotion / …）
│   └── Composite/LayoutShell/  # 15 组合根容器 + qmldir + README（第五模块）
├── examples/
│   ├── gallery/                # 组件预览画廊（含 15 页布局壳）
│   └── layout_shell/           # 15 个独立演示目录
├── docs/                       # 宪法、白皮书、封版规范、生成器产物
├── scripts/                    # 生成器与门禁
└── tests/                      # 单元测试与验收
```

> 草案中的 `Atoms/` / `Widgets/` / `Theme/` / `Layout/` 是逻辑分组名，**不是仓库物理目录**；
> 视觉变量唯一门面是 `NovaTheme`，不存在 `Theme/` 目录。

---

## 📖 文档

- [旗舰组件库白皮书](pyside-nova-旗舰组件库白皮书.md) — 品牌宣言、架构体系与全端方案
- [Prescient Layout Shell 封版规范](Prescient-LayoutShell-封版规范.md) — 准入红线、槽位规范与四性验收
- [组合根容器逐组件 API 页](../components/index.md) — 15 项 Props / Slots / Events 完整契约与依赖组件清单
- [组件索引](../COMPONENT_LIST.md) — 139 类型，生成器产物（权威事实源）
- [架构宪法](../CONSTITUTION.md) · [组合组件宪法](../COMPOSITION_CONSTITUTION.md)

---

## 🎯 适用场景

- 企业级桌面工具、IDE 与插件工作台
- AI 助手客户端、对话与内容管理界面
- 配置管理、资源浏览、图标与模板库
- 安卓移动端轻量应用与随附工具
- 工业 HMI、中控大屏、数据可视化控制台
- 需对接串口、USB、视频流的专业终端软件

---

## 🤝 对比优势

| 维度 | PySide6-Nova | Electron | Flutter | 分端原生开发 |
|---|---|---|---|---|
| 桌面性能 | 原生渲染，内存友好 | 内核重，体积偏高 | 桌面成熟度一般 | 最优但成本最高 |
| 移动端 | 安卓打包，组件复用 | 基本不支持 | 强 | 各端分别开发 |
| 大屏 / 嵌入式 | Qt 传统优势领域 | 长期运行易掉帧 | 较弱 | 依赖厂商 |
| 硬件外设 | 串口 / USB / CAN / 视频流完备 | 支持薄弱 | 有限 | 完备 |
| 开发效率 | 高，低学习门槛 | 前端上手快 | 需掌握 Dart | 最低 |

> 定性对比，不代表具体项目的绝对性能结论；选型应结合团队能力、交付周期与目标平台验证。

---

## ✅ 封版验收（1.0.0 GA 实测）

| 门禁 | 结果 |
|---|---|
| 静态门禁（a11y → API 冻结 → qmllint） | **3/3 PASS** |
| API 冻结 | **139 类型零漂移** · `bfd3d938a2fab7be` |
| a11y 契约 | **139/139**（interactive 32 · semantic 28 · decorative 79） |
| qmllint | **0 error**，warning 在预算内 |
| 专项测试 | **48/48** |
| 无头实例化 | **31/31**（15 组件 + Gallery + 15 演示） |
| 四性全库回扫（宪法 0.8.1 / 封版规范 v2.0.1） | **15/15** 极端非法入参稳态几何非负 · **15/15** 声明式 RTL · 双主题实心注入渲染 PASS · `reducedMotion` 300→0ms PASS |
| 组合态一致性契约（宪法 0.9.0 / 封版规范 v2.1.0） | **NovaChat 六轨装配首例**：唯一密度源、单一分隔源、抽象几何装饰、动效同步、槽位 `anchors.fill` 契约、成品级 showcase；浅色 / 深色 / 折叠三态渲染审计通过，QML 零错误、指纹不变 |
| CC 迁移批次 2（宪法 0.9.1） | **NovaDesktop / NovaMobile / NovaFlexLayout 三大根壳**：栏高归零恒定锚链（消除布局跳变）、主色系抽象几何、成品级 showcase；12 张浅 / 深 / 变体渲染审计图全通过、API 冻结零漂移、**4/15 天花板销号** |

---

## 📜 许可证

MIT License（许可证以仓库实际声明为准）。

---

<div align="center">

**一套组件，全端交付。**

*原生级性能 · 企业级规范 · 旗舰级观感*

</div>

> 本文为 `docs/white_paper/` 下的**对外营销版 README 素材**，与主 README 同源同步；
> 技术红线以《Prescient Layout Shell 封版规范》与架构 / 组合宪法为准，组件成熟度以
> `docs/COMPONENT_LIST.md` 为准。涉及「已交付 / 已验证」的表述均须有门禁记录支撑。
