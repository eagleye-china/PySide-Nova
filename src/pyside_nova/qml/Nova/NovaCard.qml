// src/pyside_nova/qml/Nova/NovaCard.qml

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool flat: false
    property bool bordered: false
    property bool square: false
    property bool dark: false
    property string tag: ""
    property real radius: Theme.radiusMd
    property int elevation: flat ? 0 : 1

    default property alias content: contentHost.data
    readonly property alias contentItem: contentHost

    // ✅ 核心修复：彻底移除了对子组件宽高的死锁依赖
    // 交给外部通过 width / height 或 Layout 指定大小，这里给一个纯兜底值
    implicitWidth: Units.px(300)
    implicitHeight: Units.px(200)

    readonly property int radiusValue: square ? Theme.radiusNone : Units.px(radius)
    readonly property color surfaceColor: dark
        ? Theme.dark
        : (tag.length > 0 ? Theme.colorOf(tag) : Theme.surface)
    readonly property color foreground: dark
        ? Theme.text_primary
        : (tag.length > 0 ? Theme.contrast(Theme.colorOf(tag)) : Theme.text_primary)
    readonly property color borderColor: bordered ? Theme.border : "transparent"

    readonly property real shadowOpacity: Math.min(0.28, 0.05 + elevation * 0.045)
    readonly property real shadowSpread: elevation <= 0 ? 0 : 1 + elevation * 0.8

    Rectangle {
        id: shadowOuter
        anchors.fill: backgroundLayer
        anchors.margins: -Units.px(root.shadowSpread * 2)
        radius: root.radiusValue + Units.px(root.shadowSpread * 2)
        color: Qt.rgba(0, 0, 0, root.shadowOpacity * 0.35)
        visible: root.elevation > 0
        z: -2
    }

    Rectangle {
        id: shadowInner
        anchors.fill: backgroundLayer
        anchors.margins: -Units.px(root.shadowSpread)
        radius: root.radiusValue + Units.px(root.shadowSpread)
        color: Qt.rgba(0, 0, 0, root.shadowOpacity)
        visible: root.elevation > 0
        z: -1
    }

    Rectangle {
        id: backgroundLayer
        anchors.fill: parent
        radius: root.radiusValue
        color: root.surfaceColor
        border.width: root.bordered ? Math.max(1, Units.px(1)) : 0
        border.color: root.borderColor
        clip: true

        // ✅ 核心修复：内容容器不再计算 implicitWidth，完全由父级决定
        Item {
            id: contentHost
            anchors.fill: parent
            anchors.margins: Units.px(Theme.spaceMd)
            clip: true
        }
    }
}