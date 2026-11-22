// src/pyside_nova/qml/Nova/Controls/NovaCheckbox.qml
// NovaCheckbox 复选：true/false/indeterminate 三态、toggleOrder、val 模式、leftLabel、键盘切换
// 对标 Quasar QCheckbox（use-checkbox 18 props）；visual 插槽供 NovaToggle 换装开关外观
// 契约统一：label / hint / error / readonly / disable（clearable/rules 不适用已留痕）
import QtQuick
import Nova.Services

Item {
    id: root

    default property alias content: contentHost.data

    // ── 值语义（对标 use-checkbox） ────────────────────────────
    property var modelValue: null
    property var val: null                   // 非 null：checked = modelValue === val
    property var trueValue: true             // 对标 true-value
    property var falseValue: false           // 对标 false-value
    property var indeterminateValue: null    // 对标 indeterminate-value
    property bool toggleIndeterminate: false // 对标 toggle-indeterminate（把半选入循环）
    property int toggleOrder: 0              // 0=true→false；1=false→true（半选居间）
    readonly property bool checked: _valMode ? modelValue === val
                                     : modelValue === trueValue
    readonly property bool indeterminate: !_valMode && indeterminateValue !== null
                                          && modelValue === indeterminateValue

    // ── 内容与外观 ────────────────────────────────────────────
    property string label: ""
    property bool leftLabel: false
    property string checkedIcon: ""          // 对标 checked-icon（空=内置绘制勾）
    property string uncheckedIcon: ""
    property string indeterminateIcon: ""
    property color tint: NovaTheme.primary   // 对标 color
    property bool keepColor: false           // 对标 keep-color（未选中仍着色）
    property bool dense: false
    property bool disable: false
    property bool readonly: false
    property bool activeTab: !disable        // 对标 tabindex（QML 化：是否入 Tab 链）
    property string hint: ""                 // 契约统一
    property bool error: false
    property string errorMessage: ""

    readonly property bool hasError: error || errorMessage !== ""
    readonly property real _boxSize: dense ? 16 : 18
    readonly property int _fs: dense ? 12 : 14
    // visual 插槽宿主宽度（NovaToggle 换装为开关轨道宽度）
    property real visualWidth: _boxSize

    signal valueChanged(var value)           // 对标 update:model-value
    signal toggled(bool checked)

    // visual 插槽：NovaToggle 覆盖为开关外观（默认：勾选框绘制）
    property Component visual: Component {
        Item {
            readonly property bool chk: root.checked
            readonly property bool ind: root.indeterminate
            Rectangle {
                id: box
                anchors.centerIn: parent
                width: root._boxSize; height: root._boxSize
                radius: 3
                color: root._fgBox
                border.width: 2
                border.color: root._borderBox
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }
            Canvas {
                id: mark
                anchors.centerIn: parent
                width: root._boxSize - 8; height: root._boxSize - 8
                visible: chk || ind
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = root.checked || root.indeterminate
                        ? NovaTheme.textOnPrimary : "transparent"
                    ctx.lineWidth = 2
                    ctx.lineCap = "round"
                    if (root.indeterminate) {
                        ctx.beginPath()
                        ctx.moveTo(2, height / 2); ctx.lineTo(width - 2, height / 2)
                        ctx.stroke()
                    } else {
                        ctx.beginPath()
                        ctx.moveTo(2, height / 2); ctx.lineTo(width * 0.38, height - 2)
                        ctx.lineTo(width - 1, 2)
                        ctx.stroke()
                    }
                }
                onVisibleChanged: requestPaint()
                Connections {
                    target: root
                    function onModelValueChanged() { mark.requestPaint() }
                }
            }
            // 对标 checked-icon/unchecked-icon/indeterminate-icon（显式指定时以图标渲染）
            NovaIcon {
                anchors.centerIn: parent
                visible: root.checked && root.checkedIcon !== ""
                icon: root.checkedIcon; size: root._boxSize
                color: NovaTheme.textOnPrimary
            }
            NovaIcon {
                anchors.centerIn: parent
                visible: !root.checked && !root.indeterminate && root.uncheckedIcon !== ""
                icon: root.uncheckedIcon; size: root._boxSize
                color: root._borderBox
            }
            NovaIcon {
                anchors.centerIn: parent
                visible: root.indeterminate && root.indeterminateIcon !== ""
                icon: root.indeterminateIcon; size: root._boxSize
                color: NovaTheme.textOnPrimary
            }
        }
    }

    // 内部配色（对标 keep-color 语义）
    readonly property color _borderBox: {
        if (root.hasError) return NovaTheme.negative
        if (root.checked || root.indeterminate || root.keepColor) return root.tint
        return NovaTheme.outline
    }
    readonly property color _fgBox: (root.checked || root.indeterminate) && !root.readonly
        ? (root.hasError ? NovaTheme.negative : root.tint) : "transparent"

    // ── 值切换（对标 use-checkbox toggle 语义） ─────────────────
    // 半选循环（toggleIndeterminate 时把半选入链）：order 0 = t→f→i→t；order 1 = f→t→i→f
    // Quasar 语义 1:1：只发信号不写自身 modelValue；宿主绑定 + onValueChanged 写回共享状态
    function toggle() {
        if (disable || readonly) return _onVal()
        var next
        if (indeterminate) {
            next = toggleOrder === 1 ? _offVal() : _onVal()
        } else if (checked) {
            next = (toggleIndeterminate && _hasInd && toggleOrder === 1)
                ? indeterminateValue : _offVal()
        } else {
            next = (toggleIndeterminate && _hasInd && toggleOrder === 0)
                ? indeterminateValue : _onVal()
        }
        root.valueChanged(next)
        root.toggled(next === _onVal())
        return next
    }

    function _onVal() { return _valMode ? val : trueValue }
    function _offVal() { return falseValue }
    readonly property bool _valMode: val !== null && val !== undefined
    readonly property bool _hasInd: indeterminateValue !== null && !_valMode

    // ── 布局 ──────────────────────────────────────────────────
    implicitWidth: row.implicitWidth
    implicitHeight: Math.max(_boxSize, _fs + 6)
                    + ((hint !== "" || hasError) && hint !== "" ? 16 : 0)

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

        Loader {
            id: visualLoader
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: root.visual
            width: root.visualWidth
            height: root._boxSize
            opacity: root.disable ? 0.5 : 1
        }

        Text {
            visible: !root.leftLabel && root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.disable ? NovaTheme.textMuted : NovaTheme.textColor
            font.family: NovaTheme.fontFamily
            font.pixelSize: root._fs
        }

        Item { id: contentHost; width: 0; height: root._boxSize }
    }

    Text {
        visible: hint !== "" && !hasError
        x: 0
        y: row.height + 2
        text: hint
        color: NovaTheme.textMuted
        font.family: NovaTheme.fontFamily
        font.pixelSize: 11
    }
    Text {
        visible: hasError
        x: 0
        y: row.height + 2
        text: errorMessage !== "" ? errorMessage : "校验未通过"
        color: NovaTheme.negative
        font.family: NovaTheme.fontFamily
        font.pixelSize: 11
    }

    MouseArea {
        anchors.fill: row
        enabled: !root.disable && !root.readonly
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.toggle()
    }

    Keys.onSpacePressed: root.toggle()
    Keys.onReturnPressed: root.toggle()
    Keys.onEnterPressed: root.toggle()
    activeFocusOnTab: root.activeTab
}
