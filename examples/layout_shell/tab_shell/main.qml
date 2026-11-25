// examples/layout_shell/tab_shell/main.qml
// NovaTabShell 独立演示 · 成品级 Showcase：多文档编辑器真实业务注入 / 调参面板默认收起
// 运行：python examples/layout_shell/tab_shell/run.py
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1200
    height: 760
    minimumWidth: 760
    minimumHeight: 500
    visible: true
    title: "NovaTabShell · 多文档编辑器（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // 变体态 = 标签栏收起，内容铺满
    property bool paramsOpen: false
    property bool showFooter: true
    property int activeTab: 0
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
            text: "NovaTabShell  ·  多文档编辑器"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "标签栏 / 文档画布 / 状态栏"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
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

        NovaTabShell {
            id: shell
            anchors.fill: parent
            showTabBar: !win.variantMode
            showFooter: win.showFooter
            onTabActivated: function(i) { win.activeTab = i; win.logSignal("tabActivated(" + i + ")") }
            onTabCloseRequested: function(i) { win.logSignal("tabCloseRequested(" + i + ")") }
            onTabAddRequested: win.logSignal("tabAddRequested()")

            // ① 标签栏：3 个真实文档标签（激活 / hover / 关闭）+ 新建
            tabBarSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    spacing: 4
                    Repeater {
                        model: ["架构宪法.md", "组合宪法.md", "天花板档案.md"]
                        Rectangle {
                            required property string modelData
                            required property int index
                            width: 156; height: 32
                            radius: NovaTheme.radiusS
                            color: win.activeTab === index ? NovaTheme.surface : (tabArea.containsMouse ? NovaTheme.surfaceAlt : "transparent")
                            border { width: win.activeTab === index ? 1 : 0; color: NovaTheme.outline }
                            Rectangle {
                                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                width: 8; height: 8; radius: 2
                                color: win.activeTab === index ? NovaTheme.primary : NovaTheme.outline
                            }
                            Text {
                                anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
                                text: modelData
                                color: win.activeTab === index ? NovaTheme.primary : NovaTheme.textColor
                                font.pixelSize: NovaTheme.fontXS
                            }
                            MouseArea {
                                id: tabArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.activeTab = index
                            }
                        }
                    }
                    Rectangle {
                        width: 28; height: 28; radius: NovaTheme.radiusS
                        color: addArea.containsMouse ? NovaTheme.surfaceAlt : "transparent"
                        border { width: 1; color: NovaTheme.outline }
                        Rectangle { anchors.centerIn: parent; width: 10; height: 2; color: NovaTheme.textMuted }
                        Rectangle { anchors.centerIn: parent; width: 2; height: 10; color: NovaTheme.textMuted }
                        MouseArea { id: addArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("tabAddRequested()") }
                    }
                }
                Text {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    text: "3 个文档 · 已全部保存"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                }
            }

            // ② 文档画布：限宽阅读栏 + 标题 / 正文 / 检查清单
            contentSlot: Item {
                anchors.fill: parent
                Item {
                    anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    width: Math.min(parent.width - win._gap * 2, 820)
                    Column {
                        anchors { fill: parent; margins: win._gap }
                        spacing: win._gap
                        Text {
                            text: win.activeTab === 0 ? "架构宪法 · 卷首宣言" : (win.activeTab === 1 ? "组合组件宪法 · 第 9 章" : "组件天花板档案 · 销号台账")
                            color: NovaTheme.textColor
                            font { pixelSize: NovaTheme.fontXL; bold: true }
                        }
                        Text {
                            text: "CARF — Conceive, Achieve, Refine, Freeze — Culminate to the peak."
                            color: NovaTheme.primary
                            font.pixelSize: NovaTheme.fontS
                        }
                        Rectangle {
                            width: parent.width
                            height: 180
                            radius: NovaTheme.radiusM
                            color: NovaTheme.surface
                            border { width: 1; color: NovaTheme.outline }
                            Column {
                                anchors { fill: parent; margins: win._gap }
                                spacing: 10
                                Repeater {
                                    model: [
                                        "C 构想 · 法源先行，CSA 立方向与验收标准",
                                        "A 实现 · 三要素 / 槽位 alias / 唯一令牌源 / 冻结面",
                                        "R 打磨 · 六维天花板 + CC-1~CC-8 装配态出图",
                                        "F 封版 · API 零漂移 + 文档账本闭环"
                                    ]
                                    Row {
                                        required property string modelData
                                        spacing: win._gap
                                        Rectangle { width: 8; height: 8; radius: 4; color: NovaTheme.primary; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: modelData; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: parent.width
                            height: 140
                            radius: NovaTheme.radiusM
                            color: NovaTheme.surface
                            border { width: 1; color: NovaTheme.outline }
                            Text {
                                anchors { left: parent.left; leftMargin: win._gap; top: parent.top; topMargin: 12 }
                                text: "装配态检查清单"
                                color: NovaTheme.textColor
                                font { pixelSize: NovaTheme.fontM; bold: true }
                            }
                            Column {
                                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 42; margins: win._gap }
                                spacing: 8
                                Repeater {
                                    model: ["单一分隔源 · PASS", "恒定锚链 · PASS", "槽位铺满 · PASS", "双主题实心注入 · PASS"]
                                    Row {
                                        required property string modelData
                                        spacing: win._gap
                                        Rectangle { width: 8; height: 8; radius: 4; color: NovaTheme.positive; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: modelData; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ③ 状态栏：真实文档态
            footerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.positive }
                    Text { text: "Markdown · UTF-8 · 已保存"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "|"; color: NovaTheme.outline; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "第 " + (win.activeTab + 1) + " / 3 个文档"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
                Text {
                    anchors { right: parent.right; rightMargin: win._gap; verticalCenter: parent.verticalCenter }
                    text: "Ln 24, Col 8"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                }
            }
        }
    }

    Rectangle {
        id: statusBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: NovaTheme.surfaceAlt
        Text {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "装配态  ·  标签栏高度归零恒定锚链  ·  浅/深双主题  ·  标签栏收起变体"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "CARF-R  ·  CC-1~CC-8"
            color: NovaTheme.primary
            font.pixelSize: NovaTheme.fontXS
        }
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
                Text { text: "收起标签栏"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Row {
                spacing: win._unit
                Text { text: "显示状态栏"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.showFooter; onCheckedChanged: win.showFooter = checked }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
