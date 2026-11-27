# examples/layout_shell/ai_report/pipeline.py
"""NovaAIReport 演示的数据管道与宿主桥（启动器 / 出图 / 机检共用）。

    data.generate_rows() ──> NovaDataGridModel (reportTable)
                                   │
                                   ▼
                       NovaDataGridFilterProxy (reportFilter)
                                   │
                                   ▼
       NovaDataGridPagination ──> NovaDataGridPagedProxy (reportPaged)
                                   │
                                   ▼
                       NovaDataGridExpandProxy (reportExpand)
                                   │
                                   ▼
                       NovaDataGrid.qml 注入 reportSlot

    ReportBridge 只承载"宿主统计 + 受控信号记录 + 人工确认闸门状态"，
    不承载布局语义；NovaAIReport 仍是无业务语义骨架。
"""
from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtCore import Property, QObject, Signal, Slot

from pyside_nova.datagrid import (
    NovaDataGridExpandProxy,
    NovaDataGridFilterProxy,
    NovaDataGridModel,
    NovaDataGridPagedProxy,
    NovaDataGridPagination,
)

# 坑位 70：examples 归档层级可变，禁止写死 parents[n]；以标志目录向上探测。
DEMO_DIR = Path(__file__).resolve().parent
for _p in (DEMO_DIR, *DEMO_DIR.parents):
    if (_p / "src" / "pyside_nova" / "qml" / "Nova").is_dir():
        REPO_ROOT = _p
        break
else:  # pragma: no cover - 仅仓库结构损坏时触发
    raise RuntimeError(f"无法从 {DEMO_DIR} 向上定位 pyside-nova 仓库根")
if str(DEMO_DIR) not in sys.path:
    sys.path.insert(0, str(DEMO_DIR))

import data as plant


class ReportBridge(QObject):
    """宿主侧统计与受控闸门状态；QML 只读属性、只调槽。"""

    changed = Signal()

    def __init__(self, stats: dict, parent=None) -> None:
        super().__init__(parent)
        self._stats = dict(stats)
        self._last_signal = "（等待交互）"
        self._signal_count = 0
        self._gate_open = False
        self._approval_done: bool | None = None

    @Property(int, notify=changed)
    def total(self) -> int:
        return self._stats["total"]

    @Property(int, notify=changed)
    def normal(self) -> int:
        return self._stats["normal"]

    @Property(int, notify=changed)
    def warning(self) -> int:
        return self._stats["warning"]

    @Property(int, notify=changed)
    def critical(self) -> int:
        return self._stats["critical"]

    @Property(float, notify=changed)
    def avgCE(self) -> float:
        return self._stats["avgCE"]

    @Property(float, notify=changed)
    def avgDC(self) -> float:
        return self._stats["avgDC"]

    @Property(float, notify=changed)
    def gapCE(self) -> float:
        return self._stats["gapCE"]

    @Property(float, notify=changed)
    def advancedGap(self) -> float:
        return self._stats["advancedGap"]

    @Property(float, notify=changed)
    def healthyRate(self) -> float:
        return self._stats["healthyRate"]

    @Property(str, notify=changed)
    def lastSignal(self) -> str:
        return self._last_signal

    @Property(int, notify=changed)
    def signalCount(self) -> int:
        return self._signal_count

    @Property(bool, notify=changed)
    def gateOpen(self) -> bool:
        return self._gate_open

    @Property(bool, notify=changed)
    def approvalDone(self) -> bool:
        return bool(self._approval_done)

    @Property(str, notify=changed)
    def approvalLabel(self) -> str:
        if self._approval_done is None:
            return "待人工确认"
        return "已采纳 · 可回写" if self._approval_done else "已驳回 · 不回写"

    @Slot(str)
    def noteSignal(self, text: str) -> None:
        """Shell 只 emit 意图；宿主在此记录，绝不反向写 Shell 状态。"""
        self._last_signal = text
        self._signal_count += 1
        self.changed.emit()

    @Slot()
    def requestApproval(self) -> None:
        self._gate_open = True
        self._last_signal = "approvalRequested()"
        self._signal_count += 1
        self.changed.emit()

    @Slot(bool)
    def approve(self, accepted: bool) -> None:
        self._approval_done = bool(accepted)
        self._last_signal = "采纳建议" if accepted else "驳回建议"
        self._signal_count += 1
        self.changed.emit()

    @Slot()
    def closeGate(self) -> None:
        self._gate_open = False
        self.changed.emit()


def build_pipeline(rows: list[dict], page_size: int = plant.DEFAULT_PAGE_SIZE):
    """model → filter → paged → expand 五段管道；与 1.7.0 P0 口径一致。"""
    columns = plant.build_columns()
    table = NovaDataGridModel(columns, rows, row_key="slot")
    pagination = NovaDataGridPagination(page_size=page_size)
    filter_proxy = NovaDataGridFilterProxy()
    filter_proxy.setSourceModel(table)
    paged_proxy = NovaDataGridPagedProxy(pagination)
    paged_proxy.setSourceModel(filter_proxy)
    pagination.setTotal(len(rows))
    expand_proxy = NovaDataGridExpandProxy()
    expand_proxy.setSourceModel(paged_proxy)
    return table, filter_proxy, paged_proxy, pagination, expand_proxy


def inject(engine, *, rows: list[dict] | None = None,
           seed: int = plant.DEFAULT_SEED,
           page_size: int = plant.DEFAULT_PAGE_SIZE,
           prefix: str = "report") -> dict:
    """把数据管道 + 宿主桥注入引擎；返回强引用句柄（防 GC 提前析构）。"""
    rows = rows if rows is not None else plant.generate_rows(seed=seed)
    table, filter_proxy, paged_proxy, pagination, expand_proxy = build_pipeline(rows, page_size)
    bridge = ReportBridge(plant.compute_stats(rows))
    meta = {
        "rows": len(rows),
        "columns": len(plant.build_columns()),
        "pageSize": page_size,
        "seed": seed,
        "version": "1.10.0",
    }
    props = {
        f"{prefix}Table": table,
        f"{prefix}Filter": filter_proxy,
        f"{prefix}Paged": paged_proxy,
        f"{prefix}Pages": pagination,
        f"{prefix}Expand": expand_proxy,
        f"{prefix}Bridge": bridge,
        f"{prefix}Meta": meta,
    }
    ctx = engine.rootContext()
    for name, value in props.items():
        ctx.setContextProperty(name, value)
    return {"rows": rows, "props": props, "bridge": bridge}
