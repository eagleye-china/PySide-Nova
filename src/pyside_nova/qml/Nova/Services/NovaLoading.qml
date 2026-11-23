// src/pyside_nova/qml/Nova/Services/NovaLoading.qml
// NovaLoading 全局加载服务单例：引用计数并发、delay 防闪烁、局部/全屏、超时保护、三种 spinner（对标 Loading 插件）
// NovaLoading —— 命令式加载遮罩（对标 Quasar Loading 插件；契约见 docs/PARITY.md NovaLoading 审计节）
// 基线事实（npm quasar@2.35.5 dist/api/Loading.json 逐项核实）：
//     11 项配置：delay / message / group / html / boxClass / spinnerSize / spinnerColor /
//                messageColor / backgroundColor / spinner / customClass；
//     默认 group = '__default_quasar_group__'；hide() 按组立即关闭。
// QML 裁定：
//     html ⛔（XSS 面，QML 用 Text 的富文本能力由 messageFormat 承载，属 Nova 增强）；
//     boxClass / customClass ⛔（无 CSS 类体系）→ 布尔 boxed 映射；
//     spinner（QSpinner 组件）→ spinnerModel 字符串，四期 NovaSpinner 就绪后开放组件注入。
// Nova 增强（PARITY 标"增强"）：
//     · 引用计数：同组多次 show 不互踩，句柄 hide() 只释放自己那一份；
//     · target：把加载层挂到任意 Item 内（局部加载），缺省全屏走 NovaOverlayHost zTop；
//     · timeout：卡死兜底；increment/decrement/count/activeGroups/hideAll 内省面。
// a11y: decorative —— QtObject 单例（非视觉节点），语义经 NovaA11y.notice 播报
pragma Singleton
import QtQuick
import Nova.Services

