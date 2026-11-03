# Web 后台映射

本页是从 DBus 对象命名和字段语义推导出的后台页面映射。除非标注“采集确认”，否则均为“推测，待抓包验证”。

## 页面映射表

| Web 后台页面 | DBus 对象 | 依据 | 状态 |
| --- | --- | --- | --- |
| 无线基本设置 | `Config/WLAN/Devices/{1..8}` | `SSID/PWD/Channel/Enable` | 推测 |
| 无线高级设置 | `Config/WLAN/Devices/{1..8}` | `TransmitPower/FrequencyWidth/Standard/AutoChannelEnable` | 推测 |
| 访客网络 | `Config/WLAN/Devices/{1..8}` | `IsGuest` | 推测 |
| WPS | `Config/WLAN/Devices/{n}/WPS` | `Enable/WPSStatus` | 推测 |
| WiFi 定时 | `Config/WLAN/Timer` | `StartTime/EndTime/ControlCycle` | 推测 |
| LAN/DHCP | `Config/DHCPServer` | `LocalIP/DHCPStartIP/DHCPEndIP` | 推测 |
| LAN 口状态 | `Config/EthernetConfig/{1..4}` | `BitRate/DuplexMode/BytesSent/Received` | 推测 |
| 终端列表 | `Config/LANHosts` 与子对象 | `GetOnlineDeviceList`, `MAC/IP/HostName` | 推测 |
| 终端限速 | `Config/LANHosts/{n}` | `UsBandwidth/DsBandwidth` | 推测 |
| WAN 状态 | `Info/Network/WANConnectionDb/{1,2}` | `ConnectionStatus/IPAddress/Gateway/DNS` | 推测 |
| IPv6 状态 | `Info/Network/WANConnectionDb/{1,2}` | `IPv6IPAddress/IPv6Prefix/IPv6Gateway` | 推测 |
| PON 光功率 | `Info/PON` | `RXPower/TXPower/Voltage/Temperature` | 推测 |
| 设备信息 | `Info/Device` | `ModelName/SerialNumber/SoftwareVersion` 等 | 推测 |
| VoIP 状态 | `Info/VoIP/1` | `PhoneNumber/LineStatus` | 推测 |
| 防火墙/IP 组 | `Firewall/IPSet` | `AddIPSet/DeleteIPSet` | 推测 |
| VPN | `Firewall/L2TPVPN` | `L2TPVPNProfile` | 推测 |
| QoS | `Transfer/TrafficQoSFlow/{1..8}` | `UpSpeed/DownSpeed/DSCPRemark` | 推测 |
| Samba | `Storage/SambaServer` | `Enable/Anonymous/Accounts` | 推测 |
| FTP | `Storage/FTPServers/1` | `Port/FTPPath/UserName/Password` | 推测 |
| USB 文件管理 | `Storage/NAS` | `ListFolder/Copy/Move/Remove` | 推测 |
| Ping 诊断 | `Diagnostics/IPPing` | `StartIPPingDiagnostics` | 推测 |
| TraceRoute | `Diagnostics/TraceRoute` | `StartTraceRouteDiagnostics` | 推测 |
| 系统重启/恢复 | `Unicom/System` | `Reboot/Restore/LocalRecovery` | 推测 |

## 验证方法

推荐验证方式：

```sh
dbus-monitor --system "destination='com.cuc.igd1'"
```

如果设备没有 `dbus-monitor`，可用进程跟踪或前端请求抓包辅助验证：

1. 打开 Web 页面。
2. 保存页面字段。
3. 比对 DBus `Set/SetValues`、`GetAll` 调用。
4. 回读目标对象确认字段变化。

## 关键判断

从 DBus 数据看，后台页面很可能采用“页面打开时 `GetAll`，保存时 `SetValues`”的模型。该判断来自以下事实：

- 110 个对象暴露 `com.cuc.igd1.Properties`。
- 113 个 `GetAll`、113 个 `Set`、110 个 `SetValues` 方法被采集到。
- 配置对象普遍存在 RW 字段。

该调用模式尚需 Web 后台抓包确认。
