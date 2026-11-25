// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaFlexLayout.qml
// NovaFlexLayout 企业大屏弹性布局壳：columns 驱动的浮起面板网格 + 自适应分栏（HMI / 工控大屏），组合态一致性契约（CC）落地
// 组合态（宪法 0.9.0）：_ 私有组合上下文统一网格密度/层级/动效；header/footer 高度归零 + 恒定锚链（CC-5）；
//   三色渐变底线与三色面板顶条收敛主色系（CC-3）；每边界唯一分隔源；槽位宿主铺满（CC-6）。
// 用法：向 headerSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；columns 与断点驱动分栏，缩放取 NovaScreen
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
    property alias footerSlot: _footerHost.data
    property alias overlaySlot: _overlay.data

    property bool showHeader: true
    property bool showFooter: false
    property int columns: 3            // 1~4 分栏数，钳制防非法入参
    property int headerHeight: 64
    property int footerHeight: 48
    property int gap: 8
    property bool scalable: true

    signal layoutChanged(int columns)

    readonly property int _cols: Math.max(1, Math.min(4, root.columns))

    // 鲁棒性：几何入参只读钳制（宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面
    readonly property int _headerH: Math.max(24, Math.min(root.headerHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))
    readonly property int _gap: Math.max(0, Math.min(root.gap, 64))

    // ── 组合上下文 CC-1（宪法 0.9.0）：面板网格唯一密度 / 层级 / 动效 / 品牌色基准 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _pad: root._gap
    readonly property real _radius: NovaTheme.radiusM
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _rail: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    readonly property color _ink: NovaTheme.primary
    // 单色系派生：替换原 primary / secondary / accent 三色撞色（CC-3）
    readonly property color _inkSoft: Qt.lighter(NovaTheme.primary, 1.35)
    readonly property color _inkPale: Qt.lighter(NovaTheme.primary, 1.7)

    implicitWidth: 1920
    implicitHeight: 1080

    onColumnsChanged: root.layoutChanged(root._cols)

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 1. Header（高度归零 + 恒定锚链 CC-5）──
    Rectangle {
        id: _header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showHeader ? root._headerH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        // 该边界唯一分隔源（CC-2）：表面色阶 + 1px 中性线，不再叠三色渐变底线
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }

        Item {
            id: _headerHost
            anchors.fill: parent
        }
    }

    // ── 2. 面板网格骨架（浮起面板底色；业务注入内容浮于其上，不再另铺一套不透明底板）──
    // a11y: decorative
    Row {
        id: _panelGrid
        anchors {
            top: _header.bottom
            bottom: _footer.top
            left: parent.left
            right: parent.right
            margins: root._pad
        }
        spacing: root._pad
        Repeater {
            model: root._cols
            Rectangle {
                required property int index
                width: (parent.width - (root._cols - 1) * root._pad) / root._cols
                height: parent.height
                radius: root._radius
                color: root._panel
                border { width: 1; color: root._divider }
                // 分栏数变化时面板宽度平滑过渡（CC-5 动效同步）
                Behavior on width {
                    NumberAnimation { duration: root._dur; easing.type: root._ease }
                }
            }
        }
    }

    // 面板顶条覆盖层：主色系三档深浅，抽象几何（CC-3 禁止三色撞色 / 仿分段 tab）
    // a11y: decorative
    Row {
        anchors { fill: _panelGrid }
        spacing: root._pad
        z: NovaTheme.zMarginals
        Repeater {
            model: root._cols
            Item {
                required property int index
                // 委托作用域内解析 index，内层 Rectangle 走 parent 限定，避免 qmllint unqualified
                readonly property color _tone: index === 0 ? root._ink
                                              : (index === 1 ? root._inkSoft : root._inkPale)
                width: (parent.width - (root._cols - 1) * root._pad) / root._cols
                height: parent.height
                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 3
                    color: parent._tone
                    opacity: 0.9
                }
                Behavior on width {
                    NumberAnimation { duration: root._dur; easing.type: root._ease }
                }
            }
        }
    }

    // ── 3. 内容区（锚链恒指 _header.bottom / _footer.top；padding 与网格同值，CC-1）──
    NovaPage {
        id: _body
        anchors {
            top: _header.bottom
            bottom: _footer.top
            left: parent.left
            right: parent.right
        }
        padding: root._pad
    }

    // ── 4. Footer（高度归零 + 恒定锚链）──
    Rectangle {
        id: _footer
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: root.showFooter ? root._footerH : 0
        clip: true
        color: root._panel
        z: NovaTheme.zMarginals
        Behavior on height {
            NumberAnimation { duration: root._dur; easing.type: root._ease }
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }

        Item {
            id: _footerHost
            anchors.fill: parent
        }
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zMax }

    // 顶层品牌签名：2px 单色系发丝线（CC-3 主签名，与 Chat / Desktop / Mobile 同族）
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
}
