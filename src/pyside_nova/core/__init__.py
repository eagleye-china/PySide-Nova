"""
src/pyside_nova/core/__init__.py
/**
 * @created 2026-11-13 23:50:31
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */

core —— 线程与桥接基础设施（不依赖 QML，可单测）。
"""

from __future__ import annotations

from .bridge import NovaBridgeBase
from .worker import (
    NovaTask,
    NovaWorker,
    ThreadRunner,
    in_main_thread,
    run_on_main_thread,
)

__all__ = [
    "NovaBridgeBase",
    "NovaWorker",
    "NovaTask",
    "ThreadRunner",
    "in_main_thread",
    "run_on_main_thread",
]
