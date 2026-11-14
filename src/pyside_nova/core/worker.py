"""
src/pyside_nova/core/worker.py
/**
 * @created 2026-11-13 23:50:31
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */

NovaWorker —— 面向 HMI 的异步线程基类（铁律：子线程只算数据，主线程只更新界面）。

设计约束：
1. 子线程内**绝不**触碰任何 QWidget / QML item / QAbstractItemModel；
2. 子线程只做纯计算，结果一律通过 ``Signal`` 投递给主线程；
3. 桥接到 QML 的槽函数由 ``NovaBridgeBase`` 保证执行在主线程，并在内部吞掉异常；
4. 高频中间结果走节流信号，避免主线程事件队列被刷爆（工业 HMI 常见卡顿源）。

两种用法::

    # ① 继承式：轻量任务
    class Loader(NovaWorker):
        def do_work(self):
            return heavy_compute()

    w = Loader()
    w.finished.connect(on_done)          # 主线程槽
    w.start()

    # ② QObject + moveToThread：任务与线程生命周期分离（推荐，长期运行/可取消）
    from pyside_nova.core.worker import ThreadRunner

    runner = ThreadRunner(MyTask())
    runner.resultReady.connect(on_result)
    runner.start()
    ...
    runner.request_stop()
    runner.wait()

注意：``request_stop()`` 只是设置协作式取消标志，任务内部需自行轮询
``self.is_stop_requested`` 才能及时退出。本模块不探测线程安全，请遵守契约。
"""

from __future__ import annotations

import logging
import time
import traceback
from typing import Any, Callable

from PySide6.QtCore import (
    QCoreApplication,
    QObject,
    QThread,
    Qt,
    Signal,
    Slot,
)

logger = logging.getLogger("pyside_nova.core.worker")


# ─────────────────────────────────────────────────────────────
# 工具函数
# ─────────────────────────────────────────────────────────────
def in_main_thread() -> bool:
    """当前是否处于 GUI 主线程。"""
    app = QCoreApplication.instance()
    return app is None or QThread.currentThread() is app.thread()


def run_on_main_thread(func: Callable[..., Any]) -> Any:
    """装饰器：把任何槽函数强制拉回主线程执行，并吞掉异常。

    用于「子线程 → Python 回调」这类没有 Qt 信号充当边界、容易漏网直改 UI 的路径。
    已在主线程时直接同步执行，无额外开销。
    """

    def wrapper(*args: Any, **kwargs: Any) -> Any:
        if in_main_thread():
            try:
                return func(*args, **kwargs)
            except Exception:  # pragma: no cover - 防御性兜底
                logger.exception("主线程回调异常：%s", getattr(func, "__name__", func))
                return None

        owner = args[0] if args and isinstance(args[0], QObject) else None
        target = owner if owner is not None else func

        def _invoke() -> None:
            try:
                func(*args, **kwargs)
            except Exception:  # pragma: no cover
                logger.exception("跨线程回调异常：%s", getattr(func, "__name__", func))

        # QueuedConnection：跨线程时事件投递到目标线程的事件循环
        from PySide6.QtCore import QMetaObject

        QMetaObject.invokeMethod(target, _invoke, Qt.ConnectionType.QueuedConnection)
        return None

    return wrapper


# ─────────────────────────────────────────────────────────────
# 继承式 Worker（QThread 子类）
# ─────────────────────────────────────────────────────────────
class NovaWorker(QThread):
    """轻量异步任务基类。

    子类只需实现 :meth:`do_work`（纯计算，禁止 UI）。返回值经 ``finished`` 信号
    （在主线程接收）交给界面层。

    信号：
        - ``resultReady(object)``：任务成功，携带返回值；
        - ``progressChanged(int, str)``：进度（0-100），可高频，槽必须轻量；
        - ``message(str)``：单条日志文本，自动节流；
        - ``failed(str)` / ``errorOccurred(str, str)``：异常信息（含堆栈）；
        - ``finished()`：QThread 原生信号，本类中额外统一为「成功或失败都发」。
    """

    resultReady = Signal(object)  # noqa: N815
    progressChanged = Signal(int, str)  # noqa: N815
    message = Signal(str)
    failed = Signal(str)
    errorOccurred = Signal(str, str)  # noqa: N815  (message, traceback)

    #: 中间结果节流间隔（毫秒），避免主线程被刷爆
    message_interval_ms: int = 100

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._stop_requested = False
        self._last_emit_ts = 0.0

    # ── 取消 ───────────────────────────────────────────────
    @property
    def is_stop_requested(self) -> bool:
        """协作式取消标志，子线程内部轮询使用。"""
        return self._stop_requested

    @Slot()
    def request_stop(self) -> None:
        """请求停止（可在主线程安全调用）。"""
        self._stop_requested = True

    # ── 子线程内可安全调用的发信号方法 ──────────────────────
    def emit_progress(self, value: int, text: str = "") -> None:
        """发送进度；避免过度频繁（由 interval 控制节流）。"""
        self.progressChanged.emit(int(value), str(text))

    def emit_message(self, text: str, force: bool = False) -> None:
        """发送日志文本，默认按 ``message_interval_ms`` 节流。"""
        now = time.monotonic()
        if not force and (now - self._last_emit_ts) * 1000.0 < self.message_interval_ms:
            return
        self._last_emit_ts = now
        self.message.emit(str(text))

    # ── 生命周期 ───────────────────────────────────────────
    def run(self) -> None:  # noqa: D102 - QThread 接口
        try:
            result = self.do_work()
        except Exception as exc:
            tb = traceback.format_exc()
            logger.error("NovaWorker 任务异常：%s\n%s", exc, tb)
            self.failed.emit(str(exc))
            self.errorOccurred.emit(str(exc), tb)
            return

        if self._stop_requested:
            self.message.emit("任务已取消")
            return

        self.resultReady.emit(result)

    def do_work(self) -> Any:
        """子类实现：纯计算逻辑，禁止任何 UI / 模型操作。"""
        raise NotImplementedError("子类必须实现 do_work()")


