# tests/test_api_freeze.py
# API 冻结门禁（六期 RC1）：冻结清单自洽性、面零漂移、命名红线、静态体检、qmllint 预算
"""API 冻结（1.0）门禁测试。

三道闸的自动化验收：
1. **清单自洽**：`api/nova-api-1.6.0.json` 的指纹必须能由内容重算得出（防手改绕过）；
2. **面零漂移**：现网 146 类型逐成员（props/signals/methods）与清单一致；
   并验证门禁**能真的变红**（删类型/加成员/改签名三类反例，防「永远绿」的假门禁）；
3. **命名与纪律**：`on*` 前缀、基类成员撞名、qmldir `//` 注释、版本 1.0、头注释、
   `Component.onDestroyed` 等红线零违规；
4. **qmllint**：error 零容忍 + warning 分类预算（`tests/lint-baseline.json`）。

本模块纯静态（不建 QML 引擎），失败信息直接指向源码行。
"""
from __future__ import annotations

import copy
import json
import os
import subprocess
import sys
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS))

import check_api_freeze as caf  # noqa: E402
import check_qmllint as cql  # noqa: E402
import gen_api_freeze as gaf  # noqa: E402

MANIFEST = ROOT / "api" / "nova-api-1.6.0.json"
DOC = ROOT / "docs" / "API_FREEZE.md"

# 1.2.0：组合模块 19→20（新增 NovaIncubator 第 20 组合根，宪法第 8 章 additive · 整批单次重签）；总数 143→144
# 1.3.0：NovaIncubator additive（emblemClickable:bool + emblemClicked() + emblemToolTip:string 徽记可点带悬停提示）；总数不变
# 1.4.0：新增公共导出类型 NovaMarkdown（Nova.Controls 第 92 个），宪法第 8 章 additive minor 整批单次重签；总数 144→145
# 1.5.0：新增公共导出类型 NovaDataGrid（Nova.Controls 第 93 个），整批单次重签；总数 145→146，旧 145 类型逐字不变
# 1.5.0（additive 并入未发布版本）：新增第 21 组合根 NovaAIReport（Composite.LayoutShell），
#   整批单次重签；总数 146→147，LayoutShell 20→21，decorative 84→85，旧 146 类型逐字不变
EXPECTED_MODULES = {"Nova.Controls": 93, "Nova.Behaviors": 13,
                    "Nova.Services": 16, "Nova.Design": 4,
                    "Nova.Composite.LayoutShell": 21}
EXPECTED_TOTAL = 147


@pytest.fixture(scope="module")
def manifest() -> dict:
    assert MANIFEST.exists(), f"缺少冻结清单：{MANIFEST}（跑 scripts/gen_api_freeze.py）"
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


@pytest.fixture(scope="module")
def current() -> dict:
    return gaf.collect()


# ── 1. 清单自洽 ──────────────────────────────────────────────────────
def test_manifest_schema(manifest):
    assert manifest["schema"] == "nova-api-freeze/1"
    assert manifest["package"] == "pyside-nova"
    assert manifest["apiVersion"] == "1.6.0"
    assert manifest["baseline"] == "Quasar 2.35.5"


def test_manifest_counts(manifest):
    assert manifest["counts"]["total"] == EXPECTED_TOTAL
    assert manifest["counts"]["modules"] == EXPECTED_MODULES
    a11y = manifest["counts"]["a11y"]
    assert sum(a11y.values()) == EXPECTED_TOTAL
    assert a11y == {"decorative": 85, "interactive": 33, "semantic": 29}


def test_manifest_fingerprint_self_consistent(manifest):
    """指纹必须由清单内容算出——手改清单而不重算 = 门禁必须发现。"""
    recomputed = gaf.fingerprint({"modules": manifest["modules"],
                                  "types": manifest["types"]})
    assert recomputed == manifest["fingerprint"]


def test_manifest_matches_current_surface(manifest, current):
    rep = caf.Report(quiet=True)
    caf.diff_surface(manifest, current, rep)
    assert not rep.breaking, "破坏性漂移：" + "；".join(rep.breaking)
    assert not rep.additive, "增量漂移：" + "；".join(rep.additive)


def test_manifest_excludes_private_members(manifest):
    """`_` 前缀是私有实现，不得进冻结面（否则重构即破坏 API）。"""
    leaked = [f"{t}.{sig}" for t, info in manifest["types"].items()
              for group in ("props", "signals", "methods")
              for sig in info[group] if caf._sig_name(sig).startswith("_")]
    assert not leaked, f"私有成员泄漏进冻结面：{leaked[:5]}"


def test_manifest_covers_every_export(manifest, current):
    assert set(manifest["types"]) == set(current["types"])
    for full, info in manifest["types"].items():
        assert info["props"] is not None and isinstance(info["props"], list)
        assert info["a11y"] in ("interactive", "semantic", "decorative"), full


