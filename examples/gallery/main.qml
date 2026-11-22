// examples/gallery/main.qml
// pyside-nova 组件画廊：侧边导航 + 12 页面覆盖全部组件与服务，明暗一键切换、断点实时监控
// pyside-nova 组件画廊：左侧导航 + 右侧页面，覆盖全部已交付组件
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import Nova.Services
import Nova.Controls
import Nova.Behaviors

ApplicationWindow {
    id: window
    width: 1180
    height: 800
    visible: true
    title: "pyside-nova · 组件画廊 Gallery"
    color: NovaTheme.page

    // 断点体系接入 + 离线图标通道（main.py 注入 novaIconLocalRoot）
    Component.onCompleted: {
        NovaScreen.source = window
        if (typeof novaIconLocalRoot !== "undefined" && novaIconLocalRoot !== "")
            NovaTheme.iconLocalRoot = novaIconLocalRoot
    }

    // ── 顶部标题栏 ──────────────────────────────────────────────
    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 56
        color: NovaTheme.surface

        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingL }
            spacing: NovaTheme.spacingM

            Rectangle {
                width: 30; height: 30; radius: 9
                anchors.verticalCenter: parent.verticalCenter
                color: NovaTheme.primary
                Text {
                    anchors.centerIn: parent
                    text: "N"; color: NovaTheme.textOnPrimary
                    font.bold: true; font.pixelSize: 16
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "pyside-nova"
                color: NovaTheme.textColor
                font.pixelSize: NovaTheme.fontL
                font.bold: true
            }
            NovaChip {
                anchors.verticalCenter: parent.verticalCenter
                text: "Gallery 0.6.2"
                outlined: true; dense: true
            }
        }

        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: NovaTheme.spacingL }
            spacing: NovaTheme.spacingM

            NovaChip {
                anchors.verticalCenter: parent.verticalCenter
                text: "断点 " + NovaScreen.name + " · " + window.width + "px"
                outlined: true; dense: true
            }
            NovaBtn {
                anchors.verticalCenter: parent.verticalCenter
                icon: NovaTheme.isDark ? "☀" : "🌙"
                variant: "flat"
                onClicked: NovaTheme.toggleDark()
            }
        }
    }

    // ── 左侧导航 ────────────────────────────────────────────────
    Rectangle {
        id: sidebar
        anchors { top: header.bottom; left: parent.left; bottom: parent.bottom }
        width: 208
        color: NovaTheme.surface

        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.top }
            width: 1; color: NovaTheme.outline
        }

        Column {
            anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: NovaTheme.spacingM }
            spacing: 2

            Repeater {
                model:                     ListModel {
                    ListElement { label: "概览";               icon: "mdi:home-variant-outline" }
                    ListElement { label: "NovaLayout 布局";    icon: "mdi:view-dashboard-outline" }
                    ListElement { label: "NovaBtn 按钮";       icon: "mdi:gesture-tap" }
                    ListElement { label: "NovaCard 卡片";      icon: "mdi:card-outline" }
                    ListElement { label: "NovaChip 标签";      icon: "mdi:tag-outline" }
                    ListElement { label: "NovaAvatar 头像";    icon: "mdi:account-circle-outline" }
                    ListElement { label: "NovaBadge 徽标";     icon: "mdi:numeric-9-plus" }
                    ListElement { label: "NovaIcon 图标";      icon: "mdi:shape-outline" }
                    ListElement { label: "NovaNotify 通知";    icon: "mdi:bell-ring-outline" }
                    ListElement { label: "NovaDialog 对话框";  icon: "mdi:message-text-outline" }
                    ListElement { label: "Loading / Storage";  icon: "mdi:progress-clock" }
                    ListElement { label: "Theme / Screen";     icon: "mdi:palette-outline" }
                }

                delegate: Rectangle {
                    id: navItem
                    required property int index
                    required property string label
                    required property string icon

                    width: sidebar.width - 12
                    height: 38
                    radius: NovaTheme.radiusS
                    color: nav.currentIndex === index ? NovaTheme.primary : "transparent"
                    opacity: nav.currentIndex === index ? 1 : 0.8

                    Row {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: NovaTheme.spacingM }
                        spacing: NovaTheme.spacingM

                        NovaIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            icon: navItem.icon
                            size: 18
                            color: nav.currentIndex === navItem.index ? NovaTheme.textOnPrimary : NovaTheme.textMuted
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: navItem.label
                            color: nav.currentIndex === navItem.index ? NovaTheme.textOnPrimary : NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontS
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: nav.currentIndex = navItem.index
                    }
                }
            }
        }
    }

    // ── 右侧内容 ────────────────────────────────────────────────
    Loader {
        id: content
        anchors { top: header.bottom; left: sidebar.right; right: parent.right; bottom: parent.bottom }
        sourceComponent: [pageOverview, pageLayout, pageBtn, pageCard, pageChip,
                          pageAvatar, pageBadge, pageIcon, pageNotify, pageDialog,
                          pageServices, pageTheme][nav.currentIndex]
    }

    Rectangle { id: nav; property int currentIndex: 0; visible: false }

    // ════════════════════════════════════════════════════════════
    // 页面：NovaLayout 布局（6 种经典布局，全部可交互）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageLayout
        Item {
            GalleryPage {
                title: "NovaLayout 布局"
                desc: "布局五件套 + 栅格：NovaLayout 按子项类型自动归位（header/footer/drawer/page）；NovaDrawer 支持 mini 悬停展开、breakpoint 自动收起、push/overlay；NovaRow × NovaCol 12 栅格（offset/offset 推挤/wrap）；NovaVisible 断点显隐（跟随窗口断点，右上角实时显示）。"

                GalleryRow { label: "① 后台管理（mini 抽屉 · 点 ☰ 切换 push/overlay）" }
                LayoutPreview {
                    height: 220
                    NovaLayout {
                        id: adminLay
                        NovaHeader {
                            height: 30
                            Row {
                                anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                                spacing: 6
                                Text { text: "N"; color: NovaTheme.textOnPrimary; font.bold: true; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Nova 后台"; color: NovaTheme.textOnPrimary; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                            }
                            NovaBtn {
                                anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                                icon: "mdi:menu"; variant: "flat"; tint: Qt.rgba(1, 1, 1, 0.18)
                                onClicked: adminDrawer.overlay = !adminDrawer.overlay
                            }
                        }
                        NovaDrawer {
                            id: adminDrawer
                            mini: true; size: 110; miniWidth: 40; breakpoint: 420
                            Column {
                                spacing: 4
                                Repeater {
                                    model: ["mdi:home-outline", "mdi:chart-bar", "mdi:email-outline", "mdi:cog-outline"]
                                    delegate: NovaIcon {
                                        required property int index
                                        required property string modelData
                                        x: 8; y: index * 34 + 8
                                        icon: modelData; size: 22; color: NovaTheme.textMuted
                                    }
                                }
                            }
                        }
                        NovaFooter {
                            height: 24
                            Text { anchors.centerIn: parent; text: "NovaFooter"; color: NovaTheme.textOnPrimary; font.pixelSize: 11 }
                        }
                        NovaPage {
                            padding: 8
                            NovaRow {
                                anchors { left: parent.left; right: parent.right; top: parent.top }
                                NovaCol { cols: 4; gutter: 4; LayoutCard { } }
                                NovaCol { cols: 4; gutter: 4; LayoutCard { } }
                                NovaCol { cols: 4; gutter: 4; LayoutCard { } }
                            }
                        }
                    }
                }

                GalleryRow { label: "② 数据看板（12 栅格 cols 3/3/6 + 4/8）" }
                LayoutPreview {
                    height: 170
                    NovaPage {
                        padding: 8
                        NovaRow {
                            id: dashRow1
                            anchors { left: parent.left; right: parent.right; top: parent.top }
                            NovaCol { cols: 3; gutter: 4; LayoutCard { h: 52 } }
                            NovaCol { cols: 3; gutter: 4; LayoutCard { h: 52 } }
                            NovaCol { cols: 6; gutter: 4; LayoutCard { h: 52 } }
                        }
                        NovaRow {
                            anchors { left: parent.left; right: parent.right; top: dashRow1.bottom; topMargin: 8 }
                            NovaCol { cols: 4; gutter: 4; LayoutCard { h: 52 } }
                            NovaCol { cols: 8; gutter: 4; LayoutCard { h: 52 } }
                        }
                    }
                }

                GalleryRow { label: "③ 表单页（双列栅格 + offset）" }
                LayoutPreview {
                    height: 150
                    NovaPage {
                        padding: 8
                        NovaRow {
                            anchors { left: parent.left; right: parent.right; top: parent.top }
                            NovaCol { cols: 6; gutter: 4; LayoutField { label: "用户名" } }
                            NovaCol { cols: 6; gutter: 4; LayoutField { label: "邮箱" } }
                        }
                        NovaRow {
                            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 50 }
                            NovaCol { cols: 6; offset: 6; gutter: 4; LayoutField { label: "备注（offset 6 右移）" } }
                        }
                    }
                }

                GalleryRow { label: "④ 详情页（头图 4 栅格 + 内容 8 栅格）" }
                LayoutPreview {
                    height: 150
                    NovaPage {
                        padding: 8
                        NovaRow {
                            anchors { left: parent.left; right: parent.right; top: parent.top }
                            NovaCol { cols: 4; gutter: 4 }
                            NovaCol { cols: 8; gutter: 4 }
                            NovaCol { cols: 4; gutter: 4; LayoutCard { h: 100 } }
                            NovaCol { cols: 8; gutter: 4; LayoutLines { n: 5 } }
                        }
                    }
                }

                GalleryRow { label: "⑤ 登录页（justify center 居中卡片）" }
                LayoutPreview {
                    height: 180
                    NovaLayout {
                        NovaHeader { height: 26 }
                        NovaPage {
                            padding: 8
                            NovaRow {
                                anchors.fill: parent
                                justify: "center"; align: "center"
                                NovaCol {
                                    cols: 4
                                    Rectangle {
                                        width: parent.width; height: 96; radius: NovaTheme.radiusM
                                        color: NovaTheme.surface; border.color: NovaTheme.outline
                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 8
                                            Text { text: "登录 Nova"; color: NovaTheme.textColor; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                            Rectangle { width: 120; height: 22; radius: 4; color: NovaTheme.surfaceAlt; border.color: NovaTheme.outline; anchors.horizontalCenter: parent.horizontalCenter }
                                            NovaBtn { text: "登录"; anchors.horizontalCenter: parent.horizontalCenter }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                GalleryRow { label: "⑥ 空态 + NovaVisible 断点显隐（窗口断点：当前 " + NovaScreen.name + "）" }
                LayoutPreview {
                    height: 150
                    NovaPage {
                        padding: 8
                        NovaRow {
                            anchors.fill: parent
                            justify: "center"; align: "center"
                            NovaVisible {
                                width: 420; height: 60
                                above: "md"
                                Rectangle {
                                    width: 420; height: 60; radius: NovaTheme.radiusM
                                    color: NovaTheme.surface; border.color: NovaTheme.outline
                                    Column {
                                        anchors.centerIn: parent; spacing: 6
                                        NovaIcon { icon: "mdi:inbox-multiple-outline"; size: 26; color: NovaTheme.textMuted; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: "桌面端空态（above: 'md' 时显示）"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS; anchors.horizontalCenter: parent.horizontalCenter }
                                    }
                                }
                            }
                            NovaVisible {
                                width: 220; height: 60
                                below: "md"
                                Rectangle {
                                    width: 220; height: 60; radius: NovaTheme.radiusM
                                    color: NovaTheme.surface; border.color: NovaTheme.outline
                                    Text { anchors.centerIn: parent; text: "移动端空态（below: 'md'）"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：概览
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageOverview
        Item {
            GalleryPage {
                title: "概览 Overview"
                desc: "pyside-nova 已交付 21 个组件（含 NovaNotify 通知服务）全部实机展示。所有组件共享 NovaTheme 三级设计令牌，明暗主题一键切换。"

                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "filled" }
                    NovaBtn { text: "outlined"; variant: "outlined" }
                    NovaBtn { text: "flat"; variant: "flat" }
                    NovaBtn { icon: "mdi:magnify"; round: true; variant: "flat" }
                }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaChip { text: "PySide6"; filled: true }
                    NovaChip { text: "QML"; outlined: true }
                    NovaChip { text: "企业级"; selected: true }
                    NovaAvatar { text: "N" }
                    NovaAvatar { text: "Nova"; size: 36; square: true }
                }
                Row {
                    spacing: NovaTheme.spacingL
                    Rectangle {
                        width: 160; height: 72; radius: NovaTheme.radiusM
                        color: NovaTheme.primary
                        Text { anchors.centerIn: parent; text: "NovaRipple"; color: "#fff"; font.bold: true }
                        NovaRipple { }
                    }
                    Rectangle {
                        width: 160; height: 72; radius: NovaTheme.radiusM
                        color: NovaTheme.surfaceAlt
                        border.color: NovaTheme.outline
                        Text { anchors.centerIn: parent; text: "自定义波纹色"; color: NovaTheme.textMuted }
                        NovaRipple { color: Qt.rgba(NovaTheme.accent.r, NovaTheme.accent.g, NovaTheme.accent.b, 0.35) }
                    }
                    NovaBtn { icon: "🔔"; round: true; NovaBadge { text: "99+"; floating: true } }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：NovaBtn
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageBtn
        Item {
            GalleryPage {
                title: "NovaBtn 按钮"
                desc: "对标 QBtn：filled / outlined / flat 三种形态 × sm / md / lg 三种尺寸，内置水波纹、hover、loading、键盘触发。"

                GalleryRow { label: "形态 variant" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "filled" }
                    NovaBtn { text: "outlined"; variant: "outlined" }
                    NovaBtn { text: "flat"; variant: "flat" }
                    NovaBtn { text: "negative"; tint: NovaTheme.negative }
                    NovaBtn { text: "positive"; tint: NovaTheme.positive }
                }

                GalleryRow { label: "尺寸 size" }
                Row {
                    spacing: NovaTheme.spacingM
                    anchors.verticalCenter: undefined
                    NovaBtn { text: "sm"; size: "sm" }
                    NovaBtn { text: "md" }
                    NovaBtn { text: "lg"; size: "lg" }
                    NovaBtn { text: "dense" }
                }

                GalleryRow { label: "图标与圆形按钮" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { icon: "mdi:magnify"; text: "搜索" }
                    NovaBtn { icon: "mdi:plus"; round: true }
                    NovaBtn { icon: "mdi:delete-outline"; round: true; variant: "outlined"; tint: NovaTheme.negative }
                    NovaBtn { icon: "❤"; round: true; variant: "flat"; tint: NovaTheme.negative }
                }

                GalleryRow { label: "状态" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "loading…"; loading: true }
                    NovaBtn { text: "disabled"; disable: true }
                    NovaBtn { text: "点我计数 " + clickCount
                              onClicked: clickCount++ ; property int clickCount: 0 }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：NovaCard
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageCard
        Item {
            GalleryPage {
                title: "NovaCard 卡片"
                desc: "卡片三件套：NovaCard（容器）+ NovaCardSection（内容）+ NovaCardActions（操作区），MultiEffect 真实阴影。"

                Row {
                    spacing: NovaTheme.spacingL

                    NovaCard {
                        width: 280
                        NovaCardSection {
                            Text { text: "默认卡片"; font.bold: true; font.pixelSize: NovaTheme.fontL; color: NovaTheme.textColor }
                            Text { text: "elevated 模式，带 2 级高程阴影。padding 默认 spacingL。"; wrapMode: Text.WordWrap; width: parent.width; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                        }
                        NovaCardActions {
                            NovaBtn { text: "取消"; variant: "flat" }
                            NovaBtn { text: "确定" }
                        }
                    }

                    NovaCard {
                        width: 280
                        flat: true; bordered: true
                        NovaCardSection {
                            Text { text: "flat + bordered"; font.bold: true; font.pixelSize: NovaTheme.fontL; color: NovaTheme.textColor }
                            Text { text: "无边框阴影、仅描边的轻量卡片，适合列表容器。"; wrapMode: Text.WordWrap; width: parent.width; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                        }
                        NovaCardActions { align: "left"; NovaChip { text: "flat"; dense: true; outlined: true } }
                    }

                    NovaCard {
                        width: 280
                        elevation: 4
                        NovaCardSection {
                            Text { text: "高程 4"; font.bold: true; font.pixelSize: NovaTheme.fontL; color: NovaTheme.textColor }
                            Text { text: "elevation 属性 0~5 级，对应 NovaTheme.shadowColor 令牌。"; wrapMode: Text.WordWrap; width: parent.width; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：NovaChip
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageChip
        Item {
            GalleryPage {
                title: "NovaChip 标签"
                desc: "对标 QChip：filled / outlined / tinted、可选中、可移除、dense、可点击，事件 clicked / removed。"

                GalleryRow { label: "外观" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaChip { text: "filled"; filled: true }
                    NovaChip { text: "outlined"; outlined: true }
                    NovaChip { text: "tinted"; tint: NovaTheme.secondary }
                    NovaChip { text: "accent"; filled: true; tint: NovaTheme.accent }
                }

                GalleryRow { label: "可选中 / 可移除 / dense" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaChip { text: "可选中"; clickable: true; onClicked: selected = !selected }
                    NovaChip { text: "点击我移除"; removable: true; onRemoved: removedTip.visible = true }
                    NovaChip { text: "dense"; dense: true; filled: true }
                    Text {
                        id: removedTip
                        visible: false
                        text: "已触发 removed() ✓"
                        color: NovaTheme.positive; font.pixelSize: NovaTheme.fontS
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                GalleryRow { label: "状态" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaChip { text: "selected"; selected: true }
                    NovaChip { text: "disabled"; disable: true; filled: true }
                    NovaChip { icon: "mdi:react"; text: "带图标"; outlined: true }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：NovaAvatar
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageAvatar
        Item {
            GalleryPage {
                title: "NovaAvatar 头像"
                desc: "文字自动配色 / 图片 / square / 尺寸可调；textColor 与 tint 可覆盖。"

                GalleryRow { label: "文字头像（自动配色）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaAvatar { text: "A" }
                    NovaAvatar { text: "B" }
                    NovaAvatar { text: "C" }
                    NovaAvatar { text: "D" }
                    NovaAvatar { text: "Nova"; size: 40 }
                }

                GalleryRow { label: "方形 / 自定义色调" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaAvatar { text: "Q"; square: true; tint: NovaTheme.secondary }
                    NovaAvatar { text: "X"; square: true; size: 36; tint: NovaTheme.accent }
                    NovaAvatar { text: "Z"; size: 52 }
                }

                GalleryRow { label: "图片头像" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaAvatar {
                        size: 44
                        source: "https://cdn.jsdelivr.net/gh/qt/qtbase@dev/.github/workflows/logo.svg"
                    }
                    Text { text: "source 属性传任意 url 即可"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS; anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：NovaBadge / NovaRipple
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageBadge
        Item {
            GalleryPage {
                title: "NovaBadge 徽标 · NovaRipple 波纹"
                desc: "NovaBadge 作为子项挂载到任意 Item（红点 / 数值 / 浮动）；NovaRipple 提供按压水波纹行为。"

                GalleryRow { label: "NovaBadge 子项挂载" }
                Row {
                    spacing: NovaTheme.spacingL
                    NovaAvatar { text: "M"; NovaBadge { text: "3" } }
                    NovaBtn { icon: "🔔"; round: true; variant: "outlined"; NovaBadge { text: "99+"; floating: true } }
                    NovaBtn { icon: "💬"; round: true; variant: "flat"; NovaBadge { text: "" } }
                    NovaBtn { icon: "✉"; round: true; variant: "outlined"; tint: NovaTheme.secondary; NovaBadge { text: "12"; offsetX: -4 } }
                }

                GalleryRow { label: "NovaRipple 波纹行为" }
                Row {
                    spacing: NovaTheme.spacingL
                    Rectangle {
                        width: 180; height: 80; radius: NovaTheme.radiusM
                        color: NovaTheme.primary
                        Text { anchors.centerIn: parent; text: "默认波纹"; color: "#fff"; font.bold: true }
                        NovaRipple { }
                    }
                    Rectangle {
                        width: 180; height: 80; radius: NovaTheme.radiusM
                        color: NovaTheme.surfaceAlt; border.color: NovaTheme.outline
                        Text { anchors.centerIn: parent; text: "自定义色/时长"; color: NovaTheme.textMuted }
                        NovaRipple { color: Qt.rgba(NovaTheme.accent.r, NovaTheme.accent.g, NovaTheme.accent.b, 0.35); duration: 320 }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：NovaIcon
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageIcon
        Item {
            GalleryPage {
                title: "NovaIcon 图标"
                desc: "icon=\"mdi:home\" / \"material:favorite\" 式 API。优先本地图标包（NovaTheme.iconLocalRoot），缺失自动回落 jsdelivr 云端 CDN。"

                GalleryRow { label: "MDI 图标集（" + (NovaTheme.iconLocalRoot !== "" ? "本地通道已启用" : "云端 CDN") + "）" }
                Row {
                    spacing: NovaTheme.spacingL
                    NovaIcon { icon: "mdi:home"; size: 32 }
                    NovaIcon { icon: "mdi:magnify"; size: 32 }
                    NovaIcon { icon: "mdi:cog-outline"; size: 32 }
                    NovaIcon { icon: "mdi:bell-outline"; size: 32; color: NovaTheme.accent }
                    NovaIcon { icon: "mdi:delete-outline"; size: 32; color: NovaTheme.negative }
                    NovaIcon { icon: "mdi:check-circle"; size: 32; color: NovaTheme.positive }
                }

                GalleryRow { label: "Material 图标集" }
                Row {
                    spacing: NovaTheme.spacingL
                    NovaIcon { icon: "material:favorite"; size: 32; color: NovaTheme.negative }
                    NovaIcon { icon: "material:star"; size: 32; color: NovaTheme.warning }
                    NovaIcon { icon: "material:settings"; size: 32 }
                    NovaIcon { icon: "material:search"; size: 32; color: NovaTheme.primary }
                }

                GalleryRow { label: "尺寸与彩色模式" }
                Row {
                    spacing: NovaTheme.spacingL
                    NovaIcon { icon: "mdi:heart"; size: 16 }
                    NovaIcon { icon: "mdi:heart"; size: 24 }
                    NovaIcon { icon: "mdi:heart"; size: 32 }
                    NovaIcon { icon: "mdi:heart"; size: 48; color: NovaTheme.negative }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：NovaNotify 通知
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageNotify
        Item {
            id: np
            property string lastReason: ""
            property var taskHandle: null

            // 统一入口：接管 dismissed(reason) 用于页面内实时展示关闭原因
            function notify(cfg) {
                var h = NovaNotify.show(cfg)
                if (h && h.item)
                    h.item.dismissed.connect(function(r) { np.lastReason = r })
                return h
            }

            GalleryPage {
                title: "NovaNotify 通知"
                desc: "对标 Notify 插件：命令式 show()（对标 Notify.create）、9 位定位、分组徽标（badge 计数）、动作按钮、超时进度条、dismissed(reason) 关闭原因上报（Nova 增强，基线 onDismiss 无参数）。通知悬浮于窗口顶层，点按钮触发。"

                GalleryRow { label: "内置类型（type 预设，对标 notifTypes）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "positive"; tint: NovaTheme.positive
                              onClicked: np.notify({ type: "positive", message: "保存成功", caption: "文档已写入本地" }) }
                    NovaBtn { text: "negative"; tint: NovaTheme.negative
                              onClicked: np.notify({ type: "negative", message: "删除失败", caption: "文件被其他程序占用" }) }
                    NovaBtn { text: "warning"
                              onClicked: np.notify({ type: "warning", message: "磁盘剩余空间不足 10%" }) }
                    NovaBtn { text: "info"
                              onClicked: np.notify({ type: "info", message: "新版本 0.6.0 已发布" }) }
                    NovaBtn { text: "closeBtn"
                              onClicked: np.notify({ message: "常驻通知（timeout: 0）", closeBtn: true, timeout: 0 }) }
                }

                GalleryRow { label: "9 位定位（top 头插 / bottom 尾插 / 侧向中线插入）" }
                Flow {
                    width: parent.width
                    spacing: NovaTheme.spacingS
                    Repeater {
                        model: ["top-left", "top-right", "bottom-left", "bottom-right", "top", "bottom", "left", "right", "center"]
                        delegate: NovaBtn {
                            required property string modelData
                            text: modelData
                            variant: "flat"
                            size: "sm"
                            onClicked: np.notify({ message: "position: " + modelData, position: modelData, timeout: 1500 })
                        }
                    }
                }

                GalleryRow { label: "动作按钮与关闭原因（triggered 先行 → dismissed 后至）" }
                Column {
                    spacing: NovaTheme.spacingS
                    Row {
                        spacing: NovaTheme.spacingM
                        NovaBtn { text: "可撤销删除"
                                  onClicked: np.notify({ message: "已删除 1 个文件", caption: "本次操作可撤销",
                                                         actions: [{ label: "撤销", handler: function() {
                                                                        np.notify({ type: "info", message: "已恢复" }) } }] }) }
                        NovaBtn { text: "不关闭动作（noDismiss）"; variant: "outlined"
                                  onClicked: np.notify({ message: "点「看看」我不会关闭",
                                                         actions: [{ label: "看看", noDismiss: true, handler: function() {
                                                                        np.notify({ type: "info", message: "看过了" }) } }] }) }
                        NovaBtn { text: "超时进度条"
                                  onClicked: np.notify({ message: "5 秒后自动消失", progress: true, timeout: 5000 }) }
                    }
                    NovaChip {
                        text: "最近关闭原因 dismissed(reason): " + (np.lastReason === "" ? "（尚无）" : np.lastReason)
                        filled: np.lastReason !== ""
                        tint: np.lastReason === "" ? NovaTheme.textMuted : NovaTheme.primary
                        dense: true
                    }
                }

                GalleryRow { label: "分组与徽标（同键合并 + badge 递增；自定义组后到者替换前者）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "同消息连发 ×2"
                              onClicked: {
                                  np.notify({ message: "同一事件", caption: "分组键相同会合并并计徽标" })
                                  np.notify({ message: "同一事件", caption: "分组键相同会合并并计徽标" })
                              } }
                    NovaBtn { text: "自定义组 upload 连发 ×3"; variant: "outlined"
                              onClicked: {
                                  for (var i = 1; i <= 3; i++)
                                      np.notify({ message: "上传分片 " + i + "/3", group: "upload" })
                              } }
                    NovaBtn { text: "group: false 并发 ×2"; variant: "flat"
                              onClicked: {
                                  np.notify({ message: "任务 A", group: false, timeout: 3000 })
                                  np.notify({ message: "任务 B", group: false, timeout: 3000 })
                              } }
                }

                GalleryRow { label: "句柄 handle：dismiss() / update(props)（仅非分组可更新）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: np.taskHandle ? "同步进度 +10%" : "开始同步（ongoing）"
                              onClicked: {
                                  if (!np.taskHandle) {
                                      np.taskHandle = np.notify({ type: "ongoing", message: "正在同步… 0%", position: "top-right" })
                                  } else {
                                      var runs = np.taskHandle.item.message.match(/\d+/)
                                      var pct = Math.min(100, (runs ? parseInt(runs[0]) : 0) + 10)
                                      np.taskHandle.update({ message: "正在同步… " + pct + "%" })
                                      if (pct >= 100) {
                                          np.taskHandle.dismiss()
                                          np.taskHandle = null
                                      }
                                  }
                              } }
                    NovaBtn { text: "清空全部"; variant: "outlined"; tint: NovaTheme.negative
                              onClicked: NovaNotify.dismissAll("bottom") }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：NovaDialog 对话框
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageDialog
        Item {
            id: dp
            property string lastReason: "—"
            property var taskHandle: null

            // 进度对话框演示：2 秒后句柄 update 收尾并关闭
            Timer {
                id: progressTimer
                interval: 2000
                onTriggered: {
                    if (!dp.taskHandle)
                        return
                    dp.taskHandle.update({ title: "导入完成", message: "1,240 条记录已写入。", progress: false })
                    dp.taskHandle.ok()
                    dp.taskHandle = null
                }
            }

            function openDlg(cfg) {
                var h = NovaDialog.show(cfg)
                if (h)
                    h.dismissed.connect(function(r) { dp.lastReason = r })
                return h
            }

            GalleryPage {
                title: "NovaDialog 对话框"
                desc: "对标 Dialog 插件（27 项配置对账）：命令式 show() → 句柄（hide/update/ok/cancel + 三信号），五向定位、OK/Cancel 三态、persistent 锁外点与 ESC、seamless、fullWidth/maximized、进度态。dismissed(reason) 五值 ok/cancel/backdrop/escape/api 属基线 2.28 真 parity。"

                GalleryRow { label: "基础用法（关闭原因实时显示）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "标准确认框"
                              onClicked: dp.openDlg({ title: "继续?", message: "确定要执行该操作吗？此操作不可撤销。" }) }
                    NovaBtn { text: "危险确认"; tint: NovaTheme.negative
                              onClicked: dp.openDlg({ title: "删除 3 个文件?", message: "删除后无法恢复。",
                                                        ok: { label: "删除", tint: "#EF4444" },
                                                        cancel: "取消" }) }
                    NovaBtn { text: "仅确定（无取消）"; variant: "outlined"
                              onClicked: dp.openDlg({ title: "提示", message: "系统已更新到最新版本。", cancel: false }) }
                    NovaChip { text: "上次关闭原因: " + dp.lastReason; filled: true; tint: NovaTheme.primary }
                }

                GalleryRow { label: "行为开关（persistent / seamless / 全宽 / 最大化）" }
                Flow {
                    width: parent.width
                    spacing: NovaTheme.spacingS
                    NovaBtn { text: "persistent 常驻"; size: "sm"; variant: "flat"
                              onClicked: dp.openDlg({ title: "必须处理", message: "点遮罩或按 ESC 都不会关闭，只能点按钮。", persistent: true }) }
                    NovaBtn { text: "seamless 无遮罩"; size: "sm"; variant: "flat"
                              onClicked: dp.openDlg({ title: "无缝模式", message: "背景可继续操作，无遮罩层。", seamless: true }) }
                    NovaBtn { text: "fullWidth 全宽"; size: "sm"; variant: "flat"
                              onClicked: dp.openDlg({ title: "全宽对话框", message: "卡片宽度贴近窗口，左右各留 24px。", fullWidth: true }) }
                    NovaBtn { text: "maximized 最大化"; size: "sm"; variant: "flat"
                              onClicked: dp.openDlg({ title: "最大化", message: "铺满整个窗口。", maximized: true }) }
                }

                GalleryRow { label: "五向定位（position）" }
                Flow {
                    width: parent.width
                    spacing: NovaTheme.spacingS
                    Repeater {
                        model: ["standard", "top", "right", "bottom", "left"]
                        delegate: NovaBtn {
                            required property string modelData
                            text: modelData; size: "sm"; variant: "flat"
                            onClicked: dp.openDlg({ title: "position: " + modelData, message: "对话框按指定方位落位。", position: modelData })
                        }
                    }
                }

                GalleryRow { label: "进度态 + 句柄 update（2 秒后自动更新并关闭）" }
                NovaBtn { text: "处理中对话框"
                          onClicked: {
                              dp.taskHandle = dp.openDlg({ title: "正在导入", message: "请稍候，正在写入 1,240 条记录…",
                                                           progress: { message: "26%" }, cancel: false, persistent: true })
                              progressTimer.restart()
                          } }

                GalleryRow { label: "自定义内容（contentDelegate 替代基线 html）" }
                NovaBtn { text: "带输入框的对话框"
                          onClicked: dp.openDlg({
                              title: "重命名",
                              message: "请输入新的名称：",
                              contentDelegate: inputComp,
                              ok: "保存"
                          }) }
            }

            Component {
                id: inputComp
                TextField {
                    width: parent ? parent.width : 320
                    placeholderText: "新名称"
                    font.pixelSize: NovaTheme.fontS
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：L4 服务（NovaLoading / NovaStorage / NovaApp / NovaPlatform）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageServices
        Item {
            id: svc

            property var autoHandle: null
            property var refA: null
            property var refB: null
            property int demoCount: 0
            property string storeDump: ""
            property string appState: "窗口"
            property string localMsg: ""

            function autoLoading() {
                svc.autoHandle = NovaLoading.show({ delay: 0, message: "正在写入 1,240 条记录…" })
                autoTimer.restart()
            }

            function addRef() {
                var n = NovaLoading.count("demo") + 1
                var h = NovaLoading.show({ delay: 0, group: "demo", message: "并发任务 " + n + " / 3" })
                if (n === 1)
                    svc.refA = h
                else
                    svc.refB = h
                svc.demoCount = NovaLoading.count("demo")
            }

            function dropRef() {
                if (svc.refB) {
                    svc.refB.hide()
                    svc.refB = null
                } else if (svc.refA) {
                    svc.refA.hide()
                    svc.refA = null
                }
                svc.demoCount = NovaLoading.count("demo")
            }

            function localLoading() {
                var h = NovaLoading.show({ delay: 0, target: localBox,
                                           message: "局部加载中…", spinnerSize: 36 })
                svc.localMsg = "已挂到框内"
                localTimer.handle = h
                localTimer.restart()
            }

            function saveValue() {
                NovaStorage.useNamespace("gallery-demo")
                NovaStorage.set(storeKey.text.length > 0 ? storeKey.text : "greeting", storeValue.text)
                svc.storeDump = JSON.stringify(NovaStorage.getAll())
            }

            function clearStore() {
                NovaStorage.useNamespace("gallery-demo")
                NovaStorage.clear()
                svc.storeDump = "（空）"
            }

            function refreshApp() {
                svc.appState = NovaApp.isFullscreen ? "全屏"
                             : NovaApp.isMaximized ? "最大化" : "窗口"
            }

            // 自动收口 / 局部加载收口 / 状态刷新 三个轻量计时器
            Timer {
                id: autoTimer
                interval: 1600
                onTriggered: {
                    if (svc.autoHandle) {
                        svc.autoHandle.hide()
                        svc.autoHandle = null
                    }
                }
            }

            Timer {
                id: localTimer
                property var handle: null
                interval: 1600
                onTriggered: {
                    if (handle) {
                        handle.hide()
                        handle = null
                    }
                }
            }

            Timer {
                interval: 300
                running: true
                repeat: true
                onTriggered: svc.refreshApp()
            }

            GalleryPage {
                title: "L4 服务 · Loading / Storage / App / Platform"
                desc: "0.6.2 一次交付四件服务：NovaLoading（11 项对账 + 引用计数/局部加载/超时保护）、NovaStorage（LocalStorage API + 命名空间 + 真落盘 ini）、NovaApp（全屏/最大化/标题）、NovaPlatform（系统与触摸能力探测）。"

                GalleryRow { label: "NovaLoading · 全屏加载（1.6 秒自动收口）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "显示加载"; icon: "mdi:loading"; onClicked: svc.autoLoading() }
                    NovaChip {
                        text: "active: " + NovaLoading.activeCount()
                        outlined: true; dense: true
                    }
                }

                GalleryRow { label: "NovaLoading · 引用计数（同组并发，归零才真正关闭）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "引用 +1"; size: "sm"; variant: "outlined"; onClicked: svc.addRef() }
                    NovaBtn { text: "释放 -1"; size: "sm"; variant: "outlined"; onClicked: svc.dropRef() }
                    NovaChip { text: "demo 组引用: " + svc.demoCount; filled: true; tint: NovaTheme.primary; dense: true }
                }

                GalleryRow { label: "NovaLoading · 局部加载（target = 下方框体）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "框内加载"; size: "sm"; variant: "flat"; onClicked: svc.localLoading() }
                    NovaChip { text: svc.localMsg === "" ? "遮罩只覆盖目标区域" : svc.localMsg; outlined: true; dense: true }
                }
                Rectangle {
                    id: localBox
                    width: parent ? parent.width : 400
                    height: 110
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surfaceAlt
                    border.color: NovaTheme.outline
                    Text {
                        anchors.centerIn: parent
                        text: "局部容器（NovaLoading target 指向我）"
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                    }
                }

                GalleryRow { label: "NovaLoading · spinner 变体" }
                Flow {
                    width: parent.width
                    spacing: NovaTheme.spacingS
                    Repeater {
                        model: ["ring", "dots", "pulse"]
                        delegate: NovaBtn {
                            required property string modelData
                            text: modelData
                            size: "sm"
                            variant: "flat"
                            onClicked: {
                                var h = NovaLoading.show({ delay: 0, spinnerModel: modelData,
                                                           message: "spinnerModel: " + modelData })
                                svc.autoHandle = h
                                autoTimer.restart()
                            }
                        }
                    }
                }

                GalleryRow { label: "NovaStorage · 命名空间 gallery-demo（真落盘，重启仍在）" }
                Row {
                    spacing: NovaTheme.spacingM
                    Rectangle {
                        width: 150; height: 34; radius: NovaTheme.radiusS
                        color: NovaTheme.surface; border.color: NovaTheme.outline
                        TextInput {
                            id: storeKey
                            anchors.fill: parent
                            anchors.margins: 8
                            text: "greeting"
                            color: NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontS
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }
                    Rectangle {
                        width: 220; height: 34; radius: NovaTheme.radiusS
                        color: NovaTheme.surface; border.color: NovaTheme.outline
                        TextInput {
                            id: storeValue
                            anchors.fill: parent
                            anchors.margins: 8
                            text: "你好，青铜峡"
                            color: NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontS
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }
                    NovaBtn { text: "写入"; size: "sm"; onClicked: svc.saveValue() }
                    NovaBtn { text: "清空"; size: "sm"; variant: "outlined"; onClicked: svc.clearStore() }
                }
                Text {
                    width: parent ? parent.width : 400
                    text: svc.storeDump === "" ? "（点写入后显示 getAll() 快照）" : svc.storeDump
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                    font.family: "Consolas"
                    wrapMode: Text.WrapAnywhere
                }

                GalleryRow { label: "NovaApp · 窗口控制" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "全屏"; size: "sm"; variant: "flat"; onClicked: NovaApp.request() }
                    NovaBtn { text: "最大化"; size: "sm"; variant: "flat"; onClicked: NovaApp.setVisibility("maximized") }
                    NovaBtn { text: "还原窗口"; size: "sm"; variant: "flat"; onClicked: NovaApp.setVisibility("windowed") }
                    NovaChip { text: "当前: " + svc.appState; filled: true; tint: NovaTheme.secondary; dense: true }
                }

                GalleryRow { label: "NovaPlatform · 运行环境" }
                Flow {
                    width: parent.width
                    spacing: NovaTheme.spacingS
                    NovaChip { text: NovaPlatform.describe(); filled: true; dense: true }
                    NovaChip { text: "isDesktop: " + NovaPlatform.isDesktop; outlined: true; dense: true }
                    NovaChip { text: "hasTouch: " + NovaPlatform.hasTouch; outlined: true; dense: true }
                    NovaChip { text: "isWindows: " + NovaPlatform.isWindows; outlined: true; dense: true }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：Theme / Screen
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageTheme
        Item {
            GalleryPage {
                title: "NovaTheme 令牌 · NovaScreen 断点"
                desc: "NovaTheme 提供品牌/语义/表面色、几何、字阶、阴影三级令牌；NovaScreen 对标 Quasar Screen 插件（xs/sm/md/lg/xl + lt/gt）。"

                GalleryRow { label: "明暗主题切换（右上角 🌙/☀）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn { text: "toggleDark()"; icon: "mdi:theme-light-dark"; onClicked: NovaTheme.toggleDark() }
                    NovaChip { text: NovaTheme.isDark ? "Dark 模式" : "Light 模式"; filled: true; tint: NovaTheme.primary }
                }

                GalleryRow { label: "表面色令牌" }
                Row {
                    spacing: NovaTheme.spacingM
                    Repeater {
                        model: [
                            { n: "page", c: NovaTheme.page },
                            { n: "surface", c: NovaTheme.surface },
                            { n: "surfaceAlt", c: NovaTheme.surfaceAlt },
                            { n: "outline", c: NovaTheme.outline },
                            { n: "textColor", c: NovaTheme.textColor },
                            { n: "textMuted", c: NovaTheme.textMuted }
                        ]
                        delegate: Column {
                            spacing: 4
                            required property var modelData
                            Rectangle {
                                width: 88; height: 56; radius: NovaTheme.radiusS
                                color: modelData.c; border.color: NovaTheme.outline
                            }
                            Text { text: modelData.n; font.pixelSize: NovaTheme.fontXS; color: NovaTheme.textMuted; width: 88; horizontalAlignment: Text.AlignHCenter }
                        }
                    }
                }

                GalleryRow { label: "品牌色 / 语义色" }
                Row {
                    spacing: NovaTheme.spacingM
                    Repeater {
                        model: [
                            { n: "primary", c: NovaTheme.primary },
                            { n: "secondary", c: NovaTheme.secondary },
                            { n: "accent", c: NovaTheme.accent },
                            { n: "positive", c: NovaTheme.positive },
                            { n: "negative", c: NovaTheme.negative },
                            { n: "warning", c: NovaTheme.warning },
                            { n: "info", c: NovaTheme.info }
                        ]
                        delegate: Column {
                            spacing: 4
                            required property var modelData
                            Rectangle {
                                width: 76; height: 56; radius: NovaTheme.radiusS
                                color: modelData.c
                            }
                            Text { text: modelData.n; font.pixelSize: NovaTheme.fontXS; color: NovaTheme.textMuted; width: 76; horizontalAlignment: Text.AlignHCenter }
                        }
                    }
                }

                GalleryRow { label: "NovaScreen 断点（拖拽窗口宽度实时变化）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaChip { text: "name: " + NovaScreen.name; filled: true }
                    NovaChip { text: "isMobile: " + NovaScreen.isMobile; outlined: true }
                    NovaChip { text: "ltMd: " + NovaScreen.ltMd; outlined: true }
                    NovaChip { text: "gtSm: " + NovaScreen.gtSm; outlined: true }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 画廊复用构件
    // ════════════════════════════════════════════════════════════
    component GalleryPage: Item {
        id: gp
        property string title: ""
        property string desc: ""
        default property alias demos: body.data

        anchors.fill: parent

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: body.implicitHeight + NovaTheme.spacingL * 2
            clip: true

            ScrollBar.vertical: ScrollBar { }

            Column {
                id: body
                x: NovaTheme.spacingL
                y: NovaTheme.spacingL
                width: flick.width - NovaTheme.spacingL * 2
                spacing: NovaTheme.spacingM

                Text {
                    text: gp.title
                    color: NovaTheme.textColor
                    font.pixelSize: NovaTheme.fontXL
                    font.bold: true
                }
                Text {
                    text: gp.desc
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontS
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                Item { width: 1; height: NovaTheme.spacingM }
            }
        }
    }

    component GalleryRow: Text {
        color: NovaTheme.textMuted
        font.pixelSize: NovaTheme.fontXS
        font.letterSpacing: 1.2
        text: label.toUpperCase()
        topPadding: NovaTheme.spacingL
        property string label: ""
    }

    // 布局页预览框：固定高度的迷你画布，内部嵌真实 NovaLayout
    component LayoutPreview: Rectangle {
        id: lp
        default property alias content: slot.data
        width: parent ? parent.width : 0
        height: 200
        radius: NovaTheme.radiusM
        color: NovaTheme.surfaceAlt
        border.color: NovaTheme.outline
        clip: true

        Text {
            x: 8; y: 4
            text: "迷你预览（内部为真实组件，非截图）"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontXS
            opacity: 0.6
        }

        Item {
            id: slot
            anchors { fill: parent; topMargin: 20; leftMargin: 8; rightMargin: 8; bottomMargin: 8 }
        }
    }

    component LayoutCard: Rectangle {
        width: parent ? parent.width : 100
        height: h
        radius: NovaTheme.radiusS
        color: NovaTheme.surface
        border.color: NovaTheme.outline
        property int h: 60
        Text { anchors.centerIn: parent; text: "NovaCol"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
    }

    component LayoutField: Column {
        property string label: ""
        spacing: 4
        Text { text: label; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
        Rectangle {
            width: parent ? parent.width : 100; height: 24
            radius: NovaTheme.radiusS
            color: NovaTheme.surface
            border.color: NovaTheme.outline
            Text { x: 6; anchors.verticalCenter: parent.verticalCenter; text: "输入…"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; opacity: 0.6 }
        }
    }

    component LayoutLines: Column {
        property int n: 3
        spacing: 6
        Repeater {
            model: n
            Rectangle {
                required property int index
                width: parent ? parent.width * (index === 0 ? 0.6 : 1) : 100
                height: 8
                radius: 3
                color: NovaTheme.surfaceAlt
                border.color: NovaTheme.outline
            }
        }
    }
}
