import QtQuick
import QtQuick.Effects

Item {
    id: root

    property string source: ""
    property string text: ""
    
    // 🌟 修复：同样避开 size 保留字
    property int avatarSize: Units.px(40)
    
    property color fallbackColor: "#555555"
    property bool square: false
    property bool rounded: false

    width: avatarSize
    height: avatarSize

    Rectangle {
        anchors.fill: parent
        radius: root.square ? 0 : (root.rounded ? Units.px(4) : width / 2)
        color: (root.source === "" || avatarImage.status !== Image.Ready) ? root.fallbackColor : "transparent"

        Text {
            anchors.centerIn: parent
            text: root.text
            color: "white"
            font.pixelSize: root.avatarSize * 0.4
            font.bold: true
            visible: !root.source || avatarImage.status !== Image.Ready
        }
    }

    Image {
        id: avatarImage
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: root.source !== "" && status === Image.Ready

        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: avatarMask
        }
    }

    Item {
        id: avatarMask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            radius: root.square ? 0 : (root.rounded ? Units.px(4) : width / 2)
            color: "white"
        }
    }
}
