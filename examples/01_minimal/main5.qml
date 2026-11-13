// examples/01_minimal/main.qml

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Nova 1.0

ApplicationWindow {
    visible: true
    width: 900
    height: 800
    title: "NovaCardActions 测试"
    color: Theme.background

    Rectangle {
        id: header
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        height: Units.px(60)
        color: Theme.surface; border.color: Theme.border; border.width: 1

        Text {
            anchors.centerIn: parent; text: "NovaCardActions 交互测试"
            color: Theme.text_primary; font.pixelSize: Units.px(18); font.bold: true
        }

        NovaButton {
            anchors.right: parent.right; anchors.rightMargin: Units.px(16); anchors.verticalCenter: parent.verticalCenter
            text: "🌓 切换主题"
            onClicked: ThemeManager.mode = (Theme.mode === "light" ? "dark" : "light")
        }
    }

    ColumnLayout {
        anchors.top: header.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.margins: Units.px(24)
        spacing: Units.px(24)

        NovaCard {
            Layout.fillWidth: true
            height: Units.px(220) // 明确指定卡片高度

            Column {
                anchors.top: parent.top; anchors.left: parent.left; spacing: Units.px(8)
                Text {
                    text: "👤 单保录"; color: Theme.text_primary; font.pixelSize: Units.px(20); font.bold: true
                }
                Text {
                    text: "系统管理员 | 上次登录: 2026-11-13"; color: Theme.text_secondary; font.pixelSize: Units.px(14)
                }
            }

            NovaCardActions {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                align: "right"

                NovaButton {
                    text: "✏️ 编辑资料"; onClicked: console.log("📌 编辑资料")
                }
                NovaButton {
                    text: "🗑️ 删除账户"; onClicked: console.log("📌 删除账户")
                }
                NovaButton {
                    text: "🛡️ 安全报告"; onClicked: console.log("📌 安全报告")
                }
            }
        }

        NovaCard {
            Layout.fillWidth: true
            height: Units.px(160) // 明确指定卡片高度

            Text {
                anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; anchors.topMargin: Units.px(8)
                text: "⚙️ 系统提示"; color: Theme.text_primary; font.pixelSize: Units.px(18); font.bold: true
            }

            NovaCardActions {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                align: "center"

                NovaButton {
                    text: "取消"; onClicked: console.log("📌 取消")
                }
                NovaButton {
                    text: "确认应用"; onClicked: console.log("📌 确认应用")
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}