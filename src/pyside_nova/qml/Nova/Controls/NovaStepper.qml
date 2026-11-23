// src/pyside_nova/qml/Nova/Controls/NovaStepper.qml
// NovaStepper 步骤条（对标 QStepper）：受控 modelValue / 头部导航（headerNav 逐项开关）/
// 状态图标解析 1:1 对标 2.35.6 StepHeader.js（active > error > done；step 级优先；
// 'none' 退让 prefix→icon/inactiveIcon）/ 垂直模式 / flat-bordered /
// alternative-labels / contracted；navigation/message 命名槽
import QtQuick
import Nova.Controls
import Nova.Services

Rectangle {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.Grouping
    Accessible.name: a11yLabel

    // ── 默认槽：NovaStep 集合 ───────────────────────────────
    default property alias content: stepHost.data

    // ── 命名槽 ──────────────────────────────────────────────
    property alias navigation: navSlot.data   // 对标 navigation 槽（NovaStepperNavigation）
    property Component message: null          // 对标 message 槽（头部消息区模板）

    // ── 受控契约（坑位 22：只 emit 不自写） ──────────────────
    property var modelValue: null
    signal updateModelValue(var name)
    signal beforeTransition(var info)   // { newIndex, oldIndex, direction }
    signal transition(var info)

    // ── 行为（对标 QStepper props） ─────────────────────────
    property bool vertical: false
    property bool headerNav: true           // 总开关；逐步骤 NovaStep.headerNav 可关
    property bool animated: false
    property bool infinite: false
    property bool flat: false
    property bool bordered: false
    property bool alternativeLabels: false  // 图标叠文案（仅水平）
    property bool contracted: false         // 头部只画圆点（窄窗口口径）
    property string inactiveIcon: ""
    property color inactiveColor: NovaTheme.textMuted
    property color doneColor: NovaTheme.primary
    property color activeColor: NovaTheme.primary
    property color errorColor: NovaTheme.negative
    property string doneIcon: "mdi:check"
    property string activeIcon: "mdi:pencil"
    property string errorIcon: "mdi:alert"
    property int transitionDuration: 300

    // ⛔ keep-alive 系：Vue 缓存语义 N/A；⛔ dark：主题自动跟随

    color: NovaTheme.surface
    border.width: bordered ? 1 : 0
    border.color: NovaTheme.outline
    radius: flat ? 0 : NovaTheme.radiusM
    implicitWidth: 560
    implicitHeight: vertical ? 300 : headerH + 240 + 1

    // ── 派生（坑位 28：显式失效——_steps 平铺属性 + _rev 版本号） ──
    property var _steps: []
    property int _rev: 0
    readonly property int count: _steps.length
    readonly property int currentIndex: _rev >= 0 ? _indexOfValue(modelValue) : -1
    readonly property real headerH: vertical
        ? (contracted ? _steps.length * 44 : _steps.length * 56)
        : (alternativeLabels ? 88 : 64)

    function _refreshSteps() {
        var out = []
        for (var i = 0; i < stepHost.children.length; i++) {
            var c = stepHost.children[i]
            if (c.isNovaStep === true)
                out.push(c)
        }
        _steps = out
        _rev++
        Qt.callLater(_layout)
    }
    onChildrenChanged: Qt.callLater(_refreshSteps)
    Component.onCompleted: Qt.callLater(_refreshSteps)

    function _indexOfValue(v) {
        for (var i = 0; i < count; i++)
            if (_steps[i].name !== "" && String(_steps[i].name) === String(v))
                return i
        var n = Number(v)
        if (Number.isFinite(n) && n >= 0 && n < count)
            return Math.floor(n)
        return count > 0 ? 0 : -1
    }

    function _nameOf(i) {
        return _steps[i].name !== "" ? _steps[i].name : i
    }

    // ── 导航（对标 next/previous/goTo；禁用页跳过） ──────────
    function _stepFrom(i, dir) {
        if (count === 0) return -1
        var n = count
        for (var s = 0; s < n; s++) {
            var j = infinite
                ? ((i + dir * (s + 1)) % n + n) % n
                : i + dir * (s + 1)
            if (j < 0 || j >= n) return -1
            if (!_steps[j].disable) return j
        }
        return -1
    }
    function next() {
        var j = _stepFrom(currentIndex, 1)
        if (j !== -1) goTo(j)
    }
    function previous() {
        var j = _stepFrom(currentIndex, -1)
        if (j !== -1) goTo(j)
    }
    function goTo(target) {
        if (count === 0) return -1
        var j = -1
        if (typeof target === "number") {
            j = Math.min(Math.max(Math.floor(target), 0), count - 1)
            if (_steps[j].disable) return -1
        } else {
            j = _indexOfValue(target)
            if (j < 0 || _steps[j].disable) return -1
        }
        var old = currentIndex
        if (j === old) return j
        updateModelValue(_nameOf(j))
        beforeTransition({ newIndex: j, oldIndex: old,
                           direction: j > old ? "next" : "prev" })
        _afterTimer.restart()   // 坑位 19：显式启动
        return j
    }

    Timer {
        id: _afterTimer
        interval: root.animated ? Math.max(0, root.transitionDuration) : 0
        onTriggered: if (root.currentIndex >= 0)
            root.transition({ newIndex: root.currentIndex, oldIndex: -1, direction: "" })
    }

    // 头部点击统一入口（headerNav 总开关 × 步骤级 headerNav × disable）
    function _goToStep(step) {
        var i = _steps.indexOf(step)
        if (i < 0) return
        if (!headerNav || step.disable) return
        if (i === currentIndex) return
        goTo(i)
    }

    // ── 布局 ────────────────────────────────────────────────
    function _layout() {
        if (vertical) {
            // 头部条目栈高已由 headerH 派生；内容区跟随当前步
            for (var i = 0; i < count; i++) {
                _steps[i].width = contentArea.width
                _steps[i].height = contentArea.height
                _steps[i].x = 0
                _steps[i].y = 0
            }
        } else {
            for (var h = 0; h < count; h++) {
                _steps[h].width = contentArea.width
                _steps[h].height = contentArea.height
                _steps[h].x = h * contentArea.width
                _steps[h].y = 0
            }
        }
    }

    // ── 头部状态解析（对标 StepHeader.js） ──────────────────
    function _stateIcon(i) {
        var st = _steps[i]
        var active = i === currentIndex
        var icon = active
            ? (st.activeIcon !== "" ? st.activeIcon
               : (activeIcon !== "" ? activeIcon : ""))
            : (st.error ? (st.errorIcon !== "" ? st.errorIcon : errorIcon)
               : (st.done && !st.disable
                  ? (st.doneIcon !== "" ? st.doneIcon : doneIcon) : ""))
        if (icon === "none") return ""          // 'none' 退让 prefix→icon
        if (icon !== "") return icon
        return ""                                // 无状态图标 → prefix 或 icon
    }

    function _dotColor(i) {
        var st = _steps[i]
        var active = i === currentIndex
        if (active)
            return st.activeColor !== "" ? _qcolor(st.activeColor) : activeColor
        if (st.error) return st.errorColor !== "" ? _qcolor(st.errorColor) : errorColor
        if (!st.disable && st.done)
            return st.doneColor !== "" ? _qcolor(st.doneColor) : doneColor
        return st.color !== "" ? _qcolor(st.color) : inactiveColor
    }

    function _qcolor(s) {
        // Quasar 命名色映射（step 级 color 字符串口径）
        if (s === "primary") return NovaTheme.primary
        if (s === "secondary") return NovaTheme.secondary
        if (s === "accent") return NovaTheme.accent
        if (s === "negative") return NovaTheme.negative
        if (s === "positive") return NovaTheme.positive
        if (s === "warning") return NovaTheme.warning
        if (s === "info") return NovaTheme.info
        if (s === "dark") return NovaTheme.dark
        return Qt.rgba(0, 0, 0, 0)   // 未知命名色 → 透明（退让上层）
    }

    // ══ 头部 ════════════════════════════════════════════════
    Item {
        id: header
        x: 0; y: 0
        width: parent.width
        height: root.headerH

        // message 槽（设置时整幅替代头部）
        Loader {
            anchors.fill: parent
            sourceComponent: root.message
            visible: root.message !== null
        }

        // 头部条目（水平：Row 排布 + 连接线；垂直：栈）
        Item {
            id: headStack
            anchors.fill: parent
            visible: root.message === null

            Repeater {
                model: root.count

                Item {
                    id: headItem
                    required property int index
                    readonly property var st: root._steps[index]
                    readonly property bool active: index === root.currentIndex
                    // 状态色/图标：直读依赖（st.* / currentIndex）强制重评，
                    // 再经 _dotColor/_stateIcon 计算（坑位 24/28：函数调用绑定不可靠）
                    readonly property color dotC: {
                        var _d = st.done
                        var _e = st.error
                        var _x = st.disable
                        var _c = st.color
                        var _ci = root.currentIndex
                        return root._dotColor(index)
                    }
                    readonly property string icon: {
                        var _ai = st.activeIcon
                        var _ei = st.errorIcon
                        var _di = st.doneIcon
                        var _ci = root.currentIndex
                        return root._stateIcon(index)
                    }
                    readonly property bool usePrefix: icon === ""
                        && st.prefix !== ""
                    readonly property bool navOk: root.headerNav && st.headerNav
                        && !st.disable && !active

                    x: root.vertical ? 0
                       : headRowX(index, width)
                    y: root.vertical ? headStackY(index) : 0
                    width: root.vertical ? parent.width
                           : (contracted ? 56
                              : Math.max(120, (parent.width - (root.count - 1) * 2) / root.count))
                    height: root.vertical ? (root.contracted ? 44 : 56)
                                          : parent.height

                    function headRowX(i, w) {
                        // 水平均分（含连接线重叠）
                        return i * w
                    }
                    function headStackY(i) {
                        return i * height
                    }

                    // 连接线（前段：前一步已完成 → 主题色；越界守卫）
                    Rectangle {
                        visible: !root.vertical && headItem.index > 0
                        x: 0; y: 28
                        width: parent.width / 2 - 16
                        height: 2
                        color: headItem.index > 0
                               && headItem.index - 1 < root._steps.length
                               && root._steps[headItem.index - 1] !== undefined
                               && root._steps[headItem.index - 1].done
                               && !root._steps[headItem.index - 1].error
                               ? root.doneColor : NovaTheme.outline
                    }
                    // 连接线（后段：后一步已完成 → 主题色；越界守卫）
                    Rectangle {
                        visible: !root.vertical && headItem.index < root.count - 1
                        x: parent.width / 2 + 16; y: 28
                        width: parent.width / 2 - 16
                        height: 2
                        color: headItem.index < root._steps.length - 1
                               && root._steps[headItem.index + 1] !== undefined
                               && root._steps[headItem.index + 1].done
                               && !root._steps[headItem.index + 1].error
                               ? root.doneColor : NovaTheme.outline
                    }
                    // 垂直连接线
                    Rectangle {
                        visible: root.vertical && headItem.index < root.count - 1
                        x: 16; y: parent.height - 4
                        width: 2
                        height: 12
                        color: NovaTheme.outline
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: NovaTheme.spacingS
                        visible: !(root.alternativeLabels && !root.vertical)

                        Rectangle {
                            width: 28; height: 28; radius: 14
                            color: headItem.active || headItem.st.error
                                   || (headItem.st.done && !headItem.st.disable)
                                   ? headItem.dotC : "transparent"
                            border.width: headItem.active || headItem.st.error
                                          || (headItem.st.done && !headItem.st.disable) ? 0 : 2
                            border.color: headItem.dotC.a > 0 ? headItem.dotC : NovaTheme.textMuted
                            anchors.verticalCenter: parent.verticalCenter

                            NovaIcon {
                                anchors.centerIn: parent
                                visible: !headItem.usePrefix
                                         && (headItem.icon !== "" || headItem.st.icon !== "")
                                icon: headItem.icon !== "" ? headItem.icon
                                      : headItem.st.icon
                                size: 15
                                color: headItem.active || headItem.st.error
                                       || (headItem.st.done && !headItem.st.disable)
                                       ? NovaTheme.textOnPrimary : headItem.dotC
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: headItem.usePrefix
                                text: headItem.st.prefix
                                color: headItem.active || headItem.st.error
                                       || (headItem.st.done && !headItem.st.disable)
                                       ? NovaTheme.textOnPrimary : headItem.dotC
                                font.pixelSize: NovaTheme.fontS
                                font.weight: Font.Medium
                            }
                        }

                        Column {
                            visible: !root.contracted
                                     && headItem.st.title !== ""
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: headItem.st.title
                                color: headItem.active ? headItem.dotC
                                       : (headItem.st.error ? headItem.dotC
                                          : NovaTheme.textColor)
                                font.pixelSize: NovaTheme.fontM
                                font.weight: headItem.active ? Font.DemiBold : Font.Medium
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, 160)
                            }
                            Text {
                                visible: root.message === null
                                         && headItem.st.caption !== ""
                                text: headItem.st.caption
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontS
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, 160)
                            }
                        }
                    }

                    // alternative-labels：图标上、文案下（仅水平）
                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        visible: root.alternativeLabels && !root.vertical

                        Text {
                            text: headItem.usePrefix ? headItem.st.prefix
                                  : (headItem.icon !== "" ? "" : headItem.st.title)
                            color: headItem.dotC
                            font.pixelSize: NovaTheme.fontS
                            visible: text !== ""
                        }
                        Text {
                            visible: !root.contracted && headItem.st.title !== ""
                            text: headItem.st.title
                            color: headItem.active ? headItem.dotC : NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontM
                            elide: Text.ElideRight
                            width: Math.min(implicitWidth, parent.width - 8)
                        }
                    }

                    opacity: headItem.st.disable ? 0.45 : 1

                    MouseArea {
                        anchors.fill: parent
                        enabled: headItem.navOk
                        cursorShape: headItem.navOk ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root._goToStep(headItem.st)
                    }
                }
            }
        }
    }

    // ══ 内容区 ═══════════════════════════════════════════════
    Rectangle {
        id: headerSep
        y: root.headerH
        width: parent.width
        height: 1
        color: NovaTheme.outline
        visible: !root.flat
    }

    Item {
        id: contentArea
        x: 0
        y: root.headerH + 1
        width: parent.width
        height: parent.height - root.headerH - 1
        clip: true

        Item {
            id: strip
            width: parent.width
            height: parent.height
            x: root.vertical ? 0
               : -root.currentIndex * width
            y: root.vertical ? -root.currentIndex * height : 0

            Behavior on x {
                enabled: root.animated && !root.vertical
                NumberAnimation { duration: root.transitionDuration }
            }
            Behavior on y {
                enabled: root.animated && root.vertical
                NumberAnimation { duration: root.transitionDuration }
            }

            Item {
                id: stepHost
                anchors.fill: parent
                onChildrenChanged: Qt.callLater(root._layout)
            }
        }
    }

    // navigation 命名槽（底部工具条）
    Item {
        id: navSlot
        visible: children.length > 0
        x: NovaTheme.spacingM
        y: root.vertical ? height * 0 : root.headerH + 1
        width: parent.width - NovaTheme.spacingM * 2
        height: childrenRect.height
        // 挂载后锚定底部（水平）/内容区底部（垂直）
        Component.onCompleted: Qt.callLater(_anchorNav)
        onChildrenChanged: Qt.callLater(_anchorNav)
        function _anchorNav() {
            if (children.length === 0) return
            y = root.vertical
               ? root.height - height - NovaTheme.spacingM
               : root.height - height - NovaTheme.spacingM
        }
    }

    onWidthChanged: Qt.callLater(_layout)
    onHeightChanged: Qt.callLater(_layout)
    onVerticalChanged: Qt.callLater(_layout)
    onCurrentIndexChanged: Qt.callLater(_layout)
}
