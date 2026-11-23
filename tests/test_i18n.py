# tests/test_i18n.py
# 国际化 + RTL 测试（0.16.1）：locale 切换 / 词典翻译 / 复数规则 / 数字货币日期 /
# RTL 方向派生 / 方向性组件镜像（Pagination / Breadcrumbs / SlideItem / Drawer）
"""NovaI18n 与 RTL 镜像测试。

覆盖五层：
1. locale 层：setLocale、baseLang/isoName 派生、isRtl 语言集合判定
2. 翻译层：t() 插值 / 缺译回落 key / 主语言码前缀回落 / addBundle 热注入
3. 复数层：CLDR 卡片规则（en/zh/ja/ru/ar/cs/pl）+ tp() 类别选择 + 热注入
4. 格式层：formatNumber / formatCurrency / formatDate / formatRelative
5. RTL 层：NovaTheme 派生令牌 + 方向性组件几何镜像

坑位 44：QQmlExpression + creationContext 组合对非 Item 对象在 Qt 6.12/PySide6
下间歇 SIGSEGV；本模块统一「QML 内定义 helper 函数/只读属性 + Python 直调/直读」
（QML 函数经 metaobject 暴露，PySide 可直接调用）。
"""
import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent

_ALIVE = []


def _pump():
    """刷事件循环：Qt.callLater 布局与 RTL 绑定重算需要一轮事件循环。"""
    QGuiApplication.processEvents()


def _wait_value(getter, expected, timeout=1.0):
    """轮询直至 getter() == expected（动画/CSS 类渐变需要事件循环推进时钟）。"""
    import time
    end = time.time() + timeout
    while time.time() < end:
        _pump()
        if getter() == expected:
            return True
        time.sleep(0.02)
    return False


@pytest.fixture(scope="module", autouse=True)
def _teardown(qml_engine):
    yield
    from conftest import close_alive
    close_alive()
    _ALIVE.clear()


@pytest.fixture(scope="module")
def engine(qml_engine):
    return qml_engine


def _make(engine, code):
    comp = QQmlComponent(engine)
    comp.setData(code.encode("utf-8"), QUrl("qrc:/nova-i18n.qml"))
    obj = comp.create()
    errors = [e.toString() for e in comp.errors()]
    assert obj is not None, errors
    _ALIVE.append(obj)
    _ALIVE.append(comp)
    return obj


@pytest.fixture(scope="module")
def i18n(engine):
    """常驻探针：包装 NovaI18n 全部可断言面（locale 状态跨用例以 reset 归位）。"""
    return _make(engine, """
import QtQuick
import Nova.Services
QtObject {
    // 只读包装（QQmlExpression 直读单例名需 import 上下文，探针内已具备）
    readonly property string locale: NovaI18n.locale
    readonly property string isoName: NovaI18n.isoName
    readonly property string baseLang: NovaI18n.baseLang
    readonly property bool isRtl: NovaI18n.isRtl
    readonly property string direction: NovaI18n.direction
    readonly property bool themeIsRtl: NovaTheme.isRtl
    readonly property string themeDirection: NovaTheme.direction
    function reset() { NovaI18n.setLocale("en-US") }
    function set(name) { NovaI18n.setLocale(name) }
    function t(key) { return NovaI18n.t(key) }
    function tp(key, n) { return NovaI18n.tp(key, n) }
    function ti(key, n) { return NovaI18n.t(key, {n: n}) }        // 插值
    function cat(n) { return NovaI18n.pluralCategory(n) }
    function num(n, d) { return NovaI18n.formatNumber(n, d) }
    function cur(n) { return NovaI18n.formatCurrency(n) }
    function addBundle(name, dict) { NovaI18n.addBundle(name, dict) }
    function addPluralBundle(name, dict) { NovaI18n.addPluralBundle(name, dict) }
}
""")


# ══════════════════════════════════════════════════════════════
# 1. locale 层
# ══════════════════════════════════════════════════════════════
def test_locale_switch_and_base_lang(i18n):
    """setLocale 更新 locale；baseLang 取首段并小写；isoName 保留全称。"""
    i18n.set("zh-TW")
    assert i18n.property("locale") == "zh-TW"
    assert i18n.property("isoName") == "zh-TW"
    assert i18n.property("baseLang") == "zh"
    i18n.reset()
    assert i18n.property("locale") == "en-US"
    assert i18n.property("baseLang") == "en"


