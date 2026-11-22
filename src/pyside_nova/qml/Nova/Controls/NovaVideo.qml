// src/pyside_nova/qml/Nova/Controls/NovaVideo.qml
// NovaVideo 视频嵌入包装（对标 QVideo）：QtMultimedia Video 的皮肤化容器，
// ratio 默认 16/9 等比缩放，controls 常驻（QML Video 自带回放控件）
import QtQuick
import QtMultimedia
import Nova.Services

Item {
    id: root

    // ── 数据源 ──────────────────────────────────────────────
    property url src
    property real ratio: 16 / 9    // >0 强制 height = width / ratio（对标 ratio）
    property string title: ""      // 无障碍语义（对标 title 属性）

    // ⛔ fetchpriority/referrerpolicy/loading：浏览器 iframe 加载语境，QML 不适用
    // ⛔ width/height：QML Item.width/height 本身即尺寸语义，不重复提供

    implicitWidth: 480
    implicitHeight: implicitWidth / ratio
    clip: true

    Accessible.name: title !== "" ? title : "NovaVideo"
    Accessible.role: Accessible.Animation

    onWidthChanged: if (ratio > 0) height = width / ratio
    onRatioChanged: if (ratio > 0 && width > 0) height = width / ratio

    // 播放器惰性创建：src 为空不实例化 Video（无音频服务环境初始化 FFmpeg 音频会挂死，
    // 且空源本就只有占位提示——按需实例化思路与整体交付纪律一致）
    Loader {
        anchors.fill: parent
        active: root.src.toString() !== ""
        sourceComponent: playerComp
    }

    Component {
        id: playerComp
        Video {
            anchors.fill: parent
            source: root.src
            autoPlay: false
            fillMode: VideoOutput.PreserveAspectCrop
        }
    }

    // 空源提示（令牌取色）
    Rectangle {
        anchors.fill: parent
        color: NovaTheme.surfaceAlt
        visible: root.src.toString() === ""
        Text {
            anchors.centerIn: parent
            text: "设置 src 播放视频"
            color: NovaTheme.textMuted
            font.pixelSize: NovaTheme.fontS
        }
    }
}
