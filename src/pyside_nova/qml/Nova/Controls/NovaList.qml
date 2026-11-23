// src/pyside_nova/qml/Nova/Controls/NovaList.qml
// NovaList 列表容器（对标 QList）：separator/dense/padding、accordion 手风琴协调
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.List
    Accessible.name: a11yLabel

    default property alias content: body.data

    property bool separator: false          // 子项之间画分隔线（由 NovaItem 消费）
    property bool dense: false              // 紧凑行高（由 NovaItem 消费）
    property bool padding: false
    property bool accordion: false          // 手风琴：子 NovaItem 展开时收起兄弟

    implicitWidth: 320
    implicitHeight: body.implicitHeight + (padding ? NovaTheme.spacingM * 2 : 0)

    Column {
        id: body
        x: root.padding ? NovaTheme.spacingM : 0
        y: root.padding ? NovaTheme.spacingM : 0
        width: parent.width - (root.padding ? NovaTheme.spacingM * 2 : 0)
        spacing: 0
        onChildrenChanged: root._bindChildren()
        Component.onCompleted: root._bindChildren()
    }

    // 手风琴协调：任一 NovaItem 展开时收起其它兄弟（受控：emit 给宿主，宿主写回）
    function collapseSiblings(item) {
        for (var i = 0; i < body.children.length; i++) {
            var c = body.children[i]
            if (c !== item && c.expandRequested !== undefined && c.expanded)
                c.expandRequested(false)
        }
    }

    // 给子 NovaItem 挂上列表引用（分隔线/dense/手风琴经此下发）
    function _bindChildren() {
        for (var i = 0; i < body.children.length; i++) {
            var c = body.children[i]
            if (c.listRef !== undefined)
                c.listRef = root
        }
    }

    // 是否最后一个 NovaItem（跳过 Timer 等非可见资源子项）
    function isLastItem(item) {
        for (var i = body.children.length - 1; i >= 0; i--) {
            var c = body.children[i]
            if (c.listRef !== undefined)
                return c === item
        }
        return false
    }
}
