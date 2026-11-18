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
    
    // 🌟 细节1：左侧直角，右侧圆角
    topLeftRadius: 0
    bottomLeftRadius: 0
    topRightRadius: Units.px(24)
    bottomRightRadius: Units.px(24)

    // 🌟 细节2：取消了 active 状态的固定深色阴影，只保留悬浮和按压反馈
    color: {
        if (mouseArea.containsPress) return Qt.rgba(1, 1, 1, 0.12) // 按下时深色
        if (mouseArea.containsMouse && root.clickable) return Qt.rgba(1, 1, 1, 0.06) // 悬浮时浅色阴影
        return "transparent" // 默认包括 active 都是透明，没有阴影
    }

    Behavior on color { ColorAnimation { duration: 150 } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Units.px(16)
        anchors.rightMargin: Units.px(16)
        spacing: Units.px(24)
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: root.icon
            font.pixelSize: Units.px(20)
            anchors.verticalCenter: parent.verticalCenter
            // 只有悬浮或选中时图标才完全亮起
            opacity: (root.active || mouseArea.containsMouse) ? 1.0 : 0.6 
            visible: root.icon !== ""
        }

        Text {
            text: root.label
            // 选中时文字变蓝
            color: root.active ? Theme.primary : (mouseArea.containsMouse ? "#ffffff" : "#e0e0e0")
            font.pixelSize: Units.px(15)
            font.bold: root.active
            anchors.verticalCenter: parent.verticalCenter
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
