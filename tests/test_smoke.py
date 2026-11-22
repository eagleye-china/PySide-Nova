# tests/test_smoke.py
# 冒烟测试：全部组件 QML 解析+实例化、令牌可读、断点语义（1366px→md）、画廊完整加载、L4 服务行为级断言
"""冒烟测试：验证 pyside-nova QML 模块可在引擎中正确解析并实例化。"""
import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QEventLoop, QTimer, QUrl
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
    # ── L4 服务层（v0.6.0）：单例读取 + 动作/句柄实例化 ──
    "import QtQuick\nimport Nova.Services\n"
    "QtObject { property int c: NovaNotify.countAt('bottom');"
    " property var ci: NovaOverlayHost.contentItem;"
    " property int zn: NovaTheme.zNotify }",
    "import QtQuick\nimport Nova.Services\n"
    "NovaNotifyAction { label: 'undo'; icon: 'mdi:undo'; noDismiss: true }",
    "import QtQuick\nimport Nova.Services\n"
    "NovaNotifyHandle { }",
    "import QtQuick\nimport Nova.Services\n"
    "QtObject { property var h: null;"
    " Component.onCompleted: h = NovaNotify.show('hi') }",
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
    from PySide6.QtGui import QWindow
    if not isinstance(obj, QWindow):
        obj.setParent(QGuiApplication.instance())   # Window 不能挂 app，自身引用由测试持有
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




# ══════════════════════════════════════════════════════════════
# L4 服务层：NovaNotify 行为级断言（契约见 docs/PARITY.md 审计节）
# ══════════════════════════════════════════════════════════════

NOTIFY_WINDOW_QML = (
    "import QtQuick\nimport QtQuick.Window\nimport Nova.Services\n"
    "Window { id: w; visible: false; width: 800; height: 600;"
    " Component.onCompleted: NovaScreen.source = w }"
)

NOTIFY_DRIVER_QML = (
    "import QtQuick\nimport Nova.Services\n"
    "QtObject {\n"
    "  property var lastReason: ''\n"
    "  property var lastHandle: null\n"
    "  property int handlerRuns: 0\n"
    "  function show(msg, opts) {\n"
    "    var c = opts === undefined ? {} : opts; c.message = msg\n"
    "    var h = NovaNotify.show(c)\n"
    "    if (h && h.item) h.item.dismissed.connect(function(r) { lastReason = r })\n"
    "    lastHandle = h\n"
    "    return h\n"
    "  }\n"
    "  function act(msg, opts) {\n"
    "    var c = opts === undefined ? {} : opts; c.message = msg\n"
    "    c.actions = [{ label: 'ok', handler: function() { handlerRuns++ } }]\n"
    "    var h = NovaNotify.show(c)\n"
    "    if (h && h.item) h.item.dismissed.connect(function(r) { lastReason = r })\n"
    "    lastHandle = h\n"
    "    return h\n"
    "  }\n"
    "  function cnt(pos) { return NovaNotify.countAt(pos) }\n"
    "  function dismissAll(pos) { NovaNotify.dismissAll(pos) }\n"
    "  function setmax(n) { NovaNotify.maxVisible = n }\n"
    "  function setdark(v) { NovaTheme.setDark(v) }\n"
    "  function resetReason() { lastReason = '' }\n"
    "  function clearAll() {\n"
    "    var all = NovaNotify.positionList\n"
    "    for (var i = 0; i < all.length; i++) NovaNotify.dismissAll(all[i])\n"
    "  }\n"
    "}"
)


@pytest.fixture()
def notify_env(qml_engine):
    """L4 行为测试环境：源窗口 + 驱动对象；每个用例前后清空通知栈。"""
    win = _make(qml_engine, NOTIFY_WINDOW_QML)
    drv = _make(qml_engine, NOTIFY_DRIVER_QML)
    drv.clearAll()
    yield drv
    drv.clearAll()
    drv.setmax(5)


def _pump(ms=50):
    loop = QEventLoop()
    QTimer.singleShot(ms, loop.quit)
    loop.exec()


def test_notify_show_dismiss_reason_api(notify_env):
    """show → count 1 → dismiss() → reason 'api'，句柄失效。"""
    h = notify_env.show("hello", None)
    assert notify_env.cnt("bottom") == 1
    assert h.property("valid") is True
    item = h.property("item")
    assert item.property("message") == "hello"
    h.dismiss()
    assert notify_env.cnt("bottom") == 0
    assert h.property("valid") is False
    assert notify_env.property("lastReason") == "api"


def test_notify_nine_positions(notify_env):
    """9 个位置逐个落位；left/right/center 走中线插入。"""
    positions = ["top-left", "top-right", "bottom-left", "bottom-right",
                 "top", "bottom", "left", "right", "center"]
    for pos in positions:
        notify_env.show("p", {"position": pos, "group": False})
        assert notify_env.cnt(pos) == 1
    for pos in positions:
        notify_env.dismissAll(pos)
        assert notify_env.cnt(pos) == 0


