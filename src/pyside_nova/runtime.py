# src/pyside_nova/runtime.py
# Nova Runtime 后端：为 QML 服务层提供 Python 侧能力（Storage 持久化 / Platform 精确探测）
"""Nova Runtime —— QML 服务层的 Python 后端（L4 支撑件）。

设计约束（三章）：
1. **能力归位**：纯 QML 做不到的事（无 org 标识的文件级 QSettings、输入设备枚举）集中在此，
   QML 服务单例只做缓存与 API 门面，业务语义仍写在 `.qml`（可读性优先）。
2. **零冲突**：注册到独立模块 URI ``Nova.Runtime``（C++ 侧注册，无 qmldir），
   与目录式 QML 模块 ``Nova.Services`` 互不干扰。
3. **不抛异常**：所有槽返回安全默认值，失败只写日志——QML 侧永远拿到可用值。

注册方式：``init_nova(engine)`` 内自动完成，应用无需感知。
"""

from __future__ import annotations

import os
import re
import sys
import weakref
from pathlib import Path

from PySide6.QtCore import (
    Property,
    QEvent,
    QObject,
    QSettings,
    QStandardPaths,
    QSysInfo,
    Qt,
    Signal,
    Slot,
)
from PySide6.QtGui import QGuiApplication, QInputDevice

__all__ = ["NovaRuntime", "install_input_modality_filter", "runtime_snapshot",
           "set_keyboard_mode"]

# 输入模态（focus-visible 语义的判定依据）：最近一次输入是否来自键盘。
# 默认 True —— 无输入历史时按键盘模态处理，首屏控件焦点环可见（WCAG 2.4.7 不赌运气）。
_KEYBOARD_MODE = True
# 存活的 NovaRuntime 实例（每个 QML 引擎一个，工厂式注册）；事件过滤器只广播给它们
_INSTANCES: "weakref.WeakSet[NovaRuntime]" = weakref.WeakSet()
_FILTER: "_InputModalityFilter | None" = None


def _detect_os() -> str:
    """返回与 ``Qt.platform.os`` 同名的操作系统标识（windows / osx / linux / android / ios / wasm）。"""
    if sys.platform.startswith("win"):
        return "windows"
    if sys.platform == "darwin":
        return "osx"
    if sys.platform in ("emscripten", "wasi"):
        return "wasm"
    if sys.platform.startswith("linux"):
        return "linux"
    return sys.platform or "unknown"


