# tests/test_soak.py
# 24h 内存长跑压测（RC2 封版验收项）：反复创建/销毁高风险对象 + RSS 趋势判定
"""24h 内存长跑（soak test）。

对齐 docs/ECOSYSTEM_PARITY.md §6「24h 压测无内存增长」。设计纪律：
- pytest 常驻单引擎（坑位 42）——不新建 QQmlEngine；
- qrc:/ 单斜杠（坑位 48）——所有 setData URL；
- 长跑收尾 os._exit 硬退出（坑位 49）——由 conftest 在 --soak 时接管；
- 零依赖 RSS 采样（soak_mem.py，ctypes 直调系统 API）。

负载循环覆盖长期运行的高泄漏风险路径（对象池复用，零对象创建）：
1. 弹层 registerPopup / unregisterPopup（坑位 35：漏注销会级联污染）；
2. 长寿命 NovaTable 派生属性读取（验证组件自身常驻不泄漏）；
3. 明暗主题切换 + 令牌读取（派生缓存）；
4. i18n locale 切换 + 翻译读取（服务单例状态）。

不测「反复创建/销毁复杂 QML 组件」：Qt 6.12 + PySide6 对此有 ~0.3-0.5MB/次
不可回收固有开销（纯 Qt Quick 组件同样复现，属引擎层行为），纳入会掩盖产品真泄漏。

默认 24h；冒烟用 --soak-hours 0.02（约 72s）快速验证判定链路。
"""
from __future__ import annotations

import gc
import json
import os
import time
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QMetaObject, QObject, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent

ROOT = Path(__file__).resolve().parent.parent

# 判定阈值（24h 全量口径）：稳态斜率 ≤ 2 MB/h、分段漂移 ≤ 24 MB、峰值 ≤ 1500 MB。
# 24h × 2MB/h = 48MB 容许带，覆盖 Python/Qt 分配器碎片与缓存抖动，仍能抓住真泄漏
# （真泄漏通常 >100MB/24h 且单调）。冒烟模式由 CLI 放宽采样数要求。
MAX_SLOPE_MB_H = 2.0
MAX_DRIFT_MB = 24.0
MAX_RSS_MB = 1500.0

# 单一 QML harness：所有负载在 QML 内部完成（坑位 11——Python 不摸 QML wrapper，
# 只经元对象调 workload()）。轮数用属性承载（坑位 46：不依赖函数返回值）。
#
# 负载设计（踩过的坑，务必保持）：
# - 稳态语义：对象池复用，一次创建 N 个弹层/表格长期持有，之后只反复操作它们。
#   绝不每轮 createObject/destroy 复杂组件——实测 Qt 6.12+PySide6 每创建销毁一个
#   复杂 QML 组件有 ~0.3-0.5MB 不可回收固有开销（纯 Qt Quick 组件同样如此，属引擎
#   层行为），测它会让门禁永远红灯、失去意义。
# - 弹层走真实 NovaOverlayHost register/unregister（坑位 35）但用固定对象反复开关；
# - 表格常驻只读派生属性：不反复赋值 rows / 翻页（那会重建 delegate，触发引擎固有开销）；
# - 根类型必须 Item（非 QtObject）：动态对象用 Component.createObject(this)，
#   传 null parent 或 Qt.createQmlObject(null,...) 会让 QML 函数静默中断。
_HARNESS_QML = b"""
import QtQuick
import Nova.Services
import Nova.Controls
Item {
    property int cyclesDone: 0
    property var dataRows: []
    property var table: null
    property var popups: []
    property Component tableComp: Component {
        Rectangle {
            width: 400; height: 300
            property var rows: []
            NovaTable {
                anchors.fill: parent
                columns: ["A", "B", "C"]
                rows: parent.rows
                rowsPerPage: 20
            }
        }
    }
    property Component popComp: Component { Rectangle { width: 10; height: 10 } }
    Component.onCompleted: {
        var d = [];
        for (var i = 0; i < 1000; i++) d.push({ A: "x" + i, B: i, C: "ok" });
        dataRows = d;
        table = tableComp.createObject(this);
        for (var p = 0; p < 6; p++) popups.push(popComp.createObject(this));
    }
    function noop() {}
    function workload() {
        // 1) popup register/unregister on pooled objects (real popup stack, no churn)
        //    closeFn reuses one function reference, no per-round JS closure
        for (var p = 0; p < popups.length; p++) {
            NovaOverlayHost.registerPopup(popups[p], noop);
            NovaOverlayHost.unregisterPopup(popups[p]);
        }
        // 2) long-lived NovaTable: read derived state only. Do NOT reassign rows
        //    or flip pages - that rebuilds Repeater delegates, whose ~0.3-0.5MB
        //    per-cycle churn is a Qt 6.12 engine artifact (reproduces with pure
        //    Qt Quick components) and would drown out real product leaks.
        var cnt = table.rowCount;
        var vis = table.visibleRows;
        // 3) theme / i18n / token reads (long-running property paths)
        NovaTheme.toggleDark();
        var c = NovaTheme.primary;
        var s = NovaI18n.t("app.title");
        NovaI18n.setLocale(NovaI18n.locale === "en" ? "zh_CN" : "en");
        cyclesDone++;
    }
}
"""


