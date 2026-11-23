// src/pyside_nova/qml/Nova/Behaviors/NovaTouchHold.qml
// NovaTouchHold 长按行为：按住时长阈值、触摸/鼠标各自灵敏度、位移即取消（对标 Quasar v-touch-hold）
// NovaTouchHold —— 长按（L3 行为层）
//
// 用法：
//     Rectangle {
//         width: 240; height: 120
//         NovaTouchHold {
//             duration: 500
//             onHold: (d) => console.log("按住了", d.duration, "ms")
//         }
//     }
//
// 基线契约（npm quasar@2.35.5 src/directives/touch-hold/TouchHold.json 核实）：
//     value: Function(details) | undefined(禁用)
//     details: evt / touch / mouse / position{top,left} / duration
//     arg 默认 "600:5:7" → duration=600ms / 触摸灵敏度 5px / 鼠标灵敏度 7px
//     修饰：capture / mouse / mouseCapture
//
// 语义要点：位移超过灵敏度即取消（防止"想拖却变成长按"）；到时只触发一次，松手不会重复。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick

Item {
    id: beh

    property Item target: parent

    property int duration: 600
    property real touchSensitivity: 5
    property real mouseSensitivity: 7
    property bool preventStealing: true

    readonly property bool pressed: core.pressed
    readonly property bool held: _held
    readonly property bool holding: holder.running      // 正在计时中（可用于进度指示的起点）

    property bool _held: false

    signal hold(var details)
    signal cancel()                 // 位移超限 / 提前松手（增强：基线无显式通知）

    anchors.fill: parent

    Timer {
        id: holder
        interval: beh.duration
        repeat: false
        onTriggered: {
            beh._held = true
            beh.hold({
                "evt": null,
                "touch": core.isTouch,
                "mouse": !core.isTouch,
                "position": { "top": core.posY, "left": core.posX },
                "duration": beh.duration
            })
        }
    }

    NovaTouchCore {
        id: core
        target: beh.target
        threshold: 0
        preventStealing: beh.preventStealing

        onPressStarted: {
            beh._held = false
            holder.restart()
        }

        onPressMoved: {
            if (!holder.running)
                return
            var limit = core.isTouch ? beh.touchSensitivity : beh.mouseSensitivity
            if (Math.max(core.distanceX, core.distanceY) > limit) {
                holder.stop()
                beh.cancel()
            }
        }

        onPressReleased: {
            if (holder.running) {
                holder.stop()
                beh.cancel()
            }
        }

        onPressCanceled: {
            if (holder.running) {
                holder.stop()
                beh.cancel()
            }
        }
    }
}
