// src/pyside_nova/qml/Nova/Controls/NovaField.qml
// NovaField 表单容器壳：浮动 label + hint/error/counter 底行 + 样式四型 + 校验引擎
// 对标 Quasar QField（use-field 29 props + use-validate 7 props）+ NovaInput/NovaSelect 共用壳
// 契约统一（二期 Sprint A）：label / hint / error / readonly / disable / clearable / rules
// 命名红线：基调色 tint（对应 QField 的 color）；QML 无 `for` 保留字 → 辅助名用 name
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.Grouping
    Accessible.name: a11yLabel !== "" ? a11yLabel : label

    // ── 默认槽：控件内容区（NovaInput 放 TextInput、NovaSelect 放展示层） ──
    default property alias control: controlHost.data

    // ── 内容（对标 use-field content 组） ──────────────────────
    property string label: ""
    property bool stackLabel: false          // label 恒浮起（对标 stack-label）
    property string hint: ""
    property bool hideHint: false
    property string prefix: ""
    property string suffix: ""
    property bool counter: false             // 是否显示计数（对标 counter）
    property string counterText: ""          // 计数内容（子类绑定，如 "12/40"）
    property bool labelSlot: false           // 对标 label-slot（自定义 label 由默认槽承接）

    // ── 外观（对标 use-field style 组） ────────────────────────
    property color tint: NovaTheme.primary   // 基调色（对标 color）
    property color bgColor: NovaTheme.surfaceAlt   // 对标 bg-color
    property color labelColor: NovaTheme.textMuted // 对标 label-color
    property bool loading: false
    // 样式四型（互斥，优先级 outlined > standout > filled > borderless；默认 filled）
    property bool filled: false
    property bool outlined: false
    property bool standout: false
    property bool borderless: false
    property bool rounded: false
    property bool square: false
    property bool dense: false
    property bool hideBottomSpace: false     // 对标 hide-bottom-space
    property bool bottomSlots: false         // 对标 bottom-slots（预留下行锚点）

    // ── 状态 ──────────────────────────────────────────────────
    property bool disable: false
    property bool readonly: false
    property bool autofocus: false
    property string name: ""                 // 对标 for（QML 保留字改名）
    property bool clearable: false
    property string clearIcon: "mdi:close-circle"
    // 子类接线点：控件值与焦点态（用于浮动 label 判定与校验）
    property var value: null
    property bool controlFocused: false
    // 多行控件覆盖控件区高度（-1 = 用默认）
    property real customControlH: -1

    // ── 校验（对标 use-validate） ──────────────────────────────
    property bool error: false               // 外部强置错误态
    property string errorMessage: ""
    property bool noErrorIcon: false
    property var rules: []                   // fn(v)->true|msg 或内置字符串规则
    property bool reactiveRules: false       // Nova 增强：rules 变化即重校验
    property bool lazyRules: false           // true = 首次失焦后才启用实时校验

    readonly property bool hasError: error || _ruleError
    readonly property string effectiveError: errorMessage !== "" ? errorMessage : _ruleMessage
    readonly property bool focused: controlFocused

    signal cleared()
    signal validated(bool ok)

    // ── 布局派生 ──────────────────────────────────────────────
    readonly property real _controlH: customControlH > 0 ? customControlH : (dense ? 28 : 40)
    readonly property real _labelH: 18
    readonly property real _bottomH: 18
    readonly property string _style: outlined ? "outlined"
                                    : standout ? "standout"
                                    : borderless ? "borderless" : "filled"
    readonly property bool _hasValue: value !== null && value !== undefined && value !== ""
    readonly property bool _floated: stackLabel || controlFocused || _hasValue || label === ""
    readonly property bool _showBottom: !hideBottomSpace &&
        (((!hideHint && hint !== "") && !hasError) || hasError || (counter && counterText !== ""))
    implicitWidth: 240
    implicitHeight: _controlH + (_floated && label !== "" && !labelSlot ? _labelH + 2 : 0)
                    + (_showBottom ? _bottomH + 3 : 0)

    // ── 校验引擎（对标 use-validate 语义） ─────────────────────
    property bool _ruleError: false
    property string _ruleMessage: ""
    property bool _wasValidated: false       // lazyRules 下是否已"激活"校验

    // 内置字符串规则（对标 Quasar 规则字符串子集）：required / minlen(n) / maxlen(n) / len(n) / email
    function _builtinRule(expr, v) {
        var s = String(expr)
        if (s === "required")
            return (v !== null && v !== undefined && v !== "" && (!Array.isArray(v) || v.length > 0))
                || "必填项"
        var m = s.match(/^(minlen|maxlen|len)\((\d+)\)$/)
        if (m) {
            var n = parseInt(m[2])
            var len = v === null || v === undefined ? 0 : String(v).length
            if (m[1] === "minlen") return len >= n || `长度不得少于 ${n} 个字符`
            if (m[1] === "maxlen") return len <= n || `长度不得超过 ${n} 个字符`
            return len === n || `长度须为 ${n} 个字符`
        }
        if (s === "email")
            return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(v)) || "邮箱格式不正确"
        return true
    }

    function _runValidate() {
        var v = root.value
        var list = root.rules
        if (list === undefined || list === null) list = []
        var arr = Array.isArray(list) ? list : [list]
        for (var i = 0; i < arr.length; i++) {
            var r = arr[i]
            var res
            if (typeof r === "string")
                res = root._builtinRule(r, v)
            else if (typeof r === "function")
                res = r(v)
            else
                continue
            if (res !== true && res !== undefined) {
                root._ruleError = true
                root._ruleMessage = res === false ? "校验未通过" : String(res)
                root.validated(false)
                return false
            }
        }
        if (root._ruleError) {
            root._ruleError = false
            root._ruleMessage = ""
            root.validated(true)
        }
        return true
    }

    // 公开校验 API（对标 QInput.validate / resetValidation）
    function validate() {
        root._wasValidated = true
        return root._runValidate()
    }

    function resetValidation() {
        root._ruleError = false
        root._ruleMessage = ""
        root._wasValidated = false
        root.validated(true)
    }

    onValueChanged: if (!lazyRules || _wasValidated) _runValidate()
    onControlFocusedChanged: if (!controlFocused && !_wasValidated) {
        _wasValidated = true           // 首次失焦：lazyRules 激活
        if (lazyRules) _runValidate()
    }
    onRulesChanged: if (reactiveRules && _wasValidated) _runValidate()

    // ── 清空（对标 clearable） ─────────────────────────────────
    function clear() {
        if (!clearable || disable || readonly) return
        root.cleared()   // 子类负责真正的清值（field 不拥有值）
    }

    // ── 视觉 ──────────────────────────────────────────────────
    readonly property bool _isBoxed: _style === "outlined" || _style === "filled" || _style === "standout"
    readonly property real _bodyRadius: square ? 0 : (rounded ? _controlH / 2 : NovaTheme.radiusM)
    readonly property color _border: hasError ? NovaTheme.negative
                          : (controlFocused && _style !== "filled") ? tint
                          : _style === "standout" ? NovaTheme.outline
                          : NovaTheme.outline
    readonly property color _bodyColor: _style === "filled" || _style === "standout"
        ? (controlFocused && !disable ? Qt.darker(bgColor, 1.04) : bgColor)
        : "transparent"

    Rectangle {
        id: body
        y: (root._floated && root.label !== "" && !root.labelSlot) ? root._labelH + 2 : 0
        width: root.width
        height: root._controlH
        radius: root._bodyRadius
        color: root._bodyColor
        border.width: root._style === "outlined" || root._style === "standout" ? 1.2 : 0
        border.color: root._border
        opacity: root.disable ? 0.55 : 1

        // 悬浮 label（filled/outlined 浮起态：小字压在顶边）
        Text {
            visible: root._floated && root.label !== "" && !root.labelSlot
                     && root._style !== "borderless"
            x: 12
            y: -9
            text: root.label
            color: root.hasError ? NovaTheme.negative
                 : root.controlFocused ? root.tint : root.labelColor
            font.family: NovaTheme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
        }
        // borderless 模式 label 常驻在控件区上方
        Text {
            visible: root.label !== "" && root._style === "borderless"
            x: 0; y: -16
            text: root.label
            color: root.hasError ? NovaTheme.negative : root.labelColor
            font.family: NovaTheme.fontFamily
            font.pixelSize: 11
        }

        // 底部强调条（聚焦/错误反馈；filled/outlined/standout 用）
        Rectangle {
            anchors { bottom: parent.bottom; bottomMargin: root._style === "outlined" ? -1 : 0 }
            x: 8
            width: parent.width - 16
            height: 2
            radius: 1
            visible: root._style !== "borderless" && !root.disable
            color: root.hasError ? NovaTheme.negative
                 : root.controlFocused ? root.tint : "transparent"
            Behavior on color { ColorAnimation { duration: 180 } }
        }

        Row {
            id: row
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 10
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.prefix !== ""
                text: root.prefix
                color: NovaTheme.textMuted
                font.family: NovaTheme.fontFamily
                font.pixelSize: root.dense ? 12 : 14
            }

            // 非浮动态 label 占位（placeholder 语义）
            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: !root._floated && root.label !== ""
                text: root.label
                color: root.labelColor
                font.family: NovaTheme.fontFamily
                font.pixelSize: root.dense ? 12 : 14
            }

            Item {
                id: controlHost
                // CARF 基础组件 Robustness：prefix/label/suffix 为超长文本时，
                // 其 Row 内 Text 的隐式宽度会反噬本宽度计算产生负几何（布局塌陷）。
                // 钳到非负——对外公开属性签名不变，仅内部几何出口守护。
                width: Math.max(0, parent.width - x - (suffixText.visible ? suffixText.width + 6 : 0)
                     - (clearBtn.visible ? clearBtn.width + 4 : 0)
                     - (loadingSpin.visible ? loadingSpin.width + 4 : 0))
                height: parent.height
                clip: true
            }

            Text {
                id: suffixText
                anchors.verticalCenter: parent.verticalCenter
                visible: root.suffix !== ""
                text: root.suffix
                color: NovaTheme.textMuted
                font.family: NovaTheme.fontFamily
                font.pixelSize: root.dense ? 12 : 14
            }

            // loading 转圈（对标 QField loading）
            Canvas {
                id: loadingSpin
                anchors.verticalCenter: parent.verticalCenter
                visible: root.loading
                width: 14; height: 14
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = root.tint
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    ctx.arc(7, 7, 5, 0, Math.PI * 1.25)
                    ctx.stroke()
                }
                RotationAnimation on rotation {
                    from: 0; to: 360
                    duration: 850; loops: Animation.Infinite
                    running: root.loading
                }
                Connections {
                    target: root
                    function onTintChanged() { loadingSpin.requestPaint() }
                }
            }

            // 清空按钮（对标 clearable/clear-icon）
            Item {
                id: clearBtn
                anchors.verticalCenter: parent.verticalCenter
                visible: root.clearable && root._hasValue && !root.disable && !root.readonly
                width: 18; height: 18

                MouseArea {
                    id: clearMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !root.disable && !root.readonly
                    onClicked: root.clear()
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 16; height: 16; radius: 8
                    color: clearMa.containsMouse
                           ? Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.18) : "transparent"
                }
                // 十字清除（纯绘制，无网络依赖）
                Canvas {
                    anchors.centerIn: parent
                    width: 10; height: 10
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = NovaTheme.textMuted
                        ctx.lineWidth = 1.6
                        ctx.beginPath()
                        ctx.moveTo(2, 2); ctx.lineTo(8, 8)
                        ctx.moveTo(8, 2); ctx.lineTo(2, 8)
                        ctx.stroke()
                    }
                }
            }
        }
    }

    // ── 底行：hint / error / counter（对标 bottom-slots 三位） ──
    Text {
        visible: root._showBottom
        x: 12
        y: body.y + body.height + 3
        width: root.width - 24
        height: root._bottomH
        text: root.hasError ? root.effectiveError : root.hint
        color: root.hasError ? NovaTheme.negative : NovaTheme.textMuted
        font.family: NovaTheme.fontFamily
        font.pixelSize: 11
        elide: Text.ElideRight
        maximumLineCount: 1
    }
    Text {
        visible: root._showBottom && root.counter && root.counterText !== ""
        anchors.right: root.right
        anchors.rightMargin: 12
        y: body.y + body.height + 3
        height: root._bottomH
        text: root.counterText
        color: NovaTheme.textMuted
        font.family: NovaTheme.fontFamily
        font.pixelSize: 11
    }
}