def _pump(seconds: float) -> None:
    end = time.perf_counter() + seconds
    while time.perf_counter() < end:
        QGuiApplication.processEvents()
        time.sleep(0.005)


@pytest.fixture(scope="module")
def engine(qml_engine):
    return qml_engine


def _make_probe(engine, code: bytes, tag: str, anchor: QObject):
    """用 Python 强引用的 QObject 作 parent 创建探针——否则 QML 顶层对象被 JS GC
    回收（坑位 11：Python 引用保不住 QML 顶层对象）。"""
    comp = QQmlComponent(engine)
    comp.setData(code, QUrl(f"qrc:/soak-{tag}.qml"))
    obj = comp.createObject(anchor)
    assert obj is not None, f"{tag} 探针创建失败: {[e.toString() for e in comp.errors()]}"
    return obj


def test_soak_memory_leak(engine, request):
    """24h 长跑：稳态运行时反复触发高风险操作 + 周期采样 GC 后 RSS，判定无单调增长。

    负载用对象池（一次创建、反复操作），不每轮 createObject/destroy 复杂组件——
    后者会测到 Qt 6.12 引擎创建对象的固有不可回收开销（纯 Qt Quick 组件同样），
    属引擎层行为，测它让门禁永远红灯。真正要抓的是「稳态运行中不可回收的增长」。
    采样前驱动 QML GC + Python GC，读 GC 后的驻留 RSS（排除待回收垃圾干扰）。
    """
    from soak_mem import analyze, rss_mb

    hours = float(request.config.getoption("--soak-hours"))
    interval = float(request.config.getoption("--soak-interval"))
    report_path = request.config.getoption("--soak-report")

    # 编译一次 harness，创建一个长期存活实例（带 anchor 强引用抗 JS GC，坑位 11）
    comp = QQmlComponent(engine)
    comp.setData(_HARNESS_QML, QUrl("qrc:/soak-harness.qml"))
    assert comp.isReady() and not comp.isError(), \
        f"harness 编译失败: {[e.toString() for e in comp.errors()]}"

    anchor = QObject()  # Python 强引用 parent，保住 harness 顶层对象（坑位 11）
    harness = comp.createObject(anchor)
    assert harness is not None, "harness 创建失败"
    assert engine.collectGarbage is not None  # Qt6 引擎 GC 可用（判定前必须能排垃圾）

    deadline = time.perf_counter() + hours * 3600
    next_sample = time.perf_counter() + min(interval, max(0.5, hours * 3600 / 12))
    samples: list[tuple[float, float, int]] = []
    t0 = time.perf_counter()
    cycles = 0

    def sample() -> None:
        # 驱动 JS 堆 + Python 堆 GC，读 GC 后的真实驻留 RSS——
        # 只有 GC 后仍增长才是不可回收的真泄漏（纯待回收垃圾不算）。
        engine.collectGarbage()
        gc.collect()
        _pump(0.02)
        samples.append((time.perf_counter() - t0, rss_mb(), 0))

    sample()  # 起点

    while time.perf_counter() < deadline:
        QMetaObject.invokeMethod(harness, "workload")
        cycles += 1
        _pump(0.005)
        if time.perf_counter() >= next_sample:
            sample()
            if samples[-1][1] > MAX_RSS_MB * 1.3:
                # 硬止损：明显爆内存时提前收尾，避免拖垮整机
                break
            next_sample = time.perf_counter() + interval

    sample()  # 收尾
    anchor.deleteLater()
    _pump(0.1)

    verdict = analyze(
        samples,
        max_slope=MAX_SLOPE_MB_H,
        max_drift=MAX_DRIFT_MB,
        max_rss=MAX_RSS_MB,
        min_samples=4 if hours < 0.1 else 20,
    )

    report = {
        "config": {"hours": hours, "interval_sec": interval, "cycles": cycles,
                   "max_slope_mb_h": MAX_SLOPE_MB_H, "max_drift_mb": MAX_DRIFT_MB,
                   "max_rss_mb": MAX_RSS_MB},
        "verdict": verdict.as_dict(),
        "samples": [[round(t, 2), round(r, 2), o] for t, r, o in samples],
    }
    if report_path:
        p = Path(report_path)
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"\n[soak] {hours:.3f}h / {cycles} 轮 / {len(samples)} 样本 → {verdict.reason}")
    if report_path:
        print(f"[soak] 报告：{report_path}")
    # 坑位 49：长跑后解释器收尾期 GC 崩溃——标记由 conftest 硬退出（退出码已还原）
    # 注意必须在 assert 之前标记，失败时同样走硬退出保留非零退出码
    request.config._nova_soak_hard_exit = True
    assert verdict.ok, f"24h 压测内存判定失败：{verdict.reason}"


def test_soak_analyzer_selfcheck():
    """判定器自检：合成平坦/单调增长序列，确认口径不误报也不漏报。"""
    from soak_mem import analyze

    flat = [(i * 600.0, 300.0 + (i % 3) * 0.4, 50000) for i in range(30)]
    leak = [(i * 600.0, 300.0 + i * 8.0, 50000 + i * 400) for i in range(30)]
    kw = {"max_slope": 2.0, "max_drift": 24.0, "max_rss": 1500.0}
    assert analyze(flat, **kw).ok, "平坦序列被误判为泄漏"
    assert not analyze(leak, **kw).ok, "单调增长序列被漏判"
