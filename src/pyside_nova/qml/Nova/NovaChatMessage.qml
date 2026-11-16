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

    property color bubbleColor: isSystem ? "#0E1B12" : (sent ? Theme.primary : Theme.surface)
    property color bubbleTextColor: isSystem ? "#4CAF50" : (sent ? Theme.white : Theme.text_primary)

    signal copyCodeRequested(string base64Code)

    implicitHeight: layout.implicitHeight + 16
    width: parent ? parent.width : 400

    RowLayout {
        id: layout
        anchors.top: parent.top; anchors.topMargin: 8
        anchors.left: parent.left; anchors.right: parent.right
        spacing: 8

        Item {
            Layout.preferredWidth: 36; Layout.preferredHeight: 36
            visible: !root.sent && root.avatar !== ""
            Rectangle {
                anchors.fill: parent; radius: 18; color: "#333"
                Text {
                    anchors.centerIn: parent; text: root.avatar; font.pixelSize: 20
                }
            }
        }

        Item {
            Layout.fillWidth: true; visible: root.sent
        }

        Column {
            Layout.maximumWidth: root.width * 0.85
            spacing: 4

            Text {
                text: root.name; color: "#888"; font.pixelSize: 12; visible: !root.sent
            }

            Rectangle {
                id: bubble
                width: messageText.width + 24
                height: messageText.height + 16
                radius: 8; color: root.bubbleColor
                border.color: root.isSystem ? "#2E7D32" : "transparent"
                border.width: root.isSystem ? 1 : 0

                TextEdit {
                    id: messageText
                    x: 12; y: 8
                    width: Math.min(implicitWidth, root.width * 0.85 - 24)
                    text: root.text
                    color: root.bubbleTextColor
                    font.pixelSize: 14
                    wrapMode: TextEdit.WrapAnywhere
                    textFormat: TextEdit.RichText
                    readOnly: true
                    selectByMouse: true
                    cursorDelegate: Item {
                        width: 0; height: 0
                    }

                    onHoveredLinkChanged: {
                        if (hoveredLink !== "") {
                            cursorShape = Qt.PointingHandCursor
                        } else {
                            cursorShape = Qt.IBeamCursor
                        }
                    }

                    onLinkActivated: (link) => {
                        if (link.startsWith("copy:")) {
                            root.copyCodeRequested(link.substring(5))
                        } else {
                            Qt.openUrlExternally(link)
                        }
                    }
                }
                // ❌ 彻底删除了这里曾经的“复制全部”悬浮按钮
            }
        }

        Item {
            Layout.fillWidth: true; visible: !root.sent
        }
    }
}