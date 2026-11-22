// src/pyside_nova/qml/Nova/Services/NovaLoadingHandle.qml
// NovaLoadingHandle 加载句柄：show() 返回值，hide()/update() + valid/count（引用计数语义，Nova 增强）
// NovaLoadingHandle —— 单个"调用方"对加载层的引用凭据。
// 语义（与 NovaDialogHandle 的强杀语义刻意不同）：
//     hide()  = 释放本句柄持有的 **一份** 引用；同组还有其他持有者时遮罩继续显示（并发不互踩）
//     update(props) → bool = 更新同组视觉配置（多持有者时后到者生效）
//     valid / count = 句柄是否仍持有引用 / 该组当前引用计数
import QtQuick

QtObject {
    id: handle

    // 指向的活动组条目（{ group, count, item, dead }）；null = 已失效
    property var entry: null

    // 视觉层引用（与 Notify/Dialog 句柄同名同义：调试、测试、自动化直接取）
    readonly property var item: entry ? entry.item : null

    // 失效判据只看 entry.dead：句柄释放后视觉层可能仍在淡出，但引用已归还
    readonly property bool valid: entry !== null && !entry.dead
    readonly property string group: entry ? entry.group : ""
    readonly property int count: entry ? entry.count : 0

    function hide() {
        if (!handle.valid)
            return false
        return NovaLoading._release(handle.entry)
    }

    function update(props) {
        if (!handle.valid || !props || typeof props !== "object")
            return false
        return NovaLoading._apply(handle.entry, props)
    }
}
