// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaFlexLayout.qml
// NovaFlexLayout 企业大屏弹性布局壳：columns 驱动的浮起面板网格 + 自适应分栏 + 动态缩放（HMI / 工控大屏）
// NovaFlexLayout —— 多端根壳之企业大屏；以"浮起面板网格"为身份语言，区别于桌面 / 移动根壳
// 用法：向 headerSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；columns 与断点驱动分栏，缩放取 NovaScreen
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root
    // 鲁棒性 / i18n：声明式容器随 RTL 镜像；逻辑侧槽位语义恒定（宪法第 7 章第 3 条）
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias headerSlot: _header.data
    property alias contentSlot: _body.content
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property bool showHeader: true
    property bool showFooter: false
    property int columns: 3            // 1~4 分栏数，钳制防非法入参
    property int headerHeight: 64
    property int footerHeight: 48
    property int gap: 8
    property bool scalable: true

    signal layoutChanged(int columns)

    readonly property int _cols: Math.max(1, Math.min(4, root.columns))
    readonly property bool _largeScreen: NovaScreen.gtLg

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _gap: Math.max(0, Math.min(root.gap, 64))

    implicitWidth: 1920
    implicitHeight: 1080

    onColumnsChanged: root.layoutChanged(root._cols)

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    NovaHeader {
        id: _header
        visible: root.showHeader
        height: root._headerH
        anchors { top: parent.top; left: parent.left; right: parent.right }
        tint: NovaTheme.surface

        // 身份元素：大屏品牌渐变底线（身份点缀）
        // a11y: decorative
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 3
            gradient: Gradient {
                GradientStop { position: 0.0; color: NovaTheme.primary }
                GradientStop { position: 0.5; color: NovaTheme.secondary }
                GradientStop { position: 1.0; color: NovaTheme.accent }
            }
        }
    }

    // ── 身份元素：columns 驱动的浮起面板网格骨架 ──
    // 面板表面作为底；顶条提级到内容之上，确保业务注入内容铺满时身份仍可见
    // a11y: decorative
    Row {
        id: _panelGrid
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left; right: parent.right
            margins: root._gap
        }
        spacing: root._gap
        Repeater {
            model: root._cols
            Rectangle {
                required property int index
                width: (parent.width - (root._cols - 1) * root._gap) / root._cols
                height: parent.height
                radius: NovaTheme.radiusM
                color: NovaTheme.surface
                border { width: 1; color: NovaTheme.outline }
            }
        }
    }

    // 面板顶条覆盖层（z 高于内容槽，身份色条恒可见）
    // a11y: decorative
    Row {
        anchors { fill: _panelGrid }
        spacing: root._gap
        z: NovaTheme.zMarginals
        Repeater {
            model: root._cols
            Rectangle {
                required property int index
                width: (parent.width - (root._cols - 1) * root._gap) / root._cols
                height: 3
                color: index === 0 ? NovaTheme.primary
                      : (index === 1 ? NovaTheme.secondary : NovaTheme.accent)
                opacity: 0.9
            }
        }
    }

    NovaPage {
        id: _body
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left; right: parent.right
        }
        padding: root._gap
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root._footerH
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zMax }
}
