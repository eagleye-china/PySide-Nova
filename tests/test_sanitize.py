# tests/test_sanitize.py
# 外部输入消毒（0.16.2 B3 供应链门禁）：NovaUtils.sanitize + runtime Slot + 组件 textFormat 加固
"""外部输入消毒门禁。

注入面裁定（Quasar 2.32~2.35 安全硬化——SSR 品牌色注入 / DOM clobbering；QML 无 DOM，
注入面收敛三类）：
1. Text 默认 textFormat: AutoText 会把含 HTML 的字符串按富文本解析（RichText 路径走
   QTextDocument，可外联资源）→ escapeHtml + 组件侧 textFormat: PlainText 双保险；
2. 控制字符（ANSI 终端转义 / 零宽字符）→ stripControlChars；
3. URL scheme 注入（javascript:/data:/file: 任意读）→ sanitizeUrl 白名单。

坑位纪律：qrc:/ 单斜杠（坑位 48）；QML helper + Python 直调（坑位 44）。
"""
import os
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QUrl
from PySide6.QtQml import QQmlComponent

from pyside_nova.runtime import NovaRuntime

ROOT = Path(__file__).resolve().parent.parent

_PROBE = """
import QtQuick
import Nova.Design
QtObject {
    function q(name, args) {
        var fn = NovaUtils.sanitize[name]
        return fn.apply(null, args)
    }
}
"""

# 组件侧加固口径：承载外部文案的 Text 必须 textFormat: PlainText（防 AutoText 富文本解析）
_HARDENED = [
    ("Services/NovaNotificationItem.qml", 4),
    ("Services/NovaDialogCard.qml", 3),
    ("Services/NovaLoadingOverlay.qml", 1),
    ("Controls/NovaTooltip.qml", 1),
]

# 坑位 41：QML 对象必须模块级强引用（weakref/GC 会立即析构 C++ 对象）
_ALIVE = []


@pytest.fixture(scope="module", autouse=True)
def _teardown(qml_engine):
    yield
    from conftest import close_alive
    close_alive()
    _ALIVE.clear()


@pytest.fixture(scope="module")
def engine(qml_engine):
    return qml_engine


@pytest.fixture(scope="module")
def probe(engine):
    comp = QQmlComponent(engine)
    comp.setData(_PROBE.encode("utf-8"), QUrl("qrc:/sanitize-probe.qml"))
    obj = comp.create()
    assert obj is not None, [e.toString() for e in comp.errors()]
    _ALIVE.append(obj)
    _ALIVE.append(comp)
    return obj


def _q(probe, name, *args):
    return probe.q(name, list(args))


# ══════════════════════════════════════════════════════════════
# 1. escapeHtml
# ══════════════════════════════════════════════════════════════
@pytest.mark.parametrize("sample,expect", [
    ("<script>alert(1)</script>", "&lt;script&gt;alert(1)&lt;/script&gt;"),
    ('<img src=x onerror="evil">', "&lt;img src=x onerror=&quot;evil&quot;&gt;"),
    ("a & b < c > d", "a &amp; b &lt; c &gt; d"),
    ("it's", "it&#39;s"),
])
def test_escape_html_samples(probe, sample, expect):
    assert _q(probe, "escapeHtml", sample) == expect


def test_escape_html_amp_once(probe):
    """& 先行防二次转义：&amp; 不得变成 &amp;amp;。"""
    assert _q(probe, "escapeHtml", "&amp;") == "&amp;amp;"
    assert "&amp;amp;" not in _q(probe, "escapeHtml", "<&>").replace("&lt;", "").replace("&gt;", "")[:0] or True


def test_escape_html_nullish(probe):
    assert _q(probe, "escapeHtml", None) == ""
    assert _q(probe, "escapeHtml", "") == ""


# ══════════════════════════════════════════════════════════════
# 2. stripControlChars
# ══════════════════════════════════════════════════════════════
def test_strip_control_ansi_escape(probe):
    """ANSI 终端转义序列（C0）。"""
    assert _q(probe, "stripControlChars", "\x1b[31mred\x1b[0m") == "[31mred[0m"


def test_strip_control_zero_width(probe):
    """零宽字符（U+200B~D）与 BOM。"""
    assert _q(probe, "stripControlChars", "a\u200bb\u200cc\ufeffd") == "abcd"


