# Commands

本页整理天邑设备的命令、隐藏 CGI、对象接口与高频维护入口。目标是形成可维护的索引，而不是只保留碎片化帖子。

## 入口索引

| 类别 | 入口/命令 | 常见用途 | 适用型号 | 状态 |
| --- | --- | --- | --- | --- |
| Web 隐藏页 | `/usbbackup.cmd?action=backupeble&sessionKey=...` | 导出配置 | `TEWA-708E`，相近型号待扩展 | 已整理 |
| Web 隐藏页 | `/enableTelnet.html` | 开启 Telnet | `TEWA-708E` | 已整理 |
| Web CGI | `telandftpcfg.cmd?action=add...` | 开启 Telnet/FTP | `TEWA-707G`、`766G`、`750/708/768/800/1000` 一类社区样本 | 社区资料 |
| Web 对象接口 | `POST /setObjs` | 写对象开 Telnet | `TEWA-872G` | 已整理 |
| 设备命令 | `telecomadmin get` | 提取超管 | `TEWA-1006G`，其它型号待验证 | 社区资料 |
| 设备命令 | `CUAdmin get` | 提取超管 | 早期型号 | 社区资料 |
| 设备命令 | `sendcmd 1 DB save` | 保存数据库 | 未明确 | 社区资料 |
| 设备命令 | `sendcmd 1 DB saveasy` | 异步保存数据库 | 未明确 | 社区资料 |
| shell | `su` | 进入更高权限环境 | `TEWA-1000E`、`1006G` 等 | 社区资料 |
| shell | `echo $USER` | 判断当前用户 | `TEWA-1000E` | 已整理 |
| shell | `/opt/upt/apps/ssh/start_ssh.sh` | 启动 SSH | `TEWA-1000E` | 已整理 |
| shell | `ip6tables -I INPUT ... --dport 22 -j ACCEPT` | 放行 IPv6 SSH | `TEWA-1000E` | 已整理 |

## Web 入口

### `usbbackup.cmd`

这是目前最有代表性的天邑隐藏页之一，常用于导出 CFG 配置。

- 常见形态:
  - `usbbackup.cmd?action=backupeble&sessionKey=...`
- 关联线索:
  - `sessionKey`
  - U 盘挂载点
  - 导出的 `ctce8_*.cfg`
- 已知用途:
  - 导出配置
  - 后续搜索 `TeleComAccount`、宽带账号、电话参数等
- 常见适用机型:
  - `TEWA-708E`
  - `TEWA-768G`
  - 社区还常提到 `TEWA-1000E`、`TEWA-800E`

#### 来源

- GitHub: `jonirrings/xor`
- 恩山
- ChinaDSL

### `/enableTelnet.html`

这是最常被提及的天邑 Web 隐藏页之一。

- 常见用途:
  - 在已获得高权限 Web 会话后启用 Telnet
- 已知机型:
  - `TEWA-708E`
- 备注:
  - 其它型号是否保留相同路径，当前没有统一结论。

#### 来源

- GitHub: `jonirrings/xor`

### `telandftpcfg.cmd`

这是社区资料中频率很高的一个入口，通常和 `set3_sessionKey` 一起出现。

- 常见用途:
  - 同时打开 Telnet 与 FTP
- 常见参数:
  - `telusername`
  - `telpwd`
  - `telport`
  - `telenable`
  - `ftpusername`
  - `ftppwd`
  - `ftpport`
  - `ftpenable`
  - `set3_sessionKey`
- 常见适用范围:
  - `TEWA-707G`
  - `TEWA-766G`
  - 社区常泛化到 `750/708/768/800/1000` 一组

#### 待验证

- 是否所有天邑新固件都保留该 CGI。
- `set2_sessionKey` 与 `set3_sessionKey` 的差异。
- CGI 是否只是前端入口，背后仍走同一对象树。

#### 来源

- ChinaDSL
- 恩山

### `POST /setObjs`

