// src/pyside_nova/qml/Nova/Behaviors/NovaMorphPool.qml
// NovaMorphPool 形变分组注册表（单例）：group -> 当前活动目标 Item
// NovaMorph 依赖它协调同名 group 的元素切换（旧隐/新显 + 几何形变）
// ── 实现口径留痕：曾用 .pragma library JS 共享注册表，实测呈现
// per-importing-file 实例化（同 group 两实例互相看不见对方的注册），
// 改 QML 单例（Services 模块同款惯例）保证引擎级唯一（0.15.0 沉淀）
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma Singleton
import QtQuick

QtObject {
    property var _map: ({})                      // group -> Item

    // 首个成员登记：仅当组为空时生效（成为默认活动元素）
    function register(group, item) {
        var g = String(group || "")
        if (g === "" || item === null || item === undefined) return
        if (_map[g] === undefined || _map[g] === null)
            _map[g] = item
    }

    // 强制切换活动元素（morph 触发时调用）
    function setCurrent(group, item) {
        var g = String(group || "")
        if (g === "" || item === null || item === undefined) return
        _map[g] = item
    }

    // 注销（析构时）
    function unregister(group, item) {
        var g = String(group || "")
        if (g === "") return
        if (_map[g] === item) delete _map[g]
    }

    // 当前活动元素（无注册返回 null）
    function current(group) {
        var g = String(group || "")
        return _map[g] !== undefined ? _map[g] : null
    }
}