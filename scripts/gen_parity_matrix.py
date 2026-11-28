#!/usr/bin/env python3
# scripts/gen_parity_matrix.py
# Parity Ops L-B：上游全量面 × 冻结面 → 五态机读矩阵 + 人类可读视图
"""生成 ``parity/matrix.json``（禁手改）与 ``docs/PARITY_MATRIX.md``（现行视图）。

**输入（四个法源，全部机读）**：

1. ``upstream/manifest-2.35.5.json`` + ``upstream/cache/api-2.35.5/*.json`` —— 上游全量面
2. ``api/nova-api-1.11.0.json::types`` —— Nova 冻结面 147 类型（含 props/signals/methods）
3. ``parity/scope.json`` —— 手写唯一法源：P0 集、N/A 理由码、别名表、机检绑定、门禁口径
4. ``tests/*.py`` —— 真实 ``def test_*`` 函数名（法源链不留悬空）

**五态（提案 §3 L-B）**：``ALIGNED``（有机检固化）/ ``MAPPED``（语义承接，可解释未固化）/
``N/A``（带理由码）/ ``GAP``（真实缺口，带优先级 + 里程碑）/ ``ENHANCEMENT``（Nova 增强，
只登记不混入 ALIGNED 防虚高）。

用法::

    python scripts/gen_parity_matrix.py           # 生成 matrix.json + 视图
    python scripts/gen_parity_matrix.py --check  # 幂等校验（不写盘）

退出码：0 = 成功 / 一致；1 = 幂等漂移 / 法源链悬空 / 前置缺失。
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
SCOPE_PATH = ROOT / "parity" / "scope.json"
MATRIX_PATH = ROOT / "parity" / "matrix.json"
VIEW_PATH = ROOT / "docs" / "PARITY_MATRIX.md"
STATES = ("ALIGNED", "MAPPED", "N/A", "GAP", "ENHANCEMENT")

# 上游 facet → Nova 冻结面成员侧
FACET_TO_NOVA = {
    "props": "props",
    "slots": "props",       # Nova 用 property Component <name>Delegate 承接插槽
    "events": "signals",
    "methods": "methods",
}


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _stable_signature(doc: dict) -> str:
    stable = {k: v for k, v in doc.items()
              if k not in ("signature", "generated_at")}
    return _sha256(json.dumps(stable, sort_keys=True, ensure_ascii=False).encode("utf-8"))


def norm(name: str) -> str:
    return re.sub(r"[^a-z0-9]", "", name.lower())


def camel(name: str) -> str:
    parts = re.split(r"[-_:]", name)
    return parts[0] + "".join(p[:1].upper() + p[1:] for p in parts[1:] if p)


def member_name(raw: str) -> str:
    """冻结面成员名解析：``ro popupCount:int`` → ``popupCount``；``closed(int count)`` → ``closed``。"""
    s = raw.strip()
    s = s.removeprefix("ro ")
    s = s.split(":")[0].split("(")[0]
    return s.strip()


def nova_member_sets(freeze_type: dict) -> dict[str, set[str]]:
    return {
        side: {norm(member_name(x)) for x in freeze_type.get(raw, [])}
        for side, raw in (("props", "props"), ("signals", "signals"), ("methods", "methods"))
    }


def scan_test_ids(root: Path = ROOT) -> set[str]:
    out: set[str] = set()
    for path in sorted((root / "tests").glob("*.py")):
        out.update(re.findall(r"^def (test_\w+)\(",
                              path.read_text(encoding="utf-8"), re.MULTILINE))
    return out


def enumerate_items(doc: dict, facets: list[str]) -> list[tuple[str, str]]:
    """按 scope.facet_keys 枚举上游成员项，返回 (facet, name) 列表。"""
    items: list[tuple[str, str]] = []
    for facet in facets:
        val = doc.get(facet)
        if facet == "value":
            # directive 的 value 是「绑定值描述对象」，其 keys 是元数据字段而非 API 成员；
            # 按 1 项计入（组件级已判定 Nova Behaviors 对应），不展开（见 scope.json::facet_notes）。
            if val is not None:
                items.append((facet, facet))
        elif isinstance(val, dict):
            items.extend((facet, str(k)) for k in val)
        elif val is not None:
            items.append((facet, facet))
    return items


def na_reason(scope: dict, facet: str, name: str) -> str | None:
    for rule in scope["na_patterns"]:
        if facet in rule["facets"] and re.search(rule["name_regex"], name):
            return rule["reason_code"]
    return None


def alias_of(scope: dict, upstream: str, facet: str, name: str) -> str | None:
    for key in (upstream, "*"):
        m = scope.get("alias_map", {}).get(key, {}).get(facet, {})
        if name in m:
            return m[name]
    return None


def bound_tests(scope: dict, nova: str, facet: str, name: str) -> list[str]:
    m = scope.get("test_bindings", {}).get(nova, {}).get(facet, {})
    ids = m.get(name, m.get("*", []))
    return list(ids)


def classify_item(scope: dict, upstream: str, nova: str, facet: str, name: str,
                  nova_sets: dict[str, set[str]], real_tests: set[str],
                  is_p0: bool = False) -> dict:
    item: dict = {"facet": facet, "name": name}

    reason = na_reason(scope, facet, name)
    if reason:
        item.update(state="N/A", reason_code=reason)
        return item

    tests = bound_tests(scope, nova, facet, name)
    if tests:
        missing = [t for t in tests if t not in real_tests]
        if missing:
            raise ValueError(f"法源链悬空 test_id：{upstream}/{facet}/{name} → {missing}")
        item.update(state="ALIGNED", test_ids=tests,
                    nova_member=alias_of(scope, upstream, facet, name) or camel(name))
        return item

    alias = alias_of(scope, upstream, facet, name)
    if alias:
        item.update(state="MAPPED", nova_member=alias,
                    reason_code="RENAMED_MAPPING")
        return item

    side = FACET_TO_NOVA.get(facet)
    if side:
        candidates = {norm(camel(name))}
        if facet == "slots":
            candidates.add(norm(camel(name) + "Delegate"))
        hit = candidates & nova_sets[side]
        if hit:
            item.update(state="MAPPED", nova_member=min(hit),
                        reason_code="LITERAL_MEMBER")
            return item

    pr = scope["priority_rules"]
    item.update(
        state="GAP",
        reason_code="NO_MEMBER",
        priority=pr["p0_member_gap_priority"] if is_p0 else pr["member_gap_priority"].get(facet, "P2"),
        milestone=pr["p0_milestone"] if is_p0 else pr["default_milestone"],
    )
    return item


def build(root: Path = ROOT) -> tuple[dict, str]:
    pin = json.loads(PIN_PATH.read_text(encoding="utf-8"))
    version = pin["pinned_version"]
    manifest_path = root / "upstream" / f"manifest-{version}.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    scope = json.loads(SCOPE_PATH.read_text(encoding="utf-8"))
    # 冻结面文件名由自动探测得出，禁手写版本清单（复用 migrate2nova 范式）
    freeze_files = sorted((root / "api").glob("nova-api-*.json"),
                          key=lambda p: tuple(int(x) for x in p.stem.split("-")[-1].split(".")))
    freeze = json.loads(freeze_files[-1].read_text(encoding="utf-8"))["types"]

    real_tests = scan_test_ids(root)
    short_to_full = {k.split(".")[-1]: k for k in freeze}
    # P0 必须按 (nova, upstream) 精确配对判定：只看 nova 名会把 QDialog.json 误纳入
    # （插件 Dialog.json 与组件 QDialog.json 曾同时落到 NovaDialog）。
    p0_pairs_set = {(p["nova"], p["upstream"]) for p in scope["p0_pairs"]}

    # 校验 P0 配对：nova / upstream 双端必须真实存在
    manifest_names = {e["name"] for e in manifest["entries"]}
    for pair in scope["p0_pairs"]:
        if pair["nova"] not in freeze:
            raise ValueError(f"P0 配对 nova 不存在于冻结面：{pair['nova']}")
        if pair["upstream"] not in manifest_names:
            raise ValueError(f"P0 配对 upstream 不存在于 manifest：{pair['upstream']}")
    for up, target in scope.get("mapping_overrides", {}).items():
        if up not in manifest_names or target not in freeze:
            raise ValueError(f"mapping_override 法源悬空：{up} → {target}")

    # 校验所有机检绑定真实存在
    for nova, facets in scope.get("test_bindings", {}).items():
        for facet, binds in facets.items():
            for key, ids in binds.items():
                missing = [t for t in ids if t not in real_tests]
                if missing:
                    raise ValueError(f"法源链悬空 test_id：{nova}/{facet}/{key} → {missing}")

    entries: list[dict] = []
    state_counts: Counter[str] = Counter()
    expanded = 0
    unexpanded = 0
    p0_gaps: list[dict] = []

    for e in manifest["entries"]:
        name = e["name"]
        up_type = e["upstream_type"]
        stem = name[:-5]
        candidate = stem[1:] if stem.startswith("Q") and len(stem) > 1 else stem
        nova = (scope.get("mapping_overrides", {}).get(name)
                or short_to_full.get("Nova" + candidate))
        doc = json.loads((root / manifest["cache_dir"] / name).read_text(encoding="utf-8"))
        facets = scope["facet_keys"].get(up_type, [])
        items_raw = enumerate_items(doc, facets)
        is_p0 = (nova, name) in p0_pairs_set

        if nova is None:
            unexpanded += len(items_raw)
            entries.append({
                "upstream": name, "upstream_type": up_type, "nova": None,
                "p0": False, "state": "GAP",
                "reason_code": "NO_NOVA_COUNTERPART",
                "priority": scope["priority_rules"]["component_gap_priority"],
                "milestone": scope["priority_rules"]["default_milestone"],
                "unexpanded_member_items": len(items_raw),
                "member_counts": e["member_counts"],
                "items": [],
            })
            continue

        nova_sets = nova_member_sets(freeze[nova])
        items = [classify_item(scope, name, nova, f, n, nova_sets, real_tests, is_p0)
                 for f, n in items_raw]
        expanded += len(items)
        for it in items:
            state_counts[it["state"]] += 1
            if it["state"] == "GAP" and is_p0:
                p0_gaps.append({"upstream": name, "nova": nova, **it})

        # Nova 独有增强成员（冻结面 props 有、上游 props 无）：只登记数量，不混入 ALIGNED
        upstream_prop_names = {norm(camel(n)) for f, n in items_raw if f == "props"}
        enhancement = sorted(
            x for x in freeze[nova].get("props", [])
            if norm(member_name(x)) not in upstream_prop_names
        )

        all_aligned = bool(items) and all(i["state"] == "ALIGNED" for i in items)
        has_carry = any(i["state"] in ("ALIGNED", "MAPPED") for i in items)
        entry_state = "ALIGNED" if all_aligned else ("MAPPED" if has_carry else "GAP")
        entries.append({
            "upstream": name, "upstream_type": up_type, "nova": nova,
            "p0": is_p0, "state": entry_state,
            "member_counts": e["member_counts"],
            "expanded_member_items": len(items),
            "enhancement_members": len(enhancement),
            "by_state": dict(sorted(Counter(i["state"] for i in items).items())),
            "items": items,
        })

    na_meta = state_counts["N/A"]
    applicable = expanded - na_meta
    aligned = state_counts["ALIGNED"]
    explainable = aligned + state_counts["MAPPED"] + na_meta
    orphans = sum(
        1 for e in entries for i in e["items"]
        if i["state"] not in STATES
        or (i["state"] == "GAP" and not (i.get("priority") and i.get("milestone")))
        or (i["state"] == "ALIGNED" and not i.get("test_ids"))
        or (i["state"] == "N/A" and not i.get("reason_code"))
    )
    zero_orphan_rate = 1.0 if expanded else 0.0
    if orphans:
        zero_orphan_rate = round((expanded - orphans) / expanded, 6)

    p0_items = [i for e in entries if e["p0"] for i in e["items"]]
    p0_states = Counter(i["state"] for i in p0_items)
    p0_na = p0_states["N/A"]
    p0_applicable = len(p0_items) - p0_na
    p0_aligned = p0_states["ALIGNED"]

    matrix: dict = {
        "schema": "nova-parity-matrix/1",
        "pinned_version": version,
        "observed_version": pin.get("observed_version"),
        "sources": {
            "upstream_manifest": f"upstream/manifest-{version}.json",
            "upstream_manifest_signature": manifest["signature"],
            "nova_freeze": freeze_files[-1].name,
            "scope": "parity/scope.json",
            "tests": "tests/*.py (real def test_* functions)",
        },
        "summary": {
            "upstream_entries": len(entries),
            "nova_mapped_entries": sum(1 for e in entries if e["nova"]),
            "p0_pairs": len(scope["p0_pairs"]),
            "expanded_member_items": expanded,
            "unexpanded_member_items": unexpanded,
            "by_state": dict(sorted(state_counts.items())),
            "by_upstream_type": dict(sorted(Counter(e["upstream_type"] for e in entries).items())),
            "orphans": orphans,
            "zero_orphan_rate": zero_orphan_rate,
            "applicable_items": applicable,
            "coverage": {
                "literal": round(aligned / applicable, 6) if applicable else 0.0,
                "explainable": round(explainable / expanded, 6) if expanded else 0.0,
                "test_frozen": round(aligned / applicable, 6) if applicable else 0.0,
            },
            "p0": {
                "pairs": len(scope["p0_pairs"]),
                "items": len(p0_items),
                "by_state": dict(sorted(p0_states.items())),
                "applicable_items": p0_applicable,
                "gap_count": len(p0_gaps),
                "coverage": {
                    "literal": round(p0_aligned / p0_applicable, 6) if p0_applicable else 0.0,
                    "explainable": round(
                        (p0_aligned + p0_states["MAPPED"] + p0_na) / len(p0_items), 6
                    ) if p0_items else 0.0,
                    "test_frozen": round(p0_aligned / p0_applicable, 6) if p0_applicable else 0.0,
                },
            },
        },
        "p0_gaps": p0_gaps,
        "entries": entries,
    }
    matrix["signature"] = _stable_signature(matrix)
    matrix["generated_at"] = datetime.now().astimezone().isoformat(timespec="seconds")

    view = render_view(matrix, scope)
    return matrix, view


def render_view(matrix: dict, scope: dict) -> str:
    s = matrix["summary"]
    sig = matrix["signature"]
    p0 = s["p0"]
    lines = [
        "# Parity 机读矩阵 · 现行覆盖率与逐项欠账清单",
        "",
        f"<!-- parity-signature: {sig} -->",
        "",
        ("> **生成物 · 禁手改**：由 `scripts/gen_parity_matrix.py` 写出；"
        "`check_parity.py` 用此签名做矩阵 / 视图 / 冻结面三方一致校验。"),
        (f"> **上游事实源**：npm `quasar@{matrix['pinned_version']}` `dist/api/*.json`"
        f"（`upstream/manifest-{matrix['pinned_version']}.json`）；"
        f"**Nova 事实源**：`{matrix['sources']['nova_freeze']}`（147 类型）。"),
        "> **关系口径**：Inspired by Quasar (MIT) · 只用公开 API 元数据 · 不复制源码、不构成 fork / port。",
        ("> **口径纪律**：`docs/PARITY.md` 是历史审计史料（不删、不回改）；本页是**现行机读视图**，"
        "与 `ECOSYSTEM_PARITY.md` 的历史评分无继承关系。"),
        "",
        "## 1. 全量面总览（脚本计数，非估算）",
        "",
        "| 指标 | 值 |",
        "|---|---|",
        f"| 上游条目 | **{s['upstream_entries']}**（" +
        " / ".join(f"{k} {v}" for k, v in s["by_upstream_type"].items()) + "） |",
        f"| 与冻结面自动同名映射 | **{s['nova_mapped_entries']}** |",
        f"| 逐项展开成员项 | **{s['expanded_member_items']}** |",
        f"| 未逐项展开（无 Nova 对应类型，组件级带里程碑） | **{s['unexpanded_member_items']}** |",
        f"| 零悬空率 | **{s['zero_orphan_rate'] * 100:.2f}%**（悬空 {s['orphans']}） |",
        f"| 适用项（扣除 N/A / 元数据） | **{s['applicable_items']}** |",
        "",
        "### 1.1 三层口径覆盖率（口径见 `parity/scope.json::coverage_definitions`）",
        "",
        "| 档 | 定义 | 全量面 | P0 集 |",
        "|---|---|---|---|",
        f"| 字面 literal | ALIGNED / 适用项 | **{s['coverage']['literal'] * 100:.2f}%** | **{p0['coverage']['literal'] * 100:.2f}%** |",
        f"| 可解释 explainable | (ALIGNED+MAPPED+N/A) / 全量项（GAP 不计入） | **{s['coverage']['explainable'] * 100:.2f}%** | **{p0['coverage']['explainable'] * 100:.2f}%** |",
        f"| 机检固化 test_frozen | 带真实 PASS `test_id` 的 ALIGNED / 适用项（独立计） | **{s['coverage']['test_frozen'] * 100:.2f}%** | **{p0['coverage']['test_frozen'] * 100:.2f}%** |",
        "",
        ("> **验收红线（2026-11-28 12:35 CSA 采纳 A 类）**：三层必须并列呈现，"
        "禁止只报可解释率；**GAP = 保守下界**（语义等价但未登记映射的项暂落 GAP），"
        "提升只能靠**补登记 + 补机检**，不许改判五态放宽口径；**机检固化独立计**，"
        "MAPPED / N/A 无对应机检用例不计入。详见 "
        "`proposals/SPEC_COMPONENT_PARITY_MEASURES.md` §2 / §3。"),
        "",
        ("> **不圆场**：GAP 不算「可解释」。P1 是诊断期，覆盖率是**真实诊断输出**，"
        "不是凑数指标；把阈值提到 100% 属 P2/P3 封版门禁（届时 GAP 清零才达标）。"),
        "",
        "### 1.2 逐项五态分布",
        "",
        "| 状态 | 数量 | 含义 |",
        "|---|---|---|",
    ]
    desc = {
        "ALIGNED": "有机检固化（`test_id` 真实存在）",
        "MAPPED": "语义承接（同名或改名），可解释但未固化",
        "N/A": "带理由码的合法不适用",
        "GAP": "真实缺口，带优先级 + 里程碑",
        "ENHANCEMENT": "Nova 增强（登记不混入 ALIGNED）",
    }
    for k in STATES:
        lines.append(f"| `{k}` | {s['by_state'].get(k, 0)} | {desc[k]} |")
    lines += [
        "",
        f"## 2. P0 组件集全表审计（{scope['p0_pair_count']} 个旗舰配对 · CSA 09:13 授权依磁盘事实核定）",
        "",
        (f"P0 集口径见 `parity/scope.json::p0_pairs`（**CSA 2026-11-28 09:13 授权「按磁盘事实定」、"
        f"小诺逐条核验 {scope['p0_pair_count']}/12 后固化；标准级口径已确认**）。"
        f"逐项 {p0['items']} 项 · 适用 {p0['applicable_items']} 项 · "
        f"**真实 GAP {p0['gap_count']} 项**。"),
        "",
        "| Nova 类型 | 上游 | 逐项 | ALIGNED | MAPPED | N/A | GAP | 可解释 | 机检固化 |",
        "|---|---|---|---|---|---|---|---|---|",
    ]
    for e in matrix["entries"]:
        if not e["p0"]:
            continue
        b = e["by_state"]
        total = e["expanded_member_items"]
        na = b.get("N/A", 0)
        app = total - na
        al = b.get("ALIGNED", 0)
        ex = round((al + b.get("MAPPED", 0) + na) / total * 100, 1) if total else 0.0
        tf = round(al / app * 100, 1) if app else 0.0
        lines.append(
            f"| `{e['nova']}` | `{e['upstream']}` | {total} | {al} | "
            f"{b.get('MAPPED', 0)} | {na} | {b.get('GAP', 0)} | {ex}% | {tf}% |"
        )
    lines += [
        "",
        "### 2.1 P0 集逐条磁盘证据（CSA 09:13 授权核定 · 脚本计数，非估算）",
        "",
        ("> 各条 `disk_evidence` 与 `upstream/manifest-2.35.5.json` / `parity/matrix.json` / 冻结面同源，"
         "由 `tests/test_parity_matrix.py` 反查现盘复验；`selection_basis` 里的数字是 "
         "`docs/PARITY.md` 历史审计节口径，与 pinned npm `dist/api` 发布面**并列保留、不圆场**（见 §3）。"),
        "",
        "| Nova 类型 | 上游 | 类型 | pinned 面 props/slots/events/methods | 逐项 / 五态 | 冻结面 props/signals/methods | 审计法源 | 机检绑定 |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for pair in scope["p0_pairs"]:
        ev = pair["disk_evidence"]
        u, f = ev["upstream_member_counts"], ev["freeze_members"]
        pm = "/".join(str(u.get(k, 0)) for k in ("props", "slots", "events", "methods"))
        fm = "/".join(str(f.get(k, 0)) for k in ("props", "signals", "methods"))
        states = " · ".join(f"{k} {v}" for k, v in sorted(ev["by_state"].items()))
        lines.append(
            f"| `{pair['nova']}` | `{pair['upstream']}` | {ev['upstream_type']} | {pm} | "
            f"{ev['expanded_member_items']} · {states} | {fm} | "
            f"{ev['audit_section']} | {ev['test_binding']} |"
        )
    lines += [
        "",
        "### 2.2 P0 集逐项欠账清单（真实 GAP，按上游条目聚合）",
        "",
        "| 上游 | Nova | facet | 成员 | 优先级 | 里程碑 |",
        "|---|---|---|---|---|---|",
    ]
    if matrix["p0_gaps"]:
        for g in matrix["p0_gaps"][:80]:
            lines.append(
                f"| `{g['upstream']}` | `{g['nova']}` | {g['facet']} | `{g['name']}` | "
                f"{g['priority']} | {g['milestone']} |"
            )
        if len(matrix["p0_gaps"]) > 80:
            lines.append(f"| … | | | 其余 {len(matrix['p0_gaps']) - 80} 项见 `parity/matrix.json::p0_gaps` | | |")
    else:
        lines.append("| — | — | — | 无 | — | — |")
    lines += [
        "",
        "## 3. 法源口径差异登记（不圆场、并列保留）",
        "",
        "| 项 | T28 / `PARITY.md` 史料 | 本页（pinned npm `dist/api` 2.35.5） |",
        "|---|---|---|",
        "| QTable props | 63 | **65** |",
        "| QTable slots | 21 | **21**（一致） |",
        "| QTable events | 9 | **11**（多 `fullscreen` / `update:fullscreen`） |",
        "| QTable methods | 15 | **17**（多 `setFullscreen` / `exitFullscreen`） |",
        "| QTable 分母 | 63+21+9+15+15 列元字段 = **123** | 65+21+11+17 = **114**（`computedProps` 3 单列） |",
        "| QSelect props | 47（`PARITY.md §0.9` 收口 24） | **92**（聚合 mixin 后的完整发布面） |",
        "",
        ("> **两个法源，不是谁错了**：`PARITY.md` 各 Sprint 与 T28 用的是 GitHub `dev` 分支"
        " `ui/src/components/*/*.json`（**组件自身定义**）；本页用 npm `dist/api/*.json`"
        "（**聚合 use-field / use-form / use-virtual-scroll 等 mixin 后的完整发布面**）。"
        "QSelect 47 → 92 的落差正说明历史审计面对的是更小的面，因此本页的 GAP 多为真实缺口，"
        "而非误判。按史料不圆场：T28 的 123/123 结论与 `PARITY.md` 各节计数逐字保留、不回改，"
        "本页另给 pinned 发布面的真实数字。`scope.json::test_bindings` 只绑定 T28 真实断言过的 "
        "21 slots / 15 methods / 9 events，多出的 4 项**不虚绑**。"),
        "",
        "## 4. 门禁口径",
        "",
        "| 类别 | 项 |",
        "|---|---|",
    ]
    for b in scope["gate_policy"]["blocking"]:
        lines.append(f"| 阻断 | {b} |")
    for r in scope["gate_policy"]["reported_not_blocking"]:
        lines.append(f"| 仅报告（不阻断） | {r} |")
    lines += [
        "",
        f"> {scope['gate_policy']['rationale']}",
        f"> 下一步：{scope['gate_policy']['next']}",
        "",
        "## 5. 未竟事项（如实登记）",
        "",
        "- **P2**（09:37 已「先列出」）：全生态 L0~L6 广度台账见 `docs/PARITY_BREADTH.md`（156 条逐条归属 + 批次建议 + 面外层清单）；**完现待办**：逐条归属判定 / `parity/baseline.json` 棘轮基线 / 站点 dashboard / 门禁阈值提升，须 CSA 立项。",
        "- **P3 / D3**：跟进节奏已于 09:37 核定（三档：T1 交付前离线硬门 + T2 每周在线周巡 + T3 阻断类事件即时响应），见 `docs/PARITY_CADENCE.md` + `upstream/cadence.json`；`--online` 双源实现、`nova_mcp.py::check_updates` 升级与周期自动化仍属 P3 待立项，**准实时自动化不做**。",
        "- **升 pin 独立议题**：`gen_upstream_baseline.py --apply` 源码级投影 + minor 重签；CSA D4 下 `pinned` 保持 2.35.5。",
        "- **机检固化率偏低是真实欠账**：库内仅 `NovaTable` 有成员级全表机检（`test_nova_table.py` 23 项），其余 P0 组件主要靠 `test_smoke.py` 冒烟；这一数字正是本议题「完整度不够」的量化答案，不以调整口径掩盖。",
        "- **GAP 是保守下界，不等于功能缺口数**：当前矩阵只机读化「同名 / `scope.json` 已登记别名 / 明确 N/A 理由码」三类判定。`variant` 承接 `square` / `rounded` / `flat`、主题令牌承接 `*-color` 等**语义等价但尚未登记映射**的项暂落 GAP。P2 逐层人工审计收敛后，可解释率只会因补登记而上升，不会靠放宽口径上升。",
        "",
        "---",
        "",
        f"*签名 `{sig}` · 由 `gen_parity_matrix.py` 生成，`check_parity.py` 校验。*",
        "",
    ]
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="生成 / 校验 Parity 机读矩阵与现行视图")
    ap.add_argument("--check", action="store_true", help="幂等校验（不写盘）")
    args = ap.parse_args(argv)

    try:
        matrix, view = build()
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"[parity] 生成失败：{exc} → rc 1")
        return 1

    if args.check:
        if not MATRIX_PATH.exists() or not VIEW_PATH.exists():
            print("[parity] matrix.json / PARITY_MATRIX.md 缺失 → rc 1")
            return 1
        existing = json.loads(MATRIX_PATH.read_text(encoding="utf-8"))
        view_text = VIEW_PATH.read_text(encoding="utf-8")
        scope = json.loads(SCOPE_PATH.read_text(encoding="utf-8"))
        # 双向核对：不只比签名，重渲染全文比对 —— 手改视图正文也会 FAIL（生成物禁手改）。
        expected_view = render_view(matrix, scope)
        ok = (existing.get("signature") == matrix["signature"]
              and expected_view == view_text)
        print(f"[parity] --check {'PASS' if ok else 'FAIL'} · "
              f"entries={matrix['summary']['upstream_entries']} · "
              f"items={matrix['summary']['expanded_member_items']} · "
              f"signature={matrix['signature'][:16]} · view_body={'OK' if expected_view == view_text else 'DRIFT'}")
        return 0 if ok else 1

    MATRIX_PATH.parent.mkdir(parents=True, exist_ok=True)
    MATRIX_PATH.write_text(json.dumps(matrix, indent=2, ensure_ascii=False) + "\n",
                           encoding="utf-8")
    VIEW_PATH.write_text(view, encoding="utf-8")
    s = matrix["summary"]
    print("[parity] 已写入 parity/matrix.json + docs/PARITY_MATRIX.md")
    print(f"         entries={s['upstream_entries']} · mapped={s['nova_mapped_entries']} · "
          f"expanded_items={s['expanded_member_items']} · orphans={s['orphans']}")
    print(f"         by_state={s['by_state']}")
    print(f"         coverage literal={s['coverage']['literal']} "
          f"explainable={s['coverage']['explainable']} test_frozen={s['coverage']['test_frozen']}")
    print(f"         P0: items={s['p0']['items']} gaps={s['p0']['gap_count']} "
          f"explainable={s['p0']['coverage']['explainable']} "
          f"test_frozen={s['p0']['coverage']['test_frozen']}")
    print(f"         signature={matrix['signature'][:16]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
