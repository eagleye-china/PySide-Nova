import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    signal themeToggleRequested()
    signal messageSent(string text)
    signal copyCodeRequested(string base64Code)

    property string title: "NovaChat"
    property string userName: "User"
    property string userAvatar: "👨‍💻"
    property string aiName: "AI Assistant"
    property string aiAvatar: "🤖"
    property alias model: chatModel
    property bool isAiThinking: false
    property bool showHeader: true
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)

    default property alias defaultSlotContent: defaultSlot.children
    property alias headerSlotContent: headerSlot.children
    property alias footerSlotContent: footerSlot.children

    color: _utilBg !== "transparent" ? _utilBg : Theme.background

    ListModel { id: chatModel }

    function getFullStamp() {
        let now = new Date();
        let days = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"];
        return Qt.formatDateTime(now, "yyyy-MM-dd HH:mm:ss") + " " + days[now.getDay()];
    }

    function addUserMessage(text) {
        let timeStr = Qt.formatDateTime(new Date(), "hh:mm");
        chatModel.append({ sent: true, name: root.userName, avatar: root.userAvatar, text: text, stamp: timeStr, fullStamp: getFullStamp(), isTyping: false });
        scrollToBottom();
    }

    function addAiMessage(text, enableTyping = true) {
        let timeStr = Qt.formatDateTime(new Date(), "hh:mm");
        chatModel.append({ sent: false, name: root.aiName, avatar: root.aiAvatar, text: text, stamp: timeStr, fullStamp: getFullStamp(), isTyping: enableTyping });
        scrollToBottom();
    }

    function addSystemMessage(text) {
        let timeStr = Qt.formatDateTime(new Date(), "hh:mm");
        chatModel.append({ sent: false, name: "⚙️ 系统工具", avatar: "🛠️", text: text, stamp: timeStr, fullStamp: getFullStamp(), isTyping: false, isSystem: true });
        scrollToBottom();
    }

    function scrollToBottom() { Qt.callLater(chatListView.positionViewAtEnd); }

    Item {
        id: headerSlot
        visible: root.showHeader && root.headerSlotContent.length > 0
        height: visible ? childrenRect.height : 0
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        z: 10
    }

    Rectangle {
        id: header
        visible: root.showHeader && root.headerSlotContent.length === 0
        height: visible ? Units.px(60) : 0
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        color: Theme.surface; border.color: Theme.border; border.width: 1; z: 10

        Text { anchors.centerIn: parent; text: root.title; color: Theme.text_primary; font.pixelSize: Units.px(18); font.bold: true }

        Rectangle {
            width: Units.px(80); height: Units.px(36)
            anchors.right: parent.right; anchors.rightMargin: Units.px(16); anchors.verticalCenter: parent.verticalCenter
            color: btnMouse.pressed ? Qt.darker(Theme.primary, 1.2) : (btnMouse.containsMouse ? Qt.lighter(Theme.primary, 1.1) : Theme.primary)
            radius: Theme.radiusSm
            Text { anchors.centerIn: parent; text: "🌓 切换"; color: "white"; font.bold: true }
            MouseArea { id: btnMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.themeToggleRequested() }
        }
    }

    Item {
        id: defaultSlot
        anchors.top: headerSlot.visible ? headerSlot.bottom : header.bottom
        anchors.bottom: footerSlot.visible ? footerSlot.top : inputArea.top
        anchors.left: parent.left; anchors.right: parent.right
        visible: root.defaultSlotContent.length > 0
        
        ListView {
            id: chatListView
            anchors.fill: parent
            visible: root.defaultSlotContent.length === 0
            clip: true; model: chatModel; spacing: Units.px(12); topMargin: Units.px(16); bottomMargin: Units.px(16); z: 1
            delegate: NovaChatMessage {
                width: chatListView.width
                sent: model.sent; name: model.name; avatar: model.avatar; text: model.text; stamp: model.stamp; fullStamp: model.fullStamp; isTyping: model.isTyping
                isSystem: model.isSystem ? true : false
                onCopyCodeRequested: (base64Code) => root.copyCodeRequested(base64Code)
            }
            onCountChanged: scrollToBottom()
        }
    }

    Item {
        id: footerSlot
        visible: root.footerSlotContent.length > 0
        height: visible ? childrenRect.height : 0
        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
        z: 10
    }

    Rectangle {
        id: inputArea
        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
        visible: root.footerSlotContent.length === 0
        height: visible ? Units.px(160) : 0
        color: Theme.surface; border.color: Theme.border; border.width: 1; z: 10

        Rectangle {
            id: inputContainer
            anchors.fill: parent; anchors.margins: Units.px(16)
            radius: Theme.radiusMd; color: Theme.background
            border.color: inputText.activeFocus ? Theme.primary : Theme.border; border.width: 1

            ColumnLayout {
                anchors.fill: parent; anchors.margins: Units.px(8); spacing: Units.px(8)
                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    TextArea {
                        id: inputText
                        placeholderText: "输入你想说的话... (Enter 发送)"
                        placeholderTextColor: Theme.text_secondary
                        color: Theme.text_primary; font.pixelSize: Units.px(14); wrapMode: TextArea.Wrap; background: null
                        topPadding: Units.px(8); leftPadding: Units.px(8)
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (!event.modifiers) { triggerSend(); event.accepted = true; }
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: Units.px(8)
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: Units.px(64); height: Units.px(32); radius: Theme.radiusSm
                        color: root.isAiThinking ? Theme.disabled : Theme.primary
                        Text { anchors.centerIn: parent; text: root.isAiThinking ? "思考中..." : "发送"; color: "white" }
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
        addUserMessage(txt); inputText.text = ""; root.messageSent(txt);
    }
}
