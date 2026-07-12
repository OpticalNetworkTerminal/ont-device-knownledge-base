# ZTE

本目录改为维护中兴 ONT / 家庭网关知识体系的长期 Reference，而不是继续堆积零散教程。组织目标参考 ArchWiki、OpenWrt Wiki、命令参考手册和长期研究笔记的组合形态。

## 设计原则

- `Platform`：放平台、产品线、软件架构、启动、升级、恢复、运营商定制等稳定背景知识。
- `Devices`：每个型号一个目录，记录型号边界、已知版本、适用命令、待验证点。
- `Guides`：解决“怎么做”，只收录已经具备可重复路径的操作主题。
- `Commands`：解决“这个命令是什么”，按功能、语法、风险、证据等级进行命令参考整理。
- `DBus`：只放 IPC / D-Bus / 私有总线相关结论，不再把配置表索引混放到这里。
- `Database`：放配置表索引、命令索引、型号清单等结构化资料。
- `Research`：放论坛资料、GPL 分析、实验记录、猜测、待验证内容，原则上不删除。
- `FAQ`：放常见问题与术语。

## Evidence Level

Evidence Level 用于保留信息，而不是在未实机验证时直接删除。

| 等级 | 含义 |
| --- | --- |
| A | 官方文档、官方源码、GPL 源码、实机验证 |
| B | GPL 分析、多来源一致、源码分析 |
| C | 恩山、ChinaDSL、52pojie、GitHub 讨论等多个社区来源一致 |
| D | 单一论坛、博客、经验贴、未交叉验证记录 |

详细说明见 [Research/README](./Research/README.md) 与 [Database/evidence-levels.yaml](./Database/evidence-levels.yaml)。

## 目录导航

- [Platform](./Platform/README.md)
- [Devices](./Devices/README.md)
- [Guides](./Guides/README.md)
- [Commands](./Commands/README.md)
- [DBus](./DBus/README.md)
- [Database](./Database/README.md)
- [Research](./Research/README.md)
- [FAQ](./FAQ/README.md)

## 当前重构重点

- 建立命令参考与操作指南的分层
- 建立 `Research -> Guides / Commands` 的升级路径
- 建立 `sendcmd` 的分域索引，而不是把所有资料压成一篇长文
- 为后续 `G7615`、`F7607`、`F7005` 等设备目录预留固定结构

## 当前已升级为 Reference 的主题

- [Platform/平台架构](./Platform/平台架构.md)
- [Platform/软件架构](./Platform/软件架构.md)
- [Commands/sendcmd](./Commands/sendcmd.md)
- [Commands/telnet](./Commands/telnet.md)
- [Database/配置表索引](./Database/配置表索引.md)

## 当前保留在 Research 的主题

- [高权限账户与工厂模式](./Research/高权限账户与工厂模式.md)
- [修改SN](./Research/修改SN.md)
- [修改MAC](./Research/修改MAC.md)
- [修改LOID](./Research/修改LOID.md)
- [桥接](./Research/桥接.md)
- [Mesh](./Research/Mesh.md)
- [LED控制](./Research/LED控制.md)
- [双模切换](./Research/双模切换.md)
- [sendcmd 社区命令收集](./Research/sendcmd社区命令收集.md)

## 来源策略

- 本轮优先使用你提供的昨天资料作为初始知识库。
- 对网络公开资料仅保留现有仓库已整理过的引用，不额外扩写新结论。
- 存在冲突时，保留多种观点并标注 Evidence，而不强行下统一结论。
