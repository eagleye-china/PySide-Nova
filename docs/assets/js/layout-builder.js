/* P2-① Layout Builder（手写资产，数据来自生成物 nova-data.js） */
(function () {
  'use strict';
  var T = window.NovaTool;
  if (!T) { return; }

  T.onReady(function () {
    var root = document.getElementById('nova-layout-builder');
    var site = window.NOVA_SITE;
    if (!root || !site || !site.components || !site.components.length) { return; }

    var current = site.components[0];
    var state = {};
    var theme = 'light';
    var status = T.el('span', 'nova-status');
    var fields = T.el('div', 'nova-panel');
    var stack = T.el('div', 'nova-stack');
    var preview = T.el('img', 'nova-preview');
    preview.style.display = 'none';
    var code = T.el('pre', 'nova-code');

    function initState(comp) {
      state = {};
      (comp.props || []).forEach(function (p) {
        state[p.name] = (p.default === null || p.default === undefined)
          ? '' : String(p.default);
      });
    }

    function refresh() {
      code.textContent = T.qml(current, state, true);
      var url = T.screenshot(current, theme);
      if (url) {
        preview.src = url;
        preview.style.display = '';
      } else {
        preview.removeAttribute('src');
        preview.style.display = 'none';
      }
      buildStructure();
    }

    function buildStructure() {
      stack.textContent = '';
      stack.appendChild(T.el('div', '', current.name + ' · 组合根容器（anchors.fill: parent）'));
      var bars = (current.props || []).filter(function (p) {
        return /^(show|has|enable|visible|with)/i.test(p.name);
      });
      if (bars.length) {
        bars.forEach(function (p) {
          var b = T.el('div', '', p.name + '  ' + (p.readonly ? '（只读）' : ''));
          b.setAttribute('data-hidden', state[p.name] === 'false' ? 'true' : 'false');
          stack.appendChild(b);
        });
      } else {
        stack.appendChild(T.el('div', '', '无显式栏位开关；以槽位注入为主'));
      }
      (current.slots || []).forEach(function (s) {
        stack.appendChild(T.el('div', '', '槽位 ' + s + ' → Item { anchors.fill: parent }'));
      });
    }

    function buildFields() {
      fields.textContent = '';
      fields.appendChild(T.el('h3', '', '栏位与属性 · ' + current.name));
      fields.appendChild(T.el('p', 'nova-hint',
        '勾选栏位开关、调整数值/字符串属性；下方 QML 与结构预览即时同步。'
        + '只读属性不生成可编辑控件。'));
      var editable = (current.props || []).filter(function (p) { return !p.readonly; });
      if (!editable.length) {
        fields.appendChild(T.el('p', 'nova-hint', '该组件无可编辑公开属性。'));
      }
      editable.forEach(function (p) {
        var row = T.el('div', 'nova-field');
        var lab = T.el('div');
        lab.appendChild(T.el('code', '', p.name));
        lab.appendChild(T.el('div', 'nova-type', p.type));
        row.appendChild(lab);
        if (p.kind === 'bool') {
          var cb = document.createElement('input');
          cb.type = 'checkbox';
          cb.checked = state[p.name] === 'true';
          cb.setAttribute('aria-label', p.name);
          cb.addEventListener('change', function () {
            state[p.name] = cb.checked ? 'true' : 'false';
            refresh();
          });
          row.appendChild(cb);
        } else {
          var inp = document.createElement('input');
          inp.type = 'text';
          inp.value = state[p.name];
          inp.setAttribute('aria-label', p.name + '（' + p.type + '）');
          inp.addEventListener('input', function () {
            state[p.name] = inp.value;
            refresh();
          });
          row.appendChild(inp);
        }
        fields.appendChild(row);
      });
    }

    var bar = T.el('div', 'nova-toolbar');
    bar.appendChild(T.el('label', '', '根容器'));
    var sel = T.el('select');
    sel.setAttribute('aria-label', '选择根容器');
    site.components.forEach(function (c) {
      var o = T.el('option', '', c.name + ' · ' + c.category);
      o.value = c.name;
      sel.appendChild(o);
    });
    sel.addEventListener('change', function () {
      current = site.components.filter(function (c) { return c.name === sel.value; })[0];
      initState(current);
      buildFields();
      refresh();
      status.textContent = '';
    });
    bar.appendChild(sel);

    [['NovaDesktop', 'Desktop 预设'], ['NovaMobile', 'Mobile 预设'],
     ['NovaChat', 'Chat 预设']].forEach(function (preset) {
      var b = T.el('button', 'nova-btn nova-btn--ghost', preset[1]);
      b.type = 'button';
      b.addEventListener('click', function () {
        var found = site.components.filter(function (c) { return c.name === preset[0]; })[0];
        if (!found) { return; }
        current = found;
        sel.value = current.name;
        initState(current);
        buildFields();
        refresh();
        status.textContent = '已载入 ' + preset[1];
      });
      bar.appendChild(b);
    });
    var seg = T.themeButtons(function (t) { theme = t; refresh(); }, 'light');
    bar.appendChild(seg);
    var copy = T.el('button', 'nova-btn', '复制 QML');
    copy.type = 'button';
    copy.addEventListener('click', function () { T.copy(code.textContent, status); });
    bar.appendChild(copy);
    bar.appendChild(status);
    root.appendChild(bar);

    var grid = T.el('div', 'nova-grid');
    var right = T.el('div', 'nova-panel');
    right.appendChild(T.el('h3', '', '结构预览'));
    right.appendChild(stack);
    right.appendChild(T.el('h4', '', '三态装配图'));
    right.appendChild(preview);
    right.appendChild(T.el('h4', '', '生成的 QML 骨架'));
    right.appendChild(code);
    right.appendChild(T.el('p', 'nova-hint',
      '静态生成器：单根容器 + 槽位配置，不提供任意拖拽嵌套或浏览器内 Qt 渲染。'));
    grid.appendChild(fields);
    grid.appendChild(right);
    root.appendChild(grid);

    initState(current);
    buildFields();
    refresh();
  });
})();
