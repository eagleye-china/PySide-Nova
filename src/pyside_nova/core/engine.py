# src/pyside_nova/core/engine.py
from pathlib import Path
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl


def create_engine() -> QQmlApplicationEngine:
    """创建一个配置好的 QML 引擎，自动加入 Nova 的组件路径"""
    engine = QQmlApplicationEngine()

    # ✅ 获取当前 Nova 的 qml 文件夹绝对路径
    qml_dir = Path(__file__).parent.parent / "qml"

    # ✅ 将路径加入 QML 引擎的导入路径中
    engine.addImportPath(str(qml_dir))

    return engine
