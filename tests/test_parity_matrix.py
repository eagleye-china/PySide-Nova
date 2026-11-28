# tests/test_parity_matrix.py
# T31 / P1：机读矩阵、视图、冻结面三方一致 + P0 组件集全表审计的机检固化
"""纯文件 / JSON 校验，不加载 Qt（避开坑位 49 全库 SIGSEGV 口径）。

法源：
- ``upstream/manifest-2.35.5.json``（官方 npm tarball 缓存，脚本计数）
- ``parity/scope.json``（手写唯一法源）
- ``parity/matrix.json`` + ``docs/PARITY_MATRIX.md``（生成物，禁手改）
- ``api/nova-api-1.11.0.json``（147 类型 / 指纹 ``9966483dda5a53c4``）
"""
from __future__ import annotations

import hashlib
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
STATES = {"ALIGNED", "MAPPED", "N/A", "GAP", "ENHANCEMENT"}


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


def _items(matrix: dict) -> list[dict]:
    return [i for e in matrix["entries"] for i in e.get("items", [])]


# ── 上游全量面事实源 ────────────────────────────────────────

def test_manifest_156_entries_and_cache_sha256_all_match():
    """上游全量面 156 条，且每个缓存文件 sha256 与 manifest 逐字一致（脚本计数、禁手写清单）。"""
    m = _read("upstream/manifest-2.35.5.json")
    assert m["pinned_version"] == "2.35.5"
    assert m["totals"]["files"] == len(m["entries"]) == 156
    assert m["totals"]["by_type"] == {"component": 123, "directive": 13, "plugin": 20}
    cache = ROOT / m["cache_dir"]
    for e in m["entries"]:
        raw = (cache / e["name"]).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == e["sha256"], e["name"]
        assert e["bytes"] == len(raw), e["name"]


def test_manifest_generator_is_idempotent():
    """manifest 生成器 --check 幂等；--refresh 属 P3，返回 rc 2（前置缺失，非产品红）。"""
    assert _run("gen_upstream_manifest.py", "--check").returncode == 0
    assert _run("gen_upstream_manifest.py", "--refresh").returncode == 2


def test_baseline_guard_six_of_six():
    """pinned=2.35.5 与 6 处历史硬编码口径一致；--apply 明确拒绝（rc 2，不回改史料）。"""
    r = _run("gen_upstream_baseline.py", "--check")
    assert r.returncode == 0, r.stdout
    assert "6/6 一致" in r.stdout
    assert _run("gen_upstream_baseline.py", "--apply").returncode == 2


# ── 矩阵 / 视图 / 冻结面三方一致 ────────────────────────────

def test_matrix_generator_is_idempotent_and_view_signature_matches():
    """gen_parity_matrix.py --check PASS；视图签名 == 矩阵签名（双向核对）。"""
    assert _run("gen_parity_matrix.py", "--check").returncode == 0
    matrix = _read("parity/matrix.json")
    view = (ROOT / "docs/PARITY_MATRIX.md").read_text(encoding="utf-8")
    m = re.search(r"parity-signature:\s*([0-9a-f]+)", view)
    assert m is not None and m.group(1) == matrix["signature"]


def test_view_hand_edit_is_detected_and_recovered():
    """手改视图正文（不只签名）会被 --check 与 check_parity 双重拦下；测试自恢复不留残影。"""
    view = ROOT / "docs" / "PARITY_MATRIX.md"
    original = view.read_text(encoding="utf-8")
    try:
        view.write_text(original + "\n<!-- hand edit probe -->\n", encoding="utf-8")
        assert _run("gen_parity_matrix.py", "--check").returncode == 1
        assert _run("check_parity.py").returncode == 1
    finally:
        view.write_text(original, encoding="utf-8")
    assert view.read_text(encoding="utf-8") == original
    assert _run("gen_parity_matrix.py", "--check").returncode == 0
    assert _run("check_parity.py").returncode == 0


def test_matrix_signature_recomputes_from_stable_fields():
    """签名由稳定字段重算得出（generated_at / signature 自身不参与），防手改生成物。"""
    gen = _load("gen_parity_matrix", SCRIPTS / "gen_parity_matrix.py")
    matrix = _read("parity/matrix.json")
    assert gen._stable_signature(matrix) == matrix["signature"]


def test_freeze_zero_drift_147_types():
    """冻结面 147 类型 / 指纹 9966483dda5a53c4 零漂移；P1 不改任何 QML 公共面。"""
    freeze = _read("api/nova-api-1.11.0.json")
    assert freeze["counts"]["total"] == len(freeze["types"]) == 147
    assert freeze["fingerprint"] == "9966483dda5a53c4"
    assert freeze["baseline"] == "Quasar 2.35.5"


