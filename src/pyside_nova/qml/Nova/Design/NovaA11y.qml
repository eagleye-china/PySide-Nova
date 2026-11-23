// src/pyside_nova/qml/Nova/Design/NovaA11y.qml
// NovaA11y 可访问性单例：WCAG 2.1 AA 对比度数学、AA 兜底派生令牌、键盘焦点可见性语义、状态播报与语义词汇表（对标 Quasar 无——Nova 增强）
// NovaA11y —— L0 设计语言层的可访问性基座（0.16.0 五期 Sprint B）
// 基线留痕：Quasar 2.35.5 无 a11y 模块（Vue 侧靠 aria-* 属性散写，无统一令牌与门禁）；
//   Nova 以此为差异化能力：Accessible.* 逐组件 1:1 覆盖 + AA 兜底派生 + 静态/运行时双门禁。
// 设计要点：
//   1. 纯函数集合 + 三态属性，不持有 Item 引用（QML 单例不得跨引擎持有对象）
//   2. 派生一律「最小位移」：品牌色本身不改，只在需要承载文字/边界时压到 AA 阈值
//   3. 焦点可见性走 focus-visible 语义：键盘操作才画焦点环（鼠标点击不画），
//      与浏览器 :focus-visible 一致，避免鼠标用户视觉噪声
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma Singleton
import QtQuick
import Nova.Runtime

