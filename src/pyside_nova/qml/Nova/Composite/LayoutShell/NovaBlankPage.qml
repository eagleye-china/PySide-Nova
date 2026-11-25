// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaBlankPage.qml
// NovaBlankPage 纯净单页壳：居中阅读栏 + Header + Content + Footer，最克制的可定制基底（无侧栏 / 无标签导航）
// NovaBlankPage —— 独立小工具 / 子页面 / 高级用户自定义布局基底；以"居中阅读栏"为身份语言
// 用法：向 headerSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；Shell 仅提供三区布局与令牌底色
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
    property bool showFooter: true
    property int headerHeight: 56
    property int footerHeight: 48
    property int padding: 24

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _pad: Math.max(0, Math.min(root.padding, 96))

    implicitWidth: 800
    implicitHeight: 600

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    NovaHeader {
        id: _header
        visible: root.showHeader
        height: root._headerH
        anchors { top: parent.top; left: parent.left; right: parent.right }
        tint: NovaTheme.surface

        // 身份元素：极细居中发丝（克制到极致，仅一点品牌暗示）
        // a11y: decorative
        Rectangle {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            width: 32; height: 1
            color: NovaTheme.primary
            opacity: 0.9
            z: NovaTheme.zMarginals
        }
    }

    // ── 身份元素：居中阅读栏（最大宽度约束，左右优雅留白）──
    Rectangle {
        id: _readingColumn
        anchors {
            top: root.showHeader ? _header.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            horizontalCenter: parent.horizontalCenter
            leftMargin: NovaTheme.spacingL
            rightMargin: NovaTheme.spacingL
        }
        width: Math.max(0, Math.min(parent.width - NovaTheme.spacingL * 2, 880))
        color: NovaTheme.surface
        radius: NovaTheme.radiusM
        border { width: 1; color: NovaTheme.outline }

        NovaPage {
            id: _body
            anchors.fill: parent
            padding: root._pad
        }
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root._footerH
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface

        // a11y: decorative
        Rectangle {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            width: 32; height: 1
            color: NovaTheme.outlineStrong
            opacity: 0.9
            z: NovaTheme.zMarginals
        }
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
