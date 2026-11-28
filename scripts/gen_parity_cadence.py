#!/usr/bin/env python3
# scripts/gen_parity_cadence.py
# Parity Ops L-D：D3 跟进节奏唯一法源 → 现行视图（生成物，禁手改）
"""渲染 ``docs/PARITY_CADENCE.md``（D3 已核定节奏的现行人类可读视图）。

**输入**：``upstream/cadence.json`` —— 唯一手写法源（CSA 09:37 授权「D3 你先定」）。
本脚本不复制版本号（版本事实源恒为 ``upstream/quasar-pin.json``），只读节奏口径。

用法::

    python scripts/gen_parity_cadence.py           # 生成视图
    python scripts/gen_parity_cadence.py --check  # 幂等校验（重渲染全文双向核对，不写盘）

退出码：0 = 成功 / 一致；1 = 幂等漂移 / 法源结构不完整；2 = 前置缺失。
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CADENCE_PATH = ROOT / "upstream" / "cadence.json"
VIEW_PATH = ROOT / "docs" / "PARITY_CADENCE.md"


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def stable_signature(doc: dict) -> str:
    """由法源全文字段重算（cadence.json 本身不含 signature / generated_at）。"""
    return _sha256(json.dumps(doc, sort_keys=True, ensure_ascii=False).encode("utf-8"))


def validate(doc: dict) -> None:
    """法源链不留悬空：结构完整性在渲染前就校验。"""
    if doc.get("schema") != "nova-upstream-cadence/1" or doc.get("status") != "ratified":
        raise ValueError("cadence.json schema / status 非法")
    triggers = doc.get("triggers", [])
    if [t.get("id") for t in triggers] != ["T1", "T2", "T3"]:
        raise ValueError("三档触发必须精确为 T1 / T2 / T3")
    if sum(1 for t in triggers if t.get("blocking")) != 1:
        raise ValueError("必须且只能有一道硬门（T1）")
    sla = doc.get("classification_sla", {})
    if set(sla) != {"C0", "C1", "C2", "C3", "C4", "C5", "C6"}:
        raise ValueError("C0~C6 分级 SLA 必须全覆盖")
    if {k for k, v in sla.items() if v.get("blocking")} != {"C0", "C1", "C5"}:
        raise ValueError("阻断类必须与 check_upstream_drift.py::BLOCKING 一致（C0/C1/C5）")
    if not doc.get("non_goals") or not doc.get("deferred_to_p3"):
        raise ValueError("non_goals / deferred_to_p3 不得为空（边界不悬空）")


def render_view(doc: dict) -> str:
    sig = stable_signature(doc)
    eb = doc["empirical_basis"]
    lines = [
        "# 上游跟进节奏（D3 · 2026-11-28 09:37 已核定）",
        "",
        f"<!-- cadence-signature: {sig} -->",
        "",
        ("> **生成物 · 禁手改**：由 `scripts/gen_parity_cadence.py` 从唯一法源 "
         "`upstream/cadence.json` 渲染；`check_parity_ops.py` 用此签名做双向核对。"),
        ("> **版本事实源**：`upstream/quasar-pin.json`（本页刻意不复制 pinned / observed 版本号，"
         "避免口径散落）。**关系口径**：Inspired by Quasar (MIT) · 只用公开 API 元数据与发布说明。"),
        ("> **性质**：本页是**节奏口径**（方向与标准级），不是自动化实现。"
         "本轮未创建任何定时自动化任务；周期自动化属 P3，须 CSA 单独授权。"),
        "",
        "## 1. 核定结论",
        "",
        f"**{doc['decision']}**",
        "",
        (f"核定依据：{doc['decided_by']}。承接提案 §7-D3 的建议"
         "（交付前离线门 + 每周在线周巡），并按磁盘实证把「每周」细化为三档触发与分级 SLA。"),
        "",
        "## 2. 实证依据（为什么不做准实时）",
        "",
        "| 版本 | 日期 | 实际变更 |",
        "|---|---|---|",
    ]
    for row in eb["release_timeline"]:
        parts = [p.strip() for p in row.split("·")]
        lines.append(f"| {parts[0]} | {parts[1]} | {parts[2]} |" if len(parts) >= 3
                     else f"| {row} | | |")
    lines += ["", "> 逐条实证："]
    for f in eb["observed_facts"]:
        lines.append(f"> - {f}")
    lines += ["", f"> **推论**：{eb['inference']}", "",
              "## 3. 三档触发", "",
              "| 档 | 节奏 | 模式 | 硬门 | SLA | 责任 | 状态 |",
              "|---|---|---|---|---|---|---|"]
    for t in doc["triggers"]:
        hard = "**是（rc 1 阻断）**" if t.get("blocking") else "否"
        lines.append(
            f"| **{t['id']} {t['name']}** | {t['cadence']} | {t['mode']} | {hard} | "
            f"{t['sla']} | {t['owner']} | `{t['status']}` |"
        )
    lines += ["", "### 3.1 各档明细", ""]
    for t in doc["triggers"]:
        lines += [f"**{t['id']} · {t['name']}**", "",
                  f"- 数据源：{t['source']}",
                  f"- 命令：`{'` / `'.join(t['commands'])}`",
                  f"- 产出：{' · '.join(f'`{o}`' if not o.startswith('可选') and ' ' not in o else o for o in t['outputs'])}",
                  f"- 说明：{t['detail']}", ""]
    lines += [
        "## 4. C0~C6 分级响应 SLA",
        "",
        "| 类 | 阻断 | 响应时限 | 动作 | 闸门 |",
        "|---|---|---|---|---|",
    ]
    for k in sorted(doc["classification_sla"]):
        v = doc["classification_sla"][k]
        lines.append(f"| **{k}** | {'**是**' if v['blocking'] else '否'} | {v['sla']} | "
                     f"{v['action']} | {v['gate']} |")
    lines += ["", "## 5. 闸门契约与红线", "",
              "| 项 | 口径 |", "|---|---|"]
    for k, v in doc["gate_contract"].items():
        lines.append(f"| `{k}` | {v} |")
    lines += ["", "## 6. 明确不做（non-goals）", ""]
    for n in doc["non_goals"]:
        lines.append(f"- {n}")
    lines += ["", "## 7. 留给 P3 的待办（本轮不实现）", ""]
    for d in doc["deferred_to_p3"]:
        lines.append(f"- {d}")
    lines += [
        "",
        "## 8. 边界与交还控制权",
        "",
        ("**零 QML 改动 · 零冻结面改动（147 类型 / `9966483dda5a53c4` 不变）· 零史料回改 · "
         "零发布动作 · 零自动化任务**。交付前离线门（`check_upstream_drift.py --offline`）与 "
         "`check_parity.py` 仍按项目惯例单独跑，不挂 `check_all.py --tier static`（静态恒 3/3）。"),
        ("> 节奏已核定，但**周巡的在线实现与定时自动化均需 CSA 另行立项/授权**；"
         "未发话前不自行开工、不建 automation、不升 pin。"),
        "",
        "---",
        "",
        f"*签名 `{sig}` · 由 `gen_parity_cadence.py` 生成，`check_parity_ops.py` 校验。*",
        "",
    ]
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="渲染 / 校验 D3 跟进节奏现行视图")
    ap.add_argument("--check", action="store_true", help="幂等校验（不写盘）")
    args = ap.parse_args(argv)

    if not CADENCE_PATH.exists():
        print(f"[cadence] 事实源缺失：{CADENCE_PATH.relative_to(ROOT)} → rc 2")
        return 2
    try:
        doc = json.loads(CADENCE_PATH.read_text(encoding="utf-8"))
        validate(doc)
        view = render_view(doc)
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"[cadence] 生成失败：{exc} → rc 1")
        return 1

    sig = stable_signature(doc)
    if args.check:
        if not VIEW_PATH.exists():
            print("[cadence] PARITY_CADENCE.md 缺失 → rc 1")
            return 1
        actual = VIEW_PATH.read_text(encoding="utf-8")
        ok = actual == view
        print(f"[cadence] --check {'PASS' if ok else 'FAIL'} · "
              f"signature={sig[:16]} · view_body={'OK' if ok else 'DRIFT'}")
        return 0 if ok else 1

    VIEW_PATH.write_text(view, encoding="utf-8")
    print(f"[cadence] 已写入 docs/PARITY_CADENCE.md · triggers=3 · "
          f"sla_classes={len(doc['classification_sla'])} · signature={sig[:16]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
