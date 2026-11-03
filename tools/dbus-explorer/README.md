# DBus Explorer

`dbus-explorer` 是面向 ONT、Buildroot、OpenWrt、LXC 和通用 Linux Embedded 的 DBus 自动发现与导出工具。

它不是一次性 dump 脚本，而是 `ont-device-knowledge-base` 的官方 DBus 采集工具目录。设计目标是：优先兼容 BusyBox / POSIX Shell，自动发现 Service，递归遍历 Object Tree，导出 Interface / Method / Signal / Property / GetAll / ObjectManager，并同时生成 Markdown 与 JSON。

## 特性

- 自动检测 `gdbus`、`dbus-send`、`timeout`
- 优先使用 `gdbus`，缺失时降级到 `dbus-send`
- 从 `/` 开始递归 object tree
- 自动去重，避免重复采集
- 自动解析 interface、method、signal、property、child node
- 自动识别 `*.Properties`，调用 `GetAll` 读取 Property 实际值
- `GetAll` 不支持或无法解析时自动降级到逐个 `Get`
- 自动调用 `org.freedesktop.DBus.ObjectManager.GetManagedObjects`
- 自动生成敏感属性、可写属性、Web 管理相关候选索引
- 保存全部 raw command output，便于后续重新解析
- 生成 Markdown、JSON、tree.txt、summary.md
- 统一日志：`logs/run.log`、`logs/error.log`、`logs/debug.log`
- 预留厂商插件：Huawei、ZTE、FiberHome、天邑
- 可选搜索与版本对比

## 目录结构

```text
tools/dbus-explorer/
├── README.md
├── dbus-explorer.sh
├── lib.sh
├── modules/
│   ├── service.sh
│   ├── object.sh
│   ├── property.sh
│   ├── markdown.sh
│   └── json.sh
├── plugins/
│   ├── README.md
│   └── example-vendor-plugin.sh
└── output/
```

## 运行

在设备上运行：

```sh
cd tools/dbus-explorer
sh ./dbus-explorer.sh collect
```

指定输出目录：

```sh
sh ./dbus-explorer.sh collect -o /tmp/dbus-explorer
```

只采集指定 service：

```sh
sh ./dbus-explorer.sh collect -s com.cuc.igd1,com.cuc.ufw1
```

采集 session bus：

```sh
sh ./dbus-explorer.sh collect -b session
```

设置单条 DBus 命令超时：

```sh
sh ./dbus-explorer.sh collect -t 3
```

采集时默认会实时输出进度到终端，包括工具检测、Service 数量、当前 Service、当前 Object、`GetAll`、`GetManagedObjects` 和失败原因。详细命令日志仍写入：

```text
logs/run.log
logs/error.log
logs/debug.log
```

静默采集：

```sh
sh ./dbus-explorer.sh collect -q
```

## 输出

一次采集会生成：

```text
output/run-YYYYmmdd-HHMMSS/
├── services.txt
├── service-index.md
├── summary.md
├── tree.txt
├── SensitiveObjects.md
├── SensitiveProperties.md
├── WritableProperties.md
├── WebManagement.md
├── run.info
├── logs/
│   ├── run.log
│   ├── error.log
│   └── debug.log
├── raw/
│   ├── services/
│   ├── objects/
│   ├── properties/
│   └── managed-objects/
├── markdown/
│   ├── service-index.md
│   ├── summary.md
│   ├── tree.txt
│   ├── properties/
│   └── SERVICE_NAME/
└── json/
    ├── services.json
    ├── tree.json
    ├── objects.json
    ├── interfaces.json
    ├── methods.json
    ├── signals.json
    ├── properties.json
    ├── properties-values.json
    ├── getall.json
    ├── managed-objects.json
    └── summary.json
```

每个 Object 会生成一个 Markdown 文件，包含：

- Object Path
- Service
- Interfaces
- Methods
- Signals
- Properties
- Current Values
- GetAll
- ManagedObjects
- Child Objects

## 搜索

默认搜索最近一次采集目录：

```sh
sh ./dbus-explorer.sh search WLAN
sh ./dbus-explorer.sh search DHCP
sh ./dbus-explorer.sh search LANHost
sh ./dbus-explorer.sh --grep Password
sh ./dbus-explorer.sh --grep PPPoE
sh ./dbus-explorer.sh --grep LOID
```

指定目录：

```sh
sh ./dbus-explorer.sh search WLAN -o output/run-20260713-120000
```

## 版本对比

对比旧固件与新固件的采集结果：

```sh
sh ./dbus-explorer.sh compare old-output new-output
```

输出包含：

- 新增 / 删除 Object
- 新增 / 删除 Interface
- 新增 / 删除 Method
- 新增 / 删除 Property

## 插件

插件放在 `plugins/*.sh`，会在采集开始时自动加载。

预留 hook：

```sh
dbus_explorer_plugin_after_object() {
    service=$1
    object_path=$2
    introspect_file=$3
    # vendor-specific parsing
}
```

建议后续添加：

- `plugins/huawei.sh`
- `plugins/zte.sh`
- `plugins/fiberhome.sh`
- `plugins/tw.sh`

## 兼容性说明

本工具只依赖 POSIX Shell 和常见 BusyBox 工具：

- `sh`
- `awk`
- `sed`
- `grep`
- `cut`
- `sort`
- `uniq`
- `find`
- `mkdir`
- `basename`
- `dirname`

DBus 客户端使用：

- `gdbus`
- `dbus-send`

不依赖：

- Python
- Perl
- Node.js
- jq

## 设计说明

DBus Explorer 会同时保存 raw 输出和结构化索引。结构化解析失败不代表 raw 数据丢失，后续可以通过改进 parser 重新生成 Markdown / JSON。这对光猫、Buildroot、OpenWrt 等输出格式不一致的环境尤其重要。
