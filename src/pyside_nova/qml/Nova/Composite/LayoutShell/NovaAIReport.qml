// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaAIReport.qml
// NovaAIReport 智能报表工作台壳：对标带 + 诊断轨 + 主报表区 + 预测区间带 + 问数轨 + 审批闸门 + 浮层
// 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全槽共享；
//   相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（对标游标尺 / 因果鱼骨 /
//   行列刻度尺 / 置信区间带 / 问数双点 / 闸门横闩 / 单色系发丝），不仿交互控件、不撞色；
//   折叠锚链恒定，栏高归零而非 visible 三元切换。
// 用法：向 benchmarkSlot/diagnosisSlot/reportSlot/forecastSlot/querySlot/approvalSlot/overlaySlot
//   注入业务内容；Shell 只托管布局与折叠意图，不含参数语义层、归因引擎、预测模型、
//   NL2SQL 映射器、Agent 编排等业务语义。主报表区推荐注入 NovaDataGrid。
// 治理边界（封版法源）：对标基线 / 归因七元组 / 预测区间 / 问数逻辑 / 人工确认闸门
//   全由业务槽位注入；Shell 仅以 approvalSlot 预留确认闸门呈现位，绝不自动执行。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）；语义由注入内容承担
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    // ── 七个槽位（第 4 章 alias 机制；业务内容全部由宿主注入）──
    property alias benchmarkSlot: _benchmark.data
    property alias diagnosisSlot: _diagnosis.content
    property alias reportSlot: _report.content
    property alias forecastSlot: _forecast.data
    property alias querySlot: _query.content
    property alias approvalSlot: _approval.data
    property alias overlaySlot: _overlay.data

    // ── 配置属性（默认值来自令牌，进冻结面）──
    property real diagnosisSize: 300
    property real querySize: 340
    property int benchmarkHeight: 64
    property int forecastHeight: 96
    property int approvalHeight: 180
    property bool showBenchmark: true
    property bool showDiagnosis: true
    property bool showForecast: true
    property bool showQuery: true
    property bool showApproval: true
    property bool diagnosisCollapsed: false
    property bool queryCollapsed: false
    property int breakpoint: 1180
    property bool bordered: true

    // ── 受控契约：只 emit，不自写宿主状态 ──
    signal diagnosisToggled(bool collapsed)
    signal queryToggled(bool collapsed)
    signal approvalRequested()
    function toggleDiagnosis() { root.diagnosisToggled(!root.diagnosisCollapsed) }
    function toggleQuery() { root.queryToggled(!root.queryCollapsed) }
    function requestApproval() { root.approvalRequested() }

    readonly property bool belowBreakpoint: width > 0 && width < root.breakpoint

    implicitWidth: 1440
    implicitHeight: 900

    // 非法入参钳制（宪法第 7 章第 1 条）：极端值下几何有限非负，栏高下界取 24
    readonly property real _diagnosisW: Math.max(180, Math.min(root.diagnosisSize, width / 3 || root.diagnosisSize))
    readonly property real _queryW: Math.max(220, Math.min(root.querySize, width / 3 || root.querySize))
    readonly property int _benchmarkH: Math.max(24, Math.min(root.benchmarkHeight, 240))
    readonly property int _forecastH: Math.max(24, Math.min(root.forecastHeight, 360))
    readonly property int _approvalH: Math.max(24, Math.min(root.approvalHeight, 480))

    // ── 组合上下文 CC-1：全槽唯一密度 / 层级 / 动效 / 品牌色基准 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _railBg: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    // 应用身份图标（qrc:/icons/app-aireport.svg；私有 _ 前缀不进冻结面，decorative）
    readonly property url _appIcon: "qrc:/icons/app-aireport"
    // ── 专属主题 · 仪表钢蓝（色相 258°，偏移 +0.0694 ≈ +25°；CC-3 组件内单色相）──
    // 智能报表 · 冷静精确的钢蓝；色相随 setBrand 漂移，饱和/明度系数独立定制
    // _signatureOn：true=专属色相（默认）/ false=回归全局品牌蓝（亮色态）；私有令牌不进冻结面
    property bool _signatureOn: true
    readonly property real _themeHue: root._signatureOn
        ? (NovaTheme.primary.hsvHue + 0.0694 + 1) % 1
        : NovaTheme.primary.hsvHue
    readonly property color _accent: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 0.95),
        Math.min(1, NovaTheme.primary.hsvValue * (NovaTheme.isDark ? 1.22 : 1)), 1)
    readonly property color _ink: root._accent
    readonly property color _inkSoft: Qt.lighter(root._accent, 1.35)
    // ── Aurora Core · 极光核辉光（同色相提亮 + 中性白芯；只用于身份焦点小面积点缀）──
    readonly property color _glow: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 0.72),
        Math.min(1, NovaTheme.primary.hsvValue * (NovaTheme.isDark ? 1.5 : 1.25)), 1)

    Rectangle { anchors.fill: parent; color: NovaTheme.page }
    NovaIcon {
        id: _appBadge
        objectName: "_appBadge"
        icon: "img:" + root._appIcon
        size: root._unit * 4
        monochrome: false
        anchors {
            top: parent.top; left: parent.left; topMargin: root._unit; leftMargin: root._unit
        }
        opacity: 0.9
        z: NovaTheme.zMarginals
        // 应用身份徽记：decorative 语义，a11yLabel 留空由注入内容承担语义
    }

    // ── 1. 对标带（本厂值 / 行业基线 / 先进基线 / 差距；报表全局呈现位）──
    Item {
        id: _benchmarkBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showBenchmark ? root._benchmarkH : 0
        clip: true
        z: NovaTheme.zMarginals
        Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

        NovaHeader {
            id: _benchmark
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root._benchmarkH
            tint: root._panel
        }

        // 对标带 / 主体唯一边界：1px 中性分隔（CC-2）
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1
            color: root._divider
            z: NovaTheme.zMarginals
        }

        // 身份 A-1：对标游标尺（主轴 + 三条基准刻 + 偏差游标；纯几何，不仿按钮 / tab）
        // a11y: decorative
        Item {
            anchors { left: parent.left; leftMargin: root._gap; bottom: parent.bottom; bottomMargin: root._unit }
            width: 88; height: 14
            z: NovaTheme.zMarginals
            Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: root._divider }
            Rectangle { x: 4;  y: 8; width: 2; height: 5; color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 26; y: 6; width: 2; height: 7; color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 48; y: 4; width: 2; height: 9; color: root._ink; opacity: 0.9 }
            Rectangle { x: 70; y: 3; width: 6; height: 6; rotation: 45; color: root._glow; opacity: 0.9 }
        }
    }

    // ── 2. 左栏 诊断轨（归因七元组 / 根因排序 / 建议动作）──
    Rectangle {
        id: _diagnosisWrap
        anchors { top: _benchmarkBar.bottom; bottom: parent.bottom; left: parent.left }
        width: (root.showDiagnosis && !root.diagnosisCollapsed && !root.belowBreakpoint) ? root._diagnosisW : 0
        color: root._railBg
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }
        NovaPage { id: _diagnosis; anchors.fill: parent; padding: root._gap }

        // 身份 B-1：因果鱼骨（竖干 + 三对斜枝；抽象几何，不仿树控件 / 列表）
        // a11y: decorative
        Item {
            anchors { top: parent.top; topMargin: root._gap; left: parent.left; leftMargin: root._gap }
            width: 34; height: 30
            z: NovaTheme.zMarginals
            Rectangle { x: 16; y: 0;  width: 2; height: 30; color: root._ink; opacity: 0.9 }
            Rectangle { x: 6;  y: 5;  width: 11; height: 1; rotation: 25;  color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 18; y: 5;  width: 11; height: 1; rotation: -25; color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 6;  y: 14; width: 11; height: 1; rotation: 25;  color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 18; y: 14; width: 11; height: 1; rotation: -25; color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 6;  y: 23; width: 11; height: 1; rotation: 25;  color: root._ink;     opacity: 0.9 }
            Rectangle { x: 18; y: 23; width: 11; height: 1; rotation: -25; color: root._ink;     opacity: 0.9 }
        }
    }

    NovaSeparator {
        id: _diagnosisSep
        anchors { top: _benchmarkBar.bottom; bottom: parent.bottom; left: _diagnosisWrap.right }
        vertical: true
        visible: root.bordered && _diagnosisWrap.width > 0
        z: NovaTheme.zMarginals
    }

    // ── 3. 中栏 主报表区（NovaDataGrid 注入位）+ 预测区间带 ──
    Item {
        id: _center
        anchors {
            top: _benchmarkBar.bottom
            bottom: parent.bottom
            left: _diagnosisWrap.right
            right: _queryWrap.left
        }

        NovaPage {
            id: _report
            anchors {
                top: parent.top
                bottom: _forecastBar.top
                left: parent.left
                right: parent.right
            }
            padding: root._gap
        }

        // 身份 C-1：行列刻度尺（横轴 + 纵轴 + 行列刻点；报表栅格抽象，中央留给业务注入）
        // a11y: decorative
        Item {
            anchors { top: _report.top; left: _report.left; topMargin: root._unit; leftMargin: root._unit }
            width: 60; height: 40
            z: NovaTheme.zMarginals
            Rectangle { x: 0; y: 8; width: 60; height: 1; color: root._divider; opacity: 0.9 }
            Rectangle { x: 8; y: 0; width: 1; height: 40; color: root._divider; opacity: 0.9 }
            Rectangle { x: 20; y: 5; width: 1; height: 6; color: root._ink; opacity: 0.9 }
            Rectangle { x: 36; y: 5; width: 1; height: 6; color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 52; y: 5; width: 1; height: 6; color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 5; y: 20; width: 6; height: 1; color: root._ink; opacity: 0.9 }
            Rectangle { x: 5; y: 34; width: 6; height: 1; color: root._inkSoft; opacity: 0.9 }
        }

        // 3b. 预测区间带（2–8h 区间 + 模型新鲜度；栏高归零 + 恒定锚链 CC-5）
        Item {
            id: _forecastBar
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: root.showForecast ? root._forecastH : 0
            clip: true
            z: NovaTheme.zMarginals
            Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

            NovaFooter {
                id: _forecast
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._forecastH
                tint: root._panel
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: 1
                color: root._divider
                z: NovaTheme.zMarginals
            }
            // 身份 D-1：置信区间带（主轴 + 上下界 + 中心点；纯几何，不仿进度条 / 滑块）
            // a11y: decorative
            Item {
                anchors { left: parent.left; leftMargin: root._gap; top: parent.top; topMargin: root._unit }
                width: 96; height: 16
                z: NovaTheme.zMarginals
                Rectangle { x: 0;  y: 7;  width: 96; height: 2; color: root._divider; opacity: 0.9 }
                Rectangle { x: 14; y: 2;  width: 64; height: 1; color: root._inkSoft; opacity: 0.9 }
                Rectangle { x: 14; y: 13; width: 64; height: 1; color: root._inkSoft; opacity: 0.9 }
                Rectangle { x: 14; y: 2;  width: 1;  height: 12; color: root._inkSoft; opacity: 0.9 }
                Rectangle { x: 77; y: 2;  width: 1;  height: 12; color: root._inkSoft; opacity: 0.9 }
                Rectangle { x: 44; y: 5;  width: 8;  height: 8; radius: 4; color: root._glow; opacity: 0.9 }
            }
        }
    }

    // ── 4. 右栏 问数轨 + 审批闸门 ──
    NovaSeparator {
        id: _querySep
        anchors { top: _benchmarkBar.bottom; bottom: parent.bottom; right: _queryWrap.left }
        vertical: true
        visible: root.bordered && _queryWrap.width > 0
        z: NovaTheme.zMarginals
    }

    Rectangle {
        id: _queryWrap
        anchors { top: _benchmarkBar.bottom; bottom: parent.bottom; right: parent.right }
        width: (root.showQuery && !root.queryCollapsed && !root.belowBreakpoint) ? root._queryW : 0
        color: root._railBg
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }

        NovaPage {
            id: _query
            anchors {
                top: parent.top
                bottom: _approvalBar.top
                left: parent.left
                right: parent.right
            }
            padding: root._gap
        }

        // 身份 E-1：问数双点（两个实心方点 + 连接横线；对话抽象，不仿气泡 / 按钮）
        // a11y: decorative
        Item {
            anchors { top: _query.top; topMargin: root._gap; right: _query.right; rightMargin: root._gap }
            width: 28; height: 18
            z: NovaTheme.zMarginals
            Rectangle { x: 0;  y: 0; width: 10; height: 10; radius: 2; color: root._ink; opacity: 0.9 }
            Rectangle { x: 14; y: 8; width: 10; height: 10; radius: 2; color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 8;  y: 8; width: 8;  height: 1; color: root._divider; opacity: 0.9 }
        }

        // 4b. 审批闸门（建议 → 人工确认 → 回写；栏高归零 + 恒定锚链 CC-5）
        Item {
            id: _approvalBar
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: root.showApproval ? root._approvalH : 0
            clip: true
            z: NovaTheme.zMarginals
            Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

            NovaFooter {
                id: _approval
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._approvalH
                tint: root._panel
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: 1
                color: root._divider
                z: NovaTheme.zMarginals
            }
            // 身份 F-1：闸门横闩（双立柱 + 横闩 + 缺口；确认闸门抽象，不仿开关 / 按钮）
            // a11y: decorative
            Item {
                anchors { right: parent.right; rightMargin: root._gap; top: parent.top; topMargin: root._unit }
                width: 26; height: 18
                z: NovaTheme.zMarginals
                Rectangle { x: 0;  y: 2; width: 2;  height: 16; color: root._ink; opacity: 0.9 }
                Rectangle { x: 24; y: 2; width: 2;  height: 16; color: root._ink; opacity: 0.9 }
                Rectangle { x: 2;  y: 8; width: 22; height: 2;  color: root._inkSoft; opacity: 0.9 }
                Rectangle { x: 11; y: 8; width: 4;  height: 2;  color: NovaTheme.surface; opacity: 0.9 }
            }
        }
    }

    // ── 5. 浮层（人工确认弹窗 / 加载遮罩；业务注入须为透明 Item）──
    Item {
        id: _overlay
        anchors.fill: parent
        z: NovaTheme.zFixedDrawer
    }

    // 顶层品牌签名：2px 单色系递进发丝线（CC-3）
    // a11y: decorative
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 2
        z: NovaTheme.zMarginals
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root._ink }
            GradientStop { position: 0.5; color: root._inkSoft }
            GradientStop { position: 1.0; color: root._ink }
        }
        opacity: 0.9
    }

    // 前置预判性：Esc 收起两条可折叠轨（只 emit 意图，宿主受控改 *Collapsed）
    focus: true
    Keys.onEscapePressed: {
        if (!root.diagnosisCollapsed) root.diagnosisToggled(true)
        if (!root.queryCollapsed) root.queryToggled(true)
    }
}
