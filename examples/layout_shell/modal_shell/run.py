# examples/layout_shell/modal_shell/run.py
# NovaModalShell 独立演示启动器：python examples/layout_shell/modal_shell/run.py
"""NovaModalShell 独立演示（组合宪法 0.2.0）。"""
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import init_nova

ROOT = Path(__file__).resolve().parents[3]


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setApplicationName("nova-demo-modal_shell")
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
