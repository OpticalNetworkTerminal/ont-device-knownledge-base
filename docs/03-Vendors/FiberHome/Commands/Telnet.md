# Telnet

本页先建立 `Telnet` 命令索引，只收录已进入 shell 后的只读巡检命令，不收录开启方式和绕过方式。

## 已验证内容

- `Telnet` 在烽火设备公开研究中确实出现过，但不是官方公开常规管理面。
- 不同固件对 `telnetd` 的开放策略差异很大。

## 待验证内容

- 各 `HG`/`AN` 子型号的默认开放状态
- 不同运营商固件的命令可用性

## 命令索引

### `uname -a`

| 字段 | 内容 |
| --- | --- |
| 功能 | 识别内核、架构和构建信息 |
| 语法 | `uname -a` |
| 参数 | 无 |
| 返回值 | 系统标识字符串 |
| 示例 | `uname -a` |
| 适用型号 | 已获得 shell 的机型 |
| 风险等级 | 低 |
| 验证状态 | 通用命令，未实机验证 |
| 来源 | Linux/BusyBox 通用 |

### `ps`

| 字段 | 内容 |
| --- | --- |
| 功能 | 查看进程列表，识别 `webs`、`cwmp`、`omci`、`dropbear`、`telnetd` |
| 语法 | `ps` |
| 参数 | 无 |
| 返回值 | 进程列表 |
| 示例 | `ps` |
| 适用型号 | 已获得 shell 的机型 |
| 风险等级 | 低 |
| 验证状态 | 通用命令；进程命名与公开研究部分吻合 |
| 来源 | [Pierre Kim 研究](https://pierrekim.github.io/blog/2021-01-12-fiberhome-ont-0day-vulnerabilities.html) |

### `netstat -lnp`

| 字段 | 内容 |
| --- | --- |
| 功能 | 查看监听端口与进程 |
| 语法 | `netstat -lnp` |
| 参数 | `-l`、`-n`、`-p` |
| 返回值 | 监听端口列表 |
| 示例 | `netstat -lnp` |
| 适用型号 | BusyBox 带 `netstat` 的机型 |
| 风险等级 | 低 |
| 验证状态 | 通用命令，未实机验证 |
| 来源 | Linux/BusyBox 通用 |

### `cat /proc/mtd`

| 字段 | 内容 |
| --- | --- |
| 功能 | 查看分区布局 |
| 语法 | `cat /proc/mtd` |
| 参数 | 无 |
| 返回值 | MTD 分区表 |
| 示例 | `cat /proc/mtd` |
| 适用型号 | 基于 MTD 的机型 |
| 风险等级 | 低 |
| 验证状态 | 与公开 bootlog 线索吻合 |
| 来源 | [AN5506 bootlog](https://gist.github.com/platkaw/926b7176714e02f3c729680584400f2d) |
