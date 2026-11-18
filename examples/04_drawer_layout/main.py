import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtQml import QQmlApplicationEngine, QQmlComponent
from PySide6.QtGui import QGuiApplication
from pyside_nova import install_qml_import_path

def main():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    def on_warnings(warnings):
        for warning in warnings:
            print(f"[QML WARNING] {warning.toString()}")

    engine.warnings.connect(on_warnings)
    install_qml_import_path(engine)

    demo_qml = Path(__file__).parent / "main.qml"
    if not demo_qml.exists():
        print(f"\n❌ [致命错误] 找不到 QML 文件：{demo_qml}")
        sys.exit(-1)

    qml_url = QUrl.fromLocalFile(str(demo_qml))
    
    component = QQmlComponent(engine, qml_url)
    if component.isError():
        print("\n❌ 发现 QML 编译错误:")
        for error in component.errors():
            print(f"  - {error.toString()}")
        sys.exit(-1)

    engine.load(qml_url)
    if not engine.rootObjects():
        sys.exit(-1)
        
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
