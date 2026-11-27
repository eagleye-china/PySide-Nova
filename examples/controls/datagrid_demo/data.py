# examples/controls/datagrid_demo/data.py
"""铝电解工作站 · 模拟数据源（纯 Python，零 Qt 依赖）。

业务口径（与 README 的「工艺阈值」小节同源）：
  - 一个电解系列下辖若干工区，每台槽以 ``系列-工区-序号`` 编号，作为 rowKey；
  - 一次采集刷新槽电压 / 电解温度 / 氧化铝浓度 / 炉底压降 / 阳极效应次数；
  - severity 由工艺阈值判定，0 正常 / 1 预警 / 2 严重，同时决定「状态」列文本。

刻意做成确定性数据源：``seed`` 固定时任意行数档位都可复现，
便于离屏真机截图对齐、统计断言与回归比对。
"""
from __future__ import annotations

import random

from pyside_nova.datagrid import SEVERITY_FIELD, NovaDataGridColumn

SERIES = ("一系列", "二系列", "三系列", "四系列")
WORKSHOPS = ("一车间", "二车间", "三车间", "四车间", "五车间", "六车间")
STATE_LABELS = {0: "正常", 1: "预警", 2: "严重"}

# ── 工艺阈值（severity 判定 + UI 说明的唯一事实源）──────────────
TEMP_WARN = 958.0       # 电解温度 °C 预警线
TEMP_CRIT = 968.0       # 电解温度 °C 严重线
VOLT_WARN = 4.30        # 槽电压 V 预警线
VOLT_CRIT = 4.45        # 槽电压 V 严重线
DROP_WARN = 395.0       # 炉底压降 mV 预警线
EFFECT_WARN = 2         # 阳极效应次数 预警线
EFFECT_CRIT = 4         # 阳极效应次数 严重线

DEFAULT_ROWS = 4000
DEFAULT_SEED = 20261127
DEFAULT_INTERVAL = 400   # ms / 批
DEFAULT_BATCH = 24       # 槽 / 批


def _clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def severity_of(row: dict) -> int:
    """按工艺阈值判定槽况等级；严重优先于预警。"""
    if (row["temp"] >= TEMP_CRIT or row["voltage"] >= VOLT_CRIT
            or row["effect"] >= EFFECT_CRIT):
        return 2
    if (row["temp"] >= TEMP_WARN or row["voltage"] >= VOLT_WARN
            or row["drop"] >= DROP_WARN or row["effect"] >= EFFECT_WARN):
        return 1
    return 0


def with_severity(row: dict) -> dict:
    """账实同源：severity 与 state 永远由同一份行数据推导，不各处硬编码。"""
    out = dict(row)
    out[SEVERITY_FIELD] = severity_of(out)
    out["state"] = STATE_LABELS[out[SEVERITY_FIELD]]
    return out


def build_columns() -> list[NovaDataGridColumn]:
    """11 列工艺参数；「槽电压」可内联编辑（editor=number）。"""
    return [
        NovaDataGridColumn("slot", "槽号", width=130),
        NovaDataGridColumn("workshop", "工区", width=100),
        NovaDataGridColumn("voltage", "槽电压(V)", width=120,
                           align="right", editable=True, editor="number"),
        NovaDataGridColumn("current", "系列电流(kA)", width=130, align="right"),
        NovaDataGridColumn("temp", "电解温度(°C)", width=130, align="right"),
        NovaDataGridColumn("alumina", "Al₂O₃浓度(%)", width=140, align="right"),
        NovaDataGridColumn("ratio", "分子比", width=100, align="right"),
        NovaDataGridColumn("drop", "炉底压降(mV)", width=140, align="right"),
        NovaDataGridColumn("effect", "阳极效应(次)", width=130, align="right"),
        NovaDataGridColumn("age", "槽龄(天)", width=100, align="right"),
        NovaDataGridColumn("state", "状态", width=110),
    ]