def test_matrix_records_latest_freeze_and_manifest_signatures():
    """matrix 记录的法源文件名 / manifest 签名与现盘一致（三方一致的法源链）。"""
    matrix = _read("parity/matrix.json")
    manifest = _read("upstream/manifest-2.35.5.json")
    assert matrix["sources"]["nova_freeze"] == "nova-api-1.11.0.json"
    assert matrix["sources"]["upstream_manifest_signature"] == manifest["signature"]


# ── 五态机与零悬空 ──────────────────────────────────────────

def test_zero_orphan_rate_is_100_percent():
    """1932 逐项全部有五态归属；GAP 带优先级+里程碑、N/A 带理由码、ALIGNED 带 test_id。"""
    matrix = _read("parity/matrix.json")
    items = _items(matrix)
    assert items and matrix["summary"]["expanded_member_items"] == len(items)
    assert all(i["state"] in STATES for i in items)
    for i in items:
        if i["state"] == "GAP":
            assert i.get("priority") and i.get("milestone"), i
        elif i["state"] == "N/A":
            assert i.get("reason_code"), i
        elif i["state"] == "ALIGNED":
            assert i.get("test_ids"), i
    assert matrix["summary"]["orphans"] == 0
    assert matrix["summary"]["zero_orphan_rate"] == 1.0


def test_summary_by_state_matches_item_recomputation():
    """summary.by_state 与逐项重算一致（防生成物被手改）。"""
    matrix = _read("parity/matrix.json")
    computed = dict(Counter(i["state"] for i in _items(matrix)))
    assert computed == matrix["summary"]["by_state"]


def test_na_reason_codes_all_registered_in_scope():
    """每条 N/A 的理由码必须在 scope.json 理由码表内（法源链不留悬空）。"""
    matrix = _read("parity/matrix.json")
    scope = _read("parity/scope.json")
    codes = set(scope["na_reason_codes"])
    used = {i["reason_code"] for i in _items(matrix) if i["state"] == "N/A"}
    assert used and used <= codes, sorted(used - codes)


def test_all_aligned_test_ids_are_real_functions():
    """所有 ALIGNED 的 test_id 真实存在于 tests/*.py；45 项全部有绑定。"""
    matrix = _read("parity/matrix.json")
    defined: set[str] = set()
    for p in (ROOT / "tests").glob("*.py"):
        defined.update(re.findall(r"^def (test_\w+)\(",
                                  p.read_text(encoding="utf-8"), re.MULTILINE))
    aligned = [i for i in _items(matrix) if i["state"] == "ALIGNED"]
    bound = {t for i in aligned for t in i["test_ids"]}
    assert len(aligned) == matrix["summary"]["by_state"]["ALIGNED"] == 45
    assert bound and bound <= defined, sorted(bound - defined)


# ── P0 组件集全表审计 ───────────────────────────────────────

def test_p0_pairs_are_exactly_the_12_declared():
    """P0 集精确 12 条（按 nova+upstream 精确配对）；每条 disk_evidence 反查现盘一致。

    CSA 09:13 授权「按磁盘事实定」：条数读 scope.json::p0_pair_count，证据逐条与
    manifest / matrix.json / 冻结面 / 审计法源实测比对，法源链不留悬空、不虚填。
    """
    matrix = _read("parity/matrix.json")
    scope = _read("parity/scope.json")
    declared = {(p["nova"], p["upstream"]) for p in scope["p0_pairs"]}
    actual = {(e["nova"], e["upstream"]) for e in matrix["entries"] if e["p0"]}
    assert len(declared) == len(actual) == scope["p0_pair_count"] == 12
    assert actual == declared, sorted(actual ^ declared)
    assert matrix["summary"]["p0"]["pairs"] == scope["p0_pair_count"]

    manifest = _read("upstream/manifest-2.35.5.json")
    freeze = _read("api/nova-api-1.11.0.json")["types"]
    mf = {e["name"]: e for e in manifest["entries"]}
    me = {e["upstream"]: e for e in matrix["entries"]}
    for p in scope["p0_pairs"]:
        ev = p["disk_evidence"]
        assert (ROOT / "upstream/cache/api-2.35.5" / p["upstream"]).exists()
        assert p["nova"] in freeze
        assert ev["upstream_type"] == mf[p["upstream"]]["upstream_type"]
        assert ev["upstream_member_counts"] == mf[p["upstream"]]["member_counts"]
        assert ev["expanded_member_items"] == me[p["upstream"]]["expanded_member_items"]
        assert ev["by_state"] == me[p["upstream"]]["by_state"]
        assert ev["freeze_members"] == {
            k: len(freeze[p["nova"]].get(k, [])) for k in ("props", "signals", "methods")
        }
        assert ev["audit_anchor"] in (ROOT / ev["audit_source"]).read_text(encoding="utf-8")


