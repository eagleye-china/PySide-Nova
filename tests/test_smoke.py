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
