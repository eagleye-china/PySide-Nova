// examples/layout_shell/desktop/main.qml
// NovaDesktop 独立演示 · 成品级 Showcase：三栏真实业务注入 / 调参面板默认收起 / 真实交互位 / 明暗双主题
// 运行：python examples/layout_shell/desktop/run.py
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
    width: 1280
    height: 800
    minimumWidth: 720
    minimumHeight: 520
    visible: true
    title: "NovaDesktop · 桌面工作台（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: { NovaScreen.source = win; NovaTheme.setDark(win.themeMode === "signature") }

    property bool showBars: true
    property bool variantMode: false      // CARF 复评：三态出图统一变体开关
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
            text: "NovaDesktop  ·  桌面工作台"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "菜单栏 / 工具栏 / 页面 / 状态栏"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        // 主题切换（纯几何日月，零字体依赖）
        Rectangle {
            id: themeBtn
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
        // 调参开关（纯几何三横线）
        Rectangle {
            id: paramsBtn
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

    // ── 主舞台：五槽全部注入真实业务内容 ──
    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaDesktop {
            id: shell
            _signatureOn: win.themeMode === "signature"
            anchors.fill: parent
            showMenu: win.showBars && !win.variantMode
            showToolbar: win.showBars && !win.variantMode
            showStatus: win.showBars && !win.variantMode
            onWindowCloseRequested: win.logSignal("windowCloseRequested()")

            // ① 菜单栏：真实菜单项（hover 高亮 + 可点击）
            menuSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                    spacing: 2
                    Repeater {
                        model: ["文件", "编辑", "视图", "工具", "帮助"]
                        Rectangle {
                            required property string modelData
                            width: 54; height: 24; radius: 4
                            color: menuArea.containsMouse ? NovaTheme.surfaceAlt : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: NovaTheme.textColor
                                font.pixelSize: NovaTheme.fontXS
                            }
                            MouseArea {
                                id: menuArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.logSignal("menu(" + modelData + ")")
                            }
                        }
                    }
                }
                Text {
                    anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                    text: "nova-workspace  ·  main"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                }
            }

            // ② 工具栏：真实工具位（纯几何图标 + 文本 + 分组竖线）
            toolbarSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    spacing: 6
                    Repeater {
                        model: [
                            { label: "新建", kind: 0 }, { label: "打开", kind: 1 }, { label: "保存", kind: 2 },
                            { label: "运行", kind: 3 }, { label: "调试", kind: 4 }
                        ]
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: 66; height: 30; radius: 6
                            color: toolArea.containsMouse ? NovaTheme.surface : "transparent"
                            border { width: 1; color: toolArea.containsMouse ? NovaTheme.outline : "transparent" }
                            Row {
                                anchors.centerIn: parent
                                spacing: 6
                                Rectangle {
                                    width: 10; height: 10; radius: modelData.kind === 4 ? 5 : 2
                                    rotation: modelData.kind === 0 ? 45 : 0
                                    color: "transparent"
                                    border { width: 1.5; color: modelData.kind === 3 ? NovaTheme.primary : NovaTheme.textMuted }
                                }
                                Text { text: modelData.label; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                            }
                            // 第三项后分组竖线（唯一分隔，不与 Shell 边界线叠加）
                            Rectangle {
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                width: 1; height: 18
                                color: NovaTheme.outline
                                visible: index === 2
                            }
                            MouseArea {
                                id: toolArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: win.logSignal("tool(" + modelData.label + ")")
                            }
                        }
                    }
                }
                Text {
                    anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                    text: "QML / PySide6"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                }
            }

            // ③ 页面：文件树 + 编辑区（真实 IDE 场景）
            pageSlot: Item {
                anchors.fill: parent
                Row {
                    anchors.fill: parent
                    spacing: 0
                    // 文件树
                    Rectangle {
                        width: 216; height: parent.height
                        color: NovaTheme.surfaceAlt
                        Column {
                            anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 10; top: parent.top; topMargin: 14 }
                            spacing: 6
                            Text { text: "项目文件"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                            Repeater {
                                model: [
                                    { name: "NovaDesktop.qml", meta: "组合根容器", active: true },
                                    { name: "main.qml", meta: "演示入口", active: false },
                                    { name: "NovaTheme.qml", meta: "设计令牌", active: false },
                                    { name: "README.md", meta: "说明文档", active: false },
                                    { name: "CHANGELOG.md", meta: "变更记录", active: false }
                                ]
                                Rectangle {
                                    required property var modelData
                                    width: parent.width; height: 36; radius: 6
                                    color: modelData.active ? Qt.lighter(NovaTheme.surfaceAlt, 1.10)
                                         : (fileArea.containsMouse ? NovaTheme.surface : "transparent")
                                    Rectangle {
                                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                        width: 2
                                        color: NovaTheme.primary
                                        visible: modelData.active
                                    }
                                    Column {
                                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                        spacing: 2
                                        Text { text: modelData.name; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                                        Text { text: modelData.meta; color: NovaTheme.textMuted; font.pixelSize: 10 }
                                    }
                                    MouseArea {
                                        id: fileArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: win.logSignal("open(" + modelData.name + ")")
                                    }
                                }
                            }
                        }
                    }
                    NovaSeparator { height: parent.height; vertical: true }
                    // 编辑区
                    Item {
                        width: parent.width - 217; height: parent.height
                        Rectangle {
                            anchors { left: parent.left; right: parent.right; top: parent.top }
                            height: 40
                            color: NovaTheme.surface
                            Text {
                                anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
                                text: "NovaDesktop.qml"
                                color: NovaTheme.textColor
                                font { pixelSize: NovaTheme.fontS; bold: true }
                            }
                            Text {
                                anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                                text: "组合态一致性契约 CC · 0.9.0"
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                            }
                        }
                        Column {
                            anchors { left: parent.left; leftMargin: 22; right: parent.right; rightMargin: 22; top: parent.top; topMargin: 58 }
                            spacing: 9
                            Repeater {
                                model: [
                                    "Item { id: root",
                                    "    LayoutMirroring.enabled: NovaTheme.isRtl",
                                    "    readonly property real _gap: root._unit * 2",
                                    "    readonly property int  _dur: NovaMotion.duration(...)",
                                    "    // 三栏共享组合上下文，锚链恒定",
                                    "    NovaPage { id: _page; padding: 0 }",
                                    "}"
                                ]
                                Row {
                                    required property int index
                                    required property string modelData
                                    spacing: 16
                                    Text { text: String(index + 1).padStart(2, " "); color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: modelData; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                                }
                            }
                            Item { width: 1; height: 10 }
                            Text { text: "装配态检查清单"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                            Repeater {
                                model: [
                                    { item: "组合上下文唯一密度源 · 13 个 _ 私有常量", ok: true },
                                    { item: "每边界唯一分隔源 · 三栏不叠线", ok: true },
                                    { item: "恒定锚链 + 栏高归零 · 收起无跳变", ok: true },
                                    { item: "装饰收敛主色系 · 无仿交互控件", ok: true },
                                    { item: "槽位注入顶层 anchors.fill · 无 0×0", ok: true }
                                ]
                                Row {
                                    required property var modelData
                                    spacing: 10
                                    Rectangle {
                                        width: 8; height: 8; radius: 4
                                        color: modelData.ok ? NovaTheme.primary : NovaTheme.textMuted
                                        opacity: 0.9
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text { text: modelData.item; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: modelData.ok ? "PASS" : "—"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                }
                            }
                        }
                        Rectangle {
                            anchors { left: parent.left; leftMargin: 22; right: parent.right; rightMargin: 22; bottom: parent.bottom; bottomMargin: 20 }
                            height: 62; radius: 10
                            color: NovaTheme.surface
                            border { width: 1; color: NovaTheme.outline }
                            Row {
                                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                                spacing: 24
                                Column {
                                    spacing: 3
                                    Text { text: "组合上下文"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: "13 个 _ 私有常量"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                                }
                                Column {
                                    spacing: 3
                                    Text { text: "边界分隔"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: "每边界唯一分隔源"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                                }
                                Column {
                                    spacing: 3
                                    Text { text: "折叠动效"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: "栏高归零 · 锚链恒定"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                                }
                            }
                        }
                    }
                }
            }

            // ④ 状态栏：真实编辑器状态（非调试字样）
            statusSlot: Item {
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                    spacing: 14
                    Text { text: "就绪"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "5 个文件"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "UTF-8"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "QML"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
                Row {
                    anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                    spacing: 14
                    Text { text: "Ln 12, Col 8"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Text { text: "100%"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                }
            }

            overlaySlot: Item {}
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
                Text { text: "NovaDesktop · 三栏收起/展开不影响展示"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示三栏"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Text {
                    text: "槽位注入真实菜单 / 工具 / 文件树 / 编辑器内容；Esc 触发 windowCloseRequested。"
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
                text: "Showcase  ·  装配态验收  ·  三栏 / 变体态 / 双主题"
                color: NovaTheme.textMuted
                font.pixelSize: NovaTheme.fontXS
            }
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "NovaDesktop · 1.0.0 GA · " + (win.themeMode === "signature" ? "专属" : "亮色")
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }
}
