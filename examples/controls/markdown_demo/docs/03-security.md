# 链接安全演练

> `NovaMarkdown` 的链接处置遵循一条原则：**危险协议一律不执行，只发信号**。
> 本页的链接都是真实可点的，点击事件会实时出现在右侧「事件流」里。

## 安全链接

下面两个是通过白名单校验的外链。点击后触发 `linkClicked(url)`；
组件默认 `openLinksExternally: true` 时还会调用 `Qt.openUrlExternally(url)`。

- [PySide6 文档](https://doc.qt.io/qtforpython/)
- [Qt Quick Text 类型](https://doc.qt.io/qt-6/qml-qtquick-text.html)

> **本 demo 默认把「自动打开外链」关掉**（只为方便演示，不改动组件默认值），
> 点击链接只会记录在右侧事件流，不会弹出系统浏览器。
> 想验证完整的 `Qt.openUrlExternally` 行为，在左栏勾选该开关即可。

## 被拦截的危险协议

协议判定在 `_safeUrl()` 里完成：先 `trim().toLowerCase()`，再对前缀做白名单排除。
大小写变体与前后空白都无法绕过。以下四个链接**只会**触发 `linkBlocked(url)`，
绝不打开、绝不跳转、绝不执行任何脚本：

- [javascript 协议](javascript:alert(1))
- [vbscript 协议](vbscript:msgbox("x"))
- [data 协议](data:text/plain,hello)
- [file 协议](file:///C:/Windows/win.ini)

## 处置流程

```
onLinkActivated(url) → _onLink(url)
   ├─ 危险协议        → linkBlocked(url)              （不打开、不跳转）
   ├─ "#anchor"       → scrollToAnchor(anchor)        （页内跳转，不发 linkClicked）
   └─ 其他            → linkClicked(url)
                        + openLinksExternally ? Qt.openUrlExternally(url) : 无
```

### 为什么拦截而不是静默丢弃

静默吞掉事件会让宿主无法感知攻击尝试。组件选择把决策权交还宿主：
监听 `linkBlocked`，可以记日志、弹提示、或上报风控，而不是替宿主做主。

```qml
NovaMarkdown {
    id: doc
    openLinksExternally: false
    onLinkClicked: function(url) { log("允许", url) }
    onLinkBlocked: function(url) { warn("拦截", url) }
}
```

## 页内锚点

组件支持 Markdown 里的 `#anchor` 页内链接，点击后直接滚动到对应标题块，
**不会**发出 `linkClicked`。锚点由 `_slug(title, index)` 生成，与 `toc[].anchor` 对应。

更可靠的做法是使用右栏「**外部大纲**」：它遍历 `doc.toc`，
用库组件 `NovaBtn` 逐条渲染，点击时调用 `doc.scrollToAnchor(modelData.anchor)`。
切到本页后试着点几条，观察文档滚动位置的变化。

## 空态

在左栏点「清空文档」把 `markdown` 置空，组件会显示「暂无内容」而不是白屏；
`empty` 只读属性同步变为 `true`，底部状态栏也会实时反映。再点一次即可恢复。

---

**边界说明**：白名单排除的是协议前缀，不做 URL 内容审计、不做域名信誉判断、
不做 XSS 清洗（本组件不渲染 HTML 原生标签）。需要更严格策略的宿主，
请在 `linkClicked` 里自行接管并二次校验。
