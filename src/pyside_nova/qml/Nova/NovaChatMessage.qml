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
    property string label: ""
    property bool isTyping: false

    property real maxBubbleRatio: 0.75
    property color bubbleColor: sent ? Theme.primary : Theme.surface
    property color bubbleTextColor: sent ? Theme.white : Theme.text_primary
    property color nameColor: Theme.text_secondary
    property color stampColor: Theme.text_secondary
    property color labelColor: Theme.text_secondary

    readonly property real avatarSize: Units.px(36)
    readonly property real gap: Units.px(8)
    readonly property real maxBubbleWidth: root.width * maxBubbleRatio
    readonly property bool isImageAvatar: avatar.startsWith("http") || avatar.startsWith("file:") || avatar.startsWith("qrc:")

    implicitHeight: contentLayout.implicitHeight + (labelText.visible ? labelText.height + Units.px(12) : Units.px(12))
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

    function startTyping() {
        _visibleLength = 0;
        isTyping = true;
    }

    signal typingProgress()

    Text {
        id: labelText
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.label
        color: root.labelColor
        font.pixelSize: Units.px(12)
        font.bold: true
        visible: root.label !== ""
    }

    RowLayout {
        id: contentLayout
        anchors.top: labelText.visible ? labelText.bottom : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: labelText.visible ? Units.px(8) : 0
        spacing: root.gap

        // 左侧头像
        Item {
            Layout.preferredWidth: root.avatarSize
            Layout.preferredHeight: root.avatarSize
            Layout.alignment: Qt.AlignTop
            visible: !root.sent && root.avatar !== ""

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Theme.mode === "dark" ? "#333" : "#E0E0E0"
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.isImageAvatar ? root.avatar : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: root.isImageAvatar
                }
                Text {
                    anchors.centerIn: parent
                    text: root.avatar
                    font.pixelSize: Units.px(20)
                    visible: !root.isImageAvatar
                }
            }
        }

        Item {
            Layout.fillWidth: true
            visible: root.sent
        }

        Column {
            id: bubbleColumn
            Layout.maximumWidth: root.maxBubbleWidth
            spacing: Units.px(4)

            Text {
                text: root.name
                color: root.nameColor
                font.pixelSize: Units.px(12)
                visible: !root.sent && root.name !== ""
                leftPadding: Units.px(4)
            }

            Rectangle {
                id: bubble
                visible: root.text !== "" || root.isTyping
                width: bubbleText.width + Units.px(24)
                height: bubbleText.implicitHeight + Units.px(16)
                radius: Theme.radiusMd
                color: root.bubbleColor

                Text {
                    id: bubbleText
                    anchors.centerIn: parent // ✅ 用居中代替 fill，防止计算死锁
                    width: Math.min(implicitWidth, root.maxBubbleWidth - Units.px(24))
                    anchors.margins: Units.px(12)
                    text: root._displayText
                    color: root.bubbleTextColor
                    font.pixelSize: Units.px(14)
                    wrapMode: Text.Wrap

                    // ✅ 核心升级：开启 Markdown 渲染！
                    textFormat: Text.MarkdownText

                    // 让链接颜色跟随主题
                    linkColor: root.sent ? Theme.white : Theme.primary
                }
            }

            Text {
                text: root.stamp
                color: root.stampColor
                font.pixelSize: Units.px(11)
                visible: root.stamp !== ""
                width: parent.width
                horizontalAlignment: root.sent ? Text.AlignRight : Text.AlignLeft
                leftPadding: root.sent ? 0 : Units.px(4)
                rightPadding: root.sent ? Units.px(4) : 0
            }
        }

        Item {
            Layout.fillWidth: true
            visible: !root.sent
        }

        // 右侧头像
        Item {
            Layout.preferredWidth: root.avatarSize
            Layout.preferredHeight: root.avatarSize
            Layout.alignment: Qt.AlignTop
            visible: root.sent && root.avatar !== ""

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Theme.mode === "dark" ? "#333" : "#E0E0E0"
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.isImageAvatar ? root.avatar : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: root.isImageAvatar
                }
                Text {
                    anchors.centerIn: parent
                    text: root.avatar
                    font.pixelSize: Units.px(20)
                    visible: !root.isImageAvatar
                }
            }
        }
    }
}