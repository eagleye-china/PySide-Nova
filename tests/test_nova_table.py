# tests/test_nova_table.py
# NovaTable 1.11.0（完全对标 Quasar QTable）：静态契约 + additive 零漂移 + 完整度评估事实
"""NovaTable 验收。

纯静态层（不建 QML 引擎，规避坑位 49 的 offscreen 全量串跑 SIGSEGV）：

1. 冻结面：147 类型 / 指纹 5328cd0e3c71e7ac / 110 props · 18 signals · 26 methods；
2. additive 零漂移：1.9.0 的 77/14/21 逐成员仍是 1.11.0 面的子集，旧签名一个不丢；
   增量恰为 33 props / 4 signals / 5 methods；
3. QTable 全表映射：21 slots / 15 methods / 9 events 全覆盖（官方 QTable.json 口径）；
4. 源码纪律：qmldir 导出 / a11y interactive · Table / 零第三方依赖 /
   私有成员不泄漏 / `grid` 旧语义与 `viewMode` 解耦 / 受控模式只发意图 /
   官方 sort-method / filter-method 另立成员不劫持已发布语义；
5. 史料不圆场：构想稿原样保留且被 exclude，1.9.0 冻结面为已发布史料；
6. 账实一致：CHANGELOG 1.11.0 段 / 1.9.0 已发布校准 / 徽标刻字 v1.11.0 /
   现行文档 §0 校准 + §14 完整度评估 + §15 框架边界。

真机层（离屏全插槽激活 / TOTAL_MSGS=0）由交付验收的独立探针执行，不进 pytest。
"""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

import pytest

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS))

QML = ROOT / "src" / "pyside_nova" / "qml" / "Nova" / "Controls" / "NovaTable.qml"
QML_TR = ROOT / "src" / "pyside_nova" / "qml" / "Nova" / "Controls" / "NovaTr.qml"
QMLDIR = QML.parent / "qmldir"
DOC = ROOT / "docs" / "controls" / "NovaTable.current.md"
HISTORICAL_DOC = ROOT / "docs" / "controls" / "NovaTable.md"
MANIFEST = ROOT / "api" / "nova-api-1.11.0.json"
PREV_MANIFEST = ROOT / "api" / "nova-api-1.9.0.json"
CHANGELOG = ROOT / "CHANGELOG.md"
MKDOCS = ROOT / "mkdocs.yml"
PYPROJECT = ROOT / "pyproject.toml"
BRAND = ROOT / "src" / "pyside_nova" / "resources" / "icons" / "pyside-nova-logo-sealed.svg"

KEY = "Nova.Controls.NovaTable"
TR_KEY = "Nova.Controls.NovaTr"
FINGERPRINT = "9966483dda5a53c4"      # 1.11.0 现行冻结面（T29-B 重签）
PREV_FINGERPRINT = "b15a4be38c000c59"  # 1.9.0 已发布史料，不回改

