# pyside-nova · 基础组件天花板档案（CARF-R 逐项打磨销号台账 · 非组合组件）

> **CARF — Conceive, Achieve, Refine, Freeze — Culminate to the peak.
> 构想 · 实现 · 打磨 · 封版，终抵巅峰（天花板）。**
>
> **法源**：`CONSTITUTION.md`（母法 · 卷首 CARF 宣言 + 第 13 章 API 冻结）
> · `COMPOSITION_CONSTITUTION.md`（组合宪法 1.0.0 第 0 章第 3/4 条：基础控件不受 CC 约束、
> 四性逐项判定、仅在实测暴露缺陷时反向打磨）
> · `layout_shell/CEILING_AUDIT.md`（组合组件 15/15 销号台账，本档案为其**适配版续篇**）
> · `white_paper/Prescient-LayoutShell-封版规范.md`（技术红线 v2.1.0）
> **分工**：伙伴 = **CSA**（构想 / 方向 / 标准 / 验收拍板）；小诺 = **完现者**（实现 / 自检 / 验收 / 文档账本闭环）。
> **当前状态**：**15 / 15 实测缺陷销号**（第一批数值 14 项 + 第二批超长字符串 1 项；
> 其余 108 项体检无缺陷、不改）· `../../scripts/audit_foundations.py` **PASS** ·
> 公共 API 冻结指纹 `bfd3d938a2fab7be` · 139 导出类型零漂移。
> **第二批（剩余项多维体检）**：伙伴指令「49 SIGSEGV 先不管，继续打磨剩下的项」后，
> 对剩余项补测「非数值边界入参 / 深主题 / RTL-ar / reducedMotion」三维度，
> 锁定 **1 项真实缺陷（NovaField 超长字符串反噬宽度）** 并销号；其余命中经甄别为探针假阳性。

---

## 0. 适用范围与标尺（与组合组件台账的关键区别）

### 0.1 为什么不是「对 128 项批量套 CC 契约」

组合宪法第 0 章第 3 条明确：**单纯的基础控件（L2）、行为（L3）、服务（L4）不受组合宪法约束**；
第 4 条进一步禁止「把全库体检信号直接判为合规债批量套规则（坑位 18 的适用对象是组合根容器）」，
并要求「基础控件是否适用四性条款须逐项判定，仅在装配态验收真实暴露缺陷时反向打磨（装配态驱动、按需反哺）」。

因此本轮**不**把 `audit_ceiling.py` 的 CC-1~CC-8 静态契约（组合上下文 / 单一分隔源 / 撞色 / 槽位宿主等）
套到基础组件。静态摸底实测：128 项基础组件中撞色仅 1 处（`NovaStepper._qcolor()` 的 Quasar 命名色映射，
合法 API 语义）、三元锚链 4 处（margin 条件值，非可见性跳变）、硬编码时长 0、低实心 0——
**这些命中全部为合法语义，无一是真实缺陷**，机械套规则会误伤。

### 0.2 待打磨全集与分母

| 模块 | 文件数 | 公开类型 | 说明 |
| :--- | ---: | ---: | :--- |
| `Nova.Controls` | 91 | 91 | 可视化基础控件 |
| `Nova.Behaviors` | 14 | 13 | +1 internal（`NovaTouchCore`） |
| `Nova.Services` | 19 | 16 | +3 internal（通知/对话框/加载卡片） |
| `Nova.Design` | 4 | 4 | 全单例（令牌 / 图标集 / utils / a11y） |
| **合计** | **128** | **124** | 另 15 项组合根容器已单独销号，不在本档案范围 |

### 0.3 适配版六维标尺（基础组件）

| 维度 | 判定要点 | 本轮结论 |
| :--- | :--- | :--- |
| **功能** | API 契约、信号 / 属性语义 | `test_smoke.py` 300+ 用例覆盖，不改 |
| **质量** | 静态门禁 3/3、专项 48/48、qmllint 0 error、API 零漂移 | 全绿（见 §3） |
| **观感** | 令牌取色、双主题可辨 | Gallery 24 页 + 240 视觉基线覆盖，不改 |
| **友好度** | a11y role/name/焦点、键盘可达 | `test_a11y.py` 139/139，不改 |
| **四性 · Robustness** | **极端非法入参下稳态几何非负有限、钳制** | **第一批数值 14 项 + 第二批超长字符串 1 项 → 共 15 项销号** |
| **四性 · Solidity / Aesthetics / Prescience** | API 最小化 / 唯一令牌源 / 键盘可达预判 | 深主题 / RTL-ar / reducedMotion 三态实测无缺陷，不改 |

