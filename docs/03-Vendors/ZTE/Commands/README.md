# Commands

本目录只放命令参考，不再混放“怎么操作”的指南。操作步骤请看 [Guides](../Guides/README.md)，未验证或争议较大的资料请看 [Research](../Research/README.md)。

## 命令条目

| 条目 | 主题 | Evidence | 说明 |
| --- | --- | --- | --- |
| [sendcmd](./sendcmd.md) | 数据库、调试、恢复相关入口 | B/C | 当前最重要的命令族入口 |
| [sidbg](./sidbg.md) | 调试 / 数据库访问 | C | 常与 `sendcmd` 对照出现 |
| [debug](./debug.md) | 调试命令集合 | D | 语法边界仍待整理 |
| [telnet](./telnet.md) | 维护登录入口 | B/C | 重点是入口与字段，而不是启用教程 |
| [ssh](./ssh.md) | 维护登录入口 | D | 缺少稳定公开证据 |
| [ftp](./ftp.md) | 文件传输 | D | 多为零散资料 |
| [tftp](./tftp.md) | 恢复 / 刷写辅助 | C | 常与串口或 Bootloader 联用 |
| [串口](./串口.md) | 低层维护入口 | B | 偏维护接口参考 |

## sendcmd 索引

`sendcmd` 不再只保留一篇概览，而是拆成三层：

- [Commands/sendcmd](./sendcmd.md)：命令参考总览
- [Database/配置表索引](../Database/配置表索引.md)：表、字段、文件名索引
- [Database/sendcmd-command-index.yaml](../Database/sendcmd-command-index.yaml)：结构化命令索引
- [Research/sendcmd社区命令收集](../Research/sendcmd社区命令收集.md)：尚未升级为正式参考的社区命令

## 升级原则

- 能稳定回答“命令是什么、怎么拼、风险多大”的内容进入 `Commands`
- 能稳定回答“怎么完成某个目标”的内容进入 `Guides`
- 仍然只是线索、争议、实验记录的内容保留在 `Research`