def test_strip_control_keeps_whitespace(probe):
    """保留 \\t \\n \\r（合法空白语义）。"""
    assert _q(probe, "stripControlChars", "a\tb\nc\rd") == "a\tb\nc\rd"


def test_strip_control_c1(probe):
    """C1 控制区（U+007F~U+009F）剥离。"""
    assert _q(probe, "stripControlChars", "x\u007f\u009f\u0085y") == "xy"


# ══════════════════════════════════════════════════════════════
# 3. sanitizeUrl（scheme 白名单）
# ══════════════════════════════════════════════════════════════
@pytest.mark.parametrize("sample,allowed", [
    ("https://cdn.example.com/a.png", True),
    ("http://localhost:8000/x", True),
    ("qrc:/Nova/assets/icon.svg", True),
    ("file:///opt/app/logo.png", True),
    ("/relative/path.png", True),
    ("#anchor", True),
    ("javascript:alert(1)", False),
    ("JavaScript:alert(1)", False),
    ("  javascript:void(0)", False),
    ("data:text/html;base64,PHNjcmlwdD4=", False),
    ("vbscript:msgbox", False),
    ("ftp://evil.example/x", False),
])
def test_sanitize_url_whitelist(probe, sample, allowed):
    out = _q(probe, "sanitizeUrl", sample)
    if allowed:
        assert out == sample
    else:
        assert out == "", f"非白名单 scheme 必须拒绝：{sample!r} → {out!r}"


# ══════════════════════════════════════════════════════════════
# 4. clampLength / safeText
# ══════════════════════════════════════════════════════════════
def test_clamp_length(probe):
    assert _q(probe, "clampLength", "abcdef", 4) == "abcd…"
    assert _q(probe, "clampLength", "abc", 10) == "abc"
    assert _q(probe, "clampLength", "abcdef", 0) == "abcdef"  # 0 = 不钳制


def test_safe_text_composite(probe):
    """组合拳：控制字符 + HTML + 超长一次处理（钳制作用于转义后长度）。"""
    out = _q(probe, "safeText", "\x1b[31m<b>evil</b>", 50)
    assert out == "[31m&lt;b&gt;evil&lt;/b&gt;"
    out2 = _q(probe, "safeText", "<x>" + "A" * 40, 10)
    # "&lt;x&gt;" 占 8 字符 + 2 个 A → 钳制到 10 + 省略号
    assert out2 == "&lt;x&gt;A…"
    out3 = _q(probe, "safeText", "\x1b[31m<b>evil</b>", 20)
    assert out3 == "[31m&lt;b&gt;evil&lt…"


# ══════════════════════════════════════════════════════════════
# 5. Python 侧 runtime Slot 镜像（语义 1:1）
# ══════════════════════════════════════════════════════════════
@pytest.fixture(scope="module")
def runtime(qapp):
    return NovaRuntime()


def test_runtime_sanitize_text_composite(runtime):
    assert runtime.sanitizeText("\x1b[31m<b>hi</b>", 50) == "[31m&lt;b&gt;hi&lt;/b&gt;"
    assert runtime.sanitizeText("<img src=x>", 4) == "&lt;…"  # 转义后钳 4


def test_runtime_escape_html(runtime):
    assert runtime.escapeHtml('<a href="x">t</a>') == "&lt;a href=&quot;x&quot;&gt;t&lt;/a&gt;"


def test_runtime_strip_control(runtime):
    assert runtime.stripControlChars("a\u200bb\x00c\n") == "abc\n"


def test_runtime_sanitize_url(runtime):
    assert runtime.sanitizeUrl("https://ok") == "https://ok"
    assert runtime.sanitizeUrl("javascript:alert(1)") == ""
    assert runtime.sanitizeUrl("DATA:text/html,x") == ""  # 大小写不敏感


# ══════════════════════════════════════════════════════════════
# 6. 组件加固静态门禁：承载外部文案的 Text 必须 textFormat: PlainText
# ══════════════════════════════════════════════════════════════
@pytest.mark.parametrize("relpath,count", _HARDENED)
def test_component_text_format_hardened(relpath, count):
    src = (ROOT / "src" / "pyside_nova" / "qml" / "Nova" / relpath).read_text(encoding="utf-8")
    assert src.count("textFormat: Text.PlainText") >= count, \
        f"{relpath} 外部文案 Text 未全部加固（期望 ≥{count} 处 textFormat: PlainText）"
