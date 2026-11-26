#!/usr/bin/env python3
"""sync_brand_version.py — 升版时同步徽标 SVG 内的版本号字样。

法源：CSA 2026-11-26 14:37「这是 SVG 文件，每次升版时记得把 SVG 文件的
版本号也得修正」；规范见 docs/prescript/GUIDE_BRAND_MARK.md §7。

徽标是 SVG 文本，缎带 / 下弧刻的是**当前包版本**（不是 API 契约版本）。
每次升版——包括 patch——必须同步修正，否则账实不符。
本脚本从 __about__.py（唯一版本源）读取版本，批量替换三枚正式徽标与
文档站副本里的版本字样；--check 供门禁机检，防止漏改。

用法：
    python scripts/sync_brand_version.py            # 写入（源 + 站点副本）
    python scripts/sync_brand_version.py --check   # 只校验，不写文件
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ABOUT = ROOT / "src" / "pyside_nova" / "__about__.py"
ICONS = ROOT / "src" / "pyside_nova" / "resources" / "icons"
BRAND = ROOT / "docs" / "assets" / "brand"

NAMES = (
    "pyside-nova-logo-sealed.svg",
    "pyside-nova-logo-sealed-mono.svg",
    "pyside-nova-logo-sealed-gold.svg",
)

# 缎带：SEALED · API 1.2 / SEALED · v1.2.3 / SEALED · 1.2 → SEALED · v{ver}
PAT_RIBBON = re.compile(r"SEALED\s*·\s*(?:API\s*)?v?\d+(?:\.\d+)*")
# 下弧：FLAGSHIP SEAL · v1.2 / · 1.2.3 → FLAGSHIP SEAL · v{ver}
PAT_ARC = re.compile(r"(FLAGSHIP SEAL\s*·\s*)v?\d+(?:\.\d+)*")


def current_version() -> str:
    text = ABOUT.read_text(encoding="utf-8")
    m = re.search(r'__version__\s*=\s*"([^"]+)"', text)
    if not m:
        raise RuntimeError(f"无法从 {ABOUT} 读取 __version__")
    return m.group(1)


def normalize(svg: str, ver: str) -> str:
    svg = PAT_RIBBON.sub(f"SEALED · v{ver}", svg)
    svg = PAT_ARC.sub(lambda m: m.group(1) + f"v{ver}", svg)
    return svg


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true", help="只校验，不写文件")
    args = ap.parse_args()

    ver = current_version()
    problems: list[str] = []
    changed: list[str] = []

    for name in NAMES:
        src = ICONS / name
        dst = BRAND / name
        if not src.exists():
            problems.append(f"缺少源徽标：{src.relative_to(ROOT)}")
            continue

        original = src.read_text(encoding="utf-8")
        expected = normalize(original, ver)

        if args.check:
            if expected != original:
                found = set(PAT_RIBBON.findall(original) + PAT_ARC.findall(original))
                problems.append(
                    f"{src.relative_to(ROOT)} 版本字样未同步到 v{ver}（现存 {sorted(found)}）"
                )
            if not dst.exists():
                problems.append(f"缺少站点副本：{dst.relative_to(ROOT)}")
            elif dst.read_text(encoding="utf-8") != expected:
                problems.append(f"站点副本与源不一致：{dst.relative_to(ROOT)}")
        else:
            if expected != original:
                src.write_text(expected, encoding="utf-8")
                changed.append(str(src.relative_to(ROOT)))
            BRAND.mkdir(parents=True, exist_ok=True)
            if not dst.exists() or dst.read_text(encoding="utf-8") != expected:
                dst.write_text(expected, encoding="utf-8")
                changed.append(str(dst.relative_to(ROOT)))

    if args.check:
        if problems:
            for p in problems:
                print(f"[FAIL] {p}")
            print(f"[check] 目标版本 v{ver} · 徽标版本同步校验未通过")
            return 1
        print(f"[check] 目标版本 v{ver} · 3 枚徽标 + 3 份站点副本版本字样全部同步 ✓")
        return 0

    if problems:
        for p in problems:
            print(f"[FAIL] {p}")
        return 1
    if changed:
        print(f"[ok] 版本字样同步至 v{ver} · 更新 {len(changed)} 个文件：")
        for f in changed:
            print(f"     {f}")
    else:
        print(f"[ok] 版本字样已是 v{ver}，无需改动（幂等）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
