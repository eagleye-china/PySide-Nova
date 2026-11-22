// src/pyside_nova/qml/Nova/Services/NovaDialogCard.qml
// NovaDialogCard 对话框卡片：遮罩 + 卡片 + 标题/正文/内容委托/进度/动作区，四向定位与进出场动效（内部件，由 NovaDialog 驱动）
// NovaDialogCard —— 单个对话框的可视层（对标 QDialog 卡片；qmldir 内部导出，不由应用直接声明）
// 行为契约见 docs/PARITY.md NovaDialog 审计节：
//     默认 OK/Cancel 双按钮（flat 风格）、focus=ok；persistent 同时锁住 backdrop 与 ESC；
//     dismissed(reason) 五值：ok / cancel / backdrop / escape / api（关闭原因上报为基线 2.28 真 parity）；
//     宽高规则：maxWidth 560、四周留白 24；fullWidth/fullHeight 贴边留白、maximized 全屏。
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Nova.Controls
import Nova.Services

Item {
    id: root

    // ── 内容 ──────────────────────────────────────────────────
    property string title: ""
    property string message: ""
    property Component contentDelegate: null   // 替代基线 html（QML 无 DOM + XSS 面），整块替换正文区

    // ── 定位与形态 ────────────────────────────────────────────
    property string position: "standard"        // standard | top | right | bottom | left
    property bool maximized: false
    property bool fullWidth: false
    property bool fullHeight: false
    property bool seamless: false               // 无遮罩（基线 seamless）
    property real maxWidth: 560
    property color cardTint: NovaTheme.surface

    // ── 关闭策略 ──────────────────────────────────────────────
    property bool persistent: false
    property bool noEscDismiss: false
    property bool noBackdropDismiss: false

    // ── 动作区（由 NovaDialog.normalizeButton 归一后的结构） ────
    property var okConfig: ({ visible: true, label: "OK", variant: "flat", tint: NovaTheme.primary })
    property var cancelConfig: ({ visible: true, label: "Cancel", variant: "flat", tint: NovaTheme.primary })
    property string focusTarget: "ok"           // ok | cancel | none
    property bool stackButtons: false

    // ── 进度 ──────────────────────────────────────────────────
    property bool progress: false
    property string progressMessage: ""

    // ── 动效 ──────────────────────────────────────────────────
    property string transitionShow: "scale"      // scale | fade | none
    property string transitionHide: "scale"

    // ── 回调（基线 onOk / onCancel / onDismiss；on* 前缀撞 QML 红线，改名承载） ──
    property var okCallback: null
    property var cancelCallback: null
    property var dismissCallback: null

    // ── 运行时状态（NovaDialog 维护，应用层只读） ───────────────
    readonly property bool hasBackdrop: !seamless
    property bool _closed: false
    property bool _dead: false
    property var _handle: null                   // NovaDialogHandle 反向引用（防 GC）

    signal accepted()
    signal cancelled()
    signal dismissed(string reason)

    focus: true
    Keys.onEscapePressed: root.requestDismiss("escape")

    Component.onCompleted: root.playEnter()
    Component.onDestruction: NovaDialog._forget(root)

    // ── 遮罩 ──────────────────────────────────────────────────
    Rectangle {
        id: scrim
        anchors.fill: parent
        visible: root.hasBackdrop
        color: "#000000"
        opacity: 0

        MouseArea {
            anchors.fill: parent
            onClicked: root.requestDismiss("backdrop")
        }
    }

    // ── 卡片 ──────────────────────────────────────────────────
    Rectangle {
        id: card
        readonly property int margin: 24
        readonly property int pad: NovaTheme.spacingL

        width: root.maximized ? root.width
             : root.fullWidth ? Math.max(0, root.width - 2 * margin)
             : Math.min(root.maxWidth, Math.max(0, root.width - 2 * margin))
        height: root.maximized ? root.height
              : root.fullHeight ? Math.max(0, root.height - 2 * margin)
              : col.implicitHeight + 2 * pad
        x: root.maximized ? 0
         : root.position === "left" ? margin
         : root.position === "right" ? root.width - width - margin
         : (root.width - width) / 2
        y: root.maximized ? 0
         : root.position === "top" ? margin
         : root.position === "bottom" ? root.height - height - margin
         : (root.height - height) / 2

        radius: NovaTheme.radiusM
        color: root.cardTint
        border.width: 1
        border.color: NovaTheme.outline
        scale: 1

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: NovaTheme.shadowColor(3)
            shadowBlur: 0.5
            shadowVerticalOffset: 12
        }

        Column {
            id: col
            x: card.pad
            y: card.pad
            width: Math.max(0, card.width - 2 * card.pad)
            spacing: NovaTheme.spacingL

            Text {
                width: parent.width
                visible: root.title !== ""
                text: root.title
                color: NovaTheme.textColor
                font.pixelSize: NovaTheme.fontL
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                visible: root.message !== ""
                text: root.message
                color: NovaTheme.textMuted
                font.pixelSize: NovaTheme.fontS
                lineHeight: 1.35
                wrapMode: Text.WordWrap
            }

            Loader {
                width: parent.width
                visible: sourceComponent !== null
                sourceComponent: root.contentDelegate
            }

            Row {
                width: parent.width
                spacing: NovaTheme.spacingM
                visible: root.progress

                BusyIndicator {
                    running: root.progress
                    visible: root.progress
                    implicitWidth: 28
                    implicitHeight: 28
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.progressMessage !== ""
                    text: root.progressMessage
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontS
                }
            }

            Item {
                width: parent.width
                height: actions.implicitHeight
                visible: root.okConfig.visible !== false || root.cancelConfig.visible !== false

                Grid {
                    id: actions
                    anchors.right: parent.right
                    columns: root.stackButtons ? 1 : 2
                    spacing: NovaTheme.spacingS

                    NovaBtn {
                        id: cancelBtn
                        visible: root.cancelConfig.visible !== false
                        text: root.cancelConfig.label !== undefined ? root.cancelConfig.label : "Cancel"
                        variant: root.cancelConfig.variant !== undefined ? root.cancelConfig.variant : "flat"
                        tint: root.cancelConfig.tint !== undefined ? root.cancelConfig.tint : NovaTheme.primary
                        focus: root.focusTarget === "cancel"
                        onClicked: root.cancel()
                    }

                    NovaBtn {
                        id: okBtn
                        visible: root.okConfig.visible !== false
                        text: root.okConfig.label !== undefined ? root.okConfig.label : "OK"
                        variant: root.okConfig.variant !== undefined ? root.okConfig.variant : "flat"
                        tint: root.okConfig.tint !== undefined ? root.okConfig.tint : NovaTheme.primary
                        focus: root.focusTarget === "ok"
                        onClicked: root.accept()
                    }
                }
            }
        }
    }

    // ── 动效 ──────────────────────────────────────────────────
    ParallelAnimation {
        id: enterAnim
        NumberAnimation {
            target: root
            property: "opacity"
            from: 0
            to: 1
            duration: 180
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: card
            property: "scale"
            from: root.transitionShow === "scale" ? 0.92 : 1
            to: 1
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: exitAnim
        onFinished: root.destroy()
        NumberAnimation {
            target: root
            property: "opacity"
            from: 1
            to: 0
            duration: 160
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: card
            property: "scale"
            from: 1
            to: root.transitionHide === "scale" ? 0.94 : 1
            duration: 160
            easing.type: Easing.InCubic
        }
    }

    function playEnter() {
        if (root.transitionShow === "none") {
            root.opacity = 1
            return
        }
        root.opacity = 0
        scrim.opacity = root.hasBackdrop ? 0.5 : 0
        enterAnim.start()
    }

    function playExit() {
        if (root.transitionHide === "none") {
            root.destroy()
            return
        }
        exitAnim.start()
    }

    // ── 关闭路径（唯一入口：ok/cancel/backdrop/escape/api 全部汇于此） ──
    function requestDismiss(reason) {
        if (root._closed || root._dead)
            return
        var r = reason === undefined ? "api" : reason
        if (r === "escape" && (root.persistent || root.noEscDismiss))
            return
        if (r === "backdrop" && (root.persistent || root.noBackdropDismiss))
            return
        root._closed = true
        if (root._handle)
            root._handle.item = null
        if (r === "ok" && typeof root.okCallback === "function")
            root.okCallback()
        if (r === "cancel" && typeof root.cancelCallback === "function")
            root.cancelCallback()
        if (typeof root.dismissCallback === "function")
            root.dismissCallback(r)
        root.dismissed(r)
        if (r === "ok")
            root.accepted()
        else if (r === "cancel")
            root.cancelled()
        root.playExit()
    }

    function accept() {
        root.requestDismiss("ok")
    }

    function cancel() {
        root.requestDismiss("cancel")
    }

    // ── 更新（白名单，语义对标基线 update：只改传入项，不重置关闭状态） ──
    function applyUpdate(props) {
        if (!props || typeof props !== "object")
            return false
        var keys = ["title", "message", "contentDelegate", "progress", "progressMessage",
                    "persistent", "seamless", "maximized", "fullWidth", "fullHeight",
                    "transitionShow", "transitionHide"]
        for (var i = 0; i < keys.length; i++) {
            if (props[keys[i]] !== undefined)
                root[keys[i]] = props[keys[i]]
        }
        if (props.tint !== undefined)
            root.cardTint = props.tint
        if (props.ok !== undefined)
            root.okConfig = NovaDialog.normalizeButton(props.ok, "OK")
        if (props.cancel !== undefined)
            root.cancelConfig = NovaDialog.normalizeButton(props.cancel, "Cancel")
        return true
    }
}
