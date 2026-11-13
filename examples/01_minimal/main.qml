// examples/01_minimal/main.qml

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Nova 1.0

ApplicationWindow {
    visible: true
    width: 1280
    height: 800
    title: "Nova 工业级仪表盘大屏"
    color: Theme.background

    // ── 1. 顶部 Header (完全锚定) ──
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
                    onClicked: Theme.mode = Theme.mode === "light" ? "dark" : "light"
                }
            }
        }
    }

    // ── 2. 左侧数据统计卡片区 (固定宽度 260) ──
    Column {
        id: leftPanel
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Units.px(Theme.spaceLg)
        anchors.topMargin: Units.px(Theme.spaceLg) // 与 header 的间距
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
                anchors.top: parent.top
                anchors.topMargin: Units.px(Theme.spaceMd)
                anchors.left: parent.left
                anchors.leftMargin: Units.px(Theme.spaceMd)
                text: "总设备数"
                color: Theme.text_secondary
                font.pixelSize: Units.px(14)
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Units.px(Theme.spaceMd)
                anchors.left: parent.left
                anchors.leftMargin: Units.px(Theme.spaceMd)
                text: "5,000"
                color: Theme.primary
                font.pixelSize: Units.px(32)
                font.bold: true
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
                anchors.top: parent.top
                anchors.topMargin: Units.px(Theme.spaceMd)
                anchors.left: parent.left
                anchors.leftMargin: Units.px(Theme.spaceMd)
                text: "运行中"
                color: Theme.text_secondary
                font.pixelSize: Units.px(14)
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Units.px(Theme.spaceMd)
                anchors.left: parent.left
                anchors.leftMargin: Units.px(Theme.spaceMd)
                text: "2,345"
                color: Theme.positive
                font.pixelSize: Units.px(32)
                font.bold: true
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
                anchors.top: parent.top
                anchors.topMargin: Units.px(Theme.spaceMd)
                anchors.left: parent.left
                anchors.leftMargin: Units.px(Theme.spaceMd)
                text: "异常警报"
                color: Theme.text_secondary
                font.pixelSize: Units.px(14)
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Units.px(Theme.spaceMd)
                anchors.left: parent.left
                anchors.leftMargin: Units.px(Theme.spaceMd)
                text: "12"
                color: Theme.negative
                font.pixelSize: Units.px(32)
                font.bold: true
            }
        }
    }

    // ── 3. 右侧数据表格区 (自动撑满剩余空间) ──
    Rectangle {
        anchors.top: header.bottom
        anchors.left: leftPanel.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Units.px(Theme.spaceLg)
        anchors.topMargin: Units.px(Theme.spaceLg) // 与 header 的间距
        anchors.leftMargin: Units.px(Theme.spaceLg) // 与左侧面板的间距
        color: Theme.surface
        radius: Theme.radiusMd
        border.color: Theme.border
        border.width: 1
        clip: true

        NovaTable {
            anchors.fill: parent
            anchors.margins: Units.px(1)

            columns: [
                {label: "节点编号", field: "id", width: 100, align: "center"},
                {label: "设备名称", field: "name", width: 200, align: "left"},
                {label: "运行状态", field: "status", width: 120, align: "center"},
                {label: "当前温度", field: "temp", width: 120, align: "right"},
                {label: "系统压力", field: "pressure", width: 120, align: "right"},
                {label: "最后心跳", field: "time", width: 200, align: "left"}
            ]

            rows: {
                let data = [];
                for (let i = 1; i <= 5000; i++) {
                    data.push({
                        id: i,
                        name: "工业节点 - " + (i < 10 ? "00" + i : i),
                        status: i % 3 === 0 ? "异常" : (i % 2 === 0 ? "待机" : "运行中"),
                        temp: (25 + Math.random() * 20).toFixed(1),
                        pressure: (100 + Math.random() * 50).toFixed(1),
                        time: "2026-11-13 10:" + (i % 60 < 10 ? "0" + (i % 60) : (i % 60)) + ":00"
                    });
                }
                return data;
            }

            onRowClicked: (rowData, index) => {
                console.log("📌 选中设备:", rowData.name)
            }
        }
    }
}