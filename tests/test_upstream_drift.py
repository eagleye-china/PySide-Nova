# tests/test_upstream_drift.py
# T30 / P0 止血：Quasar 2.35.6 → 2.36.0 上游跟进的机检固化
"""上游漂移门专项：把「2.35.6 三条 humanStorageSize 欠账」与「7 类变更分类器」钉死。

法源：
- 上游实现：quasar@2.36.0 ``ui/src/utils/format/format.js``（tag 与 dev 双份逐字一致）
- 上游期望表：``ui/src/utils/format/format.test.js``
- 变更登记：``upstream/changes/2.35.5-2.36.0.json``（GitHub Releases + npm 双源核实）
- 基线事实源：``upstream/quasar-pin.json``（pinned 2.35.5 / observed 2.36.0 · CSA D4）

本文件三条主用例即 P0 DoD 的「三条边界用例」；其余为官方期望表抽样、回归保护
（``test_smoke.py:2151-2152`` 的 1536 / 1023）、TypeError 契约与分类器端到端验证。
"""
from __future__ import annotations

import importlib.util
import os
import re
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"

# QML 探针：所有期望值一次性作为 property 求值；throw 契约在 onCompleted 里 try/catch
# 落到 property（属性绑定里抛异常只会退化成空串 + warning，无法判定，见坑位 68 同源）。
PROBE_QML = """
import QtQuick
import Nova.Design

QtObject {
    // ── 2.35.6 #18604 三条欠账边界（P0 止血主用例）──
    property string b1: NovaUtils.format.humanStorageSize(1048575)
    property string b2: NovaUtils.format.humanStorageSize(-2048)
    property string b3: NovaUtils.format.humanStorageSize("500")

    // ── 官方 format.test.js 期望表抽样 ──
    property string t1: NovaUtils.format.humanStorageSize(1023.96)
    property string t2: NovaUtils.format.humanStorageSize(" 1536 ")
    property string t3: NovaUtils.format.humanStorageSize("2048")
    property string t4: NovaUtils.format.humanStorageSize(1024 * 1024 * 1024)
    property string t5: NovaUtils.format.humanStorageSize(1024 * 1024 - 1)
    property string t6: NovaUtils.format.humanStorageSize(-1023.96)
    property string t7: NovaUtils.format.humanStorageSize(1023.5, 0)
    property string t8: NovaUtils.format.humanStorageSize(1024 * 2.25, 2)
    property string t9: NovaUtils.format.humanStorageSize(-50)
    property string t10: NovaUtils.format.humanStorageSize(100, 3)

    // ── 回归：现有 test_smoke.py 的 1536 / 1023 用例零影响 ──
    property string r1: NovaUtils.format.humanStorageSize(1536)
    property string r2: NovaUtils.format.humanStorageSize(1023)

    // ── TypeError 契约：非 number / 非数字串 / NaN 一律抛 ──
    property string errNan: ""
    property string errNull: ""
    property string errEmpty: ""
    property string errSpace: ""
    property string errAbc: ""
    property string errBool: ""
    property string errArray: ""
    property string okNumericString: ""

    Component.onCompleted: {
        errNan = _guard(NaN)
        errNull = _guard(null)
        errEmpty = _guard("")
        errSpace = _guard(" ")
        errAbc = _guard("abc")
        errBool = _guard(true)
        errArray = _guard([2048])
        okNumericString = _guard("500")
    }

    function _guard(v) {
        try {
            return "OK:" + NovaUtils.format.humanStorageSize(v)
        } catch (e) {
            return "ERR:" + String(e.name)
        }
    }
}
"""


@pytest.fixture(scope="module")
def upstream_env(qml_engine):
    """单引擎探针（conftest 的 qml_engine 为 session 单例，坑位 49 稳定性前提）。"""
    from PySide6.QtCore import QUrl
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQml import QQmlComponent

    comp = QQmlComponent(qml_engine)
    comp.setData(PROBE_QML.encode("utf-8"), QUrl("qrc:/nova-upstream-drift.qml"))
    obj = comp.create()
    assert obj is not None, [e.toString() for e in comp.errors()]
    obj.setParent(QGuiApplication.instance())  # 强引用防 QML 引擎 GC（坑位 77 同源）
    return obj


def _drift_module():
    """以文件方式加载脚本（scripts/ 不在 sys.path，且不能触发其 __main__）。"""
    spec = importlib.util.spec_from_file_location(
        "check_upstream_drift", SCRIPTS / "check_upstream_drift.py")
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


# ── P0 DoD 三条主用例 ───────────────────────────────────────

def test_human_storage_size_boundary(upstream_env):
    """2.35.6 #18604 ①：边界按显示值判单位，1048575 → 1.0MB（旧实现 1024.0KB）。"""
    assert upstream_env.property("b1") == "1.0MB"
    assert upstream_env.property("t5") == "1.0MB"          # 1024*1024-1
    assert upstream_env.property("t1") == "1.0KB"           # 1023.96 → 显示值 1024.0
    assert upstream_env.property("t6") == "-1.0KB"          # -1023.96
    assert upstream_env.property("t7") == "1KB"             # 1023.5 / decimals=0


def test_human_storage_size_negative(upstream_env):
    """2.35.6 #18604 ②：按量级选单位，-2048 → -2.0KB（旧实现滞留 -2048.0B）。"""
    assert upstream_env.property("b2") == "-2.0KB"
    assert upstream_env.property("t9") == "-50.0B"          # 负值且未达边界
    assert upstream_env.property("t2") == "1.5KB"           # 带空格数字串


