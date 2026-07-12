# 开启Telnet

## 目标

启用设备的 LAN 侧 Telnet 维护入口，并在修改后验证是否能持久化。

## Evidence

C

说明：

- 本文主要依据你提供的昨天资料，并与仓库中已有社区来源交叉整理。
- 这里给的是“推荐操作框架”，不是所有机型通用的一键脚本。

## 前提

- 已取得可执行 `sendcmd` 或 `sidbg` 的入口
- 能先查询表结构再修改
- 明确只在本人设备或获授权维护场景使用

## 推荐步骤

1. 查询 `TelnetCfg` 与相关端口控制表。
2. 优先只开启 LAN，不开启 WAN。
3. 只修改实际存在的字段。
4. 保存后重启，再在插光前后分别验证。

## 常见命令

```sh
sendcmd 1 DB p TelnetCfg
sendcmd 1 DB p PortControl
sendcmd 1 DB set TelnetCfg 0 Wan_Enable 0
sendcmd 1 DB set TelnetCfg 0 Lan_Enable 1
sendcmd 1 DB save
```

部分样本还会出现：

```sh
sendcmd 1 DB set TelnetCfg 0 TS_Enable 1
sendcmd 1 DB set TelnetCfg 0 Lan_EnableAfterOlt 1
```

## 验证

```sh
sendcmd 1 DB p TelnetCfg
reboot
```

重启后应分别检查：

- 普通重启后是否仍可访问
- PON 注册完成后是否仍可访问
- 长时间运行后是否被运营商定制逻辑关闭

## 风险

- 不要默认开启 WAN 侧 Telnet
- 不要反复设置本机不存在的字段
- 不同设备可能通过 `TelnetCfg`、`TelnetUser`、`PortControl` 或网页工厂模式共同控制

## 交叉引用

- 命令参考见 [../Commands/telnet.md](../Commands/telnet.md)
- `sendcmd` 见 [../Commands/sendcmd.md](../Commands/sendcmd.md)
- 表索引见 [../Database/配置表索引.md](../Database/配置表索引.md)
