// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaIncubator.qml
// NovaIncubator 应用孵化器工作台壳：全局栏 + 配方库 + 孵化舞台 + CARF 四阶段条 + 三重校验 + 封版证书 + 浮层
// 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全槽共享；
//   相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（递进楔形 / 五列配方栅 / 七区分格环 /
//   四节点收敛链 / 三道校验刻线 / 方章折角），不仿交互控件、不同屏撞色；折叠锚链恒定。
// 用法：向 globalSlot/recipeSlot/stageSlot/pipelineSlot/validateSlot/certificateSlot/overlaySlot 注入业务内容；
//   Shell 只托管布局与折叠意图，不含配方注册表、配方解释器、组件装配器、治理注入器、
//   三重校验器、封版证书签发器等业务语义。
// 治理边界（封版法源）：孵化内核 / 三重校验 / 证书签发 / 人工确认闸门均为业务层职责，由槽位注入；
//   Shell 仅以浮层槽预留确认闸门呈现位置，绝不自动封版、绝不自动执行。
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
    property alias recipeSlot: _recipe.data
    property alias stageSlot: _stage.content
    property alias pipelineSlot: _pipeline.data
    property alias validateSlot: _validate.content
    property alias certificateSlot: _certificate.data
    property alias overlaySlot: _overlay.data

    // ── 配置属性（默认值来自令牌，进冻结面）──
    property real recipeSize: 260
    property real validateSize: 340
    property int globalHeight: 52
    property int pipelineHeight: 64
    property int certificateHeight: 160
    property bool showGlobal: true
    property bool showRecipe: true
    property bool showValidate: true
    property bool showPipeline: true
    property bool showCertificate: true
    property bool recipeCollapsed: false
    property bool validateCollapsed: false
    property int breakpoint: 1100
    property bool bordered: true

    // ── 受控契约：只 emit，不自写宿主状态 ──
    signal recipeToggled(bool collapsed)
    signal validateToggled(bool collapsed)
    signal freezeRequested()
    function toggleRecipe() { root.recipeToggled(!root.recipeCollapsed) }
    function toggleValidate() { root.validateToggled(!root.validateCollapsed) }
    function requestFreeze() { root.freezeRequested() }

    readonly property bool belowBreakpoint: width > 0 && width < root.breakpoint

    implicitWidth: 1440
    implicitHeight: 900

    // 非法入参钳制（宪法第 7 章第 1 条）：极端值下几何有限非负
    readonly property real _recipeW: Math.max(180, Math.min(root.recipeSize, width / 3 || root.recipeSize))
    readonly property real _validateW: Math.max(200, Math.min(root.validateSize, width / 3 || root.validateSize))
    readonly property int _globalH: Math.max(24, Math.min(root.globalHeight, 240))
    readonly property int _pipelineH: Math.max(24, Math.min(root.pipelineHeight, 360))
    readonly property int _certH: Math.max(24, Math.min(root.certificateHeight, 480))

    // ── 组合上下文 CC-1：全槽唯一密度 / 层级 / 动效 / 品牌色基准 ──
    readonly property real _unit: NovaTheme.spacingS
    readonly property real _gap: root._unit * 2
    readonly property real _radius: NovaTheme.radiusM
    readonly property int _dur: NovaMotion.duration(NovaMotion.transitionDuration)
    readonly property int _ease: NovaMotion.easingStandard
    readonly property color _divider: NovaTheme.outline
    readonly property color _railBg: NovaTheme.surfaceAlt
    readonly property color _panel: NovaTheme.surface
    // ── 专属主题 · 紫晶（色相 283°，偏移 +0.1390）──
    // 应用孵化 · 紫晶孕育、CARF 收敛；色相随 setBrand 漂移，饱和/明度系数独立定制（CC-3：组件内仍单色相）
    readonly property real _themeHue: (NovaTheme.primary.hsvHue + (0.1390) + 1) % 1
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

    // ── 1. 全局栏（身份 · 配方代号 · 封版状态；孵化工作台基座呈现位）──
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

        // 身份 A-1：四级递进楔形条（CARF 四阶段收敛到巅峰；列首，主色系单色，不仿 tab / 按钮）
        // a11y: decorative
        Item {
            anchors { left: parent.left; bottom: parent.bottom; leftMargin: root._gap; bottomMargin: root._unit }
            width: 72; height: 10
            z: NovaTheme.zMarginals
            Rectangle { x: 0;  y: 8; width: 24; height: 2;  color: root._ink;     opacity: 0.9 }
            Rectangle { x: 26; y: 6; width: 18; height: 4;  color: root._ink;     opacity: 0.9 }
            Rectangle { x: 46; y: 3; width: 12; height: 7;  color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 60; y: 0; width: 8;  height: 10; color: root._inkSoft; opacity: 0.9 }
        }
    }

    // ── 2. 左栏 配方库（R1~R5 五套配方 + 七区契约导航）──
    Rectangle {
        id: _recipeWrap
        anchors { top: _globalBar.bottom; bottom: parent.bottom; left: parent.left }
        width: (root.showRecipe && !root.recipeCollapsed && !root.belowBreakpoint) ? root._recipeW : 0
        color: root._railBg
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }
        Item { id: _recipe; anchors.fill: parent }

        // 身份 A-2（抽象几何）：列首五列配方栅 + 列尾七刻点
        // a11y: decorative
        Item {
            id: _recipeIdentity
            anchors.fill: parent
            z: NovaTheme.zMarginals
            Row {
                anchors { top: parent.top; topMargin: root._gap; left: parent.left; leftMargin: root._gap }
                spacing: root._unit
                Repeater {
                    model: 5
                    Rectangle {
                        required property int index
                        width: 3; height: 10 + index * 3
                        color: index === 0 ? root._ink : root._inkSoft
                        opacity: 0.9
                    }
                }
            }
            Column {
                anchors { bottom: parent.bottom; bottomMargin: root._gap; left: parent.left; leftMargin: root._gap }
                spacing: 3
                Repeater {
                    model: 7
                    Rectangle {
                        required property int index
                        width: Math.max(2, 6 - index * 0.4); height: 2; radius: 1
                        color: index < 3 ? root._inkSoft : root._divider
                        opacity: 0.9
                    }
                }
            }
        }
    }

    NovaSeparator {
        id: _recipeSep
        anchors { top: _globalBar.bottom; bottom: parent.bottom; left: _recipeWrap.right }
        vertical: true
        visible: root.bordered && _recipeWrap.width > 0
        z: NovaTheme.zMarginals
    }

    // ── 3. 中栏 孵化舞台（四阶段流水线主内容 + CARF 四阶段条）──
    Item {
        id: _center
        anchors {
            top: _globalBar.bottom
            bottom: parent.bottom
            left: _recipeWrap.right
            right: _validateWrap.left
        }

        NovaPage {
            id: _stage
            anchors {
                top: parent.top
                bottom: _pipelineBar.top
                left: parent.left
                right: parent.right
            }
            padding: root._gap
        }

        // 身份 B-1：七区分格环 + 中心孵化点（右上角标，中央完全留给业务注入）
        // a11y: decorative
        Item {
            id: _stageIdentity
            anchors { top: _stage.top; right: _stage.right; topMargin: root._gap; rightMargin: root._gap }
            width: 40; height: 40
            z: NovaTheme.zMarginals
            Repeater {
                model: 7
                Rectangle {
                    required property int index
                    x: 17 + 14 * Math.cos(index * 2 * Math.PI / 7)
                    y: 17 + 14 * Math.sin(index * 2 * Math.PI / 7)
                    width: 6; height: 2; radius: 1
                    rotation: index * (360 / 7)
                    color: index === 0 ? root._ink : root._inkSoft
                    opacity: 0.9
                }
            }
            Rectangle {
                anchors.centerIn: parent
                width: 9; height: 9; radius: 4.5
                color: root._glow
                opacity: 0.9
                Rectangle { anchors.centerIn: parent; width: 4; height: 4; radius: 2; color: NovaTheme.surface }
            }
        }

        // 3b. CARF 四阶段条（Conceive → Achieve → Refine → Freeze；栏高归零 + 恒定锚链 CC-5）
        Item {
            id: _pipelineBar
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: root.showPipeline ? root._pipelineH : 0
            clip: true
            z: NovaTheme.zMarginals
            Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

            NovaFooter {
                id: _pipeline
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._pipelineH
                tint: root._panel
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: 1
                color: root._divider
                z: NovaTheme.zMarginals
            }
            // 身份 B-2：四节点收敛链（节点由散到聚，指向封版；纯几何，不仿步骤条 / 按钮）
            // a11y: decorative
            Item {
                anchors { left: parent.left; leftMargin: root._gap; top: parent.top; topMargin: root._unit }
                width: 90; height: 12
                z: NovaTheme.zMarginals
                Rectangle { x: 0;  y: 5; width: 8;  height: 2; color: root._divider; opacity: 0.9 }
                Rectangle { x: 24; y: 4; width: 6;  height: 6; radius: 3;   color: root._ink;     opacity: 0.9 }
                Rectangle { x: 34; y: 5; width: 12; height: 2; color: root._divider; opacity: 0.9 }
                Rectangle { x: 50; y: 4; width: 5;  height: 5; radius: 2.5; color: root._ink;     opacity: 0.9 }
                Rectangle { x: 59; y: 5; width: 8;  height: 2; color: root._inkSoft; opacity: 0.9 }
                Rectangle { x: 70; y: 4; width: 4;  height: 4; radius: 2;   color: root._inkSoft; opacity: 0.9 }
                Rectangle { x: 77; y: 5; width: 5;  height: 2; color: root._ink;     opacity: 0.9 }
                Rectangle { x: 84; y: 3; width: 4;  height: 8; color: root._ink;     opacity: 0.9 }
            }
        }
    }

    // ── 4. 右栏 三重校验 + 封版证书 ──
    NovaSeparator {
        id: _validateSep
        anchors { top: _globalBar.bottom; bottom: parent.bottom; right: _validateWrap.left }
        vertical: true
        visible: root.bordered && _validateWrap.width > 0
        z: NovaTheme.zMarginals
    }

    Rectangle {
        id: _validateWrap
        anchors { top: _globalBar.bottom; bottom: parent.bottom; right: parent.right }
        width: (root.showValidate && !root.validateCollapsed && !root.belowBreakpoint) ? root._validateW : 0
        color: root._railBg
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: root._ease } }

        NovaPage {
            id: _validate
            anchors {
                top: parent.top
                bottom: _certBar.top
                left: parent.left
                right: parent.right
            }
            padding: root._gap
        }

        // 身份 C-1：三道递减校验刻线 + 收敛角（右上角标，不仿状态灯组）
        // a11y: decorative
        Item {
            id: _validateIdentity
            anchors { top: _validate.top; right: _validate.right; topMargin: root._gap; rightMargin: root._gap }
            width: 30; height: 24
            z: NovaTheme.zMarginals
            Rectangle { x: 0; y: 0;  width: 26; height: 2; color: root._ink;     opacity: 0.9 }
            Rectangle { x: 0; y: 6;  width: 18; height: 2; color: root._inkSoft; opacity: 0.9 }
            Rectangle { x: 0; y: 12; width: 10; height: 2; color: root._inkSoft; opacity: 0.9 }
            Rectangle { anchors { right: parent.right; bottom: parent.bottom } width: 8; height: 1; color: root._ink; opacity: 0.9 }
            Rectangle { anchors { right: parent.right; bottom: parent.bottom } width: 1; height: 8; color: root._ink; opacity: 0.9 }
        }

        // 4b. 封版证书栏（五件套预览 / 签发状态）
        Item {
            id: _certBar
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: root.showCertificate ? root._certH : 0
            clip: true
            z: NovaTheme.zMarginals
            Behavior on height { NumberAnimation { duration: root._dur; easing.type: root._ease } }

            NovaFooter {
                id: _certificate
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: root._certH
                tint: root._panel
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: 1
                color: root._divider
                z: NovaTheme.zMarginals
            }
            // 身份 C-2：方章折角 + 封蜡点（纯几何，不仿按钮 / 徽章）
            // a11y: decorative
            Item {
                anchors { right: parent.right; rightMargin: root._gap; top: parent.top; topMargin: root._unit }
                width: 20; height: 20
                z: NovaTheme.zMarginals
                Rectangle { anchors { top: parent.top; left: parent.left; right: parent.right } height: 1; color: root._ink; opacity: 0.9 }
                Rectangle { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } height: 1; color: root._inkSoft; opacity: 0.9 }
                Rectangle { anchors { top: parent.top; bottom: parent.bottom; left: parent.left } width: 1; color: root._ink; opacity: 0.9 }
                Rectangle { anchors { top: parent.top; bottom: parent.bottom; right: parent.right } width: 1; color: root._inkSoft; opacity: 0.9 }
                Rectangle { anchors { top: parent.top; right: parent.right } width: 6; height: 6; radius: 3; color: root._ink; opacity: 0.9 }
            }
        }
    }

    // ── 5. 浮层（人工确认闸门 / 配方详情 / 加载遮罩；业务注入须为透明 Item）──
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

    // 前置预判性：Esc 收起两条可折叠栏（只 emit 意图，宿主受控改 *Collapsed）
    focus: true
    Keys.onEscapePressed: {
        if (!root.recipeCollapsed) root.recipeToggled(true)
        if (!root.validateCollapsed) root.validateToggled(true)
    }
}
