import QtQuick
import QtQuick.Effects // 🌟 补上这个关键模块，Qt6 图形遮罩神库

Item {
    id: root

    property string source: ""
    property string text: ""
    property int size: Units.px(40)
    property color fallbackColor: "#555555"
    
    // 对齐 Quasar QAvatar 属性
    property bool square: false
    property bool rounded: false

    width: size
    height: size

    // 1. 底圈背景与文字兜底容器
    Rectangle {
        anchors.fill: parent
        radius: root.square ? 0 : (root.rounded ? Units.px(4) : width / 2)
        color: (root.source === "" || avatarImage.status !== Image.Ready) ? root.fallbackColor : "transparent"

        Text {
            anchors.centerIn: parent
            text: root.text
            color: "white"
            font.pixelSize: root.size * 0.4
            font.bold: true
            visible: !root.source || avatarImage.status !== Image.Ready
        }
    }

    // 2. 头像图片层：使用 MultiEffect 和遮罩进行完美圆角裁剪
    Image {
        id: avatarImage
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: root.source !== "" && status === Image.Ready

        // 开启图层特效
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: avatarMask
        }
    }

    // 3. 遮罩层：画一个透明不可见的圆角矩形，供上面使用
    Item {
        id: avatarMask
        anchors.fill: parent
        visible: false // 遮罩本身不能显示在屏幕上
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            radius: root.square ? 0 : (root.rounded ? Units.px(4) : width / 2)
            color: "white" // 遮罩的颜色必须是不透明的纯色（白色），底层只取它的 alpha 轮廓
        }
    }
}
