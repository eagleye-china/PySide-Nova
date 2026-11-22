# tests/test_smoke.py
# 冒烟测试：全部组件 QML 解析+实例化、令牌可读、断点语义（1366px→md）、画廊完整加载、L4 服务行为级断言
"""冒烟测试：验证 pyside-nova QML 模块可在引擎中正确解析并实例化。"""
import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QEventLoop, QPoint, QTimer, QUrl, Qt
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent, QQmlEngine
from PySide6.QtTest import QTest

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
    # ── L3 行为层（v0.7.0）：九个指令行为 + 共享观察池 ──
    "import QtQuick\nimport Nova.Behaviors\nNovaIntersection { }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "NovaIntersection { threshold: [0, 0.5, 1]; once: true }",
    "import QtQuick\nimport Nova.Behaviors\nNovaScrollObserver { }",
    "import QtQuick\nimport Nova.Behaviors\nNovaScrollFire { threshold: 0.5 }",
    "import QtQuick\nimport Nova.Behaviors\nNovaClosePopup { depth: -1 }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "NovaTouchPan { horizontal: true; directions: ['left', 'right'] }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "NovaTouchSwipe { directions: ['up']; minVelocity: 0.08 }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "NovaTouchHold { duration: 500; touchSensitivity: 4 }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "NovaTouchRepeat { delays: '0:400'; keyRepeat: true }",
    "import QtQuick\nimport Nova.Services\n"
    "QtObject { property int n: NovaIntersectionPool.count;"
    " property int p: NovaIntersectionPool.pollInterval }",
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


_ALIVE = []   # 测试期强引用池：QWindow 无 parent，组件对象一销毁就会被连带 delete


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
    _ALIVE.append(obj)                              # 全类型强引用（Window 也不例外）
    if not isinstance(obj, QWindow):
        obj.setParent(QGuiApplication.instance())   # 非 Window 再挂到 app
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


# ════════════════════════════════════════════════════════════
# L4 服务层：NovaDialog（27 项配置对账 · 关闭原因上报 · 句柄）
# ════════════════════════════════════════════════════════════

DIALOG_DRIVER_QML = (
    "import QtQuick\nimport Nova.Services\n"
    "QtObject {\n"
    "  property string lastReason: ''\n"
    "  property int okRuns: 0\n"
    "  property int cancelRuns: 0\n"
    "  property int cbHits: 0\n"
    "  property var lastHandle: null\n"
    "  function open(opts) {\n"
    "    var h = NovaDialog.show(opts)\n"
    "    if (h) {\n"
    "      h.dismissed.connect(function(r) { lastReason = r })\n"
    "      h.accepted.connect(function() { okRuns++ })\n"
    "      h.rejected.connect(function() { cancelRuns++ })\n"
    "    }\n"
    "    lastHandle = h\n"
    "    return h\n"
    "  }\n"
    "  function openCb() {\n"
    "    return NovaDialog.show({\n"
    "      title: 'cb',\n"
    "      onOk: function() { cbHits += 10 },\n"
    "      onCancel: function() { cbHits += 1 },\n"
    "      onDismiss: function(r) { cbHits += 100 }\n"
    "    })\n"
    "  }\n"
    "  function cnt() { return NovaDialog.count() }\n"
    "  function hideAll(r) { NovaDialog.hideAll(r) }\n"
    "  function setdefaults(o) { NovaDialog.setDefaults(o) }\n"
    "  function clearDefaults() { NovaDialog._defaults = ({}) }\n"
    "  function setdark(v) { NovaTheme.setDark(v) }\n"
    "  function resetReason() { lastReason = '' }\n"
    "}"
)


@pytest.fixture()
def dialog_env(qml_engine):
    """L4 对话框测试环境：源窗口 + 驱动对象；用例前后关闭全部对话框并清空默认值。"""
    win = _make(qml_engine, NOTIFY_WINDOW_QML)
    drv = _make(qml_engine, DIALOG_DRIVER_QML)
    drv.hideAll("api")
    drv.clearDefaults()
    yield drv
    drv.hideAll("api")
    drv.clearDefaults()
    drv.setdark(False)
    _pump(250)


def test_dialog_show_and_ok_reason(dialog_env):
    """show → count 1 → ok() → accepted + dismissed('ok') → 句柄失效。"""
    h = dialog_env.open({"title": "继续?", "message": "确认继续操作"})
    assert dialog_env.cnt() == 1
    assert h.property("valid") is True
    item = h.property("item")
    assert item.property("title") == "继续?"
    assert item.property("message") == "确认继续操作"
    assert item.property("position") == "standard"
    assert item.property("focusTarget") == "ok"
    h.ok()
    assert dialog_env.property("lastReason") == "ok"
    assert dialog_env.property("okRuns") == 1
    assert h.property("valid") is False
    assert dialog_env.cnt() == 0


def test_dialog_cancel_reason(dialog_env):
    """cancel() → rejected + dismissed('cancel')；API 关闭走 'api'。"""
    h = dialog_env.open({"title": "x"})
    h.cancel()
    assert dialog_env.property("lastReason") == "cancel"
    assert dialog_env.property("cancelRuns") == 1
    h2 = dialog_env.open({"title": "y"})
    h2.hide()
    assert dialog_env.property("lastReason") == "api"
    assert h2.property("valid") is False


def test_dialog_persistent_blocks_backdrop_and_escape(dialog_env):
    """persistent 同时锁 backdrop 与 ESC；api 仍可关闭（程序化兜底）。"""
    h = dialog_env.open({"title": "p", "persistent": True})
    item = h.property("item")
    item.requestDismiss("backdrop")
    item.requestDismiss("escape")
    assert h.property("valid") is True
    assert dialog_env.cnt() == 1
    item.requestDismiss("api")
    assert h.property("valid") is False
    assert dialog_env.property("lastReason") == "api"


def test_dialog_no_backdrop_and_esc_flags(dialog_env):
    """noBackdropDismiss 只锁外点；noEscDismiss 只锁 ESC——两者互不串味。"""
    h = dialog_env.open({"title": "a", "noBackdropDismiss": True})
    item = h.property("item")
    item.requestDismiss("backdrop")
    assert h.property("valid") is True
    item.requestDismiss("escape")
    assert h.property("valid") is False
    assert dialog_env.property("lastReason") == "escape"
    h2 = dialog_env.open({"title": "b", "noEscDismiss": True})
    it2 = h2.property("item")
    it2.requestDismiss("escape")
    assert h2.property("valid") is True
    it2.requestDismiss("backdrop")
    assert h2.property("valid") is False
    assert dialog_env.property("lastReason") == "backdrop"


def test_dialog_setdefaults_and_update(dialog_env):
    """setDefaults 深合并（title 默认 + 逐项覆盖）；句柄 update 白名单生效。"""
    dialog_env.setdefaults({"title": "默认标题", "ok": "确定"})
    h = dialog_env.open({})
    item = h.property("item")
    assert item.property("title") == "默认标题"
    assert item.property("okConfig").toVariant()["label"] == "确定"
    h2 = dialog_env.open({"title": "覆盖"})
    assert h2.property("item").property("title") == "覆盖"
    assert h2.update({"title": "改后", "message": "新正文"}) is True
    assert h2.property("item").property("title") == "改后"
    assert h2.property("item").property("message") == "新正文"
    h2.hide()
    assert h2.update({"title": "失效"}) is False


def test_dialog_positions_and_invalid(dialog_env):
    """五向定位全部接受；非法位置拒绝（返回 null，不静默回落）。"""
    for pos in ["standard", "top", "right", "bottom", "left"]:
        h = dialog_env.open({"title": pos, "position": pos})
        assert h is not None
        assert h.property("item").property("position") == pos
        h.hide()
    assert dialog_env.open({"position": "middle"}) is None
    assert dialog_env.property("lastHandle") is None


def test_dialog_seamless_progress_dark(dialog_env):
    """seamless 无遮罩；progress 转进度态；Dark 模式实例化（宪法第 5 章）。"""
    h = dialog_env.open({"title": "s", "seamless": True})
    item = h.property("item")
    assert item.property("hasBackdrop") is False
    h.hide()
    h2 = dialog_env.open({"title": "p", "progress": {"message": "处理中"}})
    it2 = h2.property("item")
    assert it2.property("progress") is True
    assert it2.property("progressMessage") == "处理中"
    h2.hide()
    dialog_env.setdark(True)
    h3 = dialog_env.open({"title": "dark"})
    assert h3.property("item").property("cardTint").isValid()
    h3.hide()


def test_dialog_callbacks_and_hideall(dialog_env):
    """基线链式回调 onOk/onCancel/onDismiss 全部触发；hideAll 批量关闭。"""
    h = dialog_env.openCb()
    h.ok()
    # onOk(10) + onDismiss(100)
    assert dialog_env.property("cbHits") == 110
    h2 = dialog_env.openCb()
    h2.cancel()
    assert dialog_env.property("cbHits") == 211     # +1 +100
    dialog_env.open({"title": "a"})
    dialog_env.open({"title": "b"})
    assert dialog_env.cnt() == 2
    dialog_env.hideAll("api")
    assert dialog_env.cnt() == 0


