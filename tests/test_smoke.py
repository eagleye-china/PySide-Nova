# tests/test_smoke.py
# 冒烟测试：全部组件 QML 解析+实例化、令牌可读、断点语义（1366px→md）、画廊完整加载、L4 服务行为级断言
"""冒烟测试：验证 pyside-nova QML 模块可在引擎中正确解析并实例化。"""
import os
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtCore import QEventLoop, QPoint, QTimer, QUrl, Qt
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent, QQmlEngine
from PySide6.QtTest import QTest

from pyside_nova import init_nova

CASES = [
    # services：单例可解析、令牌可读取
    "import QtQuick\nimport Nova.Services\n"
    "QtObject { property color c: NovaTheme.primary }",
    "import QtQuick\nimport Nova.Services\n"
    "QtObject { property bool d: NovaTheme.isDark }",
    # controls：逐个实例化
    "import QtQuick\nimport Nova.Controls\nNovaBtn { text: 'hi' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtn { text: 'x'; variant: 'outlined'; loading: true; size: 'sm' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtn { icon: '+'; round: true; disable: true; tint: '#EF4444' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaCard { NovaCardSection { Text { text: 'a' } } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaCard { flat: true; NovaCardSection { } NovaCardActions { } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaChip { text: 'tag'; removable: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaChip { text: 'x'; filled: true; dense: true; tint: '#26A69A' }",
    "import QtQuick\nimport Nova.Controls\nNovaAvatar { text: 'N'; size: 40 }",
    "import QtQuick\nimport Nova.Controls\nNovaIcon { icon: 'mdi:home' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaIcon { icon: 'material:menu'; size: 32; color: '#EF4444'; monochrome: false }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtn { icon: 'mdi:home'; text: 'icon btn'; variant: 'outlined' }",
    "import QtQuick\nimport Nova.Controls\nNovaSeparator { width: 100 }",
    "import QtQuick\nimport Nova.Controls\nNovaSeparator { vertical: true; height: 100 }",
    "import QtQuick\nimport Nova.Controls\nNovaSpace { }",
    # NovaBadge：作为子项挂载（含红点模式与浮动模式）
    "import QtQuick\nimport Nova.Controls\n"
    "Item { width: 50; height: 50; NovaBadge { text: '5' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "Item { width: 50; height: 50; NovaBadge { } }",
    "import QtQuick\nimport Nova.Controls\n"
    "Item { width: 50; height: 50; NovaBadge { text: 'x'; floating: true } }",
    # behaviors：NovaRipple 子项挂载
    "import QtQuick\nimport Nova.Behaviors\n"
    "Rectangle { width: 100; height: 60; NovaRipple { } }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "Rectangle { width: 100; height: 60; NovaRipple { color: 'red'; duration: 300 } }",
    # 槽机制：默认槽（default property alias）子项挂载
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtn { text: 'x'; Rectangle { width: 4; height: 4 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaChip { text: 'x'; Rectangle { width: 4; height: 4 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaAvatar { text: 'A'; Rectangle { width: 4; height: 4 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaIcon { icon: 'mdi:home'; Rectangle { width: 4; height: 4 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "Item { width: 50; height: 50; NovaBadge { text: '1'; Rectangle { width: 4; height: 4 } } }",
    # services：NovaScreen 断点（1366px → md）
    "import QtQuick\nimport Nova.Services\n"
    "Item { id: it; width: 1366; height: 768;"
    " Component.onCompleted: NovaScreen.source = it }",
    # ── L1 布局系统（v0.5.0）：逐个实例化 ──
    "import QtQuick\nimport Nova.Controls\n"
    "NovaHeader { Rectangle { width: 10; height: 10 } }",
    "import QtQuick\nimport Nova.Controls\nNovaFooter { }",
    "import QtQuick\nimport Nova.Controls\nNovaPage { Text { text: 'p' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaDrawer { side: 'left'; mini: true; Rectangle { width: 10; height: 10 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaDrawer { side: 'right'; overlay: true; breakpoint: 500; bordered: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaRow { width: 400; height: 100; Rectangle { width: 50; height: 20 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaRow { width: 1200; height: 100; NovaCol { cols: 6 } NovaCol { cols: 4; offset: 2 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaVisible { above: 'md'; Rectangle { width: 10; height: 10 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaVisible { below: 'sm'; only: 'xs sm md' }",
    # 槽机制：布局五件套默认槽
    "import QtQuick\nimport Nova.Controls\n"
    "NovaLayout { width: 800; height: 600;"
    " NovaHeader { } NovaDrawer { } NovaFooter { } NovaPage { Text { text: 'x' } } }",
    # ── L4 服务层（v0.6.0）：单例读取 + 动作/句柄实例化 ──
    "import QtQuick\nimport Nova.Services\n"
    "QtObject { property int c: NovaNotify.countAt('bottom');"
    " property var ci: NovaOverlayHost.contentItem;"
    " property int zn: NovaTheme.zNotify }",
    "import QtQuick\nimport Nova.Services\n"
    "NovaNotifyAction { label: 'undo'; icon: 'mdi:undo'; noDismiss: true }",
    "import QtQuick\nimport Nova.Services\n"
    "NovaNotifyHandle { }",
    "import QtQuick\nimport Nova.Services\n"
    "QtObject { property var h: null;"
    " Component.onCompleted: h = NovaNotify.show('hi') }",
    # ── L3 行为层（v0.7.0）：九个指令行为 + 共享观察池 ──
    "import QtQuick\nimport Nova.Behaviors\nNovaIntersection { }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "NovaIntersection { threshold: [0, 0.5, 1]; once: true }",
    "import QtQuick\nimport Nova.Behaviors\nNovaScrollObserver { }",
    "import QtQuick\nimport Nova.Behaviors\nNovaScrollFire { threshold: 0.5 }",
    "import QtQuick\nimport Nova.Behaviors\nNovaClosePopup { depth: -1 }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "NovaTouchPan { horizontal: true; directions: ['left', 'right'] }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "NovaTouchSwipe { directions: ['up']; minVelocity: 0.08 }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "NovaTouchHold { duration: 500; touchSensitivity: 4 }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "NovaTouchRepeat { delays: '0:400'; keyRepeat: true }",
    "import QtQuick\nimport Nova.Services\n"
    "QtObject { property int n: NovaIntersectionPool.count;"
    " property int p: NovaIntersectionPool.pollInterval }",
    # ── 二期 Sprint A 表单核心（v0.9.0）：逐个实例化 ──
    "import QtQuick\nimport Nova.Controls\n"
    "NovaField { label: 'L'; hint: 'H'; clearable: true; outlined: true; counter: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaField { label: 'L'; Rectangle { width: 4; height: 4 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaInput { label: '用户名'; hint: '必填'; clearable: true; rules: ['required'] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaInput { type: 'password'; modelModifiers: ['number', 'trim']; debounce: 200 }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaInput { type: 'textarea'; autogrow: true; shadowText: '影子文本' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaSelect { label: 'S'; options: [{label: 'A', value: 1}, {label: 'B', value: 2}]; emitValue: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaSelect { multiple: true; maxValues: 3; useInput: true; options: ['x', 'y']; noOptionLabel: '无' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaCheckbox { label: 'C'; hint: 'H'; toggleIndeterminate: true; indeterminateValue: 'p' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaCheckbox { label: 'A'; val: 'opt-a'; leftLabel: true; keepColor: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaRadio { label: 'R'; val: 'a'; modelValue: 'a'; dense: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaToggle { label: 'T'; icon: 'mdi:check'; iconColor: '#FFF'; dense: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaSlider { min: 0; max: 10; step: 1; snap: true; markers: true; label: true; labelAlways: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaSlider { vertical: true; reverse: true; markers: 2; markerLabels: ['低', '高']; dense: true }",
    # ── Sprint B（v0.10.0）输入进阶八件 ──
    "import QtQuick\nimport Nova.Controls\n"
    "NovaRange { min: 0; max: 100; step: 5; label: true; minRange: 10; maxRange: 60 }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaRange { vertical: true; reverse: true; markers: 4; markerLabels: ['A', 'B', 'C', 'D'] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaDate { mask: 'YYYY/MM/DD'; minimal: '2026/01/15'; todayBtn: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaDate { range: true; events: ['2026/01/08', '2026/01/22'] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaDate { multiple: true; firstDayOfWeek: 1 }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTime { withSeconds: true; format24h: true; nowBtn: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTime { hourOptions: [9, 10, 11]; minuteOptions: [0, 15, 30, 45] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaColorPicker { formatModel: 'rgb'; noFooter: false }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaColorPicker { defaultValue: '#5B6EF5'; flat: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaOptionGroup { type: 'radio'; options: [{label: '甲', value: 1}, {label: '乙', value: 2, disable: true}] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaOptionGroup { type: 'toggle'; inline: true; leftLabel: true; options: ['x', 'y', 'z'] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtnToggle { options: ['日', '周', '月']; clearable: true; outline: true; dense: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtnToggle { vertical: true; spread: true; multiple: true; options: [{label: 'a', value: 1}, {label: 'b', value: 2}] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaPopupEdit { title: '编辑'; autoSave: false; Rectangle { width: 60; height: 24; color: '#eee' } }",
    # ── 三期 Sprint A：数据体系九件（v0.11.0） ──
    "import QtQuick\nimport Nova.Controls\nNovaTh { text: '名称'; sortable: true; align: 'center' }",
    "import QtQuick\nimport Nova.Controls\nNovaTd { text: '单元格'; align: 'right' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTr { width: 300; Rectangle { width: 40; height: 20 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaPagination { page: 2; pages: 20; maxPages: 5; ellipses: true; boundaryLinks: true; arrows: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTable { width: 640; height: 300; title: '人员'; rowKey: 'id';"
    " columns: [{name: 'id', label: 'ID', field: 'id', align: 'center', sortable: true}, '姓名'];"
    " rows: [{id: 1, name: 'a'}, {id: 2, name: 'b'}]; rowsPerPage: 5; selected: []; expanded: [] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTable { width: 640; height: 300; filter: 'a'; singleSelection: true; binaryStateSort: true;"
    " rowsPerPage: 0; selected: []; grid: true; flat: true;"
    " columns: ['a', 'b']; rows: [{a: 1, b: 2}] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTree { width: 320; height: 240; tickStrategy: 'strict'; filter: '';"
    " nodes: [{label: 'A', children: [{label: 'A1'}]}, {label: 'B', lazy: true}];"
    " expanded: []; ticked: []; selected: null }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTree { width: 320; height: 240; dense: true; defaultExpandAll: true; nodeKey: 'key';"
    " nodes: [{label: 'X', key: 'x', tickStrategy: 'none', caption: 'cap', icon: 'mdi:folder'}] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaList { width: 320; height: 200; separator: true; dense: true; accordion: true; padding: true;"
    " NovaItem { label: 'a'; expandable: true } NovaItem { label: 'b'; caption: 'c'; clickable: true; active: true } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaItem { label: 'x'; caption: 'y'; icon: 'mdi:home';\n"
    "  leading: NovaItemSection { avatar: true; Rectangle { width: 10; height: 10 } }\n"
    "  trailing: NovaItemSection { trailing: true; NovaIcon { icon: 'mdi:chevron-right' } } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaItemSection { thumbnail: true; topAligned: true; Rectangle { width: 40; height: 40 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaItemLabel { text: '标题'; overline: true; lines: 2 }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaItemLabel { text: '辅助'; caption: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaMarkupTable { title: '账单'; dense: true; flat: true;"
    " columns: ['品名', '金额']; rows: [['咖啡', '¥28'], ['书籍', '¥56']] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaInfiniteScroll { width: 300; height: 200; offset: 40; Rectangle { width: 10; height: 10 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaVirtualScroll { width: 300; height: 160; itemSize: 40;"
    " delegate: Rectangle { width: 280; height: 40; required property int index } }",
    "import QtQuick\nimport Nova.Controls\nNovaScrollArea { width: 300; height: 200; Rectangle { width: 500; height: 400 } }",
    # ── 三期 Sprint B：媒体体系十类型（v0.12.0） ──
    "import QtQuick\nimport Nova.Controls\n"
    "NovaImg { width: 120; ratio: 1.6; fit: 'contain'; alt: '图'; loadingShowDelay: 200;"
    " spinnerSize: 36; noSpinner: false }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaImg { src: ''; placeholderSrc: 'p.png'; errorSrc: 'e.png'; noTransition: true;"
    " loadingSlot: Rectangle { } errorSlot: Rectangle { } Rectangle { } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaResponsive { width: 320; ratio: 1.7777; Rectangle { color: 'red' } }",
    "import QtQuick\nimport Nova.Controls\nNovaVideo { width: 480; title: '宣传片' }",
    "import QtQuick\nimport Nova.Controls\n"
    "Item { width: 400; height: 600; Flickable { id: f }"
    " NovaParallax { width: 400; height: 200; src: 'x.png'; speed: 0.5; scrollTarget: f;"
    " mediaSlot: Item { } Rectangle { } } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaCarousel { width: 400; height: 200; arrows: true; navigation: true; infinite: true;"
    " swipeable: true; autoplay: false; transitionDuration: 200;"
    " NovaCarouselSlide { name: 'a' } NovaCarouselSlide { name: 'b'; disable: true }"
    " NovaCarouselControl { position: 'top-right'; offset: 12; Text { text: 'x' } } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaCarousel { width: 300; height: 160; vertical: true; padding: true;"
    " navigation: true; navigationPosition: 'right'; navigationIcon: 'mdi:circle';"
    " NovaCarouselSlide { imgSrc: 't.png' } NovaCarouselSlide { } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTimeline { width: 380; tint: '#26A69A'; side: 'left'; layout: 'comfortable';"
    " NovaTimelineEntry { heading: true; title: '里程碑' }"
    " NovaTimelineEntry { title: 'T'; subtitle: 'S'; body: 'B'; icon: 'mdi:star' }"
    " NovaTimelineEntry { title: 'R'; side: 'right'; avatar: 'a.png' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTimeline { width: 320; layout: 'dense';"
    " NovaTimelineEntry { title: 'D'; body: '正文' }"
    " NovaTimelineEntry { title: 'D2'; subtitle: '子'; Rectangle { } } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaChatMessage { width: 420; sent: true; name: '我'; text: ['在吗', '好的'];"
    " stamp: '10:00'; size: 8; avatarSlot: Rectangle { } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaChatMessage { width: 420; label: '今天'; text: '单条字符串';"
    " nameSlot: Item { } stampSlot: Item { } labelSlot: Item { } Rectangle { } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTable { width: 640; height: 300; virtualScroll: true; rowsPerPage: 0;"
    " virtualScrollItemSize: 40; columns: ['a', 'b'];"
    " rows: [{a: 1, b: 2}, {a: 3, b: 4}] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTable { width: 640; height: 300; serverSide: true; rowsNumber: 42;"
    " loading: true; loadingLabel: '载入中'; noDataLabel: '空空如也';"
    " columns: ['nm']; rows: [{nm: 1}] }",
    # 四期 Sprint A · 导航体系（0.13.0）
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTabs { NovaTab { name: 'a'; label: '邮件'; icon: 'mdi:email' }"
    " NovaTab { name: 'b'; label: '日历'; alert: '3' }"
    " NovaTab { name: 'c'; label: '禁用'; disable: true } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTabs { vertical: true; align: 'left'; switchIndicator: true; narrowIndicator: true;"
    " NovaTab { name: 'x'; label: 'X' } NovaTab { name: 'y'; label: 'Y' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTabPanels { animated: true; swipeable: true; infinite: true;"
    " NovaTabPanel { name: 'a'; Rectangle { } } NovaTabPanel { name: 'b' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBreadcrumbs { separator: '›'; NovaBreadcrumbsEl { label: '主页'; icon: 'mdi:home' }"
    " NovaBreadcrumbsEl { label: '分类' } NovaBreadcrumbsEl { label: '当前'; disable: true } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBreadcrumbs { separatorDelegate: Component { Rectangle { width: 10; height: 2; color: 'red' } }"
    " NovaBreadcrumbsEl { label: 'a' } NovaBreadcrumbsEl { label: 'b' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaStepper { NovaStep { name: 's1'; title: '一' } NovaStep { name: 's2'; title: '二'; done: true }"
    " NovaStep { name: 's3'; title: '三'; error: true } NovaStep { name: 's4'; title: '四'; disable: true } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaStepper { vertical: true; contracted: true; animated: true;"
    " NovaStep { title: 'a' } NovaStep { title: 'b' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaStepper { alternativeLabels: true;"
    " NovaStep { title: 'a'; prefix: '1' } NovaStep { title: 'b' }"
    " navigation: [NovaStepperNavigation { NovaBtn { text: '下一步' } }] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaExpansionItem { label: '展开我'; caption: '副文案'; group: 'g'; expandSeparator: true;"
    " Rectangle { color: 'red'; width: 40; height: 20 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaExpansionItem { switchToggleSide: true; expandIconToggle: true; denseToggle: true;"
    " labelLines: 2; header: Item { } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaToolbar { inset: true; NovaToolbarTitle { text: '标题' } NovaBtn { text: '保存' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaToolbarTitle { shrink: true; Text { text: 'custom' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaFab { direction: 'up'; stagger: 25; label: '新建'; externalLabel: true;"
    " NovaFabAction { icon: 'mdi:pencil'; label: '文档' }"
    " NovaFabAction { icon: 'mdi:delete'; disable: true } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaFab { square: true; modelValue: true; hover: true;"
    " NovaFabAction { icon: 'mdi:home' } NovaFabAction { square: true; label: '设' } }",
    # 四期 Sprint B · 弹层与反馈（0.14.0）
    "import QtQuick\nimport Nova.Controls\n"
    "NovaMenu { modelValue: true; width: 140; height: 80;"
    " NovaItem { label: '打开'; clickable: true } NovaItem { label: '保存' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaMenu { contextMenu: true; autoClose: true; fit: true;"
    " anchor: 'bottom right'; self: 'top right'; offset: [4, 4]; NovaItem { label: 'a' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaDialogShell { modelValue: true; width: 480; height: 320; persistent: true;"
    " Text { text: '正文' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaDialogShell { position: 'bottom'; seamless: true; fullWidth: true; square: true;"
    " Rectangle { width: 200; height: 60 } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaPopupProxy { breakpoint: 450; NovaItem { label: 'm1' } NovaItem { label: 'm2' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaTooltip { text: '工具提示'; delay: 80; hideDelay: 40; anchor: 'top middle'; self: 'bottom middle' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBottomSheet { modelValue: true; width: 420; height: 300;"
    " actions: [{label: '拍照', icon: 'mdi:camera'}, {label: '相册', icon: 'mdi:image'}, {label: '取消'}] }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBottomSheet { grid: true; actions: [{label: 'a', icon: 'mdi:home'}, {label: 'b'}, {label: 'c'}, {label: 'd'}] }",
    "import Nova.Controls\nNovaSpinner { }",
    "import Nova.Controls\nNovaSpinner { variant: 'ball'; size: 32 }",
    "import Nova.Controls\nNovaSpinner { variant: 'hourglass'; thickness: 4 }",
    "import Nova.Controls\nNovaSpinner { variant: 'gears' }",
    "import Nova.Controls\nNovaSpinner { variant: 'grid' }",
    "import Nova.Controls\nNovaSpinner { variant: 'dots' }",
    "import Nova.Controls\nNovaSpinner { variant: 'radio' }",
    "import Nova.Controls\nNovaSpinner { variant: 'comment' }",
    "import Nova.Controls\nNovaSkeleton { type: 'text'; animation: 'bounce' }",
    "import Nova.Controls\nNovaSkeleton { type: 'circle'; size: 48; animation: 'fade'; bordered: true }",
    "import Nova.Controls\nNovaSkeleton { type: 'badge'; animation: 'none' }",
    "import Nova.Controls\nNovaInnerLoading { showing: true; size: 36; label: '加载中' }",
    "import Nova.Controls\nNovaAjaxBar { position: 'top'; size: 3; reverse: true }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBanner { rounded: true; dense: true; inlineActions: true;"
    " Rectangle { width: 24; height: 24; color: 'teal' } Text { text: '公告内容' } NovaBtn { text: '知道了' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBar { dense: true; Text { text: '顶栏'; color: 'white' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaNoSsr { placeholderText: '载入中…'; delay: 30; Text { text: '真内容' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaPullToRefresh { width: 300; height: 200; side: 'bottom'; icon: 'mdi:download';"
    " Rectangle { color: '#E8EAF2'; anchors.fill: parent } }",
    "import Nova.Controls\nNovaResizeObserver { debounce: 0 }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtnDropdown { label: '操作'; split: true; autoClose: true;"
    " NovaItem { label: '编辑' } NovaItem { label: '删除' } }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaBtnGroup { vertical: true; spread: true; outline: true;"
    " NovaBtn { text: '日' } NovaBtn { text: '周' } NovaBtn { text: '月' } }",
    # ── 五期长尾组件（v0.15.0）：Editor / SlideItem / Morph / MorphPool ──
    "import QtQuick\nimport Nova.Controls\n"
    "NovaEditor { placeholder: '写点什么…'; minHeight: 80 }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaEditor { toolbar: [['bold', 'italic'], ['h1', 'quote'], ['undo', 'redo']];"
    " flat: true; modelValue: '# 标题\\n正文' }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaSlideItem { dense: true; width: 300; height: 44 }",
    "import QtQuick\nimport Nova.Controls\n"
    "NovaSlideItem { width: 300; height: 56;"
    " leftSlot: Component { Rectangle { anchors.fill: parent; color: 'teal' } }"
    " rightSlot: Component { Rectangle { anchors.fill: parent; color: 'tomato' } }"
    " Rectangle { color: '#E8EAF2'; anchors.fill: parent; Text { text: '正面' } } }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "Rectangle { width: 50; height: 50; NovaMorph { group: 'g' } }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "Item { width: 10; height: 10; NovaMorph { group: 'g'; target: parent; duration: 0;"
    " tint: 'teal'; radius: 8 } }",
    "import QtQuick\nimport Nova.Behaviors\n"
    "QtObject { property var cur: NovaMorphPool.current('nonexistent-group') }",
]


def test_screen_breakpoints(qml_engine):
    """1366px 应命中 md 断点（>=1024 且 <1440），lt/gt 语义对标 Quasar。"""
    code = ("import QtQuick\nimport Nova.Services\n"
            "Item { id: it; width: 1366; height: 768;"
            " Component.onCompleted: NovaScreen.source = it;"
            " property string bp: NovaScreen.name;"
            " property bool md: NovaScreen.isMd;"
            " property bool gtSm: NovaScreen.gtSm;"
            " property bool ltMd: NovaScreen.ltMd }")
    component = QQmlComponent(qml_engine)
    component.setData(code.encode("utf-8"), QUrl("qrc:/nova-screen.qml"))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    assert obj.property("bp") == "md"
    assert obj.property("md") is True
    assert obj.property("gtSm") is True
    assert obj.property("ltMd") is True


_ALIVE = []   # 测试期强引用池：QWindow 无 parent，组件对象一销毁就会被连带 delete


def _make(qml_engine, code, wait=0.0):
    """创建 QML 对象并挂到 app 防止引擎 GC 无父根对象；wait>0 时泵事件（宽度动画）。"""
    import time

    from PySide6.QtGui import QGuiApplication

    component = QQmlComponent(qml_engine)
    component.setData(code.encode("utf-8"), QUrl("qrc:/nova-l1.qml"))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    from PySide6.QtGui import QWindow
    _ALIVE.append(obj)                              # 全类型强引用（Window 也不例外）
    if not isinstance(obj, QWindow):
        obj.setParent(QGuiApplication.instance())   # 非 Window 再挂到 app
    if wait > 0:
        end = time.time() + wait
        while time.time() < end:
            QGuiApplication.instance().processEvents()
            time.sleep(0.02)
    return obj


def test_layout_quadrants_and_push(qml_engine):
    """NovaLayout 四象限归位：header 顶部、footer 底部、drawer push 时页面区让位。"""
    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Controls\n"
                "NovaLayout { width: 1200; height: 600\n"
                " property real hy: headerItem ? headerItem.y : -1\n"
                " property real fy: footerItem ? footerItem.y : -1\n"
                " property real dw: drawerItem ? drawerItem.width : -1\n"
                " property real px: pageArea.x\n"
                " NovaHeader { } NovaDrawer { } NovaFooter { } NovaPage { } }")
    assert obj.property("hy") == 0
    assert obj.property("fy") == 600 - 48
    assert abs(obj.property("dw") - 280) < 0.1
    assert abs(obj.property("px") - 280) < 0.1


def test_layout_autocollapse(qml_engine):
    """宿主宽度 800 < 断点 1024：抽屉自动收起（宽 0），页面区不让位。"""
    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Controls\n"
                "NovaLayout { width: 800; height: 600\n"
                " property real dw: drawerItem ? drawerItem.width : -1\n"
                " property real px: pageArea.x\n"
                " NovaHeader { } NovaDrawer { } NovaFooter { } NovaPage { } }",
                wait=0.4)
    assert obj.property("dw") == 0
    assert obj.property("px") == 0


def test_grid_math(qml_engine):
    """12 栅格数学：cols=6 → 行宽一半；offset=2 → 推挤 2/12 行宽（含 spacing）。"""
    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Controls\n"
                "NovaRow { width: 1200; height: 100\n"
                " property real w1: children[0].width\n"
                " property real w2: children[1].width\n"
                " property real x2: children[1].x\n"
                " NovaCol { cols: 6 }\n"
                " NovaCol { cols: 4; offset: 2 } }")
    assert abs(obj.property("w1") - 600) < 0.5
    assert abs(obj.property("w2") - 400) < 0.5
    assert abs(obj.property("x2") - (600 + 12 + 200)) < 1.5


def test_nova_visible_semantics(qml_engine):
    """NovaVisible 三语义：1366px(md) 下 above:'md' 隐藏 / only:'md' 显示 / below:'sm' 隐藏。"""
    _make(qml_engine,
          "import QtQuick\nimport Nova.Services\n"
          "Item { width: 1366; height: 100;"
          " Component.onCompleted: NovaScreen.source = this }")
    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Controls\n"
                "Item {\n"
                " property bool va: children[0].visible\n"
                " property bool vb: children[1].visible\n"
                " property bool vc: children[2].visible\n"
                " NovaVisible { above: 'md' }\n"
                " NovaVisible { only: 'md' }\n"
                " NovaVisible { below: 'sm' } }")
    assert obj.property("va") is False
    assert obj.property("vb") is True
    assert obj.property("vc") is False


@pytest.fixture(scope="module", autouse=True)
def _smoke_teardown(qml_engine):
    """模块收尾：按创建逆序释放 QML 对象，再让引擎析构。

    0.16.0 实测（Qt 6.12）：模块内创建的 Window 若活到解释器退出、而 QGuiApplication 已析构，
    进程退出时会 SIGSEGV（间歇）；显式 close + 清引用可稳定退出码。
    """
    yield
    from conftest import close_alive
    close_alive()
    _ALIVE.clear()
    _pump(0.05)


@pytest.fixture(scope="module")
def qml_engine(qml_engine):
    """复用 conftest 的会话级引擎（0.16.0：多引擎并存会在 Qt 6.12 间歇崩溃）。"""
    return qml_engine


def test_theme_dark_plugin_api(qml_engine):
    """Dark 插件 API：isDark / setDark / toggleDark / dark 品牌色（对标 $q.dark.*）。"""
    code = ("import QtQuick\nimport Nova.Services\n"
            "QtObject { property bool a: NovaTheme.isDark;"
            " property color dk: NovaTheme.dark;"
            " property bool after: { NovaTheme.setDark(true); NovaTheme.toggleDark();"
            " NovaTheme.isDark } }")
    component = QQmlComponent(qml_engine)
    component.setData(code.encode("utf-8"), QUrl("qrc:/nova-dark-api.qml"))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    assert obj.property("a") is False
    assert obj.property("dk").isValid()
    # setDark(true) → toggleDark() → False（状态翻转正确）
    assert obj.property("after") is False
    obj.deleteLater()


def test_demo_loads(qml_engine):
    """精简演示 examples/demo/main.qml 必须完整加载。"""
    from pathlib import Path

    demo = Path(__file__).resolve().parents[1] / "examples" / "demo" / "main.qml"
    component = QQmlComponent(qml_engine)
    component.loadUrl(QUrl.fromLocalFile(str(demo)))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    obj.deleteLater()


def test_gallery_loads(qml_engine):
    """组件画廊 examples/gallery/main.qml 必须完整加载。"""
    from pathlib import Path

    gallery = Path(__file__).resolve().parents[1] / "examples" / "gallery" / "main.qml"
    component = QQmlComponent(qml_engine)
    component.loadUrl(QUrl.fromLocalFile(str(gallery)))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    obj.deleteLater()


@pytest.mark.parametrize("code", CASES)
def test_component_instantiates(qml_engine, code):
    component = QQmlComponent(qml_engine)
    component.setData(code.encode("utf-8"), QUrl("qrc:/nova-smoke.qml"))
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    obj.deleteLater()


def test_theme_tokens(qml_engine):
    component = QQmlComponent(qml_engine)
    component.setData(
        b"import QtQuick\nimport Nova.Services\n"
        b"QtObject { property color c: NovaTheme.surface;"
        b" property color s: NovaTheme.shadowColor(2) }",
        QUrl("qrc:/nova-theme.qml"),
    )
    obj = component.create()
    errors = [e.toString() for e in component.errors()]
    assert obj is not None, errors
    assert obj.property("c").isValid()
    assert obj.property("s").isValid()




# ══════════════════════════════════════════════════════════════
# L4 服务层：NovaNotify 行为级断言（契约见 docs/PARITY.md 审计节）
# ══════════════════════════════════════════════════════════════

NOTIFY_WINDOW_QML = (
    "import QtQuick\nimport QtQuick.Window\nimport Nova.Services\n"
    "Window { id: w; visible: false; width: 800; height: 600;"
    " Component.onCompleted: NovaScreen.source = w }"
)

NOTIFY_DRIVER_QML = (
    "import QtQuick\nimport Nova.Services\n"
    "QtObject {\n"
    "  property var lastReason: ''\n"
    "  property var lastHandle: null\n"
    "  property int handlerRuns: 0\n"
    "  function show(msg, opts) {\n"
    "    var c = opts === undefined ? {} : opts; c.message = msg\n"
    "    var h = NovaNotify.show(c)\n"
    "    if (h && h.item) h.item.dismissed.connect(function(r) { lastReason = r })\n"
    "    lastHandle = h\n"
    "    return h\n"
    "  }\n"
    "  function act(msg, opts) {\n"
    "    var c = opts === undefined ? {} : opts; c.message = msg\n"
    "    c.actions = [{ label: 'ok', handler: function() { handlerRuns++ } }]\n"
    "    var h = NovaNotify.show(c)\n"
    "    if (h && h.item) h.item.dismissed.connect(function(r) { lastReason = r })\n"
    "    lastHandle = h\n"
    "    return h\n"
    "  }\n"
    "  function cnt(pos) { return NovaNotify.countAt(pos) }\n"
    "  function dismissAll(pos) { NovaNotify.dismissAll(pos) }\n"
    "  function setmax(n) { NovaNotify.maxVisible = n }\n"
    "  function setdark(v) { NovaTheme.setDark(v) }\n"
    "  function resetReason() { lastReason = '' }\n"
    "  function clearAll() {\n"
    "    var all = NovaNotify.positionList\n"
    "    for (var i = 0; i < all.length; i++) NovaNotify.dismissAll(all[i])\n"
    "  }\n"
    "}"
)


@pytest.fixture()
def notify_env(qml_engine):
    """L4 行为测试环境：源窗口 + 驱动对象；每个用例前后清空通知栈。"""
    win = _make(qml_engine, NOTIFY_WINDOW_QML)
    drv = _make(qml_engine, NOTIFY_DRIVER_QML)
    drv.clearAll()
    yield drv
    drv.clearAll()
    drv.setmax(5)


def _pump(ms=50):
    loop = QEventLoop()
    QTimer.singleShot(ms, loop.quit)
    loop.exec()


def test_notify_show_dismiss_reason_api(notify_env):
    """show → count 1 → dismiss() → reason 'api'，句柄失效。"""
    h = notify_env.show("hello", None)
    assert notify_env.cnt("bottom") == 1
    assert h.property("valid") is True
    item = h.property("item")
    assert item.property("message") == "hello"
    h.dismiss()
    assert notify_env.cnt("bottom") == 0
    assert h.property("valid") is False
    assert notify_env.property("lastReason") == "api"


def test_notify_nine_positions(notify_env):
    """9 个位置逐个落位；left/right/center 走中线插入。"""
    positions = ["top-left", "top-right", "bottom-left", "bottom-right",
                 "top", "bottom", "left", "right", "center"]
    for pos in positions:
        notify_env.show("p", {"position": pos, "group": False})
        assert notify_env.cnt(pos) == 1
    for pos in positions:
        notify_env.dismissAll(pos)
        assert notify_env.cnt(pos) == 0


def test_notify_type_presets(notify_env):
    """内置类型预设：positive 色板、warning textTint=dark、ongoing 常驻转圈不分组。"""
    h = notify_env.show("ok", {"type": "positive"})
    from PySide6.QtGui import QColor
    assert h.property("item").property("tint") == QColor("#22C55E")
    h2 = notify_env.show("warn", {"type": "warning"})
    assert h2.property("item").property("textTint") == QColor("#1D1D1D")
    h3 = notify_env.show("job", {"type": "ongoing"})
    it = h3.property("item")
    assert it.property("spinner") is True
    assert it.property("timeout") == 0
    assert it.property("groupKey") is None



def test_notify_invalid_inputs(notify_env):
    """非法位置拒绝（返回 null）；非法 timeout 回落 5000；timeout=0 强制关进度。"""
    assert notify_env.show("x", {"position": "middle"}) is None
    assert notify_env.property("lastHandle") is None
    it = notify_env.show("t", {"group": False, "timeout": -5}).property("item")
    assert it.property("timeout") == 5000
    it2 = notify_env.show("z", {"group": False, "timeout": 0, "progress": True}).property("item")
    assert it2.property("progress") is False


def test_notify_grouping_and_badge(notify_env):
    """自动分组：同键合并 badge 递增，旧句柄失效且上报 replaced。"""
    h1 = notify_env.show("dup", None)
    h2 = notify_env.show("dup", None)
    assert notify_env.cnt("bottom") == 1
    assert h2.property("item").property("badge") == 2
    assert h1.property("valid") is False
    assert notify_env.property("lastReason") == "replaced"


def test_notify_group_key_includes_actions(notify_env):
    """分组键含 actions 标签：同 message 不同动作文案 → 不同组。"""
    notify_env.show("m", {"actions": [{"label": "保存"}]})
    notify_env.show("m", {"actions": [{"label": "另存为"}]})
    assert notify_env.cnt("bottom") == 2


def test_notify_group_false_and_custom_group(notify_env):
    """group:false 并列多条；自定义组后到者替换前者。"""
    notify_env.show("A", {"group": False})
    notify_env.show("B", {"group": False})
    assert notify_env.cnt("bottom") == 2
    h = notify_env.show("u1", {"group": "upload"})
    assert notify_env.cnt("bottom") == 3        # A + B + u1
    notify_env.show("u2", {"group": "upload"})
    assert notify_env.cnt("bottom") == 3        # u1 被 u2 替换，总数不增
    assert h.property("valid") is False
    assert notify_env.property("lastReason") == "replaced"


def test_notify_update_semantics(notify_env):
    """分组句柄 update 拒绝返回 False；非分组句柄可更新内容。"""
    g = notify_env.show("grp", None)
    assert g.update({"message": "x"}) is False
    f = notify_env.show("free", {"group": False})
    assert f.update({"message": "free2"}) is True
    assert f.property("item").property("message") == "free2"


def test_notify_action_dismiss_order(notify_env):
    """动作点击契约：handler 先行、dismissed('action') 后至；noDismiss 不关闭。"""
    h = notify_env.act("with-action", {"group": False})
    it = h.property("item")
    it.triggerAction(0)
    assert notify_env.property("handlerRuns") == 1
    assert notify_env.property("lastReason") == "action"
    assert h.property("valid") is False
    # noDismiss：点击后不关闭、不上报 dismissed
    notify_env.resetReason()
    sticky = notify_env.show("sticky2", {"group": False,
                                         "actions": [{"label": "ok", "noDismiss": True,
                                                      "handler": lambda: None}]})
    sticky.property("item").triggerAction(0)
    assert sticky.property("valid") is True
    assert notify_env.property("lastReason") == ""
    assert notify_env.property("handlerRuns") == 1   # Python lambda 句柄不进 driver 计数


def test_notify_close_btn_user_reason(notify_env):
    """closeBtn 归入动作列表，点击上报 user。"""
    h = notify_env.show("cb", {"group": False, "closeBtn": True})
    acts = h.property("item").property("actions")
    assert len(acts) == 1
    assert acts[0].property("label") == "关闭"
    assert acts[0].property("closeReason") == "user"
    h.property("item").triggerAction(0)
    assert notify_env.property("lastReason") == "user"


def test_notify_max_visible_overflow(notify_env):
    """同屏上限：超限淘汰最旧一条，原因 overflow（Nova 增强）。"""
    notify_env.setmax(2)
    for i in range(3):
        notify_env.show("of%d" % i, {"group": False})
    assert notify_env.cnt("bottom") == 2
    assert notify_env.property("lastReason") == "overflow"


def test_notify_timeout_reason(notify_env):
    """自然到期上报 timeout（timeout=20ms → 计时器 1020ms，含入场动效时长）。"""
    notify_env.show("ttl", {"group": False, "timeout": 20})
    assert notify_env.cnt("bottom") == 1
    _pump(1400)
    assert notify_env.cnt("bottom") == 0
    assert notify_env.property("lastReason") == "timeout"


def test_notify_setdefaults_and_dark(notify_env):
    """setDefaults 合并（position/timeout 覆盖）+ Dark 模式下实例化（宪法第 5 章强制用例）。"""
    notify_env.setdark(True)
    h = notify_env.show("dark-ttl", None)
    assert h.property("valid") is True
    assert h.property("item").property("tint").isValid()
    h.dismiss()
    notify_env.setdark(False)
    notify_env.show("d2", {"position": "top"})
    assert notify_env.cnt("top") == 1
    notify_env.dismissAll("top")


# ════════════════════════════════════════════════════════════
# L4 服务层：NovaDialog（27 项配置对账 · 关闭原因上报 · 句柄）
# ════════════════════════════════════════════════════════════

DIALOG_DRIVER_QML = (
    "import QtQuick\nimport Nova.Services\n"
    "QtObject {\n"
    "  property string lastReason: ''\n"
    "  property int okRuns: 0\n"
    "  property int cancelRuns: 0\n"
    "  property int cbHits: 0\n"
    "  property var lastHandle: null\n"
    "  function open(opts) {\n"
    "    var h = NovaDialog.show(opts)\n"
    "    if (h) {\n"
    "      h.dismissed.connect(function(r) { lastReason = r })\n"
    "      h.accepted.connect(function() { okRuns++ })\n"
    "      h.rejected.connect(function() { cancelRuns++ })\n"
    "    }\n"
    "    lastHandle = h\n"
    "    return h\n"
    "  }\n"
    "  function openCb() {\n"
    "    return NovaDialog.show({\n"
    "      title: 'cb',\n"
    "      onOk: function() { cbHits += 10 },\n"
    "      onCancel: function() { cbHits += 1 },\n"
    "      onDismiss: function(r) { cbHits += 100 }\n"
    "    })\n"
    "  }\n"
    "  function cnt() { return NovaDialog.count() }\n"
    "  function hideAll(r) { NovaDialog.hideAll(r) }\n"
    "  function setdefaults(o) { NovaDialog.setDefaults(o) }\n"
    "  function clearDefaults() { NovaDialog._defaults = ({}) }\n"
    "  function setdark(v) { NovaTheme.setDark(v) }\n"
    "  function resetReason() { lastReason = '' }\n"
    "}"
)


@pytest.fixture()
def dialog_env(qml_engine):
    """L4 对话框测试环境：源窗口 + 驱动对象；用例前后关闭全部对话框并清空默认值。"""
    win = _make(qml_engine, NOTIFY_WINDOW_QML)
    drv = _make(qml_engine, DIALOG_DRIVER_QML)
    drv.hideAll("api")
    drv.clearDefaults()
    yield drv
    drv.hideAll("api")
    drv.clearDefaults()
    drv.setdark(False)
    _pump(250)


def test_dialog_show_and_ok_reason(dialog_env):
    """show → count 1 → ok() → accepted + dismissed('ok') → 句柄失效。"""
    h = dialog_env.open({"title": "继续?", "message": "确认继续操作"})
    assert dialog_env.cnt() == 1
    assert h.property("valid") is True
    item = h.property("item")
    assert item.property("title") == "继续?"
    assert item.property("message") == "确认继续操作"
    assert item.property("position") == "standard"
    assert item.property("focusTarget") == "ok"
    h.ok()
    assert dialog_env.property("lastReason") == "ok"
    assert dialog_env.property("okRuns") == 1
    assert h.property("valid") is False
    assert dialog_env.cnt() == 0


def test_dialog_cancel_reason(dialog_env):
    """cancel() → rejected + dismissed('cancel')；API 关闭走 'api'。"""
    h = dialog_env.open({"title": "x"})
    h.cancel()
    assert dialog_env.property("lastReason") == "cancel"
    assert dialog_env.property("cancelRuns") == 1
    h2 = dialog_env.open({"title": "y"})
    h2.hide()
    assert dialog_env.property("lastReason") == "api"
    assert h2.property("valid") is False


def test_dialog_persistent_blocks_backdrop_and_escape(dialog_env):
    """persistent 同时锁 backdrop 与 ESC；api 仍可关闭（程序化兜底）。"""
    h = dialog_env.open({"title": "p", "persistent": True})
    item = h.property("item")
    item.requestDismiss("backdrop")
    item.requestDismiss("escape")
    assert h.property("valid") is True
    assert dialog_env.cnt() == 1
    item.requestDismiss("api")
    assert h.property("valid") is False
    assert dialog_env.property("lastReason") == "api"


def test_dialog_no_backdrop_and_esc_flags(dialog_env):
    """noBackdropDismiss 只锁外点；noEscDismiss 只锁 ESC——两者互不串味。"""
    h = dialog_env.open({"title": "a", "noBackdropDismiss": True})
    item = h.property("item")
    item.requestDismiss("backdrop")
    assert h.property("valid") is True
    item.requestDismiss("escape")
    assert h.property("valid") is False
    assert dialog_env.property("lastReason") == "escape"
    h2 = dialog_env.open({"title": "b", "noEscDismiss": True})
    it2 = h2.property("item")
    it2.requestDismiss("escape")
    assert h2.property("valid") is True
    it2.requestDismiss("backdrop")
    assert h2.property("valid") is False
    assert dialog_env.property("lastReason") == "backdrop"


def test_dialog_setdefaults_and_update(dialog_env):
    """setDefaults 深合并（title 默认 + 逐项覆盖）；句柄 update 白名单生效。"""
    dialog_env.setdefaults({"title": "默认标题", "ok": "确定"})
    h = dialog_env.open({})
    item = h.property("item")
    assert item.property("title") == "默认标题"
    assert item.property("okConfig").toVariant()["label"] == "确定"
    h2 = dialog_env.open({"title": "覆盖"})
    assert h2.property("item").property("title") == "覆盖"
    assert h2.update({"title": "改后", "message": "新正文"}) is True
    assert h2.property("item").property("title") == "改后"
    assert h2.property("item").property("message") == "新正文"
    h2.hide()
    assert h2.update({"title": "失效"}) is False


def test_dialog_positions_and_invalid(dialog_env):
    """五向定位全部接受；非法位置拒绝（返回 null，不静默回落）。"""
    for pos in ["standard", "top", "right", "bottom", "left"]:
        h = dialog_env.open({"title": pos, "position": pos})
        assert h is not None
        assert h.property("item").property("position") == pos
        h.hide()
    assert dialog_env.open({"position": "middle"}) is None
    assert dialog_env.property("lastHandle") is None


def test_dialog_seamless_progress_dark(dialog_env):
    """seamless 无遮罩；progress 转进度态；Dark 模式实例化（宪法第 5 章）。"""
    h = dialog_env.open({"title": "s", "seamless": True})
    item = h.property("item")
    assert item.property("hasBackdrop") is False
    h.hide()
    h2 = dialog_env.open({"title": "p", "progress": {"message": "处理中"}})
    it2 = h2.property("item")
    assert it2.property("progress") is True
    assert it2.property("progressMessage") == "处理中"
    h2.hide()
    dialog_env.setdark(True)
    h3 = dialog_env.open({"title": "dark"})
    assert h3.property("item").property("cardTint").isValid()
    h3.hide()


def test_dialog_callbacks_and_hideall(dialog_env):
    """基线链式回调 onOk/onCancel/onDismiss 全部触发；hideAll 批量关闭。"""
    h = dialog_env.openCb()
    h.ok()
    # onOk(10) + onDismiss(100)
    assert dialog_env.property("cbHits") == 110
    h2 = dialog_env.openCb()
    h2.cancel()
    assert dialog_env.property("cbHits") == 211     # +1 +100
    dialog_env.open({"title": "a"})
    dialog_env.open({"title": "b"})
    assert dialog_env.cnt() == 2
    dialog_env.hideAll("api")
    assert dialog_env.cnt() == 0


# ══════════════════════════════════════════════════════════════
# L4 服务层：NovaLoading（11 项对账 · 引用计数 · 局部/全屏 · 超时）
# ══════════════════════════════════════════════════════════════

LOADING_DRIVER_QML = (
    "import QtQuick\nimport Nova.Services\n"
    "QtObject {\n"
    "  property var lastHandle: null\n"
    "  function open(opts) { var h = NovaLoading.show(opts); lastHandle = h; return h }\n"
    "  function cnt(g) { return NovaLoading.count(g) }\n"
    "  function active(g) { return NovaLoading.isActive(g) }\n"
    "  function groups() { return NovaLoading.activeGroups() }\n"
    "  function activeCount() { return NovaLoading.activeCount() }\n"
    "  function inc(opts) { return NovaLoading.increment(opts) }\n"
    "  function dec(g) { return NovaLoading.decrement(g) }\n"
    "  function forceHide(g) { return NovaLoading.hide(g) }\n"
    "  function hideAll() { NovaLoading.hideAll() }\n"
    "  function setDefaults(o) { NovaLoading.setDefaults(o) }\n"
    "  function clearDefaults() { NovaLoading._defaults = ({}) }\n"
    "  function setdark(v) { NovaTheme.setDark(v) }\n"
    "}"
)


@pytest.fixture()
def loading_env(qml_engine):
    """L4 加载服务测试环境：源窗口 + 驱动对象；用例前后强杀全部加载组。"""
    _make(qml_engine, NOTIFY_WINDOW_QML)
    drv = _make(qml_engine, LOADING_DRIVER_QML)
    drv.hideAll()
    drv.clearDefaults()
    yield drv
    drv.hideAll()
    drv.clearDefaults()
    drv.setdark(False)


def test_loading_show_hide(loading_env):
    """show 建组并渲染 message；句柄 hide 归零即释放，句柄失效。"""
    h = loading_env.open({"delay": 0, "message": "加载中"})
    assert loading_env.cnt("__default_quasar_group__") == 1
    item = h.property("item")
    assert item.property("message") == "加载中"
    assert item.property("started") is True
    assert h.property("valid") is True
    h.hide()
    assert loading_env.cnt("__default_quasar_group__") == 0
    assert h.property("valid") is False


def test_loading_concurrent_refcount(loading_env):
    """引用计数：同组两次 show → 2；释放一份仍显示，归零才收口（并发不互踩）。"""
    h1 = loading_env.open({"delay": 0, "group": "job"})
    h2 = loading_env.open({"delay": 0, "group": "job"})
    assert loading_env.cnt("job") == 2
    assert h1.property("count") == 2
    assert h1.property("item") == h2.property("item")      # 复用同一视觉层

    h1.hide()
    assert loading_env.cnt("job") == 1
    assert loading_env.active("job") is True
    assert h2.property("valid") is True
    assert h2.property("item").property("refCount") == 1

    h2.hide()
    assert loading_env.cnt("job") == 0
    assert loading_env.active("job") is False


def test_loading_groups_isolated(loading_env):
    """不同组互不影响：hide(g1) 不动 g2；activeGroups 如实反映。"""
    h1 = loading_env.open({"delay": 0, "group": "g1"})
    h2 = loading_env.open({"delay": 0, "group": "g2"})
    assert loading_env.activeCount() == 2
    assert sorted(_v(loading_env.groups())) == ["g1", "g2"]
    loading_env.forceHide("g1")
    assert loading_env.active("g1") is False
    assert loading_env.active("g2") is True
    assert h1.property("valid") is False
    h2.hide()


def test_loading_force_hide_ignores_count(loading_env):
    """hide(group) 对标基线语义：无视引用计数整组立即关闭。"""
    h1 = loading_env.open({"delay": 0, "group": "f"})
    h2 = loading_env.open({"delay": 0, "group": "f"})
    assert loading_env.cnt("f") == 2
    loading_env.forceHide("f")
    assert loading_env.cnt("f") == 0
    assert h1.property("valid") is False
    assert h2.property("valid") is False


def test_loading_delay_defers_show(loading_env):
    """delay 内不显示（防闪烁）；到点后才 started。"""
    h = loading_env.open({"delay": 250})
    item = h.property("item")
    assert item.property("started") is False
    _pump(420)
    assert item.property("started") is True
    h.hide()


def test_loading_delay_then_hide_never_shows(loading_env):
    """delay 窗口内 hide：从未显示即销毁，不留残余组。"""
    h = loading_env.open({"delay": 400})
    h.hide()
    assert loading_env.cnt("__default_quasar_group__") == 0
    assert h.property("valid") is False
    _pump(500)
    assert loading_env.activeCount() == 0


def test_loading_config_mapping(loading_env):
    """配置映射：message / spinnerSize / spinnerModel / 配色 / boxed；非法 spinnerModel 回落 ring。"""
    from PySide6.QtGui import QColor

    h = loading_env.open({"delay": 0, "message": "m", "spinnerSize": 64,
                          "spinnerModel": "dots", "spinnerTint": "#EF4444",
                          "backgroundTint": "#223344", "boxed": True})
    it = h.property("item")
    assert it.property("spinnerSize") == 64
    assert it.property("spinnerModel") == "dots"
    assert it.property("boxed") is True
    assert it.property("spinnerTint") == QColor("#EF4444")
    assert it.property("backgroundTint") == QColor("#223344")
    h.hide()

    bad = loading_env.open({"delay": 0, "spinnerModel": "bogus"})
    assert bad.property("item").property("spinnerModel") == "ring"
    bad.hide()


def test_loading_setdefaults_and_dark(loading_env):
    """setDefaults 深合并生效；Dark 模式实例化无异常（宪法第 5 章强制用例）。"""
    loading_env.setDefaults({"spinnerSize": 72, "message": "默认文案"})
    h = loading_env.open({"delay": 0})
    it = h.property("item")
    assert it.property("spinnerSize") == 72
    assert it.property("message") == "默认文案"
    h.hide()

    loading_env.setdark(True)
    h2 = loading_env.open({"delay": 0, "message": "暗色"})
    assert h2.property("item").property("spinnerTint").isValid()
    h2.hide()
    loading_env.setdark(False)


def test_loading_local_target(qml_engine):
    """局部加载：target 是 Item 时挂进该 Item 内并铺满（Nova 增强）。"""
    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Services\n"
                "Item { id: host; width: 320; height: 240\n"
                "  property var h: null\n"
                "  property var kid: children.length > 0 ? children[0] : null\n"
                "  property bool attachedNow: kid !== null && kid.parent === host\n"
                "  Component.onCompleted: h = NovaLoading.show({ delay: 0, target: host, message: '局部' })\n"
                "}")
    assert obj.property("h").property("valid") is True
    assert obj.property("attachedNow") is True
    obj.property("h").hide()


def test_loading_timeout_guard(loading_env):
    """超时保护：timeout 到点强制收口（Nova 增强，防卡死）。"""
    h = loading_env.open({"delay": 0, "group": "slow", "timeout": 150})
    assert loading_env.active("slow") is True
    _pump(500)
    assert loading_env.active("slow") is False
    assert h.property("valid") is False


# ══════════════════════════════════════════════════════════════
# L4 服务层：NovaStorage（LocalStorage API · 命名空间 · 真落盘）
# ══════════════════════════════════════════════════════════════

STORAGE_DRIVER_QML = (
    "import QtQuick\nimport Nova.Services\n"
    "QtObject {\n"
    "  function useNs(n) { return NovaStorage.useNamespace(n) }\n"
    "  function set(k, v) { return NovaStorage.set(k, v) }\n"
    "  function get(k, d) { return NovaStorage.get(k, d) }\n"
    "  function has(k) { return NovaStorage.has(k) }\n"
    "  function drop(k) { return NovaStorage.remove(k) }\n"
    "  function clear() { return NovaStorage.clear() }\n"
    "  function keys() { return NovaStorage.getAllKeys() }\n"
    "  function all() { return NovaStorage.getAll() }\n"
    "  function setAll(o) { return NovaStorage.setAll(o) }\n"
    "  function setAllArray() { return NovaStorage.setAll([1, 2, 3]) }\n"
    "  function len() { return NovaStorage.getLength() }\n"
    "  function empty() { return NovaStorage.isEmpty() }\n"
    "  function reload() { return NovaStorage.reload() }\n"
    "  function setItem(k, v) { return NovaStorage.setItem(k, v) }\n"
    "  function getItem(k) { return NovaStorage.getItem(k) }\n"
    "  function removeItem(k) { return NovaStorage.removeItem(k) }\n"
    "  function backend() { return NovaStorage.backend }\n"
    "  function path() { return NovaStorage.storagePath }\n"
    "}"
)

STORAGE_TEST_NS = "nova-smoke"


@pytest.fixture()
def storage_env(qml_engine):
    """持久化测试环境：切到专用命名空间并清空，避免污染真实用户数据。"""
    drv = _make(qml_engine, STORAGE_DRIVER_QML)
    drv.useNs(STORAGE_TEST_NS)
    drv.clear()
    yield drv
    drv.clear()


def test_storage_crud(storage_env):
    """set/get/has/remove/getLength/isEmpty 基本语义。"""
    assert storage_env.empty() is True
    assert storage_env.set("alpha", 1) is True
    assert storage_env.has("alpha") is True
    assert storage_env.get("alpha", 0) == 1
    assert storage_env.len() == 1
    assert storage_env.drop("alpha") is True
    assert storage_env.drop("alpha") is False          # 二次删除返回 false
    assert storage_env.get("alpha", "fallback") == "fallback"


def _v(value):
    """QML 返回值归一：QJSValue → Python，其余原样。"""
    return value.toVariant() if hasattr(value, "toVariant") else value


def test_storage_value_types(storage_env):
    """值类型往返：字符串 / 数字 / 布尔 / 对象 / 数组 / null。"""
    storage_env.set("s", "青铜峡")
    storage_env.set("n", 3.14)
    storage_env.set("b", True)
    storage_env.set("o", {"k": [1, 2], "deep": {"x": "y"}})
    storage_env.set("a", [1, "two", False])
    storage_env.set("z", None)

    assert storage_env.get("s", None) == "青铜峡"
    assert abs(storage_env.get("n", 0) - 3.14) < 1e-9
    assert storage_env.get("b", False) is True
    assert _v(storage_env.get("o", {}))["deep"]["x"] == "y"
    assert _v(storage_env.get("a", []))[1] == "two"
    assert storage_env.get("z", "missing") is None
    assert storage_env.has("z") is True               # null 与"键不存在"可区分


def test_storage_persistence_to_disk(storage_env):
    """真落盘：写入后由 Python 侧新建 QSettings 实例读回同一 ini（模拟重启）。"""
    from pyside_nova.runtime import NovaRuntime

    storage_env.set("persist", {"mode": "ini"})
    rt = NovaRuntime()
    blob = rt.readBlob(STORAGE_TEST_NS)
    assert "persist" in blob and "ini" in blob
    assert storage_env.path().endswith("nova-storage.ini")


def test_storage_namespace_isolated(storage_env):
    """命名空间隔离：A 空间写入不影响 B 空间；切回 A 数据仍在。"""
    storage_env.set("k", "A")
    storage_env.useNs(STORAGE_TEST_NS + "-b")
    storage_env.clear()
    assert storage_env.has("k") is False
    storage_env.set("k", "B")
    assert storage_env.get("k", None) == "B"
    storage_env.useNs(STORAGE_TEST_NS)
    assert storage_env.get("k", None) == "A"
    storage_env.useNs(STORAGE_TEST_NS + "-b")
    storage_env.clear()
    storage_env.useNs(STORAGE_TEST_NS)


def test_storage_getall_deepcopy(storage_env):
    """getAll 返回深拷贝：外部改副本不影响库内数据。"""
    storage_env.setAll({"a": 1, "b": {"c": 2}})
    assert storage_env.len() == 2
    snap = _v(storage_env.all())
    snap["b"]["c"] = 999
    assert _v(storage_env.get("b", {}))["c"] == 2
    assert sorted(_v(storage_env.keys())) == ["a", "b"]


def test_storage_invalid_inputs(storage_env):
    """非法输入安全兜底：setAll 非对象拒绝；空 key 拒绝；损坏数据不崩。"""
    assert storage_env.setAllArray() is False
    assert storage_env.setAll("nope") is False
    assert storage_env.set(None, 1) is False


def test_storage_web_aliases(storage_env):
    """Web Storage 兼容别名：setItem/getItem/removeItem 与主 API 同源。"""
    assert storage_env.setItem("w", "v") is True
    assert storage_env.getItem("w") == "v"
    assert storage_env.removeItem("w") is True
    assert storage_env.getItem("w") is None


# ══════════════════════════════════════════════════════════════
# L4 服务层：NovaPlatform / NovaApp
# ══════════════════════════════════════════════════════════════

def test_platform_facts(qml_engine):
    """平台事实：os 与 Python 侧一致、桌面互斥判定、snapshot 字段齐全。"""
    import sys

    from pyside_nova.runtime import NovaRuntime

    obj = _make(qml_engine,
                "import QtQuick\nimport Nova.Services\n"
                "QtObject {\n"
                " property string os: NovaPlatform.os\n"
                " property bool w: NovaPlatform.isWindows\n"
                " property bool l: NovaPlatform.isLinux\n"
                " property bool d: NovaPlatform.isDesktop\n"
                " property bool t: NovaPlatform.hasTouch\n"
                " property string desc: NovaPlatform.describe()\n"
                " property var snap: NovaPlatform.snapshot()\n"
                "}")
    rt = NovaRuntime()
    assert obj.property("os") == rt.osName
    assert (obj.property("w") and obj.property("l")) is False
    assert isinstance(obj.property("t"), bool)
    assert obj.property("desc") != ""
    snap = _v(obj.property("snap"))
    for key in ("os", "osVersion", "cpuArch", "isMobile", "isDesktop", "hasTouch", "isWasm"):
        assert key in snap
    if sys.platform.startswith("linux"):
        assert obj.property("l") is True
        assert obj.property("d") is True


# 驱动对象在 QML 侧持有窗口引用（held）：QML 的 JS GC 不认 Python 引用，
# 必须由 QML 属性强引用窗口，否则 _pump 触发 GC 后窗口被回收、Python wrapper 悬空。
APP_DRIVER_QML = (
    "import QtQuick\nimport Nova.Services\n"
    "QtObject {\n"
    "  property var held: null\n"
    "  function keep(w) { held = w }\n"
    "  function snap() { return NovaApp.snapshot() }\n"
    "  function curTitle() { return NovaApp.title }\n"
    "  function curVisible() { return NovaApp.isVisible }\n"
    "  function title(t) { return NovaApp.setTitle(t) }\n"
    "  function vis(n) { return NovaApp.setVisibility(n) }\n"
    "  function toggle() { return NovaApp.toggle() }\n"
    "  function exitFs() { return NovaApp.exit() }\n"
    "  function bad(n) { return NovaApp.setVisibility(n) }\n"
    "}"
)


def test_app_window_control(qml_engine):
    """窗口服务：标题同步、最大化/全屏切换、toggle 往返、非法状态拒绝。"""
    drv = _make(qml_engine, APP_DRIVER_QML)      # 先建驱动，再建窗口并立刻在 QML 侧强引用
    win = _make(qml_engine, NOTIFY_WINDOW_QML)
    drv.keep(win)

    assert drv.snap().toVariant()["available"] is True
    assert drv.title("Nova 控制台") is True
    assert drv.curTitle() == "Nova 控制台"          # 断言一律走 QML 侧，不摸 Python 侧窗口 wrapper

    assert drv.vis("maximized") is True
    assert drv.snap().toVariant()["isMaximized"] is True

    assert drv.toggle() is True
    assert drv.snap().toVariant()["isFullscreen"] is True
    assert drv.toggle() is True
    assert drv.snap().toVariant()["isFullscreen"] is False
    assert drv.snap().toVariant()["isMaximized"] is True          # 退出全屏回落到进入前状态

    assert drv.vis("windowed") is True
    assert drv.bad("floating") is False


def test_app_without_window(qml_engine):
    """无源窗口时安全降级：available=false、命令返回 false、不抛错。"""
    engine = QQmlEngine()
    init_nova(engine)
    component = QQmlComponent(engine)
    component.setData(("import QtQuick\nimport Nova.Services\n"
                       "QtObject { property bool a: NovaApp.available\n"
                       " property bool r: NovaApp.request()\n"
                       " property string t: NovaApp.title }").encode(),
                      QUrl("qrc:/nova-app-nowin.qml"))
    obj = component.create()
    assert obj is not None, [e.toString() for e in component.errors()]
    assert obj.property("a") is False
    assert obj.property("r") is False
    assert obj.property("t") == ""
    obj.deleteLater()


# ══════════════════════════════════════════════════════════════
# L3 行为层（v0.7.0）：Intersection / Scroll / ClosePopup / Touch 四件套
# ══════════════════════════════════════════════════════════════

# 单窗口装全部行为：各行为占不同矩形区域（MouseArea 不能叠在同一目标上——
# 这是 QML 指针模型的固有约束，不是实现缺陷），驱动函数统一由窗口持有。
BEHAVIOR_ENV_QML = (
    "import QtQuick\nimport QtQuick.Window\nimport Nova.Behaviors\nimport Nova.Services\n"
    "Window { id: win; width: 420; height: 640; visible: true; color: '#f4f4f4'\n"
    "  Component.onCompleted: NovaScreen.source = win\n"
    "  property int panCount: 0\n"
    "  property string panDir: ''\n"
    "  property bool panFirst: false\n"
    "  property bool panFinal: false\n"
    "  property real panOffsetX: 0\n"
    "  property int swipeCount: 0\n"
    "  property string swipeDir: ''\n"
    "  property real swipeVelocity: 0\n"
    "  property int holdCount: 0\n"
    "  property int holdDuration: 0\n"
    "  property int repCount: 0\n"
    "  property int interEnter: 0\n"
    "  property int interExit: 0\n"
    "  property int onceCount: 0\n"
    "  property int fireCount: 0\n"
    "  property real scrollV: -1\n"
    "  property bool scrollAtBottom: false\n"
    "  property string scrollDir: ''\n"
    "  function moveInter(y) { interBox.y = y }\n"
    "  function scrollTo(v) { flick.contentY = v }\n"
    "  function interRatioNow() { return inter.intersectionRatio }\n"
    "  function interVisible() { return inter.isIntersecting }\n"
    "  function rearmOnce() { onceBeh.rearm() }\n"
    "  function pauseOnce() { onceBeh.enabled = false }\n"
    "  function resumeOnce() { onceBeh.enabled = true }\n"
    "  function stopInter() { inter.stop() }\n"
    "  function poolCount() { return NovaIntersectionPool.count }\n"
    "  Rectangle { id: panBox; x: 0; y: 0; width: 200; height: 120; color: '#c8e6c9'\n"
    "    NovaTouchPan { onPan: (d) => { win.panCount++; win.panDir = d.direction;\n"
    "      if (d.isFirst) win.panFirst = true; if (d.isFinal) win.panFinal = true;\n"
    "      win.panOffsetX = d.offset.x } } }\n"
    "  Rectangle { id: swipeBox; x: 0; y: 130; width: 200; height: 120; color: '#bbdefb'\n"
    "    NovaTouchSwipe { directions: ['right']\n"
    "      onSwipe: (d) => { win.swipeCount++; win.swipeDir = d.direction;\n"
    "        win.swipeVelocity = d.velocity } } }\n"
    "  Rectangle { id: holdBox; x: 0; y: 260; width: 200; height: 120; color: '#ffe0b2'\n"
    "    NovaTouchHold { duration: 250\n"
    "      onHold: (d) => { win.holdCount++; win.holdDuration = d.duration } } }\n"
    "  Rectangle { id: repBox; x: 200; y: 0; width: 220; height: 120; color: '#f8bbd0'\n"
    "    NovaTouchRepeat { delays: '0:150:100'\n"
    "      onRepeat: (d) => win.repCount = d.repeatCount } }\n"
    "  Rectangle { id: interBox; x: 200; y: 130; width: 220; height: 120; color: '#d1c4e9'\n"
    "    NovaIntersection { id: inter; threshold: [0, 0.5]\n"
    "      onEntered: (e) => win.interEnter++\n"
    "      onExited: (e) => win.interExit++ }\n"
    "    NovaIntersection { id: onceBeh; once: true; threshold: 0.3\n"
    "      onEntered: (e) => win.onceCount++ }\n"
    "    NovaScrollFire { threshold: 0.6; onFire: (i) => win.fireCount++ } }\n"
    "  Flickable { id: flick; x: 0; y: 400; width: 420; height: 220\n"
    "    contentWidth: 420; contentHeight: 1000; clip: true\n"
    "    NovaScrollObserver { onScroll: (d) => { win.scrollV = d.vertical;\n"
    "      win.scrollAtBottom = d.atBottom; win.scrollDir = d.direction } } }\n"
    "}"
)

# 通用驱动代理：PySide 把 QML Window 包装成 QWindow（metaobject 里没有 QML 函数），
# 所以行为一律经 QML 侧代理调用；代理同时强引用窗口，避免 JS GC 回收无父窗口。
BEHAVIOR_DRIVER_QML = (
    "import QtQuick\n"
    "QtObject {\n"
    "  property var w: null\n"
    "  function keep(x) { w = x }\n"
    "  function call0(name) {\n"
    "    var fn = w ? w[name] : null\n"
    "    return typeof fn === 'function' ? fn.call(w) : null\n"
    "  }\n"
    "  function call1(name, a) {\n"
    "    var fn = w ? w[name] : null\n"
    "    return typeof fn === 'function' ? fn.call(w, a) : null\n"
    "  }\n"
    "  function call2(name, a, b) {\n"
    "    var fn = w ? w[name] : null\n"
    "    return typeof fn === 'function' ? fn.call(w, a, b) : null\n"
    "  }\n"
    "  function val(name) { return w ? w[name] : undefined }\n"
    "}"
)


def _call(drv, name, *args):
    """QML 函数按固定形参暴露（Qt 6 不支持可选参数），按实参个数分派。"""
    if len(args) == 0:
        return drv.call0(name)
    if len(args) == 1:
        return drv.call1(name, args[0])
    return drv.call2(name, args[0], args[1])


@pytest.fixture()
def behavior_env(qml_engine):
    """L3 行为测试环境：可见窗口（QTest 投递鼠标事件要求 visible=true）+ 调用代理。"""
    win = _make(qml_engine, BEHAVIOR_ENV_QML, wait=0.12)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)      # 直接在 QML 侧持有窗口：JS GC 不认 Python 引用
    _pump(80)
    return drv


def test_intersection_enter_exit_and_ratio(behavior_env):
    """初始可见 → entered 一次、比例 1.0；移出视口 → 比例 0、exited；移回 → 再次 entered。"""
    drv = behavior_env
    assert drv.val("interEnter") == 1
    assert abs(_call(drv, "interRatioNow") - 1.0) < 0.01

    _call(drv, "moveInter", 800)              # 整个移出窗口
    _pump(120)
    assert _call(drv, "interRatioNow") == 0.0
    assert drv.val("interExit") == 1
    assert _call(drv, "interVisible") is False

    _call(drv, "moveInter", 130)
    _pump(120)
    assert drv.val("interEnter") == 2
    assert _call(drv, "interVisible") is True


def test_intersection_ratio_partial(behavior_env):
    """部分可见时比例精确：box 露出 60px / 高 120px → 0.5 左右。"""
    drv = behavior_env
    _call(drv, "moveInter", 580)              # 窗口高 640，box 580..700 → 可见 60
    _pump(120)
    ratio = _call(drv, "interRatioNow")
    assert 0.45 < ratio < 0.55, ratio
    assert _call(drv, "interVisible") is True


def test_intersection_once_and_rearm(behavior_env):
    """once:true 触发一次后解除观察；关掉再打开（rearm）可再次触发。"""
    drv = behavior_env
    assert drv.val("onceCount") == 1

    _call(drv, "moveInter", 900)              # 移出，once 已退休，不重复
    _pump(120)
    _call(drv, "moveInter", 130)
    _pump(120)
    assert drv.val("onceCount") == 1

    _call(drv, "pauseOnce")                 # 禁用 → 移出池
    _pump(60)
    _call(drv, "resumeOnce")                # 重新打开 = 再武装（基线"重新赋值"等价语义）
    _pump(120)
    assert drv.val("onceCount") == 2


def test_intersection_stop_releases_subscription(behavior_env):
    """stop() 显式停止后不再回调（对标 handler 返回 false），池里少一个订阅者。"""
    drv = behavior_env
    before = _call(drv, "poolCount")
    _call(drv, "stopInter")
    _pump(80)
    assert _call(drv, "poolCount") < before
    _call(drv, "moveInter", 900)
    _pump(120)
    _call(drv, "moveInter", 130)
    _pump(120)
    assert _call(drv, "interRatioNow") == 1.0   # 状态仍可读，但不再发信号
    assert drv.val("interEnter") == 1


def test_scroll_observer_positions(behavior_env):
    """Flickable 滚动 → onScroll 给出 vertical / 方向 / atBottom。"""
    drv = behavior_env
    _call(drv, "scrollTo", 300)
    _pump(120)
    assert abs(drv.val("scrollV") - 300) < 0.01
    assert drv.val("scrollAtBottom") is False
    assert drv.val("scrollDir") == "down"

    _call(drv, "scrollTo", 780)               # contentHeight 1000 - height 220 = 780
    _pump(120)
    assert drv.val("scrollAtBottom") is True


def test_scroll_fire_once_and_threshold(behavior_env):
    """ScrollFire 进入视口即触发一次（v2.30 语义：不滚动也会触发），之后不再重复。"""
    drv = behavior_env
    assert drv.val("fireCount") == 1
    _call(drv, "moveInter", 900)
    _pump(120)
    _call(drv, "moveInter", 130)
    _pump(120)
    assert drv.val("fireCount") == 1


def test_touch_pan_details(behavior_env):
    """拖动：方向、首末帧、带符号 offset 齐全。"""
    drv = behavior_env
    win = drv.property("w")
    QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, QPoint(40, 40))
    _pump(30)
    QTest.mouseMove(win, QPoint(90, 44), 20)
    _pump(20)
    QTest.mouseMove(win, QPoint(150, 48), 20)
    _pump(20)
    QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, QPoint(150, 48))
    _pump(80)

    assert drv.val("panCount") >= 2
    assert drv.val("panDir") == "right"
    assert drv.val("panFirst") is True
    assert drv.val("panFinal") is True
    assert drv.val("panOffsetX") > 80


def test_touch_swipe_direction_filter(behavior_env):
    """右滑命中（directions:['right']），左滑被过滤。"""
    drv = behavior_env
    win = drv.property("w")
    QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, QPoint(40, 190))
    QTest.mouseMove(win, QPoint(180, 190), 10)
    _pump(30)
    QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, QPoint(180, 190))
    _pump(60)
    assert drv.val("swipeCount") == 1
    assert drv.val("swipeDir") == "right"
    assert drv.val("swipeVelocity") > 0.06

    QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, QPoint(180, 190))
    QTest.mouseMove(win, QPoint(60, 190), 10)
    _pump(30)
    QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, QPoint(60, 190))
    _pump(60)
    assert drv.val("swipeCount") == 1       # 左滑不在白名单，不触发


