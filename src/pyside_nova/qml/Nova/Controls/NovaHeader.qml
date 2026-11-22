// src/pyside_nova/qml/Nova/Controls/NovaHeader.qml
// NovaHeader 顶部应用栏：NovaLayout 四象限之顶栏，tint 基调色 + 默认槽，高度隐式 56（对标 QHeader）
// NovaHeader —— 顶部应用栏（对标 QHeader）
// 用法：作为 NovaLayout 直接子项声明即自动安置到顶部；默认底色 primary，字色用 NovaTheme.textOnPrimary
import QtQuick
import Nova.Services

Rectangle {
    id: root

    default property alias content: body.data

    // 基调色（约定命名 tint），默认品牌主色
    property color tint: NovaTheme.primary
    // 文字建议色（跟随 tint 铺满与否由使用者决定）
    readonly property color contentColor: NovaTheme.textOnPrimary

    implicitHeight: 56
    height: implicitHeight
    color: tint

    Item {
        id: body
        anchors.fill: parent
    }
}
