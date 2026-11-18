import QtQuick

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    property bool showHeader: true
    property bool showFooter: true
    property bool showLeftDrawer: false
    property bool showRightDrawer: false

    property int headerHeight: Units.px(60)
    property int footerHeight: Units.px(40)
    property int leftDrawerWidth: Units.px(240)
    property int rightDrawerWidth: Units.px(240)
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)

    color: _utilBg !== "transparent" ? _utilBg : Theme.background

    default property alias defaultSlotContent: pageContainer.children
    property alias pageContent: pageContainer.children

    property alias title: header.title
    property alias headerLeftContent: header.prependSlotContent
    property alias headerCenterContent: header.defaultSlotContent
    property alias headerRightContent: header.appendSlotContent
    property alias footerContent: footer.defaultSlotContent
    
    property alias leftDrawerContent: leftDrawer.defaultSlotContent
    property alias rightDrawerContent: rightDrawer.defaultSlotContent

    NovaHeader {
        id: header
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        height: root.showHeader ? root.headerHeight : 0
        visible: root.showHeader
        z: 10
    }

    NovaFooter {
        id: footer
        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
        height: root.showFooter ? root.footerHeight : 0
        visible: root.showFooter
        z: 10
    }

    NovaDrawer {
        id: leftDrawer
        anchors.top: header.bottom; anchors.bottom: footer.top; anchors.left: parent.left
        width: root.showLeftDrawer ? root.leftDrawerWidth : 0
        visible: root.showLeftDrawer
    }

    NovaDrawer {
        id: rightDrawer
        anchors.top: header.bottom; anchors.bottom: footer.top; anchors.right: parent.right
        width: root.showRightDrawer ? root.rightDrawerWidth : 0
        visible: root.showRightDrawer
    }

    Item {
        id: pageContainer
        anchors.top: header.bottom; anchors.bottom: footer.top
        anchors.left: leftDrawer.right; anchors.right: rightDrawer.left
    }
}
