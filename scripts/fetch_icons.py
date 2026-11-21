# scripts/fetch_icons.py
# 下载 MDI / Material 图标包到 icons/（约 1 万个 SVG）作为离线部署数据源；--only mdi|material 可选
#!/usr/bin/env python3
"""下载 MDI / Material 图标 SVG 包到本地 icons/ 目录（离线部署通道）。

用法::

    python scripts/fetch_icons.py             # 全部下载（mdi + material 系列）
    python scripts/fetch_icons.py --only mdi  # 只下载 mdi
    python scripts/fetch_icons.py --only material

产出（目录名 = NovaIcon 的 set 前缀）::

    icons/mdi/*.svg
    icons/material/*.svg
    icons/material-outlined/*.svg
    icons/material-round/*.svg
    icons/material-sharp/*.svg
    icons/material-two-tone/*.svg

之后将 NovaTheme.iconLocalRoot 指向 icons/ 的 file:// URI 即离线可用；
本地缺失的图标仍会自动回落云端 CDN。
"""
import argparse
import io
import json
import shutil
import tarfile
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEST = ROOT / "icons"

# npm 包名 → {包内子目录: 本地目标目录}
PACKAGES = {
    "@mdi/svg": {"svg": "mdi"},
    "@material-design-icons/svg": {
        "filled": "material",
        "outlined": "material-outlined",
        "round": "material-round",
        "sharp": "material-sharp",
        "two-tone": "material-two-tone",
    },
}


def fetch(pkg: str, mapping: dict) -> None:
    quoted = urllib.parse.quote(pkg, safe="")
    with urllib.request.urlopen(
            f"https://registry.npmjs.org/{quoted}/latest") as r:
        meta = json.load(r)
    version = meta["version"]
    tarball_url = meta["dist"]["tarball"]
    print(f"[fetch] {pkg}@{version}")

    with urllib.request.urlopen(tarball_url) as r:
        data = r.read()
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar:
        for src_sub, dst_sub in mapping.items():
            out_dir = DEST / dst_sub
            out_dir.mkdir(parents=True, exist_ok=True)
            prefix = f"package/{src_sub}/"
            count = 0
            for m in tar.getmembers():
                if m.name.startswith(prefix) and m.name.endswith(".svg"):
                    f = tar.extractfile(m)
                    if f is None:
                        continue
                    (out_dir / Path(m.name).name).write_bytes(f.read())
                    count += 1
            print(f"  {src_sub:<10} -> icons/{dst_sub:<18} ({count} 个图标)")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--only", choices=["mdi", "material"],
                    help="只下载指定图标包（默认全部）")
    args = ap.parse_args()

    if DEST.exists():
        shutil.rmtree(DEST)
    DEST.mkdir(parents=True)

    if args.only:
        pkg = "@mdi/svg" if args.only == "mdi" else "@material-design-icons/svg"
        fetch(pkg, PACKAGES[pkg])
    else:
        for pkg, mapping in PACKAGES.items():
            fetch(pkg, mapping)

    print(f"\n✅ 图标包已就绪：{DEST}")
    print("   QML 中设置：NovaTheme.iconLocalRoot = '" + DEST.as_uri() + "'")


if __name__ == "__main__":
    main()
