// src/pyside_nova/qml/Nova/Behaviors/NovaIntersection.qml
// NovaIntersection 视口观察行为：进入/离开视口回调、阈值、once、rootMargin、once 再武装（对标 Quasar v-intersection）
// NovaIntersection —— 元素可见性观察（L3 行为层）
//
// 用法（行为作为子项挂到目标 Item 内，target 默认就是宿主）：
//     Rectangle {
//         width: 200; height: 120
//         NovaIntersection {
//             once: true
//             onEntered: (entry) => console.log("进入视口", entry.intersectionRatio)
//         }
//     }
//
// 基线契约（npm quasar@2.35.5 src/directives/intersection/Intersection.json 核实）：
//     value 四态：Function / Object{handler, cfg{root, rootMargin, threshold}} / false / null(undefined)
//     handler(entry) 返回 false → 停止观察；modifiers.once → 首次可见后自动停止（且 once 改回 false 可再武装）
//     entry 字段：target / isIntersecting / intersectionRatio / boundingClientRect / intersectionRect / rootBounds / time
//
// QML 映射（如实记录于 docs/PARITY.md）：
//     handler 函数 → 信号 onIntersect(entry)（每次状态或比例跨阈值都回调）
//     once 修饰符  → once: true；rearm() 手动再武装（对标 setOnce 语义）
//     cfg.root     → root（Item，默认窗口视口）
//     cfg.rootMargin → rootMarginTop/Right/Bottom/Left（四个 real，比字符串解析更 QML）
//     cfg.threshold → threshold（数字或数组）
//     返回值 false → 声明式 QML 无"返回值"，改由 stop() 显式停止
//
// 实现路径差异：基线走浏览器原生 IntersectionObserver（异步、阈值边界通知）；
// Nova 走 NovaIntersectionPool 的帧轮询 + 自算矩形交集（含祖先 clip 链），故比例是精确值而非近似。
import QtQuick
import Nova.Services

