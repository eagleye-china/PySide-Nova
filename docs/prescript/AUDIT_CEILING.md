# pyside-nova · 组件天花板档案（CARF-R 逐项打磨销号台账）

> **CARF — Conceive, Achieve, Refine, Freeze — Culminate to the peak.
> 构想 · 实现 · 打磨 · 封版，终抵巅峰（天花板）。**
>
> **法源**：`../CONSTITUTION.md`（母法 · 卷首 CARF 宣言 + 第 13 章 API 冻结）
> · `../COMPOSITION_CONSTITUTION.md`（组合宪法 **1.0.0**，第 0 章第 5 条 + 第 9 章 CC-1~CC-8）
> · `../prescript/SPEC_FREEZE.md`（技术红线 **v2.1.0**）
> **分工**（伙伴确立）：伙伴 = **CSA**（构想 / 方向 / 标准 / 验收拍板）；小诺 = **完现者**（实现 / 自检 / 验收 / 文档账本闭环）。
> **节奏**：**优先组合组件**；组合打磨中若暴露单个组件问题，再反向打磨该单个组件（装配态驱动、按需反哺）；
> 不推倒重来、不批量扫荡、一次一项或同族一组、逐项验收销号。
> **当前状态**：**20 / 20 已销号**（15 项 GA + 1.2.0 新增 5 项增量组合根）
> · `../../scripts/audit_ceiling.py` **20/20 PASS** · 60 张三态装配图全通过
> · 公共 API 冻结指纹 `4f882374ad52262b`（1.2.0 整批单次重签）· 144 导出类型
> · 包版本 **1.2.0**（15 项 GA 签名零改动 + 5 项增量；发布边界归 CSA）。

---

## 0. CARF 宣言与全量打磨节奏

### 0.1 宣言在本档案的角色

本档案是 **CARF-R（Refine 打磨）阶段的活台账**：每一项销号即一次
「六维评估 → 差距清单 → `_` 私有 PATCH → 装配态三态出图 → 机检 → 销号」的完整 R 循环；
全部销号后进入 **CARF-F（Freeze 封版）**——API 冻结零漂移 + 宪法 / CHANGELOG / 权威清单 /
账本 / AI 离线副本闭环，发布边界归 CSA。CARF 循环往复，但**不推倒重来、不批量扫荡**：
F 之后可回到 C 复评（本轮批次 1~2 四项即按 CARF 口径复评），每轮 R 都在既有基座上再优化。

### 0.2 节奏（伙伴授权「15 项组合组件全部打磨一遍，你自己定节奏」，小诺按语义分类分批）

| 批次 | 类别 | 组合根容器（按销号顺序） | 项数 | 变体态审计重点 | 状态 |
| :--- | :--- | :--- | :---: | :--- | :---: |
| 批次 1 | AI 对话主窗口 | NovaChat | 1 | 折叠三态 | ✅ 已销 |
| 批次 2 | 多端根壳 | NovaDesktop · NovaMobile · NovaFlexLayout | 3 | 三栏收起 / 大安全区 / 两栏变体 | ✅ 已销 |
| 批次 3 | 主导航壳 | NovaSidebar → NovaTopNavigation → NovaDualSide | 3 | 侧栏折叠 / 下拉展开 / 双侧收起 | ✅ 已销 |
| 批次 4 | 多栏工作台壳 | NovaTabShell → NovaThreeColumn → NovaCompare → NovaCardGrid | 4 | 标签栏收起 / 三栏折叠 / 中缝 / 列数变化 | ✅ 已销 |
| 批次 5 | 浮层容器壳 | NovaModal → NovaDrawerPanel | 2 | 关闭态 / 抽屉对侧 | ✅ 已销 |
| 批次 6 | 极简独立页壳 | NovaSetupWizard → NovaBlankPage | 2 | 步骤跳转 / 阅读栏宽度 | ✅ 已销 |
| **CARF 复评** | 全量机检 | 批次 1~2 四项统一 `variantMode` + **15/15 统一机检表** | — | 12 张既有图扩为 **45 张** | ✅ 已销 |

### 0.3 每项销号的固定动作（缺一不可）

1. **六维评估**：功能 / 质量 / 观感 / 友好度 / 四性，逐条列差距清单；
2. **CC-1~CC-8 迁移**：组合上下文唯一密度源、单一分隔源、主色系抽象几何（禁止仿交互控件）、
   层级色阶、栏高归零 + 恒定锚链 + 共用 `_dur`/`_ease`、槽位宿主铺满且注入顶层
   `anchors.fill: parent`、装配态验收、showcase 纪律；**全为 `_` 私有 PATCH，公共 API 逐字不变**；
3. **成品级 showcase**：真实业务内容注入、调参面板默认收起、纯几何图标（零字体依赖）、
   统一暴露 `variantMode` 供三态出图；
4. **三态出图**：浅色 / 深色 / 变体态真实引擎渲染，`docs/screenshots/<name>_showcase_*.png`；
5. **机检**：`../../scripts/audit_ceiling.py` 全量扫描（静态 CC 契约 / 15 组件实例化 / 15 showcase
   + Gallery / 每项 3 组极端非法入参稳态几何 / RTL / reducedMotion / 文档断链），
   外加静态门禁、专项、qmllint、API 冻结零漂移；
6. **销号**：本档案进度表打勾 + 批次记录 + 宪法 / CHANGELOG / 账本 / AI 生成物同步。

> **反向打磨纪律**：仅在装配态验收真实暴露某**基础组件**缺陷时，才反向打磨该单个组件，
> 并记录触发点；不为凑流程硬造修改。本轮**未触发任何 Controls 基础组件反向修改**，
> 两次组件内修复均落在组合根容器自身（见 §7）。

---

## 1. 评估标尺（六维 + CC 契约）

