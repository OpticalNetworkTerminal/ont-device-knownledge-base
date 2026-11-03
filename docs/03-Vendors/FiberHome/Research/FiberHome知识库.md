# FiberHome 烽火 ONT 知识库

本文是 `FiberHome / 烽火` ONT 的正式 Wiki 入口，基于 `Research/` 资料整理而来。资料来源包括官方产品页、官方 PDF、公开安全研究、GitHub/Gist、恩山、ChinaDSL、博客、运营商论坛、认证资料和社区经验。

本文不是一次性定稿。社区经验、逆向资料和运营商定制差异会被保留，并在对应条目中注明来源与状态。

## 资料状态

| 状态 | 含义 |
| --- | --- |
| `官方` | FiberHome 官网、官方 PDF、认证手册、标准组织资料 |
| `研究` | 公开安全研究、GitHub/Gist、固件/bootlog/配置工具分析 |
| `社区` | 恩山、ChinaDSL、OpenWrt Forum、运营商论坛等社区经验 |
| `待验证` | 来源不足、型号范围不清或多个来源存在冲突 |

## 快速结论

- `HG` 系列是当前资料中最完整的家庭网关型 ONT 家族，官方公开型号覆盖 GPON、XGSPON、Wi-Fi 5、Wi-Fi 6、Wi-Fi 7。
- `AN5506` 是社区和研究资料中出现频率最高的 `AN` 家族，常见形态包括桥接型 ONT、轻路由型 ONT 和运营商定制型号。
- `OMCI` 是 FiberHome GPON/ONT 管理链中的核心能力；新代 `HG` 设备官方资料通常同时列出 `Web UI / OMCI / TR-069`。
- `Telnet`、串口、隐藏页面、工厂模式、超级管理员和配置文件导出在社区资料中大量出现，但强依赖型号、运营商、地区和固件版本。
- 固件版本常以 `RPxxxx` 出现，例如 `RP2602`、`RP2613`、`RP2617`、`RP2627`、`RP4423`、`RP0303`。

## 型号索引

### HG 系列

| 型号 | 定位 | 已整理能力 | 来源状态 |
| --- | --- | --- | --- |
| `HG6019A` | GPON routing-type ONT | 官方型号存在性 | 官方 |
| `HG6119A` | GPON ONT | 官方型号存在性 | 官方 |
| `HG6142A` | GPON routing-type ONT | 4GE + POTS；山东联通社区经验 | 官方 + 社区 |
| `HG6144F` | GPON + Wi-Fi 6 routing-type ONT | 官方型号存在性 | 官方 |
| `HG6145D` | GPON + Wi-Fi 5 routing-type ONT | 移动版 Telnet、地区/桥接社区经验 | 官方 + 社区 |
| `HG6145D1` | 运营商定制型号 | 中国移动/联通社区经验、`RP0303` 配置片段线索 | 社区 |
| `HG6145D2` | GPON + Wi-Fi 5 routing-type ONT | `OMCI / Web UI / TR-069`、远程升级、IPv4/IPv6 | 官方 |
| `HG6145F` | GPON + Wi-Fi 6 routing-type ONT | WebUI JSON/API 工具线索 | 官方 + 研究 |
| `HG6145F1` | GPON + Wi-Fi 6 routing-type ONT | `OMCI / Web UI / TR-069`、`RP4423`、配置工具、阿尔及利亚运营商资料 | 官方 + 研究 |
| `HG6145F3` | GPON + Wi-Fi 6 routing-type ONT | 指示灯集合、移动版替换与 Telnet 社区经验 | 官方 + 社区 |
| `HG6240A` | 运营商配发型号 | ViewQwest SG 替换讨论 | 社区 |
| `HG6243F` | GPON + Wi-Fi 6 routing-type ONT | 官方型号存在性 | 官方 |
| `HG6245D` | 研究样本型号 | `RP2602/RP2613` 安全研究 | 研究 |
| `HG6543D` | GPON + Wi-Fi 5 routing-type ONT | 官方型号存在性 | 官方 |
| `HG6543C/C4` | 社区出现型号 | 联通桥接记录、TTL 启动过程 | 社区 |
| `HG6795H` | GPON + Wi-Fi 7 routing-type ONT | 官方型号存在性 | 官方 |
| `HG680P` | 机顶盒/改造样本 | OpenWrt 21.02 移植仓库线索 | 研究 |
| `HG8143F` | GPON ONT | PDF 线索含 `SN`、`Password`、`SN+Password`、`LOID` 认证方式与 EasyMesh | 官方 |

