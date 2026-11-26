# scripts/audit_showcase.py
# 装配态三态出图审计（CARF-R / 组合宪法第 9 章 CC-7）：浅色 / 深色 / 变体态真实引擎渲染
"""组合根容器 showcase 的装配态验收出图工具。

法源：母法卷首 CARF 宣言（R 打磨阶段）· 组合宪法 1.0.0 第 9 章 CC-7 / CC-8
      · docs/prescript/AUDIT_CEILING.md（逐项销号台账）

用法：
    python scripts/audit_showcase.py --name desktop
    python scripts/audit_showcase.py --all
    python scripts/audit_showcase.py --name sidebar --width 1280 --height 800

输出：docs/screenshots/<name>_showcase_light.png / _dark.png / _variant.png

约定（CC-8 参考实现纪律）：
  - 每个 showcase 暴露 `property bool variantMode: false`，脚本置真渲染变体态；
  - 主题经 NovaTheme.setDark() 切换（与 tests/conftest.py 单引擎纪律一致）；
  - 每个 showcase 单独进程渲染（坑位 49：退出期 shiboken 隐式析构崩溃，收尾硬退出）；
  - 中文字体显式加载（坑位 15：offscreen 缺字体渲染成豆腐块）。
"""
from __future__ import annotations

import argparse
import os
import sys
import time
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

from PySide6.QtCore import QUrl  # noqa: E402
from PySide6.QtGui import QFont, QFontDatabase, QGuiApplication  # noqa: E402
from PySide6.QtQml import QQmlComponent, QQmlEngine  # noqa: E402
# 必须先导入 QQuickWindow 类型：shiboken 只有在该类型已注册时，才把 ApplicationWindow
# 包装成 QQuickWindow（否则退回 QWindow 基类，grabWindow() 不存在——0.9.1 批次实测坑位）
from PySide6.QtQuick import QQuickWindow  # noqa: E402,F401

from pyside_nova import init_nova  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = ROOT / "examples" / "layout_shell"
SHOTS = ROOT / "docs" / "screenshots"

NAMES = [
    "blank_page", "card_grid", "chat", "compare", "desktop", "drawer_panel",
    "dual_side", "flex_layout", "mobile", "modal", "setup_wizard", "sidebar",
    "tab_shell", "three_column", "top_navigation",
    "agent", "de", "copilot", "orbit", "incubator",
]

_PROBE = b"""
import QtQuick
import Nova.Services
QtObject {
    function setDark(v) { NovaTheme.setDark(v) }
    function isDark() { return NovaTheme.isDark }
}
"""


def _pump(seconds: float = 0.35) -> None:
    end = time.perf_counter() + seconds
    while time.perf_counter() < end:
        QGuiApplication.processEvents()
        time.sleep(0.01)


def _font() -> None:
    for candidate in ("C:/Windows/Fonts/msyh.ttc", "C:/Windows/Fonts/msyh.ttf"):
        if Path(candidate).exists():
            QFontDatabase.addApplicationFont(candidate)
            break
    app = QGuiApplication.instance()
    if app is not None:
        app.setFont(QFont("Microsoft YaHei", 10))


def _grab(win):
    """QQuickWindow.grabWindow()；shiboken 偶发把 ApplicationWindow 包装成 QWindow 基类，
    此时用类方法调用 + getCppPointer/wrapInstance 还原（0.9.1 批次实测坑位防御）。"""
    from PySide6.QtQuick import QQuickWindow
    try:
        return QQuickWindow.grabWindow(win)
    except (AttributeError, TypeError):
        import shiboken6
        ptr = shiboken6.getCppPointer(win)[0]
        qwin = shiboken6.wrapInstance(ptr, QQuickWindow)
        return QQuickWindow.grabWindow(qwin)


def _shoot(win, target: Path) -> None:
    img = _grab(win)
    if img.isNull():
        raise RuntimeError(f"grabWindow 返回空图：{target}")
    target.parent.mkdir(parents=True, exist_ok=True)
    if not img.save(str(target), "PNG"):
        raise RuntimeError(f"PNG 保存失败：{target}")
    if not target.exists() or target.stat().st_size < 1024:
        raise RuntimeError(f"截图文件异常：{target}")
    print(f"  ✓ {target.name}  ({img.width()}x{img.height()})")


def render(name: str, width: int = 0, height: int = 0) -> int:
    qml = EXAMPLES / name / "main.qml"
    if not qml.exists():
        raise FileNotFoundError(f"缺少 showcase：{qml}")
    app = QGuiApplication.instance() or QGuiApplication([])
    _font()
    engine = QQmlEngine()
    init_nova(engine)

    probe_comp = QQmlComponent(engine)
    probe_comp.setData(_PROBE, QUrl("qrc:/audit-probe.qml"))
    probe = probe_comp.create()
    if probe is None:
        raise RuntimeError("主题探针创建失败：" + " | ".join(e.toString() for e in probe_comp.errors()))

    win_comp = QQmlComponent(engine, QUrl.fromLocalFile(str(qml)))
    win = win_comp.create()
    if win is None:
        raise RuntimeError(f"{name} 加载失败：" + " | ".join(e.toString() for e in win_comp.errors()))
    if width and height:
        win.resize(width, height)
    _pump(0.5)

    prefix = "chat" if name == "chat" else ("flex" if name == "flex_layout" else name)
    out = SHOTS / f"{prefix}_showcase"

    # ① 浅色
    probe.setDark(False)
    try:
        win.setProperty("variantMode", False)
    except Exception:
        pass
    _pump(0.45)
    _shoot(win, Path(f"{out}_light.png"))

    # ② 深色
    probe.setDark(True)
    _pump(0.45)
    _shoot(win, Path(f"{out}_dark.png"))

    # ③ 变体态（浅色 + variantMode）
    probe.setDark(False)
    win.setProperty("variantMode", True)
    _pump(0.6)
    _shoot(win, Path(f"{out}_variant.png"))

    win.setProperty("variantMode", False)
    _pump(0.2)
    print(f"[{name}] 三态装配态出图完成 · 主题探针 {probe.isDark()}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="CARF-R 装配态三态出图审计")
    parser.add_argument("--name", default="", help="showcase 目录名；留空配合 --all")
    parser.add_argument("--all", action="store_true", help="渲染全部 20 项（逐项独立进程由外层循环承担）")
    parser.add_argument("--width", type=int, default=0)
    parser.add_argument("--height", type=int, default=0)
    args = parser.parse_args()
    names = NAMES if args.all else [args.name]
    if not names or not names[0]:
        parser.error("请指定 --name 或 --all")
    failed = []
    for name in names:
        try:
            print(f"[{name}] 开始装配态出图 …")
            render(name, args.width, args.height)
        except Exception as exc:  # noqa: BLE001
            import traceback
            failed.append((name, str(exc)))
            traceback.print_exc()
            print(f"[{name}] ✗ {exc}", file=sys.stderr)
    if failed:
        for name, err in failed:
            print(f"  - {name}: {err}", file=sys.stderr)
        return 1
    print("装配态三态出图审计 PASS ✓")
    return 0


if __name__ == "__main__":
    code = main()
    sys.stdout.flush()
    sys.stderr.flush()
    # 坑位 49：退出期 QML 对象隐式析构在 Qt 6.12 下可触发 shiboken 崩溃，出图完成后硬退出
    os._exit(code)