每项组合根容器须同时满足：

| 维度 | 判定要点 |
| :--- | :--- |
| **功能** | 槽位契约完整、受控信号只 emit 不自写宿主状态、断点 / RTL / 主题联动生效 |
| **质量** | 静态门禁 3/3、专项 48/48、qmllint 0 error、非法入参稳态几何非负、API 零漂移 |
| **观感** | 密度栅格统一、层级靠表面色阶、无重复分隔线与撞色调试线、双主题实心业务注入下身份可辨 |
| **友好度** | 无「看着能点却不能点」的仿交互控件、真实交互位有 hover / 点击反馈、空态由业务注入承担 |
| **四性** | Robustness（钳制 / 极端窗口 / RTL / reducedMotion）· Solidity（API 最小化 / 依赖定向）· Aesthetics（唯一令牌源 / 动效同步 / 身份差异化）· Prescience（安全边距 / 键盘可达 / 主题预判） |

**CC-1~CC-8 逐条检查**：组合上下文唯一密度源 / 单一分隔源 / 装饰预算与禁止仿交互控件 / 层级色阶 / 动效同步与恒定锚链 / 槽位内容基线（`anchors.fill: parent`）/ 装配态验收 / 参考实现纪律。

**销号条件**（缺一不可）：① 六维评估完成；② 差距清单全部 PATCH 销号；③ 浅 / 深 / 变体**三态真实引擎渲染出图审计**；④ 极端非法入参 + RTL + reducedMotion 实测；⑤ 宪法 / CHANGELOG / 权威清单 / 账本 / AI 生成物同步；⑥ `audit_ceiling.py` 机检 PASS；⑦ 交一份「天花板档案」给伙伴验收。

---

## 2. 复盘：为什么「单个封版组件组合到一起就掉链子」

| 层 | 缺什么 | 实锤 |
| :--- | :--- | :--- |
| **机制** | **L1 组合上下文层**：`NovaTheme` 是 L0 令牌、业务注入是 L2，中间没有装配契约。Quasar 靠 CSS 变量 + `QItem/QList/QCard` 组合惯例隐式提供密度 / 层级 / 动效 / 尺寸协商，QML 必须显式建模 | 六轨各取各的 `spacingM`，`NovaPage` padding + Shell padding + 装饰 margins **三层叠加** |
| **架构** | **槽位只保证「放得进」，不保证「铺得开」**：`property alias xxxSlot: _host.data` 注入的顶层 `Item` 默认 **0×0**，内部 anchors 算出 `-24` / `-48` 负宽高被裁掉 | 对象树打印确认：这是**「中央永远空板」的真因**，不是内容没写 |
| **规范** | **只有单组件验收，没有装配态验收** | 15 项各自四性全 PASS，六轨一拼：同边界 3~4 层线、青橙撞色、20+ 仿交互控件、调参台占着详情栏 |

**两条同等重要**：`secondary` 青 / `accent` 橙与 `primary` 蓝同屏撞色；圆钮 / 搜索胶囊 / 图标方块 / 三点菜单 / 分段 tab **长得能点却不能点**（直接砸「友好度」天花板）；折叠锚链用 `sep.visible ? ...` 三元切换，折叠瞬间布局跳变。

> 以上复盘已固化入宪（0.9.0 第 9 章）、封版规范（v2.1.0 §2.3 / §8.3）、CHANGELOG、权威清单与工作区账本；本档案为逐项销号的活台账。

---

## 3. 批次 1 · NovaChat（0.9.0 首例 · 已销号 · CARF 复评再销 1 处）

**改造**：13 个 `_` 私有 `readonly` 组合上下文常量供六轨共享；边界收敛为每边界唯一分隔源 + 2px 主色系顶层线；删 3 条 `secondary`/`accent` 撞色缘轨；20+ 仿控件装饰 → 抽象几何；三段折叠共用 `_dur`/`_ease`、锚链恒定不依赖 `visible` 三元；showcase 六槽真实业务注入、调参面板默认收起、消息与输入限宽居中。

**0.9.1 复评残余销号（7 处，均在 showcase 层）**：状态栏调试态 → 真实连接状态；消息流改「不足一屏贴底 / 超出一屏顶对齐且可滚动」；会话头三点仿菜单 → 真实「成员 3」胶囊；输入区 3 个仿工具方块 → 真实可交互工具位（纯几何图标 + hover）；导航轨 4 位补 hover 反馈；signal 回显移入调参浮层。

**CARF 复评（本轮）**：`audit_ceiling.py` 首轮机检暴露源码仍残留 1 处 `showHeader/showComposer` 三元锚链 → 改为 `_headerBar` / `_composerBar` **栏高归零 + 恒定锚链 + `Behavior on height`**，内层 `NovaHeader` / `NovaFooter` 保持固定高度规避坑位 19（0 高内部 padding 反噬），装饰细线 / 在线点 / 输入区短带随栏收起；画布对角双角标 margins 加父区尺寸钳制；showcase 补 `variantMode`。

**验收**：浅 / 深 / 折叠三态渲染审计（`chat_showcase_*.png`）、QML 零错误、对象树无 0×0 / 负宽高、公共 API 逐字不变。

---

## 4. 批次 2 · 三大多端根壳（0.9.1 · 已销号 · CARF 复评再销 1 处）

### 4.1 NovaDesktop

