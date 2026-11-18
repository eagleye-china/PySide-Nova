import QtQuick
import QtQuick.Controls.Basic

/**
 * @created 2026-11-18 10:30:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Rectangle {
    id: root

    property var treeData: []
    property bool selectable: false
    property var selectedIds: []
    property string utilityClasses: ""

    readonly property color _utilBg: NovaUtilityCore.bgColorOf(utilityClasses)
    readonly property color _utilText: NovaUtilityCore.textColorOf(utilityClasses)

    property alias itemSlotContent: itemSlot.children

    property color baseColor: _utilBg !== "transparent" ? _utilBg : Theme.surface
    property color hoverColor: Theme.hover
    property color textColor: _utilText !== "transparent" ? _utilText : Theme.text_primary
    property color borderColor: Theme.border
    property color iconColor: Theme.text_secondary

    color: baseColor
    radius: Theme.radiusSm
    border.color: borderColor
    border.width: 1
    clip: true

    readonly property real rowHeight: Units.px(44)
    readonly property real indentWidth: Units.px(24)
    readonly property real fontSize: Units.px(14)

    property var expandedNodes: ({})
    ListModel { id: flatModel }
    Item { 
        id: itemSlot
        property var scope: ({ nodeId: -1, label: "", level: 0 })
    }

    onTreeDataChanged: {
        if (treeData && treeData.length > 0) {
            for (let i = 0; i < treeData.length; i++) expandedNodes[treeData[i].id] = true;
        }
        rebuildModel();
    }

    function toggleNode(id) {
        let newExpanded = Object.assign({}, expandedNodes);
        newExpanded[id] = !newExpanded[id];
        expandedNodes = newExpanded;
        rebuildModel();
    }

    function toggleSelect(id, isChecked) {
        let newSelected = selectedIds.slice();
        function setChildrenState(nodeId, checked) {
            let idx = newSelected.indexOf(nodeId);
            if (checked && idx === -1) newSelected.push(nodeId);
            if (!checked && idx !== -1) newSelected.splice(idx, 1);
            function findNode(nodes, targetId) {
                for (let n of nodes) {
                    if (n.id === targetId) return n;
                    if (n.children) { let found = findNode(n.children, targetId); if (found) return found; }
                }
                return null;
            }
            let node = findNode(treeData, nodeId);
            if (node && node.children) { for (let child of node.children) setChildrenState(child.id, checked); }
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
                flatModel.append({ nodeId: node.id, label: node.label || "Unknown", level: level, hasChildren: hasChildren, isExpanded: isExpanded, icon: node.icon || "" });
                if (hasChildren && isExpanded) traverse(node.children, level + 1);
            }
        }
        traverse(treeData, 0);
    }

    ListView {
        id: listView
        anchors.fill: parent; anchors.margins: 1; clip: true; model: flatModel; reuseItems: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar { id: vbar; active: true; policy: ScrollBar.AsNeeded; contentItem: Rectangle { implicitWidth: Units.px(6); radius: Units.px(3); color: root.borderColor; opacity: vbar.pressed ? 0.8 : 0.4 } }

        delegate: Rectangle {
            id: rowItem
            width: listView.width; height: root.rowHeight
            property int nodeId: model.nodeId
            property string label: model.label
            property int level: model.level
            property bool hasChildren: model.hasChildren
            property bool isExpanded: model.isExpanded
            property string icon: model.icon
            property bool isSelected: root.selectedIds.indexOf(nodeId) > -1

            color: isSelected ? Theme.pressed : (rowMouse.containsMouse ? root.hoverColor : "transparent")

            MouseArea {
                id: rowMouse; anchors.fill: parent; hoverEnabled: true
                onClicked: (mouse) => {
                    root.itemSlot.scope = { nodeId: rowItem.nodeId, label: rowItem.label, level: rowItem.level };
                    if (mouse.button === Qt.RightButton) {
                        var globalPos = mapToItem(null, mouse.x, mouse.y);
                        root.nodeRightClicked(rowItem.nodeId, rowItem.label, globalPos.x, globalPos.y);
                    } else {
                        if (root.selectable) root.toggleSelect(rowItem.nodeId, !rowItem.isSelected);
                        else if (rowItem.hasChildren) root.toggleNode(rowItem.nodeId);
                        root.nodeClicked(rowItem.nodeId, rowItem.label);
                    }
                }
            }

            Loader {
                anchors.fill: parent
                active: root.itemSlotContent.length > 0
                sourceComponent: itemSlot
            }

            Row {
                visible: root.itemSlotContent.length === 0
                anchors.verticalCenter: parent.verticalCenter
                x: rowItem.level * root.indentWidth + Units.px(8)
                spacing: Units.px(6)

                Item {
                    width: Units.px(20); height: Units.px(20)
                    Text { anchors.centerIn: parent; text: rowItem.hasChildren ? (rowItem.isExpanded ? "▼" : "▶") : ""; color: root.iconColor; font.pixelSize: Units.px(12); visible: rowItem.hasChildren }
                    MouseArea { anchors.fill: parent; cursorShape: rowItem.hasChildren ? Qt.PointingHandCursor : Qt.ArrowCursor; enabled: rowItem.hasChildren; onClicked: root.toggleNode(rowItem.nodeId) }
                }
                Item {
                    width: root.selectable ? Units.px(20) : 0; height: Units.px(20); visible: root.selectable
                    Rectangle {
                        anchors.centerIn: parent; width: Units.px(16); height: Units.px(16); radius: Theme.radiusSm
                        color: rowItem.isSelected ? Theme.primary : "transparent"; border.width: 2; border.color: rowItem.isSelected ? Theme.primary : Theme.border
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleSelect(rowItem.nodeId, !rowItem.isSelected) }
                    }
                }
                Text { visible: rowItem.icon !== ""; anchors.verticalCenter: parent.verticalCenter; text: rowItem.icon; font.pixelSize: Units.px(16) }
                Text { anchors.verticalCenter: parent.verticalCenter; text: rowItem.label; color: root.textColor; font.pixelSize: root.fontSize; font.bold: rowItem.level === 0 }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.borderColor; opacity: 0.1 }
        }
    }
    signal nodeClicked(var nodeId, var label)
    signal nodeRightClicked(var nodeId, var label, var x, var y)
}