EXPECTED_PROPS = {
    "a11yLabel:string", "binaryStateSort:bool", "bodyCellDelegate:Component",
    "bodyDelegate:Component", "bodySelectionDelegate:Component", "bordered:bool",
    "bottomDelegate:Component", "bottomRowDelegate:Component", "cardContainerStyleToken:string",
    "cardStyleFn:var", "cardStyleToken:string", "cellDelegates:var", "clearFilterText:string",
    "colorToken:string", "columnSortOrder:string", "columns:var", "dense:bool",
    "descending:bool", "expandSlot:Component", "expanded:var", "exportDelimiter:string",
    "filter:string", "filterMethod:var", "filterRowsMethod:var", "flat:bool",
    "footerDelegate:Component", "fullScreen:bool", "grid:bool", "gridBreakpoint:int",
    "gridCellHeight:int", "gridCellWidth:int", "gridDelegate:Component", "gridHeader:bool",
    "headerCellDelegate:Component", "headerCellDelegates:var", "headerDelegate:Component",
    "headerSelectionDelegate:Component", "hideBottom:bool", "hideHeader:bool",
    "hideNoData:bool", "hidePagination:bool", "hideSelectedBanner:bool", "loadMoreEnabled:bool",
    "loadMoreThreshold:int", "loading:bool", "loadingDelegate:Component", "loadingLabel:string",
    "noDataDelegate:Component", "noDataLabel:string", "noResultsLabel:string", "page:int",
    "paginationDelegate:Component", "paginationLabel:var", "responsive:bool",
    "ro allVisibleSelected:bool", "ro filteredRows:var", "ro normColumns:var",
    "ro pageCount:int", "ro paginationState:var", "ro rowCount:int", "ro selectionInfo:var",
    "ro someSelected:bool", "ro sortedRows:var", "ro virtualContentHeight:real",
    "ro virtualContentY:real", "ro virtualRowCount:int", "ro visibleRows:var", "rowData:var",
    "rowExpanded:bool", "rowIdx:int", "rowK:string", "rowKey:string", "rowKeyFn:var",
    "rowSelected:bool", "rowStyleFn:var", "rows:var", "rowsNumber:int", "rowsPerPage:int",
    "rowsPerPageLabel:string", "rowsPerPageOptions:var", "selected:var",
    "selectedRowsLabel:var", "selectionMode:string", "separator:string", "serverSide:bool",
    "showColumnSelector:bool", "showExportButton:bool", "showFullScreenButton:bool",
    "singleSelection:bool", "slotData:var", "sortBy:string", "sortMethod:var", "square:bool",
    "tableHeaderStyleToken:string", "tableStyleToken:string", "title:string",
    "titleClass:string", "topDelegate:Component", "topLeftDelegate:Component",
    "topRightDelegate:Component", "topRowDelegate:Component", "topSelectionDelegate:Component",
    "viewMode:string", "virtualScroll:bool", "virtualScrollItemSize:int",
    "virtualScrollSliceSize:int", "virtualScrollStickySizeEnd:int",
    "virtualScrollStickySizeStart:int", "visibleColumns:var", "wrapCells:bool",
}
EXPECTED_SIGNALS = {
    "clearFilterRequested()", "columnVisibilityChanged(var keys)",
    "exportRequested(var csvText)", "fullScreenToggled(bool active)",
    "loadMoreRequested(int lastRow)", "pageRequested(int page)",
    "paginationChanged(var pagination)", "request(var params)",
    "rowClicked(var row, int index)", "rowContextMenu(var row, int index)",
    "rowDoubleClicked(var row)", "rowsPerPageRequested(int size)", "selectionChanged(var info)",
    "sortChanged(string field, bool desc)", "updateExpanded(var keys)",
    "updateSelected(var rows)", "virtualScrollInfo(var info)", "virtualScrollReset()",
}
EXPECTED_METHODS = {
    "clearFilter()", "clearSelection()", "exportCsv(delimiter)", "firstPage()",
    "getCellValue(col, row)", "isRowExpanded(row, i)", "isRowSelected(row)", "lastPage()",
    "nextPage()", "prevPage()", "requestPage(p)", "requestRowsPerPage(size)",
    "requestServerInteraction()", "requestSort(name)", "resetVirtualScroll()", "scrollTo(i)",
    "setExpanded(keys)", "setPagination(pg)", "setViewMode(mode)", "setVisibleColumns(keys)",
    "sort(name)", "toggleAllSelection()", "toggleColumnVisibility(name)", "toggleFullScreen()",
    "toggleRowExpand(row, i)", "toggleRowSelection(row)",
}

NEW_190_PROPS = {
    "bodyDelegate:Component", "bottomDelegate:Component",
    "bottomRowDelegate:Component", "cellDelegates:var", "clearFilterText:string",
    "columnSortOrder:string", "dense:bool", "exportDelimiter:string",
    "footerDelegate:Component", "fullScreen:bool", "gridBreakpoint:int",
    "gridCellHeight:int", "gridCellWidth:int", "gridDelegate:Component",
    "gridHeader:bool", "headerCellDelegates:var", "headerDelegate:Component",
    "loadMoreEnabled:bool", "loadMoreThreshold:int", "loadingDelegate:Component",
    "noDataDelegate:Component", "noResultsLabel:string", "responsive:bool",
    "separator:string", "showColumnSelector:bool", "showExportButton:bool",
    "showFullScreenButton:bool", "slotData:var", "topDelegate:Component",
    "topRowDelegate:Component", "viewMode:string", "visibleColumns:var",
}
NEW_1100_PROPS = {
    "bodyCellDelegate:Component", "bodySelectionDelegate:Component",
    "cardContainerStyleToken:string", "cardStyleFn:var", "cardStyleToken:string",
    "colorToken:string", "filterRowsMethod:var", "headerCellDelegate:Component",
    "headerSelectionDelegate:Component", "hideNoData:bool", "hidePagination:bool",
    "hideSelectedBanner:bool", "paginationDelegate:Component", "paginationLabel:var",
    "ro paginationState:var", "ro selectionInfo:var", "rowKeyFn:var", "rowStyleFn:var",
    "rowsPerPageLabel:string", "selectedRowsLabel:var", "selectionMode:string",
    "sortMethod:var", "square:bool", "tableHeaderStyleToken:string", "tableStyleToken:string",
    "titleClass:string", "topLeftDelegate:Component", "topRightDelegate:Component",
    "topSelectionDelegate:Component", "virtualScrollSliceSize:int",
    "virtualScrollStickySizeEnd:int", "virtualScrollStickySizeStart:int", "wrapCells:bool",
}
NEW_1100_SIGNALS = {
    "paginationChanged(var pagination)", "rowContextMenu(var row, int index)",
    "selectionChanged(var info)", "virtualScrollInfo(var info)",
}
NEW_1100_METHODS = {
    "clearSelection()", "getCellValue(col, row)", "lastPage()", "setExpanded(keys)",
    "sort(name)",
}