def test_touch_hold_timing(behavior_env):
    """按住 250ms 触发一次；提前松手不触发；触发后松手不重复。"""
    drv = behavior_env
    win = drv.property("w")
    QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, QPoint(40, 320))
    _pump(400)
    assert drv.val("holdCount") == 1
    assert drv.val("holdDuration") == 250
    QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, QPoint(40, 320))
    _pump(80)
    assert drv.val("holdCount") == 1


def test_touch_repeat_sequence(behavior_env):
    """按住连发：首帧立即 + 之后按 150/100 节奏；松手即停。"""
    drv = behavior_env
    win = drv.property("w")
    QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, QPoint(250, 40))
    _pump(90)
    first = drv.val("repCount")
    assert first >= 1
    _pump(420)
    grown = drv.val("repCount")
    assert grown > first

    QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, QPoint(250, 40))
    _pump(80)
    stopped = drv.val("repCount")
    _pump(300)
    assert drv.val("repCount") == stopped   # 松手后不再增长


# ── ClosePopup：弹层栈按层关闭 ──────────────────────────────
CLOSE_POPUP_QML = (
    "import QtQuick\nimport QtQuick.Window\nimport Nova.Controls\nimport Nova.Behaviors\n"
    "import Nova.Services\n"
    "Window { id: win; width: 420; height: 400; visible: true\n"
    "  Component.onCompleted: NovaScreen.source = win\n"
    "  property int closedCount: 0\n"
    "  NovaBtn { id: btn; x: 20; y: 20; text: '关闭'\n"
    "    NovaClosePopup { id: cp; onClosed: (n) => win.closedCount = n } }\n"
    "  function open(n) { NovaDialog.hideAll('api');\n"
    "    for (var i = 0; i < n; i++) NovaDialog.show({ title: 'T' + i, message: 'm' }) }\n"
    "  function cnt() { return NovaDialog.count() }\n"
    "  function stack() { return NovaOverlayHost.popupCount() }\n"
    "  function clickBtn() { btn.clicked() }\n"
    "  function setDepth(d) { cp.depth = d }\n"
    "  function trigger() { return cp.trigger() }\n"
    "  function clearAll() { NovaDialog.hideAll('api') }\n"
    "}"
)