def generate_rows(count: int, seed: int = DEFAULT_SEED) -> list[dict]:
    """生成 ``count`` 台电解槽的确定性初始快照。"""
    rng = random.Random(seed)
    rows: list[dict] = []
    for i in range(count):
        series_idx = i % len(SERIES)
        shop_idx = (i // len(SERIES)) % len(WORKSHOPS)
        seq = i // (len(SERIES) * len(WORKSHOPS)) + 1
        row = {
            "slot": f"{series_idx + 1}-{shop_idx + 1}-{seq:03d}",
            "series": SERIES[series_idx],
            "workshop": WORKSHOPS[shop_idx],
            "voltage": round(_clamp(rng.gauss(4.16, 0.10), 3.85, 4.60), 2),
            "current": round(_clamp(rng.gauss(338.0, 6.0), 310.0, 365.0), 1),
            "temp": round(_clamp(rng.gauss(948.0, 8.0), 925.0, 985.0), 1),
            "alumina": round(_clamp(rng.gauss(2.9, 0.6), 1.2, 4.8), 2),
            "ratio": round(_clamp(rng.gauss(2.48, 0.10), 2.10, 2.90), 2),
            "drop": int(_clamp(rng.gauss(340.0, 28.0), 260, 440)),
            "effect": rng.choices([0, 1, 2, 3, 4, 5, 6],
                                  weights=[45, 22, 14, 9, 6, 3, 1])[0],
            "age": rng.randint(120, 2400),
        }
        rows.append(with_severity(row))
    return rows


def make_batch(rng: random.Random, rows: list[dict], size: int) -> list[dict]:
    """模拟一次采集批次：随机抽 ``size`` 台槽，刷新工艺量并重算 severity。

    返回的是**增量更新**（按 slot 作为 rowKey 合并），供
    ``NovaDataGridModel.batchUpdate()`` 使用；宿主侧同时用它同步自己的数据镜像。
    """
    if not rows:
        return []
    picks = rng.sample(range(len(rows)), min(size, len(rows)))
    updates: list[dict] = []
    for idx in picks:
        row = rows[idx]
        merged = {
            "slot": row["slot"],
            "voltage": round(_clamp(row["voltage"] + rng.gauss(0, 0.035), 3.85, 4.60), 2),
            "temp": round(_clamp(row["temp"] + rng.gauss(0, 2.2), 925.0, 985.0), 1),
            "alumina": round(_clamp(row["alumina"] + rng.gauss(0, 0.18), 1.2, 4.8), 2),
            "drop": int(_clamp(row["drop"] + rng.gauss(0, 8), 260, 440)),
        }
        if rng.random() < 0.06:
            merged["effect"] = min(6, row["effect"] + 1)
        full = dict(row)
        full.update(merged)
        full[SEVERITY_FIELD] = severity_of(full)
        full["state"] = STATE_LABELS[full[SEVERITY_FIELD]]
        # 只把变化的字段 + severity/state 送进模型，避免整行回写
        updates.append(merged | {
            SEVERITY_FIELD: full[SEVERITY_FIELD],
            "state": full["state"],
        })
    return updates


def compute_stats(rows: list[dict]) -> dict:
    """Python 侧聚合统计（QML 不遍历全表，4000 行量级约 2 ms）。"""
    total = len(rows)
    sev = {0: 0, 1: 0, 2: 0}
    volt_sum = 0.0
    temp_sum = 0.0
    for row in rows:
        sev[int(row.get(SEVERITY_FIELD, 0))] += 1
        volt_sum += row["voltage"]
        temp_sum += row["temp"]
    return {
        "total": total,
        "normal": sev[0],
        "warning": sev[1],
        "critical": sev[2],
        "healthyRate": round(100.0 * sev[0] / total, 1) if total else 0.0,
        "avgVoltage": round(volt_sum / total, 2) if total else 0.0,
        "avgTemp": round(temp_sum / total, 1) if total else 0.0,
    }
