// src/pyside_nova/qml/Nova/Controls/NovaTimelineEntry.qml
// NovaTimelineEntry 时间轴条目（对标 QTimelineEntry）：heading 标题态 / icon·avatar 轴点 /
// title·subtitle·body 三段内容 + titleSlot/subtitleSlot 命名槽；布局参数取自宿主 NovaTimeline
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: entry

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.ListItem
    Accessible.name: a11yLabel !== "" ? a11yLabel : title

    // ── 默认槽：正文内容（对标 default slot） ────────────────
    default property alias content: bodyHost.data

    // 宿主识别标记
    readonly property bool _isNovaTimelineEntry: true

    // 宿主回填的序号（首尾条目不向端外延伸轴连线）
    property int _entryIndex: -1

    // ── 属性（对标 heading/side/icon/avatar/color/title/subtitle/body） ──
    property bool heading: false        // 标题条目（无轴点，整行渲染）
    property string side: ""            // loose 布局下的停靠边（left/right；空取宿主 side）
    property string icon: ""            // 轴点图标（优先于 avatar）
    property url avatar: ""             // 轴点头像
    property color tint: NovaTheme.primary  // 对标 color（tint 命名红线）
    property string title: ""
    property string subtitle: ""
    property string body: ""            // 正文文本；亦可走 default 槽

    // ⛔ tag：HTML 渲染元素语义，QML 不适用

    // ── 命名槽（对标 title/subtitle 插槽） ───────────────────
    property Component titleSlot: null
    property Component subtitleSlot: null

    // ── 宿主解析（向上遍历找 NovaTimeline，坑位 14 语义） ────
    property var _host: null
    readonly property string _effSide: side !== "" ? side
        : (_host !== null ? _host.side : "left")
    readonly property bool _axisLeft: _effSide === "left"
    readonly property bool _comfortable: _host !== null && _host.layout === "comfortable"
    readonly property bool _isFirst: _entryIndex <= 0
    readonly property bool _isLast: _host !== null
        ? _entryIndex >= _host._entryCount() - 1 : true

    readonly property int _axisW: 32
    readonly property int _gap: NovaTheme.spacingM

    Component.onCompleted: _attach()
    onParentChanged: if (_host === null) _attach()

    function _attach() {
        var p = parent
        while (p !== null) {
            if (p._isNovaTimeline === true) {
                _host = p
                return
            }
            p = p.parent
        }
    }

    // 标题态：整行渲染
    readonly property bool _headingMode: heading

    // ── 高度：内容列决定 ─────────────────────────────────────
    implicitHeight: _headingMode
        ? headingText.height
        : contentCol.height + 2

    // ── 标题条目 ─────────────────────────────────────────────
    Text {
        id: headingText
        visible: entry._headingMode
        width: parent.width
        text: entry.title !== "" ? entry.title : entry.body
        color: entry.tint
        font.pixelSize: NovaTheme.fontM
        font.weight: Font.Medium
    }

    // ── 轴区：连线 + 圆点/图标/头像（垂直居中于标题行） ──────
    Item {
        id: axisZone
        visible: !entry._headingMode
        x: entry._axisLeft ? 0 : parent.width - entry._axisW
        width: entry._axisW
        height: parent.height

        // 连线：延伸进 spacing 覆盖间隙（首条不向上、末条不向下）
        Rectangle {
            x: (parent.width - 2) / 2
            width: 2
            color: entry.tint
            opacity: 0.35
            y: entry._isFirst ? 14 : -entry._gap / 2
            height: entry._isLast
                ? parent.height - 14 + entry._gap / 2
                : parent.height - y + entry._gap / 2
        }

        Rectangle {
            id: axisDot
            width: entry.icon !== "" || entry.avatar.toString() !== "" ? 28 : 10
            height: width
            radius: width / 2
            x: (parent.width - width) / 2
            y: 9
            color: entry.tint
            visible: !entry._headingMode

            Image {
                anchors.fill: parent
                visible: entry.icon === "" && entry.avatar.toString() !== ""
                fillMode: Image.PreserveAspectCrop
                source: entry.avatar
                asynchronous: true
            }
            NovaIcon {
                anchors.centerIn: parent
                visible: entry.icon !== ""
                icon: entry.icon
                size: 14
                color: NovaTheme.textOnPrimary
            }
        }
    }

    // ── 标签区（仅 comfortable：title/subtitle 与轴对侧独占） ─
    Column {
        id: labelZone
        visible: !entry._headingMode && entry._comfortable
        spacing: 2
        width: (parent.width - entry._axisW - entry._gap * 2) / 2
        x: entry._axisLeft
            ? parent.width - width
            : entry._axisW + entry._gap
        y: NovaTheme.spacingS

        Loader {
            active: entry.titleSlot !== null
            sourceComponent: entry.titleSlot
        }
        Text {
            visible: entry.title !== "" && entry.titleSlot === null
            text: entry.title
            color: NovaTheme.textColor
            font.pixelSize: NovaTheme.fontM
            font.weight: Font.Medium
            horizontalAlignment: entry._axisLeft ? Text.AlignRight : Text.AlignLeft
            width: parent.width
        }
        Text {
            visible: entry.subtitle !== "" && entry.subtitleSlot === null
            text: entry.subtitle
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontS
            horizontalAlignment: entry._axisLeft ? Text.AlignRight : Text.AlignLeft
            width: parent.width
        }
        Loader {
            active: entry.subtitleSlot !== null
            sourceComponent: entry.subtitleSlot
        }
    }

    // ── 内容区：dense/loose 标签在正文上方，comfortable 仅正文 ──
    Column {
        id: contentCol
        spacing: 2
        width: entry._comfortable
            ? (parent.width - entry._axisW - entry._gap * 2) / 2
            : parent.width - entry._axisW - entry._gap * 2
        x: entry._axisLeft
            ? entry._axisW + entry._gap
            : entry._comfortable ? 0
              : parent.width - entry._axisW - entry._gap - width

        Column {
            width: parent.width
            visible: !entry._comfortable
            spacing: 2

            Loader {
                active: entry.titleSlot !== null
                sourceComponent: entry.titleSlot
            }
            Text {
                visible: entry.title !== "" && entry.titleSlot === null
                text: entry.title
                color: NovaTheme.textColor
                font.pixelSize: NovaTheme.fontM
                font.weight: Font.Medium
            }
            Text {
                visible: entry.subtitle !== "" && entry.subtitleSlot === null
                text: entry.subtitle
                color: NovaTheme.textMuted
                font.pixelSize: NovaTheme.fontS
            }
            Loader {
                active: entry.subtitleSlot !== null
                sourceComponent: entry.subtitleSlot
            }
        }

        Text {
            visible: entry.body !== "" && !entry._hasSlotContent()
            text: entry.body
            color: NovaTheme.textColor
            font.pixelSize: NovaTheme.fontS
            width: parent.width
            wrapMode: Text.Wrap
        }
    }

    // ── default 槽宿主（正文子项挂载于此；非空时 body 文本隐藏） ──
    Item {
        id: bodyHost
        width: entry.width
        height: childrenRect.height
        y: contentCol.height + NovaTheme.spacingS
    }

    function _hasSlotContent() {
        return bodyHost.children.length > 0
    }
}
