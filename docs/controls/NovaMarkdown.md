# NovaMarkdown · Markdown 文档渲染器

> **模块** `Nova.Controls` · **a11y** `semantic`（`Accessible.StaticText`）· **pyside-nova 1.7.0** ·
> **API 冻结指纹** `9742de8638251876` · **零第三方依赖**（全库唯一依赖仍是 `PySide6>=6.8`）·
> 公共签名以 `api/nova-api-1.7.0.json` 冻结面为准
>
> **史料（1.4.0 初版，不回改）**：指纹 `37fbbe9ab5806a2a` / `api/nova-api-1.4.0.json`；
> 下方 §1.1 / §9 / §10 的 1.4.0 时点表述按「史料不圆场」原样保留。
> **T22（1.5.0 实现体 · 2026-11-27）**：择优反哺 4 项渲染增益，公共面
> **10 props / 3 signals / 3 methods 逐字不变、冻结指纹零漂移**，见 §4.1 / §9.1 / §10.1。
>
> 本页是**手写使用文档**（`docs/controls/` 不属生成物目录）。组件源码：
> `src/pyside_nova/qml/Nova/Controls/NovaMarkdown.qml`。

---

## 1. 定位与取舍

`NovaMarkdown` 是**只读** Markdown 文档渲染器，用于把一段 Markdown 源文本渲染成与
`NovaTheme` 完全同源的 QML 文档视图：标题、强调、列表、表格、围栏代码块、链接、
内置大纲侧栏、页内锚点跳转、危险协议拦截。

### 1.1 与旧构想稿的裁决（史料不圆场）

本页替换了原同名文档。**原稿是一份独立新工程的构想稿，不是本库文档**，其中：

| 原稿内容 | 与本库事实的冲突 |
|---|---|
| `version = "0.1.0"`、声称「API 已冻结，可直接发布」 | 本库当前 `1.4.0`，冻结面已运行多个版本周期 |
| `nova/` Python 包、`nova/markdown/{config,parser,bridge}.py`、`main.py`、`Main.qml` | 本库是 **5 个 qmldir 模块**的纯 QML 库，无 `nova/` 包、无 Python 解析器 |
| 依赖 `markdown-it-py` / `mdit-py-plugins` / `Pygments` / `linkify-it-py` | 本库 `pyproject.toml` **唯一依赖 `PySide6>=6.8`** |
| `WebEngineView` + `QWebChannel` + `QtWebEngineQuick.initialize()` | 本库不引入 QtWebEngine，也不允许 QML `import QtQuick.Controls` 走 WebEngine 路径 |
| 手写 `ToolBar` / `SplitView` / `ListView` / `THEMES` CSS 字典 | 违反「库组件优先、零手搓」与「`NovaTheme` 是主题唯一事实源」 |
| `config` / `bridge` / `loading` / `theme` / `renderFailed` 等 QML 属性 | 本组件未实现、未导出，不进冻结面 |

**因此不采纳原稿的 Python 解析器 + WebEngine 路线**。原稿作为历史素材保留差异说明，
不回改、不圆场；本页按本库宪法重写为可直接使用的事实文档。

### 1.2 架构决策：为什么是纯 QML

| 维度 | 原构思路线 | 本库路线（1.4.0） | 裁决依据 |
|---|---|---|---|
| 依赖 | 3 个第三方 Python 包 + QtWebEngine | **0**（仅 PySide6 自带 `Text.MarkdownText`） | 宪法：唯一依赖 PySide6 |
| 渲染内核 | `markdown-it-py` → HTML → WebEngine | QML `Text { textFormat: Text.MarkdownText }` | Qt 6 原生 Markdown 导入器（md4c），实测可用 |
| 主题 | JS 侧 `THEMES` 字典 + CSS 变量 | `NovaTheme.surface / textColor / primaryText / fontFamily / bodyLineHeight` 绑定 | 令牌唯一事实源，明暗自动联动 |
| 容器 / 控件 | 手写 `SplitView` / `ListView` / `ItemDelegate` | `NovaScrollArea` + `NovaBtn` | 库组件优先、零手搓 |
| 链接安全 | 正则替换 `href="javascript:..."` | `_safeUrl()` 协议白名单 + `linkBlocked` 信号 | 宿主可监听，不静默吞事件 |
| 降级 | WebEngine 不可用时显示原始文本 | 空态 `暂无内容`，绝不白屏 | 无外部运行时，无降级分支 |

