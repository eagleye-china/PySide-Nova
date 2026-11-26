#!/usr/bin/env python3
"""render_brand_previews.py — 用 Chrome 内核复拍三枚封版徽标实拍图。

法源：docs/prescript/GUIDE_BRAND_MARK.md §7（升版 SOP 第 5 步）。
QtSvg / QSvgRenderer 不渲染 textPath 环形铭文，故必须用浏览器内核。
每次升版、SVG 版本号修正后复拍，产物带版本后缀，历史实拍按「史料不圆场」保留。

用法：
    python scripts/render_brand_previews.py
"""

from __future__ import annotations

import re
from pathlib import Path

from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]
ABOUT = ROOT / "src" / "pyside_nova" / "__about__.py"
ICONS = ROOT / "src" / "pyside_nova" / "resources" / "icons"
OUT = ROOT / "docs" / "screenshots" / "branding"

CHROME = Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe")

# 徽标 → 展示底色（单色版 / 鎏金版需深底才立得住）
MARKS = (
    ("pyside-nova-logo-sealed.svg", "#F7FAFF"),
    ("pyside-nova-logo-sealed-mono.svg", "#0F1E3D"),
    ("pyside-nova-logo-sealed-gold.svg", "#0B1730"),
)


def current_version() -> str:
    text = ABOUT.read_text(encoding="utf-8")
    return re.search(r'__version__\s*=\s*"([^"]+)"', text).group(1)


def main() -> None:
    ver = current_version()
    OUT.mkdir(parents=True, exist_ok=True)
    launch = {"headless": True}
    if CHROME.exists():
        launch["executable_path"] = str(CHROME)

    with sync_playwright() as p:
        browser = p.chromium.launch(**launch)
        page = browser.new_page(viewport={"width": 600, "height": 600},
                                device_scale_factor=1)
        for name, bg in MARKS:
            svg = (ICONS / name).read_text(encoding="utf-8")
            html = (
                '<!doctype html><html><body style="margin:0;width:600px;'
                'height:600px;display:flex;align-items:center;'
                f'justify-content:center;background:{bg}">'
                f'<div style="width:520px;height:520px">{svg}</div>'
                "</body></html>"
            )
            page.set_content(html, wait_until="load")
            stem = name[:-4]
            dest = OUT / f"{stem}_v{ver}.png"
            page.screenshot(path=str(dest))
            print(f"[ok] {dest.relative_to(ROOT)}  ({dest.stat().st_size:,} B)")
        browser.close()
    print(f"[done] 版本 v{ver} · 3 枚 Chrome 实拍完成")


if __name__ == "__main__":
    main()
