# Commands

本手册按维护入口整理 ZTE 命令参考。


# Commands 总览

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


# sendcmd

# sendcmd

## 功能

`sendcmd` 是当前 ZTE ONT 资料里最核心的维护命令入口之一。公开资料显示，它常被用于：

- 查询配置数据库
- 修改配置数据库
- 保存配置
- 重启或恢复默认配置
- 查看调试信息
- 处理配置文件解密
- 配合 `TelnetCfg`、`DevAuthInfo`、`MgtServer`、`WANC`、`PortControl` 等表完成维护入口、远程管理、桥接与运营商定制相关修改

## Evidence

- `DB all / p / set / save`：B/C
- `DB reboot / DB rreset`：C
- `DB decry`：C
- `p all`、`-task`、`-socket`：D

## 常见适用范围

公开资料里，`sendcmd` 常见于以下型号或型号族：

- F460 / F660
- F7610M
- G7615 / F7607P 一类较新 ZXHN 机型
- 多个移动、电信、联通定制版本

这不等于所有 ZTE ONT 都开放 `sendcmd`，也不等于所有字段、行号和持久化行为完全一致。

## 语法

高频形式：

```sh
sendcmd 1 DB all
sendcmd 1 DB p <table>
sendcmd 1 DB set <table> <row> <field> <value>
sendcmd 1 DB delr <table> <row>
sendcmd 1 DB save
sendcmd 1 DB reboot
sendcmd 1 DB rreset
sendcmd 1 DB decry <path>
sendcmd 1 p all
```

## 参数

| 参数 | 说明 | Evidence |
| --- | --- | --- |
| `1` | 常见实例编号，准确语义未统一确认 | C |
| `DB` | 配置数据库操作域 | B/C |
| `all` | 列出数据库表或对象 | B/C |
| `p` | 打印指定表或对象 | B/C |
| `set` | 修改字段值 | B/C |
| `delr` | 删除指定行 | C |
| `save` | 保存当前改动 | B/C |
| `reboot` | 通过数据库命令触发重启 | C |
| `rreset` | 恢复默认配置相关动作 | C |
| `decry` | 设备侧解密配置文件 | C |

## 返回值

当前没有形成跨型号统一的返回值规范。实践上应优先读取本机输出，而不是假定固定格式。

## 分类索引

| 分类 | 典型命令 | 用途 | Evidence |
| --- | --- | --- | --- |
| DB 枚举 | `sendcmd 1 DB all` | 查看表或对象 | B/C |
| DB 查询 | `sendcmd 1 DB p TelnetCfg` | 查看记录与字段 | B/C |
| DB 修改 | `sendcmd 1 DB set DevAuthInfo 0 Pass xxx` | 修改字段 | B/C |
| DB 删除 | `sendcmd 1 DB delr <table> <row>` | 删除记录 | C |
| DB 保存 | `sendcmd 1 DB save` | 持久化改动 | B/C |
| DB 重启 | `sendcmd 1 DB reboot` | 重启设备 | C |
| DB 恢复 | `sendcmd 1 DB rreset` | 恢复默认配置 | C |
| DB 解密 | `sendcmd 1 DB decry /userconfig/cfg/db_user_cfg.xml` | 处理配置文件 | C |
| 调试输出 | `sendcmd 1 p all` | 观察调试信息 | D |

## DB

### 当前结论

公开资料稳定指向一种“表 + 行 + 字段”的配置数据库模型，但表结构、字段名、行号和持久化方式不保证跨型号一致。

### 高优先级表

| 表名 | 常见用途 | 示例 | Evidence |
| --- | --- | --- | --- |
| `TelnetCfg` | Telnet 开关、端口、账号、连接数 | `sendcmd 1 DB p TelnetCfg` | B/C |
| `DevAuthInfo` | Web 管理账户、密码、权限级别 | `sendcmd 1 DB set DevAuthInfo 0 Pass xxx` | B/C |
| `TelnetUser` | Telnet 用户名与密码 | `sidbg 1 DB set TelnetUser 0 Username root` | C |
| `MgtServer` | TR-069 / ACS 管理配置 | `sendcmd 1 DB p MgtServer` | C |
| `WANC` | WAN 连接与业务配置 | `sendcmd 1 DB p WANC` | C |
| `PortControl` | 端口或服务开放控制 | `sendcmd 1 DB p PortControl` | C |
| `DevInfo` | 设备基本信息 | `sendcmd 1 DB p DevInfo` | C |
| `CltLmt` | 用户数限制 | `sendcmd 1 DB p CltLmt` | C |
| `FWBase` | 连接数限制 | `sendcmd 1 DB p FWBase` | C |
| `PDTCTUSERINFO` | 注册状态、LOID 页面逻辑 | `sendcmd 1 DB p PDTCTUSERINFO` | C |
| `WLANCfg` | 无线配置 | `sendcmd 1 DB p WLANCfg` | C |
| `WLCInfo` | 无线控制状态 | `sendcmd 1 DB p WLCInfo` | C |
| `FTPUser` | FTP 用户或权限 | `sendcmd 1 DB p FTPUser` | D |
| `VoIPSIPLine` | 语音线索 | `sendcmd 1 DB p VoIPSIPLine all` | D |

