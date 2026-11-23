// src/pyside_nova/qml/Nova/Controls/NovaLayout.qml
// NovaLayout 布局骨架：四象限容器（header/footer/drawer/page），按子项类型自动归位 + push/overlay 双模式 + 断点自动收起（对标 QLayout）
// NovaLayout —— 页面布局骨架（对标 QLayout）
// 用法：将 NovaHeader / NovaFooter / NovaDrawer / NovaPage 作为直接子项声明，
//       NovaLayout 按类型扫描并安置到对应象限；其余子项进入页面区。
//       push（推挤）与 overlay（悬浮）由 NovaDrawer 自身属性决定；
//       窗口宽度小于 NovaDrawer.breakpoint 时自动转为 overlay 并收起。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    // 默认槽：子项先落入暂存区，扫描后按类型归位
    default property alias content: pageHost.data

    // ── 扫描结果（只读引用） ──
    readonly property Item headerItem: _headerItem
    readonly property Item footerItem: _footerItem
    readonly property Item drawerItem: _drawerItem
    readonly property Item pageArea: pageHost

    // ── 抽屉控制 API ──
    readonly property bool drawerOpen: _drawerItem ? _drawerItem.open : false
    function openDrawer()  { if (_drawerItem) _drawerItem.open = true }
    function closeDrawer() { if (_drawerItem) _drawerItem.open = false }
    function toggleDrawer() { if (_drawerItem) _drawerItem.open = !_drawerItem.open }

    // 页面区底色
    property color pageColor: NovaTheme.page

    property Item _headerItem: null
    property Item _footerItem: null
    property Item _drawerItem: null

    implicitWidth: 800
    implicitHeight: 600

    // ── 页面区：位于 header 之下、footer 之上；push 模式下左右让出抽屉宽度 ──
    Rectangle {
        id: pageHost
        objectName: "novaLayoutPageHost"
        anchors {
            top: root._headerItem ? root._headerItem.bottom : root.top
            bottom: root._footerItem ? root._footerItem.top : root.bottom
            left: root.left
            right: root.right
            leftMargin: root.pushLeft
            rightMargin: root.pushRight
        }
        color: root.pageColor

        // 动态追加子项时同样触发扫描归位
        onChildrenChanged: root._scan()
    }

    // push 模式让位宽度（抽屉自身 width 动画时自动跟随）
    readonly property real pushLeft: _drawerItem && _drawerItem.side === "left" && !_drawerItem.effectiveOverlay
                                     ? _drawerItem.width : 0
    readonly property real pushRight: _drawerItem && _drawerItem.side === "right" && !_drawerItem.effectiveOverlay
                                      ? _drawerItem.width : 0

    // ── 类型扫描与归位 ──
    function _scan() {
        var pending = []
        for (var i = 0; i < pageHost.children.length; i++)
            pending.push(pageHost.children[i])

        for (var j = 0; j < pending.length; j++) {
            var child = pending[j]

            if (child instanceof NovaHeader) {
                child.parent = root
                child.anchors.top = root.top
                child.anchors.left = root.left
                child.anchors.right = root.right
                _headerItem = child
            } else if (child instanceof NovaFooter) {
                child.parent = root
                child.anchors.bottom = root.bottom
                child.anchors.left = root.left
                child.anchors.right = root.right
                _footerItem = child
            } else if (child instanceof NovaDrawer) {
                child.parent = root
                child.anchors.top = _headerItem ? _headerItem.bottom : root.top
                child.anchors.bottom = _footerItem ? _footerItem.top : root.bottom
                if (child.side === "right")
                    child.anchors.right = root.right
                else
                    child.anchors.left = root.left
                child.z = 10
                _drawerItem = child
            } else if (child instanceof NovaPage) {
                child.anchors.fill = pageHost
            }
            // 其余子项留在 pageHost，由使用者自行布局
        }
    }

    Component.onCompleted: {
        _scan()
        _collapseIfBelow()
    }
    onChildrenChanged: _scan()

    // 断点收起策略：宿主宽度小于抽屉 breakpoint 时自动收起（autoCollapse）
    onWidthChanged: _collapseIfBelow()

    function _collapseIfBelow() {
        if (_drawerItem && _drawerItem.autoCollapse && width < _drawerItem.breakpoint)
            _drawerItem.open = false
    }
}
