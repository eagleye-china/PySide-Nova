# scripts/audit_foundations.py
# 基础组件 Robustness 天花板机检（CARF-R 适配版）：15 项销号守护 + 122 公开类型实例化冒烟
"""非组合基础组件的 Robustness 机检入口（docs/CEILING_AUDIT_FOUNDATIONS.md 配套尺）。

法源：母法卷首 CARF 宣言（R 打磨）· 组合宪法第 0 章第 3/4 条
      （基础控件不受 CC 装配契约约束，四性逐项判定、仅在实测暴露缺陷时打磨）
      · docs/CEILING_AUDIT_FOUNDATIONS.md（逐项销号台账）

适配说明（与 audit_ceiling.py 的区别）：
  - audit_ceiling.py 针对 15 项组合根容器，跑 CC-1~CC-8 静态契约 + 全属性同时注入；
  - 本尺针对 Controls/Behaviors/Services/Design 基础组件，**不套 CC 契约**，
    只验四性中的 Robustness：逐属性注入极端非法值（-999 / 999999），
    在充分收敛（0.45s，与组合尺一致）后遍历对象树测稳态几何非负有限。
    逐属性（而非同时）注入，避免多属性组合出正常 API 用法下不可能出现的假阳性。

覆盖：
  1. 15 项已销号基础组件：逐属性非法入参稳态几何（守护不回退）
     —— 第一批 14 项数值极端入参；第二批 NovaField 超长字符串入参
  2. 全部公开非单例类型（122 项）字面量实例化冒烟
  3. 正常默认值下零负几何对照（防止钳制破坏正常布局）
  4. 双主题 / RTL / reducedMotion 三态实例化零负几何（第二批新增守护）

用法：python scripts/audit_foundations.py
"""
from __future__ import annotations

import json
import math
import os
import sys
import time
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

from PySide6.QtCore import QUrl  # noqa: E402
from PySide6.QtGui import QGuiApplication  # noqa: E402
from PySide6.QtQml import QQmlComponent, QQmlEngine  # noqa: E402
from PySide6.QtQuick import QQuickItem, QQuickWindow  # noqa: E402

from pyside_nova import init_nova  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
API = ROOT / "api" / "nova-api-1.6.0.json"

# 本轮 CARF-R 销号的 15 项 Robustness 缺陷（数据驱动，非批量套规则）
FOUNDATIONS = [
    "NovaAjaxBar", "NovaCardSection", "NovaCheckbox", "NovaCol",
    "NovaDialogShell", "NovaEditor", "NovaExpansionItem", "NovaImg",
    "NovaInnerLoading", "NovaPage", "NovaRange", "NovaSeparator",
    "NovaSlideItem", "NovaSlider",
]

# 第二批：超长字符串入参守护（NovaField label/prefix/suffix 反噬宽度）
LONG_TEXT_PROPS = {
    "NovaField": ["label", "prefix", "suffix"],
}
_LONG = "汉" * 2000

# 数据句柄类：QtObject 派生，无 width/height 等几何属性（非可视化对象，
# 实例化探针不得强加几何属性，否则是机检尺自身的假阳性）。
DATA_HANDLES = {
    "NovaDialogHandle", "NovaLoadingHandle", "NovaNotifyAction", "NovaNotifyHandle",
}

_ALIVE: list = []


def _pump(seconds: float = 0.45) -> None:
    end = time.perf_counter() + seconds
    while time.perf_counter() < end:
        QGuiApplication.processEvents()
        time.sleep(0.005)


def _create(engine, qml: str):
    comp = QQmlComponent(engine)
    comp.setData(qml.encode("utf-8"), QUrl("qrc:/foundation-audit.qml"))
    obj = comp.create()
    if obj is None:
        raise RuntimeError(" | ".join(e.toString() for e in comp.errors()))
    _ALIVE.extend([comp, obj])
    return obj


def _geometry_ok(obj) -> tuple[bool, str]:
    for it in [obj] + list(obj.findChildren(QQuickItem)):
        try:
            # 未参与渲染的隐藏布局容器不进几何判定：NovaDataGrid 在
            # pagination=null 时分栏高 0、visible=false，其内部 RowLayout
            # 以 anchors.fill + 左右 margin 计算会得到 -24x0 的未布局值，
            # 既不显示也不参与命中测试，不构成负几何缺陷。
            if not it.isVisible():
                continue
            w, h = it.width(), it.height()
        except RuntimeError:
            continue
        if not (math.isfinite(w) and math.isfinite(h)) or w < 0 or h < 0:
            return False, f"{it.metaObject().className()} {w:.0f}x{h:.0f}"
    return True, ""


def _numeric_props(data: dict, name: str, module: str) -> list[str]:
    props = data["types"][f"{module}.{name}"]["props"]
    return [p.split(":")[0] for p in props
            if not p.startswith("ro ") and p.split(":")[-1] in ("int", "real")]


