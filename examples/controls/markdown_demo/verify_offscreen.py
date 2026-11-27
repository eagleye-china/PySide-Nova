# examples/markdown_demo/verify_offscreen.py
"""NovaMarkdown demo 离屏真机自检（非 pytest，供手工验收与 CI 复核）。

运行::

    QT_QPA_PLATFORM=offscreen python examples/controls/markdown_demo/verify_offscreen.py

验收口径与 docs/controls/NovaMarkdown.md §9 一致：
真实 QQmlApplicationEngine 加载 main.qml、视觉树取证（坑位 69 用 childItems）、
交互事件链触发三信号、截图，且 0 条坏 Qt 消息。
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QPA_FONTDIR", "C:/Windows/Fonts")

from PySide6.QtCore import QEventLoop, QObject, QTimer
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QQmlExpression, qmlContext
from PySide6.QtQuick import QQuickItem, QQuickWindow
from shiboken6 import getCppPointer, wrapInstance

from pyside_nova import init_nova

sys.path.insert(0, str(Path(__file__).resolve().parent))
import main as demo_main

DEMO_DIR = Path(__file__).resolve().parent
ROOT = demo_main.find_repo_root()   # 与 main.py 同源：向上探测，不写死层数
SHOT = Path(os.environ.get("NOVA_DEMO_SHOT", str(DEMO_DIR / "markdown_demo.png")))
SHOT_DARK = DEMO_DIR / "markdown_demo_dark.png"
SHOT_TABLE = DEMO_DIR / "markdown_demo_table.png"   # T22：GFM 表格 Grid 自绘取证

MESSAGES: list[str] = []


def _handler(msg_type, context, message):
    text = str(message)
    MESSAGES.append(text)
    # 只把 error / 严重告警当坏消息；offscreen 下字体/平台的说明性 info 忽略
    low = text.lower()
    if any(k in low for k in ("error", "failed", "cannot ", "undefined", "is not defined",
                              "referenceerror", "typeerror", "syntax error", "binding loop",
                              "cannot assign", "invalid property")):
        BAD.append(text)


BAD: list[str] = []


def qeval(root: QObject, expr: str):
    ctx = qmlContext(root)
    e = QQmlExpression(ctx, root, expr)
    value, undefined = e.evaluate()
    if e.hasError():
        raise RuntimeError(f"QQmlExpression 求值失败: {expr} -> {e.error().toString()}")
    return None if undefined else value


def visual_stats(item: QQuickItem) -> dict:
    """坑位 69：Repeater delegate 是视觉子项，必须走 childItems() 而非 QObject.children()。"""
    texts = 0
    stack = [item]
    while stack:
        cur = stack.pop()
        for child in cur.childItems():
            if child.metaObject().className() == "QQuickText":
                texts += 1
            stack.append(child)
    return {"QQuickText": texts}


def main() -> int:
    from PySide6.QtCore import qInstallMessageHandler
    qInstallMessageHandler(_handler)

    titles, texts = demo_main.collect_docs()

    app = QGuiApplication(sys.argv)
    app.setApplicationName("nova-markdown-demo-verify")
    engine = QQmlApplicationEngine()
    init_nova(engine)
    ctx = engine.rootContext()
    # 与 main.py 一致：只注入字符串列表，选项数组由 main.qml 用真正 JS 数组构造
    ctx.setContextProperty("demoTitles", titles)
    ctx.setContextProperty("demoTexts", texts)
    icons = ROOT / "icons"
    if (icons / "mdi").is_dir():
        ctx.setContextProperty("novaIconLocalRoot", icons.as_uri())

    engine.load(str(DEMO_DIR / "main.qml"))
    roots = engine.rootObjects()
    if not roots:
        print("FAIL: QML 未加载出根对象", file=sys.stderr)
        return 1
    root = roots[0]

    # 让渲染跑几帧，确保 Repeater delegate / 绑定全部就位
    loop = QEventLoop()
    QTimer.singleShot(350, loop.quit)
    loop.exec()

    print("== 加载事实 ==")
    print("  roots        :", len(roots))
    print("  文档篇数     :", len(titles), "→", [t[:14] for t in titles])
    print("  markdown 字符:", qeval(root, "doc.markdown.length"))
    print("  toc 条目     :", qeval(root, "doc.toc.length"))
    print("  empty        :", qeval(root, "doc.empty"))
    print("  showToc      :", qeval(root, "doc.showToc"))
    print("  tocEnd       :", qeval(root, "doc.tocEnd"))
    print("  baseFontSize :", qeval(root, "doc.baseFontSize"))
    print("  isDark       :", qeval(root, "NovaTheme.isDark"))
    print("  事件流条数   :", qeval(root, "st.events.length"))
    print("  文档切换器   : 选项", qeval(root, "docPicker._normalized.length"),
          "项 / 高", qeval(root, "docPicker.height"),
          "（防 QVariantList → Array.isArray=False 塌陷回归）")

    content = root.contentItem() if isinstance(root, QQuickWindow) else None
    if content is None:
        qwin = wrapInstance(getCppPointer(root)[0], QQuickWindow)
        content = qwin.contentItem()
    print("  视觉树       :", visual_stats(content))

    qwin = wrapInstance(getCppPointer(root)[0], QQuickWindow)

    # ── 默认态截图：加载完成即拍，事件流天然只有初始 tocReady，无交互残留 ──
    img = qwin.grabWindow()
    ok_img = img.save(str(SHOT))
    print("== 截图（默认态 · 亮色 / 第 1 篇） ==")
    print("  路径:", SHOT, "| 尺寸:", img.width(), "x", img.height(), "| 保存:", ok_img)

    # ── T22 增益取证：滚到「能力矩阵」，拍 GFM 表格逐格 Grid 自绘 ──
    qeval(root, "doc.scrollToAnchor(doc.toc[2].anchor)")
    QTimer.singleShot(250, loop.quit)
    loop.exec()
    img_table = qwin.grabWindow()
    ok_table = img_table.save(str(SHOT_TABLE))
    print("== 截图（T22 · GFM 表格 Grid 自绘 / 第 1 篇「能力矩阵」） ==")
    print("  路径:", SHOT_TABLE, "| 尺寸:", img_table.width(), "x", img_table.height(),
          "| 保存:", ok_table)
    qeval(root, "doc.scrollToTop()")

    # ── 交互事件链 ────────────────────────────────────────────
    print("== 交互事件链 ==")
    qeval(root, "doc._onLink('https://example.com/safe')")
    print("  安全链接后 linkClicked 计数:", qeval(root, "st.clickedCount"))
    qeval(root, "doc._onLink('javascript:alert(1)')")
    print("  危险协议后 blocked 计数   :", qeval(root, "st.blockedCount"))
    # 走 NovaBtnToggle 的编程通道 select()，让「选中态」与 st.docIndex 同步（账实同源）
    qeval(root, "tocLevelPicker.select(6)")
    print("  tocEnd=6 后大纲条目       :", qeval(root, "doc.toc.length"))
    qeval(root, "NovaTheme.setDark(true)")
    print("  暗色后 isDark             :", qeval(root, "NovaTheme.isDark"))
    qeval(root, "NovaTheme.setDark(false)")
    qeval(root, "docPicker.select(2)")
    print("  切到第 3 篇文档字符数     :", qeval(root, "doc.markdown.length"))
    qeval(root, "doc.scrollToAnchor(doc.toc[0].anchor)")
    qeval(root, "doc.scrollToTop()")
    qeval(root, "doc.reload()")
    qeval(root, "st.cleared = true")
    print("  清空后 empty              :", qeval(root, "doc.empty"))
    qeval(root, "st.cleared = false")
    print("  恢复后 empty              :", qeval(root, "doc.empty"))
    qeval(root, "docPicker.select(3)")  # dogfooding：组件自述
    print("  dogfooding toc 条目       :", qeval(root, "doc.toc.length"))

    # ── 暗色交互态：切到安全演练，触发拦截事件，展示三信号 + 明暗联动 ──
    qeval(root, "NovaTheme.setDark(true)")
    qeval(root, "docPicker.select(2)")
    qeval(root, "tocLevelPicker.select(3)")
    qeval(root, "doc._onLink('javascript:alert(1)')")
    qeval(root, "doc._onLink('https://example.com/safe')")
    qeval(root, "doc._onLink('file:///C:/Windows/win.ini')")
    QTimer.singleShot(250, loop.quit)
    loop.exec()
    img_dark = qwin.grabWindow()
    ok_dark = img_dark.save(str(SHOT_DARK))
    print("== 截图（交互态 · 暗色 / 安全演练） ==")
    print("  路径:", SHOT_DARK, "| 尺寸:", img_dark.width(), "x", img_dark.height(), "| 保存:", ok_dark)

    print("== Qt 消息 ==")
    print("  总消息:", len(MESSAGES), "| 坏消息:", len(BAD))
    for m in BAD[:10]:
        print("   BAD:", m[:220])

    picker_opts = qeval(root, "docPicker._normalized.length")
    picker_h = qeval(root, "docPicker.height")
    passed = (len(roots) == 1 and len(BAD) == 0 and ok_img and ok_dark and ok_table
              and qeval(root, "doc.toc.length") > 0
              and picker_opts == len(titles) and picker_h > 0)
    print("== 结论 ==", "PASS" if passed else "FAIL")
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