def test_rtl_language_set(i18n):
    """isRtl/direction：RTL 语言集合（ar/he/fa/ur…）为真，其余为假；NovaTheme 派生同值。"""
    for loc, rtl in [("ar-EG", True), ("he-IL", True), ("fa-IR", True),
                     ("ur-PK", True), ("en-US", False), ("zh-CN", False),
                     ("de-DE", False), ("ru-RU", False)]:
        i18n.set(loc)
        assert i18n.property("isRtl") is rtl, loc
        assert i18n.property("direction") == ("rtl" if rtl else "ltr"), loc
        assert i18n.property("themeIsRtl") is rtl, loc
        assert i18n.property("themeDirection") == ("rtl" if rtl else "ltr"), loc
    i18n.reset()


# ══════════════════════════════════════════════════════════════
# 2. 翻译层
# ══════════════════════════════════════════════════════════════
def test_translate_and_interpolation(i18n):
    """t()：按 locale 查词典、{n} 插值、缺译回落 key 本身、主语言码前缀回落。"""
    i18n.set("zh-CN")
    assert i18n.t("confirm") == "确认"
    assert i18n.ti("selected", 3) == "已选 3 项"
    assert i18n.t("no.such.key") == "no.such.key"
    # 主语言码前缀回落：zh-TW → zh-CN 词典
    i18n.set("zh-TW")
    assert i18n.t("cancel") == "取消"
    i18n.reset()
    assert i18n.t("confirm") == "Confirm"


def test_add_bundle_hot_injection(i18n):
    """addBundle 运行时热注入新语言；未注入语言回落 en-US。"""
    i18n.addBundle("ja-JP", {"confirm": "確認する", "cancel": "キャンセル"})
    i18n.set("ja-JP")
    assert i18n.t("confirm") == "確認する"
    assert i18n.t("save") == "Save"      # 缺词回落 en-US
    i18n.reset()


# ══════════════════════════════════════════════════════════════
# 3. 复数层（CLDR 卡片规则）
# ══════════════════════════════════════════════════════════════
@pytest.mark.parametrize("loc,n,expected", [
    # en：one（仅整数 1）/ other
    ("en-US", 1, "one"), ("en-US", 0, "other"), ("en-US", 2, "other"),
    # zh/ja：恒 other
    ("zh-CN", 0, "other"), ("zh-CN", 1, "other"), ("zh-CN", 99, "other"),
    ("ja-JP", 1, "other"),
    # ru：one / few / many
    ("ru-RU", 1, "one"), ("ru-RU", 11, "many"), ("ru-RU", 21, "one"),
    ("ru-RU", 3, "few"), ("ru-RU", 5, "many"), ("ru-RU", 12, "many"),
    ("ru-RU", 22, "few"), ("ru-RU", 111, "many"),
    # ar：zero / one / two / few / many / other
    ("ar-EG", 0, "zero"), ("ar-EG", 1, "one"), ("ar-EG", 2, "two"),
    ("ar-EG", 5, "few"), ("ar-EG", 11, "many"), ("ar-EG", 99, "many"),
    ("ar-EG", 100, "other"),
    # cs：one / few / many
    ("cs-CZ", 1, "one"), ("cs-CZ", 3, "few"), ("cs-CZ", 5, "many"),
    # pl：one / few / many
    ("pl-PL", 1, "one"), ("pl-PL", 4, "few"), ("pl-PL", 14, "many"),
])
def test_plural_categories(i18n, loc, n, expected):
    i18n.set(loc)
    assert i18n.cat(n) == expected
    i18n.reset()


def test_plural_translate(i18n):
    """tp()：按复数类别选词条并插值 {n}；zh 单一 other 形态；缺条目回落 key。"""
    i18n.set("en-US")
    assert i18n.tp("apple", 1) == "1 apple"
    assert i18n.tp("apple", 2) == "2 apples"
    i18n.set("zh-CN")
    assert i18n.tp("apple", 5) == "5 个苹果"
    assert i18n.tp("nothing.here", 2) == "nothing.here"
    i18n.reset()


