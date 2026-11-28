#!/usr/bin/env python3
# scripts/check_parity_ops.py
# Parity Ops L-D：D3 节奏法源 + P2 广度台账的结构门禁（独立于 P1 check_parity.py）
"""守护 ``upstream/cadence.json``（D3）与 ``parity/breadth.json``（P2）的结构完整性。

**为什么不改 check_parity.py**：P1 的 19 项门禁已完现销号、口径冻结；本脚本独立成门，
保证 P1 门禁零改动。两者都在交付前单独跑，均不挂 ``check_all.py --tier static``
（静态恒 3/3）。

检查项：

- cadence：schema / ratified / 3 档触发 / 唯一硬门 / C0~C6 全覆盖 / 阻断类与
  ``check_upstream_drift.py::BLOCKING`` 一致 / non_goals / P3 待办 / 视图全文双向核对
- breadth：签名重算 / 视图全文双向核对 / 156 条零悬空 / 层级在七层定义内 /
  与 matrix.json 同源（签名、逐项、GAP、组件级缺口）/ 批次求和守恒 /
  面外层如实登记（L0/L5/L6 不虚高）
- 生成器 ``--check`` 幂等（两个新生成器）
- 冻结面 147 类型 / 指纹 ``9966483dda5a53c4`` 零漂移

退出码：0 = PASS；1 = 产品红（结构 / 法源链问题）；2 = 前置缺失。
"""
from __future__ import annotations

import argparse
import importlib.util
import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "scripts"
PIN_PATH = ROOT / "upstream" / "quasar-pin.json"
CADENCE_PATH = ROOT / "upstream" / "cadence.json"
CADENCE_VIEW = ROOT / "docs" / "PARITY_CADENCE.md"
TAXONOMY_PATH = ROOT / "parity" / "breadth_taxonomy.json"
MATRIX_PATH = ROOT / "parity" / "matrix.json"
BREADTH_PATH = ROOT / "parity" / "breadth.json"
BREADTH_VIEW = ROOT / "docs" / "PARITY_BREADTH.md"


def _load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def _generator_check(script: str) -> bool:
    r = subprocess.run([sys.executable, str(SCRIPTS / script), "--check"],
                       check=False, cwd=ROOT, capture_output=True, text=True)
    return r.returncode == 0 and "PASS" in r.stdout


def _latest_freeze() -> Path:
    def key(p: Path):
        try:
            return tuple(int(x) for x in p.stem.split("-")[-1].split("."))
        except ValueError:
            return (0,)
    return max((ROOT / "api").glob("nova-api-*.json"), key=key)


