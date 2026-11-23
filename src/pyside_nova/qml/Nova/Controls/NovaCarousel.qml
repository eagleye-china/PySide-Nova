// src/pyside_nova/qml/Nova/Controls/NovaCarousel.qml
// NovaCarousel 轮播（对标 QCarousel）：受控 modelValue / arrows / navigation / thumbnails /
// autoplay / infinite / swipeable(DragHandler 被动抓取不吞子内容点击) / animated；
// 子项即页（NovaCarouselSlide 优先，任意 Item 亦可），NovaCarouselControl 自动挂覆盖层
import QtQuick
import Nova.Controls
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
    // 键盘路径：方向键翻页（左右 / 垂直时上下），Home/End 跳首尾
    Keys.onPressed: function(ev) {
        var fwd = root.vertical ? Qt.Key_Down : Qt.Key_Right
        var back = root.vertical ? Qt.Key_Up : Qt.Key_Left
        if (ev.key === fwd) { root.next(); ev.accepted = true }
        else if (ev.key === back) { root.previous(); ev.accepted = true }
        else if (ev.key === Qt.Key_Home) { root.goTo(0, root.animated); ev.accepted = true }
        else if (ev.key === Qt.Key_End) { root.goTo(root._collectSlides().length - 1, root.animated); ev.accepted = true }
    }

    // ── 默认槽：轮播页集合（对标 default slot） ──────────────
    default property alias content: slideHost.data

    // 宿主识别标记（NovaCarouselControl 自动挂载用）
    readonly property bool isNovaCarousel: true

    // 覆盖层引用（CarouselControl 锚定基准；id 跨文档不可见，必须以属性暴露）
    readonly property alias controlLayerItem: controlLayer

    // 自动轮播运行态（诊断/测试用）
    readonly property bool autoRunning: autoTimer.running

    // ── 页寻址（受控，坑位 22：只 emit 不自写） ──────────────
    // modelValue 为当前页 name（可为数字——页名亦可取整数字面量）；未具名页按序号寻址
    property var modelValue: 0
    signal updateModelValue(var name)
    signal beforeTransition(var info)   // { newIndex, oldIndex, direction }
    signal transition(var info)         // 过渡完成后上报（对标 transition 事件）

    // ── 行为开关 ────────────────────────────────────────────
    property bool animated: true
    property bool infinite: false
    property bool swipeable: true
    property bool vertical: false
    property int transitionDuration: 300
    property bool padding: false

    // ── 自动轮播（对标 autoplay）：数字毫秒 | true→5000 | 负数反向 | false 停 ──
    property var autoplay: false

    // ── 控件 ────────────────────────────────────────────────
    property bool arrows: false
    property string prevIcon: "mdi:chevron-left"
    property string nextIcon: "mdi:chevron-right"
    property bool navigation: false
    property string navigationPosition: "bottom"   // top/right/bottom/left
    property string navigationIcon: ""             // 非空：图标导航点（对标 navigation-icon）
    property bool thumbnails: false                // 缩略图导航（取页 imgSrc）
    property color controlTint: NovaTheme.primary  // 对标 control-color（tint 命名红线）
    property color controlTextColor: NovaTheme.textOnPrimary  // 对标 control-text-color

    // ⛔ fullscreen/no-route-fullscreen-exit：窗口全屏与浏览器路由退出语境强耦合，
    //   留待四期弹层体系统一裁定；⛔ keep-alive 系（Vue 组件缓存语义）；
    // ⛔ transition-prev/next（过渡名选择器）：统一单一滑动过渡；
    // ⛔ control-type：控件按钮形态固定；⛔ dark：主题由 NovaTheme 自动跟随
    // ⛔ height：QML Item.height 即容器高语义，不重复提供

    // ── 派生 ────────────────────────────────────────────────
    readonly property var _slides: _collectSlides()
    readonly property int count: _slides.length
    readonly property int currentIndex: _indexOfValue(modelValue)
    readonly property string currentName: count > 0 && currentIndex >= 0
        ? (_slides[currentIndex].name !== "" ? _slides[currentIndex].name : currentIndex) : ""

    property bool _snap: false   // infinite 回绕瞬移时暂停动画

    function _collectSlides() {
        var out = []
        for (var i = 0; i < slideHost.children.length; i++) {
            var c = slideHost.children[i]
            if (c.isNovaCarouselControl === true)
                continue   // 覆盖控件不是页（挂载完成后已迁移）
            if (c instanceof Item)
                out.push(c)
        }
        return out
    }
    onCountChanged: Qt.callLater(_layout)

    function _indexOfValue(v) {
        for (var i = 0; i < count; i++)
            if (_slides[i].name !== "" && String(_slides[i].name) === String(v))
                return i
        var n = Number(v)
        if (Number.isFinite(n) && n >= 0 && n < count)
            return Math.floor(n)
        return count > 0 ? 0 : -1
    }

    function _nameOf(i) {
        return _slides[i].name !== "" ? _slides[i].name : i
    }

    // ── 导航方法（对标 next/previous/goTo） ──────────────────
    function _stepFrom(i, dir) {
        if (count === 0) return -1
        var n = count
        for (var s = 0; s < n; s++) {
            var j = infinite
                ? ((i + dir * (s + 1)) % n + n) % n
                : i + dir * (s + 1)
            if (j < 0 || j >= n)
                return -1
            if (!_slides[j].disable)
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
            if (_slides[j].disable) return -1
        } else {
            j = _indexOfValue(target)
            if (j < 0 || _slides[j].disable) return -1
        }
        var old = currentIndex
        if (j === old)
            return j
        // infinite 回绕（首尾跳变）瞬移不带动画，避免长距离扫过中间页
        var dist = Math.abs(j - old)
        _snap = (animate === false) || (infinite && dist > 1)
        _layout()
        updateModelValue(_nameOf(j))
        beforeTransition({ newIndex: j, oldIndex: old,
                           direction: j > old ? "next" : "prev" })
        // transition 事件在过渡完成后上报（坑位 19：Timer 需显式启动）
        _afterTimer.restart()
        autoTimer.restart()   // 手动导航重置自动轮播节拍
        return j
    }

    Timer {
        id: _afterTimer
        interval: root.animated && !root._snap ? Math.max(0, root.transitionDuration) : 0
        onTriggered: if (root.currentIndex >= 0)
            root.transition({ newIndex: root.currentIndex, oldIndex: -1, direction: "" })
    }

    // ── 自动轮播 Timer（坑位 19：显式 restart；到末页且非 infinite 即停） ──
    readonly property real _autoMs: autoplay === true ? 5000
        : (typeof autoplay === "number" && autoplay !== 0 ? Math.abs(autoplay) : 0)
    readonly property bool _autoReverse: typeof autoplay === "number" && autoplay < 0
    readonly property bool _autoAtEnd: !infinite && (
        _autoReverse ? currentIndex <= 0 : currentIndex >= count - 1)

    Timer {
        id: autoTimer
        interval: root._autoMs
        repeat: false
        running: root._autoMs > 0 && root.count > 1 && !root._autoAtEnd
        onTriggered: root._autoReverse ? root.previous() : root.next()
    }

    // ── 页布局 ───────────────────────────────────────────────
    function _layout() {
        for (var i = 0; i < count; i++) {
            var s = _slides[i]
            s.width = strip.width
            s.height = strip.height
            s.x = vertical ? 0 : i * strip.width
            s.y = vertical ? i * strip.height : 0
        }
    }

    implicitWidth: 600
    implicitHeight: 300
    clip: true

    // ── 页面条（平铺所有页，x/y 平移过渡） ────────────────────
    Item {
        id: clipHost
        anchors.fill: parent
        anchors.margins: root.padding ? NovaTheme.spacingM : 0

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
                id: slideHost
                anchors.fill: parent
                onChildrenChanged: Qt.callLater(root._layout)
            }
        }
    }

    // ── 滑动手势：DragHandler 被动抓取（不吞子内容点击） ──────
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
            // 快速甩动（速度过阈）或拖过 1/4 尺寸都翻页
            if (t < -span / 4 || v < -0.5) root.next()
            else if (t > span / 4 || v > 0.5) root.previous()
        }
    }

    // ── 覆盖层（arrows / navigation / thumbnails / CarouselControl） ──
    Item {
        id: controlLayer
        anchors.fill: parent
        anchors.margins: root.padding ? NovaTheme.spacingM : 0
    }

    function _registerControl(item) {
        item.parent = controlLayer
    }

    // 前后箭头（垂直模式移到上下）
    NovaBtn {
        id: arrowPrev
        visible: root.arrows && root.count > 1
                  && (root.currentIndex > 0 || root.infinite)
        icon: root.prevIcon
        round: true
        variant: "filled"
        tint: root.controlTint
        disable: root.count === 0 || (root.currentIndex <= 0 && !root.infinite)
        x: root.vertical ? (root.width - width) / 2 : NovaTheme.spacingS
        y: root.vertical ? NovaTheme.spacingS : (root.height - height) / 2
        onClicked: root.previous()
    }
    NovaBtn {
        id: arrowNext
        visible: root.arrows && root.count > 1
                  && (root.currentIndex < root.count - 1 || root.infinite)
        icon: root.nextIcon
        round: true
        variant: "filled"
        tint: root.controlTint
        disable: root.count === 0 || (root.currentIndex >= root.count - 1 && !root.infinite)
        x: root.vertical ? (root.width - width) / 2 : root.width - width - NovaTheme.spacingS
        y: root.vertical ? root.height - height - NovaTheme.spacingS : (root.height - height) / 2
        onClicked: root.next()
    }

    // 导航点 / 缩略图（navigationPosition 决定停靠边）
    readonly property bool _navAtBottom: !root.vertical &&
        (navigationPosition === "bottom" || navigationPosition === "top")
    readonly property bool _navTopEdge: navigationPosition === "top" || navigationPosition === "left"

    Row {
        id: navRow
        visible: (root.navigation || root.thumbnails) && root.count > 1
        spacing: NovaTheme.spacingS

        Repeater {
            model: root.count

            Rectangle {
                id: dot
                required property int index
                readonly property bool isCurrent: root.currentIndex === index
                readonly property var slideItem: root._slides[index]
                readonly property bool isThumb: root.thumbnails
                    && slideItem !== null && slideItem.imgSrc !== undefined
                    && slideItem.imgSrc.toString() !== ""

                width: root.thumbnails && isThumb ? 44 : (root.navigationIcon !== "" ? 24 : 10)
                height: root.thumbnails && isThumb ? 32 : 10
                radius: root.thumbnails && isThumb ? NovaTheme.radiusS : height / 2
                color: isCurrent ? root.controlTint : "transparent"
                border.width: 1
                border.color: isCurrent ? root.controlTint
                              : root.controlTextColor

                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: dot.isThumb ? dot.slideItem.imgSrc : ""
                    asynchronous: true
                    opacity: dot.isCurrent ? 1 : 0.55
                }
                NovaIcon {
                    anchors.centerIn: parent
                    visible: root.navigationIcon !== ""
                    icon: root.navigationIcon
                    size: 18
                    color: dot.isCurrent ? root.controlTextColor : root.controlTextColor
                }

                opacity: root._slides[index].disable ? 0.35 : 1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goTo(dot.index, true)
                }

                Behavior on color { ColorAnimation { duration: 160 } }
            }
        }
    }

    // navRow 停靠位置（navigation-position 对标：top/right/bottom/left）由 _placeNav 统一布局

    on_NavTopEdgeChanged: Qt.callLater(_placeNav)
    onNavigationPositionChanged: Qt.callLater(_placeNav)
    onWidthChanged: Qt.callLater(_placeNav)
    onHeightChanged: Qt.callLater(_placeNav)
    on_NavAtBottomChanged: Qt.callLater(_placeNav)
    Component.onCompleted: Qt.callLater(_placeNav)

    function _placeNav() {
        if (!navRow.visible) return
        var m = NovaTheme.spacingS
        if (navigationPosition === "top") {
            navRow.x = (width - navRow.width) / 2; navRow.y = m
        } else if (navigationPosition === "bottom") {
            navRow.x = (width - navRow.width) / 2; navRow.y = height - navRow.height - m
        } else if (navigationPosition === "left") {
            navRow.x = m; navRow.y = (height - navRow.height) / 2
        } else if (navigationPosition === "right") {
            navRow.x = width - navRow.width - m; navRow.y = (height - navRow.height) / 2
        } else {
            navRow.x = (width - navRow.width) / 2; navRow.y = height - navRow.height - m
        }
    }

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