# QTable 官方 API 全表（63 props / 21 slots / 9 events / 15 methods / 15 列元字段）
QTABLE_SLOTS = [
    "loading", "item", "body", "body-cell", "body-cell-[name]", "header", "header-cell",
    "header-cell-[name]", "body-selection", "body-expand", "header-selection", "top-row",
    "bottom-row", "footer", "top", "bottom", "pagination", "top-left", "top-right",
    "top-selection", "no-data",
]
QTABLE_METHODS = [
    "requestServerInteraction", "setPagination", "firstPage", "prevPage", "nextPage",
    "lastPage", "isRowSelected", "clearSelection", "isRowExpanded", "setExpanded", "sort",
    "toggleFullscreen", "resetVirtualScroll", "scrollTo", "getCellValue",
]
QTABLE_EVENT_DESTS = [
    "rowClicked", "rowDoubleClicked", "rowContextMenu", "request", "selectionChanged",
    "paginationChanged", "updateSelected", "updateExpanded", "virtualScrollInfo",
]


@pytest.fixture(scope="module")
def manifest() -> dict:
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


@pytest.fixture(scope="module")
def previous() -> dict:
    return json.loads(PREV_MANIFEST.read_text(encoding="utf-8"))


# ── 1. 冻结面 ──────────────────────────────────────────────────────
def test_manifest_version_and_fingerprint(manifest):
    assert manifest["apiVersion"] == "1.11.0"
    assert manifest["packageVersion"] == "1.11.0"
    assert manifest["fingerprint"] == FINGERPRINT
    assert manifest["counts"]["total"] == 147
    assert manifest["counts"]["modules"]["Nova.Controls"] == 93


def test_frozen_surface_matches_exactly(manifest):
    entry = manifest["types"][KEY]
    assert entry["kind"] == "component"
    assert entry["a11y"] == "interactive"
    assert set(entry["props"]) == EXPECTED_PROPS
    assert set(entry["signals"]) == EXPECTED_SIGNALS
    assert set(entry["methods"]) == EXPECTED_METHODS
    assert (len(entry["props"]), len(entry["signals"]), len(entry["methods"])) == (110, 18, 26)


def test_additive_zero_drift(manifest, previous):
    old = previous["types"][KEY]
    new = manifest["types"][KEY]
    assert (len(old["props"]), len(old["signals"]), len(old["methods"])) == (77, 14, 21)
    for field in ("props", "signals", "methods"):
        lost = set(old[field]) - set(new[field])
        assert not lost, f"{field} 旧成员丢失（破坏 additive）：{sorted(lost)}"
    assert set(new["props"]) - set(old["props"]) == NEW_1100_PROPS
    assert set(new["signals"]) - set(old["signals"]) == NEW_1100_SIGNALS
    assert set(new["methods"]) - set(old["methods"]) == NEW_1100_METHODS
    # 1.9.0 相对 1.8.0 的 32 项增量仍在面内
    assert NEW_190_PROPS <= set(new["props"])


def test_previous_manifest_is_published_history(previous):
    """1.9.0 冻结面是已发布史料，本轮不回改。"""
    assert previous["fingerprint"] == PREV_FINGERPRINT
    assert previous["apiVersion"] == "1.9.0"
    assert previous["counts"]["total"] == 147


def test_nova_tr_additive_extension(manifest, previous):
    """NovaTr 为 row-style-fn / row-contextmenu 增 1 prop + 1 signal，旧面不丢。"""
    old, new = previous["types"][TR_KEY], manifest["types"][TR_KEY]
    assert set(old["props"]) <= set(new["props"])
    assert set(old["signals"]) <= set(new["signals"])
    assert set(new["props"]) - set(old["props"]) == {"rowColor:color"}
    assert set(new["signals"]) - set(old["signals"]) == {"rowContextMenu()"}


