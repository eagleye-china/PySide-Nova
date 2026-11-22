// src/pyside_nova/qml/Nova/Services/NovaNotify.qml
// NovaNotify 全局通知服务单例：29 项配置对账、9 位位置栈、分组徽标、句柄更新、关闭原因上报（对标 Notify 插件）
// NovaNotify —— 全局通知服务单例（对标 Quasar Notify 插件；契约裁定见 docs/PARITY.md / 宪法 0.5.1 记录）
// 基线事实（npm quasar@2.35.5 源码核实，勿按文档页凭记忆改）：
//     默认 position=bottom / timeout=5000 / textColor=white；timeout=0 常驻且 progress 强制关；
//     分组键 = message|caption|multiLine|label*icon… 再拼 |position；分组通知只能 dismiss 不能 update；
//     计时器与进度条时长 = timeout + 1000（1000 为入场动效，基线 transition 1s）；
//     基线 onDismiss() 无参数（"关闭原因上报"属 Dialog/BottomSheet）——Nova 的 dismissed(reason) 是增强。
pragma Singleton
import QtQuick

QtObject {
    id: api

    // ── 基线常量 ───────────────────────────────────────────────
    readonly property var positionList: ["top-left", "top-right", "bottom-left", "bottom-right",
                                         "top", "bottom", "left", "right", "center"]
    readonly property int enterMs: 1000          // 进出场动效时长 = 基线 transition 1s；计时器/进度条共用本常量
    readonly property int defaultTimeout: 5000   // 基线默认显示时长
    property int maxVisible: 5                   // 同屏上限（MASTER_PLAN Sprint 2 验收，Nova 增强）

    // 关闭原因枚举（dismissed 信号；基线无此概念，Nova 增强，PARITY 标"增强"栏）
    //     timeout / user / action / api / replaced / overflow
    readonly property var dismissReasons: ["timeout", "user", "action", "api", "replaced", "overflow"]

    // ── 默认值与类型注册表 ─────────────────────────────────────
    property var _defaults: ({})
    property var _registeredTypes: ({})
    property var _stacks: ({})                   // position → Item 数组
    property var _groups: ({})                   // 运行时分组键 → Item
    property var _conn: null                     // 窗口尺寸监听

    function setDefaults(opts) {
        if (opts && typeof opts === "object")
            api._defaults = opts
    }

    function registerType(typeName, typeOpts) {
        if (typeName && typeOpts && typeof typeOpts === "object")
            api._registeredTypes[typeName] = typeOpts
    }

    // 内置类型预设（对标 notifTypes；色板取 NovaTheme 令牌，grey-8 → dark 令牌）
    function _typePreset(name) {
        switch (name) {
        case "positive": return { icon: "mdi:check-circle", tint: NovaTheme.positive }
        case "negative": return { icon: "mdi:close-circle", tint: NovaTheme.negative }
        case "warning":  return { icon: "mdi:alert", tint: NovaTheme.warning, textTint: NovaTheme.dark }
        case "info":     return { icon: "mdi:information-outline", tint: NovaTheme.info }
        case "ongoing":  return { group: false, timeout: 0, spinner: true, tint: NovaTheme.dark }
        }
        var reg = api._registeredTypes[name]
        return reg ? reg : {}
    }

    // ── 兜底默认（生效顺序：内置 → setDefaults → 本次 config） ──
    function _baseConfig() {
        return {
            type: "", message: "", caption: "",
            tint: NovaTheme.dark, textTint: NovaTheme.textOnPrimary,
            icon: "", iconTint: "transparent", iconSize: 24, avatar: "",
            spinner: false, spinnerDelegate: null, spinnerTint: "transparent", spinnerSize: 32,
            position: "bottom", group: true,
            badgeTint: NovaTheme.negative, badgeTextTint: "#FFFFFF", badgePosition: "",
            progress: false, progressTint: Qt.rgba(1, 1, 1, 0.7),
            timeout: 5000, actions: [], closeBtn: false, multiLine: undefined,
            contentDelegate: null
        }
    }

    function _merge(target, src) {
        if (!src)
            return
        for (var k in src)
            target[k] = src[k]
    }

    function _stackFor(position) {
        if (!api._stacks[position])
            api._stacks[position] = []
        return api._stacks[position]
    }

    // ── 动作归一化：QtObject（声明式，含 triggered 信号）原样收编；JS 字面量转为 NovaNotifyAction ──
    function _normalizeAction(a) {
        if (a && Qt.isQtObject(a))
            return a
        var o = actionComp.createObject(null)
        a = a || {}
        o.label = a.label !== undefined ? String(a.label) : ""
        o.icon = a.icon !== undefined ? String(a.icon) : ""
        if (a.tint !== undefined) o.tint = a.tint
        if (a.textTint !== undefined) o.textTint = a.textTint
        o.noDismiss = a.noDismiss === true
        o.handler = (a.handler && typeof a.handler === "function") ? a.handler : null
        o.closeReason = a.closeReason === "user" ? "user" : "action"
        return o
    }

    // ── 主入口：show(config)（对标 Notify.create） ───────────────
    function show(config) {
        if (config === undefined || config === null) {
            console.warn("NovaNotify: 参数必填")
            return null
        }
        if (typeof config !== "object")
            config = { message: String(config) }

        var notif = api._baseConfig()
        api._merge(notif, api._defaults)
        var tname = config.type !== undefined ? config.type : notif.type
        if (tname)
            api._merge(notif, api._typePreset(tname))
        api._merge(notif, config)

        // 位置校验：基线拼错会静默回落 bottom，QML 语境直接拒绝更诚实
        if (api.positionList.indexOf(notif.position) === -1) {
            console.warn("NovaNotify: wrong position", notif.position)
            return null
        }

        // 超时归一（基线：undefined/null/true/false/''/负数 → 5000）
        if (notif.timeout === undefined || notif.timeout === null ||
                notif.timeout === true || notif.timeout === false || notif.timeout === "" ||
                notif.timeout < 0)
            notif.timeout = api.defaultTimeout
        if (notif.timeout === 0)
            notif.progress = false

        // 动作定稿（config.actions + defaults.actions + 类型预设 actions，再补 closeBtn；不重复并入 defaults）
        var actions = []
        var rawActions = (config.actions !== undefined ? config.actions : []) || []
        for (var i = 0; i < rawActions.length; i++)
            actions.push(api._normalizeAction(rawActions[i]))
        if (api._defaults.actions)
            for (var j = 0; j < api._defaults.actions.length; j++)
                actions.push(api._normalizeAction(api._defaults.actions[j]))
        var preset = tname ? api._typePreset(tname) : {}
        if (preset.actions)
            for (var k = 0; k < preset.actions.length; k++)
                actions.push(api._normalizeAction(preset.actions[k]))
        if (notif.closeBtn)
            actions.push(api._normalizeAction({
                label: typeof notif.closeBtn === "string" ? notif.closeBtn : "关闭",
                closeReason: "user"
            }))

        // multiLine 兜底：未指定时 = 动作数 > 1（必须在 actions 定稿后计算，分组键依赖它）
        if (notif.multiLine === undefined)
            notif.multiLine = actions.length > 1

        // 分组键（契约 4.1：message|caption|multiLine|label*icon…，再拼 |position）
        var groupKeyFinal = null
        if (notif.group !== false && notif.group !== null) {
            if (notif.group === true || notif.group === undefined) {
                var parts = [notif.message, notif.caption, notif.multiLine]
                for (var m = 0; m < actions.length; m++)
                    parts.push((actions[m].label || "") + "*" + (actions[m].icon || ""))
                groupKeyFinal = parts.join("|")
            } else {
                groupKeyFinal = String(notif.group)
            }
        }
        var runtimeKey = groupKeyFinal === null ? null : groupKeyFinal + "|" + notif.position

        // 徽标位置兜底：position 含 left → top-right，否则 top-left
        if (!notif.badgePosition)
            notif.badgePosition = notif.position.indexOf("left") !== -1 ? "top-right" : "top-left"

        // 入场滑移方向
        var dirX = 0, dirY = 0
        if (notif.position.indexOf("top") !== -1) dirY = -1
        else if (notif.position.indexOf("bottom") !== -1) dirY = 1
        if (notif.position.indexOf("left") !== -1) dirX = -1
        else if (notif.position.indexOf("right") !== -1) dirX = 1

        var existing = runtimeKey !== null ? api._groups[runtimeKey] : undefined
        var stack = api._stackFor(notif.position)

        var props = {
            message: notif.message, caption: notif.caption, contentDelegate: notif.contentDelegate,
            tint: notif.tint, textTint: notif.textTint,
            icon: notif.icon, iconTint: notif.iconTint, iconSize: notif.iconSize, avatar: notif.avatar,
            spinner: notif.spinner, spinnerDelegate: notif.spinnerDelegate,
            spinnerTint: notif.spinnerTint, spinnerSize: notif.spinnerSize,
            badgeTint: notif.badgeTint, badgeTextTint: notif.badgeTextTint, badgePosition: notif.badgePosition,
            progress: notif.progress, progressTint: notif.progressTint, timeout: notif.timeout,
            actions: actions, multiLine: notif.multiLine,
            position: notif.position, groupKey: runtimeKey,
            dirX: dirX, dirY: dirY,
            quiet: existing !== undefined   // 同组替换：静默换装，无入场动效
        }

        var item = itemComp.createObject(null, props)
        if (!item) {
            console.warn("NovaNotify: 通知卡片创建失败")
            return null
        }

        // 分组替换：旧条目上报 replaced（无动效）、徽标 +1、保留位置、重置计时
        if (existing !== undefined) {
            var idx = stack.indexOf(existing)
            api.dismiss(existing, "replaced", false)
            item.badge = existing.badge + 1
            stack.splice(idx === -1 ? stack.length : idx, 0, item)
            api._groups[runtimeKey] = item
        } else {
            if (runtimeKey !== null)
                api._groups[runtimeKey] = item
            if (notif.position.indexOf("top") !== -1)
                stack.unshift(item)
            else if (notif.position.indexOf("bottom") !== -1)
                stack.push(item)
            else
                stack.splice(Math.floor(stack.length / 2), 0, item)   // left/right/center 中线插入
        }

        if (!NovaOverlayHost.attach(item))
            return null

        api.relayout(notif.position)
        api._watchWindow()

        // 同屏上限（Nova 增强）：超限淘汰最旧一条，原因 overflow
        while (stack.length > api.maxVisible) {
            var oldestIdx = notif.position.indexOf("top") !== -1 ? stack.length - 1 : 0
            api.dismiss(stack[oldestIdx], "overflow")
        }

        item.timedOut.connect(function() { api.dismiss(item, "timeout") })

        var handle = handleComp.createObject(null, { item: item })
        item._handle = handle
        return handle
    }

    // ── 关闭（唯一出口；reason 为 dismissed 信号载荷） ───────────
    function dismiss(item, reason, animate) {
        if (!item || item._dead)
            return
        item._dead = true
        if (item._handle)
            item._handle.item = null
        if (item.groupKey !== null && api._groups[item.groupKey] === item)
            delete api._groups[item.groupKey]
        var stack = api._stackFor(item.position)
        var idx = stack.indexOf(item)
        if (idx !== -1)
            stack.splice(idx, 1)
        item.dismissed(reason === undefined ? "api" : reason)
        if (animate === false) {
            api.relayout(item.position)
            item.destroy()
        } else {
            api.relayout(item.position)
            item.playExit()
        }
    }

    // ── 更新（仅限非分组；合并语义对标基线：group 强制 false、position 不变、重置计时） ──
    function update(item, props) {
        if (!item || item._dead)
            return false
        if (item.groupKey !== null)
            return false                          // 分组通知禁止更新（基线语义）
        if (!props || typeof props !== "object")
            return false
        var whitelist = ["message", "caption", "contentDelegate", "tint", "textTint", "icon",
                         "iconTint", "iconSize", "avatar", "spinner", "spinnerDelegate",
                         "spinnerTint", "spinnerSize", "progress", "progressTint",
                         "timeout", "multiLine"]
        for (var i = 0; i < whitelist.length; i++) {
            var key = whitelist[i]
            if (props[key] !== undefined)
                item[key] = props[key]
        }
        if (props.badgeTint !== undefined) item.badgeTint = props.badgeTint
        if (props.actions !== undefined) {
            var actions = []
            for (var a = 0; a < props.actions.length; a++)
                actions.push(api._normalizeAction(props.actions[a]))
            item.actions = actions
        }
        if (props.timeout !== undefined && item.timeout === 0)
            item.progress = false                 // timeout=0 → progress 强制关
        api.relayout(item.position)
        item.resetTimer()
        return true
    }

    // ── 内省（Nova 增强：测试/自动化/调试面） ────────────────────
    function countAt(position) {
        var s = api._stacks[position]
        return s ? s.length : 0
    }

    function totalCount() {
        var total = 0
        for (var i = 0; i < api.positionList.length; i++)
            total += api.countAt(api.positionList[i])
        return total
    }

    function dismissAll(position) {
        var stack = api._stacks[position]
        if (!stack)
            return
        while (stack.length > 0)
            api.dismiss(stack[stack.length - 1], "api")
    }

    // ── 布局：宽度约束 + 逐位排布（契约 4.2：top 头插 / bottom 尾插 / 侧向中线） ──
    // 尺寸取 NovaScreen（源窗口语义），不取 contentItem：窗口未显示时 contentItem 几何为 0
    function relayout(position) {
        var stack = api._stacks[position]
        if (!stack || stack.length === 0)
            return
        if (!NovaOverlayHost.contentItem)
            return
        var W = NovaScreen.width, H = NovaScreen.height
        var maxW = W >= 1024 ? W * 0.65 : W * 0.95    // 基线 max-width: 95vw / 65vw@sm
        var margin = 10, gap = 10

        var total = 0
        for (var i = 0; i < stack.length; i++) {
            var it = stack[i]
            it.maxWidth = maxW
            it.width = Math.min(it.implicitWidth, maxW)
            it.height = it.implicitHeight
            total += it.height + gap
        }
        total -= gap

        var isTop = position.indexOf("top") !== -1
        var isBottom = position.indexOf("bottom") !== -1
        var y
        if (isTop)
            y = margin
        else if (isBottom)
            y = H - margin - total
        else
            y = Math.max(margin, (H - total) / 2)

        for (var j = 0; j < stack.length; j++) {
            var n = stack[j]
            n.y = y
            y += n.height + gap
            if (position.indexOf("left") !== -1)
                n.x = margin
            else if (position.indexOf("right") !== -1)
                n.x = W - margin - n.width
            else
                n.x = (W - n.width) / 2
        }
    }

    function relayoutAll() {
        for (var i = 0; i < api.positionList.length; i++)
            api.relayout(api.positionList[i])
    }

    // 窗口尺寸变化 → 全量重排（单监听，target 变更时重建）
    function _watchWindow() {
        var ci = NovaOverlayHost.contentItem
        if (api._conn && api._conn.target === ci)
            return
        if (api._conn) {
            api._conn.destroy()
            api._conn = null
        }
        if (!ci)
            return
        api._conn = connComp.createObject(null, { target: ci })
    }

    // Qt 6.12 坑位：QtObject（单例）体内不可直接声明 Component 子项，必须走 property Component 内联
    property Component connComp: Component {
        Connections {
            function onWidthChanged() { NovaNotify.relayoutAll() }
            function onHeightChanged() { NovaNotify.relayoutAll() }
        }
    }

    property Component itemComp: Component {
        NovaNotificationItem { }
    }

    property Component actionComp: Component {
        NovaNotifyAction { }
    }

    property Component handleComp: Component {
        NovaNotifyHandle { }
    }
}
