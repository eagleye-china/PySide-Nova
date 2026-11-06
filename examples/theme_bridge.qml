import QtQuick
import QtQuick.Controls

Window {
    width: 400
    height: 300
    visible: true
    color: "#1E1E1E"

    Rectangle {
        anchors.centerIn: parent
        width: 200
        height: 50
        radius: 8
        // ✅ 直接使用 Python 注入的主题颜色！
        color: NovaTheme.primaryColor

        Text {
            anchors.centerIn: parent
            text: "Python Controlled Color"
            color: "white"
        }
    }
}