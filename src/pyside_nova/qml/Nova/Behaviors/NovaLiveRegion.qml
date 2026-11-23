// src/pyside_nova/qml/Nova/Behaviors/NovaLiveRegion.qml
// NovaLiveRegion 状态播报区：把 NovaA11y.notice() 的状态消息真正说给屏读器（WCAG 4.1.3 Status Messages）——Quasar 无对应，Nova 增强
// NovaLiveRegion —— 宿主根节点放一个即可：NovaLiveRegion { }（零尺寸、零视觉、不参与事件分发）
// 背景：QML 的 Accessible.announce() 是附加方法，只能从 Item 作用域调用；单例调用会报
//   "Accessible attached property must be attached to an object deriving from Item"（0.16.0 实测）。
//   故播报状态存于 NovaA11y，由本组件在宿主侧消费并转成真正的 announce 调用。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Design

Item {
    id: root

    // 播报语义留痕（Qt 无 assertive/polite 区分，仅作调用方意图记录与文档口径）
    property string politeness: "polite"      // polite | assertive
    readonly property string lastSpoken: NovaA11y.lastAnnouncement

    width: 0
    height: 0
    visible: false                            // 纯逻辑，无指针通道 → 可见性门控安全（坑位 13）

    // Accessible 是附加属性，只能在 Item 作用域内调用（Connections 内调用会报
    // "must be attached to an object deriving from Item"）→ 统一走根 Item 的成员函数
    function speak(text) {
        if (text === undefined || text === null || String(text) === "")
            return
        Accessible.announce(String(text))
    }

    Connections {
        target: NovaA11y
        function onAnnouncementCountChanged() {
            root.speak(NovaA11y.lastAnnouncement)
        }
    }
}
