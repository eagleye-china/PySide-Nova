// src/pyside_nova/qml/Nova/Behaviors/NovaTouchCore.qml
// NovaTouchCore 指针手势内核：按下/移动/释放生命周期、距离/方向/时间、触摸与鼠标来源判定（内部件）
// NovaTouchCore —— 触摸手势公共内核（internal，供 NovaTouchPan/Swipe/Hold/Repeat 复用）
//
// 为什么要有内核：四个 touch 指令的差异只在"什么时候回调、回调什么"，而"怎么跟踪指针"完全一样。
// 把跟踪收敛到一处，四个行为共享同一套坐标/时间/阈值语义，避免四份各自漂移的实现。
//
// 实现路径（如实记录于 docs/PARITY.md）：
//   · 基线监听 DOM 的 touchstart/touchmove/touchend + mousedown/mousemove/mouseup；
//     QML 用 MouseArea（Qt 默认把触屏合成鼠标事件）+ MultiPointTouchArea 探测真实触摸来源。
//   · 禁用统一走 Item.enabled（不重声明：Qt 6.12 的 Item.enabled 会被视为覆盖基类成员）。
//   · 根节点不能设 visible: false —— 不可见 Item 不参与事件分发，内部 MouseArea 会彻底失灵。
//   · 坐标统一换算成场景坐标（mapToItem(null, ...)），与基线的 clientX/clientY 口径一致。
//   · touch 判定：触摸层在 250ms 内报过触点 → 本次按下视为触摸（Qt 无事件源字段，只能这样判）。
import QtQuick

Item {
    id: core

    // ── 配置 ────────────────────────────────────────────────
    property Item target: parent
    property bool preventStealing: true        // 对应基线 .prevent/.stop 的"别被 Flickable 抢走"
    property bool stopPropagation: false
    property bool showGrabbingCursor: false
    property real threshold: 0                 // 起判距离（像素）：位移超过它才算手势开始

    // ── 只读状态 ────────────────────────────────────────────
    readonly property bool pressed: area.pressed
    readonly property bool gesturing: _active
    readonly property bool isTouch: _touch
    readonly property real startX: _sx
    readonly property real startY: _sy
    readonly property real posX: _x
    readonly property real posY: _y
    readonly property real offsetX: _x - _sx
    readonly property real offsetY: _y - _sy
    readonly property real distanceX: Math.abs(_x - _sx)
    readonly property real distanceY: Math.abs(_y - _sy)
    readonly property real deltaX: _dx
    readonly property real deltaY: _dy
    readonly property real duration: _now - _startTime
    readonly property string direction: _dir

    property bool _active: false
    property bool _touch: false
    property real _sx: 0
    property real _sy: 0
    property real _x: 0
    property real _y: 0
    property real _dx: 0
    property real _dy: 0
    property real _startTime: 0
    property real _now: 0
    property string _dir: ""
    property real _touchStamp: -100000

    // ── 信号（子类据此实现各自语义） ─────────────────────────
    signal pressStarted()
    signal gestureStarted()        // 位移越过 threshold（threshold=0 时按下即触发）
    signal pressMoved()
    signal pressReleased()
    signal pressCanceled()

    anchors.fill: parent

    // 触摸来源探测：只认触摸，不碰鼠标（mouseEnabled: false）
    MultiPointTouchArea {
        anchors.fill: parent
        mouseEnabled: false
        onPressed: (points) => { core._touchStamp = Date.now() }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        preventStealing: core.preventStealing
        cursorShape: core.showGrabbingCursor && area.pressed && core._active
                     ? Qt.ClosedHandCursor : Qt.ArrowCursor

        onPressed: (mouse) => core._onPress(mouse)
        onPositionChanged: (mouse) => core._onMove(mouse)
        onReleased: (mouse) => core._onRelease(false)
        onCanceled: core._onRelease(true)
    }

    // ── 生命周期 ────────────────────────────────────────────
    function _onPress(mouse) {
        if (!core.enabled)
            return
        core._touch = (Date.now() - core._touchStamp) < 250
        var p = core.mapToItem(null, mouse.x, mouse.y)
        core._sx = p.x
        core._sy = p.y
        core._x = p.x
        core._y = p.y
        core._dx = 0
        core._dy = 0
        core._startTime = Date.now()
        core._now = core._startTime
        core._dir = ""
        core._active = false
        core.pressStarted()
        if (core.threshold <= 0) {
            core._active = true
            core.gestureStarted()
        }
    }

    function _onMove(mouse) {
        if (!area.pressed)
            return
        var p = core.mapToItem(null, mouse.x, mouse.y)
        core._dx = p.x - core._x
        core._dy = p.y - core._y
        core._x = p.x
        core._y = p.y
        core._now = Date.now()

        var ox = core._x - core._sx
        var oy = core._y - core._sy
        if (Math.abs(ox) >= Math.abs(oy))
            core._dir = ox > 0 ? "right" : (ox < 0 ? "left" : core._dir)
        else
            core._dir = oy > 0 ? "down" : (oy < 0 ? "up" : core._dir)

        if (!core._active && (Math.abs(ox) >= core.threshold || Math.abs(oy) >= core.threshold)) {
            core._active = true
            core.gestureStarted()
        }
        core.pressMoved()
    }

    function _onRelease(canceled) {
        core._now = Date.now()
        if (canceled)
            core.pressCanceled()
        else
            core.pressReleased()
        core._active = false
    }

    // 供子类在释放后继续读方向（父类按 offset 兜底重算）
    function refreshDirection() {
        var ox = core._x - core._sx
        var oy = core._y - core._sy
        if (Math.abs(ox) >= Math.abs(oy))
            core._dir = ox >= 0 ? "right" : "left"
        else
            core._dir = oy >= 0 ? "down" : "up"
        return core._dir
    }
}