这是当前天邑资料里最接近“对象模型写配置”的案例。

- 已知对象路径:
  - `InternetGatewayDevice.DeviceInfo.X_CMCC_ServiceManage.`
- 已知字段:
  - `TelnetEnable`
  - `TelnetWANEnable`
  - `TelnetUserName`
  - `TelnetPassword`
- 已知机型:
  - `TEWA-872G`
- 研究价值:
  - 与 TR-069 / TR-181 风格对象树高度相关。
  - 对中国移动定制机型的管理模型研究价值很高。

#### 来源

- GitHub Issue #23

## 设备命令

### `telecomadmin get`

- 常见用途:
  - 在已进入 Telnet 或设备命令环境后读取超级管理员密码
- 常见关联机型:
  - `TEWA-1006G`
  - 社区还把它扩展到 `708E / 1000E`
- 现状:
  - 社区资料较多，但返回格式、适用固件与前置条件不完全统一。

#### 来源

- ChinaDSL
- 恩山

### `CUAdmin get`

- 常见用途:
  - 较早期天邑设备中读取超管密码
- 常见关联机型:
  - `TEWA-300/500/600/700/750` 一类
- 现状:
  - 主要见于“早期设备”和“老分代”经验总结。

#### 来源

- 恩山

### `sendcmd 1 DB save`

- 常见用途:
  - 触发数据库保存
- 现状:
  - 经常与 `saveasy` 一起出现。
  - 目前缺少公开样本确认其真实后端与返回值。

#### 来源

- 恩山相关帖子汇总

### `sendcmd 1 DB saveasy`

- 常见用途:
  - 异步保存数据库
- 现状:
  - `saveasy` 拼写本身就值得保留，因为社区资料里经常原样出现。
  - 暂不改写成其它拼写，等待后续 GPL 或固件样本确认。

#### 来源

- 恩山相关帖子汇总

## shell 与高权限入口

### `su`

- 用途:
  - 进入更高权限 shell
- 典型关联:
  - `TEWA-1006G`
  - `TEWA-1000E`
- 社区常见说法:
  - `su` 密码与 MAC、SN、设备算法有关
  - 不同型号和出厂分代算法不同

#### 来源

- ChinaDSL
- 恩山
- GitHub Issue #24

### `echo $USER`

- 用途:
  - 判断当前环境是受限用户、`telnet-user` 还是更高权限用户
- 典型关联:
  - `TEWA-1000E`

#### 来源

- GitHub Issue #24

### `/opt/upt/apps/ssh/start_ssh.sh`

- 用途:
  - 启动社区自建的 SSH 服务
- 典型关联:
  - `TEWA-1000E`
- 关联路径:
  - `/opt/upt/apps/ssh/`
  - `/var/samba/smb.conf`
  - `/var/group`

#### 来源

- GitHub Issue #24

### `ip6tables -I INPUT ... --dport 22 -j ACCEPT`

- 用途:
  - 放行 IPv6 SSH 入站
- 典型关联:
  - `TEWA-1000E`

#### 来源

- GitHub Issue #24

## 命令与入口的使用方式

从目前资料看，天邑的入口大致可分成四层：

1. Web 隐藏页
2. Web CGI / 对象接口
3. Telnet 受限命令环境
4. 更高权限 shell / 自建 SSH

不同型号会停留在不同层，不一定都能贯通。

## 待验证

- `telecomadmin get` 是否在所有 `TEWA-708E / 1000E / 1006G` 分支通用。
- `CUAdmin get` 是否只适用于旧设备。
- `sendcmd` 的真实命令空间、权限要求与数据库后端。
- `telandftpcfg.cmd` 是否只是 Web 前端，而非真正核心能力入口。
- `;` 触发 root 的行为究竟属于命令注入、调试残留还是设备命令层设计缺陷。

## 来源

- GitHub / GitHub Issues
- 恩山无线论坛
- ChinaDSL
- 详细索引见 [Research/Commands](../Research/Commands/README.md)
