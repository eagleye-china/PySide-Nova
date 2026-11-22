// src/pyside_nova/qml/Nova/Controls/NovaTransition.qml
// NovaTransition 过渡包装组件（对标 Quasar q-transition--fade/scale/rotate/slide-*/jump-*/flip-* 共 16 种）
// NovaTransition —— 进出场过渡：声明式包住任意内容，show 切换时按预设播放进场/离场动画
// 1:1 语义：enter-from 与 leave-to 不对称（slide 进场从一侧推入、离场向另一侧推出），故用两组独立动画
// reduced-motion：NovaMotion.reducedMotion 为真时时长归零（基线只覆盖 .animated，此处为 Nova 增强）
// 用法：NovaTransition { name: "slide-right"; show: visibleFlag; NovaCard { ... } }
import QtQuick
import Nova.Design

Item {
    id: root

    // ── 预设与状态 ───────────────────────────────────────────
    property string name: "fade"
    property bool show: true
    property int duration: NovaMotion.duration(NovaMotion.transitionDuration)
    property int easing: NovaMotion.easingStandard
    property bool clipContent: true

    default property alias content: host.data

    signal entered()
    signal exited()

    readonly property var preset: NovaMotion.preset(name)
    readonly property string axis: preset.axis !== undefined ? preset.axis : "y"

    // 进场起点（未定义的维度不参与动画）
    readonly property bool _hasOpacity: preset.opacityIn !== undefined || preset.opacityOut !== undefined
    readonly property bool _hasScale: preset.scaleIn !== undefined || preset.scaleOut !== undefined
    readonly property bool _hasMoveX: preset.xIn !== undefined || preset.xOut !== undefined
                                     || preset.pxIn !== undefined || preset.pxOut !== undefined
    readonly property bool _hasMoveY: preset.yIn !== undefined || preset.yOut !== undefined
                                     || preset.pyIn !== undefined || preset.pyOut !== undefined
    readonly property bool _hasAngle: preset.angleIn !== undefined || preset.angleOut !== undefined

    readonly property real _inOpacity: preset.opacityIn !== undefined ? preset.opacityIn : 1
    readonly property real _outOpacity: preset.opacityOut !== undefined ? preset.opacityOut : 1
    readonly property real _inScale: preset.scaleIn !== undefined ? preset.scaleIn : 1
    readonly property real _outScale: preset.scaleOut !== undefined ? preset.scaleOut : 1
    readonly property real _inX: (preset.xIn !== undefined ? preset.xIn : 0) * width
                                  + (preset.pxIn !== undefined ? preset.pxIn : 0)
    readonly property real _outX: (preset.xOut !== undefined ? preset.xOut : 0) * width
                                  + (preset.pxOut !== undefined ? preset.pxOut : 0)
    readonly property real _inY: (preset.yIn !== undefined ? preset.yIn : 0) * height
                                  + (preset.pyIn !== undefined ? preset.pyIn : 0)
    readonly property real _outY: (preset.yOut !== undefined ? preset.yOut : 0) * height
                                  + (preset.pyOut !== undefined ? preset.pyOut : 0)
    readonly property real _inAngle: preset.angleIn !== undefined ? preset.angleIn : 0
    readonly property real _outAngle: preset.angleOut !== undefined ? preset.angleOut : 0

    property bool _visible: show
    visible: _visible

    // 无动画直落终态（创建期/关闭动效时使用）
    function _applyState(entering) {
        host.opacity = root._hasOpacity ? (entering ? root._inOpacity : root._outOpacity) : 1
        host.scale = root._hasScale ? (entering ? root._inScale : root._outScale) : 1
        host.x = root._hasMoveX ? (entering ? root._inX : root._outX) : 0
        host.y = root._hasMoveY ? (entering ? root._inY : root._outY) : 0
        rot.angle = root._hasAngle ? (entering ? root._inAngle : root._outAngle) : 0
    }

    function _applyFinal() {
        host.opacity = 1
        host.scale = 1
        host.x = 0
        host.y = 0
        rot.angle = 0
    }

    onShowChanged: {
        if (show) {
            _visible = true
            if (duration <= 0) {
                _applyFinal()
                entered()
            } else {
                enterAnim.restart()
            }
        } else {
            if (duration <= 0) {
                _applyState(false)
                _visible = false
                exited()
            } else {
                leaveAnim.restart()
            }
        }
    }

    Component.onCompleted: {
        if (show) {
            _applyFinal()
        } else {
            _applyState(false)
            _visible = false
        }
    }

    clip: clipContent

    Item {
        id: host
        width: parent.width
        height: parent.height
        transformOrigin: Item.Center
        transform: Rotation {
            id: rot
            origin.x: host.width / 2
            origin.y: host.height / 2
            axis.x: root.axis === "x" ? 1 : 0
            axis.y: root.axis === "y" ? 1 : 0
            axis.z: 0
        }
    }

    // ── 进场：从 enter-from 到正常态 ──────────────────────────
    ParallelAnimation {
        id: enterAnim

        NumberAnimation {
            target: host; property: "opacity"
            from: root._hasOpacity ? root._inOpacity : 1; to: 1
            duration: root.duration; easing.type: root.easing
        }
        NumberAnimation {
            target: host; property: "scale"
            from: root._hasScale ? root._inScale : 1; to: 1
            duration: root.duration; easing.type: root.easing
        }
        NumberAnimation {
            target: host; property: "x"
            from: root._hasMoveX ? root._inX : 0; to: 0
            duration: root.duration; easing.type: root.easing
        }
        NumberAnimation {
            target: host; property: "y"
            from: root._hasMoveY ? root._inY : 0; to: 0
            duration: root.duration; easing.type: root.easing
        }
        NumberAnimation {
            target: rot; property: "angle"
            from: root._hasAngle ? root._inAngle : 0; to: 0
            duration: root.duration; easing.type: root.easing
        }

        onFinished: {
            root._applyFinal()
            root.entered()
        }
    }

    // ── 离场：从正常态到 leave-to ─────────────────────────────
    ParallelAnimation {
        id: leaveAnim

        NumberAnimation {
            target: host; property: "opacity"
            from: 1; to: root._hasOpacity ? root._outOpacity : 1
            duration: root.duration; easing.type: root.easing
        }
        NumberAnimation {
            target: host; property: "scale"
            from: 1; to: root._hasScale ? root._outScale : 1
            duration: root.duration; easing.type: root.easing
        }
        NumberAnimation {
            target: host; property: "x"
            from: 0; to: root._hasMoveX ? root._outX : 0
            duration: root.duration; easing.type: root.easing
        }
        NumberAnimation {
            target: host; property: "y"
            from: 0; to: root._hasMoveY ? root._outY : 0
            duration: root.duration; easing.type: root.easing
        }
        NumberAnimation {
            target: rot; property: "angle"
            from: 0; to: root._hasAngle ? root._outAngle : 0
            duration: root.duration; easing.type: root.easing
        }

        onFinished: {
            if (!root.show)
                root._visible = false
            root.exited()
        }
    }
}
