import QtQuick
import QtQuick.Window
// ✅ 这一行非常关键！导入你的 Nova 组件包
import pyside_nova.qml 1.0

Window {
    width: 640
    height: 480
    visible: true
    color: "#121212"
    title: "PySide-Nova Components"

    Column {
        anchors.centerIn: parent
        spacing: 20

        // ✅ 使用你定义的 NovaButton
        NovaButton {
            text: "Primary Button"
            bgColor: NovaTheme.primaryColor
            onClicked: console.log("Clicked Primary")
        }

        NovaButton {
            text: "Danger Button"
            bgColor: "#F44336"
            btnRadius: 20 // 测试自定义圆角
            onClicked: console.log("Clicked Danger")
        }
    }
}