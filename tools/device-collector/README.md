# Device Collector

`device-collector` 是面向 ONT / OpenWrt / Buildroot / BusyBox / 通用嵌入式 Linux 设备的长期维护型采集工具目录。

当前已经提供以下基础采集器：

- `collect.sh`
  - 主入口，负责组织整套采集流程
- `dbus-dump.sh`
  - 通用 DBus 自动采集
- `ubus-dump.sh`
  - 通用 ubus 自动采集
- `sendcmd-dump.sh`
  - 通用 sendcmd 只读自动采集
- `filesystem-dump.sh`
  - 通用文件系统结构采集

## 设计目标

- BusyBox 优先兼容
- Buildroot / OpenWrt / Linux 优先兼容
- POSIX Shell 为主
- 单项失败不影响整体
- 输出结构稳定，便于知识库归档与 AI 分析
- 后续支持厂商插件持续扩展

## 目录结构

```text
device-collector/
├── README.md
├── collect.sh
├── collect-host.sh
├── collect-lxc.sh
├── collect-elf.sh
├── collect-firmware.sh
├── dbus-dump.sh
├── ubus-dump.sh
├── sendcmd-dump.sh
├── filesystem-dump.sh
├── lib.sh
├── lib/
│   ├── common.sh
│   ├── dbus.sh
│   └── output.sh
├── plugins/
│   ├── README.md
│   ├── example-vendor-plugin.sh
│   └── sendcmd/
│       ├── README.md
│       └── zte-generic.sh
├── output/
└── samples/
```

## 用法

运行整套采集：

```sh
cd tools/device-collector
sh ./collect.sh
```

单独运行 ubus 采集：

```sh
sh ./ubus-dump.sh -o /tmp/ubus
```

单独运行 sendcmd 采集：

```sh
sh ./sendcmd-dump.sh -o /tmp/sendcmd
```

单独运行文件系统采集：

```sh
sh ./filesystem-dump.sh -o /tmp/filesystem
```

## 各采集器说明

### `ubus-dump.sh`

- 自动检测 `ubus`
- 自动导出 `ubus list`
- 遍历每个 object
- 解析 method 与签名
- 仅对无参数且不命中危险关键字的方法执行 `ubus call`
- 生成 `objects/*.md`

输出结构：

```text
ubus/
├── README.md
├── summary.md
├── objects.txt
├── logs/
└── objects/
```

### `sendcmd-dump.sh`

- 自动检测 `sendcmd`
- 采用插件化探测
- 通过只读探测命令自动发现候选表
- 通过只读查询命令导出表内容
- 自动跳过危险关键字命令

输出结构：

```text
sendcmd/
├── README.md
├── summary.md
├── tables.txt
├── logs/
└── tables/
```

### `filesystem-dump.sh`

- 采集 `mount` / `/proc/mounts` / `/proc/filesystems` / `df`
- 采集 `/proc/mtd` / `ubi` / `ubinfo`
- 输出受控深度目录树
- 输出配置文件索引
- 输出可执行文件索引
- 输出 socket 列表
- 输出 overlay 分析结果

输出结构：

```text
filesystem/
├── README.md
├── summary.md
├── tree/
├── configs/
├── executables/
└── logs/
```

### `dbus-dump.sh`

- 自动发现 system bus 上的 service
- 自动递归遍历 object tree
- 自动采集 interface / method / signal / property
- 自动调用 `GetAll`
- 自动调用 `GetManagedObjects`

## 安全说明

- `ubus-dump.sh` 只自动执行无参数方法
- `sendcmd-dump.sh` 只执行插件声明的只读命令
- 所有带明显修改语义的命令都应被拒绝
- 任意单项失败不会中断整次采集

## 样例

输出目录样例见：

- `samples/sample-output-tree.txt`

## 后续扩展建议

- 为 `sendcmd` 增加更多厂商/版本插件
- 为 `ubus` 增加更细粒度的方法签名解析
- 为 `filesystem` 增加分区与 overlay 结构化摘要
- 将各模块 `summary.md` 继续汇总到主 `summary.json`
