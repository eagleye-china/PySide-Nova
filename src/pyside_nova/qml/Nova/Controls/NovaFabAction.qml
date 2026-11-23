// src/pyside_nova/qml/Nova/Controls/NovaFabAction.qml
// NovaFabAction 悬浮按钮动作（对标 QFabAction）：圆钮 + 外置 label；revealed/_delay
// 由宿主 NovaFab 级联下发（stagger 节拍），本组件只做渐显/缩放响应；
// to 路由语义 ⛔（无路由体系），点击统一 clicked 信号
import QtQuick
import Nova.Services
import Nova.Behaviors
import Nova.Design

Item {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.Button
    Accessible.name: a11yLabel !== "" ? a11yLabel : label
    Accessible.focusable: revealed && !disable
    Accessible.focused: activeFocus
    activeFocusOnTab: revealed && !disable
    enabled: !disable
    Keys.onReturnPressed: root.click()
    Keys.onEnterPressed: root.click()
    Keys.onSpacePressed: root.click()

    // ── 默认槽：自定义内容（有则替代 icon） ──────────────────
    default property alias content: slotBox.data

    property string icon: ""
    property string label: ""           // 外置标签文案（externalLabel 语义恒定：宿主侧展开）
    property bool hideLabel: false
    property color tint: NovaTheme.primary   // 基调色红线
    property color textColor: NovaTheme.textOnPrimary
    property bool square: false
    property bool disable: false
    property string anchor: ""          // 对齐锚（空=沿用宿主方向）

    // 宿主级联注入
    property bool revealed: false       // 展开态（宿主按 stagger 节拍逐个置真）
    property int delay: 0               // 本动作的级联延迟（ms）

    signal clicked()

    function click() {
        if (disable) return
        clicked()   // 对标 click() 方法（模拟点击）
    }

    implicitWidth: 44
    implicitHeight: 44

    opacity: revealed ? 1 : 0
    scale: revealed ? 1 : 0.4

    Behavior on opacity { NumberAnimation { duration: 160 } }
    Behavior on scale { NumberAnimation { duration: 160 } }

    Row {
        anchors.centerIn: parent
        spacing: NovaTheme.spacingS

        // 外置标签（宿主方向布局下渲染在按钮旁）
        Rectangle {
            visible: !root.hideLabel && root.label !== ""
            height: 26
            width: labelTxt.implicitWidth + 14
            radius: 13
            color: NovaTheme.dark
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: labelTxt
                anchors.centerIn: parent
                text: root.label
                color: NovaTheme.textOnPrimary
                font.pixelSize: NovaTheme.fontS
            }
        }

        Rectangle {
            id: dot
            width: 40
            height: 40
            radius: root.square ? NovaTheme.radiusS : 20
            color: root.tint
            anchors.verticalCenter: parent.verticalCenter
            opacity: root.disable ? 0.5 : 1

            NovaIcon {
                anchors.centerIn: parent
                visible: root.icon !== "" && slotBox.children.length === 0
                icon: root.icon
                size: 20
                color: root.textColor
            }

            Item {
                id: slotBox
                anchors.centerIn: parent
                width: childrenRect.width
                height: childrenRect.height
            }

            MouseArea {
                anchors.fill: parent
                enabled: !root.disable
                cursorShape: root.disable ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: root.click()
            }
        }
    }
    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
