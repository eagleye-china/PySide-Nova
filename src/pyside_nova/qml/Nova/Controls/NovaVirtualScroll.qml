// src/pyside_nova/qml/Nova/Controls/NovaVirtualScroll.qml
// NovaVirtualScroll 虚拟滚动容器（对标 QVirtualScroll）
// items 数组 + delegate 组件 → 内部 ListView 真虚拟化（仅渲染可视窗口 + reuseItems）
import QtQuick
import QtQuick.Controls.Basic
import Nova.Services

Flickable {
    id: root

    property var items: []                  // 数据数组（任意元素）
    property Component delegate: null       // 行渲染组件（必填，可读 modelData/index）
    property real itemSize: 48              // 统一行高（当前实现要求等高）

    clip: true
    contentWidth: width
    contentHeight: Math.max(height, lv.count * itemSize + NovaTheme.spacingS * 2)

    function scrollToIndex(i) {
        contentY = Math.max(0, Math.min(contentHeight - height, i * itemSize))
        lv.contentY = contentY
        lv.forceLayout()
    }

    onContentYChanged: lv.contentY = contentY

    ListView {
        id: lv
        x: 0
        y: NovaTheme.spacingS
        width: parent.width
        height: root.contentHeight
        interactive: false
        model: root.items
        delegate: root.delegate
        reuseItems: true
        cacheBuffer: 240
    }
}
