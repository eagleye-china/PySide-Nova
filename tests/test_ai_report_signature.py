# tests/test_ai_report_signature.py
"""第 11 套专属主题 / 应用图标 / 暗色标题栏的静态契约回归（1.11.0 · 2026-11-28）。

覆盖三件事：
1. ``NovaAIReport.qml`` 与其余 10 个组合根逐项同构（``_signatureOn`` 二态 +
   ``_accent/_ink/_inkSoft/_glow`` + ``_appIcon``/``NovaIcon`` 徽记），且全为
   ``_`` 私有令牌 —— 公共面 / 冻结指纹零漂移。
2. ``app-aireport.svg`` 在 pyside-nova 与 nova-forge 两工程字节一致，色相台账
   与 QML ``_themeHue`` 偏移账实相符。
3. ``examples/layout_shell/ai_report/`` 的 ``darkChromeChanged(bool)`` →
   自包含 DWM helper → 原生标题栏同步链路完整。

纯静态 / 纯文本校验，全程不导入 PySide6，规避坑位 49 的 pytest 生命周期 SIGSEGV。
"""
from __future__ import annotations

import ast
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FORGE = ROOT.parent / "nova-forge"
SHELLS = ROOT / "src" / "pyside_nova" / "qml" / "Nova" / "Composite" / "LayoutShell"
NOVA_ICONS = ROOT / "src" / "pyside_nova" / "resources" / "icons"
FORGE_ICONS = FORGE / "src" / "nova_forge" / "resources" / "icons"
DEMO = ROOT / "examples" / "layout_shell" / "ai_report"

TEN_SHELLS = (
    "NovaAgent", "NovaChat", "NovaCopilot", "NovaDE", "NovaDesktop",
    "NovaFlexLayout", "NovaIncubator", "NovaMobile", "NovaOrbit", "NovaSetupWizard",
)


class TestEleventhSignatureTheme(unittest.TestCase):
    """NovaAIReport 与其余 10 壳的专属主题形态同构。"""

    def setUp(self) -> None:
        self.text = (SHELLS / "NovaAIReport.qml").read_text(encoding="utf-8")
        self.peers = {
            name: (SHELLS / f"{name}.qml").read_text(encoding="utf-8")
            for name in TEN_SHELLS
        }

    def test_all_eleven_have_signature_switch(self) -> None:
        for name, text in {**self.peers, "NovaAIReport": self.text}.items():
            self.assertIn("property bool _signatureOn: true", text, name)
            self.assertIn("root._signatureOn", text, name)
            self.assertIn(": NovaTheme.primary.hsvHue", text, name)

    def test_ai_report_theme_tokens(self) -> None:
        text = self.text
        for token in ("_themeHue", "_accent", "_ink", "_inkSoft", "_glow"):
            self.assertIn(f"property color {token}" if token != "_themeHue"
                          else "property real _themeHue", text, token)
        self.assertIn("+ 0.0694", text)                       # 专属偏移 258°
        self.assertIn("readonly property color _ink: root._accent", text)
        self.assertIn("Qt.lighter(root._accent, 1.35)", text)
        self.assertIn("NovaTheme.isDark ? 1.22 : 1", text)     # 暗色提亮
        self.assertIn("NovaTheme.isDark ? 1.5 : 1.25", text)   # Aurora 亮核

    def test_private_only_no_public_theme_api(self) -> None:
        """不得把主题 / 图标升为公共 API（须 CSA 拍板 + additive minor 重签）。"""
        text = self.text
        for banned in ("property bool signatureOn", "property string themeMode",
                       "property url appIcon", "property url icon"):
            self.assertNotIn(banned, text)

    def test_app_icon_badge(self) -> None:
        text = self.text
        self.assertIn('readonly property url _appIcon: "qrc:/icons/app-aireport"', text)
        self.assertIn("NovaIcon {", text)
        self.assertIn('icon: "img:" + root._appIcon', text)
        self.assertIn("monochrome: false", text)
        self.assertIn("id: _appBadge", text)
        self.assertIn("import Nova.Controls", text)


