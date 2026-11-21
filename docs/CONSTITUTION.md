# 架构宪法 — pyside-nova Architecture Constitution

> 本宪法是 pyside-nova 的最高工程准则。**每次产品交付都必须随版本迭代更新本文件**
> （见文末迭代记录表），条款变更须在 CHANGELOG 同步说明。与任何其他文档冲突时，以本宪法为准。

## 第 0 章 宗旨

以 **Quasar Framework 最新稳定版**为对标本源，为 PySide6 / Qt Quick 构建
**企业级旗舰版**组件库，最终达成 `1.0.0-flagship` 封版（API 冻结 + LTS 24 个月）。

**对标基线：Quasar `2.26.0`**（2026-11 经官方 releases 核实，随交付迭代复核更新）。

## 第 1 章 工程结构（冻结条款）

1. 项目根目录名为 `pyside-nova`（建项目/仓库时使用）
2. **src 布局**：Python 包固定 `src/pyside_nova`，QML 模块固定 `src/pyside_nova/qml/Nova/{Services,Controls,Behaviors}`
3. QML 模块 URI 固定：`Nova.Services` / `Nova.Controls` / `Nova.Behaviors`；`qmldir` 导出清单即公共 API 面
4. Python 接入层唯一入口：`from pyside_nova import init_nova`；版本唯一来源 `src/pyside_nova/__about__.py`
5. wheel 必须完整携带 QML 资源（qmldir + .qml），pip 安装即用

## 第 2 章 头注释（冻结条款）

每个 `.py` / `.qml` 文件以两行注释开头：

```
// src/pyside_nova/qml/Nova/Controls/NovaIcon.qml
// NovaIcon 图标组件：icon="mdi:home" 式 API，本地图标包优先、云端 CDN 自动回落，MultiEffect 单色化着色（对标 QIcon）
```

- 第 1 行：**从 `src/` 开始的完整文件子路径**（qmldir 用 `#` 前缀，shebang 文件路径注释位于第 2 行）
- 第 2 行：**组件/文件说明**——直接沉淀为 API 文档（docs）素材，一句话讲清定位与对标关系，禁止日期流水
- `qmldir` 注释只能用 `#`（Qt 硬限制：`//` 会破坏模块解析）

## 第 3 章 Quasar 化（核心条款）

1. **对标基线锁定 Quasar 2.26.x**：组件属性名 1:1 对齐（如 `flat`/`dense`/`disable`），差异须在组件注释与 docs 中注明理由
2. 组件类名一律 `Nova` 前缀：`QBtn → NovaBtn`
3. **命名红线**：
   - 基调色属性统一命名 `tint`（QML 中 `color` 与 Rectangle 基类冲突）
   - 禁用 `on*` 前缀属性名（QML 信号处理器保留字；语义文本色为 `textOnPrimary`/`textColor`/`textMuted`）
   - 禁止组件内声明 `property color color`
4. **全量对标审计（3.5 条）**：每组件逐属性/事件/槽/model 对照 Quasar 建立审计表
   （[PARITY.md](PARITY.md)）；新组件交付必须新增审计节；❌ 项须标里程碑、⛔ 项须写 QML 语境理由；
   封版前 ✅ 占比门禁 P0 ≥90%、全库 ≥85%
5. **槽机制（宪法第 4 章）与断点体系（第 6 章）为 Quasar 化的强制性组成**

## 第 4 章 槽机制（0.2.1 新颁）

Quasar 组件的 Vue 槽必须映射为 QML 等价机制；**凡 Quasar 组件有槽，对应 Nova 组件必须实现**：

| Vue/Quasar 槽 | QML 映射 | 实现方式 |
|---|---|---|
| 默认槽（default） | `default property alias content: <host>.data` | 子项挂载到覆盖层宿主 Item |
| 命名槽（named，如 QBtn loading） | 具名 alias / 专属子组件区域 | `property alias` 或组合子组件（如 NovaCard 的 CardSection/CardActions） |
| 作用域槽（scoped） | `property Component xxxDelegate` + required 属性回传数据 | M1 数据类组件（NovaTable/NovaList）强制使用 delegate 模式 |

已实现默认槽的组件：`NovaBtn` / `NovaChip` / `NovaAvatar` / `NovaIcon` / `NovaBadge` /
`NovaCard` / `NovaCardSection` / `NovaCardActions`。
`NovaSeparator` / `NovaSpace` / `NovaRipple`（行为类）在 Quasar 中无内容槽，豁免。

