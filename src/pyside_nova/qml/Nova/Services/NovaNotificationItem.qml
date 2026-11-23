// src/pyside_nova/qml/Nova/Services/NovaNotificationItem.qml
// NovaNotificationItem 通知卡片：媒体/正文/动作/进度/徽标一体渲染，进出动效与超时计时（内部件，由 NovaNotify 驱动）
// NovaNotificationItem —— 单条通知的可视卡片（对标 q-notification 卡片；qmldir 内部导出，不由应用直接声明）
// 行为契约见 docs/PARITY.md NovaNotify 审计节：
//     入场/出场动效 transform+opacity 各 1s（基线 $z-notify 卡片 transition）；
//     计时器时长 = timeout + 1000（1000 与动效共用同一常量，不可分开写死）；
//     progress 进度条动画时长同计时器；媒体互斥 spinner > icon > avatar。
import QtQuick
import QtQuick.Effects
import Nova.Controls
import Nova.Services

Item {
    id: root

    // ── 内容 ──────────────────────────────────────────────────
    property string message: ""
    property string caption: ""
    property Component contentDelegate: null   // 替代基线 html（QML 无 DOM + XSS 面），整块替换正文区

    // ── 外观（命名红线：基调色 tint / 文字色 textTint） ──────────
    property color tint: NovaTheme.dark
    property color textTint: NovaTheme.textOnPrimary
    property string icon: ""
    property color iconTint: "transparent"
    property real iconSize: 24
    property url avatar: ""
    property bool spinner: false
    property Component spinnerDelegate: null
    property color spinnerTint: "transparent"
    property real spinnerSize: 32

    // ── 徽标（分组计数） ───────────────────────────────────────
    property int badge: 1
    property color badgeTint: NovaTheme.negative
    property color badgeTextTint: "#FFFFFF"
    property string badgePosition: "top-right"   // top-left | top-right | bottom-left | bottom-right

    // ── 进度与超时 ────────────────────────────────────────────
    property bool progress: false
    property color progressTint: Qt.rgba(1, 1, 1, 0.7)
    property int timeout: 5000

    // ── 动作 ──────────────────────────────────────────────────
    property var actions: []                     // NovaNotifyAction 实例数组
    property bool multiLine: false

    // ── 运行时状态（NovaNotify 维护，应用层只读） ───────────────
    property string position: "bottom"
    property var groupKey: null                  // null = 不分组
    property real maxWidth: 360                  // 由 NovaNotify.relayout 按窗口宽度约束（基线 95vw / 65vw@sm）
    property bool quiet: false                   // true = 静默替换路径，不出入场动效
    property real dirX: 0                        // 入场滑移方向（由 position 决定）
    property real dirY: 0
    readonly property bool hasMedia: spinner || icon !== "" || avatar !== ""
    readonly property bool exiting: _exiting
    property bool _exiting: false
    property bool _dead: false
    property var _handle: null                   // NovaNotifyHandle 反向引用（防 GC）

    signal dismissed(string reason)
    signal timedOut()

    // ── 尺寸自洽 ──────────────────────────────────────────────
    readonly property real hpad: 16
    readonly property real vpad: 10
    readonly property real actionsWidth: root.multiLine ? mlActionsLoader.width : stdActionsLoader.width
    readonly property real textMax: {
        var base = root.maxWidth - 2 * root.hpad
        var mediaW = root.hasMedia ? 48 : 0
        var actW = root.multiLine ? 0 : (root.actions.length > 0 ? root.actionsWidth + 8 : 0)
        return Math.max(48, base - mediaW - actW)
    }
    implicitWidth: Math.min(maxWidth,
                            (root.multiLine ? mlCol.implicitWidth : stdRow.implicitWidth) + 2 * hpad)
    implicitHeight: (root.multiLine ? mlCol.implicitHeight : stdRow.implicitHeight) + 2 * vpad
    width: implicitWidth
    height: implicitHeight

    // ── 进出场动效（与计时器共用 enterMs 常量，见 NovaNotify） ────
    property real showProgress: quiet ? 1.0 : 0.0
    Behavior on showProgress {
        enabled: !root.quiet
        NumberAnimation { duration: NovaNotify.enterMs; easing.type: Easing.OutCubic }
    }
    opacity: showProgress
    transform: [
        Translate {
            x: root.dirX * (1 - root.showProgress) * 26
            y: root.dirY * (1 - root.showProgress) * 26
        },
        Scale {
            origin.x: root.width / 2
            origin.y: root.height / 2
            xScale: 0.96 + 0.04 * root.showProgress
            yScale: 0.96 + 0.04 * root.showProgress
        }
    ]
    // 队列重排（相邻条目关闭后平滑归位）
    Behavior on y {
        enabled: !root._exiting
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    Component.onCompleted: {
        if (!quiet)
            showProgress = 1.0
        if (timeout > 0)
            timeoutTimer.start()
        if (progress && timeout > 0)
            restartProgress()
    }

    Timer {
        id: timeoutTimer
        interval: root.timeout > 0 ? root.timeout + NovaNotify.enterMs : 0
        onTriggered: root.timedOut()
    }

    function resetTimer() {
        if (timeout > 0) {
            timeoutTimer.interval = timeout + NovaNotify.enterMs
            timeoutTimer.restart()
            restartProgress()
        }
    }

    // 进度条：时长与计时器一致（timeout + 1000），线性走完即消失时刻
    property real progressFraction: 1.0
    NumberAnimation {
        id: progressAnim
        target: root
        property: "progressFraction"
        from: 1.0
        to: 0.0
        duration: root.timeout + NovaNotify.enterMs
        easing.type: Easing.Linear
    }
    function restartProgress() {
        progressFraction = 1.0
        if (progress && timeout > 0)
            progressAnim.restart()
    }

    function playExit() {
        _exiting = true
        timeoutTimer.stop()
        showProgress = 0.0
        exitDestroy.restart()
    }
    Timer {
        id: exitDestroy
        interval: NovaNotify.enterMs
        onTriggered: root.destroy()
    }

    // 程序化触发动作（等同于点击，含关闭语义；画廊/自动化/测试复用）
    function triggerAction(index) {
        var act = root.actions[index]
        if (!act)
            return
        act.triggered()
        if (act.handler)
            act.handler()
        if (!act.noDismiss)
            NovaNotify.dismiss(root, act.closeReason || "action")
    }

    // ══════════════════════════════════════════════════════════
    // 卡片本体
    // ══════════════════════════════════════════════════════════
    Rectangle {
        id: card
        anchors.fill: parent
        radius: NovaTheme.radiusM
        color: root.tint
        clip: true

        MultiEffect {
            anchors.fill: parent
            anchors.margins: -12
            source: card
            z: -1
            shadowEnabled: true
            shadowColor: NovaTheme.shadowColor(2)
            shadowBlur: 0.4
            autoPaddingEnabled: false
        }

        // ── 标准布局：媒体 + 正文 + 动作 同行 ──
        Row {
            id: stdRow
            visible: !root.multiLine
            anchors.centerIn: parent
            spacing: 10

            Loader { sourceComponent: mediaComp; visible: root.hasMedia }
            Loader { sourceComponent: textComp }
            Loader { id: stdActionsLoader; sourceComponent: actionsComp; visible: root.actions.length > 0 }
        }

        // ── 多行布局：媒体 + 正文在上，动作行在下（右对齐） ──
        Column {
            id: mlCol
            visible: root.multiLine
            anchors.centerIn: parent
            spacing: 6

            Row {
                spacing: 10
                Loader { sourceComponent: mediaComp; visible: root.hasMedia }
                Loader { sourceComponent: textComp }
            }
            Row {
                Loader { id: mlActionsLoader; sourceComponent: actionsComp; visible: root.actions.length > 0 }
            }
        }
    }

    // ── 动作行（两组布局共用一份源 Component） ──
    Component {
        id: actionsComp
        Row {
            spacing: 2

            Repeater {
                model: root.actions

                delegate: Text {
                    textFormat: Text.PlainText  // 外部文案消毒：禁 AutoText 富文本解析（0.16.2）
                    id: btn
                    required property int index
                    required property var modelData

                    text: modelData.label !== "" ? modelData.label : "•"
                    color: modelData.textTint.a > 0 ? modelData.textTint : root.textTint
                    font.family: NovaTheme.fontFamily
                    font.pixelSize: NovaTheme.fontS
                    leftPadding: 8
                    rightPadding: 8
                    topPadding: 6
                    bottomPadding: 6
                    verticalAlignment: Text.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.triggerAction(btn.index)
                    }
                }
            }
        }
    }

    // ── 正文区（message + caption，或 contentDelegate 整块替换） ──
    Component {
        id: textComp
        Column {
            id: tcol
            spacing: 2

            Text {
                textFormat: Text.PlainText  // 外部文案消毒：禁 AutoText 富文本解析（0.16.2）
                visible: root.message !== "" && root.contentDelegate === null
                text: root.message
                color: root.textTint
                font.family: NovaTheme.fontFamily
                font.pixelSize: NovaTheme.fontM
                width: Math.min(implicitWidth, textMax)
                wrapMode: root.multiLine ? Text.WordWrap : Text.NoWrap
                elide: Text.ElideRight
            }
            Text {
                textFormat: Text.PlainText  // 外部文案消毒：禁 AutoText 富文本解析（0.16.2）
                visible: root.caption !== "" && root.contentDelegate === null
                text: root.caption
                color: root.textTint
                opacity: 0.8
                font.family: NovaTheme.fontFamily
                font.pixelSize: NovaTheme.fontS
                width: Math.min(implicitWidth, textMax)
                wrapMode: root.multiLine ? Text.WordWrap : Text.NoWrap
                elide: Text.ElideRight
            }
            // 作用域槽宿主：contentDelegate 替代基线 html 通道
            Loader {
                active: root.contentDelegate !== null
                sourceComponent: root.contentDelegate
                width: textMax
            }
        }
    }

    // ── 媒体区（互斥：spinner > icon > avatar；icon "none" 占位不渲染） ──
    Component {
        id: mediaComp
        Item {
            width: 40
            height: 40

            // 转圈：默认内置最小实现（D4 裁定），spinnerDelegate 可整块替换
            Loader {
                anchors.centerIn: parent
                visible: root.spinner
                width: root.spinnerSize
                height: root.spinnerSize
                sourceComponent: root.spinnerDelegate !== null ? root.spinnerDelegate : defaultSpinnerComp
            }
            Component {
                id: defaultSpinnerComp
                Item {
                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 900
                        loops: Animation.Infinite
                    }
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.width: 3
                        border.color: root.spinnerTint.a > 0 ? root.spinnerTint : root.textTint
                    }
                }
            }

            NovaIcon {
                anchors.centerIn: parent
                visible: !root.spinner && root.icon !== "" && root.icon !== "none"
                icon: root.icon
                size: root.iconSize
                color: root.iconTint.a > 0 ? root.iconTint : root.textTint
            }

            Image {
                anchors.centerIn: parent
                visible: !root.spinner && root.icon === "" && root.avatar !== ""
                source: root.avatar
                fillMode: Image.PreserveAspectCrop
                mipmap: true
            }
        }
    }

    // ── 分组徽标（badge > 1 时出现；贴角内缩 6px，避免与卡片圆角/裁剪打架） ──
    Rectangle {
        id: badgeChip
        visible: root.badge > 1
        width: Math.max(badgeLabel.width + 10, 20)
        height: 20
        radius: height / 2
        color: root.badgeTint
        z: 1

        x: root.badgePosition.indexOf("left") !== -1 ? 6
           : root.badgePosition.indexOf("right") !== -1 ? parent.width - width - 6
           : (parent.width - width) / 2
        y: root.badgePosition.indexOf("top") !== -1 ? 6 : parent.height - height - 6

        Text {
            textFormat: Text.PlainText  // 外部文案消毒：禁 AutoText 富文本解析（0.16.2）
            id: badgeLabel
            anchors.centerIn: parent
            text: root.badge > 99 ? "99+" : String(root.badge)
            color: root.badgeTextTint
            font.family: NovaTheme.fontFamily
            font.pixelSize: 11
            font.bold: true
        }
    }

    // ── 超时进度条（timeout=0 时强制隐藏，契约 4.3） ──
    Rectangle {
        id: progress
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 3
        width: parent.width * root.progressFraction
        visible: root.progress && root.timeout > 0 && !root._exiting
        color: root.progressTint
    }
}