class TestEleventhIconAsset(unittest.TestCase):
    """第 11 枚图标：两工程镜像、色相台账、qrc 注册。"""

    def test_mirrored_byte_identical(self) -> None:
        nova = (NOVA_ICONS / "app-aireport.svg").read_bytes()
        forge = (FORGE_ICONS / "app-aireport.svg").read_bytes()
        self.assertEqual(nova, forge)
        self.assertIn(b"hue 258", nova)

    def test_svg_parseable_and_pure_geometry(self) -> None:
        text = (NOVA_ICONS / "app-aireport.svg").read_text(encoding="utf-8")
        root = ET.fromstring(text)
        self.assertEqual(root.attrib.get("viewBox"), "0 0 256 256")
        for banned in ("<text", "textPath", "gradient"):
            self.assertNotIn(banned, text)

    def test_hue_matches_qml_offset(self) -> None:
        """233° 基准 + 0.0694×360 ≈ 25° → 258°，QML 与图标头部注释逐字一致。"""
        offset_deg = 0.0694 * 360
        self.assertAlmostEqual(233 + offset_deg, 258.0, delta=0.5)
        self.assertIn("+ 0.0694", (SHELLS / "NovaAIReport.qml").read_text(encoding="utf-8"))
        self.assertIn("hue 258°", (NOVA_ICONS / "app-aireport.svg").read_text(encoding="utf-8"))

    def test_qrc_aliases_in_both_projects(self) -> None:
        for qrc, alias in (
            (ROOT / "src" / "pyside_nova" / "resources" / "resources.qrc", "app-aireport"),
            (FORGE / "src" / "nova_forge" / "resources" / "resources.qrc", "app-aireport.svg"),
        ):
            tree = ET.parse(qrc).getroot()
            aliases = {
                el.get("alias")
                for res in tree.findall("qresource")
                for el in res.findall("file")
            }
            self.assertIn(alias, aliases, qrc.name)


class TestDarkChromeWiring(unittest.TestCase):
    """ai_report demo：暗色主题 → 原生标题栏同步（QML 信号 + 自包含 DWM helper）。"""

    def setUp(self) -> None:
        self.qml = (DEMO / "main.qml").read_text(encoding="utf-8")
        self.runner = (DEMO / "run.py").read_text(encoding="utf-8")

    def test_qml_signal_and_single_on_completed(self) -> None:
        qml = self.qml
        self.assertIn("signal darkChromeChanged(bool dark)", qml)
        self.assertIn("darkChromeChanged(win.themeMode === \"signature\")", qml)
        self.assertIn("darkChromeChanged(true)", qml)
        # 坑位：不得新增第二个 Component.onCompleted（会触发 Property value set multiple times）
        self.assertEqual(qml.count("Component.onCompleted:"), 1)

    def test_shell_signature_bound_to_theme(self) -> None:
        self.assertIn("_signatureOn: win.themeMode === \"signature\"", self.qml)

    def test_runner_self_contained_dwm_helper(self) -> None:
        runner = self.runner
        tree = ast.parse(runner)
        funcs = {n.name for n in tree.body if isinstance(n, ast.FunctionDef)}
        self.assertIn("_sync_title_bar", funcs)
        for needle in ("darkChromeChanged.connect", "QTimer.singleShot(10",
                       "DwmSetWindowAttribute", "20", "19",
                       "QGuiApplication.topLevelWindows()"):
            self.assertIn(needle, runner, needle)

    def test_window_icon_after_init_nova(self) -> None:
        runner = self.runner
        tree = ast.parse(runner)
        calls = [n for n in ast.walk(tree) if isinstance(n, ast.Call)]
        init_pos = [n.lineno for n in calls
                    if isinstance(n.func, ast.Name) and n.func.id == "init_nova"]
        icon_pos = [n.lineno for n in calls
                    if isinstance(n.func, ast.Attribute) and n.func.attr == "setWindowIcon"]
        self.assertTrue(init_pos)
        self.assertTrue(icon_pos)
        self.assertLess(init_pos[0], icon_pos[0], "qrc 注册前设图标，QIcon 会为空")
        self.assertIn(':/icons/app-aireport', runner)

    def test_no_qml_window_icon(self) -> None:
        """ApplicationWindow 无 icon 属性，QML 赋值会让整个 demo 加载失败。"""
        self.assertNotIn('icon: "qrc:/icons/', self.qml)


if __name__ == "__main__":
    unittest.main()
