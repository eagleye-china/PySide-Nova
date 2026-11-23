// src/pyside_nova/qml/Nova/Controls/NovaPopupProxy.qml
// NovaPopupProxy 弹层路由：窗口宽/高较小者 < breakpoint → Dialog 形态（全屏卡片），否则 Menu 形态（对标 QPopupProxy）
// 内容槽共享：default 槽内容按当前形态 reparent 到对应形态容器；关闭后归还
// 受控契约：modelValue（坑位 22）；target 触发语义与 NovaMenu 一致
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    default property alias content: holder.data

    // ── 触发与行为（转发当前形态） ─────────────────────────────
    property var target: null
    property bool contextMenu: false
    property bool autoClose: false
    property bool persistent: false
    property bool noEscDismiss: false
    property bool noBackdropDismiss: false
    property int breakpoint: 450                // 窗口宽/高较小者低于该值 → Dialog 形态
    property bool cover: false
    property bool fit: false
    property string anchor: "bottom left"
    property string self: "top left"
    property var offset: [0, 0]
    property color tint: NovaTheme.surface
    property string position: "standard"        // Dialog 形态定位

    // ── 受控契约 ──────────────────────────────────────────────
    property bool modelValue: false
    signal updateModelValue(bool v)
    signal beforeShow()
    signal shown()
    signal beforeHide()
    signal hidden()
    signal escapeKey()

    // ── 形态派生（窗口宽/高较小者，对标 QPopupProxy breakpoint 判定） ──
    readonly property bool dialogMode: {
        var w = NovaScreen.width, h = NovaScreen.height
        return Math.min(w, h) < root.breakpoint
    }
    readonly property bool _open: modelValue

    Component.onCompleted: if (target === null) target = parent

    onDialogModeChanged: {
        if (_open) {
            _reparentContent(dialogMode ? dialogShell.contentBox : menuPanel.contentBox)
            menuModeActive = !dialogMode
        }
    }

    property bool menuModeActive: true

    // ── 槽内容迁移（关闭后归还 holder，避免重复创建/销毁） ─────
    function _reparentContent(dest) {
        for (var i = 0; i < holder.children.length; i++) {
            var c = holder.children[i]
            c.parent = dest
        }
        for (var j = 0; j < holder.data.length; j++) { /* data 与 children 同步，无需处理 */ }
    }
    function _restoreContent() {
        _reparentContent(holder)
    }

    // ── 双形态声明 ────────────────────────────────────────────
    NovaMenu {
        id: menuPanel
        target: root.target !== null ? root.target : root.parent
        contextMenu: root.contextMenu
        autoClose: root.autoClose
        persistent: root.persistent
        noEscDismiss: root.noEscDismiss
        cover: root.cover
        fit: root.fit
        anchor: root.anchor
        self: root.self
        offset: root.offset
        tint: root.tint
        modelValue: root._open && !root.dialogMode
        onUpdateModelValue: (v) => root.updateModelValue(v)
        onEscapeKey: root.escapeKey()
        z: root.z
    }

    NovaDialogShell {
        id: dialogShell
        anchors.fill: parent
        persistent: root.persistent
        noEscDismiss: root.noEscDismiss
        noBackdropDismiss: root.noBackdropDismiss
        position: root.position
        tint: root.tint
        modelValue: root._open && root.dialogMode
        onUpdateModelValue: (v) => root.updateModelValue(v)
        onEscapeKey: root.escapeKey()
        z: root.z
    }

    // 状态对齐：随形态切换同步事件（受控契约下 modelValue 驱动，这里只补事件）
    Connections {
        target: menuPanel
        function onShown() { if (!root.dialogMode) { root.beforeShow(); root.shown() } }
        function onHidden() { if (!root.dialogMode) { root._restoreContent(); root.beforeHide(); root.hidden() } }
    }
    Connections {
        target: dialogShell
        function onShown() { if (root.dialogMode) { root.beforeShow(); root.shown() } }
        function onHidden() { if (root.dialogMode) { root._restoreContent(); root.beforeHide(); root.hidden() } }
    }

    // 打开时把槽内容迁入当前形态
    onVisibleChanged: {
        if (visible) {
            menuModeActive = !dialogMode
            _reparentContent(dialogMode ? dialogShell.contentBox : menuPanel.contentBox)
        }
    }

    // ── 方法 ──────────────────────────────────────────────────
    function show() { if (!_open) updateModelValue(true) }
    function hide() { if (_open) updateModelValue(false) }
    function toggle() { _open ? hide() : show() }

    // ── 内容暂存宿主（不可见，仅持有槽内容） ──────────────────
    Item {
        id: holder
        visible: false
        width: 0; height: 0
    }
}
