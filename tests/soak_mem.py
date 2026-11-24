# tests/soak_mem.py
# 24h 压测：零依赖 RSS 采样 + 泄漏趋势判定（RC2 验收「24h 压测无内存增长」）
"""内存采样与泄漏判定工具（零第三方依赖，对齐项目 SBOM 脚本的离线纪律）。

RSS 采样：
- Windows: ctypes → psapi.GetProcessMemoryInfo（WorkingSetSize）
- Linux: /proc/self/statm 的 resident 页
- 采样前调用方须 gc.collect() + processEvents()，否则读到的是 GC 抖动峰值

判定（三段稳健口径，避免单点比较误报）：
1. warmup 丢弃前 10% 样本（组件首次创建的 QML 编译缓存、Qt 内部惰性分配）
2. 稳态段最小二乘拟合斜率 MB/小时
3. 稳态前 1/3 vs 后 1/3 均值漂移
三者同时纳入：斜率/漂移超阈或峰值超上限即 FAIL；不支持的平台直接报错（诚实边界）。
"""
from __future__ import annotations

import ctypes
import gc
import os
import sys
from dataclasses import dataclass

_MB = 1048576


def _rss_windows() -> float:
    from ctypes import wintypes

    class PROCESS_MEMORY_COUNTERS(ctypes.Structure):
        _fields_ = [
            ("cb", wintypes.DWORD),
            ("PageFaultCount", wintypes.DWORD),
            ("PeakWorkingSetSize", ctypes.c_size_t),
            ("WorkingSetSize", ctypes.c_size_t),
            ("QuotaPeakPagedPoolUsage", ctypes.c_size_t),
            ("QuotaPagedPoolUsage", ctypes.c_size_t),
            ("QuotaPeakNonPagedPoolUsage", ctypes.c_size_t),
            ("QuotaNonPagedPoolUsage", ctypes.c_size_t),
            ("PagefileUsage", ctypes.c_size_t),
            ("PeakPagefileUsage", ctypes.c_size_t),
        ]

    # 必须显式声明原型：64 位下默认 int 会截断 HANDLE（伪句柄 -1 → 0xFFFFFFFF），
    # 导致 GetProcessMemoryInfo 返回 False（实测坑位）
    kern = ctypes.windll.kernel32
    kern.GetCurrentProcess.restype = wintypes.HANDLE
    fn = ctypes.windll.psapi.GetProcessMemoryInfo
    fn.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD]
    fn.restype = wintypes.BOOL
    handle = kern.GetCurrentProcess()
    pmc = PROCESS_MEMORY_COUNTERS()
    pmc.cb = ctypes.sizeof(pmc)
    if not fn(handle, ctypes.byref(pmc), pmc.cb):
        raise OSError(f"GetProcessMemoryInfo failed (err={ctypes.get_last_error()})")
    return pmc.WorkingSetSize / _MB


def _rss_linux() -> float:
    with open("/proc/self/statm", encoding="ascii") as f:
        resident_pages = int(f.read().split()[1])
    return resident_pages * os.sysconf("SC_PAGE_SIZE") / _MB


def rss_mb() -> float:
    """当前进程常驻内存（MB）；不支持的平台抛错，不静默返回 0。"""
    if sys.platform == "win32":
        return _rss_windows()
    if sys.platform.startswith("linux"):
        return _rss_linux()
    raise RuntimeError(f"RSS 采样不支持平台 {sys.platform}（需贡献 task_info 实现）")


def object_count() -> int:
    """Python 存活对象数（QML wrapper 泄漏敏感的辅助指标）。"""
    objs = gc.get_objects()
    n = len(objs)
    del objs
    return n


@dataclass
class SoakVerdict:
    ok: bool
    reason: str
    samples: int
    warmup_dropped: int
    slope_mb_per_hour: float
    drift_mb: float
    rss_start_mb: float
    rss_end_mb: float
    rss_peak_mb: float
    objects_start: int
    objects_end: int
    duration_sec: float

    def as_dict(self) -> dict:
        return {k: (round(v, 3) if isinstance(v, float) else v)
                for k, v in self.__dict__.items()}


def analyze(samples: list[tuple[float, float, int]], *,
            max_slope: float, max_drift: float, max_rss: float,
            warmup_frac: float = 0.1, min_samples: int = 6) -> SoakVerdict:
    """趋势判定。samples: [(elapsed_sec, rss_mb, python_object_count), ...]。"""
    duration = samples[-1][0] if samples else 0.0
    peak = max((s[1] for s in samples), default=0.0)
    base = SoakVerdict(
        ok=False, reason="", samples=len(samples), warmup_dropped=0,
        slope_mb_per_hour=0.0, drift_mb=0.0,
        rss_start_mb=samples[0][1] if samples else 0.0,
        rss_end_mb=samples[-1][1] if samples else 0.0,
        rss_peak_mb=peak,
        objects_start=samples[0][2] if samples else 0,
        objects_end=samples[-1][2] if samples else 0,
        duration_sec=duration,
    )
    if len(samples) < min_samples:
        base.reason = f"样本不足（{len(samples)} < {min_samples}），无法判定趋势"
        return base
    n_warm = max(1, int(len(samples) * warmup_frac))
    steady = samples[n_warm:]
    base.warmup_dropped = n_warm
    t0 = steady[0][0]
    xs = [(t - t0) / 3600.0 for t, _, _ in steady]
    ys = [r for _, r, _ in steady]
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    den = sum((x - mx) ** 2 for x in xs)
    slope = sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / den if den > 1e-9 else 0.0
    third = max(1, n // 3)
    head = sum(ys[:third]) / third
    tail = sum(ys[-third:]) / third
    drift = tail - head
    base.slope_mb_per_hour = slope
    base.drift_mb = drift
    bad: list[str] = []
    if slope > max_slope:
        bad.append(f"稳态斜率 {slope:.2f} MB/h 超阈 {max_slope}")
    if drift > max_drift:
        bad.append(f"前后段漂移 {drift:.1f} MB 超阈 {max_drift}")
    if peak > max_rss:
        bad.append(f"峰值 RSS {peak:.1f} MB 超上限 {max_rss}")
    base.ok = not bad
    base.reason = "；".join(bad) if bad else (
        f"无泄漏趋势（斜率 {slope:.2f} MB/h，漂移 {drift:.1f} MB，峰值 {peak:.1f} MB）")
    return base
