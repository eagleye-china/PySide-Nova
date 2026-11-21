# CONTRIBUTING — pyside-nova 贡献指南

> 感谢参与！pyside-nova 目标是企业级旗舰版封版（`1.0.0-flagship`）。
> **最高准则见《架构宪法》[docs/CONSTITUTION.md](docs/CONSTITUTION.md)**（每次交付随版本迭代），
> 本指南是宪法的落地细则；冲突时以宪法为准。

## 1. 环境准备

```bash
git clone https://github.com/your-name/pyside-nova.git
cd pyside-nova
pip install -e ".[dev]"
pytest -q          # 32 项冒烟测试应全绿
```

- Python 3.10–3.13；PySide6 ≥ 6.8（建议与最新 Qt 6.12.x 对齐）
- Windows 为主开发环境（CI 矩阵同时覆盖 Linux）

## 2. 项目布局（src layout，冻结）

```
src/pyside_nova/
├── __init__.py            # Python 接入层
├── __about__.py           # 版本唯一来源
└── qml/Nova/
    ├── Services/          # 单例服务（NovaTheme / NovaScreen）
    ├── Controls/          # 可视组件
    └── Behaviors/         # 行为（可挂载到任意 Item）
examples/
├── demo/                  # 精简演示
└── gallery/               # 组件画廊（新组件必须在画廊中新增页面）
docs/                      # 架构 / 令牌 / API / 路线图
scripts/                   # fetch_icons / local_deploy
tests/                     # 冒烟测试（新组件必须新增用例）
```

QML 模块 URI 固定为 `Nova.Services` / `Nova.Controls` / `Nova.Behaviors`，
包名固定 `pyside_nova`，wheel 内完整携带 QML 资源。

## 3. 文件头注释规范（强制）

每个 `.py` / `.qml` 文件以两行注释开头：第 1 行**从 `src/` 开始的完整文件子路径**，第 2 行**组件/文件说明**——
该说明将直接沉淀为 API 文档（docs）素材，要求一句话讲清组件定位与对标关系：

```qml
// src/pyside_nova/qml/Nova/Controls/NovaIcon.qml
// NovaIcon 图标组件：icon="mdi:home" 式 API，本地图标包优先、云端 CDN 自动回落，MultiEffect 单色化着色（对标 QIcon）
```

```python
# tests/test_smoke.py
# 冒烟测试：全部组件 QML 解析+实例化、令牌可读、断点语义（1366px→md）、画廊完整加载
```

例外：`qmldir` 文件的注释只能用 `#`（qmldir 不支持 `//` 注释，这是 Qt 硬限制）。

## 4. QML 编码规范

### 命名

| 规则 | 说明 |
|---|---|
| 组件类名 `Nova` 前缀 | `NovaBtn`、`NovaChip` … |
| 基调色属性命名 `tint` | **禁止** `property color color`（与 Rectangle 基类冲突导致重复赋值） |
| 禁用 `on*` 属性名 | QML 保留给信号处理器；语义色为 `textOnPrimary` / `textColor` / `textMuted` |
| 附着式组件用子项挂载 | `NovaBadge { }`、`NovaRipple { }`；`attach` 语法规划于 M1 经 PySide6 `QML_ATTACHED` 实现 |
| import 顺序 | `QtQuick` → `Nova.*`；禁止依赖隐式导入 |

### 结构约定

- 所有颜色/间距/字号取自 `NovaTheme` 令牌，**禁止魔法数值色**（特殊业务色需评审）
- 新组件必须：支持明暗双主题、禁用态、`clip` 不误伤挂载的 NovaBadge
- 单例属性赋值只能发生在 `Component.onCompleted`，不可对象体内声明式绑定

### qmldir

新增组件后同步更新对应模块的 `qmldir` 导出清单——该清单就是冻结的公共 API 面。

## 5. Python 编码规范

- 遵循 PEP 8；docstring 说明用途与参数
- 公共 API 变更必须在 CHANGELOG 记录并标注 `@since` 版本

## 6. 质量门禁（CI 强制）

| 门禁 | 标准 |
|---|---|
| 冒烟测试 | `pytest -q` 全绿；新组件必须新增解析 + 实例化用例 |
| 画廊 | 新组件必须在 `examples/gallery/` 新增页面且可完整加载 |
| 明暗双主题 | 画廊页面下 `NovaTheme.toggleDark()` 无警告（QColor 警告视为失败） |
| qmllint | `pyside6-qmllint src/pyside_nova/qml/Nova/**/*.qml` 0 error（CI 参考） |
| wheel 完整性 | `python -m build` 后 wheel 内含全部 QML + qmldir |

## 7. 提交与版本

- 提交信息：`<type>: <summary>`，type ∈ feat / fix / docs / refactor / test / chore
- 版本号唯一来源 `src/pyside_nova/__about__.py`，CHANGELOG 按 Keep a Changelog 更新
- 发布：打 `v*` 标签 → GitHub Actions Trusted Publishing 自动发布 PyPI

## 8. 旗舰版封版纪律（M3 起）

- Feature Freeze → Code Freeze → RC 双签 → GA 封版
- 公共 API 冻结后仅允许：bug 修复 / 安全热修（72h 通道）/ 性能优化
- 废弃 API 走两版本周期：先 `@deprecated` 标注 + 运行时警告，再移除
