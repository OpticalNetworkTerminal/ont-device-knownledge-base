# Commands

本目录只放命令参考，不再混放“怎么操作”的指南。操作步骤请看 [Guides](../Guides/README.md)，未验证或争议较大的资料请看 [Research](../Research/README.md)。

## 命令条目

| 条目 | 主题 | Evidence | 说明 |
| --- | --- | --- | --- |
| [sendcmd](./sendcmd.md) | 数据库、Telnet、SSH、FTP、TFTP、调试、恢复相关入口 | B/C | 当前最重要的命令族入口 |
| [sidbg](./sidbg.md) | 调试 / 数据库访问 | C | 常与 `sendcmd` 对照出现 |
| [串口](./串口.md) | 低层维护入口 | B | 偏维护接口参考 |

## sendcmd 索引

`sendcmd` 现在作为统一入口页，直接收纳：

- `DB`
- `Telnet`
- `SSH`
- `FTP`
- `TFTP`
- `Debug`
- `TR-069`
- `桥接`
- `高权限账户`
- `配置文件与解密`
- `SN / MAC / LOID`
- `无线 / Mesh / LED / 双模`

相关索引保留为两层：

- [Commands/sendcmd](./sendcmd.md)：命令参考总览
- [Database/sendcmd-command-index.yaml](../Database/sendcmd-command-index.yaml)：结构化命令索引
- [Research/Commands/sendcmd-index](../Research/Commands/sendcmd-index.md)：公开出现样本总索引
- [Research/sendcmd社区命令收集](../Research/sendcmd社区命令收集.md)：尚未完全升级的社区命令收集页

## 升级原则

- 能稳定回答“命令是什么、怎么拼、风险多大”的内容进入 `Commands`
- 能稳定回答“怎么完成某个目标”的内容进入 `Guides`
- 仍然只是线索、争议、实验记录的内容保留在 `Research`
