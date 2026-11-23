// src/pyside_nova/qml/Nova/Controls/NovaBreadcrumbsEl.qml
// NovaBreadcrumbsEl 面包屑条目（对标 QBreadcrumbsEl）：label/icon/disable + default 槽；
// to/href 路由语义 ⛔（无路由体系），点击统一 clicked 信号由宿主处理
import QtQuick
import Nova.Services
import Nova.Behaviors
import Nova.Design

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.Link
    Accessible.name: a11yLabel !== "" ? a11yLabel : label
    Accessible.focusable: !disable
    Accessible.focused: activeFocus
    activeFocusOnTab: !disable
    enabled: !disable
    Keys.onReturnPressed: root.requestClick()
    Keys.onEnterPressed: root.requestClick()
    Keys.onSpacePressed: root.requestClick()

    // ── 默认槽：条目自定义内容（有则替代 label/icon） ─────────
    default property alias content: slotBox.data

    property string label: ""      // 条目文案
    property string icon: ""       // 条目图标
    property bool disable: false   // 禁用（不可点击）

    // 宿主（NovaBreadcrumbs）注入：激活态着色与间距统一管理
    property var crumbsRef: null
    readonly property bool isActiveColor: crumbsRef !== null
        && crumbsRef.isActiveEl(this)

    signal clicked()

    function requestClick() {
        if (disable) return
        clicked()
    }

    implicitWidth: box.implicitWidth + NovaTheme.spacingS * 2
    implicitHeight: Math.max(24, box.implicitHeight)

    Row {
        id: box
        anchors.centerIn: parent
        spacing: NovaTheme.spacingS

        NovaIcon {
            visible: root.icon !== ""
            icon: root.icon
            size: 18
            color: root.disable ? NovaTheme.textMuted
                  : (root.isActiveColor ? NovaTheme.primary : NovaTheme.textColor)
        }
        Text {
            visible: root.label !== ""
            text: root.label
            font.pixelSize: NovaTheme.fontM
            color: root.disable ? NovaTheme.textMuted
                  : (root.isActiveColor ? NovaTheme.primary : NovaTheme.textColor)
        }

        Item { id: slotBox; width: childrenRect.width; height: childrenRect.height }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !root.disable
        cursorShape: root.disable ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: root.requestClick()
    }
    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
