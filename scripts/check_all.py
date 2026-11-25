#!/usr/bin/env python3
# scripts/check_all.py
# 一键总验收入口（库管员+成品验收员）：分层串跑全部门禁，统一汇总表与退出码语义
"""pyside-nova 一键总验收入口。

**分层而非"一键默认跑 24h"**：按场景分四档，避免把封版级长跑塞进日常交付。
统一退出码：0=全绿（含 WARN 有条件通过）/ 1=至少一道产品红或工具 ERROR /
2=未执行门禁（参数错误或环境缺失，如用错解释器）。
门禁红灯先定性（SESSION_HANDOFF 岗位规矩）：cve 缺 SBOM/缓存返回 2 判 WARN
（前置缺失），不计产品红；环境缺 PySide6 在预检阶段判 ERROR（码 2）终止，
与产品缺陷区分。

用法::

    python scripts/check_all.py                          # 默认 static（秒级，交付前）
    python scripts/check_all.py --tier dynamic            # perf + visual(smoke) + soak(冒烟) + hidpi
    python scripts/check_all.py --tier supply             # cve（离线读缓存）
    python scripts/check_all.py --tier all --brief        # 全部 8 道，摘要模式
    python scripts/check_all.py --tier all --soak-24 --visual-full --cve-online
                                                         # 封版完全体（真 24h + 全矩阵 + 联网 CVE）
    python scripts/check_all.py --list                    # 列出门禁清单与分层
    python scripts/check_all.py --report reports/acceptance.json

**解释器一致性**：所有子门禁均用运行本脚本的 sys.executable 启动。必须用项目
专用环境（miniconda3/envs/pyside6_nova/python.exe）运行，否则 qmllint 等会因缺
PySide6 假红灯（坑位 52）。启动时打印解释器路径供核对。
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass, replace
from datetime import datetime
import importlib.util
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PY = sys.executable  # 环境一致性的关键：子门禁与总入口同一解释器


@dataclass
class Gate:
    key: str
    name: str
    tier: str
    cmd: list[str]              # 传给 PY 的参数（脚本路径相对 ROOT）
    skip_code: int | None = None  # 该退出码 = 前置缺失(WARN)，非产品红


@dataclass
class Result:
    key: str
    name: str
    tier: str
    status: str     # PASS / FAIL / WARN / ERROR
    rc: int
    seconds: float


# 顺序即执行顺序；static 三道与 local_deploy.py:172 交付链一致
GATES: list[Gate] = [
    Gate("a11y", "可访问性契约", "static", ["scripts/check_a11y.py", "--quiet"]),
    Gate("api", "API 冻结", "static", ["scripts/check_api_freeze.py", "--quiet"]),
    Gate("qmllint", "qmllint 预算", "static", ["scripts/check_qmllint.py"]),
    Gate("perf", "性能三指标", "dynamic", ["scripts/check_perf.py"]),
    Gate("visual", "视觉回归", "dynamic", ["scripts/check_visual.py", "--smoke"]),
    Gate("soak", "内存长跑", "dynamic",
         ["scripts/check_soak.py", "--hours", "0.02", "--interval", "3", "-q"]),
    Gate("hidpi", "HiDPI 矩阵", "dynamic", ["-m", "pytest", "tests/test_hidpi.py", "-q"]),
    Gate("cve", "CVE 周巡", "supply",
         ["scripts/check_cve.py", "--offline", "--fail-on", "high"], skip_code=2),
]

TIER_KEYS: dict[str, list[str]] = {
    "static": ["a11y", "api", "qmllint"],
    "dynamic": ["perf", "visual", "soak", "hidpi"],
    "supply": ["cve"],
}
TIER_KEYS["all"] = [g.key for g in GATES]

ICON = {"PASS": "✓", "FAIL": "✗", "WARN": "!", "ERROR": "?"}


def select_gates(args: argparse.Namespace) -> list[Gate]:
    """按 tier 选门禁，并应用封版级参数变体（soak-24 / visual-full / cve-online）。"""
    keys = set(TIER_KEYS[args.tier])
    out: list[Gate] = []
    for g in GATES:
        if g.key not in keys:
            continue
        cmd = list(g.cmd)
        if g.key == "soak" and args.soak_24:
            cmd = ["scripts/check_soak.py", "--hours", "24", "--interval", "300", "-q"]
        elif g.key == "visual" and args.visual_full:
            cmd = ["scripts/check_visual.py"]
        elif g.key == "cve" and args.cve_online:
            cmd = ["scripts/check_cve.py", "--fail-on", "high"]
        out.append(replace(g, cmd=cmd))
    return out


def run_gate(gate: Gate, brief: bool) -> Result:
    t0 = time.perf_counter()
    tail = ""
    try:
        if brief:
            # 不捕获会污染汇总表；捕获则显式 utf-8 + replace（坑位 52 同款防御）
            proc = subprocess.run(
                [PY, *gate.cmd], cwd=str(ROOT),
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                encoding="utf-8", errors="replace",
            )
            rc = proc.returncode
            tail = "\n".join((proc.stdout or "").splitlines()[-12:])
        else:
            # 透传子进程输出：天然免疫 GBK/UTF-8 解码问题，过程可见
            rc = subprocess.run([PY, *gate.cmd], cwd=str(ROOT)).returncode
    except OSError as exc:  # 解释器/脚本无法启动——工具异常，非产品缺陷
        rc, tail, status = 127, f"[入口] 无法启动：{exc}", "ERROR"
    else:
        if rc == 0:
            status = "PASS"
        elif gate.skip_code is not None and rc == gate.skip_code:
            status = "WARN"
        else:
            status = "FAIL"
    seconds = round(time.perf_counter() - t0, 2)

    print(f"  {ICON[status]} {gate.name:<14} {status:<5} rc={rc:<3} {seconds:>7.2f}s")
    if brief and status in ("FAIL", "ERROR") and tail:
        for line in tail.splitlines():
            print(f"        | {line}")
    return Result(gate.key, gate.name, gate.tier, status, rc, seconds)


def print_list() -> None:
    print("pyside-nova 门禁清单（一键总验收）")
    print(f"  {'分层':<10}{'键':<10}{'门禁':<16}{'默认调用'}")
    for g in GATES:
        print(f"  {g.tier:<10}{g.key:<10}{g.name:<16}{' '.join(g.cmd)}")
    print("\n分层场景：")
    print("  static   秒级   a11y / api_freeze / qmllint  —— 每次交付前（默认）")
    print("  dynamic  分钟级 perf / visual(smoke) / soak(冒烟) / hidpi —— 功能回归")
    print("  supply   秒级   cve 离线周巡")
    print("  all      全部   封版；加 --soak-24 --visual-full --cve-online 为完全体")


def write_report(results: list[Result], args: argparse.Namespace, overall: int, path: str) -> None:
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "tier": args.tier,
        "interpreter": PY,
        "options": {
            "soak_24": args.soak_24,
            "visual_full": args.visual_full,
            "cve_online": args.cve_online,
        },
        "gates": [vars(r) for r in results],
        "summary": {
            "total": len(results),
            "pass": sum(r.status == "PASS" for r in results),
            "fail": sum(r.status == "FAIL" for r in results),
            "warn": sum(r.status == "WARN" for r in results),
            "error": sum(r.status == "ERROR" for r in results),
            "overall_exit": overall,
        },
    }
    out.write_text(__import__("json").dumps(payload, indent=2, ensure_ascii=False) + "\n",
                   encoding="utf-8")
    print(f"\n  报告已写入：{out}")


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="pyside-nova 一键总验收")
    ap.add_argument("--tier", choices=list(TIER_KEYS), default="static",
                    help="验收集层（默认 static）")
    ap.add_argument("--soak-24", action="store_true",
                    help="soak 跑真 24h（默认冒烟 0.02h/72s）；封版 CI 用")
    ap.add_argument("--visual-full", action="store_true",
                    help="视觉全矩阵（明暗 × 5 断点 × 24 页，~150s；默认 smoke）")
    ap.add_argument("--cve-online", action="store_true",
                    help="CVE 联网查 OSV.dev（默认 --offline 读缓存）")
    ap.add_argument("--brief", action="store_true",
                    help="摘要模式：捕获子进程输出，仅在门禁失败时打印尾部 12 行")
    ap.add_argument("--report", default="", help="验收报告 JSON 输出路径（可选）")
    ap.add_argument("--list", action="store_true", help="列出门禁清单与分层后退出")
    args = ap.parse_args(argv)

    if args.list:
        print_list()
        return 0

    print("=" * 68)
    print(f"pyside-nova 一键总验收 · tier={args.tier} · {datetime.now():%Y-%m-%d %H:%M:%S}")
    print(f"  解释器：{PY}")

    # 环境预检：需要 PySide6 的门禁层若跑在无 PySide6 解释器上，提前判 ERROR 并终止。
    # 避免把"环境未装依赖"误报成产品红（岗位规矩：红灯先定性）。
    needs_qt = any(g.key in ("qmllint", "perf", "visual", "soak", "hidpi")
                   for g in select_gates(args))
    if needs_qt and importlib.util.find_spec("PySide6") is None:
        print("  ? 环境预检失败：当前解释器无 PySide6 —— 这是工具/环境问题，非产品缺陷。")
        print("    请用项目专用环境运行：miniconda3/envs/pyside6_nova/python.exe scripts/check_all.py")
        print("=" * 68)
        print("  结论：环境 ERROR（未执行门禁）→ 退出码 2")
        print("=" * 68)
        return 2
    print("=" * 68)

    gates = select_gates(args)
    results = [run_gate(g, args.brief) for g in gates]

    n_pass = sum(r.status == "PASS" for r in results)
    n_fail = sum(r.status == "FAIL" for r in results)
    n_warn = sum(r.status == "WARN" for r in results)
    n_error = sum(r.status == "ERROR" for r in results)
    overall = 1 if (n_fail or n_error) else 0

    print("-" * 68)
    print(f"  结论：{len(results)} 道 · {n_pass} PASS / {n_fail} FAIL / "
          f"{n_warn} WARN / {n_error} ERROR → 退出码 {overall}")
    if overall == 0 and n_warn == 0:
        print("  全绿：可放行。")
    elif overall == 0:
        print("  有条件通过：WARN 为前置缺失（如 CVE 无 SBOM/缓存），非产品缺陷。")
    else:
        print("  存在产品红或工具异常：见上方 FAIL/ERROR 明细，修复后重跑。")
    print("=" * 68)

    if args.report:
        write_report(results, args, overall, args.report)
    return overall


if __name__ == "__main__":
    raise SystemExit(main())
