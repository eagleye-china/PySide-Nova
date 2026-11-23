// src/pyside_nova/qml/Nova/Controls/NovaOptionGroup.qml
// NovaOptionGroup 选项组：checkbox/radio/toggle 三型统一、options 归一化、inline/纵向布局
// 对标 Quasar QOptionGroup（24 props 含继承 use-checkbox 18；Nova 收口核心 21 项，
// size/validator/name 留痕见 PARITY）
// 契约统一：hint / error / readonly / disable
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.Grouping
    Accessible.name: a11yLabel

    // ── 组型与选项（对标 QOptionGroup） ─────────────────────────
    property string type: "checkbox"         // checkbox | radio | toggle
    property var options: []                 // 标量数组或 [{label, value, disable}]
    property string optionValue: "value"     // 值键名
    property string optionLabel: "label"     // 文案键名
    property string optionDisable: "disable"
    property var modelValue: []              // checkbox/toggle: 数组；radio: 标量

    // ── 外观（对标） ───────────────────────────────────────────
    property bool inline: false              // 横排
    property bool leftLabel: false
    property bool keepColor: false
    property color tint: NovaTheme.primary   // 对标 color
    property bool dense: false
    property bool disable: false
    property bool readonly: false
    property bool activeTab: !disable
    property string hint: ""
    property bool error: false
    property string errorMessage: ""
    readonly property bool hasError: error || errorMessage !== ""

    signal valueChanged(var value)           // 对标 update:model-value

    // ── 选项归一化（与 NovaSelect 同管道） ──────────────────────
    readonly property var _normalized: {
        var out = []
        var arr = Array.isArray(options) ? options : []
        for (var i = 0; i < arr.length; i++) {
            var o = arr[i]
            if (o === null || o === undefined) continue
            if (typeof o === "object") {
                out.push({
                    label: String(o[optionLabel] !== undefined ? o[optionLabel] : o),
                    value: o[optionValue],
                    disable: o[optionDisable] === true
                })
            } else {
                out.push({ label: String(o), value: o, disable: false })
            }
        }
        return out
    }

    // ── 值语义（radio=标量 / checkbox·toggle=数组） ─────────────
    readonly property bool _scalarMode: type === "radio"
    function _has(v) {
        return _scalarMode ? modelValue === v
             : (Array.isArray(modelValue) && modelValue.indexOf(v) > -1)
    }

    function _setRadio(v) {
        if (disable || readonly) return
        root.modelValue = v
        root.valueChanged(v)
    }
    function _setArray(v, on) {
        if (disable || readonly) return
        var arr = Array.isArray(modelValue) ? modelValue.slice() : []
        var idx = arr.indexOf(v)
        if (on && idx === -1) arr.push(v)
        else if (!on && idx > -1) arr.splice(idx, 1)
        root.modelValue = arr
        root.valueChanged(arr)
    }

    // 编程通道（测试/宿主）
    function selectOption(value) {
        for (var i = 0; i < _normalized.length; i++) {
            var o = _normalized[i]
            if (o.value === value) {
                if (o.disable || disable || readonly) return false
                if (_scalarMode) _setRadio(value)
                else _setArray(value, !_has(value))
                return true
            }
        }
        return false
    }
    function resetValue() {
        var empty = _scalarMode ? null : []
        root.modelValue = empty
        root.valueChanged(empty)
    }

    // ── 布局 ───────────────────────────────────────────────────
    implicitWidth: inline ? 300 : 200
    implicitHeight: _normalized.length * (dense ? 26 : 34)
                    + ((hint !== "" && !hasError) || hasError ? 16 : 0)

    Column {
        id: flow
        anchors.top: parent.top
        width: parent.width
        spacing: root.dense ? 4 : 8

        // 横排时外包一行
        Row {
            visible: root.inline
            width: parent.width
            spacing: NovaTheme.spacingM
            Repeater { model: root._normalized; delegate: optDelegate }
        }
        // 纵排
        Column {
            visible: !root.inline
            width: parent.width
            spacing: root.dense ? 4 : 8
            Repeater { model: root._normalized; delegate: optDelegate }
        }
    }

    component OptItem: Item {
        id: it
        property var opt: null
        readonly property bool on: root._has(opt ? opt.value : null)
        width: flow.width
        height: root.dense ? 24 : 32
        Loader {
            id: ld
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: root.type === "radio" ? radioC
                           : (root.type === "toggle" ? toggleC : checkC)
        }
        Component {
            id: checkC
            NovaCheckbox {
                label: it.opt.label
                val: it.opt.value
                modelValue: it.on ? it.opt.value : "__nova_off__"
                leftLabel: root.leftLabel
                keepColor: root.keepColor
                dense: root.dense
                disable: root.disable || it.opt.disable
                tint: root.tint
                onToggled: (chk) => root._setArray(it.opt.value, chk)
            }
        }
        Component {
            id: radioC
            NovaRadio {
                label: it.opt.label
                val: it.opt.value
                modelValue: root.modelValue
                leftLabel: root.leftLabel
                dense: root.dense
                disable: root.disable || it.opt.disable
                tint: root.tint
                onSelected: root._setRadio(it.opt.value)
            }
        }
        Component {
            id: toggleC
            NovaToggle {
                label: it.opt.label
                val: it.opt.value
                modelValue: it.on ? it.opt.value : "__nova_off__"
                leftLabel: root.leftLabel
                keepColor: root.keepColor
                dense: root.dense
                disable: root.disable || it.opt.disable
                tint: root.tint
                onToggled: (chk) => root._setArray(it.opt.value, chk)
            }
        }
    }
    // Repeater delegate（inline component 实例化，modelData 注入 opt）
    Component {
        id: optDelegate
        OptItem { opt: modelData }
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
