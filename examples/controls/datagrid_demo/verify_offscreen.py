# examples/controls/datagrid_demo/verify_offscreen.py
"""铝电解工作站 demo · 离屏真机自检（非 pytest，供手工验收与 CI 复核）。

运行::

    QT_QPA_PLATFORM=offscreen python examples/controls/datagrid_demo/verify_offscreen.py

验收口径：
  - 真实 QQmlApplicationEngine 加载 main.qml，4000 槽 / 11 列全管道；
  - 视觉树取证走 ``QQuickItem.childItems()``（坑位 69）；
  - 每个 QML 表达式后推进事件循环（坑位 73，避免 invalidate 踩半更新状态）；
  - 两张 grabWindow() 截图（默认亮色 / 暗色告警视图）；
  - 0 条坏 Qt 消息。
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QPA_FONTDIR", "C:/Windows/Fonts")
# Windows offscreen 下 QWindowsTheme 会尝试打开原生 SCROLLBAR 主题：既刷 52 条
# `OpenThemeData() failed for theme 8` 消息，又把 TableView 的 ScrollBar indicator
# 画成黑/白竖条。强制 Qt Quick Controls 走 Basic 自绘样式，两个问题一起消失（README §7）。
os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")

DEMO_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(DEMO_DIR))

import data as plant
import main as demo_main
from PySide6.QtCore import QEventLoop, QObject, QTimer, qInstallMessageHandler
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QQmlExpression, qmlContext
from PySide6.QtQuick import QQuickItem, QQuickWindow
from shiboken6 import getCppPointer, wrapInstance

from pyside_nova import init_nova

SHOT = DEMO_DIR / "datagrid_demo.png"
SHOT_DARK = DEMO_DIR / "datagrid_demo_dark.png"

MESSAGES: list[str] = []
BAD: list[str] = []


def _handler(msg_type, context, message):
    """模块级函数保持强引用；只把真正的错误/告警当坏消息。"""
    text = str(message)
    MESSAGES.append(text)
    low = text.lower()
    # Windows QPA 平台噪声：offscreen 下打开原生滚动条主题失败，与产品代码无关。
    if "openthemedata()" in low:
        return
    if any(k in low for k in ("error", "failed", "cannot ", "undefined", "is not defined",
                              "referenceerror", "typeerror", "syntax error", "binding loop",
                              "cannot assign", "invalid property", "deprecated")):
        BAD.append(text)


def qeval(root: QObject, expr: str):
    ctx = qmlContext(root)
    ex = QQmlExpression(ctx, root, expr)
    value, undefined = ex.evaluate()
    if ex.hasError():
        raise RuntimeError(f"QQmlExpression 求值失败: {expr} -> {ex.error().toString()}")
    return None if undefined else value


def count_text(item: QQuickItem) -> int:
    """坑位 69：Repeater/TableView delegate 是视觉子项，须走 childItems()。"""
    count = 0
    stack = [item]
    while stack:
        cur = stack.pop()
        for child in cur.childItems():
            mo = child.metaObject()
            if mo and mo.className() == "QQuickText":
                count += 1
            stack.append(child)
    return count


def main() -> int:
    qInstallMessageHandler(_handler)

    rows_count = plant.DEFAULT_ROWS
    page_size = 50
    interval = plant.DEFAULT_INTERVAL
    batch = plant.DEFAULT_BATCH
    rows = plant.generate_rows(rows_count, plant.DEFAULT_SEED)

    # 保持 QGuiApplication 的 Python 强引用，避免离屏验收期间被 GC 提前析构。
    _app = QGuiApplication.instance() or QGuiApplication(sys.argv)
    table, filter_proxy, paged_proxy, pagination = demo_main.build_pipeline(rows, page_size)
    stats = demo_main.WorkstationStats(rows)
    index = {r["slot"]: i for i, r in enumerate(rows)}
    stream = demo_main.CollectionStream(
        table, stats, rows, index,
        interval=interval, batch=batch, seed=plant.DEFAULT_SEED + 1,
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
    ctx.setContextProperty("plantMeta", demo_main.make_meta(
        rows=rows_count, seed=plant.DEFAULT_SEED, page_size=page_size,
        interval=interval, batch=batch,
    ))

    engine.load(str(DEMO_DIR / "main.qml"))
    roots = engine.rootObjects()
    if len(roots) != 1:
        print("== 结论 == FAIL（根对象数 != 1）")
        for m in MESSAGES[:10]:
            print("  |", m[:200])
        return 1
    root = roots[0]

    loop = QEventLoop()
    QTimer.singleShot(500, loop.quit)
    loop.exec()

    def step(label: str, expr: str):
        value = qeval(root, expr)
        print(f"  {label:34s} -> {value}")
        # 坑位 73：模型变更后必须让 QML 事件循环消化绑定/delegate 更新
        QTimer.singleShot(40, loop.quit)
        loop.exec()
        return value

    qwin = wrapInstance(getCppPointer(root)[0], QQuickWindow)

    # ── 默认态截图（未启动采集，无交互残留）──
    img = qwin.grabWindow()
    ok_img = img.save(str(SHOT))
    print("== 截图（默认态 · 亮色 / 全量） ==")
    print("  路径:", SHOT, "| 尺寸:", img.width(), "x", img.height(), "| 保存:", ok_img)

    print("== 大数据量硬证据 ==")
    text_count = count_text(root.contentItem())
    total_rows = step("源模型总行数", "plantTable.rowCount()")
    page_rows = step("当前页可见行数（分页切片）", "grid._model.rowCount()")
    total = step("分页总数", "plantPages.total")
    cols = step("列数", "grid.columnDefs.length")
    print(f"  视觉树 QQuickText 数量          : {text_count}")
    print(f"  虚拟化比（可见行 / 总行）       : {page_rows} / {total_rows}")
    assert total_rows == rows_count, f"源模型应 {rows_count} 行"
    assert page_rows == page_size, f"分页切片应 {page_size} 行"
    assert total == rows_count, "分页总数应与源模型一致"
    assert cols == 11, "应有 11 列工艺参数"
    # 4000 行 × 11 列若全量渲染会有数万个 QQuickText；这里远小于它，证明真虚拟化
    assert text_count < 900, f"视觉树文本数 {text_count} 过大，疑似未虚拟化"

    print("== 统计卡片（Python 侧聚合） ==")
    s_total = step("在册槽数", "plantStats.total")
    step("正常率 %", "plantStats.healthyRate")
    s_warn = step("预警槽", "plantStats.warning")
    s_crit = step("严重槽", "plantStats.critical")
    step("平均槽电压", "plantStats.avgVoltage")
    step("平均电解温度", "plantStats.avgTemp")
    assert s_total == rows_count
    assert s_warn + s_crit + step("正常槽", "plantStats.normal") == rows_count

    print("== 交互事件链 ==")
    step("排序 voltage", "grid.sortByKey('voltage', true)")
    step("排序键", "grid._sortKey")
    step("过滤：预警", "plantFilter.setQuickFilter('预警')")
    step("过滤后页内行数", "grid._model.rowCount()")
    step("清除过滤", "plantFilter.clearFilters()")
    step("恢复后页内行数", "grid._model.rowCount()")
    step("手动刷新一批", "plantStream.tick()")
    step("批次号", "plantStream.batchNo")
    step("最近刷新槽", "plantStream.lastSlot")
    step("启动采集", "plantStream.start()")
    step("采集中", "plantStream.running")
    step("暂停采集", "plantStream.stop()")
    step("精简列（5 列）", "plantTable.setVisibleColumns(['slot','workshop','voltage','temp','state'])")
    step("精简后列数", "grid.columnDefs.length")
    step("恢复 11 列", "plantTable.setVisibleColumns(['slot','workshop','voltage','current','temp','alumina','ratio','drop','effect','age','state'])")
    step("恢复后列数", "grid.columnDefs.length")
    step("翻到末页", "plantPages.lastPage()")
    step("末页页码", "plantPages.currentPage")
    step("回到首页", "plantPages.firstPage()")
    step("滚动到行", "grid.scrollToRow(30)")
    step("键盘游标", "grid._a11ySet(2)")
    step("取首行数据", "JSON.stringify(grid.getRowData(0)).slice(0, 60)")
    step("右键菜单信号", "grid.rowContextMenuRequested(0, 20, 30)")
    step("清空选择", "grid.clearSelection()")

    # ── 暗色告警视图截图 ──
    step("切到暗色", "NovaTheme.setDark(true)")
    step("仅看严重", "plantFilter.setQuickFilter('严重')")
    step("暗色 isDark", "NovaTheme.isDark")
    QTimer.singleShot(250, loop.quit)
    loop.exec()
    img_dark = qwin.grabWindow()
    ok_dark = img_dark.save(str(SHOT_DARK))
    print("== 截图（交互态 · 暗色 / 严重槽过滤） ==")
    print("  路径:", SHOT_DARK, "| 尺寸:", img_dark.width(), "x", img_dark.height(), "| 保存:", ok_dark)

    print("== Qt 消息 ==")
    print("  总消息:", len(MESSAGES), "| 坏消息:", len(BAD))
    for m in BAD[:10]:
        print("  BAD:", m[:220])

    passed = (len(roots) == 1 and len(BAD) == 0 and ok_img and ok_dark
              and total_rows == rows_count and text_count < 900)
    print("== 结论 ==", "PASS" if passed else "FAIL")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
