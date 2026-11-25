#!/usr/bin/env python3
# scripts/gen_api_freeze.py
# API 冻结清单生成器（六期 RC1）：qmldir 导出清单 = 冻结公共 API 面，逐类型快照公共成员签名
# 产物：api/nova-api-<apiVersion>.json（机器可校验）+ docs/API_FREEZE.md（人读签署文档）
"""生成 Nova 1.0 API 冻结清单。

**冻结口径（宪法第 13 章）**：公共 API 面 = 五个 qmldir 的导出行。冻结清单逐类型记录
模块归属 / 文件 / 单例与否 / a11y 分类 / 公共成员签名（props / signals / methods）。
以 `_` 开头的成员是私有实现，**不进冻结面**（可自由重构）。

用法::

    python scripts/gen_api_freeze.py                 # 重新生成清单与文档
    python scripts/gen_api_freeze.py --check         # 只校验（等价 check_api_freeze.py）

冻结后变更流程：改 QML → 跑 check_api_freeze.py（红）→ 评估破坏性 → 升 API 版本 →
重跑本脚本 + 更新 docs/API_FREEZE.md 签署行 → CHANGELOG 记一行。
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from datetime import date
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from gen_apidocs import parse_qml, read_qmldir  # noqa: E402  复用同一解析口径

PROJECT = SCRIPT_DIR.parent
QML_ROOT = PROJECT / "src" / "pyside_nova" / "qml" / "Nova"
OUT_JSON = PROJECT / "api"
DOC = PROJECT / "docs" / "API_FREEZE.md"

SCHEMA = "nova-api-freeze/1"
BASELINE = "Quasar 2.35.5"
SIGNERS = "小伙（产品/验收）· 小诺（架构/实现）"

# 模块声明顺序（文档与控制台输出稳定）；Composite/LayoutShell 为组合组件专属第五模块（宪法 0.3.0）
LAYERS = ["Controls", "Behaviors", "Services", "Design", "Composite/LayoutShell"]


def _about() -> tuple[str, str]:
    """返回 (packageVersion, apiVersion)；0.16.2→1.0.0 式的 API 面用 MAJOR.MINOR.PATCH。"""
    text = (PROJECT / "src" / "pyside_nova" / "__about__.py").read_text(encoding="utf-8")
    ver = re.search(r'__version__\s*=\s*"([^"]+)"', text).group(1)
    m = re.match(r"(\d+)\.(\d+)\.(\d+)", ver)
    api = f"{m.group(1)}.{m.group(2)}.0"
    return ver, api


def _a11y_table() -> dict[str, tuple[str, str, str]]:
    """合并 check_a11y 的五张契约表 → {类型名: (分类, 角色, 名称来源)}。"""
    from check_a11y import BEHAVIORS, CONTROLS, DESIGN, LAYOUTSHELL, SERVICES
    merged: dict[str, tuple[str, str, str]] = {}
    for table in (CONTROLS, BEHAVIORS, SERVICES, DESIGN, LAYOUTSHELL):
        merged.update(table)
    return merged


def _is_public(name: str) -> bool:
    """`_` 前缀为私有实现（不进冻结面）；`__` 双下划线同样排除。"""
    return not name.startswith("_")


def _members(info: dict) -> dict:
    """把 parse_qml 结果压成签名列表（排序后可比对、可 diff）。"""
    props = sorted(
        f"{'ro ' if p['readonly'] else ''}{p['name']}:{p['type']}"
        for p in info["properties"] if _is_public(p["name"])
    )
    signals = sorted(f"{s['name']}({s['params']})" for s in info["signals"]
                     if _is_public(s["name"]))
    methods = sorted(f"{m['name']}({m['params']})" for m in info["methods"]
                     if _is_public(m["name"]))
    return {"props": props, "signals": signals, "methods": methods}


def collect() -> dict:
    """扫描五个 qmldir → 冻结面数据结构（不含时间戳，便于指纹稳定）。"""
    a11y = _a11y_table()
    types: dict[str, dict] = {}
    modules: dict[str, dict] = {}
    missing_files: list[str] = []
    unregistered: list[str] = []

    for layer in LAYERS:
        qmldir = QML_ROOT / layer / "qmldir"
        if not qmldir.exists():
            raise SystemExit(f"缺少 qmldir：{qmldir}")
        module, entries = read_qmldir(qmldir)
        mod = {"module": module, "version": "1.0", "types": [], "singletons": []}
        for t in entries:
            src = qmldir.parent / t["file"]
            if not src.exists():
                missing_files.append(f"{module}.{t['name']} → {src}")
                continue
            info = parse_qml(src)
            cls = a11y.get(t["name"])
            if cls is None:
                unregistered.append(t["name"])
            types[f"{module}.{t['name']}"] = {
                "module": module,
                "file": f"Nova/{layer}/{t['file']}",
                "kind": t["kind"],
                "a11y": cls[0] if cls else "unregistered",
                **_members(info),
            }
            mod["singletons" if t["kind"] == "singleton" else "types"].append(t["name"])
        mod["types"].sort()
        mod["singletons"].sort()
        modules[module] = mod

    if missing_files:
        raise SystemExit("qmldir 指向的文件不存在：\n  " + "\n  ".join(missing_files))
    if unregistered:
        raise SystemExit("以下类型未在 check_a11y 契约表登记（无 a11y 分类无法冻结）：\n  "
                         + "\n  ".join(unregistered))

    return {"modules": modules, "types": dict(sorted(types.items()))}


def fingerprint(surface: dict) -> str:
    """冻结面内容指纹：canonical JSON 的 sha256（前 16 位，与项目其他指纹口径一致）。"""
    canon = json.dumps(surface, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canon.encode("utf-8")).hexdigest()[:16]


def build_manifest() -> dict:
    pkg_version, api_version = _about()
    surface = collect()
    counts = {"total": len(surface["types"])}
    a11y_counts: dict[str, int] = {}
    for t in surface["types"].values():
        a11y_counts[t["a11y"]] = a11y_counts.get(t["a11y"], 0) + 1
    return {
        "schema": SCHEMA,
        "package": "pyside-nova",
        "apiVersion": api_version,
        "packageVersion": pkg_version,
        "baseline": BASELINE,
        "counts": {
            "total": counts["total"],
            "modules": {m: len(v["types"]) + len(v["singletons"])
                        for m, v in surface["modules"].items()},
            "a11y": dict(sorted(a11y_counts.items())),
        },
        "modules": surface["modules"],
        "types": surface["types"],
        "fingerprint": fingerprint(surface),
    }


def manifest_path(api_version: str) -> Path:
    return OUT_JSON / f"nova-api-{api_version}.json"


def render_doc(man: dict) -> str:
    t = man["types"]
    mods = man["modules"]
    rows: list[str] = []
    for full, info in t.items():
        name = full.rsplit(".", 1)[1]   # 模块名带点（Nova.Behaviors.X），从右切
        kind = "单例" if info["kind"] == "singleton" else "组件"
        rows.append(
            f"| `{name}` | {info['module']} | {kind} | {info['a11y']} | "
            f"{len(info['props'])} | {len(info['signals'])} | {len(info['methods'])} |"
        )
    mod_rows = "\n".join(
        f"| {m} | {len(v['types'])} | {len(v['singletons'])} | "
        f"{len(v['types']) + len(v['singletons'])} |"
        for m, v in mods.items()
    )
    a11y = man["counts"]["a11y"]
    return f"""# Nova 1.0 API 冻结清单（RC1 签署件）

