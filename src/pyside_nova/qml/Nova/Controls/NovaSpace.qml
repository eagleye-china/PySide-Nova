// src/pyside_nova/qml/Nova/Controls/NovaSpace.qml
// NovaSpace 占位空白（对标 QSpace）
// NovaSpace —— 弹性占位（对标 QSpace）
// 在 RowLayout / ColumnLayout 中自动撑满剩余空间
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import QtQuick.Layouts

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true
}