**实测依据**（离屏 Qt Quick 引擎）：`Text.MarkdownText` 可实例化 `QQuickTextImageHandler`，
单段混合 Markdown `contentHeight = 472.0`、`truncated = False`；本组件 10 个分块全部真实渲染，
表格块 `contentHeight = 80.0`。

---

## 2. 导入与最小示例

```qml
import QtQuick
import QtQuick.Window
import Nova.Controls
import Nova.Services

Window {
    width: 900; height: 700; visible: true
    color: NovaTheme.page

    NovaMarkdown {
        anchors.fill: parent
        anchors.margins: 20
        markdown: "# 快速开始\n\n**加粗** · *斜体* · `行内代码`\n\n| 特性 | 状态 |\n|---|---|\n| 零依赖 | ✅ |"
    }
}
```

带大纲侧栏与链接处置：

```qml
NovaMarkdown {
    id: doc
    anchors.fill: parent
    showToc: true          // 左侧 190px 大纲
    tocStart: 1
    tocEnd: 3              // 只收 H1~H3
    markdown: docSource

    onLinkClicked: function(url) { console.log("外链：", url) }
    onLinkBlocked: function(url) { console.warn("已拦截危险协议：", url) }
    onTocReady: function(items) { console.log("大纲条目：", items.length) }
}
```

> `openLinksExternally: true`（默认）时，通过安全校验的链接会同时
> `Qt.openUrlExternally(url)`；若宿主希望完全接管，置 `false` 并只监听 `linkClicked`。

---

## 3. 公共 API（与冻结面逐字一致）

### Props

| 属性 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `markdown` | `string` | `""` | Markdown 源文本，唯一输入；变更自动重解析 |
| `showToc` | `bool` | `false` | 是否显示内置大纲侧栏（宽 190px） |
| `tocStart` | `int` | `1` | 大纲起始标题层级（1~6） |
| `tocEnd` | `int` | `3` | 大纲结束标题层级（1~6） |
| `openLinksExternally` | `bool` | `true` | 安全链接是否自动交给系统打开 |
| `outlined` | `bool` | `true` | 卡片边框与圆角 |
| `baseFontSize` | `int` | `NovaTheme.bodyFontSize` | 正文字号（像素） |
| `a11yLabel` | `string` | `""` | 可读名覆盖；为空时回落「Markdown 文档」 |
| `toc` *(只读)* | `var` | `[]` | `[{level,title,anchor,index}]` |
| `empty` *(只读)* | `bool` | `true` | 无有效块时为真，显示空态 |

### Signals

| 信号 | 参数 | 语义 |
|---|---|---|
| `linkClicked` | `string url` | 通过安全校验的链接被点击（页内 `#anchor` 不触发，直接跳转） |
| `linkBlocked` | `string url` | 危险协议被拦截：`javascript:` / `vbscript:` / `data:` / `file:` |
| `tocReady` | `var items` | 大纲解析完成，携带 `[{level,title,anchor,index}]` |

### Methods

| 方法 | 参数 | 语义 |
|---|---|---|
| `scrollToTop()` | — | 回到文档顶部 |
| `scrollToAnchor(anchor)` | `anchor` | 跳到指定标题锚点（与 `toc[].anchor` 对应） |
| `reload()` | — | 强制重新解析当前 `markdown` |

> 所有实现细节（`_blocks` / `_toc` / `_parse` / `_rebuild` / `_safeUrl` / `_onLink`）
> 一律 `_` 前缀私有，**不进冻结面**，可自由重构而不触发 additive 重签。

