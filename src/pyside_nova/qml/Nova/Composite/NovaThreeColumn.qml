// src/pyside_nova/qml/Nova/Composite/NovaThreeColumn.qml
// NovaThreeColumn 三栏工作台壳：目录树 / 中列表 / 详情，三级深度色阶（对标资源管理器布局）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）；
//   深色顶条与 primary→secondary 渐变收敛主色系、伪 grip 改抽象短条（CC-3）；槽位宿主独立铺满（CC-6）。
// 用法：向 treeSlot/listSlot/detailSlot/headerSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias treeSlot: _treeHost.data
    property alias listSlot: _list.content
    property alias detailSlot: _detailHost.data
    property alias headerSlot: _headerHost.data
    property alias footerSlot: _footerHost.data
    property alias overlaySlot: _overlay.data

    property real treeSize: 220
    property real detailSize: 320
    property bool showHeader: true
    property bool showFooter: false
    property int headerHeight: 56
    property int footerHeight: 48
    property bool bordered: true

    signal columnResized(string column, real size)

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）
    readonly property real _tw: Math.max(120, Math.min(root.treeSize, width / 4 || root.treeSize))
    readonly property real _dw: Math.max(160, Math.min(root.detailSize, width / 3 || root.detailSize))
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))

    // ── 组合上下文 CC-1 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    readonly property color _ink: NovaTheme.primary
    readonly property color _inkSoft: Qt.lighter(NovaTheme.primary, 1.35)

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 顶栏（高度归零 + 恒定锚链 CC-5）──
    Rectangle {
        id: _headerBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showHeader ? root._headerH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        NovaHeader {
            id: _header
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root._headerH
            tint: root._panel
        }
        Item {
            id: _headerHost
            anchors { fill: _header; leftMargin: root._gap; rightMargin: root._gap }
        }
    }

    // ── 第 1 级（深）：目录树栏；宽度变化共用 _dur/_ease ──
    Rectangle {
        id: _treeWrap
        anchors { top: _headerBar.bottom; bottom: _footerBar.top; left: parent.left }
        width: root._tw
        color: root._rail
        Behavior on width {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        // 身份 A（主签名）：主色系顶条（替换原 NovaTheme.dark 硬件黑）
        // a11y: decorative
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 4
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root._ink }
                GradientStop { position: 1.0; color: root._inkSoft }
            }
            opacity: 0.9
            z: NovaTheme.zMarginals
        }
        Item {
            id: _treeHost
            anchors { fill: parent; margins: root._gap; topMargin: root._gap }
        }
    }

    // 边界 1：唯一垂直分隔源 + 抽象短条（不仿可拖拽 grip，CC-3）
    NovaSeparator {
        id: _s1
        anchors { top: _headerBar.bottom; bottom: _footerBar.top; left: _treeWrap.right }
        vertical: true
        visible: root.bordered
        z: NovaTheme.zMarginals
        Rectangle {
            anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            width: 3; height: 24; radius: 1.5
            color: root._ink
            opacity: 0.9
        }
    }

    // 第 2 级（中）：列表区
    NovaPage {
        id: _list
        anchors {
            top: _headerBar.bottom
            bottom: _footerBar.top
            left: _s1.right
            right: _s2.left
        }
        padding: 0
    }

    // 边界 2：唯一垂直分隔源 + 抽象短条（主色系浅档）
    NovaSeparator {
        id: _s2
        anchors { top: _headerBar.bottom; bottom: _footerBar.top; right: _detailWrap.left }
        vertical: true
        visible: root.bordered
        z: NovaTheme.zMarginals
        Rectangle {
            anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            width: 3; height: 24; radius: 1.5
            color: root._inkSoft
            opacity: 0.9
        }
    }

    // ── 第 3 级（浅/浮起）：详情栏 ──
    Rectangle {
        id: _detailWrap
        anchors { top: _headerBar.bottom; bottom: _footerBar.top; right: parent.right }
        width: root._dw
        color: root._panel
        Behavior on width {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        // 身份 B（次签名）：单色系渐变发丝（替换原 primary→secondary 撞色）
        // a11y: decorative
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 3
            z: NovaTheme.zMarginals
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root._inkSoft }
                GradientStop { position: 1.0; color: root._ink }
            }
            opacity: 0.9
        }
        Item {
            id: _detailHost
            anchors { fill: parent; margins: root._gap; topMargin: root._gap }
        }
    }

    // ── 底栏（高度归零 + 恒定锚链；该边界唯一分隔源）──
    Rectangle {
        id: _footerBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: root.showFooter ? root._footerH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }

        NovaFooter {
            id: _footer
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: root._footerH
            tint: root._panel
        }
        Item {
            id: _footerHost
            anchors { fill: _footer; leftMargin: root._gap; rightMargin: root._gap }
        }
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
