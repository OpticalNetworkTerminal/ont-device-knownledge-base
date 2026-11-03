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

## 使用 zteOnu 工具开启

对于支持对应 factory mode 流程的机型，社区现在常直接使用 `zteOnu` 这类工具先打开工厂模式，再拿到临时 Telnet，最后固化为长期可用入口。

### 当前整理共识

- `Septrum101/zteOnu` 是公开可获取的中兴 ONT factory mode / Telnet 开启工具之一。
- 恩山 G1610 讨论中，有用户直接给出 `./zteOnu -i 光猫IP` 的使用方式。
- GitHub Releases 可确认该工具持续发布版本，且 `v0.0.3` 的发布说明中出现过 `Add -telnet param to permanent telnet`。
- 对 `zteOnu` 的分析文章认为其流程大致是：激活工厂接口、进入 factory mode、获取临时 Telnet、再用多条 `sendcmd` 写回 `TelnetCfg` 并重启固化。

### 常见用法

```sh
./zteOnu -i 192.168.1.1
```

部分资料还提到：

- 可先恢复出厂后再尝试
- 某些新版固件需要配合特定网卡 MAC 或新版固件模式
- 临时 Telnet 开启后，仍建议用 `sendcmd 1 DB save` 一类方式做持久化

### 风险与限制

- 工具是否适用，强依赖具体型号、固件代际和运营商定制
- 成功拿到临时 Telnet 不等于已经永久固化
- 切地区、恢复出厂或运营商下发配置后，Telnet 仍可能再次关闭

### 工具来源

- GitHub 仓库：<https://github.com/Septrum101/zteOnu>
- GitHub Releases：<https://github.com/Septrum101/zteOnu/releases>

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

- 命令参考见 [../Commands/sendcmd.md#telnet](../Commands/sendcmd.md#telnet)
- 地区码与 `upgradetest sdefconf` 见 [../Commands/sendcmd.md#地区码显示修改与恢复](../Commands/sendcmd.md#地区码显示修改与恢复)
- `sendcmd` 见 [../Commands/sendcmd.md](../Commands/sendcmd.md)
- 表索引见 [../Commands/sendcmd.md#db](../Commands/sendcmd.md#db)
- `zteOnu` 研究背景见 [../Research/Community/index.md](../Research/Community/index.md)

## 来源

- <https://github.com/Septrum101/zteOnu>
- <https://github.com/Septrum101/zteOnu/releases>
- <https://www.right.com.cn/forum/thread-8401446-1-1.html>
- <https://hackliu.com/?p=258>
- <https://blog.csdn.net/weixin_46337464/article/details/153938831>
