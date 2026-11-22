// src/pyside_nova/qml/Nova/Controls/NovaTimeline.qml
// NovaTimeline 时间轴（对标 QTimeline）：tint 轴色 / side 左右停靠 / dense·comfortable·loose
// 三布局；default 槽为 NovaTimelineEntry 序列，条目经 _timelineRef 反向取宿主布局参数
import QtQuick
import Nova.Controls
import Nova.Services

Item {
    id: root

    // ── 默认槽：条目集合（对标 default slot） ────────────────
    default property alias content: entriesHost.data

    // 供 NovaTimelineEntry 向上识别宿主
    readonly property bool _isNovaTimeline: true

    // ── 属性（对标 color/side/layout） ──────────────────────
    property color tint: NovaTheme.primary     // 对标 color（tint 命名红线）
    property string side: "left"               // left/right（dense/comfortable 的停靠边）
    property string layout: "dense"            // dense/comfortable/loose

    // ⛔ dark：主题由 NovaTheme 自动跟随，不重复提供

    implicitWidth: 480
    implicitHeight: entriesHost.childrenRect.height

    // 轴连线由各条目自绘（延伸进 spacing 覆盖间隙，loose 布局条目左右交替亦可成立）

    Column {
        id: entriesHost
        width: parent.width
        spacing: NovaTheme.spacingM
        onChildrenChanged: Qt.callLater(_relayout)
    }

    readonly property bool _axisOnLeft: side === "left"

    function _entryCount() {
        var n = 0
        for (var i = 0; i < entriesHost.children.length; i++)
            if (entriesHost.children[i]._isNovaTimelineEntry === true)
                n++
        return n
    }

    function _relayout() {
        for (var i = 0; i < entriesHost.children.length; i++) {
            var c = entriesHost.children[i]
            if (c._isNovaTimelineEntry === true)
                c._entryIndex = i
        }
    }
}
