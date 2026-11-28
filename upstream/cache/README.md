# 上游公开 API 元数据缓存（离线可复现）

> **关系口径恒为 Inspired by Quasar (MIT)**：参见 `docs/QUASAR_ACKNOWLEDGEMENT.md`。
> 本目录**只存 Quasar 随 npm 包发布的公开 API 描述元数据**（`dist/api/*.json`），
> **不含任何 Quasar 源码、实现、样式或构建产物**，不构成 fork / port / 移植。

| 项 | 值 |
|---|---|
| 来源 | 官方 npm registry `https://registry.npmjs.org/quasar/-/quasar-2.35.5.tgz` |
| 提取路径 | `package/dist/api/*.json`（tarball 内） |
| 版本 | `2.35.5` = `upstream/quasar-pin.json::pinned_version`（唯一事实源，CSA D4 未升 pin） |
| 文件数 | **156**（123 component / 20 plugin / 13 directive）—— 由 `scripts/gen_upstream_manifest.py` 脚本计数，**禁手写清单** |
| 校验 | 每个文件的 sha256 由 `gen_upstream_manifest.py` 计算并写入 `upstream/manifest-2.35.5.json` |
| 用途 | 离线跑 `gen_parity_matrix.py` / `check_parity.py` / `check_upstream_drift.py --offline`；P2 全生态广度台账的输入 |

**为什么可以入仓**：这些 JSON 是 Quasar 文档站用来生成 API 页的**公开接口描述**（属性名、类型、说明、示例），
不是源码；缓存它们是为了让对账在离线环境下可复现（对齐 `check_cve.py --offline` 缓存范式）。
按 MIT 许可保留原版权与致谢，沿用 `QUASAR_ACKNOWLEDGEMENT.md` 的禁用词表：
**只写 Inspired by，不写 fork / port / 移植 / 复刻**。

**纪律**：

- 升 pin 时必须换目录 `api-<newver>/` 并重新生成 manifest，**不得就地覆盖**（史料不圆场）。
- `upstream/manifest-*.json`、`parity/matrix.json`、`docs/PARITY_MATRIX.md` 均为**生成物，禁手改**。
- 本目录内容只读消费；任何「对齐/缺口」判定都在 `parity/matrix.json` 里，不回写缓存。