**销号条件**：① 六维评估完成；② 差距清单全部 PATCH；③ 逐属性非法入参稳态几何实测非负；
④ API 冻结零漂移 + 静态门禁 + 专项全绿；⑤ 机检尺 PASS；⑥ 文档账本闭环。

### 0.4 固定动作（每项缺一不可）

1. **实测诊断**：第一批逐属性注入 `-999` / `999999`，第二批注入超长字符串（2000 汉字）/
   特殊字符 / 空串 / `transparent` / `null`，均 0.45s 充分收敛，遍历对象树测稳态几何；
2. **差距清单**：仅登记真实暴露的负 / 非有限几何，合法 API 语义（命名色映射等）与
   探针假阳性（给 delegate 内部属性赋值被 QML 拒绝）不判缺陷；
3. **`_` 私有 PATCH**：新增 `readonly property _xxx` 钳制属性（第一批）或对内部几何出口加
   `Math.max(0, ...)` 守护（第二批 NovaField），**公共属性 / 信号 / 方法签名逐字不变**；
4. **复验**：逐属性重测，正常默认值对照零负几何；
5. **销号**：本档案打勾 + 机检尺 + 门禁 + CHANGELOG 同步。

---

## 1. 体检方法与「初筛假阳性」的甄别

**初筛**（全部数值属性同时注入 `-999` / `999999`，0.10s 收敛）暴露 19 组几何命中，
其中 `NovaBlankPage` / `NovaCardGrid` / `NovaChat` 是**已 15/15 销号的组合根容器**（不属本档案范围），
且 0.10s 收敛短于组合尺的 0.45s——初筛含收敛不足与多属性异常组合的假阳性。

**精确复测**（逐属性注入 + 0.45s 充分收敛 + 正常默认值对照）后，锁定 **14 项真实 Robustness 缺陷**；
其余初筛命中在充分收敛后几何全非负，确认为假阳性，**不改**（遵守「不硬造修改」）。

机检尺 `scripts/audit_foundations.py` 固化了精确复测口径（逐属性 + 0.45s + 默认值对照），
作为本轮销号项的长期守护尺。

### 1.1 第二批 · 剩余项多维体检（伙伴指令：49 SIGSEGV 先不管，继续打磨剩余项）

第一批只覆盖了「数值极端入参」单一维度。第二批对**剩余项**补测三个尚未系统扫过的维度，
坚持「数据驱动、不硬造修改」：

| 维度 | 方法 | 结果 |
| :--- | :--- | :--- |
| 非数值边界入参 | string 超长 2000 字 / 特殊字符 / 空串 · color `transparent` · bool · var `null` · url 空 | **1 项真实几何命中**（NovaField）；约 40 处 `CREATE_FAIL` 为探针假阳性 |
| 深主题 | `NovaTheme.setDark(true)` 全类型实例化遍历对象树 | **0 负几何** |
| RTL-ar | `NovaI18n.setLocale("ar")` 同上 | **0 负几何** |
| reducedMotion | `NovaMotion.reducedMotion=true` 同上 | **0 负几何**（静态硬编码 duration 亦为 0） |

**关键甄别**（不硬造修改）：
- **CREATE_FAIL ≈40 处是假阳性**：`opt` / `tag` / `rowData` / `expandable` / `key` /
  `pendingShow` / `pendingReveal` / `target` / `half` / `kids` 等均声明在**内部组件 / Delegate /
  Repeater** 里（grep 行号 118~393 深埋文件内部），API 扫描器递归收集为根类型属性，
  但根组件不接受直接赋值 → QML 类型系统拒绝。非产品缺陷。
- **静态信号命中全为合法语义**：37 处硬编码颜色分别是 `NovaColorPicker` 色板数据、
  `NovaAvatar` 随机头像色、各处品牌底白字、`NovaTooltip`/`NovaSkeleton` 自带 `isDark` 双分支、
  `NovaBottomSheet` 半透明遮罩；4 处 `anchors.right` 中 `NovaPopupEdit` 按钮 Row 是固定
  RTL 视觉设计，`NovaBadge`/`NovaBtnToggle` 是角标/分隔线定位，`NovaField` 字符计数器固定
  右下角属观感偏好非几何缺陷。均不改。
