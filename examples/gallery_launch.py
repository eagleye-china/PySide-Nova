# examples/gallery_launch.py
# 画廊 demo 独立入口（scripts/build_app.py 的 PyInstaller 打包目标，0.16.2 B3）
"""画廊 demo 可执行入口。

开发期：python examples/gallery_launch.py
打包后：QML 资源随 PyInstaller --add-data 进包，从 sys._MEIPASS 解析（onefile 解压目录）。
"""
import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent, QQmlEngine

from pyside_nova import init_nova


def resource_root() -> Path:
    """返回 examples/ 资源根目录（其下直接是 gallery/main.qml）。

    开发期：本文件位于 <repo>/examples/gallery_launch.py，根 = 文件所在目录；
    打包后：--add-data examples->examples，根 = sys._MEIPASS/examples。
    历史 bug（0.16.2 B3）：开发期曾用文件所在目录再拼一层 examples/，
    得到不存在的 examples/examples/gallery/main.qml。
    """
    if getattr(sys, "frozen", False) and hasattr(sys, "_MEIPASS"):
        return Path(sys._MEIPASS) / "examples"
    return Path(__file__).resolve().parent


def main() -> int:
    app = QGuiApplication(sys.argv)
    engine = QQmlEngine()
    init_nova(engine)

    qml = resource_root() / "gallery" / "main.qml"
    comp = QQmlComponent(engine, QUrl.fromLocalFile(str(qml)))
    win = comp.create()
    if win is None:
        print("QML 加载失败：", file=sys.stderr)
        for e in comp.errors():
            print(" ", e.toString(), file=sys.stderr)
        return 1
    win.show()
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
