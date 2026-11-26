# 项目交接快照 — Session Handoff

> 用途：本文件是项目状态的**唯一事实源**；`scripts/gen_prompt.py` 会把它全文内联进
> `PROMPT.md`，新会话粘贴 PROMPT.md 即可 100% 恢复上下文。
> **每次交付随宪法迭代记录表同步更新本文件。**（更新于 1.2.3 · 2026-11-26）

## ⚠️ 当前状态校准（2026-11-25 17:16 立 · **2026-11-26 1.2.3 品牌徽标双轨制落地 / 功能主体仍为 1.2.0 第 20 组合根 NovaIncubator 收官** · 覆盖下方 rc1 历史快照）

> **本节优先于下方全部历史正文**。下方「1.0.0rc1 / 124 类型 / 六期 RC1」等内容是
> 2026-11-23 的历史档案，保留供追溯，**不得作为当前状态引用**。

| 项 | 当前事实（2026-11-26 · **1.2.0 整批单次重签 / 第 20 组合根 NovaIncubator 收官**；T9 / 坑位 49 / T5 均已结案） |
|---|---|
| 版本 / 发布 | **1.2.3**（由 1.2.2 作 **patch** 升级：品牌徽标双轨制落地 + PyPI README 绝对链接修正，**公共 API 零漂移**；CSA 14:37 改判徽标版本口径——徽标为 SVG 文本、刻当前包版本 `v1.2.3`，**每次升版（含 patch）同步修正**，由 `scripts/sync_brand_version.py` 写入 + `--check` 机检固化（见 `GUIDE_BRAND_MARK.md §7`）；**1.2.2**（PyPI 元数据 / 双语 README 呈现修正）已由 CSA 发布至 PyPI，`main` / tag `v1.2.2` → `a431a0f`；功能主体是 1.0.1 → 1.2.0 的 **additive minor**——共新增 **5 项组合根容器** `NovaAgent` / `NovaDE` / `NovaCopilot` / `NovaOrbit` / **`NovaIncubator`**，**15 项 GA 公共签名逐字不变**；1.1.0 为未发布中间批次、其四增量已并入 1.2.0 **整批登记、单次重签**，禁止中间指纹；按 1.0.1 / 1.2.1 先例 `apiVersion` 保持 **1.2.0**、清单 `api/nova-api-1.2.0.json` 文件名不改）；**1.0.0 GA / 1.0.1 / 1.2.1 / 1.2.2 已由 CSA 发布至 PyPI，1.2.3 待 CSA 发布** |
| 公共 QML 类型 | **144**（Controls 91 · Behaviors 13 · Services 16 · Design 4 · **Composite.LayoutShell 20** = 15 GA + 3 AI 智能组合根 + 1 意图轨道呈现层 + 1 应用孵化器工作台） |
| API 冻结 | 144 类型零漂移 · 指纹 **`4f882374ad52262b`**（1.2.0 整批单次重签，12:05 物理拍平后重签；历史指纹 `bfd3d938a2fab7be → cc32b5852ed04995 → 862312749d335aad → 68b34a408489b6a8`）· `api/nova-api-1.2.0.json` 与 `docs/API_FREEZE.md` 均为生成物禁手改；旧 143 类型成员逐字比对 **0 漂移**，仅新增 `NovaIncubator` |
| 方法论 | **CARF — Conceive, Achieve, Refine, Freeze — Culminate to the peak.** 构想 · 实现 · 打磨 · 封版，终抵巅峰（天花板）；母法 `docs/CONSTITUTION.md` 卷首 + 组合宪法 `docs/COMPOSITION_CONSTITUTION.md` **1.0.0** 卷首执行版。本轮 CARF 全循环：C 精读命名稿 + World-Class Edition 史料、裁定「方法论层史料 + 组件层工作台壳」双层法源 → A 第 20 组合根 QML + 1.2.0 整批重签 → R 三态图 / 20/20 机检 / 视觉实测避让 → F 账本闭环 |
| 组合根容器 | **20 / 20 天花板全量销号**（15 GA + 5 增量，CARF-R 完成；**第 20 个 = 本库最后一个组合组件**）；逐项台账 `docs/prescript/AUDIT_CEILING.md`（§8 表 1~20 行；§9.1 当前 20/20、§9.2 19/19 历史、§9.3 18/18 历史、§9.4 15/15 历史）；`scripts/audit_ceiling.py` **20/20 PASS** |
| 基础组件 | **15 / 15** 真实 Robustness 缺陷销号（14 数值 + 1 超长字符串，非组合组件）；台账 `docs/CEILING_AUDIT_FOUNDATIONS.md`；`scripts/audit_foundations.py` **PASS**（127 非单例类型实例化 × 三态零负几何），全 `_` 私有 / 内部几何 PATCH、公共 API 零漂移 |
| 测试基建坑位 49 | **21:47 依 CSA 指令结案归档：议题结案、非交付完成**——Qt 6.12 + shiboken 与 pytest 生命周期 refcount 冲突，14 类工程修复无效、未交付修复；真正修复需 CSA 拍板降级 PySide6 或改分批独立进程测试架构。产品代码 / 已发布包不受影响 |
| 装配态资产 | **20 × 浅/深/变体 = 60 张** `docs/screenshots/*_showcase_*.png`（本轮新增 `incubator` 3 张；1.1.0 批次 `agent` / `de` / `copilot` / `orbit` 各 3 张）；工具 `scripts/audit_showcase.py` |
| 企业级旗舰版封版法源 | ① `docs/prescript/LAW_NovaAgent.md` ② `LAW_NovaDE.md` ③ `LAW_NovaCopilot.md`（联合方案拆三份）④ `LAW_NovaOrbit.md`（原地企业级优化：元信息 / 零章无业务语义骨架 / O1~O8 / 组件级契约 / CC 映射 / CARF / 封版声明）⑤ **`LAW_NovaIncubator.md`（905 行：前置组件层封版法源 396 行 + 原 508 行 World-Class Edition 史料逐字保留；元信息 / 零章三要素 / 法源张力消解 / I1~I8 / 组件级契约 / CC-1~CC-8 / CARF 四阶段 / 命名稿整合 / 封版声明）**；⑥ `ARCHIVE_NovaIncubator_Naming.md` 命名定稿史料（288 行）。均已纳入 `mkdocs.yml` nav |
| 品牌徽标（1.2.3） | CSA 14:22 / 14:25 双轨制拍板：**克制矢量派** `src/pyside_nova/resources/icons/pyside-nova-logo-sealed.svg`（+ `-mono.svg`）= 正式库标，进 README 双语 / 文档站首页；**华丽宣传派** `-sealed-gold.svg` 仅海报封面，不上 favicon / 小尺寸。**刻当前包版本 `v1.2.3`**（CSA 14:37 改判：SVG 版本号是文字、每次升版含 patch 同步修正，非刻死 API 契约），由 `scripts/sync_brand_version.py` 写入 + `--check` 机检固化；规范唯一事实源 `docs/prescript/GUIDE_BRAND_MARK.md`（§7 升版 SOP）。`.gitignore` 的 `icons/` 无锚点误伤已修为 `/icons/` + 资源放行，17 个 SVG + 2 PNG 首次入库；`textPath` 环形铭文须 Chrome/Playwright 渲染（QtSvg 不渲染） |
| 第 20 组合根 NovaIncubator | **「本库最后一个组合组件」** = 诺瓦应用孵化器在组件层的「应用孵化器工作台壳」。七槽无业务语义骨架（global / recipe / stage / pipeline / validate / certificate / overlay）+ 3 受控信号（`recipeToggled` / `validateToggled` / `freezeRequested`）+ 3 函数 + `_` 私有纯几何身份；成品级 Demo `examples/layout_shell/incubator/` 真实注入 R1~R5 五套配方 / 七区契约 / 组件编排 / 治理清单 / CARF 四阶段 / 三重校验 / 封版证书五件套 / **人工确认闸门**；Gallery 第 20 页 + 逐组件 API 页 + 3 张三态图。`freezeRequested()` 只 emit 意图，**壳绝不自动封版、绝不自动执行** |
| 按需打磨（实测驱动） | 三 AI 组件与第 20 组合根均按 CSA 拍板 **「实测驱动、按需打磨」**：20/20 机检（静态 CC 契约 / 字面量实例化 / 60/60 组极端非法入参 / RTL 20/20 / reducedMotion）+ 三态装配图视觉复核；首轮 `incubator` 出图暴露 2 处**业务注入侧争位**（标题与身份装饰重叠、证书栏五件套裁切），仅在 Demo 侧 `topMargin` / `certificateHeight: 190` 避让修复，**组件侧零 PATCH、零公共面改动、零指纹漂移**；不硬造修改、不批量扫荡 |
| 门禁 | `check_all.py --tier static` **3/3**（a11y **144/144** · API 冻结 144 零漂移 · qmllint **0 error** / 594 warning 预算内）；专项 `pytest tests/test_api_freeze.py tests/test_layout_shells.py -q` **53/53**；`audit_ceiling.py` **20/20 PASS**（20 组件字面量 + 21/21 showcase / Gallery + **60/60 组**极端非法入参零负几何 + RTL 20/20 + reducedMotion 300→0 + **526 链接断链 0**）；`audit_foundations.py` **15/15 PASS**；`mkdocs build` exit 0 / **0 WARNING / 0 内容 INFO**；`gen_apidocs.py` / `gen_component_list.py` 重跑幂等（144 类型 / 20 页逐组件文档 / 60 张三态图引用） |
| 生态对标复核 / T9 | 17:16 复核综合完美度 **≈72%**（内核 ≈95% 反超 / 组件与装配态 ≈92% / 开发者生态体验 ≈55~60%）。**T9 20:23 依伙伴指令销号**（P0 三条 19:35 + P1 四项 / P2 三项 20:23 全落地；归档行按 CSA 结案特例标注「议题结案、非交付完成 / 部分交付」：站点部署 / WASM 在线运行时归 CSA）。完整对账表见工作区根 `PROMPT.md` **§12 / §12.7** |
| 发布边界 | HEAD `0053f6e`（CSA 已 commit + push 1.0.1 + tag `v1.0.1` + PyPI 上架 LATEST RELEASE）；**本轮 1.2.0 全部改动留工作树、尚未提交**。**commit / push / tag / PyPI / 站点上线一律归 CSA（伙伴）**，小诺只做实现 / 只读核查 / 构建验证 / 账本闭环；待办池 **2 项（T3 / T4）**、无活跃主线、下一个编号 T10。`docs/prescript/LAW_NovaOrbit.md` / `NovaIncubator.md` 的 `AM` intent-to-add 暂存状态是否纳入提交由 CSA 决定 |
| 物理目录分类（1.2.0） | **20 个 QML 已拍平于 `Composite/LayoutShell/` 根目录**（12:05 CSA 指令；1.2.0 曾按九类归入 `Navigation/Workbench/.../` 子目录，现已撤回为文档层台账）；`qmldir` 逐项以 `名字.qml` 平铺导出，模块 URI 恒为 `Nova.Composite.LayoutShell` 单一模块、20 个类型名与 `import` 用法不变。`gen_api_freeze.py` 重签 → 指纹 `4f882374ad52262b`（`file` 溯源元数据变化；反向归一化后精确还原旧值 `68b34a408489b6a8`，公共成员逐成员零漂移）。`audit_ceiling.py` / `gen_apidocs.py` 改由 qmldir 解析路径。详见 `docs/prescript/GUIDE_CLASSIFICATION.md §1.1` |
| 文档重组与「不将就」入宪（1.2.0） | 母法 `docs/CONSTITUTION.md` 卷首 CARF 宣言后新增**第 4 条「不将就 / No Compromise」**最高信条（六维缺一不可 / 现有再优仍再优化 / 史料不圆场 / 账实不符必校准 / 退出历史舞台者不留残影 / 法源链不留悬空引用）。按此信条把 `docs/layout_shell/`（14 份）与 `docs/white_paper/`（8 份）**合并为单一 `docs/prescript/`**：13 份现行文档按 `类别_主题.md` 前缀分区（`LAW_` 5 / `GUIDE_` 2 / `AUDIT_` 1 / `SPEC_` 3 / `WHITEPAPER_` 1 / `ARCHIVE_` 1），9 份退出历史舞台的 md 依 CSA 授权删除（全部 git 已跟踪、可从 HEAD 精确恢复）；nav / 双语 README / 首页 / 生成器 / 模块 README / 组合宪法现行条款 / 结构快照全库同步，现行「权威清单」引用改指向 `COMPONENT_LIST.md` + 冻结清单 + 模块 README。**零 QML / 零 `qmldir` / 零模块 URI 改动 · 冻结面 `68b34a408489b6a8` 零漂移** |
| **v2.0 物理重构立项（M1 就绪态 · 2026-11-26 10:44 校准）** | CSA 10:09 指令「**先做 v2.0 物理重构，立项和兼容层一起**」= `GUIDE_QUASAR_ALIGNMENT.md §5` 四条前置条件的那次单独拍板；**CSA 10:44 指令「`Controls/` 下新建的 `Foundation` 去掉」→ 首个物理 pilot 撤回、M1 回退为「零物理视图」就绪态**。法源 [`SPEC_V2_COMPAT.md`](prescript/SPEC_V2_COMPAT.md)（RFC + 双轨兼容契约 + 宪法第 9/13 章合规论证 + M1~M4 分批路线图）。**Qt 6.12 七形态实测**（`scripts/spike_v2_compat.py` **7/7**，临时目录、不碰产品树）证明 `qmldir` 的 `../` / `../../` 跨目录转发可行且拿到**同一物理实现**，据此校正「改 URI 必破坏兼容」的旧裁定。**M1 就绪态实物**：**0 个物理兼容视图**（`Nova/Controls/Foundation/` 已删除、`gen_apidocs.py` 视图跳过死代码已清除，产品树 qmldir 精确 **5 个**冻结面模块）+ `scripts/audit_v2_compat.py`（**C1~C5 PASS**：0 视图 / 5 qmldir / 生成器干净 / 冻结面零漂移）+ `scripts/spike_v2_compat.py`（7/7）+ `tests/test_v2_compat.py`（**15 passed**：12 旧 URI 真实实例化 + 3 就绪态机检）。**零 QML 搬运 · 零旧 `qmldir` 改动 · 零模块 URI 改动 · 零生成物手改 · 冻结面 `68b34a408489b6a8` / AI 包 `0b02273de9aee652` 零漂移**；静态 3/3 · 专项 53/53 + 15 = **68 passed** · 20/20 · 15/15 · 域分类 PASS · mkdocs 0 内容 INFO · 断链 0 · 生成器重跑幂等。**首个真实兼容视图与 M2（首批物理迁移 + additive major 重签 2.0.0）同批落地，均待 CSA 定 1.2.0 发布衔接后启动**；全量废除 `Composite` / 改模块 URI 须 CSA 再单独豁免改宪。包版本仍 **1.2.0**（兼容基线），发布归 CSA |
| **Quasar 文案正名 + 10 组件专属主题（12:30 · CSA 三令）** | CSA 三令：① 把 Quasar 关系从 `Derived from` 正名为 **`Inspired by`**（避免 fork 误读）→ 新建 `docs/QUASAR_ACKNOWLEDGEMENT.md`（文案唯一事实源，三版 banner + 禁用词表 + 四条例证），中英 README 首屏 `The Quasar of the Qt Quick world` / `ports that ecosystem` 改为 Inspired by 口径；② **随时更新 PROMPT.md**；③ 为 10 个 AI / 根壳组合根设计专属艺术级主题。主题实现：各组件注入私有 `_themeHue` / `_accent` 令牌（色相 168° 湖绿 → 283° 紫晶有序分布，独立 sat/val 系数 + 暗色 ×1.25 提亮，从 `NovaTheme.primary.hsvHue` 派生、换肤联动），身份装饰全改走 `_accent`；设计法源 `docs/prescript/GUIDE_COMPONENT_THEMES.md`（色值总表 + 架构铁律 + 「3 主题」问句如实澄清为明暗 × 专属色二维体系）。**零公共属性 / 零冻结面（指纹 `4f882374ad52262b` 不变）/ 零 qmldir / 零模块 URI / 零几何改动**；AI 包因新增 2 文档页 `af4385eddb5fc2ac` → `5699ae9ce0566c6b`（真实状态变更、非漂移）；qmllint 0 error / 594 warning 全在预算（零新增）、天花板 20/20（撞色 0 / 断链 0）、10 组件明暗双模式实例化 20 组全 Ready、色值逐项实测。**改动留工作树、发布归 CSA** |
| **Aurora Core 极光核辉光落地（12:52 · CSA 授权「世界级惊艳·其他你定你完现」）** | CSA 指令：① Q2 撤销——不加第 9 公共色（避免 additive minor 重签）；② Q3 授权完现、目标世界级惊艳、实现自定。**A 落地**：10 组件各注入私有 `_glow` 令牌（从本组件 `_themeHue` 派生、sat×0.78、val×1.28、暗色×1.5），焦点装饰升级为「亮核环 + 中性白芯」——6 组件同心白芯（Chat/Copilot/DE/Incubator/Mobile/SetupWizard）、4 组件首节点提亮（Agent/Desktop/Flex/Orbit）。**R 技术选型**：弃 MultiEffect（离屏渲染参数改动零像素差异、效果不可见却引入 import+成本）、弃 Gradient.Radial / RadialGradient（Qt 6.12 报 missing-property / 类型不存在）；采用纯几何亮核+白芯（100% 可见、零 import、零新增 warning）。**F 门禁**：qmllint 594 warning 全在预算零新增 · 撞色 0 · 断链 0（579 条）· API 冻结 144 / `4f882374ad52262b` 零漂移 · static 3/3 · pytest 53/53 · v2 15/15 · foundations 15/15 · domains PASS · 10 组件明暗实例化 20 组全过、色值逐项实测。设计法源 `docs/prescript/GUIDE_COMPONENT_THEMES.md §1.5 Aurora Core`（落点表 + 技术选型记录 + 铁律不变式 + 青出于蓝叙事闭环）。**零公共属性 / 零 qmldir / 零模块 URI / 零几何语义变化**；AI 包 `5699ae9ce0566c6b`→`0080fb7a9fd837cb`（+Aurora Core 文档段，真状态变更）。改动留工作树、发布归 CSA |
| **青色品牌资产立项 · 取色 +「青出于蓝」母题落地（12:43 · CSA 四问）** | CSA 四问：① 图中好看的颜色是什么名 → PIL 量化 + 定点采样，主色 `#22A6EF` hue 201°（星芒 `#0D9AE9` 202° / 发光点 `#40FAF9` 180°），色名 **Azure / Cerulean 蔚蓝**，中文「天青 / 蔚蓝」，恰是「青」；② 能否作 8 色之外第 9 色 → **可行但代价重**：`NovaTheme` 每个公共 `property` 逐项进冻结面 `props`，加色即 additive 公共 API → 宪法第 8 章 minor 重签 + a11y 契约登记 + 指纹变 + 全量门禁；轻量替代是私有 `_` 令牌不进公共面；③ 能否用于 10 主题 → **定点可行、全刷不可**：新青 hue 201° 与现有 SetupWizard 168° / FlexLayout 176° / Mobile 193° / Chat 216° 青系四色挤在 168–216° 带，全刷毁掉 168°→283° 有序分布且撞色；推荐只替换 1–2 个最贴切组件、或作独立品牌色；④ 上次 md 文档真意 → 「想引用**青出于蓝而胜于蓝**的用意」→ `docs/QUASAR_ACKNOWLEDGEMENT.md` §3 从「可选文艺版」升级为**品牌立意母题**（《荀子·劝学》本义 + 与 Inspired by 同构表 + 用法分档 + 与禁用词表边界），§5 补「典故即立意」，顶部加品牌立意行；AI 包离线拷贝同步。**「青出于蓝」叙事闭环**：Nova primary `#5B6EF5` hue 233°（蓝）→ 新青 hue 201°（青），正是「青取之于蓝而青于蓝」；与 Inspired by Quasar 口径同构。**Q2/Q3 属 additive 公共 API 变更，本轮只给评估、未改冻结面，待 CSA 拍板后开工**；Q4 已落地（纯文案层、指纹不变）。改动留工作树、发布归 CSA |
| **物理层拍平（12:05 · CSA 指令）** | CSA 指令「LayoutShell 子目录看着不爽，移到父目录」→ **20 个 QML 从九类子目录上移一层、9 个空目录删除、`qmldir` 改平铺、20 个头注释路径同步**。冻结面重签 `4f882374ad52262b`（反向归一化 `file` 精确还原 `68b34a408489b6a8` → 公共成员逐字零漂移）；九类分类下沉文档层台账、物理路径回归 1.0.x 已发布形态。生成物全链路重跑、法源锚点同步、全量门禁复验。**零类型名 / 零 URI / 零公共成员 / 零 import 变化** |
| 身份 / 分工 | 伙伴 = **CSA**（构想 / 方向 / 标准 / 验收拍板）；小诺 = **完现者**（实现 / 自检 / 验收 / 文档账本闭环）。**本文件是项目内投影；跨会话唯一入口是工作区根 `D://Porjects//PyCharm//PySide6//Nova//PROMPT.md`**，二者冲突以工作区根为准 |

