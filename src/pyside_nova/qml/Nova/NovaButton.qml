import QtQuick

/**
 * @created 2026-11-18 15:00:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Item {
    id: root

    property string label: ""
    property alias text: root.label
    property url icon: ""
    property url iconRight: ""
    property string color: "primary"
    property string variant: "filled"
    property string size: "md"
    property bool rounded: false
    property bool elevated: false
    property bool dense: false
    property bool loading: false
    property string utilityClasses: ""
    
    signal clicked()

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)
    readonly property int _utilElevation: NovaUtilityCore.elevationOf(utilityClasses)
    readonly property int _utilRadius: NovaUtilityCore.radiusPxOf(utilityClasses)

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
        color: root.variant === "text" || root.variant === "flat" ? "transparent" : "#2196F3" 
        radius: root.rounded ? height / 2 : Units.px(Theme.radiusMd)
        border.width: root.variant === "outlined" ? Units.px(1) : 0
        border.color: "#1565C0"
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

            // ── 1. 前置区域（插槽或图标） ──
            Item {
                id: prependArea
                anchors.verticalCenter: parent.verticalCenter
                visible: (prependSlot.children.length > 0) || (root.icon.toString() !== "")
                
                width: prependSlot.children.length > 0 ? prependSlot.width : Units.px(18)
                height: prependSlot.children.length > 0 ? prependSlot.height : Units.px(18)

                // 外部插槽
                Item {
                    id: prependSlot
                    anchors.fill: parent
                    visible: children.length > 0
                }

                // 默认图标（无外部插槽时显示）
                Image {
                    source: root.icon
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    visible: prependSlot.children.length === 0
                }
            }

            // ── 2. 主体区域（插槽或文字） ──
            Item {
                id: defaultArea
                anchors.verticalCenter: parent.verticalCenter
                visible: (defaultSlot.children.length > 0) || (root.label !== "")
                
                width: defaultSlot.children.length > 0 ? defaultSlot.width : labelText.width
                height: defaultSlot.children.length > 0 ? defaultSlot.height : labelText.height

                // 外部插槽
                Item {
                    id: defaultSlot
                    anchors.fill: parent
                    visible: children.length > 0
                }

                // 默认文字（无外部插槽时显示）
                Text {
                    id: labelText
                    text: root.label
                    font.pixelSize: Units.px(16)
                    font.bold: true
                    color: "#FFFFFF"
                    visible: defaultSlot.children.length === 0
                }
            }

            // ── 3. 后置区域（插槽或图标） ──
            Item {
                id: appendArea
                anchors.verticalCenter: parent.verticalCenter
                visible: (appendSlot.children.length > 0) || (root.iconRight.toString() !== "")
                
                width: appendSlot.children.length > 0 ? appendSlot.width : Units.px(18)
                height: appendSlot.children.length > 0 ? appendSlot.height : Units.px(18)

                // 外部插槽
                Item {
                    id: appendSlot
                    anchors.fill: parent
                    visible: children.length > 0
                }

                // 默认图标（无外部插槽时显示）
                Image {
                    source: root.iconRight
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    visible: appendSlot.children.length === 0
                }
            }
        }

        // ── 4. 状态级覆盖（Loading） ──
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
                color: "#FFFFFF"
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