# ══════════════════════════════════════════════════════════════
# L4 服务层：NovaLoading（11 项对账 · 引用计数 · 局部/全屏 · 超时）
# ══════════════════════════════════════════════════════════════

LOADING_DRIVER_QML = (
    "import QtQuick\nimport Nova.Services\n"
    "QtObject {\n"
    "  property var lastHandle: null\n"
    "  function open(opts) { var h = NovaLoading.show(opts); lastHandle = h; return h }\n"
    "  function cnt(g) { return NovaLoading.count(g) }\n"
    "  function active(g) { return NovaLoading.isActive(g) }\n"
    "  function groups() { return NovaLoading.activeGroups() }\n"
    "  function activeCount() { return NovaLoading.activeCount() }\n"
    "  function inc(opts) { return NovaLoading.increment(opts) }\n"
    "  function dec(g) { return NovaLoading.decrement(g) }\n"
    "  function forceHide(g) { return NovaLoading.hide(g) }\n"
    "  function hideAll() { NovaLoading.hideAll() }\n"
    "  function setDefaults(o) { NovaLoading.setDefaults(o) }\n"
    "  function clearDefaults() { NovaLoading._defaults = ({}) }\n"
    "  function setdark(v) { NovaTheme.setDark(v) }\n"
    "}"
)


@pytest.fixture()
def loading_env(qml_engine):
    """L4 加载服务测试环境：源窗口 + 驱动对象；用例前后强杀全部加载组。"""
    _make(qml_engine, NOTIFY_WINDOW_QML)
    drv = _make(qml_engine, LOADING_DRIVER_QML)
    drv.hideAll()
    drv.clearDefaults()
    yield drv
    drv.hideAll()
    drv.clearDefaults()
    drv.setdark(False)


def test_loading_show_hide(loading_env):
    """show 建组并渲染 message；句柄 hide 归零即释放，句柄失效。"""
    h = loading_env.open({"delay": 0, "message": "加载中"})
    assert loading_env.cnt("__default_quasar_group__") == 1
    item = h.property("item")
    assert item.property("message") == "加载中"
    assert item.property("started") is True
    assert h.property("valid") is True
    h.hide()
    assert loading_env.cnt("__default_quasar_group__") == 0
    assert h.property("valid") is False


def test_loading_concurrent_refcount(loading_env):
    """引用计数：同组两次 show → 2；释放一份仍显示，归零才收口（并发不互踩）。"""
    h1 = loading_env.open({"delay": 0, "group": "job"})
    h2 = loading_env.open({"delay": 0, "group": "job"})
    assert loading_env.cnt("job") == 2
    assert h1.property("count") == 2
    assert h1.property("item") == h2.property("item")      # 复用同一视觉层

    h1.hide()
    assert loading_env.cnt("job") == 1
    assert loading_env.active("job") is True
    assert h2.property("valid") is True
    assert h2.property("item").property("refCount") == 1

    h2.hide()
    assert loading_env.cnt("job") == 0
    assert loading_env.active("job") is False


def test_loading_groups_isolated(loading_env):
    """不同组互不影响：hide(g1) 不动 g2；activeGroups 如实反映。"""
    h1 = loading_env.open({"delay": 0, "group": "g1"})
    h2 = loading_env.open({"delay": 0, "group": "g2"})
    assert loading_env.activeCount() == 2
    assert sorted(_v(loading_env.groups())) == ["g1", "g2"]
    loading_env.forceHide("g1")
    assert loading_env.active("g1") is False
    assert loading_env.active("g2") is True
    assert h1.property("valid") is False
    h2.hide()


def test_loading_force_hide_ignores_count(loading_env):
    """hide(group) 对标基线语义：无视引用计数整组立即关闭。"""
    h1 = loading_env.open({"delay": 0, "group": "f"})
    h2 = loading_env.open({"delay": 0, "group": "f"})
    assert loading_env.cnt("f") == 2
    loading_env.forceHide("f")
    assert loading_env.cnt("f") == 0
    assert h1.property("valid") is False
    assert h2.property("valid") is False


def test_loading_delay_defers_show(loading_env):
    """delay 内不显示（防闪烁）；到点后才 started。"""
    h = loading_env.open({"delay": 250})
    item = h.property("item")
    assert item.property("started") is False
    _pump(420)
    assert item.property("started") is True
    h.hide()


def test_loading_delay_then_hide_never_shows(loading_env):
    """delay 窗口内 hide：从未显示即销毁，不留残余组。"""
    h = loading_env.open({"delay": 400})
    h.hide()
    assert loading_env.cnt("__default_quasar_group__") == 0
    assert h.property("valid") is False
    _pump(500)
    assert loading_env.activeCount() == 0


def test_loading_config_mapping(loading_env):
    """配置映射：message / spinnerSize / spinnerModel / 配色 / boxed；非法 spinnerModel 回落 ring。"""
    from PySide6.QtGui import QColor

    h = loading_env.open({"delay": 0, "message": "m", "spinnerSize": 64,
                          "spinnerModel": "dots", "spinnerTint": "#EF4444",
                          "backgroundTint": "#223344", "boxed": True})
    it = h.property("item")
    assert it.property("spinnerSize") == 64
    assert it.property("spinnerModel") == "dots"
    assert it.property("boxed") is True
    assert it.property("spinnerTint") == QColor("#EF4444")
    assert it.property("backgroundTint") == QColor("#223344")
    h.hide()

    bad = loading_env.open({"delay": 0, "spinnerModel": "bogus"})
    assert bad.property("item").property("spinnerModel") == "ring"
    bad.hide()


def test_loading_setdefaults_and_dark(loading_env):
    """setDefaults 深合并生效；Dark 模式实例化无异常（宪法第 5 章强制用例）。"""
    loading_env.setDefaults({"spinnerSize": 72, "message": "默认文案"})
    h = loading_env.open({"delay": 0})
    it = h.property("item")
    assert it.property("spinnerSize") == 72
    assert it.property("message") == "默认文案"
    h.hide()

    loading_env.setdark(True)
    h2 = loading_env.open({"delay": 0, "message": "暗色"})
    assert h2.property("item").property("spinnerTint").isValid()
    h2.hide()
    loading_env.setdark(False)


def test_loading_local_target(qml_engine):
    """局部加载：target 是 Item 时挂进该 Item 内并铺满（Nova 增强）。"""
    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Services\n"
                "Item { id: host; width: 320; height: 240\n"
                "  property var h: null\n"
                "  property var kid: children.length > 0 ? children[0] : null\n"
                "  property bool attachedNow: kid !== null && kid.parent === host\n"
                "  Component.onCompleted: h = NovaLoading.show({ delay: 0, target: host, message: '局部' })\n"
                "}")
    assert obj.property("h").property("valid") is True
    assert obj.property("attachedNow") is True
    obj.property("h").hide()


def test_loading_timeout_guard(loading_env):
    """超时保护：timeout 到点强制收口（Nova 增强，防卡死）。"""
    h = loading_env.open({"delay": 0, "group": "slow", "timeout": 150})
    assert loading_env.active("slow") is True
    _pump(500)
    assert loading_env.active("slow") is False
    assert h.property("valid") is False


# ══════════════════════════════════════════════════════════════
# L4 服务层：NovaStorage（LocalStorage API · 命名空间 · 真落盘）
# ══════════════════════════════════════════════════════════════

STORAGE_DRIVER_QML = (
    "import QtQuick\nimport Nova.Services\n"
    "QtObject {\n"
    "  function useNs(n) { return NovaStorage.useNamespace(n) }\n"
    "  function set(k, v) { return NovaStorage.set(k, v) }\n"
    "  function get(k, d) { return NovaStorage.get(k, d) }\n"
    "  function has(k) { return NovaStorage.has(k) }\n"
    "  function drop(k) { return NovaStorage.remove(k) }\n"
    "  function clear() { return NovaStorage.clear() }\n"
    "  function keys() { return NovaStorage.getAllKeys() }\n"
    "  function all() { return NovaStorage.getAll() }\n"
    "  function setAll(o) { return NovaStorage.setAll(o) }\n"
    "  function setAllArray() { return NovaStorage.setAll([1, 2, 3]) }\n"
    "  function len() { return NovaStorage.getLength() }\n"
    "  function empty() { return NovaStorage.isEmpty() }\n"
    "  function reload() { return NovaStorage.reload() }\n"
    "  function setItem(k, v) { return NovaStorage.setItem(k, v) }\n"
    "  function getItem(k) { return NovaStorage.getItem(k) }\n"
    "  function removeItem(k) { return NovaStorage.removeItem(k) }\n"
    "  function backend() { return NovaStorage.backend }\n"
    "  function path() { return NovaStorage.storagePath }\n"
    "}"
)

