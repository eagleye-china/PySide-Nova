// src/pyside_nova/qml/Nova/Controls/NovaCardSection.qml
// NovaCardSection 卡片内容区：默认内容槽，padding 取 NovaTheme.spacingL
// NovaCardSection —— 卡片内容分区（对标 QCardSection）
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    default property alias content: column.data

    property int padding: NovaTheme.spacingL

    // CARF 基础组件 Robustness：padding 极端非法入参钳制，避免 column 负宽 / 负 implicitHeight。
    readonly property int _pad: Math.max(0, Math.min(root.padding,
                                                     Math.floor(root.width / 2),
                                                     Math.floor(root.height / 2)))

    implicitWidth: 360
    implicitHeight: column.implicitHeight + _pad * 2

    Column {
        id: column
        x: root._pad
        y: root._pad
        width: Math.max(0, root.width - root._pad * 2)
        spacing: NovaTheme.spacingS
    }
}
