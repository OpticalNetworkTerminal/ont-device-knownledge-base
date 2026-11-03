# Guides

本页按“入口主题”整理天邑设备的正式知识，而不是按论坛帖子拆分。重点覆盖 Telnet、SSH、隐藏页面、超级管理员、桥接、恢复、升级、Mesh、双模与设备标识项。

## 主题索引

| 主题 | 关键入口/线索 | 代表机型 |
| --- | --- | --- |
| Telnet | `/enableTelnet.html`、`telandftpcfg.cmd`、`POST /setObjs` | `TEWA-708E`、`872G`、`1006G` |
| SSH | Samba、`start_ssh.sh`、`ip6tables` | `TEWA-1000E` |
| 隐藏页面 | `usbbackup.cmd`、`enableTelnet.html`、`sessionKey` | `TEWA-708E`、`768G` |
| 超级管理员 | `TeleComAccount`、`telecomadmin get`、`CUAdmin get` | `708E`、`1006G`、早期机型 |
| 配置恢复 | CFG/XML、导回、业务下发 | 多型号 |
| 升级 | Web 升级、运营商模板覆盖 | 多型号 |
| 桥接 | 超管界面、业务模板、远程修改 | `1000E`、`800E` |
| Mesh | 智能组网、功能显示受限 | 多型号 |
| 双模 | GPON / EPON / XG-PON 产品谱系 | 多型号 |
| SN / MAC / LOID | 标识读取、备份、恢复后行为 | 多型号 |

## Telnet

### 常见路径

目前天邑资料中的 Telnet 开启路径至少有三类：

1. 直接访问隐藏页面
2. 通过隐藏 CGI 写配置
3. 通过对象接口写入管理对象

### 路径一：`/enableTelnet.html`

这是目前最稳定、最知名的一条路径，至少在 `TEWA-708E` 上有明确资料。

- 典型前提:
  - 先获得可用的高权限 Web 登录态
- 典型效果:
  - 启用 Telnet 服务

### 路径二：`telandftpcfg.cmd`

这是后期社区资料中非常高频的一条路径。

- 常见搭配:
  - `set3_sessionKey`
  - 手工拼接 CGI 参数
- 典型效果:
  - 一次性开启 Telnet 与 FTP

### 路径三：`POST /setObjs`

这是 `TEWA-872G` 中出现的对象模型写入方案。

- 典型特征:
  - 直接写 `InternetGatewayDevice.DeviceInfo.X_CMCC_ServiceManage.`
  - 更像配置对象层，而不是单纯的页面绕过

### Telnet 后的环境

进入 Telnet 后，不一定立刻得到标准 shell。公开资料显示至少存在以下情况：

- 只能执行受限维护命令
- 可执行 `telecomadmin get`
- 可进一步 `su`
- 可借由特殊行为切到更高权限用户

### 待验证

- 天邑不同分代固件对 Telnet 的过滤差异。
- `admin/admin`、`user/user` 等默认凭据是否统一。
- Telnet 是否会被运营商模板在重启后覆盖。

### 来源

- GitHub / GitHub Issues
- 恩山
- ChinaDSL

## SSH

### 当前已知主线

目前公开资料主要集中在 `TEWA-1000E`。

已知链路包括：

- 在受限环境中取得更高权限
- 修改 `/var/samba/smb.conf`
- 通过 Samba 把根目录映射出来
- 向 `/opt/upt/apps/ssh/` 写入 SSH 相关文件
- 运行 `/opt/upt/apps/ssh/start_ssh.sh`
- 用 `ip6tables` 放行 IPv6 入站 22 端口

### 这条链路说明了什么

- 天邑设备底层是常规 Linux 风格运行时。
- 至少部分应用目录可读写。
- Samba、应用目录、用户组与防火墙之间可以串出完整的提权和远程接入链路。

### 待验证

- 其它型号能否复用同样目录结构。
- `sshd` 是否受 CPU 架构或 C 库版本限制。
- 自启是否必须依赖 `ommonitord`。

### 来源

- GitHub Issue #24

## 隐藏页面与前端调试

### `sessionKey`

天邑很多路径并不是直接裸露，而是依赖 `sessionKey` 或其变体。

常见获取位置：

- 页面源码
- 浏览器控制台
- `Sources`
- `Network`

### `set2_sessionKey` / `set3_sessionKey`

这是后期固件讨论中经常出现的参数名。它们通常意味着：

- 页面不再把关键参数明文放在旧位置
- 需要从更深的 JS 或网络请求中挖出参数
- 相关 CGI 可能是隐藏但仍保留的

### 已知隐藏页

- `usbbackup.cmd`
- `enableTelnet.html`

### 待验证

- `hidden_version_switch.html`
- `hidden_version_switch.gch`
- `return2factory.gch`
- `bridge_route.gch`

这些名称在社区有提及，但当前还没有足够天邑样本支撑为正式结论。

### 来源

- GitHub
- 恩山
- ChinaDSL

## 超级管理员

### 主要获取路径

当前整理后，天邑超管资料主要可以归并为三条路径：

1. 导出 CFG/XML 后搜索 `TeleComAccount`
2. Telnet 后执行 `telecomadmin get`
3. 早期型号执行 `CUAdmin get`

### 路径一：配置提取

