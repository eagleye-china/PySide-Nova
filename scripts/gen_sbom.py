# scripts/gen_sbom.py
# SBOM 生成（0.16.2 B3 供应链门禁）：CycloneDX 1.5 JSON
"""生成 CycloneDX 1.5 格式 SBOM（软件物料清单）。

用法：
    python scripts/gen_sbom.py                    # 输出 dist/pyside-nova-x.y.z.cdx.json
    python scripts/gen_sbom.py --out PATH         # 指定输出路径

口径：
- rootComponent = pyside-nova（读 __about__）；components = 运行时依赖（pyproject dependencies）
  + dev 依赖（pytest/build，标记 scope=optional dev）+ 当前环境实际安装版本（importlib.metadata）；
- 许可证逐包读取 dist metadata（Classifier/License 字段），未知标 NOASSERTION；
- 生成物**禁止手改**（宪法口径）；周巡 CVE 查询由 check_cve.py 消费本文件。

无第三方 SBOM 库依赖（离线可用、零风险面——SBOM 生成器本身也该进 SBOM）。
"""
import argparse
import json
import sys
from datetime import datetime, timezone
from importlib import metadata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "src"))

from pyside_nova import __about__  # noqa: E402


def _parse_pyproject_deps() -> list[dict]:
    """读 pyproject：returns [{name, scope}]。"""
    text = (ROOT / "pyproject.toml").read_text(encoding="utf-8")
    out = []
    # 运行时依赖（Tomllib 兼容 3.11）
    import tomllib
    data = tomllib.loads(text)
    for dep in data["project"].get("dependencies", []):
        out.append({"name": _dep_name(dep), "scope": "required"})
    for dep in data["project"].get("optional-dependencies", {}).get("dev", []):
        out.append({"name": _dep_name(dep), "scope": "optional"})
    return out


def _dep_name(req: str) -> str:
    return req.split(";")[0].split(">")[0].split("<")[0].split("=")[0].split("[")[0].strip()


def _license_of(dist_name: str) -> str:
    try:
        dist = metadata.distribution(dist_name)
        meta = dist.metadata
        lic = (meta.get("License") or "").strip()
        if lic:
            return lic.splitlines()[0][:120]
        classifiers = [c for c in meta.get_all("Classifier") or [] if c.startswith("License ::")]
        if classifiers:
            return classifiers[0].split("::")[-1].strip()
    except metadata.PackageNotFoundError:
        pass
    return "NOASSERTION"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default=None)
    args = parser.parse_args()

    deps = _parse_pyproject_deps()
    components = []
    for dep in deps:
        try:
            ver = metadata.version(dep["name"])
        except metadata.PackageNotFoundError:
            ver = "0.0.0-MISSING"
        components.append({
            "type": "library",
            "bom-ref": f"pkg:pypi/{dep['name'].lower()}@{ver}",
            "name": dep["name"],
            "version": ver,
            "scope": dep["scope"],
            "licenses": [{"license": {"name": _license_of(dep["name"])}}],
            "purl": f"pkg:pypi/{dep['name'].lower()}@{ver}",
        })

    bom = {
        "bomFormat": "CycloneDX",
        "specVersion": "1.5",
        "serialNumber": f"urn:uuid:nova-{int(datetime.now(timezone.utc).timestamp())}",
        "version": 1,
        "metadata": {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "component": {
                "type": "library",
                "bom-ref": f"pkg:pypi/{__about__.__title__}@{__about__.__version__}",
                "name": __about__.__title__,
                "version": __about__.__version__,
                "purl": f"pkg:pypi/{__about__.__title__}@{__about__.__version__}",
            },
            "tools": [{"name": "gen_sbom.py", "version": "0.16.2"}],
        },
        "components": components,
    }

    out = args.out or str(ROOT / "dist" / f"pyside-nova-{__about__.__version__}.cdx.json")
    Path(out).parent.mkdir(parents=True, exist_ok=True)
    Path(out).write_text(json.dumps(bom, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"[sbom] {len(components)} 组件 → {out}")
    for c in components:
        print(f"  - {c['name']}=={c['version']}  [{c['scope']}]  {c['licenses'][0]['license']['name']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
