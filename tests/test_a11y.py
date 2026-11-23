# tests/test_a11y.py
# 可访问性测试：WCAG 对比度数学、令牌 AA 门禁、运行时角色矩阵、键盘全路径、焦点环焦点可见性、状态播报（0.16.0）
"""可访问性（WCAG 2.1 AA）门禁测试。

覆盖四层：
1. 数学层：NovaA11y 的对比度/亮度/AA 派生（纯函数，可脱离 Item 断言）
2. 令牌层：NovaTheme 全部文本/边界/焦点令牌在明暗两主题下过阈值（4.5:1 / 3:1）
3. 运行时层：QAccessible 权威接口逐类型核对 role/name/disabled/focusable
4. 行为层：键盘激活、焦点环焦点可见性（键盘可见／指针隐藏）、状态播报、静态门禁自检
"""
import os
import subprocess
import sys
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QEventLoop, QObject, QUrl
from PySide6.QtGui import QAccessible, QGuiApplication, QWindow
from PySide6.QtQml import QQmlComponent, QQmlContext, QQmlEngine, QQmlExpression
from PySide6.QtTest import QTest
from PySide6.QtCore import Qt

from pyside_nova import init_nova
from pyside_nova.runtime import set_keyboard_mode

ROOT = Path(__file__).resolve().parent.parent
_ALIVE = []


@pytest.fixture(scope="module")
def engine():
    app = QGuiApplication.instance() or QGuiApplication([])
    assert app is not None
    eng = QQmlEngine()
    init_nova(eng)
    yield eng
    del eng


def _make(eng, code, wait=0.0):
    comp = QQmlComponent(eng)
    comp.setData(code.encode("utf-8"), QUrl("qrc:/nova-a11y.qml"))
    obj = comp.create()
    errors = [e.toString() for e in comp.errors()]
    assert obj is not None, errors
    _ALIVE.append(obj)
    _ALIVE.append(comp)          # 组件持有创建出的 Window 所有权，必须强引用
    if not isinstance(obj, QWindow):
        obj.setParent(QGuiApplication.instance())
    if wait > 0:
        _pump(wait)
    return obj


def _pump(seconds=0.1):
    import time

    end = time.time() + seconds
    app = QGuiApplication.instance()
    while time.time() < end:
        app.processEvents()
        time.sleep(0.01)


def _eval(engine, obj, expression):
    """求值 QML 表达式（QQmlExpression.evaluate() 返回 (值, 是否 undefined) 元组）。"""
    return QQmlExpression(QQmlContext(engine.rootContext()), obj, expression).evaluate()[0]


def _by_name(root, name):
    for child in root.findChildren(QObject):
        if child.objectName() == name:
            return child
    raise AssertionError(f"未找到 objectName={name}")


def _iface(item):
    iface = QAccessible.queryAccessibleInterface(item)
    assert iface is not None, "QAccessible 拿不到接口（Accessible 未生效）"
    return iface


# ══════════════════════════════════════════════════════════════
# 1. 数学层
# ══════════════════════════════════════════════════════════════
def test_wcag_contrast_math(engine):
    """对比度：黑白 21:1、对称、同色 1:1；亮度与 WCAG 定义一致。"""
    obj = _make(engine, """
import QtQuick
import Nova.Design
QtObject {
    property real c1: NovaA11y.contrast("#000000", "#FFFFFF")
    property real c2: NovaA11y.contrast("#FFFFFF", "#000000")
    property real c3: NovaA11y.contrast("#5B6EF5", "#5B6EF5")
    property real lumWhite: NovaA11y.luminance("#FFFFFF")
    property real lumBlack: NovaA11y.luminance("#000000")
    property bool aaPass: NovaA11y.passesAA("#1F2128", "#FFFFFF")
    property bool aaFail: NovaA11y.passesAA("#EEEEEE", "#FFFFFF")
    property bool uiPass: NovaA11y.passesUI("#949494", "#FFFFFF")
}
""")
    assert abs(obj.property("c1") - 21.0) < 0.01
    assert abs(obj.property("c2") - 21.0) < 0.01
    assert abs(obj.property("c3") - 1.0) < 0.001
    assert abs(obj.property("lumWhite") - 1.0) < 0.001
    assert abs(obj.property("lumBlack")) < 0.001
    assert obj.property("aaPass") is True
    assert obj.property("aaFail") is False
    assert obj.property("uiPass") is True


