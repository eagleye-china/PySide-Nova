// src/pyside_nova/qml/Nova/Composite/NovaCardGrid.qml
// NovaCardGrid 卡片网格壳：筛选工具条 + 网格骨架 + 分页状态栏（对标组件画廊 / 模板市场）
// 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）；
//   伪筛选胶囊 / 伪视图切换钮改为主色系抽象几何（CC-3）；槽位宿主独立铺满（CC-6）。
// 用法：向 filterSlot/gridSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias filterSlot: _filterHost.data
    property alias gridSlot: _grid.data
    property alias footerSlot: _footerHost.data
    property alias overlaySlot: _overlay.data

    property bool showFilter: true
    property bool showFooter: true
    property int filterHeight: 52
    property int footerHeight: 48
    property int padding: 12

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）
    readonly property int _filterH: Math.max(24, Math.min(root.filterHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _pad: Math.max(0, Math.min(root.padding, 96))

    // ── 组合上下文 CC-1 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _panel: NovaTheme.surface
    readonly property color _ink: NovaTheme.primary
    readonly property color _inkSoft: Qt.lighter(NovaTheme.primary, 1.35)
    readonly property color _inkPale: Qt.lighter(NovaTheme.primary, 1.7)

    implicitWidth: 1024
    implicitHeight: 720

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 筛选工具条（高度归零 + 恒定锚链 CC-5）──
    Rectangle {
        id: _filterWrap
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showFilter ? root._filterH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        // 身份 A（主签名）：主色系三档递减条（替换原「筛选胶囊」仿交互控件）
        // a11y: decorative
        Row {
            anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
            spacing: root._unit
            z: NovaTheme.zMarginals
            Rectangle { width: 28; height: 4; radius: 2; color: root._ink; opacity: 0.9 }
            Rectangle { width: 16; height: 4; radius: 2; color: root._inkSoft; opacity: 0.9 }
            Rectangle { width: 8; height: 4; radius: 2; color: root._inkPale; opacity: 0.9 }
        }
        // 身份 B（次签名）：抽象几何小方块（替换原「视图切换双钮」仿交互控件）
        // a11y: decorative
        Row {
            anchors { right: parent.right; rightMargin: root._gap; verticalCenter: parent.verticalCenter }
            spacing: root._unit
            z: NovaTheme.zMarginals
            Rectangle { width: 10; height: 10; radius: 2; color: root._ink; opacity: 0.9 }
            Rectangle { width: 8; height: 8; radius: 2; color: root._inkSoft; opacity: 0.9 }
        }

        Item {
            id: _filterHost
            anchors { fill: parent; leftMargin: root._gap * 7; rightMargin: root._gap * 5 }
        }
    }

    // ── 网格骨架：铺满内容区，注入顶层须 anchors.fill: parent（CC-6）──
    Item {
        id: _grid
        anchors {
            top: _filterWrap.bottom
            bottom: _footerBar.top
            left: parent.left
            right: parent.right
            margins: root._pad
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
