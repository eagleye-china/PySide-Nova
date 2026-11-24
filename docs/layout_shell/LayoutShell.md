# Prescient Layout Shell｜预判式布局壳 · 旗舰封版规范
> **归属**：pyside-nova Flagship 旗舰版组件库
> **版本**：v1.0.0 (FROZEN)
> **状态**：封版基准文档，后续新增任何 Layout Shell 组件必须严格遵循本规范
> **英文标识**：Prescient Layout Shell

---

## 一、 前言与设计哲学

在 GUI 应用开发中，界面骨架是用户的第一触点。绝大多数 Python / PySide 开发者擅长业务逻辑与数据处理，但往往缺乏 UI 编排、视觉层次、动效节奏与多 DPI 适配的设计经验。
普通组件库仅交付零散原子控件（按钮、输入框、图标），将布局搭建、样式协调、适配兼容全部交由使用者自行实现，导致上手门槛高、成品风格参差不齐、易出现界面粗糙与主题联动失效等问题。

**Prescient Layout Shell（预判式布局壳）** 是 pyside-nova 的差异化核心体系：
我们提前站在开发者之前，将企业级 GUI 的布局范式、美学基线、容错逻辑、响应规则、主题联动全部沉淀为标准化复合组件。
Layout Shell 本身仍是标准 Nova 组件，可在 Gallery 画廊预览、独立调参、单元测试、版本管控；**严格不绑定任何业务逻辑**，仅提供稳定、美观、鲁棒的桌面应用骨架。
使用者只需向预留槽位注入业务页面与自定义控件，无需精通 UI 设计，即可产出工整、专业、具备高级观感的桌面应用界面。

> **品牌定位一句话**：
> Prescient Layout Shell — 预判开发者痛点，骨架开箱即出彩，保留全量自定义能力。

---

## 二、 核心术语定义

| 中文 | 英文 | 释义 |
| :--- | :--- | :--- |
| **鲁棒性** | Robustness | 运行容错能力，覆盖窗口极值、高 DPI 缩放、非法入参、QML 重复属性、动态加载异常等边界场景，异常下不崩溃、具备兜底渲染能力。 |
| **健壮性** | Solidity | 架构与契约稳定性，分层解耦、依赖可控、API 长期兼容，版本迭代不会破坏性变更上层业务。 |
| **艺术性** | Aesthetics | 美学基线，内置统一间距、比例、圆角、阴影、动画曲线，默认状态就具备精致观感，全部基于 Theme Token，禁止硬编码。 |
| **前置预判性** | Prescience | 本体系独有特质：预判高频 UI 痛点并内置解决方案，降低使用者认知与开发成本；高级用户可覆盖默认参数，保留定制空间。 |
| **布局壳** | Layout Shell | 无业务语义的复合根容器组件，由 Atoms 原子组件合规组合，提供固定槽位、布局约束、联动交互，用于承载业务内容。 |
| **原子组件** | Atom Component | 最小单一职责基础组件（NovaButton、NovaIcon 等），只负责单一渲染/交互，无跨组件布局联动。 |
| **槽位** | Slot | 预留内容注入点位，遵循单向数据流，外部注入内容，Shell 仅做布局托管，不侵入子组件状态。 |

> **四大核心支柱（旗舰四性）**：Robustness、Solidity、Aesthetics、Prescience。

---

## 三、 分层边界（封版红线，不可突破）

整个 pyside-nova 组件体系分为三层，Layout Shell 严格位于【复合层】，清晰隔离职责，防止骨架组件异化为业务框架。

1. **Atoms 原子层（底层依赖）**
   - **成员**：`NovaIcon`、`NovaButton`、`NovaInput`、`NovaDialog`、`NovaTooltip` 等最小单元组件。
   - **约束**：单一职责，只完成自身渲染与基础交互；不感知全局布局、路由、业务菜单。
   - **依赖**：无，或仅依赖 Theme 主题 Token、基础 Layout 容器。

2. **Layout Shell 布局壳层（本体系，复合层）**
   - **成员**：`NovaSidebarShell`、`NovaTopNavShell`、`NovaThreeColumnShell`、`NovaModalShell` 等。
   - **✅ 允许实现**：
     - 固定布局结构、安全边距、划分内容区域。
     - 导航展开/收起动画、过渡曲线、状态联动。
     - 自动主题 Token 绑定、明暗主题同步。
     - 响应式规则、窗口尺寸自适应、高 DPI 适配。
     - 属性合法性校验、边界兜底渲染、信号转发。
   - **❌ 严格禁止**：
     - 硬编码业务菜单、业务路由表、业务页面。
     - 引入业务单例、业务数据模型、业务专属配置。
     - 反向依赖上层业务项目代码。
     - 写死业务文案、项目专属图标。
   - **强制校验规则**：任意一个 Layout Shell，脱离业务项目，单独在 Gallery 画廊中必须可独立预览、正常运行。

