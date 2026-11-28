#!/usr/bin/env python3
# scripts/gen_upstream_baseline.py
# 上游基线口径守护：quasar-pin.json 是唯一事实源，6 处历史硬编码必须与它一致
"""守护 ``quasar-pin.json::pinned_version`` 与 6 处历史硬编码口径一致（零写入）。

**背景**：提案 R2 —— ``"baseline": "Quasar 2.35.5"`` 散落在
``api/nova-api-*.json`` / ``docs/ai/index.json`` / ``gen_apidocs.py`` /
``gen_api_freeze.py`` / ``gen_prompt.py`` / ``docs/PARITY.md``。散落本身不是错，
错在「没有单一事实源守护它」：0.13.0/0.14.0 的漂移复核正是因此只核了组件 JSON。

**为什么本脚本不做 --apply**：
- 已发布的 ``api/nova-api-1.0.0.json ~ 1.11.0.json`` 与 ``PARITY.md`` 历史段属史料，
  **一律不回改**；
- CSA D4 已拍板 ``pinned`` 保持 2.35.5，当前 6 处口径本来就一致 → 投影是 no-op；
- 真正把生成器常量改成「从 pin 读取」属**升 pin 独立议题**（届时随 minor 重签执行），
  P1 不抢跑、不假装完成。

规则表直接复用 ``check_upstream_drift.py::BASELINE_SENTINELS``（单一规则表，不复制）。

用法::

    python scripts/gen_upstream_baseline.py --check     # 交付前守护（默认）
    python scripts/gen_upstream_baseline.py --apply     # 明确拒绝 → rc 2

退出码：0 = 6 处一致；1 = 口径漂移；2 = 前置缺失 / 未实现的 --apply。
"""
from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PIN_PATH = ROOT / "upstream" / "quasar-pin.json"
SCRIPTS = ROOT / "scripts"


def _drift_module():
    spec = importlib.util.spec_from_file_location(
        "check_upstream_drift", SCRIPTS / "check_upstream_drift.py")
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="上游基线口径守护（零写入）")
    ap.add_argument("--check", action="store_true", help="守护 6 处口径一致（默认）")
    ap.add_argument("--apply", action="store_true",
                    help="源码级投影：须在升 pin 独立议题中执行 → rc 2")
    args = ap.parse_args(argv)

    if args.apply:
        print("[baseline] --apply 属「升 pin 独立议题」范围，P1 不执行。")
        print("           理由：pinned 保持 2.35.5（CSA D4），当前投影是 no-op；")
        print("           且已发布 api/*.json 与 PARITY.md 历史段属史料，一律不回改。")
        return 2

    if not PIN_PATH.exists():
        print(f"[baseline] 事实源缺失：{PIN_PATH.relative_to(ROOT)} → rc 2")
        return 2
    pin = json.loads(PIN_PATH.read_text(encoding="utf-8"))
    pinned = pin["pinned_version"]
    mod = _drift_module()
    results = mod.check_baseline_consistency(pinned, ROOT)

    bad = [r for r in results if not r["ok"]]
    print("=" * 68)
    print(f"pyside-nova 上游基线口径守护 · pinned={pinned} "
          f"(observed={pin.get('observed_version')}) · 唯一事实源 quasar-pin.json")
    for r in results:
        print(f"  [{'OK ' if r['ok'] else 'BAD'}] {r['path']}: {r['detail']}")
    print(f"  结论：{'PASS' if not bad else 'FAIL'} · {len(results) - len(bad)}/{len(results)} 一致")
    print("=" * 68)
    return 0 if not bad else 1


if __name__ == "__main__":
    raise SystemExit(main())
