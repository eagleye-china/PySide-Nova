// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaThreeColumn.qml
// NovaThreeColumn 三栏工作台壳：目录树 / 中列表 / 详情，三级深度色阶（对标资源管理器布局）
// NovaThreeColumn —— 文档阅读器 / 图标画廊 / API 工作台组合根容器；以"三级色阶"为身份语言
// 用法：向 treeSlot/listSlot/detailSlot/headerSlot/footerSlot/overlaySlot 注入业务内容；columnResized 为受控拖拽意图出口
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root
    // 鲁棒性 / i18n：声明式容器随 RTL 镜像；逻辑侧槽位语义恒定（宪法第 7 章第 3 条）
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias treeSlot: _tree.data
    property alias listSlot: _list.content
    property alias detailSlot: _detail.data
    property alias headerSlot: _header.data
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property real treeSize: 220
    property real detailSize: 320
    property bool showHeader: true
    property bool showFooter: false
    property int headerHeight: 56
    property int footerHeight: 48
    property bool bordered: true

    signal columnResized(string column, real size)

    readonly property real _tw: Math.max(120, Math.min(root.treeSize, width / 4 || root.treeSize))
    readonly property real _dw: Math.max(160, Math.min(root.detailSize, width / 3 || root.detailSize))

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    NovaHeader {
        id: _header
        visible: root.showHeader
        height: root._headerH
        anchors { top: parent.top; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    // ── 身份元素：三级深度色阶 ──
    // 第 1 级（最深）：目录树栏
    Rectangle {
        id: _treeWrap
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left
        }
        width: root._tw
        color: NovaTheme.surfaceAlt

        // 树栏顶部标识（深色一寸 + 三色点，纯装饰）
        // a11y: decorative
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 4
            color: NovaTheme.dark
            opacity: 0.9
            z: NovaTheme.zMarginals
        }
        Item { id: _tree; anchors { fill: parent; topMargin: 4 } }
    }

    NovaSeparator {
        id: _s1
        anchors { top: _treeWrap.top; bottom: _treeWrap.bottom; left: _treeWrap.right }
        vertical: true
        visible: root.bordered
        z: NovaTheme.zMarginals
        enabled: true
        HoverHandler { cursorShape: Qt.SplitHCursor }
        // 分隔中部拖拽 grip（纯装饰）
        // a11y: decorative
        Rectangle {
            anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            width: 4; height: 24; radius: 2
            color: NovaTheme.outlineStrong
            opacity: 0.9
        }
    }

    // 第 2 级（中）：列表区
    NovaPage {
        id: _list
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: _s1.right
            right: _s2.left
        }
        padding: NovaTheme.spacingM
    }

    NovaSeparator {
        id: _s2
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            right: _detailWrap.left
        }
        vertical: true
        visible: root.bordered
        z: NovaTheme.zMarginals
        HoverHandler { cursorShape: Qt.SplitHCursor }
        // a11y: decorative
        Rectangle {
            anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            width: 4; height: 24; radius: 2
            color: NovaTheme.outlineStrong
            opacity: 0.9
        }
    }

    // 第 3 级（浅/浮起）：详情栏
    Rectangle {
        id: _detailWrap
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            right: parent.right
        }
        width: root._dw
        color: NovaTheme.surface

        // 详情栏顶部 accent 发丝（身份点缀）
        // a11y: decorative
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 3
            z: NovaTheme.zMarginals
            gradient: Gradient {
                GradientStop { position: 0.0; color: NovaTheme.primary }
                GradientStop { position: 1.0; color: NovaTheme.secondary }
            }
        }
        Item { id: _detail; anchors { fill: parent; topMargin: 3 } }
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root._footerH
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
