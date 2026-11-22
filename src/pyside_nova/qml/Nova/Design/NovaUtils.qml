// src/pyside_nova/qml/Nova/Design/NovaUtils.qml
// NovaUtils 工具层单例（对标 Quasar utils）：colors 12 / date 21（formatDate 44 token）/ format 6 / is 5 / debounce / throttle / frameDebounce / uid / extend
// NovaUtils —— L5 工具层（对标 Quasar `import { colors, date, format, is, extend, debounce, throttle, uid } from 'quasar'`）
// 1:1 对账基线：npm quasar@2.35.5 src/utils/{colors,date,format,is,extend,debounce,throttle,frame-debounce,uid}
// QML 不适用项（留痕，见 docs/PARITY.md L5 节）：
//   dom 9 项（offset/style/height/width/css/cssBatch/ready/getElement/childHasFocus）→ QML Item 几何原生
//   event 14 项（listenOpts/getEventPath/stop/prevent/…）→ QML MouseArea 信号与 accepted
//   scroll 12 项（getScrollHeight/animVerticalScrollTo/…）→ QML Flickable contentY/contentHeight
//   colors.getPaletteColor（依赖 document+getComputedStyle）
pragma Singleton
import QtQuick

QtObject {
    id: root

    // ══════════════════════════════════════════════════════════
    // 内部工具（V4 引擎兼容层：不依赖 ES2017+ 的 padStart/replaceAll/at/Map）
    // ══════════════════════════════════════════════════════════
    // 单字节转两位十六进制（不用位运算拼串：V4 引擎下 1<<24 参与 | 运算会串色）
    function _hex2(n) {
        var s = Math.round(n).toString(16)
        return s.length >= 2 ? s : "0" + s
    }

    function _pad(v, length, char) {
        if (v === undefined || v === null)
            return v
        var c = char === undefined ? "0" : char
        var s = String(v)
        var n = length === undefined ? 2 : length
        while (s.length < n)
            s = c + s
        return s
    }

    function _replaceAll(s, find, repl) {
        return String(s).split(find).join(repl)
    }

    function _isDateObj(v) {
        return Object.prototype.toString.call(v) === "[object Date]"
    }

    function _isArray(v) {
        return Array.isArray(v)
    }

    function _isPlainObject(v) {
        return v !== null && typeof v === "object" && !Array.isArray(v) && !_isDateObj(v)
    }

    function _toDate(v) {
        if (_isDateObj(v))
            return new Date(v.getTime())
        return new Date(v)
    }

    function _cloneDate(v) {
        return _isDateObj(v) ? new Date(v.getTime()) : v
    }

    function _daysInMonth(y, m) {
        return new Date(y, m + 1, 0).getDate()
    }

    // ══════════════════════════════════════════════════════════
    // colors —— 12 个函数 1:1（a 一律 0..100 百分比，遵循基线数值契约）
    // ══════════════════════════════════════════════════════════
    readonly property var colors: ({
        rgbToHex: function (c) {
            var r = Math.round(c.r), g = Math.round(c.g), b = Math.round(c.b)
            var hasA = c.a !== undefined
            if (r > 255 || g > 255 || b > 255 || (hasA && c.a > 100))
                throw new TypeError("Expected 3 numbers below 256 (and optionally one below 100)")
            var a = ""
            if (hasA) {
                var byte = Math.round((255 * c.a) / 100)
                a = root._pad(byte.toString(16), 2).slice(-2)
            }
            return "#" + root._hex2(r) + root._hex2(g) + root._hex2(b) + a
        },

        rgbToText: function (c) {
            var hasA = c.a !== undefined
            var alpha = hasA ? "," + Number((c.a / 100).toFixed(10)) : ""
            return "rgb" + (hasA ? "a" : "") + "(" + c.r + "," + c.g + "," + c.b + alpha + ")"
        },

        hexToRgb: function (hex) {
            if (typeof hex !== "string")
                throw new TypeError("Expected a string")
            if (hex.charCodeAt(0) === 35)
                hex = hex.slice(1)
            if (hex.length === 3 || hex.length === 4) {
                var e = ""
                for (var i = 0; i < hex.length; ++i)
                    e += hex[i] + hex[i]
                hex = e
            }
            var num = parseInt(hex, 16)
            if (hex.length > 6) {
                return {
                    r: (num >> 24) & 255,
                    g: (num >> 16) & 255,
                    b: (num >> 8) & 255,
                    a: Math.round(((num & 255) / 2.55) * 10) / 10
                }
            }
            return { r: num >> 16, g: (num >> 8) & 255, b: num & 255 }
        },

        hsvToRgb: function (c) {
            var s = c.s / 100, v = c.v / 100, h = c.h / 360
            var i = Math.floor(h * 6), f = h * 6 - i
            var p = v * (1 - s), q = v * (1 - f * s), t = v * (1 - (1 - f) * s)
            var r, g, b
            switch (i % 6) {
            case 0: r = v; g = t; b = p; break
            case 1: r = q; g = v; b = p; break
            case 2: r = p; g = v; b = t; break
            case 3: r = p; g = q; b = v; break
            case 4: r = t; g = p; b = v; break
            default: r = v; g = p; b = q; break
            }
            return { r: Math.round(r * 255), g: Math.round(g * 255), b: Math.round(b * 255), a: c.a }
        },

        rgbToHsv: function (c) {
            var max = Math.max(c.r, c.g, c.b), min = Math.min(c.r, c.g, c.b)
            var d = max - min
            var s = max === 0 ? 0 : d / max
            var v = max / 255
            var h = 0
            if (max !== min) {
                if (max === c.r)
                    h = (c.g - c.b + d * (c.g < c.b ? 6 : 0)) / (6 * d)
                else if (max === c.g)
                    h = (c.b - c.r + d * 2) / (6 * d)
                else
                    h = (c.r - c.g + d * 4) / (6 * d)
            }
            return { h: Math.round(h * 360), s: Math.round(s * 100), v: Math.round(v * 100), a: c.a }
        },

        textToRgb: function (str) {
            if (typeof str !== "string")
                throw new TypeError("Expected a string")
            var color = root._replaceAll(str, " ", "")
            var re = /^rgb(a)?\((\d{1,3}),(\d{1,3}),(\d{1,3}),?([01]?\.?\d*?)?\)$/
            var m = re.exec(color)
            if (m === null)
                return root.colors.hexToRgb(color)
            var rgb = {
                r: Math.min(255, Math.max(0, parseInt(m[2], 10))),
                g: Math.min(255, Math.max(0, parseInt(m[3], 10))),
                b: Math.min(255, Math.max(0, parseInt(m[4], 10)))
            }
            if (m[1] !== undefined || m[5] !== undefined) {
                var alpha = parseFloat(m[5])
                var safe = isFinite(alpha) ? Math.max(0, Math.min(1, alpha)) : 1
                rgb.a = Number((safe * 100).toFixed(10))
            }
            return rgb
        },

        // percent < 0 即 darken（基线语义）
        lighten: function (color, percent) {
            if (typeof color !== "string")
                throw new TypeError("Expected a string as color")
            if (typeof percent !== "number")
                throw new TypeError("Expected a numeric percent")
            var rgb = root.colors.textToRgb(color)
            var t = percent < 0 ? 0 : 255
            var p = Math.abs(percent) / 100
            var r = Math.round((t - rgb.r) * p) + rgb.r
            var g = Math.round((t - rgb.g) * p) + rgb.g
            var b = Math.round((t - rgb.b) * p) + rgb.b
            return "#" + root._hex2(r) + root._hex2(g) + root._hex2(b)
        },

        luminosity: function (color) {
            var rgb = typeof color === "string" ? root.colors.textToRgb(color) : color
            if (!rgb || rgb.r === undefined)
                throw new TypeError("Expected a string or a {r, g, b} object as color")
            var r = rgb.r / 255, g = rgb.g / 255, b = rgb.b / 255
            var R = r <= 0.03928 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4)
            var G = g <= 0.03928 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4)
            var B = b <= 0.03928 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4)
            return 0.2126 * R + 0.7152 * G + 0.0722 * B
        },

        brightness: function (color) {
            var rgb = typeof color === "string" ? root.colors.textToRgb(color) : color
            if (!rgb || rgb.r === undefined)
                throw new TypeError("Expected a string or a {r, g, b} object as color")
            return (rgb.r * 299 + rgb.g * 587 + rgb.b * 114) / 1000
        },

        blend: function (fgColor, bgColor) {
            var fgObj = typeof fgColor !== "string"
            var rgb1 = fgObj ? fgColor : root.colors.textToRgb(fgColor)
            var rgb2 = typeof bgColor !== "string" ? bgColor : root.colors.textToRgb(bgColor)
            if (!rgb1 || rgb1.r === undefined || !rgb2 || rgb2.r === undefined)
                throw new TypeError("Expected a string or a {r, g, b[, a]} object as colors")
            var r1 = rgb1.r / 255, g1 = rgb1.g / 255, b1 = rgb1.b / 255
            var a1 = rgb1.a !== undefined ? rgb1.a / 100 : 1
            var r2 = rgb2.r / 255, g2 = rgb2.g / 255, b2 = rgb2.b / 255
            var a2 = rgb2.a !== undefined ? rgb2.a / 100 : 1
            var a = a1 + a2 * (1 - a1)
            var ret = {
                r: Math.round(((r1 * a1 + r2 * a2 * (1 - a1)) / a) * 255),
                g: Math.round(((g1 * a1 + g2 * a2 * (1 - a1)) / a) * 255),
                b: Math.round(((b1 * a1 + b2 * a2 * (1 - a1)) / a) * 255),
                a: Math.round(a * 100)
            }
            return fgObj ? ret : root.colors.rgbToHex(ret)
        },

        // offset 必填且需在 -1..1；原色无 alpha 时基准 alpha = 0（基线语义）
        changeAlpha: function (color, offset) {
            if (typeof color !== "string")
                throw new TypeError("Expected a string as color")
            if (offset === undefined || offset < -1 || offset > 1)
                throw new TypeError("Expected offset to be between -1 and 1")
            var rgb = root.colors.textToRgb(color)
            var alpha = rgb.a !== undefined ? rgb.a / 100 : 0
            return root.colors.rgbToHex({
                r: rgb.r, g: rgb.g, b: rgb.b,
                a: Math.round(Math.min(1, Math.max(0, alpha + offset)) * 100)
            })
        },

        // Nova 增强：WCAG 对比度 + 自动字色（Quasar 无，QColorPicker/QBtn 选字色需要）
        contrastRatio: function (c1, c2) {
            var l1 = root.colors.luminosity(c1)
            var l2 = root.colors.luminosity(c2)
            var hi = Math.max(l1, l2), lo = Math.min(l1, l2)
            return (hi + 0.05) / (lo + 0.05)
        },

        contrastColor: function (bg, light, dark) {
            var l = light !== undefined ? light : "#FFFFFF"
            var d = dark !== undefined ? dark : "#000000"
            return root.colors.contrastRatio(bg, l) >= root.colors.contrastRatio(bg, d) ? l : d
        }
    })

    // ══════════════════════════════════════════════════════════
    // format —— 6 个函数 1:1
    // ══════════════════════════════════════════════════════════
    readonly property var format: ({
        humanStorageSize: function (bytes, decimals) {
            var units = ["B", "KB", "MB", "GB", "TB", "PB"]
            var u = 0
            var dec = decimals === undefined ? 1 : decimals
            while (parseInt(bytes, 10) >= 1024 && u < units.length - 1) {
                bytes /= 1024
                ++u
            }
            return bytes.toFixed(dec) + units[u]
        },

        capitalize: function (str) {
            return str.charAt(0).toUpperCase() + str.slice(1)
        },

        between: function (v, min, max) {
            return max <= min ? min : Math.min(max, Math.max(min, v))
        },

        normalizeToInterval: function (v, min, max) {
            if (max <= min)
                return min
            var size = max - min + 1
            var index = min + ((v - min) % size)
            if (index < min)
                index = size + index
            return index === 0 ? 0 : index
        },

        pad: function (v, length, char) {
            return root._pad(v, length, char)
        },

        getDecimalsCount: function (value) {
            var s = String(value).trim().toLowerCase().split("e")
            var mantissa = s[0]
            var exponent = Number(s[1]) || 0
            var dot = mantissa.split(".")
            var count = (dot[1] || "").length - exponent
            return count > 0 ? Math.min(count, 100) : 0
        }
    })

    // ══════════════════════════════════════════════════════════
    // date —— 语言包 + 21 个函数 + formatDate 44 token 1:1
    // ══════════════════════════════════════════════════════════
    readonly property var dateLocale: ({
        enUS: {
            days: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
            daysShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
            months: ["January", "February", "March", "April", "May", "June",
                     "July", "August", "September", "October", "November", "December"],
            monthsShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
            firstDayOfWeek: 0
        },
        zhCN: {
            days: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"],
            daysShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"],
            months: ["一月", "二月", "三月", "四月", "五月", "六月",
                     "七月", "八月", "九月", "十月", "十一月", "十二月"],
            monthsShort: ["一月", "二月", "三月", "四月", "五月", "六月",
                          "七月", "八月", "九月", "十月", "十一月", "十二月"],
            firstDayOfWeek: 1
        }
    })

    // token 正则（顺序即优先级，1:1 复制基线）
    readonly property var _dateTokenRe: /\[((?:[^\]\\]|\\]|\\)*)\]|do|d{1,4}|Mo|M{1,4}|m{1,2}|wo|w{1,2}|Qo|Do|DDDo|D{1,4}|YY(?:YY)?|GG(?:GG)?|H{1,2}|h{1,2}|s{1,2}|S{1,3}|Z{1,2}|a{1,2}|[AQExX]/g
    readonly property string _defaultMask: "YYYY-MM-DDTHH:mm:ss.SSSZ"

    function _ordinal(n) {
        var v = n % 100
        if (v >= 11 && v <= 13)
            return n + "th"
        switch (n % 10) {
        case 1: return n + "st"
        case 2: return n + "nd"
        case 3: return n + "rd"
        default: return n + "th"
        }
    }

    // 时区：offset > 0 输出 '-'，=== 0 输出 '+'（基线符号约定）
    function _formatTimezone(offsetMinutes, colon) {
        var abs = Math.abs(offsetMinutes)
        var h = root._pad(Math.floor(abs / 60), 2)
        var m = root._pad(abs % 60, 2)
        var sign = offsetMinutes > 0 ? "-" : "+"
        return sign + h + (colon ? ":" : "") + m
    }

    // ISO 8601 周（无 firstDayOfWeek/firstWeekMinDays 参数，2.x 已收敛为 ISO）
    function _isoWeekThursday(d) {
        var x = new Date(d.getFullYear(), d.getMonth(), d.getDate())
        var day = x.getDay() || 7
        x.setDate(x.getDate() + 4 - day)
        return x
    }

    readonly property var date: ({
        formatDate: function (val, mask, locale, forcedYear) {
            if (val === undefined || val === null || val === "" || val === false
                    || val === Infinity || val === -Infinity)
                return undefined
            var d = root._isDateObj(val) ? val : new Date(val)
            if (isNaN(d.getTime()))
                return undefined
            var dl = locale || root.dateLocale.enUS
            // 基线 null 会抛错；QML 绑定常给 null，这里有意回落默认（PARITY 标偏差点）
            var m = (mask === undefined || mask === null) ? root._defaultMask : String(mask)
            var y = d.getFullYear()
            var mo = d.getMonth()
            var dd = d.getDate()
            var hh = d.getHours()
            var mi = d.getMinutes()
            var ss = d.getSeconds()
            var ms = d.getMilliseconds()
            var doy = root.date.getDayOfYear(d)
            var woy = root.date.getWeekOfYear(d)
            var woyYear = root.date.getISOWeekYear(d)

            var f = {
                YY: function () {
                    var v = y % 100
                    return v < 0 ? "-" + root._pad(-v, 2) : root._pad(v, 2)
                },
                YYYY: function () { return root._pad(forcedYear !== undefined ? forcedYear : y, 4) },
                M: function () { return mo + 1 },
                Mo: function () { return root._ordinal(mo + 1) },
                MM: function () { return root._pad(mo + 1, 2) },
                MMM: function () { return dl.monthsShort[mo] },
                MMMM: function () { return dl.months[mo] },
                Q: function () { return Math.ceil((mo + 1) / 3) },
                Qo: function () { return root._ordinal(Math.ceil((mo + 1) / 3)) },
                D: function () { return dd },
                Do: function () { return root._ordinal(dd) },
                DD: function () { return root._pad(dd, 2) },
                DDD: function () { return doy },
                DDDo: function () { return root._ordinal(doy) },
                DDDD: function () { return root._pad(doy, 3) },
                d: function () { return d.getDay() },
                do: function () { return root._ordinal(d.getDay()) },
                dd: function () { return dl.days[d.getDay()].slice(0, 2) },
                ddd: function () { return dl.daysShort[d.getDay()] },
                dddd: function () { return dl.days[d.getDay()] },
                E: function () { return d.getDay() || 7 },
                w: function () { return woy },
                wo: function () { return root._ordinal(woy) },
                ww: function () { return root._pad(woy, 2) },
                GG: function () { return root._pad(woyYear % 100, 2) },
                GGGG: function () { return forcedYear !== undefined ? forcedYear : woyYear },
                H: function () { return hh },
                HH: function () { return root._pad(hh, 2) },
                h: function () { return hh === 0 ? 12 : (hh > 12 ? hh % 12 : hh) },
                hh: function () { return root._pad(hh === 0 ? 12 : (hh > 12 ? hh % 12 : hh), 2) },
                m: function () { return mi },
                mm: function () { return root._pad(mi, 2) },
                s: function () { return ss },
                ss: function () { return root._pad(ss, 2) },
                S: function () { return Math.floor(ms / 100) },
                SS: function () { return root._pad(Math.floor(ms / 10), 2) },
                SSS: function () { return root._pad(ms, 3) },
                A: function () { return hh < 12 ? "AM" : "PM" },
                a: function () { return hh < 12 ? "am" : "pm" },
                aa: function () { return hh < 12 ? "a.m." : "p.m." },
                Z: function () { return root._formatTimezone(d.getTimezoneOffset(), true) },
                ZZ: function () { return root._formatTimezone(d.getTimezoneOffset(), false) },
                X: function () { return Math.floor(d.getTime() / 1000) },
                x: function () { return d.getTime() }
            }

            return m.replace(root._dateTokenRe, function (token) {
                if (token.charCodeAt(0) === 91)   // '['
                    return token.slice(1, token.length - 1).split("\\]").join("]")
                var fn = f[token]
                return fn !== undefined ? String(fn()) : token
            })
        },

        addToDate: function (d, mod) { return root.date._change(d, mod, 1) },
        subtractFromDate: function (d, mod) { return root.date._change(d, mod, -1) },

        _change: function (d, mod, sign) {
            if (!mod)
                return new Date(d.getTime())
            var date = new Date(d.getTime())
            var day = mod.day !== undefined ? mod.day : mod.days
            var hour = mod.hour !== undefined ? mod.hour : mod.hours
            var minute = mod.minute !== undefined ? mod.minute : mod.minutes
            var second = mod.second !== undefined ? mod.second : mod.seconds
            var ms = mod.millisecond !== undefined ? mod.millisecond : mod.milliseconds
            var monthCount = mod.month !== undefined ? mod.month : mod.months
            var yearCount = mod.year !== undefined ? mod.year : mod.years
            var explicitDate = mod.date

            // 先做 年/月/日 的"日夹取"（先 setDate(1) 防溢出，1/31 + 1 月不滚到 3/3）
            if (monthCount !== undefined || yearCount !== undefined || explicitDate !== undefined) {
                var targetDay = explicitDate !== undefined
                        ? explicitDate : (day !== undefined ? date.getDate() + sign * day : date.getDate())
                var y = date.getFullYear() + (yearCount !== undefined ? sign * yearCount : 0)
                var mo = date.getMonth() + (monthCount !== undefined ? sign * monthCount : 0)
                date.setDate(1)
                date.setFullYear(y)
                date.setMonth(mo)
                date.setDate(Math.min(targetDay, root._daysInMonth(y, date.getMonth())))
                if (day !== undefined && explicitDate === undefined)
                    day = undefined   // 已并入 targetDay
            }

            if (day !== undefined) date.setDate(date.getDate() + sign * day)
            if (hour !== undefined) date.setHours(date.getHours() + sign * hour)
            if (minute !== undefined) date.setMinutes(date.getMinutes() + sign * minute)
            if (second !== undefined) date.setSeconds(date.getSeconds() + sign * second)
            if (ms !== undefined) date.setMilliseconds(date.getMilliseconds() + sign * ms)
            return date
        },

        adjustDate: function (d, mod, utc) {
            var date = new Date(d.getTime())
            var get = utc ? "getUTC" : "get"
            var set = utc ? "setUTC" : "set"
            var keys = ["FullYear", "Month", "Date", "Hours", "Minutes", "Seconds", "Milliseconds"]
            var names = ["year", "month", "date", "hour", "minute", "second", "millisecond"]
            for (var i = 0; i < keys.length; ++i) {
                var v = mod[names[i]]
                if (v !== undefined)
                    date[set + keys[i]](v)
            }
            return date
        },

        buildDate: function (mod, utc) { return root.date.adjustDate(new Date(), mod, utc) },

        startOfDate: function (d, unit, utc) {
            var date = new Date(d.getTime())
            var u = String(unit).toLowerCase()
            var set = utc ? "setUTC" : "set"
            var get = utc ? "getUTC" : "get"
            switch (u) {
            case "year":
                date[set + "Month"](0)
            case "month":
                date[set + "Date"](1)
            case "day":
            case "date":
                date[set + "Hours"](0)
            case "hour":
                date[set + "Minutes"](0)
            case "minute":
                date[set + "Seconds"](0)
            case "second":
                date[set + "Milliseconds"](0)
            }
            return date
        },

        endOfDate: function (d, unit, utc) {
            var date = root.date.startOfDate(d, unit, utc)
            var u = String(unit).toLowerCase()
            var set = utc ? "setUTC" : "set"
            switch (u) {
            case "year": date[set + "FullYear"](date.getFullYear() + 1); date[set + "Month"](0); break
            case "month": date[set + "Month"](date.getMonth() + 1); break
            case "day":
            case "date": date[set + "Date"](date.getDate() + 1); break
            case "hour": date[set + "Hours"](date.getHours() + 1); break
            case "minute": date[set + "Minutes"](date.getMinutes() + 1); break
            case "second": date[set + "Seconds"](date.getSeconds() + 1); break
            }
            return new Date(date.getTime() - 1)
        },

        getDateDiff: function (d, subtract, unit) {
            var u = unit === undefined ? "days" : unit
            var a = root._isDateObj(d) ? d : new Date(d)
            var b = root._isDateObj(subtract) ? subtract : new Date(subtract)
            if (u === "years")
                return a.getFullYear() - b.getFullYear()
            if (u === "months")
                return (a.getFullYear() - b.getFullYear()) * 12 + (a.getMonth() - b.getMonth())
            var diff = a.getTime() - b.getTime()
            var tzFix = (b.getTimezoneOffset() - a.getTimezoneOffset()) * 60000
            var ms = diff + tzFix
            switch (u) {
            case "days": return Math.floor(ms / 86400000)
            case "hours": return Math.floor(ms / 3600000)
            case "minutes": return Math.floor(ms / 60000)
            default: return Math.floor(ms / 1000)
            }
        },

        getDayOfYear: function (d) {
            return root.date.getDateDiff(d, root.date.startOfDate(d, "year"), "days") + 1
        },

        getWeekOfYear: function (d) {
            var th = root._isoWeekThursday(d)
            var jan4 = new Date(th.getFullYear(), 0, 4)
            var firstTh = root._isoWeekThursday(jan4)
            return 1 + Math.round((th.getTime() - firstTh.getTime()) / 604800000)
        },

        getISOWeekYear: function (d) { return root._isoWeekThursday(d).getFullYear() },

        getDayOfWeek: function (d) { return d.getDay() || 7 },

        // 基线签名：(date, from, to, opts={inclusiveFrom, inclusiveTo, onlyDate})
        // Nova 增强：支持 '[]' '[)' '(]' '()' 字符串写法（第三条参数位）
        isBetweenDates: function (d, from, to, opts) {
            var o = {}
            if (typeof opts === "string") {
                o = {
                    inclusiveFrom: opts.charAt(0) === "[",
                    inclusiveTo: opts.charAt(1) === "]"
                }
            } else if (opts) {
                o = opts
            }
            var date = root._isDateObj(d) ? d : new Date(d)
            var a = root._isDateObj(from) ? from : new Date(from)
            var b = root._isDateObj(to) ? to : new Date(to)
            if (o.onlyDate) {
                var id = function (x) { return x.getFullYear() * 10000 + x.getMonth() * 100 + x.getDate() }
                var v = id(date), lo = id(a), hi = id(b)
                var l = o.inclusiveFrom ? v >= lo : v > lo
                var r = o.inclusiveTo ? v <= hi : v < hi
                return l && r
            }
            var lt = o.inclusiveFrom ? date.getTime() >= a.getTime() : date.getTime() > a.getTime()
            var rt = o.inclusiveTo ? date.getTime() <= b.getTime() : date.getTime() < b.getTime()
            return lt && rt
        },

        isSameDate: function (d, d2, unit) {
            if (unit === undefined)
                return d.getTime() === d2.getTime()
            switch (unit) {
            case "second":
                if (d.getSeconds() !== d2.getSeconds()) return false
            case "minute":
                if (d.getMinutes() !== d2.getMinutes()) return false
            case "hour":
                if (d.getHours() !== d2.getHours()) return false
            case "day":
                if (d.getDate() !== d2.getDate()) return false
            case "month":
                if (d.getMonth() !== d2.getMonth()) return false
            case "year":
                return d.getFullYear() === d2.getFullYear()
            default:
                throw new Error("date.isSameDate: 未知 unit " + unit)
            }
        },

        daysInMonth: function (d, utc) {
            var m = utc ? d.getUTCMonth() : d.getMonth()
            var y = utc ? d.getUTCFullYear() : d.getFullYear()
            return new Date(y, m + 1, 0).getDate()
        },

        getMaxDate: function (d) {
            var max = d.getTime()
            for (var i = 1; i < arguments.length; ++i)
                max = Math.max(max, arguments[i].getTime())
            return new Date(max)
        },

        getMinDate: function (d) {
            var min = d.getTime()
            for (var i = 1; i < arguments.length; ++i)
                min = Math.min(min, arguments[i].getTime())
            return new Date(min)
        },

        getDateBetween: function (d, min, max) {
            var t = d.getTime()
            if (min) t = Math.max(t, min.getTime())
            if (max) t = Math.min(t, max.getTime())
            return new Date(t)
        },

        inferDateFormat: function (d) {
            var t = typeof d
            return t === "object" ? "date" : t
        },

        isValid: function (d) {
            return isFinite(d) || isFinite(Date.parse(d))
        },

        clone: function (d) { return root._cloneDate(d) },

        // 解析侧：编译 mask 为正则后抽取字段（覆盖 44 token 的子集语义，见 PARITY）
        extractDate: function (str, mask, locale) {
            var dl = locale || root.dateLocale.enUS
            var m = (mask === undefined || mask === null) ? root._defaultMask : String(mask)
            var map = {}
            var captures = []
            var reText = ""
            var epochMs = null, epochS = null
            var lastIndex = 0
            var src = m.replace(root._dateTokenRe, function (token, literal, offset) {
                reText += root.date._escapeRe(m.slice(lastIndex, offset))
                lastIndex = offset + token.length
                if (literal !== undefined) {
                    reText += root.date._escapeRe(literal.split("\\]").join("]"))
                    return token
                }
                var pattern = null
                if (token === "YYYY") pattern = "(-?\\d{1,4})"
                else if (token === "YY") pattern = "(-?\\d{1,2})"
                else if (token === "M" || token === "Mo") pattern = "(\\d{1,2})(?:st|nd|rd|th)?"
                else if (token === "MM") pattern = "(\\d{2})"
                else if (token === "MMM") pattern = root._namesRe(dl.monthsShort)
                else if (token === "MMMM") pattern = root._namesRe(dl.months)
                else if (token === "D" || token === "Do") pattern = "(\\d{1,2})(?:st|nd|rd|th)?"
                else if (token === "DD") pattern = "(\\d{2})"
                else if (token === "DDD" || token === "DDDo") pattern = "(\\d{1,3})(?:st|nd|rd|th)?"
                else if (token === "DDDD") pattern = "(\\d{3})"
                else if (token === "H" || token === "HH") pattern = "(\\d{1,2})"
                else if (token === "h" || token === "hh") pattern = "(\\d{1,2})"
                else if (token === "m" || token === "mm") pattern = "(\\d{1,2})"
                else if (token === "s" || token === "ss") pattern = "(\\d{1,2})"
                else if (token === "S") pattern = "(\\d)"
                else if (token === "SS") pattern = "(\\d{2})"
                else if (token === "SSS") pattern = "(\\d{3})"
                else if (token === "A") pattern = "(AM|PM)"
                else if (token === "a") pattern = "(am|pm)"
                else if (token === "aa") pattern = "(a\\.m\\.|p\\.m\\.)"
                else if (token === "Z") pattern = "([+-]\\d{2}:\\d{2})"
                else if (token === "ZZ") pattern = "([+-]\\d{4})"
                else if (token === "X") pattern = "(\\d+)"
                else if (token === "x") pattern = "(\\d+)"
                if (pattern !== null) {
                    map[captures.length] = token
                    captures.push(token)
                    reText += pattern
                } else {
                    // 不参与字段计算的 token（星期/季度/周/时区名）以宽松模式吞掉
                    reText += "(?:[^\\s]+)"
                }
                return token
            })
            reText += root.date._escapeRe(m.slice(lastIndex))
            var re = new RegExp("^" + reText + "$")
            var hit = re.exec(str)
            if (hit === null)
                return new Date(NaN)

            var model = { year: null, month: null, date: null, hour: null, minute: null,
                          second: null, millisecond: 0, meridiem: null, dayOfYear: null }
            for (var i = 0; i < captures.length; ++i) {
                var tok = captures[i]
                var raw = hit[i + 1]
                if (raw === undefined)
                    continue
                switch (tok) {
                case "YYYY": model.year = parseInt(raw, 10); break
                case "YY":
                    model.year = parseInt(raw, 10)
                    if (model.year >= 0 && model.year < 100) model.year += 2000
                    break
                case "M": case "Mo": model.month = parseInt(raw, 10) - 1; break
                case "MM": model.month = parseInt(raw, 10) - 1; break
                case "MMM": model.month = dl.monthsShort.indexOf(raw); break
                case "MMMM": model.month = dl.months.indexOf(raw); break
                case "D": case "Do": case "DD": model.date = parseInt(raw, 10); break
                case "DDD": case "DDDo": case "DDDD": model.dayOfYear = parseInt(raw, 10); break
                case "H": case "HH": case "h": case "hh": model.hour = parseInt(raw, 10); break
                case "m": case "mm": model.minute = parseInt(raw, 10); break
                case "s": case "ss": model.second = parseInt(raw, 10); break
                case "S": model.millisecond = parseInt(raw, 10) * 100; break
                case "SS": model.millisecond = parseInt(raw, 10) * 10; break
                case "SSS": model.millisecond = parseInt(raw, 10); break
                case "A": model.meridiem = raw; break
                case "a": model.meridiem = raw.toUpperCase(); break
                case "aa": model.meridiem = raw.charAt(0).toUpperCase() === "P" ? "PM" : "AM"; break
                case "X": epochS = parseInt(raw, 10); break
                case "x": epochMs = parseInt(raw, 10); break
                }
            }
            if (epochS !== null) return new Date(epochS * 1000)
            if (epochMs !== null) return new Date(epochMs)

            var now = new Date()
            var y = model.year !== null ? model.year : now.getFullYear()
            var mo = model.month !== null ? model.month : 0
            var day = model.date !== null ? model.date : 1
            var h = model.hour !== null ? model.hour : 0
            if (model.meridiem !== null) {
                h = h % 12
                if (model.meridiem === "PM") h += 12
            }
            if (model.dayOfYear !== null) {
                var probe = new Date(2000, 0, model.dayOfYear)
                mo = probe.getMonth()
                day = probe.getDate()
            }
            return new Date(y, mo, day, h,
                            model.minute !== null ? model.minute : 0,
                            model.second !== null ? model.second : 0,
                            model.millisecond)
        },

        _escapeRe: function (s) {
            return String(s).replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
        },

        _namesRe: function (list) {
            var sorted = list.slice(0).sort(function (a, b) { return b.length - a.length })
            return "(" + sorted.map(function (x) { return root.date._escapeRe(x) }).join("|") + ")"
        }
    })

    // ══════════════════════════════════════════════════════════
    // is —— 5 个函数（基线 src/utils/is/is.js 全部导出）
    // ══════════════════════════════════════════════════════════
    readonly property var is: ({
        isObject: function (v) {
            return v !== null && typeof v === "object" && !Array.isArray(v)
        },

        isDate: function (v) {
            return Object.prototype.toString.call(v) === "[object Date]"
        },

        isRegexp: function (v) {
            return Object.prototype.toString.call(v) === "[object RegExp]"
        },

        isNumber: function (v) {
            return typeof v === "number" && isFinite(v)
        },

        deepEqual: function (a, b) {
            if (a === b)
                return true
            if (a !== a && b !== b)
                return true   // NaN
            if (a === null || b === null || typeof a !== "object" || typeof b !== "object")
                return false
            if (Array.isArray(a) !== Array.isArray(b))
                return false
            if (Array.isArray(a)) {
                if (a.length !== b.length)
                    return false
                for (var i = 0; i < a.length; ++i)
                    if (!root.is.deepEqual(a[i], b[i]))
                        return false
                return true
            }
            if (root.is.isDate(a) && root.is.isDate(b))
                return a.getTime() === b.getTime()
            if (root.is.isRegexp(a) && root.is.isRegexp(b))
                return String(a) === String(b)
            var ka = Object.keys(a).filter(function (k) { return a[k] !== undefined })
            var kb = Object.keys(b).filter(function (k) { return b[k] !== undefined })
            if (ka.length !== kb.length)
                return false
            for (var j = 0; j < ka.length; ++j) {
                if (kb.indexOf(ka[j]) < 0)
                    return false
                if (!root.is.deepEqual(a[ka[j]], b[ka[j]]))
                    return false
            }
            return true
        }
    })

    // ══════════════════════════════════════════════════════════
    // extend —— 类 jQuery 深/浅合并（基线语义：首参 boolean 表 deep）
    // ══════════════════════════════════════════════════════════
    function extend() {
        var args = Array.prototype.slice.call(arguments)
        var deep = false
        if (typeof args[0] === "boolean")
            deep = args.shift()
        var target = args.shift()
        if (!target || (typeof target !== "object" && typeof target !== "function"))
            target = {}
        for (var i = 0; i < args.length; ++i) {
            var src = args[i]
            if (!src)
                continue
            for (var key in src) {
                if (key === "__proto__")
                    continue
                var copy = src[key]
                if (copy === undefined)
                    continue
                if (deep && (root._isPlainObject(copy) || Array.isArray(copy))) {
                    var base = target[key]
                    if (Array.isArray(copy))
                        base = Array.isArray(base) ? base : []
                    else
                        base = root._isPlainObject(base) ? base : {}
                    target[key] = root.extend.apply(root, [true, base, copy])
                } else {
                    target[key] = copy
                }
            }
        }
        return target
    }

    function clone(v) {
        if (Array.isArray(v))
            return v.slice(0)
        if (root._isPlainObject(v))
            return root.extend(true, {}, v)
        return root._cloneDate(v)
    }

    // ══════════════════════════════════════════════════════════
    // 计时类工具：Timer 池（QML 无 setTimeout/crypto，用 Component 内联创建）
    // ══════════════════════════════════════════════════════════
    property Component _timerComp: Component { Timer {} }

    // debounce(fn, wait=250, options)：options = {leading, trailing=true, maxWait} 或布尔简写
    function debounce(fn, wait, options) {
        var opts = options
        if (opts === true)
            opts = { leading: true, trailing: false }
        else if (!opts)
            opts = {}
        var leading = opts.leading === true
        var trailing = opts.trailing === undefined ? true : opts.trailing === true
        var maxWait = typeof opts.maxWait === "number" ? opts.maxWait : 0
        var waitMs = wait === undefined ? 250 : wait

        var timer = root._timerComp.createObject(root, { "interval": waitMs, "repeat": false })
        var maxTimer = maxWait > 0
                ? root._timerComp.createObject(root, { "interval": maxWait, "repeat": false }) : null
        var lastArgs = null
        var lastThis = null
        var pending = false
        var result
        var wrapper

        function invoke() {
            if (lastArgs === null)
                return
            var args = lastArgs
            var ctx = lastThis
            lastArgs = null
            lastThis = null
            pending = false
            wrapper.isPending = false
            if (maxTimer !== null)
                maxTimer.stop()
            result = fn.apply(ctx, args)
        }

        wrapper = function () {
            lastArgs = Array.prototype.slice.call(arguments)
            lastThis = this
            var firstOfWindow = !timer.running
            pending = true
            wrapper.isPending = true
            if (leading && firstOfWindow) {
                invoke()
                pending = true
                wrapper.isPending = true
            }
            timer.restart()
            if (maxTimer !== null && !maxTimer.running)
                maxTimer.restart()
        }

        timer.triggered.connect(function () {
            if (trailing && pending)
                invoke()
            else {
                pending = false
                wrapper.isPending = false
            }
        })
        if (maxTimer !== null)
            maxTimer.triggered.connect(function () { if (pending) invoke() })

        wrapper.isPending = false
        wrapper.cancel = function () {
            timer.stop()
            if (maxTimer !== null)
                maxTimer.stop()
            lastArgs = null
            lastThis = null
            pending = false
            wrapper.isPending = false
        }
        wrapper.flush = function () {
            if (timer.running)
                timer.stop()
            if (pending)
                invoke()
        }
        return wrapper
    }

    // throttle(fn, limit=250, trailing)：返回上次 fn 返回值（基线语义）
    function throttle(fn, limit, trailing) {
        var limitMs = limit === undefined ? 250 : limit
        var timer = null
        var lastRun = 0
        var lastArgs = null
        var lastThis = null
        var pending = false
        var result

        function run() {
            lastRun = Date.now()
            var args = lastArgs
            var ctx = lastThis
            lastArgs = null
            lastThis = null
            pending = false
            result = fn.apply(ctx, args)
            return result
        }

        var wrapper = function () {
            lastArgs = Array.prototype.slice.call(arguments)
            lastThis = this
            var remain = limitMs - (Date.now() - lastRun)
            if (remain <= 0) {
                if (timer !== null) {
                    timer.stop()
                    timer.destroy()
                    timer = null
                }
                run()
            } else if (trailing) {
                pending = true
                if (timer === null) {
                    timer = root._timerComp.createObject(root, { "interval": remain, "repeat": false })
                    timer.start()          // createObject 不会自动启动 Timer（坑：必须显式 start/restart）
                    timer.triggered.connect(function () {
                        timer.destroy()
                        timer = null
                        if (pending)
                            run()
                    })
                } else {
                    timer.restart()
                }
            }
            return result
        }

        wrapper.cancel = function () {
            if (timer !== null) {
                timer.stop()
                timer.destroy()
                timer = null
            }
            lastArgs = null
            lastThis = null
            pending = false
        }
        wrapper.flush = function () {
            if (timer !== null) {
                timer.stop()
                timer.destroy()
                timer = null
            }
            return pending ? run() : result
        }
        return wrapper
    }

    // frameDebounce(fn)：QML 无 requestAnimationFrame，用 16ms 单发 Timer 等价（只保留最后一次参数）
    function frameDebounce(fn) {
        var timer = root._timerComp.createObject(root, { "interval": 16, "repeat": false })
        var lastArgs = null
        var lastThis = null
        timer.triggered.connect(function () {
            if (lastArgs !== null) {
                var args = lastArgs
                var ctx = lastThis
                lastArgs = null
                lastThis = null
                fn.apply(ctx, args)
            }
        })
        var wrapper = function () {
            lastArgs = Array.prototype.slice.call(arguments)
            lastThis = this
            timer.restart()
        }
        wrapper.cancel = function () {
            timer.stop()
            lastArgs = null
            lastThis = null
        }
        return wrapper
    }

    // uid()：QML 无 crypto.randomUUID，用时间戳 + 计数器 + 随机段生成 v4 形态（碰撞抗性弱于基线，见 PARITY）
    property int _uidCounter: 0

    function uid() {
        root._uidCounter = (root._uidCounter + 1) % 1000000
        var hex = "0123456789abcdef"
        var out = ""
        for (var i = 0; i < 36; ++i) {
            if (i === 8 || i === 13 || i === 18 || i === 23)
                out += "-"
            else if (i === 14)
                out += "4"
            else if (i === 19)
                out += hex.charAt(8 + Math.floor(Math.random() * 4))
            else
                out += hex.charAt(Math.floor(Math.random() * 16))
        }
        return out
    }
}