### AN 系列

| 型号 | 定位 | 已整理能力 | 来源状态 |
| --- | --- | --- | --- |
| `AN5506-01-A` | GPON bridging-type ONT | `OMCI / Web UI`、`Bridged`、`Routed Internet Service`、`IPTV` | 官方 |
| `AN5506_01A2G` | Web 显示型号 | 逻辑 `SN`、`LOID`、替换光猫社区讨论 | 社区 |
| `AN5506-02` | GPON ONT | Anatel/FCC 手册页线索 | 官方/认证 |
| `AN5506-02-B` | GPON bridging-type ONT | 2GE + 1POTS | 官方 |
| `AN5506-04-A` | 社区固件型号 | ChinaDSL 固件版本线索 | 社区 |
| `AN5506-04-B` | GPON ONT | Anatel/FCC 用户手册，含 Web GUI、LED、安装流程 | 官方/认证 |
| `AN5506-04-F` | GPON ONU | `RP2617` 漏洞资料 | 研究 |
| `AN5506-04-FA` | PLDT/社区高频型号 | `RP2627`、串口、bootlog、`U-Boot 2010.03`、`Linux 2.6.34.10`、`JFFS2` | 研究 |
| `AN5506-04-G2` | GPON ONT | 葡语市场手册 PDF 线索 | 官方/认证 |

### SR / WA / AX 相关

| 型号或系列 | 定位 | 已整理能力 | 来源状态 |
| --- | --- | --- | --- |
| `SR1041F` | Smart Router | `WEB UI / TR-069 / FiberHome APP / Aquar cloud platform`、EasyMesh、`802.11k/v/r` | 官方 |
| `SR1021F` | Smart Router | PDF 线索含 EasyMesh 与 `802.11k/v/r` | 官方 |
| `SR3141M` | Smart Router / Mesh | PDF 线索含 EasyMesh | 官方 |
| `WA2000/WA3000/WA3200/WA3300E/WA3400D/WA3500D/WA5500M` | CPE/WA 系列 | PDF 线索含 `Telnet / WEB / TR-069 ACS` | 官方 |
| `AX` | 系列关键字 | Research 中仅作为待补关键字出现 | 待验证 |

## 软件与平台

### Linux / BusyBox / Buildroot

公开 bootlog 和 GitHub 仓库显示，部分 FiberHome ONT 使用嵌入式 Linux、MTD 分区和 JFFS2 文件系统。`AN5506-04-FA` bootlog 中可见 `U-Boot 2010.03-svn671412`、`Linux-2.6.34.10`、`rootfstype=jffs2` 和 `mtdparts`。

Research 中尚未定位到 FiberHome 官方 GPL Release / OSS Center 的稳定下载入口；当前可确认的开源上游资料包括 Linux Kernel、Buildroot、BusyBox、Bootlin Buildroot training，以及非官方 GitHub 仓库中的固件拆分线索。

### Web Framework / Web UI

公开研究中出现过 `webs` 进程命名；社区资料大量围绕 Web UI 的隐藏页面、地区模板、桥接页面、升级页面和超级管理员菜单展开。`fiberhome_exporter` 仓库显示部分 `HG6145F` 可通过 WebUI JSON API 抓取状态。

### TR-069 / CWMP

`HG6145D2`、`HG6145F1` 官方资料明确列出 `OMCI / Web UI / TR-069`，并支持远程管理、远程升级和业务自动下发。`HG6145D2` 资料还提到可通过 `TR-069` 传送 XML 配置文件。

`SR1041F` 与 WA/CPE PDF 资料也出现 `TR-069 ACS`、`WEB UI`、云平台或 APP 管理线索。正式整理时应把 `TR-069` 视为运营商远程配置与回写的重要来源。

### OMCI

`OMCI` 是 FiberHome ONT 的稳定管理面。`AN5506-01-A` 官方资料明确写明基于 `OMCI` 的自动业务下发、管理和远程升级；`HG6145D2/HG6145F1` 同时列出 `OMCI` 与 `TR-069`。

### DBus / 私有 IPC

