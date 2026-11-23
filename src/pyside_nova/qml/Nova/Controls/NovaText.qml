// src/pyside_nova/qml/Nova/Controls/NovaText.qml
// NovaText 排版组件（对标 Quasar text-h1…caption + text-weight-* + text-muted/italic/strike/no-wrap 工具类）
// NovaText —— 排版文本：12 级字阶 1:1 取 NovaTheme.typeScale（rem×16→px、em→px 字距、真实行高）
// 用法：NovaText { typography: "h1"; text: "标题" } / NovaText { typography: "overline"; text: "OVERLINE" }
// 大写/小写/首字母大写走 QML 原生 font.capitalization（1:1 对标 text-uppercase/lowercase/capitalize）
import QtQuick
import Nova.Services

Text {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.StaticText
    Accessible.name: a11yLabel !== "" ? a11yLabel : text

    // ── 字阶（12 级，未知名回落 body2）────────────────────────
    property string typography: "body2"

    // ── 语义着色 ─────────────────────────────────────────────
    property bool muted: false        // 对标 text-grey / text-muted
    property bool strike: false       // 对标 text-strike
    property bool italic: false       // 对标 text-italic

    // 大写字阶（Quasar 的 overline 组件层带 uppercase；这里显式开关，不隐式改）
    property bool upper: false

    // 私有：排版令牌对象（0.16.2 前名为 `style`，与 Text.style 枚举撞名——RC1 冻结审查改名，
    // 保留 Text.style 的原生语义：outline/stroke 等渲染模式仍可用）
    readonly property var _style: NovaTheme.textStyle(typography)

    font.family: NovaTheme.fontFamily
    font.pixelSize: _style.size
    font.weight: _style.weight
    font.letterSpacing: _style.letterSpacing
    font.strikeout: strike
    font.italic: italic
    font.capitalization: upper ? Font.AllUppercase : Font.MixedCase

    lineHeight: _style.lineHeight
    lineHeightMode: Text.FixedHeight

    color: muted ? NovaTheme.textMuted : NovaTheme.textColor
    wrapMode: Text.Wrap
    renderType: Text.NativeRendering
}
