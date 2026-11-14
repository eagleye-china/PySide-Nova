# src/pyside_nova/bridge/theme_manager.py

from PySide6.QtCore import QObject, Property, Signal, QSettings


class ThemeManager(QObject):
    modeChanged = Signal(str)

    def __init__(self):
        super().__init__()
        self._settings = QSettings("NovaFramework", "NovaApp")
        self._mode = str(self._settings.value("theme_mode", "dark"))
        print(f"📥 [ThemeManager 启动]: {self._mode}")

    def _get_mode(self):
        return self._mode

    def _set_mode(self, value):
        print(f"⚡ [Python 收到切换请求]: {value}")
        if self._mode != value:
            self._mode = value
            self._settings.setValue("theme_mode", value)
            self._settings.sync()  # 强制落盘
            print(f"✅ [注册表写入成功]: {value}")
            self.modeChanged.emit(self._mode)

    # 使用 Property 暴露给 QML，可直接赋值和读取
    mode = Property(str, _get_mode, _set_mode, notify=modeChanged)
