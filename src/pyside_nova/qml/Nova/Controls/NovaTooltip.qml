// src/pyside_nova/qml/Nova/Controls/NovaTooltip.qml
// NovaTooltip 工具提示：target 悬停（delay/hideDelay）、anchor/self/offset 定位、text 便捷或 default 槽（对标 QTooltip）
// 就地渲染口径：z 提升于声明处（PARITY §0.14 留痕：非 portal，建议声明在页面根层）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.ToolTip
    Accessible.name: a11yLabel !== "" ? a11yLabel : text

    default property alias content: bubbleContent.data

    // ── 内容（default 槽优先，否则用 text 便捷属性） ────────────
    property string text: ""                     // Nova 增强：单行便捷文案
    readonly property bool _useText: text !== "" && bubbleContent.children.length === 0

    // ── 触发 ──────────────────────────────────────────────────
    property var target: null                    // null = 声明父项
    property int delay: 0                        // 显示延迟 ms
    property int hideDelay: 0                    // 消失延迟 ms
    property var offset: [14, 14]                // 对标默认 [14, 14]
    property string anchor: "bottom middle"      // target 锚点
    property string self: "top middle"           // 气泡对齐点

    // ── 形态 ──────────────────────────────────────────────────
    property real maxWidth: 280
    property color tint: isDark ? "#3A3A44" : "#2A2A32"
    property bool isDark: NovaTheme.isDark

    // ── 受控契约（可编程显示；悬停为内建触发） ──────────────────
    property bool modelValue: false
    signal updateModelValue(bool v)
    signal beforeShow()
    signal shown()
    signal beforeHide()
    signal hidden()

    readonly property bool _open: modelValue
    visible: modelValue
    z: 9500

    // target 缺省父项（绑定直读，不写回——坑位 22 邻域）
    readonly property var _tgt: target !== null ? target : parent

    onVisibleChanged: {
        if (visible) { beforeShow(); _place(); shown() }
        else { beforeHide(); hidden() }
    }
    onImplicitWidthChanged: if (visible) _place()

    // ── 悬停触发（target 上挂 HoverHandler + 延迟 Timer） ──────
    HoverHandler {
        enabled: root._tgt !== null
        target: root._tgt
        onHoveredChanged: root.updateHover(isHovered)
    }
    Timer {
        id: tipTimer
        property bool pendingShow: true
        onTriggered: pendingShow ? root.updateModelValue(true) : root.updateModelValue(false)
    }
    function updateHover(inside) {
        tipTimer.stop()
        if (inside && !root._open) {
            tipTimer.pendingShow = true
            tipTimer.interval = Math.max(0, root.delay)
            tipTimer.restart()
        } else if (!inside && root._open) {
            tipTimer.pendingShow = false
            tipTimer.interval = Math.max(0, root.hideDelay)
            tipTimer.restart()
        }
    }

    // ── 定位（对标 anchor/self/offset，clamp 宿主范围） ────────
    function _edgePt(str, w, h) {
        var p = String(str).split(/\s+/)
        var vy = p[0] !== undefined ? p[0] : "top"
        var hx = p[1] !== undefined ? p[1] : "left"
        var x = hx === "right" || hx === "end" ? w : (hx === "left" || hx === "start" ? 0 : w / 2)
        var y = vy === "bottom" ? h : (vy === "top" ? 0 : h / 2)
        return Qt.point(x, y)
    }

    function _place() {
        var t = target !== null ? target : parent
        if (!t || !parent) return
        var tp = t.mapToItem(parent, 0, 0)
        var ox = offset !== undefined && offset !== null && offset.length > 0 ? offset[0] : 0
        var oy = offset !== undefined && offset !== null && offset.length > 1 ? offset[1] : 0
        var a = _edgePt(anchor, t.width, t.height)
        var s = _edgePt(self, width, height)
        x = tp.x + a.x - s.x + ox
        y = tp.y + a.y - s.y + oy
        x = Math.max(0, Math.min(x, parent.width - width))
        y = Math.max(0, Math.min(y, parent.height - height))
    }

    // ── 方法 ──────────────────────────────────────────────────
    function show() { if (!_open) updateModelValue(true) }
    function hide() { if (_open) updateModelValue(false) }
    function toggle() { _open ? hide() : show() }
    function updatePosition() { if (visible) _place() }

    // ── 气泡 ──────────────────────────────────────────────────
    Rectangle {
        id: bubble
        width: bubbleRow.implicitWidth + 16
        height: bubbleRow.implicitHeight + 12
        radius: 6
        color: root.tint

        Row {
            id: bubbleRow
            x: 8
            y: 6
            spacing: 6

            Text {
                visible: root._useText
                text: root.text
                color: "#FFFFFF"
                font.pixelSize: NovaTheme.fontS
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                id: bubbleContent
                visible: !root._useText
                width: childrenRect.width
                height: childrenRect.height
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    width: bubble.width
    height: bubble.height
}
