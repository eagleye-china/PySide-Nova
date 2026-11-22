// src/pyside_nova/qml/Nova/Controls/NovaBottomSheet.qml
// NovaBottomSheet 底部动作面板：actions 数组（列表/网格）+ default 槽、遮罩、ESC/背景点击关闭、
// 关闭原因上报（backdrop/escape/api，对标 BottomSheet 插件 · 基线 2.28 语义）
// 声明式壳口径：就地渲染（anchors.fill 父级）；modelValue 受控（坑位 22）
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    default property alias content: customBody.data

    // ── 动作（对标 BottomSheet 插件 actions 数组；default 槽优先） ──
    property var actions: []                     // [{ label, icon, disable? }]
    property bool grid: false                    // true = 网格布局（3 列）
    property color tint: NovaTheme.surface

    // ── 受控契约 ──────────────────────────────────────────────
    property bool modelValue: false
    signal updateModelValue(bool v)

    // ── 事件（关闭原因上报） ──────────────────────────────────
    signal actionPicked(int index)               // 点击动作（随后 dismissed("ok")）
    signal dismissed(string reason)              // backdrop | escape | api | ok
    signal beforeShow()
    signal shown()
    signal beforeHide()
    signal hidden()
    signal escapeKey()

    readonly property bool _open: modelValue
    readonly property int _cols: 3
    readonly property real _itemH: 52

    implicitWidth: 400
    implicitHeight: 300
    visible: modelValue

    onVisibleChanged: {
        if (visible) {
            beforeShow()
            forceActiveFocus()
            NovaOverlayHost.registerPopup(root, function(reason) { requestDismiss("api") })
            shown()
        } else {
            beforeHide()
            NovaOverlayHost.unregisterPopup(root)
            hidden()
        }
    }

    Keys.onEscapePressed: {
        escapeKey()
        requestDismiss("escape")
    }

    // ── 遮罩 ──────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.visible ? 0.5 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }
        MouseArea { anchors.fill: parent; onClicked: root.requestDismiss("backdrop") }
    }

    // ── 底部卡片（滑入动效） ──────────────────────────────────
    Rectangle {
        id: sheet
        width: root.width
        height: root._useActions ? contentCol.implicitHeight + 2 * NovaTheme.spacingM
                                 : Math.max(80, customBody.childrenRect.height + 2 * NovaTheme.spacingM)
        x: 0
        y: root.visible ? root.height - height : root.height
        Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

        radius: NovaTheme.radiusL
        color: root.tint
        border.width: 1
        border.color: NovaTheme.outline

        readonly property bool _useActions: root.actions.length > 0 && customBody.children.length === 0

        Column {
            id: contentCol
            x: NovaTheme.spacingM
            y: NovaTheme.spacingM
            width: Math.max(0, sheet.width - 2 * NovaTheme.spacingM)
            spacing: 2

            // 列表布局
            Repeater {
                model: root.grid ? [] : root.actions
                delegate: NovaItem {
                    required property int index
                    readonly property var act: root.actions[index]
                    width: contentCol.width
                    clickable: act.disable !== true
                    label: act.label !== undefined ? String(act.label) : ""
                    icon: act.icon !== undefined ? String(act.icon) : ""
                    disable: act.disable === true
                    opacity: act.disable === true ? 0.4 : 1
                    onClicked: root._pick(index)
                }
            }

            // 网格布局（3 列，图标+文案竖排）
            Flow {
                visible: root.grid && root.actions.length > 0
                width: parent.width
                spacing: 4
                Repeater {
                    model: root.grid ? root.actions : []
                    delegate: Rectangle {
                        required property int index
                        readonly property var act: root.actions[index]
                        width: (contentCol.width - 8) / root._cols
                        height: 88
                        radius: NovaTheme.radiusS
                        color: ma.containsMouse ? NovaTheme.surfaceAlt : "transparent"
                        opacity: act.disable === true ? 0.4 : 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 6
                            NovaIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                icon: act.icon !== undefined ? String(act.icon) : ""
                                size: 24
                                color: NovaTheme.textColor
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: act.label !== undefined ? String(act.label) : ""
                                color: NovaTheme.textColor
                                font.pixelSize: NovaTheme.fontS
                            }
                        }
                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: act.disable !== true
                            onClicked: root._pick(index)
                        }
                    }
                }
            }

            // default 槽（actions 为空时渲染）
            Item {
                id: customBody
                visible: root.actions.length === 0
                width: parent.width
                height: childrenRect.height
            }
        }
    }

    function _pick(index) {
        actionPicked(index)
        requestDismiss("ok")
    }

    // ── 关闭路径 ──────────────────────────────────────────────
    function requestDismiss(reason) {
        if (!visible) return
        var r = reason === undefined ? "api" : reason
        dismissed(r)
        updateModelValue(false)
    }

    function show() { if (!_open) updateModelValue(true) }
    function hide() { if (_open) updateModelValue(false) }
    function toggle() { _open ? hide() : show() }
}
