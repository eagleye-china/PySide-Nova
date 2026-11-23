// src/pyside_nova/qml/Nova/Services/NovaScreen.qml
// NovaScreen 屏幕断点单例：xs/sm/md/lg/xl（600/1024/1440/1920），is/lt/gt 语义 1:1 对标 Quasar Screen 插件
// NovaScreen —— 屏幕断点单例（对标 Quasar Screen 插件）
// 用法：在 ApplicationWindow 中绑定一次源窗口：NovaScreen.source: window
// 断点阈值（对标 Quasar 默认值）：xs < 600 · sm < 1024 · md < 1440 · lg < 1920 · xl >= 1920
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma Singleton
import QtQuick

QtObject {
    id: screen

    // ── 源窗口（ApplicationWindow / Window / 任意 Item 均可） ──
    property var source: null

    readonly property int width: source ? source.width : 0
    readonly property int height: source ? source.height : 0

    // ── 断点阈值（px），可运行时定制 ──
    property var thresholds: ({ "xs": 600, "sm": 1024, "md": 1440, "lg": 1920 })

    function setThresholds(xs, sm, md, lg) {
        if (xs !== undefined)
            thresholds = ({ "xs": xs, "sm": sm, "md": md, "lg": lg })
    }

    // 当前断点名：xs | sm | md | lg | xl
    readonly property string name: width >= thresholds.lg ? "xl"
                                 : width >= thresholds.md ? "lg"
                                 : width >= thresholds.sm ? "md"
                                 : width >= thresholds.xs ? "sm" : "xs"

    // ── Quasar Screen.is.* ──
    readonly property bool isXs: name === "xs"
    readonly property bool isSm: name === "sm"
    readonly property bool isMd: name === "md"
    readonly property bool isLg: name === "lg"
    readonly property bool isXl: name === "xl"

    // ── Quasar Screen.lt.*（小于该断点） ──
    readonly property bool ltSm: width < thresholds.sm
    readonly property bool ltMd: width < thresholds.md
    readonly property bool ltLg: width < thresholds.lg

    // ── Quasar Screen.gt.*（大于等于该断点） ──
    readonly property bool gtXs: width >= thresholds.xs
    readonly property bool gtSm: width >= thresholds.sm
    readonly property bool gtMd: width >= thresholds.md
    readonly property bool gtLg: width >= thresholds.lg

    // 便捷：移动端宽度（< 1024）
    readonly property bool isMobile: ltSm
}
