import QtQuick

Item {
    id: root

    property string name: ""
    property url source: ""
    
    property string iconSize: "md" 
    property color color: Theme.text_primary

    property bool padLeft: false
    property bool padRight: false

    readonly property int _pixelSize: {
        if (iconSize === "xs") return Units.px(12)
        if (iconSize === "sm") return Units.px(16)
        if (iconSize === "md") return Units.px(24)
        if (iconSize === "lg") return Units.px(32)
        if (iconSize === "xl") return Units.px(48)
        return parseInt(iconSize) || Units.px(24)
    }

    // 🌟 补充箭头图标
    readonly property var _iconMap: ({
        "menu": "☰",
        "inbox": "📥",
        "star": "⭐",
        "send": "✈️",
        "drafts": "📝",
        "delete": "🗑️",
        "settings": "⚙️",
        "home": "🏠",
        "search": "🔍",
        "add": "➕",
        "close": "✖️",
        "arrow_back": "⬅️",
        "arrow_forward": "➡️",
        "chevron_left": "◀"
    })

    readonly property string _displayChar: _iconMap[name] !== undefined ? _iconMap[name] : name

    implicitWidth: _pixelSize
    implicitHeight: _pixelSize

    anchors.rightMargin: padLeft ? Units.px(8) : 0
    anchors.leftMargin: padRight ? Units.px(8) : 0

    Text {
        anchors.fill: parent
        visible: root.source.toString() === ""
        text: root._displayChar
        color: root.color
        font.pixelSize: root._pixelSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Image {
        anchors.fill: parent
        visible: root.source.toString() !== ""
        source: root.source
        fillMode: Image.PreserveAspectFit
        asynchronous: true
    }
}
