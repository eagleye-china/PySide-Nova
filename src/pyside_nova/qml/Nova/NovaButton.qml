// src/pyside_nova/qml/Nova/NovaButton.qml

import QtQuick
import QtQuick.Controls.Basic

/**
 * @created 2026-11-13 10:53:29
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    property alias text: btnText.text
    property string size: "md"
    property bool primary: true
    property bool flat: false
    property bool enabled: true

    implicitWidth: btnText.implicitWidth + Units.px(32)
    implicitHeight: Units.px(Theme.buttonHeight(size))
    radius: Theme.radiusSm

    color: {
        if (!enabled) return Theme.disabled;
        if (flat) return mouseArea.containsMouse ? Theme.hover : "transparent";
        if (primary) return mouseArea.containsMouse ? Qt.lighter(Theme.primary, 1.1) : Theme.primary;
        return mouseArea.containsMouse ? Theme.hover : Theme.surface;
    }

    border.width: (!primary && !flat) ? 1 : 0
    border.color: Theme.border
    opacity: enabled ? 1.0 : 0.6

    Behavior on color {
        ColorAnimation { duration: Theme.durationFast }
    }

    Text {
        id: btnText
        anchors.centerIn: parent
        text: "Button"
        color: {
            if (!root.enabled) return Theme.text_secondary;
            if (root.flat) return Theme.text_primary;
            return root.primary ? Theme.white : Theme.text_primary;
        }
        font.pixelSize: Units.px(Theme.fontSizeFor(root.size))
        font.bold: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

    signal clicked()
}