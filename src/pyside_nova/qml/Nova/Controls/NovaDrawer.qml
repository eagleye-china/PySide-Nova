// src/pyside_nova/qml/Nova/Controls/NovaDrawer.qml
// NovaDrawer 侧边抽屉：left/right、mini 悬停展开、push/overlay 双模式、breakpoint 自动收起、宽度动画（对标 QDrawer）
// NovaDrawer —— 侧边抽屉（对标 QDrawer）
// 用法：作为 NovaLayout 直接子项声明；open 控制展开；mini 模式收起为 miniWidth、悬停临时展开；
//       宿主宽度 < breakpoint 时自动转 overlay 并收起（对标 QDrawer behavior/breakpoint）
import QtQuick
import QtQuick.Effects
import Nova.Services

Item {
    id: root

    default property alias content: body.data

    // ── 几何与行为 ──
    property string side: "left"        // left | right
    property real size: 280             // 展开宽度（width 由展开状态驱动）
    property bool mini: false           // mini 模式：收起为 miniWidth，悬停临时展开
    property real miniWidth: 64
    property bool overlay: false        // 悬浮模式（不推挤页面区）
    property int breakpoint: 1024       // 宿主宽度小于该值 → 强制 overlay + 收起
    property bool autoCollapse: true    // 跨过 breakpoint 时是否自动收起
    property bool bordered: false
    property bool open: true            // 展开状态（mini 模式下表示"固定展开"）

    property color tint: NovaTheme.surface

    signal opened
    signal closed

    // ── 状态派生（对标 QDrawer 行为语义） ──
    readonly property real layoutWidth: parent ? parent.width : NovaScreen.width
    readonly property bool belowBreakpoint: layoutWidth < breakpoint
    readonly property bool effectiveOverlay: overlay || belowBreakpoint
    readonly property bool expanded: mini ? (hovered || open) : open

    property bool hovered: false

    implicitWidth: size
    implicitHeight: 200

    // 宽度动画：展开 → size；mini 收起 → miniWidth；普通收起 → 0
    width: expanded ? size : (mini ? miniWidth : 0)
    Behavior on width {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    onOpenChanged: open ? opened() : closed()
    // 断点收起策略由宿主 NovaLayout 执行（autoCollapse 语义）：
    // 创建期 parent 宽度是瞬态值，抽屉自身不可靠判断

    Rectangle {
        id: panel
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right }
        color: root.tint
        border.width: root.bordered ? 1 : 0
        border.color: NovaTheme.outline
    }

    // overlay 模式悬浮阴影
    MultiEffect {
        anchors.fill: panel
        anchors.margins: -16
        source: panel
        z: -1
        shadowEnabled: root.effectiveOverlay && root.width > 0
        shadowColor: NovaTheme.shadowColor(3)
        shadowBlur: 0.5
        autoPaddingEnabled: false
    }

    HoverHandler {
        onHoveredChanged: root.hovered = isHovered
    }

    Item {
        id: body
        anchors.fill: parent
    }
}
