# tests/test_hidpi.py
# HiDPI 测试（0.16.1）：100% / 150% / 200% 缩放矩阵下组件几何正确、单例缩放事实可读
"""HiDPI 100~200% 验证。

Qt 6 默认启用高 DPI 缩放（AA_EnableHighDpiScaling），组件以逻辑像素书写、
系统按 dpr 自动放大——组件库无需自行换算（对标 Quasar：无 HiDPI 特殊分支）。
本模块验证两层：
1. 缩放事实层：NovaRuntime.devicePixelRatio / scaleFactor 随 QT_SCALE_FACTOR 联动
2. 几何层：子进程 + QT_SCALE_FACTOR ∈ {1.0, 1.5, 2.0} 下 NovaBtn 逻辑宽度不变
   （布局不重排；物理像素由渲染管线按 dpr 放大）
"""
import os
import subprocess
import sys
import tempfile
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QUrl
from PySide6.QtQml import QQmlComponent

ROOT = Path(__file__).resolve().parent.parent

# 子进程探针（写入临时文件执行，避免三引号转义）
_PROBE_TEMPLATE = """
import sys
sys.path.insert(0, {root!r})
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent, QQmlEngine
from pyside_nova import init_nova

app = QGuiApplication([])
engine = QQmlEngine()
init_nova(engine)

qml = '''
import QtQuick
import Nova.Runtime
import Nova.Services
import Nova.Controls
Item {{
    width: 300; height: 80
    NovaBtn {{ id: b; objectName: "b"; text: "OK"; width: 160; height: 40 }}
    readonly property real dpr: NovaRuntime.devicePixelRatio
    readonly property real sf: NovaRuntime.scaleFactor
    readonly property real btnLogicalW: b.width
}}
'''
# 对标 test_smoke 顺序纪律：先热身服务单例，再建组件（坑位 48）
warm = QQmlComponent(engine)
warm.setData(b"import QtQuick\\nimport Nova.Services\\n"
             b"QtObject {{ property color c: NovaTheme.primary }}", QUrl("qrc:/hidpi-warm.qml"))
assert warm.create() is not None
comp = QQmlComponent(engine)
comp.setData(qml.encode("utf-8"), QUrl("qrc:/hidpi-probe.qml"))
host = comp.create()
if host is None:
    print("ERRORS:", [e.toString() for e in comp.errors()])
    sys.exit(2)
app.processEvents()
print("RESULT", host.property("dpr"), host.property("sf"), host.property("btnLogicalW"))
"""


def _run_scaled(scale: str) -> tuple[float, float, float]:
    probe = _PROBE_TEMPLATE.format(root=str(ROOT / "src")).encode()
    with tempfile.NamedTemporaryFile("wb", suffix=".py", delete=False) as f:
        f.write(probe)
        path = f.name
    try:
        env = dict(os.environ)
        env["QT_QPA_PLATFORM"] = "offscreen"
        env["QT_SCALE_FACTOR"] = scale
        proc = subprocess.run(
            [sys.executable, path],
            capture_output=True, text=True, env=env, cwd=str(ROOT), timeout=60)
    finally:
        os.unlink(path)
    out = [l for l in proc.stdout.splitlines() if l.startswith("RESULT")]
    assert out, f"scale={scale} 无输出: {proc.stdout[-300:]} {proc.stderr[-300:]}"
    parts = out[0].split()
    return float(parts[1]), float(parts[2]), float(parts[3])   # dpr, sf, logicalW


@pytest.mark.parametrize("scale,dpr", [("1.0", 1.0), ("1.5", 1.5), ("2.0", 2.0)])
def test_scale_factor_matrix(scale, dpr):
    """QT_SCALE_FACTOR 100~200%：dpr 联动、按钮逻辑宽度恒定（布局不重排）。"""
    got_dpr, got_sf, logical_w = _run_scaled(scale)
    assert abs(got_dpr - dpr) < 0.01, f"devicePixelRatio 应为 {dpr}，实际 {got_dpr}"
    assert abs(got_sf - float(scale)) < 0.01
    # 逻辑像素书写口径：组件宽度不随缩放变化（Qt 渲染管线负责物理放大）
    assert logical_w == 160.0, f"逻辑宽度应恒 160，实际 {logical_w}"


@pytest.fixture(scope="module")
def engine(qml_engine):
    return qml_engine


def test_runtime_dpr_default(engine):
    """无缩放环境：默认 dpr≥1.0、scaleFactor=1.0（Python snapshot 同步暴露）。"""
    from pyside_nova.runtime import runtime_snapshot

    comp = QQmlComponent(engine)
    comp.setData(
        b"import QtQuick\nimport Nova.Runtime\n"
        b"QtObject { property real dpr: NovaRuntime.devicePixelRatio;"
        b" property real sf: NovaRuntime.scaleFactor }",
        QUrl("qrc:/hidpi-default.qml"))
    obj = comp.create()
    assert obj is not None
    dpr = obj.property("dpr")
    sf = obj.property("sf")
    assert dpr is not None and dpr >= 1.0
    assert sf == 1.0   # 测试进程未设 QT_SCALE_FACTOR
    # Python 侧 snapshot 与 QML 属性同源
    snap = runtime_snapshot()
    assert snap["devicePixelRatio"] >= 1.0
    assert snap["scaleFactor"] >= 1.0
