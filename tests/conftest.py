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


def pytest_configure(config):
    config.addinivalue_line("markers", "visual: 全矩阵视觉回归门禁（scripts/check_visual.py 承载）")
    config.addinivalue_line("markers", "soak: 24h 内存长跑（scripts/check_soak.py 承载）")


def pytest_addoption(parser):
    """0.16.2 视觉回归开关 + 1.0.0 24h 压测开关（对应 CLI 传入）。"""
    parser.addoption("--visual-full", action="store_true", default=False,
                     help="跑全矩阵视觉门禁（明暗 × 5 断点 × 24 页）")
    parser.addoption("--snapshot-update", action="store_true", default=False,
                     help="重建视觉基线（tests/baselines/visual/）")
    parser.addoption("--soak-hours", type=float, default=24.0,
                     help="24h 压测时长（小时）；默认 24，冒烟 0.02")
    parser.addoption("--soak-interval", type=float, default=300.0,
                     help="内存采样间隔（秒）；默认 300（24h 得 288+ 样本）")
    parser.addoption("--soak-report", default="",
                     help="压测报告 JSON 输出路径（可选）")


def close_alive() -> None:
    """关闭并释放登记表内的 QML 对象（按创建逆序）；引擎与应用保持存活。"""
    for obj in reversed(ALIVE):
        try:
            if isinstance(obj, QWindow):
                obj.close()
        except RuntimeError:
            pass
    ALIVE.clear()


def pytest_unconfigure(config):  # noqa: ARG001
    """坑位 49：长跑（视觉全矩阵 / 24h soak）后解释器收尾期 GC 崩溃（shiboken refcount）——
    报告输出已完成后硬退出，规避收尾期隐式析构，保 CI 退出码语义。"""
    if getattr(config, "_nova_visual_hard_exit", False) or \
       getattr(config, "_nova_soak_hard_exit", False):
        import sys
        # 失败用例必须以非零码退出：sessionfinish 已记录 exitstatus
        code = int(getattr(config, "_nova_exit_code", 0))
        sys.stdout.flush()
        sys.stderr.flush()
        os._exit(code)


def pytest_sessionfinish(session, exitstatus):  # noqa: ARG001
    """进程收尾：先释放窗口，再让 Qt 正常析构（避免退出期 SIGSEGV）。
    同时记录退出码供 unconfigure 硬退出时还原（坑位 49 的 CI 语义）。"""
    session.config._nova_exit_code = int(exitstatus)
    close_alive()
    app = QGuiApplication.instance()
    if app is not None:
        app.processEvents()
