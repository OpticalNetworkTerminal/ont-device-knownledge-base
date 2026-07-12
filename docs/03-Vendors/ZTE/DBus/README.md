# DBus

本目录现在只用于整理 ZTE 设备里的 D-Bus / 私有 IPC / 对象模型相关结论，不再把“配置表索引”直接放在这里。

## 当前判断

- 公开社区资料大量出现 `sendcmd`、`sidbg`、配置表、XML 配置文件。
- 但“这些东西是否直接建立在标准 D-Bus 之上”这一点，目前没有足够证据统一下结论。
- 因此本目录只保留接口现状说明，把配置表与命令数据迁移到 [Database](../Database/README.md)。

## 当前条目

- [接口现状](./接口现状.md)

## 交叉引用

- 配置表索引见 [Database/配置表索引](../Database/配置表索引.md)
- 软件层背景见 [Platform/软件架构](../Platform/软件架构.md)
- 研究笔记见 [Research/sendcmd社区命令收集](../Research/sendcmd社区命令收集.md)
