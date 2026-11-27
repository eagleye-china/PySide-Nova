// src/pyside_nova/qml/Nova/Composite/NovaDrawerPanel.qml
// NovaDrawerPanel 侧边滑出面板壳：单色系侧缘轨 + 抽象短条 + 非模态临时面板（区别于常驻 Sidebar）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）；
//   primary→secondary 撞色轨收敛主色系、伪 grabber 把手改抽象几何（CC-3）；槽位宿主独立铺满（CC-6）。
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

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）
    readonly property int _titleH: Math.max(24, Math.min(root.titleHeight, 240))
    readonly property int _actionsH: Math.max(24, Math.min(root.actionsHeight, 240))

    // ── 组合上下文 CC-1 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _panel: NovaTheme.surface
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _ink: NovaTheme.primary
    readonly property color _inkSoft: Qt.lighter(NovaTheme.primary, 1.35)

    visible: root.open
    anchors.fill: parent

    // 功能性遮罩：刻意半透明透出下层（CC-3 实心度例外，保留 0.32）
    Rectangle {
        id: _scrim
        visible: root.scrim
        anchors.fill: parent
        color: NovaTheme.shadowColor(2)
        opacity: 0.32
        MouseArea { anchors.fill: parent; onClicked: root.requestClose() }
    }

    // 身份 A（主签名）：单色系侧缘轨（绝对定位，恒定不依赖 visible 三元，CC-5）
    // a11y: decorative
    Rectangle {
        x: root.bySide === "right" ? _panelCard.x : _panelCard.x + _panelCard.width - 3
        y: 0
        width: 3
        height: parent.height
        z: NovaTheme.zFixedDrawer + 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: root._ink }
            GradientStop { position: 1.0; color: root._inkSoft }
        }
        opacity: 0.9
    }

    // 恒定 x 定位（CC-5）：不用 left/right undefined 三元锚链——
    // 该写法在 Qt 6.12 下左右锚会同时生效把面板拉伸至整宽（装配态对侧变体实测缺陷）
    Rectangle {
        id: _panelCard
        width: Math.max(200, Math.min(root.size, parent.width * 0.8 || root.size))
        height: parent.height
        x: root.bySide === "left" ? 0 : parent.width - width
        y: 0
        color: root._panel
        z: NovaTheme.zFixedDrawer
        Behavior on width {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        Behavior on x {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }

        // 内侧边界唯一垂直分隔源（CC-2；同样恒定 x，不依赖 undefined 三元）
        NovaSeparator {
            x: root.bySide === "right" ? 0 : _panelCard.width - 1
            y: 0
            width: 1
            height: _panelCard.height
            vertical: true
        }

        // ── 标题栏（高度归零 + 恒定锚链 CC-5；该边界唯一分隔源）──
        Rectangle {
            id: _titleBar
            anchors { top: parent.top; left: parent.left; right: parent.right }
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
            // 身份 B（次签名）：主色系短渐变线（替换「grabber 把手」伪控件）
            // a11y: decorative
            Rectangle {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 6 }
                width: 32; height: 3; radius: 1.5
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
            // CC-6 + 鲁棒性（坑位 20）：操作栏收起（高度 0）时 margins 自动归零，避免负高。
            Item {
                id: _actionsHost
                anchors {
                    fill: parent
                    margins: Math.max(0, Math.min(root._unit, Math.min(parent.width, parent.height) / 2))
                }
            }
        }

        Keys.onEscapePressed: root.requestClose()
        focus: true
    }

    Component.onCompleted: if (root.open) _panelCard.forceActiveFocus()
}
