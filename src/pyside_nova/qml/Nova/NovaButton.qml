// src/pyside_nova/qml/Nova/NovaButton.qml

import QtQuick
import QtQuick.Controls.Basic

Item {
    id: root

    // 恢复最兼容的契约属性
    property bool primary: true
    property bool flat: false
    property bool loading: false
    property string size: "md"

    property alias text: label.text

    signal clicked()

    readonly property real _height: Units.px(Theme.buttonHeight(size))
    readonly property real _hPad: Units.px(Theme.spaceMd)

    implicitWidth: Math.max(_height, label.implicitWidth + _hPad * 2)
    implicitHeight: _height

    // 背景色
    property color _bgColor: {
        if (!root.enabled || root.loading) return Theme.disabled;
        if (root.flat) return ma.containsMouse ? Theme.hover : "transparent";
        if (root.primary) return ma.containsMouse ? Qt.lighter(Theme.primary, 1.1) : Theme.primary;
        return ma.containsMouse ? Theme.hover : Theme.surface;
    }

    Behavior on _bgColor {
        ColorAnimation {
            duration: Theme.durationFast
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color: root._bgColor
        border.width: (!root.primary && !root.flat) ? Units.px(1) : 0
        border.color: Theme.border
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: {
            if (!root.enabled) return Theme.text_secondary;
            if (root.flat) return Theme.text_primary;
            return root.primary ? Theme.contrast(Theme.primary) : Theme.text_primary;
        }
        font.pixelSize: Units.px(Theme.fontSizeFor(root.size))
        font.bold: true
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled && !root.loading
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}