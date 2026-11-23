// src/pyside_nova/qml/Nova/Design/NovaIconSet.qml
// NovaIconSet 图标集单例（对标 Quasar $q.iconSet + IconSet 插件）：14 套内置图标集全键 1:1、provider 注册表、图标名归一化解析器
// NovaIconSet —— 图标集与图标资源 provider 注册表（L0 设计语言）
// 1:1 对标：$q.iconSet（name/type/arrow/chevron/… 100 个语义键）、$q.iconSet.set(obj)（顶层浅合并 + set 函数自挂载）
// Nova 增强：provider 注册表（svg/ligature 两通道 + 自定义模板或函数）、resolve() 归一化解析器（对标 QIcon.parseIcon）
//            支持 mdi-home / mdi:home / fas fa-home / o_home / sym_r_home / img: / SVG path 等写法
// 实测（2026-11-22）：mdi / material / material-symbols / ionicons v7 / eva / fontawesome v6 / bootstrap / line-awesome
//            均有逐图标 SVG CDN；themify 只有 woff 无逐图标 SVG（留痕，需自备本地图标包）
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma Singleton
import QtQuick
import "IconSets.js" as IconSets

QtObject {
    id: root

    // ── 当前图标集 ────────────────────────────────────────────
    // name 对标 $q.iconSet.name；切换请用 use(name) / set(obj)，不要直接改 name
    readonly property string name: _name
    property string _name: "material-icons"

    // 当前图标集数据（整对象替换以触发通知）
    property var _data: IconSets.get("material-icons")

    // 自定义图标集注册表：name -> iconSet 对象
    property var _custom: ({})
    // 版本号：provider/图标集变更时自增，供绑定刷新（JS 对象属性变更无通知）
    property int _rev: 0

    // ── 语义键访问（1:1 对标 $q.iconSet.*，19 组 101 键）──────
    readonly property var type: { root._rev; return root._data.type }
    readonly property var arrow: { root._rev; return root._data.arrow }
    readonly property var chevron: { root._rev; return root._data.chevron }
    readonly property var colorPicker: { root._rev; return root._data.colorPicker }
    readonly property var pullToRefresh: { root._rev; return root._data.pullToRefresh }
    readonly property var carousel: { root._rev; return root._data.carousel }
    readonly property var chip: { root._rev; return root._data.chip }
    readonly property var datetime: { root._rev; return root._data.datetime }
    readonly property var editor: { root._rev; return root._data.editor }
    readonly property var expansionItem: { root._rev; return root._data.expansionItem }
    readonly property var fab: { root._rev; return root._data.fab }
    readonly property var field: { root._rev; return root._data.field }
    readonly property var pagination: { root._rev; return root._data.pagination }
    readonly property var rating: { root._rev; return root._data.rating }
    readonly property var stepper: { root._rev; return root._data.stepper }
    readonly property var tabs: { root._rev; return root._data.tabs }
    readonly property var table: { root._rev; return root._data.table }
    readonly property var tree: { root._rev; return root._data.tree }
    readonly property var uploader: { root._rev; return root._data.uploader }

    // 已注册图标集名（内置 14 套 + 运行时注册）
    readonly property var available: {
        root._rev
        return IconSets.names().concat(Object.keys(root._custom))
    }

    // 语义键全集（101 条点号路径，自检/文档用）
    readonly property var keyPaths: IconSets.paths()

    // ── 图标集操作 ────────────────────────────────────────────
    // 切换到内置或已注册的图标集
    function use(setName) {
        var d = root._custom[setName] !== undefined
                ? root._custom[setName] : IconSets.get(setName)
        if (d === null || d === undefined) {
            console.warn("NovaIconSet: 未注册的图标集 " + setName)
            return false
        }
        root._name = setName
        root._data = d
        root._rev++
        return true
    }

    // 1:1 对标 $q.iconSet.set(obj)：浅合并，未给出的键保留旧值（Quasar 语义）
    function set(iconSetObject) {
        if (!iconSetObject)
            return
        var next = Object.assign({}, root._data, iconSetObject)
        if (iconSetObject.name !== undefined)
            root._name = iconSetObject.name
        root._data = next
        root._rev++
    }

    // 注册整份自定义图标集（以 mdi-v7 全键为底，未给出的键自动补默认值）
    function register(setName, definition) {
        if (!setName || !definition)
            return false
        var base = Object.assign({}, IconSets.get("mdi-v7"))
        var merged = Object.assign(base, definition)
        merged.name = setName
        var next = Object.assign({}, root._custom)
        next[setName] = merged
        root._custom = next
        root._rev++
        return true
    }

    function unregister(setName) {
        if (root._custom[setName] === undefined)
            return false
        var next = Object.assign({}, root._custom)
        delete next[setName]
        root._custom = next
        if (root._name === setName)
            root.use("material-icons")
        root._rev++
        return true
    }

    // 按点号路径取值：get("type.positive") → "check"
    function get(path, fallback) {
        root._rev
        if (path === undefined || path === null || path === "")
            return fallback
        var parts = String(path).split(".")
        var cur = root._data
        for (var i = 0; i < parts.length; ++i) {
            if (cur === null || cur === undefined || cur[parts[i]] === undefined)
                return fallback
            cur = cur[parts[i]]
        }
        return cur
    }

    // ── provider 注册表（图标资源的渲染来源）──────────────────
    // spec: { kind: "svg" | "ligature", url: "模板含 %1" 或 function(name), colorize: bool,
    //         family: 字体族（ligature）, src: 字体文件 url（ligature）, ligature: bool }
    property var _providers: ({
        // MDI 系列（实心）
        "mdi": {
            kind: "svg", colorize: true,
            url: "https://cdn.jsdelivr.net/npm/@mdi/svg@7.4.47/svg/%1.svg"
        },
        // Material Icons / Symbols（同一套命名，按字形风格分 provider）
        "material": {
            kind: "svg", colorize: true,
            url: "https://cdn.jsdelivr.net/npm/@material-design-icons/svg/filled/%1.svg"
        },
        "material-outlined": {
            kind: "svg", colorize: true,
            url: "https://cdn.jsdelivr.net/npm/@material-design-icons/svg/outlined/%1.svg"
        },
        "material-round": {
            kind: "svg", colorize: true,
            url: "https://cdn.jsdelivr.net/npm/@material-design-icons/svg/round/%1.svg"
        },
        "material-sharp": {
            kind: "svg", colorize: true,
            url: "https://cdn.jsdelivr.net/npm/@material-design-icons/svg/sharp/%1.svg"
        },
        "material-symbols-rounded": {
            kind: "svg", colorize: true,
            url: "https://cdn.jsdelivr.net/npm/@material-symbols/svg-400/rounded/%1.svg"
        },
        "material-symbols-outlined": {
            kind: "svg", colorize: true,
            url: "https://cdn.jsdelivr.net/npm/@material-symbols/svg-400/outlined/%1.svg"
        },
        "material-symbols-sharp": {
            kind: "svg", colorize: true,
            url: "https://cdn.jsdelivr.net/npm/@material-symbols/svg-400/sharp/%1.svg"
        },
        // Ionicons：Quasar 内置图标集为 v4 类名（ion-md-*/ion-ios-*），SVG 通道取 v7 分发，
        // 名称按 v4→v7 语义映射：md-X → X（filled）、ios-X → X-outline
        "ionicons": {
            kind: "svg", colorize: true,
            url: function (name) {
                var n = String(name)
                if (n.indexOf("ion-") === 0)
                    n = n.slice(4)
                if (n.indexOf("md-") === 0)
                    n = n.slice(3)
                else if (n.indexOf("ios-") === 0)
                    n = n.slice(4) + "-outline"
                return "https://cdn.jsdelivr.net/npm/ionicons@7/dist/svg/" + n + ".svg"
            }
        },
        // Eva Icons（outline 目录 + svg 子目录，实测路径；分发文件名为 <name>-outline.svg）
        "eva": {
            kind: "svg", colorize: true,
            url: function (name) {
                var n = String(name)
                if (n.indexOf("eva-") === 0)
                    n = n.slice(4)
                if (n.slice(-8) !== "-outline")
                    n = n + "-outline"
                return "https://cdn.jsdelivr.net/npm/eva-icons@1.1.3/outline/svg/" + n + ".svg"
            }
        },
        // Font Awesome 6 Free 三风格（v6 起大量图标改名：home→house 等，内置别名表见 _faAlias）
        "fontawesome-solid": {
            kind: "svg", colorize: true,
            url: function (name) {
                return "https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.7.2/svgs/solid/"
                        + root._faResolve(name) + ".svg"
            }
        },
        "fontawesome-regular": {
            kind: "svg", colorize: true,
            url: function (name) {
                return "https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.7.2/svgs/regular/"
                        + root._faResolve(name) + ".svg"
            }
        },
        "fontawesome-brands": {
            kind: "svg", colorize: true,
            url: "https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.7.2/svgs/brands/%1.svg"
        },
        // Bootstrap Icons
        "bootstrap": {
            kind: "svg", colorize: true,
            url: "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/icons/%1.svg"
        },
        // Line Awesome（实际分发为 <name>-solid.svg）
        "line-awesome": {
            kind: "svg", colorize: true,
            url: function (name) {
                return "https://cdn.jsdelivr.net/npm/line-awesome@1/svg/" + name + "-solid.svg"
            }
        }
    })

    // Font Awesome 5 → 6 改名表（v6 free 包不再分发旧文件名；仅收组件库常用图标）
    readonly property var _faAlias: ({
        "home": "house", "search": "magnifying-glass", "times": "xmark",
        "check-circle": "circle-check", "times-circle": "circle-xmark",
        "info-circle": "circle-info", "question-circle": "circle-question",
        "exclamation-circle": "circle-exclamation", "exclamation-triangle": "triangle-exclamation",
        "plus-circle": "circle-plus", "minus-circle": "circle-minus",
        "arrow-circle-right": "circle-arrow-right", "arrow-circle-left": "circle-arrow-left",
        "arrow-alt-circle-right": "circle-right", "trash-alt": "trash-can",
        "edit": "pen-to-square", "pencil-alt": "pen", "save": "floppy-disk",
        "user-times": "user-xmark", "user-edit": "user-pen", "sync": "rotate",
        "sync-alt": "rotate", "cog": "gear", "cogs": "gears",
        "shopping-cart": "cart-shopping", "sign-in-alt": "right-to-left",
        "sign-out-alt": "right-from-bracket", "external-link-alt": "up-right-from-square",
        "file-alt": "file-lines", "calendar-alt": "calendar-days",
        "chart-bar": "chart-column", "comment-alt": "comment-dots",
        "map-marker-alt": "location-dot", "phone-alt": "phone",
        "envelope-open-text": "envelope-open-text", "th-list": "table-list",
        "sort": "arrow-down-wide-short", "sort-alpha-down": "arrow-down-a-z",
        "long-arrow-alt-right": "arrow-right-long", "long-arrow-alt-left": "arrow-left-long",
        "angle-double-left": "angles-left", "angle-double-right": "angles-right",
        "angle-left": "angle-left", "chevron-circle-down": "circle-chevron-down"
    })

    function _faResolve(name) {
        var n = String(name)
        if (n.indexOf("fa-") === 0)
            n = n.slice(3)
        var alias = root._faAlias[n]
        return alias !== undefined ? alias : n
    }

    // 已注册 provider id 列表
    readonly property var providers: {
        root._rev
        return Object.keys(root._providers)
    }

    // 注册/覆盖一个 provider；返回是否成功（name 为空视为调用错误）
    function registerProvider(id, spec) {
        if (!id || !spec)
            return false
        if (spec.kind === undefined)
            spec = Object.assign({ kind: "svg", colorize: true }, spec)
        if (spec.kind === "svg" && typeof spec.url !== "string" && typeof spec.url !== "function") {
            console.warn("NovaIconSet: provider " + id + " 缺少 url 模板或函数")
            return false
        }
        if (spec.kind === "ligature" && !spec.family) {
            console.warn("NovaIconSet: ligature provider " + id + " 缺少 family")
            return false
        }
        var next = Object.assign({}, root._providers)
        next[id] = spec
        root._providers = next
        root._rev++
        return true
    }

    function unregisterProvider(id) {
        if (root._providers[id] === undefined)
            return false
        var next = Object.assign({}, root._providers)
        delete next[id]
        root._providers = next
        root._rev++
        return true
    }

    function provider(id) {
        root._rev
        return root._providers[id] !== undefined ? root._providers[id] : null
    }

    // provider 的最终资源地址：模板 %1 替换或调用函数
    function providerUrl(id, iconName) {
        var p = root.provider(id)
        if (p === null)
            return ""
        if (typeof p.url === "function")
            return String(p.url(iconName))
        return String(p.url).replace("%1", iconName)
    }

    // ── 图标名归一化解析器（对标 QIcon.parseIcon，八通道）─────
    // 返回 { kind, provider, name, content?, nodes?, src?, cls? }
    //   kind: "none" | "svg" | "ligature" | "image" | "path" | "unsupported"
    property var _libMap: ({
        "mdi-": "mdi",
        "icon-": "fontawesome-solid",
        "fa-": "fontawesome-solid",
        "bt-": "bootstrap",
        "eva-": "eva",
        "iconfont ": "iconfont",
        "ti-": "themify",
        "bi-": "bootstrap",
        "i-": "unocss"
    })

    property var _matMap: ({ "o_": "material-outlined", "r_": "material-round", "s_": "material-sharp" })
    property var _symMap: ({ "sym_o_": "material-symbols-outlined",
                             "sym_r_": "material-symbols-rounded",
                             "sym_s_": "material-symbols-sharp" })

    // 当前图标集对应的默认 provider（裸名兜底通道）
    function defaultProvider() {
        var n = root._name
        if (root._providers[n] !== undefined)
            return n
        if (n.indexOf("material-symbols") === 0)
            return "material-symbols-rounded"
        if (n.indexOf("material-icons") === 0)
            return "material"
        if (n === "mdi-v5" || n === "mdi-v6" || n === "mdi-v7")
            return "mdi"
        if (n === "ionicons-v4")
            return "ionicons"
        if (n === "eva-icons")
            return "eva"
        if (n === "fontawesome-v6")
            return "fontawesome-solid"
        if (n === "bootstrap-icons")
            return "bootstrap"
        if (n === "line-awesome")
            return "line-awesome"
        if (n === "themify")
            return "themify"
        return "material"
    }

    // FA / LineAwesome 旧式写法判定：「fa fa-home」「fas fa-home」「las la-home」
    function _isFaLegacy(s) {
        if (s.length < 4)
            return false
        var c0 = s.charCodeAt(0)
        if ((c0 !== 102 && c0 !== 108) || s.charCodeAt(1) !== 97)   // f|l + a
            return false
        var c2 = s.charCodeAt(2)
        if (c2 === 32)                                              // "fa ..."
            return true
        if (s.charCodeAt(3) !== 32)
            return false
        return c2 === 115 || c2 === 114 || c2 === 108 || c2 === 98 || c2 === 100 || c2 === 107
    }

    // SVG path 直出判定：以 M/m 开头的路径数据
    function _isSvgPath(s) {
        var c0 = s.charCodeAt(0)
        if (c0 !== 77 && c0 !== 109)
            return false
        var i = 1, c = s.charCodeAt(i)
        while (c === 32 || (c >= 9 && c <= 13)) c = s.charCodeAt(++i)
        if (c === 43 || c === 45) c = s.charCodeAt(++i)
        if (c === 46) c = s.charCodeAt(++i)
        return c >= 48 && c <= 57
    }

    function resolve(icon) {
        root._rev
        if (icon === undefined || icon === null || icon === "" || icon === "none")
            return { kind: "none", provider: "", name: "" }
        var s = String(icon).trim()

        // 1) 图片直出
        if (s.indexOf("img:") === 0)
            return { kind: "image", provider: "", name: s.slice(4), src: s.slice(4) }

        // 2) SVG <use>（QML 无对应能力，显式留痕而非静默失败）
        if (s.indexOf("svguse:") === 0)
            return { kind: "unsupported", provider: "", name: s,
                     reason: "QML 无 SVG <use> 引用能力，请改用 img: 或 svg path" }

        // 3) Ionicons：ion-md-*/ion-ios-*/ion-logo-* 原样，裸 ion-* 取当前平台前缀
        if (s.indexOf("ion-") === 0) {
            var nm = s
            if (s.indexOf("ion-md") !== 0 && s.indexOf("ion-ios") !== 0 && s.indexOf("ion-logo") !== 0)
                nm = "ion-" + (Qt.platform.os === "ios" || Qt.platform.os === "osx" ? "ios" : "md") + s.slice(3)
            return { kind: "svg", provider: "ionicons", name: nm }
        }

        // 4) Material Symbols 变体前缀 sym_[ors]_
        if (s.indexOf("sym_") === 0) {
            var symType = root._symMap[s.slice(0, 6)]
            if (symType !== undefined)
                return { kind: "svg", provider: symType, name: s.slice(6) }
            // 未知 sym_ 名字按普通 material 名处理（基线同款回落）
        }

        // 5) 前缀库映射（声明顺序即优先级：icon-/iconfont 先于 i-）
        var prefixes = Object.keys(root._libMap)
        for (var i = 0; i < prefixes.length; ++i) {
            var pre = prefixes[i]
            if (s.indexOf(pre) === 0) {
                var lib = root._libMap[pre]
                var body = s.slice(pre.length)
                if (lib === "unocss")
                    return { kind: "unsupported", provider: "", name: s,
                             reason: "UnoCSS 纯图标依赖构建期 CSS，QML 无对应能力" }
                if (lib.indexOf("fontawesome") === 0) {
                    // fa- 前缀：按风格类名细分为 solid/regular/brands
                    var fp = "fontawesome-solid"
                    if (pre === "icon-" || body.indexOf("brands ") === 0)
                        fp = "fontawesome-brands"
                    return { kind: "svg", provider: fp, name: body.replace(/^(solid|regular|brands) /, "") }
                }
                return { kind: "svg", provider: lib, name: body }
            }
        }

        // 6) FA 旧式类名写法：fas fa-home / far fa-home / fab fa-github / las la-home
        if (root._isFaLegacy(s)) {
            var toks = s.split(/\s+/)
            var style = toks[0]
            var body2 = toks.length > 1 ? toks[toks.length - 1] : ""
            if (body2.indexOf("fa-") === 0)
                body2 = body2.slice(3)
            else if (body2.indexOf("la-") === 0)
                body2 = body2.slice(3)
            var prov = "fontawesome-solid"
            if (style === "far")
                prov = "fontawesome-regular"
            else if (style === "fab")
                prov = "fontawesome-brands"
            else if (style === "las" || style === "lar" || style === "lal")
                prov = "line-awesome"
            return { kind: "svg", provider: prov, name: body2 }
        }

        // 7) SVG path 直出：`M...|viewBox`，多段用 && 分隔，style/transform 用 @@ 分隔
        if (root._isSvgPath(s)) {
            var parts = s.split("|")
            var def = parts[0]
            var nodes = def.split("&&").map(function (seg) {
                var t = seg.split("@@")
                return { d: t[0], style: t[1] !== undefined ? t[1] : "", transform: t[2] !== undefined ? t[2] : "" }
            })
            return { kind: "path", provider: "", name: "", nodes: nodes,
                     viewBox: parts.length > 1 ? parts[1] : "0 0 24 24" }
        }

        // 8) `set:name` 显式写法（Nova 原生）：mdi:home / material-outlined:settings
        var ci = s.indexOf(":")
        if (ci > 0) {
            var setId = s.slice(0, ci)
            var mapped = {
                "mdi": "mdi", "material": "material",
                "material-outlined": "material-outlined", "material-round": "material-round",
                "material-sharp": "material-sharp", "material-symbols": "material-symbols-rounded",
                "ionicons": "ionicons", "eva": "eva", "fontawesome": "fontawesome-solid",
                "themify": "themify", "bootstrap": "bootstrap", "line-awesome": "line-awesome"
            }[setId]
            if (mapped !== undefined)
                return { kind: "svg", provider: mapped, name: s.slice(ci + 1) }
        }

        // 8.5) 非图标名文本（emoji / 单字符符号）：直接当文本渲染，不去 CDN 撞 404
        if (/[^\x00-\x7F]/.test(s) && !/[\u4e00-\u9fa5]/.test(s))
            return { kind: "text", provider: "", name: s }

        // 9) 兜底：material 连字变体 o_/r_/s_，其余走当前图标集默认 provider
        var matType = root._matMap[s.slice(0, 2)]
        if (matType !== undefined)
            return { kind: "svg", provider: matType, name: s.slice(2) }
        return { kind: "svg", provider: root.defaultProvider(), name: s }
    }
}
