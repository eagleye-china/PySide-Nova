// src/pyside_nova/qml/Nova/Services/NovaApp.qml
// NovaApp 窗口服务单例：全屏/最大化/最小化、窗口标题、可见与激活状态（对标 AppFullscreen + AppVisibility + Meta）
// NovaApp —— 窗口级命令式服务（对标 Quasar $q.fullscreen / $q.appVisible / $q.meta）
// 基线事实（npm quasar@2.35.5 源码核实）：
//     AppFullscreen: request() / exit() / toggle() / isActive / isCapable
//     AppVisibility: $q.appVisible（布尔），事件 app:visibility
//     Meta: $q.meta.set({ title }) —— 浏览器 document.title
// QML 语境映射：
//     document.title → 窗口 title；page URL / meta 标签 ⛔ 不适用；
//     全屏/最大化/最小化统一走 Window.visibility（QML 无 "浏览器全屏" 概念）。
// 窗口来源：NovaScreen.source（与 NovaOverlayHost 同一约定，单窗口跟踪）。
pragma Singleton
import QtQuick
import QtQuick.Window
import Nova.Services

QtObject {
    id: app

    // 目标窗口（Window / ApplicationWindow；Item 时取其 window）
    readonly property var targetWindow: {
        var s = NovaScreen.source
        if (!s)
            return null
        return s.contentItem !== undefined ? s : s.window
    }

    readonly property bool available: app.targetWindow !== null
    readonly property bool isCapable: app.available

    // ── 状态（只读派生：窗口被系统改动时自动跟随） ──────────────
    readonly property bool isFullscreen: app.available
                                         ? app.targetWindow.visibility === Window.FullScreen : false
    readonly property bool isMaximized: app.available
                                        ? app.targetWindow.visibility === Window.Maximized : false
    readonly property bool isMinimized: app.available
                                        ? app.targetWindow.visibility === Window.Minimized : false
    readonly property bool isVisible: app.available ? app.targetWindow.visible : false
    readonly property bool isActive: app.available ? app.targetWindow.active : false
    readonly property string title: app.available ? app.targetWindow.title : ""

    // ── 全屏（对标 $q.fullscreen.request / exit / toggle） ──────
    function request() {
        return app.setVisibility("fullscreen")
    }

    function exit() {
        return app.setVisibility(app._restoreTo)
    }

    function toggle() {
        return app.isFullscreen ? app.exit() : app.request()
    }

    // 退出全屏时的回落状态：进全屏前的窗口状态（默认 windowed）
    property string _restoreTo: "windowed"

    // ── 统一可见性入口：fullscreen | maximized | minimized | windowed ──
    function setVisibility(name) {
        if (!app.available) {
            console.warn("NovaApp: 无可用窗口，请先在根窗口执行 NovaScreen.source = window")
            return false
        }
        var map = {
            "fullscreen": Window.FullScreen,
            "maximized": Window.Maximized,
            "minimized": Window.Minimized,
            "windowed": Window.Windowed
        }
        if (map[name] === undefined) {
            console.warn("NovaApp: 未知窗口状态", name)
            return false
        }
        if (name === "fullscreen" && !app.isFullscreen) {
            app._restoreTo = app.isMaximized ? "maximized"
                           : app.isMinimized ? "windowed" : "windowed"
        }
        app.targetWindow.visibility = map[name]
        return true
    }

    // ── 标题（对标 $q.meta.set({ title })） ────────────────────
    function setTitle(text) {
        if (!app.available) {
            console.warn("NovaApp: 无可用窗口，setTitle 忽略")
            return false
        }
        app.targetWindow.title = text === undefined || text === null ? "" : String(text)
        return true
    }

    // ── 显隐（对标 $q.appVisible 的写入侧：少数场景需要主动隐藏窗口） ──
    function show() {
        if (!app.available)
            return false
        app.targetWindow.show()
        return true
    }

    function hide() {
        if (!app.available)
            return false
        app.targetWindow.hide()
        return true
    }

    // ── 快照（调试/测试） ─────────────────────────────────────
    function snapshot() {
        return {
            available: app.available,
            visibility: app.available ? app.targetWindow.visibility : -1,
            isFullscreen: app.isFullscreen,
            isMaximized: app.isMaximized,
            isMinimized: app.isMinimized,
            isVisible: app.isVisible,
            isActive: app.isActive,
            title: app.title
        }
    }
}