## 第 5 章 设计令牌

1. `NovaTheme` 是令牌唯一来源；组件**禁止魔法数值色**，颜色/间距/字号一律取令牌
2. 三级令牌：基础（品牌/语义/几何/字阶/阴影）→ 表面（随 dark 切换）→ 组件内部派生
3. **品牌色 1:1 对标 Quasar 8 大变量**：`primary` / `secondary` / `accent` / `dark` /
   `positive` / `negative` / `info` / `warning`；运行时 `setBrand()` 换肤
4. 明暗双主题为每个组件的强制属性；`toggleDark()` 一键切换零警告；
   主题模式 API 对标 Dark 插件：`isDark`（= $q.dark.isActive）/ `setDark(v)`（= $q.dark.set()）/ `toggleDark()`（= $q.dark.toggle()）
5. WCAG 2.1 AA 对比度门禁自 M2 起纳入 CI

## 第 6 章 断点体系

1. `NovaScreen` 1:1 对标 Quasar Screen 插件：阈值 xs<600 / sm<1024 / md<1440 / lg<1920 / xl≥1920，可 `setThresholds()` 定制
2. 语义 `isXs…isXl` / `ltSm…ltLg` / `gtXs…gtLg` / `isMobile` 与 Quasar 完全一致
3. 接入方式唯一：`Component.onCompleted: NovaScreen.source = window`
   （单例属性禁止对象体内声明式绑定——会被解析为 attached property）

## 第 7 章 图标系统

1. `NovaIcon` 的 `icon` 属性采用 `"mdi:home"` 式 API（`<集>:<名>`，无前缀默认 material）
2. 双通道：本地图标包（`NovaTheme.iconLocalRoot`，`scripts/fetch_icons.py` 产出）优先，缺失自动回落 jsDelivr CDN
3. 封装 QML `Image` + `MultiEffect` 着色；`monochrome: false` 保留原 SVG 彩色
4. 组件的 `icon` 属性统一自动识别图标引用（如 `NovaBtn.icon: "mdi:magnify"`）

## 第 8 章 质量门禁（CI 强制）

1. 冒烟测试全绿；**新组件必须新增**：解析+实例化用例、槽用例（若有槽）、明暗主题用例
2. 新组件必须在 `examples/gallery/` 新增页面且画廊完整加载
3. `pyside6-qmllint` 0 error；wheel 完整性（QML+qmldir 齐全）随 `local_deploy.py` 验证
4. 一键交付命令：`python scripts/local_deploy.py --zip`（构建→安装→测试→发布 ZIP）

## 第 9 章 版本与交付纪律

1. SemVer：破坏性 API 变更必须升 major 并在 CHANGELOG 标注 ⚠ Breaking
2. 每次交付：`__about__.py` 升版 → CHANGELOG 更新 → **本宪法迭代记录表新增一行** → 重新生成发布 ZIP
3. 封版（M3）后：公共 API 冻结，仅允许 bug 修复 / 72h 安全热修 / 性能优化；废弃 API 走两版本周期

## 迭代记录表（每次交付必须更新）

| 版本 | 日期 | 条款变更 |
|---|---|---|
| 0.1.0 | 2026-11-21 | 宪法雏形：工程结构、头注释雏形、命名红线、令牌、断点、图标、质量门禁 |
| 0.2.0 | 2026-11-21 | 第 1/2 章冻结：src 布局终版（pyside_nova/qml/Nova）、头注释双行规范、qmldir `#` 注释条款、gallery 门禁 |
| 0.2.1 | 2026-11-21 | 新颁第 4 章槽机制（默认/命名/作用域槽映射，5 组件重构补默认槽）；第 3 章对标基线锁定 Quasar 2.26.0；第 5 章补齐品牌色 `darkColor` |
| 0.3.0 | 2026-11-21 | ⚠ 命名重构：主题模式 `dark` → `isDark`，品牌色 `darkColor` → `dark`（1:1 对标 $dark，趁 0.x 期修复），新增 `setDark()`；新颁 3.5 条全量对标审计（PARITY.md，逐属性/事件/槽/model 对照） |
| 0.3.1 | 2026-11-21 | 基础夯实轮：测试护栏补齐（Dark API + demo 加载，合计 32 项）、GitHub Issue/PR 模板入宪第 8 章交付清单、dependabot 巡检 |