当前 Research 未定位到可确认的 FiberHome ONT `DBus` 对象树或私有总线文档。该主题保留为待补充项，后续应从 GPL、rootfs、进程间通信和 Web 后端二进制中继续确认。

## 固件与启动链

| 型号 | 版本/线索 | Bootloader | Kernel | Rootfs/Filesystem | 来源状态 |
| --- | --- | --- | --- | --- | --- |
| `HG6245D` | `RP2602`、`RP2613` | 未标注 | 未标注 | 未标注 | 研究 |
| `AN5506-04-F` | `RP2617` | 未标注 | 未标注 | 未标注 | 研究 |
| `AN5506-01A` | `RP2511` | 未标注 | 未标注 | 未标注 | 研究 |
| `HG6145F1` | `RP4423` | 未标注 | 未标注 | Web 配置文件可导出，存在加密/重封装工具线索 | 研究 |
| `AN5506-04-FA` | `RP2627` | 未标注 | 未标注 | 串口/控制台研究仓库 | 研究 |
| `AN5506-04-FA` | `AN5506_04F1A.img/.bin` | `U-Boot 2010.03-svn671412` | `Linux-2.6.34.10` | `JFFS2` | 研究 |
| `HG6145D` | 山西移动固件配置线索 | 未标注 | 未标注 | 未标注 | 社区 |
| `AN5506-04-A` | 三个版本固件线索 | 未标注 | 未标注 | 未标注 | 社区 |

启动链相关关键词：

- `StartCode`
- `U-Boot`
- `mtdparts`
- `kernel_rootfsA/B`
- `app_binA/B`
- `app_exA/B`
- `cfg`
- `rootfstype=jffs2`

## 配置与持久化

FiberHome 的配置资料可以分为三个层次：PON 侧管理参数、本地 Web/UI 配置、文件系统或配置分区中的持久化数据。

| 对象 | 资料整理 | 来源状态 |
| --- | --- | --- |
| `cfg` 分区 | `AN5506-04-FA` bootlog 中可见独立配置分区线索 | 研究 |
| Web 导出配置文件 | `HG6145F1 RP4423` 存在配置文件解密/重加密工具链 | 研究 |
| `/flash/cfg/agentconf/` | `HG2543C1` 博客桥接记录中出现 | 社区 |
| `/flash/cfg/app_conf/` | `HG2543C1` 博客桥接记录中出现 | 社区 |
| `SoftwareModules` | `HG6145D1` 中国移动博客记录中出现 | 社区 |
| `com.cmcc.wuyougateway` | `HG6145D1` 中国移动博客记录中出现 | 社区 |
| 逻辑 `SN` / `LOID` | `AN5506_01A2G` 恩山替换光猫讨论中出现 | 社区 |

### SN / MAC / LOID / Password

`HG8143F` 官方 PDF 线索显示 FiberHome 设备可能支持 `SN`、`Password`、`SN+Password`、`LOID` 多种 PON 认证方式。国内社区资料中，`SN`、逻辑 `SN`、`LOID`、`VID`、地区模板、运营商配置经常一起出现。

这些字段可能参与 PON 注册、运营商绑定、业务模板下发和替换光猫流程。不同运营商和地区的字段名称、是否可见、是否可写差异较大，正式文档中应按型号和运营商记录，不应跨型号套用。

## 调试入口

### Telnet

`Telnet` 在社区资料中出现频率很高，尤其集中在中国移动 `HG6145D/HG6145D1/HG6145F3`、中国电信部分 `HG` 型号和 `AN5506` 讨论。它通常与隐藏页面、工厂模式、超级管理员、配置导出或命令行维护一起出现。

当前整理状态：

- 官方资料通常不把 `Telnet` 作为 ONT 常规管理面公开。
- ChinaDSL 有 `HG6145D` 新版开 Telnet 主题。
- 恩山有 `HG6145F3` 移动版替换和 `telnetenable.cgi` 线索。
- 恩山和博客中出现 `show admin_pwd`、`show admin_name`、`show allinfo`、`load preconfig` 等 CLI 字符串。

### SSH

`SSH` 的公开资料少于 `Telnet`。Research 中暂未形成稳定型号矩阵。若后续 GPL/rootfs 发现 `dropbear` 或 `sshd`，应补充到软件组件与命令索引。

### UART / TTL / 串口

