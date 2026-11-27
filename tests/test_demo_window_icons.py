# tests/test_demo_window_icons.py
# 创建时间：星期五 2026-11-27 10:15
"""11 个专属主题 demo 的原生窗口图标接线回归（静态契约）。

每个 demo 的 run.py 必须在 init_nova() 之后调用 setWindowIcon，
否则 qrc 尚未注册，QIcon 为空——标题栏/任务栏仍是 Qt 默认图标。
本文件不导入 PySide6，避开坑位 49 的 pytest 生命周期 SIGSEGV。
"""
from __future__ import annotations

import ast
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = ROOT / "examples" / "layout_shell"

MAPPING = {
    "agent": "app-agent",
    "chat": "app-chat",
    "copilot": "app-copilot",
    "de": "app-de",
    "desktop": "app-desktop",
    "flex_layout": "app-flex",
    "incubator": "app-incubator",
    "mobile": "app-mobile",
    "orbit": "app-orbit",
    "setup_wizard": "app-wizard",
    "ai_report": "app-aireport",
}


class TestDemoWindowIcons(unittest.TestCase):
    def test_each_demo_sets_window_icon_after_init_nova(self) -> None:
        for demo, alias in MAPPING.items():
            p = EXAMPLES / demo / "run.py"
            self.assertTrue(p.is_file(), demo)
            src = p.read_text(encoding="utf-8")
            tree = ast.parse(src)
            calls = [n for n in ast.walk(tree) if isinstance(n, ast.Call)]
            init_pos = [
                n.lineno for n in calls
                if isinstance(n.func, ast.Name) and n.func.id == "init_nova"
            ]
            icon_pos = [
                n.lineno for n in calls
                if isinstance(n.func, ast.Attribute) and n.func.attr == "setWindowIcon"
            ]
            self.assertTrue(init_pos, f"{demo}: no init_nova()")
            self.assertTrue(icon_pos, f"{demo}: no setWindowIcon()")
            self.assertLess(init_pos[0], icon_pos[0], f"{demo}: qrc 注册前设图标，QIcon 会为空")
            self.assertIn(f":/icons/{alias}", src, demo)

    def test_no_invalid_qml_window_icon(self) -> None:
        """ApplicationWindow 无 icon 属性，QML 赋值会让整个 demo 加载失败。"""
        for demo in MAPPING:
            qml = (EXAMPLES / demo / "main.qml").read_text(encoding="utf-8")
            self.assertNotIn('icon: "qrc:/icons/', qml, demo)

    def test_application_window_present(self) -> None:
        for demo in MAPPING:
            qml = (EXAMPLES / demo / "main.qml").read_text(encoding="utf-8")
            self.assertIn("ApplicationWindow {", qml, demo)


if __name__ == "__main__":
    unittest.main()
