import QtQuick
import QtQuick.Controls
import QtQuick.Window

Window {
    width: 640
    height: 480
    visible: true
    title: "PySide-Nova First Look"
    color: "#1E1E1E" // 暗黑背景

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Welcome to PySide-Nova 🌟"
            color: "#FFFFFF"
            font.pixelSize: 24
            font.bold: true
        }

        Button {
            text: "Click Me"
            onClicked: {
                console.log("Button clicked from QML!")
            }
        }
    }
}