# tests/test_v2_compat.py
# v2.0 双轨兼容契约测试（法源 docs/prescript/SPEC_V2_COMPAT.md §4 / §7）
"""守护 M1 就绪态：旧 URI 零破坏 + 产品树零物理兼容视图。

CSA 2026-11-26 10:44 指令「Controls 下新建的 Foundation 去掉」：M1 回退为
就绪态，不再落地任何 pilot 兼容转发视图。本测试保留「旧 URI 逐字可用」的
真实实例化回归，并把「0 视图 / 5 qmldir / 生成器无死代码」固化为机检。

复用 conftest 的会话级单引擎（多引擎在 Qt 6.12 下间歇 SIGSEGV，坑位 49）。
冻结面导出集合 ⊆ 146 类型由 scripts/audit_v2_compat.py 静态守护。
"""
from __future__ import annotations

import os
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import json
from pathlib import Path

import pytest
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication, QWindow
from PySide6.QtQml import QQmlComponent

from conftest import close_alive

ROOT = Path(__file__).resolve().parent.parent
QML = ROOT / "src" / "pyside_nova" / "qml" / "Nova"
GEN = ROOT / "scripts" / "gen_apidocs.py"
MARK = "@nova-compat-view"
LAYERS = ["Controls", "Behaviors", "Services", "Design", "Composite/LayoutShell"]

# 旧 URI 实例化样本 12 类型（取自 Controls 概念域台账
# GUIDE_COMPONENT_DOMAINS.md / api/component-domains-1.7.0.json；
# 概念域分类保留在文档层，物理子目录已依 CSA 10:44 指令撤销，此处无任何物理目录依赖）
SAMPLE_TYPES = [
    "NovaAvatar", "NovaBadge", "NovaChip", "NovaIcon", "NovaImg",
    "NovaSeparator", "NovaSkeleton", "NovaSpace", "NovaSpinner",
    "NovaText", "NovaBar", "NovaTransition",
]

_HELD: list = []


@pytest.fixture(scope="module", autouse=True)
def _teardown():
    yield
    _HELD.clear()
    close_alive()


@pytest.fixture(scope="module")
def engine(qml_engine):
    return qml_engine


def _create(engine, qml: str):
    """稳定创建模式（沿用 test_layout_shells._create）：强引用组件 + 对象挂到应用。"""
    comp = QQmlComponent(engine)
    comp.setData(qml.encode("utf-8"), QUrl("qrc:/nova-v2.qml"))
    if comp.isError():
        pytest.fail(" | ".join(e.toString() for e in comp.errors()))
    obj = comp.create()
    assert obj is not None, "create() 返回 None：" + " | ".join(
        e.toString() for e in comp.errors())
    _HELD.append(comp)
    _HELD.append(obj)
    if not isinstance(obj, QWindow):
        obj.setParent(QGuiApplication.instance())
    return obj


@pytest.mark.parametrize("name", SAMPLE_TYPES)
def test_old_uri_unchanged(engine, name):
    """C1：旧 Nova.Controls URI 逐字不变、12 类型仍可实例化（兼容基线回归）。"""
    obj = _create(engine, f"import QtQuick\nimport Nova.Controls 1.0\n{name} {{ }}")
    assert obj is not None


def test_zero_physical_compat_views():
    """C2：M1 就绪态硬约束 —— 产品树不得存在任何 @nova-compat-view 物理视图。"""
    views = [p for p in QML.glob("**/qmldir") if MARK in p.read_text(encoding="utf-8")]
    assert views == [], f"就绪态应为 0 视图，实得 {[p.name for p in views]}"


def test_exactly_five_qmldir_modules():
    """C3：全库 qmldir 恰 5 个冻结面模块，无第 6 个独立子模块。"""
    qmldirs = sorted(QML.glob("**/qmldir"))
    assert len(qmldirs) == 5, [p.relative_to(QML).as_posix() for p in qmldirs]
    ledger = json.loads((ROOT / "api" / "nova-api-1.7.0.json").read_text(encoding="utf-8"))
    mods = set()
    for p in qmldirs:
        for line in p.read_text(encoding="utf-8").splitlines():
            if line.strip().startswith("module "):
                mods.add(line.strip().split(None, 1)[1])
    assert mods == set(ledger["counts"]["modules"])


def test_generator_has_no_view_dead_code():
    """C5：gen_apidocs.py 不得残留 @nova-compat-view 跳过死代码（视图已撤）。"""
    assert MARK not in GEN.read_text(encoding="utf-8")