### 配置文件线索

| 文件名 | 角色猜测 | Evidence |
| --- | --- | --- |
| `/userconfig/cfg/db_user_cfg.xml` | 用户配置 XML | B/C |
| `db_backup_cfg.xml` | 备份配置 | C |
| `db_default_cfg.xml` | 默认配置 | C |
| `db_default_auto_cfg.xml` | 默认自动配置 | B/C |
| `config.bin` | 导出/封装配置文件 | B/C |

## Telnet

Telnet 是 `sendcmd` 资料里最常见的维护入口主题之一。

### 常见字段

| 字段 | 常见含义 | Evidence |
| --- | --- | --- |
| `TS_Enable` | Telnet 总开关 | C |
| `Wan_Enable` | WAN 侧开关 | C |
| `Lan_Enable` | LAN 侧开关 | B/C |
| `TS_Port` | Telnet 端口 | C |
| `TSLan_Port` | LAN Telnet 端口 | C |
| `TS_UName` / `TS_UPwd` | 一组账号密码 | C |
| `TSLan_UName` / `TSLan_UPwd` | LAN 侧账号密码 | C |
| `Max_Con_Num` | 最大连接数 | C |
| `Lan_EnableAfterOlt` | 插光注册后是否保持 LAN Telnet | C |

### 常见命令样本

```sh
sendcmd 1 DB p TelnetCfg
sendcmd 1 DB set TelnetCfg 0 TS_Enable 1
sendcmd 1 DB set TelnetCfg 0 Wan_Enable 0
sendcmd 1 DB set TelnetCfg 0 Lan_Enable 1
sendcmd 1 DB set TelnetCfg 0 Lan_EnableAfterOlt 1
sendcmd 1 DB save
```

具体开启步骤见 [开启Telnet](../Guides/开启Telnet.md)。

## 高权限账户

### 高频表

- `DevAuthInfo`
- `TelnetCfg`
- `TelnetUser`

### 常见命令样本

```sh
sendcmd 1 DB p DevAuthInfo
sendcmd 1 DB set DevAuthInfo 0 User telecomadmin
sendcmd 1 DB set DevAuthInfo 0 Pass nE7jA%5m
sendcmd 1 DB set DevAuthInfo 1 Level 1
sendcmd 1 DB save
```

### 当前整理共识

- `DevAuthInfo` 常用于 Web 管理账号、密码和权限级别。
- 社区里反复出现 `telecomadmin`、`CMCCAdmin`、`CUAdmin` 一类运营商定制账号。
- `user` 提权到更高等级是常见玩法，但字段、行号和是否会被覆盖依型号不同。

## SSH

Evidence：D

目前没有足够稳定的公开资料表明 ZTE ONT 普遍默认开放 SSH，或存在统一的 SSH 开启命令集。

## FTP

Evidence：D

### 当前公开线索

- 有资料提到 `FTPUser`、`FTPServerCfg` 一类对象
- 有 GitHub 样本提到通过 `sendcmd 1 DB p FTPUser` 查看相关信息
- ChinaDSL 资料中也出现过通过修改 XML 方式开启 FTP 的讨论

### 待验证

- `sendcmd` 是否能直接启用 FTP
- FTP 在不同运营商版本中的默认状态
- FTP 与 TFTP / Telnet 的关系

## TFTP

Evidence：C

### 常见样本

```sh
tftp -p -l userconfig/cfg/db_user_cfg.xml -r db_user_cfg.xml 192.168.1.2
tftp -g -r db_user_cfg.xml 192.168.1.2
```

### 当前整理共识

- TFTP 在 ZTE 折腾场景中很常见
- 但其入口位于用户态、Telnet 环境还是 Bootloader，取决于具体型号

## TR-069 与运营商远程管理

### 高频表

- `MgtServer`
- `WANC`

### 常见命令样本

```sh
sendcmd 1 DB p MgtServer
sendcmd 1 DB set MgtServer 0 URL http://127.0.0.1
sendcmd 1 DB set MgtServer 0 Tr069Enable 0
sendcmd 1 DB set MgtServer 0 PeriodicInformEnable 0
sendcmd 1 DB save
```

