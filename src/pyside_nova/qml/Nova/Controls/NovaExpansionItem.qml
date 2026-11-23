// src/pyside_nova/qml/Nova/Controls/NovaExpansionItem.qml
// NovaExpansionItem 展开项（对标 QExpansionItem）：header（icon/label/caption 或 header
// 命名槽）+ 动画展开内容；group 手风琴（ExpansionGroups.js 注册表互斥收起）；
// 受控契约（坑位 22）：expanded 默认绑定 defaultOpened（宿主未绑时的初值），组件自身
// 只 emit updateModelValue(bool) 不自写；show/beforeShow/hide/beforeHide/afterShow/
// afterHide 全事件；show/hide/toggle 方法
import QtQuick
import "ExpansionGroups.js" as ExpGroups
import Nova.Services
import Nova.Behaviors
import Nova.Design

Rectangle {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.Button
    Accessible.name: a11yLabel !== "" ? a11yLabel : label
    Accessible.checkable: true
    Accessible.checked: expanded
    Accessible.focusable: !disable
    Accessible.focused: activeFocus
    activeFocusOnTab: !disable
    Keys.onReturnPressed: root.requestToggle()
    Keys.onEnterPressed: root.requestToggle()
    Keys.onSpacePressed: root.requestToggle()
    Keys.onEscapePressed: root.hide()

    // ── 默认槽：展开内容 ────────────────────────────────────
    default property alias content: body.data

    // ── 命名槽：自定义头部（对标 header 槽） ─────────────────
    property alias header: headerSlot.data

    // ── 受控契约 ────────────────────────────────────────────
    property bool defaultOpened: false    // 初始展开（宿主未绑 expanded 时的初值）
    property bool expanded: defaultOpened // 宿主绑定后以宿主为准
    signal updateModelValue(bool expanded)
    signal beforeShow()
    signal shown()
    signal beforeHide()
    signal hidden()
    signal afterShow()
    signal afterHide()

    // ⛔ Quasar 的 show/hide 事件名与 QML 信号 shown/hidden 撞名规避（坑位 25 口径）；
    //   Quasar show 语义 = show() 触发后 → 本组件 shown；after-show = 动画结束后 afterShow

    // ── 行为（对标 QExpansionItem props） ───────────────────
    property string label: ""
    property string caption: ""
    property int labelLines: 0            // 0 = 不限行（单行省略）
    property int captionLines: 0
    property string icon: ""
    property string expandIcon: "mdi:chevron-down"
    property string expandedIcon: ""      // 展开态替换图标；空则沿用 expandIcon
    property bool hideExpandIcon: false
    property bool expandIconToggle: false // 仅图标区响应切换（头部其余区域不触发）
    property bool switchToggleSide: false // 展开图标换到左侧（默认右侧）
    property bool denseToggle: false
    property bool dense: false
    property int duration: 300
    property real headerInsetLevel: 0
    property real contentInsetLevel: 0
    property bool expandSeparator: false  // 展开时上下分隔线
    property string group: ""             // 手风琴组名（同名互斥）
    property bool popup: false            // popup 模式：展开区浮出描边
    property bool disable: false
    property color tint: NovaTheme.primary   // 对标 QItem color 口径（基调色红线）

    // ⛔ to/href/active-class 系：无路由体系；⛔ dark：主题自动跟随

    color: "transparent"
    radius: NovaTheme.radiusS
    implicitWidth: 320
    height: implicitHeight
    implicitHeight: headerRow.implicitHeight + NovaTheme.spacingS * 2
                    + contentClip.height + (expandSeparator && expanded ? 2 : 0)

    opacity: disable ? 0.55 : 1

    Component.onCompleted: ExpGroups.register(root)
    Component.onDestruction: ExpGroups.unregister(root)
    onGroupChanged: {
        ExpGroups.unregister(root)
        ExpGroups.register(root)
    }

    // ── 动作（对标 show/hide/toggle 方法；只 emit 不自写） ──
    function show() {
        if (disable || expanded) return
        beforeShow()
        ExpGroups.closeOthers(root)   // 手风琴互斥（组内收起走各自受控上报）
        updateModelValue(true)
        shown()
        Qt.callLater(function () { afterShow() })
    }
    function hide() {
        if (disable || !expanded) return
        beforeHide()
        updateModelValue(false)
        hidden()
        Qt.callLater(function () { afterHide() })
    }
    function toggle() {
        expanded ? hide() : show()
    }

    // 组内互斥收起（ExpansionGroups 调用；不再触发 closeOthers 防连锁风暴）
    function _closeByGroup() {
        if (!expanded || disable) return
        beforeHide()
        updateModelValue(false)
        hidden()
        Qt.callLater(function () { afterHide() })
    }

    function requestToggle() {
        if (disable) return
        toggle()
    }

    // ── 头部行（手动布局：switchToggleSide 决定图标左右） ────
    Item {
        id: headerRow
        x: 0
        y: NovaTheme.spacingS
        width: parent.width
        height: Math.max(root.dense ? 32 : 44,
                         contentCol.implicitHeight)

        readonly property real insetX: NovaTheme.spacingM + root.headerInsetLevel * 24
        readonly property real iconW: root.hideExpandIcon ? 0 : (root.denseToggle ? 24 : 32)

        // 头部主体：自定义 header 命名槽优先，否则便捷 label/caption
        Column {
            id: contentCol
            x: headerRow.insetX + (root.switchToggleSide ? headerRow.iconW + NovaTheme.spacingM : 0)
            width: headerRow.width - headerRow.insetX - headerRow.iconW
                   - (root.switchToggleSide ? NovaTheme.spacingM : 0) - NovaTheme.spacingM
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Item {
                id: headerSlot
                width: childrenRect.width
                height: childrenRect.height
                visible: children.length > 0
            }

            Text {
                visible: headerSlot.children.length === 0 && root.label !== ""
                text: root.label
                color: root.expanded ? root.tint : NovaTheme.textColor
                font.pixelSize: NovaTheme.fontM
                elide: Text.ElideRight
                width: parent.width
                maximumLineCount: root.labelLines > 0 ? root.labelLines : 1
                wrapMode: root.labelLines > 1 ? Text.Wrap : Text.NoWrap
            }
            Text {
                visible: headerSlot.children.length === 0 && root.caption !== ""
                text: root.caption
                color: NovaTheme.textMuted
                font.pixelSize: NovaTheme.fontS
                elide: Text.ElideRight
                width: parent.width
                maximumLineCount: root.captionLines > 0 ? root.captionLines : 1
                wrapMode: root.captionLines > 1 ? Text.Wrap : Text.NoWrap
            }
        }

        // 展开图标（switchToggleSide → 左侧；默认右侧）
        Item {
            id: iconBox
            width: headerRow.iconW
            height: headerRow.height
            x: root.switchToggleSide
               ? headerRow.insetX
               : headerRow.width - headerRow.iconW - NovaTheme.spacingM
            anchors.verticalCenter: parent.verticalCenter

            NovaIcon {
                anchors.centerIn: parent
                visible: !root.hideExpandIcon
                icon: root.expanded && root.expandedIcon !== ""
                      ? root.expandedIcon : root.expandIcon
                size: root.denseToggle ? 18 : 22
                color: root.expanded ? root.tint : NovaTheme.textMuted
            }
            MouseArea {
                anchors.fill: parent
                enabled: !root.hideExpandIcon && !root.disable
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.expandIconToggle)
                        root.requestToggle()
                }
            }
        }

        // 头部整体点击（expandIconToggle 时仅图标区响应）
        MouseArea {
            anchors.fill: parent
            enabled: !root.disable && !root.expandIconToggle
            cursorShape: Qt.PointingHandCursor
            onClicked: root.requestToggle()
        }
    }

    // 展开分隔线（上）
    Rectangle {
        anchors { left: parent.left; right: parent.right; top: headerRow.bottom }
        height: 1
        color: NovaTheme.outline
        visible: root.expandSeparator && root.expanded
    }

    // 展开内容（高度动画揭示；几何随 expanded 变化——宿主写回后生效）
    Item {
        id: contentClip
        x: 0
        y: headerRow.y + headerRow.height + 1
        width: parent.width
        height: root.expanded ? body.implicitHeight + NovaTheme.spacingS * 2 : 0
        clip: true

        Behavior on height {
            NumberAnimation { duration: root.duration }
        }

        Item {
            id: body
            x: NovaTheme.spacingM + root.contentInsetLevel * 24
            y: NovaTheme.spacingS
            width: parent.width - x - NovaTheme.spacingM
            height: implicitHeight
        }
    }

    // 展开分隔线（下）
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: NovaTheme.outline
        visible: root.expandSeparator && root.expanded
    }

    // popup 模式：展开区描边
    Rectangle {
        anchors.fill: contentClip
        color: "transparent"
        border.color: NovaTheme.outline
        visible: root.popup && root.expanded
        radius: NovaTheme.radiusS
    }

    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
