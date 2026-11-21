// src/pyside_nova/qml/Nova/Controls/NovaBtn.qml
// NovaBtn 按钮：filled/outlined/flat × sm/md/lg，内置按压水波纹、hover、loading、disable、键盘触发（对标 QBtn）
// NovaBtn —— 按钮（对标 QBtn）
// variant: filled(默认) | outlined | flat；size: sm | md | lg；round 图形按钮
// 内置：按压水波纹 / hover 反馈 / loading 旋转 / disable / 键盘 Enter 触发
// tint 为基调色（对应 QBtn 的 color 属性；QML 中 color 与基类属性冲突故命名 tint）
import QtQuick
import Nova.Services

Rectangle {
    id: root

    // ── 槽机制（对标 QBtn 默认槽）─────────────────────────────
    // 默认子项挂载到按钮覆盖层（NovaBadge 等吸附角标不受影响）
    default property alias content: contentHost.data

    // ── 内容 ──
    property string text: ""
    property string icon: ""
    property string iconRight: ""

    // ── 外观 ──
    property string variant: "filled"
    property string size: "md"
    property bool round: false
    property bool dense: false
    property color tint: NovaTheme.primary

    // ── 状态 ──
    property bool disable: false
    property bool loading: false

    // ── 事件 ──
    signal clicked()
    signal pressed()
    signal released()

    readonly property bool isPressed: ma.pressed
    readonly property bool isHovered: ma.containsMouse

    // icon 属性智能识别：mdi:home / xxx.svg 等图标引用 → NovaIcon；其余 → 字形/emoji
    readonly property bool _iconIsRef: icon.indexOf(":") > -1
                                       || icon.indexOf("/") > -1
                                       || icon.indexOf(".svg") > -1

    readonly property real _h: size === "sm" ? 28
                            : size === "lg" ? 46
                            : (dense ? 30 : 38)
    readonly property int _fs: size === "sm" ? 12 : (size === "lg" ? 16 : 14)
    readonly property real _padX: round ? 0 : (size === "sm" ? 10 : (size === "lg" ? 20 : 14))
    readonly property color _fg: variant === "filled" ? NovaTheme.textOnPrimary : tint
    readonly property color _bg: variant === "filled"
        ? (isPressed ? Qt.darker(tint, 1.15)
           : (isHovered && !disable ? Qt.lighter(tint, 1.08) : tint))
        : (isHovered && !disable ? Qt.rgba(tint.r, tint.g, tint.b, 0.08) : "transparent")

    implicitHeight: _h
    implicitWidth: round ? _h : Math.max(_h, row.implicitWidth + _padX * 2)
    radius: round ? _h / 2 : NovaTheme.radiusM
    color: _bg
    border.width: variant === "outlined" ? 1.2 : 0
    border.color: disable ? NovaTheme.outline : tint
    opacity: disable ? 0.45 : 1
    clip: waves.count > 0   // 仅波纹进行中裁剪，避免裁掉挂载的 NovaBadge
    activeFocusOnTab: !disable

    Keys.onReturnPressed: _emitClick()
    Keys.onEnterPressed: _emitClick()
    Keys.onSpacePressed: _emitClick()

    function _emitClick() {
        if (!disable && !loading)
            root.clicked()
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        NovaIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== "" && root._iconIsRef
            icon: root.icon
            size: root._fs + 6
            color: root._fg
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== "" && !root._iconIsRef
            text: root.icon
            color: root._fg
            font.pixelSize: root._fs + 2
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            text: root.text
            color: root._fg
            font.family: NovaTheme.fontFamily
            font.pixelSize: root._fs
            font.weight: Font.DemiBold
        }
        Canvas {
            id: spinner
            anchors.verticalCenter: parent.verticalCenter
            visible: root.loading
            width: root._fs + 2
            height: width
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = root._fg
                ctx.lineWidth = 2
                ctx.beginPath()
                ctx.arc(width / 2, height / 2, width / 2 - 2, 0, Math.PI * 1.3)
                ctx.stroke()
            }
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 850
                loops: Animation.Infinite
                running: root.loading
            }
            Connections {
                target: root
                function onTintChanged() { spinner.requestPaint() }
                function onVariantChanged() { spinner.requestPaint() }
            }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.iconRight !== ""
            text: root.iconRight
            color: root._fg
            font.pixelSize: root._fs + 2
        }
    }

    // ── 默认槽宿主：按钮内容之上的覆盖层 ──────────────────────
    Item { id: contentHost; anchors.fill: parent }

    // ── 内置水波纹 ────────────────────────────────────────────
    ListModel { id: waves }

    MouseArea {
        id: ma
        anchors.fill: parent
        enabled: !root.disable && !root.loading
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: (m) => {
            waves.append({ "rx": m.x, "ry": m.y,
                           "dia": root._rippleDia(m.x, m.y), "done": false })
            root.pressed()
        }
        onReleased: { root.released(); root._settle() }
        onCanceled: root._settle()
        onClicked: root.clicked()
    }

    function _rippleDia(x, y) {
        return 2 * Math.max(
            Math.hypot(x, y),
            Math.hypot(root.width - x, y),
            Math.hypot(x, root.height - y),
            Math.hypot(root.width - x, root.height - y)) + 24
    }

    function _settle() {
        for (var i = 0; i < waves.count; ++i)
            if (!waves.get(i).done)
                waves.setProperty(i, "done", true)
    }

    Repeater {
        model: waves
        delegate: Rectangle {
            id: waveCircle
            required property int index
            required property real rx
            required property real ry
            required property real dia
            required property bool done

            x: rx - dia / 2
            y: ry - dia / 2
            width: dia
            height: dia
            radius: dia / 2
            color: root.variant === "filled"
                   ? Qt.rgba(1, 1, 1, 0.35)
                   : Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.25)
            opacity: done ? 0 : 1
            Behavior on opacity {
                NumberAnimation { duration: 320; easing.type: Easing.OutQuad }
            }
            NumberAnimation on scale {
                from: 0
                to: 1
                duration: 480
                easing.type: Easing.OutQuad
            }
            onDoneChanged: if (done) cleanup.restart()
            Timer {
                id: cleanup
                interval: 340
                onTriggered: waves.remove(waveCircle.index)
            }
        }
    }
}
