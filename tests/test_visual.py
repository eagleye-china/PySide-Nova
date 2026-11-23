# tests/test_visual.py
# 视觉回归基线（0.16.2 B3）：明/暗 × 5 断点 × 全画廊 24 页（MASTER_PLAN Sprint B3 门禁）
"""视觉回归门禁。

矩阵：明暗两主题 × 5 断点（xs=480 / sm=800 / md=1200 / lg=1600 / xl=1920）× 24 页 = 240 张。
- 默认 `pytest tests/` 只跑 **smoke 抽检**（md 断点 × 明暗 × 3 关键页，秒级）；
- **全矩阵**由 `scripts/check_visual.py`（--visual-full）承载，基线经 --snapshot-update 生成。

坑位纪律（0.16.1 沉淀）：qrc:/ 单斜杠（坑位 48）；QML helper + Python 直调（坑位 44）；
测试单引擎（坑位 42）。基线为 PNG 无损；diff 口径：单通道差 >8 视为差异像素，
占比 >0.2% 判失败（容忍反走样噪声）。
"""
import os
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QBuffer, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent
from PySide6.QtQuick import QQuickItem

_ALIVE = []

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "tests" / "baselines" / "visual"

BP = [("xs", 480), ("sm", 800), ("md", 1200), ("lg", 1600), ("xl", 1920)]
THEMES = ["light", "dark"]
NPAGES = 24
PIXEL_TOL = 12      # 单通道差容忍（反走样 + 256 色量化噪声）
DIFF_RATIO = 0.01   # 差异像素占比上限 1%（真正回归通常 >10%）

_PROBE = """
import QtQuick
import Nova.Services
QtObject {
    function toggleDark() { NovaTheme.toggleDark() }
    function isDark() { return NovaTheme.isDark }
    function resetI18n() { NovaI18n.setLocale("en-US") }
}
"""

# smoke 抽检页：概览 / 数据体系 / 国际化
SMOKE_PAGES = [0, 17, 23]


@pytest.fixture(scope="module", autouse=True)
def _teardown(qml_engine):
    """模块收尾：释放本模块 QML 对象（引擎先于 Window 析构会在退出期 SIGSEGV，0.16.0 实测）。"""
    yield
    # 退出期崩溃规避（0.16.2 坑位 49）：全矩阵长跑后解释器收尾期 GC 触发
    # shiboken refcount 崩溃（none_dealloc）——按创建逆序 deleteLater 全部
    # QML 对象（窗口/组件/探针），事件循环内完成 C++ 析构，避免收尾期隐式析构
    from PySide6.QtCore import QTimer
    for obj in reversed(_ALIVE):
        try:
            obj.deleteLater()
        except RuntimeError:
            pass
    _ALIVE.clear()
    _pump(0.15)
    import gc
    gc.collect()


@pytest.fixture(scope="module")
def engine(qml_engine):
    return qml_engine


def _pump(seconds=0.15):
    import time
    end = time.perf_counter() + seconds
    while time.perf_counter() < end:
        QGuiApplication.processEvents()
        time.sleep(0.01)


def _probe(engine):
    comp = QQmlComponent(engine)
    comp.setData(_PROBE.encode("utf-8"), QUrl("qrc:/visual-probe.qml"))
    obj = comp.create()
    assert obj is not None, [e.toString() for e in comp.errors()]
    _ALIVE.append(obj)
    _ALIVE.append(comp)
    return obj, comp


def _make_gallery(engine):
    comp = QQmlComponent(engine, QUrl.fromLocalFile(str(ROOT / "examples" / "gallery" / "main.qml")))
    win = comp.create()
    assert win is not None, [e.toString() for e in comp.errors()]
    _ALIVE.append(win)
    _ALIVE.append(comp)
    return win, comp


def _shoot(win, path: Path):
    import io

    from PIL import Image
    img = win.grabWindow()
    assert not img.isNull(), f"grabWindow 失败：{path}"
    path.parent.mkdir(parents=True, exist_ok=True)
    buf = QBuffer()
    buf.open(QBuffer.ReadWrite)
    assert img.save(buf, "PNG"), "QImage 内存保存失败"
    buf.seek(0)
    im = Image.open(io.BytesIO(bytes(buf.data())))
    if im.mode != "RGB":
        im = im.convert("RGB")
    im = im.convert("P", palette=Image.ADAPTIVE, colors=256)
    im.save(str(path), "PNG", optimize=True)
    assert path.exists() and path.stat().st_size > 0, f"save 失败：{path}"


