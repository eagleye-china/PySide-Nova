from pathlib import Path
import sys
from PySide6.QtCore import QUrl
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication

def main():
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # 核心：指向qml目录（qml文件夹，不是Nova文件夹！）
    project_root = Path(__file__).parent.parent
    qml_import_path = project_root / "src" / "pyside_nova" / "qml"
    engine.addImportPath(str(qml_import_path))

    demo_qml = Path(__file__).parent / "nova_button_demo.qml"
    engine.load(QUrl.fromLocalFile(str(demo_qml)))

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
