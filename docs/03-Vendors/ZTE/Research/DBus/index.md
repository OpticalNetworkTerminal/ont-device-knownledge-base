# DBus / Config DB Index

本页保留“对象/表/接口”层面的研究线索。

## 当前已命中的对象/表

| 对象/表 | Evidence | 上下文 |
| --- | --- | --- |
| `DBBase` | C | 数据库总表 |
| `WAND` | C | WAN 相关 |
| `WANCD` | C | WAN VLAN/描述类线索 |
| `WANC` | C | WAN 连接 |
| `WANCServList` | C | 业务类型列表 |
| `WANCIP` | C | IP 接口 |
| `WANCPPP` | C | PPPoE |
| `LAND` | C | LAN |
| `BrGrp` | C | Bridge group |
| `DevInfo` | C | 设备概览 |
| `DevAuthInfo` | B/C | Web 账户/权限 |
| `TelnetCfg` | B/C | Telnet 配置 |
| `TelnetUser` | C | Telnet 用户 |
| `PortControl` | C | 端口开关 |
| `MgtServer` | C | TR-069 / ACS |
| `CltLmt` | C | 用户数量限制 |
| `FWBase` | C | 连接数限制 |
| `PDTCTUSERINFO` | C | 注册状态/LOID 页面逻辑 |
| `WLANCfg` | C | 无线 SSID 前缀等 |
| `WLCInfo` | C | 无线控制状态 |
| `FTPUser` | D | FTP 用户 |
| `FTPServerCfg` | C | FTP 服务配置 |
| `VoIPSIPLine` | D | 语音线索 |
| `QOSCONFProduct` 等 Product 表族 | C | ChinaDSL/恩山转载代码大全中大量出现 |

## 原始资料去向

- `sendcmd`/`sidbg` 命令层面：见 [Commands](../Commands/index.md)
- 配置文件层面：见 [Config](../Config/index.md)
- 社区原帖层面：见 [Community](../Community/index.md)