def test_aa_derivation_is_minimal(engine):
    """AA 派生：已达标原样返回；未达标只朝最近方向做最小位移，且落点过阈值。"""
    obj = _make(engine, """
import QtQuick
import Nova.Services
import Nova.Design
QtObject {
    property color keep: NovaA11y.aaText("#000000", "#FFFFFF")
    property color pushed: NovaA11y.aaText(NovaTheme.warning, NovaTheme.a11yBase)
    property real pushedRatio: NovaA11y.contrast(NovaA11y.aaText(NovaTheme.warning, NovaTheme.a11yBase), NovaTheme.a11yBase)
    property color fill: NovaTheme.fillTint(NovaTheme.primary)
    property real fillRatio: NovaA11y.contrast(NovaTheme.textOnPrimary, NovaTheme.fillTint(NovaTheme.primary))
}
""")
    assert obj.property("keep").name() == "#000000"
    assert obj.property("pushedRatio") >= 4.5
    assert obj.property("fillRatio") >= 4.5
    # 品牌色相保持：派生后的填充色仍在蓝紫区间（红分量最小、蓝分量最大）
    fill = obj.property("fill")
    assert fill.blue() > fill.green() > fill.red()


# ══════════════════════════════════════════════════════════════
# 2. 令牌层（明暗两主题全量门禁）
# ══════════════════════════════════════════════════════════════
TOKEN_PROBE = """
import QtQuick
import Nova.Services
import Nova.Design

QtObject {
    id: probe
    readonly property var surfaceNames: ["page", "surface", "surfaceAlt"]
    readonly property var surfaceColors: [NovaTheme.page, NovaTheme.surface, NovaTheme.surfaceAlt]
    readonly property var textTokens: ({
        textColor: NovaTheme.textColor,
        textMuted: NovaTheme.textMuted,
        primaryText: NovaTheme.primaryText,
        secondaryText: NovaTheme.secondaryText,
        accentText: NovaTheme.accentText,
        positiveText: NovaTheme.positiveText,
        negativeText: NovaTheme.negativeText,
        warningText: NovaTheme.warningText,
        infoText: NovaTheme.infoText
    })

    // 文本 AA：9 令牌 × 3 表面全部 ≥4.5:1
    function textFailures() {
        var out = []
        for (var k in textTokens) {
            for (var i = 0; i < surfaceColors.length; ++i) {
                var r = NovaA11y.contrast(textTokens[k], surfaceColors[i])
                if (r < NovaA11y.aaTextRatio)
                    out.push(k + "@" + surfaceNames[i] + "=" + r.toFixed(2))
            }
        }
        return out
    }

    // 非文本 3:1 + 填充面 4.5:1
    function uiFailures() {
        var out = []
        if (NovaA11y.contrast(NovaTheme.outlineStrong, NovaTheme.a11yBase) < NovaA11y.uiComponentRatio)
            out.push("outlineStrong=" + NovaA11y.contrast(NovaTheme.outlineStrong, NovaTheme.a11yBase).toFixed(2))
        for (var i = 0; i < surfaceColors.length; ++i) {
            var r = NovaA11y.contrast(NovaTheme.focusRing, surfaceColors[i])
            if (r < NovaA11y.uiComponentRatio)
                out.push("focusRing@" + surfaceNames[i] + "=" + r.toFixed(2))
        }
        var fr = NovaA11y.contrast(NovaTheme.textOnPrimary, NovaTheme.fillTint(NovaTheme.primary))
        if (fr < NovaA11y.aaTextRatio)
            out.push("textOnPrimary@primaryFill=" + fr.toFixed(2))
        return out
    }
}
"""


