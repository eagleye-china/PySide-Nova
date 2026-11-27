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
from pyside_nova.datagrid import (
    SEVERITY_FIELD,
    NovaDataGridColumn,
    NovaDataGridFilterProxy,
    NovaDataGridModel,
    NovaDataGridPagedProxy,
    NovaDataGridPagination,
)

ROOT = Path(__file__).resolve().parents[2]   # 项目根目录


def _build_datagrid_models():
    """Gallery 第 25 页 NovaDataGrid 的示例数据管道（工业槽位监控）。"""
    columns = [
        NovaDataGridColumn("slot", "槽号", width=120),
        NovaDataGridColumn("voltage", "电压(V)", width=120,
                           editable=True, editor="number"),
        NovaDataGridColumn("temp", "温度(°C)", width=130, align="right"),
        NovaDataGridColumn("state", "状态", width=110),
    ]
    rows = [
        {"slot": "A01", "voltage": 4.12, "temp": 935.5, "state": "正常", SEVERITY_FIELD: 0},
        {"slot": "B02", "voltage": 3.98, "temp": 941.2, "state": "预警", SEVERITY_FIELD: 1},
        {"slot": "C03", "voltage": 3.71, "temp": 988.9, "state": "严重", SEVERITY_FIELD: 2},
        {"slot": "D04", "voltage": 4.05, "temp": 930.1, "state": "正常", SEVERITY_FIELD: 0},
        {"slot": "E05", "voltage": 3.88, "temp": 955.7, "state": "预警", SEVERITY_FIELD: 1},
        {"slot": "F06", "voltage": 4.18, "temp": 928.4, "state": "正常", SEVERITY_FIELD: 0},
    ]
    table = NovaDataGridModel(columns, rows, row_key="slot")
    pagination = NovaDataGridPagination(page_size=20)
    filter_proxy = NovaDataGridFilterProxy()
    filter_proxy.setSourceModel(table)
    paged_proxy = NovaDataGridPagedProxy(pagination)
    paged_proxy.setSourceModel(filter_proxy)
    pagination.setTotal(len(rows))
    return table, filter_proxy, paged_proxy, pagination


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setApplicationName("pyside-nova-gallery")

    engine = QQmlApplicationEngine()
    init_nova(engine)

    # 第 25 页 NovaDataGrid 的数据管道（Python 模型注入，不依赖任何第三方库）
    table, filter_proxy, paged_proxy, pagination = _build_datagrid_models()
    ctx = engine.rootContext()
    ctx.setContextProperty("gridTableModel", table)
    ctx.setContextProperty("gridFilterProxy", filter_proxy)
    ctx.setContextProperty("gridPagedProxy", paged_proxy)
    ctx.setContextProperty("gridPagination", pagination)

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