def test_human_storage_size_numeric_string(upstream_env):
    """2.35.6 #18604 ③：数字字符串一律接受，'500' → 500.0B（旧实现抛 TypeError）。"""
    assert upstream_env.property("b3") == "500.0B"
    assert upstream_env.property("t3") == "2.0KB"           # '2048'
    assert upstream_env.property("okNumericString") == "OK:500.0B"


def test_human_storage_size_official_table_sample(upstream_env):
    """官方 format.test.js 其余抽样：GB 单位、decimals 语义、三位小数。"""
    assert upstream_env.property("t4") == "1.0GB"
    assert upstream_env.property("t8") == "2.25KB"          # 2304 / decimals=2
    assert upstream_env.property("t10") == "100.000B"       # 100 / decimals=3


def test_human_storage_size_throws_type_error(upstream_env):
    """非 number / 非数字串 / NaN 一律 TypeError（NaN 旧实现返回 'NaNB'）。"""
    for key in ("errNan", "errNull", "errEmpty", "errSpace", "errAbc", "errBool", "errArray"):
        assert upstream_env.property(key) == "ERR:TypeError", key


def test_human_storage_size_existing_smoke_regression(upstream_env):
    """回归保护：test_smoke.py:2151-2152 的 1536 / 1023 语义零影响。"""
    assert upstream_env.property("r1") == "1.5KB"
    assert upstream_env.property("r2") == "1023.0B"


# ── 分类器与离线门端到端 ───────────────────────────────────

def test_classifier_matches_all_five_real_changes():
    """分类器对 2.35.6 三条 + 2.36.0 两条真实变更分类正确（5/5）。"""
    mod = _drift_module()
    pin = mod.load_pin()
    changes = mod.load_changes(pin)
    assert len(changes["changes"]) == 5
    expected = {
        "2.35.6-format-hss-boundary": "C1",
        "2.35.6-format-hss-negative": "C1",
        "2.35.6-format-hss-input": "C1",
        "2.36.0-lang-tg": "C3",
        "2.36.0-directives-ts-types": "C4",
    }
    for c in changes["changes"]:
        assert mod.classify(c) == c["category"] == expected[c["id"]], c["id"]


def test_classifier_covers_all_seven_categories():
    """七类规则都有落点，不是只针对本轮 5 条硬编码（规则表可外推）。"""
    mod = _drift_module()
    cases = [
        ({"scope": "api", "change": "add", "target": "QTable.props.newProp"}, "C0"),
        ({"scope": "utils", "change": "behavior"}, "C1"),
        ({"scope": "component", "type": "feat", "change": "new"}, "C2"),
        ({"scope": "lang", "change": "new"}, "C3"),
        ({"scope": "types", "change": "typing"}, "C4"),
        ({"security": True, "scope": "plugin", "change": "behavior"}, "C5"),
        ({"scope": "docs", "change": "modify"}, "C6"),
    ]
    for payload, expected in cases:
        assert mod.classify(payload) == expected, payload


def test_offline_gate_is_green_and_pin_unchanged():
    """离线门 PASS；CSA D4：pinned 仍 2.35.5、observed 登记 2.36.0；6 处口径零漂移。"""
    mod = _drift_module()
    pin = mod.load_pin()
    report = mod.evaluate(pin, mod.load_changes(pin))
    assert report["status"] == "PASS", report
    assert report["pinned_version"] == "2.35.5"
    assert report["observed_version"] == "2.36.0"
    assert report["total_changes"] == 5
    assert report["by_category"] == {"C1": 3, "C3": 1, "C4": 1}
    assert report["blocking_open"] == []
    assert report["classification_mismatches"] == []
    assert all(b["ok"] for b in report["baseline_consistency"]), report["baseline_consistency"]


def test_c1_changes_all_resolved_with_test_ids():
    """C1 是 P0 阻断类：三条必须全部销号且各带机检用例（机检固化 100%）。"""
    mod = _drift_module()
    pin = mod.load_pin()
    c1 = [c for c in mod.load_changes(pin)["changes"] if mod.classify(c) == "C1"]
    assert len(c1) == 3
    for c in c1:
        assert c["status"] == "resolved", c["id"]
        assert c["test_ids"], c["id"]
    bound = {t for c in c1 for t in c["test_ids"]}
    assert bound == {
        "test_human_storage_size_boundary",
        "test_human_storage_size_official_table_sample",
        "test_human_storage_size_existing_smoke_regression",
        "test_human_storage_size_negative",
        "test_human_storage_size_numeric_string",
        "test_human_storage_size_throws_type_error",
    }


def test_c1_test_ids_are_real_test_functions():
    """登记的 test_id 必须真实存在于本模块 —— 法源链不留悬空（机检化）。"""
    mod = _drift_module()
    pin = mod.load_pin()
    defined = set(re.findall(r"^def (test_\w+)\(",
                             Path(__file__).read_text(encoding="utf-8"), re.MULTILINE))
    bound = {
        t for c in mod.load_changes(pin)["changes"]
        if mod.classify(c) in mod.BLOCKING for t in c.get("test_ids", [])
    }
    assert bound, "阻断类必须绑定机检用例"
    assert bound <= defined, f"悬空 test_id：{sorted(bound - defined)}"
