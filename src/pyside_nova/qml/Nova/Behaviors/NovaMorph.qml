// src/pyside_nova/qml/Nova/Behaviors/NovaMorph.qml
// NovaMorph 元素形变行为（对标 Quasar v-morph 指令 · 基线 2.35.5 语义）：
// 同 group 的元素间形变过渡——morph() 时旧活动元素退出、ghost 影子从旧几何
// 形变至新元素几何、新元素显示（卡片展开为详情）
// 契约：morph 接管目标可见性（旧隐/新显，命令式切换），目标 visible 勿再绑定；
// active 为快照语义（morph 生效即 true；注册表见 NovaMorphPool 单例）
import QtQuick
import Nova.Services

Item {
    id: beh

    property Item target: parent                     // 形变目标元素
    property string group: ""                        // 形变组名（对标 v-morph group）
    property int duration: 300                       // ghost 形变动画时长
    property color tint: NovaTheme.primary           // ghost 影子颜色
    property real radius: 4                          // ghost 圆角

    // ── 事件 ──────────────────────────────────────────────────
    signal morphStarted()                            // morph 触发（旧元素已隐藏）
    signal morphFinished()                           // 形变完成（新元素已显示、ghost 已回收）
    readonly property bool active: _active           // 本实例最近一次 morph 是否生效
    property bool _active: false

    // ghost 影子：从旧几何动画到新几何后销毁（坑位 7：Item 可内联 Component）
    property Component ghostComp: Component {
        Rectangle {
            color: beh.tint
            radius: beh.radius
            opacity: 0.92

            Behavior on x { NumberAnimation { duration: beh.duration; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: beh.duration; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: beh.duration; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: beh.duration; easing.type: Easing.OutCubic } }
        }
    }

    Component.onCompleted: {
        // 登记（首个成员成为默认活动元素；可见性初始态由宿主持有）
        if (group !== "" && target !== null)
            NovaMorphPool.register(group, target)
    }
    Component.onDestruction: {
        if (target !== null) NovaMorphPool.unregister(group, target)
    }

    // ── 触发形变：自身成为该组活动元素 ────────────────────────
    function morph() {
        if (group === "" || target === null) return false
        var self = target
        var old = NovaMorphPool.current(group)
        morphStarted()
        _active = true

        if (old !== null && old !== self) {
            // 旧元素几何 → self.parent 坐标系（跨父级映射）
            var r = self.parent !== null
                    ? self.parent.mapFromItem(old, 0, 0, old.width, old.height)
                    : Qt.rect(self.x, self.y, self.width, self.height)
            old.visible = false
            if (duration > 0 && self.parent !== null && r.width > 0) {
                var ghost = ghostComp.createObject(self.parent, {
                    x: r.x, y: r.y, width: r.width, height: r.height
                })
                self.visible = false
                Qt.callLater(function() {
                    if (ghost === null) return
                    ghost.x = self.x
                    ghost.y = self.y
                    ghost.width = self.width
                    ghost.height = self.height
                })
                var t = Qt.createQmlObject(
                    'import QtQuick; Timer { }', beh, "_morphTimer")
                t.interval = duration + 40
                t.repeat = false
                t.triggered.connect(function() {
                    if (ghost !== null) ghost.destroy()
                    self.visible = true
                    morphFinished()
                    t.destroy()
                })
                t.start()                             // 坑位 19：动态创建 Timer 必须显式 start
                NovaMorphPool.setCurrent(group, self)
                return true
            }
        }
        // 无旧元素 / 零时长：直接切换
        if (old !== null && old !== self) old.visible = false
        self.visible = true
        morphFinished()
        NovaMorphPool.setCurrent(group, self)
        return true
    }

    // 当前是否为组内活动元素（命令式调用，勿走派生绑定——坑位 24/28）
    function isActive() {
        return NovaMorphPool.current(group) === target
    }
}