- **诊断**：`showToolbar ? _toolbar.bottom : ...` **visible 三元锚链**；26×26 圆角方块是仿交互控件；红 / 黄 / 绿三色控制点与主色撞色；三栏散用 `NovaTheme.spacing*`；演示五槽全是占位文字 + 调参台常驻。
- **改造（全 `_` 私有 PATCH）**：13 个组合上下文常量；三栏改「**高度归零 + 恒定锚链 + `Behavior on height` 共用 `_dur`/`_ease`**」；三色控制点 → 主色系三档深浅；仿控件方块 → 段位递减条；`_menu`/`_toolbarHost`/`_statusHost` 独立宿主铺满；`NovaPage padding: 0` 消除三层叠加；顶层 2px 单色系发丝线统一主签名。
- **showcase**：真实 IDE 场景（菜单栏 5 项 / 工具栏 5 个位 / 文件树 + 代码行 + 装配态检查清单 / 属性卡 / 状态栏）；调参面板默认收起浮层；emoji 主题图标 → 纯几何日月；组件状态栏与窗口状态条文案去重。
- **验收**：浅 / 深 / **三栏收起变体态**三图、QML 零错误、页面铺满无塌陷。**CARF 复评**补 `variantMode`，三图重出。

### 4.2 NovaMobile

- **诊断**：`showHeader ? ...` / `showBottomNav ? ...` 三元锚链；`_safeBottom` 与底导航双轨重叠；灵动岛硬件黑在深色下与背景糊成一片；槽位注入顶层 0×0；演示全是占位色块。
- **改造**：组合上下文常量；Header / 底导航高度归零 + 恒定锚链 + 同步动效；删冗余 `_safeBottom`，安全区并入底导航 wrap；灵动岛、home indicator 收敛主色系抽象几何；`_headerHost`/`_bottomNav` 独立宿主铺满；`focus: true` 保证返回键可达。
- **反向打磨（0.9.1，条件触发）**：装配态**深色双主题出图审计**暴露「灵动岛只剩孤立蓝点」——这是 `NovaMobile.qml` **组件自身**的深色可见性缺陷，直接在该组件内修（深色改提亮表面色 + 描边），未改任何 Controls 基础组件。
- **CARF 复评（本轮，机检暴露）**：极端非法入参 `999999` 下「安全区 + Header + 安全区 + Nav」叠加超过窗口高度，`NovaPage` 稳态负高 `-80`。新增 `_chromeCap`（父高 18%）作为四条 chrome 轨共享高度预算，任何入参组合下内容区恒 ≥ 父高 28%；`_safeT/_safeB/_headerH/_navH` 全部纳入预算钳制。showcase 补 `variantMode`。
- **showcase**：手机设备框（双主题自适应底座）+ 真实会话页（问候卡 / 3 张任务卡含进度条 / 最近消息）+ 4 个真实可交互底导航位；左右静态装配态说明；调参面板默认收起。
- **验收**：浅 / 深 / **大安全区变体态**三图、QML 零错误、灵动岛双主题可辨、极端入参稳态几何非负。

### 4.3 NovaFlexLayout

- **诊断**：header / footer 三元锚链；`primary`/`secondary`/`accent` 三色渐变底线 + 三色面板顶条撞色；面板网格与 `NovaPage` 同区域各铺一套布局；`columns` 变化无过渡。
- **改造**：组合上下文常量；header / footer 高度归零 + 恒定锚链 + 同步动效；删三色底线、面板顶条改主色系三档深浅、顶层 2px 单色系发丝线；面板宽度加 `Behavior on width` 共用 `_dur`/`_ease`；`_headerHost`/`_footerHost` 独立宿主铺满；网格 `margins` 与内容区 `padding` 同值对齐（CC-1）。
- **showcase**：真实实时运行看板（3 张面板：KPI 大数值 / 迷你柱状图 / 指标行 / 时段明细 4 行）；底层面板网格作骨架、业务只注入内容不另铺底板；分栏变体时业务卡片同步收起。
- **验收**：浅 / 深 / **两栏变体态**三图、QML 零错误、变体无第 3 张残留卡片。**CARF 复评**补 `variantMode`（变体 2 列 + 隐藏 header/footer），三图重出。

---

## 5. 批次 3~6 · 十一项组合根容器（CARF-R 全量迁移 · 全部已销号）

十一项全部按 §0.3 固定动作逐项落地：源码整文件按 CC-1~CC-8 重写；showcase 重做为**成品级真实业务场景**（调参面板默认收起浮层、纯几何图标、统一 `variantMode`）；浅 / 深 / 变体三态真实引擎出图；机检逐项销号。全部为 `_` 私有 PATCH，公共 API 签名逐字不变。

### 5.1 批次 3 · 主导航壳

- **NovaSidebar**：诊断「三元锚链 + `primary→secondary` 撞色渐变轨 + 仿筛选控件 + 槽位宿主未铺满」。改造：组合上下文常量；顶 / 底栏高度归零 + 恒定锚链；侧栏卡宽度 `Behavior on width`；品牌渐变轨与三档圆点收敛主色系；段位递减条替代仿控件；五槽宿主独立铺满；`NovaPage padding: 0`。showcase「**产品控制台**」：顶栏品牌 / 搜索 / 账户、左侧工作区导航树、中央 KPI 与活动列表、底部连接态；变体态折叠侧栏。极端入参下 `_sidebarHost` margins 加父轨尺寸钳制（见 §6.2）。
- **NovaTopNavigation**：诊断「胶囊台 / 下拉 / 状态栏三元切换 + 撞色带」。改造：胶囊导航台高度归零、悬浮下拉卡 `Behavior on height`、底栏高度归零、alias 宿主铺满、主色系装饰、`NovaPage padding: 0`。showcase「**数据分析门户**」：真实导航、悬浮下拉 6 宫格、KPI 卡、柱状趋势、数据源列表、底部同步态；变体态展开下拉。极端入参下 `_menuHost` margins 加父轨尺寸钳制（见 §6.2）。
- **NovaDualSide**：诊断「左右栏 `visible` 三元跳变 + 双侧撞色色带」。改造：左 / 右栏宽度归零 + `Behavior on width`；主色系渐变轨与角标替换撞色色带；中央画布点阵留在业务注入下方；底栏高度归零；宿主铺满。showcase「**设计器工作台**」：左侧图层树、中央设计稿卡 + 四角取景框（改恒定 `x/y` 绝对定位）、右侧属性面板、底部文件态；变体态收起左栏。

