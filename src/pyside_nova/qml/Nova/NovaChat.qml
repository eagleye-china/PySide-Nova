// src/pyside_nova/qml/Nova/NovaChat.qml

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: "NovaChat"
    property string userName: "User"
    property string userAvatar: "👨‍💻"
    property string aiName: "AI Assistant"
    property string aiAvatar: "🤖"
    property alias model: chatModel
    property bool isAiThinking: false

    color: Theme.background

    function addUserMessage(text) {
        let timeStr = Qt.formatTime(new Date(), "hh:mm");
        chatModel.append({
            sent: true,
            name: root.userName,
            avatar: root.userAvatar,
            text: text,
            stamp: timeStr,
            isTyping: false
        });
        scrollToBottom();
    }

    function addAiMessage(text, enableTyping = true) {
        let timeStr = Qt.formatTime(new Date(), "hh:mm");
        chatModel.append({
            sent: false,
            name: root.aiName,
            avatar: root.aiAvatar,
            text: text,
            stamp: timeStr,
            isTyping: enableTyping
        });
        scrollToBottom();
    }

    function clearChat() {
        chatModel.clear();
    }

    function scrollToBottom() {
        Qt.callLater(chatListView.positionViewAtEnd);
    }

    signal messageSent(string text)

    ListModel {
        id: chatModel
    }

    // ── 1. 顶部 Header ──
    Rectangle {
        id: header
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        height: Units.px(60)
        color: Theme.surface; border.color: Theme.border; border.width: 1
        z: 10

        Text {
            anchors.centerIn: parent; text: root.title; color: Theme.text_primary; font.pixelSize: Units.px(18); font.bold: true
        }

        NovaButton {
            anchors.right: parent.right; anchors.rightMargin: Units.px(16); anchors.verticalCenter: parent.verticalCenter
            text: "🌓 切换"
            onClicked: {
                let nextMode = (Theme.mode === "light" ? "dark" : "light");
                Theme.mode = nextMode; // 改变 QML 界面
                ThemeManager.mode = nextMode; // 通知 Python 持久化
            }
        }
    }

    // ── 2. 消息列表 ──
    ListView {
        id: chatListView
        anchors.top: header.bottom; anchors.bottom: inputArea.top; anchors.left: parent.left; anchors.right: parent.right
        clip: true; model: chatModel; spacing: Units.px(12); topMargin: Units.px(16); bottomMargin: Units.px(16)
        z: 1

        property bool isFarFromBottom: (contentHeight - height - contentY) > 200
        onContentYChanged: isFarFromBottom = (contentHeight - height - contentY) > 200
        onContentHeightChanged: isFarFromBottom = (contentHeight - height - contentY) > 200

        delegate: NovaChatMessage {
            width: chatListView.width
            sent: model.sent; name: model.name; avatar: model.avatar; text: model.text; stamp: model.stamp; isTyping: model.isTyping
            onTypingProgress: { if (!chatListView.isFarFromBottom) chatListView.positionViewAtEnd(); }
            onImplicitHeightChanged: { if (!chatListView.isFarFromBottom) chatListView.positionViewAtEnd(); }
        }
        onCountChanged: scrollToBottom()
    }

    // ── 3. 底部输入区 ──
    Rectangle {
        id: inputArea
        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
        height: inputContainer.implicitHeight + Units.px(16)
        color: Theme.surface; border.color: Theme.border; border.width: 1
        z: 10

        Rectangle {
            id: inputContainer
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: Units.px(16)
            implicitHeight: inputLayout.implicitHeight + Units.px(8)
            radius: Theme.radiusMd; color: Theme.background
            border.color: inputText.activeFocus ? Theme.primary : Theme.border; border.width: 1

            ColumnLayout {
                id: inputLayout
                anchors.fill: parent; anchors.margins: Units.px(8); spacing: Units.px(8)

                ScrollView {
                    Layout.fillWidth: true; Layout.preferredHeight: Math.min(inputText.implicitHeight, Units.px(120)); clip: true
                    TextArea {
                        id: inputText
                        placeholderText: "输入你想说的话... (Enter 发送)"
                        placeholderTextColor: Theme.text_secondary
                        color: Theme.text_primary; font.pixelSize: Units.px(14); wrapMode: TextArea.Wrap; background: null; selectByMouse: true
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (!event.modifiers) {
                                    triggerSend();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: Units.px(8)
                    z: 20

                    NovaButton {
                        text: "😀"
                        flat: true
                        implicitWidth: Units.px(40)
                        implicitHeight: Units.px(32)
                        onClicked: emojiPanel.visible = !emojiPanel.visible
                    }

                    NovaButton {
                        text: "📁"
                        flat: true
                        implicitWidth: Units.px(40)
                        implicitHeight: Units.px(32)
                        onClicked: filePanel.visible = !filePanel.visible
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    NovaButton {
                        text: root.isAiThinking ? "思考中..." : "发送"
                        primary: true
                        Layout.preferredHeight: Units.px(32)
                        enabled: inputText.text.trim().length > 0 && !root.isAiThinking
                        onClicked: triggerSend()
                    }
                }
            }
        }
    }

    // ── 4. 弹窗面板 ──
    Rectangle {
        id: emojiPanel
        visible: false
        width: Units.px(280); height: Units.px(120)
        anchors.bottom: inputArea.top; anchors.left: parent.left; anchors.leftMargin: Units.px(16); anchors.bottomMargin: Units.px(10)
        color: Theme.surface; border.color: Theme.border; radius: Theme.radiusMd
        z: 100

        Grid {
            anchors.centerIn: parent
            columns: 6
            spacing: Units.px(12)
            Repeater {
                model: ["😀", "😂", "🤣", "😊", "😍", "🤔", "😎", "😭", "😡", "👍", "🙏", "❤️"]
                delegate: Text {
                    text: modelData; font.pixelSize: Units.px(24)
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { inputText.text += modelData; emojiPanel.visible = false; }
                    }
                }
            }
        }
    }

    Rectangle {
        id: filePanel
        visible: false
        width: Units.px(160); height: Units.px(100)
        anchors.bottom: inputArea.top; anchors.left: parent.left; anchors.leftMargin: Units.px(56); anchors.bottomMargin: Units.px(10)
        color: Theme.surface; border.color: Theme.border; radius: Theme.radiusMd
        z: 100

        Column {
            anchors.fill: parent
            Rectangle {
                width: parent.width; height: Units.px(40); color: fileM1.containsMouse ? Theme.hover : "transparent"
                Text {
                    anchors.centerIn: parent; text: "📄 发送文件"; color: Theme.text_primary; font.pixelSize: Units.px(14)
                }
                MouseArea {
                    id:
                        fileM1; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: filePanel.visible = false
                }
            }
            Rectangle {
                width: parent.width; height: Units.px(40); color: fileM2.containsMouse ? Theme.hover : "transparent"
                Text {
                    anchors.centerIn: parent; text: "🖼️ 发送图片"; color: Theme.text_primary; font.pixelSize: Units.px(14)
                }
                MouseArea {
                    id:
                        fileM2; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: filePanel.visible = false
                }
            }
        }
    }

    function triggerSend() {
        let txt = inputText.text.trim();
        if (txt === "" || root.isAiThinking) return;
        addUserMessage(txt);
        inputText.text = "";
        root.messageSent(txt);
    }
}