Item {
    id: beh

    // ── 配置 ────────────────────────────────────────────────
    property Item target: parent
    property Item root: null                    // null = 窗口视口（NovaIntersectionPool.viewport()）

    property real rootMarginTop: 0
    property real rootMarginRight: 0
    property real rootMarginBottom: 0
    property real rootMarginLeft: 0

    // 阈值：数字或数组。只决定"什么时候回调"，不影响 intersectionRatio 的精确值。
    property var threshold: 0
    property bool once: false

    // ── 状态（只读） ────────────────────────────────────────
    readonly property bool isIntersecting: _intersecting
    readonly property real intersectionRatio: _ratio
    readonly property bool observing: _observed

    property bool _intersecting: false
    property real _ratio: 0
    property bool _done: false
    property bool _observed: false

    // ── 信号 ────────────────────────────────────────────────
    signal intersect(var entry)        // 每次跨阈值/翻转（对标 handler 每次回调）
    signal entered(var entry)          // 由不可见 → 可见
    signal exited(var entry)           // 由可见 → 不可见

    anchors.fill: parent
    visible: false                     // 纯逻辑行为，不参与渲染

    Component.onCompleted: {
        if (beh.enabled)
            beh._start()
    }

    Component.onDestruction: beh._stop()

    onEnabledChanged: {
        if (beh.enabled) {
            // 禁用期结束 = 重新武装：基线里"把 handler 重新赋上"就会重新观察，这里用 enabled 开关表达
            beh._done = false
            beh._start()
        } else {
            beh._stop()
        }
    }

    // ── 订阅控制 ────────────────────────────────────────────
    function _start() {
        if (beh._observed)
            return
        // 重置上一次的判定：观察器只报"变化"，而重新观察必须把当前状态再交付一次
        // （对标基线 reobserve：状态没变过就再也不会通知，只能靠重新 observe 补一帧）
        beh._intersecting = false
        beh._ratio = 0
        beh._observed = NovaIntersectionPool.add(beh)
    }

    function _stop() {
        if (!beh._observed)
            return
        NovaIntersectionPool.remove(beh)
        beh._observed = false
    }

    // 显式停止（对标 handler 返回 false）
    function stop() {
        beh._done = true
        beh._stop()
    }

    // 再武装：对标 setOnce(false) 让 once 退休的元素重新观察
    function rearm() {
        beh._done = false
        if (beh.enabled)
            beh._start()
    }

    // 立即求值一次（不等下一帧）
    function kick() {
        beh.evaluate()
    }

    // ── 阈值工具 ────────────────────────────────────────────
    function _thresholds() {
        var t = beh.threshold
        if (t === undefined || t === null)
            return [0]
        if (typeof t === "number")
            return [t]
        if (Array.isArray(t) && t.length > 0)
            return t
        return [0]
    }

    function _crossed(prev, next) {
        var ts = beh._thresholds()
        for (var i = 0; i < ts.length; i++) {
            var t = ts[i]
            if ((prev < t && next >= t) || (prev >= t && next < t))
                return true
        }
        return false
    }

    // ── 几何测量 ────────────────────────────────────────────
    // 返回 { ratio, intersecting, bounding, intersection, root } 或 null（不可测）
    function measure() {
        var t = beh.target
        var r = beh.root ? beh.root : NovaIntersectionPool.viewport()
        if (!t || !r || t.width <= 0 || t.height <= 0 || r.width <= 0 || r.height <= 0)
            return null

        var p = t.mapToItem(r, 0, 0)
        var box = NovaIntersectionPool.toRect(p.x, p.y, t.width, t.height)

        // 祖先裁剪链：原生 IntersectionObserver 会把祖先 clip 计入可见区域，
        // 这里从 target.parent 起逐个求交（Flickable.clip 是最常见的一环）。
        var node = t.parent
        while (node && node !== r) {
            if (node.clip === true && node.width > 0 && node.height > 0) {
                var np = node.mapToItem(r, 0, 0)
                box = NovaIntersectionPool.intersect(
                            box, NovaIntersectionPool.toRect(np.x, np.y, node.width, node.height))
            }
            node = node.parent
        }

        var view = NovaIntersectionPool.toRect(
                    -beh.rootMarginLeft, -beh.rootMarginTop,
                    r.width + beh.rootMarginLeft + beh.rootMarginRight,
                    r.height + beh.rootMarginTop + beh.rootMarginBottom)
        var inter = NovaIntersectionPool.intersect(box, view)

        var total = t.width * t.height
        var ratio = total > 0 ? (inter.width * inter.height) / total : 0
        return { ratio: ratio, intersecting: ratio > 0, bounding: box, intersection: inter, root: view }
    }

    function _makeEntry(m) {
        return {
            "target": beh.target,
            "isIntersecting": m.intersecting,
            "intersectionRatio": m.ratio,
            "boundingClientRect": m.bounding,
            "intersectionRect": m.intersection,
            "rootBounds": m.root,
            "time": Date.now()
        }
    }

    // ── 池回调（每 tick） ────────────────────────────────────
    function evaluate() {
        if (!beh.enabled || beh._done)
            return true                       // 保持订阅但不计算

        var m = beh.measure()
        if (!m)
            return true

        var wasIn = beh._intersecting
        var prevRatio = beh._ratio
        beh._ratio = m.ratio
        beh._intersecting = m.intersecting

        var flipped = wasIn !== m.intersecting
        if (!flipped && !beh._crossed(prevRatio, m.ratio))
            return true                       // 无变化：不打扰调用方（比基线安静，是刻意的）

        var entry = beh._makeEntry(m)
        beh.intersect(entry)
        if (m.intersecting && !wasIn)
            beh.entered(entry)
        else if (!m.intersecting && wasIn)
            beh.exited(entry)

        if (beh.once && m.intersecting) {
            beh._done = true
            return false                      // false → 池移除订阅（一次性观察结束）
        }
        return true
    }
}
