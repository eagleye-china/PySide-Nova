// src/pyside_nova/qml/Nova/Services/NovaOverlayHost.qml
// NovaOverlayHost 全局弹层宿主单例：把动态 Item 挂到窗口顶层 overlay 并按层叠令牌分配 z（对标 Quasar createGlobalNode）
// NovaOverlayHost —— 全局弹层宿主单例（L4 服务层共用基础设施）
// 职责边界：只负责"挂载 + 分层"，不管理队列/生命周期；队列类服务（NovaNotify 等）各自持有自己的栈。
// 接入方式：复用断点体系唯一入口，无需额外绑定——宿主自动跟随 NovaScreen.source 定位窗口：
//     source 是 Window      → 挂到 window.contentItem
//     source 是 Item        → 挂到 item.window.contentItem
// 多窗口说明：与 NovaScreen 同一约定，单进程当前仅跟踪一个源窗口。
pragma Singleton
import QtQuick

QtObject {
    id: host

    // ── 层叠令牌（与 NovaTheme 同值镜像；使用处优先读 NovaTheme，本组保留供单例内部自引用） ──
    readonly property int zNotify: NovaTheme.zNotify

    // ── 弹层挂载目标（contentItem 只读派生，勿手写赋值） ──────────
    readonly property var contentItem: {
        var s = NovaScreen.source
        if (!s)
            return null
        if (s.contentItem !== undefined)
            return s.contentItem            // Window / ApplicationWindow
        return s.window ? s.window.contentItem : null   // 任意 Item
    }

    // 将 item 挂载到窗口顶层并分配层叠 z；layer 缺省为 zNotify。
    // 返回 true = 挂载成功；false = 当前无可用窗口（未执行 NovaScreen.source = window）。
    // 注意：不自动铺满——铺满类 overlay（如遮罩）由调用方自行 anchors.fill。
    function attach(item, layer) {
        var ci = host.contentItem
        if (!ci) {
            console.warn("NovaOverlayHost: 无可用窗口，请先在根窗口执行 NovaScreen.source = window")
            return false
        }
        item.parent = ci
        item.z = (layer !== undefined && layer !== null) ? layer : NovaTheme.zNotify
        item.visible = true
        return true
    }

    // ── 弹层栈（Nova 增强，对标 Quasar portal 链 + closePortals） ─────────────
    // 用途：NovaClosePopup 要按"层数"关闭（<0 全关 / 0 禁用 / N 关顶 N 层），需要知道谁在栈里。
    // 约定：可关闭弹层（如 NovaDialog）挂载时 registerPopup(item, closeFn)，关闭/销毁时 unregisterPopup(item)；
    //       closeFn(reason) 负责真正的收口动作（由弹层自己决定怎么关，宿主不越权）。
    property var _popups: []

    function registerPopup(item, closeFn) {
        if (!item) {
            console.warn("NovaOverlayHost: registerPopup 需要有效 item")
            return false
        }
        host.unregisterPopup(item)
        // 不可变更新：var 属性的 in-place push 不触发变更通知
        host._popups = host._popups.concat([{ item: item, close: closeFn }])
        return true
    }

    function unregisterPopup(item) {
        var out = []
        for (var i = 0; i < host._popups.length; i++) {
            if (host._popups[i].item !== item)
                out.push(host._popups[i])
        }
        if (out.length !== host._popups.length)
            host._popups = out
    }

    function popupCount() {
        return host._popups.length
    }

    // 当前弹层（自底向顶的 item 数组，只读快照）
    function popups() {
        var out = []
        for (var i = 0; i < host._popups.length; i++)
            out.push(host._popups[i].item)
        return out
    }

    // 自栈顶向下关闭 depth 层：depth < 0 = 全关；0 = 不动作；>0 = 关 N 层。
    // 返回实际关闭数量（对标 closePortals 的"层"语义）。
    function closePopups(depth, reason) {
        var d = depth === undefined || depth === null ? 1 : depth
        if (d === 0 || host._popups.length === 0)
            return 0

        var n = d < 0 ? host._popups.length : Math.min(d, host._popups.length)
        var closed = 0
        for (var i = 0; i < n; i++) {
            var top = host._popups[host._popups.length - 1]
            if (!top)
                break
            host._popups = host._popups.slice(0, host._popups.length - 1)
            try {
                if (typeof top.close === "function")
                    top.close(reason === undefined ? "api" : reason)
            } catch (err) {
                console.warn("NovaOverlayHost: 弹层关闭回调异常 -", err)
            }
            closed++
        }
        return closed
    }

    // 栈顶弹层（无则 null）
    function topPopup() {
        return host._popups.length > 0 ? host._popups[host._popups.length - 1].item : null
    }
}
