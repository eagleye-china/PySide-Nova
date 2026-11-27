# 在线可调参 Playground

> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；重跑生成器即可同步。

把 20 个组合根容器的**真实公共 Props** 做成可交互参数面板：选择容器、调整属性、切换浅色 / 深色 / 变体三态预览，右侧 QML 片段与属性表实时同步，一键复制即可粘进本地 Gallery 运行。

> ⚠️ **能力边界（如实标注）**：预览图是 `audit_showcase.py` 用真实 Qt Quick 引擎渲染的 60 张三态装配图；参数改动实时反映在 **QML 代码与属性表**，但浏览器内不重新渲染 Qt 场景（需本地 Gallery 或 Qt for WebAssembly，后者属 P2 边界遗留）。属性名 / 类型 / 默认值全部取自 `api/nova-api-1.7.0.json` 冻结面，无臆造 props。

<div id="nova-playground" class="nova-tool" data-nova-tool="playground"></div>

## 相关

- [20 项组合根容器总览](../components/index.md)
- [60 张三态装配图索引](../components/showcase.md)
- [Layout Builder](layout-builder.md)
- [在线示例浏览器](examples.md)
- [API 冻结清单](../API_FREEZE.md)
