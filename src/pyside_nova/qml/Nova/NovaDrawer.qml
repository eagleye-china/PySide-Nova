import QtQuick

Item {
    id: root

    property bool permanent: true
    property bool opened: false
    property bool mini: false
    property bool overlay: false
    property bool bordered: true
    property bool elevated: false

    property string side: "left"
    property int expandedWidth: Units.px(240)
    property int miniWidth: Units.px(60)
    property int breakpoint: 1024
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)
    readonly property int _utilElevation: NovaUtilityCore.elevationOf(utilityClasses)

    function show() { if (!opened) opened = true; }
    function hide() { if (opened) opened = false; }
    function toggle() { opened = !opened; }

    readonly property bool _isResponsiveOverlay: overlay || (parent !== null && parent.width < breakpoint)
    readonly property real _currentWidth: (mini && !_isResponsiveOverlay) ? miniWidth : expandedWidth

    width: _currentWidth
    visible: (permanent && !_isResponsiveOverlay) ? true : (opened || x > -_currentWidth)
    
    x: {
        if (permanent && !_isResponsiveOverlay) return 0;
        if (_isResponsiveOverlay) {
            var pWidth = (parent !== null) ? parent.width : 1000;
            if (side === "left") return opened ? 0 : -_currentWidth;
            else return opened ? pWidth - _currentWidth : pWidth;
        }
        return 0;
    }

    Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    default property alias defaultSlotContent: defaultSlot.children
    property alias miniSlotContent: miniSlot.children
    property alias content: defaultSlot.children
    property alias contentData: defaultSlot.children

    Rectangle {
        id: bg
        anchors.fill: parent
        color: _utilBg !== "transparent" ? _utilBg : Theme.surface
        // 🌟 优化边框逻辑：去掉四周边框，只在靠内的一侧画线 (更符合 Quasar 规范)
        Rectangle {
            visible: root.bordered
            width: 1
            height: parent.height
            anchors.right: root.side === "left" ? parent.right : undefined
            anchors.left: root.side === "right" ? parent.left : undefined
            color: Theme.border
        }
    }

    Item {
        id: defaultSlot
        anchors.fill: parent
        visible: !root.mini || root.miniSlotContent.length === 0
        // 🌟 优化：移除默认的 margins，交给业务层用 Flickable/padding 控制
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }

    Item {
        id: miniSlot
        anchors.fill: parent
        visible: root.mini && root.miniSlotContent.length > 0
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
