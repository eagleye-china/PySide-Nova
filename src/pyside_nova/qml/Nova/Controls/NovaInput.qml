// src/pyside_nova/qml/Nova/Controls/NovaInput.qml
// NovaInput 文本输入：单行/密码/多行/数字、modelModifiers、debounce、autogrow、clearable
// 对标 Quasar QInput（input 8 props + use-field + use-validate；NovaField 之下的控制层）
// 契约统一：label / hint / error / readonly / disable / clearable / rules
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Behaviors
import Nova.Design

NovaField {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.EditableText
    Accessible.name: a11yLabel !== "" ? a11yLabel : (label !== "" ? label : placeholder)
    Accessible.readOnly: readonly
    Accessible.focusable: !disable
    Accessible.focused: activeFocus

    // ── 对标 QInput 8 props ───────────────────────────────────
    property var modelValue: ""              // 对标 modelValue（string/number）
    property var modelModifiers: []          // number | trim | capitalize
    property string shadowText: ""           // 空值且未聚焦时的影子文本（对标 shadowText）
    property string type: "text"             // text|password|number|int|textarea|search|email|tel|url
    property int debounce: 0                 // valueChanged 防抖毫秒（对标 debounce）
    property bool autogrow: false            // textarea 自增高（对标 autogrow）
    property int maxLength: 0                // Nova 增强（HTML maxlength 语义）
    property string placeholder: ""          // Nova 增强：原生 placeholder

    // ── 事件 ──────────────────────────────────────────────────
    // 值通知走 modelValue 属性变更信号（对标 update:model-value）；另有显式信号：
    signal editingFinished()                 // 回车/失焦提交
    signal keyPressed(var event)
    property bool _emitting: false           // 内部提交旗标：避免 number 模式改写用户输入

    // ── 派生状态 ──────────────────────────────────────────────
    readonly property bool _isArea: type === "textarea"
    readonly property bool _isPassword: type === "password"
    readonly property string _text: _isArea ? area.text : input.text
    readonly property var _mods: Array.isArray(modelModifiers) ? modelModifiers : []

    readonly property var typedValue: {
        if (_mods.indexOf("number") > -1) {
            var n = parseFloat(root._text)
            return isNaN(n) ? null : n
        }
        var s = root._text
        if (_mods.indexOf("trim") > -1) s = s.trim()
        if (_mods.indexOf("capitalize") > -1 && s.length > 0)
            s = s.charAt(0).toUpperCase() + s.slice(1)
        return s
    }

    // 校验取值接线
    value: _text
    controlFocused: input.activeFocus || area.activeFocus
    customControlH: _isArea && autogrow ? Math.max(40, area.implicitHeight + 12) : -1
    counterText: counter ? (maxLength > 0 ? `${_text.length}/${maxLength}` : String(_text.length)) : ""

    // 双向同步（guard 防回环；_emitting 提交期间不改写输入文本）
    onModelValueChanged: {
        if (_emitting) return
        var s = modelValue === null || modelValue === undefined ? "" : String(modelValue)
        if (s !== root._text) root._setText(s)
    }
    function _setText(s) {
        if (_isArea) area.text = s
        else input.text = s
    }
    // 从文本源直接计算提交值（2026-11-27 坑位 53）：禁止在变更级联里读 typedValue
    // 绑定——onTextChanged 触发时 typedValue / _text 绑定尚未重算，读到的是
    // 上一次文本，导致 modelValue「写回滞后一拍」：宿主做外部回显时会把旧值
    // 提交回去、宿主守卫 v !== bridge.path 误判后把配置改回旧值（nova-forge
    // prescript 浏览选目录后被静默回退的真实事故）。直接读 input.text / area.text
    // 源头（readonly 值属性，非绑定），保证提交值与显示文本永远一致。
    function _typedOf(t) {
        let s = t
        if (_mods.indexOf("trim") > -1) s = s.trim()
        if (_mods.indexOf("capitalize") > -1 && s.length > 0)
            s = s.charAt(0).toUpperCase() + s.slice(1)
        if (_mods.indexOf("number") > -1) {
            const n = parseFloat(s)
            return isNaN(n) ? null : n
        }
        return s
    }
    function _emitChange() {
        root._emitting = true
        root.modelValue = root._typedOf(root._isArea ? area.text : input.text)
        root._emitting = false
    }

    // ── 校验/清空接线 ─────────────────────────────────────────
    onCleared: {
        root._setText("")
        root._emitChange()
        root.resetValidation()
    }

    // ── 键盘与提交 ────────────────────────────────────────────
    Keys.onReturnPressed: { editingFinished() }
    Keys.onEnterPressed: { editingFinished() }

    // ── 影子文本（shadowText：空值未聚焦时显示） ────────────────
    Text {
        visible: root.shadowText !== "" && root._text === "" && !root.controlFocused
        x: 0
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        text: root.shadowText
        color: NovaTheme.textMuted
        opacity: 0.75
        font.family: NovaTheme.fontFamily
        font.pixelSize: root.dense ? 12 : 14
        elide: Text.ElideRight
    }

    // placeholder（原生占位；与浮动 label 二选一场景由用户决定）
    Text {
        visible: root.placeholder !== "" && root._text === "" && !root.controlFocused
                 && root.label === ""
        x: 0
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        text: root.placeholder
        color: NovaTheme.textMuted
        font.family: NovaTheme.fontFamily
        font.pixelSize: root.dense ? 12 : 14
        elide: Text.ElideRight
    }

    // ── 单行 TextInput ────────────────────────────────────────
    TextInput {
        id: input
        anchors.fill: parent
        visible: !root._isArea
        enabled: !root.disable && !root.readonly
        color: NovaTheme.textColor
        selectionColor: root.tint
        selectedTextColor: NovaTheme.textOnPrimary
        font.family: NovaTheme.fontFamily
        font.pixelSize: root.dense ? 12 : 14
        echoMode: root._isPassword ? TextInput.Password : TextInput.Normal
        passwordCharacter: "●"
        activeFocusOnTab: !root.disable
        onTextChanged: {
            if (root.maxLength > 0 && text.length > root.maxLength) {
                var cur = text
                text = cur.substring(0, root.maxLength)
            }
            if (root.debounce > 0) debouncer.restart()
            else root._emitChange()
        }
        onActiveFocusChanged: {
            if (!activeFocus) {
                root.editingFinished()
                if (root.debounce > 0 && debouncer.running) {
                    debouncer.stop()
                    root._emitChange()
                }
            }
        }
        Keys.onPressed: (e) => root.keyPressed(e)
    }

    // ── 多行 TextArea（type: textarea） ────────────────────────
    TextArea {
        id: area
        anchors { left: parent.left; right: parent.right; top: parent.top }
        visible: root._isArea
        enabled: !root.disable && !root.readonly
        wrapMode: TextInput.Wrap
        color: NovaTheme.textColor
        selectionColor: root.tint
        selectedTextColor: NovaTheme.textOnPrimary
        font.family: NovaTheme.fontFamily
        font.pixelSize: root.dense ? 12 : 14
        activeFocusOnTab: !root.disable
        background: null
        onTextChanged: {
            if (root.debounce > 0) debouncer.restart()
            else root._emitChange()
        }
        onActiveFocusChanged: {
            if (!activeFocus) {
                root.editingFinished()
                if (root.debounce > 0 && debouncer.running) {
                    debouncer.stop()
                    root._emitChange()
                }
            }
        }
    }

    // debounce 计时器（坑位 20：Timer 显式 start）
    Timer {
        id: debouncer
        interval: Math.max(1, root.debounce)
        onTriggered: root._emitChange()
    }

    Component.onCompleted: if (autofocus && !disable) setFocus()

    // 公开焦点方法（Nova 增强；命名避坑：Item.focus 为 FINAL 成员，重声明/重名会失效——坑位 12）
    function setFocus() {
        if (_isArea) area.forceActiveFocus()
        else input.forceActiveFocus()
    }

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
