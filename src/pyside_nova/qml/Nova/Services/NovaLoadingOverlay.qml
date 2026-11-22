// src/pyside_nova/qml/Nova/Services/NovaLoadingOverlay.qml
// NovaLoadingOverlay 加载遮罩视觉层：半透明遮罩 + 三种 spinner + 消息 + delay/timeout（内部件，由 NovaLoading 驱动）
// NovaLoadingOverlay —— 单个加载组件的可视层（对标 Quasar Loading 的 portal 内容）
// 契约：delay 内不显示（防闪烁）；seamless 无遮罩（局部内嵌）；timeout 到点强制收口（Nova 增强）。
// 销毁由自身负责：fadeOut → closed() → destroy()；服务层在 closed 里清引用。
import QtQuick

Item {
    id: root

    // ── 配置（服务层写入） ────────────────────────────────────
    property string message: ""
    property int spinnerSize: 50
    property string spinnerModel: "ring"        // ring | dots | pulse
    property color spinnerTint: NovaTheme.primary
    property color messageTint: NovaTheme.textColor
    property color backgroundTint: NovaTheme.isDark ? Qt.rgba(0.07, 0.07, 0.09, 0.74)
                                                   : Qt.rgba(1, 1, 1, 0.74)
    property bool seamless: false               // true = 无遮罩（局部内嵌场景）
    property bool boxed: false                  // true = 消息带卡片底
    property int delay: 500                     // 0 = 立即显示
    property int timeout: 0                     // >0 = 超时保护（Nova 增强）
    property int refCount: 1                    // 引用计数（同组并发数，Nova 增强）

    // ── 运行时状态（服务层只读） ──────────────────────────────
    readonly property bool started: _started
    property bool _started: false
    property bool _closed: false

    signal closed()

    // 根节点始终"在场"（宿主 attach 会置 visible=true），真正的可见性由 _started 门控：
    // delay 期间子项不渲染，遮罩也不拦点击——这是"防闪烁 + 不误挡"的关键。
    opacity: 0

    Component.onCompleted: {
        if (root.delay <= 0)
            root.appear()
    }

    // ── 遮罩（吞掉全部点击，防误触穿透） ──────────────────────
    Rectangle {
        anchors.fill: parent
        visible: !root.seamless && root._started
        color: root.backgroundTint

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onWheel: function(wheel) { wheel.accepted = true }
        }
    }

    // ── 内容区：spinner + 消息 ────────────────────────────────
    // box 只作背景（包住 content），内容统一由 content Column 居中布局
    Rectangle {
        id: box
        anchors.centerIn: parent
        width: content.implicitWidth + 2 * NovaTheme.spacingL
        height: content.implicitHeight + 2 * NovaTheme.spacingL
        visible: root.boxed && root._started
        radius: NovaTheme.radiusL
        color: NovaTheme.surface
        border.width: 1
        border.color: NovaTheme.outline
    }

    Column {
        id: content
        anchors.centerIn: parent
        spacing: NovaTheme.spacingM
        visible: root._started

        // ── spinner: ring（Canvas 圆环，带渐变头） ─────────────
        Canvas {
            id: ring
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.spinnerSize
            height: root.spinnerSize
            visible: root.spinnerModel === "ring"
            antialiasing: true

            property color tint: root.spinnerTint

            onTintChanged: requestPaint()
            onWidthChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var lw = Math.max(2, width * 0.10)
                var r = width / 2 - lw / 2
                var cx = width / 2
                var cy = height / 2

                ctx.lineWidth = lw
                ctx.lineCap = "round"

                // 底环：同色 16% 透明
                ctx.strokeStyle = Qt.rgba(tint.r, tint.g, tint.b, 0.16)
                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, Math.PI * 2)
                ctx.stroke()

                // 进度弧：270°
                ctx.strokeStyle = tint
                ctx.beginPath()
                ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 1.5)
                ctx.stroke()
            }

            RotationAnimator on rotation {
                from: 0
                to: 360
                duration: 900
                loops: Animation.Infinite
                running: root.visible && root.spinnerModel === "ring"
            }
        }

        // ── spinner: dots（三点依次缩放） ──────────────────────
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Math.max(4, root.spinnerSize * 0.14)
            visible: root.spinnerModel === "dots"
            height: root.spinnerSize * 0.5

            Repeater {
                model: 3

                Rectangle {
                    id: dot
                    width: Math.max(6, root.spinnerSize * 0.20)
                    height: width
                    radius: width / 2
                    color: root.spinnerTint
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.35

                    SequentialAnimation on scale {
                        running: root.visible && root.spinnerModel === "dots"
                        loops: Animation.Infinite
                        PauseAnimation { duration: index * 140 }
                        NumberAnimation { to: 1.35; duration: 260; easing.type: Easing.OutQuad }
                        NumberAnimation { to: 1.0; duration: 260; easing.type: Easing.InQuad }
                        PauseAnimation { duration: (2 - index) * 140 }
                    }

                    SequentialAnimation on opacity {
                        running: root.visible && root.spinnerModel === "dots"
                        loops: Animation.Infinite
                        PauseAnimation { duration: index * 140 }
                        NumberAnimation { to: 1.0; duration: 260 }
                        NumberAnimation { to: 0.35; duration: 260 }
                        PauseAnimation { duration: (2 - index) * 140 }
                    }
                }
            }
        }

        // ── spinner: pulse（呼吸圆） ───────────────────────────
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.spinnerSize * 0.7
            height: width
            radius: width / 2
            color: root.spinnerTint
            visible: root.spinnerModel === "pulse"

            SequentialAnimation on scale {
                running: root.visible && root.spinnerModel === "pulse"
                loops: Animation.Infinite
                NumberAnimation { to: 0.72; duration: 620; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 620; easing.type: Easing.InOutQuad }
            }

            SequentialAnimation on opacity {
                running: root.visible && root.spinnerModel === "pulse"
                loops: Animation.Infinite
                NumberAnimation { to: 0.45; duration: 620 }
                NumberAnimation { to: 0.95; duration: 620 }
            }
        }

        // ── 消息 ──────────────────────────────────────────────
        Text {
            id: msg
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.message !== ""
            text: root.message
            color: root.messageTint
            font.pixelSize: NovaTheme.fontS
            font.family: NovaTheme.fontFamily
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: Math.min(implicitWidth, 360)
        }
    }

    // ── 延时显示（防闪烁） ────────────────────────────────────
    Timer {
        id: delayTimer
        interval: Math.max(0, root.delay)
        running: root.delay > 0 && !root._started && !root._closed
        onTriggered: root.appear()
    }

    // ── 超时保护（Nova 增强：卡死兜底） ───────────────────────
    Timer {
        interval: Math.max(1, root.timeout)
        running: root.timeout > 0 && root._started && !root._closed
        onTriggered: {
            console.warn("NovaLoading: 加载超过 " + root.timeout + "ms，超时收口")
            root.close()
        }
    }

    // ── 显隐动效 ──────────────────────────────────────────────
    NumberAnimation {
        id: fadeIn
        target: root
        property: "opacity"
        to: 1
        duration: 140
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: fadeOut
        target: root
        property: "opacity"
        to: 0
        duration: 130
        easing.type: Easing.InCubic
        onFinished: {
            root._closed = true
            root.closed()
            root.destroy()
        }
    }

    function appear() {
        if (root._started || root._closed)
            return
        root._started = true
        fadeIn.start()
    }

    // 局部加载：挂到目标 Item 内并铺满（target 缺省时由服务层走 NovaOverlayHost 全屏）
    function mountOn(host) {
        if (!host)
            return false
        root.parent = host
        root.anchors.fill = host
        root.z = 1
        return true
    }

    // 唯一关闭入口：引用计数归零 / 超时 / 宿主销毁
    function close() {
        if (root._closed)
            return
        if (!root._started) {          // delay 期间收口：从未显示，直接销毁（不闪）
            root._closed = true
            root.closed()
            root.destroy()
            return
        }
        root._closed = true
        fadeOut.start()
    }

    Component.onDestruction: {
        if (!root._closed) {
            root._closed = true
            root.closed()
        }
    }
}