`AN5506-04-FA` bootlog、`fiberhome-AN5506-04F-` GitHub 仓库、PLDT `fiberhomesuperadmin` 仓库、ChinaDSL `HG6543C4 ttl的启动过程` 均属于串口/boot/debug 方向的重要资料。

### Factory / Engineering Mode

恩山 `HG3142F` 资料中出现 `factory`、`load_cli` 等关键词；PLDT `AN5506-04-FA` 资料中出现高级界面和串口控制台研究。该类资料应保留为“维护模式/工程模式”线索，避免直接泛化到全部型号。

## 命令索引

本节整理公开出现过的命令或关键词。这里的“命令”包含 shell 命令、CLI 关键词、隐藏入口字符串、配置分区名和诊断组件名。部分条目来自社区或漏洞资料，不能直接视为全部型号可用。

| 命令/关键词 | 分类 | 适用型号 | 来源状态 | 备注 |
| --- | --- | --- | --- | --- |
| `uname -a` | Linux shell | 已获得 shell 的机型 | 通用 | 内核与架构识别 |
| `ps` | Linux shell | 已获得 shell 的机型 | 通用/研究 | 公开研究中出现 `webs` 等进程线索 |
| `netstat -lnp` | Linux shell | BusyBox 带 `netstat` 的机型 | 通用 | 监听端口与进程 |
| `ifconfig` | Linux shell | BusyBox 网络工具链机型 | 通用 | 接口信息 |
| `route -n` | Linux shell | BusyBox 网络工具链机型 | 通用 | 路由表 |
| `mount` | Linux shell | 已获得 shell 的机型 | 通用/研究 | 文件系统挂载 |
| `cat /proc/mtd` | Linux shell | MTD 架构机型 | 研究 | 分区布局 |
| `cat /proc/cmdline` | Linux shell | 已获得 shell 的机型 | 研究 | 启动参数 |
| `df -h` | Linux shell | 已获得 shell 的机型 | 通用 | 分区空间 |
| `dmesg` | Linux shell | 已获得 shell 的机型 | 通用 | 内核日志 |
| `sync` | Linux shell | 已获得 shell 的机型 | 通用 | 刷新缓存 |
| `reboot` | Linux shell | 已获得 shell 的机型 | 通用 | 重启 |
| `debug` | 调试关键词 | `AN5506-04-FA` | 社区 | PLDT 资料中出现 |
| `telnet` | 管理面关键词 | `HG6145D` 等 | 社区 | ChinaDSL/恩山高频主题 |
| `telnetenable.cgi` | 隐藏入口关键词 | `HG6145F3` | 社区 | 恩山移动版资料中出现 |
| `factory` | 工厂模式关键词 | `HG3142F` | 社区 | 恩山资料中出现 |
| `load_cli` | CLI 关键词 | `HG3142F` | 社区 | 恩山资料中出现 |
| `show admin_pwd` | CLI 关键词 | `HG6143D1` 等 | 社区 | 电信语境资料中出现 |
| `show admin_name` | CLI 关键词 | `HG` 系列未明确子型号 | 社区 | 移动版博客资料中出现 |
| `show allinfo` | CLI 关键词 | 未标注 | 社区 | 电信版本讨论中出现 |
| `load preconfig` | CLI 关键词 | 未标注 | 社区 | 电信版本讨论中出现 |
| `cfg` | 分区名/配置关键词 | `AN5506-04-FA` | 研究 | bootlog 分区名 |
| `shell` | 调试关键词 | `AN5506-04F` | 研究 | GitHub 仓库主题 |
| `diag` | 诊断关键词 | `AN5506-04-F RP2617` | 研究 | 漏洞资料中的 ping diagnostic tool |
| `sendcmd` | 待补关键词 | 未定位到 FiberHome Research 直接来源 | 待验证 | 后续若在 GPL/论坛中出现再补来源 |

## 网络与业务

### 桥接 / 路由

`AN5506-01-A` 官方资料明确支持 `Bridged` 与 `Routed Internet Service`。`HG` 系列作为家庭网关型 ONT，社区资料中常见“改桥接”“隐藏桥接页面”“运营商远程回写”等主题。

整理时应区分：

- 设备能力是否支持桥接
- Web UI 是否开放桥接菜单
- 运营商模板是否允许修改
- 修改后是否会被 `OMCI/TR-069` 回写
- IPTV/VoIP/远程管理是否依赖原 WAN 模式

