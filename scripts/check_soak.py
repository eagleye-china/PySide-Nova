#!/usr/bin/env python3
# scripts/check_soak.py
# 24h 内存长跑门禁 CLI（1.0.0 RC2）：包装 tests/test_soak.py（pytest 承载，见坑位 42/48/49）
"""pyside-nova 24h 内存长跑压测门禁。

对齐 docs/ECOSYSTEM_PARITY.md §6「24h 压测无内存增长」验收项。

用法：
    python scripts/check_soak.py                       # 完整 24h（默认）
    python scripts/check_soak.py --hours 0.02          # 冒烟（~72s，验链路）
    python scripts/check_soak.py --hours 2 --interval 60 --report reports/soak.json

判定口径（tests/soak_mem.py analyze）：
- 丢弃前 10% 样本为 warmup；稳态段最小二乘斜率 ≤ 2 MB/h；
- 前后 1/3 分段均值漂移 ≤ 24 MB；峰值 RSS ≤ 1500 MB。
真泄漏通常 >100MB/24h 且单调上升，容许带覆盖分配器碎片与缓存抖动。

实现说明：门禁本体在 tests/test_soak.py（pytest 常驻单引擎，坑位 42/48）；
本脚本只是 CLI 包装，退出码 = pytest 结果，CI 可直接挂。
长跑后解释器收尾 GC 崩溃由 conftest 坑位 49 硬退出规避，退出码语义保留。
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main() -> int:
    ap = argparse.ArgumentParser(description="pyside-nova 24h 内存长跑门禁")
    ap.add_argument("--hours", type=float, default=24.0, help="压测时长（小时），默认 24；冒烟 0.02")
    ap.add_argument("--interval", type=float, default=300.0, help="采样间隔（秒），默认 300")
    ap.add_argument("--report", default="", help="报告 JSON 输出路径（可选）")
    ap.add_argument("-q", "--quiet", action="store_true", help="静默 pytest 输出")
    args = ap.parse_args()

    print("=" * 64)
    print("pyside-nova 24h 内存长跑门禁（1.0.0 RC2 封版验收）")
    print(f"  时长 {args.hours}h | 采样间隔 {args.interval}s | "
          f"阈值 斜率≤2MB/h · 漂移≤24MB · 峰值≤1500MB")
    print("=" * 64)

    pytest_args = [
        sys.executable, "-m", "pytest",
        str(ROOT / "tests" / "test_soak.py"),
        "-q" if args.quiet else "-v",
        "-s",
        f"--soak-hours={args.hours}",
        f"--soak-interval={args.interval}",
    ]
    if args.report:
        pytest_args.append(f"--soak-report={args.report}")

    proc = subprocess.run(pytest_args, cwd=str(ROOT))
    if proc.returncode == 0:
        print("[soak] 门禁通过 ✓ —— 无内存增长趋势，可勾选 RC2 压测项")
    else:
        print("[soak] 门禁失败 ✗ —— 判定为内存增长或探针异常，见报告/输出")
    return proc.returncode


if __name__ == "__main__":
    sys.exit(main())
