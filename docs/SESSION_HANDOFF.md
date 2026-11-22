# 项目交接快照 — Session Handoff

> 用途：本文件是项目状态的**唯一事实源**；`scripts/gen_prompt.py` 会把它全文内联进
> `PROMPT.md`，新会话粘贴 PROMPT.md 即可 100% 恢复上下文。
> **每次交付随宪法迭代记录表同步更新本文件。**（更新于 0.6.2 · 2026-11-22）

## 一句话定位

pyside-nova：面向 PySide6 的企业级 QML 组件库，QML 元素 Quasar 生态化，
对标 **Quasar 2.35.5**（2026-11-22 复核纠正，原 2.26.0 过期），目标 `1.0.0-flagship` 封版（API 冻结 + LTS 24 个月）。

## 当前状态（0.6.2 · 一期 Sprint 2 **收口完成**：六件服务全交付，L4 44%）

- **公共 QML 类型 32 个已交付**（qmldir 导出口径）：Controls 18 + Services 单例 9
  （Screen/Theme/OverlayHost/Notify/Dialog/**Loading/Storage/App/Platform**）+ 句柄与动作 4
  + Behaviors 1；另有 Nova.Runtime Python 后端（ini 存储 + 平台探测）
- **测试 91 项全绿**（组件解析/槽/断点/Dark API/demo+画廊完整加载 + 布局/Notify/Dialog 行为级断言
  + 0.6.2 新增：Loading 引用计数/delay/局部 target/timeout/强杀/配置映射，Storage CRUD/类型往返/
  真落盘/命名空间/深拷贝/非法输入/Web 别名，Platform 事实核对，窗口控制/无窗口降级）
- **Sprint 2 六件全部交付**：Notify(0.6.0) / Dialog(0.6.1) / Loading·Storage·App·Platform(0.6.2 一次收口)
- **交付节奏条款（0.6.2 新颁）**：Sprint 是最小交付单元——一次收口、一个版本号、一套六份交付物；
  中间件只 git 提交不单独打全包
- **环境约定**：用户 Dell Win11 · PySide6 6.12.0 · 单人开发 · PyPI + GitHub
- **接续方式**：粘贴 `PROMPT.md`（自包含，快照已内联）；快照改动后须重跑 `gen_prompt.py`

## 必读文件（按需深读，非预读）

0. `docs/MASTER_PLAN.md` —— **全生态六期总规划**（排期与验收以它为准）

1. `docs/CONSTITUTION.md` —— 架构宪法（十章程则 + 迭代记录表）
0.5. `docs/ECOSYSTEM_PARITY.md` §0.5 —— 2.26→2.35 基线漂移审计（增量对照表）
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
6. 断点判断勿在组件自身 Component.onCompleted 做——创建期 parent 宽度是瞬态值（0），策略应由宿主（如 NovaLayout）持有
2. `property color color` 与 Rectangle 基类冲突 → 用 `tint`
3. 纯 QML 不支持自定义 attached property（`attach` 语法 M1 经 PySide6 `QML_ATTACHED`）
4. qmldir 不支持 `//` 注释
5. 单例属性不可对象体内声明式绑定（会解析成 attached）
7. QtObject（含单例）体内不可直接声明 `Component { }` 子项——报 "Cannot assign to non-existent
   default property"；必须走 `property Component xxx: Component { … }` 内联（0.6.0 实战沉淀）
8. `qmlRegisterSingletonInstance`（PySide6）把实例交给 QML 树管理：组件销毁即 delete Python 对象，
   二次访问报 "Internal C++ object already deleted"，且全局单实例无法多引擎共享 →
   一律用**工厂式 `qmlRegisterSingletonType`**（0.6.2 沉淀）
9. 服务单例引用裸 JS 对象当状态条目：属性变化无通知，句柄绑定不刷新 → 条目必须是 QML 对象
   （property Component 内联 QtObject）（0.6.2 沉淀）
10. 动态 overlay 的可见性与宿主 attach（强制 visible=true）冲突：可见性门控放内部 `_started`，
    根节点常驻、子项受控（0.6.2 沉淀）
11. QML 测试里 Python 引用保不住 QML 顶层 Window（JS GC 不认 Python 引用）→ 行为断言一律走
    QML 侧函数，不摸 Python 侧窗口 wrapper（0.6.2 沉淀）

## 下一步（一期 Sprint 2 L4 服务层，总规划见 MASTER_PLAN.md）

- ~~Sprint 1 L1 布局~~ ✅ 0.5.0 完成（6 种经典布局示例全部入画廊）
- ~~Sprint 2 L4 服务~~ ✅ **0.6.0~0.6.2 收口完成**（Notify 29 项 / Dialog 27 项 / Loading 11 项对账
  + Storage 全 API + App + Platform；画廊 12 页；91 项测试；L4 0% → 44%）
- **Sprint 3（下一步）L3 行为（v0.7.0）**：NovaClosePopup / NovaIntersection（单例 observer 池）/
  NovaTouchPan·Swipe·Hold·Repeat / NovaScrollObserver·ScrollFire —— 按节奏条款一次收口
- **Sprint 4 L0/L5（v0.8.0）**：图标 provider 注册表 + 6 套图标集 + Nova.utils + 动效令牌 + 9 级排版
- 详细差距与 DoD：`docs/ECOSYSTEM_PARITY.md`（12 项 P0 空白 + 24 条封版验收）

## 最近一次交付

- **0.6.2：Sprint 2 收口 · 一次交付四件**（NovaLoading 11 项对账 + 引用计数 / NovaStorage 真落盘 /
  NovaApp / NovaPlatform + NovaRuntime Python 后端 + 画廊第 12 页 + 91 项测试 + 交付节奏条款）
- 0.6.1：Sprint 2 第二件 NovaDialog（27 项对账 + 句柄三信号 + 画廊对话框页 + 71 项测试）
- 0.6.0：Sprint 2 首件 NovaNotify + NovaOverlayHost（29 项对账 + 63 项测试）
- **0.5.0：一期 Sprint 1 · L1 布局系统**（布局五件套 + 栅格三件套 + 画廊布局页 + 46 项测试）
- 0.4.2：**基线纠正 2.26.0 → 2.35.5** + 增量审计（AI-ready/MCP 入 L6、关闭原因上报/hover 契约/stagger/side 入 DoD）
- 0.4.1：**全生态开发总规划**（六期战略 + 全量对账表 + 冒烟测试七条纪律）
- 0.4.0：生态对标白皮书（七层模型 + 12 项 P0 空白 + 24 条封版验收）+ 宪法第 10 章 + M1 范围重排
- 0.3.4：PROMPT 单文件自包含（快照全文内联 + 内容指纹校验），告别"翻 4 个文件"
- 0.3.3：交付包完整性加固（ZIP 含 PROMPT + .git 历史 + BUILD_INFO + SHA256）
- 0.3.2：快照/提示词双模板 + gen_prompt.py 生成器

## 交付物通道

- 本地：`python scripts/local_deploy.py --zip` → `dist/pyside-nova-<版>-release.zip`
- PyPI：打 `v*` 标签 → GitHub Actions Trusted Publishing 自动发布
