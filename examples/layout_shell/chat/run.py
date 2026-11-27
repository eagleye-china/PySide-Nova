# examples/layout_shell/chat/run.py
# NovaChat 独立演示启动器：python examples/layout_shell/chat/run.py
"""NovaChat 独立演示（组合宪法 0.4.0，对标 WorkBuddy 桌面端主窗口）。"""
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import init_nova

ROOT = Path(__file__).resolve().parents[3]


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setApplicationName("nova-demo-chat")
    engine = QQmlApplicationEngine()
    init_nova(engine)
    app.setWindowIcon(QIcon(":/icons/app-chat"))
    icons = ROOT / "icons"
    if icons.is_dir():
        engine.rootContext().setContextProperty("novaIconLocalRoot", icons.as_uri())
    engine.load(str(Path(__file__).resolve().parent / "main.qml"))
    if not engine.rootObjects():
        return 1
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
