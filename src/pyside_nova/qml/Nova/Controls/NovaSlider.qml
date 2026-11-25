// src/pyside_nova/qml/Nova/Controls/NovaSlider.qml
// NovaSlider 滑杆：拖拽/键盘取值、step 量化、snap 刻点、markers、label 气泡、垂直模式
// 对标 Quasar QSlider（use-slider 33 props；Nova 收口 26 项，img 类留痕见 PARITY）
// 契约统一：label（气泡沫）/ hint / error / readonly / disable
import QtQuick
import Nova.Services
import Nova.Behaviors
import Nova.Design

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.Slider
    // 注意：QSlider 语义的 label 是「显示值标签」布尔开关（对标 QSlider.label），不可当可读名
    Accessible.name: a11yLabel
    Accessible.readOnly: readonly
    Accessible.focusable: !disable
    Accessible.focused: activeFocus
    enabled: !disable

    // ── 值域（对标 use-slider） ────────────────────────────────
    property var modelValue: 0
    property real min: 0
    property real max: 100
    property real innerMin: 0                // 对标 inner-min
    property real innerMax: 100              // 对标 inner-max
    property real step: 1
    property bool snap: false                // 对标 snap（刻点吸附显示）
    property bool reverse: false
    property bool vertical: false

    // ── 外观 ──────────────────────────────────────────────────
    property color tint: NovaTheme.primary   // 对标 color
    property color trackColor: NovaTheme.outline
    property color selectionColor: tint      // 对标 selection-color
    property color thumbColor: tint          // 对标 thumb-color
    property real trackSize: dense ? 2 : 4   // 对标 track-size
    property real thumbSize: dense ? 14 : 20 // 对标 thumb-size
    // CARF 基础组件 Robustness：thumb/track 尺寸非法入参钳制，几何恒非负且不超父短边。
    readonly property real _dim: Math.min(root.width, root.height)
    readonly property real _thumbSize: Math.max(0, Math.min(root.thumbSize, root._dim))
    readonly property real _trackSize: Math.max(0, Math.min(root.trackSize, root._dim))
    property bool dense: false
    property bool dark: NovaTheme.isDark

    // ── 气泡 label（对标 label/label-always/label-value） ───────
    property bool label: false               // 拖拽/键盘时显示气泡
    property bool labelAlways: false
    property string labelValue: ""           // 自定义气泡文案

    // ── 刻度（对标 markers/marker-labels） ─────────────────────
    property var markers: false              // true=每 step 一个刻点；数字=间隔
    property var markerLabels: null          // true=数值标签；数组=自定义标签

    // ── 状态（契约统一） ───────────────────────────────────────
    property bool disable: false
    property bool readonly: false
    property bool activeTab: !disable
    property string hint: ""
    property bool error: false
    property string errorMessage: ""

    readonly property bool hasError: error || errorMessage !== ""
    readonly property bool _focused: dragArea.drag.active || keyboardFocus

    signal valueChanged(var value)           // 对标 update:model-value
    signal changed()                         // 拖拽结束/键盘释放提交（对标 @change）

    // ── 取值数学（对标 QSlider 数值管道） ───────────────────────
    readonly property real _lo: Math.max(min, innerMin)
    readonly property real _hi: Math.min(max, innerMax)
    readonly property real _pct: (Number(modelValue) - _lo) / Math.max(_hi - _lo, 1e-9)
    readonly property string _labelText: labelValue !== "" ? labelValue : String(modelValue)
    property bool keyboardFocus: false

    function _quantize(v) {
        if (step <= 0) return v
        var q = Math.round((v - _lo) / step) * step + _lo
        // 浮点噪声收敛到 step 精度
        var dec = (String(step).split(".")[1] || "").length
        return parseFloat(q.toFixed(Math.min(dec, 10)))
    }

    function posToValue(pos) {
        var len = vertical ? height - _thumbSize : width - _thumbSize
        if (len <= 0) return _lo
        var t = pos / len
        if (reverse) t = 1 - t
        t = Math.max(0, Math.min(1, t))
        return _quantize(_lo + t * (_hi - _lo))
    }

    function setValue(v) {
        var c = Math.max(_lo, Math.min(_hi, _quantize(Number(v))))
        if (c === Number(root.modelValue)) return
        root.modelValue = c
        root.valueChanged(c)
    }

    // 测试与宿主便捷通道：按步进走 N 步
    function stepBy(n) {
        setValue(Number(root.modelValue) + n * step)
        root.changed()
    }

    onModelValueChanged: if (!dragArea.drag.active && !updatingFromDrag) {
        var c = Math.max(_lo, Math.min(_hi, Number(modelValue)))
        if (c !== Number(modelValue)) modelValue = c
    }
    property bool updatingFromDrag: false

    // ── 布局 ──────────────────────────────────────────────────
    implicitWidth: vertical ? Math.max(_thumbSize, 24) : 200
    implicitHeight: vertical ? 200 : Math.max(_thumbSize, 24)
                    + ((hint !== "" && !hasError) || hasError ? 16 : 0)

    // 轨道坐标（vertical：y 轴）
    readonly property real _trackLen: (vertical ? height : width) - _thumbSize
    readonly property real _thumbPos: _thumbSize / 2 + (reverse ? 1 - Math.max(0, Math.min(1, _pct)) : Math.max(0, Math.min(1, _pct))) * _trackLen
    readonly property real _selLen: Math.max(0, Math.min(1, _pct)) * _trackLen

    // ── 轨道 ──────────────────────────────────────────────────
    Rectangle {
        id: track
        color: root.trackColor
        radius: root._trackSize / 2
        x: root.vertical ? (root.width - root._trackSize) / 2 : root._thumbSize / 2
        y: root.vertical ? root._thumbSize / 2 : (root.height - root._trackSize) / 2
        width: root.vertical ? root._trackSize : root._trackLen
        height: root.vertical ? root._trackLen : root._trackSize
        opacity: root.disable ? 0.4 : 1
    }

    // 已选段
    Rectangle {
        color: root.hasError ? NovaTheme.negative : root.selectionColor
        radius: root._trackSize / 2
        x: root.vertical ? (root.width - root._trackSize) / 2
           : (root.reverse ? root._thumbPos : root._thumbSize / 2)
        y: root.vertical ? (root.reverse ? root._thumbSize / 2 : root._thumbPos)
           : (root.height - root._trackSize) / 2
        width: root.vertical ? root._trackSize : root._selLen
        height: root.vertical ? root._selLen : root._trackSize
        visible: root._selLen > 0
        opacity: root.disable ? 0.4 : 1
    }

    // ── 刻点（snap/markers） ───────────────────────────────────
    readonly property int _markerCount: {
        if (!markers && !snap) return 0
        var stepCount = Math.floor((root._hi - root._lo) / root.step + 0.5)
        return Math.min(stepCount + 1, 200)
    }
    readonly property real _markerEvery: typeof markers === "number" && markers > 1
                                         ? markers : 1
    Repeater {
        model: root._markerCount
        Rectangle {
            required property int index
            readonly property real t: root.reverse ? 1 - index / (root._markerCount - 1)
                                                   : index / (root._markerCount - 1)
            x: root.vertical ? (root.width - 2) / 2
               : root._thumbSize / 2 + t * root._trackLen - 1
            y: root.vertical ? root._thumbSize / 2 + t * root._trackLen - 1
               : (root.height - root._trackSize) / 2 - 4
            width: root.vertical ? 2 : 2
            height: root.vertical ? 2 : 2
            radius: 1
            color: root.dark ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.3)
            visible: root._markerCount > 1 && index % root._markerEvery === 0
        }
    }

    // 刻度标签（markerLabels）
    Repeater {
        model: root.markerLabels === true ? root._markerCount
             : (Array.isArray(root.markerLabels) ? root.markerLabels.length : 0)
        Text {
            required property int index
            readonly property real t: root.reverse ? 1 - index / (root._markerCount - 1)
                                                   : index / (root._markerCount - 1)
            readonly property string txt: Array.isArray(root.markerLabels)
                                          ? String(root.markerLabels[index])
                                          : String(root._quantize(root._lo + index * root.step))
            x: root.vertical ? root.width + 4
               : root._thumbSize / 2 + t * root._trackLen - width / 2
            y: root.vertical ? root._thumbSize / 2 + t * root._trackLen - height / 2
               : (root.height - root._trackSize) / 2 + root._trackSize + 4
            text: txt
            color: NovaTheme.textMuted
            font.pixelSize: 9
        }
    }

    // ── 滑块 ──────────────────────────────────────────────────
    Rectangle {
        id: thumb
        x: root.vertical ? (root.width - root._thumbSize) / 2 : root._thumbPos - root._thumbSize / 2
        y: root.vertical ? root._thumbPos - root._thumbSize / 2
           : (root.height - root._trackSize) / 2 - (root._thumbSize - root._trackSize) / 2
        width: root._thumbSize; height: root._thumbSize; radius: root._thumbSize / 2
        color: root.hasError ? NovaTheme.negative : root.thumbColor
        border.width: 2
        border.color: NovaTheme.surface
        opacity: root.disable ? 0.5 : 1
        scale: root._focused ? 1.15 : 1
        Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }

        // label 气泡（拖拽/键盘/labelAlways 显示）
        Rectangle {
            id: bubble
            x: root.vertical ? (root._thumbSize - width) / 2 + 8 : (root._thumbSize - width) / 2
            y: root.vertical ? -height + 4 : -height - 4
            width: bubbleText.implicitWidth + 12
            height: 20
            radius: 4
            color: root.hasError ? NovaTheme.negative : root.tint
            visible: root.label && (root.labelAlways || root._focused)
            Text {
                id: bubbleText
                anchors.centerIn: parent
                text: root._labelText
                color: NovaTheme.textOnPrimary
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
        }
    }

    // ── 交互 ──────────────────────────────────────────────────
    MouseArea {
        id: dragArea
        anchors.fill: parent
        enabled: !root.disable && !root.readonly
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onPressed: (m) => {
            root.updatingFromDrag = true
            root.setValue(root.posToValue(root.vertical ? m.y - root._thumbSize / 2
                                                        : m.x - root._thumbSize / 2))
            root.updatingFromDrag = false
        }
        onPositionChanged: (m) => {
            if (!pressed) return
            root.updatingFromDrag = true
            root.setValue(root.posToValue(root.vertical ? m.y - root._thumbSize / 2
                                                        : m.x - root._thumbSize / 2))
            root.updatingFromDrag = false
        }
        onReleased: root.changed()
        drag.target: null
    }

    Keys.onLeftPressed: { stepBy(reverse ? 1 : -1) }
    Keys.onRightPressed: { stepBy(reverse ? -1 : 1) }
    Keys.onUpPressed: { stepBy(vertical ? (reverse ? -1 : 1) : 0) }
    Keys.onDownPressed: { stepBy(vertical ? (reverse ? 1 : -1) : 0) }
    Keys.onPressed: (e) => {
        if (e.key === Qt.Key_Home) { setValue(_lo); changed() }
        else if (e.key === Qt.Key_End) { setValue(_hi); changed() }
    }
    activeFocusOnTab: root.activeTab
    onActiveFocusChanged: keyboardFocus = activeFocus

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

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
