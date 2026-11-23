// src/pyside_nova/qml/Nova/Services/NovaIntersectionPool.qml
// NovaIntersectionPool 视口观察池单例：一个定时器驱动全部订阅者批量求值（对标 Quasar 2.30 共享 IntersectionObserver 池）
// NovaIntersectionPool —— 共享观察池（L3 行为层基础设施）
//
// 为什么需要池：浏览器的 IntersectionObserver 每帧对每个 observer 单独跑一遍，
// N 个单元素 observer 的开销远大于 1 个 observer 挂 N 个 target。QML 没有 IntersectionObserver，
// 等价能力靠"N 个订阅者 + 1 个驱动源"实现——本池即那个唯一驱动源：
// 一个 Timer（pollInterval）批量调用订阅者的 evaluate()，订阅者自己算比例、自己决定回不回调。
//
// 订阅者契约（QML 对象，非裸 JS 对象——裸对象属性变化无通知，0.6.2 坑位）：
//     evaluate() -> Boolean    返回 false = 已失效，池会把你踢出去；返回 true = 继续观察
// 池不关心订阅者是谁：NovaIntersection / NovaScrollObserver / NovaScrollFire 共用同一驱动源。
//
// 实现路径差异（如实记录于 docs/PARITY.md）：基线是浏览器原生 IntersectionObserver（异步、按阈值边界通知）；
// Nova 是"帧轮询 + 自算矩形交集"，因此 pollInterval 越小越灵敏、开销越大（默认 34ms ≈ 30fps）。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma Singleton
import QtQuick
import Nova.Services

QtObject {
    id: pool

    // ── 配置 ────────────────────────────────────────────────
    // 轮询间隔（毫秒）：34 ≈ 30fps。滚动/动画/布局变化都能被捕捉，代价是常驻定时器开销。
    property int pollInterval: 34

    // ── 状态 ────────────────────────────────────────────────
    property var _subs: []
    readonly property int count: _subs.length

    // 唯一驱动源：有订阅者才跑（无订阅时零开销）
    property Timer ticker: Timer {
        interval: pool.pollInterval
        repeat: true
        running: pool._subs.length > 0
        onTriggered: pool.tick()
    }

    // ── 订阅管理 ────────────────────────────────────────────
    function add(sub) {
        if (!sub)
            return false
        if (pool._subs.indexOf(sub) !== -1)
            return false
        // 不可变更新：var 属性的 in-place push 不触发变更通知（_subs 被 ticker.running 绑定）
        pool._subs = pool._subs.concat([sub])
        pool.tick()          // 立即求值一次，订阅当帧就有结论（对标 observer 首次回调）
        return true
    }

    function remove(sub) {
        var idx = pool._subs.indexOf(sub)
        if (idx === -1)
            return false
        var out = pool._subs.slice()
        out.splice(idx, 1)
        pool._subs = out
        return true
    }

    function clear() {
        pool._subs = []
    }

    // 手动踢一脚（立即可达，不等下一帧）：尺寸变化、页面切换、按钮触发后可用
    function kick() {
        pool.tick()
    }

    // ── 批量求值 ────────────────────────────────────────────
    // 倒序遍历：订阅者可能在 evaluate 里 remove 自己或别人，正序会跳项。
    function tick() {
        if (pool._subs.length === 0)
            return
        var snapshot = pool._subs.slice()
        var dead = null
        for (var i = snapshot.length - 1; i >= 0; i--) {
            var sub = snapshot[i]
            var alive = true
            try {
                alive = sub && typeof sub.evaluate === "function" ? sub.evaluate() !== false : false
            } catch (err) {
                console.warn("NovaIntersectionPool: 订阅者求值异常 -", err)
                alive = false
            }
            if (!alive) {
                if (!dead)
                    dead = []
                dead.push(sub)
            }
        }
        if (dead) {
            for (var j = 0; j < dead.length; j++)
                pool.remove(dead[j])
        }
    }

    // ── 公共几何工具（行为层复用，避免各处重写） ─────────────
    // 默认视口：窗口 contentItem（与 NovaOverlayHost 同一解析口径）
    function viewport() {
        var s = NovaScreen.source
        if (!s)
            return null
        if (s.contentItem !== undefined)
            return s.contentItem
        return s.window ? s.window.contentItem : null
    }

    // 最近的可滚动祖先（Flickable / ListView / GridView / ScrollView 的内容 item 都有 contentY）
    function nearestScrollable(item) {
        var node = item
        while (node) {
            if (typeof node.contentY === "number" && typeof node.contentHeight === "number")
                return node
            node = node.parent
        }
        return null
    }

    // 滚动位置：可滚动容器取 contentX/Y，其余视为不动
    function scrollPosition(root) {
        if (!root)
            return { x: 0, y: 0 }
        return {
            x: typeof root.contentX === "number" ? root.contentX : 0,
            y: typeof root.contentY === "number" ? root.contentY : 0
        }
    }

    // 矩形交集（无交集返回零面积矩形，不返回 null——调用方少一层判空）
    function intersect(a, b) {
        var x1 = Math.max(a.x, b.x)
        var y1 = Math.max(a.y, b.y)
        var x2 = Math.min(a.x + a.width, b.x + b.width)
        var y2 = Math.min(a.y + a.height, b.y + b.height)
        if (x2 <= x1 || y2 <= y1)
            return { x: x1, y: y1, width: 0, height: 0 }
        return { x: x1, y: y1, width: x2 - x1, height: y2 - y1 }
    }

    // 规范化为 IntersectionObserverEntry 风格的 rect（top/left/right/bottom 齐全）
    function toRect(x, y, width, height) {
        return {
            x: x, y: y, width: width, height: height,
            top: y, left: x, right: x + width, bottom: y + height
        }
    }
}