def test_plural_hot_injection(i18n):
    """addPluralBundle 热注入复数规则包。"""
    i18n.addPluralBundle("ja-JP", {"apple": {"other": "りんご {n} 個"}})
    i18n.set("ja-JP")
    assert i18n.tp("apple", 3) == "りんご 3 個"
    i18n.reset()


# ══════════════════════════════════════════════════════════════
# 4. 格式层
# ══════════════════════════════════════════════════════════════
def test_format_number_grouping(i18n):
    """formatNumber：千分位分组符与小数点随 locale（en 逗号点 / de 点逗号）。"""
    i18n.set("en-US")
    assert i18n.num(1234567.891, 2) == "1,234,567.89"
    assert i18n.num(-9876, 0) == "-9,876"
    assert i18n.num(42, 0) == "42"
    i18n.set("de-DE")
    assert i18n.num(1234567.891, 2) == "1.234.567,89"
    i18n.reset()


def test_format_currency(i18n):
    """formatCurrency：货币符号随 locale，复用 formatNumber 数字格式。"""
    i18n.set("en-US")
    assert i18n.cur(9999) == "$9,999.00"
    i18n.set("zh-CN")
    assert i18n.cur(9999) == "¥9,999.00"
    i18n.reset()


def test_format_date_and_relative(engine, i18n):
    """formatDate 全形态（iso/shortDate/longDateTime/自定义 pattern）+ formatRelative。
    日期对象由 QML 侧构造；en 含 AM、zh 含 上午、de 含本地化月份名。"""
    probe = _make(engine, """
import QtQuick
import Nova.Services
QtObject {
    function iso() { return NovaI18n.formatDate(new Date(2026,1,14,9,5,3), "iso") }
    function shortDate() { return NovaI18n.formatDate(new Date(2026,1,14), "shortDate") }
    function longDT() { return NovaI18n.formatDate(new Date(2026,1,14,9,5,3), "longDateTime") }
    function custom() { return NovaI18n.formatDate(new Date(2026,1,14), "yyyy-MM-dd") }
    function rel3d() { return NovaI18n.formatRelative(new Date(Date.now() - 3 * 86400000)) }
    function rel400d() { return NovaI18n.formatRelative(new Date(Date.now() - 400 * 86400000)) }
}
""")
    i18n.set("en-US")
    assert probe.iso() == "2026-02-14T09:05:03"
    assert probe.shortDate() == "2/14/26"
    assert probe.custom() == "2026-02-14"
    en_long = probe.longDT()
    assert "2026" in en_long and "AM" in en_long.upper()
    assert probe.rel3d() == "3 days ago"
    assert probe.rel400d() == "1 year ago"
    i18n.set("zh-CN")
    zh_long = probe.longDT()
    assert "2026" in zh_long and ("上午" in zh_long or "AM" in zh_long)
    assert probe.rel3d() == "3 天前"
    i18n.set("de-DE")
    assert "Februar" in probe.longDT()      # 本地化月份名
    i18n.reset()


# ══════════════════════════════════════════════════════════════
# 5. RTL 层：方向性组件几何镜像
# ══════════════════════════════════════════════════════════════
def test_rtl_pagination_mirrors(engine, i18n):
    """NovaPagination：RTL 下位置器镜像（首按钮排到右缘）。"""
    obj = _make(engine, """
import QtQuick
import Nova.Services
import Nova.Controls
Rectangle {
    width: 400; height: 60
    NovaPagination { id: pag; anchors.fill: parent; pages: 10; page: 3
                     arrows: true; boundaryLinks: true }
    function firstBtnX() { return pag.children.length > 0 ? pag.children[0].x : -1 }
}
""")
    i18n.reset()
    ltr_x = obj.firstBtnX()
    i18n.set("ar-EG")
    _pump()
    rtl_x = obj.firstBtnX()
    assert ltr_x == 0, f"LTR 首按钮应贴左，实际 x={ltr_x}"
    assert rtl_x > 0, f"RTL 首按钮应镜像到右侧，实际 x={rtl_x}"
    i18n.reset()