---

## 4. 渲染内核与分块策略

`Text.MarkdownText` 只能整体渲染一段文本。若把整篇文档塞进单个 `Text`，
表格、围栏、列表的内部语法虽仍可解析，但组件无法对**单个标题**做锚点定位，
也无法给代码块单独加底框。因此组件按「块」切分：

```
_parse(src)  →  [{kind, text, level, anchor, table?, image?}, ...]
                 kind ∈ heading / fence / table / hr / tasklist / quote / list
                       / image / paragraph
```

- **围栏优先**：遇到 ``` / ~~~ 先整段收拢到闭合行，保证围栏内内容不被按行拆散；
- **标题独立成块**：记录 `level` 与 `anchor`（T22 起 `_slug(title, counter)` 计数器去重，
  不再拼 `blocks.length`，锚点不随前文增删漂移）；
- **表格 / hr / tasklist / 独占图片独立成块**（T22）：`_lineKind()` 严格化，
  表格按「表头 + 分隔行 + 连续数据行」一次收拢；`:::` 容器等仍按普通段落字面显示；
- **同语法聚组**：连续的引用行 / 列表行合并为一块；
- **普通块一个 `Text`**：`textFormat: Text.MarkdownText`、`wrapMode: Text.WordWrap`，
  颜色 / 字号 / 行高全部绑定 `NovaTheme`；**表格块例外**，见 §4.1；
- **`NovaScrollArea` 承载**：`Column` 首尾各留 12px `Item`（坑位 65 口径），
  保证 `childrenRect.height` 含内边距；大纲侧栏同样外包 `NovaScrollArea`（T22，见 §5）；
- **锚点跳转 O(1)**（T22）：`_parse()` 同时产出 `anchorMap` 存入 `_anchorIndex`，
  `scrollToAnchor()` 直接 `itemAt(index)` 命中块、不再遍历 `objectName`；
  `scrollToTop()` 加 `_flick` null 保护。两者仍写 `scroller._flick.contentY`
  （`NovaScrollArea` 为此反哺了 `_flick` 私有只读别名）。

### 4.1 GFM 表格逐格自绘（T22）

Qt `Text.MarkdownText` 对表格支持不稳定，旧实现把整段表格原文塞进一个 `Text`。
T22 改为**逐格渲染**：

```
_extractTable() → {header[], aligns[], allRows[][], colCount}
ColumnLayout ← Repeater(allRows) → RowLayout ← Repeater(该行各列) → Rectangle + Text
```

- 每个单元格独立 `Text`（仍用 `Text.MarkdownText`，单元格内链接可走 `_onLink()`）；
- `aligns` 由分隔行 `:---` / `---:` / `:---:` 解析出 left / right / center；
- 表头行 `surfaceAlt` 底色 + 粗体，数据行 `surface` 底色，1px `outline` 边框；
- **`Layout.fillHeight` + `preferredHeight` 让同行等高、行高随该行最高文字自适应**，
  网格连续且不裁字（坑位 75）。

> 候选稿 v0.17.0 用 `[header].concat(rows)` 直接交给 `Grid`，元素数 = 行数，
> 真机只渲染出对角线格子；T22 反哺时已改为逐行 `RowLayout`，并清除该稿的
> 公共面污染与 TOC 手搓控件（§10.1）。

### 坑位 69 · Repeater 是「视觉子项」

`QQuickRepeater` 创建的 delegate，其 **QObject parent 不挂在 Repeater 下**，
而是作为视觉子项挂在父 `Column` 上。用 `QObject.children()` 遍历只能看到
大纲标题与空态两个 `Text`，会误判「正文没渲染」。

**正确取证口径**：从 `window.contentItem()` 起走 `QQuickItem.childItems()` 视觉树
（且需提前 `import PySide6.QtQuick`，否则 `rootObjects()` 被包装成无 `contentItem()` 的
`QWindow`）。本次验收实测：视觉树 32 个 `QQuickText`，其中 10 个正文块全部可见。

---

## 5. 大纲（TOC）

`showToc: true` 时左侧出现 190px 侧栏，`tocStart / tocEnd` 过滤层级，
条目用库组件 `NovaBtn`（`variant: "flat"` / `size: "sm"` / `dense: true`）渲染，
按 `(level - tocStart) * 10` 缩进，点击调用 `scrollToAnchor(anchor)`。

**T22 起侧栏可滚动**：内容外包 `NovaScrollArea`，`Column.width` 绑
`tocScroller.width` 而非 `parent.width` —— 后者会与 `NovaScrollArea.inner.width`
的 `childrenRect` 互锁产生 `Binding loop`（候选稿真机实测 1 条）。
超过约 15 条大纲时不再被 `clip` 吞掉；首尾各留 6px `Item`（坑位 65 口径）。
条目始终用 `NovaBtn`，不手搓 `Text + MouseArea + Rectangle`。

`toc` 只读属性与 `tocReady(items)` 信号同源，宿主可自行渲染外部目录：

```qml
Repeater {
    model: doc.toc
    NovaBtn {
        text: modelData.title
        onClicked: doc.scrollToAnchor(modelData.anchor)
    }
}
```

---

## 6. 链接与安全

```
onLinkActivated(url) → _onLink(url)
   ├─ 危险协议        → linkBlocked(url)              （不打开、不跳转）
   ├─ "#anchor"       → scrollToAnchor(anchor)        （页内跳转，不发 linkClicked）
   └─ 其他            → linkClicked(url)
                        + openLinksExternally ? Qt.openUrlExternally(url) : 无