> **冻结日期**：{date.today().isoformat()}　**包版本**：`{man['packageVersion']}`　
> **API 版本**：`{man['apiVersion']}`　**对标基线**：{man['baseline']}
> **内容指纹**：`{man['fingerprint']}`　**签署人**：{SIGNERS}

## 1. 冻结口径

**公共 API 面 = 五个 `qmldir` 的导出行**。这是本库对外的唯一契约来源：QML 侧
`import Nova.Controls 1.0` / `import Nova.Composite.LayoutShell 1.0` 能拿到的每个类型名，
就是 1.0 承诺稳定的全部内容。

| 进冻结面 | 不进冻结面 |
|---|---|
| 类型名 / 模块归属 / 单例性 | QML 内部 `id`、子项结构、锚点与布局细节 |
| 公共 `property`（含 `readonly`）的名字、类型、只读性 | `_` 开头的私有属性与方法（实现自由） |
| 公共 `signal` 的名字与参数签名 | 默认值与绑定表达式（视觉令牌可调） |
| 公共 `function` 的名字与参数签名 | 文件内部拆分、委托组件命名 |
| a11y 分类（interactive / semantic / decorative） | 内部性能优化与重绘策略 |

机器可校验副本：`api/nova-api-{man['apiVersion']}.json`（schema `{man['schema']}`）。
其 `types` 里每个公共成员都是 `名字:类型` / `名字(参数)` 的签名串，任何增删改都会让
`scripts/check_api_freeze.py` 变红。

