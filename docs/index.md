# pyside-nova 文档站首页

**pyside-nova** 是面向 **PySide6 / QML** 的企业级 UI 组件库，对标 [Quasar Framework](https://quasar.dev)（v2.35.5 基线逐项对账），
当前版本 **1.0.1**（1.0.0 GA 之上的 patch 升级，**待 CSA 发布** · **139 个导出类型** · **15 个组合根容器 15/15 天花板销号** · API 冻结指纹 `bfd3d938a2fab7be` 不变）。

> **最高方法论 CARF** — Conceive · Achieve · Refine · Freeze（构想 · 实现 · 打磨 · 封版，终抵巅峰）。
> 六维天花板（**功能 / 质量 / 观感 / 友好度 / 四性**：鲁棒性 · 坚实性 · 艺术性 · 预判性）逐项销号；
> 公共 API 冻结指纹 `bfd3d938a2fab7be` 零漂移，139 类型封版不漂移。

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
| **139 个导出类型** | Controls 91 · Behaviors 13 · Services 16 · Design 4 · **Composite.LayoutShell 15**，全部登记 a11y 契约 |
| **15 个组合根容器** | 主导航 4 / 多栏工作台 3 / 浮层容器 2 / 独立页壳 2 / 多端根壳 3 / AI 对话主窗口 1，六类 15/15 封版 |
| **组合态一致性契约** | CC-1~CC-8 入宪（组合宪法 1.0.0 第 9 章）；一律 `property alias` 槽位、只 emit 不自写宿主状态 |
| **六维天花板 15/15** | CARF-R 全量销号：45 张三态装配图 + `audit_ceiling.py` PASS + 极端非法入参稳态几何 + RTL / reducedMotion |
| **API 冻结零漂移** | `api/nova-api-1.0.0.json` 逐成员签名 + `check_api_freeze.py` 门禁；静态门禁 3/3 · 专项 48/48 |
| **可访问性 WCAG 2.1 AA** | AA 派生令牌、全键盘路径、焦点环（focus-visible）、静态 + 运行时双门禁 |
| **国际化 NovaI18n** | locale 切换、CLDR 七语系复数、数字 / 货币 / 日期格式化、RTL 双轨镜像 |
| **性能门禁** | 冷启动 ≤800ms / 组件实例化 ≤5ms / 1000 行表格 ≤1700ms（pytest 门禁承载） |
| **供应链** | CycloneDX SBOM + OSV CVE 周巡 + 外部输入消毒 |
| **AI-ready** | `docs/ai/` 版本精确离线 API 包 + Nova MCP server 六工具，杜绝「基于训练记忆的幻觉 props」 |

## 文档导航

- **[15 个组合根容器 · 逐组件 API 页](components/index.md)** —— Props / Slots / Events / 依赖组件 / 最小示例 / 三态装配图
- **[45 张三态装配图索引](components/showcase.md)**
- **[CARF-R 15/15 天花板销号台账](layout_shell/CEILING_AUDIT.md)**
- [白皮书：旗舰组件库](white_paper/pyside-nova-旗舰组件库白皮书.md) · [Prescient Layout Shell 封版规范](white_paper/Prescient-LayoutShell-封版规范.md) · [营销版 README 素材](white_paper/pyside-nova-README.md)
- [架构宪法](CONSTITUTION.md)（母法 · 卷首 CARF · 第 0~13 章） / [组合组件宪法](COMPOSITION_CONSTITUTION.md)（1.0.0 · 第 9 章 CC-1~CC-8）
- [组件清单（139 项）](COMPONENT_LIST.md) / [API 冻结清单](API_FREEZE.md) / [设计令牌](DESIGN_TOKENS.md)
- [国际化指南](I18N.md) · [无障碍](A11Y.md) · [无障碍矩阵](A11Y_MATRIX.md) · [画廊预览](GALLERY.md)
- [Quasar 逐项对账](PARITY.md) / [生态七层对账（历史档案）](ECOSYSTEM_PARITY.md)
- [总规划](MASTER_PLAN.md) / [路线图](ROADMAP.md) / [交接快照](SESSION_HANDOFF.md)

## 一分钟跑通画廊

```bash
pip install pyside-nova==1.0.1
# 克隆仓库后：
python examples/gallery_launch.py    # 24 页组件画廊（明暗主题 / 断点 / i18n / RTL）
```
