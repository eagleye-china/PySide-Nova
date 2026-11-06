import sys
from pathlib import Path
from PySide6.QtGui import QGuiApplication
from src.pyside_nova.core.engine import create_engine
from src.pyside_nova.core.theme_bridge import NovaTheme  # 假设你把之前的主题类放到了这里

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = create_engine()

    # 注入主题
    theme = NovaTheme()
    engine.rootContext().setContextProperty("NovaTheme", theme)

    # 加载 QML
    engine.load(QUrl.fromLocalFile(str(Path(__file__).parent / "demo_button.qml")))

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