```

`_safeUrl()` 用**协议前缀白名单排除**（`javascript:` / `vbscript:` / `data:` / `file:`），
`trim().toLowerCase()` 后比较，避免大小写与前后空白绕过。危险链接只发信号、
绝不执行，宿主可自行记录或提示。

---

## 7. 主题与可访问性

| 视觉面 | 令牌 |
|---|---|
| 卡片底 / 边框 | `NovaTheme.surface` / `outline` / `radiusM` |
| 侧栏 / 代码块底 | `NovaTheme.surfaceAlt` / `radiusS` |
| 正文 / 链接 | `NovaTheme.textColor` / `primaryText` |
| 空态 / 大纲标题 | `NovaTheme.textMuted` |
| 字体 / 行高 | `NovaTheme.fontFamily` / `bodyFontSize` / `bodyLineHeight` / `fontXS` / `fontM` |

`NovaTheme.setDark(true)` 后正文颜色由 `#1F2128` → `#E9EAEF` 实测联动，
无需组件侧任何重绘逻辑。

a11y 分类 `semantic`、`Accessible.role: Accessible.StaticText`、
`Accessible.name` 默认「Markdown 文档」，可由 `a11yLabel` 覆盖；
登记在 `scripts/check_a11y.py` 的 `CONTROLS` 契约表。

---

## 8. 能力边界（如实标注）

除 GFM 表格由组件逐格自绘（§4.1）外，其余渲染能力完全由 Qt 的
`Text.MarkdownText`（CommonMark + 部分 GFM）决定，组件**不自行实现其他语法扩展**：

| 支持（实测） | 不支持 / 不作承诺 |
|---|---|
| `#`~`######` 标题 | 脚注 `[^1]`、定义列表 |
| `**粗**` `*斜*` `~~删~~` `` `行内代码` `` | `++插入++` `==标记==`、上下标 `H~2~O` |
| 有序 / 无序列表、任务列表 `- [x]` | Emoji 短码、自动链接（autolink）、Typographer |
| GFM 表格（含 `:---:` 对齐） | `::: tip` 容器（按普通段落字面显示） |
| 围栏代码块 ``` / ~~~（含语言标注） | Mermaid / KaTeX / 语法高亮配色 |
| 引用 `>`、链接、页内 `#anchor` | 图片尺寸语法 `=100x50`、HTML 原生标签 |

