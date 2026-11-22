// src/pyside_nova/qml/Nova/Controls/NovaMenu.qml
// NovaMenu 声明式菜单：target 触发（父项/右键/hover 契约）、auto-close、persistent 锁 ESC+外部点击、
// fit/cover、anchor/self/offset 定位、受控 modelValue（对标 QMenu）
// Nova 口径（PARITY §0.14 留痕）：
//     portal 语义降级为就地渲染 + z 提升（建议声明在页面根层，z 由宿主层级决定）；
//     model 受控契约沿用坑位 22（show/hide 只 emit 不自写，UI 跟随 modelValue）；
//     auto-close 用 TapHandler 被动监听（不吞子项点击，坑位：MouseArea 独占会饿死菜单项）。
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    default property alias content: contentHost.data

    // ── 触发与行为 ────────────────────────────────────────────
    property var target: null                    // null = 声明父项
    property bool contextMenu: false             // 右键打开
    property bool autoClose: false               // 点击菜单内任意处关闭（被动监听）
    property bool persistent: false              // 锁 ESC + 外部点击
    property bool noEscDismiss: false
    property bool hover: false                   // 悬停展开契约（离场宽限收起）
    property int hoverDelay: 0
    property int hoverHideDelay: 150

    // ── 定位 ──────────────────────────────────────────────────
    property bool fit: false                     // 菜单至少与 target 等宽
    property bool cover: false                   // 菜单覆盖 target
    property string anchor: "bottom left"        // target 的锚点（两词：纵 top/bottom/middle × 横 left/middle/right）
    property string self: "top left"             // 菜单自身对齐点
    property var offset: [0, 0]                  // [x, y] 外扩

    // ── 形态 ──────────────────────────────────────────────────
    property color tint: NovaTheme.surface
    property bool square: false
    property real maxHeight: 0                   // 0 = 不限（超出裁剪）
    property real maxWidth: 0
    readonly property real pad: 6

    // 内容容器暴露（NovaPopupProxy 等内部组合需要 reparent 槽内容进来）
    readonly property alias contentBox: contentHost

    // ── 受控契约（坑位 22：只 emit 不自写） ────────────────────
    property bool modelValue: false
    signal updateModelValue(bool v)
    signal beforeShow()
    signal shown()
    signal beforeHide()
    signal hidden()
    signal escapeKey()

    // ── 运行时（只读） ────────────────────────────────────────
    readonly property bool _open: modelValue

    implicitWidth: fit || cover ? (target ? target.width : 0) : contentHost.childrenRect.width + 2 * pad
    implicitHeight: contentHost.childrenRect.height + 2 * pad
    visible: modelValue
    z: 9000

    // ── 显示时定位 + 焦点 + 进弹层栈 ──────────────────────────
    onVisibleChanged: {
        if (visible) {
            beforeShow()
            _place()
            forceActiveFocus()
            NovaOverlayHost.registerPopup(root, function(reason) { requestHide() })
            Qt.callLater(_hookAutoClose)
            shown()
        } else {
            beforeHide()
            NovaOverlayHost.unregisterPopup(root)
            hidden()
        }
    }

    Component.onDestruction: NovaOverlayHost.unregisterPopup(root)

    // ESC：persistent/noEscDismiss 时不响应
    Keys.onEscapePressed: {
        if (!persistent && !noEscDismiss) {
            escapeKey()
            requestHide()
        }
    }

    // ── target 触发（左键/右键；target 缺省父项，绑定直读不写回） ──
    readonly property var _tgt: target !== null ? target : parent
    TapHandler {
        enabled: root.visible === false && !root.contextMenu && root._tgt !== null
        target: root._tgt
        onTapped: root.requestShow()
    }
    TapHandler {
        enabled: root.visible === false && root.contextMenu && root._tgt !== null
        acceptedButtons: Qt.RightButton
        target: root._tgt
        onTapped: root.requestShow()
    }

    // ── hover 契约（进入 hoverDelay 展开；离场 hoverHideDelay 宽限收起） ──
    HoverHandler {
        id: menuHov
        enabled: root.hover
        target: null   // 悬停区域由外部命中区决定（target 或菜单）
        cursorShape: Qt.ArrowCursor
    }
    Timer {
        id: hoverTimer
        property bool pendingShow: true
        onTriggered: pendingShow ? root.requestShow() : root.requestHide()
    }
    // hover 命中区 = target ∪ 菜单（由宿主/调用方经 updateHover(bool) 驱动）
    function updateHover(inside) {
        if (!root.hover) return
        hoverTimer.stop()
        if (inside && !root._open) {
            hoverTimer.pendingShow = true
            hoverTimer.interval = Math.max(0, root.hoverDelay)
            hoverTimer.restart()
        } else if (!inside && root._open) {
            hoverTimer.pendingShow = false
            hoverTimer.interval = Math.max(0, root.hoverHideDelay)
            hoverTimer.restart()
        }
    }

    // ── 定位（对标 anchor/self/offset；clamp 到宿主范围） ──────
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
        if (!t || !parent)
            return
        var tw = t.width, th = t.height
        var tp = t.mapToItem(parent, 0, 0)
        var ox = offset !== undefined && offset !== null && offset.length > 0 ? offset[0] : 0
        var oy = offset !== undefined && offset !== null && offset.length > 1 ? offset[1] : 0
        var a = _edgePt(anchor, tw, th)
        var s = _edgePt(self, width, height)
        if (cover) {
            x = tp.x + ox
            y = tp.y + oy
            width = Math.max(implicitWidth, tw)
        } else {
            width = implicitWidth
            x = tp.x + a.x - s.x + ox
            y = tp.y + a.y - s.y + oy
        }
        height = implicitHeight
        // clamp：不溢出宿主
        if (parent) {
            x = Math.max(0, Math.min(x, parent.width - width))
            y = Math.max(0, Math.min(y, parent.height - height))
        }
    }

    onImplicitWidthChanged: if (visible) _place()
    onImplicitHeightChanged: if (visible) _place()

    // ── 方法（对标 show/hide/toggle/updatePosition/focus；只 emit 不自写） ──
    function show() { requestShow() }
    function hide() { requestHide() }
    function requestShow() { if (!_open) updateModelValue(true) }
    function requestHide() { if (_open) updateModelValue(false) }
    function toggle() { _open ? requestHide() : requestShow() }
    function updatePosition() { if (visible) _place() }

    // ── 外部点击捕获（就地渲染口径：负偏移铺宿主范围；persistent 时不拦；
    //    宿主交互控件点击由宿主自行处理——NovaMenu 不劫持宿主控件事件） ──
    MouseArea {
        x: root.parent !== null ? -root.x : 0
        y: root.parent !== null ? -root.y : 0
        width: root.parent !== null ? root.parent.width : 0
        height: root.parent !== null ? root.parent.height : 0
        enabled: root.visible && !root.persistent
        z: -1
        onClicked: root.requestHide()
    }

    // ── 菜单面板 ──────────────────────────────────────────────
    Rectangle {
        id: panel
        x: 0; y: 0
        width: root.width
        height: Math.min(root.height, root.maxHeight > 0 ? root.maxHeight : root.height)
        radius: root.square ? 0 : NovaTheme.radiusS
        color: root.tint
        border.width: 1
        border.color: NovaTheme.outline
        clip: true

        // 内容宿主：子项手动排布（坑位 24/28：不用定位器，读 childrenRect 出尺寸）
        Item {
            id: contentHost
            x: root.pad
            y: root.pad
            width: Math.max(0, panel.width - 2 * root.pad)
            height: childrenRect.height
        }

        // auto-close：动态挂接子项 clicked（TapHandler 会被子项 MouseArea 独占饿死——坑位沉淀 35）
        TapHandler {
            enabled: false
        }
    }

    // 子项 clicked 挂接（autoClose 口径：任何菜单项点击后关闭；登记防重复挂接）
    property var _hookedItems: []
    function _hookAutoClose() {
        for (var i = 0; i < contentHost.children.length; i++) {
            var c = contentHost.children[i]
            if (c.clicked !== undefined && root._hookedItems.indexOf(c) === -1) {
                c.clicked.connect(function() {
                    if (root.autoClose && root.visible)
                        root.requestHide()
                })
                root._hookedItems = root._hookedItems.concat([c])
            }
        }
    }
}
