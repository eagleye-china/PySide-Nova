// src/pyside_nova/qml/Nova/Controls/NovaDialogShell.qml
// NovaDialogShell 声明式对话框壳：遮罩 + 卡片 + default 槽，persistent/no-esc/no-backdrop、
// 五向定位、shake 吸引注意、**关闭原因上报**（ok/cancel/backdrop/escape/api，对标 QDialog · 基线 2.28 真 parity）
// 命名说明：Services 已有 NovaDialog 命令式单例，跨模块同名 import 歧义 → 组件壳名 NovaDialogShell（Nova 命名红线）
// 就地渲染口径：anchors.fill 父级（建议声明在页面根层）；modelValue 受控（坑位 22）
import QtQuick
import QtQuick.Effects
import Nova.Controls
import Nova.Services

Item {
    id: root

    default property alias content: cardBody.data

    // ── 受控契约 ──────────────────────────────────────────────
    property bool modelValue: false
    signal updateModelValue(bool v)

    // ── 关闭策略 ──────────────────────────────────────────────
    property bool persistent: false             // 同时锁 backdrop 与 ESC（点击外部/按 ESC → shake 吸引注意）
    property bool noEscDismiss: false
    property bool noBackdropDismiss: false
    property bool seamless: false               // 无遮罩
    property bool noShake: false

    // ── 形态与定位 ────────────────────────────────────────────
    property bool maximized: false
    property bool fullWidth: false
    property bool fullHeight: false
    property string position: "standard"        // standard | top | right | bottom | left
    property bool square: false
    property color tint: NovaTheme.surface
    readonly property real margin: 24
    property real maxWidth: 560

    // ── 事件（对标 QDialog；dismissed(reason) 关闭原因上报） ──
    signal beforeShow()
    signal shown()
    signal beforeHide()
    signal hidden()
    signal escapeKey()
    signal shake()
    signal accepted()                            // reason === "ok"
    signal cancelled()                           // reason === "cancel"
    signal dismissed(string reason)              // ok | cancel | backdrop | escape | api

    // ── 运行时（只读） ────────────────────────────────────────
    readonly property bool _open: modelValue

    implicitWidth: 400
    implicitHeight: 300

    visible: modelValue

    onVisibleChanged: {
        if (visible) {
            beforeShow()
            forceActiveFocus()
            NovaOverlayHost.registerPopup(root, function(reason) { requestDismiss("api") })
            _playEnter()
            shown()
        } else {
            beforeHide()
            NovaOverlayHost.unregisterPopup(root)
            hidden()
        }
    }

    Keys.onEscapePressed: {
        escapeKey()
        if (!persistent && !noEscDismiss)
            requestDismiss("escape")
        else
            _doShake()
    }

    // ── 遮罩 ──────────────────────────────────────────────────
    Rectangle {
        id: scrim
        anchors.fill: parent
        visible: !root.seamless
        color: "#000000"
        opacity: root.visible ? 0.5 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.persistent || root.noBackdropDismiss)
                    root._doShake()
                else
                    root.requestDismiss("backdrop")
            }
        }
    }

    // ── 卡片 ──────────────────────────────────────────────────
    Rectangle {
        id: card
        width: root.maximized ? root.width
             : root.fullWidth ? Math.max(0, root.width - 2 * root.margin)
             : Math.min(root.maxWidth, Math.max(0, root.width - 2 * root.margin))
        height: root.maximized ? root.height
              : root.fullHeight ? Math.max(0, root.height - 2 * root.margin)
              : Math.min(Math.max(implicitHeight, 120), Math.max(0, root.height - 2 * root.margin))
        readonly property real implicitHeight: cardBody.childrenRect.height + 2 * NovaTheme.spacingL
        x: root.position === "left" ? root.margin
         : root.position === "right" ? root.width - width - root.margin
         : (root.width - width) / 2
        y: root.position === "top" ? root.margin
         : root.position === "bottom" ? root.height - height - root.margin
         : (root.height - height) / 2

        radius: root.square ? 0 : NovaTheme.radiusM
        color: root.tint
        border.width: 1
        border.color: NovaTheme.outline

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: NovaTheme.shadowColor(3)
            shadowBlur: 0.5
            shadowVerticalOffset: 12
        }

        // 内容宿主（手动排布口径，读 childrenRect 出卡片高度；暴露给 PopupProxy 组合）
        Item {
            id: cardBody
            objectName: "dialogContentHost"
            x: NovaTheme.spacingL
            y: NovaTheme.spacingL
            width: Math.max(0, card.width - 2 * NovaTheme.spacingL)
            height: childrenRect.height
        }
    }

    // 内容容器暴露（NovaPopupProxy 等内部组合需要 reparent 槽内容进来）
    readonly property alias contentBox: cardBody

    // ── 动效 ──────────────────────────────────────────────────
    ParallelAnimation {
        id: enterAnim
        running: false
        NumberAnimation { target: card; property: "scale"; from: 0.94; to: 1; duration: 180; easing.type: Easing.OutCubic }
        NumberAnimation { target: card; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
    }

    function _playEnter() {
        card.scale = 0.94
        card.opacity = 0
        enterAnim.restart()
    }

    // shake：persistent 拒关时的吸引注意动效（对标 QDialog shake）
    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: card; property: "x"; to: card.x + 8; duration: 60 }
        NumberAnimation { target: card; property: "x"; to: card.x - 8; duration: 60 }
        NumberAnimation { target: card; property: "x"; to: card.x + 4; duration: 60 }
        NumberAnimation { target: card; property: "x"; to: card.x; duration: 60 }
    }

    function _doShake() {
        if (noShake || !visible) return
        shake()
        shakeAnim.restart()
    }

    // ── 关闭路径（唯一入口；programmatic 语义 = "api"，五值口径对齐 Services.NovaDialog） ──
    function requestDismiss(reason) {
        if (!visible) return
        var r = reason === undefined ? "api" : reason
        if (r === "escape" && (persistent || noEscDismiss)) return
        if (r === "backdrop" && (persistent || noBackdropDismiss)) return
        if (r === "ok") accepted()
        else if (r === "cancel") cancelled()
        dismissed(r)
        updateModelValue(false)
    }

    function accept() { requestDismiss("ok") }
    function cancel() { requestDismiss("cancel") }

    // ── 方法（对标 show/hide/toggle/focus/shake） ──────────────
    function show() { if (!_open) updateModelValue(true) }
    function hide() { if (_open) updateModelValue(false) }
    function toggle() { _open ? hide() : show() }
    function doShake() { _doShake() }
}
