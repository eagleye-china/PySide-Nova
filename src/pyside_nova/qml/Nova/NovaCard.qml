import QtQuick
import QtQuick.Layouts

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Item {
    id: root

    property bool flat: false
    property bool bordered: false
    property bool square: false
    property bool dark: false
    property string tag: ""
    property real radius: Theme.radiusMd
    property int elevation: flat ? 0 : 1
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)
    readonly property int _utilElevation: NovaUtilityCore.elevationOf(utilityClasses)
    readonly property int _utilRadius: NovaUtilityCore.radiusPxOf(utilityClasses)

    default property alias defaultSlotContent: defaultSlot.children
    property alias headerSlotContent: headerSlot.children
    property alias footerSlotContent: footerSlot.children
    
    property alias content: defaultSlot.children
    readonly property alias contentItem: defaultSlot

    implicitWidth: Units.px(300)
    implicitHeight: cardLayout.implicitHeight

    readonly property int radiusValue: square ? Theme.radiusNone : (_utilRadius > 0 ? _utilRadius : Units.px(radius))
    readonly property color surfaceColor: dark ? Theme.dark : (_utilBg !== "transparent" ? _utilBg : (tag.length > 0 ? Theme.colorOf(tag) : Theme.surface))
    readonly property color foreground: dark ? Theme.text_primary : (_utilText !== "transparent" ? _utilText : (tag.length > 0 ? Theme.contrast(Theme.colorOf(tag)) : Theme.text_primary))
    readonly property color borderColor: bordered ? Theme.border : "transparent"

    readonly property real shadowOpacity: Math.min(0.28, 0.05 + (_utilElevation > 0 ? _utilElevation : elevation) * 0.045)
    readonly property real shadowSpread: (_utilElevation > 0 ? _utilElevation : elevation) <= 0 ? 0 : 1 + (_utilElevation > 0 ? _utilElevation : elevation) * 0.8

    Rectangle {
        id: shadowOuter
        anchors.fill: backgroundLayer
        anchors.margins: -Units.px(root.shadowSpread * 2)
        radius: root.radiusValue + Units.px(root.shadowSpread * 2)
        color: Qt.rgba(0, 0, 0, root.shadowOpacity * 0.35)
        visible: root.elevation > 0 || root._utilElevation > 0
        z: -2
    }

    Rectangle {
        id: shadowInner
        anchors.fill: backgroundLayer
        anchors.margins: -Units.px(root.shadowSpread)
        radius: root.radiusValue + Units.px(root.shadowSpread)
        color: Qt.rgba(0, 0, 0, root.shadowOpacity)
        visible: root.elevation > 0 || root._utilElevation > 0
        z: -1
    }

    Rectangle {
        id: backgroundLayer
        anchors.fill: parent
        radius: root.radiusValue
        color: root.surfaceColor
        border.width: root.bordered ? Math.max(1, Units.px(1)) : 0
        border.color: root.borderColor
        clip: true

        ColumnLayout {
            id: cardLayout
            anchors.fill: parent
            spacing: 0

            Item {
                id: headerSlot
                Layout.fillWidth: true
                implicitHeight: childrenRect.height
                visible: root.headerSlotContent.length > 0
                Layout.margins: Units.px(Theme.spaceMd)
            }

            Item {
                id: defaultSlot
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: childrenRect.height
                Layout.margins: Units.px(Theme.spaceMd)
            }

            Item {
                id: footerSlot
                Layout.fillWidth: true
                implicitHeight: childrenRect.height
                visible: root.footerSlotContent.length > 0
                Layout.margins: Units.px(Theme.spaceMd)
            }
        }
    }
}