> 原稿承诺的「插件矩阵 / Pygments 高亮 / QWebChannel 双向通信 / LRU 缓存 /
> `taskToggled` 交互 / `renderFailed` 降级」在本库中**均未实现，也不在公共 API 内**。
> 需要这些能力时应另立议题评估，不得把构想稿当作已交付契约。

**适用边界**：适合 README / 变更日志 / 帮助文档 / 组件说明等**中等长度只读文档**。
普通块每块一个 `Text`、表格每格一个 `Text`，超长文档（数千块 / 大表格）建议宿主侧分页；
组件不做缓存与虚拟滚动。T22 起表格行高随该行最高单元格自适应，极长单元格会撑高整行、
不裁字（坑位 75）。

---

## 9. 验收事实（1.4.0 · 离屏真机）

真实 `QQmlApplicationEngine` + `QTest` 事件链，非静态扫描：

```
roots = 1 · blocks = 10 · toc = 4 · QQuickText = 32（正文块 10）
max contentHeight = 80.0（表格块） · Markdown 源语法保留 ✓
theme: #1F2128 → #E9EAEF ✓ · setDark 无错误
scrollToAnchor 无错误 · linkBlocked = 1 · linkClicked = 1
0 条坏 Qt 消息 → PASS
```

门禁侧：`qmllint` 单文件 **0 warning**，全库告警计数回到预算线；
`check_a11y.py` 新增 `semantic` 登记；`qmldir` 新增
`NovaMarkdown 1.0 NovaMarkdown.qml` 导出。

### 9.1 T22 反哺验收（1.5.0 实现体 · 2026-11-27 · 不覆盖上方 1.4.0 史料段）

真实离屏 Qt Quick 引擎 A/B 探针（重复标题 / 3×3 GFM 表格 / hr / tasklist / 40 条大纲）：

```
table / hr / tasklist 独立成块 ✓
表格 3×3 = 9 格全部独立渲染（候选稿只出对角线 3 格，已修正）
锚点 [铝电解工作站, 工艺参数, 工艺参数-1, 细分项-01] · 不随 blocks.length 漂移
_anchorIndex['工艺参数-1'] = 6 · scrollToAnchor 真实位移 0 → 311
TOC contentHeight 1218 > 视口 625 · 文档 1709 > 658 → 两侧真可滚动
0 条坏 Qt 消息 → PASS
```

门禁与回归：

```
冻结面 9742de8638251876 · 146 类型零漂移 · NovaMarkdown 10/3/3 逐字不变
qmllint 单文件 0 warning / 0 error · 全库 594 = 预算 594（未打红）
check_all.py --tier static 3/3 · 三个 --check ✓ · ruff 全净
test_nova_markdown.py 15 passed（新增 3 项 T22 回归）
核心 3 文件 53 passed（T21 时 50 → 现 53）· mkdocs build exit 0
markdown_demo 离屏真机 PASS · 3 张截图 · 0 坏 Qt 消息
AI 包指纹 710415cae870bc8f → a09d2545950a9e13（docs/ai 全量属性表同步）
```

> **如实标注**：全库 537 项一次性 `pytest tests/` 仍会 SIGSEGV（exit 139），
> 元凶是 `test_a11y.py` / `test_visual.py` / `test_smoke.py` 在 offscreen 干净态的
> 既有缺陷（坑位 49 同类，史料已挂账）；`--collect-only` 成功、逐文件单跑除这 3 个外全绿，
> **非 T22 引入**。项目门禁口径本就是 `check_all.py --tier static` 与相关子集。

---

## 10. additive 与冻结面

新增公共导出类型属宪法第 8 章 **additive minor**，必须：

1. `__about__.py` `1.3.0 → 1.4.0`；
2. 重跑 `scripts/gen_api_freeze.py` → `api/nova-api-1.4.0.json` + `docs/API_FREEZE.md`
   （新指纹 `37fbbe9ab5806a2a`）；