### 5.2 批次 4 · 多栏工作台壳

- **NovaTabShell**：标签栏 / 底栏高度归零 + 恒定锚链；三色段落改主色系递减条；删标签栏底部重复 `NovaSeparator`，保留居中品牌下划线；宿主铺满；`NovaPage padding: 0`。showcase「**多文档编辑器**」：3 个真实文档标签、文档画布、CARF 清单与状态栏；变体态收起标签栏。
- **NovaThreeColumn**：顶 / 底栏高度归零；树栏 / 详情栏 `Behavior on width`；深色顶条与 `primary→secondary` 渐变收敛主色系；伪 grip 改抽象短条；两条垂直 `NovaSeparator` 为唯一分隔源；宿主铺满。showcase「**Nova API Explorer**」：左侧模块树、中间接口列表、右侧接口详情、顶部搜索 / 版本、底部指纹状态；变体态切换顶 / 底栏并收窄树栏。
- **NovaCompare**：控制 / 底栏高度归零；中缝圆形调节柄 + 双箭头改抽象短条；A/B 贯穿色条改主色系角标；左右 `NovaPage padding: 0`；宿主铺满。showcase「**生产 / 预发布配置对比**」：A/B 双面板真实差异行、同步滚动开关、底部差异统计；变体态收起控制 / 状态栏。
- **NovaCardGrid**：工具条 / 底栏高度归零；仿筛选胶囊与仿视图切换钮改主色系抽象几何；`_grid` 铺满内容区；padding 钳制 `_pad`；宿主铺满。showcase「**模板市场**」：真实搜索、分类标签、6 张模板卡，变体态工具条收起且只显示 4 张卡；Flow 自适应 + 状态栏分页。

### 5.3 批次 5 · 浮层容器壳

- **NovaModal**：`primary/secondary/accent` 三色顶条改主色系单色渐变；拖拽 catcher 伪把手改短渐变线；标题 / 操作栏高度归零 + 恒定锚链；`_mask opacity: 0.55` 保留为**功能性遮罩例外**（CC-3）；阴影层改 `x/y/width/height` 绝对定位避免与 anchors 混用；宿主铺满。showcase「**PyPI 发布确认**」：背景业务页 + 半透明遮罩 + 浮起卡片 + 真实取消 / 确认按钮；变体态收起标题 / 操作栏；`dialogOpen` 可重开。
- **NovaDrawerPanel**：`primary→secondary` 侧缘轨收敛主色系；grabber 伪把手改短渐变线；标题 / 操作栏高度归零；`_scrim opacity: 0.32` 功能性遮罩例外；宿主铺满。**装配态对侧变体出图暴露面板拉伸占满整宽**（`left/right: undefined` 三元锚链在 Qt 6.12 下左右锚同时生效）→ 改恒定 `x/y` 定位 + `Behavior on x`，内侧 `NovaSeparator` 同步改恒定 `x`；另修 `id-shadows-member` 真实红灯（`readonly property color _panel` 与 `id: _panel` 同名 → 重命名为 `_panelCard`）。showcase「**属性编辑抽屉**」：背景项目详情 + 真实表单字段 + 操作按钮；变体态切到左侧并开启遮罩；极端入参下 `_actionsHost` margins 加父轨尺寸钳制（见 §6.2）。

### 5.4 批次 6 · 极简独立页壳

- **NovaSetupWizard**：步骤栏高度归零 + 恒定锚链；时间轴装饰保留但业务 `stepsSlot` 提级 `z: 3`；两个仿交互控件改抽象几何；控制栏 / 底栏宿主独立铺满；`NovaPage padding: 0`。showcase「**新建工程向导**」：三步向导、真实步骤标签、模板 / 模块 / 确认表单、真实上下一步按钮、底部进度态；变体态跳到第 3 步并显示底栏。
- **NovaBlankPage**：顶 / 底栏高度归零；居中阅读栏 `_readingColumn` 单一表面色阶；`NovaPage` 用 `anchors { fill: parent; margins: _pad }` + `padding: 0` 避免阅读栏 padding 与 `NovaPage` padding 叠加；宿主铺满。showcase「**CARF 宣言文档阅读页**」：顶栏文档导航、阅读栏正文与四阶段卡片、底部同步态；变体态纯净阅读大留白。

> **三态图清单**（15 项 × 3 态 = **45 张**，均在 `../screenshots/`）：
> `chat / desktop / mobile / flex / sidebar / top_navigation / dual_side / tab_shell /
> three_column / compare / card_grid / modal / drawer_panel / setup_wizard / blank_page`
> 各 `_showcase_light.png` / `_showcase_dark.png` / `_showcase_variant.png`。
>
> **1.1.0 增量（2026-11-26）**：`agent` / `de` / `copilot` / `orbit` 各 3 张 → 合计 **19 项 × 3 态 = 57 张**；
> 新增三态图的销号结论见 §8 表 16/17/18 行与 §9.2 历史快照。
>
> **1.2.0 增量（2026-11-26）**：`incubator` 3 张 → 合计 **20 项 × 3 态 = 60 张**；
> 第 20 组合根 `NovaIncubator` 的销号结论见 §8 表第 20 行与 §9.1 当前验收总表。

---

## 6. CARF 复评与 15/15 全量机检

### 6.1 两把机检尺

