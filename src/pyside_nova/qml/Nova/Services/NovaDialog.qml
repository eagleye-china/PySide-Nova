// src/pyside_nova/qml/Nova/Services/NovaDialog.qml
// NovaDialog 全局对话框服务单例：27 项配置对账、五向定位、双按钮契约、关闭原因上报、句柄更新（对标 Dialog 插件）
// NovaDialog —— 命令式对话框（对标 Quasar Dialog 插件；契约见 docs/PARITY.md NovaDialog 审计节）
// 基线事实（npm quasar@2.35.5 dist/api/Dialog.json 核实，勿按文档页凭记忆改）：
//     27 项配置：class/style/html/component 等 DOM 专属项⛔不移植；prompt/options 待二期表单组件就绪；
//     默认 OK/Cancel 双按钮、focus=ok、transition scale、position standard；
//     关闭原因 ok / cancel / backdrop / escape / api 属基线 2.28 真 parity（与 Notify 不同）。
// 宿主：所有对话框挂到 NovaOverlayHost（zTop 层），与 NovaNotify（zNotify）互不打架。
pragma Singleton
import QtQuick
import Nova.Services

QtObject {
    id: api

    // ── 契约常量 ──────────────────────────────────────────────
    readonly property var positionList: ["standard", "top", "right", "bottom", "left"]
    readonly property var dismissReasons: ["ok", "cancel", "backdrop", "escape", "api"]
    readonly property int zLayer: NovaTheme.zTop

    // ── 运行时状态 ────────────────────────────────────────────
    property var _defaults: ({})      // setDefaults 合并源
    property var _dialogs: []         // 活动对话框（按创建顺序，支持多层堆叠）

    // ── 默认值（对标基线 dialogDefaults：深合并，数组整体替换） ──
    function setDefaults(opts) {
        if (!opts || typeof opts !== "object") {
            console.warn("NovaDialog: setDefaults 需要对象参数")
            return
        }
        api._merge(api._defaults, opts)
    }

    function _merge(target, src) {
        for (var key in src) {
            var val = src[key]
            if (val && typeof val === "object" && !Array.isArray(val) && key !== "contentDelegate") {
                if (!target[key] || typeof target[key] !== "object")
                    target[key] = {}
                api._merge(target[key], val)
            } else {
                target[key] = val
            }
        }
    }

    // ── 按钮归一：true/false/字符串/对象 四态（对标基线 ok/cancel 三态 + QBtn props） ──
    function normalizeButton(input, defLabel) {
        if (input === false)
            return { visible: false, label: defLabel, variant: "flat", tint: NovaTheme.primary }
        if (input === undefined || input === null || input === true)
            return { visible: true, label: defLabel, variant: "flat", tint: NovaTheme.primary }
        if (typeof input === "string")
            return { visible: true, label: input, variant: "flat", tint: NovaTheme.primary }
        return {
            visible: input.visible !== false,
            label: input.label !== undefined ? String(input.label) : defLabel,
            variant: input.flat === true ? "flat" : (input.variant || "flat"),
            tint: input.tint !== undefined ? input.tint : NovaTheme.primary
        }
    }

    // ── 创建（对标 $q.dialog(opts) → 链式句柄） ────────────────
    function show(opts) {
        if (!opts || typeof opts !== "object") {
            console.warn("NovaDialog: show(opts) 需要对象参数")
            return null
        }

        var cfg = {}
        api._merge(cfg, api._defaults)
        api._merge(cfg, opts)

        var pos = cfg.position === undefined || cfg.position === null ? "standard" : cfg.position
        if (api.positionList.indexOf(pos) === -1) {
            console.warn("NovaDialog: wrong position", pos)
            return null
        }

        var item = api.dialogComp.createObject(null)
        if (!item) {
            console.warn("NovaDialog: 对话框卡片创建失败")
            return null
        }

        item.position = pos
        item.title = cfg.title !== undefined && cfg.title !== null ? String(cfg.title) : ""
        item.message = cfg.message !== undefined && cfg.message !== null ? String(cfg.message) : ""
        item.contentDelegate = cfg.contentDelegate !== undefined ? cfg.contentDelegate : null
        item.persistent = cfg.persistent === true
        item.noEscDismiss = cfg.noEscDismiss === true
        item.noBackdropDismiss = cfg.noBackdropDismiss === true
        item.seamless = cfg.seamless === true
        item.maximized = cfg.maximized === true
        item.fullWidth = cfg.fullWidth === true
        item.fullHeight = cfg.fullHeight === true
        item.progress = cfg.progress !== undefined && cfg.progress !== false && cfg.progress !== null
        item.progressMessage = (cfg.progress && typeof cfg.progress === "object" && cfg.progress.message !== undefined)
                ? String(cfg.progress.message) : ""
        item.okConfig = api.normalizeButton(cfg.ok, "OK")
        item.cancelConfig = api.normalizeButton(cfg.cancel, "Cancel")
        item.focusTarget = cfg.focus !== undefined ? cfg.focus : "ok"
        item.stackButtons = cfg.stackButtons === true
        item.transitionShow = cfg.transitionShow !== undefined ? cfg.transitionShow : "scale"
        item.transitionHide = cfg.transitionHide !== undefined ? cfg.transitionHide : "scale"
        item.cardTint = cfg.tint !== undefined ? cfg.tint : NovaTheme.surface
        item.okCallback = typeof cfg.onOk === "function" ? cfg.onOk : null
        item.cancelCallback = typeof cfg.onCancel === "function" ? cfg.onCancel : null
        item.dismissCallback = typeof cfg.onDismiss === "function" ? cfg.onDismiss : null

        if (!NovaOverlayHost.attach(item, api.zLayer)) {
            item.destroy()
            return null
        }
        item.anchors.fill = item.parent

        var h = api.handleComp.createObject(api)
        h.item = item
        item._handle = h
        item.accepted.connect(h.accepted)
        item.cancelled.connect(h.rejected)
        item.dismissed.connect(h.dismissed)

        api._dialogs.push(item)
        item.forceActiveFocus()
        return h
    }

    // ── 内省（Nova 增强：测试/自动化/调试面） ────────────────────
    function count() {
        var n = 0
        for (var i = 0; i < api._dialogs.length; i++) {
            if (!api._dialogs[i]._closed)
                n++
        }
        return n
    }

    function activeDialogs() {
        var out = []
        for (var i = 0; i < api._dialogs.length; i++) {
            if (!api._dialogs[i]._closed)
                out.push(api._dialogs[i])
        }
        return out
    }

    // ── 批量关闭（reason 默认 api） ────────────────────────────
    function hideAll(reason) {
        var list = api.activeDialogs()
        for (var i = 0; i < list.length; i++)
            list[i].requestDismiss(reason === undefined ? "api" : reason)
    }

    // 卡片销毁回调（NovaDialogCard.Component.onDestruction 调用），防止列表悬挂
    function _forget(item) {
        var idx = api._dialogs.indexOf(item)
        if (idx !== -1)
            api._dialogs.splice(idx, 1)
    }

    // Qt 6.12 坑位：QtObject（单例）体内不可直接声明 Component 子项，必须走 property Component 内联
    property Component dialogComp: Component {
        NovaDialogCard { }
    }

    property Component handleComp: Component {
        NovaDialogHandle { }
    }
}
