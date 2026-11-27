# tests/test_app_icons.py
# 迁移时间：星期五 2026-11-27 09:52
"""11 枚专属主题组合根的应用图标资产回归（pyside-nova 归属）。

图标从 nova-forge 迁入本仓库 ``src/pyside_nova/resources/icons/app-*.svg``，
由 nova-forge 的 ``scripts/gen_app_icons.py`` 从 ``catalog.hue`` 单一事实源生成。
本测试只校验**图标资产本身**，不导入 PySide6 / nova-forge，规避坑位 49 的
pytest 生命周期 SIGSEGV；QML 真实渲染与 DWM 调用链由 nova-forge 的离屏脚本覆盖。
"""
from __future__ import annotations

import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ICONS_DIR = ROOT / "src" / "pyside_nova" / "resources" / "icons"

# 单一事实源镜像：nova-forge/src/nova_forge/prescript/catalog.py 的 KINDS.hue
# 与 INCUBATOR_HUE；升版或调色时须同步生成脚本与本表（账实相符）。
EXPECTED_HUES: dict[str, int] = {
    "app-agent.svg": 233,
    "app-copilot.svg": 266,
    "app-de.svg": 205,
    "app-orbit.svg": 243,
    "app-desktop.svg": 223,
    "app-chat.svg": 216,
    "app-mobile.svg": 193,
    "app-flex.svg": 176,
    "app-wizard.svg": 168,
    "app-incubator.svg": 283,
    "app-aireport.svg": 258,
}


class TestElevenAppIcons(unittest.TestCase):
    """11 枚图标实体：数量 / 可解析 / 色相单一事实源 / 纯几何。"""

    def test_eleven_icons_exist_and_parse(self) -> None:
        self.assertEqual(len(EXPECTED_HUES), 11)
        self.assertEqual(len(set(EXPECTED_HUES)), 11)
        for name in EXPECTED_HUES:
            path = ICONS_DIR / name
            self.assertTrue(path.is_file(), name)
            root = ET.fromstring(path.read_text(encoding="utf-8"))
            self.assertEqual(root.tag, "{http://www.w3.org/2000/svg}svg")
            self.assertEqual(root.attrib.get("viewBox"), "0 0 256 256")

    def test_no_text_or_gradient(self) -> None:
        """QtSvg 不渲染 textPath；图标一律纯几何，且不用 QML 不可用的径向渐变。"""
        for name in EXPECTED_HUES:
            text = (ICONS_DIR / name).read_text(encoding="utf-8")
            self.assertNotIn("textPath", text, name)
            self.assertNotIn("<text", text, name)
            self.assertNotIn("gradient", text, name)

    def test_hue_matches_catalog(self) -> None:
        """每枚图标头部注释的色相必须与 catalog.hue 台账一致（账实相符）。"""
        for name, hue in EXPECTED_HUES.items():
            text = (ICONS_DIR / name).read_text(encoding="utf-8")
            self.assertIn(f"hue {hue}°", text, f"{name} 色相应为 {hue}°")

    def test_app_icon_set_is_exact(self) -> None:
        """资产目录恰好这 11 枚 app 图标，不缺不多（其余为品牌徽标）。"""
        actual = {p.name for p in ICONS_DIR.glob("app-*.svg")}
        self.assertEqual(actual, set(EXPECTED_HUES))

    def test_brand_icons_intact(self) -> None:
        """应用图标迁入不挤掉原有 3 枚正式品牌徽标。"""
        for name in (
            "pyside-nova-logo-sealed.svg",
            "pyside-nova-logo-sealed-mono.svg",
            "pyside-nova-logo-sealed-gold.svg",
        ):
            self.assertTrue((ICONS_DIR / name).is_file(), name)


if __name__ == "__main__":
    unittest.main()