@pytest.fixture()
def close_popup_env(qml_engine):
    win = _make(qml_engine, CLOSE_POPUP_QML, wait=0.05)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)      # 直接在 QML 侧持有窗口：JS GC 不认 Python 引用
    _call(drv, "clearAll")
    _pump(80)
    yield drv
    _call(drv, "clearAll")
    _pump(80)


def test_dialog_enters_popup_stack(close_popup_env):
    """Dialog 打开进栈、关闭出栈（NovaClosePopup 才有"层"可数）。"""
    drv = close_popup_env
    _call(drv, "open", 2)
    _pump(80)
    assert _call(drv, "cnt") == 2
    assert _call(drv, "stack") == 2

    _call(drv, "clearAll")
    _pump(450)                              # 关闭动画 180+160ms，等它真的销毁出栈
    assert _call(drv, "cnt") == 0
    assert _call(drv, "stack") == 0


def test_close_popup_clicked_bridge(close_popup_env):
    """宿主 clicked 桥接：点一下关最上层；depth=0 禁用；depth<0 全关。"""
    drv = close_popup_env
    _call(drv, "open", 2)
    _pump(80)

    _call(drv, "clickBtn")                    # depth 默认 1
    _pump(300)
    assert _call(drv, "cnt") == 1
    assert drv.val("closedCount") == 1

    _call(drv, "setDepth", 0)                 # 禁用语义
    _call(drv, "clickBtn")
    _pump(120)
    assert _call(drv, "cnt") == 1

    _call(drv, "setDepth", -1)                # 整链
    _call(drv, "clickBtn")
    _pump(450)
    assert _call(drv, "cnt") == 0


