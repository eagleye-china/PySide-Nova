// src/pyside_nova/qml/Nova/Controls/NovaEditor.qml
// NovaEditor 轻量富文本编辑器（对标 QEditor · 基线 2.35.5 语义）
// 工具栏配置 toolbar（数组的数组，分组渲染）+ execCmd() 格式化命令 + modelValue 受控
// ── 实现口径留痕（PARITY 对账）──
// QEditor 基于 DOM contenteditable，QML TextEdit 无富文本选区格式化 API；
// Nova 同语义落地为「轻量标记编辑器」：命令在纯文本上包裹标记（**b** / *i* / # 标题 …），
// 经 toHtml() 导出 HTML——toolbar 配置 / execCmd / modelValue(update:model-value) 契约 1:1 对齐。
// 受控口径沿用 NovaInput：TextArea.text ↔ modelValue 双向同步 + guard 防回环（坑位 22 精神）。
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Behaviors
import Nova.Design

NovaField {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.EditableText
    Accessible.name: a11yLabel !== "" ? a11yLabel : label
    Accessible.readOnly: readonly
    Accessible.focusable: !disable
    Accessible.focused: activeFocus

    // ── 对标 QEditor 核心 props ───────────────────────────────
    property var modelValue: ""                                  // 编辑器内容（标记文本；对标 modelValue）
    property var toolbar: [                                      // 工具栏配置（分组的命令名数组；对标 QEditor toolbar）
        ["bold", "italic", "underline", "strike"],
        ["h1", "h2", "quote"],
        ["ul", "ol", "code"],
        ["link", "removeFormat"],
        ["undo", "redo"]
    ]
    property string placeholder: ""
    property bool flat: false                                    // 无边框模式（对标 flat）
    property int minHeight: 96                                   // 内容区最小高度（Nova 增强）
    property bool disable: false
    property bool readonly: false                                // 只读（对标 QEditor readonly）

    // ── 事件 ──────────────────────────────────────────────────
    signal updateModelValue(string value)                        // 对标 update:model-value（同 NovaField.value 变更信号）——
                                                                 // 编辑器走显式信号避免与 Field.value 自动信号撞名（坑位 21）
    signal saved(string value)                                   // 对标 @save（本组件无事件总线，保存命令经 execCmd("save") 触发）
    signal keyPressed(var event)

    // ── 派生状态 ──────────────────────────────────────────────
    readonly property var _commands: ({                          // 命令 → 行内包裹标记（null = 行前缀型命令，见 _commands2）
        bold: "Bold", italic: "Italic", underline: "Under", strike: "Strike"
    })
    readonly property var _commands2: ({                         // 行前缀型命令 → 每行前缀（对标 QEditor 命令名 1:1）
        h1: "# ", h2: "## ", h3: "### ", h4: "#### ", h5: "##### ", h6: "###### ",
        quote: "> ", code: "    ", ul: "- ", ol: "1. "
    })
    readonly property var _labels: ({                            // 工具栏按钮标签（无 DOM 字体图标，用语义缩写）
        bold: "B", italic: "I", underline: "U", strike: "S",
        h1: "H1", h2: "H2", h3: "H3", h4: "H4", h5: "H5", h6: "H6",
        quote: "❝", code: "</>", ul: "•—", ol: "1.", link: "🔗",
        removeFormat: "⌫", undo: "↶", redo: "↷",
        separator: ""
    })
    readonly property string _text: area.text
    readonly property int buttonCount: toolRepeater.count   // 工具栏命令按钮数（不含 separator）
    property bool _syncing: false                                // guard 防回环（NovaInput 同款）

    // 校验取值接线
    value: _text
    // 控件区高度 = 工具栏 + 内容区（NovaField 固定高度裁剪区需显式覆盖）
    customControlH: toolbarRow.height + minHeight + 8

    // ── 双向同步（受控 + guard） ──────────────────────────────
    onModelValueChanged: {
        if (_syncing) return
        var s = modelValue === null || modelValue === undefined ? "" : String(modelValue)
        if (s !== area.text) area.text = s
    }

    // ── 工具栏 ────────────────────────────────────────────────
    Rectangle {
        id: toolbarRow
        width: parent.width
        height: root.toolbar.length > 0 ? 36 : 0
        visible: root.toolbar.length > 0
        color: root.flat ? "transparent" : NovaTheme.surfaceAlt
        radius: root.flat ? 0 : NovaTheme.radiusS

        Row {
            id: btnRow
            x: 4
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Repeater {
                id: toolRepeater
                model: {
                    // 展平：外层分组、内层命令；组间插 separator
                    var flat = []
                    for (var g = 0; g < root.toolbar.length; g++) {
                        if (g > 0) flat.push("separator")
                        var grp = root.toolbar[g]
                        for (var c = 0; c < grp.length; c++) flat.push(grp[c])
                    }
                    return flat
                }
                delegate: Item {
                    id: btn
                    required property int index
                    required property var modelData
                    readonly property bool isSep: modelData === "separator"
                    width: isSep ? 10 : 26
                    height: 28
                    visible: !isSep || index > 0

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 4
                        color: btnMa.containsMouse && !btn.isSep
                               ? NovaTheme.surfaceAlt : "transparent"
                        visible: !btn.isSep
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: !btn.isSep
                        text: root._labels[btn.modelData] !== undefined ? root._labels[btn.modelData] : ""
                        color: btnMa.pressed ? NovaTheme.primary
                                             : (btnMa.containsMouse ? NovaTheme.textColor : NovaTheme.textMuted)
                        font.pixelSize: NovaTheme.fontS
                        font.bold: btn.modelData === "bold"
                        font.italic: btn.modelData === "italic"
                        font.underline: btn.modelData === "underline"
                        font.strikeout: btn.modelData === "strike"
                    }
                    MouseArea {
                        id: btnMa
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !root.disable && !root.readonly && !btn.isSep
                        onClicked: root.execCmd(btn.modelData)
                    }
                }
            }
        }
    }

    // ── 内容区（底板由 NovaField 样式层提供，此处透明承载） ───
    Item {
        id: body
        y: toolbarRow.height
        width: parent.width
        height: parent.height - toolbarRow.height

        ScrollView {
            id: sv
            anchors.fill: parent
            anchors.margins: 8
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            TextArea {
                id: area
                width: sv.width - 8
                height: Math.max(root.minHeight, sv.height - 8)
                textFormat: TextEdit.PlainText
                wrapMode: TextEdit.Wrap
                color: NovaTheme.textColor
                selectionColor: NovaTheme.ripple
                placeholderText: root.placeholder
                placeholderTextColor: NovaTheme.textMuted
                font.pixelSize: NovaTheme.fontM
                background: null
                readOnly: root.readonly || root.disable
                onTextChanged: {
                    if (root._syncing) return
                    root._syncing = true
                    root.updateModelValue(text)
                    root._syncing = false
                }
                Keys.onPressed: function(ev) { root.keyPressed(ev) }
            }
        }
    }

    // ── 选区辅助（对标 QEditor caret） ────────────────────────
    function selectRange(s, e) { area.select(s, e) }
    function caretPosition() { return area.cursorPosition }

    // ── 命令执行（对标 QEditor runCmd/caret 命令族） ──────────
    function execCmd(cmd, arg) {
        if (root.readonly || root.disable) return false
        if (cmd === "save") { saved(root._text); return true }
        if (cmd === "undo") { area.undo(); return true }
        if (cmd === "redo") { area.redo(); return true }

        var wrap = root._commands[cmd]                 // 行内包裹型
        if (wrap !== undefined) return _wrapSelection(wrap, arg)

        var prefix = root._commands2[cmd]              // 行前缀型
        if (prefix !== undefined) return _prefixLines(prefix)

        if (cmd === "link") return _wrapSelection("Link", arg !== undefined ? String(arg) : "url")
        if (cmd === "removeFormat") return _removeFormat()
        return false
    }

    // 选区包裹标记；无选区时在光标处插入占位对
    function _wrapSelection(name, arg) {
        var tag = arg !== undefined ? arg : name
        var s = area.selectionStart, e = area.selectionEnd
        var open = s !== e ? "[" + tag + "]" : "[" + tag + "]"
        var close = "[/" + tag + "]"
        var inner = s !== e ? area.getText(s, e) : "text"
        area.remove(Math.min(s, e), Math.max(s, e))
        area.insert(Math.min(s, e), open + inner + close)
        return true
    }

    // 行前缀型：选中（或光标所在）行的每一行加前缀
    function _prefixLines(prefix) {
        var s = area.selectionStart, e = area.selectionEnd
        if (s === e) {                                   // 无选区：光标行
            var lineStart = area.text.lastIndexOf("\n", Math.max(0, area.cursorPosition - 1)) + 1
            area.insert(lineStart, prefix)
            return true
        }
        var start = area.text.lastIndexOf("\n", Math.max(0, s - 1)) + 1
        var seg = area.getText(start, e)
        var patched = seg.split("\n").map(function(l) { return prefix + l }).join("\n")
        area.remove(start, e)
        area.insert(start, patched)
        return true
    }

    // 清除选区内的行内标记（removeFormat：去掉 [X]…[/X] 包裹）
    function _removeFormat() {
        var s = area.selectionStart, e = area.selectionEnd
        if (s === e) return false
        var seg = area.getText(s, e)
        var clean = seg.replace(/\[\/?[A-Za-z0-9_]+\]/g, "")
        area.remove(s, e)
        area.insert(s, clean)
        return true
    }

    // ── HTML 导出（标记 → HTML；对标 QEditor 的 getHTML） ────
    function _esc(s) {
        return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    }
    function toHtml() {
        var lines = _text.split("\n")
        var out = []
        for (var i = 0; i < lines.length; i++) {
            var l = lines[i]
            var m
            // 结构前缀在原始行上判断并切片，内容再单独转义（勿在转义后切片——前缀长度错位）
            if ((m = l.match(/^(#{1,6})\s+(.*)$/)) !== null)
                out.push("<h" + m[1].length + ">" + _inline(_esc(m[2])) + "</h" + m[1].length + ">")
            else if (l.indexOf("> ") === 0)
                out.push("<blockquote>" + _inline(_esc(l.slice(2))) + "</blockquote>")
            else if (l.indexOf("- ") === 0)
                out.push("<li>" + _inline(_esc(l.slice(2))) + "</li>")
            else if (l.indexOf("1. ") === 0)
                out.push("<li>" + _inline(_esc(l.slice(3))) + "</li>")
            else if (l.indexOf("    ") === 0 && l.trim().length > 0)
                out.push("<pre><code>" + _esc(l.slice(4)) + "</code></pre>")
            else if (l.length === 0) out.push("")
            else out.push("<p>" + _inline(_esc(l)) + "</p>")
        }
        return out.join("\n")
    }

    // 行内标记 → 行内 HTML（[Bold]x[/Bold] → <strong>x</strong> 等）
    function _inline(s) {
        var map = { Bold: "strong", Italic: "em", Under: "u", Strike: "s" }
        var r = s
        for (var k in map) {
            var open = new RegExp("\\[" + k + "\\]([\\s\\S]*?)\\[/" + k + "\\]", "g")
            r = r.replace(open, "<" + map[k] + ">$1</" + map[k] + ">")
        }
        r = r.replace(/\[Link\]([\s\S]*?)\[\/Link\]/g, "<a>$1</a>")
             .replace(/\[Link\]/g, "").replace(/\[\/Link\]/g, "")
        return r
    }

    function clear() { area.clear() }
    function focusEditor() { area.forceActiveFocus() }   // 坑位 12：focus 撞 Item FINAL 成员

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
