// src/pyside_nova/qml/Nova/Services/NovaI18n.qml
// NovaI18n 国际化服务单例（对标 Quasar Lang 插件 $q.lang + vue-i18n 语义）
// 基线事实（npm quasar@2.35.5 Lang 源码核实）：
//     $q.lang.isoName / $q.lang.rtl / $q.lang.set(locale) / $q.lang.props（词典包）
//     事件 lang:locale-change；RTL 由语言集合判定（ar/he/fa/ur...）
// QML 语境裁定：
//     · vue-i18n 的组件树翻译注入 ⛔ 不适用（QML 无组件作用域词典），
//       改为「全局词典包 + t()/tp() 命令式查询」，词典可运行时 addBundle 热注入；
//     · 复数走 CLDR 1.4 卡片规则的 JS 精简实现（zh/other-only、en/de one-other、
//       ru one-few-many、ar zero-one-two-few-many、cs/sk one-few-many-other），
//       不引 ICU（离线可用、零依赖）；
//     · 数字/日期格式化走 locale 分隔符表 + Qt.formatDate/Qt.formatDateTime(…, Qt.locale(name))，
//       Qt 6 原生支持按 localeName 取规则，无需后端。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma Singleton
import QtQuick

QtObject {
    id: lang

    // ── locale（BCP-47，如 "zh-CN" / "en-US" / "ru-RU" / "ar-EG"） ──
    property string locale: "en-US"

    // 语言主码（"zh-CN" → "zh"；与 Quasar $q.lang.isoName 语义对齐但保留全称）
    readonly property string isoName: locale

    // 主语言码（小写；"zh-CN_zh-Hans" 等异形也能切出首段）
    readonly property string baseLang: {
        var head = locale.split(/[-_]/)[0]
        return head ? head.toLowerCase() : "en"
    }

    // ── RTL（对标 $q.lang.rtl；Quasar RTL 语言集合核实：ar/he/fa/ur/ps/sd/ug/yi/ckb） ──
    readonly property var _rtlLangs: ["ar", "he", "fa", "ur", "ps", "sd", "ug", "yi", "ckb"]
    readonly property bool isRtl: _rtlLangs.indexOf(baseLang) !== -1
    readonly property string direction: isRtl ? "rtl" : "ltr"

    function setLocale(name) {
        if (name && name !== lang.locale) {
            lang.locale = name
            // 对标 Quasar lang:locale-change 事件（QML 语境 = 属性信号）
        }
    }

    // ── 词典包（对标 $q.lang.props；内置 en-US / zh-CN，可运行时 addBundle 热注入） ──
    property var bundles: ({
        "en-US": {
            confirm: "Confirm", cancel: "Cancel", submit: "Submit", save: "Save",
            close: "Close", search: "Search", loading: "Loading…", retry: "Retry",
            menu: "Menu", more: "More", expand: "Expand", collapse: "Collapse",
            prevPage: "Previous page", nextPage: "Next page", firstPage: "First page",
            lastPage: "Last page", selected: "{n} selected", itemsOf: "{n} items",
            emptyText: "No data yet", required: "Required",
            dayAgo: "{n} day ago", monthAgo: "{n} month ago", yearAgo: "{n} year ago"
        },
        "zh-CN": {
            confirm: "确认", cancel: "取消", submit: "提交", save: "保存",
            close: "关闭", search: "搜索", loading: "加载中…", retry: "重试",
            menu: "菜单", more: "更多", expand: "展开", collapse: "收起",
            prevPage: "上一页", nextPage: "下一页", firstPage: "首页",
            lastPage: "末页", selected: "已选 {n} 项", itemsOf: "{n} 项",
            emptyText: "暂无数据", required: "必填项",
            dayAgo: "{n} 天前", monthAgo: "{n} 个月前", yearAgo: "{n} 年前"
        }
    })

    // 复数词典：key → { zero/one/two/few/many/other }（缺类别回落 other）
    // zh/ja/ko 只给 other；en：one/other；ru：one/few/many/other；ar：zero/one/two/few/many/other
    property var pluralBundles: ({
        "en-US": {
            apple: { one: "{n} apple", other: "{n} apples" },
            message: { one: "{n} message", other: "{n} messages" },
            dayAgo: { one: "{n} day ago", other: "{n} days ago" },
            monthAgo: { one: "{n} month ago", other: "{n} months ago" },
            yearAgo: { one: "{n} year ago", other: "{n} years ago" }
        },
        "zh-CN": {
            apple: { other: "{n} 个苹果" },
            message: { other: "{n} 条消息" },
            dayAgo: { other: "{n} 天前" },
            monthAgo: { other: "{n} 个月前" },
            yearAgo: { other: "{n} 年前" }
        }
    })

    function addBundle(localeName, dict) {
        if (!lang.bundles[localeName])
            lang.bundles[localeName] = {}
        for (var k in dict)
            lang.bundles[localeName][k] = dict[k]
    }

    function addPluralBundle(localeName, dict) {
        if (!lang.pluralBundles[localeName])
            lang.pluralBundles[localeName] = {}
        for (var k in dict)
            lang.pluralBundles[localeName][k] = dict[k]
    }

    // 词典查找链：locale 精确 → 主语言码（zh-TW→zh-CN：前缀匹配首个 base 相同的包）→ en-US → key 本身
    function _bundleFor(localeName) {
        var table = lang.bundles
        if (table[localeName] !== undefined)
            return table[localeName]
        var base = localeName.split(/[-_]/)[0]
        if (base) {
            if (table[base] !== undefined)
                return table[base]
            for (var k in table) {
                if (k.split(/[-_]/)[0] === base)
                    return table[k]
            }
        }
        return table["en-US"]
    }

    function _pluralBundleFor(localeName) {
        var table = lang.pluralBundles
        if (table[localeName] !== undefined)
            return table[localeName]
        var base = localeName.split(/[-_]/)[0]
        if (base) {
            if (table[base] !== undefined)
                return table[base]
            for (var k2 in table) {
                if (k2.split(/[-_]/)[0] === base)
                    return table[k2]
            }
        }
        return table["en-US"]
    }

    // ── 插值："{name}" → params.name；无 params 时原样返回 ──
    function _interpolate(tpl, params) {
        if (!params)
            return tpl
        return tpl.replace(/\{(\w+)\}/g, function (m, k) {
            return params[k] !== undefined ? String(params[k]) : m
        })
    }

    // ── 翻译（对标 vue-i18n $t；缺译回落链：locale 包 → en-US 包 → key 本身） ──
    function t(key, params) {
        var b = _bundleFor(lang.locale)
        var tpl = (b && b[key] !== undefined) ? b[key] : undefined
        if (tpl === undefined) {
            var fb = lang.bundles["en-US"]
            tpl = (fb && fb[key] !== undefined) ? fb[key] : key
        }
        return lang._interpolate(tpl, params)
    }

    // ── 复数类别（CLDR 1.4 卡片规则 · JS 精简实现） ──
    // 返回 "zero" | "one" | "two" | "few" | "many" | "other"
    function pluralCategory(n) {
        n = Number(n)
        var i = Math.floor(Math.abs(n))
        switch (lang.baseLang) {
        case "zh": case "ja": case "ko": case "th": case "vi":
            return "other"
        case "ar":
            if (n === 0) return "zero"
            if (n === 1) return "one"
            if (n === 2) return "two"
            var m100 = i % 100
            if (m100 >= 3 && m100 <= 10) return "few"
            if (m100 >= 11 && m100 <= 99) return "many"
            return "other"
        case "ru": case "uk":
            var m10 = i % 10, m100u = i % 100
            if (m10 === 1 && m100u !== 11) return "one"
            if (m10 >= 2 && m10 <= 4 && !(m100u >= 12 && m100u <= 14)) return "few"
            return "many"
        case "cs": case "sk":
            if (i === 1) return "one"
            if (i >= 2 && i <= 4) return "few"
            return "many"
        case "pl":
            var p10 = i % 10, p100 = i % 100
            if (i === 1) return "one"
            if (p10 >= 2 && p10 <= 4 && !(p100 >= 12 && p100 <= 14)) return "few"
            return "many"
        default: // en/de/es/fr/it/…：one（仅整数 1）/ other
            return (n === 1 && String(n) === String(i)) ? "one" : "other"
        }
    }

    // ── 复数翻译（对标 vue-i18n $tc / t 选择式）：tp("apple", 2) → "2 apples" ──
    function tp(key, n, params) {
        var pb = _pluralBundleFor(lang.locale)
        var forms = (pb && pb[key] !== undefined) ? pb[key] : null
        var cat = lang.pluralCategory(n)
        var tpl = key
        if (forms) {
            tpl = forms[cat] !== undefined ? forms[cat] : forms.other
        } else {
            // 词典缺复数条目 → 回落普通词典 → key 本身
            var b = _bundleFor(lang.locale)
            if (b && b[key] !== undefined) tpl = b[key]
        }
        var p = params || {}
        p.n = n
        return lang._interpolate(tpl, p)
    }

    // ── 数字本地化（千分位分组 + 小数点；分隔符表随 locale） ──
    // formatNumber(1234567.89) / formatNumber(1234.5, 2)
    readonly property var _separators: ({
        en: [",", "."], zh: [",", "."], ja: [",", "."], ko: [",", "."],
        de: [".", ","], es: [".", ","], it: [".", ","], ru: ["\u00A0", ","],
        fr: ["\u202F", ","], ar: ["\u066C", "\u066B"], he: [",", "."], fa: ["\u066C", "\u066B"]
    })

    function formatNumber(n, decimals) {
        var d = (decimals !== undefined) ? decimals : 0
        var neg = n < 0
        var abs = Math.abs(Number(n))
        var fixed = abs.toFixed(d)
        var parts = fixed.split(".")
        var sep = lang._separators[lang.baseLang] || lang._separators.en
        var intPart = parts[0]
        var grouped = intPart.replace(/\B(?=(\d{3})+(?!\d))/g, sep[0])
        if (parts.length > 1)
            grouped += sep[1] + parts[1]
        return (neg ? "-" : "") + grouped
    }

    // ── 货币（Nova 增强：Quasar 无；符号表 + formatNumber 复用） ──
    readonly property var _currencySymbols: ({
        en: "$", zh: "\u00A5", ja: "\u00A5", ko: "\u20A9", de: "\u20AC",
        es: "\u20AC", it: "\u20AC", fr: "\u20AC", ru: "\u20BD", ar: "\u0631.\u0633.",
        he: "\u20AA", fa: "\u0631\u06CC\u0627\u0644"
    })

    function formatCurrency(n, decimals) {
        var d = (decimals !== undefined) ? decimals : 2
        return (lang._currencySymbols[lang.baseLang] || "$") + lang.formatNumber(n, d)
    }

    // ── 日期时间本地化（Qt.locale(name).toString(date, pattern) 渲染） ──
    // 坑位 43：Qt 6.12 的 Qt.formatDate 三参重载实际不存在（(date, locale, pattern)
    // 被解析为 (date, locale) 两参版、pattern 被丢弃），自定义 pattern + 自定义 locale
    // 必须走 Qt.locale(name).toString(date, pattern) —— 本地化字段（月份名/数字）齐全。
    // style：shortDate / longDate / shortTime / longTime / shortDateTime / longDateTime / iso
    // 或直接传 Qt 自定义 pattern（如 "yyyy-MM-dd"）
    readonly property var _dateStyles: ({
        shortDate: "M/d/yy", longDate: "MMMM d, yyyy",
        shortTime: "h:mm AP", longTime: "h:mm:ss AP",
        shortDateTime: "M/d/yy h:mm AP", longDateTime: "MMMM d, yyyy h:mm:ss AP"
    })

    function formatDate(date, style) {
        var d = date
        if (style === "iso")
            return Qt.formatDateTime(d, "yyyy-MM-ddTHH:mm:ss")
        var pattern = lang._dateStyles[style] || (style || "longDate")
        return Qt.locale(lang.locale).toString(d, pattern)
    }

    // 相对时间（复数联动示范：dayAgo/monthAgo/yearAgo 走 tp）
    function formatRelative(date, now) {
        var ref = now || new Date()
        var days = Math.floor((ref.getTime() - date.getTime()) / 86400000)
        if (days < 30) return lang.tp("dayAgo", Math.max(days, 0) || 1)
        if (days < 365) return lang.tp("monthAgo", Math.floor(days / 30))
        return lang.tp("yearAgo", Math.floor(days / 365))
    }
}
