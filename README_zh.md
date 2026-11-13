# PySide Nova ⚛️

[![PyPI](https://img.shields.io/pypi/v/pyside-nova?color=blue&label=PyPI)](https://pypi.org/project/pyside-nova/)
[![Python](https://img.shields.io/badge/python-3.10%2B-blue)](https://www.python.org/)
[![Qt](https://img.shields.io/badge/Qt-6.5%2B-green)](https://www.qt.io/)
[![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/eagleye-china/PySide-Nova/blob/main/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/eagleye-china/PySide-Nova?style=social)](https://github.com/eagleye-china/PySide-Nova)

[English](https://github.com/eagleye-china/PySide-Nova/blob/main/README.md) | **简体中文**

**Nova** 是面向 **PySide6 + Qt Quick(QML)** 打造的企业级组件库。

与姊妹库 [pyside-quasar](https://github.com/eagleye-china/pyside-quasar)（PySide6 **Widgets** 版）共享同一套设计规范与属性契约 —— **一套属性，两套渲染底座**。

**Nova** 专为工业 HMI、触摸屏、监控大屏与嵌入式面板而生：支持 GPU 硬件渲染、MVVM 架构友好、高 DPI 像素级安全、键盘 / 触摸 / 鼠标三模交互，并内置统一的明暗主题与焦点环系统。

---

## 📦 安装

```bash
pip install pyside-nova
```

开发态安装：

```bash
git clone <repo>
cd pyside-nova
pip install -e ".[dev]"
```

---

## 🚀 快速开始

### Python 端
```python
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import install_qml_import_path, theme_manager

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()

install_qml_import_path(engine)                       # ① 注册 QML 导入路径

tm = theme_manager()
engine.rootContext().setContextProperty("novaTheme", tm)   # ② 注入主题管理器（可选）

engine.load(Path(__file__).with_name("main.qml"))
if not engine.rootObjects():
    sys.exit(1)

tm.attach_engine(engine)                               # ③ load 之后绑定主题单例
sys.exit(app.exec())
```

### QML 端
```qml
import QtQuick
import Nova 1.0

Window {
    width: 480; height: 240
    visible: true
    color: Theme.background

    NovaButton {
        anchors.centerIn: parent
        label: "启动"
        color: "positive"
        onClicked: console.log("started")
    }
}
```

> ⚠️ **高频踩坑预警**：忘记调用 `install_qml_import_path()` 是最常见的错误。若未调用，QML 引擎会直接报错 `module "Nova" is not installed`。

---

## 📐 属性契约（两库共用）

为了保证 Widgets 和 QML 双端体验的绝对一致，Nova 严格遵循以下属性规范：

| 属性名 | 允许取值 / 类型 |
| :--- | :--- |
| `color` | `primary` `secondary` `positive` `negative` `warning` `info` `dark` `white` |
| `variant` | `filled` `outlined` `flat` `text` `push` |
| `size` | `xs` `sm` `md` `lg` `xl` 或整数像素 |
| `rounded` / `elevated` / `dense` | `bool` |
| `loading` / `disabled` | `bool` |
| `label` / `icon` / `iconRight` | `string` / `url` |

*注：命名一旦发布**绝不再改动**，后续新增语义只允许追加，严禁改名或建立同义别名。*

---

## 📂 目录速览

```text
src/pyside_nova/
├── __init__.py            # install_qml_import_path() / theme_manager()
├── theme/
│   ├── tokens.py          # ⭐ 设计 token 唯一真源 (Single Source of Truth)
│   └── manager.py         # NovaThemeManager：明暗主题切换逻辑
├── core/
│   ├── bridge.py          # NovaBridgeBase：带异常兜底的通信基类
│   └── worker.py          # BaseWorker / ThreadRunner：工控异步线程基座
└── qml/Nova/
    ├── qmldir             # QML 模块声明（新增组件必须在此登记）
    ├── Theme.qml          # ⚠️ 自动生成物，由 tools/gen_theme.py 产出
    ├── Units.qml          # dp 单位换算入口
    └── NovaButton.qml
```

> 💡 **改颜色 / 改间距的唯一正确姿势**：
> 编辑 `theme/tokens.py` -> 运行 `python tools/gen_theme.py` -> 提交这两个文件。
> **严禁手改 `Theme.qml`**（CI 会用 `--check` 校验两者一致性）。

---

## 🛠️ 开发命令

```bash
ruff format src tests examples tools      # 格式化代码
ruff check src tests examples tools       # 静态类型检查
python tools/gen_theme.py                 # 生成 Theme.qml
python tools/gen_theme.py --check         # 校验生成物是否最新
pyside6-qmllint -I src/pyside_nova/qml src/pyside_nova/qml/Nova/*.qml # QML语法检查
pytest -v                                 # 运行单元测试
python examples/01_minimal/main.py        # 运行最小演示示例
python -m build && twine check dist/*     # 打包并校验
```

---

## 📌 版本策略

- 采用独立 SemVer 规范，与 `pyside-quasar` **不强制对齐版本号**，只保证同一份设计 Token 保持一致；
- 最低支持：PySide6 ≥ 6.5 LTS（主力测试于 6.8 LTS）；
- 新增组件只能在 v1.0 之后追加，绝不删减已发布的属性。

## 📜 License

MIT License，允许商用和二次修改。