def test_no_private_member_leaks_into_frozen_surface(manifest):
    entry = manifest["types"][KEY]
    for field in ("props", "signals", "methods"):
        for sig in entry[field]:
            assert not sig.startswith("_"), f"私有成员泄漏进公共面：{sig}"
            assert not sig.startswith("ro _"), f"私有 readonly 泄漏进公共面：{sig}"


# ── 2. QTable 全表映射 ─────────────────────────────────────────────
def test_qtable_21_slots_all_mapped(manifest):
    props = set(manifest["types"][KEY]["props"])
    # 21 slots 的 NovaTable 落点（含 1.9.0 既有 13 + 1.11.0 新增 8）
    mapped = {
        "loadingDelegate", "gridDelegate", "bodyDelegate", "bodyCellDelegate",
        "cellDelegates", "headerDelegate", "headerCellDelegate", "headerCellDelegates",
        "bodySelectionDelegate", "expandSlot", "headerSelectionDelegate", "topRowDelegate",
        "bottomRowDelegate", "footerDelegate", "topDelegate", "bottomDelegate",
        "paginationDelegate", "topLeftDelegate", "topRightDelegate", "topSelectionDelegate",
        "noDataDelegate",
    }
    assert len(QTABLE_SLOTS) == 21 and len(mapped) == 21
    assert all(any(m in p for p in props) for m in mapped), "QTable slot 落点缺失"


def test_qtable_15_methods_all_mapped(manifest):
    methods = set(manifest["types"][KEY]["methods"])
    dests = [
        "requestServerInteraction()", "setPagination(pg)", "firstPage()", "prevPage()",
        "nextPage()", "lastPage()", "isRowSelected(row)", "clearSelection()",
        "isRowExpanded(row, i)", "setExpanded(keys)", "sort(name)", "toggleFullScreen()",
        "resetVirtualScroll()", "scrollTo(i)", "getCellValue(col, row)",
    ]
    assert len(QTABLE_METHODS) == 15 and len(dests) == 15
    assert set(dests) <= methods, "QTable method 落点缺失"


def test_qtable_9_events_all_mapped(manifest):
    signals = set(manifest["types"][KEY]["signals"])
    assert len(QTABLE_EVENT_DESTS) == 9
    assert all(any(d.split("(")[0] in s for s in signals) for d in QTABLE_EVENT_DESTS), \
        "QTable event 落点缺失"


# ── 3. 源码纪律 ────────────────────────────────────────────────────
def test_qmldir_exports_nova_table():
    assert "NovaTable 1.0 NovaTable.qml" in QMLDIR.read_text(encoding="utf-8")


def test_a11y_registered_as_interactive_table():
    import check_a11y
    entry = check_a11y.CONTROLS["NovaTable"]
    assert entry[0] == check_a11y.INTERACTIVE
    assert entry[1] == "Table"


def test_zero_third_party_dependency():
    text = PYPROJECT.read_text(encoding="utf-8")
    assert 'dependencies = ["PySide6>=6.8"]' in text
    for banned in ("markdown-it-py", "PyQt", "QtWebEngine", "pandas", "numpy"):
        assert banned not in text


def test_legacy_grid_semantics_not_hijacked():
    text = QML.read_text(encoding="utf-8")
    assert "property bool grid: false" in text
    assert "保留原语义" in text
    assert 'property string viewMode: "table"' in text


def test_controlled_mode_emits_intent_only():
    text = QML.read_text(encoding="utf-8")
    for sig in ("signal updateSelected(var rows)", "signal updateExpanded(var keys)",
                "signal sortChanged(string field, bool desc)",
                "signal pageRequested(int page)", "signal request(var params)"):
        assert sig in text
    assert "均不自写" in text


def test_all_slots_and_intents_declared():
    text = QML.read_text(encoding="utf-8")
    for decl in ("property Component bodyDelegate: null",
                 "property Component headerDelegate: null",
                 "property Component topDelegate: null",
                 "property Component bottomDelegate: null",
                 "property Component topRowDelegate: null",
                 "property Component bottomRowDelegate: null",
                 "property Component footerDelegate: null",
                 "property Component noDataDelegate: null",
                 "property Component loadingDelegate: null",
                 "property Component gridDelegate: null",
                 "property var cellDelegates: ({})",
                 "property var headerCellDelegates: ({})",
                 "property Component bodyCellDelegate: null",
                 "property Component headerCellDelegate: null",
                 "property Component bodySelectionDelegate: null",
                 "property Component headerSelectionDelegate: null",
                 "property Component paginationDelegate: null",
                 "property Component topLeftDelegate: null",
                 "property Component topRightDelegate: null",
                 "property Component topSelectionDelegate: null"):
        assert decl in text, f"缺少插槽声明：{decl}"
    for sig in ("signal fullScreenToggled(bool active)",
                "signal exportRequested(var csvText)",
                "signal loadMoreRequested(int lastRow)",
                "signal clearFilterRequested()",
                "signal rowsPerPageRequested(int size)",
                "signal columnVisibilityChanged(var keys)",
                "signal virtualScrollReset()",
                "signal rowContextMenu(var row, int index)",
                "signal selectionChanged(var info)",
                "signal paginationChanged(var pagination)",
                "signal virtualScrollInfo(var info)"):
        assert sig in text, f"缺少意图信号：{sig}"


