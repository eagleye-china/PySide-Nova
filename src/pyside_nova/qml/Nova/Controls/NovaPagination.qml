// src/pyside_nova/qml/Nova/Controls/NovaPagination.qml
// NovaPagination 页码器（对标 QPagination）
// 受控模式（坑位 22）：不自写 page —— pageRequested(next) 上报，宿主写回
import QtQuick
import Nova.Services
import Nova.Behaviors
import Nova.Design

Rectangle {
    id: root

    // ── 可访问性（WCAG 2.1 AA · 0.16.0）────────────────────────────
    property string a11yLabel: ""
    Accessible.role: Accessible.Grouping
    Accessible.name: a11yLabel            // 分页器无文案属性（label 属内部导航钮），可读名走 a11yLabel
    Accessible.focusable: true
    Accessible.focused: activeFocus
    activeFocusOnTab: true
    Keys.onRightPressed: root.nextPage()
    Keys.onLeftPressed: root.prevPage()
    // Home/End 走通用 onPressed：Qt 6.12 无 Keys.onEndPressed 专用信号
    Keys.onPressed: function(ev) {
        if (ev.key === Qt.Key_Home) { root.requestPage(1); ev.accepted = true }
        else if (ev.key === Qt.Key_End) { root.requestPage(root.pages); ev.accepted = true }
    }

    property int page: 1                    // 当前页（宿主写回）
    property int pages: 1                   // 总页数
    property int maxPages: 5                // 最多显示的页码按钮数
    property bool boundaryLinks: false      // 首末页快捷键（«»）
    property bool ellipses: false           // 省略号
    property bool arrows: true              // 前后翻页箭头
    property bool disable: false
    property color activeColor: NovaTheme.primary // 对标 color（页码选中底色）
    property string inputStyle: "filled"    // 保留 API 面

    signal pageRequested(int page)

    width: 400
    height: 36
    color: "transparent"

    // 计算可见页码序列（maxPages 滑窗 + 可选省略号）
    function visiblePages() {
        var out = []
        if (pages <= 0)
            return out
        var win = Math.max(1, maxPages)
        var start = Math.max(1, page - Math.floor(win / 2))
        var end = Math.min(pages, start + win - 1)
        start = Math.max(1, end - win + 1)
        if (ellipses && start > 1) {
            out.push(1)
            if (start > 2)
                out.push("…")
        }
        for (var i = start; i <= end; i++)
            out.push(i)
        if (ellipses && end < pages) {
            if (end < pages - 1)
                out.push("…")
            out.push(pages)
        }
        return out
    }

    function requestPage(p) {
        var next = Math.min(Math.max(1, Math.round(p)), Math.max(1, pages))
        if (next !== page)
            pageRequested(next)
        return next
    }

    function nextPage() { return requestPage(page + 1) }
    function prevPage() { return requestPage(page - 1) }

    implicitHeight: 36

    Row {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        // RTL（0.16.1）：位置器自动镜像（首按钮排到右侧），箭头字符随之取反
        LayoutMirroring.enabled: NovaTheme.isRtl
        spacing: 4

        component NavBtn: Rectangle {
            id: nb
            property string label: ""
            property bool nav: true          // 箭头/边界按钮（禁用态逻辑不同）
            width: 32; height: 32; radius: NovaTheme.radiusS
            color: nav ? "transparent" : (root.page === nbPage(nb.tag) ? root.activeColor : NovaTheme.surfaceAlt)
            border.width: nav ? 1 : 0
            border.color: NovaTheme.outline
            property var tag: null

            Text {
                anchors.centerIn: parent
                text: nb.label
                color: {
                    if (root.disable)
                        return NovaTheme.textMuted
                    if (!nb.nav && root.page === nbPage(nb.tag))
                        return NovaTheme.textOnPrimary
                    return NovaTheme.textColor
                }
                font.pixelSize: NovaTheme.fontS
                font.bold: !nb.nav
            }

            function nbPage(t) { return typeof t === "number" ? t : 0 }

            MouseArea {
                anchors.fill: parent
                enabled: !root.disable && (!nb.nav || (nb.tag === -2 ? root.page > 1
                                                       : nb.tag === -1 ? root.page < root.pages
                                                       : true))
                onClicked: {
                    if (nb.nav) {
                        if (nb.tag === -2) root.requestPage(root.page - 1)
                        else root.requestPage(root.page + 1)
                    } else {
                        root.requestPage(nb.tag)
                    }
                }
            }
        }

        NavBtn { visible: root.boundaryLinks; nav: false; label: NovaTheme.isRtl ? "»" : "«"; tag: 1 }
        NavBtn { visible: root.arrows; label: NovaTheme.isRtl ? "›" : "‹"; tag: -2 }
        Repeater {
            model: root.visiblePages()
            NavBtn {
                nav: false
                label: String(modelData)
                tag: typeof modelData === "number" ? modelData : null
            }
        }
        NavBtn { visible: root.arrows; label: NovaTheme.isRtl ? "‹" : "›"; tag: -1 }
        NavBtn { visible: root.boundaryLinks; nav: false; label: NovaTheme.isRtl ? "«" : "»"; tag: root.pages }
    }
    // 焦点环（键盘模态可见；offset 0 = 贴边环，零尺寸增量）
    NovaFocusRing { target: root; offset: 0 }

}
