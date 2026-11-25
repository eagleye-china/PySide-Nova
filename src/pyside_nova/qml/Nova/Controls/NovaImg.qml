// src/pyside_nova/qml/Nova/Controls/NovaImg.qml
// NovaImg 图片组件（对标 QImg）：占位/错误图 + 加载转圈（延时防闪）+ ratio 宽高比 + fit/position，
// slots：default 覆盖内容 / loadingSlot / errorSlot（对标 loading/error 插槽）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 默认槽：覆盖在图片上的内容（对标 QImg default slot） ──
    default property alias content: overlay.data

    // ── 数据源 ──────────────────────────────────────────────
    property url src
    property url placeholderSrc    // 加载中占位图（对标 placeholder-src）
    property url errorSrc          // 加载失败错误图（对标 error-src）

    // ── 宽高比（对标 ratio / initial-ratio） ────────────────
    property real ratio: 0         // >0 强制宽高比 height = width / ratio
    property real initialRatio: 0  // 未指定 ratio 时的初始宽高比（避免加载期高度塌陷）
    readonly property real _effRatio: ratio > 0 ? ratio
                                     : (initialRatio > 0 ? initialRatio : 0)

    // ── 外观（对标 fit/position/spinner-*） ─────────────────
    property string fit: "cover"          // cover/fill/contain/none/scale-down
    property string position: "center"    // 对标 object-position（简化方位枚举）
    property color spinnerTint: NovaTheme.primary  // 对标 spinner-color（tint 命名红线）
    property real spinnerSize: 42                  // 对标 spinner-size
    // CARF 基础组件 Robustness：spinnerSize 非法入参钳制，spinner 直径恒非负。
    readonly property real _spinnerSize: Math.max(0, root.spinnerSize)
    property bool noSpinner: false
    property bool noTransition: false
    property int loadingShowDelay: 400             // 防缓存图闪 spinner（对标 loading-show-delay）
    property string alt: ""               // 无障碍语义（对标 alt 属性）

    // ⛔ srcset/sizes：QML Image 无 srcset 语义（原生按 DPR 取 @2x 资源），不适用
    // ⛔ width/height：QML Item.width/height 本身即尺寸语义，不重复提供
    // ⛔ loading/crossorigin/decoding/referrerpolicy/fetchpriority/draggable/
    //    img-class/img-style/no-native-menu：浏览器加载/菜单/class 语境，QML 不适用

    // ── 事件（对标 load/error） ─────────────────────────────
    signal loaded()
    signal errored()

    // ── 命名槽（对标 loading/error 插槽） ───────────────────
    property Component loadingSlot: null
    property Component errorSlot: null

    // ── 状态派生 ────────────────────────────────────────────
    // status: loading / loaded / error
    readonly property string status: img.status === Image.Ready ? "loaded"
                                   : img.status === Image.Error ? "error" : "loading"
    readonly property bool busy: status === "loading"

    implicitWidth: 240
    // ratio 派生高：有实际 width 用 width（对标 QImg 按 CSS 宽维持比例）；
    // 宿主显式设置 height 时其值优先生效（本绑定只影响 implicitHeight）
    implicitHeight: _effRatio > 0
        ? (width > 0 ? width / _effRatio : implicitWidth / _effRatio)
        : 240
    clip: true

    Accessible.name: alt !== "" ? alt : "NovaImg"
    Accessible.role: Accessible.Graphic

    function _fitMode() {
        switch (fit) {
        case "fill": return Image.Stretch
        case "contain": return Image.PreserveAspectFit
        case "none": return Image.Pad
        case "scale-down": return Image.PreserveAspectFit
        default: return Image.PreserveAspectCrop
        }
    }

    function _posVAlign() {
        if (position.indexOf("top") === 0) return Image.AlignTop
        if (position.indexOf("bottom") === 0) return Image.AlignBottom
        return Image.AlignVCenter
    }
    function _posHAlign() {
        if (position.indexOf("left") !== -1) return Image.AlignLeft
        if (position.indexOf("right") !== -1) return Image.AlignRight
        return Image.AlignHCenter
    }

    // 占位/错误图分层叠加（避免 source 依赖 status 的绑定环）：
    // 主图常驻 source=src；加载中叠占位图；失败叠错误图
    Image {
        id: img
        anchors.fill: parent
        fillMode: root._fitMode()
        horizontalAlignment: root._posHAlign()
        verticalAlignment: root._posVAlign()
        source: root.src
        asynchronous: true
        cache: true
        opacity: root.status === "loaded" ? 1.0 : 0.35
        Behavior on opacity { NumberAnimation { duration: root.noTransition ? 0 : 220 } }
        onStatusChanged: {
            if (status === Image.Ready) root.loaded()
            else if (status === Image.Error) root.errored()
        }
    }
    Image {
        id: placeholderImg
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: root.placeholderSrc
        asynchronous: true
        visible: root.status === "loading" && root.placeholderSrc.toString() !== ""
    }
    Image {
        id: errorImg
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: root.errorSrc
        asynchronous: true
        visible: root.status === "error" && root.errorSrc.toString() !== ""
    }

    // 加载转圈：loadingShowDelay 延时显示（防缓存命中闪 spinner）
    Item {
        id: spinnerHost
        anchors.fill: parent
        property bool elapsed: false
        visible: root.busy && !root.noSpinner && elapsed

        Timer {
            id: spinnerDelayTimer
            interval: Math.max(0, root.loadingShowDelay)
            running: root.busy && !root.noSpinner
            // 坑位 16 语义：状态翻转先复位再计时，避免上次残留 elapsed
            onRunningChanged: if (!running) spinnerHost.elapsed = false
            onTriggered: spinnerHost.elapsed = true
        }

        // 环形 spinner：旋转 Item + Canvas 270° 弧（令牌取色，无魔法色值）
        Item {
            width: root._spinnerSize
            height: root._spinnerSize
            anchors.centerIn: parent

            RotationAnimation on rotation {
                from: 0; to: 360
                duration: 900
                loops: Animation.Infinite
                running: root.busy && !root.noSpinner && spinnerHost.elapsed
            }
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 3
                border.color: Qt.rgba(root.spinnerTint.r, root.spinnerTint.g,
                                      root.spinnerTint.b, 0.22)
            }
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = root.spinnerTint.toString()
                    ctx.lineWidth = 3
                    ctx.lineCap = "round"
                    ctx.beginPath()
                    ctx.arc(width / 2, height / 2, width / 2 - 2,
                            -Math.PI / 2, -Math.PI / 2 + 1.5 * Math.PI)
                    ctx.stroke()
                }
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                Connections {
                    function onSpinnerTintChanged() { parent.requestPaint() }
                    target: root
                }
            }
        }
    }

    // 命名槽渲染（errorSlot 与 loadingSlot 状态互斥）
    Loader {
        anchors.fill: parent
        active: root.status === "error" && root.errorSlot !== null
        sourceComponent: root.errorSlot
    }
    Loader {
        anchors.fill: parent
        active: root.status === "loading" && root.loadingSlot !== null
        sourceComponent: root.loadingSlot
    }

    // 默认槽宿主：覆盖层
    Item {
        id: overlay
        anchors.fill: parent
    }
}
