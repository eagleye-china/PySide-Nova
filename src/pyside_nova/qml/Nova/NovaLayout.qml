// src/pyside_nova/qml/Nova/NovaLayout.qml

import QtQuick

/**
 * @created 2026-11-13 10:53:29
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Item {
    id: root

    property bool horizontal: true
    property real spacing: Theme.spaceSm
    property bool wrap: false
    property string justify: "start"
    property string align: "start"

    default property alias contentData: flowEngine.data

    implicitWidth: flowEngine.childrenRect.width
    implicitHeight: flowEngine.childrenRect.height

    Flow {
        id: flowEngine
        flow: root.horizontal ? Flow.LeftToRight : Flow.TopToBottom
        spacing: Units.px(root.spacing)

        width: root.wrap ? root.width : 999999
        height: root.wrap ? root.height : 999999

        x: {
            if (root.wrap) return 0;
            const contentWidth = childrenRect.width;
            const rootWidth = root.width > 0 ? root.width : contentWidth;
            if (root.horizontal) {
                if (root.justify === "center" || root.justify === "space-around") return (rootWidth - contentWidth) / 2;
                if (root.justify === "end") return rootWidth - contentWidth;
                return 0;
            } else {
                if (root.align === "center") return (rootWidth - contentWidth) / 2;
                if (root.align === "end") return rootWidth - contentWidth;
                return 0;
            }
        }

        y: {
            if (root.wrap) return 0;
            const contentHeight = childrenRect.height;
            const rootHeight = root.height > 0 ? root.height : contentHeight;
            if (root.horizontal) {
                if (root.align === "center") return (rootHeight - contentHeight) / 2;
                if (root.align === "end") return rootHeight - contentHeight;
                return 0;
            } else {
                if (root.justify === "center" || root.justify === "space-around") return (rootHeight - contentHeight) / 2;
                if (root.justify === "end") return rootHeight - contentHeight;
                return 0;
            }
        }
    }
}