# tests/test_nova_datagrid.py
# NovaDataGrid（1.5.0 additive 第 146 个公共类型）：静态契约 + Python 数据层 + 离屏真机验收
"""NovaDataGrid 验收。

静态层：qmldir 导出 / a11y 契约 / 冻结面签名 / 旧 145 类型逐字不变 /
零第三方依赖 / 库组件优先 / 文档事实 / 私有成员不泄漏。
数据层：列定义、roleNames 转发、批量更新、列显隐、过滤与分页切片。
真机层：真实 QQmlEngine 加载 + 完整交互事件链 + 0 坏 Qt 消息。

坑位 71：条件高度的 Rectangle 的 visible 不可绑定自身 height（自举死锁）。
坑位 72：Connections 的 `function onXxx()` 会被冻结面解析器误登记为公共方法。
"""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

import pytest

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QPA_FONTDIR", "C:/Windows/Fonts")

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))
sys.path.insert(0, str(ROOT / "scripts"))

QML = SRC / "pyside_nova" / "qml" / "Nova" / "Controls" / "NovaDataGrid.qml"
QMLDIR = SRC / "pyside_nova" / "qml" / "Nova" / "Controls" / "qmldir"
DOC = ROOT / "docs" / "controls" / "NovaDataGrid.md"
MANIFEST = ROOT / "api" / "nova-api-1.9.0.json"
KEY = "Nova.Controls.NovaDataGrid"

EXPECTED_SIGNALS = {
    "rowClicked(int row)",
    "rowDoubleClicked(int row)",
    "cellClicked(int row, int column)",
    "cellEdited(int row, int column, var value)",
    "sortRequested(int column, bool ascending)",
    "refreshRequested()",
    "request(var params)",
    "rowContextMenuRequested(int row, real x, real y)",
    "rowExpansionToggled(var rowKey, bool expanded)",
    "selectionChanged(var rows)",
    "selectionActionRequested(var rows, string action)",
    "clearFilterRequested()",
    "columnWidthResized(var widths)",
    "loadMoreRequested(int lastRow)",
    "groupToggled(var groupKey, bool collapsed)",
    "fullScreenToggled(bool active)",
    "exportRequested(var csvText)",
}
EXPECTED_METHODS = {
    "sortByKey(colKey, ascending)",
    "scrollToRow(row)",
    "clearSelection()",
    "getRowData(rowIndex)",
    "toggleExpansion(row)",
    "isExpanded(row)",
    "clearFilters()",
    "requestSelectionAction(action)",
    "resetColumnWidths()",
    "toggleGroup(groupKey)",
    "toggleTreeNode(row)",
    "setViewMode(mode)",
    "setPageSize(size)",
    "toggleFullScreen()",
    "exportCsv(delimiter)",
}


@pytest.fixture(scope="module")
def manifest() -> dict:
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


@pytest.fixture(scope="module")
def qml_text() -> str:
    return QML.read_text(encoding="utf-8")


# ── 1. 静态契约 ────────────────────────────────────────────────
def test_qmldir_exports_type():
    lines = [l.strip() for l in QMLDIR.read_text(encoding="utf-8").splitlines()
             if l.strip() and not l.strip().startswith("#")]
    assert "NovaDataGrid 1.0 NovaDataGrid.qml" in lines


def test_frozen_surface(manifest):
    assert manifest["apiVersion"] == "1.9.0"
    assert manifest["counts"]["total"] == 147
    assert manifest["counts"]["modules"]["Nova.Controls"] == 93
    assert manifest["counts"]["a11y"]["interactive"] == 33
    info = manifest["types"][KEY]
    assert info["a11y"] == "interactive"
    assert info["file"] == "Nova/Controls/NovaDataGrid.qml"
    assert set(info["signals"]) == EXPECTED_SIGNALS
    assert EXPECTED_METHODS.issubset(set(info["methods"]))
    assert "ro columnDefs:var" in info["props"]
    assert "ro allColumnDefs:var" in info["props"]
    # 内部实现一律 `_` 前缀，不得泄漏进公共面
    for group in ("props", "signals", "methods"):
        leaked = [s for s in info[group] if s.split(":")[0].split("(")[0].startswith("_")]
        assert not leaked, f"私有成员泄漏：{leaked}"


