# tests/conftest.py
# 测试全局夹具：整个测试进程共用「一个 QGuiApplication + 一个 QQmlEngine」（0.16.0 稳定性修复）
"""pyside-nova 测试全局夹具。

**为什么必须共用单引擎**（0.16.0 实战结论）：
QML 回归测试若让多个模块各自 `QQmlEngine()` 并在模块结束时析构，Qt 6.12 会在「一个引擎已销毁、
另一个引擎继续创建组件」时**间歇性 SIGSEGV**（实测：0.15.0 的 322 项稳定；加入 a11y 模块后
343 项有 20~60% 概率在 `component.create()` 处崩溃，与用例内容无关、与引擎数量强相关）。
改为全进程单引擎后稳定；且引擎常驻可避免「Window 活到解释器退出、而 QGuiApplication 已析构」
的第二类崩溃。
"""
from __future__ import annotations

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtGui import QGuiApplication, QWindow
from PySide6.QtQml import QQmlEngine

from pyside_nova import init_nova

# 存活对象登记表：全进程共用，模块收尾时统一关闭（不删除引擎/应用）
ALIVE: list = []


@pytest.fixture(scope="session")
def qapp():
    app = QGuiApplication.instance() or QGuiApplication([])
    assert app is not None
    yield app


@pytest.fixture(scope="session")
def qml_engine(qapp):
    """全进程唯一的 QML 引擎（初始化一次，进程结束前不析构）。"""
    eng = QQmlEngine()
    init_nova(eng)
    yield eng


def close_alive() -> None:
    """关闭并释放登记表内的 QML 对象（按创建逆序）；引擎与应用保持存活。"""
    for obj in reversed(ALIVE):
        try:
            if isinstance(obj, QWindow):
                obj.close()
        except RuntimeError:
            pass
    ALIVE.clear()


def pytest_sessionfinish(session, exitstatus):  # noqa: ARG001
    """进程收尾：先释放窗口，再让 Qt 正常析构（避免退出期 SIGSEGV）。"""
    close_alive()
    app = QGuiApplication.instance()
    if app is not None:
        app.processEvents()
