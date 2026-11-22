// src/pyside_nova/qml/Nova/Controls/NovaItemLabel.qml
// NovaItemLabel 条目标签（对标 QItemLabel）：overline/caption/header/lines
import QtQuick
import Nova.Services

Text {
    id: root

    property bool overline: false           // 上标签样式（小号大写字距）
    property bool caption: false            // 辅助文字（小号灰）
    property bool header: false             // 列表分节标题
    property int lines: 0                   // 0=不省略；>0=ellipsis 行数

    color: overline ? NovaTheme.textMuted
            : caption ? NovaTheme.textMuted
            : header ? NovaTheme.primary
            : NovaTheme.textColor
    font.pixelSize: overline || caption ? NovaTheme.fontXS
                     : header ? NovaTheme.fontS
                     : NovaTheme.fontM
    font.weight: header || overline ? Font.Bold : Font.Normal
    font.letterSpacing: overline ? 1 : 0
    opacity: caption ? 0.9 : 1

    wrapMode: lines > 0 ? Text.Wrap : Text.NoWrap
    maximumLineCount: lines > 0 ? lines : 2147483647
    elide: lines > 0 ? Text.ElideRight : Text.ElideNone
}
