// examples/layout_shell/dual_side/main.qml
// NovaDualSide 独立演示 · 成品级 Showcase：图层树 / 设计画布 / 属性面板真实业务注入 · 调参默认收起
// 运行：python examples/layout_shell/dual_side/run.py
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    width: 1280
    height: 800
    minimumWidth: 820
    minimumHeight: 560
    visible: true
    title: "NovaDualSide · 设计器工作台（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // 变体态 = 左栏收起，画布自动铺开
    property bool paramsOpen: false
    property bool showBars: true
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
            text: "NovaDualSide  ·  设计器工作台"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "左侧图层 / 中央画布 / 右侧属性"
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
                Rectangle {
                    anchors { right: parent.right; top: parent.top }
                    width: 11; height: 11; radius: 5.5
                    color: NovaTheme.surfaceAlt
                    visible: !NovaTheme.isDark
                }
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
                Repeater {
                    model: 3
                    Rectangle { width: 14; height: 2; radius: 1; color: win.paramsOpen ? NovaTheme.textOnPrimary : NovaTheme.textMuted }
                }
            }
            MouseArea { anchors.fill: parent; onClicked: win.paramsOpen = !win.paramsOpen }
        }
        NovaSeparator { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaDualSide {
            id: shell
            anchors.fill: parent
            leftCollapsed: win.variantMode
            showFooter: win.showBars
            onLeftToggled: function(c) { win.logSignal("leftToggled(" + c + ")"); win.variantMode = c }
            onRightToggled: function(c) { win.logSignal("rightToggled(" + c + ")") }

            // ① 左栏：图层树（真实可点击）
            leftSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { fill: parent; topMargin: win._unit * 2 }
                    spacing: win._unit
                    Text { text: "图层"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Repeater {
                        model: [
                            { n: "画板 · 首页", k: 0 },
                            { n: "标题文本", k: 1 },
                            { n: "主视觉卡片", k: 2 },
                            { n: "数据指标行", k: 3 },
                            { n: "底部操作区", k: 4 }
                        ]
                        Rectangle {
                            required property var modelData
                            required property int index
                            width: parent.width
                            height: 32
                            radius: NovaTheme.radiusS
                            color: index === 2 ? NovaTheme.surface : (layerArea.containsMouse ? NovaTheme.surfaceAlt : "transparent")
                            Rectangle {
                                anchors { left: parent.left; leftMargin: win._unit; verticalCenter: parent.verticalCenter }
                                width: 10; height: 10; radius: 2
                                color: index === 2 ? NovaTheme.primary : NovaTheme.outline
                                opacity: 0.9
                            }
                            Text {
                                anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
                                text: modelData.n
                                color: index === 2 ? NovaTheme.primary : NovaTheme.textColor
                                font.pixelSize: NovaTheme.fontS
                            }
                            MouseArea {
                                id: layerArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.logSignal("select(" + modelData.n + ")")
                            }
                        }
                    }
                    Item { width: 1; height: win._unit }
                    Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
                    Text { text: "资源"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Repeater {
                        model: ["品牌色板", "字体阶梯", "间距栅格"]
                        Rectangle {
                            required property string modelData
                            width: parent.width
                            height: 30
                            radius: NovaTheme.radiusS
                            color: resArea.containsMouse ? NovaTheme.surfaceAlt : "transparent"
                            Rectangle {
                                anchors { left: parent.left; leftMargin: win._unit; verticalCenter: parent.verticalCenter }
                                width: 8; height: 8; radius: 4
                                color: Qt.lighter(NovaTheme.primary, 1.35)
                            }
                            Text {
                                anchors { left: parent.left; leftMargin: 22; verticalCenter: parent.verticalCenter }
                                text: modelData
                                color: NovaTheme.textColor
                                font.pixelSize: NovaTheme.fontXS
                            }
                            MouseArea {
                                id: resArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.logSignal("resource(" + modelData + ")")
                            }
                        }
                    }
                }
            }

            // ② 中央画布：设计稿卡（限宽居中）+ 四角取景框 + 标注
            contentSlot: Item {
                anchors.fill: parent
                Item {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - win._gap * 2, 520)
                    height: Math.min(parent.height - win._gap * 2, 420)
                    Rectangle {
                        anchors.fill: parent
                        radius: NovaTheme.radiusM
                        color: NovaTheme.surface
                        border { width: 1; color: NovaTheme.outline }
                        Rectangle {
                            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 28; leftMargin: 28; rightMargin: 28 }
                            height: 46
                            radius: NovaTheme.radiusS
                            color: NovaTheme.primary
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "企业级旗舰版组件库"
                                color: NovaTheme.textOnPrimary
                                font { pixelSize: NovaTheme.fontL; bold: true }
                            }
                        }
                        Row {
                            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 96; leftMargin: 28; rightMargin: 28 }
                            spacing: win._gap
                            Repeater {
                                model: [1280, 640, 320]
                                Rectangle {
                                    required property int modelData
                                    width: (parent.width - win._gap * 2) / 3
                                    height: 96
                                    radius: NovaTheme.radiusS
                                    color: NovaTheme.surfaceAlt
                                    border { width: 1; color: NovaTheme.outline }
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData + " px"
                                        color: NovaTheme.textColor
                                        font.pixelSize: NovaTheme.fontS
                                    }
                                }
                            }
                        }
                        Rectangle {
                            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 28 }
                            height: 54
                            radius: NovaTheme.radiusS
                            color: NovaTheme.surfaceAlt
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "CARF · 构想 实现 打磨 封版"
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontS
                            }
                            Rectangle {
                                anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                width: 84; height: 28; radius: 14
                                color: NovaTheme.primary
                                Text { anchors.centerIn: parent; text: "开始使用"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontXS }
                                MouseArea { anchors.fill: parent; onClicked: win.logSignal("cta()") }
                            }
                        }
                    }
                    // 四角取景框（纯几何标注，落在内容之上但不遮挡）
                    Repeater {
                        model: 4
                        Rectangle {
                            required property int index
                            width: 14; height: 14
                            x: index % 2 === 0 ? 0 : parent.width - 14
                            y: index < 2 ? 0 : parent.height - 14
                            color: "transparent"
                            border { width: 2; color: NovaTheme.primary }
                        }
                    }
                }
            }

            // ③ 右栏：属性面板（真实可交互输入位）
            rightSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { fill: parent; topMargin: win._unit * 2 }
                    spacing: win._gap
                    Text { text: "属性"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                    Text { text: "主视觉卡片"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
                    Row {
                        width: parent.width
                        spacing: win._unit
                        Repeater {
                            model: [{ l: "W", v: "520" }, { l: "H", v: "420" }, { l: "R", v: "10" }]
                            Rectangle {
                                required property var modelData
                                width: (parent.width - win._unit * 2) / 3
                                height: 52
                                radius: NovaTheme.radiusS
                                color: NovaTheme.surface
                                border { width: 1; color: NovaTheme.outline }
                                Text {
                                    anchors { left: parent.left; leftMargin: 8; top: parent.top; topMargin: 6 }
                                    text: modelData.l
                                    color: NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontXS
                                }
                                Text {
                                    anchors { left: parent.left; leftMargin: 8; bottom: parent.bottom; bottomMargin: 6 }
                                    text: modelData.v
                                    color: NovaTheme.textColor
                                    font.pixelSize: NovaTheme.fontS
                                }
                            }
                        }
                    }
                    Text { text: "填充"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Row {
                        spacing: win._unit
                        Repeater {
                            model: [NovaTheme.primary, Qt.lighter(NovaTheme.primary, 1.35), Qt.lighter(NovaTheme.primary, 1.7), NovaTheme.surfaceAlt]
                            Rectangle {
                                required property color modelData
                                width: 34; height: 34; radius: NovaTheme.radiusS
                                color: modelData
                                border { width: 1; color: NovaTheme.outline }
                                MouseArea { anchors.fill: parent; onClicked: win.logSignal("fill()") }
                            }
                        }
                    }
                    Text { text: "不透明度  100%"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Slider { width: parent.width; from: 0; to: 100; value: 100 }
                    Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
                    Text { text: "对齐"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Row {
                        spacing: win._unit
                        Repeater {
                            model: 3
                            Rectangle {
                                required property int index
                                width: 44; height: 32; radius: NovaTheme.radiusS
                                color: alignArea.containsMouse ? NovaTheme.surfaceAlt : NovaTheme.surface
                                border { width: 1; color: NovaTheme.outline }
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 3
                                    Repeater {
                                        model: 3
                                        Rectangle { width: 14; height: 2; radius: 1; color: NovaTheme.textMuted }
                                    }
                                }
                                MouseArea { id: alignArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("align(" + index + ")") }
                            }
                        }
                    }
                }
            }

            // ④ 状态栏：真实文件态
            footerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.positive }
                    Text { text: "首页画板 · 已保存"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "|"; color: NovaTheme.outline; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "5 个图层 · 1 个选中"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
                Text {
                    anchors { right: parent.right; rightMargin: win._gap; verticalCenter: parent.verticalCenter }
                    text: "缩放 100%"
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
            text: "装配态  ·  双栏宽度归零恒定锚链  ·  浅/深双主题  ·  左栏收起变体"
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
                Text { text: "收起左栏"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Row {
                spacing: win._unit
                Text { text: "显示状态栏"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
