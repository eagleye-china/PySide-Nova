// examples/layout_shell/three_column/main.qml
// NovaThreeColumn 独立演示 · 成品级 Showcase：API 工作台真实业务注入 / 调参面板默认收起
// 运行：python examples/layout_shell/three_column/run.py
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
    minimumHeight: 540
    visible: true
    title: "NovaThreeColumn · API 工作台（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: NovaScreen.source = win

    property bool variantMode: false        // 变体态 = 顶栏收起 + 底栏展开 + 树栏收窄
    property bool paramsOpen: false
    property int activeApi: 0
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
            text: "NovaThreeColumn  ·  API 工作台"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "目录树 / 接口列表 / 详情"
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

        NovaThreeColumn {
            id: shell
            anchors.fill: parent
            showHeader: !win.variantMode
            showFooter: win.variantMode
            treeSize: win.variantMode ? 180 : 220
            onColumnResized: function(c, s) { win.logSignal("columnResized(" + c + ", " + s + ")") }

            // ① 顶栏：品牌 + 全局搜索 + 版本
            headerSlot: Item {
                anchors.fill: parent
                Rectangle { anchors { left: parent.left; verticalCenter: parent.verticalCenter } width: 20; height: 20; radius: 5; color: NovaTheme.primary; Rectangle { anchors.centerIn: parent; width: 7; height: 7; radius: 2; color: NovaTheme.textOnPrimary } }
                Text { anchors { left: parent.left; leftMargin: 30; verticalCenter: parent.verticalCenter } text: "Nova API Explorer"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                Rectangle {
                    anchors { right: versionChip.left; rightMargin: win._gap; verticalCenter: parent.verticalCenter }
                    width: 260; height: 30; radius: 15
                    color: NovaTheme.surfaceAlt
                    border { width: 1; color: apiSearch.containsMouse ? NovaTheme.primary : NovaTheme.outline }
                    Text { anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter } text: "搜索接口 / 类型 / 模块…"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    MouseArea { id: apiSearch; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("apiSearch()") }
                }
                Rectangle {
                    id: versionChip
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    width: 88; height: 28; radius: 14
                    color: NovaTheme.surfaceAlt
                    border { width: 1; color: NovaTheme.outline }
                    Text { anchors.centerIn: parent; text: "v1.0.0 GA"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                }
            }

            // ② 目录树：分组 + 模块（真实可点击）
            treeSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { fill: parent; topMargin: win._unit }
                    spacing: win._unit
                    Text { text: "模块"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Repeater {
                        model: ["Nova.Services", "Nova.Controls", "Nova.Behaviors", "Nova.Design", "Composite.LayoutShell"]
                        Rectangle {
                            required property string modelData
                            required property int index
                            width: parent.width
                            height: 32
                            radius: NovaTheme.radiusS
                            color: index === 4 ? NovaTheme.surface : (treeArea.containsMouse ? NovaTheme.surface : "transparent")
                            Rectangle { anchors { left: parent.left; leftMargin: win._unit; verticalCenter: parent.verticalCenter } width: 8; height: 8; radius: 2; color: index === 4 ? NovaTheme.primary : NovaTheme.outline }
                            Text { anchors { left: parent.left; leftMargin: 22; verticalCenter: parent.verticalCenter } text: modelData; color: index === 4 ? NovaTheme.primary : NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                            MouseArea { id: treeArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("module(" + modelData + ")") }
                        }
                    }
                    Item { width: 1; height: win._unit }
                    Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
                    Text { text: "收藏"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Repeater {
                        model: ["NovaTheme", "NovaChat", "NovaMotion"]
                        Rectangle {
                            required property string modelData
                            width: parent.width; height: 30; radius: NovaTheme.radiusS
                            color: favArea.containsMouse ? NovaTheme.surface : "transparent"
                            Rectangle { anchors { left: parent.left; leftMargin: win._unit; verticalCenter: parent.verticalCenter } width: 7; height: 7; radius: 3.5; color: Qt.lighter(NovaTheme.primary, 1.35) }
                            Text { anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter } text: modelData; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                            MouseArea { id: favArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("favorite(" + modelData + ")") }
                        }
                    }
                }
            }

            // ③ 接口列表：真实条目（选中 + hover）
            listSlot: Item {
                anchors.fill: parent
                Item {
                    anchors { fill: parent; margins: win._gap }
                    Column {
                        anchors.fill: parent
                        spacing: win._unit
                        Text { text: "Composite.LayoutShell · 20 项"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                        Repeater {
                            model: [
                                { m: "GET", p: "/NovaSidebar", d: "侧边导航工作台壳" },
                                { m: "GET", p: "/NovaTopNavigation", d: "顶部导航工作台壳" },
                                { m: "GET", p: "/NovaDualSide", d: "双侧边工作台壳" },
                                { m: "GET", p: "/NovaThreeColumn", d: "三栏工作台壳" },
                                { m: "GET", p: "/NovaChat", d: "AI 对话主窗口" },
                                { m: "GET", p: "/NovaFlexLayout", d: "实时运行看板" }
                            ]
                            Rectangle {
                                required property var modelData
                                required property int index
                                width: parent.width
                                height: 54
                                radius: NovaTheme.radiusS
                                color: win.activeApi === index ? NovaTheme.surface : (apiArea.containsMouse ? NovaTheme.surfaceAlt : "transparent")
                                border { width: win.activeApi === index ? 1 : 0; color: NovaTheme.outline }
                                Rectangle {
                                    anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                                    width: 42; height: 22; radius: 4
                                    color: NovaTheme.primary
                                    Text { anchors.centerIn: parent; text: modelData.m; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontXS }
                                }
                                Text { anchors { left: parent.left; leftMargin: 66; top: parent.top; topMargin: 9 } text: modelData.p; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                                Text { anchors { left: parent.left; leftMargin: 66; bottom: parent.bottom; bottomMargin: 9 } text: modelData.d; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                MouseArea { id: apiArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.activeApi = index }
                            }
                        }
                    }
                }
            }

            // ④ 详情：方法 / 路径 / 参数表
            detailSlot: Item {
                anchors.fill: parent
                Column {
                    anchors { fill: parent; topMargin: win._unit }
                    spacing: win._gap
                    Text { text: "接口详情"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                    Rectangle {
                        width: parent.width; height: 66; radius: NovaTheme.radiusS
                        color: NovaTheme.surfaceAlt
                        border { width: 1; color: NovaTheme.outline }
                        Rectangle { anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter } width: 44; height: 24; radius: 4; color: NovaTheme.primary; Text { anchors.centerIn: parent; text: "GET"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontXS } }
                        Text { anchors { left: parent.left; leftMargin: 66; verticalCenter: parent.verticalCenter } text: "/NovaThreeColumn"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    }
                    Text { text: "配置属性"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Repeater {
                        model: [
                            { n: "treeSize", t: "real", d: "目录树栏宽度" },
                            { n: "detailSize", t: "real", d: "详情栏宽度" },
                            { n: "showHeader", t: "bool", d: "是否显示顶栏" },
                            { n: "showFooter", t: "bool", d: "是否显示底栏" },
                            { n: "bordered", t: "bool", d: "是否显示栏间分隔" }
                        ]
                        Rectangle {
                            required property var modelData
                            width: parent.width; height: 40
                            color: "transparent"
                            Text { anchors { left: parent.left; verticalCenter: parent.verticalCenter } text: modelData.n; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                            Text { anchors { right: parent.right; verticalCenter: parent.verticalCenter } text: modelData.t; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
                            Rectangle { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } height: 1; color: NovaTheme.outline }
                        }
                    }
                    Text { text: "信号：columnResized(string, real)"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
            }

            // ⑤ 状态栏：真实服务态
            footerSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: win._gap; verticalCenter: parent.verticalCenter }
                    spacing: win._unit
                    Rectangle { width: 7; height: 7; radius: 3.5; color: NovaTheme.positive }
                    Text { text: "本地 API 索引已加载 · 139 类型"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                }
                Text { anchors { right: parent.right; rightMargin: win._gap; verticalCenter: parent.verticalCenter } text: "指纹 4f882374ad52262b"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
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
            text: "装配态  ·  三级表面色阶 / 恒定锚链  ·  浅/深双主题  ·  顶底栏切换变体"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
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
                Text { text: "顶底栏切换"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                CheckBox { checked: win.variantMode; onCheckedChanged: win.variantMode = checked }
            }
            Rectangle { width: parent.width; height: 1; color: NovaTheme.outline }
            Text { text: "signal 回显"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
            Text { text: win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap; width: parent.width }
        }
    }
}
