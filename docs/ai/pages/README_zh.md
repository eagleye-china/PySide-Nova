<div align="center">

# pyside-nova

**Qt Quick 世界的 Quasar** —— 面向 PySide6 的企业级 QML 组件库。

对标 [Quasar Framework](https://quasar.dev/) 的组件生态，为 Qt Quick / PySide6 提供
统一的设计令牌（Theme）、组件（Controls）、行为（Behaviors）、服务（Services）四层体系。

[![CI](https://github.com/your-name/pyside-nova/actions/workflows/ci.yml/badge.svg)](https://github.com/your-name/pyside-nova/actions/workflows/ci.yml)
[![PyPI](https://img.shields.io/pypi/v/pyside-nova)](https://pypi.org/project/pyside-nova/)
[![Python](https://img.shields.io/pypi/pyversions/pyside-nova)](https://pypi.org/project/pyside-nova/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

> 🌍 English: **[README.md](README.md)**

- **基线环境**：Windows 11 / macOS / Linux · Python 3.10–3.13 · PySide6 ≥ 6.8（已在 **6.12.0** 实测）
- **对标基线**：**Quasar `2.26.0`**（已核实官方 releases）· 当前状态 `0.3.0`（槽机制 + 全量对标审计 + 架构宪法）· 目标 `1.0.0-flagship` LTS 封版
- **架构宪法**：[docs/CONSTITUTION.md](docs/CONSTITUTION.md) —— 每次交付随版本迭代更新
- **生态对标白皮书**：[docs/ECOSYSTEM_PARITY.md](docs/ECOSYSTEM_PARITY.md) —— 七层模型成熟度、12 项 P0 空白、24 条封版验收

## 为什么选 pyside-nova

Qt Quick Controls 只覆盖基础控件，而企业级应用需要 Quasar 的完整故事：有主张的主题体系、
断点、图标集、表单系统、数据表格、通知服务。**pyside-nova 把这套生态搬到纯 QML + PySide6 上**，
API 与 Quasar 1:1 对齐 —— Vue/Quasar 开发者零学习成本，企业团队拿到的是一套可审计、
可封版的组件资产。

## 特性

- 🎨 **三级设计令牌**：基础令牌 → 语义令牌 → 组件令牌，`NovaTheme` 单例统一管理；明暗主题一键切换、运行时品牌换肤
- 🧩 **Quasar 风格 API**：`QBtn → NovaBtn`、`QCard → NovaCard`，属性名对齐，学习成本趋近于零
- 🧱 **槽机制**：Quasar 槽 → QML 映射——默认槽 → `default property alias`
  （NovaBtn/Chip/Avatar/Icon/Badge/Card 全系）、命名槽 → 组合子组件、作用域槽 → `Component delegate`（宪法强制）
- 🖥️ **断点体系**：`NovaScreen` 1:1 移植 Quasar Screen 插件（xs/sm/md/lg/xl = 600/1024/1440/1920，`is*` / `lt*` / `gt*`）
- 🖼️ **图标双通道**：`NovaIcon { icon: "mdi:home" }`，本地图标包（离线）优先、云端 CDN 自动回落
- 📦 **pip 即用**：QML 模块随 wheel 分发，`init_nova(engine)` 一行接入
- ✅ **实测而非承诺**：32 项冒烟测试（含 demo 与画廊完整加载），CI 在真实 QML 引擎上运行（Windows + Linux 矩阵）

## 安装

```bash
pip install pyside-nova          # PyPI 发布后
pip install -e ".[dev]"          # 本地开发
```

## 快速开始

```python
# main.py
import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from pyside_nova import init_nova

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
init_nova(engine)          # 注册 Nova.* QML 导入路径
engine.load("main.qml")
sys.exit(app.exec())
```

```qml
// main.qml
import QtQuick
import QtQuick.Controls.Basic
import Nova.Services
import Nova.Controls
import Nova.Behaviors

ApplicationWindow {
    visible: true
    color: NovaTheme.page

    Column {
        anchors.centerIn: parent
        spacing: 12
        NovaBtn { text: "主操作" }
        NovaChip { text: "QML"; removable: true }
        Rectangle {
            width: 140; height: 60; radius: 8
            color: NovaTheme.primary
            NovaRipple { }                    // 水波纹行为：作为子项挂载
        }
        NovaBtn {
            icon: "🔔"
            round: true
            NovaBadge { text: "99+" }         // 徽标：作为子项挂载，自动吸附右上角
        }
    }
}
```

> **API 约定**：基调色属性统一命名 `tint`（而非 `color`）—— QML 中 `color` 与 Rectangle
> 基类属性冲突，视觉角色等同 QBtn 的 `color`。

### 组件画廊

```bash
python examples/gallery/main.py    # 组件画廊：侧边导航 + 全组件实机展示
python examples/demo/main.py       # 精简演示
```

## 组件状态

| 组件 | 对标 Quasar | 说明 | 状态 |
|---|---|---|---|
| `NovaTheme` | Dark 插件 + brand 变量 | 设计令牌单例，明暗主题、品牌换肤、阴影令牌 | ✅ 0.1.0 |
| `NovaBtn` | QBtn | filled/outlined/flat、水波纹、loading、键盘 | ✅ 0.1.0 |
| `NovaCard` 系列 | QCard 系列 | Card / CardSection / CardActions、MultiEffect 阴影 | ✅ 0.1.0 |
| `NovaChip` | QChip | filled/outlined/tinted、可选中、可移除 | ✅ 0.1.0 |
| `NovaAvatar` | QAvatar | 文字自动配色 / emoji / 图片 | ✅ 0.1.0 |
| `NovaIcon` | QIcon | `icon="mdi:home"`，本地包 + CDN 双通道，MultiEffect 着色 | ✅ 0.1.0 |
| `NovaScreen` | Screen 插件 | xs/sm/md/lg/xl 断点，is/lt/gt 语义 1:1 对标 | ✅ 0.1.0 |
| `NovaBadge` | QBadge | 子项挂载，红点/数值/浮动 | ✅ 0.1.0 |
| `NovaRipple` | v-ripple | 子项挂载波纹（NovaBtn 已内置） | ✅ 0.1.0 |
| `NovaSpace` / `NovaSeparator` | QSpace / QSeparator | 布局原语 | ✅ 0.1.0 |
| `NovaField` / `NovaInput` | QField / QInput | 统一字段包装器 | 🚧 M1 |
| `NovaForm` / `NovaSelect` | QForm / QSelect | 规则化校验、多选过滤 | 🚧 M1 |
| `NovaDate` | QDate | 日历选择器（Qt 6 无内置日历） | 🚧 M1 |
| `NovaLayout` | QLayout | header/footer/drawer/page 集成布局 | 🚧 M1 |
| `NovaTable` | QTable | 排序/过滤/分页/多选数据表格 | 🚧 M1 |
| `NovaNotify` / `NovaDialog` | Notify / Dialog 插件 | 命令式服务单例 | 🚧 M2 |

完整 68 项对标清单见 [docs/ROADMAP.md](docs/ROADMAP.md)。

## 项目结构（src 布局）

```
pyside-nova/
├── pyproject.toml                  # hatchling 打包，wheel 内含 QML 资源
├── src/pyside_nova/
│   ├── __init__.py                 # init_nova(engine)
│   ├── __about__.py                # 版本唯一来源
│   └── qml/Nova/
│       ├── Services/               # NovaTheme / NovaScreen 单例
│       ├── Controls/               # NovaBtn / NovaCard / NovaChip ...
│       └── Behaviors/              # NovaRipple
├── examples/
│   ├── demo/                       # 精简演示
│   └── gallery/                    # 组件画廊（侧边导航 + 分页）
├── docs/                           # 架构 / 令牌 / API / 路线图
├── scripts/
│   ├── fetch_icons.py              # 下载 MDI/Material 图标包到 icons/
│   └── local_deploy.py             # 一键打包部署（build→install→test）
├── tests/test_smoke.py             # QML 解析 + 实例化冒烟测试
└── .github/workflows/              # CI（Win+Linux 矩阵）与 PyPI 可信发布
```

每个 `.py` / `.qml` 文件均以两行头注释开头：第 1 行为**从 `src/` 开始的完整文件子路径**，第 2 行为
组件/文件说明——该说明直接沉淀为 API 文档（docs）素材：

```
// src/pyside_nova/qml/Nova/Controls/NovaIcon.qml
// NovaIcon 图标组件：icon="mdi:home" 式 API，本地图标包优先、云端 CDN 自动回落（对标 QIcon）
```

## 图标系统（NovaIcon）

```qml
NovaIcon { icon: "mdi:home"; size: 28 }                  // MDI 图标
NovaIcon { icon: "material:favorite"; color: "red" }     // Material 图标（默认单色化跟随 color）
NovaIcon { icon: "material-outlined:settings" }          // outlined / round / sharp / two-tone 变体
NovaBtn  { icon: "mdi:magnify"; round: true }            // NovaBtn 的 icon 属性自动识别图标引用
```

- **双通道加载**：优先本地图标包（`NovaTheme.iconLocalRoot`），本地缺失自动回落 jsDelivr
  云端 CDN（`@mdi/svg`、`@material-design-icons/svg`）
- **着色**：封装 QML `Image` + `MultiEffect` 色彩化，`monochrome: false` 保留原 SVG 彩色

## 离线部署与一键打包

```bash
# 1. 下载图标包到本地 icons/（约 1 万个 SVG，可选 --only mdi / --only material）
python scripts/fetch_icons.py

# 2. 一键本地打包部署：清理 → 构建 wheel → 本地安装 → 冒烟测试
python scripts/local_deploy.py
python scripts/local_deploy.py --zip --demo   # 额外生成发布 ZIP 包（源码 + wheel）并运行演示
```

demo / 画廊检测到 `icons/` 目录后自动启用本地通道（无需联网）。应用侧也可在 QML 中直接设置：
`NovaTheme.iconLocalRoot = "file:///C:/deploy/icons"`。

## 开发

```bash
pip install -e ".[dev]"
pytest -q                          # 冒烟测试（32 项）
python examples/gallery/main.py    # 可视化预览
python -m build                    # 构建 sdist + wheel
```

代码规范、架构与发布流程详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 发布到 PyPI（GitHub Actions 可信发布）

1. GitHub 仓库 → Settings → Environments 创建 `pypi` 环境
2. PyPI → Publishing → 添加 Trusted Publisher（仓库 + workflow `release.yml` + environment `pypi`）
3. 打标签触发发布：

```bash
git tag v0.2.0
git push origin v0.2.0
```

## 旗舰版封版路线

| 里程碑 | 范围 |
|---|---|
| **M0** ✅ | 基建 + 首批 12 组件 + 组件画廊 |
| **M1** | P0 旗舰组件（Layout / Table / Form / Date / Select / Notify / Dialog…） |
| **M2** | P1 企业增强 + 文档站 |
| **M3** | `1.0.0-flagship` 封版 —— API 冻结、WCAG 2.1 AA 门禁、LTS 24 个月 |

## 许可证

[MIT](LICENSE)
