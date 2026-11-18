import QtQuick
import Nova 1.0

Window {
    width: 480
    height: 320
    visible: true
    color: Theme.background
    title: "Nova Utility Class Demo"

    NovaUtility {
        anchors.centerIn: parent
        width: Units.px(240)
        height: Units.px(120)
        utilityClasses: "bg-primary text-white elevation-3 rounded-md"

        Column {
            anchors.centerIn: parent
            spacing: Units.px(8)

            Text {
                text: "Nova 旗舰组件库"
                font.pixelSize: Units.px(16)
                color: parent.parent.textColor
            }

            NovaButton {
                label: "测试按钮"
                variant: "text"
            }
        }
    }
}