## 一句话定位

pyside-nova：面向 PySide6 的企业级 QML 组件库，QML 元素 Quasar 生态化，
对标 **Quasar 2.35.5**（2026-11-22 复核纠正，原 2.26.0 过期），目标 `1.0.0-flagship` 封版（API 冻结 + LTS 24 个月）。

## 当前状态（1.0.0rc1 · **六期 RC1 收口：API 冻结审查——最后一公里已上道**）

- **公共 QML 类型 124 个已交付**（qmldir 导出口径）：Controls **91** + Behaviors **13**
  + Services **16**（单例 12 + 句柄动作 4）+ Design **4**
- **API 冻结（1.0.0rc1 · RC1 主线）**：`qmldir` 导出清单 = 冻结公共 API 面。双件制——
  `api/nova-api-1.0.0.json`（124 类型逐成员签名：`名字:类型` / `名字(参数)`，`_` 前缀私有成员
  不进面；指纹 **f2fd1b0eacf665f2**）+ `docs/API_FREEZE.md`（口径/统计/变更分级/例外/全量明细），
  均由 `gen_api_freeze.py` 生成**禁止手改**；门禁 `check_api_freeze.py` 三桶判定
  （破坏性 / 增量 / 纪律）+ 指纹自洽；`check_qmllint.py` 预算制（**0 error** + 593 warning
  分类挂账，只降不升）；`local_deploy.py` 交付前串跑 a11y → API 冻结 → qmllint 三道，红即拒包
