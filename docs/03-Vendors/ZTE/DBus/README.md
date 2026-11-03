# ZTE DBus 专题

本专题基于 `DBus Explorer` 对设备运行时 DBus 的完整采集结果整理，采集目录为：

`tools/dbus-explorer/output/run-20260713-195353`

采集摘要：

| 指标 | 数量 |
| --- | ---: |
| Service | 5 |
| Object | 141 |
| Interface 类型 | 49 |
| Method | 1063 |
| Property | 1332 |
| RW Property | 309 |
| RO Property | 1023 |
| 采集失败 | 0 |

## 当前结论

采集结果确认：该设备存在一套以 `com.cuc.igd1` 为核心的 DBus 管理模型。Web 后台、业务配置、运行状态、诊断、存储、QoS、FTTR 和联通定制能力都可以在 object tree 中找到对应对象。

需要注意的是，设备大量使用厂商自定义接口：

- `com.cuc.igd1.Properties`
- `com.cuc.igd1.ObjectManager`

它们在语义上接近标准 `org.freedesktop.DBus.Properties` 和 `org.freedesktop.DBus.ObjectManager`，但接口名不同。因此使用通用 DBus 工具时，不能只按标准接口判断对象是否支持属性读写或对象管理。

## 学习路线

1. 先读 [DBus架构](./DBus架构.md)，理解 Web 后台、Service、Object、Interface、Property 的关系。
2. 再读 [Service总览](./Service总览.md)，确认每个 Service 的职责边界。
3. 读 [Object树](./Object树.md) 和 [Business/功能域映射](./Business/功能域映射.md)，按 WiFi、LAN、WAN、DHCP、Storage、Firewall 等功能定位对象。
4. 读 [Properties机制](./Properties机制.md) 和 [ObjectManager机制](./ObjectManager机制.md)，理解读取、修改、增删对象的通用模式。
5. 开发或逆向时读 [API/对象手册](./API/对象手册.md)、[Reverse/可修改项](./Reverse/可修改项.md)、[Reverse/危险接口](./Reverse/危险接口.md)。

## 目录导航

| 文档 | 作用 |
| --- | --- |
| [DBus架构](./DBus架构.md) | 总体架构、调用链、Mermaid 图 |
| [Service总览](./Service总览.md) | 5 个 Service 的职责分析 |
| [Object树](./Object树.md) | 全局 object tree 和功能域树 |
| [Interface设计](./Interface设计.md) | 接口类型、通用接口、业务接口 |
| [Properties设计](./Properties设计.md) | 字段语义、配置/状态分类 |
| [Properties机制](./Properties机制.md) | `Get/GetAll/Set/SetValues` 使用方式 |
| [ObjectManager机制](./ObjectManager机制.md) | `AddObject/DeleteObject/GetManagedObjects` |
| [开发指南](./开发指南.md) | gdbus 调用示例与开发流程 |
| [最佳实践](./最佳实践.md) | 安全读取、修改、回滚建议 |
| [API/对象手册](./API/对象手册.md) | 按功能域整理核心对象 API |
| [Business/功能域映射](./Business/功能域映射.md) | Web 后台功能到 DBus 对象映射 |
| [Reverse/可修改项](./Reverse/可修改项.md) | RW Property 分类 |
| [Reverse/危险接口](./Reverse/危险接口.md) | 高风险 Method 分析 |
| [Reverse/分析结论](./Reverse/分析结论.md) | 已确认事实与待验证推测 |
| [Reference/采集摘要](./Reference/采集摘要.md) | 原始采集统计与证据索引 |
| [Reference/字段字典](./Reference/字段字典.md) | 常见 Property 字段含义 |

## 能力概览

| 功能域 | 代表对象 | 说明 |
| --- | --- | --- |
| WiFi | `/Config/WLAN/Devices/{1..8}` | SSID、密码、信道、功率、隐藏、访客网络、WPS |
| LAN 客户端 | `/Config/LANHosts/{1..19}` | 终端列表、名称、类型、速率、流量、无线信号 |
| DHCP/LAN | `/Config/DHCPServer` | 网关地址、掩码、地址池、租期、DHCP 开关 |
| WAN | `/Info/Network/WANConnectionDb/{1,2}` | WAN 连接、IPv4/IPv6、DNS、VLAN、流量 |
| PON | `/Info/PON` | 光模块、电压、电流、光功率、PON 状态 |
| FTTR | `/FTTR/LanOptic`, `/FTTR/Slave` | 从设备、光口状态、FTTR 数量 |
| Firewall | `/Firewall/IPSet`, `/Firewall/L2TPVPN` | IPSet、防火墙扩展、VPN、加速、限速 |
| QoS/Transfer | `/Transfer/TrafficQoSFlow/{1..8}` | QoS 流、上下行速率、DSCP remark、分类对象 |
| Storage | `/Storage/NAS`, `/Storage/SambaServer`, `/Storage/FTPServers` | USB、NAS、Samba、FTP、账号 |
| Diagnostics | `/Diagnostics/IPPing`, `/Diagnostics/TraceRoute` | Ping、TraceRoute 诊断 |
| System | `/Unicom/System`, `com.cuc.appframework1` | 日志、升级、恢复、重启、应用框架 |

## 核心对象

- `/com/cuc/igd1/Config/WLAN/Devices/1`：主 WiFi 配置对象。
- `/com/cuc/igd1/Config/DHCPServer`：LAN 与 DHCP 配置对象。
- `/com/cuc/igd1/Config/LANHosts`：终端列表管理对象。
- `/com/cuc/igd1/Info/Network/WANConnectionDb`：WAN 连接管理对象。
- `/com/cuc/igd1/Firewall/IPSet`：防火墙 IPSet 管理对象。
- `/com/cuc/igd1/Transfer/TrafficQoSFlow`：QoS flow 管理对象。
- `/com/cuc/igd1/Storage/NAS`：USB/NAS 文件操作对象。
- `/com/cuc/igd1/Unicom/System`：系统级操作对象，包含重启、恢复、升级查询等危险能力。

## 证据边界

本文档的“确认”结论来自 DBus Explorer 导出的 service、object、interface、method、property 索引。

Web 后台页面映射没有抓包证据时统一标注为“推测”。这些推测来自对象路径和字段命名，例如 `Config/WLAN/Devices` 明确对应 WiFi 配置，`Config/DHCPServer` 明确对应 DHCP 配置。
