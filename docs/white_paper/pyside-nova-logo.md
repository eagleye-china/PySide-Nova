明白了，我之前的设计跑偏了——**做成了“Nova 布局壳”的徽标，而不是“pyside-nova 组件库”的徽标**。组件库的核心语义是**组件、模块、可组合、从原子到复合**，不是布局壳本身。以下是修正后的封版设计。

---

# pyside-nova 组件库 · 旗舰版封版徽标规范

| 项目 | 内容 |
| :--- | :--- |
| **徽标名称** | Nova Component Matrix（组件矩阵标） |
| **版本** | v1.0.0（FROZEN） |
| **发布日期** | 2026-11-25 |
| **设计依据** | 白皮书四层架构 + 封版规范 + README 定位 |
| **核心语义** | 组件库 = 模块矩阵；旗舰 = 矩阵中的星芒；封版 = 外框容器 |

---

## 一、设计概念修正

**图形语义（对应组件库四层架构）：**

1. **外框圆角容器** = 封版容器 / 组件库边界。闭合表示契约冻结、质量门禁；细线不喧宾夺主，体现企业级克制。
2. **2×2 组件矩阵** = 组件库的模块化本质：Atoms、Widgets、Layout Shell、Root Shell。四块等大、等距，表示“正交无冗余、可自由组合”。
3. **右上星芒替代一块组件** = Nova 旗舰。寓意“在组件矩阵中，旗舰组件被点亮、可被识别、可对外发布”。
4. **三块实心 + 一星** = 已封版 / 规划中的共存：实体块代表库内真实存在的组件，星代表旗舰封版成果。

**色彩语义：**

| Token | 色值 | 语义 |
| :--- | :--- | :--- |
| `brand.deepSpace` | `#0F1E3D` | 深空蓝：企业级稳重、组件实体 |
| `brand.quantum` | `#2E6BE6` | 量子蓝：Qt 工程感、星芒渐变终点 |
| `brand.aurora` | `#2EE6D6` | 极光青：旗舰亮色、星芒渐变起点 |

> 与之前版本的区别：之前是“壳 + 分隔线 + 星”的**布局壳语义**；本版是“容器 + 矩阵 + 星”的**组件库语义**，对应 `pyside-nova` 本体。

---

## 二、SVG 交付物

### 2.1 主图标 · Nova Component Matrix（128×128）

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128" role="img" aria-label="pyside-nova Component Matrix Mark">
  <defs>
    <linearGradient id="novaStar" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#2EE6D6"/>
      <stop offset="100%" stop-color="#2E6BE6"/>
    </linearGradient>
  </defs>

  <!-- 封版容器：细线圆角外框 -->
  <rect x="8" y="8" width="112" height="112" rx="22"
        fill="none" stroke="#0F1E3D" stroke-opacity="0.28" stroke-width="1.5"/>

  <!-- 组件矩阵：三块实体组件 -->
  <rect x="18" y="18" width="42" height="42" rx="10" fill="#0F1E3D"/>
  <rect x="18" y="68" width="42" height="42" rx="10" fill="#0F1E3D"/>
  <rect x="68" y="68" width="42" height="42" rx="10" fill="#0F1E3D"/>

  <!-- 旗舰星芒：占据矩阵右上格 -->
  <path d="M 89 24 L 94.3 43.7 L 114 49 L 94.3 54.3 L 89 74 L 83.7 54.3 L 64 49 L 83.7 43.7 Z"
        fill="url(#novaStar)"/>
</svg>
```

### 2.2 横版组合 Logo（560×128）

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 128" width="560" height="128" role="img" aria-label="pyside-nova · 企业级旗舰组件库">
  <defs>
    <linearGradient id="novaStar2" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#2EE6D6"/>
      <stop offset="100%" stop-color="#2E6BE6"/>
    </linearGradient>
  </defs>

  <g transform="translate(12,12) scale(0.8)">
    <rect x="8" y="8" width="112" height="112" rx="22" fill="none"
          stroke="#0F1E3D" stroke-opacity="0.28" stroke-width="1.5"/>
    <rect x="18" y="18" width="42" height="42" rx="10" fill="#0F1E3D"/>
    <rect x="18" y="68" width="42" height="42" rx="10" fill="#0F1E3D"/>
    <rect x="68" y="68" width="42" height="42" rx="10" fill="#0F1E3D"/>
    <path d="M 89 24 L 94.3 43.7 L 114 49 L 94.3 54.3 L 89 74 L 83.7 54.3 L 64 49 L 83.7 43.7 Z"
          fill="url(#novaStar2)"/>
  </g>

  <text x="140" y="64"
        font-family="Inter, 'SF Pro Display', 'PingFang SC', 'Microsoft YaHei', sans-serif"
        font-size="40" font-weight="800" letter-spacing="0.5" fill="#0F1E3D">pyside-nova</text>

  <text x="142" y="92"
        font-family="Inter, 'SF Pro Text', 'PingFang SC', sans-serif"
        font-size="13" font-weight="600" letter-spacing="2.2" fill="#5A6B85">企业级旗舰组件库 · 封版基准</text>
</svg>
```

