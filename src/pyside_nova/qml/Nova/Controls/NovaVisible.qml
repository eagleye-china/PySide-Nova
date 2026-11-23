// src/pyside_nova/qml/Nova/Controls/NovaVisible.qml
// NovaVisible 断点显隐：above/below/only 三种语义按 NovaScreen 断点控制 visible（对标 Quasar gt-*/lt-* 可见性工具类）
// NovaVisible —— 断点可见性包装器（对标 Quasar visible-* 工具类）
// 用法：包裹任意子项；above: "md" 表示 ≥md 显示；below: "sm" 表示 <sm 显示；
//       only: "xs sm" 表示仅这些断点显示；三属性可组合，均默认不限制
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    default property alias content: holder.data

    // 显示于 ≥ 该断点（如 "md"），空串不限制
    property string above: ""
    // 显示于 < 该断点，空串不限制
    property string below: ""
    // 仅显示于这些断点（空格分隔），空串不限制
    property string only: ""

    function threshold(bp) {
        return NovaScreen.thresholds[bp] !== undefined ? NovaScreen.thresholds[bp] : 0
    }
    function known(bp) {
        return NovaScreen.thresholds[bp] !== undefined
    }

    visible: (above === "" || !known(above) || NovaScreen.width >= threshold(above))
             && (below === "" || !known(below) || NovaScreen.width < threshold(below))
             && (only === "" || only.split(" ").indexOf(NovaScreen.name) >= 0)

    implicitWidth: 100
    implicitHeight: 100

    Item {
        id: holder
        anchors.fill: parent
    }
}
