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

import sys
from pathlib import Path

from PySide6.QtCore import (
    Property,
    QObject,
    QSettings,
    QStandardPaths,
    QSysInfo,
    Slot,
)
from PySide6.QtGui import QInputDevice

__all__ = ["NovaRuntime", "runtime_snapshot"]


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
    """QML ``Nova.Runtime.NovaRuntime`` 单例：存储后端 + 平台探测。"""

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._os = _detect_os()
        self._settings: QSettings | None = None
        self._path = self._resolve_path()

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
        }


def runtime_snapshot() -> dict:
    """无 QML 语境下的平台快照（单元测试/脚本用）。"""
    return NovaRuntime().snapshot()