def test_old_145_types_unchanged(manifest):
    """1.4.0 的 145 类型逐字不变；1.9.0 唯一例外 = `NovaTable` additive 扩展。

    `NovaTable` 1.9.0 对标 Quasar QTable 做 additive minor（45/7/13 → 77/14/21）：
    只加公共成员、旧成员逐字零丢失，由 `tests/test_nova_table.py` 精确固化。
    其余 144 类型仍要求逐字不变。
    """
    old = json.loads((ROOT / "api" / "nova-api-1.4.0.json").read_text(encoding="utf-8"))
    additive_key = "Nova.Controls.NovaTable"
    diff = [k for k, v in old["types"].items()
            if k != additive_key and manifest["types"].get(k) != v]
    assert not diff, f"旧类型被改动：{diff[:5]}"
    o, n = old["types"][additive_key], manifest["types"][additive_key]
    for field in ("props", "signals", "methods"):
        lost = set(o[field]) - set(n[field])
        assert not lost, f"NovaTable additive 破坏旧 {field}：{sorted(lost)}"
    # 1.5.0 最终冻结面相对 1.4.0 新增两类型：NovaDataGrid（本测试主角）+ NovaAIReport（第 21 组合根）
    assert set(manifest["types"]) - set(old["types"]) == {
        KEY, "Nova.Composite.LayoutShell.NovaAIReport"}


def test_zero_third_party_dependency():
    pyproject = (ROOT / "pyproject.toml").read_text(encoding="utf-8")
    assert 'dependencies = ["PySide6>=6.8"]' in pyproject
    for banned in ("markdown-it-py", "Pygments", "WebEngine", "pandas"):
        assert banned not in pyproject


def test_library_components_first(qml_text):
    assert "pragma ComponentBehavior: Bound" in qml_text
    for lib in ("NovaField", "NovaInput", "NovaBtn", "NovaBtnToggle",
                "NovaMenu", "NovaOptionGroup", "NovaPagination", "NovaSpinner",
                "NovaTheme", "NovaFocusRing"):
        assert lib in qml_text, f"缺库组件 {lib}"
    # 裸控件拼装禁止（TableView / HeaderView / ScrollBar / ItemSelectionModel 属数据视图基础设施）
    for banned in ("Button {", "TextField {", "ComboBox {", "CheckBox {",
                   "BusyIndicator {", "ScrollView {", "Popup {"):
        assert banned not in qml_text, f"出现裸控件 {banned}"
    assert "novaTheme." not in qml_text          # 令牌统一到大写 NovaTheme
    assert "visible: root.showToolbar" in qml_text   # 坑位 71
    assert "function onCountChanged" in qml_text  # 坑位 72：Qt 6.12 标准语法


def test_usage_doc(qml_text):
    doc = DOC.read_text(encoding="utf-8")
    for token in ("NovaDataGrid", "1.5.0", "9742de8638251876",
                  "坑位 70", "坑位 71", "坑位 72", "pyside_nova.datagrid",
                  "NovaTable", "cellDelegates", "serverSide"):
        assert token in doc, f"使用文档缺 {token}"
    assert "controls/NovaDataGrid.md" in (ROOT / "mkdocs.yml").read_text(encoding="utf-8")


# ── 2. Python 数据层 ──────────────────────────────────────────
@pytest.fixture(scope="module")
def pipeline():
    from PySide6.QtCore import Qt

    from pyside_nova.datagrid import (
        SEVERITY_FIELD,
        NovaDataGridColumn,
        NovaDataGridFilterProxy,
        NovaDataGridModel,
        NovaDataGridPagedProxy,
        NovaDataGridPagination,
        NovaDataGridRoles,
    )
    cols = [
        NovaDataGridColumn("slot", "槽号", width=100),
        NovaDataGridColumn("v", "电压(V)", width=110, editable=True, editor="number"),
        NovaDataGridColumn("state", "状态", width=90, visible=False),
    ]
    rows = [
        {"slot": "A01", "v": 4.12, "state": "ok", SEVERITY_FIELD: 0},
        {"slot": "B02", "v": 3.98, "state": "warn", SEVERITY_FIELD: 1},
    ]
    table = NovaDataGridModel(cols, rows, row_key="slot")
    pagination = NovaDataGridPagination(page_size=1)
    fp = NovaDataGridFilterProxy()
    fp.setSourceModel(table)
    pp = NovaDataGridPagedProxy(pagination)
    pp.setSourceModel(fp)
    pagination.setTotal(2)
    return table, fp, pp, pagination, Qt, NovaDataGridRoles