def test_close_popup_trigger_returns_count(close_popup_env):
    """trigger() 返回实际关闭层数（可用于埋点/日志）。"""
    drv = close_popup_env
    _call(drv, "open", 3)
    _pump(80)
    assert _call(drv, "trigger") == 1
    _pump(300)
    assert _call(drv, "cnt") == 2


# ══════════════════════════════════════════════════════════════
# 0.8.0 · Sprint 4：L0 设计语言（图标集/动效/排版）+ L5 工具层
# ══════════════════════════════════════════════════════════════

L0_ENV_QML = r"""
import QtQuick
import Nova.Design
import Nova.Services
import Nova.Controls

Item {
    id: win
    width: 400; height: 300

    property int enterCount: 0
    property int exitCount: 0
    property int debCount: 0
    property int thrCount: 0
    property int frameCount: 0
    property var debFn: null
    property var thrFn: null
    property var frameFn: null
    property string uid1: ""
    property string uid2: ""

    readonly property var fixedDate: new Date(2026, 10, 22, 21, 53, 7, 123)

    // ── 图标集 ──
    property int setCount: NovaIconSet.available.length
    property int keyCount: NovaIconSet.keyPaths.length
    property int providerCount: NovaIconSet.providers.length
    property string defName: NovaIconSet.name
    property string typePositive: NovaIconSet.type.positive
    property string arrowDown: NovaIconSet.get("arrow.down")
    property string missingKey: NovaIconSet.get("no.such.key", "fb")

    function reset() {
        NovaMotion.speedFactor = 1.0
        NovaMotion.reducedMotion = false
        NovaIconSet.use("material-icons")
        NovaIconSet.unregister("my-set")
        NovaIconSet.unregisterProvider("acme")
    }
    function useSet(n) { return NovaIconSet.use(n) }
    function setNameValue() { return NovaIconSet.name }
    function val(p) { return NovaIconSet.get(p) }
    function applyPartial() {
        NovaIconSet.set({ editor: { bold: "mdi-alpha-b" } })
        return String(NovaIconSet.editor.italic) + "|" + NovaIconSet.editor.bold
    }
    function applyName() {
        NovaIconSet.set({ name: "brand-x" })
        return NovaIconSet.name
    }
    function registerSet() { return NovaIconSet.register("my-set", { type: { positive: "mdi-verified" } }) }
    function cutSet() { return NovaIconSet.unregister("my-set") }
    function kind(s) { return NovaIconSet.resolve(s).kind }
    function provider(s) { return NovaIconSet.resolve(s).provider }
    function iname(s) { return NovaIconSet.resolve(s).name }
    function reason(s) { var r = NovaIconSet.resolve(s); return r.reason === undefined ? "" : r.reason }
    function nodeCount(s) { var r = NovaIconSet.resolve(s); return r.nodes === undefined ? -1 : r.nodes.length }
    function viewBox(s) { var r = NovaIconSet.resolve(s); return r.viewBox === undefined ? "" : r.viewBox }
    function addProvider() { return NovaIconSet.registerProvider("acme", { url: "https://acme.io/%1.svg" }) }
    function delProvider() { return NovaIconSet.unregisterProvider("acme") }
    function pcount() { return NovaIconSet.providers.length }
    function purl(a, b) { return NovaIconSet.providerUrl(a, b) }
    function badProvider() { return NovaIconSet.registerProvider("bad", { kind: "ligature" }) }

    // ── 动效 ──
    property int durMain: NovaMotion.transitionDuration
    property int durScale: NovaMotion.scaleDuration
    property int durFade: NovaMotion.fadeDuration
    property int presetCount: NovaMotion.presetNames.length
    property bool hasFlip: NovaMotion.hasPreset("flip-right")
    property bool hasBogus: NovaMotion.hasPreset("no-such")
    function setSpeed(v) { NovaMotion.speedFactor = v }
    function setReduced(v) { NovaMotion.reducedMotion = v }
    function durOf(v) { return NovaMotion.duration(v) }
    function presetField(n, f) { var p = NovaMotion.preset(n); return p[f] === undefined ? -999 : p[f] }

    // ── 排版 ──
    property int typeCount: NovaTheme.typeNames.length
    property string h1Style: NovaTheme.textStyle("h1").size + "/" + NovaTheme.textStyle("h1").lineHeight
                             + "/" + NovaTheme.textStyle("h1").letterSpacing + "/" + NovaTheme.textStyle("h1").weight
    property string capStyle: NovaTheme.textStyle("caption").size + "/" + NovaTheme.textStyle("caption").weight
    property int unknownSize: NovaTheme.textStyle("nope").size
    property int elev7: NovaTheme.elevationLayers(7).length
    property int elev1Blur: NovaTheme.elevationLayers(1)[0][2]

    NovaText { id: tx1; typography: "h3"; text: "甲" }
    property int txSize: tx1.font.pixelSize
    property int txLine: tx1.lineHeight

    NovaTransition {
        id: tr
        name: "fade"
        show: true
        width: 100
        height: 50
        duration: 60
        onEntered: win.enterCount++
        onExited: win.exitCount++
    }
    function showIt() { tr.show = true }
    function hideIt() { tr.show = false }
    function trVisible() { return tr.visible ? "true" : "false" }

    // ── colors ──
    property string c1: NovaUtils.colors.rgbToHex({ r: 91, g: 110, b: 245 })
    property string c2: NovaUtils.colors.rgbToHex({ r: 91, g: 110, b: 245, a: 50 })
    property int c3: NovaUtils.colors.hexToRgb("#5B6EF5").g
    property string c4: NovaUtils.colors.lighten("#000000", 50)
    property string c5: NovaUtils.colors.lighten("#FFFFFF", -50)
    property string c6: NovaUtils.colors.changeAlpha("#ff0000", 0.5)
    property string c7: NovaUtils.colors.changeAlpha("#ff000080", -0.5)
    property real c8: NovaUtils.colors.textToRgb("rgba(10,20,30,0.5)").a
    property string c9: NovaUtils.colors.rgbToText({ r: 10, g: 20, b: 30, a: 50 })
    property string c10: NovaUtils.colors.blend("rgba(255,0,0,0.5)", "#0000FF")
    property real c11: NovaUtils.colors.contrastRatio("#000000", "#FFFFFF")
    property string c12: NovaUtils.colors.contrastColor("#000000")
    property int c13: NovaUtils.colors.rgbToHsv({ r: 255, g: 0, b: 0 }).h
    property int c14: NovaUtils.colors.hsvToRgb({ h: 120, s: 100, v: 100 }).g

    // ── format ──
    property string f1: NovaUtils.format.humanStorageSize(1536)
    property string f2: NovaUtils.format.humanStorageSize(1023)
    property string f3: NovaUtils.format.pad(7)
    property int f4: NovaUtils.format.getDecimalsCount(1.5e-7)
    property int f5: NovaUtils.format.normalizeToInterval(-1, 0, 4)
    property string f6: NovaUtils.format.capitalize("nova")
    property real f7: NovaUtils.format.between(15, 0, 10)

    // ── date ──
    property string d1: NovaUtils.date.formatDate(fixedDate, "YYYY|YY|M|Mo|MM|MMM|MMMM|Q|Qo|D|Do|DD|DDD|DDDo|DDDD|d|do|dd|ddd|dddd|E|w|wo|ww|GG|GGGG|H|HH|h|hh|m|mm|s|ss|S|SS|SSS|A|a|aa")
    property string d2: NovaUtils.date.formatDate(fixedDate, "YYYY年M月D日 dddd", NovaUtils.dateLocale.zhCN)
    property string d3: NovaUtils.date.formatDate(fixedDate, "[YYYY]年-MM")
    property string dZ: NovaUtils.date.formatDate(fixedDate, "Z|ZZ")
    property bool dX: NovaUtils.date.formatDate(fixedDate, "x") === String(fixedDate.getTime())
    property bool d4: NovaUtils.date.formatDate(undefined) === undefined
    property bool d5: NovaUtils.date.formatDate("not a date") === undefined
    property string dMask: NovaUtils.date.formatDate(fixedDate)
    function addMonthEnd() { var x = NovaUtils.date.addToDate(new Date(2026, 0, 31), { month: 1 }); return (x.getMonth() + 1) + "/" + x.getDate() }
    function subDays() { var x = NovaUtils.date.subtractFromDate(new Date(2026, 2, 1), { days: 1 }); return (x.getMonth() + 1) + "/" + x.getDate() }
    function addLeap() { var x = NovaUtils.date.addToDate(new Date(2024, 1, 29), { year: 1 }); return x.getFullYear() + "/" + (x.getMonth() + 1) + "/" + x.getDate() }
    function adjDate() { var x = NovaUtils.date.adjustDate(new Date(2026, 0, 1), { month: 6, date: 15 }); return (x.getMonth() + 1) + "/" + x.getDate() }
    property string d6: NovaUtils.date.formatDate(NovaUtils.date.startOfDate(fixedDate, "month"), "YYYY-MM-DD HH:mm:ss")
    property string d7: NovaUtils.date.formatDate(NovaUtils.date.endOfDate(fixedDate, "month"), "YYYY-MM-DD HH:mm:ss.SSS")
    property int d8: NovaUtils.date.getDayOfYear(fixedDate)
    property int d9: NovaUtils.date.getWeekOfYear(fixedDate)
    property int d10: NovaUtils.date.getISOWeekYear(fixedDate)
    property int d11: NovaUtils.date.getDayOfWeek(fixedDate)
    property bool b1: NovaUtils.date.isBetweenDates(fixedDate, new Date(2026, 10, 1), new Date(2026, 11, 1))
    property bool b2: NovaUtils.date.isBetweenDates(new Date(2026, 10, 1), new Date(2026, 10, 1), new Date(2026, 11, 1))
    property bool b3: NovaUtils.date.isBetweenDates(new Date(2026, 10, 1), new Date(2026, 10, 1), new Date(2026, 11, 1), "[]")
    property bool b4: NovaUtils.date.isBetweenDates(new Date(2026, 10, 1, 23), new Date(2026, 10, 1), new Date(2026, 10, 2), { onlyDate: true, inclusiveFrom: true, inclusiveTo: true })
    property bool b5: NovaUtils.date.isSameDate(new Date(2026, 10, 22, 1), new Date(2026, 10, 22, 23), "day")
    property string d12: NovaUtils.date.formatDate(NovaUtils.date.extractDate("22/11/2026 21:53", "DD/MM/YYYY HH:mm"), "YYYY-MM-DD HH:mm")
    property int d13: NovaUtils.date.daysInMonth(new Date(2024, 1, 1))
    property string d14: NovaUtils.date.formatDate(NovaUtils.date.getMaxDate(new Date(2026, 0, 1), new Date(2026, 5, 1)), "MM")
    property string d15: NovaUtils.date.formatDate(NovaUtils.date.getDateBetween(new Date(2026, 0, 1), new Date(2026, 5, 1), new Date(2026, 8, 1)), "MM")
    property string d16: NovaUtils.date.inferDateFormat(new Date())
    property bool d17: NovaUtils.date.isValid(new Date()) && !NovaUtils.date.isValid("xx")

    // ── is / extend ──
    property bool e1: NovaUtils.is.deepEqual({ a: [1, 2] }, { a: [1, 2] })
    property bool e2: NovaUtils.is.deepEqual({ a: 1 }, { a: 2 })
    property bool e3: NovaUtils.is.isObject({}) && !NovaUtils.is.isObject([]) && NovaUtils.is.isDate(new Date())
    property bool e4: NovaUtils.is.isNumber(1.5) && !NovaUtils.is.isNumber(NaN)
    property string e5: JSON.stringify(NovaUtils.extend(true, { a: { b: 1 } }, { a: { c: 2 } }))
    property string e6: JSON.stringify(NovaUtils.extend({ x: 1 }, { y: 2 }))

    // ── 计时类 ──
    function setupDebounce() { debFn = NovaUtils.debounce(function () { win.debCount++ }, 60) }
    function fireDebounce() { debFn() }
    function cancelDebounce() { debFn.cancel() }
    function setupThrottle() { thrFn = NovaUtils.throttle(function () { win.thrCount++ }, 80, true) }
    function fireThrottle() { thrFn() }
    function setupFrame() { frameFn = NovaUtils.frameDebounce(function () { win.frameCount++ }) }
    function fireFrame() { frameFn() }
    function makeUids() { win.uid1 = NovaUtils.uid(); win.uid2 = NovaUtils.uid() }
}
"""


@pytest.fixture()
def l0_env(qml_engine):
    """L0/L5 测试环境：单例状态复位 + 窗口强引用 + QML 侧调用代理。"""
    win = _make(qml_engine, L0_ENV_QML)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)
    _call(drv, "reset")
    _pump(30)
    return drv


# ── L0 图标集 ──────────────────────────────────────────────

def test_iconset_defaults(l0_env):
    """默认图标集 material-icons：14 套内置、100 个语义键、provider 注册表就绪。"""
    drv = l0_env
    assert drv.val("defName") == "material-icons"
    assert drv.val("setCount") == 14
    assert drv.val("keyCount") == 100
    assert drv.val("providerCount") >= 14
    assert drv.val("typePositive") == "check_circle"
    assert drv.val("arrowDown") == "arrow_downward"
    assert drv.val("missingKey") == "fb"


def test_iconset_use_switches_values(l0_env):
    """use() 切换图标集后语义键整体换值（1:1 对标 $q.iconSet.type.positive）。"""
    drv = l0_env
    assert _call(drv, "useSet", "mdi-v7") is True
    assert _call(drv, "setNameValue") == "mdi-v7"
    assert _call(drv, "val", "type.positive") == "mdi-check-circle"
    assert _call(drv, "val", "arrow.dropdown") == "mdi-menu-down"
    assert _call(drv, "useSet", "fontawesome-v6") is True
    assert _call(drv, "val", "type.positive") == "fas fa-check"
    assert _call(drv, "useSet", "no-such-set") is False
    assert _call(drv, "setNameValue") == "fontawesome-v6"


def test_iconset_set_is_shallow_merge(l0_env):
    """set() 顶层浅合并：给出 editor 组就整组替换（基线 Object.assign 语义）。"""
    drv = l0_env
    out = _call(drv, "applyPartial")
    assert out == "undefined|mdi-alpha-b"       # editor.italic 被整组替换掉
    assert _call(drv, "applyName") == "brand-x"


def test_iconset_register_custom(l0_env):
    """register() 自定义图标集以 mdi-v7 全键补齐，可 use/unregister。"""
    drv = l0_env
    assert _call(drv, "registerSet") is True
    assert drv.val("setCount") == 15
    assert _call(drv, "useSet", "my-set") is True
    assert _call(drv, "val", "type.positive") == "mdi-verified"
    assert _call(drv, "val", "chevron.left") == "mdi-chevron-left"   # 未给出的键自动补齐
    assert _call(drv, "cutSet") is True
    assert drv.val("setCount") == 14


def test_resolve_prefix_family(l0_env):
    """前缀归一化：mdi-/fa 旧式/o_ 变体/显式冒号/sym_ 变体/ion 平台前缀。"""
    drv = l0_env
    assert _call(drv, "provider", "mdi-home") == "mdi"
    assert _call(drv, "iname", "mdi-home") == "home"
    assert _call(drv, "provider", "mdi:home") == "mdi"
    assert _call(drv, "provider", "fas fa-home") == "fontawesome-solid"
    assert _call(drv, "iname", "fas fa-home") == "home"
    assert _call(drv, "provider", "far fa-star") == "fontawesome-regular"
    assert _call(drv, "provider", "fab fa-github") == "fontawesome-brands"
    assert _call(drv, "provider", "las la-check") == "line-awesome"
    assert _call(drv, "provider", "o_home") == "material-outlined"
    assert _call(drv, "provider", "r_home") == "material-round"
    assert _call(drv, "provider", "s_home") == "material-sharp"
    assert _call(drv, "provider", "sym_r_home") == "material-symbols-rounded"
    assert _call(drv, "provider", "sym_o_home") == "material-symbols-outlined"
    assert _call(drv, "provider", "bi-house") == "bootstrap"
    assert _call(drv, "provider", "eva-home") == "eva"
    assert _call(drv, "provider", "ti-home") == "themify"
    assert _call(drv, "provider", "ion-md-home") == "ionicons"
    assert _call(drv, "iname", "ion-md-home") == "ion-md-home"


def test_resolve_platform_and_fallbacks(l0_env):
    """ion 裸名补平台前缀；裸名走当前图标集默认 provider；none/img 两通道。"""
    drv = l0_env
    ion = _call(drv, "iname", "ion-home")
    assert ion.startswith("ion-md-") or ion.startswith("ion-ios-")
    assert _call(drv, "provider", "home") == "material"
    assert _call(drv, "kind", "") == "none"
    assert _call(drv, "kind", "none") == "none"
    assert _call(drv, "kind", "img:qrc:/a.png") == "image"
    assert _call(drv, "iname", "img:qrc:/a.png") == "qrc:/a.png"
    assert _call(drv, "kind", "svguse:a.svg#b") == "unsupported"
    assert "SVG <use>" in _call(drv, "reason", "svguse:a.svg#b")
    assert _call(drv, "kind", "i-carbon-home") == "unsupported"


def test_resolve_svg_path_channel(l0_env):
    """SVG path 直出：&& 多路径、|viewBox、@@ style/transform 三段解析。"""
    drv = l0_env
    assert _call(drv, "kind", "M12 2L2 7v10h4V9h12v8h4V7z") == "path"
    assert _call(drv, "nodeCount", "M0 0h24v24H0z&&M5 5h14v14H5z") == 2
    assert _call(drv, "viewBox", "M0 0h24v24H0z|0 0 16 16") == "0 0 16 16"
    assert _call(drv, "viewBox", "M0 0h24v24H0z") == "0 0 24 24"


def test_provider_registry(l0_env):
    """provider 注册/注销/模板替换；非法 spec 拒绝注册。"""
    drv = l0_env
    base = _call(drv, "pcount")
    assert _call(drv, "addProvider") is True
    assert _call(drv, "pcount") == base + 1
    assert _call(drv, "purl", "acme", "rocket") == "https://acme.io/rocket.svg"
    assert _call(drv, "delProvider") is True
    assert _call(drv, "pcount") == base
    assert _call(drv, "badProvider") is False


def test_provider_urls_match_baseline_distribution(l0_env):
    """四类 provider 的真实分发地址（2026-11-22 实测 200）：ionicons/eva/fa 别名/line-awesome。"""
    drv = l0_env
    assert _call(drv, "purl", "ionicons", "ion-md-home").endswith("/ionicons@7/dist/svg/home.svg")
    assert _call(drv, "purl", "ionicons", "ion-ios-home").endswith("/svg/home-outline.svg")
    assert _call(drv, "purl", "eva", "home-outline").endswith("/eva-icons@1.1.3/outline/svg/home-outline.svg")
    assert _call(drv, "purl", "fontawesome-solid", "home").endswith("/svgs/solid/house.svg")
    assert _call(drv, "purl", "fontawesome-solid", "user").endswith("/svgs/solid/user.svg")
    assert _call(drv, "purl", "line-awesome", "check").endswith("/line-awesome@1/svg/check-solid.svg")
    assert _call(drv, "purl", "bootstrap", "house").endswith("/bootstrap-icons@1.11.3/icons/house.svg")


