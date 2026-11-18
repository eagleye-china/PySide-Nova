import QtQuick

Rectangle {
    id: root
    implicitHeight: Units.px(56)
    property string title: "Nova App"
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)

    color: _utilBg !== "transparent" ? _utilBg : Theme.surface
    border.color: Theme.border
    border.width: 1

    property alias prependSlotContent: leftSlot.children
    default property alias defaultSlotContent: centerSlot.children
    property alias appendSlotContent: rightSlot.children
    
    property alias leftContent: leftSlot.children
    property alias centerContent: centerSlot.children
    property alias rightContent: rightSlot.children
    property alias contentData: centerSlot.children

    Row {
        id: leftSlot
        anchors.left: parent.left
        anchors.leftMargin: Units.px(8)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Units.px(8)
    }

    Row {
        id: centerSlot
        anchors.centerIn: parent
        spacing: Units.px(8)

        Text {
            text: root.title
            color: root._utilText !== "transparent" ? root._utilText : Theme.text_primary
            font.pixelSize: Units.px(20)
            font.bold: true
            visible: centerSlot.children.length === 0
        }
    }

    Row {
        id: rightSlot
        anchors.right: parent.right
        anchors.rightMargin: Units.px(8)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Units.px(8)
    }
}
