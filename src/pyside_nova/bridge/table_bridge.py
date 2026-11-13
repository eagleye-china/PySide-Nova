# src/pyside_nova/bridge/table_bridge.py

import random

from PySide6.QtCore import Property, QObject, Signal


class TableBridge(QObject):
    rowsChanged = Signal()  # noqa: N815

    def __init__(self):
        super().__init__()
        self._rows = self._generate_data()

    def _generate_data(self):
        data = []
        for i in range(1, 5001):
            data.append({
                "id": i,
                "name": f"工业节点 - {i:03d}",
                "status": "异常" if i % 3 == 0 else ("待机" if i % 2 == 0 else "运行中"),
                "temp": f"{25 + random.random() * 20:.1f}",
                "pressure": f"{100 + random.random() * 50:.1f}",
                "time": f"2026-11-13 10:{i % 60:02d}:00"
            })
        return data

    @Property(list, notify=rowsChanged)
    def rows(self):
        return self._rows
