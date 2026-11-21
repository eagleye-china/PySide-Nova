# Security Policy — pyside-nova 安全策略

## 支持版本

| 版本 | 状态 | LTS |
|---|---|---|
| `0.2.x` | ✅ 支持（M0/M1 演进期） | — |
| `1.0.0-flagship`（规划） | ✅ 支持 | 24 个月 LTS，API 冻结 |
| `< 1.0` 旧版本 | ❌ 仅最新 0.x 分支接收修复 | — |

## 报告漏洞

**请不要在公开 Issue 中披露安全漏洞。**

1. 使用 GitHub Security Advisories（仓库 → Security → Report a vulnerability）
   私密报告；或邮件联系维护者（见仓库 Profile）
2. 请包含：影响的组件、复现步骤/最小示例、影响评估、建议修复方向
3. 响应目标：**72 小时内**确认，7 天内给出评估结论
4. 修复后：发布补丁版本 + 公开 Advisory 致谢（除非你要求匿名）

旗舰版封版后启用 **72 小时安全热修通道**：针对高危（CVSS ≥ 9）漏洞，
绕过常规发布节奏，24h 内出补丁、72h 内完成全渠道发布。

## 安全设计基线

- 纯 QML + Python，无网络权限请求；`NovaIcon` 云端通道仅访问固定 jsDelivr CDN 域名
- 本地图标通道读取 `NovaTheme.iconLocalRoot` 指定目录，不执行任何动态代码加载
- CI 依赖安装均来自官方 PyPI；发布走 PyPI Trusted Publishing，无长期 token
