// src/pyside_nova/qml/Nova/Controls/NovaBreadcrumbs.qml
// NovaBreadcrumbs 面包屑容器（对标 QBreadcrumbs）：在条目之间自动插分隔符；
// activeColor 语义对标 2.35.6 源码——作用于「中间的、未禁用」条目（最后一个为当前页不吃激活色）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.Grouping
    Accessible.name: a11yLabel

    // ── 默认槽：NovaBreadcrumbsEl 集合（宿主持有，手动布局） ──
    default property alias content: stash.data

    property string separator: "/"                 // 分隔符文本
    property color separatorColor: NovaTheme.textMuted
    property color activeTint: NovaTheme.primary   // 对标 active-color（tint 命名红线）
    property string gutter: "sm"                   // none/xs/sm/md/lg/xl → 0/4/8/16/24/48
    property string align: "left"                  // left/center/right
    property Component separatorDelegate: null     // 自定义分隔符模板（对标 separator 槽）

    // ⛔ separatorColor 的 Quasar 命名色字符串口径：Nova 用 color 类型直传
    // ⛔ to/href/active-class 系：无路由体系，条目点击统一 clicked 信号

    readonly property real _gap: gutter === "xs" ? 4
        : gutter === "md" ? 16 : gutter === "lg" ? 24
        : gutter === "xl" ? 48 : (gutter === "none" ? 0 : 8)

    // 激活条目判定：非最后一个、未禁用的 El（对标 q-breadcrumbs--last 反相）
    function isActiveEl(el) {
        var els = _els()
        if (els.length < 2) return false
        if (els[els.length - 1] === el) return false
        return !el.disable
    }

    function _els() {
        var out = []
        for (var i = 0; i < stash.children.length; i++) {
            var c = stash.children[i]
            if (c.isCrumbsSeparator !== true)
                out.push(c)
        }
        return out
    }

    // ── 分隔符池（重建时全量销毁再建） ────────────────────────
    property var _seps: []

    function _buildSep() {
        var o
        if (separatorDelegate !== null) {
            o = separatorDelegate.createObject(stash)
        } else {
            o = _sepComp.createObject(stash)
        }
        o.isCrumbsSeparator = true
        return o
    }

    Component {
        id: _sepComp
        Text {
            property bool isCrumbsSeparator: false
            text: root.separator
            color: root.separatorColor
            font.pixelSize: NovaTheme.fontM
        }
    }

    // ── 手动布局：条目 + 分隔符线性排布（避坑 30：显式 x/y/width） ──
    function _layout() {
        var els = _els()
        var n = els.length
        // 销毁旧分隔符（快照后删，避免边遍历边删）
        var olds = _seps
        _seps = []
        for (var d = 0; d < olds.length; d++)
            olds[d].destroy()
        if (n === 0) return

        var sepW = 0
        var needSeps = Math.max(0, n - 1)
        // 预估总宽（分隔符宽度建出后量测；文本分隔符可先量测文本宽）
        if (needSeps > 0) {
            for (var s = 0; s < needSeps; s++) {
                var sp = _buildSep()
                sp.width = sp.implicitWidth > 0 ? sp.implicitWidth
                           : (separatorDelegate !== null ? 16 : sepTextW())
                sp.height = root.height
                _seps.push(sp)
                sepW += sp.width + _gap * 2
            }
        }
        var totalW = 0
        for (var e = 0; e < n; e++)
            totalW += els[e].implicitWidth
        totalW += sepW
        var x0 = root.align === "center" ? Math.max(0, (root.width - totalW) / 2)
                : root.align === "right" ? Math.max(0, root.width - totalW) : 0
        var cx = x0
        var sepIdx = 0
        for (var i = 0; i < n; i++) {
            var el = els[i]
            el.crumbsRef = root
            el.width = el.implicitWidth
            el.height = el.implicitHeight
            el.x = cx
            el.y = (root.height - el.implicitHeight) / 2
            cx += el.implicitWidth
            if (i < n - 1 && sepIdx < _seps.length) {
                var sep = _seps[sepIdx]
                sep.x = cx + _gap
                sep.y = (root.height - sep.implicitHeight) / 2
                cx += sep.width + _gap * 2
                sepIdx++
            }
        }
    }

    function sepTextW() {
        return separator.length * 8 + 4
    }

    implicitWidth: 400
    implicitHeight: 28

    // 宿主容器（子项直接布局于此，可见、透明）
    Item {
        id: stash
        anchors.fill: parent
        onChildrenChanged: Qt.callLater(root._layoutGuarded)
    }

    property bool _building: false
    function _layoutGuarded() {
        if (_building) return
        Qt.callLater(_layout)
    }

    onAlignChanged: Qt.callLater(_layout)
    onWidthChanged: Qt.callLater(_layout)
    on_GapChanged: Qt.callLater(_layout)
    onSeparatorChanged: Qt.callLater(_layout)
    Component.onCompleted: Qt.callLater(_layout)
}
