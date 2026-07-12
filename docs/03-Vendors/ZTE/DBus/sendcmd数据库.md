# sendcmd数据库

## 主题说明

本页整理当前已公开可交叉验证的 `sendcmd`/`sidbg` 配置数据库对象、常见表名和操作方式。

## 当前结论

公开资料显示，很多 ZTE ONT 的维护操作都围绕“表 + 行 + 字段”的配置数据库模型展开。

## 已验证表名索引

| 表名 | 常见用途 | 示例 | 状态 |
| --- | --- | --- | --- |
| `TelnetCfg` | Telnet 开关、权限、连接数、插光后行为 | `sendcmd 1 DB p TelnetCfg` | 已验证 |
| `DevAuthInfo` | Web 管理账户/密码/级别 | `sendcmd 1 DB set DevAuthInfo 0 Pass admin` | 已验证 |
| `TelnetUser` | Telnet 用户名/密码 | `sidbg 1 DB set TelnetUser 0 Username root` | 社区资料 |
| `MgtServer` | TR-069 管理配置 | `sendcmd 1 DB set MgtServer 0 Tr069Enable 0` | 社区资料 |
| `WANC` | WAN 连接使能 | `sendcmd 1 DB set WANC 0 Enable 0` | 社区资料 |

## 常见操作模型

### 打印表

```sh
sendcmd 1 DB p TelnetCfg
sidbg 1 DB p DevAuthInfo
```

### 修改字段

```sh
sendcmd 1 DB set TelnetCfg 0 Lan_Enable 1
sendcmd 1 DB set DevAuthInfo 1 Level 1
```

### 保存配置

```sh
sendcmd 1 DB save
sidbg 1 DB save
```

## 配置文件线索

GitHub 与社区资料可确认以下文件名在 ZTE 设备研究中经常出现：

- `/userconfig/cfg/db_user_cfg.xml`
- `db_backup_cfg.xml`
- `db_default_auto_cfg.xml`
- `config.bin`

这说明“运行时数据库”与“导出/加密配置文件”之间很可能存在映射关系，但具体转换过程仍待逐机型验证。

## 验证状态

- 表名存在性：已验证/社区资料混合
- 表结构全量清单：待验证
- 表间关联：待验证

## 来源

- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.right.com.cn/forum/thread-8237756-1-1.html>
- <https://github.com/mkst/zte-config-utility>
- <https://github.com/mkst/zte-config-utility/issues/103>
- <https://github.com/mkst/zte-config-utility/issues/153>
