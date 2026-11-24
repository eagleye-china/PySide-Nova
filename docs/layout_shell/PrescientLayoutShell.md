# pyside-nova Prescient Layout Shell｜旗舰布局壳组件清单（整合完整版）
> 封版规范：Prescient Layout Shell v1.0.0
> 定位：主打工业桌面工具、HMI、IDE类、配置管理、AI助手、文档工作台；精而不繁、正交无冗余，一个业务场景优先匹配一个Shell，不重复造同结构骨架
> 新增：**NovaDesktop、NovaMobile、NovaFlexLayout** 三端专属根壳，补齐桌面/移动端/企业大屏场景，和工作台布局壳体系融合

## 总览分类
主导航布局壳（业务工作台主力，引流核心）
内容排版/多栏工作台壳（文档、预览、对比、配置）
弹窗 & 浮层容器壳（模态、非模态、提示面板）
极简独立页壳（小工具、单页卡片、向导页）
多端专属根壳（桌面、移动端、企业大屏）

## 一、主导航布局壳（4个，最核心）
1. **NovaSidebarShell**（✅ 已封版，首个主推引流款）
    > 结构：侧边栏 + Header + Content + Footer + Overlay
    > 适用：绝大多数工具、管理后台、dev_toolbox_pro、NovaChat、图标画廊、剪贴板保存工具
    > 特点：侧边可折叠，自带导航骨架，是用户上手第一个Shell
2. **NovaTopNavShell**
    > 结构：顶部一级导航栏 + 子菜单下拉区 + 主内容区 + 底部状态栏
    > 适用：软件配置工具、简单企业后台、面向新手的轻量化工具、不想占左侧空间的场景
    > 差异：无常驻侧边栏，适合窗口宽度不大、功能模块不多的应用
3. **NovaDualSideShell**（双侧边）
    > 结构：左侧导航目录 + 右侧属性面板 + 中间主内容 + Header + Footer
    > 适用：编辑器、配置器、节点工具、QML预览工作台、资源管理器（类似Qt Designer、VSCode基础布局）
    > 特点：左右侧栏均可独立折叠，三栏骨架，工业配置软件高频
4. **NovaTabShell**（标签页工作台壳）
    > 结构：顶部Tab标签栏 + 标签内容容器 + 底部状态栏 + 全局浮层
    > 适用：多文档打开、多任务并行工具（同时打开多个qml、多个配置文件）
    > 特点：内置Tab激活、关闭、新增信号；每个Tab内部可嵌入任意Shell/页面

## 二、多栏内容工作台壳（3个，专业向，吸引进阶开发者）
5. **NovaThreeColumnShell**（三栏固定工作台）
    > 结构：左目录树｜中列表｜右详情预览
    > 适用：文档阅读器、资源库、图标库画廊、日志查看器、API文档工作台
    > 特点：三栏宽度均可拖拽分割，内置分割条，适配Material Symbols图标画廊场景
6. **NovaCompareShell**（双栏对比壳）
    > 结构：左右对等双内容面板 + 顶部统一控制栏 + 底部状态栏
    > 适用：代码对比、SVG图标对比、配置对比、新旧版本diff查看器
    > 特点：等宽布局，同步滚动可选属性，专门面向开发工具场景
7. **NovaCardGridShell**（卡片工作台壳）
    > 结构：顶部筛选/搜索栏 + 自适应卡片网格容器 + 底部分页状态栏
    > 适用：组件画廊总览、模板市场、素材库、模板选择器
    > 特点：自适应行列，适合展示大量预览卡片，Gallery首页非常合适

## 三、弹窗 & 浮层容器壳（2个，基础配套，所有Shell共用）
8. **NovaModalShell**（模态弹窗壳）
    > 结构：遮罩层 + 弹窗容器（标题栏 + 内容槽 + 按钮栏）
    > 适用：配置弹窗、确认框、表单弹窗、导出弹窗
    > 特点：自带键盘ESC关闭、点击遮罩关闭、圆角阴影，主题Token驱动
