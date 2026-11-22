// src/pyside_nova/qml/Nova/Controls/NovaItem.qml
// NovaItem 列表条目（对标 QItem）
// 槽：default（主内容）/ leading（左头像图标区，对标 QItemSection left）/
//     trailing（右侧区）/ expandContent（展开内容区，仅 expanded 时显示）
// 可展开模式（expandable）：expandRequested(bool) 受控上报，宿主写回 expanded；
// 在 NovaList.accordion 容器中自动收起兄弟
import QtQuick
import Nova.Services

Rectangle {
    id: root

    default property alias content: mid.data
    // 坑位 25 同款：left 为 Item FINAL 属性不可覆盖 → leading
    property alias leading: leftSlot.data
    property alias trailing: sideSlot.data  // 对标 QItemSection side
    property alias expandContent: expandBody.data

    property string label: ""               // 便捷主文案
    property string caption: ""             // 便捷副文案
    property string icon: ""                // 便捷左图标
    property bool clickable: false
    property bool active: false             // 激活高亮
    property bool disable: false
    property bool expandable: false         // 可展开（点击切换）
    property bool expanded: false           // 受控
    property bool manualExpand: false       // true=展开状态完全由宿主管（点击只上报）

    // NovaList 注入
    property var listRef: null

    signal clicked()
    signal expandRequested(bool expanded)

    // 展开请求统一入口（受控上报 + 手风琴协调）；MouseArea 与测试共用
    function requestExpand() {
        if (disable || !expandable)
            return
        expandRequested(!expanded)
        if (!manualExpand && listRef)
            listRef.collapseSiblings(root)
    }

    function requestClick() {
        if (disable || !clickable || expandable)
            return
        clicked()
    }

    radius: NovaTheme.radiusS
    color: active ? Qt.rgba(NovaTheme.primary.r, NovaTheme.primary.g, NovaTheme.primary.b, 0.10)
                  : "transparent"
    implicitWidth: 320
    implicitHeight: Math.max(listRef && listRef.dense ? 36 : 48,
                             row.implicitHeight + NovaTheme.spacingS * 2)
                     + (expandable && expanded ? expandBody.height + 6 : 0)
    height: implicitHeight
    opacity: disable ? 0.5 : 1

    Row {
        id: row
        x: NovaTheme.spacingM
        y: (Math.max(listRef && listRef.dense ? 36 : 48, implicitHeight) - height) / 2
        width: parent.width - NovaTheme.spacingM * 2
        spacing: NovaTheme.spacingM

        // 左分区
        Item {
            id: leftSlot
            width: childrenRect.width
            height: childrenRect.height
            anchors.verticalCenter: parent.verticalCenter
            NovaIcon {
                visible: root.icon !== ""
                icon: root.icon
                size: 22
                color: root.active ? NovaTheme.primary : NovaTheme.textMuted
            }
        }

        // 主内容
        Column {
            id: mid
            width: parent.width - leftSlot.width - sideSlot.width - NovaTheme.spacingM * 4
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                visible: root.label !== ""
                text: root.label
                color: root.active ? NovaTheme.primary : NovaTheme.textColor
                font.pixelSize: NovaTheme.fontM
                elide: Text.ElideRight
                width: parent.width
            }
            Text {
                visible: root.caption !== ""
                text: root.caption
                color: NovaTheme.textMuted
                font.pixelSize: NovaTheme.fontS
                elide: Text.ElideRight
                width: parent.width
            }
        }

        // 右分区
        Item {
            id: sideSlot
            width: childrenRect.width
            height: childrenRect.height
            anchors.verticalCenter: parent.verticalCenter
        }

        // 展开指示
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.expandable
            text: root.expanded ? "▾" : "▸"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontS
        }
    }

    // 展开内容区（仅 expandable && expanded 时占位显示）
    Column {
        id: expandBody
        x: NovaTheme.spacingM + 24
        y: row.y + row.height + 4
        width: parent.width - NovaTheme.spacingM * 2 - 24
        visible: root.expandable && root.expanded
        height: visible ? implicitHeight : 0
        spacing: 4
    }

    // 分隔线（NovaList.separator 注入；最后一条不画）
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: NovaTheme.outline
        opacity: 0.6
        visible: listRef !== null && listRef.separator === true && !listRef.isLastItem(root)
    }

    MouseArea {
        anchors.fill: parent
        enabled: !disable
        cursorShape: (clickable || expandable) ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: expandable ? requestExpand() : requestClick()
    }
}