3. `tests/test_api_freeze.py` 断言 `144 → 145` / `Nova.Controls 91 → 92` /
   `semantic 28 → 29`；
4. 现行事实源（生成器 / 审计脚本 / README / mkdocs）由 `1.3.0 / 144` 同步到
   `1.4.0 / 145`；历史 CHANGELOG 行属史料不回改；
5. `sync_brand_version.py` 同步 3 枚徽标 + 3 份站点副本的 `v1.4.0` 字样；
6. 生成器链 `gen_component_list.py` → `gen_apidocs.py` → `gen_prompt.py --check` 全部重跑。

`1.3.0` 清单 `api/nova-api-1.3.0.json` 与指纹 `5d865b2d976af016` **保留为史料**，
不回改、不删除。

### 10.1 T22 择优反哺为何不需要重签（1.5.0 实现体）

A 方案的硬约束是**不动冻结面**，因此本轮**不升版、不改 `apiVersion`、不重签
`api/nova-api-1.5.0.json`、不改 `docs/API_FREEZE.md`、不动徽标版本号**。技术依据：

| 判据 | 机制 |
|---|---|
| `gen_api_freeze._is_public()` | 仅 `not name.startswith("_")`；所有新增内部状态一律 `_` 前缀 |
| `gen_apidocs.PROP_RE` | 匹配 `property` / `readonly property`，**不匹配 `required property`**；delegate 内的 `required property` 天然不进面 |
| `fingerprint()` | 含 `types[].file` 等元数据、**不含 QML 文件体**；改实现体不动指纹 |
| `docs/ai/` | 由 `parse_qml` 生成、**含全量 properties（含 `_` 私有）** → 改源码必须重跑生成器链同步 |

候选稿 `nova-forge/docs/controls/NovaMarkdown.qml` v0.17.0 若原样覆盖，会
`10 → 22 props`（delegate 内 `readonly property` 被整文件正则收进公共面）、
专项 `NovaBtn` 断言落空、真机 1 条 `Binding loop`；故只择 4 项增益反哺，
其余（手搓 TOC / 新增公共属性 / 独立加载时 import 缺失）一律不采纳。

> **账实校准**：上一轮评估所列「qmllint +6 unqualified 超预算」是**候选文件放在
> `nova-forge/docs/controls/` 导致 `NovaScrollArea` 类型解析失败**的连带产物；
> 放回 `Nova/Controls/` 同目录后单文件 **0 warning**，非代码缺陷。
> 该条阻塞在 A 反哺语境下自动消解，其余 3 条按上表逐一化解。

---

## 11. 相关文件与法源

| 文件 | 角色 |
|---|---|
| `src/pyside_nova/qml/Nova/Controls/NovaMarkdown.qml` | 组件实现（唯一事实源） |
| `src/pyside_nova/qml/Nova/Controls/qmldir` | 公共导出登记 |
| `src/pyside_nova/qml/Nova/Controls/NovaScrollArea.qml` | 反哺 `_flick` 私有别名 |
| `scripts/check_a11y.py` | a11y 契约表 |
| `api/nova-api-1.7.0.json` / `docs/API_FREEZE.md` | 现行冻结面（生成器产物，禁手改） |
| `examples/controls/markdown_demo/` | 独立演示 + 三张真机截图 + 离屏自检 |
| `tests/test_nova_markdown.py` | 专项 15 项（含 T22 三项增益回归） |
| `docs/CONSTITUTION.md` 第 8 章 / `SPEC_FREEZE.md` v2.1.0 | additive 升版法源 |
| `docs/QUASAR_ACKNOWLEDGEMENT.md` | 关系口径唯一事实源（**Inspired by**） |

> 关系口径：本组件对标 Quasar `QMarkdown` 的功能定位，属 **Inspired by**，
> 非 fork / port / derived from。
