/* P1-① 站点版本切换器（手写资产，数据来自生成物 nova-data.js） */
(function () {
  'use strict';
  function mount() {
    if (document.getElementById('nova-version-switch')) { return; }
    var site = window.NOVA_SITE;
    if (!site || !site.versions || !site.versions.length) { return; }
    var host = document.querySelector('.md-header__inner') ||
               document.querySelector('.md-header');
    if (!host) { return; }

    var wrap = document.createElement('div');
    wrap.id = 'nova-version-switch';
    wrap.className = 'nova-version';
    var label = document.createElement('label');
    label.setAttribute('for', 'nova-version-select');
    label.textContent = '版本';
    var select = document.createElement('select');
    select.id = 'nova-version-select';
    select.setAttribute('aria-label', '文档版本');
    site.versions.forEach(function (v) {
      var opt = document.createElement('option');
      opt.textContent = v.label;
      opt.value = v.url || '';
      if (!v.url) { opt.selected = true; }
      select.appendChild(opt);
    });
    select.addEventListener('change', function () {
      if (select.value) { window.location.href = select.value; }
    });
    wrap.appendChild(label);
    wrap.appendChild(select);
    host.appendChild(wrap);
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount);
  } else { mount(); }
})();
