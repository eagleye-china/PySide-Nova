// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaOrbit.qml
// NovaOrbit 意图轨道工作台壳：全局栏 + 轨道态势栏 + 意图场 + 活产物画布（NovaChat 天花板形态）
// 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全轨共享；
//   相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（轨道发丝线 / 递减轨道链 /
//   并行分叉角标 / 双向箭头环 / 拓扑点阵），不仿交互控件、不同屏撞色；折叠锚链恒定。
// 用法：向 globalSlot/railSlot/intentSlot/composerSlot/canvasSlot/mapSlot/overlaySlot 注入业务内容；
//   Shell 只托管布局与折叠意图，不含轨道注册表、信号感知器、实体路由、产物对象等业务语义。
// 治理边界（设计文档 §3）：Orbit Engine / Entity Router / 孵化轨道确认闸门均为业务层职责，由槽位注入；
//   Shell 仅以轨道地图槽与浮层槽预留其呈现位置，绝不自动把孵化轨道转为执行轨道。
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
    property alias globalSlot: _global.data
    property alias railSlot: _rail.data
    property alias intentSlot: _intent.content
    property alias composerSlot: _composer.data
    property alias canvasSlot: _canvas.content
    property alias mapSlot: _map.data
    property alias overlaySlot: _overlay.data

    // ── 配置属性（默认值来自令牌，进冻结面）──
    property real railSize: 260
    property real canvasSize: 320
    property int globalHeight: 52
    property int composerHeight: 72
    property int mapHeight: 120
    property bool showGlobal: true
    property bool showRail: true
    property bool showCanvas: true
    property bool showComposer: true
    property bool showMap: true
    property bool railCollapsed: false
    property bool canvasCollapsed: false
    property int breakpoint: 1100
    property bool bordered: true

    // ── 受控契约：只 emit，不自写宿主状态 ──
    signal railToggled(bool collapsed)
    signal canvasToggled(bool collapsed)
    signal orbitRequested()
    function toggleRail() { root.railToggled(!root.railCollapsed) }
    function toggleCanvas() { root.canvasToggled(!root.canvasCollapsed) }
    function requestOrbit() { root.orbitRequested() }

    readonly property bool belowBreakpoint: width > 0 && width < root.breakpoint

    implicitWidth: 1440
    implicitHeight: 900

    // 非法入参钳制（宪法第 7 章第 1 条）：极端值下几何有限非负
    readonly property real _railW: Math.max(180, Math.min(root.railSize, width / 3 || root.railSize))
    readonly property real _canvasW: Math.max(200, Math.min(root.canvasSize, width / 3 || root.canvasSize))
    readonly property int _globalH: Math.max(24, Math.min(root.globalHeight, 240))
    readonly property int _composerH: Math.max(24, Math.min(root.composerHeight, 360))
    readonly property int _mapH: Math.max(24, Math.min(root.mapHeight, 480))

    // ── 组合上下文 CC-1：全轨唯一密度/层级/动效/品牌色基准 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property real _radius: NovaTheme.radiusM
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _railBg: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    // ── 专属主题 · 靛青（色相 243°，偏移 +0.0290）──
    // 意图轨道 · 靛青深邃、感知；色相随 setBrand 漂移，饱和/明度系数独立定制（CC-3：组件内仍单色相）
    readonly property real _themeHue: (NovaTheme.primary.hsvHue + (0.0290) + 1) % 1
    readonly property color _accent: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 0.94),
        Math.min(1, NovaTheme.primary.hsvValue * 0.98 * (NovaTheme.isDark ? 1.25 : 1)), 1)
    readonly property color _ink: root._accent
    readonly property color _inkSoft: Qt.lighter(root._accent, 1.35)
    // ── Aurora Core · 极光核辉光（同色相提亮 + 中性白芯；CC-3 组件内仍单色相）──
    // 从本组件专属色相派生，setBrand 换肤同步平移；只用于身份焦点小面积点缀
    readonly property color _glow: Qt.hsva(root._themeHue,
        Math.min(1, NovaTheme.primary.hsvSaturation * 0.78),
        Math.min(1, NovaTheme.primary.hsvValue * (NovaTheme.isDark ? 1.5 : 1.28)), 1)

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 1. 全局栏（身份 · 租户 · 全局搜索 · 通知；NovaChat 基座呈现位）──
    Item {
        id: _globalBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.showGlobal ? root._globalH : 0
        clip: true
        z: NovaTheme.zMarginals
        Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

        NovaHeader {
            id: _global
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: root._globalH
            tint: root._panel
        }

        // 全局栏 / 主体唯一边界：1px 中性分隔（CC-2）
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1
            color: root._divider
            z: NovaTheme.zMarginals
        }

        // 身份 A-1：三段轨道发丝线（列首，主色系单色渐变；不仿 tab / 按钮）
        // a11y: decorative
        Item {
            anchors { left: parent.left; top: parent.top; leftMargin: root._gap }
            width: 72; height: 2
            z: NovaTheme.zMarginals
            Row {
                spacing: root._unit
                Rectangle { width: 24; height: 2; color: root._ink; opacity: 0.9 }
                Rectangle { width: 16; height: 2; color: root._inkSoft; opacity: 0.9 }
                Rectangle { width: 8; height: 2; color: root._divider; opacity: 0.9 }
            }
        }
    }

    // ── 2. 左栏 Orbit Rail（活跃轨道 + 感知信号 + 能力召回 + 执行实体切换）──
    Rectangle {
        id: _railWrap
        anchors { top: _globalBar.bottom; bottom: parent.bottom; left: parent.left }
        width: (root.showRail && !root.railCollapsed && !root.belowBreakpoint) ? root._railW : 0
        color: root._railBg
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }
        Item { id: _rail; anchors.fill: parent }

        // 身份 A-2（抽象几何）：列首递减轨道链 + 右缘主色渐变轨 + 列尾感知信号弧点
        // a11y: decorative
        Item {
            id: _railIdentity
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
                Rectangle { width: 10; height: 3; radius: 1.5; color: root._ink; opacity: 0.9 }
                Rectangle { width: 6; height: 1; y: 1; color: root._divider }
                Rectangle { width: 7; height: 3; radius: 1.5; color: root._inkSoft; opacity: 0.9 }
                Rectangle { width: 6; height: 1; y: 1; color: root._divider }
                Rectangle { width: 4; height: 3; radius: 1.5; color: root._divider; opacity: 0.9 }
            }
            // 感知信号弧点（三段递减圆点，纯几何，不仿状态灯组）
            Row {
                anchors { bottom: parent.bottom; bottomMargin: root._gap; left: parent.left; leftMargin: root._gap }
                spacing: root._unit
                Rectangle { width: 7; height: 7; radius: 3.5; color: root._glow; opacity: 0.9 }
                Rectangle { width: 4; height: 4; radius: 2; y: 1; color: root._inkSoft; opacity: 0.9 }
                Rectangle { width: 3; height: 3; radius: 1.5; y: 1.5; color: root._divider; opacity: 0.9 }
            }
        }
    }

    NovaSeparator {
        id: _railSep
        anchors { top: _globalBar.bottom; bottom: parent.bottom; left: _railWrap.right }
        vertical: true
        visible: root.bordered && _railWrap.width > 0
        z: NovaTheme.zMarginals
    }

    // ── 3. 中栏 Intent Field（多轨道并行意图场 + 统一意图输入栏）──
    Item {
        id: _center
        anchors {
            top: _globalBar.bottom
            bottom: parent.bottom
            left: _railWrap.right
            right: _canvasWrap.left
        }

        NovaPage {
            id: _intent
            anchors {
                top: parent.top
                bottom: _composerBar.top
                left: parent.left
                right: parent.right
            }
            padding: root._gap
        }

        // 身份 B-1：并行分叉角标 + 对角取景框（中央完全留给业务注入）
        // a11y: decorative；margins 钳制避免极端入参负几何
        Item {
            id: _intentIdentity
            anchors {
                fill: _intent
                margins: Math.max(0, Math.min(root._gap, Math.min(_intent.width, _intent.height) / 2))
            }
            z: NovaTheme.zMarginals
            readonly property int _arm: 10
            Rectangle { anchors { top: parent.top; left: parent.left } width: _intentIdentity._arm; height: 1; color: root._ink; opacity: 0.9 }
            Rectangle { anchors { top: parent.top; left: parent.left } width: 1; height: _intentIdentity._arm; color: root._ink; opacity: 0.9 }
            // 分叉：从左上角引出的两条递减短线（并行轨道意象，不仿连线按钮）
            Rectangle {
                anchors { top: parent.top; left: parent.left; topMargin: root._unit * 3; leftMargin: root._unit * 3 }
                width: 16; height: 1; color: root._inkSoft; opacity: 0.9
                transform: Rotation { angle: 32; origin.x: 0; origin.y: 0 }
            }
            Rectangle {
                anchors { top: parent.top; left: parent.left; topMargin: root._unit * 5; leftMargin: root._unit * 3 }
                width: 11; height: 1; color: root._divider; opacity: 0.9
                transform: Rotation { angle: -18; origin.x: 0; origin.y: 0 }
            }
            Rectangle { anchors { bottom: parent.bottom; right: parent.right } width: _intentIdentity._arm; height: 1; color: root._inkSoft; opacity: 0.9 }
            Rectangle { anchors { bottom: parent.bottom; right: parent.right } width: 1; height: _intentIdentity._arm; color: root._inkSoft; opacity: 0.9 }
        }

        // 3b. 统一意图输入栏（轨道调度器；栏高归零 + 恒定锚链 CC-5）
        Item {
            id: _composerBar
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: root.showComposer ? root._composerH : 0
            clip: true
            z: NovaTheme.zMarginals
            Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

            NovaFooter {
                id: _composer
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._composerH
                tint: root._panel
            }
            // intent / composer 唯一边界：1px 中性分隔
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: 1
                color: root._divider
                z: NovaTheme.zMarginals
            }
            // 身份 B-2：轨道路由三段短条（纯几何，不仿输入框 / 追加按钮）
            // a11y: decorative
            Item {
                anchors.fill: parent
                z: NovaTheme.zMarginals
                Row {
                    anchors { left: parent.left; leftMargin: root._gap; top: parent.top; topMargin: root._unit }
                    spacing: root._unit
                    Rectangle { width: 28; height: 2; radius: 1; color: root._ink; opacity: 0.9 }
                    Rectangle { width: 18; height: 2; radius: 1; color: root._inkSoft; opacity: 0.9 }
                    Rectangle { width: 10; height: 2; radius: 1; color: root._divider; opacity: 0.9 }
                }
            }
        }
    }

    // ── 4. 右栏 Live Canvas（活产物画布 + 全局轨道地图）──
    NovaSeparator {
        id: _canvasSep
        anchors { top: _globalBar.bottom; bottom: parent.bottom; right: _canvasWrap.left }
        vertical: true
        visible: root.bordered && _canvasWrap.width > 0
        z: NovaTheme.zMarginals
    }

    Rectangle {
        id: _canvasWrap
        anchors { top: _globalBar.bottom; bottom: parent.bottom; right: parent.right }
        width: (root.showCanvas && !root.canvasCollapsed && !root.belowBreakpoint) ? root._canvasW : 0
        color: root._railBg
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }

        NovaPage {
            id: _canvas
            anchors {
                top: parent.top
                bottom: _mapBar.top
                left: parent.left
                right: parent.right
            }
            padding: root._gap
        }

        // 身份 C-1：双向箭头环（产物可再入轨的抽象几何，不仿拖拽手柄）
        // a11y: decorative；margins 钳制避免极端入参负几何
        Item {
            id: _canvasIdentity
            anchors {
                fill: _canvas
                margins: Math.max(0, Math.min(root._gap, Math.min(_canvas.width, _canvas.height) / 2))
            }
            z: NovaTheme.zMarginals
            Rectangle {
                anchors { top: parent.top; right: parent.right; rightMargin: root._unit }
                width: 14; height: 2; color: root._ink; opacity: 0.9
                transform: Rotation { angle: 42; origin.x: 7; origin.y: 1 }
            }
            Rectangle {
                anchors { top: parent.top; right: parent.right; rightMargin: root._unit; topMargin: 5 }
                width: 14; height: 2; color: root._inkSoft; opacity: 0.9
                transform: Rotation { angle: -42; origin.x: 7; origin.y: 1 }
            }
            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; leftMargin: root._unit }
                width: 5; height: 5; radius: 2.5; color: root._inkSoft; opacity: 0.9
            }
        }

        // 4b. 全局轨道地图（拓扑视图；栏高归零 + 恒定锚链）
        Item {
            id: _mapBar
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: root.showMap ? root._mapH : 0
            clip: true
            z: NovaTheme.zMarginals
            Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

            NovaFooter {
                id: _map
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._mapH
                tint: root._panel
            }
            // canvas / map 唯一边界：1px 中性分隔
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: 1
                color: root._divider
                z: NovaTheme.zMarginals
            }
            // 身份 C-2：轨道拓扑点阵（3×3 递减圆点，纯几何，不仿缩略图按钮）
            // a11y: decorative
            Item {
                anchors.fill: parent
                z: NovaTheme.zMarginals
                Column {
                    anchors { right: parent.right; rightMargin: root._gap; top: parent.top; topMargin: root._unit }
                    spacing: root._unit
                    Repeater {
                        model: 3
                        Row {
                            required property int index
                            spacing: root._unit
                            Repeater {
                                model: 3
                                Rectangle {
                                    required property int index
                                    width: 3; height: 3; radius: 1.5
                                    color: index === 0 ? root._ink : root._inkSoft
                                    opacity: 0.9
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── 5. 浮层（孵化轨道确认卡 / 提示 / 加载遮罩；业务注入须为透明 Item）──
    Item {
        id: _overlay
        anchors.fill: parent
        z: NovaTheme.zFixedDrawer
    }

    // 顶层品牌签名：2px 单色系轨道发丝线（CC-3）
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
        if (!root.railCollapsed) root.railToggled(true)
        if (!root.canvasCollapsed) root.canvasToggled(true)
    }
}
