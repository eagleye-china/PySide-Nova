// src/pyside_nova/qml/Nova/NovaChatMessage.qml

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool sent: false
    property string text: ""
    property string name: ""
    property string avatar: ""
    property string stamp: ""
    property bool isTyping: false
    property bool isSystem: false

    property real maxBubbleRatio: 0.75
    property color bubbleColor: isSystem ? "#0E1B12" : (sent ? Theme.primary : Theme.surface)
    property color bubbleTextColor: isSystem ? "#4CAF50" : (sent ? Theme.white : Theme.text_primary)
    property color nameColor: isSystem ? "#81C784" : Theme.text_secondary
    property color stampColor: Theme.text_secondary

    readonly property real avatarSize: Units.px(36)
    readonly property real gap: Units.px(8)
    readonly property real maxBubbleWidth: root.width * maxBubbleRatio

    implicitHeight: contentLayout.implicitHeight + Units.px(16)
    implicitWidth: parent ? parent.width : 400
    width: parent ? parent.width : 400

    property int _visibleLength: isTyping ? 0 : text.length
    property string _displayText: isTyping ? text.substring(0, _visibleLength) : text

    Timer {
        id: typingTimer
        interval: 25
        repeat: true
        running: root.isTyping && root._visibleLength < root.text.length
        onTriggered: {
            root._visibleLength++;
            root.typingProgress();
        }
    }

    signal typingProgress()

    RowLayout {
        id: contentLayout
        anchors.top: parent.top
        anchors.topMargin: Units.px(8)
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: root.gap

        // 左侧头像
        Item {
            Layout.preferredWidth: root.avatarSize
            Layout.preferredHeight: root.avatarSize
            Layout.alignment: Qt.AlignTop
            visible: !root.sent && root.avatar !== ""
            Rectangle {
                anchors.fill: parent; radius: width / 2
                color: root.isSystem ? "#1B5E20" : (Theme.mode === "dark" ? "#333" : "#E0E0E0")
                clip: true
                Text {
                    anchors.centerIn: parent; text: root.avatar; font.pixelSize: Units.px(20)
                }
            }
        }

        Item {
            Layout.fillWidth: true; visible: root.sent
        }

        Column {
            Layout.maximumWidth: root.maxBubbleWidth
            spacing: Units.px(4)

            Text {
                text: root.name; color: root.nameColor; font.pixelSize: Units.px(12)
                visible: !root.sent && root.name !== ""; leftPadding: Units.px(4)
            }

            Rectangle {
                id: bubble
                visible: root.text !== "" || root.isTyping
                width: Math.min(bubbleText.implicitWidth + Units.px(24), root.maxBubbleWidth)
                height: bubbleText.implicitHeight + Units.px(16)
                radius: Theme.radiusMd; color: root.bubbleColor
                border.color: root.isSystem ? "#2E7D32" : "transparent"; border.width: root.isSystem ? 1 : 0

                Text {
                    id: bubbleText
                    anchors.centerIn: parent
                    width: Math.min(implicitWidth, root.maxBubbleWidth - Units.px(24))
                    text: root._displayText
                    color: root.bubbleTextColor
                    font.pixelSize: Units.px(14)
                    wrapMode: Text.WrapAnywhere

                    // 🚨 放弃纯文本，改为 RichText（如果包含表格，会自动渲染成带边框和底色的富文本）
                    textFormat: Text.RichText
                }
            }

            Text {
                text: root.stamp; color: root.stampColor; font.pixelSize: Units.px(11)
                visible: root.stamp !== ""; width: parent.width
                horizontalAlignment: root.sent ? Text.AlignRight : Text.AlignLeft
            }
        }

        Item {
            Layout.fillWidth: true; visible: !root.sent
        }

        // 右侧头像
        Item {
            Layout.preferredWidth: root.avatarSize; Layout.preferredHeight: root.avatarSize; Layout.alignment: Qt.AlignTop
            visible: root.sent && root.avatar !== ""
            Rectangle {
                anchors.fill: parent; radius: width / 2; color: Theme.mode === "dark" ? "#333" : "#E0E0E0"; clip: true
                Text {
                    anchors.centerIn: parent; text: root.avatar; font.pixelSize: Units.px(20)
                }
            }
        }
    }
}