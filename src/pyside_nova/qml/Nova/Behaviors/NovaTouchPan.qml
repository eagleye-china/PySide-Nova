// src/pyside_nova/qml/Nova/Behaviors/NovaTouchPan.qml
// NovaTouchPan 拖动手势行为：方向/轴向过滤、首末标记、位移与增量、抓手光标（对标 Quasar v-touch-pan）
// NovaTouchPan —— 拖动（L3 行为层）
//
// 用法：
//     Rectangle {
//         width: 300; height: 200
//         NovaTouchPan {
//             horizontal: true
//             onPan: (d) => { x += d.delta.x; if (d.isFinal) snapBack() }
//         }
//     }
//
// 基线契约（npm quasar@2.35.5 src/directives/touch-pan/TouchPan.json 核实）：
//     value: Function(details) | undefined(禁用)
//     details: evt / touch / mouse / position{top,left} / direction / isFirst / isFinal /
//              duration / distance{x,y}(绝对) / offset{x,y}(带符号) / delta{x,y}(相对上次)
//     修饰：stop / prevent / capture / mouse / mouseCapture / mouseAllDir / preserveCursor /
//           horizontal / vertical / up / right / down / left
//
// QML 映射：
//     stop / prevent      → stopPropagation / preventStealing
//     mouseAllDir         → allDirections（首移方向不被接受也不中止）
//     preserveCursor      → preserveCursor（关掉抓手光标）
//     horizontal/vertical → horizontal / vertical
//     up/right/down/left  → directions: ["up", ...]（空数组 = 全向）
//     注意：行为层会接管指针（MouseArea 在宿主之上），宿主自己的点击逻辑请改用它给出的回调；
//           这是"手势行为"的固有语义，不是缺陷——基线的 v-touch-pan 同样会 preventDefault。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick

Item {
    id: beh

    property Item target: parent
    property bool horizontal: false
    property bool vertical: false
    property var directions: []
    property bool allDirections: false
    property bool preventStealing: true
    property bool stopPropagation: true
    property bool preserveCursor: false
    property real threshold: 8              // 起判距离（Nova 增强：基线鼠标无独立阈值，这里统一 8px）

    readonly property bool panning: _started && core.pressed
    property bool _started: false
    property bool _aborted: false
    property int _count: 0

    signal pan(var details)

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

    function _details(isFinal, isFirst) {
        return {
            "evt": null,
            "touch": core.isTouch,
            "mouse": !core.isTouch,
            "position": { "top": core.posY, "left": core.posX },
            "direction": core.direction,
            "isFirst": isFirst,
            "isFinal": isFinal,
            "duration": core.duration,
            "distance": { "x": core.distanceX, "y": core.distanceY },
            "offset": { "x": core.offsetX, "y": core.offsetY },
            "delta": { "x": core.deltaX, "y": core.deltaY }
        }
    }

    NovaTouchCore {
        id: core
        target: beh.target
        threshold: beh.threshold
        preventStealing: beh.preventStealing
        stopPropagation: beh.stopPropagation
        showGrabbingCursor: !beh.preserveCursor

        onPressStarted: {
            beh._started = false
            beh._aborted = false
            beh._count = 0
        }

        onGestureStarted: {
            if (!beh.allDirections && !beh._accept(core.direction)) {
                beh._aborted = true
                return
            }
            beh._started = true
            beh._emit(false)
        }

        onPressMoved: {
            if (!beh._started || beh._aborted)
                return
            if (!beh._accept(core.direction))
                return
            beh._emit(false)
        }

        onPressReleased: {
            if (beh._started && !beh._aborted)
                beh._emit(true)
            beh._started = false
        }

        onPressCanceled: {
            if (beh._started && !beh._aborted)
                beh._emit(true)
            beh._started = false
            beh._aborted = false
        }
    }

    function _emit(isFinal) {
        if (!beh.enabled)
            return
        var isFirst = beh._count === 0        // 先判首帧再自增，顺序颠倒会让 isFirst 永远为 false
        beh._count++
        beh.pan(beh._details(isFinal, isFirst))
    }
}
