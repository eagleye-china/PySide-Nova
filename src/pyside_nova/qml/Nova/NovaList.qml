import QtQuick

Flickable {
    id: root
    clip: true
    contentWidth: width
    contentHeight: listColumn.height + Units.px(16) // 底部留白
    boundsBehavior: Flickable.StopAtBounds

    default property alias content: listColumn.data

    Column {
        id: listColumn
        width: parent.width
        y: Units.px(8) // 顶部留白
        spacing: Units.px(4) // 菜单项之间的间距
    }
}
