# examples/01_minimal/main.py

import sys
from pathlib import Path
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

current_dir = Path(__file__).resolve().parent
project_root = current_dir.parent.parent
sys.path.insert(0, str(project_root / "src"))

from pyside_nova.bridge.theme_manager import ThemeManager
from pyside_nova.bridge.chat_bridge import ChatBridge


def main() -> int:
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    theme_manager = ThemeManager()
    chat_bridge = ChatBridge()

    theme_manager.setParent(app)
    chat_bridge.setParent(app)

    engine.rootContext().setContextProperty("ThemeManager", theme_manager)
    engine.rootContext().setContextProperty("ChatBridge", chat_bridge)

    qml_root = project_root / "src" / "pyside_nova" / "qml"
    engine.addImportPath(str(qml_root))

    qml_file = current_dir / "main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    if not engine.rootObjects():
        return -1

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