- **`../../scripts/audit_showcase.py`**（CC-7）：统一 `NovaTheme.setDark()` 主题探针 + `variantMode` 变体开关，
  `QQuickWindow.grabWindow()` 真实引擎渲染 15 × 3 = 45 张 PNG；`--all` 一键全量重出。
  排障沉淀：`QQuickWindow` 须在 `QQmlComponent.create()` 前导入，否则 shiboken 把 `ApplicationWindow`
  包装成 `QWindow` 基类而缺 `grabWindow()`；出图完成用 `os._exit()` 规避 Qt 退出期隐式析构崩溃。
- **`../../scripts/audit_ceiling.py`**（CARF-R 销号条件）：15 项静态 CC 契约扫描（组合上下文 / 动效令牌 /
  RTL / 恒定锚链 / 撞色 / 硬编码时长 / 占位文案 / 槽位 alias）+ 15 组件字面量实例化 + 15 showcase
  + Gallery + 每项 3 组极端非法入参（`-999` / `999999` / `undefined`，等待 Behavior 收敛后遍历对象树测稳态几何）
  + RTL 15/15 + reducedMotion + 文档相对链接断链扫描。

### 6.2 首轮 FAIL 33 项的定位与销号（不降标准、只修真实缺陷）

| 类别 | 命中 | 根因 | 处置 |
| :--- | :--- | :--- | :--- |
| 静态反模式 | 1 | `NovaChat.qml` 残留 `showHeader/showComposer` 三元锚链 | 改 `_headerBar`/`_composerBar` 栏高归零 + 恒定锚链（§3） |
| 静态反模式 | 3 | `NovaDesktop`/`NovaCardGrid`/`NovaSetupWizard` 各 2 处命中「占位 / 伪按钮 / 按钮位标识」——**全部在源码注释里**，是「已替换旧仿控件」的修复史料，非用户可见占位文案 | 机检按语义修正：新增 `_strip_comments()`，反模式只扫非注释文本（真实占位文案依旧判 FAIL）；同时把三份注释措辞规范化为「仿交互控件」做双保险；功能性遮罩 `_mask`/`_scrim` 低实心按 CC-3 例外识别 |
| 动态稳态几何 | 1 | `NovaMobile` 四条 chrome 轨叠加超窗高 → `NovaPage -80` | 新增 `_chromeCap` 共享高度预算（§4.2） |
| 动态稳态几何 | 7 | `NovaSidebar -24` / `NovaTopNavigation -24` / `NovaDrawerPanel -12`：槽位宿主 `anchors.fill` + 固定 `margins`，父轨归零时算出负宽高 | 三处宿主 `margins` 改为 `Math.max(0, Math.min(基准值, 父宽/2, 父高/2))`，父轨归零时自动归零 |
| 文档断链 | 21 | **全部**来自 `docs/ai/pages/**` 生成物副本：`../../scripts/gen_apidocs.py` 原用 `shutil.copyfile` 原样拷贝，链接基准从 `docs/` 或仓库根变成 `docs/ai/pages/` 后失效；已核实 21 个目标文件在源文档中**全部真实存在** | **修生成器而非放宽机检**：新增 `rewrite_links()`，按「源文档目录」解析、按「目标目录」重新表达相对链接，`#anchor`/`?query`/外部 URL 原样保留；重跑生成器，断链 21 → 0。生成物一律由生成器产出，未手工编辑 |

**原则**：动态 8 项与断链 21 项是真实工程缺陷，全部改代码 / 改生成器修复；静态 3 项是机检语义误判，修正扫描语义并同步规范化注释措辞；**没有调高 qmllint 预算、没有排除失败项、没有手改生成物**。

### 6.3 最终 PASS

> ⚠️ **本节为 2026-11-25 的 15 项 GA 阶段历史验收**；**当前 1.2.0 的 20/20 结论**见 §8 销号表与 §9.1（1.1.0 历史快照见 §9.2）。
>
`python scripts/audit_ceiling.py` → **结论：PASS · 15/15 六维天花板机检全绿（CARF-R 销号条件达成）**。
静态机检表 15 项 CC-1 / 动效 / RTL 全 ✓，锚链三元 0、撞色 0、硬编码 0、占位 0、低实心 0；
动态：实例化 15/15 · showcase + Gallery 16/16 · 极端非法入参 **45/45 组非负几何** · RTL 15/15
· reducedMotion `300.0 → 0`；文档相对链接 88 条检查 · **断链 0**。

---

## 7. 反向打磨记录（条件触发原则）

| 触发点 | 暴露方式 | 反向对象 | 处置 |
| :--- | :--- | :--- | :--- |
| NovaMobile 灵动岛深色不可辨 | 0.9.1 装配态双主题实心注入渲染审计 | `NovaMobile.qml`（组合根容器自身） | 深色改提亮表面色 + 描边 |
| `NovaDrawerPanel` 面板拉伸占满整宽 | 本轮装配态**左侧变体**出图审计 | `NovaDrawerPanel.qml`（组合根容器自身） | `left/right: undefined` 三元锚链 → 恒定 `x/y` + `Behavior on x`；重出图后抽屉仅占约 1/3 宽、右侧业务页与遮罩可见 |
| `id-shadows-member` 超预算 +2 | 静态门禁 qmllint 真实红灯 | `NovaDrawerPanel.qml`（组合根容器自身） | `id: _panel` 与 `_panel` 属性同名 → 重命名 `_panelCard`；**未调预算掩盖** |

其余缺陷全部落在**组合层 / showcase 层 / 工具与生成器层**；本轮**未触发任何 Controls 基础组件的反向修改**。按伙伴节奏「若是单个组件问题，再反向打磨」，不为凑流程硬造修改。

---

## 8. 销号进度表（20 项）

