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
