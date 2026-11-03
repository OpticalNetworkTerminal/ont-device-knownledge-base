# Object 树

## 顶层结构

采集结果确认 `com.cuc.igd1` 是业务主树：

```text
/com/cuc/igd1
├── Config
├── Diagnostics
├── FTTR
├── Firewall
├── Info
├── Network
├── Storage
├── Transfer
└── Unicom
```

## 功能域对象数量

| 功能域 | 对象数量 | 说明 |
| --- | ---: | --- |
| `Config` | 52 | 配置主域，包含 WiFi、DHCP、LANHosts、Ethernet、LED、电源、家长控制 |
| `Transfer` | 29 | 转发、QoS、流量、WMM、镜像、监控 |
| `Info` | 13 | 设备、PON、WAN、VoIP、WiFi 状态 |
| `Storage` | 9 | USB、NAS、Samba、FTP |
| `Firewall` | 5 | IPSet、VPN、网络加速、流控 |
| `Network` | 5 | HTTPServer、测速、访问控制、存储黑名单 |
| `Unicom` | 4 | PPPoE、系统命令 |
| `FTTR` | 3 | 光口与从设备 |
| `Diagnostics` | 3 | Ping、TraceRoute |

## Config

```text
Config
├── DHCPServer
├── EthernetConfig
│   ├── 1
│   ├── 2
│   ├── 3
│   └── 4
├── LANHosts
│   ├── 1..19
├── ParentalControlCTR
├── ParentalControlConfig
├── Peripheral
│   └── LED
├── Power
│   └── SleepTimer
└── WLAN
    ├── Devices
    │   ├── 1..8
    │   │   └── WPS
    └── Timer
```

`Config` 是 Web 后台“设置类页面”的主要 DBus 域。RW 属性主要集中在这里。

## Info

```text
Info
├── Device
├── MngPlat
├── Network
│   └── WANConnectionDb
│       ├── 1
│       │   └── PortMapping
│       └── 2
│           └── PortMapping
├── PON
├── VoIP
│   └── 1
└── WiFi
```

`Info` 以运行状态为主。虽然部分对象也暴露 `Set/SetValues`，但多数业务字段为 RO，开发时应先按只读状态源处理。

## Transfer

```text
Transfer
├── AutoDiagnostics
│   ├── Monitor
│   └── Redirect
├── FastPathSpeedUp
├── Layer3ForwardingIPv4Config
├── Layer3ForwardingIPv6Config
├── TrafficDetailProcess
├── TrafficForward
├── TrafficMirror
├── TrafficMonitoringConfig
├── TrafficQoSFlow
│   ├── 1..8
│   │   └── Classification
└── WMMConfiguration
```

`Transfer` 是转发与流量策略域，包含 QoS、WMM、流量镜像、IPv4/IPv6 forwarding 配置等能力。

## Storage

```text
Storage
├── FTPServers
│   └── 1
├── NAS
├── SambaServer
│   └── Accounts
│       └── 1
└── USB
    └── Devices
```

`Storage/NAS` 暴露文件操作方法，风险高于普通属性读取。

## Firewall

```text
Firewall
├── IPSet
├── L2TPVPN
├── NetworkAcceleration
└── TrafficControl
```

`Firewall/IPSet` 是操作型接口，提供 `AddIPSet/DeleteIPSet/DeleteIPSetEntry` 等方法。其他集合对象通过 `ObjectManager` 管理配置实例。

## Network

```text
Network
├── AccessControlBlackList
├── HTTPServer
├── SpeedTestTry
└── StorageBlackList
```

该域包含 Web/HTTP 服务配置、测速任务与黑名单对象。

## Unicom

```text
Unicom
├── PPPoE
│   └── 2
└── System
```

`Unicom/System` 是系统级高风险对象，包含 `Reboot`、`Restore`、`LocalRecovery`、`InformUpgrade` 等方法。

## FTTR 与 Diagnostics

```text
FTTR
├── LanOptic
└── Slave

Diagnostics
├── IPPing
└── TraceRoute
```

FTTR 负责光口和从设备状态；Diagnostics 负责网络诊断任务。
