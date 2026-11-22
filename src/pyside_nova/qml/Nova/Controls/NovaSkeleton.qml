// src/pyside_nova/qml/Nova/Controls/NovaSkeleton.qml
// NovaSkeleton 骨架屏：type（rect/text/circle/square/badge/tag）× animation（wave/bounce/fade/none，对标 QSkeleton）
// wave = 渐变横扫；bounce = 透明度脉冲；fade = 交替呼吸
import QtQuick
import Nova.Services

Rectangle {
    id: root

    // ── 形态 ──────────────────────────────────────────────────
    property string type: "rect"                 // rect | text | circle | square | badge | tag
    property string animation: "wave"            // wave | bounce | fade | none
    property int animationSpeed: 1500            // 周期 ms
    property bool bordered: false
    final property real size: 0                        // 同时锁宽高（circle/square 常用）
    final property real customWidth: 0                 // 0 = implicit（rect 默认 240×52）
    final property real customHeight: 0

    readonly property color _base: NovaTheme.surfaceAlt
    readonly property color _hi: NovaTheme.isDark ? "#32323A" : "#EDEFF4"

    color: _base
    border.width: root.bordered ? 1 : 0
    border.color: NovaTheme.outline

    implicitWidth: customWidth > 0 ? customWidth : (size > 0 ? size : 240)
    implicitHeight: customHeight > 0 ? customHeight : (size > 0 ? size
                      : type === "text" ? 16 : type === "badge" ? 22 : type === "tag" ? 26 : 52)
    width: implicitWidth
    height: implicitHeight

    radius: type === "circle" ? height / 2
          : type === "square" ? 0
          : type === "text" ? 4
          : type === "badge" ? height / 2
          : type === "tag" ? 6
          : NovaTheme.radiusS

    // ── wave 渐变横扫 ─────────────────────────────────────────
    Rectangle {
        id: sweep
        anchors.fill: parent
        radius: parent.radius
        visible: root.animation === "wave"
        color: "transparent"
        clip: true

        Rectangle {
            id: sweepBar
            x: -parent.width
            width: parent.width * 0.8
            height: parent.height
            rotation: 8
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 0.5; color: root._hi }
                GradientStop { position: 1; color: "transparent" }
            }
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { from: -sweep.width; to: sweep.width; duration: root.animationSpeed; easing.type: Easing.InOutQuad }
            }
        }
    }

    // ── bounce / fade 透明度脉冲 ──────────────────────────────
    SequentialAnimation on opacity {
        running: root.animation === "bounce"
        loops: Animation.Infinite
        NumberAnimation { from: 1; to: 0.45; duration: root.animationSpeed / 2; easing.type: Easing.InOutQuad }
        NumberAnimation { from: 0.45; to: 1; duration: root.animationSpeed / 2; easing.type: Easing.InOutQuad }
    }
    SequentialAnimation on color {
        running: root.animation === "fade"
        loops: Animation.Infinite
        ColorAnimation { from: root._base; to: root._hi; duration: root.animationSpeed / 2 }
        ColorAnimation { from: root._hi; to: root._base; duration: root.animationSpeed / 2 }
    }
}
