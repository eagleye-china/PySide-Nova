#!/usr/bin/env python3
# scripts/gen_parity_breadth.py
# Parity Ops P2：全生态广度台账（脚本计数，禁手写清单）→ 机读 breadth.json + 现行视图
"""生成 ``parity/breadth.json`` 与 ``docs/PARITY_BREADTH.md``（均为生成物，禁手改）。

**输入（全部机读 / 手写唯一法源）**：

1. ``parity/matrix.json`` —— T31 五态逐项矩阵（156 条 / 1932 逐项 / 862 GAP）
2. ``upstream/manifest-2.35.5.json`` —— 上游全量面（脚本计数）
3. ``parity/breadth_taxonomy.json`` —— **唯一手写法源**：L0~L6 分层规则 + 功能族 + 批次规则 + 面外清单
4. ``api/nova-api-1.11.0.json`` —— 冻结面 147 类型（自动探测，禁手写版本号）

**纪律**：逐条清单全部由矩阵脚本计数得出，不手写 156 条；L0/L5/L6 等
``dist/api`` 之外的生态面如实列为「面外未纳入」，绝不虚高全量面。

用法::

    python scripts/gen_parity_breadth.py           # 生成 breadth.json + 视图
    python scripts/gen_parity_breadth.py --check  # 幂等校验（重渲染全文双向核对，不写盘）

退出码：0 = 成功 / 一致；1 = 幂等漂移 / 法源链悬空 / 层级未 100% 覆盖；2 = 前置缺失。
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from collections import Counter
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PIN_PATH = ROOT / "upstream" / "quasar-pin.json"
SCOPE_TAXONOMY = ROOT / "parity" / "breadth_taxonomy.json"
MATRIX_PATH = ROOT / "parity" / "matrix.json"
BREADTH_PATH = ROOT / "parity" / "breadth.json"
VIEW_PATH = ROOT / "docs" / "PARITY_BREADTH.md"


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _stable_signature(doc: dict) -> str:
    stable = {k: v for k, v in doc.items()
              if k not in ("signature", "generated_at")}
    return _sha256(json.dumps(stable, sort_keys=True, ensure_ascii=False).encode("utf-8"))


def _latest_freeze(root: Path = ROOT) -> Path:
    """复用 migrate2nova 自动探测范式：禁手写版本清单。"""
    def key(p: Path):
        try:
            return tuple(int(x) for x in p.stem.split("-")[-1].split("."))
        except ValueError:
            return (0,)
    files = sorted((root / "api").glob("nova-api-*.json"), key=key)
    return files[-1]


def classify(entry: dict, taxonomy: dict) -> tuple[str, str, bool]:
    """按规则表判定 (layer, family, 是否兜底)；规则表即法源，顺序优先。"""
    stem = entry["upstream"][:-5]
    for rule in taxonomy["layer_rules"]:
        when = rule.get("when", {})
        if when and all(entry.get(k) == v for k, v in when.items()):
            return rule["layer"], rule["family"], False
        rx = rule.get("name_regex")
        if rx and re.search(rx, stem):
            return rule["layer"], rule["family"], False
    d = taxonomy["default_rule"]
    return d["layer"], d["family"], True


def batch_of(entry: dict, gap_items: int, taxonomy: dict) -> str:
    """按批次规则表判定；顺序即优先级。"""
    ctx = {
        "p0": bool(entry.get("p0")),
        "reason_code": entry.get("reason_code"),
        "has_gap": gap_items > 0,
    }
    for rule in taxonomy["batch_rules"]:
        when = rule["when"]
        if all(ctx.get(k) == v for k, v in when.items()):
            return rule["id"]
    raise ValueError(f"批次规则未覆盖：{entry['upstream']}")


def build(root: Path = ROOT) -> tuple[dict, str]:
    pin = json.loads(PIN_PATH.read_text(encoding="utf-8"))
    version = pin["pinned_version"]
    matrix = json.loads(MATRIX_PATH.read_text(encoding="utf-8"))
    taxonomy = json.loads(SCOPE_TAXONOMY.read_text(encoding="utf-8"))
    manifest = json.loads((root / "upstream" / f"manifest-{version}.json")
                          .read_text(encoding="utf-8"))
    freeze_file = _latest_freeze(root)
    freeze = json.loads(freeze_file.read_text(encoding="utf-8"))["types"]

    rows: list[dict] = []
    fallback_hits = 0
    for e in matrix["entries"]:
        layer, family, fallback = classify(e, taxonomy)
        if fallback:
            fallback_hits += 1
        by_state = e.get("by_state", {})
        gap_items = by_state.get("GAP", 0)
        gaps = [i for i in e.get("items", []) if i.get("state") == "GAP"]
        priority = e.get("priority") or (gaps[0].get("priority") if gaps else "—")
        milestone = e.get("milestone") or (gaps[0].get("milestone") if gaps else "—")
        rows.append({
            "upstream": e["upstream"],
            "upstream_type": e["upstream_type"],
            "nova": e.get("nova"),
            "p0": bool(e.get("p0")),
            "state": e["state"],
            "reason_code": e.get("reason_code"),
            "layer": layer,
            "family": family,
            "fallback": fallback,
            "expanded_member_items": e.get("expanded_member_items", 0),
            "unexpanded_member_items": e.get("unexpanded_member_items", 0),
            "by_state": dict(sorted(by_state.items())),
            "gap_items": gap_items,
            "priority": priority,
            "milestone": milestone,
            "batch": batch_of(e, gap_items, taxonomy),
        })

    # 零悬空：每条必须有 layer / family / batch，且 layer 必须在七层定义内
    defined_layers = set(taxonomy["layer_definitions"])
    orphan = [r["upstream"] for r in rows
              if not r["layer"] or not r["family"] or not r["batch"]
              or r["layer"] not in defined_layers]
    if orphan:
        raise ValueError(f"层级归属悬空：{orphan[:5]}")

    by_layer = Counter(r["layer"] for r in rows)
    by_family = Counter(r["family"] for r in rows)
    by_batch = Counter(r["batch"] for r in rows)
    gap_by_batch = Counter()
    component_gap_by_batch = Counter()
    for r in rows:
        gap_by_batch[r["batch"]] += r["gap_items"]
        if r["reason_code"] == "NO_NOVA_COUNTERPART":
            component_gap_by_batch[r["batch"]] += 1

    layer_rows = []
    for code, meta in taxonomy["layer_definitions"].items():
        sub = [r for r in rows if r["layer"] == code]
        layer_rows.append({
            "layer": code,
            "name": meta["name"],
            "in_dist_api": meta["in_dist_api"],
            "scope": meta["scope"],
            "entries": len(sub),
            "expanded_member_items": sum(r["expanded_member_items"] for r in sub),
            "unexpanded_member_items": sum(r["unexpanded_member_items"] for r in sub),
            "gap_items": sum(r["gap_items"] for r in sub),
            "component_gap_entries": sum(1 for r in sub
                                         if r["reason_code"] == "NO_NOVA_COUNTERPART"),
            "note": ("面内 · 由 dist/api 条目逐条归属" if meta["in_dist_api"]
                     else "面外 · dist/api 不含此层，见 out_of_scope_facets（不虚高）"),
        })

    batch_rows = []
    for rule in taxonomy["batch_rules"]:
        bid = rule["id"]
        batch_rows.append({
            "id": bid,
            "name": rule["name"],
            "priority": rule["priority"],
            "note": rule["note"],
            "entries": by_batch.get(bid, 0),
            "member_gap_items": gap_by_batch.get(bid, 0),
            "component_gap_entries": component_gap_by_batch.get(bid, 0),
        })

    s = matrix["summary"]
    doc: dict = {
        "schema": "nova-parity-breadth/1",
        "pinned_version": version,
        "observed_version": pin.get("observed_version"),
        "sources": {
            "matrix": "parity/matrix.json",
            "matrix_signature": matrix["signature"],
            "upstream_manifest": f"upstream/manifest-{version}.json",
            "upstream_manifest_signature": manifest["signature"],
            "taxonomy": "parity/breadth_taxonomy.json",
            "nova_freeze": freeze_file.name,
            "nova_freeze_types": len(freeze),
        },
        "summary": {
            "upstream_entries": len(rows),
            "expanded_member_items": s["expanded_member_items"],
            "unexpanded_member_items": s["unexpanded_member_items"],
            "member_gap_items": s["by_state"].get("GAP", 0),
            "component_gap_entries": sum(1 for r in rows
                                         if r["reason_code"] == "NO_NOVA_COUNTERPART"),
            "fallback_hits": fallback_hits,
            "by_state": dict(sorted(s["by_state"].items())),
            "by_layer": dict(sorted(by_layer.items())),
            "by_family": dict(sorted(by_family.items())),
            "by_batch": dict(sorted(by_batch.items())),
            "zero_orphan_rate": 1.0,
        },
        "layers": layer_rows,
        "batches": batch_rows,
        "out_of_scope_facets": taxonomy["out_of_scope_facets"],
        "coverage_discipline": taxonomy["coverage_discipline"],
        "entries": rows,
    }
    # 硬约束：与矩阵同源，防手改 / 口径漂移
    assert len(rows) == s["upstream_entries"] == 156
    assert sum(r["gap_items"] for r in rows) == s["by_state"]["GAP"] == 862
    assert sum(r["expanded_member_items"] for r in rows) == s["expanded_member_items"]
    assert sum(r["unexpanded_member_items"] for r in rows) == s["unexpanded_member_items"]
    assert sum(b["member_gap_items"] for b in batch_rows) == 862
    assert sum(b["component_gap_entries"] for b in batch_rows) == doc["summary"]["component_gap_entries"]

    doc["signature"] = _stable_signature(doc)
    doc["generated_at"] = datetime.now().astimezone().isoformat(timespec="seconds")
    return doc, render_view(doc, taxonomy)


def render_view(doc: dict, taxonomy: dict) -> str:
    s = doc["summary"]
    sig = doc["signature"]
    # 三层口径从 matrix.json 现读（法源链：breadth 视图引用 P1 机读事实源，
    # 不复制数字、不改本文件签名；matrix 变则视图随生成器重渲染而变）。
    cov = json.loads(MATRIX_PATH.read_text(encoding="utf-8"))["summary"]["coverage"]
    lines = [
        "# Parity 全生态广度台账（P2 · 先列出，未完现）",
        "",
        f"<!-- breadth-signature: {sig} -->",
        "",
        ("> **生成物 · 禁手改**：由 `scripts/gen_parity_breadth.py` 写出；"
         "`check_parity_ops.py` 用此签名做机读台账 / 视图 / 矩阵三方一致校验。"),
        (f"> **上游事实源**：npm `quasar@{doc['pinned_version']}` `dist/api/*.json`"
         f"（`upstream/manifest-{doc['pinned_version']}.json`，156 条脚本计数）；"
         f"**Nova 事实源**：`{doc['sources']['nova_freeze']}`（147 类型）。"),
        ("> **关系口径**：Inspired by Quasar (MIT) · 只用公开 API 元数据 · 不复制源码、不构成 fork / port。"),
        ("> **诚实边界**：`dist/api/*.json` 只覆盖 **L1~L4** 的 API 面。"
         "**L0 设计语言 / L5 工具层 / L6 工程化**是面外未纳入层（见 §5），"
         "绝不把 156 条当作「全生态」——T30 的 L5 漏复核正是这一边界的可复现证据。"),
        "",
        "## 1. 广度总览（脚本计数，非估算）",
        "",
        "| 指标 | 值 |",
        "|---|---|",
        f"| 上游条目（dist/api 面内） | **{s['upstream_entries']}** |",
        f"| 逐项展开成员项 | **{s['expanded_member_items']}** |",
        f"| 未逐项展开（组件级缺口） | **{s['unexpanded_member_items']}** |",
        "| 逐项五态 | " + " · ".join(f"`{k}` {v}" for k, v in s["by_state"].items()) + " |",
        f"| 成员级 GAP | **{s['member_gap_items']}** |",
        f"| 组件级缺口条目（NO_NOVA_COUNTERPART） | **{s['component_gap_entries']}** |",
        f"| 层级归属零悬空率 | **{s['zero_orphan_rate'] * 100:.2f}%** |",
        f"| 兜底规则命中（如实登记，不算精确分类） | **{s['fallback_hits']}** |",
        "",
        "### 1.1 七层覆盖现状（L0~L6）",
        "",
        "| 层 | 名称 | dist/api 面内 | 条目 | 逐项 | GAP | 组件级缺口 | 口径 |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for l in doc["layers"]:
        inside = "是" if l["in_dist_api"] else "**否（面外）**"
        lines.append(f"| **{l['layer']}** | {l['name']} | {inside} | {l['entries']} | "
                     f"{l['expanded_member_items']} | {l['gap_items']} | "
                     f"{l['component_gap_entries']} | {l['note']} |")
    lines += [
        "",
        ("> 面内层条目合计 = 156（与 manifest 一致）；面外层的 `0` 表示"
         "「dist/api 不含此层」，**不是「已覆盖」也不是「零缺口」**。"),
        "",
        "### 1.2 三层口径（与 `docs/PARITY_MATRIX.md` 同源；面外不算分子）",
        "",
        "| 档 | 全量面 | 定义 |",
        "|---|---|---|",
        f"| 字面 literal | **{cov['literal'] * 100:.2f}%** | ALIGNED / 适用项 |",
        (f"| 可解释 explainable | **{cov['explainable'] * 100:.2f}%** | "
         "(ALIGNED+MAPPED+N/A) / 全量项，GAP 不计入 |"),
        (f"| 机检固化 test_frozen | **{cov['test_frozen'] * 100:.2f}%** | "
         "带真实 PASS `test_id` 的 ALIGNED / 适用项，**独立计** |"),
        "",
        ("> **验收红线（2026-11-28 12:35 CSA 采纳 A 类）**：三层并列呈现，禁止只报"
         "可解释率；**GAP = 保守下界**，提升只能靠**补登记 + 补机检**，不许改判五态"
         "放宽口径；机检固化独立计，MAPPED / N/A 无用例不计入；L0/L5/L6 面外层"
         "**不算覆盖率分子**。详见 `proposals/SPEC_COMPONENT_PARITY_MEASURES.md` §2 / §3。"),
        "",
        "## 2. 逐层逐条台账（156 条，脚本计数）",
        "",
        "| 上游 | 类型 | 功能族 | Nova 对应 | 状态 | 逐项 | GAP | 优先级 | 批次 |",
        "|---|---|---|---|---|---|---|---|---|",
    ]
    for code in taxonomy["layer_definitions"]:
        sub = [r for r in doc["entries"] if r["layer"] == code]
        if not sub:
            continue
        meta = taxonomy["layer_definitions"][code]
        lines += ["", f"### 2.{code[1:]} {code} · {meta['name']}（{len(sub)} 条）", "",
                  "| 上游 | 类型 | 功能族 | Nova 对应 | 状态 | 逐项 | GAP | 优先级 | 批次 |",
                  "|---|---|---|---|---|---|---|---|---|"]
        for r in sub:
            nova = f"`{r['nova']}`" if r["nova"] else "**无对应类型**"
            items = (str(r["expanded_member_items"]) if r["expanded_member_items"]
                     else f"未展开 {r['unexpanded_member_items']}")
            lines.append(f"| `{r['upstream']}` | {r['upstream_type']} | {r['family']} | "
                         f"{nova} | `{r['state']}` | {items} | {r['gap_items']} | "
                         f"{r['priority']} | **{r['batch']}** |")
    lines += [
        "",
        "## 3. 组件级缺口专表（53 条 NO_NOVA_COUNTERPART）",
        "",
        ("> 这些上游条目在冻结面 147 类型中无对应类型。逐项成员未展开（合计 400 项），"
         "需先逐条判定「新增组件 / N/A 理由码」，再决定是否立项——**不直接等于要做 53 个组件**。"),
        "",
        "| 功能族 | 条数 | 代表条目 |",
        "|---|---|---|",
    ]
    gaps = [r for r in doc["entries"] if r["reason_code"] == "NO_NOVA_COUNTERPART"]
    fam = Counter(r["family"] for r in gaps)
    for name, count in sorted(fam.items(), key=lambda x: (-x[1], x[0])):
        sample = [r["upstream"][:-5] for r in gaps if r["family"] == name][:5]
        lines.append(f"| {name} | **{count}** | {', '.join(f'`{n}`' for n in sample)} |")
    lines += [
        "",
        "## 4. 批次聚合与建议（批次是建议，不是立项）",
        "",
        "| 批次 | 名称 | 优先级 | 条目 | 成员级 GAP | 组件级缺口 | 说明 |",
        "|---|---|---|---|---|---|---|",
    ]
    for b in doc["batches"]:
        lines.append(f"| **{b['id']}** | {b['name']} | {b['priority']} | {b['entries']} | "
                     f"{b['member_gap_items']} | {b['component_gap_entries']} | {b['note']} |")
    lines += [
        "",
        ("> **口径守恒**：四个批次的成员级 GAP 求和 = 862（与矩阵一致）；"
         "组件级缺口条目求和 = 53。B1 是 D1 目标函数（适用域内 P0 100% 机检固化）的封版前置，"
         "B2 只补登记不放宽口径，B3 先做归属判定。**全部须 CSA 拍板后才立项**。"),
        "",
        "## 5. 面外未纳入层（dist/api 之外，如实列出）",
        "",
        ("> 这是「全面对标」不能只看 156 条的关键。以下生态面不在 npm `dist/api/*.json` 内，"
         "本轮只登记现状与 P2 应做动作，**不计入任何覆盖率分子**。"),
        "",
        "| 层 | 面 | Nova 现状 | 为何面外 | P2 应做 |",
        "|---|---|---|---|---|",
    ]
    for f in doc["out_of_scope_facets"]:
        lines.append(f"| **{f['layer']}** | {f['facet']} | {f['in_nova']} | "
                     f"{f['why_outside']} | {f['p2_action']} |")
    lines += [
        "",
        "## 6. 未竟事项（列出 ≠ 完现 P2）",
        "",
        "- **本轮只做**：逐条台账 + 批次建议 + 面外清单 + 机检固化；`docs/PARITY_BREADTH.md` 已挂 nav。",
        "- **未做（须 CSA 立项）**：`parity/baseline.json` 棘轮基线（覆盖率只升不降）、站点 parity dashboard、门禁阈值提升、53 条逐条归属判定、面外层基线（L0/L5/L6）、862 项 GAP 逐项收敛。",
        "- **未做（已核定的 D3 节奏，见 `docs/PARITY_CADENCE.md`）**：`--online` 双源实现、`nova_mcp.py::check_updates` 升级、每周定时自动化（须 CSA 单独授权）。",
        "- **升 pin 独立议题**：D4 下 `pinned` 保持 2.35.5；`gen_upstream_baseline.py --apply` 仍 rc 2。",
        "- **零改动边界**：零 QML / 零冻结面改动（147 类型 / `9966483dda5a53c4` 不变）· 不升版 · 不重签 · 零史料回改 · 零发布动作 · 零自动化任务。",
        "",
        "---",
        "",
        f"*签名 `{sig}` · 由 `gen_parity_breadth.py` 生成，`check_parity_ops.py` 校验。*",
        "",
    ]
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="生成 / 校验 Parity 全生态广度台账")
    ap.add_argument("--check", action="store_true", help="幂等校验（不写盘）")
    args = ap.parse_args(argv)

    for p in (PIN_PATH, SCOPE_TAXONOMY, MATRIX_PATH):
        if not p.exists():
            print(f"[breadth] 前置缺失：{p.relative_to(ROOT)} → rc 2")
            return 2
    try:
        doc, view = build()
    except (OSError, ValueError, KeyError, AssertionError, json.JSONDecodeError) as exc:
        print(f"[breadth] 生成失败：{exc} → rc 1")
        return 1

    if args.check:
        if not BREADTH_PATH.exists() or not VIEW_PATH.exists():
            print("[breadth] breadth.json / PARITY_BREADTH.md 缺失 → rc 1")
            return 1
        existing = json.loads(BREADTH_PATH.read_text(encoding="utf-8"))
        view_text = VIEW_PATH.read_text(encoding="utf-8")
        taxonomy = json.loads(SCOPE_TAXONOMY.read_text(encoding="utf-8"))
        expected_view = render_view(doc, taxonomy)
        ok = (existing.get("signature") == doc["signature"]
              and _stable_signature(existing) == existing.get("signature")
              and expected_view == view_text)
        print(f"[breadth] --check {'PASS' if ok else 'FAIL'} · "
              f"entries={doc['summary']['upstream_entries']} · "
              f"gaps={doc['summary']['member_gap_items']} · "
              f"signature={doc['signature'][:16]} · "
              f"view_body={'OK' if expected_view == view_text else 'DRIFT'}")
        return 0 if ok else 1

    BREADTH_PATH.write_text(json.dumps(doc, indent=2, ensure_ascii=False) + "\n",
                            encoding="utf-8")
    VIEW_PATH.write_text(view, encoding="utf-8")
    s = doc["summary"]
    print("[breadth] 已写入 parity/breadth.json + docs/PARITY_BREADTH.md")
    print(f"          entries={s['upstream_entries']} · expanded={s['expanded_member_items']} · "
          f"gaps={s['member_gap_items']} · component_gaps={s['component_gap_entries']} · "
          f"fallback={s['fallback_hits']}")
    print(f"          by_layer={s['by_layer']}")
    print(f"          by_batch={s['by_batch']}")
    print(f"          signature={doc['signature'][:16]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
