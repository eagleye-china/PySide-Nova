// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaCopilot.qml
// NovaCopilot 增强型协作面板壳：建议列 + 工作画布 + 动作闸门轨
//   （对标 NovaCopilot 建议—确认—执行契约与 Draft/Confirm/Read-Only 三模）
// 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全轨共享；
//   相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（内联胶囊条 / 闸门分隔点 /
//   撤销弧环 / 三段确认级条），与 NovaAgent / NovaDE 身份互不重复，不仿交互控件、不撞色；
//   折叠锚链恒定不依赖 visible 三元切换。
// 用法：向 suggestSlot/inlineSlot/contentSlot/gateSlot/overlaySlot 注入业务内容；
//   Shell 只托管布局与折叠状态，不含建议内容、grounding 上下文、动作审计等业务语义。
// 治理边界（设计文档 §4）：以用户身份 grounding / 规则引擎优先 / Human-in-the-loop Gate /
//   动作可撤销可回溯均为业务层职责，由槽位注入；Shell 仅以动作闸门轨预留其呈现位置。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）；语义由注入内容承担
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    // ── 五个槽位（第 4 章 alias 机制；overlaySlot 非必需但保留供提示）──
    property alias suggestSlot: _suggest.data
    property alias inlineSlot: _inline.data
    property alias contentSlot: _body.content
    property alias gateSlot: _gate.data
    property alias overlaySlot: _overlay.data

    // ── 配置属性（进冻结面）──
    property real suggestSize: 280
    property real gateSize: 300
    property int inlineHeight: 44
    property bool showSuggest: true
    property bool showInline: true
    property bool showGate: true
    property bool suggestCollapsed: false
    property bool gateCollapsed: false
    property int breakpoint: 1024
    property bool bordered: true

    // ── 受控契约：只 emit，不自写宿主状态 ──
    signal suggestToggled(bool collapsed)
    signal gateToggled(bool collapsed)
    signal actionProposed()
    function toggleSuggest() { root.suggestToggled(!root.suggestCollapsed) }
    function toggleGate() { root.gateToggled(!root.gateCollapsed) }
    function proposeAction() { root.actionProposed() }

    readonly property bool belowBreakpoint: width > 0 && width < root.breakpoint

    implicitWidth: 1280
    implicitHeight: 800

    // 非法入参钳制（宪法第 7 章第 1 条）
    readonly property real _suggestW: Math.max(180, Math.min(root.suggestSize, width / 2 || root.suggestSize))
    readonly property real _gateW: Math.max(200, Math.min(root.gateSize, width / 3 || root.gateSize))
    readonly property int _inlineH: Math.max(24, Math.min(root.inlineHeight, 200))

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
    // ── 专属主题 · 鸢尾紫（色相 266°，偏移 +0.0940）──
    // 增强协作 · 紫色代表增强与共创；色相随 setBrand 漂移，饱和/明度系数独立定制（CC-3：组件内仍单色相）
    // _signatureOn：true=专属色相（默认）/ false=回归全局品牌蓝（亮色态）；私有令牌不进冻结面
    property bool _signatureOn: true
    readonly property real _themeHue: root._signatureOn
        ? (NovaTheme.primary.hsvHue + (0.0940) + 1) % 1
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

    // ── 1. 左建议列（建议 / 内联提示宿主；窄屏自动收起）──
    Rectangle {
        id: _suggestWrap
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: (root.showSuggest && !root.suggestCollapsed && !root.belowBreakpoint) ? root._suggestW : 0
        color: root._rail
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }
        Item { id: _suggest; anchors.fill: parent }

        // 身份 A：内联胶囊条 + 三段确认级条（抽象几何；不仿建议卡片按钮）
        // a11y: decorative
        Item {
            id: _suggestIdentity
            anchors.fill: parent
            z: NovaTheme.zMarginals
            Rectangle {
                anchors { top: parent.top; topMargin: root._gap; horizontalCenter: parent.horizontalCenter }
                width: 36; height: 3; radius: 1.5
                color: root._ink
                opacity: 0.9
            }
            Row {
                anchors { bottom: parent.bottom; bottomMargin: root._gap; left: parent.left; leftMargin: root._gap }
                spacing: root._unit
                Rectangle { width: 16; height: 3; radius: 1.5; color: root._ink; opacity: 0.9 }
                Rectangle { width: 10; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
                Rectangle { width: 5; height: 3; radius: 1.5; color: root._divider }
            }
        }
    }

    NovaSeparator {
        id: _suggestSep
        anchors { top: parent.top; bottom: parent.bottom; left: _suggestWrap.right }
        vertical: true
        visible: root.bordered && _suggestWrap.width > 0
        z: NovaTheme.zMarginals
    }

    // ── 2. 中央工作画布：内联建议条 + 业务内容 ──
    Item {
        id: _center
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: _suggestWrap.right
            right: _gateWrap.left
        }

        // 2a. 内联建议条（栏高归零 + 恒定锚链 CC-5）
        Item {
            id: _inlineBar
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root.showInline ? root._inlineH : 0
            clip: true
            z: NovaTheme.zMarginals
            Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

            NovaHeader {
                id: _inline
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._inlineH
                tint: root._panel
            }
            // inline / body 唯一边界：1px 中性分隔
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: root._divider
                z: NovaTheme.zMarginals
            }
            // 身份 B：内联胶囊（纯几何短条 + 侧锚点，不仿输入框）
            // a11y: decorative
            Rectangle {
                anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
                width: 24; height: 3; radius: 1.5
                color: root._ink
                opacity: 0.9
                z: NovaTheme.zMarginals
            }
        }

        // 2b. 业务工作画布（grounding 内容由宿主注入）
        NovaPage {
            id: _body
            anchors {
                top: _inlineBar.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            padding: root._gap
        }

        // 身份 C：画布对角双角标（中央完全留给业务注入）
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
    }

    // ── 3. 右侧动作闸门轨（proposed action / 确认 / 撤销窗口呈现位）──
    NovaSeparator {
        id: _gateSep
        anchors { top: parent.top; bottom: parent.bottom; right: _gateWrap.left }
        vertical: true
        visible: root.bordered && _gateWrap.width > 0
        z: NovaTheme.zMarginals
    }

    Rectangle {
        id: _gateWrap
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: (root.showGate && !root.gateCollapsed && !root.belowBreakpoint) ? root._gateW : 0
        color: root._rail
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }
        Item { id: _gate; anchors.fill: parent }

        // 身份 D：闸门分隔点 + 撤销弧环（纯几何；不仿确认/撤销按钮）
        // a11y: decorative
        Item {
            id: _gateIdentity
            anchors.fill: parent
            z: NovaTheme.zMarginals
            Rectangle {
                anchors { top: parent.top; topMargin: root._gap; horizontalCenter: parent.horizontalCenter }
                width: 40; height: 2; radius: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root._ink }
                    GradientStop { position: 1.0; color: root._inkSoft }
                }
                opacity: 0.9
            }
            // 撤销弧环近似：三个同心递减方块（零字体依赖）
            Rectangle {
                anchors { bottom: parent.bottom; bottomMargin: root._gap; horizontalCenter: parent.horizontalCenter }
                width: 10; height: 10; radius: 5
                color: root._ink
                opacity: 0.9
                Rectangle { anchors.centerIn: parent; width: 7; height: 7; radius: 3.5; color: root._glow }
                Rectangle { anchors.centerIn: parent; width: 3; height: 3; radius: 1.5; color: NovaTheme.surface }
            }
        }
    }

    // ── 4. 浮层（确认提示 / 提示 / 加载遮罩）──
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
        if (!root.suggestCollapsed) root.suggestToggled(true)
        if (!root.gateCollapsed) root.gateToggled(true)
    }
}
