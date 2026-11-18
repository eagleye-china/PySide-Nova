import QtQuick

Item {
    id: root

    property string label: ""
    property alias text: root.label
    
    property string icon: ""
    property string iconRight: ""
    
    property string color: "primary"
    property string variant: "filled"
    property string size: "md"
    property bool rounded: false
    property bool elevated: false
    property bool dense: false
    property bool loading: false
    property string utilityClasses: ""
    
    // 🌟 新增：允许自定义背景色
    property color bgColor: "transparent"
    property color textColor: "transparent" 
    
    signal clicked()

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)
    readonly property int _utilElevation: NovaUtilityCore.elevationOf(utilityClasses)
    readonly property int _utilRadius: NovaUtilityCore.radiusPxOf(utilityClasses)

    readonly property color _finalTextColor: {
        if (textColor !== "transparent") return textColor
        if (_utilText !== "transparent") return _utilText
        return variant === "filled" ? "white" : Theme.primary
    }

    default property alias defaultSlotContent: defaultSlot.children
    property alias prependSlotContent: prependSlot.children
    property alias appendSlotContent: appendSlot.children
    property alias loadingSlotContent: loadingSlot.children

    implicitWidth: Math.max(Units.px(80), contentRow.implicitWidth + padding * 2)
    implicitHeight: dense ? Units.px(28) : (size === "sm" ? Units.px(32) : Units.px(40))
    
    readonly property int padding: dense ? Units.px(8) : (size === "sm" ? Units.px(12) : Units.px(16))

    Rectangle {
        id: bg
        anchors.fill: parent
        // 🌟 优先使用 bgColor
        color: {
            if (root.bgColor !== "transparent") return root.bgColor
            if (root.variant === "text" || root.variant === "flat" || root.variant === "outlined") return "transparent"
            return root._utilBg !== "transparent" ? root._utilBg : Theme.primary
        }
        radius: root.rounded ? height / 2 : (_utilRadius > 0 ? _utilRadius : Units.px(Theme.radiusMd))
        border.width: root.variant === "outlined" ? Units.px(1) : 0
        border.color: root.bgColor !== "transparent" ? root.bgColor : Theme.primary
        opacity: root.enabled ? 1.0 : 0.5
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: padding
        anchors.rightMargin: padding

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: Units.px(8)
            visible: !root.loading

            Item {
                id: prependArea
                anchors.verticalCenter: parent.verticalCenter
                visible: (prependSlot.children.length > 0) || (root.icon !== "")
                
                width: prependSlot.children.length > 0 ? prependSlot.width : Units.px(18)
                height: prependSlot.children.length > 0 ? prependSlot.height : Units.px(18)

                Item {
                    id: prependSlot
                    anchors.fill: parent
                    visible: children.length > 0
                }

                NovaIcon {
                    name: root.icon
                    iconSize: "sm"
                    anchors.fill: parent
                    visible: prependSlot.children.length === 0
                    color: root._finalTextColor
                }
            }

            Item {
                id: defaultArea
                anchors.verticalCenter: parent.verticalCenter
                visible: (defaultSlot.children.length > 0) || (root.label !== "")
                
                width: defaultSlot.children.length > 0 ? defaultSlot.width : labelText.width
                height: defaultSlot.children.length > 0 ? defaultSlot.height : labelText.height

                Item {
                    id: defaultSlot
                    anchors.fill: parent
                    visible: children.length > 0
                }

                Text {
                    id: labelText
                    text: root.label
                    font.pixelSize: Units.px(14)
                    font.bold: true
                    color: root._finalTextColor
                    visible: defaultSlot.children.length === 0
                }
            }

            Item {
                id: appendArea
                anchors.verticalCenter: parent.verticalCenter
                visible: (appendSlot.children.length > 0) || (root.iconRight !== "")
                
                width: appendSlot.children.length > 0 ? appendSlot.width : Units.px(18)
                height: appendSlot.children.length > 0 ? appendSlot.height : Units.px(18)

                Item {
                    id: appendSlot
                    anchors.fill: parent
                    visible: children.length > 0
                }

                NovaIcon {
                    name: root.iconRight
                    iconSize: "sm"
                    anchors.fill: parent
                    visible: appendSlot.children.length === 0
                    color: root._finalTextColor
                }
            }
        }

        Item {
            id: loadingArea
            anchors.centerIn: parent
            visible: root.loading
            width: loadingSlot.children.length > 0 ? loadingSlot.width : Units.px(20)
            height: loadingSlot.children.length > 0 ? loadingSlot.height : Units.px(20)

            Item {
                id: loadingSlot
                anchors.fill: parent
                visible: children.length > 0
            }

            Text {
                text: "⏳"
                visible: loadingSlot.children.length === 0
                anchors.centerIn: parent
                font.pixelSize: Units.px(16)
                color: root._finalTextColor
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
