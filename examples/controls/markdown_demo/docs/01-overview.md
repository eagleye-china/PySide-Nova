# NovaMarkdown · 文档渲染器

> **零第三方依赖**的 Qt 原生 Markdown 渲染器 —— pyside-nova **1.4.0** 新增的只读文档组件。
> 你眼前这一页，**就是由 NovaMarkdown 自己渲染出来的**（本 demo 会加载它自己的使用文档作为第 4 篇示例）。

`NovaMarkdown` 把一段 Markdown 源文本渲染成与 `NovaTheme` 完全同源的文档视图：
标题、强调、列表、表格、围栏代码块、引用、链接、内置大纲侧栏、页内锚点跳转与危险协议拦截。

## 一分钟上手

```qml
import QtQuick
import Nova.Controls
import Nova.Services

NovaMarkdown {
    anchors.fill: parent
    anchors.margins: 20
    showToc: true
    markdown: "# 快速开始\n\n**加粗** · *斜体* · `行内代码`"
}
```

Python 侧只需注册一次模块，然后加载 QML：

```python
from PySide6.QtQml import QQmlApplicationEngine
from pyside_nova import init_nova

engine = QQmlApplicationEngine()
init_nova(engine)
engine.load("main.qml")
```

> 全库唯一依赖仍是 `PySide6>=6.8`。渲染内核是 Qt 自带的 `Text.MarkdownText`（md4c），
> 没有 `markdown-it-py`、没有 `Pygments`、没有 WebEngine，也没有任何 Python 解析器。

## 能力矩阵

| 能力 | 实现方式 | 状态 |
| :--- | :--- | :---: |
| 标题 / 强调 / 列表 / 表格 | `Text.MarkdownText`（CommonMark + 部分 GFM） | ✅ |
| 围栏代码块 | 分块独立 `Text` + 主题化底框 | ✅ |
| 内置大纲侧栏 | `NovaBtn` + 层级过滤 `tocStart / tocEnd` | ✅ |
| 页内锚点跳转 | `scrollToAnchor()` 写 `NovaScrollArea` 的 `contentY` | ✅ |
| 危险协议拦截 | `_safeUrl()` 白名单排除 + `linkBlocked` 信号 | ✅ |
| 明暗主题联动 | 全部颜色 / 字号绑定 `NovaTheme` 令牌 | ✅ |
| 空态 | 无有效块时显示「暂无内容」，绝不白屏 | ✅ |
| 语法高亮 / Mermaid / KaTeX | 由 Qt 内核能力边界决定，不作承诺 | — |

## 语法覆盖

- **加粗**、*斜体*、~~删除线~~、`行内代码` 均按 CommonMark 解析
- 无序列表
  - 支持嵌套层级
- 有序列表
  1. 第一项
  2. 第二项
- 任务列表：
  - [x] 分块渲染
  - [x] 大纲与锚点
  - [ ] 虚拟滚动（能力边界，留给宿主分页）

### 标题层级

左侧「内置大纲」默认只收 **H1~H3**。用左栏的「大纲层级」切换成 H1~H4 或 H1~H6，
可以看到 `#### 四级标题` 与 `##### 五级标题` 被收进大纲 —— 这就是 `tocEnd` 的作用。

#### 四级标题

这一节在默认 `tocEnd: 3` 时不出现在大纲里。

##### 五级标题

同理，五级标题需要 `tocEnd >= 5`。

> **引用块**：`Text.MarkdownText` 原生支持 `>` 引用。
> 组件把连续的引用行合并为一个块，避免逐行拆散导致样式断裂。

## 主题与可访问性

切换到**暗色**再回来：正文颜色会由 `#1F2128` 变为 `#E9EAEF`，无需组件侧重绘逻辑。
组件登记为 a11y `semantic`，`Accessible.role = StaticText`，可读名可用 `a11yLabel` 覆盖。

## 相关链接

- [PySide6 官方文档](https://doc.qt.io/qtforpython/) —— 通过安全校验的外链
- [Qt Quick Text.MarkdownText](https://doc.qt.io/qt-6/qml-qtquick-text.html) —— 渲染内核说明
- 危险协议演练请切到第 3 篇《链接安全演练》，点击其中的红色链接观察 `linkBlocked` 事件
