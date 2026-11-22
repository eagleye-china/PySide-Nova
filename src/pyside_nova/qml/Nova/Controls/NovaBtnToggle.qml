// src/pyside_nova/qml/Nova/Controls/NovaBtnToggle.qml
// NovaBtnToggle 按钮组切换：options 单/多值、clearable、active 着色、spread/vertical
// 对标 Quasar QBtnToggle（31 props；Nova 收口核心 22 项，glossy/stack/stretch 留痕见 PARITY）
// 契约统一：disable / readonly
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 值与选项（对标 QBtnToggle） ─────────────────────────────
    property var modelValue: null            // 标量（multiple 未开）或数组
    property bool multiple: false
    property bool clearable: false           // 再点已选项清除
    property var options: []                 // [{label, value, icon, disable}] 或标量
    property bool noCaps: false              // 对标 no-caps（中文无影响，留 API 面）

    // ── 外观（对标） ───────────────────────────────────────────
    property bool outline: false             // 未选中描边态
    property bool flat: false                // 未选中扁平态
    property bool push: false
    property bool unelevated: false
    property bool rounded: false
    property color tint: NovaTheme.primary   // 对标 color
    property color textColor: NovaTheme.textColor
    property color toggleColor: tint         // 对标 toggle-color（选中底色）
    property color toggleTextColor: NovaTheme.textOnPrimary
    property bool spread: false              // 均分宽度
    property bool vertical: false
    property bool dense: false
    property string size: "md"               // sm | md | lg

    // ── 状态（契约统一） ───────────────────────────────────────
    property bool disable: false
    property bool readonly: false
    property string hint: ""
    property bool error: false
    property string errorMessage: ""
    readonly property bool hasError: error || errorMessage !== ""

    signal valueChanged(var value)           // 对标 update:model-value

    // ── 选项归一化 ─────────────────────────────────────────────
    readonly property var _normalized: {
        var out = []
        var arr = Array.isArray(options) ? options : []
        for (var i = 0; i < arr.length; i++) {
            var o = arr[i]
            if (o === null || o === undefined) continue
            if (typeof o === "object")
                out.push({ label: String(o.label !== undefined ? o.label : o.value),
                           value: o.value, icon: String(o.icon || ""),
                           disable: o.disable === true })
            else out.push({ label: String(o), value: o, icon: "", disable: false })
        }
        return out
    }

    function _isOn(v) {
        return multiple ? (Array.isArray(modelValue) && modelValue.indexOf(v) > -1)
                        : modelValue === v
    }

    // ── 值管道（受控模式：写回由组承担，同 NovaOptionGroup） ─────
    function _pick(opt) {
        if (opt.disable || disable || readonly) return false
        if (multiple) {
            var arr = Array.isArray(modelValue) ? modelValue.slice() : []
            var idx = arr.indexOf(opt.value)
            if (idx > -1) {
                if (!clearable) return false
                arr.splice(idx, 1)
            } else arr.push(opt.value)
            root.modelValue = arr
            root.valueChanged(arr)
        } else {
            if (_isOn(opt.value)) {
                if (!clearable) return false
                root.modelValue = null
                root.valueChanged(null)
                return true
            }
            root.modelValue = opt.value
            root.valueChanged(opt.value)
        }
        return true
    }

    // 编程通道
    function select(value) {
        for (var i = 0; i < _normalized.length; i++)
            if (_normalized[i].value === value) return _pick(_normalized[i])
        return false
    }
    function clear() {
        var empty = multiple ? [] : null
        root.modelValue = empty
        root.valueChanged(empty)
    }

    // ── 布局 ───────────────────────────────────────────────────
    implicitWidth: vertical ? 120 : Math.max(60, _normalized.length * 64)
    implicitHeight: vertical ? _normalized.length * (dense ? 30 : 38)
                             : (dense ? 30 : 38)
                             + ((hint !== "" && !hasError) || hasError ? 16 : 0)

    readonly property string _inactiveVariant: push ? "push"
                                               : (outline ? "outline"
                                               : (flat || unelevated ? "flat" : "filled"))

    // 分组容器（圆角整体感：首尾圆角大、中间小）
    Rectangle {
        id: groupBg
        visible: root._inactiveVariant === "filled" && !root.push
        anchors.fill: btnHost
        radius: root.rounded ? (root.vertical ? 19 : 19) : NovaTheme.radiusS
        color: NovaTheme.outline
        opacity: 0.25
    }

    Column {
        id: btnHost
        visible: root.vertical
        anchors.top: parent.top
        width: parent.width
        spacing: 0
        Repeater { model: root._normalized; delegate: btnDelegate }
    }
    Row {
        id: btnHostH
        visible: !root.vertical
        anchors.top: parent.top
        width: parent.width
        spacing: 0
        Repeater { model: root._normalized; delegate: btnDelegate }
    }

    component OptBtn: Item {
        id: ob
        property var opt: null
        property int optIndex: 0
        readonly property bool on: root._isOn(opt ? opt.value : null)
        height: root.vertical ? (root.dense ? 30 : 38)
                              : (root.dense ? 30 : 38)
                              + ((root.hint !== "" && !root.hasError) || root.hasError ? 0 : 0)
        width: root.spread ? (root.vertical ? ob.parent.width : ob.parent.width / root._normalized.length)
                           : btn.implicitWidth
        NovaBtn {
            id: btn
            width: parent.width
            text: ob.opt.label
            icon: ob.opt.icon
            variant: ob.on ? "filled" : root._inactiveVariant
            tint: ob.on ? root.toggleColor : root.tint
            dense: root.dense
            round: false
            disable: root.disable || ob.opt.disable
            // 选中/未选中文字色：filled 时由按钮自定（textOnPrimary），此处覆盖 via textColor
            Rectangle {
                visible: root._inactiveVariant === "filled" && !root.push && !root.rounded
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: 1
                height: root.dense ? 16 : 22
                color: NovaTheme.surface
                opacity: 0.6
            }
            onClicked: root._pick(ob.opt)
        }
    }
    Component {
        id: btnDelegate
        OptBtn { opt: modelData; optIndex: index }
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
