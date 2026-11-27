# scripts/gen_component_list.py
# 星期二 2026-11-24 11:46
"""生成 docs/COMPONENT_LIST.md —— 公共 QML 类型完整编号清单。

数据源（只读，禁止手改产物）：
- api/nova-api-1.4.0.json  权威类型清单 + 模块/文件/a11y/属性统计
- docs/ai/api/*.json       每类型的中文描述（源自 QML 头文件注释）

模块顺序与编号遵循 API 冻结文件的 counts 口径：
Nova.Controls → Nova.Behaviors → Nova.Services → Nova.Design → Nova.Composite.LayoutShell（组合组件专属，宪法 0.3.0）。
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
API = ROOT / "api" / "nova-api-1.4.0.json"
AI_API = ROOT / "docs" / "ai" / "api"
OUT = ROOT / "docs" / "COMPONENT_LIST.md"

MODULE_ORDER = ["Nova.Controls", "Nova.Behaviors", "Nova.Services", "Nova.Design",
                "Nova.Composite.LayoutShell"]
CN_NUM = "一二三四五六七八九十"
MODULE_LABEL = {
    "Nova.Controls": "Controls · 控件",
    "Nova.Behaviors": "Behaviors · 行为",
    "Nova.Services": "Services · 服务单例",
    "Nova.Design": "Design · 设计层",
    "Nova.Composite.LayoutShell": "Composite/LayoutShell · 组合组件（15 项根容器）",
}
A11Y_LABEL = {
    "decorative": "decorative（装饰）",
    "interactive": "interactive（交互）",
    "semantic": "semantic（语义）",
}


def parse_description(desc: str, name: str) -> tuple[str, str]:
    """从 AI 文档描述中拆出 (中文说明, 对标 Quasar)。"""
    text = (desc or "").strip()

    parity = ""
    match = re.search(r"（对标\s*([^）]+)）", text)
    if match:
        parity = match.group(1).strip()
    if not parity:
        match = re.search(r"对标\s+(Quasar\s+)?(v?[A-Z][A-Za-z0-9]*(?:\s+插件)?)", text)
        if match:
            parity = match.group(0).replace("对标 ", "", 1).strip()

    summary = text
    for pattern in (
        r"\s+a11y\s*:",
        r"\s+Nova\w+\s+——",
        r"\s+契约",
        r"\s+实现口径",
        r"\s+用法",
    ):
        match = re.search(pattern, summary)
        if match:
            summary = summary[: match.start()]
    summary = re.split(r"(?<=[。；])\s", summary)[0]
    summary = re.sub(r"（对标\s*[^）]+）", "", summary)  # 对标已单列，去重
    summary = re.sub(r"^" + re.escape(name) + r"\s*", "", summary)
    summary = summary.strip(" ：:，,、；;。")
    if len(summary) > 110:
        summary = summary[:108] + "…"
    return summary or "—", parity or "Nova 增强 / 无对应"


def main() -> int:
    freeze = json.loads(API.read_text(encoding="utf-8"))
    types = freeze["types"]

    lines: list[str] = []
    lines.append("# pyside-nova 组件清单")
    lines.append("")
    lines.append(
        f"> 版本 **{freeze['packageVersion']}** · 基线 **{freeze['baseline']}** · "
        f"API 指纹 `{freeze['fingerprint']}` · 共 **{freeze['counts']['total']}** 个公共 QML 类型"
    )
    lines.append(">")
    lines.append(
        "> 数据源：`api/nova-api-1.4.0.json`（权威）+ `docs/ai/api/*.json`（描述）。"
        "本文件由 `scripts/gen_component_list.py` 生成，请勿手工编辑。"
    )
    lines.append(">")
    lines.append(
        "> 分类口径：" + " / ".join(
            f"{module} {freeze['counts']['modules'][module]}" for module in MODULE_ORDER
        ) + "；每个类型在 `examples/gallery/` 中有实机展示页面。"
    )
    lines.append("")
    lines.append("## 目录")
    lines.append("")
    for idx, module in enumerate(MODULE_ORDER, 1):
        count = freeze["counts"]["modules"][module]
        lines.append(f"- {CN_NUM[idx - 1]}、{MODULE_LABEL[module]}（{count} 项）")
    lines.append("")
    lines.append("---")
    lines.append("")

    number = 0
    for section, module in enumerate(MODULE_ORDER, 1):
        count = freeze["counts"]["modules"][module]
        lines.append(f"## {CN_NUM[section - 1]}、{MODULE_LABEL[module]}（{count} 项）")
        lines.append("")
        lines.append("| 序号 | 组件 | 说明 | 对标 Quasar | a11y | 属性/信号/方法 | QML 文件 |")
        lines.append("|---:|---|---|---|---|---:|---|")

        # 注意：modules[].types 列表本身不完整（实测 Design 空、Services 仅 4），
        # 权威来源是 types 字典 + counts 计数，故按 types 的 module 字段反查并排序。
        names = sorted(
            key[len(module) + 1:]  # 精确剥离 "Nova.Controls." 前缀
            for key, info in types.items()
            if info["module"] == module
        )
        for name in names:
            number += 1
            key = f"{module}.{name}"
            info = types[key]
            doc_path = AI_API / f"{key}.json"
            doc = json.loads(doc_path.read_text(encoding="utf-8")) if doc_path.exists() else {}
            summary, parity = parse_description(doc.get("description", ""), name)
            props = len(info.get("props", []))
            signals = len(info.get("signals", []))
            methods = len(info.get("methods", []))
            stat = f"{props}/{signals}/{methods}"
            a11y = A11Y_LABEL.get(info.get("a11y", ""), info.get("a11y", "—"))
            qml = f"`{info['file']}`"
            lines.append(
                f"| {number} | **{name}** | {summary} | {parity} | {a11y} | {stat} | {qml} |"
            )
        lines.append("")

    lines.append("---")
    lines.append("")
    lines.append("## 统计")
    lines.append("")
    lines.append("| 模块 | 数量 | 占比 |")
    lines.append("|---|---:|---:|")
    for module in MODULE_ORDER:
        count = freeze["counts"]["modules"][module]
        lines.append(f"| {MODULE_LABEL[module]} | {count} | {count / freeze['counts']['total']:.1%} |")
    lines.append(f"| **合计** | **{freeze['counts']['total']}** | **100%** |")
    lines.append("")
    a11y_counts = freeze["counts"]["a11y"]
    lines.append(
        "a11y 契约分布：decorative "
        f"{a11y_counts['decorative']} / interactive {a11y_counts['interactive']} / "
        f"semantic {a11y_counts['semantic']}。"
        "完整契约见 [A11Y_MATRIX.md](A11Y_MATRIX.md)（`scripts/check_a11y.py` 生成）。"
    )
    lines.append("")

    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"已生成 {OUT.relative_to(ROOT)}：{number} 个类型")
    if number != freeze["counts"]["total"]:
        print(f"警告：数量不符（期望 {freeze['counts']['total']}），请检查数据源", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
