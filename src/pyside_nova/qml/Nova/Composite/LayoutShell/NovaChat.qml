// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaChat.qml
// NovaChat AI 对话主窗口壳：六槽多轨工作台（对标 WorkBuddy 桌面端主窗口），组合态一致性契约（CC）落地标杆
// 组合态（宪法 0.9.0）：根内以 _ 私有 readonly 声明唯一组合上下文（密度/层级/动效/品牌色），六轨共享；
//   相邻边界只有一条分隔源；身份装饰一律抽象几何、禁止仿交互控件、同屏品牌色收敛为主色系；
//   折叠锚链恒定不依赖 visible 三元切换。全部为 _ 私有 PATCH，公共 API 签名逐字不变、冻结指纹不变。
// 用法：向 navSlot/conversationSlot/headerSlot/contentSlot/composerSlot/detailSlot/overlaySlot 注入业务内容；Shell 只托管布局与折叠状态，不含会话数据与业务文案
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）；气泡语义由注入的 NovaChatMessage 承担
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    LayoutMirroring.enabled: NovaTheme.isRtl

    // ── 六个槽位（第 4 章 alias 机制；对话气泡走 contentSlot 注入 NovaChatMessage）──
    property alias navSlot: _nav.data
    property alias conversationSlot: _conversation.data
    property alias headerSlot: _header.data
    property alias contentSlot: _body.content
    property alias composerSlot: _composer.data
    property alias detailSlot: _detail.data
    property alias overlaySlot: _overlay.data

    // ── 配置属性（默认值来自令牌，不进冻结面）──
    property real navSize: 64
    property real conversationSize: 300
    property real detailSize: 320
    property int headerHeight: 52
    property int composerHeight: 132
    property bool showNav: true
    property bool showConversation: true
    property bool showDetail: true
    property bool showHeader: true
    property bool showComposer: true
    property bool navCollapsed: false
    property bool conversationCollapsed: false
    property bool detailCollapsed: false
    property int breakpoint: 960
    property bool bordered: true

    // ── 受控契约：只 emit，不自写宿主状态 ──
    signal navToggled(bool collapsed)
    signal conversationToggled(bool collapsed)
    signal detailToggled(bool collapsed)
    function toggleNav() { root.navToggled(!root.navCollapsed) }
    function toggleConversation() { root.conversationToggled(!root.conversationCollapsed) }
    function toggleDetail() { root.detailToggled(!root.detailCollapsed) }

    readonly property bool belowBreakpoint: width > 0 && width < root.breakpoint
    // 应用身份图标（qrc:/icons/app-chat.svg；私有 _ 前缀不进冻结面，decorative）
    readonly property url _appIcon: "qrc:/icons/app-chat"

    implicitWidth: 1280
    implicitHeight: 800

    // 非法入参钳制：窄窗下各栏最多占容器一半，杜绝溢出（0.8.1）
    readonly property real _navW: Math.max(48, Math.min(root.navSize, 160))
    readonly property real _convW: Math.max(180, Math.min(root.conversationSize, width / 2 || root.conversationSize))
    readonly property real _detailW: Math.max(200, Math.min(root.detailSize, width / 3 || root.detailSize))
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _composerH: Math.max(24, Math.min(root.composerHeight, 360))

    // ── 组合上下文 CC-1（宪法 0.9.0）：六轨唯一密度/层级/动效/品牌色基准 ──
    // 禁止各轨散用 NovaTheme.spacing* 造成 padding 叠加；所有轨道一律引用本组常量。
    readonly property real _unit: NovaTheme.spacingS             // 6px 密度栅格基元
    readonly property real _gap: root._unit * 2                   // 12 轨内统一边距
    readonly property real _railPad: root._unit * 2
    readonly property real _radius: NovaTheme.radiusM
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    // ── 专属主题 · 蔚蓝（色相 216°，偏移 -0.0460）──
    // AI 对话 · 清澈沟通，六轨分治；色相随 setBrand 漂移，饱和/明度系数独立定制（CC-3：组件内仍单色相）
    // _signatureOn：true=专属色相（默认）/ false=回归全局品牌蓝（亮色态）；私有令牌不进冻结面
    property bool _signatureOn: true
    readonly property real _themeHue: root._signatureOn
        ? (NovaTheme.primary.hsvHue + (-0.0460) + 1) % 1
        : NovaTheme.primary.hsvHue
    readonly property color _accent: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 1.18),
        Math.min(1, NovaTheme.primary.hsvValue * 1.00 * (NovaTheme.isDark ? 1.25 : 1)), 1)
    readonly property color _ink: root._accent
    // 单色系派生：同屏只出现主色系，secondary / accent 不再与 primary 撞色（CC-3）
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

    // ── 1. 最左导航轨（图标 rail 宿主）──
    Rectangle {
        id: _navWrap
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: (root.showNav && !root.navCollapsed) ? root._navW : 0
        color: root._rail
        clip: true
        visible: width > 0
        Behavior on width {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        Item { id: _nav; anchors.fill: parent }

        // 身份 A（抽象几何，CC-3：不仿按钮/图标）；声明于 _nav 之后浮于业务注入之上且只占边缘/列首
        // a11y: decorative
        Item {
            id: _navIdentity
            anchors.fill: parent
            z: NovaTheme.zMarginals
            // 内侧竖向主色渐变缘轨：该轨唯一边界签名，不与 separator 叠在同一像素
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; right: parent.right; rightMargin: 1 }
                width: 2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root._ink }
                    GradientStop { position: 1.0; color: root._inkSoft }
                }
                opacity: 0.9
            }
            // 列首品牌徽记（渐变实心圆 + 内环）
            Rectangle {
                anchors { top: parent.top; topMargin: root._gap; horizontalCenter: parent.horizontalCenter }
                width: 28; height: 28; radius: 14
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root._ink }
                    GradientStop { position: 1.0; color: root._inkSoft }
                }
                // Aurora Core：同色相亮核环 + 中性白芯
                Rectangle {
                    anchors.centerIn: parent
                    width: 14; height: 14; radius: 7
                    color: root._glow
                    opacity: 0.9
                    Rectangle { anchors.centerIn: parent; width: 8; height: 8; radius: 4; color: NovaTheme.surface }
                }
            }
            // 列尾抽象锚点（纯几何圆点，不做成可点击头像）
            Rectangle {
                anchors { bottom: parent.bottom; bottomMargin: root._gap; horizontalCenter: parent.horizontalCenter }
                width: 6; height: 6; radius: 3
                color: root._ink
                opacity: 0.9
            }
        }
    }

    // 边界唯一分隔源 CC-2：整条边界只此一条，不再叠加渐变缘轨 / 发丝线 / 顶层色带
    NovaSeparator {
        id: _navSep
        anchors { top: parent.top; bottom: parent.bottom; left: _navWrap.right }
        vertical: true
        visible: root.bordered && _navWrap.width > 0
        z: NovaTheme.zMarginals
    }

    // ── 2. 会话列（会话列表宿主；窄屏自动收起）──
    Rectangle {
        id: _convWrap
        // CC-5：锚链恒定指向 _navWrap.right，不用 visible 三元切换，避免折叠瞬间布局跳变
        anchors { top: parent.top; bottom: parent.bottom; left: _navWrap.right }
        width: (root.showConversation && !root.conversationCollapsed && !root.belowBreakpoint) ? root._convW : 0
        color: root._rail
        clip: true
        visible: width > 0
        Behavior on width {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        Item { id: _conversation; anchors.fill: parent }

        // 身份 B（抽象几何）：列首短色带 + 左缘激活竖条 + 列尾角标
        // a11y: decorative
        Item {
            id: _convIdentity
            anchors.fill: parent
            z: NovaTheme.zMarginals
            Rectangle {
                anchors { top: parent.top; topMargin: root._gap; left: parent.left; leftMargin: root._gap }
                width: 36; height: 3; radius: 1.5
                color: root._ink
                opacity: 0.9
            }
            // 列尾 L 形角标（纯几何，不仿新建按钮）
            Rectangle {
                anchors { bottom: parent.bottom; bottomMargin: root._gap; left: parent.left; leftMargin: root._gap }
                width: 10; height: 2
                color: root._inkSoft
                opacity: 0.9
            }
            Rectangle {
                anchors { bottom: parent.bottom; bottomMargin: root._gap; left: parent.left; leftMargin: root._gap }
                width: 2; height: 10
                color: root._inkSoft
                opacity: 0.9
            }
        }
    }

    NovaSeparator {
        id: _convSep
        anchors { top: parent.top; bottom: parent.bottom; left: _convWrap.right }
        vertical: true
        visible: root.bordered && _convWrap.width > 0
        z: NovaTheme.zMarginals
    }

    // ── 3. 中间对话区：header + 消息内容 + 输入区 ──
    Item {
        id: _center
        // CC-5：左右锚定恒定，折叠时只由轨宽动画驱动，不因 separator visible 突变而重排
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: _convWrap.right
            right: _detailWrap.left
        }

        // ── 3a. 会话头（栏高归零 + 恒定锚链 CC-5；内层 NovaHeader 固定高度规避 0 高内部 padding 反噬，坑位 19）──
        Item {
            id: _headerBar
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root.showHeader ? root._headerH : 0
            clip: true
            z: NovaTheme.zMarginals
            Behavior on height {
                NumberAnimation { duration: root._dur; easing.type: root._ease }
            }

            NovaHeader {
                id: _header
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._headerH
                tint: root._panel
            }

            // header / body 的唯一边界：2px 主色渐变细线（随栏收起，不再另挂 separator）
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

            // 身份 C-1：在线状态点（语义色实心，非交互控件）
            // a11y: decorative
            Rectangle {
                anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
                width: 8; height: 8; radius: 4
                color: NovaTheme.positive
                z: NovaTheme.zMarginals
            }
        }

        NovaPage {
            id: _body
            // CC-5：锚链恒指栏底 / 栏顶，栏高归零驱动，不用 showX 三元切换
            anchors {
                top: _headerBar.bottom
                bottom: _composerBar.top
                left: parent.left
                right: parent.right
            }
            // CC-1：轨内边距统一走组合上下文，与角标内缩同值对齐，消除三层 padding 叠加
            padding: root._gap
        }

        // ── 3b. 输入区（栏高归零 + 恒定锚链；内层 NovaFooter 固定高度规避 0 高反噬）──
        Item {
            id: _composerBar
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: root.showComposer ? root._composerH : 0
            clip: true
            z: NovaTheme.zMarginals
            Behavior on height {
                NumberAnimation { duration: root._dur; easing.type: root._ease }
            }

            NovaFooter {
                id: _composer
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._composerH
                tint: root._panel
            }

            // body / composer 的唯一边界：1px 中性分隔
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: 1
                color: root._divider
                z: NovaTheme.zMarginals
            }

            // 身份 C-3：输入区 —— 顶部短色带 + 左缘圆点（抽象几何；不仿输入框/发送按钮）
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

        // 身份 C-2：AI 画布对角双角标（只占内容区对角，中央消息区完全留给业务注入）
        // a11y: decorative；margins 钳制避免极端入参下父区过小导致负几何
        Item {
            id: _canvasIdentity
            anchors {
                fill: _body
                margins: Math.max(0, Math.min(root._gap, Math.min(_body.width, _body.height) / 2))
            }
            z: NovaTheme.zMarginals
            readonly property int _arm: 10
            // 左上
            Rectangle { anchors { top: parent.top; left: parent.left } width: _canvasIdentity._arm; height: 1; color: root._ink; opacity: 0.9 }
            Rectangle { anchors { top: parent.top; left: parent.left } width: 1; height: _canvasIdentity._arm; color: root._ink; opacity: 0.9 }
            // 右下
            Rectangle { anchors { bottom: parent.bottom; right: parent.right } width: _canvasIdentity._arm; height: 1; color: root._inkSoft; opacity: 0.9 }
            Rectangle { anchors { bottom: parent.bottom; right: parent.right } width: 1; height: _canvasIdentity._arm; color: root._inkSoft; opacity: 0.9 }
        }
    }

    // ── 4. 右侧详情栏（上下文 / 引用 / 工具面板）──
    NovaSeparator {
        id: _detailSep
        anchors { top: parent.top; bottom: parent.bottom; right: _detailWrap.left }
        vertical: true
        visible: root.bordered && _detailWrap.width > 0
        z: NovaTheme.zMarginals
    }

    Rectangle {
        id: _detailWrap
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: (root.showDetail && !root.detailCollapsed && !root.belowBreakpoint) ? root._detailW : 0
        color: root._rail
        clip: true
        visible: width > 0
        Behavior on width {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        Item { id: _detail; anchors.fill: parent }

        // 身份 D（抽象几何）：列首三段递减几何条 + 列尾圆点；不仿分段 tab / 菜单
        // a11y: decorative
        Item {
            id: _detailIdentity
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

    // ── 5. 浮层（弹窗 / 提示 / 加载遮罩）──
    Item {
        id: _overlay
        anchors.fill: parent
        z: NovaTheme.zFixedDrawer
    }

    // 顶层品牌签名：2px 单色系发丝线（CC-3：不再三段撞色），恒在最上层且只占顶部 2px
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

    // 前置预判性：Esc 收起三条可折叠轨（只 emit 意图，宿主受控改 *Collapsed）
    focus: true
    Keys.onEscapePressed: {
        if (!root.navCollapsed) root.navToggled(true)
        if (!root.conversationCollapsed) root.conversationToggled(true)
        if (!root.detailCollapsed) root.detailToggled(true)
    }
}
