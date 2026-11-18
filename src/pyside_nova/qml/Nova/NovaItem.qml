import QtQuick

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool active: false
    property bool clickable: false
    
    signal clicked()

    width: parent ? parent.width : 0
    implicitHeight: Units.px(48)
    
    topLeftRadius: 0
    bottomLeftRadius: 0
    topRightRadius: Units.px(24)
    bottomRightRadius: Units.px(24)

    readonly property bool _isCompact: width < Units.px(100)

    color: {
        if (mouseArea.containsPress) return Qt.rgba(1, 1, 1, 0.12)
        if (mouseArea.containsMouse && root.clickable) return Qt.rgba(1, 1, 1, 0.06)
        return "transparent" 
    }

    Behavior on color { ColorAnimation { duration: 150 } }

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        
        // 🌟 核心修复：放弃危险的 anchors 动态切换，改用数学计算 x 坐标
        // 如果是紧凑模式，(父宽度 - 自身宽度) / 2 即可绝对居中；否则靠左留出边距
        x: root._isCompact ? (parent.width - width) / 2 : Units.px(16)
        spacing: root._isCompact ? 0 : Units.px(24)

        NovaIcon {
            name: root.icon
            iconSize: "md"
            anchors.verticalCenter: parent.verticalCenter
            opacity: (root.active || mouseArea.containsMouse) ? 1.0 : 0.6 
            visible: root.icon !== ""
        }

        Text {
            text: root.label
            color: root.active ? Theme.primary : (mouseArea.containsMouse ? "#ffffff" : "#e0e0e0")
            font.pixelSize: Units.px(15)
            font.bold: root.active
            anchors.verticalCenter: parent.verticalCenter
            visible: !root._isCompact 
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        
        onClicked: {
            if (root.clickable) {
                root.clicked()
            }
        }
    }
}
