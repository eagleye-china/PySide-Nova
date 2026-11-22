# tests/test_smoke.py
# 冒烟测试：全部组件 QML 解析+实例化、令牌可读、断点语义（1366px→md）、画廊完整加载
"""冒烟测试：验证 pyside-nova QML 模块可在引擎中正确解析并实例化。"""
import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent, QQmlEngine

from pyside_nova import init_nova

CASES = [
    # services：单例可解析、令牌可读取
    "import QtQuick\nimport Nova.Services\n"
    "QtObject { property color c: NovaTheme.primary }",
    "import QtQuick\nimport Nova.Services\n"
    "QtObject { property bool d: NovaTheme.isDark }",
    # controls：逐个实例化
    "import QtQuick\nimport Nova.Controls\nNovaBtn { text: 'hi' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtn { text: 'x'; variant: 'outlined'; loading: true; size: 'sm' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtn { icon: '+'; round: true; disable: true; tint: '#EF4444' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaCard { NovaCardSection { Text { text: 'a' } } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaCard { flat: true; NovaCardSection { } NovaCardActions { } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaChip { text: 'tag'; removable: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaChip { text: 'x'; filled: true; dense: true; tint: '#26A69A' }",
    "import QtQuick\nimport Nova.Controls\nNovaAvatar { text: 'N'; size: 40 }",
    "import QtQuick\nimport Nova.Controls\nNovaIcon { icon: 'mdi:home' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaIcon { icon: 'material:menu'; size: 32; color: '#EF4444'; monochrome: false }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtn { icon: 'mdi:home'; text: 'icon btn'; variant: 'outlined' }",
    "import QtQuick\nimport Nova.Controls\nNovaSeparator { width: 100 }",
    "import QtQuick\nimport Nova.Controls\nNovaSeparator { vertical: true; height: 100 }",
    "import QtQuick\nimport Nova.Controls\nNovaSpace { }",
    # NovaBadge：作为子项挂载（含红点模式与浮动模式）
    "import QtQuick\nimport Nova.Controls\n"
    "Item { width: 50; height: 50; NovaBadge { text: '5' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "Item { width: 50; height: 50; NovaBadge { } }",
    "import QtQuick\nimport Nova.Controls\n"
    "Item { width: 50; height: 50; NovaBadge { text: 'x'; floating: true } }",
    # behaviors：NovaRipple 子项挂载
    "import QtQuick\nimport Nova.Behaviors\n"
    "Rectangle { width: 100; height: 60; NovaRipple { } }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "Rectangle { width: 100; height: 60; NovaRipple { color: 'red'; duration: 300 } }",
    # 槽机制：默认槽（default property alias）子项挂载
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtn { text: 'x'; Rectangle { width: 4; height: 4 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaChip { text: 'x'; Rectangle { width: 4; height: 4 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaAvatar { text: 'A'; Rectangle { width: 4; height: 4 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaIcon { icon: 'mdi:home'; Rectangle { width: 4; height: 4 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "Item { width: 50; height: 50; NovaBadge { text: '1'; Rectangle { width: 4; height: 4 } } }",
    # services：NovaScreen 断点（1366px → md）
    "import QtQuick\nimport Nova.Services\n"
    "Item { id: it; width: 1366; height: 768;"
    " Component.onCompleted: NovaScreen.source = it }",
    # ── L1 布局系统（v0.5.0）：逐个实例化 ──
    "import QtQuick\nimport Nova.Controls\n"
    "NovaHeader { Rectangle { width: 10; height: 10 } }",
    "import QtQuick\nimport Nova.Controls\nNovaFooter { }",
    "import QtQuick\nimport Nova.Controls\nNovaPage { Text { text: 'p' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaDrawer { side: 'left'; mini: true; Rectangle { width: 10; height: 10 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaDrawer { side: 'right'; overlay: true; breakpoint: 500; bordered: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaRow { width: 400; height: 100; Rectangle { width: 50; height: 20 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaRow { width: 1200; height: 100; NovaCol { cols: 6 } NovaCol { cols: 4; offset: 2 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaVisible { above: 'md'; Rectangle { width: 10; height: 10 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaVisible { below: 'sm'; only: 'xs sm md' }",
    # 槽机制：布局五件套默认槽
    "import QtQuick\nimport Nova.Controls\n"
    "NovaLayout { width: 800; height: 600;"
    " NovaHeader { } NovaDrawer { } NovaFooter { } NovaPage { Text { text: 'x' } } }",
]


def test_screen_breakpoints(qml_engine):
    """1366px 应命中 md 断点（>=1024 且 <1440），lt/gt 语义对标 Quasar。"""
    code = ("import QtQuick\nimport Nova.Services\n"
            "Item { id: it; width: 1366; height: 768;"
            " Component.onCompleted: NovaScreen.source = it;"
            " property string bp: NovaScreen.name;"
            " property bool md: NovaScreen.isMd;"
            " property bool gtSm: NovaScreen.gtSm;"
            " property bool ltMd: NovaScreen.ltMd }")
    component = QQmlComponent(qml_engine)
    component.setData(code.encode("utf-8"), QUrl("qrc:/nova-screen.qml"))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    assert obj.property("bp") == "md"
    assert obj.property("md") is True
    assert obj.property("gtSm") is True
    assert obj.property("ltMd") is True


def _make(qml_engine, code, wait=0.0):
    """创建 QML 对象并挂到 app 防止引擎 GC 无父根对象；wait>0 时泵事件（宽度动画）。"""
    import time

    from PySide6.QtGui import QGuiApplication

    component = QQmlComponent(qml_engine)
    component.setData(code.encode("utf-8"), QUrl("qrc:/nova-l1.qml"))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    obj.setParent(QGuiApplication.instance())
    if wait > 0:
        end = time.time() + wait
        while time.time() < end:
            QGuiApplication.instance().processEvents()
            time.sleep(0.02)
    return obj


def test_layout_quadrants_and_push(qml_engine):
    """NovaLayout 四象限归位：header 顶部、footer 底部、drawer push 时页面区让位。"""
    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Controls\n"
                "NovaLayout { width: 1200; height: 600\n"
                " property real hy: headerItem ? headerItem.y : -1\n"
                " property real fy: footerItem ? footerItem.y : -1\n"
                " property real dw: drawerItem ? drawerItem.width : -1\n"
                " property real px: pageArea.x\n"
                " NovaHeader { } NovaDrawer { } NovaFooter { } NovaPage { } }")
    assert obj.property("hy") == 0
    assert obj.property("fy") == 600 - 48
    assert abs(obj.property("dw") - 280) < 0.1
    assert abs(obj.property("px") - 280) < 0.1


def test_layout_autocollapse(qml_engine):
    """宿主宽度 800 < 断点 1024：抽屉自动收起（宽 0），页面区不让位。"""
    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Controls\n"
                "NovaLayout { width: 800; height: 600\n"
                " property real dw: drawerItem ? drawerItem.width : -1\n"
                " property real px: pageArea.x\n"
                " NovaHeader { } NovaDrawer { } NovaFooter { } NovaPage { } }",
                wait=0.4)
    assert obj.property("dw") == 0
    assert obj.property("px") == 0


def test_grid_math(qml_engine):
    """12 栅格数学：cols=6 → 行宽一半；offset=2 → 推挤 2/12 行宽（含 spacing）。"""
    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Controls\n"
                "NovaRow { width: 1200; height: 100\n"
                " property real w1: children[0].width\n"
                " property real w2: children[1].width\n"
                " property real x2: children[1].x\n"
                " NovaCol { cols: 6 }\n"
                " NovaCol { cols: 4; offset: 2 } }")
    assert abs(obj.property("w1") - 600) < 0.5
    assert abs(obj.property("w2") - 400) < 0.5
    assert abs(obj.property("x2") - (600 + 12 + 200)) < 1.5


def test_nova_visible_semantics(qml_engine):
    """NovaVisible 三语义：1366px(md) 下 above:'md' 隐藏 / only:'md' 显示 / below:'sm' 隐藏。"""
    _make(qml_engine,
          "import QtQuick\nimport Nova.Services\n"
          "Item { width: 1366; height: 100;"
          " Component.onCompleted: NovaScreen.source = this }")
    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Controls\n"
                "Item {\n"
                " property bool va: children[0].visible\n"
                " property bool vb: children[1].visible\n"
                " property bool vc: children[2].visible\n"
                " NovaVisible { above: 'md' }\n"
                " NovaVisible { only: 'md' }\n"
                " NovaVisible { below: 'sm' } }")
    assert obj.property("va") is False
    assert obj.property("vb") is True
    assert obj.property("vc") is False


@pytest.fixture(scope="module")
def qml_engine():
    app = QGuiApplication.instance() or QGuiApplication([])
    assert app is not None
    engine = QQmlEngine()
    init_nova(engine)
    yield engine
    del engine


def test_theme_dark_plugin_api(qml_engine):
    """Dark 插件 API：isDark / setDark / toggleDark / dark 品牌色（对标 $q.dark.*）。"""
    code = ("import QtQuick\nimport Nova.Services\n"
            "QtObject { property bool a: NovaTheme.isDark;"
            " property color dk: NovaTheme.dark;"
            " property bool after: { NovaTheme.setDark(true); NovaTheme.toggleDark();"
            " NovaTheme.isDark } }")
    component = QQmlComponent(qml_engine)
    component.setData(code.encode("utf-8"), QUrl("qrc:/nova-dark-api.qml"))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    assert obj.property("a") is False
    assert obj.property("dk").isValid()
    # setDark(true) → toggleDark() → False（状态翻转正确）
    assert obj.property("after") is False
    obj.deleteLater()


def test_demo_loads(qml_engine):
    """精简演示 examples/demo/main.qml 必须完整加载。"""
    from pathlib import Path

    demo = Path(__file__).resolve().parents[1] / "examples" / "demo" / "main.qml"
    component = QQmlComponent(qml_engine)
    component.loadUrl(QUrl.fromLocalFile(str(demo)))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    obj.deleteLater()


def test_gallery_loads(qml_engine):
    """组件画廊 examples/gallery/main.qml 必须完整加载。"""
    from pathlib import Path

    gallery = Path(__file__).resolve().parents[1] / "examples" / "gallery" / "main.qml"
    component = QQmlComponent(qml_engine)
    component.loadUrl(QUrl.fromLocalFile(str(gallery)))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    obj.deleteLater()


@pytest.mark.parametrize("code", CASES)
def test_component_instantiates(qml_engine, code):
    component = QQmlComponent(qml_engine)
    component.setData(code.encode("utf-8"), QUrl("qrc:/nova-smoke.qml"))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    obj.deleteLater()


def test_theme_tokens(qml_engine):
    component = QQmlComponent(qml_engine)
    component.setData(
        b"import QtQuick\nimport Nova.Services\n"
        b"QtObject { property color c: NovaTheme.surface;"
        b" property color s: NovaTheme.shadowColor(2) }",
        QUrl("qrc:/nova-theme.qml"),
    )
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    assert obj.property("c").isValid()
    assert obj.property("s").isValid()
