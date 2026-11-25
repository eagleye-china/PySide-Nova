// src/pyside_nova/qml/Nova/Composite/LayoutShell/NovaCompare.qml
// NovaCompare 双栏对比壳：中缝调节柄 + 等宽双面板 + 控制栏 + 状态栏（对标代码 / 配置 diff 工具）
// NovaCompare —— 等宽对比工作台组合根容器；以"中缝圆形调节柄"为身份语言
// 用法：向 controlSlot/leftSlot/rightSlot/footerSlot/overlaySlot 注入业务内容；同步滚动为受控开关，Shell 只 emit 偏好
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma ComponentBehavior: Bound
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root
    // 鲁棒性 / i18n：声明式容器随 RTL 镜像；逻辑侧槽位语义恒定（宪法第 7 章第 3 条）
    LayoutMirroring.enabled: NovaTheme.isRtl

    property alias controlSlot: _control.data
    property alias leftSlot: _left.data
    property alias rightSlot: _right.data
    property alias footerSlot: _footer.data
    property alias overlaySlot: _overlay.data

    property bool showControl: true
    property bool showFooter: true
    property bool syncScroll: false
    property int controlHeight: 48
    property int footerHeight: 48
    property bool divider: true

    signal syncScrollToggled(bool enabled)
    function toggleSyncScroll() { root.syncScrollToggled(!root.syncScroll) }

    // 鲁棒性：几何入参只读钳制（非法 / 空值回退安全范围，禁止裸用外部值做几何计算；
    // 宪法第 7 章第 1 条 / 封版规范 §2.1）。_ 私有，不进 API 冻结面。
    readonly property int _controlH: Math.max(24, Math.min(root.controlHeight, 240))
    readonly property int _footerH: Math.max(24, Math.min(root.footerHeight, 240))

    implicitWidth: 1280
    implicitHeight: 800

    Rectangle { anchors.fill: parent; color: NovaTheme.page }

    Rectangle {
        id: _controlWrap
        visible: root.showControl
        height: root._controlH
        anchors { top: parent.top; left: parent.left; right: parent.right }
        color: NovaTheme.surface
        z: NovaTheme.zMarginals
        Item { id: _control; anchors.fill: parent }
    }

    // ── 身份元素：A / B 面板标识发丝（左 primary / 右 secondary）──
    // a11y: decorative
    Rectangle {
        anchors { top: root.showControl ? _controlWrap.bottom : parent.top; left: parent.left; right: _sep.left }
        height: 3
        color: NovaTheme.primary
        opacity: 0.9
        z: NovaTheme.zMarginals
    }
    // a11y: decorative
    Rectangle {
        anchors { top: root.showControl ? _controlWrap.bottom : parent.top; left: _sep.right; right: parent.right }
        height: 3
        color: NovaTheme.secondary
        opacity: 0.9
        z: NovaTheme.zMarginals
    }

    NovaPage {
        id: _left
        anchors {
            top: root.showControl ? _controlWrap.bottom : parent.top
            topMargin: 3
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: parent.left
            right: _sep.left
        }
        padding: NovaTheme.spacingS
    }

    // ── 身份元素：中缝调节柄（线 + 中央圆形 grip + 上下箭头）──
    NovaSeparator {
        id: _sep
        anchors {
            top: root.showControl ? _controlWrap.bottom : parent.top
            bottom: root.showFooter ? _footer.top : parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        vertical: true
        visible: root.divider
        z: NovaTheme.zMarginals
        // a11y: decorative
        Rectangle {
            anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            width: 22; height: 34; radius: NovaTheme.radiusS
            color: NovaTheme.surface
            border { width: 1; color: NovaTheme.primary }
            // 左向箭头
            Rectangle {
                anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                width: 5; height: 5; rotation: 45
                color: NovaTheme.primary
                border { width: 1; color: NovaTheme.primary }
            }
            // 右向箭头
            Rectangle {
                anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                width: 5; height: 5; rotation: 45
                color: NovaTheme.secondary
                border { width: 1; color: NovaTheme.secondary }
            }
        }
    }

    NovaPage {
        id: _right
        anchors {
            top: root.showControl ? _controlWrap.bottom : parent.top
            topMargin: 3
            bottom: root.showFooter ? _footer.top : parent.bottom
            left: _sep.right
            right: parent.right
        }
        padding: NovaTheme.spacingS
    }

    NovaFooter {
        id: _footer
        visible: root.showFooter
        height: root._footerH
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        tint: NovaTheme.surface
    }

    Item { id: _overlay; anchors.fill: parent; z: NovaTheme.zFixedDrawer }
}
