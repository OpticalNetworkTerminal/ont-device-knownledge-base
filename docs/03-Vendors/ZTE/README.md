# ZTE

本目录现在按“维护手册”组织，中兴 ONT 的正式入口统一收敛到几本手册里；`Devices/`、`Research/`、`Database/` 继续分别承担型号差异、资料仓库和结构化数据的职责。

## 手册入口

- [Architecture](./Architecture.md)
- [Filesystem](./Filesystem.md)
- [Configuration](./Configuration.md)
- [Commands](./Commands.md)
- [PracticalGuide](./PracticalGuide.md)
- [ReverseEngineering](./ReverseEngineering.md)
- [Devices](./Devices/README.md)
- [Research](./Research/README.md)
- [Database](./Database/README.md)

## 设计目标

- 用 `Architecture` 统一承接平台、软件架构、启动恢复、运营商定制和 IPC 背景。
- 用 `Configuration` 统一承接配置数据库、配置文件和持久化线索。
- 用 `Commands` 统一承接 `sendcmd`、`sidbg`、串口等入口，而不是再把 Telnet/FTP/TFTP 拆成独立页。
- 用 `PracticalGuide` 统一承接 Telnet、改密、恢复出厂、SN/MAC/LOID、桥接、Mesh 等实际操作主题。
- 用 `ReverseEngineering` 承接研究入口和逆向资料导航。

## Evidence Level

| 等级 | 含义 |
| --- | --- |
| A | 官方文档、官方源码、GPL 源码、实机验证 |
| B | GPL 分析、多来源一致、源码分析 |
| C | 恩山、ChinaDSL、52pojie、GitHub 讨论等多个社区来源一致 |
| D | 单一论坛、博客、经验贴、未交叉验证记录 |

详细说明见 [Research/README](./Research/README.md) 与 [Database/evidence-levels.yaml](./Database/evidence-levels.yaml)。