STORAGE_TEST_NS = "nova-smoke"


@pytest.fixture()
def storage_env(qml_engine):
    """持久化测试环境：切到专用命名空间并清空，避免污染真实用户数据。"""
    drv = _make(qml_engine, STORAGE_DRIVER_QML)
    drv.useNs(STORAGE_TEST_NS)
    drv.clear()
    yield drv
    drv.clear()


def test_storage_crud(storage_env):
    """set/get/has/remove/getLength/isEmpty 基本语义。"""
    assert storage_env.empty() is True
    assert storage_env.set("alpha", 1) is True
    assert storage_env.has("alpha") is True
    assert storage_env.get("alpha", 0) == 1
    assert storage_env.len() == 1
    assert storage_env.drop("alpha") is True
    assert storage_env.drop("alpha") is False          # 二次删除返回 false
    assert storage_env.get("alpha", "fallback") == "fallback"


def _v(value):
    """QML 返回值归一：QJSValue → Python，其余原样。"""
    return value.toVariant() if hasattr(value, "toVariant") else value


def test_storage_value_types(storage_env):
    """值类型往返：字符串 / 数字 / 布尔 / 对象 / 数组 / null。"""
    storage_env.set("s", "青铜峡")
    storage_env.set("n", 3.14)
    storage_env.set("b", True)
    storage_env.set("o", {"k": [1, 2], "deep": {"x": "y"}})
    storage_env.set("a", [1, "two", False])
    storage_env.set("z", None)

    assert storage_env.get("s", None) == "青铜峡"
    assert abs(storage_env.get("n", 0) - 3.14) < 1e-9
    assert storage_env.get("b", False) is True
    assert _v(storage_env.get("o", {}))["deep"]["x"] == "y"
    assert _v(storage_env.get("a", []))[1] == "two"
    assert storage_env.get("z", "missing") is None
    assert storage_env.has("z") is True               # null 与"键不存在"可区分


def test_storage_persistence_to_disk(storage_env):
    """真落盘：写入后由 Python 侧新建 QSettings 实例读回同一 ini（模拟重启）。"""
    from pyside_nova.runtime import NovaRuntime

    storage_env.set("persist", {"mode": "ini"})
    rt = NovaRuntime()
    blob = rt.readBlob(STORAGE_TEST_NS)
    assert "persist" in blob and "ini" in blob
    assert storage_env.path().endswith("nova-storage.ini")


def test_storage_namespace_isolated(storage_env):
    """命名空间隔离：A 空间写入不影响 B 空间；切回 A 数据仍在。"""
    storage_env.set("k", "A")
    storage_env.useNs(STORAGE_TEST_NS + "-b")
    storage_env.clear()
    assert storage_env.has("k") is False
    storage_env.set("k", "B")
    assert storage_env.get("k", None) == "B"
    storage_env.useNs(STORAGE_TEST_NS)
    assert storage_env.get("k", None) == "A"
    storage_env.useNs(STORAGE_TEST_NS + "-b")
    storage_env.clear()
    storage_env.useNs(STORAGE_TEST_NS)


def test_storage_getall_deepcopy(storage_env):
    """getAll 返回深拷贝：外部改副本不影响库内数据。"""
    storage_env.setAll({"a": 1, "b": {"c": 2}})
    assert storage_env.len() == 2
    snap = _v(storage_env.all())
    snap["b"]["c"] = 999
    assert _v(storage_env.get("b", {}))["c"] == 2
    assert sorted(_v(storage_env.keys())) == ["a", "b"]


def test_storage_invalid_inputs(storage_env):
    """非法输入安全兜底：setAll 非对象拒绝；空 key 拒绝；损坏数据不崩。"""
    assert storage_env.setAllArray() is False
    assert storage_env.setAll("nope") is False
    assert storage_env.set(None, 1) is False


def test_storage_web_aliases(storage_env):
    """Web Storage 兼容别名：setItem/getItem/removeItem 与主 API 同源。"""
    assert storage_env.setItem("w", "v") is True
    assert storage_env.getItem("w") == "v"
    assert storage_env.removeItem("w") is True
    assert storage_env.getItem("w") is None


# ══════════════════════════════════════════════════════════════
# L4 服务层：NovaPlatform / NovaApp
# ══════════════════════════════════════════════════════════════

def test_platform_facts(qml_engine):
    """平台事实：os 与 Python 侧一致、桌面互斥判定、snapshot 字段齐全。"""
    import sys

    from pyside_nova.runtime import NovaRuntime

    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Services\n"
                "QtObject {\n"
                " property string os: NovaPlatform.os\n"
                " property bool w: NovaPlatform.isWindows\n"
                " property bool l: NovaPlatform.isLinux\n"
                " property bool d: NovaPlatform.isDesktop\n"
                " property bool t: NovaPlatform.hasTouch\n"
                " property string desc: NovaPlatform.describe()\n"
                " property var snap: NovaPlatform.snapshot()\n"
                "}")
    rt = NovaRuntime()
    assert obj.property("os") == rt.osName
    assert (obj.property("w") and obj.property("l")) is False
    assert isinstance(obj.property("t"), bool)
    assert obj.property("desc") != ""
    snap = _v(obj.property("snap"))
    for key in ("os", "osVersion", "cpuArch", "isMobile", "isDesktop", "hasTouch", "isWasm"):
        assert key in snap
    if sys.platform.startswith("linux"):
        assert obj.property("l") is True
        assert obj.property("d") is True


# 驱动对象在 QML 侧持有窗口引用（held）：QML 的 JS GC 不认 Python 引用，
# 必须由 QML 属性强引用窗口，否则 _pump 触发 GC 后窗口被回收、Python wrapper 悬空。
APP_DRIVER_QML = (
    "import QtQuick\nimport Nova.Services\n"
    "QtObject {\n"
    "  property var held: null\n"
    "  function keep(w) { held = w }\n"
    "  function snap() { return NovaApp.snapshot() }\n"
    "  function curTitle() { return NovaApp.title }\n"
    "  function curVisible() { return NovaApp.isVisible }\n"
    "  function title(t) { return NovaApp.setTitle(t) }\n"
    "  function vis(n) { return NovaApp.setVisibility(n) }\n"
    "  function toggle() { return NovaApp.toggle() }\n"
    "  function exitFs() { return NovaApp.exit() }\n"
    "  function bad(n) { return NovaApp.setVisibility(n) }\n"
    "}"
)


def test_app_window_control(qml_engine):
    """窗口服务：标题同步、最大化/全屏切换、toggle 往返、非法状态拒绝。"""
    drv = _make(qml_engine, APP_DRIVER_QML)      # 先建驱动，再建窗口并立刻在 QML 侧强引用
    win = _make(qml_engine, NOTIFY_WINDOW_QML)
    drv.keep(win)

    assert drv.snap().toVariant()["available"] is True
    assert drv.title("Nova 控制台") is True
    assert drv.curTitle() == "Nova 控制台"          # 断言一律走 QML 侧，不摸 Python 侧窗口 wrapper

    assert drv.vis("maximized") is True
    assert drv.snap().toVariant()["isMaximized"] is True

    assert drv.toggle() is True
    assert drv.snap().toVariant()["isFullscreen"] is True
    assert drv.toggle() is True
    assert drv.snap().toVariant()["isFullscreen"] is False
    assert drv.snap().toVariant()["isMaximized"] is True          # 退出全屏回落到进入前状态

    assert drv.vis("windowed") is True
    assert drv.bad("floating") is False


def test_app_without_window(qml_engine):
    """无源窗口时安全降级：available=false、命令返回 false、不抛错。"""
    engine = QQmlEngine()
    init_nova(engine)
    component = QQmlComponent(engine)
    component.setData(("import QtQuick\nimport Nova.Services\n"
                       "QtObject { property bool a: NovaApp.available\n"
                       " property bool r: NovaApp.request()\n"
                       " property string t: NovaApp.title }").encode(),
                      QUrl("qrc:/nova-app-nowin.qml"))
    obj = component.create()
    assert obj is not None, [e.toString() for e in component.errors()]
    assert obj.property("a") is False
    assert obj.property("r") is False
    assert obj.property("t") == ""
    obj.deleteLater()


# ══════════════════════════════════════════════════════════════
# L3 行为层（v0.7.0）：Intersection / Scroll / ClosePopup / Touch 四件套
# ══════════════════════════════════════════════════════════════

