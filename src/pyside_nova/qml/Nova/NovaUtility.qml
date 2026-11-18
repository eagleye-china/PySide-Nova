import QtQuick

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Item {
    id: root

    property string utilityClasses: ""
    default property alias content: targetItem.children

    implicitWidth: targetItem.childrenRect.width
    implicitHeight: targetItem.childrenRect.height

    Component.onCompleted: NovaUtilityCore.validate(utilityClasses)

    readonly property color backgroundColor: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color textColor: NovaUtilityCore.textColorOf(utilityClasses)
    readonly property int elevationLevel: NovaUtilityCore.elevationOf(utilityClasses)
    readonly property int radiusPx: NovaUtilityCore.radiusPxOf(utilityClasses)
    readonly property bool isDarkBg: NovaUtilityCore.isDarkBackground(utilityClasses)

    Item {
        id: targetItem
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: targetItem
        z: -1
        visible: root.backgroundColor !== "transparent"
        color: root.backgroundColor
        radius: root.radiusPx
    }

    Rectangle {
        anchors.fill: targetItem
        z: -2
        visible: root.elevationLevel > 0
        color: "#000000"
        opacity: 0.04 * root.elevationLevel
        radius: root.radiusPx
        anchors.margins: -Units.px(root.elevationLevel)
        anchors.bottomMargin: -Units.px(root.elevationLevel * 2)
    }
}
