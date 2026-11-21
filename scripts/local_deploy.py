#!/usr/bin/env python3
# scripts/local_deploy.py
# 一键本地打包部署：清理 → 构建 wheel → 本地安装 → 冒烟测试 →（--zip 生成发布 ZIP 包）
"""一键本地打包部署。

用法::

    python scripts/local_deploy.py          # 清理 → 构建 wheel → 安装 → 冒烟测试
    python scripts/local_deploy.py --demo   # 部署完成后运行可视化演示
    python scripts/local_deploy.py --zip    # 额外生成发布 ZIP 包（源码 + wheel）
    python scripts/local_deploy.py --zip --demo

发布 ZIP 产物：dist/pyside-nova-<版本>-release.zip，
内含完整源码树（src/examples/docs/scripts/tests/.github）与构建好的 wheel。
"""
import argparse
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# 发布 ZIP 内包含的顶层条目（排除 dist/build/icons 等产物与缓存）
ZIP_ENTRIES = [
    "pyproject.toml", "README.md", "README_zh.md", "CHANGELOG.md",
    "CONTRIBUTING.md", "SECURITY.md", "CODE_OF_CONDUCT.md", "LICENSE", ".gitignore",
    "src", "examples", "docs", "scripts", "tests", ".github",
]


def run(cmd: list, cwd: Path = ROOT) -> None:
    print(f"[run] {' '.join(cmd)}")
    subprocess.run(cmd, cwd=str(cwd), check=True)


def make_release_zip(wheel: Path, version: str) -> Path:
    """把源码树 + wheel 打成发布 ZIP（zip 内根目录为 pyside-nova/）。"""
    out = ROOT / "dist" / f"pyside-nova-{version}-release.zip"
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for entry in ZIP_ENTRIES:
            src = ROOT / entry
            if src.is_file():
                zf.write(src, f"pyside-nova/{entry}")
            elif src.is_dir():
                for f in sorted(src.rglob("*")):
                    if f.is_file() and not any(
                        part in {"__pycache__", ".pytest_cache", "egg-info"}
                        for part in f.parts
                    ):
                        zf.write(f, f"pyside-nova/{f.relative_to(ROOT).as_posix()}")
        zf.write(wheel, f"pyside-nova/dist/{wheel.name}")
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--demo", action="store_true", help="部署完成后运行演示")
    ap.add_argument("--zip", action="store_true", help="生成发布 ZIP 包（源码 + wheel）")
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

    # 5. 发布 ZIP 包
    if args.zip:
        from pyside_nova import __version__
        zip_path = make_release_zip(wheel, __version__)
        print(f"✅ 发布 ZIP 包：{zip_path.relative_to(ROOT).as_posix()}")

    if args.demo:
        run([sys.executable, "examples/demo/main.py"])


if __name__ == "__main__":
    main()