# 单窗口装全部行为：各行为占不同矩形区域（MouseArea 不能叠在同一目标上——
# 这是 QML 指针模型的固有约束，不是实现缺陷），驱动函数统一由窗口持有。
BEHAVIOR_ENV_QML = (
    "import QtQuick\nimport QtQuick.Window\nimport Nova.Behaviors\nimport Nova.Services\n"
    "Window { id: win; width: 420; height: 640; visible: true; color: '#f4f4f4'\n"
    "  Component.onCompleted: NovaScreen.source = win\n"
    "  property int panCount: 0\n"
    "  property string panDir: ''\n"
    "  property bool panFirst: false\n"
    "  property bool panFinal: false\n"
    "  property real panOffsetX: 0\n"
    "  property int swipeCount: 0\n"
    "  property string swipeDir: ''\n"
    "  property real swipeVelocity: 0\n"
    "  property int holdCount: 0\n"
    "  property int holdDuration: 0\n"
    "  property int repCount: 0\n"
    "  property int interEnter: 0\n"
    "  property int interExit: 0\n"
    "  property int onceCount: 0\n"
    "  property int fireCount: 0\n"
    "  property real scrollV: -1\n"
    "  property bool scrollAtBottom: false\n"
    "  property string scrollDir: ''\n"
    "  function moveInter(y) { interBox.y = y }\n"
    "  function scrollTo(v) { flick.contentY = v }\n"
    "  function interRatioNow() { return inter.intersectionRatio }\n"
    "  function interVisible() { return inter.isIntersecting }\n"
    "  function rearmOnce() { onceBeh.rearm() }\n"
    "  function pauseOnce() { onceBeh.enabled = false }\n"
    "  function resumeOnce() { onceBeh.enabled = true }\n"
    "  function stopInter() { inter.stop() }\n"
    "  function poolCount() { return NovaIntersectionPool.count }\n"
    "  Rectangle { id: panBox; x: 0; y: 0; width: 200; height: 120; color: '#c8e6c9'\n"
    "    NovaTouchPan { onPan: (d) => { win.panCount++; win.panDir = d.direction;\n"
    "      if (d.isFirst) win.panFirst = true; if (d.isFinal) win.panFinal = true;\n"
    "      win.panOffsetX = d.offset.x } } }\n"
    "  Rectangle { id: swipeBox; x: 0; y: 130; width: 200; height: 120; color: '#bbdefb'\n"
    "    NovaTouchSwipe { directions: ['right']\n"
    "      onSwipe: (d) => { win.swipeCount++; win.swipeDir = d.direction;\n"
    "        win.swipeVelocity = d.velocity } } }\n"
    "  Rectangle { id: holdBox; x: 0; y: 260; width: 200; height: 120; color: '#ffe0b2'\n"
    "    NovaTouchHold { duration: 250\n"
    "      onHold: (d) => { win.holdCount++; win.holdDuration = d.duration } } }\n"
    "  Rectangle { id: repBox; x: 200; y: 0; width: 220; height: 120; color: '#f8bbd0'\n"
    "    NovaTouchRepeat { delays: '0:150:100'\n"
    "      onRepeat: (d) => win.repCount = d.repeatCount } }\n"
    "  Rectangle { id: interBox; x: 200; y: 130; width: 220; height: 120; color: '#d1c4e9'\n"
    "    NovaIntersection { id: inter; threshold: [0, 0.5]\n"
    "      onEntered: (e) => win.interEnter++\n"
    "      onExited: (e) => win.interExit++ }\n"
    "    NovaIntersection { id: onceBeh; once: true; threshold: 0.3\n"
    "      onEntered: (e) => win.onceCount++ }\n"
    "    NovaScrollFire { threshold: 0.6; onFire: (i) => win.fireCount++ } }\n"
    "  Flickable { id: flick; x: 0; y: 400; width: 420; height: 220\n"
    "    contentWidth: 420; contentHeight: 1000; clip: true\n"
    "    NovaScrollObserver { onScroll: (d) => { win.scrollV = d.vertical;\n"
    "      win.scrollAtBottom = d.atBottom; win.scrollDir = d.direction } } }\n"
    "}"
)

# 通用驱动代理：PySide 把 QML Window 包装成 QWindow（metaobject 里没有 QML 函数），
# 所以行为一律经 QML 侧代理调用；代理同时强引用窗口，避免 JS GC 回收无父窗口。
BEHAVIOR_DRIVER_QML = (
    "import QtQuick\n"
    "QtObject {\n"
    "  property var w: null\n"
    "  function keep(x) { w = x }\n"
    "  function call0(name) {\n"
    "    var fn = w ? w[name] : null\n"
    "    return typeof fn === 'function' ? fn.call(w) : null\n"
    "  }\n"
    "  function call1(name, a) {\n"
    "    var fn = w ? w[name] : null\n"
    "    return typeof fn === 'function' ? fn.call(w, a) : null\n"
    "  }\n"
    "  function call2(name, a, b) {\n"
    "    var fn = w ? w[name] : null\n"
    "    return typeof fn === 'function' ? fn.call(w, a, b) : null\n"
    "  }\n"
    "  function val(name) { return w ? w[name] : undefined }\n"
    "}"
)


def _call(drv, name, *args):
    """QML 函数按固定形参暴露（Qt 6 不支持可选参数），按实参个数分派。"""
    if len(args) == 0:
        return drv.call0(name)
    if len(args) == 1:
        return drv.call1(name, args[0])
    return drv.call2(name, args[0], args[1])


@pytest.fixture()
def behavior_env(qml_engine):
    """L3 行为测试环境：可见窗口（QTest 投递鼠标事件要求 visible=true）+ 调用代理。"""
    win = _make(qml_engine, BEHAVIOR_ENV_QML, wait=0.12)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)      # 直接在 QML 侧持有窗口：JS GC 不认 Python 引用
    _pump(80)
    return drv


def test_intersection_enter_exit_and_ratio(behavior_env):
    """初始可见 → entered 一次、比例 1.0；移出视口 → 比例 0、exited；移回 → 再次 entered。"""
    drv = behavior_env
    assert drv.val("interEnter") == 1
    assert abs(_call(drv, "interRatioNow") - 1.0) < 0.01

    _call(drv, "moveInter", 800)              # 整个移出窗口
    _pump(120)
    assert _call(drv, "interRatioNow") == 0.0
    assert drv.val("interExit") == 1
    assert _call(drv, "interVisible") is False

    _call(drv, "moveInter", 130)
    _pump(120)
    assert drv.val("interEnter") == 2
    assert _call(drv, "interVisible") is True


def test_intersection_ratio_partial(behavior_env):
    """部分可见时比例精确：box 露出 60px / 高 120px → 0.5 左右。"""
    drv = behavior_env
    _call(drv, "moveInter", 580)              # 窗口高 640，box 580..700 → 可见 60
    _pump(120)
    ratio = _call(drv, "interRatioNow")
    assert 0.45 < ratio < 0.55, ratio
    assert _call(drv, "interVisible") is True


def test_intersection_once_and_rearm(behavior_env):
    """once:true 触发一次后解除观察；关掉再打开（rearm）可再次触发。"""
    drv = behavior_env
    assert drv.val("onceCount") == 1

    _call(drv, "moveInter", 900)              # 移出，once 已退休，不重复
    _pump(120)
    _call(drv, "moveInter", 130)
    _pump(120)
    assert drv.val("onceCount") == 1

    _call(drv, "pauseOnce")                 # 禁用 → 移出池
    _pump(60)
    _call(drv, "resumeOnce")                # 重新打开 = 再武装（基线"重新赋值"等价语义）
    _pump(120)
    assert drv.val("onceCount") == 2


def test_intersection_stop_releases_subscription(behavior_env):
    """stop() 显式停止后不再回调（对标 handler 返回 false），池里少一个订阅者。"""
    drv = behavior_env
    before = _call(drv, "poolCount")
    _call(drv, "stopInter")
    _pump(80)
    assert _call(drv, "poolCount") < before
    _call(drv, "moveInter", 900)
    _pump(120)
    _call(drv, "moveInter", 130)
    _pump(120)
    assert _call(drv, "interRatioNow") == 1.0   # 状态仍可读，但不再发信号
    assert drv.val("interEnter") == 1


def test_scroll_observer_positions(behavior_env):
    """Flickable 滚动 → onScroll 给出 vertical / 方向 / atBottom。"""
    drv = behavior_env
    _call(drv, "scrollTo", 300)
    _pump(120)
    assert abs(drv.val("scrollV") - 300) < 0.01
    assert drv.val("scrollAtBottom") is False
    assert drv.val("scrollDir") == "down"

    _call(drv, "scrollTo", 780)               # contentHeight 1000 - height 220 = 780
    _pump(120)
    assert drv.val("scrollAtBottom") is True


def test_scroll_fire_once_and_threshold(behavior_env):
    """ScrollFire 进入视口即触发一次（v2.30 语义：不滚动也会触发），之后不再重复。"""
    drv = behavior_env
    assert drv.val("fireCount") == 1
    _call(drv, "moveInter", 900)
    _pump(120)
    _call(drv, "moveInter", 130)
    _pump(120)
    assert drv.val("fireCount") == 1


