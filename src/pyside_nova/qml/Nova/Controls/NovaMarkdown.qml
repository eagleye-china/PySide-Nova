// src/pyside_nova/qml/Nova/Controls/NovaMarkdown.qml
// NovaMarkdown Markdown 文档渲染器（对标 Quasar QMarkdown）：Qt 原生 Text.MarkdownText + NovaTheme 令牌 + 分块大纲
// a11y: semantic —— 只读文档内容；可读名由 a11yLabel 覆盖，默认「Markdown 文档」
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Nova.Services

Item {
    id: root

    // T22 择优反哺（不动冻结面）：GFM 表格 Grid 自绘 / 锚点去重 + O(1) 索引 /
    // TOC 侧栏可滚动 / hr·tasklist·独占图独立分块。所有新增内部状态一律 `_` 前缀，
    // 公共面恒定 10 props / 3 signals / 3 methods，API 1.5.0 指纹零漂移。

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
    property var _anchorIndex: ({})          // anchor → blockIndex，跳转 O(1)

    implicitWidth: 480
    implicitHeight: 360

    onMarkdownChanged: root._rebuild()
    onTocStartChanged: root._rebuild()
    onTocEndChanged: root._rebuild()
    Component.onCompleted: root._rebuild()

    // ── 解析工具（全部 _ 私有）──────────────────────────────────
    function _isHr(line) {
        var s = String(line).trim()
        if (s.length < 3) return false
        var c = s.charAt(0)
        if (c !== "-" && c !== "*" && c !== "_") return false
        var marks = 0
        for (var i = 0; i < s.length; i++) {
            var ch = s.charAt(i)
            if (ch === c) marks++
            else if (ch !== " " && ch !== "\t") return false
        }
        return marks >= 3
    }

    function _isSeparatorLine(line) {
        // GFM 表格分隔行 |---|---| / |:--|--:|:--:|（也兼容无首尾竖线）
        var s = String(line).trim()
        if (s.charAt(0) === "|") s = s.substring(1)
        if (s.charAt(s.length - 1) === "|") s = s.substring(0, s.length - 1)
        var cells = s.split("|")
        if (cells.length === 0) return false
        for (var i = 0; i < cells.length; i++) {
            if (!/^:?-+:?$/.test(cells[i].trim())) return false
        }
        return true
    }

    function _lineKind(line) {
        if (/^\s*\|.*\|\s*$/.test(line)) return "table"
        if (/^\s*>/.test(line)) return "quote"
        if (root._isHr(line)) return "hr"
        if (/^\s*([-+*]|\d+\.)\s+\[[ xX]\]\s+/.test(line)) return "tasklist"
        if (/^\s*([-+*]|\d+\.)\s+/.test(line)) return "list"
        return "paragraph"
    }

    function _isImageOnly(line) {
        return /^\s*!\[[^\]]*\]\([^)]+\)\s*$/.test(line)
    }

    function _extractImage(line) {
        var m = String(line).match(/!\[([^\]]*)\]\(([^)\s]+)(?:\s+"([^"]*)")?\)/)
        if (!m) return null
        return { alt: m[1] || "", src: m[2] || "", title: m[3] || "" }
    }

    function _splitRow(line) {
        var s = String(line).trim()
        if (s.charAt(0) === "|") s = s.substring(1)
        if (s.charAt(s.length - 1) === "|") s = s.substring(0, s.length - 1)
        return s.split("|").map(function (c) { return c.trim() })
    }

    function _extractTable(headerLine, sepLine, dataLines) {
        var header = root._splitRow(headerLine)
        var aligns = root._splitRow(sepLine).map(function (c) {
            var l = c.charAt(0) === ":"
            var r = c.charAt(c.length - 1) === ":"
            return l && r ? "center" : r ? "right" : "left"
        })
        var rows = []
        for (var k = 0; k < dataLines.length; k++)
            rows.push(root._splitRow(dataLines[k]))
        // 逐行模型交给 RowLayout → Repeater（每行元素即该列文本）。
        // 不在 QML 绑定里对 QVariantList 做 concat / 取模（坑位 70），也不把
        // 行数当成 cell 数（候选稿 v0.17.0 只渲染出对角线格子的缺陷）。
        return {
            header: header, aligns: aligns, rows: rows,
            allRows: [header].concat(rows), colCount: header.length
        }
    }

    function _slug(title, counter) {
        // 按标题文本 + 去重计数生成锚点，不依赖 blocks.length（避免锚点漂移）
        var s = String(title).toLowerCase().replace(/\s+/g, "-")
        s = s.replace(/[^a-z0-9\u4e00-\u9fa5_-]/g, "")
        var base = s !== "" ? s : "section"
        var n = counter[base] || 0
        counter[base] = n + 1
        return n === 0 ? base : base + "-" + n
    }

    // ── 解析主体：逐行扫描，按 kind 分组为「块」─────────────────
    function _parse(src) {
        var lines = String(src || "").replace(/\r\n/g, "\n").split("\n")
        var blocks = []
        var tocList = []
        var anchorMap = {}
        var slugCounter = {}
        var i = 0
        while (i < lines.length) {
            var line = lines[i]

            // 围栏代码块
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

            // 标题
            var head = line.match(/^(#{1,6})\s+(.+?)\s*#*\s*$/)
            if (head) {
                var level = head[1].length
                var title = head[2].replace(/[*_`~]/g, "").trim()
                var anchor = root._slug(title, slugCounter)
                blocks.push({ kind: "heading", text: line, level: level, anchor: anchor })
                if (level >= root.tocStart && level <= root.tocEnd) {
                    tocList.push({ level: level, title: title,
                                   anchor: anchor, index: blocks.length - 1 })
                }
                anchorMap[anchor] = blocks.length - 1
                i++
                continue
            }

            // 分隔线
            if (root._isHr(line)) {
                blocks.push({ kind: "hr", text: line, level: 0, anchor: "" })
                i++
                continue
            }

            // GFM 表格（表头 + 分隔行 + 数据行）
            if (root._lineKind(line) === "table"
                    && i + 1 < lines.length
                    && root._isSeparatorLine(lines[i + 1])) {
                var headerLine = line
                var sepLine = lines[i + 1]
                var dataLines = []
                var j = i + 2
                while (j < lines.length && /^\s*\|.*\|\s*$/.test(lines[j])) {
                    dataLines.push(lines[j])
                    j++
                }
                blocks.push({
                    kind: "table", text: "", level: 0, anchor: "",
                    table: root._extractTable(headerLine, sepLine, dataLines)
                })
                i = j
                continue
            }

            // 独占一行的图片
            if (root._isImageOnly(line)) {
                var img = root._extractImage(line)
                if (img) {
                    blocks.push({
                        kind: "image", text: line, level: 0, anchor: "", image: img
                    })
                    i++
                    continue
                }
            }

            // 普通块（按 kind 分组）
            var hint = root._lineKind(line)
            var group = [line]
            i++
            while (i < lines.length) {
                var nx = lines[i]
                if (/^\s*$/.test(nx)) break
                if (/^\s*(`{3,}|~{3,})/.test(nx)) break
                if (/^(#{1,6})\s+/.test(nx)) break
                if (root._isHr(nx)) break
                if (root._lineKind(nx) === "table"
                        && i + 1 < lines.length
                        && root._isSeparatorLine(lines[i + 1])) break
                if (root._lineKind(nx) !== hint) break
                group.push(nx)
                i++
            }
            blocks.push({ kind: hint, text: group.join("\n"), level: 0, anchor: "" })
        }
        return { blocks: blocks, toc: tocList, anchorMap: anchorMap }
    }

    function _rebuild() {
        var r = root._parse(root.markdown)
        root._blocks = r.blocks
        root._toc = r.toc
        root._anchorIndex = r.anchorMap
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

    // ── 对外方法（名字/签名逐字不变）───────────────────────────
    function scrollToTop() {
        if (scroller._flick) scroller._flick.contentY = 0
    }

    function scrollToAnchor(anchor) {
        if (!anchor || !scroller._flick) return
        var idx = root._anchorIndex[anchor]
        if (idx === undefined || idx < 0) return
        var it = blockRepeater.itemAt(idx)
        if (!it) return
        var maxY = Math.max(0, scroller._flick.contentHeight - scroller._flick.height)
        scroller._flick.contentY = Math.max(0, Math.min(it.y, maxY))
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

        // 大纲侧栏（库组件 NovaBtn + NovaScrollArea 可滚动；坑位 65 首尾留白）
        Rectangle {
            id: tocPane
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: root.showToc ? 190 : 0
            visible: root.showToc
            color: NovaTheme.surfaceAlt
            clip: true
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
            NovaScrollArea {
                id: tocScroller
                anchors {
                    left: parent.left; right: parent.right
                    top: tocTitle.bottom; topMargin: 8; bottom: parent.bottom
                }
                Column {
                    // 绑定 scroller.width 而非 parent.width：避开 NovaScrollArea.inner.width
                    // 与 childrenRect 互锁的绑定环（候选稿真机 1 条 Binding loop）
                    width: tocScroller.width
                    spacing: 2
                    Item { width: 1; height: 6 }
                    Repeater {
                        model: root._toc
                        delegate: Item {
                            id: tocRow
                            required property int index
                            required property var modelData
                            width: tocScroller.width - 12
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
                    Item { width: 1; height: 6 }
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

                        readonly property bool _isFence: modelData.kind === "fence"
                        readonly property bool _isTable: modelData.kind === "table"
                        readonly property bool _isHr: modelData.kind === "hr"
                        readonly property bool _isImage: modelData.kind === "image"
                        readonly property bool _isBody: !blockItem._isFence
                            && !blockItem._isTable && !blockItem._isHr && !blockItem._isImage

                        objectName: blockItem.modelData.anchor || ""
                        width: docColumn.width
                        height: {
                            if (blockItem._isHr) return 20
                            if (blockItem._isTable) return tableGrid.height + 6
                            if (blockItem._isImage) return Math.max(0, imageBody.height + 6)
                            return bodyText.implicitHeight
                                + (blockItem._isFence ? 20 : 6)
                        }

                        // 围栏代码底
                        Rectangle {
                            anchors.fill: parent
                            visible: blockItem._isFence
                            radius: NovaTheme.radiusS
                            color: NovaTheme.surfaceAlt
                            border.width: 1
                            border.color: NovaTheme.outline
                        }

                        // 分隔线
                        Rectangle {
                            visible: blockItem._isHr
                            anchors.verticalCenter: parent.verticalCenter
                            x: 14
                            width: Math.max(0, parent.width - 28)
                            height: 1
                            color: NovaTheme.outline
                        }

                        // GFM 表格：ColumnLayout + RowLayout。行高由该行最高单元格
                        // 自适应，Layout.fillHeight 把同行拉齐 → 网格连续、不裁字。
                        // （Grid 是定位器，各格按自身文本定高会留下行间空隙。）
                        ColumnLayout {
                            id: tableGrid
                            visible: blockItem._isTable
                            x: 14
                            y: 3
                            width: Math.max(0, parent.width - 28)
                            spacing: 0

                            Repeater {
                                model: blockItem._isTable
                                    ? blockItem.modelData.table.allRows : []
                                delegate: RowLayout {
                                    id: rowItem
                                    required property int index
                                    required property var modelData
                                    Layout.fillWidth: true
                                    spacing: 0

                                    Repeater {
                                        model: rowItem.modelData
                                        delegate: Rectangle {
                                            id: cellRect
                                            required property int index
                                            required property var modelData

                                            readonly property bool _isHead:
                                                rowItem.index === 0
                                            readonly property string _align:
                                                (blockItem._isTable
                                                    && blockItem.modelData.table.aligns[index])
                                                    || "left"

                                            Layout.preferredWidth:
                                                tableGrid.width
                                                / (blockItem._isTable
                                                    ? blockItem.modelData.table.colCount : 1)
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            Layout.preferredHeight:
                                                cellBody.implicitHeight + 18
                                            Layout.minimumHeight:
                                                cellBody.implicitHeight + 18
                                            implicitHeight: cellBody.implicitHeight + 18
                                            color: cellRect._isHead
                                                ? NovaTheme.surfaceAlt : NovaTheme.surface
                                            border.width: 1
                                            border.color: NovaTheme.outline

                                            Text {
                                                id: cellBody
                                                anchors {
                                                    left: parent.left; right: parent.right
                                                    top: parent.top
                                                    leftMargin: 8; rightMargin: 8; topMargin: 6
                                                }
                                                text: String(cellRect.modelData)
                                                textFormat: Text.MarkdownText
                                                wrapMode: Text.WordWrap
                                                color: NovaTheme.textColor
                                                font {
                                                    family: NovaTheme.fontFamily
                                                    pixelSize: root.baseFontSize
                                                    bold: cellRect._isHead
                                                }
                                                horizontalAlignment:
                                                        cellRect._align === "center" ? Text.AlignHCenter
                                                    : cellRect._align === "right" ? Text.AlignRight
                                                        : Text.AlignLeft
                                                onLinkActivated: function (url) {
                                                    root._onLink(url)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 独占一行的图片（宽度自适应，未就绪时高度 0 不占位）
                        Image {
                            id: imageBody
                            visible: blockItem._isImage
                            x: 14
                            y: 3
                            width: Math.max(1, parent.width - 28)
                            source: blockItem._isImage && blockItem.modelData.image
                                ? blockItem.modelData.image.src : ""
                            sourceSize.width: Math.max(1, Math.floor(width))
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            smooth: true
                            height: status === Image.Ready && sourceSize.width > 0
                                ? Math.min(sourceSize.height * (width / sourceSize.width), 1200)
                                : 0
                        }

                        // 正文（heading / paragraph / list / tasklist / quote / fence）
                        Text {
                            id: bodyText
                            visible: blockItem._isBody || blockItem._isFence
                            anchors {
                                left: parent.left; right: parent.right; top: parent.top
                                leftMargin: blockItem._isFence ? 10 : 14
                                rightMargin: blockItem._isFence ? 10 : 14
                                topMargin: blockItem._isFence ? 8 : 2
                            }
                            text: blockItem._isBody || blockItem._isFence
                                ? blockItem.modelData.text : ""
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
