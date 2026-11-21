// src/pyside_nova/qml/Nova/Controls/NovaAvatar.qml
// NovaAvatar 头像：文字哈希自动配色 / 图片 / square / size 可调（对标 QAvatar）
// NovaAvatar —— 头像（对标 QAvatar）
// 文字头像（按内容自动配色）/ emoji / 图片三态
import QtQuick
import Nova.Services

Rectangle {
    id: root

    // ── 槽机制（对标 QAvatar 默认槽）──────────────────────────
    // 默认子项挂载到覆盖层，可在头像之上叠加自定义内容
    default property alias content: extraHost.data

    property string text: ""
    property url source: ""
    property real size: 44
    property bool square: false
    property color tint: root.autoColor   // 基调色（QML 中 color 与基类属性冲突故命名 tint）
    property color textColor: "#FFFFFF"

    // 按文本内容 hash 自动选色
    readonly property color autoColor: {
        var palette = ["#EF5350", "#5B6EF5", "#26A69A", "#EF6C00",
                       "#8E24AA", "#00897B", "#D81B60", "#6D4C41"]
        var s = text.length > 0 ? text : "?"
        var h = 0
        for (var i = 0; i < s.length; ++i)
            h = (h * 31 + s.charCodeAt(i)) % 997
        return palette[h % palette.length]
    }

    width: size
    height: size
    radius: square ? NovaTheme.radiusM : size / 2
    color: root._hasImage ? "transparent" : tint
    clip: root._hasImage   // 仅图片模式裁剪圆角，避免裁掉挂载的 NovaBadge

    readonly property bool _hasImage: root.source.toString() !== ""

    Text {
        anchors.centerIn: parent
        visible: !root._hasImage && root.text !== ""
        text: root.text
        color: root.textColor
        font.family: NovaTheme.fontFamily
        font.pixelSize: root.size * 0.42
        font.bold: true
    }

    Image {
        anchors.fill: parent
        visible: root._hasImage
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // 默认槽宿主：覆盖层，几何与头像一致（NovaBadge 等子项仍可正常吸附角标）
    Item { id: extraHost; anchors.fill: parent }
}
