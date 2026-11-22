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

from PySide6.QtQml import qmlRegisterSingletonType

from .__about__ import __title__, __version__
from .runtime import NovaRuntime

__all__ = ["__title__", "__version__", "init_nova", "QML_ROOT", "NovaRuntime"]

# QML 模块根目录（qml/Nova/{Services,Controls,Behaviors}）
# 统一转成正斜杠，保证 Windows / macOS / Linux 表现一致
QML_ROOT = (Path(__file__).resolve().parent / "qml").as_posix()

# 注册守卫（同一进程只注册类型一次；实例按引擎惰性创建）
_RUNTIME_REGISTERED = False


def _runtime_factory(engine):
    """每个 QML 引擎一个 NovaRuntime 实例（工厂式注册，避免跨引擎所有权踩踏）。"""
    return NovaRuntime()


def _ensure_runtime() -> None:
    """注册 ``Nova.Runtime`` QML 单例类型（幂等）。

    坑位记录（0.6.2）：``qmlRegisterSingletonInstance`` 在 PySide6 下把实例交给 QML 树管理，
    组件销毁即 delete Python 侧对象，二次访问报 "Internal C++ object already deleted"；
    且全局单实例无法被多个 QQmlEngine 安全共享。改用工厂式 ``qmlRegisterSingletonType``：
    引擎按需创建、PySide 侧不留悬空引用，多引擎（测试/多窗口）天然安全。
    """
    global _RUNTIME_REGISTERED
    if _RUNTIME_REGISTERED:
        return
    qmlRegisterSingletonType(NovaRuntime, "Nova.Runtime", 1, 0, "NovaRuntime", _runtime_factory)
    _RUNTIME_REGISTERED = True


def init_nova(engine) -> None:
    """将 pyside-nova 的 QML 模块注册到引擎，使 ``import Nova.*`` 生效。

    Args:
        engine: ``QQmlEngine`` 或 ``QQmlApplicationEngine`` 实例。
    """
    engine.addImportPath(QML_ROOT)
    _ensure_runtime()