def test_model_surface(pipeline):
    table, _fp, _pp, _p, Qt, roles = pipeline
    assert table.rowCount() == 2 and table.columnCount() == 2
    assert table.headerData(0, Qt.Orientation.Horizontal) == "槽号"
    assert table.data(table.index(0, 1), roles.DisplayRole) == 4.12
    assert table.data(table.index(1, 1), roles.SeverityRole) == 1
    assert table.flags(table.index(0, 1)) & Qt.ItemFlag.ItemIsEditable
    assert table.roleNames()[roles.HighlightedRole] == b"highlighted"


def test_model_edit_and_batch(pipeline):
    table, _fp, _pp, _p, _Qt, _roles = pipeline
    assert table.setRawValue(0, 1, "4.30") is True
    assert table.getRawValue(0, 1) == 4.30
    assert table.setRawValue(0, 1, "not-a-number") is False
    table.batchUpdate([{"slot": "B02", "v": 4.01}])
    assert table.getRawValue(1, 1) == 4.01
    assert table.getRow(0)["slot"] == "A01"
    assert table.allRows()[1]["slot"] == "B02"


def test_column_visibility(pipeline):
    table, fp, _pp, _p, _Qt, _roles = pipeline
    table.setVisibleColumns(["slot", "v", "state"])
    assert table.columnCount() == 3
    assert len(table.allColumns) == 3
    assert fp.roleNames() == table.roleNames()      # 代理转发 role
    table.setVisibleColumns(["slot", "v"])


def test_filter_and_paging(pipeline):
    _table, fp, pp, pagination, _Qt, _roles = pipeline
    fp.setQuickFilter("A01")
    assert fp.rowCount() == 1
    fp.clearFilters()
    assert pagination.pageCount == 2
    assert pagination.startIndex == 0 and pagination.endIndex == 1
    assert pp.rowCount() == 1
    pagination.nextPage()
    assert pagination.currentPage == 2 and pagination.startIndex == 1
    assert pp.rowCount() == 1
    assert pp.roleNames() == fp.roleNames()
    pagination.firstPage()


def test_expand_proxy_roles_and_mapping(pipeline):
    from pyside_nova.datagrid import NovaDataGridExpandProxy

    table, _fp, _pp, _p, _Qt, roles = pipeline
    proxy = NovaDataGridExpandProxy()
    proxy.setSourceModel(table)
    assert proxy.rowCount() == 2
    assert proxy.roleNames()[roles.IsExpansionRole] == b"isExpansion"
    assert proxy.roleNames()[roles.ExpansionDataRole] == b"expansionData"

    proxy.toggleRow(0)
    assert proxy.rowCount() == 3
    assert proxy.expanded == ["A01"]
    assert proxy.data(proxy.index(1, 0), roles.IsExpansionRole) is True
    assert proxy.data(proxy.index(1, 0), roles.ExpansionRowRole) == 0
    assert proxy.data(proxy.index(1, 0), roles.RowKeyRole) == "A01"
    assert proxy.expansionData(1)["rowData"]["slot"] == "A01"
    assert proxy.mapToSource(proxy.index(1, 0)).row() == 0
    assert proxy.mapToSource(proxy.index(2, 0)).row() == 1

    proxy.toggleRow(1)             # 点展开行自身应折叠
    assert proxy.rowCount() == 2
    assert proxy.expanded == []


def test_filter_proxy_filter_active(pipeline):
    _table, fp, _pp, _p, _Qt, _roles = pipeline
    assert fp.filterActive is False
    fp.setQuickFilter("A01")
    assert fp.filterActive is True
    fp.setColumnFilter("slot", "")
    assert fp.filterActive is True
    fp.clearFilters()
    assert fp.filterActive is False


