# scripts/build_app.py
# 一键应用打包（0.16.2 B3）：PyInstaller onefile 打包画廊 demo
"""用法：
    python scripts/build_app.py               # 打包 → dist/nova-gallery
    python scripts/build_app.py --no-run      # 只打包不验证
    python scripts/build_app.py --console     # 带控制台输出（调试）

产物：单文件可执行（Linux = ELF / Windows = nova-gallery.exe，同名目标随平台自动落位）。
QML 资源经 --add-data 进包（qml/ 与 examples/），onefile 运行期解压到 sys._MEIPASS。
PySide6 由 PyInstaller 官方 hook 自动收集（QtQml/QtQuick 插件与依赖）。

诚实边界（PARITY）：
- 门禁目标 ≤60MB：实测 185.7MB（PySide6 6.12 全运行时 onefile，exclude-module 已配置
  但 Qt 大件非 Python 模块收集路径——Qt 插件目录占绝对大头）。进一步压缩方向：
  upx 压缩（牺牲启动时间）/ QML 预编译进 rcc / 按需裁剪 Qt 插件目录（post-build 钩子）；
  诚实记录，不强凑门禁。
- 沙箱 pyenv Python 无 --enable-shared → PyInstaller 不可用；用 uv venv（shared python）
  跑本脚本：`uv venv --python 3.12 && uv pip install -e . pyinstaller && <venv>/python scripts/build_app.py`
- 代码签名 / 安装器（MSI/NSIS）需平台证书，超出沙箱能力；Windows exe 在 Linux 沙箱
  不可构建——目标平台交叉打包须在对应 OS 上执行本脚本。
"""
import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
APP_NAME = "nova-gallery"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--no-run", action="store_true", help="只打包不启动验证")
    parser.add_argument("--console", action="store_true", help="保留控制台（调试用）")
    args = parser.parse_args()

    sep = ";" if sys.platform == "win32" else ":"
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--name", APP_NAME,
        "--onefile",
        "--noconfirm",
        "--clean",
        "--windowed" if not args.console else "--console",
        # QML 模块资源（Nova.* 三模块 + icons）
        "--add-data", f"src/pyside_nova/qml{sep}pyside_nova/qml",
        "--add-data", f"examples{sep}examples",
        # 隐式导入（QML 动态 import 不被静态分析发现）
        "--hidden-import", "pyside_nova.runtime",
        # 体积裁剪：画廊只用 QtQml/QtQuick/QtGui，剔除未用的 Qt 大件
        # （QtWebEngine ~100MB / 3D / Charts / Sql / WebSockets / NetworkAuth 等）
        *[
            f"--exclude-module={m}"
            for m in [
                "PySide6.QtWebEngineCore", "PySide6.QtWebEngineWidgets", "PySide6.QtWebEngineQuick",
                "PySide6.QtWebChannel", "PySide6.QtPositioning", "PySide6.QtLocation",
                "PySide6.Qt3DCore", "PySide6.Qt3DRender", "PySide6.Qt3DInput", "PySide6.Qt3DLogic",
                "PySide6.Qt3DAnimation", "PySide6.Qt3DExtras",
                "PySide6.QtCharts", "PySide6.QtDataVisualization", "PySide6.QtGraphs",
                "PySide6.QtSql", "PySide6.QtPdf", "PySide6.QtSensors", "PySide6.QtSerialPort",
                "PySide6.QtTest", "PySide6.QtBluetooth", "PySide6.QtNfc", "PySide6.QtRemoteObjects",
                "PySide6.QtScxml", "PySide6.QtStateMachine", "PySide6.QtTextToSpeech",
                "PySide6.QtWebSockets", "PySide6.QtNetworkAuth", "PySide6.QtMultimedia",
                "PySide6.QtMultimediaWidgets", "PySide6.QtDesigner", "PySide6.QtHelp",
                "PySide6.QtUiTools", "PySide6.QtOpenGLWidgets",
            ]
        ],
        str(ROOT / "examples" / "gallery_launch.py"),
    ]

    print("[build] PyInstaller 打包中……")
    proc = subprocess.run(cmd, cwd=ROOT)
    if proc.returncode != 0:
        print("[build] 打包失败 ✗")
        return proc.returncode

    exe = ROOT / "dist" / (APP_NAME + (".exe" if sys.platform == "win32" else ""))
    size_mb = exe.stat().st_size / 1024 / 1024 if exe.exists() else 0
    print(f"[build] ✓ 产物 {exe}（{size_mb:.1f} MB）")

    if not args.no_run:
        print("[build] 启动验证（QT_QPA_PLATFORM=offscreen，2 秒自检）……")
        import os
        import signal
        import time
        env = dict(os.environ, QT_QPA_PLATFORM="offscreen")
        child = subprocess.Popen([str(exe)], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            time.sleep(2)
            rc = child.poll()
            if rc is not None and rc != 0:
                print(f"[build] 启动验证失败 ✗（exit {rc}）")
                return 1
            print("[build] ✓ 启动验证通过")
        finally:
            child.send_signal(signal.SIGTERM)
            try:
                child.wait(timeout=5)
            except subprocess.TimeoutExpired:
                child.kill()
    return 0


if __name__ == "__main__":
    sys.exit(main())
