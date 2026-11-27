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
    docs/components/<Name>.md          20 个组合根容器逐组件 API 页（T9/P0-3）
    docs/components/index.md           20 项总览
    docs/components/showcase.md        60 张三态装配图索引
    docs/assets/js/nova-data.js        站点产品化层数据（T9/P1+P2）
    docs/tools/*.md                    Playground / Layout Builder / 示例浏览器
    docs/community/*.md                社区入口与治理文件投影
    docs/en/*.md                      英文骨架页（i18n 语言切换器目标）
"""
import argparse
import hashlib
import json
import os
import re
import sys
from datetime import date
from pathlib import Path

PROJECT = Path(__file__).resolve().parent.parent
QML_ROOT = PROJECT / "src" / "pyside_nova" / "qml" / "Nova"

# 核心文档离线拷贝清单（pages）
PAGES = [
    "README_zh.md", "CHANGELOG.md", "COMPONENT_LIST.md", "COMPONENTS.md", "ARCHITECTURE.md",
    "CONSTITUTION.md", "COMPOSITION_CONSTITUTION.md", "PARITY.md", "ECOSYSTEM_PARITY.md", "DESIGN_TOKENS.md",
    "QUASAR_ACKNOWLEDGEMENT.md", "prescript/GUIDE_COMPONENT_THEMES.md",
    "MASTER_PLAN.md", "ROADMAP.md", "API_FREEZE.md",
]


def rewrite_links(text: str, src_dir: Path, dst_dir: Path) -> str:
    """离线拷贝时重写相对链接：以「源文档目录」解析，再以「目标目录」重新表达。

    生成物副本不再原样复制（那会让 docs/ 或根级相对链接基准失效，产生伪断链）；
    重写后每个链接仍指向与源文档相同的真实文件。外部 URL / 纯锚点 / mailto 原样保留，
    #anchor 与 ?query 原样回拼。生成物一律由本函数产出，禁止手工编辑。
    """
    def _sub(m):
        raw = m.group(1)
        if raw.startswith(("http://", "https://", "#", "mailto:")):
            return m.group(0)
        anchor = ""
        if "#" in raw:
            raw, _, anchor = raw.partition("#")
            anchor = "#" + anchor
        query = ""
        if "?" in raw:
            raw, _, query = raw.partition("?")
            query = "?" + query
        if not raw:
            return m.group(0)
        target = (src_dir / raw).resolve()
        rel = os.path.relpath(target, dst_dir).replace(os.sep, "/")
        return "]({}{}{})".format(rel, query, anchor)
    return re.sub(r"\]\(([^)]+)\)", _sub, text)


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
            text = src.read_text(encoding="utf-8")
            # 清单项可含 docs/ 子路径（如 prescript/GUIDE_*.md）；离线拷贝扁平化为文件名，
            # 避免 out_pages 下新建子目录，同时 rewrite_links 仍按源目录解析相对链接。
            flat = Path(name).name
            (out_pages / flat).write_text(
                rewrite_links(text, src.parent, out_pages), encoding="utf-8")
            copied.append(flat)

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


# ---------------------------------------------------------------------------
# T9 / P0-3 · 逐组件文档页生成器（对齐 Quasar 逐组件 Props / Slots / Events 页）
#   事实源：api/nova-api-1.8.0.json（冻结签名，唯一权威）
#           + QML 源 parse_qml()（中文描述 / 默认值）
#           + Composite/LayoutShell/README.md（分类 / 身份 / 依赖）
#           + docs/prescript/AUDIT_CEILING.md §8（20 项销号台账）
#           + docs/screenshots/*_showcase_*.png（60 张三态装配图）
#   产物：docs/components/index.md · <Name>.md × 20 · showcase.md
#   生成物一律由本函数产出，禁止手工编辑；重跑本生成器即完成同步。
#   硬约束：只读冻结面，绝不新增 / 改写任何公共 QML API。
# ---------------------------------------------------------------------------
COMPOSITE_MODULE = "Nova.Composite.LayoutShell"

CATEGORY_RE = re.compile(r"^###\s+(.+?)（(\d+)）\s*$", re.M)
COMPONENT_HEAD_RE = re.compile(r"^####\s+`(Nova\w+)`\s+—\s+(.+?)\s*$", re.M)
FIELD_RE = re.compile(r"^-\s+\*\*(.+?)\*\*：(.+)$", re.M)
AUDIT_ROW_RE = re.compile(
    r"^\|\s*\d+\s*\|\s*\*\*(Nova\w+)\*\*\s*\|\s*([^|]+?)\s*\|"
    r"\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|\s*$", re.M)


def _clean_default(v) -> str:
    """parse_qml 的默认值形如 ': true' / ': 56'，归一为表格单元格文本。"""
    if not v:
        return "—"
    v = v.strip()
    if v.startswith(":"):
        v = v[1:].strip()
    return v or "—"


def _split_signature(s: str) -> tuple[str, str]:
    """'foo(int x)' → ('foo', 'int x')；'foo:bool' → ('foo', 'bool')。"""
    s = s.strip()
    m = re.match(r"^(\w+)\((.*)\)$", s)
    if m:
        return m.group(1), m.group(2).strip()
    if ":" in s:
        n, t = s.split(":", 1)
        return n.strip(), t.strip()
    return s, ""


def _parse_module_readme(path: Path) -> dict:
    """解析模块 README「三、20 项完整契约」→ {name: {category, title, fields}}。"""
    text = path.read_text(encoding="utf-8")
    cats = list(CATEGORY_RE.finditer(text))
    result = {}
    for i, m in enumerate(cats):
        start = m.end()
        end = cats[i + 1].start() if i + 1 < len(cats) else len(text)
        nxt = re.search(r"^##\s+", text[start:end], re.M)
        if nxt:
            end = start + nxt.start()
        block = text[start:end]
        heads = list(COMPONENT_HEAD_RE.finditer(block))
        for j, h in enumerate(heads):
            fend = heads[j + 1].start() if j + 1 < len(heads) else len(block)
            fields = {fm.group(1): fm.group(2).strip()
                      for fm in FIELD_RE.finditer(block[h.end():fend])}
            result[h.group(1)] = {
                "category": m.group(1).strip(),
                "title": h.group(2).strip(),
                "fields": fields,
            }
    return result


def _parse_audit(path: Path) -> dict:
    """解析 CEILING_AUDIT.md §8 销号进度表 → {name: {batch, status, states, note}}。"""
    text = path.read_text(encoding="utf-8")
    return {
        m.group(1): {"batch": m.group(2).strip(), "status": m.group(3).strip(),
                     "states": m.group(4).strip(), "note": m.group(5).strip()}
        for m in AUDIT_ROW_RE.finditer(text)
    }


# 缩写连写类型的展示目录别名（NovaDE 是缩写，snake 化会得到 d_e，与实际目录 de 不符）
_SHOWCASE_ALIAS = {"NovaDE": "de", "NovaAIReport": "ai_report"}


def _showcase_prefix(name: str, prefixes: set) -> str | None:
    """NovaThreeColumn → three_column；NovaFlexLayout → flex（事实源前缀回退匹配）。

    缩写连写类型（如 NovaDE）走显式别名表，避免自动 snake 化误推。
    """
    alias = _SHOWCASE_ALIAS.get(name)
    if alias and alias in prefixes:
        return alias
    snake = re.sub(r"(?<!^)(?=[A-Z])", "_", name[4:]).lower()
    if snake in prefixes:
        return snake
    parts = snake.split("_")
    for i in range(len(parts) - 1, 0, -1):
        cand = "_".join(parts[:i])
        if cand in prefixes:
            return cand
    return None


def _deps(fields: dict) -> list[str]:
    """README「- **依赖**：Theme · Header · …」→ ['NovaTheme', 'NovaHeader', …]。"""
    raw = fields.get("依赖", "").split("｜")[0]
    return ["Nova" + x.strip() for x in raw.split("·") if x.strip()]


def _cell(s) -> str:
    return str(s).replace("|", "\\|").replace("\n", " ")


def _table(headers: list[str], rows: list[list]) -> str:
    out = ["| " + " | ".join(headers) + " |",
           "|" + "|".join(["---"] * len(headers)) + "|"]
    for r in rows:
        out.append("| " + " | ".join(_cell(x) for x in r) + " |")
    return "\n".join(out)


def _render_component_page(ctx: dict) -> str:
    name, entry = ctx["name"], ctx["entry"]
    meta, audit, prefix = ctx["meta"], ctx["audit"], ctx["prefix"]
    version, fingerprint, total = ctx["version"], ctx["fingerprint"], ctx["total"]
    shell_count = ctx.get("shellCount", total)

    desc = (ctx["ai"].get("description") or "").strip()
    defaults = {p["name"]: p["default"] for p in ctx["ai"].get("properties", [])}
    fields = meta.get("fields", {})
    deps = _deps(fields)

    props_rows, slot_rows = [], []
    for raw in entry["props"]:
        # 冻结 JSON 以 'ro ' 前缀标注 readonly property（冻结面全量）
        ro = raw.startswith("ro ")
        n, t = _split_signature(raw[3:] if ro else raw)
        suffix = " *(只读)*" if ro else ""
        if t == "alias":
            slot_rows.append([f"`{n}`" + suffix, "`alias`",
                              "业务内容注入槽；顶层须 `anchors.fill: parent`（CC-6）"])
        else:
            d = _clean_default(defaults.get(n))
            props_rows.append([f"`{n}`" + suffix, f"`{t}`",
                               "—" if d == "—" else f"`{d}`"])
    sig_rows = [[f"`{_split_signature(x)[0]}`",
                 f"`{_split_signature(x)[1]}`" if _split_signature(x)[1] else "—",
                 "组件只 emit，不自写宿主状态"] for x in entry["signals"]]
    meth_rows = [[f"`{_split_signature(x)[0]}`",
                  f"`{_split_signature(x)[1]}`" if _split_signature(x)[1] else "—",
                  "命令式调用"] for x in entry["methods"]]

    parts = [
        f"# {name} · {meta.get('title') or '组合根容器'}",
        "",
        f"> **模块** `{COMPOSITE_MODULE}` · **分类** {meta.get('category', '未分类')} · "
        f"**pyside-nova {version}** · API 冻结指纹 `{fingerprint}` · "
        f"**{shell_count}/{shell_count} 天花板销号** · a11y `{entry.get('a11y', '—')}`",
        "> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；"
        "重跑生成器即可同步。",
        "",
        "## 概览",
        "",
        desc or "（组件描述见模块 README）",
        "",
    ]
    if fields.get("身份"):
        parts.append(f"- **身份**：{fields['身份']}")
    if deps:
        parts.append("- **依赖组件**：" + "、".join(f"`{d}`" for d in deps)
                     + "（全部为库内已导出公共类型）")
    if audit:
        parts.append(f"- **天花板销号**：{audit['status']} · {audit['batch']} · "
                     f"三态「{audit['states']}」")
        parts.append(f"- **台账备注**：{audit['note'] or '—'}")
    parts += [f"- **源码**：`{entry['file']}`", ""]

    parts += ["## Props", "",
              _table(["属性", "类型", "默认值"], props_rows) if props_rows
              else "（无公开配置属性）", ""]
    parts += ["## Slots", "",
              _table(["槽位", "类型", "说明"], slot_rows) if slot_rows
              else "（无 alias 槽位）", ""]
    parts += ["## Events / Signals", "",
              _table(["信号", "参数", "语义"], sig_rows) if sig_rows
              else "（该组件不 emit 信号）", ""]
    parts += ["## Methods", "",
              _table(["方法", "参数", "语义"], meth_rows) if meth_rows
              else "（该组件无公开方法）", ""]

    first_slot = next((_split_signature(x)[0] for x in entry["props"]
                       if x.endswith(":alias")), None)
    example = ["import QtQuick", f"import {COMPOSITE_MODULE}", "",
               f"{name} {{", "    anchors.fill: parent"]
    if first_slot:
        example += ["", f"    {first_slot}: Item {{", "        anchors.fill: parent",
                    "        // 业务内容：注入顶层须铺满（CC-6）", "    }"]
    example.append("}")
    parts += ["## 最小示例", "", "```qml", *example, "```", ""]

    if prefix:
        parts += ["## 三态装配图", "",
                  "> 真实 Qt Quick 引擎渲染；60 张全量索引见 [装配图索引](showcase.md)", "",
                  _table(["浅色", "深色", "变体"], [[
                      f"![浅色](../screenshots/{prefix}_showcase_light.png)",
                      f"![深色](../screenshots/{prefix}_showcase_dark.png)",
                      f"![变体](../screenshots/{prefix}_showcase_variant.png)",
                  ]]), ""]
    else:
        parts += ["## 三态装配图", "", "（未找到对应装配图）", ""]

    parts += ["## 相关", "",
              f"- [{shell_count} 项组合根容器总览](index.md)",
              f"- [{shell_count * 3} 张三态装配图索引](showcase.md)",
              f"- [CARF-R {shell_count}/{shell_count} 销号台账](../prescript/AUDIT_CEILING.md)",
              f"- [组件清单（{total} 项）](../COMPONENT_LIST.md)",
              "- [API 冻结清单](../API_FREEZE.md)",
              ""]
    return "\n".join(parts)


def _render_index(rows: list[dict], version: str, fingerprint: str,
                  total: int, shell_count: int) -> str:
    by_cat: dict[str, list[dict]] = {}
    for r in rows:
        by_cat.setdefault(r["category"], []).append(r)
    parts = [
        f"# 组合根容器（{shell_count} 项）", "",
        f"> **{COMPOSITE_MODULE}** · pyside-nova **{version}** · "
        f"**{total} 个导出类型** · API 冻结指纹 `{fingerprint}` · "
        f"**{shell_count}/{shell_count} 六维天花板全部销号**（CARF-R）",
        "> 本页由 `scripts/gen_apidocs.py` 自动生成，**禁止手工编辑**。", "",
        f"{shell_count} 个组合根容器按语义分为 {len(by_cat)} 类；每个容器都由 ≥2 个已导出公共类型组合、"
        "一律 `property alias` 槽位、只 emit 不自写宿主状态。", "",
    ]
    for cat, items in by_cat.items():
        parts += [f"## {cat}（{len(items)}）", "",
                  _table(["组件", "说明", "Props", "Slots", "Signals", "文档"], [
                      [f"[{r['name']}]({r['name']}.md)", r["title"],
                       str(r["props"]), str(r["slots"]), str(r["signals"]),
                       f"[API 页]({r['name']}.md)"]
                      for r in items]), ""]
    parts += ["## 契约基线", "",
              "- **CC-1~CC-8** 组合态一致性契约（组合宪法 1.0.0 第 9 章）",
              "- **NovaTheme** 唯一令牌源 · **NovaMotion** 唯一动效门面（CC-3）",
              "- `property alias` 槽位 + 注入顶层 `anchors.fill: parent`（CC-6）",
              f"- `_` 私有成员不进冻结面；公共 API 逐字不变（{total} 类型）", "",
              "## 相关", "",
              f"- [{shell_count * 3} 张三态装配图索引](showcase.md)",
              f"- [CARF-R {shell_count}/{shell_count} 销号台账](../prescript/AUDIT_CEILING.md)",
              f"- [组件清单（{total} 项）](../COMPONENT_LIST.md)",
              "- [API 冻结清单](../API_FREEZE.md)",
              ""]
    return "\n".join(parts)


def _render_showcase(rows: list[dict], version: str, shell_count: int) -> str:
    linked = [r for r in rows if r["prefix"]]
    parts = [
        f"# 三态装配图索引（{len(linked) * 3} 张）", "",
        f"> **{shell_count} 项组合根容器 × 浅色 / 深色 / 变体** · 真实 Qt Quick 引擎渲染 · "
        f"pyside-nova **{version}**",
        "> 本页由 `scripts/gen_apidocs.py` 自动生成，**禁止手工编辑**。", "",
        "每张三态图都是 `audit_ceiling.py` 机检的验收产物："
        "浅 / 深双主题实心注入 + 变体态极端非法入参稳态几何。", "",
        _table(["组件", "分类", "浅色", "深色", "变体"], [
            [f"[{r['name']}]({r['name']}.md)", r["category"],
             f"[浅色](../screenshots/{r['prefix']}_showcase_light.png)",
             f"[深色](../screenshots/{r['prefix']}_showcase_dark.png)",
             f"[变体](../screenshots/{r['prefix']}_showcase_variant.png)"]
            for r in linked]), "",
        "## 相关", "",
        f"- [{shell_count} 项组合根容器总览](index.md)",
        f"- [CARF-R {shell_count}/{shell_count} 销号台账](../prescript/AUDIT_CEILING.md)",
        "",
    ]
    return "\n".join(parts)


def _collect_components(project: Path) -> dict:
    """汇总逐组件页 / 站点产品化层共用的唯一事实源（冻结 JSON + QML + README + 台账 + 三态装配图）。"""
    freeze = json.loads((project / "api" / "nova-api-1.8.0.json").read_text(encoding="utf-8"))
    about = (project / "src" / "pyside_nova" / "__about__.py").read_text(encoding="utf-8")
    version = re.search(r'__version__\s*=\s*"([^"]+)"', about).group(1)
    fingerprint = freeze["fingerprint"]
    total = freeze["counts"]["total"]
    types = freeze["types"]
    fq_names = sorted(k for k in types if k.startswith(COMPOSITE_MODULE + "."))

    qml_dir = (project / "src" / "pyside_nova" / "qml" / "Nova"
               / "Composite" / "LayoutShell")
    # 1.2.0 起组合根按九类物理子目录归档；真实路径以 qmldir 为唯一事实源
    qml_files = {t["name"]: t["file"]
                 for t in read_qmldir(qml_dir / "qmldir")[1]}
    meta = _parse_module_readme(qml_dir / "README.md")
    audit = _parse_audit(project / "docs" / "prescript" / "AUDIT_CEILING.md")
    prefixes = {
        p.name[:-len("_showcase_light.png")]
        for p in (project / "docs" / "screenshots").glob("*_showcase_light.png")
    }

    ctxs = []
    for fq in fq_names:
        name = fq.split(".")[-1]
        entry = types[fq]
        src = qml_dir / qml_files[name]
        ai = parse_qml(src) if src.exists() else {"description": "", "properties": []}
        prefix = _showcase_prefix(name, prefixes)
        m = meta.get(name, {"category": "未分类", "title": "", "fields": {}})
        ctxs.append({"name": name, "entry": entry, "ai": ai, "meta": m,
                     "audit": audit.get(name, {}), "prefix": prefix,
                     "version": version, "fingerprint": fingerprint, "total": total,
                     "shellCount": len(fq_names)})
    cat_order = list(dict.fromkeys(m["category"] for m in meta.values()))
    ctxs.sort(key=lambda x: (cat_order.index(x["meta"]["category"])
                             if x["meta"]["category"] in cat_order else 999, x["name"]))
    rows = [{
        "name": c["name"], "category": c["meta"]["category"], "title": c["meta"]["title"],
        "props": sum(1 for x in c["entry"]["props"] if not x.endswith(":alias")),
        "slots": sum(1 for x in c["entry"]["props"] if x.endswith(":alias")),
        "signals": len(c["entry"]["signals"]), "prefix": c["prefix"],
    } for c in ctxs]
    return {"ctxs": ctxs, "rows": rows, "version": version,
            "fingerprint": fingerprint, "total": total,
            "shellCount": len(fq_names)}


def build_component_pages(project: Path) -> dict:
    """从冻结事实源生成 docs/components/ 下的逐组件 API 页 + 总览 + 装配图索引。"""
    c = _collect_components(project)
    out_dir = project / "docs" / "components"
    out_dir.mkdir(parents=True, exist_ok=True)
    for ctx in c["ctxs"]:
        (out_dir / f"{ctx['name']}.md").write_text(
            _render_component_page(ctx), encoding="utf-8")
    (out_dir / "index.md").write_text(
        _render_index(c["rows"], c["version"], c["fingerprint"], c["total"],
                      c["shellCount"]),
        encoding="utf-8")
    (out_dir / "showcase.md").write_text(
        _render_showcase(c["rows"], c["version"], c["shellCount"]), encoding="utf-8")
    rows = c["rows"]
    return {"count": len(rows),
            "with_showcase": sum(1 for r in rows if r["prefix"]),
            "categories": len({r["category"] for r in rows})}


# ---------------------------------------------------------------------------
# T9 / P1 + P2 · 文档站产品化层
#   版本切换器数据 / 在线可调参 Playground / 站点中英 i18n / Layout Builder /
#   社区入口 / 在线示例浏览器 —— 全部只消费冻结事实源，不新增任何公共 QML API。
#   产物（一律为生成物，禁止手工编辑；重跑本生成器即完成同步）：
#     docs/assets/js/nova-data.js
#     docs/tools/{playground,layout-builder,examples}.md
#     docs/community/{index,contributing,code-of-conduct,security,sponsors,blog}.md
#     docs/en/{index,components,playground,layout-builder,community}.md
#   静态交互逻辑与样式见 docs/assets/{js,css}/ 下手写资产（非生成物）。
# ---------------------------------------------------------------------------
REPO_URL = "https://github.com/eagleye-china/pyside-nova"
PYPI_URL = "https://pypi.org/project/pyside-nova/"
GEN_BANNER = (
    "> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；"
    "重跑生成器即可同步。\n"
)


def _prop_kind(t: str) -> str:
    if t == "bool":
        return "bool"
    if t in ("int", "real", "double"):
        return "number"
    if t == "string":
        return "string"
    if t == "color":
        return "color"
    return "other"


def _site_components(c: dict) -> list[dict]:
    """冻结面 → Playground / Builder 的逐组件参数模型（真实属性名与默认值）。"""
    out = []
    for ctx in c["ctxs"]:
        entry, ai = ctx["entry"], ctx["ai"]
        defaults = {p["name"]: p["default"] for p in ai.get("properties", [])}
        props, slots = [], []
        for raw in entry["props"]:
            ro = raw.startswith("ro ")
            n, t = _split_signature(raw[3:] if ro else raw)
            if t == "alias":
                slots.append(n)
                continue
            d = _clean_default(defaults.get(n))
            props.append({
                "name": n, "type": t, "default": None if d == "—" else d,
                "readonly": ro, "kind": _prop_kind(t),
            })
        signals = [_split_signature(x)[0] for x in entry["signals"]]
        out.append({
            "name": ctx["name"], "category": ctx["meta"]["category"],
            "title": ctx["meta"]["title"],
            "description": (ai.get("description") or "").strip(),
            "prefix": ctx["prefix"], "props": props, "slots": slots,
            "signals": signals,
            "file": entry.get("file", ""),
        })
    return out


def _write(project: Path, rel: str, text: str) -> None:
    p = project / "docs" / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text, encoding="utf-8")


def _render_tool_page(title: str, tool: str, intro: str, related: list[str]) -> str:
    parts = [f"# {title}", "", GEN_BANNER.rstrip(), "", intro, "",
             f'<div id="nova-{tool}" class="nova-tool" '
             f'data-nova-tool="{tool}"></div>', "",
             "## 相关", ""]
    parts += [f"- {x}" for x in related]
    parts.append("")
    return "\n".join(parts)


def _project_root_doc(project: Path, root_name: str, title: str, note: str) -> str:
    """仓库根治理文件 → 站点页投影（相对链接按源/目标目录重表达，越界链接指向仓库 blob）。"""
    src = project / root_name
    text = src.read_text(encoding="utf-8")
    lines = text.splitlines()
    if lines and lines[0].startswith("# "):
        text = "\n".join(lines[1:]).lstrip("\n")
    text = rewrite_links(text, project, project / "docs" / "community")
    text = re.sub(r"\]\(\.\./\.\./([^)]+)\)",
                  lambda m: f"]({REPO_URL}/blob/main/{m.group(1)})", text)
    return (f"# {title}\n\n{GEN_BANNER.rstrip()}\n\n{note}\n\n"
            f"> 上游唯一事实源：仓库根 [`{root_name}`]({REPO_URL}/blob/main/{root_name})。\n\n"
            f"---\n\n{text}\n")


def build_site_experience(project: Path) -> dict:
    """生成 T9/P1+P2 的站点数据、工具页、社区页与英文页。"""
    c = _collect_components(project)
    version, fingerprint, total = c["version"], c["fingerprint"], c["total"]
    shell_count = c["shellCount"]
    shots = shell_count * 3
    comps = _site_components(c)
    gallery = sorted(p.name for p in
                     (project / "docs" / "assets" / "gallery").glob("page-*.png"))

    # ---- 1. 站点数据（版本切换器 / Playground / Builder / 示例浏览器共用） ----
    data = {
        "version": version,
        "fingerprint": fingerprint,
        "typesTotal": total,
        "repo": REPO_URL,
        "pypi": PYPI_URL,
        "versions": [
            {"label": f"{version} · 当前站点（GA）", "url": ""},
            {"label": f"{version} · PyPI 发布页", "url": f"{PYPI_URL}{version}/"},
            {"label": "main · 开发分支", "url": REPO_URL},
        ],
        "components": comps,
        "gallery": gallery,
    }
    js = ("/* 生成物：scripts/gen_apidocs.py 产出，禁止手工编辑。\n"
          "   事实源：__about__.py + api/nova-api-1.8.0.json + QML + 60 张三态图 */\n"
          "window.NOVA_SITE = " + json.dumps(data, indent=2, ensure_ascii=False) + ";\n")
    _write(project, "assets/js/nova-data.js", js)

    gen = GEN_BANNER.rstrip()

    # ---- 2. P1-③ 在线可调参 Playground ----
    _write(project, "tools/playground.md", _render_tool_page(
        "在线可调参 Playground", "playground",
        "把 20 个组合根容器的**真实公共 Props** 做成可交互参数面板："
        "选择容器、调整属性、切换浅色 / 深色 / 变体三态预览，右侧 QML 片段与属性表实时同步，"
        "一键复制即可粘进本地 Gallery 运行。\n\n"
        "> ⚠️ **能力边界（如实标注）**：预览图是 `audit_showcase.py` 用真实 Qt Quick 引擎渲染的"
        " 60 张三态装配图；参数改动实时反映在 **QML 代码与属性表**，但浏览器内不重新渲染 Qt 场景"
        "（需本地 Gallery 或 Qt for WebAssembly，后者属 P2 边界遗留）。"
        "属性名 / 类型 / 默认值全部取自 `api/nova-api-1.8.0.json` 冻结面，无臆造 props。",
        ["[20 项组合根容器总览](../components/index.md)",
         "[60 张三态装配图索引](../components/showcase.md)",
         "[Layout Builder](layout-builder.md)",
         "[在线示例浏览器](examples.md)",
         "[API 冻结清单](../API_FREEZE.md)"]))

    # ---- 3. P2-① Layout Builder ----
    _write(project, "tools/layout-builder.md", _render_tool_page(
        "Layout Builder · 可视化布局生成", "layout-builder",
        "选择 20 个组合根容器之一，勾选栏位开关与数值属性，"
        "左侧结构预览即时响应，右侧生成**可直接运行的 QML 骨架**并一键复制。"
        "内置 Desktop / Mobile / Chat 三个预设。\n\n"
        "> ⚠️ **能力边界（如实标注）**：本 Builder 是**单根容器 + 槽位配置**的静态生成器，"
        "不提供任意拖拽嵌套与浏览器内 Qt 渲染；生成代码使用冻结面真实属性名，"
        "槽位注入遵循 CC-6（`anchors.fill: parent`）。",
        ["[20 项组合根容器总览](../components/index.md)",
         "[在线可调参 Playground](playground.md)",
         "[在线示例浏览器](examples.md)",
         "[组合组件宪法](../COMPOSITION_CONSTITUTION.md)"]))

    # ---- 4. P2-③ 在线示例浏览器（静态产物版，WASM 如实标为边界遗留） ----
    _write(project, "tools/examples.md", _render_tool_page(
        "在线示例浏览器", "examples",
        "汇总 **24 页本地 Gallery 截图** + **60 张真实 Qt Quick 三态装配图**，"
        "按组件 / 主题筛选与放大查看，并附一键复制的本地运行命令。\n\n"
        "> ⚠️ **能力边界（如实标注）**：本页提供的是**可浏览的静态渲染产物**与可复制的运行命令；"
        "「浏览器内运行 Qt 场景」需 Qt for WebAssembly 构建产物与站点部署，"
        "**本轮未交付**（超出零产品代码边界，且部署归 CSA）。",
        ["[20 项组合根容器总览](../components/index.md)",
         "[60 张三态装配图索引](../components/showcase.md)",
         "[在线可调参 Playground](playground.md)",
         "[画廊预览](../GALLERY.md)"]))

    # ---- 5. P2-② 社区入口 ----
    _write(project, "community/index.md", "\n".join([
        "# 社区与贡献", "", gen, "",
        f"pyside-nova **{version} GA** 的社区入口。仓库、发布与议题讨论均在 GitHub，"
        "以下链接为真实地址（站点部署与正式域名归 CSA，本轮未上线）。", "",
        "## 官方入口", "",
        f"- [GitHub 仓库]({REPO_URL}) · [Issues]({REPO_URL}/issues) · "
        f"[Discussions]({REPO_URL}/discussions)",
        f"- [PyPI 发布页]({PYPI_URL})（`pip install pyside-nova=={version}`）",
        f"- [CHANGELOG]({REPO_URL}/blob/main/CHANGELOG.md) · "
        f"[架构宪法]({REPO_URL}/blob/main/docs/CONSTITUTION.md)", "",
        "## 参与", "",
        "- [贡献指南](contributing.md) · [行为准则](code-of-conduct.md) · "
        "[安全策略](security.md)",
        "- [赞助](sponsors.md) · [博客](blog.md) —— **入口预留，内容尚未设立，待 CSA 决策**", "",
        "## 文档站", "",
        "- [文档首页](../index.md) · [在线工具](../tools/playground.md) · "
        "[English](../en/index.md)", "",
    ]))
    for rel, root, title, note in [
        ("community/contributing.md", "CONTRIBUTING.md", "贡献指南",
         "社区贡献流程的站点投影；以上游仓库根文件为唯一事实源。"),
        ("community/code-of-conduct.md", "CODE_OF_CONDUCT.md", "行为准则",
         "社区行为准则的站点投影；以上游仓库根文件为唯一事实源。"),
        ("community/security.md", "SECURITY.md", "安全策略",
         "漏洞报告与安全响应流程的站点投影；以上游仓库根文件为唯一事实源。"),
    ]:
        _write(project, rel, _project_root_doc(project, root, title, note))
    for rel, title, body in [
        ("community/sponsors.md", "赞助", "赞助计划**尚未设立**。本页为站点导航入口占位，待 CSA 决策后填充真实信息；当前不编造任何赞助渠道或链接。"),
        ("community/blog.md", "博客", "官方博客**尚未设立**。本页为站点导航入口占位，待 CSA 决策后填充真实文章；当前不编造任何文章内容。"),
    ]:
        _write(project, rel, "\n".join([
            f"# {title}", "", gen, "", body, "",
            "## 相关", "", "- [社区与贡献](index.md)",
            f"- [GitHub Discussions]({REPO_URL}/discussions)", "",
        ]))

    # ---- 6. P1-④ 站点 i18n（英文骨架 + Material 官方语言切换器） ----
    _write(project, "en/index.md", "\n".join([
        "# pyside-nova Documentation", "", gen, "",
        f"**English coverage:** 5 pages (home, components, playground, layout builder, "
        f"community). The remaining documentation is currently available in Chinese only; "
        f"use the language switcher in the header to return to the Chinese site.", "",
        f"pyside-nova **{version} GA** is an enterprise PySide6 / QML component library "
        f"with **{total} exported types**, including **{shell_count} composite root containers** "
        f"({shell_count}/{shell_count} CARF ceiling sign-off). Public API fingerprint `{fingerprint}` is frozen.", "",
        "## Quick start", "", "```bash", f"pip install pyside-nova=={version}",
        "python examples/gallery_launch.py   # 24-page local component gallery", "```", "",
        "```qml", "import QtQuick", "import Nova.Composite.LayoutShell", "",
        "NovaDesktop {", "    anchors.fill: parent", "}", "```", "",
        "## Explore", "",
        f"- [{shell_count} composite root containers](components.md) (full per-component API pages are in Chinese)",
        "- [Online playground](playground.md) · [Layout Builder](layout-builder.md)",
        "- [Community](community.md) · [Chinese documentation home](../index.md)",
        f"- [GitHub]({REPO_URL}) · [PyPI]({PYPI_URL})", "",
    ]))
    _write(project, "en/components.md", "\n".join([
        f"# Composite Root Containers ({shell_count})", "", gen, "",
        f"All {shell_count} containers are shipped in `{COMPOSITE_MODULE}` and have passed the "
        f"six-dimension CARF ceiling audit ({shell_count}/{shell_count}). Full Props / Slots / Events tables "
        "are available on the Chinese per-component pages linked below.", "",
        "| Category | Containers |", "|---|---|",
    ] + [
        f"| {cat} | " + " · ".join(
            f"[{x['name']}](../components/{x['name']}.md)" for x in comps
            if x["category"] == cat) + " |"
        for cat in dict.fromkeys(x["category"] for x in comps)
    ] + ["", "## See also", "", "- [Chinese overview](../components/index.md)",
         f"- [{shots} three-state screenshots](../components/showcase.md)",
         "- [CARF-R audit ledger](../prescript/AUDIT_CEILING.md)", "",
         "- [Back to English home](index.md)", ""]))
    _write(project, "en/playground.md", "\n".join([
        "# Online Playground", "", gen, "",
        f"The interactive playground renders the **real public Props** of all {shell_count} composite "
        "root containers with live QML code generation and three-state previews "
        "(light / dark / variant). Data comes from the frozen API surface; no invented props.", "",
        "- [Open the playground](../tools/playground.md)",
        "- [Layout Builder](layout-builder.md)",
        "- [Back to English home](index.md)", "",
    ]))
    _write(project, "en/layout-builder.md", "\n".join([
        "# Layout Builder", "", gen, "",
        "A static QML skeleton generator: pick one of the 20 root containers, toggle its "
        "chrome and numeric properties, preview the structure, and copy runnable QML.", "",
        "- [Open the builder](../tools/layout-builder.md)",
        "- [Examples browser](../tools/examples.md)",
        "- [Back to English home](index.md)", "",
    ]))
    _write(project, "en/community.md", "\n".join([
        "# Community", "", gen, "",
        f"- [GitHub repository]({REPO_URL}) · [Issues]({REPO_URL}/issues)",
        f"- [PyPI]({PYPI_URL})",
        "- [Contributing guide](../community/contributing.md) (Chinese)",
        "- [Community home](../community/index.md) (Chinese)", "",
        "Sponsorship and blog entries are reserved but not yet established.", "",
        "- [Back to English home](index.md)", "",
    ]))

    return {"version": version, "components": len(comps),
            "gallery": len(gallery), "pages": 3 + 6 + 5,
            "screenshots": sum(1 for x in comps if x["prefix"]) * 3}


def main() -> int:
    ap = argparse.ArgumentParser(
        description="生成 Nova AI-ready 文档包 + 逐组件 API 页 + 文档站产品化层")
    ap.add_argument("--project", type=Path, default=PROJECT)
    args = ap.parse_args()
    index = build(args.project)
    pages = build_component_pages(args.project)
    site = build_site_experience(args.project)
    print(f"AI-ready 包：{index['types_total']} 类型 API + {len(index['pages'])} 页文档"
          f"（指纹 {index['fingerprint']}）→ docs/ai/")
    print(f"逐组件文档页：{pages['count']} 页（{pages['categories']} 类 · 三态图 "
          f"{pages['with_showcase']}/{pages['count']} 项齐全）"
          " + index.md + showcase.md → docs/components/")
    print(f"站点产品化层：{site['pages']} 页 + nova-data.js（{site['components']} 组件 · "
          f"{site['gallery']} 张 Gallery 图 · {site['screenshots']} 张三态图引用）")
    return 0


if __name__ == "__main__":
    sys.exit(main())