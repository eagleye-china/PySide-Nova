# 公共 API 速查

> 与 `api/nova-api-1.4.0.json` 冻结面逐字一致，指纹 `37fbbe9ab5806a2a`。
> 本页用表格把 **8 个可写属性 / 2 个只读属性 / 3 个信号 / 3 个方法** 一次列全，
> 右上角「外部大纲」演示 `toc` 只读属性如何被宿主自行渲染。

## 可写属性（Props）

| 属性 | 类型 | 默认值 | 说明 |
| :--- | :--- | :--- | :--- |
| `markdown` | `string` | `""` | Markdown 源文本，唯一输入；变更自动重解析 |
| `showToc` | `bool` | `false` | 是否显示内置大纲侧栏（宽 190px） |
| `tocStart` | `int` | `1` | 大纲起始标题层级（1~6） |
| `tocEnd` | `int` | `3` | 大纲结束标题层级（1~6） |
| `openLinksExternally` | `bool` | `true` | 安全链接是否自动交给系统打开 |
| `outlined` | `bool` | `true` | 卡片边框与圆角 |
| `baseFontSize` | `int` | `NovaTheme.bodyFontSize` | 正文字号（像素） |
| `a11yLabel` | `string` | `""` | 可读名覆盖；为空时回落「Markdown 文档」 |

## 只读属性

| 属性 | 类型 | 说明 |
| :--- | :--- | :--- |
| `toc` | `var` | `[{level, title, anchor, index}]`，与 `tocReady` 同源 |
| `empty` | `bool` | 无有效块时为真，显示空态 |

## 信号（Signals）

| 信号 | 参数 | 语义 |
| :--- | :--- | :--- |
| `linkClicked` | `string url` | 通过安全校验的链接被点击 |
| `linkBlocked` | `string url` | 危险协议被拦截 |
| `tocReady` | `var items` | 大纲解析完成 |

三个信号在本 demo 的**右侧事件流**里实时记录，可以直接点击文档中的链接验证。

## 方法（Methods）

| 方法 | 参数 | 语义 |
| :--- | :--- | :--- |
| `scrollToTop()` | — | 回到文档顶部 |
| `scrollToAnchor(anchor)` | `anchor` | 跳到指定标题锚点 |
| `reload()` | — | 强制重新解析当前 `markdown` |

左栏「方法」区有对应按钮，逐一点击即可观察效果。

## 宿主自定义大纲

`toc` 只读属性可直接喂给宿主自己的 `Repeater`，这是本 demo 右栏「外部大纲」的做法：

```qml
Repeater {
    model: doc.toc
    NovaBtn {
        text: modelData.title
        variant: "flat"
        size: "sm"
        dense: true
        onClicked: doc.scrollToAnchor(modelData.anchor)
    }
}
```

### 为什么不用内置大纲

内置大纲（`showToc: true`）开箱即用，但样式固定。
需要把目录放进全局导航、加徽标、或与业务侧状态联动时，用 `toc` 自行渲染更灵活。

### 私有实现不进冻结面

`_blocks` / `_toc` / `_parse` / `_rebuild` / `_safeUrl` / `_onLink` 一律 `_` 前缀，
属于可自由重构的私有实现，不会触发 additive 重签。

## 分块策略

```
_parse(src)  →  [{kind, text, level, anchor}, ...]
                 kind ∈ heading / fence / table / quote / list / paragraph
```

- 围栏优先收拢，保证代码块内语法不被按行拆断
- 标题独立成块，记录 `level` 与 `anchor` 供跳转
- 连续表格 / 引用 / 列表行聚为一块，避免表头语义丢失
- 每块一个 `Text.MarkdownText`，由 `NovaScrollArea` 承载

> **能力边界**：适合 README / 变更日志 / 帮助文档等中等长度只读文档。
> 数千块的超长文档建议宿主侧分页，组件不做缓存与虚拟滚动。
