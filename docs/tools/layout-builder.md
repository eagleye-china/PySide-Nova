# Layout Builder · 可视化布局生成

> 本页由 `scripts/gen_apidocs.py` 从冻结事实源自动生成，**禁止手工编辑**；重跑生成器即可同步。

选择 15 个组合根容器之一，勾选栏位开关与数值属性，左侧结构预览即时响应，右侧生成**可直接运行的 QML 骨架**并一键复制。内置 Desktop / Mobile / Chat 三个预设。

> ⚠️ **能力边界（如实标注）**：本 Builder 是**单根容器 + 槽位配置**的静态生成器，不提供任意拖拽嵌套与浏览器内 Qt 渲染；生成代码使用冻结面真实属性名，槽位注入遵循 CC-6（`anchors.fill: parent`）。

<div id="nova-layout-builder" class="nova-tool" data-nova-tool="layout-builder"></div>

## 相关

- [15 项组合根容器总览](../components/index.md)
- [在线可调参 Playground](playground.md)
- [在线示例浏览器](examples.md)
- [组合组件宪法](../COMPOSITION_CONSTITUTION.md)
