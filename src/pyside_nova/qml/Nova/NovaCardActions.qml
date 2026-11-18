import QtQuick
import QtQuick.Layouts

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    property string align: "right"
    property bool bordered: true
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)

    default property alias defaultSlotContent: defaultSlot.children
    property alias contentData: defaultSlot.children

    implicitHeight: layout.implicitHeight + Units.px(16)
    color: _utilBg !== "transparent" ? _utilBg : "transparent"

    Rectangle {
        visible: root.bordered
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: Theme.border
        opacity: 0.6
    }

    RowLayout {
        id: layout
        anchors.top: parent.top
        anchors.topMargin: Units.px(16)
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Units.px(8)

        Item {
            Layout.fillWidth: true
            visible: root.align === "right" || root.align === "center"
        }

        Item {
            id: defaultSlot
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }

        Item {
            Layout.fillWidth: true
            visible: root.align === "left" || root.align === "center"
        }
    }
}
