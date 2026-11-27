// examples/markdown_demo/Main.qml
// NovaMarkdown 独立演示主界面：加载真实 .md 文件 · 内置大纲 / 明暗 / 字号 / 边框 /
// 危险协议拦截 / 锚点跳转 / 宿主自定义大纲 / 三信号事件流。
// 控件全部取自 Nova.Controls（库组件优先、零手搓）；颜色全部取自 NovaTheme 令牌。
// demoTitles / demoTexts 由 main.py 经 setContextProperty 运行时注入，
// qmllint 静态看不到它们，故对本文件关闭 unqualified 类别（examples 不进门禁扫描）。
// qmllint disable unqualified
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nova.Services
import Nova.Controls

ApplicationWindow {
    id: win
    width: 1280
    height: 820
    minimumWidth: 1040
    minimumHeight: 640
    visible: true
    title: "NovaMarkdown · 文档渲染器演示"
    color: NovaTheme.page

    Component.onCompleted: {
        NovaScreen.source = win
        if (typeof novaIconLocalRoot !== "undefined" && novaIconLocalRoot !== "")
            NovaTheme.iconLocalRoot = novaIconLocalRoot
    }

    // ── 演示状态 ─────────────────────────────────────────────
    QtObject {
        id: st
        property int docIndex: 0
        property bool cleared: false
        property int fontSize: NovaTheme.bodyFontSize
        property var events: []
        property int eventCount: 0
        property int blockedCount: 0
        property int clickedCount: 0

        function log(kind, text) {
            var e = { kind: kind, text: text, no: st.eventCount + 1 }
            var next = [e]
            for (var i = 0; i < st.events.length && next.length < 9; i++)
                next.push(st.events[i])
            st.events = next
            st.eventCount++
            if (kind === "block") st.blockedCount++
            if (kind === "link") st.clickedCount++
        }

        function currentText() {
            if (st.cleared) return ""
            var i = st.docIndex
            if (i < 0 || i >= demoTexts.length) return ""
            return demoTexts[i]
        }
    }

    // ── 顶栏 ─────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: NovaTheme.spacingL
        spacing: NovaTheme.spacingM

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            radius: NovaTheme.radiusM
            color: NovaTheme.surface
            border.width: 1
            border.color: NovaTheme.outline

            RowLayout {
                anchors.fill: parent
                anchors.margins: NovaTheme.spacingM
                spacing: NovaTheme.spacingM

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        text: "NovaMarkdown · 文档渲染器"
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontL
                        font.bold: true
                        color: NovaTheme.textColor
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "零第三方依赖 · Qt 原生 MarkdownText · 内置大纲 / 锚点 / 危险协议拦截 · pyside-nova 1.10.0"
                        font.family: NovaTheme.fontFamily
                        font.pixelSize: NovaTheme.fontXS
                        color: NovaTheme.textMuted
                    }
                }

                NovaChip {
                    text: "⛔ 已拦截 " + st.blockedCount
                    outlined: true
                    dense: true
                    tint: NovaTheme.negative
                }
                NovaChip {
                    text: "🔗 外链 " + st.clickedCount
                    outlined: true
                    dense: true
                }
                NovaBtn {
                    text: NovaTheme.isDark ? "切到亮色" : "切到暗色"
                    variant: "flat"
                    size: "sm"
                    onClicked: NovaTheme.toggleDark()
                }
            }
        }

        // ── 主体三栏 ─────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: NovaTheme.spacingM

            // ── 左：控制台 ────────────────────────────────────
            Rectangle {
                Layout.preferredWidth: 272
                Layout.fillHeight: true
                radius: NovaTheme.radiusM
                color: NovaTheme.surface
                border.width: 1
                border.color: NovaTheme.outline

                NovaScrollArea {
                    id: leftScroll
                    anchors.fill: parent
                    anchors.margins: 1

                    Column {
                        id: leftColumn
                        width: leftScroll.width - 2
                        x: 1
                        spacing: 0
                        Item { width: 1; height: NovaTheme.spacingM }

                        // 文档选择
                        Text {
                            x: NovaTheme.spacingM
                            text: "示例文档 · " + demoTitles.length + " 篇"
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontS
                            font.bold: true
                            color: NovaTheme.textColor
                        }
                        Item { width: 1; height: 6 }
                        NovaBtnToggle {
                            id: docPicker
                            x: NovaTheme.spacingM
                            width: leftColumn.width - NovaTheme.spacingM * 2
                            vertical: true
                            spread: true
                            dense: true
                            size: "sm"
                            flat: true
                            // 必须用真正的 JS 数组：main.py 注入的是 QVariantList，
                            // QML 侧 Array.isArray() 为 False，会让 NovaBtnToggle 归一化为空、高度塌陷。
                            options: {
                                var arr = []
                                for (var i = 0; i < demoTitles.length; i++)
                                    arr.push({ label: demoTitles[i], value: i })
                                return arr
                            }
                            modelValue: 0
                            onValueChanged: function(v) {
                                st.docIndex = v
                                st.cleared = false
                                st.log("nav", "切换到《" + demoTitles[v] + "》")
                            }
                        }

                        Item { width: 1; height: NovaTheme.spacingL }
                        Rectangle { x: NovaTheme.spacingM; width: leftColumn.width - NovaTheme.spacingM * 2; height: 1; color: NovaTheme.outline }

                        // 大纲层级
                        Item { width: 1; height: NovaTheme.spacingM }
                        Text {
                            x: NovaTheme.spacingM
                            text: "大纲层级（tocEnd）"
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontS
                            font.bold: true
                            color: NovaTheme.textColor
                        }
                        Item { width: 1; height: 6 }
                        NovaBtnToggle {
                            id: tocLevelPicker
                            x: NovaTheme.spacingM
                            width: leftColumn.width - NovaTheme.spacingM * 2
                            dense: true
                            size: "sm"
                            spread: true
                            options: [
                                { label: "H1–H3", value: 3 },
                                { label: "H1–H4", value: 4 },
                                { label: "H1–H6", value: 6 }
                            ]
                            modelValue: 3
                            onValueChanged: function(v) {
                                doc.tocEnd = v
                                st.log("toc", "大纲层级设为 H1–H" + v)
                            }
                        }

                        Item { width: 1; height: NovaTheme.spacingL }
                        Rectangle { x: NovaTheme.spacingM; width: leftColumn.width - NovaTheme.spacingM * 2; height: 1; color: NovaTheme.outline }

                        // 开关
                        Item { width: 1; height: NovaTheme.spacingM }
                        Text {
                            x: NovaTheme.spacingM
                            text: "组件属性"
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontS
                            font.bold: true
                            color: NovaTheme.textColor
                        }
                        Item { width: 1; height: 6 }
                        Column {
                            x: NovaTheme.spacingM
                            width: leftColumn.width - NovaTheme.spacingM * 2
                            spacing: 4
                            NovaCheckbox {
                                label: "内置大纲 showToc"
                                modelValue: doc.showToc
                                onValueChanged: function(v) { doc.showToc = v }
                            }
                            NovaCheckbox {
                                label: "卡片边框 outlined"
                                modelValue: doc.outlined
                                onValueChanged: function(v) { doc.outlined = v }
                            }
                            NovaCheckbox {
                                label: "自动打开外链"
                                modelValue: doc.openLinksExternally
                                onValueChanged: function(v) { doc.openLinksExternally = v }
                            }
                        }

                        Item { width: 1; height: NovaTheme.spacingL }
                        Rectangle { x: NovaTheme.spacingM; width: leftColumn.width - NovaTheme.spacingM * 2; height: 1; color: NovaTheme.outline }

                        // 字号
                        Item { width: 1; height: NovaTheme.spacingM }
                        Text {
                            x: NovaTheme.spacingM
                            text: "正文基础字号 · " + st.fontSize + " px"
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontS
                            font.bold: true
                            color: NovaTheme.textColor
                        }
                        Item { width: 1; height: 6 }
                        RowLayout {
                            x: NovaTheme.spacingM
                            width: leftColumn.width - NovaTheme.spacingM * 2
                            spacing: 6
                            NovaBtn {
                                Layout.fillWidth: true
                                text: "A− 缩小"
                                variant: "flat"
                                size: "sm"
                                onClicked: {
                                    st.fontSize = Math.max(11, st.fontSize - 1)
                                    doc.baseFontSize = st.fontSize
                                }
                            }
                            NovaBtn {
                                Layout.fillWidth: true
                                text: "A+ 放大"
                                variant: "flat"
                                size: "sm"
                                onClicked: {
                                    st.fontSize = Math.min(20, st.fontSize + 1)
                                    doc.baseFontSize = st.fontSize
                                }
                            }
                        }

                        Item { width: 1; height: NovaTheme.spacingL }
                        Rectangle { x: NovaTheme.spacingM; width: leftColumn.width - NovaTheme.spacingM * 2; height: 1; color: NovaTheme.outline }

                        // 方法
                        Item { width: 1; height: NovaTheme.spacingM }
                        Text {
                            x: NovaTheme.spacingM
                            text: "方法（Methods）"
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontS
                            font.bold: true
                            color: NovaTheme.textColor
                        }
                        Item { width: 1; height: 6 }
                        RowLayout {
                            x: NovaTheme.spacingM
                            width: leftColumn.width - NovaTheme.spacingM * 2
                            spacing: 6
                            NovaBtn {
                                Layout.fillWidth: true
                                text: "回到顶部"
                                variant: "flat"
                                size: "sm"
                                onClicked: { doc.scrollToTop(); st.log("method", "scrollToTop()") }
                            }
                            NovaBtn {
                                Layout.fillWidth: true
                                text: "重新解析"
                                variant: "flat"
                                size: "sm"
                                onClicked: { doc.reload(); st.log("method", "reload()") }
                            }
                        }
                        Item { width: 1; height: 6 }
                        NovaBtn {
                            x: NovaTheme.spacingM
                            width: leftColumn.width - NovaTheme.spacingM * 2
                            text: st.cleared ? "恢复文档（空态 → 有内容）" : "清空文档（演示空态）"
                            variant: "flat"
                            size: "sm"
                            onClicked: {
                                st.cleared = !st.cleared
                                st.log("method", st.cleared ? "markdown = \"\"" : "恢复 markdown")
                            }
                        }

                        Item { width: 1; height: NovaTheme.spacingM }
                        Text {
                            x: NovaTheme.spacingM
                            width: leftColumn.width - NovaTheme.spacingM * 2
                            text: "提示：本 demo 默认关闭「自动打开外链」，点击文档中的链接只会记录在右侧事件流，不会弹出系统浏览器。"
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontXS
                            color: NovaTheme.textMuted
                            wrapMode: Text.WordWrap
                        }
                        Item { width: 1; height: NovaTheme.spacingM }
                    }
                }
            }

            // ── 中：文档主体 ────────────────────────────────────
            NovaMarkdown {
                id: doc
                Layout.fillWidth: true
                Layout.fillHeight: true
                showToc: true
                tocStart: 1
                tocEnd: 3
                outlined: true
                openLinksExternally: false
                a11yLabel: "NovaMarkdown 演示文档"
                markdown: st.currentText()

                onLinkClicked: function(url) { st.log("link", url) }
                onLinkBlocked: function(url) { st.log("block", url) }
                onTocReady: function(items) { st.log("toc", "大纲解析完成 · " + items.length + " 条") }
            }

            // ── 右：事件流 + 外部大纲 ────────────────────────────
            ColumnLayout {
                Layout.preferredWidth: 268
                Layout.fillHeight: true
                spacing: NovaTheme.spacingM

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.width: 1
                    border.color: NovaTheme.outline

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        spacing: 6
                        Text {
                            text: "信号事件流 · 共 " + st.eventCount + " 条"
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontS
                            font.bold: true
                            color: NovaTheme.textColor
                        }
                        Text {
                            text: "linkClicked / linkBlocked / tocReady 实时记录"
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontXS
                            color: NovaTheme.textMuted
                        }
                        NovaScrollArea {
                            id: eventScroll
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Column {
                                id: eventColumn
                                width: eventScroll.width
                                spacing: 4
                                Item { width: 1; height: 2 }
                                Repeater {
                                    model: st.events
                                    delegate: Rectangle {
                                        id: eventRow
                                        required property var modelData
                                        readonly property string tag:
                                            eventRow.modelData.kind === "block" ? "⛔ 拦截"
                                            : eventRow.modelData.kind === "link" ? "🔗 外链"
                                            : eventRow.modelData.kind === "toc" ? "📑 大纲"
                                            : eventRow.modelData.kind === "method" ? "⚙ 方法"
                                            : "• 导航"
                                        width: eventColumn.width
                                        height: eventText.implicitHeight + 12
                                        radius: NovaTheme.radiusS
                                        color: eventRow.modelData.kind === "block" ? NovaTheme.surfaceAlt : "transparent"
                                        border.width: eventRow.modelData.kind === "block" ? 1 : 0
                                        border.color: NovaTheme.outline
                                        Text {
                                            id: eventText
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            text: eventRow.tag + "  " + eventRow.modelData.text
                                            font.family: NovaTheme.fontFamily
                                            font.pixelSize: NovaTheme.fontXS
                                            color: eventRow.modelData.kind === "block" ? NovaTheme.negative : NovaTheme.textColor
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                }
                                Item { width: 1; height: 2 }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 218
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.width: 1
                    border.color: NovaTheme.outline

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        spacing: 4
                        Text {
                            text: "宿主自定义大纲 · " + doc.toc.length + " 条"
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontS
                            font.bold: true
                            color: NovaTheme.textColor
                        }
                        Text {
                            text: "Repeater { model: doc.toc } → scrollToAnchor()"
                            font.family: NovaTheme.fontFamily
                            font.pixelSize: NovaTheme.fontXS
                            color: NovaTheme.textMuted
                        }
                        NovaScrollArea {
                            id: tocScroll
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Column {
                                id: tocColumn
                                width: tocScroll.width
                                spacing: 2
                                Item { width: 1; height: 2 }
                                Repeater {
                                    model: doc.toc
                                    delegate: NovaBtn {
                                        id: tocBtn
                                        required property var modelData
                                        width: tocColumn.width
                                        x: Math.max(0, (tocBtn.modelData.level - doc.tocStart) * 8)
                                        text: tocBtn.modelData.title
                                        variant: "flat"
                                        size: "sm"
                                        dense: true
                                        tint: NovaTheme.primary
                                        onClicked: {
                                            doc.scrollToAnchor(tocBtn.modelData.anchor)
                                            st.log("method", "scrollToAnchor(\"" + tocBtn.modelData.title + "\")")
                                        }
                                    }
                                }
                                Item { width: 1; height: 2 }
                            }
                        }
                    }
                }
            }
        }

        // ── 底部状态栏 ─────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            radius: NovaTheme.radiusS
            color: NovaTheme.surfaceAlt
            border.width: 1
            border.color: NovaTheme.outline
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: NovaTheme.spacingM
                anchors.rightMargin: NovaTheme.spacingM
                spacing: NovaTheme.spacingL
                Text {
                    Layout.fillWidth: true
                    text: "文档 " + (st.docIndex + 1) + "/" + demoTitles.length
                        + "  ·  " + demoTitles[st.docIndex]
                        + "  ·  " + st.currentText().length + " 字符"
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontXS
                    color: NovaTheme.textMuted
                    elide: Text.ElideRight
                }
                Text {
                    text: "大纲 " + doc.toc.length + " 条  ·  空态 " + (doc.empty ? "是" : "否")
                        + "  ·  层级 H1–H" + doc.tocEnd
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontXS
                    color: NovaTheme.textMuted
                }
            }
        }
    }
}
