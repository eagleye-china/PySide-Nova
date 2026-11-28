#!/usr/bin/env python3
# scripts/check_upstream_drift.py
# 上游漂移监测门（T30 / P0 止血骨架）：pin → 变更登记 → 7 类分类器 → 分级响应 → 闭环销号
"""pyside-nova × Quasar 上游漂移离线门。

**为什么需要它**：0.13.0 / 0.14.0 判「2.35.6 零漂移」时只比对 ``dist/api/*.json``
（组件 API 面），漏掉 L5 工具层；Quasar 2.35.6 修的正是 ``humanStorageSize`` 三条边界，
库内一直复刻着 2.35.5 的旧行为。本门把「基线事实源 + 全 scope 变更登记 + 分类分级 +
机检固化销号」串成可机检闭环，避免每次上游 patch 都要全库 147 类型人工对账。

用法::

    python scripts/check_upstream_drift.py --offline       # 交付前离线硬门 T1（默认）
    python scripts/check_upstream_drift.py --offline --report reports/upstream.json
    python scripts/check_upstream_drift.py --online        # T2 周巡：P3 未实现 → rc 2（D3 09:37 已核定，见 upstream/cadence.json）

退出码语义（对齐 check_cve.py / check_all.py）：
    0 = 全绿（无未销号阻断类命中、分类登记一致、baseline 口径一致）
    1 = 产品红（存在未销号的 C0/C1/C5、分类漂移、或 baseline 口径漂移）
    2 = 前置缺失（pin / changes 文件缺失，或 --online 尚未实现）

**边界**：纯标准库、零第三方依赖、不联网、不写生成物。``upstream/quasar-pin.json``
是全库唯一允许手写上游版本号的地方；本脚本守护它与 6 处历史硬编码口径一致，
投影（消除散落）由 P1 的 ``gen_upstream_baseline.py`` 承担。
"""
from __future__ import annotations

import argparse
import json
import re
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PIN_PATH = ROOT / "upstream" / "quasar-pin.json"

# 7 类变更分类器（C0~C6）。优先级自上而下；命中即返回。
CATEGORIES: dict[str, str] = {
    "C0": "组件 API 面增删改（props/slots/methods/events）→ P0 阻断，命中组件 PARITY 重跑",
    "C1": "行为语义 / 默认值 / 边界 → P0 阻断，命中工具或服务必须补机检用例",
    "C2": "新增组件 / 指令 / 插件 / 新品类 → P1 登记 GAP + 里程碑",
    "C3": "语言包 / 图标集 → P2 可选增益，登记不阻断",
    "C4": "TS 类型层（.d.ts）→ P3 仅登记（QML 无 TS）",
    "C5": "安全修复 → P1 走 check_cve.py + sanitize 复核",
    "C6": "文档 / 构建 / CI / 内部重构 → P3 仅登记",
}
BLOCKING = ("C0", "C1", "C5")

# 历史口径散落点（R2 证据）。P0 只「守护一致」，不投影、不回改任何已发布文件。
BASELINE_SENTINELS: list[tuple[str, str]] = [
    ("api/nova-api-*.json", r'"baseline"\s*:\s*"Quasar ([0-9.]+)"'),
    ("docs/ai/index.json", r'"baseline"\s*:\s*"Quasar ([0-9.]+)"'),
    ("scripts/gen_api_freeze.py", r'BASELINE\s*=\s*"Quasar ([0-9.]+)"'),
    ("scripts/gen_apidocs.py", r'"baseline"\s*:\s*"Quasar ([0-9.]+)"'),
    ("scripts/gen_prompt.py", r'QUASAR_BASELINE\s*=\s*"([0-9.]+)"'),
    ("docs/PARITY.md", r'对标基线 \*\*2\.35\.5\*\*'),
]


def classify(change: dict) -> str:
    """按变更元数据判定 C0~C6。规则表即法源，登记里的 ``category`` 必须由此反算一致。"""
    scope = str(change.get("scope", ""))
    target = str(change.get("target", ""))
    kind = str(change.get("change", ""))
    ctype = str(change.get("type", ""))

    if change.get("security") is True or ctype == "security":
        return "C5"
    if scope == "types" or ".d.ts" in target or kind == "typing":
        return "C4"
    if scope in ("lang", "icon-set"):
        return "C3"
    if scope == "api" and kind in ("add", "remove", "modify"):
        return "C0"
    if kind == "new" or (ctype == "feat" and scope in ("component", "directive", "plugin")):
        return "C2"
    if scope in ("utils", "plugin", "directive", "service") and kind in (
        "behavior", "default", "boundary", "modify"
    ):
        return "C1"
    if scope in ("docs", "build", "ci", "internal", "tooling"):
        return "C6"
    return "C6"  # 兜底不允许静默丢弃：登记若写别的类会被分类一致性检出差


def load_pin(path: Path = PIN_PATH) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def load_changes(pin: dict, root: Path = ROOT) -> dict:
    rel = pin.get("changes_file", "")
    if not rel:
        raise ValueError("quasar-pin.json 缺少 changes_file")
    return json.loads((root / "upstream" / rel).read_text(encoding="utf-8"))


def _latest_freeze(root: Path = ROOT) -> Path | None:
    """复用 migrate2nova 的自动探测范式：禁手写版本清单。"""
    def key(p: Path):
        tail = p.stem.split("-")[-1]
        try:
            return tuple(int(x) for x in tail.split("."))
        except ValueError:
            return (0,)
    files = sorted((root / "api").glob("nova-api-*.json"), key=key)
    return files[-1] if files else None


