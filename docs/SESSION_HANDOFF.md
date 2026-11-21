# 项目交接快照 — Session Handoff

> 用途：本文件是项目状态的**唯一事实源**；`scripts/gen_prompt.py` 会把它全文内联进
> `PROMPT.md`，新会话粘贴 PROMPT.md 即可 100% 恢复上下文。
> **每次交付随宪法迭代记录表同步更新本文件。**（更新于 0.4.0 · 2026-11-21）

## 一句话定位

pyside-nova：面向 PySide6 的企业级 QML 组件库，QML 元素 Quasar 生态化，
对标 **Quasar 2.26.0**，目标 `1.0.0-flagship` 封版（API 冻结 + LTS 24 个月）。

## 当前状态（0.4.0 · M0 完成，M1 生态骨架待动工）

- **12 个组件已交付**：NovaTheme / NovaScreen / NovaBtn / NovaCard·Section·Actions /
  NovaChip / NovaAvatar / NovaIcon / NovaBadge / NovaRipple / NovaSpace / NovaSeparator
- **测试 32 项全绿**（组件解析/槽/断点语义/Dark API/demo+画廊完整加载）
- **环境约定**：用户 Dell Win11 · PySide6 6.12.0 · 单人开发 · PyPI + GitHub
- **接续方式**：粘贴 `PROMPT.md`（自包含，快照已内联）；快照改动后须重跑 `gen_prompt.py`

## 必读文件（按需深读，非预读）

1. `docs/CONSTITUTION.md` —— 架构宪法（九章程则 + 迭代记录表）
2. `docs/PARITY.md` —— 全量对标审计（逐属性/事件/槽/model）
3. `CHANGELOG.md` —— 版本史（含 Qt 6.12 坑位沉淀）
4. `CONTRIBUTING.md` —— 宪法落地细则

## 不可违反的约定（速查）

- 头注释：第 1 行 `src/` 起始子路径，第 2 行文档素材说明；qmldir 只用 `#`
- 命名红线：基调色 `tint`；禁 `on*` 属性；主题模式 `isDark` / `setDark()` / `toggleDark()`；品牌色 `dark`（$dark 1:1）
- 槽机制：默认槽 `default property alias`、命名槽组合子组件、作用域槽 `Component delegate`
- 断点接入唯一方式：`Component.onCompleted: NovaScreen.source = window`
- 交付纪律：升版 → CHANGELOG → 宪法记录表 → 本文件 → `gen_prompt.py` 刷新 PROMPT → `local_deploy.py --zip`

## 已知坑位（Qt 6.12 实战沉淀）

1. `on*` 前缀属性名导致整个模块加载失败
2. `property color color` 与 Rectangle 基类冲突 → 用 `tint`
3. 纯 QML 不支持自定义 attached property（`attach` 语法 M1 经 PySide6 `QML_ATTACHED`）
4. qmldir 不支持 `//` 注释
5. 单例属性不可对象体内声明式绑定（会解析成 attached）

## 下一步（M1 生态骨架，按 ECOSYSTEM_PARITY.md 执行）

- **Sprint 1（先做）L1 布局**：NovaLayout / NovaHeader / NovaFooter / NovaDrawer / NovaPage
  + NovaRow / NovaCol / NovaVisible（12 栅格 × 5 断点、gutter、断点显隐）
  → 验收：6 种经典布局示例（后台/看板/表单/详情/登录/空态）
- **Sprint 2 L4 服务**：NovaNotify / NovaDialog / NovaLoading / NovaStorage / NovaApp / NovaPlatform
- **Sprint 3 L3 行为**：NovaClosePopup / NovaIntersection / NovaTouchPan·Swipe·Hold / NovaScrollObserver
- **Sprint 4 L0/L5**：图标 provider 注册表 + 6 套图标集 + Nova.utils + 动效令牌 + 9 级排版
- 详细差距与 DoD：`docs/ECOSYSTEM_PARITY.md`（12 项 P0 空白 + 24 条封版验收）

## 最近一次交付

- 0.4.0：生态对标白皮书（七层模型 + 12 项 P0 空白 + 24 条封版验收）+ 宪法第 10 章 + M1 范围重排
- 0.3.4：PROMPT 单文件自包含（快照全文内联 + 内容指纹校验），告别"翻 4 个文件"
- 0.3.3：交付包完整性加固（ZIP 含 PROMPT + .git 历史 + BUILD_INFO + SHA256）
- 0.3.2：快照/提示词双模板 + gen_prompt.py 生成器

## 交付物通道

- 本地：`python scripts/local_deploy.py --zip` → `dist/pyside-nova-<版>-release.zip`
- PyPI：打 `v*` 标签 → GitHub Actions Trusted Publishing 自动发布