@pytest.mark.parametrize("dark", [False, True])
def test_all_text_tokens_pass_aa_on_all_surfaces(engine, dark):
    """9 个文本令牌 × 3 种表面（明/暗）：全部 ≥4.5:1（WCAG 1.4.3 AA）。"""
    from PySide6.QtQml import QQmlContext, QQmlExpression

    drv = _make(engine, TOKEN_PROBE)
    ctx = QQmlContext(engine.rootContext())
    QQmlExpression(ctx, drv, f"NovaTheme.setDark({'true' if dark else 'false'})").evaluate()
    _pump(0.05)
    failures = _eval(engine, drv, "textFailures().join('; ')")
    QQmlExpression(ctx, drv, "NovaTheme.setDark(false)").evaluate()
    _pump(0.02)
    assert failures == "", f"AA 未达标（{'dark' if dark else 'light'}）：{failures}"


@pytest.mark.parametrize("dark", [False, True])
def test_border_and_focus_ring_pass_ui_contrast(engine, dark):
    """控件边界与焦点环 ≥3:1（WCAG 1.4.11）；填充底色压白字 ≥4.5:1。"""
    from PySide6.QtQml import QQmlContext, QQmlExpression

    drv = _make(engine, TOKEN_PROBE)
    ctx = QQmlContext(engine.rootContext())
    QQmlExpression(ctx, drv, f"NovaTheme.setDark({'true' if dark else 'false'})").evaluate()
    _pump(0.05)
    failures = _eval(engine, drv, "uiFailures().join('; ')")
    QQmlExpression(ctx, drv, "NovaTheme.setDark(false)").evaluate()
    _pump(0.02)
    assert failures == "", f"非文本对比未达标（{'dark' if dark else 'light'}）：{failures}"


# ══════════════════════════════════════════════════════════════
# 3. 运行时角色矩阵（QAccessible 权威接口）
# ══════════════════════════════════════════════════════════════
MATRIX_WINDOW = """
import QtQuick
import Nova.Controls
Window {
    width: 640; height: 480; visible: true
    NovaBtn { objectName: "c_btn"; text: "保存" }
    NovaBtn { objectName: "c_btn_icon"; icon: "mdi:home"; a11yLabel: "首页" }
    NovaBtn { objectName: "c_btn_off"; text: "禁用"; disable: true }
    NovaCheckbox { objectName: "c_check"; label: "同意条款"; modelValue: true }
    NovaToggle { objectName: "c_toggle"; label: "通知"; modelValue: false }
    NovaRadio { objectName: "c_radio"; label: "选项一"; modelValue: "a"; val: "a" }
    NovaInput { objectName: "c_input"; label: "邮箱" }
    NovaSelect { objectName: "c_select"; label: "城市" }
    NovaSlider { objectName: "c_slider"; a11yLabel: "音量"; modelValue: 30 }
    NovaChip { objectName: "c_chip"; text: "标签" }
    NovaChip { objectName: "c_chip_off"; text: "静态" }
    NovaTab { objectName: "c_tab"; label: "概览" }
    NovaExpansionItem { objectName: "c_exp"; label: "高级设置" }
    NovaTh { objectName: "c_th"; text: "名称"; sortable: true; width: 100 }
    NovaSpinner { objectName: "c_spinner" }
    NovaAvatar { objectName: "c_avatar"; text: "Nova" }
    NovaImg { objectName: "c_img"; alt: "图表" }
    NovaSeparator { objectName: "c_sep"; width: 50 }
    NovaTable { objectName: "c_table"; columns: [{ name: "a", label: "A" }]; rows: [{ a: 1 }, { a: 2 }] }
    NovaTabs { objectName: "c_tabs"; NovaTab { label: "一" } NovaTab { label: "二" } }
}
"""

