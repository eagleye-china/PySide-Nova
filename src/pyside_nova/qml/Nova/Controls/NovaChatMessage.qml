// src/pyside_nova/qml/Nova/Controls/NovaChatMessage.qml
// NovaChatMessage 聊天气泡（对标 QChatMessage）：sent 收发镜像 / name·avatar·text[]·stamp /
// label 分组标签 + size 栅格宽（1~12）；slots：default 正文 / avatarSlot / nameSlot /
// stampSlot / labelSlot；⛔ *-html 系（QML 不解析 HTML，走 default 槽）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 默认槽：自定义正文（对标 default slot；非空时 text[] 隐藏） ──
    default property alias content: bodyHost.data

    // ── 属性（对标 sent/label/bg-color/text-color/name/avatar/text/stamp/size） ──
    property bool sent: false              // true=当前用户发出（镜像右侧）
    property string label: ""              // 分组标签（气泡组上方居中）
    property color tint: sent ? NovaTheme.primary : NovaTheme.surfaceAlt  // 对标 bg-color
    property color textColor: sent ? NovaTheme.textOnPrimary : NovaTheme.textColor  // 对标 text-color
    property string name: ""               // 发送者名
    property url avatar: ""                // 头像
    property var text: []                  // 字符串或字符串数组（多条气泡）
    property string stamp: ""              // 时间戳（尾条气泡右下角）
    property int size: 12                  // 1~12（栅格宽语义：气泡区宽 = size/12 × 容器宽）

    // ⛔ label-html/name-html/text-html/stamp-html：QML 不解析 HTML，富文本走 default 槽

    // ── 命名槽（对标 avatar/name/stamp/label 插槽） ──────────
    property Component avatarSlot: null
    property Component nameSlot: null
    property Component stampSlot: null
    property Component labelSlot: null

    // ── 派生 ────────────────────────────────────────────────
    readonly property var _lines: {
        if (text === null || text === undefined) return []
        if (typeof text === "string") return [text]
        if (Array.isArray(text)) return text
        return [String(text)]
    }
    // size 栅格宽的基准：组件自身宽度（QML 语境下组件宽即容器宽）
    readonly property real _unit: width > 0 ? width : implicitWidth
    readonly property real _bubbleZone: Math.max(60, _unit * Math.min(Math.max(size, 1), 12) / 12)
    readonly property real _avatarW: (avatarSlot !== null || avatar.toString() !== "") ? 34 : 0

    implicitWidth: 480
    implicitHeight: labelZone.height + bodyCol.height

    // ── 分组标签 ─────────────────────────────────────────────
    Item {
        id: labelZone
        width: parent.width
        height: visible ? 24 : 0
        visible: root.label !== "" || root.labelSlot !== null

        Loader {
            anchors.centerIn: parent
            active: root.labelSlot !== null
            sourceComponent: root.labelSlot
        }
        Text {
            anchors.centerIn: parent
            visible: root.label !== "" && root.labelSlot === null
            text: root.label
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontS
        }
    }

    // ── 主体：镜像行 ─────────────────────────────────────────
    Column {
        id: bodyCol
        anchors { top: labelZone.bottom; topMargin: NovaTheme.spacingS }
        width: parent.width

        Row {
            id: bubbleRow
            spacing: NovaTheme.spacingS
            layoutDirection: root.sent ? Qt.RightToLeft : Qt.LeftToRight
            // sent 镜像：气泡行贴右
            x: root.sent ? parent.width - width : 0
            width: parent.width
            height: childrenRect.height

            // 头像（slot 优先；底对齐最后一条气泡——对齐基准取气泡列高，勿锚定行自身高度防环）
            Item {
                width: root._avatarW
                height: 34
                y: bubbles.height - 34
                visible: root._avatarW > 0

                Loader {
                    anchors.fill: parent
                    active: root.avatarSlot !== null
                    sourceComponent: root.avatarSlot
                }
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: NovaTheme.surface
                    border.width: 1
                    border.color: NovaTheme.outline
                    visible: root.avatarSlot === null && root.avatar.toString() !== ""

                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: root.avatar
                        asynchronous: true
                    }
                }
            }

            // 气泡列：name + 多条 text + stamp
            Column {
                id: bubbles
                spacing: 4
                width: root._bubbleZone - root._avatarW

                Loader {
                    active: root.nameSlot !== null
                    sourceComponent: root.nameSlot
                }
                Text {
                    visible: root.name !== "" && root.nameSlot === null
                    text: root.name
                    color: NovaTheme.textMuted
                    font.pixelSize: NovaTheme.fontXS
                }

                Repeater {
                    model: root._lines

                    Rectangle {
                        id: lineBubble
                        required property int index
                        required property string modelData
                        readonly property bool isLast: index === root._lines.length - 1

                        width: bubbles.width
                        height: lineText.paintedHeight + 16
                                 + (isLast && root.stamp !== "" ? 14 : 0)
                        radius: 10
                        color: root.tint

                        Text {
                            id: lineText
                            x: 10
                            y: 8
                            width: parent.width - 20
                            text: lineBubble.modelData
                            color: root.textColor
                            font.pixelSize: NovaTheme.fontS
                            wrapMode: Text.Wrap
                        }

                        // 时间戳（仅尾条）
                        Loader {
                            visible: lineBubble.isLast
                            active: root.stampSlot !== null && lineBubble.isLast
                            sourceComponent: root.stampSlot
                            anchors { right: parent.right; rightMargin: 10
                                      bottom: parent.bottom; bottomMargin: 2 }
                        }
                        Text {
                            visible: lineBubble.isLast && root.stamp !== ""
                                     && root.stampSlot === null
                            anchors { right: parent.right; rightMargin: 10
                                      bottom: parent.bottom; bottomMargin: 2 }
                            text: root.stamp
                            color: root.textColor
                            opacity: 0.7
                            font.pixelSize: NovaTheme.fontXS
                        }
                    }
                }
            }
        }

        // default 槽宿主（正文子项；气泡下方独立渲染）
        Item {
            id: bodyHost
            width: parent.width
            height: childrenRect.height
            y: bubbleRow.height + NovaTheme.spacingS
        }
    }
}
