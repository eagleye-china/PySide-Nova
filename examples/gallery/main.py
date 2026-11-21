# examples/gallery/main.py
# 组件画廊启动入口：python examples/gallery/main.py
"""pyside-nova 组件画廊（Gallery）启动入口。

运行::

    python examples/gallery/main.py

自动检测项目根目录的 icons/（由 scripts/fetch_icons.py 产出），
存在则启用 NovaIcon 离线通道，否则走云端 CDN。
"""
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import init_nova

ROOT = Path(__file__).resolve().parents[2]   # 项目根目录


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setApplicationName("pyside-nova-gallery")

    engine = QQmlApplicationEngine()
    init_nova(engine)

    # 离线图标通道：检测 icons/ 目录（对应 NovaTheme.iconLocalRoot）
    icons_dir = ROOT / "icons"
    if icons_dir.is_dir():
        engine.rootContext().setContextProperty(
            "novaIconLocalRoot", icons_dir.as_uri())

    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(str(qml_file))
    if not engine.rootObjects():
        return 1
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