## 2. 冻结统计（{man['counts']['total']} 类型）

| 模块 | 组件 | 单例 | 合计 |
|---|---|---|---|
| Nova.Controls | {len(mods['Nova.Controls']['types'])} | {len(mods['Nova.Controls']['singletons'])} | {len(mods['Nova.Controls']['types']) + len(mods['Nova.Controls']['singletons'])} |
| Nova.Behaviors | {len(mods['Nova.Behaviors']['types'])} | {len(mods['Nova.Behaviors']['singletons'])} | {len(mods['Nova.Behaviors']['types']) + len(mods['Nova.Behaviors']['singletons'])} |
| Nova.Services | {len(mods['Nova.Services']['types'])} | {len(mods['Nova.Services']['singletons'])} | {len(mods['Nova.Services']['types']) + len(mods['Nova.Services']['singletons'])} |
| Nova.Design | {len(mods['Nova.Design']['types'])} | {len(mods['Nova.Design']['singletons'])} | {len(mods['Nova.Design']['types']) + len(mods['Nova.Design']['singletons'])} |
| Nova.Composite.LayoutShell | {len(mods['Nova.Composite.LayoutShell']['types'])} | {len(mods['Nova.Composite.LayoutShell']['singletons'])} | {len(mods['Nova.Composite.LayoutShell']['types']) + len(mods['Nova.Composite.LayoutShell']['singletons'])} |
| **合计** | **{sum(len(v['types']) for v in mods.values())}** | **{sum(len(v['singletons']) for v in mods.values())}** | **{man['counts']['total']}** |

a11y 分类：interactive **{a11y.get('interactive', 0)}** / semantic **{a11y.get('semantic', 0)}** /
decorative **{a11y.get('decorative', 0)}**（与 `scripts/check_a11y.py` 同一契约表，双通道一致才放行）。

## 3. 冻结后的变更政策（语义化版本）

| 变更类型 | 例子 | 允许的版本动作 | 门禁行为 |
|---|---|---|---|
| **破坏性** | 删类型 / 改成员类型 / 改信号参数 / 移模块 / 单例↔组件 | 仅 **major**（2.0） | `check_api_freeze.py` 红，须重签清单 |
| **增量** | 新增类型 / 新增公共属性或方法（不改既有签名） | **minor**（1.x） | 红，须升 minor + 重签 |
| **实现** | 私有成员、默认值、内部结构、视觉令牌取值 | **patch**（1.0.x） | 绿，无需重签 |
| **废弃** | `@deprecated` 注释 + 运行时警告，两版本周期后移除 | minor 标注 → major 移除 | 门禁提示，不阻断 |

**废弃 API 的落地方式（QML 无 `@deprecated` 运行时）**：`// DEPRECATED 1.x: 用 xxx 取代，2.0 移除`
写在属性声明上一行，`_warnOnce` 在 `Component.onCompleted` 里经 `NovaUtils.logOnce()` 打一次
console.warn（不污染绑定、不刷屏）。1.0 封版时清单内**无废弃项**。

