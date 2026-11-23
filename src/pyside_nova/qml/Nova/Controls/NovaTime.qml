// src/pyside_nova/qml/Nova/Controls/NovaTime.qml
// NovaTime 时钟面盘：时/分/秒三面切换、24h/12h(AM/PM)、options 过滤、nowBtn
// 对标 Quasar QTime（14 props；Nova 收口核心 12 项，validator/defaultDate 留痕见 PARITY）
// 契约统一：hint / error / readonly / disable
import QtQuick
import Nova.Services
import Nova.Behaviors
import Nova.Design

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.EditableText
    Accessible.name: a11yLabel !== "" ? a11yLabel : hint
    Accessible.readOnly: readonly
    Accessible.focusable: !disable
    Accessible.focused: activeFocus
    activeFocusOnTab: !disable
    // 键盘路径：上下改小时、左右改分钟、Enter 提交、M 切换上下午、F 换面盘
    Keys.onPressed: function(ev) {
        if (root.disable || root.readonly) return
        if (ev.key === Qt.Key_Up) { root.setHour((root._h + 1) % 24); ev.accepted = true }
        else if (ev.key === Qt.Key_Down) { root.setHour((root._h + 23) % 24); ev.accepted = true }
        else if (ev.key === Qt.Key_Right) { root.setMinute((root._m + 1) % 60); ev.accepted = true }
        else if (ev.key === Qt.Key_Left) { root.setMinute((root._m + 59) % 60); ev.accepted = true }
        else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) { root._emit(); ev.accepted = true }
        else if (ev.key === Qt.Key_M) { root.toggleAmPm(); ev.accepted = true }
        else if (ev.key === Qt.Key_F) { root.cycleFace(); ev.accepted = true }
    }

    // ── 值（对标 QTime） ───────────────────────────────────────
    property var modelValue: null            // "HH:mm(:ss)" 串（24h 制存储）
    property bool format24h: false
    property bool withSeconds: false
    property var hourOptions: null           // 数组过滤（0-23）
    property var minuteOptions: null         // 0-59
    property var secondOptions: null
    property bool nowBtn: false

    // ── 外观/状态 ──────────────────────────────────────────────
    property color tint: NovaTheme.primary
    property bool disable: false
    property bool readonly: false
    property string hint: ""
    property bool error: false
    property string errorMessage: ""
    readonly property bool hasError: error || errorMessage !== ""

    signal valueChanged(var value)

    // ── 内部状态 ───────────────────────────────────────────────
    property int _h: 0                       // 0-23（内部恒 24h 制）
    property int _m: 0
    property int _s: 0
    property bool _isAm: true                // 显示侧状态（12h 模式）
    property int _face: 0                    // 0=时 1=分 2=秒
    property bool _touched: false            // 是否已选过（null → 值）

    readonly property string _fmt: withSeconds ? "HH:mm:ss" : "HH:mm"

    function _pad(v) { return v < 10 ? "0" + v : String(v) }

    onModelValueChanged: {
        if (modelValue === null || modelValue === undefined || modelValue === "") {
            _touched = false
            return
        }
        var m = /^(\d{1,2}):(\d{2})(?::(\d{2}))?$/.exec(String(modelValue))
        if (!m) return
        root._h = Math.min(23, parseInt(m[1], 10))
        root._m = Math.min(59, parseInt(m[2], 10))
        root._s = m[3] !== undefined ? Math.min(59, parseInt(m[3], 10)) : 0
        root._isAm = root._h < 12
        root._touched = true
    }

    function _emit() {
        var out = _pad(_h) + ":" + _pad(_m) + (withSeconds ? ":" + _pad(_s) : "")
        root.modelValue = out
        root.valueChanged(out)
    }

    function _inOptions(opts, v) {
        return opts === null || opts === undefined || opts.indexOf(v) > -1
    }

    function setHour(h) {
        if (!_inOptions(hourOptions, h)) return false
        root._h = h
        root._isAm = h < 12
        root._touched = true
        _emit()
        return true
    }
    function setMinute(m) {
        if (!_inOptions(minuteOptions, m)) return false
        root._m = m; root._touched = true
        _emit()
        return true
    }
    function setSecond(s) {
        if (!_inOptions(secondOptions, s)) return false
        root._s = s; root._touched = true
        _emit()
        return true
    }
    function toggleAmPm() {
        root._isAm = !root._isAm
        if (_touched) {
            root._h = (_h % 12) + (_isAm ? 0 : 12)
            _emit()
        }
        return _isAm
    }
    function cycleFace() {
        var next = _face + 1
        if (next === 2 && !withSeconds) next = 0
        if (next > 2) next = 0
        _face = next
        return _face
    }
    function setNow() {
        var t = new Date()
        if (_inOptions(hourOptions, t.getHours()) && _inOptions(minuteOptions, t.getMinutes())
                && (!withSeconds || _inOptions(secondOptions, t.getSeconds()))) {
            root._h = t.getHours(); root._m = t.getMinutes(); root._s = t.getSeconds()
            root._isAm = _h < 12
            root._touched = true
            _emit()
            return true
        }
        return false
    }
    function valueText() {
        return _touched ? _pad(_h) + ":" + _pad(_m) + (withSeconds ? ":" + _pad(_s) : "") : null
    }

    // ── 数字读出 ───────────────────────────────────────────────
    readonly property string _hDisplay: format24h ? _pad(_h)
        : _pad(_h % 12 === 0 ? 12 : _h % 12)
    readonly property bool _hDirty: _touched

    implicitWidth: 268
    implicitHeight: 300

    Rectangle {
        anchors.fill: parent
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border.width: 1
        border.color: root.hasError ? NovaTheme.negative : NovaTheme.outline
        opacity: root.disable ? 0.6 : 1
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        // 头部：读出 + AM/PM
        Row {
            width: parent.width
            height: 40
            spacing: 4
            Item { width: 1; height: 1 }
            // 时
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root._hDirty ? root._hDisplay : "--"
                color: root._face === 0 ? root.tint : NovaTheme.textColor
                font.pixelSize: 26
                font.weight: Font.DemiBold
                MouseArea { anchors.fill: parent; enabled: !root.disable; onClicked: root._face = 0 }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ":"
                color: NovaTheme.textMuted
                font.pixelSize: 26
            }
            // 分
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root._hDirty ? root._pad(root._m) : "--"
                color: root._face === 1 ? root.tint : NovaTheme.textColor
                font.pixelSize: 26
                font.weight: Font.DemiBold
                MouseArea { anchors.fill: parent; enabled: !root.disable; onClicked: root._face = 1 }
            }
            Text {
                visible: root.withSeconds
                anchors.verticalCenter: parent.verticalCenter
                text: ":"
                color: NovaTheme.textMuted
                font.pixelSize: 26
            }
            // 秒
            Text {
                visible: root.withSeconds
                anchors.verticalCenter: parent.verticalCenter
                text: root._hDirty ? root._pad(root._s) : "--"
                color: root._face === 2 ? root.tint : NovaTheme.textColor
                font.pixelSize: 26
                font.weight: Font.DemiBold
                MouseArea { anchors.fill: parent; enabled: !root.disable; onClicked: root._face = 2 }
            }
            Item { width: 1; height: 1 }
            // AM/PM
            Column {
                visible: !root.format24h
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Rectangle {
                    width: 40; height: 16; radius: 8
                    color: root._isAm ? root.tint : "transparent"
                    border.width: 1
                    border.color: root._isAm ? root.tint : NovaTheme.outline
                    Text { anchors.centerIn: parent; text: "上午"; font.pixelSize: 10
                           color: root._isAm ? NovaTheme.textOnPrimary : NovaTheme.textMuted }
                    MouseArea { anchors.fill: parent; enabled: !root.disable
                                onClicked: if (!root._isAm) root.toggleAmPm() }
                }
                Rectangle {
                    width: 40; height: 16; radius: 8
                    color: !root._isAm ? root.tint : "transparent"
                    border.width: 1
                    border.color: !root._isAm ? root.tint : NovaTheme.outline
                    Text { anchors.centerIn: parent; text: "下午"; font.pixelSize: 10
                           color: !root._isAm ? NovaTheme.textOnPrimary : NovaTheme.textMuted }
                    MouseArea { anchors.fill: parent; enabled: !root.disable
                                onClicked: if (root._isAm) root.toggleAmPm() }
                }
            }
        }

        // 时钟面盘
        Item {
            width: parent.width
            height: 210
            Canvas {
                id: clock
                anchors.centerIn: parent
                width: 200; height: 200
                readonly property real cx: width / 2
                readonly property real cy: height / 2
                readonly property real rOuter: width / 2 - 8
                Connections {
                    target: root
                    function on_HChanged() { clock.requestPaint() }
                    function on_MChanged() { clock.requestPaint() }
                    function on_SChanged() { clock.requestPaint() }
                    function on_FaceChanged() { clock.requestPaint() }
                }
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    // 外圈
                    ctx.beginPath()
                    ctx.arc(cx, cy, rOuter, 0, Math.PI * 2)
                    ctx.strokeStyle = NovaTheme.outline
                    ctx.lineWidth = 1
                    ctx.stroke()
                    if (_face === 0) {
                        // 时面：12 或 24 刻度
                        var n = root.format24h ? 24 : 12
                        ctx.fillStyle = NovaTheme.textColor
                        ctx.font = "600 12px sans-serif"
                        ctx.textAlign = "center"
                        ctx.textBaseline = "middle"
                        for (var i = 1; i <= n; i++) {
                            var deg = (i * 360 / n) - 90
                            var rad = deg * Math.PI / 180
                            var rr = root.format24h ? rOuter - 10 : rOuter - 14
                            ctx.fillText(String(i), cx + Math.cos(rad) * rr, cy + Math.sin(rad) * rr)
                        }
                        // 指针
                        var hv = root.format24h ? root._h : (root._h % 12 === 0 ? 12 : root._h % 12)
                        var hd = (hv * 360 / n) - 90
                        var hrad = hd * Math.PI / 180
                        ctx.beginPath()
                        ctx.moveTo(cx, cy)
                        ctx.lineTo(cx + Math.cos(hrad) * (rOuter - 26), cy + Math.sin(hrad) * (rOuter - 26))
                        ctx.strokeStyle = root.tint
                        ctx.lineWidth = 3
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.arc(cx + Math.cos(hrad) * (rOuter - 26), cy + Math.sin(hrad) * (rOuter - 26), 5, 0, Math.PI * 2)
                        ctx.fillStyle = root.tint
                        ctx.fill()
                    } else {
                        // 分/秒面：60 刻点，5 的倍数带数字
                        ctx.textAlign = "center"
                        ctx.textBaseline = "middle"
                        var val = _face === 1 ? root._m : root._s
                        var opts = _face === 1 ? root.minuteOptions : root.secondOptions
                        for (var k = 0; k < 60; k++) {
                            var d2 = (k * 6) - 90
                            var r2 = d2 * Math.PI / 180
                            var dis = _inOptions(opts, k)
                            if (k % 5 === 0) {
                                ctx.fillStyle = (dis && k === val) ? root.tint : NovaTheme.textColor
                                ctx.font = "600 10px sans-serif"
                                ctx.fillText(String(k), cx + Math.cos(r2) * (rOuter - 12), cy + Math.sin(r2) * (rOuter - 12))
                            } else {
                                ctx.beginPath()
                                ctx.arc(cx + Math.cos(r2) * (rOuter - 12), cy + Math.sin(r2) * (rOuter - 12), dis ? 2 : 1.2, 0, Math.PI * 2)
                                ctx.fillStyle = (dis && k === val) ? root.tint : NovaTheme.outline
                                ctx.fill()
                            }
                        }
                        // 指针
                        var vd = (val * 6) - 90
                        var vrad = vd * Math.PI / 180
                        ctx.beginPath()
                        ctx.moveTo(cx, cy)
                        ctx.lineTo(cx + Math.cos(vrad) * (rOuter - 30), cy + Math.sin(vrad) * (rOuter - 30))
                        ctx.strokeStyle = root.tint
                        ctx.lineWidth = 3
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.arc(cx + Math.cos(vrad) * (rOuter - 30), cy + Math.sin(vrad) * (rOuter - 30), 5, 0, Math.PI * 2)
                        ctx.fillStyle = root.tint
                        ctx.fill()
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                enabled: !root.disable && !root.readonly
                onPressed: (m) => {
                    var p = mapToItem(clock, m.x, m.y)
                    var dx = p.x - clock.cx
                    var dy = p.y - clock.cy
                    if (dx * dx + dy * dy < 900) return      // 圆心死区
                    var deg = (Math.atan2(dy, dx) * 180 / Math.PI + 90 + 360) % 360
                    if (root._face === 0) {
                        if (root.format24h) {
                            var h = Math.round(deg / 15) % 24
                            root.setHour(h)
                        } else {
                            var h12 = Math.round(deg / 30) % 12
                            var hh = h12 === 0 ? 12 : h12
                            root.setHour(root._isAm ? hh % 24 : (hh === 12 ? 0 : hh + 12))
                        }
                        root.cycleFace()                     // 选拨后自动进入分面（基线手感）
                    } else if (root._face === 1) {
                        root.setMinute(Math.round(deg / 6) % 60)
                    } else {
                        root.setSecond(Math.round(deg / 6) % 60)
                    }
                }
            }
        }

        // nowBtn
        Row {
            visible: root.nowBtn
            width: parent.width
            height: 24
            Rectangle {
                height: 22
                width: nowText.implicitWidth + 16
                radius: 11
                color: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.12)
                Text { id: nowText; anchors.centerIn: parent; text: "现在"; color: root.tint; font.pixelSize: 12 }
                MouseArea { anchors.fill: parent; enabled: !root.disable; onClicked: root.setNow() }
            }
        }
    }

    Text {
        visible: root.hint !== "" && !root.hasError
        x: 8; y: parent.height + 4
        text: root.hint
        color: NovaTheme.textMuted
        font.pixelSize: 11
    }
    Text {
        visible: root.hasError
        x: 8; y: parent.height + 4
        text: root.errorMessage !== "" ? root.errorMessage : "校验未通过"
        color: NovaTheme.negative
        font.pixelSize: 11
    }

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
