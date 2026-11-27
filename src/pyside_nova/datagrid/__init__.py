# src/pyside_nova/datagrid/__init__.py
"""NovaDataGrid 配套 Python 数据层。

与 QML 侧的 ``Nova.Controls.NovaDataGrid`` 配套使用：::

    from pyside_nova.datagrid import (
        NovaDataGridColumn, NovaDataGridModel,
        NovaDataGridFilterProxy, NovaDataGridPagination, NovaDataGridPagedProxy,
    )

    columns = [
        NovaDataGridColumn("slot", "槽号", width=120),
        NovaDataGridColumn("voltage", "电压(V)", width=120, editable=True,
                           editor="number"),
    ]
    table_model = NovaDataGridModel(columns, rows, row_key="slot")
    pagination = NovaDataGridPagination(page_size=20)
    filter_proxy = NovaDataGridFilterProxy()
    filter_proxy.setSourceModel(table_model)
    paged_proxy = NovaDataGridPagedProxy(pagination)
    paged_proxy.setSourceModel(filter_proxy)
    # 注入 QML：ctx.setContextProperty("tableModel", table_model) ...

零第三方依赖（仅 PySide6），主题令牌不在 Python 侧 —— QML 统一走
``Nova.Services.NovaTheme``。命名统一 ``NovaDataGrid*`` 前缀，避免与
已发布的 QML 类型 ``NovaTable`` 混淆。
"""
from .model import (
    SEVERITY_FIELD,
    NovaDataGridColumn,
    NovaDataGridModel,
    NovaDataGridRoles,
)
from .proxy import (
    NovaDataGridFilterProxy,
    NovaDataGridPagedProxy,
    NovaDataGridPagination,
)

__all__ = [
    "SEVERITY_FIELD",
    "NovaDataGridColumn",
    "NovaDataGridFilterProxy",
    "NovaDataGridModel",
    "NovaDataGridPagedProxy",
    "NovaDataGridPagination",
    "NovaDataGridRoles",
]
