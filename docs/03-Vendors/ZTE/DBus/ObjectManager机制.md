# ObjectManager 机制

## 厂商对象管理接口

设备使用 `com.cuc.igd1.ObjectManager` 管理集合对象。采集确认该接口出现 35 次，提供：

| Method | 作用 | 风险 |
| --- | --- | --- |
| `AddObject` | 新增子对象 | 中到高 |
| `DeleteObject` | 删除指定子对象 | 高 |
| `RemoveAllObjects` | 删除全部子对象 | 极高 |
| `GetManagedObjects` | 读取集合全部对象 | 低 |

## 集合对象

| 集合对象 | 子对象 | 说明 |
| --- | --- | --- |
| `/Config/LANHosts` | `/Config/LANHosts/1..19` | 客户端列表 |
| `/Config/WLAN/Devices` | `/Config/WLAN/Devices/1..8` | WiFi SSID/射频实例 |
| `/Config/EthernetConfig` | `/Config/EthernetConfig/1..4` | LAN 口实例 |
| `/Info/Network/WANConnectionDb` | `/Info/Network/WANConnectionDb/1..2` | WAN 连接实例 |
| `/Transfer/TrafficQoSFlow` | `/Transfer/TrafficQoSFlow/1..8` | QoS flow 实例 |
| `/Storage/FTPServers` | `/Storage/FTPServers/1` | FTP 服务实例 |
| `/Storage/SambaServer/Accounts` | `/Storage/SambaServer/Accounts/1` | Samba 账号实例 |
| `/Network/AccessControlBlackList` | 动态对象 | 访问控制黑名单 |
| `/Network/StorageBlackList` | 动态对象 | 存储黑名单 |

## 读取集合示例

```sh
gdbus call --system \
  --dest com.cuc.igd1 \
  --object-path /com/cuc/igd1/Config/LANHosts \
  --method com.cuc.igd1.ObjectManager.GetManagedObjects
```

```sh
gdbus call --system \
  --dest com.cuc.igd1 \
  --object-path /com/cuc/igd1/Transfer/TrafficQoSFlow \
  --method com.cuc.igd1.ObjectManager.GetManagedObjects
```

## 为什么重要

Web 后台打开“客户端列表”“WAN 连接列表”“QoS 规则列表”“端口映射列表”时，不适合逐个猜路径。`GetManagedObjects` 是更自然的入口，因为它一次返回对象路径、接口和属性。

## 删除风险

`DeleteObject` 和 `RemoveAllObjects` 很危险：

- 删除 WiFi、WAN、QoS、端口映射、账号、黑名单等对象可能破坏配置。
- `RemoveAllObjects` 是批量删除，除非在可恢复环境中验证，否则不要调用。
- 对 `LANHosts` 这类运行时数据库调用删除方法，可能导致客户端列表或限速策略异常。
