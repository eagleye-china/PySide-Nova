// src/pyside_nova/qml/Nova/Controls/NovaFab.qml
// NovaFab 悬浮按钮组（对标 QFab）：主圆钮 + NovaFabAction 子项；direction 展开方向 /
// stagger 级联动画（逐个 delay=idx×stagger 显现）/ hover 打开契约（hoverDelay 进入 /
// hoverHideDelay 离场宽限）/ external-label / 垂直动作对齐；受控 modelValue(bool)
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 默认槽：NovaFabAction 集合 ──────────────────────────
    default property alias content: actionHost.data

    // ── 受控契约（坑位 22：只 emit 不自写） ──────────────────
    property bool modelValue: false
    signal updateModelValue(bool open)
    signal beforeShow()
    signal shown()    // 坑位 25：show 与 QML 内建语义规避
    signal beforeHide()
    signal hidden()

    // ── 行为（对标 QFab props） ─────────────────────────────
    property bool hover: false             // 悬停展开/离场收起
    property int hoverDelay: 0             // 进入→展开延迟 ms
    property int hoverHideDelay: 150       // 离场宽限 ms
    property string direction: "right"     // right/left/up/down
    property string verticalActionsAlign: "center"  // up/down 时水平对齐 left/center/right
    property int stagger: 40               // 级联节拍 ms
    property string icon: "mdi:plus"
    property string activeIcon: "mdi:close"
    property bool hideIcon: false
    property string label: ""
    property bool externalLabel: false     // label 外置于按钮旁（展开常显口径）
    property string labelPosition: "right" // left/right/top/bottom
    property bool hideLabel: false
    property bool square: false
    property bool disable: false
    property color tint: NovaTheme.primary      // 基调色红线
    property color textColor: NovaTheme.textOnPrimary

    // ⛔ persistent：路由导航隐藏语境 N/A；⛔ tooltip 槽：四期弹层体系交付后接入；
    // ⛔ type/outline/push/unelevated/glossy：HTML 按钮形态，Nova 圆钮形态固定

    implicitWidth: 44
    implicitHeight: 44

    // 展开度（主钮图标旋转等）；open 为视图态（宿主写回后跟随）
    readonly property bool open: modelValue

    // ── 动作（对标 show/hide/toggle；只 emit 不自写；级联由 open 变化统一驱动） ──
    function show() {
        if (disable || open) return
        beforeShow()
        updateModelValue(true)
        shown()
    }
    function hide() {
        if (disable || !open) return
        beforeHide()
        updateModelValue(false)
        hidden()
    }
    function toggle() {
        open ? hide() : show()
    }

    function requestToggle() {
        if (disable) return
        toggle()
    }

    // ── 级联节拍（stagger）：宿主写回 open 后逐个 Timer 下发 revealed ──
    // （坑位 19：createObject 的 Timer 必须显式 start）
    property var _timers: []
    function _stagger(reveal) {
        if (actionHost === null) return
        var acts = _actions()
        for (var t = 0; t < _timers.length; t++) _timers[t].destroy()
        _timers = []
        for (var i = 0; i < acts.length; i++) {
            var act = acts[i]
            var ms = reveal ? i * stagger : 0
            act.delay = ms
            if (reveal) {
                act.revealed = false
                var tm = _timerComp.createObject(root)
                tm.interval = Math.max(0, ms)
                tm.target = act
                tm.start()   // 显式启动
                _timers.push(tm)
            } else {
                act.revealed = false
            }
        }
    }
    on_OpenChanged: {
        _hoverTimer.stop()
        _stagger(open)
    }

    Component {
        id: _timerComp
        Timer {
            property var target: null
            repeat: false
            onTriggered: if (target !== null) target.revealed = true
        }
    }

    function _actions() {
        var out = []
        for (var i = 0; i < actionHost.children.length; i++) {
            var c = actionHost.children[i]
            if (c.revealed !== undefined)
                out.push(c)
        }
        return out
    }

    // ── 动作排布（沿 direction 线性展开） + hover 命中区更新 ──
    function _placeActions() {
        var acts = _actions()
        var step = 48   // 动作间距
        var minX = 0, minY = 0, maxX = mainBtn.width, maxY = mainBtn.height
        for (var i = 0; i < acts.length; i++) {
            var a = acts[i]
            a.width = a.implicitWidth
            a.height = a.implicitHeight
            if (direction === "right") {
                a.x = mainBtn.width + step * (i + 1)
                a.y = (mainBtn.height - a.height) / 2
            } else if (direction === "left") {
                a.x = -step * (i + 1) - (a.width - mainBtn.width)
                a.y = (mainBtn.height - a.height) / 2
            } else if (direction === "up") {
                a.x = _vAlignX(a.width)
                a.y = -step * (i + 1)
            } else {   // down
                a.x = _vAlignX(a.width)
                a.y = mainBtn.height + step * (i + 1)
            }
            minX = Math.min(minX, a.x)
            minY = Math.min(minY, a.y)
            maxX = Math.max(maxX, a.x + a.width)
            maxY = Math.max(maxY, a.y + a.height)
        }
        hoverArea.x = minX; hoverArea.y = minY
        hoverArea.width = maxX - minX
        hoverArea.height = maxY - minY
    }

    function _vAlignX(w) {
        if (verticalActionsAlign === "left") return 0
        if (verticalActionsAlign === "right") return mainBtn.width - w
        return (mainBtn.width - w) / 2
    }

    onWidthChanged: Qt.callLater(_placeActions)
    onHeightChanged: Qt.callLater(_placeActions)
    onDirectionChanged: Qt.callLater(_placeActions)
    onVerticalActionsAlignChanged: Qt.callLater(_placeActions)
    Component.onCompleted: {
        Qt.callLater(_placeActions)
        if (open) Qt.callLater(function () { _stagger(true) })
    }

    // ── hover 契约（进入 hoverDelay 展开；离场 hoverHideDelay 宽限收起）；
    //    命中区 = 主钮 + 动作外溢范围（hoverArea，_placeActions 统一更新） ──
    Item {
        id: hoverArea
        x: 0; y: 0
        width: root.width
        height: root.height

        HoverHandler {
            id: hov
            enabled: root.hover && !root.disable
            onHoveredChanged: root._onHover(hovered)
        }
    }

    function _onHover(now) {
        if (!hover || disable) return
        _hoverTimer.stop()
        if (now && !open) {
            _hoverTimer.pendingReveal = true
            _hoverTimer.interval = Math.max(0, hoverDelay)
            _hoverTimer.restart()
        } else if (!now && open) {
            _hoverTimer.pendingReveal = false
            _hoverTimer.interval = Math.max(0, hoverHideDelay)
            _hoverTimer.restart()
        }
    }

    Timer {
        id: _hoverTimer
        property bool pendingReveal: true
        onTriggered: pendingReveal ? root.show() : root.hide()
    }

    // ── 主圆钮 ──────────────────────────────────────────────
    Rectangle {
        id: mainBtn
        width: 44
        height: 44
        radius: root.square ? NovaTheme.radiusS : 22
        color: root.tint
        opacity: root.disable ? 0.5 : 1

        NovaIcon {
            anchors.centerIn: parent
            visible: !root.hideIcon
            icon: root.open ? root.activeIcon : root.icon
            size: 22
            color: root.textColor
            rotation: root.open ? 45 : 0

            Behavior on rotation { NumberAnimation { duration: 160 } }
        }

        Text {
            anchors.centerIn: parent
            visible: root.hideIcon && root.label !== "" && !root.externalLabel
            text: root.label
            color: root.textColor
            font.pixelSize: NovaTheme.fontM
        }

        MouseArea {
            anchors.fill: parent
            enabled: !root.disable
            cursorShape: root.disable ? Qt.ArrowCursor : Qt.PointingHandCursor
            onClicked: root.requestToggle()
        }
    }

    // 外置 label（externalLabel：按钮旁常显）
    Text {
        visible: root.externalLabel && !root.hideLabel && root.label !== ""
        text: root.label
        color: NovaTheme.textColor
        font.pixelSize: NovaTheme.fontM
        x: labelPosition === "right" ? mainBtn.width + NovaTheme.spacingS
           : labelPosition === "left" ? -implicitWidth - NovaTheme.spacingS
           : 0
        y: labelPosition === "top" ? -implicitHeight - 4
           : labelPosition === "bottom" ? mainBtn.height + 4
           : (mainBtn.height - implicitHeight) / 2
    }

    // 动作宿主（覆盖主钮邻域；clip 关闭以容纳外溢动作）
    Item {
        id: actionHost
        x: mainBtn.x
        y: mainBtn.y
        width: mainBtn.width
        height: mainBtn.height
        onChildrenChanged: Qt.callLater(root._placeActions)
    }

    readonly property bool _open: open
}
