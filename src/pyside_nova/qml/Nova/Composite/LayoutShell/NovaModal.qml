// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaModal.qml
// NovaModal 模态弹窗壳：顶部品牌色条 + 拖拽把手 + 浮起卡片 + 遮罩，ESC / 点遮罩关闭（对标 Quasar QDialog）
// NovaModal —— 全库通用模态弹窗组合根容器；以"顶部色条 + catcher 把手"为身份语言
// 用法：向 titleSlot/contentSlot/actionsSlot 注入业务内容；open/dismiss 受控，Shell 只 emit 关闭意图
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root
    // 鲁棒性 / i18n：声明式容器随 RTL 镜像；逻辑侧槽位语义恒定（宪法第 7 章第 3 条）
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias titleSlot: _title.data
    property alias contentSlot: _body.content
    property alias actionsSlot: _actions.data

    property bool open: false
    property bool dismissOnMask: true
    property bool showTitle: true
    property bool showActions: true
    property real maxWidth: 520
    property real maxHeight: 620
    property int titleHeight: 52
    property int actionsHeight: 56

    signal closeRequested(string reason)   // "escape" | "mask" | "button"
    function requestClose(reason) { root.closeRequested(reason) }

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _titleH: Math.max(24, Math.min(root.titleHeight, 240))
    readonly property int _actionsH: Math.max(24, Math.min(root.actionsHeight, 240))
    readonly property real _maxW: Math.max(280, root.maxWidth)
    readonly property real _maxH: Math.max(160, root.maxHeight)
    // 标题栏 + 操作栏固定占用；卡片高度下界须覆盖它，否则极端 maxHeight 会压出负内容区
    readonly property real _chromeH: (root.showTitle ? root._titleH : 0)
                                     + (root.showActions ? root._actionsH : 0)

    visible: root.open
    anchors.fill: parent
    z: NovaTheme.zFullscreen

    Rectangle {
        id: _mask
        anchors.fill: parent
        // 功能性遮罩：刻意半透明透出下层（非身份装饰，不受实心度 ≥0.85 约束）
        color: NovaTheme.shadowColor(2)
        opacity: 0.55
        MouseArea {
            anchors.fill: parent
            enabled: root.dismissOnMask
            onClicked: root.requestClose("mask")
        }
    }

    // 浮起阴影层（elevation 观感）
    // a11y: decorative
    Rectangle {
        anchors { fill: _card }
        x: _card.x + 2; y: _card.y + 6
        radius: NovaTheme.radiusL
        color: NovaTheme.shadowColor(3)
    }

    Rectangle {
        id: _card
        width: Math.max(280, Math.min(root._maxW, parent.width - NovaTheme.spacingL * 2))
        height: Math.max(root._chromeH + NovaTheme.spacingL * 2,
                         Math.min(root._maxH,
                                  root._chromeH
                                  + _body.implicitHeight + NovaTheme.spacingL * 2))
        anchors.centerIn: parent
        radius: NovaTheme.radiusL
        color: NovaTheme.surface
        border { width: 1; color: NovaTheme.outline }
        clip: true

        // ── 身份元素 ①：顶部品牌渐变色条 ──
        // a11y: decorative
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 4
            z: NovaTheme.zMarginals
            gradient: Gradient {
                GradientStop { position: 0.0; color: NovaTheme.primary }
                GradientStop { position: 0.5; color: NovaTheme.secondary }
                GradientStop { position: 1.0; color: NovaTheme.accent }
            }
        }

        NovaHeader {
            id: _titleWrap
            visible: root.showTitle
            height: root._titleH
            anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 4 }
            tint: NovaTheme.surface

            // ── 身份元素 ②：拖拽 catcher 把手（顶部居中横条）──
            // a11y: decorative
            Rectangle {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 5 }
                width: 32; height: 4; radius: 2
                color: NovaTheme.outlineStrong
                opacity: 0.9
                z: NovaTheme.zMarginals
            }

            NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
            Item {
                id: _title
                anchors {
                    fill: parent
                    topMargin: 8
                    leftMargin: NovaTheme.spacingM
                    rightMargin: NovaTheme.spacingM
                }
            }
        }

        NovaPage {
            id: _body
            anchors {
                top: root.showTitle ? _titleWrap.bottom : parent.top
                topMargin: root.showTitle ? 0 : 4
                bottom: root.showActions ? _actionsWrap.top : parent.bottom
                left: parent.left; right: parent.right
            }
            padding: NovaTheme.spacingM
        }

        Rectangle {
            id: _actionsWrap
            visible: root.showActions
            height: root._actionsH
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            color: NovaTheme.surfaceAlt
            NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
            Item { id: _actions; anchors { fill: parent; margins: NovaTheme.spacingS } }
        }

        Keys.onEscapePressed: root.requestClose("escape")
        focus: true
    }

    Component.onCompleted: if (root.open) _card.forceActiveFocus()
}
