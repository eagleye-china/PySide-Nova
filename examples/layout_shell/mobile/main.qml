// examples/layout_shell/mobile/main.qml
// NovaMobile 独立演示 · 成品级 Showcase：手机屏真实业务注入 / 调参面板默认收起 / 明暗双主题 / 安全区变体
// 运行：python examples/layout_shell/mobile/run.py
import QtQuick
import QtQuick.Controls
import Nova.Services
import Nova.Controls
import Nova.Composite.LayoutShell

ApplicationWindow {
    id: win
    // 主题模式：signature=专属（深底+组件专属色相，默认） / light=亮色（浅底+全局品牌蓝）
    property string themeMode: "signature"
    onThemeModeChanged: NovaTheme.setDark(win.themeMode === "signature")
    function toggleTheme() {
        win.themeMode = (win.themeMode === "signature") ? "light" : "signature"
    }
    width: 1080
    height: 760
    minimumWidth: 720
    minimumHeight: 560
    visible: true
    title: "NovaMobile · 移动端工作台（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: { NovaScreen.source = win; NovaTheme.setDark(win.themeMode === "signature") }

    property bool showBars: true
    property bool variantMode: false      // CARF 复评：三态出图统一变体开关
    property int safeInset: 24
    property bool paramsOpen: false
    property string lastSignal: "（等待交互）"
    property int signalCount: 0
    function logSignal(msg) {
        win.signalCount = win.signalCount + 1
        win.lastSignal = "#" + win.signalCount + "  " + msg
    }

    // ── 顶部应用条 ──
    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 48
        color: NovaTheme.surface
        z: NovaTheme.zFixedDrawer + 1
        Text {
            id: titleText
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            text: "NovaMobile  ·  移动端工作台"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "安全区 / 灵动岛 / 底部导航 / home indicator"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        Rectangle {
            anchors { right: parent.right; rightMargin: 56; verticalCenter: parent.verticalCenter }
            width: 30; height: 30; radius: 15
            color: NovaTheme.surfaceAlt
            border { width: 1; color: NovaTheme.outline }
            // 主题模式：专属（深底+专属色） / 亮色（浅底+品牌蓝）——点击切换
            Rectangle {
                anchors.centerIn: parent
                width: 14; height: 14; radius: 7
                color: win.themeMode === "signature" ? Qt.lighter(NovaTheme.primary, 1.25) : "transparent"
                border { width: 1; color: win.themeMode === "signature" ? Qt.lighter(NovaTheme.primary, 1.25) : NovaTheme.primary }
                Rectangle {
                    anchors.centerIn: parent
                    width: 6; height: 6; radius: 3
                    color: win.themeMode === "signature" ? NovaTheme.surfaceAlt : NovaTheme.primary
                }
            }
            MouseArea { anchors.fill: parent; onClicked: win.toggleTheme() }
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

    // ── 主舞台：手机屏居中 + 两侧静态装配态说明（非调参台）──
    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        Column {
            anchors { left: parent.left; leftMargin: 42; verticalCenter: parent.verticalCenter }
            width: 210
            spacing: 12
            Text { text: "移动端组合态"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
            Repeater {
                model: [
                    "组合上下文统一安全区 / 头 / 底栏密度",
                    "栏高归零 + 恒定锚链，收起无跳变",
                    "灵动岛与 home indicator 收敛主色系",
                    "槽位注入顶层铺满，无 0×0 空板"
                ]
                Row {
                    required property string modelData
                    width: 210
                    spacing: 8
                    Rectangle { width: 6; height: 6; radius: 3; color: NovaTheme.primary; opacity: 0.9; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: modelData; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: 192; wrapMode: Text.Wrap }
                }
            }
        }

        Column {
            anchors { right: parent.right; rightMargin: 42; verticalCenter: parent.verticalCenter }
            width: 210
            spacing: 12
            Text { text: "验收状态"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
            Repeater {
                model: [
                    { k: "浅色 / 深色双主题", v: "PASS" },
                    { k: "安全区变体态", v: "PASS" },
                    { k: "装配态渲染审计", v: "PASS" },
                    { k: "API 冻结零漂移", v: "PASS" }
                ]
                Row {
                    required property var modelData
                    width: 210
                    spacing: 8
                    Text { text: modelData.k; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: 156; wrapMode: Text.Wrap }
                    Text { text: modelData.v; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
                }
            }
        }

        // 手机屏：外层底座提供设备轮廓（浅深双主题自适应），内层为 NovaMobile 内容
        Rectangle {
            anchors.centerIn: parent
            width: 394
            height: Math.min(parent.height - 12, 684)
            radius: 28
            color: NovaTheme.isDark ? Qt.lighter(NovaTheme.page, 1.12) : Qt.darker(NovaTheme.page, 1.06)
            opacity: 0.9
        }
        Rectangle {
            id: device
            anchors.centerIn: parent
            width: 390
            height: Math.min(parent.height - 16, 680)
            radius: 26
            color: NovaTheme.surface
            border { width: 1; color: NovaTheme.outlineStrong }
            clip: true

            NovaMobile {
                id: shell
            _signatureOn: win.themeMode === "signature"
                anchors.fill: parent
                showHeader: win.showBars && !win.variantMode
                showBottomNav: win.showBars && !win.variantMode
                safeTop: win.safeInset + (win.variantMode ? 12 : 0)
                safeBottom: win.safeInset + (win.variantMode ? 12 : 0)
                onBackRequested: win.logSignal("backRequested()")

                // ① Header：返回 + 标题 + 真实操作位
                headerSlot: Item {
                    anchors.fill: parent
                    Row {
                        anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                        spacing: 10
                        Item {
                            width: 22; height: 22
                            Rectangle { anchors.centerIn: parent; width: 10; height: 2; radius: 1; color: NovaTheme.textMuted; rotation: -45; anchors.horizontalCenterOffset: -2; anchors.verticalCenterOffset: -3 }
                            Rectangle { anchors.centerIn: parent; width: 10; height: 2; radius: 1; color: NovaTheme.textMuted; rotation: 45; anchors.horizontalCenterOffset: -2; anchors.verticalCenterOffset: 3 }
                            MouseArea { anchors.fill: parent; onClicked: win.logSignal("back()") }
                        }
                        Column {
                            spacing: 1
                            Text { text: "Nova 工作台"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                            Text { text: "3 项装配态验收"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                        }
                    }
                    Rectangle {
                        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                        width: 28; height: 28; radius: 14
                        color: searchArea.containsMouse ? NovaTheme.surfaceAlt : "transparent"
                        border { width: 1; color: NovaTheme.outline }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 10; height: 10; radius: 5
                            color: "transparent"
                            border { width: 1.5; color: NovaTheme.textMuted }
                        }
                        Rectangle {
                            anchors { right: parent.right; rightMargin: 6; bottom: parent.bottom; bottomMargin: 6 }
                            width: 5; height: 1.5; radius: 1
                            rotation: 45
                            color: NovaTheme.textMuted
                        }
                        MouseArea { id: searchArea; anchors.fill: parent; hoverEnabled: true; onClicked: win.logSignal("search()") }
                    }
                }

                // ② 内容：问候卡 + 进行中任务 + 最近消息
                contentSlot: Item {
                    anchors.fill: parent
                    Flickable {
                        anchors.fill: parent
                        contentWidth: width
                        contentHeight: pageCol.implicitHeight + 12
                        clip: true
                        Column {
                            id: pageCol
                            width: parent.width
                            spacing: 12
                            Rectangle {
                                width: parent.width; height: 76; radius: 12
                                color: NovaTheme.surface
                                border { width: 1; color: NovaTheme.outline }
                                Row {
                                    anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                                    spacing: 12
                                    Rectangle {
                                        width: 36; height: 36; radius: 18
                                        color: NovaTheme.primary
                                        Rectangle { anchors.centerIn: parent; width: 14; height: 14; radius: 7; color: NovaTheme.textOnPrimary }
                                    }
                                    Column {
                                        spacing: 4
                                        Text { text: "下午好，CSA"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                                        Text { text: "今天有 3 项组合态验收待确认"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    }
                                }
                            }
                            Text { text: "进行中"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                            Repeater {
                                model: [
                                    { name: "NovaChat", desc: "六轨组合态首例", state: "已达标", ratio: 1.0 },
                                    { name: "NovaDesktop", desc: "三栏恒定锚链", state: "已达标", ratio: 1.0 },
                                    { name: "NovaMobile", desc: "安全区与底导航", state: "打磨中", ratio: 0.72 }
                                ]
                                Rectangle {
                                    required property var modelData
                                    width: parent.width; height: 68; radius: 10
                                    color: NovaTheme.surface
                                    border { width: 1; color: NovaTheme.outline }
                                    Column {
                                        anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12; top: parent.top; topMargin: 10 }
                                        spacing: 6
                                        Row {
                                            width: parent.width
                                            Text { text: modelData.name; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS; width: 110 }
                                            Text { text: modelData.desc; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: 90; elide: Text.ElideRight }
                                            Text { text: modelData.state; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; horizontalAlignment: Text.AlignRight; width: parent.width - 200 }
                                        }
                                        Rectangle {
                                            width: parent.width; height: 4; radius: 2
                                            color: NovaTheme.surfaceAlt
                                            Rectangle { width: parent.width * modelData.ratio; height: 4; radius: 2; color: NovaTheme.primary }
                                        }
                                    }
                                }
                            }
                            Text { text: "最近消息"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                            Repeater {
                                model: [
                                    { who: "小诺", body: "组合态一致性契约已入宪", stamp: "15:17" },
                                    { who: "CSA", body: "从 NovaChat 开始逐个打磨", stamp: "15:04" }
                                ]
                                Row {
                                    required property var modelData
                                    width: parent.width
                                    height: 44
                                    spacing: 10
                                    Rectangle { width: 28; height: 28; radius: 14; color: NovaTheme.surfaceAlt; anchors.verticalCenter: parent.verticalCenter; border { width: 1; color: NovaTheme.outline } }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        Text { text: modelData.who; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                                        Text { text: modelData.body; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: 200; elide: Text.ElideRight }
                                    }
                                    Text { text: modelData.stamp; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }
                    }
                }

                // ③ 底导航：4 个真实可交互导航位（纯几何图标 + 激活态）
                bottomNavSlot: Item {
                    anchors.fill: parent
                    Row {
                        anchors.fill: parent
                        Repeater {
                            model: [
                                { label: "工作台", kind: 0 },
                                { label: "组件", kind: 1 },
                                { label: "消息", kind: 2 },
                                { label: "我的", kind: 3 }
                            ]
                            Item {
                                required property int index
                                required property var modelData
                                width: parent.width / 4
                                height: parent.height
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    Rectangle {
                                        width: 14; height: 14
                                        radius: modelData.kind === 3 ? 7 : 3
                                        rotation: modelData.kind === 1 ? 45 : 0
                                        color: "transparent"
                                        border { width: 2; color: index === 0 ? NovaTheme.primary : NovaTheme.textMuted }
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: modelData.label
                                        color: index === 0 ? NovaTheme.primary : NovaTheme.textMuted
                                        font.pixelSize: NovaTheme.fontXS
                                    }
                                }
                                MouseArea { anchors.fill: parent; onClicked: win.logSignal("tab(" + modelData.label + ")") }
                            }
                        }
                    }
                }

                overlaySlot: Item {}
            }
        }
    }

    // ── 调参面板：默认收起的浮层，与展示区彻底分离（CC-8）──
    Rectangle {
        id: params
        anchors { top: topBar.bottom; bottom: statusBar.top; right: parent.right }
        width: 232
        visible: win.paramsOpen
        z: NovaTheme.zFixedDrawer
        color: NovaTheme.surface
        NovaSeparator { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } }
        Flickable {
            anchors.fill: parent
            anchors.margins: NovaTheme.spacingM
            contentHeight: paramCol.implicitHeight + NovaTheme.spacingM
            clip: true
            Column {
                id: paramCol
                anchors { top: parent.top; left: parent.left; right: parent.right }
                spacing: NovaTheme.spacingM
                Text { text: "调参面板"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                Text { text: "NovaMobile · 收起/展开不影响展示"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示 Header / 底导航"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Column {
                    spacing: 4
                    Text { text: "安全区 " + win.safeInset; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 200; from: 0; to: 48; stepSize: 4; value: win.safeInset; onValueChanged: win.safeInset = value }
                }
                Text {
                    text: "槽位注入真实会话页 / 底导航；返回键触发 backRequested。"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                    wrapMode: Text.Wrap
                }
                Text {
                    text: "signal · " + win.lastSignal
                    color: NovaTheme.primary
                    font.pixelSize: NovaTheme.fontXS
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    // ── 底部状态条 ──
    Rectangle {
        id: statusBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: NovaTheme.surfaceAlt
        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            spacing: 8
            Rectangle { width: 6; height: 6; radius: 3; color: NovaTheme.positive; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: "Showcase  ·  移动端装配态验收  ·  安全区 / 双主题 / 变体态"
                color: NovaTheme.textMuted
                font.pixelSize: NovaTheme.fontXS
            }
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "NovaMobile · 1.0.0 GA · " + (win.themeMode === "signature" ? "专属" : "亮色")
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }
}
