# examples/layout_shell/orbit/run.py
# NovaOrbit 独立演示启动器：python examples/layout_shell/orbit/run.py
"""NovaOrbit 意图轨道工作台独立演示（组合宪法第 8 章 Gallery 门禁）。"""
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import init_nova

ROOT = Path(__file__).resolve().parents[3]


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setApplicationName("nova-demo-orbit")
    engine = QQmlApplicationEngine()
    init_nova(engine)
    icons = ROOT / "icons"
    if icons.is_dir():
        engine.rootContext().setContextProperty("novaIconLocalRoot", icons.as_uri())
    engine.load(str(Path(__file__).resolve().parent / "main.qml"))
    if not engine.rootObjects():
        return 1
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
