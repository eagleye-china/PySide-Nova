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

    // 🚀 新增：多选与排序契约
    property bool selectable: false
    property var selectedItems: []
    property string sortBy: ""
    property bool sortDescending: false

    // 🎨 全面接入 Theme
    property color baseColor: Theme.surface
    property color stripeColor: Theme.mode === "dark" ? Qt.lighter(Theme.surface, 1.15) : Qt.darker(Theme.surface, 1.03)
    property color hoverColor: Theme.hover
    property color textColor: Theme.text_primary
    property color headerTextColor: Theme.text_secondary
    property color borderColor: Theme.border

    color: baseColor
    radius: Theme.radiusSm
    border.color: borderColor
    border.width: 1
    clip: true

    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

    readonly property real rowHeight: dense ? Units.px(36) : Units.px(48)
    readonly property real headerHeight: dense ? Units.px(40) : Units.px(50)
    readonly property real fontSize: dense ? Units.px(12) : Units.px(14)
    readonly property real checkboxWidth: Units.px(48)

    // 内部数据模型
    ListModel { id: tableModel }

    onRowsChanged: updateModel()
    onSortByChanged: updateModel()
    onSortDescendingChanged: updateModel()

    function updateModel() {
        tableModel.clear();
        if (!rows || rows.length === 0) return;
        let displayData = rows.slice();
        if (sortBy !== "") {
            displayData.sort((a, b) => {
                let valA = a[sortBy];
                let valB = b[sortBy];
                if (typeof valA === "number" && typeof valB === "number") {
                    return sortDescending ? valB - valA : valA - valB;
                } else {
                    let strA = String(valA).toLowerCase();
                    let strB = String(valB).toLowerCase();
                    if (strA < strB) return sortDescending ? 1 : -1;
                    if (strA > strB) return sortDescending ? -1 : 1;
                    return 0;
                }
            });
        }
        for (let i = 0; i < displayData.length; i++) {
            tableModel.append(displayData[i]);
        }
    }

    function toggleSelectAll() {
        if (selectedItems.length === rows.length) selectedItems = [];
        else selectedItems = rows.map(r => r.id);
        selectedItemsChanged();
    }

    function toggleRow(id) {
        let newSelected = selectedItems.slice();
        let idx = newSelected.indexOf(id);
        if (idx > -1) newSelected.splice(idx, 1);
        else newSelected.push(id);
        selectedItems = newSelected;
        selectedItemsChanged();
    }

    // ── 表头固定区 ──
    Rectangle {
        id: headerBg
        width: parent.width
        height: root.headerHeight
        color: root.baseColor
        z: 2

        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

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

            // 头部全选框
            Item {
                width: root.selectable ? root.checkboxWidth : 0
                height: headerBg.height
                visible: root.selectable

                Rectangle {
                    anchors.centerIn: parent
                    width: Units.px(18)
                    height: Units.px(18)
                    radius: Theme.radiusSm
                    color: root.selectedItems.length === root.rows.length && root.rows.length > 0 ? Theme.primary : "transparent"
                    border.width: 2
                    border.color: root.selectedItems.length === root.rows.length && root.rows.length > 0 ? Theme.primary : Theme.border

                    Rectangle {
                        anchors.centerIn: parent
                        width: Units.px(10)
                        height: 2
                        color: Theme.white
                        visible: root.selectedItems.length > 0 && root.selectedItems.length < root.rows.length
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        color: Theme.white
                        font.pixelSize: Units.px(12)
                        font.bold: true
                        visible: root.selectedItems.length === root.rows.length && root.rows.length > 0
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleSelectAll()
                    }
                }
            }

            Repeater {
                model: root.columns
                Item {
                    width: modelData.width || Units.px(100)
                    height: headerBg.height

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Units.px(12)
                        spacing: Units.px(4)

                        Text {
                            text: modelData.label || ""
                            color: root.sortBy === modelData.field ? Theme.primary : root.headerTextColor
                            font.pixelSize: root.fontSize
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: root.sortDescending ? "↓" : "↑"
                            color: Theme.primary
                            font.pixelSize: root.fontSize
                            visible: root.sortBy === modelData.field
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.sortBy === modelData.field) {
                                root.sortDescending = !root.sortDescending;
                            } else {
                                root.sortBy = modelData.field;
                                root.sortDescending = false;
                            }
                        }
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
        model: tableModel
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
            property var rowData: model
            property bool isSelected: root.selectedItems.indexOf(rowData.id) > -1

            color: isSelected ? Theme.pressed :
                   (rowMouse.containsMouse ? root.hoverColor :
                   (root.striped && index % 2 !== 0 ? root.stripeColor : root.baseColor))

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }

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

                // 行内选择框
                Item {
                    width: root.selectable ? root.checkboxWidth : 0
                    height: rowItem.height
                    visible: root.selectable

                    Rectangle {
                        anchors.centerIn: parent
                        width: Units.px(18)
                        height: Units.px(18)
                        radius: Theme.radiusSm
                        color: rowItem.isSelected ? Theme.primary : "transparent"
                        border.width: 2
                        border.color: rowItem.isSelected ? Theme.primary : Theme.border

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: Theme.white
                            font.pixelSize: Units.px(12)
                            font.bold: true
                            visible: rowItem.isSelected
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleRow(rowItem.rowData.id)
                        }
                    }
                }

                Repeater {
                    model: root.columns
                    Item {
                        width: modelData.width || Units.px(100)
                        height: rowItem.height

                        // 🚀 支持彩色胶囊标签 (Badge) - 改用了 modelData.badge 防止冲突
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: Units.px(12)
                            visible: modelData.badge === true
                            width: badgeText.implicitWidth + Units.px(16)
                            height: Units.px(22)
                            radius: Units.px(11)

                            property string val: rowItem.rowData[modelData.field] || ""
                            color: {
                                if (val === "异常" || val === "Error") return Qt.rgba(0.95, 0.35, 0.35, 0.15);
                                if (val === "运行中" || val === "Success") return Qt.rgba(0.2, 0.8, 0.4, 0.15);
                                if (val === "待机" || val === "Warning") return Qt.rgba(0.9, 0.7, 0.1, 0.15);
                                return Theme.hover;
                            }

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: parent.val
                                font.pixelSize: Units.px(12)
                                font.bold: true
                                color: {
                                    if (parent.val === "异常" || parent.val === "Error") return Theme.negative;
                                    if (parent.val === "运行中" || parent.val === "Success") return Theme.positive;
                                    if (parent.val === "待机" || parent.val === "Warning") return Theme.warning;
                                    return Theme.text_secondary;
                                }
                            }
                        }

                        Text {
                            visible: modelData.badge !== true
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