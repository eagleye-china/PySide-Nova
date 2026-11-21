// src/pyside_nova/qml/Nova/Controls/NovaIcon.qml
// NovaIcon 图标组件：icon="mdi:home" 式 API，本地图标包优先、云端 CDN 自动回落，MultiEffect 单色化着色（对标 QIcon）
// NovaIcon —— 图标（对标 QIcon）
// icon="mdi:home" | "material:favorite" | "material-outlined:settings" ...（不带前缀默认 material）
// 双通道：本地图标包（NovaTheme.iconLocalRoot）优先，缺失自动回落云端 CDN（jsDelivr）
// 封装 QML Image 元素 + MultiEffect 单色化着色；QBtn 等组件的 icon 属性自动识别图标引用
import QtQuick
import QtQuick.Effects
import Nova.Services

Item {
    id: root

    // ── 槽机制（对标 QIcon 默认槽）────────────────────────────
    // 默认子项挂载到图标覆盖层
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

    // 云端 CDN 模板（set → url 模板，%1 为图标名）
    readonly property var _templates: ({
        "mdi": "https://cdn.jsdelivr.net/npm/@mdi/svg/svg/%1.svg",
        "material": "https://cdn.jsdelivr.net/npm/@material-design-icons/svg/filled/%1.svg",
        "material-outlined": "https://cdn.jsdelivr.net/npm/@material-design-icons/svg/outlined/%1.svg",
        "material-round": "https://cdn.jsdelivr.net/npm/@material-design-icons/svg/round/%1.svg",
        "material-sharp": "https://cdn.jsdelivr.net/npm/@material-design-icons/svg/sharp/%1.svg",
        "material-two-tone": "https://cdn.jsdelivr.net/npm/@material-design-icons/svg/two-tone/%1.svg"
    })

    readonly property string _set: {
        var i = icon.indexOf(":")
        if (i > -1 && _templates[icon.substring(0, i)] !== undefined)
            return icon.substring(0, i)
        return "material"
    }

    readonly property string _name: {
        var i = icon.indexOf(":")
        return i > -1 ? icon.substring(i + 1) : icon
    }

    property bool _useCloud: false
    onIconChanged: _useCloud = false

    readonly property string _url: {
        if (source.toString() !== "")
            return source.toString()
        if (icon === "")
            return ""
        if (!_useCloud && NovaTheme.iconLocalRoot.toString() !== "")
            return _stripSlash(NovaTheme.iconLocalRoot.toString())
                    + "/" + _set + "/" + _name + ".svg"
        return _templates[_set].arg(_name)
    }

    function _stripSlash(s) {
        while (s.length > 0 && s.charAt(s.length - 1) === "/")
            s = s.substring(0, s.length - 1)
        return s
    }

    width: size
    height: size

    Image {
        id: img
        anchors.fill: parent
        source: root._url
        sourceSize: Qt.size(root.size, root.size)
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        cache: true
        onStatusChanged: {
            if (status === Image.Error && root.source.toString() === ""
                    && root.icon !== "" && !root._useCloud && root.cloudFallback)
                root._useCloud = true   // 本地图标缺失 → 回落云端
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: img
        colorization: root.monochrome ? 1.0 : 0.0
        colorizationColor: root.color
    }

    // 默认槽宿主：图标之上的覆盖层
    Item { id: overlay; anchors.fill: parent }
}