def test_column_meta_fields_supported():
    text = QML.read_text(encoding="utf-8")
    for field in ("format: c.format", "sort: c.sort", "rawSort: c.rawSort",
                  "autoWidth: c.autoWidth", "headerStyle:", "classes:",
                  'typeof col.field === "function"', 'typeof s === "function"'):
        assert field in text


def test_official_semantics_members_do_not_hijack_legacy():
    """官方 sort-method / filter-method 是整体函数；旧 filterMethod 单行谓词保留。"""
    text = QML.read_text(encoding="utf-8")
    assert "property var filterMethod: null" in text            # 1.9.0 前既有语义
    assert "property var filterRowsMethod: null" in text         # 1.11.0 官方等价
    assert "property var sortMethod: null" in text
    assert "root.filterRowsMethod(src, root.filter, root.normColumns, root.getCellValue)" in text
    assert "root.sortMethod(src, root.sortBy, root.descending)" in text
    assert "property var rowKeyFn: null" in text


def test_framework_boundary_documented():
    text = DOC.read_text(encoding="utf-8")
    for item in ("virtual-scroll-target", "table-colspan", "icon-first-page",
                 "virtual-scroll-slice-ratio-before", "dark", "sticky"):
        assert item in text, f"框架边界未登记：{item}"


# ── 4. 史料不圆场 / 文档事实 ───────────────────────────────────────
def test_historical_draft_preserved_verbatim():
    assert HISTORICAL_DOC.exists(), "构想稿史料被误删（git restore 可精确恢复）"
    text = HISTORICAL_DOC.read_text(encoding="utf-8")
    assert text.startswith("# NovaTable 企业级旗舰封版 · 完整可运行方案")
    assert text.count("\n") == 1654
    assert text.rstrip().endswith("冻结列与展开行作为 v0.13.0 补丁推进，不阻塞本次封版。")


def test_current_doc_has_1100_calibration_and_keeps_190_verbatim():
    assert DOC.exists()
    text = DOC.read_text(encoding="utf-8")
    assert "1.9.0 现行" in text                     # 史料标题逐字保留
    assert "77 props / 14 signals / 21 methods" in text
    assert PREV_FINGERPRINT in text
    assert "§0 · 1.11.0 现行校准" in text
    assert FINGERPRINT in text
    assert "api/nova-api-1.11.0.json" in text
    assert "110 / 18 / 26" in text
    assert "不改写、不删除构想稿" in text
    assert "委托声明契约" in text and 'property: "slotData"' in text
    assert "property var slotData" in text and "property var cellData" in text
    assert "114/123 = 92.7%" in text and "123/123 = 100%" in text
    assert "## 14." in text and "## 15." in text and "勘误登记" in text


def test_mkdocs_excludes_draft_and_nav_includes_current():
    cfg = MKDOCS.read_text(encoding="utf-8")
    assert "controls/NovaTable.md" in cfg.split("exclude_docs:")[1].split("extra_css:")[0]
    assert "controls/NovaTable.current.md" in cfg
    assert "NovaTable 使用文档（1.11.0 现行）" in cfg


def test_changelog_1100_is_current_head():
    text = CHANGELOG.read_text(encoding="utf-8")
    first = next(line for line in text.splitlines() if line.startswith("## ["))
    assert first.startswith("## [1.11.0]")
    assert "T29" in first and "分层迁移" in first
    assert "⭐ 当前状态" in first
    assert "## [1.9.0]" in text and "已由 CSA 发布" in text
    assert "92.7%" in text and "5328cd0e3c71e7ac" in text


def test_brand_seal_carries_current_version():
    text = BRAND.read_text(encoding="utf-8")
    assert "v1.11.0" in text, "封版徽标刻字未同步（跑 scripts/sync_brand_version.py）"
    assert "v1.9.0" not in text
