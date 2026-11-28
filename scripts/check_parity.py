#!/usr/bin/env python3
# scripts/check_parity.py
# Parity Ops L-D：机读矩阵门禁（结构完整性阻断，覆盖率为诊断输出）
"""``parity/matrix.json`` 门禁。P1 诊断期的阻断项与仅报告项见
``parity/scope.json::gate_policy``——**不把 GAP 算成可解释来凑 100%**。

用法::

    python scripts/check_parity.py                 # 交付前门禁
    python scripts/check_parity.py --report x.json # 附结构化报告

退出码：0 = PASS；1 = 产品红（结构完整性 / 三方一致 / 法源链问题）；2 = 前置缺失。
"""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
from collections import Counter
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "scripts"
MATRIX_PATH = ROOT / "parity" / "matrix.json"
SCOPE_PATH = ROOT / "parity" / "scope.json"
VIEW_PATH = ROOT / "docs" / "PARITY_MATRIX.md"
PIN_PATH = ROOT / "upstream" / "quasar-pin.json"
STATES = {"ALIGNED", "MAPPED", "N/A", "GAP", "ENHANCEMENT"}


def _load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def real_test_ids(root: Path = ROOT) -> set[str]:
    out: set[str] = set()
    for path in sorted((root / "tests").glob("*.py")):
        out.update(re.findall(r"^def (test_\w+)\(",
                              path.read_text(encoding="utf-8"), re.MULTILINE))
    return out


