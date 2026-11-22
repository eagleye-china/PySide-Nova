// src/pyside_nova/qml/Nova/Controls/NovaBtnGroup.qml
// NovaBtnGroup 按钮组样式壳：spread/vertical、outline/flat/push 形态统一下发（对标 QBtnGroup）
// 子项为 NovaBtn；组内间距归零（并接）；vertical 切换时槽内容 reparent 到对应布局容器
import QtQuick
import Nova.Services

Rectangle {
    id: root

    default property alias content: holder.data

    // ── 形态 ──────────────────────────────────────────────────
    property bool vertical: false
    property bool spread: false                  // 撑满可用空间
    property bool outline: false
    property bool flat: false
    property bool push: false

    color: "transparent"
    radius: NovaTheme.radiusS
    border.width: outline ? 1 : 0
    border.color: NovaTheme.outline

    implicitWidth: vertical ? groupCol.implicitWidth : groupRow.implicitWidth
    implicitHeight: vertical ? groupCol.implicitHeight : groupRow.implicitHeight
    width: spread && !vertical && parent ? parent.width : implicitWidth
    height: spread && vertical && parent ? parent.height : implicitHeight

    readonly property real _gap: 1

    // ── 样式下发（坑位 28 口径：形态变化显式失效） ─────────────
    function _applyStyle() {
        for (var i = 0; i < holder.children.length; i++) {
            var c = holder.children[i]
            if (c.variant === undefined) continue
            if (push) c.variant = "flat"
            else if (outline) c.variant = "outline"
            else if (flat) c.variant = "flat"
        }
        _layout()
    }
    onOutlineChanged: _applyStyle()
    onFlatChanged: _applyStyle()
    onPushChanged: _applyStyle()
    onVerticalChanged: _layout()
    Component.onCompleted: { Qt.callLater(_applyStyle); Qt.callLater(_layout) }

    // ── 布局容器（双形态） ────────────────────────────────────
    Column {
        id: groupCol
        visible: root.vertical
        spacing: root._gap
        width: root.spread && root.vertical ? root.width : implicitWidth
    }

    Row {
        id: groupRow
        visible: !root.vertical
        spacing: root._gap
        height: root.spread && !root.vertical ? root.height : implicitHeight
    }

    function _layout() {
        var dest = root.vertical ? groupCol : groupRow
        for (var i = 0; i < holder.children.length; i++) {
            var c = holder.children[i]
            if (c.parent !== dest)
                c.parent = dest
            if (root.spread) {
                if (root.vertical) c.width = root.width
                else c.height = root.height
            }
        }
    }

    // ── 声明内容暂存宿主（不可见；_layout 时迁入布局容器） ─────
    Item {
        id: holder
        visible: false
        width: 0; height: 0
        onChildrenChanged: Qt.callLater(root._layout)
    }
}