- **冻结审查修掉 3 处真实缺陷**：NovaColorPicker 幽灵令牌 `NovaTheme.background`（不存在）→
  `surface`、`root.tint`（组件无此属性）→ `hasError ? negative : primary`；NovaText
  `readonly property var style` 覆盖 `Text.style` 枚举 → 私有 `_style`；画廊同款令牌 2 处
- **废弃机制落地**（宪法第 13 章政策 4）：`NovaUtils.logOnce(key,msg)` +
  `NovaUtils.deprecate(type, api, replacement, removedIn)`，同一 key 只播一次
- **国际化（0.16.1 主线）**：NovaI18n——locale 切换、`t()` 插值与三级回落（精确 → 主语言前缀 →
  en-US → key）、`tp()` CLDR 七语系复数（zh/ja/en/ru/ar/cs/pl 28 组参数化验证）、
  数字/货币/日期/相对时间格式化、`addBundle()` 热注入；内置 en-US/zh-CN 词典；指南见 `docs/I18N.md`
- **RTL 双轨镜像**：NovaTheme 方向令牌（isRtl/direction 联动）+ 6 组件适配
  （Pagination/Drawer/Layout/SlideItem/Breadcrumbs/StepperNavigation）；**逻辑侧语义恒定**
- **性能门禁全绿**（test_perf.py 3 项）：冷启动 ≤800ms / 全类型实例化 ≤5ms（两遍测量法 +
  KNOWN_HEAVY 白名单）/ 1000 行表格 ≤1700ms（实测大幅富余）
- **HiDPI 门禁全绿**（test_hidpi.py 4 项）：QT_SCALE_FACTOR 1.0/1.5/2.0 矩阵，dpr 联动 +
  逻辑几何恒定；Nova.Runtime 上报 devicePixelRatio/scaleFactor
- **a11y M2 补差完成**：NovaTree 方向键游标（roving cursor，RTL 键互换）、NovaDialogShell
  焦点陷阱（Tab 循环 + Esc 还焦，应用级事件过滤器承载——坑位 45）
- **可访问性契约（0.16.0 建立，0.16.1 维持）**：124 类型登记 **interactive 32 / semantic 28 /
  decorative 64**（NovaI18n 为 decorative 单例）；门禁双通道 `scripts/check_a11y.py` +
  `tests/test_a11y.py` 24 项