EXPECT = {
    "c_btn": (QAccessible.Role.Button, "保存", False),
    "c_btn_icon": (QAccessible.Role.Button, "首页", False),
    "c_btn_off": (QAccessible.Role.Button, "禁用", True),
    "c_check": (QAccessible.Role.CheckBox, "同意条款", False),
    "c_toggle": (QAccessible.Role.Switch, "通知", False),
    "c_radio": (QAccessible.Role.RadioButton, "选项一", False),
    "c_input": (QAccessible.Role.EditableText, "邮箱", False),
    "c_select": (QAccessible.Role.ComboBox, "城市", False),
    "c_slider": (QAccessible.Role.Slider, "音量", False),
    "c_chip": (QAccessible.Role.StaticText, "标签", False),
    "c_tab": (QAccessible.Role.PageTab, "概览", False),
    "c_exp": (QAccessible.Role.Button, "高级设置", False),
    "c_th": (QAccessible.Role.ColumnHeader, "名称", False),
    "c_avatar": (QAccessible.Role.Graphic, "Nova", False),
    "c_img": (QAccessible.Role.Graphic, "图表", False),
    "c_sep": (QAccessible.Role.Separator, "", False),
    "c_table": (QAccessible.Role.Table, "", False),
    "c_tabs": (QAccessible.Role.PageTabList, "", False),
    "c_spinner": (QAccessible.Role.ProgressBar, "", False),
}


def test_runtime_role_and_name_matrix(engine):
    """逐类型核对 QAccessible 暴露的 role / 可读名 / disabled 状态。"""
    win = _make(engine, MATRIX_WINDOW, wait=0.2)
    problems = []
    for tag, (role, name, disabled) in EXPECT.items():
        item = _by_name(win, tag)
        iface = _iface(item)
        if iface.role() != role:
            problems.append(f"{tag}: role={iface.role()} 期望 {role}")
        actual_name = iface.text(QAccessible.Text.Name)
        if actual_name != name:
            problems.append(f"{tag}: name={actual_name!r} 期望 {name!r}")
        if bool(iface.state().disabled) != disabled:
            problems.append(f"{tag}: disabled={bool(iface.state().disabled)} 期望 {disabled}")
    assert not problems, "\n".join(problems)


def test_focusable_only_for_actionable(engine):
    """可操作控件 focusable=true；纯展示（Chip 静态态、Spinner）不抢焦点。"""
    win = _make(engine, MATRIX_WINDOW, wait=0.2)
    for tag in ("c_btn", "c_check", "c_input", "c_select", "c_slider", "c_tab", "c_th"):
        assert _iface(_by_name(win, tag)).state().focusable, tag
    assert not _iface(_by_name(win, "c_spinner")).state().focusable


# ══════════════════════════════════════════════════════════════
# 4. 行为层：键盘 / 焦点环 / 播报 / 静态门禁
# ══════════════════════════════════════════════════════════════
KEY_WINDOW = """
import QtQuick
import Nova.Controls
Window {
    id: win
    width: 640; height: 480; visible: true

    property int btnClicks: 0
    property int chipClicks: 0
    property int tabClicks: 0
    property int pageRequests: 0
    property int tableClicks: 0
    property int tableIndex: -1
    property string tabsValue: ""

    NovaBtn { objectName: "k_btn"; text: "确定"; onClicked: win.btnClicks++ }
    NovaChip { objectName: "k_chip"; text: "标签"; clickable: true; onClicked: win.chipClicks++ }
    property var checkValue: null
    NovaCheckbox {
        objectName: "k_check"
        label: "勾选"
        modelValue: false
        onValueChanged: (v) => win.checkValue = v
    }
    NovaTab { objectName: "k_tab"; label: "概览"; onClicked: win.tabClicks++ }
    NovaPagination { objectName: "k_page"; page: 1; pages: 5; onPageRequested: win.pageRequests++ }
    NovaTable {
        objectName: "k_table"
        columns: [{ name: "a", label: "A" }]
        rows: [{ a: "r1" }, { a: "r2" }, { a: "r3" }]
        onRowClicked: (row, index) => { win.tableClicks++; win.tableIndex = index }
    }
    NovaTabs {
        objectName: "k_tabs"
        onUpdateModelValue: (v) => win.tabsValue = String(v)
        NovaTab { label: "一" } NovaTab { label: "二" } NovaTab { label: "三" }
    }
    NovaTime { objectName: "k_time" }
}
"""


