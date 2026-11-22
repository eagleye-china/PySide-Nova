// src/pyside_nova/qml/Nova/Behaviors/NovaTouchSwipe.qml
// NovaTouchSwipe 快速滑动行为：速度阈值、触摸/鼠标各自最小距离、方向过滤（对标 Quasar v-touch-swipe）
// NovaTouchSwipe —— 快速滑动（L3 行为层）
//
// 用法：
//     Rectangle {
//         width: 300; height: 200
//         NovaTouchSwipe {
//             directions: ["left"]          // 只接左滑
//             onSwipe: (d) => dismiss()
//         }
//     }
//
// 基线契约（npm quasar@2.35.5 src/directives/touch-swipe/TouchSwipe.json 核实）：
//     value: Function(details) | undefined(禁用)
//     details: evt / touch / mouse / direction / duration / distance{x,y}(绝对)
//     arg 默认 "6e-2:6:50" → minVelocity=0.06(px/ms) / touchMinDistance=6 / mouseMinDistance=50
//     修饰：capture / mouse / mouseCapture / horizontal / vertical / up / right / down / left
//
// 语义要点：
//   · 基线在移动过程中就触发（不等松手）；Nova 同口径——移动到合格即触发一次，
//     松手瞬间再判一次兜底（极快速滑动可能一帧就结束）。
//   · 鼠标的最小距离远大于触摸（50 vs 6），否则任何点击都会变成滑动——这是基线刻意的区分。
import QtQuick

Item {
    id: beh

    property Item target: parent

    property real minVelocity: 0.06         // px/ms
    property real touchMinDistance: 6
    property real mouseMinDistance: 50
    property bool horizontal: false
    property bool vertical: false
    property var directions: []             // 空 = 全向

    property bool _fired: false

    signal swipe(var details)

    anchors.fill: parent

    function _accept(dir) {
        if (!dir)
            return false
        if (beh.directions && beh.directions.length > 0 && beh.directions.indexOf(dir) === -1)
            return false
        if (beh.horizontal && (dir === "up" || dir === "down"))
            return false
        if (beh.vertical && (dir === "left" || dir === "right"))
            return false
        return true
    }

    function _qualified() {
        var dir = core.direction || core.refreshDirection()
        if (!beh._accept(dir))
            return false
        var need = core.isTouch ? beh.touchMinDistance : beh.mouseMinDistance
        var dist = Math.max(core.distanceX, core.distanceY)
        if (dist < need)
            return false
        var v = dist / Math.max(1, core.duration)
        return v >= beh.minVelocity
    }

    function _details() {
        return {
            "evt": null,
            "touch": core.isTouch,
            "mouse": !core.isTouch,
            "direction": core.direction || core.refreshDirection(),
            "duration": core.duration,
            "distance": { "x": core.distanceX, "y": core.distanceY },
            "velocity": Math.max(core.distanceX, core.distanceY) / Math.max(1, core.duration),
            "position": { "top": core.posY, "left": core.posX }
        }
    }

    function _tryFire() {
        if (beh._fired || !beh.enabled || !beh._qualified())
            return
        beh._fired = true
        beh.swipe(beh._details())
    }

    NovaTouchCore {
        id: core
        target: beh.target
        threshold: 0

        onPressStarted: beh._fired = false
        onPressMoved: beh._tryFire()
        onPressReleased: beh._tryFire()
    }
}