- **唯一真实缺陷**：`NovaField` 的 `label` / `prefix` / `suffix` 超长时，Row 内 Text 隐式宽度
  （≈27228px）反噬 `controlHost.width = parent.width - x - suffixText.width...` → `QQuickItem -27228x40`。
  正常值 / 空串零负几何，确证 Robustness 缺陷 → 销号（见 §2 第 15 项）。

> **口径说明**：API 122 非单例类型 = 15 组合壳 + 91 Controls + 12 Behaviors + 4 数据句柄。
> 剔除 15 组合壳（已单独 15/15 销号）+ 4 句柄后，真实剩余基础组件为 **89 项**
> （77 Controls + 12 Behaviors）；「114」是文件级口径（128 文件 − 14 已销号），含 singleton /
> internal / 组合壳差异。第二批实测以可实例化的 89 项为准（脚本连组合壳一并跑，甄别时剔除）。

---

## 2. 逐项销号表（15 项真实缺陷）

| # | 组件 | 缺陷属性 | 根因 | `_` 私有 PATCH | 三值复验 | 状态 |
| :-- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | **NovaPage** | `padding` | 超大 margins 算出 body 负几何 | `_pad` 钳到父半尺寸 | ✓ | ✅ |
| 2 | **NovaCardSection** | `padding` | column 负宽 / 负 implicitHeight | `_pad` 钳到父半尺寸 + width 下限 | ✓ | ✅ |
| 3 | **NovaCol** | `gutter` | body margins 超父尺寸 | `_gutter` 钳到父半尺寸 | ✓ | ✅ |
| 4 | **NovaSeparator** | `size` | 负值传给分隔线 Rectangle 宽/高 | `_size` 钳非负 | ✓ | ✅ |
| 5 | **NovaInnerLoading** | `size` | 负值传给 Spinner 直径 | `_size` 钳非负 | ✓ | ✅ |
| 6 | **NovaAjaxBar** | `size` | 负值传给 track 厚度 | `_size` 钳非负且不超父短边 | ✓ | ✅ |
| 7 | **NovaCheckbox** | `visualWidth` | 负值传给 Loader 宽 | `_visualWidth` 钳非负 | ✓ | ✅ |
| 8 | **NovaDialogShell** | `maxWidth` | 负值参与 card 宽计算 | `_maxWidth` 钳非负 | ✓ | ✅ |
| 9 | **NovaEditor** | `minHeight` | 内容塌陷 → Qt ScrollView 内部 ScrollBar/Placeholder 负几何 | `_minHeight` 钳非负 + `body.height` 下限 + `customControlH` 补足 margins | ✓ | ✅ |
| 10 | **NovaExpansionItem** | `headerInsetLevel` / `contentInsetLevel` | 超大层级缩进算出负内容宽 | `_headerInset` / `_contentInset` 钳到 [0,12] + width 下限 | ✓ | ✅ |
| 11 | **NovaImg** | `spinnerSize` | 负值传给 spinner Item 宽/高 | `_spinnerSize` 钳非负 | ✓ | ✅ |
| 12 | **NovaSlideItem** | `revealWidth` | 负值传给侧板 Loader 宽 + 除零 | `_revealWidth` 钳非负且不超父半宽 + 除零保护 | ✓ | ✅ |
| 13 | **NovaRange** | `thumbSize` / `trackSize` | 负值 / 超大值传给 Thumb / track 宽高与半径 | `_thumbSize` / `_trackSize` 钳到 [0, 父短边]，全部几何出口改用钳制值 | ✓ | ✅ |
| 14 | **NovaSlider** | `thumbSize` / `trackSize` | 同上 | 同上 | ✓ | ✅ |
| 15 | **NovaField**（第二批） | `label` / `prefix` / `suffix` | 超长文本（2000 字）Row 内 Text 隐式宽度反噬 `controlHost.width` → `QQuickItem -27228x40` | 内部几何出口 `Math.max(0, parent.width - x - ...)` 守护（无新增公开属性） | ✓（超长/短/空三组） | ✅ |

