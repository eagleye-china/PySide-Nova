#!/usr/bin/env python3
# scripts/nova_mcp.py
# Nova MCP server（对标 @quasar/mcp v1.0.0 · Quasar 2.33 "AI-ready" 新品类）：
# stdio JSON-RPC 2.0（MCP 传输 = 换行分隔 JSON），六工具离线口径 1:1 对标：
#   search_docs / list_pages / get_page / list_api / get_api / check_updates
# 数据源：docs/ai/（scripts/gen_apidocs.py 产物——版本化 API + 离线文档页）
# 设计要点（对标 @quasar/mcp "built for small context windows"）：
#   search 返回命中摘要而非全文；get_page 支持按节截取；全部离线、零网络、零依赖
"""Nova MCP server：AI agent 离线精确查询 Nova 版本化 API。

用法（MCP 客户端配置示例）：
    { "mcpServers": { "nova": { "command": "python",
      "args": ["scripts/nova_mcp.py", "--project", "/path/to/project"] } } }

依赖：仅标准库（离线包 docs/ai/ 由 scripts/gen_apidocs.py 生成）。
"""
import argparse
import json
import re
import sys
from pathlib import Path

PROTOCOL_VERSION = "2024-11-05"

TOOLS = [
    {
        "name": "search_docs",
        "description": "Keyword search over Nova API entries and documentation pages. "
                       "Returns compact hit summaries (type/prop/signal names + snippets), "
                       "not full documents — built for small context windows.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "keyword": {"type": "string", "description": "Search keyword (component/prop/signal/method/topic)"},
                "limit": {"type": "integer", "description": "Max hits (default 8)"}
            },
            "required": ["keyword"],
        },
    },
    {
        "name": "list_pages",
        "description": "List offline documentation pages available (name, title line, line count).",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "get_page",
        "description": "Read one documentation page (optionally a single markdown section, "
                       "e.g. section '## 5. 五期').",
        "inputSchema": {
            "type": "object",
            "properties": {
                "name": {"type": "string", "description": "Page file name (from list_pages)"},
                "section": {"type": "string", "description": "Optional section heading to extract"}
            },
            "required": ["name"],
        },
    },
    {
        "name": "list_api",
        "description": "List Nova public types (optionally filtered by module, e.g. 'Nova.Controls').",
        "inputSchema": {
            "type": "object",
            "properties": {"module": {"type": "string", "description": "Module filter"}}
        },
    },
    {
        "name": "get_api",
        "description": "Read the full versioned API of one type (properties/signals/methods with docs).",
        "inputSchema": {
            "type": "object",
            "properties": {
                "type": {"type": "string", "description": "Qualified type name, e.g. Nova.Controls.NovaEditor"}
            },
            "required": ["type"],
        },
    },
    {
        "name": "check_updates",
        "description": "Report the pyside-nova version this docs pack was generated from, "
                       "the Quasar parity baseline, and the AI-pack fingerprint (offline; no network).",
        "inputSchema": {"type": "object", "properties": {}},
    },
]


