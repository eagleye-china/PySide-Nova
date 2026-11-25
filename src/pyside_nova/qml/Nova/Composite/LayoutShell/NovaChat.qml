// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaChat.qml
// NovaChat AI 对话主窗口壳：品牌化多轨工作台 —— 导航轨 / 会话列 / 对话区 / 输入区 / 详情栏 / 浮层六槽骨架（对标 WorkBuddy 桌面端主窗口）
// 身份体系（0.7.1）：顶层三段品牌线 + 五轨各自独占的前景结构签名 —— 图标 rail（品牌徽记/激活点/账户锚）、
//   会话栈（搜索胶囊/激活竖条/新建圆钮）、AI 画布（四角取景框）、输入区（浮起胶囊/附加点/发送钮）、
//   详情栏（分段 tab/渐变缘轨）。全部为下划线私有纯几何装饰、零业务语义、只用 NovaTheme 真实令牌，
//   声明于注入槽位之后以浮于业务之上且只占边缘/角标（不遮挡中央内容）。
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

    implicitWidth: 1280
    implicitHeight: 800

    // 非法入参钳制：窄窗下各栏最多占容器一半，杜绝溢出
    readonly property real _navW: Math.max(48, Math.min(root.navSize, 160))
    readonly property real _convW: Math.max(180, Math.min(root.conversationSize, width / 2 || root.conversationSize))
    readonly property real _detailW: Math.max(200, Math.min(root.detailSize, width / 3 || root.detailSize))
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _composerH: Math.max(24, Math.min(root.composerHeight, 360))

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 1. 最左导航轨（图标 rail 宿主）──
    Rectangle {
        id: _navWrap
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: (root.showNav && !root.navCollapsed) ? root._navW : 0
        color: NovaTheme.surfaceAlt
        clip: true
        visible: width > 0
        Behavior on width {
            NumberAnimation { duration: NovaMotion.duration(NovaMotion.transitionDuration); easing.type: NovaMotion.easingStandard }
        }
        Item { id: _nav; anchors.fill: parent }

        // 身份 A：图标 rail —— 品牌徽记 + 三级激活点 + 账户锚 + 内侧渐变缘轨
        // a11y: decorative（纯几何，声明于 _nav 之后浮于业务注入之上，仅占 rail 边缘与中轴）
        Item {
            id: _navIdentity
            anchors.fill: parent
            // 内侧竖向品牌渐变缘轨
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                width: 3
                gradient: Gradient {
                    GradientStop { position: 0.0; color: NovaTheme.primary }
                    GradientStop { position: 1.0; color: NovaTheme.secondary }
                }
            }
            // 顶部品牌徽记（渐变圆 + 外圈光晕环）
            Rectangle {
                anchors { top: parent.top; topMargin: NovaTheme.spacingL; horizontalCenter: parent.horizontalCenter }
                width: 34; height: 34; radius: 17
                color: "transparent"
                border { width: 2; color: NovaTheme.primary }
                opacity: 0.9
            }
            Rectangle {
                anchors { top: parent.top; topMargin: NovaTheme.spacingL + 5; horizontalCenter: parent.horizontalCenter }
                width: 24; height: 24; radius: 12
                gradient: Gradient {
                    GradientStop { position: 0.0; color: NovaTheme.primary }
                    GradientStop { position: 1.0; color: NovaTheme.secondary }
                }
            }
            // 三级图标位：第一个品牌激活（实心 + 左指示条），其余 outlined
            Column {
                anchors { top: parent.top; topMargin: NovaTheme.spacingL * 4; horizontalCenter: parent.horizontalCenter }
                spacing: NovaTheme.spacingM
                Rectangle { width: 20; height: 20; radius: NovaTheme.radiusS; color: NovaTheme.primary; opacity: 0.9
                    Rectangle { anchors { left: parent.left; leftMargin: -NovaTheme.spacingS - 6; verticalCenter: parent.verticalCenter }
                        width: 3; height: 16; radius: 1.5; color: NovaTheme.primary } }
                Rectangle { width: 20; height: 20; radius: NovaTheme.radiusS; color: "transparent"
                    border { width: 1; color: NovaTheme.outline } }
                Rectangle { width: 20; height: 20; radius: NovaTheme.radiusS; color: "transparent"
                    border { width: 1; color: NovaTheme.outline } }
            }
            // 底部账户锚（outlined 圆 + 内点）
            Rectangle {
                anchors { bottom: parent.bottom; bottomMargin: NovaTheme.spacingL; horizontalCenter: parent.horizontalCenter }
                width: 26; height: 26; radius: 13
                color: "transparent"
                border { width: 1; color: NovaTheme.outline }
                Rectangle { anchors.centerIn: parent; width: 8; height: 8; radius: 4; color: NovaTheme.secondary; opacity: 0.9 }
            }
        }
    }

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
        anchors { top: parent.top; bottom: parent.bottom; left: _navSep.visible ? _navSep.right : _navWrap.right }
        width: (root.showConversation && !root.conversationCollapsed && !root.belowBreakpoint) ? root._convW : 0
        color: NovaTheme.surfaceAlt
        clip: true
        visible: width > 0
        Behavior on width {
            NumberAnimation { duration: NovaMotion.duration(NovaMotion.transitionDuration); easing.type: NovaMotion.easingStandard }
        }
        Item { id: _conversation; anchors.fill: parent }

        // 身份 B：会话栈 —— 搜索胶囊 + 激活竖条 + 新建圆钮（只占列首/左缘/列尾）
        // a11y: decorative
        Item {
            id: _convIdentity
            anchors.fill: parent
            // 顶部搜索胶囊（outlined 圆角条 + 左放大镜点）
            Rectangle {
                anchors { top: parent.top; topMargin: NovaTheme.spacingM; left: parent.left; leftMargin: NovaTheme.spacingM; right: parent.right; rightMargin: NovaTheme.spacingM }
                height: 30
                radius: 15
                color: "transparent"
                border { width: 1; color: NovaTheme.outline }
                Rectangle {
                    anchors { left: parent.left; leftMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
                    width: 8; height: 8; radius: 4
                    color: "transparent"
                    border { width: 1.5; color: NovaTheme.primary }
                }
            }
            // 激活会话左缘品牌竖条
            Rectangle {
                anchors { top: parent.top; topMargin: NovaTheme.spacingM * 5; left: parent.left }
                width: 3; height: 44; radius: 1.5
                color: NovaTheme.primary
            }
            // 列尾新建圆钮（primary 圆 + 十字）
            Rectangle {
                anchors { right: parent.right; rightMargin: NovaTheme.spacingM; bottom: parent.bottom; bottomMargin: NovaTheme.spacingM }
                width: 32; height: 32; radius: 16
                color: NovaTheme.primary
                Rectangle { anchors.centerIn: parent; width: 12; height: 2; radius: 1; color: NovaTheme.textOnPrimary }
                Rectangle { anchors.centerIn: parent; width: 2; height: 12; radius: 1; color: NovaTheme.textOnPrimary }
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
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: _convSep.visible ? _convSep.right : _convWrap.right
            right: _detailSep.visible ? _detailSep.left : _detailWrap.left
        }

        NovaHeader {
            id: _header
            visible: root.showHeader
            height: root._headerH
            anchors { top: parent.top; left: parent.left; right: parent.right }
            tint: NovaTheme.surface
        }

        NovaPage {
            id: _body
            anchors {
                top: root.showHeader ? _header.bottom : parent.top
                bottom: root.showComposer ? _composer.top : parent.bottom
                left: parent.left
                right: parent.right
            }
            padding: NovaTheme.spacingM
        }

        NovaFooter {
            id: _composer
            visible: root.showComposer
            height: root._composerH
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            tint: NovaTheme.surface
        }

        // 身份 C-1：会话头 —— 在线状态点（positive + 光晕环）+ 底缘品牌细线 + 右缘三点位
        // a11y: decorative
        Item {
            id: _headerIdentity
            anchors { top: _header.top; bottom: _header.bottom; left: _header.left; right: _header.right }
            visible: root.showHeader
            Rectangle {
                anchors { left: parent.left; leftMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
                width: 18; height: 18; radius: 9
                color: NovaTheme.positive
                opacity: 0.9
            }
            Rectangle {
                anchors { left: parent.left; leftMargin: NovaTheme.spacingM + 5; verticalCenter: parent.verticalCenter }
                width: 8; height: 8; radius: 4
                color: NovaTheme.positive
            }
            Row {
                anchors { right: parent.right; rightMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
                spacing: 5
                Rectangle { width: 4; height: 4; radius: 2; color: NovaTheme.textMuted; opacity: 0.9 }
                Rectangle { width: 4; height: 4; radius: 2; color: NovaTheme.textMuted; opacity: 0.9 }
                Rectangle { width: 4; height: 4; radius: 2; color: NovaTheme.textMuted; opacity: 0.9 }
            }
            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: NovaTheme.primary }
                    GradientStop { position: 1.0; color: NovaTheme.surface }
                }
                opacity: 0.9
            }
        }

        // 身份 C-2：AI 画布四角取景框（只占 body 四角，中央消息区完全留给业务注入）
        // a11y: decorative
        Item {
            id: _canvasIdentity
            anchors { fill: _body; margins: NovaTheme.spacingM }
            readonly property int _arm: 14
            // 左上
            Rectangle { anchors { top: parent.top; left: parent.left } width: _canvasIdentity._arm; height: 2; color: NovaTheme.primary; opacity: 0.85 }
            Rectangle { anchors { top: parent.top; left: parent.left } width: 2; height: _canvasIdentity._arm; color: NovaTheme.primary; opacity: 0.85 }
            // 右上
            Rectangle { anchors { top: parent.top; right: parent.right } width: _canvasIdentity._arm; height: 2; color: NovaTheme.primary; opacity: 0.85 }
            Rectangle { anchors { top: parent.top; right: parent.right } width: 2; height: _canvasIdentity._arm; color: NovaTheme.primary; opacity: 0.85 }
            // 左下
            Rectangle { anchors { bottom: parent.bottom; left: parent.left } width: _canvasIdentity._arm; height: 2; color: NovaTheme.secondary; opacity: 0.85 }
            Rectangle { anchors { bottom: parent.bottom; left: parent.left } width: 2; height: _canvasIdentity._arm; color: NovaTheme.secondary; opacity: 0.85 }
            // 右下
            Rectangle { anchors { bottom: parent.bottom; right: parent.right } width: _canvasIdentity._arm; height: 2; color: NovaTheme.secondary; opacity: 0.85 }
            Rectangle { anchors { bottom: parent.bottom; right: parent.right } width: 2; height: _canvasIdentity._arm; color: NovaTheme.secondary; opacity: 0.85 }
        }

        // 身份 C-3：浮起输入胶囊 —— outlined 透明胶囊轮廓（不遮挡业务输入框）+ 附加圆点 + 发送圆钮
        // a11y: decorative
        Item {
            id: _composerIdentity
            anchors { fill: _composer; margins: NovaTheme.spacingM }
            visible: root.showComposer
            Rectangle {
                anchors { fill: parent; leftMargin: NovaTheme.spacingL; rightMargin: 46 }
                radius: NovaTheme.radiusL
                color: "transparent"
                border { width: 1; color: NovaTheme.outline }
            }
            // 附加点（outlined 圆 + 十字）
            Rectangle {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                width: 24; height: 24; radius: 12
                color: "transparent"
                border { width: 1; color: NovaTheme.outline }
                Rectangle { anchors.centerIn: parent; width: 9; height: 1.5; radius: 1; color: NovaTheme.textMuted }
                Rectangle { anchors.centerIn: parent; width: 1.5; height: 9; radius: 1; color: NovaTheme.textMuted }
            }
            // 发送圆钮（primary 圆 + 纯几何右向箭头；rotation 组合，零字体依赖）
            Rectangle {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                width: 34; height: 34; radius: 17
                color: NovaTheme.primary
                Rectangle { anchors.centerIn: parent; width: 12; height: 2; radius: 1; color: NovaTheme.textOnPrimary }
                Rectangle { anchors.centerIn: parent; anchors.horizontalCenterOffset: 5; anchors.verticalCenterOffset: -3
                    width: 7; height: 2; radius: 1; rotation: 45; color: NovaTheme.textOnPrimary }
                Rectangle { anchors.centerIn: parent; anchors.horizontalCenterOffset: 5; anchors.verticalCenterOffset: 3
                    width: 7; height: 2; radius: 1; rotation: -45; color: NovaTheme.textOnPrimary }
            }
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
        color: NovaTheme.surfaceAlt
        clip: true
        visible: width > 0
        Behavior on width {
            NumberAnimation { duration: NovaMotion.duration(NovaMotion.transitionDuration); easing.type: NovaMotion.easingStandard }
        }
        Item { id: _detail; anchors.fill: parent }

        // 身份 D：详情栏 —— 三段分段 tab（首个激活）+ 内侧渐变缘轨 + 底部信息点
        // a11y: decorative
        Item {
            id: _detailIdentity
            anchors.fill: parent
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                width: 3
                gradient: Gradient {
                    GradientStop { position: 0.0; color: NovaTheme.secondary }
                    GradientStop { position: 1.0; color: NovaTheme.accent }
                }
            }
            Row {
                anchors { top: parent.top; topMargin: NovaTheme.spacingM; left: parent.left; leftMargin: NovaTheme.spacingM }
                spacing: NovaTheme.spacingS
                Rectangle { width: 40; height: 22; radius: 11; color: NovaTheme.primary; opacity: 0.85 }
                Rectangle { width: 40; height: 22; radius: 11; color: "transparent"; border { width: 1; color: NovaTheme.outline } }
                Rectangle { width: 40; height: 22; radius: 11; color: "transparent"; border { width: 1; color: NovaTheme.outline } }
            }
            Row {
                anchors { bottom: parent.bottom; bottomMargin: NovaTheme.spacingM; left: parent.left; leftMargin: NovaTheme.spacingM }
                spacing: 5
                Rectangle { width: 4; height: 4; radius: 2; color: NovaTheme.textMuted; opacity: 0.9 }
                Rectangle { width: 4; height: 4; radius: 2; color: NovaTheme.textMuted; opacity: 0.9 }
                Rectangle { width: 4; height: 4; radius: 2; color: NovaTheme.textMuted; opacity: 0.9 }
            }
        }
    }

    // ── 5. 浮层（弹窗 / 提示 / 加载遮罩）──
    Item {
        id: _overlay
        anchors.fill: parent
        z: NovaTheme.zFixedDrawer
    }

    // ── 顶层品牌签名线：三段品牌色发丝线横跨全宽（最后声明 → 恒在最上层，仅占顶部 2px）──
    // a11y: decorative
    Row {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 2
        z: NovaTheme.zMarginals
        Rectangle { width: parent.width / 3; height: 2; color: NovaTheme.primary }
        Rectangle { width: parent.width / 3; height: 2; color: NovaTheme.secondary }
        Rectangle { width: parent.width / 3; height: 2; color: NovaTheme.accent }
    }

    // 前置预判性：Esc 收起三条可折叠轨（只 emit 意图，宿主受控改 *Collapsed）
    focus: true
    Keys.onEscapePressed: {
        if (!root.navCollapsed) root.navToggled(true)
        if (!root.conversationCollapsed) root.conversationToggled(true)
        if (!root.detailCollapsed) root.detailToggled(true)
    }
}
