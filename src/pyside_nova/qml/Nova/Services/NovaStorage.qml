// src/pyside_nova/qml/Nova/Services/NovaStorage.qml
// NovaStorage 持久化服务单例：命名空间隔离、JSON 值序列化、Web Storage 别名、落盘到 ini（对标 LocalStorage / SessionStorage）
// NovaStorage —— 全局键值持久化（对标 Quasar $q.localStorage；sessionStorage 语义由 clear() + 不持久模式承载）
// 基线事实（npm quasar@2.35.5 LocalStorage 源码核实）：
//     API 面：set / get / remove / clear / has / getAll / getAllKeys / getLength / isEmpty / setAll
//     以及 Web Storage 兼容别名：setItem / getItem / removeItem；
//     Quasar 的 localStorage 是浏览器原生实现（无命名空间概念）——命名空间与持久化后端为 **Nova 增强**。
// 后端：Nova.Runtime.NovaRuntime（Python 侧 QSettings/IniFormat，不依赖 organizationName）；
//     后端不可用时自动降级为进程内存（persistent=false），API 行为不变，绝不抛错。
// a11y: decorative —— 布局/装饰容器，故意不挂 Accessible.*（避免屏读器噪声）
pragma Singleton
import QtQuick
import Nova.Runtime

QtObject {
    id: db

    // ── 后端与命名空间 ────────────────────────────────────────
    readonly property string storagePath: NovaRuntime ? NovaRuntime.storagePath : ""
    readonly property bool persistent: NovaRuntime !== null && NovaRuntime !== undefined
    readonly property string backend: db.persistent ? "ini" : "memory"

    // 命名空间（Nova 增强：多业务隔离；切换时先落盘旧空间再加载新空间）
    property string namespace: "default"

    // ── 运行时状态 ────────────────────────────────────────────
    property var _data: ({})
    property bool _loaded: false

    Component.onCompleted: db.reload()

    // ── 内部：序列化 / 落盘 ────────────────────────────────────
    function _encode(value) {
        try {
            var s = JSON.stringify(value === undefined ? null : value)
            return s === undefined ? "null" : s
        } catch (e) {
            console.warn("NovaStorage: 值无法 JSON 序列化（" + e + "），按 null 存储")
            return "null"
        }
    }

    function _decode(text) {
        if (!text || text === "")
            return ({})
        try {
            var v = JSON.parse(text)
            return (v && typeof v === "object" && !Array.isArray(v)) ? v : ({})
        } catch (e) {
            console.warn("NovaStorage: 持久化数据损坏，已按空空间载入（" + e + "）")
            return ({})
        }
    }

    function _flush() {
        if (!db.persistent)
            return true
        return NovaRuntime.writeBlob(db.namespace, JSON.stringify(db._data))
    }

    // 从后端重读（Nova 增强：多窗口同步 / 测试）
    function reload() {
        var raw = db.persistent ? NovaRuntime.readBlob(db.namespace) : ""
        db._data = db._decode(raw)
        db._loaded = true
        return db.getLength()
    }

    // 立即落盘（Nova 增强：批量写后手动 sync，等价 QSettings.sync）
    function flush() {
        return db._flush()
    }

    // 切换命名空间（Nova 增强）；返回切换后该空间的键数量
    function useNamespace(name) {
        var next = (name === undefined || name === null || String(name) === "") ? "default" : String(name)
        if (next === db.namespace)
            return db.getLength()
        db._flush()
        db.namespace = next
        db.reload()
        return db.getLength()
    }

    // ── 核心 API（对标 LocalStorage） ──────────────────────────
    function set(key, value) {
        if (key === undefined || key === null) {
            console.warn("NovaStorage: set(key, value) 的 key 不可为空")
            return false
        }
        var k = String(key)
        db._data[k] = value === undefined ? null : value
        return db._flush()
    }

    function get(key, defaultValue) {
        var k = String(key)
        if (!Object.prototype.hasOwnProperty.call(db._data, k))
            return defaultValue === undefined ? null : defaultValue
        var v = db._data[k]
        return v === undefined ? (defaultValue === undefined ? null : defaultValue) : v
    }

    function has(key) {
        return Object.prototype.hasOwnProperty.call(db._data, String(key))
    }

    function remove(key) {
        var k = String(key)
        if (!Object.prototype.hasOwnProperty.call(db._data, k))
            return false
        delete db._data[k]
        db._flush()
        return true
    }

    function clear() {
        var ns = db.namespace
        db._data = ({})
        if (db.persistent)
            NovaRuntime.clearBlob(ns)
        return true
    }

    function getLength() {
        return Object.keys(db._data).length
    }

    function isEmpty() {
        return db.getLength() === 0
    }

    function getAllKeys() {
        return Object.keys(db._data)
    }

    // 返回深拷贝，避免调用方持有内部对象引用直接改库
    function getAll() {
        return JSON.parse(JSON.stringify(db._data))
    }

    function setAll(obj) {
        if (!obj || typeof obj !== "object" || Array.isArray(obj)) {
            console.warn("NovaStorage: setAll(obj) 需要普通对象")
            return false
        }
        db._data = JSON.parse(JSON.stringify(obj))
        return db._flush()
    }

    // ── Web Storage 兼容别名（对标 Quasar localStorage.setItem/getItem/removeItem） ──
    function setItem(key, value) { return db.set(key, value) }
    function getItem(key) { return db.get(key, null) }
    function removeItem(key) { return db.remove(key) }
}
