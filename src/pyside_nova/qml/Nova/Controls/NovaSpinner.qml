// src/pyside_nova/qml/Nova/Controls/NovaSpinner.qml
// NovaSpinner 加载指示器：variant 八变体（ring/ball/dots/hourglass/gears/grid/radio/comment，对标 QSpinner 系列）
// Canvas 逐帧绘制口径：统一 Timer 驱动 phase ∈ [0,1)，onPhaseChanged → requestPaint（坑位 28 显式失效口径）
import QtQuick
import Nova.Services

Canvas {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.ProgressBar
    Accessible.name: a11yLabel

    // ── 形态 ──────────────────────────────────────────────────
    property string variant: "ring"              // ring | ball | dots | hourglass | gears | grid | radio | comment
    property real size: 42
    property color tint: NovaTheme.primary
    property real thickness: 5                   // ring/radio 口径：描边宽度

    readonly property var _variants: ["ring", "ball", "dots", "hourglass", "gears", "grid", "radio", "comment"]

    width: size
    height: size

    // ── 相位驱动（12fps 足够平滑，Canvas 重绘成本低） ──────────
    property real phase: 0
    Timer {
        interval: 33
        running: root.visible
        repeat: true
        onTriggered: root.phase = (root.phase + 0.033) % 1
    }
    onPhaseChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var c = Math.min(width, height) / 2
        var t = root.phase
        ctx.strokeStyle = String(root.tint)
        ctx.fillStyle = String(root.tint)
        ctx.lineCap = "round"
        ctx.lineJoin = "round"

        switch (root.variant) {
        case "ball": {
            // 沿轨道旋转的三实心圆（对标 QSpinnerBall）
            var r = c * 0.72, br = Math.max(2, c * 0.16)
            for (var i = 0; i < 3; i++) {
                var ang = (t + i / 3) * Math.PI * 2
                ctx.beginPath()
                ctx.arc(c + r * Math.cos(ang), c + r * Math.sin(ang), br, 0, Math.PI * 2)
                ctx.fill()
            }
            break
        }
        case "dots": {
            // 三点脉冲（对标 QSpinnerDots：透明度随相位波动）
            var dr = Math.max(2.5, c * 0.14)
            for (var d = 0; d < 3; d++) {
                var ph = (t * 3 - d * 0.35) % 1
                ctx.globalAlpha = 0.35 + 0.65 * (0.5 + 0.5 * Math.sin(ph * Math.PI * 2))
                ctx.beginPath()
                ctx.arc(c - dr * 2.4 + d * dr * 2.4, c, dr, 0, Math.PI * 2)
                ctx.fill()
            }
            ctx.globalAlpha = 1
            break
        }
        case "hourglass": {
            // 旋转沙漏（对标 QSpinnerHourglass：线框翻转）
            ctx.save()
            ctx.translate(c, c)
            ctx.rotate(t * Math.PI * 2)
            var h = c * 0.72
            ctx.beginPath()
            ctx.moveTo(-h, -h)
            ctx.lineTo(h, -h)
            ctx.lineTo(-h, h)
            ctx.lineTo(h, h)
            ctx.closePath()
            ctx.lineWidth = Math.max(2, root.thickness * 0.6)
            ctx.stroke()
            ctx.restore()
            break
        }
        case "gears": {
            // 双齿轮对转（对标 QSpinnerGears：外齿圈 + 内齿圈反向）
            var teeth = 8
            for (var g = 0; g < 2; g++) {
                ctx.save()
                ctx.translate(g === 0 ? c : c * 1.36, g === 0 ? c : c * 1.36)
                ctx.rotate((g === 0 ? t : -t) * Math.PI * 2)
                var R = c * (g === 0 ? 0.62 : 0.30)
                ctx.lineWidth = Math.max(2, root.thickness * 0.5)
                ctx.beginPath()
                ctx.arc(0, 0, R * 0.66, 0, Math.PI * 2)
                ctx.stroke()
                for (var k = 0; k < teeth; k++) {
                    var a2 = k / teeth * Math.PI * 2
                    ctx.beginPath()
                    ctx.moveTo(R * 0.66 * Math.cos(a2), R * 0.66 * Math.sin(a2))
                    ctx.lineTo(R * Math.cos(a2), R * Math.sin(a2))
                    ctx.stroke()
                }
                ctx.restore()
            }
            break
        }
        case "grid": {
            // 九宫格脉冲（对标 QSpinnerGrid：3×3 方块透明度波动）
            var cell = c * 0.42, gap = cell * 0.28
            for (var gx = 0; gx < 3; gx++) {
                for (var gy = 0; gy < 3; gy++) {
                    var gp = (t * 2 + (gx + gy) * 0.18) % 1
                    ctx.globalAlpha = 0.25 + 0.75 * (0.5 + 0.5 * Math.sin(gp * Math.PI * 2))
                    var s = cell * 0.62
                    ctx.fillRect(c - cell * 1.5 + gx * (cell + gap) - s / 2 + cell / 2,
                                 c - cell * 1.5 + gy * (cell + gap) - s / 2 + cell / 2,
                                 s, s)
                }
            }
            ctx.globalAlpha = 1
            break
        }
        case "radio": {
            // 转圈短弧（对标 QSpinnerRadio：不闭合弧线）
            ctx.lineWidth = Math.max(2, root.thickness * 0.7)
            ctx.beginPath()
            ctx.arc(c, c, c * 0.62, t * Math.PI * 2, t * Math.PI * 2 + Math.PI * 1.1)
            ctx.stroke()
            break
        }
        case "comment": {
            // 气泡点（对标 QSpinnerComment：气泡内三点跳动）
            ctx.lineWidth = Math.max(2, root.thickness * 0.5)
            ctx.beginPath()
            ctx.roundRect(c * 0.18, c * 0.3, c * 1.3, c * 0.9, c * 0.18)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(c * 0.5, c * 1.18)
            ctx.lineTo(c * 0.78, c * 1.18)
            ctx.lineTo(c * 0.5, c * 1.4)
            ctx.closePath()
            ctx.fill()
            for (var p = 0; p < 3; p++) {
                var pp = (t * 3 - p * 0.3) % 1
                ctx.globalAlpha = 0.3 + 0.7 * (0.5 + 0.5 * Math.sin(pp * Math.PI * 2))
                ctx.beginPath()
                ctx.arc(c * 0.55 + p * c * 0.22, c * 0.75, Math.max(1.5, c * 0.07), 0, Math.PI * 2)
                ctx.fill()
            }
            ctx.globalAlpha = 1
            break
        }
        default: {
            // ring（对标 QSpinner 默认 mat：渐进弧线）
            ctx.lineWidth = Math.max(2, root.thickness * 0.6)
            var start = t * Math.PI * 2
            ctx.beginPath()
            ctx.arc(c, c, c * 0.68, start, start + Math.PI * 1.4)
            ctx.stroke()
            break
        }
        }
    }
}
