// src/pyside_nova/qml/Nova/Controls/NovaScrollArea.qml
// NovaScrollArea 滚动区域（对标 QScrollArea）：内容超界出主题化滚动条
import QtQuick
import QtQuick.Controls.Basic
import Nova.Services

Item {
    id: root

    default property alias content: inner.data

    clip: true
    implicitWidth: 400
    implicitHeight: 300

    Flickable {
        id: flick
        anchors.fill: parent
        clip: true
        contentWidth: inner.childrenRect.width
        contentHeight: inner.childrenRect.height

        Item {
            id: inner
            width: Math.max(flick.width, childrenRect.width)
            height: childrenRect.height
        }

        ScrollBar.vertical: NovaScrollBar { }
        ScrollBar.horizontal: NovaScrollBar { }
    }

    // 主题化滚动条（明暗跟随 NovaTheme）
    component NovaScrollBar: ScrollBar {
        implicitWidth: 8
        implicitHeight: 8
        contentItem: Rectangle {
            implicitWidth: 8
            implicitHeight: 8
            radius: 4
            color: NovaTheme.isDark ? Qt.rgba(1, 1, 1, 0.28)
                                    : Qt.rgba(0, 0, 0, 0.24)
        }
        background: Rectangle { color: "transparent" }
    }
}