@pytest.mark.parametrize("key,attr", [
    (Qt.Key_Return, "btnClicks"),
    (Qt.Key_Enter, "btnClicks"),
    (Qt.Key_Space, "btnClicks"),
])
def test_btn_keyboard_activation(engine, key, attr):
    """按钮：Enter / 小键盘 Enter / Space 均触发 clicked（WCAG 2.1.1 键盘可达）。"""
    win = _make(engine, KEY_WINDOW, wait=0.15)
    btn = _by_name(win, "k_btn")
    btn.forceActiveFocus()
    _pump(0.05)
    QTest.keyClick(win, key)
    _pump(0.05)
    assert win.property(attr) == 1


def test_chip_and_tab_keyboard_activation(engine):
    """可点 Chip / Tab：Space、Enter 触发 clicked。"""
    win = _make(engine, KEY_WINDOW, wait=0.15)
    chip = _by_name(win, "k_chip")
    chip.forceActiveFocus()
    QTest.keyClick(win, Qt.Key_Space)
    _pump(0.05)
    assert win.property("chipClicks") == 1

    tab = _by_name(win, "k_tab")
    tab.forceActiveFocus()
    QTest.keyClick(win, Qt.Key_Return)
    _pump(0.05)
    assert win.property("tabClicks") == 1


def test_checkbox_keyboard_toggle(engine):
    """复选：Space 切换（受控组件只 emit，宿主写回；此处断言信号落地）。"""
    win = _make(engine, KEY_WINDOW, wait=0.15)
    chk = _by_name(win, "k_check")
    chk.forceActiveFocus()
    QTest.keyClick(win, Qt.Key_Space)
    _pump(0.05)
    assert win.property("checkValue") is True      # 受控：组件只 emit，宿主写回


def test_pagination_arrow_keys(engine):
    """分页：Right 请求下一页（只 emit pageRequested，不自写 page）。"""
    win = _make(engine, KEY_WINDOW, wait=0.15)
    pg = _by_name(win, "k_page")
    pg.forceActiveFocus()
    QTest.keyClick(win, Qt.Key_Right)
    _pump(0.05)
    assert win.property("pageRequests") == 1
    assert pg.property("page") == 1          # 受控：宿主未写回则保持原值


def test_table_row_cursor_and_enter(engine):
    """表格：Down 移动行游标、Enter 触发行点击（带正确行号）。"""
    win = _make(engine, KEY_WINDOW, wait=0.2)
    tbl = _by_name(win, "k_table")
    tbl.forceActiveFocus()
    QTest.keyClick(win, Qt.Key_Down)
    QTest.keyClick(win, Qt.Key_Down)
    QTest.keyClick(win, Qt.Key_Return)
    _pump(0.05)
    assert win.property("tableClicks") == 1
    assert win.property("tableIndex") == 1


def test_tabs_arrow_navigation_is_controlled(engine):
    """标签页：Right 把下一标签名 emit 给宿主（受控契约：组件不自写 modelValue）。"""
    win = _make(engine, KEY_WINDOW, wait=0.2)
    tabs = _by_name(win, "k_tabs")
    tabs.forceActiveFocus()
    QTest.keyClick(win, Qt.Key_Right)
    _pump(0.05)
    assert win.property("tabsValue") != ""


