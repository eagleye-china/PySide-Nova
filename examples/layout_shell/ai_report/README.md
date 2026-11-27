# NovaAIReport · 铝电解智能报表 Showcase

NovaAIReport（第 21 组合根）的成品级独立演示。**主报表区真实装配 `NovaDataGrid`**，
Python 侧 `QAbstractTableModel` 数据管道 + TableView 真虚拟化；七槽业务语义全部在宿主侧
注入，Shell 只托管布局与受控信号，不持有任何报表状态。

## 运行

```bash
# 仓库根执行（PYTHONPATH=src 或已 pip install -e .）
python examples/layout_shell/ai_report/run.py

# 指定规模 / 种子 / 分页（确定性可复现）
python examples/layout_shell/ai_report/run.py --rows 1200 --page-size 20 --seed 20261128
```

窗口右上角「调参」面板默认收起（CC-8），可切换折叠双轨、显示分区、变体态、亮/暗主题。
窗口图标为 `app-aireport`（第 11 枚专属主题应用图标，hue 258° 仪表钢蓝）；
切到「专属」暗色态时 **Windows 原生标题栏同步变暗**，切回亮色态恢复。

## 图标 / 专属主题 / 标题栏（1.11.0）

- `run.py` 在 `init_nova()` 注册 qrc **之后** `setWindowIcon(QIcon(":/icons/app-aireport"))`。
- `main.qml` 的 `shell._signatureOn` 绑定 `win.themeMode === "signature"`，与其余 10 壳同构；
  第 11 套专属主题「仪表钢蓝 258°」见 `docs/prescript/GUIDE_COMPONENT_THEMES.md §2`。
- `signal darkChromeChanged(bool)` 在 `onThemeModeChanged` 与 `Component.onCompleted` 中 emit，
  由 `run.py::_sync_title_bar`（自包含 DWM helper，不依赖 nova-forge）同步原生标题栏；
  非 Windows no-op、无监听者无害。

## 架构（账实同源）

```
data.generate_rows()  ──>  NovaDataGridModel (reportTable)
                                  │
                                  ▼
                      NovaDataGridFilterProxy (reportFilter)
                                  │
                                  ▼
      NovaDataGridPagination ──> NovaDataGridPagedProxy (reportPaged)
                                  │
                                  ▼
                      NovaDataGrid.qml → NovaAIReport.reportSlot
```

`pipeline.inject()` 是**唯一注入口**：`run.py`、`scripts/audit_showcase.py`
（三态出图）、`scripts/audit_ceiling.py`（21/21 天花板机检）共用同一函数，
保证「演示态 = 验收态」。`ReportBridge` 只承载宿主统计、受控信号记录与人工
确认闸门状态；布局语义仍归 Shell。

## 七槽映射

| 槽位 | 注入内容 | 业务语义归属 |
|---|---|---|
| `benchmarkSlot` | 本厂值 / 行业基线 / 先进基线 / 差距 | 宿主 |
| `diagnosisSlot` | 归因卡片（极距偏低 / 热平衡越界） | 宿主 |
| `reportSlot` | **`NovaDataGrid` 真装配** + 申请审批 | 宿主 |
| `forecastSlot` | 2–8h 预测区间 + 模型新鲜度 | 宿主 |
| `querySlot` | 早报规则模板 / 过滤 / 问数按钮 | 宿主 |
| `approvalSlot` | 采纳 / 驳回（受控，不自动回写） | 宿主 |
| `overlaySlot` | 人工确认闸门浮层 | 宿主 |

Shell 侧只暴露 `diagnosisToggled` / `queryToggled` / `approvalRequested` 三信号，
宿主桥记录意图，**绝不反向写 Shell 状态**。

## 边界与坑位

- 库组件零手搓：状态徽标用 `cellDelegates` 委托，配色一律 `NovaTheme` 令牌；
  不新增主题令牌、不撞 `secondary|accent` 身份色。
- 坑位 70：目录层级可变，`run.py` / `pipeline.py` 以标志目录向上探测仓库根，
  不写死 `parents[n]`。
- 坑位 49：数据句柄与宿主桥在启动器内保持强引用；出图 / 机检脚本每 showcase
  独立进程并硬退出。
- 坑位 71：`visible` 绑上游属性，不绑自身 `height`。
- 语义边界：参数语义层、归因引擎、预测模型、NL2SQL、Agent 编排均**不入库**，
  本 demo 里只以静态文案 + 受控意图模拟呈现。

## 验收

```bash
python scripts/audit_showcase.py --name ai_report   # 三态装配态出图
python scripts/audit_ceiling.py                     # 21/21 六维天花板机检
```