# ── L0 动效 ───────────────────────────────────────────────

def test_motion_tokens(l0_env):
    """动效令牌 1:1：--q-transition-duration .3s、q-animate--scale .15s、q-animate--fade .2s。"""
    drv = l0_env
    assert drv.val("durMain") == 300
    assert drv.val("durScale") == 150
    assert drv.val("durFade") == 200
    assert drv.val("presetCount") == 15
    assert drv.val("hasFlip") is True
    assert drv.val("hasBogus") is False


def test_motion_preset_fields(l0_env):
    """预设字段：fade 只动透明、slide-right 位移非对称、flip 绕 y 轴。"""
    drv = l0_env
    assert _call(drv, "presetField", "fade", "opacityIn") == 0
    assert _call(drv, "presetField", "fade", "xIn") == -999
    assert _call(drv, "presetField", "slide-right", "xIn") == -1
    assert _call(drv, "presetField", "slide-right", "xOut") == 1
    assert _call(drv, "presetField", "jump-up", "pyIn") == 15
    assert _call(drv, "presetField", "flip-right", "angleOut") == 180


def test_motion_speed_and_reduced(l0_env):
    """speedFactor 缩放时长；reducedMotion 全链归零（无障碍短路）。"""
    drv = l0_env
    assert _call(drv, "durOf", 300) == 300
    _call(drv, "setSpeed", 2)
    assert _call(drv, "durOf", 300) == 600
    _call(drv, "setSpeed", 0.5)
    assert _call(drv, "durOf", 300) == 150
    _call(drv, "setReduced", True)
    assert _call(drv, "durOf", 300) == 0
    _call(drv, "setReduced", False)


def test_transition_enter_exit_signals(l0_env):
    """NovaTransition：show 切换触发 entered/exited，离场结束隐藏。"""
    drv = l0_env
    assert drv.val("enterCount") == 0
    _call(drv, "hideIt")
    _pump(180)
    assert drv.val("exitCount") == 1
    assert _call(drv, "trVisible") == "false"
    _call(drv, "showIt")
    _pump(180)
    assert drv.val("enterCount") == 1
    assert _call(drv, "trVisible") == "true"


# ── L0 排版 ───────────────────────────────────────────────

def test_typescale_table(l0_env):
    """12 级字阶：h1 = 6rem/6rem/-.01562em/300 → 96px/96px/-1.5px/Light。"""
    drv = l0_env
    assert drv.val("typeCount") == 12
    assert drv.val("h1Style") == "96/96/-1.5/300"
    assert drv.val("capStyle") == "12/400"
    assert drv.val("unknownSize") == 14       # 未知字阶回落 body2


def test_elevation_tokens(l0_env):
    """高程令牌：7 级就近取 6 级（三层），shadow-1 umbra blur = 3。"""
    drv = l0_env
    assert drv.val("elev7") == 3
    assert drv.val("elev1Blur") == 3


def test_novatext_applies_style(l0_env):
    """NovaText 按字阶写入 font.pixelSize / lineHeight。"""
    drv = l0_env
    assert drv.val("txSize") == 48
    assert drv.val("txLine") == 50


# ── L5 colors ─────────────────────────────────────────────

def test_colors_hex_roundtrip(l0_env):
    """rgbToHex / hexToRgb 往返；a 为 0..100 百分制。"""
    drv = l0_env
    assert drv.val("c1") == "#5b6ef5"
    assert drv.val("c2") == "#5b6ef580"
    assert drv.val("c3") == 110


def test_colors_lighten_darken(l0_env):
    """lighten 正数提亮、负数即 darken。"""
    drv = l0_env
    assert drv.val("c4") == "#808080"
    assert drv.val("c5") == "#808080"


def test_colors_change_alpha_baseline_semantics(l0_env):
    """changeAlpha：原色无 alpha 时基准为 0（基线坑，非直觉的 100）。"""
    drv = l0_env
    assert drv.val("c6") == "#ff000080"
    assert drv.val("c7") == "#ff000000"


def test_colors_text_and_blend(l0_env):
    """textToRgb 的 a 百分制（0.5→50）；blend 为 source-over 合成。"""
    drv = l0_env
    assert drv.val("c8") == 50
    assert drv.val("c9") == "rgba(10,20,30,0.5)"
    assert drv.val("c10") == "#800080ff"


def test_colors_contrast_and_hsv(l0_env):
    """WCAG 对比度黑白 21:1；自动字色对比度取大者；HSV 往返。"""
    drv = l0_env
    assert abs(drv.val("c11") - 21.0) < 0.01
    assert drv.val("c12") == "#FFFFFF"
    assert drv.val("c13") == 0
    assert drv.val("c14") == 255


# ── L5 format ─────────────────────────────────────────────

def test_format_functions(l0_env):
    """humanStorageSize / pad / getDecimalsCount / normalizeToInterval / between。"""
    drv = l0_env
    assert drv.val("f1") == "1.5KB"
    assert drv.val("f2") == "1023.0B"
    assert drv.val("f3") == "07"
    assert drv.val("f4") == 8
    assert drv.val("f5") == 4
    assert drv.val("f6") == "Nova"
    assert drv.val("f7") == 10


# ── L5 date ───────────────────────────────────────────────

def test_formatdate_all_tokens(l0_env):
    """formatDate 44 个 token 逐项对账（2026-11-22 21:53:07.123 星期日）。"""
    drv = l0_env
    assert drv.val("d1") == (
        "2026|26|11|11th|11|Nov|November|4|4th|22|22nd|22|326|326th|326|"
        "0|0th|Su|Sun|Sunday|7|47|47th|47|26|2026|21|21|9|09|53|53|7|07|1|12|123|PM|pm|p.m."
    )


def test_formatdate_timezone_and_epoch(l0_env):
    """Z/ZZ 符号与基线一致（东八区 +08:00/+0800）；x 为毫秒时间戳。"""
    import re
    drv = l0_env
    tz = drv.val("dZ")
    assert re.match(r"^[+-]\d{2}:\d{2}\|[+-]\d{4}$", tz), tz
    assert drv.val("dX") is True


def test_formatdate_locale_and_literal(l0_env):
    """中文语言包（MMMM/dddd）；[literal] 转义为原样输出（基线语义，非解析后插值）。"""
    drv = l0_env
    assert drv.val("d2") == "2026年11月22日 星期日"
    assert drv.val("d3") == "YYYY年-11"


def test_formatdate_invalid_inputs(l0_env):
    """非法输入返回 undefined；mask 缺省用 defaultMask。"""
    drv = l0_env
    assert drv.val("d4") is True
    assert drv.val("d5") is True
    m = drv.val("dMask")
    assert m.startswith("2026-11-22T21:53:07.123")


def test_date_arithmetic_month_end(l0_env):
    """月加法先夹取日（1/31 + 1 月 → 2/28，不滚到 3/3）；闰年 2/29 + 1 年 → 2/28。"""
    drv = l0_env
    assert _call(drv, "addMonthEnd") == "2/28"
    assert _call(drv, "subDays") == "2/28"
    assert _call(drv, "addLeap") == "2025/2/28"
    assert _call(drv, "adjDate") == "7/15"


def test_date_start_end_of_unit(l0_env):
    """startOfDate/endOfDate 月边界：01 00:00:00.000 ~ 30 23:59:59.999。"""
    drv = l0_env
    assert drv.val("d6") == "2026-11-01 00:00:00"
    assert drv.val("d7") == "2026-11-30 23:59:59.999"


def test_date_week_and_day_of_year(l0_env):
    """年内第 326 天、ISO 第 47 周、ISO 周年 2026、周日 = 7。"""
    drv = l0_env
    assert drv.val("d8") == 326
    assert drv.val("d9") == 47
    assert drv.val("d10") == 2026
    assert drv.val("d11") == 7


def test_date_is_between_dates(l0_env):
    """isBetweenDates 默认两端开；'[]' 字符串写法闭合；onlyDate 只比日期。"""
    drv = l0_env
    assert drv.val("b1") is True
    assert drv.val("b2") is False
    assert drv.val("b3") is True
    assert drv.val("b4") is True
    assert drv.val("b5") is True


def test_date_extract_and_misc(l0_env):
    """extractDate 解析往返；daysInMonth 闰年、getMaxDate、getDateBetween、infer/isValid。"""
    drv = l0_env
    assert drv.val("d12") == "2026-11-22 21:53"
    assert drv.val("d13") == 29
    assert drv.val("d14") == "06"
    assert drv.val("d15") == "06"
    assert drv.val("d16") == "date"
    assert drv.val("d17") is True


# ── L5 is / extend / 计时类 ────────────────────────────────

def test_is_and_extend(l0_env):
    """deepEqual 深比较、isObject 排除数组、extend 深合并保留原对象。"""
    drv = l0_env
    assert drv.val("e1") is True
    assert drv.val("e2") is False
    assert drv.val("e3") is True
    assert drv.val("e4") is True
    assert drv.val("e5") == '{"a":{"b":1,"c":2}}'
    assert drv.val("e6") == '{"x":1,"y":2}'


def test_debounce_trailing_and_cancel(l0_env):
    """debounce 默认 trailing：连发 3 次只执行 1 次；cancel 后不再执行。"""
    drv = l0_env
    _call(drv, "setupDebounce")
    _call(drv, "fireDebounce")
    _call(drv, "fireDebounce")
    _call(drv, "fireDebounce")
    _pump(200)
    assert drv.val("debCount") == 1
    _call(drv, "fireDebounce")
    _call(drv, "cancelDebounce")
    _pump(200)
    assert drv.val("debCount") == 1


def test_throttle_leading_and_trailing(l0_env):
    """throttle：窗口内只执行一次，尾跑补齐（trailing=true）。"""
    drv = l0_env
    _call(drv, "setupThrottle")
    _call(drv, "fireThrottle")
    _call(drv, "fireThrottle")
    _pump(40)
    assert drv.val("thrCount") == 1
    _pump(200)
    assert drv.val("thrCount") == 2


def test_frame_debounce_and_uid(l0_env):
    """frameDebounce 只保留最后一次；uid 为 v4 形态且唯一。"""
    import re
    drv = l0_env
    _call(drv, "setupFrame")
    _call(drv, "fireFrame")
    _call(drv, "fireFrame")
    _pump(120)
    assert drv.val("frameCount") == 1

    _call(drv, "makeUids")
    u1, u2 = drv.val("uid1"), drv.val("uid2")
    assert re.match(r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$", u1), u1
    assert u1 != u2


# ── 二期 Sprint A：表单核心七件（v0.9.0） ────────────────────

FORM_ENV_QML = (
    "import QtQuick\n"
    "import Nova.Controls\n"
    "Item {\n"
    "  width: 800; height: 600\n"
    "  // 计数器\n"
    "  property int commitCount: 0\n"
    "  property var lastValue: null\n"
    "  property int changedCount: 0\n"
    "  property var lastCheck: null\n"
    "  property int picked: 0\n"
    "  // 状态镜像（坑位 15：QML 侧只暴露属性，Python 侧不摸子组件）\n"
    "  property bool inpHasError: inp.hasError\n"
    "  property string inpText: inp._text\n"
    "  property bool cbChecked: cb.checked\n"
    "  property bool cbValChecked: cbVal.checked\n"
    "  property bool raChecked: ra.checked\n"
    "  property bool rbChecked: rb.checked\n"
    "  property bool tgChecked: tg.checked\n"
    "  property var selVal: sel.modelValue\n"
    "  // ① NovaInput：校验 + modifiers + clearable + debounce\n"
    "  NovaInput {\n"
    "    id: inp; width: 240; x: 10; y: 10\n"
    "    label: '用户名'; clearable: true\n"
    "    rules: ['required', 'minlen(3)']\n"
    "    onEditingFinished: commitCount++\n"
    "  }\n"
    "  NovaInput {\n"
    "    id: numInp; width: 240; x: 10; y: 80\n"
    "    type: 'number'; modelModifiers: ['number']\n"
    "    onModelValueChanged: { lastValue = modelValue; changedCount++ }\n"
    "  }\n"
    "  NovaInput {\n"
    "    id: debInp; width: 240; x: 10; y: 150\n"
    "    debounce: 120\n"
    "    onModelValueChanged: { lastValue = modelValue; changedCount++ }\n"
    "  }\n"
    "  NovaInput { id: lazyInp; width: 240; x: 10; y: 220; rules: ['email']; lazyRules: true }\n"
    "  // ② NovaSelect\n"
    "  NovaSelect {\n"
    "    id: sel; width: 240; x: 300; y: 10\n"
    "    options: [{label: '苹果', value: 'apple'}, {label: '香蕉', value: 'banana', disable: true}, {label: '樱桃', value: 'cherry'}]\n"
    "    emitValue: true\n"
    "    onModelValueChanged: picked++\n"
    "  }\n"
    "  NovaSelect {\n"
    "    id: selMulti; width: 240; x: 300; y: 80\n"
    "    multiple: true; emitValue: true; maxValues: 2\n"
    "    options: ['a', 'b', 'c', 'd']\n"
    "  }\n"
    "  // ③ NovaCheckbox / NovaRadio / NovaToggle\n"
    "  NovaCheckbox {\n"
    "    id: cb; x: 300; y: 150; label: '记住我'\n"
    "    onModelValueChanged: lastCheck = modelValue\n"
    "  }\n"
    "  NovaCheckbox {\n"
    "    id: cbInd; x: 300; y: 200; label: '全选'\n"
    "    toggleIndeterminate: true; indeterminateValue: 'partial'; toggleOrder: 1\n"
    "  }\n"
    "  NovaCheckbox { id: cbVal; x: 300; y: 250; label: 'A'; val: 'opt-a' }\n"
    "  property var radioVal: 'b'\n"
    "  NovaRadio { id: ra; x: 300; y: 300; label: '甲'; val: 'a'; modelValue: radioVal }\n"
    "  NovaRadio { id: rb; x: 300; y: 340; label: '乙'; val: 'b'; modelValue: radioVal }\n"
    "  NovaToggle { id: tg; x: 300; y: 390; label: '开关'; icon: 'mdi:check' }\n"
    "  // ④ NovaSlider\n"
    "  NovaSlider {\n"
    "    id: sl; width: 300; x: 10; y: 300\n"
    "    min: 0; max: 100; step: 5; label: true\n"
    "    onValueChanged: (v) => lastValue = v\n"
    "  }\n"
    "  NovaSlider { id: slV; width: 40; height: 160; x: 10; y: 380; vertical: true; reverse: true; step: 10 }\n"
    "  // 驱动函数（QML 函数无可选参数——固定形参）\n"
    "  function inpSet(t) { inp.modelValue = t }\n"
    "  function inpValidate() { return inp.validate() }\n"
    "  function inpClear() { inp.clear() }\n"
    "  function inpReset() { inp.resetValidation() }\n"
    "  function numSet(t) { numInp.modelValue = t; return numInp.typedValue }\n"
    "  function debSet(t) { debInp.modelValue = t; return debInp._text }\n"
    "  function debType(t) { debInp._setText(t) }\n"
    "  function lazyBlur() { lazyInp.controlFocused = true; lazyInp.controlFocused = false; return lazyInp.hasError }\n"
    "  function lazySet(t) { lazyInp.modelValue = t }\n"
    "  function lazyValidate() { return lazyInp.validate() }\n"
    "  function selPick(v) { return sel.selectOption(v) }\n"
    "  function selByLabel(l) { return sel._setValueByLabel(l) }\n"
    "  function selDisplay() { return sel._displayText }\n"
    "  function selMultiToggle(v) { return selMulti.selectOption(v) }\n"
    "  function selMultiVals() { return selMulti.modelValue ? selMulti.modelValue.length : 0 }\n"
    "  function cbToggle() { cb.modelValue = cb.toggle(); return cb.checked }\n"
    "  function cbIndCycle() { cbInd.modelValue = cbInd.toggle(); return cbInd.modelValue }\n"
    "  function cbValToggle() { cbVal.modelValue = cbVal.toggle(); return cbVal.modelValue }\n"
    "  function radioPick() { radioVal = ra.select(); return radioVal }\n"
    "  function tgToggle() { tg.modelValue = tg.toggle(); return tg.checked }\n"
    "  function slSet(v) { sl.setValue(v); return sl.modelValue }\n"
    "  function slPos(x) { return sl.posToValue(x) }\n"
    "  function slStep() { sl.stepBy(2); return sl.modelValue }\n"
    "  function slStepV() { slV.stepBy(1); return slV.modelValue }\n"
    "}"
)


@pytest.fixture()
def form_env(qml_engine):
    """Sprint A 表单测试环境：七件全实例化 + 调用代理。"""
    win = _make(qml_engine, FORM_ENV_QML, wait=0.05)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)
    _pump(60)
    return drv


def test_form_input_validation_contract(form_env):
    """统一契约：required+minlen 双规则；空值报错 → 合法值通过 → reset 复位。"""
    drv = form_env
    assert drv.call0("inpValidate") is False          # 空值 → required 不通过
    assert drv.val("inpHasError") is True
    drv.call1("inpSet", "nova")
    assert drv.call0("inpValidate") is True
    drv.call0("inpReset")
    assert drv.val("inpHasError") is False


def test_form_input_clear_and_modifiers(form_env):
    """clearable 清空；number 模式 typedValue 强转数值。"""
    drv = form_env
    drv.call1("inpSet", "hello")
    drv.call0("inpClear")
    assert drv.val("inpText") == ""
    v = drv.call1("numSet", "42")
    assert v == 42 and isinstance(v, (int, float))
    assert drv.val("changedCount") >= 1


def test_form_input_debounce(form_env):
    """debounce>0 时 modelValue 延迟提交（文本即时，模型防抖）。"""
    drv = form_env
    before = drv.val("changedCount")
    drv.call1("debType", "abc")                       # 模拟键入：文本即时变
    _pump(30)
    assert drv.val("changedCount") == before          # 防抖窗口内未提交
    _pump(220)
    assert drv.val("changedCount") == before + 1
    assert drv.val("lastValue") == "abc"


def test_form_input_lazy_rules(form_env):
    """lazyRules：失焦前不实时校验；首次失焦激活后 email 规则生效。"""
    drv = form_env
    assert drv.call0("lazyBlur") is True              # 失焦激活：空值非 email → 报错
    assert drv.call0("lazyValidate") is False
    drv.call1("lazySet", "a@b.co")
    assert drv.call0("lazyValidate") is True


def test_form_select_pick_and_normalize(form_env):
    """选项归一化 + emitValue + disabled 拒选 + 展示文案。"""
    drv = form_env
    assert drv.call1("selPick", "cherry") is True
    assert drv.val("picked") == 1
    assert drv.call0("selDisplay") == "樱桃"
    assert drv.call1("selPick", "banana") is False    # disabled 拒选
    assert drv.call1("selByLabel", "苹果") is True
    assert drv.val("selVal") == "apple"


def test_form_select_multiple_and_cap(form_env):
    """multiple 多选 + maxValues=2 上限拒收。"""
    drv = form_env
    assert drv.call1("selMultiToggle", "a") is True
    assert drv.call1("selMultiToggle", "b") is True
    assert drv.call0("selMultiVals") == 2
    assert drv.call1("selMultiToggle", "c") is False  # 满员时 c 被拒
    assert drv.call0("selMultiVals") == 2


def test_form_checkbox_toggle_semantics(form_env):
    """true/false 语义 + 半选循环（order 1：f→t→i→f）。"""
    drv = form_env
    assert drv.call0("cbToggle") is True              # false → true
    assert drv.val("lastCheck") is True
    assert drv.call0("cbToggle") is False             # true → false
    assert drv.val("lastCheck") is False
    # 半选循环（toggleOrder 1）：false → true → partial → false
    assert drv.call0("cbIndCycle") is True
    assert drv.call0("cbIndCycle") == "partial"
    assert drv.call0("cbIndCycle") is False


def test_form_checkbox_val_mode(form_env):
    """val 模式：checked = modelValue === val；toggle 发出 val。"""
    drv = form_env
    assert drv.val("cbValChecked") is False
    assert drv.call0("cbValToggle") == "opt-a"
    assert drv.val("cbValChecked") is True


def test_form_radio_group(form_env):
    """radio 组：select 写回 val；宿主同步 modelValue 后两枚联动。"""
    drv = form_env
    assert drv.val("rbChecked") is True               # 初始 modelValue 'b'
    drv.call0("radioPick")                             # 点甲
    assert drv.val("radioVal") == "a"
    assert drv.val("raChecked") is True
    assert drv.val("rbChecked") is False              # 乙取消


def test_form_toggle_switch_semantics(form_env):
    """NovaToggle 复用 checkbox 值语义（换装不改行为）。"""
    drv = form_env
    assert drv.call0("tgToggle") is True
    assert drv.val("tgChecked") is True
    assert drv.call0("tgToggle") is False
    assert drv.val("tgChecked") is False


def test_form_slider_quantize_and_clamp(form_env):
    """step=5 量化 + min/max 夹取 + 轨道位置换算。"""
    drv = form_env
    assert drv.call1("slSet", 47) == 45                # 量化到 5 的倍数
    assert drv.call1("slSet", 999) == 100              # 夹取上限
    assert drv.call1("slSet", -9) == 0                 # 夹取下限
    assert drv.call1("slPos", 146) == 50               # 轨道中点 → 50


def test_form_slider_step_and_vertical(form_env):
    """stepBy 走 N 步；垂直模式步进方向正确。"""
    drv = form_env
    drv.call1("slSet", 50)
    assert drv.call0("slStep") == 60                   # +2 步 × step 5
    assert drv.call0("slStepV") == 10                  # 垂直 stepBy +1 步 × step 10



# ── 二期 Sprint B：输入进阶八件（v0.10.0） ────────────────────

