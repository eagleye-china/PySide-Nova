# scripts/check_visual.py
# 视觉回归门禁 CLI（0.16.2 B3）：明/暗 × 5 断点 × 全画廊 24 页
"""视觉回归门禁入口（pytest 包装）。

用法：
    python scripts/check_visual.py                # 全矩阵 diff 门禁
    python scripts/check_visual.py --update       # 重建基线（tests/baselines/visual/）
    python scripts/check_visual.py --smoke        # 只跑 smoke 抽检（等价默认全量里的抽检）

口径：单通道差 >8 计差异像素，占比 >0.2% 判失败（容忍反走样噪声）。
坑位纪律：pytest 常驻单引擎（坑位 42）；qrc:/ 单斜杠（坑位 48）——
独立进程直接创建组件曾确定性 SIGSEGV，故门禁以 pytest 承载（对齐 check_perf.py 模式）。
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main() -> int:
    args = sys.argv[1:]
    if "--update" in args:
        pytest_args = ["-q", "tests/test_visual.py::test_visual_full_matrix", "--visual-full", "--snapshot-update"]
        print("[visual] 重建基线：tests/baselines/visual/（240 张）")
    elif "--smoke" in args:
        pytest_args = ["-q", "tests/test_visual.py::test_visual_smoke"]
        print("[visual] smoke 抽检（md × 明暗 × 3 页）")
    else:
        pytest_args = ["-q", "tests/test_visual.py::test_visual_full_matrix", "--visual-full"]
        print("[visual] 全矩阵门禁（明暗 × 5 断点 × 24 页）")
    proc = subprocess.run([sys.executable, "-m", "pytest", *pytest_args], cwd=ROOT)
    if proc.returncode == 0:
        print("[visual] 门禁通过 ✓")
    else:
        print("[visual] 门禁失败 ✗（基线漂移：确认是否有意变更——有意则 --update 重建）")
    return proc.returncode


if __name__ == "__main__":
    sys.exit(main())
