// src/pyside_nova/qml/Nova/Controls/NovaPage.qml
// NovaPage 页面容器：NovaLayout 之页面象限内容包装，统一 padding，类型扫描后自动铺满页面区（对标 QPage）
// NovaPage —— 页面容器（对标 QPage + QPageContainer）
// 用法：作为 NovaLayout 直接子项声明即自动铺满页面区；padding 控制内边距
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    default property alias content: body.data

    property int padding: NovaTheme.spacingL

    implicitWidth: 400
    implicitHeight: 300

    Item {
        id: body
        anchors {
            fill: parent
            margins: root.padding
        }
    }
}
