// src/pyside_nova/qml/Nova/Behaviors/NovaTouchRepeat.qml
// NovaTouchRepeat 按住连发行为：按序列延迟重复触发、可接键盘按键（对标 Quasar v-touch-repeat）
// NovaTouchRepeat —— 按住连发（L3 行为层）
//
// 用法（数字键盘 / 长按加速滚动都靠它）：
//     Rectangle {
//         width: 80; height: 48
//         NovaTouchRepeat {
//             delays: "0:600:300"                 // 立即触发 → 600ms 后 → 之后每 300ms
//             onRepeat: (d) => console.log("第", d.repeatCount, "次")
//         }
//     }
//
// 基线契约（npm quasar@2.35.5 src/directives/touch-repeat/TouchRepeat.json 核实）：
//     value: Function(details) | undefined(禁用)
//     arg 默认 "0:600:300"：第 1 次等待 0ms、第 2 次 600ms、第 3 次 300ms，此后沿用最后一个值
//     details: evt / touch / mouse / keyboard / position{top,left} / keyCode / duration / repeatCount / startTime
//     修饰：capture / mouse / mouseCapture / keyCapture / esc / tab / enter / space / up / left / right / down / delete / [键码]
//
// QML 映射：arg 字符串 → delays 属性（"0:600:300" 或 "400" 单值均支持）；
//           键盘修饰 → keys（Qt.Key 值数组），keyRepeat: true 时接管键盘。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick

Item {
    id: beh

    property Item target: parent

    // 延迟序列（毫秒），用冒号分隔：第 n 次触发前的等待；末值用于后续所有次
    property string delays: "0:600:300"
    property bool keyRepeat: false          // true = 键盘也参与连发
    property var keys: []                   // 空 = 默认 Space / Enter

    readonly property bool pressed: core.pressed
    readonly property bool repeating: rep.running && _active
    readonly property int repeatCount: _count

    property bool _active: false
    property int _count: 0
    property real _startTime: 0
    property bool _kb: false                // 本次连发的通道（timer 接力时不能丢）
    property int _keyCode: 0

    signal repeat(var details)

    anchors.fill: parent
    focus: beh.keyRepeat

    function _list() {
        var parts = String(beh.delays).split(":")
        var out = []
        for (var i = 0; i < parts.length; i++) {
            var v = Number(parts[i])
            out.push(isNaN(v) || v < 0 ? 0 : v)
        }
        if (out.length === 0)
            out.push(0)
        return out
    }

    function _delayFor(count) {
        var list = beh._list()
        var idx = Math.min(count, list.length - 1)
        return list[idx]
    }

    function _details(keyboard, keyCode) {
        return {
            "evt": null,
            "touch": keyboard ? false : core.isTouch,
            "mouse": keyboard ? false : !core.isTouch,
            "keyboard": keyboard,
            "position": keyboard ? null : { "top": core.posY, "left": core.posX },
            "keyCode": keyCode,
            "duration": Date.now() - beh._startTime,
            "repeatCount": beh._count,
            "startTime": beh._startTime
        }
    }

    Timer {
        id: rep
        repeat: false
        onTriggered: beh._fire()
    }

    // 触摸/鼠标通道：第一次由 press 驱动，之后由 timer 接力
    NovaTouchCore {
        id: core
        target: beh.target
        threshold: 0

        onPressStarted: {
            beh._active = true
            beh._count = 0
            beh._startTime = Date.now()
            beh._schedule(false, 0)
        }

        onPressReleased: beh._stop()
        onPressCanceled: beh._stop()
    }

    // 键盘通道
    Keys.onPressed: (event) => {
        if (!beh.enabled || !beh.keyRepeat || beh._active)
            return
        if (!beh._wantKey(event.key))
            return
        beh._active = true
        beh._count = 0
        beh._startTime = Date.now()
        beh._schedule(true, event.key)
        event.accepted = true
    }

    Keys.onReleased: (event) => {
        if (!beh.keyRepeat || !beh._active)
            return
        if (!beh._wantKey(event.key))
            return
        beh._stop()
        event.accepted = true
    }

    function _wantKey(code) {
        if (beh.keys && beh.keys.length > 0)
            return beh.keys.indexOf(code) !== -1
        return code === Qt.Key_Space || code === Qt.Key_Return || code === Qt.Key_Enter
    }

    function _schedule(keyboard, keyCode) {
        beh._kb = keyboard
        beh._keyCode = keyCode
        var d = beh._delayFor(beh._count)
        if (d <= 0) {
            beh._fire()
        } else {
            rep.interval = d
            rep.restart()
        }
    }

    function _fire() {
        if (!beh._active)
            return
        beh._count++
        beh.repeat(beh._details(beh._kb, beh._keyCode))
        // 触发后按序列排下一次；末值复用，且下限 1ms（防 0 延迟自旋）
        var next = beh._delayFor(beh._count)
        rep.interval = next <= 0 ? 1 : next
        rep.restart()
    }

    function _stop() {
        beh._active = false
        rep.stop()
    }
}