3. **业务应用层（上层消费方）**
   - **成员**：开发者业务页面、工具、业务逻辑、数据处理。
   - **约束**：消费 Layout Shell，向槽位注入业务内容；不修改 Shell 内部私有实现，仅通过公开属性、信号做配置。

---

## 四、 Layout Shell 封版准入验收清单（门禁标准）

一个复合组件归类为 Prescient Layout Shell，必须**全部满足**以下条目，验收通过方可纳入库、打上封版标签、进入 Gallery 正式分组。

### 4.1 契约与健壮性（Solidity）
- [ ] 对外属性、信号、槽位命名严格遵循 Nova 统一命名规范，和 PySide-Quasar Widget 同名组件契约对齐。
- [ ] API 最小化原则：只暴露必要配置项，内部实现私有化，不随意暴露内部控件 id。
- [ ] 版本兼容策略：封版后，属性、信号移除或破坏性变更必须走主版本升级，小版本仅做 bug 修复、新增可选属性。
- [ ] 依赖定向：仅依赖 Atoms 原子组件、Theme 主题模块，不依赖业务模块。
- [ ] 单向数据流：父 Shell 通过属性向下传配置，子内容通过信号向上通知，禁止跨层级直接修改内部状态。

### 4.2 鲁棒性（Robustness）
- [ ] **内存与性能**：槽位内容动态增删时，布局自动重排，无残留渲染，无内存泄漏（建议使用 `Loader` 或 `Repeater` 管理动态内容）。
- [ ] **窗口边界**：窗口缩至极小、最大化、全屏模式下布局不溢出、不崩溃、元素不丢失（强制最小宽度/高度保护）。
- [ ] **高 DPI 适配**：Windows 不同缩放比例（100%/125%/150%/200%）渲染正常，文字、图标不模糊、布局不错位。
- [ ] **参数容错**：传入 undefined、空值、非法尺寸、非法枚举值时，自动回退安全默认值，不抛出 QML 运行异常。
- [ ] **规避历史坑**：禁止多处对同一个属性重复赋值（Property value set multiple times）。
- [ ] **主题切换**：明暗主题实时切换，样式平滑更新，不会出现卡死、样式残留。

### 4.3 艺术性（Aesthetics）
- [ ] 全部尺寸、间距、圆角、阴影、颜色、动画参数取自 Theme Token，**禁止写死色值与像素硬编码**。
- [ ] 默认美学基线：不做任何自定义配置时，组件默认渲染效果具备企业级精致观感。
- [ ] 动画统一：动画曲线、时长统一规范，避免不同 Shell 动画节奏割裂。
- [ ] 留白规范：内置安全边距，内容区域不会贴边，符合桌面 GUI 阅读习惯。
- [ ] 视觉层级清晰：导航、头部、侧边栏、内容区、底部有明确层级区分（阴影与边框组合使用）。

### 4.4 前置预判性（Prescience）与 A11y
- [ ] **预判高频痛点并内置默认方案**：
    - 预判用户不会设计边距 → 内置安全边距。
    - 预判 Drawer 动画参数难以调优 → 内置成熟动画参数。
    - 预判用户遗漏高 DPI 适配 → 内置缩放适配逻辑。
    - 预判主题联动容易遗漏 → 自动绑定全局主题。
- [ ] **预判操作习惯**：内置键盘导航（Tab 焦点流转、Esc 关闭/收起侧边栏），符合桌面应用交互直觉。
- [ ] 分层可定制：新手直接使用默认值；高级用户可覆盖属性、插槽，深度自定义布局。
- [ ] 配置项友好：属性命名语义直白，配套注释，降低理解成本。

### 4.5 工程交付配套（入库必备）
- [ ] 独立组件源码：`xxxShell.qml` + `qmldir`。
- [ ] 独立 README：组件说明、属性表、信号表、槽位说明、最小示例代码。
- [ ] Gallery 画廊 Demo：独立预览页面，提供调参面板，实时修改属性查看效果。
- [ ] 单元测试：覆盖核心信号、状态切换、边界参数。
- [ ] 验收清单：本清单，验收标记通过。

