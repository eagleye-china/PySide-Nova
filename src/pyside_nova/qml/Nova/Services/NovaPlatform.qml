// src/pyside_nova/qml/Nova/Services/NovaPlatform.qml
// NovaPlatform 平台信息服务单例：操作系统判定、触摸能力、移动/桌面/WebAssembly 分流（对标 Platform 插件）
// NovaPlatform —— 平台事实查询（对标 Quasar $q.platform）
// 基线事实（npm quasar@2.35.5 Platform 源码核实）：
//     is.windows / is.mac / is.linux / is.ios / is.android / is.mobile / is.desktop /
//     has.touch / has.webAuthn / within.iframe / within.webView
// QML 语境裁定：
//     · 浏览器专属项（has.webAuthn、within.iframe、is.pwa、is.electron、浏览器内核判定）⛔ 不适用；
//     · 触摸能力改由 Python 侧枚举 QInputDevice 得出（Qt 6 无 QML 级 API）；
//     · osVersion / cpuArch 为 Nova 增强（对标 Platform 无此二项，但"关于"页刚需）。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma Singleton
import QtQuick
import Nova.Runtime

QtObject {
    id: pf

    // ── 系统标识（与 Qt.platform.os 同名：windows / osx / linux / android / ios / wasm） ──
    readonly property string os: NovaRuntime ? NovaRuntime.osName : Qt.platform.os
    readonly property string osVersion: NovaRuntime ? NovaRuntime.osVersion : ""
    readonly property string cpuArch: NovaRuntime ? NovaRuntime.cpuArch : ""

    // ── 系统判定（对标 $q.platform.is.*） ──────────────────────
    readonly property bool isWindows: pf.os === "windows"
    readonly property bool isMac: pf.os === "osx"
    readonly property bool isLinux: pf.os === "linux"
    readonly property bool isAndroid: pf.os === "android"
    readonly property bool isIOS: pf.os === "ios"
    readonly property bool isWasm: pf.os === "wasm"

    readonly property bool isMobile: pf.isAndroid || pf.isIOS
    readonly property bool isDesktop: !pf.isMobile && !pf.isWasm

    // ── 输入能力（对标 $q.platform.has.touch） ─────────────────
    // 桌面触摸本由后端枚举输入设备得出；无后端时按"移动系统即有触摸"回落。
    readonly property bool hasTouch: novaRuntimeReady ? NovaRuntime.hasTouchscreen : pf.isMobile

    // 后端是否注册（init_nova 未调用时为 false：os 回落 Qt.platform.os，触摸回落 isMobile）
    readonly property bool novaRuntimeReady: NovaRuntime !== null && NovaRuntime !== undefined

    // 无障碍：系统减弱动效偏好（Nova 增强；五期 a11y 攻坚接管真实系统值）
    property bool reducedMotion: false

    // ── 调试/关于页快照 ───────────────────────────────────────
    function describe() {
        return pf.os + (pf.osVersion !== "" ? " · " + pf.osVersion : "")
                + (pf.cpuArch !== "" ? " · " + pf.cpuArch : "")
    }

    function snapshot() {
        return {
            os: pf.os, osVersion: pf.osVersion, cpuArch: pf.cpuArch,
            isMobile: pf.isMobile, isDesktop: pf.isDesktop,
            hasTouch: pf.hasTouch, isWasm: pf.isWasm
        }
    }
}
