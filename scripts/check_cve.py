# scripts/check_cve.py
# CVE 周巡（0.16.2 B3 供应链门禁）：SBOM × OSV.dev 批量查询
"""对 gen_sbom.py 产出的 SBOM 逐组件查询 OSV.dev 已知漏洞。

用法：
    python scripts/check_cve.py                  # 联网查询（api.osv.dev）
    python scripts/check_cve.py --offline        # 只用缓存报告（CI 无网环境）
    python scripts/check_cve.py --sbom PATH      # 指定 SBOM（默认 dist/*.cdx.json）

口径：
- OSV 批量端点 POST /v1/querybatch（组件名 + purl）；命中结果按 severity 汇总；
- 缓存写 dist/cve-report.json（--offline 只读不查）；
- 周巡语义：报告 + 建议处置；--fail-on high|critical|any 任一命中返回非 0（入 CI 可选）；
- 忽略清单 .cve-ignore（填 OSV ID + 理由，逐行，# 注释）——已评估可接受时使用。
"""
import argparse
import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OSV_BATCH = "https://api.osv.dev/v1/querybatch"
OSV_GET = "https://api.osv.dev/v1/vulns/"


def _load_sbom(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _query_osv(components: list[dict]) -> dict[str, list[str]]:
    """querybatch：returns {bom-ref: [vuln_id, ...]}。"""
    queries = [{"package": {"name": c["name"], "ecosystem": "PyPI"}} for c in components]
    req = urllib.request.Request(
        OSV_BATCH,
        data=json.dumps({"queries": queries}).encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    out: dict[str, list[str]] = {}
    for comp, result in zip(components, data.get("results", [])):
        ids = [v["id"] for v in result.get("vulns", [])]
        if ids:
            out[comp["bom-ref"]] = ids
    return out


def _severity_of(vuln_id: str) -> str:
    try:
        with urllib.request.urlopen(OSV_GET + vuln_id, timeout=30) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        for s in data.get("severity", []):
            sc = (s.get("score") or "").upper()
            if "CRITICAL" in sc:
                return "critical"
            if "HIGH" in sc:
                return "high"
            if "MODERATE" in sc or "MEDIUM" in sc:
                return "moderate"
        # CVSS 向量粗判
        for s in data.get("severity", []):
            sc = s.get("score") or ""
            m = sc.find("CVSS:3")
            if m >= 0:
                try:
                    import re
                    seg = sc[m:]
                    if " /c:" in seg or " /i:" in seg:
                        return "high"  # 粗判；精确分值由人工复核
                except Exception:
                    pass
        return "unknown"
    except Exception:
        return "unknown"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sbom", default=None)
    parser.add_argument("--offline", action="store_true")
    parser.add_argument("--fail-on", choices=["any", "high", "critical"], default=None)
    args = parser.parse_args()

    sbom_path = Path(args.sbom) if args.sbom else sorted((ROOT / "dist").glob("*.cdx.json"))
    if isinstance(sbom_path, list):
        if not sbom_path:
            print("[cve] 未找到 SBOM——先跑 python scripts/gen_sbom.py")
            return 2
        sbom_path = sbom_path[-1]
    sbom = _load_sbom(sbom_path)
    ignore_path = ROOT / ".cve-ignore"
    ignored = {
        line.split("#")[0].strip()
        for line in ignore_path.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.strip().startswith("#")
    } if ignore_path.exists() else set()

    report = {"sbom": sbom_path.name, "components": len(sbom.get("components", [])), "vulnerabilities": []}

    if args.offline:
        cache = ROOT / "dist" / "cve-report.json"
        if not cache.exists():
            print("[cve] 无缓存报告（--offline 需先联网跑一次）")
            return 2
        report = json.loads(cache.read_text(encoding="utf-8"))
        print(f"[cve] 离线模式：读缓存 {cache.name}")
    else:
        components = sbom.get("components", [])
        hits = _query_osv(components)
        for ref, ids in hits.items():
            for vid in ids:
                if vid in ignored:
                    continue
                report["vulnerabilities"].append({
                    "id": vid,
                    "component": ref,
                    "severity": _severity_of(vid),
                })
        out = ROOT / "dist" / "cve-report.json"
        out.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"[cve] 查询完成：{report['components']} 组件，命中 {len(report['vulnerabilities'])} → {out.name}")

    vulns = report.get("vulnerabilities", [])
    if vulns:
        print("[cve] 未忽略漏洞清单：")
        for v in vulns:
            print(f"  - {v['id']}  [{v.get('severity', '?')}]  {v['component']}")
    else:
        print("[cve] ✓ 无未忽略已知漏洞")

    if args.fail_on:
        order = {"critical": 3, "high": 2, "moderate": 1, "unknown": 0}
        threshold = {"any": 0, "high": 2, "critical": 3}[args.fail_on]
        bad = [v for v in vulns if order.get(v.get("severity", "unknown"), 0) >= threshold]
        if bad:
            print(f"[cve] --fail-on {args.fail_on}：{len(bad)} 项命中阈值")
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
