// src/pyside_nova/qml/Nova/Controls/NovaFooter.qml
// NovaFooter 底部应用栏：NovaLayout 四象限之底栏，tint 基调色 + 默认槽，高度隐式 48（对标 QFooter）
// NovaFooter —— 底部应用栏（对标 QFooter）
// 用法：作为 NovaLayout 直接子项声明即自动安置到底部；默认底色 primary
import QtQuick
import Nova.Services

Rectangle {
    id: root

    default property alias content: body.data

    property color tint: NovaTheme.primary
    readonly property color contentColor: NovaTheme.textOnPrimary

    implicitHeight: 48
    height: implicitHeight
    color: tint

    Item {
        id: body
        anchors.fill: parent
    }
}
