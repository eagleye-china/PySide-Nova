// src/pyside_nova/qml/Nova/Controls/NovaStepperNavigation.qml
// NovaStepperNavigation 步骤导航槽容器（对标 QStepperNavigation）：default 槽放
// 上一步/下一步等按钮；由宿主 NovaStepper 的 navigation 命名槽挂载渲染
import QtQuick
import Nova.Services

Row {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""            // 可读名覆盖（aria-label 等价）
    Accessible.role: Accessible.Grouping
    Accessible.name: a11yLabel

    // Row 自带 default data 槽——直接声明按钮子项即可
    spacing: NovaTheme.spacingM
    // RTL（0.16.1）：位置器自动镜像（步骤流从右往左）
    LayoutMirroring.enabled: NovaTheme.isRtl
}
