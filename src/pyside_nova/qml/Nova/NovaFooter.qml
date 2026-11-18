import QtQuick

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root
    implicitHeight: Units.px(40)
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)

    color: _utilBg !== "transparent" ? _utilBg : Theme.surface
    border.color: Theme.border
    border.width: 1

    default property alias defaultSlotContent: defaultSlot.children
    property alias content: defaultSlot.children
    property alias contentData: defaultSlot.children

    Item {
        id: defaultSlot
        anchors.fill: parent
        anchors.margins: Units.px(8)
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
