// src/pyside_nova/qml/Nova/Controls/NovaForm.qml
// NovaForm 表单容器：聚合子组件校验（递归发现 validate() 能力）、greedy 全量校验、
// 提交聚合、错误焦点（对标 Quasar QForm 5 props 1:1）
// 契约统一：readonly / disable 由子组件自持，本组件只做编排
import QtQuick
import Nova.Services

Column {
    id: root

    // ── 对标 QForm props ───────────────────────────────────────
    property bool greedy: false              // true=全量校验（非短路）
    property bool autofocus: false           // 完成后聚焦首个可输入子件
    property bool noErrorFocus: false        // 校验失败不聚焦
    property bool noResetFocus: false        // reset 不移焦点

    // ── 事件（对标 QForm） ──────────────────────────────────────
    signal submitted()                       // submit() 校验通过后发出
    signal validationSuccess(bool res)
    signal validationFailed(var errors)      // 未通过子件列表

    // ── 子件发现（递归扫描 validate() 能力；Item.children 为列表属性） ──
    function _collectFields(item, out) {
        if (!item) return out
        if (typeof item.validate === "function"
                && item.hasError !== undefined
                && item !== root) {
            out.push(item)
        }
        var kids = item.children
        for (var i = 0; i < kids.length; i++)
            _collectFields(kids[i], out)
        return out
    }

    readonly property var _fields: {
        var items = []
        var kids = root.children
        for (var i = 0; i < kids.length; i++)
            _collectFields(kids[i], items)
        return items
    }

    // ── 校验编排 ───────────────────────────────────────────────
    function validate() {
        var ok = true
        var errors = []
        var fields = _fields
        for (var i = 0; i < fields.length; i++) {
            var f = fields[i]
            var r = f.validate()
            if (r === false) {
                ok = false
                errors.push(f)
                if (!greedy) break              // 短路（基线默认）
            }
        }
        if (!ok && !noErrorFocus && errors.length > 0) {
            var first = errors[0]
            if (first.setFocus) first.setFocus()
            else first.forceActiveFocus()
        }
        if (ok) validationSuccess(true)
        else validationFailed(errors)
        return ok
    }

    function resetValidation() {
        var fields = _fields
        for (var i = 0; i < fields.length; i++) {
            if (typeof fields[i].resetValidation === "function")
                fields[i].resetValidation()
        }
    }

    function submit() {
        if (validate()) {
            submitted()
            return true
        }
        return false
    }

    Component.onCompleted: if (autofocus) {
        var fields = _fields
        for (var i = 0; i < fields.length; i++) {
            if (typeof fields[i].setFocus === "function") { fields[i].setFocus(); break }
        }
    }
}
