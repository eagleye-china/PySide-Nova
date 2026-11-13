# src/pyside_nova/bridge/theme_manager.py

from PySide6.QtCore import QObject, Property, Signal, QSettings


class ThemeManager(QObject):
    modeChanged = Signal(str)

    def __init__(self):
        super().__init__()
        self._settings = QSettings("NovaFramework", "NovaApp")
        self._mode = str(self._settings.value("theme_mode", "light"))
        print(f"🌓 [Python] 初始化主题模式: {self._mode}")

    def _get_mode(self):
        return self._mode

    def _set_mode(self, value):
        if self._mode != value:
            self._mode = value
            self._settings.setValue("theme_mode", value)
            print(f"✅ [Python] 收到切换指令，新主题: {value}")
            self.modeChanged.emit(self._mode)

    mode = Property(str, _get_mode, _set_mode, notify=modeChanged)
