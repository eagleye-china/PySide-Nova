// src/pyside_nova/qml/Nova/Services/NovaNotifyAction.qml
// NovaNotifyAction 通知动作项：label/icon/tint/noDismiss + triggered() 信号或 handler 回调（对标 Notify actions 数组项）
// NovaNotifyAction —— 通知动作项（对标 Quasar Notify actions[] 子项，QML 无闭包传参故拆为对象）
// 两种用法（等价）：
//     1) 声明式：actions: [ NovaNotifyAction { label: "撤销"; onTriggered: doUndo() } ]
//     2) JS 配置：NovaNotify.show({ actions: [{ label: "撤销", handler: function() { doUndo() } }] })
// 点击顺序契约（宪法语义）：triggered() / handler 先行，noDismiss 为假再走关闭流程。
import QtQuick

QtObject {
    id: action

    property string label: ""
    property string icon: ""            // 参与分组键计算；按钮内图标渲染随 Sprint 4 图标 provider 收口
    property color tint: "transparent"  // 预留（对标 action.color）
    property color textTint: "transparent"   // 透明 = 跟随通知正文 textTint
    property bool noDismiss: false      // true = 点击后不自动关闭（对标 no-closable 语义）
    property var handler: null          // JS 回调形态（对标 actions[].handler）
    property string closeReason: "action"    // 关闭原因上报归属：动作按钮 action / 关闭按钮 user（内部字段）

    signal triggered()
}
