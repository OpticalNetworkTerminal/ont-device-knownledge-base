# Interface 设计

## 接口分层

采集结果显示，每个业务对象通常包含以下接口组合：

```text
org.freedesktop.DBus.Introspectable
org.freedesktop.DBus.Peer
com.cuc.igd1.Properties
业务接口，如 com.cuc.igd1.WLANConfiguration
```

集合型对象还会额外包含：

```text
com.cuc.igd1.ObjectManager
```

## 通用接口

| Interface | 出现次数 | 作用 |
| --- | ---: | --- |
| `org.freedesktop.DBus.Introspectable` | 114 | 返回对象接口、方法、属性、子节点定义 |
| `org.freedesktop.DBus.Peer` | 114 | `Ping` 与 `GetMachineId` |
| `com.cuc.igd1.Properties` | 110 | 厂商属性读写接口 |
| `com.cuc.igd1.ObjectManager` | 35 | 厂商对象集合管理接口 |

## 业务接口

| Interface | 对象 | 功能 |
| --- | --- | --- |
| `com.cuc.igd1.WLANConfiguration` | `/Config/WLAN/Devices/{1..8}` | WiFi SSID、密码、信道、功率、隐藏、访客、统计 |
| `com.cuc.igd1.WPS` | `/Config/WLAN/Devices/{1..8}/WPS` | WPS 开关和状态 |
| `com.cuc.igd1.DHCPServer` | `/Config/DHCPServer` | DHCP 开关、网关地址、地址池、租期 |
| `com.cuc.igd1.LANHost` | `/Config/LANHosts/{1..19}` | 客户端身份、连接、无线质量、速率、流量 |
| `com.cuc.igd1.LANHostManager` | `/Config/LANHosts` | 客户端集合与查询 |
| `com.cuc.igd1.EthernetConfig` | `/Config/EthernetConfig/{1..4}` | LAN 口开关、模式、速率、双工、流量 |
| `com.cuc.igd1.WANConnectionInfo` | `/Info/Network/WANConnectionDb/{1,2}` | WAN IPv4/IPv6、DNS、VLAN、连接状态、流量 |
| `com.cuc.igd1.PONInfo` | `/Info/PON` | PON 状态、光功率、电压、电流、温度 |
| `com.cuc.igd1.DeviceInfo` | `/Info/Device` | 型号、版本、CPU/MEM、运行状态 |
| `com.cuc.igd1.IPSet` | `/Firewall/IPSet` | IPSet 查询、添加、删除 |
| `com.cuc.igd1.NASAccess` | `/Storage/NAS` | NAS 文件列表、复制、移动、删除、重命名 |
| `com.cuc.igd1.SysCmd` | `/Unicom/System` | 系统命令、重启、恢复、升级通知、日志 |
| `com.cuc.appframework1.AppAgent` | `/com/cuc/appframework1` | 应用安装、卸载、升级、运行、停止 |
| `com.cuc.ufw1.framework` | `/com/cuc/ufw1` | 固件框架、MTD、升级、恢复 |

## 设计特点

1. 属性读写被抽象成统一接口，而不是每个业务接口单独定义 setter。
2. 集合管理被抽象成统一 `ObjectManager`，动态对象通过路径区分实例。
3. 配置对象和状态对象混在同一棵树中，需要靠 property 权限区分是否可修改。
4. 大量对象虽然暴露 `Set/SetValues`，但真正可修改字段只以 property 的 `readwrite` 为准。

## 信号

采集到 197 个 Signal。通用属性变更信号主要来自 `com.cuc.igd1.Properties`，可用于后台页面刷新或状态订阅。当前文档未确认 Web 后台是否实际订阅这些 Signal，需抓包或进程跟踪验证。
