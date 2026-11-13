// examples/01_minimal/main.qml

import QtQuick
import QtQuick.Controls.Basic
import Nova 1.0

ApplicationWindow {
    visible: true
    width: 900
    height: 800
    title: "Nova-Agentic (工具调用版)"
    color: Theme.background
    Component.onCompleted: {
        if (typeof ThemeManager !== "undefined" && ThemeManager !== null) {
            Theme.mode = ThemeManager.mode;
        }
    }


    NovaChat {
        id: chatWindow
        anchors.fill: parent
        title: "Nova-Agentic 🤖"
        userName: "单保录"
        userAvatar: "👨‍💻"
        aiName: "小诺 (Agentic)"
        aiAvatar: "🤖"

        Component.onCompleted: {
            addAiMessage("你好，单保录！我已接入 DeepSeek 并开启了**工具调用（Function Calling）**。试试叫我：\n`帮我读取一下 NovaButton.qml 的代码。`\n\n或者：\n`帮我在根目录建一个 test.txt，内容是 Hello Nova。` 🚀", false)
        }

        onMessageSent: (text) => {
            isAiThinking = true

            let timeStr = Qt.formatTime(new Date(), "hh:mm");
            model.append({
                sent: false, name: aiName, avatar: aiAvatar,
                text: "", stamp: timeStr, isTyping: false
            });
            scrollToBottom()

            ChatBridge.sendMessage(text)
        }
    }

    Connections {
        target: ChatBridge

        function onChunkReceived(chunk) {
            let lastIndex = chatWindow.model.count - 1;
            if (lastIndex >= 0) {
                let currentText = chatWindow.model.get(lastIndex).text;
                chatWindow.model.setProperty(lastIndex, "text", currentText + chunk);
                chatWindow.scrollToBottom();
            }
        }

        // ✅ 核心：接收并渲染工具执行日志
        function onActionLogged(log) {
            console.log("⚙️", log);
            // 在界面上插一个系统灰条气泡，提示当前正在干嘛
            let timeStr = Qt.formatTime(new Date(), "hh:mm");
            chatWindow.model.append({
                sent: false, name: "⚙️ 系统工具", avatar: "🛠️",
                text: "```text\n" + log + "\n```", // 用 Markdown 代码块让日志变灰底
                stamp: timeStr, isTyping: false
            });
            chatWindow.scrollToBottom();
        }

        function onReplyFinished() {
            chatWindow.isAiThinking = false;
        }

        function onReplyError(err) {
            chatWindow.isAiThinking = false;
            chatWindow.addAiMessage("❌ 报错: " + err, false);
        }
    }
}