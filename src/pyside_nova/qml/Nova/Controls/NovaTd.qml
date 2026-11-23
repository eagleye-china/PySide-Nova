// src/pyside_nova/qml/Nova/Controls/NovaTd.qml
// NovaTd 单元格（对标 QTd）：文本/对齐/自定义内容
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Rectangle {
    id: root

    default property alias content: inner.data

    property string text: ""
    property string align: "left"          // left | center | right
    property bool autoWidth: true

    width: 120
    height: 44
    color: "transparent"

    Item {
        id: inner
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: NovaTheme.spacingM
            rightMargin: NovaTheme.spacingM
        }
        height: parent.height

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: NovaTheme.textColor
            font.pixelSize: NovaTheme.fontM
            elide: Text.ElideRight
            width: parent.width
            horizontalAlignment:
                root.align === "center" ? Text.AlignHCenter
                : root.align === "right" ? Text.AlignRight : Text.AlignLeft
        }
    }
}