QtObject {
    id: api

    // ── 契约常量 ──────────────────────────────────────────────
    readonly property string defaultGroup: "__default_quasar_group__"
    readonly property var spinnerModels: ["ring", "dots", "pulse"]
    readonly property int zLayer: NovaTheme.zTop

    // ── 运行时状态 ────────────────────────────────────────────
    property var _defaults: ({})
    property var _entries: []          // 活动组：[{ group, count, item, dead }]

    // ── 默认值（对标 $q.loading.setDefaults） ──────────────────
    function setDefaults(opts) {
        if (!opts || typeof opts !== "object") {
            console.warn("NovaLoading: setDefaults 需要对象参数")
            return
        }
        api._merge(api._defaults, opts)
    }

    function _merge(target, src) {
        for (var key in src) {
            var val = src[key]
            if (val && typeof val === "object" && !Array.isArray(val) && key !== "target") {
                if (!target[key] || typeof target[key] !== "object")
                    target[key] = {}
                api._merge(target[key], val)
            } else {
                target[key] = val
            }
        }
    }

    function _find(group) {
        for (var i = 0; i < api._entries.length; i++) {
            var e = api._entries[i]
            if (!e.dead && e.group === group)
                return e
        }
        return null
    }

    // ── 创建（对标 $q.loading.show(opts)） ────────────────────
    function show(opts) {
        var cfg = {}
        api._merge(cfg, api._defaults)
        if (opts !== undefined && opts !== null) {
            if (typeof opts !== "object") {
                console.warn("NovaLoading: show(opts) 需要对象参数")
                return null
            }
            api._merge(cfg, opts)
        }

        var group = (cfg.group === undefined || cfg.group === null || String(cfg.group) === "")
                ? api.defaultGroup : String(cfg.group)

        var entry = api._find(group)
        if (entry) {                       // 同组并发：计数 +1，复用同一视觉层
            entry.count += 1
            api._apply(entry, cfg)
            return api._makeHandle(entry)
        }

        var item = api.overlayComp.createObject(null)
        if (!item) {
            console.warn("NovaLoading: 加载层创建失败")
            return null
        }

        entry = api.entryComp.createObject(api)
        entry.group = group
        entry.count = 1
        entry.item = item
        entry.dead = false

        // 先落配置（delay 决定是否延时显示），再挂载——挂载会触发 visible 逻辑
        api._apply(entry, cfg)

        var target = cfg.target
        if (target && target.children !== undefined) {
            item.mountOn(target)
        } else if (!NovaOverlayHost.attach(item, api.zLayer)) {
            item.destroy()
            return null
        } else {
            item.anchors.fill = item.parent
        }

        api._entries.push(entry)
        item.closed.connect(function() { api._drop(entry) })
        return api._makeHandle(entry)
    }

    // 配置落地（show 与 update 共用；白名单只改传入项）
    function _apply(entry, cfg) {
        if (!entry || !entry.item)
            return false
        var it = entry.item

        if (cfg.message !== undefined)
            it.message = cfg.message === null ? "" : String(cfg.message)
        if (cfg.spinnerSize !== undefined)
            it.spinnerSize = Math.max(12, Number(cfg.spinnerSize))
        if (cfg.spinnerModel !== undefined) {
            if (api.spinnerModels.indexOf(cfg.spinnerModel) === -1)
                console.warn("NovaLoading: 未知 spinnerModel", cfg.spinnerModel, "→ 回落 ring")
            it.spinnerModel = api.spinnerModels.indexOf(cfg.spinnerModel) === -1 ? "ring" : cfg.spinnerModel
        }
        if (cfg.spinnerTint !== undefined)
            it.spinnerTint = cfg.spinnerTint
        if (cfg.messageTint !== undefined)
            it.messageTint = cfg.messageTint
        if (cfg.backgroundTint !== undefined)
            it.backgroundTint = cfg.backgroundTint
        if (cfg.seamless !== undefined)
            it.seamless = cfg.seamless === true
        if (cfg.boxed !== undefined)
            it.boxed = cfg.boxed === true
        if (cfg.delay !== undefined && entry.count === 1)
            it.delay = Math.max(0, Number(cfg.delay))
        if (cfg.timeout !== undefined)
            it.timeout = Math.max(0, Number(cfg.timeout))
        if (cfg.silent === true)
            it.seamless = true

        it.refCount = entry.count

        // 创建时 overlay 的 onCompleted 已按默认 delay(500) 判断过，此处配置落地后重新裁定：
        // delay<=0 立即显形；delay>0 交给 overlay 内的 delayTimer（其 running 绑定已随 delay 更新）。
        if (it.delay <= 0 && !it.started && !it._closed)
            it.appear()
        return true
    }

    // ── 释放（句柄 hide 的唯一出口：计数 -1，归零才收口） ──────
    function _release(entry) {
        if (!entry || entry.dead)
            return false
        entry.count -= 1
        if (entry.count > 0) {
            if (entry.item)
                entry.item.refCount = entry.count
            return true
        }
        entry.dead = true
        var idx = api._entries.indexOf(entry)
        if (idx !== -1)
            api._entries.splice(idx, 1)
        if (entry.item)
            entry.item.close()
        return true
    }

    // overlay 关闭回调：清引用，防悬挂
    function _drop(entry) {
        if (!entry)
            return
        entry.dead = true
        entry.item = null
        var idx = api._entries.indexOf(entry)
        if (idx !== -1)
            api._entries.splice(idx, 1)
    }

    // ── 强制关闭（对标 $q.loading.hide：按组立即收口，无视计数） ──
    function hide(group) {
        var g = (group === undefined || group === null) ? api.defaultGroup : String(group)
        var entry = api._find(g)
        if (!entry)
            return false
        entry.count = 0
        entry.dead = true
        var idx = api._entries.indexOf(entry)
        if (idx !== -1)
            api._entries.splice(idx, 1)
        if (entry.item)
            entry.item.close()
        return true
    }

    function hideAll() {
        var list = api._entries.slice(0)
        for (var i = 0; i < list.length; i++) {
            list[i].count = 0
            list[i].dead = true
            if (list[i].item)
                list[i].item.close()
        }
        api._entries = []
    }

    // ── 便捷：引用计数加减 ───────────────────────────────────
    function increment(opts) {
        return api.show(opts)
    }

    function decrement(group) {
        var g = (group === undefined || group === null) ? api.defaultGroup : String(group)
        var entry = api._find(g)
        if (!entry)
            return false
        return api._release(entry)
    }

    // ── 内省（Nova 增强） ────────────────────────────────────
    function isActive(group) {
        var g = (group === undefined || group === null) ? api.defaultGroup : String(group)
        return api._find(g) !== null
    }

    function count(group) {
        var g = (group === undefined || group === null) ? api.defaultGroup : String(group)
        var entry = api._find(g)
        return entry ? entry.count : 0
    }

    function activeGroups() {
        var out = []
        for (var i = 0; i < api._entries.length; i++) {
            if (!api._entries[i].dead)
                out.push(api._entries[i].group)
        }
        return out
    }

    function activeCount() {
        return api._entries.length
    }

    // Qt 6.12 坑位：QtObject 体内不可直接声明可视子项，必须走 property Component 内联
    property Component overlayComp: Component {
        NovaLoadingOverlay { }
    }

    property Component handleComp: Component {
        NovaLoadingHandle { }
    }

    // 活动组条目：必须是 QML 对象而非裸 JS 对象——handle.valid/count/item 依赖属性通知，
    // 裸对象的属性改动不会触发绑定重算（0.6.2 实测坑位）。parent=api 保活，单例生命周期内常驻。
    property Component entryComp: Component {
        QtObject {
            property string group: ""
            property int count: 1
            property var item: null
            property bool dead: false
        }
    }

    function _makeHandle(entry) {
        var h = api.handleComp.createObject(api)
        h.entry = entry
        return h
    }
}