# ── 2b. 1.9.0 P1/P2 数据层 ───────────────────────────────────
def test_column_style_metadata_and_csv_export():
    from pyside_nova.datagrid import NovaDataGridColumn, NovaDataGridModel

    cols = [
        NovaDataGridColumn("slot", "槽号", style="accent", auto_width=True),
        NovaDataGridColumn("state", "状态", classes=["warning"],
                           header_style="muted"),
    ]
    model = NovaDataGridModel(cols, [
        {"slot": "A01", "state": "正常"},
        {"slot": "B,02", "state": "预警"},
    ], row_key="slot")
    assert model.columns[0]["style"] == "accent"
    assert model.columns[0]["autoWidth"] is True
    assert model.columns[1]["classes"] == ["warning"]
    assert model.columns[1]["headerStyle"] == "muted"
    assert model.exportCsv() == "槽号,状态\nA01,正常\n\"B,02\",预警\n"
    assert model.exportCsvWithDelimiter("\t") == "槽号\t状态\nA01\t正常\nB,02\t预警\n"
    assert model.exportColumnsCsv(["state"]) == "状态\n正常\n预警\n"


def test_group_proxy_collapse_and_tree():
    from pyside_nova.datagrid import (
        NovaDataGridColumn,
        NovaDataGridGroupProxy,
        NovaDataGridModel,
        NovaDataGridRoles,
    )

    cols = [
        NovaDataGridColumn("slot", "槽号"),
        NovaDataGridColumn("state", "状态"),
        NovaDataGridColumn("parent", "父", visible=False),
    ]
    rows = [
        {"slot": "A", "state": "ok", "parent": ""},
        {"slot": "A1", "state": "warn", "parent": "A"},
        {"slot": "B", "state": "ok", "parent": ""},
    ]
    model = NovaDataGridModel(cols, rows, row_key="slot")
    proxy = NovaDataGridGroupProxy()
    proxy.setGroupBy("state")
    proxy.setSourceModel(model)
    assert proxy.rowCount() == 5           # 2 个分组头 + 3 条数据
    assert proxy.isGroupRow(0) is True
    assert proxy.groupData(0)["label"] == "ok"
    assert proxy.data(proxy.index(0, 0), NovaDataGridRoles.GroupCountRole) == 2
    proxy.toggleGroup("ok")
    assert proxy.rowCount() == 3 and proxy.collapsed == ["ok"]
    assert proxy.roleNames()[NovaDataGridRoles.TreeLevelRole] == b"treeLevel"

    proxy.setGroupBy("")
    proxy.setTreeParentKey("parent")
    proxy.setTreeMode(True)
    assert proxy.rowCount() == 2           # A / B 两个根节点
    proxy.setTreeExpanded(["A"])
    assert proxy.rowCount() == 3
    assert proxy.data(proxy.index(1, 0), NovaDataGridRoles.RowKeyRole) == "A1"
    proxy.toggleTreeNode(0)            # 折叠根节点 A
    assert proxy.rowCount() == 2


