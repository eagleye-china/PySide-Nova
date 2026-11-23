// src/pyside_nova/qml/Nova/Controls/NovaCardActions.qml
// NovaCardActions 卡片操作区：align 左/中/右对齐
// NovaCardActions —— 卡片操作区（对标 QCardActions）
// align: "left" | "center" | "right"
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    default property alias content: row.data

    property string align: "right"

    readonly property real _pad: 8

    implicitWidth: row.implicitWidth + _pad * 2
    implicitHeight: row.implicitHeight + _pad * 2

    Row {
        id: row
        y: root._pad
        spacing: NovaTheme.spacingS
        x: root.align === "right" ? root.width - root._pad - row.implicitWidth
          : root.align === "center" ? (root.width - row.implicitWidth) / 2
          : root._pad
    }
}
