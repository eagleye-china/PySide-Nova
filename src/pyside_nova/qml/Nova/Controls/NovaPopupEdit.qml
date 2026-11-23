// src/pyside_nova/qml/Nova/Controls/NovaPopupEdit.qml
// NovaPopupEdit 就地编辑弹层：点击目标弹编辑器、autoSave、设置/取消按钮、校验
// 对标 Quasar QPopupEdit（13 props；Nova 收口核心 11 项，cover 覆盖定位留痕见 PARITY）
// 用法：默认内容=目标元素；editorData 挂编辑子件（绑 root.modelValue）；保存调 root.set(v)
//       或 autoSave=true 时编辑器直接改 root.modelValue 即生效
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Behaviors
import Nova.Design

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.Button
    Accessible.name: a11yLabel !== "" ? a11yLabel : title
    Accessible.checkable: true
    Accessible.checked: popup.opened
    Accessible.focusable: !disable
    Accessible.focused: activeFocus
    activeFocusOnTab: !disable
    enabled: !disable
    Keys.onReturnPressed: root.show()
    Keys.onEnterPressed: root.show()
    Keys.onSpacePressed: root.show()
    Keys.onEscapePressed: root.hide()

    // ── 值（对标 QPopupEdit） ──────────────────────────────────
    property var modelValue: null
    property bool autoSave: false            // true=无按钮（编辑即值，close 即提交）
    property bool buttons: true              // 显示 设置/取消 按钮
    property string title: ""
    property string labelSet: "设置"
    property string labelCancel: "取消"
    property color tint: NovaTheme.primary   // 对标 color
    property bool cover: false               // 对标 cover（Nova 简化：向上弹）

    // ── 状态 ───────────────────────────────────────────────────
    property bool disable: false
    property bool readonly: false

    signal valueChanged(var value)           // 对标 update:model-value（save 时发出）
    signal beforeShow()                      // 对标 @before-show
    signal shown()                           // 对标 @show（避开 Item 内建撞名，坑位留痕）
    signal beforeHide()
    signal hidden()                          // 对标 @hide
    signal canceled()                        // 对标 @cancel

    // ── 槽位 ───────────────────────────────────────────────────
    default property alias content: targetHost.data   // 目标元素
    property alias editorData: editorHost.data        // 编辑器子件

    // ── 值管道（写回由本组件承担——弹层是值的所有者语义） ────────
    function set(v) {
        root.modelValue = v
        root.valueChanged(v)
        popup.close()
    }
    function cancel() {
        root.canceled()
        popup.close()
    }
    function show() {
        if (!disable && !readonly) popup.open()
    }
    function hide() { popup.close() }

    implicitWidth: targetHost.implicitWidth > 0 ? targetHost.implicitWidth : 120
    implicitHeight: targetHost.implicitHeight > 0 ? targetHost.implicitHeight : 32

    Item {
        id: targetHost
        anchors.fill: parent
    }

    // 点击目标弹层
    MouseArea {
        anchors.fill: parent
        enabled: !root.disable && !root.readonly
        cursorShape: Qt.PointingHandCursor
        onClicked: root.show()
    }

    Popup {
        id: popup
        x: 0
        y: root.cover ? -height + root.height : root.height + 4
        width: Math.max(root.width, editorHost.implicitWidth + 24)
        height: editorColumn.implicitHeight + 20
        padding: 10
        modal: true
        dim: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: NovaTheme.surface
            radius: NovaTheme.radiusM
            border.width: 1
            border.color: NovaTheme.outline
        }

        onOpened: { root.beforeShow(); root.shown() }
        onClosed: root.beforeHide()

        contentItem: Column {
            id: editorColumn
            spacing: 10
            Text {
                visible: root.title !== ""
                text: root.title
                color: NovaTheme.textColor
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
            Item {
                id: editorHost
                width: popup.width - 20
                height: childrenRect.height
            }
            Row {
                visible: root.buttons && !root.autoSave
                spacing: 8
                layoutDirection: Qt.RightToLeft
                anchors.right: parent.right
                NovaBtn {
                    text: root.labelCancel
                    variant: "flat"
                    onClicked: root.cancel()
                }
                NovaBtn {
                    text: root.labelSet
                    variant: "filled"
                    tint: root.tint
                    onClicked: {
                        // autoSave=false 时由编辑器在输入过程中已写 modelValue（autoSave 语义收敛），
                        // 这里统一走 set() 提交并关闭
                        root.set(root.modelValue)
                    }
                }
            }
        }
    }

    // 弹层关闭即 hidden（autoSave 语义：值已在编辑过程中生效）
    onVisibleChanged: if (!visible) root.hidden()

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
