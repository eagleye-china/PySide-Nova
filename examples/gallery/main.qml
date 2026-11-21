// examples/gallery/main.qml
// pyside-nova 组件画廊：侧边导航 + 8 页面覆盖全部组件，明暗一键切换、断点实时监控
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
                text: "Gallery 0.2.0"
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
                model: ListModel {
                    ListElement { label: "概览";               icon: "mdi:home-variant-outline" }
                    ListElement { label: "NovaBtn 按钮";       icon: "mdi:gesture-tap" }
                    ListElement { label: "NovaCard 卡片";      icon: "mdi:card-outline" }
                    ListElement { label: "NovaChip 标签";      icon: "mdi:tag-outline" }
                    ListElement { label: "NovaAvatar 头像";    icon: "mdi:account-circle-outline" }
                    ListElement { label: "NovaBadge 徽标";     icon: "mdi:numeric-9-plus" }
                    ListElement { label: "NovaIcon 图标";      icon: "mdi:shape-outline" }
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
        sourceComponent: [pageOverview, pageBtn, pageCard, pageChip,
                          pageAvatar, pageBadge, pageIcon, pageTheme][nav.currentIndex]
    }

    Rectangle { id: nav; property int currentIndex: 0; visible: false }

    // ════════════════════════════════════════════════════════════
    // 页面：概览
    // ════════════════════════════════════════════════════════════
    Component {
        id: pageOverview
        Item {
            GalleryPage {
                title: "概览 Overview"
                desc: "pyside-nova 首批 12 个组件全部实机展示。所有组件共享 NovaTheme 三级设计令牌，明暗主题一键切换。"

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
}
