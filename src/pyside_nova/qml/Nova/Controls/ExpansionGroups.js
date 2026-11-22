// ExpansionGroups.js
// NovaExpansionItem 分组注册表（对标 QExpansionItem group 手风琴）：
// 同名 group 的条目互斥展开——任一条目展开时，通知组内其余条目收起（受控写回：
// 被收起方只 emit updateModelValue(false) 由宿主落笔，坑位 22 口径）
.pragma library

var _groups = ({})   // name -> [item, ...]

function register(item) {
    var g = String(item.group || "")
    if (g === "") return
    if (!_groups[g]) _groups[g] = []
    if (_groups[g].indexOf(item) === -1)
        _groups[g].push(item)
}

function unregister(item) {
    var g = String(item.group || "")
    if (g === "" || !_groups[g]) return
    var i = _groups[g].indexOf(item)
    if (i !== -1) _groups[g].splice(i, 1)
    if (_groups[g].length === 0) delete _groups[g]
}

// item 展开后调用：收起组内其余条目（经各条目 _closeByGroup 走受控上报）
function closeOthers(item) {
    var g = String(item.group || "")
    if (g === "" || !_groups[g]) return
    var list = _groups[g].slice()
    for (var i = 0; i < list.length; i++) {
        var o = list[i]
        if (o !== item && o._closeByGroup)
            o._closeByGroup()
    }
}
