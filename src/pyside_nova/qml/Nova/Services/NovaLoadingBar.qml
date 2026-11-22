// src/pyside_nova/qml/Nova/Services/NovaLoadingBar.qml
// NovaLoadingBar 命令式顶部进度服务单例：start/increment/stop（对标 LoadingBar 插件）
// 懒创建内部 NovaAjaxBar 挂 NovaOverlayHost（zTop 层）；无窗口时降级 no-op
pragma Singleton
import QtQuick
import Nova.Controls

QtObject {
    id: api

    property var _bar: null                      // 懒创建的 NovaAjaxBar 实例

    function _ensure() {
        if (api._bar !== null)
            return api._bar
        var comp = Qt.createComponent("qrc:/pyside_nova/qml/Nova/Controls/NovaAjaxBar.qml")
        var bar = comp.createObject(null)
        if (!bar) {
            console.warn("NovaLoadingBar: 进度条创建失败 -", comp.errorString())
            return null
        }
        if (!NovaOverlayHost.attach(bar, NovaTheme.zTop)) {
            bar.destroy()
            return null
        }
        bar.anchors.left = bar.parent.left
        bar.anchors.right = bar.parent.right
        bar.anchors.top = bar.parent.top
        api._bar = bar
        bar.Component.onDestruction.connect(function() { api._bar = null })
        return bar
    }

    // ── 命令式 API（对标 LoadingBar 插件） ─────────────────────
    function start(opts) {
        var bar = api._ensure()
        if (!bar) return
        if (opts && typeof opts === "object") {
            if (opts.position !== undefined) bar.position = opts.position
            if (opts.size !== undefined) bar.size = opts.size
            if (opts.reverse !== undefined) bar.reverse = opts.reverse
        }
        bar.start()
    }

    function increment(size) {
        if (api._bar !== null)
            api._bar.increment(size)
    }

    function stop() {
        if (api._bar !== null)
            api._bar.stop()
    }
}
