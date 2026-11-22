// src/pyside_nova/qml/Nova/Behaviors/NovaScrollObserver.qml
// NovaScrollObserver 滚动位置观察行为：滚动回调、方向、边界（对标 Quasar v-scroll）
// NovaScrollObserver —— 滚动监听（L3 行为层）
//
// 用法：
//     Flickable {
//         id: list
//         NovaScrollObserver {
//             onScroll: (d) => bar.position = d.vertical / list.contentHeight
//         }
//     }
//
// 基线契约（npm quasar@2.35.5 src/directives/scroll/Scroll.json 核实）：
//     value: Function(verticalScrollPosition, horizontalScrollPosition) | undefined(禁用)
//     QML 映射：函数 → 信号 onScroll(details)，details 同时给出两个位置与增量/方向/边界（增强）
//
// root 解析顺序：显式 root → 最近可滚动祖先（Flickable/ListView/GridView，有 contentY）→ 窗口视口
// 驱动：NovaIntersectionPool 帧轮询（与 Intersection/ScrollFire 共用唯一驱动源，避免每个行为各自开定时器）
import QtQuick
import Nova.Services

Item {
    id: beh

    property Item target: parent
    property Item root: null                  // null = 自动（最近可滚动祖先）
    property bool trackHorizontal: true

    readonly property real verticalPosition: _v
    readonly property real horizontalPosition: _h
    readonly property Item scrollRoot: _root

    property real _v: 0
    property real _h: 0
    property Item _root: null
    property bool _observed: false

    signal scroll(var details)

    anchors.fill: parent

    Component.onCompleted: {
        beh._root = beh._resolveRoot()
        if (beh.enabled)
            beh._start()
    }

    Component.onDestruction: beh._stop()

    onEnabledChanged: {
        if (beh.enabled)
            beh._start()
        else
            beh._stop()
    }

    onRootChanged: {
        beh._root = beh._resolveRoot()
        beh.kick()
    }

    function _resolveRoot() {
        if (beh.root)
            return beh.root
        var sc = NovaIntersectionPool.nearestScrollable(beh.target ? beh.target : beh.parent)
        return sc ? sc : NovaIntersectionPool.viewport()
    }

    function _start() {
        if (beh._observed)
            return
        beh._observed = NovaIntersectionPool.add(beh)
    }

    function _stop() {
        if (!beh._observed)
            return
        NovaIntersectionPool.remove(beh)
        beh._observed = false
    }

    function kick() {
        beh.evaluate()
    }

    function evaluate() {
        if (!beh.enabled)
            return true
        var r = beh._root ? beh._root : beh._resolveRoot()
        if (!r)
            return true

        var pos = NovaIntersectionPool.scrollPosition(r)
        var prevV = beh._v
        var prevH = beh._h
        var dv = pos.y - prevV
        var dh = pos.x - prevH
        if (dv === 0 && dh === 0)
            return true

        beh._v = pos.y
        beh._h = pos.x

        var maxV = typeof r.contentHeight === "number" ? Math.max(0, r.contentHeight - r.height) : 0
        var maxH = typeof r.contentWidth === "number" ? Math.max(0, r.contentWidth - r.width) : 0

        beh.scroll({
            "vertical": pos.y,
            "horizontal": pos.x,
            "deltaY": dv,
            "deltaX": dh,
            "direction": Math.abs(dv) >= Math.abs(dh) ? (dv > 0 ? "down" : "up")
                                                      : (dh > 0 ? "right" : "left"),
            "atTop": pos.y <= 0.5,
            "atBottom": maxV > 0 && pos.y >= maxV - 0.5,
            "atLeft": pos.x <= 0.5,
            "atRight": maxH > 0 && pos.x >= maxH - 0.5,
            "root": r
        })
        return true
    }
}
