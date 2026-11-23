#!/usr/bin/env python3
# scripts/gen_icons.py
# NovaIconGenie —— 应用图标全套生成器（对标 @quasar/icongenie · 基线 2.35.5 产物口径）
# 单张源图（建议 ≥512×512 PNG）→ favicon / apple-touch / android / ios / electron / splash 全套
"""NovaIconGenie：单图生成全套应用图标。

用法：
    python scripts/gen_icons.py source.png --out icons/ [--background "#RRGGBB"] [--padding 10]

产物目录结构（对标 icongenie generate 默认清单）：
    <out>/favicon/favicon-16x16.png ... favicon-96x96.png favicon-128x128.png
    <out>/apple-touch-icon.png + apple-touch-icon-<size>.png
    <out>/android/icon-<size>.png          （36/48/72/96/144/192/512）
    <out>/ios/AppIcon-<size>@<scale>x.png  （20~1024 全档）
    <out>/splash/splash-<w>x<h>.png        （--splash 开启；含背景色与内边距）
    <out>/icongenie-report.json            （产物清单 + 源图指纹）
"""
import argparse
import hashlib
import json
import math
import sys
from pathlib import Path

from PIL import Image

# 产物清单（对标 icongenie 默认模式）
FAVICONS = [16, 32, 96, 128]
APPLE_TOUCH = [120, 152, 167, 180, 192]
ANDROID = [36, 48, 72, 96, 144, 192, 512]
IOS_BASES = [  # (边 pt, scale) —— 对标 AppIcon.appiconset 档位
    (20, 2), (20, 3), (29, 2), (29, 3), (38, 2), (38, 3),
    (40, 2), (40, 3), (60, 2), (60, 3), (76, 2), (83.5, 2),
    (1024, 1),
]
SPLASHES = [  # 对标 icongenie splash 主要档位
    (1284, 2778), (1170, 2532), (750, 1334), (1242, 2688),
    (1080, 1920), (720, 1280),
]


def _composite(source: Image.Image, size: int, padding: int, bg: str | None) -> Image.Image:
    """居中缩放 + 可选内边距 + 可选背景色。"""
    inner = max(1, size - 2 * padding)
    img = source.copy()
    img.thumbnail((inner, inner), Image.LANCZOS)
    mode = "RGBA" if bg in (None, "transparent", "none") else "RGB"
    canvas = Image.new(mode, (size, size), None if mode == "RGBA" else bg)
    off = ((size - img.width) // 2, (size - img.height) // 2)
    canvas.paste(img, off, img if img.mode == "RGBA" else None)
    return canvas


def generate(source: Path, out: Path, background: str | None,
             padding: int, with_splash: bool) -> list[dict]:
    """生成全套图标；返回产物清单（相对路径 + 尺寸）。"""
    src = Image.open(source)
    src.load()
    if src.width < 64 or src.height < 64:
        raise SystemExit("源图太小（<64px），建议 ≥512×512")
    made: list[dict] = []

    def emit(img: Image.Image, rel: str) -> None:
        p = out / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        img.save(p, "PNG")
        made.append({"path": rel, "width": img.width, "height": img.height})

    for s in FAVICONS:
        emit(_composite(src, s, padding, background), f"favicon/favicon-{s}x{s}.png")
    emit(_composite(src, 180, padding, background), "apple-touch-icon.png")
    for s in APPLE_TOUCH:
        emit(_composite(src, s, padding, background), f"apple-touch-icon-{s}.png")
    for s in ANDROID:
        emit(_composite(src, s, padding, background), f"android/icon-{s}.png")
    for pt, scale in IOS_BASES:
        size = int(round(pt * scale))
        pt_s = str(int(pt)) if float(pt).is_integer() else str(pt)
        emit(_composite(src, size, 0, background),
             f"ios/AppIcon-{pt_s}x{pt_s}@{scale}x.png")
    emit(_composite(src, 1024, 0, background), "ios/AppIcon-1024.png")

    if with_splash:
        if not background or background in ("transparent", "none"):
            raise SystemExit("--splash 需要 --background 提供不透明背景色")
        for w, h in SPLASHES:
            canvas = Image.new("RGB", (w, h), background)
            inner_w = w - 2 * padding
            img = src.copy()
            img.thumbnail((inner_w, h - 2 * padding), Image.LANCZOS)
            canvas.paste(img, ((w - img.width) // 2, (h - img.height) // 2),
                         img if img.mode == "RGBA" else None)
            emit(canvas, f"splash/splash-{w}x{h}.png")
    return made


def main() -> int:
    ap = argparse.ArgumentParser(description="NovaIconGenie：单图生成全套应用图标")
    ap.add_argument("source", type=Path, help="源图（PNG，建议 ≥512×512）")
    ap.add_argument("--out", type=Path, default=Path("icons"), help="输出目录")
    ap.add_argument("--background", default=None, help="背景色（#RRGGBB 或 transparent）")
    ap.add_argument("--padding", type=int, default=0, help="内边距 px（图标内留白）")
    ap.add_argument("--splash", action="store_true", help="同时生成启动图（需不透明背景色）")
    args = ap.parse_args()

    if not args.source.exists():
        raise SystemExit(f"源图不存在：{args.source}")

    made = generate(args.source, args.out, args.background, args.padding, args.splash)
    digest = hashlib.sha256(args.source.read_bytes()).hexdigest()[:16]
    report = {
        "generator": "NovaIconGenie",
        "source": str(args.source),
        "source_sha256_16": digest,
        "background": args.background,
        "padding": args.padding,
        "count": len(made),
        "files": made,
    }
    rp = args.out / "icongenie-report.json"
    rp.parent.mkdir(parents=True, exist_ok=True)
    rp.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"NovaIconGenie：{len(made)} 个产物 → {args.out}（清单：{rp}）")
    return 0


if __name__ == "__main__":
    sys.exit(main())