def test_qdialog_component_uses_explicit_override_not_services_singleton():
    """QDialog.json 走 mapping_override → NovaDialogShell（PARITY.md:726/733 命名红线），不误入 P0。"""
    matrix = _read("parity/matrix.json")
    scope = _read("parity/scope.json")
    e = next(x for x in matrix["entries"] if x["upstream"] == "QDialog.json")
    assert scope["mapping_overrides"]["QDialog.json"] == "Nova.Controls.NovaDialogShell"
    assert e["nova"] == "Nova.Controls.NovaDialogShell"
    assert e["p0"] is False
    plugin = next(x for x in matrix["entries"] if x["upstream"] == "Dialog.json")
    assert plugin["nova"] == "Nova.Services.NovaDialog" and plugin["p0"] is True


def test_p0_gap_list_is_complete_and_prioritized():
    """p0_gaps 与逐项重算一致，每条带 P1 优先级与封版里程碑（逐项欠账清单可机检）。"""
    matrix = _read("parity/matrix.json")
    scope = _read("parity/scope.json")
    computed = [i for e in matrix["entries"] if e["p0"] for i in e["items"]
                if i["state"] == "GAP"]
    gaps = matrix["p0_gaps"]
    assert len(gaps) == len(computed) == matrix["summary"]["p0"]["gap_count"]
    assert gaps
    for g in gaps:
        assert g["priority"] == scope["priority_rules"]["p0_member_gap_priority"]
        assert g["milestone"] == scope["priority_rules"]["p0_milestone"]
        assert g["reason_code"] == "NO_MEMBER"


def test_coverage_arithmetic_excludes_gap_from_explainable():
    """可解释 = (ALIGNED+MAPPED+N/A)/全量项，GAP 不计入（不圆场、不虚高）。"""
    matrix = _read("parity/matrix.json")
    s = matrix["summary"]
    b = s["by_state"]
    total = s["expanded_member_items"]
    expected = round((b["ALIGNED"] + b["MAPPED"] + b["N/A"]) / total, 6)
    assert s["coverage"]["explainable"] == expected
    assert s["applicable_items"] == total - b["N/A"]
    assert s["coverage"]["literal"] == round(b["ALIGNED"] / s["applicable_items"], 6)
    assert s["coverage"]["test_frozen"] == s["coverage"]["literal"]


# ── 口径差异登记与门禁端到端 ────────────────────────────────

def test_two_law_sources_difference_is_documented_not_reconciled():
    """T28 源 json 与 npm dist/api 发布面的计数差异并列登记，史料不回改。"""
    view = (ROOT / "docs/PARITY_MATRIX.md").read_text(encoding="utf-8")
    assert "| QTable props | 63 | **65** |" in view
    assert "| QTable events | 9 | **11**" in view
    assert "| QTable methods | 15 | **17**" in view
    assert "| QSelect props | 47" in view and "**92**" in view
    assert "两个法源，不是谁错了" in view
    qtable = json.loads((ROOT / "upstream/cache/api-2.35.5/QTable.json").read_text(encoding="utf-8"))
    assert (len(qtable["props"]), len(qtable["slots"]),
            len(qtable["events"]), len(qtable["methods"])) == (65, 21, 11, 17)


def test_check_parity_gate_is_green():
    """check_parity.py 端到端 PASS；--report 分支可写结构化报告（临时、自清）。"""
    r = _run("check_parity.py")
    assert r.returncode == 0, r.stdout + r.stderr
    assert "结论：PASS" in r.stdout
    out = ROOT / "upstream" / "reports" / "_p1_check_tmp.json"
    try:
        assert _run("check_parity.py", "--report", str(out)).returncode == 0
        assert json.loads(out.read_text(encoding="utf-8"))["status"] == "PASS"
    finally:
        out.unlink(missing_ok=True)


def test_scope_gate_policy_is_diagnostic_not_silent_watering_down():
    """P1 门禁口径显式登记：覆盖率仅报告不阻断、GAP 不算可解释、阈值提升留 P2/P3。"""
    scope = _read("parity/scope.json")
    gp = scope["gate_policy"]
    assert gp["phase"] == "P1-diagnostic"
    assert any("zero_orphan_rate" in b for b in gp["blocking"])
    assert "三档覆盖率" in gp["reported_not_blocking"]
    assert "GAP 不计入可解释" in scope["coverage_definitions"]["explainable_coverage"]
    assert "P2" in gp["next"] and "P3" in gp["next"]
