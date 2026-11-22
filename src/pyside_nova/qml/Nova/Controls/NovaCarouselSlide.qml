// src/pyside_nova/qml/Nova/Controls/NovaCarouselSlide.qml
// NovaCarouselSlide 轮播页（对标 QCarouselSlide）：name 寻址 / disable / img-src 快速图片页，
// default 槽为页内容；几何（位置/尺寸/显隐）由宿主 NovaCarousel 统一管理
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 默认槽：页内容 ───────────────────────────────────────
    default property alias content: body.data

    // ── 属性（对标 name/disable/img-src） ───────────────────
    property string name: ""       // 页寻址名；空则由宿主以序号寻址
    property bool disable: false   // 禁用页（不可被 goTo 选中）
    property url imgSrc: ""        // 快速图片页：填充即渲染

    clip: true

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: root.imgSrc
        asynchronous: true
        visible: root.imgSrc.toString() !== ""
    }

    Item {
        id: body
        anchors.fill: parent
    }

    // 禁用遮罩（令牌取色）
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)
        visible: root.disable
    }
}
