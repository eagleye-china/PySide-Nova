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

    readonly property var style: NovaTheme.textStyle(typography)

    font.family: NovaTheme.fontFamily
    font.pixelSize: style.size
    font.weight: style.weight
    font.letterSpacing: style.letterSpacing
    font.strikeout: strike
    font.italic: italic
    font.capitalization: upper ? Font.AllUppercase : Font.MixedCase

    lineHeight: style.lineHeight
    lineHeightMode: Text.FixedHeight

    color: muted ? NovaTheme.textMuted : NovaTheme.textColor
    wrapMode: Text.Wrap
    renderType: Text.NativeRendering
}
