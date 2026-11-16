// src/pyside_nova/qml/Nova/NovaChat.qml
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: root

    signal themeToggleRequested()

    signal messageSent(string text)

    signal copyCodeRequested(string base64Code) // 根节点声明

    property string title: "NovaChat"
    property string userName: "User"
    property string userAvatar: "👨‍💻"
    property string aiName: "AI Assistant"
    property string aiAvatar: "🤖"
    property alias model: chatModel
    property bool isAiThinking: false

    color: Theme.background

    ListModel {
        id: chatModel
    }

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

    function addSystemMessage(text) {
        let timeStr = Qt.formatTime(new Date(), "hh:mm");
        chatModel.append({
            sent: false,
            name: "⚙️ 系统工具",
            avatar: "🛠️",
            text: text,
            stamp: timeStr,
            isTyping: false,
            isSystem: true
        });
        scrollToBottom();
    }

    function scrollToBottom() {
        Qt.callLater(chatListView.positionViewAtEnd);
    }

    Rectangle {
        id: header
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        height: Units.px(60); color: Theme.surface; border.color: Theme.border; border.width: 1; z: 10

        Text {
            anchors.centerIn: parent; text: root.title; color: Theme.text_primary; font.pixelSize: Units.px(18); font.bold: true
        }

        Rectangle {
            width: Units.px(80); height: Units.px(36)
            anchors.right: parent.right; anchors.rightMargin: Units.px(16); anchors.verticalCenter: parent.verticalCenter
            color: btnMouse.pressed ? Qt.darker(Theme.primary, 1.2) : (btnMouse.containsMouse ? Qt.lighter(Theme.primary, 1.1) : Theme.primary)
            radius: Theme.radiusSm

            Text {
                anchors.centerIn: parent; text: "🌓 切换"; color: "white"; font.bold: true
            }
            MouseArea {
                id: btnMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: root.themeToggleRequested()
            }
        }
    }

    ListView {
        id: chatListView
        anchors.top: header.bottom; anchors.bottom: inputArea.top; anchors.left: parent.left; anchors.right: parent.right
        clip: true; model: chatModel; spacing: Units.px(12); topMargin: Units.px(16); bottomMargin: Units.px(16); z: 1

        delegate: NovaChatMessage {
            width: chatListView.width
            sent: model.sent; name: model.name; avatar: model.avatar; text: model.text; stamp: model.stamp; isTyping: model.isTyping
            isSystem: model.isSystem ? true : false
            onCopyCodeRequested: (base64Code) => {
                root.copyCodeRequested(base64Code)
            }
        }
        onCountChanged: scrollToBottom()
    }

    Rectangle {
        id: inputArea
        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
        height: inputContainer.implicitHeight + Units.px(16)
        color: Theme.surface; border.color: Theme.border; border.width: 1; z: 10

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
                        color: Theme.text_primary; font.pixelSize: Units.px(14); wrapMode: TextArea.Wrap; background: null
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
                    Item {
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        width: Units.px(64); height: Units.px(32); radius: Theme.radiusSm
                        color: root.isAiThinking ? Theme.disabled : Theme.primary
                        Text {
                            anchors.centerIn: parent; text: root.isAiThinking ? "思考中..." : "发送"; color: "white"
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: root.isAiThinking ? Qt.ArrowCursor : Qt.PointingHandCursor
                            enabled: !root.isAiThinking && inputText.text.trim().length > 0
                            onClicked: triggerSend()
                        }
                    }
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