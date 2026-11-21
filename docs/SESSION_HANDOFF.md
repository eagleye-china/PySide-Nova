# 项目交接快照 — Session Handoff

> 用途：任何新会话（或人类协作者）只需读本文件 + 宪法即可 100% 恢复上下文。
> **每次交付随宪法迭代记录表同步更新本文件。**（更新于 0.3.1 · 2026-11-21）

## 一句话定位

pyside-nova：面向 PySide6 的企业级 QML 组件库，QML 元素 Quasar 生态化，
对标 **Quasar 2.26.0**，目标 `1.0.0-flagship` 封版（API 冻结 + LTS 24 个月）。

## 当前状态（0.3.1 · M0 完成，M1 未动工）

- **12 个组件已交付**：NovaTheme / NovaScreen / NovaBtn / NovaCard·Section·Actions /
  NovaChip / NovaAvatar / NovaIcon / NovaBadge / NovaRipple / NovaSpace / NovaSeparator
- **测试 32 项全绿**（组件解析/槽/断点语义/Dark API/demo+画廊完整加载）
- **环境约定**：用户 Dell Win11 · PySide6 6.12.0 · 单人开发 · PyPI + GitHub

## 必读文件（优先级顺序）

1. `docs/CONSTITUTION.md` —— 架构宪法（九章程则 + 迭代记录表）
2. `docs/PARITY.md` —— 全量对标审计（逐属性/事件/槽/model）
3. `CHANGELOG.md` —— 版本史（含 Qt 6.12 四大坑位沉淀）
4. `CONTRIBUTING.md` —— 宪法落地细则

## 不可违反的约定（速查）

- 头注释：第 1 行 `src/` 起始子路径，第 2 行文档素材说明；qmldir 只用 `#`
- 命名红线：基调色 `tint`；禁 `on*` 属性；主题模式 `isDark` / `setDark()` / `toggleDark()`；品牌色 `dark`（$dark 1:1）
- 槽机制：默认槽 `default property alias`、命名槽组合子组件、作用域槽 `Component delegate`
- 断点接入唯一方式：`Component.onCompleted: NovaScreen.source = window`
- 交付纪律：升版 → CHANGELOG → 宪法记录表 → 本文件 → `python scripts/local_deploy.py --zip`

## 已知坑位（Qt 6.12 实战沉淀）

1. `on*` 前缀属性名导致整个模块加载失败
2. `property color color` 与 Rectangle 基类冲突 → 用 `tint`
3. 纯 QML 不支持自定义 attached property（`attach` 语法 M1 经 PySide6 `QML_ATTACHED`）
4. qmldir 不支持 `//` 注释
5. 单例属性不可对象体内声明式绑定（会解析成 attached）

## 下一步（M1 攻坚，未开工）

- **M1 首战 `NovaLayout`**（header/footer/drawer/page 集成布局，QML 完全没有）：
  按宪法 + PARITY.md 逐项对照 QLayout/QHeader/QFooter/QDrawer/QPage 建审计节
- M1 队列：NovaTable / NovaField / NovaInput / NovaForm / NovaSelect / NovaDate /
  NovaNotify / NovaDialog / NovaStepper / NovaCarousel / NovaTree …
  （完整清单见 `docs/ROADMAP.md`）
- 同期可做：PARITY.md 中现有组件的 ❌/🚧 项按里程碑消化

## 交付物通道

- 本地：`python scripts/local_deploy.py --zip` → `dist/pyside-nova-<版>-release.zip`
- PyPI：打 `v*` 标签 → GitHub Actions Trusted Publishing 自动发布
