// examples/01_minimal/main.qml

import QtQuick
import QtQuick.Controls.Basic
import Nova 1.0

ApplicationWindow {
    visible: true
    width: 1000
    height: 800
    title: "Nova-Agentic (终极 QML 版)"
    color: Theme.background

    NovaChat {
        id: chatWindow
        anchors.fill: parent
        title: "Nova-Orbit 🤖"
        userName: "单保录"
        userAvatar: "👨‍💻"
        aiName: "小诺 (Agentic)"
        aiAvatar: "🤖"

        Component.onCompleted: {
            // 同步 Python 的初始主题
            if (typeof ThemeManager !== "undefined" && ThemeManager !== null) {
                Theme.mode = ThemeManager.mode;
            }
            addAiMessage("你好！我是你的 AI 架构师小诺。现在底层已经完全由 Python 后台流式驱动，并且开启了工具调用！\n\n你可以试着对我说：**帮我读取一下 `NovaChat.qml` 的代码**，或者让我**在根目录建一个 test.txt**。🚀", false)
        }

        // 拦截发送信号
        onMessageSent: (text) => {
            isAiThinking = true

            // 在界面上先插入一个空白的 AI 气泡
            let timeStr = Qt.formatTime(new Date(), "hh:mm");
            model.append({
                sent: false, name: aiName, avatar: aiAvatar,
                text: "", stamp: timeStr, isTyping: false
            });
            scrollToBottom()

            // 发给 Python
            ChatBridge.sendMessage(text)
        }
    }

    // ✅ 监听 Python 流式信号
    Connections {
        target: ChatBridge

        // 1. 流式接收文本块并追加到最后一条气泡
        function onChunkReceived(chunk) {
            let lastIndex = chatWindow.model.count - 1;
            if (lastIndex >= 0) {
                let currentText = chatWindow.model.get(lastIndex).text;
                chatWindow.model.setProperty(lastIndex, "text", currentText + chunk);
                chatWindow.scrollToBottom();
            }
        }

        // 2. 接收系统工具执行日志（渲染为灰色特殊气泡）
        function onActionLogged(log) {
            chatWindow.addSystemMessage(log);
        }

        // 3. 结束/错误状态复位
        function onReplyFinished() {
            chatWindow.isAiThinking = false;
        }

        function onReplyError(err) {
            chatWindow.isAiThinking = false;
            chatWindow.addAiMessage("❌ **API 请求失败**: " + err, false);
        }
    }
}