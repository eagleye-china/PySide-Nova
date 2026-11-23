// src/pyside_nova/qml/Nova/Controls/NovaResponsive.qml
// NovaResponsive 等比例容器（对标 QResponsive）：ratio > 0 时强制 height = width / ratio，
// 内容铺满容器（use-ratio 组合函数 1:1；ratio 缺省时高度交给宿主/内容自定）
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    // ── 默认槽：内容铺满容器（对标 default slot） ────────────
    default property alias content: inner.data

    // ── 宽高比（对标 ratio；Quasar useRatio：非法值视为无比例） ──
    property real ratio: 0    // >0 生效：height = width / ratio

    clip: true
    implicitWidth: 320
    implicitHeight: ratio > 0 ? implicitWidth / ratio : 200

    onWidthChanged: if (ratio > 0) height = width / ratio
    onRatioChanged: if (ratio > 0 && width > 0) height = width / ratio

    Item {
        id: inner
        anchors.fill: parent
    }
}