| # | 组合根容器 | 批次 | 状态 | 三态装配审计 | 备注 |
| :-- | :--- | :--- | :--- | :--- | :--- |
| 1 | **NovaChat** | 批次 1（0.9.0） | ✅ 已销号 | 浅 / 深 / 折叠 | 六轨标杆；0.9.1 残余 7 处 + CARF 复评三元锚链 1 处已销 |
| 2 | **NovaDesktop** | 批次 2（0.9.1） | ✅ 已销号 | 浅 / 深 / 三栏收起 | 恒定锚链 + 栏高归零动效；CARF 复评补 `variantMode` |
| 3 | **NovaMobile** | 批次 2（0.9.1） | ✅ 已销号 | 浅 / 深 / 大安全区 | 灵动岛深色反向修复 + CARF 复评 chrome 高度预算 |
| 4 | **NovaFlexLayout** | 批次 2（0.9.1） | ✅ 已销号 | 浅 / 深 / 两栏变体 | 单色系面板网格 + 分栏平滑过渡 |
| 5 | **NovaSidebar** | 批次 3 | ✅ 已销号 | 浅 / 深 / 侧栏折叠 | 产品控制台；宿主 margins 稳态钳制 |
| 6 | **NovaTopNavigation** | 批次 3 | ✅ 已销号 | 浅 / 深 / 下拉展开 | 数据分析门户；下拉卡 margins 稳态钳制 |
| 7 | **NovaDualSide** | 批次 3 | ✅ 已销号 | 浅 / 深 / 双侧收起 | 设计器工作台；四角取景框恒定 `x/y` |
| 8 | **NovaTabShell** | 批次 4 | ✅ 已销号 | 浅 / 深 / 标签栏收起 | 多文档编辑器 |
| 9 | **NovaThreeColumn** | 批次 4 | ✅ 已销号 | 浅 / 深 / 三栏折叠 | Nova API Explorer |
| 10 | **NovaCompare** | 批次 4 | ✅ 已销号 | 浅 / 深 / 中缝控制 | 生产 / 预发布配置 diff |
| 11 | **NovaCardGrid** | 批次 4 | ✅ 已销号 | 浅 / 深 / 列数变化 | 模板市场 |
| 12 | **NovaModal** | 批次 5 | ✅ 已销号 | 浅 / 深 / 关闭态 | PyPI 发布确认；功能性遮罩例外 |
| 13 | **NovaDrawerPanel** | 批次 5 | ✅ 已销号 | 浅 / 深 / 抽屉对侧 | 属性编辑抽屉；2 次组件内反向修复 |
| 14 | **NovaSetupWizard** | 批次 6 | ✅ 已销号 | 浅 / 深 / 步骤跳转 | 新建工程向导 |
| 15 | **NovaBlankPage** | 批次 6 | ✅ 已销号 | 浅 / 深 / 阅读栏宽度 | CARF 宣言文档阅读页 |
| 16 | **NovaAgent** | 1.1.0 AI 智能组合根 | ✅ 已销号 | 浅 / 深 / 变体 | 任务列 DAG 链 + 编排画布 + 验证轨 + 审批闸门；八项准入控制由业务注入 |
| 17 | **NovaDE** | 1.1.0 AI 智能组合根 | ✅ 已销号 | 浅 / 深 / 变体 | 岗位菱形徽记 + 队列堆叠 + 工作画布 + SLA 轨 + 交接条；四要件由业务注入 |
| 18 | **NovaCopilot** | 1.1.0 AI 智能组合根 | ✅ 已销号 | 浅 / 深 / 变体 | 建议列 + 内联条 + 工作画布 + 动作闸门轨；确认闸门由业务注入 |
| 19 | **NovaOrbit** | 1.1.0 意图轨道呈现层 | ✅ 已销号 | 浅 / 深 / 变体 | 三栏同构异质 + 七槽托管 + 全局栏/输入栏/轨道地图/浮层；Orbit Engine / Entity Router / 孵化确认闸门全由业务注入；第 19 个组合根 · 七件组件收官件 |
| 20 | **NovaIncubator** | 1.2.0 应用孵化器工作台（收官件） | ✅ 已销号 | 浅 / 深 / 变体 | 七槽无业务语义骨架（全局栏 / 配方库 / 孵化舞台 / CARF 四阶段条 / 三重校验 / 封版证书 / 浮层）+ 3 受控信号 + 3 函数 + 递进楔形/配方栅/七区环/收敛链/校验刻线/方章折角差异化身份；配方解释器 / 组件装配器 / 治理注入器 / 三重校验器 / 证书签发器全由业务注入；**本库第 20 个、最后一个组合组件**；三态图实测暴露 3 处业务注入争位 → 业务侧调参销号、组件公共面零改动 |

> **20 / 20 全部销号**。批次 1~6（15 项 GA）为 `_` 私有 PATCH 打磨，公共 API 逐字不变；
> 1.1.0 新增 4 项组合根（3 项 AI 智能组合根 + 1 项意图轨道呈现层）为**增量（additive）**变更，
> 指纹 `862312749d335aad`，143 类型（15 项 GA 签名零改动）——该批次为**未发布历史批次**，结论见 §9.2。
> 1.2.0 新增第 20 组合根 `NovaIncubator`（应用孵化器工作台壳），按宪法第 8 章升 minor
> **整批单次重签** `api/nova-api-1.2.0.json`，指纹 `68b34a408489b6a8`，**144 类型**（15 项 GA 签名零改动）。
> 三态图 45 → 57 → **60 张**，机检 `audit_ceiling.py` **20/20 PASS**（60/60 组极端非法入参零负几何 · RTL 20/20 · 481 条链接断链 0）。

---

## 9. 最终验收总表（CARF-F）

### 9.1 当前（1.2.0 · 2026-11-26 · 20 项组合根容器 · 第 20 组合根 NovaIncubator 收官 · 整批单次重签）

