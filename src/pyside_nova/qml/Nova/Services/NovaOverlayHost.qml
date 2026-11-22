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
}
