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


# ── Windows 任务栏分组 / 图标缓存隔离（自包含）────────────────────
# 未显式设置 AppUserModelID 时，Windows 按「可执行文件路径」分组并缓存
# 任务栏图标 —— 11 个 demo 都由同一个 python.exe 启动，会共享同一缓存项，
# 于是出现「标题栏小图标正确、任务栏按钮仍是默认图标」的怪象，且表现随
# 运行顺序 / 缓存新旧漂移（同一份代码 agent 正常、ai_report 异常即此故）。
# 设唯一 AppID 后每个 demo 拥有独立分组与独立缓存项，图标即时生效。
# Windows 要求进程级 AppID 在创建任何窗口之前设置，且只成功一次；
# 非 Windows 静默 no-op，已存在窗口时设置失败亦不影响主流程。
def _set_app_user_model_id(app_id: str) -> None:
    import ctypes

    if sys.platform != "win32":
        return
    try:
        fn = ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID
    except (AttributeError, OSError):
        return
    with suppress(AttributeError, OSError):
        fn.argtypes = [ctypes.c_wchar_p]
        fn.restype = ctypes.c_long
        fn(app_id)


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
    # 必须早于任何窗口创建：进程级 AppID 一旦有窗口即不可再改
    _set_app_user_model_id("Nova.PySide6.Demo.AIReport")
    app.setApplicationName("nova-demo-ai-report")
    engine = QQmlApplicationEngine()
    init_nova(engine)
    # qrc 由 init_nova() 注册后才可取图标，顺序不可颠倒
    app_icon = QIcon(":/icons/app-aireport")
    app.setWindowIcon(app_icon)
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
        # 原生句柄就绪后重设 ICON_BIG / ICON_SMALL：双保险，避免 QQuickWindow
        # 创建时只落小图标、任务栏沿用进程默认图标（Windows shell 缓存路径）
        window.setIcon(app_icon)
        window.darkChromeChanged.connect(_sync_title_bar)
        QTimer.singleShot(10, lambda: _sync_title_bar(True))
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
