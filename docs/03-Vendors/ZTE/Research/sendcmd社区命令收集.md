# sendcmd 社区命令收集

本页用于保留尚未升级成正式命令参考的 `sendcmd` 社区样本，避免资料散失。

## Evidence

C/D

## 当前收集分类

### DB 管理

- `sendcmd 1 DB all`
- `sendcmd 1 DB p <table>`
- `sendcmd 1 DB set <table> <row> <field> <value>`
- `sendcmd 1 DB delr <table> <row>`
- `sendcmd 1 DB save`
- `sendcmd 1 DB reboot`
- `sendcmd 1 DB rreset`

### 配置文件处理

- `sendcmd 1 DB decry /userconfig/cfg/db_user_cfg.xml`
- `sendcmd 1 DB saveasy`

### 调试类

- `sendcmd 1 p all`
- `sendcmd 1 -task`
- `sendcmd 1 -socket`

## 备注

- `saveasy` 在较老资料中出现，但语义并未统一确认
- `-task`、`-socket` 目前只看到零散样本，先保留为研究线索
- 后续如果能明确子命令语法和输出，再升级到 `Commands/debug.md`

## 来源

- 用户提供资料：`/Users/jonhy/Downloads/zte-ont-telnet-sendcmd-command-reference-v2.md`
- 现有仓库中的论坛/GitHub 引用
