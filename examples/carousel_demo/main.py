# examples/carousel_demo/main.py
"""NovaCarousel 轮播组件独立演示启动器。

运行：python examples/carousel_demo/main.py
依赖：conda pyside6_nova 环境（含 PySide6 6.8+ 与编辑态 pyside_nova）。
"""
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import init_nova


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setApplicationName("nova-carousel-demo")

    engine = QQmlApplicationEngine()
    init_nova(engine)  # 注册 Nova.* QML 模块（单引擎，坑位 42）

    # 仓库根存在 icons/（fetch_icons.py 产出）时启用离线图标通道，箭头图标可离线显示
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