| 项目 | 结果 |
| :--- | :--- |
| `scripts/audit_ceiling.py` 20/20 天花板机检 | **PASS**（20 组件字面量实例化 + 21 showcase / Gallery + **60/60** 组极端非法入参零负几何 + RTL 20/20 + reducedMotion 300→0 + **481 条文档相对链接断链 0**） |
| `scripts/audit_foundations.py` 基础组件机检 | **PASS**（15/15 销号 · 127 非单例类型实例化 · 三态零负几何） |
| 静态门禁 `check_all.py --tier static` | **3/3 PASS**（a11y **144/144** · API 冻结 · qmllint **0 error / 594 warning** 预算内） |
| 专项 `test_api_freeze.py` + `test_layout_shells.py` | **53/53 passed** |
| 装配态渲染审计 | **20 项 × 浅 / 深 / 变体 = 60 张图全部出图 PASS**（新增 `incubator` 3 张；`NovaIncubator` 七槽真实业务注入 Demo 无头加载零警告；三态图视觉复核暴露 3 处业务注入争位 → 业务侧调参销号） |
| API 冻结 | **144 类型 · 指纹 `4f882374ad52262b`**（1.2.0 整批单次重签；**15 项 GA 公共签名逐字不变**，旧 143 类型成员零漂移） |
| 法源与组件契约 | `NovaIncubator.md` 企业级优化为第 20 组合根封版法源（元信息 / 零章无业务语义骨架 / 法源张力消解 / I1~I8 / CC-1~CC-8 / CARF 四阶段 / 封版声明；原 508 行史料逐字保留）；模块 README 补第 20 项契约与 20 项依赖矩阵 |
| 文档站 `mkdocs build` | **exit 0 / 0 WARNING / 0 内容 INFO**（nav 20 项全覆盖，含 `components/NovaIncubator.md` 与封版法源） |
| 物理目录分类 | **20 个 QML 按九类物理归档**（`qmldir` 相对子路径导出、模块 URI 不变）· 重签指纹 `68b34a408489b6a8` · 公共成员零漂移（归一化 `file` 后还原 `4f882374ad52262b`）· `audit_ceiling.py` / `gen_apidocs.py` 改由 qmldir 解析路径 · **07:18 F 收口复验：20/20 PASS · 512 条文档链接断链 0 · `test_layout_shells.py` 20/20 真实实例化证实 `qmldir` 相对子路径导出生效**（链接数由物理分类前 481 增至 512，系分类新增/改写文档所致，**断链恒为 0**；481 为当时准确时点值，不回改收官表） |
| AI 离线副本 | `gen_apidocs.py` 重跑：**144 类型 API + `nova-data.js`**（20 组件 / 24 Gallery / 60 三态图）；生成物未手改 |
| 文档层域分类守护（附加 · 不改 20/20 口径） | `scripts/audit_domains.py` **PASS**：144 类型零遗漏 / 零重复 / 零幽灵 · **104 基础类型全归十域**（Controls 7 域 91 + Behaviors 3 域 13）· 5 个 `qmldir` 模块 · 单向依赖 0 破口 · 相对导入 0 处；台账 `api/component-domains-1.2.0.json` 由生成器产出（禁手改） |
| `prescript/` 文档重组 + Quasar 理念对齐（附加 · 不改 20/20 口径） | **09:20 重组**：13 份现行文档按前缀分区、9 份退出历史舞台者删除（git tracked 可恢复）· **526 条文档链接断链 0**。**09:52 对齐指南**：新增 `GUIDE_QUASAR_ALIGNMENT.md`（第三份现行 `GUIDE_`），`audit_ceiling.py` **20/20 PASS · 553 条文档相对链接断链 0** · `mkdocs build` exit 0 / 0 内容 INFO / 0 "not in nav" · `audit_domains.py` PASS · `gen_prompt.py --check` `c8456b80bc20` ✓ · 冻结面 `68b34a408489b6a8` 与 AI 包 `0b02273de9aee652` **零漂移**。**链接计数 481 → 512 → 533 → 526 → 553 均为文档集规模变化导致的时点测量值，断链恒为 0**；收官表 481 与 `SESSION_HANDOFF.md` 门禁行 526 属当时准确值，**按「史料不圆场」不回改**，当前值以本行为准（不为非契约性计数触发项目投影指纹连锁漂移）。**零 QML / 零 `qmldir` / 零模块 URI / 零生成器改动** |
| **v2.0 立项 · 双轨兼容 M1 就绪态（10:44 校准 · 附加 · 不改 20/20 口径）** | **10:22** 曾落地 1 个 `Nova/Controls/Foundation/qmldir` pilot；**10:44 CSA 指令「去掉」已依「不将就」干净撤回**：删除物理目录（产品树 qmldir 回到精确 **5 个**）· 清除 `gen_apidocs.py` 跳过死代码 · `audit_v2_compat.py` 重写为就绪态守护 · `test_v2_compat.py` 改为 12 旧 URI 实例化 + 3 机检 · spike 内临时示意目录改中性 `Sub/`。**当前**：`audit_v2_compat.py` **PASS（C1~C5：0 视图 / 5 qmldir / 生成器干净 / 冻结面零漂移）** · `spike_v2_compat.py` **7/7** · `tests/test_v2_compat.py` **15 passed** · 专项 53 + 15 = **68 passed** · 生成器重跑幂等 AI 包 **`0b02273de9aee652` / 144 类型** · 冻结面 **`68b34a408489b6a8`** 零漂移 · **零 QML 搬运 / 零旧 `qmldir` / 零模块 URI / 零生成物手改**。链接计数与历史时点值按「史料不圆场」不回改，**10:44 当前实测 562 条链接断链 0**；**「5 冻结面模块 + 0 个 v2.0 兼容视图」由 `audit_v2_compat.py C2/C3` 机检钉死**，首个视图与 M2 同批 |