def test_rtl_breadcrumbs_mirrors(engine, i18n):
    """NovaBreadcrumbs：RTL 下手动布局反排（首条目 x 落在右半区）。"""
    obj = _make(engine, """
import QtQuick
import Nova.Services
import Nova.Controls
Rectangle {
    width: 400; height: 40
    NovaBreadcrumbs { id: bc; anchors.fill: parent
        NovaBreadcrumbsEl { label: "Home" }
        NovaBreadcrumbsEl { label: "Library" }
        NovaBreadcrumbsEl { label: "Detail" }
    }
    function firstElX() { return bc._els()[0].x }
}
""")
    i18n.reset()
    ltr_x = obj.firstElX()
    i18n.set("ar-EG")
    _pump()
    rtl_x = obj.firstElX()
    assert ltr_x < 100, f"LTR 首条目应从左侧排布，实际 x={ltr_x}"
    assert rtl_x > 100, f"RTL 首条目应反排到右半区，实际 x={rtl_x}"
    i18n.reset()


def test_rtl_slideitem_mirrors(engine, i18n):
    """NovaSlideItem：RTL 下逻辑 left 面板挂右缘、slideLeft 向 +x（视觉右）展开。"""
    obj = _make(engine, """
import QtQuick
import Nova.Services
import Nova.Controls
Rectangle {
    width: 400; height: 80
    NovaSlideItem { id: si; anchors.fill: parent; duration: 0
        Rectangle { width: 200; height: 40; color: "blue" }
        leftSlot: Component { Rectangle { width: 60; height: 40; color: "red" } }
        rightSlot: Component { Rectangle { width: 60; height: 40; color: "green" } }
    }
    function loaderX(name) {
        for (var i = 0; i < si.children.length; i++)
            if (si.children[i].objectName === name) return si.children[i].x
        return -1
    }
    function frontX() {
        for (var i = 0; i < si.children.length; i++)
            if (si.children[i].objectName === "NovaSlideItem.front") return si.children[i].x
        return -1
    }
    function slideL() { si.slideLeft() }
    function slideR() { si.slideRight() }
    function doReset() { si.reset() }
    function isOpen() { return si.opened }
}
""")
    i18n.reset()
    assert obj.loaderX("NovaSlideItem.leftLoader") == 0
    assert obj.loaderX("NovaSlideItem.rightLoader") == 328   # 400-72
    i18n.set("ar-EG")
    _pump()
    assert obj.loaderX("NovaSlideItem.leftLoader") == 328    # 逻辑 left → 右缘
    assert obj.loaderX("NovaSlideItem.rightLoader") == 0
    obj.slideL()
    assert obj.frontX() == 72                                # +x = 视觉右滑
    assert obj.isOpen() is True
    obj.doReset()
    obj.slideR()
    assert obj.frontX() == -72
    assert obj.isOpen() is True
    obj.doReset()
    assert obj.isOpen() is False
    i18n.reset()


def test_rtl_drawer_effective_side(engine, i18n):
    """NovaDrawer：RTL 下 effectiveSide 镜像；NovaLayout push 语义跟随。"""
    obj = _make(engine, """
import QtQuick
import Nova.Services
import Nova.Controls
Rectangle {
    width: 400; height: 200
    NovaLayout { id: lay; anchors.fill: parent
        // breakpoint 0：禁用断点自动收起（宿主 400px 会触发默认 1024 断点收起语义）
        NovaDrawer { id: dr; side: "left"; size: 120; breakpoint: 0 }
        NovaPage { }
    }
    function effSide() { return dr.effectiveSide }
    function pushLeft() { return lay.pushLeft }
    function pushRight() { return lay.pushRight }
    readonly property real drawerW: dr.width
}
""")
    i18n.reset()
    _pump()
    assert obj.effSide() == "left"
    # width 有 220ms Behavior 动画：轮询至稳定终值
    assert _wait_value(lambda: obj.property("drawerW"), 120), "抽屉展开动画未到位"
    assert obj.pushLeft() == 120
    assert obj.pushRight() == 0
    i18n.set("ar-EG")
    _pump()
    assert obj.effSide() == "right"
    assert obj.pushLeft() == 0
    assert obj.pushRight() == 120
    i18n.reset()
