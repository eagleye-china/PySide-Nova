// src/pyside_nova/qml/Nova/Services/NovaDialogHandle.qml
// NovaDialogHandle 对话框句柄：show() 返回值，hide()/update()/ok()/cancel()/valid + 三信号（对标 createDialog 的链式句柄）
// NovaDialogHandle —— 对话框句柄（基线返回可链式对象；QML 语境升级为 QObject：可绑定、可观测、可 GC）
// 语义对齐：
//     hide()                —— 等价基线 handle.hide()，关闭原因 api
//     update(props) → bool  —— 等价基线 handle.update(props)；句柄失效返回 false
//     onOk/onCancel/onDismiss —— 基线为链式回调；QML 用 accepted/rejected/dismissed 三信号承载
//     ok() / cancel()       —— Nova 增强：程序化触发主/次按钮（自动化测试友好）
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick

QtObject {
    id: handle

    // 指向的对话框卡片（NovaDialogCard）；null = 已失效
    property var item: null

    readonly property bool valid: item !== null

    signal accepted()
    signal rejected()
    signal dismissed(string reason)

    function hide() {
        if (item)
            item.requestDismiss("api")
    }

    function update(props) {
        if (!item)
            return false
        return item.applyUpdate(props)
    }

    function ok() {
        if (item)
            item.accept()
    }

    function cancel() {
        if (item)
            item.cancel()
    }
}