9. **NovaDrawerPanelShell**（侧边滑出面板壳）
    > 结构：从右侧/左侧滑出的面板容器
    > 适用：属性面板、详情面板、临时表单，非模态，不阻塞主界面
    > 区别于主Sidebar：它是临时唤起面板，不是常驻导航

## 四、极简独立页壳（2个，轻量化小工具）
10. **NovaWizardShell**（分步向导壳）
    > 结构：顶部步骤指示器 + 当前步骤内容槽 + 底部上一步/下一步按钮区
    > 适用：新建工程向导、打包向导、初始化配置向导（WSL安卓打包向导、项目初始化）
    > 特点：内置步骤状态管理、进度展示，只做向导骨架，业务表单放contentSlot
11. **NovaBlankPageShell**（纯净单页壳）
    > 结构：Header + Content + Footer，无任何侧边/标签导航
    > 适用：独立小工具、简单单页页面、嵌入到其他Shell内部的子页面
    > 特点：最小化骨架，给需要完全自定义布局的高级用户

## 五、多端专属根壳（3个，补齐桌面/移动/大屏）
12. **NovaDesktop**｜桌面应用容器组件
    > 桌面端根壳，内置菜单栏、状态栏、多页面管理，作为PC桌面应用顶层根容器
13. **NovaMobile**｜移动应用容器组件
    > 适配安卓触摸交互、系统安全区、移动端导航，专门用于PySide6移动端打包顶层壳
14. **NovaFlexLayout**｜企业大屏弹性布局组件
    > 自适应大屏、分栏、网格、动态缩放，面向HMI、工控超大分辨率大屏场景

---
## ✅ 清单汇总（精简索引版，直接放进LayoutShell总README）
1. NovaSidebarShell        侧边导航工作台（主推、已封版）
2. NovaTopNavShell         顶部导航轻量化工作台
3. NovaDualSideShell       左右双侧边三栏工作台
4. NovaTabShell            多标签页工作台
5. NovaThreeColumnShell    目录-列表-详情三栏工作台
6. NovaCompareShell        双栏对比工作台
7. NovaCardGridShell       卡片网格素材画廊
8. NovaModalShell          模态弹窗壳
9. NovaDrawerPanelShell    侧边临时滑出面板
10. NovaWizardShell        分步向导壳
11. NovaBlankPageShell     纯净无导航单页壳
12. NovaDesktop            桌面端顶层应用根壳
13. NovaMobile             移动端顶层应用根壳
14. NovaFlexLayout         企业大屏弹性布局壳

## 📄 仓库简介（README 可用）
pyside-nova Prescient Layout Shell 是一套对标 Quasar、面向 PySide6 QML 的旗舰布局壳体系，包含14个正交无冗余的布局容器组件。覆盖工作台导航、多栏预览对比、弹窗浮层、向导、独立单页，同时配套 **NovaDesktop 桌面根壳、NovaMobile 移动端根壳、NovaFlexLayout 企业大屏布局**，一套布局体系同时适配PC桌面软件、安卓移动端、工业HMI大屏场景。所有Shell遵循统一Prescient Layout Shell封版规范、统一槽位命名、统一Theme Token体系，独立Gallery Demo，适合企业级工具、IDE、配置平台、AI工作台快速落地。

## 📌 落地顺序建议（按引流优先级）
✅ NovaSidebarShell（已完成）
NovaThreeColumnShell（给图标画廊，马上就能用）
NovaModalShell（全库通用弹窗）
NovaTabShell（多文件编辑）
NovaWizardShell（打包向导）
NovaDesktop / NovaMobile / NovaFlexLayout（多端顶层壳）
其余按需迭代

> 每一个都严格遵守同一套Prescient Layout Shell封版规范、统一槽位命名、统一Theme Token体系、独立Gallery Demo、独立README。

直接复制保存为 `layout-shell.md` 即可。
接下来要不要直接开工写 **NovaThreeColumnShell** 的全套交付物（qml + qmldir + README + Gallery Demo）？