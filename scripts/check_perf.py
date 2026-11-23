#!/usr/bin/env python3
# scripts/check_perf.py
# 性能门禁入口（0.16.1）：包装 tests/test_perf.py（pytest 承载，见坑位 48）
"""pyside-nova 性能门禁。

三维度（对齐 docs/MASTER_PLAN.md Sprint B2 DoD）：
1. 冷启动：画廊 main.qml 实例化 + 首屏布局 ≤ 800ms
2. 组件实例化：全部导出类型（预热后）逐个 create() ≤ 5ms/个
   （已知例外：NovaDate 日历网格固有 ~6ms，诚实边界白名单）
3. 表格：1000 行 NovaTable 挂载 + 布局 ≤ 1700ms

实现说明：门禁本体在 tests/test_perf.py（pytest 承载）——独立 python 进程在
干净引擎上 setData 组件会确定性 SIGSEGV（shiboken refcount，根因是 qrc://
双斜杠 URL 被解析为带 authority 的路径，qrc:/ 单斜杠即愈；基线 0.16.0 同样
复现，pytest 常驻单引擎全量稳定，坑位 42/48）。本脚本只是 CLI 包装：
退出码 = pytest 结果，CI 可直接挂。
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main() -> int:
    print("=" * 64)
    print("pyside-nova 性能门禁（0.16.1）—— 承载于 tests/test_perf.py")
    print("  预算：冷启动 ≤800ms | 组件实例化 ≤5ms/个 | 1000 行表格 ≤1700ms")
    print("=" * 64)
    proc = subprocess.run(
        [sys.executable, "-m", "pytest", str(ROOT / "tests" / "test_perf.py"), "-q"],
        cwd=str(ROOT),
    )
    return proc.returncode


if __name__ == "__main__":
    sys.exit(main())
