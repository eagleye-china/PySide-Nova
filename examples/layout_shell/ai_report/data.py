# examples/layout_shell/ai_report/data.py
"""NovaAIReport 演示数据集（纯 Python，零 Qt 依赖）。

业务口径：铝电解智能报表的八列事实表 —— 本厂值 / 行业基线 / 差距 /
状态 / 2–8h 预测区间。数据源刻意做成确定性（seed 固定即可复现），
便于三态出图、离屏验收与统计断言账实同源。

边界纪律：本文件只生成"业务事实"，不承载 Shell 语义；归因 / 预测 /
问数 / 审批的文字呈现由 QML 槽位注入，Python 侧只提供统计聚合与信号记录。
"""
from __future__ import annotations

import random

from pyside_nova.datagrid import SEVERITY_FIELD, NovaDataGridColumn

STATE_LABELS = {0: "正常", 1: "预警", 2: "严重"}
DEFAULT_ROWS = 240
DEFAULT_SEED = 20261127
DEFAULT_PAGE_SIZE = 12
BENCH_CE = 93.6          # 行业基线：电流效率 %
ADVANCED_CE = 94.6       # 先进基线：电流效率 %


def build_columns() -> list[NovaDataGridColumn]:
    """八列报表事实表；电流效率可内联编辑（editor=number）。"""
    return [
        # 列宽合计 728px：在七槽布局的中央区（左右轨展开时约 760px）首屏
        # 完整显示八列，避免水平滚动条遮挡状态列（观感 / CC-4）。
        NovaDataGridColumn("slot", "槽号", width=84),
        NovaDataGridColumn("ce", "效率(%)", width=92,
                           align="right", editable=True, editor="number"),
        NovaDataGridColumn("dc", "电耗(kWh/t)", width=108, align="right"),
        NovaDataGridColumn("effect", "效应(次)", width=84, align="right"),
        NovaDataGridColumn("bench", "基线(%)", width=92, align="right"),
        NovaDataGridColumn("gap", "差距", width=72, align="right"),
        NovaDataGridColumn("forecast", "2–8h 预测区间", width=120),
        NovaDataGridColumn("state", "状态", width=76),
    ]


def _clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def severity_of(ce: float, effect: int) -> int:
    """工艺口径：电流效率 <92 或效应 ≥4 判严重；<93 或效应 ≥2 判预警。"""
    if ce < 92.0 or effect >= 4:
        return 2
    if ce < 93.0 or effect >= 2:
        return 1
    return 0


def with_severity(row: dict) -> dict:
    """账实同源：severity 与 state 永远由同一行事实推导。"""
    out = dict(row)
    sev = severity_of(float(out["ce"]), int(out["effect"]))
    out[SEVERITY_FIELD] = sev
    out["state"] = STATE_LABELS[sev]
    return out


def generate_rows(count: int = DEFAULT_ROWS,
                  seed: int = DEFAULT_SEED) -> list[dict]:
    """生成 ``count`` 台电解槽的确定性报表快照。"""
    rng = random.Random(seed)
    rows: list[dict] = []
    for i in range(count):
        ce = round(_clamp(rng.gauss(93.4, 1.1), 90.5, 95.2), 2)
        effect = rng.choices([0, 1, 2, 3, 4, 5],
                             weights=[44, 24, 15, 9, 6, 2])[0]
        row = {
            "slot": f"{(i % 4) + 1}-{(i // 4) % 6 + 1}-{i // 24 + 1:03d}",
            "ce": ce,
            "dc": round(_clamp(13100 - (ce - 93.0) * 145 + rng.gauss(0, 45),
                               12100, 13800), 0),
            "effect": effect,
            "bench": BENCH_CE,
            "gap": round(ce - BENCH_CE, 2),
            "forecast": f"{round(ce - 0.6, 1)}–{round(ce + 0.4, 1)}",
        }
        rows.append(with_severity(row))
    return rows


def compute_stats(rows: list[dict]) -> dict:
    """Python 侧聚合统计；QML 只读属性，绝不遍历全表。"""
    total = len(rows)
    sev = {0: 0, 1: 0, 2: 0}
    ce_sum = 0.0
    dc_sum = 0.0
    for row in rows:
        sev[int(row.get(SEVERITY_FIELD, 0))] += 1
        ce_sum += float(row["ce"])
        dc_sum += float(row["dc"])
    avg_ce = round(ce_sum / total, 2) if total else 0.0
    return {
        "total": total,
        "normal": sev[0],
        "warning": sev[1],
        "critical": sev[2],
        "avgCE": avg_ce,
        "avgDC": round(dc_sum / total, 0) if total else 0.0,
        "gapCE": round(avg_ce - BENCH_CE, 2),
        "advancedGap": round(ADVANCED_CE - avg_ce, 2),
        "healthyRate": round(100.0 * sev[0] / total, 1) if total else 0.0,
    }
