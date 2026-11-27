# tests/test_nova_markdown.py
# NovaMarkdown（1.4.0 additive 第 145 个公共类型）：静态契约 + 离屏 Qt Quick 真机验收
"""NovaMarkdown 验收。

静态层：qmldir 导出 / a11y 契约 / 冻结面签名 / 零第三方依赖 / 库组件优先 / 文档事实。
真机层：真实 QQmlEngine 加载 + QTest 事件链，覆盖解析分块、TOC、正文渲染、主题联动、
链接安全、锚点方法与空态。

坑位 69：Repeater delegate 是「视觉子项」，QObject.parent 不挂在 Repeater 下。
必须用 QQuickItem.childItems() 视觉树取证；用 QObject.children() 会误判正文未渲染。
"""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

import pytest

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS))

SRC = ROOT / "src" / "pyside_nova" / "qml" / "Nova" / "Controls" / "NovaMarkdown.qml"
QMLDIR = ROOT / "src" / "pyside_nova" / "qml" / "Nova" / "Controls" / "qmldir"
DOC = ROOT / "docs" / "controls" / "NovaMarkdown.md"
MANIFEST = ROOT / "api" / "nova-api-1.5.0.json"
PYPROJECT = ROOT / "pyproject.toml"

FINGERPRINT = "9742de8638251876"        # 1.5.0 现行冻结面
HISTORICAL_FP = "37fbbe9ab5806a2a"      # 1.4.0 史料（使用文档对比表保留，史料不圆场）

MD = (
    "# 一级标题\n\n"
    "## 安装\n\n"
    "正文 **加粗** *斜体* ~~删除线~~ `行内代码` 与 [安全链接](https://example.com)。\n\n"
    "- [x] 已完成任务\n- [ ] 待办任务\n\n"
    "| 特性 | 状态 |\n| :--- | :---: |\n| 表格 | 支持 |\n\n"
    "```python\ndef hello():\n    return 42\n```\n\n"
    "### 三级细节\n\n"
    "::: tip\n容器语法是扩展点\n:::\n\n"
    "## 安全\n\n"
    "[危险链接](javascript:alert(1))\n"
)

EXPECTED_PROPS = {
    "a11yLabel:string", "baseFontSize:int", "markdown:string",
    "openLinksExternally:bool", "outlined:bool", "ro empty:bool", "ro toc:var",
    "showToc:bool", "tocEnd:int", "tocStart:int",
}
EXPECTED_SIGNALS = {
    "linkBlocked(string url)", "linkClicked(string url)", "tocReady(var items)",
}
EXPECTED_METHODS = {"reload()", "scrollToAnchor(anchor)", "scrollToTop()"}


# ── 1. 静态契约（不建 QML 引擎）─────────────────────────────────
def test_qmldir_exports_nova_markdown():
    assert "NovaMarkdown 1.0 NovaMarkdown.qml" in QMLDIR.read_text(encoding="utf-8")


def test_a11y_registered_as_semantic():
    import check_a11y
    entry = check_a11y.CONTROLS["NovaMarkdown"]
    assert entry[0] == check_a11y.SEMANTIC
    assert entry[1] == "StaticText"


def test_frozen_api_surface_matches_exactly():
    man = json.loads(MANIFEST.read_text(encoding="utf-8"))
    assert man["apiVersion"] == "1.5.0"
    assert man["fingerprint"] == FINGERPRINT
    assert man["counts"]["total"] == 146
    info = man["types"]["Nova.Controls.NovaMarkdown"]
    assert info["a11y"] == "semantic"
    assert set(info["props"]) == EXPECTED_PROPS
    assert set(info["signals"]) == EXPECTED_SIGNALS
    assert set(info["methods"]) == EXPECTED_METHODS


def test_no_private_member_leaks_into_freeze():
    """`_` 前缀是实现自由，不得进冻结面。"""
    info = json.loads(MANIFEST.read_text(encoding="utf-8"))["types"]["Nova.Controls.NovaMarkdown"]
    leaked = [s for group in ("props", "signals", "methods") for s in info[group]
              if s.lstrip("ro ").lstrip().startswith("_")]
    assert not leaked, leaked