# ── 2. 门禁必须能变红（反例三连，防假门禁） ──────────────────────────
def _buckets(frozen: dict, mutated: dict) -> tuple[list[str], list[str]]:
    rep = caf.Report(quiet=True)
    caf.diff_surface(frozen, mutated, rep)
    return rep.breaking, rep.additive


def test_gate_detects_removed_type(manifest, current):
    mutated = copy.deepcopy(current)
    first = sorted(mutated["types"])[0]
    del mutated["types"][first]
    breaking, additive = _buckets(manifest, mutated)
    assert any("删除" in b or "取消导出" in b for b in breaking), breaking
    assert not additive


def test_gate_detects_added_member(manifest, current):
    mutated = copy.deepcopy(current)
    target = "Nova.Controls.NovaBtn"
    mutated["types"][target]["props"].append("brandNewKnob:string")
    breaking, additive = _buckets(manifest, mutated)
    assert any("新增属性" in a for a in additive), additive
    assert not breaking


def test_gate_detects_changed_signature(manifest, current):
    mutated = copy.deepcopy(current)
    target = "Nova.Controls.NovaBtn"
    props = mutated["types"][target]["props"]
    props[props.index("text:string")] = "text:int"
    breaking, _ = _buckets(manifest, mutated)
    assert any("签名变更" in b for b in breaking), breaking


def test_gate_detects_moved_type(manifest, current):
    mutated = copy.deepcopy(current)
    mutated["types"]["Nova.Controls.NovaBtn"]["module"] = "Nova.Behaviors"
    breaking, _ = _buckets(manifest, mutated)
    assert any("模块变更" in b for b in breaking), breaking


# ── 3. 命名红线与清单纪律 ────────────────────────────────────────────
def test_hygiene_clean_on_repo(current):
    rep = caf.Report(quiet=True)
    caf.check_hygiene(current, rep)
    assert not rep.hygiene, "纪律违规：\n" + "\n".join(rep.hygiene)


def test_hygiene_flags_forbidden_props(tmp_path):
    """反例：`on*` 前缀 + Rectangle 根类型上的 `color` + onDestroyed 必须被抓。"""
    qml_dir = tmp_path / "src" / "pyside_nova" / "qml"
    (qml_dir / "Nova" / "Controls").mkdir(parents=True)
    (qml_dir / "Nova" / "Controls" / "NovaBad.qml").write_text(
        "// src/pyside_nova/qml/Nova/Controls/NovaBad.qml\n"
        "// 反例样本\n"
        "import QtQuick\n"
        "Rectangle {\n"
        "    property string onClick: \"x\"\n"
        "    property color color: \"red\"\n"
        "    Component.onDestroyed: console.log(1)\n"
        "}\n", encoding="utf-8")
    fake = {"types": {"Nova.Controls.NovaBad": {
        "module": "Nova.Controls", "file": "Nova/Controls/NovaBad.qml",
        "kind": "component", "a11y": "decorative",
        "props": ["onClick:string", "color:color"], "signals": [], "methods": [],
    }}}
    rep = caf.Report(quiet=True)
    caf.check_hygiene(fake, rep, root=tmp_path)
    joined = "\n".join(rep.hygiene)
    assert "on*" in joined
    assert "撞名" in joined
    assert "onDestroyed" in joined


def test_qmldir_discipline_no_double_slash():
    for layer in gaf.LAYERS:
        text = (gaf.QML_ROOT / layer / "qmldir").read_text(encoding="utf-8")
        assert "//" not in text, f"{layer}/qmldir 使用了 // 注释（坑位 4）"


def test_qmldir_exports_are_version_1_0():
    for layer in gaf.LAYERS:
        for line in (gaf.QML_ROOT / layer / "qmldir").read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith(caf.QMLDIR_SKIP):
                continue
            parts = line.split()
            offset = 1 if parts[0] == "singleton" else 0
            assert parts[offset + 1] == "1.0", f"{layer}/qmldir 导出版本非 1.0：{line}"


def test_every_type_file_is_named_after_its_type(manifest):
    for full, info in manifest["types"].items():
        name = full.rsplit(".", 1)[1]
        assert Path(info["file"]).stem == name, f"{full} 文件名不匹配：{info['file']}"


def test_singletons_declare_pragma(manifest):
    missing = []
    for full, info in manifest["types"].items():
        if info["kind"] != "singleton":
            continue
        text = (ROOT / "src" / "pyside_nova" / "qml" / info["file"]).read_text(encoding="utf-8")
        if "pragma Singleton" not in text:
            missing.append(full)
    assert not missing, f"单例缺 pragma Singleton：{missing}"


def test_no_type_name_collides_across_modules(manifest):
    seen: dict[str, str] = {}
    for full, info in manifest["types"].items():
        name = full.rsplit(".", 1)[1]
        assert name not in seen, f"{name} 同时导出在 {seen[name]} 与 {info['module']}"
        seen[name] = info["module"]


