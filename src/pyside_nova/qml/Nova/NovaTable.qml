// src/pyside_nova/qml/Nova/NovaTable.qml

import QtQuick
import QtQuick.Controls.Basic

/**
 * @created 2026-11-13 10:53:29
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    // ── 属性契约 ──
    property var columns: []
    property var rows: []
    property bool striped: true
    property bool dense: false

    // 🎨 全面接入 Theme 契约，随 mode 自动切换
    property color baseColor: Theme.surface
    property color stripeColor: Theme.mode === "dark" ? Qt.lighter(Theme.surface, 1.15) : Qt.darker(Theme.surface, 1.03)
    property color hoverColor: Theme.hover
    property color textColor: Theme.text_primary
    property color headerTextColor: Theme.text_secondary
    property color borderColor: Theme.border

    // 外观设置
    color: baseColor
    radius: Theme.radiusSm
    border.color: borderColor
    border.width: 1
    clip: true

    // 全局动效：切换主题时背景色平滑过渡
    Behavior on color {
        ColorAnimation {
            duration: Theme.durationFast
        }
    }

    readonly property real rowHeight: dense ? Units.px(36) : Units.px(48)
    readonly property real headerHeight: dense ? Units.px(40) : Units.px(50)
    readonly property real fontSize: dense ? Units.px(12) : Units.px(14)

    // ── 表头固定区 ──
    Rectangle {
        id: headerBg
        width: parent.width
        height: root.headerHeight
        color: root.baseColor
        z: 2

        Behavior on color {
            ColorAnimation {
                duration: Theme.durationFast
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: root.borderColor
        }

        Row {
            id: headerRow
            height: parent.height
            x: -tableList.contentX

            Repeater {
                model: root.columns
                Item {
                    width: modelData.width || Units.px(100)
                    height: headerBg.height

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Units.px(12)
                        text: modelData.label || ""
                        color: root.headerTextColor
                        font.pixelSize: root.fontSize
                        font.bold: true
                        elide: Text.ElideRight
                        width: parent.width - Units.px(24)
                        horizontalAlignment: modelData.align === "center" ? Text.AlignHCenter :
                                modelData.align === "right" ? Text.AlignRight : Text.AlignLeft
                    }
                }
            }
        }
    }

    // ── 表体虚拟滚动区 ──
    ListView {
        id: tableList
        anchors.top: headerBg.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        clip: true
        model: root.rows
        reuseItems: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick | Flickable.HorizontalFlick

        ScrollBar.vertical: ScrollBar {
            id: vbar
            active: true
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle {
                implicitWidth: Units.px(6)
                radius: Units.px(3)
                color: root.borderColor
                opacity: vbar.pressed ? 0.8 : 0.4
            }
        }

        delegate: Rectangle {
            id: rowItem
            width: Math.max(headerRow.width, tableList.width)
            height: root.rowHeight
            property var rowData: model.modelData || model

            color: rowMouse.containsMouse ? root.hoverColor :
                (root.striped && index % 2 !== 0 ? root.stripeColor : root.baseColor)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durationFast
                }
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.rowClicked(rowData, index)
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: root.borderColor
                opacity: 0.3
            }

            Row {
                height: parent.height
                x: -tableList.contentX

                Repeater {
                    model: root.columns
                    Item {
                        width: modelData.width || Units.px(100)
                        height: rowItem.height

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: Units.px(12)
                            text: rowItem.rowData[modelData.field] !== undefined ? rowItem.rowData[modelData.field] : ""
                            color: root.textColor
                            font.pixelSize: root.fontSize
                            elide: Text.ElideRight
                            width: parent.width - Units.px(24)
                            horizontalAlignment: modelData.align === "center" ? Text.AlignHCenter :
                                    modelData.align === "right" ? Text.AlignRight : Text.AlignLeft
                        }
                    }
                }
            }
        }
    }

    signal rowClicked(var rowData, int rowIndex)
}