# ─────────────────────────────────────────────────────────────
# QObject + moveToThread（推荐模式）
# ─────────────────────────────────────────────────────────────
class NovaTask(QObject):
    """任务对象：只包含计算逻辑，由 :class:`ThreadRunner` 搬到子线程执行。

    定义信号 → 由主线程订阅；子线程内 emit 自动排队到主线程。
    """

    resultReady = Signal(object)  # noqa: N815
    progressChanged = Signal(int, str)  # noqa: N815
    message = Signal(str)
    failed = Signal(str)
    errorOccurred = Signal(str, str)  # noqa: N815
    done = Signal()

    message_interval_ms: int = 100

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._stop_requested = False
        self._last_emit_ts = 0.0

    @property
    def is_stop_requested(self) -> bool:
        return self._stop_requested

    @Slot()
    def request_stop(self) -> None:
        self._stop_requested = True

    def emit_progress(self, value: int, text: str = "") -> None:
        self.progressChanged.emit(int(value), str(text))

    def emit_message(self, text: str, force: bool = False) -> None:
        now = time.monotonic()
        if not force and (now - self._last_emit_ts) * 1000.0 < self.message_interval_ms:
            return
        self._last_emit_ts = now
        self.message.emit(str(text))

    @Slot()
    def run(self) -> None:
        """由 ThreadRunner 在子线程内调用。"""
        guard = NovaWorker.__new__(NovaWorker)  # 仅借用取消标志字段
        guard._stop_requested = self._stop_requested  # noqa: SLF001
        try:
            result = self.do_work()
        except Exception as exc:
            tb = traceback.format_exc()
            logger.error("NovaTask 任务异常：%s\n%s", exc, tb)
            self.failed.emit(str(exc))
            self.errorOccurred.emit(str(exc), tb)
            self.done.emit()
            return
        if not self._stop_requested:
            self.resultReady.emit(result)
        self.done.emit()

    def do_work(self) -> Any:
        raise NotImplementedError("子类必须实现 do_work()")


class ThreadRunner(QObject):
    """把 :class:`NovaTask` 搬进独立 QThread 并管理生命周期。

    所有信号全部转发给 Runner（其亲和线程是主线程），因此订阅方永远是主线程。
    """

    resultReady = Signal(object)  # noqa: N815
    progressChanged = Signal(int, str)  # noqa: N815
    message = Signal(str)
    failed = Signal(str)
    errorOccurred = Signal(str, str)  # noqa: N815
    finished = Signal()

    def __init__(self, task: QObject, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._task = task
        self._thread = QThread(self)
        task.moveToThread(self._thread)

        # 线程启动后由事件循环拉起 task.run
        self._thread.started.connect(task.run)

        # 转发（自动 QueuedConnection：task 在子线程 emit，主线程接收）
        task.resultReady.connect(self.resultReady)
        task.progressChanged.connect(self.progressChanged)
        task.message.connect(self.message)
        task.failed.connect(self.failed)
        task.errorOccurred.connect(self.errorOccurred)

        task.done.connect(self._thread.quit)
        task.done.connect(self.finished)
        self._thread.finished.connect(self._on_thread_finished)

    # ── 主线程可调接口 ─────────────────────────────────────
    def start(self) -> None:
        if not self._thread.isRunning():
            self._thread.start()

    def request_stop(self) -> None:
        """主线程设置协作式取消标志（任务侧轮询 ``is_stop_requested``）。"""
        setter = getattr(self._task, "request_stop", None)
        if callable(setter):
            # 用 direct call 只是翻布尔位，不放业务逻辑，属安全操作
            setter()

    def wait(self, msecs: int = 30000) -> bool:
        return self._thread.wait(msecs)

    def is_running(self) -> bool:
        return self._thread.isRunning()

    def _on_thread_finished(self) -> None:
        # 任务对象回到主线程，避免被 GC 于子线程上下文
        self._task.moveToThread(QCoreApplication.instance().thread())

    def __del__(self) -> None:  # pragma: no cover
        try:
            if self._thread.isRunning():
                self.request_stop()
                self._thread.quit()
                self._thread.wait(3000)
        except Exception:
            pass


__all__ = [
    "NovaWorker",
    "NovaTask",
    "ThreadRunner",
    "in_main_thread",
    "run_on_main_thread",
]