class NovaRuntime(QObject):
    """QML ``Nova.Runtime.NovaRuntime`` 单例：存储后端 + 平台探测 + 输入模态。"""

    keyboardModeChanged = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._os = _detect_os()
        self._settings: QSettings | None = None
        self._path = self._resolve_path()
        self._keyboard_mode = _KEYBOARD_MODE
        _INSTANCES.add(self)

    # ── 输入模态（focus-visible 语义）────────────────────────────────
    @Property(bool, notify=keyboardModeChanged)
    def keyboardMode(self) -> bool:
        """最近一次输入是否来自键盘（True=键盘模态，焦点环应可见）。

        由应用级事件过滤器维护（``install_input_modality_filter``）：KeyPress/KeyRelease
        置 True，鼠标按下/触摸/滚轮置 False。QML 侧经 ``NovaA11y.keyboardMode`` 读取。
        """
        return self._keyboard_mode

    def _apply_keyboard_mode(self, value: bool) -> None:
        if self._keyboard_mode == value:
            return
        self._keyboard_mode = value
        self.keyboardModeChanged.emit()

    @Slot(bool)
    def setKeyboardMode(self, value: bool) -> None:
        """显式设置输入模态（测试/自动化脚本用，绕过事件流）。"""
        self._apply_keyboard_mode(bool(value))

    # ── 存储路径（不依赖 organizationName，纯文件级 ini） ──────────────
    @staticmethod
    def _resolve_path() -> Path:
        base = QStandardPaths.writableLocation(QStandardPaths.StandardLocation.AppDataLocation)
        root = Path(base) if base else Path.home() / ".pyside-nova"
        try:
            root.mkdir(parents=True, exist_ok=True)
        except OSError:
            root = Path.home() / ".pyside-nova"
            root.mkdir(parents=True, exist_ok=True)
        return root / "nova-storage.ini"

    def _store(self) -> QSettings:
        if self._settings is None:
            self._settings = QSettings(str(self._path), QSettings.Format.IniFormat)
        return self._settings

    @Property(str, constant=True)
    def storagePath(self) -> str:
        """实际落盘的 ini 路径（调试/文档用）。"""
        return str(self._path)

    # ── Storage 后端：整块 JSON blob 的读写（namespace 即 group） ──────
    @Slot(str, result=str)
    def readBlob(self, namespace: str) -> str:
        """读取命名空间的 JSON 文本；不存在或损坏返回空串。"""
        try:
            s = self._store()
            s.beginGroup(namespace or "default")
            raw = s.value("blob", "")
            s.endGroup()
            return raw if isinstance(raw, str) else ""
        except Exception as exc:  # pragma: no cover - 后端兜底
            print(f"[nova] NovaRuntime.readBlob failed: {exc}")
            return ""

    @Slot(str, str, result=bool)
    def writeBlob(self, namespace: str, blob: str) -> bool:
        """写入整块 JSON 文本并立即 sync；返回是否落盘成功。"""
        try:
            s = self._store()
            s.beginGroup(namespace or "default")
            s.setValue("blob", blob)
            s.endGroup()
            s.sync()
            return s.status() == QSettings.Status.NoError
        except Exception as exc:  # pragma: no cover
            print(f"[nova] NovaRuntime.writeBlob failed: {exc}")
            return False

    @Slot(str, result=bool)
    def clearBlob(self, namespace: str) -> bool:
        """删除某命名空间全部数据。"""
        try:
            s = self._store()
            s.beginGroup(namespace or "default")
            s.remove("")
            s.endGroup()
            s.sync()
            return s.status() == QSettings.Status.NoError
        except Exception as exc:  # pragma: no cover
            print(f"[nova] NovaRuntime.clearBlob failed: {exc}")
            return False

    # ── Platform 探测 ────────────────────────────────────────────────
    @Property(str, constant=True)
    def osName(self) -> str:
        return self._os

    @Property(str, constant=True)
    def osVersion(self) -> str:
        """产品名（Windows 11 / macOS 版本）优先，回落内核版本。"""
        try:
            pretty = QSysInfo.prettyProductName()
            return pretty or QSysInfo.kernelVersion()
        except Exception:  # pragma: no cover
            return ""

    @Property(str, constant=True)
    def cpuArch(self) -> str:
        return QSysInfo.currentCpuArchitecture()

    @Property(str, constant=True)
    def kernelType(self) -> str:
        return QSysInfo.kernelType()

    @Property(bool, constant=True)
    def isMobile(self) -> bool:
        return self._os in ("android", "ios")

    @Property(bool, constant=True)
    def hasTouchscreen(self) -> bool:
        """枚举 Qt 输入设备：存在 TouchScreen 即视为触摸屏可用（Qt 6 无更简 API）。"""
        try:
            for dev in QInputDevice.devices():
                if dev.type() == QInputDevice.DeviceType.TouchScreen:
                    return True
        except Exception:  # pragma: no cover
            pass
        return False

    # ── HiDPI（0.16.1 · Nova 增强：缩放事实查询） ────────────────────
    # Qt 6 默认启用高 DPI 缩放（AA_EnableHighDpiScaling），组件无需自行换算；
    # 此处暴露「当前缩放事实」供焦点环/细线取整、密度分流等少数场景使用。
    # 坑位 48：不可用 constant=True——单例构造期屏幕未就绪，dpr=0 会被永久缓存。
    hidpiChanged = Signal()

    @Property(float, notify=hidpiChanged)
    def devicePixelRatio(self) -> float:
        """主屏幕设备像素比（100%→1.0 / 150%→1.5 / 200%→2.0，含 QT_SCALE_FACTOR）。

        offscreen 等无真实屏幕的平台 dpr 可能为 0：回落 1.0（100% 语义）。"""
        screen = QGuiApplication.primaryScreen()
        dpr = float(screen.devicePixelRatio()) if screen is not None else 1.0
        return dpr if dpr > 0.0 else 1.0

    @Property(float, notify=hidpiChanged)
    def scaleFactor(self) -> float:
        """QT_SCALE_FACTOR 环境因子（未设置返回 1.0；与 dpr 区分用于诊断）。"""
        try:
            return float(os.environ.get("QT_SCALE_FACTOR", "1.0"))
        except ValueError:  # pragma: no cover
            return 1.0

    @Slot(result="QVariantMap")
    def snapshot(self) -> dict:
        """一次性取回全部平台事实（测试与"关于"页用）。"""
        return {
            "osName": self.osName,
            "osVersion": self.osVersion,
            "cpuArch": self.cpuArch,
            "kernelType": self.kernelType,
            "isMobile": self.isMobile,
            "hasTouchscreen": self.hasTouchscreen,
            "storagePath": self.storagePath,
            "devicePixelRatio": self.devicePixelRatio,
            "scaleFactor": self.scaleFactor,
        }

    # ── 外部输入消毒（0.16.2 B3 供应链门禁） ──────────────────────
    # QML 侧等价实现在 NovaUtils.sanitize（语义 1:1）；本段供 Python 驱动的
    # 字符串路径使用（MCP server / CLI / 存储回读）。注入面与裁定见 NovaUtils 头注释。

    _CONTROL_RE = re.compile(
        "[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F-\u009F"
        "\u200B-\u200D\u2028\u2029\uFEFF]"
    )
    _SAFE_URL_SCHEMES = ("http:", "https:", "qrc:", "file:")

    @Slot(str, result=str)
    def sanitizeText(self, text: str, maxLen: int = 0) -> str:
        """组合消毒：剥控制字符 → HTML 实体转义 →（可选）长度钳制。

        maxLen <= 0 时不钳制。外部文案入库/展示前的标准口径。
        """
        s = self.stripControlChars(text)
        s = self.escapeHtml(s)
        if maxLen and maxLen > 0 and len(s) > maxLen:
            s = s[:maxLen] + "…"
        return s

    @Slot(str, result=str)
    def escapeHtml(self, text: str) -> str:
        """HTML 实体转义（& 先行防二次转义；< > " ' 全覆盖）。"""
        if not text:
            return ""
        return (
            text.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace('"', "&quot;")
            .replace("'", "&#39;")
        )

    @Slot(str, result=str)
    def stripControlChars(self, text: str) -> str:
        """剥离 C0/C1 控制字符与零宽字符（保留 \t \n \r）。"""
        if not text:
            return ""
        return self._CONTROL_RE.sub("", text)

    @Slot(str, result=str)
    def sanitizeUrl(self, url: str) -> str:
        """URL scheme 白名单：http/https/qrc/file（含相对路径）；其余返回空串。"""
        if not url:
            return ""
        low = url.strip().lower()
        if low.startswith(self._SAFE_URL_SCHEMES) or low.startswith(("/", "#")):
            return url
        return ""

        # ── 焦点陷阱（a11y · Dialog Tab 循环，0.16.1） ──────────────────
    # 为什么必须走应用级事件过滤器：Tab/Backtab 在 activeFocusItem 的
    # QQuickItem::keyPressEvent C++ 默认实现中被消费（移动焦点并 accept），
    # 事件不冒泡，QML Keys（含 Keys.BeforeItem——它只对「所在 item 自己」前置）
    # 永远收不到（坑位 45）。过滤器在窗口级拦截，是唯一可靠断点。
    @Slot(QObject)
    def registerFocusTrap(self, trap: QObject) -> None:
        """注册焦点陷阱容器（QML Item）。

        必须强引用：QML→Python 的 QObject 参数 wrapper 是临时的（slot 返回即被 GC，
        weakref 立刻失效，坑位 45）；C++ 对象归 QML 引擎所有，销毁后调用抛 RuntimeError，
        由过滤器按僵尸清理。"""
        if trap is None:
            return
        for t in _TRAPS:
            if t is trap:
                return
        _TRAPS.append(trap)

    @Slot(result=int)
    def numTraps(self) -> int:
        """调试/测试：当前注册的陷阱数（含未清理僵尸）。"""
        return len(_TRAPS)

    @Slot(QObject)
    def unregisterFocusTrap(self, trap: QObject) -> None:
        """注销焦点陷阱（陷阱关闭时由 QML 侧调用）。"""
        if trap is None:
            return
        for t in list(_TRAPS):
            if t is trap:
                _TRAPS.remove(t)


