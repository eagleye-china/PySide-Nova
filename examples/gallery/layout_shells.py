# examples/gallery/layout_shells.py
# Prescient Layout Shell 独立画廊启动入口：python examples/gallery/layout_shells.py
"""14 项组合根容器独立预览画廊（组合宪法 0.2.0 Gallery 门禁）。

与主画廊 main.py 分离，避免触碰 3898 行主文件；可独立加载、逐项调参、明暗切换。
"""
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import init_nova

ROOT = Path(__file__).resolve().parents[2]


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setApplicationName("pyside-nova-layout-shells")

    engine = QQmlApplicationEngine()
    init_nova(engine)

    icons_dir = ROOT / "icons"
    if icons_dir.is_dir():
        engine.rootContext().setContextProperty("novaIconLocalRoot", icons_dir.as_uri())

    qml_file = Path(__file__).resolve().parent / "layout_shells.qml"
    engine.load(str(qml_file))
    if not engine.rootObjects():
        return 1
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
