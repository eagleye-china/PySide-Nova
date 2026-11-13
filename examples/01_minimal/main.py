# examples/01_minimal/main.py

import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

# ✅ 加入 src 路径以导入 bridge
current_dir = Path(__file__).resolve().parent
project_root = current_dir.parent.parent
sys.path.insert(0, str(project_root / "src"))

from pyside_nova.bridge.theme_manager import ThemeManager
from pyside_nova.bridge.table_bridge import TableBridge


def main() -> int:
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # ✅ 将 Python 实例注册到 QML 上下文
    theme_manager = ThemeManager()
    table_bridge = TableBridge()

    # 🪄 核心修复：设置 Parent 防止被 Python 的 GC 垃圾回收
    theme_manager.setParent(app)
    table_bridge.setParent(app)

    engine.rootContext().setContextProperty("ThemeManager", theme_manager)
    engine.rootContext().setContextProperty("TableBridge", table_bridge)

    qml_root = project_root / "src" / "pyside_nova" / "qml"
    print(f"🔍 QML 导入根目录: {qml_root}")
    if not qml_root.exists():
        print("❌ 错误: QML 目录不存在！")
        return -1

    engine.addImportPath(str(qml_root))

    qml_file = current_dir / "main.qml"
    print(f"🔍 正在加载文件: {qml_file}")

    engine.load(QUrl.fromLocalFile(str(qml_file)))
    if not engine.rootObjects():
        print("❌ 加载失败！请检查上方的 QML Error 输出。")
        return -1

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
