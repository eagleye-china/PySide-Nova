// src/pyside_nova/qml/Nova/Controls/NovaMarkupTable.qml
// NovaMarkupTable 标记表格（对标 QMarkupTable）：columns/rows 数组直渲 + 标题
import QtQuick
import Nova.Services

Rectangle {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.Table
    Accessible.name: a11yLabel !== "" ? a11yLabel : title

    property string title: ""
    property var columns: []                // ["列A", "列B", ...]
    property var rows: []                   // [["a1","b1"], ["a2","b2"], ...]
    property bool flat: false
    property bool dense: false

    radius: NovaTheme.radiusL
    color: NovaTheme.surface
    border.width: flat ? 0 : 1
    border.color: NovaTheme.outline
    implicitWidth: 400
    implicitHeight: titleArea.height + headRow.height + bodyCol.height + 2

    Column {
        anchors.fill: parent

        Rectangle {
            id: titleArea
            width: parent.width
            height: root.title !== "" ? 44 : 0
            Text {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingM }
                text: root.title
                color: NovaTheme.textColor
                font.pixelSize: NovaTheme.fontL
                font.weight: Font.Medium
            }
        }

        // 表头
        Rectangle {
            id: headRow
            width: parent.width
            height: root.dense ? 36 : 44
            color: NovaTheme.surfaceAlt
            Row {
                anchors.fill: parent
                Repeater {
                    model: root.columns
                    Item {
                        required property var modelData
                        width: headRow.width / Math.max(1, root.columns.length)
                        height: parent.height
                        Text {
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingM }
                            text: modelData
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontS
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }
                        Rectangle {
                            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                            width: 1; color: NovaTheme.outline; opacity: 0.6
                        }
                    }
                }
            }
        }

        // 表体
        Column {
            id: bodyCol
            width: parent.width

            Repeater {
                model: root.rows

                Rectangle {
                    id: bodyRow
                    required property var modelData
                    required property int index
                    width: parent.width
                    height: root.dense ? 36 : 44
                    color: "transparent"

                    Row {
                        anchors.fill: parent
                        Repeater {
                            model: bodyRow.modelData.length
                            Item {
                                required property int index
                                width: bodyRow.width / Math.max(1, bodyRow.modelData.length)
                                height: parent.height
                                Text {
                                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingM }
                                    text: String(bodyRow.modelData[index])
                                    color: NovaTheme.textColor
                                    font.pixelSize: NovaTheme.fontM
                                    elide: Text.ElideRight
                                    width: parent.width - NovaTheme.spacingM * 2
                                }
                            }
                        }
                    }
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height: 1; color: NovaTheme.outline; opacity: 0.5
                    }
                }
            }
        }
    }
}
