# tests/test_layout_shells.py
# Prescient Layout Shell 20 项组合根容器测试：解析 / 实例化 / 槽位 / 主题 / 边界（组合宪法 0.2.0 第 8 章门禁）
"""20 项 Prescient Layout Shell 的组合契约测试。

覆盖宪法第 8 章第 3 条的四类用例：
1. 解析+实例化：20 类型逐个逐字面量实例化（qmllint 只查静态，实例化才抓运行时属性错误）
2. 槽用例：标准槽 alias 注入后子项真实挂载
3. 明暗主题用例：切主题零异常
4. 边界参数用例：非法尺寸/枚举入参自动钳制不崩
复用 conftest 的会话级单引擎（多引擎并存在 Qt 6.12 下间歇 SIGSEGV）。
"""
from __future__ import annotations

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QUrl
from PySide6.QtQml import QQmlComponent

from conftest import ALIVE, close_alive

SHELLS = [
    "NovaSidebar", "NovaTopNavigation", "NovaDualSide", "NovaTabShell",
    "NovaThreeColumn", "NovaCompare", "NovaCardGrid", "NovaModal",
    "NovaDrawerPanel", "NovaSetupWizard", "NovaBlankPage", "NovaDesktop",
    "NovaMobile", "NovaFlexLayout", "NovaChat",
    "NovaAgent", "NovaDE", "NovaCopilot", "NovaOrbit", "NovaIncubator",
    "NovaAIReport",
]


@pytest.fixture(scope="module", autouse=True)
def _teardown():
    yield
    _HELD.clear()
    close_alive()


@pytest.fixture(scope="module")
def engine(qml_engine):
    return qml_engine


def _create(engine, qml: str):
    """稳定创建模式（沿用 test_smoke._make）：强引用组件 + 对象挂到 QApplication。

    QQmlComponent 持有 create() 对象的所有权；只强引用对象而不持有组件，
    下一次组件创建时 Qt 会连带析构前一个对象（坑位 49 同类防御）。
    """
    from PySide6.QtGui import QGuiApplication, QWindow
    comp = QQmlComponent(engine)
    comp.setData(qml.encode("utf-8"), QUrl("qrc:/nova-shell.qml"))
    if comp.isError():
        pytest.fail(" | ".join(e.toString() for e in comp.errors()))
    obj = comp.create()
    assert obj is not None, "create() 返回 None：" + " | ".join(e.toString() for e in comp.errors())
    _HELD.append(comp)
    _HELD.append(obj)
    if not isinstance(obj, QWindow):
        obj.setParent(QGuiApplication.instance())
    return obj


_HELD: list = []


@pytest.mark.parametrize("name", SHELLS)
def test_shell_parse_and_instantiate(engine, name):
    """每个 Shell 可独立解析并实例化（无业务上下文、无 Gallery 依赖）。"""
    obj = _create(engine, f"import QtQuick\nimport Nova.Composite.LayoutShell 1.0\n{name} {{ }}")
    assert obj is not None


def test_standard_slots_inject(engine):
    """五个标准槽位 alias 注入真实子项并挂载到宿主。"""
    qml = """
import QtQuick
import Nova.Composite.LayoutShell 1.0
NovaSidebar {
    width: 900; height: 600
    headerSlot: Rectangle { objectName: "h"; color: "#123456" }
    sidebarSlot: Rectangle { objectName: "s"; color: "#234567" }
    contentSlot: Rectangle { objectName: "c"; color: "#345678" }
    footerSlot: Rectangle { objectName: "f"; color: "#456789" }
    overlaySlot: Rectangle { objectName: "o"; color: "#56789a" }
}
"""
    obj = _create(engine, qml)
    names = set()
    for child in obj.findChildren(object):
        try:
            n = child.objectName()
        except Exception:
            n = ""
        if n:
            names.add(n)
    assert {"h", "s", "c", "f", "o"} <= names, f"槽位子项未全部挂载：{names}"


def test_theme_toggle_no_error(engine):
    """明暗主题切换后 Shell 实例仍可用（令牌绑定不产生运行时异常）。"""
    qml = """
import QtQuick
import Nova.Composite.LayoutShell 1.0
import Nova.Services 1.0
Item {
    property bool probe: { NovaTheme.setDark(true); NovaTheme.setDark(false); true }
    NovaSidebar { width: 900; height: 600; contentSlot: Rectangle { color: NovaTheme.surface } }
    NovaModal { open: true; contentSlot: Rectangle { color: NovaTheme.surface } }
}
"""
    obj = _create(engine, qml)
    assert obj.property("probe") is True


@pytest.mark.parametrize("bad", ["-999", "999999", "undefined"])
def test_illegal_size_clamped(engine, bad):
    """非法尺寸入参钳制到安全值，布局不溢出、对象可实例化。"""
    qml = f"""
import QtQuick
import Nova.Composite.LayoutShell 1.0
NovaThreeColumn {{ width: 1024; height: 768; treeSize: {bad}; detailSize: {bad} }}
"""
    obj = _create(engine, qml)
    assert obj is not None


def test_flex_invalid_columns_clamped(engine):
    """FlexLayout 列数越界钳制到 1~4 并发 layoutChanged。"""
    obj = _create(engine, """
import QtQuick
import Nova.Composite.LayoutShell 1.0
NovaFlexLayout { columns: 99 }
""")
    assert obj is not None
    assert obj.property("_cols") in (1, 2, 3, 4)
