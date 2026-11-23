// src/pyside_nova/qml/Nova/Controls/NovaParallax.qml
// NovaParallax 视差滚动容器（对标 QParallax）：媒体层随宿主滚动慢速位移（speed 因子），
// scroll-target 缺省向上遍历找最近 Flickable（坑位 14：默认属性转交内部容器 parent 失真）
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 默认槽：前景内容（对标 default slot） ────────────────
    default property alias content: frontLayer.data

    // ── 数据源与效果参数 ────────────────────────────────────
    property url src                       // 媒体图（mediaSlot 缺省时渲染）
    property real speed: 1.0               // 视差速度 0<speed<1（官方默认 1；越小球动越慢）
    property var scrollTarget: null        // 滚动宿主（Flickable/ScrollView）；null 自动向上探测

    // ⛔ height：QML Item.height 即容器高语义，不重复提供
    // ⛔ scroll-target 的 CSS 选择器形态：QML 无 DOM 查询，仅接受 Item 引用

    // ── 事件（对标 scroll，载荷 progress∈[0,1] + contentY） ──
    signal scrolled(var info)

    // ── 命名槽（对标 media 插槽；default 即 content） ────────
    property Component mediaSlot: null

    clip: true
    implicitWidth: 400
    implicitHeight: 300

    // ── 自动探测滚动宿主：向上遍历（坑位 14 语义） ───────────
    readonly property Flickable _flick: scrollTarget !== null ? scrollTarget : _findFlick(root)

    function _findFlick(item) {
        var p = item.parent
        while (p !== null) {
            if (p instanceof Flickable) return p
            p = p.parent
        }
        return null
    }

    // 容器在 contentItem 坐标系中的纵向位置（静态锚定，父链变化时刷新）
    property real _topInContent: 0
    function _measure() {
        if (_flick === null || _flick.contentItem === null) return
        var mapped = root.mapToItem(_flick.contentItem, 0, 0)
        _topInContent = mapped.y
        _apply()
    }
    onParentChanged: Qt.callLater(_measure)
    onScrollTargetChanged: Qt.callLater(_measure)
    onYChanged: Qt.callLater(_measure)
    // 创建期测量双保险：onCompleted 同步一次 + callLater 布局稳定后复核
    // （创建期 contentItem/绑定求值顺序不可靠——实测同步首测可能得 0）
    Component.onCompleted: {
        _measure()
        Qt.callLater(_measure)
    }

    // 进度：容器穿越视口的程度 0（底缘进入）→ 1（顶缘离开）
    readonly property real progress: _flick === null ? 0
        : Math.min(1, Math.max(0, (_flick.contentY + _flick.height - _topInContent)
                                  / (_flick.height + root.height)))

    function _apply() {
        // 媒体层位移：progress × speed × 容器高（图比容器高 speed 倍余量，始终覆盖）
        mediaLayer.y = -mediaLayer.extra * progress
        scrolled({ progress: progress, contentY: _flick !== null ? _flick.contentY : 0 })
    }

    onProgressChanged: _apply()

    function refresh() {
        // 对标 QParallax.refresh()：重测锚定 + 立即重算位移（勿递归调 _measure→_apply→…）
        _measure()
        _apply()
    }

    // ── 媒体层 ──────────────────────────────────────────────
    // extra：媒体层超出容器高的纵向余量 = speed × height（speed 钳制 0~1）
    readonly property real _speed: Math.min(1, Math.max(0, speed))

    Item {
        id: mediaLayer
        x: 0
        width: parent.width
        height: parent.height + mediaLayer.extra
        property real extra: root._speed * root.height

        // 作用域槽优先；否则内部 Image 渲染 src
        Loader {
            anchors.fill: parent
            active: root.mediaSlot !== null
            sourceComponent: root.mediaSlot
        }
        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: root.src
            asynchronous: true
            visible: root.mediaSlot === null && root.src.toString() !== ""
        }
    }

    // 前景内容层（default 槽宿主）
    Item {
        id: frontLayer
        anchors.fill: parent
    }
}