### 9.2 历史快照（2026-11-26 · 19 项 · 四增量整批单次重签阶段）

> 以下为 1.1.0 四增量（含第 19 组合根 NovaOrbit）完现时的验收结论（指纹 `862312749d335aad` / 143 类型 / 57 张图），
> **该批次未发布、史料完整保留供追溯**；当前状态一律以 §8 销号表与 §9.1 为准。

| 项目 | 结果 |
| :--- | :--- |
| `scripts/audit_ceiling.py` 19/19 天花板机检 | **PASS**（19 组件字面量实例化 + 20 showcase / Gallery + 极端非法入参零负几何 + RTL 19/19 + reducedMotion 300→0 + 文档相对链接断链 0） |
| `scripts/audit_foundations.py` 基础组件机检 | **PASS**（15/15 销号 · 125 非单例类型实例化 · 三态零负几何） |
| 静态门禁 `check_all.py --tier static` | **3/3 PASS**（a11y **143/143** · API 冻结 · qmllint **0 error** 预算内） |
| 专项 `test_api_freeze.py` + `test_layout_shells.py` | **52/52 passed** |
| 装配态渲染审计 | **19 项 × 浅 / 深 / 变体 = 57 张图全部出图 PASS**（新增 `orbit` 3 张；`NovaOrbit` 七槽真实业务注入 Demo 无头加载 `ROOTS 1` / 零警告） |
| API 冻结 | **143 类型 · 指纹 `862312749d335aad`**（1.1.0 四增量整批单次重签；**15 项 GA 公共签名逐字不变**） |
| 四份企业级旗舰版封版法源 | 联合方案拆为 `NovaAgent.md` / `NovaDE.md` / `NovaCopilot.md` 三份独立封版 md；`NovaOrbit.md` 原地企业级优化（零章无业务语义骨架 / O1~O8 工程落点 / CC-1~CC-8 / CARF 四阶段 / 封版声明） |
| 文档站 `mkdocs build` | **exit 0 / 0 WARNING / 0 内容 INFO**（nav 19 项全覆盖，含四份封版法源与 `NovaOrbit` 组件页） |
| AI 离线副本 | `gen_apidocs.py` 重跑：**143 类型 API + `nova-data.js`**（19 组件 / 24 Gallery / 57 三态图）；生成物未手改 |

### 9.3 历史快照（2026-11-26 · 18 项 · 三 AI 智能组合根阶段）

> 以下为 1.1.0 三 AI 智能组合根完现时的验收结论（指纹 `cc32b5852ed04995` / 142 类型 / 54 张图），
> **史料完整保留供追溯**；当前状态一律以 §8 销号表与 §9.1 为准。

| 项目 | 结果 |
| :--- | :--- |
| `scripts/audit_ceiling.py` 18/18 天花板机检 | **PASS**（18 组件字面量实例化 + 19 showcase / Gallery + **54/54** 组极端非法入参零负几何 + RTL 18/18 + 443 条文档相对链接断链 0） |
| 静态门禁 `check_all.py --tier static` | **3/3 PASS**（a11y **142/142** · qmllint **0 error / 593 warning** 预算内） |
| 专项 `test_api_freeze.py` + `test_layout_shells.py` | **51/51 passed** |
| 装配态渲染审计 | **18 项 × 浅 / 深 / 变体 = 54 张图全部出图 PASS**（`agent` / `de` / `copilot` 各 3 张） |
| API 冻结 | **142 类型 · 指纹 `cc32b5852ed04995`**（1.1.0 additive minor 重签；15 项 GA 公共签名逐字不变） |

### 9.4 历史快照（2026-11-25 · 15 项 GA 阶段 CARF-R 封版）

> 以下为 15 项 GA 组合根容器打磨完成时的验收结论，**史料完整保留供追溯**；当前状态一律以 §8 销号表与 §9.1 为准。

| 项目 | 结果 |
| :--- | :--- |
| `scripts/audit_ceiling.py` 15/15 天花板机检 | **PASS**（静态 15/15 全 ✓ · 45/45 组极端入参非负几何 · RTL 15/15 · reducedMotion 300→0 · 断链 0） |
| 静态门禁 `check_all.py --tier static` | **3/3 PASS**（a11y 139/139 · API 冻结 · qmllint **0 error / 593 warning** 预算内） |
| 专项 `test_api_freeze.py` + `test_layout_shells.py` | **48/48 passed** |
| 无头实例化 | **31/31**（15 组合组件 + 15 独立演示 + Gallery），QML 零错误 |
| 装配态渲染审计 | 15 项 × 浅 / 深 / 变体 = **45 张图全部出图 PASS**，`docs/screenshots/*_showcase_*.png`；抽查 chat 浅/变体、mobile 变体、drawer_panel 变体视觉无退化 |
| API 冻结 | **139 类型零漂移 · 命名红线 0 违规 · 指纹 `bfd3d938a2fab7be` 不变**（全 `_` 私有 PATCH，无需重签） |
| AI 离线副本 | `gen_apidocs.py` 重跑：**139 类型 API + 13 页文档**，链接重写后断链 21 → **0**；生成物未手改 |
| 文档闭环 | 母法卷首 CARF 宣言 + 迭代记录 · 组合宪法 1.0.0 卷首执行版 + 第 0 章第 5 条 + 迭代记录 + 落地范围 · 本档案 · CHANGELOG · 双语 README · 工作区账本 |

---

## 10. 发布边界

**commit / push / tag / PyPI 一律归伙伴（CSA）本人**；本档案与所有改动留在工作树待伙伴拍板验收。
CARF 循环不终止：F 之后若伙伴提出新构想（C），在既有 1.0.0 基座上再进入下一轮 R，**不推倒重来**。
