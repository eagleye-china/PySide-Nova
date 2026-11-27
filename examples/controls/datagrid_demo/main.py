# examples/controls/datagrid_demo/main.py
"""铝电解工作站 · NovaDataGrid 大数据量演示启动器。

运行::

    python examples/controls/datagrid_demo/main.py                 # 4000 槽 + 实时采集
    python examples/controls/datagrid_demo/main.py --rows 10000    # 万行档验证虚拟化
    python examples/controls/datagrid_demo/main.py --no-stream     # 静态快照（截图用）
    python examples/controls/datagrid_demo/main.py --list          # 只打印数据集摘要

架构（与 docs/controls/NovaDataGrid.md 的管道口径一致）::

    data.generate_rows()  ──>  NovaDataGridModel (tableModel)
                                     │
                                     ▼
                         NovaDataGridFilterProxy (filterProxy)
                                     │
                                     ▼
             NovaDataGridPagination ─> NovaDataGridPagedProxy (pagedProxy)
                                     │
                                     ▼
                          NovaDataGrid.qml（TableView 真虚拟化）

统计与采集流在 Python 侧聚合/推送，QML 不遍历全表；这是「大数据量」
场景下与「把 4000 行塞进 JS 数组」最本质的区别。
"""
from __future__ import annotations

import argparse
import random
import sys
from pathlib import Path

DEMO_DIR = Path(__file__).resolve().parent


def find_repo_root(start: Path) -> Path:
    """向上探测含 ``src/pyside_nova/qml/Nova`` 的仓库根。

    坑位 70 经验：``examples/`` 层级会被归档整理（markdown_demo 曾被移入
    ``examples/controls/``），任何写死 ``parents[n]`` 的定位都会静默失效。
    """
    for candidate in (start, *start.parents):
        if (candidate / "src" / "pyside_nova" / "qml" / "Nova").is_dir():
            return candidate
    raise RuntimeError(f"无法从 {start} 向上定位 pyside-nova 仓库根")


REPO_ROOT = find_repo_root(DEMO_DIR)
for _p in (REPO_ROOT / "src", DEMO_DIR):
    if str(_p) not in sys.path:
        sys.path.insert(0, str(_p))

import data as plant
from PySide6.QtCore import Property, QObject, QTimer, Signal, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import init_nova
from pyside_nova.datagrid import (
    NovaDataGridFilterProxy,
    NovaDataGridModel,
    NovaDataGridPagedProxy,
    NovaDataGridPagination,
)


class WorkstationStats(QObject):
    """Python 侧统计聚合，QML 只读取属性，不遍历 4000/10000 行。"""

    changed = Signal()

    def __init__(self, rows: list[dict], parent=None) -> None:
        super().__init__(parent)
        self._d = plant.compute_stats(rows)

    def recompute(self, rows: list[dict]) -> None:
        self._d = plant.compute_stats(rows)
        self.changed.emit()

    @Property(int, notify=changed)
    def total(self) -> int:
        return self._d["total"]

    @Property(int, notify=changed)
    def normal(self) -> int:
        return self._d["normal"]

    @Property(int, notify=changed)
    def warning(self) -> int:
        return self._d["warning"]

    @Property(int, notify=changed)
    def critical(self) -> int:
        return self._d["critical"]

    @Property(float, notify=changed)
    def healthyRate(self) -> float:
        return self._d["healthyRate"]

    @Property(float, notify=changed)
    def avgVoltage(self) -> float:
        return self._d["avgVoltage"]

    @Property(float, notify=changed)
    def avgTemp(self) -> float:
        return self._d["avgTemp"]


class CollectionStream(QObject):
    """模拟 PLC/数采网关的高频采集批次。

    每 ``interval`` ms 推一批 ``batch`` 台槽的增量，走
    ``NovaDataGridModel.batchUpdate()``（50 ms 合并 dataChanged + 1.5 s 行高亮），
    而不是整表重置——这是大数据量下不掉帧的关键。
    """

    changed = Signal()

    def __init__(
        self,
        table: NovaDataGridModel,
        stats: WorkstationStats,
        rows: list[dict],
        index: dict[str, int],
        *,
        interval: int,
        batch: int,
        seed: int,
        parent=None,
    ) -> None:
        super().__init__(parent)
        self._table = table
        self._stats = stats
        self._rows = rows
        self._index = index
        self._rng = random.Random(seed)
        self._batch = max(1, batch)
        self._batch_no = 0
        self._last_slot = ""
        self._running = False
        self._timer = QTimer(self)
        self._timer.setInterval(max(50, interval))
        self._timer.timeout.connect(self.tick)

    @Property(bool, notify=changed)
    def running(self) -> bool:
        return self._running

    @Property(int, notify=changed)
    def batchNo(self) -> int:
        return self._batch_no

    @Property(str, notify=changed)
    def lastSlot(self) -> str:
        return self._last_slot

    @Property(int, notify=changed)
    def batchSize(self) -> int:
        return self._batch

    @Property(int, notify=changed)
    def intervalMs(self) -> int:
        return self._timer.interval()

    @Slot()
    def start(self) -> None:
        if not self._running:
            self._running = True
            self._timer.start()
            self.changed.emit()

    @Slot()
    def stop(self) -> None:
        if self._running:
            self._running = False
            self._timer.stop()
            self.changed.emit()

    @Slot()
    def toggle(self) -> None:
        self.stop() if self._running else self.start()

    @Slot()
    def tick(self) -> None:
        updates = plant.make_batch(self._rng, self._rows, self._batch)
        if not updates:
            return
        # 宿主数据镜像与模型同步更新，保证统计与表格账实同源
        for update in updates:
            idx = self._index.get(update["slot"])
            if idx is not None:
                merged = dict(self._rows[idx])
                merged.update(update)
                self._rows[idx] = merged
        self._table.batchUpdate(updates)
        self._stats.recompute(self._rows)
        self._batch_no += 1
        self._last_slot = str(updates[-1]["slot"])
        self.changed.emit()


