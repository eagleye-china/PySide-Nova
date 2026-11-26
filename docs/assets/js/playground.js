/* P1-③ 在线可调参 Playground（手写资产，数据来自生成物 nova-data.js） */
(function () {
  'use strict';
  var T = window.NovaTool;
  if (!T) { return; }

  T.onReady(function () {
    var root = document.getElementById('nova-playground');
    var site = window.NOVA_SITE;
    if (!root || !site || !site.components || !site.components.length) { return; }

    var state = {};
    var current = site.components[0];
    var theme = 'light';
    var status = T.el('span', 'nova-status');
    var fieldsBox = T.el('div', 'nova-panel');
    var preview = T.el('img', 'nova-preview');
    preview.alt = '三态装配图预览';
    var code = T.el('pre', 'nova-code');
    var tbody = T.el('tbody');
    var table = T.el('table', 'nova-table');
    var thead = T.el('thead');
    var hrow = T.el('tr');
    ['属性', '类型', '当前值'].forEach(function (h) {
      var th = T.el('th', '', h);
      hrow.appendChild(th);
    });
    thead.appendChild(hrow);
    table.appendChild(thead);
    table.appendChild(tbody);

    function initState(comp) {
      state = {};
      (comp.props || []).forEach(function (p) {
        state[p.name] = (p.default === null || p.default === undefined)
          ? '' : String(p.default);
      });
    }

    function refreshTable() {
      tbody.textContent = '';
      (current.props || []).forEach(function (p) {
        var tr = T.el('tr');
        tr.appendChild(T.el('td', '', p.name + (p.readonly ? ' (只读)' : '')));
        tr.appendChild(T.el('td', '', p.type));
        tr.appendChild(T.el('td', '', state[p.name] === '' ? '—' : state[p.name]));
        tbody.appendChild(tr);
      });
    }

    function refresh() {
      code.textContent = T.qml(current, state, true);
      refreshTable();
      var url = T.screenshot(current, theme);
      if (url) {
        preview.src = url;
        preview.style.display = '';
        preview.alt = current.name + ' · ' + theme + ' 三态装配图';
      } else {
        preview.removeAttribute('src');
        preview.style.display = 'none';
      }
    }

    function buildFields() {
      fieldsBox.textContent = '';
      fieldsBox.appendChild(T.el('h3', '', '参数面板 · ' + current.name));
      var hint = T.el('p', 'nova-hint',
        '默认值取自 api/nova-api-1.2.0.json 冻结面；别名槽位（' +
        (current.slots || []).length + ' 个）按 CC-6 自动注入，不在此面板编辑。');
      fieldsBox.appendChild(hint);
      if (!current.props || !current.props.length) {
        fieldsBox.appendChild(T.el('p', 'nova-hint', '该组件无公开配置属性。'));
        return;
      }
      current.props.forEach(function (p) {
        var row = T.el('div', 'nova-field' + (p.readonly ? ' nova-field--ro' : ''));
        var lab = T.el('div');
        lab.appendChild(T.el('code', '', p.name));
        lab.appendChild(T.el('div', 'nova-type',
          p.type + (p.readonly ? ' · 只读' : ' · 可编辑')));
        row.appendChild(lab);
        if (p.readonly) {
          row.appendChild(T.el('code', '',
            state[p.name] === '' ? '—' : state[p.name]));
        } else if (p.kind === 'bool') {
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
        fieldsBox.appendChild(row);
      });
    }

    /* 工具栏 */
    var bar = T.el('div', 'nova-toolbar');
    bar.appendChild(T.el('label', '', '组合根容器'));
    var sel = T.el('select');
    sel.setAttribute('aria-label', '选择组合根容器');
    var cats = {};
    site.components.forEach(function (c) {
      if (!cats[c.category]) {
        var g = document.createElement('optgroup');
        g.label = c.category;
        cats[c.category] = g;
        sel.appendChild(g);
      }
      var o = T.el('option', '', c.name + ' · ' + c.title);
      o.value = c.name;
      cats[c.category].appendChild(o);
    });
    sel.addEventListener('change', function () {
      current = site.components.filter(function (c) { return c.name === sel.value; })[0];
      initState(current);
      buildFields();
      refresh();
      status.textContent = '';
    });
    bar.appendChild(sel);
    var seg = T.themeButtons(function (t) { theme = t; refresh(); }, 'light');
    bar.appendChild(seg);
    var copy = T.el('button', 'nova-btn', '复制 QML');
    copy.type = 'button';
    copy.addEventListener('click', function () { T.copy(code.textContent, status); });
    bar.appendChild(copy);
    bar.appendChild(status);
    root.appendChild(bar);

    /* 两栏主体 */
    var grid = T.el('div', 'nova-grid');
    var right = T.el('div', 'nova-panel');
    right.appendChild(T.el('h3', '', '三态装配图预览'));
    preview.style.display = 'none';
    right.appendChild(preview);
    var cap = T.el('p', 'nova-hint',
      '真实 Qt Quick 引擎渲染产物（audit_showcase.py）；参数改动实时改写下方 QML，浏览器内不重渲染场景。');
    right.appendChild(cap);
    right.appendChild(T.el('h4', '', '实时 QML 片段'));
    right.appendChild(code);
    right.appendChild(T.el('h4', '', '当前属性表'));
    right.appendChild(table);
    grid.appendChild(fieldsBox);
    grid.appendChild(right);
    root.appendChild(grid);

    initState(current);
    buildFields();
    refresh();
  });
})();
