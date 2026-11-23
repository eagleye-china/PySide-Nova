// src/pyside_nova/qml/Nova/Behaviors/NovaRipple.qml
// NovaRipple 水波纹行为：作为子项挂载到任意 Item，color/duration 可定制（对标 Quasar v-ripple 指令）
// NovaRipple —— 水波纹（对标 v-ripple）
// 用法：作为最后一个子项放进任意可点击的 Item：
//     Rectangle {
//         width: 140; height: 80; radius: 8
//         color: NovaTheme.primary
//         NovaRipple { }
//     }
// 说明：内部用被动 TapHandler 监听宿主点击，不阻断宿主自身的事件处理；
// 触发时机为点击完成（tapped），按压即起波的效果由 NovaBtn 内置实现。
// 纯 QML 不支持自定义 attached property（需 C++/Python 注册），
// attach 语法规划在 M1 通过 PySide6 QML_ATTACHED 补齐。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: overlay

    property color color: NovaTheme.ripple
    property int duration: 550

    anchors.fill: parent
    clip: true

    TapHandler {
        target: overlay.parent
        onTapped: (tapPoint) => overlay.open(tapPoint.position.x, tapPoint.position.y)
        onCanceled: overlay.settle()
    }

    ListModel { id: waves }

    function open(x, y) {
        var d = 2 * Math.max(
            Math.hypot(x, y),
            Math.hypot(overlay.width - x, y),
            Math.hypot(x, overlay.height - y),
            Math.hypot(overlay.width - x, overlay.height - y)) + 24
        waves.append({ "rx": x, "ry": y, "dia": d, "done": false })
    }

    function settle() {
        for (var i = 0; i < waves.count; ++i)
            if (!waves.get(i).done)
                waves.setProperty(i, "done", true)
    }

    function removeAt(i) {
        waves.remove(i)
    }

    Repeater {
        model: waves
        delegate: Item {
            id: waveItem
            required property int index
            required property real rx
            required property real ry
            required property real dia
            required property bool done

            x: rx - dia / 2
            y: ry - dia / 2
            width: dia
            height: dia

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: overlay.color
                opacity: waveItem.done ? 0 : 1
                Behavior on opacity {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }
                NumberAnimation on scale {
                    from: 0
                    to: 1
                    duration: overlay.duration
                    easing.type: Easing.OutQuad
                }
            }

            // 点击触发的波纹：绽放完成后自动消散
            Timer {
                id: life
                interval: overlay.duration + 60
                onTriggered: waveItem.done = true
            }
            Timer {
                id: cleanup
                interval: overlay.duration + 380
                onTriggered: overlay.removeAt(waveItem.index)
            }
            Component.onCompleted: life.restart()
        }
    }
}
