// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaAgent.qml
// NovaAgent 智能体任务执行工作台壳：任务列 + 编排画布 + 验证轨 + 审批闸（对标 NovaAgent 八项准入控制）
// 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全轨共享；
//   相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（DAG 节点环 / 风险分级色阶 / 闸门色带），
//   不仿交互控件、不同屏撞色；折叠锚链恒定不依赖 visible 三元切换。
// 用法：向 taskSlot/planSlot/contentSlot/verifySlot/approvalSlot/overlaySlot 注入业务内容；
//   Shell 只托管布局与折叠状态，不含任务数据、工具凭证、审批记录等业务语义。
// 治理边界（设计文档 §2）：八项准入控制、风险分级、外部信号验证器均为业务层职责，由槽位注入；
//   Shell 仅以审批闸门条带与验证轨的视觉分层预留其呈现位置。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）；语义由注入内容承担
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    // ── 六个槽位（第 4 章 alias 机制；业务内容全部由宿主注入）──
    property alias taskSlot: _task.data
    property alias planSlot: _plan.data
    property alias contentSlot: _body.content
    property alias verifySlot: _verify.data
    property alias approvalSlot: _approval.data
    property alias overlaySlot: _overlay.data

    // ── 配置属性（默认值来自令牌，进冻结面）──
    property real taskSize: 280
    property real verifySize: 300
    property int headerHeight: 52
    property int approvalHeight: 96
    property bool showTask: true
    property bool showPlan: true
    property bool showVerify: true
    property bool showApproval: true
    property bool taskCollapsed: false
    property bool verifyCollapsed: false
    property int breakpoint: 960
    property bool bordered: true

    // ── 受控契约：只 emit，不自写宿主状态 ──
    signal taskToggled(bool collapsed)
    signal verifyToggled(bool collapsed)
    signal approvalRequested()
    function toggleTask() { root.taskToggled(!root.taskCollapsed) }
    function toggleVerify() { root.verifyToggled(!root.verifyCollapsed) }
    function requestApproval() { root.approvalRequested() }

    readonly property bool belowBreakpoint: width > 0 && width < root.breakpoint
    // 应用身份图标（qrc:/icons/app-agent.svg；私有 _ 前缀不进冻结面，decorative）
    readonly property url _appIcon: "qrc:/icons/app-agent"

    implicitWidth: 1280
    implicitHeight: 800

    // 非法入参钳制（宪法第 7 章第 1 条）：极端值下几何有限非负
    readonly property real _taskW: Math.max(180, Math.min(root.taskSize, width / 2 || root.taskSize))
    readonly property real _verifyW: Math.max(200, Math.min(root.verifySize, width / 3 || root.verifySize))
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _approvalH: Math.max(24, Math.min(root.approvalHeight, 360))

    // ── 组合上下文 CC-1：全轨唯一密度/层级/动效/品牌色基准 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property real _railPad: root._unit * 2
    readonly property real _radius: NovaTheme.radiusM
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    // ── 专属主题 · 深空靛蓝（色相 233°，偏移 +0.0000）──
    // 智能体编排 · 本库基准主色，冷静理性；色相随 setBrand 漂移，饱和/明度系数独立定制（CC-3：组件内仍单色相）
    // _signatureOn：true=专属色相（默认）/ false=回归全局品牌蓝（亮色态）；私有令牌不进冻结面
    property bool _signatureOn: true
    readonly property real _themeHue: root._signatureOn
        ? (NovaTheme.primary.hsvHue + (0.0000) + 1) % 1
        : NovaTheme.primary.hsvHue
    readonly property color _accent: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 1.00),
        Math.min(1, NovaTheme.primary.hsvValue * 1.00 * (NovaTheme.isDark ? 1.25 : 1)), 1)
    readonly property color _ink: root._accent
    readonly property color _inkSoft: Qt.lighter(root._accent, 1.35)
    // ── Aurora Core · 极光核辉光（同色相提亮 + 中性白芯；CC-3 组件内仍单色相）──
    // 从本组件专属色相派生，setBrand 换肤同步平移；只用于身份焦点小面积点缀
    readonly property color _glow: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 0.78),
        Math.min(1, NovaTheme.primary.hsvValue * (NovaTheme.isDark ? 1.5 : 1.28)), 1)

    Rectangle { anchors.fill: parent; color: NovaTheme.page }
    NovaIcon {
        id: _appBadge
        objectName: "_appBadge"
        icon: "img:" + root._appIcon
        size: root._unit * 4
        monochrome: false
        anchors { top: parent.top; left: parent.left; topMargin: root._unit; leftMargin: root._unit }
        opacity: 0.9
        z: NovaTheme.zMarginals
        // 应用身份徽记：decorative 语义，a11yLabel 留空由注入内容承担语义
    }

    // ── 1. 左任务列（任务队列宿主；窄屏自动收起）──
    Rectangle {
        id: _taskWrap
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: (root.showTask && !root.taskCollapsed && !root.belowBreakpoint) ? root._taskW : 0
        color: root._rail
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }
        Item { id: _task; anchors.fill: parent }

        // 身份 A（抽象几何）：列首 DAG 三节点递减链 + 右缘主色渐变轨；不仿新建按钮
        // a11y: decorative
        Item {
            id: _taskIdentity
            anchors.fill: parent
            z: NovaTheme.zMarginals
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; right: parent.right; rightMargin: 1 }
                width: 2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root._ink }
                    GradientStop { position: 1.0; color: root._inkSoft }
                }
                opacity: 0.9
            }
            Row {
                anchors { top: parent.top; topMargin: root._gap; left: parent.left; leftMargin: root._gap }
                spacing: root._unit
                Rectangle { width: 9; height: 9; radius: 4.5; color: root._glow; opacity: 0.9 }
                Rectangle { width: 6; height: 1; y: 4; color: root._divider }
                Rectangle { width: 6; height: 6; radius: 3; color: root._inkSoft; opacity: 0.9 }
                Rectangle { width: 6; height: 1; y: 4; color: root._divider }
                Rectangle { width: 4; height: 4; radius: 2; y: 2; color: root._divider }
            }
            // 列尾风险分级三色阶（同主色系明度递减，非红绿撞色）
            Rectangle {
                anchors { bottom: parent.bottom; bottomMargin: root._gap; left: parent.left; leftMargin: root._gap }
                width: 24; height: 3; radius: 1.5; color: root._ink; opacity: 0.9
            }
        }
    }

    NovaSeparator {
        id: _taskSep
        anchors { top: parent.top; bottom: parent.bottom; left: _taskWrap.right }
        vertical: true
        visible: root.bordered && _taskWrap.width > 0
        z: NovaTheme.zMarginals
    }

    // ── 2. 中央编排区：任务头 + DAG 规划 + 执行画布 + 审批闸门 ──
    Item {
        id: _center
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: _taskWrap.right
            right: _verifyWrap.left
        }

        // 2a. 任务头（栏高归零 + 恒定锚链 CC-5）
        Item {
            id: _headerBar
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root.showPlan ? root._headerH : 0
            clip: true
            z: NovaTheme.zMarginals
            Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

            NovaHeader {
                id: _plan
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._headerH
                tint: root._panel
            }
            // header / body 唯一边界：2px 主色渐变细线
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                z: NovaTheme.zMarginals
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root._ink }
                    GradientStop { position: 1.0; color: root._divider }
                }
                opacity: 0.9
            }
            // 身份 B-1：编排在线状态点（语义色实心）
            // a11y: decorative
            Rectangle {
                anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
                width: 8; height: 8; radius: 4
                color: NovaTheme.positive
                z: NovaTheme.zMarginals
            }
        }

        // 2b. 执行画布（内容槽）
        NovaPage {
            id: _body
            anchors {
                top: _headerBar.bottom
                bottom: _approvalBar.top
                left: parent.left
                right: parent.right
            }
            padding: root._gap
        }

        // 身份 B-2：DAG 画布对角取景框（中央完全留给业务注入）
        // a11y: decorative；margins 钳制避免极端入参负几何
        Item {
            id: _canvasIdentity
            anchors {
                fill: _body
                margins: Math.max(0, Math.min(root._gap, Math.min(_body.width, _body.height) / 2))
            }
            z: NovaTheme.zMarginals
            readonly property int _arm: 10
            Rectangle { anchors { top: parent.top; left: parent.left } width: _canvasIdentity._arm; height: 1; color: root._ink; opacity: 0.9 }
            Rectangle { anchors { top: parent.top; left: parent.left } width: 1; height: _canvasIdentity._arm; color: root._ink; opacity: 0.9 }
            Rectangle { anchors { bottom: parent.bottom; right: parent.right } width: _canvasIdentity._arm; height: 1; color: root._inkSoft; opacity: 0.9 }
            Rectangle { anchors { bottom: parent.bottom; right: parent.right } width: 1; height: _canvasIdentity._arm; color: root._inkSoft; opacity: 0.9 }
        }

        // 2c. 审批闸门区（HIGH 风险人工复核点；栏高归零 + 恒定锚链）
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
            // body / approval 唯一边界：1px 中性分隔
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: 1
                color: root._divider
                z: NovaTheme.zMarginals
            }
            // 身份 B-3：审批闸门色带（纯几何条带，不仿确认按钮）
            // a11y: decorative
            Item {
                anchors.fill: parent
                z: NovaTheme.zMarginals
                Rectangle {
                    anchors { top: parent.top; topMargin: root._unit; horizontalCenter: parent.horizontalCenter }
                    width: 48; height: 2; radius: 1
                    color: root._ink
                    opacity: 0.9
                }
                Rectangle {
                    anchors { left: parent.left; leftMargin: root._gap; top: parent.top; topMargin: root._gap }
                    width: 6; height: 6; radius: 3
                    color: root._inkSoft
                    opacity: 0.9
                }
            }
        }
    }

    // ── 3. 右侧验证轨（外部信号检查器宿主，独立于 Agent）──
    NovaSeparator {
        id: _verifySep
        anchors { top: parent.top; bottom: parent.bottom; right: _verifyWrap.left }
        vertical: true
        visible: root.bordered && _verifyWrap.width > 0
        z: NovaTheme.zMarginals
    }

    Rectangle {
        id: _verifyWrap
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: (root.showVerify && !root.verifyCollapsed && !root.belowBreakpoint) ? root._verifyW : 0
        color: root._rail
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }
        Item { id: _verify; anchors.fill: parent }

        // 身份 C（抽象几何）：列首三段递减验证级条 + 列尾圆点；不仿状态 tab
        // a11y: decorative
        Item {
            id: _verifyIdentity
            anchors.fill: parent
            z: NovaTheme.zMarginals
            Row {
                anchors { top: parent.top; topMargin: root._gap; left: parent.left; leftMargin: root._gap }
                spacing: root._unit
                Rectangle { width: 24; height: 3; radius: 1.5; color: root._ink; opacity: 0.9 }
                Rectangle { width: 14; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
                Rectangle { width: 8; height: 3; radius: 1.5; color: root._divider }
            }
            Rectangle {
                anchors { bottom: parent.bottom; bottomMargin: root._gap; left: parent.left; leftMargin: root._gap }
                width: 6; height: 6; radius: 3
                color: root._inkSoft
                opacity: 0.9
            }
        }
    }

    // ── 4. 浮层（审批卡片 / 提示 / 加载遮罩）──
    Item {
        id: _overlay
        anchors.fill: parent
        z: NovaTheme.zFixedDrawer
    }

    // 顶层品牌签名：2px 单色系发丝线（CC-3）
    // a11y: decorative
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 2
        z: NovaTheme.zMarginals
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root._ink }
            GradientStop { position: 1.0; color: root._inkSoft }
        }
        opacity: 0.9
    }

    // 前置预判性：Esc 收起两条可折叠轨（只 emit 意图，宿主受控改 *Collapsed）
    focus: true
    Keys.onEscapePressed: {
        if (!root.taskCollapsed) root.taskToggled(true)
        if (!root.verifyCollapsed) root.verifyToggled(true)
    }
}
