import sys
from pathlib import Path
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)

    # 实例化 QML 引擎
    engine = QQmlApplicationEngine()

    # 定位到我们即将写的 QML 文件
    qml_file = Path(__file__).parent / "hello_nova.qml"

    # 加载 QML
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