### Mesh / EasyMesh

官方资料已确认 `SR1041F`、`SR1021F`、`SR3141M`、`HG8143F` 或相关 PDF 中存在 EasyMesh / `802.11k/v/r` 线索。`HG6145F1/HG6145F3/HG6543D/HG6145D2` 是否开放 EasyMesh，需要按运营商固件继续验证。

### Wi-Fi

`HG` 新代型号覆盖 Wi-Fi 5、Wi-Fi 6、Wi-Fi 7。社区资料中 `HG6145F1 RP4423` 出现默认 Wi-Fi 密码可预测相关研究和工具线索，属于安全主题，应按型号、运营商、版本分别记录。

### LED / 按键

`HG6145F3` 官方 PDF 明确出现 `Power/PON/LOS/Internet/Phone/USB/LAN/WLAN/WPS` 指示灯集合。`SR1041E` 官方资料可见 `Reset` 短按重启、长按恢复出厂，`WPS` 长按启动协商。

不同型号外壳、运营商版本和指示灯丝印可能不同。LED 表应按型号补充，不要用单一型号覆盖全部 FiberHome ONT。

## 运营商差异

### 中国移动

| 型号 | 整理内容 | 来源状态 |
| --- | --- | --- |
| `HG6145D/HG6145D1` | 北京移动/联通资料中出现管理员密码、改省份、桥接、拆解 | 社区 |
| `HG6145F3` | 移动版替换光猫、Telnet、超管、桥接资料 | 社区 |
| `HG6145D` | ChinaDSL 移动新版 Telnet、隐藏界面、配置文件位置 | 社区 |
| `HG6145D1` | 博客记录 `CMCC`、`RP0303`、`LOID`、`SoftwareModules` 片段 | 社区 |

### 中国联通

| 型号 | 整理内容 | 来源状态 |
| --- | --- | --- |
| `HG6142A` | 山东联通超级管理员与桥接资料 | 社区 |
| `HG3142F` | 管理员密码、工厂模式、`load_cli` 资料 | 社区 |
| `HG6543C` | 联通桥接博客记录 | 社区 |

### 中国电信

| 型号 | 整理内容 | 来源状态 |
| --- | --- | --- |
| `HG6143D1` | Telnet 用户名/密码、超级用户讨论 | 社区 |
| 未标注 | 新版 Telnet、超密、省份、`OPERATOR_NAME` 讨论 | 社区 |

### 广电

| 型号 | 整理内容 | 来源状态 |
| --- | --- | --- |
| `HG6340A` | 株洲广电登录问题，Telnet 无法开启 | 社区 |

### 海外运营商

| 运营商 | 型号 | 整理内容 | 来源状态 |
| --- | --- | --- | --- |
| PLDT | `AN5506-04-FA RP2627` | 高级界面、串口控制台、默认管理资料 | 研究/社区 |
| Algérie Télécom | `HG6145F1 RP4423` | 配置工具、默认密码/预测研究、漏洞资料 | 研究 |
| ViewQwest | `HG6240A` | 新加坡替换光猫讨论 | 社区 |
| IndiHome | `AN5506-04F` | GitHub 仓库语境，boot/filesystem/MTD | 研究 |

## 安全与限制

FiberHome 公开安全资料集中在 `HG6245D`、`AN5506`、`HG6145F1 RP4423`。这些资料用于帮助整理风险面和版本差异，不应直接泛化到全部 FiberHome 设备。

| 型号 | 版本 | 主题 | 来源状态 |
| --- | --- | --- | --- |
| `HG6245D` | `RP2602/RP2613` | 多个公开漏洞研究 | 研究 |
| `AN5506-04-F` | `RP2617` | OS command injection advisory | 研究 |
| `AN5506-01A` | `RP2511` | 漏洞 advisory | 研究 |
| `HG6145F1` | `RP4423` | 配置/密码/漏洞研究 | 研究 |

运营商限制常见表现：

- 超级管理员账号存在但菜单被隐藏
- 桥接、TR-069、升级页面不可见或只读
- 恢复出厂后被远程重新下发配置
- 地区模板、运营商模板、业务模板影响 Web UI
- `SN/MAC/LOID` 页面存在但不可写

## 待验证

以下内容保留，不删除：

