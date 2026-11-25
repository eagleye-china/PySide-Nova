#!/usr/bin/env python3
# scripts/gen_apidocs.py
# AI-ready 文档包生成器（对标 Quasar 2.33 "AI-ready out of the box"）：
# 扫描 qmldir + QML 源 → docs/ai/api/*.json（每类型 props/signals/methods/描述）
# + docs/ai/pages/（核心文档离线拷贝）+ docs/ai/index.json（版本指纹索引）
# 消费方：scripts/nova_mcp.py（Nova MCP server）——AI agent 精确查询 Nova 版本化 API，
# 杜绝"基于训练记忆的幻觉 props"
"""生成 Nova AI-ready 文档包（docs/ai/）。

用法：
    python scripts/gen_apidocs.py [--project ROOT]

产物：
    docs/ai/api/<Module>.<Type>.json   每公共类型一份 API 描述
    docs/ai/pages/<name>.md            核心文档离线拷贝
    docs/ai/index.json                 版本 + 基线 + 模块计数 + 内容指纹
"""
import argparse
import hashlib
import json
import re
import shutil
import sys
from datetime import date
from pathlib import Path

PROJECT = Path(__file__).resolve().parent.parent
QML_ROOT = PROJECT / "src" / "pyside_nova" / "qml" / "Nova"

# 核心文档离线拷贝清单（pages）
PAGES = [
    "README_zh.md", "CHANGELOG.md", "COMPONENT_LIST.md", "COMPONENTS.md", "ARCHITECTURE.md",
    "CONSTITUTION.md", "COMPOSITION_CONSTITUTION.md", "PARITY.md", "ECOSYSTEM_PARITY.md", "DESIGN_TOKENS.md",
    "MASTER_PLAN.md", "ROADMAP.md", "API_FREEZE.md",
]

PROP_RE = re.compile(
    r"^\s*(readonly\s+)?property\s+([\w<>]+)\s+(\w+)\s*(.*)$")
SIGNAL_RE = re.compile(r"^\s*signal\s+(\w+)\s*\(([^)]*)\)")
FUNC_RE = re.compile(r"^\s*function\s+(\w+)\s*\(([^)]*)\)")


def parse_qml(path: Path) -> dict:
    """从 QML 源提取类型描述 + props/signals/methods（含行内注释当摘要）。"""
    lines = path.read_text(encoding="utf-8").splitlines()
    # 头注释：第 1 行 src/ 路径，第 2~4 行描述素材
    desc = ""
    for ln in lines[1:5]:
        if ln.startswith("// "):
            desc += ln[3:].strip() + " "
        elif ln.strip() == "":
            break
    props, signals, methods = [], [], []
    for i, ln in enumerate(lines):
        m = PROP_RE.match(ln)
        if m and not ln.strip().startswith("//"):
            ro = m.group(1) is not None
            default = m.group(4).strip()
            comment = ""
            if "//" in default:
                default, comment = default.split("//", 1)
                comment = comment.strip()
                default = default.strip()
            props.append({
                "name": m.group(3),
                "type": m.group(2),
                "readonly": ro,
                "default": default or None,
                "doc": comment or None,
                "line": i + 1,
            })
            continue
        m = SIGNAL_RE.match(ln)
        if m:
            signals.append({"name": m.group(1), "params": m.group(2).strip()})
            continue
        m = FUNC_RE.match(ln)
        if m:
            methods.append({"name": m.group(1), "params": m.group(2).strip()})
    return {
        "description": desc.strip(),
        "properties": props,
        "signals": signals,
        "methods": methods,
    }


def read_qmldir(path: Path) -> tuple[str, list[dict]]:
    """解析 qmldir → (module 名, [{name, file, kind}])。kind: singleton|component。"""
    module = None
    types = []
    for ln in path.read_text(encoding="utf-8").splitlines():
        ln = ln.strip()
        if ln.startswith("module "):
            module = ln.split(None, 1)[1]
        elif ln.startswith("singleton "):
            _, name, _ver, fname = ln.split()
            types.append({"name": name, "file": fname, "kind": "singleton"})
        elif ln and not ln.startswith("#") and not ln.startswith("internal ") \
                and not ln.startswith("pragma ") and not ln.startswith("depends"):
            parts = ln.split()
            if len(parts) >= 3 and parts[1].startswith("1."):
                types.append({"name": parts[0], "file": parts[2], "kind": "component"})
    return module or "", types


def build(project: Path) -> dict:
    qml_root = project / "src" / "pyside_nova" / "qml" / "Nova"
    out_api = project / "docs" / "ai" / "api"
    out_pages = project / "docs" / "ai" / "pages"
    out_api.mkdir(parents=True, exist_ok=True)
    out_pages.mkdir(parents=True, exist_ok=True)

    # 版本唯一来源
    about = (project / "src" / "pyside_nova" / "__about__.py").read_text(encoding="utf-8")
    version = re.search(r'__version__\s*=\s*"([^"]+)"', about).group(1)

    modules = {}
    api_files: list[Path] = []
    for qmldir in sorted(qml_root.glob("**/qmldir")):  # 递归：含 Composite/LayoutShell 嵌套模块
        module, types = read_qmldir(qmldir)
        mod_entry = {"types": [], "singletons": [], "count": 0}
        for t in types:
            src = qmldir.parent / t["file"]
            if not src.exists():
                continue
            info = parse_qml(src)
            doc = {
                "name": f"{module}.{t['name']}",
                "kind": t["kind"],
                "source": str(src.relative_to(project)).replace("\\", "/"),
                **info,
            }
            fp = out_api / f"{module}.{t['name']}.json"
            fp.write_text(json.dumps(doc, indent=1, ensure_ascii=False), encoding="utf-8")
            api_files.append(fp)
            mod_entry["count"] += 1
            (mod_entry["singletons"] if t["kind"] == "singleton" else mod_entry["types"])\
                .append(t["name"])
        modules[module] = mod_entry

    # pages 离线拷贝
    copied = []
    for name in PAGES:
        src = project / "docs" / name if (project / "docs" / name).exists() \
            else project / name
        if src.exists():
            shutil.copyfile(src, out_pages / name)
            copied.append(name)

    # 内容指纹（全部 api JSON 排序后哈希）
    h = hashlib.sha256()
    for fp in sorted(api_files):
        h.update(fp.name.encode())
        h.update(fp.read_bytes())
    index = {
        "package": "pyside-nova",
        "version": version,
        "baseline": "Quasar 2.35.5",
        "generated": str(date.today()),
        "modules": {k: v["count"] for k, v in sorted(modules.items())},
        "types_total": sum(v["count"] for v in modules.values()),
        "pages": copied,
        "fingerprint": h.hexdigest()[:16],
        "usage": "AI agents: use scripts/nova_mcp.py tools (search_docs/list_pages/"
                 "get_page/list_api/get_api/check_updates) — offline, version-exact.",
    }
    (project / "docs" / "ai" / "index.json").write_text(
        json.dumps(index, indent=2, ensure_ascii=False), encoding="utf-8")
    return index


def main() -> int:
    ap = argparse.ArgumentParser(description="生成 Nova AI-ready 文档包（docs/ai/）")
    ap.add_argument("--project", type=Path, default=PROJECT)
    args = ap.parse_args()
    index = build(args.project)
    print(f"AI-ready 包：{index['types_total']} 类型 API + {len(index['pages'])} 页文档"
          f"（指纹 {index['fingerprint']}）→ docs/ai/")
    return 0


if __name__ == "__main__":
    sys.exit(main())