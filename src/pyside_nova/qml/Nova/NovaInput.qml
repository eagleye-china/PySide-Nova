import QtQuick
import QtQuick.Controls.Basic

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    property alias text: input.text
    property string placeholderText: "请输入内容..."
    property bool readOnly: false
    property alias echoMode: input.echoMode
    property alias maximumLength: input.maximumLength
    property alias validator: input.validator
    property string size: "md"
    property bool loading: false
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)
    readonly property int _utilRadius: NovaUtilityCore.radiusPxOf(utilityClasses)

    default property alias defaultSlotContent: defaultSlot.children
    property alias prependSlotContent: prependSlot.children
    property alias appendSlotContent: appendSlot.children
    property alias loadingSlotContent: loadingSlot.children

    readonly property bool _interactive: root.enabled && !root.readOnly && !root.loading
    readonly property bool _focused: input.activeFocus && root.enabled
    readonly property bool _hovered: hoverArea.containsMouse && !_focused && _interactive

    implicitWidth: Units.px(240)
    implicitHeight: Units.px(Theme.buttonHeight(size))
    radius: _utilRadius > 0 ? _utilRadius : Theme.radiusSm
    color: _utilBg !== "transparent" ? _utilBg : Theme.surface

    property color _borderColor: {
        if (!root.enabled) return Theme.disabled;
        if (root.loading) return Theme.disabled;
        if (_focused) return Theme.primary;
        if (_hovered) return Theme.borderHover || Theme.primary;
        return Theme.border;
    }

    Behavior on _borderColor { ColorAnimation { duration: Theme.durationFast } }

    border.width: _focused ? Units.px(2) : Units.px(1)
    border.color: _borderColor

    Row {
        anchors.fill: parent
        anchors.leftMargin: Units.px(Theme.spaceSm)
        anchors.rightMargin: Units.px(Theme.spaceSm)
        spacing: Units.px(8)

        Item {
            id: prependSlot
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            visible: root.prependSlotContent.length > 0
        }

        Item {
            id: inputArea
            width: parent.width - (prependSlot.visible ? prependSlot.width + parent.spacing : 0) - (appendSlot.visible ? appendSlot.width + parent.spacing : 0)
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: placeholder
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: root.placeholderText
                color: root._utilText !== "transparent" ? root._utilText : Theme.text_secondary
                font.pixelSize: Units.px(Theme.fontSizeFor(root.size))
                elide: Text.ElideRight
                visible: input.length === 0 && root.defaultSlotContent.length === 0
            }

            TextInput {
                id: input
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                color: root._interactive ? (root._utilText !== "transparent" ? root._utilText : Theme.text_primary) : Theme.text_secondary
                selectionColor: Theme.primary
                selectedTextColor: Theme.white
                font.pixelSize: Units.px(Theme.fontSizeFor(root.size))
                selectByMouse: true
                clip: true
                readOnly: root.readOnly
                cursorVisible: root._interactive ? activeFocus : false
                visible: root.defaultSlotContent.length === 0
            }

            Item {
                id: defaultSlot
                anchors.fill: parent
                visible: root.defaultSlotContent.length > 0
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
            }
        }

        Item {
            id: loadingSlot
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            visible: root.loading
            Text {
                text: "⏳"
                visible: root.loadingSlotContent.length === 0
                anchors.centerIn: parent
            }
        }

        Item {
            id: appendSlot
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            visible: root.appendSlotContent.length > 0 && !root.loading
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: root._interactive ? Qt.IBeamCursor : Qt.ArrowCursor
    }

    MouseArea {
        anchors.fill: parent
        enabled: root._interactive
        onClicked: input.forceActiveFocus()
    }
}
