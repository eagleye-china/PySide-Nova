# src/pyside_nova/bridge/theme_manager.py

from PySide6.QtCore import QObject, Property, Signal, QSettings


class ThemeManager(QObject):
    modeChanged = Signal()

    def __init__(self):
        super().__init__()
        # 使用 QSettings 把配置保存在系统注册表（Windows）或 ~/.config（Linux）
        self._settings = QSettings("NovaFramework", "NovaApp")
        self._mode = self._settings.value("theme_mode", "light")

    @Property(str, notify=modeChanged)
    def mode(self):
        return self._mode

    @mode.setter
    def mode(self, value):
        if self._mode != value:
            self._mode = value
            self._settings.setValue("theme_mode", value)
            self.modeChanged.emit()
