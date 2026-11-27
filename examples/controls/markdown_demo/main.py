# examples/controls/markdown_demo/main.py
"""NovaMarkdown 独立演示启动器。

运行::

    python examples/controls/markdown_demo/main.py
    python examples/controls/markdown_demo/main.py --doc path/to/your.md
    python examples/controls/markdown_demo/main.py --list

设计要点（与 docs/controls/NovaMarkdown.md 账实同源）：

* 示例文档是磁盘上真实的 ``docs/*.md`` 文件，由本启动器读取后注入 QML 上下文，
  不在 QML 里硬编码长字符串 —— 文档改了，demo 立刻跟着变。
* 最后一篇固定注入库自身的 ``docs/controls/NovaMarkdown.md``（dogfooding）：
  用 NovaMarkdown 渲染 NovaMarkdown 自己的使用文档。
* 只依赖 PySide6 与 pyside_nova，与组件「零第三方依赖」口径一致。

依赖：conda ``pyside6_nova`` 环境（PySide6 6.8+ 与编辑态 pyside_nova）。
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyside_nova import init_nova

DEMO_DIR = Path(__file__).resolve().parent
DOCS_DIR = DEMO_DIR / "docs"


def find_repo_root() -> Path:
    """向上探测含 ``src/pyside_nova`` 的仓库根。

    demo 目录可能被整理到 ``examples/`` 下的任意层级（如
    ``examples/controls/markdown_demo/``，与 ``examples/layout_shell/`` 同级）。
    固定写死 ``parents[1]`` 会在多一层分类目录时把根算成 ``examples/``，
    导致 dogfooding 文档与离线图标根双双丢失 —— 故改为按标志目录探测。
    """
    for candidate in (DEMO_DIR, *DEMO_DIR.parents):
        if (candidate / "src" / "pyside_nova").is_dir():
            return candidate
    return DEMO_DIR.parents[-1]


REPO_ROOT = find_repo_root()
SELF_DOC = REPO_ROOT / "docs" / "controls" / "NovaMarkdown.md"


def _title_from(text: str, fallback: str) -> str:
    """取首个 H1 作为列表标题；没有 H1 时回落到文件名（账实同源）。"""
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("# "):
            return stripped[2:].strip()
    return fallback


def collect_docs() -> tuple[list[str], list[str]]:
    """收集内置示例文档，返回 (标题列表, 正文列表)，两个列表逐位对应。"""
    titles: list[str] = []
    texts: list[str] = []
    for path in sorted(DOCS_DIR.glob("*.md")):
        body = path.read_text(encoding="utf-8")
        titles.append(_title_from(body, path.stem))
        texts.append(body)

    # dogfooding：用被演示的组件渲染它自己的使用文档
    if SELF_DOC.is_file():
        titles.append("组件自述 · NovaMarkdown.md")
        texts.append(SELF_DOC.read_text(encoding="utf-8"))
    return titles, texts


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="markdown_demo",
        description="NovaMarkdown 文档渲染器独立演示",
    )
    parser.add_argument(
        "--doc", type=Path, action="append", default=[], metavar="PATH",
        help="追加一篇外部 .md 文档（可重复指定）",
    )
    parser.add_argument(
        "--list", action="store_true", help="只列出将加载的文档标题，不启动窗口",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    titles, texts = collect_docs()

    for path in args.doc:
        if not path.is_file():
            print(f"文档不存在：{path}", file=sys.stderr)
            return 2
        body = path.read_text(encoding="utf-8")
        titles.append(_title_from(body, path.stem))
        texts.append(body)

    if args.list:
        for i, title in enumerate(titles, 1):
            print(f"{i:>2}. {title}  ({len(texts[i - 1])} 字符)")
        return 0

    app = QGuiApplication(sys.argv)
    app.setApplicationName("nova-markdown-demo")

    engine = QQmlApplicationEngine()
    init_nova(engine)  # 注册 Nova.* QML 模块（单引擎，坑位 42）

    ctx = engine.rootContext()
    # 注意：只注入字符串列表（QVariantList），不注入 list[dict]。
    # PySide6 的 QVariantList 在 QML 侧 Array.isArray() 为 False，而 NovaBtnToggle
    # 的 options 归一化正好用 Array.isArray 判定 —— 注入 list[dict] 会让控件高度塌成 0。
    # 选项数组改在 main.qml 里用真正的 JS 数组构造（见 docPicker.options）。
    ctx.setContextProperty("demoTitles", titles)
    ctx.setContextProperty("demoTexts", texts)

    # 仓库根存在 icons/（fetch_icons.py 产出）时启用离线图标通道
    icons_dir = REPO_ROOT / "icons"
    if (icons_dir / "mdi").is_dir():
        ctx.setContextProperty("novaIconLocalRoot", icons_dir.as_uri())

    engine.load(str(DEMO_DIR / "main.qml"))
    if not engine.rootObjects():
        return 1
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
