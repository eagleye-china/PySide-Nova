"""
src/pyside_nova/core/bridge.py
/**
 * @created 2026-11-13 23:50:31
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */

NovaBridgeBase —— 异常安全的 QML 桥接基类（主线程 UI 收口点）。

铁律落地：
1. 本类所有 ``@Slot`` 均由 QML 调用，天然运行在主线程；
2. 子线程只通过信号连接到本类槽函数，**永不**直接持有 QML item 引用；
3. 所有槽函数由 ``_safe_slot`` 包裹，异常只记日志、不炸 QML 引擎；
4. 提供给 QML 的“更新界面”入口只走 ``Property`` 变更通知，不做隐式重入。

典型用法::

    from pyside_nova.core.bridge import NovaBridgeBase
    from pyside_nova.core.worker import NovaWorker

    class DeviceBridge(NovaBridgeBase):
        statusChanged = Signal(str)

        def __init__(self):
            super().__init__()
            self._status = "idle"

        @Property(str, notify=statusChanged)
        def status(self):
            return self._status

        @Slot()
        def startPoll(self):
            w = NovaWorker()
            w.finished.connect(self._on_done)     # 主线程槽
            w.start()

        def _on_done(self):
            self.set_status("ready")
"""

from __future__ import annotations

import functools
import logging
from typing import Any, Callable

from PySide6.QtCore import QObject, Slot

logger = logging.getLogger("pyside_nova.core.bridge")


class NovaBridgeBase(QObject):
    """QML ↔ Python 桥接基类：强制主线程 + 异常吞噬。"""

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)

    # ── 安全槽装饰器 ───────────────────────────────────────
    @staticmethod
    def safe_slot(*arg_types: type, **kwargs: Any) -> Callable[[Callable[..., Any]], Callable[..., Any]]:
        """把普通方法包装成「不抛异常」的 QML 槽。

        用法::

            @NovaBridgeBase.safe_slot()
            def refresh(self): ...

            @NovaBridgeBase.safe_slot(str)
            def setStatus(self, text): ...
        """
        result_type = kwargs.get("result", "QVariant")
        name = kwargs.get("name")

        def decorator(func: Callable[..., Any]) -> Callable[..., Any]:
            @functools.wraps(func)
            def wrapper(self: NovaBridgeBase, *args: Any, **kw: Any) -> Any:
                try:
                    return func(self, *args, **kw)
                except Exception:
                    logger.exception("桥接槽异常：%s", func.__name__)
                    return None

            slot_kwargs: dict[str, Any] = {"result": result_type}
            if name:
                slot_kwargs["name"] = name
            return Slot(*arg_types, **slot_kwargs)(wrapper)

        return decorator

    # ── 主线程断言 ─────────────────────────────────────────
    def assert_main_thread(self, where: str = "") -> bool:
        """调试用：断言当前在主线程，返回布尔结果并告警。"""
        from .worker import in_main_thread

        ok = in_main_thread()
        if not ok:
            logger.error("违规：%s 在子线程操作界面！请改为信号投递到主线程。", where or type(self).__name__)
        return ok


__all__ = ["NovaBridgeBase"]
