# pyside-nova Documentation

> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；重跑生成器即可同步。

**English coverage:** 5 pages (home, components, playground, layout builder, community). The remaining documentation is currently available in Chinese only; use the language switcher in the header to return to the Chinese site.

pyside-nova **1.7.0 GA** is an enterprise PySide6 / QML component library with **147 exported types**, including **21 composite root containers** (21/21 CARF ceiling sign-off). Public API fingerprint `157ab2b1d77ea9f9` is frozen.

## Quick start

```bash
pip install pyside-nova==1.7.0
python examples/gallery_launch.py   # 24-page local component gallery
```

```qml
import QtQuick
import Nova.Composite.LayoutShell

NovaDesktop {
    anchors.fill: parent
}
```

## Explore

- [21 composite root containers](components.md) (full per-component API pages are in Chinese)
- [Online playground](playground.md) · [Layout Builder](layout-builder.md)
- [Community](community.md) · [Chinese documentation home](../index.md)
- [GitHub](https://github.com/eagleye-china/pyside-nova) · [PyPI](https://pypi.org/project/pyside-nova/)