def build_pipeline(rows: list[dict], page_size: int):
    columns = plant.build_columns()
    table = NovaDataGridModel(columns, rows, row_key="slot")
    pagination = NovaDataGridPagination(page_size=page_size)
    filter_proxy = NovaDataGridFilterProxy()
    filter_proxy.setSourceModel(table)
    paged_proxy = NovaDataGridPagedProxy(pagination)
    paged_proxy.setSourceModel(filter_proxy)
    pagination.setTotal(len(rows))
    return table, filter_proxy, paged_proxy, pagination


def make_meta(*, rows: int, seed: int, page_size: int,
              interval: int, batch: int) -> dict:
    """注入 QML 的运行参数；启动器与离屏验收共用同一份，避免账实不符。"""
    return {
        "rows": rows,
        "seed": seed,
        "columns": len(plant.build_columns()),
        "pageSize": page_size,
        "interval": interval,
        "batch": batch,
        "version": "1.5.0",
        "tempWarn": plant.TEMP_WARN,
        "tempCrit": plant.TEMP_CRIT,
        "voltWarn": plant.VOLT_WARN,
        "voltCrit": plant.VOLT_CRIT,
    }


def _print_summary(rows: list[dict], args: argparse.Namespace) -> None:
    stats = plant.compute_stats(rows)
    print("== 铝电解工作站数据集 ==")
    print(f"  槽位数       : {stats['total']}")
    print(f"  工艺列       : {len(plant.build_columns())}")
    print(f"  正常 / 预警 / 严重 : {stats['normal']} / {stats['warning']} / {stats['critical']}")
    print(f"  正常率       : {stats['healthyRate']} %")
    print(f"  平均槽电压   : {stats['avgVoltage']} V")
    print(f"  平均电解温度 : {stats['avgTemp']} °C")
    print(f"  分页         : 每页 {args.page_size} 槽 / 共 {((len(rows) + args.page_size - 1) // args.page_size)} 页")
    print(f"  采集         : 每 {args.interval} ms 推 {args.batch} 槽"
          + ("（--no-stream 已关闭）" if args.no_stream else ""))
    print(f"  阈值         : 温度 {plant.TEMP_WARN}/{plant.TEMP_CRIT} °C ·"
          f" 电压 {plant.VOLT_WARN}/{plant.VOLT_CRIT} V ·"
          f" 效应 {plant.EFFECT_WARN}/{plant.EFFECT_CRIT} 次")
    print(f"  seed         : {args.seed}（确定性，可复现）")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="NovaDataGrid 铝电解工作站大数据量演示")
    parser.add_argument("--rows", type=int, default=plant.DEFAULT_ROWS,
                        help=f"槽位行数（默认 {plant.DEFAULT_ROWS}，可试 10000）")
    parser.add_argument("--seed", type=int, default=plant.DEFAULT_SEED,
                        help="数据随机种子（确定性）")
    parser.add_argument("--interval", type=int, default=plant.DEFAULT_INTERVAL,
                        help="采集批次间隔 ms")
    parser.add_argument("--batch", type=int, default=plant.DEFAULT_BATCH,
                        help="每批刷新的槽位数")
    parser.add_argument("--page-size", type=int, default=50,
                        help="分页大小")
    parser.add_argument("--no-stream", action="store_true",
                        help="关闭实时采集（静态快照，截图/验收用）")
    parser.add_argument("--list", action="store_true",
                        help="只打印数据集摘要，不启动窗口")
    args = parser.parse_args(argv)

    rows = plant.generate_rows(args.rows, args.seed)
    if args.list:
        _print_summary(rows, args)
        return 0

    # 保持 QGuiApplication / QML 引擎的 Python 强引用，避免离屏期间被 GC 提前析构
    app = QGuiApplication.instance() or QGuiApplication(sys.argv)
    table, filter_proxy, paged_proxy, pagination = build_pipeline(rows, args.page_size)
    stats = WorkstationStats(rows)
    index = {r["slot"]: i for i, r in enumerate(rows)}
    stream = CollectionStream(
        table, stats, rows, index,
        interval=args.interval, batch=args.batch, seed=args.seed + 1,
    )

    engine = QQmlApplicationEngine()
    init_nova(engine)
    ctx = engine.rootContext()
    for name, obj in (
        ("plantTable", table),
        ("plantFilter", filter_proxy),
        ("plantPaged", paged_proxy),
        ("plantPages", pagination),
        ("plantStats", stats),
        ("plantStream", stream),
    ):
        ctx.setContextProperty(name, obj)
    ctx.setContextProperty("plantMeta", make_meta(
        rows=args.rows, seed=args.seed, page_size=args.page_size,
        interval=args.interval, batch=args.batch,
    ))

    engine.load(str(DEMO_DIR / "main.qml"))
    if not engine.rootObjects():
        print("QML 加载失败：无根对象", file=sys.stderr)
        return 1
    if not args.no_stream:
        stream.start()
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