---

## 五、 目录结构规范

```text
pyside-nova/src/pyside_nova/qml/Nova/
├── Atoms/                      # 原子基础组件
├── Composite/
│   └── LayoutShell/            # Prescient Layout Shell 专属目录
│       ├── README.md           # 【本文档，封版总纲】
│       ├── NovaSidebarShell/
│       │   ├── NovaSidebarShell.qml
│       │   ├── qmldir
│       │   ├── README.md
│       │   └── demo/
│       ├── NovaTopNavShell/
│       ├── NovaThreeColumnShell/
│       ├── NovaModalShell/
│       └── ...
├── Theme/                      # Token 主题体系
└── Layout/                     # 基础布局容器（Row/Column 等底层容器）
```

> **Gallery 画廊分组**：`Prescient Layout Shell｜预判式布局壳`，放置首页显眼位置，作为库的展示招牌。

---

## 六、 槽位（Slot）设计通用规范

所有 Layout Shell 的槽位统一语义，方便使用者跨 Shell 迁移业务页面：
1. `headerSlot`：顶部头部区域（标题、全局操作、主题切换）。
2. `sidebarSlot`：侧边导航区域（菜单、目录）。
3. `contentSlot`：主内容区域（**最核心槽位，业务页面注入位置**）。
4. `footerSlot`：底部区域（状态栏、版本信息、操作提示）。
5. `overlaySlot`：浮层遮罩区域（弹窗、全局提示、加载遮罩）。

> **槽位设计原则**：按需提供，不冗余；槽位是 `Item` 容器，外部自由放入任意 Nova 组件或业务页面，Shell 只管控布局位置。

---

## 七、 QML 编码强制规范（Layout Shell 专属）

1. **组件头部注释模板**：每个 Shell 文件头部必须携带：
```qml
/**
 * Prescient Layout Shell | 预判式布局壳
 * Component: NovaSidebarShell
 * Flagship Standard: Robustness, Solidity, Aesthetics, Prescience
 * Follow Layout Shell Frozen Spec v1.0.0
 */
```
2. **私有属性前缀**：内部控件 id 加私有前缀 `_`，例如 `_drawer`，暗示外部不可直接访问。
3. **严禁硬编码**：所有默认值优先读取 Theme Token，不使用字面颜色、尺寸。
4. **信号命名规范**：使用动宾结构，例如 `pageSelected()`、`sidebarToggled()`。
5. **组合优于继承**：尽量使用组合而非 QML 继承，规避属性冲突、多重继承陷阱。
6. **生命周期管控**：在 `Component.onCompleted` 中进行初始状态校准，在 `Component.onDestruction` 中释放定时器与动态加载对象。

---

## 八、 版本迭代与变更流程

1. **总纲文档**：本文件为 FROZEN 基准；如需修改封版规则，必须走库的版本评审，升级文档版本号。
2. **已封版 Layout Shell**：
   - **PATCH（补丁）**：仅修复 bug、优化兜底逻辑，不新增属性、不改动默认美学。
   - **MINOR（小版本）**：新增可选属性、新增槽位，原有 API 完全兼容。
   - **MAJOR（主版本）**：破坏性 API 变更、结构重设计，需要明确告知使用者迁移方案。
3. **新增 Layout Shell**：先写 Demo、在 Gallery 验证，对照验收清单逐项勾选，全部通过后合并入库。

---

## 九、 对外宣传 & README 文案摘录（可直接复制）

> 🎯 **pyside-nova Prescient Layout Shell**
> 不用精通 UI 设计，也能写出专业、精致、工业级的桌面 GUI。
> 我们提前帮你搞定布局、导航、主题联动、自适应、动画、边界容错。
> 一套 Layout Shell = 一个应用标准骨架，填充业务即可交付。
> 四大旗舰标准：Robustness（鲁棒）、Solidity（健壮）、Aesthetics（艺术）、Prescience（前置预判）。

---

## 十、 附录：最小使用示例（NovaSidebarShell）

```qml
import Nova

NovaSidebarShell {
    title: "剪贴板多块保存工具"
    sidebarCollapsed: false

    sidebarSlot: NovaMenu {
        // 导航菜单
    }

    contentSlot: ClipMultiBlockSaverPage {}

    footerSlot: NovaLabel { text: "Dev Toolbox Pro | pyside-nova" }
}
```