def evaluate() -> dict:
    problems: list[str] = []
    checks: list[dict] = []

    def record(name: str, ok: bool, detail: str = "") -> None:
        checks.append({"check": name, "ok": ok, "detail": detail})
        if not ok:
            problems.append(f"{name}: {detail}")

    paths = {
        "quasar-pin.json": PIN_PATH, "cadence.json": CADENCE_PATH,
        "PARITY_CADENCE.md": CADENCE_VIEW, "breadth_taxonomy.json": TAXONOMY_PATH,
        "matrix.json": MATRIX_PATH, "breadth.json": BREADTH_PATH,
        "PARITY_BREADTH.md": BREADTH_VIEW,
    }
    for label, p in paths.items():
        if not p.exists():
            return {"status": "MISSING", "missing": label, "checks": checks}
    if not list((ROOT / "api").glob("nova-api-*.json")):
        return {"status": "MISSING", "missing": "api/nova-api-*.json", "checks": checks}

    pin = json.loads(PIN_PATH.read_text(encoding="utf-8"))
    cadence = json.loads(CADENCE_PATH.read_text(encoding="utf-8"))
    taxonomy = json.loads(TAXONOMY_PATH.read_text(encoding="utf-8"))
    matrix = json.loads(MATRIX_PATH.read_text(encoding="utf-8"))
    breadth = json.loads(BREADTH_PATH.read_text(encoding="utf-8"))
    cadence_view = CADENCE_VIEW.read_text(encoding="utf-8")
    breadth_view = BREADTH_VIEW.read_text(encoding="utf-8")

    gen_cadence = _load("gen_parity_cadence", SCRIPTS / "gen_parity_cadence.py")
    gen_breadth = _load("gen_parity_breadth", SCRIPTS / "gen_parity_breadth.py")
    drift = _load("check_upstream_drift", SCRIPTS / "check_upstream_drift.py")

    # ── D3 cadence ────────────────────────────────────────────
    record("cadence_ratified",
           cadence.get("schema") == "nova-upstream-cadence/1"
           and cadence.get("status") == "ratified",
           "cadence schema / status 非已核定")
    triggers = cadence.get("triggers", [])
    record("cadence_three_triggers",
           [t.get("id") for t in triggers] == ["T1", "T2", "T3"],
           "三档触发不是 T1 / T2 / T3")
    record("cadence_single_hard_gate",
           [t["id"] for t in triggers if t.get("blocking")] == ["T1"],
           "硬门必须且只能是 T1")
    record("cadence_t1_offline_t2_online",
           triggers[0].get("mode") == "offline" and triggers[1].get("mode") == "online"
           and triggers[2].get("mode") == "event",
           "T1 离线 / T2 在线 / T3 事件驱动的模式不符")
    sla = cadence.get("classification_sla", {})
    record("cadence_sla_covers_c0_c6",
           set(sla) == set(drift.CATEGORIES),
           "分级 SLA 与 C0~C6 分类器不对齐")
    blocking_sla = {k for k, v in sla.items() if v.get("blocking")}
    record("cadence_blocking_matches_drift",
           blocking_sla == set(drift.BLOCKING),
           f"阻断类不一致：cadence={sorted(blocking_sla)} / drift={sorted(drift.BLOCKING)}")
    record("cadence_non_goals_and_p3",
           bool(cadence.get("non_goals")) and bool(cadence.get("deferred_to_p3"))
           and any("自动化" in n for n in cadence["non_goals"]),
           "non_goals / P3 待办缺失，或未明确「不建自动化」")
    record("cadence_no_version_copy",
           "pinned_version" not in cadence and "observed_version" not in cadence,
           "cadence 复制了版本号（应只引用 quasar-pin.json）")

    sig = gen_cadence.stable_signature(cadence)
    m = re.search(r"cadence-signature:\s*([0-9a-f]+)", cadence_view)
    record("cadence_view_signature", m is not None and m.group(1) == sig,
           "cadence 视图签名缺失或不一致")
    record("cadence_view_body_matches_generator",
           gen_cadence.render_view(cadence) == cadence_view,
           "cadence 视图正文与生成器重渲染不一致（疑似手改生成物）")
    record("cadence_generator_idempotent", _generator_check("gen_parity_cadence.py"),
           "gen_parity_cadence.py --check 未 PASS")

    # ── P2 breadth ────────────────────────────────────────────
    record("breadth_signature",
           gen_breadth._stable_signature(breadth) == breadth.get("signature"),
           "breadth.json 稳定字段签名重算不一致")
    m2 = re.search(r"breadth-signature:\s*([0-9a-f]+)", breadth_view)
    record("breadth_view_signature", m2 is not None and m2.group(1) == breadth.get("signature"),
           "breadth 视图签名缺失或不一致")
    record("breadth_view_body_matches_generator",
           gen_breadth.render_view(breadth, taxonomy) == breadth_view,
           "breadth 视图正文与生成器重渲染不一致（疑似手改生成物）")
    record("breadth_generator_idempotent", _generator_check("gen_parity_breadth.py"),
           "gen_parity_breadth.py --check 未 PASS")

    rows = breadth["entries"]
    ms = matrix["summary"]
    bs = breadth["summary"]
    defined_layers = set(taxonomy["layer_definitions"])
    batch_ids = {b["id"] for b in taxonomy["batch_rules"]}
    orphan = [r["upstream"] for r in rows
              if not r.get("layer") or not r.get("family") or not r.get("batch")
              or r["layer"] not in defined_layers or r["batch"] not in batch_ids]
    record("breadth_zero_orphan", not orphan and len(rows) == 156,
           f"{len(orphan)} 条层级/批次归属悬空: {orphan[:5]}")
    record("breadth_matches_matrix_signature",
           breadth["sources"]["matrix_signature"] == matrix["signature"],
           "breadth 记录的矩阵签名与现盘不一致")
    record("breadth_matches_matrix_counts",
           bs["expanded_member_items"] == ms["expanded_member_items"] == 1932
           and bs["member_gap_items"] == ms["by_state"]["GAP"] == 862
           and bs["component_gap_entries"] == 53
           and bs["unexpanded_member_items"] == ms["unexpanded_member_items"] == 400,
           "156 / 1932 / 862 / 53 / 400 与矩阵不一致")
    record("breadth_batch_sum_conserved",
           sum(b["member_gap_items"] for b in breadth["batches"]) == 862
           and sum(b["component_gap_entries"] for b in breadth["batches"]) == 53
           and sum(b["entries"] for b in breadth["batches"]) == 156,
           "批次求和守恒被破坏")
    record("breadth_fallback_declared",
           bs["fallback_hits"] == sum(1 for r in rows if r.get("fallback")),
           "兜底命中数与逐条登记不一致")
    out_layers = {l["layer"] for l in breadth["layers"] if not l["in_dist_api"]}
    facets_layers = {f["layer"] for f in breadth["out_of_scope_facets"]}
    record("breadth_out_of_scope_disclosed",
           {"L0", "L5", "L6"} <= out_layers
           and {"L0", "L5", "L6"} <= facets_layers
           and all(l["entries"] == 0 for l in breadth["layers"]
                   if not l["in_dist_api"]),
           "面外层 L0/L5/L6 未如实登记（不得虚高为已覆盖）")
    record("breadth_layer_sum_156",
           sum(l["entries"] for l in breadth["layers"] if l["in_dist_api"]) == 156,
           "面内层条目求和不是 156")

    # ── 冻结面零漂移（本轮零 QML / 零 api/ 改动）──────────────
    freeze = json.loads(_latest_freeze().read_text(encoding="utf-8"))
    record("freeze_147_zero_drift",
           len(freeze.get("types", {})) == 147
           and freeze.get("fingerprint") == "9966483dda5a53c4"
           and freeze.get("baseline") == f"Quasar {pin['pinned_version']}",
           "冻结面 147 类型 / 指纹 / baseline 漂移")

    return {
        "status": "PASS" if not problems else "FAIL",
        "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "pinned_version": pin["pinned_version"],
        "observed_version": pin.get("observed_version"),
        "checks": checks,
        "problems": problems,
        "diagnostics": {
            "cadence_signature": sig[:16],
            "breadth_signature": breadth.get("signature", "")[:16],
            "entries": bs["upstream_entries"],
            "expanded": bs["expanded_member_items"],
            "gaps": bs["member_gap_items"],
            "component_gaps": bs["component_gap_entries"],
            "by_layer": bs["by_layer"],
            "by_batch": bs["by_batch"],
        },
        "note": "D3 节奏口径 + P2 广度台账结构门；P1 check_parity.py 的 19 项门禁保持零改动。",
    }


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="D3 节奏 + P2 广度台账结构门")
    ap.add_argument("--report", default="", help="结构化报告 JSON 输出路径（可选）")
    args = ap.parse_args(argv)

    report = evaluate()
    print("=" * 68)
    if report["status"] == "MISSING":
        print(f"  前置缺失：{report['missing']} → rc 2")
        return 2
    print(f"pyside-nova Parity Ops 门 · pinned={report['pinned_version']} "
          f"observed={report['observed_version']}")
    for c in report["checks"]:
        print(f"  [{'OK ' if c['ok'] else 'BAD'}] {c['check']}"
              + (f" · {c['detail']}" if not c["ok"] else ""))
    d = report["diagnostics"]
    print(f"  诊断：{d['entries']} 条目 · {d['expanded']} 逐项 · GAP {d['gaps']} · "
          f"组件级缺口 {d['component_gaps']}")
    print(f"  分层 {d['by_layer']} · 批次 {d['by_batch']}")
    print(f"  结论：{report['status']} · {report['note']}")
    print("=" * 68)

    if args.report:
        out = Path(args.report)
        if not out.is_absolute():
            out = ROOT / out
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n",
                       encoding="utf-8")
        print(f"  报告已写入：{out}")
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
