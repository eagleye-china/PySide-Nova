// src/pyside_nova/qml/Nova/NovaTree.qml

import QtQuick
import QtQuick.Controls.Basic

/**
 * @created 2026-11-13 16:00:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    // ── 属性契约 ──
    property var treeData: []

    // 🚀 多选与图标支持
    property bool selectable: false
    property var selectedIds: []

    // 主题色接入
    property color baseColor: Theme.surface
    property color hoverColor: Theme.hover
    property color textColor: Theme.text_primary
    property color borderColor: Theme.border
    property color iconColor: Theme.text_secondary

    color: baseColor
    radius: Theme.radiusSm
    border.color: borderColor
    border.width: 1
    clip: true

    Behavior on color {
        ColorAnimation {
            duration: Theme.durationFast
        }
    }

    readonly property real rowHeight: Units.px(44)
    readonly property real indentWidth: Units.px(24)
    readonly property real fontSize: Units.px(14)

    // 维护展开状态
    property var expandedNodes: ({})
    ListModel {
        id: flatModel
    }

    onTreeDataChanged: {
        if (treeData && treeData.length > 0) {
            // 默认展开第一层
            for (let i = 0; i < treeData.length; i++) {
                expandedNodes[treeData[i].id] = true;
            }
        }
        rebuildModel();
    }

    function toggleNode(id) {
        let newExpanded = Object.assign({}, expandedNodes);
        newExpanded[id] = !newExpanded[id];
        expandedNodes = newExpanded;
        rebuildModel();
    }

    // 多选逻辑（父子级联）
    function toggleSelect(id, isChecked) {
        let newSelected = selectedIds.slice();

        function setChildrenState(nodeId, checked) {
            let idx = newSelected.indexOf(nodeId);
            if (checked && idx === -1) newSelected.push(nodeId);
            if (!checked && idx !== -1) newSelected.splice(idx, 1);

            function findNode(nodes, targetId) {
                for (let n of nodes) {
                    if (n.id === targetId) return n;
                    if (n.children) {
                        let found = findNode(n.children, targetId);
                        if (found) return found;
                    }
                }
                return null;
            }

            let node = findNode(treeData, nodeId);
            if (node && node.children) {
                for (let child of node.children) {
                    setChildrenState(child.id, checked);
                }
            }
        }

        setChildrenState(id, isChecked);
        selectedIds = newSelected;
    }

    function rebuildModel() {
        flatModel.clear();

        function traverse(nodes, level) {
            if (!nodes) return;
            for (let i = 0; i < nodes.length; i++) {
                let node = nodes[i];
                let hasChildren = !!(node.children && node.children.length > 0);
                let isExpanded = !!(expandedNodes[node.id] === true);

                flatModel.append({
                    nodeId: node.id,
                    label: node.label || "Unknown",
                    level: level,
                    hasChildren: hasChildren,
                    isExpanded: isExpanded,
                    icon: node.icon || ""
                });

                if (hasChildren && isExpanded) {
                    traverse(node.children, level + 1);
                }
            }
        }

        traverse(treeData, 0);
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 1
        clip: true
        model: flatModel
        reuseItems: true
        boundsBehavior: Flickable.StopAtBounds

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
            width: listView.width
            height: root.rowHeight

            property int nodeId: model.nodeId
            property string label: model.label
            property int level: model.level
            property bool hasChildren: model.hasChildren
            property bool isExpanded: model.isExpanded
            property string icon: model.icon
            property bool isSelected: root.selectedIds.indexOf(nodeId) > -1

            color: isSelected ? Theme.pressed : (rowMouse.containsMouse ? root.hoverColor : "transparent")
            Behavior on color {
                ColorAnimation {
                    duration: Theme.durationFast
                }
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        var globalPos = mapToItem(null, mouse.x, mouse.y);
                        root.nodeRightClicked(rowItem.nodeId, rowItem.label, globalPos.x, globalPos.y);
                    } else {
                        // 如果开了多选，点击行也可以触发勾选
                        if (root.selectable) {
                            root.toggleSelect(rowItem.nodeId, !rowItem.isSelected);
                        } else if (rowItem.hasChildren) {
                            // 没开多选，点行就折叠
                            root.toggleNode(rowItem.nodeId);
                        }
                        root.nodeClicked(rowItem.nodeId, rowItem.label);
                    }
                }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                x: rowItem.level * root.indentWidth + Units.px(8)
                spacing: Units.px(6)

                // 1. 折叠/展开箭头 (必须保留位置和点击区)
                Item {
                    width: Units.px(20)
                    height: Units.px(20)
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: rowItem.hasChildren ? (rowItem.isExpanded ? "▼" : "▶") : ""
                        color: root.iconColor
                        font.pixelSize: Units.px(12)
                        visible: rowItem.hasChildren
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: rowItem.hasChildren ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: rowItem.hasChildren
                        onClicked: root.toggleNode(rowItem.nodeId)
                    }
                }

                // 2. Checkbox 多选框
                Item {
                    width: root.selectable ? Units.px(20) : 0
                    height: Units.px(20)
                    visible: root.selectable
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.centerIn: parent
                        width: Units.px(16)
                        height: Units.px(16)
                        radius: Theme.radiusSm
                        color: rowItem.isSelected ? Theme.primary : "transparent"
                        border.width: 2
                        border.color: rowItem.isSelected ? Theme.primary : Theme.border

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: Theme.white
                            font.pixelSize: Units.px(10)
                            font.bold: true
                            visible: rowItem.isSelected
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleSelect(rowItem.nodeId, !rowItem.isSelected)
                        }
                    }
                }

                // 3. 图标 (如果有)
                Text {
                    visible: rowItem.icon !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: rowItem.icon
                    font.pixelSize: Units.px(16)
                }

                // 4. 节点文字
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: rowItem.label
                    color: root.textColor
                    font.pixelSize: root.fontSize
                    font.bold: rowItem.level === 0
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: root.borderColor
                opacity: 0.1
            }
        }
    }

    signal nodeClicked(var nodeId, var label)

    signal nodeRightClicked(var nodeId, var label, var x, var y)
}