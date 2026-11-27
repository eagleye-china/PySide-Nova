"""T29-B 受控物理迁移专项测试：URI 与公共面零漂移 + 归一化反推还原。

CSA 拍板（2026-11-28）：1.11.0 minor · 仅重签指纹 · 不落兼容视图。
硬约束：`Nova.Composite.LayoutShell` URI 与 `import` 全不变、147 类型公共面
逐成员零变化，唯一变化是 10 个 `types[].file` 溯源字段（../ 转发）。

法源：docs/prescript/SPEC_T29_LAYOUTSHELL_SPLIT.md §4 B8（逐成员零漂移证明）
     + GUIDE_CLASSIFICATION.md §1.1 / SPEC_V2_COMPAT.md §116（归一化反推）。
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
QML = ROOT / "src" / "pyside_nova" / "qml" / "Nova"
LAY = QML / "Composite" / "LayoutShell"
COM = QML / "Composite"

OLD_MANIFEST = ROOT / "api" / "nova-api-1.10.0.json"   # 已发布史料，零回改
NEW_MANIFEST = ROOT / "api" / "nova-api-1.11.0.json"   # 本轮重签
OLD_FINGERPRINT = "5328cd0e3c71e7ac"
NEW_FINGERPRINT = "9966483dda5a53c4"
MODULE_URI = "Nova.Composite.LayoutShell"

MOVED = {
    "NovaBlankPage", "NovaCardGrid", "NovaCompare", "NovaDrawerPanel",
    "NovaDualSide", "NovaModal", "NovaSidebar", "NovaTabShell",
    "NovaThreeColumn", "NovaTopNavigation",
}
KEPT = {
    "NovaAgent", "NovaAIReport", "NovaChat", "NovaCopilot", "NovaDE",
    "NovaDesktop", "NovaFlexLayout", "NovaIncubator", "NovaMobile",
    "NovaOrbit", "NovaSetupWizard",
}


def _fp(surface: dict) -> str:
    """与 scripts/gen_api_freeze.py::fingerprint 完全同口径。"""
    canon = json.dumps(surface, ensure_ascii=False, sort_keys=True,
                       separators=(",", ":"))
    return hashlib.sha256(canon.encode("utf-8")).hexdigest()[:16]


def _surface(man: dict) -> dict:
    return {"modules": man["modules"], "types": man["types"]}


@pytest.fixture(scope="module")
def old():
    return json.loads(OLD_MANIFEST.read_text(encoding="utf-8"))


@pytest.fixture(scope="module")
def new():
    return json.loads(NEW_MANIFEST.read_text(encoding="utf-8"))


# ── 1. 新清单与史料清单的元信息 ────────────────────────────────
def test_manifests_versions(new, old):
    assert NEW_MANIFEST.exists() and OLD_MANIFEST.exists()
    assert new["apiVersion"] == "1.11.0"
    assert new["packageVersion"] == "1.11.0"
    assert new["fingerprint"] == NEW_FINGERPRINT
    assert len(new["types"]) == 147
    # 1.10.0 已发布史料零回改
    assert old["fingerprint"] == OLD_FINGERPRINT
    assert old["apiVersion"] == "1.10.0"
    assert len(old["types"]) == 147


def test_new_fingerprint_selfconsistent(new):
    """清单自洽：指纹必须能由 surface 重算得出（防手改绕过）。"""
    assert _fp(_surface(new)) == new["fingerprint"]


# ── 2. 顶层字段除版本/指纹外逐字不变 ──────────────────────────
def test_top_level_zero_drift(new, old):
    volatile = {"apiVersion", "packageVersion", "fingerprint", "types"}
    for k in old:
        if k in volatile:
            continue
        assert new[k] == old[k], f"顶层字段 {k} 被改动"


# ── 3. 核心：公共面逐成员零漂移，唯一变化 = 10 个 file ─────────
def test_public_surface_zero_drift(new, old):
    assert set(new["types"]) == set(old["types"]), "类型集合变化"
    assert new["counts"] == old["counts"], "counts 变化"
    changed_files = []
    for key in old["types"]:
        o, n = old["types"][key], new["types"][key]
        assert set(n) == set(o), f"{key} 字段集合变化"
        for field in o:
            if field == "file":
                continue
            assert n[field] == o[field], f"{key}.{field} 公共成员被改动"
        if n["file"] != o["file"]:
            changed_files.append(key)
    assert len(changed_files) == 10, f"file 变化数应为 10：{changed_files}"
    assert {k.split(".")[-1] for k in changed_files} == MOVED


def test_normalized_reverse_restores_old_fingerprint(new, old):
    """归一化反推：把 10 个新 file 改回旧值，指纹精确还原 1.10.0。"""
    surface = _surface(new)
    surface["types"] = {k: dict(v) for k, v in new["types"].items()}
    restored = 0
    for key in old["types"]:
        if surface["types"][key]["file"] != old["types"][key]["file"]:
            surface["types"][key]["file"] = old["types"][key]["file"]
            restored += 1
    assert restored == 10
    assert _fp(surface) == OLD_FINGERPRINT, "归一化反推未能还原旧指纹"


# ── 4. qmldir：10 条 ../ 转发 / 11 条原位 / URI 不变 ───────────
def test_qmldir_forwarding():
    text = (LAY / "qmldir").read_text(encoding="utf-8")
    lines = [l.strip() for l in text.splitlines()
             if l.strip() and not l.strip().startswith("#")
             and not l.strip().startswith("module ")]
    entries = {}
    for l in lines:
        parts = l.split()
        if len(parts) >= 3 and parts[1].startswith("1."):
            entries[parts[0]] = parts[2]
    assert len(entries) == 21, f"导出行应为 21，实得 {len(entries)}"
    assert f"module {MODULE_URI}" in text
    fwd = {k for k, v in entries.items() if v.startswith("../")}
    assert fwd == MOVED, f"../ 转发集不符：{fwd ^ MOVED}"
    for k in KEPT:
        assert entries[k] == f"{k}.qml", f"{k} 应保持原位平铺导出"
    # 现行校准注释已登记，史料注释保留（不圆场）
    assert "T29-B 现行校准" in text
    assert "不再落物理子目录" in text


# ── 5. 物理文件：10 上移 / 11 留原处 ───────────────────────────
def test_physical_layout():
    for n in MOVED:
        assert (COM / f"{n}.qml").exists(), f"{n}.qml 未上移到 Composite/"
        assert not (LAY / f"{n}.qml").exists(), f"{n}.qml 仍残留在 LayoutShell/"
    for n in KEPT:
        assert (LAY / f"{n}.qml").exists(), f"{n}.qml 应保持原位"
        assert not (COM / f"{n}.qml").exists(), f"{n}.qml 被误移"
    # 文件头路径注释已同步，description 来源（第 2~3 行）不动
    first = (COM / "NovaSidebar.qml").read_text(encoding="utf-8").splitlines()[0]
    assert "Nova/Composite/NovaSidebar.qml" in first
    assert "Nova/Composite/LayoutShell/NovaSidebar.qml" not in first


# ── 6. 判别锚与 URI 引用未变 ──────────────────────────────────
def test_hue_discriminant_unchanged():
    """11 保留 = 命中 hsvHue；10 移出 = 未命中；零例外。"""
    hue, plain = set(), set()
    for p in list(LAY.glob("*.qml")) + list(COM.glob("*.qml")):
        (hue if "hsvHue" in p.read_text(encoding="utf-8") else plain).add(p.stem)
    assert hue == KEPT, f"hsvHue 命中集不符：{hue ^ KEPT}"
    assert plain == MOVED, f"hsvHue 未命中集不符：{plain ^ MOVED}"


def test_module_uri_import_intact():
    """已发布 import 用法零改动：全库仍以绝对模块 URI 引用。"""
    qmldirs = sorted(QML.glob("**/qmldir"))
    assert len(qmldirs) == 5, f"qmldir 应恰 5 个：{[p.name for p in qmldirs]}"
    mods = set()
    for p in qmldirs:
        for l in p.read_text(encoding="utf-8").splitlines():
            if l.strip().startswith("module "):
                mods.add(l.strip().split()[1])
    assert MODULE_URI in mods
    assert "Nova.Composite" not in mods, "不得升格独立模块（C 档未采纳）"
    # 迁移集 QML 正文无相对路径 import
    for n in MOVED:
        t = (COM / f"{n}.qml").read_text(encoding="utf-8")
        assert 'import "' not in t, f"{n} 出现相对路径 import"
