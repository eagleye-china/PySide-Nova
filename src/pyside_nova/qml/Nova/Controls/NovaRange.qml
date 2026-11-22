// src/pyside_nova/qml/Nova/Controls/NovaRange.qml
// NovaRange 双值范围滑杆：左右滑块、step 量化、min/maxRange 约束、markers、气泡
// 对标 Quasar QRange（20 props；Nova 收口核心 17 项，aria/img 类留痕见 PARITY）
// 契约统一：hint / error / readonly / disable
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 值域（对标 QRange） ───────────────────────────────────
    property var modelValue: ({ min: 0, max: 50 })   // { min, max }
    property real min: 0
    property real max: 100
    property real step: 1
    property bool snap: false
    property bool reverse: false
    property bool vertical: false
    property real minRange: 0                        // 两滑块最小间距
    property real maxRange: 0                        // 0=不限制；>0 最大间距
    property bool dragRange: false                   // 整段拖动（Nova：拖右滑块同移）

    // ── 外观 ──────────────────────────────────────────────────
    property color tint: NovaTheme.primary
    property color trackColor: NovaTheme.outline
    property color selectionColor: tint
    property color leftThumbColor: tint              // 对标 left-thumb-color
    property color rightThumbColor: tint             // 对标 right-thumb-color
    property real trackSize: dense ? 2 : 4
    property real thumbSize: dense ? 14 : 20
    property bool dense: false
    property bool dark: NovaTheme.isDark

    // ── 气泡 label ────────────────────────────────────────────
    property bool label: false
    property bool labelAlways: false
    property string leftLabelValue: ""               // 对标 left-label-value
    property string rightLabelValue: ""

    // ── 刻度 ──────────────────────────────────────────────────
    property var markers: false
    property var markerLabels: null

    // ── 状态（契约统一） ───────────────────────────────────────
    property bool disable: false
    property bool readonly: false
    property bool activeTab: !disable
    property string hint: ""
    property bool error: false
    property string errorMessage: ""

    readonly property bool hasError: error || errorMessage !== ""

    signal valueChanged(var value)                   // 对标 update:model-value
    signal changed()                                 // 拖拽结束提交（对标 @change）

    // ── 取值数学（与 NovaSlider 同管道） ────────────────────────
    readonly property real _lo: min
    readonly property real _hi: max
    readonly property real _left: Number(_norm.min)
    readonly property real _right: Number(_norm.max)
    readonly property var _norm: _normalize(modelValue)
    property bool updatingFromDrag: false

    function _normalize(mv) {
        if (!mv || typeof mv !== "object")
            return { min: 0, max: 0 }
        var o = mv
        var l = Number(o.min !== undefined ? o.min : 0)
        var r = Number(o.max !== undefined ? o.max : 0)
        if (l > r) { var t = l; l = r; r = t }
        return { min: l, max: r }
    }

    function _quantize(v) {
        if (step <= 0) return v
        var q = Math.round((v - _lo) / step) * step + _lo
        var dec = (String(step).split(".")[1] || "").length
        return parseFloat(q.toFixed(Math.min(dec, 10)))
    }

    function posToValue(pos) {
        var len = vertical ? height - thumbSize : width - thumbSize
        if (len <= 0) return _lo
        var t = pos / len
        if (reverse) t = 1 - t
        t = Math.max(0, Math.min(1, t))
        return _quantize(_lo + t * (_hi - _lo))
    }

    function setRange(left, right) {
        var l = Math.max(_lo, Math.min(_hi, _quantize(Number(left))))
        var r = Math.max(_lo, Math.min(_hi, _quantize(Number(right))))
        if (l > r) { var t = l; l = r; r = t }
        // min/maxRange 约束
        if (minRange > 0 && r - l < minRange)
            r = Math.min(_hi, l + minRange)
        if (maxRange > 0 && r - l > maxRange)
            r = l + maxRange
        if (r > _hi) r = _hi
        if (root.modelValue && typeof root.modelValue === "object"
                && root.modelValue.min === l && root.modelValue.max === r) return
        root.modelValue = { min: l, max: r }
        root.valueChanged(root.modelValue)
    }

    function setValueLeft(v) {
        var c = Math.max(_lo, Math.min(_right - minRange, _quantize(Number(v))))
        setRange(c, _right)
    }
    function setValueRight(v) {
        var c = Math.max(_left + minRange, Math.min(_hi, _quantize(Number(v))))
        if (maxRange > 0) c = Math.min(c, _left + maxRange)
        setRange(_left, c)
    }

    onModelValueChanged: if (!updatingFromDrag) {
        // 夹取回写（只读修正不触发信号）；直接函数调用取值，避开绑定重评期 undefined（坑位 24）
        if (!modelValue || typeof modelValue !== "object") return
        var n = _normalize(modelValue)
        if (Number(modelValue.min) !== n.min || Number(modelValue.max) !== n.max)
            setRange(n.min, n.max)
    }

    // ── 布局 ──────────────────────────────────────────────────
    implicitWidth: vertical ? Math.max(thumbSize, 24) : 200
    implicitHeight: vertical ? 200 : Math.max(thumbSize, 24)
                    + ((hint !== "" && !hasError) || hasError ? 16 : 0)

    readonly property real _trackLen: (vertical ? height : width) - thumbSize
    function _pct(v) {
        var p = (v - _lo) / Math.max(_hi - _lo, 1e-9)
        return reverse ? 1 - Math.max(0, Math.min(1, p)) : Math.max(0, Math.min(1, p))
    }
    readonly property real _leftPos: thumbSize / 2 + _pct(_left) * _trackLen
    readonly property real _rightPos: thumbSize / 2 + _pct(_right) * _trackLen
    readonly property string _leftText: leftLabelValue !== "" ? leftLabelValue : String(_left)
    readonly property string _rightText: rightLabelValue !== "" ? rightLabelValue : String(_right)

    // ── 轨道 ──────────────────────────────────────────────────
    Rectangle {
        color: root.trackColor
        radius: root.trackSize / 2
        x: root.vertical ? (root.width - root.trackSize) / 2 : root.thumbSize / 2
        y: root.vertical ? root.thumbSize / 2 : (root.height - root.trackSize) / 2
        width: root.vertical ? root.trackSize : root._trackLen
        height: root.vertical ? root._trackLen : root.trackSize
        opacity: root.disable ? 0.4 : 1
    }
    Rectangle {
        color: root.hasError ? NovaTheme.negative : root.selectionColor
        radius: root.trackSize / 2
        x: root.vertical ? (root.width - root.trackSize) / 2
           : Math.min(root._leftPos, root._rightPos)
        y: root.vertical ? Math.min(root._leftPos, root._rightPos)
           : (root.height - root.trackSize) / 2
        width: root.vertical ? root.trackSize
           : Math.abs(root._rightPos - root._leftPos)
        height: root.vertical ? Math.abs(root._rightPos - root._leftPos)
           : root.trackSize
        opacity: root.disable ? 0.4 : 1
    }

    // ── 刻点 ──────────────────────────────────────────────────
    readonly property int _markerCount: {
        if (!markers && !snap) return 0
        var stepCount = Math.floor((root._hi - root._lo) / root.step + 0.5)
        return Math.min(stepCount + 1, 200)
    }
    readonly property real _markerEvery: typeof markers === "number" && markers > 1 ? markers : 1
    Repeater {
        model: root._markerCount
        Rectangle {
            required property int index
            readonly property real t: index / (root._markerCount - 1)
            readonly property real p: root.reverse ? 1 - t : t
            x: root.vertical ? (root.width - 2) / 2 : root.thumbSize / 2 + p * root._trackLen - 1
            y: root.vertical ? root.thumbSize / 2 + p * root._trackLen - 1
               : (root.height - root.trackSize) / 2 - 4
            width: 2; height: 2; radius: 1
            color: root.dark ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.3)
            visible: root._markerCount > 1 && index % root._markerEvery === 0
        }
    }
    Repeater {
        model: root.markerLabels === true ? root._markerCount
             : (Array.isArray(root.markerLabels) ? root.markerLabels.length : 0)
        Text {
            required property int index
            readonly property real t: index / (root._markerCount - 1)
            readonly property real p: root.reverse ? 1 - t : t
            readonly property string txt: Array.isArray(root.markerLabels)
                                          ? String(root.markerLabels[index])
                                          : String(root._quantize(root._lo + index * root.step))
            x: root.vertical ? root.width + 4 : root.thumbSize / 2 + p * root._trackLen - width / 2
            y: root.vertical ? root.thumbSize / 2 + p * root._trackLen - height / 2
               : (root.height - root.trackSize) / 2 + root.trackSize + 4
            text: txt
            color: NovaTheme.textMuted
            font.pixelSize: 9
        }
    }

    // ── 双滑块 ────────────────────────────────────────────────
    component Thumb: Rectangle {
        id: th
        property bool isLeft: false
        readonly property real pos: isLeft ? root._leftPos : root._rightPos
        x: root.vertical ? (root.width - root.thumbSize) / 2 : pos - root.thumbSize / 2
        y: root.vertical ? pos - root.thumbSize / 2
           : (root.height - root.trackSize) / 2 - (root.thumbSize - root.trackSize) / 2
        width: root.thumbSize; height: root.thumbSize; radius: root.thumbSize / 2
        color: root.hasError ? NovaTheme.negative
             : (isLeft ? root.leftThumbColor : root.rightThumbColor)
        border.width: 2
        border.color: NovaTheme.surface
        opacity: root.disable ? 0.5 : 1
        scale: ma.containsMouse || root._dragLeft === isLeft && root._dragging ? 1.15 : 1
        Rectangle {
            id: bubble
            x: root.vertical ? (root.thumbSize - width) / 2 + 8 : (root.thumbSize - width) / 2
            y: root.vertical ? -height + 4 : -height - 4
            width: bt.implicitWidth + 12
            height: 20
            radius: 4
            color: root.hasError ? NovaTheme.negative : root.tint
            visible: root.label && (root.labelAlways || root._dragging)
            Text {
                id: bt
                anchors.centerIn: parent
                text: th.isLeft ? root._leftText : root._rightText
                color: NovaTheme.textOnPrimary
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            anchors.margins: -6
            enabled: !root.disable && !root.readonly
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            property bool dragging: false
            onPressed: { dragging = true; root._dragging = true; root._dragLeft = th.isLeft }
            onReleased: { dragging = false; root._dragging = false; root.changed() }
            onPositionChanged: (m) => {
                if (!dragging) return
                var g = mapToItem(root, m.x + th.x, m.y + th.y)
                var v = root.posToValue(root.vertical ? g.y - root.thumbSize / 2
                                                      : g.x - root.thumbSize / 2)
                if (th.isLeft) root.setValueLeft(v)
                else root.setValueRight(v)
            }
        }
    }
    property bool _dragging: false
    property bool _dragLeft: false
    Thumb { isLeft: true }
    Thumb { isLeft: false }

    // 点轨道空档：跳最近的滑块
    MouseArea {
        anchors.fill: parent
        enabled: !root.disable && !root.readonly
        z: -1
        cursorShape: Qt.PointingHandCursor
        onPressed: (m) => {
            var v = root.posToValue(root.vertical ? m.y - root.thumbSize / 2
                                                  : m.x - root.thumbSize / 2)
            if (Math.abs(v - root._left) <= Math.abs(v - root._right))
                root.setValueLeft(v)
            else root.setValueRight(v)
        }
    }

    // ── 键盘（聚焦于最近滑块） ─────────────────────────────────
    activeFocusOnTab: root.activeTab
    Keys.onLeftPressed: { reverse ? setValueRight(_right + step) : setValueLeft(_left - step) ; changed() }
    Keys.onRightPressed: { reverse ? setValueLeft(_left - step) : setValueRight(_right + step) ; changed() }
    Keys.onPressed: (e) => {
        if (e.key === Qt.Key_Home) setRange(_lo, _right)
        else if (e.key === Qt.Key_End) setRange(_left, _hi)
    }

    Text {
        visible: root.hint !== "" && !root.hasError
        x: 0; y: parent.height - 14
        text: root.hint
        color: NovaTheme.textMuted
        font.pixelSize: 11
    }
    Text {
        visible: root.hasError
        x: 0; y: parent.height - 14
        text: root.errorMessage !== "" ? root.errorMessage : "校验未通过"
        color: NovaTheme.negative
        font.pixelSize: 11
    }
}