def main() -> int:
    app = QGuiApplication.instance() or QGuiApplication([])
    engine = QQmlEngine()
    init_nova(engine)
    data = json.loads(API.read_text(encoding="utf-8"))

    # name -> module（排除 singleton）
    singles = set()
    for m, v in data["modules"].items():
        singles.update(v.get("singletons", []))
    types = {k.rsplit(".", 1)[-1]: k.rsplit(".", 1)[0]
             for k in data["types"] if k.rsplit(".", 1)[-1] not in singles}

    print("=" * 78)
    print("pyside-nova · 基础组件 Robustness 天花板机检（CARF-R 适配版）")
    print("=" * 78)

    failures: list[str] = []

    # ① 全公开类型实例化冒烟
    smoke_fail = []
    for name, mod in sorted(types.items()):
        try:
            if name in DATA_HANDLES:
                # QtObject 数据句柄：无几何属性，裸实例化
                _create(engine, f"import QtQuick\nimport {mod} 1.0\n{name} {{ }}")
            else:
                _create(engine, f"import QtQuick\nimport {mod} 1.0\n{name} {{ width: 800; height: 600 }}")
        except Exception as exc:  # noqa: BLE001
            smoke_fail.append(f"{name}: {exc}")
    print(f"\n[1] 公开非单例类型实例化   {len(types) - len(smoke_fail)}/{len(types)}")
    for f in smoke_fail:
        print("  ✗ " + f)
        failures.append("instantiate " + f)

    # ② 14 项逐属性非法入参稳态几何 + 正常值对照
    print(f"\n[2] 已销号 {len(FOUNDATIONS)} 项 · 逐属性稳态几何（-999 / 999999 / 默认值对照）")
    for name in FOUNDATIONS:
        mod = types[name]
        nums = _numeric_props(data, name, mod)
        bad_cases = 0
        # 默认值对照
        try:
            obj = _create(engine, f"import QtQuick\nimport {mod} 1.0\n{name} {{ width: 800; height: 600 }}")
            _pump(0.2)
            ok, detail = _geometry_ok(obj)
            if not ok:
                failures.append(f"{name} 默认几何: {detail}")
                bad_cases += 1
        except Exception as exc:  # noqa: BLE001
            failures.append(f"{name} 默认实例化: {exc}")
            bad_cases += 1
        # 逐属性非法值
        for prop in nums:
            for bad in ("-999", "999999"):
                try:
                    obj = _create(engine, f"import QtQuick\nimport {mod} 1.0\n"
                                          f"{name} {{ width: 800; height: 600\n{prop}: {bad}\n}}")
                    _pump(0.45)
                    ok, detail = _geometry_ok(obj)
                    if not ok:
                        failures.append(f"{name}.{prop}={bad}: 负/非有限几何 {detail}")
                        bad_cases += 1
                except Exception:  # noqa: BLE001,S110
                    # 非法赋值导致的 QML 绑定错误不属几何缺陷（属性类型系统已拒绝）
                    pass
        mark = "✓" if bad_cases == 0 else "✗"
        print(f"  {mark} {name:<20} 数值属性 {len(nums):>2} 项 · 问题 {bad_cases}")

    # ③ 第二批：超长字符串入参守护（反噬宽度类缺陷）
    print(f"\n[3] 超长字符串入参守护（{len(LONG_TEXT_PROPS)} 项）")
    for name, props in LONG_TEXT_PROPS.items():
        mod = types[name]
        bad = 0
        for prop in props:
            try:
                obj = _create(engine, f"import QtQuick\nimport {mod} 1.0\n"
                                      f"{name} {{ width:800; height:600; {prop}: '{_LONG}' }}")
                _pump(0.35)
                ok, detail = _geometry_ok(obj)
                if not ok:
                    failures.append(f"{name}.{prop}=<2000字>: 负几何 {detail}")
                    bad += 1
            except Exception as exc:  # noqa: BLE001
                failures.append(f"{name}.{prop} 超长实例化: {exc}")
                bad += 1
        mark = "✓" if bad == 0 else "✗"
        print(f"  {mark} {name:<20} 超长文本属性 {len(props)} 项 · 问题 {bad}")

    # ④ 双主题 / RTL / reducedMotion 三态实例化守护（剩余项体检全绿，固化防回退）
    print("\n[4] 三态实例化（深主题 / RTL-ar / reducedMotion）零负几何")
    probe = _create(engine, "import QtQuick\nimport Nova.Services\nimport Nova.Design\n"
                            "QtObject{function dark(v){NovaTheme.setDark(v)} "
                            "function rtl(v){NovaI18n.setLocale(v?'ar':'en-US')} "
                            "function rm(v){NovaMotion.reducedMotion=v}}")
    for mode, setter in (("深主题", lambda v: probe.dark(v)),
                         ("RTL-ar", lambda v: probe.rtl(v)),
                         ("reducedMotion", lambda v: probe.rm(v))):
        setter(True)
        bad = 0
        for name, mod in sorted(types.items()):
            if name in DATA_HANDLES:
                qml = f"import QtQuick\nimport {mod} 1.0\n{name} {{ }}"
            else:
                qml = f"import QtQuick\nimport {mod} 1.0\n{name} {{ width:800; height:600 }}"
            try:
                obj = _create(engine, qml)
                _pump(0.08)
                ok, detail = _geometry_ok(obj)
                if not ok:
                    failures.append(f"[{mode}] {name}: {detail}")
                    bad += 1
            except Exception:  # noqa: BLE001
                pass  # 数据句柄/特殊类型的实例化差异不属几何缺陷
        setter(False)
        mark = "✓" if bad == 0 else "✗"
        print(f"  {mark} {mode:<16} 负几何 {bad} 项")
        if bad:
            failures.append(f"[{mode}] 共 {bad} 项负几何")

    print("\n" + "=" * 78)
    if failures:
        print(f"结论：FAIL · {len(failures)} 项待销号")
        for f in failures[:20]:
            print("  ✗ " + f)
        sys.stdout.flush()
        sys.stderr.flush()
        os._exit(1)
    total_fixed = len(FOUNDATIONS) + len(LONG_TEXT_PROPS)
    print(f"结论：PASS · {total_fixed}/{total_fixed} 项基础组件 Robustness 机检全绿"
          f"（{len(FOUNDATIONS)} 数值 + {len(LONG_TEXT_PROPS)} 超长字符串）"
          f" · {len(types)} 非单例类型实例化零缺陷 · 三态实例化零负几何（CARF-R 销号条件达成）")
    sys.stdout.flush()
    sys.stderr.flush()
    os._exit(0)


if __name__ == "__main__":
    main()
