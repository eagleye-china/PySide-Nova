// src/pyside_nova/qml/Nova/Controls/NovaResizeObserver.qml
// NovaResizeObserver 尺寸观察：target（默认声明父项）尺寸变化 → debounce → resize(w,h)（对标 QResizeObserver）
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick

Item {   // 0 尺寸隐形根（QtObject 无默认属性，不能挂 Timer/Connections）
    id: root
    width: 0; height: 0; visible: false

    // ── 配置 ──────────────────────────────────────────────────
    property int debounce: 100
    property var target: null                    // null = Component.onCompleted 时取 parent
    property bool _touched: false                // 初次绑定不触发（观察器语义：只报变化）

    // ── 事件 ──────────────────────────────────────────────────
    signal resize(real width, real height)

    Component.onCompleted: {
        if (root.target === null)
            root.target = root.parent
    }

    onTargetChanged: {
        _touched = false
        if (target !== null) {
            _lw = target.width
            _lh = target.height
        }
    }

    property real _lw: 0
    property real _lh: 0

    Timer {
        id: deb
        interval: Math.max(1, root.debounce)
        onTriggered: {
            if (root.target === null) return
            root.resize(root.target.width, root.target.height)
        }
    }

    Connections {
        target: root.target
        function onWidthChanged() { root._check() }
        function onHeightChanged() { root._check() }
    }

    function _check() {
        if (root.target === null) return
        if (!root._touched) {                    // 绑定首帧只记录基线
            root._lw = root.target.width
            root._lh = root.target.height
            root._touched = true
            return
        }
        if (root.target.width !== root._lw || root.target.height !== root._lh) {
            root._lw = root.target.width
            root._lh = root.target.height
            root.debounce > 0 ? deb.restart() : root.resize(root.target.width, root.target.height)
        }
    }

    // ── 方法（对标 trigger） ──────────────────────────────────
    function trigger() {
        if (root.target !== null)
            root.resize(root.target.width, root.target.height)
    }
}
