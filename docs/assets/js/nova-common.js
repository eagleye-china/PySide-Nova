/* 文档站工具页共享逻辑（手写资产，数据来自生成物 nova-data.js） */
(function () {
  'use strict';
  var T = {};

  T.onReady = function (fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn);
    } else { fn(); }
  };

  T.el = function (tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) { e.className = cls; }
    if (text !== undefined && text !== null) { e.textContent = String(text); }
    return e;
  };

  T.copy = function (text, status) {
    function done(ok) {
      if (status) { status.textContent = ok ? '已复制到剪贴板' : '复制失败，请手动选择代码'; }
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(
        function () { done(true); }, function () { done(false); });
      return;
    }
    var ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    var ok = false;
    try { ok = document.execCommand('copy'); } catch (e) { ok = false; }
    document.body.removeChild(ta);
    done(ok);
  };

  /* 生成可运行 QML：属性名/默认值全部来自冻结面，槽位遵循 CC-6 */
  T.qml = function (comp, state, withSlot) {
    var lines = ['import QtQuick', 'import Nova.Composite.LayoutShell', '',
                 comp.name + ' {', '    anchors.fill: parent'];
    (comp.props || []).forEach(function (p) {
      if (p.readonly) { return; }
      var v = state[p.name];
      if (v === undefined || v === null || v === '') { return; }
      lines.push('    ' + p.name + ': ' + v);
    });
    if (withSlot && comp.slots && comp.slots.length) {
      lines.push('', '    ' + comp.slots[0] + ': Item {',
                 '        anchors.fill: parent',
                 '        // 业务内容：注入顶层须铺满（CC-6）', '    }');
    }
    lines.push('}');
    return lines.join('\n');
  };

  /* 页面位于 <site>/tools/ 或 <site>/en/，统一用 document.baseURI 解析 */
  T.asset = function (rel) {
    return new URL(rel, document.baseURI).href;
  };

  T.screenshot = function (comp, theme) {
    if (!comp.prefix) { return ''; }
    return T.asset('../screenshots/' + comp.prefix + '_showcase_' + theme + '.png');
  };

  T.gallery = function (name) {
    return T.asset('../assets/gallery/' + name);
  };

  T.themeButtons = function (onChange, initial) {
    var box = T.el('span', 'nova-seg');
    var current = initial || 'light';
    var items = [['light', '浅色'], ['dark', '深色'], ['variant', '变体']];
    var btns = {};
    items.forEach(function (it) {
      var b = T.el('button', '', it[1]);
      b.type = 'button';
      b.setAttribute('aria-pressed', it[0] === current ? 'true' : 'false');
      b.addEventListener('click', function () {
        current = it[0];
        Object.keys(btns).forEach(function (k) {
          btns[k].setAttribute('aria-pressed', k === current ? 'true' : 'false');
        });
        onChange(current);
      });
      btns[it[0]] = b;
      box.appendChild(b);
    });
    box.value = function () { return current; };
    return box;
  };

  window.NovaTool = T;
})();
