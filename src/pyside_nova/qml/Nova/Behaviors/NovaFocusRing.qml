// src/pyside_nova/qml/Nova/Behaviors/NovaFocusRing.qml
// NovaFocusRing 焦点环行为：键盘模态下为可聚焦控件绘制焦点环（WCAG 2.4.7 焦点可见 / 1.4.11 非文本对比）——Quasar 无对应，Nova 增强
// NovaFocusRing —— 可挂载行为：NovaFocusRing { target: root }，只画不拦事
// 设计要点：
//   1. 可见性由 NovaA11y.ringVisible(target) 统一裁决（键盘模态 + activeFocus），
//      鼠标点击不画环（focus-visible 语义，与浏览器一致，避免视觉噪声）
//   2. 环体默认外扩 2px（offset），间隙露出所处表面色——填充态按钮上也不会与底色撞车；
//      宿主若 clip 或依赖 childrenRect 定尺寸，传 offset: 0 退化为贴边环（零尺寸增量）
//   3. 无任何指针通道（无 MouseArea/HoverHandler）：不参与事件分发，
//      因此 visible 门控安全（坑位 13 只约束带指针通道的行为）
//   4. parent 显式指回 target：组件默认槽会把子项转交给内部 contentHost（坑位 14），
//      显式 parent 可保证环与宿主同层、不被内容容器裁切
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services
import Nova.Design

Item {
    id: root

    // 宿主（必填）：显式传入，勿依赖 parent（默认槽可能改写 parent）
    property Item target: null

    // 外观（默认取令牌，可按需覆盖）
    property color tint: NovaTheme.focusRing
    property int ringWidth: NovaTheme.focusRingWidth
    property int offset: NovaTheme.focusRingOffset
    // -1 = 跟随宿主圆角（Rectangle 系取 radius，其余按 0）
    property real cornerRadius: -1

    readonly property bool active: NovaA11y.ringVisible(root.target)
    readonly property real _targetRadius: (root.target && root.target.radius !== undefined)
                                          ? root.target.radius : 0

    objectName: "NovaFocusRing"
    parent: root.target
    anchors.fill: parent
    anchors.margins: -root.offset
    z: 9999
    // 未激活时整棵子树隐藏：既省绘制，也让依赖 childrenRect 的宿主零尺寸扰动
    visible: root.active

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: (root.cornerRadius >= 0 ? root.cornerRadius : root._targetRadius) + root.offset
        border.width: root.ringWidth
        border.color: root.tint
    }
}