- `sendcmd` 是否在 FiberHome GPL、rootfs 或论坛资料中出现，当前 Research 未定位到直接来源。
- `HG6145F1/HG6145F3/HG6543D/HG6145D2` 的 EasyMesh 是否在具体运营商固件中开放。
- `AN` 系列是否普遍存在 `TR-069` 本地页面；官方 `AN5506-01-A` 资料主要强调 `OMCI`。
- `SSH/dropbear` 在各型号固件中的存在范围。
- `/flash/cfg/agentconf/` 与 `/flash/cfg/app_conf/` 是否跨型号通用，目前主要来自 `HG2543C1` 博客。
- 国内不同运营商的 `show admin_pwd`、`show admin_name`、`show allinfo` 等 CLI 字符串是否同属一个 CLI 框架。
- `HG6240A`、`HG680P` 等海外或非典型型号是否应纳入 ONT 主系列，还是单独作为 FiberHome 设备资料。
- 官方 GPL Release / OSS Center 的稳定入口仍未定位到。

## 来源

- FiberHome 官方 ONTs Series: https://en.fiberhome.com/ONTsSeries.html
- FiberHome `HG6145D2`: https://en.fiberhome.com/TNOTN/20240126/46266.html
- FiberHome `HG6145F1`: https://en.fiberhome.com/ONTsSeries/20240102/45830.html
- FiberHome `AN5506-01-A`: https://en.fiberhome.com/ONTsSeries/20240130/46447.html
- FiberHome GPON no Wi-Fi ONT Product Specifications: https://en.fiberhome.com/FASInformation/20240124/46083.html
- FiberHome Smart Home: https://en.fiberhome.com/SmartHome.html
- FiberHome `HG6145F3` PDF: https://en.fiberhome.com/u/cms/fhgj/202602/271653346lr1.pdf
- FiberHome `HG8143F` PDF: https://en.fiberhome.com/u/cms/fhgj/202602/271653347y4r.pdf
- Pierre Kim FiberHome HG6245D / AN5506 research: https://pierrekim.github.io/blog/2021-01-12-fiberhome-ont-0day-vulnerabilities.html
- AN5506-04-FA bootlog: https://gist.github.com/platkaw/926b7176714e02f3c729680584400f2d
- fiberhome-AN5506-04F-: https://github.com/ndunks/fiberhome-AN5506-04F-
- fiberhomesuperadmin: https://github.com/bkspc/fiberhomesuperadmin
- fiberhome-config-utility: https://github.com/numberonedz/fiberhome-config-utility
- fiberhome_exporter: https://github.com/mcbyte-it/fiberhome_exporter
- GitHub Advisory `AN5506-04-F RP2617`: https://github.com/advisories/GHSA-hcfv-5p8h-vvh5
- GitHub Advisory `AN5506-01A RP2511`: https://github.com/advisories/GHSA-22m8-5g68-4439
- GitHub Advisory `HG6145F1 RP4423`: https://github.com/advisories/GHSA-cg2x-c25f-6327
- 恩山 `HG6145D/HG6145D1`: https://www.right.com.cn/forum/thread-8230876-27-1.html
- 恩山 `HG6142A`: https://www.right.com.cn/forum/thread-8252962-1-1.html
- 恩山 `HG6145F3`: https://www.right.com.cn/forum/thread-8436021-1-1.html
- 恩山 `HG3142F`: https://www.right.com.cn/forum/thread-8434746-1-1.html
- 恩山 `AN5506_01A2G`: https://www.right.com.cn/forum/thread-8395440-1-1.html
- ChinaDSL `HG6145D` Telnet: https://www.chinadsl.net/thread-170876-1-1.html
- ChinaDSL `HG6543C4` TTL: https://www.chinadsl.net/thread-166049-1-1.html
- ChinaDSL `HG6340A`: https://www.chinadsl.net/thread-178004-1-1.html
- HG2543C1 桥接博客: https://blog.ningwang.me/posts/fiberhome-hg254c1-bridging/
- HG6145D1 博客园记录: https://www.cnblogs.com/backuper/p/19022601
- Broadband Forum TR-069: https://www.broadband-forum.org/pdfs/tr-069-1-6-0.pdf
- Broadband Forum TR-156: https://www.broadband-forum.org/pdfs/tr-156-4-0-0.pdf
- Buildroot: https://buildroot.org/
- BusyBox: https://busybox.net/
- Linux Kernel: https://www.kernel.org/
