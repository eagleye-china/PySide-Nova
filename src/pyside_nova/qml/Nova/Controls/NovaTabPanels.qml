// src/pyside_nova/qml/Nova/Controls/NovaTabPanels.qml
// NovaTabPanels 面板容器（对标 QTabPanels）：受控 modelValue / animated / infinite /
// swipeable（DragHandler 被动抓取）/ vertical / transitionDuration；
// 子项即面板（NovaTabPanel 优先，任意 Item 亦可）；条带平移过渡（对标 Carousel 口径）
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 默认槽：面板集合 ────────────────────────────────────
    default property alias content: panelHost.data

    // ── 页寻址（受控，坑位 22：只 emit 不自写） ──────────────
    property var modelValue: null
    signal updateModelValue(var name)
    signal beforeTransition(var info)   // { newIndex, oldIndex, direction }
    signal transition(var info)         // 过渡完成后上报

    // ── 行为开关 ────────────────────────────────────────────
    property bool animated: false
    property bool infinite: false
    property bool swipeable: false
    property bool vertical: false
    property int transitionDuration: 300

    // ⛔ keep-alive 系：Vue 组件缓存语义，QML 无对应（面板常驻条带）；
    // ⛔ transition-prev/next：统一单一滑动过渡（Carousel 口径）；⛔ dark：主题自动跟随

    // ── 派生 ────────────────────────────────────────────────
    readonly property var _panels: _collectPanels()
    readonly property int count: _panels.length
    readonly property int currentIndex: _indexOfValue(modelValue)

    property bool _snap: false   // infinite 回绕瞬移时暂停动画

    function _collectPanels() {
        var out = []
        for (var i = 0; i < panelHost.children.length; i++) {
            var c = panelHost.children[i]
            if (c instanceof Item)
                out.push(c)
        }
        return out
    }
    onChildrenChanged: Qt.callLater(_layout)

    function _indexOfValue(v) {
        for (var i = 0; i < count; i++)
            if (_panels[i].name !== "" && String(_panels[i].name) === String(v))
                return i
        var n = Number(v)
        if (Number.isFinite(n) && n >= 0 && n < count)
            return Math.floor(n)
        return count > 0 ? 0 : -1
    }

    function _nameOf(i) {
        return _panels[i].name !== "" && _panels[i].name !== undefined
               ? _panels[i].name : i
    }

    // ── 导航方法（对标 next/previous/goTo；禁用页跳过） ──────
    function _stepFrom(i, dir) {
        if (count === 0) return -1
        var n = count
        for (var s = 0; s < n; s++) {
            var j = infinite
                ? ((i + dir * (s + 1)) % n + n) % n
                : i + dir * (s + 1)
            if (j < 0 || j >= n)
                return -1
            if (!_panels[j].disable)
                return j
        }
        return -1
    }

    function next() {
        var j = _stepFrom(currentIndex, 1)
        if (j !== -1) goTo(j, true)
    }
    function previous() {
        var j = _stepFrom(currentIndex, -1)
        if (j !== -1) goTo(j, true)
    }
    function goTo(target, animate) {
        if (count === 0) return -1
        var j = -1
        if (typeof target === "number") {
            j = Math.min(Math.max(Math.floor(target), 0), count - 1)
            if (_panels[j].disable) return -1
        } else {
            j = _indexOfValue(target)
            if (j < 0 || _panels[j].disable) return -1
        }
        var old = currentIndex
        if (j === old)
            return j
        var dist = Math.abs(j - old)
        _snap = (animate === false) || (infinite && dist > 1)
        _layout()
        updateModelValue(_nameOf(j))
        beforeTransition({ newIndex: j, oldIndex: old,
                           direction: j > old ? "next" : "prev" })
        _afterTimer.restart()   // 坑位 19：Timer 需显式启动
        return j
    }

    Timer {
        id: _afterTimer
        interval: root.animated && !root._snap ? Math.max(0, root.transitionDuration) : 0
        onTriggered: if (root.currentIndex >= 0)
            root.transition({ newIndex: root.currentIndex, oldIndex: -1, direction: "" })
    }

    // ── 面板布局 ─────────────────────────────────────────────
    function _layout() {
        for (var i = 0; i < count; i++) {
            var p = _panels[i]
            p.width = strip.width
            p.height = strip.height
            p.x = vertical ? 0 : i * strip.width
            p.y = vertical ? i * strip.height : 0
        }
    }

    implicitWidth: 400
    implicitHeight: 200
    clip: true

    // ── 面板条（平移过渡） ───────────────────────────────────
    Item {
        id: clipHost
        anchors.fill: parent

        Item {
            id: strip
            width: parent.width
            height: parent.height
            x: vertical ? 0 : -root.currentIndex * width
            y: vertical ? -root.currentIndex * height : 0

            Behavior on x {
                enabled: root.animated && !root._snap && !root.vertical
                NumberAnimation { duration: root.transitionDuration }
            }
            Behavior on y {
                enabled: root.animated && !root._snap && root.vertical
                NumberAnimation { duration: root.transitionDuration }
            }

            Item {
                id: panelHost
                anchors.fill: parent
                onChildrenChanged: Qt.callLater(root._layout)
            }
        }
    }

    // ── 滑动手势（Carousel 口径：被动抓取不吞子内容点击） ────
    DragHandler {
        id: swipeH
        enabled: root.swipeable && root.count > 1
        target: null
        acceptedButtons: Qt.LeftButton
        xAxis.enabled: !root.vertical
        yAxis.enabled: root.vertical
        onActiveChanged: {
            if (active) return
            var span = root.vertical ? root.height : root.width
            var t = root.vertical ? translation.y : translation.x
            var v = root.vertical ? centroid.velocity.y : centroid.velocity.x
            if (t < -span / 4 || v < -0.5) root.next()
            else if (t > span / 4 || v > 0.5) root.previous()
        }
    }

    onWidthChanged: Qt.callLater(_layout)
    onHeightChanged: Qt.callLater(_layout)
    Component.onCompleted: Qt.callLater(_layout)
}
