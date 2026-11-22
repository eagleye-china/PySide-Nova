// src/pyside_nova/qml/Nova/Behaviors/NovaScrollFire.qml
// NovaScrollFire 首次进入视口触发一次的行为：阈值可调、可再武装（对标 Quasar v-scroll-fire）
// NovaScrollFire —— 滚动到视口触发一次（L3 行为层）
//
// 用法（懒加载图片的经典姿势）：
//     Image {
//         width: 200; height: 120
//         source: ""
//         NovaScrollFire {
//             onFire: (item) => item.source = "https://cdn.example.com/big.jpg"
//         }
//     }
//
// 基线契约（npm quasar@2.35.5 src/directives/scroll-fire/ScrollFire.json 核实）：
//     value: Function(el) | undefined(禁用；禁用期间重新赋值可再次武装)
//     arg:   0~1 的数字，默认 0（看到一点就触发）→ Nova 用 threshold 属性承载
//     v2.30 起内部复用共享 IntersectionObserver（与 v-intersection 同池）→ Nova 同样复用 NovaIntersection
//
// 语义要点（与基线一致）：
//   · 触发一次后自动解除武装；中间禁用过再启用 = 重新武装（rearm() 亦可手动）
//   · threshold: 0.5 表示至少露出一半才触发；1 表示完全可见才触发
import QtQuick
import Nova.Services

Item {
    id: beh

    property Item target: parent
    property Item root: null
    property real threshold: 0          // 0~1，需可见比例 ≥ 该值才触发
    property bool armed: true           // 武装态：false = 不再触发（触发后自动置 false）

    readonly property bool fired: _fired
    property bool _fired: false

    signal fire(var item)

    anchors.fill: parent

    // 复用 NovaIntersection：同一套池 + 同一套几何测量，避免两套可见性算法各自漂移
    NovaIntersection {
        id: inner
        target: beh.target
        root: beh.root
        threshold: 1
        enabled: beh.armed
        onIntersect: (entry) => {
            if (entry.intersectionRatio + 0.0001 >= beh.threshold) {
                beh._fired = true
                beh.armed = false
                beh.fire(entry.target)
            }
        }
    }

    function rearm() {
        beh._fired = false
        beh.armed = true
    }
}
