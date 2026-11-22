// src/pyside_nova/qml/Nova/Design/NovaMotion.qml
// NovaMotion 动效令牌单例（对标 Quasar --q-transition-duration/.3s + q-transition--* 12 种过渡 + q-animate--* 2 种动画）
// NovaMotion —— 动效令牌（L0 设计语言）：时长/缓动/预设过渡表/reduced-motion 短路
// 1:1 对账基线：npm quasar@2.35.5 src/css/core/transitions.sass + animations.sass
//   --q-transition-duration: .3s；--q-transition-easing: cubic-bezier(0.215,0.61,0.355,1)（= Easing.OutCubic）
//   .q-animate--scale: q-scale .15s cubic-bezier(.25,.8,.25,1)；.q-animate--fade: q-fade .2s
//   --animate-duration: .3s / --animate-delay: .3s / --animate-repeat: 1
// Nova 增强：speedFactor 全局调速、reducedMotion 全链短路（基线只覆盖 .animated）
pragma Singleton
import QtQuick

QtObject {
    id: root

    // ── 时长令牌（毫秒；基线为 s，此处 ×1000）──────────────────
    readonly property int transitionDuration: 300   // --q-transition-duration: .3s
    readonly property int animateDuration: 300      // --animate-duration: .3s
    readonly property int animateDelay: 300         // --animate-delay: .3s
    readonly property int animateRepeat: 1          // --animate-repeat: 1
    readonly property int scaleDuration: 150        // .q-animate--scale 0.15s
    readonly property int fadeDuration: 200         // .q-animate--fade 0.2s
    readonly property int rippleDuration: 400       // NovaRipple 默认（与基线 ripple 视觉对齐）

    // ── 缓动令牌 ──────────────────────────────────────────────
    // cubic-bezier(0.215,0.61,0.355,1) 即 easeOutCubic
    readonly property int easingStandard: Easing.OutCubic
    readonly property int easingScale: Easing.OutQuad     // cubic-bezier(.25,.8,.25,1) 近似
    readonly property int easingFade: Easing.OutQuad      // 基线 fade 固定 ease-out
    readonly property int easingDecelerate: Easing.OutQuart
    readonly property int easingAccelerate: Easing.InQuad
    readonly property int easingEmphasized: Easing.OutQuint
    readonly property int easingOvershoot: Easing.OutBack
    readonly property int easingLinear: Easing.Linear

    // ── 全局调节 ──────────────────────────────────────────────
    property real speedFactor: 1.0        // 1.0 原速；2.0 半速；0.5 双速
    property bool reducedMotion: false    // 无障碍：true 时全部动效时长归零（等价 prefers-reduced-motion）
    property bool animateOnStart: false   // 组件创建时是否播放进场动画（默认不播，避免首帧闪烁）

    // 统一取时长：reducedMotion 直接归零；否则按 speedFactor 缩放
    function duration(base) {
        if (root.reducedMotion)
            return 0
        var v = Math.round((base === undefined ? root.transitionDuration : base) * root.speedFactor)
        return v < 0 ? 0 : v
    }

    // ── 12 种预设过渡（1:1 对标 q-transition--*）──────────────
    // 字段：opacityIn/opacityOut 进场/离场不透明度，scaleIn/scaleOut 缩放，
    //       xIn/xOut、yIn/yOut 位移（相对宽高的倍率，±1 = 整宽/整高；jump 类为像素偏移用 px 字段），
    //       angleIn/angleOut 旋转角，axis 旋转轴（flip 用），
    //       pxIn/pxOut 像素位移（jump 系列 ±15px）
    readonly property var presets: ({
        "fade": { opacityIn: 0, opacityOut: 0 },

        "scale": { opacityIn: 0, opacityOut: 0, scaleIn: 0, scaleOut: 0 },

        "rotate": { opacityIn: 0, opacityOut: 0, scaleIn: 0, scaleOut: 0,
                    angleIn: 90, angleOut: 90 },

        // slide：进场从一侧推入，离场向另一侧推出（基线 enter-from/leave-to 不对称）
        "slide-right": { xIn: -1, xOut: 1 },
        "slide-left": { xIn: 1, xOut: -1 },
        "slide-up": { yIn: 1, yOut: -1 },
        "slide-down": { yIn: -1, yOut: 1 },

        // jump：±15px 位移 + 淡入淡出
        "jump-right": { opacityIn: 0, opacityOut: 0, pxIn: -15, pxOut: 15 },
        "jump-left": { opacityIn: 0, opacityOut: 0, pxIn: 15, pxOut: -15 },
        "jump-up": { opacityIn: 0, opacityOut: 0, pyIn: 15, pyOut: -15 },
        "jump-down": { opacityIn: 0, opacityOut: 0, pyIn: -15, pyOut: 15 },

        // flip：3D 翻面（perspective 400px 的 QML 近似：绕轴旋转 ±180°）
        "flip-right": { angleIn: -180, angleOut: 180, axis: "y" },
        "flip-left": { angleIn: 180, angleOut: -180, axis: "y" },
        "flip-up": { angleIn: 180, angleOut: -180, axis: "x" },
        "flip-down": { angleIn: -180, angleOut: 180, axis: "x" }
    })

    readonly property var presetNames: Object.keys(root.presets)

    function preset(name) {
        var p = root.presets[name]
        return p !== undefined ? p : root.presets["fade"]
    }

    function hasPreset(name) {
        return root.presets[name] !== undefined
    }
}