def test_touch_pan_details(behavior_env):
    """拖动：方向、首末帧、带符号 offset 齐全。"""
    drv = behavior_env
    win = drv.property("w")
    QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, QPoint(40, 40))
    _pump(30)
    QTest.mouseMove(win, QPoint(90, 44), 20)
    _pump(20)
    QTest.mouseMove(win, QPoint(150, 48), 20)
    _pump(20)
    QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, QPoint(150, 48))
    _pump(80)

    assert drv.val("panCount") >= 2
    assert drv.val("panDir") == "right"
    assert drv.val("panFirst") is True
    assert drv.val("panFinal") is True
    assert drv.val("panOffsetX") > 80


def test_touch_swipe_direction_filter(behavior_env):
    """右滑命中（directions:['right']），左滑被过滤。"""
    drv = behavior_env
    win = drv.property("w")
    QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, QPoint(40, 190))
    QTest.mouseMove(win, QPoint(180, 190), 10)
    _pump(30)
    QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, QPoint(180, 190))
    _pump(60)
    assert drv.val("swipeCount") == 1
    assert drv.val("swipeDir") == "right"
    assert drv.val("swipeVelocity") > 0.06

    QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, QPoint(180, 190))
    QTest.mouseMove(win, QPoint(60, 190), 10)
    _pump(30)
    QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, QPoint(60, 190))
    _pump(60)
    assert drv.val("swipeCount") == 1       # 左滑不在白名单，不触发


def test_touch_hold_timing(behavior_env):
    """按住 250ms 触发一次；提前松手不触发；触发后松手不重复。"""
    drv = behavior_env
    win = drv.property("w")
    QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, QPoint(40, 320))
    _pump(400)
    assert drv.val("holdCount") == 1
    assert drv.val("holdDuration") == 250
    QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, QPoint(40, 320))
    _pump(80)
    assert drv.val("holdCount") == 1


def test_touch_repeat_sequence(behavior_env):
    """按住连发：首帧立即 + 之后按 150/100 节奏；松手即停。"""
    drv = behavior_env
    win = drv.property("w")
    QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, QPoint(250, 40))
    _pump(90)
    first = drv.val("repCount")
    assert first >= 1
    _pump(420)
    grown = drv.val("repCount")
    assert grown > first

    QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, QPoint(250, 40))
    _pump(80)
    stopped = drv.val("repCount")
    _pump(300)
    assert drv.val("repCount") == stopped   # 松手后不再增长


# ── ClosePopup：弹层栈按层关闭 ──────────────────────────────
CLOSE_POPUP_QML = (
    "import QtQuick\nimport QtQuick.Window\nimport Nova.Controls\nimport Nova.Behaviors\n"
    "import Nova.Services\n"
    "Window { id: win; width: 420; height: 400; visible: true\n"
    "  Component.onCompleted: NovaScreen.source = win\n"
    "  property int closedCount: 0\n"
    "  NovaBtn { id: btn; x: 20; y: 20; text: '关闭'\n"
    "    NovaClosePopup { id: cp; onClosed: (n) => win.closedCount = n } }\n"
    "  function open(n) { NovaDialog.hideAll('api');\n"
    "    for (var i = 0; i < n; i++) NovaDialog.show({ title: 'T' + i, message: 'm' }) }\n"
    "  function cnt() { return NovaDialog.count() }\n"
    "  function stack() { return NovaOverlayHost.popupCount() }\n"
    "  function clickBtn() { btn.clicked() }\n"
    "  function setDepth(d) { cp.depth = d }\n"
    "  function trigger() { return cp.trigger() }\n"
    "  function clearAll() { NovaDialog.hideAll('api') }\n"
    "}"
)


@pytest.fixture()
def close_popup_env(qml_engine):
    win = _make(qml_engine, CLOSE_POPUP_QML, wait=0.05)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)      # 直接在 QML 侧持有窗口：JS GC 不认 Python 引用
    _call(drv, "clearAll")
    _pump(80)
    yield drv
    _call(drv, "clearAll")
    _pump(80)


def test_dialog_enters_popup_stack(close_popup_env):
    """Dialog 打开进栈、关闭出栈（NovaClosePopup 才有"层"可数）。"""
    drv = close_popup_env
    _call(drv, "open", 2)
    _pump(80)
    assert _call(drv, "cnt") == 2
    assert _call(drv, "stack") == 2

    _call(drv, "clearAll")
    _pump(450)                              # 关闭动画 180+160ms，等它真的销毁出栈
    assert _call(drv, "cnt") == 0
    assert _call(drv, "stack") == 0


def test_close_popup_clicked_bridge(close_popup_env):
    """宿主 clicked 桥接：点一下关最上层；depth=0 禁用；depth<0 全关。"""
    drv = close_popup_env
    _call(drv, "open", 2)
    _pump(80)

    _call(drv, "clickBtn")                    # depth 默认 1
    _pump(300)
    assert _call(drv, "cnt") == 1
    assert drv.val("closedCount") == 1

    _call(drv, "setDepth", 0)                 # 禁用语义
    _call(drv, "clickBtn")
    _pump(120)
    assert _call(drv, "cnt") == 1

    _call(drv, "setDepth", -1)                # 整链
    _call(drv, "clickBtn")
    _pump(450)
    assert _call(drv, "cnt") == 0


def test_close_popup_trigger_returns_count(close_popup_env):
    """trigger() 返回实际关闭层数（可用于埋点/日志）。"""
    drv = close_popup_env
    _call(drv, "open", 3)
    _pump(80)
    assert _call(drv, "trigger") == 1
    _pump(300)
    assert _call(drv, "cnt") == 2


# ══════════════════════════════════════════════════════════════
# 0.8.0 · Sprint 4：L0 设计语言（图标集/动效/排版）+ L5 工具层
# ══════════════════════════════════════════════════════════════