# ── 3. 离屏真机 ───────────────────────────────────────────────
def test_offscreen_runtime(tmp_path):
    from PySide6.QtCore import QEventLoop, QTimer, qInstallMessageHandler
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQml import QQmlApplicationEngine, QQmlExpression, qmlContext

    from pyside_nova import init_nova
    from pyside_nova.datagrid import (
        SEVERITY_FIELD,
        NovaDataGridColumn,
        NovaDataGridExpandProxy,
        NovaDataGridFilterProxy,
        NovaDataGridGroupProxy,
        NovaDataGridModel,
        NovaDataGridPagedProxy,
        NovaDataGridPagination,
    )

    messages: list[str] = []
    previous = qInstallMessageHandler(lambda mt, ctx, msg: messages.append(msg))
    try:
        cols = [
            NovaDataGridColumn("slot", "槽号", width=120),
            NovaDataGridColumn("voltage", "电压(V)", width=120,
                               editable=True, editor="number"),
            NovaDataGridColumn("state", "状态", width=110),
        ]
        rows = [
            {"slot": "A01", "voltage": 4.12, "state": "正常", SEVERITY_FIELD: 0},
            {"slot": "B02", "voltage": 3.98, "state": "预警", SEVERITY_FIELD: 1},
            {"slot": "C03", "voltage": 3.71, "state": "严重", SEVERITY_FIELD: 2},
        ]
        table = NovaDataGridModel(cols, rows, row_key="slot")
        pagination = NovaDataGridPagination(page_size=20)
        fp = NovaDataGridFilterProxy()
        fp.setSourceModel(table)
        pp = NovaDataGridPagedProxy(pagination)
        pp.setSourceModel(fp)
        pagination.setTotal(len(rows))
        ep = NovaDataGridExpandProxy()
        ep.setSourceModel(pp)
        gp = NovaDataGridGroupProxy()
        gp.setSourceModel(ep)

        qml = tmp_path / "Main.qml"
        qml.write_text(
            "import QtQuick\nimport QtQuick.Controls\n"
            "import Nova.Controls\nimport Nova.Services\n"
            "ApplicationWindow {\n"
            "  width: 900; height: 600; visible: true\n"
            "  property int editedCount: 0\n"
            "  property int clickedCount: 0\n"
            "  property int expandCount: 0\n"
            "  property int selectionCount: 0\n"
            "  property int groupCount: 0\n"
            "  property int fullScreenCount: 0\n"
            "  property string exportedCsv: ''\n"
            "  NovaDataGrid {\n"
            "    id: grid\n"
            "    anchors.fill: parent\n"
            "    anchors.margins: 12\n"
            "    title: '工业槽位监控'\n"
            "    tableModel: dmTable\n"
            "    filterProxy: dmFilter\n"
            "    pagedProxy: dmPaged\n"
            "    pagination: dmPages\n"
            "    expandProxy: dmExpand\n"
            "    groupProxy: dmGroup\n"
            "    resizableColumns: true\n"
            "    columnWidths: ({ slot: 150 })\n"
            "    stickyColumns: ['slot', 'state']\n"
            "    footerData: ({ slot: '合计' })\n"
            "    pageSizeOptions: [{label:'20',value:20},{label:'50',value:50}]\n"
            "    showExportButton: true\n"
            "    selectionMode: 'multiple'\n"
            "    expansionDelegate: Component { Rectangle { property var expansionData; color: NovaTheme.surfaceAlt } }\n"
            "    selectionDelegate: Component { Rectangle { property var selectionData; color: NovaTheme.outline } }\n"
            "    emptyDelegate: Component { Rectangle { property var emptyData; color: 'transparent' } }\n"
            "    onCellEdited: function(r, c, v) { editedCount++ }\n"
            "    onRowClicked: function(r) { clickedCount++ }\n"
            "    onRowExpansionToggled: function(k, e) { expandCount++ }\n"
            "    onSelectionChanged: function(rows) { selectionCount++ }\n"
            "    onGroupToggled: function(k, c) { groupCount++ }\n"
            "    onFullScreenToggled: function(v) { fullScreenCount++ }\n"
            "    onExportRequested: function(csv) { exportedCsv = csv }\n"
            "  }\n}\n",
            encoding="utf-8",
        )

        # 保持 QGuiApplication 的 Python 强引用，避免离屏验收期间被 GC 提前析构。
        _app = QGuiApplication.instance() or QGuiApplication([])
        engine = QQmlApplicationEngine()
        init_nova(engine)
        ctx = engine.rootContext()
        for name, obj in (("dmTable", table), ("dmFilter", fp),
                          ("dmPaged", pp), ("dmPages", pagination),
                          ("dmExpand", ep), ("dmGroup", gp)):
            ctx.setContextProperty(name, obj)
        engine.load(str(qml))
        roots = engine.rootObjects()
        assert len(roots) == 1, f"加载失败：{messages[:5]}"
        root = roots[0]
        loop = QEventLoop()
        QTimer.singleShot(350, loop.quit)
        loop.exec()

        def ev(expr):
            ex = QQmlExpression(qmlContext(root), root, expr)
            value, undef = ex.evaluate()
            assert not ex.hasError(), f"{expr} -> {ex.error().toString()}"
            # 坑位 73：QML 绑定 / delegate 更新是排队到事件循环的。若把一连串
            # 改模型的操作挤在同一条表达式求值链里同步跑完，下一次
            # QSortFilterProxyModel.invalidate() 会踩到半更新状态，Qt 6.12
            # offscreen 下表现为 Windows access violation（exit 139）。
            # 真实 app 每个事件之间都会推进循环，验收脚本必须同节奏。
            QTimer.singleShot(30, loop.quit)
            loop.exec()
            return None if undef else value

        assert ev("grid.width") > 0 and ev("grid.height") > 0
        assert ev("grid.columnDefs.length") == 3
        assert ev("grid._model.rowCount()") == 3
        assert ev("grid.pagination.total") == 3
        assert ev("grid._columnOptions.length") == 3

        # 排序 → 过滤 → 批量更新 → 编辑 → 列显隐 → 信号 → 键盘 → 明暗
        ev("grid.sortByKey('voltage', true)")
        assert ev("grid._sortKey") == "voltage"
        ev("dmFilter.setQuickFilter('B02')")
        assert ev("grid._model.rowCount()") == 1
        ev("dmFilter.clearFilters()")
        assert ev("grid._model.rowCount()") == 3
        ev("dmTable.batchUpdate([{slot: 'C03', voltage: 3.75}])")
        assert ev("dmTable.getRawValue(2, 1)") == 3.75
        ev("grid._editingRow = 1; grid._editingColumn = 1; grid._submitEdit('4.20')")
        assert ev("dmTable.getRawValue(1, 1)") == 4.20
        assert ev("editedCount") == 1
        ev("grid._editingRow = 1; grid._editingColumn = 1; grid._submitEdit('bad')")
        assert ev("grid._editError") is True
        ev("grid._cancelEdit()")
        ev("dmTable.setVisibleColumns(['slot', 'voltage'])")
        assert ev("grid.columnDefs.length") == 2
        ev("dmTable.setVisibleColumns(['slot', 'voltage', 'state'])")
        ev("grid.rowContextMenuRequested(0, 20, 30)")
        ev("grid.refreshRequested()")
        ev("grid._a11ySet(2)")
        assert ev("grid._a11yRow") == 2
        ev("grid.scrollToRow(2)")
        ev("grid.clearSelection()")
        assert ev("JSON.stringify(grid.getRowData(0))").find("A01") >= 0
        ev("grid._columnMenuOpen = true")
        assert ev("grid._columnMenuOpen") is True
        ev("grid._columnMenuOpen = false")

        # 1.7.0 P0：展开行 / 选择信号 / 空态 / 键盘长跳（史料口径，不回改）
        assert ev("grid.expandProxy !== null") is True
        ev("grid.toggleExpansion(0)")
        assert ev("grid._model.rowCount()") == 4
        assert ev("grid.expandedRows.length") == 1
        assert ev("expandCount") == 1
        ev("grid.toggleExpansion(1)")
        assert ev("grid._model.rowCount()") == 3
        assert ev("grid.expandedRows.length") == 0
        ev("grid.requestSelectionAction('delete')")
        ev("dmFilter.setQuickFilter('NO-MATCH')")
        assert ev("grid.filterActive") is True
        ev("grid.clearFilters()")
        assert ev("grid.filterActive") is False
        ev("grid._a11ySet(0); grid._a11yMove(10)")
        assert ev("grid._a11yRow") == 2

        # 1.9.0 P1/P2：列宽 / sticky / 合计行 / 插槽 / 页大小 / 分组 / 全屏 / CSV / 形态
        assert ev("grid.resizableColumns") is True
        assert ev("grid._widthForColumn(0)") == 150
        assert ev("grid._stickyKeys().length") == 2
        assert ev("Object.keys(grid.footerData).length") == 1
        assert ev("grid._pageSizeOptions.length") == 2
        ev("grid.setViewMode('grid')")
        assert ev("grid._effectiveViewMode") == "grid"
        ev("grid.setViewMode('table')")
        ev("dmGroup.setGroupBy('state')")
        assert ev("grid._model.rowCount()") == 6   # 3 个分组头 + 3 条数据
        ev("grid.toggleGroup('正常')")
        assert ev("groupCount") == 1 and gp.collapsed == ["正常"]
        ev("dmGroup.setGroupBy('')")
        ev("grid.toggleFullScreen()")
        assert ev("grid.fullScreen") is True and ev("fullScreenCount") == 1
        ev("grid.toggleFullScreen()")
        assert ev("grid.exportCsv()").find("槽号") >= 0
        assert ev("exportedCsv").find("槽号") >= 0

        ev("NovaTheme.setDark(true)")
        assert ev("NovaTheme.isDark") is True
        ev("NovaTheme.setDark(false)")

        QTimer.singleShot(200, loop.quit)
        loop.exec()
        assert not messages, f"真机产生坏 Qt 消息：{messages[:8]}"
    finally:
        qInstallMessageHandler(previous)
