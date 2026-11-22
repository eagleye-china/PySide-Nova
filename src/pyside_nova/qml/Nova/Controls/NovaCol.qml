// src/pyside_nova/qml/Nova/Controls/NovaCol.qml
// NovaCol 栅格列：cols 1~12 占 12 栅格、offset 偏移、gutter 内边距，父级 NovaRow 自动排布（对标 Quasar col-*-n）
// NovaCol —— 栅格列（对标 Quasar col-*-n + offset-*）
// 用法：置于 NovaRow 内；宽度 = 行宽 × cols/12（声明式绑定，随行宽实时变化）；
//       offset 向右偏移 offset/12 行宽；gutter 为四周内边距
import QtQuick
import Nova.Services

Item {
    id: root

    default property alias content: body.data

    // 栅格占数（1~12，12 = 整行）
    property int cols: 12
    // 偏移栅格数（0~11）
    property int offset: 0
    // 四周内边距（替代 q-gutter 的列内实现）
    property int gutter: 0

    implicitWidth: 100

    width: parent && parent instanceof NovaRow ? parent.width * cols / 12 : implicitWidth

    onColsChanged: if (parent && parent instanceof NovaRow) parent.relayout()
    onOffsetChanged: if (parent && parent instanceof NovaRow) parent.relayout()

    Item {
        id: body
        anchors {
            fill: parent
            margins: root.gutter
        }
    }
}
