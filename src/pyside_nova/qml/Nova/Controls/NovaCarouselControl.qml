// src/pyside_nova/qml/Nova/Controls/NovaCarouselControl.qml
// NovaCarouselControl 轮播覆盖控件（对标 QCarouselControl）：声明于 NovaCarousel 内部，
// 完成后自动挂载到轮播覆盖层并按 position/offset 锚定；default 槽为控件内容
import QtQuick
import Nova.Services

Item {
    id: ctrl

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.Grouping
    Accessible.name: a11yLabel

    // ── 默认槽：控件内容 ─────────────────────────────────────
    default property alias content: host.data

    // ── 属性（对标 position/offset） ────────────────────────
    property string position: "bottom-right"   // top-left/top/top-right/left/right/bottom-left/bottom/bottom-right
    property real offset: 16                   // 距覆盖层边缘像素

    // 宿主识别标记（NovaCarousel 收纳覆盖控件时过滤，勿删）
    readonly property bool _isNovaCarouselControl: true

    // 挂载完成后向上遍历找 NovaCarousel（坑位 14：向上遍历找宿主）
    Component.onCompleted: _attach()
    onPositionChanged: if (_host !== null) _applyLayout()

    property var _host: null

    function _attach() {
        var p = parent
        while (p !== null) {
            if (p.isNovaCarousel === true) {
                _host = p
                p._registerControl(ctrl)
                _applyLayout()
                return
            }
            p = p.parent
        }
    }

    function _applyLayout() {
        // 以覆盖层（_host.controlLayerItem）为锚定基准
        var layer = _host.controlLayerItem
        anchors.right = undefined
        anchors.left = undefined
        anchors.top = undefined
        anchors.bottom = undefined
        anchors.horizontalCenter = undefined
        anchors.verticalCenter = undefined
        var h = position.indexOf("left") !== -1 ? "left"
              : position.indexOf("right") !== -1 ? "right"
              : position === "left" || position === "right" ? position : ""
        var v = position.indexOf("top") !== -1 ? "top"
              : position.indexOf("bottom") !== -1 ? "bottom"
              : position === "top" || position === "bottom" ? position : ""
        if (h === "left") { anchors.left = layer.left; anchors.leftMargin = offset }
        else if (h === "right") { anchors.right = layer.right; anchors.rightMargin = offset }
        if (v === "top") { anchors.top = layer.top; anchors.topMargin = offset }
        else if (v === "bottom") { anchors.bottom = layer.bottom; anchors.bottomMargin = offset }
        if (h === "" && v !== "") {
            // 纯 top/bottom：水平居中
            anchors.horizontalCenter = layer.horizontalCenter
        }
        if (v === "" && h !== "") {
            // 纯 left/right：垂直居中
            anchors.verticalCenter = layer.verticalCenter
        }
    }

    Item {
        id: host
    }
}