- **诚实边界**：复数为 CLDR 精简实现（七语系，未覆盖全部语言卡片）；性能为门禁口径
  （24h 压测工具已就绪 + 冒烟通过，**真实 24h 全量长跑留 CI**）；屏读器真机回归（NVDA）随 B3
  安排；组件内部组合色逐件像素采样未做
- **工程化外环（0.16.2 主线）**：
  视觉回归门禁（明暗 × 5 断点 × 24 页 **240 基线**，check_visual.py 像素 diff 容差 12/1%，
  默认 smoke 秒级、CLI --visual-full 全矩阵 ~150s）；
  外部输入消毒（NovaUtils.sanitize 五函数 + runtime 四 Slot + 9 处 textFormat: PlainText
  组件加固 + 32 项测试，对标 2.32~2.35 安全硬化）；
  CycloneDX SBOM（gen_sbom.py 零依赖离线）+ OSV CVE 周巡（check_cve.py + .cve-ignore
  带理由，首轮 0 未忽略漏洞）；
  一键打包 build_app.py（PyInstaller onefile 185.7MB 启动自检过；≤60MB 为诚实边界——
  Qt 运行时物理下限，uv shared-python 构建路径已记录）；
  MkDocs 文档站（material 可搜索 15 页 + 画廊预览 24 图 = "在线示例"等价呈现）
- **诚实边界**：复数为 CLDR 精简实现（七语系）；24h 压测**工具链已交付**（check_soak.py /
  test_soak.py / soak_mem.py，冒烟 72s 8896 轮 RSS 84.6→84.9MB 平坦、斜率 -2.78MB/h、
  门禁退出码 0），真实 24h 全量长跑留 CI 执行 `--hours 24`；负载为稳态对象池 + 采样前双 GC，
  刻意不纳入「反复建销复杂组件」（Qt 6.12+PySide6 固有 0.3-0.5MB/次开销，纯 Qt Quick 同样复现）；
  屏读器真机回归（NVDA）封版前人工安排；应用打包 ≤60MB 未达（Qt 物理下限 185MB，方向：
  upx / QML 预编译 / 插件裁剪）；安装器与代码签名需平台证书
- **测试 454 项全绿**（427 + 1.0.0rc1 新增 27：冻结面/反例三连/纪律/qmllint 预算/废弃机制/
  三处缺陷回归；全矩阵 1 项由 check_visual.py CLI 承载、视觉 smoke 1 项跳过为设计如此）
  + 视觉基线 240 张；测试基建维持
  **全进程单 QML 引擎**（坑位 42）+ **qrc:/ 单斜杠纪律**（坑位 48，SIGSEGV 总根因）
- **Sprint 进度**：Sprint 1 ✅(0.5.0) → 2 ✅(0.6.x) → 3 ✅(0.7.0) → 4 ✅(0.8.0)
  → 二期 A ✅(0.9.0) → 二期 B ✅(0.10.0) → 三期 A ✅(0.11.0) → 三期 B ✅(0.12.0)
  → 四期 A ✅(0.13.0) → 四期 B ✅(0.14.0) → 五期 A ✅(0.15.0)
  → 五期 B1 ✅(0.16.0 可访问性) → 五期 B2 ✅(0.16.1 i18n+RTL+性能+HiDPI)
  → **五期 B3 ✅(0.16.2 工程化外环：视觉回归+消毒+SBOM/CVE+打包+文档站)**
  → **六期 RC1 ✅(1.0.0rc1 API 冻结审查) → RC2 24 条验收 → 1.0.0-flagship 封版**
- **七层成熟度**：L0 100% / L1 100% / L3 100% / L4 44% / L5 95% / L2 70% / **L6 90%（RC1 冻结治理入册）→ 封版目标 95%**
  （a11y 双门禁 + perf/hidpi 门禁入工程化）；非功能性轴：可访问性 90%→**95%**（余 5% = 组合色
  逐件采样 + NVDA 真机回归）、国际化 0%→**90%**（余 10% = 更多语言词典包 + 术语表管理）、
  性能 **门禁化**（24h 压测工具就绪+冒烟通过，全量长跑留 CI）、HiDPI **门禁化**（真机多屏抽查待 B3）
- **表单统一契约**：`label/hint/error/readonly/disable/clearable/rules` 贯穿表单族（对标 use-field +
  use-validate 36 props 逐项对账）；**受控模式**：组件只 emit 不自写（Quasar v-model 语义 1:1，
  防绑定环），宿主绑定 + 信号写回——数据体系全族沿用（selected/expanded/sortBy/page 均受控）
- **数据体系契约**：选中/勾选一律**按键值比较**（rowKey 或 JSON 全等，坑位 27）；
  树派生索引**显式失效**（onNodesChanged/on_LazyStoreChanged → _refreshDerived + _rev，坑位 28）
