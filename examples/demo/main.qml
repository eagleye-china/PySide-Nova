// examples/demo/main.qml
// pyside-nova 精简演示主窗口：首批组件综合展示
// pyside-nova 第一批组件演示
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Nova.Services
import Nova.Controls
import Nova.Behaviors

ApplicationWindow {
    id: window
    width: 1000
    height: 780
    visible: true
    title: "pyside-nova · Demo"
    color: NovaTheme.page

    // 断点体系接入（对标 Quasar Screen 插件）+ 离线图标包自动启用
    // （单例属性不能在对象体内声明式绑定，需在 onCompleted 中赋值）
    Component.onCompleted: {
        NovaScreen.source = window
        if (typeof novaIconLocalRoot !== "undefined" && novaIconLocalRoot !== "")
            NovaTheme.iconLocalRoot = novaIconLocalRoot
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: NovaTheme.spacingL
        spacing: NovaTheme.spacingM

        // ── 顶栏 ──────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "pyside-nova"
                font.family: NovaTheme.fontFamily
                font.pixelSize: NovaTheme.fontXL
                font.bold: true
                color: NovaTheme.textColor
            }
            Text {
                text: "0.6.0 · Quasar-style components for PySide6"
                font.pixelSize: NovaTheme.fontS
                color: NovaTheme.textMuted
            }
            NovaSpace { }
            NovaBtn {
                text: NovaTheme.isDark ? "☀ 浅色" : "🌙 深色"
                variant: "outlined"
                onClicked: NovaTheme.toggleDark()
            }
            NovaBtn {
                icon: "🎨"
                round: true
                onClicked: NovaTheme.setBrand(Qt.hsla(Math.random(), 0.65, 0.55, 1))
            }
        }

        // ── 组件展示区 ────────────────────────────────────
        ScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: scroll.availableWidth
                spacing: NovaTheme.spacingL

                // ── NovaBtn ────────────────────────────────
                NovaCard {
                    Layout.fillWidth: true
                    NovaCardSection {
                        Column {
                            width: parent.width
                            spacing: NovaTheme.spacingM

                            Text {
                                text: "NovaBtn · 按钮"
                                font.bold: true
                                font.pixelSize: NovaTheme.fontL
                                color: NovaTheme.textColor
                            }
                            Text {
                                width: parent.width
                                text: "variant: filled / outlined / flat · size: sm / md / lg · 内置水波纹、loading、disable、键盘触发"
                                font.pixelSize: NovaTheme.fontS
                                color: NovaTheme.textMuted
                                wrapMode: Text.WordWrap
                            }
                            Row {
                                spacing: NovaTheme.spacingM
                                NovaBtn { text: "主操作" }
                                NovaBtn { text: "次操作"; variant: "outlined" }
                                NovaBtn { text: "幽灵按钮"; variant: "flat" }
                                NovaBtn { icon: "＋"; round: true }
                            }
                            Row {
                                spacing: NovaTheme.spacingM
                                NovaBtn { text: "小号 sm"; size: "sm" }
                                NovaBtn { text: "加载中…"; loading: true }
                                NovaBtn { text: "禁用"; disable: true }
                                NovaBtn { icon: "🗑"; text: "删除"; tint: NovaTheme.negative }
                            }
                        }
                    }
                }

                // ── NovaChip ───────────────────────────────
                NovaCard {
                    Layout.fillWidth: true
                    NovaCardSection {
                        Column {
                            width: parent.width
                            spacing: NovaTheme.spacingM

                            Text {
                                text: "NovaChip · 标签"
                                font.bold: true
                                font.pixelSize: NovaTheme.fontL
                                color: NovaTheme.textColor
                            }
                            Flow {
                                width: parent.width
                                spacing: NovaTheme.spacingS

                                NovaChip { text: "QML" }
                                NovaChip { text: "PySide6"; filled: true; tint: NovaTheme.secondary }
                                NovaChip { icon: "🔥"; text: "带图标" }
                                NovaChip { text: "描边"; outlined: true }
                                NovaChip {
                                    id: selectChip
                                    text: "点我选中"
                                    clickable: true
                                    onClicked: selectChip.selected = !selectChip.selected
                                }
                                NovaChip {
                                    id: removeChip
                                    text: "点 ✕ 移除我"
                                    removable: true
                                    onRemoved: removeChip.destroy()
                                }
                                NovaChip { text: "dense"; dense: true }
                            }
                        }
                    }
                }

                // ── NovaAvatar ─────────────────────────────
                NovaCard {
                    Layout.fillWidth: true
                    NovaCardSection {
                        Column {
                            width: parent.width
                            spacing: NovaTheme.spacingM

                            Text {
                                text: "NovaAvatar · 头像"
                                font.bold: true
                                font.pixelSize: NovaTheme.fontL
                                color: NovaTheme.textColor
                            }
                            Row {
                                spacing: NovaTheme.spacingM
                                NovaAvatar { text: "N" }
                                NovaAvatar { text: "nova"; size: 54 }
                                NovaAvatar { text: "Q"; size: 36; square: true; tint: NovaTheme.secondary }
                                NovaAvatar { text: "🔥" }
                                NovaAvatar { text: "M"; size: 64 }
                            }
                        }
                    }
                }

                // ── NovaScreen · 断点 ───────────────────────
                NovaCard {
                    Layout.fillWidth: true
                    NovaCardSection {
                        Column {
                            width: parent.width
                            spacing: NovaTheme.spacingM

                            Text {
                                text: "NovaScreen · 断点（对标 Quasar Screen 插件）"
                                font.bold: true
                                font.pixelSize: NovaTheme.fontL
                                color: NovaTheme.textColor
                            }
                            Text {
                                text: "width: " + NovaScreen.width + "px · 当前断点: "
                                      + NovaScreen.name + " · 拖拽窗口边缘试试 →"
                                font.pixelSize: NovaTheme.fontS
                                color: NovaTheme.primary
                                font.bold: true
                            }
                            Flow {
                                width: parent.width
                                spacing: NovaTheme.spacingS

                                NovaChip {
                                    text: "xs " + (NovaScreen.isXs ? "✓" : "—")
                                    filled: NovaScreen.isXs
                                    tint: NovaScreen.isXs ? NovaTheme.primary : NovaTheme.textMuted
                                    dense: true
                                }
                                NovaChip {
                                    text: "sm " + (NovaScreen.isSm ? "✓" : "—")
                                    filled: NovaScreen.isSm
                                    tint: NovaScreen.isSm ? NovaTheme.primary : NovaTheme.textMuted
                                    dense: true
                                }
                                NovaChip {
                                    text: "md " + (NovaScreen.isMd ? "✓" : "—")
                                    filled: NovaScreen.isMd
                                    tint: NovaScreen.isMd ? NovaTheme.primary : NovaTheme.textMuted
                                    dense: true
                                }
                                NovaChip {
                                    text: "lg " + (NovaScreen.isLg ? "✓" : "—")
                                    filled: NovaScreen.isLg
                                    tint: NovaScreen.isLg ? NovaTheme.primary : NovaTheme.textMuted
                                    dense: true
                                }
                                NovaChip {
                                    text: "xl " + (NovaScreen.isXl ? "✓" : "—")
                                    filled: NovaScreen.isXl
                                    tint: NovaScreen.isXl ? NovaTheme.primary : NovaTheme.textMuted
                                    dense: true
                                }
                            }
                            Text {
                                width: parent.width
                                text: "lt: { sm: " + NovaScreen.ltSm + ", md: " + NovaScreen.ltMd
                                      + " }  ·  gt: { xs: " + NovaScreen.gtXs + ", sm: " + NovaScreen.gtSm
                                      + ", md: " + NovaScreen.gtMd + " }"
                                font.pixelSize: NovaTheme.fontXS
                                color: NovaTheme.textMuted
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                // ── NovaIcon · 图标 ─────────────────────────
                NovaCard {
                    Layout.fillWidth: true
                    NovaCardSection {
                        Column {
                            width: parent.width
                            spacing: NovaTheme.spacingM

                            Text {
                                text: "NovaIcon · 图标（对标 QIcon）"
                                font.bold: true
                                font.pixelSize: NovaTheme.fontL
                                color: NovaTheme.textColor
                            }
                            Row {
                                spacing: NovaTheme.spacingM

                                NovaIcon { icon: "mdi:home"; size: 28 }
                                NovaIcon { icon: "mdi:cog"; size: 28; color: NovaTheme.primary }
                                NovaIcon { icon: "mdi:bell"; size: 36; color: NovaTheme.warning }
                                NovaIcon { icon: "material:favorite"; size: 28; color: NovaTheme.negative }
                                NovaIcon { icon: "material-outlined:settings"; size: 28 }
                                NovaIcon { icon: "mdi:delete"; size: 28; color: NovaTheme.textMuted }
                            }
                            Row {
                                spacing: NovaTheme.spacingM
                                NovaBtn { icon: "mdi:home"; text: "图标按钮"; variant: "outlined" }
                                NovaBtn { icon: "mdi:magnify"; round: true }
                            }
                            Text {
                                width: parent.width
                                text: "双通道：优先本地图标包（python scripts/fetch_icons.py 下载到 icons/），"
                                      + "本地缺失自动回落云端 CDN（jsDelivr: @mdi/svg、@material-design-icons/svg）；"
                                      + "NovaBtn 的 icon 属性自动识别图标引用"
                                font.pixelSize: NovaTheme.fontXS
                                color: NovaTheme.textMuted
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                // ── NovaBadge / NovaRipple ─────────────────
                NovaCard {
                    Layout.fillWidth: true
                    NovaCardSection {
                        Column {
                            width: parent.width
                            spacing: NovaTheme.spacingM

                            Text {
                                text: "NovaBadge / NovaRipple · 徽标与水波纹"
                                font.bold: true
                                font.pixelSize: NovaTheme.fontL
                                color: NovaTheme.textColor
                            }
                            Text {
                                width: parent.width
                                text: "作为子项挂载到任意 Item；纯 QML 不支持自定义 attached property，attach 语法规划于 M1 通过 PySide6 QML_ATTACHED 补齐"
                                font.pixelSize: NovaTheme.fontS
                                color: NovaTheme.textMuted
                                wrapMode: Text.WordWrap
                            }
                            Row {
                                spacing: NovaTheme.spacingL

                                NovaAvatar {
                                    text: "M"
                                    NovaBadge { text: "3" }
                                }
                                NovaBtn {
                                    icon: "🔔"
                                    round: true
                                    variant: "outlined"
                                    NovaBadge { text: "99+"; floating: true }
                                }
                                NovaBtn {
                                    icon: "💬"
                                    round: true
                                    variant: "flat"
                                    NovaBadge { }   // 空 text = 红点
                                }
                                Rectangle {
                                    width: 150
                                    height: 76
                                    radius: NovaTheme.radiusM
                                    color: NovaTheme.primary
                                    Text {
                                        anchors.centerIn: parent
                                        text: "NovaRipple"
                                        color: "#FFFFFF"
                                        font.pixelSize: NovaTheme.fontS
                                        font.bold: true
                                    }
                                    NovaRipple { }
                                }
                                Rectangle {
                                    width: 150
                                    height: 76
                                    radius: NovaTheme.radiusM
                                    color: NovaTheme.surfaceAlt
                                    border.color: NovaTheme.outline
                                    Text {
                                        anchors.centerIn: parent
                                        text: "自定义波纹色"
                                        color: NovaTheme.textMuted
                                        font.pixelSize: NovaTheme.fontS
                                    }
                                    NovaRipple {
                                        color: Qt.rgba(NovaTheme.accent.r, NovaTheme.accent.g, NovaTheme.accent.b, 0.35)
                                    }
                                }
                            }
                        }
                    }
                }

                // ── 布局原语 ────────────────────────────────
                NovaCard {
                    Layout.fillWidth: true
                    NovaCardSection {
                        Column {
                            width: parent.width
                            spacing: NovaTheme.spacingM

                            Text {
                                text: "NovaSpace / NovaSeparator / NovaCard 系列 · 布局原语"
                                font.bold: true
                                font.pixelSize: NovaTheme.fontL
                                color: NovaTheme.textColor
                            }
                            Item {
                                width: parent.width
                                height: 40
                                Row {
                                    anchors.fill: parent
                                    NovaBtn { text: "保存" }
                                    NovaSpace { }
                                    NovaBtn { text: "取消"; variant: "flat" }
                                }
                            }
                            NovaSeparator { width: parent.width }
                            NovaSeparator { width: parent.width; spaced: true }
                            NovaCardActions {
                                width: parent.width
                                align: "center"
                                NovaChip { text: "NovaCardSection" }
                                NovaChip { text: "NovaCardActions" }
                                NovaChip { text: "NovaCardActions: align center" }
                            }
                        }
                    }
                }

                // ── NovaNotify · 通知 ────────────────────────
                NovaCard {
                    Layout.fillWidth: true
                    NovaCardSection {
                        Column {
                            width: parent.width
                            spacing: NovaTheme.spacingM

                            Text {
                                text: "NovaNotify · 通知（对标 Notify 插件）"
                                font.bold: true
                                font.pixelSize: NovaTheme.fontL
                                color: NovaTheme.textColor
                            }
                            Text {
                                width: parent.width
                                text: "命令式 show() · 9 位定位 · 分组徽标 · 动作按钮 · 超时进度条 · dismissed(reason) 关闭原因上报（Nova 增强）"
                                font.pixelSize: NovaTheme.fontS
                                color: NovaTheme.textMuted
                                wrapMode: Text.WordWrap
                            }
                            Flow {
                                width: parent.width
                                spacing: NovaTheme.spacingM

                                NovaBtn { text: "成功"; tint: NovaTheme.positive
                                          onClicked: NovaNotify.show({ type: "positive", message: "保存成功", caption: "文档已写入本地" }) }
                                NovaBtn { text: "失败"; tint: NovaTheme.negative
                                          onClicked: NovaNotify.show({ type: "negative", message: "删除失败", caption: "文件被其他程序占用" }) }
                                NovaBtn { text: "警告"
                                          onClicked: NovaNotify.show({ type: "warning", message: "磁盘剩余空间不足 10%" }) }
                                NovaBtn { text: "信息"
                                          onClicked: NovaNotify.show({ type: "info", message: "新版本 0.6.0 已发布", caption: "pip install --upgrade pyside-nova" }) }
                                NovaBtn { text: "撤销演示"; variant: "outlined"
                                          onClicked: NovaNotify.show({ message: "已删除 1 个文件", caption: "本次操作可撤销",
                                                                       actions: [{ label: "撤销", handler: function() {
                                                                           NovaNotify.show({ type: "info", message: "已恢复" }) } }] }) }
                                NovaBtn { text: "带关闭按钮"; variant: "flat"
                                          onClicked: NovaNotify.show({ message: "常驻通知（timeout: 0）", closeBtn: true, timeout: 0 }) }
                                NovaBtn { text: "分组连发 ×2"; variant: "flat"
                                          onClicked: {
                                              NovaNotify.show({ message: "同一事件", caption: "分组键相同会合并并计徽标" })
                                              NovaNotify.show({ message: "同一事件", caption: "分组键相同会合并并计徽标" })
                                          } }
                                NovaBtn { text: "九宫格定位"; variant: "flat"
                                          onClicked: {
                                              var pos = ["top-left", "top-right", "bottom-left", "bottom-right"]
                                              for (var i = 0; i < pos.length; i++)
                                                  NovaNotify.show({ message: pos[i], position: pos[i], timeout: 1500 })
                                          } }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
