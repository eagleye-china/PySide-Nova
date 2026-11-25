// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaDualSide.qml
// NovaDualSide 双侧边工作台壳：左导航 + 中央画布 + 右属性，两侧独立折叠（对标 Qt Designer / VSCode 三栏布局）
// NovaDualSide —— 工业配置软件高频三栏组合根容器；以"中央画布 + 双栏浮起"为身份语言
// 用法：向 leftSlot/contentSlot/rightSlot/footerSlot/overlaySlot 注入业务内容；两侧宽度受控、只 emit 折叠事件
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

    property alias leftSlot: _left.data
    property alias contentSlot: _body.content
    property alias rightSlot: _right.data
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property real leftSize: 240
    property real rightSize: 280
    property bool leftCollapsed: false
    property bool rightCollapsed: false
    property bool showFooter: true
    property int footerHeight: 48
    property bool bordered: true

    signal leftToggled(bool collapsed)
    signal rightToggled(bool collapsed)
    function toggleLeft() { root.leftToggled(!root.leftCollapsed) }
    function toggleRight() { root.rightToggled(!root.rightCollapsed) }

    readonly property real _lw: Math.max(80, Math.min(root.leftSize, width / 3 || root.leftSize))
    readonly property real _rw: Math.max(80, Math.min(root.rightSize, width / 3 || root.rightSize))

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    // ── 身份元素 ①：左侧轨（primary 竖色条，折叠时仍保留视觉锚）──
    // a11y: decorative
    Rectangle {
        id: _leftRail
        anchors { top: parent.top; bottom: root.showFooter ? _footer.top : parent.bottom; left: parent.left }
        width: 3
        color: NovaTheme.primary
        opacity: 0.85
    }

    // 左侧浮起卡
    Rectangle {
        id: _leftCard
        anchors {
            top: parent.top; topMargin: NovaTheme.spacingS
            bottom: root.showFooter ? _footer.top : parent.bottom; bottomMargin: NovaTheme.spacingS
            left: _leftRail.right; leftMargin: NovaTheme.spacingS
        }
        width: root.leftCollapsed ? 0 : root._lw
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border { width: root.bordered ? 1 : 0; color: NovaTheme.outline }
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: NovaMotion.duration(NovaMotion.transitionDuration); easing.type: NovaMotion.easingStandard } }
        // a11y: decorative —— 顶部栏目标识发丝
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 0 }
            height: 3
            color: NovaTheme.primary
            opacity: 0.9
            z: NovaTheme.zMarginals
        }
        Item { id: _left; anchors { fill: parent; margins: NovaTheme.spacingS; topMargin: NovaTheme.spacingS + 3 } }
    }

    // ── 身份元素 ②：中央画布（圆角表面 + 网格底纹，区别于普通内容页）──
    // a11y: decorative
    Rectangle {
        id: _canvas
        anchors {
            top: parent.top; topMargin: NovaTheme.spacingS
            bottom: root.showFooter ? _footer.top : parent.bottom; bottomMargin: NovaTheme.spacingS
            left: _leftCard.visible ? _leftCard.right : _leftRail.right
            right: _rightCard.visible ? _rightCard.left : parent.right
            leftMargin: NovaTheme.spacingS
            rightMargin: NovaTheme.spacingS
        }
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border { width: 1; color: NovaTheme.outline }

        // 网格底纹：低透明度点阵（纯装饰，不承载语义）
        // a11y: decorative
        Grid {
            // 底纹须留在业务注入之下（中央内容区完全留给业务，宪法 0.7.1 多轨分治）
            anchors.centerIn: parent
            rows: 8; columns: 12
            rowSpacing: 28; columnSpacing: 28
            Repeater {
                model: 96
                Rectangle {
                    width: 2; height: 2; radius: 1
                    color: NovaTheme.outline
                    opacity: 0.9
                }
            }
        }

        NovaPage {
            id: _body
            anchors.fill: parent
            padding: NovaTheme.spacingM
        }
    }

    // 右侧浮起卡
    Rectangle {
        id: _rightCard
        anchors {
            top: parent.top; topMargin: NovaTheme.spacingS
            bottom: root.showFooter ? _footer.top : parent.bottom; bottomMargin: NovaTheme.spacingS
            right: parent.right; rightMargin: NovaTheme.spacingS
        }
        width: root.rightCollapsed ? 0 : root._rw
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border { width: root.bordered ? 1 : 0; color: NovaTheme.outline }
        clip: true
        visible: width > 0
        Behavior on width { NumberAnimation { duration: NovaMotion.duration(NovaMotion.transitionDuration); easing.type: NovaMotion.easingStandard } }
        // a11y: decorative —— 顶部栏目标识发丝（secondary 区分左右）
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 3
            color: NovaTheme.secondary
            opacity: 0.9
            z: NovaTheme.zMarginals
        }
        Item { id: _right; anchors { fill: parent; margins: NovaTheme.spacingS; topMargin: NovaTheme.spacingS + 3 } }
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root._footerH
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }

    // 前置预判性：Esc 收起双侧栏（只 emit 收起意图，宿主受控改 left/rightCollapsed）
    focus: true
    Keys.onEscapePressed: {
        if (!root.leftCollapsed) root.leftToggled(true)
        if (!root.rightCollapsed) root.rightToggled(true)
    }
}