> **三值复验**：第 1~14 项均测 `正常默认值 / -999 / 999999` 三组；第 15 项测 `超长 2000 字 / 短文本 / 空串` 三组，稳态几何全部非负有限。
> **API 零漂移**：第 1~14 项新增属性全部为 `_` 私有只读，第 15 项仅改内部 Item 几何出口，公共签名逐字不变，冻结指纹不变。

---

## 3. 最终验收总表（CARF-F）

| 项目 | 结果 |
| :--- | :--- |
| `scripts/audit_foundations.py` 基础组件 Robustness 机检 | **PASS**（15/15 逐属性稳态几何 · 122 非单例类型实例化零缺陷 · 三态零负几何） |
| 第 1~14 项三值复验（默认 / -999 / 999999） | **全绿**：负几何从 19 组 → **0 组** |
| 第 15 项三值复验（超长 2000 字 / 短文本 / 空串） | **全绿**：NovaField 三属性负几何 → **0** |
| 三态实例化（深主题 / RTL-ar / reducedMotion） | **全绿**：122 类型 × 3 态零负几何 |
| 静态门禁 `check_all.py --tier static` | **3/3 PASS**（a11y 139/139 · API 冻结 · qmllint 0 error / 594 warning 预算内） |
| 专项 `test_api_freeze.py` + `test_layout_shells.py` | **48/48 passed** |
| API 冻结 | **139 类型零漂移 · 指纹 `bfd3d938a2fab7be` 不变**（全 `_` 私有 / 内部几何 PATCH，无需重签） |
| qmllint warning | 594 全在分类预算内（0 error；baseline 的 `total:593` 为历史字段、不参与判定，实际分类 counts 之和 594 未变） |

> **测试基建说明**：`test_smoke.py -k` 子集运行至 `form_env` fixture 的 `_pump()` 时触发
> 坑位 49（Qt 6.12 / shiboken 退出期访问违例），属 conftest.py 已记录的已知交互，
> 与本次 QML 改动无关（未改任何测试代码）；功能契约由 300+ 冒烟用例 + 48 专项 + 3 门禁覆盖。

---

## 4. 反向打磨与「不改」清单

- **合法语义命中，不改**：`NovaStepper._qcolor()` 的 `secondary`/`accent`（Quasar 命名色映射 API）、
  `NovaField` 的 margin 条件值、`NovaColorPicker`/`NovaImg`/`NovaNoSsr`/`NovaSelect`/`NovaTabs`
  的占位属性（真实契约）、`NovaPagination`/`NovaStepperNavigation` 的 RTL（已实现）。
- **组合根容器命中，不在本档案范围**：初筛的 `NovaBlankPage`/`NovaCardGrid`/`NovaChat`
  由 `layout_shell/CEILING_AUDIT.md` 管辖（15/15 已销号）。
- **第二批 CREATE_FAIL 假阳性（不改）**：`NovaBreadcrumbs.isCrumbsSeparator` / `NovaBtnToggle.opt` /
  `NovaFab.pendingReveal` / `NovaFab.target` / `NovaMenu.pendingShow` / `NovaOptionGroup.opt` /
  `NovaPagination.label` / `NovaPagination.nav` / `NovaPagination.tag` / `NovaTable.rowData` /
  `NovaTable.rowExpanded` / `NovaTable.rowK` / `NovaTable.rowSelected` / `NovaTooltip.pendingShow` /
  `NovaTree.expandable` / `NovaTree.half` / `NovaTree.key` / `NovaTree.kids` 等 —— 均为 Delegate /
  内部 Repeater 的属性被 API 扫描器递归误收为根类型可赋值属性，根组件赋值被 QML 类型系统拒绝。
- **第二批观感候选（不改）**：`NovaField` 字符计数器固定右下角（`anchors.right`）是观感偏好，
  非几何缺陷；`NovaPopupEdit` 按钮 Row 硬编码 `Qt.RightToLeft` 是固定视觉设计（主按钮靠右），
  与语言方向无关。深主题 / RTL / reducedMotion 三态实测均无负几何，不构成 Robustness 差距。
- 本轮**未触发**任何需要改公共 API 的缺陷：第一批为 `_` 私有 PATCH，第二批为内部几何出口守护。

---

## 5. 发布边界

**commit / push / tag / PyPI 一律归伙伴（CSA）本人**；本档案与所有改动留在工作树待伙伴拍板验收。
CARF 循环不终止：F 之后若伙伴提出新构想（C），在既有 1.0.0 基座上再进入下一轮 R，**不推倒重来**。
