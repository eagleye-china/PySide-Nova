#!/usr/bin/env python3
# scripts/gen_upstream_manifest.py
# 上游全量面清单生成器：官方 npm tarball 缓存 → manifest（脚本计数，禁手写清单）
"""从 ``upstream/cache/api-<pinned>/`` 生成上游全量面 ``upstream/manifest-<pinned>.json``。

**为什么需要它**：提案 R2 的根因是「上游基线无单一事实源 + 口径散落」。本脚本复用
``migrate2nova`` 的冻结面自动探测范式：清单完全由脚本枚举缓存目录得出，**禁止手写
上游组件清单**；每个文件带 sha256，离线可复现（对齐 ``check_cve.py --offline`` 缓存）。

用法::

    python scripts/gen_upstream_manifest.py            # 生成 / 覆盖 manifest
    python scripts/gen_upstream_manifest.py --check   # 幂等校验（不写盘）
    python scripts/gen_upstream_manifest.py --refresh # P3 在线刷新未实现 → rc 2

退出码：0 = 成功 / 一致；1 = 幂等漂移或前置错误；2 = 未实现的前置（--refresh）。

**边界**：纯标准库、默认零联网、只读缓存；``generated_at`` 不参与签名，保证 --check 稳定。
"""
from __future__ import annotations

import argparse
import hashlib
import json
from collections import Counter
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PIN_PATH = ROOT / "upstream" / "quasar-pin.json"
MEMBER_KEYS = (
    "props", "slots", "events", "methods", "computedProps",
    "injection", "quasarConfOptions", "value",
)


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def load_pin() -> dict:
    return json.loads(PIN_PATH.read_text(encoding="utf-8"))


def member_counts(doc: dict) -> dict[str, int]:
    """按上游 JSON 的实际键计数；directive 的 ``value`` 是单对象，按 1 项计。"""
    counts: dict[str, int] = {}
    for key in MEMBER_KEYS:
        val = doc.get(key)
        if isinstance(val, dict):
            counts[key] = len(val)
        elif val is not None:
            counts[key] = 1
    return counts


def build(pin: dict, root: Path = ROOT) -> dict:
    version = pin["pinned_version"]
    cache = root / "upstream" / "cache" / f"api-{version}"
    if not cache.is_dir():
        raise FileNotFoundError(f"上游元数据缓存缺失：{cache.relative_to(root)}")

    entries: list[dict] = []
    total_bytes = 0
    by_type: Counter[str] = Counter()
    by_facet: Counter[str] = Counter()
    for path in sorted(cache.glob("*.json")):
        raw = path.read_bytes()
        doc = json.loads(raw.decode("utf-8"))
        up_type = str(doc.get("type", "unknown"))
        counts = member_counts(doc)
        total_bytes += len(raw)
        by_type[up_type] += 1
        for k, v in counts.items():
            by_facet[k] += v
        entries.append({
            "name": path.name,
            "upstream_type": up_type,
            "bytes": len(raw),
            "sha256": _sha256(raw),
            "member_counts": counts,
            "member_total": sum(counts.values()),
        })

    if not entries:
        raise ValueError("缓存目录为空，拒绝生成空 manifest（禁手写清单）")

    manifest: dict = {
        "schema": "nova-upstream-manifest/1",
        "pinned_version": version,
        "source": f"npm:quasar@{version} package/dist/api/*.json (official tarball)",
        "license_note": (
            "Inspired by Quasar (MIT). Public API metadata only. "
            "No source code reuse; no fork/port claim."
        ),
        "cache_dir": f"upstream/cache/api-{version}",
        "totals": {
            "files": len(entries),
            "bytes": total_bytes,
            "by_type": dict(sorted(by_type.items())),
            "member_items": sum(e["member_total"] for e in entries),
            "by_facet": dict(sorted(by_facet.items())),
        },
        "entries": entries,
    }
    # 签名只覆盖稳定字段：generated_at / signature 自身不参与，保证 --check 幂等。
    stable = {k: v for k, v in manifest.items() if k != "signature"}
    manifest["signature"] = _sha256(
        json.dumps(stable, sort_keys=True, ensure_ascii=False).encode("utf-8"))
    manifest["generated_at"] = datetime.now().astimezone().isoformat(timespec="seconds")
    return manifest


def _stable_signature(doc: dict) -> str:
    stable = {k: v for k, v in doc.items()
              if k not in ("signature", "generated_at")}
    return _sha256(json.dumps(stable, sort_keys=True, ensure_ascii=False).encode("utf-8"))


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="生成 / 校验上游全量面 manifest")
    ap.add_argument("--check", action="store_true", help="幂等校验，不写盘")
    ap.add_argument("--refresh", action="store_true",
                    help="在线刷新缓存：P3 周巡范围，当前返回 rc 2")
    args = ap.parse_args(argv)

    if args.refresh:
        print("[manifest] --refresh 在线刷新属 P3 范围（CSA D3 未拍板），尚未实现。")
        print("           当前缓存来自官方 npm tarball，离线可复现；返回 rc 2。")
        return 2

    try:
        pin = load_pin()
        fresh = build(pin)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"[manifest] 生成失败：{exc} → rc 1")
        return 1

    out = ROOT / "upstream" / f"manifest-{pin['pinned_version']}.json"
    if args.check:
        if not out.exists():
            print(f"[manifest] 缺失：{out.relative_to(ROOT)} → rc 1")
            return 1
        existing = json.loads(out.read_text(encoding="utf-8"))
        ok = _stable_signature(existing) == fresh["signature"]
        print(f"[manifest] --check {'PASS' if ok else 'FAIL'} · "
              f"files={fresh['totals']['files']} · "
              f"member_items={fresh['totals']['member_items']} · "
              f"signature={fresh['signature'][:16]}")
        return 0 if ok else 1

    out.write_text(json.dumps(fresh, indent=2, ensure_ascii=False) + "\n",
                   encoding="utf-8")
    t = fresh["totals"]
    print(f"[manifest] 已写入 {out.relative_to(ROOT)}")
    print(f"           files={t['files']} · by_type={t['by_type']} · "
          f"member_items={t['member_items']} · by_facet={t['by_facet']}")
    print(f"           signature={fresh['signature'][:16]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