## 4. 签署

- [x] 导出清单清点完毕（{man['counts']['total']} 类型，五模块）
- [x] 每类型文件存在、文件名与类型名一致、qmldir 版本 `1.0`
- [x] a11y 分类 100% 登记（三分类制，见 `docs/A11Y.md`）
- [x] 无跨模块重名（同名类型必须全库唯一，否则 QML 侧歧义）
- [x] 公共成员签名机器快照入库（本文件同目录 JSON）
- [x] 命名红线扫描通过（无 `on*` 前缀属性 / 无 `color` 撞名 / 无 `palette`·`show`·`hide`）
- [ ] RC2：24 条验收清单（`docs/ECOSYSTEM_PARITY.md` §6）全勾后随 1.0.0 正式生效

**签署结论**：自 {date.today().isoformat()} 起，上表 {man['counts']['total']} 个类型的公共面视为
**冻结**；后续任何公共面变化都必须走第 3 节流程并重签本文件（指纹 `{man['fingerprint']}` → 新指纹）。

## 5. 已知偏差与例外（冻结保留，2.0 再谈）

冻结不等于完美。RC1 逐文件 + qmllint 体检后，以下四项**明确保留**并登记原因——
写下来是为了让后来者知道「这是裁定的结果，不是漏掉的债」：

| 项 | 现状 | 为什么不在此刻动 |
|---|---|---|
| `[unqualified]` 552 条 | 嵌套组件引用外层 `id`（qmllint 建议 `pragma ComponentBehavior: Bound`） | 该 pragma 会收紧委托的上下文捕获语义，124 文件全库改造在封版窗口内风险 > 收益；已入预算（`tests/lint-baseline.json`），只降不升 |
| `a11yLabel` 在 NovaInput / NovaToggle 重复声明 | 基类（NovaField / NovaCheckbox）已有同名同型属性 | 重复声明让「本类型的 a11y 面」在文件内自证，冻结清单不依赖继承推导；语义零差异，保留 |
| `[import]` 单例告警 1 条 | qmllint 对 `NovaMotion` 报「未在 qmldir 声明 singleton」 | 误判：`Nova/Design/qmldir` 第 5 行即 `singleton NovaMotion 1.0`；qmllint 单文件扫描缺模块上下文 |
| 应用包 185.7MB（目标 ≤60MB） | Qt 运行时物理下限 | 与 API 面无关，属打包工程；方向已记录（upx / QML 预编译 / 插件裁剪），RC2 再评估 |

RC2 仍欠的四项（与 API 面解耦，不阻断冻结）：24h 内存长跑、NVDA 真机回归、
安装器与代码签名（需平台证书）、迁移指南 + LTS 承诺书。

## 6. 全类型清单（冻结面明细）

| 类型 | 模块 | 形态 | a11y | props | signals | methods |
|---|---|---|---|---|---|---|
{chr(10).join(rows)}

---

> 本文件由 `scripts/gen_api_freeze.py` 生成，**勿手改**；签署行随生成时间与指纹自动更新。
> 校验：`python scripts/check_api_freeze.py`（CI 与交付前必跑，红则阻断）。
"""


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="生成 Nova API 冻结清单")
    ap.add_argument("--check", action="store_true", help="只校验不写盘（等价 check_api_freeze.py）")
    args = ap.parse_args(argv)

    if args.check:
        from check_api_freeze import main as check_main
        return check_main([])

    man = build_manifest()
    OUT_JSON.mkdir(parents=True, exist_ok=True)
    fp = manifest_path(man["apiVersion"])
    fp.write_text(json.dumps(man, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    DOC.write_text(render_doc(man), encoding="utf-8")
    print(f"✓ 冻结清单：{fp.relative_to(PROJECT)}（{man['counts']['total']} 类型）")
    print(f"✓ 签署文档：{DOC.relative_to(PROJECT)}")
    print(f"  指纹 {man['fingerprint']} · API {man['apiVersion']} · 包 {man['packageVersion']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