def evaluate(root: Path = ROOT) -> dict:
    problems: list[str] = []
    checks: list[dict] = []

    def record(name: str, ok: bool, detail: str = "") -> None:
        checks.append({"check": name, "ok": ok, "detail": detail})
        if not ok:
            problems.append(f"{name}: {detail}")

    for label, path in (("matrix.json", MATRIX_PATH), ("scope.json", SCOPE_PATH),
                        ("PARITY_MATRIX.md", VIEW_PATH), ("quasar-pin.json", PIN_PATH)):
        if not path.exists():
            return {"status": "MISSING", "missing": label, "checks": checks}

    matrix = json.loads(MATRIX_PATH.read_text(encoding="utf-8"))
    scope = json.loads(SCOPE_PATH.read_text(encoding="utf-8"))
    view_text = VIEW_PATH.read_text(encoding="utf-8")
    pin = json.loads(PIN_PATH.read_text(encoding="utf-8"))
    gen = _load_module("gen_parity_matrix", SCRIPTS / "gen_parity_matrix.py")

    # 1. 矩阵签名（重算稳定字段）
    record("matrix_signature", gen._stable_signature(matrix) == matrix.get("signature"),
           "稳定字段 sha256 重算不一致")

    # 2. 视图签名一致（三方一致之「视图」）
    m = re.search(r"parity-signature:\s*([0-9a-f]+)", view_text)
    record("view_signature", m is not None and m.group(1) == matrix.get("signature"),
           "视图签名缺失或与矩阵不一致")
    record("view_body_matches_generator", gen.render_view(matrix, scope) == view_text,
           "视图正文与生成器重渲染不一致（疑似手改生成物）")

    # 3. 上游 manifest 签名 + 156 个缓存文件 sha256 全量核对
    manifest_path = root / "upstream" / f"manifest-{pin['pinned_version']}.json"
    if not manifest_path.exists():
        record("upstream_manifest", False, "manifest 缺失")
    else:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        record("manifest_signature_in_matrix",
               manifest.get("signature") == matrix["sources"].get("upstream_manifest_signature"),
               "matrix 记录的 manifest 签名与现盘不一致")
        cache = root / manifest["cache_dir"]
        bad: list[str] = []
        for e in manifest["entries"]:
            p = cache / e["name"]
            if not p.exists() or _sha256(p.read_bytes()) != e["sha256"]:
                bad.append(e["name"])
        record("cache_sha256_all", not bad, f"{len(bad)} 个文件校验失败: {bad[:5]}")
        record("manifest_file_count",
               manifest["totals"]["files"] == len(manifest["entries"]) == matrix["summary"]["upstream_entries"],
               "156 条上游条目计数不一致")

    # 4. 冻结面三方一致之「冻结面」：文件自动探测 + 147 类型零漂移
    freeze_files = sorted((root / "api").glob("nova-api-*.json"),
                          key=lambda p: tuple(int(x) for x in p.stem.split("-")[-1].split(".")))
    latest = freeze_files[-1] if freeze_files else None
    freeze = json.loads(latest.read_text(encoding="utf-8")) if latest else {}
    record("freeze_source_is_latest",
           latest is not None and latest.name == matrix["sources"].get("nova_freeze"),
           "matrix 记录的冻结面不是最新探测文件")
    record("freeze_147_types",
           len(freeze.get("types", {})) == 147 and freeze.get("counts", {}).get("total") == 147,
           "冻结面类型数不是 147")
    record("freeze_fingerprint",
           freeze.get("fingerprint") == "9966483dda5a53c4",
           f"冻结面指纹漂移：{freeze.get('fingerprint')}")

    # 5. 零悬空率 / 五态合法性 / 法源完整性（逐项重算，不信任 summary）
    items = [i for e in matrix["entries"] for i in e.get("items", [])]
    invalid = [i for i in items if i.get("state") not in STATES]
    record("states_valid", not invalid, f"{len(invalid)} 项状态非法")
    orphan = [
        i for i in items
        if (i.get("state") == "GAP" and not (i.get("priority") and i.get("milestone")))
        or (i.get("state") == "ALIGNED" and not i.get("test_ids"))
        or (i.get("state") == "N/A" and not i.get("reason_code"))
    ]
    record("zero_orphan_rate", not orphan, f"{len(orphan)} 项悬空（GAP 缺优先级/里程碑等）")

    # 6. 机检绑定率 100%：所有 ALIGNED 的 test_id 真实存在
    tests = real_test_ids(root)
    bound = {t for i in items if i.get("state") == "ALIGNED" for t in i.get("test_ids", [])}
    dangling = sorted(bound - tests)
    record("test_ids_real", not dangling, f"悬空 test_id: {dangling[:5]}")
    record("aligned_has_test_id",
           all(i.get("test_ids") for i in items if i.get("state") == "ALIGNED"),
           "存在无 test_id 的 ALIGNED")

    # 7. N/A 理由码必须在 scope 法源表内
    codes = set(scope["na_reason_codes"])
    bad_codes = sorted({i["reason_code"] for i in items
                        if i.get("state") == "N/A" and i.get("reason_code") not in codes})
    record("na_reason_codes_legal", not bad_codes, f"未登记理由码: {bad_codes}")

    # 8. P0 集：条数以 scope.json 白名单为唯一法源（不硬编码），配对精确一致，
    #    且每条须带完整的磁盘事实证据结构（CSA 09:13「按磁盘事实定」的结构门）。
    p0 = [e for e in matrix["entries"] if e.get("p0")]
    declared = {(p["nova"], p["upstream"]) for p in scope["p0_pairs"]}
    actual = {(e["nova"], e["upstream"]) for e in p0}
    count_ok = len(p0) == scope["p0_pair_count"] == len(scope["p0_pairs"])
    evidence_ok = all(
        isinstance(p.get("disk_evidence"), dict)
        and p["disk_evidence"].get("upstream_type")
        and isinstance(p["disk_evidence"].get("upstream_member_counts"), dict)
        and isinstance(p["disk_evidence"].get("freeze_members"), dict)
        and isinstance(p["disk_evidence"].get("by_state"), dict)
        and p["disk_evidence"].get("audit_source")
        and p["disk_evidence"].get("audit_anchor")
        for p in scope["p0_pairs"]
    )
    record("p0_pairs_exact", count_ok and evidence_ok and actual == declared,
           f"P0 配对不符：{len(p0)} 条 / 白名单 {len(scope['p0_pairs'])} 条，"
           f"证据结构完整={evidence_ok}，差集 {sorted(actual ^ declared)[:5]}")
    record("p0_items_all_classified",
           all(i.get("state") in STATES for e in p0 for i in e["items"]),
           "P0 集存在未判定项")

    # 9. summary 与逐项重算一致（防手改生成物）
    by_state = Counter(i["state"] for i in items)
    record("summary_by_state_consistent",
           dict(by_state) == {k: v for k, v in matrix["summary"]["by_state"].items()},
           "summary.by_state 与逐项重算不一致")
    record("summary_zero_orphan_consistent",
           matrix["summary"]["zero_orphan_rate"] == 1.0 and not orphan,
           "summary 零悬空率与逐项重算不一致")

    # 10. mapping_overrides 生效（QDialog 组件不得落到 Services 单例）
    qdialog = next((e for e in matrix["entries"] if e["upstream"] == "QDialog.json"), None)
    record("qdialog_override",
           qdialog is not None and qdialog["nova"] == "Nova.Controls.NovaDialogShell"
           and not qdialog.get("p0"),
           "QDialog.json 未走 mapping_override 或被误纳入 P0")

    s = matrix["summary"]
    status = "PASS" if not problems else "FAIL"
    return {
        "status": status,
        "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "signature": matrix.get("signature"),
        "pinned_version": pin["pinned_version"],
        "observed_version": pin.get("observed_version"),
        "checks": checks,
        "problems": problems,
        "diagnostics": {
            "upstream_entries": s["upstream_entries"],
            "expanded_member_items": s["expanded_member_items"],
            "by_state": s["by_state"],
            "zero_orphan_rate": s["zero_orphan_rate"],
            "coverage": s["coverage"],
            "p0": s["p0"],
        },
        "note": "P1 诊断期：覆盖率为真实诊断输出（不阻断）；阻断项 = 结构完整性 / 三方一致 / 法源链。",
    }


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Parity 机读矩阵门禁")
    ap.add_argument("--report", default="", help="结构化报告 JSON 输出路径（可选）")
    args = ap.parse_args(argv)

    report = evaluate()
    print("=" * 68)
    print(f"pyside-nova Parity 门 · pinned={report.get('pinned_version')} "
          f"observed={report.get('observed_version')}")
    if report["status"] == "MISSING":
        print(f"  前置缺失：{report['missing']} → rc 2")
        return 2
    for c in report["checks"]:
        print(f"  [{'OK ' if c['ok'] else 'BAD'}] {c['check']}"
              + (f" · {c['detail']}" if not c["ok"] else ""))
    d = report["diagnostics"]
    print(f"  诊断：{d['upstream_entries']} 条目 · {d['expanded_member_items']} 逐项 · "
          f"零悬空 {d['zero_orphan_rate'] * 100:.2f}% · by_state={d['by_state']}")
    print(f"  覆盖率：字面 {d['coverage']['literal'] * 100:.2f}% · "
          f"可解释 {d['coverage']['explainable'] * 100:.2f}% · "
          f"机检固化 {d['coverage']['test_frozen'] * 100:.2f}%")
    print(f"  P0：{d['p0']['pairs']} 配对 · {d['p0']['items']} 项 · "
          f"GAP {d['p0']['gap_count']} · "
          f"可解释 {d['p0']['coverage']['explainable'] * 100:.2f}% · "
          f"机检固化 {d['p0']['coverage']['test_frozen'] * 100:.2f}%")
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
