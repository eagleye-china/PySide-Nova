# examples/layout_shell/ai_report/run.py
"""NovaAIReport 成品级演示启动器（组合宪法第 8 章 Gallery 门禁）。

运行::

    python examples/layout_shell/ai_report/run.py
    python examples/layout_shell/ai_report/run.py --rows 1200 --page-size 20
    python examples/layout_shell/ai_report/run.py --seed 20261128

架构与 ``pipeline.inject()`` / ``audit_showcase.py`` / ``audit_ceiling.py``
共用同一套数据管道，避免"演示态"与"验收态"账实不符。
"""
from __future__ import annotations

import argparse
import sys
from contextlib import suppress
from pathlib import Path

from PySide6.QtCore import QTimer
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from pyside_nova import init_nova


# ── Windows 原生标题栏明暗同步（自包含，不依赖 nova-forge）──────────
# 契约与 nova-forge prescript 孵化产物 ``main.py::_sync_title_bar`` 一致：
# QML 侧 ``darkChromeChanged(bool)`` → DWM immersive dark mode。
# 库内 demo 是独立工程，运行时读不到 nova-forge 的 utils / qrc，故在此自包含。
# 非 Windows 平台静默 no-op；句柄未就绪 / 无 DWM 均不影响主流程。
def _window_handle(window) -> int:
    """尽力取顶层窗口 winId；窗口尚未创建 / 平台异常时返回 0。"""
    with suppress(AttributeError, TypeError, ValueError, RuntimeError):
        return int(window.winId())
    return 0


def _sync_title_bar(dark: bool) -> None:
    import ctypes

    if sys.platform != "win32":
        return
    try:
        dwmapi = ctypes.windll.dwmapi
    except (AttributeError, OSError):
        return  # 无 DWM
    dwmapi.DwmSetWindowAttribute.argtypes = [
        ctypes.c_void_p, ctypes.c_uint32, ctypes.c_void_p, ctypes.c_uint32
    ]
    dwmapi.DwmSetWindowAttribute.restype = ctypes.c_long
    value = ctypes.c_int(1 if dark else 0)
    for window in QGuiApplication.topLevelWindows():
        hwnd = _window_handle(window)
        if not hwnd:
            continue
        # 属性 20 = Win10 2004+ / Win11；失败回退属性 19 = Win10 1809~1909
        res = dwmapi.DwmSetWindowAttribute(
            ctypes.c_void_p(hwnd), 20, ctypes.byref(value), ctypes.sizeof(value)
        )
        if res != 0:
            dwmapi.DwmSetWindowAttribute(
                ctypes.c_void_p(hwnd), 19, ctypes.byref(value), ctypes.sizeof(value)
            )

DEMO_DIR = Path(__file__).resolve().parent
if str(DEMO_DIR) not in sys.path:
    sys.path.insert(0, str(DEMO_DIR))

import data as plant
from pipeline import REPO_ROOT, inject


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="NovaAIReport · 智能报表工作台演示")
    parser.add_argument("--rows", type=int, default=plant.DEFAULT_ROWS,
                        help=f"电解槽行数（默认 {plant.DEFAULT_ROWS}）")
    parser.add_argument("--seed", type=int, default=plant.DEFAULT_SEED,
                        help="数据随机种子（确定性可复现）")
    parser.add_argument("--page-size", type=int, default=plant.DEFAULT_PAGE_SIZE,
                        help=f"分页大小（默认 {plant.DEFAULT_PAGE_SIZE}）")
    args = parser.parse_args(argv)

    app = QGuiApplication.instance() or QGuiApplication(sys.argv)
    app.setApplicationName("nova-demo-ai-report")
    engine = QQmlApplicationEngine()
    init_nova(engine)
    # qrc 由 init_nova() 注册后才可取图标，顺序不可颠倒
    app.setWindowIcon(QIcon(":/icons/app-aireport"))
    icons = REPO_ROOT / "icons"
    if icons.is_dir():
        engine.rootContext().setContextProperty("novaIconLocalRoot", icons.as_uri())

    # 保持数据管道与宿主桥的强引用，避免离屏期间被 GC 提前析构（坑位 49）
    _handles = inject(
        engine,
        rows=plant.generate_rows(max(1, args.rows), args.seed),
        seed=args.seed,
        page_size=max(1, args.page_size),
    )
    engine.load(str(DEMO_DIR / "main.qml"))
    if not engine.rootObjects():
        print("QML 加载失败：无根对象", file=sys.stderr)
        return 1
    # 原生标题栏随 QML 主题同步：初始暗色 + 每次明暗切换
    # 无信号（离屏实跑 / 非 Qt 窗口）时静默跳过，不影响主流程
    window = engine.rootObjects()[0]
    with suppress(AttributeError, RuntimeError):
        window.darkChromeChanged.connect(_sync_title_bar)
        QTimer.singleShot(10, lambda: _sync_title_bar(True))
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
