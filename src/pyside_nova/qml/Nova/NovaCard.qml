// src/pyside_nova/qml/Nova/NovaCard.qml

import QtQuick
import QtQuick.Layouts

/**
 * NovaCard —— 对标 Quasar QCard 的企业级卡片容器
 *
 * @created 2026-11-12 22:51:13
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Item {
    id: root

    // ── 属性契约
    property bool flat: false               // 无阴影
    property bool bordered: false           // 描边
    property bool square: false             // 直角
    property bool dark: false               // 深色底（不跟随主题 surface）
    property string tag: ""                 // 语义色（留空则用 surface）

    // 圆角：未设置时回退到主题 radiusMd
    property real radius: Theme.radiusMd
    property int elevation: flat ? 0 : 1    // 0~5，映射层叠阴影强度

    // 默认插槽：NovaCard 内声明的子元素默认附加到 contentItem
    default property alias content: contentHost.data

    // 内容承载层（插槽宿主）
    readonly property alias contentItem: contentHost

    // ── 尺寸：有显式尺寸时以显式为准，否则由内容撑开
    implicitWidth: contentHost.implicitWidth + Units.px(Theme.spaceMd) * 2
    implicitHeight: contentHost.implicitHeight + Units.px(Theme.spaceMd) * 2

    // ✅ 核心修复：统一由内部处理 Units.px 转换，外部只需传入数值即可
    readonly property int radiusValue: square ? Theme.radiusNone : Units.px(radius)
    readonly property color surfaceColor: dark
        ? Theme.dark
        : (tag.length > 0 ? Theme.colorOf(tag) : Theme.surface)
    readonly property color foreground: dark
        ? Theme.text_primary
        : (tag.length > 0 ? Theme.contrast(Theme.colorOf(tag)) : Theme.text_primary)
    readonly property color borderColor: bordered ? Theme.border : "transparent"

    // ── 阴影层（多层同心 Rectangle 模拟层叠阴影，避免 QML 分组属性动画）
    readonly property real shadowOpacity: Math.min(0.28, 0.05 + elevation * 0.045)
    readonly property real shadowSpread: elevation <= 0 ? 0 : 1 + elevation * 0.8

    // 阴影底：外层大一圈、低透明度
    Rectangle {
        id: shadowOuter
        anchors.fill: backgroundLayer
        anchors.margins: -Units.px(root.shadowSpread * 2)
        radius: root.radiusValue + Units.px(root.shadowSpread * 2)
        color: Qt.rgba(0, 0, 0, root.shadowOpacity * 0.35)
        visible: root.elevation > 0
        z: -2
    }

    // 阴影核：贴边、略高透明度
    Rectangle {
        id: shadowInner
        anchors.fill: backgroundLayer
        anchors.margins: -Units.px(root.shadowSpread)
        radius: root.radiusValue + Units.px(root.shadowSpread)
        color: Qt.rgba(0, 0, 0, root.shadowOpacity)
        visible: root.elevation > 0
        z: -1
    }

    // ── 背景层
    Rectangle {
        id: backgroundLayer
        anchors.fill: parent
        radius: root.radiusValue
        color: root.surfaceColor
        border.width: root.bordered ? Math.max(1, Units.px(1)) : 0
        border.color: root.borderColor
        clip: true

        // ── 内容容器（默认插槽宿主）
        Item {
            id: contentHost
            anchors.fill: parent
            anchors.margins: Units.px(Theme.spaceMd)
            clip: true // 防止内部溢出的内容画到卡片外

            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}