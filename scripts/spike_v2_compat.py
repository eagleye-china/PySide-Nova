# scripts/spike_v2_compat.py
# v2.0 双轨兼容架构 Qt 技术可行性实测（法源 docs/prescript/SPEC_V2_COMPAT.md §1）
"""可复现 spike：在临时 import path 造最小 QML 模块，验证兼容层形态。

用 QQmlComponent + 单 QGuiApplication(offscreen)，不触碰仓库任何文件。
七形态：A 基线 / B 同 URI 子目录 / C 新 URI ../ 转发 / D 薄转发包装（应弃用）/
E 双 URI 共存 / F 物理重构+双轨 / H 旧 URI ../../ 转发到新顶层目录。

运行：python scripts/spike_v2_compat.py   （需 PySide6，QT_QPA_PLATFORM 自动 offscreen）
"""
from __future__ import annotations

import os
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import tempfile
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent, QQmlEngine

app = QGuiApplication.instance() or QGuiApplication([])
root = Path(tempfile.mkdtemp(prefix="nova-v2-spike-"))
nova = root / "Nova"
impl = ('import QtQuick\nimport Nova.Services 1.0\n'
        'Item { property string tag: "REAL"; property color c: NovaTheme.primary }\n')

# 依赖模块（绝对 URI，验证物理搬家不影响内部 import）
svc = nova / "Services"
svc.mkdir(parents=True)
(svc / "NovaTheme.qml").write_text(
    'pragma Singleton\nimport QtQuick\nQtObject { property color primary: "#ff0000" }\n',
    encoding="utf-8")
(svc / "qmldir").write_text(
    'module Nova.Services\nsingleton NovaTheme 1.0 NovaTheme.qml\n', encoding="utf-8")

# 集合 1：A / B / C / D / E（文件在旧位置）
ctrl = nova / "Controls"
ctrl.mkdir()
(ctrl / "NovaInput.qml").write_text(impl, encoding="utf-8")
sub = ctrl / "Sub"          # 纯技术示意：相对子路径导出，非产品目录分类
sub.mkdir()
(sub / "NovaText.qml").write_text(
    'import QtQuick\nItem { property string tag: "SUB" }\n', encoding="utf-8")
(ctrl / "qmldir").write_text(
    'module Nova.Controls\nNovaInput 1.0 NovaInput.qml\n'
    'NovaText 1.0 Sub/NovaText.qml\n', encoding="utf-8")

form = ctrl / "Form"
form.mkdir()
(form / "qmldir").write_text(
    'module Nova.Controls.Form\nNovaInput 1.0 ../NovaInput.qml\n', encoding="utf-8")

alias = ctrl / "Alias"
alias.mkdir()
(alias / "qmldir").write_text(
    'module Nova.Controls.Alias\nNovaInput 1.0 NovaInput.qml\n', encoding="utf-8")
(alias / "NovaInput.qml").write_text(
    'import QtQuick\nimport Nova.Controls 1.0 as Base\n'
    'Item { property string tag: "WRAPPER"; Base.NovaInput { } }\n', encoding="utf-8")

# 集合 2：F 物理重构（文件搬进 Form/）+ 双轨兼容
c2 = nova / "C2Controls"
c2.mkdir()
f2 = c2 / "Form"
f2.mkdir()
(f2 / "NovaInput.qml").write_text(impl, encoding="utf-8")
(c2 / "qmldir").write_text(
    'module Nova.C2Controls\nNovaInput 1.0 Form/NovaInput.qml\n', encoding="utf-8")
(f2 / "qmldir").write_text(
    'module Nova.C2Controls.Form\nNovaInput 1.0 NovaInput.qml\n', encoding="utf-8")

# 集合 3：H 旧 URI ../../ 转发到新顶层目录（全量 v2.0 路线）
pc = nova / "Prescient" / "Carriers"
pc.mkdir(parents=True)
(pc / "NovaDesktop.qml").write_text(
    'import QtQuick\nItem { property string tag: "REAL-DESKTOP" }\n', encoding="utf-8")
ls = nova / "Composite" / "LayoutShell"
ls.mkdir(parents=True)
(ls / "qmldir").write_text(
    'module Nova.Composite.LayoutShell\n'
    'NovaDesktop 1.0 ../../Prescient/Carriers/NovaDesktop.qml\n', encoding="utf-8")

eng = QQmlEngine()
eng.addImportPath(str(root))
base = QUrl.fromLocalFile(str(root / "probe.qml"))


def probe(label: str, qml: str, expect: str | None) -> bool:
    comp = QQmlComponent(eng)
    comp.setData(qml.encode("utf-8"), base)
    if comp.status() != QQmlComponent.Status.Ready:
        print(f"[ERROR] {label:<42} {comp.errorString().strip().splitlines()[:2]}")
        return False
    obj = comp.create()
    tag = obj.property("tag") if obj else None
    ok = (tag == expect) if expect is not None else (obj is not None)
    print(f"[{'PASS' if ok else 'FAIL'}] {label:<42} tag={tag!r}")
    return ok


print("v2.0 兼容层 Qt spike · PySide6 · offscreen")
print("=" * 66)
checks = {
    "A 旧 URI 平铺导出（基线）":
        probe("A old URI flat", "import Nova.Controls 1.0\nNovaInput { }\n", "REAL"),
    "B 同一 URI 相对子路径（1.2.0 范式）":
        probe("B same URI subdir", "import Nova.Controls 1.0\nNovaText { }\n", "SUB"),
    "C 新 URI ../ 跨目录转发（同一实现）":
        probe("C new URI ../ forward",
              "import Nova.Controls.Form 1.0\nNovaInput { }\n", "REAL"),
    "D 薄转发包装（类型身份被改 → 弃用）":
        probe("D thin wrapper (identity changed)",
              "import Nova.Controls.Alias 1.0\nNovaInput { }\n", "WRAPPER"),
    "E 双 URI 共存":
        probe("E dual-URI coexist",
              "import QtQuick\nimport Nova.Controls 1.0\n"
              "import Nova.Controls.Form 1.0 as Form\n"
              "Item { NovaInput { } Form.NovaInput { } }\n", None),
    "F1 物理搬迁后旧 URI（子路径反指）":
        probe("F1 old URI after physical move",
              "import Nova.C2Controls 1.0\nNovaInput { }\n", "REAL"),
    "F2 物理搬迁后新 URI（平铺）":
        probe("F2 new URI after physical move",
              "import Nova.C2Controls.Form 1.0\nNovaInput { }\n", "REAL"),
    "H 旧 URI ../../ 转发到新顶层目录（全量路线）":
        probe("H old URI ../../ forward",
              "import Nova.Composite.LayoutShell 1.0\nNovaDesktop { }\n", "REAL-DESKTOP"),
}
print("=" * 66)
bad = [k for k, v in checks.items() if not v]
for k, v in checks.items():
    print(f"  {'PASS' if v else 'FAIL'}  {k}")
print()
if bad:
    print(f"结论：FAIL · {len(bad)} 形态未通过")
    raise SystemExit(1)
print("结论：PASS · 7/7 · F（物理重构+双轨+单一事实源）与 "
      "H（9 大顶层目录重构 + 旧 URI 零破坏）均技术可行；D 包装形态弃用")
