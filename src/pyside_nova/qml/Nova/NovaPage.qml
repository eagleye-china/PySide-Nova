import QtQuick
import QtQuick.Controls.Basic

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Item {
    id: root

    property int padding: Units.px(16)
    property bool scrollable: true
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)

    default property alias defaultSlotContent: defaultSlot.children
    property alias content: defaultSlot.children
    property alias contentData: defaultSlot.children

    Rectangle {
        anchors.fill: parent
        z: -1
        color: root._utilBg
        visible: root._utilBg !== "transparent"
    }

    Flickable {
        anchors.fill: parent
        clip: true
        interactive: root.scrollable
        contentWidth: width
        contentHeight: defaultSlot.childrenRect.height + root.padding * 2
        boundsBehavior: Flickable.StopAtBounds

        Item {
            id: defaultSlot
            width: parent.width - root.padding * 2
            x: root.padding
            y: root.padding
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}
