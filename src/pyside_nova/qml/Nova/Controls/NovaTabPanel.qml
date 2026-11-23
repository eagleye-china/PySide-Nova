// src/pyside_nova/qml/Nova/Controls/NovaTabPanel.qml
// NovaTabPanel 标签页面板（对标 QTabPanel）：name 寻址 / disable；
// default 槽为面板内容；几何（位置/尺寸/显隐）由宿主 NovaTabPanels 统一管理
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 默认槽：面板内容 ────────────────────────────────────
    default property alias content: body.data

    property var name: ""        // 面板寻址名（可任意类型；空则宿主以序号寻址）
    property bool disable: false // 禁用面板（不可被 goTo 选中）

    readonly property bool isNovaTabPanel: true

    clip: true

    Item {
        id: body
        anchors.fill: parent
    }

    // 禁用遮罩（令牌取色）
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)
        visible: root.disable
    }
}
