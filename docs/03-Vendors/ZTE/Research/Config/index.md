# Config Index

本页只收录配置文件、配置数据库、导出导入与恢复线索。

| 对象 | Evidence | 上下文 | 来源 |
| --- | --- | --- | --- |
| `config.bin` | B | `zte-config-utility` 重点处理对象 | <https://github.com/mkst/zte-config-utility> |
| `db_user_cfg.xml` | B/C | ZTE ONT 常见用户配置文件；社区大量讨论 | GitHub + ChinaDSL + 恩山 |
| `db_backup_cfg.xml` | C | 社区常称为备份配置 | ChinaDSL |
| `db_default_cfg.xml` | C | 社区常称为运营商默认配置 | ChinaDSL |
| `db_default_auto_cfg.xml` | B | GitHub 样本中出现；Type-3 DB | <https://github.com/mkst/zte-config-utility> |
| `/userconfig/cfg/` | C | 社区常见配置目录 | ChinaDSL |
| `/tmp/debug-decry-cfg` | C | `sendcmd`/`sidbg ... decry` 后的输出目录线索 | GitHub issue + ChinaDSL |
| `DevAuthInfo` | B/C | Web 账号/密码/级别 | GitHub + 社区 |
| `TelnetCfg` | B/C | Telnet 配置 | GitHub + 社区 |
| `TelnetUser` | C | Telnet 用户表 | 恩山 |
| `MgtServer` | C | TR-069 / ACS | 恩山 |
| `WANC` | C | WAN 连接/业务类型 | 恩山 |
| `PDTCTUSERINFO` | C | 注册页/LOID/状态线索 | ChinaDSL |
| `WLANCfg` | C | SSID 前缀等无线字段 | ChinaDSL |
| `FWBase` | C | 连接数限制 | 恩山 |
| `PortControl` | C | 端口开关 | Gist/社区 |
| `FTPUser` / `FTPServerCfg` | C/D | FTP 相关字段 | GitHub repo / ChinaDSL |

## 文件/数据库相关命令线索

- `sendcmd 1 DB decry /userconfig/cfg/db_user_cfg.xml`
- `sidbg 1 DB decry /userconfig/cfg/db_user_cfg.xml`
- `tftp -p -l userconfig/cfg/db_user_cfg.xml -r db_user_cfg.xml 192.168.1.2`
- `tftp -g -r db_user_cfg.xml 192.168.1.2`

## 备注

- 这里只保留对象与出现线索。
- 不在本页判定“哪种修改方式才是最终正确做法”。
