#!/usr/bin/env python3
# scripts/check_version_imprint.py
# 版本烙印一致性门（①A 类 · 2026-11-28 12:35 CSA 采纳建议范围）
"""pyside-nova × Quasar 版本烙印门：唯一事实源 → 机读投影 → 对外烙印 → 关系声明 → 跟进锚点。

**事实源纪律**：``upstream/quasar-pin.json`` 是全库唯一允许手写上游版本号的地方。
本脚本只读、不写盘、不联网、不复制版本号；README / README_zh 的现状表是**活口径投影**，
正则精确定位表格行，不模糊搜全文（史料段的 2.35.5 基线留痕一律不检查、不回改）。

四项校验：
1. pin 事实源的 ``pinned_version`` / ``observed_version`` 与 ``matrix.json`` / ``breadth.json`` 投影逐字一致。
2. README / README_zh 现状表的 pinned / observed 行与 pin 事实源逐字一致。
3. 关系声明只出现 ``Inspired by Quasar`` / ``受 Quasar 启发``；禁用表述取自
   ``docs/QUASAR_ACKNOWLEDGEMENT.md`` §4 表（tagline「The Quasar of Qt Quick」的解禁
   仅限品牌首屏，关系声明层仍禁用，见 §4 效力变更注）。
4. ``upstream/cadence.json::status == ratified`` 且 ``scope_ref`` 仍指向 pin 事实源
   （跟进节奏与烙印同源，不散落版本号）。

用法::

    python scripts/check_version_imprint.py

退出码（对齐 check_upstream_drift.py）：
    0 = 四项全绿；1 = 烙印/投影/声明漂移；2 = 前置文件缺失。

**边界**：不挂 ``check_all.py --tier static``（静态恒 3/3），交付前单独跑；
不升 pin、不改冻结面、不新建自动化、不发布。
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PIN_PATH = ROOT / "upstream" / "quasar-pin.json"
CADENCE_PATH = ROOT / "upstream" / "cadence.json"
PROJECTIONS = (ROOT / "parity" / "matrix.json", ROOT / "parity" / "breadth.json")
READMES = (ROOT / "README.md", ROOT / "README_zh.md")

# 只认现状表整行；旧态史料中的「对标基线 2.35.5」不参与本门。
TABLE_PATTERNS: dict[Path, dict[str, re.Pattern[str]]] = {
    ROOT / "README.md": {
        "pinned_version": re.compile(
            r"^\|\s*\*\*Parity baseline \(pinned\)\*\*\s*\|\s*Quasar \*\*([0-9.]+)\*\*", re.MULTILINE
        ),
        "observed_version": re.compile(
            r"^\|\s*\*\*Observed upstream\*\*\s*\|\s*Quasar \*\*([0-9.]+)\*\*", re.MULTILINE
        ),
    },
    ROOT / "README_zh.md": {
        "pinned_version": re.compile(
            r"^\|\s*\*\*对标基线（pinned）\*\*\s*\|\s*Quasar \*\*([0-9.]+)\*\*", re.MULTILINE
        ),
        "observed_version": re.compile(
            r"^\|\s*\*\*上游已观察（observed）\*\*\s*\|\s*Quasar \*\*([0-9.]+)\*\*", re.MULTILINE
        ),
    },
}

# QUASAR_ACKNOWLEDGEMENT.md §4 表的禁用表述（关系声明层；tagline 解禁不适用此处）。
FORBIDDEN = (
    "Derived from Quasar", "源自 Quasar", "Quasar fork", "Python port of Quasar",
    "surpasses its origin", "超越原版", "ports that ecosystem",
)
ALLOWED = ("Inspired by Quasar", "受 Quasar 启发")


def _load(path: Path) -> dict:
    with path.open(encoding="utf-8") as fh:
        return json.load(fh)


def _require_files() -> list[str]:
    paths = [PIN_PATH, CADENCE_PATH, *PROJECTIONS, *READMES,
             ROOT / "docs" / "QUASAR_ACKNOWLEDGEMENT.md"]
    return [str(p.relative_to(ROOT)) for p in paths if not p.is_file()]


def check() -> list[tuple[int, str]]:
    """返回 ``(校验项序号, 失败原因)`` 列表；空 = 全绿。"""
    failures: list[tuple[int, str]] = []
    pin = _load(PIN_PATH)
    fields = ("pinned_version", "observed_version")
    for field in fields:
        if field not in pin:
            failures.append((1, f"pin 事实源缺字段 {field}"))

    # 1. pin → 机读投影（生成物禁手改，漂移即红）
    for path in PROJECTIONS:
        data = _load(path)
        for field in fields:
            if data.get(field) != pin.get(field):
                failures.append((
                    1,
                    (f"{path.relative_to(ROOT)}::{field} = {data.get(field)!r}，"
                     f"事实源 = {pin.get(field)!r}"),
                ))

    # 2. pin → README / README_zh 现状表（精确行匹配，不模糊扫全文）
    for path, patterns in TABLE_PATTERNS.items():
        text = path.read_text(encoding="utf-8")
        for field, pattern in patterns.items():
            found = pattern.search(text)
            if not found:
                failures.append((2, f"{path.relative_to(ROOT)} 现状表缺 {field} 行"))
            elif found.group(1) != pin.get(field):
                failures.append((
                    2,
                    (f"{path.relative_to(ROOT)}::{field} = {found.group(1)!r}，"
                     f"事实源 = {pin.get(field)!r}"),
                ))

    # 3. 关系声明：禁用表述零命中 + 允许表述至少一处
    for path in READMES:
        text = path.read_text(encoding="utf-8")
        for phrase in FORBIDDEN:
            if phrase.lower() in text.lower():
                failures.append((3, f"{path.relative_to(ROOT)} 出现禁用表述 {phrase!r}"))
        if not any(phrase in text for phrase in ALLOWED):
            failures.append((
                3,
                (f"{path.relative_to(ROOT)} 关系声明缺允许表述 "
                 f"({' / '.join(ALLOWED)})"),
            ))

    # 4. 跟进锚点：D3 已核定 + scope_ref 指回 pin 事实源（不复制版本号）
    cadence = _load(CADENCE_PATH)
    if cadence.get("status") != "ratified":
        failures.append((4, f"cadence.json::status = {cadence.get('status')!r}，应为 ratified"))
    scope_ref = cadence.get("scope_ref")
    if not isinstance(scope_ref, str) or "quasar-pin.json" not in scope_ref:
        failures.append((4, "cadence.json::scope_ref 未指向 upstream/quasar-pin.json"))

    return failures


def main() -> int:
    parser = argparse.ArgumentParser(description="pyside-nova 版本烙印一致性门（只读）")
    parser.parse_args()
    missing = _require_files()
    if missing:
        print("[VERSION-IMPRINT] 前置缺失：" + "、".join(missing))
        return 2
    failures = check()
    items = (
        "1. pin ↔ matrix/breadth 机读投影一致",
        "2. pin ↔ README/README_zh 现状表一致",
        "3. 关系声明 Inspired by / 禁用表述零命中",
        "4. D3 cadence ratified + scope_ref 指回 pin",
    )
    # 失败原因按序号归类展示；无失败则四项全 PASS。
    for idx, label in enumerate(items, start=1):
        bucket = [reason for no, reason in failures if no == idx]
        print(f"[VERSION-IMPRINT] {label} — {'FAIL' if bucket else 'PASS'}")
        for reason in bucket:
            print(f"[VERSION-IMPRINT]   ↳ {reason}")
    if failures:
        print(f"[VERSION-IMPRINT] RESULT: FAIL ({len(failures)} 项漂移)")
        return 1
    print("[VERSION-IMPRINT] RESULT: PASS (4/4)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
