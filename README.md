<div align="center">

# pyside-nova

**The Quasar of the Qt Quick world** — an enterprise-grade QML component library for PySide6.

对标 [Quasar Framework](https://quasar.dev/) 的组件生态，为 Qt Quick / PySide6 提供
统一的设计令牌（Theme）、组件（Controls）、行为（Behaviors）、服务（Services）四层体系。

[![CI](https://github.com/your-name/pyside-nova/actions/workflows/ci.yml/badge.svg)](https://github.com/your-name/pyside-nova/actions/workflows/ci.yml)
[![PyPI](https://img.shields.io/pypi/v/pyside-nova)](https://pypi.org/project/pyside-nova/)
[![Python](https://img.shields.io/pypi/pyversions/pyside-nova)](https://pypi.org/project/pyside-nova/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-README_zh.md-blue)](README_zh.md)

</div>

> 🇨🇳 中文文档：**[README_zh.md](README_zh.md)**

- **Baseline**: Windows 11 / macOS / Linux · Python 3.10–3.13 · PySide6 ≥ 6.8 (verified on **6.12.0**)
- **Target**: **Quasar `2.26.0`** (verified against official releases) · Status: `0.3.0` — slots, parity audit + Constitution · Freeze: `1.0.0-flagship` LTS
- **Constitution**: [docs/CONSTITUTION.md](docs/CONSTITUTION.md) — iterated with every delivery
- **Ecosystem Parity White Paper**: [docs/ECOSYSTEM_PARITY.md](docs/ECOSYSTEM_PARITY.md) — 7-layer maturity, 12 P0 gaps, 24 release gates

## Why pyside-nova

Qt Quick Controls covers the basics, but enterprise apps need the *whole* Quasar story:
opinionated theming, breakpoints, icon sets, form systems, data tables, notifications.
**pyside-nova ports that ecosystem to pure QML + PySide6**, with a 1:1 Quasar-style API
so Vue/Quasar developers feel at home — and a frozen, audit-friendly enterprise release
process for everyone else.

## Features

- 🎨 **Three-tier design tokens** — base → semantic → component tokens in the `NovaTheme`
  singleton; light/dark with one call; runtime brand re-skinning
- 🧩 **Quasar-style API** — `QBtn → NovaBtn`, `QCard → NovaCard`; property names aligned,
  near-zero learning cost for Quasar developers
- 🧱 **Slot system** — Quasar slots mapped to QML: default slot → `default property alias`
  (NovaBtn/Chip/Avatar/Icon/Badge/Card family), named slots → composed sub-components,
  scoped slots → `Component delegates` (mandated in the Constitution)
- 🖥️ **Breakpoints** — `NovaScreen` ports Quasar's Screen plugin 1:1
  (xs/sm/md/lg/xl = 600/1024/1440/1920, `is*` / `lt*` / `gt*`)
- 🖼️ **Dual-channel icons** — `NovaIcon { icon: "mdi:home" }` resolves MDI / Material
  icons from a local pack (offline) with automatic CDN fallback
- 📦 **pip-ready** — QML modules ship inside the wheel; one line to bootstrap
- ✅ **Verified, not promised** — 32 smoke tests (incl. demo & gallery load) run in CI on a real
  QML engine (Windows + Linux matrix)

## Installation

```bash
pip install pyside-nova          # from PyPI (after release)
pip install -e ".[dev]"          # local development
```

## Quick start

```python
# main.py
import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from pyside_nova import init_nova

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
init_nova(engine)          # registers Nova.* QML import paths
engine.load("main.qml")
sys.exit(app.exec())
```

```qml
// main.qml
import QtQuick
import QtQuick.Controls.Basic
import Nova.Services
import Nova.Controls
import Nova.Behaviors

ApplicationWindow {
    visible: true
    color: NovaTheme.page

    Column {
        anchors.centerIn: parent
        spacing: 12
        NovaBtn { text: "Primary action" }
        NovaChip { text: "QML"; removable: true }
        Rectangle {
            width: 140; height: 60; radius: 8
            color: NovaTheme.primary
            NovaRipple { }                    // ripple behavior, mounted as child
        }
        NovaBtn {
            icon: "🔔"
            round: true
            NovaBadge { text: "99+" }         // badge, mounted as child
        }
    }
}
```

> **API note**: the accent-color property is named `tint` (not `color`) because `color`
> clashes with the base `Rectangle` property in QML — same visual role as QBtn's `color`.

### Gallery

```bash
python examples/gallery/main.py    # full component gallery with sidebar navigation
python examples/demo/main.py       # compact demo
```

## Component status

| Component | Quasar counterpart | Notes | Status |
|---|---|---|---|
| `NovaTheme` | Dark plugin + brand vars | Token singleton, dark mode, brand re-skin, shadows | ✅ 0.1.0 |
| `NovaBtn` | QBtn | filled/outlined/flat, ripple, loading, keyboard | ✅ 0.1.0 |
| `NovaCard` family | QCard family | Card / CardSection / CardActions, MultiEffect shadows | ✅ 0.1.0 |
| `NovaChip` | QChip | filled/outlined/tinted, selectable, removable | ✅ 0.1.0 |
| `NovaAvatar` | QAvatar | auto-color text / emoji / image | ✅ 0.1.0 |
| `NovaIcon` | QIcon | `icon="mdi:home"`, local pack + CDN fallback, tinting | ✅ 0.1.0 |
| `NovaScreen` | Screen plugin | xs/sm/md/lg/xl breakpoints, is/lt/gt semantics | ✅ 0.1.0 |
| `NovaBadge` | QBadge | dot / value / floating, child-mount | ✅ 0.1.0 |
| `NovaRipple` | v-ripple | child-mount ripple (built into NovaBtn) | ✅ 0.1.0 |
| `NovaSpace` / `NovaSeparator` | QSpace / QSeparator | layout primitives | ✅ 0.1.0 |
| `NovaField` / `NovaInput` | QField / QInput | unified field wrapper | 🚧 M1 |
| `NovaForm` / `NovaSelect` | QForm / QSelect | rule validation, multi-select + filter | 🚧 M1 |
| `NovaDate` | QDate | calendar picker (Qt 6 ships none) | 🚧 M1 |
| `NovaLayout` | QLayout | header/footer/drawer/page integrated layout | 🚧 M1 |
| `NovaTable` | QTable | sort/filter/paginate/multi-select data table | 🚧 M1 |
| `NovaNotify` / `NovaDialog` | Notify / Dialog plugins | imperative service singletons | 🚧 M2 |

Full 68-item gap analysis lives in the roadmap: [docs/ROADMAP.md](docs/ROADMAP.md).

## Project layout (src layout)

```
pyside-nova/
├── pyproject.toml                  # hatchling packaging, QML ships in the wheel
├── src/pyside_nova/
│   ├── __init__.py                 # init_nova(engine)
│   ├── __about__.py                # single source of version truth
│   └── qml/Nova/
│       ├── Services/               # NovaTheme / NovaScreen singletons
│       ├── Controls/               # NovaBtn / NovaCard / NovaChip / ...
│       └── Behaviors/              # NovaRipple
├── examples/
│   ├── demo/                       # compact demo
│   └── gallery/                    # component gallery (sidebar + pages)
├── docs/                           # architecture / tokens / API / roadmap
├── scripts/
│   ├── fetch_icons.py              # download MDI/Material packs into icons/
│   └── local_deploy.py             # one-click build → install → test
├── tests/test_smoke.py             # QML parse + instantiate smoke tests
└── .github/workflows/              # CI (Win+Linux) and PyPI trusted release
```

Every `.py` / `.qml` file starts with a two-line header comment — line 1 is the
full subpath starting from `src/`, line 2 is a one-sentence description that
feeds the API docs:

```
// src/pyside_nova/qml/Nova/Controls/NovaIcon.qml
// NovaIcon 图标组件：icon="mdi:home" 式 API，本地图标包优先、云端 CDN 自动回落（对标 QIcon）
```

## Icon system (NovaIcon)

```qml
NovaIcon { icon: "mdi:home"; size: 28 }                  // MDI
NovaIcon { icon: "material:favorite"; color: "red" }     // Material (monochrome tint by default)
NovaIcon { icon: "material-outlined:settings" }          // outlined / round / sharp / two-tone
NovaBtn  { icon: "mdi:magnify"; round: true }            // NovaBtn auto-detects icon refs
```

- **Dual channel**: local pack first (`NovaTheme.iconLocalRoot`), automatic jsDelivr CDN
  fallback when missing locally (`@mdi/svg`, `@material-design-icons/svg`)
- **Tinting**: QML `Image` + `MultiEffect`; `monochrome: false` keeps original SVG colors

## Offline deploy & one-click packaging

```bash
# 1. download icon packs into icons/ (~10k SVGs, optional --only mdi / --only material)
python scripts/fetch_icons.py

# 2. one-click local deploy: clean → build wheel → install → smoke tests
python scripts/local_deploy.py
python scripts/local_deploy.py --zip --demo   # + release ZIP (source + wheel) and demo
```

The demo/gallery auto-enable the local icon channel when `icons/` exists. Apps can also
set it directly: `NovaTheme.iconLocalRoot = "file:///C:/deploy/icons"`.

## Development

```bash
pip install -e ".[dev]"
pytest -q                          # smoke tests (32)
python examples/gallery/main.py    # visual preview
python -m build                    # sdist + wheel
```

Coding conventions, architecture and release process: [CONTRIBUTING.md](CONTRIBUTING.md).

## Release to PyPI (Trusted Publishing)

1. GitHub repo → Settings → Environments → create `pypi`
2. PyPI → Publishing → add Trusted Publisher (repo + workflow `release.yml` + env `pypi`)
3. Tag and push:

```bash
git tag v0.2.0
git push origin v0.2.0
```

## Enterprise freeze roadmap

| Milestone | Scope |
|---|---|
| **M0** ✅ | Foundation + first 12 components + Gallery |
| **M1** | P0 flagship components (Layout/Table/Form/Date/Select/Notify/Dialog…) |
| **M2** | P1 enterprise add-ons + docs site |
| **M3** | `1.0.0-flagship` freeze — API frozen, WCAG 2.1 AA gate, 24-month LTS |

## License

[MIT](LICENSE)
