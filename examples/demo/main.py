# examples/demo/main.py
# pyside-nova 精简演示启动入口：自动检测 icons/ 目录启用离线图标通道
"""pyside-nova 组件演示：python examples/demo/main.py"""
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import init_nova


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setApplicationName("pyside-nova-demo")

    engine = QQmlApplicationEngine()
    init_nova(engine)

    # 离线图标包：仓库根目录存在 icons/（fetch_icons.py 产出）时自动启用本地通道
    icons_dir = Path(__file__).resolve().parents[2] / "icons"
    if (icons_dir / "mdi").exists():
        engine.rootContext().setContextProperty("novaIconLocalRoot", icons_dir.as_uri())

    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(str(qml_file))
    if not engine.rootObjects():
        return 1
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
