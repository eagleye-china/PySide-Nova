// examples/layout_shell/incubator/main.qml
// NovaIncubator 独立演示 · 成品级 Showcase：七槽真实业务注入 / 调参面板默认收起 / 人工确认闸门 / 明暗双主题
// 运行：python examples/layout_shell/incubator/run.py
// 业务语义（配方 / 七区 / 三重校验 / 证书签发）全部在此注入，Shell 侧不持有任何孵化状态
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
    width: 1440
    height: 900
    minimumWidth: 960
    minimumHeight: 600
    visible: true
    title: "NovaIncubator · 诺瓦应用孵化器（成品级 Showcase）"
    color: NovaTheme.page

    Component.onCompleted: { NovaScreen.source = win; NovaTheme.setDark(win.themeMode === "signature") }

    property bool variantMode: false
    property bool paramsOpen: false
    property bool collapsed: false
    property bool showBars: true
    property real recipeSize: 264
    property real validateSize: 344
    property int certificateHeight: 190
    property int activeRecipe: 0
    property string lastSignal: "（等待交互）"
    property int signalCount: 0
    property bool gateOpen: false
    property bool frozen: false
    property int stage: 3

    readonly property var recipes: [
        { code: "R1", name: "Orbit 旗舰工作台", form: "意图轨道工作台", maturity: "FINAL",
          required: "NovaDesk · NovaFlexLayout · NovaOrbit · NovaCopilot",
          optional: "NovaAgent / NovaDE", gate: "O1–O8 全过 · Copilot 闸门不可绕过" },
        { code: "R2", name: "数字员工队伍", form: "部门级数字员工流水线", maturity: "FINAL",
          required: "NovaDesk · NovaFlexLayout · NovaDE · NovaCopilot",
          optional: "NovaAgent / NovaOrbit", gate: "DE 四要件 · 影子模式 ≥48h" },
        { code: "R3", name: "智能任务台", form: "任务型自主执行工作台", maturity: "FINAL",
          required: "NovaDesk · NovaFlexLayout · NovaAgent · NovaCopilot",
          optional: "NovaOrbit / NovaDE", gate: "Agent 八项准入 · 外部验证器独立" },
        { code: "R4", name: "全端协同应用", form: "桌面 + 移动 + 大屏一体", maturity: "FINAL",
          required: "NovaDesk · NovaMobile · NovaFlexLayout · NovaCopilot",
          optional: "NovaOrbit / NovaAgent / NovaDE", gate: "FlexLayout 跨端一致性全过" },
        { code: "R5", name: "极简 Copilot 应用", form: "单职能嵌入式协作", maturity: "FINAL",
          required: "NovaDesk · NovaFlexLayout · NovaCopilot",
          optional: "—", gate: "Copilot 三模落地 · grounding 不提权" }
    ]
    readonly property var zones: [
        { k: "区1 shell", v: "PrescientLayoutShell.v2 · desk / mobile / large_screen" },
        { k: "区2 components", v: "必选 4 件 · 可选 2 件 · 版本范围校验" },
        { k: "区3 intelligence", v: "orbit_entity_router · HITL 闸门" },
        { k: "区4 governance", v: "SSO + 租户隔离 · OTel 统一流 · 数据边界" },
        { k: "区5 acceptance", v: "prescript_validate · carf_gate · 组件门禁" },
        { k: "区6 delivery", v: "运行包 · 治理清单 · 审计接入 · 证书 · 升级路径" },
        { k: "区7 observability", v: "p99 < 200ms · availability 99.95%" }
    ]
    readonly property var checks: [
        { k: "配方合规", d: "七区完整性 + 配方版本 + ceiling_grade", s: "PASS" },
        { k: "契约合规", d: "调用 prescript validate · 壳契约 / 槽位边界", s: "PASS" },
        { k: "门禁合规", d: "O1–O8 + Copilot 人工闸门 + Agent 准入", s: "PASS" }
    ]
    readonly property var bundle: [
        { k: "封版证书", d: "incubation.certificate.yaml" },
        { k: "运行包", d: "桌面 / 移动 / 大屏构建产物" },
        { k: "治理清单", d: "governance.manifest.yaml" },
        { k: "审计接入", d: "OTel + orbit_event_id 映射" },
        { k: "升级路径", d: "upgrade.path.yaml · semver" }
    ]
    readonly property var stages: ["Conceive 构想", "Achieve 实现", "Refine 打磨", "Freeze 封版"]

    function logSignal(msg) {
        win.signalCount = win.signalCount + 1
        win.lastSignal = "#" + win.signalCount + "  " + msg
    }
    function pick(i) {
        win.activeRecipe = i
        win.frozen = false
        win.gateOpen = false
        win.logSignal("recipe(" + win.recipes[i].code + ") · " + win.recipes[i].name)
    }
    function seal() {
        if (!win.frozen) {
            win.logSignal("freezeRequested() · 已上报宿主，等待人工确认闸门")
            win.gateOpen = true
        }
    }
    function confirm() {
        win.frozen = true
        win.gateOpen = false
        win.stage = 4
        win.logSignal("certificate issued · 封版证书五件套已签发")
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
            text: "NovaIncubator  ·  诺瓦应用孵化器"
            color: NovaTheme.textColor
            font { pixelSize: NovaTheme.fontM; bold: true }
        }
        Text {
            anchors { left: titleText.right; leftMargin: 18; verticalCenter: parent.verticalCenter }
            text: "选配方 · 注业务 · 三重校验 · 一次封版"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
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

    // ── 主舞台：七槽全部注入真实业务内容 ──
    Item {
        id: stage
        anchors { top: topBar.bottom; bottom: statusBar.top; left: parent.left; right: parent.right }

        NovaIncubator {
            id: shell
            _signatureOn: win.themeMode === "signature"
            anchors.fill: parent
            recipeSize: win.recipeSize
            validateSize: win.validateSize
            certificateHeight: win.certificateHeight
            recipeCollapsed: win.collapsed
            validateCollapsed: win.collapsed
            showGlobal: win.showBars && !win.variantMode
            showRecipe: win.showBars && !win.variantMode
            showValidate: win.showBars && !win.variantMode
            showPipeline: win.showBars
            showCertificate: win.showBars
            onRecipeToggled: function(c) { win.logSignal("recipeToggled(" + c + ")"); win.collapsed = c }
            onValidateToggled: function(c) { win.logSignal("validateToggled(" + c + ")"); win.collapsed = c }
            onFreezeRequested: win.seal()

            // ① 全局栏：孵化系统身份 / 当前配方 / 封版状态
            globalSlot: Item {
                anchors.fill: parent
                Rectangle {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    width: 10; height: 10; radius: 5
                    color: NovaTheme.primary
                }
                Text {
                    anchors { left: parent.left; leftMargin: 38; verticalCenter: parent.verticalCenter }
                    text: "NovaIncubator  ·  星海科技 / 企业租户  ·  配方 " + win.recipes[win.activeRecipe].code
                    color: NovaTheme.textColor
                    font { pixelSize: NovaTheme.fontS; bold: true }
                }
                Row {
                    anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 12
                    Rectangle {
                        width: 176; height: 26; radius: 6
                        color: NovaTheme.surfaceAlt
                        border { width: 1; color: NovaTheme.outline }
                        Text {
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            text: "搜索配方 / 组件 / 门禁…"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                        }
                    }
                    Rectangle {
                        width: 96; height: 26; radius: 6
                        color: win.frozen ? NovaTheme.primary : NovaTheme.surfaceAlt
                        border { width: 1; color: win.frozen ? NovaTheme.primary : NovaTheme.outline }
                        Text {
                            anchors.centerIn: parent
                            text: win.frozen ? "已封版 FINAL" : "孵化中 BETA"
                            color: win.frozen ? NovaTheme.textOnPrimary : NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                        }
                    }
                    Text {
                        text: "maturity " + win.recipes[win.activeRecipe].maturity
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // ② 左栏 配方库：R1~R5 五套首发配方 + 七区导航
            recipeSlot: Item {
                anchors.fill: parent
                Flickable {
                    anchors.fill: parent
                    contentHeight: recipeCol.implicitHeight + 24
                    Column {
                        id: recipeCol
                        anchors { top: parent.top; topMargin: 40; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                        spacing: 8
                        Text { text: "首发配方 · R1–R5"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                        Repeater {
                            model: win.recipes
                            Rectangle {
                                required property int index
                                required property var modelData
                                width: recipeCol.width
                                height: 62
                                radius: 6
                                color: win.activeRecipe === index ? Qt.lighter(NovaTheme.surfaceAlt, 1.08) : "transparent"
                                Rectangle {
                                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                    width: 3
                                    color: win.activeRecipe === index ? NovaTheme.primary : NovaTheme.outline
                                }
                                Column {
                                    anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                    spacing: 4
                                    Row {
                                        spacing: 8
                                        Text { text: modelData.code; color: NovaTheme.primary; font { pixelSize: NovaTheme.fontXS; bold: true } }
                                        Text { text: modelData.name; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: win.activeRecipe === index } }
                                    }
                                    Text {
                                        text: modelData.form
                                        color: NovaTheme.textMuted
                                        font.pixelSize: NovaTheme.fontXS
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.pick(index) }
                            }
                        }
                        Rectangle { width: recipeCol.width; height: 1; color: NovaTheme.outline }
                        Text { text: "七区契约导航 · incubator.recipe.yaml"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                        Flow {
                            width: recipeCol.width
                            spacing: 6
                            Repeater {
                                model: win.zones
                                Rectangle {
                                    required property var modelData
                                    width: zoneLabel.implicitWidth + 14; height: 22; radius: 5
                                    color: NovaTheme.surfaceAlt
                                    Text { id: zoneLabel; anchors.centerIn: parent; text: modelData.k; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.logSignal("zone(" + modelData.k + ") · 七区契约") }
                                }
                            }
                        }
                        Rectangle { width: recipeCol.width; height: 1; color: NovaTheme.outline }
                        Text { text: "成熟度 L1–L5 · 最低 L3 造配方"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    }
                }
            }

            // ③ 中栏 孵化舞台：七区配方契约 + 组件编排 + 治理清单
            stageSlot: Item {
                anchors.fill: parent
                Flickable {
                    anchors.fill: parent
                    contentHeight: stageCol.implicitHeight + 24
                    Column {
                        id: stageCol
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 8 }
                        width: Math.min(parent.width - 16, 760)
                        spacing: 12
                        Rectangle {
                            width: stageCol.width
                            height: 68
                            radius: 8
                            color: NovaTheme.surface
                            border { width: 1; color: NovaTheme.primary }
                            Rectangle {
                                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                width: 3; color: NovaTheme.primary
                            }
                            Column {
                                anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                spacing: 6
                                Row {
                                    spacing: 10
                                    Text { text: win.recipes[win.activeRecipe].code; color: NovaTheme.primary; font { pixelSize: NovaTheme.fontS; bold: true } }
                                    Text { text: win.recipes[win.activeRecipe].name; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                                    Text { text: "· " + win.recipes[win.activeRecipe].form; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                                }
                                Text {
                                    text: "ceiling_grade: true  ·  maturity " + win.recipes[win.activeRecipe].maturity + "  ·  C1–C6 六条硬标准全过"
                                    color: NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontXS
                                }
                            }
                        }
                        Text { text: "七区配方契约（缺区即拦截）"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                        Repeater {
                            model: win.zones
                            Rectangle {
                                required property int index
                                required property var modelData
                                width: stageCol.width
                                height: 44
                                radius: 6
                                color: NovaTheme.surface
                                border { width: 1; color: NovaTheme.outline }
                                Row {
                                    anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                    spacing: 12
                                    Rectangle {
                                        width: 22; height: 22; radius: 4
                                        color: NovaTheme.surfaceAlt
                                        Text { anchors.centerIn: parent; text: String(index + 1); color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 3
                                        Text { text: modelData.k; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                                        Text { text: modelData.v; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: stageCol.width - 80; elide: Text.ElideRight }
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: stageCol.width
                            height: 72
                            radius: 8
                            color: NovaTheme.surfaceAlt
                            Column {
                                anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                spacing: 5
                                Text { text: "组件编排 · 必选 / 可选"; color: NovaTheme.primary; font { pixelSize: NovaTheme.fontXS; bold: true } }
                                Text { text: "必选：" + win.recipes[win.activeRecipe].required; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS; width: parent.width; elide: Text.ElideRight }
                                Text { text: "可选：" + win.recipes[win.activeRecipe].optional; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: parent.width; elide: Text.ElideRight }
                            }
                        }
                        Rectangle {
                            width: stageCol.width
                            height: 60
                            radius: 8
                            color: NovaTheme.surfaceAlt
                            Column {
                                anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                spacing: 5
                                Text { text: "治理随配方同行 · 四类必填"; color: NovaTheme.primary; font { pixelSize: NovaTheme.fontXS; bold: true } }
                                Text { text: "身份 SSO / 审计 OTel / 数据边界 / 成本归因 —— init 阶段写入配方"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS; width: parent.width; elide: Text.ElideRight }
                            }
                        }
                        Text {
                            text: "配方门禁：" + win.recipes[win.activeRecipe].gate
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                            width: stageCol.width
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            // ④ 底部 CARF 四阶段条 + 请求封版入口
            pipelineSlot: Item {
                id: pipelineHost
                anchors.fill: parent
                Row {
                    anchors { left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                    spacing: 8
                    Repeater {
                        model: win.stages
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: Math.max(96, (pipelineHost.width - 260) / 4)
                            height: 30
                            radius: 6
                            color: index <= win.stage ? NovaTheme.primary : NovaTheme.surfaceAlt
                            border { width: 1; color: index <= win.stage ? NovaTheme.primary : NovaTheme.outline }
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: index <= win.stage ? NovaTheme.textOnPrimary : NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { win.stage = index; win.logSignal("stage(" + index + ") · " + modelData) } }
                        }
                    }
                    Rectangle {
                        width: freezeLabel.implicitWidth + 24; height: 30; radius: 6
                        color: win.frozen ? NovaTheme.surfaceAlt : NovaTheme.primary
                        border { width: 1; color: win.frozen ? NovaTheme.outline : NovaTheme.primary }
                        Text {
                            id: freezeLabel
                            anchors.centerIn: parent
                            text: win.frozen ? "已签发证书" : "请求封版"
                            color: win.frozen ? NovaTheme.textMuted : NovaTheme.textOnPrimary
                            font.pixelSize: NovaTheme.fontS
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: shell.requestFreeze() }
                    }
                }
            }

            // ⑤ 右栏 三重校验：配方 / 契约 / 门禁
            validateSlot: Item {
                anchors.fill: parent
                Column {
                    id: validateCol
                    anchors { top: parent.top; topMargin: 40; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    spacing: 8
                    Text { text: "三重校验 · incubator validate"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    Repeater {
                        model: win.checks
                        Rectangle {
                            required property int index
                            required property var modelData
                            width: validateCol.width
                            height: 60
                            radius: 6
                            color: NovaTheme.surface
                            border { width: 1; color: NovaTheme.outline }
                            Rectangle {
                                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                width: 3; color: NovaTheme.positive
                            }
                            Column {
                                anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                spacing: 4
                                Row {
                                    spacing: 8
                                    Text { text: String(index + 1); color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
                                    Text { text: modelData.k; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontS; bold: true } }
                                    Text { text: modelData.s; color: NovaTheme.positive; font.pixelSize: NovaTheme.fontXS }
                                }
                                Text { text: modelData.d; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: parent.width; elide: Text.ElideRight }
                            }
                        }
                    }
                    Rectangle { width: validateCol.width; height: 1; color: NovaTheme.outline }
                    Text { text: "结论 · 三层全过方可 freeze"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS }
                    Rectangle {
                        width: validateCol.width; height: 34; radius: 6
                        color: NovaTheme.surfaceAlt
                        Text {
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            text: "prescript validate → 调用（非重写）"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                        }
                    }
                    Text {
                        text: "人工闸门不可绕过：Copilot 三模 / Agent 高风险审批 / DE 升级路径"
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                        width: validateCol.width
                        wrapMode: Text.Wrap
                    }
                }
            }

            // ⑥ 封版证书栏：五件套预览
            certificateSlot: Item {
                anchors.fill: parent
                Column {
                    id: certCol
                    anchors { top: parent.top; topMargin: 36; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    spacing: 5
                    Row {
                        spacing: 8
                        Text { text: "封版证书 · 五件套"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                        Text {
                            text: win.frozen ? "已签发" : "待签发"
                            color: win.frozen ? NovaTheme.positive : NovaTheme.warning
                            font.pixelSize: NovaTheme.fontXS
                        }
                    }
                    Repeater {
                        model: win.bundle
                        Rectangle {
                            required property var modelData
                            width: certCol.width
                            height: 22
                            radius: 4
                            color: NovaTheme.surface
                            Row {
                                anchors { left: parent.left; leftMargin: 8; right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                spacing: 8
                                Rectangle { width: 5; height: 5; radius: 2.5; color: win.frozen ? NovaTheme.positive : NovaTheme.outline; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: modelData.k; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontXS }
                                Text { text: modelData.d; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; width: parent.width - 110; elide: Text.ElideRight }
                            }
                        }
                    }
                }
            }

            // ⑦ 浮层：人工确认闸门由业务注入，壳不自动封版
            overlaySlot: Item {
                anchors.fill: parent
                Rectangle {
                    visible: win.gateOpen
                    anchors.centerIn: parent
                    width: 360; height: 176
                    radius: 10
                    color: NovaTheme.surface
                    border { width: 1; color: NovaTheme.primary }
                    Column {
                        anchors { fill: parent; margins: 18 }
                        spacing: 10
                        Text { text: "人工确认闸门 · freeze-gate"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                        Text {
                            text: "配方 " + win.recipes[win.activeRecipe].code + " 三重校验全过。签发封版证书须经宿主一次显式确认；壳只 emit freezeRequested()，不自动封版。"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                            width: parent.width
                            wrapMode: Text.Wrap
                        }
                        Row {
                            spacing: 10
                            Rectangle {
                                width: 118; height: 30; radius: 6
                                color: NovaTheme.primary
                                Text { anchors.centerIn: parent; text: "确认签发"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.confirm() }
                            }
                            Rectangle {
                                width: 96; height: 30; radius: 6
                                color: NovaTheme.surfaceAlt
                                border { width: 1; color: NovaTheme.outline }
                                Text { anchors.centerIn: parent; text: "取消"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { win.gateOpen = false; win.logSignal("gate cancelled · 未签发") } }
                            }
                        }
                    }
                }
            }
        }

        // ── 调参浮层（默认收起，与展示区隔离）──
        Rectangle {
            id: params
            visible: win.paramsOpen
            anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
            width: 288
            z: NovaTheme.zFixedDrawer
            color: NovaTheme.surface
            border { width: 1; color: NovaTheme.outline }
            Column {
                anchors { fill: parent; margins: NovaTheme.spacingM }
                spacing: NovaTheme.spacingM
                Text { text: "调参面板"; color: NovaTheme.textColor; font { pixelSize: NovaTheme.fontM; bold: true } }
                Text { text: "NovaIncubator · 收起/展开不影响展示"; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "折叠左右两栏"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.collapsed; onCheckedChanged: win.collapsed = checked }
                }
                Row {
                    spacing: NovaTheme.spacingS
                    Text { text: "显示全部栏位"; anchors.verticalCenter: parent.verticalCenter; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    CheckBox { checked: win.showBars; onCheckedChanged: win.showBars = checked }
                }
                Column {
                    spacing: 4
                    Text { text: "配方库宽 " + Math.round(win.recipeSize); color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 240; from: 180; to: 420; stepSize: 20; value: win.recipeSize; onValueChanged: win.recipeSize = value }
                }
                Column {
                    spacing: 4
                    Text { text: "校验栏宽 " + Math.round(win.validateSize); color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                    Slider { width: 240; from: 200; to: 460; stepSize: 20; value: win.validateSize; onValueChanged: win.validateSize = value }
                }
                Text {
                    text: "配方解释器 / 组件装配器 / 治理注入器 / 三重校验器 / 证书签发器由业务槽位注入；Shell 只托管七槽布局。"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                    wrapMode: Text.Wrap
                }
                Text { text: "signal · " + win.lastSignal; color: NovaTheme.primary; font.pixelSize: NovaTheme.fontXS; wrapMode: Text.Wrap }
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
            Text { text: "孵化内核在线  ·  三重校验就绪  ·  封版须经宿主一次显式确认"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            text: "NovaIncubator · 1.2.0 · " + (win.themeMode === "signature" ? "专属" : "亮色")
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
        }
        NovaSeparator { anchors { top: parent.top; left: parent.left; right: parent.right } }
    }
}