def test_zero_third_party_dependency():
    """构想稿的 WebEngine + markdown-it-py + Pygments 路线不得进入本库。"""
    src = SRC.read_text(encoding="utf-8")
    for forbidden in ("QtWebEngine", "QWebChannel", "markdown_it", "Pygments",
                      "nova/markdown", "import QtQuick.Controls"):
        assert forbidden not in src, f"出现外部依赖路线：{forbidden}"
    tom = PYPROJECT.read_text(encoding="utf-8")
    assert 'dependencies = ["PySide6>=6.8"]' in tom


def test_uses_library_components_and_theme_tokens():
    src = SRC.read_text(encoding="utf-8")
    for token in ("NovaScrollArea", "NovaBtn", "NovaTheme.surface",
                  "NovaTheme.textColor", "NovaTheme.primaryText",
                  "Text.MarkdownText", "pragma ComponentBehavior: Bound"):
        assert token in src, f"缺失库组件/令牌：{token}"
    assert "=>" not in src, "QML 禁用箭头函数（工作区铁律）"


def test_doc_is_current_library_doc_not_concept_draft():
    doc = DOC.read_text(encoding="utf-8")
    # 原稿独有的「可运行工程」代码块 / 发布声明 / 封版清单不得混入本库使用文档
    for stale in ("pyside-nova 0.1.0", "pip install pyside-nova[all]",
                  "from markdown_it import MarkdownIt", "class NovaMarkdownParser:",
                  "## 🎉 封版清单"):
        assert stale not in doc, f"使用文档残留构想稿内容：{stale}"
    # 但差异裁决必须如实记录（史料不圆场），对比表里允许点名 WebEngineView
    assert "WebEngineView" in doc and "史料不圆场" in doc
    for current in ("1.4.0", HISTORICAL_FP, "Text.MarkdownText", "坑位 69"):
        assert current in doc, f"使用文档缺现行事实：{current}"


# ── 2. 离屏真机（共享 qml_engine fixture）───────────────────────
QML_TEMPLATE = r"""
import QtQuick
import QtQuick.Window
import Nova.Controls
import Nova.Services
Window {
    id: win
    width: 900; height: 700; visible: true
    color: NovaTheme.page
    property int linkHits: 0
    property int blockHits: 0
    property int tocHits: 0
    property string lastUrl: ""
    NovaMarkdown {
        id: md
        objectName: "md"
        anchors.fill: parent
        anchors.margins: 20
        showToc: true
        markdown: __MD__
        onLinkClicked: function(u) { win.linkHits++; win.lastUrl = u }
        onLinkBlocked: function(u) { win.blockHits++; win.lastUrl = u }
        onTocReady: function(items) { win.tocHits++ }
    }
}
"""


@pytest.fixture(scope="module")
def md_view(qml_engine):
    from PySide6.QtCore import QObject, QUrl
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQml import QQmlComponent, QQmlExpression, qmlContext
    from PySide6.QtQuick import QQuickItem  # 提前注册，保证 QQuickItem 包装
    from PySide6.QtTest import QTest

    qml = QML_TEMPLATE.replace("__MD__", json.dumps(MD, ensure_ascii=False))
    comp = QQmlComponent(qml_engine)
    comp.setData(qml.encode("utf-8"), QUrl("qrc:/nova-markdown-test.qml"))
    win = comp.create()
    assert win is not None, [e.toString() for e in comp.errors()]
    app = QGuiApplication.instance()
    app.processEvents()
    QTest.qWait(200)

    md = win.findChild(QObject, "md")
    assert md is not None
    assert isinstance(md, QQuickItem)
    yield win, md

    # 恢复全局主题单例，避免污染后续测试模块
    QQmlExpression(qmlContext(md), md, "NovaTheme.setDark(false)").evaluate()
    app.processEvents()
    win.close()


def _visual_texts(md):
    """坑位 69 正确口径：从组件根走 QQuickItem.childItems() 视觉树。"""
    def walk(item):
        for c in item.childItems():
            yield c
            yield from walk(c)
    return [c for c in walk(md) if c.metaObject().className() == "QQuickText"]


def _qobject_texts(md):
    """错误口径（仅用于反证）：QObject.children() 看不到 Repeater delegate。"""
    def walk(o):
        for c in o.children():
            yield c
            yield from walk(c)
    return [c for c in walk(md) if c.metaObject().className() == "QQuickText"]