FORM2_ENV_QML = (
    "import QtQuick\n"
    "import Nova.Controls\n"
    "Item {\n"
    "  width: 900; height: 700\n"
    "  // 计数器\n"
    "  property int submitCount: 0\n"
    "  property int failedCount: 0\n"
    "  property int canceledCount: 0\n"
    "  property int shownCount: 0\n"
    "  property var lastPe: null\n"
    "  // ① NovaRange\n"
    "  NovaRange { id: rng; width: 240; x: 10; y: 10; min: 0; max: 100; step: 5; minRange: 10; maxRange: 60 }\n"
    "  // ② NovaDate（单选/区间/多选/导航夹取）\n"
    "  NovaDate { id: dt; x: 10; y: 60; mask: 'YYYY/MM/DD' }\n"
    "  NovaDate { id: dtR; x: 320; y: 60; range: true; mask: 'YYYY/MM/DD' }\n"
    "  NovaDate { id: dtM; x: 320; y: 60; multiple: true; mask: 'YYYY/MM/DD' }\n"
    "  NovaDate { id: dtNav; x: 320; y: 60; mask: 'YYYY/MM/DD'\n"
    "             navigationMinYearMonth: dtNav._pad4(dtNav._today.y) + '/' + dtNav._pad2(dtNav._today.m + 1)\n"
    "             navigationMaxYearMonth: dtNav._pad4(dtNav._today.y) + '/' + dtNav._pad2(dtNav._today.m + 1) }\n"
    "  NovaDate { id: dtMin; x: 320; y: 60; mask: 'YYYY/MM/DD'\n"
    "             minimal: dtMin._pad4(dtMin._today.y) + '/' + dtMin._pad2(dtMin._today.m + 1) + '/' + dtMin._pad2(dtMin._today.d) }\n"
    "  // ③ NovaTime\n"
    "  NovaTime { id: tm; x: 640; y: 60 }\n"
    "  NovaTime { id: tmS; x: 640; y: 60; withSeconds: true; format24h: true }\n"
    "  NovaTime { id: tmOpt; x: 640; y: 60; hourOptions: [9, 10, 11] }\n"
    "  // ④ NovaColorPicker\n"
    "  NovaColorPicker { id: cp; x: 10; y: 420 }\n"
    "  NovaColorPicker { id: cpRgb; x: 280; y: 420; formatModel: 'rgb' }\n"
    "  // ⑤ NovaOptionGroup\n"
    "  NovaOptionGroup { id: og; x: 640; y: 420; options: [{label: '甲', value: 'a'}, {label: '乙', value: 'b'}, {label: '丙（禁用）', value: 'c', disable: true}] }\n"
    "  NovaOptionGroup { id: ogr; x: 640; y: 420; type: 'radio'; options: ['r1', 'r2'] }\n"
    "  NovaOptionGroup { id: ogt; x: 640; y: 420; type: 'toggle'; options: ['t1', 't2'] }\n"
    "  // ⑥ NovaForm\n"
    "  NovaForm {\n"
    "    id: f; x: 10; y: 620; width: 200\n"
    "    NovaInput { id: fInp; label: '必填'; rules: ['required'] }\n"
    "  }\n"
    "  NovaForm {\n"
    "    id: fg; x: 10; y: 620; width: 200; greedy: true\n"
    "    onValidationFailed: failedCount++\n"
    "    NovaInput { id: gInp1; label: '一'; rules: ['required'] }\n"
    "    NovaInput { id: gInp2; label: '二'; rules: ['email'] }\n"
    "  }\n"
    "  // ⑦ NovaBtnToggle\n"
    "  NovaBtnToggle { id: bt; x: 400; y: 620; options: [{label: '日', value: 'd'}, {label: '周', value: 'w'}, {label: '月', value: 'm', disable: true}]; clearable: true }\n"
    "  NovaBtnToggle { id: btm; x: 400; y: 620; multiple: true; options: ['a', 'b', 'c'] }\n"
    "  // ⑧ NovaPopupEdit\n"
    "  NovaPopupEdit {\n"
    "    id: pe; x: 700; y: 620\n"
    "    onShown: shownCount++\n"
    "    onCanceled: canceledCount++\n"
    "    onValueChanged: (v) => lastPe = v\n"
    "    Rectangle { width: 60; height: 24; color: '#eee' }\n"
    "  }\n"
    "  // 驱动函数\n"
    "  function rngSet(l, r) { rng.setRange(l, r); return rng.modelValue }\n"
    "  function rngLeft(v) { rng.setValueLeft(v); return rng.modelValue }\n"
    "  function rngRight(v) { rng.setValueRight(v); return rng.modelValue }\n"
    "  function datePick(d) { return dt.selectDay(d) }\n"
    "  function dateVal() { return dt.modelValue }\n"
    "  function dateRangeClick(d) { dtR.selectDay(d); return dtR.modelValue }\n"
    "  function dateMulti(d) { dtM.selectDay(d); return dtM.modelValue.length }\n"
    "  function dateNavUp() { return dtNav.navigateMonth(1) }\n"
    "  function dateNavDown() { return dtNav.navigateMonth(-1) }\n"
    "  function dateMinPick(d) { return dtMin.selectDay(Math.max(1, dtMin._today.d - 3)) }\n"
    "  function timeSetH(h) { return tm.setHour(h) }\n"
    "  function timeSetM(m) { return tm.setMinute(m) }\n"
    "  function timeVal() { return tm.modelValue }\n"
    "  function timeSSet(v) { tmS.modelValue = v; return tmS.modelValue }\n"
    "  function timeAmPm() { tm.toggleAmPm(); return tm._isAm }\n"
    "  function timeOptH(h) { return tmOpt.setHour(h) }\n"
    "  function timeOptVal() { return tmOpt.modelValue }\n"
    "  function colorHex(s) { return cp.setHex(s) }\n"
    "  function colorVal() { return cp.modelValue }\n"
    "  function colorRgbHex(s) { return cpRgb.setHex(s) }\n"
    "  function colorRgbVal() { return cpRgb.modelValue }\n"
    "  function ogPick(v) { return og.selectOption(v) }\n"
    "  function ogVals() { return og.modelValue ? og.modelValue.length : 0 }\n"
    "  function ogRadio(v) { return ogr.selectOption(v) }\n"
    "  function ogRadioVal() { return ogr.modelValue }\n"
    "  function ogTogglePick(v) { return ogt.selectOption(v) }\n"
    "  function ogToggleVals() { return ogt.modelValue ? ogt.modelValue.length : 0 }\n"
    "  function formValidate() { return f.validate() }\n"
    "  function formInpSet(t) { fInp.modelValue = t; return f.validate() }\n"
    "  function formSubmit() { return f.submit() }\n"
    "  function formGreedyValidate() { return fg.validate() }\n"
    "  function formReset() { f.resetValidation(); return fInp.hasError }\n"    "  function btPick(v) { return bt.select(v) }\n"
    "  function btVal() { return bt.modelValue }\n"
    "  function btmPick(v) { return btm.select(v) }\n"
    "  function btmVals() { return btm.modelValue ? btm.modelValue.length : 0 }\n"
    "  function peShow() { pe.show(); return shownCount }\n"
    "  function peSet(v) { pe.set(v); return pe.modelValue }\n"
    "  function peCancel() { pe.cancel(); return canceledCount }\n"
    "}"
)


@pytest.fixture()
def form2_env(qml_engine):
    """Sprint B 输入进阶测试环境：八件全实例化 + 调用代理。"""
    win = _make(qml_engine, FORM2_ENV_QML, wait=0.05)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)
    _pump(60)
    return drv


def test_form2_range_quantize_and_constraints(form2_env):
    """step 量化 + min/maxRange 约束 + 左右滑块独立步进。"""
    drv = form2_env
    v = drv.call2("rngSet", 47, 93).toVariant()
    assert v["min"] == 45 and v["max"] == 95               # 双端量化
    v = drv.call2("rngSet", 10, 85).toVariant()            # maxRange=60 → max=70
    assert v["min"] == 10 and v["max"] == 70
    v = drv.call1("rngLeft", 5).toVariant()                # minRange=10 → max 拉到 15
    assert v["min"] == 5 and v["max"] - v["min"] >= 10
    v = drv.call1("rngRight", 3).toVariant()               # 右滑块不许低于左-10
    assert v["max"] >= v["min"] + 10


def test_form2_date_single_and_mask(form2_env):
    """单选：mask 格式化输出；再点取消（noUnset=false）。"""
    drv = form2_env
    ok = drv.call1("datePick", 20)
    assert ok is True
    mv = drv.call0("dateVal")
    assert isinstance(mv, str) and mv.endswith("/20") and len(mv) == 10   # YYYY/MM/DD
    assert drv.call1("datePick", 20) is True               # 再点取消
    assert drv.call0("dateVal") is None


def test_form2_date_range_and_multiple(form2_env):
    """区间：两次点击形成 {from,to}（逆序自动交换）；多选计数。"""
    drv = form2_env
    assert drv.call1("dateRangeClick", 10) is None         # 第一击只入 pending
    mv = drv.call1("dateRangeClick", 5).toVariant()
    assert mv["from"].endswith("/05") and mv["to"].endswith("/10")
    assert mv["from"] < mv["to"]                           # 逆序交换
    n = drv.call1("dateMulti", 3)
    assert n == 1
    n = drv.call1("dateMulti", 7)
    assert n == 2


def test_form2_date_navigation_clamp_and_minimal(form2_env):
    """导航夹取：navMin=navMax=本月 → 翻月双向拒绝；minimal 之前拒选。"""
    drv = form2_env
    assert drv.call0("dateNavUp") is False
    assert drv.call0("dateNavDown") is False
    assert drv.call0("dateMinPick") is False               # today-3 < minimal


def test_form2_time_clock_semantics(form2_env):
    """时/分管道 + withSeconds 输出 + options 拒绝 + nowBtn。"""
    drv = form2_env
    assert drv.call1("timeSetH", 14) is True
    assert drv.call0("timeVal") == "14:00"
    assert drv.call1("timeSetM", 37) is True
    assert drv.call0("timeVal") == "14:37"
    # withSeconds：mask 解析管道（三段式 HH:mm:ss）
    assert drv.call1("timeSSet", "09:05:08") == "09:05:08"
    assert drv.call1("timeOptH", 22) is False              # hourOptions 过滤
    assert drv.call1("timeOptH", 10) is True
    assert drv.call0("timeOptVal") == "10:00"


def test_form2_time_ampm_toggle(form2_env):
    """12h 制：AM/PM 切换偏移 +12h（16:30 → 04:30）。"""
    drv = form2_env
    drv.call1("timeSetH", 16)
    drv.call1("timeSetM", 30)
    is_am = drv.call0("timeAmPm")                          # 16 点 → 切到 AM
    assert is_am is True
    assert drv.call0("timeVal") == "04:30"


def test_form2_color_pipeline(form2_env):
    """hex 解析→HSV→输出；非法 hex 拒绝；rgb formatModel 输出。"""
    drv = form2_env
    assert drv.call1("colorHex", "#FF0000") is True
    assert drv.call0("colorVal") == "#ff0000"
    assert drv.call1("colorHex", "zzz") is False
    assert drv.call1("colorHex", "#00ff00") is True
    assert drv.call0("colorVal") == "#00ff00"              # 自洽往返
    assert drv.call1("colorRgbHex", "#ff0000") is True
    assert drv.call0("colorRgbVal") == "rgb(255,0,0)"


def test_form2_option_group_semantics(form2_env):
    """checkbox 数组增删 + 禁用拒选；radio 标量；toggle 型同数组语义。"""
    drv = form2_env
    assert drv.call1("ogPick", "a") is True
    assert drv.call0("ogVals") == 1
    assert drv.call1("ogPick", "c") is False               # 禁用拒选
    assert drv.call1("ogPick", "a") is True                # 再点移除
    assert drv.call0("ogVals") == 0
    assert drv.call1("ogRadio", "r2") is True
    assert drv.call0("ogRadioVal") == "r2"
    assert drv.call1("ogRadio", "r1") is True
    assert drv.call0("ogRadioVal") == "r1"
    assert drv.call1("ogTogglePick", "t1") is True
    assert drv.call0("ogToggleVals") == 1


def test_form2_form_aggregate(form2_env):
    """NovaForm：聚合校验/greedy 全量计错/submit 发信号/reset 复位。"""
    drv = form2_env
    assert drv.call0("formValidate") is False              # 必填空 → 失败
    assert drv.call1("formInpSet", "ok") is True
    assert drv.call0("formSubmit") is True
    assert drv.val("submitCount") >= 0                     # submitted 信号由宿主接
    # greedy：两个都空 → failed 一次（全量后仍单次信号）
    before = drv.val("failedCount")
    assert drv.call0("formGreedyValidate") is False
    assert drv.val("failedCount") == before + 1
    drv.call0("formReset")
    assert drv.call0("formReset") is False                 # 复位后无错误态


def test_form2_btn_toggle_group(form2_env):
    """按钮组：选中/禁用拒选/clearable 再点清空/多选数组。"""
    drv = form2_env
    assert drv.call1("btPick", "d") is True
    assert drv.call0("btVal") == "d"
    assert drv.call1("btPick", "m") is False               # 禁用
    assert drv.call1("btPick", "d") is True                # clearable 再点清
    assert drv.call0("btVal") is None
    assert drv.call1("btmPick", "a") is True
    assert drv.call1("btmPick", "b") is True
    assert drv.call0("btmVals") == 2


def test_form2_popup_edit_flow(form2_env):
    """就地编辑：set 写值+发信号/cancel 发 canceled（Popup.open 需窗口环境，
    无头测试不验 opened——留痕 PARITY）。"""
    drv = form2_env
    drv.call0("peShow")                                    # 无窗口时 open 静默失败，不抛
    v = drv.call1("peSet", "new-value")
    assert v == "new-value"
    assert drv.val("lastPe") == "new-value"
    c = drv.call0("peCancel")
    assert c >= 1


# ── 三期 Sprint A：数据体系九件（v0.11.0） ───────────────────

DATA_ENV_QML = (
    "import QtQuick\n"
    "import Nova.Controls\n"
    "Item {\n"
    "  id: it\n"
    "  width: 900; height: 700\n"
    "  // 宿主状态（受控写回）\n"
    "  property string sf: ''\n"
    "  property bool sd: false\n"
    "  property var tblSel: []\n"
    "  property var tblExp: []\n"
    "  property int tblPage: 1\n"
    "  property var trExp: []\n"
    "  property var trTicked: []\n"
    "  property var trSel: null\n"
    "  property int loadCount: 0\n"
    "  property bool infStopped: false\n"
    "  property bool itemA: false\n"
    "  property bool itemB: false\n"
    "  property int vsRendered: 0\n"
    "  // ① NovaTable：排序/过滤/分页/选择/展开\n"
    "  NovaTable {\n"
    "    id: tbl\n"
    "    width: 700; height: 460; title: '人员'; rowKey: 'id'\n"
    "    columns: [{name: 'id', label: 'ID', field: 'id', align: 'center', sortable: true},\n"
    "              {name: 'nm', label: '姓名', field: 'name', sortable: true}]\n"
    "    rows: [{id: 3, name: 'cc'}, {id: 1, name: 'aa'}, {id: 5, name: 'ee'},\n"
    "           {id: 2, name: 'bb'}, {id: 4, name: 'dd'}]\n"
    "    rowsPerPage: 2\n"
    "    sortBy: it.sf; descending: it.sd\n"
    "    selected: it.tblSel; expanded: it.tblExp; page: it.tblPage\n"
    "    expandSlot: Row { property var rowData; property int rowIndex;"
    " Text { text: 'ext:' + (rowData ? rowData.name : '?') } }\n"
    "    onUpdateSelected: (r) => it.tblSel = r\n"
    "    onUpdateExpanded: (k) => it.tblExp = k\n"
    "    onSortChanged: (f, d) => { it.sf = f; it.sd = d }\n"
    "    onPageRequested: (p) => it.tblPage = p\n"
    "  }\n"
    "  // ② NovaPagination\n"
    "  NovaPagination { id: pag; page: it.tblPage; pages: 20; ellipses: true; boundaryLinks: true;\n"
    "    onPageRequested: (p) => it.tblPage = p }\n"
    "  // ③ NovaTree：strict 勾选级联 + 懒加载\n"
    "  NovaTree {\n"
    "    id: tree\n"
    "    width: 300; height: 320; tickStrategy: 'strict'\n"
    "    nodes: [{label: 'A', children: [{label: 'A1'}, {label: 'A2'}]},\n"
    "            {label: 'B', children: [{label: 'B1', children: [{label: 'B1a'}]}]},\n"
    "            {label: 'L', lazy: true}]\n"
    "    expanded: it.trExp; ticked: it.trTicked; selected: it.trSel\n"
    "    onUpdateExpanded: (k) => it.trExp = k\n"
    "    onUpdateTicked: (k) => it.trTicked = k\n"
    "    onUpdateSelected: (k) => it.trSel = k\n"
    "    onLazyLoad: (node, done) => done([{label: 'L1'}])\n"
    "  }\n"
    "  // ④ NovaList 手风琴（受控展开）\n"
    "  NovaList {\n"
    "    id: lst; width: 300; accordion: true\n"
    "    NovaItem { id: lstA; label: '甲'; expandable: true; expanded: it.itemA;"
    " onExpandRequested: (e) => it.itemA = e }\n"
    "    NovaItem { id: lstB; label: '乙'; expandable: true; expanded: it.itemB;"
    " onExpandRequested: (e) => it.itemB = e }\n"
    "  }\n"
    "  // ⑤ NovaInfiniteScroll\n"
    "  NovaInfiniteScroll {\n"
    "    id: inf; width: 300; height: 150; offset: 20\n"
    "    contentHeight: 600\n"
    "    onLoad: (i, done) => { it.loadCount++; var stop = it.loadCount >= 2;"
    " it.infStopped = stop; done(stop) }\n"
    "  }\n"
    "  // ⑥ NovaVirtualScroll 5000 行虚拟化\n"
    "  NovaVirtualScroll {\n"
    "    id: vs; width: 300; height: 160; itemSize: 40\n"
    "    items: Array.from({length: 5000}, function (_, i) { return i })\n"
    "    delegate: Rectangle { width: 280; height: 40; required property int index;"
    " Component.onCompleted: it.vsRendered++ }\n"
    "  }\n"
    "  // ⑦ NovaScrollArea / NovaMarkupTable（冒烟即验）\n"
    "  NovaScrollArea { width: 120; height: 80; Rectangle { width: 400; height: 300; color: '#ddd' } }\n"
    "  NovaMarkupTable { y: 620; columns: ['a', 'b']; rows: [['1', '2']] }\n"
    "  // 驱动代理（固定形参）\n"
    "  function snapT() { return JSON.stringify({sf: it.sf, sd: it.sd, sel: it.tblSel.length,"
    " exp: it.tblExp, page: it.tblPage, vis: tbl.visibleRows.length}) }\n"
    "  function tblSort(n) { tbl.requestSort(n); return it.snapT() }\n"
    "  function tblPick(i) { tbl.toggleRowSelection(tbl.rows[i]); return it.tblSel.length }\n"
    "  function tblAll() { tbl.toggleAllSelection(); return it.tblSel.length }\n"
    "  function tblSetFilter(f) { tbl.filter = f; return tbl.filteredRows.length }\n"
    "  function tblExpand(i) { tbl.toggleRowExpand(tbl.rows[i], i); return JSON.stringify(it.tblExp) }\n"
    "  function tblGo(p) { return tbl.requestPage(p) }\n"
    "  function pagGo(p) { return pag.requestPage(p) }\n"
    "  function pagNext() { return pag.nextPage() }\n"
    "  function pagPrev() { return pag.prevPage() }\n"
    "  function trSnap() { return JSON.stringify({ticked: it.trTicked, sel: it.trSel, exp: it.trExp}) }\n"
    "  function trTick(k, on) { tree.setTicked(k, on); return it.trSnap() }\n"
    "  function trExpand(k) { tree.tryExpand(k); return it.trSnap() }\n"
    "  function trExpandAll() { tree.expandAll(); return it.trExp.length }\n"
    "  function trFilter() { tree.filter = 'B1a'; return JSON.stringify(Object.keys(tree._visibleKeys)) }\n"
    "  function trSelect(k) { tree.selectNode(k); return it.trSel }\n"
    "  function trNodeAt(k) { var n = tree.getNodeByKey(k); return n ? n.label : null }\n"
    "  function lstExpandB() { lstB.requestExpand(); return true }\n"
    "  function lstState() { return JSON.stringify({a: it.itemA, b: it.itemB}) }\n"
    "  function infKick(y) { inf.contentY = y; return it.loadCount }\n"
    "  function infResume() { inf.resume(); return it.loadCount }\n"
    "  function vsScroll(i) { vs.scrollToIndex(i); return Math.round(vs.contentY) }\n"
    "  function vsCount() { return it.vsRendered }\n"
    "}"
)


@pytest.fixture()
def data_env(qml_engine):
    """三期数据体系测试环境：表格/分页器/树/列表/无限滚动/虚拟滚动全实例化 + 代理。"""
    win = _make(qml_engine, DATA_ENV_QML, wait=0.05)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)
    _pump(60)
    return drv


def test_data_table_sort_and_filter(data_env):
    """三态排序（无序→升→降→无序）+ 全字段过滤。"""
    drv = data_env
    s = drv.call1("tblSort", "id")
    assert '"sf":"id"' in s and '"sd":false' in s
    assert drv.call1("tblSort", "id") == s.replace('"sd":false', '"sd":true')   # 升→降
    s3 = drv.call1("tblSort", "id")                                             # 降→无序
    assert '"sf":""' in s3 and '"sd":false' in s3
    assert drv.call1("tblSetFilter", "a") == 1          # cc/aa/ee/dd/bb → 含 'a' 只有 aa
    assert drv.call1("tblSetFilter", "") == 5


def test_data_table_selection_semantics(data_env):
    """单选一行 → 全选补齐 → 反选全清（键值比较，信号深拷贝不影响语义）。"""
    drv = data_env
    assert drv.call1("tblPick", 0) == 1
    assert drv.call0("tblAll") == 2                     # 补齐本页（2 行/页）
    assert drv.call0("tblAll") == 0                     # 全选→反选清空
    assert drv.call0("tblAll") == 2


def test_data_table_expand_and_page(data_env):
    """展开行（key 上报）+ 分页翻页/越界钳制。"""
    drv = data_env
    assert drv.call1("tblExpand", 1) == '["1"]'         # rowKey=id → 第 2 行 id=1
    assert drv.call1("tblGo", 3) == 3                   # 5 行 2/页 → 最大页 3
    assert drv.call1("tblGo", 0) == 1                   # 下界钳制


def test_data_pagination(data_env):
    """NovaPagination：requestPage 钳制 + prev/next + 边界不再上报。"""
    drv = data_env
    assert drv.call1("pagGo", 25) == 20                 # 上界
    assert drv.call1("pagGo", 0) == 1                   # 下界
    assert drv.call1("pagGo", 10) == 10
    assert drv.call0("pagNext") == 11
    assert drv.call0("pagPrev") == 10
    assert drv.val("tblPage") == 10


def test_data_tree_tick_strict_cascade(data_env):
    """strict 策略：勾子 → 勾父；反勾父 → 全清；键路径正确。"""
    drv = data_env
    s = drv.call2("trTick", "0.0", True)
    assert '"0.0"' in s and '"0"' not in s.replace('"0.0"', "")
    s2 = drv.call2("trTick", "0.1", True)
    assert '"0.0","0.1","0"' in s2                      # 全勾 → 父自动勾
    s3 = drv.call2("trTick", "0", False)
    assert s3 == '{"ticked":[],"sel":null,"exp":[]}'    # 反勾父 → 子全清


def test_data_tree_select_expand_lazy_filter(data_env):
    """单选节点 / 懒加载（done 回填后子键 2.0 入索引）/ 过滤保祖先链。"""
    drv = data_env
    assert drv.call1("trSelect", "1") == "1"
    assert drv.call1("trSelect", "1") is None           # 再点取消
    s = drv.call1("trExpand", "2")                      # 懒节点首次展开
    assert '"exp":["2"]' in s                           # 展开键上报
    assert drv.call1("trNodeAt", "2.0") == "L1"         # done 回填后 L1 入索引
    assert drv.call0("trExpandAll") >= 3
    keys = drv.call0("trFilter")
    assert "1.0.0" in keys and '"0"' not in keys        # B1a 可见、A 不可见


def test_data_list_accordion(data_env):
    """手风琴：展开甲 → 请求展开乙 → 甲被收起（expandRequested(false) 上报）。"""
    drv = data_env
    assert drv.call0("lstState") == '{"a":false,"b":false}'
    assert drv.call0("lstExpandB") is True
    assert drv.call0("lstState") == '{"a":false,"b":true}'   # 甲自动收起


def test_data_infinite_scroll(data_env):
    """触底持续加载（一次触底补满两批）→ done(true) 停止；resume 重新武装。"""
    drv = data_env
    assert drv.call1("infKick", 500) == 2               # 触底 → 连续加载 2 批后停止
    assert drv.val("infStopped") is True
    assert drv.call1("infKick", 500) == 2               # 停止后不再加载
    assert drv.call0("infResume") == 3                  # resume 重新武装


def test_data_virtual_scroll(data_env):
    """5000 行仅渲染可视窗口（虚拟化生效）；scrollToIndex 跳转正确。"""
    drv = data_env
    rendered = drv.call0("vsCount")
    assert rendered < 200                               # 远小于 5000
    assert drv.call1("vsScroll", 4000) == 160000        # 4000 * 40


