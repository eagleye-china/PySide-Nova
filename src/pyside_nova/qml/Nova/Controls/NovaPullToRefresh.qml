// src/pyside_nova/qml/Nova/Controls/NovaPullToRefresh.qml
// NovaPullToRefresh 下拉刷新：side 四边拉动（top/bottom/left/right，对标 2.30）、refresh 事件、trigger() 方法
// 拉动数学：从 side 边缘向内容方向拖拽 dist；pullProgress = dist / threshold（钳制 0~1）
// refreshing 受控口径：宿主在 refresh 处理器里置 true，数据就绪后置 false 复位（对标事件驱动语义）
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.Grouping
    Accessible.name: a11yLabel

    default property alias content: contentHost.data

    // ── 配置 ──────────────────────────────────────────────────
    property string side: "top"                  // top | bottom | left | right
    property bool disable: false
    property color tint: NovaTheme.primary
    property color bgColor: NovaTheme.surface
    property string icon: "mdi:refresh"
    property real threshold: 80                  // 触发拉动距离 px
    property bool refreshing: false              // 受控：宿主数据加载中（拉动动画保持）

    // ── 事件与方法 ────────────────────────────────────────────
    signal refresh()

    readonly property bool _horizontal: side === "left" || side === "right"
    readonly property bool _fromStart: side === "top" || side === "left"
    readonly property real pullProgress: pullDist / threshold
    property real pullDist: 0                    // 当前拉动距离（0 = 静止）

    implicitWidth: 400
    implicitHeight: 300

    // ── 指示器几何 ────────────────────────────────────────────
    readonly property real _indOffset: {
        var p = Math.min(1, Math.max(0, pullProgress))
        if (refreshing && pullDist === 0) return threshold * 0.75   // 刷新中：保持拉出态
        return p * threshold * 0.75
    }

    // ── 拉动交互（DragHandler 边缘判定） ──────────────────────
    DragHandler {
        id: drag
        enabled: !root.disable && !root.refreshing
        target: null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus

        onActiveChanged: {
            if (!active) {
                // 松手：超阈值 → 触发刷新；否则回弹
                if (root.pullDist >= root.threshold && !root.disable) {
                    root.refreshing = true
                    root.pullDist = 0
                    root.refresh()
                } else {
                    root.pullDist = 0
                }
            }
        }
        onTranslationChanged: {
            if (!active) return
            var d
            if (side === "top") d = translation.y
            else if (side === "bottom") d = -translation.y
            else if (side === "left") d = translation.x
            else d = -translation.x
            // 只累计朝向内容方向的净拉动
            d = Math.max(0, d)
            // 起点边缘判定：拖拽从边缘 40px 内开始才生效（DragHandler 无起点回调，用累积首帧近似）
            if (root.pullDist === 0 && !_nearEdge())
                return
            root.pullDist = Math.max(0, d)
        }
        function _nearEdge() { return true }   // 简化口径：整面生效（PARITY 留痕：无 DOM touchstart 坐标）
    }

    // ── 内容区（拉动时沿 side 平移） ──────────────────────────
    Item {
        id: contentClip
        anchors.fill: parent
        clip: true

        Item {
            id: body
            width: parent.width
            height: parent.height
            x: side === "left" ? root.pullDist : (side === "right" ? -root.pullDist : 0)
            y: side === "top" ? root.pullDist : (side === "bottom" ? -root.pullDist : 0)

            Behavior on x { enabled: root.pullDist === 0; NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on y { enabled: root.pullDist === 0; NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Item {
                id: contentHost
                anchors.fill: parent
            }
        }
    }

    // ── 指示器（拉出的圆形容器） ──────────────────────────────
    Rectangle {
        id: indicator
        width: 40
        height: 40
        radius: 20
        color: root.bgColor
        border.width: 1
        border.color: NovaTheme.outline
        opacity: Math.min(1, root.pullDist / (root.threshold * 0.5))

        x: side === "left" ? root.pullDist * 0.75 + 8
         : side === "right" ? root.width - 48 - root.pullDist * 0.75
         : (root.width - width) / 2
        y: side === "top" ? root.pullDist * 0.75 + 8
         : side === "bottom" ? root.height - 48 - root.pullDist * 0.75
         : (root.height - height) / 2

        RotationAnimation on rotation {
            running: root.refreshing
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 900
        }

        NovaIcon {
            anchors.centerIn: parent
            icon: root.icon
            size: 22
            color: root.tint
            visible: !root.refreshing
        }
        NovaSpinner {
            anchors.centerIn: parent
            visible: root.refreshing
            size: 24
            variant: "radio"
            tint: root.tint
        }
    }

    // ── 方法（对标 trigger） ──────────────────────────────────
    function trigger() {
        if (disable || refreshing) return
        refreshing = true
        refresh()
    }
}
