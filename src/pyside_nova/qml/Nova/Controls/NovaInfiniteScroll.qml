// src/pyside_nova/qml/Nova/Controls/NovaInfiniteScroll.qml
// NovaInfiniteScroll 无限滚动（对标 QInfiniteScroll）
// 滚动近底 emit load(index, done)：宿主追加内容后 done(false) 继续；done(true) 停止
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
import QtQuick
import Nova.Services

Flickable {
    id: root

    default property alias content: body.data

    property real offset: 100               // 触底提前量（px）
    property bool disable: false

    signal load(int index, var done)

    clip: true
    contentWidth: width
    contentHeight: body.height + NovaTheme.spacingL

    property int _batch: 0
    property bool _stop: false
    property bool _busy: false

    function resume() {                     // 停止后重新武装
        _stop = false
        _busy = false
        _maybeLoad()
    }

    function _maybeLoad() {
        if (disable || _stop || _busy)
            return
        if (contentY + height >= contentHeight - offset && contentHeight > 0) {
            _busy = true
            var batch = _batch
            _batch = _batch + 1
            load(batch, function (stop) {
                root._busy = false
                if (stop === true)
                    root._stop = true
                else
                    root._maybeLoad()
            })
        }
    }

    onContentYChanged: _maybeLoad()
    onHeightChanged: _maybeLoad()

    Column {
        id: body
        width: root.width
        spacing: NovaTheme.spacingS
    }
}
