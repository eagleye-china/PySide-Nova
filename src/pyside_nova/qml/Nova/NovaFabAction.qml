import QtQuick

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)

    default property alias defaultSlotContent: defaultSlot.children

    signal triggered()

    width: Units.px(44)
    height: Units.px(44)
    radius: width / 2
    color: _utilBg !== "transparent" ? _utilBg : Theme.surface
    border.color: Theme.border
    border.width: 1

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Units.px(2)
        radius: parent.radius
        color: Qt.rgba(0, 0, 0, 0.1)
        z: -1
    }

    Item {
        id: defaultSlot
        anchors.centerIn: parent
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.pixelSize: Units.px(18)
        color: root._utilText !== "transparent" ? root._utilText : Theme.text_primary
        visible: root.defaultSlotContent.length === 0
    }

    Rectangle {
        anchors.right: parent.left
        anchors.rightMargin: Units.px(8)
        anchors.verticalCenter: parent.verticalCenter
        width: labelText.implicitWidth + Units.px(12)
        height: Units.px(24)
        radius: Theme.radiusSm
        color: Theme.mode === "dark" ? "#333" : "#222"
        opacity: actionMouse.containsMouse ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Text {
            id: labelText
            anchors.centerIn: parent
            text: root.label
            color: "#fff"
            font.pixelSize: Units.px(12)
        }
    }

    MouseArea {
        id: actionMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.triggered()
    }
}
