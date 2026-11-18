import QtQuick

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Item {
    id: root

    property string text: "＋"
    property string icon: ""
    property color bgColor: Theme.primary
    property color textColor: Theme.white
    property bool expanded: false
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)

    default property alias defaultSlotContent: menuColumn.children
    property alias contentData: menuColumn.children

    readonly property bool hasActions: defaultSlotContent.length > 0
    readonly property real fabSize: Units.px(56)

    width: fabSize
    height: fabSize + (expanded ? menuColumn.implicitHeight + Units.px(16) : 0)

    Column {
        id: menuColumn
        anchors.bottom: mainFab.top
        anchors.bottomMargin: Units.px(16)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Units.px(12)

        opacity: root.expanded ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Rectangle {
        id: mainFab
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.fabSize
        height: root.fabSize
        radius: width / 2
        color: root._utilBg !== "transparent" ? root._utilBg : root.bgColor
        border.color: Qt.rgba(0, 0, 0, 0.1)
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: -Units.px(4)
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.15)
            z: -1
        }

        Text {
            anchors.centerIn: parent
            text: root.icon !== "" ? root.icon : root.text
            color: root._utilText !== "transparent" ? root._utilText : root.textColor
            font.pixelSize: root.icon !== "" ? Units.px(24) : Units.px(28)
            font.bold: true
            rotation: (root.hasActions && root.expanded) ? 45 : 0
            Behavior on rotation { NumberAnimation { duration: 200 } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.hasActions) root.expanded = !root.expanded;
                else root.clicked();
            }
        }
    }

    signal clicked()
}
