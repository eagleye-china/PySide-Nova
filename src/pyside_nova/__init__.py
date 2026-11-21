# src/pyside_nova/__init__.py
# pyside-nova Python 接入层：init_nova(engine) 注册 Nova.* QML 导入路径，一行接入
"""pyside-nova —— 面向 PySide6 的企业级 QML 组件库（对标 Quasar Framework）。

快速开始::

    import sys
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQml import QQmlApplicationEngine
    from pyside_nova import init_nova

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    init_nova(engine)          # 注册 QML 导入路径
    engine.load("main.qml")    # 在 QML 中: import Nova.Controls

QML 模块划分::

    import Nova.Services   # NovaTheme 等全局单例服务（主题/令牌）
    import Nova.Controls   # NovaBtn / NovaCard / NovaChip ... 组件
    import Nova.Behaviors  # NovaRipple 等 attached property 行为
"""
from pathlib import Path

from .__about__ import __title__, __version__

__all__ = ["__title__", "__version__", "init_nova", "QML_ROOT"]

# QML 模块根目录（qml/Nova/{Services,Controls,Behaviors}）
# 统一转成正斜杠，保证 Windows / macOS / Linux 表现一致
QML_ROOT = (Path(__file__).resolve().parent / "qml").as_posix()


def init_nova(engine) -> None:
    """将 pyside-nova 的 QML 模块注册到引擎，使 ``import Nova.*`` 生效。

    Args:
        engine: ``QQmlEngine`` 或 ``QQmlApplicationEngine`` 实例。
    """
    engine.addImportPath(QML_ROOT)
