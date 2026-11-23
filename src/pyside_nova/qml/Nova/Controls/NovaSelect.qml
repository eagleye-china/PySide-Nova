// src/pyside_nova/qml/Nova/Controls/NovaSelect.qml
// NovaSelect 下拉选择：options 归一化 / single+multiple / emitValue / useInput 过滤 / 下拉弹层
// 对标 Quasar QSelect（47 props；Nova 收口核心 24 项，其余留痕见 PARITY）
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
    Accessible.role: Accessible.ComboBox
    Accessible.name: a11yLabel !== "" ? a11yLabel : label
    Accessible.readOnly: readonly
    Accessible.focusable: !disable
    Accessible.focused: activeFocus

    // ── 对标 QSelect 核心组 ───────────────────────────────────
    property var options: []                 // [{label,value,disable}] 或标量数组
    property string optionValue: "value"     // 值键名
    property string optionLabel: "label"     // 文案键名
    property string optionDisable: "disable"
    property var modelValue: null            // 单选：值/对象；多选：数组
    property bool multiple: false
    property bool emitValue: false           // true=模型取原始值；false=取选项对象（对标语义）
    property string displayValue: ""         // 自定义展示文案（对标 display-value）
    property bool hideDropdownIcon: false
    property string dropdownIcon: "mdi:menu-down"
    property bool optionsDense: false
    property bool optionsCover: false        // Nova 简化：true=向上弹（近似 cover 语义）
    property string noOptionLabel: ""        // 空选项文案（对标 no-option-label）
    property int maxValues: 0                // 多选上限（0=不限）
    property bool useInput: false            // 键入过滤（对标 use-input）
    property string inputPlaceholder: ""     // useInput 占位

    // 值通知走 modelValue 属性变更信号（对标 update:model-value）
    signal popupShow()
    signal popupHide()
    signal newValue(var input)               // useInput 下回车新值（对标 @new-value）

    // ── 选项归一化（对标 QSelect getPropValues 语义） ───────────
    readonly property var _normalized: {
        var out = []
        var list = Array.isArray(options) ? options : []
        for (var i = 0; i < list.length; i++) {
            var o = list[i]
            if (o !== null && typeof o === "object") {
                out.push({
                    label: String(o[optionLabel] !== undefined ? o[optionLabel] : o),
                    value: o[optionValue] !== undefined ? o[optionValue] : o,
                    disable: o[optionDisable] === true,
                    src: o
                })
            } else {
                out.push({ label: String(o), value: o, disable: false, src: o })
            }
        }
        return out
    }
    readonly property var _selectedValues: {
        if (modelValue === null || modelValue === undefined) return []
        return multiple ? (Array.isArray(modelValue) ? modelValue : [modelValue])
                        : [modelValue]
    }
    readonly property string _displayText: {
        if (displayValue !== "") return displayValue
        var out = []
        var vals = _selectedValues
        for (var i = 0; i < _normalized.length; i++)
            for (var j = 0; j < vals.length; j++)
                if (_optEq(_normalized[i], vals[j])) { out.push(_normalized[i].label); break }
        if (out.length === 0 && useInput && filterText !== "") return filterText
        return out.join(", ")
    }

    function _optEq(opt, v) {
        if (emitValue) return opt.value === v
        return opt.src === v || opt.value === v
    }

    // 校验取值接线：以展示文案为校验面（required 判空）
    value: _displayText
    readonly property string filterText: useInput ? filterInput.text : ""

    // ── 交互 ──────────────────────────────────────────────────
    function _pick(opt) {
        if (opt.disable || disable || readonly) return false
        if (multiple) {
            var vals = _selectedValues.slice()
            var idx = -1
            for (var i = 0; i < vals.length; i++)
                if (_optEq(opt, vals[i])) { idx = i; break }
            if (idx > -1) vals.splice(idx, 1)
            else if (maxValues > 0 && vals.length >= maxValues) return false
            else vals.push(emitValue ? opt.value : opt.src)
            root.modelValue = vals
        } else {
            var v = emitValue ? opt.value : opt.src
            root.modelValue = v
            popup.close()
        }
        popupListView.currentIndex = -1
        return true
    }

    function _setValueByLabel(label) {
        for (var i = 0; i < _normalized.length; i++)
            if (_normalized[i].label === label) return _pick(_normalized[i])
        return false
    }

    // Nova 增强：编程式选值（测试与宿主便捷通道）
    function selectOption(value) {
        for (var i = 0; i < _normalized.length; i++)
            if (_normalized[i].value === value) return _pick(_normalized[i])
        return false
    }

    function showPopup() {
        if (!disable && !readonly) popup.open()
    }
    function hidePopup() { popup.close() }

    // ── 展示层 ────────────────────────────────────────────────
    // 选中值 / 过滤输入
    Text {
        visible: !(root.useInput && popup.opened) && root._displayText !== ""
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        text: root._displayText
        color: NovaTheme.textColor
        font.family: NovaTheme.fontFamily
        font.pixelSize: root.dense ? 12 : 14
        elide: Text.ElideRight
    }
    // useInput 键入过滤
    TextInput {
        id: filterInput
        visible: root.useInput
        enabled: !root.disable && !root.readonly
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        color: NovaTheme.textColor
        font.family: NovaTheme.fontFamily
        font.pixelSize: root.dense ? 12 : 14
        activeFocusOnTab: false
        Keys.onReturnPressed: {
            if (!root._setValueByLabel(text) && text !== "") root.newValue(text)
        }
    }

    // 下拉箭头（右端；点击开合）
    Item {
        width: 20; height: parent.height
        x: parent.width - width
        visible: !root.hideDropdownIcon
        Text {
            anchors.centerIn: parent
            text: root.dropdownIcon.indexOf("mdi:") === 0 ? "▾" : root.dropdownIcon
            color: root.disable ? NovaTheme.textMuted
                 : root.controlFocused ? root.tint : NovaTheme.textMuted
            font.pixelSize: root.dense ? 12 : 14
            rotation: popup.opened ? 180 : 0
            Behavior on rotation { NumberAnimation { duration: 150 } }
        }
        MouseArea {
            anchors.fill: parent
            enabled: !root.disable && !root.readonly
            cursorShape: Qt.PointingHandCursor
            onClicked: popup.opened ? popup.close() : popup.open()
        }
    }

    // 整体点击开合（控件区空白处）
    MouseArea {
        anchors.fill: parent
        enabled: !root.disable && !root.readonly
        cursorShape: Qt.PointingHandCursor
        onClicked: popup.opened ? popup.close() : popup.open()
    }

    // ── 弹层（对标 QSelect menu 模式） ─────────────────────────
    Popup {
        id: popup
        y: root.optionsCover ? -height - 4 : root.height + 4
        width: Math.max(root.width, popupListView.contentItem.implicitWidth + 16)
        height: Math.min(240, popupListView.contentHeight + 12)
        padding: 4
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: NovaTheme.surface
            radius: NovaTheme.radiusM
            border.width: 1
            border.color: NovaTheme.outline
        }

        onOpened: { root.popupShow(); root.controlFocused = true }
        onClosed: { root.popupHide(); root.controlFocused = false }

        contentItem: ListView {
            id: popupListView
            implicitWidth: contentWidth
            clip: true
            model: {
                var list = root._normalized
                if (root.useInput && root.filterText !== "") {
                    var f = root.filterText.toLowerCase()
                    var out = []
                    for (var i = 0; i < list.length; i++)
                        if (list[i].label.toLowerCase().indexOf(f) > -1) out.push(list[i])
                    return out
                }
                return list
            }
            delegate: ItemDelegate {
                id: optDelegate
                required property int index
                required property var modelData
                width: popupListView.width
                height: root.optionsDense ? 26 : 34
                highlighted: {
                    var vals = root._selectedValues
                    for (var i = 0; i < vals.length; i++)
                        if (root._optEq(modelData, vals[i])) return true
                    return false
                }
                opacity: modelData.disable ? 0.45 : 1
                background: Rectangle {
                    color: optDelegate.highlighted
                           ? Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.14) : "transparent"
                    radius: NovaTheme.radiusS
                }
                contentItem: Text {
                    text: optDelegate.modelData.label
                    color: optDelegate.highlighted ? root.tint : NovaTheme.textColor
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: root.optionsDense ? 12 : 13
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: root._pick(optDelegate.modelData)
            }
            // 空选项（对标 no-option-label）
            footer: Item {
                width: popupListView.width
                height: root._normalized.length === 0 ? 30 : 0
                Text {
                    anchors.centerIn: parent
                    visible: root._normalized.length === 0
                    text: root.noOptionLabel !== "" ? root.noOptionLabel : "（无选项）"
                    color: NovaTheme.textMuted
                    font.pixelSize: 12
                }
            }
        }
    }

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
