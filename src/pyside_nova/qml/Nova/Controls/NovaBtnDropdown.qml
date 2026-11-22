// src/pyside_nova/qml/Nova/Controls/NovaBtnDropdown.qml
// NovaBtnDropdown 下拉按钮：NovaBtn 主钮 + 内嵌 NovaMenu、split 分体、cover/persistent/auto-close（对标 QBtnDropdown）
// 受控契约：modelValue（菜单开合，坑位 22）
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    default property alias content: menuHost.data

    // ── 按钮形态 ──────────────────────────────────────────────
    property string label: ""
    property string icon: ""
    property string iconRight: ""
    property string variant: "filled"            // filled | outline | flat（NovaBtn 口径）
    property color tint: NovaTheme.primary
    property string size: "md"
    property bool disable: false
    property bool split: false                   // 下拉图标独立按钮
    property bool disableMainBtn: false
    property bool disableDropdown: false
    property string dropdownIcon: "mdi:menu-down"
    property bool noIconAnimation: false

    // ── 菜单形态（转发 NovaMenu） ─────────────────────────────
    property bool persistent: false
    property bool autoClose: false
    property bool cover: false
    property bool fit: false

    // ── 受控契约 ──────────────────────────────────────────────
    property bool modelValue: false
    signal updateModelValue(bool v)
    signal click()                               // 主钮点击（split 时仅左钮）
    signal beforeShow()
    signal shown()
    signal beforeHide()
    signal hidden()

    readonly property bool _open: modelValue
    implicitWidth: btnRow.implicitWidth
    implicitHeight: btnRow.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Row {
        id: btnRow
        spacing: 2

        NovaBtn {
            id: mainBtn
            text: root.label
            icon: root.icon
            iconRight: root.split ? root.iconRight : root.dropdownIcon
            variant: root.variant
            tint: root.tint
            size: root.size
            disable: root.disable || root.disableMainBtn
            onClicked: {
                if (root.split) {
                    root.click()
                } else {
                    if (!root.disableDropdown)
                        root.toggle()
                    root.click()
                }
            }
        }

        NovaBtn {
            visible: root.split
            icon: root.dropdownIcon
            variant: root.variant === "filled" ? "outline" : root.variant
            tint: root.tint
            size: root.size
            disable: root.disable || root.disableDropdown
            onClicked: root.toggle()
        }
    }

    // ── 内嵌菜单（就地渲染于按钮下方） ────────────────────────
    NovaMenu {
        id: menuHost
        target: btnRow
        anchor: "bottom left"
        self: "top left"
        persistent: root.persistent
        autoClose: root.autoClose
        cover: root.cover
        fit: root.fit
        modelValue: root._open && !root.disable && !root.disableDropdown
        onUpdateModelValue: (v) => root.updateModelValue(v)
        z: root.z + 10
    }

    Connections {
        target: menuHost
        function onShown() { root.beforeShow(); root.shown() }
        function onHidden() { root.beforeHide(); root.hidden() }
    }

    // ── 方法（对标 show/hide/toggle） ─────────────────────────
    function show() { if (!_open) updateModelValue(true) }
    function hide() { if (_open) updateModelValue(false) }
    function toggle() { _open ? hide() : show() }
}