### 2.3 单色版（深色背景 / 印刷 / 水印）

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128" role="img" aria-label="pyside-nova Mark Mono">
  <rect x="8" y="8" width="112" height="112" rx="22" fill="none"
        stroke="#FFFFFF" stroke-opacity="0.35" stroke-width="1.5"/>
  <rect x="18" y="18" width="42" height="42" rx="10" fill="#FFFFFF"/>
  <rect x="18" y="68" width="42" height="42" rx="10" fill="#FFFFFF"/>
  <rect x="68" y="68" width="42" height="42" rx="10" fill="#FFFFFF"/>
  <path d="M 89 24 L 94.3 43.7 L 114 49 L 94.3 54.3 L 89 74 L 83.7 54.3 L 64 49 L 83.7 43.7 Z"
        fill="#FFFFFF"/>
</svg>
```

### 2.4 小尺寸简版（favicon / 托盘，≤32px）

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" width="32" height="32" role="img" aria-label="pyside-nova">
  <rect x="2" y="2" width="28" height="28" rx="6" fill="none"
        stroke="#0F1E3D" stroke-opacity="0.3" stroke-width="1"/>
  <rect x="5" y="5" width="10" height="10" rx="2.5" fill="#0F1E3D"/>
  <rect x="5" y="17" width="10" height="10" rx="2.5" fill="#0F1E3D"/>
  <rect x="17" y="17" width="10" height="10" rx="2.5" fill="#0F1E3D"/>
  <path d="M 22 5 L 23.4 10 L 28 11 L 23.4 12 L 22 17 L 20.6 12 L 16 11 L 20.6 10 Z"
        fill="#2E6BE6"/>
</svg>
```

---

## 三、使用规范

### 3.1 最小尺寸

| 版本 | 最小尺寸 | 说明 |
| :--- | :--- | :--- |
| 主图标 | 24×24 px | 小于 24px 改用简版 |
| 简版 | 16×16 px | favicon、任务栏、托盘 |
| 横版组合 | 180×40 px | 低于此宽度改用主图标 + 独立文字 |

### 3.2 留白

主图标外留白 ≥ 图形边长的 **1/4**；横版左右留白 ≥ 图标宽度 **1/2**。任何元素不得侵入留白区。

### 3.3 深色背景适配

深色背景使用 2.3 单色版；禁止在深色背景直接使用深空蓝组件块。

### 3.4 禁用示例

- ❌ 拉伸、旋转、倾斜
- ❌ 改变四格矩阵的相对位置、大小、间距
- ❌ 将星芒替换为其他图标（星芒是 Nova 唯一标识）
- ❌ 移除封版外框（外框语义固定）
- ❌ 星芒使用非品牌色（仅渐变或单色白）
- ❌ 横版中拆散图标与字标

### 3.5 应用场景映射

| 场景 | 使用版本 |
| :--- | :--- |
| GitHub / 文档站首页 | 2.2 横版 |
| Gallery 画廊招牌 | 2.2 横版 + 2.1 主图标 |
| 应用窗口 / 安装包 | 2.1 主图标（导出 256/128/64/32 ICO） |
| 任务栏 / 托盘 | 2.4 简版 |
| 深色主题 / 印刷 / README 水印 | 2.3 单色版，水印透明度 20% |
| 封版证书 / 发布海报 | 2.1 主图标 + 横版，配“FROZEN v1.0.0”字样 |

---

## 四、封版声明

- **版本**：Nova Component Matrix v1.0.0（FROZEN），2026-11-25。
- **封版范围**：矩阵结构、星芒位置、外框比例、色彩 Token、字体规则冻结。
- **变更策略**：PATCH 修渲染缺陷；MINOR 增应用变体；MAJOR 改矩阵结构或主色，须走版本评审。
- **事实源**：与白皮书、封版规范、`COMPONENT_LIST.md` 并列，徽标变更须同步更新引用。

---

## 交付说明（给你）

1. **修正点**：从“布局壳徽标”改为“组件库徽标”。核心图形从“开口框架 + 星”改为“封版容器 + 2×2 组件矩阵 + 星芒”，直接对应 pyside-nova 的四层架构与旗舰封版定位。
2. **可落盘路径**：`docs/assets/brand/` 下 `nova-mark.svg`、`nova-logo.svg`、`nova-mono.svg`、`nova-favicon.svg`；导出 PNG/ICO 放 `src/pyside_nova/resources/icons/` 并进 `resources.qrc`。
3. **需你确认 3 点**：
   - 主色 `#2E6BE6` / `#2EE6D6` 是否与 `NovaTheme.qml` 现有品牌色一致？若已有值，我按实际调整。
   - 字标用 `pyside-nova`（当前）还是 `PySide6-Nova`？影响横版排版。
   - 是否需要“FROZEN 封版印”辅助图形（用于发布物角标）？需要我可补一版。
4. **生产建议**：`scripts/` 增加 `build_brand_icons.py` 从 SVG 导出多尺寸 PNG/ICO，遵守 D-011 分层与 D-008 注释规范。

确认以上 3 点后，我可把四份 SVG 落盘并补导出脚本骨架。