// src/pyside_nova/qml/Nova/Controls/NovaStep.qml
// NovaStep 步骤面板（对标 QStep）：name/title/caption/icon/prefix/done/error/disable +
// 状态图标覆盖（done/active/error 的 icon+color，'none' 退让 prefix→icon）；default 槽
// 为步骤内容；几何与激活态由宿主 NovaStepper 统一管理（stepperRef 注入）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.ListItem
    Accessible.name: a11yLabel !== "" ? a11yLabel : title

    // ── 默认槽：步骤内容 ────────────────────────────────────
    default property alias content: body.data

    // ── 属性（对标 QStep） ──────────────────────────────────
    property var name: ""          // 步骤寻址名；空则宿主以序号寻址
    property string title: ""
    property string caption: ""
    property string icon: ""       // 无状态时圆点内图标
    property string prefix: ""     // 圆点内编号文案（覆盖 icon，有状态图标时让位）
    property bool done: false
    property bool error: false
    property bool disable: false
    property bool headerNav: true  // 允许头部导航跳到本步骤
    property string color: ""      // Quasar 命名色字符串口径（Item 基类无冲突）

    // 状态图标/颜色覆盖（step 级优先于 stepper 级；'none' 退让 prefix→icon）
    property string doneIcon: ""
    property string doneColor: ""
    property string activeIcon: ""
    property string activeColor: ""
    property string errorIcon: ""
    property string errorColor: ""

    readonly property bool isNovaStep: true

    clip: true

    Item {
        id: body
        anchors.fill: parent
    }

    // 禁用遮罩
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)
        visible: root.disable
    }
}