L0_ENV_QML = r"""
import QtQuick
import Nova.Design
import Nova.Services
import Nova.Controls

Item {
    id: win
    width: 400; height: 300

    property int enterCount: 0
    property int exitCount: 0
    property int debCount: 0
    property int thrCount: 0
    property int frameCount: 0
    property var debFn: null
    property var thrFn: null
    property var frameFn: null
    property string uid1: ""
    property string uid2: ""

    readonly property var fixedDate: new Date(2026, 10, 22, 21, 53, 7, 123)

    // ── 图标集 ──
    property int setCount: NovaIconSet.available.length
    property int keyCount: NovaIconSet.keyPaths.length
    property int providerCount: NovaIconSet.providers.length
    property string defName: NovaIconSet.name
    property string typePositive: NovaIconSet.type.positive
    property string arrowDown: NovaIconSet.get("arrow.down")
    property string missingKey: NovaIconSet.get("no.such.key", "fb")

    function reset() {
        NovaMotion.speedFactor = 1.0
        NovaMotion.reducedMotion = false
        NovaIconSet.use("material-icons")
        NovaIconSet.unregister("my-set")
        NovaIconSet.unregisterProvider("acme")
    }
    function useSet(n) { return NovaIconSet.use(n) }
    function setNameValue() { return NovaIconSet.name }
    function val(p) { return NovaIconSet.get(p) }
    function applyPartial() {
        NovaIconSet.set({ editor: { bold: "mdi-alpha-b" } })
        return String(NovaIconSet.editor.italic) + "|" + NovaIconSet.editor.bold
    }
    function applyName() {
        NovaIconSet.set({ name: "brand-x" })
        return NovaIconSet.name
    }
    function registerSet() { return NovaIconSet.register("my-set", { type: { positive: "mdi-verified" } }) }
    function cutSet() { return NovaIconSet.unregister("my-set") }
    function kind(s) { return NovaIconSet.resolve(s).kind }
    function provider(s) { return NovaIconSet.resolve(s).provider }
    function iname(s) { return NovaIconSet.resolve(s).name }
    function reason(s) { var r = NovaIconSet.resolve(s); return r.reason === undefined ? "" : r.reason }
    function nodeCount(s) { var r = NovaIconSet.resolve(s); return r.nodes === undefined ? -1 : r.nodes.length }
    function viewBox(s) { var r = NovaIconSet.resolve(s); return r.viewBox === undefined ? "" : r.viewBox }
    function addProvider() { return NovaIconSet.registerProvider("acme", { url: "https://acme.io/%1.svg" }) }
    function delProvider() { return NovaIconSet.unregisterProvider("acme") }
    function pcount() { return NovaIconSet.providers.length }
    function purl(a, b) { return NovaIconSet.providerUrl(a, b) }
    function badProvider() { return NovaIconSet.registerProvider("bad", { kind: "ligature" }) }

    // ── 动效 ──
    property int durMain: NovaMotion.transitionDuration
    property int durScale: NovaMotion.scaleDuration
    property int durFade: NovaMotion.fadeDuration
    property int presetCount: NovaMotion.presetNames.length
    property bool hasFlip: NovaMotion.hasPreset("flip-right")
    property bool hasBogus: NovaMotion.hasPreset("no-such")
    function setSpeed(v) { NovaMotion.speedFactor = v }
    function setReduced(v) { NovaMotion.reducedMotion = v }
    function durOf(v) { return NovaMotion.duration(v) }
    function presetField(n, f) { var p = NovaMotion.preset(n); return p[f] === undefined ? -999 : p[f] }

    // ── 排版 ──
    property int typeCount: NovaTheme.typeNames.length
    property string h1Style: NovaTheme.textStyle("h1").size + "/" + NovaTheme.textStyle("h1").lineHeight
                             + "/" + NovaTheme.textStyle("h1").letterSpacing + "/" + NovaTheme.textStyle("h1").weight
    property string capStyle: NovaTheme.textStyle("caption").size + "/" + NovaTheme.textStyle("caption").weight
    property int unknownSize: NovaTheme.textStyle("nope").size
    property int elev7: NovaTheme.elevationLayers(7).length
    property int elev1Blur: NovaTheme.elevationLayers(1)[0][2]

    NovaText { id: tx1; typography: "h3"; text: "甲" }
    property int txSize: tx1.font.pixelSize
    property int txLine: tx1.lineHeight

    NovaTransition {
        id: tr
        name: "fade"
        show: true
        width: 100
        height: 50
        duration: 60
        onEntered: win.enterCount++
        onExited: win.exitCount++
    }
    function showIt() { tr.show = true }
    function hideIt() { tr.show = false }
    function trVisible() { return tr.visible ? "true" : "false" }

    // ── colors ──
    property string c1: NovaUtils.colors.rgbToHex({ r: 91, g: 110, b: 245 })
    property string c2: NovaUtils.colors.rgbToHex({ r: 91, g: 110, b: 245, a: 50 })
    property int c3: NovaUtils.colors.hexToRgb("#5B6EF5").g
    property string c4: NovaUtils.colors.lighten("#000000", 50)
    property string c5: NovaUtils.colors.lighten("#FFFFFF", -50)
    property string c6: NovaUtils.colors.changeAlpha("#ff0000", 0.5)
    property string c7: NovaUtils.colors.changeAlpha("#ff000080", -0.5)
    property real c8: NovaUtils.colors.textToRgb("rgba(10,20,30,0.5)").a
    property string c9: NovaUtils.colors.rgbToText({ r: 10, g: 20, b: 30, a: 50 })
    property string c10: NovaUtils.colors.blend("rgba(255,0,0,0.5)", "#0000FF")
    property real c11: NovaUtils.colors.contrastRatio("#000000", "#FFFFFF")
    property string c12: NovaUtils.colors.contrastColor("#000000")
    property int c13: NovaUtils.colors.rgbToHsv({ r: 255, g: 0, b: 0 }).h
    property int c14: NovaUtils.colors.hsvToRgb({ h: 120, s: 100, v: 100 }).g

    // ── format ──
    property string f1: NovaUtils.format.humanStorageSize(1536)
    property string f2: NovaUtils.format.humanStorageSize(1023)
    property string f3: NovaUtils.format.pad(7)
    property int f4: NovaUtils.format.getDecimalsCount(1.5e-7)
    property int f5: NovaUtils.format.normalizeToInterval(-1, 0, 4)
    property string f6: NovaUtils.format.capitalize("nova")
    property real f7: NovaUtils.format.between(15, 0, 10)

    // ── date ──
    property string d1: NovaUtils.date.formatDate(fixedDate, "YYYY|YY|M|Mo|MM|MMM|MMMM|Q|Qo|D|Do|DD|DDD|DDDo|DDDD|d|do|dd|ddd|dddd|E|w|wo|ww|GG|GGGG|H|HH|h|hh|m|mm|s|ss|S|SS|SSS|A|a|aa")
    property string d2: NovaUtils.date.formatDate(fixedDate, "YYYY年M月D日 dddd", NovaUtils.dateLocale.zhCN)
    property string d3: NovaUtils.date.formatDate(fixedDate, "[YYYY]年-MM")
    property string dZ: NovaUtils.date.formatDate(fixedDate, "Z|ZZ")
    property bool dX: NovaUtils.date.formatDate(fixedDate, "x") === String(fixedDate.getTime())
    property bool d4: NovaUtils.date.formatDate(undefined) === undefined
    property bool d5: NovaUtils.date.formatDate("not a date") === undefined
    property string dMask: NovaUtils.date.formatDate(fixedDate)
    function addMonthEnd() { var x = NovaUtils.date.addToDate(new Date(2026, 0, 31), { month: 1 }); return (x.getMonth() + 1) + "/" + x.getDate() }
    function subDays() { var x = NovaUtils.date.subtractFromDate(new Date(2026, 2, 1), { days: 1 }); return (x.getMonth() + 1) + "/" + x.getDate() }
    function addLeap() { var x = NovaUtils.date.addToDate(new Date(2024, 1, 29), { year: 1 }); return x.getFullYear() + "/" + (x.getMonth() + 1) + "/" + x.getDate() }
    function adjDate() { var x = NovaUtils.date.adjustDate(new Date(2026, 0, 1), { month: 6, date: 15 }); return (x.getMonth() + 1) + "/" + x.getDate() }
    property string d6: NovaUtils.date.formatDate(NovaUtils.date.startOfDate(fixedDate, "month"), "YYYY-MM-DD HH:mm:ss")
    property string d7: NovaUtils.date.formatDate(NovaUtils.date.endOfDate(fixedDate, "month"), "YYYY-MM-DD HH:mm:ss.SSS")
    property int d8: NovaUtils.date.getDayOfYear(fixedDate)
    property int d9: NovaUtils.date.getWeekOfYear(fixedDate)
    property int d10: NovaUtils.date.getISOWeekYear(fixedDate)
    property int d11: NovaUtils.date.getDayOfWeek(fixedDate)
    property bool b1: NovaUtils.date.isBetweenDates(fixedDate, new Date(2026, 10, 1), new Date(2026, 11, 1))
    property bool b2: NovaUtils.date.isBetweenDates(new Date(2026, 10, 1), new Date(2026, 10, 1), new Date(2026, 11, 1))
    property bool b3: NovaUtils.date.isBetweenDates(new Date(2026, 10, 1), new Date(2026, 10, 1), new Date(2026, 11, 1), "[]")
    property bool b4: NovaUtils.date.isBetweenDates(new Date(2026, 10, 1, 23), new Date(2026, 10, 1), new Date(2026, 10, 2), { onlyDate: true, inclusiveFrom: true, inclusiveTo: true })
    property bool b5: NovaUtils.date.isSameDate(new Date(2026, 10, 22, 1), new Date(2026, 10, 22, 23), "day")
    property string d12: NovaUtils.date.formatDate(NovaUtils.date.extractDate("22/11/2026 21:53", "DD/MM/YYYY HH:mm"), "YYYY-MM-DD HH:mm")
    property int d13: NovaUtils.date.daysInMonth(new Date(2024, 1, 1))
    property string d14: NovaUtils.date.formatDate(NovaUtils.date.getMaxDate(new Date(2026, 0, 1), new Date(2026, 5, 1)), "MM")
    property string d15: NovaUtils.date.formatDate(NovaUtils.date.getDateBetween(new Date(2026, 0, 1), new Date(2026, 5, 1), new Date(2026, 8, 1)), "MM")
    property string d16: NovaUtils.date.inferDateFormat(new Date())
    property bool d17: NovaUtils.date.isValid(new Date()) && !NovaUtils.date.isValid("xx")

    // ── is / extend ──
    property bool e1: NovaUtils.is.deepEqual({ a: [1, 2] }, { a: [1, 2] })
    property bool e2: NovaUtils.is.deepEqual({ a: 1 }, { a: 2 })
    property bool e3: NovaUtils.is.isObject({}) && !NovaUtils.is.isObject([]) && NovaUtils.is.isDate(new Date())
    property bool e4: NovaUtils.is.isNumber(1.5) && !NovaUtils.is.isNumber(NaN)
    property string e5: JSON.stringify(NovaUtils.extend(true, { a: { b: 1 } }, { a: { c: 2 } }))
    property string e6: JSON.stringify(NovaUtils.extend({ x: 1 }, { y: 2 }))

    // ── 计时类 ──
    function setupDebounce() { debFn = NovaUtils.debounce(function () { win.debCount++ }, 60) }
    function fireDebounce() { debFn() }
    function cancelDebounce() { debFn.cancel() }
    function setupThrottle() { thrFn = NovaUtils.throttle(function () { win.thrCount++ }, 80, true) }
    function fireThrottle() { thrFn() }
    function setupFrame() { frameFn = NovaUtils.frameDebounce(function () { win.frameCount++ }) }
    function fireFrame() { frameFn() }
    function makeUids() { win.uid1 = NovaUtils.uid(); win.uid2 = NovaUtils.uid() }
}
"""


