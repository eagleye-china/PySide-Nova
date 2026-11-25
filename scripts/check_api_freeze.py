#!/usr/bin/env python3
# scripts/check_api_freeze.py
# API 冻结门禁（六期 RC1）：现网导出面 vs 冻结清单逐成员比对 + 命名红线/头注释/qmldir 纪律体检
# 红即阻断交付：破坏性变更必须升 major，增量必须升 minor 并重签清单
"""Nova API 冻结门禁。

三道检查（任一失败退出码 1）：

1. **冻结面比对**：现网 qmldir + QML 源重建签名面，与 `api/nova-api-<v>.json` 逐类型比对。
   破坏性（删类型/改签名/移模块/改 a11y）× 与 增量（新类型/新成员）分别报告——
   两者都必须重签清单，只是版本动作不同。
2. **命名红线**（宪法第 2 章 + 坑位 1/2/25）：禁 `on*` 前缀属性、禁 `color` 撞名、
   禁 `palette`/`show`/`hide` 撞内建成员；禁 `Component.onDestroyed`（坑位 33）。
3. **清单纪律**：qmldir 只用 `#` 注释、导出版本恒为 `1.0`、文件存在、根类型同名、
   头注释两行规范、跨模块无重名。

用法::

    python scripts/check_api_freeze.py            # 校验（CI / 交付前）
    python scripts/check_api_freeze.py --quiet    # 只输出结论行
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

import gen_api_freeze as freeze  # noqa: E402  同一口径的收集器

PROJECT = freeze.PROJECT
QML_ROOT = freeze.QML_ROOT

# 命名红线（坑位 1：`on*` 前缀让整模块加载失败；坑位 2/25：与基类内建成员撞名）
# 撞名判定按「根类型是否真有该成员」——`color` 只在 Rectangle/Text 系是内建成员，
# 根类型为 Item 时声明 `property color color` 合法（NovaRipple / NovaIcon 即此形态）。
ON_PREFIX_RE = re.compile(r"^on[A-Z]")
BASE_MEMBER_CONFLICT = {
    "color": {"Rectangle", "Text", "TextEdit", "TextInput", "BorderImage"},
    "palette": {"Control", "Popup", "Menu", "Dialog"},
    "show": {"Popup", "Menu", "Dialog", "Window", "ApplicationWindow"},
    "hide": {"Popup", "Menu", "Dialog", "Window", "ApplicationWindow"},
}
# qmldir 的非导出行前缀（`internal` 行是私有类型，不受 1.0 版本约束）
QMLDIR_SKIP = ("#", "module", "internal", "depends", "pragma", "plugin", "classname",
               "typeinfo", "designersupported", "prefer", "optional")

ROOT_TYPE_RE = re.compile(r"^([A-Z][A-Za-z0-9_.]*)\s*\{", re.MULTILINE)


class Report:
    def __init__(self, quiet: bool = False) -> None:
        self.quiet = quiet
        self.breaking: list[str] = []
        self.additive: list[str] = []
        self.hygiene: list[str] = []
        self.notes: list[str] = []

    def bad(self, bucket: list[str], msg: str) -> None:
        bucket.append(msg)
        if not self.quiet:
            print(f"  ✗ {msg}")

    def ok(self, msg: str) -> None:
        if not self.quiet:
            print(f"  ✓ {msg}")

    @property
    def failed(self) -> bool:
        return bool(self.breaking or self.additive or self.hygiene)


# ── 1. 冻结面比对 ────────────────────────────────────────────────────
def load_manifest(man_path: Path) -> dict:
    if not man_path.exists():
        raise SystemExit(f"缺少冻结清单：{man_path}\n先跑 python scripts/gen_api_freeze.py")
    return json.loads(man_path.read_text(encoding="utf-8"))


def diff_surface(frozen: dict, current: dict, rep: Report) -> None:
    f_types, c_types = frozen["types"], current["types"]

    for name in sorted(set(f_types) - set(c_types)):
        rep.bad(rep.breaking, f"类型被删除或取消导出：{name}")
    for name in sorted(set(c_types) - set(f_types)):
        rep.bad(rep.additive, f"新增导出类型：{name}（须升 minor 并重签清单）")

    for name in sorted(set(f_types) & set(c_types)):
        f, c = f_types[name], c_types[name]
        for field, label in (("module", "模块"), ("kind", "形态"), ("a11y", "a11y 分类")):
            if f[field] != c[field]:
                rep.bad(rep.breaking, f"{name} 的{label}变更：{f[field]} → {c[field]}")
        for group, label in (("props", "属性"), ("signals", "信号"), ("methods", "方法")):
            f_set, c_set = set(f[group]), set(c[group])
            # 签名比较用「名字」做键：同名不同类型 = 破坏性
            f_by_name = {_sig_name(s): s for s in f_set}
            c_by_name = {_sig_name(s): s for s in c_set}
            for key in sorted(set(f_by_name) - set(c_by_name)):
                rep.bad(rep.breaking, f"{name} 删除{label}：{f_by_name[key]}")
            for key in sorted(set(c_by_name) - set(f_by_name)):
                rep.bad(rep.additive, f"{name} 新增{label}：{c_by_name[key]}（须升 minor）")
            for key in sorted(set(f_by_name) & set(c_by_name)):
                if f_by_name[key] != c_by_name[key]:
                    rep.bad(rep.breaking,
                            f"{name} 的{label}签名变更：{f_by_name[key]} → {c_by_name[key]}")

    if not (rep.breaking or rep.additive):
        rep.ok(f"冻结面零漂移（{len(c_types)} 类型逐成员一致）")


def _sig_name(sig: str) -> str:
    """从签名串取名字：`ro text:string` → `text`；`clicked(var)` → `clicked`。"""
    s = sig[3:] if sig.startswith("ro ") else sig
    return s.split(":", 1)[0].split("(", 1)[0]


# ── 2. 命名红线 + 3. 清单纪律 ────────────────────────────────────────
def check_hygiene(current: dict, rep: Report, root: Path | None = None) -> None:
    """root 可指向临时目录（测试注入反例用）；qmldir 纪律恒扫真实仓库。"""
    qml_base = (root or PROJECT) / "src" / "pyside_nova" / "qml"
    seen: dict[str, str] = {}
    for full, info in current["types"].items():
        name = full.rsplit(".", 1)[1]   # 模块名可能带点（Nova.Behaviors.X）
        if name in seen and seen[name] != info["module"]:
            rep.bad(rep.hygiene, f"跨模块重名：{name} 同时存在于 {seen[name]} 与 {info['module']}")
        seen[name] = info["module"]

        path = qml_base / info["file"]
        if not path.exists():
            rep.bad(rep.hygiene, f"{full} 的源文件不存在：{info['file']}")
            continue
        lines = path.read_text(encoding="utf-8").splitlines()

        # 头注释两行规范：第 1 行 src/ 路径，第 2 行文档素材说明
        if not lines or not lines[0].startswith("// src/pyside_nova/qml/"):
            rep.bad(rep.hygiene, f"{full} 头注释第 1 行须为 `// src/…` 子路径")
        if len(lines) < 2 or not lines[1].startswith("// "):
            rep.bad(rep.hygiene, f"{full} 头注释第 2 行须为文档素材说明")

        text = "\n".join(lines)
        if "Component.onDestroyed" in text:
            rep.bad(rep.hygiene, f"{full} 使用了不存在的 `Component.onDestroyed`（坑位 33，应为 onDestruction）")

        # 文件名必须与导出类型同名（qmldir 按文件名解析，不同名 = 阅读与工具链双重混淆）
        if Path(info["file"]).stem != name:
            rep.bad(rep.hygiene, f"{full} 的文件名与类型名不一致：{Path(info['file']).name}")

        # 单例须 pragma Singleton（否则被当普通组件，属性声明式绑定失效）
        if info["kind"] == "singleton" and "pragma Singleton" not in text:
            rep.bad(rep.hygiene, f"{full} 为单例但缺少 `pragma Singleton`")

        root = _root_type(text)
        for sig in info["props"]:
            pname = _sig_name(sig)
            if ON_PREFIX_RE.match(pname):
                rep.bad(rep.hygiene, f"{full}.{pname} 使用 `on*` 前缀（坑位 1：整模块加载失败）")
            conflict = BASE_MEMBER_CONFLICT.get(pname)
            if conflict and root in conflict:
                rep.bad(rep.hygiene,
                        f"{full}.{pname} 与基类 `{root}` 的内建成员撞名（坑位 2/25；基调色用 tint）")

    # qmldir 纪律：只用 `#` 注释 + 导出（非 internal）版本恒为 1.0
    for layer in freeze.LAYERS:
        qmldir = QML_ROOT / layer / "qmldir"
        for i, raw in enumerate(qmldir.read_text(encoding="utf-8").splitlines(), 1):
            line = raw.strip()
            if not line:
                continue
            if "//" in line:
                rep.bad(rep.hygiene, f"{layer}/qmldir:{i} 使用 `//` 注释（qmldir 只认 `#`，坑位 4）")
            if line.startswith(QMLDIR_SKIP):
                continue
            parts = line.split()
            offset = 1 if parts[0] == "singleton" else 0   # singleton <名> <版本> <文件>
            if len(parts) >= offset + 3 and parts[offset + 1] != "1.0":
                rep.bad(rep.hygiene,
                        f"{layer}/qmldir:{i} 导出版本为 {parts[offset + 1]}，冻结面恒为 1.0"
                        f"（{parts[offset]}）")

    if not rep.hygiene:
        rep.ok(f"命名红线与清单纪律扫描通过（{len(current['types'])} 类型 / {len(freeze.LAYERS)} qmldir）")


def _root_type(text: str) -> str:
    for m in ROOT_TYPE_RE.finditer(text):
        if m.group(1) != "Component":
            return m.group(1)
    return ""


# ── 主流程 ───────────────────────────────────────────────────────────
def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Nova API 冻结门禁")
    ap.add_argument("--quiet", action="store_true", help="只输出结论行")
    args = ap.parse_args(argv)

    rep = Report(args.quiet)
    man_path = freeze.manifest_path(freeze._about()[1])
    frozen = load_manifest(man_path)
    current = freeze.collect()

    if not args.quiet:
        print(f"API 冻结门禁 · {man_path.name}（指纹 {frozen['fingerprint']}）")

    # 清单自身完整性：指纹必须与内容一致（防手改清单绕过门禁）
    actual_fp = freeze.fingerprint({"modules": frozen["modules"], "types": frozen["types"]})
    if actual_fp != frozen["fingerprint"]:
        rep.bad(rep.breaking, f"冻结清单指纹不符（清单被手改？）：记录 {frozen['fingerprint']} ≠ 实算 {actual_fp}")
    else:
        rep.ok(f"清单指纹自洽：{actual_fp}")

    diff_surface(frozen, current, rep)
    cur_fp = freeze.fingerprint(current)
    if cur_fp != frozen["fingerprint"] and not (rep.breaking or rep.additive):
        rep.bad(rep.breaking, f"冻结面内容漂移但未被逐成员比对捕获：{frozen['fingerprint']} → {cur_fp}")

    check_hygiene(current, rep)

    total = current and len(current["types"]) or 0
    if rep.failed:
        if not args.quiet:
            print()
            print(f"✗ API 冻结门禁未通过：破坏性 {len(rep.breaking)} · 增量 {len(rep.additive)} "
                  f"· 纪律 {len(rep.hygiene)}")
            print("  破坏性 → 须升 major（2.0）；增量 → 须升 minor + 重签清单；"
                  "纪律 → 直接修源码")
        return 1
    print(f"✓ API 冻结门禁通过：{total} 类型零漂移 · 命名红线 0 违规 · 清单指纹 {frozen['fingerprint']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
