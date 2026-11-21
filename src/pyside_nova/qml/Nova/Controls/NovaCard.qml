// src/pyside_nova/qml/Nova/Controls/NovaCard.qml
// NovaCard 卡片容器：flat/elevated/bordered、elevation 0~5 级 MultiEffect 真实阴影（对标 QCard）
// NovaCard —— 卡片容器（对标 QCard）
// 内容区使用 NovaCardSection / NovaCardActions 组织；elevated 提供阴影
import QtQuick
import QtQuick.Effects
import Nova.Services

Rectangle {
    id: root

    // 内容（默认属性）进入内部 Column
    default property alias content: body.data

    property bool flat: false
    property bool elevated: !flat
    property bool bordered: false
    property int elevation: 2

    radius: NovaTheme.radiusL
    color: NovaTheme.surface
    border.width: bordered ? 1 : 0
    border.color: NovaTheme.outline

    implicitWidth: 360
    implicitHeight: body.implicitHeight

    MultiEffect {
        anchors.fill: parent
        anchors.margins: -24
        source: root
        z: -1
        shadowEnabled: root.elevated
        shadowColor: NovaTheme.shadowColor(root.elevation)
        shadowBlur: 0.5
        shadowVerticalOffset: 2
        autoPaddingEnabled: false
    }

    Column {
        id: body
        anchors.fill: parent
        spacing: 0
    }
}
