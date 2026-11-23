// src/pyside_nova/qml/Nova/Controls/NovaRadio.qml
// NovaRadio 单选：val 匹配 modelValue、leftLabel、keepColor、键盘选择
// 对标 Quasar QRadio（12 props）
// 契约统一：label / hint / error / readonly / disable
import QtQuick
import Nova.Services
import Nova.Behaviors
import Nova.Design

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.RadioButton
    Accessible.name: a11yLabel !== "" ? a11yLabel : label
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.focusable: !disable
    Accessible.focused: activeFocus
    enabled: !disable

    default property alias content: contentHost.data

    // ── 值语义（对标 QRadio） ──────────────────────────────────
    property var modelValue: null
    property var val: null
    readonly property bool checked: modelValue === val && val !== null

    // ── 内容与外观 ────────────────────────────────────────────
    property string label: ""
    property bool leftLabel: false
    property string checkedIcon: ""          // 对标 checked-icon（空=内置绘制圆点）
    property string uncheckedIcon: ""
    property color tint: NovaTheme.primary
    property bool keepColor: false
    property bool dense: false
    property bool disable: false
    property bool readonly: false
    property bool activeTab: !disable
    property string hint: ""                 // 契约统一
    property bool error: false
    property string errorMessage: ""

    readonly property bool hasError: error || errorMessage !== ""
    readonly property real _size: dense ? 16 : 18
    readonly property int _fs: dense ? 12 : 14

    signal valueChanged(var value)           // 对标 update:model-value（宿主负责写回，对标 v-model）
    signal selected()

    // Quasar 语义 1:1：组件只发信号不写自身 modelValue；宿主绑定 + onValueChanged 写回共享状态
    function select() {
        if (disable || readonly || checked) return val
        root.valueChanged(root.val)
        root.selected()
        return root.val
    }

    // ── 布局 ──────────────────────────────────────────────────
    implicitWidth: row.implicitWidth
    implicitHeight: Math.max(_size, _fs + 6) + ((hint !== "" && !hasError) || hasError ? 16 : 0)

    Row {
        id: row
        anchors { left: parent.left; top: parent.top }
        spacing: 8

        Text {
            visible: root.leftLabel && root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: NovaTheme.textColor
            font.family: NovaTheme.fontFamily
            font.pixelSize: root._fs
        }

        Item {
            width: root._size; height: root._size
            anchors.verticalCenter: parent.verticalCenter
            opacity: root.disable ? 0.5 : 1

            Rectangle {
                id: ring
                anchors.centerIn: parent
                width: root._size; height: root._size; radius: root._size / 2
                color: "transparent"
                border.width: 2
                border.color: root.hasError ? NovaTheme.negative
                            : (root.checked || root.keepColor) ? root.tint : NovaTheme.outline
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }
            Rectangle {
                anchors.centerIn: parent
                width: root._size / 2 - 1; height: width; radius: width / 2
                visible: root.checked
                color: root.hasError ? NovaTheme.negative : root.tint
                scale: root.checked ? 1 : 0
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }
            }
            // 对标 checked-icon / unchecked-icon（显式指定时以图标渲染）
            NovaIcon {
                anchors.centerIn: parent
                visible: root.checked && root.checkedIcon !== ""
                icon: root.checkedIcon; size: root._size
                color: root.hasError ? NovaTheme.negative : root.tint
            }
            NovaIcon {
                anchors.centerIn: parent
                visible: !root.checked && root.uncheckedIcon !== ""
                icon: root.uncheckedIcon; size: root._size
                color: root.keepColor ? root.tint : NovaTheme.outline
            }
        }

        Text {
            visible: !root.leftLabel && root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.disable ? NovaTheme.textMuted : NovaTheme.textColor
            font.family: NovaTheme.fontFamily
            font.pixelSize: root._fs
        }

        Item { id: contentHost; width: 0; height: root._size }
    }

    Text {
        visible: root.hint !== "" && !root.hasError
        x: 0; y: row.height + 2
        text: root.hint
        color: NovaTheme.textMuted
        font.family: NovaTheme.fontFamily
        font.pixelSize: 11
    }
    Text {
        visible: root.hasError
        x: 0; y: row.height + 2
        text: root.errorMessage !== "" ? root.errorMessage : "校验未通过"
        color: NovaTheme.negative
        font.family: NovaTheme.fontFamily
        font.pixelSize: 11
    }

    MouseArea {
        anchors.fill: row
        enabled: !root.disable && !root.readonly
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.select()
    }

    Keys.onSpacePressed: root.select()
    Keys.onReturnPressed: root.select()
    Keys.onEnterPressed: root.select()
    activeFocusOnTab: root.activeTab

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