```sh
sendcmd 1 DB p WANC
sendcmd 1 DB set WANC x ServList 8
sendcmd 1 DB set WANC x StrServList OTHER
```

### 当前整理共识

- `MgtServer` 多与 ACS / TR-069 地址和上报开关有关
- `WANC` 多与 WAN 业务类型、端口服务类型、桥接/路由业务状态有关
- 社区对“直接删除 TR-069”和“先改成 OTHER 再从页面删”两种做法都保留了样本

## 桥接

### 当前整理共识

- 桥接不只是“改一个开关”
- 常见入口是 `WANC`、服务类型、隐藏页面和高权限账户
- 电信、移动、联通定制版本差异明显

### 高频命令线索

```sh
sendcmd 1 DB p WANC
sendcmd 1 DB set WANC x ServList 8
sendcmd 1 DB set WANC x StrServList OTHER
```

## 配置文件与解密

### 常见命令样本

```sh
sendcmd 1 DB decry /userconfig/cfg/db_user_cfg.xml
```

### 当前整理共识

- `db_user_cfg.xml` 是最常见的用户配置文件线索
- `config.bin` 与 XML 之间存在导出/封装关系
- `sendcmd ... decry` 在 F680、F6600R 等讨论中反复出现，但不同机型结果并不一致

## 认证参数：SN / MAC / LOID

### 当前整理共识

- `SN`、`MAC`、`LOID` 修改都属于高风险主题
- 有的资料经由 `sendcmd`
- 有的资料经由 `setmac`
- 有的资料经由下载、解密、编辑、回传 `db_user_cfg.xml`

### 参考

- [修改SN](../Research/修改SN.md)
- [修改MAC](../Research/修改MAC.md)
- [修改LOID](../Research/修改LOID.md)
- [setmac-index](../Research/Commands/setmac-index.md)

## 无线、Mesh、LED、双模

### 当前已整理内容

- `WLANCfg` 常用于 SSID 前缀、无线名称一类字段
- `WLCInfo` 在部分 G7615 / F7607P 研究稿中出现

### 样本

```sh
sendcmd 1 DB p WLANCfg
sendcmd 1 DB set WLANCfg 0 ESSIDPrefix ""
sendcmd 1 DB set WLANCfg 4 ESSIDPrefix ""
sendcmd 1 DB p WLCInfo
sendcmd 1 DB set WLCInfo 0 WLCStatus 0
```

## 调试

### 当前已见命令

```sh
sendcmd 1 p all
sendcmd 1 -task
sendcmd 1 -socket
```

### 当前结论

- 这些命令在线索里确实存在
- 但公开资料对参数语义、输出格式和可用型号的说明很少

## 通用查看命令

虽然这些命令不都属于 `sendcmd` 本体，但它们经常和 `sendcmd` 一起使用。

```sh
upgradetest getver
cat /proc/capability/boardinfo
sendcmd 1 DB p DevInfo
setmac show2
date
cat /proc/cpuusage
cat /proc/tempsensor
```

### 当前整理共识

- `upgradetest getver` 常用于查看固件版本或主备版本线索
- `cat /proc/capability/boardinfo` 常用于查看硬件信息
- `sendcmd 1 DB p DevInfo` 常用于查看设备总览
- `setmac show2` 常用于查看 PONMAC、LOID、SN、MAC、SSID 等关键参数

## 地区码显示、修改与恢复

地区码切换在较新的社区资料里反复出现，常与 `G7615V2`、`F7610M`、联通/电信定制页面切换、Telnet 固化和管理员页面可见性相关。

### Evidence

C

### 常见命令

```sh
cat /etc/init.d/regioncode
cat /userconfig/flag_type
upgradetest sdefconf <地区号>
```

### 常见用途

| 动作 | 命令 | 说明 |
| --- | --- | --- |
| 显示可用地区号 | `cat /etc/init.d/regioncode` | 查看设备内置地区码表 |
| 显示当前地区 | `cat /userconfig/flag_type` | 查看当前地区标记 |
| 更新地区 | `upgradetest sdefconf <地区号>` | 将设备切到指定地区 |
| 重置回原地区 | `upgradetest sdefconf <原地区号>` | 重新切回原来的地区代码 |

### 当前整理共识

- `upgradetest sdefconf <地区号>` 是目前公开资料里最常见的地区切换命令
- 执行后设备通常会重启，Telnet 入口可能需要重新开启或重新固化
- 某些地区切换后，隐藏管理页、默认管理账户或运营商定制页面会发生变化
- “重置地区”目前没有看到独立于 `sdefconf` 的统一命令，社区通常就是重新写回原地区号

