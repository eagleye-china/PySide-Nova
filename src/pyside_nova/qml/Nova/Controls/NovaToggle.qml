// src/pyside_nova/qml/Nova/Controls/NovaToggle.qml
// NovaToggle 开关：轨道+滑块换装 NovaCheckbox（复用三态/toggleOrder/val 全部值语义）
// 对标 Quasar QToggle（use-checkbox 18 + icon/iconColor）
// 契约统一：label / hint / error / readonly / disable
import QtQuick
import Nova.Services

NovaCheckbox {
    id: root

    // ── 对标 QToggle 扩展 ─────────────────────────────────────
    property string icon: ""                 // 滑块内置图标（对标 icon）
    property color iconColor: "#FFFFFF"      // 对标 icon-color

    // ── 外观派生 ──────────────────────────────────────────────
    readonly property real _trackW: dense ? 30 : 36
    readonly property real _trackH: dense ? 16 : 20
    readonly property real _thumbD: dense ? 12 : 14

    visualWidth: _trackW

    // 换装：覆盖 NovaCheckbox 的 visual 插槽（勾选框 → 开关）
    visual: Component {
        Item {
            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                x: (parent.width - root._trackW) / 2
                width: root._trackW; height: root._trackH; radius: root._trackH / 2
                color: root.checked || root.indeterminate
                       ? (root.hasError ? NovaTheme.negative
                          : root.readonly ? Qt.darker(root.tint, 1.2) : root.tint)
                       : NovaTheme.surfaceAlt
                border.width: 1
                border.color: root.checked || root.indeterminate ? "transparent" : NovaTheme.outline
                opacity: root.disable ? 0.5 : 1
                Behavior on color { ColorAnimation { duration: 180 } }
            }
            Rectangle {
                id: thumb
                anchors.verticalCenter: parent.verticalCenter
                x: ((root.checked || root.indeterminate)
                    ? root._trackW - root._thumbD - 3 : 3)
                   + (parent.width - root._trackW) / 2
                width: root._thumbD; height: root._thumbD; radius: root._thumbD / 2
                color: root.checked || root.indeterminate
                       ? NovaTheme.textOnPrimary : NovaTheme.outline
                scale: root.disable ? 0.8 : 1
                Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 180 } }
            }
            // 对标 icon / icon-color（滑块内置图标）
            NovaIcon {
                anchors.centerIn: thumb
                visible: root.icon !== "" && (root.checked || root.indeterminate)
                icon: root.icon
                size: root._thumbD - 4
                color: root.iconColor
            }
        }
    }
}
