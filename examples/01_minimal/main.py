import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


def main() -> int:
    app = QGuiApplication(sys.argv)

    engine = QQmlApplicationEngine()

    # ✅ 核心：捕获 QML 报错
    engine.warnings.connect(lambda warnings: [print("🚨 QML Error:", w.toString()) for w in warnings])

    qml_root = Path(__file__).resolve().parents[2] / "src" / "pyside_nova" / "qml"
    print(f"🔍 QML 导入根目录: {qml_root}")
    if not qml_root.exists():
        print(f"❌ 错误: QML 目录不存在，请检查！")
        return -1

    engine.addImportPath(str(qml_root))

    qml_file = Path(__file__).with_name("main.qml")
    print(f"🔍 正在加载文件: {qml_file}")

    engine.load(QUrl.fromLocalFile(str(qml_file)))
    if not engine.rootObjects():
        print("❌ 加载失败！请检查上方的 QML Error 输出。")
        return -1

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
