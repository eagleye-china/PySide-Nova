// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaMobile.qml
// NovaMobile 移动应用根壳：安全区 + 灵动岛 + 内容 + 底部导航 + home indicator（对标 Quasar QLayout mobile），组合态一致性契约（CC）落地
// 组合态（宪法 0.9.0）：_ 私有组合上下文统一安全区/头/底栏密度与动效；栏高归零 + 恒定锚链（CC-5）；
//   每边界唯一分隔源；灵动岛与 home indicator 收敛主色系抽象几何（CC-3）；槽位宿主铺满（CC-6）。
// 用法：向 headerSlot/contentSlot/bottomNavSlot/overlaySlot 注入业务内容；安全区由 safeTop/safeBottom 属性注入
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services
import Nova.Design

Item {
    id: root
    // 鲁棒性 / i18n：声明式容器随 RTL 镜像；逻辑侧槽位语义恒定（宪法第 7 章第 3 条）
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias headerSlot: _headerHost.data
    property alias contentSlot: _body.content
    property alias bottomNavSlot: _bottomNav.data
    property alias overlaySlot: _overlay.data

    property bool showHeader: true
    property bool showBottomNav: true
    property int safeTop: 0
    property int safeBottom: 0
    property int headerHeight: 56
    property int bottomNavHeight: 60
    property bool isTouch: NovaPlatform.isMobile

    signal backRequested()

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面
    // 前置预判性（坑位 20）：四条 chrome 轨共享高度预算，任何非法入参组合下内容区恒 ≥ 父高 28%，
    // 杜绝「安全区 + Header + 安全区 + Nav」叠加超过窗口高度导致 NovaPage 负高。
    readonly property real _chromeCap: Math.max(0, height) * 0.18
    readonly property int _safeT: Math.max(0, Math.min(root.safeTop, 160, root._chromeCap))
    readonly property int _safeB: Math.max(0, Math.min(root.safeBottom, 160, root._chromeCap))
    readonly property int _headerH: Math.max(Math.min(24, root._chromeCap), Math.min(root.headerHeight, 240, root._chromeCap))
    readonly property int _navH: Math.max(Math.min(24, root._chromeCap), Math.min(root.bottomNavHeight, 240, root._chromeCap))

    // ── 组合上下文 CC-1（宪法 0.9.0）：安全区 / 头 / 底栏唯一密度 / 层级 / 动效 / 品牌色基准 ──
    readonly property real _unit: NovaTheme.spacingS              // 6px 密度栅格基元
    readonly property real _gap: root._unit * 2                     // 12 轨内统一边距
    readonly property real _radius: NovaTheme.radiusM
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    // ── 专属主题 · 天青（色相 193°，偏移 -0.1110）──
    // 移动根壳 · 天青轻盈；色相随 setBrand 漂移，饱和/明度系数独立定制（CC-3：组件内仍单色相）
    // _signatureOn：true=专属色相（默认）/ false=回归全局品牌蓝（亮色态）；私有令牌不进冻结面
    property bool _signatureOn: true
    readonly property real _themeHue: root._signatureOn
        ? (NovaTheme.primary.hsvHue + (-0.1110) + 1) % 1
        : NovaTheme.primary.hsvHue
    readonly property color _accent: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 1.00),
        Math.min(1, NovaTheme.primary.hsvValue * 0.95 * (NovaTheme.isDark ? 1.25 : 1)), 1)
    readonly property color _ink: root._accent
    readonly property color _inkSoft: Qt.lighter(root._accent, 1.35)
    // ── Aurora Core · 极光核辉光（同色相提亮 + 中性白芯；CC-3 组件内仍单色相）──
    // 从本组件专属色相派生，setBrand 换肤同步平移；只用于身份焦点小面积点缀
    readonly property color _glow: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 0.78),
        Math.min(1, NovaTheme.primary.hsvValue * (NovaTheme.isDark ? 1.5 : 1.28)), 1)

    implicitWidth: 390
    implicitHeight: 844

    // 应用身份图标（私有 _ 前缀不进冻结面，decorative）
    readonly property url _appIcon: "qrc:/icons/app-mobile"

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

    // ── 1. 顶部安全区（刘海 / 状态栏）；高度恒定，不参与折叠 ──
    Item {
        id: _safeTop
        height: root._safeT
        anchors { top: parent.top; left: parent.left; right: parent.right }

        // 身份 A：灵动岛（居中胶囊 + 摄像头点，主色系抽象几何；不仿按钮）
        // a11y: decorative
        Rectangle {
            z: NovaTheme.zMarginals
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 4 }
            width: 96; height: 20; radius: 10
            // 深色主题下硬件黑胶囊会与 page 糊成一片、只剩摄像头孤点；改用提亮的表面色 + 描边保持可辨（装配态审计实测）
            color: NovaTheme.isDark ? Qt.lighter(NovaTheme.surfaceAlt, 1.35) : NovaTheme.dark
            border { width: NovaTheme.isDark ? 1 : 0; color: NovaTheme.outlineStrong }
            opacity: 0.9
            Rectangle {
                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                width: 9; height: 9; radius: 4.5
                color: root._glow
                opacity: 0.9
                Rectangle { anchors.centerIn: parent; width: 4; height: 4; radius: 2; color: NovaTheme.surface }
            }
        }
    }

    // ── 2. Header（高度归零 + 恒定锚链 CC-5；clip 保证收起动画全程可见）──
    Rectangle {
        id: _header
        anchors { top: _safeTop.bottom; left: parent.left; right: parent.right }
        height: root.showHeader ? root._headerH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        // 业务头注入宿主：铺满整个 Header（CC-6 注入顶层须 anchors.fill: parent）
        Item {
            id: _headerHost
            anchors.fill: parent
        }
    }

    // ── 3. 内容区（锚链恒指 _header.bottom / _bottomNavWrap.top，不用 visible 三元）──
    NovaPage {
        id: _body
        anchors {
            top: _header.bottom
            bottom: _bottomNavWrap.top
            left: parent.left
            right: parent.right
        }
        // CC-1：轨内边距统一走组合上下文，业务注入不再叠加 padding
        padding: root._gap
    }

    NovaSeparator {
        anchors { top: _body.top; left: _body.left; right: _body.right }
        z: NovaTheme.zMarginals
    }

    // ── 4. 底部导航 + 安全区（高度含 _safeB；隐藏时仅保留安全区，锚链恒定）──
    Rectangle {
        id: _bottomNavWrap
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: root._safeB + (root.showBottomNav ? root._navH : 0)
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }

        // 身份 B：home indicator（底部居中横条，中性色抽象几何）
        // a11y: decorative
        Rectangle {
            z: NovaTheme.zMarginals
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: Math.max(4, root._safeB / 2)
            }
            width: 108; height: 4; radius: 2
            color: NovaTheme.outlineStrong
            opacity: 0.9
        }

        // 业务底导航宿主：让出安全区高度；隐藏态高度为 0，内容自然被裁
        Item {
            id: _bottomNav
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: root._safeB
            }
        }
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFullscreen }

    // 顶层品牌签名：2px 单色系发丝线（CC-3 主签名，与 Chat / Desktop 同族）
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

    focus: true
    Keys.onBackPressed: root.backRequested()
}
