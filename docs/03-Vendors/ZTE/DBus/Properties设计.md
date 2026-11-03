# Properties 设计

## 总体分布

采集到 1332 个 Property：

| 权限 | 数量 | 含义 |
| --- | ---: | --- |
| RW | 309 | 可通过厂商 `Properties.Set/SetValues` 修改的候选配置项 |
| RO | 1023 | 运行状态、统计、硬件信息、派生状态 |

RW 字段主要集中在：

- `Config/WLAN/Devices/{1..8}`：WiFi 配置。
- `Config/DHCPServer`：DHCP/LAN 地址配置。
- `Config/LANHosts/{1..19}`：终端别名、类型、上下行限速。
- `Transfer/TrafficQoSFlow/{1..8}`：QoS 上下行速率与 DSCP。
- `Storage/FTPServers/1`, `Storage/SambaServer`：存储服务配置。
- `Network/SpeedTestTry`：测速任务参数。

## 配置型 Property

| 字段 | 对象 | 含义 |
| --- | --- | --- |
| `SSID` | WiFi | 无线网络名称 |
| `PWD` | WiFi | 无线密码 |
| `Enable` | WiFi/WPS/端口/服务 | 开关 |
| `Channel` | WiFi | 无线信道 |
| `AutoChannelEnable` | WiFi | 自动信道 |
| `TransmitPower` | WiFi | 发射功率 |
| `SSIDAdvertisementEnabled` | WiFi | 是否广播 SSID |
| `FrequencyWidth` | WiFi | 频宽 |
| `Standard` | WiFi | 无线制式 |
| `PortIsolation` | WiFi | 端口/客户端隔离 |
| `DHCPServerEnable` | DHCP | DHCP 服务开关 |
| `LocalIP` | DHCP | LAN 网关地址 |
| `Submask` | DHCP | LAN 子网掩码 |
| `DHCPStartIP` | DHCP | 地址池起始 |
| `DHCPEndIP` | DHCP | 地址池结束 |
| `DHCPDuration` | DHCP | DHCP 租期 |
| `DevName` | LANHost | 客户端显示名 |
| `DevType` | LANHost | 客户端类型 |
| `UsBandwidth` / `DsBandwidth` | LANHost | 上下行限速 |
| `UsGuaranteeBandwidth` / `DsGuaranteeBandwidth` | LANHost | 上下行保障带宽 |

## 状态型 Property

| 字段 | 对象 | 含义 |
| --- | --- | --- |
| `RSSI`, `SNR`, `Noise` | LANHost | 无线信号质量 |
| `RxBytes`, `TxBytes` | LANHost/WAN/PON | 累计收发字节 |
| `UpSpeed`, `DownSpeed` | LANHost | 当前上下行速率 |
| `ConnectionStatus` | WAN | WAN 连接状态 |
| `IPAddress`, `Gateway`, `DNSServers` | WAN | IPv4 网络参数 |
| `IPv6IPAddress`, `IPv6Gateway`, `IPv6Prefix` | WAN | IPv6 网络参数 |
| `PONStatus` | PON | PON 链路状态 |
| `RXPower`, `TXPower`, `Voltage`, `Current`, `Temperature` | PON/FTTR | 光模块物理状态 |
| `OnlineSta`, `MaxSta` | WiFi | 在线终端数与最大终端数 |
| `TotalBytesSent`, `TotalBytesReceived` | WiFi | 无线侧累计流量 |

## 凭据型 Property

| 字段 | 对象 | 权限 | 风险 |
| --- | --- | --- | --- |
| `PWD` | WiFi | RW | 修改会影响无线接入 |
| `Password` | HTTPServer / FTP / Samba Account | RW 或 RO | 可能影响管理、FTP、Samba 登录 |
| `UserName` | FTP/Samba 等 | RW | 账号名 |
| `PPPoEPassword` | PPPoE | RO | 敏感信息，只读采集到字段名 |

## 命名规律

- `Config/*` 下字段多为配置项。
- `Info/*` 下字段多为状态项。
- `*Bytes*`, `*Pkts*`, `*Speed*` 多为统计或实时速率。
- `Max*`, `NumberOfEntries` 多为容量或实例数量。
- `Enable` 需要结合对象判断含义，例如 WiFi 开关、WPS 开关、HTTP 服务开关、FTP/Samba 开关。
