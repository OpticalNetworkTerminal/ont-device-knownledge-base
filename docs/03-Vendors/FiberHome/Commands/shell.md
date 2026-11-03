# Shell

本页聚合 FiberHome 设备在 `Telnet`、`SSH`、串口或其它 shell 入口下的已整理命令，避免再按接入方式拆成多个碎片页面。

## Telnet

本节先保留 `Telnet` 命令索引，只收录已进入 shell 后的只读巡检命令，不收录开启方式和绕过方式。

### 已验证内容

- `Telnet` 在烽火设备公开研究中确实出现过，但不是官方公开常规管理面。
- 不同固件对 `telnetd` 的开放策略差异很大。

### 待验证内容

- 各 `HG`/`AN` 子型号的默认开放状态
- 不同运营商固件的命令可用性

### 命令索引

#### `uname -a`

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

#### `ps`

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

#### `netstat -lnp`

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

#### `cat /proc/mtd`

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

## SSH

本节保留 `SSH` 相关索引。当前阶段仅记录“若设备已合法开放 SSH，建议如何记录和验证”。

### 已验证内容

- 官方资料很少把 `SSH` 作为常规 ONT 管理面公开。
- `SSH` 是否存在，强依赖具体型号、固件和调试态。

### 待验证内容

- 各 `HG` 子型号是否存在可公开确认的 `SSH` 管理面
- `dropbear` 在不同固件中的存在范围

### 命令索引

#### `ssh user@host`

| 字段 | 内容 |
| --- | --- |
| 功能 | 建立 SSH 会话 |
| 语法 | `ssh user@host` |
| 参数 | `user`、`host` |
| 返回值 | 登录成功后进入 shell；失败则返回认证或连接错误 |
| 示例 | `ssh admin@192.168.1.1` |
| 适用型号 | 已开放 SSH 的机型 |
| 风险等级 | 中 |
| 验证状态 | 通用用法，设备侧支持状态待验证 |
| 来源 | OpenSSH 通用 |

#### `df -h`

| 字段 | 内容 |
| --- | --- |
| 功能 | 查看分区空间占用 |
| 语法 | `df -h` |
| 参数 | `-h` |
| 返回值 | 文件系统空间统计 |
| 示例 | `df -h` |
| 适用型号 | 已开放 SSH shell 的机型 |
| 风险等级 | 低 |
| 验证状态 | 通用命令，未实机验证 |
| 来源 | Linux/BusyBox 通用 |

## Debug

本节聚焦串口、bootlog、启动参数和恢复判断。

### 已验证内容

- 公开 bootlog 显示 FiberHome 部分机型采用嵌入式 Linux + `JFFS2` + `MTD` 分区布局。
- `Reset` 键在官方资料中承担重启与恢复出厂功能。

### 待验证内容

- 各型号串口参数是否一致
- 各型号恢复后配置分区保留策略

### 命令索引

#### `cat /proc/cmdline`

| 字段 | 内容 |
| --- | --- |
| 功能 | 查看启动参数 |
| 语法 | `cat /proc/cmdline` |
| 参数 | 无 |
| 返回值 | 启动参数字符串 |
| 示例 | `cat /proc/cmdline` |
| 适用型号 | 已获得 shell 的机型 |
| 风险等级 | 低 |
| 验证状态 | 与公开 bootlog 结构吻合 |
| 来源 | [AN5506 bootlog](https://gist.github.com/platkaw/926b7176714e02f3c729680584400f2d) |

#### `mount`

| 字段 | 内容 |
| --- | --- |
| 功能 | 查看文件系统挂载点 |
| 语法 | `mount` |
| 参数 | 无 |
| 返回值 | 挂载列表 |
| 示例 | `mount` |
| 适用型号 | 已获得 shell 的机型 |
| 风险等级 | 低 |
| 验证状态 | 通用命令，未实机验证 |
| 来源 | Linux/BusyBox 通用 |

## 公开 CLI / 维护关键词索引

本节整理 Research 中公开出现过的 FiberHome CLI、隐藏入口、调试关键词和诊断关键词。部分条目来自社区或漏洞资料，不能直接视为所有型号可用。

| 关键词 | 分类 | 适用型号 | 来源状态 | 首次整理来源 |
| --- | --- | --- | --- | --- |
| `debug` | 调试关键词 | `AN5506-04-FA` | 社区 | [PLDT 默认管理资料 Gist](https://gist.github.com/mihkuno/d70564c3c890703d4ec9197b34f5918f) |
| `telnet` | 管理面关键词 | `HG6145D` 等 | 社区 | [ChinaDSL HG6145D Telnet](https://www.chinadsl.net/thread-170876-1-1.html) |
| `telnetenable.cgi` | 隐藏入口关键词 | `HG6145F3` | 社区 | [恩山 HG6145F3 移动版](https://www.right.com.cn/forum/thread-8436021-1-1.html) |
| `factory` | 工厂模式关键词 | `HG3142F` | 社区 | [恩山 HG3142F](https://www.right.com.cn/forum/thread-8434746-1-1.html) |
| `load_cli` | CLI 关键词 | `HG3142F` | 社区 | [恩山 HG3142F](https://www.right.com.cn/forum/thread-8434746-1-1.html) |
| `show admin_pwd` | CLI 关键词 | `HG6143D1` 等 | 社区 | [恩山 Telnet 用户名和密码讨论](https://www.right.com.cn/forum/thread-8368395-1-1.html) |
| `show admin_name` | CLI 关键词 | `HG` 系列未明确子型号 | 社区 | [CSDN 移动烽火 HG 光猫资料](https://blog.csdn.net/mgledu/article/details/138901373) |
| `show allinfo` | CLI 关键词 | 未标注 | 社区 | [恩山新版 Telnet 超密讨论](https://www.right.com.cn/forum/thread-8407524-1-1.html) |
| `load preconfig` | CLI 关键词 | 未标注 | 社区 | [恩山新版 Telnet 超密讨论](https://www.right.com.cn/forum/thread-8407524-1-1.html) |
| `cfg` | 分区名/配置关键词 | `AN5506-04-FA` | 研究 | [AN5506-04-FA bootlog](https://gist.github.com/platkaw/926b7176714e02f3c729680584400f2d) |
| `shell` | 调试关键词 | `AN5506-04F` | 研究 | [fiberhome-AN5506-04F-](https://github.com/ndunks/fiberhome-AN5506-04F-) |
| `diag` | 诊断关键词 | `AN5506-04-F RP2617` | 研究 | [GitHub Advisory GHSA-hcfv-5p8h-vvh5](https://github.com/advisories/GHSA-hcfv-5p8h-vvh5) |
| `sendcmd` | 待补关键词 | 未定位到 FiberHome Research 直接来源 | 待验证 | 当前 Research 未收录直接来源 |

## 待验证

- `sendcmd` 是否出现在 FiberHome GPL、rootfs 或论坛资料中。
- `show admin_pwd`、`show admin_name`、`show allinfo` 是否来自同一个 FiberHome CLI 框架。
- `telnetenable.cgi` 是否只适用于特定移动版固件，还是多个 `HG` 子型号共用。
- `diag` 在 `AN5506-04-F RP2617` 以外版本中的存在范围。
