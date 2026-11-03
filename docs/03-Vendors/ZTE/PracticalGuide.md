# PracticalGuide

本手册汇总 ZTE 的实际维护主题。


# Guides 总览

# Guides

本目录只收录“怎么做”的主题，并且应尽量具备可重复路径。证据不足、运营商差异过大或仍存在明显冲突的内容，先留在 `Research`。

## 当前条目

- [开启Telnet](./开启Telnet.md)
- [修改管理密码](./修改管理密码.md)
- [恢复出厂](./恢复出厂.md)

## 进入 Guides 的标准

- 至少能描述前提条件、步骤、验证方法和风险
- 至少具备 C 级以上 Evidence
- 不把单一论坛经验直接写成所有设备通用步骤


# 开启Telnet

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


# 修改管理密码

# 修改管理密码

## 目标

修改 Web 管理或 Telnet 登录密码。

## Evidence

C

## 适用范围

- `DevAuthInfo` 常见于 Web 管理账户
- `TelnetUser` / `TelnetCfg` 常见于 Telnet 账户
- 表结构必须以本机查询结果为准

## 推荐步骤

1. 先查询相关表。
2. 只修改确认存在的字段。
3. 修改后再次查询确认结构未异常。
4. 最后执行保存。

## 常见命令

```sh
sendcmd 1 DB p DevAuthInfo
sendcmd 1 DB set DevAuthInfo 0 Pass 'new-password'
sendcmd 1 DB save
```

```sh
sidbg 1 DB p TelnetUser
sidbg 1 DB set TelnetUser 0 Password 'new-password'
sidbg 1 DB save
```

## 风险

- 改错字段或行号可能导致无法登录
- 不同运营商版本可能存在额外账号或隐藏恢复逻辑

## 交叉引用

- 命令参考见 [../Commands/sendcmd.md](../Commands/sendcmd.md)
- 配置表索引见 [../Commands/sendcmd.md#db](../Commands/sendcmd.md#db)
- 高权限账户差异见 [../Research/高权限账户与工厂模式.md](../Research/高权限账户与工厂模式.md)


# 恢复出厂

# 恢复出厂

## 目标

把设备恢复到默认配置状态。

## Evidence

C

## 已知路径

- Web 管理界面恢复
- 配置数据库恢复相关命令
- 按键 / 串口 / 低层恢复

## 当前共识

- “恢复出厂”是稳定存在的维护目标
- 但“恢复出厂”不等于“重新刷完整固件”
- 是否保留 SN / MAC / LOID / 运营商参数，必须按设备记录

## 常见命令线索

```sh
sendcmd 1 DB rreset
sendcmd 1 DB reboot
```

## 风险

- 可能清空可写配置
- 可能导致认证参数丢失
- 某些版本恢复后会重新被运营商侧下发覆盖

## 交叉引用

- 背景见 [../Platform/恢复机制.md](../Platform/恢复机制.md)
- 研究主题见 [../Research/修改LOID.md](../Research/修改LOID.md)
- 设备差异后续放入 `Devices/<model>/`


# 高权限账户与工厂模式

# 高权限账户与工厂模式

## Evidence

C

## 当前结论

- 高权限账户、工厂账号、隐藏入口明显受运营商定制影响
- 当前更适合作为研究主题保存，不适合直接上升为统一操作指南

## 当前线索

- `telecomadmin`
- `CMCCAdmin`
- `CUAdmin`
- `cqadmin`
- 通过 `DevAuthInfo`、`TelnetCfg` 或网页工厂模式相关逻辑进入高权限状态

## 交叉引用

- [../Platform/运营商定制.md](../Platform/运营商定制.md)
- [../Guides/修改管理密码.md](../Guides/修改管理密码.md)


# 修改SN

# 修改SN

## Evidence

C

## 功能

修改设备序列号。

## 当前状态

社区资料

## 风险等级

极高

## 说明

- 序列号可能参与运营商资产管理、PON 认证或密钥计算
- 当前只保留主题，不给出未经验证的通用步骤

## 来源

- <https://www.chinadsl.net/thread-179762-1-1.html>
- <https://www.right.com.cn/forum/thread-8406849-1-1.html>


# 修改MAC

# 修改MAC

## Evidence

C

## 功能

修改设备 MAC 地址。

## 当前状态

社区资料

## 风险等级

极高

## 说明

- 可能影响 Web 登录、配置加密、PON 注册、运营商识别
- 当前阶段只保留索引，不输出通用命令结论

## 来源

- <https://www.right.com.cn/forum/thread-8406849-1-1.html>
- <https://github.com/mkst/zte-config-utility/blob/master/SUPPORT.md>


# 修改LOID

# 修改LOID

## Evidence

C

## 功能

修改 LOID 或相关 PON 认证参数。

## 当前状态

社区资料

## 风险等级

极高

## 说明

- LOID 强依赖运营商认证策略
- 不同设备可能将其分散存储在不同表或页面

## 来源

- <https://www.chinadsl.net/thread-151687-1-1.html>
- <https://www.right.com.cn/forum/thread-8406849-1-1.html>


# 桥接

# 桥接

## Evidence

C

## 功能

整理 ZTE ONT 桥接配置、运营商限制和常见改法。

## 当前状态

社区资料

## 说明

- 桥接通常与 `WANC`、VLAN、地区码、运营商隐藏页面等主题交叉出现
- 当前阶段不输出统一命令结论

## 来源

- <https://www.right.com.cn/forum/thread-8237756-1-1.html>
- <https://www.chinadsl.net/thread-151687-1-1.html>


# Mesh

# Mesh

## Evidence

D

## 功能

整理 ZTE ONT/家庭网关 Mesh、FTTR、主从节点联动等主题。

## 当前状态

待验证

## 说明

- 官方产品线中既有传统 ONT，也有偏家庭网关/FTTR 的设备
- 不能把单一机型的 Mesh 行为扩展到整个中兴 ONT 产品线


# LED控制

# LED控制

## Evidence

D

## 功能

整理设备 LED 灯控相关命令或配置项。

## 当前状态

待验证

## 说明

- 目前没有足够稳定的公开命令样本
- 后续可从配置表、GPIO、Web UI 和工厂模式继续跟踪


# 双模切换

# 双模切换

## Evidence

D

## 功能

整理 GPON/EPON 等模式切换相关主题。

## 当前状态

待验证

## 说明

- 该主题与具体硬件平台强相关
- 目前缺少足够稳定的一手资料，不宜给出统一步骤
