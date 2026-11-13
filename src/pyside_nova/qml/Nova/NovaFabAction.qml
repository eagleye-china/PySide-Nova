// src/pyside_nova/qml/Nova/NovaFabAction.qml

import QtQuick

/**
 * @created 2026-11-13 18:10:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    property string icon: ""
    property string label: ""

    signal triggered()

    width: Units.px(44)
    height: Units.px(44)
    radius: width / 2
    color: Theme.surface
    border.color: Theme.border
    border.width: 1

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Units.px(2)
        radius: parent.radius
        color: Qt.rgba(0, 0, 0, 0.1)
        z: -1
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.pixelSize: Units.px(18)
        color: Theme.text_primary
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
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

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
        onClicked: {
            root.triggered();
        }
    }
}