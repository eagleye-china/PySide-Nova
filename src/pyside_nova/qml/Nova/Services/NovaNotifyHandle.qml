// src/pyside_nova/qml/Nova/Services/NovaNotifyHandle.qml
// NovaNotifyHandle 通知句柄：show() 返回值，dismiss()/update(props)/valid 三面（对标 Notify.create 返回的句柄函数）
// NovaNotifyHandle —— 通知句柄（基线返回裸函数，QML 语境升级为 QObject：可绑定、可观测、可 GC）
// 语义对齐：
//     dismiss()                 —— 等价基线句柄函数无参调用
//     update(props) → bool      —— 等价基线句柄函数传 props；分组通知禁止更新，返回 false
//     valid                     —— Nova 增强：句柄是否仍指向活着的通知（基线 dismiss 后句柄变静默空函数，难排查）
import QtQuick

QtObject {
    id: handle

    // 指向的通知卡片（NovaNotificationItem）；null = 已失效
    property var item: null

    readonly property bool valid: item !== null

    function dismiss() {
        if (item)
            NovaNotify.dismiss(item, "api")
    }

    function update(props) {
        if (!item)
            return false
        return NovaNotify.update(item, props)
    }
}
