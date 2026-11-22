// src/pyside_nova/qml/Nova/Controls/NovaAjaxBar.qml
// NovaAjaxBar 顶部进度条：start/increment/stop 命令式 API + 渐进模拟（越接近完成越慢，对标 QAjaxBar）
// 四向 position（top/bottom/left/right）+ reverse；进度语义：start 后自动渐进至 progressCap，stop 冲刺收尾
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 形态 ──────────────────────────────────────────────────
    property string position: "top"              // top | bottom | left | right
    property real size: 2                        // 条厚度 px
    property color tint: NovaTheme.primary
    property bool reverse: false                 // 反向行进
    readonly property real progressCap: 90       // 未 stop 前渐进上限（对标 QAjaxBar 行为口径）

    // ── 运行时（只读） ────────────────────────────────────────
    property real progress: 0                    // 0~100
    readonly property bool active: _waiters > 0

    // ── 事件 ──────────────────────────────────────────────────
    signal started()
    signal stopped()

    z: 9800
    visible: progress > 0 && progress < 100

    // 多进程计数（对标 hijack 语义：N 次 start 需 N 次 stop）
    property int _waiters: 0

    // ── 渐进模拟：间隔随进度拉长（50ms→800ms），步长收窄 ──────
    Timer {
        id: creep
        interval: 200
        repeat: true
        running: root.active && root.progress < root.progressCap
        onTriggered: {
            var left = root.progressCap - root.progress
            var step = Math.max(0.4, left * 0.12)
            root.progress = Math.min(root.progressCap, root.progress + step)
            interval = 200 + (root.progress / root.progressCap) * 600
        }
    }

    onActiveChanged: if (!active && progress > 0) _finish()
    onVisibleChanged: if (!visible) progress = 0

    // ── 条 ────────────────────────────────────────────────────
    Rectangle {
        id: track
        color: root.tint
        opacity: 0.9

        states: [
            State {
                name: "h"; when: root.position === "top" || root.position === "bottom"
                PropertyChanges { target: track; x: 0; width: root.width * root.progress / 100; height: root.size }
                PropertyChanges { target: track; y: root.position === "top" ? 0 : root.height - root.size }
            },
            State {
                name: "v"; when: root.position === "left" || root.position === "right"
                PropertyChanges { target: track; y: 0; height: root.height * root.progress / 100; width: root.size }
                PropertyChanges { target: track; x: root.position === "left" ? 0 : root.width - root.size }
            }
        ]

        // reverse 镜像：水平右锚 / 垂直下锚
        transform: Scale {
            xScale: root.reverse && (root.position === "top" || root.position === "bottom") ? -1 : 1
            origin.x: root.reverse && (root.position === "top" || root.position === "bottom") ? root.width : 0
            yScale: root.reverse && (root.position === "left" || root.position === "right") ? -1 : 1
            origin.y: root.reverse && (root.position === "left" || root.position === "right") ? root.height : 0
        }
    }

    // ── 命令式 API（对标 start/increment/stop） ────────────────
    function start() {
        _waiters++
        if (_waiters === 1) {
            progress = 0
            started()
            creep.restart()
        }
    }

    function increment(size) {
        var s = size === undefined ? 12 : size
        progress = Math.min(progressCap, progress + s)
    }

    function stop() {
        if (_waiters > 0)
            _waiters--
    }

    function _finish() {
        creep.stop()
        // 冲刺到 100 → visible false → 进度复位
        progress = 100
        stopAnim.restart()
    }

    SequentialAnimation {
        id: stopAnim
        NumberAnimation { target: root; property: "progress"; from: 100; to: 100; duration: 120 }   // 停留
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: 220 }
        ScriptAction { script: { root.opacity = 1; root.progress = 0; root.stopped() } }
    }
}
