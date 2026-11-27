// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaDE.qml
// NovaDE 数字员工岗位工作台壳：岗位条 + 任务队列 + 工作画布 + SLA 轨 + 人工交接条
//   （对标 NovaDE 四要件：岗位形态 / 任务队列 / 能力调用 / 队伍级治理）
// 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全部轨共享；
//   相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（岗位菱形徽记 / 队列堆叠角标 /
//   SLA 递减弧条 / 交接双向箭头），与 NovaAgent 的节点链身份互不重复，不仿交互控件、不撞色；
//   折叠锚链恒定不依赖 visible 三元切换。
// 用法：向 roleSlot/queueSlot/contentSlot/slaSlot/handoffSlot/overlaySlot 注入业务内容；
//   Shell 只托管布局与折叠状态，不含岗位定义、队列数据、SLA 指标等业务语义。
// 治理边界（设计文档 §3）：岗位注册表 / SSO+RBAC / 技能层 / Shadow Mode 均为业务层职责，
//   由槽位注入；Shell 仅以岗位条与交接条的视觉分层预留其呈现位置。
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
    property alias roleSlot: _role.data
    property alias queueSlot: _queue.data
    property alias contentSlot: _body.content
    property alias slaSlot: _sla.data
    property alias handoffSlot: _handoff.data
    property alias overlaySlot: _overlay.data

    // ── 配置属性（进冻结面）──
    property real queueSize: 300
    property real slaSize: 280
    property int roleHeight: 64
    property int handoffHeight: 84
    property bool showQueue: true
    property bool showSla: true
    property bool showRole: true
    property bool showHandoff: true
    property bool queueCollapsed: false
    property bool slaCollapsed: false
    property int breakpoint: 1024
    property bool bordered: true

    // ── 受控契约：只 emit，不自写宿主状态 ──
    signal queueToggled(bool collapsed)
    signal slaToggled(bool collapsed)
    signal handoffRequested()
    function toggleQueue() { root.queueToggled(!root.queueCollapsed) }
    function toggleSla() { root.slaToggled(!root.slaCollapsed) }
    function requestHandoff() { root.handoffRequested() }

    readonly property bool belowBreakpoint: width > 0 && width < root.breakpoint
    // 应用身份图标（qrc:/icons/app-de.svg；私有 _ 前缀不进冻结面，decorative）
    readonly property url _appIcon: "qrc:/icons/app-de"

    implicitWidth: 1280
    implicitHeight: 800

    // 非法入参钳制（宪法第 7 章第 1 条）
    readonly property real _queueW: Math.max(200, Math.min(root.queueSize, width / 2 || root.queueSize))
    readonly property real _slaW: Math.max(180, Math.min(root.slaSize, width / 3 || root.slaSize))
    readonly property int _roleH: Math.max(24, Math.min(root.roleHeight, 240))
    readonly property int _handoffH: Math.max(24, Math.min(root.handoffHeight, 360))

    // ── 组合上下文 CC-1：全轨唯一密度基准 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property real _railPad: root._unit * 2
    readonly property real _radius: NovaTheme.radiusM
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    // ── 专属主题 · 钢蓝（色相 205°，偏移 -0.0760）──
    // 数字员工 · 钢蓝理性、岗位秩序；色相随 setBrand 漂移，饱和/明度系数独立定制（CC-3：组件内仍单色相）
    // _signatureOn：true=专属色相（默认）/ false=回归全局品牌蓝（亮色态）；私有令牌不进冻结面
    property bool _signatureOn: true
    readonly property real _themeHue: root._signatureOn
        ? (NovaTheme.primary.hsvHue + (-0.0760) + 1) % 1
        : NovaTheme.primary.hsvHue
    readonly property color _accent: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 0.95),
        Math.min(1, NovaTheme.primary.hsvValue * 0.82 * (NovaTheme.isDark ? 1.25 : 1)), 1)
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

    // ── 1. 顶部岗位条（岗位身份 / 队伍级治理呈现位；栏高归零 + 恒定锚链）──
    Item {
        id: _roleBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showRole ? root._roleH : 0
        clip: true
        z: NovaTheme.zMarginals
        Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

        NovaHeader {
            id: _role
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root._roleH
            tint: root._panel
        }
        // 岗位条 / 主体唯一边界：2px 主色渐变细线
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
        // 身份 A：岗位菱形徽记（旋转方形，纯几何、零字体依赖；不仿头像按钮）
        // a11y: decorative
        Rectangle {
            anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
            width: 14; height: 14; radius: 2
            color: root._ink
            rotation: 45
            opacity: 0.9
            z: NovaTheme.zMarginals
            Rectangle {
                anchors.centerIn: parent
                width: 7; height: 7; radius: 2
                color: root._glow
                opacity: 0.9
                Rectangle { anchors.centerIn: parent; width: 3; height: 3; radius: 1; color: NovaTheme.surface }
            }
        }
    }

    // ── 2. 左任务队列列（队列视图宿主；窄屏自动收起）──
    Rectangle {
        id: _queueWrap
        anchors { top: _roleBar.bottom; bottom: _handoffBar.top; left: parent.left }
        width: (root.showQueue && !root.queueCollapsed && !root.belowBreakpoint) ? root._queueW : 0
        color: root._rail
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }
        Item { id: _queue; anchors.fill: parent }

        // 身份 B：队列分层堆叠角标（三条左对齐递减卡沿，抽象几何；不仿菜单项）
        // a11y: decorative
        Item {
            id: _queueIdentity
            anchors.fill: parent
            z: NovaTheme.zMarginals
            Rectangle {
                anchors { top: parent.top; topMargin: root._gap; left: parent.left; leftMargin: root._gap }
                width: 30; height: 3; radius: 1.5; color: root._ink; opacity: 0.9
            }
            Rectangle {
                anchors { top: parent.top; topMargin: root._gap + root._unit * 2; left: parent.left; leftMargin: root._gap + root._unit }
                width: 20; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9
            }
            Rectangle {
                anchors { top: parent.top; topMargin: root._gap + root._unit * 4; left: parent.left; leftMargin: root._gap + root._unit * 2 }
                width: 10; height: 3; radius: 1.5; color: root._divider
            }
            Rectangle {
                anchors { bottom: parent.bottom; bottomMargin: root._gap; left: parent.left; leftMargin: root._gap }
                width: 2; height: 12
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root._ink }
                    GradientStop { position: 1.0; color: root._inkSoft }
                }
                opacity: 0.9
            }
        }
    }

    NovaSeparator {
        id: _queueSep
        anchors { top: _roleBar.bottom; bottom: _handoffBar.top; left: _queueWrap.right }
        vertical: true
        visible: root.bordered && _queueWrap.width > 0
        z: NovaTheme.zMarginals
    }

    // ── 3. 中央工作画布（跨系统工作执行呈现位）──
    NovaPage {
        id: _body
        anchors {
            top: _roleBar.bottom
            bottom: _handoffBar.top
            left: _queueWrap.right
            right: _slaWrap.left
        }
        padding: root._gap
    }

    // 身份 C：工作画布顶部中点双短条（区别于 Agent 的对角取景框；中央大部留业务注入）
    // a11y: decorative；margins 钳制避免极端入参负几何
    Item {
        id: _canvasIdentity
        anchors {
            fill: _body
            margins: Math.max(0, Math.min(root._gap, Math.min(_body.width, _body.height) / 2))
        }
        z: NovaTheme.zMarginals
        Row {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            spacing: root._unit
            Rectangle { width: 12; height: 2; radius: 1; color: root._ink; opacity: 0.9 }
            Rectangle { width: 12; height: 2; radius: 1; color: root._inkSoft; opacity: 0.9 }
        }
    }

    // ── 4. 右侧 SLA / 技能轨（队伍级治理与可用性呈现位；窄屏自动收起）──
    NovaSeparator {
        id: _slaSep
        anchors { top: _roleBar.bottom; bottom: _handoffBar.top; right: _slaWrap.left }
        vertical: true
        visible: root.bordered && _slaWrap.width > 0
        z: NovaTheme.zMarginals
    }

    Rectangle {
        id: _slaWrap
        anchors { top: _roleBar.bottom; bottom: _handoffBar.top; right: parent.right }
        width: (root.showSla && !root.slaCollapsed && !root.belowBreakpoint) ? root._slaW : 0
        color: root._rail
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }
        Item { id: _sla; anchors.fill: parent }

        // 身份 D：SLA 递减条 + 环形锚点（纯几何；不仿进度控件）
        // a11y: decorative
        Item {
            id: _slaIdentity
            anchors.fill: parent
            z: NovaTheme.zMarginals
            Rectangle {
                anchors { top: parent.top; topMargin: root._gap; left: parent.left; leftMargin: root._gap }
                width: 8; height: 8; radius: 4
                color: NovaTheme.positive
                opacity: 0.9
            }
            Column {
                anchors { top: parent.top; topMargin: root._gap; right: parent.right; rightMargin: root._gap }
                spacing: root._unit
                Rectangle { width: 20; height: 3; radius: 1.5; color: root._ink; opacity: 0.9 }
                Rectangle { width: 13; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
                Rectangle { width: 7; height: 3; radius: 1.5; color: root._divider }
            }
        }
    }

    // ── 5. 底部人工交接条（Auto/Draft/Handoff 边界呈现位；栏高归零 + 恒定锚链）──
    Item {
        id: _handoffBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: root.showHandoff ? root._handoffH : 0
        clip: true
        z: NovaTheme.zMarginals
        Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

        NovaFooter {
            id: _handoff
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root._handoffH
            tint: root._panel
        }
        // 主体 / 交接条唯一边界：1px 中性分隔
        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 1
            color: root._divider
            z: NovaTheme.zMarginals
        }
        // 身份 E：交接双向箭头（两段三角几何，指向彼此；不仿提交按钮）
        // a11y: decorative
        Item {
            anchors.fill: parent
            z: NovaTheme.zMarginals
            Rectangle {
                anchors { top: parent.top; topMargin: root._unit; horizontalCenter: parent.horizontalCenter }
                width: 40; height: 2; radius: 1
                color: root._ink
                opacity: 0.9
            }
            Rectangle {
                anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
                width: 8; height: 8; color: root._inkSoft; rotation: 45; opacity: 0.9
            }
        }
    }

    // ── 6. 浮层（交接确认 / 提示 / 加载遮罩）──
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
        z: NovaTheme.zMarginals + 1
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
        if (!root.queueCollapsed) root.queueToggled(true)
        if (!root.slaCollapsed) root.slaToggled(true)
    }
}