这是最稳定、也最像“离线取证”的方法。

- 先获取配置
- 再解码 CFG 或读取 XML
- 搜索 `TeleComAccount` 等关键字段

### 路径二：`telecomadmin get`

这是后期社区整理里经常出现的命令。

- 常见于：
  - `TEWA-1006G`
  - 社区也延伸到 `708E / 1000E`

### 路径三：`CUAdmin get`

更常见于旧设备、旧固件和早期教程。

### 待验证

- 超管密码是否每次业务下发后改变。
- `TeleComAccount` 是否总是超管信息，而不是部分型号的其它凭据字段。
- 各运营商定制分支是否共用相同命令。

### 来源

- GitHub
- 恩山
- ChinaDSL

## 配置恢复

### 当前主线

从现有资料看，天邑设备的恢复问题主要围绕四件事：

1. 有没有导出配置
2. 配置是 CFG、XML 还是运营商对象树
3. 恢复出厂后哪些业务参数会丢
4. 重新导入后是否会被运营商模板覆盖

### 常见高风险项

- `LOID`
- 宽带账号
- 电话账号
- `SN`
- `MAC`
- 桥接配置
- IPTV/VLAN

### 待验证

- 恢复出厂后 `LOID / SN / MAC` 的保留行为。
- CFG 是否支持跨版本导回。
- 导入后 TR-069 是否会重新覆盖本地改动。

### 来源

- 社区帖子汇总
- GitHub 相关讨论

## 升级

### 当前已知点

- 升级入口通常仍在 Web 管理界面。
- 真正值得关注的是升级后是否：
  - 关闭隐藏页面
  - 改变 `sessionKey` 获取方式
  - 收紧 Telnet / SSH
  - 改写桥接与运营商模板行为

### 现阶段不足

- 公开升级包样本较少。
- 官方公开 GPL / firmware 下载入口暂未明确。
- 还缺 Bootloader、签名、分区布局样本。

### 待验证

- 升级包格式
- 校验或签名机制
- 是否存在双固件或双配置分区

### 来源

- 社区帖子
- Research/Firmware

## 桥接

### 当前整理结论

桥接是天邑社区需求最高的主题之一，但它不是单一功能，而是几类问题的叠加：

- 是否能看到桥接页面
- 是否有超管权限
- 业务模板是否允许改桥接
- 改完后是否会被运营商下发覆盖

### 已知线索

- `TEWA-1000E` 有社区远程改桥接过程记录。
- `TEWA-800E` 在联通场景下也常被问及桥接。
- 许多天邑帖子默认把“获取超管”与“改桥接”绑定为一组需求。

### 待验证

- 各运营商模板下的 VLAN 绑定方式。
- IPTV 与桥接的联动影响。
- 桥接页面是否只是前端限制，还是底层对象本身被锁。

### 来源

- ChinaDSL
- 恩山

## Mesh / 智能组网

### 当前情况

与桥接相比，天邑公开的 Mesh 资料明显更少，但可以确认：

- 官方产品线与年报长期提到智能组网、FTTR、WiFi7、家庭网关。
- 社区对“组网显示项”“隐藏页面”“功能限制”的讨论零散存在。

### 整理建议

当前更适合把 Mesh 当成“运营商模板与功能显示限制”的一部分，而不是先写死具体操作教程。

### 待验证

- 天邑是否存在稳定的 EasyMesh 相关页面或对象路径。
- 不同机型主副设备角色如何表达。
- 超管或隐藏页是否能解锁组网显示项。

### 来源

- 官方年报与产品资料
- 社区零散讨论

## 双模

### 当前情况

天邑公开产品线横跨：

- GPON
- EPON
- XG-PON
- 智能家庭网关

但“用户可切换双模”与“产品族同时覆盖多制式”是两件不同的事，当前社区资料还不足以把它们合并成统一操作结论。

### 待验证

- 是否存在独立的 GPON/EPON 切换页面。
- 切换后是否影响注册与业务下发。
- 双模是否只存在于少数特定硬件平台。

### 来源

- 官方产品资料
- 社区讨论

## SN / MAC / LOID

### 当前整理原则

这部分内容风险最高，因此只整理知识点与风险，不给出未经充分来源支撑的结论性操作。

### 已知关注点

- 导出配置前应优先记录设备标识项。
- 恢复出厂、刷配置、改桥接、重注册都可能涉及这些字段。
- 社区长期关注 `LOID`、`SN`、`MAC` 的读取、保存与回填问题。

### 待验证

- 这些字段在 CFG/XML 中的具体位置。
- 不同运营商定制分支对它们的校验程度。
- 恢复或升级后是否仍会保留。

### 来源

- 社区资料汇总

## 待验证

### 社区存在不同观点的主题

- `sendcmd` 的真实作用范围
- `saveasy` 的准确拼写与后端实现
- `hidden_version_switch` / `return2factory` / `bridge_route` 一类页面是否真实存在于天邑当前固件
- `;` 触发 root 的机理
- “中兴版 TEWA-1100G”的含义

后续应继续以 [Research](../Research/README.md) 为底稿补充来源，再回写本页。

## 来源

- GitHub / GitHub Issues
- 恩山无线论坛
- ChinaDSL
- 官方资料
- 详细来源链见 [Research](../Research/README.md)
