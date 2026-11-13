// examples/01_minimal/main.qml

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Nova 1.0

ApplicationWindow {
    visible: true
    width: 1000
    height: 800
    title: "Nova 主题系统与组件测试"

    // ✅ 窗口底色接入 Theme
    color: Theme.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Units.px(24)
        spacing: Units.px(20)

        // ── 顶栏：主题切换 ──
        NovaLayout {
            Layout.fillWidth: true
            height: Units.px(40)
            justify: "space-between"
            align: "center"

            Text {
                text: "Nova 核心引擎测试 (当前主题: " + Theme.mode + ")"
                color: Theme.text_primary
                font.pixelSize: Units.px(18)
                font.bold: true
            }

            // ✅ 用原生 QML 写的测试按钮，确保绝不报错
            Rectangle {
                width: Units.px(120)
                height: Units.px(36)
                radius: Theme.radiusSm
                color: btnMouse.containsMouse ? Theme.primary : Theme.secondary

                Text {
                    anchors.centerIn: parent
                    text: "🔄 切换明暗"
                    color: "#ffffff"
                    font.pixelSize: Units.px(14)
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Theme.mode = Theme.mode === "light" ? "dark" : "light"
                }
            }
        }

        // ── 组件测试区：输入框与原生按钮 ──
        NovaLayout {
            Layout.fillWidth: true
            height: Units.px(50)
            horizontal: true
            spacing: Units.px(16)
            align: "center"

            // 保留你的 NovaInput
            NovaInput {
                width: Units.px(240)
                placeholderText: "请输入设备编号..."
            }

            // 原生测试按钮
            Rectangle {
                width: Units.px(80)
                height: Units.px(36)
                radius: Theme.radiusSm
                color: Theme.primary

                Text {
                    anchors.centerIn: parent
                    text: "查询"
                    color: "#ffffff"
                }
            }
        }

        // ── BOSS 组件：高性能表格 ──
        NovaTable {
            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: [
                { label: "ID", field: "id", width: 80, align: "center" },
                { label: "设备名称", field: "name", width: 200, align: "left" },
                { label: "运行状态", field: "status", width: 120, align: "center" },
                { label: "温度 (℃)", field: "temp", width: 120, align: "right" },
                { label: "压力 (kPa)", field: "pressure", width: 120, align: "right" },
                { label: "最后更新时间", field: "time", width: 200, align: "left" }
            ]

            rows: {
                let data = [];
                for (let i = 1; i <= 5000; i++) {
                    data.push({
                        id: i,
                        name: "智能控制节点 - " + (i < 10 ? "00" + i : i),
                        status: i % 3 === 0 ? "异常" : (i % 2 === 0 ? "待机" : "运行中"),
                        temp: (25 + Math.random() * 20).toFixed(1),
                        pressure: (100 + Math.random() * 50).toFixed(1),
                        time: "2026-11-13 10:" + (i % 60 < 10 ? "0" + (i % 60) : (i % 60)) + ":00"
                    });
                }
                return data;
            }
        }
    }
}