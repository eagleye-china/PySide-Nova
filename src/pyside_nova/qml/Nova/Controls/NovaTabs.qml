// src/pyside_nova/qml/Nova/Controls/NovaTabs.qml
// NovaTabs 标签页容器（对标 QTabs）：受控 modelValue、横向滚动 + 溢出箭头
// （outside-arrows/mobile-arrows）、align（left/center/right/justify）、breakpoint 自动
// justify、垂直模式、指示条（narrow/switch）、dense；Tab 激活态由本组件下发
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    // ── 默认槽：NovaTab 集合 ────────────────────────────────
    default property alias content: tabHost.data

    // ── 受控契约（坑位 22：只 emit 不自写） ──────────────────
    property var modelValue: null
    signal updateModelValue(var name)

    // ── 行为（对标 QTabs props） ────────────────────────────
    property bool vertical: false
    property bool outsideArrows: false     // 溢出箭头占位两侧（常显）
    property bool mobileArrows: false      // 窄容器强制显示箭头
    property string align: "center"        // left/center/right/justify
    property int breakpoint: 600           // 容器宽低于此值自动 justify
    property color activeColor: NovaTheme.primary   // 对标 active-color（tint 红线）
    property color activeBgColor: "transparent"     // 对标 active-bg-color
    property color indicatorColor: NovaTheme.primary // 对标 indicator-color
    property string leftIcon: "mdi:chevron-left"
    property string rightIcon: "mdi:chevron-right"
    property bool stretch: false           // Tab 纵向拉伸填满容器
    property bool shrink: false            // 容器收缩为内容宽（默认撑满）
    property bool switchIndicator: false   // 指示条换侧（横→上沿 / 纵→右侧）
    property bool narrowIndicator: false   // 指示条同 Tab 内容宽
    property bool inlineLabel: false       // 图标文案同行（默认垂直堆叠近似——横向模式即同行）
    property bool noCaps: false
    property bool dense: false

    // ⛔ active-class/content-class：HTML class 选择器语义 N/A（样式直连属性下发）
    // ⛔ dark：主题由 NovaTheme 自动跟随

    // ── 派生 ────────────────────────────────────────────────
    readonly property var _tabs: _collectTabs()
    readonly property int count: _tabs.length
    readonly property int currentIndex: _indexOfValue(modelValue)
    readonly property string currentName: currentIndex >= 0 ? _nameOf(currentIndex) : ""

    function _collectTabs() {
        var out = []
        for (var i = 0; i < tabHost.children.length; i++) {
            var c = tabHost.children[i]
            if (c.isNovaTab === true)
                out.push(c)
        }
        return out
    }
    onChildrenChanged: Qt.callLater(_layout)

    function _indexOfValue(v) {
        for (var i = 0; i < count; i++)
            if (_tabs[i].name !== "" && String(_tabs[i].name) === String(v))
                return i
        var n = Number(v)
        if (Number.isFinite(n) && n >= 0 && n < count)
            return Math.floor(n)
        return count > 0 ? 0 : -1
    }

    function _nameOf(i) {
        return _tabs[i].name !== "" ? _tabs[i].name : i
    }

    function _isActive(tab) {
        var i = _tabs.indexOf(tab)
        return i >= 0 && i === currentIndex
    }

    // Tab 点击统一入口（受控上报）
    function _goToTab(tab) {
        var i = _tabs.indexOf(tab)
        if (i < 0 || tab.disable) return
        updateModelValue(_nameOf(i))
    }

    implicitWidth: shrink ? contentMeasure() : 400
    implicitHeight: vertical
        ? (shrink ? contentMeasureH() : 200)
        : (dense ? 36 : 48)

    function contentMeasure() {
        var w = 0
        for (var i = 0; i < _tabs.length; i++)
            w += _tabs[i].implicitWidth
        return w + (dense ? 0 : 0)
    }
    function contentMeasureH() {
        var h = 0
        for (var i = 0; i < _tabs.length; i++)
            h += _tabs[i].implicitHeight
        return h
    }

    // justify：容器宽 < breakpoint 或显式 justify → Tab 均分宽度
    readonly property bool _justify: align === "justify" || (!vertical && width < breakpoint)

    // ── Tab 布局（横向滚动 / 纵向堆叠） ─────────────────────
    function _layout() {
        var tabs = _tabs
        var n = tabs.length
        if (n === 0) { _updateOverflow(); return }
        var sumW = 0
        var maxH = 0
        for (var i = 0; i < n; i++) {
            tabs[i].tabsRef = root
            sumW += tabs[i].implicitWidth
            maxH = Math.max(maxH, tabs[i].implicitHeight)
        }
        if (vertical) {
            for (var v = 0; v < n; v++) {
                tabs[v].width = viewport.width
                tabs[v].height = tabs[v].implicitHeight
                tabs[v].x = 0
                tabs[v].y = _stackY(tabs, v)
            }
        } else {
            var avail = viewport.width
            var eachW = root._justify ? Math.max(0, avail / n) : 0
            var x = 0
            for (var h = 0; h < n; h++) {
                var t = tabs[h]
                t.height = root.stretch ? viewport.height : t.implicitHeight
                t.y = (viewport.height - t.height) / 2
                t.width = root._justify ? eachW : t.implicitWidth
                // 非 justify 时按 align 排布（内容不超宽才偏移）
                x += t.width
            }
            var total = x
            var x0 = 0
            if (!root._justify && total < avail) {
                if (root.align === "center") x0 = (avail - total) / 2
                else if (root.align === "right") x0 = avail - total
            }
            var cx = x0
            for (var h2 = 0; h2 < n; h2++) {
                tabs[h2].x = cx
                cx += tabs[h2].width
            }
        }
        _updateOverflow()
    }

    function _stackY(tabs, idx) {
        var y = 0
        for (var i = 0; i < idx; i++)
            y += tabs[i].height
        return y
    }

    // ── 溢出判定（箭头显隐） ─────────────────────────────────
    readonly property bool _overflow: vertical
        ? tabHost.implicitHeight > viewport.height
        : tabHost.childrenRect.width > viewport.width
    readonly property bool _arrowsVisible: !_overflowBlocked
        && ((outsideArrows || mobileArrows) && _overflow)
    readonly property bool _overflowBlocked: false

    onWidthChanged: Qt.callLater(_layout)
    onHeightChanged: Qt.callLater(_layout)
    onVerticalChanged: Qt.callLater(_layout)
    onAlignChanged: Qt.callLater(_layout)
    on_JustifyChanged: Qt.callLater(_layout)
    onCountChanged: Qt.callLater(_layout)
    Component.onCompleted: Qt.callLater(_layout)

    // ── 视口 ────────────────────────────────────────────────
    readonly property real _edge: _arrowsVisible && outsideArrows ? 40 : 0

    Flickable {
        id: viewport
        x: root._edge
        y: 0
        width: root.width - root._edge * 2
        height: root.height
        contentWidth: root.vertical ? width : Math.max(width, tabHost.childrenRect.width)
        contentHeight: root.vertical ? Math.max(height, tabHost.childrenRect.height) : height
        interactive: root._overflow
        clip: false
        boundsBehavior: Flickable.StopAtBounds

        // Tab 宿主容器（子项由 _layout 手动排布——避坑 24/28：定位不走定位器）
        Item {
            id: tabHost
            x: 0; y: 0
            width: parent.width
            height: parent.height
        }
    }

    // ── 指示条（横：底部下划线；纵：左侧竖条；switchIndicator 换侧） ──
    Rectangle {
        id: indicator
        visible: root.currentIndex >= 0
        color: root.indicatorColor

        // 激活 Tab 几何（相对 viewport）
        readonly property var act: root.currentIndex >= 0 ? root._tabs[root.currentIndex] : null
        readonly property real narrowW: act !== null
            ? Math.min(act.width, contentRowW(act)) : 0

        function contentRowW(t) {
            // narrow-indicator：取 Tab 内容宽（implicitWidth 近似）
            return t.implicitWidth
        }

        x: root.vertical
           ? (root.switchIndicator ? viewport.width - width : 0)
           : (act !== null ? act.x + (root.narrowIndicator ? (act.width - width) / 2 : 0) : 0)
        y: root.vertical
           ? (act !== null ? act.y : 0)
           : (root.switchIndicator ? 0 : viewport.height - height)
        width: root.vertical ? 3
               : (root.narrowIndicator ? narrowW : (act !== null ? act.width : 0))
        height: root.vertical ? (act !== null ? act.height : 0) : 3

        Behavior on x { NumberAnimation { duration: 180 } }
        Behavior on y { NumberAnimation { duration: 180 } }
        Behavior on width { NumberAnimation { duration: 180 } }
        Behavior on height { NumberAnimation { duration: 180 } }
    }

    // ── 溢出箭头（滚动 Flickable） ───────────────────────────
    function _scrollBack() {
        if (root.vertical) viewport.contentY = Math.max(0, viewport.contentY - 80)
        else viewport.contentX = Math.max(0, viewport.contentX - 80)
    }
    function _scrollFwd() {
        if (root.vertical) viewport.contentY = Math.min(viewport.contentHeight - viewport.height, viewport.contentY + 80)
        else viewport.contentX = Math.min(viewport.contentWidth - viewport.width, viewport.contentX + 80)
    }

    NovaBtn {
        id: arrowL
        visible: root._arrowsVisible
        icon: root.vertical ? "mdi:chevron-up" : root.leftIcon
        round: true
        variant: "flat"
        size: "sm"
        x: root.vertical ? (root.width - width) / 2 : 0
        y: root.vertical ? 0 : (root.height - height) / 2
        onClicked: root._scrollBack()
    }
    NovaBtn {
        id: arrowR
        visible: root._arrowsVisible
        icon: root.vertical ? "mdi:chevron-down" : root.rightIcon
        round: true
        variant: "flat"
        size: "sm"
        x: root.vertical ? (root.width - width) / 2 : root.width - width
        y: root.vertical ? root.height - height : (root.height - height) / 2
        onClicked: root._scrollFwd()
    }

    function _updateOverflow() {
        // 触发 _overflow 重评（childrenRect 无独立变更通知口，此处为显式钩子）
    }
}
