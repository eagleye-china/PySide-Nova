# pyside-nova 文档站首页

**pyside-nova** 是面向 **PySide6 / QML** 的企业级 UI 组件库，对标 [Quasar Framework](https://quasar.dev)（v2.35.5 基线逐项对账），
当前版本 **0.16.x**（五期非功能攻坚中）。

```python
import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from pyside_nova import init_nova

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
init_nova(engine)          # 注册 Nova.* QML 导入路径
engine.load("main.qml")    # QML 里: import Nova.Controls
```

## 亮点

| 能力 | 说明 |
|---|---|
| **生态七层** | L0 设计语言 100% / L1 布局 100% / L3 行为 100% / L5 工具 95% / L2 组件 70% / L4 服务 / L6 工程化 |
| **124 个导出类型** | Controls 91 + Behaviors 13 + Services 16 + Design 4，全部登记 a11y 契约 |
| **可访问性 WCAG 2.1 AA** | AA 派生令牌、全键盘路径、焦点环（focus-visible）、静态+运行时双门禁 |
| **国际化 NovaI18n** | locale 切换、CLDR 七语系复数、数字/货币/日期格式化、RTL 双轨镜像 |
| **性能门禁** | 冷启动 ≤800ms / 组件实例化 ≤5ms / 1000 行表格 ≤1700ms（pytest 门禁承载） |
| **视觉回归** | 明暗 × 5 断点 × 全画廊 240 基线 + 像素 diff 门禁 |
| **供应链** | CycloneDX SBOM + OSV CVE 周巡 + 外部输入消毒 |

## 文档导航

- [架构宪法](CONSTITUTION.md) —— 工程纪律唯一权威（12 章）
- [总规划](MASTER_PLAN.md) / [路线图](ROADMAP.md)
- [组件清单](COMPONENTS.md) / [设计令牌](DESIGN_TOKENS.md)
- [国际化指南](I18N.md) · [无障碍](A11Y.md) · [画廊预览](GALLERY.md)
- [Quasar 对账](PARITY.md) / [生态对账](ECOSYSTEM_PARITY.md)

## 一分钟跑通画廊

```bash
pip install pyside-nova
# 克隆仓库后：
python examples/gallery_launch.py    # 24 页组件画廊（明暗主题 / 断点 / i18n / RTL）
```
