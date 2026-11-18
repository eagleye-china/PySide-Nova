import QtQuick
import QtQuick.Layouts

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Item {
    id: root

    property bool sent: false
    property string text: ""
    property string name: ""
    property string avatar: ""
    property string stamp: ""
    property string fullStamp: ""
    property bool isTyping: false
    property bool isSystem: false
    property bool showFullTime: false
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)

    default property alias defaultSlotContent: defaultSlot.children

    property color bubbleColor: isSystem ? "#0E1B12" : (sent ? Theme.primary : (_utilBg !== "transparent" ? _utilBg : Theme.surface))
    property color bubbleTextColor: isSystem ? "#4CAF50" : (sent ? Theme.white : (_utilText !== "transparent" ? _utilText : Theme.text_primary))

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
            Rectangle { anchors.fill: parent; radius: 18; color: "#333" }
            Text { anchors.centerIn: parent; text: root.avatar; font.pixelSize: 20 }
        }

        Item { Layout.fillWidth: true; visible: root.sent }

        Column {
            width: bubble.width
            Layout.maximumWidth: root.width * 0.85
            spacing: 4

            Text { text: root.name; color: Theme.text_secondary; font.pixelSize: 12; visible: !root.sent }

            Rectangle {
                id: bubble
                width: defaultSlot.implicitWidth + 24
                height: defaultSlot.implicitHeight + 16
                radius: 8
                color: root.bubbleColor
                border.color: root.isSystem ? "#2E7D32" : "transparent"
                border.width: root.isSystem ? 1 : 0

                TextEdit {
                    id: messageText
                    visible: root.defaultSlotContent.length === 0
                    x: 12; y: 8
                    width: Math.min(implicitWidth, root.width * 0.85 - 24)
                    text: root.text
                    color: root.bubbleTextColor
                    font.pixelSize: 14
                    wrapMode: TextEdit.WrapAnywhere
                    textFormat: TextEdit.RichText
                    readOnly: true; selectByMouse: true
                    cursorDelegate: Item { width: 0; height: 0 }
                    onHoveredLinkChanged: { cursorShape = hoveredLink !== "" ? Qt.PointingHandCursor : Qt.IBeamCursor }
                    onLinkActivated: (link) => {
                        if (link.startsWith("copy:")) root.copyCodeRequested(link.substring(5));
                        else Qt.openUrlExternally(link);
                    }
                }

                Item {
                    id: defaultSlot
                    visible: root.defaultSlotContent.length > 0
                    x: 12; y: 8
                    width: Math.min(implicitWidth, root.width * 0.85 - 24)
                    implicitWidth: childrenRect.width
                    implicitHeight: childrenRect.height
                }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: root.showFullTime ? root.fullStamp : root.stamp
                color: Theme.text_secondary; font.pixelSize: 10; wrapMode: Text.NoWrap
                visible: root.stamp !== ""
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showFullTime = !root.showFullTime }
            }
        }

        Item { Layout.fillWidth: true; visible: !root.sent }

        Item {
            Layout.preferredWidth: 36; Layout.preferredHeight: 36
            visible: root.sent && root.avatar !== ""
            Rectangle { anchors.fill: parent; radius: 18; color: "#333" }
            Text { anchors.centerIn: parent; text: root.avatar; font.pixelSize: 20 }
        }
    }
}
