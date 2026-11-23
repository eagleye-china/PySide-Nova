// src/pyside_nova/qml/Nova/Controls/NovaTh.qml
// NovaTh 表头单元格（对标 QTh）：文本/对齐/排序指示（受控模式：sortRequest 只上报）
import QtQuick
import Nova.Services
import Nova.Behaviors
import Nova.Design

Rectangle {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.ColumnHeader
    Accessible.name: a11yLabel !== "" ? a11yLabel : text
    Accessible.focusable: sortable
    Accessible.focused: activeFocus
    activeFocusOnTab: sortable
    Keys.onReturnPressed: if (root.sortable) root.sortRequest()
    Keys.onEnterPressed: if (root.sortable) root.sortRequest()
    Keys.onSpacePressed: if (root.sortable) root.sortRequest()

    default property alias content: inner.data

    property string text: ""
    property string align: "left"          // left | center | right
    property bool sortable: false
    // 排序态由宿主回写驱动（NovaTablesortBy/descending 下发）
    property bool sorted: false
    property bool descending: false

    signal sortRequest()

    width: 120
    height: 40
    color: "transparent"

    Row {
        id: inner
        anchors {
            left: root.align === "left" ? parent.left : undefined
            horizontalCenter: root.align === "center" ? parent.horizontalCenter : undefined
            right: root.align === "right" ? parent.right : undefined
            leftMargin: NovaTheme.spacingM
            rightMargin: NovaTheme.spacingM
        }
        height: parent.height
        spacing: 2

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.sorted ? NovaTheme.primary : NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontS
            font.weight: Font.Bold
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.sortable
            text: root.sorted ? (root.descending ? "▾" : "▴") : "⇅"
            color: root.sorted ? NovaTheme.primary : NovaTheme.textMuted
            opacity: root.sorted ? 1 : 0.45
            font.pixelSize: NovaTheme.fontXS
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.sortable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.sortable) root.sortRequest()
    }
    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
