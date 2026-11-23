// src/pyside_nova/qml/Nova/Controls/NovaNoSsr.qml
// NovaNoSsr 延迟渲染壳：placeholder 文案/槽先显示，内容在 delay（默认下一帧）后切换（对标 QNoSsr）
// Nova 口径：QML 无 SSR 环境，语义落位为"客户端就绪延迟渲染"（骨架占位→内容），PARITY §0.14 留痕
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    default property alias content: contentBox.data
    property alias placeholder: placeholderBox.data

    // ── 配置 ──────────────────────────────────────────────────
    property string placeholderText: ""          // 未用 placeholder 槽时的占位文案
    property int delay: 0                        // 内容延迟 ms（0 = 下一帧）

    // ── 状态 ──────────────────────────────────────────────────
    readonly property bool ready: contentBox.children.length > 0 && _elapsed
    property bool _elapsed: false

    implicitWidth: contentBox.childrenRect.width > 0 ? contentBox.childrenRect.width
                 : placeholderBox.childrenRect.width > 0 ? placeholderBox.childrenRect.width : 200
    implicitHeight: contentBox.childrenRect.height > 0 ? contentBox.childrenRect.height
                  : placeholderBox.childrenRect.height > 0 ? placeholderBox.childrenRect.height : 24
    width: implicitWidth
    height: implicitHeight

    Timer {
        interval: Math.max(1, root.delay)
        running: true
        onTriggered: root._elapsed = true
    }

    // ── 内容层（就绪后渲染） ──────────────────────────────────
    Item {
        id: contentBox
        visible: root._elapsed
        width: childrenRect.width
        height: childrenRect.height
    }

    // ── 占位层 ────────────────────────────────────────────────
    Column {
        id: placeholderBox
        visible: !root._elapsed
        width: root.width
        spacing: 4

        Text {
            visible: root.placeholderText !== "" && placeholderBox.children.length <= 1
            text: root.placeholderText
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontS
        }
    }
}