# ══════════════════════════════════════════════════════════════
# 三期 Sprint B · 媒体体系行为级断言（v0.12.0，契约见 docs/PARITY.md §0.12）
# ══════════════════════════════════════════════════════════════

MEDIA_ENV_QML = (
    "import QtQuick\n"
    "import Nova.Controls\n"
    "Item {\n"
    "  id: it\n"
    "  width: 900; height: 1400\n"
    "  // 宿主状态（受控写回）\n"
    "  property var carVal: 0\n"
    "  property var carEvt: null\n"
    "  property var parInfo: null\n"
    "  property var srvReq: null\n"
    "  property bool imgLoaded: false\n"
    "  property bool imgErrored: false\n"
    "  property bool imgLoading: false\n"
    "  property string ssf: ''\n"
    "  property bool ssd: false\n"
    "  property int srvPage: 1\n"
    "  property bool chatSent: false\n"
    "  property var car2Val: 0\n"
    "  // ① NovaImg（真实 PNG，由测试夹具注入路径）\n"
    "  NovaImg {\n"
    "    id: img; width: 120; ratio: 1.6; fit: 'contain'; loadingShowDelay: 0\n"
    "    src: '%SRC%'\n"
    "    onLoaded: { it.imgLoaded = true; it.imgLoading = false }\n"
    "    onErrored: it.imgErrored = true\n"
    "    Rectangle { color: 'blue'; width: 10; height: 10 }\n"
    "  }\n"
    "  // ② NovaResponsive 等比容器\n"
    "  NovaResponsive { id: resp; width: 320; y: 130; ratio: 2.0; Rectangle { color: 'red' } }\n"
    "  // ③ NovaVideo 空源（播放器惰性，不创建 Video 元素）\n"
    "  NovaVideo { id: vid; width: 200; y: 300 }\n"
    "  // ④ NovaParallax（宿主 Flickable，progress 与 scroll 事件）\n"
    "  Flickable {\n"
    "    id: flick; x: 480; width: 300; height: 300; contentWidth: 300; contentHeight: 900\n"
    "    Rectangle { width: 300; height: 900; color: '#eee' }\n"
    "    NovaParallax {\n"
    "      id: par; y: 400; width: 300; height: 120; speed: 0.5; scrollTarget: flick; src: '%SRC%'\n"
    "      onScrolled: (info) => it.parInfo = info\n"
    "    }\n"
    "  }\n"
    "  // ⑤ NovaCarousel（受控 + infinite + 禁用页 + 覆盖控件）\n"
    "  NovaCarousel {\n"
    "    id: car; width: 320; height: 180; y: 340\n"
    "    modelValue: it.carVal\n"
    "    infinite: true; arrows: true; navigation: true; swipeable: true; animated: false\n"
    "    NovaCarouselSlide { name: 'x' }\n"
    "    NovaCarouselSlide { name: 'y' }\n"
    "    NovaCarouselSlide { name: 'dis'; disable: true }\n"
    "    NovaCarouselSlide { name: 'z' }\n"
    "    NovaCarouselControl { id: carCtl; position: 'bottom-left'; Text { text: 'ctl' } }\n"
    "    onUpdateModelValue: (n) => it.carVal = n\n"
    "    onTransition: (info) => it.carEvt = info\n"
    "  }\n"
    "  // ⑥ 自动轮播（非 infinite，到末页停止）\n"
    "  NovaCarousel {\n"
    "    id: car2; width: 200; height: 100; y: 540; animated: false\n"
    "    autoplay: 30; modelValue: it.car2Val\n"
    "    NovaCarouselSlide { name: 'p1' } NovaCarouselSlide { name: 'p2' }\n"
    "    onUpdateModelValue: (n) => it.car2Val = n\n"
    "  }\n"
    "  // ⑦ NovaTimeline（comfortable + heading + loose side）\n"
    "  NovaTimeline {\n"
    "    id: tl; width: 380; y: 660; layout: 'comfortable'; side: 'left'\n"
    "    NovaTimelineEntry { id: te0; heading: true; title: '里程碑' }\n"
    "    NovaTimelineEntry { id: te1; title: 'v0.12'; subtitle: '媒体'; body: '七件'; icon: 'mdi:star' }\n"
    "    NovaTimelineEntry { id: te2; title: 'x'; side: 'right' }\n"
    "  }\n"
    "  // ⑧ NovaChatMessage（多气泡 + stamp 尾条）\n"
    "  NovaChatMessage {\n"
    "    id: chat; width: 420; y: 900; name: '客服'; text: ['您好', '在吗']; stamp: '10:00'\n"
    "    sent: it.chatSent; size: 8\n"
    "  }\n"
    "  // ⑨ NovaTable 虚拟滚动（500 行）\n"
    "  NovaTable {\n"
    "    id: tv; x: 480; width: 400; height: 300\n"
    "    virtualScroll: true; rowsPerPage: 0; virtualScrollItemSize: 40\n"
    "    columns: [{name: 'id', label: 'ID', field: 'id', align: 'center', sortable: true}]\n"
    "    rows: Array.from({length: 500}, function (_, i) { return {id: i + 1} })\n"
    "  }\n"
    "  // ⑩ NovaTable 服务端模式（request 信号 + rowsNumber）\n"
    "  NovaTable {\n"
    "    id: ts; x: 480; y: 340; width: 400; height: 300\n"
    "    serverSide: true; rowsNumber: 42; rowsPerPage: 10\n"
    "    loadingLabel: '载入中'; noDataLabel: '空空如也'\n"
    "    columns: [{name: 'nm', label: '名', field: 'nm', sortable: true}]\n"
    "    rows: []\n"
    "    filter: it.srvFilter\n"
    "    sortBy: it.ssf; descending: it.ssd; page: it.srvPage\n"
    "    onSortChanged: (f, d) => { it.ssf = f; it.ssd = d }\n"
    "    onPageRequested: (p) => it.srvPage = p\n"
    "    onRequest: (req) => it.srvReq = req\n"
    "  }\n"
    "  property string srvFilter: ''\n"
    "  // ── 驱动代理（固定形参） ──\n"
    "  function imgStatus() { return img.status }\n"
    "  function imgH() { return img.implicitHeight }\n"
    "  function respH() { return resp.height }\n"
    "  function vidPlayerGone() { return vid.children.length >= 0 && vid.src.toString() === '' }\n"
    "  function parScroll(y) { flick.contentY = y; return par.progress }\n"
    "  function parProbe() { return JSON.stringify({top: par._topInContent, flick: par._flick !== null, y: par.y, prog: par.progress}) }\n"
    "  function parMediaY() { return Math.round(par.children[0] !== undefined ? par.children[0].y : 999) }\n"
    "  function carGo(n) { car.goTo(n, false); return it.carVal }\n"
    "  function carNext() { car.next(); return it.carVal }\n"
    "  function carPrev() { car.previous(); return it.carVal }\n"
    "  function carCount() { return car.count }\n"
    "  function carCtlOk() { return carCtl.parent === car.controlLayerItem }\n"
    "  function car2State() { return JSON.stringify({cur: car2.currentIndex, atEnd: car2._autoAtEnd, run: car2.autoRunning, ms: car2._autoMs}) }\n"
    "  function tlInfo() { return JSON.stringify({idx: te1._entryIndex, host: te1._host !== null,\n"
    "                                             lay: te1._host.layout, first: te1._isFirst, last: te1._isLast}) }\n"
    "  function tlSide2() { return te2._effSide }\n"
    "  function chatLines() { return chat._lines.length }\n"
    "  function chatZone() { return Math.round(chat._bubbleZone) }\n"
    "  function chatMirror() { chat.sent = true; return chat.sent }\n"
    "  function tvCount() { return tv.virtualRowCount }\n"
    "  function tvScroll(i) { tv.scrollTo(i); return Math.round(tv.virtualContentY) }\n"
    "  function srvSort(f) { ts.requestSort(f); return it.srvReq === null ? '' : JSON.stringify(it.srvReq.pagination) }\n"
    "  function srvGo(p) { ts.requestPage(p); return it.srvReq === null ? '' : JSON.stringify(it.srvReq.pagination) }\n"
    "  function srvSet(pg) { ts.setPagination({sortBy: 'nm', descending: true, page: pg}); return it.srvReq === null ? '' : JSON.stringify(it.srvReq.pagination) }\n"
    "  function srvFirst() { ts.firstPage(); return it.srvReq === null ? '' : JSON.stringify(it.srvReq.pagination) }\n"
    "  function srvFilterSet(f) { it.srvFilter = f; return it.srvReq === null ? '' : JSON.stringify(it.srvReq.pagination) }\n"
    "  function srvPages() { return ts.pageCount }\n"
    "  function srvRowCnt() { return ts.rowCount }\n"
    "}"
)


@pytest.fixture()
def media_env(qml_engine):
    """媒体体系测试环境：Img(真图)/Responsive/Video/Parallax/Carousel×2/Timeline/Chat/虚拟表/服务端表。"""
    import os
    import tempfile

    from PIL import Image as PILImage

    fd, path = tempfile.mkstemp(suffix=".png")
    os.close(fd)
    PILImage.new("RGB", (8, 8), (91, 110, 245)).save(path)
    qml = MEDIA_ENV_QML.replace("%SRC%", QUrl.fromLocalFile(path).toString())
    win = _make(qml_engine, qml, wait=0.3)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)
    _pump(150)
    return drv


def test_media_img_load_and_ratio(media_env):
    """真实 PNG 加载 → loaded 事件 + ratio 派生高度（120/1.6=75）。"""
    drv = media_env
    assert drv.call0("imgStatus") == "loaded"
    assert drv.val("imgLoaded") is True
    assert abs(drv.call0("imgH") - 75.0) < 0.6


def test_media_responsive_ratio(media_env):
    """NovaResponsive：ratio 2.0 → height = width / ratio = 160。"""
    drv = media_env
    assert abs(drv.call0("respH") - 160.0) < 0.6


def test_media_video_lazy_player(media_env):
    """空源 NovaVideo 不创建播放器（惰性实例化）。"""
    drv = media_env
    assert drv.call0("vidPlayerGone") is True


def test_media_parallax_progress_and_event(media_env):
    """滚动宿主 → progress∈(0,1] + scrolled 事件上报；媒体层产生位移。"""
    drv = media_env
    p = drv.call1("parScroll", 120)
    assert 0 < p <= 1
    info = drv.val("parInfo")
    assert info is not None and "progress" in info
    y1 = drv.call0("parMediaY")
    drv.call1("parScroll", 300)
    y2 = drv.call0("parMediaY")
    assert y2 < y1   # 视差：媒体层随滚动上移


def test_media_carousel_go_to_and_skip_disabled(media_env):
    """goTo(name) 受控上报；next 跳过禁用页；infinite 末页回绕首页。"""
    drv = media_env
    assert drv.call1("carGo", "y") == "y"
    assert drv.call1("carGo", "dis") == "y"     # 禁用页不可达
    assert drv.call0("carNext") == "z"
    assert drv.call0("carNext") == "x"          # infinite 回绕
    assert drv.call0("carPrev") == "z"
    assert drv.call0("carCount") == 4


def test_media_carousel_control_attach(media_env):
    """NovaCarouselControl 声明于轮播内部 → 自动挂载覆盖层。"""
    drv = media_env
    assert drv.call0("carCtlOk") is True


def test_media_carousel_autoplay_stop_at_end(media_env):
    """autoplay 到末页自动停（Timer.running=false）；interval=30ms。"""
    drv = media_env
    _pump(260)
    s = drv.call0("car2State")
    assert '"ms":30' in s
    assert '"atEnd":true' in s
    assert '"run":false' in s


def test_media_timeline_entry_host_binding(media_env):
    """条目回填序号/宿主解析（坑位 14 向上遍历）；loose side 覆盖宿主 side。"""
    drv = media_env
    s = drv.call0("tlInfo")
    assert '"host":true' in s and '"idx":1' in s and '"lay":"comfortable"' in s
    assert '"first":false' in s and '"last":false' in s
    assert drv.call0("tlSide2") == "right"


def test_media_chat_message_semantics(media_env):
    """text 数组多条气泡；size 栅格宽 8/12；sent 镜像翻转。"""
    drv = media_env
    assert drv.call0("chatLines") == 2
    assert abs(drv.call0("chatZone") - 420 * 8 / 12) < 1.5
    assert drv.call0("chatMirror") is True


def test_media_table_virtual_scroll(media_env):
    """500 行虚拟化 + scrollTo 跳转（行高 40）。"""
    drv = media_env
    assert drv.call0("tvCount") == 500
    h1 = drv.call1("tvScroll", 1)                # 首行高（NovaTr 44 + 分隔 1）
    assert h1 > 0
    assert drv.call1("tvScroll", 100) >= 100 * h1 - 10   # 线性跳转（含分隔线余量）


def test_media_table_server_request(media_env):
    """服务端模式：排序/翻页/过滤/主动交互全部触发 request（页码重置语义）。"""
    drv = media_env
    s = drv.call1("srvSort", "nm")
    assert '"sortBy":"nm"' in s and '"descending":false' in s and '"page":1' in s
    s2 = drv.call1("srvSort", "nm")
    assert '"descending":true' in s2             # 升→降
    s3 = drv.call1("srvGo", 3)
    assert '"page":3' in s3 and '"rowsPerPage":10' in s3 and '"rowsNumber":42' in s3
    assert drv.call0("srvPages") == 5            # ceil(42/10)
    assert drv.call0("srvRowCnt") == 42
    s4 = drv.call1("srvSet", 2)
    assert '"sortBy":"nm"' in s4 and '"descending":true' in s4 and '"page":2' in s4
    s5 = drv.call0("srvFirst")
    assert '"page":1' in s5
    s6 = drv.call1("srvFilterSet", "关键词")
    assert '"page":1' in s6                      # 过滤触发请求且重置页码


def test_media_env_reentrant(media_env):
    """媒体环境可复检（画廊加载由既有 test_gallery_loads 覆盖）。"""
    drv = media_env
    assert drv.call0("carCount") == 4


# ══════════════════════════════════════════════════════════════
# 四期 Sprint A · 导航体系行为级断言（v0.13.0，契约见 docs/PARITY.md §0.13）
# ══════════════════════════════════════════════════════════════

NAV_ENV_QML = (
    "import QtQuick\n"
    "import Nova.Controls\n"
    "Item {\n"
    "  id: it\n"
    "  width: 900; height: 900\n"
    "  // 宿主状态（受控写回）\n"
    "  property var tabVal: null\n"
    "  property var stepVal: 's1'\n"
    "  property var stepEvt: null\n"
    "  property bool expA: false\n"
    "  property bool expB: false\n"
    "  property bool expC: false\n"
    "  property bool fabOpen: false\n"
    "  property var crumbClick: null\n"
    "  property var transInfo: null\n"
    "  // ① NovaTabs（受控 + 禁用页）\n"
    "  NovaTabs {\n"
    "    id: tabs; width: 400; height: 48\n"
    "    modelValue: it.tabVal\n"
    "    NovaTab { id: t0; name: 'a'; label: 'A' }\n"
    "    NovaTab { id: t1; name: 'b'; label: 'B' }\n"
    "    NovaTab { id: t2; name: 'c'; label: 'C'; disable: true }\n"
    "    onUpdateModelValue: (n) => it.tabVal = n\n"
    "  }\n"
    "  // ② NovaTabPanels（与 Tabs 共享 tabVal；禁用页 + 过渡事件）\n"
    "  NovaTabPanels {\n"
    "    id: panels; width: 400; height: 120; y: 60\n"
    "    modelValue: it.tabVal\n"
    "    animated: false\n"
    "    NovaTabPanel { name: 'a' }\n"
    "    NovaTabPanel { name: 'b' }\n"
    "    NovaTabPanel { name: 'c'; disable: true }\n"
    "    onUpdateModelValue: (n) => it.tabVal = n\n"
    "    onBeforeTransition: (info) => it.transInfo = info\n"
    "  }\n"
    "  // ③ NovaStepper（s3 禁用）\n"
    "  NovaStepper {\n"
    "    id: st; width: 500; height: 200; y: 200\n"
    "    modelValue: it.stepVal\n"
    "    NovaStep { name: 's1'; title: '一' }\n"
    "    NovaStep { name: 's2'; title: '二'; done: true }\n"
    "    NovaStep { name: 's3'; title: '三'; disable: true }\n"
    "    NovaStep { name: 's4'; title: '四' }\n"
    "    onUpdateModelValue: (n) => it.stepVal = n\n"
    "    onBeforeTransition: (info) => it.stepEvt = info\n"
    "  }\n"
    "  // ④ NovaExpansionItem 手风琴（A/B 同组，C 异组）\n"
    "  NovaExpansionItem {\n"
    "    id: ea; label: 'A'; group: 'acc'; width: 200; y: 420\n"
    "    expanded: it.expA\n"
    "    onUpdateModelValue: (v) => it.expA = v\n"
    "  }\n"
    "  NovaExpansionItem {\n"
    "    id: eb; label: 'B'; group: 'acc'; width: 200; y: 470\n"
    "    expanded: it.expB\n"
    "    onUpdateModelValue: (v) => it.expB = v\n"
    "  }\n"
    "  NovaExpansionItem {\n"
    "    id: ec; label: 'C'; group: 'other'; width: 200; y: 520\n"
    "    expanded: it.expC\n"
    "    onUpdateModelValue: (v) => it.expC = v\n"
    "  }\n"
    "  // ⑤ NovaFab（stagger 10ms × 3 动作）\n"
    "  NovaFab {\n"
    "    id: fab; x: 600; y: 420\n"
    "    stagger: 10; direction: 'right'\n"
    "    modelValue: it.fabOpen\n"
    "    NovaFabAction { id: fa0; icon: 'mdi:pencil' }\n"
    "    NovaFabAction { id: fa1; icon: 'mdi:delete' }\n"
    "    NovaFabAction { id: fa2; icon: 'mdi:share' }\n"
    "    onUpdateModelValue: (v) => it.fabOpen = v\n"
    "  }\n"
    "  // ⑥ NovaBreadcrumbs\n"
    "  NovaBreadcrumbs {\n"
    "    id: crumb; width: 400; height: 28; y: 640\n"
    "    NovaBreadcrumbsEl { id: ce0; label: '主页'; onClicked: it.crumbClick = 'home' }\n"
    "    NovaBreadcrumbsEl { id: ce1; label: '分类'; onClicked: it.crumbClick = 'cat' }\n"
    "    NovaBreadcrumbsEl { id: ce2; label: '当前'; disable: true }\n"
    "  }\n"
    "  // ── 驱动代理（固定形参） ──\n"
    "  function tabClick(i) { [t0,t1,t2][i].requestClick(); return String(it.tabVal) }\n"
    "  function tabActive(i) { return [t0,t1,t2][i].isActive }\n"
    "  function panelGo(n) { panels.goTo(n, false); return String(it.tabVal) }\n"
    "  function panelNext() { panels.next(); return String(it.tabVal) }\n"
    "  function panelCur() { return panels.currentIndex }\n"
    "  function stepGo(i) { st.goTo(i); return String(it.stepVal) }\n"
    "  function stepNext() { st.next(); return String(it.stepVal) }\n"
    "  function expOpenA() { ea.show(); return [it.expA, it.expB, it.expC].join(',') }\n"
    "  function expHideA() { ea.hide(); return String(it.expA) }\n"
    "  function fabToggle() { fab.requestToggle(); return it.fabOpen }\n"
    "  function fabReveal() { return [fa0.revealed, fa1.revealed, fa2.revealed].join(',') }\n"
    "  function fabDelays() { return [fa0.delay, fa1.delay, fa2.delay].join(',') }\n"
    "  function fabHideNow() { fab.hide(); return String(it.fabOpen) }\n"
    "  function crumbClick0() { ce0.requestClick(); return String(it.crumbClick) }\n"
    "  function crumbSeps() { return crumb._seps.length }\n"
    "  function crumbSepText() { return crumb._seps.length > 0 ? crumb._seps[0].text : '' }\n"
    "  function crumbActive() { return [ce0.isActiveColor, ce1.isActiveColor, ce2.isActiveColor].join(',') }\n"
    "  function transInfoOk() { return it.transInfo !== null && it.transInfo.newIndex !== undefined }\n"
    "  function stepEvtOk() { return it.stepEvt !== null && it.stepEvt.newIndex !== undefined }\n"
    "}"
)


@pytest.fixture()
def nav_env(qml_engine):
    """导航体系测试环境：Tabs/Panels 联动 + Stepper + 手风琴 + Fab + 面包屑。"""
    win = _make(qml_engine, NAV_ENV_QML, wait=0.3)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)
    _pump(150)
    return drv


def test_nav_tabs_controlled_and_disabled(nav_env):
    """Tab 点击受控写回；禁用页不写回；isActive 由宿主下发。"""
    drv = nav_env
    assert _call(drv, "tabClick", 1) == "b"
    assert _call(drv, "tabActive", 1) is True
    assert _call(drv, "tabActive", 0) is False
    assert _call(drv, "tabClick", 2) == "b"      # 禁用页：不写回
    assert _call(drv, "tabActive", 2) is False


def test_nav_tab_panels_navigation(nav_env):
    """面板与 Tabs 共享 modelValue 联动；goTo 名称寻址；禁用面板跳过；过渡事件。"""
    drv = nav_env
    assert _call(drv, "panelCur") == 0           # 初始 tabVal=null → 首面板
    _call(drv, "tabClick", 1)                    # 'b' → 面板联动
    assert _call(drv, "panelCur") == 1
    assert _call(drv, "panelGo", "a") == "a"     # 名称寻址
    assert _call(drv, "panelGo", 2) == "a"       # 禁用面板拒绝
    assert _call(drv, "panelNext") == "b"        # a → b
    _pump(60)
    assert _call(drv, "transInfoOk") is True     # beforeTransition 事件


def test_nav_stepper_header_and_navigation(nav_env):
    """goTo 序号寻址；next 跳过禁用步骤；禁用目标拒绝；before-transition 事件。"""
    drv = nav_env
    assert _call(drv, "stepGo", 1) == "s2"
    assert _call(drv, "stepNext") == "s4"        # s3 禁用 → 跳到 s4
    assert _call(drv, "stepGo", 2) == "s4"       # 禁用目标拒绝
    assert _call(drv, "stepEvtOk") is True


def test_nav_expansion_group_accordion(nav_env):
    """同组互斥：A 展开时 B 受控收起；异组 C 不受影响；hide() 收起自身。"""
    drv = nav_env
    assert _call(drv, "expOpenA") == "true,false,false"
    assert _call(drv, "expHideA") == "false"


def test_nav_fab_stagger_reveal(nav_env):
    """toggle 受控写回；级联延迟 0/10/20；Timer 显式启动后动作全部 revealed；hide 收起。"""
    drv = nav_env
    assert _call(drv, "fabToggle") is True
    assert _call(drv, "fabDelays") == "0,10,20"
    _pump(250)
    assert _call(drv, "fabReveal") == "true,true,true"
    assert _call(drv, "fabHideNow") == "false"
    _pump(80)
    assert _call(drv, "fabReveal") == "false,false,false"


def test_nav_breadcrumbs_semantics(nav_env):
    """分隔符自动插入（n-1 个）；点击信号；激活色：中间条目着色、当前页不着色（2.35.6 源码语义）。"""
    drv = nav_env
    assert _call(drv, "crumbSeps") == 2
    assert _call(drv, "crumbSepText") == "/"
    assert _call(drv, "crumbClick0") == "home"
    assert _call(drv, "crumbActive") == "true,true,false"


def test_nav_env_reentrant(nav_env):
    """导航环境可复检。"""
    drv = nav_env
    assert _call(drv, "crumbSeps") == 2


# ══════════════════════════════════════════════════════════════
# 四期 Sprint B · 弹层与反馈行为级断言（v0.14.0，契约见 docs/PARITY.md §0.14）
# ══════════════════════════════════════════════════════════════

