// examples/layout_shell/chat/main.qml
// NovaChat 独立演示 · 成品级 Showcase：六槽真实业务注入 / 调参面板默认收起 / 真实交互位 / 明暗双主题
// 运行：python examples/layout_shell/chat/run.py
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    // 主题模式：signature=专属（深底+组件专属色相，默认） / light=亮色（浅底+全局品牌蓝）
    property string themeMode: "signature"
    onThemeModeChanged: NovaTheme.setDark(win.themeMode === "signature")
    function toggleTheme() {
        win.themeMode = (win.themeMode === "signature") ? "light" : "signature"
    }
    width: 1280
    height: 800
    minimumWidth: 720
    minimumHeight: 520
    visible: true
    title: "NovaChat · AI 对话工作台（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: { NovaScreen.source = win; NovaTheme.setDark(win.themeMode === "signature") }

    property bool collapsed: false
    property bool showBars: true
    property bool variantMode: false      // CARF 复评：三态出图统一变体开关
    property int panelSize: 300
    property string lastSignal: "（等待交互）"
    property int signalCount: 0
    property bool paramsOpen: false
    property string draft: ""
    property var messages: []
    function logSignal(msg) {
        win.signalCount = win.signalCount + 1
        win.lastSignal = "#" + win.signalCount + "  " + msg
    }
    function send() {
        if (win.draft.trim() === "") return
        var next = win.messages.concat([{ who: "me", body: win.draft, stamp: "刚刚" }])
        win.messages = next
        win.draft = ""
        win.logSignal("messageSent(" + next.length + ")")
    }

    // ── 顶部应用条 ──
    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 48
        color: NovaTheme.surface
        z: NovaTheme.zFixedDrawer + 1
        Text {
            id: titleText
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "NovaChat  ·  AI 对话工作台"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "导航轨 / 会话列 / 对话区 / 输入区 / 详情栏"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        // 主题切换（纯几何日月，零字体依赖）
        Rectangle {
            id: themeBtn
            anchors { right: parent.right; rightMargin: 56; verticalCenter: parent.verticalCenter }
            width: 30; height: 30; radius: 15
            color: NovaTheme.surfaceAlt
            border { width: 1; color: NovaTheme.outline }
            // 主题模式：专属（深底+专属色） / 亮色（浅底+品牌蓝）——点击切换
            Rectangle {
                anchors.centerIn: parent
                width: 14; height: 14; radius: 7
                color: win.themeMode === "signature" ? Qt.lighter(NovaTheme.primary, 1.25) : "transparent"
                border { width: 1; color: win.themeMode === "signature" ? Qt.lighter(NovaTheme.primary, 1.25) : NovaTheme.primary }
                Rectangle {
                    anchors.centerIn: parent
                    width: 6; height: 6; radius: 3
                    color: win.themeMode === "signature" ? NovaTheme.surfaceAlt : NovaTheme.primary
                }
            }
            MouseArea { anchors.fill: parent; onClicked: win.toggleTheme() }
        }
        // 调参开关（纯几何三横线）
        Rectangle {
            id: paramsBtn
            anchors { right: parent.right; rightMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            width: 30; height: 30; radius: 8
            color: win.paramsOpen ? NovaTheme.primary : NovaTheme.surfaceAlt
            border { width: 1; color: win.paramsOpen ? NovaTheme.primary : NovaTheme.outline }
            Column {
                anchors.centerIn: parent
                spacing: 3
                Repeater {
                    model: 3
                    Rectangle { width: 14; height: 2; radius: 1; color: win.paramsOpen ? NovaTheme.textOnPrimary : NovaTheme.textMuted }
                }
            }
            MouseArea { anchors.fill: parent; onClicked: win.paramsOpen = !win.paramsOpen }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

    // ── 主舞台：六槽全部注入真实业务内容（不再是占位色块）──
    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaChat {
            id: shell
            _signatureOn: win.themeMode === "signature"
            anchors.fill: parent
            navSize: 56
            conversationSize: win.panelSize
            detailSize: win.panelSize
            conversationCollapsed: win.collapsed || win.variantMode
            detailCollapsed: win.collapsed || win.variantMode
            showNav: win.showBars && !win.variantMode
            showHeader: win.showBars && !win.variantMode
            showComposer: win.showBars && !win.variantMode
            onNavToggled: function(c) { win.logSignal("navToggled(" + c + ")") }
            onConversationToggled: function(c) { win.logSignal("conversationToggled(" + c + ")"); win.collapsed = c }
            onDetailToggled: function(c) { win.logSignal("detailToggled(" + c + ")"); win.collapsed = c }

            // ① 导航轨：4 个导航位（业务真实交互位）
            navSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { top: parent.top; topMargin: 52; horizontalCenter: parent.horizontalCenter }
                    spacing: 14
                    Repeater {
                        model: 4
                        Rectangle {
                            required property int index
                            width: 24; height: 24; radius: 7
                            color: index === 0 ? NovaTheme.primary
                                  : (navArea.containsMouse ? NovaTheme.surfaceAlt : "transparent")
                            border { width: index === 0 ? 0 : 1; color: NovaTheme.outline }
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8; height: 8; radius: 2
                                color: index === 0 ? NovaTheme.textOnPrimary : NovaTheme.textMuted
                            }
                            MouseArea {
                                id: navArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.logSignal("nav(" + index + ")")
                            }
                        }
                    }
                }
            }

            // ② 会话列：搜索框 + 4 条真实会话
            conversationSlot: Item {
                anchors.fill: parent
                Rectangle {
                    id: searchBox
                    anchors { top: parent.top; topMargin: 12; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    height: 34; radius: 8
                    color: NovaTheme.surface
                    border { width: 1; color: NovaTheme.outline }
                    Row {
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                        spacing: 8
                        Rectangle { width: 10; height: 10; radius: 5; color: "transparent"; border { width: 1.5; color: NovaTheme.textMuted } }
                        Text { text: "搜索会话"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                    }
                }
                Column {
                    id: convList
                    anchors { top: searchBox.bottom; topMargin: 12; left: parent.left; right: parent.right }
                    Repeater {
                        model: [
                            { title: "Nova 工作台", preview: "六轨装配已完成密度对齐", stamp: "10:02", unread: 2 },
                            { title: "设计评审", preview: "令牌与层级方案已确认", stamp: "昨天", unread: 0 },
                            { title: "发布清单", preview: "1.0.0 已上架 PyPI", stamp: "周一", unread: 0 },
                            { title: "无障碍回归", preview: "键盘可达与 RTL 全通过", stamp: "周一", unread: 0 }
                        ]
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: convList.width
                            height: 64
                            color: index === 0 ? Qt.lighter(NovaTheme.surfaceAlt, 1.08) : "transparent"
                            Rectangle {
                                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                width: 2
                                color: NovaTheme.primary
                                visible: index === 0
                            }
                            Row {
                                anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                spacing: 10
                                Rectangle {
                                    width: 34; height: 34; radius: 17
                                    color: index === 0 ? NovaTheme.primary : NovaTheme.surfaceAlt
                                    border { width: 1; color: NovaTheme.outline }
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 12; height: 12; radius: 6
                                        color: index === 0 ? NovaTheme.textOnPrimary : NovaTheme.textMuted
                                    }
                                }
                                Column {
                                    width: parent.width - 44 - (modelData.unread > 0 ? 24 : 0)
                                    spacing: 3
                                    Text {
                                        text: modelData.title
                                        color: NovaTheme.textColor
                                        font { pixelSize: NovaTheme.fontS; bold: true }
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                    Text {
                                        text: modelData.preview
                                        color: NovaTheme.textMuted
                                        font.pixelSize: NovaTheme.fontXS
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }
                            }
                            Text {
                                anchors { right: parent.right; rightMargin: 12; top: parent.top; topMargin: 12 }
                                text: modelData.stamp
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                            }
                            Rectangle {
                                anchors { right: parent.right; rightMargin: 12; bottom: parent.bottom; bottomMargin: 12 }
                                width: 18; height: 18; radius: 9
                                color: NovaTheme.primary
                                visible: modelData.unread > 0
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.unread
                                    color: NovaTheme.textOnPrimary
                                    font.pixelSize: 10
                                }
                            }
                            MouseArea { anchors.fill: parent; onClicked: win.logSignal("conversation(" + index + ")") }
                        }
                    }
                }
            }

            // ③ 会话头：头像 + 名称 + 状态 + 操作位
            headerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
                    spacing: 10
                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: NovaTheme.primary
                        Rectangle { anchors.centerIn: parent; width: 12; height: 12; radius: 6; color: NovaTheme.textOnPrimary }
                    }
                    Column {
                        spacing: 1
                            Text { text: "Nova 工作台"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                            Text { text: "在线 · 3 位成员"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                        }
                    }
                    Rectangle {
                        anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                        width: 78; height: 28; radius: 14
                        color: membersArea.containsMouse ? NovaTheme.surfaceAlt : "transparent"
                        border { width: 1; color: NovaTheme.outline }
                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Rectangle { width: 6; height: 6; radius: 3; color: NovaTheme.positive }
                            Text { text: "成员 3"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                        }
                        MouseArea {
                            id: membersArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: win.logSignal("members()")
                        }
                    }
                }

                // ④ 对话区：日期分组 + 真实气泡 + 发送回显（填满中央，不留空板）
                contentSlot: Item {
                    anchors.fill: parent
                    Flickable {
                        id: msgFlick
                        anchors.fill: parent
                        contentWidth: width
                        // CC-6 内容基线：不足一屏贴底（真实 IM 节奏），超出一屏顶对齐且可滚动
                        contentHeight: Math.max(msgFlick.height, msgCol.implicitHeight + 16)
                        clip: true
                        Item {
                            id: msgStage
                            width: msgFlick.width
                            height: msgFlick.contentHeight
                            Column {
                                id: msgCol
                                width: Math.min(msgStage.width, 720)
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    top: parent.top
                                    topMargin: Math.max(0, msgStage.height - msgCol.implicitHeight - 16)
                                }
                                spacing: 12
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "今天  10:00"
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                            }
                            NovaChatMessage {
                                width: msgCol.width; size: 9
                                sent: false; name: "Nova"
                                text: ["你好，我是 Nova。", "这是可直接复用的 AI 对话工作台示例。"]
                                stamp: "10:00"
                            }
                            NovaChatMessage {
                                width: msgCol.width; size: 9
                                sent: true
                                text: "收到，六槽都由业务注入。"
                                stamp: "10:01"
                            }
                            NovaChatMessage {
                                width: msgCol.width; size: 9
                                sent: false; name: "Nova"
                                text: ["密度栅格、唯一分隔源、层级与动效已对齐。", "折叠动画共用同一时长与缓动，锚链恒定不跳变。"]
                                stamp: "10:02"
                            }
                            NovaChatMessage {
                                width: msgCol.width; size: 9
                                sent: true
                                text: "身份装饰也收敛成抽象几何了，不再有伪按钮。"
                                stamp: "10:03"
                            }
                            Repeater {
                                model: win.messages
                                NovaChatMessage {
                                    required property var modelData
                                    width: msgCol.width; size: 9
                                    sent: true
                                    text: modelData.body
                                    stamp: modelData.stamp
                                }
                        }
                    }
                }
                }
            }

            // ⑤ 输入区：工具栏 + 真实输入框 + 可点击发送
            composerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 10 }
                    spacing: 10
                    Repeater {
                        model: ["attach", "emoji", "more"]
                        Rectangle {
                            required property int index
                            required property string modelData
                            width: 22; height: 22; radius: 6
                            color: toolArea.containsMouse ? NovaTheme.primary : NovaTheme.surfaceAlt
                            border { width: 1; color: toolArea.containsMouse ? NovaTheme.primary : NovaTheme.outline }
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8; height: 8
                                radius: index === 1 ? 4 : 1
                                rotation: index === 0 ? 45 : 0
                                color: "transparent"
                                border { width: 1.5; color: toolArea.containsMouse ? NovaTheme.textOnPrimary : NovaTheme.textMuted }
                            }
                            MouseArea {
                                id: toolArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.logSignal("tool(" + modelData + ")")
                            }
                        }
                    }
                }
                Rectangle {
                    id: inputBox
                    width: Math.min(parent.width - 24, 880)
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top; topMargin: 36
                        bottom: parent.bottom; bottomMargin: 12
                    }
                    radius: 10
                    color: NovaTheme.surface
                    border { width: 1; color: NovaTheme.outlineStrong }
                    TextInput {
                        id: input
                        anchors { left: parent.left; leftMargin: 12; right: sendBtn.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                        color: NovaTheme.textColor
                        font.pixelSize: NovaTheme.fontS
                        selectByMouse: true
                        text: win.draft
                        onTextEdited: win.draft = text
                        onAccepted: win.send()
                    }
                    Text {
                        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                        text: "输入消息，回车发送…"
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontS
                        visible: input.text === ""
                    }
                    Rectangle {
                        id: sendBtn
                        anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                        width: 34; height: 34; radius: 17
                        color: NovaTheme.primary
                        Rectangle { anchors.centerIn: parent; width: 12; height: 2; radius: 1; color: NovaTheme.textOnPrimary }
                        Rectangle {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 5; anchors.verticalCenterOffset: -3
                            width: 7; height: 2; radius: 1; rotation: 45
                            color: NovaTheme.textOnPrimary
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 5; anchors.verticalCenterOffset: 3
                            width: 7; height: 2; radius: 1; rotation: -45
                            color: NovaTheme.textOnPrimary
                        }
                        MouseArea { anchors.fill: parent; onClicked: win.send() }
                    }
                }
            }

            // ⑥ 详情栏：会话信息 + 成员 + 引用卡片
            detailSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16; top: parent.top; topMargin: 36 }
                    spacing: 14
                    Rectangle {
                        width: 48; height: 48; radius: 24
                        color: NovaTheme.primary
                        anchors.horizontalCenter: parent.horizontalCenter
                        Rectangle { anchors.centerIn: parent; width: 20; height: 20; radius: 10; color: NovaTheme.textOnPrimary }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Nova 工作台"
                        color: NovaTheme.textColor
                        font { pixelSize: NovaTheme.fontM; bold: true }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "3 位成员 · 创建于今天"
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                    }
                    NovaSeparator { width: parent.width }
                    Text { text: "成员"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Repeater {
                        model: ["小诺  ·  架构", "CSA  ·  产品", "验收  ·  质量"]
                        Row {
                            required property string modelData
                            width: parent.width
                            spacing: 8
                            Rectangle { width: 24; height: 24; radius: 12; color: NovaTheme.surfaceAlt; border { width: 1; color: NovaTheme.outline } }
                            Text {
                                text: modelData
                                color: NovaTheme.textColor
                                font.pixelSize: NovaTheme.fontS
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                    NovaSeparator { width: parent.width }
                    Text { text: "引用"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Rectangle {
                        width: parent.width; height: 56; radius: 10
                        color: NovaTheme.surface
                        border { width: 1; color: NovaTheme.outline }
                        Column {
                            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                            spacing: 3
                            Text { text: "组合态一致性契约 CC"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                            Text { text: "CONSTITUTION.md · 0.9.0"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                        }
                    }
                }
            }

            overlaySlot: Item {}
        }
    }

    // ── 调参面板：默认收起的浮层，与展示区彻底分离（CC-6）──
    Rectangle {
        id: params
        anchors { top: topBar.bottom; bottom: statusBar.top; right: parent.right }
        width: 232
        visible: win.paramsOpen
        z: NovaTheme.zFixedDrawer
        color: NovaTheme.surface
        NovaSeparator { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } }
        Flickable {
            anchors.fill: parent
            anchors.margins: NovaTheme.spacingM
            contentHeight: paramCol.implicitHeight + NovaTheme.spacingM
            clip: true
            Column {
                id: paramCol
                anchors { top: parent.top; left: parent.left; right: parent.right }
                spacing: NovaTheme.spacingM
                Text { text: "调参面板"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                Text { text: "NovaChat · 收起/展开不影响展示"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "会话列/详情折叠"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.collapsed; onCheckedChanged: win.collapsed = checked }
                }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示导航/Header/输入区"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Column {
                    spacing: 4
                    Text { text: "栏宽 " + win.panelSize; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 200; from: 120; to: 420; stepSize: 20; value: win.panelSize; onValueChanged: win.panelSize = value }
                }
                Text {
                    text: "气泡由 NovaChatMessage 真实渲染；主窗口只托管六槽布局。"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                    wrapMode: Text.Wrap
                }
                Text {
                    text: "signal · " + win.lastSignal
                    color: NovaTheme.primary
                    font.pixelSize: NovaTheme.fontXS
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    // ── 底部状态条 ──
    Rectangle {
        id: statusBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: NovaTheme.surfaceAlt
        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            spacing: 8
            Rectangle { width: 6; height: 6; radius: 3; color: NovaTheme.positive; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: "已连接  ·  3 位成员在线  ·  消息已同步"
                color: NovaTheme.textMuted
                font.pixelSize: NovaTheme.fontXS
            }
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "NovaChat · 1.0.0 GA · " + (win.themeMode === "signature" ? "专属" : "亮色")
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }
}
