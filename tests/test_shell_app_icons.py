# tests/test_shell_app_icons.py
# 创建时间：星期五 2026-11-27 10:05
"""11 个专属主题组合根的应用图标接线回归（A 方案 · 零冻结面漂移）。

纯静态契约：私有 _appIcon 属性 + 库内 NovaIcon 徽记（img: 图片直出通道）+ qrc 资源可读。
真实异步加载由 ``scripts`` 离屏实跑覆盖（本文件不导入 PySide6 渲染栈，
避免坑位 49 的 pytest 生命周期 SIGSEGV）。
"""
from __future__ import annotations

import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHELLS = ROOT / "src" / "pyside_nova" / "qml" / "Nova" / "Composite" / "LayoutShell"
QRC = ROOT / "src" / "pyside_nova" / "resources" / "resources.qrc"

MAPPING = {
    "NovaAgent": "app-agent",
    "NovaIncubator": "app-incubator",
    "NovaCopilot": "app-copilot",
    "NovaDE": "app-de",
    "NovaOrbit": "app-orbit",
    "NovaDesktop": "app-desktop",
    "NovaChat": "app-chat",
    "NovaMobile": "app-mobile",
    "NovaFlexLayout": "app-flex",
    "NovaSetupWizard": "app-wizard",
    "NovaAIReport": "app-aireport",
}


class TestShellAppIcons(unittest.TestCase):
    def test_each_shell_has_private_icon_property(self) -> None:
        for shell, alias in MAPPING.items():
            text = (SHELLS / f"{shell}.qml").read_text(encoding="utf-8")
            # 私有 _ 前缀：不进 API 冻结面
            self.assertIn("readonly property url _appIcon", text, shell)
            self.assertIn(f'"qrc:/icons/{alias}"', text, shell)

    def test_each_shell_uses_nova_icon(self) -> None:
        """徽记用库内 NovaIcon 的 img: 图片直出通道，保留彩色。"""
        for shell in MAPPING:
            text = (SHELLS / f"{shell}.qml").read_text(encoding="utf-8")
            self.assertIn("NovaIcon {", text, shell)
            self.assertIn('icon: "img:" + root._appIcon', text, shell)
            self.assertIn("monochrome: false", text, shell)
            self.assertIn("import Nova.Controls", text, shell)

    def test_no_bare_image_badge(self) -> None:
        """徽记必须用库内 NovaIcon，不引入裸 Image / NovaImg 直出。"""
        for shell in MAPPING:
            text = (SHELLS / f"{shell}.qml").read_text(encoding="utf-8")
            self.assertIn("id: _appBadge", text, shell)
            self.assertNotIn("fillMode: Image.PreserveAspectFit", text, shell)
            self.assertNotIn("src: root._appIcon", text, shell)

    def test_qrc_registers_all_eleven_aliases(self) -> None:
        qrc = ET.parse(QRC).getroot()
        aliases = {
            el.get("alias")
            for qres in qrc.findall("qresource")
            for el in qres.findall("file")
        }
        for shell, alias in MAPPING.items():
            self.assertIn(alias, aliases, shell)

    def test_frozen_surface_untouched(self) -> None:
        """A 方案承诺：组件只加私有属性，公共配置属性数量不变。"""
        for shell in MAPPING:
            text = (SHELLS / f"{shell}.qml").read_text(encoding="utf-8")
            self.assertNotIn("property url appIcon", text, shell)
            self.assertNotIn("property url icon", text, shell)


if __name__ == "__main__":
    unittest.main()
