// src/pyside_nova/qml/NovaButton.qml
import QtQuick
import QtQuick.Controls

Button {
    id: root

    // 自定义属性，方便从外部控制
    property color bgColor: "#0078D4"
    property color textColor: "#FFFFFF"
    property int btnRadius: 8

    // 尺寸设置
    implicitWidth: 120
    implicitHeight: 40

    // 背景完全自定义
    background: Rectangle {
        color: root.down ? Qt.darker(root.bgColor, 1.2) : root.bgColor
        radius: root.btnRadius

        // 简单的颜色过渡动画
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    // 文字内容自定义
    contentItem: Text {
        text: root.text
        color: root.textColor
        font.pixelSize: 14
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // 鼠标移入移出光效（可选）
    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}