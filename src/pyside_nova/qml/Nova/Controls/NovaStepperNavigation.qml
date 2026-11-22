// src/pyside_nova/qml/Nova/Controls/NovaStepperNavigation.qml
// NovaStepperNavigation 步骤导航槽容器（对标 QStepperNavigation）：default 槽放
// 上一步/下一步等按钮；由宿主 NovaStepper 的 navigation 命名槽挂载渲染
import QtQuick
import Nova.Services

Row {
    id: root

    // Row 自带 default data 槽——直接声明按钮子项即可
    spacing: NovaTheme.spacingM
}
