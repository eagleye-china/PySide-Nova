// examples/gallery/layout_shells.qml
// 组合根容器独立画廊：20 项逐项真实预览 + 实时调参面板 + 明暗切换（含 NovaChat / NovaAgent / NovaDE / NovaCopilot / NovaOrbit / NovaIncubator）
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
    title: "pyside-nova · 组合根容器（20 项 · 含四个 AI 智能组合根 / 意图轨道工作台 / 应用孵化器工作台）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    readonly property var shellNames: [
        "NovaSidebar", "NovaTopNavigation", "NovaDualSide", "NovaTabShell",
        "NovaThreeColumn", "NovaCompare", "NovaCardGrid", "NovaModal",
        "NovaDrawerPanel", "NovaSetupWizard",         "NovaBlankPage", "NovaDesktop",
        "NovaMobile", "NovaFlexLayout", "NovaChat",
        "NovaAgent", "NovaDE", "NovaCopilot", "NovaOrbit", "NovaIncubator"
    ]
    readonly property var shellPages: [
        pgSidebar, pgTopNavigation, pgDual, pgTab, pgThreeCol, pgCompare, pgCardGrid, pgModal,
        pgDrawerPanel, pgSetupWizard, pgBlankPage, pgDesktop, pgMobile, pgFlex, pgChat,
        pgAgent, pgDE, pgCopilot, pgOrbit, pgIncubator
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

    // ── 左侧 20 项导航 ──
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
                    text: "所有槽位注入可视化占位块；\n左侧切换 19 个真实组合根容器。\n无业务语义 · 令牌驱动 · 可独立加载。"
                    color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap
                }
            }
        }
    }

    // ── 占位块 component（复用于各槽位）──
    Component { id: slotBlock; Rectangle { color: NovaTheme.surfaceAlt; border { width: 1; color: NovaTheme.outline } } }

    // ── 19 个独立预览页（15 GA + 4 增量）──
    Component { id: pgSidebar; NovaSidebar { anchors.fill: parent; sidebarSize: win.panelSize; sidebarCollapsed: win.collapsed; showHeader: win.showBars; showFooter: win.showBars
        headerSlot: Rectangle { color: NovaTheme.primary; Text { anchors.centerIn: parent; text: "headerSlot"; color: NovaTheme.textOnPrimary } }
        sidebarSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "sidebarSlot"; color: NovaTheme.textMuted } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaSidebar · contentSlot"; color: NovaTheme.textColor } }
        footerSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "footerSlot"; color: NovaTheme.textMuted } } } }

    Component { id: pgTopNavigation; NovaTopNavigation { anchors.fill: parent; showHeader: win.showBars; showFooter: win.showBars
        headerSlot: Rectangle { color: NovaTheme.primary; Text { anchors.centerIn: parent; text: "一级导航 headerSlot"; color: NovaTheme.textOnPrimary } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaTopNavigation"; color: NovaTheme.textColor } } } }

    Component { id: pgDual; NovaDualSide { anchors.fill: parent; leftSize: win.panelSize; rightSize: win.panelSize; leftCollapsed: win.collapsed; showFooter: win.showBars
        leftSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "leftSlot"; color: NovaTheme.textMuted } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaDualSide"; color: NovaTheme.textColor } }
        rightSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "rightSlot"; color: NovaTheme.textMuted } } } }

    Component { id: pgTab; NovaTabShell { anchors.fill: parent; showTabBar: win.showBars; showFooter: win.showBars
        tabBarSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "Tab 1 | Tab 2 | Tab 3"; color: NovaTheme.textColor } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaTabShell"; color: NovaTheme.textColor } } } }

    Component { id: pgThreeCol; NovaThreeColumn { anchors.fill: parent; treeSize: win.panelSize; detailSize: win.panelSize; showHeader: win.showBars
        treeSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "treeSlot"; color: NovaTheme.textMuted } }
        listSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "listSlot"; color: NovaTheme.textColor } }
        detailSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "detailSlot"; color: NovaTheme.textMuted } } } }

    Component { id: pgCompare; NovaCompare { anchors.fill: parent; showControl: win.showBars; showFooter: win.showBars
        controlSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "对比控制栏"; color: NovaTheme.textColor } }
        leftSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "leftSlot"; color: NovaTheme.textMuted } }
        rightSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "rightSlot"; color: NovaTheme.textMuted } } } }

    Component { id: pgCardGrid; NovaCardGrid { anchors.fill: parent; showFilter: win.showBars; showFooter: win.showBars
        filterSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "筛选 / 搜索"; color: NovaTheme.textColor } }
        gridSlot: Grid {
            anchors.fill: parent; spacing: 8; columns: 3
            Repeater { model: 9; Rectangle { width: 140; height: 90; radius: NovaTheme.radiusM; color: NovaTheme.surface; border { width: 1; color: NovaTheme.outline } } }
        } } }

    Component { id: pgModal; Item { anchors.fill: parent
        NovaBlankPage { anchors.fill: parent; contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaModal（点按钮打开）"; color: NovaTheme.textColor }
            NovaBtn { anchors.centerIn: parent; text: "打开模态壳"; onClicked: m.open = true } } }
        NovaModal { id: m; open: false; titleSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "标题"; color: NovaTheme.textColor } }
            contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "模态内容槽"; color: NovaTheme.textColor } }
            actionsSlot: Rectangle { color: NovaTheme.surface; NovaBtn { anchors.centerIn: parent; text: "关闭"; onClicked: m.open = false } } } } }

    Component { id: pgDrawerPanel; Item { anchors.fill: parent
        NovaBlankPage { anchors.fill: parent; contentSlot: Rectangle { color: NovaTheme.page; NovaBtn { anchors.centerIn: parent; text: "打开侧滑面板"; onClicked: d.open = true } } }
        NovaDrawerPanel { id: d; open: false; size: win.panelSize; scrim: true; side: "right"
            titleSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "属性面板"; color: NovaTheme.textColor } }
            contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "contentSlot"; color: NovaTheme.textColor } } } } }

    Component { id: pgSetupWizard; NovaSetupWizard { anchors.fill: parent; stepCount: 4; currentStep: 1; showSteps: win.showBars
        stepsSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "① ─ ② ─ ③ ─ ④"; color: NovaTheme.primary } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaSetupWizard · 步骤内容"; color: NovaTheme.textColor } }
        controlsSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "上一步 | 下一步"; color: NovaTheme.textColor } } } }

    Component { id: pgBlankPage; NovaBlankPage { anchors.fill: parent; showHeader: win.showBars; showFooter: win.showBars
        headerSlot: Rectangle { color: NovaTheme.primary; Text { anchors.centerIn: parent; text: "Header"; color: NovaTheme.textOnPrimary } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "NovaBlankPage · 纯净单页"; color: NovaTheme.textColor } } } }

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

    Component { id: pgChat; NovaChat { anchors.fill: parent; navSize: 56; conversationSize: win.panelSize; detailSize: win.panelSize
        conversationCollapsed: win.collapsed; detailCollapsed: win.collapsed
        showNav: win.showBars; showHeader: win.showBars; showComposer: win.showBars
        navSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "▤"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontL } }
        conversationSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "会话列表"; color: NovaTheme.textMuted } }
        headerSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "NovaChat · WorkBuddy 主窗口"; color: NovaTheme.textColor } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "对话区（注入 NovaChatMessage 气泡）"; color: NovaTheme.textColor } }
        composerSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "输入区 / 工具栏"; color: NovaTheme.textMuted } }
        detailSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "详情 / 上下文"; color: NovaTheme.textMuted } } } }

    // ── 1.1.0 四个 AI 智能组合根（调参页占位块，与独立 showcase 分工）──
    Component { id: pgAgent; NovaAgent { anchors.fill: parent; taskSize: win.panelSize; verifySize: win.panelSize
        taskCollapsed: win.collapsed; verifyCollapsed: win.collapsed
        showTask: win.showBars; showPlan: win.showBars; showApproval: win.showBars
        taskSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "任务列 / DAG"; color: NovaTheme.textMuted } }
        planSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "NovaAgent · 编排规划"; color: NovaTheme.textColor } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "执行画布（注入 DAG 节点）"; color: NovaTheme.textColor } }
        approvalSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "审批闸门 · HIGH 风险复核"; color: NovaTheme.textMuted } }
        verifySlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "外部信号验证轨"; color: NovaTheme.textMuted } } } }

    Component { id: pgDE; NovaDE { anchors.fill: parent; queueSize: win.panelSize; slaSize: win.panelSize
        queueCollapsed: win.collapsed; slaCollapsed: win.collapsed
        showQueue: win.showBars; showRole: win.showBars; showHandoff: win.showBars
        roleSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "NovaDE · 岗位条（应付单据处理）"; color: NovaTheme.primary } }
        queueSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "任务队列"; color: NovaTheme.textMuted } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "工作画布（跨系统处理）"; color: NovaTheme.textColor } }
        slaSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "SLA / 队伍治理轨"; color: NovaTheme.textMuted } }
        handoffSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "人工交接条 · Auto/Draft/Handoff"; color: NovaTheme.textMuted } } } }

    Component { id: pgCopilot; NovaCopilot { anchors.fill: parent; suggestSize: win.panelSize; gateSize: win.panelSize
        suggestCollapsed: win.collapsed; gateCollapsed: win.collapsed
        showSuggest: win.showBars; showInline: win.showBars; showGate: win.showBars
        inlineSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "NovaCopilot · 内联建议条"; color: NovaTheme.primary } }
        suggestSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "建议列"; color: NovaTheme.textMuted } }
        contentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "工作画布（grounding 上下文）"; color: NovaTheme.textColor } }
        gateSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "动作闸门 · 确认/撤销"; color: NovaTheme.textMuted } } } }

    // ── 1.1.0 第 19 个组合根 · NovaOrbit 意图轨道工作台（七槽占位预览）──
    Component { id: pgOrbit; NovaOrbit { anchors.fill: parent; railSize: win.panelSize; canvasSize: win.panelSize
        railCollapsed: win.collapsed; canvasCollapsed: win.collapsed
        showGlobal: win.showBars; showRail: win.showBars; showCanvas: win.showBars; showComposer: win.showBars; showMap: win.showBars
        globalSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "NovaChat 全局栏 · 身份/租户/搜索"; color: NovaTheme.textColor } }
        railSlot: Rectangle { color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "Orbit Rail · 轨道态势/感知信号"; color: NovaTheme.textMuted } }
        intentSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "Intent Field · 多轨道并行意图场"; color: NovaTheme.textColor } }
        composerSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "统一意图输入栏 · 轨道调度器"; color: NovaTheme.textMuted } }
        canvasSlot: Rectangle { color: NovaTheme.page; Text { anchors.centerIn: parent; text: "Live Canvas · 活产物画布"; color: NovaTheme.textColor } }
        mapSlot: Rectangle { color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "全局轨道地图 · 拓扑视图"; color: NovaTheme.textMuted } }
        overlaySlot: Item {} } }

    // ── 1.2.0 第 20 个组合根 · NovaIncubator 应用孵化器工作台（七槽占位预览 · 本库最后一个组合组件）──
    Component { id: pgIncubator; NovaIncubator { anchors.fill: parent; recipeSize: win.panelSize; validateSize: win.panelSize
        recipeCollapsed: win.collapsed; validateCollapsed: win.collapsed
        showGlobal: win.showBars; showRecipe: win.showBars; showValidate: win.showBars; showPipeline: win.showBars; showCertificate: win.showBars
        globalSlot: Rectangle { anchors.fill: parent; color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "全局栏 · 身份/配方代号/封版状态"; color: NovaTheme.textColor } }
        recipeSlot: Rectangle { anchors.fill: parent; color: NovaTheme.surfaceAlt; Text { anchors.centerIn: parent; text: "配方库 · R1–R5 五套首发配方"; color: NovaTheme.textMuted } }
        stageSlot: Rectangle { anchors.fill: parent; color: NovaTheme.page; Text { anchors.centerIn: parent; text: "孵化舞台 · 七区配方契约"; color: NovaTheme.textColor } }
        pipelineSlot: Rectangle { anchors.fill: parent; color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "CARF 四阶段条 · 构想/实现/打磨/封版"; color: NovaTheme.textMuted } }
        validateSlot: Rectangle { anchors.fill: parent; color: NovaTheme.page; Text { anchors.centerIn: parent; text: "三重校验 · 配方/契约/门禁"; color: NovaTheme.textColor } }
        certificateSlot: Rectangle { anchors.fill: parent; color: NovaTheme.surface; Text { anchors.centerIn: parent; text: "封版证书 · 五件套预览"; color: NovaTheme.textMuted } }
        overlaySlot: Item {} } }
}
