// src/pyside_nova/qml/Nova/Controls/NovaItemSection.qml
// NovaItemSection 条目分区（对标 QItemSection）：avatar/thumbnail/trailing/topAligned
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    default property alias content: inner.data

    property bool avatar: false             // 48px 圆形头像区
    property bool thumbnail: false          // 56px 缩略图区
    property bool trailing: false           // 右侧分区（对标 side）
    property bool topAligned: false         // 顶部对齐分区（对标 top；top 为 Item FINAL 属性）

    width: avatar || thumbnail ? (thumbnail ? 56 : 48)
           : trailing ? 40 : 100
    height: avatar || thumbnail ? (thumbnail ? 56 : 48)
            : inner.implicitHeight

    Column {
        id: inner
        anchors {
            left: parent.left
            right: parent.right
            top: root.topAligned || root.avatar || root.thumbnail ? parent.top : undefined
            verticalCenter: (root.topAligned || root.avatar || root.thumbnail) ? undefined : parent.verticalCenter
        }
        spacing: 2
    }
}
