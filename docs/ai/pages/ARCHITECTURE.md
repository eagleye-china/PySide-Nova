# 架构文档 — pyside-nova Architecture

> 版本 0.2.0 · 本文档描述库的分层架构、加载机制与打包分发设计。

## 1. 总体分层

```
┌────────────────────────────────────────────────────┐
│ 应用层 (Application)                                │
│   QML 应用 / examples/demo / examples/gallery       │
├────────────────────────────────────────────────────┤
│ Behaviors 行为层        import Nova.Behaviors       │
│   NovaRipple —— 可挂载到任意 Item 的行为            │
├────────────────────────────────────────────────────┤
│ Controls 组件层         import Nova.Controls        │
│   NovaBtn / NovaCard / NovaChip / NovaAvatar /     │
│   NovaIcon / NovaBadge / NovaSpace / NovaSeparator │
├────────────────────────────────────────────────────┤
│ Services 服务层         import Nova.Services        │
│   NovaTheme（令牌单例）/ NovaScreen（断点单例）      │
├────────────────────────────────────────────────────┤
│ Python 接入层           from pyside_nova import …   │
│   init_nova(engine) / QML_ROOT / __about__         │
└────────────────────────────────────────────────────┘
```

依赖方向自上而下：Controls 依赖 Services，Behaviors 依赖 Services；
Services 之间不互相依赖；任何层不得反向依赖应用层。

## 2. 模块加载机制

`init_nova(engine)` 只做一件事：

```python
engine.addImportPath(QML_ROOT)   # src/pyside_nova/qml
```

QML 模块按目录约定解析：

| import | 目录 | qmldir URI |
|---|---|---|
| `Nova.Services` | `qml/Nova/Services/` | `module Nova.Services`（pragma Singleton 成员） |
| `Nova.Controls` | `qml/Nova/Controls/` | `module Nova.Controls` |
| `Nova.Behaviors` | `qml/Nova/Behaviors/` | `module Nova.Behaviors` |

- **单例**：`NovaTheme.qml` / `NovaScreen.qml` 顶部 `pragma Singleton`，
  并在 `Services/qmldir` 以 `singleton` 声明导出
- **qmldir 即 API 面**：模块的公共导出清单就是 `qmldir` 文件，
  旗舰版封版后该清单冻结，新增导出走 minor 版本、移除走 major 版本
- ⚠ **qmldir 只支持 `#` 注释**，`//` 会破坏模块解析（Qt 硬限制，已沉淀为规范）

## 3. 设计决策记录（ADR 摘要）

| # | 决策 | 理由 |
|---|---|---|
| 1 | 纯 QML 实现（当前），Python 仅做接入层 | 可审计、可纯 QML 复用；attached property 等 Python 能力在 M1 经 `QML_ATTACHED` 渐进引入 |
| 2 | 基调色命名 `tint` 而非 `color` | QML 中 `property color color` 与 Rectangle 基类 `color` 冲突导致重复赋值 |
| 3 | 禁用 `on*` 前缀属性 | 与 QML 信号处理器命名规则冲突，曾导致整个模块加载失败 |
| 4 | Badge/Ripple 用子项挂载 | Qt 6.12 纯 QML 不支持自定义 attached property |
| 5 | `NovaScreen.source` 在 `onCompleted` 赋值 | 单例属性不能在对象体内声明式绑定（会被解析为 attached） |
| 6 | 图标双通道（本地优先 + CDN 回落） | 企业内网离线部署 + 个人开发云端即用，两端兼顾 |
| 7 | hatchling 打包、QML 随 wheel 分发 | pip 安装即用，无需 qrc 编译步骤，单人开发工具链最简 |
| 8 | 文件头两行注释（路径 + 星期日期时间） | 工程溯源约定，配合封版审计 |

## 4. 打包与分发

```
pyproject.toml (hatchling)
├─ wheel:   src/pyside_nova 全量（含 qml/Nova/**、qmldir）
└─ sdist:   src / tests / examples / scripts / 文档
```

- 版本唯一来源 `src/pyside_nova/__about__.py`（hatchling 动态读取）
- 发布：`v*` 标签 → GitHub Actions `release.yml` → PyPI Trusted Publishing（无 token）
- 应用分发：PyInstaller 打包应用 + `pyside-nova` wheel（官方 hook 规划于 M3）

## 5. 测试策略

| 层级 | 内容 | 位置 |
|---|---|---|
| 冒烟 | 每个组件 QML 解析 + 实例化、令牌可读 | `tests/test_smoke.py` |
| 行为 | 断点语义（1366px → md）、明暗切换 | 同上 |
| 集成 | demo / gallery 完整加载 | `test_gallery_loads` 等 |
| 视觉回归 | 明暗双主题截图比对 | 规划于 M2 |
| 覆盖率门禁 | P0 组件 ≥90%、全库 ≥85% | 规划于 M2 |
