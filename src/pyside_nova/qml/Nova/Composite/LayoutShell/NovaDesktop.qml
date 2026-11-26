// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaDesktop.qml
// NovaDesktop 桌面应用根壳：窗口控制点 + 菜单栏 + 工具栏 + 页面 + 状态栏（对标 QMainWindow），组合态一致性契约（CC）落地
// 组合态（宪法 0.9.0）：_ 私有组合上下文统一三栏密度/层级/动效；栏高归零 + 恒定锚链（CC-5，消除 visible 三元跳变）；
//   每边界唯一分隔源；三色控制点收敛主色系、仿交互控件方块改抽象几何（CC-3）；槽位宿主铺满（CC-6）。
// 用法：向 menuSlot/toolbarSlot/pageSlot/statusSlot/overlaySlot 注入业务内容；根节点为应用窗口内容根，不含 ApplicationWindow
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

    property alias menuSlot: _menu.data
    property alias toolbarSlot: _toolbarHost.data
    property alias pageSlot: _page.content
    property alias statusSlot: _statusHost.data
    property alias overlaySlot: _overlay.data

    property bool showMenu: true
    property bool showToolbar: true
    property bool showStatus: true
    property int menuHeight: 32
    property int toolbarHeight: 48
    property int statusHeight: 28

    signal windowCloseRequested()

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面
    readonly property int _menuH: Math.max(24, Math.min(root.menuHeight, 120))
    readonly property int _toolbarH: Math.max(24, Math.min(root.toolbarHeight, 240))
    readonly property int _statusH: Math.max(24, Math.min(root.statusHeight, 120))

    // ── 组合上下文 CC-1（宪法 0.9.0）：三栏唯一密度 / 层级 / 动效 / 品牌色基准 ──
    // 禁止各栏散用 NovaTheme.spacing* 造成 padding 叠加；所有轨道一律引用本组常量
    readonly property real _unit: NovaTheme.spacingS              // 6px 密度栅格基元
    readonly property real _gap: root._unit * 2                    // 12 栏内统一边距
    readonly property real _radius: NovaTheme.radiusS
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    // ── 专属主题 · 石板蓝（色相 223°，偏移 -0.0260）──
    // 桌面根壳 · 沉稳系统基底；色相随 setBrand 漂移，饱和/明度系数独立定制（CC-3：组件内仍单色相）
    // _signatureOn：true=专属色相（默认）/ false=回归全局品牌蓝（亮色态）；私有令牌不进冻结面
    property bool _signatureOn: true
    readonly property real _themeHue: root._signatureOn
        ? (NovaTheme.primary.hsvHue + (-0.0260) + 1) % 1
        : NovaTheme.primary.hsvHue
    readonly property color _accent: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 0.66),
        Math.min(1, NovaTheme.primary.hsvValue * 0.66 * (NovaTheme.isDark ? 1.25 : 1)), 1)
    readonly property color _ink: root._accent
    // 单色系派生：同屏只出现主色系，消除红 / 黄 / 绿三色控制点撞色（CC-3）
    readonly property color _inkSoft: Qt.lighter(root._accent, 1.35)
    // ── Aurora Core · 极光核辉光（同色相提亮 + 中性白芯；CC-3 组件内仍单色相）──
    // 从本组件专属色相派生，setBrand 换肤同步平移；只用于身份焦点小面积点缀
    readonly property color _glow: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 0.78),
        Math.min(1, NovaTheme.primary.hsvValue * (NovaTheme.isDark ? 1.5 : 1.28)), 1)
    readonly property color _inkPale: Qt.lighter(root._accent, 1.7)

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 1. 菜单栏（高度归零 + 恒定锚链 CC-5；clip 保证收起动画全程可见）──
    Rectangle {
        id: _menuBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showMenu ? root._menuH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        // 该边界唯一分隔源（CC-2）：不再叠加缘轨 / 发丝线 / 顶层色带
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        // 身份 A：窗口控制点（主色系三档深浅的抽象几何，CC-3 不仿按钮 / 不撞色）
        // a11y: decorative
        Row {
            anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
            spacing: root._unit
            z: NovaTheme.zMarginals
            Rectangle { width: 9; height: 9; radius: 4.5; color: root._glow; opacity: 0.9 }
            Rectangle { width: 8; height: 8; radius: 4; color: root._inkSoft; opacity: 0.9 }
            Rectangle { width: 8; height: 8; radius: 4; color: root._inkPale; opacity: 0.9 }
        }

        // 业务菜单注入宿主：铺满菜单栏、避开左端控制点；注入顶层须 anchors.fill: parent（CC-6）
        Item {
            id: _menu
            anchors {
                top: parent.top; bottom: parent.bottom
                left: parent.left; leftMargin: root._gap * 5
                right: parent.right
            }
        }
    }

    // ── 2. 工具栏（锚链恒指 _menuBar.bottom，栏高归零驱动，不用 visible 三元）──
    Rectangle {
        id: _toolbar
        anchors { top: _menuBar.bottom; left: parent.left; right: parent.right }
        height: root.showToolbar ? root._toolbarH : 0
        clip: true
        color: root._rail
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        // 身份 B：段位递减条（抽象几何；替换原 26×26「看着能点却不能点」的仿交互控件方块）
        // a11y: decorative
        Row {
            anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
            spacing: root._unit
            z: NovaTheme.zMarginals
            Rectangle { width: 28; height: 4; radius: 2; color: root._ink; opacity: 0.9 }
            Rectangle { width: 18; height: 4; radius: 2; color: root._inkSoft; opacity: 0.9 }
            Rectangle { width: 10; height: 4; radius: 2; color: root._divider }
        }

        Item {
            id: _toolbarHost
            anchors { fill: parent; leftMargin: root._gap * 8 }
        }
    }

    // ── 3. 页面（CC-1：padding 归零，轨内边距由业务注入承担，消除三层叠加）──
    NovaPage {
        id: _page
        anchors {
            top: _toolbar.bottom
            bottom: _status.top
            left: parent.left
            right: parent.right
        }
        padding: 0
    }

    // ── 4. 状态栏（锚链恒指 _status.top，栏高归零驱动）──
    Rectangle {
        id: _status
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: root.showStatus ? root._statusH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }

        // 身份 C：状态指示点（主色系，抽象几何）
        // a11y: decorative
        Rectangle {
            anchors { left: parent.left; leftMargin: root._gap; verticalCenter: parent.verticalCenter }
            width: 6; height: 6; radius: 3
            color: root._ink
            opacity: 0.9
            z: NovaTheme.zMarginals
        }

        // 状态槽独立宿主：装饰层与业务注入层分离（CC-6）
        Item {
            id: _statusHost
            anchors { fill: parent; leftMargin: root._gap * 3 }
        }
    }

    Item {
        id: _overlay
        anchors.fill: parent
        z: NovaTheme.zMax
    }

    // 顶层品牌签名：2px 单色系发丝线（CC-3 主签名，只占顶部 2px）
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

    Keys.onEscapePressed: root.windowCloseRequested()
    focus: true
}
