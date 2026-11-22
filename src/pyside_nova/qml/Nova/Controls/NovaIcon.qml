// src/pyside_nova/qml/Nova/Controls/NovaIcon.qml
// NovaIcon —— 图标（对标 QIcon）：八通道归一化解析 + provider 注册表 + 本地图标包优先/CDN 回落 + MultiEffect 单色化
// 支持写法（NovaIconSet.resolve 归一化）：
//   home / o_home / r_home / s_home        → 当前图标集（material 系变体前缀 1:1）
//   mdi-home / mdi:home / eva-home         → 前缀库映射（对标 QIcon.libMap）
//   fas fa-home / far fa-star / fab fa-github / las la-home  → FA 旧式类名写法 1:1
//   sym_r_home / sym_o_home / sym_s_home   → Material Symbols 变体
//   ion-md-home / ion-ios-home / ion-logo-github → Ionicons 平台前缀
//   img:qrc:/a.png                         → 图片直出
//   M12 2L2 7v10h4V9h12v8h4V7z|0 0 24 24  → SVG path 直出（Shape/PathSvg 渲染）
// 资源通道：provider 注册表（NovaIconSet.providers）；本地图标包（NovaTheme.iconLocalRoot）优先，
//           缺失自动回落 provider 的 CDN 地址；ligature 类 provider 走字体连字（需自备字体文件）
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Nova.Services
import Nova.Design

Item {
    id: root

    // ── 槽机制（对标 QIcon 默认槽）────────────────────────────
    default property alias content: overlay.data

    // ── 内容 ──
    property string icon: ""
    property url source: ""          // 直接指定图片地址（优先级最高）
    property real size: 24

    // ── 外观 ──
    property color color: NovaTheme.textColor
    property bool monochrome: true   // 单色化（跟随 color）；false 保留原 SVG 彩色

    // ── 网络 ──
    property bool cloudFallback: true   // 本地缺失时回落云端

    width: size
    height: size

    // ── 归一化解析（NovaIconSet.resolve，对标 QIcon.parseIcon）──
    readonly property var parsed: NovaIconSet.resolve(icon)
    readonly property string kind: parsed.kind !== undefined ? parsed.kind : "none"
    readonly property string providerId: parsed.provider !== undefined ? parsed.provider : ""
    readonly property string iconName: parsed.name !== undefined ? parsed.name : ""
    readonly property var provider: providerId !== "" ? NovaIconSet.provider(providerId) : null

    // ── 地址解析：本地图标包优先 → provider CDN ────────────────
    property bool _useCloud: false
    onIconChanged: _useCloud = false

    function _stripSlash(s) {
        while (s.length > 0 && s.charAt(s.length - 1) === "/")
            s = s.substring(0, s.length - 1)
        return s
    }

    readonly property string _remote: providerId !== ""
                                       ? NovaIconSet.providerUrl(providerId, iconName) : ""

    readonly property string _local: {
        if (NovaTheme.iconLocalRoot.toString() === "" || kind !== "svg")
            return ""
        return _stripSlash(NovaTheme.iconLocalRoot.toString()) + "/" + providerId + "/" + iconName + ".svg"
    }

    readonly property string _url: {
        if (source.toString() !== "")
            return source.toString()
        if (kind === "image")
            return parsed.src
        if (kind !== "svg")
            return ""
        if (!_useCloud && _local !== "")
            return _local
        return _remote
    }

    // ── 通道 1：SVG / 位图 ────────────────────────────────────
    Image {
        id: img
        anchors.fill: parent
        visible: root.kind === "svg" || root.kind === "image"
        source: root._url
        sourceSize: Qt.size(root.size, root.size)
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        cache: true
        onStatusChanged: {
            if (status === Image.Error && root.source.toString() === ""
                    && root.kind === "svg" && !root._useCloud && root.cloudFallback)
                root._useCloud = true   // 本地图标缺失 → 回落 provider CDN
        }
    }

    MultiEffect {
        anchors.fill: parent
        visible: img.visible
        source: img
        colorization: root.monochrome ? 1.0 : 0.0
        colorizationColor: root.color
    }

    // ── 通道 2：ligature 字体（Material Icons/Symbols 等自备字体）──
    // 需要宿主注册 ligature provider：NovaIconSet.registerProvider("material-icons",
    //   { kind: "ligature", family: "Material Icons", src: "qrc:/fonts/MaterialIcons-Regular.ttf" })
    FontLoader {
        id: fontLoader
        source: root.provider !== null && root.provider.kind === "ligature"
                && root.provider.src !== undefined ? root.provider.src : ""
    }

    Text {
        anchors.centerIn: parent
        visible: root.kind === "ligature" || (root.kind === "svg" && root.provider !== null
                                              && root.provider.kind === "ligature")
        text: visible ? root.iconName : ""
        color: root.color
        font.pixelSize: root.size
        font.family: root.provider !== null && root.provider.family !== undefined
                     ? root.provider.family : NovaTheme.fontFamily
        renderType: Text.NativeRendering
    }

    // ── 通道 2.5：纯文本（emoji / 符号，不作为图标名去 CDN 请求）──
    Text {
        anchors.centerIn: parent
        visible: root.kind === "text"
        text: visible ? root.iconName : ""
        color: root.color
        font.pixelSize: root.size * 0.86
        font.family: NovaTheme.fontFamily
    }

    // ── 通道 3：SVG path 直出（Shape/PathSvg）─────────────────
    readonly property var _nodes: kind === "path" && parsed.nodes !== undefined ? parsed.nodes : []
    readonly property real _pathScale: {
        if (kind !== "path")
            return 1
        var vb = String(parsed.viewBox).split(" ")
        var w = parseFloat(vb[2])
        return w > 0 ? size / w : 1
    }

    Item {
        id: pathHost
        anchors.fill: parent
        visible: root.kind === "path"
        // 原始 24×24 视图盒缩放到目标尺寸（transform 不影响布局）
        scale: root._pathScale
        transformOrigin: Item.TopLeft

        Repeater {
            model: root._nodes
            delegate: Shape {
                width: 24
                height: 24
                ShapePath {
                    strokeWidth: 0
                    fillColor: root.color
                    PathSvg { path: modelData.d }
                }
            }
        }
    }

    // 默认槽宿主：图标之上的覆盖层
    Item { id: overlay; anchors.fill: parent }
}
