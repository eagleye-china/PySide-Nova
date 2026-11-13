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

    ListModel {
        id: chatModel
    }

    Component.onCompleted: {
        chatModel.append({
            sent: false,
            name: "小诺 (AI)",
            avatar: "🤖",
            text: "你好，单保录！尝试点击右下角的 **悬浮按钮 ＋**，看看展开的子菜单吧！🚀",
            stamp: "10:32",
            isTyping: true
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

    // 底部高级输入区
    Rectangle {
        id: inputArea
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: inputContainer.implicitHeight + Units.px(16)
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        z: 10

        Rectangle {
            id: inputContainer
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Units.px(16)
            implicitHeight: inputLayout.implicitHeight + Units.px(8)
            radius: Theme.radiusMd
            color: Theme.background
            border.color: inputText.activeFocus ? Theme.primary : Theme.border
            border.width: 1

            ColumnLayout {
                id: inputLayout
                anchors.fill: parent
                anchors.margins: Units.px(8)
                spacing: Units.px(8)

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(inputText.implicitHeight, Units.px(120))
                    clip: true

                    TextArea {
                        id: inputText
                        placeholderText: "输入你想说的话... (Enter 发送)"
                        placeholderTextColor: Theme.text_secondary
                        color: Theme.text_primary
                        font.pixelSize: Units.px(14)
                        wrapMode: TextArea.Wrap
                        background: null
                        selectByMouse: true

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (!event.modifiers) {
                                    sendMessage();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Units.px(4)

                    component ToolIcon: Item {
                        property string iconText: ""
                        implicitWidth: Units.px(32)
                        implicitHeight: Units.px(32)

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radiusSm
                            color: iconMouse.containsMouse ? Theme.hover : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: parent.iconText
                            font.pixelSize: Units.px(18)
                            color: Theme.text_secondary
                        }

                        MouseArea {
                            id: iconMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    ToolIcon {
                        iconText: "😀"
                    }
                    ToolIcon {
                        iconText: "📦"
                    }
                    ToolIcon {
                        iconText: "📁"
                    }
                    ToolIcon {
                        iconText: "✂️"
                    }
                    ToolIcon {
                        iconText: "📷"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ToolIcon {
                        iconText: "🎤"
                    }

                    NovaButton {
                        text: "发送"
                        primary: true
                        Layout.preferredHeight: Units.px(32)
                        onClicked: sendMessage()
                    }
                }
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

        property bool isFarFromBottom: (contentHeight - height - contentY) > 200
        onContentYChanged: isFarFromBottom = (contentHeight - height - contentY) > 200
        onContentHeightChanged: isFarFromBottom = (contentHeight - height - contentY) > 200

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

        onCountChanged: chatListView.scrollToBottom()
    }

    // 🚀 终极悬浮按钮 (带子菜单)
    NovaFab {
        id: mainFabController
        anchors.right: inputArea.right
        anchors.bottom: inputArea.top
        anchors.margins: Units.px(24)

        icon: "＋"

        // 子动作 1
        NovaFabAction {
            icon: "⬇"
            label: "回到底部"
            onTriggered: {
                chatListView.scrollToBottom();
                mainFabController.expanded = false; // 点击后收起菜单
            }
        }

        // 子动作 2
        NovaFabAction {
            icon: "🌓"
            label: "切换主题"
            onTriggered: {
                ThemeManager.mode = (Theme.mode === "light" ? "dark" : "light");
                mainFabController.expanded = false;
            }
        }

        // 子动作 3
        NovaFabAction {
            icon: "🗑"
            label: "清空聊天"
            onTriggered: {
                chatModel.clear();
                mainFabController.expanded = false;
            }
        }
    }

    function sendMessage() {
        let txt = inputText.text.trim();
        if (txt === "") return;

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

        inputText.text = "";
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
                text: "这是一个带子菜单的 **超级 FAB**！点开它会弹出动画，点外面的子按钮还会自动收起。完美符合你刚才提到的 Quasar FAB 设计规范！😎",
                stamp: timeStr,
                isTyping: true
            });
        }
    }
}