QtObject {
    id: root

    // ══════════════════════════════════════════════════════════
    // 阈值常量（WCAG 2.1：1.4.3 文本 / 1.4.11 非文本 / 1.4.6 增强级）
    // ══════════════════════════════════════════════════════════
    readonly property real aaTextRatio: 4.5        // 常规文本 AA
    readonly property real aaLargeTextRatio: 3.0   // 大号文本 AA（≥18.66px 粗体 / ≥24px 常规）
    readonly property real aaaTextRatio: 7.0       // 常规文本 AAA
    readonly property real uiComponentRatio: 3.0   // 控件边界/图标/焦点指示（1.4.11）

    // ══════════════════════════════════════════════════════════
    // 焦点可见性（focus-visible 语义）
    // ══════════════════════════════════════════════════════════
    // keyboardMode 由 Nova.Runtime 的全局事件过滤器维护（最近一次输入来自键盘）
    readonly property bool keyboardMode: NovaRuntime.keyboardMode
    // 全局总开关：少数场景（演示/截图/无键盘终端）可关闭焦点环绘制
    property bool visibleFocus: true
    // 焦点环是否该画：有焦点 + 键盘模态 + 全局开关
    function ringVisible(target) {
        if (!root.visibleFocus || !root.keyboardMode)
            return false
        return target !== null && target !== undefined && target.activeFocus === true
    }

    // ══════════════════════════════════════════════════════════
    // WCAG 对比度数学（相对亮度 / 对比度 / 门禁判定）
    // ══════════════════════════════════════════════════════════
    // 归一化通道（0~255）：QML color 的 r/g/b 是 0~1 浮点，字符串走 NovaUtils 解析
    function channels(color) {
        if (color === null || color === undefined)
            return { r: 0, g: 0, b: 0 }
        if (typeof color === "string")
            return NovaUtils.colors.textToRgb(color)
        var r = color.r, g = color.g, b = color.b
        // 0~1 浮点归一化（Qt 6 color 类型语义）；已是 0~255 的对象原样保留
        if (r <= 1 && g <= 1 && b <= 1) {
            r = r * 255; g = g * 255; b = b * 255
        }
        return { r: r, g: g, b: b }
    }

    function luminance(color) {
        var c = root.channels(color)
        var r = c.r / 255, g = c.g / 255, b = c.b / 255
        var R = r <= 0.03928 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4)
        var G = g <= 0.03928 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4)
        var B = b <= 0.03928 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4)
        return 0.2126 * R + 0.7152 * G + 0.0722 * B
    }

    function contrast(a, b) {
        var la = root.luminance(a), lb = root.luminance(b)
        var hi = Math.max(la, lb), lo = Math.min(la, lb)
        return (hi + 0.05) / (lo + 0.05)
    }

    // 大号文本判定（WCAG：≥18.66px 且粗体，或 ≥24px）
    function isLargeText(pixelSize, bold) {
        if (pixelSize === undefined || pixelSize === null)
            return false
        return bold ? pixelSize >= 18.66 : pixelSize >= 24
    }

    function passesAA(fg, bg, large) {
        return root.contrast(fg, bg) >= (large ? root.aaLargeTextRatio : root.aaTextRatio)
    }

    function passesAAA(fg, bg, large) {
        return root.contrast(fg, bg) >= (large ? root.aaTextRatio : root.aaaTextRatio)
    }

    // 非文本对比（控件边界、图标、焦点环）
    function passesUI(fg, bg) {
        return root.contrast(fg, bg) >= root.uiComponentRatio
    }

    // ══════════════════════════════════════════════════════════
    // AA 兜底派生（不改品牌色，只在承载文字/边界时压到阈值）
    // ══════════════════════════════════════════════════════════
    function mix(a, b, k) {
        var ca = root.channels(a), cb = root.channels(b)
        var t = Math.max(0, Math.min(1, k))
        return Qt.rgba((ca.r * (1 - t) + cb.r * t) / 255,
                       (ca.g * (1 - t) + cb.g * t) / 255,
                       (ca.b * (1 - t) + cb.b * t) / 255, 1)
    }

    // 二分求「最小混合量」：把 color 朝 toward 推，直到与 bg 的对比度 ≥ target
    // 返回 -1 表示朝该方向无解（例如白底朝白推）
    function _minMix(color, toward, bg, target) {
        if (root.contrast(color, bg) >= target)
            return 0
        var lo = 0, hi = 1
        if (root.contrast(root.mix(color, toward, 1), bg) < target)
            return -1
        for (var i = 0; i < 22; ++i) {
            var mid = (lo + hi) / 2
            if (root.contrast(root.mix(color, toward, mid), bg) >= target)
                hi = mid
            else
                lo = mid
        }
        return hi
    }

    // 文本/图标色兜底：双向试探，取位移更小的一侧（品牌观感优先）
    function aaText(color, bg, target) {
        var t = target === undefined ? root.aaTextRatio : target
        if (root.contrast(color, bg) >= t)
            return color
        var kB = root._minMix(color, "#000000", bg, t)
        var kW = root._minMix(color, "#FFFFFF", bg, t)
        if (kB < 0 && kW < 0)
            return NovaUtils.colors.contrastColor(bg, "#FFFFFF", "#000000")
        if (kB < 0)
            return root.mix(color, "#FFFFFF", kW)
        if (kW < 0 || kB <= kW)
            return root.mix(color, "#000000", kB)
        return root.mix(color, "#FFFFFF", kW)
    }

    // 填充面兜底：底色上要压白字时单向压暗（保品牌色相，不翻成黑字）
    // 无解时（极亮底色）返回深色字方案的反转结果，仍保证可读
    function aaFill(fill, textOn, target) {
        var on = textOn === undefined ? "#FFFFFF" : textOn
        var t = target === undefined ? root.aaTextRatio : target
        if (root.contrast(on, fill) >= t)
            return fill
        var k = root._minMix(fill, "#000000", on, t)
        if (k >= 0)
            return root.mix(fill, "#000000", k)
        var kw = root._minMix(fill, "#FFFFFF", on, t)
        return kw >= 0 ? root.mix(fill, "#FFFFFF", kw) : fill
    }

    function contrastColor(bg, light, dark) {
        return NovaUtils.colors.contrastColor(bg,
            light === undefined ? "#FFFFFF" : light,
            dark === undefined ? "#000000" : dark)
    }

    // ══════════════════════════════════════════════════════════
    // 状态播报（WCAG 4.1.3 Status Messages）
    // ══════════════════════════════════════════════════════════
    // QML 的 Accessible.announce() 只能从 Item 作用域调用（附加属性绑定到调用方），
    // 单例无从调用 → 由 NovaLiveRegion（宿主根节点放一个）消费本状态并真正播报。
    property string lastAnnouncement: ""
    property int announcementCount: 0
    function notice(text) {
        var t = text === undefined || text === null ? "" : String(text)
        if (t === "")
            return
        root.lastAnnouncement = t
        root.announcementCount = root.announcementCount + 1
    }
    function clearAnnouncement() {
        root.lastAnnouncement = ""
    }

    // ══════════════════════════════════════════════════════════
    // 语义词汇表（供审计脚本与文档引用，避免各处魔法字符串）
    // ══════════════════════════════════════════════════════════
    readonly property var semanticColors: ["primary", "secondary", "accent",
                                           "positive", "negative", "warning", "info"]
    // 交互类组件必须具备的 a11y 契约（静态扫描脚本按此表核对）
    readonly property var requiredInteractive: ["role", "name", "focusable"]
}
