// src/pyside_nova/qml/Nova/Controls/NovaSlideItem.qml
// NovaSlideItem 滑动操作项（对标 QSlideItem · 基线 2.35.5 语义）：
// 正面内容（default 槽）左右滑动露出动作面板（leftSlot/rightSlot Component 槽（QSlideItem 的 left/right 撞 Item FINAL 成员改名，坑位 12）），
// 拖拽跟手 + 释放越阈值吸附打开；dense 紧凑侧板
// 契约：开合是内部动画状态（QSlideItem 本身无 v-model，指令型组件）；
// 宿主经 slideLeft()/slideRight()/reset() 命令式驱动，侧板点击后 reset()
import QtQuick
import Nova.Services
import Nova.Behaviors
import Nova.Design

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.Grouping
    Accessible.name: a11yLabel
    Accessible.focusable: true
    Accessible.focused: activeFocus
    activeFocusOnTab: true
    // 键盘路径：左右滑出动作面板，Esc 归位（指针滑动的等价路径）
    // RTL（0.16.1）：物理方向键镜像——逻辑 left（视觉右）由 Key_Right 触发
    Keys.onPressed: function(ev) {
        var leftKey = NovaTheme.isRtl ? Qt.Key_Right : Qt.Key_Left
        var rightKey = NovaTheme.isRtl ? Qt.Key_Left : Qt.Key_Right
        if (ev.key === leftKey) { root.slideLeft(); ev.accepted = true }
        else if (ev.key === rightKey) { root.slideRight(); ev.accepted = true }
        else if (ev.key === Qt.Key_Escape) { root.reset(); ev.accepted = true }
    }

    // ── 槽 ────────────────────────────────────────────────────
    default property alias content: front.data                  // 正面内容
    property Component leftSlot: null                               // 左滑露出的动作面板
    property Component rightSlot: null                              // 右滑露出的动作面板
    property bool dense: false                                  // 侧板紧凑宽度

    // ── 配置 ──────────────────────────────────────────────────
    property int revealWidth: dense ? 56 : 72                   // 侧板露出宽度
    property int duration: 240                                  // 吸附动画时长
    property real openThreshold: 0.4                            // 释放时打开所需进度（0~1）

    // ── 事件 ──────────────────────────────────────────────────
    signal slideOpened(string side)                             // "left" | "right"
    signal slideClosed()
    signal leftAction()                                         // 左侧板整板点击（随后自动 reset）
    signal rightAction()
    readonly property bool opened: _side !== ""

    // ── 状态 ──────────────────────────────────────────────────
    property string _side: ""                                   // 当前打开侧："" | "left" | "right"

    implicitWidth: 400
    implicitHeight: 56
    clip: true

    onLeftSlotChanged: _rebuildPanels()
    onRightSlotChanged: _rebuildPanels()

    // ── 侧板 ──────────────────────────────────────────────────
    function _rebuildPanels() {
        var build = function(loader, comp) {
            if (loader.item !== null && loader.item !== undefined)
                loader.item.destroy()
            if (comp !== null)
                comp.createObject(loader)
        }
        leftLoader.active = leftSlot !== null
        if (leftLoader.active) build(leftLoader, leftSlot)
        rightLoader.active = rightSlot !== null
        if (rightLoader.active) build(rightLoader, rightSlot)
    }

    Loader {
        id: leftLoader
        objectName: "NovaSlideItem.leftLoader"
        // RTL（0.16.1）：逻辑 left 面板挂到右缘（拖拽/吸附逻辑的 +x 语义随之自然成立）
        x: NovaTheme.isRtl ? root.width - width : 0
        width: root.revealWidth
        height: root.height
        active: false
    }
    Loader {
        id: rightLoader
        objectName: "NovaSlideItem.rightLoader"
        x: NovaTheme.isRtl ? 0 : root.width - width
        width: root.revealWidth
        height: root.height
        active: false
    }

    // ── 正面（拖拽跟手 + Behavior 吸附） ──────────────────────
    Item {
        id: front
        objectName: "NovaSlideItem.front"
        x: 0
        width: root.width
        height: root.height

        // 吸附动画：非拖拽期生效（拖拽时直接赋值跟手，Behavior 禁用防打架）
        Behavior on x {
            enabled: !dragMa.pressed
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            id: dragMa
            anchors.fill: parent
            enabled: root.leftSlot !== null || root.rightSlot !== null
            preventStealing: true

            property real _startX: 0
            property real _baseX: 0
            property string _dir: ""

            onPressed: function(mouse) {
                _startX = mouse.x
                _baseX = front.x
                _dir = ""
            }
            onPositionChanged: function(mouse) {
                var dx = mouse.x - _startX
                if (_dir === "") {
                    if (Math.abs(dx) < 6) return                 // 死区防抖
                    _dir = dx > 0 ? "right" : "left"
                }
                var off = _baseX + dx
                front.x = Math.max(-root.revealWidth, Math.min(root.revealWidth, off))
            }
            onReleased: root._settle()
            onCanceled: root._settle()
        }
    }

    // 释放吸附：越过阈值打开对应侧，否则闭合
    function _settle() {
        var prog = Math.abs(front.x) / revealWidth
        if (prog >= openThreshold && front.x > 0 && leftSlot !== null) _openSide("left")
        else if (prog >= openThreshold && front.x < 0 && rightSlot !== null) _openSide("right")
        else _closeSide()
    }

    function _openSide(side) {
        if (_side !== side) {
            _side = side
            slideOpened(side)
        }
        front.x = side === "left" ? revealWidth : -revealWidth
    }

    function _closeSide() {
        if (_side !== "") {
            _side = ""
            slideClosed()
        }
        front.x = 0
    }

    // ── 命令式 API ────────────────────────────────────────────
    function slideLeft() { if (leftSlot !== null) _openSide("left") }
    function slideRight() { if (rightSlot !== null) _openSide("right") }
    function reset() { _closeSide() }

    Component.onCompleted: _rebuildPanels()

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