## 风险等级

总体风险等级：高

说明：

- `sendcmd` 同时覆盖只读查询、中风险修改和高风险恢复/认证操作
- `delr`、`rreset`、认证参数修改、TR-069/WAN 删除、地区切换都应按高风险看待

## 待验证

- 是否存在统一的 `SSH` 开关命令集
- `FTPUser` / `FTPServerCfg` 的具体行为
- `sendcmd` 与 `sidbg` 在不同平台中的对应关系
- `save`、`saveasy`、配置回写和重启之间的准确持久化逻辑
- `decry` 的输出路径、权限要求和机型差异
- `Mesh`、`LED`、`双模切换` 是否存在可稳定归类到 `sendcmd` 的命令族

## 交叉引用

- [sidbg](./sidbg.md)
- [开启Telnet](../Guides/开启Telnet.md)
- [sendcmd-command-index.yaml](../Database/sendcmd-command-index.yaml)
- [sendcmd-index](../Research/Commands/sendcmd-index.md)
- [setmac-index](../Research/Commands/setmac-index.md)
- [upgradetest-index](../Research/Commands/upgradetest-index.md)

## 来源

- 中兴官方文档地图
- GitHub `mkst/zte-config-utility`
- GitHub `douniwan5788/zte_modem_tools`
- GitHub `Septrum101/zteOnu`
- 恩山论坛
- ChinaDSL
- OpenWrt Forum
- OpenWrt Wiki
- <https://hackliu.com/?p=258>
- <https://dmm.ink/2024/06/01/snmac2/>
- <https://www.right.com.cn/forum/thread-8404346-1-1.html>
- <https://www.right.com.cn/forum/thread-8379699-1-1.html>
- <https://blog.csdn.net/weixin_46337464/article/details/153938831>


# sidbg

# sidbg

## Evidence

C

## 功能

`sidbg` 是社区资料中常见的另一类 ZTE 调试/数据库访问入口，很多用法与 `sendcmd` 相近。

## 当前定位

- 作为 `sendcmd` 的并列入口保留
- 重点记录它“在哪里出现、典型语法是什么、和 `sendcmd` 有什么关系”
- 不再把 `sidbg` 单独扩写成一整套重复的 Telnet / TR-069 / 桥接指南

## 语法

```sh
sidbg 1 DB p all
sidbg 1 DB p TelnetCfg
sidbg 1 DB set DevAuthInfo 0 User CMCCAdmin
sidbg 1 DB set TelnetCfg 0 TS_Enable 1
sidbg 1 DB save
```

## 参数

- `1`：社区样本中的实例编号，准确语义待验证
- `DB`：数据库操作域
- `p`：打印
- `set`：修改
- `save`：保存

## 返回值

- 待验证

## 示例

```sh
sidbg 1 DB p TelnetCfg
sidbg 1 DB set TelnetUser 0 Username root
sidbg 1 DB set TelnetUser 0 Password admin
sidbg 1 DB save
```

## 适用型号

- 社区资料显示见于部分中兴 ONT
- 与 `sendcmd` 的覆盖面是否完全一致，待验证
- 社区中存在“`sendcmd not found`，但 `sidbg` 可用”的说法

## 与 sendcmd 的关系

- 两者都常用于访问“表 + 行 + 字段”的配置数据库模型
- `TelnetCfg`、`DevAuthInfo`、`TelnetUser` 等对象在两套命令样本中都出现过
- 若要看更完整的主题整理，优先参考 [sendcmd](./sendcmd.md)

## 风险等级

高

## 验证状态

社区资料

说明：

- 目前主要依据论坛样本
- 尚未看到足够官方资料说明 `sidbg` 的正式定位

## 来源

- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.right.com.cn/forum/thread-8237756-1-1.html>


# 串口

# 串口

## Evidence

B

## 功能

串口用于观察启动日志、进入低层维护环境和执行恢复操作。

## 已验证内容

- FCC 对多款 ZTE ONT 公开了内部照片，这为定位 UART 焊点提供了一手材料基础。
- `zte_modem_tools` 公开实现了 `serial` 开关相关逻辑，说明部分社区研究对象存在与串口有关的网页/工厂模式控制路径。

## 风险等级

高

## 验证状态

- 串口作为低层维护方向存在：已验证
- 具体焊点、电平和波特率：待验证

## 来源

- <https://github.com/douniwan5788/zte_modem_tools/blob/main/zte_factroymode.py>
- <https://fccid.io/Q78-ZXHNF660>
- <https://fccid.io/Q78-ZXHNF670E>
- <https://fccid.io/Q78-ZXHNF680V9>