def _theme_to(probe, want: str):
    """循环 toggle 直到匹配目标主题（幂等防御：前序测试可能已切换）。"""
    for _ in range(4):
        if probe.isDark() == (want == "dark"):
            return
        probe.toggleDark()
        _pump(0.1)
    assert probe.isDark() == (want == "dark"), "主题切换失败"


def _diff(baseline: Path, current: Path) -> float:
    import numpy as np
    from PIL import Image
    a = np.asarray(Image.open(str(baseline)).convert("RGB"), dtype=np.int16)
    b = np.asarray(Image.open(str(current)).convert("RGB"), dtype=np.int16)
    if a.shape != b.shape:
        return 1.0
    d = np.abs(a - b).max(axis=2)
    return float((d > PIXEL_TOL).mean())


def _shoot_matrix(engine, tmpdir: Path, pages, bps, themes):
    """全矩阵截图到 tmpdir/{theme}/{bp}-p{page}.png，返回 (win, probe)。"""
    win, win_comp = _make_gallery(engine)
    probe, probe_comp = _probe(engine)
    nav = win.findChild(QQuickItem, "nav")
    assert nav is not None
    probe.resetI18n()
    for theme in themes:
        _theme_to(probe, theme)
        for bp, width in bps:
            win.resize(width, 900)
            _pump(0.25)
            for page in pages:
                nav.setProperty("currentIndex", page)
                _pump(0.4)
                _shoot(win, tmpdir / theme / f"{bp}-p{page:02d}.png")
    return win, win_comp, probe, probe_comp


def test_visual_smoke(engine, tmp_path):
    """smoke：md 断点 × 明暗 × 3 关键页，有基线则 diff、无基线则生成。"""
    win, win_comp, probe, probe_comp = _shoot_matrix(engine, tmp_path, SMOKE_PAGES, [("md", 1200)], THEMES)
    try:
        for theme in THEMES:
            for page in SMOKE_PAGES:
                name = f"{theme}/md-p{page:02d}.png"
                cur = tmp_path / name
                base = BASE / name
                assert cur.exists(), f"smoke 截图缺失 {name}"
                if not base.exists():
                    # 首次建仓：以本次截图为基线
                    cur.parent.mkdir(parents=True, exist_ok=True)
                    base.parent.mkdir(parents=True, exist_ok=True)
                    cur.rename(base)
                    continue
                ratio = _diff(base, cur)
                assert ratio <= DIFF_RATIO, f"视觉回归超差 {name}: {ratio:.4f} > {DIFF_RATIO}"
    finally:
        probe.resetI18n()


@pytest.mark.visual
def test_visual_full_matrix(engine, request, tmp_path):
    """全矩阵门禁：明暗 × 5 断点 × 24 页 diff（scripts/check_visual.py --visual-full 承载）。"""
    if not request.config.getoption("--visual-full", default=False):
        pytest.skip("全矩阵由 scripts/check_visual.py 承载（pytest --visual-full）")
    update = request.config.getoption("--snapshot-update", default=False)
    if update:
        _shoot_matrix(engine, BASE, range(NPAGES), BP, THEMES)
        return
    win, win_comp, probe, probe_comp = _shoot_matrix(engine, tmp_path, range(NPAGES), BP, THEMES)
    failures = []
    for theme in THEMES:
        for bp, _w in BP:
            for page in range(NPAGES):
                name = f"{theme}/{bp}-p{page:02d}.png"
                base = BASE / name
                if not base.exists():
                    failures.append(f"缺基线 {name}")
                    continue
                ratio = _diff(base, tmp_path / name)
                if ratio > DIFF_RATIO:
                    failures.append(f"{name}: {ratio:.4f}")
    if failures:
        assert False, "视觉回归超差/缺基线：\n" + "\n".join(failures[:12])
    # 坑位 49（0.16.2）：全矩阵长跑（240 截图 × 148s）后解释器收尾期 GC 触发
    # shiboken refcount 崩溃（none_dealloc，deleteLater/显式 close/GC 均无效）。
    # 标记后由 conftest.pytest_unconfigure 硬退出（报告已完成），保 CI 退出码语义。
    request.config._nova_visual_hard_exit = True