- **图标集数据纪律**：`src/pyside_nova/qml/Nova/Design/IconSets.js` 是生成物（scripts/gen_iconsets.py
  从 npm quasar@2.35.5 icon-set/*.js 提取），**禁止手改**；基线包临时解包目录 /tmp/qbase 可重建
- **基线复核（0.13.0）**：Quasar 2.35.5→2.35.6 dist/api/*.json 逐文件 diff **零漂移**（纯补丁版），基线维持 2.35.5 口径
- **基线开工复核（0.15.0）**：Quasar 最新 release 2.35.2（2026-10-19）；@quasar/mcp v1.x Active
  （2026-09-17 上线，六工具口径已 1:1 对标）；quasar 2.33.0 AI-ready out of the box 口径核实
- **交付节奏条款（0.6.2 新颁，0.7.0 首次完整执行）**：Sprint 是最小交付单元——一次收口、
  一个版本号、一套六份交付物；中间件只 git 提交不单独打全包
- **弹层纪律（0.14.0）**：可关闭弹层挂 NovaOverlayHost.registerPopup + **Component.onDestruction
  注销**（泄漏会级联污染后续测试）；关闭原因上报口径 ok/cancel/backdrop/escape/api；auto-close 类
  语义动态挂接子项 clicked（坑位 35）；受控契约沿用（Menu/DialogShell/BottomSheet/PTR 均 emit-only）
- **规划核对纪律（0.14.0）**：NovaScrollObserver 已于 Behaviors 0.7.0 交付——本期发现 Controls
  新建同名类型造成跨模块歧义，已删除并关闭规划条目；同名交付前先 grep 全部 qmldir
- **导航体系契约（0.13.0）**：受控契约全族沿用（Tabs/Panels/Stepper 的 modelValue 与
  Fab 的 open 均只 emit 不自写）；ExpansionItem group 手风琴经 ExpansionGroups.js 注册表
  互斥——被收起方走自身 updateModelValue(false) 受控上报；Breadcrumbs 激活色 1:1
  对标 2.35.6 QBreadcrumbs.js；Stepper 状态图标解析 1:1 对标 StepHeader.js
- **可访问性契约（0.16.0）**：三分类制——interactive（role+name+键盘入口+按键路径+焦点环五件套）/
  semantic（role+name）/ decorative（**禁止**挂 Accessible.* + `// a11y: decorative` 标记）；
  键盘路径必须走与鼠标同一个 emit 出口（不得绕过受控契约）；装饰容器不挂语义是为了避免屏读器噪声，
  是审计结论不是遗漏——新增类型不登记分类即门禁失败
- **长尾契约（0.15.0）**：NovaEditor 实现口径留痕（QML 无 contenteditable → 标记编辑 + toHtml
  导出，契约 1:1）；NovaMorph 接管目标可见性（旧隐/新显命令式切换，目标 visible 勿再绑定）；
  Morph 初始活动元素 = 组内首个完成注册成员（onCompleted **逆序**执行 → 通常是声明序最后的）
- **环境约定**：用户 Dell Win11 · PySide6 6.12.0 · 单人开发 · PyPI + GitHub
- **接续方式**：粘贴 `PROMPT.md`（自包含，快照已内联）；快照改动后须重跑 `gen_prompt.py`

## 必读文件（按需深读，非预读）

0. `docs/MASTER_PLAN.md` —— **全生态六期总规划**（排期与验收以它为准）

1. `docs/CONSTITUTION.md` —— 架构宪法（第 0~13 章准则 + 迭代记录表，工程纪律最高法源）
1.2. `docs/COMPOSITION_CONSTITUTION.md` —— 组合组件宪法（Layout Shell 子法，第 0~9 章）：
  凡新增/改造 Shell 类组合组件必读；令牌·目录·冻结援引母法，本文件只定义组合纪律；
  `docs/layout_shell/` 历史四稿（0.9.x 时代）已按「不将就」信条删除；其 FROZEN 表述与虚构 API 一律作废，勿再参考。现行权威事实源：`docs/COMPONENT_LIST.md` + `api/nova-api-1.2.0.json` + 模块 README
0.5. `docs/ECOSYSTEM_PARITY.md` §0.5 —— 2.26→2.35 基线漂移审计（增量对照表）
1.5. `docs/A11Y.md` —— 可访问性手册（三分类契约/键盘约定/AA 派生/已知差距/坑位 38~41）
2. `docs/PARITY.md` —— 全量对标审计（逐属性/事件/槽/model）
2.5. `docs/API_FREEZE.md` —— **1.0 冻结清单签署件**（口径/变更分级/例外/124 类型明细）
3. `CHANGELOG.md` —— 版本史（含 Qt 6.12 坑位沉淀）
4. `CONTRIBUTING.md` —— 宪法落地细则

## 不可违反的约定（速查）

- 头注释：第 1 行 `src/` 起始子路径，第 2 行文档素材说明；qmldir 只用 `#`
- 命名红线：基调色 `tint`；禁 `on*` 属性；主题模式 `isDark` / `setDark()` / `toggleDark()`；品牌色 `dark`（$dark 1:1）
- 槽机制：默认槽 `default property alias`、命名槽组合子组件、作用域槽 `Component delegate`
- 组合组件：五标准槽位 `headerSlot/sidebarSlot/contentSlot/footerSlot/overlaySlot` 一律 alias 映射；
  令牌唯一门面 `NovaTheme`（无 `Theme` 单例），真名 `NovaBtn`/`NovaText`/`NovaMotion`；
  Shell 必须进 qmldir 入冻结面，`Composite/` 黑户文件与日期流水头注释禁止（组合组件宪法第 2/6/9 章）
- 断点接入唯一方式：`Component.onCompleted: NovaScreen.source = window`
- API 冻结纪律：`api/nova-api-*.json` 与 `docs/API_FREEZE.md` 是生成物**禁止手改**；
  公共面任何变化必须走 `check_api_freeze.py` 红 → 评估分级 → 重签 → CHANGELOG（宪法第 13 章）
- 交付纪律：升版 → CHANGELOG → 宪法记录表 → 本文件 → `gen_prompt.py` 刷新 PROMPT → `local_deploy.py --zip`

## 已知坑位（Qt 6.12 实战沉淀）

1. `on*` 前缀属性名导致整个模块加载失败
6. 断点判断勿在组件自身 Component.onCompleted 做——创建期 parent 宽度是瞬态值（0），策略应由宿主（如 NovaLayout）持有
2. `property color color` 与 Rectangle 基类冲突 → 用 `tint`
3. 纯 QML 不支持自定义 attached property（`attach` 语法 M1 经 PySide6 `QML_ATTACHED`）
4. qmldir 不支持 `//` 注释
5. 单例属性不可对象体内声明式绑定（会解析成 attached）
7. QtObject（含单例）体内不可直接声明 `Component { }` 子项——报 "Cannot assign to non-existent
   default property"；必须走 `property Component xxx: Component { … }` 内联（0.6.0 实战沉淀）
8. `qmlRegisterSingletonInstance`（PySide6）把实例交给 QML 树管理：组件销毁即 delete Python 对象，
   二次访问报 "Internal C++ object already deleted"，且全局单实例无法多引擎共享 →
   一律用**工厂式 `qmlRegisterSingletonType`**（0.6.2 沉淀）
9. 服务单例引用裸 JS 对象当状态条目：属性变化无通知，句柄绑定不刷新 → 条目必须是 QML 对象
   （property Component 内联 QtObject）（0.6.2 沉淀）
10. 动态 overlay 的可见性与宿主 attach（强制 visible=true）冲突：可见性门控放内部 `_started`，
    根节点常驻、子项受控（0.6.2 沉淀）
11. QML 测试里 Python 引用保不住 QML 顶层 Window（JS GC 不认 Python 引用）→ 行为断言一律走
    QML 侧函数，不摸 Python 侧窗口 wrapper（0.6.2 沉淀）
12. QML 派生 Item 里重声明 `x/y/active` 报 "Cannot override FINAL property"（Qt 6.12 FINAL 成员）；
    `enabled` 不重声明直接用 Item.enabled（继承语义天然正确）（0.7.0 沉淀）
13. 行为根节点设 visible:false 会阻断内部 MouseArea 收事件（不可见 Item 不参与事件分发）——
    纯逻辑行为可以关，带指针通道的绝不能关（0.7.0 沉淀）
14. 组件默认属性把子项转交内部容器（如 NovaBtn 的 contentHost）时，子项的 parent 不是宿主本体，
    `target: parent` 拿不到宿主信号 → 向上遍历找第一个带目标信号的祖先（0.7.0 沉淀）
15. PySide 把 QML Window 包装成 QWindow，metaobject 里没有 QML 定义的方法，函数调不到 →
    测试用 QML 侧 QtObject 代理（call0/1/2 按实参个数分派——QML 函数无可选参数）+ 强引用窗口（0.7.0 沉淀）
16. 观察器只报"变化"：重新订阅必须重置上次判定并补一帧当前状态，否则状态未变就永远等不到回调
    （基线 reobserve 同款语义）（0.7.0 沉淀）
17. V4 引擎下 `1<<24` 参与 `|` 位运算拼 hex 会静默串色（#5B6EF5→#769397）→ 十六进制一律逐字节
    toString(16) 补零；formatDate 的 literal `[...]` 语义是"原样输出"不是"解析后插值"（0.8.0 沉淀）
18. QML Animation/NumberAnimation **没有 `enabled` 属性**：不参与的维度用 from==to 兜底（0.8.0 沉淀）
19. `Component.createObject` 创建的 Timer **不会自动启动**：必须显式 start()/restart()
    ——throttle 尾跑曾因此静默失效（0.8.0 沉淀）
20. QML 无 requestAnimationFrame / crypto.randomUUID：frameDebounce 用 16ms 单发 Timer 等价 rAF；
    uid 用时间戳+计数+随机 v4 形态降级留痕；debounce/throttle 的 Timer 用 `property Component`
    内联创建（0.8.0 沉淀）
21. 子类再声明 `signal valueChanged(var)` 与基类属性的自动通知信号撞名 → "Duplicate signal name:
    invalid override"（NovaField.value 的 valueChanged 即自动信号）；值通知一律走属性变更信号，
    自定义信号换名（0.9.0 沉淀）
22. 受控组件写自身 modelValue（self-assign）会断宿主绑定并触发绑定环告警；对标 Quasar v-model：
    组件只 emit 不自写，toggle()/select() 返回下一值由宿主写回（0.9.0 沉淀）
23. `readonly color x: …` 漏 property 关键字报 "Expected token `:`"——readonly 必须配 property
    连用（0.9.0 沉淀）
24. 缓存型 `readonly property var _norm: _normalize(mv)` 在信号处理器内引用时可能拿到重评期
    undefined——处理器内改直接函数调用，不走缓存绑定（0.10.0 沉淀）
25. `palette`/`show`/`hide` 与 Qt 内建 Item 成员撞名 → 覆盖告警或 Duplicate method：改
    paletteColors/shown/hidden（0.10.0 沉淀）
26. local_deploy 装出 site-packages 真实拷贝后，pytest 的 `import pyside_nova` 会命中旧 QML
    （组件 is not a type 随机爆）——交付后必须 `pip install -e . --no-deps` 复位（0.10.0 沉淀）
27. **Qt6 信号参数会把 JS 对象/数组深拷贝**——updateSelected(rows) 这类带对象数组参数的信号
    送达宿主时引用一致性已丢失；选择/勾选语义一律按键值（rowKey 或 JSON 全等）比较，
    勿用 `===`/`indexOf` 引用比较（0.11.0 沉淀）
28. 绑定内经函数间接读取的依赖跟踪不可靠 + 递归索引漏层——NovaTree `_index` 只递归 `children`
    静态层，懒加载回填层（`_lazyStore`）永不入索引，且函数内读 `_lazyStore` 的重赋不触发重评；
    改显式失效：onNodesChanged/on_LazyStoreChanged/onFilterChanged → _refreshDerived() + _rev
    版本号供渲染绑定引用（0.11.0 沉淀）
29. inline component 裸名赋给 `delegate:`（`delegate: TableRow`）在 Qt 6.12 下**恒 count 0**
    且零报错——必须带花括号实例化 `delegate: TableRow { }`（0.12.0 沉淀）
30. 创建期可见性求值时序会让 Column 定位器错过自动布局（委托 implicitHeight 恒 0，翻可见性
    才补）——显式绑定 `height: childrenRect.height` 兜底（子项高度不依赖父高，无环）（0.12.0 沉淀）
31. QtMultimedia `Video` 元素创建即初始化 FFmpeg 音频上下文，无音频服务环境（CI/沙箱）**进程
    挂死**——播放器必须按 src 惰性创建（0.12.0 沉淀）
32. `ListView` reuseItems 与含自定义子组件的 delegate 组合在 Qt 6.12 触发**进程退出段错误**
    （包装 Component 亦不能规避）——NovaTable 虚拟滚动暂缓 reuseItems，cacheBuffer 兜底；
    布尔型 exit code 必须以 subprocess/直接退出码核验，管道 `| tail` 会吞 pytest 退出码
    （0.12.0 沉淀）
32. 占位/错误图若走"source 随 status 切换"成 source↔status 绑定环——分层叠加（主图常驻 +
    占位/错误图层按态覆盖）；坑位 28 再验证：columns.map()/宿主探测等函数调用绑定依赖不可靠，
    派生数据变更点一律显式失效（0.12.0 沉淀）
33. QML `Item` 无 `Component.onDestroyed`——析构钩子是 **`Component.onDestruction`**，
    写错整文件加载失败（0.13.0 沉淀）
35. TapHandler 与子项 MouseArea 同区域时被独占饿死——auto-close 类语义须**动态挂接子项
    clicked 信号**（connect + 登记防重复）；弹层组件销毁必须 unregisterPopup（0.14.0 沉淀）
34. Text/Item 级基元元素**没有 `background` 属性**（Control 系 API）——徽标底色须手写
    包裹 Rectangle；布尔型 JS `join(',')` 产出小写 `true/false`，测试断言小写口径
    （0.13.0 沉淀）
36. `.pragma library` JS 在多组件实例 import 场景实测呈现 **per-importing-file 实例化**
    （同 group 两实例互相看不见对方注册）——跨实例共享注册表用 **QML singleton**
    （NovaMorphPool 先例，0.15.0 沉淀）
38. **`Accessible` 是附加属性，只能在 Item 作用域内调用**：单例（QtObject）或 `Connections` 里调
    `Accessible.announce()` 报 *"must be attached to an object deriving from Item or Action"* →
    播报必须落在 Item 的成员函数里（`NovaLiveRegion.speak()`，0.16.0 沉淀）
39. **`Accessible` 没有 `disabled` / `defaultAction` / `ignoresAutomaticName`**：禁用态唯一有效途径是
    `Item.enabled: false`（实测 `QAccessible` 接口随之 `state().disabled = true`）；另：
    `Keys.onEndPressed` 在 Qt 6.12 **不存在**，End 走 `Keys.onPressed` + `Qt.Key_End`（0.16.0 沉淀）
40. **QML `color` 的 r/g/b 是 0~1 浮点**：把 color 值当 0~255 处理会让对比度恒等于 1.0
    （`NovaUtils.colors.luminosity` 旧实现即踩此坑，0.16.0 已修 + `_channels255` 归一化）
41. **`QTest` 键位测试必须同时强引用 `QQmlComponent`**：`component.create()` 出的 Window 所有权属于
    组件，组件被 GC 后窗口立即析构（*Internal C++ object already deleted*）（0.16.0 沉淀）
42. **多个 `QQmlEngine` 各自析构在 Qt 6.12 会间歇 SIGSEGV**（A 销毁后 B 再建组件 20~60% 概率崩，
    与用例无关）→ QML 测试全进程共用单引擎（`tests/conftest.py`），模块收尾只 close 窗口不删引擎；
    Window 活到解释器退出而 app 已析构是第二类退出期崩溃，靠 session 收尾规避（0.16.0 沉淀）
43. **Qt 6.12 的 `Qt.formatDate` 三参重载实际不存在**：`Qt.formatDate(date, localeName, pattern)`
    被解析为 `(date, locale)` 两参版、pattern 静默丢弃 → 自定义 pattern + 自定义 locale 必须走
    **`Qt.locale(name).toString(date, pattern)`**（本地化字段齐全，NovaI18n.formatDate 即此实现，
    0.16.1 沉淀）
44. **`QQmlExpression` + `creationContext` 对非 Item 对象间歇 SIGSEGV**：用组件的 creationContext
    求值含单例名的表达式，对象非 Item 时崩溃概率高 → 统一「**QML 内定义 helper 函数/只读属性 +
    Python 直调/直读**」模式，Python 侧不构造表达式（0.16.1 沉淀）
45. **Tab 键在 QML Keys 层拦不到**：Tab 在 `QQuickItem::keyPressEvent` 的 C++ 默认实现中被消费，
    不冒泡（`Keys.BeforeItem` 也拦不到）→ **应用级事件过滤器**（`QGuiApplication.installEventFilter`
    拦 KeyPress+Tab/Backtab，DialogShell 焦点陷阱方案）。
    同批沉淀：PySide slot 的 QObject 参数 wrapper 是**临时的**（weakref 立即失效，注册表须强引用）；
    wrapper 静态类型 QObject（QQuickItem 方法不可见，判定逻辑移 QML 内）；
    `win.property("activeFocusItem")` 的 QQuickItem* 无 converter；
    **`Item.window` 普通属性在 JS 层返回 undefined** → 必须用 attached **`Item.Window.window`**
    （0.16.1 沉淀）
50. **`qmllint` 诊断全部走 stderr**（stdout 只剩源码片段）：`capture_output=True` 只读 stdout
    会得到「0 warning」的假绿灯——预算门禁必须 `stderr=subprocess.STDOUT` 合并两股流
    （1.0.0rc1 沉淀；同批：该版本对 block-scope var 告警**不带 `[category]` 尾缀**，按消息归类）
51. **模块限定类型名不能 `split(".", 1)`**：`Nova.Behaviors.NovaMorph` 会切成
    `Behaviors.NovaMorph`（模块名自身带点）→ 一律 `rsplit(".", 1)`；qmldir 的
    `singleton <名> <版本> <文件>` 版本位比普通行右移一格，解析要按 `singleton` 前缀偏移
    （1.0.0rc1 沉淀；两处都曾让冻结清单/文档表格悄悄写错名字）
52. **`check_qmllint.py` 在中文 Windows 交付机假红灯**：① PySide6 包内是 `qmllint.exe`，
    `Path.exists()` 不补后缀且 Scripts/ 无 `pyside6-qmllint` 入口 → 显式列 `qmllint`/`qmllint.exe`
    两种候选；② `subprocess.run(text=True)` 走 locale 默认编码（中文 Windows=GBK），诊断含
    UTF-8 路径时解码崩 → 显式 `encoding="utf-8", errors="replace"`。两者都让门禁"环境问题"
    与"产品问题"混淆——**门禁红灯先分清是工具/环境还是产品，勿据假红灯判产品缺陷**
    （1.0.0rc1 交付后验收实战沉淀；修复后真实退出码 0）
49. **全矩阵视觉长跑后解释器收尾期 GC 崩溃**：240 截图 × 150s 跑完 pytest 报告后，
    finalizing GC 触发 `none_dealloc: refcount error in a C extension`
    （deleteLater / 显式 close / gc.collect 均无效）→ conftest `pytest_unconfigure`
    硬退出（`os._exit(0)`，报告输出已完成，保 CI 退出码语义）（0.16.2 沉淀）
    **【2026-11-25 21:47 CSA 指令结案归档：议题结案、非交付完成】**：`-k` 子集在 `form_env._pump()`
    亦复现；诊断定位 `runner.py:150 item.funcargs = None` 后 shiboken refcount / 堆损坏
    （`0xc0000374` / access violation）；14 类工程修复全部无效，独立进程 8/8 稳定。
    **未交付代码修复**；真正修复需 CSA 拍板隔离验证 PySide6 降级（6.11.3 / 6.10.3）
    或改测试架构为分批独立进程。产品 QML / 已推送 `5c94186` / 已发布 1.0.0 包不受影响，
    试验改动已全部回退、工作树干净。详见 `CHANGELOG.md` [Unreleased] 与工作区日志 21:45 / 21:47 段。
46. **QML 函数从 Python wrapper 调用返回未求值 MetaFunction**：`host.someFunc()` 拿到的是
    MetaFunction 对象而非结果 → 承载结果的用 `readonly property int xxx`，Python
    `setProperty`/直读属性（0.16.1 沉淀）
47. **性能测量须两遍法**：首建含 QML 编译冷缓存（同一进程内同类型第二次才是纯实例化成本）；
    NovaDate/NovaEditor 首建 11~15ms 属日历/文档网格固有成本，白名单显式登记（KNOWN_HEAVY），
    不静默放行（0.16.1 沉淀）
48. **`qrc://` 双斜杠 URL 是间歇 SIGSEGV 总根因**：shiboken 把 `qrc://xxx.qml` 解析为带 authority
    的路径，`QQmlComponent.setData(data, QUrl("qrc://…"))` 在干净引擎早期确定性段错误
    （exit 139，独立脚本与 pytest 交错复现，历劫多引擎/import 顺序/NovaTheme 热身等假设全部排除后定位）
    → **全部测试代码统一 `qrc:/` 单斜杠**；纪律：test_smoke 首两个 case 先建 NovaTheme 探针
    （0.16.1 沉淀）
49. **全矩阵视觉长跑后解释器收尾期 GC 崩溃**：240 截图 × 150s 跑完 pytest 报告后，
    finalizing GC 触发 `none_dealloc: refcount error in a C extension`
    （deleteLater / 显式 close / gc.collect 均无效）→ conftest `pytest_unconfigure`
    硬退出（`os._exit(0)`，报告输出已完成，保 CI 退出码语义）（0.16.2 沉淀）
    **【2026-11-25 21:47 CSA 指令结案归档：议题结案、非交付完成】**：`-k` 子集在 `form_env._pump()`
    亦复现；诊断定位 `runner.py:150 item.funcargs = None` 后 shiboken refcount / 堆损坏
    （`0xc0000374` / access violation）；14 类工程修复全部无效，独立进程 8/8 稳定。
    **未交付代码修复**；真正修复需 CSA 拍板隔离验证 PySide6 降级（6.11.3 / 6.10.3）
    或改测试架构为分批独立进程。产品 QML / 已推送 `5c94186` / 已发布 1.0.0 包不受影响，
    试验改动已全部回退、工作树干净。详见 `CHANGELOG.md` [Unreleased] 与工作区日志 21:45 / 21:47 段。
37. QML `Component.onCompleted` 按**创建完成逆序**执行（声明序最后的先 complete）——
    组内"首个完成注册者成为默认活动元素"通常是声明序最后的成员；依赖顺序的注册表
    语义须按此口径设计并写进测试（0.15.0 沉淀）
- ~~Sprint 2 L4 服务~~ ✅ 0.6.0~0.6.2（Notify 29 项/Dialog 27 项/Loading 11 项对账 + Storage/App/Platform；L4 44%）
- ~~Sprint 3 L3 行为~~ ✅ 0.7.0（九件一次收口；L3 100%）
- ~~Sprint 4 L0/L5 基础层~~ ✅ **0.8.0 收口（Nova.Design 三单例 + NovaText/NovaTransition；
  14 套图标集 + provider 注册表 + 八通道解析；colors 12 + date 21（44 token）+ format 6 + is 5 +
  debounce/throttle/uid；动效 15 预设；排版 12 级；画廊 15 页；149 项测试；L0 100%/L5 95%）**
- ~~二期 Sprint A 表单核心~~ ✅ 0.9.0；~~二期 Sprint B 输入进阶~~ ✅ **0.10.0（NovaRange/NovaDate
  自研日历/NovaTime 时钟面盘/NovaColorPicker 色域盘/NovaOptionGroup/NovaForm/NovaBtnToggle/
  NovaPopupEdit 八件；L2 16%→24%；画廊 17 页；199 项测试）**
- ~~二期 Sprint A 表单核心~~ ✅ 0.9.0；~~二期 Sprint B 输入进阶~~ ✅ 0.10.0（八件；L2 16%→24%）
- ~~三期 Sprint A 数据体系~~ ✅ **0.11.0（NovaTable+Th/Td/Tr / NovaTree / NovaPagination /
  NovaList·NovaItem(+Section/Label) / NovaMarkupTable / NovaInfiniteScroll / NovaVirtualScroll /
  NovaScrollArea 九件 14 类型；L2 24%→34%；画廊 18 页；225 项测试）**
- ~~三期 Sprint B 媒体体系~~ ✅ **0.12.0（NovaImg/NovaResponsive/NovaVideo/NovaParallax/
  NovaCarousel+Slide+Control/NovaTimeline+Entry/NovaChatMessage 十类型 + NovaTable 增强
  虚拟滚动/服务端模式/loading；L2 34%→43%；画廊 19 页；250 项测试）**
- ~~四期 A 导航体系~~ ✅ **0.13.0（NovaTabs/Tab/TabPanel/TabPanels + NovaBreadcrumbs/El +
  NovaStepper/Step/StepperNavigation + NovaExpansionItem + NovaToolbar/Title +
  NovaFab/FabAction 14 类型；L2 43%→54%；画廊 20 页；271 项测试；基线复核 2.35.6 零漂移）**
- ~~四期 B 弹层与反馈~~ ✅ **0.14.0（NovaMenu/DialogShell/PopupProxy/Tooltip/BottomSheet +
  Spinner×8/Skeleton/InnerLoading/AjaxBar+LoadingBar 服务/Banner/Bar/NoSsr/PullToRefresh/
  ResizeObserver；L2 54%→68%；画廊 21 页；308 项测试；ScrollObserver 规划核对不重复）**
- ~~五期 A 长尾组件~~ ✅ **0.15.0（NovaEditor 轻量富文本（标记编辑+HTML 导出同语义留痕）/
  NovaSlideItem 左右滑动面板/NovaMorph group 形变 + NovaMorphPool 单例/NovaIconGenie CLI
  37 产物/AI-ready 文档包 + Nova MCP server 六工具；L2 68%→70%、L3 Morph 补齐、L6 70%→75%；
  画廊 22 页；322 项测试；坑位 36~37 沉淀）**
- **五期 B2（下一步）国际化 + 性能（v0.16.1）** ✅ **0.16.1 收口（NovaI18n 单例 + RTL 双轨镜像
  6 组件 + 性能门禁三指标（冷启动 ≤800ms / 组件 ≤5ms / 1000 行表格 ≤1700ms）+ HiDPI 1.0~2.0 矩阵；
  a11y M2 补差：Tree 方向键游标、Dialog 焦点陷阱（NVDA 真机回归移 B3）；画廊 23 页；394 项测试；
  坑位 43~48 沉淀，其中 48（qrc:// 双斜杠段错误）为间歇崩溃总根因）**
- ~~五期 B3 工程化外环（v0.16.2）~~ ✅ **0.16.2 收口（视觉回归 240 基线 + 外部输入消毒 32 项
  + SBOM/CVE 周巡 + PyInstaller 打包自检 + MkDocs 文档站可搜索；画廊预览页 = 在线示例等价；
  L6 80%→90%；427 项测试；坑位 49 沉淀）**——**五期全部完成**
- **六期（下一步）封版 1.0.0-flagship**：~~RC1 API 冻结审查~~ ✅ 1.0.0rc1 →
  **RC2 24 条封版验收清单全勾**（ECOSYSTEM_PARITY 第 6 节；24h 压测工具就绪+冒烟通过（全量长跑留 CI），
  余项 3 条：NVDA 真机 / 安装器签名 / 迁移指南 + LTS）→ 1.0.0 正式封版
- 详细差距与 DoD：`docs/ECOSYSTEM_PARITY.md`

## 最近一次交付

- **1.0.0rc1：六期 RC1 收口 · API 冻结审查**
  （124 类型逐成员签名快照 `api/nova-api-1.0.0.json` + 签署件 `docs/API_FREEZE.md`；
  新增门禁 `check_api_freeze.py`（三桶 + 指纹自洽）与 `check_qmllint.py`（0 error + 593
  warning 分类预算）；local_deploy 交付前三门禁串跑；冻结审查修掉 3 处真实缺陷
  （ColorPicker 幽灵令牌/无主 tint、NovaText.style 覆盖 Text.style）；
  废弃机制 NovaUtils.logOnce·deprecate；测试 427→454；坑位 50~51）

- **0.16.2：五期 Sprint B3 收口 · 工程化外环一次交付**
  （视觉回归门禁 240 基线明暗 × 5 断点 + 外部输入消毒 NovaUtils.sanitize/runtime Slot/
  textFormat 加固 9 处 + CycloneDX SBOM + OSV CVE 周巡 + build_app.py 打包自检 +
  MkDocs 可搜索文档站 + 画廊在线预览页；测试 394→427；坑位 49 沉淀）

- **0.16.1：五期 Sprint B2 收口 · i18n + RTL + 性能 + HiDPI 一次交付**
  （NovaI18n 服务单例（locale 切换/t() 三级回落/tp() CLDR 七语系复数/formatNumber·Currency·
  Date·Relative/addBundle 热注入）+ RTL 双轨镜像（Pagination/Drawer/Layout/SlideItem/
  Breadcrumbs/StepperNavigation，逻辑侧语义恒定）+ 性能门禁 test_perf.py 三指标 + HiDPI 门禁
  test_hidpi.py 矩阵 + a11y 补差（Tree roving cursor / DialogShell 焦点陷阱）+ docs/I18N.md +
  画廊第 24 页；测试 343→394；类型 123→124）
- **0.15.0：五期 Sprint A 收口 · 长尾组件一次交付**
  （NovaEditor 轻量富文本（toolbar 分组/execCmd 命令族/toHtml 导出/受控 guard）+
  NovaSlideItem 左右滑动动作面板 + NovaMorph 元素形变（ghost 几何过渡）+ NovaMorphPool
  singleton 注册表 + NovaIconGenie 图标全套 CLI + AI-ready 版本化 API 文档包 +
  Nova MCP server 六工具；画廊第 22 页；测试 322 项；类型 117→120）
- **0.14.0：四期 Sprint B 收口 · 弹层与反馈一次交付**
  （NovaMenu + NovaDialogShell 关闭原因上报 + NovaPopupProxy 断点路由 + NovaTooltip +
  NovaBottomSheet + NovaSpinner 八变体 + NovaSkeleton/NovaInnerLoading/NovaAjaxBar/
  NovaLoadingBar 服务/NovaBanner/NovaBar/NovaNoSsr/NovaPullToRefresh 四边拉动/
  NovaResizeObserver；画廊第 21 页；测试 308 项；L2 54%→68%；类型 100→117）
- **0.13.0：四期 Sprint A 收口 · 导航体系 14 类型一次交付**
  （NovaTabs/Tab/TabPanel/TabPanels 受控标签页族 + NovaBreadcrumbs/El + NovaStepper/Step/
  StepperNavigation 状态图标 1:1 解析 + NovaExpansionItem group 手风琴 + NovaToolbar/Title +
  NovaFab/FabAction stagger 级联 + hover 契约；画廊第 20 页；测试 271 项；L2 43%→54%）
- **0.12.0：三期 Sprint B 收口 · 媒体体系十类型 + Table 增强一次交付**
  （NovaImg 三态占位/ratio + NovaResponsive 等比 + NovaVideo 惰性播放器 + NovaParallax 视差 +
  NovaCarousel 受控全家桶（arrows/navigation/autoplay/infinite/swipeable/覆盖控件）+
  NovaTimeline 三布局 + NovaChatMessage 收发气泡 + NovaTable 虚拟滚动/服务端模式/loading；
  画廊第 19 页；测试 250 项；L2 34%→43%）
- **0.11.0：三期 Sprint A 收口 · 数据体系九件 14 类型一次交付**
  （NovaTable 排序/过滤/分页/多选/展开行 + NovaTree strict 级联/懒加载/过滤 +
  NovaPagination + NovaList 手风琴四件 + NovaMarkupTable + NovaInfiniteScroll +
  NovaVirtualScroll 5000 行虚拟化 + NovaScrollArea；画廊第 18 页；测试 225 项；L2 24%→34%）
- 0.10.0：二期 Sprint B 收口 · 输入进阶八件一次交付（自研日历/时钟面盘/取色器落地）
  （NovaRange 双值约束 + NovaDate 三模式 mask 日历 + NovaTime 三面时钟 + NovaColorPicker
  SV 色域盘 + NovaOptionGroup 三型 + NovaForm 聚合校验 + NovaBtnToggle + NovaPopupEdit
  + 画廊第 17 页 + 测试 199 项；L2 16%→24%）
- 0.9.0：二期 Sprint A · 表单核心七件（统一契约 + 校验引擎；画廊 16 页；174 项测试）
- 0.8.0：Sprint 4 收口 · L0 设计语言 + L5 工具层一次交付（一期生态骨架完工）**
  （NovaIconSet 14 套图标集/100 语义键/provider 注册表/八通道解析 + NovaMotion 动效令牌 15 预设
  + NovaUtils colors 12·date 21·format 6·is 5·debounce/throttle/uid/extend + NovaText 排版 12 级
  + NovaTransition 过渡组件 + NovaTheme 排版/高程令牌 + NovaIcon 升级三通道 + 画廊 14/15 页
  + 测试 149 项；L0 60%→100%、L5 0%→95%；新增 Nova.Design 模块）
- 0.7.0：Sprint 3 收口 · L3 行为层九件一次交付（Intersection/ScrollObserver/ScrollFire/
  ClosePopup/TouchPan·Swipe·Hold·Repeat + NovaIntersectionPool 共享观察池 + NovaOverlayHost
  弹层栈 + 画廊第 13 页 + 114 项测试；L3 11% → 100%）
- 0.6.2：Sprint 2 收口 · 一次交付四件（NovaLoading 11 项对账 + 引用计数 / NovaStorage 真落盘 /
  NovaApp / NovaPlatform + NovaRuntime Python 后端 + 画廊第 12 页 + 91 项测试 + 交付节奏条款）
- 0.6.1：Sprint 2 第二件 NovaDialog（27 项对账 + 句柄三信号 + 画廊对话框页 + 71 项测试）
- 0.6.0：Sprint 2 首件 NovaNotify + NovaOverlayHost（29 项对账 + 63 项测试）
- **0.5.0：一期 Sprint 1 · L1 布局系统**（布局五件套 + 栅格三件套 + 画廊布局页 + 46 项测试）
- 0.4.2：**基线纠正 2.26.0 → 2.35.5** + 增量审计（AI-ready/MCP 入 L6、关闭原因上报/hover 契约/stagger/side 入 DoD）
- 0.4.1：**全生态开发总规划**（六期战略 + 全量对账表 + 冒烟测试七条纪律）
- 0.4.0：生态对标白皮书（七层模型 + 12 项 P0 空白 + 24 条封版验收）+ 宪法第 10 章 + M1 范围重排
- 0.3.4：PROMPT 单文件自包含（快照全文内联 + 内容指纹校验），告别"翻 4 个文件"
- 0.3.3：交付包完整性加固（ZIP 含 PROMPT + .git 历史 + BUILD_INFO + SHA256）
- 0.3.2：快照/提示词双模板 + gen_prompt.py 生成器

## 交付物通道

- 门禁：`check_a11y.py` → `check_api_freeze.py` → `check_qmllint.py`（local_deploy 第 0 步，红即拒包）
- **一键总验收 `scripts/check_all.py`**（库管员+验收员入口，分层，统一退出码 0 全绿/1 产品红或工具 ERROR/2 未执行门禁）：
  `--tier static`（默认，秒级三静态门禁）· `--tier dynamic`（perf/visual smoke/soak 冒烟/hidpi）·
  `--tier supply`（cve）· `--tier all`（全部 8 道；封版加 `--soak-24 --visual-full --cve-online`）；
  `--brief` 摘要、`--report PATH` 落 JSON。内置环境预检：无 PySide6 的解释器直接判 ERROR(码2)，
  不把"环境问题"误报成产品红。子门禁与总入口共用 `sys.executable`，必须用
  `miniconda3/envs/pyside6_nova/python.exe` 运行。
- 本地：`python scripts/local_deploy.py --zip --allinone` → release.zip + ALL-IN-ONE.zip
  （--allinone 必须在最终 git 提交之后运行，保证包内历史与 HEAD 一致——0.8.0 教训）
- PyPI：打 `v*` 标签 → GitHub Actions Trusted Publishing 自动发布
