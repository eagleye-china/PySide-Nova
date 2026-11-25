// examples/layout_shell/blank_page/main.qml
// NovaBlankPage 独立演示 · 成品级 Showcase：文档阅读页真实业务注入 / 调参面板默认收起
// 运行：python examples/layout_shell/blank_page/run.py
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1100
    height: 740
    minimumWidth: 720
    minimumHeight: 500
    visible: true
    title: "NovaBlankPage · 文档阅读页（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // 变体态 = 顶底栏收起 + 大留白纯净阅读
    property bool paramsOpen: false
    property string lastSignal: "—"
    property int signalCount: 0
    function logSignal(msg) {
        win.signalCount = win.signalCount + 1
        win.lastSignal = "#" + win.signalCount + "  " + msg
    }
    readonly property real _gap: NovaTheme.spacingM
    readonly property real _unit: NovaTheme.spacingS

    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 48
        color: NovaTheme.surface
        z: NovaTheme.zFixedDrawer + 1
        Text {
            id: titleText
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "NovaBlankPage  ·  文档阅读页"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text { anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter } text: "居中阅读栏 / 克制基底 / 单一表面色阶"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        Rectangle {
            anchors { right: parent.right; rightMargin: 56; verticalCenter: parent.verticalCenter }
            width: 30; height: 30; radius: 15
            color: NovaTheme.surfaceAlt
            border { width: 1; color: NovaTheme.outline }
            Rectangle {
                anchors.centerIn: parent
                width: 14; height: 14; radius: 7
                color: NovaTheme.isDark ? NovaTheme.warning : NovaTheme.primary
                Rectangle { anchors { right: parent.right; top: parent.top } width: 11; height: 11; radius: 5.5; color: NovaTheme.surfaceAlt; visible: !NovaTheme.isDark }
            }
            MouseArea { anchors.fill: parent; onClicked: NovaTheme.toggleDark() }
        }
        Rectangle {
            anchors { right: parent.right; rightMargin: NovaTheme.spacingM; verticalCenter: parent.verticalCenter }
            width: 30; height: 30; radius: 8
            color: win.paramsOpen ? NovaTheme.primary : NovaTheme.surfaceAlt
            border { width: 1; color: win.paramsOpen ? NovaTheme.primary : NovaTheme.outline }
            Column {
                anchors.centerIn: parent
                spacing: 3
                Repeater { model: 3; Rectangle { width: 14; height: 2; radius: 1; color: win.paramsOpen ? NovaTheme.textOnPrimary : NovaTheme.textMuted } }
            }
            MouseArea { anchors.fill: parent; onClicked: win.paramsOpen = !win.paramsOpen }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaBlankPage {
            id: shell
            anchors.fill: parent
            showHeader: !win.variantMode
            showFooter: !win.variantMode
            padding: win.variantMode ? 48 : 24

            // ① 顶栏：品牌 + 文档导航
            headerSlot: Item {
                anchors.fill: parent
                Rectangle { anchors { left: parent.left; verticalCenter: parent.verticalCenter } width: 20; height: 20; radius: 5; color: NovaTheme.primary; Rectangle { anchors.centerIn: parent; width: 7; height: 7; radius: 2; color: NovaTheme.textOnPrimary } }
                Text { anchors { left: parent.left; leftMargin: 30; verticalCenter: parent.verticalCenter } text: "Nova 文档"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                Row {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Repeater {
                        model: ["指南", "组件", "宪法", "更新日志"]
                        Rectangle {
                            required property string modelData
                            width: 64; height: 28; radius: NovaTheme.radiusS
                            color: docArea.containsMouse ? NovaTheme.surfaceAlt : "transparent"
                            Text { anchors.centerIn: parent; text: modelData; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                            MouseArea { id: docArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("doc(" + modelData + ")") }
                        }
                    }
                }
            }

            // ② 内容：真实文章（限宽阅读栏内）
            contentSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { fill: parent; margins: win._unit }
                    spacing: win._gap
                    Text { text: "CARF 宣言"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontXL; bold: true } }
                    Text { text: "Conceive · Achieve · Refine · Freeze — Culminate to the peak."; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontS }
                    Rectangle { width: parent.width; height: 2; color: NovaTheme.outline }
                    Text {
                        width: parent.width
                        wrapMode: Text.Wrap
                        text: "构想 · 实现 · 打磨 · 封版，终抵巅峰。每一个 pyside-nova 组件与 15 项组合根容器，都必须是功能、质量、观感、友好度与四性（鲁棒性、坚实性、艺术性、预判性）六维缺一不可的天花板。"
                        color: NovaTheme.textColor
                        font.pixelSize: NovaTheme.fontS
                        lineHeight: 1.6
                    }
                    Repeater {
                        model: [
                            { t: "C 构想", d: "CSA 立方向、定标准，法源先行。" },
                            { t: "A 实现", d: "完现者把设想落成可交付、可验证的工程现实。" },
                            { t: "R 打磨", d: "六维天花板 + CC 装配态出图，逐项验收销号。" },
                            { t: "F 封版", d: "API 冻结零漂移，文档账本闭环，发布归 CSA。" }
                        ]
                        Rectangle {
                            required property var modelData
                            width: parent.width
                            height: 56
                            radius: NovaTheme.radiusS
                            color: NovaTheme.surfaceAlt
                            border { width: 1; color: NovaTheme.outline }
                            Text { anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter } text: modelData.t; color: NovaTheme.primary; font { pixelSize: NovaTheme.fontS; bold: true } }
                            Text { anchors { left: parent.left; leftMargin: 120; verticalCenter: parent.verticalCenter } text: modelData.d; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                        }
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.Wrap
                        text: "CARF 是循环而非一次性流程：封版之后以复评回到构想，但禁止推倒重来；每一轮打磨只在既有基座上再优化，一次一项、逐项销号。"
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                        lineHeight: 1.6
                    }
                }
            }

            // ③ 底栏：真实文档态
            footerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.positive }
                    Text { text: "文档已同步 · 阅读进度 68%"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                }
                Text { anchors { right: parent.right; rightMargin: win._gap; verticalCenter: parent.verticalCenter } text: "最后更新 2026-11-25"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            }
        }
    }

    Rectangle {
        id: statusBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: NovaTheme.surfaceAlt
        Text { anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL } text: "装配态  ·  阅读栏单一表面色阶 / 栏高归零恒定锚链  ·  浅/深双主题  ·  纯净阅读变体"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        Text { anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL } text: "CARF-R  ·  CC-1~CC-8"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }

    Rectangle {
        id: params
        anchors { top: topBar.bottom; bottom: statusBar.top; right: parent.right }
        width: 248
        color: NovaTheme.surface
        border { width: 1; color: NovaTheme.outline }
        visible: win.paramsOpen
        z: NovaTheme.zMenu
        Column {
            anchors { fill: parent; margins: win._gap }
            spacing: win._gap
            Text { text: "调参面板"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
            Row {
                spacing: win._unit
                Text { text: "纯净阅读"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
