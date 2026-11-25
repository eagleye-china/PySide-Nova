// examples/gallery/layout_shells.qml
// Prescient Layout Shell 独立画廊：14 项组合根容器逐项真实预览 + 实时调参面板 + 明暗切换
// 满足组合宪法 0.2.0 第 8 章 Gallery 门禁：每个 Shell 独立预览、可独立加载、脱离业务、调参面板
// 运行：python examples/gallery/layout_shells.py（不侵入主画廊 main.qml）
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1180
    height: 780
    visible: true
    title: "pyside-nova · Prescient Layout Shell（14 项）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    readonly property var shellNames: [
        "NovaSidebarShell", "NovaTopNavShell", "NovaDualSideShell", "NovaTabShell",
        "NovaThreeColumnShell", "NovaCompareShell", "NovaCardGridShell", "NovaModalShell",
        "NovaDrawerPanelShell", "NovaWizardShell", "NovaBlankPageShell", "NovaDesktop",
        "NovaMobile", "NovaFlexLayout"
    ]
    readonly property var shellPages: [
        pgSidebar, pgTopNav, pgDual, pgTab, pgThreeCol, pgCompare, pgCardGrid, pgModal,
        pgDrawerPanel, pgWizard, pgBlankPage, pgDesktop, pgMobile, pgFlex
    ]

    property bool collapsed: false
    property bool showBars: true
    property int panelSize: 240

    // ── 顶栏 ──
    Rectangle {
        id: top
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 52
        color: NovaTheme.surface
        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            spacing: NovaTheme.spacingM
            Text { text: "Prescient Layout Shell"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontL; font.bold: true }
            NovaChip { text: win.shellNames.length + " 项"; outlined: true; dense: true }
        }
        NovaBtn {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            icon: NovaTheme.isDark ? "☀" : "🌙"; variant: "flat"
            onClicked: NovaTheme.toggleDark()
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

    // ── 左侧 14 项导航 ──
    Rectangle {
        id: nav
        anchors { top: top.bottom; bottom: parent.bottom; left: parent.left }
        width: 210
        color: NovaTheme.surfaceAlt
        property int currentIndex: 0
        ListView {
            objectName: "shellNav"
            anchors.fill: parent
            model: win.shellNames
            currentIndex: 0
            onCurrentIndexChanged: nav.currentIndex = currentIndex
            delegate: Item {
                width: nav.width; height: 36
                Rectangle {
                    anchors.fill: parent
                    readonly property bool isCurrent: ListView.view && ListView.view.currentIndex === index
                    color: isCurrent ? NovaTheme.primary : NovaTheme.surfaceAlt
                    opacity: isCurrent ? 0.18 : 1
                }
                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingM }
                    text: modelData; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS
                }
                MouseArea { anchors.fill: parent; onClicked: ListView.view.currentIndex = index }
            }
        }
    }

    // ── 右侧预览 + 调参 ──
    Item {
        anchors { top: top.bottom; bottom: parent.bottom; left: nav.right; right: parent.right }
        Rectangle { anchors.fill: parent; color: NovaTheme.page }

        Loader {
            id: preview
            anchors { top: parent.top; left: parent.left; right: paramPanel.left; bottom: parent.bottom }
            sourceComponent: win.shellPages[nav.currentIndex]
        }

        Rectangle {
            id: paramPanel
            anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
            width: 232
            color: NovaTheme.surface
            NovaSeparator { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } }
            Column {
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: NovaTheme.spacingM }
                spacing: NovaTheme.spacingM
                Text { text: "调参面板"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontM; font.bold: true }
                Text { text: win.shellNames[nav.currentIndex]; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "折叠/收起"; color: NovaTheme.textColor; anchors.verticalCenter: parent.verticalCenter }
                    CheckBox { checked: win.collapsed; onCheckedChanged: win.collapsed = checked }
                }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示栏"; color: NovaTheme.textColor; anchors.verticalCenter: parent.verticalCenter }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Column {
                    spacing: 4
                    Text { text: "侧栏/面板尺寸 " + win.panelSize; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider {
                        width: 200; from: 120; to: 420; stepSize: 20; value: win.panelSize
                        onValueChanged: win.panelSize = value
                    }
                }
                Text {
                    text: "所有槽位注入可视化占位块；\n左侧切换 14 个真实 Shell 骨架。\n无业务语义 · 令牌驱动 · 可独立加载。"
                    color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap
                }
            }
        }
    }

    // ── 占位块 component（复用于各槽位）──
    Component { id: slotBlock; Rectangle { color: NovaTheme.surfaceAlt; border { width: 1; color: NovaTheme.outline } } }

    // ── 14 个独立预览页 ──
    Component { id: pgSidebar; NovaSidebarShell { anchors.fill: parent; sidebarSize: win.panelSize; sidebarCollapsed: win.collapsed; showHeader: win.showBars; showFooter: win.showBars
        headerSlot: Rectangle { color: NovaTheme.primary; Text { anchors.centerIn: parent; text: "headerSlot"; color: NovaTheme.textOnPrimary } }
        sidebarSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "sidebarSlot"; color: NovaTheme.textMuted } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaSidebarShell · contentSlot"; color: NovaTheme.textColor } }
        footerSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "footerSlot"; color: NovaTheme.textMuted } } } }

    Component { id: pgTopNav; NovaTopNavShell { anchors.fill: parent; showHeader: win.showBars; showFooter: win.showBars
        headerSlot: Rectangle { color: NovaTheme.primary; Text { anchors.centerIn: parent; text: "一级导航 headerSlot"; color: NovaTheme.textOnPrimary } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaTopNavShell"; color: NovaTheme.textColor } } } }

    Component { id: pgDual; NovaDualSideShell { anchors.fill: parent; leftSize: win.panelSize; rightSize: win.panelSize; leftCollapsed: win.collapsed; showFooter: win.showBars
        leftSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "leftSlot"; color: NovaTheme.textMuted } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaDualSideShell"; color: NovaTheme.textColor } }
        rightSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "rightSlot"; color: NovaTheme.textMuted } } } }

    Component { id: pgTab; NovaTabShell { anchors.fill: parent; showTabBar: win.showBars; showFooter: win.showBars
        tabBarSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "Tab 1 | Tab 2 | Tab 3"; color: NovaTheme.textColor } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaTabShell"; color: NovaTheme.textColor } } } }

    Component { id: pgThreeCol; NovaThreeColumnShell { anchors.fill: parent; treeSize: win.panelSize; detailSize: win.panelSize; showHeader: win.showBars
        treeSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "treeSlot"; color: NovaTheme.textMuted } }
        listSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "listSlot"; color: NovaTheme.textColor } }
        detailSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "detailSlot"; color: NovaTheme.textMuted } } } }

    Component { id: pgCompare; NovaCompareShell { anchors.fill: parent; showControl: win.showBars; showFooter: win.showBars
        controlSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "对比控制栏"; color: NovaTheme.textColor } }
        leftSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "leftSlot"; color: NovaTheme.textMuted } }
        rightSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "rightSlot"; color: NovaTheme.textMuted } } } }

    Component { id: pgCardGrid; NovaCardGridShell { anchors.fill: parent; showFilter: win.showBars; showFooter: win.showBars
        filterSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "筛选 / 搜索"; color: NovaTheme.textColor } }
        gridSlot: Grid {
            anchors.fill: parent; spacing: 8; columns: 3
            Repeater { model: 9; Rectangle { width: 140; height: 90; radius: NovaTheme.radiusM; color: NovaTheme.surface; border { width: 1; color: NovaTheme.outline } } }
        } } }

    Component { id: pgModal; Item { anchors.fill: parent
        NovaBlankPageShell { anchors.fill: parent; contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaModalShell（点按钮打开）"; color: NovaTheme.textColor }
            NovaBtn { anchors.centerIn: parent; text: "打开模态壳"; onClicked: m.open = true } } }
        NovaModalShell { id: m; open: false; titleSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "标题"; color: NovaTheme.textColor } }
            contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "模态内容槽"; color: NovaTheme.textColor } }
            actionsSlot: Rectangle { color: NovaTheme.surface; NovaBtn { anchors.centerIn: parent; text: "关闭"; onClicked: m.open = false } } } } }

    Component { id: pgDrawerPanel; Item { anchors.fill: parent
        NovaBlankPageShell { anchors.fill: parent; contentSlot: Rectangle { color: NovaTheme.page; NovaBtn { anchors.centerIn: parent; text: "打开侧滑面板"; onClicked: d.open = true } } }
        NovaDrawerPanelShell { id: d; open: false; size: win.panelSize; scrim: true; side: "right"
            titleSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "属性面板"; color: NovaTheme.textColor } }
            contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "contentSlot"; color: NovaTheme.textColor } } } } }

    Component { id: pgWizard; NovaWizardShell { anchors.fill: parent; stepCount: 4; currentStep: 1; showSteps: win.showBars
        stepsSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "① ─ ② ─ ③ ─ ④"; color: NovaTheme.primary } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaWizardShell · 步骤内容"; color: NovaTheme.textColor } }
        controlsSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "上一步 | 下一步"; color: NovaTheme.textColor } } } }

    Component { id: pgBlankPage; NovaBlankPageShell { anchors.fill: parent; showHeader: win.showBars; showFooter: win.showBars
        headerSlot: Rectangle { color: NovaTheme.primary; Text { anchors.centerIn: parent; text: "Header"; color: NovaTheme.textOnPrimary } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaBlankPageShell · 纯净单页"; color: NovaTheme.textColor } } } }

    Component { id: pgDesktop; NovaDesktop { anchors.fill: parent; showMenu: win.showBars; showToolbar: win.showBars; showStatus: win.showBars
        pageSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaDesktop · 桌面根壳"; color: NovaTheme.textColor } } } }

    Component { id: pgMobile; NovaMobile { anchors.fill: parent; width: Math.min(390, parent.width); anchors.horizontalCenter: parent.horizontalCenter
        showHeader: win.showBars; showBottomNav: win.showBars; safeTop: 24; safeBottom: 16
        headerSlot: Rectangle { color: NovaTheme.primary; Text { anchors.centerIn: parent; text: "Mobile Header"; color: NovaTheme.textOnPrimary } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaMobile"; color: NovaTheme.textColor } }
        bottomNavSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "◉ 导航"; color: NovaTheme.textColor } } } }

    Component { id: pgFlex; NovaFlexLayout { anchors.fill: parent; columns: 3; showHeader: win.showBars
        headerSlot: Rectangle { color: NovaTheme.primary; Text { anchors.centerIn: parent; text: "大屏 Header"; color: NovaTheme.textOnPrimary } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaFlexLayout · 3 栏"; color: NovaTheme.textColor } } } }
}
