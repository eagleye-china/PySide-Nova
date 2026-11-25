// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaModal.qml
// NovaModal 模态弹窗壳：单色系顶条 + 抽象短条 + 浮起卡片 + 遮罩，ESC / 点遮罩关闭（对标 Quasar QDialog）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）；
//   三色渐变顶条收敛主色系、伪拖拽把手改抽象几何（CC-3）；槽位宿主独立铺满（CC-6）；遮罩为功能性例外。
// 用法：向 titleSlot/contentSlot/actionsSlot 注入业务内容；注入顶层须 anchors.fill: parent
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias titleSlot: _titleHost.data
    property alias contentSlot: _body.content
    property alias actionsSlot: _actionsHost.data

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

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）
    readonly property int _titleH: Math.max(24, Math.min(root.titleHeight, 240))
    readonly property int _actionsH: Math.max(24, Math.min(root.actionsHeight, 240))
    readonly property real _maxW: Math.max(280, root.maxWidth)
    readonly property real _maxH: Math.max(160, root.maxHeight)
    readonly property real _chromeH: (root.showTitle ? root._titleH : 0)
                                     + (root.showActions ? root._actionsH : 0)

    // ── 组合上下文 CC-1 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property real _radius: NovaTheme.radiusL
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _panel: NovaTheme.surface
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _ink: NovaTheme.primary
    readonly property color _inkSoft: Qt.lighter(NovaTheme.primary, 1.35)

    visible: root.open
    anchors.fill: parent
    z: NovaTheme.zFullscreen

    // 功能性遮罩：刻意半透明透出下层（CC-3 实心度例外，保留 0.55）
    Rectangle {
        id: _mask
        anchors.fill: parent
        color: NovaTheme.shadowColor(2)
        opacity: 0.55
        MouseArea {
            anchors.fill: parent
            enabled: root.dismissOnMask
            onClicked: root.requestClose("mask")
        }
    }

    // 浮起阴影层（elevation 观感；用 x/y 定位，不与 anchors 混用）
    // a11y: decorative
    Rectangle {
        x: _card.x + 3
        y: _card.y + 6
        width: _card.width
        height: _card.height
        radius: root._radius
        color: NovaTheme.shadowColor(3)
    }

    Rectangle {
        id: _card
        width: Math.max(280, Math.min(root._maxW, parent.width - root._gap * 2))
        height: Math.max(root._chromeH + root._gap * 2,
                         Math.min(root._maxH,
                                  root._chromeH + _body.implicitHeight + root._gap * 2))
        anchors.centerIn: parent
        radius: root._radius
        color: root._panel
        border { width: 1; color: root._divider }
        clip: true

        // 身份 A（主签名）：单色系顶条（替换 primary/secondary/accent 三色撞色渐变）
        // a11y: decorative
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 4
            z: NovaTheme.zMarginals
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root._ink }
                GradientStop { position: 1.0; color: root._inkSoft }
            }
            opacity: 0.9
        }

        // ── 标题栏（高度归零 + 恒定锚链 CC-5；该边界唯一分隔源）──
        Rectangle {
            id: _titleBar
            anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 4 }
            height: root.showTitle ? root._titleH : 0
            clip: true
            color: root._panel
            z: NovaTheme.zMarginals
            Behavior on height {
                NumberAnimation { duration: root._dur; easing.type: root._ease }
            }
            NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

            NovaHeader {
                id: _titleWrap
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._titleH
                tint: root._panel
            }
            // 身份 B（次签名）：居中主色系短渐变线（替换「拖拽 catcher 把手」伪控件）
            // a11y: decorative
            Rectangle {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 6 }
                width: 36; height: 3; radius: 1.5
                color: root._ink
                opacity: 0.9
                z: NovaTheme.zMarginals
            }
            Item {
                id: _titleHost
                anchors { fill: _titleWrap; leftMargin: root._gap; rightMargin: root._gap; topMargin: root._unit }
            }
        }

        NovaPage {
            id: _body
            anchors {
                top: _titleBar.bottom
                bottom: _actionsBar.top
                left: parent.left
                right: parent.right
            }
            padding: 0
        }

        // ── 操作栏（高度归零 + 恒定锚链；该边界唯一分隔源）──
        Rectangle {
            id: _actionsBar
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: root.showActions ? root._actionsH : 0
            clip: true
            color: root._rail
            z: NovaTheme.zMarginals
            Behavior on height {
                NumberAnimation { duration: root._dur; easing.type: root._ease }
            }
            NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
            Item {
                id: _actionsHost
                anchors { fill: parent; margins: root._unit }
            }
        }

        Keys.onEscapePressed: root.requestClose("escape")
        focus: true
    }

    Component.onCompleted: if (root.open) _card.forceActiveFocus()
}