# ── 4. 文档与 CLI ────────────────────────────────────────────────────
def test_signed_doc_records_fingerprint(manifest):
    text = DOC.read_text(encoding="utf-8")
    assert manifest["fingerprint"] in text, "签署文档未记录当前指纹（未重签）"
    assert "冻结口径" in text and "签署结论" in text
    assert f"{EXPECTED_TOTAL} 类型" in text or f"**{EXPECTED_TOTAL}**" in text


def test_signed_doc_lists_every_type(manifest):
    text = DOC.read_text(encoding="utf-8")
    missing = [full.rsplit(".", 1)[1] for full in manifest["types"]
               if f"`{full.rsplit('.', 1)[1]}`" not in text]
    assert not missing, f"签署文档缺类型：{missing[:5]}"


def test_gate_cli_exit_zero():
    proc = subprocess.run([sys.executable, str(SCRIPTS / "check_api_freeze.py"), "--quiet"],
                          capture_output=True, text=True, cwd=str(ROOT), timeout=180)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "API 冻结门禁通过" in proc.stdout


def test_qmllint_gate_exit_zero():
    proc = subprocess.run([sys.executable, str(SCRIPTS / "check_qmllint.py")],
                          capture_output=True, text=True, cwd=str(ROOT), timeout=300)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "0 error" in proc.stdout


def test_qmllint_zero_errors_and_budget_respected():
    counts, errors, _warnings = cql.run_lint()
    assert not errors, "qmllint 报 error：\n" + "\n".join(errors[:10])
    baseline = json.loads((ROOT / "tests" / "lint-baseline.json").read_text(encoding="utf-8"))
    for cat, cur in counts.items():
        assert cat in baseline["budget"], f"新告警类别未立预算：{cat}"
        assert cur <= baseline["budget"][cat], f"{cat} 超预算：{cur} > {baseline['budget'][cat]}"


# ── 5. RC1 冻结审查修掉的具体缺陷（回归护栏） ────────────────────────
def test_colorpicker_uses_surface_token_not_phantom_background():
    """冻结审查抓到：`NovaTheme.background`（令牌不存在 → 输入框底色丢失）。"""
    src = (ROOT / "src" / "pyside_nova" / "qml" / "Nova" / "Controls"
           / "NovaColorPicker.qml").read_text(encoding="utf-8")
    assert "NovaTheme.surface" in src
    assert "NovaTheme.background" not in src
    hits = [p.relative_to(ROOT).as_posix() for p in list((ROOT / "src").rglob("*.qml"))
            + list((ROOT / "examples").rglob("*.qml"))
            if "NovaTheme.background" in p.read_text(encoding="utf-8", errors="ignore")]
    assert not hits, f"仍在使用不存在的 NovaTheme.background：{hits}"


def test_colorpicker_focus_border_uses_existing_property():
    """冻结审查抓到：`root.tint`（NovaColorPicker 无此属性 → 焦点边框无色）。"""
    src = (ROOT / "src" / "pyside_nova" / "qml" / "Nova" / "Controls"
           / "NovaColorPicker.qml").read_text(encoding="utf-8")
    assert "root.tint" not in src
    assert "NovaTheme.primary" in src


def test_novatext_no_longer_shadows_text_style(manifest):
    """冻结审查抓到：`readonly property var style` 覆盖 Text.style 枚举（基类成员撞名）。"""
    props = manifest["types"]["Nova.Controls.NovaText"]["props"]
    assert not any(p.endswith(" style:var") or p == "ro style:var" for p in props), props
    src = (ROOT / "src" / "pyside_nova" / "qml" / "Nova" / "Controls"
           / "NovaText.qml").read_text(encoding="utf-8")
    assert "_style" in src and "property var style:" not in src


# ── 6. 废弃机制（1.0 冻结策略的运行时载体） ─────────────────────────
_PROBE = """
import QtQuick
import Nova.Design
QtObject {
    function once(key, msg) { return NovaUtils.logOnce(key, msg) }
    function deprecate(t, a, repl, rm) { return NovaUtils.deprecate(t, a, repl, rm) }
}
"""


@pytest.fixture(scope="module")
def probe(qml_engine):
    from PySide6.QtCore import QUrl
    from PySide6.QtQml import QQmlComponent
    comp = QQmlComponent(qml_engine)
    comp.setData(_PROBE.encode("utf-8"), QUrl("qrc:/api-freeze-probe.qml"))  # 坑位 48：单斜杠
    obj = comp.create()
    assert obj is not None, [e.toString() for e in comp.errors()]
    yield obj
    obj.deleteLater()


def test_log_once_speaks_only_first_time(probe):
    key = "freeze.test.logOnce"
    assert probe.once(key, "hello") is True
    assert probe.once(key, "hello again") is False


def test_deprecate_is_once_per_api(probe):
    assert probe.deprecate("NovaOld", "legacy", "NovaNew", "2.0") is True
    assert probe.deprecate("NovaOld", "legacy", "NovaNew", "2.0") is False
    # 不同 API 各自独立（key = 类型.成员）
    assert probe.deprecate("NovaOld", "other", "NovaNew", "2.0") is True
