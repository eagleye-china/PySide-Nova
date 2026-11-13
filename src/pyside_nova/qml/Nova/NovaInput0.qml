// src/pyside_nova/qml/Nova/NovaInput.qml

import QtQuick
import QtQuick.Layouts

/**
 * NovaInput —— 对标 Quasar QInput 的企业级输入框
 *
 * @created 2026-11-12 23:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    // ── 属性契约
    property alias text: input.text
    property alias placeholderText: inputPlaceholder.text
    property bool readOnly: false
    property alias echoMode: input.echoMode
    property string size: "md"

    // ✅ 核心修复：将边框颜色抽离为自定义属性
    property color borderColor: input.activeFocus ? Theme.primary : Theme.border

    // ✅ 核心修复：将 Behavior 直接作用于自定义的单属性上（完全符合架构宪法）
    Behavior on borderColor {
        ColorAnimation {
            duration: Theme.durationFast
        }
    }

    // ── 尺寸与主题
    implicitWidth: Units.px(240)
    implicitHeight: Units.px(Theme.buttonHeight(size))
    radius: Theme.radiusSm
    color: Theme.surface
    border.width: 1
    // 绑定到已经带有平滑动画的属性
    border.color: root.borderColor

    // 内容层（不再需要垫底的 borderAnimator，减少了渲染层级）
    Item {
        anchors.fill: parent
        anchors.margins: Units.px(Theme.spaceSm)

        // 原生输入引擎
        TextInput {
            id: input
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.text_primary
            font.pixelSize: Units.px(Theme.fontSizeFor(root.size))
            selectByMouse: true
            clip: true
            readOnly: root.readOnly
            // ✅ 修复抢焦点：移除了 focus: true，仅保留点击获取焦点
            activeFocusOnPress: true
        }

        // 占位符（当 TextInput 没有文字时显示）
        Text {
            id: inputPlaceholder
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            color: Theme.text_secondary
            font.pixelSize: Units.px(Theme.fontSizeFor(root.size))
            visible: input.text.length === 0
            elide: Text.ElideRight
        }
    }
}