# Database

本页整理天邑设备的配置文件、数据库、对象树、文件路径与持久化线索。它和 [Commands](../Commands/README.md) 不同，关注的是“数据存在哪里、怎么被前端和命令层引用”。

## 配置与数据库总览

| 对象 | 路径/名称 | 用途 | 常见机型 | 状态 |
| --- | --- | --- | --- | --- |
| U 盘备份配置 | `ctce8_*.cfg` | 导出的配置备份文件 | `TEWA-708E`、`768G` 等 | 已整理 |
| 用户配置文件 | `/userconfig/cfg/db_user_cfg.xml` | 用户侧配置数据库 | 多型号 | 社区资料 |
| Samba 配置 | `/var/samba/smb.conf` | 共享配置 | `TEWA-1000E` | 已整理 |
| SSH 目录 | `/opt/upt/apps/ssh/` | 自建 SSH 服务文件 | `TEWA-1000E` | 已整理 |
| 自启钩子 | `/opt/upt/apps/apps/opt/apps/opmaintain/diagapps/ommonitord` | 自启相关线索 | `TEWA-1000E` | 社区资料 |
| 组信息 | `/var/group` | 用户组调整 | `TEWA-1000E` | 已整理 |
| U 盘挂载点 | `/mnt/usb1_1` | 配置备份与文件交换 | 多型号 | 已整理 |

## CFG 与 XML

### `ctce8_*.cfg`

目前公开资料最明确的是这类配置备份文件。

- 已知样本:
  - `ctce8_TEWA-708E.cfg`
  - `ctce8_TEWA-768G.cfg`
- 已知用途:
  - 导出后解码
  - 搜索超管、宽带账号、电话参数、业务字段
- 已知特征:
  - `TEWA-708E` 样本可通过 `byte ^ 0xff` 还原
- 常见研究方向:
  - 是否所有天邑 `ctce8_*.cfg` 都采用相同编码
  - CFG 与 XML 是否只是不同包装层

#### 来源

- GitHub: `jonirrings/xor`
- GitHub Issue #19
- 恩山
- ChinaDSL

### `/userconfig/cfg/db_user_cfg.xml`

这是社区反复提及的配置数据库路径。

- 常见说法:
  - 可通过 FTP 或文件系统路径获取
  - 解开后可搜索 `telecomadmin`、`TeleComAccount`
  - 宽带账号、语音参数、运营商配置也可能在同一文件或关联文件中
- 当前整理结论:
  - 该路径在社区出现频率足够高，值得作为正式知识点保留。
  - 但其内部结构、字段字典与不同型号之间的一致性仍需要更多样本。

#### 来源

- ChinaDSL
- 恩山
- GitHub 相关讨论链

## 高价值字段

### `TeleComAccount`

这是天邑资料中最常被检索的关键字段之一。

- 常见用途:
  - 提取超管密码
  - 作为“配置文件是否解码成功”的快速判断字段
- 典型关联:
  - `TEWA-708E`
  - 其它社区提到的电信定制机型

#### 来源

- GitHub: `jonirrings/xor`
- 恩山
- ChinaDSL

### `sessionKey` / `set2_sessionKey` / `set3_sessionKey`

这些字段本质上不一定属于“数据库字段”，但它们是连接前端页面、隐藏 CGI 与配置修改流程的关键标识，所以一并收录在本页。

- `sessionKey`
  - 常见于较早期页面源码或控制台变量
- `set2_sessionKey`
  - 社区用于区分后期固件的一类入口参数
- `set3_sessionKey`
  - 与 `telandftpcfg.cmd` 一类新教程强相关

#### 当前观察

- 它们是“进入配置修改路径”的关键钥匙，而不是单纯的静态字段。
- 不同固件把它们藏在 HTML、JS、Network 请求或表单中。

#### 来源

- GitHub
- 恩山
- ChinaDSL

## 对象树与管理模型

### `InternetGatewayDevice.DeviceInfo.X_CMCC_ServiceManage.`

`TEWA-872G` 的 `POST /setObjs` 样本提供了一个重要线索：天邑至少部分机型通过对象树进行设备配置，且对象结构明显接近 TR-069 / TR-181 体系。

这意味着：

- 天邑某些 Web 配置页可能只是对象写入的前端包装。
- 运营商定制功能，如 Telnet、远程管理、桥接控制，很可能被封装在厂商扩展对象下。
- 不同运营商可能有不同的 `X_` 私有命名空间。

#### 来源

- GitHub Issue #23
- Broadband Forum `TR-069` / `TR-181`

## Linux 路径与持久化线索

### `/var/samba/smb.conf`

- 用途:
  - Samba 配置
  - 社区已利用它追加共享，将 `/` 暴露为网络共享目录
- 价值:
  - 证明设备至少部分运行时路径可修改
  - 为后续写入 SSH、查看根文件系统提供落点

### `/opt/upt/apps/ssh/`

- 用途:
  - 存放自建 SSH 文件
- 价值:
  - 反映天邑固件中存在较完整的应用目录层次

### `/opt/upt/apps/apps/opt/apps/opmaintain/diagapps/ommonitord`

- 用途:
  - 社区作为自启切入点提及
- 价值:
  - 暗示诊断/维护进程可能是启动链的一部分

### `/var/group`

- 用途:
  - 用户组控制
- 价值:
  - 社区已将其用于提高用户组权限

## 运营商配置

从目前资料看，天邑配置库里最值得长期跟踪的运营商相关数据包括：

- 超级管理员
- 宽带账号与密码
- 电话账号与密码
- `LOID`
- `SN`
- `MAC`
- 桥接模板
- VLAN / IPTV
- TR-069 / ACS 参数

这些字段很可能并不总在同一个文件中，但通常会在：

- CFG 备份
- XML 配置
- 对象树
- 设备命令层

之间相互映射。

## 恢复与升级相关

数据库视角下，恢复与升级最关键的问题不是“如何点按钮”，而是：

- 恢复出厂后哪些字段会丢失
- 配置导回是否有版本绑定
- 是否存在签名、校验或运营商模板覆盖
- 升级后隐藏页、Telnet、对象树是否变化

这几个问题目前都没有足够样本，故暂保留为待验证。

## 待验证

- `db_user_cfg.xml` 的完整字段结构。
- `sendcmd 1 DB save` 与 `saveasy` 的真实实现对象。
- CFG 与 XML 的相互转换关系。
- `TeleComAccount` 在不同型号中的字段路径是否一致。
- `LOID`、`SN`、`MAC` 在恢复、升级、重新下发业务后的保留行为。
- `ommonitord` 是否真的是稳定可用的自启钩子。

## 来源

- GitHub / GitHub Issues
- 恩山无线论坛
- ChinaDSL
- Broadband Forum
- 详细原始索引见 [Research/Database 相关目录](../Research/README.md)