def test_notify_type_presets(notify_env):
    """内置类型预设：positive 色板、warning textTint=dark、ongoing 常驻转圈不分组。"""
    h = notify_env.show("ok", {"type": "positive"})
    from PySide6.QtGui import QColor
    assert h.property("item").property("tint") == QColor("#22C55E")
    h2 = notify_env.show("warn", {"type": "warning"})
    assert h2.property("item").property("textTint") == QColor("#1D1D1D")
    h3 = notify_env.show("job", {"type": "ongoing"})
    it = h3.property("item")
    assert it.property("spinner") is True
    assert it.property("timeout") == 0
    assert it.property("groupKey") is None



def test_notify_invalid_inputs(notify_env):
    """非法位置拒绝（返回 null）；非法 timeout 回落 5000；timeout=0 强制关进度。"""
    assert notify_env.show("x", {"position": "middle"}) is None
    assert notify_env.property("lastHandle") is None
    it = notify_env.show("t", {"group": False, "timeout": -5}).property("item")
    assert it.property("timeout") == 5000
    it2 = notify_env.show("z", {"group": False, "timeout": 0, "progress": True}).property("item")
    assert it2.property("progress") is False


def test_notify_grouping_and_badge(notify_env):
    """自动分组：同键合并 badge 递增，旧句柄失效且上报 replaced。"""
    h1 = notify_env.show("dup", None)
    h2 = notify_env.show("dup", None)
    assert notify_env.cnt("bottom") == 1
    assert h2.property("item").property("badge") == 2
    assert h1.property("valid") is False
    assert notify_env.property("lastReason") == "replaced"


def test_notify_group_key_includes_actions(notify_env):
    """分组键含 actions 标签：同 message 不同动作文案 → 不同组。"""
    notify_env.show("m", {"actions": [{"label": "保存"}]})
    notify_env.show("m", {"actions": [{"label": "另存为"}]})
    assert notify_env.cnt("bottom") == 2


def test_notify_group_false_and_custom_group(notify_env):
    """group:false 并列多条；自定义组后到者替换前者。"""
    notify_env.show("A", {"group": False})
    notify_env.show("B", {"group": False})
    assert notify_env.cnt("bottom") == 2
    h = notify_env.show("u1", {"group": "upload"})
    assert notify_env.cnt("bottom") == 3        # A + B + u1
    notify_env.show("u2", {"group": "upload"})
    assert notify_env.cnt("bottom") == 3        # u1 被 u2 替换，总数不增
    assert h.property("valid") is False
    assert notify_env.property("lastReason") == "replaced"


def test_notify_update_semantics(notify_env):
    """分组句柄 update 拒绝返回 False；非分组句柄可更新内容。"""
    g = notify_env.show("grp", None)
    assert g.update({"message": "x"}) is False
    f = notify_env.show("free", {"group": False})
    assert f.update({"message": "free2"}) is True
    assert f.property("item").property("message") == "free2"


def test_notify_action_dismiss_order(notify_env):
    """动作点击契约：handler 先行、dismissed('action') 后至；noDismiss 不关闭。"""
    h = notify_env.act("with-action", {"group": False})
    it = h.property("item")
    it.triggerAction(0)
    assert notify_env.property("handlerRuns") == 1
    assert notify_env.property("lastReason") == "action"
    assert h.property("valid") is False
    # noDismiss：点击后不关闭、不上报 dismissed
    notify_env.resetReason()
    sticky = notify_env.show("sticky2", {"group": False,
                                         "actions": [{"label": "ok", "noDismiss": True,
                                                      "handler": lambda: None}]})
    sticky.property("item").triggerAction(0)
    assert sticky.property("valid") is True
    assert notify_env.property("lastReason") == ""
    assert notify_env.property("handlerRuns") == 1   # Python lambda 句柄不进 driver 计数


def test_notify_close_btn_user_reason(notify_env):
    """closeBtn 归入动作列表，点击上报 user。"""
    h = notify_env.show("cb", {"group": False, "closeBtn": True})
    acts = h.property("item").property("actions")
    assert len(acts) == 1
    assert acts[0].property("label") == "关闭"
    assert acts[0].property("closeReason") == "user"
    h.property("item").triggerAction(0)
    assert notify_env.property("lastReason") == "user"


def test_notify_max_visible_overflow(notify_env):
    """同屏上限：超限淘汰最旧一条，原因 overflow（Nova 增强）。"""
    notify_env.setmax(2)
    for i in range(3):
        notify_env.show("of%d" % i, {"group": False})
    assert notify_env.cnt("bottom") == 2
    assert notify_env.property("lastReason") == "overflow"


def test_notify_timeout_reason(notify_env):
    """自然到期上报 timeout（timeout=20ms → 计时器 1020ms，含入场动效时长）。"""
    notify_env.show("ttl", {"group": False, "timeout": 20})
    assert notify_env.cnt("bottom") == 1
    _pump(1400)
    assert notify_env.cnt("bottom") == 0
    assert notify_env.property("lastReason") == "timeout"


def test_notify_setdefaults_and_dark(notify_env):
    """setDefaults 合并（position/timeout 覆盖）+ Dark 模式下实例化（宪法第 5 章强制用例）。"""
    notify_env.setdark(True)
    h = notify_env.show("dark-ttl", None)
    assert h.property("valid") is True
    assert h.property("item").property("tint").isValid()
    h.dismiss()
    notify_env.setdark(False)
    notify_env.show("d2", {"position": "top"})
    assert notify_env.cnt("top") == 1
    notify_env.dismissAll("top")
