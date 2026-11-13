// examples/01_minimal/main.qml

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Nova 1.0

ApplicationWindow {
    visible: true
    width: 1280
    height: 800
    title: "Nova 工业级仪表盘大屏 (NovaTree 测试)"
    color: Theme.background

    // ── 1. 顶部 Header ──
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Units.px(Theme.spaceLg)
        height: Units.px(72)
        color: Theme.surface
        radius: Theme.radiusMd
        border.color: Theme.border
        border.width: 1

        NovaLayout {
            anchors.fill: parent
            anchors.leftMargin: Units.px(Theme.spaceLg)
            anchors.rightMargin: Units.px(Theme.spaceLg)
            justify: "space-between"
            align: "center"

            Text {
                text: "Nova 工业监控平台"
                color: Theme.text_primary
                font.pixelSize: Units.px(22)
                font.bold: true
            }

            NovaLayout {
                spacing: Units.px(Theme.spaceMd)
                align: "center"

                NovaInput {
                    width: Units.px(240)
                    placeholderText: "🔍 搜索设备节点..."
                }

                NovaButton {
                    text: "刷新数据"
                    primary: false
                    onClicked: console.log("🔄 刷新数据...")
                }

                NovaButton {
                    text: "🌓 切换明暗"
                    primary: true
                    onClicked: {
                        ThemeManager.mode = (Theme.mode === "light" ? "dark" : "light");
                    }
                }
            }
        }
    }

    // ── 2. 左侧统计卡片区 ──
    Column {
        id: leftPanel
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Units.px(Theme.spaceLg)
        anchors.topMargin: Units.px(Theme.spaceLg)
        width: Units.px(260)
        spacing: Units.px(Theme.spaceLg)

        // 卡片 1
        Rectangle {
            width: parent.width
            height: Units.px(130)
            color: Theme.surface
            radius: Theme.radiusMd
            border.color: Theme.border
            border.width: 1

            Text {
                anchors.top: parent.top; anchors.topMargin: Units.px(Theme.spaceMd); anchors.left: parent.left; anchors.leftMargin: Units.px(Theme.spaceMd); text: "总设备数"; color: Theme.text_secondary; font.pixelSize: Units.px(14)
            }
            Text {
                anchors.bottom: parent.bottom; anchors.bottomMargin: Units.px(Theme.spaceMd); anchors.left: parent.left; anchors.leftMargin: Units.px(Theme.spaceMd); text: "5,000"; color: Theme.primary; font.pixelSize: Units.px(32); font.bold: true
            }
        }

        // 卡片 2
        Rectangle {
            width: parent.width
            height: Units.px(130)
            color: Theme.surface
            radius: Theme.radiusMd
            border.color: Theme.border
            border.width: 1

            Text {
                anchors.top: parent.top; anchors.topMargin: Units.px(Theme.spaceMd); anchors.left: parent.left; anchors.leftMargin: Units.px(Theme.spaceMd); text: "运行中"; color: Theme.text_secondary; font.pixelSize: Units.px(14)
            }
            Text {
                anchors.bottom: parent.bottom; anchors.bottomMargin: Units.px(Theme.spaceMd); anchors.left: parent.left; anchors.leftMargin: Units.px(Theme.spaceMd); text: "2,345"; color: Theme.positive; font.pixelSize: Units.px(32); font.bold: true
            }
        }

        // 卡片 3
        Rectangle {
            width: parent.width
            height: Units.px(130)
            color: Theme.surface
            radius: Theme.radiusMd
            border.color: Theme.border
            border.width: 1

            Text {
                anchors.top: parent.top; anchors.topMargin: Units.px(Theme.spaceMd); anchors.left: parent.left; anchors.leftMargin: Units.px(Theme.spaceMd); text: "异常警报"; color: Theme.text_secondary; font.pixelSize: Units.px(14)
            }
            Text {
                anchors.bottom: parent.bottom; anchors.bottomMargin: Units.px(Theme.spaceMd); anchors.left: parent.left; anchors.leftMargin: Units.px(Theme.spaceMd); text: "12"; color: Theme.negative; font.pixelSize: Units.px(32); font.bold: true
            }
        }
    }

    // 右侧 NovaTree 测试区
    Rectangle {
        anchors.top: header.bottom
        anchors.left: leftPanel.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Units.px(Theme.spaceLg)
        anchors.topMargin: Units.px(Theme.spaceLg)
        anchors.leftMargin: Units.px(Theme.spaceLg)
        color: Theme.surface
        radius: Theme.radiusMd
        border.color: Theme.border
        border.width: 1
        clip: true

        NovaTree {
            id: tree
            anchors.fill: parent
            anchors.margins: Units.px(1)

            // ✅ 开启多选
            selectable: true

            treeData: [
                {
                    id: 1, label: "华东一号制造基地", icon: "🏢",
                    children: [
                        {
                            id: 11, label: "一号车间 (注塑)", icon: "🏭",
                            children: [
                                {id: 111, label: "注塑机 A-01 (运行中)", icon: "⚙️"},
                                {id: 112, label: "注塑机 A-02 (待机)", icon: "⚙️"},
                                {id: 113, label: "机械臂 B-01 (异常)", icon: "🦾"}
                            ]
                        },
                        {
                            id: 12, label: "二号车间 (组装)", icon: "🏭",
                            children: [
                                {id: 121, label: "传送带 C-01", icon: "⚙️"},
                                {id: 122, label: "质检相机 D-01", icon: "📷"}
                            ]
                        }
                    ]
                }
            ]

            onNodeClicked: (nodeId, label) => {
                console.log("📌 左键选中:", label)
            }

            // ✅ 接收右键信号，弹出菜单
            onNodeRightClicked: (nodeId, label, x, y) => {
                contextMenu.targetNodeId = nodeId;
                contextMenu.targetLabel = label;
                contextMenu.popup(x, y);
            }
        }

        // 自定义右键菜单
        Menu {
            id: contextMenu
            property var targetNodeId: 0
            property string targetLabel: ""

            MenuItem {
                text: "➕ 添加子节点"
                onTriggered: console.log("添加子节点到:", contextMenu.targetLabel)
            }
            MenuItem {
                text: "✏️ 编辑属性"
                onTriggered: console.log("编辑节点:", contextMenu.targetLabel)
            }
            MenuSeparator {
            }
            MenuItem {
                text: "❌ 删除节点"
                onTriggered: console.log("删除节点:", contextMenu.targetLabel)
            }
        }
    }
}