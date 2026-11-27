// src/pyside_nova/qml/Nova/Controls/NovaMarkdown.qml
// NovaMarkdown Markdown 文档渲染器（对标 Quasar QMarkdown）：Qt 原生 Text.MarkdownText + NovaTheme 令牌 + 分块大纲
// a11y: semantic —— 只读文档内容；可读名由 a11yLabel 覆盖，默认「Markdown 文档」
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.StaticText
    Accessible.name: root.a11yLabel !== "" ? root.a11yLabel : "Markdown 文档"

    // ── 输入 API ─────────────────────────────────────────────────
    property string markdown: ""             // Markdown 源文本（唯一输入，零外部依赖）
    property bool showToc: false             // 是否显示内置大纲侧栏
    property int tocStart: 1                 // 大纲起始标题层级（1~6）
    property int tocEnd: 3                   // 大纲结束标题层级（1~6）
    property bool openLinksExternally: true  // 安全链接是否自动交给系统打开
    property bool outlined: true             // 卡片边框与圆角
    property int baseFontSize: NovaTheme.bodyFontSize

    // ── 只读输出 ─────────────────────────────────────────────────
    readonly property var toc: root._toc
    readonly property bool empty: root._blocks.length === 0

    // ── 信号 ─────────────────────────────────────────────────────
    signal linkClicked(string url)           // 已通过安全校验的链接被点击
    signal linkBlocked(string url)           // 危险协议被拦截（javascript:/vbscript:/data:/file:）
    signal tocReady(var items)               // 大纲解析完成：{level,title,anchor,index}[]

    // ── 私有状态（_ 前缀不进冻结面，实现自由）──────────────────
    property var _blocks: []
    property var _toc: []

    implicitWidth: 480
    implicitHeight: 360

    onMarkdownChanged: root._rebuild()
    onTocStartChanged: root._rebuild()
    onTocEndChanged: root._rebuild()
    Component.onCompleted: root._rebuild()

    // ── 解析：按「块」切分，保证表格/列表/围栏内语法不被拆断 ────
    function _lineKind(line) {
        if (/^\s*\|/.test(line)) return "table"
        if (/^\s*>/.test(line)) return "quote"
        if (/^\s*([-+*]|\d+\.)\s+/.test(line)) return "list"
        return "paragraph"
    }

    function _slug(title, idx) {
        var s = String(title).toLowerCase().replace(/\s+/g, "-")
        s = s.replace(/[^a-z0-9\u4e00-\u9fa5_-]/g, "")
        return (s !== "" ? s : "section") + "-" + idx
    }

    function _parse(src) {
        var lines = String(src || "").replace(/\r\n/g, "\n").split("\n")
        var blocks = []
        var tocList = []
        var i = 0
        while (i < lines.length) {
            var line = lines[i]
            var fence = line.match(/^\s*(`{3,}|~{3,})/)
            if (fence) {
                var mark = fence[1].charAt(0)
                var width = fence[1].length
                var buf = [line]
                i++
                var closeRe = new RegExp("^\\s*" + mark + "{" + width + ",}\\s*$")
                while (i < lines.length) {
                    var fl = lines[i]
                    buf.push(fl)
                    i++
                    if (closeRe.test(fl)) break
                }
                blocks.push({ kind: "fence", text: buf.join("\n"), level: 0, anchor: "" })
                continue
            }
            if (/^\s*$/.test(line)) { i++; continue }

            var head = line.match(/^(#{1,6})\s+(.+?)\s*#*\s*$/)
            if (head) {
                var level = head[1].length
                var title = head[2].replace(/[*_`~]/g, "").trim()
                var anchor = root._slug(title, blocks.length)
                blocks.push({ kind: "heading", text: line, level: level, anchor: anchor })
                if (level >= root.tocStart && level <= root.tocEnd) {
                    tocList.push({ level: level, title: title,
                                   anchor: anchor, index: blocks.length - 1 })
                }
                i++
                continue
            }

            var hint = root._lineKind(line)
            var group = [line]
            i++
            while (i < lines.length) {
                var nx = lines[i]
                if (/^\s*$/.test(nx)) break
                if (/^\s*(`{3,}|~{3,})/.test(nx)) break
                if (/^(#{1,6})\s+/.test(nx)) break
                if (root._lineKind(nx) !== hint) break
                group.push(nx)
                i++
            }
            blocks.push({ kind: hint, text: group.join("\n"), level: 0, anchor: "" })
        }
        return { blocks: blocks, toc: tocList }
    }

    function _rebuild() {
        var r = root._parse(root.markdown)
        root._blocks = r.blocks
        root._toc = r.toc
        root.tocReady(r.toc)
    }

    // ── 安全：危险协议一律拦截，宿主可监听 linkBlocked 自行处置 ──
    function _safeUrl(url) {
        var u = String(url || "").trim().toLowerCase()
        return !(u.indexOf("javascript:") === 0 || u.indexOf("vbscript:") === 0
                 || u.indexOf("data:") === 0 || u.indexOf("file:") === 0)
    }

    function _onLink(url) {
        if (!root._safeUrl(url)) { root.linkBlocked(url); return }
        if (url.length > 0 && url.charAt(0) === "#") {
            root.scrollToAnchor(url.substring(1))
            return
        }
        root.linkClicked(url)
        if (root.openLinksExternally) Qt.openUrlExternally(url)
    }

    // ── 对外方法 ─────────────────────────────────────────────────
    function scrollToTop() {
        scroller._flick.contentY = 0
    }

    function scrollToAnchor(anchor) {
        if (!anchor) return
        for (var k = 0; k < blockRepeater.count; ++k) {
            var it = blockRepeater.itemAt(k)
            // objectName 是 QQuickItem 标准属性，qmllint 可静态解析
            if (it && it.objectName === anchor) {
                var maxY = Math.max(0, scroller._flick.contentHeight - scroller._flick.height)
                scroller._flick.contentY = Math.max(0, Math.min(it.y, maxY))
                return
            }
        }
    }

    function reload() {
        root._rebuild()
    }

    // ── 视觉：令牌化卡片底 ──────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border.width: root.outlined ? 1 : 0
        border.color: NovaTheme.outline
    }

    Item {
        id: stage
        anchors.fill: parent
        anchors.margins: root.outlined ? 1 : 0

        // 大纲侧栏（库组件 NovaBtn flat/dense）
        Rectangle {
            id: tocPane
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: root.showToc ? 190 : 0
            visible: root.showToc
            color: NovaTheme.surfaceAlt
            Rectangle {
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: 1
                color: NovaTheme.outline
            }
            Text {
                id: tocTitle
                anchors { left: parent.left; top: parent.top; leftMargin: 12; topMargin: 10 }
                text: "大纲 · " + root._toc.length
                color: NovaTheme.textMuted
                font { family: NovaTheme.fontFamily; pixelSize: NovaTheme.fontXS }
            }
            Column {
                anchors { left: parent.left; right: parent.right; top: tocTitle.bottom; topMargin: 8 }
                spacing: 2
                Repeater {
                    model: root._toc
                    delegate: Item {
                        id: tocRow
                        required property int index
                        required property var modelData
                        width: tocPane.width - 12
                        height: 26
                        x: 6 + Math.max(0, tocRow.modelData.level - root.tocStart) * 10
                        NovaBtn {
                            anchors.fill: parent
                            text: tocRow.modelData.title
                            variant: "flat"
                            size: "sm"
                            dense: true
                            tint: NovaTheme.primary
                            onClicked: root.scrollToAnchor(tocRow.modelData.anchor)
                        }
                    }
                }
            }
        }

        // 文档滚动区（库组件 NovaScrollArea；坑位 65：首尾留白 Item）
        NovaScrollArea {
            id: scroller
            anchors { left: tocPane.right; right: parent.right; top: parent.top; bottom: parent.bottom }

            Column {
                id: docColumn
                x: 0
                width: scroller.width
                Item { width: 1; height: 12 }
                Repeater {
                    id: blockRepeater
                    model: root._blocks
                    delegate: Item {
                        id: blockItem
                        required property int index
                        required property var modelData
                        objectName: blockItem.modelData.anchor || ""
                        width: docColumn.width
                        height: bodyText.implicitHeight + (blockItem.modelData.kind === "fence" ? 20 : 6)

                        Rectangle {
                            anchors.fill: parent
                            visible: blockItem.modelData.kind === "fence"
                            radius: NovaTheme.radiusS
                            color: NovaTheme.surfaceAlt
                            border.width: 1
                            border.color: NovaTheme.outline
                        }

                        Text {
                            id: bodyText
                            anchors {
                                left: parent.left; right: parent.right; top: parent.top
                                leftMargin: blockItem.modelData.kind === "fence" ? 10 : 14
                                rightMargin: blockItem.modelData.kind === "fence" ? 10 : 14
                                topMargin: blockItem.modelData.kind === "fence" ? 8 : 2
                            }
                            text: blockItem.modelData.text
                            textFormat: Text.MarkdownText
                            wrapMode: Text.WordWrap
                            color: NovaTheme.textColor
                            linkColor: NovaTheme.primaryText
                            font { family: NovaTheme.fontFamily; pixelSize: root.baseFontSize }
                            lineHeight: NovaTheme.bodyLineHeight
                            onLinkActivated: function(url) { root._onLink(url) }
                        }
                    }
                }
                Item { width: 1; height: 12 }
            }
        }

        // 空态：绝不白屏
        Text {
            anchors.centerIn: parent
            visible: root.empty
            text: "暂无内容"
            color: NovaTheme.textMuted
            font { family: NovaTheme.fontFamily; pixelSize: NovaTheme.fontM }
        }
    }
}
