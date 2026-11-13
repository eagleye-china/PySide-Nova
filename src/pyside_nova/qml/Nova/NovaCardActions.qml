// src/pyside_nova/qml/Nova/NovaCardActions.qml

import QtQuick
import QtQuick.Layouts

/**
 * @created 2026-11-13 21:00:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    property string align: "right"
    property bool bordered: true

    // ✅ 核心修复：移除了 implicitWidth 的父级计算，只计算高度
    implicitHeight: layout.implicitHeight + Units.px(16)
    color: "transparent"

    // 顶部分割线
    Rectangle {
        visible: root.bordered
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: Theme.border
        opacity: 0.6
    }

    RowLayout {
        id: layout
        anchors.top: parent.top
        anchors.topMargin: Units.px(16)
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Units.px(8)

        // 左侧弹簧
        Item {
            Layout.fillWidth: true
            visible: root.align === "right" || root.align === "center"
        }

        // 承载外部按钮的容器
        Row {
            id: innerRow
            Layout.alignment: Qt.AlignVCenter
            spacing: Units.px(8)
        }

        // 右侧弹簧
        Item {
            Layout.fillWidth: true
            visible: root.align === "left" || root.align === "center"
        }
    }

    // ✅ 把 alias 放在最后
    default property alias contentData: innerRow.data
}