def runtime_snapshot() -> dict:
    """无 QML 语境下的平台快照（单元测试/脚本用）。"""
    return NovaRuntime().snapshot()


# ══════════════════════════════════════════════════════════════════
# 输入模态广播（focus-visible）+ 焦点陷阱（Dialog Tab 循环）
# ══════════════════════════════════════════════════════════════════
_KB_EVENTS = (QEvent.Type.KeyPress, QEvent.Type.KeyRelease)
_POINTER_EVENTS = (QEvent.Type.MouseButtonPress, QEvent.Type.MouseButtonDblClick,
                   QEvent.Type.TouchBegin, QEvent.Type.Wheel)
_TRAPS: "list[QObject]" = []              # 存活的焦点陷阱容器（强引用 QML wrapper，见坑位 45）
_TAB_KEYS = (Qt.Key.Key_Tab, Qt.Key.Key_Backtab)


def _is_trap_ancestor(trap: QObject, item: QObject) -> bool:
    """item 是否位于陷阱容器内（沿 parent 链上溯）。"""
    p = item
    while p is not None:
        if p is trap:
            return True
        try:
            p = p.parent()
        except RuntimeError:  # pragma: no cover - 已析构
            return False
    return False


class _InputModalityFilter(QObject):
    """应用级事件过滤器：输入模态广播 + 焦点陷阱的 Tab 拦截。

    模态判定只做类型判断后立刻返回 False（不拦截事件），开销极小；
    焦点陷阱仅在存在注册容器时进入，逐个弱引用判活。
    """

    def eventFilter(self, obj: QObject, event: QEvent) -> bool:
        etype = event.type()
        if etype == QEvent.Type.KeyPress and _TRAPS:
            try:
                ev = event
                if ev.key() in _TAB_KEYS:
                    # 焦点命中判定交给 QML（trapHitTest）：win.property("activeFocusItem")
                    # 的 QQuickItem* 在 PySide 无 converter（坑位 45），Python 侧不可读。
                    back = (ev.key() == Qt.Key.Key_Backtab
                            or bool(ev.modifiers() & Qt.KeyboardModifier.ShiftModifier))
                    for trap in reversed(_TRAPS):
                        try:
                            # 可见性/焦点命中判定全在 QML（wrapper 静态类型 QObject，
                            # isVisible 等 QQuickItem 方法不可见，坑位 45）
                            if bool(trap.trapHitTest()) and bool(trap.trapNext(back)):
                                return True
                        except RuntimeError:
                            # 陷阱 C++ 对象已销毁（未走 unregister）：按僵尸清理
                            try:
                                _TRAPS.remove(trap)
                            except ValueError:
                                pass
                            continue
            except Exception:  # pragma: no cover - 陷阱链路兜底（不吞事件）
                pass
        if etype in _KB_EVENTS:
            _broadcast(True)
        elif etype in _POINTER_EVENTS:
            _broadcast(False)
        return False


def _broadcast(value: bool) -> None:
    global _KEYBOARD_MODE
    if _KEYBOARD_MODE == value:
        return
    _KEYBOARD_MODE = value
    for inst in list(_INSTANCES):
        try:
            inst._apply_keyboard_mode(value)
        except RuntimeError:  # pragma: no cover - 引擎已析构
            pass


def set_keyboard_mode(value: bool) -> None:
    """以「真实输入」语义设置全局模态（测试用；等价于发生一次键盘/鼠标输入）。"""
    _broadcast(bool(value))


def install_input_modality_filter() -> None:
    """安装输入模态事件过滤器（幂等）。无 GUI 应用实例时静默跳过。"""
    global _FILTER
    if _FILTER is not None:
        return
    app = QGuiApplication.instance()
    if app is None:  # pragma: no cover - 纯 QCoreApplication 场景
        return
    _FILTER = _InputModalityFilter(app)
    app.installEventFilter(_FILTER)
