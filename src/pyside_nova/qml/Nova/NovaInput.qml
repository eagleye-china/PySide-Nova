// src/pyside_nova/qml/Nova/NovaInput.qml

import QtQuick
import QtQuick.Controls.Basic

/**
 * @created 2026-11-13 17:35:58
 * @updated 2026-11-13 20:20:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    // ── 属性契约 ──
    property alias text: input.text
    property bool readOnly: false
    property alias echoMode: input.echoMode
    property alias maximumLength: input.maximumLength
    property alias validator: input.validator
    property string size: "md"

    // ── 状态追踪 ──
    readonly property bool _interactive: root.enabled && !root.readOnly
    readonly property bool _focused: input.activeFocus && root.enabled
    readonly property bool _hovered: hoverArea.containsMouse && !_focused && _interactive

    implicitWidth: Units.px(240)
    implicitHeight: Units.px(Theme.buttonHeight(size))
    radius: Theme.radiusSm
    color: Theme.surface

    // ✅ 宪法合规：抽离独立的边框色属性
    property color _borderColor: {
        if (!_interactive) return Theme.disabled;
        if (_focused) return Theme.primary;
        if (_hovered) return Theme.borderHover || Theme.primary;
        return Theme.border;
    }

    // ✅ 宪法合规：对单一颜色属性使用 Behavior
    Behavior on _borderColor {
        ColorAnimation {
            duration: Theme.durationFast
        }
    }

    // 边框设置：只对颜色动画，宽度瞬间变化，防止内部文字抖动
    border.width: _focused ? Units.px(2) : Units.px(1)
    border.color: _borderColor

    // ── 占位符 ──
    Text {
        id: placeholder
        anchors.fill: parent
        anchors.leftMargin: Units.px(Theme.spaceSm)
        anchors.rightMargin: Units.px(Theme.spaceSm)
        verticalAlignment: Text.AlignVCenter
        text: "请输入内容..." // 外部绑定的占位符
        color: Theme.text_secondary
        font.pixelSize: Units.px(Theme.fontSizeFor(root.size))
        elide: Text.ElideRight
        visible: input.length === 0
    }

    // ── 原生输入引擎 ──
    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: Units.px(Theme.spaceSm)
        anchors.rightMargin: Units.px(Theme.spaceSm)
        verticalAlignment: TextInput.AlignVCenter
        color: root._interactive ? Theme.text_primary : Theme.text_secondary
        selectionColor: Theme.primary
        selectedTextColor: Theme.white
        font.pixelSize: Units.px(Theme.fontSizeFor(root.size))
        selectByMouse: true
        clip: true
        readOnly: root.readOnly

        // ✅ 只读状态下不显示光标
        cursorVisible: root._interactive ? activeFocus : false
    }

    // ── 交互区 ──
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // 只用来追踪 Hover，不阻挡点击
        cursorShape: root._interactive ? Qt.IBeamCursor : Qt.ArrowCursor
    }

    MouseArea {
        anchors.fill: parent
        enabled: root._interactive
        onClicked: input.forceActiveFocus()
    }

    // ── 无障碍与键盘 ──
    activeFocusOnTab: root._interactive
    Accessible.role: Accessible.EditableText
    Accessible.name: placeholder.text
    Accessible.focusable: root._interactive
}