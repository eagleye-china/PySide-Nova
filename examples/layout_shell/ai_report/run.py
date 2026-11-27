# examples/layout_shell/ai_report/run.py
"""NovaAIReport 成品级演示启动器（组合宪法第 8 章 Gallery 门禁）。

运行::

    python examples/layout_shell/ai_report/run.py
    python examples/layout_shell/ai_report/run.py --rows 1200 --page-size 20
    python examples/layout_shell/ai_report/run.py --seed 20261128

架构与 ``pipeline.inject()`` / ``audit_showcase.py`` / ``audit_ceiling.py``
共用同一套数据管道，避免"演示态"与"验收态"账实不符。
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import init_nova

DEMO_DIR = Path(__file__).resolve().parent
if str(DEMO_DIR) not in sys.path:
    sys.path.insert(0, str(DEMO_DIR))

import data as plant
from pipeline import REPO_ROOT, inject


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="NovaAIReport · 智能报表工作台演示")
    parser.add_argument("--rows", type=int, default=plant.DEFAULT_ROWS,
                        help=f"电解槽行数（默认 {plant.DEFAULT_ROWS}）")
    parser.add_argument("--seed", type=int, default=plant.DEFAULT_SEED,
                        help="数据随机种子（确定性可复现）")
    parser.add_argument("--page-size", type=int, default=plant.DEFAULT_PAGE_SIZE,
                        help=f"分页大小（默认 {plant.DEFAULT_PAGE_SIZE}）")
    args = parser.parse_args(argv)

    app = QGuiApplication.instance() or QGuiApplication(sys.argv)
    app.setApplicationName("nova-demo-ai-report")
    engine = QQmlApplicationEngine()
    init_nova(engine)
    icons = REPO_ROOT / "icons"
    if icons.is_dir():
        engine.rootContext().setContextProperty("novaIconLocalRoot", icons.as_uri())

    # 保持数据管道与宿主桥的强引用，避免离屏期间被 GC 提前析构（坑位 49）
    _handles = inject(
        engine,
        rows=plant.generate_rows(max(1, args.rows), args.seed),
        seed=args.seed,
        page_size=max(1, args.page_size),
    )
    engine.load(str(DEMO_DIR / "main.qml"))
    if not engine.rootObjects():
        print("QML 加载失败：无根对象", file=sys.stderr)
        return 1
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