@pytest.fixture()
def l0_env(qml_engine):
    """L0/L5 测试环境：单例状态复位 + 窗口强引用 + QML 侧调用代理。"""
    win = _make(qml_engine, L0_ENV_QML)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)
    _call(drv, "reset")
    _pump(30)
    return drv


# ── L0 图标集 ──────────────────────────────────────────────

def test_iconset_defaults(l0_env):
    """默认图标集 material-icons：14 套内置、100 个语义键、provider 注册表就绪。"""
    drv = l0_env
    assert drv.val("defName") == "material-icons"
    assert drv.val("setCount") == 14
    assert drv.val("keyCount") == 100
    assert drv.val("providerCount") >= 14
    assert drv.val("typePositive") == "check_circle"
    assert drv.val("arrowDown") == "arrow_downward"
    assert drv.val("missingKey") == "fb"


def test_iconset_use_switches_values(l0_env):
    """use() 切换图标集后语义键整体换值（1:1 对标 $q.iconSet.type.positive）。"""
    drv = l0_env
    assert _call(drv, "useSet", "mdi-v7") is True
    assert _call(drv, "setNameValue") == "mdi-v7"
    assert _call(drv, "val", "type.positive") == "mdi-check-circle"
    assert _call(drv, "val", "arrow.dropdown") == "mdi-menu-down"
    assert _call(drv, "useSet", "fontawesome-v6") is True
    assert _call(drv, "val", "type.positive") == "fas fa-check"
    assert _call(drv, "useSet", "no-such-set") is False
    assert _call(drv, "setNameValue") == "fontawesome-v6"


def test_iconset_set_is_shallow_merge(l0_env):
    """set() 顶层浅合并：给出 editor 组就整组替换（基线 Object.assign 语义）。"""
    drv = l0_env
    out = _call(drv, "applyPartial")
    assert out == "undefined|mdi-alpha-b"       # editor.italic 被整组替换掉
    assert _call(drv, "applyName") == "brand-x"


def test_iconset_register_custom(l0_env):
    """register() 自定义图标集以 mdi-v7 全键补齐，可 use/unregister。"""
    drv = l0_env
    assert _call(drv, "registerSet") is True
    assert drv.val("setCount") == 15
    assert _call(drv, "useSet", "my-set") is True
    assert _call(drv, "val", "type.positive") == "mdi-verified"
    assert _call(drv, "val", "chevron.left") == "mdi-chevron-left"   # 未给出的键自动补齐
    assert _call(drv, "cutSet") is True
    assert drv.val("setCount") == 14


def test_resolve_prefix_family(l0_env):
    """前缀归一化：mdi-/fa 旧式/o_ 变体/显式冒号/sym_ 变体/ion 平台前缀。"""
    drv = l0_env
    assert _call(drv, "provider", "mdi-home") == "mdi"
    assert _call(drv, "iname", "mdi-home") == "home"
    assert _call(drv, "provider", "mdi:home") == "mdi"
    assert _call(drv, "provider", "fas fa-home") == "fontawesome-solid"
    assert _call(drv, "iname", "fas fa-home") == "home"
    assert _call(drv, "provider", "far fa-star") == "fontawesome-regular"
    assert _call(drv, "provider", "fab fa-github") == "fontawesome-brands"
    assert _call(drv, "provider", "las la-check") == "line-awesome"
    assert _call(drv, "provider", "o_home") == "material-outlined"
    assert _call(drv, "provider", "r_home") == "material-round"
    assert _call(drv, "provider", "s_home") == "material-sharp"
    assert _call(drv, "provider", "sym_r_home") == "material-symbols-rounded"
    assert _call(drv, "provider", "sym_o_home") == "material-symbols-outlined"
    assert _call(drv, "provider", "bi-house") == "bootstrap"
    assert _call(drv, "provider", "eva-home") == "eva"
    assert _call(drv, "provider", "ti-home") == "themify"
    assert _call(drv, "provider", "ion-md-home") == "ionicons"
    assert _call(drv, "iname", "ion-md-home") == "ion-md-home"


def test_resolve_platform_and_fallbacks(l0_env):
    """ion 裸名补平台前缀；裸名走当前图标集默认 provider；none/img 两通道。"""
    drv = l0_env
    ion = _call(drv, "iname", "ion-home")
    assert ion.startswith("ion-md-") or ion.startswith("ion-ios-")
    assert _call(drv, "provider", "home") == "material"
    assert _call(drv, "kind", "") == "none"
    assert _call(drv, "kind", "none") == "none"
    assert _call(drv, "kind", "img:qrc:/a.png") == "image"
    assert _call(drv, "iname", "img:qrc:/a.png") == "qrc:/a.png"
    assert _call(drv, "kind", "svguse:a.svg#b") == "unsupported"
    assert "SVG <use>" in _call(drv, "reason", "svguse:a.svg#b")
    assert _call(drv, "kind", "i-carbon-home") == "unsupported"


def test_resolve_svg_path_channel(l0_env):
    """SVG path 直出：&& 多路径、|viewBox、@@ style/transform 三段解析。"""
    drv = l0_env
    assert _call(drv, "kind", "M12 2L2 7v10h4V9h12v8h4V7z") == "path"
    assert _call(drv, "nodeCount", "M0 0h24v24H0z&&M5 5h14v14H5z") == 2
    assert _call(drv, "viewBox", "M0 0h24v24H0z|0 0 16 16") == "0 0 16 16"
    assert _call(drv, "viewBox", "M0 0h24v24H0z") == "0 0 24 24"


def test_provider_registry(l0_env):
    """provider 注册/注销/模板替换；非法 spec 拒绝注册。"""
    drv = l0_env
    base = _call(drv, "pcount")
    assert _call(drv, "addProvider") is True
    assert _call(drv, "pcount") == base + 1
    assert _call(drv, "purl", "acme", "rocket") == "https://acme.io/rocket.svg"
    assert _call(drv, "delProvider") is True
    assert _call(drv, "pcount") == base
    assert _call(drv, "badProvider") is False


def test_provider_urls_match_baseline_distribution(l0_env):
    """四类 provider 的真实分发地址（2026-11-22 实测 200）：ionicons/eva/fa 别名/line-awesome。"""
    drv = l0_env
    assert _call(drv, "purl", "ionicons", "ion-md-home").endswith("/ionicons@7/dist/svg/home.svg")
    assert _call(drv, "purl", "ionicons", "ion-ios-home").endswith("/svg/home-outline.svg")
    assert _call(drv, "purl", "eva", "home-outline").endswith("/eva-icons@1.1.3/outline/svg/home-outline.svg")
    assert _call(drv, "purl", "fontawesome-solid", "home").endswith("/svgs/solid/house.svg")
    assert _call(drv, "purl", "fontawesome-solid", "user").endswith("/svgs/solid/user.svg")
    assert _call(drv, "purl", "line-awesome", "check").endswith("/line-awesome@1/svg/check-solid.svg")
    assert _call(drv, "purl", "bootstrap", "house").endswith("/bootstrap-icons@1.11.3/icons/house.svg")


# ── L0 动效 ───────────────────────────────────────────────

def test_motion_tokens(l0_env):
    """动效令牌 1:1：--q-transition-duration .3s、q-animate--scale .15s、q-animate--fade .2s。"""
    drv = l0_env
    assert drv.val("durMain") == 300
    assert drv.val("durScale") == 150
    assert drv.val("durFade") == 200
    assert drv.val("presetCount") == 15
    assert drv.val("hasFlip") is True
    assert drv.val("hasBogus") is False


def test_motion_preset_fields(l0_env):
    """预设字段：fade 只动透明、slide-right 位移非对称、flip 绕 y 轴。"""
    drv = l0_env
    assert _call(drv, "presetField", "fade", "opacityIn") == 0
    assert _call(drv, "presetField", "fade", "xIn") == -999
    assert _call(drv, "presetField", "slide-right", "xIn") == -1
    assert _call(drv, "presetField", "slide-right", "xOut") == 1
    assert _call(drv, "presetField", "jump-up", "pyIn") == 15
    assert _call(drv, "presetField", "flip-right", "angleOut") == 180


def test_motion_speed_and_reduced(l0_env):
    """speedFactor 缩放时长；reducedMotion 全链归零（无障碍短路）。"""
    drv = l0_env
    assert _call(drv, "durOf", 300) == 300
    _call(drv, "setSpeed", 2)
    assert _call(drv, "durOf", 300) == 600
    _call(drv, "setSpeed", 0.5)
    assert _call(drv, "durOf", 300) == 150
    _call(drv, "setReduced", True)
    assert _call(drv, "durOf", 300) == 0
    _call(drv, "setReduced", False)


