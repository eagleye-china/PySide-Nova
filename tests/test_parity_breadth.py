# tests/test_parity_breadth.py
# 09:37 · D3 跟进节奏核定 + P2 全生态广度台账的机检固化
"""纯文件 / JSON 校验，不加载 Qt（避开坑位 49 全库 SIGSEGV 口径）。

法源：
- ``upstream/cadence.json``（D3 唯一手写法源）+ ``docs/PARITY_CADENCE.md``（生成物）
- ``parity/breadth_taxonomy.json``（L0~L6 分层 / 批次规则，唯一手写法源）
- ``parity/matrix.json`` / ``parity/breadth.json`` / ``docs/PARITY_BREADTH.md``（生成物）
- ``api/nova-api-1.11.0.json``（147 类型 / 指纹 ``9966483dda5a53c4``）
"""
from __future__ import annotations

import importlib.util
import json
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"
PY = sys.executable


def _run(script: str, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run([PY, str(SCRIPTS / script), *args], check=False,
                          cwd=ROOT, capture_output=True, text=True)


def _load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def _read(rel: str):
    return json.loads((ROOT / rel).read_text(encoding="utf-8"))


# ── D3 跟进节奏 ─────────────────────────────────────────────

def test_cadence_is_ratified_with_three_triggers_and_single_hard_gate():
    """D3 已核定：T1 交付前离线硬门（唯一阻断）/ T2 每周在线周巡 / T3 事件即时响应。"""
    c = _read("upstream/cadence.json")
    assert c["schema"] == "nova-upstream-cadence/1"
    assert c["status"] == "ratified"
    assert [t["id"] for t in c["triggers"]] == ["T1", "T2", "T3"]
    assert [t["id"] for t in c["triggers"] if t["blocking"]] == ["T1"]
    assert [t["mode"] for t in c["triggers"]] == ["offline", "online", "event"]
    assert c["triggers"][1]["status"] == "institutionalized"
    assert "≤1 工作日" in c["triggers"][1]["sla"]


def test_cadence_sla_covers_c0_c6_and_blocking_matches_classifier():
    """分级 SLA 必须覆盖 C0~C6，阻断类与 check_upstream_drift.py::BLOCKING 完全一致。"""
    c = _read("upstream/cadence.json")
    drift = _load("check_upstream_drift", SCRIPTS / "check_upstream_drift.py")
    assert set(c["classification_sla"]) == set(drift.CATEGORIES)
    assert {k for k, v in c["classification_sla"].items() if v["blocking"]} == set(drift.BLOCKING)
    assert c["gate_contract"]["no_rerun_redline"].startswith("C3 / C4 / C6")
    assert "C0" in c["gate_contract"]["resolution_requirement"]


def test_cadence_does_not_copy_version_and_defers_automation_to_p3():
    """版本事实源唯一（quasar-pin.json）；本轮不建自动化，周期自动化明确留 P3。"""
    c = _read("upstream/cadence.json")
    assert "pinned_version" not in c and "observed_version" not in c
    assert c["scope_ref"].startswith("upstream/quasar-pin.json")
    assert any("本轮创建定时自动化任务" in n for n in c["non_goals"])
    assert any("自动化" in d for d in c["deferred_to_p3"])
    pin = _read("upstream/quasar-pin.json")
    assert pin["pinned_version"] == "2.35.5" and pin["observed_version"] == "2.36.0"


def test_cadence_view_is_generator_produced_and_hand_edit_detected():
    """cadence 视图签名 + 全文双向核对；手改正文会被 --check 与结构门双重拦下，测试自恢复。"""
    c = _read("upstream/cadence.json")
    gen = _load("gen_parity_cadence", SCRIPTS / "gen_parity_cadence.py")
    view = ROOT / "docs" / "PARITY_CADENCE.md"
    original = view.read_text(encoding="utf-8")
    sig = gen.stable_signature(c)
    m = re.search(r"cadence-signature:\s*([0-9a-f]+)", original)
    assert m is not None and m.group(1) == sig
    assert gen.render_view(c) == original
    assert _run("gen_parity_cadence.py", "--check").returncode == 0
    try:
        view.write_text(original + "\n<!-- hand edit probe -->\n", encoding="utf-8")
        assert _run("gen_parity_cadence.py", "--check").returncode == 1
        assert _run("check_parity_ops.py").returncode == 1
    finally:
        view.write_text(original, encoding="utf-8")
    assert view.read_text(encoding="utf-8") == original
    assert _run("check_parity_ops.py").returncode == 0


# ── P2 广度台账 ─────────────────────────────────────────────

def test_breadth_real_numbers_match_matrix_exactly():
    """156 / 1932 / 400 / 862 / 53 与矩阵逐项重算一致（脚本计数，禁手写清单）。"""
    b = _read("parity/breadth.json")
    m = _read("parity/matrix.json")
    assert len(b["entries"]) == m["summary"]["upstream_entries"] == 156
    assert b["sources"]["matrix_signature"] == m["signature"]
    assert m["signature"].startswith("35548a2652c9dd63")  # 矩阵签名零漂移
    assert sum(r["expanded_member_items"] for r in b["entries"]) == 1932
    assert sum(r["unexpanded_member_items"] for r in b["entries"]) == 400
    assert sum(r["gap_items"] for r in b["entries"]) == 862
    assert sum(1 for r in b["entries"] if r["reason_code"] == "NO_NOVA_COUNTERPART") == 53
    assert b["summary"]["by_state"] == m["summary"]["by_state"]
    assert b["summary"]["fallback_hits"] == 0


def test_breadth_every_entry_has_layer_family_batch_zero_orphan():
    """156 条逐条有层级 / 功能族 / 批次归属，零悬空 100%；层必须在七层定义内。"""
    b = _read("parity/breadth.json")
    tax = _read("parity/breadth_taxonomy.json")
    layers = set(tax["layer_definitions"])
    batches = {r["id"] for r in tax["batch_rules"]}
    for r in b["entries"]:
        assert r["layer"] in layers, r["upstream"]
        assert r["family"] and r["batch"] in batches, r["upstream"]
    assert b["summary"]["zero_orphan_rate"] == 1.0
    assert dict(Counter(r["layer"] for r in b["entries"])) == b["summary"]["by_layer"]
    assert sum(l["entries"] for l in b["layers"] if l["in_dist_api"]) == 156


def test_breadth_layer_split_is_l1_13_l2_110_l3_13_l4_20():
    """分层结果可复算：L1 布局 13 / L2 组件 110 / L3 指令 13 / L4 插件 20。"""
    b = _read("parity/breadth.json")
    assert b["summary"]["by_layer"] == {"L1": 13, "L2": 110, "L3": 13, "L4": 20}
    assert all(l["entries"] == 0 for l in b["layers"] if not l["in_dist_api"])
    # 指令与插件各自整层归属
    assert {r["layer"] for r in b["entries"] if r["upstream_type"] == "directive"} == {"L3"}
    assert {r["layer"] for r in b["entries"] if r["upstream_type"] == "plugin"} == {"L4"}


def test_breadth_out_of_scope_layers_disclosed_not_inflated():
    """L0 / L5 / L6 面外层如实列出（含 L5 漏复核的 T30 实证），不计入分子。"""
    b = _read("parity/breadth.json")
    facets = {f["layer"] for f in b["out_of_scope_facets"]}
    assert {"L0", "L5", "L6"} <= facets
    l5 = next(f for f in b["out_of_scope_facets"] if f["layer"] == "L5")
    assert "T30" in l5["why_outside"] and "humanStorageSize" in l5["why_outside"]
    assert "不虚高" in b["coverage_discipline"]["honest_boundary"]
    assert b["coverage_discipline"]["listed_not_completed"].startswith("本轮是")


def test_breadth_batch_sum_conserved_and_p0_gate_prerequisite():
    """四批次 GAP 求和 = 862、组件级缺口求和 = 53、条目求和 = 156；B1 是封版前置。"""
    b = _read("parity/breadth.json")
    assert sum(x["member_gap_items"] for x in b["batches"]) == 862
    assert sum(x["component_gap_entries"] for x in b["batches"]) == 53
    assert sum(x["entries"] for x in b["batches"]) == 156
    b1 = next(x for x in b["batches"] if x["id"] == "B1")
    assert b1["entries"] == 12 and b1["member_gap_items"] == 267  # D1 封版前置
    assert b1["priority"] == "P1"
    b3 = next(x for x in b["batches"] if x["id"] == "B3")
    assert b3["entries"] == 53 and b3["component_gap_entries"] == 53


def test_breadth_view_is_generator_produced_and_hand_edit_detected():
    """breadth 视图签名 + 全文双向核对；手改正文被双重拦下，测试自恢复无残影。"""
    b = _read("parity/breadth.json")
    tax = _read("parity/breadth_taxonomy.json")
    gen = _load("gen_parity_breadth", SCRIPTS / "gen_parity_breadth.py")
    view = ROOT / "docs" / "PARITY_BREADTH.md"
    original = view.read_text(encoding="utf-8")
    assert gen._stable_signature(b) == b["signature"]
    m = re.search(r"breadth-signature:\s*([0-9a-f]+)", original)
    assert m is not None and m.group(1) == b["signature"]
    assert gen.render_view(b, tax) == original
    assert _run("gen_parity_breadth.py", "--check").returncode == 0
    try:
        view.write_text(original + "\n<!-- hand edit probe -->\n", encoding="utf-8")
        assert _run("gen_parity_breadth.py", "--check").returncode == 1
        assert _run("check_parity_ops.py").returncode == 1
    finally:
        view.write_text(original, encoding="utf-8")
    assert view.read_text(encoding="utf-8") == original
    assert _run("check_parity_ops.py").returncode == 0


def test_parity_ops_gate_is_green_and_report_branch_works():
    """结构门端到端 PASS；--report 输出结构化报告（临时、自清）。"""
    r = _run("check_parity_ops.py")
    assert r.returncode == 0, r.stdout + r.stderr
    assert "结论：PASS" in r.stdout
    assert "P1 check_parity.py" in r.stdout
    out = ROOT / "upstream" / "reports" / "_p2_check_tmp.json"
    try:
        assert _run("check_parity_ops.py", "--report", str(out)).returncode == 0
        d = json.loads(out.read_text(encoding="utf-8"))
        assert d["status"] == "PASS"
        assert len(d["checks"]) >= 20 and all(c["ok"] for c in d["checks"])
    finally:
        out.unlink(missing_ok=True)


def test_p1_gate_unchanged_and_freeze_zero_drift():
    """P1 的 19 项门禁零改动且仍全绿；冻结面 147 类型 / 指纹零漂移。"""
    r = _run("check_parity.py", "--report", str(ROOT / "upstream" / "reports" / "_p1_tmp.json"))
    assert r.returncode == 0, r.stdout + r.stderr
    tmp = ROOT / "upstream" / "reports" / "_p1_tmp.json"
    try:
        d = json.loads(tmp.read_text(encoding="utf-8"))
        assert d["status"] == "PASS" and len(d["checks"]) == 19
    finally:
        tmp.unlink(missing_ok=True)
    freeze = _read("api/nova-api-1.11.0.json")
    assert freeze["counts"]["total"] == len(freeze["types"]) == 147
    assert freeze["fingerprint"] == "9966483dda5a53c4"
    assert freeze["baseline"] == "Quasar 2.35.5"
