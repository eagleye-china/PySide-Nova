// src/pyside_nova/qml/Nova/Controls/NovaTab.qml
// NovaTab 标签页单项（对标 QTab）：name/label/icon/alert + default 槽自定义内容；
// 激活态由宿主 NovaTabs 下发（tabsRef 注入），点击经 requestClick 统一上报（受控契约，
// 坑位 22：Tab 自身不写 modelValue，宿主绑定 + updateModelValue 写回）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 默认槽：自定义内容（有则替代 label/icon） ─────────────
    default property alias content: slotBox.data

    property string name: ""      // 面板寻址名；空则宿主以序号寻址
    property string label: ""     // 文案
    property string icon: ""      // 图标
    property var alert: false     // true→红点 | 字符串→徽标文案（对标 alert Boolean/String）
    property string alertIcon: "" // 浮动图标提示（alert 为真且设置时显示）
    property bool noCaps: false   // 不做全大写（QML 文本不做 CSS 大写变换，此属性仅透传口径）
    property bool disable: false

    // 宿主注入（NovaTabs）
    property var tabsRef: null
    readonly property bool isActive: tabsRef !== null && tabsRef._isActive(this)

    readonly property bool isNovaTab: true

    signal clicked()

    function requestClick() {
        if (disable) return
        clicked()
        if (tabsRef !== null)
            tabsRef._goToTab(this)
    }

    // ── 尺寸（宿主布局消费） ─────────────────────────────────
    readonly property real _tabH: (tabsRef !== null && tabsRef.dense) ? 36 : 48
    implicitHeight: _tabH
    implicitWidth: contentRow.implicitWidth + NovaTheme.spacingM * 2.5

    // 覆盖背景（激活态 bg；横向模式指示条画在宿主，垂直模式这里带左侧条）
    Rectangle {
        anchors.fill: parent
        radius: NovaTheme.radiusS
        color: root.isActive && root.tabsRef !== null
               && root.tabsRef.activeBgColor.a > 0
               ? root.tabsRef.activeBgColor : "transparent"
        visible: root.isActive
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: NovaTheme.spacingS

        NovaIcon {
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
            icon: root.icon
            size: 20
            color: root.isActive
                   ? (root.tabsRef !== null ? root.tabsRef.activeColor : NovaTheme.primary)
                   : NovaTheme.textMuted
        }

        Item { id: slotBox; width: childrenRect.width; height: childrenRect.height }

        Text {
            visible: root.label !== "" && slotBox.children.length === 0
            text: root.label
            font.pixelSize: NovaTheme.fontM
            font.capitalization: root.noCaps ? Font.MixedCase : Font.AllUppercase
            font.weight: root.isActive ? Font.DemiBold : Font.Medium
            color: root.isActive
                   ? (root.tabsRef !== null ? root.tabsRef.activeColor : NovaTheme.textColor)
                   : NovaTheme.textColor
            anchors.verticalCenter: parent.verticalCenter
        }

        // alert：红点或徽标文案
        Rectangle {
            visible: root.alert === true && root.alertIcon === ""
            width: 8; height: 8; radius: 4
            color: NovaTheme.negative
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle {
            visible: root.alert !== true && root.alert !== false && root.alert !== ""
            width: alertTxt.implicitWidth + 10
            height: 18
            radius: 9
            color: NovaTheme.negative
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: alertTxt
                anchors.centerIn: parent
                text: String(root.alert)
                font.pixelSize: NovaTheme.fontXS
                color: "#FFFFFF"
            }
        }
        NovaIcon {
            visible: root.alert !== false && root.alertIcon !== ""
            anchors.verticalCenter: parent.verticalCenter
            icon: root.alertIcon
            size: 16
            color: NovaTheme.negative
        }
    }

    function contentChildrenPlaceholder() { return slotBox.children.length }    opacity: disable ? 0.45 : 1

    MouseArea {
        anchors.fill: parent
        enabled: !root.disable
        cursorShape: root.disable ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: root.requestClick()
    }
}
