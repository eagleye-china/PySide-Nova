// examples/gallery/main.qml
// pyside-nova 组件画廊：侧边导航 + 23 页面覆盖组件/服务/行为/设计语言/工具层五层，明暗一键切换、断点实时监控
// pyside-nova 组件画廊：左侧导航 + 右侧页面，覆盖全部已交付组件
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import Nova.Services
import Nova.Controls
import Nova.Behaviors
import Nova.Design

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
                text: "Gallery 0.14.0"
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
                    ListElement { label: "L3 行为指令";        icon: "mdi:gesture-swipe" }
                    ListElement { label: "Theme / Screen";     icon: "mdi:palette-outline" }
                    ListElement { label: "L0 图标/排版/动效";   icon: "mdi:shape-plus-outline" }
                    ListElement { label: "L5 工具层 utils";     icon: "mdi:function-variant" }
                    ListElement { label: "表单核心";            icon: "mdi:form-textbox" }
                    ListElement { label: "输入进阶";            icon: "mdi:clock-time-eight-outline" }
                    ListElement { label: "数据体系";            icon: "mdi:table-large" }
                    ListElement { label: "媒体体系";            icon: "mdi:image-multiple-outline" }
                    ListElement { label: "导航体系";            icon: "mdi:compass-outline" }
                    ListElement { label: "弹层与反馈";          icon: "mdi:layers-triple-outline" }
                    ListElement { label: "长尾组件";            icon: "mdi:alpha-t-circle-outline" }
                    ListElement { label: "无障碍 a11y";          icon: "mdi:human-wheelchair" }
                    ListElement { label: "国际化 i18n";          icon: "mdi:translate" }
                    ListElement { label: "NovaMarkdown 文档";    icon: "mdi:file-document-outline" }
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
                          pageServices, pageBehaviors, pageTheme,
                          pageDesign, pageUtils, pageForms, pageForm2, pageData, pageMedia, pageNav, pagePopup, pageLongtail, pageA11y, pageI18n, pageMarkdown][nav.currentIndex]
    }

    Rectangle { id: nav; objectName: "nav"; property int currentIndex: 0; visible: false }

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
                desc: "pyside-nova 已交付 120 个公共类型（Controls 91 + Services 15 + Design 3 + Behaviors 11）全部实机展示。所有组件共享 NovaTheme 三级设计令牌，明暗主题一键切换。"

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
    // 页面：L3 行为（九个指令行为，v0.7.0）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageBehaviors
        Item {
            id: behPage

            property int interEnters: 0
            property int interExits: 0
            property real interRatio: -1
            property int fires: 0
            property string scrollInfo: "还没滚动"
            property string panInfo: "试着在绿框里拖动"
            property string swipeInfo: "试着左右快速划一下"
            property int holdCount: 0
            property int repCount: 0
            property bool holdActive: false
            property real dragX: 16
            property int closeCount: 0

            function resetAll() {
                behPage.interEnters = 0
                behPage.interExits = 0
                behPage.fires = 0
                behPage.holdCount = 0
                behPage.repCount = 0
                behPage.closeCount = 0
                behPage.panInfo = "试着在绿框里拖动"
                behPage.swipeInfo = "试着左右快速划一下"
            }

            GalleryPage {
                title: "L3 行为 · 指令九件（Ripple / Intersection / Scroll / ClosePopup / Touch×4）"
                desc: "0.7.0 一次收口行为层：NovaIntersection（共享观察池 + 祖先裁剪 + once 再武装）、"
                      + "NovaScrollObserver / NovaScrollFire（首入视口触发一次）、NovaClosePopup（弹层栈按层关闭）、"
                      + "NovaTouchPan / Swipe / Hold / Repeat（方向阈值 + 长按 + 连发）。所有演示均为真实行为组件，不是截图。"

                GalleryRow { label: "NovaIntersection + NovaScrollFire · 懒加载（滚动下方框体，方块变亮＝已触发）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaChip { text: "ratio " + (behPage.interRatio < 0 ? "—" : behPage.interRatio.toFixed(2)); filled: true; dense: true; tint: NovaTheme.primary }
                    NovaChip { text: "进入 " + behPage.interEnters; outlined: true; dense: true }
                    NovaChip { text: "离开 " + behPage.interExits; outlined: true; dense: true }
                    NovaChip { text: "scroll-fire " + behPage.fires; outlined: true; dense: true }
                    NovaBtn { text: "清零"; size: "sm"; variant: "flat"; onClicked: behPage.resetAll() }
                }

                Rectangle {
                    width: parent ? parent.width : 400
                    height: 170
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surfaceAlt
                    border.color: NovaTheme.outline
                    clip: true

                    Flickable {
                        id: lazyFlick
                        anchors.fill: parent
                        anchors.margins: 6
                        contentWidth: width
                        contentHeight: 520
                        clip: true

                        Column {
                            spacing: 10

                            Repeater {
                                model: 3
                                delegate: Rectangle {
                                    id: lazyBox
                                    required property int index
                                    width: lazyFlick.width
                                    height: 120
                                    radius: NovaTheme.radiusS
                                    color: lazyBox.loaded ? NovaTheme.primary : NovaTheme.surface
                                    border.color: NovaTheme.outline

                                    property bool loaded: false
                                    property real ratio: 0

                                    Text {
                                        anchors.centerIn: parent
                                        text: lazyBox.loaded
                                              ? "第 " + (lazyBox.index + 1) + " 块 · 已触发加载"
                                              : "第 " + (lazyBox.index + 1) + " 块 · 等待进入视口"
                                        color: lazyBox.loaded ? "#FFFFFF" : NovaTheme.textMuted
                                        font.pixelSize: NovaTheme.fontS
                                    }

                                    NovaScrollFire {
                                        threshold: 0.35
                                        onFire: (item) => {
                                            item.loaded = true
                                            behPage.fires++
                                        }
                                    }

                                    NovaIntersection {
                                        threshold: [0, 0.5, 1]
                                        onIntersect: (entry) => {
                                            lazyBox.ratio = entry.intersectionRatio
                                            if (lazyBox.index === 0)
                                                behPage.interRatio = entry.intersectionRatio
                                        }
                                        onEntered: (entry) => {
                                            if (lazyBox.index === 0) behPage.interEnters++
                                        }
                                        onExited: (entry) => {
                                            if (lazyBox.index === 0) behPage.interExits++
                                        }
                                    }
                                }
                            }
                        }

                        NovaScrollObserver {
                            onScroll: (d) => behPage.scrollInfo = "y=" + Math.round(d.vertical)
                                             + (d.atBottom ? " · 到底了" : (d.atTop ? " · 顶部" : ""))
                        }
                    }
                }

                Row {
                    spacing: NovaTheme.spacingM
                    NovaChip { text: "滚动位置：" + behPage.scrollInfo; outlined: true; dense: true }
                    NovaBtn {
                        text: "回顶"; size: "sm"; variant: "flat"
                        onClicked: lazyFlick.contentY = 0
                    }
                }

                GalleryRow { label: "NovaTouchPan · 拖动（松手回弹，x 限制在框内）" }
                Rectangle {
                    width: parent ? parent.width : 400
                    height: 110
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surfaceAlt
                    border.color: NovaTheme.outline

                    Rectangle {
                        id: dragDot
                        x: behPage.dragX
                        anchors.verticalCenter: parent.verticalCenter
                        width: 92; height: 62
                        radius: NovaTheme.radiusM
                        color: NovaTheme.secondary

                        Text {
                            anchors.centerIn: parent
                            text: "拖我"
                            color: "#FFFFFF"
                            font.pixelSize: NovaTheme.fontS
                        }

                        NovaTouchPan {
                            horizontal: true
                            onPan: (d) => {
                                if (d.isFirst)
                                    behPage.panInfo = "拖动中 → " + d.direction
                                if (!d.isFinal) {
                                    var nx = dragDot.x + d.delta.x
                                    var maxX = dragDot.parent.width - dragDot.width - 8
                                    dragDot.x = Math.max(8, Math.min(maxX, nx))
                                } else {
                                    behPage.panInfo = "松手：" + d.direction + " · " + Math.round(d.distance.x) + "px"
                                }
                            }
                        }
                    }
                }
                NovaChip { text: behPage.panInfo; outlined: true; dense: true }

                GalleryRow { label: "NovaTouchSwipe · 快速划动（阈值 0.06 px/ms）" }
                Rectangle {
                    width: parent ? parent.width : 400
                    height: 90
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surfaceAlt
                    border.color: NovaTheme.outline

                    Text {
                        anchors.centerIn: parent
                        text: "← 左滑 / 右滑 / 上滑 / 下滑 →"
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontS
                    }

                    NovaTouchSwipe {
                        onSwipe: (d) => behPage.swipeInfo = "命中 " + d.direction
                                           + " · v=" + d.velocity.toFixed(2)
                                           + " px/ms · " + Math.round(Math.max(d.distance.x, d.distance.y)) + "px"
                    }
                }
                NovaChip { text: behPage.swipeInfo; outlined: true; dense: true }

                GalleryRow { label: "NovaTouchHold · 长按 600ms（位移超灵敏度即取消）" }
                Row {
                    spacing: NovaTheme.spacingM
                    Rectangle {
                        width: 180; height: 76
                        radius: NovaTheme.radiusM
                        color: bahHold.pressed ? NovaTheme.primary : NovaTheme.surfaceAlt
                        border.color: NovaTheme.outline

                        Text {
                            anchors.centerIn: parent
                            text: "按住我不放"
                            color: bahHold.pressed ? "#FFFFFF" : NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontS
                        }

                        NovaTouchHold {
                            id: bahHold
                            duration: 600
                            onHold: (d) => { behPage.holdCount++; behPage.holdActive = true }
                            onCancel: behPage.holdActive = false
                        }
                    }
                    NovaChip { text: "长按命中 " + behPage.holdCount + " 次"; filled: true; dense: true; tint: NovaTheme.primary }
                    NovaChip { text: behPage.holdActive ? "已触发" : "待命"; outlined: true; dense: true }
                }

                GalleryRow { label: "NovaTouchRepeat · 按住连发（0 → 400 → 每 200ms）" }
                Row {
                    spacing: NovaTheme.spacingM
                    Rectangle {
                        width: 140; height: 76
                        radius: NovaTheme.radiusM
                        color: bahRep.repeating ? NovaTheme.accent : NovaTheme.surfaceAlt
                        border.color: NovaTheme.outline

                        Text {
                            anchors.centerIn: parent
                            text: "按住连发"
                            color: bahRep.repeating ? "#FFFFFF" : NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontS
                        }

                        NovaTouchRepeat {
                            id: bahRep
                            delays: "0:400:200"
                            onRepeat: (d) => behPage.repCount = d.repeatCount
                        }
                    }
                    NovaChip { text: "已发 " + behPage.repCount + " 次"; filled: true; dense: true; tint: NovaTheme.accent }
                }

                GalleryRow { label: "NovaClosePopup · 弹层栈按层关闭（打开两个对话框试试）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaBtn {
                        text: "打开两层"; size: "sm"
                        onClicked: {
                            NovaDialog.show({ title: "第一层", message: "点下面的按钮关我" })
                            NovaDialog.show({ title: "第二层", message: "点一次关一层，点「全关」清空" })
                        }
                    }
                    NovaBtn {
                        text: "全关"; size: "sm"; variant: "outlined"
                        onClicked: NovaOverlayHost.closePopups(-1, "api")
                    }
                    NovaChip { text: "栈内 " + NovaOverlayHost.popupCount() + " 层"; outlined: true; dense: true }
                }

                GalleryRow { label: "NovaClosePopup · 在对话框内容里放关闭按钮（真实链路）" }
                NovaBtn {
                    text: "打开带关闭按钮的对话框"; size: "sm"; variant: "flat"
                    onClicked: NovaDialog.show({
                        title: "ClosePopup 实测",
                        contentDelegate: closeContent
                    })
                }

                Component {
                    id: closeContent
                    Item {
                        implicitHeight: 96
                        Text {
                            anchors.centerIn: parent
                            text: "这个按钮挂了 NovaClosePopup，点它关闭当前弹层"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontS
                        }
                        NovaBtn {
                            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                            text: "关闭本层"; size: "sm"; variant: "outlined"
                            NovaClosePopup { onClosed: (n) => behPage.closeCount += n }
                        }
                    }
                }

                NovaChip { text: "ClosePopup 关闭计数：" + behPage.closeCount; outlined: true; dense: true }
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

    // ════════════════════════════════════════════════════════════
    // 页面：L0 设计语言（图标集 / 排版 / 动效）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageDesign
        Item {
            id: dp
            property string probeIcon: "mdi-home"
            property string trName: "slide-right"
            property bool trShow: true

            Timer {
                id: replay
                interval: 520; repeat: false
                onTriggered: dp.trShow = true
            }
            function replayDemo() { dp.trShow = false; replay.restart() }

            GalleryPage {
                title: "L0 设计语言 · 图标集 / 排版 / 动效"
                desc: "图标：14 套 Quasar 官方 icon-set 全键移植（100 个语义键/套）+ provider 注册表 + 八通道名称归一化（mdi-home、mdi:home、fas fa-home、o_home、sym_r_home、ion-md-home、img:、SVG path）。排版：12 级字阶 1:1（h1 96px/96px/-1.5px/300）。动效：15 种预设过渡 + 时长/缓动令牌 + reducedMotion 短路。"

                GalleryRow { label: "① 图标集切换（点击即刻换整套语义键）" }
                Flow {
                    width: parent.width
                    spacing: 6
                    Repeater {
                        model: NovaIconSet.available
                        delegate: NovaBtn {
                            required property string modelData
                            text: modelData
                            size: "sm"
                            variant: NovaIconSet.name === modelData ? "flat" : "outlined"
                            onClicked: NovaIconSet.use(modelData)
                        }
                    }
                }

                GalleryRow { label: "② 当前图标集语义键（" + NovaIconSet.name + "）" }
                Row {
                    spacing: NovaTheme.spacingL
                    Repeater {
                        model: [
                            { "k": "type.positive", "label": "positive" },
                            { "k": "type.negative", "label": "negative" },
                            { "k": "arrow.dropdown", "label": "dropdown" },
                            { "k": "chevron.right", "label": "chevron" },
                            { "k": "chip.remove", "label": "chip.remove" },
                            { "k": "pagination.next", "label": "pagination" },
                            { "k": "stepper.done", "label": "stepper.done" },
                            { "k": "rating.icon", "label": "rating" }
                        ]
                        delegate: Column {
                            required property var modelData
                            spacing: 4
                            NovaIcon {
                                icon: NovaIconSet.get(modelData.k)
                                size: 26
                                color: NovaTheme.primary
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: modelData.label
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                            }
                        }
                    }
                }

                GalleryRow { label: "③ 八种写法归一化（同一图标的不同书写方式）" }
                Flow {
                    width: parent.width
                    spacing: NovaTheme.spacingL
                    Repeater {
                        model: ["mdi-home", "mdi:home", "fas fa-home", "o_home",
                                "sym_r_home", "ion-md-home", "bi-house", "eva-home"]
                        delegate: Column {
                            required property string modelData
                            spacing: 2
                            NovaIcon { icon: modelData; size: 26; anchors.horizontalCenter: parent.horizontalCenter }
                            Text {
                                text: modelData
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                            }
                            Text {
                                text: NovaIconSet.resolve(modelData).provider
                                color: NovaTheme.textMuted
                                font.pixelSize: 10
                                opacity: 0.7
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    Column {
                        spacing: 2
                        NovaIcon {
                            icon: "M12 2L2 7v10h4V9h12v8h4V7z|0 0 24 24"
                            size: 26
                            color: NovaTheme.accent
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text { text: "SVG path 直出"; color: NovaTheme.textMuted; font.pixelSize: 10 }
                    }
                }

                GalleryRow { label: "④ 排版 12 级字阶（1:1 对标 $headings）" }
                Column {
                    width: parent.width
                    spacing: 2
                    Repeater {
                        model: NovaTheme.typeNames
                        delegate: Row {
                            required property string modelData
                            spacing: NovaTheme.spacingM
                            NovaText {
                                text: modelData
                                typography: "caption"
                                muted: true
                                width: 74
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                            }
                            NovaText { text: "青铜峡 Nova 字阶"; typography: modelData }
                        }
                    }
                }

                GalleryRow { label: "⑤ 动效预设（15 种，reducedMotion 一键全链短路）" }
                Row {
                    spacing: NovaTheme.spacingS
                    Repeater {
                        model: ["fade", "scale", "slide-right", "slide-up", "jump-right", "flip-right"]
                        delegate: NovaBtn {
                            required property string modelData
                            text: modelData
                            size: "sm"
                            variant: dp.trName === modelData ? "flat" : "outlined"
                            onClicked: { dp.trName = modelData; dp.replayDemo() }
                        }
                    }
                    NovaBtn {
                        text: "重播"
                        size: "sm"
                        variant: "outlined"
                        icon: "↻"
                        onClicked: dp.replayDemo()
                    }
                    NovaBtn {
                        text: NovaMotion.reducedMotion ? "减弱动效：开" : "减弱动效：关"
                        size: "sm"
                        variant: NovaMotion.reducedMotion ? "flat" : "outlined"
                        onClicked: NovaMotion.reducedMotion = !NovaMotion.reducedMotion
                    }
                }
                Rectangle {
                    width: parent.width
                    height: 96
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surfaceAlt
                    border.color: NovaTheme.outline
                    clip: true

                    NovaTransition {
                        anchors.centerIn: parent
                        width: 180
                        height: 64
                        name: dp.trName
                        show: dp.trShow
                        Rectangle {
                            anchors.fill: parent
                            radius: NovaTheme.radiusS
                            color: NovaTheme.primary
                            NovaText {
                                anchors.centerIn: parent
                                text: dp.trName
                                typography: "subtitle2"
                                color: NovaTheme.textOnPrimary
                            }
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：L5 工具层（colors / date / format / debounce / throttle）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageUtils
        Item {
            id: up
            property var now: new Date()
            property int rawClicks: 0
            property int debClicks: 0
            property int thrClicks: 0
            property var debFn: NovaUtils.debounce(function () { up.debClicks++ }, 300)
            property var thrFn: NovaUtils.throttle(function () { up.thrClicks++ }, 300, true)
            property string uidSample: ""

            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: up.now = new Date()
            }
            Component.onCompleted: up.uidSample = NovaUtils.uid()

            GalleryPage {
                title: "L5 工具层 · NovaUtils"
                desc: "对标 Quasar `import { colors, date, format, is, extend, debounce, throttle } from 'quasar'`。colors 12 函数（百分制 alpha 契约）、date 21 函数（formatDate 44 token、ISO 周、月末日夹取）、format 6 函数、is 5 函数 + extend/clone/uid/debounce/throttle/frameDebounce。DOM/event/scroll 共 35 项在 QML 不适用，已在 PARITY 留痕。"

                GalleryRow { label: "① colors · 亮度梯度（lighten 负数即 darken）" }
                Row {
                    spacing: 4
                    Repeater {
                        model: [-60, -40, -20, 0, 20, 40, 60, 80, 95]
                        delegate: Column {
                            required property int modelData
                            spacing: 2
                            Rectangle {
                                width: 62; height: 34; radius: NovaTheme.radiusS
                                color: NovaUtils.colors.lighten("#5B6EF5", modelData)
                            }
                            Text {
                                text: (modelData > 0 ? "+" : "") + modelData + "%"
                                color: NovaTheme.textMuted
                                font.pixelSize: 10
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                GalleryRow { label: "② colors · 对比度自动选字色（WCAG）" }
                Row {
                    spacing: 8
                    Repeater {
                        model: ["#5B6EF5", "#22C55E", "#F59E0B", "#EF4444", "#1D1D1D", "#FFFFFF"]
                        delegate: Rectangle {
                            required property string modelData
                            width: 118; height: 44; radius: NovaTheme.radiusS
                            color: modelData
                            Text {
                                anchors.centerIn: parent
                                text: modelData + " · " + NovaUtils.colors.contrastRatio(modelData, NovaUtils.colors.contrastColor(modelData)).toFixed(1) + ":1"
                                color: NovaUtils.colors.contrastColor(modelData)
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                GalleryRow { label: "③ date · 实时格式化（每秒刷新）" }
                Row {
                    spacing: NovaTheme.spacingL
                    Column {
                        spacing: 2
                        Text {
                            text: NovaUtils.date.formatDate(up.now, "YYYY-MM-DD HH:mm:ss")
                            color: NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontXL
                            font.family: "Consolas"
                        }
                        Text {
                            text: NovaUtils.date.formatDate(up.now, "dddd, MMMM Do YYYY · ww 周 · 年内第 DDD 天")
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontS
                        }
                        Text {
                            text: NovaUtils.date.formatDate(up.now, "YYYY年M月D日 dddd A hh:mm", NovaUtils.dateLocale.zhCN)
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontS
                        }
                    }
                    Column {
                        spacing: 2
                        Text { text: "ISO 周：w=" + NovaUtils.date.getWeekOfYear(up.now) + " / GG=" + NovaUtils.date.getISOWeekYear(up.now); color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                        Text { text: "年内第 " + NovaUtils.date.getDayOfYear(up.now) + " 天 / 本月 " + NovaUtils.date.daysInMonth(up.now) + " 天"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                        Text { text: "时间戳 x=" + NovaUtils.date.formatDate(up.now, "x") + " / X=" + NovaUtils.date.formatDate(up.now, "X"); color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS }
                    }
                }

                GalleryRow { label: "④ format · 人类可读（humanStorageSize / pad / getDecimalsCount）" }
                Row {
                    spacing: NovaTheme.spacingS
                    Repeater {
                        model: [512, 1536, 1048576, 5368709120, 1099511627776]
                        delegate: NovaChip {
                            required property int modelData
                            text: modelData + " → " + NovaUtils.format.humanStorageSize(modelData)
                            outlined: true
                            dense: true
                        }
                    }
                    NovaChip {
                        text: "1.5e-7 → " + NovaUtils.format.getDecimalsCount(1.5e-7) + " 位小数"
                        outlined: true
                        dense: true
                    }
                }

                GalleryRow { label: "⑤ debounce / throttle（连点 10 次看真实差异）" }
                Row {
                    spacing: NovaTheme.spacingM
                    Rectangle {
                        width: 150; height: 62; radius: NovaTheme.radiusS
                        color: NovaTheme.primary
                        Text { anchors.centerIn: parent; text: "连点我"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontM }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                up.rawClicks++
                                up.debFn()
                                up.thrFn()
                            }
                        }
                    }
                    Column {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: "原始触发：" + up.rawClicks + " 次"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS }
                        Text { text: "debounce(300ms)：" + up.debClicks + " 次"; color: NovaTheme.positive; font.pixelSize: NovaTheme.fontS }
                        Text { text: "throttle(300ms)：" + up.thrClicks + " 次"; color: NovaTheme.accent; font.pixelSize: NovaTheme.fontS }
                    }
                    NovaBtn {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "清零"
                        size: "sm"
                        variant: "outlined"
                        onClicked: { up.rawClicks = 0; up.debClicks = 0; up.thrClicks = 0 }
                    }
                }

                GalleryRow { label: "⑥ is / extend / uid" }
                Column {
                    spacing: 4
                    Text {
                        text: "deepEqual({a:[1,2]}, {a:[1,2]}) → " + NovaUtils.is.deepEqual({ "a": [1, 2] }, { "a": [1, 2] })
                        color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS
                    }
                    Text {
                        text: "extend(true, {a:{b:1}}, {a:{c:2}}) → " + JSON.stringify(NovaUtils.extend(true, { "a": { "b": 1 } }, { "a": { "c": 2 } }))
                        color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS
                    }
                    Text {
                        text: "uid() → " + up.uidSample
                        color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：表单核心（NovaField/NovaInput/NovaSelect/NovaCheckbox/NovaRadio/NovaToggle/NovaSlider）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageForms
        Item {
            id: fp
            property var multi: [false, false]
            property string radioPick: "b"
            property var selFruit: null
            property var selTags: []
            property bool tg1: false
            property bool tg2: false

            GalleryPage {
                title: "表单核心 · 二期 Sprint A"
                desc: "统一契约 label / hint / error / readonly / disable / clearable / rules。NovaField 容器壳（样式四型 + 浮动 label + 校验引擎）、NovaInput（密码/多行/数字/防抖）、NovaSelect（归一化选项 + 多选 + useInput 过滤）、NovaCheckbox（三态循环）、NovaRadio、NovaToggle（复用 checkbox 语义换装开关）、NovaSlider（step 量化 + 刻点 + 气泡 + 垂直）。"

                GalleryRow { label: "① NovaInput：校验规则 / 清空 / 密码 / 多行 / 数字" }
                Column {
                    spacing: NovaTheme.spacingM
                    width: parent.width
                    Row {
                        spacing: NovaTheme.spacingL
                        NovaInput {
                            width: 260
                            label: "用户名"
                            hint: "至少 3 个字符"
                            clearable: true
                            rules: ["required", "minlen(3)"]
                        }
                        NovaInput {
                            width: 200
                            label: "密码"
                            type: "password"
                            clearable: true
                        }
                        NovaInput {
                            width: 160
                            label: "价格"
                            type: "number"
                            modelModifiers: ["number"]
                            prefix: "¥"
                            suffix: "元"
                        }
                    }
                    NovaInput {
                        width: 380
                        label: "备注"
                        type: "textarea"
                        autogrow: true
                        shadowText: "请输入备注（textarea 自增高）"
                    }
                    Text {
                        text: "↑ 输入少于 3 字符即时报错（rules 实时校验）"
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                    }
                }

                GalleryRow { label: "② NovaField 样式四型：filled / outlined / standout / borderless" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaField { width: 170; label: "filled（默认）"; filled: true; hint: "底行 hint" }
                    NovaField { width: 150; label: "outlined"; outlined: true }
                    NovaField { width: 150; label: "standout"; standout: true }
                    NovaField { width: 150; label: "borderless"; borderless: true }
                    NovaField { width: 130; label: "dense+rounded"; filled: true; dense: true; rounded: true; stackLabel: true }
                }

                GalleryRow { label: "③ NovaSelect：单选 / 多选上限 / useInput 过滤" }
                Row {
                    spacing: NovaTheme.spacingL
                    NovaSelect {
                        width: 200
                        label: "水果"
                        emitValue: true
                        options: [
                            { label: "苹果", value: "apple" },
                            { label: "香蕉", value: "banana", disable: true },
                            { label: "樱桃", value: "cherry" },
                            { label: "榴莲", value: "durian" }
                        ]
                    }
                    NovaSelect {
                        width: 220
                        label: "多选（最多 2 项）"
                        multiple: true; emitValue: true; maxValues: 2
                        options: ["HTML", "CSS", "QML", "Python"]
                    }
                    NovaSelect {
                        width: 200
                        label: "搜索过滤"
                        useInput: true
                        emitValue: true
                        options: ["北京", "上海", "广州", "深圳", "杭州"]
                    }
                }

                GalleryRow { label: "④ NovaCheckbox / NovaRadio / NovaToggle：三态循环与组联动（受控模式：宿主写回）" }
                Column {
                    spacing: 10
                    Row {
                        spacing: NovaTheme.spacingL
                        Column {
                            spacing: 8
                            NovaCheckbox {
                                label: "选项甲"
                                modelValue: fp.multi[0] === true
                                onValueChanged: (v) => { if (fp.multi[0] !== v) fp.multi = [v, fp.multi[1]] }
                            }
                            NovaCheckbox {
                                label: "选项乙"
                                modelValue: fp.multi[1] === true
                                onValueChanged: (v) => { if (fp.multi[1] !== v) fp.multi = [fp.multi[0], v] }
                            }
                            NovaCheckbox {
                                label: "全选（半选循环 f→t→i→f）"
                                toggleIndeterminate: true
                                indeterminateValue: "partial"
                                modelValue: (fp.multi[0] === true && fp.multi[1] === true) ? true
                                           : (fp.multi[0] !== true && fp.multi[1] !== true) ? false : "partial"
                                onValueChanged: (v) => fp.multi = [v === true, v === true]
                            }
                        }
                        Column {
                            spacing: 8
                            NovaRadio { label: "甲"; val: "a"; modelValue: fp.radioPick; onValueChanged: (v) => { if (fp.radioPick !== v) fp.radioPick = v } }
                            NovaRadio { label: "乙"; val: "b"; modelValue: fp.radioPick; onValueChanged: (v) => { if (fp.radioPick !== v) fp.radioPick = v } }
                            NovaRadio { label: "丙（禁用）"; val: "c"; modelValue: fp.radioPick; disable: true }
                        }
                        Column {
                            spacing: 12
                            NovaToggle { label: "开关（带图标）"; icon: "mdi:check"; modelValue: fp.tg1 === true; onValueChanged: (v) => fp.tg1 = v }
                            NovaToggle { label: "dense"; dense: true; modelValue: fp.tg2 === true; onValueChanged: (v) => fp.tg2 = v }
                            NovaToggle { label: "readonly"; readonly: true; modelValue: true }
                        }
                    }
                }

                GalleryRow { label: "⑤ NovaSlider：step 量化 / 刻点 / 气泡 / 垂直 / markerLabels" }
                Row {
                    spacing: NovaTheme.spacingL
                    Column {
                        spacing: 8
                        NovaSlider {
                            width: 300
                            min: 0; max: 100; step: 5
                            label: true
                            markers: 2
                        }
                        NovaSlider {
                            width: 300
                            min: 0; max: 100; step: 10
                            markerLabels: true
                            hint: "markerLabels 数值刻度（step 10）"
                        }
                    }
                    NovaSlider {
                        width: 36; height: 120
                        vertical: true
                        reverse: true
                        label: true
                    }
                    NovaSlider {
                        width: 36; height: 120
                        vertical: true
                        markerLabels: ["低", "中", "高"]
                        label: true
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：输入进阶（NovaRange/NovaDate/NovaTime/NovaColorPicker/NovaOptionGroup/NovaForm/NovaBtnToggle/NovaPopupEdit）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageForm2
        Item {
            id: f2
            property var rangeVal: ({ min: 20, max: 80 })
            property string dateVal: ""
            property string timeVal: ""
            property string colorVal: ""
            property var ogVals: []
            property string radioVal: "r1"
            property var btVal: "w"
            property string peVal: "可编辑文本"
            property int formOk: 0

            GalleryPage {
                title: "输入进阶 · 二期 Sprint B"
                desc: "NovaRange 双值范围、NovaDate 自研日历（单选/多选/区间）、NovaTime 时钟面盘、NovaColorPicker 色域盘、NovaOptionGroup 三型选项组、NovaForm 聚合校验、NovaBtnToggle 按钮组、NovaPopupEdit 就地编辑。"

                GalleryRow { label: "① NovaRange：双值范围滑杆（step 量化 + min/maxRange 约束）" }
                NovaRange {
                    width: 320
                    min: 0; max: 100; step: 5
                    minRange: 10; maxRange: 60
                    label: true; markers: 4
                    modelValue: f2.rangeVal
                    onValueChanged: (v) => f2.rangeVal = v
                }

                GalleryRow { label: "② NovaDate / NovaTime：自研日历 + 时钟面盘" }
                Row {
                    spacing: NovaTheme.spacingL
                    Column {
                        spacing: 8
                        NovaDate {
                            mask: "YYYY/MM/DD"
                            todayBtn: true
                            events: [Qt.formatDate(new Date(), "yyyy/MM/dd")]
                            onValueChanged: (v) => f2.dateVal = v === null ? "未选择" : v
                        }
                        Text { text: "选中：" + f2.dateVal; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                    }
                    Column {
                        spacing: 8
                        NovaTime { withSeconds: false; nowBtn: true; onValueChanged: (v) => f2.timeVal = v === null ? "未选择" : v }
                        Text { text: "选中：" + f2.timeVal; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                    }
                }

                GalleryRow { label: "③ NovaColorPicker：色域盘 + 色相条 + 调色板" }
                Row {
                    spacing: NovaTheme.spacingL
                    NovaColorPicker { onValueChanged: (v) => f2.colorVal = v === null ? "未选择" : v }
                    Column {
                        spacing: 8
                        Rectangle { width: 48; height: 48; radius: 10; color: f2.colorVal === "" ? NovaTheme.outline : f2.colorVal; border.width: 1; border.color: NovaTheme.outline }
                        Text { text: f2.colorVal === "" ? "-" : f2.colorVal; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                    }
                }

                GalleryRow { label: "④ NovaOptionGroup / NovaBtnToggle：三型选项组 + 按钮组" }
                Row {
                    spacing: NovaTheme.spacingL
                    Column { spacing: 8; NovaOptionGroup { type: "checkbox"; options: [{label: "邮件", value: "mail"}, {label: "短信", value: "sms"}, {label: "推送（禁用）", value: "push", disable: true}]; onValueChanged: (v) => f2.ogVals = v } }
                    Column { spacing: 8; NovaOptionGroup { type: "radio"; options: [{label: "普通", value: "r1"}, {label: "加急", value: "r2"}]; modelValue: f2.radioVal; onValueChanged: (v) => f2.radioVal = v } }
                    NovaOptionGroup { type: "toggle"; inline: true; options: ["天气", "新闻"] }
                    NovaBtnToggle { options: [{label: "日", value: "d"}, {label: "周", value: "w"}, {label: "月", value: "m"}]; clearable: true; modelValue: f2.btVal; onValueChanged: (v) => f2.btVal = v }
                }

                GalleryRow { label: "⑤ NovaForm：聚合校验（greedy 全量计错 + submit）" }
                Column {
                    spacing: 10
                    width: parent.width
                    NovaForm {
                        id: f2form
                        width: 320
                        greedy: true
                        onSubmitted: f2.formOk++
                        NovaInput { width: 320; label: "邮箱（必填 + email 规则）"; rules: ["required", "email"] }
                        NovaInput { width: 320; label: "备注（maxlen 10）"; rules: ["maxlen(10)"] }
                        Row {
                            spacing: 8
                            NovaBtn { text: "提交表单"; onClicked: f2form.submit() }
                            NovaBtn { text: "重置"; variant: "outlined"; onClicked: f2form.resetValidation() }
                        }
                    }
                    Text { text: "成功提交次数：" + f2.formOk; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                }

                GalleryRow { label: "⑥ NovaPopupEdit：就地编辑（autoSave 关闭即提交）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaPopupEdit {
                        width: 200
                        title: "编辑文本"
                        labelSet: "保存"; labelCancel: "取消"
                        Rectangle {
                            width: 200; height: 34; radius: NovaTheme.radiusS
                            color: NovaTheme.surface
                            border.width: 1; border.color: NovaTheme.outline
                            Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: f2.peVal; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS; elide: Text.ElideRight }
                        }
                        editorData: Column {
                            spacing: 8
                            Rectangle { width: 200; height: 28; radius: NovaTheme.radiusS; color: NovaTheme.surface; border.width: 1; border.color: NovaTheme.outline
                                TextInput { x: 8; anchors.verticalCenter: parent.verticalCenter; width: 184; text: f2.peVal; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS; onTextChanged: if (text !== f2.peVal) f2.peVal = text }
                            }
                        }
                    }
                    Text { text: "当前值：" + f2.peVal; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：数据体系 · 三期 Sprint A（表格/树/分页/列表/无限滚动/虚拟滚动）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageData
        Item {
            id: dt
            // 表格受控状态（坑位 22：组件只上报，宿主写回）
            property string sortField: ""
            property bool sortDesc: false
            property var tblSelected: []
            property int infBatches: 0
            property var tblExpanded: []
            property int tblPage: 1
            property string tblFilter: ""
            // 树受控状态
            property var trExpanded: []
            property var trTicked: []
            property var trSelected: null
            // 列表手风琴
            property bool accA: false
            property bool accB: false
            property bool accC: false
            // 分页器
            property int pg: 3
            // 数据源
            property var staffRows: [
                { id: 1, name: "苏晚晴", dept: "研发部", city: "杭州", score: 92 },
                { id: 2, name: "陆则明", dept: "产品部", city: "上海", score: 87 },
                { id: 3, name: "程一诺", dept: "研发部", city: "深圳", score: 95 },
                { id: 4, name: "许知远", dept: "设计部", city: "杭州", score: 78 },
                { id: 5, name: "林深见鹿", dept: "市场部", city: "北京", score: 83 },
                { id: 6, name: "顾北辰", dept: "研发部", city: "广州", score: 90 },
                { id: 7, name: "沈清辞", dept: "运营部", city: "成都", score: 74 },
                { id: 8, name: "温叙白", dept: "产品部", city: "武汉", score: 88 }
            ]

            GalleryPage {
                title: "数据体系 · 三期 Sprint A"
                desc: "NovaTable 排序/过滤/分页/多选/展开行（受控模式）、NovaTree strict 勾选级联+懒加载+过滤、NovaPagination 页码器、NovaList 手风琴、NovaMarkupTable、NovaVirtualScroll 5000 行虚拟化、NovaInfiniteScroll 触底加载、NovaScrollArea。"

                GalleryRow { label: "① NovaTable：点击表头排序（三态）· 多选 · 过滤 · 分页 · 点行展开" }
                Column {
                    width: parent ? parent.width - 16 : 600
                    spacing: NovaTheme.spacingS
                    Rectangle {
                        width: parent.width
                        height: 34
                        radius: NovaTheme.radiusS
                        color: NovaTheme.surfaceAlt
                        border.width: 1; border.color: NovaTheme.outline
                        TextInput {
                            id: filterIn
                            x: 10; anchors.verticalCenter: parent.verticalCenter
                            width: 260
                            color: NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontS
                            onTextChanged: dt.tblFilter = text
                            Text {
                                visible: filterIn.text === ""
                                x: 0; anchors.verticalCenter: parent.verticalCenter
                                text: "🔍 全字段过滤（试试“研发”或“杭州”）…"
                                color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS
                            }
                        }
                    }
                    NovaTable {
                        id: bigTbl
                        width: parent.width
                        title: "团队名单"
                        rowKey: "id"
                        columns: [
                            { name: "id", label: "ID", field: "id", align: "center", sortable: true },
                            { name: "name", label: "姓名", field: "name", sortable: true },
                            { name: "dept", label: "部门", field: "dept", sortable: true },
                            { name: "city", label: "城市", field: "city", sortable: true },
                            { name: "score", label: "绩效", field: "score", align: "right", sortable: true }
                        ]
                        rows: dt.staffRows
                        filter: dt.tblFilter
                        sortBy: dt.sortField
                        descending: dt.sortDesc
                        selected: dt.tblSelected
                        expanded: dt.tblExpanded
                        page: dt.tblPage
                        rowsPerPage: 3
                        expandSlot: Row {
                            property var rowData
                            property int rowIndex
                            leftPadding: 56
                            spacing: 8
                            Text { text: "📋 工单小结："; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                            Text {
                                text: rowData ? rowData.name + " · " + rowData.dept + " · 绩效 " + rowData.score + " 分"
                                              : ""
                                color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS
                            }
                        }
                        onSortChanged: (f, d) => { dt.sortField = f; dt.sortDesc = d }
                        onUpdateSelected: (r) => dt.tblSelected = r
                        onUpdateExpanded: (k) => dt.tblExpanded = k
                        onPageRequested: (p) => dt.tblPage = p
                    }
                    Text {
                        text: "排序：" + (dt.sortField === "" ? "无" : dt.sortField + (dt.sortDesc ? " ↓" : " ↑"))
                              + "　已选 " + dt.tblSelected.length + " 行　展开 " + dt.tblExpanded.length + " 行"
                        color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS
                    }
                }

                GalleryRow { label: "② NovaTree：strict 勾选级联（子全勾→父自动勾）· 懒加载 · 过滤" }
                Row {
                    spacing: NovaTheme.spacingL
                    NovaTree {
                        id: bigTree
                        width: 360; height: 260
                        tickStrategy: "strict"
                        nodes: [
                            { label: "研发中心", icon: "mdi:folder-outline", children: [
                                  { label: "前端组", children: [{ label: "Web 小队" }, { label: "客户端小队" }] },
                                  { label: "后端组", children: [{ label: "平台小队" }] } ] },
                            { label: "设计中心", icon: "mdi:palette-outline", children: [{ label: "视觉组" }] },
                            { label: "外包资源池（懒加载）", icon: "mdi:cloud-download-outline", lazy: true }
                        ]
                        expanded: dt.trExpanded
                        ticked: dt.trTicked
                        selected: dt.trSelected
                        onUpdateExpanded: (k) => dt.trExpanded = k
                        onUpdateTicked: (k) => dt.trTicked = k
                        onUpdateSelected: (k) => dt.trSelected = k
                        onLazyLoad: (node, done) => done([
                            { label: "外包 · 视觉支持" }, { label: "外包 · 文案支持" }
                        ])
                    }
                    Column {
                        spacing: 6
                        Text { text: "已选节点：" + (dt.trSelected === null ? "无" : dt.trSelected); color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                        Text { text: "已勾选 " + dt.trTicked.length + " 个：" + dt.trTicked.join("、"); color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS; width: 360; wrapMode: Text.Wrap }
                        NovaBtn { text: "全部展开"; variant: "outlined"; dense: true; onClicked: bigTree.expandAll() }
                        NovaBtn { text: "全部收起"; variant: "outlined"; dense: true; onClicked: bigTree.collapseAll() }
                    }
                }

                GalleryRow { label: "③ NovaList：手风琴（展开一个自动收起兄弟）· separator/dense" }
                NovaList {
                    width: 480
                    separator: true
                    accordion: true
                    NovaItem {
                        label: "v0.11.0 · 数据体系"
                        caption: "表格/树/分页/列表九件一次交付"
                        icon: "mdi:package-up"
                        expandable: true; expanded: dt.accA
                        onExpandRequested: (e) => dt.accA = e
                        expandContent: NovaItemLabel { text: "NovaTable 基础能力全部就位，虚拟滚动与服务端模式留待 v0.12。"; caption: true; lines: 2 }
                    }
                    NovaItem {
                        label: "受控模式贯穿"
                        caption: "组件只上报，宿主写回"
                        icon: "mdi:swap-horizontal"
                        expandable: true; expanded: dt.accB
                        onExpandRequested: (e) => dt.accB = e
                        expandContent: NovaItemLabel { text: "排序/选择/展开/分页全部走 emit-only，杜绝绑定环。"; caption: true; lines: 2 }
                    }
                    NovaItem {
                        label: "不可展开条目（对照）"
                        icon: "mdi:information-outline"
                        clickable: true
                        onClicked: dt.accC = !dt.accC
                        trailing: Item { width: 64; height: 22; NovaBadge { text: "点击试试" } }
                    }
                }

                GalleryRow { label: "④ NovaPagination：maxPages 滑窗 + ellipses + boundaryLinks（« »）" }
                Column {
                    spacing: 6
                    NovaPagination {
                        page: dt.pg
                        pages: 42
                        maxPages: 5
                        ellipses: true
                        boundaryLinks: true
                        onPageRequested: (p) => dt.pg = p
                    }
                    Text { text: "当前页 " + dt.pg + " / 42"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                }

                GalleryRow { label: "⑤ NovaMarkupTable：标记表格（columns/rows 直渲）" }
                NovaMarkupTable {
                    width: 480
                    title: "本期交付清单"
                    columns: ["交付物", "对标", "状态"]
                    rows: [
                        ["NovaTable(+Th/Td/Tr)", "QTable", "已交付（基础）"],
                        ["NovaTree", "QTree", "已交付"],
                        ["NovaPagination", "QPagination", "已交付"],
                        ["NovaList / NovaItem", "QList / QItem", "已交付"],
                        ["NovaMarkupTable", "QMarkupTable", "已交付"],
                        ["NovaVirtualScroll / NovaInfiniteScroll / NovaScrollArea", "同名", "已交付"]
                    ]
                }

                GalleryRow { label: "⑥ NovaVirtualScroll：5000 行仅渲染可视窗口（reuseItems）" }
                Rectangle {
                    width: 520
                    height: 220
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surfaceAlt
                    border.width: 1; border.color: NovaTheme.outline
                    NovaVirtualScroll {
                        id: vsl
                        anchors.fill: parent
                        anchors.margins: 8
                        itemSize: 40
                        items: Array.from({ length: 5000 }, function (_, i) { return i })
                        delegate: Rectangle {
                            required property int index
                            width: vsl.width; height: 40
                            radius: NovaTheme.radiusS
                            color: index % 2 ? NovaTheme.surface : NovaTheme.surfaceAlt
                            Text {
                                x: 12; anchors.verticalCenter: parent.verticalCenter
                                text: "第 " + (parent.index + 1) + " 行 · 虚拟渲染中"
                                color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS
                            }
                        }
                    }
                }

                GalleryRow { label: "⑦ NovaInfiniteScroll：触底自动加载（本演示 3 批后停止）" }
                NovaInfiniteScroll {
                    width: 520
                    height: 180
                    Rectangle {
                        width: parent.width; height: 120
                        radius: NovaTheme.radiusS
                        color: NovaTheme.surface
                        border.width: 1; border.color: NovaTheme.outline
                    }
                    onLoad: (index, done) => {
                        dt.infBatches++
                        infTimer.done = done
                        infTimer.start()
                    }
                    Timer {
                        id: infTimer
                        property var done: null
                        interval: 600
                        onTriggered: if (done) done(dt.infBatches >= 3)
                    }
                    Text { text: "已加载 " + dt.infBatches + " 批" + (dt.infBatches >= 3 ? "（已停止）" : ""); x: 12; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                }

                GalleryRow { label: "⑧ NovaScrollArea：内容超界出主题化滚动条（明暗跟随）" }
                NovaScrollArea {
                    width: 520
                    height: 160
                    Rectangle {
                        width: 800; height: 300
                        radius: NovaTheme.radiusM
                        color: NovaTheme.surface
                        Column {
                            x: 16; y: 12
                            spacing: 8
                            Repeater {
                                model: 8
                                Text {
                                    required property int index
                                    text: "横向纵向都超出内容区的长文本行 " + (index + 1)
                                    color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontM
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：媒体体系 · 三期 Sprint B（图片/等比容器/视频/视差/轮播/时间轴/聊天气泡/表格增强）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageMedia
        Item {
            id: md
            // 媒体页受控状态
            property var carSlide: "首屏"
            property int carVisits: 0
            property string srvSortBy: ""
            property bool srvDesc: false
            property int srvPage: 1
            property var srvRows: []
            property string srvFilter: ""
            property var parInfo: null
            property string imgState: ""
            // 服务端模式模拟数据池
            readonly property var srvPool: Array.from({ length: 137 }, function (_, i) {
                return { id: i + 1, name: "工单-" + (1000 + i + 1), owner: ["苏晚晴", "陆则明", "程一诺", "许知远"][i % 4], status: ["处理中", "已完成", "待评审"][i % 3] }
            })
            function srvFetch(sortBy, desc, page, flt) {
                var rows = srvPool
                if (flt !== "") rows = rows.filter(function (r) { return r.name.indexOf(flt) !== -1 || r.owner.indexOf(flt) !== -1 })
                if (sortBy !== "") rows = rows.slice().sort(function (a, b) {
                    var va = a[sortBy], vb = b[sortBy]
                    return (typeof va === "number" ? va - vb : String(va).localeCompare(String(vb))) * (desc ? -1 : 1)
                })
                return rows.slice((page - 1) * 8, page * 8)
            }
            function srvRefresh() {
                srvRows = Qt.binding(function () {
                    return srvFetch(srvSortBy, srvDesc, srvPage, srvFilter)
                })
            }

            GalleryPage {
                title: "媒体体系 · 三期 Sprint B"
                desc: "NovaImg 占位/错误/转圈三态 + ratio 宽高比、NovaResponsive 等比容器、NovaVideo 视频包装（播放器惰性创建）、NovaParallax 视差滚动、NovaCarousel 受控轮播（arrows/navigation/autoplay/infinite/swipeable/缩略图/覆盖控件）、NovaTimeline 三布局时间轴、NovaChatMessage 聊天气泡、NovaTable 虚拟滚动 + 服务端模式。"

                // 图片演示源：内联 SVG data URL（离线可用）
                readonly property string svgRed: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='100'><defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'><stop offset='0' stop-color='%235B6EF5'/><stop offset='1' stop-color='%2326A69A'/></linearGradient></defs><rect width='160' height='100' fill='url(%23g)'/><circle cx='130' cy='26' r='14' fill='%23FF7043'/></svg>"
                readonly property string svgPlaceholder: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='100'><rect width='160' height='100' fill='%23E3E5EB'/><text x='80' y='55' font-size='12' text-anchor='middle' fill='%236E7380'>加载中…</text></svg>"

                GalleryRow { label: "① NovaImg：加载态（占位图+延时转圈）/ 错误图 / ratio 宽高比 / fit 四态" }
                Row {
                    spacing: NovaTheme.spacingM
                    Column {
                        spacing: 4
                        NovaImg {
                            width: 240; ratio: 1.6; fit: "contain"
                            src: md.svgRed
                            placeholderSrc: md.svgPlaceholder
                            spinnerTint: NovaTheme.primary; loadingShowDelay: 200
                            onLoaded: md.imgState = "loaded"
                        }
                        Text { text: "加载态 → " + md.imgState; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                    }
                    Column {
                        spacing: 4
                        NovaImg {
                            width: 240; ratio: 1.6; fit: "cover"
                            src: "file:///not-exists-404.png"
                            errorSrc: md.svgPlaceholder
                            onErrored: md.imgState = md.imgState === "loaded" ? md.imgState : "error"
                        }
                        Text { text: "错误态（404 → errorSrc）"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                    }
                }

                GalleryRow { label: "② NovaResponsive：ratio 等比容器（内容铺满，宽变高随）" }
                Row {
                    spacing: NovaTheme.spacingM
                    NovaResponsive {
                        width: 300; ratio: 16 / 9
                        Rectangle { anchors.fill: parent; radius: NovaTheme.radiusS; color: NovaTheme.primary
                            Text { anchors.centerIn: parent; text: "16 : 9"; color: NovaTheme.textOnPrimary; font.bold: true } }
                    }
                    NovaResponsive {
                        width: 300; ratio: 1
                        Rectangle { anchors.fill: parent; radius: NovaTheme.radiusS; color: NovaTheme.secondary
                            Text { anchors.centerIn: parent; text: "1 : 1"; color: NovaTheme.textOnPrimary; font.bold: true } }
                    }
                }

                GalleryRow { label: "③ NovaVideo：视频包装（ratio 16:9；src 为空时显示提示、播放器按需创建）" }
                NovaVideo { width: 360; title: "产品宣传片（示例占位）" }

                GalleryRow { label: "④ NovaParallax：视差滚动（下方滚动条拖动，看对勾图随速度因子 0.6 慢移）" }
                Item {
                    width: 560; height: 200
                    Rectangle {
                        id: parFlickBg
                        width: 560; height: 200
                        radius: NovaTheme.radiusM
                        color: NovaTheme.surfaceAlt
                        border.width: 1; border.color: NovaTheme.outline
                    }
                    Flickable {
                        id: parFlick
                        anchors.fill: parent
                        contentWidth: width
                        contentHeight: 620
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        Rectangle { width: 560; height: 620; color: "transparent" }
                        Column {
                            y: 520; spacing: 6
                            Repeater {
                                model: ["滚动内容 A（正常速度）", "滚动内容 B（正常速度）", "滚动内容 C（正常速度）"]
                                Text { required property string modelData; x: 16; text: modelData; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                            }
                        }
                        NovaParallax {
                            y: 180; width: 560; height: 180; speed: 0.6
                            scrollTarget: parFlick
                            src: md.svgRed
                            Rectangle {
                                anchors { left: parent.left; leftMargin: 16; bottom: parent.bottom; bottomMargin: 12 }
                                Text { text: "Parallax 媒体层"; color: "#fff"; font.bold: true; font.pixelSize: NovaTheme.fontM }
                            }
                            onScrolled: (info) => md.parInfo = info
                        }
                    }
                    Rectangle {
                        anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                        width: 6; height: 120; radius: 3; color: NovaTheme.outline
                    }
                }
                Text { text: "视差进度：" + (md.parInfo ? Number(md.parInfo.progress).toFixed(3) : "0"); color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }

                GalleryRow { label: "⑤ NovaCarousel：受控轮播（← → 箭头 / 圆点导航 / 自动轮播 / 无限回绕 / 拖拽翻页 / 自定义覆盖控件）" }
                Column {
                    spacing: 6
                    NovaCarousel {
                        id: car
                        width: 560; height: 220
                        modelValue: md.carSlide
                        arrows: true
                        navigation: true
                        infinite: true
                        swipeable: true
                        animated: true
                        autoplay: 4000
                        transitionDuration: 260
                        NovaCarouselSlide {
                            name: "首屏"; imgSrc: md.svgRed
                            Rectangle { anchors.centerIn: parent; width: 180; height: 64; radius: NovaTheme.radiusM; color: Qt.rgba(0, 0, 0, 0.45)
                                Text { anchors.centerIn: parent; text: "品牌首屏"; color: "#fff"; font.pixelSize: NovaTheme.fontL } }
                        }
                        NovaCarouselSlide {
                            name: "新品"
                            Rectangle { anchors.fill: parent; color: NovaTheme.secondary
                                Text { anchors.centerIn: parent; text: "新品发布"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontXL } }
                        }
                        NovaCarouselSlide {
                            name: "数据"
                            Rectangle { anchors.fill: parent; color: NovaTheme.primary
                                Text { anchors.centerIn: parent; text: "数据看板"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontXL } }
                        }
                        NovaCarouselControl {
                            position: "bottom-right"; offset: 10
                            Rectangle { width: 92; height: 26; radius: 13; color: Qt.rgba(0, 0, 0, 0.55)
                                Text { anchors.centerIn: parent; text: "已翻 " + md.carVisits + " 次"; color: "#fff"; font.pixelSize: NovaTheme.fontXS } }
                        }
                        onUpdateModelValue: (n) => { md.carSlide = n; md.carVisits++ }
                    }
                    Text { text: "当前页：" + md.carSlide + "（4 秒自动轮播，亦可拖拽 / 点击圆点）"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                }

                GalleryRow { label: "⑥ NovaTimeline：comfortable 布局（标签与正文分侧）+ heading + 图标轴点" }
                NovaTimeline {
                    width: 560
                    layout: "comfortable"
                    side: "left"
                    tint: NovaTheme.primary
                    NovaTimelineEntry { heading: true; title: "v0.12.0 · 媒体体系里程碑" }
                    NovaTimelineEntry { title: "NovaImg 落地"; subtitle: "三态 + ratio"; body: "占位/错误图与延时转圈，宽高比派生。"; icon: "mdi:image-outline" }
                    NovaTimelineEntry { title: "NovaCarousel 落地"; subtitle: "受控 + 覆盖控件"; body: "arrows/navigation/autoplay/infinite/swipeable 全家桶。"; icon: "mdi:view-carousel-outline" }
                    NovaTimelineEntry { title: "NovaTable 增强"; subtitle: "虚拟滚动 + 服务端"; body: "virtualScroll 与 request 信号一次收口。"; icon: "mdi:table-edit" }
                }

                GalleryRow { label: "⑦ NovaChatMessage：收发镜像 / 多条气泡 / stamp / 分组标签" }
                Column {
                    spacing: NovaTheme.spacingM
                    width: 560
                    NovaChatMessage {
                        width: 480
                        label: "今天 10:02"
                        name: "客服小诺"
                        text: ["您好，请问 NovaCarousel 支持触摸翻页吗？", "支持的，swipeable 默认开启～"]
                        stamp: "10:02"
                        avatarSlot: Rectangle { width: 34; height: 34; radius: 17; color: NovaTheme.secondary
                            Text { anchors.centerIn: parent; text: "诺"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontS } }
                    }
                    NovaChatMessage {
                        width: 480
                        sent: true
                        name: "小伙"
                        text: "太好了，服务端表格也想要！"
                        stamp: "10:03"
                        size: 8
                    }
                }

                GalleryRow { label: "⑧ NovaTable 虚拟滚动：1000 行真虚拟化 + 表头粘性常驻 + scrollTo" }
                Column {
                    spacing: 4
                    width: 560
                    NovaTable {
                        id: vtbl
                        width: 560; height: 240
                        virtualScroll: true; rowsPerPage: 0; virtualScrollItemSize: 44
                        title: "虚拟滚动 · 1000 行"
                        rowKey: "id"
                        columns: [
                            { name: "id", label: "#", field: "id", align: "center" },
                            { name: "name", label: "名称", field: "name" },
                            { name: "status", label: "状态", field: "status" }
                        ]
                        rows: Array.from({ length: 1000 }, function (_, i) {
                            return { id: i + 1, name: "记录-" + (i + 1), status: ["活跃", "归档", "草稿"][i % 3] }
                        })
                    }
                    Row {
                        spacing: NovaTheme.spacingM
                        NovaBtn { text: "跳到第 800 行"; variant: "outlined"; dense: true; onClicked: vtbl.scrollTo(799) }
                        Text { text: "虚拟化行数：" + vtbl.virtualRowCount + "（仅可视区 + 缓存带渲染）"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS; anchors.verticalCenter: parent.verticalCenter }
                    }
                }

                GalleryRow { label: "⑨ NovaTable 服务端模式：排序/翻页/过滤触发 request，宿主切片回填" }
                Column {
                    spacing: 4
                    width: 560
                    Rectangle {
                        width: parent.width; height: 32; radius: NovaTheme.radiusS
                        color: NovaTheme.surfaceAlt; border.width: 1; border.color: NovaTheme.outline
                        TextInput {
                            id: srvFilterIn
                            x: 10; anchors.verticalCenter: parent.verticalCenter; width: 240
                            color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontS
                            onTextChanged: { md.srvFilter = text; md.srvPage = 1; md.srvRefresh() }
                            Text { visible: srvFilterIn.text === ""; x: 0; anchors.verticalCenter: parent.verticalCenter
                                text: "🔍 服务端过滤（试试“苏晚晴”）…"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                        }
                    }
                    NovaTable {
                        id: srvTbl
                        width: 560; height: 260
                        title: "服务端分页 · 共 137 条（8 条/页）"
                        serverSide: true
                        rowsNumber: 137
                        rowsPerPage: 8
                        rowKey: "id"
                        loading: srvLoadTimer.running
                        loadingLabel: "宿主取数中…"
                        columns: [
                            { name: "id", label: "#", field: "id", align: "center", sortable: true },
                            { name: "name", label: "工单", field: "name", sortable: true },
                            { name: "owner", label: "负责人", field: "owner", sortable: true },
                            { name: "status", label: "状态", field: "status" }
                        ]
                        rows: md.srvRows
                        sortBy: md.srvSortBy; descending: md.srvDesc; page: md.srvPage
                        filter: md.srvFilter
                        onSortChanged: (f, d) => { md.srvSortBy = f; md.srvDesc = d; md.srvPage = 1; srvLoadTimer.restart(); md.srvRefresh() }
                        onPageRequested: (p) => { md.srvPage = p; srvLoadTimer.restart(); md.srvRefresh() }
                    }
                    Timer {
                        id: srvLoadTimer
                        interval: 350
                        onTriggered: if (running) stop()
                    }
                    Text { text: "最后请求：sort=" + (md.srvSortBy === "" ? "无" : md.srvSortBy) + (md.srvDesc ? "↓" : "↑") + " · page=" + md.srvPage; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                    Component.onCompleted: md.srvRefresh()
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：导航体系 · 四期 Sprint A（标签页/面板/面包屑/步骤条/展开项/工具栏/悬浮按钮组）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageNav
        Item {
            id: nv
            // 导航页受控状态
            property var tabVal: "inbox"
            property var stepVal: "info"
            property bool expAccount: true
            property bool expSecurity: false
            property bool fabOpen: false
            property int fabTicks: 0

            GalleryPage {
                title: "导航体系 · 四期 Sprint A"
                desc: "NovaTabs/NovaTab 标签页（横向滚动箭头/align/breakpoint 自动 justify/垂直模式/指示条）、NovaTabPanels 面板容器（animated/infinite/swipeable，受控联动）、NovaBreadcrumbs 面包屑（分隔符/激活色对标 2.35.6 源码语义）、NovaStepper 步骤条（状态图标解析 1:1/头部导航/垂直模式）、NovaExpansionItem 展开项（group 手风琴）、NovaToolbar 工具栏、NovaFab 悬浮按钮组（direction/stagger 级联/hover 契约）。"

                GalleryRow { label: "① NovaTabs + NovaTabPanels：受控联动 / 禁用页跳过 / 箭头溢出滚动" }
                NovaTabs {
                    width: parent.width
                    modelValue: nv.tabVal
                    NovaTab { name: "inbox"; label: "收件箱"; icon: "mdi:email-outline" }
                    NovaTab { name: "starred"; label: "已加星标"; icon: "mdi:star-outline"; alert: "3" }
                    NovaTab { name: "sent"; label: "已发送"; icon: "mdi:send-outline" }
                    NovaTab { name: "spam"; label: "垃圾邮件"; icon: "mdi:alert-octagon-outline"; disable: true }
                    NovaTab { name: "archived"; label: "归档"; icon: "mdi:archive-outline"; alert: true }
                    onUpdateModelValue: (n) => nv.tabVal = n
                }
                NovaTabPanels {
                    width: parent.width; height: 150
                    modelValue: nv.tabVal
                    animated: true
                    NovaTabPanel {
                        name: "inbox"
                        Rectangle {
                            anchors.fill: parent; color: NovaTheme.surfaceAlt; radius: NovaTheme.radiusS
                            Text { anchors.centerIn: parent; text: "收件箱面板 —— 与上方 Tabs 受控联动"; color: NovaTheme.textMuted }
                        }
                    }
                    NovaTabPanel {
                        name: "starred"
                        Rectangle {
                            anchors.fill: parent; color: NovaTheme.surfaceAlt; radius: NovaTheme.radiusS
                            Text { anchors.centerIn: parent; text: "已加星标面板"; color: NovaTheme.textMuted }
                        }
                    }
                    NovaTabPanel {
                        name: "sent"
                        Rectangle {
                            anchors.fill: parent; color: NovaTheme.surfaceAlt; radius: NovaTheme.radiusS
                            Text { anchors.centerIn: parent; text: "已发送面板"; color: NovaTheme.textMuted }
                        }
                    }
                    NovaTabPanel { name: "spam" }
                    NovaTabPanel { name: "archived" }
                }

                GalleryRow { label: "② NovaBreadcrumbs：分隔符 / 激活色（中间条目着色，当前页不着色）/ 禁用条目" }
                NovaBreadcrumbs {
                    width: parent.width
                    NovaBreadcrumbsEl { label: "工作台"; icon: "mdi:home-outline"; onClicked: console.log("home") }
                    NovaBreadcrumbsEl { label: "项目管理" }
                    NovaBreadcrumbsEl { label: "pyside-nova" }
                    NovaBreadcrumbsEl { label: "当前里程碑"; disable: true }
                }
                NovaBreadcrumbs {
                    width: parent.width
                    separator: "›"
                    NovaBreadcrumbsEl { label: "一级" }
                    NovaBreadcrumbsEl { label: "二级" }
                    NovaBreadcrumbsEl { label: "三级"; disable: true }
                }

                GalleryRow { label: "③ NovaStepper：状态图标解析（active>error>done）/ 禁用步骤跳过 / navigation 槽 / 垂直模式" }
                NovaStepper {
                    id: stepper
                    width: parent.width; height: 220
                    modelValue: nv.stepVal
                    animated: true
                    NovaStep { name: "info"; title: "基本信息"; caption: "填写项目资料" }
                    NovaStep { name: "config"; title: "参数配置"; caption: "勾选交付范围"; done: true }
                    NovaStep { name: "review"; title: "评审"; caption: "等待复核"; disable: true }
                    NovaStep { name: "deploy"; title: "交付上线"; caption: "出错自动回滚"; error: true }
                    onUpdateModelValue: (n) => nv.stepVal = n
                    navigation: [
                        NovaStepperNavigation {
                            NovaBtn { text: "上一步"; variant: "outlined"; onClicked: stepper.previous() }
                            NovaBtn { text: "下一步"; onClicked: stepper.next() }
                        }
                    ]
                }
                NovaStepper {
                    width: parent.width; height: 180
                    vertical: true
                    contracted: true
                    NovaStep { title: "环境准备" }
                    NovaStep { title: "依赖安装"; done: true }
                    NovaStep { title: "启动服务" }
                }

                GalleryRow { label: "④ NovaExpansionItem：group 手风琴互斥 / switchToggleSide / expandSeparator" }
                NovaExpansionItem {
                    width: parent.width
                    label: "账户设置"; caption: "昵称 / 邮箱 / 头像"
                    icon: "mdi:account-cog-outline"
                    group: "settings"; expandSeparator: true
                    expanded: nv.expAccount
                    onUpdateModelValue: (v) => nv.expAccount = v
                    Rectangle { color: NovaTheme.surfaceAlt; radius: NovaTheme.radiusS; width: parent.width; height: 44
                        Text { anchors.centerIn: parent; text: "账户设置内容区"; color: NovaTheme.textMuted } }
                }
                NovaExpansionItem {
                    width: parent.width
                    label: "安全与登录"; caption: "两步验证 / 设备管理"
                    icon: "mdi:shield-lock-outline"
                    group: "settings"; switchToggleSide: true
                    expanded: nv.expSecurity
                    onUpdateModelValue: (v) => nv.expSecurity = v
                    Rectangle { color: NovaTheme.surfaceAlt; radius: NovaTheme.radiusS; width: parent.width; height: 44
                        Text { anchors.centerIn: parent; text: "安全设置内容区"; color: NovaTheme.textMuted } }
                }

                GalleryRow { label: "⑤ NovaToolbar + NovaToolbarTitle：inset / shrink" }
                NovaToolbar {
                    width: parent.width
                    radius: NovaTheme.radiusS
                    border.color: NovaTheme.outline; border.width: 1
                    NovaToolbarTitle { text: "项目设置" }
                    NovaBtn { text: "撤销"; variant: "outlined"; size: "sm" }
                    NovaBtn { text: "保存"; size: "sm" }
                }

                GalleryRow { label: "⑥ NovaFab + NovaFabAction：direction 展开方向 / stagger 级联 / external-label（点主钮开合）" }
                Item {
                    width: parent.width; height: 130
                    NovaFab {
                        id: fabDemo
                        x: 40; y: 40
                        direction: "up"
                        stagger: 45
                        label: "新建"
                        modelValue: nv.fabOpen
                        NovaFabAction { icon: "mdi:file-document-outline"; label: "文档"; onClicked: nv.fabTicks++ }
                        NovaFabAction { icon: "mdi:table-large"; label: "表格"; onClicked: nv.fabTicks++ }
                        NovaFabAction { icon: "mdi:presentation"; label: "演示"; disable: true }
                        onUpdateModelValue: (v) => nv.fabOpen = v
                    }
                    Text {
                        x: 130; y: 58
                        text: "动作触发次数：" + nv.fabTicks
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontS
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }


    // ════════════════════════════════════════════════════════════
    // 页面：弹层与反馈 · 四期 Sprint B（菜单/对话框/弹层路由/工具提示/底部面板/加载体系/横幅/观察器）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pagePopup
        Item {
            id: pp
            // 弹层页受控状态
            property bool menuOpen: false
            property bool dlgOpen: false
            property bool sheetOpen: false
            property var dlgReasons: []
            property var sheetPicks: []
            property bool ptrRefreshing: false
            property int ptrCount: 0
            property int barWaiters: 0
            property real barProgress: 0

            GalleryPage {
                title: "弹层与反馈 · 四期 Sprint B"
                desc: "NovaMenu 菜单（auto-close/右键/hover 契约/anchor 定位）、NovaDialogShell 对话框（关闭原因上报 ok/cancel/backdrop/escape/api · persistent shake）、NovaPopupProxy 弹层路由（断点 Menu↔Dialog）、NovaTooltip 工具提示、NovaBottomSheet 底部动作面板（网格/列表）、NovaSpinner 八变体、NovaSkeleton 骨架屏、NovaAjaxBar/NovaLoadingBar 进度、NovaBanner/NovaBar、NovaPullToRefresh 四边拉动、双观察器。"

                GalleryRow { label: "① NovaMenu：点击按钮开菜单 · auto-close 点任意项即关 · contextMenu 右键形态" }
                NovaBtn {
                    id: menuAnchor
                    text: pp.menuOpen ? "关闭菜单" : "打开菜单"
                    icon: "mdi:menu"
                    onClicked: pp.menuOpen = !pp.menuOpen
                }
                Text { text: "（或在下方区域右键）"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                NovaMenu {
                    width: 190
                    modelValue: pp.menuOpen
                    target: menuAnchor
                    autoClose: true
                    NovaItem { label: "打开文件"; icon: "mdi:folder-open-outline"; clickable: true }
                    NovaItem { label: "保存副本"; icon: "mdi:content-save-outline"; clickable: true }
                    NovaItem { label: "导出 PDF"; icon: "mdi:file-pdf-box"; clickable: true }
                    NovaItem { label: "删除"; icon: "mdi:delete-outline"; clickable: true }
                    onUpdateModelValue: (v) => pp.menuOpen = v
                }
                NovaMenu {
                    width: 160
                    contextMenu: true
                    target: pp.parent
                    NovaItem { label: "右键菜单项 A"; clickable: true }
                    NovaItem { label: "右键菜单项 B"; clickable: true }
                }

                GalleryRow { label: "② NovaDialogShell：关闭原因上报（persistent 锁闭 → shake 吸引注意）" }
                NovaBtn {
                    text: "打开对话框"
                    icon: "mdi:card-text-outline"
                    onClicked: pp.dlgOpen = true
                }
                Text {
                    text: pp.dlgReasons.length > 0 ? "最近关闭原因：" + pp.dlgReasons[pp.dlgReasons.length - 1] : "尚未关闭过"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontS
                }
                NovaDialogShell {
                    anchors.fill: pp
                    modelValue: pp.dlgOpen
                    onDismissed: (reason) => pp.dlgReasons = pp.dlgReasons.concat([reason])
                    onUpdateModelValue: (v) => pp.dlgOpen = v

                    Column {
                        width: parent.width
                        spacing: NovaTheme.spacingS
                        Text { text: "保存更改？"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontL; font.bold: true }
                        Text { text: "未保存的修改将会丢失。persistent 模式下按 ESC / 点遮罩会 shake 而不关闭。"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS; wrapMode: Text.WordWrap; width: parent.width }
                        Row {
                            spacing: NovaTheme.spacingS
                            layoutDirection: Qt.RightToLeft
                            anchors.right: parent.right
                            NovaBtn { text: "放弃"; variant: "flat"; onClicked: pp.dlgOpen = false }
                            NovaBtn { text: "保存"; onClicked: pp.dlgOpen = false }
                        }
                    }
                }

                GalleryRow { label: "③ NovaBottomSheet：底部动作面板（列表 / 网格）+ 动作回报" }
                NovaBtn {
                    text: "打开动作面板"
                    icon: "mdi:arrow-up-bold-box-outline"
                    onClicked: pp.sheetOpen = true
                }
                Text {
                    text: pp.sheetPicks.length > 0 ? "已选动作：" + pp.sheetPicks[pp.sheetPicks.length - 1] : "尚未选择"
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontS
                }
                NovaBottomSheet {
                    anchors.fill: pp
                    modelValue: pp.sheetOpen
                    actions: [
                        { label: "拍照上传", icon: "mdi:camera-outline" },
                        { label: "从相册选择", icon: "mdi:image-multiple-outline" },
                        { label: "云端文件", icon: "mdi:cloud-upload-outline" },
                        { label: "取消", icon: "mdi:close", disable: false }
                    ]
                    onActionPicked: (idx) => pp.sheetPicks = pp.sheetPicks.concat(["#" + idx])
                    onUpdateModelValue: (v) => pp.sheetOpen = v
                }

                GalleryRow { label: "④ NovaTooltip：悬停显示（anchor/self/offset 可调）" }
                NovaBtn {
                    text: "悬停我"
                    variant: "outline"
                    NovaTooltip { text: "这是工具提示：anchor bottom middle"; delay: 120 }
                }

                GalleryRow { label: "⑤ 加载体系：NovaSpinner 八变体 × NovaSkeleton × NovaInnerLoading" }
                Flow {
                    width: parent.width
                    spacing: NovaTheme.spacingL
                    Repeater {
                        model: [
                            { v: "ring", n: "ring" }, { v: "ball", n: "ball" }, { v: "dots", n: "dots" },
                            { v: "hourglass", n: "hourglass" }, { v: "gears", n: "gears" }, { v: "grid", n: "grid" },
                            { v: "radio", n: "radio" }, { v: "comment", n: "comment" }
                        ]
                        delegate: Column {
                            spacing: 4
                            NovaSpinner { variant: modelData.v; size: 34; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: modelData.n; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }
                }
                Row {
                    spacing: NovaTheme.spacingL
                    NovaSkeleton { type: "rect"; width: 180; height: 64 }
                    NovaSkeleton { type: "circle"; size: 64 }
                    Column {
                        spacing: 8
                        NovaSkeleton { type: "text"; width: 160 }
                        NovaSkeleton { type: "text"; width: 120 }
                        NovaSkeleton { type: "text"; width: 90 }
                    }
                }
                Rectangle {
                    width: parent.width
                    height: 80
                    radius: NovaTheme.radiusS
                    color: NovaTheme.surfaceAlt
                    border.width: 1
                    border.color: NovaTheme.outline
                    NovaInnerLoading { anchors.fill: parent; showing: true; label: "正在加载" }
                }

                GalleryRow { label: "⑥ NovaAjaxBar：start/increment/stop 命令式进度（多进程计数）" }
                Row {
                    spacing: NovaTheme.spacingS
                    NovaBtn { text: "start"; variant: "flat"; onClicked: { ajaxBar.start(); pp.barWaiters++ } }
                    NovaBtn { text: "increment"; variant: "flat"; onClicked: ajaxBar.increment() }
                    NovaBtn { text: "stop"; variant: "flat"; onClicked: { ajaxBar.stop(); pp.barWaiters = Math.max(0, pp.barWaiters - 1) } }
                    Text { text: "等待进程：" + pp.barWaiters; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS; anchors.verticalCenter: parent.verticalCenter }
                }
                NovaAjaxBar { id: ajaxBar; width: parent.width; height: 3; position: "top" }
                NovaBtn {
                    text: "NovaLoadingBar 服务（命令式顶部进度 2 秒）"
                    variant: "flat"
                    onClicked: {
                        NovaLoadingBar.start()
                        svcTimer.restart()
                    }
                }
                Timer {
                    id: svcTimer
                    interval: 2000
                    onTriggered: NovaLoadingBar.stop()
                }

                GalleryRow { label: "⑦ NovaBanner / NovaBar：横幅与顶栏" }
                NovaBanner {
                    width: parent.width
                    rounded: true
                    Rectangle { width: 36; height: 36; radius: 18; color: NovaTheme.primary }
                    Column {
                        width: parent.width - 200
                        Text { text: "v0.14.0 已发布"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontM; font.weight: Font.Medium }
                        Text { text: "弹层与反馈体系 18 个新类型上线，含关闭原因上报与四边拉动刷新。"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                    }
                    NovaBtn { text: "查看"; variant: "flat" }
                    NovaBtn { text: "关闭"; variant: "flat" }
                }
                NovaBar {
                    width: parent.width
                    Text { text: "NovaBar 顶栏"; color: NovaTheme.textOnPrimary; font.pixelSize: NovaTheme.fontM }
                    Item { width: 8; height: 1 }
                    NovaIcon { icon: "mdi:magnify"; color: NovaTheme.textOnPrimary; size: 18 }
                    NovaIcon { icon: "mdi:dots-vertical"; color: NovaTheme.textOnPrimary; size: 18 }
                }

                GalleryRow { label: "⑧ NovaPullToRefresh：四边拉动（演示 top 边向下拉触发）+ 双观察器" }
                Rectangle {
                    width: parent.width
                    height: 160
                    radius: NovaTheme.radiusS
                    border.width: 1
                    border.color: NovaTheme.outline
                    clip: true
                    NovaPullToRefresh {
                        anchors.fill: parent
                        refreshing: pp.ptrRefreshing
                        onRefresh: {
                            pp.ptrCount++
                            ptrTimer.restart()
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: NovaTheme.surfaceAlt
                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "在此区域按住向下拉"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                                Text { text: "已刷新 " + pp.ptrCount + " 次"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontM; font.bold: true }
                            }
                        }
                    }
                    Timer {
                        id: ptrTimer
                        interval: 1200
                        onTriggered: pp.ptrRefreshing = false
                    }
                }
                Row {
                    spacing: NovaTheme.spacingL
                    Column {
                        spacing: 4
                        Text { text: "NovaResizeObserver"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                        Text { text: "宿主宽度：" + obsRoot.width + "px"; color: NovaTheme.textColor; font.pixelSize: NovaTheme.fontM }
                    }
                }
            }

            // ResizeObserver 观测宿主
            NovaResizeObserver {
                id: obsRoot
                target: pp
                onResize: (w, h) => { /* 宿主尺寸变化（演示绑定读取） */ }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：长尾组件 · 五期 Sprint A（Editor/SlideItem/Morph/IconGenie/MCP）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageLongtail
        Item {
            id: lt
            property bool morphCard: true          // true=卡片形态 / false=详情形态
            property int slideCount: 0

            GalleryPage {
                title: "长尾组件 · 五期 Sprint A"
                desc: "NovaEditor 轻量富文本（工具栏配置/格式化命令/HTML 导出——QML 无 contenteditable，以标记编辑实现同语义）、NovaSlideItem 滑动操作项（左滑右滑动作面板）、NovaMorph 元素形变（v-morph group 语义，ghost 几何过渡）、NovaIconGenie 图标全套生成 CLI、Nova MCP server（离线 AI 文档查询六工具，对标 @quasar/mcp 2.33 新品类）。"

                GalleryRow { label: "① NovaEditor：工具栏命令编辑 · 底部实时 HTML 导出" }
                NovaEditor {
                    id: ltEd
                    width: Math.min(640, parent.width)
                    minHeight: 90
                    placeholder: "写点什么…（选中后点工具栏加粗/标题/列表）"
                    modelValue: "# 发布计划\n- 图标全套已生成\n- MCP server 已接入"
                    onUpdateModelValue: (v) => { ltEd.modelValue = v; htmlOut.text = ltEd.toHtml() }
                    Component.onCompleted: htmlOut.text = ltEd.toHtml()
                }
                Text {
                    width: Math.min(640, parent.width)
                    text: "HTML 导出实时预览："
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                }
                Rectangle {
                    width: Math.min(640, parent.width)
                    height: 56
                    radius: NovaTheme.radiusS
                    color: NovaTheme.surfaceAlt
                    clip: true
                    Text {
                        id: htmlOut
                        x: 8
                        width: parent.width - 16
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                        wrapMode: Text.WordWrap
                    }
                }

                GalleryRow { label: "② NovaSlideItem：左右滑动露出动作面板（拖拽跟手 + 越阈值吸附）" }
                Item {
                    width: Math.min(480, parent.width)
                    height: 56
                    NovaSlideItem {
                        id: slideDemo
                        width: parent.width
                        height: 56
                        leftSlot: Component {
                            Rectangle {
                                anchors.fill: parent
                                color: NovaTheme.secondary
                                Text { anchors.centerIn: parent; text: "收藏"; color: NovaTheme.textOnPrimary }
                            }
                        }
                        rightSlot: Component {
                            Rectangle {
                                anchors.fill: parent
                                color: NovaTheme.negative
                                Text { anchors.centerIn: parent; text: "删除"; color: NovaTheme.textOnPrimary }
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            radius: NovaTheme.radiusS
                            color: NovaTheme.surface
                            border.width: 1
                            border.color: NovaTheme.outline
                            Text { anchors.centerIn: parent; text: "← 拖我 · 第 " + lt.slideCount + " 次动作"; color: NovaTheme.textColor }
                        }
                        onLeftAction: lt.slideCount++
                        onRightAction: lt.slideCount++
                    }
                }

                GalleryRow { label: "③ NovaMorph：卡片 ⇄ 详情形变（v-morph group 语义 · ghost 几何过渡）" }
                Item {
                    width: Math.min(480, parent.width)
                    height: 130
                    clip: true

                    Rectangle {
                        id: morphCardFace
                        visible: lt.morphCard
                        width: 180; height: 110; x: 10; y: 8
                        radius: NovaTheme.radiusM
                        color: NovaTheme.surfaceAlt
                        border.width: 1
                        border.color: NovaTheme.primary
                        Column {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "新版本通知"; color: NovaTheme.textColor; font.bold: true }
                            NovaBtn { text: "展开详情"; anchors.horizontalCenter: parent.horizontalCenter; onClicked: lt.morphCard = !lt.morphCard }
                        }
                        NovaMorph { group: "card"; target: morphCardFace; duration: 260; tint: NovaTheme.primary }
                    }
                    Rectangle {
                        id: morphDetailFace
                        visible: !lt.morphCard
                        width: 420; height: 110; x: 10; y: 8
                        radius: NovaTheme.radiusM
                        color: NovaTheme.surface
                        border.width: 1
                        border.color: NovaTheme.primary
                        Column {
                            anchors { verticalCenter: parent.verticalCenter; left: parent.left; margins: 12 }
                            spacing: 6
                            Text { text: "v0.15.0 长尾组件已交付"; color: NovaTheme.textColor; font.bold: true }
                            Text { text: "Editor / SlideItem / Morph / IconGenie / MCP server"; color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontS }
                            NovaBtn { text: "收起"; onClicked: lt.morphCard = !lt.morphCard }
                        }
                        NovaMorph { group: "card"; target: morphDetailFace; duration: 260; tint: NovaTheme.primary }
                    }
                }
                Text {
                    text: "点「展开详情 / 收起」触发 group 形变：旧形态隐藏、ghost 从旧几何动画至新几何。"
                    color: NovaTheme.textMuted; font.pixelSize: NovaTheme.fontXS
                }

                GalleryRow { label: "④ NovaIconGenie + Nova MCP server：生态工具（CLI 演示口径）" }
                NovaCard {
                    width: Math.min(640, parent.width)
                    flat: true
                    NovaCardSection {
                        Column {
                            spacing: 6
                            Text { text: "图标全套生成（对标 @quasar/icongenie）"; color: NovaTheme.textColor; font.bold: true }
                            Text {
                                text: "python scripts/gen_icons.py source.png --out icons/ --background \"#FFF\" --splash\n→ favicon ×4 + apple-touch ×6 + android ×7 + ios 全档 + splash ×6（37 产物 + icongenie-report.json）"
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                                font.family: "monospace"
                            }
                            Item { width: 1; height: 6 }
                            Text { text: "AI-ready 文档包 + MCP server（对标 @quasar/mcp · 2.33 新品类）"; color: NovaTheme.textColor; font.bold: true }
                            Text {
                                text: "python scripts/gen_apidocs.py          → docs/ai/（120 类型 API + 10 页离线文档 + 指纹）\npython scripts/nova_mcp.py --project . → stdio MCP server\n六工具：search_docs / list_pages / get_page / list_api / get_api / check_updates"
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                                font.family: "monospace"
                            }
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════
    // 页面：无障碍 a11y（AA 派生令牌 / 焦点环 / 键盘全路径 / 状态播报）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageA11y
        Item {
            id: a11yPage
            GalleryPage {
                title: "无障碍 a11y · WCAG 2.1 AA"
                desc: "0.16.0 新增：NovaA11y 基座（WCAG 对比度数学 + AA 兜底派生 + 焦点可见性语义 + 状态播报）、"
                      + "NovaFocusRing 焦点环、NovaLiveRegion 播报区；123 个导出类型逐一登记 a11y 契约（32 interactive / 28 semantic / 63 decorative），"
                      + "门禁命令 python scripts/check_a11y.py（缺项即阻断交付）。"

                GalleryRow { label: "① AA 兜底派生：语义色当文字用时自动压到 4.5:1，本色仍用于填充面" }

                Rectangle {
                    width: parent.width
                    height: 132
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.color: NovaTheme.outline

                    Row {
                        id: swatches
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        spacing: NovaTheme.spacingL

                        Repeater {
                            model: [
                                { name: "primary", base: NovaTheme.primary, safe: NovaTheme.primaryText },
                                { name: "secondary", base: NovaTheme.secondary, safe: NovaTheme.secondaryText },
                                { name: "accent", base: NovaTheme.accent, safe: NovaTheme.accentText },
                                { name: "positive", base: NovaTheme.positive, safe: NovaTheme.positiveText },
                                { name: "negative", base: NovaTheme.negative, safe: NovaTheme.negativeText },
                                { name: "warning", base: NovaTheme.warning, safe: NovaTheme.warningText },
                                { name: "info", base: NovaTheme.info, safe: NovaTheme.infoText }
                            ]

                            delegate: Column {
                                required property var modelData
                                spacing: 6

                                Row {
                                    spacing: 4
                                    Rectangle {
                                        width: 34; height: 22; radius: 5
                                        color: modelData.base
                                    }
                                    Rectangle {
                                        width: 34; height: 22; radius: 5
                                        color: modelData.safe
                                    }
                                }
                                Text {
                                    text: modelData.name
                                    color: NovaTheme.textColor
                                    font.pixelSize: NovaTheme.fontXS
                                }
                                Text {
                                    text: "本色 " + NovaA11y.contrast(modelData.base, NovaTheme.a11yBase).toFixed(2)
                                    color: NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontXS
                                }
                                Text {
                                    text: "AA " + NovaA11y.contrast(modelData.safe, NovaTheme.a11yBase).toFixed(2)
                                    color: NovaTheme.positiveText
                                    font.pixelSize: NovaTheme.fontXS
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                GalleryRow { label: "② 焦点环：按 Tab 逐个走查——键盘模态才画环，鼠标点击不画（focus-visible）" }

                Rectangle {
                    width: parent.width
                    height: 96
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.color: NovaTheme.outline

                    Row {
                        anchors.centerIn: parent
                        spacing: NovaTheme.spacingM

                        NovaBtn { text: "主按钮"; onClicked: a11yPage.send("已保存草稿") }
                        NovaBtn { text: "描边"; variant: "outlined"; onClicked: a11yPage.send("已发布") }
                        NovaBtn { text: "扁平"; variant: "flat" }
                        NovaBtn { text: "禁用"; disable: true }
                        NovaCheckbox { label: "接收通知"; modelValue: true }
                        NovaToggle { label: "深色跟随"; modelValue: false }
                        NovaInput { width: 150; label: "邮箱"; placeholder: "you@corp.com" }
                        NovaSlider { width: 120; a11yLabel: "音量"; modelValue: 40 }
                    }
                }

                GalleryRow { label: "③ 键盘全路径：Enter/Space 激活、方向键导航、Esc 归位（无需鼠标）" }

                Rectangle {
                    width: parent.width
                    height: 150
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.color: NovaTheme.outline

                    Column {
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        spacing: NovaTheme.spacingS

                        Row {
                            spacing: NovaTheme.spacingS
                            NovaChip { text: "可点标签"; clickable: true; onClicked: a11yPage.send("标签被激活") }
                            NovaChip { text: "可删标签"; removable: true }
                            NovaChip { text: "静态标签" }
                        }
                        NovaPagination { page: a11yPage.page; pages: 6
                                          onPageRequested: (p) => a11yPage.page = p }
                        Row {
                            spacing: NovaTheme.spacingS
                            NovaBtn { text: "上一页"; variant: "flat"; onClicked: a11yPage.page = Math.max(1, a11yPage.page - 1) }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "第 " + a11yPage.page + " / 6 页（分页器聚焦后按 ← → 也可翻页）"
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontS
                            }
                        }
                    }
                }

                GalleryRow { label: "④ 状态播报：NovaA11y.notice → NovaLiveRegion 说给屏读器（WCAG 4.1.3）" }

                Rectangle {
                    width: parent.width
                    height: 96
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.color: NovaTheme.outline

                    Row {
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        spacing: NovaTheme.spacingM

                        NovaBtn { text: "播报一条状态"; onClicked: a11yPage.send("数据已同步，共 1,240 条") }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4
                            Text {
                                text: "已播报 " + NovaA11y.announcementCount + " 次"
                                color: NovaTheme.textColor
                                font.pixelSize: NovaTheme.fontS
                            }
                            Text {
                                text: NovaA11y.lastAnnouncement === "" ? "（尚无播报）" : "最近：" + NovaA11y.lastAnnouncement
                                color: NovaTheme.textMuted
                                font.pixelSize: NovaTheme.fontXS
                            }
                        }
                    }
                }

                GalleryRow { label: "⑤ 契约矩阵与门禁：123 类型逐项登记，缺项阻断交付" }

                Rectangle {
                    width: parent.width
                    height: 84
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surfaceAlt
                    border.color: NovaTheme.outline

                    Column {
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        spacing: 4
                        Text {
                            text: "interactive 32 · semantic 28 · decorative 63   →   docs/A11Y_MATRIX.md（生成物，勿手改）"
                            color: NovaTheme.textColor
                            font.pixelSize: NovaTheme.fontS
                        }
                        Text {
                            text: "python scripts/check_a11y.py --matrix docs/A11Y_MATRIX.md   # 静态门禁\n"
                                  + "pytest tests/test_a11y.py -q                                  # 20 项：数学 / 令牌 / 角色矩阵 / 键盘 / 焦点环 / 播报"
                            color: NovaTheme.textMuted
                            font.pixelSize: NovaTheme.fontXS
                            font.family: "monospace"
                        }
                    }
                }
            }

            // 页面内状态：分页受控值 + 播报通道
            property int page: 1
            function send(text) { NovaA11y.notice(text) }
        }
    }

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

    // ════════════════════════════════════════════════════════════
    // 页面：国际化 i18n（NovaI18n · locale 切换 / 复数 / 格式化 / RTL 镜像）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageI18n
        Item {
            id: i18nPage
            objectName: "pageI18n"

            // 演示 addBundle 运行时热注入：de/ja/ar/ru 词典不在内置包里，
            // 应用可在任意时机注入（幂等覆盖）；ar 复数六类别、ru 三类别
            Component.onCompleted: {
                NovaI18n.addBundle("de-DE", {
                    confirm: "Bestätigen", cancel: "Abbrechen", submit: "Absenden",
                    save: "Speichern", close: "Schließen", search: "Suchen",
                    selected: "{n} ausgewählt", emptyText: "Keine Daten",
                    dayAgo: "vor {n} Tag", monthAgo: "vor {n} Monat", yearAgo: "vor {n} Jahr"
                })
                NovaI18n.addPluralBundle("de-DE", {
                    apple: { one: "{n} Apfel", other: "{n} Äpfel" },
                    message: { one: "{n} Nachricht", other: "{n} Nachrichten" },
                    dayAgo: { one: "vor {n} Tag", other: "vor {n} Tagen" }
                })
                NovaI18n.addBundle("ja-JP", {
                    confirm: "確認", cancel: "キャンセル", submit: "送信",
                    save: "保存", close: "閉じる", search: "検索",
                    selected: "{n} 件選択", emptyText: "データがありません",
                    dayAgo: "{n}日前", monthAgo: "{n}ヶ月前", yearAgo: "{n}年前"
                })
                NovaI18n.addPluralBundle("ja-JP", {
                    apple: { other: "りんご {n} 個" },
                    message: { other: "メッセージ {n} 件" },
                    dayAgo: { other: "{n}日前" }
                })
                NovaI18n.addBundle("ru-RU", {
                    confirm: "Подтвердить", cancel: "Отмена", submit: "Отправить",
                    save: "Сохранить", close: "Закрыть", search: "Поиск",
                    selected: "Выбрано: {n}", emptyText: "Нет данных",
                    dayAgo: "{n} дн. назад", monthAgo: "{n} мес. назад", yearAgo: "{n} г. назад"
                })
                NovaI18n.addPluralBundle("ru-RU", {
                    apple: { one: "{n} яблоко", few: "{n} яблока", many: "{n} яблок", other: "{n} яблока" },
                    message: { one: "{n} сообщение", few: "{n} сообщения", many: "{n} сообщений", other: "{n} сообщения" },
                    dayAgo: { one: "{n} день назад", few: "{n} дня назад", many: "{n} дней назад", other: "{n} дня назад" }
                })
                NovaI18n.addBundle("ar-EG", {
                    confirm: "تأكيد", cancel: "إلغاء", submit: "إرسال",
                    save: "حفظ", close: "إغلاق", search: "بحث",
                    selected: "تم اختيار {n}", emptyText: "لا توجد بيانات",
                    dayAgo: "قبل {n} يوم", monthAgo: "قبل {n} شهر", yearAgo: "قبل {n} سنة"
                })
                NovaI18n.addPluralBundle("ar-EG", {
                    apple: { zero: "لا تفاحات", one: "تفاحة واحدة", two: "تفاحتان",
                             few: "{n} تفاحات", many: "{n} تفاحة", other: "{n} تفاحة" },
                    message: { zero: "لا رسائل", one: "رسالة واحدة", two: "رسالتان",
                               few: "{n} رسائل", many: "{n} رسالة", other: "{n} رسالة" },
                    dayAgo: { zero: "اليوم", one: "قبل يوم", two: "قبل يومين",
                              few: "قبل {n} أيام", many: "قبل {n} يومًا", other: "قبل {n} يوم" }
                })
            }

            GalleryPage {
                title: "国际化 i18n · NovaI18n"
                desc: "0.16.1 新增：NovaI18n 服务单例（对标 Quasar Lang 插件 + vue-i18n 语义）——locale 切换、词典 t() 插值与缺词回落、"
                      + "CLDR 复数规则 tp()（en/zh/ja/ru/ar/cs/pl 七语系）、数字/货币/日期/相对时间本地化格式化、RTL 语言集合判定（isRtl/direction）；"
                      + "RTL 布局镜像由 LayoutMirroring + 逻辑侧/物理侧分离双轨承载（Drawer/SlideItem/Pagination/Breadcrumbs 已适配）。"

                GalleryRow { label: "① locale 切换：点击按钮切全局 locale，下方所有绑定自动重求值（ar-EG 触发 RTL 镜像）" }

                Rectangle {
                    width: parent.width
                    height: 108
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.color: NovaTheme.outline

                    Column {
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        spacing: NovaTheme.spacingS

                        Row {
                            spacing: NovaTheme.spacingS
                            Repeater {
                                model: ["en-US", "zh-CN", "de-DE", "ja-JP", "ru-RU", "ar-EG"]
                                delegate: NovaBtn {
                                    required property string modelData
                                    text: modelData
                                    variant: NovaI18n.locale === modelData ? "filled" : "outline"
                                    onClicked: NovaI18n.setLocale(modelData)
                                }
                            }
                        }

                        Rectangle {
                            width: 340
                            height: 30
                            radius: NovaTheme.radiusS
                            color: NovaTheme.surfaceAlt
                            Text {
                                x: 10
                                anchors.verticalCenter: parent.verticalCenter
                                // 引用 locale 属性确保 locale 变化时本行重求值
                                text: "locale = " + NovaI18n.locale
                                      + "   baseLang = " + NovaI18n.baseLang
                                      + "   direction = " + NovaI18n.direction
                                color: NovaI18n.isRtl ? NovaTheme.warning : NovaTheme.positiveText
                                font.pixelSize: NovaTheme.fontS
                                font.bold: true
                            }
                        }
                    }
                }

                GalleryRow { label: "② t() 词典翻译 + 插值 + 缺词回落（not.in.bundle 原样返回 key）" }

                Rectangle {
                    width: parent.width
                    height: 128
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.color: NovaTheme.outline

                    Grid {
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        columns: 3
                        columnSpacing: NovaTheme.spacingL
                        rowSpacing: NovaTheme.spacingS

                        Repeater {
                            model: [
                                { k: "confirm", demo: "NovaI18n.t(\"confirm\")" },
                                { k: "cancel",  demo: "t(\"cancel\")" },
                                { k: "save",    demo: "t(\"save\")" },
                                { k: "search",  demo: "t(\"search\")" },
                                { k: "selected", demo: "t(\"selected\", {n: 5})" },
                                { k: "not.in.bundle", demo: "t(\"not.in.bundle\")" }
                            ]
                            delegate: Column {
                                required property var modelData
                                spacing: 2
                                Text {
                                    text: modelData.demo
                                    color: NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontXS
                                    font.family: "Monospace"
                                }
                                Text {
                                    text: modelData.k.indexOf("{n}") !== -1
                                          ? NovaI18n.t(modelData.k, { n: 5 })
                                          : NovaI18n.t(modelData.k)
                                    color: modelData.k === "not.in.bundle" ? NovaTheme.warning : NovaTheme.textColor
                                    font.pixelSize: NovaTheme.fontM
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                GalleryRow { label: "③ tp() CLDR 复数：同一 key 随 locale 切换复数类别（zh 恒 other / en one-other / ru one-few-many / ar 六类别）" }

                Rectangle {
                    width: parent.width
                    height: 190
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.color: NovaTheme.outline

                    Column {
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        spacing: 6

                        Repeater {
                            model: [0, 1, 2, 3, 5, 11, 21, 100]
                            delegate: Row {
                                required property int modelData
                                width: parent.width
                                spacing: NovaTheme.spacingM
                                Rectangle {
                                    width: 46; height: 24; radius: 5
                                    color: NovaTheme.surfaceAlt
                                    border.color: NovaTheme.outline
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: NovaTheme.textColor
                                        font.pixelSize: NovaTheme.fontS
                                        font.bold: true
                                    }
                                }
                                Text {
                                    width: 130
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "cat = " + NovaI18n.pluralCategory(modelData)
                                    color: NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontXS
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: NovaI18n.tp("apple", modelData)
                                    color: NovaTheme.textColor
                                    font.pixelSize: NovaTheme.fontM
                                }
                            }
                        }
                    }
                }

                GalleryRow { label: "④ 格式化：数字分组 / 货币符号 / 日期时间 / 相对时间——分隔符表与符号表随 locale（de 千分位是点、ar 用阿拉伯分隔符）" }

                Rectangle {
                    width: parent.width
                    height: 168
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.color: NovaTheme.outline

                    Grid {
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        columns: 2
                        columnSpacing: NovaTheme.spacingXL
                        rowSpacing: NovaTheme.spacingS

                        Repeater {
                            model: [
                                { demo: "formatNumber(1234567.89)", calc: function() { return NovaI18n.formatNumber(1234567.89) } },
                                { demo: "formatNumber(1234.5, 2)",  calc: function() { return NovaI18n.formatNumber(1234.5, 2) } },
                                { demo: "formatCurrency(9876.54)",  calc: function() { return NovaI18n.formatCurrency(9876.54) } },
                                { demo: "formatDate(now, \"shortDate\")", calc: function() { return NovaI18n.formatDate(new Date(), "shortDate") } },
                                { demo: "formatDate(now, \"longDateTime\")", calc: function() { return NovaI18n.formatDate(new Date(), "longDateTime") } },
                                { demo: "formatRelative(now - 3d)", calc: function() { return NovaI18n.formatRelative(new Date(Date.now() - 3 * 86400000), new Date()) } }
                            ]
                            delegate: Row {
                                required property var modelData
                                width: (parent.width - parent.columnSpacing) / 2
                                spacing: 8
                                Text {
                                    width: parent.width * 0.52
                                    text: modelData.demo
                                    color: NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontXS
                                    font.family: "Monospace"
                                    elide: Text.ElideRight
                                }
                                Text {
                                    width: parent.width * 0.48
                                    text: modelData.calc()
                                    color: NovaTheme.textColor
                                    font.pixelSize: NovaTheme.fontS
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                GalleryRow { label: "⑤ RTL 镜像：切到 ar-EG 后——Row 顺序翻转（LayoutMirroring）、Drawer/SlideItem 逻辑侧换边、Pagination 箭头取反" }

                Rectangle {
                    width: parent.width
                    height: 96
                    radius: NovaTheme.radiusM
                    color: NovaTheme.surface
                    border.color: NovaTheme.outline

                    Row {
                        LayoutMirroring.enabled: NovaTheme.isRtl
                        anchors.fill: parent
                        anchors.margins: NovaTheme.spacingM
                        spacing: NovaTheme.spacingM

                        Repeater {
                            model: ["A", "B", "C", "D"]
                            delegate: Rectangle {
                                required property string modelData
                                width: 52; height: 52; radius: 8
                                color: NovaTheme.primary
                                opacity: 0.85
                                Text { anchors.centerIn: parent; text: parent.modelData; color: "#fff"; font.pixelSize: NovaTheme.fontL; font.bold: true }
                            }
                        }

                        Rectangle {
                            width: 150; height: 52; radius: 8
                            color: NovaTheme.surfaceAlt
                            border.color: NovaTheme.outline
                            Column {
                                anchors.centerIn: parent
                                spacing: 2
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: NovaI18n.direction
                                    color: NovaI18n.isRtl ? NovaTheme.warning : NovaTheme.positiveText
                                    font.pixelSize: NovaTheme.fontM
                                    font.bold: true
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: NovaI18n.isRtl ? "镜像已启用" : "正常布局"
                                    color: NovaTheme.textMuted
                                    font.pixelSize: NovaTheme.fontXS
                                }
                            }
                        }
                    }
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

    // ════════════════════════════════════════════════════════════
    // 页面：NovaMarkdown 文档渲染器（1.4.0 · 零依赖 Qt 原生 MarkdownText）
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageMarkdown
        Item {
            id: mdPage
            objectName: "pageMarkdown"
            property string feedback: "点击文档中的链接试试"

            readonly property string demoText:
                "# NovaMarkdown\n\n" +
                "**加粗** · *斜体* · ~~删除线~~ · `行内代码` · [安全链接](https://example.com)\n\n" +
                "## 表格\n\n" +
                "| 能力 | 状态 |\n| :--- | :---: |\n| 零依赖 | 支持 |\n| 内置大纲 | 支持 |\n\n" +
                "## 列表\n\n" +
                "- [x] 分块渲染\n- [x] 锚点跳转\n- [ ] 虚拟滚动（扩展点）\n\n" +
                "```python\ndef hello():\n    return 42\n```\n\n" +
                "### 安全\n\n" +
                "[危险链接](javascript:alert(1))\n\n" +
                "## 主题\n\n" +
                "切换明暗按钮，正文颜色随 NovaTheme 令牌联动。\n"

            GalleryPage {
                title: "NovaMarkdown 文档渲染"
                desc: "1.4.0 新增公共类型：零第三方依赖，Qt 原生 Text.MarkdownText + NovaTheme 令牌 + NovaScrollArea；内置大纲侧栏、锚点跳转、危险协议拦截。"

                GalleryRow { label: "实时文档 · 大纲 / 边框 / 明暗可切" }

                Row {
                    width: parent.width
                    spacing: NovaTheme.spacingM

                    NovaBtn {
                        text: mdDoc.showToc ? "隐藏大纲" : "显示大纲"
                        variant: "flat"
                        size: "sm"
                        onClicked: mdDoc.showToc = !mdDoc.showToc
                    }
                    NovaBtn {
                        text: mdDoc.outlined ? "去掉边框" : "显示边框"
                        variant: "flat"
                        size: "sm"
                        onClicked: mdDoc.outlined = !mdDoc.outlined
                    }
                    NovaBtn {
                        text: "切换明暗"
                        variant: "flat"
                        size: "sm"
                        onClicked: NovaTheme.toggleDark()
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: mdPage.feedback
                        color: NovaTheme.textMuted
                        font.pixelSize: NovaTheme.fontXS
                    }
                }

                NovaMarkdown {
                    id: mdDoc
                    width: parent.width
                    height: 460
                    showToc: true
                    markdown: mdPage.demoText
                    onLinkClicked: function(u) { mdPage.feedback = "安全链接：" + u }
                    onLinkBlocked: function(u) { mdPage.feedback = "已拦截：" + u }
                    onTocReady: function(items) { mdPage.feedback = "大纲条目 " + items.length + " 项" }
                }
            }
        }
    }
}
