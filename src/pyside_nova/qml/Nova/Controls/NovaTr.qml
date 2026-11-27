// src/pyside_nova/qml/Nova/Controls/NovaTr.qml
// NovaTr 表格行（对标 QTr）：选中高亮/点击上报（受控：selection 由宿主写回）
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Rectangle {
    id: root

    default property alias content: row.data

    property bool selected: false
    property bool clickable: true
    // 1.10.0：对标 Quasar table-row-style-fn / table-row-class-fn（只接语义令牌色，不解析 CSS）
    property color rowColor: "transparent"

    signal rowClicked()
    signal rowDoubleClicked()
    signal rowContextMenu()          // 1.10.0：对标 @row-contextmenu

    width: 400
    height: 44
    color: selected ? Qt.rgba(NovaTheme.primary.r, NovaTheme.primary.g, NovaTheme.primary.b, 0.08)
                    : rowColor

    Row {
        id: row
        anchors.fill: parent
        spacing: 0
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.clickable
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton) root.rowContextMenu()
            else root.rowClicked()
        }
        onDoubleClicked: root.rowDoubleClicked()
    }
}
