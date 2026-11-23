// src/pyside_nova/qml/Nova/Controls/NovaRow.qml
// NovaRow 栅格行：12 栅格水平排布 + wrap 换行 + justify/align 对齐，与 NovaCol 配合使用（对标 Quasar Flex row）
// NovaRow —— 栅格行（对标 Quasar row + q-gutter + justify-*/items-* 工具类）
// 用法：子项用 NovaCol（cols 1~12 占栅格数）；普通子项按自身 width 排布。
//       justify: start|center|end|between；align: top|center|bottom；wrap 换行。
//       宽度变化 / 子项增删 / NovaCol.cols 变化时自动重排
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Item {
    id: root

    // 默认槽即 Item.data：子项（NovaCol / 普通元素）由 relayout() 定位

    property real spacing: NovaTheme.spacingM
    property string justify: "start"   // start | center | end | between
    property string align: "top"       // top | center | bottom
    property bool wrap: false

    onWidthChanged: relayout()
    onChildrenChanged: relayout()
    Component.onCompleted: relayout()

    function relayout() {
        var items = []
        for (var i = 0; i < children.length; i++)
            items.push(children[i])
        if (items.length === 0) {
            implicitHeight = 0
            return
        }

        // 分行
        var lines = [ [] ]
        var lineWidths = [ 0 ]
        var lineHeights = [ 0 ]
        var x = 0
        for (var j = 0; j < items.length; j++) {
            var it = items[j]
            var w = it.width
            if (root.wrap && x > 0 && x + w > root.width) {
                lines.push([])
                lineWidths.push(0)
                lineHeights.push(0)
                x = 0
            }
            var cur = lines.length - 1
            lines[cur].push(it)
            lineWidths[cur] += w
            lineHeights[cur] = Math.max(lineHeights[cur], it.height)
            x += w + root.spacing
        }

        // 逐行排布
        var y = 0
        for (var l = 0; l < lines.length; l++) {
            var line = lines[l]
            var n = line.length
            if (n === 0)
                continue
            var sumW = lineWidths[l]
            var startX = 0
            var gap = root.spacing
            if (justify === "center")
                startX = (root.width - sumW - gap * (n - 1)) / 2
            else if (justify === "end")
                startX = root.width - sumW - gap * (n - 1)
            else if (justify === "between" && n > 1)
                gap = (root.width - sumW) / (n - 1)

            var cx = startX
            for (var k = 0; k < n; k++) {
                var c = line[k]
                var off = (c instanceof NovaCol) ? root.width * c.offset / 12 : 0
                c.x = Math.round(cx + off)
                if (align === "center")
                    c.y = Math.round(y + (lineHeights[l] - c.height) / 2)
                else if (align === "bottom")
                    c.y = Math.round(y + lineHeights[l] - c.height)
                else
                    c.y = y
                cx += off + c.width + gap
            }
            y += lineHeights[l] + (l < lines.length - 1 ? root.spacing : 0)
        }
        implicitHeight = Math.max(y, 0)
    }
}
