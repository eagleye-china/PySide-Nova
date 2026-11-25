// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaDrawerPanel.qml
// NovaDrawerPanel 侧边滑出面板壳：侧缘轨 + grabber 把手 + 滑入动画 + 非模态临时面板（区别于常驻 Sidebar）
// NovaDrawerPanel —— 属性面板 / 详情面板 / 临时表单组合根容器；以"侧缘轨 + 滑入动画"为身份语言
// 用法：向 titleSlot/contentSlot/actionsSlot 注入业务内容；open/side 受控，Shell 只 emit 关闭与侧别意图
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
    property string side: "right"          // left | right（逻辑侧；RTL 下 bySide 自动镜像）
    readonly property string bySide: NovaTheme.isRtl ? (root.side === "left" ? "right" : "left") : root.side
    property real size: 360
    property int titleHeight: 52
    property bool showTitle: true
    property bool showActions: false
    property int actionsHeight: 56
    property bool scrim: false

    signal closeRequested()
    function requestClose() { root.closeRequested() }

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _titleH: Math.max(24, Math.min(root.titleHeight, 240))
    readonly property int _actionsH: Math.max(24, Math.min(root.actionsHeight, 240))

    visible: root.open
    anchors.fill: parent

    Rectangle {
        id: _scrim
        visible: root.scrim
        anchors.fill: parent
        // 功能性遮罩：刻意半透明透出下层（非身份装饰，不受实心度 ≥0.85 约束）
        color: NovaTheme.shadowColor(2)
        opacity: 0.32
        MouseArea { anchors.fill: parent; onClicked: root.requestClose() }
    }

    // 侧缘轨：贴在面板最外侧的渐变竖条（身份锚点）
    // a11y: decorative
    Rectangle {
        anchors {
            top: parent.top; bottom: parent.bottom
            left: root.bySide === "left" ? _panel.left : undefined
            right: root.bySide === "right" ? _panel.right : undefined
        }
        width: 4
        z: NovaTheme.zFixedDrawer + 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: NovaTheme.primary }
            GradientStop { position: 1.0; color: NovaTheme.secondary }
        }
    }

    Rectangle {
        id: _panel
        width: Math.max(200, Math.min(root.size, parent.width * 0.8 || root.size))
        anchors {
            top: parent.top; bottom: parent.bottom
            left: root.bySide === "left" ? parent.left : undefined
            right: root.bySide === "right" ? parent.right : undefined
        }
        color: NovaTheme.surface
        z: NovaTheme.zFixedDrawer

        NovaSeparator {
            anchors {
                top: parent.top; bottom: parent.bottom
                left: root.bySide === "right" ? parent.left : undefined
                right: root.bySide === "left" ? parent.right : undefined
            }
            vertical: true
        }

        NovaHeader {
            id: _titleWrap
            visible: root.showTitle
            height: root._titleH
            anchors { top: parent.top; left: parent.left; right: parent.right }
            tint: NovaTheme.surface

            // ── 身份元素：grabber 把手（顶部居中横条）──
            // a11y: decorative
            Rectangle {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 5 }
                width: 36; height: 4; radius: 2
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

        Keys.onEscapePressed: root.requestClose()
        focus: true
    }

    Component.onCompleted: if (root.open) _panel.forceActiveFocus()
}
