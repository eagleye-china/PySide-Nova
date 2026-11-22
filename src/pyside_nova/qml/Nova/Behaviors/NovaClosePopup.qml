// src/pyside_nova/qml/Nova/Behaviors/NovaClosePopup.qml
// NovaClosePopup 关闭弹层行为：点击宿主即关闭当前弹层栈的 N 层（对标 Quasar v-close-popup）
// NovaClosePopup —— 关闭弹层（L3 行为层）
//
// 用法：
//     NovaBtn {
//         text: "关闭"
//         NovaClosePopup { }                 // 点了就关掉最上层弹层
//     }
//     NovaBtn {
//         text: "全部关闭"
//         NovaClosePopup { depth: -1 }       // 关掉整条链
//     }
//
// 基线契约（npm quasar@2.35.5 src/directives/close-popup/ClosePopup.json 核实）：
//     value: Boolean | Number | String
//         0 / 'false' → 指令禁用（不关）
//         < 0         → 关闭链上全部弹层
//         1 / 'true' / undefined → 只关父弹层
//         > 1         → 关闭链上 N 层（链式 QMenu 算 1 层，QPopupProxy 分隔链式菜单）
//     触发：click + keyup(Enter 13)；关闭动作延迟到下一 tick，让 @click 先跑完（基线 setTimeout 0）
//
// QML 映射（如实记录于 docs/PARITY.md）：
//     · QML 无 DOM 指令，也没有 Vue 的 portal 组件树；"点击自己的父弹层"改由 NovaOverlayHost 弹层栈承载，
//       depth 语义与基线完全一致（<0 全关 / 0 禁用 / N 关顶 N 层）。
//     · 触发源：默认桥接宿主的 clicked 信号（NovaBtn / 未来的 NovaMenuItem 等都有），
//       宿主要是普通 Item 没有 clicked，就把 usePointer 设 true 交给内部 MouseArea。
import QtQuick
import Nova.Services

Item {
    id: beh

    property Item target: null            // 默认自动：向上找带 clicked 信号的宿主（NovaBtn 把子项转交给内部 contentHost）
    property int depth: 1                 // <0 全关；0 禁用；>0 关 N 层
    property string reason: "api"         // 传给弹层的关闭原因（NovaDialog 五值之一）
    property bool usePointer: false       // true = 用内部 MouseArea 接管点击（宿主无 clicked 信号时）
    property bool keyboard: true          // Enter 键也触发（对标 keyup 13）

    readonly property int popupCount: NovaOverlayHost.popupCount()
    property Item host: null              // 解析出的宿主（clicked 信号所在对象）

    signal closed(int count)              // 实际关闭层数

    anchors.fill: parent

    Component.onCompleted: beh.host = beh._resolveHost()
    onTargetChanged: beh.host = beh._resolveHost()

    // QML 组件的默认属性常把子项转交给内部容器（如 NovaBtn 的 contentHost），
    // 此时 parent 不是"有 clicked 的宿主"——向上找第一个带 clicked 的祖先。
    function _resolveHost() {
        if (beh.target)
            return beh.target
        var node = beh.parent
        while (node) {
            if (node.clicked !== undefined)
                return node
            node = node.parent
        }
        return beh.parent
    }

    // 宿主自带 clicked 信号时直接桥接（ignoreUnknownSignals 让普通 Item 静默）
    Connections {
        target: beh.host
        ignoreUnknownSignals: true
        function onClicked() { beh.trigger() }
    }

    // 兜底指针通道：宿主没有 clicked 信号时启用
    MouseArea {
        anchors.fill: parent
        enabled: beh.usePointer && beh.enabled
        propagateComposedEvents: true
        onClicked: (mouse) => {
            mouse.accepted = false        // 不吞事件，让宿主自己的逻辑照常跑
            beh.trigger()
        }
    }

    // 键盘通道：Enter（Key_Return / Key_Enter）触发，与基线 keyup(13) 对齐
    Keys.onPressed: (event) => {
        if (!beh.keyboard || !beh.enabled)
            return
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            beh.trigger()
            event.accepted = true
        }
    }

    // 触发关闭：depth=0 直接不动作（基线禁用语义）
    function trigger() {
        if (!beh.enabled || beh.depth === 0)
            return 0
        var n = NovaOverlayHost.closePopups(beh.depth, beh.reason)
        if (n > 0)
            beh.closed(n)
        return n
    }
}
