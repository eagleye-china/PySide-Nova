// examples/layout_shell/compare/main.qml
// NovaCompare 独立演示 · 成品级 Showcase：配置 diff 双栏真实业务注入 / 调参面板默认收起
// 运行：python examples/layout_shell/compare/run.py
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1280
    height: 780
    minimumWidth: 820
    minimumHeight: 520
    visible: true
    title: "NovaCompare · 配置对比（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // 变体态 = 控制栏与状态栏收起，双栏铺满
    property bool paramsOpen: false
    property bool syncScroll: false
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
            text: "NovaCompare  ·  配置对比"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text { anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter } text: "A / B 双面板 · 中缝单一分隔源"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
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

        NovaCompare {
            id: shell
            anchors.fill: parent
            showControl: !win.variantMode
            showFooter: !win.variantMode
            syncScroll: win.syncScroll
            onSyncScrollToggled: function(e) { win.logSignal("syncScrollToggled(" + e + ")"); win.syncScroll = e }

            // ① 控制栏：文件信息 + 同步滚动真实开关 + 差异统计
            controlSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    spacing: win._gap
                    Rectangle { width: 8; height: 8; radius: 4; color: NovaTheme.primary; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "settings.prod.json"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                    Text { text: "vs"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Rectangle { width: 8; height: 8; radius: 4; color: Qt.lighter(NovaTheme.primary, 1.35); anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "settings.staging.json"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                }
                Rectangle {
                    id: syncChip
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    width: 118; height: 28; radius: 14
                    color: win.syncScroll ? NovaTheme.primary : NovaTheme.surfaceAlt
                    border { width: 1; color: win.syncScroll ? NovaTheme.primary : NovaTheme.outline }
                    Text { anchors.centerIn: parent; text: win.syncScroll ? "同步滚动 · 开" : "同步滚动 · 关"; color: win.syncScroll ? NovaTheme.textOnPrimary : NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                    MouseArea { anchors.fill: parent; onClicked: win.syncScroll = !win.syncScroll }
                }
            }

            // ② 左面板（A）：配置行 + 差异高亮（主色系，不撞色）
            leftSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { fill: parent; margins: win._gap }
                    spacing: 4
                    Text { text: "A · 生产环境"; color: NovaTheme.primary; font { pixelSize: NovaTheme.fontS; bold: true } }
                    Repeater {
                        model: [
                            { n: "01", k: " ", t: "\"theme\": \"light\"," },
                            { n: "02", k: " ", t: "\"timeout\": 3000," },
                            { n: "03", k: "-", t: "\"retry\": 3," },
                            { n: "04", k: " ", t: "\"region\": \"cn-north\"," },
                            { n: "05", k: "-", t: "\"debug\": false," },
                            { n: "06", k: " ", t: "\"pool\": 16," },
                            { n: "07", k: " ", t: "\"cache\": \"lru\"" }
                        ]
                        Rectangle {
                            required property var modelData
                            width: parent.width
                            height: 34
                            radius: NovaTheme.radiusS
                            color: modelData.k === "-" ? NovaTheme.surfaceAlt : "transparent"
                            Text { anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter } text: modelData.n; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: 24 }
                            Text { anchors { left: parent.left; leftMargin: 36; verticalCenter: parent.verticalCenter } text: modelData.k; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontS; width: 16 }
                            Text { anchors { left: parent.left; leftMargin: 58; verticalCenter: parent.verticalCenter } text: modelData.t; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                        }
                    }
                }
            }

            // ③ 右面板（B）：对应差异行
            rightSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { fill: parent; margins: win._gap }
                    spacing: 4
                    Text { text: "B · 预发布环境"; color: Qt.lighter(NovaTheme.primary, 1.35); font { pixelSize: NovaTheme.fontS; bold: true } }
                    Repeater {
                        model: [
                            { n: "01", k: " ", t: "\"theme\": \"light\"," },
                            { n: "02", k: "+", t: "\"timeout\": 5000," },
                            { n: "03", k: "+", t: "\"retry\": 5," },
                            { n: "04", k: " ", t: "\"region\": \"cn-north\"," },
                            { n: "05", k: "+", t: "\"debug\": true," },
                            { n: "06", k: " ", t: "\"pool\": 16," },
                            { n: "07", k: " ", t: "\"cache\": \"lru\"" }
                        ]
                        Rectangle {
                            required property var modelData
                            width: parent.width
                            height: 34
                            radius: NovaTheme.radiusS
                            color: modelData.k === "+" ? NovaTheme.surfaceAlt : "transparent"
                            Text { anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter } text: modelData.n; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: 24 }
                            Text { anchors { left: parent.left; leftMargin: 36; verticalCenter: parent.verticalCenter } text: modelData.k; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontS; width: 16 }
                            Text { anchors { left: parent.left; leftMargin: 58; verticalCenter: parent.verticalCenter } text: modelData.t; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                        }
                    }
                }
            }

            // ④ 状态栏：真实差异统计
            footerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.warning }
                    Text { text: "5 处差异 · 3 处新增 · 2 处删除"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "|"; color: NovaTheme.outline; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "编码 UTF-8 · 行尾 LF"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
                Text { anchors { right: parent.right; rightMargin: win._gap; verticalCenter: parent.verticalCenter } text: "只读对比"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            }
        }
    }

    Rectangle {
        id: statusBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: NovaTheme.surfaceAlt
        Text { anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL } text: "装配态  ·  中缝唯一分隔源 / 栏高归零恒定锚链  ·  浅/深双主题  ·  双栏铺满变体"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
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
                Text { text: "双栏铺满"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Row {
                spacing: win._unit
                Text { text: "同步滚动"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.syncScroll; onCheckedChanged: win.syncScroll = checked }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
