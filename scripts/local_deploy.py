#!/usr/bin/env python3
# scripts/local_deploy.py
# 一键本地打包部署：清理 → 构建 wheel → 本地安装 → 冒烟测试 → 生成可校验的发布 ZIP
"""一键本地打包部署。

用法::

    python scripts/local_deploy.py          # 清理 → 构建 wheel → 安装 → 冒烟测试
    python scripts/local_deploy.py --demo   # 部署完成后运行可视化演示
    python scripts/local_deploy.py --zip    # 额外生成发布 ZIP 包（源码 + wheel + git 历史）
    python scripts/local_deploy.py --zip --bundle   # 再加离线图标全量包（约 30MB）
    python scripts/local_deploy.py --zip --demo

发布 ZIP 产物：
    dist/pyside-nova-<版本>-release.zip
    dist/pyside-nova-<版本>-release.zip.sha256   （校验指纹，防下载截断/传输损坏）

ZIP 内含：完整源码树（src/examples/docs/scripts/tests/.github）、PROMPT.md、
构建好的 wheel、完整 .git 历史、BUILD_INFO.txt（构建清单）。
"""
import argparse
import hashlib
import shutil
import subprocess
import sys
import zipfile
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# 发布 ZIP 内包含的顶层条目（排除 dist/build 产物与缓存）
ZIP_ENTRIES = [
    "pyproject.toml", "README.md", "README_zh.md", "CHANGELOG.md",
    "CONTRIBUTING.md", "SECURITY.md", "CODE_OF_CONDUCT.md", "LICENSE",
    ".gitignore", "PROMPT.md",
    "src", "examples", "docs", "scripts", "tests", ".github",
]

SKIP_PARTS = {"__pycache__", ".pytest_cache", "egg-info"}


def run(cmd: list, cwd: Path = ROOT) -> None:
    print(f"[run] {' '.join(cmd)}")
    subprocess.run(cmd, cwd=str(cwd), check=True)


def _git_head() -> str:
    try:
        out = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=str(ROOT),
                             capture_output=True, text=True, check=True)
        return out.stdout.strip()
    except Exception:
        return "n/a"


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def make_release_zip(wheel: Path, version: str, with_icons: bool, with_git: bool) -> Path:
    """把源码树 + wheel + git 历史打成发布 ZIP（zip 内根目录为 pyside-nova/）。"""
    out = ROOT / "dist" / f"pyside-nova-{version}-release.zip"
    entries = list(ZIP_ENTRIES)
    if with_icons:
        entries.append("icons")
    if with_git:
        entries.append(".git")

    files: list[Path] = []
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for entry in entries:
            src = ROOT / entry
            if src.is_file():
                zf.write(src, f"pyside-nova/{entry}")
                files.append(src)
            elif src.is_dir():
                for f in sorted(src.rglob("*")):
                    if f.is_file() and not any(p in SKIP_PARTS for p in f.parts):
                        zf.write(f, f"pyside-nova/{f.relative_to(ROOT).as_posix()}")
                        files.append(f)
        zf.write(wheel, f"pyside-nova/dist/{wheel.name}")
        files.append(wheel)

        info = [
            f"pyside-nova {version} 发布包构建清单",
            f"构建时间：{datetime.now():%Y-%m-%d %H:%M:%S}（星期{'一二三四五六日'[datetime.now().weekday()]}）",
            f"git HEAD：{_git_head()}",
            f"文件总数：{len(files) + 1}（含本清单）",
            f"是否含离线图标包：{'是' if with_icons else '否'}",
            f"是否含 git 历史：{'是' if with_git else '否'}",
            f"pip 安装：pip install dist/{wheel.name}",
            "",
            "校验方式（Windows PowerShell）：",
            f"  Get-FileHash .\\pyside-nova-{version}-release.zip -Algorithm SHA256",
            "  与同名 .sha256 文件内容比对一致即完整。",
        ]
        zf.writestr("pyside-nova/BUILD_INFO.txt", "\n".join(info) + "\n")

    # 旁路校验文件（防下载截断/传输损坏）
    (out.parent / f"{out.name}.sha256").write_text(
        f"{_sha256(out)}  {out.name}\n", encoding="utf-8")
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--demo", action="store_true", help="部署完成后运行演示")
    ap.add_argument("--zip", action="store_true", help="生成发布 ZIP 包（源码 + wheel + git）")
    ap.add_argument("--bundle", action="store_true",
                    help="ZIP 内附加 icons/ 离线图标全量包（约 30MB，用于完全离线部署）")
    ap.add_argument("--no-git", action="store_true", help="ZIP 内不附 .git 历史（默认附带）")
    args = ap.parse_args()

    # 1. 清理构建产物
    for d in ("dist", "build"):
        shutil.rmtree(ROOT / d, ignore_errors=True)

    # 2. 构建 wheel（缺 build 则自动安装）
    try:
        import build  # noqa: F401
    except ImportError:
        run([sys.executable, "-m", "pip", "install", "-q", "build"])
    run([sys.executable, "-m", "build", "--wheel"])

    wheels = sorted((ROOT / "dist").glob("*.whl"))
    assert wheels, "wheel 构建失败"
    wheel = wheels[-1]

    # 3. 本地安装（--no-deps：环境内 PySide6 已就绪，避免重复下载）
    run([sys.executable, "-m", "pip", "install", "--force-reinstall",
         "--no-deps", "-q", str(wheel)])

    # 4. 冒烟测试（对安装后的 wheel 内容验证 QML 打包完整性）
    run([sys.executable, "-m", "pytest", "tests", "-q"])

    print(f"\n✅ 本地部署完成：{wheel.name}")

    # 5. 发布 ZIP 包（带 SHA256 校验）
    if args.zip:
        from pyside_nova import __version__
        zip_path = make_release_zip(wheel, __version__,
                                    with_icons=args.bundle, with_git=not args.no_git)
        size_mb = zip_path.stat().st_size / 1024 / 1024
        digest = _sha256(zip_path)
        print(f"✅ 发布 ZIP 包：{zip_path.relative_to(ROOT).as_posix()} "
              f"（{size_mb:.2f} MB）")
        print(f"   SHA256：{digest}")
        print(f"   校验文件：{zip_path.name}.sha256")

    if args.demo:
        run([sys.executable, "examples/demo/main.py"])


if __name__ == "__main__":
    main()
