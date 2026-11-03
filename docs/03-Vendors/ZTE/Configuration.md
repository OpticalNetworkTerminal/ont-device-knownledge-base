# Configuration

本手册汇总 ZTE 配置数据库、配置文件和持久化相关内容。



# Database 总览

# Database

本目录用于放结构化资料，而不是长篇叙述。目标是让命令、配置表、设备清单能被长期追加和去重。

## 当前条目

- [evidence-levels.yaml](./evidence-levels.yaml)
- [sendcmd-command-index.yaml](./sendcmd-command-index.yaml)
- [zte-device-index.csv](./zte-device-index.csv)

## 使用原则

- 文本解释尽量简短，长说明回链到 `Commands`、`Platform` 或 `Research`
- 同一条命令、字段、型号不要在多个 Markdown 中各写一套
- 有争议时保留多条记录和 Evidence，不做静默覆盖

## DB

### 当前结论

公开资料稳定指向一种“表 + 行 + 字段”的配置数据库模型，但表结构、字段名、行号和持久化方式不保证跨型号一致。

### 高优先级表

| 表名 | 常见用途 | 示例 | Evidence |
| --- | --- | --- | --- |
| `TelnetCfg` | Telnet 开关、端口、账号、连接数 | `sendcmd 1 DB p TelnetCfg` | B/C |
| `DevAuthInfo` | Web 管理账户、密码、权限级别 | `sendcmd 1 DB set DevAuthInfo 0 Pass xxx` | B/C |
| `TelnetUser` | Telnet 用户名与密码 | `sidbg 1 DB set TelnetUser 0 Username root` | C |
| `MgtServer` | TR-069 / ACS 管理配置 | `sendcmd 1 DB p MgtServer` | C |
| `WANC` | WAN 连接与业务配置 | `sendcmd 1 DB p WANC` | C |
| `PortControl` | 端口或服务开放控制 | `sendcmd 1 DB p PortControl` | C |
| `DevInfo` | 设备基本信息 | `sendcmd 1 DB p DevInfo` | C |
| `CltLmt` | 用户数限制 | `sendcmd 1 DB p CltLmt` | C |
| `FWBase` | 连接数限制 | `sendcmd 1 DB p FWBase` | C |
| `PDTCTUSERINFO` | 注册状态、LOID 页面逻辑 | `sendcmd 1 DB p PDTCTUSERINFO` | C |
| `WLANCfg` | 无线配置 | `sendcmd 1 DB p WLANCfg` | C |
| `WLCInfo` | 无线控制状态 | `sendcmd 1 DB p WLCInfo` | C |
| `FTPUser` | FTP 用户或权限 | `sendcmd 1 DB p FTPUser` | D |
| `VoIPSIPLine` | 语音线索 | `sendcmd 1 DB p VoIPSIPLine all` | D |

### 配置文件线索

| 文件名 | 角色猜测 | Evidence |
| --- | --- | --- |
| `/userconfig/cfg/db_user_cfg.xml` | 用户配置 XML | B/C |
| `db_backup_cfg.xml` | 备份配置 | C |
| `db_default_cfg.xml` | 默认配置 | C |
| `db_default_auto_cfg.xml` | 默认自动配置 | B/C |
| `config.bin` | 导出/封装配置文件 | B/C |