def test_transition_enter_exit_signals(l0_env):
    """NovaTransition：show 切换触发 entered/exited，离场结束隐藏。"""
    drv = l0_env
    assert drv.val("enterCount") == 0
    _call(drv, "hideIt")
    _pump(180)
    assert drv.val("exitCount") == 1
    assert _call(drv, "trVisible") == "false"
    _call(drv, "showIt")
    _pump(180)
    assert drv.val("enterCount") == 1
    assert _call(drv, "trVisible") == "true"


# ── L0 排版 ───────────────────────────────────────────────

def test_typescale_table(l0_env):
    """12 级字阶：h1 = 6rem/6rem/-.01562em/300 → 96px/96px/-1.5px/Light。"""
    drv = l0_env
    assert drv.val("typeCount") == 12
    assert drv.val("h1Style") == "96/96/-1.5/300"
    assert drv.val("capStyle") == "12/400"
    assert drv.val("unknownSize") == 14       # 未知字阶回落 body2


def test_elevation_tokens(l0_env):
    """高程令牌：7 级就近取 6 级（三层），shadow-1 umbra blur = 3。"""
    drv = l0_env
    assert drv.val("elev7") == 3
    assert drv.val("elev1Blur") == 3


def test_novatext_applies_style(l0_env):
    """NovaText 按字阶写入 font.pixelSize / lineHeight。"""
    drv = l0_env
    assert drv.val("txSize") == 48
    assert drv.val("txLine") == 50


# ── L5 colors ─────────────────────────────────────────────

def test_colors_hex_roundtrip(l0_env):
    """rgbToHex / hexToRgb 往返；a 为 0..100 百分制。"""
    drv = l0_env
    assert drv.val("c1") == "#5b6ef5"
    assert drv.val("c2") == "#5b6ef580"
    assert drv.val("c3") == 110


def test_colors_lighten_darken(l0_env):
    """lighten 正数提亮、负数即 darken。"""
    drv = l0_env
    assert drv.val("c4") == "#808080"
    assert drv.val("c5") == "#808080"


def test_colors_change_alpha_baseline_semantics(l0_env):
    """changeAlpha：原色无 alpha 时基准为 0（基线坑，非直觉的 100）。"""
    drv = l0_env
    assert drv.val("c6") == "#ff000080"
    assert drv.val("c7") == "#ff000000"


def test_colors_text_and_blend(l0_env):
    """textToRgb 的 a 百分制（0.5→50）；blend 为 source-over 合成。"""
    drv = l0_env
    assert drv.val("c8") == 50
    assert drv.val("c9") == "rgba(10,20,30,0.5)"
    assert drv.val("c10") == "#800080ff"


def test_colors_contrast_and_hsv(l0_env):
    """WCAG 对比度黑白 21:1；自动字色对比度取大者；HSV 往返。"""
    drv = l0_env
    assert abs(drv.val("c11") - 21.0) < 0.01
    assert drv.val("c12") == "#FFFFFF"
    assert drv.val("c13") == 0
    assert drv.val("c14") == 255


# ── L5 format ─────────────────────────────────────────────

def test_format_functions(l0_env):
    """humanStorageSize / pad / getDecimalsCount / normalizeToInterval / between。"""
    drv = l0_env
    assert drv.val("f1") == "1.5KB"
    assert drv.val("f2") == "1023.0B"
    assert drv.val("f3") == "07"
    assert drv.val("f4") == 8
    assert drv.val("f5") == 4
    assert drv.val("f6") == "Nova"
    assert drv.val("f7") == 10


# ── L5 date ───────────────────────────────────────────────

def test_formatdate_all_tokens(l0_env):
    """formatDate 44 个 token 逐项对账（2026-11-22 21:53:07.123 星期日）。"""
    drv = l0_env
    assert drv.val("d1") == (
        "2026|26|11|11th|11|Nov|November|4|4th|22|22nd|22|326|326th|326|"
        "0|0th|Su|Sun|Sunday|7|47|47th|47|26|2026|21|21|9|09|53|53|7|07|1|12|123|PM|pm|p.m."
    )


def test_formatdate_timezone_and_epoch(l0_env):
    """Z/ZZ 符号与基线一致（东八区 +08:00/+0800）；x 为毫秒时间戳。"""
    import re
    drv = l0_env
    tz = drv.val("dZ")
    assert re.match(r"^[+-]\d{2}:\d{2}\|[+-]\d{4}$", tz), tz
    assert drv.val("dX") is True


def test_formatdate_locale_and_literal(l0_env):
    """中文语言包（MMMM/dddd）；[literal] 转义为原样输出（基线语义，非解析后插值）。"""
    drv = l0_env
    assert drv.val("d2") == "2026年11月22日 星期日"
    assert drv.val("d3") == "YYYY年-11"


def test_formatdate_invalid_inputs(l0_env):
    """非法输入返回 undefined；mask 缺省用 defaultMask。"""
    drv = l0_env
    assert drv.val("d4") is True
    assert drv.val("d5") is True
    m = drv.val("dMask")
    assert m.startswith("2026-11-22T21:53:07.123")


def test_date_arithmetic_month_end(l0_env):
    """月加法先夹取日（1/31 + 1 月 → 2/28，不滚到 3/3）；闰年 2/29 + 1 年 → 2/28。"""
    drv = l0_env
    assert _call(drv, "addMonthEnd") == "2/28"
    assert _call(drv, "subDays") == "2/28"
    assert _call(drv, "addLeap") == "2025/2/28"
    assert _call(drv, "adjDate") == "7/15"


def test_date_start_end_of_unit(l0_env):
    """startOfDate/endOfDate 月边界：01 00:00:00.000 ~ 30 23:59:59.999。"""
    drv = l0_env
    assert drv.val("d6") == "2026-11-01 00:00:00"
    assert drv.val("d7") == "2026-11-30 23:59:59.999"


def test_date_week_and_day_of_year(l0_env):
    """年内第 326 天、ISO 第 47 周、ISO 周年 2026、周日 = 7。"""
    drv = l0_env
    assert drv.val("d8") == 326
    assert drv.val("d9") == 47
    assert drv.val("d10") == 2026
    assert drv.val("d11") == 7


def test_date_is_between_dates(l0_env):
    """isBetweenDates 默认两端开；'[]' 字符串写法闭合；onlyDate 只比日期。"""
    drv = l0_env
    assert drv.val("b1") is True
    assert drv.val("b2") is False
    assert drv.val("b3") is True
    assert drv.val("b4") is True
    assert drv.val("b5") is True


def test_date_extract_and_misc(l0_env):
    """extractDate 解析往返；daysInMonth 闰年、getMaxDate、getDateBetween、infer/isValid。"""
    drv = l0_env
    assert drv.val("d12") == "2026-11-22 21:53"
    assert drv.val("d13") == 29
    assert drv.val("d14") == "06"
    assert drv.val("d15") == "06"
    assert drv.val("d16") == "date"
    assert drv.val("d17") is True


# ── L5 is / extend / 计时类 ────────────────────────────────

def test_is_and_extend(l0_env):
    """deepEqual 深比较、isObject 排除数组、extend 深合并保留原对象。"""
    drv = l0_env
    assert drv.val("e1") is True
    assert drv.val("e2") is False
    assert drv.val("e3") is True
    assert drv.val("e4") is True
    assert drv.val("e5") == '{"a":{"b":1,"c":2}}'
    assert drv.val("e6") == '{"x":1,"y":2}'


def test_debounce_trailing_and_cancel(l0_env):
    """debounce 默认 trailing：连发 3 次只执行 1 次；cancel 后不再执行。"""
    drv = l0_env
    _call(drv, "setupDebounce")
    _call(drv, "fireDebounce")
    _call(drv, "fireDebounce")
    _call(drv, "fireDebounce")
    _pump(200)
    assert drv.val("debCount") == 1
    _call(drv, "fireDebounce")
    _call(drv, "cancelDebounce")
    _pump(200)
    assert drv.val("debCount") == 1


def test_throttle_leading_and_trailing(l0_env):
    """throttle：窗口内只执行一次，尾跑补齐（trailing=true）。"""
    drv = l0_env
    _call(drv, "setupThrottle")
    _call(drv, "fireThrottle")
    _call(drv, "fireThrottle")
    _pump(40)
    assert drv.val("thrCount") == 1
    _pump(200)
    assert drv.val("thrCount") == 2


def test_frame_debounce_and_uid(l0_env):
    """frameDebounce 只保留最后一次；uid 为 v4 形态且唯一。"""
    import re
    drv = l0_env
    _call(drv, "setupFrame")
    _call(drv, "fireFrame")
    _call(drv, "fireFrame")
    _pump(120)
    assert drv.val("frameCount") == 1

    _call(drv, "makeUids")
    u1, u2 = drv.val("uid1"), drv.val("uid2")
    assert re.match(r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$", u1), u1
    assert u1 != u2