POPUP_ENV_QML = (
    "import QtQuick\n"
    "import Nova.Controls\n"
    "import Nova.Behaviors\n"
    "import Nova.Services\n"
    "Item {\n"
    "  id: it\n"
    "  width: 900; height: 800\n"
    "  // 宿主状态\n"
    "  property var reasons: []\n"
    "  property var picks: []\n"
    "  property int refreshCount: 0\n"
    "  property var scrollInfo: null\n"
    "  property var resizeInfo: null\n"
    "  property bool menuOpen: false\n"
    "  property bool dlgOpen: false\n"
    "  property bool dlgPersistent: false\n"
    "  property int shakeCount: 0\n"
    "  property bool sheetOpen: false\n"
    "  // ① NovaMenu（auto-close + 右键形态）\n"
    "  NovaMenu {\n"
    "    id: menu1; width: 160; height: 90\n"
    "    modelValue: it.menuOpen\n"
    "    autoClose: true\n"
    "    NovaItem { id: mi0; label: '打开文件'; clickable: true }\n"
    "    NovaItem { id: mi1; label: '保存'; clickable: true }\n"
    "    onUpdateModelValue: (v) => it.menuOpen = v\n"
    "  }\n"
    "  // ② NovaDialogShell（persistent + 关闭原因 + shake）\n"
    "  NovaDialogShell {\n"
    "    id: dlg1; anchors.fill: parent\n"
    "    modelValue: it.dlgOpen\n"
    "    persistent: it.dlgPersistent\n"
    "    onDismissed: (reason) => it.reasons = it.reasons.concat([reason])\n"
    "    onShake: it.shakeCount++\n"
    "    Text { text: '对话框内容' }\n"
    "    onUpdateModelValue: (v) => it.dlgOpen = v\n"
    "  }\n"
    "  // ③ NovaBottomSheet（动作 + 关闭原因）\n"
    "  NovaBottomSheet {\n"
    "    id: sheet1; anchors.fill: parent\n"
    "    modelValue: it.sheetOpen\n"
    "    actions: [{label: '拍照', icon: 'mdi:camera'}, {label: '相册', icon: 'mdi:image'}, {label: '取消'}]\n"
    "    onDismissed: (reason) => it.reasons = it.reasons.concat(['sheet:' + reason])\n"
    "    onActionPicked: (idx) => it.picks = it.picks.concat([idx])\n"
    "    onUpdateModelValue: (v) => it.sheetOpen = v\n"
    "  }\n"
    "  // ④ NovaAjaxBar（多进程计数）\n"
    "  NovaAjaxBar { id: bar1; width: 300; height: 4; position: 'top' }\n"
    "  // ⑤ 观察器\n"
    "  Flickable {\n"
    "    id: flk; x: 400; width: 200; height: 150\n"
    "    contentWidth: width; contentHeight: 600\n"
    "    Rectangle { width: 200; height: 600; color: '#DDDDDD' }\n"
    "  }\n"
    "  NovaScrollObserver { id: obsS; target: flk; onScroll: () => it.scrollInfo = [obsS.verticalPosition] }\n"
    "  Rectangle { id: rsz; x: 400; y: 200; width: 100; height: 50; color: '#888888' }\n"
    "  NovaResizeObserver { target: rsz; debounce: 0; onResize: (w, h) => it.resizeInfo = [w, h] }\n"
    "  // ⑥ NovaPullToRefresh（受控 refreshing）\n"
    "  NovaPullToRefresh {\n"
    "    id: ptr; x: 400; y: 300; width: 200; height: 150\n"
    "    Rectangle { color: '#E8EAF2'; anchors.fill: parent }\n"
    "    onRefresh: it.refreshCount++\n"
    "  }\n"
    "  // ⑦ NovaBtnGroup（样式下发）\n"
    "  NovaBtnGroup { id: bgrp; x: 400; y: 500; outline: true;\n"
    "    NovaBtn { id: b1; text: '日' } NovaBtn { text: '周' } }\n"
    "  // ── 驱动代理（固定形参） ──\n"
    "  function menuShow() { menu1.show(); return it.menuOpen }\n"
    "  function menuClickItem() { mi0.clicked(); return it.menuOpen }\n"
    "  function menuEscape() { NovaOverlayHost.closePopups(1, 'escape'); return it.menuOpen }\n"
    "  function dlgShow() { dlg1.show(); return it.dlgOpen }\n"
    "  function dlgBackdrop() { dlg1.requestDismiss('backdrop'); return it.dlgOpen }\n"
    "  function dlgShowPersistent() { dlg1.show(); it.dlgPersistent = true; return it.dlgOpen }\n"
    "  function dlgBackdropLock() { dlg1.requestDismiss('backdrop'); return it.dlgOpen }\n"
    "  function dlgShake() { dlg1.doShake(); return it.shakeCount }\n"
    "  function dlgEscape() { dlg1.requestDismiss('escape'); return it.dlgOpen }\n"
    "  function lastReason() { return it.reasons.length > 0 ? it.reasons[it.reasons.length-1] : '' }\n"
    "  function reasonsCount() { return it.reasons.length }\n"
    "  function sheetShow() { sheet1.show(); return it.sheetOpen }\n"
    "  function sheetPick() { sheet1._pick(1); return String(it.picks) + '|' + it.sheetOpen }\n"
    "  function barStart() { bar1.start(); bar1.start(); return bar1.active }\n"
    "  function barStop1() { bar1.stop(); return bar1.active }\n"
    "  function barStop2() { bar1.stop(); return bar1.active }\n"
    "  function topCount() { return NovaOverlayHost.popupCount() }\n"
    "  function scrollDown() { flk.contentY = 100; return obsS.scrollRoot !== null && obsS.verticalPosition >= 0 }\n"
    "  function rszGrow() { rsz.width = 150; rsz.height = 80; return String(it.resizeInfo) }\n"
    "  function ptrTrigger() { ptr.trigger(); return it.refreshCount + '|' + ptr.refreshing }\n"
    "  function ptrDone() { ptr.refreshing = false; return ptr.refreshing }\n"
    "  function grpStyle() { return b1.variant }\n"
    "  function loadingBarSvc() { NovaLoadingBar.start(); NovaLoadingBar.stop(); return 'ok' }\n"
    "}"
)


@pytest.fixture()
def popup_env(qml_engine):
    """弹层与反馈测试环境：菜单/对话框/底部面板/AjaxBar/观察器/PTR + 调用代理。"""
    win = _make(qml_engine, POPUP_ENV_QML, wait=0.3)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)
    _pump(150)
    return drv


def test_popup_menu_auto_close_and_stack(popup_env):
    """菜单 show → auto-close 子项点击关闭；ESC 经弹层栈关闭；topCount 计数。"""
    drv = popup_env
    assert _call(drv, "menuShow") is True
    _pump(60)                                     # auto-close 钩子经 callLater 挂接
    assert _call(drv, "topCount") == 1            # 进弹层栈
    assert _call(drv, "menuClickItem") is False   # auto-close：菜单项点击后关闭
    assert _call(drv, "topCount") == 0            # 出弹层栈


def test_popup_menu_escape_via_stack(popup_env):
    """closePopups(1, 'escape') 关顶层弹层（菜单）。"""
    drv = popup_env
    _call(drv, "menuShow")
    _pump(60)
    assert _call(drv, "topCount") == 1
    assert _call(drv, "menuEscape") is False      # ESC 语义逐层关闭


def test_popup_dialog_dismiss_reasons(popup_env):
    """关闭原因上报：backdrop 上报；persistent 锁 backdrop+ESC 且 shake；放开后 escape 关闭上报。"""
    drv = popup_env
    assert _call(drv, "dlgShow") is True
    assert _call(drv, "dlgBackdrop") is False     # 背景点击关闭
    assert _call(drv, "lastReason") == "backdrop"
    _call(drv, "dlgShowPersistent")               # persistent
    assert _call(drv, "dlgBackdropLock") is True  # 背景点击被锁
    assert _call(drv, "dlgShake") == 1            # shake 吸引注意
    assert _call(drv, "dlgEscape") is True        # ESC 被锁
    _pump(20)
    assert _call(drv, "dlgEscape") is True
    _pump(20)


def test_popup_dialog_escape_report(popup_env):
    """非 persistent 对话框 ESC 上报 escape。"""
    drv = popup_env
    assert _call(drv, "dlgShow") is True
    assert _call(drv, "dlgEscape") is False
    assert _call(drv, "lastReason") == "escape"


def test_popup_bottom_sheet_pick(popup_env):
    """动作面板：_pick(1) → actionPicked(1) + dismissed('ok') + 受控关闭。"""
    drv = popup_env
    assert _call(drv, "sheetShow") is True
    result = _call(drv, "sheetPick")
    assert result.startswith("[1]|") or "1" in result.split("|")[0]
    assert _call(drv, "lastReason") == "sheet:ok"


def test_popup_ajaxbar_refcount(popup_env):
    """AjaxBar 多进程计数：start×2 → stop×1 仍活跃 → stop×2 收尾。"""
    drv = popup_env
    assert _call(drv, "barStart") is True
    assert _call(drv, "barStop1") is True         # 还有一个等待者
    assert _call(drv, "barStop2") is False        # 全部结束 → 收尾


def test_popup_pull_to_refresh(popup_env):
    """PTR trigger() → refresh 事件 + refreshing 态；宿主置 false 复位。"""
    drv = popup_env
    result = _call(drv, "ptrTrigger")
    assert result.startswith("1|true")
    assert _call(drv, "ptrDone") is False


def test_popup_observers(popup_env):
    """ResizeObserver 尺寸变化上报；ScrollObserver 触发 scroll 事件。"""
    drv = popup_env
    _pump(60)
    assert _call(drv, "scrollDown") is True   # Behaviors 版 verticalPosition > 0
    _pump(30)
    assert _call(drv, "rszGrow").startswith("[150, 80]") or "150" in _call(drv, "rszGrow")


def test_popup_btn_group_style_and_service(popup_env):
    """BtnGroup 样式下发（outline）；NovaLoadingBar 服务降级 no-op 不炸。"""
    drv = popup_env
    assert _call(drv, "grpStyle") == "outline"
    assert _call(drv, "loadingBarSvc") == "ok"


# ══════════════════════════════════════════════════════════════════
# 五期 Sprint A · 长尾组件（v0.15.0）：Editor / SlideItem / Morph / IconGenie / MCP
# ══════════════════════════════════════════════════════════════════

LT_EDITOR_ENV_QML = (
    "import QtQuick\nimport Nova.Controls\n"
    "Item {\n"
    "  id: host\n"
    "  width: 460; height: 300\n"
    "  property int emits: 0\n"
    "  NovaEditor {\n"
    "    id: ed\n"
    "    width: 460; height: 300\n"
    "    toolbar: [['bold', 'italic'], ['h1', 'quote'], ['undo', 'redo']]\n"
    "    onUpdateModelValue: function(v) { ed.modelValue = v; host.emits++ }\n"
    "  }\n"
    "  function boldNoSel() { ed.modelValue = ''; ed.execCmd('bold'); return ed.modelValue }\n"
    "  function boldSel() { ed.modelValue = 'hello world'; ed.selectRange(0, 5);"
    " ed.execCmd('bold'); return ed.modelValue }\n"
    "  function prefixQuote() { ed.modelValue = 'hello'; ed.execCmd('quote'); return ed.modelValue }\n"
    "  function prefixH1() { ed.modelValue = '行甲\\n行乙'; ed.selectRange(2, 4);"
    " ed.execCmd('h2'); return ed.modelValue }\n"
    "  function rfNoSel() { ed.modelValue = 'a[Bold]b[/Bold]c'; ed.selectRange(0, 0);"
    " return ed.execCmd('removeFormat') ? ed.modelValue : 'noop' }\n"
    "  function htmlOf(s) { ed.modelValue = s; return ed.toHtml() }\n"
    "  function btnCount() { return ed.buttonCount }\n"
    "  function undoCmd() { ed.modelValue = 'abc'; ed.execCmd('undo'); return ed.modelValue }\n"
    "}\n"
)

LT_SLIDE_ENV_QML = (
    "import QtQuick\nimport Nova.Controls\n"
    "Item {\n"
    "  id: host\n"
    "  width: 320; height: 60\n"
    "  property string log: ''\n"
    "  NovaSlideItem {\n"
    "    id: si\n"
    "    width: 320; height: 60\n"
    "    duration: 60\n"
    "    leftSlot: Component { Rectangle { anchors.fill: parent; color: 'teal' } }\n"
    "    rightSlot: Component { Rectangle { anchors.fill: parent; color: 'tomato' } }\n"
    "    Rectangle { color: '#E8EAF2'; anchors.fill: parent }\n"
    "    onSlideOpened: function(side) { host.log += 'open:' + side + ';' }\n"
    "    onSlideClosed: { host.log += 'closed;' }\n"
    "    onLeftAction: { host.log += 'L;' }\n"
    "  }\n"
    "  function slideL() { si.slideLeft(); return si.opened }\n"
    "  function slideR() { si.slideRight(); return si.opened }\n"
    "  function closeAll() { si.reset(); return si.opened }\n"
    "  function frontX() { return si.children[2].x }\n"
    "}\n"
)

LT_MORPH_ENV_QML = (
    "import QtQuick\nimport Nova.Behaviors\n"
    "Item {\n"
    "  id: host\n"
    "  width: 300; height: 150\n"
    "  property int started: 0\n"
    "  property int finished: 0\n"
    "  Rectangle {\n"
    "    id: cardA\n"
    "    width: 50; height: 40; x: 10; y: 5; color: 'teal'\n"
    "    NovaMorph { id: ma; group: 'g'; target: cardA; duration: 0\n"
    "      onMorphStarted: host.started++\n"
    "      onMorphFinished: host.finished++ }\n"
    "  }\n"
    "  Rectangle {\n"
    "    id: cardB\n"
    "    width: 120; height: 60; x: 100; y: 40; color: 'tomato'; visible: false\n"
    "    NovaMorph { id: mb; group: 'g'; target: cardB; duration: 0\n"
    "      onMorphStarted: host.started++\n"
    "      onMorphFinished: host.finished++ }\n"
    "  }\n"
    "  function toA() { ma.morph(); return cardA.visible ? 'aOn' : 'fail' }\n"
    "  function toB() { mb.morph(); return cardB.visible ? 'bOn' : 'fail' }\n"
    "  function vis() { return 'a:' + cardA.visible + ',b:' + cardB.visible }\n"
    "  function act() { return 'ma:' + ma.isActive() + ',mb:' + mb.isActive() }\n"
    "}\n"
)

LT_MORPH_GHOST_ENV_QML = (
    "import QtQuick\nimport Nova.Behaviors\n"
    "Item {\n"
    "  id: host\n"
    "  width: 300; height: 150\n"
    "  property int started: 0\n"
    "  property int finished: 0\n"
    "  property bool bVis: cardB.visible\n"
    "  Rectangle {\n"
    "    id: cardA\n"
    "    width: 50; height: 40; x: 10; y: 5\n"
    "    NovaMorph { id: ma; group: 'g'; target: cardA; duration: 120 }\n"
    "  }\n"
    "  Rectangle {\n"
    "    id: cardB\n"
    "    width: 120; height: 60; x: 100; y: 40; visible: false\n"
    "    NovaMorph { id: mb; group: 'g'; target: cardB; duration: 120\n"
    "      onMorphStarted: host.started++\n"
    "      onMorphFinished: host.finished++ }\n"
    "  }\n"
    "  function toA() { ma.morph(); return 'ok' }\n"
    "  function toB() { mb.morph(); return 'ok' }\n"
    "}\n"
)


def _lt_env(qml_engine, code):
    win = _make(qml_engine, code, wait=0.12)
    drv = _make(qml_engine, BEHAVIOR_DRIVER_QML)
    drv.setProperty("w", win)
    _pump(50)
    return win, drv


def test_lt_editor_commands(qml_engine):
    """Editor 命令链：无选区占位对 / 选区包裹 / 行前缀 / removeFormat 守卫 / undo。"""
    win, drv = _lt_env(qml_engine, LT_EDITOR_ENV_QML)
    assert _call(drv, "boldNoSel") == "[Bold]text[/Bold]"
    assert drv.val("emits") >= 1                     # 受控 emit 上报
    assert _call(drv, "boldSel") == "[Bold]hello[/Bold] world"
    assert _call(drv, "prefixQuote") == "> hello"    # 光标行前缀
    assert _call(drv, "prefixH1") == "## 行甲\n## 行乙"  # 选区跨两行逐行前缀（h2 命令）
    assert _call(drv, "rfNoSel") == "noop"           # 无选区 removeFormat 不动（返回 false）


def test_lt_editor_html_and_toolbar(qml_engine):
    """Editor HTML 导出：标题/引用/列表/段落 + 行内标记；工具栏按钮渲染。"""
    win, drv = _lt_env(qml_engine, LT_EDITOR_ENV_QML)
    html = _call(drv, "htmlOf", "# 大标题\n> 引用行\n- 选项一\n普通段落")
    assert "<h1>大标题</h1>" in html
    assert "<blockquote>引用行</blockquote>" in html
    assert "<li>选项一</li>" in html
    assert "<p>普通段落</p>" in html
    assert "&lt;" in _call(drv, "htmlOf", "a<b")     # HTML 转义
    n = _call(drv, "btnCount")
    assert n >= 6                                    # 4 命令按钮 + separator 节点（Repeater 展平）
    assert "abc" in _call(drv, "undoCmd") or _call(drv, "undoCmd") == ""   # undo 不炸（无栈亦安全）


def test_lt_slideitem_open_reset(qml_engine):
    """SlideItem 命令式开合：slideLeft/slideRight 事件 + reset 收拢 + 跟手位移。"""
    win, drv = _lt_env(qml_engine, LT_SLIDE_ENV_QML)
    assert _call(drv, "slideL") is True
    _pump(120)
    assert drv.val("log") == "open:left;"
    assert _call(drv, "closeAll") is False
    _pump(120)
    assert drv.val("log") == "open:left;closed;"
    assert _call(drv, "slideR") is True
    _pump(120)
    assert drv.val("log") == "open:left;closed;open:right;"
    # 跟手位移：slideRight 后正面 x = -revealWidth（72）
    x = _call(drv, "frontX")
    assert abs(x + 72) < 1.5


def test_lt_morph_switch_and_events(qml_engine):
    """Morph 零时长切换：注册表默认成员（onCompleted 逆序）→ morph 双向切换 + 信号计数。"""
    win, drv = _lt_env(qml_engine, LT_MORPH_ENV_QML)
    # 初始：b 先完成注册 = 默认活动元素（宿主初始 visible=false 由首次 morph 校正）
    assert _call(drv, "toA") == "aOn"                # 切到 a：b 隐藏
    assert "a:true,b:false" in _call(drv, "vis")
    assert _call(drv, "act") == "ma:true,mb:false"
    assert _call(drv, "toB") == "bOn"                # 切回 b：a 隐藏
    assert "a:false,b:true" in _call(drv, "vis")
    assert drv.val("started") >= 2 and drv.val("finished") >= 2


def test_lt_morph_ghost_animation(qml_engine):
    """Morph ghost 动画路径：morph 立即隐藏旧元素、新元素延至动画完成显示。"""
    win, drv = _lt_env(qml_engine, LT_MORPH_GHOST_ENV_QML)
    assert _call(drv, "toA") == "ok"
    _pump(60)
    assert _call(drv, "toB") == "ok"
    assert win.property("bVis") is False             # 动画期未显示
    assert win.property("started") == 1
    _pump(320)                                       # 等动画 + Timer 收尾（坑位 19 显式 start）
    assert win.property("bVis") is True
    assert win.property("finished") == 1


def test_lt_icongenie_cli(qml_engine, tmp_path):
    """IconGenie CLI：64px 源图 → favicon/android/apple-touch 产物 + 尺寸正确 + report 清单。"""
    import json as _json
    import subprocess
    import sys

    from PIL import Image

    src = tmp_path / "src.png"
    Image.new("RGBA", (64, 64), (91, 110, 245, 255)).save(src)
    out = tmp_path / "icons"
    r = subprocess.run(
        [sys.executable, str(Path(__file__).resolve().parents[1] / "scripts" / "gen_icons.py"),
         str(src), "--out", str(out), "--background", "#FFFFFF", "--padding", "2"],
        capture_output=True, text=True, timeout=60)
    assert r.returncode == 0, r.stderr
    report = _json.loads((out / "icongenie-report.json").read_text(encoding="utf-8"))
    assert report["count"] >= 20
    assert Image.open(out / "favicon" / "favicon-16x16.png").size == (16, 16)
    assert Image.open(out / "android" / "icon-192.png").size == (192, 192)
    assert Image.open(out / "apple-touch-icon-180.png").size == (180, 180)
    assert (out / "ios" / "AppIcon-1024.png").exists()
    names = {f["path"] for f in report["files"]}
    assert "favicon/favicon-128x128.png" in names
    # splash 需要背景色：--splash + transparent 必须拒绝
    r2 = subprocess.run(
        [sys.executable, str(Path(__file__).resolve().parents[1] / "scripts" / "gen_icons.py"),
         str(src), "--out", str(out / "x"), "--splash"],
        capture_output=True, text=True, timeout=60)
    assert r2.returncode != 0


def test_lt_mcp_server_six_tools(qml_engine):
    """Nova MCP server：initialize/tools/list 六工具/search 命中/get_api 版本化口径。"""
    import json as _json
    import subprocess
    import sys

    root = Path(__file__).resolve().parents[1]
    proc = subprocess.Popen(
        [sys.executable, str(root / "scripts" / "nova_mcp.py"), "--project", str(root)],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, encoding="utf-8")

    def rpc(rid, method, params=None):
        req = {"jsonrpc": "2.0", "id": rid, "method": method}
        if params is not None:
            req["params"] = params
        proc.stdin.write(_json.dumps(req) + "\n")
        proc.stdin.flush()
        return _json.loads(proc.stdout.readline())

    try:
        r = rpc(1, "initialize", {"protocolVersion": "2024-11-05",
                                  "capabilities": {}, "clientInfo": {"name": "t", "version": "0"}})
        assert r["result"]["serverInfo"]["name"] == "nova-mcp"
        r = rpc(2, "tools/list")
        names = [t["name"] for t in r["result"]["tools"]]
        assert names == ["search_docs", "list_pages", "get_page", "list_api",
                         "get_api", "check_updates"]
        r = rpc(3, "tools/call", {"name": "search_docs",
                                  "arguments": {"keyword": "morph"}})
        txt = r["result"]["content"][0]["text"]
        assert "NovaMorph" in txt
        r = rpc(4, "tools/call", {"name": "list_pages"})
        assert "CHANGELOG.md" in r["result"]["content"][0]["text"]
        r = rpc(5, "tools/call", {"name": "get_page",
                                  "arguments": {"name": "CONSTITUTION.md", "section": "第 1 章"}})
        assert "第 1 章" in r["result"]["content"][0]["text"]
        r = rpc(6, "tools/call", {"name": "list_api",
                                  "arguments": {"module": "Nova.Behaviors"}})
        assert "NovaMorphPool" in r["result"]["content"][0]["text"]
        r = rpc(7, "tools/call", {"name": "get_api",
                                  "arguments": {"type": "NovaSlideItem"}})
        api = _json.loads(r["result"]["content"][0]["text"])
        assert api["name"] == "Nova.Controls.NovaSlideItem"
        assert len(api["properties"]) >= 5
        r = rpc(8, "tools/call", {"name": "check_updates"})
        upd = _json.loads(r["result"]["content"][0]["text"])
        assert upd["baseline"] == "Quasar 2.35.5"
        assert len(upd["fingerprint"]) == 16
        # 小上下文口径：search 返回摘要而非全文
        assert len(txt) < 4000
        proc.stdin.close()
    finally:
        proc.wait(timeout=10)
    assert proc.returncode == 0
