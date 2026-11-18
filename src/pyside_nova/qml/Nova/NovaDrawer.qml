import QtQuick

Item {
    id: root

    property bool permanent: true
    property bool opened: false
    property bool mini: false
    property bool overlay: false
    property bool bordered: true
    property bool elevated: false
    
    // 🌟 新增：控制完全隐藏（滑出屏幕）
    property bool hidden: false

    property string side: "left"
    property int expandedWidth: Units.px(240)
    property int miniWidth: Units.px(60)
    property int breakpoint: 1024
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)
    readonly property int _utilElevation: NovaUtilityCore.elevationOf(utilityClasses)

    function show() { if (!opened) opened = true; hidden = false; }
    function hide() { if (opened) opened = false; hidden = true; }
    function toggle() { opened = !opened; }

    readonly property bool _isResponsiveOverlay: overlay || (parent !== null && parent.width < breakpoint)
    readonly property real _currentWidth: (mini && !_isResponsiveOverlay) ? miniWidth : expandedWidth

    HoverHandler { id: hoverHandler }
    property bool hovered: hoverHandler.hovered

    width: _currentWidth
    
    // 🌟 如果 hidden 为 true，直接不显示（不占点击空间），并依靠 x 滑出
    visible: !hidden && ((permanent && !_isResponsiveOverlay) ? true : (opened || x > -_currentWidth))
    
    x: {
        if (hidden) return -_currentWidth; // 完全滑出屏幕外
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
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
        clip: true 
    }

    Item {
        id: miniSlot
        anchors.fill: parent
        visible: root.mini && root.miniSlotContent.length > 0
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
