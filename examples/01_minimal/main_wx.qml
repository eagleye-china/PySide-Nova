// examples/01_minimal/main.qml

import QtQuick
import QtQuick.Controls.Basic
import Nova 1.0

ApplicationWindow {
    visible: true
    width: 900
    height: 800
    title: "Nova-Orbit (真实大模型流式对话)"
    color: Theme.background

    NovaChat {
        id: chatWindow
        anchors.fill: parent
        title: "Nova-Orbit 🤖 (DeepSeek 驱动)"
        userName: "单保录"
        userAvatar: "👨‍💻"
        aiName: "小诺 (DeepSeek)"
        aiAvatar: "🤖"

        Component.onCompleted: {
            addAiMessage("你好，单保录！我已成功接入 **DeepSeek 大模型**。由于是真实的流式网络传输，你可以看到我打字的速度跟网络延迟有关。输入内容跟我对话吧！🚀", false)
        }

        onMessageSent: (text) => {
            isAiThinking = true

            // 插入空气泡等待流式填满
            let timeStr = Qt.formatTime(new Date(), "hh:mm");
            model.append({
                sent: false,
                name: aiName,
                avatar: aiAvatar,
                text: "",
                stamp: timeStr,
                isTyping: false
            });

            scrollToBottom()

            // 呼叫 Python 桥接器
            ChatBridge.sendMessage(text)
        }
    }

    // 接收 Python 后台线程发来的流式片段
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

        // ✅ 接收工具日志（可以扩充为在 UI 上弹 Toast，或者插入系统气泡）
        function onActionLogged(log) {
            console.log("⚙️ [AI 执行日志]:", log);
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