class NovaMcp:
    def __init__(self, project: Path):
        self.ai = project / "docs" / "ai"
        self.index = json.loads((self.ai / "index.json").read_text(encoding="utf-8"))
        self._api_cache: dict[str, dict] | None = None

    # ── 数据访问 ──────────────────────────────────────────────
    def _apis(self) -> dict[str, dict]:
        if self._api_cache is None:
            self._api_cache = {}
            for fp in sorted((self.ai / "api").glob("*.json")):
                self._api_cache[fp.stem] = json.loads(fp.read_text(encoding="utf-8"))
        return self._api_cache

    def _pages(self) -> list[Path]:
        return sorted((self.ai / "pages").glob("*.md"))

    # ── 工具实现 ──────────────────────────────────────────────
    def tool_search_docs(self, keyword: str, limit: int = 8) -> str:
        kw = keyword.lower().strip()
        if not kw:
            return "empty keyword"
        hits = []
        for name, api in self._apis().items():
            score = 0
            snippets = []
            if kw in api["name"].lower():
                score += 10
                snippets.append(f"type {api['name']} — {api['description'][:120]}")
            for p in api["properties"]:
                if kw in p["name"].lower():
                    score += 3
                    snippets.append(f"{api['name']}.{p['name']}: {p['type']}"
                                    + (f" — {p['doc']}" if p["doc"] else ""))
            for s in api["signals"]:
                if kw in s["name"].lower():
                    score += 3
                    snippets.append(f"{api['name']} signal {s['name']}({s['params']})")
            for m in api["methods"]:
                if kw in m["name"].lower():
                    score += 3
                    snippets.append(f"{api['name']} method {m['name']}({m['params']})")
            if kw in api["description"].lower() and score == 0:
                score += 1
                snippets.append(f"{api['name']} — {api['description'][:120]}")
            if score:
                hits.append((score, snippets[:4]))
        for fp in self._pages():
            lines = fp.read_text(encoding="utf-8").splitlines()
            found = [f"{fp.name}:{i+1}: {ln.strip()[:120]}"
                     for i, ln in enumerate(lines) if kw in ln.lower()][:3]
            if found:
                hits.append((1, found))
        hits.sort(key=lambda x: -x[0])
        if not hits:
            return f"no hits for '{keyword}'"
        out = []
        for _, snips in hits[:limit]:
            out.extend(snips)
        return "\n".join(out[:24])

    def tool_list_pages(self) -> str:
        out = []
        for fp in self._pages():
            first = fp.read_text(encoding="utf-8").splitlines()
            title = next((ln.lstrip("# ") for ln in first if ln.strip()), "")[:80]
            out.append(f"{fp.name} — {title} ({len(first)} lines)")
        return "\n".join(out) if out else "no pages"

    def tool_get_page(self, name: str, section: str | None = None) -> str:
        fp = self.ai / "pages" / Path(name).name
        if not fp.exists():
            return f"page not found: {name} (use list_pages)"
        text = fp.read_text(encoding="utf-8")
        if not section:
            return text[:12000]
        # 按节截取：宽松包含式定位（"## 1" 可命中 "## 第 1 章 …"）
        key = section.lstrip("# ").strip()
        lines = text.splitlines()
        start = None
        level = 0
        for i, ln in enumerate(lines):
            if not ln.startswith("#"):
                continue
            title = ln.lstrip("# ").strip()
            if key.lower() in title.lower():
                start = i
                level = len(ln) - len(ln.lstrip("#"))
                break
        if start is None:
            return f"section not found: {section} in {name}"
        end = len(lines)
        for j in range(start + 1, len(lines)):
            ln = lines[j]
            cur = len(ln) - len(ln.lstrip("#")) if ln.startswith("#") else 0
            if cur and cur <= level:
                end = j
                break
        return "\n".join(lines[start:end])[:12000]

    def tool_list_api(self, module: str | None = None) -> str:
        apis = self._apis()
        out = []
        for name in sorted(apis):
            if module and not name.lower().startswith(module.lower()):
                continue
            api = apis[name]
            out.append(f"{name} ({api['kind']}, {len(api['properties'])} props)")
        return "\n".join(out) if out else f"no types for module '{module}'"

    def tool_get_api(self, type_name: str) -> str:
        apis = self._apis()
        if type_name not in apis:
            # 宽松匹配：不带模块前缀
            cands = [k for k in apis if k.endswith("." + type_name)]
            if len(cands) == 1:
                type_name = cands[0]
            else:
                return f"type not found: {type_name} (use list_api)"
        return json.dumps(apis[type_name], ensure_ascii=False, indent=1)

    def tool_check_updates(self) -> str:
        return json.dumps({
            "package": self.index["package"],
            "docs_version": self.index["version"],
            "baseline": self.index["baseline"],
            "fingerprint": self.index["fingerprint"],
            "generated": self.index["generated"],
            "note": "offline docs pack — this is the exact version these docs describe; "
                    "no network lookup performed (对标 @quasar/mcp works-offline 口径)",
            "usage": self.index["usage"],
        }, ensure_ascii=False, indent=1)

    def dispatch(self, name: str, args: dict) -> str:
        if name == "search_docs":
            return self.tool_search_docs(args["keyword"], int(args.get("limit", 8)))
        if name == "list_pages":
            return self.tool_list_pages()
        if name == "get_page":
            return self.tool_get_page(args["name"], args.get("section"))
        if name == "list_api":
            return self.tool_list_api(args.get("module"))
        if name == "get_api":
            return self.tool_get_api(args["type"])
        if name == "check_updates":
            return self.tool_check_updates()
        raise KeyError(f"unknown tool: {name}")


def serve(project: Path) -> int:
    """stdio JSON-RPC 2.0 主循环（MCP 换行分隔传输；stdout 只出协议 JSON）。"""
    server = NovaMcp(project)
    for raw in sys.stdin:
        raw = raw.strip()
        if not raw:
            continue
        try:
            req = json.loads(raw)
        except json.JSONDecodeError:
            continue
        rid = req.get("id")
        method = req.get("method", "")
        if rid is None:
            continue                       # notification（initialized 等）：不回包
        if method == "initialize":
            result = {
                "protocolVersion": PROTOCOL_VERSION,
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "nova-mcp",
                               "version": server.index["version"]},
            }
        elif method == "tools/list":
            result = {"tools": TOOLS}
        elif method == "tools/call":
            params = req.get("params") or {}
            try:
                text = server.dispatch(params.get("name", ""),
                                       params.get("arguments") or {})
                result = {"content": [{"type": "text", "text": text}]}
            except Exception as exc:                      # noqa: BLE001
                result = {"content": [{"type": "text", "text": f"error: {exc}"}],
                          "isError": True}
        else:
            _send({"jsonrpc": "2.0", "id": rid,
                   "error": {"code": -32601, "message": f"method not found: {method}"}})
            continue
        _send({"jsonrpc": "2.0", "id": rid, "result": result})
    return 0


def _send(obj: dict) -> None:
    sys.stdout.write(json.dumps(obj, ensure_ascii=False) + "\n")
    sys.stdout.flush()


def main() -> int:
    ap = argparse.ArgumentParser(description="Nova MCP server（离线 AI 文档查询）")
    default = Path(__file__).resolve().parent.parent
    ap.add_argument("--project", type=Path, default=default,
                    help="项目根（含 docs/ai/ 离线包）")
    args = ap.parse_args()
    if not (args.project / "docs" / "ai" / "index.json").exists():
        print("缺少 docs/ai/index.json —— 先运行 scripts/gen_apidocs.py", file=sys.stderr)
        return 1
    return serve(args.project)


if __name__ == "__main__":
    sys.exit(main())