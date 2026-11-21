// src/pyside_nova/qml/Nova/Controls/NovaCardSection.qml
// NovaCardSection 卡片内容区：默认内容槽，padding 取 NovaTheme.spacingL
// NovaCardSection —— 卡片内容分区（对标 QCardSection）
import QtQuick
import Nova.Services

Item {
    id: root

    default property alias content: column.data

    property int padding: NovaTheme.spacingL

    implicitWidth: 360
    implicitHeight: column.implicitHeight + padding * 2

    Column {
        id: column
        x: root.padding
        y: root.padding
        width: root.width - root.padding * 2
        spacing: NovaTheme.spacingS
    }
}
