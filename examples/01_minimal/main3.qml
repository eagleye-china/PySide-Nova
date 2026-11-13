// examples/01_minimal/main.qml

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Nova 1.0

ApplicationWindow {
    visible: true
    width: 900
    height: 800
    title: "NovaChat (对标微信)"
    color: Theme.background

    // 数据模型
    ListModel {
        id: chatModel
    }

    // 初始化一条消息
    Component.onCompleted: {
        chatModel.append({
            sent: false,
            name: "小诺 (AI)",
            avatar: "🤖",
            text: "你好，单保录！我是你的 AI 架构师小诺。在这里输入内容，尝试与我对话吧！",
            stamp: "10:32",
            isTyping: true // 初始消息也带打字机
        })
    }

    // 顶部 Header
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Units.px(60)
        color: Theme.surface
        border.color: Theme.border
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "NovaChat"
            color: Theme.text_primary
            font.pixelSize: Units.px(18)
            font.bold: true
        }

        NovaButton {
            anchors.right: parent.right
            anchors.rightMargin: Units.px(16)
            anchors.verticalCenter: parent.verticalCenter
            text: "🌓"
            primary: false
            onClicked: ThemeManager.mode = (Theme.mode === "light" ? "dark" : "light")
        }
    }

    // 底部输入区
    Rectangle {
        id: inputArea
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: inputLayout.implicitHeight + Units.px(24)
        color: Theme.surface
        border.color: Theme.border
        border.width: 1

        RowLayout {
            id: inputLayout
            anchors.fill: parent
            anchors.margins: Units.px(12)
            spacing: Units.px(12)

            // 输入框外壳
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(inputText.implicitHeight + Units.px(16), Units.px(120))
                radius: Theme.radiusSm
                color: Theme.background
                border.color: inputText.activeFocus ? Theme.primary : Theme.border
                border.width: 1

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: Units.px(8)
                    clip: true

                    TextArea {
                        id: inputText
                        placeholderText: "输入你想说的话... (Enter 发送)"
                        placeholderTextColor: Theme.text_secondary
                        color: Theme.text_primary
                        font.pixelSize: Units.px(14)
                        wrapMode: TextArea.Wrap
                        background: null // 隐藏自带的丑陋边框
                        selectByMouse: true

                        // 监听键盘事件
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (!event.modifiers) {
                                    sendMessage();
                                    event.accepted = true; // 拦截回车，不换行
                                }
                            }
                        }
                    }
                }
            }

            // 发送按钮
            NovaButton {
                text: "发送"
                primary: true
                Layout.preferredHeight: Units.px(38)
                onClicked: sendMessage()
            }
        }
    }

    // 消息列表
    ListView {
        id: chatListView
        anchors.top: header.bottom
        anchors.bottom: inputArea.top
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
        model: chatModel
        spacing: Units.px(12)
        topMargin: Units.px(16)
        bottomMargin: Units.px(16)

        // 自动滚动到底部
        function scrollToBottom() {
            Qt.callLater(chatListView.positionViewAtEnd);
        }

        delegate: Item {
            width: chatListView.width
            height: msgItem.implicitHeight

            NovaChatMessage {
                id: msgItem
                width: parent.width
                sent: model.sent
                name: model.name
                avatar: model.avatar
                text: model.text
                stamp: model.stamp
                isTyping: model.isTyping

                onTypingProgress: chatListView.scrollToBottom()
                onImplicitHeightChanged: chatListView.scrollToBottom()
            }
        }

        // 当有新消息添加时，自动滚动
        onCountChanged: {
            chatListView.scrollToBottom();
        }
    }

    // 发送消息逻辑
    function sendMessage() {
        let txt = inputText.text.trim();
        if (txt === "") return;

        // 1. 添加用户消息
        let now = new Date();
        let timeStr = now.getHours().toString().padStart(2, '0') + ":" + now.getMinutes().toString().padStart(2, '0');

        chatModel.append({
            sent: true,
            name: "单保录",
            avatar: "👨‍💻",
            text: txt,
            stamp: timeStr,
            isTyping: false
        });

        // 清空输入框
        inputText.text = "";

        // 2. 模拟 AI 回复 (延迟 800ms 后开始打字)
        aiReplyTimer.start();
    }

    Timer {
        id: aiReplyTimer
        interval: 800
        repeat: false
        onTriggered: {
            let now = new Date();
            let timeStr = now.getHours().toString().padStart(2, '0') + ":" + now.getMinutes().toString().padStart(2, '0');

            chatModel.append({
                sent: false,
                name: "小诺 (AI)",
                avatar: "🤖",
                text: "收到！这是一个极其优雅的 QML 架构实现。\n让我们继续按照《架构宪法》**严格推进**吧！🚀",
                stamp: timeStr,
                isTyping: true // 🚀 开启打字机效果
            });
        }
    }
}