# PySide-Nova 🌟

> **专为 PySide 打造的 GPU 硬件加速、QML 驱动的 UI 框架。**  
> *PySide-Quasar 的极速孪生兄弟。专为丝滑动画与现代桌面应用而生。*

[English](https://github.com/eagleye-china/PySide-Nova/blob/main/README.md) | **简体中文**

[![PyPI version](https://img.shields.io/badge/pypi-coming_soon-orange)](https://pypi.org/project/pyside-nova/)
[![Python Version](https://img.shields.io/badge/python-3.10%2B-blue)](https://pypi.org/project/pyside-nova/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

**PySide-Nova** 是一套新一代的企业级 UI 框架，它将 **QML (Qt Quick)** 的原生速度与 **Python** 的稳健性完美结合。

如果说我们的兄弟项目 **[PySide-Quasar](https://github.com/eagleye-china/PySide-Quasar)** 专注于高密度工业表单的像素级 `QPainter` 渲染，那么 **PySide-Nova** 则完全聚焦于 **GPU 硬件加速、60帧丝滑动画以及响应式布局**。

## ✨ 为什么选择 Nova？

- ⚡ **GPU 加速**：完全基于 QML 场景图构建，拒绝掉帧，享受极致丝滑。
- 🎨 **声明式 UI**：像写 CSS 一样写界面，用 Python 写逻辑。前后端彻底分离。
- 🔗 **无缝的 Python 交互**：原生支持 QML 与 Python 之间的 `QProperty`、信号与槽。
- 🖥️ **原生 4K/Retina 适配**：原生浮点坐标系统，彻底告别手算 DPI。

## 🚀 快速开始 (即将到来)

```bash
pip install pyside-nova
```

## 📐 架构设计

```text
pyside-nova/
├── src/pyside_nova/
│   ├── core/        # Python 后端逻辑 (主题引擎、i18n、应用状态)
│   ├── python/      # 暴露给 QML 的 Python 对象
│   └── qml/         # 纯 QML 组件库 (NovaButton, NovaCard)
```