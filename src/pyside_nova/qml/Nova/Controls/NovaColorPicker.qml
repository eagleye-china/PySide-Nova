// src/pyside_nova/qml/Nova/Controls/NovaColorPicker.qml
// NovaColorPicker 取色器：SV 色域盘 + 色相条 + 调色板(palette) + HEX 编辑 + footer 值显示
// 对标 Quasar QColor（16 props；Nova 收口核心 13 项，rgb/hsl 编辑器与 alpha 通道留痕见 PARITY）
// 契约统一：hint / error / readonly / disable
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 值（对标 QColor） ──────────────────────────────────────
    property var modelValue: null            // "#RRGGBB"；未选= null（基线语义：无默认值不产出）
    property string defaultValue: ""         // 对标 default-value（null 时显示占位）
    property string formatModel: "hex"       // hex | rgb（rgb 输出 "rgb(r,g,b)"）
    property var paletteColors: [            // 对标 palette（Item.palette 内建撞名，宪法坑位：改名留痕）
        "#f44336","#e91e63","#9c27b0","#673ab7","#3f51b5","#2196f3",
        "#03a9f4","#00bcd4","#009688","#4caf50","#8bc34a","#cddc39",
        "#ffc107","#ff9800","#ff5722","#795548","#607d8b","#9e9e9e"
    ]
    property bool noFooter: false
    property bool noHeader: false
    property bool flat: false                // 对标 flat/bordered（视觉令牌化）
    property bool bordered: false

    // ── 外观/状态 ──────────────────────────────────────────────
    property bool disable: false
    property bool readonly: false
    property string hint: ""
    property bool error: false
    property string errorMessage: ""
    readonly property bool hasError: error || errorMessage !== ""

    signal valueChanged(var value)

    // ── 内部 HSV 状态 ──────────────────────────────────────────
    property real _hue: 210                  // 0-360
    property real _sat: 85                   // 0-100
    property real _val: 90                   // 0-100
    property bool _touched: false

    function _clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)) }

    function _toHex(r, g, b) {
        function h2(v) { v = Math.round(_clamp(v, 0, 255)); return (v < 16 ? "0" : "") + v.toString(16) }
        return "#" + h2(r) + h2(g) + h2(b)
    }

    function _hsv2rgb(h, s, v) {
        // h 度 / s,v 百分制 → rgb 0-255（标准 HSV）
        var c = v / 100 * s / 100
        var x = c * (1 - Math.abs((h / 60) % 2 - 1))
        var m = v / 100 - c
        var r = 0, g = 0, b = 0
        if (h < 60)      { r = c; g = x }
        else if (h < 120){ r = x; g = c }
        else if (h < 180){ g = c; b = x }
        else if (h < 240){ g = x; b = c }
        else if (h < 300){ r = x; b = c }
        else             { r = c; b = x }
        return { r: Math.round((r + m) * 255), g: Math.round((g + m) * 255), b: Math.round((b + m) * 255) }
    }

    function _rgb2hsv(r, g, b) {
        var rr = r / 255, gg = g / 255, bb = b / 255
        var mx = Math.max(rr, gg, bb), mn = Math.min(rr, gg, bb), d = mx - mn
        var h = 0
        if (d > 0) {
            if (mx === rr) h = 60 * (((gg - bb) / d) % 6)
            else if (mx === gg) h = 60 * ((bb - rr) / d + 2)
            else h = 60 * ((rr - gg) / d + 4)
        }
        if (h < 0) h += 360
        return { h: h, s: mx === 0 ? 0 : d / mx * 100, v: mx * 100 }
    }

    function _parseHex(str) {
        var m = /^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{3})$/.exec(String(str).trim())
        if (!m) return null
        var s = m[1]
        if (s.length === 3) s = s[0] + s[0] + s[1] + s[1] + s[2] + s[2]
        return {
            r: parseInt(s.slice(0, 2), 16),
            g: parseInt(s.slice(2, 4), 16),
            b: parseInt(s.slice(4, 6), 16)
        }
    }

    function _out(rgb) {
        if (formatModel === "rgb")
            return "rgb(" + rgb.r + "," + rgb.g + "," + rgb.b + ")"
        return _toHex(rgb.r, rgb.g, rgb.b)
    }

    onModelValueChanged: {
        if (modelValue === null || modelValue === undefined || modelValue === "") {
            _touched = false
            return
        }
        var rgb = _parseHex(String(modelValue))
        if (!rgb) return
        var hsv = _rgb2hsv(rgb.r, rgb.g, rgb.b)
        root._hue = hsv.h; root._sat = hsv.s; root._val = hsv.v
        root._touched = true
    }

    function _emit() {
        var rgb = _hsv2rgb(_hue, _sat, _val)
        var out = _out(rgb)
        root.modelValue = out
        root.valueChanged(out)
    }

    function setHex(str) {
        var rgb = _parseHex(str)
        if (!rgb) return false
        var hsv = _rgb2hsv(rgb.r, rgb.g, rgb.b)
        root._hue = hsv.h; root._sat = hsv.s; root._val = hsv.v
        root._touched = true
        _emit()
        return true
    }
    function setHsv(h, s, v) {
        root._hue = _clamp(h, 0, 360); root._sat = _clamp(s, 0, 100); root._val = _clamp(v, 0, 100)
        root._touched = true
        _emit()
        return true
    }
    function currentHex() {
        var rgb = _hsv2rgb(_hue, _sat, _val)
        return _toHex(rgb.r, rgb.g, rgb.b)
    }

    implicitWidth: 248
    implicitHeight: 300

    Rectangle {
        anchors.fill: parent
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border.width: root.bordered ? 1 : 0
        border.color: NovaTheme.outline
        opacity: root.disable ? 0.6 : 1
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // 头部（当前色横幅）
        Rectangle {
            id: banner
            visible: !root.noHeader
            width: parent.width
            height: 34
            radius: NovaTheme.radiusS
            // 当前色实时着色（未选择回落 outline 占位）
            color: root._touched ? root.currentHex() : NovaTheme.outline
            Text {
                anchors.centerIn: parent
                text: root._touched ? root.currentHex()
                     : (root.defaultValue !== "" ? root.defaultValue : "未选择颜色")
                color: root._touched ? NovaTheme.textOnPrimary : NovaTheme.textMuted
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
        }

        // SV 色域盘
        Item {
            width: parent.width
            height: 150
            Canvas {
                id: svPad
                anchors.fill: parent
                Connections {
                    target: root
                    function on_HueChanged() { svPad.requestPaint() }
                }
                onPaint: {
                    var ctx = getContext("2d")
                    var hueRgb = root._hsv2rgb(root._hue, 100, 100)
                    // 底色 = 纯 hue
                    ctx.fillStyle = "rgb(" + hueRgb.r + "," + hueRgb.g + "," + hueRgb.b + ")"
                    ctx.fillRect(0, 0, width, height)
                    // 白 → 透明（水平）
                    var g1 = ctx.createLinearGradient(0, 0, width, 0)
                    g1.addColorStop(0, "rgba(255,255,255,1)")
                    g1.addColorStop(1, "rgba(255,255,255,0)")
                    ctx.fillStyle = g1
                    ctx.fillRect(0, 0, width, height)
                    // 透明 → 黑（垂直）
                    var g2 = ctx.createLinearGradient(0, 0, 0, height)
                    g2.addColorStop(0, "rgba(0,0,0,0)")
                    g2.addColorStop(1, "rgba(0,0,0,1)")
                    ctx.fillStyle = g2
                    ctx.fillRect(0, 0, width, height)
                }
            }
            // 光标
            Rectangle {
                x: root._sat / 100 * (svPad.width - 1) - 6
                y: (1 - root._val / 100) * (svPad.height - 1) - 6
                width: 12; height: 12; radius: 6
                color: "transparent"
                border.width: 2
                border.color: "white"
                opacity: root._touched ? 1 : 0
            }
            MouseArea {
                anchors.fill: parent
                enabled: !root.disable && !root.readonly
                function apply(m) {
                    var p = mapToItem(svPad, m.x, m.y)
                    root._sat = root._clamp(p.x / svPad.width * 100, 0, 100)
                    root._val = root._clamp((1 - p.y / svPad.height) * 100, 0, 100)
                    root._touched = true
                    root._emit()
                }
                onPressed: (m) => apply(m)
                onPositionChanged: (m) => { if (pressed) apply(m) }
            }
        }

        // 色相条
        Item {
            width: parent.width
            height: 16
            Canvas {
                id: hueBar
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    var g = ctx.createLinearGradient(0, 0, width, 0)
                    for (var i = 0; i <= 6; i++) {
                        var rgb = root._hsv2rgb(i * 60, 100, 100)
                        g.addColorStop(i / 6, "rgb(" + rgb.r + "," + rgb.g + "," + rgb.b + ")")
                    }
                    ctx.fillStyle = g
                    ctx.fillRect(0, 0, width, height)
                }
            }
            Rectangle {
                x: root._hue / 360 * (hueBar.width - 1) - 6
                anchors.verticalCenter: parent.verticalCenter
                width: 12; height: 20; radius: 6
                color: "transparent"
                border.width: 2
                border.color: "white"
                opacity: root._touched ? 1 : 0
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                enabled: !root.disable && !root.readonly
                function apply(m) {
                    var p = mapToItem(hueBar, m.x, m.y)
                    root._hue = root._clamp(p.x / hueBar.width * 360, 0, 360)
                    root._touched = true
                    svPad.requestPaint()
                    root._emit()
                }
                onPressed: (m) => apply(m)
                onPositionChanged: (m) => { if (pressed) apply(m) }
            }
        }

        // 调色板
        Grid {
            width: parent.width
            columns: 9
            spacing: 4
            Repeater {
                model: root.paletteColors
                Rectangle {
                    required property var modelData
                    width: (parent.width - 8 * 4) / 9
                    height: width
                    radius: width / 2
                    color: modelData
                    border.width: root._touched && root.currentHex() === String(modelData) ? 2 : 0
                    border.color: NovaTheme.textColor
                    opacity: root.disable ? 0.5 : 1
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -3
                        enabled: !root.disable && !root.readonly
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setHex(parent.modelData)
                    }
                }
            }
        }

        // HEX 输入 + footer
        Row {
            visible: !root.noFooter
            width: parent.width
            spacing: 6
            Rectangle {
                width: parent.width
                height: 28
                radius: NovaTheme.radiusS
                color: NovaTheme.background
                border.width: 1
                border.color: hexInput.activeFocus ? root.tint : NovaTheme.outline
                TextInput {
                    id: hexInput
                    anchors.fill: parent
                    anchors.margins: 6
                    enabled: !root.disable && !root.readonly
                    color: NovaTheme.textColor
                    font.pixelSize: 13
                    text: root._touched ? root.currentHex() : ""
                    onEditingFinished: if (text !== "") root.setHex(text)
                }
            }
        }
    }

    Text {
        visible: root.hint !== "" && !root.hasError
        x: 8; y: parent.height + 4
        text: root.hint
        color: NovaTheme.textMuted
        font.pixelSize: 11
    }
    Text {
        visible: root.hasError
        x: 8; y: parent.height + 4
        text: root.errorMessage !== "" ? root.errorMessage : "校验未通过"
        color: NovaTheme.negative
        font.pixelSize: 11
    }
}