def test_time_up_key_steps_hour(engine):
    """时间：Up 递增小时并产出规范值串（TT 内部 24h 存储）。"""
    win = _make(engine, KEY_WINDOW, wait=0.15)
    tm = _by_name(win, "k_time")
    tm.forceActiveFocus()
    QTest.keyClick(win, Qt.Key_Up)
    _pump(0.05)
    assert str(tm.property("modelValue")).startswith("01:")


def test_focus_ring_visible_on_keyboard_only(engine):
    """焦点环：键盘模态下可见，指针点击后隐藏（focus-visible 语义）。"""
    win = _make(engine, KEY_WINDOW, wait=0.15)
    btn = _by_name(win, "k_btn")
    set_keyboard_mode(True)
    btn.forceActiveFocus()
    _pump(0.05)
    rings = [c for c in btn.findChildren(QObject) if c.objectName() == "NovaFocusRing"]
    assert len(rings) == 1, "按钮应挂且仅挂一个焦点环"
    assert rings[0].property("visible") is True

    set_keyboard_mode(False)
    _pump(0.05)
    assert rings[0].property("visible") is False

    set_keyboard_mode(True)                   # 复位，避免影响后续用例
    _pump(0.02)


def test_live_region_announces_notice(engine):
    """状态播报：NovaA11y.notice 累计计数，NovaLiveRegion 消费最新文本（WCAG 4.1.3）。"""
    drv = _make(engine, """
import QtQuick
import Nova.Design
import Nova.Behaviors
Item {
    id: host
    property string spoken: ""
    property int before: NovaA11y.announcementCount
    NovaLiveRegion { id: region }
    function say(t) { NovaA11y.notice(t) }
    function count() { return NovaA11y.announcementCount }
    function last() { return NovaA11y.lastAnnouncement }
}
""")
    before = drv.property("before")
    from PySide6.QtQml import QQmlContext, QQmlExpression

    ctx = QQmlContext(engine.rootContext())
    _eval(engine, drv, "say('已保存')")
    _pump(0.05)
    after = int(_eval(engine, drv, "count()"))
    assert after == before + 1
    assert str(_eval(engine, drv, "last()")) == "已保存"


def test_static_gate_reports_zero_gaps():
    """静态门禁自检：scripts/check_a11y.py 必须对全库返回 0（CI 同款入口）。"""
    proc = subprocess.run([sys.executable, str(ROOT / "scripts" / "check_a11y.py")],
                          capture_output=True, text=True, cwd=str(ROOT))
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "门禁通过" in proc.stdout


def test_gallery_a11y_page_instantiates(engine):
    """画廊「无障碍 a11y」页可实例化且无 QML 运行时错误（ReferenceError 类会静默降级，必须抓）。"""
    from PySide6.QtCore import qInstallMessageHandler

    messages = []

    def handler(mode, ctx, msg):
        messages.append(msg)

    old = qInstallMessageHandler(handler)
    try:
        win = _make_component(engine, ROOT / "examples" / "gallery" / "main.qml")
        nav = _by_name(win, "nav")
        nav.setProperty("currentIndex", 22)
        _pump(0.3)
        titles = [c.property("text") for c in win.findChildren(QObject)
                  if c.metaObject().className().startswith("QQuickText")
                  and isinstance(c.property("text"), str)]
        assert any("无障碍 a11y" in t for t in titles), "a11y 页未渲染"
    finally:
        qInstallMessageHandler(old)
    fatal = [m for m in messages if "ReferenceError" in m or "TypeError" in m or "is not a type" in m]
    assert not fatal, "\n".join(fatal[:5])


def _make_component(engine, path):
    comp = QQmlComponent(engine, QUrl.fromLocalFile(str(path)))
    obj = comp.create()
    errors = [e.toString() for e in comp.errors()]
    assert obj is not None, errors
    _ALIVE.append(obj)
    _ALIVE.append(comp)
    return obj
