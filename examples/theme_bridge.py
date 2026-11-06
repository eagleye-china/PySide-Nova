import sys
from pathlib import Path

from PySide6.QtCore import QObject, Property, Signal
from PySide6.QtGui import QGuiApplication, QColor
from PySide6.QtQml import QQmlApplicationEngine


class NovaTheme(QObject):
    """这是一个将被注入到 QML 中的 Python 类"""

    def __init__(self):
        super().__init__()
        self._primary_color = QColor("#0078D4")

    # 使用 Property 暴露给 QML
    def _get_primary(self):
        return self._primary_color

    def _set_primary(self, color):
        self._primary_color = color
        self.primaryChanged.emit()

    primaryChanged = Signal()
    primaryColor = Property(QColor, _get_primary, _set_primary)


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # ✅ 核心步骤：把 Python 对象注入到 QML 的全局上下文中
    theme_instance = NovaTheme()
    engine.rootContext().setContextProperty("NovaTheme", theme_instance)

    engine.load(Path(__file__).parent / "theme_bridge.qml")

    sys.exit(app.exec())