def check_baseline_consistency(pinned: str, root: Path = ROOT) -> list[dict]:
    """守护 6 处历史硬编码口径与 pin 一致；返回逐点结果（不写盘、不投影）。"""
    results: list[dict] = []
    for pattern, regex in BASELINE_SENTINELS:
        if "*" in pattern:
            f = _latest_freeze(root)
            paths = [f] if f else []
        else:
            paths = [root / pattern]
        for p in paths:
            if p is None or not p.exists():
                results.append({"path": pattern, "found": False, "ok": False,
                                "detail": "文件缺失"})
                continue
            text = p.read_text(encoding="utf-8")
            m = re.search(regex, text)
            if pattern == "docs/PARITY.md":
                # 该行是史料表述（无捕获组），只核对文本存在，不回改
                results.append({"path": p.relative_to(root).as_posix(),
                                "found": m is not None,
                                "ok": m is not None,
                                "detail": "史料基线表述存在性（不回改）"})
                continue
            found = m.group(1) if m else None
            results.append({"path": p.relative_to(root).as_posix(),
                            "found": found is not None,
                            "version": found,
                            "ok": found == pinned,
                            "detail": "一致" if found == pinned else f"口径漂移：{found} != {pinned}"})
    return results


def evaluate(pin: dict, changes: dict, root: Path = ROOT) -> dict:
    pinned = pin["pinned_version"]
    observed = pin["observed_version"]
    items = changes.get("changes", [])

    by_category: dict[str, int] = {}
    mismatches: list[dict] = []
    blocking_open: list[dict] = []
    for c in items:
        computed = classify(c)
        declared = c.get("category", "")
        by_category[computed] = by_category.get(computed, 0) + 1
        if computed != declared:
            mismatches.append({"id": c.get("id"), "declared": declared,
                               "computed": computed})
        if computed in BLOCKING and c.get("status") != "resolved":
            blocking_open.append({"id": c.get("id"), "category": computed,
                                 "status": c.get("status"),
                                 "summary": c.get("summary")})
        if computed in BLOCKING and c.get("status") == "resolved" and not c.get("test_ids"):
            blocking_open.append({"id": c.get("id"), "category": computed,
                                 "status": "resolved-but-no-test_id",
                                 "summary": "C0/C1/C5 销号必须带机检用例（机检固化）"})

    baselines = check_baseline_consistency(pinned, root)
    baseline_bad = [b for b in baselines if not b["ok"]]

    status = "PASS" if not (mismatches or blocking_open or baseline_bad) else "FAIL"
    return {
        "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "pinned_version": pinned,
        "observed_version": observed,
        "from": changes.get("from"),
        "to": changes.get("to"),
        "total_changes": len(items),
        "by_category": dict(sorted(by_category.items())),
        "blocking_categories": list(BLOCKING),
        "blocking_open": blocking_open,
        "classification_mismatches": mismatches,
        "baseline_consistency": baselines,
        "status": status,
    }


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="pyside-nova 上游漂移离线门")
    ap.add_argument("--offline", action="store_true",
                    help="只读本地 pin + 变更登记 + 缓存（默认行为）")
    ap.add_argument("--online", action="store_true",
                    help="T2 在线周巡：P3 才实现，当前 rc 2（D3 已核定，节奏见 upstream/cadence.json）")
    ap.add_argument("--report", default="", help="结构化报告 JSON 输出路径（可选）")
    args = ap.parse_args(argv)

    if args.online:
        print("[upstream] --online 周巡（D3 09:37 核定的 T2 档）双源实现属 P3，尚未落地。")
        print("           节奏口径见 upstream/cadence.json / docs/PARITY_CADENCE.md；")
        print("           交付前请跑 --offline（T1 硬门）；本命令返回 rc 2（前置缺失，非产品红）。")
        return 2

    if not PIN_PATH.exists():
        print(f"[upstream] 事实源缺失：{PIN_PATH.relative_to(ROOT)} → rc 2")
        return 2
    try:
        pin = load_pin()
        changes = load_changes(pin)
    except (ValueError, OSError, json.JSONDecodeError) as exc:
        print(f"[upstream] pin / changes 读取失败：{exc} → rc 2")
        return 2

    report = evaluate(pin, changes)
    print("=" * 68)
    print(f"pyside-nova 上游漂移门 · pinned={report['pinned_version']} "
          f"observed={report['observed_version']} · {report['generated_at']}")
    print(f"  变更登记 {report['total_changes']} 条 · 分类分布 {report['by_category']}")
    for b in report["baseline_consistency"]:
        mark = "OK " if b["ok"] else "BAD"
        print(f"  [{mark}] baseline {b['path']}: {b['detail']}")
    for m in report["classification_mismatches"]:
        print(f"  [BAD] 分类漂移 {m['id']}: 登记 {m['declared']} / 计算 {m['computed']}")
    for b in report["blocking_open"]:
        print(f"  [BAD] 未销号阻断 {b['id']} ({b['category']}/{b['status']}): {b['summary']}")
    print(f"  结论：{report['status']}")
    print("=" * 68)

    if args.report:
        out = Path(args.report)
        if not out.is_absolute():
            out = ROOT / out
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n",
                       encoding="utf-8")
        print(f"  报告已写入：{out.relative_to(ROOT) if out.is_relative_to(ROOT) else out}")

    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
