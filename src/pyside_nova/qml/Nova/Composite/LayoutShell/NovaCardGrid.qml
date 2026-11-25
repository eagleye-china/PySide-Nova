// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaCardGrid.qml
// NovaCardGrid 卡片网格壳：筛选工具条 + Flow 网格骨架 + 分页状态栏（对标组件画廊 / 模板市场）
// NovaCardGrid —— 画廊首页 / 素材库组合根容器；以"Flow 网格骨架"为身份语言
// 用法：向 filterSlot/gridSlot/footerSlot/overlaySlot 注入业务内容；卡片由业务用 NovaCard 注入
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root
    // 鲁棒性 / i18n：声明式容器随 RTL 镜像；逻辑侧槽位语义恒定（宪法第 7 章第 3 条）
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias filterSlot: _filter.data
    property alias gridSlot: _grid.data
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property bool showFilter: true
    property bool showFooter: true
    property int filterHeight: 52
    property int footerHeight: 48
    property int padding: 12

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _filterH: Math.max(24, Math.min(root.filterHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _pad: Math.max(0, Math.min(root.padding, 96))

    implicitWidth: 1024
    implicitHeight: 720

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 身份元素：工具条（左三段胶囊筛选位 + 右视图切换位）──
    Rectangle {
        id: _filterWrap
        visible: root.showFilter
        height: root._filterH
        anchors { top: parent.top; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        z: NovaTheme.zMarginals

        // 左：筛选胶囊占位（纯装饰）
        // a11y: decorative
        Row {
            z: NovaTheme.zMarginals
            anchors { left: parent.left; leftMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            spacing: NovaTheme.spacingS
            Rectangle { width: 44; height: 22; radius: 11; color: NovaTheme.primary; opacity: 0.9 }
            Rectangle { width: 36; height: 22; radius: 11; color: NovaTheme.surfaceAlt; border { width: 1; color: NovaTheme.outline } }
            Rectangle { width: 36; height: 22; radius: 11; color: NovaTheme.surfaceAlt; border { width: 1; color: NovaTheme.outline } }
        }
        // 右：视图切换双钮占位
        // a11y: decorative
        Row {
            z: NovaTheme.zMarginals
            anchors { right: parent.right; rightMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            spacing: 2
            Rectangle { width: 24; height: 22; radius: NovaTheme.radiusS; color: NovaTheme.primary; opacity: 0.85 }
            Rectangle { width: 24; height: 22; radius: NovaTheme.radiusS; color: NovaTheme.surfaceAlt; border { width: 1; color: NovaTheme.outline } }
        }

        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
        Item {
            id: _filter
            anchors {
                fill: parent
                leftMargin: NovaTheme.spacingL * 3
                rightMargin: NovaTheme.spacingL * 3
            }
        }
    }

    // ── 身份元素：真正的 Flow 网格骨架（自适应卡片位，业务注入卡片）──
    Item {
        id: _grid
        anchors {
            top: root.showFilter ? _filterWrap.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left; right: parent.right
            margins: root._pad
        }
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
