// src/pyside_nova/qml/Nova/Controls/NovaDate.qml
// NovaDate 自研日历：单选/多选(multiple)/区间(range)、mask 格式化、最小值约束、
// 事件点(events)、todayBtn、导航范围限定（Qt 6 无内置日历——对标 Quasar QDate 全自研路径）
// 对标 Quasar QDate（23 props；Nova 收口核心 19 项，validator/yearsInMonthView 留痕见 PARITY）
// 契约统一：hint / error / readonly / disable
import QtQuick
import Nova.Services
import Nova.Design
import Nova.Behaviors

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.EditableText
    Accessible.name: a11yLabel !== "" ? a11yLabel : title
    Accessible.readOnly: readonly
    Accessible.focusable: !disable
    Accessible.focused: activeFocus
    activeFocusOnTab: !disable
    // 键盘路径：方向键按日/周步进（PageUp/PageDown 按月），Enter 提交当前值
    Keys.onPressed: function(ev) {
        if (root.disable || root.readonly) return
        var step = (ev.key === Qt.Key_Up) ? -7 : (ev.key === Qt.Key_Down) ? 7
                 : (ev.key === Qt.Key_Left) ? -1 : (ev.key === Qt.Key_Right) ? 1 : 0
        if (ev.key === Qt.Key_PageUp) { root.stepMonth(-1); ev.accepted = true; return }
        if (ev.key === Qt.Key_PageDown) { root.stepMonth(1); ev.accepted = true; return }
        if (step !== 0) { root.stepDay(step); ev.accepted = true }
    }
    function _a11yCursor() {
        if (_selected && _selected.length > 0) return _selected[0]
        return _today
    }
    function stepDay(n) {
        var cur = _a11yCursor()
        var d = new Date(cur.y, cur.m, cur.d + n)
        root.valueChanged(root._fmt(d.getFullYear(), d.getMonth(), d.getDate()))
    }
    function stepMonth(n) {
        var cur = _a11yCursor()
        // JS Date 自动归一化月末溢出（1/31 + 1 月 → 3/2/3，与日历视图语义一致）
        var d = new Date(cur.y, cur.m + n, cur.d)
        root.valueChanged(root._fmt(d.getFullYear(), d.getMonth(), d.getDate()))
    }

    // ── 值与格式（对标 QDate） ─────────────────────────────────
    property var modelValue: null        // 单选 mask 串；multiple: 数组；range: {from,to}
    property string mask: "YYYY/MM/DD"   // 对标 mask（默认与基线一致）
    property bool multiple: false
    property bool range: false
    property int firstDayOfWeek: 0       // 0=周日 … 6=周六（对标 first-day-of-week）
    property string title: ""            // 默认：当前选中（range=区间串）
    property string subtitle: ""         // 默认：当前视图年月
    property var minimal: null           // 最小可选日期（Date 或 mask 串）
    property string navigationMinYearMonth: ""   // "YYYY/MM"
    property string navigationMaxYearMonth: ""
    property bool todayBtn: false
    property bool noUnset: false         // 已选中再点不取消
    property bool required: false        // 至少选一个才能导航关闭（Nova：拒绝清空为 null）
    property var events: null            // 数组（mask 串）或 fn(date)->bool
    property color eventColor: NovaTheme.primary

    // ── 外观/状态 ──────────────────────────────────────────────
    property color tint: NovaTheme.primary
    property bool disable: false
    property bool readonly: false
    property string hint: ""
    property bool error: false
    property string errorMessage: ""
    readonly property bool hasError: error || errorMessage !== ""

    signal valueChanged(var value)       // 对标 update:model-value
    signal navigationChanged()           // 视图翻月（对标 @navigation）

    // ── 内部状态 ───────────────────────────────────────────────
    readonly property var _today: { var t = new Date(); return { y: t.getFullYear(), m: t.getMonth(), d: t.getDate() } }
    property int viewYear: _today.y
    property int viewMonth: _today.m     // 0-based
    property var _selected: []           // 内部：按 mask 串规范形（单选长度 0/1）
    property var _pendingRange: null     // range 模式第一击

    function _daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate() }

    // mask → 正则：捕获 YYYY/MM/DD
    function _maskRe(mask) {
        var re = ""
        for (var i = 0; i < mask.length;) {
            if (mask.startsWith("YYYY", i)) { re += "(\\d{4})"; i += 4 }
            else if (mask.startsWith("MM", i)) { re += "(\\d{2})"; i += 2 }
            else if (mask.startsWith("DD", i)) { re += "(\\d{2})"; i += 2 }
            else {
                var ch = mask[i]
                re += /[a-zA-Z0-9]/.test(ch) ? "\\d" : "[" + ch.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&") + "]"
                i++
            }
        }
        return new RegExp("^" + re + "$")
    }

    function _parse(str) {
        if (typeof str !== "string") return null
        var m = _maskRe(mask).exec(str)
        if (!m) return null
        return { y: parseInt(m[1], 10), m: parseInt(m[2], 10) - 1, d: parseInt(m[3], 10) }
    }

    function _fmt(y, m, d) {
        return NovaUtils.date.formatDate(new Date(y, m, d), mask)
    }

    function _fmtKey(md) { return md ? _fmt(md.y, md.m, md.d) : "" }

    function _sameDay(a, b) {
        return a && b && a.y === b.y && a.m === b.m && a.d === b.d
    }

    function _minMD() {
        if (minimal === null || minimal === undefined) return null
        if (minimal instanceof Date) return { y: minimal.getFullYear(), m: minimal.getMonth(), d: minimal.getDate() }
        return _parse(String(minimal))
    }

    function _dayEnabled(md) {
        if (disable || readonly) return false
        var mn = _minMD()
        if (mn && (md.y * 10000 + (md.m + 1) * 100 + md.d) < (mn.y * 10000 + (mn.m + 1) * 100 + mn.d)) return false
        if (typeof options === "function" && !options(new Date(md.y, md.m, md.d))) return false
        return true
    }

    // ── 值管道 ─────────────────────────────────────────────────
    onModelValueChanged: {
        var keys = []
        if (range && modelValue && typeof modelValue === "object") {
            var f = _parse(String(modelValue.from || ""))
            var t = _parse(String(modelValue.to || ""))
            if (f && t) {
                if ((f.y * 10000 + (f.m + 1) * 100 + f.d) > (t.y * 10000 + (t.m + 1) * 100 + t.d)) {
                    var tmp = f; f = t; t = tmp
                }
                keys = [_fmtKey(f), _fmtKey(t)]
            }
        } else if (multiple && Array.isArray(modelValue)) {
            for (var i = 0; i < modelValue.length; i++) {
                var p = _parse(String(modelValue[i]))
                if (p) keys.push(_fmtKey(p))
            }
        } else if (modelValue !== null && modelValue !== undefined && modelValue !== "") {
            var s = _parse(String(modelValue))
            if (s) keys = [_fmtKey(s)]
            else keys = []
        }
        root._selected = keys
        root._pendingRange = null
        if (keys.length > 0) {
            var v = _parse(keys[0])
            if (v) { root.viewYear = v.y; root.viewMonth = v.m }
        }
    }

    function _emit() {
        if (range) {
            var out = null
            if (_selected.length === 2)
                out = { from: _selected[0], to: _selected[1] }
            root.modelValue = out
            root.valueChanged(out)
        } else if (multiple) {
            root.modelValue = _selected.slice()
            root.valueChanged(_selected.slice())
        } else {
            var v = _selected.length > 0 ? _selected[0] : null
            root.modelValue = v
            root.valueChanged(v)
        }
    }

    function _toggleDay(md) {
        if (!_dayEnabled(md)) return false
        var key = _fmtKey(md)
        if (range) {
            if (_pendingRange === null) {
                _pendingRange = key
                _selected = [key]
            } else {
                var a = _pendingRange, b = key
                _selected = a <= b ? [a, b] : [b, a]
                _pendingRange = null
                _emit()
                return true
            }
            return true
        }
        var idx = _selected.indexOf(key)
        if (idx > -1) {
            if (noUnset || required) return false
            _selected.splice(idx, 1)
        } else {
            if (!multiple) _selected = []
            _selected.push(key)
        }
        _emit()
        return true
    }

    // 编程通道（测试/宿主）
    function selectDay(d) { return _toggleDay({ y: viewYear, m: viewMonth, d: d }) }
    function selectDate(y, m, d) { return _toggleDay({ y: y, m: m, d: d }) }
    function clearValue() {
        if (required) return false
        _selected = []
        _pendingRange = null
        _emit()
        return true
    }
    function navigateMonth(dir) {
        var y = viewYear, m = viewMonth + dir
        if (m < 0) { m = 11; y-- }
        if (m > 11) { m = 0; y++ }
        var nk = _pad4(y) + "/" + _pad2(m + 1)
        if (navigationMinYearMonth !== "" && nk < navigationMinYearMonth) return false
        if (navigationMaxYearMonth !== "" && nk > navigationMaxYearMonth) return false
        viewYear = y; viewMonth = m
        navigationChanged()
        return true
    }
    function _pad2(v) { return v < 10 ? "0" + v : String(v) }
    function _pad4(v) { return v < 10 ? "000" + v : (v < 100 ? "00" + v : (v < 1000 ? "0" + v : String(v))) }

    function isDaySelected(y, m, d) { return _selected.indexOf(_fmt(y, m, d)) > -1 }
    function isDayInRange(y, m, d) {
        if (!range || _selected.length !== 2) return false
        var k = _fmt(y, m, d)
        return k > _selected[0] && k < _selected[1]
    }
    function isDayEvent(y, m, d) {
        if (events === null || events === undefined) return false
        var k = _fmt(y, m, d)
        if (Array.isArray(events)) return events.indexOf(k) > -1
        if (typeof events === "function") return !!events(new Date(y, m, d))
        return false
    }

    // ── 视图派生 ───────────────────────────────────────────────
    readonly property string _subtitleText: subtitle !== "" ? subtitle
        : _pad4(viewYear) + "/" + _pad2(viewMonth + 1)
    readonly property string _titleText: {
        if (title !== "") return title
        if (_selected.length === 2) return _selected[0] + " - " + _selected[1]
        if (_selected.length === 1) return _selected[0]
        return "未选择"
    }
    // 周表头（firstDayOfWeek 0=日 … 6=一）
    readonly property var _weekHead: {
        var names = NovaUtils.dateLocale.zhCN ? NovaUtils.dateLocale.zhCN.daysShort
                                              : ["日","一","二","三","四","五","六"]
        var src = names && names.length === 7 ? names : ["日","一","二","三","四","五","六"]
        var out = []
        for (var i = 0; i < 7; i++) out.push(src[(firstDayOfWeek + i) % 7])
        return out
    }
    readonly property int _gridOffset: {
        var first = new Date(viewYear, viewMonth, 1).getDay()
        return (first - firstDayOfWeek + 7) % 7
    }
    readonly property int _daysCount: _daysInMonth(viewYear, viewMonth)

    // 视图导航范围（含月首/末日边界日）
    function _navLimit(key, isMin) {
        if (key === "") return true
        var cur = _pad4(viewYear) + "/" + _pad2(viewMonth + 1)
        return isMin ? cur >= key : cur <= key
    }

    implicitWidth: 292
    implicitHeight: 352

    // ── 皮肤 ───────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: NovaTheme.radiusM
        color: NovaTheme.surface
        border.width: 1
        border.color: root.hasError ? NovaTheme.negative : NovaTheme.outline
        opacity: root.disable ? 0.6 : 1
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        // 头部：箭头 + 年月
        Row {
            width: parent.width
            height: 30
            Item {
                width: 30; height: parent.height
                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    font.pixelSize: 20
                    color: root._navLimit(root.navigationMinYearMonth, true) && !root.disable
                           ? NovaTheme.textColor : NovaTheme.outline
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: !root.disable && root._navLimit(root.navigationMinYearMonth, true)
                    onClicked: root.navigateMonth(-1)
                }
            }
            Column {
                width: parent.width - 60
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root._subtitleText
                    color: root.tint
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root._titleText
                    color: NovaTheme.textColor
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }
            Item {
                width: 30; height: parent.height
                Text {
                    anchors.centerIn: parent
                    text: "›"
                    font.pixelSize: 20
                    color: root._navLimit(root.navigationMaxYearMonth, false) && !root.disable
                           ? NovaTheme.textColor : NovaTheme.outline
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: !root.disable && root._navLimit(root.navigationMaxYearMonth, false)
                    onClicked: root.navigateMonth(1)
                }
            }
        }

        // 周表头
        Row {
            width: parent.width
            Repeater {
                model: root._weekHead
                Item {
                    required property int index
                    readonly property string w: root._weekHead[index]
                    width: (parent ? parent.width : 272) / 7
                    height: 22
                    Text {
                        anchors.centerIn: parent
                        text: parent.w
                        color: NovaTheme.textMuted
                        font.pixelSize: 11
                    }
                }
            }
        }

        // 日网格
        Grid {
            id: dayGrid
            width: parent.width
            columns: 7
            spacing: 0
            property int cellW: width / 7
            // 前导空白
            Repeater {
                model: root._gridOffset
                Item { width: dayGrid.cellW; height: 34 }
            }
            Repeater {
                model: root._daysCount
                Item {
                    id: cell
                    required property int index
                    readonly property int day: index + 1
                    readonly property var md: ({ y: root.viewYear, m: root.viewMonth, d: day })
                    readonly property bool sel: root.isDaySelected(root.viewYear, root.viewMonth, day)
                    readonly property bool inRng: root.isDayInRange(root.viewYear, root.viewMonth, day)
                    readonly property bool isToday: root._today.y === root.viewYear
                                                    && root._today.m === root.viewMonth
                                                    && root._today.d === day
                    readonly property bool en: root._dayEnabled(md)
                    width: dayGrid.cellW
                    height: 34
                    Rectangle {
                        anchors.centerIn: parent
                        width: 30; height: 30; radius: 15
                        color: parent.sel ? (root.hasError ? NovaTheme.negative : root.tint)
                             : parent.inRng ? Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.14)
                             : "transparent"
                    }
                    Text {
                        anchors.centerIn: parent
                        text: parent.day
                        color: parent.sel ? NovaTheme.textOnPrimary
                             : !parent.en ? NovaTheme.outline
                             : NovaTheme.textColor
                        font.pixelSize: 13
                        font.weight: parent.isToday && !parent.sel ? Font.Bold : Font.Normal
                    }
                    // 今日描边
                    Rectangle {
                        visible: parent.isToday && !parent.sel
                        anchors.centerIn: parent
                        width: 30; height: 30; radius: 15
                        color: "transparent"
                        border.width: 1
                        border.color: root.tint
                    }
                    // 事件点
                    Rectangle {
                        visible: root.isDayEvent(root.viewYear, root.viewMonth, parent.day)
                                 && !parent.sel
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 27
                        width: 4; height: 4; radius: 2
                        color: root.eventColor
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: parent.en
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root._toggleDay(parent.md)
                    }
                }
            }
        }

        Item { width: 1; height: 1 }

        // 底部：todayBtn
        Row {
            visible: root.todayBtn
            width: parent.width
            height: 26
            Item { width: 1; height: 1 }
            Rectangle {
                height: 24
                width: todayText.implicitWidth + 16
                radius: 12
                color: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.12)
                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { id: todayText; text: "今天"; color: root.tint; font.pixelSize: 12 }
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: !root.disable
                    onClicked: {
                        root.viewYear = root._today.y
                        root.viewMonth = root._today.m
                        root.selectDay(root._today.d)
                    }
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

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
