// src/pyside_nova/qml/Nova/Controls/NovaTree.qml
// NovaTree 树控件（对标 QTree）
// 受控模式（坑位 22）：expanded/ticked/selected 均不自写，只 emit 由宿主写回
// 勾选策略：none（仅自身）/ strict（上下级联动+半选）/ lazy（仅向下联动已加载层）
// 懒加载：lazy 节点首次展开 emit lazyLoad(node, done)，宿主 done(子节点数组)
import QtQuick
import Nova.Controls
import Nova.Services

Rectangle {
    id: root

    property var nodes: []                  // {label,icon,children,lazy,expandable,disabled,tickable,tickStrategy,caption}
    property string nodeKey: ""             // 键字段名；空则自动生成路径键 "0.1.2"
    property var expanded: []               // 已展开 key 数组（受控）
    property var selected: null             // 选中节点 key 或 null（受控）
    property var ticked: []                 // 勾选 key 数组（受控）
    property string tickStrategy: "none"    // 树级默认策略：none | strict | lazy
    property string filter: ""
    property var filterMethod: null         // function(node) -> bool
    property bool defaultExpandAll: false   // 默认全展开（不影响受控数组）
    property bool dense: false

    signal updateExpanded(var keys)
    signal updateSelected(var key)
    signal updateTicked(var keys)
    signal nodeClicked(var node, string key)
    signal lazyLoad(var node, var done)

    radius: NovaTheme.radiusL
    color: NovaTheme.surface
    border.width: 1
    border.color: NovaTheme.outline
    implicitWidth: 320
    implicitHeight: Math.max(80, treeCol.height + NovaTheme.spacingM * 2)

    // 内部懒加载子节点仓库（done 回调后整体重赋以触发索引重建）
    property var _lazyStore: ({})
    function _resolveLazy(key, children) {
        var next = Object.assign({}, _lazyStore)
        next[key] = children
        _lazyStore = next
    }

    // ── 索引：key → {node, parent, children[]} ──────────────
    function _keyOf(node, parentKey, i) {
        if (nodeKey && node[nodeKey] !== undefined)
            return String(node[nodeKey])
        return (parentKey === "" ? "" : parentKey + ".") + i
    }

    function _kidsOf(node, key) {
        if (node.lazy)
            return _lazyStore[key] || []
        return node.children || []
    }

    function _isExpandable(node, key) {
        if (node.expandable !== undefined)
            return node.expandable === true
        return node.lazy === true || (node.children !== undefined && node.children.length > 0)
    }

    function _strategyOf(node) {
        return node.tickStrategy || tickStrategy
    }

    function _buildIndexInto(list, parentKey, map) {
        for (var i = 0; i < list.length; i++) {
            var n = list[i]
            var k = _keyOf(n, parentKey, i)
            var kids = _kidsOf(n, k)
            map[k] = { node: n, parent: parentKey, children: [] }
            for (var j = 0; j < kids.length; j++) {
                map[k].children.push(_keyOf(kids[j], k, j))
            }
            // 递归全部已加载子节点（含懒加载回填层）
            _buildIndexInto(kids, k, map)
        }
        return map
    }

    // 派生数据版本号（显式失效信号，节点渲染绑定读它保刷新）
    property int _rev: 0

    // 索引：key → {node, parent, children[]}（显式失效：坑位 28 ——
    // 函数内读取 _lazyStore 的绑定依赖跟踪不可靠，nodes/懒加载回填后手动重建）
    property var _index: ({})
    property var _visibleKeys: null

    onNodesChanged: _refreshDerived()
    on_LazyStoreChanged: _refreshDerived()
    onFilterChanged: _refreshDerived()
    onFilterMethodChanged: _refreshDerived()
    Component.onCompleted: _refreshDerived()

    function _refreshDerived() {
        _index = _buildIndexInto(nodes, "", ({}))
        _visibleKeys = _computeVisible()
        _rev++
    }

    function getNodeByKey(key) {
        return _index[key] ? _index[key].node : null
    }

    // ── 展开 ────────────────────────────────────────────────
    function isExpanded(key) {
        return defaultExpandAll || expanded.indexOf(key) !== -1
    }

    function setExpanded(key, on) {
        var next = expanded.slice()
        var at = next.indexOf(key)
        if (on && at === -1)
            next.push(key)
        if (!on && at !== -1)
            next.splice(at, 1)
        updateExpanded(next)
        return next
    }

    function expandAll() {
        var out = []
        for (var k in _index)
            if (_isExpandable(_index[k].node, k))
                out.push(k)
        updateExpanded(out)
        return out
    }

    function collapseAll() {
        updateExpanded([])
        return []
    }

    // ── 选择（单选，受控） ──────────────────────────────────
    function selectNode(key) {
        var next = (selected === key) ? null : key
        updateSelected(next)
        return next
    }

    // ── 勾选（受控 + 级联） ─────────────────────────────────
    function isTicked(key) {
        return ticked.indexOf(key) !== -1
    }

    // 半选：strict 策略下有后代被勾而自身未勾
    function tickHalf(key) {
        if (!_index[key])
            return false
        if (isTicked(key) || _strategyOf(_index[key].node) !== "strict")
            return false
        return _anyDescTicked(key)
    }

    function _anyDescTicked(key) {
        var kids = _index[key] ? _index[key].children : []
        for (var i = 0; i < kids.length; i++) {
            if (ticked.indexOf(kids[i]) !== -1 || _anyDescTicked(kids[i]))
                return true
        }
        return false
    }

    function setTicked(key, on) {
        if (!_index[key])
            return ticked
        var set = ticked.slice()
        var strat = _strategyOf(_index[key].node)
        // 向下级联（strict/lazy 均只作用已加载层）
        var stack = [key]
        while (stack.length) {
            var k = stack.pop()
            var at = set.indexOf(k)
            if (on && at === -1) set.push(k)
            if (!on && at !== -1) set.splice(at, 1)
            if (strat !== "none")
                stack = stack.concat(_index[k].children)
        }
        // 向上级联（仅 strict）
        if (strat === "strict") {
            var p = _index[key].parent
            while (p !== "") {
                var kids = _index[p].children
                var all = kids.length > 0
                for (var i = 0; i < kids.length; i++)
                    if (set.indexOf(kids[i]) === -1) { all = false; break }
                var pat = set.indexOf(p)
                if (all && pat === -1) set.push(p)
                if (!all && pat !== -1) set.splice(pat, 1)
                p = _index[p].parent
            }
        }
        updateTicked(set)
        return set
    }

    function toggleTicked(key) {
        return setTicked(key, !isTicked(key))
    }

    // 展开请求（懒节点首次展开先请求宿主，done 后回填并展开）
    function tryExpand(key, open) {
        var node = getNodeByKey(key)
        if (!node)
            return expanded
        if (open === undefined)
            open = !isExpanded(key)
        if (open && node.lazy && _lazyStore[key] === undefined) {
            lazyLoad(node, function (children) {
                _resolveLazy(key, children || [])
                setExpanded(key, true)
            })
            return expanded
        }
        return setExpanded(key, open)
    }

    // ── 过滤 ────────────────────────────────────────────────
    // 可见 key 集合：自身或任一后代匹配；null = 未启用过滤（由 _refreshDerived 显式刷新）

    function _nodeMatches(n) {
        if (filterMethod)
            return filterMethod(n)
        var f = String(filter).toLowerCase()
        return String(n.label || "").toLowerCase().indexOf(f) !== -1
    }


    function _computeVisible() {
        if (!filter)
            return null
        var out = {}
        // 递归收集：自身或后代匹配的节点及其祖先链全部可见
        var walk = function (list, parentKey) {
            var any = false
            for (var i = 0; i < list.length; i++) {
                var n = list[i]
                var k = _keyOf(n, parentKey, i)
                var self = _nodeMatches(n)
                var desc = walk(n.children || [], k)
                if (self || desc) {
                    out[k] = true
                    any = true
                }
            }
            return any
        }
        walk(nodes, "")
        return out
    }

    // ══════════════════════════════════════════════════════════
    Column {
        id: treeCol
        x: NovaTheme.spacingM
        y: NovaTheme.spacingM
        width: parent.width - NovaTheme.spacingM * 2
        spacing: 0

        Repeater {
            model: root.nodes.length
            Loader {
                id: nodeLoader
                required property int index
                width: parent.width
                sourceComponent: nodeComp
                property var parentNode: root.nodes[index]
                property string parentKey: ""
                property int depth: 0
            }
        }
    }

    // 递归节点组件（坑位 25 衍生：组件内一律经 parent 访问宿主 Loader 属性，
    // 不引用外层 nodeLoader id —— 递归实例会错误绑定到顶层 Loader）
    Component {
        id: nodeComp

        Column {
            id: nodeRoot

            property var ld: parent
            property var nd: ld.parentNode
            property string key: root._keyOf(nd, ld.parentKey, ld.index)
            // _rev 引用保刷新：懒加载回填/宿主写回后重评（坑位 28 双保险）
            property var kids: { root._rev; root._kidsOf(nd, key) }
            property bool expandable: { root._rev; root._isExpandable(nd, key) }
            property bool open: { root._rev; root.isExpanded(key) }
            property string strat: root._strategyOf(nd)
            property bool tickable: nd.tickable !== false && strat !== "none"
            property bool tickOn: { root._rev; tickable && (root.isTicked(key) || (strat === "strict" && kids.length > 0 && _allKidsOn())) }
            property bool half: { root._rev; tickable && !tickOn && root.tickHalf(key) }
            property bool shown: { root._rev; root._visibleKeys === null || root._visibleKeys[key] === true }
            property bool sel: { root._rev; root.selected === key }

            width: ld.width
            function _allKidsOn() {
                for (var i = 0; i < kids.length; i++) {
                    var ck = root._keyOf(kids[i], key, i)
                    if (!root.isTicked(ck))
                        return false
                }
                return true
            }

            height: shown ? (root.dense ? 32 : 40) : 0

            Rectangle {
                width: parent.width
                height: parent.height
                radius: NovaTheme.radiusS
                color: nodeRoot.sel ? Qt.rgba(NovaTheme.primary.r, NovaTheme.primary.g, NovaTheme.primary.b, 0.10)
                                    : "transparent"

                Row {
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                    leftPadding: nodeRoot.ld.depth * 20

                    // 展开箭头
                    Item {
                        width: nodeRoot.expandable ? 24 : 20
                        height: parent.height
                        Text {
                            anchors.centerIn: parent
                            visible: nodeRoot.expandable
                            text: nodeRoot.open ? "▾" : "▸"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontS
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: nodeRoot.expandable && !nodeRoot.nd.disabled
                            onClicked: root.tryExpand(nodeRoot.key)
                        }
                    }

                    // 勾选框
                    Rectangle {
                        width: nodeRoot.tickable ? 24 : 0
                        height: parent.height
                        visible: nodeRoot.tickable
                        Rectangle {
                            width: 16; height: 16; radius: 3
                            anchors.centerIn: parent
                            color: nodeRoot.tickOn ? NovaTheme.primary : "transparent"
                            border.width: 1
                            border.color: nodeRoot.tickOn ? NovaTheme.primary : NovaTheme.textMuted
                            Text {
                                anchors.centerIn: parent
                                visible: nodeRoot.tickOn
                                text: "✓"; color: NovaTheme.textOnPrimary
                                font.pixelSize: 11; font.bold: true
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: nodeRoot.half && !nodeRoot.tickOn
                                text: "–"; color: NovaTheme.primary
                                font.pixelSize: 12; font.bold: true
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: !nodeRoot.nd.disabled
                            onClicked: root.toggleTicked(nodeRoot.key)
                        }
                    }

                    // 图标
                    NovaIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: nodeRoot.nd.icon !== undefined
                        icon: nodeRoot.nd.icon || ""
                        size: 18
                        color: nodeRoot.sel ? NovaTheme.primary : NovaTheme.textMuted
                    }

                    // 文案
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: nodeRoot.nd.label || ""
                            color: nodeRoot.nd.disabled ? NovaTheme.textMuted
                                    : nodeRoot.sel ? NovaTheme.primary : NovaTheme.textColor
                            font.pixelSize: root.dense ? NovaTheme.fontS : NovaTheme.fontM
                            font.strikeout: nodeRoot.nd.disabled === true
                        }
                        Text {
                            visible: nodeRoot.nd.caption !== undefined
                            text: nodeRoot.nd.caption || ""
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !nodeRoot.nd.disabled
                    onClicked: {
                        root.nodeClicked(nodeRoot.nd, nodeRoot.key)
                        root.selectNode(nodeRoot.key)
                    }
                }
            }

            // 子节点（递归）
            Repeater {
                model: nodeRoot.open && nodeRoot.shown ? nodeRoot.kids.length : 0
                Loader {
                    required property int index
                    width: parent.width
                    sourceComponent: nodeComp
                    property var parentNode: nodeRoot.kids[index]
                    property string parentKey: nodeRoot.key
                    property int depth: nodeRoot.ld.depth + 1
                }
            }
        }
    }
}
