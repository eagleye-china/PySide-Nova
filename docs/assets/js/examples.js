/* P2-③ 在线示例浏览器（手写资产，数据来自生成物 nova-data.js） */
(function () {
  'use strict';
  var T = window.NovaTool;
  if (!T) { return; }

  T.onReady(function () {
    var root = document.getElementById('nova-examples');
    var site = window.NOVA_SITE;
    if (!root || !site) { return; }

    var mode = 'showcase';
    var compFilter = '';
    var themeFilter = '';
    var status = T.el('span', 'nova-status');
    var grid = T.el('div', 'nova-thumbs');

    var cmd = 'pip install pyside-nova==' + site.version + '\n' +
              'python examples/gallery_launch.py    # 24 页本地组件画廊';
    var cmdPre = T.el('pre', 'nova-code', cmd);

    function lightbox(src) {
      if (document.querySelector('.nova-lightbox')) { return; }
      var box = T.el('div', 'nova-lightbox');
      var img = T.el('img');
      img.src = src;
      img.alt = '放大预览';
      box.appendChild(img);
      box.addEventListener('click', function () {
        document.body.removeChild(box);
      });
      document.body.appendChild(box);
    }

    function render() {
      grid.textContent = '';
      var items = [];
      if (mode === 'showcase') {
        site.components.forEach(function (c) {
          if (compFilter && c.name !== compFilter) { return; }
          if (!c.prefix) { return; }
          ['light', 'dark', 'variant'].forEach(function (t) {
            if (themeFilter && t !== themeFilter) { return; }
            items.push({
              src: T.screenshot(c, t),
              cap: c.name + ' · ' + t
            });
          });
        });
      } else {
        (site.gallery || []).forEach(function (g) {
          items.push({ src: T.gallery(g), cap: 'Gallery · ' + g });
        });
      }
      if (!items.length) {
        grid.appendChild(T.el('p', 'nova-hint', '当前筛选下没有图片。'));
      }
      items.forEach(function (it) {
        var fig = T.el('figure');
        var img = T.el('img');
        img.src = it.src;
        img.alt = it.cap;
        img.loading = 'lazy';
        img.addEventListener('click', function () { lightbox(it.src); });
        fig.appendChild(img);
        fig.appendChild(T.el('figcaption', '', it.cap));
        grid.appendChild(fig);
      });
      status.textContent = '共 ' + items.length + ' 张';
    }

    var bar = T.el('div', 'nova-toolbar');
    bar.appendChild(T.el('label', '', '来源'));
    var modeSel = T.el('select');
    modeSel.setAttribute('aria-label', '图片来源');
    [['showcase', '三态装配图（45）'], ['gallery', '本地 Gallery（24）']].forEach(function (o) {
      var op = T.el('option', '', o[1]);
      op.value = o[0];
      modeSel.appendChild(op);
    });
    modeSel.addEventListener('change', function () {
      mode = modeSel.value;
      compSel.disabled = mode !== 'showcase';
      themeSel.disabled = mode !== 'showcase';
      render();
    });
    bar.appendChild(modeSel);

    var compSel = T.el('select');
    compSel.setAttribute('aria-label', '筛选组件');
    var all = T.el('option', '', '全部 15 项');
    all.value = '';
    compSel.appendChild(all);
    site.components.forEach(function (c) {
      var op = T.el('option', '', c.name);
      op.value = c.name;
      compSel.appendChild(op);
    });
    compSel.addEventListener('change', function () { compFilter = compSel.value; render(); });
    bar.appendChild(compSel);

    var themeSel = T.el('select');
    themeSel.setAttribute('aria-label', '筛选主题');
    [['', '全部主题'], ['light', '浅色'], ['dark', '深色'], ['variant', '变体']]
      .forEach(function (o) {
        var op = T.el('option', '', o[1]);
        op.value = o[0];
        themeSel.appendChild(op);
      });
    themeSel.addEventListener('change', function () { themeFilter = themeSel.value; render(); });
    bar.appendChild(themeSel);

    var copy = T.el('button', 'nova-btn', '复制运行命令');
    copy.type = 'button';
    copy.addEventListener('click', function () { T.copy(cmd, status); });
    bar.appendChild(copy);
    bar.appendChild(status);
    root.appendChild(bar);

    root.appendChild(T.el('h3', '', '本地运行'));
    root.appendChild(cmdPre);
    root.appendChild(T.el('p', 'nova-hint',
      '浏览器内运行 Qt 场景需 Qt for WebAssembly 构建产物与站点部署，本轮未交付（发布边界归 CSA）。'));
    root.appendChild(T.el('h3', '', '渲染产物（点击放大）'));
    root.appendChild(grid);

    render();
  });
})();