def test_instantiate_parse_and_toc(md_view):
    win, md = md_view
    assert md.property("empty") is False
    blocks = md.property("_blocks")
    blocks = blocks.toVariant() if hasattr(blocks, "toVariant") else blocks
    toc = md.property("toc")
    toc = toc.toVariant() if hasattr(toc, "toVariant") else toc
    assert len(blocks) == 10
    assert len(toc) == 4
    assert [t["level"] for t in toc] == [1, 2, 3, 2]
    assert all("anchor" in t and "title" in t for t in toc)
    assert win.property("tocHits") >= 1


def test_visual_tree_renders_all_blocks_and_pit_69(md_view):
    _win, md = md_view
    texts = _visual_texts(md)
    body = [t for t in texts if (t.property("width") or 0) > 200
            and (t.property("contentHeight") or 0) > 20]
    assert len(body) >= 8, f"正文块渲染不足：{len(body)}"
    assert max((t.property("contentHeight") or 0) for t in body) > 40, "表格块未渲染"
    assert any("**加粗**" in str(t.property("text") or "") for t in body), \
        "Markdown 源语法未被 MarkdownText 解析"
    # 反证：QObject 树漏掉 delegate，正是坑位 69 的成因
    assert len(_qobject_texts(md)) < len(texts), "坑位 69 反证失效，请复核视觉树口径"


def test_theme_tokens_follow_dark(md_view):
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQml import QQmlExpression, qmlContext
    from PySide6.QtTest import QTest

    _win, md = md_view
    body = [t for t in _visual_texts(md) if (t.property("width") or 0) > 200
            and (t.property("contentHeight") or 0) > 20]
    light = body[0].property("color")
    expr = QQmlExpression(qmlContext(md), md, "NovaTheme.setDark(true)")
    expr.evaluate()
    assert not expr.hasError(), expr.error()
    QGuiApplication.instance().processEvents()
    QTest.qWait(150)
    dark = body[0].property("color")
    assert light != dark, "正文颜色未随 NovaTheme 明暗联动"


def test_link_safety_and_public_methods(md_view):
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQml import QQmlExpression, qmlContext

    win, md = md_view
    ctx = qmlContext(md)
    # 关闭外部打开，避免离屏环境触发系统浏览器；同时验证该属性生效
    off = QQmlExpression(ctx, md, "md.openLinksExternally = false")
    off.evaluate()
    assert not off.hasError()

    blocks_before = win.property("blockHits")
    links_before = win.property("linkHits")

    blocked = QQmlExpression(ctx, md, "_onLink('javascript:alert(1)')")
    blocked.evaluate()
    assert not blocked.hasError()
    assert win.property("blockHits") == blocks_before + 1

    safe = QQmlExpression(ctx, md, "_onLink('https://example.com')")
    safe.evaluate()
    assert not safe.hasError()
    assert win.property("linkHits") == links_before + 1
    assert win.property("lastUrl") == "https://example.com"

    toc = md.property("toc")
    toc = toc.toVariant() if hasattr(toc, "toVariant") else toc
    for code in ("scrollToTop()", "scrollToAnchor('" + toc[1]["anchor"] + "')",
                 "reload()"):
        e = QQmlExpression(ctx, md, code)
        e.evaluate()
        assert not e.hasError(), f"{code}: {e.error()}"
    QGuiApplication.instance().processEvents()


def test_empty_state_never_blank(md_view):
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQml import QQmlExpression, qmlContext

    _win, md = md_view
    ctx = qmlContext(md)
    e = QQmlExpression(ctx, md, "md.markdown = ''")
    e.evaluate()
    assert not e.hasError()
    QGuiApplication.instance().processEvents()
    assert md.property("empty") is True
    empty_texts = [t for t in _visual_texts(md)
                   if str(t.property("text") or "") == "暂无内容"]
    assert empty_texts and empty_texts[0].property("visible") is True
    # 恢复源文本，保证 fixture 状态不被用例改写
    QQmlExpression(ctx, md, "md.markdown = " + json.dumps(MD, ensure_ascii=False)).evaluate()
